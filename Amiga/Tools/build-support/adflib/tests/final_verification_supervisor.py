#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 final_verification_supervisor.py self-test --mode isolated-test --expected-protocol send2adf-final-verification/v1

from __future__ import annotations

import argparse
import hashlib
import hmac
import json
import os
import platform
import re
import secrets
import select
import shutil
import socket
import stat
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Final, Literal

PROTOCOL: Final = "send2adf-final-verification/v1"
ATTEMPT: Final = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}")
LIFECYCLE: Final = (
    "self-test",
    "start",
    "wait-ready",
    "credential-open",
    "status",
    "finalize",
    "abort",
    "cleanup",
)
REVIEWER_MODEL: Final = "gpt-5.6-sol"


def reviewer_argv(codex: Path, schema: Path) -> tuple[str, ...]:
    if not codex.is_absolute() or not schema.is_absolute():
        raise ProtocolError("reviewer_path_not_absolute")
    return (
        str(codex), "exec", "--ephemeral", "--ignore-user-config", "--ignore-rules",
        "--strict-config", "--skip-git-repo-check", "--sandbox", "read-only",
        "--output-schema", str(schema), "-m", REVIEWER_MODEL,
        "-c", "model_reasoning_effort=xhigh", "-",
    )


def credential_item_reference(value: str) -> str:
    if not value.startswith("op://GI Business/") or not value.endswith("/credential"):
        raise ProtocolError("credential_item_reference_invalid")
    if "\n" in value or "\r" in value or len(value) > 512:
        raise ProtocolError("credential_item_reference_invalid")
    return value


@dataclass(frozen=True, slots=True)
class ProtocolError(Exception):
    code: str

    def __str__(self) -> str:
        return self.code


def parse_sha256(value: str) -> str:
    if len(value) != 64 or re.fullmatch(r"[0-9a-f]{64}", value) is None:
        raise ProtocolError("sha256_invalid")
    return value


def parse_commit(value: str) -> str:
    if len(value) != 40 or re.fullmatch(r"[0-9a-f]{40}", value) is None:
        raise ProtocolError("commit_sha_invalid")
    return value


