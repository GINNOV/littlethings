#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 Tools/send2adf/scripts/package_release.py --help

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Final, cast

if __package__:
    from .adflib_source_contract import load_identity
    from .build_material_closure import canonical_build_materials
    from .license_approval_contract import ApprovalContractError, validate_approval
    from .release_archive import (
        ArchiveEntry,
        ArchiveError,
        JsonMap,
        JsonValue,
        canonical_json,
        file_entry,
        read_archive_entries,
        sha256,
        tree_entries,
        write_tar_gz,
    )
else:
    from adflib_source_contract import load_identity
    from build_material_closure import canonical_build_materials
    from license_approval_contract import ApprovalContractError, validate_approval
    from release_archive import (
        ArchiveEntry,
        ArchiveError,
        JsonMap,
        JsonValue,
        canonical_json,
        file_entry,
        read_archive_entries,
        sha256,
        tree_entries,
        write_tar_gz,
    )

HEX_40: Final = re.compile(r"^[0-9a-f]{40}$")
VERSION: Final = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+$")


@dataclass(frozen=True, slots=True)
class PackageError(Exception):
    message: str

    def __str__(self) -> str:
        return self.message


def parse_manifest(manifest: Path) -> JsonMap:
    values: dict[str, str] = {}
    for line in manifest.read_text(encoding="utf-8").splitlines():
        matched = re.fullmatch(r'set\((ADFLIB_[A-Z0-9_]+) "([^"]*)"\)', line)
        if matched is not None:
            values[matched.group(1)] = matched.group(2)
    version = values["ADFLIB_VERSION"]
    tag = values["ADFLIB_TAG"]
    if VERSION.fullmatch(version) is None or tag != f"v{version}":
        raise PackageError("invalid ADFlib version identity")
    commit = values["ADFLIB_COMMIT"]
    tree_sha = values["ADFLIB_TREE_SHA"]
    tree_manifest_sha256 = values["ADFLIB_TREE_MANIFEST_SHA256"]
    if HEX_40.fullmatch(commit) is None or HEX_40.fullmatch(tree_sha) is None or re.fullmatch(r"[0-9a-f]{64}", tree_manifest_sha256) is None:
        raise PackageError("invalid ADFlib source identity")
    contract: JsonMap = {
        "channel": "stable", "owner_repo": values["ADFLIB_OWNER_REPO"],
        "version": version, "tag": tag,
        "commit": commit, "tree_sha": tree_sha,
        "url": values["ADFLIB_ARCHIVE_URL"], "tree_manifest_sha256": tree_manifest_sha256,
        "transport_sha256": values["ADFLIB_TRANSPORT_SHA256"],
        "local_cache_sha256": values["ADFLIB_LOCAL_CACHE_SHA256"],
    }
    return contract


def adflib_source_name(identity: JsonMap) -> str:
    return f"ADFlib-{identity['tag']}"


def adflib_transport_name(identity: JsonMap) -> str:
    return f"ADFlib-{identity['commit']}-transport.tar.gz"


def build_material_kind(path: str) -> str:
    name = PurePosixPath(path).name
    if path.endswith("/patches/0001-cmake-disable-examples.patch"):
        return "adflib-patch"
    if name in {"CMakeLists.txt", "CMakePresets.json", "Makefile"} or name.endswith((".cmake", ".cmake.in", ".h.in")):
        return "build-system"
    if path.startswith("Tools/send2adf/") and name.endswith((".c", ".h")):
        return "application-source"
    return "build-helper"


def source_entries(repository: Path, adflib: Path, transport: Path, version: str, identity: JsonMap) -> list[ArchiveEntry]:
    root = f"send2adf-{version}-source"
    entries = [file_entry(f"{root}/LICENSE", repository / "LICENSE")]
    amiga_root = repository / "Amiga"
    for relative in sorted(canonical_build_materials(amiga_root), key=str.encode):
        entries.append(file_entry(f"{root}/{relative}", amiga_root / relative))
    entries += tree_entries(adflib, f"{root}/{adflib_source_name(identity)}", frozenset())
    entries.append(file_entry(f"{root}/upstream/{adflib_transport_name(identity)}", transport))
    source_identity = load_identity(amiga_root / "Tools/build-support/adflib/ADFlibDependency.cmake")
    regularization = {
        "commit": source_identity.commit, "tree_sha": source_identity.tree_sha,
        "operation": "replace-symlink-with-target-blob",
        "entries": [
            {"path": item.path, "git_mode": "120000", "symlink_blob_sha": item.symlink_blob_sha,
             "target": item.target, "target_blob_sha": item.target_blob_sha}
            for item in source_identity.policies
        ],
    }
    entries.append(ArchiveEntry(f"{root}/Tools/build-support/adflib/regularization/reviewed-symlinks.json", json.dumps(regularization, indent=2).encode() + b"\n"))
    return entries


