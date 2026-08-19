#!/usr/bin/env python3

from __future__ import annotations

import argparse
import os
import sys
import time
from pathlib import Path

from evidence_common import EvidenceError, JsonValue, exclusive_json, read_json, require_mapping, require_string, sha256_file


def identity(preflight: dict[str, JsonValue]) -> str:
    return require_string(preflight.get("parentSession"), "parentSession")


def main() -> int:
    parser = argparse.ArgumentParser(description="Create parent-bound immutable GUI lease records.")
    parser.add_argument("mode", choices=("start", "end", "schedule"))
    parser.add_argument("--preflight", required=True, type=Path)
    parser.add_argument("--session", required=True)
    parser.add_argument("--nonce", required=True)
    parser.add_argument("--receipt", required=True, type=Path)
    parser.add_argument("--start-receipt", type=Path)
    args = parser.parse_args()
    try:
        preflight_path = args.preflight.resolve(strict=True)
        preflight = require_mapping(read_json(preflight_path), "preflight")
        if identity(preflight) != args.session:
            raise EvidenceError("session-mismatch", args.session)
        start_record: JsonValue = None
        if args.mode in ("end", "schedule"):
            if args.start_receipt is None:
                raise EvidenceError("missing-start-receipt", args.mode)
            start_path = args.start_receipt.resolve(strict=True)
            start = require_mapping(read_json(start_path), "start receipt")
            if start.get("mode") != "start" or start.get("nonce") != args.nonce or start.get("session") != args.session:
                raise EvidenceError("lease-mismatch", str(start_path))
            start_record = {"path": str(start_path), "sha256": sha256_file(start_path)}
        value: JsonValue = {"schemaVersion": 1, "kind": "gui-lease", "mode": args.mode, "nonce": args.nonce, "session": args.session, "pid": os.getpid(), "preflight": {"path": str(preflight_path), "sha256": sha256_file(preflight_path)}, "startReceipt": start_record, "monotonicNs": time.monotonic_ns()}
        exclusive_json(args.receipt.absolute(), value)
    except (EvidenceError, OSError) as error:
        code = error.code if isinstance(error, EvidenceError) else "io-error"
        print(f"ERROR[{code}]: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
