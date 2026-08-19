#!/usr/bin/env python3

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from evidence_common import EvidenceError, read_json, reject_forbidden_outcomes, require_mapping, sha256_bytes, sha256_file
from validate_evidence_support import validate_document


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate immutable Swift review receipts and transcripts.")
    parser.add_argument("receipts", nargs="+", type=Path)
    parser.add_argument("--schema", default=Path("Tests/ReviewSchemas/swift-review.schema.json"), type=Path)
    parser.add_argument("--commit", required=True)
    parser.add_argument("--not-before-epoch-ns", type=int)
    args = parser.parse_args()
    try:
        for path in args.receipts:
            receipt = require_mapping(read_json(path.resolve(strict=True)), "review receipt")
            reject_forbidden_outcomes(receipt)
            transcript = Path(str(receipt.get("transcript"))).resolve(strict=True)
            if receipt.get("transcriptSHA256") != sha256_file(transcript) or transcript.stat().st_size == 0:
                raise EvidenceError("transcript-mismatch", str(transcript))
            lines = [line.strip() for line in transcript.read_text(encoding="utf-8").splitlines() if line.strip()]
            for line in lines:
                reject_forbidden_outcomes(line)
            if not lines or lines[-1] != "VERDICT: PASS":
                raise EvidenceError("missing-review-verdict", str(transcript))
            if receipt.get("verdictLine") != lines[-1] or receipt.get("verdictLineSHA256") != sha256_bytes((lines[-1] + "\n").encode()):
                raise EvidenceError("review-verdict-mismatch", str(transcript))
            validate_document(args.schema, receipt)
            if receipt.get("commitSHA") != args.commit or receipt.get("verdict") != "PASS":
                raise EvidenceError("review-mismatch", str(path))
            if args.not_before_epoch_ns is not None and transcript.stat().st_mtime_ns < args.not_before_epoch_ns:
                raise EvidenceError("stale-transcript", str(transcript))
    except (EvidenceError, OSError) as error:
        code = error.code if isinstance(error, EvidenceError) else "io-error"
        print(f"ERROR[{code}]: {error}", file=sys.stderr)
        return 2
    print("PASS: review receipts validated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
