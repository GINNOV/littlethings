#!/usr/bin/env python3
"""Move non-immediately-usable corpus sources into amiga_workspace/corpus/not_for_training."""

from __future__ import annotations

import argparse
import csv
import json
import shutil
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path


@dataclass
class RowResult:
    source_rel: str
    curated_rel: str
    reason: str
    has_entry: str
    assemble_rc: int | None


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", default="amiga_workspace/corpus/manifest.tsv")
    parser.add_argument("--raw-root", default="amiga_workspace/corpus/raw")
    parser.add_argument("--not-root", default="amiga_workspace/corpus/not_for_training")
    parser.add_argument(
        "--assembler",
        default="/usr/local/bin/vasmm68k_mot -m68000 -Fhunkexe -kick1hunks -nosym -o '{artifact}' '{source}'",
        help="Assembler command template with {source} and {artifact}",
    )
    parser.add_argument(
        "--reindex-cmd",
        default="python3 amiga_workspace/corpus/scripts/index_raw_sources.py --refresh",
    )
    parser.add_argument("--dry-run", action="store_true")
    return parser.parse_args()


def load_manifest(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        return list(reader)


def can_assemble(source: Path, assembler_template: str, cwd: Path) -> tuple[bool, int]:
    with tempfile.TemporaryDirectory(prefix="miga-asm-check-") as tmp:
        artifact = Path(tmp) / "a.out"
        cmd = assembler_template.format(source=str(source), artifact=str(artifact))
        proc = subprocess.run(cmd, shell=True, cwd=str(cwd), capture_output=True, text=True)
        return proc.returncode == 0, proc.returncode


def ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def prune_empty_dirs(root: Path) -> None:
    for directory in sorted([p for p in root.rglob("*") if p.is_dir()], reverse=True):
        try:
            directory.rmdir()
        except OSError:
            pass


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd().resolve()
    manifest_path = (repo_root / args.manifest).resolve()
    raw_root = (repo_root / args.raw_root).resolve()
    not_root = (repo_root / args.not_root).resolve()

    if not manifest_path.exists():
        raise SystemExit(f"manifest not found: {manifest_path}")
    if not raw_root.exists():
        raise SystemExit(f"raw root not found: {raw_root}")

    rows = load_manifest(manifest_path)
    if not rows:
        print("No rows in manifest. Nothing to quarantine.")
        return 0

    quarantine_results: list[RowResult] = []
    usable_count = 0

    for row in rows:
        source_rel = row["source_rel"]
        curated_rel = row["curated_rel"]
        source_path = (repo_root / source_rel).resolve()
        suffix = source_path.suffix.lower()
        has_entry = row.get("has_entry", "0")

        reason = ""
        assemble_rc: int | None = None

        if suffix not in {".s", ".asm"}:
            reason = "not_runnable_ext"
        elif has_entry != "1":
            reason = "no_entry_hint"
        else:
            ok, rc = can_assemble(source_path, args.assembler, repo_root)
            assemble_rc = rc
            if not ok:
                reason = "assemble_fail"

        if reason:
            quarantine_results.append(
                RowResult(
                    source_rel=source_rel,
                    curated_rel=curated_rel,
                    reason=reason,
                    has_entry=has_entry,
                    assemble_rc=assemble_rc,
                )
            )
        else:
            usable_count += 1

    moved = 0
    if not args.dry_run:
        for item in quarantine_results:
            source_path = (repo_root / item.source_rel).resolve()
            if not source_path.exists():
                continue
            rel_under_raw = source_path.relative_to(raw_root)
            destination = (not_root / "raw" / rel_under_raw).resolve()
            ensure_parent(destination)
            shutil.move(str(source_path), str(destination))
            moved += 1

        prune_empty_dirs(raw_root)

        reindex = subprocess.run(
            args.reindex_cmd,
            shell=True,
            cwd=str(repo_root),
            capture_output=True,
            text=True,
        )
        if reindex.returncode != 0:
            raise SystemExit(
                "Reindex failed after quarantine:\n"
                f"{reindex.stdout}\n{reindex.stderr}"
            )

    report_dir = (not_root / "reports").resolve()
    report_dir.mkdir(parents=True, exist_ok=True)
    report_tsv = report_dir / "quarantine_report.tsv"
    report_json = report_dir / "quarantine_summary.json"

    with report_tsv.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle, delimiter="\t")
        writer.writerow(["source_rel", "curated_rel", "reason", "has_entry", "assemble_rc"])
        for item in quarantine_results:
            writer.writerow([item.source_rel, item.curated_rel, item.reason, item.has_entry, item.assemble_rc])

    try:
        report_tsv_rel = str(report_tsv.relative_to(repo_root))
    except ValueError:
        report_tsv_rel = str(report_tsv)

    summary = {
        "total_rows": len(rows),
        "usable_rows": usable_count,
        "quarantined_rows": len(quarantine_results),
        "moved_files": moved,
        "dry_run": args.dry_run,
        "report_tsv": report_tsv_rel,
    }
    report_json.write_text(json.dumps(summary, indent=2), encoding="utf-8")

    print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
