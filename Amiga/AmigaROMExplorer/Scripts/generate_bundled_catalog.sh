#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT="$ROOT/AmigaROMExplorer/Resources"
MANIFEST="${MANIFEST_PATH:-/Users/megov/code/GitHub/littlethings/Amiga/commodore-amiga-firmware/manifest.tsv}"
APP="$ROOT/build/Build/Products/Debug/AmigaROMExplorer.app/Contents/MacOS/AmigaROMExplorer"

mkdir -p "$OUTPUT"

xcodebuild -project "$ROOT/AmigaROMExplorer.xcodeproj" -scheme AmigaROMExplorer -configuration Debug -derivedDataPath "$ROOT/build" build -quiet

MANIFEST_PATH="$MANIFEST" "$APP" --export-bundled-cache "$OUTPUT"

COUNT=$(find "$OUTPUT/research" -name '*.json' | wc -l | tr -d ' ')
echo "Bundled catalog ready: manifest.tsv + $COUNT research profiles in $OUTPUT"