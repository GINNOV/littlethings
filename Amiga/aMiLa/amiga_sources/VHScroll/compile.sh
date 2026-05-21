#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
ASM="vasmm68k_mot"
LINK="vlink"
OUTPUT_NAME="my_demo"
SOURCES="demo.asm data.asm ptplayer.asm"
OBJECTS="demo.o data.o ptplayer.o"

# --- Flags ---
# Add NDK macros path to the include paths
INCLUDE_PATHS="-I/opt/vbcc/sdk/NDK_3.9/include/include_i -I/opt/vbcc/sdk/NDK_3.9/include/macros"

# --- THIS IS THE FIX ---
# Added -m68000 to target the Amiga 500's CPU.
# Added -quiet to suppress unnecessary messages from vasm.
AFLAGS_COMMON="-m68000 -Fhunk -quiet $INCLUDE_PATHS"

# vlink flags for standard Amiga hunk executable
LFLAGS="-bamigahunk -Cchip"

# Debug build switch
if [ "$1" = "debug" ]; then
    echo "--- Performing DEBUG build ---"
    AFLAGS_COMMON="$AFLAGS_COMMON -g" # Add debug symbols
else
    echo "--- Performing RELEASE build ---"
fi

# --- Build Process ---
echo "Assembling sources..."
$ASM $AFLAGS_COMMON -o demo.o demo.asm
$ASM $AFLAGS_COMMON -o data.o data.asm
$ASM $AFLAGS_COMMON -o ptplayer.o ptplayer.asm

echo "Linking object files..."
# The -Cchip flag tells vlink to merge everything into a single hunk
# that will be loaded into Chip RAM. This is the simplest and safest
# option for executables that don't use a custom linker script.
$LINK $LFLAGS -o $OUTPUT_NAME $OBJECTS

echo "Cleaning up..."
rm $OBJECTS

echo "\nBuild successful! Executable created: $OUTPUT_NAME"
