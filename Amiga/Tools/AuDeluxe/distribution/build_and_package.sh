#!/bin/bash

set -euo pipefail

# --- START: Configuration for AuDeluxe ---
PROJECT_NAME="AuDeluxe"
PROJECT_PATH="../${PROJECT_NAME}.xcodeproj"
SCHEME="AuDeluxe - Release"
CONFIGURATION="Release"

# Release notes (fixed typos)
RELEASE_NOTES_CONTENT='
<h4>New Features</h4>
<ul>
    <li>Added Sparkle for automatic application updates.</li>
    <li>Implemented a caching system for faster startup times.</li>
    <li>Added a search bar to the playlist view.</li>
    <li>Added a jump link for the currently playing song.</li>
    <li>Added a menu bar to control music without switching to the app.</li>
</ul>
<h4>Bug Fixes</h4>
<ul>
    <li>Fixed an issue where the default sort order was not applied on launch.</li>
    <li>Loopback worked but the timeline was not moving.</li>
</ul>
'
# --- END: Configuration for AuDeluxe ---

ARCHIVE_PATH="./build/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="./build"
APP_PATH="${EXPORT_PATH}/${PROJECT_NAME}.app"
DMG_BASE_PATH="../releases/${PROJECT_NAME}.dmg"
README_PATH="dmg_assets/README.md"
BACKGROUND_IMAGE="dmg_assets/dmg-background.png"
VOLUME_ICON="dmg_assets/dmg-icon.icns"
EXPORT_OPTIONS_PLIST="exportOptions.plist"
MIN_SPACE_MB=1024

usage() {
    echo "Usage: $0 [--project <project_path>] [--scheme <scheme>] [--configuration <config>]"
    echo
    echo "Env vars (optional but recommended for CI):"
    echo "  SPARKLE_PRIVATE_KEY        Contents of your EdDSA private key"
    echo "  SPARKLE_PRIVATE_KEY_PATH   Path to file containing the private key"
    exit 1
}

while [[ "${#}" -gt 0 ]]; do
    case "$1" in
        --project) PROJECT_PATH="$2"; shift ;;
        --scheme) SCHEME="$2"; shift ;;
        --configuration) CONFIGURATION="$2"; shift ;;
        -h|--help) usage ;;
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
        echo "Error: Required file not found at $file"
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

echo "Copying .app from archive..."
cp -R "$ARCHIVE_PATH/Products/Applications/${PROJECT_NAME}.app" "$APP_PATH" \
    || { echo "Error: Copying app failed"; exit 1; }

if [ ! -d "$APP_PATH" ]; then
    echo "Error: Exported app not found at $APP_PATH"
    exit 1
fi

# Ensure Sparkle public key is embedded
INFO_PLIST_PATH="${APP_PATH}/Contents/Info.plist"
if ! /usr/libexec/PlistBuddy -c "Print :SUPublicEDKey" "$INFO_PLIST_PATH" >/dev/null 2>&1; then
    echo "Error: SUPublicEDKey is missing in ${INFO_PLIST_PATH}. Sparkle will reject updates."
    echo "Add your EdDSA public key under SUPublicEDKey in the target's Info.plist and rebuild."
    exit 1
fi

echo "Creating DMG with gendmg.sh..."
bash "$SCRIPT_DIR/gendmg.sh" \
    --readme "$README_PATH" \
    --app "$APP_PATH" \
    --dmg "$DMG_BASE_PATH" \
    --background "$BACKGROUND_IMAGE" \
    --volicon "$VOLUME_ICON" \
    || { echo "Error: DMG creation failed (exit code $?)"; exit 1; }

echo "Build and packaging complete."

# --- START: Appcast Update Logic ---

echo "--- Updating appcast-audeluxe.xml ---"

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$INFO_PLIST_PATH")
BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFO_PLIST_PATH")

DMG_NAME="${PROJECT_NAME}-${VERSION}_${BUILD_NUMBER}.dmg"
DMG_FINAL_PATH="${DMG_DIR}/${DMG_NAME}"
APPCAST_PATH="${DMG_DIR}/appcast-audeluxe.xml"

echo "Creating ZIP for Sparkle signing..."
ZIP_NAME="${PROJECT_NAME}-${VERSION}_${BUILD_NUMBER}.zip"
ZIP_PATH="${DMG_DIR}/${ZIP_NAME}"

# Create ZIP from the .app
(
    cd "$EXPORT_PATH"
    /usr/bin/zip -r -y "$ZIP_PATH" "${PROJECT_NAME}.app" >/dev/null
)

