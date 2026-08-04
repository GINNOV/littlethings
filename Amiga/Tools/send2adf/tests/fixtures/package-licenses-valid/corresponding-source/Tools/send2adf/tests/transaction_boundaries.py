from __future__ import annotations

import tempfile
from pathlib import Path

from transaction_support import report_rejection, run


def missing_input(send2adf: Path) -> int:
    with tempfile.TemporaryDirectory(prefix="send2adf-missing-") as temporary:
        workspace = Path(temporary).resolve()
        output = workspace / "result.adf"
        result = run(send2adf, output, [workspace / "missing"])
        return report_rejection("missing-input", result, output, workspace)


def volume_boundary(send2adf: Path, length: int) -> int:
    with tempfile.TemporaryDirectory(prefix="send2adf-volume-") as temporary:
        workspace = Path(temporary).resolve()
        source = workspace / "input"
        source.write_bytes(b"x")
        output = workspace / "result.adf"
        result = run(send2adf, output, [source], volume="V" * length)
        return report_rejection(f"volume-{length}", result, output, workspace)


def entry_limit(send2adf: Path) -> int:
    with tempfile.TemporaryDirectory(prefix="send2adf-entries-") as temporary:
        workspace = Path(temporary).resolve()
        source = workspace / "input"
        source.mkdir()
        for index in range(257):
            (source / f"f{index:03}").write_bytes(b"")
        output = workspace / "result.adf"
        return report_rejection("entry-limit", run(send2adf, output, [source]), output, workspace)


def depth_limit(send2adf: Path) -> int:
    with tempfile.TemporaryDirectory(prefix="send2adf-depth-") as temporary:
        workspace = Path(temporary).resolve()
        source = workspace / "input"
        current = source
        for _ in range(66):
            current /= "d"
        current.mkdir(parents=True)
        (current / "file").write_bytes(b"x")
        output = workspace / "result.adf"
        return report_rejection("depth-limit", run(send2adf, output, [source]), output, workspace)


def disk_full(send2adf: Path) -> int:
    with tempfile.TemporaryDirectory(prefix="send2adf-disk-full-") as temporary:
        workspace = Path(temporary).resolve()
        source = workspace / "large.bin"
        source.write_bytes(b"x" * 850000)
        output = workspace / "result.adf"
        return report_rejection("disk-full", run(send2adf, output, [source]), output, workspace)


def output_contained(send2adf: Path) -> int:
    with tempfile.TemporaryDirectory(prefix="send2adf-contained-") as temporary:
        workspace = Path(temporary).resolve()
        source = workspace / "input"
        source.mkdir()
        (source / "file").write_bytes(b"x")
        output = source / "result.adf"
        return report_rejection("output-contained", run(send2adf, output, [source]), output, source)


def dot_component(send2adf: Path, dotdot: bool) -> int:
    with tempfile.TemporaryDirectory(prefix="send2adf-dot-") as temporary:
        workspace = Path(temporary).resolve()
        source = workspace / "input"
        source.write_bytes(b"x")
        middle = ".." if dotdot else "."
        path = Path(f"{workspace}/sub/{middle}/input")
        output = workspace / "result.adf"
        return report_rejection("dotdot" if dotdot else "dot", run(send2adf, output, [path]), output, workspace)


def symlink_ancestor(send2adf: Path, output_ancestor: bool) -> int:
    with tempfile.TemporaryDirectory(prefix="send2adf-ancestor-") as temporary:
        workspace = Path(temporary).resolve()
        real = workspace / "real"
        real.mkdir()
        source = real / "input"
        source.write_bytes(b"x")
        link = workspace / "link"
        link.symlink_to(real, target_is_directory=True)
        output = (link if output_ancestor else workspace) / "result.adf"
        input_path = source if output_ancestor else link / "input"
        case = "output-symlink-ancestor" if output_ancestor else "input-symlink-ancestor"
        return report_rejection(case, run(send2adf, output, [input_path]), output, workspace)
