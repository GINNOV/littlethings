# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 transaction_cases.py --case happy --send2adf ./send2adf

from __future__ import annotations

import argparse
import os
import resource
import signal
import tempfile
from pathlib import Path
from typing import Callable

from transaction_boundaries import (
    depth_limit,
    disk_full,
    dot_component,
    entry_limit,
    missing_input,
    output_contained,
    symlink_ancestor,
    volume_boundary,
)
from transaction_support import (
    finish_paused,
    launch_paused,
    owned_temporaries,
    report_rejection,
    run,
)


def workspace_context(prefix: str) -> tempfile.TemporaryDirectory[str]:
    return tempfile.TemporaryDirectory(prefix=prefix)


def happy(send2adf: Path) -> int:
    with workspace_context("send2adf-happy-") as temporary:
        workspace = Path(temporary).resolve()
        source = workspace / ("n" * 30)
        source.mkdir()
        (source / "b.txt").write_bytes(b"beta")
        (source / "a.txt").write_bytes(b"alpha")
        current = source
        for _ in range(20):
            current /= "d" * 30
            current.mkdir()
        (current / "deep.txt").write_bytes(b"deep")
        output = workspace / "result.adf"
        result = run(send2adf, output, [source], volume="V" * 30)
        if result.returncode != 0 or output.stat().st_size != 901120 or owned_temporaries(workspace):
            print(result.stdout + result.stderr, end="")
            return 1
        print("published_without_partial")
        return 0


def invalid_name(send2adf: Path, case: str, name: str) -> int:
    with workspace_context(f"send2adf-{case}-") as temporary:
        workspace = Path(temporary).resolve()
        source = workspace / name
        source.write_bytes(b"x")
        output = workspace / "result.adf"
        return report_rejection(case, run(send2adf, output, [source]), output, workspace)


def collision(send2adf: Path, duplicate_top: bool) -> int:
    with workspace_context("send2adf-collision-") as temporary:
        workspace = Path(temporary).resolve()
        output = workspace / "result.adf"
        first = workspace / "one" / "same"
        second = workspace / "two" / ("same" if duplicate_top else "SAME")
        first.parent.mkdir()
        second.parent.mkdir()
        first.write_bytes(b"one")
        second.write_bytes(b"two")
        inputs = [first, second]
        if not duplicate_top:
            middle = workspace / "three" / "ZZZ"
            middle.parent.mkdir()
            middle.write_bytes(b"middle")
            inputs.append(middle)
        case = "duplicate-top" if duplicate_top else "case-collision"
        return report_rejection(case, run(send2adf, output, inputs), output, workspace)


def special_input(send2adf: Path, case: str) -> int:
    with workspace_context(f"send2adf-{case}-") as temporary:
        workspace = Path(temporary).resolve()
        source = workspace / "input"
        output = workspace / "result.adf"
        source.write_bytes(b"original")
        if case == "symlink":
            link = workspace / "link"
            link.symlink_to(source)
            source = link
        elif case == "fifo":
            source.unlink()
            os.mkfifo(source)
        elif case == "hardlink-output":
            os.link(source, output)
        elif case == "same-input-output":
            output = source
        elif case == "preexisting":
            output.write_bytes(b"preserve")
        result = run(send2adf, output, [source])
        preserved = case not in {"hardlink-output", "same-input-output", "preexisting"} or output.read_bytes() in {
            b"original", b"preserve"
        }
        if result.returncode == 0 or owned_temporaries(workspace) or not preserved:
            return 1
        print(f"transaction_rejected_preserving_destination case={case}")
        return 0


def oversized(send2adf: Path) -> int:
    with workspace_context("send2adf-oversized-") as temporary:
        workspace = Path(temporary).resolve()
        source = workspace / "large.bin"
        source.write_bytes(b"x" * 901121)
        output = workspace / "result.adf"
        return report_rejection("oversized", run(send2adf, output, [source]), output, workspace)


def low_nofile(send2adf: Path) -> int:
    with workspace_context("send2adf-nofile-") as temporary:
        workspace = Path(temporary).resolve()
        source = workspace / "input"
        source.mkdir()
        for index in range(40):
            (source / f"f{index:02}.txt").write_bytes(b"x")
        output = workspace / "result.adf"

        def limit_descriptors() -> None:
            resource.setrlimit(resource.RLIMIT_NOFILE, (32, 32))

        result = run(send2adf, output, [source], before_exec=limit_descriptors)
        return report_rejection("low-nofile", result, output, workspace)


def forced_write_failure(send2adf: Path) -> int:
    with workspace_context("send2adf-write-failure-") as temporary:
        workspace = Path(temporary).resolve()
        source = workspace / "input.bin"
        source.write_bytes(b"x" * 8192)
        output = workspace / "result.adf"
        environment = os.environ.copy()
        environment["SEND2ADF_TEST_FAIL_AFTER_BYTES"] = "4096"
        result = run(send2adf, output, [source], environment=environment)
        return report_rejection("forced-write-failure", result, output, workspace)


def input_race(send2adf: Path, mutation: str) -> int:
    with workspace_context(f"send2adf-input-{mutation}-") as temporary:
        workspace = Path(temporary).resolve()
        source = workspace / "input.bin"
        source.write_bytes(b"original")
        paused = launch_paused(send2adf, workspace, source, "after-input-open")
        if mutation == "unlink":
            source.unlink()
        elif mutation == "symlink":
            source.unlink()
            source.symlink_to(workspace / "replacement")
        elif mutation == "regular":
            source.unlink()
            source.write_bytes(b"replaced")
        elif mutation == "overwrite":
            source.write_bytes(b"changed!")
        elif mutation == "truncate-regrow":
            source.write_bytes(b"")
            source.write_bytes(b"original")
        result = finish_paused(paused)
        return report_rejection(f"input-{mutation}", result, paused.output, workspace)


