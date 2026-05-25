#!/bin/bash
set -e

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is required. Install it with: brew install uv"
  exit 1
fi

# Define directories and model names
BASE_MODEL="mlx-community/gemma-4-e4b-it-4bit"
ADAPTER_PATH="adapters/"
FUSED_MODEL_PATH="fused_model/"
GGUF_OUTPUT_PATH="antigravity-amiga-68k.gguf"
DATA_DIR="data/"

echo "=========================================================="
echo "Starting MLX Amiga 68k Assembly Fine-Tuning"
echo "Base Model: $BASE_MODEL"
echo "=========================================================="

# Clean up previous training checkpoints to prevent weight pollution
rm -rf "$ADAPTER_PATH" "$FUSED_MODEL_PATH"

# Run the LoRA training
# We use 1500 iterations for a focused convergence pass on the model
# We set learning rate to a safe 2e-5 to prevent weight collapse
uv run python -m mlx_lm.lora \
  --model "$BASE_MODEL" \
  --train \
  --data "$DATA_DIR" \
  --iters 1500 \
  --batch-size 2 \
  --learning-rate 2e-5 \
  --adapter-path "$ADAPTER_PATH" \
  --save-every 100 \
  --steps-per-report 10 \
  --max-seq-length 1024 \
  --grad-checkpoint

echo ""
echo "=========================================================="
echo "Training Complete! Fusing adapters into an MLX checkpoint..."
echo "=========================================================="

# Fuse adapters and save to fused_model
# Note: quantized models and gemma4 are not supported by mlx_lm's primitive GGUF converter.
# For LM Studio GGUF, convert the unquantized fused weights using llama.cpp.
uv run python -m mlx_lm.fuse \
  --model "$BASE_MODEL" \
  --adapter-path "$ADAPTER_PATH" \
  --save-path "$FUSED_MODEL_PATH"

echo "=========================================================="
echo "Process Finished Successfully!"
echo "Fused Model saved at: $FUSED_MODEL_PATH"
echo "GGUF conversion is not performed by this script. Optional path: $GGUF_OUTPUT_PATH"
echo "=========================================================="
