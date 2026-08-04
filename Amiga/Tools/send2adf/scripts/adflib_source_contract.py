from __future__ import annotations

import hashlib
import json
import re
import stat
import tarfile
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Final

if __package__:
    from .build_material_closure import canonical_build_materials
else:
    from build_material_closure import canonical_build_materials

MANIFEST_PATTERN: Final = re.compile(r'^set\((ADFLIB_[A-Z0-9_]+) "([^"]*)"\)$')
HEX40: Final = re.compile(r"[0-9a-f]{40}")
HEX64: Final = re.compile(r"[0-9a-f]{64}")
REGULARIZATION_RELATIVE: Final = "Tools/build-support/adflib/regularization/reviewed-symlinks.json"


@dataclass(frozen=True, slots=True)
class AdflibSourceError(Exception):
    message: str

    def __str__(self) -> str:
        return self.message


@dataclass(frozen=True, slots=True)
class SymlinkPolicy:
    path: str
    symlink_blob_sha: str
    target: str
    target_blob_sha: str


@dataclass(frozen=True, slots=True)
class AdflibIdentity:
    commit: str
    tree_sha: str
    manifest_sha256: str
    materialized_tree_sha: str
    materialized_manifest_sha256: str
    policies: tuple[SymlinkPolicy, ...]


@dataclass(frozen=True, slots=True)
class TreeEntry:
    mode: str
    kind: str
    sha: str
    path: str

    def row(self) -> bytes:
        return f"{self.mode}\t{self.kind}\t{self.sha}\t{self.path}\n".encode()


@dataclass(frozen=True, slots=True)
class TransportContract:
    archive: Path
    source_root: Path
    identity: AdflibIdentity
    sha256: str


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def git_object_sha(kind: str, content: bytes) -> str:
    return hashlib.sha1(f"{kind} {len(content)}\0".encode() + content).hexdigest()


def load_identity(manifest: Path) -> AdflibIdentity:
    fields: dict[str, str] = {}
    for line in manifest.read_text(encoding="utf-8").splitlines():
        match = MANIFEST_PATTERN.fullmatch(line)
        if match is not None:
            fields[match.group(1)] = match.group(2)
    names = (
        "ADFLIB_COMMIT",
        "ADFLIB_TREE_SHA",
        "ADFLIB_TREE_MANIFEST_SHA256",
        "ADFLIB_MATERIALIZED_TREE_SHA",
        "ADFLIB_MATERIALIZED_TREE_MANIFEST_SHA256",
        "ADFLIB_SYMLINK_ALLOWLIST_COMMIT",
        "ADFLIB_SYMLINK_ALLOWLIST_TREE_SHA",
        "ADFLIB_SYMLINK_ALLOWLIST",
    )
    if any(name not in fields for name in names):
        raise AdflibSourceError("packaged ADFlib manifest is incomplete")
    if HEX40.fullmatch(fields["ADFLIB_COMMIT"]) is None or HEX40.fullmatch(fields["ADFLIB_TREE_SHA"]) is None:
        raise AdflibSourceError("packaged ADFlib manifest identity is invalid")
    if HEX64.fullmatch(fields["ADFLIB_TREE_MANIFEST_SHA256"]) is None:
        raise AdflibSourceError("packaged ADFlib manifest identity is invalid")
    if HEX40.fullmatch(fields["ADFLIB_MATERIALIZED_TREE_SHA"]) is None:
        raise AdflibSourceError("packaged ADFlib manifest identity is invalid")
    if HEX64.fullmatch(fields["ADFLIB_MATERIALIZED_TREE_MANIFEST_SHA256"]) is None:
        raise AdflibSourceError("packaged ADFlib manifest identity is invalid")
    policies: list[SymlinkPolicy] = []
    for encoded in fields["ADFLIB_SYMLINK_ALLOWLIST"].split(";"):
        parts = encoded.split("|")
        if len(parts) != 5 or parts[1] != "120000" or HEX40.fullmatch(parts[2]) is None or HEX40.fullmatch(parts[4]) is None:
            raise AdflibSourceError("packaged ADFlib symlink policy is invalid")
        policies.append(SymlinkPolicy(parts[0], parts[2], parts[3], parts[4]))
    if fields["ADFLIB_SYMLINK_ALLOWLIST_COMMIT"] != fields["ADFLIB_COMMIT"]:
        raise AdflibSourceError("packaged ADFlib symlink policy identity mismatch")
    if fields["ADFLIB_SYMLINK_ALLOWLIST_TREE_SHA"] != fields["ADFLIB_TREE_SHA"]:
        raise AdflibSourceError("packaged ADFlib symlink policy identity mismatch")
    return AdflibIdentity(
        fields["ADFLIB_COMMIT"],
        fields["ADFLIB_TREE_SHA"],
        fields["ADFLIB_TREE_MANIFEST_SHA256"],
        fields["ADFLIB_MATERIALIZED_TREE_SHA"],
        fields["ADFLIB_MATERIALIZED_TREE_MANIFEST_SHA256"],
        tuple(policies),
    )