def make_source(arguments: argparse.Namespace) -> None:
    repository = Path(arguments.repository_root).resolve()
    version = arguments.version
    if VERSION.fullmatch(version) is None:
        raise PackageError("invalid release version")
    manifest = repository / "Amiga/Tools/build-support/adflib/ADFlibDependency.cmake"
    identity = parse_manifest(manifest)
    transport = Path(arguments.adflib_transport).resolve()
    if sha256(transport) != identity["transport_sha256"]:
        raise PackageError("ADFlib transport digest mismatch")
    write_tar_gz(Path(arguments.output), source_entries(repository, Path(arguments.adflib_source).resolve(), transport, version, identity), int(arguments.epoch))


def source_contract(source: Path, entries: list[ArchiveEntry], identity: JsonMap, version: str, artifact_id: str) -> JsonMap:
    archive_root = f"send2adf-{version}-source"
    relatives = [PurePosixPath(entry.name).relative_to(archive_root).as_posix() for entry in entries]
    source_name = adflib_source_name(identity)
    upstream = f"upstream/{adflib_transport_name(identity)}"
    inventory: list[dict[str, str]] = []
    for path in relatives:
        if path.startswith(f"{source_name}/"):
            continue
        if path == upstream:
            kind = "adflib-upstream-archive"
        elif path.endswith("regularization/reviewed-symlinks.json"):
            kind = "adflib-regularization"
        elif path.startswith("Tools/"):
            kind = build_material_kind(path)
        else:
            kind = "application-source"
        inventory.append({"kind": kind, "path": path})
    inventory.append({"kind": "adflib-source", "path": source_name})
    build_descriptors = {item["path"] for item in inventory if item["kind"] == "build-system"}
    build_helpers = {item["path"] for item in inventory if item["kind"] == "build-helper"}
    adflib_patches = {item["path"] for item in inventory if item["kind"] == "adflib-patch"}
    contract: JsonMap = {
        "relationship": "accompanying-source", "source_root": archive_root,
        "source_archive": {
            "name": source.name, "sha256": sha256(source), "archive_root": archive_root,
            "release_tag": f"send2adf-v{version}",
            "release_url": f"https://github.com/GINNOV/littlethings/releases/tag/send2adf-v{version}",
            "producer_job": "source-archive", "artifact_id": artifact_id,
        },
        "system_dependencies": cast(JsonValue, ["C99 compiler", "CMake >= 3.24", "Python >= 3.11", "git"]),
        "non_system_packaging_dependencies": cast(JsonValue, []),
        "adflib_source": {
            "path": source_name, "commit": identity["commit"], "tree_sha": identity["tree_sha"],
            "tree_manifest_sha256": identity["tree_manifest_sha256"], "upstream_archive": upstream,
            "upstream_archive_sha256": identity["transport_sha256"],
            "regularization_record": "Tools/build-support/adflib/regularization/reviewed-symlinks.json",
        },
        "adflib_patches": cast(JsonValue, sorted(adflib_patches)),
        "build_helpers": cast(JsonValue, sorted(build_helpers)),
        "build_descriptors": cast(JsonValue, sorted(build_descriptors)),
        "source_inventory": cast(JsonValue, sorted(inventory, key=lambda item: item["path"].encode())),
    }
    return contract


