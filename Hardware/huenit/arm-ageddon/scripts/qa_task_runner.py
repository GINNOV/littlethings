from __future__ import annotations

import json
import os
import socket
import subprocess
import sys
import time
import uuid
from pathlib import Path

from evidence_common import EvidenceError, JsonValue, clean_environment, exclusive_json, read_json, require_mapping, require_string, sha256_bytes, sha256_file, sha256_tree

ALLOWLIST = ("DEVELOPER_DIR", "LANG", "PATH", "SDKROOT", "TMPDIR", "USER")
PLAN_SHA256 = "beed619c2c60325c9d6ab29a9a80ed371f46d8bbad80313a04b6c200401825ab"
TASK1_RELEASED_COMMIT = "2fd5b1723f16c7405898e476f167206f72be1e84"


def execute(command: list[str], transcript, environment: dict[str, str], expected: int = 0) -> None:
    transcript.write(("$ " + " ".join(command) + "\n").encode())
    transcript.flush()
    result = subprocess.run(command, env=environment, stdout=transcript, stderr=subprocess.STDOUT, check=False)
    transcript.write(f"exit={result.returncode}\n".encode())
    transcript.flush()
    if result.returncode != expected:
        raise EvidenceError("unexpected-exit", f"{command[0]}: {result.returncode}, expected {expected}")


def control_message(control: socket.socket) -> dict[str, JsonValue]:
    with control.makefile("rb") as stream:
        line = stream.readline(4097)
    if not line or len(line) > 4096:
        raise EvidenceError("invalid-finalization-response", "supervisor control response")
    value = json.loads(line)
    return require_mapping(value, "supervisor control response")


def begin_supervision(command: list[str], transcript, environment: dict[str, str], expected: int = 0) -> tuple[subprocess.Popen[bytes], socket.socket]:
    control, supervisor_control = socket.socketpair()
    try:
        divider = command.index("--")
        supervised = [*command[:divider], "--finalize-fd", str(supervisor_control.fileno()), *command[divider:]]
        transcript.write(("$ " + " ".join(supervised) + "\n").encode())
        transcript.flush()
        process = subprocess.Popen(supervised, env=environment, stdout=transcript, stderr=subprocess.STDOUT, pass_fds=(supervisor_control.fileno(),))
    finally:
        supervisor_control.close()
    ready = control_message(control)
    if ready.get("status") != "ready" or ready.get("childExitStatus") != expected:
        control.close()
        process.terminate()
        process.wait()
        raise EvidenceError("unexpected-exit", f"{command[0]}: {ready}")
    return process, control


def finish_supervision(process: subprocess.Popen[bytes], control: socket.socket, receipt: Path, expected: int = 0) -> None:
    control.sendall((json.dumps({"receipt": str(receipt)}) + "\n").encode())
    response = control_message(control)
    control.close()
    exit_status = process.wait(timeout=10)
    if response.get("status") != "pass":
        raise EvidenceError(require_string(response.get("error"), "finalization error"), str(receipt))
    if exit_status != expected:
        raise EvidenceError("unexpected-exit", f"supervisor: {exit_status}, expected {expected}")


def task1_validation(root: Path, transcript, environment: dict[str, str]) -> Path:
    names = ("ARMAGEDDON_TASK1_INDEX", "ARMAGEDDON_TASK1_RELEASE", "ARMAGEDDON_PREFLIGHT")
    if any(name not in os.environ for name in names):
        raise EvidenceError("missing-task1-evidence", ",".join(names))
    preserved = root / "task-1-parent-chain.json"
    command = ["python3", "scripts/validate-evidence.py", "--schema", "Tests/ReviewSchemas/task-1-parent-evidence.schema.json", "--task1-index", os.environ[names[0]], "--task1-release", os.environ[names[1]], "--preflight", os.environ[names[2]], "--base-commit", "4d9036ae762c1fb44110e7d56b4de8c73c7fa7ed", "--preflight-base", "4d9036ae762c1fb44110e7d56b4de8c73c7fa7ed", "--released-commit", TASK1_RELEASED_COMMIT, "--plan-sha256", PLAN_SHA256, "--preserve-output", str(preserved)]
    execute(command, transcript, environment)
    return preserved


