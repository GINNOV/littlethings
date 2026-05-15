#!/usr/bin/env python3
"""Run a suite of Amiga source-built screenshot benchmarks and aggregate the result."""

from __future__ import annotations

import argparse
import json
import subprocess
import time
from pathlib import Path
from typing import Any

from amiga_eval import load_toml, resolve_kick_rom_path, resolve_path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run a suite of source-built Amiga screenshot benchmarks.")
    parser.add_argument(
        "--config",
        default="amiga_eval.toml",
        help="Path to the base evaluator TOML config (default: amiga_eval.toml).",
    )
    parser.add_argument(
        "--benchmark-config",
        default="amiga_workspace/benchmarks/copper_bars/source_benchmark_suite.json",
        help="Path to the suite JSON config.",
    )
    parser.add_argument(
        "--report",
        default="",
        help="Optional JSON report path. Defaults to <build_dir>/report.json.",
    )
    parser.add_argument("--kick-rom", default="", help="Optional direct ROM file path, or ROM filename under --kick-rom-dir.")
    parser.add_argument("--kick-rom-name", default="", help="Optional ROM filename to load from --kick-rom-dir / AMIGA_ROMS_DIR.")
    parser.add_argument("--kick-rom-dir", default="", help="Optional ROM directory override. Defaults to [paths].kick_rom_dir or roms/.")
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> int:
    args = parse_args()
    config_path = Path(args.config).resolve()
    config_dir = config_path.parent
    cfg = load_toml(config_path)
    suite_cfg_path = resolve_path(config_dir, args.benchmark_config)
    suite_cfg = load_json(suite_cfg_path)
    paths = cfg.get("paths", {})
    build_dir = resolve_path(config_dir, str(paths.get("build_dir", "build/amiga")))
    build_dir.mkdir(parents=True, exist_ok=True)
    report_path = resolve_path(config_dir, args.report) if args.report else resolve_path(config_dir, str(paths.get("report", "build/amiga/report.json")))
    kick_rom_path = resolve_kick_rom_path(config_dir, paths, args)

    suite_name = str(suite_cfg.get("name", "benchmark_suite"))
    suite_label = str(suite_cfg.get("label", suite_name))
    components = suite_cfg.get("components")
    if not isinstance(components, list) or not components:
        raise SystemExit(f"Suite config {suite_cfg_path} must define a non-empty components list")

    eval_script = resolve_path(config_dir, str(suite_cfg.get("eval_script", "amiga_eval_benchmark_source.py")))
    suite_build_dir = resolve_path(config_dir, str(suite_cfg.get("work_dir", f"build/amiga/{suite_name}")))
    suite_build_dir.mkdir(parents=True, exist_ok=True)

    component_reports: list[dict[str, Any]] = []
    scores: list[float] = []
    started = time.time()
    for index, component in enumerate(components, start=1):
        if isinstance(component, str):
            component_cfg_path = resolve_path(config_dir, component)
            component_label = component_cfg_path.stem
        elif isinstance(component, dict):
            component_cfg_path = resolve_path(config_dir, str(component["benchmark_config"]))
            component_label = str(component.get("label", component_cfg_path.stem))
        else:
            raise SystemExit(f"Invalid suite component entry: {component!r}")

        component_report_path = suite_build_dir / f"component_{index:02d}.json"
        command = [
            "python3",
            str(eval_script),
            "--config",
            str(config_path),
            "--benchmark-config",
            str(component_cfg_path),
            "--report",
            str(component_report_path),
            "--kick-rom",
            str(kick_rom_path),
        ]
        proc = subprocess.run(command, cwd=str(config_dir), capture_output=True, text=True)
        component_report = load_json(component_report_path) if component_report_path.exists() else {}
        component_score = float(component_report.get("score", 0.0) or 0.0)
        scores.append(component_score)
        component_reports.append(
            {
                "label": component_label,
                "benchmark_config": str(component_cfg_path),
                "report_path": str(component_report_path),
                "returncode": proc.returncode,
                "stdout": proc.stdout,
                "stderr": proc.stderr,
                "score": component_score,
                "verify_ok": bool(component_report.get("verify_ok")),
                "report": component_report,
            }
        )

    average_score = sum(scores) / len(scores) if scores else 0.0
    all_verify_ok = all(item["verify_ok"] for item in component_reports)
    all_emulator_ok = all(bool(item["report"].get("emulator_ok")) for item in component_reports)
    all_assembled = all(bool(item["report"].get("assembled")) for item in component_reports)
    all_packaged = all(bool(item["report"].get("packaged", True)) for item in component_reports)
    minimum_average_score = float(suite_cfg.get("minimum_average_score", 0.999))
    suite_ok = all_verify_ok and average_score >= minimum_average_score

    report = {
        "report_mode": "benchmark_suite",
        "stage_labels": {"assemble": "Assemble", "emulator": "Emulator", "verify": "Suite"},
        "score": average_score,
        "assembled": all_assembled,
        "packaged": all_packaged,
        "emulator_ok": all_emulator_ok,
        "verify_ok": suite_ok,
        "crash_detected": not all_emulator_ok,
        "artifact": "",
        "disk_image": "",
        "kick_rom": str(kick_rom_path),
        "kick_rom_name": kick_rom_path.name,
        "kick_rom_dir": str(kick_rom_path.parent),
        "suite": {
            "name": suite_name,
            "label": suite_label,
            "config": str(suite_cfg_path),
            "minimum_average_score": minimum_average_score,
            "component_count": len(component_reports),
            "average_score": average_score,
            "all_verify_ok": all_verify_ok,
            "components": [
                {
                    "label": item["label"],
                    "benchmark_config": item["benchmark_config"],
                    "report_path": item["report_path"],
                    "score": item["score"],
                    "verify_ok": item["verify_ok"],
                    "returncode": item["returncode"],
                }
                for item in component_reports
            ],
        },
        "components": component_reports,
        "checks": [
            {
                "name": "suite_component_count",
                "kind": "benchmark_suite",
                "passed": len(component_reports) > 0,
                "detail": f"components={len(component_reports)}",
            },
            {
                "name": "suite_average_score_threshold",
                "kind": "benchmark_suite",
                "passed": average_score >= minimum_average_score,
                "detail": f"average={average_score:.6f} minimum={minimum_average_score:.6f}",
            },
            {
                "name": "suite_all_components_verify",
                "kind": "benchmark_suite",
                "passed": all_verify_ok,
                "detail": f"all_verify_ok={all_verify_ok}",
            },
        ],
        "checks_total": 3,
        "checks_passed": int(len(component_reports) > 0) + int(average_score >= minimum_average_score) + int(all_verify_ok),
        "checks_ratio": (int(len(component_reports) > 0) + int(average_score >= minimum_average_score) + int(all_verify_ok)) / 3,
        "seconds": {"total": time.time() - started},
    }
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    print("---")
    print(f"benchmark suite:    {suite_label}")
    print(f"score:              {average_score:.6f}")
    print(f"assembled:          {str(all_assembled).lower()}")
    print(f"emulator_ok:        {str(all_emulator_ok).lower()}")
    print(f"suite_ok:           {str(suite_ok).lower()}")
    print(f"components:         {len(component_reports)}")
    for item in component_reports:
        print(f"  - {item['label']}: score={item['score']:.6f} verify_ok={str(item['verify_ok']).lower()}")
    print(f"report_path:        {report_path}")
    return 0 if suite_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
