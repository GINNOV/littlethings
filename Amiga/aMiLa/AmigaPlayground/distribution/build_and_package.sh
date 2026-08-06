#!/bin/bash

set -e

PROJECT_NAME="AmigaPlayground"
APP_NAME="Amiga Playground"
PROJECT_PATH="../${PROJECT_NAME}.xcodeproj"
SCHEME="AmigaPlayground"
CONFIGURATION="Release"
ARCHIVE_PATH="./build/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="./build"
APP_PATH="${EXPORT_PATH}/${APP_NAME}.app"
MIN_SPACE_MB=1024

usage() {
    echo "Usage: $0 [--project <project_path>] [--scheme <scheme>] [--configuration <config>]"
    echo "Example: $0 --project ../${PROJECT_NAME}.xcodeproj --scheme ${SCHEME} --configuration Release"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --project) PROJECT_PATH="$2"; shift ;;
        --scheme) SCHEME="$2"; shift ;;
        --configuration) CONFIGURATION="$2"; shift ;;
        *) usage ;;
    esac
    shift
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
README_PATH="${SCRIPT_DIR}/dmg_assets/README.md"
BACKGROUND_IMAGE="${SCRIPT_DIR}/dmg_assets/dmg-background.png"
VOLUME_ICON="${SCRIPT_DIR}/dmg_assets/dmg-icon.icns"
EXPORT_OPTIONS_PLIST="${SCRIPT_DIR}/exportOptions.plist"
DMG_DIR="${SCRIPT_DIR}/../../../Tools/releases"
DMG_BASE_PATH="${DMG_DIR}/${PROJECT_NAME}.dmg"
PROJECT_PATH="${SCRIPT_DIR}/${PROJECT_PATH}"

for file in "$PROJECT_PATH" "$README_PATH" "$BACKGROUND_IMAGE" "$VOLUME_ICON" "$EXPORT_OPTIONS_PLIST" "${SCRIPT_DIR}/gendmg.sh"; do
    if [ ! -e "$file" ]; then
        echo "Error: File not found at $file"
        exit 1
    fi
done

mkdir -p "$DMG_DIR" || { echo "Error: Failed to create $DMG_DIR"; exit 1; }

AVAILABLE_SPACE_KB=$(df -Pk "$DMG_DIR" | awk 'END {print $4}')
REQUIRED_SPACE_KB=$((MIN_SPACE_MB * 1024))
if (( AVAILABLE_SPACE_KB < REQUIRED_SPACE_KB )); then
    echo "Error: Insufficient disk space. Need $MIN_SPACE_MB MB."
    exit 1
fi

echo "Cleaning build directory..."
rm -rf "$EXPORT_PATH"
mkdir -p "$EXPORT_PATH"

echo "Building MLXServerHelper..."
swift build -c release --package-path "${SCRIPT_DIR}/.." --product MLXServerHelper

echo "Archiving $SCHEME..."
xcodebuild archive \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    -allowProvisioningUpdates \
    -skipPackagePluginValidation \
    -skipMacroValidation \
    || { echo "Error: Archive failed"; exit 1; }

echo "Copying .app from archive..."
cp -R "$ARCHIVE_PATH/Products/Applications/${APP_NAME}.app" "$APP_PATH" \
    || { echo "Error: Copying app failed"; exit 1; }

if [ ! -d "$APP_PATH" ]; then
    echo "Error: Exported app not found at $APP_PATH"
    exit 1
fi

echo "Bundling MLXServerHelper..."
HELPER_PRODUCT="${SCRIPT_DIR}/../.build/release/MLXServerHelper"
if [ ! -f "$HELPER_PRODUCT" ]; then
    echo "Error: MLXServerHelper product not found at $HELPER_PRODUCT"
    exit 1
fi
mkdir -p "$APP_PATH/Contents/Helpers"
cp "$HELPER_PRODUCT" "$APP_PATH/Contents/Helpers/MLXServerHelper"
chmod +x "$APP_PATH/Contents/Helpers/MLXServerHelper"

echo "Creating DMG with gendmg.sh..."
echo "Running: bash \"$SCRIPT_DIR/gendmg.sh\" --readme \"$README_PATH\" --app \"$APP_PATH\" --dmg \"$DMG_BASE_PATH\" --background \"$BACKGROUND_IMAGE\" --volicon \"$VOLUME_ICON\""
bash "$SCRIPT_DIR/gendmg.sh" \
    --readme "$README_PATH" \
    --app "$APP_PATH" \
    --dmg "$DMG_BASE_PATH" \
    --background "$BACKGROUND_IMAGE" \
    --volicon "$VOLUME_ICON" \
    || { echo "Error: DMG creation failed (exit code $?)"; exit 1; }

INFO_PLIST_PATH="${APP_PATH}/Contents/Info.plist"
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$INFO_PLIST_PATH")
BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFO_PLIST_PATH")
ZIP_NAME="${PROJECT_NAME}-${VERSION}_${BUILD_NUMBER}.zip"
ZIP_PATH="${DMG_DIR}/${ZIP_NAME}"

echo "Creating ZIP for Sparkle..."
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

OBJROOT=$(xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME" -showBuildSettings -json | sed -n 's/.*"OBJROOT" : "\([^"]*\)".*/\1/p' | head -1)
PROJECT_DERIVED_DATA_ROOT=$(dirname "$(dirname "$OBJROOT")")
SIGN_UPDATE_TOOL="${PROJECT_DERIVED_DATA_ROOT}/SourcePackages/artifacts/sparkle/Sparkle/bin/sign_update"

if [[ -x "$SIGN_UPDATE_TOOL" ]]; then
    echo "Signing ZIP with Sparkle sign_update..."
    "$SIGN_UPDATE_TOOL" "$ZIP_PATH"
fi

echo "Build and packaging complete."
echo "Created DMG: ${DMG_DIR}/${PROJECT_NAME}-${VERSION}_${BUILD_NUMBER}.dmg"
echo "Created ZIP: ${ZIP_PATH}"
