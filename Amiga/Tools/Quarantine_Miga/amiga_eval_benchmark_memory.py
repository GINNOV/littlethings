#!/usr/bin/env python3
"""Build a source benchmark into a bootable ADF and score a captured memory block."""

from __future__ import annotations

import argparse
import json
import shlex
import time
from dataclasses import asdict
from pathlib import Path
from typing import Any

from amiga_eval import load_toml, resolve_kick_rom_path, resolve_path, run_shell, write_text
from amiga_eval_benchmark_source import (
    create_adf_from_bootblock,
    env_assignment,
    make_command_result,
    now_iso,
    parse_int,
    sha1_of_file,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run one source-built Amiga memory benchmark.")
    parser.add_argument("--config", default="amiga_eval.toml")
    parser.add_argument(
        "--benchmark-config",
        default="amiga_workspace/benchmarks/audio_tone/reference_benchmark.json",
    )
    parser.add_argument("--report", default="")
    parser.add_argument("--kick-rom", default="")
    parser.add_argument("--kick-rom-name", default="")
    parser.add_argument("--kick-rom-dir", default="")
    parser.add_argument("--write-reference", action="store_true")
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def write_selection_metadata(
    *,
    repo_root: Path,
    selected_source_path: Path,
    benchmark_name: str,
    benchmark_label: str,
    benchmark_config_path: Path,
    main_source_path: Path,
    disk_image_path: Path,
) -> None:
    metadata = {
        "selected_at": now_iso(),
        "manifest": None,
        "manifest_mode": "benchmark_memory",
        "run_mode": "memory_benchmark",
        "run_mode_label": benchmark_label,
        "target": str(disk_image_path.relative_to(repo_root)),
        "benchmark": {
            "name": benchmark_name,
            "label": benchmark_label,
            "config": str(benchmark_config_path.relative_to(repo_root)),
            "disk_image": str(disk_image_path.relative_to(repo_root)),
        },
        "entry": {
            "id": f"benchmark-memory:{benchmark_name}",
            "source_rel": str(main_source_path.relative_to(repo_root)),
            "curated_rel": str(main_source_path.relative_to(repo_root)),
            "bytes": str(main_source_path.stat().st_size),
            "lines": str(len(main_source_path.read_text(encoding="utf-8").splitlines())),
            "sha1": sha1_of_file(main_source_path),
            "has_entry": "1",
            "has_section": "0",
            "label": benchmark_label,
        },
        "filter": "",
        "index_arg": 0,
        "seed_arg": 0,
    }
    selected_source_path.parent.mkdir(parents=True, exist_ok=True)
    selected_source_path.write_text(json.dumps(metadata, indent=2), encoding="utf-8")


def compute_similarity(actual_bytes: list[int], expected_bytes: list[int]) -> dict[str, float]:
    compare_len = min(len(actual_bytes), len(expected_bytes))
    if compare_len == 0:
        return {"score": 0.0, "byte_match_ratio": 0.0, "compare_len": 0}
    matches = sum(1 for index in range(compare_len) if actual_bytes[index] == expected_bytes[index])
    ratio = matches / compare_len
    return {"score": ratio, "byte_match_ratio": ratio, "compare_len": compare_len}


def main() -> int:
    args = parse_args()
    config_path = Path(args.config).resolve()
    config_dir = config_path.parent
    cfg = load_toml(config_path)
    benchmark_cfg_path = resolve_path(config_dir, args.benchmark_config)
    benchmark_cfg = load_json(benchmark_cfg_path)
    paths = cfg.get("paths", {})
    timeouts = cfg.get("timeouts", {})

    build_dir = resolve_path(config_dir, str(paths.get("build_dir", "build/amiga")))
    build_dir.mkdir(parents=True, exist_ok=True)
    work_dir = resolve_path(config_dir, str(benchmark_cfg.get("work_dir", "build/amiga/memory_benchmark")))
    include_root = resolve_path(config_dir, str(benchmark_cfg.get("include_root", benchmark_cfg["source_root"])))
    main_source_path = resolve_path(config_dir, str(benchmark_cfg["main_source"]))
    bootblock_template_path = resolve_path(config_dir, str(benchmark_cfg["bootblock_template"]))
    disk_image_path = resolve_path(config_dir, str(benchmark_cfg["disk_image"]))
    capture_state_path = resolve_path(config_dir, str(benchmark_cfg["capture_state"]))
    reference_state_path = resolve_path(config_dir, str(benchmark_cfg["reference_state"]))
    selected_source_path = resolve_path(config_dir, "build/amiga/selected_source.json")
    vamiga_report_path = resolve_path(config_dir, str(paths.get("vamiga_report", "build/amiga/vamigaweb_report.json")))
    report_path = (
        resolve_path(config_dir, args.report)
        if args.report
        else resolve_path(config_dir, str(paths.get("report", "build/amiga/report.json")))
    )
    kick_rom_path = resolve_kick_rom_path(config_dir, paths, args)

    benchmark_name = str(benchmark_cfg.get("name", "memory_benchmark"))
    benchmark_label = str(benchmark_cfg.get("label", benchmark_name))
    min_similarity = float(benchmark_cfg.get("minimum_similarity", 1.0))
    minimum_nonzero_bytes = int(benchmark_cfg.get("minimum_nonzero_bytes", 1))
    seconds = int(benchmark_cfg.get("seconds", 2))
    emulate_timeout = float(timeouts.get("emulate_seconds", 20))
    assemble_timeout = float(timeouts.get("assemble_seconds", 30))
    disk_size_bytes = parse_int(benchmark_cfg.get("disk_size_bytes", 901120))
    base_address = parse_int(benchmark_cfg.get("base_address", "0x70000"))
    capture_address = parse_int(benchmark_cfg["memory_capture_address"])
    capture_length = int(benchmark_cfg["memory_capture_length"])

    work_dir.mkdir(parents=True, exist_ok=True)
    main_binary_path = work_dir / "main.bin"
    bootblock_source_path = work_dir / "bootblock.s"
    bootblock_binary_path = work_dir / "bootblock.bin"
    include_dir = include_root / "include"

    write_selection_metadata(
        repo_root=config_dir,
        selected_source_path=selected_source_path,
        benchmark_name=benchmark_name,
        benchmark_label=benchmark_label,
        benchmark_config_path=benchmark_cfg_path,
        main_source_path=main_source_path,
        disk_image_path=disk_image_path,
    )

    bootblock_template = bootblock_template_path.read_text(encoding="utf-8")
    bootblock_text = (
        bootblock_template.replace("__BASE_ADDRESS__", f"${base_address:x}")
        .replace("__MAIN_BIN__", str(main_binary_path))
    )
    write_text(bootblock_source_path, bootblock_text)
    write_text(work_dir / "source_snapshot.s", main_source_path.read_text(encoding="utf-8"))

    assemble_cmd = " && ".join(
        [
            f"mkdir -p {shlex.quote(str(work_dir))}",
            (
                "vasmm68k_mot -Fbin -quiet -esc "
                f"-I{shlex.quote(str(include_dir))} "
                f"-o {shlex.quote(str(main_binary_path))} {shlex.quote(str(main_source_path))}"
            ),
            (
                "vasmm68k_mot -Fbin -quiet -esc "
                f"-o {shlex.quote(str(bootblock_binary_path))} {shlex.quote(str(bootblock_source_path))}"
            ),
        ]
    )
    assemble = run_shell(assemble_cmd, timeout_seconds=assemble_timeout, cwd=config_dir)
    write_text(build_dir / "assemble.stdout.log", assemble.stdout)
    write_text(build_dir / "assemble.stderr.log", assemble.stderr)
    assembled_ok = (
        assemble.returncode == 0
        and not assemble.timed_out
        and main_binary_path.exists()
        and bootblock_binary_path.exists()
    )

    package_started = time.time()
    package = make_command_result("bootblock:pad-adf", returncode=0, seconds=0.0)
    packaged_ok = False
    if assembled_ok:
        try:
            create_adf_from_bootblock(bootblock_binary_path, disk_image_path, disk_size_bytes)
            packaged_ok = disk_image_path.exists()
            package = make_command_result(
                "bootblock:pad-adf",
                returncode=0 if packaged_ok else 1,
                seconds=time.time() - package_started,
                stdout=f"disk_image={disk_image_path}\nbootblock={bootblock_binary_path}\n",
            )
        except Exception as exc:
            package = make_command_result(
                "bootblock:pad-adf",
                returncode=1,
                seconds=time.time() - package_started,
                stderr=str(exc),
            )
    else:
        package = make_command_result(
            "bootblock:pad-adf",
            returncode=1,
            seconds=time.time() - package_started,
            stderr="skipped: source assembly did not produce main.bin and bootblock.bin",
        )
    write_text(build_dir / "package.stdout.log", package.stdout)
    write_text(build_dir / "package.stderr.log", package.stderr)

    env_parts = [
        env_assignment("VAMIGA_DISK_IMAGE", str(disk_image_path)),
        env_assignment("VAMIGA_KICK_ROM", str(kick_rom_path)),
        env_assignment("VAMIGA_SECONDS", str(seconds)),
        env_assignment("VAMIGA_REPORT_PATH", str(vamiga_report_path)),
        env_assignment("VAMIGA_MEMORY_CAPTURE_PATH", str(capture_state_path)),
        env_assignment("VAMIGA_MEMORY_CAPTURE_ADDRESS", str(capture_address)),
        env_assignment("VAMIGA_MEMORY_CAPTURE_LENGTH", str(capture_length)),
        env_assignment("VAMIGA_RENDERER", str(benchmark_cfg.get("renderer", "software"))),
        env_assignment("VAMIGA_DISPLAY", str(benchmark_cfg.get("display", "standard"))),
        env_assignment("VAMIGA_PORT1", str(benchmark_cfg.get("port1", "mouse"))),
        env_assignment("VAMIGA_PORT2", str(benchmark_cfg.get("port2", "none"))),
        env_assignment("VAMIGA_WARP", "1" if benchmark_cfg.get("warp", True) else "0"),
        env_assignment(
            "VAMIGA_ACCEPT_BOOTBLOCK",
            "1" if benchmark_cfg.get("accept_bootblock", False) else "0",
        ),
        env_assignment(
            "VAMIGA_BOOTBLOCK_ACCEPT_DELAY_MS",
            str(int(benchmark_cfg.get("accept_bootblock_delay_ms", 4000))),
        ),
        env_assignment(
            "VAMIGA_BOOTBLOCK_ACCEPT_HOLD_MS",
            str(int(benchmark_cfg.get("accept_bootblock_hold_ms", 300))),
        ),
    ]
    emulate_cmd = " ".join(env_parts + ["node", "amiga_workspace/run_vamigaweb.js"])
    emulate = run_shell(emulate_cmd, timeout_seconds=emulate_timeout, cwd=config_dir) if packaged_ok else make_command_result(
        emulate_cmd,
        returncode=1,
        seconds=0.0,
        stderr="skipped: bootable disk image was not produced",
    )
    write_text(build_dir / "emulate.stdout.log", emulate.stdout)
    write_text(build_dir / "emulate.stderr.log", emulate.stderr)

    actual_state = load_json(capture_state_path) if capture_state_path.exists() else None
    actual_nonzero_bytes = (
        sum(1 for value in actual_state.get("bytes", []) if int(value) != 0) if actual_state else 0
    )
    if args.write_reference and actual_state is not None and actual_nonzero_bytes >= minimum_nonzero_bytes:
        reference_state_path.parent.mkdir(parents=True, exist_ok=True)
        reference_state_path.write_text(capture_state_path.read_text(encoding="utf-8"), encoding="utf-8")
    expected_state = load_json(reference_state_path) if reference_state_path.exists() else None

    similarity = {"score": 0.0, "byte_match_ratio": 0.0, "compare_len": 0}
    if actual_state and expected_state:
        similarity = compute_similarity(
            [int(value) for value in actual_state.get("bytes", [])],
            [int(value) for value in expected_state.get("bytes", [])],
        )

    emulator_ok = emulate.returncode == 0 and not emulate.timed_out
    state_present = bool(actual_state and actual_nonzero_bytes >= minimum_nonzero_bytes)
    verify_ok = bool(
        emulator_ok and state_present and expected_state and similarity["score"] >= min_similarity
    )
    checks = [
        {
            "name": "source_assembled",
            "kind": "assemble",
            "passed": assembled_ok,
            "detail": f"returncode={assemble.returncode} timed_out={assemble.timed_out}",
        },
        {
            "name": "bootblock_disk_built",
            "kind": "package",
            "passed": packaged_ok,
            "detail": f"bootblock={bootblock_binary_path.exists()} disk={disk_image_path.exists()}",
        },
        {
            "name": "vamiga_booted",
            "kind": "emulator",
            "passed": emulator_ok,
            "detail": f"returncode={emulate.returncode} timed_out={emulate.timed_out}",
        },
        {
            "name": "memory_state_similarity",
            "kind": "memory",
            "passed": similarity["score"] >= min_similarity,
            "detail": f"score={similarity['score']:.6f} minimum={min_similarity:.6f}",
        },
        {
            "name": "memory_state_nonzero",
            "kind": "memory",
            "passed": actual_nonzero_bytes >= minimum_nonzero_bytes,
            "detail": f"nonzero_bytes={actual_nonzero_bytes} minimum={minimum_nonzero_bytes}",
        },
    ]
    checks_passed = sum(1 for item in checks if item["passed"])

    report = {
        "report_mode": "benchmark_memory",
        "stage_labels": {"assemble": "Assemble", "emulator": "Emulator", "verify": "State"},
        "score": similarity["score"],
        "assembled": assembled_ok,
        "packaged": packaged_ok,
        "emulator_ok": emulator_ok,
        "verify_ok": verify_ok,
        "crash_detected": not emulator_ok,
        "artifact": str(capture_state_path),
        "disk_image": str(disk_image_path),
        "kick_rom": str(kick_rom_path),
        "kick_rom_name": kick_rom_path.name,
        "kick_rom_dir": str(kick_rom_path.parent),
        "benchmark": {
            "name": benchmark_name,
            "label": benchmark_label,
            "config": str(benchmark_cfg_path),
            "description": str(benchmark_cfg.get("description", "")),
            "minimum_similarity": min_similarity,
            "minimum_nonzero_bytes": minimum_nonzero_bytes,
            "memory_capture_address": capture_address,
            "memory_capture_length": capture_length,
            "capture_state": str(capture_state_path),
            "reference_state": str(reference_state_path),
        },
        "memory": {
            "actual": actual_state,
            "reference": expected_state,
            "actual_nonzero_bytes": actual_nonzero_bytes,
            "similarity": similarity,
        },
        "command_results": {
            "assemble": asdict(assemble),
            "package": asdict(package),
            "emulate": asdict(emulate),
        },
        "checks": checks,
        "checks_total": len(checks),
        "checks_passed": checks_passed,
        "checks_ratio": checks_passed / len(checks) if checks else 0.0,
        "generated_at": now_iso(),
    }
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    print("---")
    print(f"memory benchmark:   {benchmark_label}")
    print(f"score:              {similarity['score']:.6f}")
    print(f"assembled:          {'yes' if assembled_ok else 'no'}")
    print(f"emulator_ok:        {'yes' if emulator_ok else 'no'}")
    print(f"state_ok:           {'yes' if verify_ok else 'no'}")
    if actual_state:
        print(f"state_hash:         {actual_state.get('sha1', '')}")
    print(f"report_path:        {report_path}")
    return 0 if verify_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
