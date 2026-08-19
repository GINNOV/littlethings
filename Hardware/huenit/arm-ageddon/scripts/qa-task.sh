#!/bin/sh

set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    printf '%s\n' 'Usage: qa-task.sh <1-33> <happy|failure>'
    exit 0
fi
if [ "$#" -ne 2 ]; then
    printf '%s\n' 'Usage: qa-task.sh <1-33> <happy|failure>' >&2
    exit 2
fi
[ "$1" = "2" ] || { printf '%s\n' 'ERROR[unsupported-task]: task manifest has not landed yet' >&2; exit 2; }
case "$2" in happy|failure) ;; *) printf '%s\n' 'ERROR[unknown-mode]' >&2; exit 2 ;; esac

if [ -n "${ARMAGEDDON_TASK_ROOT:-}" ]; then
    task_root=$ARMAGEDDON_TASK_ROOT
else
    attempt=$("$project_root/scripts/current-evidence-dir.sh")
    parent=$(uuidgen | tr '[:upper:]' '[:lower:]')
    nonce=$(uuidgen | tr '[:upper:]' '[:lower:]')
    mkdir -m 700 "$attempt/runs"
    mkdir -m 700 "$attempt/runs/$parent"
    mkdir -m 700 "$attempt/runs/$parent/task-2"
    mkdir -m 700 "$attempt/runs/$parent/task-2/$nonce"
    task_root=$attempt/runs/$parent/task-2/$nonce
fi

cd "$project_root"
exec python3 scripts/qa_task_runner.py "$1" "$2" "$task_root"
