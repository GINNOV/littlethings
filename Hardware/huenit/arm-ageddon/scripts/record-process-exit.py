#!/usr/bin/env python3

from __future__ import annotations

import argparse
import sys
import time
from pathlib import Path

from evidence_common import EvidenceError, JsonValue, exclusive_json, read_json, require_mapping, sha256_file


def main() -> int:
    parser = argparse.ArgumentParser(description="Record an exit already observed by a trusted owner receipt.")
    parser.add_argument("--owner-receipt", required=True, type=Path)
    parser.add_argument("--receipt", required=True, type=Path)
    args = parser.parse_args()
    try:
        owner_path = args.owner_receipt.resolve(strict=True)
        owner = require_mapping(read_json(owner_path), "owner receipt")
        status = owner.get("exitStatus")
        if not isinstance(status, int) or isinstance(status, bool):
            raise EvidenceError("missing-observed-status", str(owner_path))
        if owner.get("kind") not in ("build", "process-exit"):
            raise EvidenceError("untrusted-owner", str(owner.get("kind")))
        value: JsonValue = {"schemaVersion": 1, "kind": "recorded-process-exit", "ownerReceipt": {"path": str(owner_path), "sha256": sha256_file(owner_path)}, "exitStatus": status, "recordedMonotonicNs": time.monotonic_ns()}
        exclusive_json(args.receipt.absolute(), value)
    except (EvidenceError, OSError) as error:
        code = error.code if isinstance(error, EvidenceError) else "io-error"
        print(f"ERROR[{code}]: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
