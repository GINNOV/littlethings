from __future__ import annotations

import importlib
import json
import os
import socket
import subprocess
import time
from pathlib import Path

from evidence_common import EvidenceError, JsonValue, Sha256, read_json, sha256_file


def prerequisite_records(paths: list[Path]) -> list[JsonValue]:
    records: list[JsonValue] = []
    for path in paths:
        resolved = path.resolve(strict=True)
        read_json(resolved)
        records.append({"path": str(resolved), "sha256": sha256_file(resolved)})
    return records


def receipt_paths(launch: Path, exit_path: Path) -> tuple[Path, Path]:
    if not launch.is_absolute() or not exit_path.is_absolute():
        raise EvidenceError("relative-path", "receipt paths must be absolute")
    if launch == exit_path:
        raise EvidenceError("receipt-collision", str(launch))
    launch_parent = launch.parent.resolve(strict=True)
    exit_parent = exit_path.parent.resolve(strict=True)
    if launch_parent != exit_parent or launch.parent.is_symlink() or exit_path.parent.is_symlink():
        raise EvidenceError("receipt-root-mismatch", "receipts require one canonical non-symlink parent")
    if launch.exists() or exit_path.exists():
        raise EvidenceError("output-exists", str(launch if launch.exists() else exit_path))
    return launch_parent / launch.name, exit_parent / exit_path.name


def trusted_xcodebuild_shim(command: list[str], requested: Path, observed: Path, environment: dict[str, str]) -> bool:
    if Path(command[0]).name != "xcodebuild" or requested != Path("/usr/bin/xcodebuild"):
        return False
    selected = subprocess.run(["/usr/bin/xcode-select", "-p"], env=environment, check=False, capture_output=True, text=True)
    developer = Path(environment.get("DEVELOPER_DIR", selected.stdout.strip())).resolve(strict=True)
    return developer == Path("/Applications/Xcode.app/Contents/Developer") and observed == (developer / "usr/bin/xcodebuild").resolve(strict=True)


def trusted_posix_sh_shim(command: list[str], requested: Path, observed: Path) -> bool:
    if Path(command[0]).name != "sh":
        return False
    try:
        requested_resolved = requested.resolve(strict=True)
        observed_resolved = observed.resolve(strict=True)
    except OSError:
        return False
    return requested_resolved == Path("/bin/sh") and observed_resolved == Path("/bin/bash")


def same_child_identity(observed: dict[str, JsonValue], observed_executable: Path, observed_sha: Sha256, current: dict[str, JsonValue], current_executable: Path, current_sha: Sha256, command: list[str], requested: Path, environment: dict[str, str]) -> bool:
    if observed == current:
        return True
    if observed.get("pid") != current.get("pid"):
        return False
    if trusted_xcodebuild_shim(command, requested, current_executable, environment) and observed_executable == current_executable and observed_sha == current_sha:
        return True
    return trusted_posix_sh_shim(command, requested, current_executable) or trusted_posix_sh_shim(command, observed_executable, current_executable)


def child_executable(pid: int, command: list[str], requested: Path, executable: Path, executable_sha: Sha256, environment: dict[str, str]) -> tuple[Path, Sha256]:
    result = subprocess.run(["/usr/sbin/lsof", "-nP", "-a", "-p", str(pid), "-d", "txt", "-Fn"], check=False, capture_output=True, text=True)
    paths = [Path(line[1:]) for line in result.stdout.splitlines() if line.startswith("n")]
    if result.returncode != 0 or not paths:
        raise EvidenceError("missing-process", f"pid {pid}")
    try:
        observed = paths[0].resolve(strict=True)
    except OSError as error:
        raise EvidenceError("live-io-command-mismatch", f"pid {pid}: {paths[0]}") from error
    if observed != executable.resolve(strict=True) and not trusted_xcodebuild_shim(command, requested, observed, environment) and not trusted_posix_sh_shim(command, requested, observed):
        raise EvidenceError("live-io-command-mismatch", f"pid {pid}: {observed} != {executable}")
    observed_sha = sha256_file(observed)
    if observed == executable.resolve(strict=True) and observed_sha != executable_sha:
        raise EvidenceError("live-io-binary-mismatch", str(observed))
    return observed, observed_sha


def child_identity(pid: int, command: list[str], requested: Path, executable: Path, executable_sha: Sha256, environment: dict[str, str]) -> tuple[dict[str, JsonValue], Path, Sha256]:
    observed, observed_sha = child_executable(pid, command, requested, executable, executable_sha, environment)
    from evidence_common import process_identity

    return process_identity(pid), observed, observed_sha


def await_child_identity(pid: int, command: list[str], requested: Path, executable: Path, executable_sha: Sha256, environment: dict[str, str]) -> tuple[dict[str, JsonValue], Path, Sha256] | None:
    deadline = time.monotonic() + 5
    while time.monotonic() < deadline:
        try:
            return child_identity(pid, command, requested, executable, executable_sha, environment)
        except EvidenceError as error:
            if error.code != "missing-process":
                raise
            state = subprocess.run(["/bin/ps", "-p", str(pid), "-o", "stat="], check=False, capture_output=True, text=True)
            if state.returncode != 0 or state.stdout.strip().startswith("Z"):
                return None
            time.sleep(0.01)
    raise EvidenceError("missing-process", f"pid {pid}")


def await_exec(read_fd: int) -> None:
    try:
        marker = os.read(read_fd, 1)
        trailing = os.read(read_fd, 1)
    finally:
        os.close(read_fd)
    if marker != b"1" or trailing:
        raise EvidenceError("exec-failed", "child could not exec command")


def finalize_receipt(
    fd: int,
    child_status: int,
    launch: Path,
    exit_path: Path,
    trace: Path,
    observation: Path,
    pre_exec_child: dict[str, JsonValue],
    post_exec_child: dict[str, JsonValue],
    observed_executable: Path,
    observed_executable_sha256: Sha256,
) -> None:
    validator = importlib.import_module("validate-execution-receipts")
    runtime = validator.SupervisedRuntime(
        launch=(launch, sha256_file(launch)),
        exit_receipt=(exit_path, sha256_file(exit_path)),
        trace=(trace, sha256_file(trace)),
        observation=(observation, sha256_file(observation)),
        pre_exec_child=pre_exec_child,
        post_exec_child=post_exec_child,
        observed_executable=observed_executable,
        observed_executable_sha256=observed_executable_sha256,
    )
    with socket.socket(fileno=fd) as control, control.makefile("rwb") as stream:
        stream.write((json.dumps({"status": "ready", "childExitStatus": child_status}) + "\n").encode())
        stream.flush()
        line = stream.readline(4097)
        if not line or len(line) > 4096:
            raise EvidenceError("missing-producer-origin-proof", "missing finalization request")
        request = json.loads(line)
        if not isinstance(request, dict) or not isinstance(request.get("receipt"), str):
            raise EvidenceError("invalid-finalization-request", "receipt path is required")
        try:
            validator.validate_receipt(Path(request["receipt"]), Path("Tests/ReviewSchemas/execution-receipt.schema.json"), runtime)
        except EvidenceError as error:
            stream.write((json.dumps({"status": "fail", "error": error.code}) + "\n").encode())
            stream.flush()
            raise
        stream.write(b'{"status":"pass"}\n')
        stream.flush()
