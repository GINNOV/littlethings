#!/usr/bin/env python3

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from evidence_common import EvidenceError, read_json, reject_forbidden_outcomes, require_mapping
from validate_evidence_support import validate_document


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate a manual QA observation and its artifact paths.")
    parser.add_argument("--observation", required=True, type=Path)
    parser.add_argument("--schema", default=Path("Tests/ReviewSchemas/manual-observation.schema.json"), type=Path)
    parser.add_argument("--not-before-epoch-ns", type=int)
    args = parser.parse_args()
    try:
        observation = require_mapping(read_json(args.observation.resolve(strict=True)), "observation")
        validate_document(args.schema, observation)
        reject_forbidden_outcomes(observation)
        artifacts = observation.get("artifacts")
        if not isinstance(artifacts, list):
            raise EvidenceError("missing-artifacts", str(args.observation))
        for item in artifacts:
            if not isinstance(item, str) or not Path(item).is_absolute() or not Path(item).resolve(strict=True).is_file():
                raise EvidenceError("invalid-artifact", str(item))
            if args.not_before_epoch_ns is not None and Path(item).stat().st_mtime_ns < args.not_before_epoch_ns:
                raise EvidenceError("stale-artifact", item)
    except (EvidenceError, OSError) as error:
        code = error.code if isinstance(error, EvidenceError) else "io-error"
        print(f"ERROR[{code}]: {error}", file=sys.stderr)
        return 2
    print("PASS: manual QA observation validated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
