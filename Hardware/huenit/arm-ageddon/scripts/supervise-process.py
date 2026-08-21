#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import os
import signal
import subprocess
import sys
import threading
import time
from types import FrameType
from pathlib import Path

from evidence_common import EvidenceError, JsonValue, clean_environment, exclusive_json, exclusive_write, executable_hash, process_identity, read_json, sha256_file
from supervisor_support import await_child_identity, await_exec, child_identity, finalize_receipt, prerequisite_records, receipt_paths, same_child_identity

ALLOWLIST = ("DEVELOPER_DIR", "LANG", "PATH", "SDKROOT", "TMPDIR", "USER")


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
        requested_executable, executable_sha = executable_hash(command[0], environment)
    except EvidenceError as error:
        if error.code not in {"missing-path", "missing-executable"}:
            raise
        requested_executable = Path(command[0]).absolute()
        executable_sha = ""
    executable = requested_executable
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
    started = time.monotonic_ns()
    pre_exec_child = process_identity(child_pid) if args.preexec_barrier else {"pid": child_pid, "birthAndCommand": "not-captured-without-preexec"}
    launch_value: JsonValue = {"schemaVersion": 1, "kind": "process-launch", "commandID": args.command_id, "argv": command, "supervisor": process_identity(os.getpid()), "child": pre_exec_child, "processGroup": child_pid, "executable": str(requested_executable), "executableSHA256": executable_sha, "intendedExecutable": str(requested_executable), "intendedExecutableSHA256": executable_sha, "startMonotonicNs": started, "preexecBarrier": args.preexec_barrier}
    if args.preexec_barrier:
        try:
            exclusive_json(launch, launch_value)
        except (EvidenceError, OSError):
            os.killpg(child_pid, signal.SIGTERM)
            os.waitpid(child_pid, 0)
            raise
        os.write(barrier_write, b"1")
    os.close(barrier_write)
    await_exec(exec_read)
    try:
        observed = await_child_identity(child_pid, command, requested_executable, executable, executable_sha, environment)
    except EvidenceError as error:
        if error.code == "live-io-command-mismatch":
            raise EvidenceError("live-io-process-mismatch", str(child_pid)) from error
        raise
    if observed is None:
        observed_child: dict[str, JsonValue] = {"pid": child_pid, "birthAndCommand": "exec-success-handshake"}
        observed_executable = requested_executable
        observed_executable_sha = executable_sha
    else:
        observed_child, observed_executable, observed_executable_sha = observed
    if not args.preexec_barrier:
        launch_value = {**launch_value, "child": observed_child, "observedExecutable": str(observed_executable), "observedExecutableSHA256": observed_executable_sha}
        try:
            exclusive_json(launch, launch_value)
        except (EvidenceError, OSError):
            os.killpg(child_pid, signal.SIGTERM)
            os.waitpid(child_pid, 0)
            raise
    observed_events: list[JsonValue] = []
    sample_count = 1
    observation_error: EvidenceError | None = None
    observation_finished = threading.Event()
    observation_started = threading.Event()

    def sample_process_group() -> None:
        nonlocal observation_error, sample_count
        while not observation_finished.is_set():
            try:
                identity = child_identity(child_pid, command, requested_executable, observed_executable, observed_executable_sha, environment)
                if not same_child_identity(observed_child, observed_executable, observed_executable_sha, identity[0], identity[1], identity[2], command, requested_executable, environment):
                    raise EvidenceError("live-io-process-mismatch", str(child_pid))
            except EvidenceError as error:
                if error.code == "live-io-command-mismatch":
                    observation_error = EvidenceError("live-io-process-mismatch", str(child_pid))
                elif error.code != "missing-process":
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
        trace_record = {"schemaVersion": 1, "kind": "live-io-trace", "observer": process_identity(os.getpid()), "process": observed_child, "processGroup": child_pid, "executable": str(observed_executable), "executableSHA256": observed_executable_sha, "observationStartMonotonicNs": started, "observationEndMonotonicNs": ended, "sampleCount": sample_count, "events": observed_events}
        exclusive_write(trace, (json.dumps(trace_record, sort_keys=True, separators=(",", ":")) + "\n").encode())
    prerequisites = prerequisite_records(args.exit_prerequisite)
    if trace is not None:
        prerequisites.append({"path": str(trace), "sha256": sha256_file(trace)})
    exit_value: JsonValue = {"schemaVersion": 1, "kind": "process-exit", "commandID": args.command_id, "launchReceipt": {"path": str(launch), "sha256": sha256_file(launch)}, "postExecChild": observed_child, "observedExecutable": str(observed_executable), "observedExecutableSHA256": observed_executable_sha, "exitStatus": exit_status if exit_status >= 0 else None, "signal": -exit_status if exit_status < 0 else None, "endMonotonicNs": ended, "prerequisites": prerequisites}
    exclusive_json(exit_path, exit_value)
    if observation is not None and trace is not None and trace_record is not None:
        events = trace_record["events"]
        if not isinstance(events, list):
            raise EvidenceError("invalid-live-io-trace", str(trace))
        observation_value: JsonValue = {"schemaVersion": 1, "kind": "live-io-observation", "process": observed_child, "executable": str(observed_executable), "executableSHA256": observed_executable_sha, "observationStartMonotonicNs": started, "observationEndMonotonicNs": ended, "sourceReceipts": [{"path": str(launch), "sha256": sha256_file(launch)}, {"path": str(exit_path), "sha256": sha256_file(exit_path)}], "trace": {"path": str(trace), "sha256": sha256_file(trace)}, "deviceOpenCount": sum(1 for event in events if isinstance(event, dict) and event.get("kind") == "device-open"), "serialWriteCount": sum(1 for event in events if isinstance(event, dict) and event.get("kind") == "serial-write")}
        exclusive_json(observation, observation_value)
        if args.finalize_fd is not None:
            finalize_receipt(args.finalize_fd, exit_status, launch, exit_path, trace, observation, pre_exec_child, observed_child, observed_executable, observed_executable_sha)
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
