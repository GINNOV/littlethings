#!/bin/sh

set -eu

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    printf '%s\n' 'Usage: run-swift-review.sh RECEIPT TRANSCRIPT PROMPT SKILL -- COMMAND...'
    exit 0
fi

if [ "$#" -lt 5 ]; then
    printf '%s\n' 'Usage: run-swift-review.sh RECEIPT TRANSCRIPT PROMPT SKILL -- COMMAND...' >&2
    exit 2
fi

receipt=$1
transcript=$2
prompt=$3
skill=$4
shift 4
[ "$1" = "--" ] || exit 2
shift
[ "$#" -gt 0 ] || exit 2

set +e
"$@" >"$transcript" 2>&1
status=$?
set -e
[ "$status" -eq 0 ] || exit "$status"

commit=$(git rev-parse HEAD)
project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
PYTHONPATH="$project_root/scripts" python3 - "$receipt" "$transcript" "$prompt" "$skill" "$commit" <<'PY'
import sys
from pathlib import Path
from evidence_common import EvidenceError, exclusive_json, sha256_bytes, sha256_file

try:
    receipt = Path(sys.argv[1])
    transcript = Path(sys.argv[2])
    prompt = Path(sys.argv[3])
    skill = Path(sys.argv[4])
    commit = sys.argv[5]
    resolved_transcript = transcript.resolve(strict=True)
    lines = [line.strip() for line in resolved_transcript.read_text(encoding="utf-8").splitlines() if line.strip()]
    for line in lines:
        if line.upper() in {"SKIP", "SKIPPED", "NOT_APPLICABLE", "NOT APPLICABLE"}:
            raise EvidenceError("forbidden-outcome", line)
    if not lines or lines[-1] != "VERDICT: PASS":
        raise EvidenceError("missing-review-verdict", str(resolved_transcript))
    value = {"schemaVersion": 1, "commitSHA": commit, "reviewer": "external-command", "promptSHA256": sha256_file(prompt.resolve(strict=True)), "skillSHA256": sha256_file(skill.resolve(strict=True)), "transcript": str(resolved_transcript), "transcriptSHA256": sha256_file(resolved_transcript), "verdict": "PASS", "verdictLine": lines[-1], "verdictLineSHA256": sha256_bytes((lines[-1] + "\n").encode())}
    exclusive_json(receipt.absolute(), value)
except (EvidenceError, OSError, UnicodeError) as error:
    code = error.code if isinstance(error, EvidenceError) else "io-error"
    print(f"ERROR[{code}]: {error}", file=sys.stderr)
    raise SystemExit(2) from error
PY
