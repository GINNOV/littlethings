#!/bin/bash
set -e

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is required. Install it with: brew install uv"
  exit 1
fi

# Define directories and model names
BASE_MODEL="mlx-community/Huihui-gemma-3-270m-it-abliterated-6bit"
ADAPTER_PATH="adapters/"
FUSED_MODEL_PATH="fused_model/"
GGUF_OUTPUT_PATH="antigravity-amiga-68k.gguf"
DATA_DIR="data/"

echo "=========================================================="
echo "Starting MLX Amiga 68k Assembly Fine-Tuning"
echo "Base Model: $BASE_MODEL"
echo "=========================================================="

# Run the LoRA training
# We use 400 iterations for a highly targeted fast convergence on the tiny model
# We set learning rate to 2e-5, optimizer as adamw
uv run python -m mlx_lm.lora \
  --model "$BASE_MODEL" \
  --train \
  --data "$DATA_DIR" \
  --iters 400 \
  --batch-size 4 \
  --learning-rate 2e-5 \
  --adapter-path "$ADAPTER_PATH" \
  --save-every 100 \
  --steps-per-report 20

echo ""
echo "=========================================================="
echo "Training Complete! Fusing adapters and exporting to GGUF..."
echo "=========================================================="

# Fuse adapters and export directly to GGUF format for Ollama/LM Studio
uv run python -m mlx_lm.fuse \
  --model "$BASE_MODEL" \
  --adapter-path "$ADAPTER_PATH" \
  --save-path "$FUSED_MODEL_PATH" \
  --export-gguf \
  --gguf-path "$GGUF_OUTPUT_PATH"

echo "=========================================================="
echo "Process Finished Successfully!"
echo "Fused Model saved at: $FUSED_MODEL_PATH"
echo "GGUF Model saved at: $GGUF_OUTPUT_PATH"
echo "=========================================================="
