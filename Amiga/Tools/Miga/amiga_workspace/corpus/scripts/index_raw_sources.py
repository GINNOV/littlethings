#!/usr/bin/env python3
"""Index and curate assembly-like source files from amiga_workspace/corpus/raw."""

from __future__ import annotations

import argparse
import csv
import hashlib
import shutil
from dataclasses import dataclass
from pathlib import Path
import re

SOURCE_EXTS = {".s", ".asm", ".i", ".inc"}
EXCLUDED_DIR_NAMES = {
    ".git",
    ".hg",
    ".svn",
    "node_modules",
    "build",
    "bin",
    "obj",
    "dist",
    ".vscode",
    "screenshots",
    "assets",
    "docs",
}
MAX_FILE_BYTES = 512 * 1024
ASM_HINT_RE = re.compile(
    r"\b(section|xdef|equ|dc\.|ds\.|lea|move\.|moveq|bra|bsr|jmp|jsr|rts|rte|a[0-7]|d[0-7])\b",
    re.IGNORECASE,
)


@dataclass
class Entry:
    id: int
    source_rel: str
    curated_rel: str
    bytes: int
    lines: int
    sha1: str
    has_entry: int
    has_section: int


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--raw", default="amiga_workspace/corpus/raw", help="Raw corpus root")
    parser.add_argument("--curated", default="amiga_workspace/corpus/curated", help="Curated corpus root")
    parser.add_argument(
        "--manifest",
        default="amiga_workspace/corpus/manifest.tsv",
        help="Output TSV manifest path",
    )
    parser.add_argument(
        "--refresh",
        action="store_true",
        help="Delete curated directory before indexing",
    )
    return parser.parse_args()


def is_excluded(rel_path: Path) -> bool:
    return any(part in EXCLUDED_DIR_NAMES for part in rel_path.parts)


def read_text(path: Path) -> str | None:
    raw = path.read_bytes()
    if len(raw) > MAX_FILE_BYTES:
        return None
    if b"\x00" in raw:
        return None
    try:
        return raw.decode("utf-8")
    except UnicodeDecodeError:
        try:
            return raw.decode("latin-1")
        except UnicodeDecodeError:
            return None


def looks_like_assembly(text: str) -> bool:
    return ASM_HINT_RE.search(text) is not None


def has_entry_hint(text: str) -> bool:
    return re.search(r"^\s*(xdef\s+_start|_start:|start:)", text, re.IGNORECASE | re.MULTILINE) is not None


def has_section_hint(text: str) -> bool:
    return re.search(r"^\s*section\b", text, re.IGNORECASE | re.MULTILINE) is not None


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd()
    raw_root = (repo_root / args.raw).resolve()
    curated_root = (repo_root / args.curated).resolve()
    manifest_path = (repo_root / args.manifest).resolve()

    if not raw_root.exists():
        raise SystemExit(f"raw corpus directory not found: {raw_root}")

    if args.refresh and curated_root.exists():
        shutil.rmtree(curated_root)
    curated_root.mkdir(parents=True, exist_ok=True)

    entries: list[Entry] = []
    skipped_ext = 0
    skipped_non_text = 0
    skipped_non_asm = 0

    for source_path in sorted(raw_root.rglob("*")):
        if not source_path.is_file():
            continue

        rel = source_path.relative_to(raw_root)
        if is_excluded(rel):
            continue

        if source_path.suffix.lower() not in SOURCE_EXTS:
            skipped_ext += 1
            continue

        text = read_text(source_path)
        if text is None:
            skipped_non_text += 1
            continue

        if not looks_like_assembly(text):
            skipped_non_asm += 1
            continue

        source_rel = str(source_path.relative_to(repo_root))
        curated_rel = str(Path(args.curated) / rel)
        curated_path = (repo_root / curated_rel).resolve()
        curated_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source_path, curated_path)

        data = text.encode("utf-8", errors="replace")
        sha1 = hashlib.sha1(data).hexdigest()
        line_count = text.count("\n") + (1 if text and not text.endswith("\n") else 0)

        entries.append(
            Entry(
                id=len(entries) + 1,
                source_rel=source_rel,
                curated_rel=curated_rel,
                bytes=len(data),
                lines=line_count,
                sha1=sha1,
                has_entry=1 if has_entry_hint(text) else 0,
                has_section=1 if has_section_hint(text) else 0,
            )
        )

    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    with manifest_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle, delimiter="\t")
        writer.writerow(
            ["id", "source_rel", "curated_rel", "bytes", "lines", "sha1", "has_entry", "has_section"]
        )
        for e in entries:
            writer.writerow(
                [e.id, e.source_rel, e.curated_rel, e.bytes, e.lines, e.sha1, e.has_entry, e.has_section]
            )

    print(f"indexed: {len(entries)}")
    print(f"manifest: {manifest_path}")
    print(f"curated: {curated_root}")
    print(f"skipped_ext: {skipped_ext}")
    print(f"skipped_non_text: {skipped_non_text}")
    print(f"skipped_non_asm: {skipped_non_asm}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
