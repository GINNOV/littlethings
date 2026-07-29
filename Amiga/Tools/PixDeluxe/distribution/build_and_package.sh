#!/bin/bash

set -euo pipefail

PROJECT_NAME="PixDeluxe"
PROJECT_PATH="../${PROJECT_NAME}.xcodeproj"
SCHEME="PixDeluxe - Release" # Updated to use Release scheme
CONFIGURATION="Release"
RELEASE_NOTES_CONTENT='
<h4>Sparkle installation bridge</h4>
<ul>
    <li>Completed Sparkle&apos;s sandboxed installer configuration for future automatic updates.</li>
    <li>Embedded and verified the Sparkle update key used to sign build 112.</li>
    <li>Added the missing Check for Updates command.</li>
    <li>This build is a one-time manual update; automatic updates resume after build 112 is installed.</li>
</ul>
'
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
    ARCHS="arm64 x86_64" \
    ONLY_ACTIVE_ARCH=NO \
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

ARCHITECTURES="$(lipo -archs "$APP_PATH/Contents/MacOS/$PROJECT_NAME")"
if [[ "$ARCHITECTURES" != *arm64* || "$ARCHITECTURES" != *x86_64* ]]; then
    echo "Error: Expected a universal binary, got '$ARCHITECTURES'"
    exit 1
fi

INFO_PLIST_PATH="${APP_PATH}/Contents/Info.plist"
APP_PUB=$(/usr/libexec/PlistBuddy -c "Print :SUPublicEDKey" "$INFO_PLIST_PATH")
if [[ "$(/usr/libexec/PlistBuddy -c "Print :SUEnableInstallerLauncherService" "$INFO_PLIST_PATH" 2>/dev/null)" != "true" ]]; then
    echo "Error: SUEnableInstallerLauncherService must be enabled for the sandboxed app"
    exit 1
fi

APP_ENTITLEMENTS=$(/usr/bin/codesign -d --entitlements :- "$APP_PATH" 2>/dev/null)
for mach_service in \
    "com.theblifemovement.PixDeluxe-spks" \
    "com.theblifemovement.PixDeluxe-spki"; do
    if ! grep -Fq "<string>${mach_service}</string>" <<< "$APP_ENTITLEMENTS"; then
        echo "Error: Missing Sparkle Mach service entitlement: ${mach_service}"
        exit 1
    fi
done

if [[ -n "${SPARKLE_PUBLIC_KEY:-}" && "$APP_PUB" != "$SPARKLE_PUBLIC_KEY" ]]; then
    echo "Error: SUPublicEDKey does not match SPARKLE_PUBLIC_KEY"
    exit 1
fi

SPARKLE_KEY_CONTENTS="${SPARKLE_PRIVATE_KEY:-}"
if [[ -z "$SPARKLE_KEY_CONTENTS" && -n "${SPARKLE_PRIVATE_KEY_PATH:-}" ]]; then
    if [[ ! -f "$SPARKLE_PRIVATE_KEY_PATH" ]]; then
        echo "Error: SPARKLE_PRIVATE_KEY_PATH not found: $SPARKLE_PRIVATE_KEY_PATH"
        exit 1
    fi
    SPARKLE_KEY_CONTENTS="$(<"$SPARKLE_PRIVATE_KEY_PATH")"
fi

if [[ -n "$SPARKLE_KEY_CONTENTS" ]]; then
    DERIVED_PUB=$(SPARKLE_KEY_CONTENTS="$SPARKLE_KEY_CONTENTS" /usr/bin/swift - <<'SWIFT'
import CryptoKit
import Foundation
let environment = ProcessInfo.processInfo.environment
guard let encoded = environment["SPARKLE_KEY_CONTENTS"],
      let data = Data(base64Encoded: encoded) else { exit(2) }
let seed: Data
switch data.count {
case 32: seed = data
case 64: seed = data.prefix(32)
default: exit(3)
}
let key = try Curve25519.Signing.PrivateKey(rawRepresentation: seed)
print(key.publicKey.rawRepresentation.base64EncodedString())
SWIFT
)
    if [[ "$APP_PUB" != "$DERIVED_PUB" ]]; then
        echo "Error: SUPublicEDKey does not match the provided private key"
        exit 1
    fi
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

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$INFO_PLIST_PATH")
BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFO_PLIST_PATH")
DMG_NAME="${PROJECT_NAME}-${VERSION}_${BUILD_NUMBER}.dmg"
DMG_FINAL_PATH="${DMG_DIR}/${DMG_NAME}"
ZIP_NAME="${PROJECT_NAME}-${VERSION}_${BUILD_NUMBER}.zip"
ZIP_PATH="${DMG_DIR}/${ZIP_NAME}"
APPCAST_PATH="${DMG_DIR}/appcast-pixdeluxe.xml"

