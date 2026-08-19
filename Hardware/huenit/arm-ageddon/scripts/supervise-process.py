#!/usr/bin/env python3

from __future__ import annotations

import argparse
import os
import signal
import sys
import time
from types import FrameType
from pathlib import Path

from evidence_common import EvidenceError, JsonValue, clean_environment, exclusive_json, executable_hash, process_identity, read_json, sha256_file

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


def run(args: argparse.Namespace) -> int:
    command: list[str] = args.command[1:] if args.command[:1] == ["--"] else args.command
    if not command:
        raise EvidenceError("missing-command", "command after -- is required")
    launch, exit_path = receipt_paths(args.launch_receipt, args.exit_receipt)
    environment = clean_environment(os.environ, ALLOWLIST)
    executable, executable_sha = executable_hash(command[0], environment)
    read_fd, write_fd = os.pipe()
    started = time.monotonic_ns()
    child_pid = os.fork()
    if child_pid == 0:
        os.setsid()
        os.close(write_fd)
        if args.preexec_barrier and os.read(read_fd, 1) != b"1":
            os._exit(126)
        os.close(read_fd)
        try:
            os.execvpe(command[0], command, environment)
        except OSError:
            os._exit(126)
    os.close(read_fd)
    launch_value: JsonValue = {"schemaVersion": 1, "kind": "process-launch", "commandID": args.command_id, "argv": command, "supervisor": process_identity(os.getpid()), "child": process_identity(child_pid), "processGroup": child_pid, "executable": str(executable), "executableSHA256": executable_sha, "startMonotonicNs": started, "preexecBarrier": args.preexec_barrier}
    try:
        exclusive_json(launch, launch_value)
    except (EvidenceError, OSError):
        os.close(write_fd)
        os.killpg(child_pid, signal.SIGTERM)
        os.waitpid(child_pid, 0)
        raise
    if args.preexec_barrier:
        os.write(write_fd, b"1")
    os.close(write_fd)

    def forward(signum: int, _frame: FrameType | None) -> None:
        try:
            os.killpg(child_pid, signum)
        except ProcessLookupError:
            return

    signal.signal(signal.SIGTERM, forward)
    signal.signal(signal.SIGINT, forward)
    _, wait_status = os.waitpid(child_pid, 0)
    exit_status = os.waitstatus_to_exitcode(wait_status)
    prerequisites = prerequisite_records(args.exit_prerequisite)
    exit_value: JsonValue = {"schemaVersion": 1, "kind": "process-exit", "commandID": args.command_id, "launchReceipt": {"path": str(launch), "sha256": sha256_file(launch)}, "exitStatus": exit_status if exit_status >= 0 else None, "signal": -exit_status if exit_status < 0 else None, "endMonotonicNs": time.monotonic_ns(), "prerequisites": prerequisites}
    exclusive_json(exit_path, exit_value)
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
