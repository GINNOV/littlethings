#!/bin/bash

# Exit on error
set -e

# Colors for highlighted messages
HIGHLIGHT="\033[1;37;44m" # White text on blue background
RESET="\033[0m"

# Show help function
show_help() {
    echo "Usage: $0 <asm-file>"
    echo
    echo "Builds the specified .asm file with vasm, packages it into an ADF,"
    echo "and generates a debug FS-UAE configuration file."
    echo
    echo "Example:"
    echo "  $0 rainbow_bar.asm"
}

# Check parameter count
if [ $# -lt 1 ]; then
    echo "Error: No .asm file provided."
    show_help
    exit 1
fi

# Handle help flags
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

ASM_FILE="$1"
BASENAME=$(basename "$ASM_FILE" .asm)

# Paths
OUTPUT_DIR="$HOME/Downloads/Amiga_Testing/Disks/bins/Demos"
ADF_NAME="${BASENAME}.adf"
ADF_PATH="$OUTPUT_DIR/$ADF_NAME"
CONFIG_PATH="$OUTPUT_DIR/${BASENAME}_debug.fs-uae"

# Build
echo -e "${HIGHLIGHT}BUILDING...${RESET}"
vasm -Fhunkexe -o ~/Downloads/Amiga_Testing/Disks/bins/unzipped-disk1/"${BASENAME}.bin" "$ASM_FILE"

# Package
echo -e "${HIGHLIGHT}PACKAGING...${RESET}"
send2adf -o ~/Downloads/Amiga_Testing/Disks/bins/Demos/${ADF_NAME} -N "${BASENAME}" ~/Downloads/Amiga_Testing/Disks/bins/unzipped-disk1/C ~/Downloads/Amiga_Testing/Disks/bins/unzipped-disk1/S ~/Downloads/Amiga_Testing/Disks/bins/unzipped-disk1/"${BASENAME}.bin"

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
kickstart_file = ~/Documents/FS-UAE/Kickstarts/Kickstart ROM Set/Kickstart 1.3.rom
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