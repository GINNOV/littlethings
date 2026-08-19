#!/usr/bin/env python3

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from evidence_common import EvidenceError, read_json, require_mapping, sha256_file


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate scope launch, ready, release, and trace bindings.")
    parser.add_argument("--launch", required=True, type=Path)
    parser.add_argument("--ready", required=True, type=Path)
    parser.add_argument("--release", required=True, type=Path)
    parser.add_argument("--trace", required=True, type=Path)
    args = parser.parse_args()
    try:
        launch_path = args.launch.resolve(strict=True)
        ready = require_mapping(read_json(args.ready.resolve(strict=True)), "ready")
        release = require_mapping(read_json(args.release.resolve(strict=True)), "release")
        trace = args.trace.resolve(strict=True)
        if ready.get("launchSHA256") != sha256_file(launch_path):
            raise EvidenceError("launch-hash-mismatch", str(launch_path))
        prerequisites = release.get("prerequisites")
        if not isinstance(prerequisites, list) or not any(isinstance(item, dict) and item.get("sha256") == sha256_file(args.ready.resolve(strict=True)) for item in prerequisites):
            raise EvidenceError("ready-prerequisite-missing", str(args.ready))
        if trace.stat().st_size == 0:
            raise EvidenceError("empty-trace", str(trace))
    except (EvidenceError, OSError) as error:
        code = error.code if isinstance(error, EvidenceError) else "io-error"
        print(f"ERROR[{code}]: {error}", file=sys.stderr)
        return 2
    print("PASS: scope evidence validated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
