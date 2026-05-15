#!/usr/bin/env python3
"""Build a mutable Amiga source benchmark into a bootable ADF and score audio output."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import shlex
import time
from dataclasses import asdict
from pathlib import Path
from typing import Any

from amiga_eval import (
    CommandResult,
    load_toml,
    resolve_kick_rom_path,
    resolve_path,
    run_shell,
    write_text,
)
from amiga_eval_benchmark_source import (
    amiga_bootblock_checksum,
    create_adf_from_bootblock,
    env_assignment,
    make_command_result,
    now_iso,
    parse_int,
    sha1_of_file,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run one source-built Amiga audio benchmark.")
    parser.add_argument(
        "--config",
        default="amiga_eval.toml",
        help="Path to the base evaluator TOML config (default: amiga_eval.toml).",
    )
    parser.add_argument(
        "--benchmark-config",
        default="amiga_workspace/benchmarks/audio_tone/reference_benchmark.json",
        help="Path to the source benchmark JSON config.",
    )
    parser.add_argument(
        "--report",
        default="",
        help="Optional JSON report path. Defaults to <build_dir>/report.json.",
    )
    parser.add_argument(
        "--kick-rom",
        default="",
        help="Optional direct ROM file path, or ROM filename under --kick-rom-dir.",
    )
    parser.add_argument(
        "--kick-rom-name",
        default="",
        help="Optional ROM filename to load from --kick-rom-dir / AMIGA_ROMS_DIR.",
    )
    parser.add_argument(
        "--kick-rom-dir",
        default="",
        help="Optional ROM directory override. Defaults to [paths].kick_rom_dir or roms/.",
    )
    parser.add_argument(
        "--write-reference",
        action="store_true",
        help="Capture the current audio and write it to the benchmark's reference_audio path.",
    )
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
        "manifest_mode": "benchmark_audio",
        "run_mode": "audio_benchmark",
        "run_mode_label": benchmark_label,
        "target": str(disk_image_path.relative_to(repo_root)),
        "benchmark": {
            "name": benchmark_name,
            "label": benchmark_label,
            "config": str(benchmark_config_path.relative_to(repo_root)),
            "disk_image": str(disk_image_path.relative_to(repo_root)),
        },
        "entry": {
            "id": f"benchmark-audio:{benchmark_name}",
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


def normalize_spectrum(values: list[float]) -> list[float]:
    total = sum(values)
    if total <= 1e-12:
        return [0.0 for _ in values]
    return [value / total for value in values]


def compute_spectrum(samples: list[float], bin_count: int = 32) -> list[float]:
    if not samples:
        return [0.0] * bin_count
    length = min(len(samples), 1024)
    windowed = []
    for index in range(length):
        if length == 1:
            weight = 1.0
        else:
            weight = 0.5 - 0.5 * math.cos((2.0 * math.pi * index) / (length - 1))
        windowed.append(samples[index] * weight)
    bins = []
    for bin_index in range(1, bin_count + 1):
        real = 0.0
        imag = 0.0
        factor = (2.0 * math.pi * bin_index) / length
        for sample_index, sample in enumerate(windowed):
            angle = factor * sample_index
            real += sample * math.cos(angle)
            imag -= sample * math.sin(angle)
        bins.append(math.sqrt(real * real + imag * imag))
    return normalize_spectrum(bins)


def load_audio_capture(path: Path) -> dict[str, Any]:
    raw = load_json(path)
    samples = [float(value) for value in raw.get("samples", [])]
    sample_count = len(samples)
    mean_abs = sum(abs(value) for value in samples) / sample_count if sample_count else 0.0
    rms = math.sqrt(sum(value * value for value in samples) / sample_count) if sample_count else 0.0
    peak_abs = max((abs(value) for value in samples), default=0.0)
    zero_crossings = 0
    previous = samples[0] if samples else 0.0
    for value in samples[1:]:
      if (previous < 0.0 <= value) or (previous > 0.0 >= value):
          zero_crossings += 1
      previous = value
    return {
        "sample_rate": int(raw.get("sampleRate", 0) or 0),
        "samples": samples,
        "sample_count": sample_count,
        "mean_abs": float(raw.get("meanAbs", mean_abs) or mean_abs),
        "rms": float(raw.get("rms", rms) or rms),
        "peak_abs": float(raw.get("peakAbs", peak_abs) or peak_abs),
        "zero_crossings": int(raw.get("zeroCrossings", zero_crossings) or zero_crossings),
        "non_zero_samples": int(raw.get("nonZeroSamples", 0) or 0),
        "sha1": str(raw.get("sha1", hashlib.sha1(json.dumps(samples).encode("utf-8")).hexdigest())),
        "spectrum": compute_spectrum(samples),
    }


def bounded_similarity(actual: float, expected: float) -> float:
    denom = max(abs(actual), abs(expected), 1e-9)
    return max(0.0, 1.0 - (abs(actual - expected) / denom))


def compute_audio_similarity(actual: dict[str, Any], expected: dict[str, Any]) -> dict[str, float]:
    spectrum_actual = actual["spectrum"]
    spectrum_expected = expected["spectrum"]
    spectrum_len = min(len(spectrum_actual), len(spectrum_expected))
    if spectrum_len:
        spectrum_mae = sum(
            abs(spectrum_actual[index] - spectrum_expected[index]) for index in range(spectrum_len)
        ) / spectrum_len
    else:
        spectrum_mae = 1.0
    spectrum_similarity = max(0.0, 1.0 - spectrum_mae)
    rms_similarity = bounded_similarity(actual["rms"], expected["rms"])
    peak_similarity = bounded_similarity(actual["peak_abs"], expected["peak_abs"])
    zc_similarity = bounded_similarity(float(actual["zero_crossings"]), float(expected["zero_crossings"]))
    mean_abs_similarity = bounded_similarity(actual["mean_abs"], expected["mean_abs"])
    score = (
        (0.55 * spectrum_similarity)
        + (0.20 * rms_similarity)
        + (0.10 * peak_similarity)
        + (0.10 * mean_abs_similarity)
        + (0.05 * zc_similarity)
    )
    return {
        "score": max(0.0, min(1.0, score)),
        "spectrum_similarity": spectrum_similarity,
        "spectrum_mae": spectrum_mae,
        "rms_similarity": rms_similarity,
        "peak_similarity": peak_similarity,
        "mean_abs_similarity": mean_abs_similarity,
        "zero_crossing_similarity": zc_similarity,
    }


def main() -> int:
    args = parse_args()
    config_path = Path(args.config).resolve()
    config_dir = config_path.parent
    cfg = load_toml(config_path)
    benchmark_cfg_path = resolve_path(config_dir, args.benchmark_config)
    benchmark_cfg = load_json(benchmark_cfg_path)
    if "capture_audio" not in benchmark_cfg or "reference_audio" not in benchmark_cfg:
        raise SystemExit(
            f"Benchmark config {benchmark_cfg_path} does not define capture_audio/reference_audio. "
            "Use amiga_eval_benchmark_memory.py for the current audio_tone state-based configs."
        )

    paths = cfg.get("paths", {})
    timeouts = cfg.get("timeouts", {})

    build_dir = resolve_path(config_dir, str(paths.get("build_dir", "build/amiga")))
    build_dir.mkdir(parents=True, exist_ok=True)

    work_dir = resolve_path(config_dir, str(benchmark_cfg.get("work_dir", "build/amiga/audio_tone")))
    include_root = resolve_path(config_dir, str(benchmark_cfg.get("include_root", benchmark_cfg["source_root"])))
    main_source_path = resolve_path(config_dir, str(benchmark_cfg["main_source"]))
    bootblock_template_path = resolve_path(config_dir, str(benchmark_cfg["bootblock_template"]))
    disk_image_path = resolve_path(config_dir, str(benchmark_cfg["disk_image"]))
    audio_capture_path = resolve_path(config_dir, str(benchmark_cfg["capture_audio"]))
    reference_audio_path = resolve_path(config_dir, str(benchmark_cfg["reference_audio"]))
    vamiga_report_path = resolve_path(
        config_dir, str(paths.get("vamiga_report", "build/amiga/vamigaweb_report.json"))
    )
    selected_source_path = resolve_path(config_dir, "build/amiga/selected_source.json")
    report_path = (
        resolve_path(config_dir, args.report)
        if args.report
        else resolve_path(config_dir, str(paths.get("report", "build/amiga/report.json")))
    )
    kick_rom_path = resolve_kick_rom_path(config_dir, paths, args)

    benchmark_name = str(benchmark_cfg.get("name", "audio_benchmark"))
    benchmark_label = str(benchmark_cfg.get("label", benchmark_name))
    min_similarity = float(benchmark_cfg.get("minimum_similarity", 0.99))
    min_rms = float(benchmark_cfg.get("minimum_rms", 0.001))
    seconds = int(benchmark_cfg.get("seconds", 3))
    emulate_timeout = float(timeouts.get("emulate_seconds", 20))
    assemble_timeout = float(timeouts.get("assemble_seconds", 30))
    disk_size_bytes = parse_int(benchmark_cfg.get("disk_size_bytes", 901120))
    base_address = parse_int(benchmark_cfg.get("base_address", "0x70000"))
    audio_sample_rate = int(benchmark_cfg.get("audio_sample_rate", 44100))
    audio_sample_count = int(benchmark_cfg.get("audio_sample_count", 4096))
    audio_warmup_updates = int(benchmark_cfg.get("audio_warmup_updates", 32))
    audio_update_iterations = int(benchmark_cfg.get("audio_update_iterations", 8))

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
        env_assignment("VAMIGA_AUDIO_CAPTURE_PATH", str(audio_capture_path)),
        env_assignment("VAMIGA_AUDIO_SAMPLE_RATE", str(audio_sample_rate)),
        env_assignment("VAMIGA_AUDIO_SAMPLE_COUNT", str(audio_sample_count)),
        env_assignment("VAMIGA_AUDIO_WARMUP_UPDATES", str(audio_warmup_updates)),
        env_assignment("VAMIGA_AUDIO_UPDATE_ITERATIONS", str(audio_update_iterations)),
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

    similarity_started = time.time()
    actual_audio = load_audio_capture(audio_capture_path) if audio_capture_path.exists() else None
    if args.write_reference and actual_audio is not None and actual_audio["rms"] >= min_rms and actual_audio["non_zero_samples"] > 0:
        reference_audio_path.parent.mkdir(parents=True, exist_ok=True)
        reference_audio_path.write_text(audio_capture_path.read_text(encoding="utf-8"), encoding="utf-8")
    expected_audio = load_audio_capture(reference_audio_path) if reference_audio_path.exists() else None

    score = 0.0
    similarity_details = {
        "score": 0.0,
        "spectrum_similarity": 0.0,
        "spectrum_mae": 1.0,
        "rms_similarity": 0.0,
        "peak_similarity": 0.0,
        "mean_abs_similarity": 0.0,
        "zero_crossing_similarity": 0.0,
    }
    if actual_audio and expected_audio:
        similarity_details = compute_audio_similarity(actual_audio, expected_audio)
        score = similarity_details["score"]
    similarity_seconds = time.time() - similarity_started

    emulator_ok = emulate.returncode == 0 and not emulate.timed_out
    audio_present = bool(actual_audio and actual_audio["rms"] >= min_rms and actual_audio["non_zero_samples"] > 0)
    verify_ok = bool(emulator_ok and actual_audio and expected_audio and audio_present and score >= min_similarity)
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
            "name": "audio_present",
            "kind": "audio",
            "passed": audio_present,
            "detail": (
                f"rms={actual_audio['rms']:.6f} non_zero_samples={actual_audio['non_zero_samples']}"
                if actual_audio
                else "audio capture missing"
            ),
        },
        {
            "name": "audio_similarity_threshold",
            "kind": "audio",
            "passed": score >= min_similarity,
            "detail": f"score={score:.6f} minimum={min_similarity:.6f}",
        },
    ]
    checks_passed = sum(1 for item in checks if item["passed"])

    report = {
        "report_mode": "benchmark_audio",
        "stage_labels": {"assemble": "Assemble", "emulator": "Emulator", "verify": "Audio"},
        "score": score,
        "assembled": assembled_ok,
        "packaged": packaged_ok,
        "emulator_ok": emulator_ok,
        "verify_ok": verify_ok,
        "crash_detected": not emulator_ok,
        "artifact": str(audio_capture_path),
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
            "minimum_rms": min_rms,
            "capture_audio": str(audio_capture_path),
            "reference_audio": str(reference_audio_path),
            "audio_sample_rate": audio_sample_rate,
            "audio_sample_count": audio_sample_count,
            "audio_warmup_updates": audio_warmup_updates,
            "audio_update_iterations": audio_update_iterations,
        },
        "audio": {
            "actual": actual_audio,
            "reference": expected_audio,
            "similarity": similarity_details,
        },
        "commands": {
            "assemble": assemble.command,
            "package": package.command,
            "emulate": emulate.command,
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
        "seconds": {
            "assemble": assemble.seconds,
            "package": package.seconds,
            "emulate": emulate.seconds,
            "similarity": similarity_seconds,
            "total": assemble.seconds + package.seconds + emulate.seconds + similarity_seconds,
        },
        "generated_at": now_iso(),
        "workspace": {
            "work_dir": str(work_dir),
            "main_source": str(main_source_path),
            "bootblock_template": str(bootblock_template_path),
            "main_binary": str(main_binary_path),
            "bootblock_binary": str(bootblock_binary_path),
            "disk_image": str(disk_image_path),
            "audio_capture": str(audio_capture_path),
        },
    }
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    print("---")
    print(f"audio benchmark:    {benchmark_label}")
    print(f"score:              {score:.6f}")
    print(f"assembled:          {'yes' if assembled_ok else 'no'}")
    print(f"emulator_ok:        {'yes' if emulator_ok else 'no'}")
    print(f"audio_present:      {'yes' if audio_present else 'no'}")
    print(f"audio_ok:           {'yes' if verify_ok else 'no'}")
    if actual_audio:
        print(f"audio_rms:          {actual_audio['rms']:.6f}")
        print(f"audio_hash:         {actual_audio['sha1']}")
    print(f"report_path:        {report_path}")
    return 0 if verify_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
