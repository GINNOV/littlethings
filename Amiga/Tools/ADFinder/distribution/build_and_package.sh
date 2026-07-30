#!/bin/bash

set -euo pipefail

# --- START: Configuration for ADFinder ---
PROJECT_NAME="ADFinder"
PROJECT_PATH="../${PROJECT_NAME}.xcodeproj"
SCHEME="ADFinder"
CONFIGURATION="Release"
SPARKLE_KEY_ACCOUNT="ADFinder"
RELEASE_NOTES_CONTENT='
<ul>
    <li>One-time manual upgrade to ADFinder&rsquo;s new dedicated Sparkle signing key.</li>
    <li>Repaired and hardened automatic updates for subsequent releases.</li>
    <li>Corrected HDF document registration.</li>
    <li>Added automated coverage for disk comparison and application metadata.</li>
</ul>
'
# --- END: Configuration for ADFinder ---

ARCHIVE_PATH="./build/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="./build"
APP_PATH="${EXPORT_PATH}/${PROJECT_NAME}.app"
DMG_BASE_PATH="../releases/${PROJECT_NAME}.dmg"
README_PATH="dmg_assets/README.md"
CHANGELOG_PATH="../CHANGELOG.md"
BACKGROUND_IMAGE="dmg_assets/dmg-background.png"
VOLUME_ICON="dmg_assets/dmg-icon.icns"
EXPORT_OPTIONS_PLIST="exportOptions.plist"
ENTITLEMENTS_PATH="../ADFinder/ADFinder.entitlements"
MIN_SPACE_MB=1024

