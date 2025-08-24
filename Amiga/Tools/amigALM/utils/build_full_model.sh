#!/bin/bash

# This script automates the entire pipeline:
# 1. Prepares the dataset from configured sources.
# 2. Fine-tunes the Gemma 3 model.
# 3. Merges the LoRA adapter.
# 4. Converts the final model to the GGUF format for use with Ollama, LM Studio, etc.
#
# USAGE: ./utils/build_full_model.sh

# --- Global Settings ---
set -e # Exit immediately if a command exits with a non-zero status

# CORRECTED: Determine Project Root from the script's location in a subdirectory
SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd -P)

# Define paths to scripts relative to the project root
PREPARE_SCRIPT="$PROJECT_ROOT/src/amiga_lm/prepare_dataset.py"
TRAIN_SCRIPT="$PROJECT_ROOT/src/amiga_lm/train_model.py"
MERGE_SCRIPT="$PROJECT_ROOT/src/amiga_lm/merge_model.py"

# Define paths to directories relative to the project root
MERGED_MODEL_DIR="$PROJECT_ROOT/amiga_gemma3-270m_merged"
LLAMA_CPP_DIR="$PROJECT_ROOT/../llama.cpp" # Assumes llama.cpp is in the parent directory

# --- Step 1: Data Preparation ---
echo "--- STEP 1: Preparing the dataset ---"
echo "Running script: $PREPARE_SCRIPT"
if uv run python "$PREPARE_SCRIPT"; then
    echo "✅ Dataset preparation completed successfully."
else
    echo "❌ Data preparation failed. See error logs above."
    exit 1
fi

# --- Step 2: Fine-tuning the model ---
echo "--- STEP 2: Fine-tuning the model ---"
echo "Running script: $TRAIN_SCRIPT"
if uv run python "$TRAIN_SCRIPT"; then
    echo "✅ Model fine-tuning completed successfully."
else
    echo "❌ Model fine-tuning failed. See error logs above."
    exit 1
fi

# --- Step 3: Merge LoRA adapter ---
echo "--- STEP 3: Merging LoRA adapter into the base model ---"
echo "Running script: $MERGE_SCRIPT"
if uv run python "$MERGE_SCRIPT"; then
    echo "✅ Model merging completed successfully."
else
    echo "❌ Model merging failed. See error logs above."
    exit 1
fi

# --- Step 4: GGUF Conversion ---
echo "--- STEP 4: Converting merged model to GGUF format ---"
CONVERT_SCRIPT="$LLAMA_CPP_DIR/convert-hf-to-gguf.py"

# Check if the llama.cpp conversion script exists
if [ ! -f "$CONVERT_SCRIPT" ]; then
    echo "❌ Error: Llama.cpp conversion script not found at '$CONVERT_SCRIPT'."
    echo "Please ensure the llama.cpp repository is cloned and built correctly in the parent directory."
    exit 1
fi

echo "Running conversion script: $CONVERT_SCRIPT"
if uv run python "$CONVERT_SCRIPT" --outtype f16 "$MERGED_MODEL_DIR"; then
    echo "✅ GGUF conversion completed successfully."
    echo "The final model is located at: $MERGED_MODEL_DIR/ggml-model-f16.gguf"
else
    echo "❌ GGUF conversion failed. See error logs above."
    exit 1
fi

echo "--- All steps completed. The GGUF model is ready! ---"