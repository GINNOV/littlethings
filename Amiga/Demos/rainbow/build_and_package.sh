#!/bin/bash

# Exit on error
set -e

# Paths
OUTPUT_DIR="$HOME/Downloads/Amiga_Testing/Disks"
ADF_NAME="raindemo.adf"
ADF_PATH="$OUTPUT_DIR/$ADF_NAME"
CONFIG_PATH="$OUTPUT_DIR/raindemo_debug.fs-uae"

# Build
echo "Building..."
vasm -Fhunkexe -o rainbow_bar.exe rainbow_bar.asm

# Package
echo "Packaging..."
send2adf -o "$ADF_PATH" -N rainDEMO rainbow_bar.exe S C

# Generate FS-UAE config
echo "Generating FS-UAE configuration..."
cat > "$CONFIG_PATH" <<EOF
# FS-UAE configuration saved by FS-UAE Launcher
# Last saved: $(date "+%Y-%m-%d %H:%M:%S")

[fs-uae]
chip_memory = 512
console_debugger = 1
floppy_drive_0 = $ADF_PATH
joystick_port_3 = none
kickstart_file = /Users/mario/Documents/FS-UAE/Kickstarts/Kickstart ROM Set/Kickstart 1.3.rom
EOF

echo "All done. Disk image and FS-UAE config ready:"
echo "  $ADF_PATH"
echo "  $CONFIG_PATH"
echo "Run: /Applications/FS-UAE.app/Contents/MacOS/fs-uae \"$CONFIG_PATH\""