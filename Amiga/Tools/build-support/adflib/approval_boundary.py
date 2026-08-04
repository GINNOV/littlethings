#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 -m unittest tests/test_update_adflib.py

from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Final

HEX40: Final = re.compile(r"[0-9a-f]{40}")
HEX64: Final = re.compile(r"[0-9a-f]{64}")
TIMESTAMP: Final = re.compile(r"[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z")
APPROVAL_KEYS: Final = {
    "schema_version",
    "approval_pr_number",
    "reviewer_login",
    "reviewer_user_id",
    "approved_at",
    "candidate_commit",
    "license_inventory_sha256",
    "corresponding_source_sha256",
    "entry_digest",
}
RECEIPT_KEYS: Final = {
    "schema_version",
    "merge_commit",
    "approved_ledger_sha256",
    "approval_entry_digest",
    "candidate_commit",
    "license_inventory_sha256",
    "corresponding_source_sha256",
    "tree_contains_ledger",
}


@dataclass(frozen=True, slots=True)
class ApprovalError(Exception):
    code: str
    detail: str

    def __str__(self) -> str:
        return f"{self.code}: {self.detail}"


@dataclass(frozen=True, slots=True)
class IdentityApprovalInput:
    version: str
    tag: str
    commit: str
    tree_sha: str
    tree_manifest_sha256: str


@dataclass(frozen=True, slots=True)
class ApprovalRequest:
    current: IdentityApprovalInput
    current_inventory_sha256: str
    candidate_commit: str
    candidate_inventory_sha256: str
    corresponding_source_sha256: str


def _load(path: Path, code: str):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, UnicodeDecodeError) as error:
        raise ApprovalError(code, str(error)) from error


def _entry_digest(entry) -> str:
    projection = {key: entry[key] for key in sorted(APPROVAL_KEYS - {"entry_digest"})}
    encoded = json.dumps(projection, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(encoded).hexdigest()


def _valid_entry(entry, request: ApprovalRequest) -> bool:
    if not isinstance(entry, dict) or set(entry) != APPROVAL_KEYS:
        return False
    scalar_types = (
        entry.get("schema_version") == 1,
        isinstance(entry.get("approval_pr_number"), int) and entry["approval_pr_number"] > 0,
        isinstance(entry.get("reviewer_login"), str) and bool(entry["reviewer_login"]),
        isinstance(entry.get("reviewer_user_id"), int) and entry["reviewer_user_id"] > 0,
        isinstance(entry.get("approved_at"), str) and TIMESTAMP.fullmatch(entry["approved_at"]) is not None,
        entry.get("candidate_commit") == request.candidate_commit,
        entry.get("license_inventory_sha256") == request.candidate_inventory_sha256,
        entry.get("corresponding_source_sha256") == request.corresponding_source_sha256,
        isinstance(entry.get("entry_digest"), str) and HEX64.fullmatch(entry["entry_digest"]) is not None,
    )
    return all(scalar_types) and entry["entry_digest"] == _entry_digest(entry)


def _baseline_matches(ledger, request: ApprovalRequest) -> bool:
    if not isinstance(ledger, dict) or ledger.get("schema_version") != 1 or not isinstance(ledger.get("baseline"), dict):
        return False
    baseline = ledger["baseline"]
    expected = request.current
    return (
        baseline.get("version") == expected.version
        and baseline.get("tag") == expected.tag
        and baseline.get("commit") == expected.commit
        and baseline.get("tree_sha") == expected.tree_sha
        and baseline.get("tree_manifest_sha256") == expected.tree_manifest_sha256
        and baseline.get("license_inventory_sha256") == request.current_inventory_sha256
        and baseline.get("status") == "approved"
    )


def approval_allows(ledger_path: Path, receipt_path: Path | None, request: ApprovalRequest) -> bool:
    ledger = _load(ledger_path, "license_ledger_invalid")
    if not _baseline_matches(ledger, request):
        raise ApprovalError("baseline_approval_missing", request.current.commit)
    if request.current_inventory_sha256 == request.candidate_inventory_sha256:
        return True
    approvals = ledger.get("approvals")
    if not isinstance(approvals, list):
        raise ApprovalError("license_ledger_invalid", "approvals must be an array")
    matches = [entry for entry in approvals if _valid_entry(entry, request)]
    if len(matches) != 1 or receipt_path is None:
        return False
    entry = matches[0]
    receipt = _load(receipt_path, "approval_receipt_invalid")
    ledger_digest = hashlib.sha256(ledger_path.read_bytes()).hexdigest()
    if not isinstance(receipt, dict) or set(receipt) != RECEIPT_KEYS:
        return False
    return (
        receipt.get("schema_version") == 1
        and isinstance(receipt.get("merge_commit"), str)
        and HEX40.fullmatch(receipt["merge_commit"]) is not None
        and receipt.get("approved_ledger_sha256") == ledger_digest
        and receipt.get("approval_entry_digest") == entry["entry_digest"]
        and receipt.get("candidate_commit") == request.candidate_commit
        and receipt.get("license_inventory_sha256") == request.candidate_inventory_sha256
        and receipt.get("corresponding_source_sha256") == request.corresponding_source_sha256
        and receipt.get("tree_contains_ledger") is True
    )
