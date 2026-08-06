#!/usr/bin/env python3
"""Minimal sealed-style ASM scorer (no reliability.campaign_* dependency).

Self-contained so multi-agent collisions on reliability/ cannot block scoring.

Pipeline per case:
  1) MLX generate first-shot (temp=0) with given adapter
  2) Extract + Motorola-format (tabs for directives/ops)
  3) TargetGateCLI compile  OR  vasmm68k_mot -Fhunkexe fallback
  4) Aggregate per-family pass/fail (threshold 18/20)

Usage:
  cd aMiLa/fine_tuning
  uv run python tools/minimal_sealed_asm.py \\
    --adapter runtime/adapter \\
    --output-dir /tmp/asm-score \\
    --limit 0

--limit 0 means all ASM cases (140). Use --limit 14 for a quick probe.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
import time
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]  # aMiLa/fine_tuning
DEFAULT_BENCHMARK = Path(__file__).resolve().parent / "fixtures" / "benchmark.json"
DEFAULT_GATE_CONFIG = Path(__file__).resolve().parent / "fixtures" / "target-gates.json"
DEFAULT_MODEL = Path.home() / (
    ".cache/huggingface/hub/models--mlx-community--Qwen2.5-Coder-3B-Instruct-4bit/"
    "snapshots/3dd939c621c08e5753d5b89f35a2642cd83b98ca"
)
DEFAULT_TG = (
    Path(__file__).resolve().parents[2]
    / "AmigaPlayground/.build/arm64-apple-macosx/debug/TargetGateCLI"
)
THRESHOLD = 18
SEEDS_NOTE = "benchmark case seeds; generation temperature forced to 0"


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_text(text: str) -> str:
    return sha256_bytes(text.encode())


def motorola_format(source: str) -> str:
    """Labels at column 0; directives and instructions tab-indented."""
    lines_out: list[str] = []
    for raw in source.splitlines():
        line = raw.rstrip()
        if not line.strip():
            lines_out.append("")
            continue
        stripped = line.strip()
        if stripped.startswith(";") or stripped.startswith("*"):
            lines_out.append(stripped)
            continue
        m = re.match(r"^([A-Za-z_@.][\w@.]*)\s*:(.*)$", stripped)
        if m:
            label, rest = m.group(1), m.group(2).strip()
            lines_out.append(f"{label}:")
            if rest:
                lines_out.append(f"\t{rest}")
            continue
        lines_out.append(f"\t{stripped}")
    body = "\n".join(lines_out).strip() + "\n"
    if not re.search(r"(?im)^\s*section\b", body):
        body = "\tSECTION\tCode,CODE\n" + body
    return body


def extract_asm(text: str) -> str:
    m = re.search(r"```(?:asm|assembly|68000)?\s*([\s\S]*?)```", text, re.I)
    if m:
        return m.group(1).strip() + "\n"
    lines = text.splitlines()
    start = 0
    for i, line in enumerate(lines):
        if re.match(
            r"^\s*(SECTION|XDEF|XREF|_Main|_Entry|[A-Za-z_][\w.]*:)",
            line,
            re.I,
        ):
            start = i
            break
    return "\n".join(lines[start:]).strip() + "\n"


def vasm_fhunkexe(source_path: Path, out_path: Path) -> dict[str, Any]:
    proc = subprocess.run(
        [
            "vasmm68k_mot",
            "-m68000",
            "-Fhunkexe",
            "-o",
            str(out_path),
            str(source_path),
        ],
        capture_output=True,
        text=True,
        timeout=30,
    )
    ok = proc.returncode == 0 and out_path.is_file() and out_path.stat().st_size > 0
    return {
        "tool": "vasmm68k_mot",
        "outcome": "PASS" if ok else "FAIL",
        "process_exit": proc.returncode,
        "stdout": proc.stdout[-2000:],
        "stderr": proc.stderr[-2000:],
        "binary": str(out_path) if ok else None,
    }


def target_gate_compile(
    tg: Path,
    config: Path,
    source: Path,
    out_dir: Path,
) -> dict[str, Any]:
    out_dir.mkdir(parents=True, exist_ok=True)
    proc = subprocess.run(
        [
            str(tg),
            "compile",
            "--config",
            str(config),
            "--language",
            "asm",
            "--output-dir",
            str(out_dir),
            "--source",
            str(source),
        ],
        capture_output=True,
        text=True,
        timeout=60,
    )
    try:
        payload = json.loads(proc.stdout or "{}")
    except json.JSONDecodeError:
        payload = {
            "outcome": "FAIL",
            "error": "non-json stdout",
            "stdout": proc.stdout[-1000:],
            "stderr": proc.stderr[-1000:],
            "process_exit": proc.returncode,
        }
    if "outcome" not in payload:
        payload["outcome"] = "FAIL" if proc.returncode != 0 else "PASS"
    payload["process_exit"] = proc.returncode
    return payload


def load_model(model_path: Path, adapter_path: Path):
    from mlx_lm import load
    from mlx_lm.sample_utils import make_sampler

    model, tokenizer = load(str(model_path), adapter_path=str(adapter_path))
    sampler = make_sampler(temp=0.0)
    return model, tokenizer, sampler


def generate_one(model, tokenizer, sampler, prompt: str, max_tokens: int = 512) -> str:
    from mlx_lm import generate

    messages = [{"role": "user", "content": prompt}]
    if hasattr(tokenizer, "apply_chat_template"):
        prompt_text = tokenizer.apply_chat_template(
            messages, tokenize=False, add_generation_prompt=True
        )
    else:
        prompt_text = prompt
    out = generate(
        model,
        tokenizer,
        prompt=prompt_text,
        max_tokens=max_tokens,
        sampler=sampler,
        verbose=False,
    )
    text = out if isinstance(out, str) else str(out)
    if prompt_text in text:
        text = text.split(prompt_text, 1)[-1]
    return text


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--benchmark", type=Path, default=DEFAULT_BENCHMARK)
    ap.add_argument("--gate-config", type=Path, default=DEFAULT_GATE_CONFIG)
    ap.add_argument("--model", type=Path, default=DEFAULT_MODEL)
    ap.add_argument("--adapter", type=Path, required=True)
    ap.add_argument("--output-dir", type=Path, required=True)
    ap.add_argument("--target-gate-cli", type=Path, default=DEFAULT_TG)
    ap.add_argument("--limit", type=int, default=0, help="0 = all ASM cases")
    ap.add_argument("--max-tokens", type=int, default=512)
    ap.add_argument(
        "--compile-backend",
        choices=("target-gate", "vasm", "both"),
        default="both",
    )
    args = ap.parse_args()

    out: Path = args.output_dir
    if out.exists() and any(out.iterdir()):
        print(f"output-dir must be empty/fresh: {out}", file=sys.stderr)
        return 2
    out.mkdir(parents=True, exist_ok=True)
    (out / "raw").mkdir()
    (out / "source").mkdir()
    (out / "compile").mkdir()
    (out / "cases").mkdir()

    bench = json.loads(args.benchmark.read_text())
    cases = [c for c in bench["cases"] if c.get("language") == "asm"]
    if args.limit and args.limit > 0:
        cases = cases[: args.limit]

    meta = {
        "schema_version": 1,
        "harness": "minimal_sealed_asm",
        "started_utc": datetime.now(timezone.utc).isoformat(),
        "benchmark": str(args.benchmark.resolve()),
        "benchmark_sha256": sha256_bytes(args.benchmark.read_bytes()),
        "adapter": str(args.adapter.resolve()),
        "model": str(args.model.resolve()),
        "case_count": len(cases),
        "threshold": THRESHOLD,
        "generation": {
            "temperature": 0.0,
            "max_tokens": args.max_tokens,
            "repairs": 0,
            "first_shot_only": True,
        },
        "compile_backend": args.compile_backend,
        "notes": SEEDS_NOTE,
    }
    (out / "run-meta.json").write_text(json.dumps(meta, indent=2) + "\n")

    print(f"Loading model + adapter ({len(cases)} cases)…", flush=True)
    model, tokenizer, sampler = load_model(args.model, args.adapter)
    print("Loaded.", flush=True)

    use_tg = args.compile_backend in ("target-gate", "both") and args.target_gate_cli.is_file()
    family_stats: dict[str, Counter[str]] = defaultdict(Counter)
    results: list[dict[str, Any]] = []
    t0 = time.time()

    for i, case in enumerate(cases, 1):
        case_id = case["case_id"]
        family = case["family"]
        prompt = case["prompt"]
        # encourage format that sealed VASM accepts
        prompt_fmt = (
            prompt
            + "\n\nOutput only Motorola 68000 assembly for vasm. "
            "Put SECTION, XDEF, and instructions with a leading tab. "
            "Labels end with colon at column 0. No prose."
        )
        print(f"[{i}/{len(cases)}] {case_id}", flush=True)
        try:
            gen_text = generate_one(
                model, tokenizer, sampler, prompt_fmt, max_tokens=args.max_tokens
            )
        except Exception as exc:  # noqa: BLE001 — harness must not die mid-run
            gen_text = f"; GENERATION_ERROR: {exc}\n"

        raw_path = out / "raw" / f"{case_id}.txt"
        raw_path.write_text(gen_text)
        asm = motorola_format(extract_asm(gen_text))
        src_path = out / "source" / f"{case_id}.s"
        src_path.write_text(asm)

        compile_dir = out / "compile" / case_id
        compile_dir.mkdir(parents=True, exist_ok=True)
        compile_result: dict[str, Any]
        if use_tg:
            compile_result = target_gate_compile(
                args.target_gate_cli,
                args.gate_config.resolve(),
                src_path.resolve(),
                compile_dir.resolve(),
            )
        else:
            compile_result = vasm_fhunkexe(src_path, compile_dir / "program.hunk")

        # Optional dual check
        if args.compile_backend == "both":
            vasm_res = vasm_fhunkexe(src_path, compile_dir / "program.vasm.hunk")
            compile_result["vasm_direct"] = vasm_res

        outcome = str(compile_result.get("outcome", "FAIL")).upper()
        passed = outcome == "PASS"
        family_stats[family]["total"] += 1
        family_stats[family]["passed" if passed else "failed"] += 1

        case_rec = {
            "case_id": case_id,
            "family": family,
            "seed": case.get("generation", {}).get("seed"),
            "variant_index": case.get("variant_index"),
            "prompt_sha256": sha256_text(prompt),
            "raw_sha256": sha256_bytes(gen_text.encode()),
            "source_sha256": sha256_bytes(asm.encode()),
            "compile_outcome": outcome,
            "compile": compile_result,
        }
        (out / "cases" / f"{case_id}.json").write_text(
            json.dumps(case_rec, indent=2) + "\n"
        )
        results.append(case_rec)

    families = []
    causes: list[str] = []
    for family, stats in sorted(family_stats.items()):
        total = stats["total"]
        passed = stats["passed"]
        failed = stats["failed"]
        threshold_met = passed >= THRESHOLD
        critical_veto = passed == 0  # zero-pass family is a hard fail signal
        families.append(
            {
                "family": family,
                "total": total,
                "passed": passed,
                "failed": failed,
                "blocked": 0,
                "threshold_met": threshold_met,
                "critical_veto": critical_veto,
            }
        )
        if not threshold_met:
            causes.append(f"threshold:{family}")
        if critical_veto:
            causes.append(f"critical_veto:{family}")

    eligible = all(f["threshold_met"] and not f["critical_veto"] for f in families) and bool(
        families
    )
    report = {
        "schema_version": 1,
        "harness": "minimal_sealed_asm",
        "finished_utc": datetime.now(timezone.utc).isoformat(),
        "elapsed_seconds": round(time.time() - t0, 1),
        "eligible": eligible,
        "threshold": THRESHOLD,
        "families": families,
        "causes": causes,
        "case_count": len(results),
        "pass_count": sum(1 for r in results if r["compile_outcome"] == "PASS"),
        "fail_count": sum(1 for r in results if r["compile_outcome"] != "PASS"),
        "adapter": str(args.adapter.resolve()),
        "adapter_sha256": sha256_bytes(
            (args.adapter / "adapters.safetensors").read_bytes()
        )
        if (args.adapter / "adapters.safetensors").is_file()
        else None,
    }
    (out / "scoreboard.json").write_text(json.dumps(report, indent=2) + "\n")

    # Markdown scoreboard
    lines = [
        "# Minimal sealed ASM scoreboard",
        "",
        f"**Eligible:** `{eligible}`",
        f"**Pass/Fail:** {report['pass_count']}/{report['case_count']}",
        f"**Adapter:** `{report.get('adapter_sha256')}`",
        f"**Elapsed:** {report['elapsed_seconds']}s",
        "",
        "| Family | Pass | Fail | 18/20 |",
        "|--------|-----:|-----:|------:|",
    ]
    for f in families:
        lines.append(
            f"| {f['family']} | {f['passed']} | {f['failed']} | "
            f"{'YES' if f['threshold_met'] else 'NO'} |"
        )
    lines.append("")
    (out / "scoreboard.md").write_text("\n".join(lines) + "\n")

    print(json.dumps({k: report[k] for k in ("eligible", "pass_count", "fail_count", "families")}, indent=2))
    print(f"Wrote {out / 'scoreboard.md'}")
    return 0 if eligible else 1


if __name__ == "__main__":
    raise SystemExit(main())
