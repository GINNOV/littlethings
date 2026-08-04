#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 stage_adflib.py --connected --artifacts /absolute/cache --print-source-root

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import stat
import subprocess
import sys
import tempfile
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Final

from archive_boundary import (
    ApprovedSymlink,
    ArchiveError,
    ExtractionPolicy,
    extract_archive,
)

HEX40: Final = re.compile(r"[0-9a-f]{40}")
HEX64: Final = re.compile(r"[0-9a-f]{64}")
MANIFEST_PATTERN: Final = re.compile(r'^set\((ADFLIB_[A-Z0-9_]+) "([^"]*)"\)$')


@dataclass(frozen=True, slots=True)
class StageError(Exception):
    code: str
    detail: str

    def __str__(self) -> str:
        return f"{self.code}: {self.detail}"


@dataclass(frozen=True, slots=True)
class TreeEntry:
    mode: str
    kind: str
    sha: str
    path: str

    def row(self) -> bytes:
        return f"{self.mode}\t{self.kind}\t{self.sha}\t{self.path}\n".encode()


@dataclass(frozen=True, slots=True)
class SymlinkPolicy:
    path: str
    mode: str
    blob_sha: str
    target: str
    target_blob_sha: str


@dataclass(frozen=True, slots=True)
class RedirectContract:
    source: str
    destination: str


class NoRedirectHandler(urllib.request.HTTPRedirectHandler):
    def redirect_request(
        self,
        request: urllib.request.Request,
        file_pointer,
        code: int,
        message: str,
        headers,
        new_url: str,
    ) -> None:
        return None


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def git_object_sha(kind: str, content: bytes) -> str:
    header = f"{kind} {len(content)}\0".encode()
    return hashlib.sha1(header + content).hexdigest()


def load_manifest(path: Path) -> dict[str, str]:
    fields: dict[str, str] = {}
    with path.open(encoding="utf-8") as stream:
        for line in stream:
            match = MANIFEST_PATTERN.fullmatch(line.rstrip("\n"))
            if match is not None:
                fields[match.group(1)] = match.group(2)
    required = {
        "ADFLIB_OWNER_REPO",
        "ADFLIB_VERSION",
        "ADFLIB_TAG",
        "ADFLIB_COMMIT",
        "ADFLIB_TREE_SHA",
        "ADFLIB_ARCHIVE_URL",
        "ADFLIB_TREE_MANIFEST_SHA256",
        "ADFLIB_PATCH_SHA256",
    }
    missing = sorted(required - fields.keys())
    if missing:
        raise StageError("manifest_invalid", f"missing fields: {','.join(missing)}")
    if HEX40.fullmatch(fields["ADFLIB_COMMIT"]) is None or HEX40.fullmatch(fields["ADFLIB_TREE_SHA"]) is None:
        raise StageError("manifest_invalid", "commit and tree SHA must be lowercase 40-hex")
    if HEX64.fullmatch(fields["ADFLIB_TREE_MANIFEST_SHA256"]) is None:
        raise StageError("manifest_invalid", "tree manifest digest must be lowercase 64-hex")
    expected_url = f"https://github.com/adflib/ADFlib/archive/{fields['ADFLIB_COMMIT']}.tar.gz"
    if fields["ADFLIB_ARCHIVE_URL"] != expected_url:
        raise StageError("manifest_invalid", "archive URL is not commit-addressed canonical upstream")
    materialization_source = fields.get("ADFLIB_MATERIALIZATION_SOURCE_TREE_MANIFEST_SHA256", "")
    if materialization_source and materialization_source != fields["ADFLIB_TREE_MANIFEST_SHA256"]:
        raise StageError("source_tree_mismatch", "materialization policy is bound to a different canonical tree manifest")
    return fields


