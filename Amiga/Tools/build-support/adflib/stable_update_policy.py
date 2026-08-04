#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 stable_update_policy.py validate --policy policy.json --snapshot settings.json

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Final

REPOSITORY: Final = "GINNOV/littlethings"
SCHEMA: Final = "adflib-automation-policy/v1"
ENVIRONMENT: Final = "adflib-verification"
NAMESPACE_PATTERNS: Final = (
    "deps/adflib-stable",
    "deps/adflib-leases/*",
    "deps/adflib-validation/*",
)
APP_PERMISSIONS: Final = {"actions": "read", "contents": "write", "pull_requests": "write"}


class PolicyError(Exception):
    pass


def _object(value: object, keys: frozenset[str], code: str) -> dict[str, object]:
    if not isinstance(value, dict) or set(value) != keys or not all(isinstance(key, str) for key in value):
        raise PolicyError(code)
    return value


def _string(value: object, code: str) -> str:
    if not isinstance(value, str) or not value:
        raise PolicyError(code)
    return value


def policy_payload_sha256(policy: dict[str, object]) -> str:
    payload = {key: value for key, value in policy.items() if key != "receipt"}
    encoded = (json.dumps(payload, sort_keys=True, separators=(",", ":")) + "\n").encode()
    return hashlib.sha256(encoded).hexdigest()


def verify_external_receipt(policy: dict[str, object], allowed_signers: Path, identity: str, fingerprint: str) -> None:
    receipt = _object(policy.get("receipt"), frozenset({"signer", "signature", "payload_sha256"}), "policy_receipt_invalid")
    payload = {key: value for key, value in policy.items() if key != "receipt"}
    encoded = (json.dumps(payload, sort_keys=True, separators=(",", ":")) + "\n").encode()
    if receipt.get("signer") != identity or receipt.get("payload_sha256") != hashlib.sha256(encoded).hexdigest():
        raise PolicyError("signed_receipt_payload_mismatch")
    fingerprint_result = subprocess.run(["ssh-keygen", "-lf", str(allowed_signers)], check=False, capture_output=True, text=True)
    if fingerprint_result.returncode != 0 or fingerprint not in fingerprint_result.stdout.split():
        raise PolicyError("authority_fingerprint_mismatch")
    signature = receipt.get("signature")
    if not isinstance(signature, str):
        raise PolicyError("policy_signature_missing")
    try:
        signature_bytes = base64.b64decode(signature, validate=True)
    except ValueError as error:
        raise PolicyError("policy_signature_invalid") from error
    with tempfile.NamedTemporaryFile(prefix="adflib-receipt-", suffix=".sig") as signature_file:
        signature_file.write(signature_bytes)
        signature_file.flush()
        verify = subprocess.run(["ssh-keygen", "-Y", "verify", "-f", str(allowed_signers), "-I", identity, "-n", "adflib-automation", "-s", signature_file.name], input=encoded, check=False, capture_output=True)
    if verify.returncode != 0:
        raise PolicyError("policy_signature_verification_failed")


def validate_policy_document(policy: dict[str, object]) -> None:
    _object(policy, frozenset({"schema", "repository", "receipt", "approver_team", "environment", "codeowners", "app", "merge_settings"}), "policy_schema_invalid")
    if policy["schema"] != SCHEMA or policy["repository"] != REPOSITORY:
        raise PolicyError("repository_policy_mismatch")
    team = _string(policy["approver_team"], "approver_team_invalid")
    if policy["environment"] != ENVIRONMENT:
        raise PolicyError("authority_literal_mismatch")
    receipt = _object(policy["receipt"], frozenset({"signer", "signature", "payload_sha256"}), "policy_receipt_invalid")
    if receipt["signer"] != "gi-business-adflib-authority" or not _string(receipt["signature"], "policy_signature_missing") or receipt["payload_sha256"] != policy_payload_sha256(policy):
        raise PolicyError("signed_receipt_mismatch")
    codeowners = _object(policy["codeowners"], frozenset({"paths", "owner", "blob_sha"}), "policy_codeowners_invalid")
    if codeowners["owner"] != f"@GINNOV/{team}" or codeowners["paths"] != ["/.github/workflows/adflib-update.yml", "/Amiga/Tools/build-support/adflib/"] or not isinstance(codeowners["blob_sha"], str) or len(codeowners["blob_sha"]) != 40:
        raise PolicyError("codeowners_mismatch")
    app_policy = _object(policy["app"], frozenset({"id", "installation_id", "slug", "permissions"}), "policy_app_invalid")
    if not isinstance(app_policy["id"], int) or not isinstance(app_policy["installation_id"], int) or not _string(app_policy["slug"], "app_slug_invalid") or app_policy["permissions"] != APP_PERMISSIONS:
        raise PolicyError("policy_app_identity_or_permissions_mismatch")
    _object(policy["merge_settings"], frozenset({"allow_auto_merge", "allow_merge_commit", "allow_rebase_merge", "allow_squash_merge", "delete_branch_on_merge"}), "merge_settings_invalid")


