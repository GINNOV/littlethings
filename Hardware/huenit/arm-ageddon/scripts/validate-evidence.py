#!/usr/bin/env python3

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

from evidence_common import EvidenceError, JsonValue, exclusive_json, read_json, require_mapping, require_string, sha256_file
from validate_evidence_support import validate


def task1_chain(args: argparse.Namespace) -> None:
    index_path = args.task1_index.resolve(strict=True)
    release_path = args.task1_release.resolve(strict=True)
    preflight_path = args.preflight.resolve(strict=True)
    schema = require_mapping(read_json(args.schema.resolve(strict=True)), "schema")
    index = require_mapping(read_json(index_path), "task 1 index")
    release = require_mapping(read_json(release_path), "task 1 release")
    preflight = require_mapping(read_json(preflight_path), "preflight")
    validate(schema, index)
    validate(schema, release)
    if release.get("task1IndexSHA256") != sha256_file(index_path):
        raise EvidenceError("task1-index-hash-mismatch", str(index_path))
    if release.get("preflightSHA256") != sha256_file(preflight_path):
        raise EvidenceError("preflight-hash-mismatch", str(preflight_path))
    preflight_ref = require_mapping(index.get("preflightReceipt"), "preflightReceipt")
    if preflight_ref.get("path") != str(preflight_path) or preflight_ref.get("sha256") != sha256_file(preflight_path):
        raise EvidenceError("preflight-reference-mismatch", str(preflight_path))
    commit = require_string(release.get("commitSHA"), "commitSHA")
    if commit != args.released_commit:
        raise EvidenceError("released-commit-mismatch", commit)
    if preflight.get("planSha256") != args.plan_sha256:
        raise EvidenceError("plan-hash-mismatch", str(preflight.get("planSha256")))
    repo_root = Path(require_string(preflight.get("repoRoot"), "repoRoot")).resolve(strict=True)
    fields = subprocess.run(["git", "-C", str(repo_root), "show", "-s", "--format=%P%n%s%n%T", commit], check=False, capture_output=True, text=True)
    if fields.returncode != 0:
        raise EvidenceError("missing-commit", commit)
    parent, message, tree = fields.stdout.rstrip("\n").split("\n")
    if release.get("commitParent") != parent or release.get("commitMessage") != message or release.get("commitTree") != tree:
        raise EvidenceError("commit-chain-mismatch", commit)
    if release.get("commitParent") != args.base_commit or index.get("baseSHA") != args.preflight_base:
        raise EvidenceError("base-chain-mismatch", commit)
    modes = index.get("modes")
    if not isinstance(modes, list):
        raise EvidenceError("missing-modes", str(index_path))
    for mode_value in modes:
        mode = require_mapping(mode_value, "mode")
        root = Path(require_string(mode.get("root"), "mode.root")).resolve(strict=True)
        receipt = root / "mode-receipt.json"
        mode_receipt = require_mapping(read_json(receipt), "mode receipt")
        if mode_receipt.get("nonce") != mode.get("nonce") or mode_receipt.get("root") != str(root):
            raise EvidenceError("mode-receipt-mismatch", str(receipt))
        if mode_receipt.get("mode") != mode.get("name") or mode_receipt.get("startMonotonicNs") != mode.get("startMonotonic") or mode_receipt.get("endMonotonicNs") != mode.get("endMonotonic"):
            raise EvidenceError("mode-timing-mismatch", str(receipt))
        if mode_receipt.get("statusPairSHA256") != mode.get("statusPairSHA256") or mode_receipt.get("subtreePairSHA256") != mode.get("subtreePairSHA256"):
            raise EvidenceError("mode-manifest-mismatch", str(receipt))
        pre_snapshot = require_mapping(read_json(root / "pre-snapshot.json"), "pre snapshot")
        post_snapshot = require_mapping(read_json(root / "post-snapshot.json"), "post snapshot")
        if pre_snapshot.get("statusSHA256") != post_snapshot.get("statusSHA256") or pre_snapshot.get("subtreeManifestSHA256") != post_snapshot.get("subtreeManifestSHA256"):
            raise EvidenceError("snapshot-chain-mismatch", str(root))
        expected_exits = require_mapping(mode_receipt.get("expectedExits"), "expectedExits")
        for command_id, expected_exit in expected_exits.items():
            command_receipt = require_mapping(read_json(root / f"{command_id}.json"), command_id)
            if command_receipt.get("actualExit") != expected_exit:
                raise EvidenceError("command-status-mismatch", command_id)
    if args.preserve_output is not None:
        value: JsonValue = {"schemaVersion": 1, "task1Index": {"path": str(index_path), "sha256": sha256_file(index_path)}, "task1Release": {"path": str(release_path), "sha256": sha256_file(release_path)}, "preflight": {"path": str(preflight_path), "sha256": sha256_file(preflight_path)}, "commitSHA": commit}
        exclusive_json(args.preserve_output.absolute(), value)


def parser() -> argparse.ArgumentParser:
    value = argparse.ArgumentParser(description="Validate JSON evidence and Task 1 parent provenance.")
    value.add_argument("--schema", required=True, type=Path)
    value.add_argument("--document", type=Path)
    value.add_argument("--task1-index", type=Path)
    value.add_argument("--task1-release", type=Path)
    value.add_argument("--preflight", type=Path)
    value.add_argument("--base-commit")
    value.add_argument("--preflight-base")
    value.add_argument("--released-commit")
    value.add_argument("--plan-sha256")
    value.add_argument("--preserve-output", type=Path)
    return value


def main() -> int:
    args = parser().parse_args()
    try:
        if args.document is not None:
            schema = require_mapping(read_json(args.schema.resolve(strict=True)), "schema")
            validate(schema, read_json(args.document.resolve(strict=True)))
        elif all((args.task1_index, args.task1_release, args.preflight, args.base_commit, args.preflight_base, args.released_commit, args.plan_sha256)):
            task1_chain(args)
        else:
            raise EvidenceError("usage", "provide --document or the complete Task 1 chain")
    except (EvidenceError, OSError, ValueError) as error:
        code = error.code if isinstance(error, EvidenceError) else "validation-error"
        print(f"ERROR[{code}]: {error}", file=sys.stderr)
        return 2
    print("PASS: evidence validated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
