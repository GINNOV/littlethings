#!/usr/bin/env python3
"""
Run a single autoresearch-style Amiga experiment:
edit -> assemble -> emulate -> score.

This script is intentionally generic and config-driven. It does not require a
specific assembler or emulator as long as the configured commands can run from
the shell.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import time
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

try:
    import tomllib  # Python 3.11+
except ModuleNotFoundError:  # pragma: no cover
    try:
        import tomli as tomllib  # type: ignore[no-redef]
    except ModuleNotFoundError as exc:  # pragma: no cover
        raise SystemExit(
            "Missing TOML parser: use Python 3.11+ or install tomli (pip install tomli)."
        ) from exc


DEFAULT_CRASH_PATTERNS = [
    r"guru meditation",
    r"illegal instruction",
    r"address error",
    r"bus error",
    r"exception",
]

ROM_EXTENSIONS = {".rom", ".bin", ".kick"}
PREFERRED_ROM_PATTERNS = [
    r"v1\.3",
    r"r34\.005",
    r"\ba500\b",
]


@dataclass
class CommandResult:
    command: str
    returncode: int
    timed_out: bool
    seconds: float
    stdout: str
    stderr: str
    executed: bool = True


@dataclass
class CheckResult:
    name: str
    kind: str
    passed: bool
    detail: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run one Amiga assembly evaluation.")
    parser.add_argument(
        "--config",
        default="amiga_eval.toml",
        help="Path to evaluator TOML config (default: amiga_eval.toml).",
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


def load_toml(path: Path) -> dict[str, Any]:
    with path.open("rb") as handle:
        data = tomllib.load(handle)
    return data


def resolve_path(base_dir: Path, raw: str) -> Path:
    expanded = os.path.expandvars(os.path.expanduser(raw))
    path = Path(expanded)
    if path.is_absolute():
        return path
    return (base_dir / path).resolve()


def env_flag(name: str, default: bool = False) -> bool:
    raw = os.environ.get(name, "").strip().lower()
    if raw in {"1", "true", "yes", "on"}:
        return True
    if raw in {"0", "false", "no", "off"}:
        return False
    return default


def list_kick_rom_candidates(rom_dir: Path) -> list[Path]:
    if not rom_dir.exists() or not rom_dir.is_dir():
        return []
    candidates = [path for path in rom_dir.iterdir() if path.is_file() and path.suffix.lower() in ROM_EXTENSIONS]
    candidates.sort(key=lambda path: path.name.lower())
    return candidates


def select_preferred_kick_rom(candidates: list[Path]) -> Path | None:
    if not candidates:
        return None
    for pattern in PREFERRED_ROM_PATTERNS:
        for candidate in candidates:
            if re.search(pattern, candidate.name, re.IGNORECASE):
                return candidate
    return candidates[0]


def resolve_kick_rom_path(config_dir: Path, paths: dict[str, Any], args: argparse.Namespace) -> Path:
    explicit_cli = str(args.kick_rom or "").strip()
    explicit_env = str(os.environ.get("AMIGA_KICK_ROM", "")).strip()
    explicit_cfg = str(paths.get("kick_rom", "")).strip()
    explicit_raw = explicit_cli or explicit_env or explicit_cfg

    rom_name_cli = str(args.kick_rom_name or "").strip()
    rom_name_env = str(os.environ.get("AMIGA_KICK_ROM_NAME", "")).strip()
    rom_name_cfg = str(paths.get("kick_rom_name", "")).strip()
    rom_name = rom_name_cli or rom_name_env or rom_name_cfg

    rom_dir_cli = str(args.kick_rom_dir or "").strip()
    rom_dir_env = str(os.environ.get("AMIGA_ROMS_DIR", "")).strip()
    rom_dir_cfg = str(paths.get("kick_rom_dir", "roms")).strip()
    rom_dir = resolve_path(config_dir, rom_dir_cli or rom_dir_env or rom_dir_cfg)

    if explicit_raw:
        explicit_path = resolve_path(config_dir, explicit_raw)
        if explicit_path.exists() and explicit_path.is_file():
            return explicit_path
        if explicit_path.exists() and explicit_path.is_dir():
            rom_dir = explicit_path
        elif "/" not in explicit_raw and "\\" not in explicit_raw:
            # Allow --kick-rom=<filename> as shorthand for name within ROM directory.
            rom_name = explicit_raw
        else:
            raise FileNotFoundError(f"Kickstart ROM not found: {explicit_path}")

    candidates = list_kick_rom_candidates(rom_dir)
    if not candidates:
        raise FileNotFoundError(
            f"No ROM files found in {rom_dir}. Add .rom files there or set --kick-rom / AMIGA_KICK_ROM."
        )

    if rom_name:
        for candidate in candidates:
            if candidate.name == rom_name:
                return candidate
        for candidate in candidates:
            if candidate.name.lower() == rom_name.lower():
                return candidate
        available = ", ".join(candidate.name for candidate in candidates)
        raise FileNotFoundError(
            f"Requested ROM '{rom_name}' not found in {rom_dir}. Available: {available}"
        )

    selected = select_preferred_kick_rom(candidates)
    if selected is None:
        raise FileNotFoundError(f"Unable to choose Kickstart ROM from {rom_dir}")
    return selected


def run_shell(command: str, timeout_seconds: float, cwd: Path) -> CommandResult:
    t0 = time.time()
    try:
        proc = subprocess.run(
            command,
            shell=True,
            cwd=str(cwd),
            capture_output=True,
            text=True,
            timeout=timeout_seconds,
        )
        return CommandResult(
            command=command,
            returncode=proc.returncode,
            timed_out=False,
            seconds=time.time() - t0,
            stdout=proc.stdout,
            stderr=proc.stderr,
        )
    except subprocess.TimeoutExpired as exc:
        timeout_stdout = exc.stdout or ""
        timeout_stderr = exc.stderr or ""
        if isinstance(timeout_stdout, bytes):
            timeout_stdout = timeout_stdout.decode("utf-8", errors="replace")
        if isinstance(timeout_stderr, bytes):
            timeout_stderr = timeout_stderr.decode("utf-8", errors="replace")
        return CommandResult(
            command=command,
            returncode=124,
            timed_out=True,
            seconds=time.time() - t0,
            stdout=timeout_stdout,
            stderr=timeout_stderr,
        )


def skipped_command(command: str) -> CommandResult:
    return CommandResult(
        command=command,
        returncode=0,
        timed_out=False,
        seconds=0.0,
        stdout="",
        stderr="",
        executed=False,
    )


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def read_text_if_exists(path: Path) -> str:
    if not path.exists():
        return ""
    return path.read_text(encoding="utf-8", errors="replace")


def parse_int(value: Any) -> int:
    if isinstance(value, int):
        return value
    if isinstance(value, str):
        return int(value, 0)
    raise ValueError(f"Expected int or numeric string, got {type(value)}")


def evaluate_regex_checks(
    regex_checks: list[dict[str, Any]],
    text: str,
    *,
    kind: str,
    default_name_prefix: str,
) -> list[CheckResult]:
    results: list[CheckResult] = []
    for i, check in enumerate(regex_checks):
        if not check.get("enabled", True):
            continue
        name = str(check.get("name", f"{default_name_prefix}_{i}"))
        pattern = str(check["pattern"])
        must_match = bool(check.get("must_match", True))
        ignore_case = bool(check.get("ignore_case", True))
        flags = re.IGNORECASE if ignore_case else 0

        found = re.search(pattern, text, flags) is not None
        passed = found if must_match else not found
        detail = f"pattern={'found' if found else 'missing'} must_match={must_match}"
        results.append(CheckResult(name=name, kind=kind, passed=passed, detail=detail))
    return results


def evaluate_memory_checks(memory_checks: list[dict[str, Any]], memory_path: Path) -> list[CheckResult]:
    results: list[CheckResult] = []
    memory = memory_path.read_bytes() if memory_path.exists() else b""

    for i, check in enumerate(memory_checks):
        if not check.get("enabled", True):
            continue
        name = str(check.get("name", f"memory_check_{i}"))
        offset = parse_int(check["offset"])
        expected = bytes.fromhex(str(check["bytes_hex"]))

        if not memory:
            results.append(
                CheckResult(
                    name=name,
                    kind="memory",
                    passed=False,
                    detail=f"missing memory dump at {memory_path}",
                )
            )
            continue

        end = offset + len(expected)
        if offset < 0 or end > len(memory):
            results.append(
                CheckResult(
                    name=name,
                    kind="memory",
                    passed=False,
                    detail=f"range [{offset}:{end}] outside dump size {len(memory)}",
                )
            )
            continue

        observed = memory[offset:end]
        passed = observed == expected
        detail = f"expected={expected.hex()} observed={observed.hex()}"
        results.append(CheckResult(name=name, kind="memory", passed=passed, detail=detail))
    return results


def detect_crash(log_text: str, patterns: list[str]) -> bool:
    for pattern in patterns:
        if re.search(pattern, log_text, re.IGNORECASE):
            return True
    return False


def main() -> int:
    args = parse_args()
    config_path = Path(args.config).resolve()
    config_dir = config_path.parent
    cfg = load_toml(config_path)

    paths = cfg.get("paths", {})
    commands = cfg.get("commands", {})
    timeouts = cfg.get("timeouts", {})
    metric = cfg.get("metric", {})

    source_path = resolve_path(config_dir, str(paths.get("source", "amiga_workspace/main.s")))
    build_dir = resolve_path(config_dir, str(paths.get("build_dir", "build/amiga")))
    artifact_path = resolve_path(config_dir, str(paths.get("artifact", "build/amiga/main")))
    disk_image_path = resolve_path(config_dir, str(paths.get("disk_image", "build/amiga/main.adf")))
    startup_sequence_path = resolve_path(
        config_dir, str(paths.get("startup_sequence", "amiga_workspace/startup-sequence"))
    )
    emulator_log_path = resolve_path(config_dir, str(paths.get("emulator_log", "build/amiga/emulator.log")))
    memory_dump_path = resolve_path(config_dir, str(paths.get("memory_dump", "build/amiga/memdump.bin")))
    disk_template_path = resolve_path(config_dir, str(paths.get("disk_template", "amiga_workspace/adf/system_template.adf")))
    emulator_screenshot_path = resolve_path(
        config_dir, str(paths.get("emulator_screenshot", "build/amiga/emulator_capture.png"))
    )
    kick_rom_path = resolve_kick_rom_path(config_dir, paths, args)
    vamiga_report_path = resolve_path(
        config_dir, str(paths.get("vamiga_report", "build/amiga/vamigaweb_report.json"))
    )

    report_path = (
        resolve_path(config_dir, args.report)
        if args.report
        else resolve_path(config_dir, str(paths.get("report", "build/amiga/report.json")))
    )

    build_dir.mkdir(parents=True, exist_ok=True)

    variables = {
        "source": str(source_path),
        "build_dir": str(build_dir),
        "artifact": str(artifact_path),
        "disk_image": str(disk_image_path),
        "startup_sequence": str(startup_sequence_path),
        "emulator_log": str(emulator_log_path),
        "memory_dump": str(memory_dump_path),
        "disk_template": str(disk_template_path),
        "emulator_screenshot": str(emulator_screenshot_path),
        "kick_rom": str(kick_rom_path),
        "vamiga_report": str(vamiga_report_path),
    }

    assemble_template = str(commands.get("assemble", "")).strip()
    package_template = str(commands.get("package", "")).strip()
    emulate_template = str(commands.get("emulate", "")).strip()
    verify_template = str(commands.get("verify", "")).strip()
    if not assemble_template:
        raise ValueError("Missing [commands].assemble in config.")
    if not emulate_template:
        raise ValueError("Missing [commands].emulate in config.")

    try:
        assemble_cmd = assemble_template.format(**variables)
        emulate_cmd = emulate_template.format(**variables)
        package_cmd = package_template.format(**variables) if package_template else ""
        verify_cmd = verify_template.format(**variables) if verify_template else ""
    except KeyError as exc:
        raise ValueError(f"Unknown command template variable: {exc}") from exc

    assemble_timeout = float(timeouts.get("assemble_seconds", 30))
    emulate_timeout = float(timeouts.get("emulate_seconds", 30))
    verify_timeout = float(timeouts.get("verify_seconds", 10))
    emulator_cfg = cfg.get("emulator", {})
    allow_nonzero_exit = bool(emulator_cfg.get("allow_nonzero_exit", False))
    allow_timeout_exit = bool(emulator_cfg.get("allow_timeout_exit", False))
    clear_log_before_run = bool(emulator_cfg.get("clear_log_before_run", True))
    verify_cfg = cfg.get("verify", {})
    verify_allow_nonzero_exit = bool(verify_cfg.get("allow_nonzero_exit", False))
    verify_allow_timeout_exit = bool(verify_cfg.get("allow_timeout_exit", False))
    verify_allow_nonzero_exit = env_flag(
        "AMIGA_VERIFY_ALLOW_NONZERO_EXIT", default=verify_allow_nonzero_exit
    )
    verify_allow_timeout_exit = env_flag(
        "AMIGA_VERIFY_ALLOW_TIMEOUT_EXIT", default=verify_allow_timeout_exit
    )
    crash_patterns = list(cfg.get("crash_detection", {}).get("patterns", DEFAULT_CRASH_PATTERNS))

    previous_emulator_log = ""
    if clear_log_before_run and emulator_log_path.exists():
        try:
            emulator_log_path.unlink()
        except OSError:
            # In sandboxed contexts we may not be able to mutate external logs.
            previous_emulator_log = read_text_if_exists(emulator_log_path)

    t0 = time.time()
    assemble = run_shell(assemble_cmd, timeout_seconds=assemble_timeout, cwd=config_dir)
    write_text(build_dir / "assemble.stdout.log", assemble.stdout)
    write_text(build_dir / "assemble.stderr.log", assemble.stderr)

    assembled_ok = (
        assemble.executed and not assemble.timed_out and assemble.returncode == 0 and artifact_path.exists()
    )

    package = skipped_command(package_cmd) if package_template else skipped_command("<none>")
    packaged_ok = True
    if assembled_ok and package_template:
        package = run_shell(package_cmd, timeout_seconds=assemble_timeout, cwd=config_dir)
        write_text(build_dir / "package.stdout.log", package.stdout)
        write_text(build_dir / "package.stderr.log", package.stderr)
        packaged_ok = package.executed and not package.timed_out and package.returncode == 0 and disk_image_path.exists()

    if assembled_ok and packaged_ok:
        emulate = run_shell(emulate_cmd, timeout_seconds=emulate_timeout, cwd=config_dir)
    else:
        emulate = skipped_command(emulate_cmd)

    write_text(build_dir / "emulate.stdout.log", emulate.stdout)
    write_text(build_dir / "emulate.stderr.log", emulate.stderr)

    verify = skipped_command(verify_cmd) if verify_template else skipped_command("<none>")
    if assembled_ok and packaged_ok and emulate.executed and verify_template:
        verify = run_shell(verify_cmd, timeout_seconds=verify_timeout, cwd=config_dir)

    write_text(build_dir / "verify.stdout.log", verify.stdout)
    write_text(build_dir / "verify.stderr.log", verify.stderr)

    emulator_log_text = read_text_if_exists(emulator_log_path)
    if previous_emulator_log and emulator_log_text.startswith(previous_emulator_log):
        emulator_log_text = emulator_log_text[len(previous_emulator_log):]
    combined_emulator_text = "\n".join(
        chunk for chunk in [emulate.stdout, emulate.stderr, emulator_log_text] if chunk
    )

    crash_detected = detect_crash(combined_emulator_text, crash_patterns)
    emulate_exit_ok = emulate.executed and (
        (
            not emulate.timed_out
            and (emulate.returncode == 0 or allow_nonzero_exit)
        )
        or (emulate.timed_out and allow_timeout_exit)
    )
    emulator_ok = assembled_ok and packaged_ok and emulate_exit_ok and not crash_detected
    verify_exit_ok = verify.executed and (
        (
            not verify.timed_out
            and (verify.returncode == 0 or verify_allow_nonzero_exit)
        )
        or (verify.timed_out and verify_allow_timeout_exit)
    )
    verify_ok = (not verify_template) or verify_exit_ok

    checks_section = cfg.get("checks", {})
    log_checks = list(checks_section.get("log_regex", []))
    memory_checks = list(checks_section.get("memory", []))
    verify_checks = list(checks_section.get("verify_regex", []))

    enabled_log_checks = [check for check in log_checks if check.get("enabled", True)]
    enabled_memory_checks = [check for check in memory_checks if check.get("enabled", True)]
    enabled_verify_checks = [check for check in verify_checks if check.get("enabled", True)]
    if env_flag("AMIGA_DISABLE_VERIFY_REGEX"):
        enabled_verify_checks = []

    check_results: list[CheckResult] = []
    if assembled_ok and emulate.executed:
        check_results.extend(
            evaluate_regex_checks(
                enabled_log_checks,
                combined_emulator_text,
                kind="log_regex",
                default_name_prefix="log_check",
            )
        )
        check_results.extend(evaluate_memory_checks(enabled_memory_checks, memory_dump_path))
    else:
        for i, check in enumerate(enabled_log_checks):
            name = str(check.get("name", f"log_check_{i}"))
            check_results.append(
                CheckResult(
                    name=name,
                    kind="log_regex",
                    passed=False,
                    detail="skipped: assembly/emulation did not run successfully",
                )
            )
        for i, check in enumerate(enabled_memory_checks):
            name = str(check.get("name", f"memory_check_{i}"))
            check_results.append(
                CheckResult(
                    name=name,
                    kind="memory",
                    passed=False,
                    detail="skipped: assembly/emulation did not run successfully",
                )
            )

    verify_text = "\n".join(chunk for chunk in [verify.stdout, verify.stderr] if chunk)
    if enabled_verify_checks:
        if verify_template and verify.executed:
            check_results.extend(
                evaluate_regex_checks(
                    enabled_verify_checks,
                    verify_text,
                    kind="verify_regex",
                    default_name_prefix="verify_check",
                )
            )
        else:
            reason = (
                "skipped: verification command did not run"
                if verify_template
                else "skipped: missing [commands].verify in config"
            )
            for i, check in enumerate(enabled_verify_checks):
                name = str(check.get("name", f"verify_check_{i}"))
                check_results.append(
                    CheckResult(name=name, kind="verify_regex", passed=False, detail=reason)
                )

    checks_total = len(check_results)
    checks_passed = sum(1 for check in check_results if check.passed)
    checks_ratio = 1.0 if checks_total == 0 else checks_passed / checks_total

    base_score = float(metric.get("base_score", 0.0))
    assemble_weight = float(metric.get("assemble_weight", 0.3))
    emulate_weight = float(metric.get("emulate_weight", 0.3))
    verify_weight = float(metric.get("verify_weight", 0.0))
    checks_weight = float(metric.get("checks_weight", 0.4))

    score = (
        base_score
        + assemble_weight * (1.0 if assembled_ok else 0.0)
        + emulate_weight * (1.0 if emulator_ok else 0.0)
        + verify_weight * (1.0 if verify_ok else 0.0)
        + checks_weight * checks_ratio
    )
    score = max(0.0, min(1.0, score))

    total_seconds = time.time() - t0

    report = {
        "score": score,
        "assembled": assembled_ok,
        "packaged": packaged_ok,
        "emulator_ok": emulator_ok,
        "verify_ok": verify_ok,
        "crash_detected": crash_detected,
        "checks_passed": checks_passed,
        "checks_total": checks_total,
        "checks_ratio": checks_ratio,
        "artifact": str(artifact_path),
        "disk_image": str(disk_image_path),
        "emulator_log": str(emulator_log_path),
        "memory_dump": str(memory_dump_path),
        "disk_template": str(disk_template_path),
        "emulator_screenshot": str(emulator_screenshot_path),
        "kick_rom": str(kick_rom_path),
        "kick_rom_name": kick_rom_path.name,
        "kick_rom_dir": str(kick_rom_path.parent),
        "vamiga_report": str(vamiga_report_path),
        "assemble": asdict(assemble),
        "package": asdict(package),
        "emulate": asdict(emulate),
        "verify": asdict(verify),
        "checks": [asdict(check) for check in check_results],
        "seconds": {
            "assemble": assemble.seconds,
            "package": package.seconds,
            "emulate": emulate.seconds,
            "verify": verify.seconds,
            "total": total_seconds,
        },
    }

    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, indent=2), encoding="utf-8")

    print("---")
    print(f"score:              {score:.6f}")
    print(f"assembled:          {str(assembled_ok).lower()}")
    print(f"packaged:           {str(packaged_ok).lower()}")
    print(f"emulator_ok:        {str(emulator_ok).lower()}")
    print(f"verify_ok:          {str(verify_ok).lower()}")
    print(f"crash_detected:     {str(crash_detected).lower()}")
    print(f"checks_passed:      {checks_passed}")
    print(f"checks_total:       {checks_total}")
    print(f"assemble_seconds:   {assemble.seconds:.2f}")
    print(f"package_seconds:    {package.seconds:.2f}")
    print(f"emulate_seconds:    {emulate.seconds:.2f}")
    print(f"verify_seconds:     {verify.seconds:.2f}")
    print(f"total_seconds:      {total_seconds:.2f}")
    print(f"report_path:        {report_path}")

    if check_results:
        print("check_results:")
        for check in check_results:
            status = "pass" if check.passed else "fail"
            print(f"  - {check.name} ({check.kind}): {status} ({check.detail})")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