usage() {
    echo "Usage: $0 [--project <project_path>] [--scheme <scheme>] [--configuration <config>]"
    echo "Example: $0 --project ../${PROJECT_NAME}.xcodeproj --scheme \"${SCHEME}\" --configuration Release"
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
ENTITLEMENTS_PATH="${SCRIPT_DIR}/${ENTITLEMENTS_PATH}"
DMG_DIR="${SCRIPT_DIR}/../../releases"
PROJECT_PATH="${SCRIPT_DIR}/${PROJECT_PATH}"

for file in "$PROJECT_PATH" "$README_PATH" "$CHANGELOG_PATH" "$BACKGROUND_IMAGE" "$VOLUME_ICON" "$EXPORT_OPTIONS_PLIST" "$ENTITLEMENTS_PATH" "$SCRIPT_DIR/gendmg.sh"; do
    if [ ! -e "$file" ]; then
        echo "Error: Required file not found at $file"
        exit 1
    fi
done

mkdir -p "$DMG_DIR" || { echo "Error: Failed to create $DMG_DIR"; exit 1; }
RELEASE_STAGING_DIR=$(mktemp -d "${DMG_DIR}/.${PROJECT_NAME}-release.XXXXXX")
trap 'rm -rf "$RELEASE_STAGING_DIR"' EXIT
DMG_BASE_PATH="${RELEASE_STAGING_DIR}/${PROJECT_NAME}.dmg"

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

echo "Copying .app from archive..."
cp -R "$ARCHIVE_PATH/Products/Applications/${PROJECT_NAME}.app" "$APP_PATH" \
    || { echo "Error: Copying app failed"; exit 1; }

if [ ! -d "$APP_PATH" ]; then
    echo "Error: Exported app not found at $APP_PATH"
    exit 1
fi

echo "Creating DMG with gendmg.sh..."
bash "$SCRIPT_DIR/gendmg.sh" \
    --readme "$README_PATH" \
    --entitlements "$ENTITLEMENTS_PATH" \
    --app "$APP_PATH" \
    --dmg "$DMG_BASE_PATH" \
    --background "$BACKGROUND_IMAGE" \
    --volicon "$VOLUME_ICON" \
    || { echo "Error: DMG creation failed (exit code $?)"; exit 1; }

echo "Build and packaging complete."

INFO_PLIST_PATH="${APP_PATH}/Contents/Info.plist"
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$INFO_PLIST_PATH")
BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFO_PLIST_PATH")
APP_PUBLIC_KEY=$(/usr/libexec/PlistBuddy -c "Print :SUPublicEDKey" "$INFO_PLIST_PATH")

if [[ "$(/usr/libexec/PlistBuddy -c "Print :SUEnableInstallerLauncherService" "$INFO_PLIST_PATH" 2>/dev/null)" != "true" ]]; then
    echo "Error: SUEnableInstallerLauncherService must be enabled for the sandboxed app"
    exit 1
fi

DMG_NAME="${PROJECT_NAME}-${VERSION}_${BUILD_NUMBER}.dmg"
STAGED_DMG_PATH="${RELEASE_STAGING_DIR}/${DMG_NAME}"
DMG_FINAL_PATH="${DMG_DIR}/${DMG_NAME}"
ZIP_NAME="${PROJECT_NAME}-${VERSION}_${BUILD_NUMBER}.zip"
STAGED_ZIP_PATH="${RELEASE_STAGING_DIR}/${ZIP_NAME}"
ZIP_PATH="${DMG_DIR}/${ZIP_NAME}"
STAGED_APPCAST_PATH="${RELEASE_STAGING_DIR}/appcast-adfinder.xml"
APPCAST_PATH="${DMG_DIR}/appcast-adfinder.xml"

if [ ! -f "$STAGED_DMG_PATH" ]; then
    echo "Error: Staged DMG not found at $STAGED_DMG_PATH after running gendmg.sh"
    exit 1
fi

echo "Creating ZIP for Sparkle..."
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$STAGED_ZIP_PATH"

SPARKLE_TOOL_ROOT=$(find "$HOME/Library/Developer/Xcode/DerivedData" \
    -path '*/SourcePackages/artifacts/sparkle/Sparkle/bin/sign_update' \
    -type f -perm +111 -print -quit)
if [[ -z "$SPARKLE_TOOL_ROOT" ]]; then
    echo "Error: Sparkle tools were not found in Xcode DerivedData"
    exit 1
fi
SPARKLE_TOOL_ROOT=$(dirname "$SPARKLE_TOOL_ROOT")
SIGN_UPDATE_TOOL="${SPARKLE_TOOL_ROOT}/sign_update"
GENERATE_KEYS_TOOL="${SPARKLE_TOOL_ROOT}/generate_keys"

for tool in "$SIGN_UPDATE_TOOL" "$GENERATE_KEYS_TOOL"; do
    if [[ ! -x "$tool" ]]; then
        echo "Error: Sparkle tool not found: $tool"
        exit 1
    fi
done

KEYCHAIN_PUBLIC_KEY=$("$GENERATE_KEYS_TOOL" --account "$SPARKLE_KEY_ACCOUNT" -p)
if [[ "$APP_PUBLIC_KEY" != "$KEYCHAIN_PUBLIC_KEY" ]]; then
    echo "Error: SUPublicEDKey does not match the default Sparkle Keychain account"
    exit 1
fi
RAW_SIGNATURE_OUTPUT=$("$SIGN_UPDATE_TOOL" --account "$SPARKLE_KEY_ACCOUNT" "$STAGED_ZIP_PATH")

SIGNATURE=$(sed -n 's/.*sparkle:edSignature="\([^"]*\)".*/\1/p' <<< "$RAW_SIGNATURE_OUTPUT")
ZIP_SIZE=$(sed -n 's/.*length="\([^"]*\)".*/\1/p' <<< "$RAW_SIGNATURE_OUTPUT")
SIGNATURE=$(tr -d '\r\n' <<< "$SIGNATURE")

if [[ -z "$SIGNATURE" || -z "$ZIP_SIZE" ]]; then
    echo "Error: sign_update returned an unexpected result"
    exit 1
fi

PUB_DATE=$(date -R)
DOWNLOAD_URL="https://github.com/GINNOV/littlethings/raw/master/Amiga/Tools/releases/$ZIP_NAME"
cat > "$STAGED_APPCAST_PATH" <<XML
<?xml version="1.0" encoding="utf-8"?>
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" version="2.0">
  <channel>
    <title>ADFinder Changelog</title>
    <item>
      <title>Version ${VERSION}</title>
      <description><![CDATA[${RELEASE_NOTES_CONTENT}]]></description>
      <pubDate>${PUB_DATE}</pubDate>
      <enclosure url="${DOWNLOAD_URL}" sparkle:version="${BUILD_NUMBER}" sparkle:shortVersionString="${VERSION}" length="${ZIP_SIZE}" type="application/octet-stream" sparkle:edSignature="${SIGNATURE}" />
    </item>
  </channel>
</rss>
XML

xmllint --noout "$STAGED_APPCAST_PATH"

mv "$STAGED_DMG_PATH" "$DMG_FINAL_PATH"
mv "$STAGED_ZIP_PATH" "$ZIP_PATH"
mv "$STAGED_APPCAST_PATH" "$APPCAST_PATH"
echo "Created DMG: ${DMG_FINAL_PATH}"
echo "Created ZIP: ${ZIP_PATH}"
echo "Updated appcast: ${APPCAST_PATH}"
