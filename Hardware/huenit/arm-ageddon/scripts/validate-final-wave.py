#!/usr/bin/env python3

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from evidence_common import EvidenceError, read_json, reject_forbidden_outcomes, require_mapping, sha256_file


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate four distinct immutable final-gate indexes.")
    parser.add_argument("indexes", nargs=4, type=Path)
    parser.add_argument("--commit", required=True)
    args = parser.parse_args()
    try:
        resolved = [path.resolve(strict=True) for path in args.indexes]
        if len(set(resolved)) != 4 or len({sha256_file(path) for path in resolved}) != 4:
            raise EvidenceError("reused-final-index", "indexes and hashes must be distinct")
        gates: set[str] = set()
        nonces: set[str] = set()
        for path in resolved:
            value = require_mapping(read_json(path), "final index")
            reject_forbidden_outcomes(value)
            gate = value.get("gate")
            if not isinstance(gate, str) or value.get("commitSHA") != args.commit or value.get("outcome") != "PASS":
                raise EvidenceError("final-index-mismatch", str(path))
            gates.add(gate)
            nonce = value.get("childNonce")
            if not isinstance(nonce, str) or nonce in nonces:
                raise EvidenceError("reused-nonce", str(path))
            nonces.add(nonce)
        if gates != {"compliance", "quality", "manual-fixture", "scope"}:
            raise EvidenceError("final-gates-incomplete", str(sorted(gates)))
    except (EvidenceError, OSError) as error:
        code = error.code if isinstance(error, EvidenceError) else "io-error"
        print(f"ERROR[{code}]: {error}", file=sys.stderr)
        return 2
    print("PASS: final wave validated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
