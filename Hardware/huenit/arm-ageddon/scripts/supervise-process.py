#!/usr/bin/env python3

from __future__ import annotations

import argparse
import importlib
import json
import os
import signal
import socket
import subprocess
import sys
import threading
import time
from types import FrameType
from pathlib import Path

from evidence_common import EvidenceError, JsonValue, clean_environment, exclusive_json, exclusive_write, executable_hash, process_identity, read_json, sha256_file

ALLOWLIST = ("DEVELOPER_DIR", "LANG", "PATH", "SDKROOT", "TMPDIR", "USER")


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


def same_child_identity(observed: dict[str, JsonValue], current: dict[str, JsonValue], command: list[str], executable: Path, environment: dict[str, str]) -> bool:
    if observed == current:
        return True
    observed_command = observed.get("birthAndCommand")
    current_command = current.get("birthAndCommand")
    return trusted_xcodebuild_shim(command, Path("/usr/bin/xcodebuild"), executable, environment) and observed.get("pid") == current.get("pid") and isinstance(observed_command, str) and isinstance(current_command, str) and observed_command.split(maxsplit=5)[:5] == current_command.split(maxsplit=5)[:5] and Path(observed_command).name == Path(current_command).name == "xcodebuild"


def child_executable(pid: int, command: list[str], executable: Path, executable_sha: str, environment: dict[str, str]) -> Path:
    result = subprocess.run(["/usr/sbin/lsof", "-nP", "-a", "-p", str(pid), "-d", "txt", "-Fn"], check=False, capture_output=True, text=True)
    paths = [Path(line[1:]) for line in result.stdout.splitlines() if line.startswith("n")]
    if result.returncode != 0 or not paths:
        raise EvidenceError("missing-process", f"pid {pid}")
    try:
        observed = paths[0].resolve(strict=True)
    except OSError as error:
        raise EvidenceError("live-io-command-mismatch", f"pid {pid}: {paths[0]}") from error
    if observed != executable.resolve(strict=True) and not trusted_xcodebuild_shim(command, executable, observed, environment):
        raise EvidenceError("live-io-command-mismatch", f"pid {pid}: {observed} != {executable}")
    if observed == executable.resolve(strict=True) and sha256_file(observed) != executable_sha:
        raise EvidenceError("live-io-binary-mismatch", str(observed))
    return observed


def child_identity(pid: int, command: list[str], executable: Path, executable_sha: str, environment: dict[str, str]) -> tuple[dict[str, JsonValue], Path]:
    return process_identity(pid), child_executable(pid, command, executable, executable_sha, environment)


def await_child_identity(pid: int, command: list[str], executable: Path, executable_sha: str, environment: dict[str, str]) -> tuple[dict[str, JsonValue], Path] | None:
    deadline = time.monotonic() + 5
    while time.monotonic() < deadline:
        try:
            return child_identity(pid, command, executable, executable_sha, environment)
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