def load_symlink_policy(fields: dict[str, str], requested_tree: str) -> dict[str, SymlinkPolicy]:
    encoded = fields.get("ADFLIB_SYMLINK_ALLOWLIST", "")
    if not encoded:
        return {}
    if fields.get("ADFLIB_SYMLINK_ALLOWLIST_COMMIT") != fields["ADFLIB_COMMIT"]:
        raise StageError("symlink_policy_commit_mismatch", "allowlist is not bound to dependency commit")
    if fields.get("ADFLIB_SYMLINK_ALLOWLIST_TREE_SHA") != requested_tree:
        return {}
    policies: dict[str, SymlinkPolicy] = {}
    for record in encoded.split(";"):
        parts = record.split("|")
        if len(parts) != 5:
            raise StageError("symlink_policy_invalid", record)
        link_path, mode, blob_sha, target, target_blob_sha = parts
        link = PurePosixPath(link_path)
        target_path = PurePosixPath(target)
        if len(link.parts) != 1 or link.is_absolute() or link_path in {"", ".", ".."}:
            raise StageError("symlink_policy_path_rejected", link_path)
        if target_path.is_absolute() or ".." in target_path.parts or not target_path.parts:
            raise StageError("symlink_policy_target_rejected", target)
        if mode != "120000" or HEX40.fullmatch(blob_sha) is None or HEX40.fullmatch(target_blob_sha) is None:
            raise StageError("symlink_policy_invalid", record)
        if git_object_sha("blob", target.encode()) != blob_sha:
            raise StageError("symlink_policy_blob_target_mismatch", link_path)
        if link_path in policies:
            raise StageError("symlink_policy_duplicate", link_path)
        policies[link_path] = SymlinkPolicy(link_path, mode, blob_sha, target, target_blob_sha)
    return policies


def parse_tree_response(path: Path, requested_tree: str, policies: dict[str, SymlinkPolicy] | None = None) -> list[TreeEntry]:
    with path.open(encoding="utf-8") as stream:
        payload = json.load(stream)
    if not isinstance(payload, dict) or payload.get("sha") != requested_tree:
        raise StageError("git_tree_response_mismatch", "response sha differs from requested tree")
    if payload.get("truncated") is not False:
        raise StageError("git_tree_truncated", "recursive Git tree response is incomplete")
    raw_tree = payload.get("tree")
    if not isinstance(raw_tree, list):
        raise StageError("git_tree_invalid", "tree must be an array")
    entries: list[TreeEntry] = []
    symlink_policies = policies or {}
    for raw_entry in raw_tree:
        if not isinstance(raw_entry, dict):
            raise StageError("git_tree_invalid", "entry must be an object")
        mode = raw_entry.get("mode")
        kind = raw_entry.get("type")
        sha = raw_entry.get("sha")
        member_path = raw_entry.get("path")
        if not all(isinstance(value, str) for value in (mode, kind, sha, member_path)):
            raise StageError("git_tree_invalid", "entry fields must be strings")
        if mode == "160000" or kind == "commit":
            raise StageError("git_tree_submodule", str(member_path))
        if mode == "120000":
            policy = symlink_policies.get(str(member_path))
            if policy is None:
                raise StageError("git_tree_symlink", str(member_path))
            if policy.mode != mode or policy.blob_sha != sha:
                raise StageError("git_tree_symlink_policy_mismatch", str(member_path))
        elif (mode, kind) not in {("040000", "tree"), ("100644", "blob"), ("100755", "blob")}:
            raise StageError("git_tree_unsupported_mode", f"{mode} {kind} {member_path}")
        if HEX40.fullmatch(str(sha)) is None:
            raise StageError("git_tree_invalid", f"invalid object sha for {member_path}")
        normalized = PurePosixPath(str(member_path))
        if normalized.is_absolute() or ".." in normalized.parts or str(normalized) != member_path:
            raise StageError("git_tree_invalid_path", str(member_path))
        entries.append(TreeEntry(str(mode), str(kind), str(sha), str(member_path)))
    entry_by_path = {entry.path: entry for entry in entries}
    observed_symlinks = {entry.path for entry in entries if entry.mode == "120000"}
    if observed_symlinks != symlink_policies.keys():
        raise StageError("git_tree_symlink_policy_mismatch", "allowlist and tree symlinks differ")
    for policy in symlink_policies.values():
        visited = {policy.path}
        current = policy.target
        while current in symlink_policies:
            if current in visited:
                raise StageError("git_tree_symlink_cycle", current)
            visited.add(current)
            current = symlink_policies[current].target
        target_entry = entry_by_path.get(policy.target)
        if target_entry is None or target_entry.kind != "blob" or target_entry.mode not in {"100644", "100755"}:
            raise StageError("git_tree_symlink_target_missing", policy.target)
        if target_entry.sha != policy.target_blob_sha:
            raise StageError("git_tree_symlink_target_mismatch", policy.target)
    return entries


