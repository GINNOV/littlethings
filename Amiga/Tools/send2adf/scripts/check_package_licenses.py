#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 Tools/send2adf/scripts/check_package_licenses.py <package-tree>

from __future__ import annotations

import hashlib
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Final, TypeAlias

if __package__:
    from .adflib_source_contract import (
        AdflibSourceError,
        TransportContract,
        load_identity,
        validate_packaging_materials,
        validate_regularization_record,
        validate_transport_archive,
        validate_tree,
    )
    from .license_approval_contract import ApprovalContractError, validate_approval
    from .package_materials import (
        PackageMaterialError,
        SourceArchiveContract,
        validate_license_files,
        validate_required_notices,
        validate_source_archive,
    )
else:
    from adflib_source_contract import (
        AdflibSourceError,
        TransportContract,
        load_identity,
        validate_packaging_materials,
        validate_regularization_record,
        validate_transport_archive,
        validate_tree,
    )
    from license_approval_contract import ApprovalContractError, validate_approval
    from package_materials import (
        PackageMaterialError,
        SourceArchiveContract,
        validate_license_files,
        validate_required_notices,
        validate_source_archive,
    )

JsonValue: TypeAlias = str | int | bool | None | list["JsonValue"] | dict[str, "JsonValue"]
JsonMap: TypeAlias = dict[str, JsonValue]
HEX_40: Final = re.compile(r"^[0-9a-f]{40}$")
HEX_64: Final = re.compile(r"^[0-9a-f]{64}$")
REQUIRED_PACKAGE_FILES: Final = (
    "LICENSE",
    "THIRD_PARTY_NOTICES.md",
    "LICENSES/GPL-2.0.txt",
    "ADFlib/COPYING",
    "provenance.json",
    "ADFlibLicenseApprovals.json",
    "post-merge-license-receipt.json",
    "CORRESPONDING_SOURCE.json",
)
REQUIRED_SYSTEM_DEPENDENCIES: Final = frozenset({"C99 compiler", "CMake >= 3.24", "Python >= 3.11", "git"})
NOTICE_IDENTITY_FIELDS: Final = frozenset(
    {
        "ADFLIB_VERSION",
        "ADFLIB_TAG",
        "ADFLIB_COMMIT",
        "ADFLIB_TREE_SHA",
        "ADFLIB_ARCHIVE_URL",
        "ADFLIB_TREE_MANIFEST_SHA256",
    }
)
REQUIRED_SOURCE_KINDS: Final = frozenset(
    {
        "application-source",
        "adflib-patch",
        "adflib-regularization",
        "adflib-source",
        "adflib-upstream-archive",
        "build-system",
    }
)


@dataclass(frozen=True, slots=True)
class ContractError(Exception):
    message: str

    def __str__(self) -> str:
        return self.message


def load_json(path: Path) -> JsonMap:
    try:
        value: JsonValue = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise ContractError(f"invalid JSON: {path.name}") from error
    match value:  # Untrusted JSON may be a non-object variant.
        case dict() as mapping:
            return mapping
        case _:
            raise ContractError(f"invalid JSON object: {path.name}")


def require_map(mapping: JsonMap, key: str) -> JsonMap:
    match mapping.get(key):  # Wrong JSON variants are contract errors.
        case dict() as value:
            return value
        case _:
            raise ContractError(f"invalid field: {key}")


def require_list(mapping: JsonMap, key: str) -> list[JsonValue]:
    match mapping.get(key):  # Wrong JSON variants are contract errors.
        case list() as value:
            return value
        case _:
            raise ContractError(f"invalid field: {key}")


def require_string(mapping: JsonMap, key: str) -> str:
    match mapping.get(key):  # Wrong JSON variants are contract errors.
        case str() as value if value:
            return value
        case _:
            raise ContractError(f"invalid field: {key}")


def require_hex(mapping: JsonMap, key: str, pattern: re.Pattern[str]) -> str:
    value = require_string(mapping, key)
    if pattern.fullmatch(value) is None:
        raise ContractError(f"invalid field: {key}")
    return value