def finalize_receipt(fd: int, child_status: int, launch: Path, exit_path: Path, trace: Path, observation: Path) -> None:
    validator = importlib.import_module("validate-execution-receipts")
    runtime = validator.SupervisedRuntime(
        launch=(launch, sha256_file(launch)),
        exit_receipt=(exit_path, sha256_file(exit_path)),
        trace=(trace, sha256_file(trace)),
        observation=(observation, sha256_file(observation)),
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


def run(args: argparse.Namespace) -> int:
    command: list[str] = args.command[1:] if args.command[:1] == ["--"] else args.command
    if not command:
        raise EvidenceError("missing-command", "command after -- is required")
    launch, exit_path = receipt_paths(args.launch_receipt, args.exit_receipt)
    observation = args.live_io_observation
    trace = args.live_io_trace
    if (observation is None) != (trace is None):
        raise EvidenceError("missing-live-io-artifact", "observation and trace must be requested together")
    if args.finalize_fd is not None and (observation is None or trace is None):
        raise EvidenceError("missing-live-io-artifact", "finalization requires observation and trace")
    if observation is not None and trace is not None:
        if not observation.is_absolute() or not trace.is_absolute() or observation.parent.resolve(strict=True) != launch.parent or trace.parent.resolve(strict=True) != launch.parent:
            raise EvidenceError("observation-root-mismatch", str(observation))
        if observation.exists() or trace.exists() or observation in {launch, exit_path} or trace in {launch, exit_path, observation}:
            raise EvidenceError("output-exists", str(observation if observation.exists() else trace))
        observation = observation.parent.resolve(strict=True) / observation.name
        trace = trace.parent.resolve(strict=True) / trace.name
    environment = clean_environment(os.environ, ALLOWLIST)
    try:
        executable, executable_sha = executable_hash(command[0], environment)
    except EvidenceError as error:
        if error.code not in {"missing-path", "missing-executable"}:
            raise
        executable = Path(command[0]).absolute()
        executable_sha = ""
    barrier_read, barrier_write = os.pipe()
    exec_read, exec_write = os.pipe()
    os.set_inheritable(exec_write, False)
    started = time.monotonic_ns()
    child_pid = os.fork()
    if child_pid == 0:
        os.setsid()
        os.close(barrier_write)
        os.close(exec_read)
        if args.preexec_barrier and os.read(barrier_read, 1) != b"1":
            os.write(exec_write, b"0")
            os._exit(126)
        os.close(barrier_read)
        try:
            os.write(exec_write, b"1")
            os.execvpe(command[0], command, environment)
        except OSError:
            os.write(exec_write, b"0")
            os._exit(126)
    os.close(barrier_read)
    os.close(exec_write)
    if args.preexec_barrier:
        os.write(barrier_write, b"1")
    os.close(barrier_write)
    await_exec(exec_read)
    observed = await_child_identity(child_pid, command, executable, executable_sha, environment)
    if observed is None:
        observed_child: dict[str, JsonValue] = {"pid": child_pid, "birthAndCommand": "exec-success-handshake"}
        observed_executable = executable
    else:
        observed_child, observed_executable = observed
        executable = observed_executable
        executable_sha = sha256_file(executable)
    started = time.monotonic_ns()
    launch_value: JsonValue = {"schemaVersion": 1, "kind": "process-launch", "commandID": args.command_id, "argv": command, "supervisor": process_identity(os.getpid()), "child": observed_child, "processGroup": child_pid, "executable": str(executable), "executableSHA256": executable_sha, "observedExecutable": str(observed_executable), "observedExecutableSHA256": sha256_file(observed_executable), "startMonotonicNs": started, "preexecBarrier": args.preexec_barrier}
    try:
        exclusive_json(launch, launch_value)
    except (EvidenceError, OSError):
        os.killpg(child_pid, signal.SIGTERM)
        os.waitpid(child_pid, 0)
        raise
    observed_events: list[JsonValue] = []
    sample_count = 1 if observed is None else 0
    observation_error: EvidenceError | None = None
    observation_finished = threading.Event()
    observation_started = threading.Event()

    def sample_process_group() -> None:
        nonlocal observation_error, sample_count
        while not observation_finished.is_set():
            try:
                identity = child_identity(child_pid, command, executable, executable_sha, environment)
                if not same_child_identity(observed_child, identity[0], command, executable, environment):
                    raise EvidenceError("live-io-process-mismatch", str(child_pid))
            except EvidenceError as error:
                if error.code != "missing-process":
                    observation_error = error
                observation_started.set()
                return
            processes = subprocess.run(["/bin/ps", "-axo", "pid=,pgid="], check=False, capture_output=True, text=True)
            pids = [fields[0] for line in processes.stdout.splitlines() if len(fields := line.split()) == 2 and fields[1] == str(child_pid)]
            if pids:
                opened = subprocess.run(["/usr/sbin/lsof", "-nP", "-a", "-p", ",".join(pids)], check=False, capture_output=True, text=True)
                for line in opened.stdout.splitlines()[1:]:
                    fields = line.split()
                    if len(fields) >= 9 and fields[-1].startswith(("/dev/cu.", "/dev/tty.")):
                        observed_events.append({"kind": "serial-write" if "w" in fields[3] else "device-open", "pid": int(fields[1]), "monotonicNs": time.monotonic_ns()})
            sample_count += 1
            observation_started.set()
            observation_finished.wait(0.05)

    observer = threading.Thread(target=sample_process_group, name="live-io-observer") if observation is not None else None
    if observer is not None:
        observer.start()
        if not observation_started.wait(5):
            raise EvidenceError("live-io-observer-not-ready", str(child_pid))

    def forward(signum: int, _frame: FrameType | None) -> None:
        try:
            os.killpg(child_pid, signum)
        except ProcessLookupError:
            return

    signal.signal(signal.SIGTERM, forward)
    signal.signal(signal.SIGINT, forward)
    _, wait_status = os.waitpid(child_pid, 0)
    exit_status = os.waitstatus_to_exitcode(wait_status)
    ended = time.monotonic_ns()
    observation_finished.set()
    if observer is not None:
        observer.join()
    if observation_error is not None:
        raise observation_error
    trace_record: JsonValue | None = None
    if observation is not None and trace is not None:
        trace_record = {"schemaVersion": 1, "kind": "live-io-trace", "observer": process_identity(os.getpid()), "process": launch_value["child"], "processGroup": child_pid, "executable": str(executable), "executableSHA256": executable_sha, "observationStartMonotonicNs": started, "observationEndMonotonicNs": ended, "sampleCount": sample_count, "events": observed_events}
        exclusive_write(trace, (json.dumps(trace_record, sort_keys=True, separators=(",", ":")) + "\n").encode())
    prerequisites = prerequisite_records(args.exit_prerequisite)
    if trace is not None:
        prerequisites.append({"path": str(trace), "sha256": sha256_file(trace)})
    exit_value: JsonValue = {"schemaVersion": 1, "kind": "process-exit", "commandID": args.command_id, "launchReceipt": {"path": str(launch), "sha256": sha256_file(launch)}, "exitStatus": exit_status if exit_status >= 0 else None, "signal": -exit_status if exit_status < 0 else None, "endMonotonicNs": ended, "prerequisites": prerequisites}
    exclusive_json(exit_path, exit_value)
    if observation is not None and trace is not None and trace_record is not None:
        events = trace_record["events"]
        if not isinstance(events, list):
            raise EvidenceError("invalid-live-io-trace", str(trace))
        observation_value: JsonValue = {"schemaVersion": 1, "kind": "live-io-observation", "process": launch_value["child"], "executable": str(executable), "executableSHA256": executable_sha, "observationStartMonotonicNs": started, "observationEndMonotonicNs": ended, "sourceReceipts": [{"path": str(launch), "sha256": sha256_file(launch)}, {"path": str(exit_path), "sha256": sha256_file(exit_path)}], "trace": {"path": str(trace), "sha256": sha256_file(trace)}, "deviceOpenCount": sum(1 for event in events if isinstance(event, dict) and event.get("kind") == "device-open"), "serialWriteCount": sum(1 for event in events if isinstance(event, dict) and event.get("kind") == "serial-write")}
        exclusive_json(observation, observation_value)
        if args.finalize_fd is not None:
            finalize_receipt(args.finalize_fd, exit_status, launch, exit_path, trace, observation)
    return exit_status if exit_status >= 0 else 128 - exit_status


def await_launch(args: argparse.Namespace) -> int:
    value = read_json(args.launch_receipt.resolve(strict=True))
    receipt = value if isinstance(value, dict) else {}
    if receipt.get("kind") != "process-launch" or receipt.get("commandID") != args.command_id:
        raise EvidenceError("launch-mismatch", str(args.launch_receipt))
    supervisor = receipt.get("supervisor")
    if not isinstance(supervisor, dict) or not isinstance(supervisor.get("pid"), int):
        raise EvidenceError("supervisor-missing", str(args.launch_receipt))
    if process_identity(supervisor["pid"]) != supervisor:
        raise EvidenceError("stale-supervisor", str(args.launch_receipt))
    print(args.launch_receipt.resolve(strict=True))
    return 0


def parser() -> argparse.ArgumentParser:
    value = argparse.ArgumentParser(description="Supervise one process group and attest observed launch and exit state.")
    commands = value.add_subparsers(dest="mode", required=True)
    run_parser = commands.add_parser("run")
    run_parser.add_argument("--launch-receipt", required=True, type=Path)
    run_parser.add_argument("--exit-receipt", required=True, type=Path)
    run_parser.add_argument("--command-id", required=True)
    run_parser.add_argument("--preexec-barrier", action="store_true")
    run_parser.add_argument("--exit-prerequisite", action="append", default=[], type=Path)
    run_parser.add_argument("--live-io-observation", type=Path)
    run_parser.add_argument("--live-io-trace", type=Path)
    run_parser.add_argument("--finalize-fd", type=int)
    run_parser.add_argument("command", nargs=argparse.REMAINDER)
    await_parser = commands.add_parser("await-launch")
    await_parser.add_argument("--launch-receipt", required=True, type=Path)
    await_parser.add_argument("--command-id", required=True)
    return value


def main() -> int:
    args = parser().parse_args()
    try:
        return run(args) if args.mode == "run" else await_launch(args)
    except (EvidenceError, OSError) as error:
        code = error.code if isinstance(error, EvidenceError) else "io-error"
        print(f"ERROR[{code}]: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
