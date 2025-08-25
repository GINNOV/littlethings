#!/bin/bash

# This script automates the entire pipeline:
# 1. Prepares the dataset.
# 2. Fine-tunes the Gemma 3 model.
# 3. Merges the LoRA adapter.
# 4. Generates the model card and converts the model to GGUF format.
#
# USAGE: ./utils/build_full_model.sh [OPTION]

# --- Global Settings ---
set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd -P)

PREPARE_SCRIPT="$PROJECT_ROOT/src/amiga_lm/prepare_dataset.py"
TRAIN_SCRIPT="$PROJECT_ROOT/src/amiga_lm/train_model.py"
GENERATE_CARD_SCRIPT="$PROJECT_ROOT/src/amiga_lm/generate_model_card.py"
MERGE_SCRIPT="$PROJECT_ROOT/src/amiga_lm/merge_model.py"

FINE_TUNED_DIR="$PROJECT_ROOT/amiga_gemma3-270m_finetuned"
MERGED_MODEL_DIR="$PROJECT_ROOT/amiga_gemma3-270m_merged"
LLAMA_CPP_DIR=$(cd "$PROJECT_ROOT/../../../../llama.cpp" && pwd -P)

# --- Usage Function ---
usage() {
    echo "Usage: $0 [OPTION]"
    echo "Automates the model building pipeline."
    echo
    echo "Options:"
    echo "  --all      Performs all steps from 1 to 4."
    echo "  --step1    Performs Step 1: Data Preparation."
    echo "  --step2    Performs Step 2: Fine-tuning the model."
    echo "  --step3    Performs Step 3: Merge LoRA adapter."
    echo "  --step4    Performs Step 4: Generate Model Card & GGUF Conversion."
    echo "  --help     Display this help message."
    exit 1
}

# --- Argument Parsing ---
if [ $# -eq 0 ]; then
    usage
fi

run_step1=false
run_step2=false
run_step3=false
run_step4=false

case "$1" in
    --all)   run_step1=true; run_step2=true; run_step3=true; run_step4=true ;;
    --step1) run_step1=true ;;
    --step2) run_step2=true ;;
    --step3) run_step3=true ;;
    --step4) run_step4=true ;;
    --help)  usage ;;
    *) echo "Error: Invalid argument."; usage ;;
esac

# --- Step 1: Data Preparation ---
if [ "$run_step1" = true ]; then
    echo "--- STEP 1: Preparing the dataset ---"
    if uv run python "$PREPARE_SCRIPT"; then
        echo "✅ Dataset preparation completed successfully."
    else
        echo "❌ Data preparation failed."; exit 1
    fi
fi

# --- Step 2: Fine-tuning the model ---
if [ "$run_step2" = true ]; then
    echo "--- STEP 2: Fine-tuning the model ---"
    if uv run python "$TRAIN_SCRIPT"; then
        echo "✅ Model fine-tuning completed successfully."
    else
        echo "❌ Model fine-tuning failed."; exit 1
    fi
fi

# --- Step 3: Merge LoRA adapter ---
if [ "$run_step3" = true ]; then
    echo "--- STEP 3: Merging LoRA adapter ---"
    if uv run python "$MERGE_SCRIPT"; then
        echo "✅ Model merging completed successfully."
    else
        echo "❌ Model merging failed."; exit 1
    fi
fi

# --- Step 4: Generate Model Card & GGUF Conversion ---
if [ "$run_step4" = true ]; then
    echo "--- STEP 4: Generating Model Card & Converting to GGUF format ---"
    MODEL_CARD_PATH="$FINE_TUNED_DIR/final_checkpoint/model_card.html"
    CONVERT_SCRIPT="$LLAMA_CPP_DIR/convert_hf_to_gguf.py"

    # Always regenerate the model card to avoid stale content
    echo "🧹 Removing any existing model card to prevent stale output…"
    rm -f "$MODEL_CARD_PATH"

    echo "📝 Generating fresh model card…"
    if uv run python "$GENERATE_CARD_SCRIPT"; then
        echo "✅ Model card generated at: $MODEL_CARD_PATH"
    else
        echo "❌ Model card generation failed."; exit 1
    fi

    if [ ! -f "$CONVERT_SCRIPT" ]; then
        echo "❌ Error: Llama.cpp conversion script not found at '$CONVERT_SCRIPT'."; exit 1
    fi

    echo "🔄 Running conversion: uv run python $CONVERT_SCRIPT --outtype f16 $MERGED_MODEL_DIR"
    if uv run python "$CONVERT_SCRIPT" --outtype f16 "$MERGED_MODEL_DIR"; then
        echo "✅ GGUF conversion completed successfully."
        if [ -f "$MERGED_MODEL_DIR/ggml-model-f16.gguf" ]; then
            mv "$MERGED_MODEL_DIR/ggml-model-f16.gguf" "$MERGED_MODEL_DIR/amiga-asm-model-f16.gguf"
            echo "✅ Renamed GGUF file to: amiga-asm-model-f16.gguf"
        fi
        echo "---"
        echo "1️⃣ Final GGUF model: $MERGED_MODEL_DIR/amiga-asm-model-f16.gguf"
        echo "2️⃣ Model card:       $MODEL_CARD_PATH"
        echo "   (Tip: Hard-reload the browser if you had it open: ⌘⇧R / Ctrl+Shift+R)"
    else
        echo "❌ GGUF conversion failed."; exit 1
    fi
fi

echo "--- Script finished. ---"