def probe(binary: str, root: Path, transcript, environment: dict[str, str]) -> None:
    socket_path = Path("/private/tmp") / f"armageddon-{binary.lower()}-{uuid.uuid4().hex[:12]}.sock"
    events = root / f"{binary}.events.jsonl"
    ready = root / f"{binary}.ready.json"
    flush = root / f"{binary}.flush.json"
    stop = root / f"{binary}.stop.json"
    process = subprocess.Popen([binary, "server", "--socket", str(socket_path), "--events", str(events), "--ready-receipt", str(ready)], env=environment, stdout=transcript, stderr=subprocess.STDOUT)
    deadline = time.monotonic() + 10
    while not ready.exists() and process.poll() is None and time.monotonic() < deadline:
        time.sleep(0.01)
    if not ready.exists():
        process.terminate()
        process.wait()
        raise EvidenceError("probe-not-ready", binary)
    execute([binary, "control", "--socket", str(socket_path), "--flush", "--ack", str(flush)], transcript, environment)
    execute([binary, "control", "--socket", str(socket_path), "--stop", "--ack", str(stop)], transcript, environment)
    if process.wait(timeout=10) != 0 or events.stat().st_size == 0 or socket_path.exists():
        raise EvidenceError("probe-failed", binary)


def fifo_release(root: Path, prerequisite: Path, transcript, environment: dict[str, str]) -> tuple[Path, Path]:
    fifo = root / "release.fifo"
    receipt = root / "release.json"
    capture = root / "release-token.bin"
    os.mkfifo(fifo, 0o600)
    reader = os.fork()
    if reader == 0:
        with fifo.open("rb", buffering=0) as stream, capture.open("xb") as output:
            output.write(stream.read(1))
            output.flush()
            os.fsync(output.fileno())
        os._exit(0)
    expected = sha256_file(prerequisite)
    execute(["python3", "scripts/release-gate.py", "--fifo", str(fifo), "--receipt", str(receipt), "--nonce", str(uuid.uuid4()), "--prerequisite", f"{prerequisite}={expected}"], transcript, environment)
    _, status = os.waitpid(reader, 0)
    if os.waitstatus_to_exitcode(status) != 0 or capture.read_bytes() != b"1":
        raise EvidenceError("gate-token-mismatch", str(capture))
    return receipt, capture


