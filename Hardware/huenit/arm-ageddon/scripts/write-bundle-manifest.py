#!/usr/bin/env python3

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from evidence_common import EvidenceError, JsonValue, canonical_existing, exclusive_json, output_under, sha256_file


def main() -> int:
    parser = argparse.ArgumentParser(description="Write an immutable canonical bundle manifest.")
    parser.add_argument("--bundle", required=True, type=Path)
    parser.add_argument("--root", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    try:
        root = canonical_existing(args.root, "root")
        bundle = canonical_existing(args.bundle, "bundle")
        bundle.relative_to(root)
        output = output_under(root, args.output)
        records: list[JsonValue] = []
        for path in sorted(bundle.rglob("*")):
            if path.is_symlink():
                raise EvidenceError("symlink-entry", str(path))
            if path.is_file():
                records.append({"path": path.relative_to(bundle).as_posix(), "size": path.stat().st_size, "sha256": sha256_file(path)})
        exclusive_json(output, {"schemaVersion": 1, "bundle": str(bundle), "files": records})
    except (EvidenceError, ValueError) as error:
        code = error.code if isinstance(error, EvidenceError) else "path-escape"
        print(f"ERROR[{code}]: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
