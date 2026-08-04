from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path
from typing import Callable, Final

from characterization_cases import (
    run_bootblock,
    run_empty,
    run_error_surface,
    run_file,
    run_multi,
    run_mutation,
    run_nested,
)

HELP_TOKEN: Final = "Usage:"


def run_help(send2adf: Path) -> int:
    completed = subprocess.run(
        [send2adf, "--help"],
        check=False,
        capture_output=True,
        text=True,
    )
    if completed.returncode != 0 or HELP_TOKEN not in completed.stdout:
        sys.stderr.write(completed.stdout)
        sys.stderr.write(completed.stderr)
        return 1
    print("help_ok")
    return 0


def content_cases(
    send2adf: Path, inspector: Path, fixtures: Path
) -> dict[str, Callable[[], int]]:
    return {
        "file": lambda: run_file(send2adf, inspector, fixtures),
        "nested": lambda: run_nested(send2adf, inspector, fixtures),
        "empty": lambda: run_empty(send2adf, inspector),
        "multi": lambda: run_multi(send2adf, inspector, fixtures),
        "boot_none": lambda: run_bootblock(send2adf, inspector, fixtures, "none"),
        "boot_13": lambda: run_bootblock(send2adf, inspector, fixtures, "1.3"),
        "boot_20": lambda: run_bootblock(send2adf, inspector, fixtures, "2.0"),
    }


def add_mutation_cases(
    cases: dict[str, Callable[[], int]],
    send2adf: Path,
    inspector: Path,
    fixtures: Path,
    mutator: Path,
) -> None:
    cases["mutation_content"] = lambda: run_mutation(
        send2adf,
        inspector,
        fixtures,
        mutator,
        "input/assets/data.bin:0",
        "content_digest_mismatch",
    )
    cases["mutation_bootblock"] = lambda: run_mutation(
        send2adf,
        inspector,
        fixtures,
        mutator,
        "bootblock:0",
        "bootblock_mismatch",
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", required=True)
    parser.add_argument("--send2adf", type=Path, required=True)
    parser.add_argument("--inspector", type=Path)
    parser.add_argument("--fixtures", type=Path)
    parser.add_argument("--mutator", type=Path)
    arguments = parser.parse_args()
    if arguments.case == "help":
        return run_help(arguments.send2adf)
    if arguments.case.startswith("error_"):
        return run_error_surface(arguments.send2adf, arguments.case)
    if arguments.inspector is None or arguments.fixtures is None:
        parser.error("--inspector and --fixtures are required for content cases")
    cases = content_cases(arguments.send2adf, arguments.inspector, arguments.fixtures)
    if arguments.mutator is not None:
        add_mutation_cases(
            cases,
            arguments.send2adf,
            arguments.inspector,
            arguments.fixtures,
            arguments.mutator,
        )
    selected = cases.get(arguments.case)
    if selected is None:
        parser.error(f"unknown case: {arguments.case}")
    return selected()


if __name__ == "__main__":
    raise SystemExit(main())
