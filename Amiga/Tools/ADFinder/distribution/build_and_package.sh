#!/bin/bash

set -e

PROJECT_NAME="ADFinder"
PROJECT_PATH="../${PROJECT_NAME}.xcodeproj"
SCHEME="ADFinder - Release" # Updated to use Release scheme
CONFIGURATION="Release"
ARCHIVE_PATH="./build/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="./build"
APP_PATH="${EXPORT_PATH}/${PROJECT_NAME}.app"
# This is the base path gendmg.sh will use to construct the final versioned name
DMG_BASE_PATH="../releases/${PROJECT_NAME}.dmg"
README_PATH="dmg_assets/README.md"
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
BACKGROUND_IMAGE="${SCRIPT_DIR}/${BACKGROUND_IMAGE}"
VOLUME_ICON="${SCRIPT_DIR}/${VOLUME_ICON}"
EXPORT_OPTIONS_PLIST="${SCRIPT_DIR}/${EXPORT_OPTIONS_PLIST}"
DMG_DIR="${SCRIPT_DIR}/../../releases"
DMG_BASE_PATH="${DMG_DIR}/${PROJECT_NAME}.dmg"
PROJECT_PATH="${SCRIPT_DIR}/${PROJECT_PATH}"

for file in "$PROJECT_PATH" "$README_PATH" "$BACKGROUND_IMAGE" "$VOLUME_ICON" "$EXPORT_OPTIONS_PLIST" "./gendmg.sh"; do
    if [ ! -e "$file" ]; then
        echo "Error: File not found at $file"
        exit 1
    fi
done

mkdir -p "$DMG_DIR" || { echo "Error: Failed to create $DMG_DIR"; exit 1; }

AVAILABLE_SPACE=$(df -P "$DMG_DIR" | tail -1 | awk '{print $4}' | awk '{print $1 / 1024}')
if (( $(echo "$AVAILABLE_SPACE < $MIN_SPACE_MB" | bc -l) )); then
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
    --app "$APP_PATH" \
    --dmg "$DMG_BASE_PATH" \
    --background "$BACKGROUND_IMAGE" \
    --volicon "$VOLUME_ICON" \
    || { echo "Error: DMG creation failed (exit code $?)"; exit 1; }

echo "Build and packaging complete."

# --- START: Appcast Update Logic ---

echo "--- Updating appcast.xml ---"

# Dynamically get version and build number from the app's Info.plist
INFO_PLIST_PATH="${APP_PATH}/Contents/Info.plist"
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$INFO_PLIST_PATH")
BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFO_PLIST_PATH")

# Construct the final DMG name, which is what gendmg.sh already created
DMG_NAME="${PROJECT_NAME}-${VERSION}_${BUILD_NUMBER}.dmg"
DMG_FINAL_PATH="${DMG_DIR}/${DMG_NAME}"
APPCAST_PATH="${DMG_DIR}/appcast.xml"
RELEASE_NOTES_URL="https://raw.githubusercontent.com/GINNOV/littlethings/master/Amiga/Tools/releases/changelogs.html#ADFinder"

# Check if the final DMG exists before proceeding
if [ ! -f "$DMG_FINAL_PATH" ]; then
    echo "Error: Final DMG not found at $DMG_FINAL_PATH after running gendmg.sh"
    exit 1
fi

# Get required info for the appcast item
DMG_SIZE=$(stat -f %z "$DMG_FINAL_PATH")
PUB_DATE=$(date -R)
DOWNLOAD_URL="https://github.com/GINNOV/littlethings/raw/master/Amiga/Tools/releases/$DMG_NAME"

# Use an embedded Python script for robust XML parsing
python3 -c "
import xml.etree.ElementTree as ET
import sys

# Get variables from shell
appcast_path = sys.argv[1]
version = sys.argv[2]
build_number = sys.argv[3]
dmg_url = sys.argv[4]
dmg_size = sys.argv[5]
pub_date = sys.argv[6]
release_notes_url = sys.argv[7]

# Register the sparkle namespace to prevent it from being renamed to ns0:
ET.register_namespace('sparkle', 'http://www.andymatuschak.org/xml-namespaces/sparkle')

# Parse the XML file
tree = ET.parse(appcast_path)
root = tree.getroot()
channel = root.find('channel')

# --- Check for and remove existing item for this version ---
for item in channel.findall('item'):
    enclosure = item.find('enclosure')
    if enclosure is not None:
        short_version = enclosure.get('{http://www.andymatuschak.org/xml-namespaces/sparkle}shortVersionString')
        if short_version == version:
            print(f'Found existing item for version {version}. Removing it before adding the new one.')
            channel.remove(item)

# Create the new <item> element and its children
new_item = ET.Element('item')
title = ET.SubElement(new_item, 'title')
title.text = f'Version {version}'

# Add the release notes link
release_notes = ET.SubElement(new_item, '{http://www.andymatuschak.org/xml-namespaces/sparkle}releaseNotesLink')
release_notes.text = release_notes_url

pub_date_element = ET.SubElement(new_item, 'pubDate')
pub_date_element.text = pub_date

enclosure = ET.SubElement(new_item, 'enclosure')
enclosure.set('url', dmg_url)
enclosure.set('sparkle:version', build_number)
enclosure.set('sparkle:shortVersionString', version)
enclosure.set('length', dmg_size)
enclosure.set('type', 'application/octet-stream')

# Insert the new item at the beginning of the channel
channel.insert(0, new_item)

# Write the changes back to the file
tree.write(appcast_path, encoding='utf-8', xml_declaration=True)

print(f'Successfully added Version {version} (Build {build_number}) to appcast.xml')
" "$APPCAST_PATH" "$VERSION" "$BUILD_NUMBER" "$DOWNLOAD_URL" "$DMG_SIZE" "$PUB_DATE" "$RELEASE_NOTES_URL"

# --- END: Appcast Update Logic ---

echo "--- All Done! ---"