def verify_commit_response(path: Path, requested_commit: str, requested_tree: str) -> None:
    with path.open(encoding="utf-8") as stream:
        payload = json.load(stream)
    if not isinstance(payload, dict) or payload.get("sha") != requested_commit:
        raise StageError("git_commit_response_mismatch", "response sha differs from requested commit")
    tree = payload.get("tree")
    if not isinstance(tree, dict) or tree.get("sha") != requested_tree:
        raise StageError("git_commit_tree_mismatch", "commit does not link to requested tree")


def verify_tree_manifest_digest(entries: list[TreeEntry], expected_digest: str) -> None:
    canonical_rows = b"".join(entry.row() for entry in sorted(entries, key=lambda entry: entry.row()))
    actual_digest = hashlib.sha256(canonical_rows).hexdigest()
    if actual_digest != expected_digest:
        raise StageError("git_tree_manifest_mismatch", f"expected {expected_digest}, got {actual_digest}")


def scan_source_tree(source_root: Path, policies: dict[str, SymlinkPolicy] | None = None) -> tuple[str, list[TreeEntry]]:
    entries: list[TreeEntry] = []
    materialization_policies = policies or {}
    observed_materializations: set[str] = set()

    def scan(directory: Path, relative: PurePosixPath) -> str:
        tree_parts: list[tuple[bytes, bytes]] = []
        for child in sorted(directory.iterdir(), key=lambda item: item.name.encode() + (b"/" if item.is_dir() else b"")):
            child_relative = relative / child.name
            child_stat = child.lstat()
            if stat.S_ISLNK(child_stat.st_mode):
                raise StageError("source_tree_symlink", str(child_relative))
            if stat.S_ISDIR(child_stat.st_mode):
                child_sha = scan(child, child_relative)
                entries.append(TreeEntry("040000", "tree", child_sha, str(child_relative)))
                tree_parts.append((f"40000 {child.name}\0".encode(), bytes.fromhex(child_sha)))
                continue
            if not stat.S_ISREG(child_stat.st_mode):
                raise StageError("source_tree_unsupported_type", str(child_relative))
            content = child.read_bytes()
            policy = materialization_policies.get(str(child_relative))
            if policy is not None:
                target = source_root.joinpath(*PurePosixPath(policy.target).parts)
                if not target.is_file() or target.is_symlink() or content != target.read_bytes():
                    raise StageError("source_tree_symlink_materialization_mismatch", str(child_relative))
                if git_object_sha("blob", content) != policy.target_blob_sha:
                    raise StageError("source_tree_symlink_target_mismatch", policy.target)
                child_sha = policy.blob_sha
                mode = policy.mode
                observed_materializations.add(str(child_relative))
            else:
                child_sha = git_object_sha("blob", content)
                mode = "100755" if child_stat.st_mode & 0o111 else "100644"
            entries.append(TreeEntry(mode, "blob", child_sha, str(child_relative)))
            tree_parts.append((f"{mode} {child.name}\0".encode(), bytes.fromhex(child_sha)))
        content = b"".join(prefix + digest for prefix, digest in tree_parts)
        return git_object_sha("tree", content)

    root_sha = scan(source_root, PurePosixPath())
    if observed_materializations != materialization_policies.keys():
        raise StageError("source_tree_symlink_materialization_mismatch", "allowlist and source differ")
    return root_sha, sorted(entries, key=lambda entry: entry.path.encode())


def verify_source(
    source_root: Path,
    expected_tree: str,
    expected_manifest_digest: str,
    policies: dict[str, SymlinkPolicy] | None = None,
) -> list[TreeEntry]:
    root_sha, entries = scan_source_tree(source_root, policies)
    if root_sha != expected_tree:
        raise StageError("source_tree_mismatch", f"expected {expected_tree}, got {root_sha}")
    manifest_bytes = b"".join(sorted(entry.row() for entry in entries))
    actual_digest = hashlib.sha256(manifest_bytes).hexdigest()
    if actual_digest != expected_manifest_digest:
        raise StageError("source_tree_mismatch", f"manifest expected {expected_manifest_digest}, got {actual_digest}")
    return entries


