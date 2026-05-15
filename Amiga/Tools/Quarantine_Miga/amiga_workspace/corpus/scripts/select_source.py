#!/usr/bin/env python3
"""Select one curated corpus source file and copy it into amiga_workspace/main.s."""

from __future__ import annotations

import argparse
import csv
import json
import random
from datetime import datetime, UTC
from pathlib import Path

DEFAULT_MANIFEST = Path("amiga_workspace/corpus/manifest.tsv")
RUNNABLE_MANIFEST = Path("amiga_workspace/corpus/manifest_runnable.tsv")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--manifest",
        default="",
        help=(
            "TSV manifest path. Default: use amiga_workspace/corpus/manifest_runnable.tsv when present, "
            "otherwise fallback to amiga_workspace/corpus/manifest.tsv"
        ),
    )
    parser.add_argument("--target", default="amiga_workspace/main.s", help="Target source file")
    parser.add_argument(
        "--contains",
        default="",
        help="Optional case-insensitive path filter applied to source_rel and curated_rel",
    )
    parser.add_argument("--index", type=int, default=0, help="1-based manifest entry index")
    parser.add_argument("--seed", type=int, default=0, help="Seed for deterministic random selection")
    parser.add_argument(
        "--allow-includes",
        action="store_true",
        help="Allow selecting .i/.inc include files (default picks only .s/.asm)",
    )
    parser.add_argument(
        "--allow-nonentry",
        action="store_true",
        help="Allow selecting files without _start/start entry hints",
    )
    parser.add_argument(
        "--metadata",
        default="build/amiga/selected_source.json",
        help="Where to write selection metadata",
    )
    return parser.parse_args()


def load_manifest(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        return list(reader)


def resolve_manifest_path(repo_root: Path, manifest_arg: str) -> tuple[Path, str]:
    if manifest_arg:
        return (repo_root / manifest_arg).resolve(), "explicit"

    runnable = (repo_root / RUNNABLE_MANIFEST).resolve()
    if runnable.exists():
        return runnable, "runnable_default"

    return (repo_root / DEFAULT_MANIFEST).resolve(), "fallback_default"


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd()
    manifest_path, manifest_mode = resolve_manifest_path(repo_root, args.manifest)
    target_path = (repo_root / args.target).resolve()
    metadata_path = (repo_root / args.metadata).resolve()

    if not manifest_path.exists():
        raise SystemExit(
            f"manifest not found: {manifest_path}\n"
            "run amiga_workspace/corpus/scripts/index_raw_sources.py first"
        )

    rows = load_manifest(manifest_path)
    if not rows:
        raise SystemExit(f"manifest has no entries: {manifest_path}")

    if not args.allow_includes:
        rows = [
            row
            for row in rows
            if Path(row["source_rel"]).suffix.lower() in {".s", ".asm"}
        ]
        if not rows:
            raise SystemExit("no runnable (.s/.asm) entries in manifest")

    if not args.allow_nonentry:
        rows = [row for row in rows if row.get("has_entry", "0") == "1"]
        if not rows:
            raise SystemExit("no entrypoint-hint files in manifest (use --allow-nonentry to override)")

    if args.contains:
        needle = args.contains.lower()
        rows = [
            row
            for row in rows
            if needle in row["source_rel"].lower() or needle in row["curated_rel"].lower()
        ]
        if not rows:
            raise SystemExit(f"no entries match filter: {args.contains!r}")

    if args.index > 0:
        if args.index > len(rows):
            raise SystemExit(f"index {args.index} out of range (1..{len(rows)})")
        chosen = rows[args.index - 1]
    else:
        rng = random.Random(args.seed if args.seed != 0 else None)
        chosen = rng.choice(rows)

    chosen_source = (repo_root / chosen["curated_rel"]).resolve()
    if not chosen_source.exists():
        raise SystemExit(f"chosen file missing: {chosen_source}")

    text = chosen_source.read_text(encoding="utf-8", errors="replace")
    if not text.endswith("\n"):
        text += "\n"

    target_path.parent.mkdir(parents=True, exist_ok=True)
    target_path.write_text(text, encoding="utf-8")

    metadata = {
        "selected_at": datetime.now(UTC).isoformat(),
        "manifest": str(manifest_path),
        "manifest_mode": manifest_mode,
        "target": str(target_path),
        "entry": chosen,
        "filter": args.contains,
        "index_arg": args.index,
        "seed_arg": args.seed,
    }
    metadata_path.parent.mkdir(parents=True, exist_ok=True)
    metadata_path.write_text(json.dumps(metadata, indent=2), encoding="utf-8")

    print(f"manifest: {manifest_path}")
    print(f"selected: {chosen['id']} {chosen['source_rel']}")
    print(f"copied_to: {target_path}")
    print(f"metadata: {metadata_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
