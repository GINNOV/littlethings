from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Final

LABEL: Final = "CHARACTERIZE"


def run_process(command: list[str | Path]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, check=False, capture_output=True, text=True)


def inspect_command(
    inspector: Path,
    image: Path,
    bootblock: str,
    directories: list[str],
    files: list[tuple[str, Path]],
) -> list[str | Path]:
    command: list[str | Path] = [
        inspector,
        "--image",
        image,
        "--volume",
        LABEL,
        "--dos-type",
        "1" if bootblock == "2.0" else "0",
        "--bootblock",
        bootblock,
    ]
    for directory in directories:
        command.extend(("--expect-dir", directory))
    for adf_path, host_path in files:
        command.extend(("--expect-file", f"{adf_path}={host_path}"))
    return command


def generate_and_inspect(
    send2adf: Path,
    inspector: Path,
    workspace: Path,
    bootblock: str,
    inputs: list[Path],
    directories: list[str],
    files: list[tuple[str, Path]],
) -> tuple[Path, subprocess.CompletedProcess[str]]:
    image = workspace / "generated.adf"
    generated = run_process(
        [send2adf, "-o", image, "-N", LABEL, "-B", bootblock, *inputs]
    )
    if generated.returncode != 0:
        sys.stderr.write(generated.stdout)
        sys.stderr.write(generated.stderr)
        raise subprocess.CalledProcessError(generated.returncode, generated.args)
    return image, run_process(
        inspect_command(inspector, image, bootblock, directories, files)
    )


def require_inspection(completed: subprocess.CompletedProcess[str]) -> int:
    sys.stdout.write(completed.stdout)
    sys.stderr.write(completed.stderr)
    return 0 if completed.returncode == 0 and "inspection_ok" in completed.stdout else 1


def run_file(send2adf: Path, inspector: Path, fixtures: Path) -> int:
    source = fixtures / "single" / "message.txt"
    with tempfile.TemporaryDirectory(prefix="send2adf-file-") as temporary:
        _, inspected = generate_and_inspect(
            send2adf,
            inspector,
            Path(temporary).resolve(),
            "1.3",
            [source],
            [],
            [("message.txt", source)],
        )
        return require_inspection(inspected)


def run_nested(send2adf: Path, inspector: Path, fixtures: Path) -> int:
    with tempfile.TemporaryDirectory(prefix="send2adf-nested-") as temporary:
        workspace = Path(temporary).resolve()
        source = workspace / "input"
        shutil.copytree(fixtures / "nested" / "input", source)
        empty = source / "assets" / "empty.dat"
        empty.touch()
        files = [
            ("input/assets/data.bin", source / "assets" / "data.bin"),
            ("input/assets/empty.dat", empty),
            ("input/readme.txt", source / "readme.txt"),
        ]
        _, inspected = generate_and_inspect(
            send2adf,
            inspector,
            workspace,
            "1.3",
            [source],
            ["input", "input/assets"],
            files,
        )
        return require_inspection(inspected)


def run_empty(send2adf: Path, inspector: Path) -> int:
    with tempfile.TemporaryDirectory(prefix="send2adf-empty-") as temporary:
        workspace = Path(temporary).resolve()
        empty = workspace / "empty.dat"
        empty.touch()
        _, inspected = generate_and_inspect(
            send2adf, inspector, workspace, "1.3", [empty], [], [("empty.dat", empty)]
        )
        return require_inspection(inspected)


def run_multi(send2adf: Path, inspector: Path, fixtures: Path) -> int:
    alpha = fixtures / "multi" / "alpha.txt"
    beta = fixtures / "multi" / "beta.txt"
    with tempfile.TemporaryDirectory(prefix="send2adf-multi-") as temporary:
        _, inspected = generate_and_inspect(
            send2adf,
            inspector,
            Path(temporary).resolve(),
            "1.3",
            [beta, alpha],
            [],
            [("alpha.txt", alpha), ("beta.txt", beta)],
        )
        return require_inspection(inspected)


def run_bootblock(
    send2adf: Path, inspector: Path, fixtures: Path, bootblock: str
) -> int:
    source = fixtures / "single" / "message.txt"
    with tempfile.TemporaryDirectory(prefix=f"send2adf-boot-{bootblock}-") as temporary:
        _, inspected = generate_and_inspect(
            send2adf,
            inspector,
            Path(temporary).resolve(),
            bootblock,
            [source],
            [],
            [("message.txt", source)],
        )
        return require_inspection(inspected)


def run_mutation(
    send2adf: Path,
    inspector: Path,
    fixtures: Path,
    mutator: Path,
    field: str,
    expected_error: str,
) -> int:
    source = fixtures / "nested" / "input"
    files = [
        ("input/assets/data.bin", source / "assets" / "data.bin"),
        ("input/readme.txt", source / "readme.txt"),
    ]
    with tempfile.TemporaryDirectory(prefix="send2adf-mutation-") as temporary:
        workspace = Path(temporary).resolve()
        image, inspected = generate_and_inspect(
            send2adf,
            inspector,
            workspace,
            "1.3",
            [source],
            ["input", "input/assets"],
            files,
        )
        if inspected.returncode != 0:
            return require_inspection(inspected)
        mutated = run_process(
            [sys.executable, mutator, "--image", image, "--fixture", "nested", "--field", field]
        )
        if mutated.returncode != 0:
            sys.stderr.write(mutated.stderr)
            return 1
        failed = run_process(
            inspect_command(inspector, image, "1.3", ["input", "input/assets"], files)
        )
        sys.stdout.write(failed.stdout)
        sys.stderr.write(failed.stderr)
        if failed.returncode == 0 or expected_error not in failed.stderr:
            return 1
        print(f"mutation_rejected field={field} diagnostic={expected_error}")
        return 0


def run_error_surface(send2adf: Path, case: str) -> int:
    with tempfile.TemporaryDirectory(prefix="send2adf-error-") as temporary:
        workspace = Path(temporary).resolve()
        image = workspace / "partial.adf"
        missing = workspace / "missing.bin"
        commands: dict[str, list[str | Path]] = {
            "error_missing_input": [
                send2adf, "-o", image, "-N", LABEL, "-B", "1.3", missing
            ],
            "error_missing_required": [send2adf, "-N", LABEL, missing],
            "error_invalid_bootblock": [
                send2adf, "-o", image, "-N", LABEL, "-B", "invalid", missing
            ],
        }
        completed = run_process(commands[case])
        if completed.returncode == 0:
            return 1
        if image.exists():
            return 1
        print(f"error_surface_ok case={case} partial_image=false")
        return 0
