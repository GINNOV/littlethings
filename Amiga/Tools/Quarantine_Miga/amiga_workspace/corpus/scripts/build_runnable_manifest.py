#!/usr/bin/env python3
"""Build a manifest containing only sources that pass assemble + vamos verify."""

from __future__ import annotations

import argparse
import csv
import json
import os
import shutil
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path


DEFAULT_ASSEMBLER = "vasmm68k_mot -m68000 -Fhunkexe -kick1hunks -nosym -o '{artifact}' '{source}'"


@dataclass
class ValidationResult:
    row: dict[str, str]
    assemble_rc: int | None
    verify_rc: int | None
    runnable: bool
    reason: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", default="amiga_workspace/corpus/manifest.tsv")
    parser.add_argument("--output", default="amiga_workspace/corpus/manifest_runnable.tsv")
    parser.add_argument(
        "--report-json",
        default="amiga_workspace/corpus/manifest_runnable_report.json",
        help="Summary/report JSON output path",
    )
    parser.add_argument(
        "--assembler",
        default=DEFAULT_ASSEMBLER,
        help="Assembler command template with {source} and {artifact}",
    )
    parser.add_argument(
        "--vamos",
        default="",
        help="Path to vamos binary (default: $VAMOS, then $AMIGA_TOOLS_BIN/vamos, then PATH)",
    )
    parser.add_argument(
        "--verify-timeout",
        type=float,
        default=10.0,
        help="Per-source timeout in seconds for vamos verification",
    )
    parser.add_argument(
        "--allow-nonentry",
        action="store_true",
        help="Allow sources without manifest has_entry=1",
    )
    parser.add_argument(
        "--allow-includes",
        action="store_true",
        help="Allow non .s/.asm files",
    )
    parser.add_argument(
        "--keep-temp",
        action="store_true",
        help="Keep temp directories for debugging",
    )
    return parser.parse_args()


def load_manifest(path: Path) -> tuple[list[str], list[dict[str, str]]]:
    with path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        rows = list(reader)
        return (reader.fieldnames or []), rows


def resolve_vamos_path(arg_value: str) -> str:
    if arg_value:
        return arg_value

    env_vamos = os.environ.get("VAMOS", "").strip()
    if env_vamos:
        return env_vamos

    home_default = Path.home() / ".venv" / "bin" / "vamos"
    if home_default.exists():
        return str(home_default)

    tools_bin = os.environ.get("AMIGA_TOOLS_BIN", "").strip()
    if tools_bin:
        candidate = Path(tools_bin) / "vamos"
        if candidate.exists():
            return str(candidate)

    found = shutil.which("vamos")
    if found:
        return found

    return ""


def run_assemble(
    repo_root: Path,
    source_path: Path,
    temp_dir: Path,
    assembler_template: str,
) -> tuple[int, str]:
    artifact_path = temp_dir / "main"
    cmd = assembler_template.format(source=str(source_path), artifact=str(artifact_path))
    proc = subprocess.run(
        cmd,
        shell=True,
        cwd=str(repo_root),
        capture_output=True,
        text=True,
    )
    return proc.returncode, str(artifact_path)


def run_verify(vamos_path: str, temp_dir: Path, timeout: float) -> int:
    vols_dir = temp_dir / "vamos-vols"
    vols_dir.mkdir(parents=True, exist_ok=True)
    cmd = [
        vamos_path,
        "--skip-configs",
        "--vols-base-dir",
        str(vols_dir),
        "-V",
        f"root:{temp_dir}",
        "-p",
        "root:",
        "--cwd",
        "root:",
        "-H",
        "ignore",
        "root:main",
    ]
    try:
        proc = subprocess.run(
            cmd,
            cwd=str(temp_dir),
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
        return int(proc.returncode)
    except subprocess.TimeoutExpired:
        return 124


def write_manifest(path: Path, fieldnames: list[str], rows: list[dict[str, str]]) -> None:
    output_fields = list(fieldnames)
    for extra in ("assemble_rc", "verify_rc", "runnable", "runnable_reason"):
        if extra not in output_fields:
            output_fields.append(extra)

    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, delimiter="\t", fieldnames=output_fields)
        writer.writeheader()
        for row in rows:
            writer.writerow(row)


