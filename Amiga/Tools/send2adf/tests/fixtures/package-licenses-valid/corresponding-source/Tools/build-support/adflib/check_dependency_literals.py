#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 check_dependency_literals.py --root /absolute/path/to/Amiga

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

MANIFEST_PATTERN = re.compile(r'^set\((ADFLIB_[A-Z0-9_]+) "([^"]*)"\)$')
AUTHORITY_PATTERN = re.compile(
    r"(?:PINNED_(?:VERSION|TAG|COMMIT|TREE|MANIFEST|URL)|ADFLIB_(?:VERSION|TAG|COMMIT|TREE_SHA|ARCHIVE_URL|TREE_MANIFEST_SHA256))"
)
TEXT_SUFFIXES = {".c", ".cmake", ".h", ".json", ".py", ".sh", ".swift", ".yaml", ".yml"}


def manifest_values(path: Path) -> set[str]:
    values: set[str] = set()
    for line in path.read_text(encoding="utf-8").splitlines():
        match = MANIFEST_PATTERN.fullmatch(line)
        if match is not None and match.group(1) in {
            "ADFLIB_VERSION",
            "ADFLIB_TAG",
            "ADFLIB_COMMIT",
            "ADFLIB_TREE_SHA",
            "ADFLIB_ARCHIVE_URL",
            "ADFLIB_TREE_MANIFEST_SHA256",
        }:
            values.add(match.group(2))
    return values


def is_allowed(path: Path, manifest: Path) -> bool:
    if path == manifest or "/tests/" in path.as_posix():
        return True
    return path.name == "ADFlibLicenseApprovals.json"


def violations(root: Path) -> list[str]:
    manifest = root / "Tools/build-support/adflib/ADFlibDependency.cmake"
    identities = manifest_values(manifest)
    found: list[str] = []
    for path in sorted((root / "Tools").rglob("*")):
        if not path.is_file() or path.suffix not in TEXT_SUFFIXES or is_allowed(path, manifest):
            continue
        if any(part in {"build", ".artifacts", "__pycache__"} for part in path.parts):
            continue
        try:
            lines = path.read_text(encoding="utf-8").splitlines()
        except UnicodeDecodeError:
            continue
        for line_number, line in enumerate(lines, start=1):
            if AUTHORITY_PATTERN.search(line) and any(identity in line for identity in identities):
                found.append(f"{path.relative_to(root)}:{line_number}:authoritative_adflib_literal")
    return found


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    arguments = parser.parse_args()
    found = violations(arguments.root.resolve())
    if found:
        print("\n".join(found), file=sys.stderr)
        return 2
    print("dependency_literal_check_ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
