#!/bin/bash

# Exit on error
set -e

# Colors for highlighted messages
HIGHLIGHT="\033[1;37;44m" # White text on blue background
RESET="\033[0m"

# Paths
OUTPUT_DIR="$HOME/Downloads/Amiga_Testing/Disks"
ADF_NAME="AmiDwnUnder.adf"
ADF_PATH="$OUTPUT_DIR/$ADF_NAME"
CONFIG_PATH="$OUTPUT_DIR/raindemo_debug.fs-uae"

# Build
echo -e "${HIGHLIGHT}BUILDING...${RESET}"
vasm -Fhunkexe -o AmiDwnUnder.bin AmiDwnUnder.s

# Package
echo -e "${HIGHLIGHT}PACKAGING...${RESET}"
send2adf -o "$ADF_PATH" -N DownUndr AmiDwnUnder.bin S C

# Generate FS-UAE config
echo -e "${HIGHLIGHT}GENERATING FS-UAE CONFIGURATION...${RESET}"
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

# Done message
echo -e "${HIGHLIGHT}ALL DONE. DISK IMAGE AND FS-UAE CONFIG READY:${RESET}"
echo "  $ADF_PATH"
echo "  $CONFIG_PATH"

# Ask if you want to run FS-UAE debugger
read -p "DO YOU WANT TO LAUNCH FS-UAE DEBUGGER NOW? (y/n): " ANSWER
if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
    /Applications/FS-UAE.app/Contents/MacOS/fs-uae "$CONFIG_PATH"
else
    echo "Run: /Applications/FS-UAE.app/Contents/MacOS/fs-uae \"$CONFIG_PATH\""
fi