def verify_materialized_source(source_root: Path, api_entries: list[TreeEntry], policies: dict[str, SymlinkPolicy]) -> list[TreeEntry]:
    _, local_entries = scan_source_tree(source_root, policies)
    if local_entries != sorted(api_entries, key=lambda entry: entry.path.encode()):
        raise StageError("source_tree_mismatch", "materialized source differs from reviewed Git tree")
    return local_entries


def safe_extract(archive: Path, destination: Path, commit: str, policies: dict[str, SymlinkPolicy]) -> None:
    approved = tuple(ApprovedSymlink(policy.path, policy.target) for policy in policies.values())
    if destination.is_dir() and not any(destination.iterdir()):
        destination.rmdir()
    try:
        extract_archive(archive, destination, ExtractionPolicy(f"ADFlib-{commit}", approved_symlinks=approved))
    except ArchiveError as error:
        legacy_code = {
            "archive_absolute_path": "archive_invalid_path",
            "archive_empty_path": "archive_invalid_path",
            "archive_nul_path": "archive_invalid_path",
            "archive_parent_path": "archive_invalid_path",
            "archive_link_policy_mismatch": "archive_symlink_policy_mismatch",
            "archive_link_rejected": "archive_symlink_policy_mismatch",
        }.get(error.code, error.code)
        raise StageError(legacy_code, error.detail) from error
    for policy in policies.values():
        target = destination.joinpath(*PurePosixPath(policy.target).parts)
        if not target.is_file() or target.is_symlink():
            raise StageError("archive_symlink_target_missing", policy.target)
        if git_object_sha("blob", target.read_bytes()) != policy.target_blob_sha:
            raise StageError("archive_symlink_target_mismatch", policy.target)


def download(url: str, destination: Path, redirect: RedirectContract | None = None) -> str:
    opener = urllib.request.build_opener(NoRedirectHandler())

    def request_once(request_url: str):
        request = urllib.request.Request(request_url, headers={"User-Agent": "littlethings-adflib-stager/1"})
        return opener.open(request, timeout=60)

    try:
        redirect_observed = False
        try:
            response = request_once(url)
        except urllib.error.HTTPError as error:
            if error.code not in {301, 302, 303, 307, 308}:
                raise
            location = error.headers.get("Location", "")
            error.close()
            if redirect is None:
                raise StageError("api_redirect_rejected", location) from None
            if url != redirect.source or location != redirect.destination:
                raise StageError("archive_redirect_rejected", f"{url} -> {location}") from None
            redirect_observed = True
            try:
                response = request_once(location)
            except urllib.error.HTTPError as second_error:
                second_error.close()
                raise StageError("archive_redirect_chain_rejected", location) from None
        with response:
            if redirect is not None and not redirect_observed:
                raise StageError("archive_redirect_missing", url)
            if redirect is not None and response.geturl() not in {redirect.source, redirect.destination}:
                raise StageError("archive_redirect_rejected", response.geturl())
            with destination.open("xb") as output:
                shutil.copyfileobj(response, output)
                return response.geturl()
    except (urllib.error.URLError, FileExistsError) as error:
        raise StageError("transport_failed", str(error)) from error


def write_deterministic_archive(source_root: Path, destination: Path) -> str:
    tar_bytes = bytearray()
    for path in sorted(source_root.rglob("*"), key=lambda item: item.relative_to(source_root).as_posix().encode()):
        relative = path.relative_to(source_root).as_posix()
        if path.is_symlink():
            raise StageError("canonical_archive_unsupported_type", relative)
        if path.is_dir():
            tar_bytes.extend(canonical_tar_header(relative, 0, 0o755, b"5"))
            continue
        if not path.is_file():
            raise StageError("canonical_archive_unsupported_type", relative)
        content = path.read_bytes()
        mode = 0o755 if path.stat().st_mode & 0o111 else 0o644
        tar_bytes.extend(canonical_tar_header(relative, len(content), mode, b"0"))
        tar_bytes.extend(content)
        tar_bytes.extend(bytes((-len(content)) % 512))
    tar_bytes.extend(bytes(1024))
    destination.write_bytes(canonical_gzip(bytes(tar_bytes)))
    return sha256_file(destination)


