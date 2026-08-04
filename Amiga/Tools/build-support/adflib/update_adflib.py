#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 update_adflib.py --check

from __future__ import annotations

import argparse
import hashlib
import json
import os
import tempfile
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Final

from approval_boundary import (
    ApprovalError,
    ApprovalRequest,
    IdentityApprovalInput,
    approval_allows,
)
from archive_boundary import (
    ApprovedSymlink,
    ArchiveError,
    ExtractionPolicy,
    extract_archive,
)
from license_inventory import InventoryError, LicenseInventory, build_inventory
from release_resolver import (
    ReleaseCandidate,
    ResolverError,
    parse_version,
    resolve_release,
)
from stage_adflib import (
    RedirectContract,
    StageError,
    download,
    load_manifest,
    load_symlink_policy,
    sha256_file,
    verify_source,
)

FIELD_MAP: Final = {
    "ADFLIB_VERSION": "version_text",
    "ADFLIB_TAG": "tag",
    "ADFLIB_COMMIT": "commit",
    "ADFLIB_TREE_SHA": "tree_sha",
    "ADFLIB_ARCHIVE_URL": "url",
    "ADFLIB_TREE_MANIFEST_SHA256": "tree_manifest_sha256",
}


@dataclass(frozen=True, slots=True)
class UpdateError(Exception):
    code: str
    detail: str

    def __str__(self) -> str:
        return f"{self.code}: {self.detail}"


@dataclass(frozen=True, slots=True)
class RuntimePaths:
    manifest: Path
    ledger: Path
    receipt: Path | None
    evidence: Path
    repository_root: Path
    packaging_dependencies: tuple[Path, ...]


def _identity(fields: dict[str, str]) -> dict[str, str]:
    return {
        "version": fields["ADFLIB_VERSION"],
        "tag": fields["ADFLIB_TAG"],
        "commit": fields["ADFLIB_COMMIT"],
        "tree_sha": fields["ADFLIB_TREE_SHA"],
        "url": fields["ADFLIB_ARCHIVE_URL"],
        "tree_manifest_sha256": fields["ADFLIB_TREE_MANIFEST_SHA256"],
    }


def _candidate_identity(candidate: ReleaseCandidate) -> dict[str, str]:
    return {
        "version": candidate.version_text,
        "tag": candidate.tag,
        "commit": candidate.commit,
        "tree_sha": candidate.tree_sha,
        "url": candidate.url,
        "tree_manifest_sha256": candidate.tree_manifest_sha256,
    }


def _emit(status: str, changed: bool, old: dict[str, str], new: dict[str, str], **extra) -> None:
    payload = {"status": status, "changed": changed, "old": old, "new": new, **extra}
    print(json.dumps(payload, sort_keys=True, separators=(",", ":")))


def _archive_url(commit: str) -> str:
    return f"https://github.com/adflib/ADFlib/archive/{commit}.tar.gz"


def _download_archive(commit: str, destination: Path, archive_base: str | None) -> str:
    logical = _archive_url(commit)
    if archive_base is not None:
        actual = f"{archive_base.rstrip('/')}/adflib/ADFlib/archive/{commit}.tar.gz"
        download(actual, destination)
        return logical
    redirect = f"https://codeload.github.com/adflib/ADFlib/tar.gz/{commit}"
    download(logical, destination, RedirectContract(logical, redirect))
    return logical


def _extract_inventory(
    commit: str,
    archive: Path,
    temporary_root: Path,
    fields: dict[str, str],
    tree_sha: str,
    tree_manifest: str,
) -> LicenseInventory:
    policies = load_symlink_policy(fields, fields["ADFLIB_TREE_SHA"])
    approved = tuple(ApprovedSymlink(policy.path, policy.target) for policy in policies.values())
    extracted = temporary_root / f"source-{commit}"
    extract_archive(archive, extracted, ExtractionPolicy(f"ADFlib-{commit}", approved_symlinks=approved))
    verify_source(extracted, tree_sha, tree_manifest, policies)
    return build_inventory(extracted)


