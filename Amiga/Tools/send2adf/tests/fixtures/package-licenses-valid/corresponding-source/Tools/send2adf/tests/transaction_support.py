from __future__ import annotations

import os
import signal
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Callable


@dataclass(frozen=True, slots=True)
class Result:
    returncode: int
    stdout: str
    stderr: str


@dataclass(frozen=True, slots=True)
class PausedProcess:
    process: subprocess.Popen[str]
    output: Path
    workspace: Path


@dataclass(frozen=True, slots=True)
class PauseHookError(RuntimeError):
    output: str

    def __str__(self) -> str:
        return f"pause hook failed: {self.output}"


def command(send2adf: Path, output: Path, inputs: list[Path], bootblock: str = "1.3",
            volume: str = "TRANSACTION") -> list[str]:
    return [str(send2adf), "-o", str(output), "-N", volume, "-B", bootblock,
            *(str(item) for item in inputs)]


def run(send2adf: Path, output: Path, inputs: list[Path], *,
        bootblock: str = "1.3", environment: dict[str, str] | None = None,
        before_exec: Callable[[], None] | None = None,
        volume: str = "TRANSACTION") -> Result:
    completed = subprocess.run(
        command(send2adf, output, inputs, bootblock, volume), check=False,
        capture_output=True, text=True, env=environment, preexec_fn=before_exec,
    )
    return Result(completed.returncode, completed.stdout, completed.stderr)


def launch_paused(send2adf: Path, workspace: Path, input_path: Path,
                  phase: str) -> PausedProcess:
    read_fd, write_fd = os.pipe()
    environment = os.environ.copy()
    environment["SEND2ADF_TEST_PAUSE_PHASE"] = phase
    environment["SEND2ADF_TEST_READY_FD"] = str(write_fd)
    output = workspace / "result.adf"
    process = subprocess.Popen(
        command(send2adf, output, [input_path]), stdout=subprocess.PIPE,
        stderr=subprocess.PIPE, text=True, env=environment, pass_fds=(write_fd,),
    )
    os.close(write_fd)
    ready = os.read(read_fd, 1)
    os.close(read_fd)
    if ready != b"R":
        stdout, stderr = process.communicate(timeout=10)
        raise PauseHookError(stdout + stderr)
    return PausedProcess(process, output, workspace)


def finish_paused(paused: PausedProcess, resume: bool = True,
                  interrupt: signal.Signals | None = None) -> Result:
    if interrupt is not None:
        paused.process.send_signal(interrupt)
    elif resume:
        paused.process.send_signal(signal.SIGUSR1)
    stdout, stderr = paused.process.communicate(timeout=10)
    return Result(paused.process.returncode, stdout, stderr)


def owned_temporaries(workspace: Path) -> list[Path]:
    return list(workspace.glob(".send2adf-*.tmp"))


def rejected_cleanly(result: Result, output: Path, workspace: Path) -> bool:
    return result.returncode != 0 and not output.exists() and not owned_temporaries(workspace)


def report_rejection(case: str, result: Result, output: Path, workspace: Path) -> int:
    if not rejected_cleanly(result, output, workspace):
        print(result.stdout + result.stderr, end="")
        return 1
    print(f"transaction_rejected_without_partial case={case}")
    return 0