def infrastructure_tools(root: Path, transcript, environment: dict[str, str]) -> list[Path]:
    artifacts: list[Path] = []
    manifest_root = root / "manifest-root"
    bundle = manifest_root / "Fixture.bundle"
    bundle.mkdir(parents=True, mode=0o700)
    (bundle / "fixture.txt").write_text("deterministic fixture\n", encoding="utf-8")
    merkle = manifest_root / "merkle.json"
    bundle_manifest = manifest_root / "bundle.json"
    execute(["python3", "scripts/write-merkle.py", "--root", str(manifest_root), "--output", str(merkle)], transcript, environment)
    execute(["python3", "scripts/write-bundle-manifest.py", "--bundle", str(bundle), "--root", str(manifest_root), "--output", str(bundle_manifest)], transcript, environment)
    artifacts.extend((merkle, bundle_manifest))

    process_root = root / "process"
    process_root.mkdir(mode=0o700)
    launch = process_root / "launch.json"
    exit_receipt = process_root / "exit.json"
    execute(["python3", "scripts/supervise-process.py", "run", "--launch-receipt", str(launch), "--exit-receipt", str(exit_receipt), "--command-id", "task2-true", "--preexec-barrier", "--", "/usr/bin/true"], transcript, environment)
    recorded = process_root / "recorded-exit.json"
    execute(["python3", "scripts/record-process-exit.py", "--owner-receipt", str(exit_receipt), "--receipt", str(recorded)], transcript, environment)
    release, token = fifo_release(process_root, exit_receipt, transcript, environment)
    artifacts.extend((launch, exit_receipt, recorded, release, token))

    build_root = root / "recorded-build"
    build_root.mkdir(mode=0o700)
    build_receipt = build_root / "build.json"
    execute(["python3", "scripts/record-build.py", "--root", str(build_root), "--receipt", str(build_receipt), "--stdout", str(build_root / "stdout.txt"), "--stderr", str(build_root / "stderr.txt"), "--", "/usr/bin/true"], transcript, environment)
    artifacts.append(build_receipt)

    preflight_path = Path(os.environ["ARMAGEDDON_PREFLIGHT"]).resolve(strict=True)
    preflight = require_mapping(read_json(preflight_path), "preflight")
    session = require_string(preflight.get("parentSession"), "parentSession")
    lease_nonce = str(uuid.uuid4())
    lease_start = root / "gui-lease-start.json"
    lease_end = root / "gui-lease-end.json"
    lease_schedule = root / "gui-lease-schedule.json"
    for mode, receipt in (("start", lease_start), ("end", lease_end), ("schedule", lease_schedule)):
        command = ["python3", "scripts/gui-lease.py", mode, "--preflight", str(preflight_path), "--session", session, "--nonce", lease_nonce, "--receipt", str(receipt)]
        if mode != "start":
            command.extend(("--start-receipt", str(lease_start)))
        execute(command, transcript, environment)
    artifacts.extend((lease_start, lease_end, lease_schedule))
    return artifacts


def artifact_record(path: Path) -> JsonValue:
    resolved = path.resolve(strict=True)
    digest = sha256_tree(resolved) if resolved.is_dir() else sha256_file(resolved)
    return {"path": str(resolved), "sha256": digest}


def happy(root: Path, transcript, environment: dict[str, str]) -> tuple[list[Path], subprocess.Popen[bytes], socket.socket]:
    build = root / "build"
    os.mkdir(build, 0o700)
    execute(["scripts/verify-no-live-io-in-tests.sh"], transcript, environment)
    execute(["scripts/check-motion-boundary.sh"], transcript, environment)
    execute(["swift", "test", "--parallel", "--scratch-path", str(build / "swiftpm-tests")], transcript, environment)
    execute(["swift", "build", "--scratch-path", str(build / "swiftpm-tools")], transcript, environment)
    environment["PATH"] = f"{build / 'swiftpm-tools/debug'}:{environment['PATH']}"
    probe("RuntimeTraceProbe", root, transcript, environment)
    probe("SandboxLogProbe", root, transcript, environment)
    result_bundle = root / "camera-ml-app.xcresult"
    observation_root = root / "live-io"
    os.mkdir(observation_root, 0o700)
    launch_receipt = observation_root / "launch.json"
    exit_receipt = observation_root / "exit.json"
    trace = observation_root / "trace.json"
    observation = observation_root / "observation.json"
    xcode_command = ["xcodebuild", "-project", "Armageddon.xcodeproj", "-scheme", "ArmageddonApp", "-destination", "platform=macOS", "-derivedDataPath", str(build / "xcode"), "-resultBundlePath", str(result_bundle), "test", "-only-testing:ArmageddonUITests/LaunchProfileTests/testAllFixtureProfilesReachStableUI"]
    process, control = begin_supervision(["python3", "scripts/supervise-process.py", "run", "--launch-receipt", str(launch_receipt), "--exit-receipt", str(exit_receipt), "--command-id", "task2-ui-profiles", "--preexec-barrier", "--live-io-observation", str(observation), "--live-io-trace", str(trace), "--", *xcode_command], transcript, environment)
    app = build / "xcode/Build/Products/Debug/Armageddon.app/Contents/MacOS/Armageddon"
    network_receipt = root / "network-static.json"
    execute(["python3", "scripts/audit-network.py", "--app", str(app), "--allowlist", "Tests/Fixtures/network-static-allowlist.json", "--receipt", str(network_receipt)], transcript, environment)
    parent = task1_validation(root, transcript, environment)
    return [result_bundle, parent, network_receipt, launch_receipt, exit_receipt, trace, observation, root / "RuntimeTraceProbe.events.jsonl", root / "SandboxLogProbe.events.jsonl", *infrastructure_tools(root, transcript, environment)], process, control


