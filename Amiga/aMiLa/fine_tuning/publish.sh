#!/usr/bin/env bash
set -euo pipefail

repo_id="${HF_MODEL_REPO:-bmove/antigravity-amiga-68k}"

cd "$(dirname "$0")"

if ! command -v hf >/dev/null 2>&1; then
  echo "Error: Missing Hugging Face CLI ('hf'). Install it from https://huggingface.co/docs/huggingface_hub/guides/cli"
  exit 1
fi

echo "=========================================================="
echo "Publishing Amiga Gemma-4 Specialized Adapters to HF Hub"
echo "Repository: $repo_id"
echo "=========================================================="

# Check credentials
if ! hf auth whoami >/dev/null 2>&1; then
  echo "Error: Not authenticated with Hugging Face. Please run 'hf auth login' first."
  exit 1
fi

# Upload Assembly Adapter
if [ -d "adapters_asm" ]; then
  echo "--- Uploading 68k Assembly Adapter (adapters_asm/) ---"
  hf upload "$repo_id" adapters_asm adapters_asm --type model
else
  echo "Warning: adapters_asm/ directory not found. Skipping."
fi

# Upload C Adapter
if [ -d "adapters_c" ]; then
  echo "--- Uploading Amiga C Adapter (adapters_c/) ---"
  hf upload "$repo_id" adapters_c adapters_c --type model
else
  echo "Warning: adapters_c/ directory not found. Skipping."
fi

# Optionally upload Fused Model if it exists
if [ -d "fused_model" ]; then
  echo "--- Uploading Fused Model (fused_model/) ---"
  hf upload "$repo_id" fused_model fused_model --type model
fi

# Upload README.md (Hugging Face Model Card)
if [ -f "README.md" ]; then
  echo "--- Uploading Model Card (README.md) ---"
  hf upload "$repo_id" README.md --type model
fi


echo "=========================================================="
echo "Publishing complete!"
echo "Check your repository at https://huggingface.co/$repo_id"
echo "=========================================================="
