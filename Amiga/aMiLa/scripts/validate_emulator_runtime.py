#!/usr/bin/env python3
"""
Standalone emulator runtime validator for Amiga Playground.

This deliberately runs outside the XCTest/app-hosted process. vAmiga 4.2.1
accepts RetroShell document events from the user launch session, but the same
document delivery is not reliable from the app-under-test process.
"""

from __future__ import annotations

import argparse
import json
import os
import plistlib
import re
import shutil
import socket
import subprocess
import sys
import tempfile
import time
from dataclasses import dataclass
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
VAMIGA_APP = Path("/Applications/vAmiga.app")
VAMIGA_BUNDLE_ID = "dirkwhoffmann.vAmiga"
FRAME_WIDTH = 716
FRAME_HEIGHT = 285
FRAME_BYTES = FRAME_WIDTH * FRAME_HEIGHT * 3

SENTINEL_SOURCE = """; Handcrafted sentinel: unmistakable hardware display, never returns to AmigaDOS.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            move.w     #$7fff,$9a(a6)       ; disable interrupts
            move.w     #$7fff,$9c(a6)       ; clear interrupt requests
            move.w     #$7fff,$96(a6)       ; clear DMA channels
            move.w     #$00f,$180(a6)       ; immediate blue background
            lea        CopperList(pc),a0
            move.l     a0,$80(a6)           ; COP1LC
            move.w     #$0000,$88(a6)       ; COPJMP1
            move.w     #$8280,$96(a6)       ; DMAEN + COPEN
.forever:
            bra.s      .forever

            ALIGN      2
CopperList:
            dc.w       $0100,$0200          ; no bitplanes, color 0 only
            dc.w       $2c07,$fffe,$0180,$00f
            dc.w       $5007,$fffe,$0180,$0f0
            dc.w       $7407,$fffe,$0180,$f00
            dc.w       $9807,$fffe,$0180,$ff0
            dc.w       $bc07,$fffe,$0180,$0ff
            dc.w       $ffff,$fffe
"""


@dataclass
class ToolPaths:
    vasm: Path
    xdftool: Path
    ndk_include: Path


def run(args: list[str], *, timeout: int = 30) -> subprocess.CompletedProcess[str]:
    return subprocess.run(args, text=True, capture_output=True, timeout=timeout)


