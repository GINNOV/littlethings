#!/bin/bash
set -e

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is required. Install it with: brew install uv"
  exit 1
fi

echo "=========================================================="
echo "Starting Multi-Adapter Amiga C & 68k Assembly Fine-Tuning"
echo "=========================================================="

# Clean up previous training checkpoints to prevent weight pollution
rm -rf adapters_asm/ adapters_c/

echo ""
echo "--- Training 68k Assembly Adapter (1,500 steps, high-capacity) ---"
uv run python -m mlx_lm.lora --config config_asm.yaml

echo ""
echo "--- Training Amiga C Adapter (1,500 steps, high-capacity) ---"
uv run python -m mlx_lm.lora --config config_c.yaml

echo ""
echo "=========================================================="
echo "All training sessions completed successfully!"
echo "Adapters saved in:"
echo "- Assembly: adapters_asm/"
echo "- C: adapters_c/"
echo "=========================================================="
