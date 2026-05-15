#!/usr/bin/env python3
"""Build a mutable Amiga source benchmark into a bootable ADF and score it."""

from __future__ import annotations

import argparse
import hashlib
import json
import shlex
import time
from dataclasses import asdict
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops

from amiga_eval import (
    CommandResult,
    load_toml,
    resolve_kick_rom_path,
    resolve_path,
    run_shell,
    write_text,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run one source-built Amiga screenshot benchmark.")
    parser.add_argument(
        "--config",
        default="amiga_eval.toml",
        help="Path to the base evaluator TOML config (default: amiga_eval.toml).",
    )
    parser.add_argument(
        "--benchmark-config",
        default="amiga_workspace/benchmarks/copper_bars/source_benchmark.json",
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
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def make_command_result(
    command: str,
    *,
    returncode: int,
    seconds: float,
    stdout: str = "",
    stderr: str = "",
    timed_out: bool = False,
    executed: bool = True,
) -> CommandResult:
    return CommandResult(
        command=command,
        returncode=returncode,
        timed_out=timed_out,
        seconds=seconds,
        stdout=stdout,
        stderr=stderr,
        executed=executed,
    )


def env_assignment(name: str, value: str) -> str:
    return f"{name}={shlex.quote(value)}"


def sha1_of_file(path: Path) -> str:
    return hashlib.sha1(path.read_bytes()).hexdigest()


def now_iso() -> str:
    return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())


def compute_similarity(actual: Image.Image, expected: Image.Image) -> tuple[float, float]:
    diff = ImageChops.difference(actual.convert("RGB"), expected.convert("RGB"))
    hist = diff.histogram()
    total = sum(value * (index % 256) for index, value in enumerate(hist))
    denom = actual.size[0] * actual.size[1] * 3 * 255
    mae = total / denom if denom else 1.0
    similarity = max(0.0, 1.0 - mae)
    return similarity, mae


def parse_int(value: Any) -> int:
    if isinstance(value, int):
        return value
    text = str(value).strip()
    return int(text, 0)


def amiga_bootblock_checksum(block: bytes) -> int:
    if len(block) != 1024:
        raise ValueError(f"bootblock must be exactly 1024 bytes, got {len(block)}")
    total = 0
    for offset in range(0, 1024, 4):
        word = int.from_bytes(block[offset : offset + 4], "big")
        total += word
        total = (total & 0xFFFFFFFF) + (total >> 32)
    return (~total) & 0xFFFFFFFF


def create_adf_from_bootblock(bootblock_bin_path: Path, disk_image_path: Path, disk_size_bytes: int) -> None:
    raw = bootblock_bin_path.read_bytes()
    if len(raw) > disk_size_bytes:
        raise ValueError(
            f"bootblock payload is larger than the target disk: {len(raw)} > {disk_size_bytes}"
        )

    disk = bytearray(raw)
    if len(disk) < 1024:
        disk.extend(b"\x00" * (1024 - len(disk)))

    header = bytearray(disk[:1024])
    header[4:8] = b"\x00\x00\x00\x00"
    checksum = amiga_bootblock_checksum(bytes(header))
    header[4:8] = checksum.to_bytes(4, "big")
    disk[:1024] = header

    if len(disk) < disk_size_bytes:
        disk.extend(b"\x00" * (disk_size_bytes - len(disk)))

    disk_image_path.parent.mkdir(parents=True, exist_ok=True)
    disk_image_path.write_bytes(bytes(disk))


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
        "manifest_mode": "benchmark_source",
        "run_mode": "copper_source_benchmark",
        "run_mode_label": benchmark_label,
        "target": str(disk_image_path.relative_to(repo_root)),
        "benchmark": {
            "name": benchmark_name,
            "label": benchmark_label,
            "config": str(benchmark_config_path.relative_to(repo_root)),
            "disk_image": str(disk_image_path.relative_to(repo_root)),
        },
        "entry": {
            "id": f"benchmark-source:{benchmark_name}",
            "source_rel": str(main_source_path.relative_to(repo_root)),
            "curated_rel": str(main_source_path.relative_to(repo_root)),
            "bytes": str(main_source_path.stat().st_size),
            "lines": str(
                len(
                    [
                        line
                        for line in main_source_path.read_text(encoding="utf-8").splitlines()
                        if line.strip() or line == ""
                    ]
                )
            ),
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

    work_dir = resolve_path(config_dir, str(benchmark_cfg.get("work_dir", "build/amiga/copper_bars_source")))
    source_root = resolve_path(config_dir, str(benchmark_cfg["source_root"]))
    include_root = resolve_path(config_dir, str(benchmark_cfg.get("include_root", benchmark_cfg["source_root"])))
    main_source_path = resolve_path(config_dir, str(benchmark_cfg["main_source"]))
    bootblock_template_path = resolve_path(config_dir, str(benchmark_cfg["bootblock_template"]))
    disk_image_path = resolve_path(config_dir, str(benchmark_cfg["disk_image"]))
    reference_image_path = resolve_path(config_dir, str(benchmark_cfg["reference_image"]))
    capture_image_path = resolve_path(config_dir, str(benchmark_cfg["capture_image"]))
    capture_crop_image_path = resolve_path(config_dir, str(benchmark_cfg["capture_crop_image"]))
    capture_diff_image_path = resolve_path(config_dir, str(benchmark_cfg["capture_diff_image"]))
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

    benchmark_name = str(benchmark_cfg.get("name", "benchmark_source"))
    benchmark_label = str(benchmark_cfg.get("label", benchmark_name))
    min_similarity = float(benchmark_cfg.get("minimum_similarity", 0.99))
    seconds = int(benchmark_cfg.get("seconds", 8))
    emulate_timeout = float(timeouts.get("emulate_seconds", 20))
    assemble_timeout = float(timeouts.get("assemble_seconds", 30))
    disk_size_bytes = parse_int(benchmark_cfg.get("disk_size_bytes", 901120))
    base_address = parse_int(benchmark_cfg.get("base_address", "0x70000"))

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
        env_assignment("VAMIGA_SCREENSHOT_PATH", str(capture_image_path)),
        env_assignment("VAMIGA_RENDERER", str(benchmark_cfg.get("renderer", "software"))),
        env_assignment("VAMIGA_DISPLAY", str(benchmark_cfg.get("display", "standard"))),
        env_assignment("VAMIGA_PORT1", str(benchmark_cfg.get("port1", "none"))),
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
    similarity = 0.0
    mae = 1.0
    size_match = False
    capture_exists = capture_image_path.exists()
    reference_exists = reference_image_path.exists()
    benchmark_ok = False
    verify_stdout = ""
    verify_stderr = ""

    crop_cfg = benchmark_cfg.get("crop", {})
    crop_box = (
        int(crop_cfg.get("left", 0)),
        int(crop_cfg.get("top", 42)),
        int(crop_cfg.get("right", 1166)),
        int(crop_cfg.get("bottom", 770)),
    )

    if emulate.returncode == 0 and capture_exists and reference_exists:
        actual = Image.open(capture_image_path).convert("RGB")
        reference = Image.open(reference_image_path).convert("RGB")
        actual_crop = actual.crop(crop_box)
        actual_crop.save(capture_crop_image_path)
        size_match = actual_crop.size == reference.size
        if size_match:
            diff = ImageChops.difference(actual_crop, reference)
            diff.save(capture_diff_image_path)
            similarity, mae = compute_similarity(actual_crop, reference)
        else:
            verify_stderr = f"crop size mismatch: actual={actual_crop.size} reference={reference.size}"
    else:
        reasons: list[str] = []
        if emulate.returncode != 0:
            reasons.append(f"emulate_returncode={emulate.returncode}")
        if not capture_exists:
            reasons.append(f"missing_capture={capture_image_path}")
        if not reference_exists:
            reasons.append(f"missing_reference={reference_image_path}")
        verify_stderr = ", ".join(reasons)

    benchmark_ok = (
        assembled_ok
        and packaged_ok
        and emulate.returncode == 0
        and capture_exists
        and reference_exists
        and size_match
        and similarity >= min_similarity
    )
    verify = make_command_result(
        "benchmark:image-compare",
        returncode=0 if benchmark_ok else 1,
        seconds=time.time() - similarity_started,
        stdout=verify_stdout,
        stderr=verify_stderr,
    )
    write_text(build_dir / "verify.stdout.log", verify.stdout)
    write_text(build_dir / "verify.stderr.log", verify.stderr)

    checks = [
        {
            "name": "source_exists",
            "kind": "benchmark",
            "passed": main_source_path.exists(),
            "detail": str(main_source_path),
        },
        {
            "name": "bootblock_disk_built",
            "kind": "benchmark",
            "passed": packaged_ok,
            "detail": f"bootblock={bootblock_binary_path.exists()} disk={disk_image_path.exists()}",
        },
        {
            "name": "benchmark_capture_exists",
            "kind": "benchmark",
            "passed": capture_exists,
            "detail": str(capture_image_path),
        },
        {
            "name": "benchmark_similarity_threshold",
            "kind": "benchmark",
            "passed": benchmark_ok,
            "detail": f"similarity={similarity:.6f} minimum={min_similarity:.6f} mae={mae:.6f}",
        },
    ]
    checks_total = len(checks)
    checks_passed = sum(1 for item in checks if item["passed"])
    checks_ratio = checks_passed / checks_total if checks_total else 1.0

    score = similarity if packaged_ok and emulate.returncode == 0 else 0.0
    score = max(0.0, min(1.0, score))

    report = {
        "report_mode": "benchmark",
        "stage_labels": {
            "assemble": "Assemble",
            "emulator": "Emulator",
            "verify": "Benchmark",
        },
        "score": score,
        "assembled": assembled_ok,
        "packaged": packaged_ok,
        "emulator_ok": emulate.returncode == 0 and packaged_ok,
        "verify_ok": benchmark_ok,
        "crash_detected": emulate.returncode != 0,
        "checks_passed": checks_passed,
        "checks_total": checks_total,
        "checks_ratio": checks_ratio,
        "artifact": str(main_binary_path),
        "disk_image": str(disk_image_path),
        "kick_rom": str(kick_rom_path),
        "kick_rom_name": kick_rom_path.name,
        "kick_rom_dir": str(kick_rom_path.parent),
        "vamiga_report": str(vamiga_report_path),
        "assemble": asdict(assemble),
        "package": asdict(package),
        "emulate": asdict(emulate),
        "verify": asdict(verify),
        "checks": checks,
        "benchmark": {
            "name": benchmark_name,
            "label": benchmark_label,
            "config": str(benchmark_cfg_path),
            "source_root": str(source_root),
            "include_root": str(include_root),
            "main_source": str(main_source_path),
            "bootblock_template": str(bootblock_template_path),
            "main_binary": str(main_binary_path),
            "bootblock_binary": str(bootblock_binary_path),
            "reference_image": str(reference_image_path),
            "capture_image": str(capture_image_path),
            "capture_crop_image": str(capture_crop_image_path),
            "capture_diff_image": str(capture_diff_image_path),
            "crop": {
                "left": crop_box[0],
                "top": crop_box[1],
                "right": crop_box[2],
                "bottom": crop_box[3],
            },
            "base_address": base_address,
            "disk_size_bytes": disk_size_bytes,
            "minimum_similarity": min_similarity,
            "similarity": similarity,
            "mae": mae,
            "size_match": size_match,
        },
        "seconds": {
            "assemble": assemble.seconds,
            "package": package.seconds,
            "emulate": emulate.seconds,
            "verify": verify.seconds,
            "total": assemble.seconds + package.seconds + emulate.seconds + verify.seconds,
        },
    }

    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, indent=2), encoding="utf-8")

    print("---")
    print(f"benchmark:          {benchmark_label}")
    print(f"score:              {score:.6f}")
    print(f"assembled:          {str(assembled_ok).lower()}")
    print(f"packaged:           {str(packaged_ok).lower()}")
    print(f"emulator_ok:        {str((emulate.returncode == 0 and packaged_ok)).lower()}")
    print(f"benchmark_ok:       {str(benchmark_ok).lower()}")
    print(f"similarity:         {similarity:.6f}")
    print(f"main_source:        {main_source_path}")
    print(f"disk_image:         {disk_image_path}")
    print(f"capture_crop_image: {capture_crop_image_path}")
    print(f"report_path:        {report_path}")

    return 0 if benchmark_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
