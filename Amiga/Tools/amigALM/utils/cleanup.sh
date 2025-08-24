#!/bin/bash

# This script removes all generated files and directories from the project,
# leaving a clean state for a retrain from scratch.
#
# USAGE: ./utils/cleanup.sh

# --- Determine Project Root ---
# Get the directory where the script is located
SCRIPT_DIR=$(dirname "$0")
# Set the project root as the parent directory of the script's location
PROJECT_ROOT=$(cd "$SCRIPT_DIR" && pwd -P)/..

# --- Safety Check ---
# Check if a known project file exists in the project root
if [ ! -f "$PROJECT_ROOT/pyproject.toml" ]; then
    echo "❌ Error: This does not appear to be the project root."
    echo "Aborting to prevent accidental data loss."
    exit 1
fi

# --- Main Script ---
echo "🚀 Starting project cleanup from: $PROJECT_ROOT"
echo "This will permanently delete all generated files and directories."
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Cleanup aborted."
    exit 0
fi

# --- Remove generated directories ---
declare -a dirs_to_remove=(
    ".venv"
    "amiga_asm_dataset"
    "amiga_gemma3-270m_finetuned"
    "amiga_gemma3-270m_merged"
    "model_answers"
    "source_code"
)

for dir in "${dirs_to_remove[@]}"; do
    full_path="$PROJECT_ROOT/$dir"
    if [ -d "$full_path" ]; then
        echo "Removing directory: $full_path"
        rm -rf "$full_path"
    fi
done

# --- Remove other generated files ---
echo "Removing log files and caches..."
find "$PROJECT_ROOT" -type f -name "*.pyc" -delete
find "$PROJECT_ROOT" -type d -name "__pycache__" -delete

echo "✅ Cleanup complete. The project is ready for a fresh start."
echo "You will need to run 'uv pip install -e .' to set up a new environment."