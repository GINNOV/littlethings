from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Final, TypeAlias

JsonValue: TypeAlias = str | int | bool | None | list["JsonValue"] | dict[str, "JsonValue"]
JsonMap: TypeAlias = dict[str, JsonValue]
HEX_40: Final = re.compile(r"^[0-9a-f]{40}$")
HEX_64: Final = re.compile(r"^[0-9a-f]{64}$")


@dataclass(frozen=True, slots=True)
class ApprovalContractError(Exception):
    message: str

    def __str__(self) -> str:
        return self.message


def load_json(path: Path) -> JsonMap:
    try:
        value: JsonValue = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise ApprovalContractError(f"invalid JSON: {path.name}") from error
    match value:  # noqa: MATCH_OK -- Untrusted JSON may be a non-object variant.
        case dict() as mapping:
            return mapping
        case _:
            raise ApprovalContractError(f"invalid JSON object: {path.name}")


def require_map(mapping: JsonMap, key: str) -> JsonMap:
    match mapping.get(key):  # noqa: MATCH_OK -- Wrong JSON variants are contract errors.
        case dict() as value:
            return value
        case _:
            raise ApprovalContractError(f"invalid field: {key}")


def require_list(mapping: JsonMap, key: str) -> list[JsonValue]:
    match mapping.get(key):  # noqa: MATCH_OK -- Wrong JSON variants are contract errors.
        case list() as value:
            return value
        case _:
            raise ApprovalContractError(f"invalid field: {key}")


def require_string(mapping: JsonMap, key: str) -> str:
    match mapping.get(key):  # noqa: MATCH_OK -- Wrong JSON variants are contract errors.
        case str() as value if value:
            return value
        case _:
            raise ApprovalContractError(f"invalid field: {key}")


def require_int(mapping: JsonMap, key: str) -> int:
    match mapping.get(key):  # noqa: MATCH_OK -- Wrong JSON variants are contract errors.
        case bool():
            raise ApprovalContractError(f"invalid field: {key}")
        case int() as value if value > 0:
            return value
        case _:
            raise ApprovalContractError(f"invalid field: {key}")


def require_hex(mapping: JsonMap, key: str, pattern: re.Pattern[str]) -> str:
    value = require_string(mapping, key)
    if pattern.fullmatch(value) is None:
        raise ApprovalContractError(f"invalid field: {key}")
    return value


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate_approval(root: Path, provenance: JsonMap) -> None:
    ledger_path = root / "ADFlibLicenseApprovals.json"
    ledger = load_json(ledger_path)
    if ledger.get("schema_version") != 1:
        raise ApprovalContractError("unsupported approval ledger schema")
    if require_map(ledger, "policy").get("combined_binary") != "GPL-2.0-or-later":
        raise ApprovalContractError("invalid combined-binary license policy")
    if require_map(ledger, "baseline").get("status") != "approved":
        raise ApprovalContractError("license approval pending")
    candidate_commit = require_hex(provenance, "adflib_commit", HEX_40)
    inventory_digest = require_hex(provenance, "license_inventory_sha256", HEX_64)
    matching_entry: JsonMap | None = None
    for value in require_list(ledger, "approvals"):
        match value:  # noqa: MATCH_OK -- Ledger input is untrusted JSON.
            case dict() as entry:
                if entry.get("candidate_commit") == candidate_commit and entry.get(
                    "license_inventory_sha256"
                ) == inventory_digest:
                    matching_entry = entry
            case _:
                raise ApprovalContractError("invalid approval entry")
    if matching_entry is None or matching_entry.get("policy_decision") != "approved":
        raise ApprovalContractError("license approval pending")
    require_int(matching_entry, "approval_pr")
    require_string(matching_entry, "reviewer_login")
    require_int(matching_entry, "reviewer_user_id")
    require_string(matching_entry, "approved_at")
    require_hex(matching_entry, "bootblock_inventory_sha256", HEX_64)
    entry_digest = require_hex(matching_entry, "entry_digest", HEX_64)
    projection = {key: value for key, value in matching_entry.items() if key != "entry_digest"}
    canonical = json.dumps(projection, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    if hashlib.sha256(canonical.encode()).hexdigest() != entry_digest:
        raise ApprovalContractError("approval entry digest mismatch")
    for value in require_list(ledger, "bootblocks"):
        match value:  # noqa: MATCH_OK -- Ledger input is untrusted JSON.
            case dict() as bootblock:
                require_hex(bootblock, "sha256", HEX_64)
                require_string(bootblock, "origin")
                require_string(bootblock, "redistribution_terms")
                if bootblock.get("legal_decision") != "approved":
                    raise ApprovalContractError("bootblock approval pending")
            case _:
                raise ApprovalContractError("invalid bootblock approval")
    receipt = load_json(root / "post-merge-license-receipt.json")
    expected_keys = {
        "schema_version", "repository", "ledger_path", "merge_commit", "ledger_sha256",
        "approved_entry_digest", "approved_tree_contains_exact_ledger",
    }
    if set(receipt) != expected_keys:
        raise ApprovalContractError("invalid post-merge receipt shape")
    if receipt.get("schema_version") != 1 or receipt.get("repository") != "GINNOV/littlethings":
        raise ApprovalContractError("invalid post-merge receipt identity")
    if receipt.get("ledger_path") != "Amiga/Tools/build-support/adflib/ADFlibLicenseApprovals.json":
        raise ApprovalContractError("invalid post-merge receipt ledger path")
    require_hex(receipt, "merge_commit", HEX_40)
    if receipt.get("approved_tree_contains_exact_ledger") is not True:
        raise ApprovalContractError("post-merge receipt is not authoritative")
    if receipt.get("ledger_sha256") != sha256(ledger_path):
        raise ApprovalContractError("post-merge receipt ledger mismatch")
    if receipt.get("approved_entry_digest") != entry_digest:
        raise ApprovalContractError("post-merge receipt entry mismatch")
