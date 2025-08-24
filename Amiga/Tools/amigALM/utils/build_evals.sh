#!/bin/bash

# This script compiles all .s assembly files in the model_answers directory
# using the vasm 68k assembler. It's designed to be run from any location.

# --- Determine Project Root ---
# Get the directory where the script is located
SCRIPT_DIR=$(dirname "$0")
# Set the project root as the parent directory of the script's location
PROJECT_ROOT="$SCRIPT_DIR/.."

# --- Configuration ---
# All paths are now relative to the project root
SOURCE_DIR="$PROJECT_ROOT/model_answers"
BUILD_DIR="$PROJECT_ROOT/model_answers/build"
ASSEMBLER="vasm68k_mot"

# --- Pre-flight Check ---
if ! command -v $ASSEMBLER &> /dev/null
then
    echo "❌ Error: vasm assembler ('$ASSEMBLER') not found."
    echo "Please install vasm and ensure it's in your system's PATH."
    exit 1
fi

# --- Main Script ---
echo "🚀 Starting build process..."
mkdir -p "$BUILD_DIR"
echo "Build directory '$BUILD_DIR' is ready."

shopt -s nullglob
files=("$SOURCE_DIR"/*.s)

if [ ${#files[@]} -eq 0 ]; then
    echo "🟡 Warning: No .s files found in '$SOURCE_DIR'."
    exit 0
fi

echo "Found ${#files[@]} assembly files to compile."
echo "----------------------------------------"

success_count=0
fail_count=0

for file in "${files[@]}"; do
    base_name=$(basename "$file" .s)
    output_file="$BUILD_DIR/$base_name.o"

    echo -n "Compiling '$file'... "

    if "$ASSEMBLER" -Fhunk -o "$output_file" "$file"; then
        echo "✅ Success"
        ((success_count++))
    else
        echo "❌ Fail"
        ((fail_count++))
    fi
done

echo "----------------------------------------"
echo "Build process finished."
echo "✅ Successful builds: $success_count"
echo "❌ Failed builds: $fail_count"

if [ $fail_count -gt 0 ]; then
    echo "Some files failed to compile."
    exit 1
else
    echo "All files compiled successfully!"
    exit 0
fi