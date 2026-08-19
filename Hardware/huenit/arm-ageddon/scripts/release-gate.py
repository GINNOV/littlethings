#!/usr/bin/env python3

from __future__ import annotations

import argparse
import os
import stat
import sys
import time
from pathlib import Path

from evidence_common import EvidenceError, JsonValue, exclusive_json, read_json, sha256_file


def prerequisite(argument: str) -> JsonValue:
    path_text, separator, expected = argument.rpartition("=")
    if not separator or len(expected) != 64 or any(character not in "0123456789abcdef" for character in expected):
        raise EvidenceError("invalid-prerequisite", "expected PATH=SHA256")
    path = Path(path_text)
    if not path.is_absolute() or path.is_symlink():
        raise EvidenceError("invalid-prerequisite-path", path_text)
    resolved = path.resolve(strict=True)
    read_json(resolved)
    actual = sha256_file(resolved)
    if actual != expected:
        raise EvidenceError("prerequisite-hash-mismatch", str(resolved))
    return {"path": str(resolved), "sha256": actual}


def main() -> int:
    parser = argparse.ArgumentParser(description="Release one FIFO gate after immutable prerequisites validate.")
    parser.add_argument("--fifo", required=True, type=Path)
    parser.add_argument("--receipt", required=True, type=Path)
    parser.add_argument("--nonce", required=True)
    parser.add_argument("--prerequisite", action="append", default=[])
    args = parser.parse_args()
    try:
        prerequisites = [prerequisite(value) for value in args.prerequisite]
        receipt = args.receipt
        if not receipt.is_absolute() or receipt.parent.is_symlink():
            raise EvidenceError("invalid-receipt-path", str(receipt))
        receipt = receipt.parent.resolve(strict=True) / receipt.name
        if receipt.exists():
            raise EvidenceError("output-exists", str(receipt))
        fifo = args.fifo.resolve(strict=True)
        if not stat.S_ISFIFO(fifo.stat().st_mode):
            raise EvidenceError("not-fifo", str(fifo))
        descriptor = os.open(fifo, os.O_WRONLY)
        try:
            written = os.write(descriptor, b"1")
            if written != 1:
                raise EvidenceError("short-gate-write", str(written))
        finally:
            os.close(descriptor)
        value: JsonValue = {"schemaVersion": 1, "kind": "gate-release", "nonce": args.nonce, "fifo": str(fifo), "tokenSHA256": "6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b", "prerequisites": prerequisites, "releasedMonotonicNs": time.monotonic_ns()}
        exclusive_json(receipt, value)
    except (EvidenceError, OSError) as error:
        code = error.code if isinstance(error, EvidenceError) else "io-error"
        print(f"ERROR[{code}]: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
