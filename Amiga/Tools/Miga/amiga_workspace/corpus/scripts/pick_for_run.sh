#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT_DIR"

MANIFEST="amiga_workspace/corpus/manifest.tsv"
RUNNABLE_MANIFEST="amiga_workspace/corpus/manifest_runnable.tsv"

if [[ ! -f "$MANIFEST" ]]; then
  python3 amiga_workspace/corpus/scripts/index_raw_sources.py
fi

if [[ ! -f "$RUNNABLE_MANIFEST" || "$MANIFEST" -nt "$RUNNABLE_MANIFEST" ]]; then
  python3 amiga_workspace/corpus/scripts/build_runnable_manifest.py \
    --manifest "$MANIFEST" \
    --output "$RUNNABLE_MANIFEST"
fi

if [[ $(grep -cve '^\s*$' "$RUNNABLE_MANIFEST") -le 1 ]]; then
  echo "no runnable rows in $RUNNABLE_MANIFEST (build verify-clean sources first)" >&2
  exit 1
fi

python3 amiga_workspace/corpus/scripts/select_source.py --manifest "$RUNNABLE_MANIFEST" "$@"
