#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <disk_image> <fsuae_home>" >&2
  exit 1
fi

DISK_IMAGE="$1"
FSUAE_HOME="$2"
BASE_DIR="$FSUAE_HOME/Documents/FS-UAE"
CONFIG_DIR="$BASE_DIR/Configurations"
FLOPPY_DIR="$BASE_DIR/Floppies"
LOG_DIR="$BASE_DIR/Cache/Logs"

mkdir -p "$CONFIG_DIR" "$FLOPPY_DIR" "$LOG_DIR" "$BASE_DIR/Kickstarts" "$BASE_DIR/System"
cp "$DISK_IMAGE" "$FLOPPY_DIR/main.adf"

cat > "$CONFIG_DIR/Default.fs-uae" <<'EOF'
[fs-uae]
amiga_model = A500
chip_memory = 2048
fast_memory = 0
floppy_drive_0 = main.adf
fullscreen = 0
video_sync = 0
audio_enabled = 0
EOF