echo "Creating ZIP for Sparkle..."
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

OBJROOT=$(xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME" -showBuildSettings -json | sed -n 's/.*"OBJROOT" : "\([^"]*\)".*/\1/p' | head -1)
PROJECT_DERIVED_DATA_ROOT=$(dirname "$(dirname "$OBJROOT")")
SIGN_UPDATE_TOOL="${PROJECT_DERIVED_DATA_ROOT}/SourcePackages/artifacts/sparkle/Sparkle/bin/sign_update"
GENERATE_KEYS_TOOL="${PROJECT_DERIVED_DATA_ROOT}/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_keys"
for tool in "$SIGN_UPDATE_TOOL" "$GENERATE_KEYS_TOOL"; do
    if [[ ! -x "$tool" ]]; then
        echo "Error: Sparkle tool not found: $tool"
        exit 1
    fi
done

if [[ -z "$SPARKLE_KEY_CONTENTS" ]]; then
    KEYCHAIN_PUB=$("$GENERATE_KEYS_TOOL" -p)
    if [[ "$APP_PUB" != "$KEYCHAIN_PUB" ]]; then
        echo "Error: SUPublicEDKey does not match the default Sparkle Keychain account"
        exit 1
    fi
fi

if [[ -n "$SPARKLE_KEY_CONTENTS" ]]; then
    RAW_SIG_OUT=$("$SIGN_UPDATE_TOOL" -s "$SPARKLE_KEY_CONTENTS" "$ZIP_PATH")
else
    RAW_SIG_OUT=$("$SIGN_UPDATE_TOOL" "$ZIP_PATH")
fi
SIGNATURE=$(sed -n 's/.*sparkle:edSignature="\([^"]*\)".*/\1/p' <<< "$RAW_SIG_OUT")
ZIP_SIZE=$(sed -n 's/.*length="\([^"]*\)".*/\1/p' <<< "$RAW_SIG_OUT")
SIGNATURE="${SIGNATURE:-$RAW_SIG_OUT}"
ZIP_SIZE="${ZIP_SIZE:-$(stat -f %z "$ZIP_PATH")}"
SIGNATURE=$(tr -d '\r\n' <<< "$SIGNATURE")
if [[ -z "$SIGNATURE" ]]; then
    echo "Error: sign_update returned no signature"
    exit 1
fi

PUB_DATE=$(date -R)
DOWNLOAD_URL="https://github.com/GINNOV/littlethings/raw/master/Amiga/Tools/releases/$ZIP_NAME"
cat > "$APPCAST_PATH" <<XML
<?xml version="1.0" encoding="utf-8"?>
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" version="2.0">
  <channel>
    <title>PixDeluxe Changelog</title>
    <item>
      <title>Version ${VERSION}</title>
      <description><![CDATA[${RELEASE_NOTES_CONTENT}]]></description>
      <pubDate>${PUB_DATE}</pubDate>
      <enclosure url="${DOWNLOAD_URL}" sparkle:version="${BUILD_NUMBER}" sparkle:shortVersionString="${VERSION}" length="${ZIP_SIZE}" type="application/octet-stream" sparkle:edSignature="${SIGNATURE}" />
    </item>
  </channel>
</rss>
XML

echo "Created DMG: ${DMG_FINAL_PATH}"
echo "Created ZIP: ${ZIP_PATH}"
echo "Updated appcast: ${APPCAST_PATH}"