def canonical_tar_number(value: int, width: int) -> bytes:
    encoded = f"{value:0{width - 1}o}\0".encode("ascii")
    if len(encoded) != width:
        raise StageError("canonical_archive_field_overflow", str(value))
    return encoded


def canonical_tar_header(name: str, size: int, mode: int, kind: bytes) -> bytes:
    encoded_name = name.encode("utf-8")
    if len(encoded_name) > 100 or len(kind) != 1:
        raise StageError("canonical_archive_path_rejected", name)
    header = bytearray(512)
    header[0 : len(encoded_name)] = encoded_name
    header[100:108] = canonical_tar_number(mode, 8)
    header[108:116] = canonical_tar_number(0, 8)
    header[116:124] = canonical_tar_number(0, 8)
    header[124:136] = canonical_tar_number(size, 12)
    header[136:148] = canonical_tar_number(0, 12)
    header[148:156] = b"        "
    header[156:157] = kind
    header[257:263] = b"ustar\0"
    header[263:265] = b"00"
    header[329:337] = canonical_tar_number(0, 8)
    header[337:345] = canonical_tar_number(0, 8)
    checksum = f"{sum(header):06o}\0 ".encode("ascii")
    if len(checksum) != 8:
        raise StageError("canonical_archive_checksum_overflow", name)
    header[148:156] = checksum
    return bytes(header)


def canonical_crc32(content: bytes) -> int:
    table: list[int] = []
    for value in range(256):
        current = value
        for _ in range(8):
            current = (current >> 1) ^ (0xEDB88320 if current & 1 else 0)
        table.append(current)
    result = 0xFFFFFFFF
    for value in content:
        result = table[(result ^ value) & 0xFF] ^ (result >> 8)
    return result ^ 0xFFFFFFFF


def canonical_gzip(content: bytes) -> bytes:
    output = bytearray(bytes.fromhex("1f8b08000000000002ff"))
    offset = 0
    while offset < len(content):
        block = content[offset : offset + 65535]
        offset += len(block)
        output.append(1 if offset == len(content) else 0)
        output.extend(len(block).to_bytes(2, "little"))
        output.extend((len(block) ^ 0xFFFF).to_bytes(2, "little"))
        output.extend(block)
    if not content:
        output.extend(b"\x01\x00\x00\xff\xff")
    output.extend(canonical_crc32(content).to_bytes(4, "little"))
    output.extend((len(content) & 0xFFFFFFFF).to_bytes(4, "little"))
    return bytes(output)


def apply_patch(source_root: Path, patch_path: Path, expected_digest: str) -> None:
    if sha256_file(patch_path) != expected_digest:
        raise StageError("patch_hash_mismatch", str(patch_path))
    git_environment = os.environ.copy()
    git_environment["GIT_CEILING_DIRECTORIES"] = str(source_root.parent.resolve())
    check = subprocess.run(["git", "apply", "--check", str(patch_path)], cwd=source_root, env=git_environment, check=False, capture_output=True, text=True)
    if check.returncode != 0:
        raise StageError("patch_check_failed", check.stderr.strip())
    applied = subprocess.run(["git", "apply", str(patch_path)], cwd=source_root, env=git_environment, check=False, capture_output=True, text=True)
    if applied.returncode != 0:
        raise StageError("patch_apply_failed", applied.stderr.strip())
    cmake_text = (source_root / "CMakeLists.txt").read_text(encoding="utf-8")
    if cmake_text.count("option ( ADFLIB_ENABLE_EXAMPLES") != 1:
        raise StageError("patch_hunk_mismatch", "example option not applied exactly once")


def canonical_identity(fields: dict[str, str]) -> bytes:
    channel = fields.get("ADFLIB_CHANNEL", "stable")
    if channel not in {"stable", "canary"}:
        raise StageError("identity_channel_invalid", channel)
    if channel == "canary" and (fields["ADFLIB_VERSION"], fields["ADFLIB_TAG"]) != ("0.0.0-canary", "master"):
        raise StageError("canary_identity_marker_invalid", fields["ADFLIB_VERSION"])
    identity = {
        "channel": channel,
        "owner_repo": fields["ADFLIB_OWNER_REPO"],
        "version": fields["ADFLIB_VERSION"],
        "tag": fields["ADFLIB_TAG"],
        "commit": fields["ADFLIB_COMMIT"],
        "tree_sha": fields["ADFLIB_TREE_SHA"],
        "url": fields["ADFLIB_ARCHIVE_URL"],
        "tree_manifest_sha256": fields["ADFLIB_TREE_MANIFEST_SHA256"],
    }
    return (json.dumps(identity, separators=(",", ":"), ensure_ascii=True) + "\n").encode()


