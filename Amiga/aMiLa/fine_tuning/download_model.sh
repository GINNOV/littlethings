#!/usr/bin/env bash
set -euo pipefail

repo_id="${HF_MODEL_REPO:-bmove/antigravity-amiga-68k}"
target_dir="${1:-fused_model}"

cd "$(dirname "$0")"

if ! command -v hf >/dev/null 2>&1; then
  echo "Missing Hugging Face CLI. Install it from https://huggingface.co/docs/huggingface_hub/guides/cli"
  exit 1
fi

mkdir -p "$target_dir"
hf download "$repo_id" --type model --local-dir "$target_dir"

echo "Downloaded $repo_id into $(pwd)/$target_dir"