def shell_quote_for_applescript(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


def run_applescript(lines: list[str], *, timeout: int = 15) -> subprocess.CompletedProcess[str]:
    args = ["/usr/bin/osascript"]
    for line in lines:
        args.extend(["-e", line])
    return run(args, timeout=timeout)


def find_tool_paths() -> ToolPaths:
    vasm_candidates = [
        Path("/usr/local/bin/vasmm68k_mot"),
        Path("/opt/homebrew/bin/vasmm68k_mot"),
        Path("/usr/local/bin/vasm"),
        Path("/opt/homebrew/bin/vasm"),
    ]
    vasm = next((path for path in vasm_candidates if os.access(path, os.X_OK)), None)
    if vasm is None:
        raise RuntimeError("vasm/vasmm68k_mot was not found in /usr/local/bin or /opt/homebrew/bin")

    xdftool = REPO_ROOT / "fine_tuning/.venv/bin/xdftool"
    if not os.access(xdftool, os.X_OK):
        raise RuntimeError(f"xdftool was not found or executable at {xdftool}")

    ndk_include = REPO_ROOT / "Dataset/corpus3/amiga-dev/targets/m68k-amigaos/ndk/include_i"
    if not ndk_include.exists():
        raise RuntimeError(f"NDK include directory was not found at {ndk_include}")

    return ToolPaths(vasm=vasm, xdftool=xdftool, ndk_include=ndk_include)


def configured_rom_dir() -> Path | None:
    env_value = os.environ.get("AMIGA_SMOKE_ROM_DIR")
    if env_value:
        return Path(env_value).expanduser()

    defaults = run(["/usr/bin/defaults", "read", "GINNOV.AmigaPlayground", "romsDirectoryPath"], timeout=5)
    if defaults.returncode == 0 and defaults.stdout.strip():
        return Path(defaults.stdout.strip()).expanduser()

    common = Path.home() / "Documents/FS-UAE/Kickstarts"
    return common if common.exists() else None


def select_a500_rom(rom_dir: Path) -> Path:
    candidates = sorted(
        [
            path
            for path in rom_dir.rglob("*")
            if path.is_file() and path.suffix.lower() in {".rom", ".bin", ".kick"}
        ],
        key=lambda path: path.name.lower(),
    )
    def score(path: Path) -> tuple[int, str]:
        name = path.name.lower()
        value = 0
        # The validator checks the full ADF boot path, not just the CPU code.
        # With the current xdftool-created boot disk, Kickstart 1.3 reaches a
        # flat light-gray frame in vAmiga instead of executing startup-sequence.
        # Prefer ROMs that the sentinel matrix has proven can run this ADF.
        if "3.1" in name and ("a500" in name or "a600" in name or "a2000" in name):
            value -= 100
        if "2.04" in name and ("a500" in name or "a500+" in name or "a2000" in name):
            value -= 80
        if "2.05" in name and "a600" in name:
            value -= 70
        if "a500" in name or "a500+" in name:
            value -= 20
        if "a2000" in name:
            value -= 10
        if "1.3" in name or "34.005" in name or "34.5" in name or "315093-02" in name:
            value += 100
        return (value, name)

    preferred = [path for path in candidates if score(path)[0] < 0]
    preferred.sort(key=score)
    if preferred:
        return preferred[0]
    if candidates:
        return candidates[0]
    raise RuntimeError(f"No Kickstart ROM files were found in {rom_dir}")


def compile_sentinel(tools: ToolPaths, run_dir: Path) -> Path:
    source = run_dir / "handcrafted-sentinel.s"
    binary = run_dir / "playground_bin"
    source.write_text(SENTINEL_SOURCE, encoding="utf-8")
    result = run(
        [
            str(tools.vasm),
            "-kick1hunks",
            "-Fhunkexe",
            f"-I{tools.ndk_include}",
            "-o",
            str(binary),
            "-nosym",
            str(source),
        ],
        timeout=20,
    )
    if result.returncode != 0:
        raise RuntimeError(f"Sentinel assembly failed:\n{result.stdout}\n{result.stderr}")
    return binary


def create_adf(tools: ToolPaths, run_dir: Path, binary: Path) -> Path:
    adf = run_dir / "handcrafted-sentinel.adf"
    startup = run_dir / "startup-sequence"
    startup.write_text("playground_bin\n", encoding="utf-8")
    result = run(
        [
            str(tools.xdftool),
            str(adf),
            "create",
            "+",
            "format",
            "Playground",
            "+",
            "boot",
            "install",
            "+",
            "makedir",
            "s",
            "+",
            "write",
            str(startup),
            "s/startup-sequence",
            "+",
            "write",
            str(binary),
            "playground_bin",
        ],
        timeout=30,
    )
    if result.returncode != 0:
        raise RuntimeError(f"ADF creation failed:\n{result.stdout}\n{result.stderr}")
    return adf


def create_retrosh(
    run_dir: Path,
    rom: Path,
    adf: Path,
    *,
    name: str = "boot-sentinel",
    screenshot_bases: list[Path] | None = None,
    boot_wait: float = 6.0,
    capture_interval: float = 1.5,
) -> Path:
    script = run_dir / f"{name}.retrosh"
    capture_commands: list[str] = []
    if screenshot_bases:
        capture_commands.append(f"wait {max(1, int(round(boot_wait)))}")
        for index, base in enumerate(screenshot_bases):
            capture_commands.append(f'try screenshot save "{base}"')
            if index + 1 < len(screenshot_bases):
                capture_commands.append(f"wait {max(1, int(round(capture_interval)))}")

    script.write_text(
        "\n".join(
            [
                "try amiga init A500_OCS_1MB",
                "try server rshell set PORT 8080",
                "try server rshell start",
                f'try mem load rom "{rom}"',
                "try df0 eject",
                f'try df0 insert "{adf}"',
                "try amiga power on",
                "try amiga reset",
                *capture_commands,
                "",
            ]
        ),
        encoding="utf-8",
    )
    return script


def quit_vamiga() -> None:
    try:
        subprocess.run(
            ["/usr/bin/osascript", "-e", f'tell application id "{VAMIGA_BUNDLE_ID}" to quit'],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=5,
        )
    except subprocess.TimeoutExpired:
        pass

    deadline = time.monotonic() + 5
    while time.monotonic() < deadline:
        probe = subprocess.run(["/usr/bin/pgrep", "-x", "vAmiga"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if probe.returncode != 0:
            return
        time.sleep(0.25)

    subprocess.run(["/usr/bin/pkill", "-x", "vAmiga"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(1.0)


def launch_retrosh(script: Path) -> None:
    if not VAMIGA_APP.exists():
        raise RuntimeError(f"vAmiga was not found at {VAMIGA_APP}")

    result = run(
        [
            "/usr/bin/open",
            "-a",
            str(VAMIGA_APP),
            str(script),
        ],
        timeout=15,
    )
    if result.returncode != 0:
        raise RuntimeError(f"Failed to deliver RetroShell script to vAmiga:\n{result.stdout}\n{result.stderr}")

    # Activation is best-effort. The RetroShell document delivery above is the
    # authoritative launch action; capture paths separately prove visibility.
    run_applescript([f'tell application id "{VAMIGA_BUNDLE_ID}" to activate'], timeout=3)


def wait_for_vamiga_gui(timeout_seconds: float) -> None:
    deadline = time.monotonic() + timeout_seconds
    last_output = ""
    while time.monotonic() < deadline:
        result = run_applescript(
            [
                'tell application "System Events"',
                'if exists process "vAmiga" then tell process "vAmiga" to get exists menu bar item "Machine" of menu bar 1',
                'end tell',
            ],
            timeout=5,
        )
        last_output = (result.stdout + result.stderr).strip()
        if result.returncode == 0 and result.stdout.strip().lower() == "true":
            return
        time.sleep(0.5)
    raise RuntimeError(f"Timed out waiting for vAmiga GUI menu readiness. Last output: {last_output}")


def launch_visible_retrosh(script: Path) -> None:
    if not VAMIGA_APP.exists():
        raise RuntimeError(f"vAmiga was not found at {VAMIGA_APP}")

    open_app = run(["/usr/bin/open", "-n", "-a", str(VAMIGA_APP)], timeout=10)
    if open_app.returncode != 0:
        raise RuntimeError(f"Failed to launch vAmiga GUI:\n{open_app.stdout}\n{open_app.stderr}")

    wait_for_vamiga_gui(timeout_seconds=15)
    launch_retrosh(script)
    wait_for_vamiga_gui(timeout_seconds=10)


def launch_foreground_retrosh(script: Path) -> None:
    if not VAMIGA_APP.exists():
        raise RuntimeError(f"vAmiga was not found at {VAMIGA_APP}")

    open_app = run(["/usr/bin/open", "-n", "-a", str(VAMIGA_APP)], timeout=10)
    if open_app.returncode != 0:
        raise RuntimeError(f"Failed to launch vAmiga GUI:\n{open_app.stdout}\n{open_app.stderr}")

    time.sleep(3.0)
    launch_retrosh(script)


def wait_for_port(port: int, timeout_seconds: float) -> None:
    deadline = time.monotonic() + timeout_seconds
    last_error: Exception | None = None
    while time.monotonic() < deadline:
        try:
            with socket.create_connection(("127.0.0.1", port), timeout=1.0):
                return
        except OSError as error:
            last_error = error
            time.sleep(0.4)
    raise RuntimeError(f"Timed out waiting for RetroShell port {port}: {last_error}")


def send_retroshell(port: int, command: str, *, attempts: int = 3) -> str:
    last_error: OSError | None = None
    for attempt in range(attempts):
        try:
            with socket.create_connection(("127.0.0.1", port), timeout=3.0) as sock:
                sock.sendall(command.encode("utf-8") + b"\n")
                sock.shutdown(socket.SHUT_WR)
                chunks: list[bytes] = []
                while True:
                    chunk = sock.recv(4096)
                    if not chunk:
                        break
                    chunks.append(chunk)
            return b"".join(chunks).decode("utf-8", errors="replace")
        except OSError as error:
            last_error = error
            if attempt + 1 < attempts:
                time.sleep(0.5)
    raise last_error or RuntimeError("RetroShell command failed without an OS error")


def send_retroshell_interactive(port: int, commands: list[str], timeout: float = 2.0, attempts: int = 3) -> str:
    payload = "\n".join(commands) + "\n"
    last_error: OSError | None = None
    for attempt in range(attempts):
        try:
            with socket.create_connection(("127.0.0.1", port), timeout=3.0) as sock:
                sock.sendall(payload.encode("utf-8"))
                sock.settimeout(timeout)
                chunks: list[bytes] = []
                while True:
                    try:
                        chunk = sock.recv(8192)
                    except socket.timeout:
                        break
                    if not chunk:
                        break
                    chunks.append(chunk)
            return b"".join(chunks).decode("utf-8", errors="replace")
        except OSError as error:
            last_error = error
            if attempt + 1 < attempts:
                time.sleep(0.5)
    raise last_error or RuntimeError("Interactive RetroShell command failed without an OS error")


def capture_debug_state(run_dir: Path, port: int) -> dict[str, object]:
    state_text = send_retroshell_interactive(
        port,
        [
            ".",
            "r cpu",
            "r copper",
            "r agnus",
            "r denise",
            ".",
        ],
    )
    (run_dir / "vamiga-debug-state.txt").write_text(state_text, encoding="utf-8")

    def first_hex(label: str, text: str = state_text) -> str | None:
        match = re.search(rf"{re.escape(label)}\s+:\s+0x([0-9a-fA-F]+)", text)
        return match.group(1).lower() if match else None

    cop1lc = first_hex("COP1LC")
    copper_dump = ""
    if cop1lc:
        # The remote server can briefly reset the connection after leaving
        # debug mode. Retry once before treating the dump as missing.
        for _ in range(2):
            try:
                copper_dump = send_retroshell_interactive(port, [".", f"m.w ${cop1lc}", "."])
                break
            except OSError:
                time.sleep(0.4)
    (run_dir / "vamiga-copper-list.txt").write_text(copper_dump, encoding="utf-8")

    normalized_dump = " ".join(copper_dump.upper().split())
    expected_words = [
        "0100", "0200",
        "2C07", "FFFE", "0180", "000F",
        "5007", "FFFE", "0180", "00F0",
        "7407", "FFFE", "0180", "0F00",
        "9807", "FFFE", "0180", "0FF0",
        "BC07", "FFFE", "0180", "00FF",
        "FFFF", "FFFE",
    ]
    missing_words = [word for word in expected_words if word not in normalized_dump]

    evidence = {
        "pc": first_hex("PC"),
        "a6IsCustomChipBase": "0x00dff000" in state_text.lower(),
        "dmacon": first_hex("DMACON"),
        "bplcon0": first_hex("BPLCON0"),
        "cop1lc": cop1lc,
        "coppc": first_hex("COPPC"),
        "copins1": first_hex("COPINS1"),
        "copins2": first_hex("COPINS2"),
        "copperListMatchesSentinel": not missing_words,
        "missingCopperWords": missing_words,
        "stateTranscript": str(run_dir / "vamiga-debug-state.txt"),
        "copperListDump": str(run_dir / "vamiga-copper-list.txt"),
    }
    evidence["success"] = (
        evidence["a6IsCustomChipBase"] is True
        and evidence["bplcon0"] == "0200"
        and evidence["copins1"] == "2c07"
        and evidence["copins2"] == "fffe"
        and evidence["copperListMatchesSentinel"] is True
    )
    return evidence


def parse_hex_register(label: str, text: str) -> str | None:
    match = re.search(rf"{re.escape(label)}\s+:\s+0x([0-9a-fA-F]+)", text)
    return match.group(1).lower() if match else None


def capture_runtime_snapshot(run_dir: Path, port: int, name: str) -> dict[str, object]:
    state_text = send_retroshell_interactive(
        port,
        [
            ".",
            "r cpu",
            "r copper",
            "r agnus",
            "r denise",
            ".",
        ],
        timeout=2.0,
    )
    state_path = run_dir / f"{name}-state.txt"
    state_path.write_text(state_text, encoding="utf-8")

    pointers = {
        label: parse_hex_register(label, state_text)
        for label in ["COP1LC", "BPL1PT", "BPL0PT", "SPR0PT", "AUD0LC", "PC"]
    }

    dumps: dict[str, str] = {}
    dump_commands: dict[str, str] = {}
    for label, address in pointers.items():
        if label == "PC" or not address:
            continue
        if int(address, 16) == 0:
            continue
        command = f"m.w ${address}"
        try:
            dump = send_retroshell_interactive(port, [".", command, "."], timeout=2.0)
        except OSError as error:
            dump = f"ERROR: {error}"
        dumps[label] = dump
        dump_commands[label] = command
        (run_dir / f"{name}-{label.lower()}.txt").write_text(dump, encoding="utf-8")

    # Several templates animate by writing color registers directly rather
    # than changing bitplane memory. Sampling the custom color register range
    # catches that path without depending on host screenshots.
    try:
        custom_dump = send_retroshell_interactive(port, [".", "m.w $dff180", "."], timeout=2.0)
    except OSError as error:
        custom_dump = f"ERROR: {error}"
    dumps["CUSTOM_COLOR_REGS"] = custom_dump
    dump_commands["CUSTOM_COLOR_REGS"] = "m.w $dff180"
    (run_dir / f"{name}-custom-color-regs.txt").write_text(custom_dump, encoding="utf-8")

    return {
        "statePath": str(state_path),
        "pointers": pointers,
        "dumpCommands": dump_commands,
        "dumps": dumps,
    }


def normalized_dump(text: str) -> str:
    return "\n".join(line.strip() for line in text.splitlines() if line.strip() and not line.strip().startswith("vAmiga%"))


def capture_motion_debug_evidence(run_dir: Path, port: int, interval: float) -> dict[str, object]:
    before = capture_runtime_snapshot(run_dir, port, "motion-before")
    time.sleep(interval)
    after = capture_runtime_snapshot(run_dir, port, "motion-after")

    before_dumps = before.get("dumps", {})
    after_dumps = after.get("dumps", {})
    changed_keys: list[str] = []
    stable_keys: list[str] = []
    if isinstance(before_dumps, dict) and isinstance(after_dumps, dict):
        for key in sorted(set(before_dumps).intersection(after_dumps)):
            left = normalized_dump(str(before_dumps[key]))
            right = normalized_dump(str(after_dumps[key]))
            if left and right and left != right:
                changed_keys.append(key)
            elif left and right:
                stable_keys.append(key)

    before_pc = (before.get("pointers") or {}).get("PC") if isinstance(before.get("pointers"), dict) else None
    after_pc = (after.get("pointers") or {}).get("PC") if isinstance(after.get("pointers"), dict) else None
    pc_changed = before_pc is not None and after_pc is not None and before_pc != after_pc

    # PC-only changes are too weak: a static wait loop also changes PC/raster
    # state. Require active display-related memory/register evidence.
    success = bool(changed_keys)
    return {
        "success": success,
        "before": {key: value for key, value in before.items() if key != "dumps"},
        "after": {key: value for key, value in after.items() if key != "dumps"},
        "changedKeys": changed_keys,
        "stableKeys": stable_keys,
        "pcChanged": pc_changed,
        "summary": "changed display state: " + ", ".join(changed_keys) if changed_keys else "no watched display memory/register dump changed",
    }


def capture_raw_frame(run_dir: Path, port: int, *, stem: str = "vamiga-raw-frame") -> Path:
    base = run_dir / stem
    for candidate in [base, base.with_suffix(".raw"), base.with_suffix(".data")]:
        try:
            candidate.unlink()
        except FileNotFoundError:
            pass

    deadline = time.monotonic() + 15
    last_error: Exception | None = None
    while time.monotonic() < deadline:
        try:
            wait_for_port(port, timeout_seconds=2)
            send_retroshell(port, f'screenshot save "{base}"', attempts=5)
            break
        except Exception as error:
            last_error = error
            time.sleep(0.5)

    candidates = [base, base.with_suffix(".raw"), base.with_suffix(".data")]
    while time.monotonic() < deadline:
        for candidate in candidates:
            if candidate.exists() and candidate.stat().st_size == FRAME_BYTES:
                return candidate
        time.sleep(0.2)
    found = [(str(path), path.stat().st_size) for path in candidates if path.exists()]
    raise RuntimeError(f"vAmiga did not write the expected raw frame ({FRAME_BYTES} bytes). Found: {found}. Last error: {last_error}")


def wait_for_scripted_raw_frame(base: Path, timeout_seconds: float) -> Path:
    candidates = [base, base.with_suffix(".raw"), base.with_suffix(".data")]
    deadline = time.monotonic() + timeout_seconds
    while time.monotonic() < deadline:
        for candidate in candidates:
            if candidate.exists() and candidate.stat().st_size == FRAME_BYTES:
                return candidate
        time.sleep(0.2)
    found = [(str(path), path.stat().st_size) for path in candidates if path.exists()]
    raise RuntimeError(f"vAmiga did not write scripted raw frame {base.name} ({FRAME_BYTES} bytes). Found: {found}")


def analyze_raw_frame(raw: Path) -> dict[str, int | str]:
    data = raw.read_bytes()
    if len(data) != FRAME_BYTES:
        raise RuntimeError(f"Unexpected raw frame size {len(data)}, expected {FRAME_BYTES}")

    non_black = 0
    bright = 0
    dark = 0
    min_brightness = 255
    max_brightness = 0
    buckets: set[tuple[int, int, int]] = set()
    max_spread = 0
    neutral_gray = 0
    workbench_blue = 0
    sampled = 0

    for idx in range(0, len(data), 3):
        r, g, b = data[idx], data[idx + 1], data[idx + 2]
        sampled += 1
        brightness = max(r, g, b)
        min_brightness = min(min_brightness, brightness)
        max_brightness = max(max_brightness, brightness)
        spread = max(r, g, b) - min(r, g, b)
        max_spread = max(max_spread, spread)
        buckets.add((r // 16, g // 16, b // 16))
        summed_brightness = r + g + b
        if spread <= 12 and 96 <= summed_brightness <= 690:
            neutral_gray += 1
        if b >= 120 and b > r + 35 and b >= g + 8 and r <= 150 and g <= 190:
            workbench_blue += 1
        if r > 8 or g > 8 or b > 8:
            non_black += 1
        if brightness > 160:
            bright += 1
        if brightness < 16:
            dark += 1

    return {
        "rawFrame": str(raw),
        "width": FRAME_WIDTH,
        "height": FRAME_HEIGHT,
        "bytes": len(data),
        "nonBlackPixels": non_black,
        "brightPixels": bright,
        "darkPixels": dark,
        "brightnessRange": max_brightness - min_brightness,
        "uniqueColorBuckets": len(buckets),
        "maxChannelSpread": max_spread,
        "neutralGrayPixels": neutral_gray,
        "workbenchBluePixels": workbench_blue,
        "sampledPixels": sampled,
    }


def is_likely_workbench_or_amigados(analysis: dict[str, int | str]) -> bool:
    sampled = int(analysis.get("sampledPixels", 0))
    if sampled <= 0:
        return False
    neutral_ratio = int(analysis.get("neutralGrayPixels", 0)) / sampled
    blue_ratio = int(analysis.get("workbenchBluePixels", 0)) / sampled
    return (
        neutral_ratio >= 0.42
        and blue_ratio >= 0.01
        and int(analysis.get("darkPixels", 0)) > 20
        and int(analysis.get("brightnessRange", 0)) >= 120
    )


def is_likely_flat_or_placeholder(analysis: dict[str, int | str]) -> bool:
    sampled = int(analysis.get("sampledPixels", 0))
    if sampled <= 0:
        return True
    neutral_ratio = int(analysis.get("neutralGrayPixels", 0)) / sampled
    return (
        int(analysis.get("nonBlackPixels", 0)) <= 0
        or (
            neutral_ratio >= 0.90
            and int(analysis.get("uniqueColorBuckets", 0)) <= 2
            and int(analysis.get("maxChannelSpread", 0)) <= 12
            and int(analysis.get("darkPixels", 0)) == 0
        )
    )


def is_flat_solid_frame(analysis: dict[str, int | str]) -> bool:
    sampled = int(analysis.get("sampledPixels", 0))
    if sampled <= 0:
        return True
    return (
        int(analysis.get("uniqueColorBuckets", 0)) <= 1
        and int(analysis.get("brightnessRange", 0)) <= 2
        and int(analysis.get("maxChannelSpread", 0)) <= 4
    )


def raw_frame_difference(left: Path, right: Path) -> dict[str, int | float | str]:
    left_data = left.read_bytes()
    right_data = right.read_bytes()
    if len(left_data) != len(right_data):
        raise RuntimeError(f"Cannot compare raw frames with different sizes: {len(left_data)} vs {len(right_data)}")

    changed_pixels = 0
    max_delta = 0
    sample_pixels = 0
    for idx in range(0, len(left_data), 12):
        dr = abs(left_data[idx] - right_data[idx])
        dg = abs(left_data[idx + 1] - right_data[idx + 1])
        db = abs(left_data[idx + 2] - right_data[idx + 2])
        delta = max(dr, dg, db)
        max_delta = max(max_delta, delta)
        if delta >= 16:
            changed_pixels += 1
        sample_pixels += 1

    ratio = changed_pixels / sample_pixels if sample_pixels else 0.0
    return {
        "left": str(left),
        "right": str(right),
        "sampledPixels": sample_pixels,
        "changedPixels": changed_pixels,
        "changedRatio": ratio,
        "maxDelta": max_delta,
    }


def expectation_passes(
    expectation: str,
    analyses: list[dict[str, int | str]],
    differences: list[dict[str, int | float | str]],
    motion_evidence: dict[str, object] | None = None,
) -> tuple[bool, list[str]]:
    failures: list[str] = []
    first = analyses[0]

    if is_likely_workbench_or_amigados(first):
        failures.append("captured frame looks like Workbench/AmigaDOS rather than a hardware demo")
    if expectation != "nonvisual" and is_likely_flat_or_placeholder(first):
        failures.append("captured frame is flat, black, or a placeholder")

    if expectation == "any-visual":
        if int(first.get("nonBlackPixels", 0)) <= 1_000:
            failures.append("visual prompt produced too few non-black pixels")
    elif expectation == "text":
        if is_flat_solid_frame(first):
            failures.append("text prompt captured a flat solid frame")
        if int(first.get("brightPixels", 0)) <= 200:
            failures.append("text prompt did not produce enough bright text evidence")
        if int(first.get("darkPixels", 0)) <= 1_000:
            failures.append("text prompt did not preserve a dark contrasting background")
    elif expectation == "motion":
        if is_flat_solid_frame(first):
            failures.append("motion prompt captured a flat solid frame")
        if int(first.get("nonBlackPixels", 0)) <= 100:
            failures.append("motion prompt produced too few non-black pixels")
        image_motion = bool(differences) and any(float(diff["changedRatio"]) >= 0.002 and int(diff["maxDelta"]) >= 16 for diff in differences)
        state_motion = bool(motion_evidence and motion_evidence.get("success") is True)
        if not image_motion and not state_motion:
            failures.append("motion prompt did not produce enough image or emulator-state change over time")
    elif expectation == "nonvisual":
        pass
    else:
        failures.append(f"unknown expectation: {expectation}")

    return (not failures, failures)


def analyze_image(image_path: Path) -> dict[str, int | str | tuple[int, int]]:
    try:
        from PIL import Image  # type: ignore
    except Exception as error:
        raise RuntimeError("Pillow is required to analyze the GUI screenshot image") from error

    image = Image.open(image_path).convert("RGB")
    data = list(image.getdata())
    non_black = 0
    bright = 0
    dark = 0
    min_brightness = 255
    max_brightness = 0
    buckets: set[tuple[int, int, int]] = set()
    max_spread = 0

    for r, g, b in data:
        brightness = max(r, g, b)
        min_brightness = min(min_brightness, brightness)
        max_brightness = max(max_brightness, brightness)
        max_spread = max(max_spread, max(r, g, b) - min(r, g, b))
        buckets.add((r // 16, g // 16, b // 16))
        if r > 8 or g > 8 or b > 8:
            non_black += 1
        if brightness > 160:
            bright += 1
        if brightness < 16:
            dark += 1

    return {
        "image": str(image_path),
        "width": image.width,
        "height": image.height,
        "pixels": len(data),
        "nonBlackPixels": non_black,
        "brightPixels": bright,
        "darkPixels": dark,
        "brightnessRange": max_brightness - min_brightness,
        "uniqueColorBuckets": len(buckets),
        "maxChannelSpread": max_spread,
    }


def image_difference(left: Path, right: Path) -> dict[str, int | float | str]:
    try:
        from PIL import Image  # type: ignore
    except Exception as error:
        raise RuntimeError("Pillow is required to compare GUI screenshots") from error

    left_image = Image.open(left).convert("RGB")
    right_image = Image.open(right).convert("RGB")
    width = min(left_image.width, right_image.width)
    height = min(left_image.height, right_image.height)
    left_crop = left_image.crop((0, 0, width, height))
    right_crop = right_image.crop((0, 0, width, height))
    left_pixels = left_crop.load()
    right_pixels = right_crop.load()

    changed_pixels = 0
    sample_pixels = 0
    max_delta = 0
    for y in range(0, height, 4):
        for x in range(0, width, 4):
            lr, lg, lb = left_pixels[x, y]
            rr, rg, rb = right_pixels[x, y]
            delta = max(abs(lr - rr), abs(lg - rg), abs(lb - rb))
            max_delta = max(max_delta, delta)
            if delta >= 16:
                changed_pixels += 1
            sample_pixels += 1

    ratio = changed_pixels / sample_pixels if sample_pixels else 0.0
    return {
        "left": str(left),
        "right": str(right),
        "sampledPixels": sample_pixels,
        "changedPixels": changed_pixels,
        "changedRatio": ratio,
        "maxDelta": max_delta,
    }


def vamiga_window_rect() -> tuple[int, int, int, int]:
    result = run_applescript(
        [
            f'tell application id "{VAMIGA_BUNDLE_ID}" to activate',
            "delay 0.2",
            'tell application "System Events"',
            'tell process "vAmiga"',
            "set frontmost to true",
            "repeat with candidateWindow in windows",
            'if value of attribute "AXMinimized" of candidateWindow is false then',
            "set windowPosition to position of candidateWindow",
            "set windowSize to size of candidateWindow",
            "return (item 1 of windowPosition as integer) & \",\" & (item 2 of windowPosition as integer) & \",\" & (item 1 of windowSize as integer) & \",\" & (item 2 of windowSize as integer)",
            "end if",
            "end repeat",
            "end tell",
            "end tell",
        ],
        timeout=10,
    )
    if result.returncode != 0:
        raise RuntimeError(f"Could not read vAmiga window bounds:\n{result.stdout}\n{result.stderr}")

    match = re.search(r"(-?\d+),(-?\d+),(\d+),(\d+)", result.stdout.strip())
    if not match:
        raise RuntimeError(f"Could not parse vAmiga window bounds from: {result.stdout!r}")

    x, y, width, height = (int(group) for group in match.groups())
    if width < 100 or height < 100:
        raise RuntimeError(f"vAmiga window bounds are too small to validate: {(x, y, width, height)}")
    return x, y, width, height


def capture_vamiga_window_png(path: Path) -> tuple[Path, tuple[int, int, int, int]]:
    rect = vamiga_window_rect()
    region = ",".join(str(value) for value in rect)
    result = run(["/usr/sbin/screencapture", "-x", "-R", region, str(path)], timeout=10)
    if result.returncode != 0:
        raise RuntimeError(f"screencapture failed for vAmiga window region {region}:\n{result.stdout}\n{result.stderr}")
    if not path.exists() or path.stat().st_size == 0:
        raise RuntimeError(f"screencapture did not create {path}")
    return path, rect


def write_ppm(raw: Path, ppm: Path) -> None:
    ppm.write_bytes(f"P6\n{FRAME_WIDTH} {FRAME_HEIGHT}\n255\n".encode("ascii") + raw.read_bytes())


def write_png_if_possible(raw: Path, png: Path) -> bool:
    try:
        from PIL import Image  # type: ignore
    except Exception:
        return False
    image = Image.frombytes("RGB", (FRAME_WIDTH, FRAME_HEIGHT), raw.read_bytes())
    image.save(png)
    return True


def screenshot_folder() -> Path:
    return Path.home() / "Library/Application Support/vAmiga/Screenshots"


def capture_gui_screenshot(run_dir: Path) -> Path:
    folder = screenshot_folder()
    before = set(folder.glob("*")) if folder.exists() else set()

    result = run_applescript(
        [
            f'tell application id "{VAMIGA_BUNDLE_ID}" to activate',
            "delay 0.5",
            'tell application "System Events"',
            'tell process "vAmiga"',
            'tell menu bar 1 to tell menu bar item "Machine" to tell menu 1 to click menu item "Take Screenshot"',
            "end tell",
            "end tell",
        ],
        timeout=10,
    )
    if result.returncode != 0:
        raise RuntimeError(f"Failed to invoke vAmiga GUI screenshot:\n{result.stdout}\n{result.stderr}")

    deadline = time.monotonic() + 10
    while time.monotonic() < deadline:
        current = set(folder.glob("*")) if folder.exists() else set()
        created = sorted(current - before, key=lambda path: path.stat().st_mtime, reverse=True)
        for candidate in created:
            if candidate.suffix.lower() in {".png", ".jpg", ".jpeg", ".tiff", ".bmp"} and candidate.stat().st_size > 0:
                copy = run_dir / f"vamiga-gui-screenshot{candidate.suffix.lower()}"
                shutil.copy2(candidate, copy)
                return copy
        time.sleep(0.25)

    raise RuntimeError(f"vAmiga GUI screenshot did not create a new image in {folder}")


def fsuae_executable() -> Path | None:
    candidates = [
        Path("/opt/homebrew/bin/fs-uae"),
        Path("/usr/local/bin/fs-uae"),
        Path("/Applications/FS-UAE.app/Contents/MacOS/fs-uae"),
    ]
    return next((path for path in candidates if os.access(path, os.X_OK)), None)


def latest_image_file(directory: Path, modified_after: float) -> Path | None:
    candidates = [
        path
        for path in directory.glob("*")
        if path.is_file()
        and path.suffix.lower() in {".png", ".jpg", ".jpeg", ".bmp", ".tiff", ".tif"}
        and path.stat().st_mtime >= modified_after
        and path.stat().st_size > 0
    ]
    return max(candidates, key=lambda path: path.stat().st_mtime) if candidates else None


def trigger_fsuae_screenshot() -> list[dict[str, object]]:
    attempts: list[dict[str, object]] = []
    scripts = [
        (
            "cmd-s",
            [
                'tell application id "no.fengestad.fs-uae" to activate',
                "delay 0.2",
                'tell application "System Events" to key code 1 using command down',
            ],
        ),
        (
            "f12",
            [
                'tell application id "no.fengestad.fs-uae" to activate',
                "delay 0.2",
                'tell application "System Events" to key code 111',
            ],
        ),
    ]
    for name, lines in scripts:
        result = run_applescript(lines, timeout=6)
        attempts.append({
            "method": name,
            "status": result.returncode,
            "stdout": result.stdout.strip(),
            "stderr": result.stderr.strip(),
        })
    return attempts


def capture_fsuae_image(run_dir: Path, rom: Path, adf: Path) -> dict[str, object]:
    executable = fsuae_executable()
    if executable is None:
        return {"success": False, "method": "fs-uae-screenshot", "error": "FS-UAE executable was not found"}

    screenshot_dir = run_dir / "fs-uae-screenshots"
    screenshot_dir.mkdir(parents=True, exist_ok=True)
    for path in screenshot_dir.glob("*"):
        if path.is_file():
            path.unlink()

    args = [
        str(executable),
        f"--floppy_drive_0={adf}",
        "--amiga_model=A500",
        "--chip_memory=1024",
        "--fast_memory=0",
        "--cpu=68000",
        "--jit=0",
        f"--kickstart_file={rom}",
        f"--screenshots_output_dir={screenshot_dir}",
        "--screenshots_output_mask=3",
        "--screenshots_output_prefix=sentinel",
        "--keyboard_key_f12=action_screenshot",
        "--window_width=720",
        "--window_height=576",
    ]
    started_at = time.time()
    process = subprocess.Popen(args, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    trigger_attempts: list[dict[str, object]] = []
    try:
        time.sleep(8.0)
        deadline = time.monotonic() + 12.0
        while time.monotonic() < deadline:
            trigger_attempts.extend(trigger_fsuae_screenshot())
            time.sleep(1.0)
            screenshot = latest_image_file(screenshot_dir, started_at)
            if screenshot is not None:
                analysis = analyze_image(screenshot)
                return {
                    "success": True,
                    "method": "fs-uae-screenshot",
                    "screenshot": str(screenshot),
                    "analysis": analysis,
                    "triggerAttempts": trigger_attempts,
                }
        files = [{"name": path.name, "bytes": path.stat().st_size} for path in sorted(screenshot_dir.glob("*"))]
        return {
            "success": False,
            "method": "fs-uae-screenshot",
            "error": "FS-UAE did not create a screenshot image after configured screenshot triggers",
            "files": files,
            "triggerAttempts": trigger_attempts,
            "processReturnCode": process.poll(),
        }
    finally:
        if process.poll() is None:
            process.terminate()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait(timeout=5)


def validate_prompt_adf(
    *,
    run_dir: Path,
    rom: Path,
    adf: Path,
    expectation: str,
    label: str,
    template_id: str,
    raw_captures: int,
    capture_interval: float,
    boot_wait: float,
    capture_gui: bool,
) -> dict[str, object]:
    if not adf.exists():
        raise RuntimeError(f"ADF was not found at {adf}")

    raw_capture_count = max(1, raw_captures)
    script = create_retrosh(run_dir, rom, adf, name="boot-prompt-adf")
    quit_vamiga()
    time.sleep(1.0)
    launch_retrosh(script)
    wait_for_port(8080, timeout_seconds=20)
    time.sleep(boot_wait)

    motion_evidence: dict[str, object] | None = None
    if expectation == "motion":
        motion_evidence = capture_motion_debug_evidence(run_dir, 8080, capture_interval)

    raw_paths: list[Path] = []
    analyses: list[dict[str, int | str]] = []
    capture_failures: list[str] = []
    for index in range(raw_capture_count):
        try:
            raw = capture_raw_frame(run_dir, 8080, stem=f"vamiga-raw-frame-{index + 1}")
        except Exception as error:
            capture_failures.append(f"raw capture {index + 1} of {raw_capture_count} failed: {error}")
            break
        raw_paths.append(raw)
        analyses.append(analyze_raw_frame(raw))
        write_ppm(raw, run_dir / f"vamiga-raw-frame-{index + 1}.ppm")
        write_png_if_possible(raw, run_dir / f"vamiga-raw-frame-{index + 1}.png")
        if index + 1 < raw_capture_count:
            time.sleep(capture_interval)
    if len(raw_paths) < raw_capture_count:
        capture_failures.append(f"captured {len(raw_paths)} of {raw_capture_count} requested raw frames")

    raw_differences = [
        raw_frame_difference(left, right)
        for left, right in zip(raw_paths, raw_paths[1:])
    ]
    differences = list(raw_differences)

    gui_motion_capture: dict[str, object] | None = None
    if expectation == "motion" and capture_gui:
        try:
            gui_script = create_retrosh(run_dir, rom, adf, name="boot-prompt-gui")
            quit_vamiga()
            time.sleep(1.0)
            launch_foreground_retrosh(gui_script)
            time.sleep(boot_wait)

            screenshots: list[Path] = []
            screenshot_rects: list[tuple[int, int, int, int]] = []
            gui_analyses: list[dict[str, int | str | tuple[int, int]]] = []
            for index in range(max(2, raw_captures)):
                screenshot, rect = capture_vamiga_window_png(run_dir / f"vamiga-window-motion-{index + 1}.png")
                screenshots.append(screenshot)
                screenshot_rects.append(rect)
                gui_analyses.append(analyze_image(screenshot))
                if index + 1 < max(2, raw_captures):
                    time.sleep(capture_interval)

            gui_differences = [
                image_difference(left, right)
                for left, right in zip(screenshots, screenshots[1:])
            ]
            differences.extend(gui_differences)
            gui_motion_capture = {
                "success": True,
                "screenshots": [str(path) for path in screenshots],
                "captureRects": [list(rect) for rect in screenshot_rects],
                "analyses": gui_analyses,
                "differences": gui_differences,
            }
        except Exception as error:
            gui_motion_capture = {
                "success": False,
                "error": str(error),
            }

    if analyses:
        success, failures = expectation_passes(expectation, analyses, differences, motion_evidence)
    else:
        success = False
        failures = ["no raw frame was captured"]
    failures.extend(capture_failures)
    success = success and not capture_failures

    gui_capture: dict[str, object] | None = None
    if capture_gui and expectation != "motion":
        quit_vamiga()
        time.sleep(1.0)
        launch_visible_retrosh(script)
        wait_for_port(8080, timeout_seconds=20)
        time.sleep(boot_wait)
        gui_screenshot, gui_rect = capture_vamiga_window_png(run_dir / "vamiga-window-screenshot.png")
        gui_analysis = analyze_image(gui_screenshot)
        gui_capture = {
            "screenshot": str(gui_screenshot),
            "captureRect": list(gui_rect),
            "analysis": gui_analysis,
        }
        if int(gui_analysis["nonBlackPixels"]) <= 1_000:
            failures.append("GUI capture produced too few non-black pixels")
        if int(gui_analysis["uniqueColorBuckets"]) <= 1 and expectation != "nonvisual":
            failures.append("GUI capture was too flat for a visual prompt")
        success = success and not failures

    manifest: dict[str, object] = {
        "success": success,
        "mode": "adf",
        "label": label,
        "templateID": template_id,
        "expectation": expectation,
        "artifactDirectory": str(run_dir),
        "adf": str(adf),
        "retroShellScript": str(script),
        "rawCaptures": [str(path) for path in raw_paths],
        "analyses": analyses,
        "rawDifferences": raw_differences,
        "differences": differences,
        "failures": failures,
    }
    if motion_evidence is not None:
        manifest["motionEvidence"] = motion_evidence
    if gui_capture is not None:
        manifest["guiCapture"] = gui_capture
    if gui_motion_capture is not None:
        manifest["guiMotionCapture"] = gui_motion_capture
    return manifest


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate vAmiga runtime frame capture with a handcrafted sentinel ADF.")
    parser.add_argument("--output-dir", type=Path, default=None, help="Artifact directory. Defaults to a temp directory.")
    parser.add_argument("--rom-dir", type=Path, default=None, help="Kickstart ROM directory. Defaults to AMIGA_SMOKE_ROM_DIR or app settings.")
    parser.add_argument("--adf", type=Path, default=None, help="Validate an existing bootable ADF instead of generating the sentinel ADF.")
    parser.add_argument("--expectation", choices=["any-visual", "text", "motion", "nonvisual"], default="any-visual", help="Runtime expectation for --adf mode.")
    parser.add_argument("--label", default="", help="Human-readable prompt or case name for --adf mode.")
    parser.add_argument("--template-id", default="", help="Template identifier for --adf mode.")
    parser.add_argument("--raw-captures", type=int, default=2, help="Number of raw frames to capture in --adf mode.")
    parser.add_argument("--capture-interval", type=float, default=1.5, help="Seconds between raw captures in --adf mode.")
    parser.add_argument("--boot-wait", type=float, default=6.0, help="Seconds to wait after boot/reset before capturing.")
    parser.add_argument("--skip-gui", action="store_true", help="Skip GUI screenshot capture in --adf mode.")
    parser.add_argument("--allow-state-second-path", action="store_true", help="Allow RetroShell debug state as the sentinel second path when host image capture is unavailable.")
    parser.add_argument("--keep-vamiga-running", action="store_true", help="Do not quit vAmiga after capture.")
    args = parser.parse_args()

    run_dir = args.output_dir or Path(tempfile.mkdtemp(prefix="amila-runtime-validator-"))
    run_dir.mkdir(parents=True, exist_ok=True)

    try:
        tools = find_tool_paths()
        rom_dir = args.rom_dir or configured_rom_dir()
        if rom_dir is None:
            raise RuntimeError("No ROM directory configured. Set AMIGA_SMOKE_ROM_DIR or configure the app ROM directory.")
        rom = select_a500_rom(rom_dir)

        if args.adf is not None:
            manifest = validate_prompt_adf(
                run_dir=run_dir,
                rom=rom,
                adf=args.adf,
                expectation=args.expectation,
                label=args.label,
                template_id=args.template_id,
                raw_captures=args.raw_captures,
                capture_interval=args.capture_interval,
                boot_wait=args.boot_wait,
                capture_gui=not args.skip_gui,
            )
            (run_dir / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
            print(json.dumps(manifest, indent=2))
            return 0 if manifest["success"] is True else 2

        binary = compile_sentinel(tools, run_dir)
        adf = create_adf(tools, run_dir, binary)
        script = create_retrosh(run_dir, rom, adf)

        quit_vamiga()
        time.sleep(1.0)
        launch_retrosh(script)
        wait_for_port(8080, timeout_seconds=20)
        time.sleep(6.0)
        state_evidence = capture_debug_state(run_dir, 8080)
        raw = capture_raw_frame(run_dir, 8080)

        analysis = analyze_raw_frame(raw)
        ppm = run_dir / "vamiga-raw-frame.ppm"
        png = run_dir / "vamiga-raw-frame.png"
        write_ppm(raw, ppm)
        png_written = write_png_if_possible(raw, png)

        quit_vamiga()
        time.sleep(1.0)
        launch_visible_retrosh(script)
        wait_for_port(8080, timeout_seconds=20)
        time.sleep(6.0)
        gui_state_evidence = capture_debug_state(run_dir, 8080)
        gui_capture: dict[str, object]
        try:
            gui_screenshot, gui_rect = capture_vamiga_window_png(run_dir / "vamiga-window-screenshot.png")
            gui_analysis = analyze_image(gui_screenshot)
            gui_capture = {
                "success": True,
                "method": "macos-window-screenshot",
                "screenshot": str(gui_screenshot),
                "captureRect": list(gui_rect),
                "stateEvidence": gui_state_evidence,
                "analysis": gui_analysis,
            }
        except Exception as window_error:
            try:
                gui_screenshot = capture_gui_screenshot(run_dir)
                gui_analysis = analyze_image(gui_screenshot)
                gui_capture = {
                    "success": True,
                    "method": "vamiga-gui-menu-screenshot",
                    "screenshot": str(gui_screenshot),
                    "windowCaptureError": str(window_error),
                    "stateEvidence": gui_state_evidence,
                    "analysis": gui_analysis,
                }
            except Exception as menu_error:
                gui_analysis = None
                gui_capture = {
                    "success": False,
                    "error": str(menu_error),
                    "windowCaptureError": str(window_error),
                    "stateEvidence": gui_state_evidence,
                }
        fsuae_capture: dict[str, object] | None = None
        if gui_capture["success"] is not True:
            fsuae_capture = capture_fsuae_image(run_dir, rom, adf)

        raw_success = (
            state_evidence["success"] is True
            and
            analysis["nonBlackPixels"] > 10_000
            and analysis["uniqueColorBuckets"] >= 3
            and analysis["maxChannelSpread"] > 40
        )
        gui_image_success = (
            gui_capture["success"] is True
            and gui_state_evidence["success"] is True
            and gui_analysis is not None
            and gui_analysis["nonBlackPixels"] > 10_000
            and gui_analysis["uniqueColorBuckets"] >= 3
            and gui_analysis["maxChannelSpread"] > 40
        )
        fsuae_analysis = (fsuae_capture or {}).get("analysis") if fsuae_capture else None
        fsuae_image_success = (
            fsuae_capture is not None
            and fsuae_capture.get("success") is True
            and isinstance(fsuae_analysis, dict)
            and fsuae_analysis["nonBlackPixels"] > 10_000
            and fsuae_analysis["uniqueColorBuckets"] >= 3
            and fsuae_analysis["maxChannelSpread"] > 40
        )
        second_image_success = gui_image_success or fsuae_image_success
        state_second_path_success = gui_state_evidence["success"] is True
        success = raw_success and (
            second_image_success
            or (
                args.allow_state_second_path
                and state_second_path_success
            )
        )
        if gui_image_success:
            second_path = str(gui_capture.get("method", "macos-window-screenshot"))
        elif fsuae_image_success and fsuae_capture is not None:
            second_path = str(fsuae_capture.get("method", "fs-uae-screenshot"))
        else:
            second_path = "retroshell-debug-state"
        manifest = {
            "success": success,
            "strictImageSecondPath": second_image_success,
            "stateSecondPath": state_second_path_success,
            "artifactDirectory": str(run_dir),
            "adf": str(adf),
            "retroShellScript": str(script),
            "ppm": str(ppm),
            "png": str(png) if png_written else None,
            "stateEvidence": state_evidence,
            "analysis": analysis,
            "secondPath": second_path,
            "guiCapture": gui_capture,
        }
        if fsuae_capture is not None:
            manifest["fsuaeCapture"] = fsuae_capture
        (run_dir / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
        print(json.dumps(manifest, indent=2))
        return 0 if success else 2
    except Exception as error:
        failure = {"success": False, "artifactDirectory": str(run_dir), "error": str(error)}
        (run_dir / "manifest.json").write_text(json.dumps(failure, indent=2) + "\n", encoding="utf-8")
        print(json.dumps(failure, indent=2), file=sys.stderr)
        return 1
    finally:
        if not args.keep_vamiga_running:
            quit_vamiga()


if __name__ == "__main__":
    raise SystemExit(main())