def failure(root: Path, transcript, environment: dict[str, str]) -> tuple[list[Path], subprocess.Popen[bytes], socket.socket]:
    observation_root = root / "live-io"
    os.mkdir(observation_root, 0o700)
    launch_receipt = observation_root / "launch.json"
    exit_receipt = observation_root / "exit.json"
    trace = observation_root / "trace.json"
    observation = observation_root / "observation.json"
    process, control = begin_supervision(["python3", "scripts/supervise-process.py", "run", "--launch-receipt", str(launch_receipt), "--exit-receipt", str(exit_receipt), "--command-id", "task2-forbidden-live-io", "--preexec-barrier", "--live-io-observation", str(observation), "--live-io-trace", str(trace), "--", "/bin/sh", "scripts/verify-no-live-io-in-tests.sh", "Tests/Fixtures/ForbiddenLiveIO.swift"], transcript, environment, expected=1)
    fixture_output = root / "existing.json"
    fixture_output.write_text("immutable\n", encoding="utf-8")
    execute(["python3", "scripts/write-merkle.py", "--root", str(root), "--output", str(fixture_output)], transcript, environment, expected=2)
    stale = root / "stale-manual.json"
    stale.write_text('{"schemaVersion":1,"observer":"qa","surface":"cli","invocation":["help"],"observed":["output"],"hardwareUsed":false,"artifacts":["/missing"]}\n', encoding="utf-8")
    execute(["python3", "scripts/validate-manual-qa.py", "--observation", str(stale)], transcript, environment, expected=2)
    forged = root / "forged-launch.json"
    forged.write_text('{"schemaVersion":1,"kind":"process-launch","commandID":"forged","supervisor":{"pid":1,"birthAndCommand":"forged"}}\n', encoding="utf-8")
    execute(["python3", "scripts/supervise-process.py", "await-launch", "--launch-receipt", str(forged), "--command-id", "forged"], transcript, environment, expected=2)
    gate_prerequisite = root / "gate-prerequisite.json"
    gate_prerequisite.write_text('{"schemaVersion":1}\n', encoding="utf-8")
    gate = root / "denied-gate.fifo"
    os.mkfifo(gate, 0o600)
    execute(["python3", "scripts/release-gate.py", "--fifo", str(gate), "--receipt", str(root / "denied-release.json"), "--nonce", str(uuid.uuid4()), "--prerequisite", f"{gate_prerequisite}={'0' * 64}"], transcript, environment, expected=2)
    denied_outside = root.parent / f"denied-{uuid.uuid4()}"
    execute(["/usr/bin/sandbox-exec", "-D", f"ARMAGEDDON_QA_ROOT={root}", "-f", "Tests/Fixtures/network-deny.sb", "/usr/bin/touch", str(denied_outside)], transcript, environment, expected=1)
    if denied_outside.exists():
        raise EvidenceError("sandbox-write-escaped", str(denied_outside))
    execute(["/usr/bin/sandbox-exec", "-D", f"ARMAGEDDON_QA_ROOT={root}", "-f", "Tests/Fixtures/network-deny.sb", "/usr/bin/nc", "-z", "127.0.0.1", "9"], transcript, environment, expected=1)
    task1_validation(root, transcript, environment)
    if any(name.startswith(("ARMAGEDDON_LIVE_", "ARMAGEDDON_OPERATOR_", "HUENIT_LIVE_")) or "DEVICE" in name for name in environment):
        raise EvidenceError("poisoned-environment-leak", "live/operator/device variable survived")
    return [root / "task-1-parent-chain.json", launch_receipt, exit_receipt, trace, observation], process, control


