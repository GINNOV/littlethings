#!/usr/bin/env python3

from __future__ import annotations

import argparse
import stat
import sys
from pathlib import Path

from evidence_common import EvidenceError, JsonValue, exclusive_json, output_under, sha256_file


def entries(root: Path, output: Path) -> list[JsonValue]:
    values: list[JsonValue] = []
    for path in sorted(root.rglob("*")):
        if path == output:
            continue
        if path.is_symlink():
            raise EvidenceError("symlink-entry", str(path))
        if not path.is_file():
            continue
        info = path.stat()
        values.append({"path": path.relative_to(root).as_posix(), "mode": stat.S_IMODE(info.st_mode), "size": info.st_size, "sha256": sha256_file(path)})
    return values


def main() -> int:
    parser = argparse.ArgumentParser(description="Write an immutable canonical Merkle manifest.")
    parser.add_argument("--root", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    try:
        root = args.root.resolve(strict=True)
        if not root.is_dir() or root.is_symlink():
            raise EvidenceError("invalid-root", str(args.root))
        output = output_under(root, args.output)
        exclusive_json(output, {"schemaVersion": 1, "root": str(root), "entries": entries(root, output)})
    except EvidenceError as error:
        print(f"ERROR[{error.code}]: {error.detail}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
