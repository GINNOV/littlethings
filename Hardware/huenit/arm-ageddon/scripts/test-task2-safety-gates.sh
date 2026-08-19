#!/bin/sh

set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
if [ -n "${ARMAGEDDON_SAFETY_TEST_ROOT:-}" ]; then
    root=$ARMAGEDDON_SAFETY_TEST_ROOT
    mkdir -m 700 "$root"
else
    root=$(mktemp -d /private/tmp/armageddon-task2-safety.XXXXXX)
    trap 'rm -rf "$root"' EXIT
fi
mkdir -m 700 "$root/review" "$root/io"
cd "$project_root"

printf 'prompt\n' > "$root/review/prompt.txt"
printf 'skill\n' > "$root/review/skill.md"
if ./scripts/run-swift-review.sh "$root/review/skip.json" "$root/review/skip.txt" "$root/review/prompt.txt" "$root/review/skill.md" -- /usr/bin/printf 'SKIP\n' > "$root/review/skip.stdout" 2> "$root/review/skip.stderr"; then
    printf '%s\n' 'ERROR[test-skip-as-pass]: SKIP-only review succeeded' >&2
    exit 1
fi
grep -q 'ERROR\[forbidden-outcome\]' "$root/review/skip.stderr"
./scripts/run-swift-review.sh "$root/review/pass.json" "$root/review/pass.txt" "$root/review/prompt.txt" "$root/review/skill.md" -- /usr/bin/printf 'review complete\nVERDICT: PASS\n'
python3 scripts/validate-review-receipts.py --commit "$(git rev-parse HEAD)" "$root/review/pass.json" > "$root/review/pass-validation.txt"
PYTHONDONTWRITEBYTECODE=1 python3 - "$root/review/pass.json" "$root/review/skip.txt" "$root/review/forged.json" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