def require_string_set(mapping: JsonMap, key: str) -> set[str]:
    result: set[str] = set()
    for value in require_list(mapping, key):
        match value:  # Wrong JSON variants are contract errors.
            case str() as item if item:
                result.add(item)
            case _:
                raise ContractError(f"invalid field: {key}")
    return result


def checked_path(root: Path, relative: str, *, directory: bool = False) -> Path:
    pure_path = PurePosixPath(relative)
    if pure_path.is_absolute() or not pure_path.parts or ".." in pure_path.parts:
        raise ContractError(f"unsafe path: {relative}")
    path = root.joinpath(*pure_path.parts)
    if path.is_symlink():
        raise ContractError(f"unsafe path: {relative}")
    if not (path.is_dir() if directory else path.is_file()):
        raise ContractError(f"missing: {relative}")
    return path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate_notice_policy(notice: Path, manifest: Path) -> None:
    notice_text = notice.read_text(encoding="utf-8")
    identity_values: set[str] = set()
    for line in manifest.read_text(encoding="utf-8").splitlines():
        matched = re.fullmatch(r'set\((ADFLIB_[A-Z0-9_]+) "([^"]*)"\)', line)
        if matched is not None and matched.group(1) in NOTICE_IDENTITY_FIELDS:
            identity_values.add(matched.group(2))
    if len(identity_values) != len(NOTICE_IDENTITY_FIELDS):
        raise ContractError("ADFlib notice identity source is incomplete")
    if any(value in notice_text for value in identity_values):
        raise ContractError("third-party notice pins ADFlib identity")


