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

python3 scripts/supervise-process.py run --launch-receipt "$root/io/launch.json" --exit-receipt "$root/io/exit.json" --command-id safety-test --preexec-barrier --live-io-observation "$root/io/observation.json" --live-io-trace "$root/io/trace.json" -- /usr/bin/python3 -c 'import time; time.sleep(0.05)'
PYTHONDONTWRITEBYTECODE=1 python3 - "$root/io/observation.json" "$root/io/execution.json" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

observation_path = Path(sys.argv[1])
observation = json.loads(observation_path.read_text(encoding="utf-8"))
receipt = {
    "schemaVersion": 1,
    "kind": "task-execution",
    "startMonotonicNs": observation["observationStartMonotonicNs"],
    "endMonotonicNs": observation["observationEndMonotonicNs"],
    "deviceOpenCount": observation["deviceOpenCount"],
    "serialWriteCount": observation["serialWriteCount"],
    "liveIOObservation": {"path": str(observation_path), "sha256": hashlib.sha256(observation_path.read_bytes()).hexdigest()},
}
Path(sys.argv[2]).write_text(json.dumps(receipt, sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8")
PY
python3 scripts/validate-execution-receipts.py "$root/io/execution.json" > "$root/io/pass-validation.txt"
PYTHONDONTWRITEBYTECODE=1 python3 - "$root/io/execution.json" "$root/io/observation.json" "$root/io" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

receipt = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
observation = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
root = Path(sys.argv[3])

missing = dict(receipt)
missing.pop("liveIOObservation")
(root / "missing.json").write_text(json.dumps(missing) + "\n", encoding="utf-8")

mismatch_observation = dict(observation)
mismatch_process = dict(mismatch_observation["process"])
mismatch_process["pid"] += 1
mismatch_observation["process"] = mismatch_process
mismatch_path = root / "mismatched-observation.json"
mismatch_path.write_text(json.dumps(mismatch_observation, sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8")
mismatch = dict(receipt)
mismatch["liveIOObservation"] = {"path": str(mismatch_path), "sha256": hashlib.sha256(mismatch_path.read_bytes()).hexdigest()}
(root / "mismatched.json").write_text(json.dumps(mismatch) + "\n", encoding="utf-8")

forged = dict(receipt)
forged["liveIOObservation"] = {"path": receipt["liveIOObservation"]["path"], "sha256": "0" * 64}
(root / "forged.json").write_text(json.dumps(forged) + "\n", encoding="utf-8")

window = dict(receipt)
window["startMonotonicNs"] -= 1
(root / "window.json").write_text(json.dumps(window) + "\n", encoding="utf-8")
PY
for case in missing forged mismatched window; do
    if python3 scripts/validate-execution-receipts.py "$root/io/$case.json" > "$root/io/$case.stdout" 2> "$root/io/$case.stderr"; then
        printf 'ERROR[test-%s-observation]: invalid receipt validated\n' "$case" >&2
        exit 1
    fi
done
grep -q 'ERROR\[missing-live-io-observation\]' "$root/io/missing.stderr"
grep -q 'ERROR\[live-io-hash-mismatch\]' "$root/io/forged.stderr"
grep -q 'ERROR\[live-io-process-mismatch\]' "$root/io/mismatched.stderr"
grep -q 'ERROR\[live-io-window-mismatch\]' "$root/io/window.stderr"

printf 'PASS: Task 2 review and live-I/O receipt safety gates\n'