def _corresponding_source_digest(
    paths: RuntimePaths,
    candidate: ReleaseCandidate,
    archive_sha256: str,
) -> tuple[str, dict[str, str]]:
    support_root = paths.manifest.parent
    inventory: dict[str, str] = {
        "pristine_adflib_archive_sha256": archive_sha256,
        "pristine_adflib_tree_manifest_sha256": candidate.tree_manifest_sha256,
    }
    for helper in sorted(support_root.rglob("*")):
        if not helper.is_file() or helper.is_symlink() or "tests" in helper.relative_to(support_root).parts or "__pycache__" in helper.parts:
            continue
        if helper == paths.manifest or helper == paths.ledger or helper.suffix == ".json":
            continue
        relative = helper.relative_to(paths.repository_root).as_posix()
        inventory[f"helper:{relative}"] = sha256_file(helper)
    for dependency in paths.packaging_dependencies:
        resolved = dependency.resolve(strict=True)
        if not resolved.is_file() or resolved.is_symlink():
            raise UpdateError("packaging_dependency_invalid", str(dependency))
        relative = resolved.relative_to(paths.repository_root.resolve()).as_posix()
        inventory[f"packaging_dependency:{relative}"] = sha256_file(resolved)
    encoded = json.dumps(inventory, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(encoded).hexdigest(), inventory


def _review_report(
    paths: RuntimePaths,
    candidate: ReleaseCandidate,
    inventory: LicenseInventory,
    corresponding: dict[str, str],
) -> Path:
    paths.evidence.mkdir(parents=True, exist_ok=True)
    report = paths.evidence / f"adflib-license-review-{candidate.commit}.json"
    payload = {
        "status": "license_review_required",
        "candidate_commit": candidate.commit,
        "license_inventory_sha256": inventory.digest,
        "ambiguous_paths": inventory.ambiguous_paths,
        "records": [asdict(record) for record in inventory.records],
        "classifications": [asdict(classification) for classification in inventory.classifications],
        "corresponding_source": corresponding,
    }
    report.write_text(json.dumps(payload, sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8")
    return report


def _replace_manifest(path: Path, candidate: ReleaseCandidate) -> None:
    original = path.read_text(encoding="utf-8")
    updated = original
    for field, attribute in FIELD_MAP.items():
        old_prefix = f"set({field} \""
        matching = [line for line in updated.splitlines() if line.startswith(old_prefix)]
        if len(matching) != 1:
            raise UpdateError("manifest_update_invalid", field)
        replacement = f'set({field} "{getattr(candidate, attribute)}")'
        updated = updated.replace(matching[0], replacement, 1)
    mode = path.stat().st_mode
    descriptor, temporary_name = tempfile.mkstemp(prefix=".adflib-manifest-", dir=path.parent)
    temporary = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
            stream.write(updated)
        os.chmod(temporary, mode)
        os.replace(temporary, path)
    finally:
        if temporary.exists():
            temporary.unlink()


def _approval_request(
    fields: dict[str, str],
    current_inventory: LicenseInventory,
    candidate: ReleaseCandidate,
    candidate_inventory: LicenseInventory,
    corresponding_digest: str,
) -> ApprovalRequest:
    current = IdentityApprovalInput(
        fields["ADFLIB_VERSION"],
        fields["ADFLIB_TAG"],
        fields["ADFLIB_COMMIT"],
        fields["ADFLIB_TREE_SHA"],
        fields["ADFLIB_TREE_MANIFEST_SHA256"],
    )
    return ApprovalRequest(current, current_inventory.digest, candidate.commit, candidate_inventory.digest, corresponding_digest)


def run(arguments: argparse.Namespace) -> int:
    paths = RuntimePaths(arguments.manifest, arguments.ledger, arguments.approval_receipt, arguments.evidence_dir, arguments.repository_root, tuple(arguments.packaging_dependency))
    fields = load_manifest(paths.manifest)
    old = _identity(fields)
    candidate = resolve_release(arguments.api_base)
    if candidate is None:
        _emit("no_stable_candidate", False, old, old)
        return 0
    current_version = parse_version(fields["ADFLIB_TAG"])
    if fields["ADFLIB_VERSION"] != f"{current_version.major}.{current_version.minor}.{current_version.patch}":
        raise UpdateError("manifest_version_tag_mismatch", fields["ADFLIB_TAG"])
    new = _candidate_identity(candidate)
    if candidate.version < current_version:
        raise UpdateError("release_downgrade", candidate.version_text)
    if candidate.version == current_version:
        if new != old:
            raise UpdateError("release_retagged", candidate.tag)
        _emit("current", False, old, old)
        return 0
    with tempfile.TemporaryDirectory(prefix="adflib-update-") as temporary_directory:
        temporary_root = Path(temporary_directory)
        current_archive = temporary_root / "current.tar.gz"
        candidate_archive = temporary_root / "candidate.tar.gz"
        _download_archive(fields["ADFLIB_COMMIT"], current_archive, arguments.archive_base)
        _download_archive(candidate.commit, candidate_archive, arguments.archive_base)
        current_inventory = _extract_inventory(fields["ADFLIB_COMMIT"], current_archive, temporary_root, fields, fields["ADFLIB_TREE_SHA"], fields["ADFLIB_TREE_MANIFEST_SHA256"])
        candidate_inventory = _extract_inventory(candidate.commit, candidate_archive, temporary_root, fields, candidate.tree_sha, candidate.tree_manifest_sha256)
        archive_sha256 = sha256_file(candidate_archive)
        corresponding_digest, corresponding = _corresponding_source_digest(paths, candidate, archive_sha256)
        request = _approval_request(fields, current_inventory, candidate, candidate_inventory, corresponding_digest)
        if not approval_allows(paths.ledger, paths.receipt, request):
            report = _review_report(paths, candidate, candidate_inventory, corresponding)
            _emit("license_review_required", False, old, new, report=str(report), archive_sha256=archive_sha256)
            return 3
    if arguments.check:
        _emit("update_available", True, old, new, archive_sha256=archive_sha256)
        return 1
    if not arguments.dry_run:
        _replace_manifest(paths.manifest, candidate)
    _emit("dry_run" if arguments.dry_run else "updated", True, old, new, archive_sha256=archive_sha256)
    return 0


def parser() -> argparse.ArgumentParser:
    root = Path(__file__).resolve().parent
    result = argparse.ArgumentParser()
    modes = result.add_mutually_exclusive_group()
    modes.add_argument("--check", action="store_true")
    modes.add_argument("--dry-run", action="store_true")
    result.add_argument("--manifest", type=Path, default=root / "ADFlibDependency.cmake")
    result.add_argument("--ledger", type=Path, default=root / "ADFlibLicenseApprovals.json")
    result.add_argument("--approval-receipt", type=Path)
    result.add_argument("--evidence-dir", type=Path, default=Path(".omo/evidence"))
    result.add_argument("--repository-root", type=Path, default=root.parents[3])
    result.add_argument("--api-base", default="https://api.github.com")
    result.add_argument("--archive-base")
    result.add_argument("--packaging-dependency", action="append", type=Path, default=[])
    return result


def main() -> int:
    try:
        return run(parser().parse_args())
    except (ApprovalError, ArchiveError, InventoryError, ResolverError, StageError, UpdateError, OSError, json.JSONDecodeError) as error:
        print(json.dumps({"status": "error", "changed": False, "code": getattr(error, "code", "io_error"), "detail": str(error)}, sort_keys=True, separators=(",", ":")))
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
