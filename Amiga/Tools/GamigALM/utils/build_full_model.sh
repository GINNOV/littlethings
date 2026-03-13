#!/bin/bash

# This script automates the entire pipeline from data prep to a final,
# ready-to-use GGUF model and Ollama Modelfile.
#
# USAGE: ./utils/build_full_model.sh [OPTION]

# --- Global Settings ---
set -e # Exit immediately if a command exits with a non-zero status

# Determine Project Root from the script's location in a subdirectory
SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd -P)

# Define paths to scripts relative to the project root
PREPARE_SCRIPT="$PROJECT_ROOT/src/amiga_lm/prepare_dataset.py"
TRAIN_SCRIPT="$PROJECT_ROOT/src/amiga_lm/train_model.py"
GENERATE_CARD_SCRIPT="$PROJECT_ROOT/src/amiga_lm/generate_model_card.py"
MERGE_SCRIPT="$PROJECT_ROOT/src/amiga_lm/merge_model.py"

# Define paths to directories
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
    echo "  --step4    Performs Step 4: Generate Final Artifacts."
    echo "  --help     Display this help message."
    exit 1
}

# --- Argument Parsing ---
if [ $# -eq 0 ]; then
    usage
fi

run_step1=false; run_step2=false; run_step3=false; run_step4=false

case "$1" in
    --all) run_step1=true; run_step2=true; run_step3=true; run_step4=true ;;
    --step1) run_step1=true ;;
    --step2) run_step2=true ;;
    --step3) run_step3=true ;;
    --step4) run_step4=true ;;
    --help) usage ;;
    *) echo "Error: Invalid argument."; usage ;;
esac

# --- Pipeline Steps ---

if [ "$run_step1" = true ]; then
    echo "--- STEP 1: Preparing the dataset ---"
    if uv run python "$PREPARE_SCRIPT"; then
        echo "✅ Dataset preparation completed successfully."
    else
        echo "❌ Data preparation failed."; exit 1
    fi
fi

if [ "$run_step2" = true ]; then
    echo "--- STEP 2: Fine-tuning the model ---"
    if uv run python "$TRAIN_SCRIPT"; then
        echo "✅ Model fine-tuning completed successfully."
    else
        echo "❌ Model fine-tuning failed."; exit 1
    fi
fi

if [ "$run_step3" = true ]; then
    echo "--- STEP 3: Merging LoRA adapter ---"
    if uv run python "$MERGE_SCRIPT"; then
        echo "✅ Model merging completed successfully."
    else
        echo "❌ Model merging failed."; exit 1
    fi
fi

if [ "$run_step4" = true ]; then
    echo "--- STEP 4: Generating Final Artifacts ---"
    MODEL_CARD_PATH="$FINE_TUNED_DIR/final_checkpoint/model_card.html"
    CONVERT_SCRIPT="$LLAMA_CPP_DIR/convert_hf_to_gguf.py"
    GGUF_FILE_NAME="amiga-asm-model-f16.gguf"
    GGUF_FILE_PATH="$MERGED_MODEL_DIR/$GGUF_FILE_NAME"
    MODELFILE_PATH="$MERGED_MODEL_DIR/Modelfile"

    echo "Generating model card..."
    if uv run python "$GENERATE_CARD_SCRIPT"; then
        echo "✅ Model card generated successfully."
    else
        echo "❌ Model card generation failed."; exit 1
    fi

    if [ ! -f "$CONVERT_SCRIPT" ]; then
        echo "❌ Error: Llama.cpp conversion script not found at '$CONVERT_SCRIPT'."; exit 1
    fi

    echo "Running GGUF conversion..."
    # CORRECTED: Use --outfile to specify the exact output filename
    if uv run python "$CONVERT_SCRIPT" --outfile "$GGUF_FILE_PATH" --outtype f16 "$MERGED_MODEL_DIR"; then
        echo "✅ GGUF conversion completed successfully."
    else
        echo "❌ GGUF conversion failed."; exit 1
    fi

    echo "Generating Ollama Modelfile..."
    # This uses a 'heredoc' to write the multi-line content to the Modelfile
    cat > "$MODELFILE_PATH" << EOL
# Defines how to run the fine-tuned Amiga assembly model with Ollama
FROM ./$GGUF_FILE_NAME

# Set the prompt template to match the training data
TEMPLATE """{{ .Prompt }}"""

# Set a system prompt to guide the model's behavior
SYSTEM """You are an expert Amiga assembly programmer. Your task is to generate functional 68k assembly code based on the user's request."""

# Set default generation parameters
PARAMETER temperature 0.7
PARAMETER top_p 0.9
EOL
    echo "✅ Ollama Modelfile created successfully."

    echo "---"
    echo "1️⃣ Final GGUF model: $GGUF_FILE_PATH"
    echo "2️⃣ Model card: $MODEL_CARD_PATH"
    echo "3️⃣ Ollama Modelfile: $MODELFILE_PATH"
    echo
    echo "To use with Ollama, navigate to '$MERGED_MODEL_DIR' and run:"
    echo "ollama create amiga_asm_model -f ./Modelfile"
    echo "after that you can open Ollama and select the model."
fi

echo "--- Script finished. ---"