def validate_corresponding_source(root: Path, provenance: JsonMap) -> None:
    contract = load_json(root / "CORRESPONDING_SOURCE.json")
    if contract.get("relationship") != "accompanying-source":
        raise ContractError("corresponding source must accompany binaries")
    source_root_name = require_string(contract, "source_root")
    source_root = checked_path(root, source_root_name, directory=True)
    archive = require_map(contract, "source_archive")
    archive_path = checked_path(root, require_string(archive, "name"))
    if sha256(archive_path) != require_hex(archive, "sha256", HEX_64):
        raise ContractError("corresponding source archive mismatch")
    require_string(archive, "release_tag")
    require_string(archive, "release_url")
    if require_string_set(contract, "system_dependencies") != REQUIRED_SYSTEM_DEPENDENCIES:
        raise ContractError("system dependency declaration mismatch")
    inventoried_paths: set[str] = set()
    source_kinds: set[str] = set()
    inventory_by_kind: dict[str, set[str]] = {}
    packaging_paths: set[str] = set()
    for value in require_list(contract, "source_inventory"):
        match value:  # Source inventory input is untrusted JSON.
            case dict() as item:
                kind = require_string(item, "kind")
                relative = require_string(item, "path")
                checked_path(source_root, relative, directory=kind == "adflib-source")
                source_kinds.add(kind)
                inventoried_paths.add(relative)
                inventory_by_kind.setdefault(kind, set()).add(relative)
            case _:
                raise ContractError("invalid source inventory")
    missing_kinds = REQUIRED_SOURCE_KINDS - source_kinds
    if missing_kinds:
        raise ContractError(f"missing source kind: {min(missing_kinds)}")
    for value in require_list(contract, "non_system_packaging_dependencies"):
        match value:  # Dependency input is untrusted JSON.
            case dict() as dependency:
                require_string(dependency, "name")
                path = require_string(dependency, "path")
                checked_path(source_root, path)
                packaging_paths.add(path)
            case _:
                raise ContractError("invalid packaging dependency")
    if packaging_paths != inventory_by_kind.get("packaging-dependency", set()):
        raise ContractError("packaging dependency source mismatch")
    adflib = require_map(contract, "adflib_source")
    adflib_path = require_string(adflib, "path")
    if {adflib_path} != inventory_by_kind.get("adflib-source", set()):
        raise ContractError("ADFlib source inventory mismatch")
    validate_packaging_materials(source_root)
    identity = load_identity(source_root / "Tools/build-support/adflib/ADFlibDependency.cmake")
    identities = (
        (require_hex(adflib, "commit", HEX_40), require_hex(provenance, "adflib_commit", HEX_40), identity.commit),
        (require_hex(adflib, "tree_sha", HEX_40), require_hex(provenance, "adflib_tree_sha", HEX_40), identity.tree_sha),
        (
            require_hex(adflib, "tree_manifest_sha256", HEX_64),
            require_hex(provenance, "adflib_tree_manifest_sha256", HEX_64),
            identity.manifest_sha256,
        ),
    )
    if any(contract_value != provenance_value or contract_value != pinned for contract_value, provenance_value, pinned in identities):
        raise ContractError("pinned ADFlib identity mismatch")
    upstream_archive = require_string(adflib, "upstream_archive")
    if {upstream_archive} != inventory_by_kind.get("adflib-upstream-archive", set()):
        raise ContractError("ADFlib upstream archive inventory mismatch")
    upstream_archive_sha256 = require_hex(adflib, "upstream_archive_sha256", HEX_64)
    regularization_record = require_string(adflib, "regularization_record")
    if {regularization_record} != inventory_by_kind.get("adflib-regularization", set()):
        raise ContractError("ADFlib regularization inventory mismatch")
    adflib_root = checked_path(source_root, adflib_path, directory=True)
    validate_tree(adflib_root, identity)
    validate_regularization_record(checked_path(source_root, regularization_record), identity)
    validate_transport_archive(
        TransportContract(
            checked_path(source_root, upstream_archive),
            adflib_root,
            identity,
            upstream_archive_sha256,
        )
    )
    if require_string_set(contract, "adflib_patches") != inventory_by_kind.get("adflib-patch", set()):
        raise ContractError("ADFlib patch source mismatch")
    if require_string_set(contract, "build_helpers") != inventory_by_kind.get("build-helper", set()):
        raise ContractError("build helper source mismatch")
    if require_string_set(contract, "build_descriptors") != inventory_by_kind.get("build-system", set()):
        raise ContractError("build descriptor source mismatch")
    actual_paths = {
        path.relative_to(source_root).as_posix()
        for path in source_root.rglob("*")
        if path.is_file() and not path.is_symlink()
    }
    expanded_inventory = {
        relative for relative in inventoried_paths if (source_root / relative).is_file()
    }
    for relative in tuple(inventoried_paths):
        path = source_root / relative
        if path.is_dir():
            expanded_inventory.update(
                child.relative_to(source_root).as_posix() for child in path.rglob("*") if child.is_file()
            )
    if actual_paths != expanded_inventory:
        raise ContractError("corresponding source inventory mismatch")
    validate_source_archive(
        SourceArchiveContract(
            archive=archive_path,
            source_root=source_root,
            archive_root=require_string(archive, "archive_root"),
            expected_paths=frozenset(actual_paths),
        )
    )


def check_package(root: Path) -> None:
    if not root.is_dir():
        raise ContractError(f"missing package tree: {root}")
    for relative in REQUIRED_PACKAGE_FILES:
        checked_path(root, relative)
    repository_notice = Path(__file__).resolve().parents[1] / "THIRD_PARTY_NOTICES.md"
    if (root / "THIRD_PARTY_NOTICES.md").read_bytes() != repository_notice.read_bytes():
        raise ContractError("third-party notice mismatch")
    validate_notice_policy(
        repository_notice,
        Path(__file__).resolve().parents[2] / "build-support/adflib/ADFlibDependency.cmake",
    )
    validate_required_notices(root)
    provenance = load_json(root / "provenance.json")
    validate_approval(root, provenance)
    validate_corresponding_source(root, provenance)
    contract = load_json(root / "CORRESPONDING_SOURCE.json")
    adflib = require_map(contract, "adflib_source")
    validate_license_files(
        root,
        root / require_string(contract, "source_root"),
        require_string(adflib, "path"),
    )


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print("usage: check_package_licenses.py <package-tree>", file=sys.stderr)
        return 2
    try:
        check_package(Path(argv[1]))
    except (AdflibSourceError, ApprovalContractError, ContractError, PackageMaterialError) as error:
        print(error, file=sys.stderr)
        return 2
    print("license_inventory_ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