def make_binary(arguments: argparse.Namespace) -> None:
    if os.environ.get("ADFLIB_CANARY", "").lower() in {"1", "on", "true", "yes"}:
        raise PackageError("canary release packaging rejected")
    if VERSION.fullmatch(arguments.version) is None or HEX_40.fullmatch(arguments.target_sha) is None:
        raise PackageError("invalid release identity")
    repository = Path(arguments.repository_root).resolve()
    manifest = repository / "Amiga/Tools/build-support/adflib/ADFlibDependency.cmake"
    identity = parse_manifest(manifest)
    executable = Path(arguments.binary).resolve()
    identity_result = subprocess.run([str(executable), "--build-identity"], check=False, capture_output=True, text=True)
    expected_identity = {key: identity[key] for key in ("channel", "owner_repo", "version", "tag", "commit", "tree_sha", "url", "tree_manifest_sha256")}
    if identity_result.returncode != 0 or json.loads(identity_result.stdout) != expected_identity:
        raise PackageError("binary ADFlib identity differs from production manifest")
    source = Path(arguments.source_archive).resolve()
    source_members = read_archive_entries(source)
    legal = Path(arguments.legal_root).resolve()
    approved_provenance = json.loads((legal / "provenance.json").read_text(encoding="utf-8"))
    validate_approval(legal, approved_provenance)
    provenance: JsonMap = {
        "schema_version": 1, "repository_sha": arguments.target_sha, "application_version": arguments.version,
        "adflib_identity": {key: identity[key] for key in ("channel", "owner_repo", "version", "tag", "commit", "tree_sha", "url", "tree_manifest_sha256")},
        "adflib_commit": identity["commit"], "adflib_tree_sha": identity["tree_sha"],
        "adflib_tree_manifest_sha256": identity["tree_manifest_sha256"], "shared_manifest_sha256": sha256(manifest),
        "source_transport_sha256": identity["transport_sha256"], "source_cache_sha256": identity["local_cache_sha256"],
        "license_inventory_sha256": approved_provenance["license_inventory_sha256"],
        "license_approval_reference": json.loads((legal / "post-merge-license-receipt.json").read_text(encoding="utf-8"))["approved_entry_digest"],
        "runner_image": arguments.runner_image, "architecture": arguments.architecture,
        "compiler_version": arguments.compiler_version, "cmake_version": arguments.cmake_version,
        "commands": {"configure": "cmake --preset production", "build": "cmake --build --preset production", "test": "ctest --preset production --output-on-failure", "package": "python3 Tools/send2adf/scripts/package_release.py binary"},
        "source_artifact": {"producer_job": "source-archive", "artifact_id": arguments.source_artifact_id,
                            "service_digest": arguments.source_service_digest, "sha256": sha256(source)},
    }
    root = f"send2adf-{arguments.version}-{arguments.platform}-{arguments.architecture}"
    contract = source_contract(source, source_members, identity, arguments.version, arguments.source_artifact_id)
    source_by_name = {entry.name: entry.content for entry in source_members}
    adflib_root = f"send2adf-{arguments.version}-source/{adflib_source_name(identity)}"
    package_entries = [
        file_entry(f"{root}/send2adf", executable),
        file_entry(f"{root}/LICENSE", repository / "LICENSE"),
        file_entry(f"{root}/THIRD_PARTY_NOTICES.md", repository / "Amiga/Tools/send2adf/THIRD_PARTY_NOTICES.md"),
        file_entry(f"{root}/LICENSES/GPL-2.0.txt", repository / "Amiga/Tools/send2adf/licenses/GPL-2.0.txt"),
        ArchiveEntry(f"{root}/ADFlib/COPYING", source_by_name[f"{adflib_root}/COPYING"]),
        ArchiveEntry(f"{root}/provenance.json", canonical_json(provenance)),
        ArchiveEntry(f"{root}/CORRESPONDING_SOURCE.json", canonical_json(contract)),
        file_entry(f"{root}/ADFlibLicenseApprovals.json", legal / "ADFlibLicenseApprovals.json"),
        file_entry(f"{root}/post-merge-license-receipt.json", legal / "post-merge-license-receipt.json"),
    ]
    for relative in ("src/adflib.c", "src/adf_version.h", "src/adf_limits.h"):
        package_entries.append(ArchiveEntry(f"{root}/ADFlib/source-notices/{relative}", source_by_name[f"{adflib_root}/{relative}"]))
    write_tar_gz(Path(arguments.output), package_entries, int(arguments.epoch))


def make_checksums(arguments: argparse.Namespace) -> None:
    paths = sorted((Path(value) for value in arguments.archives), key=lambda path: path.name.encode())
    Path(arguments.output).write_text("".join(f"{sha256(path)}  {path.name}\n" for path in paths), encoding="utf-8")


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser()
    commands = result.add_subparsers(dest="command", required=True)
    source = commands.add_parser("source")
    for name in ("repository-root", "adflib-source", "adflib-transport", "output", "version", "epoch"):
        source.add_argument(f"--{name}", required=True)
    binary = commands.add_parser("binary")
    for name in ("repository-root", "binary", "source-archive", "legal-root", "output", "version", "target-sha", "platform", "architecture", "epoch", "runner-image", "compiler-version", "cmake-version", "source-artifact-id", "source-service-digest"):
        binary.add_argument(f"--{name}", required=True)
    checksums = commands.add_parser("checksums")
    checksums.add_argument("--output", required=True)
    checksums.add_argument("archives", nargs="+")
    return result


def main() -> int:
    arguments = parser().parse_args()
    try:
        if arguments.command == "source":
            make_source(arguments)
        elif arguments.command == "binary":
            make_binary(arguments)
        else:
            make_checksums(arguments)
    except (ApprovalContractError, ArchiveError, json.JSONDecodeError, KeyError, OSError, PackageError, ValueError) as error:
        print(error, file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