def scan_tree(source_root: Path, identity: AdflibIdentity, upstream: bool) -> tuple[str, list[TreeEntry]]:
    entries: list[TreeEntry] = []
    policies = {policy.path: policy for policy in identity.policies}
    seen_policies: set[str] = set()

    def scan(directory: Path, relative: PurePosixPath) -> str:
        tree_parts: list[bytes] = []
        children = sorted(directory.iterdir(), key=lambda child: child.name.encode() + (b"/" if child.is_dir() else b""))
        for child in children:
            child_relative = relative / child.name
            relative_text = child_relative.as_posix()
            child_stat = child.lstat()
            if stat.S_ISLNK(child_stat.st_mode):
                raise AdflibSourceError(f"ADFlib source contains symlink: {relative_text}")
            if stat.S_ISDIR(child_stat.st_mode):
                child_sha = scan(child, child_relative)
                entries.append(TreeEntry("040000", "tree", child_sha, relative_text))
                tree_parts.append(f"40000 {child.name}\0".encode() + bytes.fromhex(child_sha))
                continue
            if not stat.S_ISREG(child_stat.st_mode):
                raise AdflibSourceError(f"ADFlib source contains unsupported type: {relative_text}")
            content = child.read_bytes()
            mode = "100755" if child_stat.st_mode & 0o111 else "100644"
            child_sha = git_object_sha("blob", content)
            policy = policies.get(relative_text)
            if policy is not None:
                target = source_root / policy.target
                if stat.S_IMODE(child_stat.st_mode) != 0o644 or content != target.read_bytes() or child_sha != policy.target_blob_sha:
                    raise AdflibSourceError(f"ADFlib symlink regularization mismatch: {relative_text}")
                if git_object_sha("blob", policy.target.encode()) != policy.symlink_blob_sha:
                    raise AdflibSourceError(f"ADFlib symlink policy mismatch: {relative_text}")
                seen_policies.add(relative_text)
                if upstream:
                    mode, child_sha = "120000", policy.symlink_blob_sha
            entries.append(TreeEntry(mode, "blob", child_sha, relative_text))
            tree_parts.append(f"{mode} {child.name}\0".encode() + bytes.fromhex(child_sha))
        return git_object_sha("tree", b"".join(tree_parts))

    root_sha = scan(source_root, PurePosixPath())
    if seen_policies != policies.keys():
        raise AdflibSourceError("ADFlib source tree identity mismatch")
    return root_sha, entries


def manifest_sha256(entries: list[TreeEntry]) -> str:
    return hashlib.sha256(b"".join(sorted(entry.row() for entry in entries))).hexdigest()


