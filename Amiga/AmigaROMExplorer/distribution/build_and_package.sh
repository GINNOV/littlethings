#!/bin/bash
set -euo pipefail

PROJECT_NAME="AmigaROMExplorer"
PROJECT_PATH="../${PROJECT_NAME}.xcodeproj"
SCHEME="AmigaROMExplorer"
CONFIGURATION="Release"
ARCHIVE_PATH="./build/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="./build"
APP_PATH="${EXPORT_PATH}/${PROJECT_NAME}.app"
MIN_SPACE_MB=1024

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
README_PATH="${SCRIPT_DIR}/dmg_assets/README.md"
BACKGROUND_IMAGE="${SCRIPT_DIR}/dmg_assets/dmg-background.png"
VOLUME_ICON="${SCRIPT_DIR}/dmg_assets/dmg-icon.icns"
EXPORT_OPTIONS_PLIST="${SCRIPT_DIR}/exportOptions.plist"
DMG_DIR="${SCRIPT_DIR}/../../Tools/releases"
DMG_BASE_PATH="${DMG_DIR}/${PROJECT_NAME}.dmg"
PROJECT_PATH="${SCRIPT_DIR}/${PROJECT_PATH}"
GENERATE_SCRIPT="${SCRIPT_DIR}/../Scripts/generate_bundled_catalog.sh"
APPCAST_PATH="${DMG_DIR}/appcast-amigaromexplorer.xml"

for file in "$PROJECT_PATH" "$README_PATH" "$BACKGROUND_IMAGE" "$VOLUME_ICON" "$EXPORT_OPTIONS_PLIST" "${SCRIPT_DIR}/gendmg.sh" "$GENERATE_SCRIPT"; do
    if [ ! -e "$file" ]; then
        echo "Error: File not found at $file"
        exit 1
    fi
done

mkdir -p "$DMG_DIR"

AVAILABLE_SPACE=$(df -P "$DMG_DIR" | tail -1 | awk '{print $4}' | awk '{print $1 / 1024}')
if (( $(echo "$AVAILABLE_SPACE < $MIN_SPACE_MB" | bc -l) )); then
    echo "Error: Insufficient disk space. Need $MIN_SPACE_MB MB, got ${AVAILABLE_SPACE} MB."
    exit 1
fi

echo "Regenerating bundled catalog..."
bash "$GENERATE_SCRIPT"

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
    -skipMacroValidation

echo "Copying .app from archive..."
cp -R "$ARCHIVE_PATH/Products/Applications/${PROJECT_NAME}.app" "$APP_PATH"

if [ ! -d "$APP_PATH" ]; then
    echo "Error: Exported app not found at $APP_PATH"
    exit 1
fi

echo "Creating DMG..."
bash "${SCRIPT_DIR}/gendmg.sh" \
    --readme "$README_PATH" \
    --app "$APP_PATH" \
    --dmg "$DMG_BASE_PATH" \
    --background "$BACKGROUND_IMAGE" \
    --volicon "$VOLUME_ICON"

INFO_PLIST_PATH="${APP_PATH}/Contents/Info.plist"
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$INFO_PLIST_PATH")
BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFO_PLIST_PATH")
DMG_NAME="${PROJECT_NAME}-${VERSION}_${BUILD_NUMBER}.dmg"
DMG_FINAL_PATH="${DMG_DIR}/${DMG_NAME}"

if [ ! -f "$DMG_FINAL_PATH" ]; then
    echo "Error: DMG not found at $DMG_FINAL_PATH"
    exit 1
fi

DMG_SIZE=$(stat -f %z "$DMG_FINAL_PATH")
PUB_DATE=$(date -u "+%a, %d %b %Y %H:%M:%S +0000")

cat > "$APPCAST_PATH" <<EOF
<?xml version='1.0' encoding='utf-8'?>
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" version="2.0">
    <channel>
        <title>Amiga ROM Explorer Changelog</title>
        <item>
            <title>Version ${VERSION}</title>
            <description><![CDATA[
Build ${BUILD_NUMBER}: sidebar interaction fixes, improved Ollama setup wizard, and Sparkle auto-updates.
]]></description>
            <sparkle:releaseNotesLink>https://raw.githubusercontent.com/GINNOV/littlethings/master/Amiga/Tools/releases/changelogs.html#amigaromexplorer</sparkle:releaseNotesLink>
            <pubDate>${PUB_DATE}</pubDate>
            <enclosure url="https://github.com/GINNOV/littlethings/raw/master/Amiga/Tools/releases/${DMG_NAME}" sparkle:version="${BUILD_NUMBER}" sparkle:shortVersionString="${VERSION}" length="${DMG_SIZE}" type="application/octet-stream" />
        </item>
    </channel>
</rss>
EOF

echo "DMG created at: $DMG_FINAL_PATH"
echo "Appcast updated at: $APPCAST_PATH"
echo "Build and packaging complete."