#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 -m unittest tests/test_archive_boundary.py

from __future__ import annotations

import os
import shutil
import tarfile
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Final


@dataclass(frozen=True, slots=True)
class ArchiveError(Exception):
    code: str
    detail: str

    def __str__(self) -> str:
        return f"{self.code}: {self.detail}"


@dataclass(frozen=True, slots=True)
class ExtractionLimits:
    members: int = 20_000
    total_bytes: int = 256 * 1024 * 1024
    member_bytes: int = 32 * 1024 * 1024
    expansion_ratio: int = 100


DEFAULT_LIMITS: Final = ExtractionLimits()


@dataclass(frozen=True, slots=True)
class ApprovedSymlink:
    path: str
    target: str


@dataclass(frozen=True, slots=True)
class ExtractionPolicy:
    expected_root: str
    limits: ExtractionLimits = DEFAULT_LIMITS
    approved_symlinks: tuple[ApprovedSymlink, ...] = ()


def _relative_parts(name: str, expected_root: str) -> tuple[str, ...]:
    if "\0" in name:
        raise ArchiveError("archive_nul_path", name)
    if name.startswith("/"):
        raise ArchiveError("archive_absolute_path", name)
    raw_parts = name.split("/")
    if ".." in raw_parts:
        raise ArchiveError("archive_parent_path", name)
    if any(part == "" for part in raw_parts[:-1]):
        raise ArchiveError("archive_empty_path", name)
    normalized = PurePosixPath(name)
    if not normalized.parts or normalized.parts[0] != expected_root:
        raise ArchiveError("archive_root_mismatch", name)
    return tuple(normalized.parts[1:])


def _validate_members(
    archive: Path,
    policy: ExtractionPolicy,
) -> None:
    seen: set[str] = set()
    folded: dict[str, str] = {}
    total_bytes = 0
    approvals = {approval.path: approval for approval in policy.approved_symlinks}
    if len(approvals) != len(policy.approved_symlinks):
        raise ArchiveError("archive_link_policy_invalid", "duplicate approved path")
    observed_links: set[str] = set()
    with tarfile.open(archive, "r:gz") as source:
        for member_count, member in enumerate(source, start=1):
            if member_count > policy.limits.members:
                raise ArchiveError("archive_member_limit", member.name)
            relative_parts = _relative_parts(member.name, policy.expected_root)
            if not relative_parts:
                if not member.isdir():
                    raise ArchiveError("archive_root_type", member.name)
                continue
            relative = "/".join(relative_parts)
            if relative in seen:
                raise ArchiveError("archive_duplicate_path", relative)
            seen.add(relative)
            casefolded = relative.casefold()
            if casefolded in folded and folded[casefolded] != relative:
                raise ArchiveError("archive_casefold_collision", relative)
            folded[casefolded] = relative
            if member.issym() or member.islnk():
                approval = approvals.get(relative)
                if member.islnk() or approval is None or member.linkname != approval.target:
                    raise ArchiveError("archive_link_rejected", relative)
                observed_links.add(relative)
                continue
            if member.sparse or member.type == tarfile.GNUTYPE_SPARSE:
                raise ArchiveError("archive_sparse_rejected", relative)
            if not member.isdir() and not member.isfile():
                raise ArchiveError("archive_unsupported_type", relative)
            if member.size > policy.limits.member_bytes:
                raise ArchiveError("archive_member_size_limit", relative)
            total_bytes += member.size
            if total_bytes > policy.limits.total_bytes:
                raise ArchiveError("archive_total_size_limit", relative)
    if observed_links != approvals.keys():
        raise ArchiveError("archive_link_policy_mismatch", "approved links differ from archive")
    compressed_bytes = archive.stat().st_size
    if compressed_bytes == 0 or total_bytes > compressed_bytes * policy.limits.expansion_ratio:
        raise ArchiveError("archive_expansion_limit", str(total_bytes))


def _open_directory(root_descriptor: int, parts: tuple[str, ...]) -> int:
    descriptor = os.dup(root_descriptor)
    try:
        for part in parts:
            try:
                child = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=descriptor)
            except FileNotFoundError:
                os.mkdir(part, mode=0o700, dir_fd=descriptor)
                child = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=descriptor)
            os.close(descriptor)
            descriptor = child
        return descriptor
    except OSError:
        os.close(descriptor)
        raise


def _extract_regular(
    source: tarfile.TarFile,
    member: tarfile.TarInfo,
    root_descriptor: int,
    parts: tuple[str, ...],
) -> None:
    parent_descriptor = _open_directory(root_descriptor, parts[:-1])
    try:
        mode = 0o755 if member.mode & 0o111 else 0o644
        descriptor = os.open(
            parts[-1],
            os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW,
            mode,
            dir_fd=parent_descriptor,
        )
        with os.fdopen(descriptor, "wb") as target:
            member_stream = source.extractfile(member)
            if member_stream is None:
                raise ArchiveError("archive_read_failed", member.name)
            remaining = member.size
            while remaining:
                block = member_stream.read(min(1024 * 1024, remaining))
                if not block:
                    raise ArchiveError("archive_read_failed", member.name)
                target.write(block)
                remaining -= len(block)
            if member_stream.read(1):
                raise ArchiveError("archive_size_mismatch", member.name)
    finally:
        os.close(parent_descriptor)


def _materialize_link(
    root_descriptor: int,
    approval: ApprovedSymlink,
) -> None:
    target_parts = _relative_parts(f"root/{approval.target}", "root")
    target_parent = _open_directory(root_descriptor, target_parts[:-1])
    output_parts = _relative_parts(f"root/{approval.path}", "root")
    output_parent = _open_directory(root_descriptor, output_parts[:-1])
    try:
        target_descriptor = os.open(target_parts[-1], os.O_RDONLY | os.O_NOFOLLOW, dir_fd=target_parent)
        output_descriptor = os.open(
            output_parts[-1],
            os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW,
            0o644,
            dir_fd=output_parent,
        )
        with os.fdopen(target_descriptor, "rb") as source, os.fdopen(output_descriptor, "wb") as destination:
            shutil.copyfileobj(source, destination)
    finally:
        os.close(target_parent)
        os.close(output_parent)


def extract_archive(
    archive: Path,
    destination: Path,
    policy: ExtractionPolicy,
) -> None:
    if destination.exists() or destination.is_symlink():
        raise ArchiveError("archive_destination_exists", str(destination))
    try:
        _validate_members(archive, policy)
    except (OSError, tarfile.TarError) as error:
        raise ArchiveError("archive_read_failed", str(error)) from error
    destination.mkdir(mode=0o700)
    try:
        root_descriptor = os.open(destination, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
        try:
            with tarfile.open(archive, "r:gz") as source:
                for member in source:
                    parts = _relative_parts(member.name, policy.expected_root)
                    if not parts:
                        continue
                    if member.isdir():
                        descriptor = _open_directory(root_descriptor, parts)
                        os.close(descriptor)
                    elif member.issym():
                        continue
                    else:
                        _extract_regular(source, member, root_descriptor, parts)
            for approval in policy.approved_symlinks:
                _materialize_link(root_descriptor, approval)
        finally:
            os.close(root_descriptor)
    except (ArchiveError, OSError, tarfile.TarError):
        shutil.rmtree(destination)
        raise
