#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
SCHEME_NAME="AmigaPlayground"
APP_NAME="Amiga Playground"
BUNDLE_ID="GINNOV.AmigaPlayground"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_FILE="$ROOT_DIR/AmigaPlayground.xcodeproj"
BUILD_DIR="$ROOT_DIR/build"
BUILT_APP="$BUILD_DIR/Debug/$APP_NAME.app"
LOCAL_APP="$ROOT_DIR/$APP_NAME.app"
HELPER_PRODUCT="$ROOT_DIR/.build/debug/MLXServerHelper"

pkill -x "$APP_NAME" >/dev/null 2>&1 || true

swift build --package-path "$ROOT_DIR" --product MLXServerHelper

xcodebuild \
  -project "$PROJECT_FILE" \
  -scheme "$SCHEME_NAME" \
  -configuration Debug \
  SYMROOT="$BUILD_DIR" \
  build

rm -rf "$LOCAL_APP"
ditto "$BUILT_APP" "$LOCAL_APP"
mkdir -p "$LOCAL_APP/Contents/Helpers"
cp "$HELPER_PRODUCT" "$LOCAL_APP/Contents/Helpers/MLXServerHelper"
chmod +x "$LOCAL_APP/Contents/Helpers/MLXServerHelper"

open_app() {
  /usr/bin/open -n "$LOCAL_APP"
}

case "$MODE" in
  run)
    open_app
    ;;
  --debug|debug)
    lldb -- "$LOCAL_APP/Contents/MacOS/$APP_NAME"
    ;;
  --logs|logs)
    open_app
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
    ;;
  --telemetry|telemetry)
    open_app
    /usr/bin/log stream --info --style compact --predicate "subsystem == \"$BUNDLE_ID\""
    ;;
  --verify|verify)
    open_app
    sleep 2
    pgrep -x "$APP_NAME" >/dev/null
    ;;
  *)
    echo "usage: $0 [run|--debug|--logs|--telemetry|--verify]" >&2
    exit 2
    ;;
esac
