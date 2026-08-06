#!/usr/bin/env bash
# Download Amiga Playground ASM runtime (Apple Silicon MLX).
# Layout:
#   runtime/base/     Qwen2.5-Coder-3B-Instruct-4bit
#   runtime/adapter/  Amiga ASM LoRA (POR)
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v hf >/dev/null 2>&1; then
  echo "Missing Hugging Face CLI (hf). https://huggingface.co/docs/huggingface_hub/guides/cli"
  exit 1
fi

BASE_REPO="${HF_BASE_MODEL_REPO:-mlx-community/Qwen2.5-Coder-3B-Instruct-4bit}"
ADAPTER_REPO="${HF_ADAPTER_REPO:-bmove/amiga-playground-asm}"
BASE_DIR="runtime/base"
ADAPTER_DIR="runtime/adapter"

echo "Base:    $BASE_REPO -> $BASE_DIR"
mkdir -p "$BASE_DIR"
hf download "$BASE_REPO" --type model --local-dir "$BASE_DIR"

echo "Adapter: $ADAPTER_REPO -> $ADAPTER_DIR"
TMP="$(mktemp -d)"
hf download "$ADAPTER_REPO" --type model --local-dir "$TMP"
mkdir -p "$ADAPTER_DIR"
if [[ -f "$TMP/adapters/adapters.safetensors" ]]; then
  cp "$TMP/adapters/adapters.safetensors" "$ADAPTER_DIR/adapters.safetensors"
  cp "$TMP/adapters/adapter_config.json" "$ADAPTER_DIR/adapter_config.json"
elif [[ -f "$TMP/adapters.safetensors" ]]; then
  cp "$TMP/adapters.safetensors" "$ADAPTER_DIR/adapters.safetensors"
  [[ -f "$TMP/adapter_config.json" ]] && cp "$TMP/adapter_config.json" "$ADAPTER_DIR/adapter_config.json"
else
  echo "Error: adapters.safetensors not found in $ADAPTER_REPO"
  rm -rf "$TMP"
  exit 1
fi
rm -rf "$TMP"

echo ""
echo "Ready:"
echo "  uv run python serve_playground.py"
echo "  # or: ./deploy.sh"
echo "App model id: amiga-playground-asm"
if command -v shasum >/dev/null 2>&1; then
  shasum -a 256 "$ADAPTER_DIR/adapters.safetensors" || true
fi
