#!/usr/bin/env python3

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

from evidence_common import EvidenceError, JsonValue, exclusive_json, read_json, require_mapping, sha256_file


MATCHERS = (r"URLSession", r"NWConnection", r"CFNetwork", r"https?://", r"connect\$", r"socket\$")


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit one exact executable for static network indicators.")
    parser.add_argument("--app", required=True, type=Path)
    parser.add_argument("--allowlist", required=True, type=Path)
    parser.add_argument("--receipt", required=True, type=Path)
    args = parser.parse_args()
    try:
        app = args.app.resolve(strict=True)
        allowlist = require_mapping(read_json(args.allowlist.resolve(strict=True)), "allowlist")
        approved = allowlist.get("entries")
        if not isinstance(approved, list):
            raise EvidenceError("invalid-allowlist", str(args.allowlist))
        approved_matchers = {entry.get("matcher") for entry in approved if isinstance(entry, dict)}
        strings = subprocess.run(["strings", str(app)], check=False, capture_output=True, text=True)
        if strings.returncode != 0:
            raise EvidenceError("strings-failed", str(strings.returncode))
        matches = sorted({matcher for matcher in MATCHERS if re.search(matcher, strings.stdout, re.MULTILINE)})
        unknown = [matcher for matcher in matches if matcher not in approved_matchers]
        if unknown:
            raise EvidenceError("unknown-network-match", unknown[0])
        value: JsonValue = {"schemaVersion": 1, "kind": "network-audit", "app": str(app), "appSHA256": sha256_file(app), "allowlistSHA256": sha256_file(args.allowlist.resolve(strict=True)), "matches": matches, "outcome": "PASS"}
        exclusive_json(args.receipt.absolute(), value)
    except (EvidenceError, OSError) as error:
        code = error.code if isinstance(error, EvidenceError) else "io-error"
        print(f"ERROR[{code}]: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