def exclusive_json_at(parent: Path, name: str, payload: dict[str, str | int | bool]) -> None:
    parent_fd = os.open(parent, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    try:
        fd = os.open(name, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600, dir_fd=parent_fd)
        try:
            encoded = (json.dumps(payload, sort_keys=True, separators=(",", ":")) + "\n").encode()
            os.write(fd, encoded)
            os.fsync(fd)
        finally:
            os.close(fd)
    except OSError as error:
        raise ProtocolError(f"exclusive_create_failed:{error.errno}") from error
    finally:
        os.close(parent_fd)


def git_output(repo_root: Path, arguments: tuple[str, ...]) -> str:
    result = subprocess.run(
        ("/usr/bin/git", "-C", str(repo_root), *arguments),
        check=False,
        capture_output=True,
        text=True,
        env={"LANG": "C", "LC_ALL": "C", "PATH": "/usr/bin:/bin"},
    )
    if result.returncode != 0 or result.stderr:
        raise ProtocolError(f"git_observation_failed:{result.returncode}")
    return result.stdout.strip()


def observe_merge_topology(repo_root: Path, expected_final: str) -> tuple[str, str, str, str]:
    head = parse_commit(git_output(repo_root, ("rev-parse", "HEAD")))
    if head != expected_final:
        raise ProtocolError("head_not_final_sha")
    fields = git_output(repo_root, ("show", "-s", "--format=%P%n%T", head)).splitlines()
    if len(fields) != 2:
        raise ProtocolError("merge_observation_shape_invalid")
    parents = fields[0].split()
    if len(parents) != 2:
        raise ProtocolError("final_commit_not_two_parent_merge")
    final_tree = parse_commit(fields[1])
    reviewed_tree = parse_commit(git_output(repo_root, ("show", "-s", "--format=%T", parents[1])))
    if final_tree != reviewed_tree:
        raise ProtocolError("merge_tree_differs_from_reviewed_head")
    return head, parse_commit(parents[0]), parse_commit(parents[1]), final_tree


@dataclass(frozen=True, slots=True)
class ExternalSeal:
    digest: str
    context: str
    final_sha: str


def sealed_digest(payload: bytes, context: str, final_sha: str) -> ExternalSeal:
    digest = hashlib.sha256(b"send2adf-anchor\0" + context.encode() + b"\0" + final_sha.encode() + b"\0" + payload)
    return ExternalSeal(digest.hexdigest(), context, final_sha)


def verify_sealed_digest(payload: bytes, seal: ExternalSeal, context: str, final_sha: str) -> None:
    if seal.context != context or seal.final_sha != final_sha:
        raise ProtocolError("external_anchor_context_mismatch")
    observed = sealed_digest(payload, context, final_sha)
    if not hmac.compare_digest(observed.digest, seal.digest):
        raise ProtocolError("external_anchor_digest_mismatch")


def consume_counter(expected: int, received: int) -> int:
    if received != expected:
        raise ProtocolError("control_counter_mismatch")
    if expected >= (2**63 - 1):
        raise ProtocolError("control_counter_exhausted")
    return expected + 1


def own_source_digest() -> str:
    descriptor = os.open(__file__, os.O_RDONLY | os.O_NOFOLLOW)
    try:
        os.lseek(descriptor, 0, os.SEEK_SET)
        digest = hashlib.sha256()
        while chunk := os.read(descriptor, 131072):
            digest.update(chunk)
        return digest.hexdigest()
    finally:
        os.close(descriptor)


def verify_path_digest(path: Path, expected: str) -> None:
    if not path.is_absolute() or len(path.parts) < 2:
        raise ProtocolError("verified_tool_path_invalid")
    directory = os.open("/", os.O_RDONLY | os.O_DIRECTORY)
    descriptor = -1
    try:
        for component in path.parts[1:-1]:
            following = os.open(
                component, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=directory
            )
            os.close(directory)
            directory = following
        descriptor = os.open(path.parts[-1], os.O_RDONLY | os.O_NOFOLLOW, dir_fd=directory)
        before = os.fstat(descriptor)
        if not stat.S_ISREG(before.st_mode):
            raise ProtocolError("verified_tool_not_regular")
        digest = hashlib.sha256()
        while chunk := os.read(descriptor, 131072):
            digest.update(chunk)
        after = os.fstat(descriptor)
        if (before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns) != (
            after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns
        ):
            raise ProtocolError("verified_tool_identity_changed")
        if not hmac.compare_digest(digest.hexdigest(), expected):
            raise ProtocolError("verified_tool_digest_mismatch")
    except OSError as error:
        raise ProtocolError(f"verified_tool_open_failed:{error.errno}") from error
    finally:
        if descriptor >= 0:
            os.close(descriptor)
        os.close(directory)


def require_attempt(value: str) -> str:
    if ATTEMPT.fullmatch(value) is None:
        raise ProtocolError("attempt_id_invalid")
    return value


def require_private_directory(path: Path) -> Path:
    metadata = path.lstat()
    if not stat.S_ISDIR(metadata.st_mode) or metadata.st_uid != os.getuid() or metadata.st_mode & 0o077:
        raise ProtocolError("evidence_directory_not_private")
    return path.resolve(strict=True)


def anchor_path(final_sha: str, attempt_id: str) -> Path:
    identity = hashlib.sha256(f"{final_sha}:{attempt_id}".encode()).hexdigest()[:32]
    return Path("/tmp") / f"send2adf-{identity}"


def self_test(mode: Literal["final", "isolated-test"], expected_protocol: str, expected_sha256: str | None) -> dict[str, str | bool]:
    if expected_protocol != PROTOCOL:
        raise ProtocolError("protocol_mismatch")
    if expected_sha256 is not None:
        expected = parse_sha256(expected_sha256)
        observed = own_source_digest()
        if not hmac.compare_digest(observed, expected):
            raise ProtocolError("supervisor_digest_mismatch")
    is_darwin = platform.system() == "Darwin"
    if mode == "final" and (not is_darwin or shutil.which("xcodebuild") is None):
        raise ProtocolError("final_host_unsupported")
    return {"credential_retrieved": False, "host": platform.platform(), "mode": mode, "protocol": PROTOCOL, "supported": True}


def start(arguments: argparse.Namespace) -> dict[str, str | int]:
    attempt = require_attempt(arguments.attempt_id)
    final_sha = parse_commit(arguments.final_sha)
    evidence = require_private_directory(arguments.evidence_dir)
    if arguments.state.resolve() != evidence / "state.json":
        raise ProtocolError("state_path_not_exact")
    if arguments.bootstrap_receipt.resolve() != evidence / "bootstrap.json":
        raise ProtocolError("bootstrap_path_not_exact")
    if arguments.state.exists() or arguments.bootstrap_receipt.exists():
        raise ProtocolError("attempt_output_collision")
    observed_final, base_sha, reviewed_head_sha, final_tree_sha = observe_merge_topology(
        arguments.repo_root.resolve(strict=True), final_sha
    )
    if arguments.local_test_sodium is None or arguments.local_test_sodium_sha256 is None:
        raise ProtocolError("stage11b_native_broker_required")
    sodium_path = arguments.local_test_sodium.resolve(strict=True)
    sodium_digest = parse_sha256(arguments.local_test_sodium_sha256)
    verify_path_digest(sodium_path, sodium_digest)
    adapter = arguments.adapter.resolve(strict=True)
    verify_path_digest(adapter, hashlib.sha256(adapter.read_bytes()).hexdigest())
    anchor = anchor_path(final_sha, attempt)
    anchor.mkdir(mode=0o700)
    control_socket = anchor / "control.sock"
    launcher_script = Path(__file__).with_name("final_verification_local_launcher.py")
    broker_script = Path(__file__).with_name("final_verification_broker.py")
    launcher = subprocess.Popen(
        [sys.executable, str(launcher_script), "--broker", str(broker_script),
         "--socket", str(control_socket), "--attempt-id", attempt,
         "--orchestrator-pid", str(arguments.orchestrator_pid), "--sodium", str(sodium_path),
         "--sodium-sha256", sodium_digest],
        pass_fds=(3,), stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
        env={"LANG": "C", "LC_ALL": "C"}, start_new_session=True,
    )
    assert launcher.stdout is not None
    readable, _, _ = select.select([launcher.stdout], [], [], 5)
    if not readable:
        launcher.terminate()
        raise ProtocolError("local_broker_readiness_timeout")
    ready_line = launcher.stdout.readline()
    if not ready_line:
        launcher.wait(timeout=5)
        assert launcher.stderr is not None
        detail = launcher.stderr.read().strip()
        raise ProtocolError(f"local_broker_readiness_missing:{detail}")
    ready = json.loads(ready_line)
    launcher_pid = int(ready.get("launcher_pid", 0))
    supervisor_pid = int(ready.get("supervisor_pid", 0))
    public_key = str(ready.get("public_key", ""))
    if launcher_pid != launcher.pid or supervisor_pid <= 0 or re.fullmatch(r"[0-9a-f]{64}", public_key) is None:
        launcher.terminate()
        raise ProtocolError("local_broker_readiness_invalid")
    state = {
        "adapter": str(adapter),
        "attempt_id": attempt,
        "base_sha": base_sha,
        "control_socket": str(control_socket),
        "final_sha": observed_final,
        "final_tree_sha": final_tree_sha,
        "launcher_pid": launcher_pid,
        "mode": "local_test",
        "orchestrator_pid": arguments.orchestrator_pid,
        "protocol": PROTOCOL,
        "public_key": public_key,
        "reviewed_head_sha": reviewed_head_sha,
        "sodium": str(sodium_path),
        "sodium_sha256": sodium_digest,
        "status": "credential_pending",
        "supervisor_pid": supervisor_pid,
        "supervisor_sha256": own_source_digest(),
    }
    exclusive_json_at(evidence, "state.json", state)
    state_bytes = (evidence / "state.json").read_bytes()
    anchor_seal = sealed_digest(state_bytes, f"state:{attempt}", str(final_sha))
    exclusive_json_at(anchor, "state-seal.json", {"context": anchor_seal.context, "digest": anchor_seal.digest, "final_sha": anchor_seal.final_sha})
    bootstrap = {
        "attempt_id": attempt,
        "next_counter": 1,
        "orchestrator_pid": arguments.orchestrator_pid,
        "protocol": PROTOCOL,
        "readiness": "credential_pending",
        "state_digest": hashlib.sha256(state_bytes).hexdigest(),
        "launcher_pid": launcher_pid,
        "supervisor_pid": supervisor_pid,
    }
    exclusive_json_at(evidence, "bootstrap.json", bootstrap)
    return {"attempt_id": attempt, "launcher_pid": launcher_pid, "next_counter": 1, "supervisor_pid": supervisor_pid}


def load_live(arguments: argparse.Namespace, require_processes: bool = True) -> dict[str, str | int | bool]:
    attempt = require_attempt(arguments.attempt_id)
    evidence = require_private_directory(arguments.evidence_dir)
    if arguments.state.resolve() != evidence / "state.json":
        raise ProtocolError("state_path_not_exact")
    expected_source = parse_sha256(arguments.expected_supervisor_sha256)
    if not hmac.compare_digest(own_source_digest(), expected_source):
        raise ProtocolError("supervisor_digest_mismatch")
    payload = json.loads(arguments.state.read_text(encoding="utf-8"))
    if not isinstance(payload, dict) or payload.get("protocol") != PROTOCOL or payload.get("mode") != "local_test":
        raise ProtocolError("local_state_invalid")
    for key, expected in (("attempt_id", attempt), ("launcher_pid", getattr(arguments, "launcher_pid", payload.get("launcher_pid"))),
                          ("supervisor_pid", getattr(arguments, "supervisor_pid", payload.get("supervisor_pid"))),
                          ("orchestrator_pid", getattr(arguments, "orchestrator_pid", payload.get("orchestrator_pid")))):
        if payload.get(key) != expected:
            raise ProtocolError(f"{key}_mismatch")
    state_bytes = arguments.state.read_bytes()
    anchor = anchor_path(str(payload["final_sha"]), attempt)
    seal_payload = json.loads((anchor / "state-seal.json").read_text(encoding="utf-8"))
    verify_sealed_digest(state_bytes, ExternalSeal(**seal_payload), f"state:{attempt}", str(payload["final_sha"]))
    observe_merge_topology(arguments.repo_root.resolve(strict=True), str(payload["final_sha"]))
    if require_processes:
        for key in ("launcher_pid", "supervisor_pid"):
            try:
                os.kill(int(payload[key]), 0)
            except OSError as error:
                raise ProtocolError(f"{key}_not_live") from error
    return payload


def broker_request(arguments: argparse.Namespace, operation: str) -> dict[str, str | int | bool]:
    state = load_live(arguments)
    request = {"attempt_id": arguments.attempt_id, "counter": arguments.counter, "operation": operation}
    client = socket.socket(socket.AF_UNIX)
    try:
        client.settimeout(5)
        client.connect(str(state["control_socket"]))
        client.sendall((json.dumps(request, sort_keys=True, separators=(",", ":")) + "\n").encode())
        line = client.makefile("rb").readline(4097)
    finally:
        client.close()
    if not line.endswith(b"\n") or len(line) > 4096:
        raise ProtocolError("broker_response_invalid")
    response = json.loads(line)
    if not isinstance(response, dict):
        raise ProtocolError("broker_response_invalid")
    if "error" in response:
        raise ProtocolError(str(response["error"]))
    signature = response.pop("signature", None)
    if not isinstance(signature, str):
        raise ProtocolError("broker_signature_missing")
    from final_verification_broker import BrokerError, canonical, verify_ed25519
    try:
        verify_ed25519(Path(str(state["sodium"])), str(state["sodium_sha256"]), str(state["public_key"]), signature, canonical(response))
    except BrokerError as error:
        raise ProtocolError(str(error)) from error
    return {**response, "signature": signature}


def create_lane_states(arguments: argparse.Namespace, state: dict[str, str | int | bool]) -> None:
    from final_verification_catalog import LANES
    root = arguments.evidence_dir / "lane-state"
    root.mkdir(mode=0o700)
    for lane in LANES:
        directory = root / lane
        directory.mkdir(mode=0o700)
        payload = {
            "attempt_id": arguments.attempt_id, "base_sha": state["base_sha"],
            "capability_id": secrets.token_hex(16), "final_sha": state["final_sha"],
            "lane": lane, "protocol": PROTOCOL, "public_fingerprint": state["public_key"],
        }
        exclusive_json_at(directory, "state.json", payload)
        (directory / "state.json").chmod(0o400)


def run_driver(arguments: argparse.Namespace, state_path: Path, evidence: Path, lane: str, probe: str | None) -> None:
    assignment = json.loads(state_path.read_text(encoding="utf-8"))
    parent, child = socket.socketpair()
    parent_fd = os.dup(parent.fileno())
    parent.close()
    try:
        saved_three = os.dup(3)
    except OSError:
        saved_three = -1
    os.dup2(child.fileno(), 3)
    driver = Path(str(load_live(arguments, require_processes=False)["adapter"])).with_name("run_final_verification.py")
    command = [sys.executable, str(driver), "--repo-root", str(arguments.repo_root), "--evidence-dir", str(evidence),
               "--state", str(state_path), "--attempt-id", arguments.attempt_id, "--lane", lane]
    if probe is not None:
        command.extend(("--probe", probe))
    process = subprocess.Popen(command, pass_fds=(3,), stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                               text=True, env={"LANG": "C", "LC_ALL": "C"})
    if saved_three >= 0:
        os.dup2(saved_three, 3)
        os.close(saved_three)
    else:
        os.close(3)
    child.close()
    stdout, stderr = process.communicate(timeout=20)
    parent = socket.socket(fileno=parent_fd)
    event_line = parent.makefile("r", encoding="utf-8").readline()
    parent.close()
    expected = 0 if probe is None or probe == "offline-rebuild" else 3
    if process.returncode != expected or stdout or stderr or not event_line:
        detail = (stderr or stdout).strip().replace("\n", ":")[:256]
        raise ProtocolError(f"lane_execution_failed:{lane}:{probe or 'positive'}:{process.returncode}:{detail}")
    event = json.loads(event_line)
    stem = lane if probe is None else f"probe-{probe}"
    if event != {"capability_id": assignment["capability_id"], "event": "evidence-ready", "stem": stem}:
        raise ProtocolError("lane_capability_response_invalid")


def execute_local_verification(arguments: argparse.Namespace, state: dict[str, str | int | bool]) -> None:
    from final_verification_catalog import LANES, PROBES, PROBE_LANE
    create_lane_states(arguments, state)
    for lane in LANES:
        run_driver(arguments, arguments.evidence_dir / "lane-state" / lane / "state.json", arguments.evidence_dir, lane, None)
    probes = arguments.evidence_dir / "probes"
    probes.mkdir(mode=0o700)
    for probe in PROBES:
        evidence = probes / probe
        evidence.mkdir(mode=0o700)
        lane = PROBE_LANE[probe]
        run_driver(arguments, arguments.evidence_dir / "lane-state" / lane / "state.json", evidence, lane, probe)


def live_command(arguments: argparse.Namespace) -> dict[str, str | int | bool]:
    operation = arguments.lifecycle
    if operation == "status" and arguments.mock_revoke:
        operation = "revoke"
    if operation == "credential-open":
        credential_item_reference(arguments.item_reference)
        if arguments.provider != "mock":
            raise ProtocolError("production_provider_requires_stage11b")
    response = broker_request(arguments, operation)
    if arguments.lifecycle == "credential-open":
        execute_local_verification(arguments, load_live(arguments))
    if arguments.lifecycle == "finalize":
        exclusive_json_at(arguments.evidence_dir, "final-receipt.json", response)
    if arguments.lifecycle == "abort":
        exclusive_json_at(arguments.evidence_dir, "abort-receipt.json", response)
    return response


def cleanup(arguments: argparse.Namespace) -> dict[str, str | bool]:
    state = load_live(arguments, require_processes=False)
    final_receipt = arguments.evidence_dir / "final-receipt.json"
    abort_receipt = arguments.evidence_dir / "abort-receipt.json"
    receipts = tuple(path for path in (final_receipt, abort_receipt) if path.is_file())
    if len(receipts) != 1 or Path(str(state["control_socket"])).exists():
        raise ProtocolError("final_cleanup_precondition_failed")
    receipt = json.loads(receipts[0].read_text(encoding="utf-8"))
    signature = receipt.pop("signature", None)
    from final_verification_broker import BrokerError, canonical, verify_ed25519
    try:
        if not isinstance(signature, str):
            raise ProtocolError("broker_signature_missing")
        verify_ed25519(Path(str(state["sodium"])), str(state["sodium_sha256"]), str(state["public_key"]), signature, canonical(receipt))
    except BrokerError as error:
        raise ProtocolError(str(error)) from error
    anchor = anchor_path(str(state["final_sha"]), arguments.attempt_id)
    (anchor / "state-seal.json").unlink()
    anchor.rmdir()
    return {"attempt_id": arguments.attempt_id, "cleaned": True}


def add_live_arguments(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--repo-root", type=Path, required=True)
    parser.add_argument("--evidence-dir", type=Path, required=True)
    parser.add_argument("--state", type=Path, required=True)
    parser.add_argument("--attempt-id", required=True)
    parser.add_argument("--launcher-pid", type=int, required=True)
    parser.add_argument("--supervisor-pid", type=int, required=True)
    parser.add_argument("--orchestrator-pid", type=int, required=True)
    parser.add_argument("--expected-supervisor-sha256", required=True)
    parser.add_argument("--counter", type=int, required=True)


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser(allow_abbrev=False)
    commands = root.add_subparsers(dest="lifecycle", required=True)
    check = commands.add_parser("self-test", allow_abbrev=False)
    check.add_argument("--mode", choices=("final", "isolated-test"), required=True)
    check.add_argument("--expected-protocol", required=True)
    check.add_argument("--expected-sha256")
    begin = commands.add_parser("start", allow_abbrev=False)
    begin.add_argument("--adapter", type=Path, required=True)
    begin.add_argument("--repo-root", type=Path, required=True)
    begin.add_argument("--evidence-dir", type=Path, required=True)
    begin.add_argument("--state", type=Path, required=True)
    begin.add_argument("--attempt-id", required=True)
    begin.add_argument("--final-sha", required=True)
    begin.add_argument("--orchestrator-pid", type=int, required=True)
    begin.add_argument("--bootstrap-receipt", type=Path, required=True)
    begin.add_argument("--local-test-sodium", type=Path)
    begin.add_argument("--local-test-sodium-sha256")
    for name in ("wait-ready", "finalize", "abort"):
        add_live_arguments(commands.add_parser(name, allow_abbrev=False))
    status = commands.add_parser("status", allow_abbrev=False)
    add_live_arguments(status)
    status.add_argument("--mock-revoke", action="store_true")
    credential = commands.add_parser("credential-open", allow_abbrev=False)
    add_live_arguments(credential)
    credential.add_argument("--provider", choices=("op", "mock"), required=True)
    credential.add_argument("--item-reference", required=True)
    cleanup = commands.add_parser("cleanup", allow_abbrev=False)
    cleanup.add_argument("--repo-root", type=Path, required=True)
    cleanup.add_argument("--evidence-dir", type=Path, required=True)
    cleanup.add_argument("--state", type=Path, required=True)
    cleanup.add_argument("--attempt-id", required=True)
    cleanup.add_argument("--expected-supervisor-sha256", required=True)
    return root


def run(arguments: argparse.Namespace) -> dict[str, str | int | bool]:
    if arguments.lifecycle == "self-test":
        return self_test(arguments.mode, arguments.expected_protocol, arguments.expected_sha256)
    if arguments.lifecycle == "start":
        return start(arguments)
    if arguments.lifecycle == "cleanup":
        return cleanup(arguments)
    return live_command(arguments)


def main() -> int:
    arguments = parser().parse_args()
    try:
        result = run(arguments)
    except (ProtocolError, OSError, json.JSONDecodeError) as error:
        print(error, file=sys.stderr)
        return 2
    json.dump(result, sys.stdout, sort_keys=True)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