def temp_race(send2adf: Path, mutation: str) -> int:
    with workspace_context(f"send2adf-temp-{mutation}-") as temporary:
        workspace = Path(temporary).resolve()
        source = workspace / "input.bin"
        source.write_bytes(b"payload")
        paused = launch_paused(send2adf, workspace, source, "after-temp")
        temporary_image = owned_temporaries(workspace)[0]
        temporary_image.unlink()
        if mutation == "symlink":
            temporary_image.symlink_to(source)
        elif mutation == "regular":
            temporary_image.write_bytes(b"replacement")
        result = finish_paused(paused)
        replacement_preserved = mutation == "unlink" or temporary_image.exists()
        if result.returncode == 0 or paused.output.exists() or not replacement_preserved:
            return 1
        print(f"temporary_replacement_rejected case={mutation}")
        return 0


def interrupted(send2adf: Path, phase: str, signal_value: signal.Signals) -> int:
    with workspace_context("send2adf-signal-") as temporary:
        workspace = Path(temporary).resolve()
        source = workspace / "input.bin"
        source.write_bytes(b"payload")
        paused = launch_paused(send2adf, workspace, source, phase)
        result = finish_paused(paused, resume=False, interrupt=signal_value)
        return report_rejection(f"{phase}-{signal_value.name}", result, paused.output, workspace)


def destination_created_race(send2adf: Path) -> int:
    with workspace_context("send2adf-destination-race-") as temporary:
        workspace = Path(temporary).resolve()
        source = workspace / "input.bin"
        source.write_bytes(b"payload")
        paused = launch_paused(send2adf, workspace, source, "after-temp")
        paused.output.write_bytes(b"preserve")
        result = finish_paused(paused)
        if result.returncode == 0 or paused.output.read_bytes() != b"preserve" or owned_temporaries(workspace):
            return 1
        print("destination_race_preserved")
        return 0


def parent_swap(send2adf: Path) -> int:
    with workspace_context("send2adf-parent-swap-") as temporary:
        root = Path(temporary).resolve()
        workspace = root / "parent"
        workspace.mkdir()
        source = root / "input.bin"
        source.write_bytes(b"payload")
        paused = launch_paused(send2adf, workspace, source, "after-preflight")
        moved = root / "moved"
        workspace.rename(moved)
        workspace.mkdir()
        result = finish_paused(paused)
        return report_rejection("parent-swap", result, workspace / "result.adf", workspace)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", required=True)
    parser.add_argument("--send2adf", required=True, type=Path)
    arguments = parser.parse_args()
    cases: dict[str, Callable[[Path], int]] = {
        "happy": happy, "missing-input": missing_input,
        "name-31": lambda binary: invalid_name(binary, "name-31", "x" * 31),
        "forbidden": lambda binary: invalid_name(binary, "forbidden", "bad:name"),
        "non-ascii": lambda binary: invalid_name(binary, "non-ascii", "café"),
        "case-collision": lambda binary: collision(binary, False),
        "duplicate-top": lambda binary: collision(binary, True),
        "symlink": lambda binary: special_input(binary, "symlink"),
        "fifo": lambda binary: special_input(binary, "fifo"),
        "hardlink-output": lambda binary: special_input(binary, "hardlink-output"),
        "same-input-output": lambda binary: special_input(binary, "same-input-output"),
        "preexisting": lambda binary: special_input(binary, "preexisting"),
        "oversized": oversized, "low-nofile": low_nofile,
        "volume-0": lambda binary: volume_boundary(binary, 0),
        "volume-31": lambda binary: volume_boundary(binary, 31),
        "entry-limit": entry_limit, "depth-limit": depth_limit,
        "disk-full": disk_full, "output-contained": output_contained,
        "dot": lambda binary: dot_component(binary, False),
        "dotdot": lambda binary: dot_component(binary, True),
        "input-symlink-ancestor": lambda binary: symlink_ancestor(binary, False),
        "output-symlink-ancestor": lambda binary: symlink_ancestor(binary, True),
        "forced-write": forced_write_failure,
        "input-unlink": lambda binary: input_race(binary, "unlink"),
        "input-symlink": lambda binary: input_race(binary, "symlink"),
        "input-regular": lambda binary: input_race(binary, "regular"),
        "input-overwrite": lambda binary: input_race(binary, "overwrite"),
        "input-truncate-regrow": lambda binary: input_race(binary, "truncate-regrow"),
        "temp-unlink": lambda binary: temp_race(binary, "unlink"),
        "temp-symlink": lambda binary: temp_race(binary, "symlink"),
        "temp-regular": lambda binary: temp_race(binary, "regular"),
        "destination-race": destination_created_race, "parent-swap": parent_swap,
        "sigint-after-temp": lambda binary: interrupted(binary, "after-temp", signal.SIGINT),
        "sigterm-after-temp": lambda binary: interrupted(binary, "after-temp", signal.SIGTERM),
        "sigint-after-link": lambda binary: interrupted(binary, "after-destination-link", signal.SIGINT),
        "sigterm-after-link": lambda binary: interrupted(binary, "after-destination-link", signal.SIGTERM),
    }
    selected = cases.get(arguments.case)
    if selected is None:
        parser.error(f"unknown case: {arguments.case}")
    return selected(arguments.send2adf)


if __name__ == "__main__":
    raise SystemExit(main())
