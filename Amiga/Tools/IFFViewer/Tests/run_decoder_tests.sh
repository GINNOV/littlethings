#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/iffviewer-tests.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' EXIT

xcrun clang \
    -std=c17 \
    -Wall -Wextra \
    -fsanitize=address,undefined \
    -fno-omit-frame-pointer \
    -framework CoreGraphics \
    -framework CoreFoundation \
    -framework CoreServices \
    -framework QuickLook \
    "$SCRIPT_DIR/IFFDecoderSafetyTests.c" \
    "$SCRIPT_DIR/../IFFPreviewExtension/IFFParser/safe_iff.c" \
    -o "$BUILD_DIR/IFFDecoderSafetyTests"

"$BUILD_DIR/IFFDecoderSafetyTests"