def main() -> int:
    args = parse_args()
    repo_root = Path.cwd().resolve()
    manifest_path = (repo_root / args.manifest).resolve()
    output_path = (repo_root / args.output).resolve()
    report_json_path = (repo_root / args.report_json).resolve()

    if not manifest_path.exists():
        raise SystemExit(f"manifest not found: {manifest_path}")

    vamos_path = resolve_vamos_path(args.vamos)
    if not vamos_path:
        raise SystemExit(
            "unable to locate 'vamos' (set --vamos, $VAMOS, or $AMIGA_TOOLS_BIN)"
        )

    fieldnames, rows = load_manifest(manifest_path)
    if not rows:
        raise SystemExit(f"manifest has no entries: {manifest_path}")

    results: list[ValidationResult] = []
    runnable_rows: list[dict[str, str]] = []

    for idx, row in enumerate(rows, start=1):
        source_rel = row.get("source_rel", "")
        curated_rel = row.get("curated_rel", "")
        source_path = (repo_root / curated_rel).resolve() if curated_rel else Path()
        suffix = source_path.suffix.lower()
        has_entry = row.get("has_entry", "0")

        assemble_rc: int | None = None
        verify_rc: int | None = None
        runnable = False
        reason = ""

        if not source_path.exists():
            reason = "missing_curated_source"
        elif not args.allow_includes and suffix not in {".s", ".asm"}:
            reason = "non_runnable_extension"
        elif not args.allow_nonentry and has_entry != "1":
            reason = "no_entry_hint"
        else:
            if args.keep_temp:
                temp_dir = Path(tempfile.mkdtemp(prefix="miga-runnable-"))
                assemble_rc, artifact = run_assemble(
                    repo_root=repo_root,
                    source_path=source_path,
                    temp_dir=temp_dir,
                    assembler_template=args.assembler,
                )

                if assemble_rc != 0:
                    reason = "assemble_fail"
                elif not Path(artifact).exists():
                    reason = "missing_artifact"
                else:
                    verify_rc = run_verify(
                        vamos_path=vamos_path,
                        temp_dir=temp_dir,
                        timeout=args.verify_timeout,
                    )
                    if verify_rc == 0:
                        runnable = True
                        reason = "ok"
                    elif verify_rc == 124:
                        reason = "verify_timeout"
                    else:
                        reason = "verify_nonzero_exit"
            else:
                with tempfile.TemporaryDirectory(prefix="miga-runnable-") as temp_dir_str:
                    temp_dir = Path(temp_dir_str)
                    assemble_rc, artifact = run_assemble(
                        repo_root=repo_root,
                        source_path=source_path,
                        temp_dir=temp_dir,
                        assembler_template=args.assembler,
                    )

                    if assemble_rc != 0:
                        reason = "assemble_fail"
                    elif not Path(artifact).exists():
                        reason = "missing_artifact"
                    else:
                        verify_rc = run_verify(
                            vamos_path=vamos_path,
                            temp_dir=temp_dir,
                            timeout=args.verify_timeout,
                        )
                        if verify_rc == 0:
                            runnable = True
                            reason = "ok"
                        elif verify_rc == 124:
                            reason = "verify_timeout"
                        else:
                            reason = "verify_nonzero_exit"

        results.append(
            ValidationResult(
                row=row,
                assemble_rc=assemble_rc,
                verify_rc=verify_rc,
                runnable=runnable,
                reason=reason,
            )
        )

        status = "runnable" if runnable else f"skip ({reason})"
        print(f"[{idx}/{len(rows)}] {source_rel or curated_rel}: {status}")

        if runnable:
            out_row = dict(row)
            out_row["assemble_rc"] = str(assemble_rc if assemble_rc is not None else "")
            out_row["verify_rc"] = str(verify_rc if verify_rc is not None else "")
            out_row["runnable"] = "1"
            out_row["runnable_reason"] = reason
            runnable_rows.append(out_row)

    write_manifest(output_path, fieldnames, runnable_rows)

    summary = {
        "manifest": str(manifest_path),
        "output": str(output_path),
        "report_json": str(report_json_path),
        "total_rows": len(rows),
        "runnable_rows": len(runnable_rows),
        "skipped_rows": len(rows) - len(runnable_rows),
        "vamos": vamos_path,
        "verify_timeout": args.verify_timeout,
        "reasons": {},
    }

    reason_counts: dict[str, int] = {}
    for item in results:
        reason_counts[item.reason] = reason_counts.get(item.reason, 0) + 1
    summary["reasons"] = reason_counts

    report_json_path.parent.mkdir(parents=True, exist_ok=True)
    report_json_path.write_text(json.dumps(summary, indent=2), encoding="utf-8")

    print(json.dumps(summary, indent=2))

    if len(runnable_rows) == 0:
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
