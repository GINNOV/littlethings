# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 transaction_hardlinks.py --case hardlink-top --send2adf ./send2adf

from __future__ import annotations

import argparse
import os
import tempfile
from pathlib import Path
from typing import Callable

from transaction_support import owned_temporaries, report_rejection, run


def input_hardlink_alias(send2adf: Path, nested: bool) -> int:
    with tempfile.TemporaryDirectory(prefix="send2adf-input-hardlink-") as temporary:
        workspace = Path(temporary).resolve()
        output = workspace / "result.adf"
        first = workspace / "first.bin"
        first.write_bytes(b"shared inode")
        if nested:
            source = workspace / "input"
            (source / "left").mkdir(parents=True)
            (source / "right").mkdir()
            first.rename(source / "left" / "first.bin")
            second = source / "right" / "second.bin"
            os.link(source / "left" / "first.bin", second)
            inputs = [source]
            case = "hardlink-nested"
        else:
            second = workspace / "second.bin"
            os.link(first, second)
            inputs = [first, second]
            case = "hardlink-top"
        result = run(send2adf, output, inputs)
        expected = "Error: duplicate input inode alias 'second.bin'\n"
        if result.stderr != expected:
            print(result.stdout + result.stderr, end="")
            return 1
        return report_rejection(case, result, output, workspace)


def repeated_bytes(send2adf: Path) -> int:
    with tempfile.TemporaryDirectory(prefix="send2adf-repeated-bytes-") as temporary:
        workspace = Path(temporary).resolve()
        first = workspace / "first.bin"
        second = workspace / "second.bin"
        first.write_bytes(b"same bytes")
        second.write_bytes(b"same bytes")
        output = workspace / "result.adf"
        result = run(send2adf, output, [first, second])
        if result.returncode != 0 or output.stat().st_size != 901120 or owned_temporaries(workspace):
            print(result.stdout + result.stderr, end="")
            return 1
        print("repeated_bytes_in_distinct_inodes_allowed")
        return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", required=True)
    parser.add_argument("--send2adf", required=True, type=Path)
    arguments = parser.parse_args()
    cases: dict[str, Callable[[Path], int]] = {
        "hardlink-top": lambda binary: input_hardlink_alias(binary, False),
        "hardlink-nested": lambda binary: input_hardlink_alias(binary, True),
        "repeated-bytes": repeated_bytes,
    }
    selected = cases.get(arguments.case)
    if selected is None:
        parser.error(f"unknown case: {arguments.case}")
    return selected(arguments.send2adf)


if __name__ == "__main__":
    raise SystemExit(main())