def connected_source(fields: dict[str, str], artifacts: Path) -> tuple[Path, dict[str, str]]:
    artifacts.mkdir(parents=True, exist_ok=True)
    pristine = artifacts / f"ADFlib-{fields['ADFLIB_COMMIT']}-pristine"
    archive = artifacts / f"ADFlib-{fields['ADFLIB_COMMIT']}-transport.tar.gz"
    commit_response = artifacts / f"ADFlib-{fields['ADFLIB_COMMIT']}-commit.json"
    tree_response = artifacts / f"ADFlib-{fields['ADFLIB_TREE_SHA']}-tree.json"
    transport_record = artifacts / "adflib-transport.json"
    expected_archive_redirect = f"https://codeload.github.com/adflib/ADFlib/tar.gz/{fields['ADFLIB_COMMIT']}"
    cached_evidence: dict[str, str] | None = None
    if not archive.exists():
        source_url = urllib.parse.urlsplit(fields["ADFLIB_ARCHIVE_URL"])
        destination_url = urllib.parse.urlsplit(expected_archive_redirect)
        if (
            source_url.scheme != "https"
            or source_url.hostname != "github.com"
            or source_url.port is not None
            or source_url.username is not None
            or source_url.password is not None
            or destination_url.scheme != "https"
            or destination_url.hostname != "codeload.github.com"
            or destination_url.port is not None
            or destination_url.username is not None
            or destination_url.password is not None
        ):
            raise StageError("archive_redirect_contract_invalid", fields["ADFLIB_ARCHIVE_URL"])
        final_url = download(
            fields["ADFLIB_ARCHIVE_URL"],
            archive,
            RedirectContract(fields["ADFLIB_ARCHIVE_URL"], expected_archive_redirect),
        )
    else:
        if not transport_record.is_file():
            raise StageError("transport_evidence_missing", str(transport_record))
        raw_evidence = json.loads(transport_record.read_text(encoding="utf-8"))
        if not isinstance(raw_evidence, dict) or set(raw_evidence) != {"transport_url", "transport_sha256", "local_cache_sha256"}:
            raise StageError("transport_evidence_invalid", str(transport_record))
        if not all(isinstance(value, str) for value in raw_evidence.values()):
            raise StageError("transport_evidence_invalid", str(transport_record))
        cached_evidence = raw_evidence
        final_url = cached_evidence["transport_url"]
        if final_url != expected_archive_redirect:
            raise StageError("transport_evidence_mismatch", final_url)
    expected_transport = fields.get("ADFLIB_EXPECTED_TRANSPORT_SHA256", "")
    if expected_transport and sha256_file(archive) != expected_transport:
        raise StageError("transport_hash_mismatch", "downloaded archive differs from captured canary evidence")
    if not commit_response.exists():
        commit_url = f"https://api.github.com/repos/adflib/ADFlib/git/commits/{fields['ADFLIB_COMMIT']}"
        download(commit_url, commit_response)
    verify_commit_response(commit_response, fields["ADFLIB_COMMIT"], fields["ADFLIB_TREE_SHA"])
    if not tree_response.exists():
        tree_url = f"https://api.github.com/repos/adflib/ADFlib/git/trees/{fields['ADFLIB_TREE_SHA']}?recursive=1"
        download(tree_url, tree_response)
    policies = load_symlink_policy(fields, fields["ADFLIB_TREE_SHA"])
    api_entries = parse_tree_response(tree_response, fields["ADFLIB_TREE_SHA"], policies)
    verify_tree_manifest_digest(api_entries, fields["ADFLIB_TREE_MANIFEST_SHA256"])
    if pristine.exists():
        verify_materialized_source(pristine, api_entries, policies)
    else:
        temporary = Path(tempfile.mkdtemp(prefix="adflib-extract-", dir=artifacts))
        try:
            safe_extract(archive, temporary, fields["ADFLIB_COMMIT"], policies)
            verify_materialized_source(temporary, api_entries, policies)
            temporary.replace(pristine)
        except StageError:
            if temporary.exists():
                shutil.rmtree(temporary)
            raise
    local_archive = artifacts / f"ADFlib-{fields['ADFLIB_COMMIT']}-verified.tar.gz"
    cache_digest = write_deterministic_archive(pristine, local_archive)
    expected_stable_transport = fields.get("ADFLIB_TRANSPORT_SHA256", "")
    if expected_stable_transport and sha256_file(archive) != expected_stable_transport:
        raise StageError("transport_hash_mismatch", "stable transport evidence changed")
    expected_cache = fields.get("ADFLIB_LOCAL_CACHE_SHA256", "")
    if expected_cache and cache_digest != expected_cache:
        raise StageError("local_cache_hash_mismatch", cache_digest)
    evidence = {
        "transport_url": final_url,
        "transport_sha256": sha256_file(archive),
        "local_cache_sha256": cache_digest,
    }
    (artifacts / "adflib-identity.json").write_bytes(canonical_identity(fields))
    if cached_evidence is None:
        transport_record.write_text(json.dumps(evidence, separators=(",", ":")) + "\n", encoding="utf-8")
    elif evidence != cached_evidence:
        raise StageError("transport_evidence_mismatch", str(transport_record))
    return pristine, evidence