def validate_policy_snapshot(policy: dict[str, object], snapshot: dict[str, object]) -> None:
    validate_policy_document(policy)
    _object(snapshot, frozenset({"repository", "default_branch", "trusted_master_sha", "merge_settings", "actions_can_approve_pull_requests", "approver_team", "environment", "codeowners", "branch_ruleset", "namespace_ruleset", "release_ruleset", "app", "receipt"}), "snapshot_schema_invalid")
    if snapshot["repository"] != REPOSITORY:
        raise PolicyError("repository_policy_mismatch")
    team = _string(policy["approver_team"], "approver_team_invalid")
    if snapshot["approver_team"] != team or snapshot["default_branch"] != "master" or not isinstance(snapshot["trusted_master_sha"], str) or len(snapshot["trusted_master_sha"]) != 40:
        raise PolicyError("authority_literal_mismatch")
    if snapshot["actions_can_approve_pull_requests"] is not False:
        raise PolicyError("actions_pr_approval_enabled")
    if snapshot["merge_settings"] != policy["merge_settings"]:
        raise PolicyError("repository_merge_settings_mismatch")
    observed_receipt = _object(snapshot["receipt"], frozenset({"signer", "payload_sha256", "verified"}), "snapshot_receipt_invalid")
    if observed_receipt != {"signer": "gi-business-adflib-authority", "payload_sha256": policy_payload_sha256(policy), "verified": True}:
        raise PolicyError("signed_receipt_mismatch")
    environment = _object(snapshot["environment"], frozenset({"name", "reviewers", "prevent_self_review"}), "environment_schema_invalid")
    if environment["name"] != ENVIRONMENT or environment["reviewers"] != [team] or environment["prevent_self_review"] is not True:
        raise PolicyError("environment_reviewers_mismatch")
    codeowners = _object(policy["codeowners"], frozenset({"paths", "owner", "blob_sha"}), "policy_codeowners_invalid")
    if snapshot["codeowners"] != codeowners:
        raise PolicyError("codeowners_mismatch")
    app_policy = _object(policy["app"], frozenset({"id", "installation_id", "slug", "permissions"}), "policy_app_invalid")
    app = _object(snapshot["app"], frozenset({"id", "installation_id", "slug", "permissions", "merge_permission"}), "snapshot_app_invalid")
    if {key: app[key] for key in app_policy} != app_policy or app["permissions"] != APP_PERMISSIONS or app["merge_permission"] is not False:
        raise PolicyError("app_identity_or_permissions_mismatch")
    app_id = app_policy["id"]
    actor = [{"type": "Integration", "id": app_id}]
    branch = _object(snapshot["branch_ruleset"], frozenset({"target", "push_actors", "required_approvals", "dismiss_stale_reviews", "require_most_recent_approval"}), "branch_ruleset_invalid")
    if branch != {"target": "master", "push_actors": [], "required_approvals": 1, "dismiss_stale_reviews": True, "require_most_recent_approval": True}:
        raise PolicyError("master_ruleset_mismatch")
    namespace = _object(snapshot["namespace_ruleset"], frozenset({"patterns", "push_actors"}), "namespace_ruleset_invalid")
    if namespace != {"patterns": list(NAMESPACE_PATTERNS), "push_actors": actor}:
        raise PolicyError("namespace_ruleset_mismatch")
    release = _object(snapshot["release_ruleset"], frozenset({"pattern", "update_allowed", "delete_allowed"}), "release_ruleset_invalid")
    if release != {"pattern": "refs/tags/v*", "update_allowed": False, "delete_allowed": False}:
        raise PolicyError("release_ruleset_mismatch")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("schema", "validate"))
    parser.add_argument("--policy", type=Path, required=True)
    parser.add_argument("--snapshot", type=Path)
    arguments = parser.parse_args()
    try:
        policy = json.loads(arguments.policy.read_text(encoding="utf-8"))
        if not isinstance(policy, dict):
            raise PolicyError("document_not_object")
        validate_policy_document(policy)
        if arguments.command == "validate":
            if arguments.snapshot is None:
                raise PolicyError("snapshot_required")
            snapshot = json.loads(arguments.snapshot.read_text(encoding="utf-8"))
            if not isinstance(snapshot, dict):
                raise PolicyError("document_not_object")
            validate_policy_snapshot(policy, snapshot)
    except (OSError, json.JSONDecodeError, PolicyError) as error:
        print(error, file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
