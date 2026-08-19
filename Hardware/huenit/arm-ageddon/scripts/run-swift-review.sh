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
from evidence_common import exclusive_json, sha256_file

receipt = Path(sys.argv[1])
transcript = Path(sys.argv[2])
prompt = Path(sys.argv[3])
skill = Path(sys.argv[4])
commit = sys.argv[5]
value = {"schemaVersion": 1, "commitSHA": commit, "reviewer": "external-command", "promptSHA256": sha256_file(prompt.resolve(strict=True)), "skillSHA256": sha256_file(skill.resolve(strict=True)), "transcript": str(transcript.resolve(strict=True)), "transcriptSHA256": sha256_file(transcript.resolve(strict=True)), "verdict": "PASS"}
exclusive_json(receipt.absolute(), value)
PY
