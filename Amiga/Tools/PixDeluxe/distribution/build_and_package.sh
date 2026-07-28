#!/bin/bash

set -e

PROJECT_NAME="PixDeluxe"
PROJECT_PATH="../${PROJECT_NAME}.xcodeproj"
SCHEME="PixDeluxe - Release" # Updated to use Release scheme
CONFIGURATION="Release"
ARCHIVE_PATH="./build/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="./build"
APP_PATH="${EXPORT_PATH}/${PROJECT_NAME}.app"
DMG_BASE_PATH="../releases/${PROJECT_NAME}.dmg"
README_PATH="dmg_assets/README.md"
CHANGELOG_PATH="../CHANGELOG.md"
BACKGROUND_IMAGE="dmg_assets/dmg-background.png"
VOLUME_ICON="dmg_assets/dmg-icon.icns"
EXPORT_OPTIONS_PLIST="exportOptions.plist"
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
README_PATH="${SCRIPT_DIR}/${README_PATH}"
CHANGELOG_PATH="${SCRIPT_DIR}/${CHANGELOG_PATH}"
BACKGROUND_IMAGE="${SCRIPT_DIR}/${BACKGROUND_IMAGE}"
VOLUME_ICON="${SCRIPT_DIR}/${VOLUME_ICON}"
EXPORT_OPTIONS_PLIST="${SCRIPT_DIR}/${EXPORT_OPTIONS_PLIST}"
DMG_DIR="${SCRIPT_DIR}/../../releases"
DMG_BASE_PATH="${DMG_DIR}/${PROJECT_NAME}.dmg"
PROJECT_PATH="${SCRIPT_DIR}/${PROJECT_PATH}"

for file in "$PROJECT_PATH" "$README_PATH" "$CHANGELOG_PATH" "$BACKGROUND_IMAGE" "$VOLUME_ICON" "$EXPORT_OPTIONS_PLIST" "$SCRIPT_DIR/gendmg.sh"; do
    if [ ! -e "$file" ]; then
        echo "Error: File not found at $file"
        exit 1
    fi
done

mkdir -p "$DMG_DIR" || { echo "Error: Failed to create $DMG_DIR"; exit 1; }

AVAILABLE_SPACE=$(df -Pk "$DMG_DIR" | awk 'END { print int($4 / 1024) }')
if [ "$AVAILABLE_SPACE" -lt "$MIN_SPACE_MB" ]; then
    echo "Error: Insufficient disk space. Need $MIN_SPACE_MB MB, got ${AVAILABLE_SPACE} MB."
    exit 1
fi

echo "Cleaning build directory..."
rm -rf "$EXPORT_PATH"
mkdir -p "$EXPORT_PATH"

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

# Replace exportArchive with direct copy
echo "Copying .app from archive..."
cp -R "$ARCHIVE_PATH/Products/Applications/${PROJECT_NAME}.app" "$APP_PATH" \
    || { echo "Error: Copying app failed"; exit 1; }

if [ ! -d "$APP_PATH" ]; then
    echo "Error: Exported app not found at $APP_PATH"
    exit 1
fi

echo "Creating DMG with gendmg.sh..."
echo "Running: bash \"$SCRIPT_DIR/gendmg.sh\" --readme \"$README_PATH\" --app \"$APP_PATH\" --dmg \"$DMG_BASE_PATH\" --background \"$BACKGROUND_IMAGE\" --volicon \"$VOLUME_ICON\""
bash "$SCRIPT_DIR/gendmg.sh" \
    --readme "$README_PATH" \
    --changelog "$CHANGELOG_PATH" \
    --app "$APP_PATH" \
    --dmg "$DMG_BASE_PATH" \
    --background "$BACKGROUND_IMAGE" \
    --volicon "$VOLUME_ICON" \
    || { echo "Error: DMG creation failed (exit code $?)"; exit 1; }

echo "Build and packaging complete."
