#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT="$ROOT/AmigaROMExplorer/Resources"
MANIFEST="${MANIFEST_PATH:-/Users/megov/code/GitHub/littlethings/Amiga/commodore-amiga-firmware/manifest.tsv}"
APP="$ROOT/build/Build/Products/Debug/AmigaROMExplorer.app/Contents/MacOS/AmigaROMExplorer"

mkdir -p "$OUTPUT"

xcodebuild -project "$ROOT/AmigaROMExplorer.xcodeproj" -scheme AmigaROMExplorer -configuration Debug -derivedDataPath "$ROOT/build" build -quiet

MANIFEST_PATH="$MANIFEST" "$APP" --export-bundled-cache "$OUTPUT"

FIRMWARE_ROOT="$(cd "$(dirname "$MANIFEST")" && pwd)"
CHECKSUMS="$OUTPUT/checksums.tsv"
{
  printf 'destination\tmd5\n'
  find "$FIRMWARE_ROOT" -type f \( -iname '*.rom' -o -iname '*.bin' \) ! -name '.*' | sort | while read -r file; do
    rel="${file#$FIRMWARE_ROOT/}"
    md5=$(md5 -q "$file")
    printf '%s\t%s\n' "$rel" "$md5"
  done
} > "$CHECKSUMS"

COUNT=$(find "$OUTPUT/research" -name '*.json' | wc -l | tr -d ' ')
CHECKSUM_COUNT=$(($(wc -l < "$CHECKSUMS") - 1))
echo "Bundled catalog ready: manifest.tsv + $COUNT research profiles + $CHECKSUM_COUNT checksums in $OUTPUT"