def run(arguments: argparse.Namespace) -> int:
    fields = load_manifest(arguments.manifest)
    if arguments.verify_commit_response is not None:
        verify_commit_response(arguments.verify_commit_response, arguments.requested_commit, arguments.requested_tree)
        print("commit_tree_verified")
        return 0
    if arguments.verify_tree_response is not None:
        policies = load_symlink_policy(fields, arguments.requested_tree)
        entries = parse_tree_response(arguments.verify_tree_response, arguments.requested_tree, policies)
        verify_tree_manifest_digest(entries, fields["ADFLIB_TREE_MANIFEST_SHA256"])
        if policies:
            verify_materialized_source(arguments.source_root, entries, policies)
        else:
            root_sha, local_entries = scan_source_tree(arguments.source_root)
            if entries != local_entries or root_sha != arguments.requested_tree:
                raise StageError("source_tree_mismatch", "fixture source does not match response")
        print("source_tree_verified")
        return 0
    if arguments.connected:
        pristine, _ = connected_source(fields, arguments.artifacts)
    else:
        if arguments.source_root is None:
            raise StageError("offline_source_required", "provide --source-root")
        pristine = arguments.source_root
        policies = load_symlink_policy(fields, fields["ADFLIB_TREE_SHA"])
        verify_source(pristine, fields["ADFLIB_TREE_SHA"], fields["ADFLIB_TREE_MANIFEST_SHA256"], policies)
    selected = pristine
    if arguments.stage is not None:
        if arguments.stage.exists():
            raise StageError("stage_exists", str(arguments.stage))
        shutil.copytree(pristine, arguments.stage, symlinks=True)
        apply_patch(arguments.stage, arguments.patch, fields["ADFLIB_PATCH_SHA256"])
        selected = arguments.stage
    if arguments.print_source_root:
        print(selected.resolve())
    return 0


def parser() -> argparse.ArgumentParser:
    script_root = Path(__file__).resolve().parent
    result = argparse.ArgumentParser()
    result.add_argument("--manifest", type=Path, default=script_root / "ADFlibDependency.cmake")
    result.add_argument("--patch", type=Path, default=script_root / "patches/0001-cmake-disable-examples.patch")
    result.add_argument("--connected", action="store_true")
    result.add_argument("--artifacts", type=Path)
    result.add_argument("--source-root", type=Path)
    result.add_argument("--stage", type=Path)
    result.add_argument("--print-source-root", action="store_true")
    result.add_argument("--verify-tree-response", type=Path)
    result.add_argument("--verify-commit-response", type=Path)
    result.add_argument("--requested-commit", default="")
    result.add_argument("--requested-tree", default="")
    return result


def main() -> int:
    try:
        arguments = parser().parse_args()
        if arguments.connected and arguments.artifacts is None:
            raise StageError("artifacts_required", "--connected requires --artifacts")
        return run(arguments)
    except (StageError, OSError, json.JSONDecodeError) as error:
        print(error, file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
