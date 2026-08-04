# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 transaction_order.py --send2adf ./send2adf --inspector ./adf_inspect

from __future__ import annotations

import argparse
import subprocess
import tempfile
from pathlib import Path


def create_tree(root: Path, order: list[str]) -> Path:
    source = root / "input"
    source.mkdir(parents=True)
    for name in order:
        (source / name).write_bytes(name.encode("ascii"))
    assets = source / "assets"
    assets.mkdir()
    (assets / "data.bin").write_bytes(b"data")
    return source


def generate(send2adf: Path, source: Path, output: Path) -> bool:
    completed = subprocess.run(
        [send2adf, "-o", output, "-N", "ORDER", "-B", "1.3", source],
        check=False, capture_output=True, text=True,
    )
    if completed.returncode != 0:
        print(completed.stdout + completed.stderr, end="")
        return False
    return True


def inspect(inspector: Path, image: Path, source: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [inspector, "--image", image, "--volume", "ORDER", "--dos-type", "0",
         "--bootblock", "1.3", "--expect-dir", "input",
         "--expect-dir", "input/assets",
         "--expect-file", f"input/a.txt={source / 'a.txt'}",
         "--expect-file", f"input/b.txt={source / 'b.txt'}",
         "--expect-file", f"input/c.txt={source / 'c.txt'}",
         "--expect-file", f"input/assets/data.bin={source / 'assets' / 'data.bin'}"],
        check=False, capture_output=True, text=True,
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--send2adf", required=True, type=Path)
    parser.add_argument("--inspector", required=True, type=Path)
    arguments = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="send2adf-order-") as temporary:
        workspace = Path(temporary).resolve()
        first_source = create_tree(workspace / "first", ["c.txt", "a.txt", "b.txt"])
        second_source = create_tree(workspace / "second", ["b.txt", "c.txt", "a.txt"])
        first_image = workspace / "first.adf"
        second_image = workspace / "second.adf"
        if not generate(arguments.send2adf, first_source, first_image):
            return 1
        if not generate(arguments.send2adf, second_source, second_image):
            return 1
        first = inspect(arguments.inspector, first_image, first_source)
        second = inspect(arguments.inspector, second_image, second_source)
        if first.returncode != 0 or second.returncode != 0 or first.stdout != second.stdout:
            print(first.stdout + first.stderr + second.stdout + second.stderr, end="")
            return 1
        print(first.stdout, end="")
        print("inspector_equivalent_creation_orders")
        return 0


if __name__ == "__main__":
    raise SystemExit(main())