receipt = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
transcript = Path(sys.argv[2])
receipt["transcript"] = str(transcript)
receipt["transcriptSHA256"] = hashlib.sha256(transcript.read_bytes()).hexdigest()
Path(sys.argv[3]).write_text(json.dumps(receipt, sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8")
PY
if python3 scripts/validate-review-receipts.py --commit "$(git rev-parse HEAD)" "$root/review/forged.json" > "$root/review/forged.stdout" 2> "$root/review/forged.stderr"; then
    printf '%s\n' 'ERROR[test-forged-review]: forged SKIP receipt validated' >&2
    exit 1
fi
grep -q 'ERROR\[forbidden-outcome\]' "$root/review/forged.stderr"

PYTHONDONTWRITEBYTECODE=1 python3 - "$root/io" <<'PY'
import hashlib
import json
import socket
import subprocess
import sys
from pathlib import Path

root = Path(sys.argv[1])

def receive(control):
    with control.makefile("rb") as stream:
        line = stream.readline()
    return json.loads(line) if line else None

def run_case(name, expected_error=None, child_command=None, child_exit=0):
    case_root = root / name
    case_root.mkdir()
    control, supervisor = socket.socketpair()
    command = ["python3", "scripts/supervise-process.py", "run", "--launch-receipt", str(case_root / "launch.json"), "--exit-receipt", str(case_root / "exit.json"), "--command-id", name, "--preexec-barrier", "--live-io-observation", str(case_root / "observation.json"), "--live-io-trace", str(case_root / "trace.json"), "--finalize-fd", str(supervisor.fileno()), "--", *(child_command or ["/bin/sleep", "1"])]
    with (case_root / "supervisor.stdout").open("wb") as stdout, (case_root / "supervisor.stderr").open("wb") as stderr:
        process = subprocess.Popen(command, pass_fds=(supervisor.fileno(),), stdout=stdout, stderr=stderr)
        supervisor.close()
        ready = receive(control)
        if ready is None:
            status = process.wait(timeout=10)
            stderr_text = (case_root / "supervisor.stderr").read_text(encoding="utf-8")
            if expected_error is None or status == 0 or f"ERROR[{expected_error}]" not in stderr_text:
                raise SystemExit(f"{name}: unexpected early supervisor failure: {status}, {stderr_text!r}")
            response = {"status": "fail", "error": expected_error}
            control.close()
        else:
            if ready != {"status": "ready", "childExitStatus": child_exit}:
                raise SystemExit(f"{name}: supervisor not ready: {ready}")
            observation_path = case_root / "observation.json"
            observation = json.loads(observation_path.read_text(encoding="utf-8"))
            receipt = {"schemaVersion": 1, "kind": "task-execution", "startMonotonicNs": observation["observationStartMonotonicNs"], "endMonotonicNs": observation["observationEndMonotonicNs"], "deviceOpenCount": observation["deviceOpenCount"], "serialWriteCount": observation["serialWriteCount"], "liveIOObservation": {"path": str(observation_path), "sha256": hashlib.sha256(observation_path.read_bytes()).hexdigest()}}
            if name == "missing":
                receipt.pop("liveIOObservation")
            elif name == "forged":
                receipt["liveIOObservation"]["sha256"] = "0" * 64
            elif name == "mismatched":
                changed = dict(observation)
                changed["process"] = {**changed["process"], "pid": changed["process"]["pid"] + 1}
                changed_path = case_root / "changed-observation.json"
                changed_path.write_text(json.dumps(changed, sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8")
                receipt["liveIOObservation"] = {"path": str(changed_path), "sha256": hashlib.sha256(changed_path.read_bytes()).hexdigest()}
            elif name == "window":
                receipt["startMonotonicNs"] -= 1
            receipt_path = case_root / "execution.json"
            receipt_path.write_text(json.dumps(receipt, sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8")
            control.sendall((json.dumps({"receipt": str(receipt_path)}) + "\n").encode())
            response = receive(control)
            control.close()
            status = process.wait(timeout=10)
    (case_root / "response.json").write_text(json.dumps(response) + "\n", encoding="utf-8")
    (case_root / "exit-status.txt").write_text(f"{status}\n", encoding="utf-8")
    if expected_error is None:
        if response != {"status": "pass"} or status != child_exit:
            raise SystemExit(f"{name}: valid finalization failed: {response}, {status}")
    elif response != {"status": "fail", "error": expected_error} or status == 0:
        raise SystemExit(f"{name}: expected {expected_error}, got {response}, {status}")

run_case("valid")
run_case("missing", "missing-live-io-observation")
run_case("forged", "live-io-hash-mismatch")
run_case("mismatched", "live-io-process-mismatch")
run_case("window", "live-io-window-mismatch")
run_case("short-lived", child_command=["/bin/sh", "-c", "exit 1"], child_exit=1)
run_case("xcode-shim", child_command=["/usr/bin/xcodebuild", "-showsdks"])
shim = json.loads((root / "xcode-shim" / "launch.json").read_text(encoding="utf-8"))
if shim["executable"] != "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild":
    raise SystemExit(f"xcode-shim: unexpected observed executable {shim['executable']}")
PY

if python3 scripts/supervise-process.py run --launch-receipt "$root/io/exec-launch.json" --exit-receipt "$root/io/exec-exit.json" --command-id exec-failed --preexec-barrier -- /private/tmp/armageddon-task2-no-such-command > "$root/io/exec-failed.stdout" 2> "$root/io/exec-failed.stderr"; then
    printf '%s\n' 'ERROR[test-exec-failure]: missing command validated' >&2
    exit 1
fi
grep -q 'ERROR\[exec-failed\]' "$root/io/exec-failed.stderr"

PYTHONDONTWRITEBYTECODE=1 python3 - "$root/io/synthetic" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
root.mkdir()

def write(name, value):
    path = root / name
    path.write_text(json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8")
    return path

def reference(path):
    return {"path": str(path), "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}

process = {"pid": 999999, "birthAndCommand": "synthetic child"}
digest = hashlib.sha256(Path("/bin/sh").read_bytes()).hexdigest()
launch = write("launch.json", {"schemaVersion": 1, "kind": "process-launch", "commandID": "synthetic", "child": process, "executable": "/bin/sh", "executableSHA256": digest})
trace = write("trace.json", {"schemaVersion": 1, "kind": "live-io-trace", "process": process, "executableSHA256": digest, "observationStartMonotonicNs": 10, "observationEndMonotonicNs": 20, "sampleCount": 1, "events": []})
exit_receipt = write("exit.json", {"schemaVersion": 1, "kind": "process-exit", "launchReceipt": reference(launch)})
observation = write("observation.json", {"schemaVersion": 1, "kind": "live-io-observation", "process": process, "executable": "/bin/sh", "executableSHA256": digest, "observationStartMonotonicNs": 10, "observationEndMonotonicNs": 20, "sourceReceipts": [reference(launch), reference(exit_receipt)], "trace": reference(trace), "deviceOpenCount": 0, "serialWriteCount": 0})
write("execution.json", {"schemaVersion": 1, "kind": "task-execution", "startMonotonicNs": 10, "endMonotonicNs": 20, "deviceOpenCount": 0, "serialWriteCount": 0, "liveIOObservation": reference(observation)})
PY
if python3 scripts/validate-execution-receipts.py "$root/io/synthetic/execution.json" > "$root/io/synthetic.stdout" 2> "$root/io/synthetic.stderr"; then
    printf '%s\n' 'ERROR[test-synthetic-origin]: self-consistent unproven receipt validated' >&2
    exit 1
fi
grep -q 'ERROR\[missing-producer-origin-proof\]' "$root/io/synthetic.stderr"

if python3 scripts/supervise-process.py run --launch-receipt "$root/io/window-launch.json" --exit-receipt "$root/io/window-exit.json" --command-id identity-window --preexec-barrier --live-io-observation "$root/io/window-observation.json" --live-io-trace "$root/io/window-trace.json" -- /bin/bash -c 'sleep 0.30; exec /bin/sleep 0.30' > "$root/io/window-supervisor.stdout" 2> "$root/io/window-supervisor.stderr"; then
    printf '%s\n' 'ERROR[test-identity-window]: executable change during observation validated' >&2
    exit 1
fi
grep -q 'ERROR\[live-io-process-mismatch\]' "$root/io/window-supervisor.stderr"
if rg -n 'ARMAGEDDON_PRODUCER_ORIGIN|producer-origin-fd|secret\.hex' scripts/supervise-process.py scripts/qa_task_runner.py scripts/validate-execution-receipts.py > "$root/io/leaked-proof.txt"; then
    printf '%s\n' 'ERROR[test-origin-leak]: caller-readable proof channel remains' >&2
    exit 1
fi

printf 'PASS: Task 2 review and live-I/O receipt safety gates\n'