def validate_tree(source_root: Path, identity: AdflibIdentity) -> None:
    upstream_tree, upstream_entries = scan_tree(source_root, identity, True)
    materialized_tree, materialized_entries = scan_tree(source_root, identity, False)
    if upstream_tree != identity.tree_sha or manifest_sha256(upstream_entries) != identity.manifest_sha256:
        raise AdflibSourceError("ADFlib source tree identity mismatch")
    if materialized_tree != identity.materialized_tree_sha:
        raise AdflibSourceError("ADFlib materialized tree identity mismatch")
    if manifest_sha256(materialized_entries) != identity.materialized_manifest_sha256:
        raise AdflibSourceError("ADFlib materialized tree identity mismatch")


def validate_regularization_record(record: Path, identity: AdflibIdentity) -> None:
    entries = [
        {
            "path": policy.path,
            "git_mode": "120000",
            "symlink_blob_sha": policy.symlink_blob_sha,
            "target": policy.target,
            "target_blob_sha": policy.target_blob_sha,
        }
        for policy in identity.policies
    ]
    expected = {"commit": identity.commit, "tree_sha": identity.tree_sha, "operation": "replace-symlink-with-target-blob", "entries": entries}
    if record.read_text(encoding="utf-8") != json.dumps(expected, indent=2) + "\n":
        raise AdflibSourceError("ADFlib regularization record mismatch")


def validate_transport_archive(contract: TransportContract) -> None:
    if sha256(contract.archive) != contract.sha256:
        raise AdflibSourceError("ADFlib upstream archive digest mismatch")
    expected_root = f"ADFlib-{contract.identity.commit}"
    policies = {policy.path: policy for policy in contract.identity.policies}
    archived_paths: set[str] = set()
    try:
        with tarfile.open(contract.archive, "r:gz") as source:
            for member in source:
                path = PurePosixPath(member.name)
                if path.is_absolute() or ".." in path.parts or not path.parts or path.parts[0] != expected_root:
                    raise AdflibSourceError(f"unsafe ADFlib upstream member: {member.name}")
                relative = PurePosixPath(*path.parts[1:])
                if member.isdir() or not relative.parts:
                    continue
                relative_text = relative.as_posix()
                if relative_text in archived_paths:
                    raise AdflibSourceError(f"duplicate ADFlib upstream member: {relative_text}")
                archived_paths.add(relative_text)
                policy = policies.get(relative_text)
                if policy is not None:
                    if not member.issym() or member.linkname != policy.target:
                        raise AdflibSourceError(f"ADFlib upstream symlink mismatch: {relative_text}")
                    continue
                if not member.isfile():
                    raise AdflibSourceError(f"unsupported ADFlib upstream member: {relative_text}")
                stream = source.extractfile(member)
                packaged = contract.source_root / relative_text
                if stream is None or stream.read() != packaged.read_bytes():
                    raise AdflibSourceError(f"ADFlib upstream content mismatch: {relative_text}")
                if bool(packaged.stat().st_mode & 0o111) != bool(member.mode & 0o111):
                    raise AdflibSourceError(f"ADFlib upstream mode mismatch: {relative_text}")
    except (OSError, tarfile.TarError) as error:
        raise AdflibSourceError("ADFlib upstream archive is not inspectable") from error
    actual_paths = {path.relative_to(contract.source_root).as_posix() for path in contract.source_root.rglob("*") if path.is_file()}
    if archived_paths != actual_paths:
        raise AdflibSourceError("ADFlib upstream archive inventory mismatch")


def validate_packaging_materials(source_root: Path) -> None:
    amiga_root = Path(__file__).resolve().parents[3]
    expected = canonical_build_materials(amiga_root)
    actual = {
        path.relative_to(source_root).as_posix()
        for path in (source_root / "Tools").rglob("*")
        if path.is_file() and path.relative_to(source_root).as_posix() != REGULARIZATION_RELATIVE
    }
    if actual != expected:
        raise AdflibSourceError("packaged build material closure mismatch")
    comparisons = {(source_root / relative): (amiga_root / relative) for relative in expected}
    if any(packaged.read_bytes() != tracked.read_bytes() for packaged, tracked in comparisons.items()):
        raise AdflibSourceError("packaged build material differs from tracked source")