echo "Locating Sparkle sign_update tool..."
OBJROOT=$(xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME" -showBuildSettings -json | grep -o '"OBJROOT" : "[^"]*' | cut -d'"' -f4)
PROJECT_DERIVED_DATA_ROOT=$(dirname "$(dirname "$OBJROOT")")
SIGN_UPDATE_TOOL="${PROJECT_DERIVED_DATA_ROOT}/SourcePackages/artifacts/sparkle/Sparkle/bin/sign_update"

if [ ! -x "$SIGN_UPDATE_TOOL" ]; then
    echo "Error: sign_update tool not found or not executable. Looked in: ${SIGN_UPDATE_TOOL}"
    exit 1
fi

# Resolve private key contents if provided
SPARKLE_KEY_CONTENTS="${SPARKLE_PRIVATE_KEY:-}"
if [[ -z "${SPARKLE_KEY_CONTENTS}" && -n "${SPARKLE_PRIVATE_KEY_PATH:-}" ]]; then
    if [ ! -f "$SPARKLE_PRIVATE_KEY_PATH" ]; then
        echo "Error: SPARKLE_PRIVATE_KEY_PATH set but file not found: $SPARKLE_PRIVATE_KEY_PATH"
        exit 1
    fi
    SPARKLE_KEY_CONTENTS="$(cat "$SPARKLE_PRIVATE_KEY_PATH")"
fi

echo "Signing the ZIP file..."
RAW_SIG_OUT=""
if [[ -n "$SPARKLE_KEY_CONTENTS" ]]; then
    RAW_SIG_OUT=$("$SIGN_UPDATE_TOOL" -s "${SPARKLE_KEY_CONTENTS}" "$ZIP_PATH")
else
    RAW_SIG_OUT=$("$SIGN_UPDATE_TOOL" "$ZIP_PATH")
fi

# Robustly extract only the edSignature (and optionally length) from sign_update output
SIG_ONLY=$(echo "$RAW_SIG_OUT" | sed -n 's/.*sparkle:edSignature="\([^"]*\)".*/\1/p')
if [[ -n "$SIG_ONLY" ]]; then
    SIGNATURE="$SIG_ONLY"
    SIG_LEN=$(echo "$RAW_SIG_OUT" | sed -n 's/.*length="\([^"]*\)".*/\1/p')
    if [[ -n "$SIG_LEN" ]]; then
        ZIP_SIZE="$SIG_LEN"
    else
        ZIP_SIZE=$(stat -f %z "$ZIP_PATH")
    fi
else
    # Fallback: assume the tool printed only the base64 signature
    SIGNATURE="$RAW_SIG_OUT"
    ZIP_SIZE=$(stat -f %z "$ZIP_PATH")
fi

# Normalize signature (strip whitespace/newlines)
SIGNATURE="$(echo -n "$SIGNATURE" | tr -d '\r\n')"

if [[ -z "$SIGNATURE" ]]; then
    echo "Error: sign_update did not return a signature. Raw output:"
    echo "$RAW_SIG_OUT"
    exit 1
fi

echo "Signature: $SIGNATURE"

PUB_DATE=$(date -R)
DOWNLOAD_URL="https://github.com/GINNOV/littlethings/raw/master/Amiga/Tools/releases/$ZIP_NAME"

if [ ! -f "$APPCAST_PATH" ]; then
    echo "Creating new appcast file at ${APPCAST_PATH}"
    cat > "$APPCAST_PATH" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" version="2.0">
  <channel>
    <title>AuDeluxe Changelog</title>
  </channel>
</rss>
XML
fi

DESCRIPTION_PLACEHOLDER="##SPARKLE_DESCRIPTION_PLACEHOLDER##"

python3 - <<'PY' "$APPCAST_PATH" "$VERSION" "$BUILD_NUMBER" "$DOWNLOAD_URL" "$ZIP_SIZE" "$PUB_DATE" "$DESCRIPTION_PLACEHOLDER" "$SIGNATURE"
import sys, re, xml.etree.ElementTree as ET
appcast_path, version, build_number, zip_url, zip_size, pub_date, description_placeholder, signature = sys.argv[1:]

sparkle_ns = 'http://www.andymatuschak.org/xml-namespaces/sparkle'
ET.register_namespace('sparkle', sparkle_ns)

with open(appcast_path, 'r', encoding='utf-8') as f:
    xml_content = f.read()

# Ensure sparkle namespace on root
if not re.search(r'<rss[^>]*xmlns:sparkle=', xml_content):
    xml_content = re.sub(r'(<rss[^>]*)', r'\1 xmlns:sparkle="'+sparkle_ns+'"', xml_content, count=1)

tree = ET.ElementTree(ET.fromstring(xml_content))
root = tree.getroot()
channel = root.find('channel')
if channel is None:
    channel = ET.SubElement(root, 'channel')

# Remove any existing item with same shortVersionString
for item in list(channel.findall('item')):
    enc = item.find('enclosure')
    if enc is not None and enc.get(f'{{{sparkle_ns}}}shortVersionString') == version:
        channel.remove(item)

new_item = ET.Element('item')
title = ET.SubElement(new_item, 'title')
title.text = f'Version {version}'

desc = ET.SubElement(new_item, 'description')
desc.text = description_placeholder

pde = ET.SubElement(new_item, 'pubDate')
pde.text = pub_date

enc = ET.SubElement(new_item, 'enclosure')
enc.set('url', zip_url)
enc.set(f'{{{sparkle_ns}}}version', build_number)
enc.set(f'{{{sparkle_ns}}}shortVersionString', version)
enc.set('length', zip_size)
enc.set('type', 'application/octet-stream')
enc.set(f'{{{sparkle_ns}}}edSignature', signature)

channel.insert(0, new_item)
tree.write(appcast_path, encoding='utf-8', xml_declaration=True)
print(f'Appcast updated with {version} ({build_number})')
PY

# Inject HTML release notes
perl -i -p0e "s|${DESCRIPTION_PLACEHOLDER}|<![CDATA[${RELEASE_NOTES_CONTENT}]]>|g" "$APPCAST_PATH"

# --- END: Appcast Update Logic ---

echo "--- All Done! ---"
echo "Created DMG: ${DMG_FINAL_PATH} (if produced)"
echo "Created ZIP: ${ZIP_PATH}"
echo "Updated appcast: ${APPCAST_PATH}"