def main() -> int:
    if len(sys.argv) != 4 or sys.argv[1] != "2" or sys.argv[2] not in ("happy", "failure"):
        print("Usage: qa_task_runner.py 2 <happy|failure> ROOT", file=sys.stderr)
        return 2
    mode = sys.argv[2]
    parent = Path(sys.argv[3]).resolve(strict=True)
    child_nonce = str(uuid.uuid4())
    root = parent / mode / child_nonce
    mode_root = parent / mode
    try:
        os.mkdir(mode_root, 0o700)
    except FileExistsError as error:
        if not mode_root.is_dir():
            raise error
    os.mkdir(root, 0o700)
    environment = clean_environment(os.environ, ALLOWLIST)
    for directory in (root / "home", root / "tmp"):
        os.mkdir(directory, 0o700)
    environment["HOME"] = str(root / "home")
    environment["TMPDIR"] = str(root / "tmp")
    environment["ARMAGEDDON_QA_BUILD_ROOT"] = str(root / "build")
    environment["GIT_CEILING_DIRECTORIES"] = str(Path.cwd().parent)
    environment["GIT_CONFIG_COUNT"] = "2"
    environment["GIT_CONFIG_KEY_0"] = "core.fsmonitor"
    environment["GIT_CONFIG_VALUE_0"] = "false"
    environment["GIT_CONFIG_KEY_1"] = "core.untrackedCache"
    environment["GIT_CONFIG_VALUE_1"] = "false"
    transcript_path = root / "camera-ml-app.txt"
    try:
        with transcript_path.open("xb") as transcript:
            artifacts, process, control = happy(root, transcript, environment) if mode == "happy" else failure(root, transcript, environment)
            transcript.flush()
            os.fsync(transcript.fileno())
            env_data = "\0".join(f"{key}={environment[key]}" for key in sorted(environment)).encode()
            observation_path = root / "live-io/observation.json"
            observation = require_mapping(read_json(observation_path), "live I/O observation")
            observation_start = observation.get("observationStartMonotonicNs")
            observation_end = observation.get("observationEndMonotonicNs")
            device_opens = observation.get("deviceOpenCount")
            serial_writes = observation.get("serialWriteCount")
            if not all(isinstance(item, int) and not isinstance(item, bool) for item in (observation_start, observation_end, device_opens, serial_writes)):
                raise EvidenceError("invalid-live-io-observation", str(observation_path))
            value: JsonValue = {"schemaVersion": 1, "kind": "task-execution", "parentRunID": os.environ.get("ARMAGEDDON_PARENT_RUN_ID", "00000000-0000-0000-0000-000000000000"), "childNonce": child_nonce, "task": 2, "mode": mode, "baseCommit": "2fd5b1723f16c7405898e476f167206f72be1e84", "finalCommit": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(), "planSHA256": PLAN_SHA256, "startMonotonicNs": observation_start, "endMonotonicNs": observation_end, "environmentSHA256": sha256_bytes(env_data), "scrubbedLiveVariables": True, "liveSchemesExcluded": True, "deviceOpenCount": device_opens, "serialWriteCount": serial_writes, "liveIOObservation": artifact_record(observation_path), "outcome": "PASS" if mode == "happy" else "EXPECTED_FAILURE", "artifacts": [artifact_record(path) for path in artifacts], "transcriptSHA256": sha256_file(transcript_path)}
            execution_receipt = root / "execution-receipt.json"
            exclusive_json(execution_receipt, value)
            finish_supervision(process, control, execution_receipt, expected=0 if mode == "happy" else 1)
        print(root)
        return 0
    except (EvidenceError, OSError, subprocess.SubprocessError) as error:
        print(f"ERROR[qa-task]: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
