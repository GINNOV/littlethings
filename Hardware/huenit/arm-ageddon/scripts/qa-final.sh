#!/bin/sh

set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    printf '%s\n' 'Usage: qa-final.sh <compliance|quality> OPTIONS' '       qa-final.sh <manual-fixture|scope> <begin|finalize> OPTIONS'
    exit 0
fi
[ "$#" -ge 1 ] || { printf '%s\n' 'ERROR[usage]: gate is required' >&2; exit 2; }

PYTHONPATH="$project_root/scripts${PYTHONPATH:+:$PYTHONPATH}" \
    exec python3 "$project_root/scripts/final_gate.py" "$@"
