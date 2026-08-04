#!/bin/bash
set -euo pipefail

PROJECT_NAME="ADFinder"
SCHEME="ADFinder"
CONFIGURATION="Release"
PROJECT_PATH=""
OUTPUT_PATH=""
INCLUDE_SOURCE=0

usage() {
    echo "usage: $0 [--project path] [--scheme name] [--configuration Debug|Release] [--unsigned] [--output directory] [--include-source]" >&2
    exit 2
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project) PROJECT_PATH="$2"; shift 2 ;;
        --scheme) SCHEME="$2"; shift 2 ;;
        --configuration) CONFIGURATION="$2"; shift 2 ;;
        --output) OUTPUT_PATH="$2"; shift 2 ;;
        --unsigned) shift ;;
        --include-source) INCLUDE_SOURCE=1; shift ;;
        *) usage ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
ADFinder_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
REPO_ROOT="$(cd "$ADFinder_ROOT/../../.." && pwd -P)"
PROJECT_PATH="${PROJECT_PATH:-$ADFinder_ROOT/ADFinder.xcodeproj}"
OUTPUT_PATH="${OUTPUT_PATH:-$ADFinder_ROOT/../releases}"
SOURCE_ROOT="${ADFLIB_VERIFIED_SOURCE_ROOT:?ADFLIB_VERIFIED_SOURCE_ROOT is required}"
ARCHITECTURE="$(uname -m)"
LOCKFILE="$ADFinder_ROOT/ADFinder.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
LOCK_DIGEST="$(shasum -a 256 "$LOCKFILE" | awk '{print $1}')"
ARTIFACT_ROOT="$(cd "$SOURCE_ROOT/../.." && pwd -P)"
SOURCE_PACKAGES="${ADFLIB_SWIFTPM_SOURCE_PACKAGES:-$ARTIFACT_ROOT/swiftpm/$LOCK_DIGEST/SourcePackages}"
BUILD_ROOT="$OUTPUT_PATH/.build"
ARCHIVE_PATH="$OUTPUT_PATH/$PROJECT_NAME.xcarchive"
APP_PATH="$OUTPUT_PATH/$PROJECT_NAME.app"

case "$ARCHITECTURE" in arm64|x86_64) ;; *) echo "unsupported_architecture: $ARCHITECTURE" >&2; exit 2 ;; esac
test -d "$SOURCE_ROOT" || { echo "verified_adflib_source_missing: $SOURCE_ROOT" >&2; exit 2; }
test -d "$SOURCE_PACKAGES" || { echo "swiftpm_closure_missing: $SOURCE_PACKAGES" >&2; exit 2; }
mkdir -p "$OUTPUT_PATH"
rm -rf "$BUILD_ROOT" "$ARCHIVE_PATH" "$APP_PATH"
mkdir -p "$BUILD_ROOT"

xcodebuild archive \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "platform=macOS,arch=$ARCHITECTURE" \
    -archivePath "$ARCHIVE_PATH" \
    -derivedDataPath "$BUILD_ROOT/DerivedData" \
    ARCHS="$ARCHITECTURE" \
    ONLY_ACTIVE_ARCH=YES \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    ADFLIB_VERIFIED_SOURCE_ROOT="$SOURCE_ROOT" \
    -clonedSourcePackagesDirPath "$SOURCE_PACKAGES" \
    -disableAutomaticPackageResolution

cp -R "$ARCHIVE_PATH/Products/Applications/$PROJECT_NAME.app" "$APP_PATH"
PROVENANCE="$APP_PATH/Contents/Resources/adflib-provenance.json"
test -f "$PROVENANCE" || { echo "adflib_provenance_missing" >&2; exit 2; }

if [[ "$INCLUDE_SOURCE" -eq 1 ]]; then
    SOURCE_STAGE="$BUILD_ROOT/corresponding-source"
    mkdir -p "$SOURCE_STAGE/Amiga/Tools" "$SOURCE_STAGE/third-party" "$SOURCE_STAGE/offline-swiftpm"
    cp -R "$ADFinder_ROOT" "$SOURCE_STAGE/Amiga/Tools/ADFinder"
    cp -R "$SOURCE_ROOT" "$SOURCE_STAGE/third-party/ADFlib"
    cp "$REPO_ROOT/Amiga/Tools/build-support/adflib/ADFlibDependency.cmake" "$SOURCE_STAGE/"
    cp -R "$SOURCE_PACKAGES" "$SOURCE_STAGE/offline-swiftpm/SourcePackages"
    cp "$LOCKFILE" "$SOURCE_STAGE/offline-swiftpm/Package.resolved"
    COPYFILE_DISABLE=1 tar -czf "$APP_PATH/Contents/Resources/ADFinder-corresponding-source.tar.gz" -C "$SOURCE_STAGE" .
    cp "$APP_PATH/Contents/Resources/ADFinder-corresponding-source.tar.gz" "$ARCHIVE_PATH/Products/Applications/$PROJECT_NAME.app/Contents/Resources/ADFinder-corresponding-source.tar.gz"
fi

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Contents/Info.plist")"
BUILD_NUMBER="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$APP_PATH/Contents/Info.plist")"
ZIP_PATH="$OUTPUT_PATH/$PROJECT_NAME-${VERSION}_${BUILD_NUMBER}.zip"
DMG_BASE="$OUTPUT_PATH/$PROJECT_NAME.dmg"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"
bash "$SCRIPT_DIR/gendmg.sh" \
    --readme "$ADFinder_ROOT/readme.md" \
    --app "$APP_PATH" \
    --dmg "$DMG_BASE" \
    --background "$SCRIPT_DIR/dmg_assets/dmg-background.png" \
    --volicon "$SCRIPT_DIR/dmg_assets/dmg-icon.icns"

DMG_PATH="$OUTPUT_PATH/$PROJECT_NAME-${VERSION}_${BUILD_NUMBER}.dmg"
test -f "$ZIP_PATH" && test -f "$DMG_PATH"
echo "adfinder_packages_ok app=$APP_PATH archive=$ARCHIVE_PATH dmg=$DMG_PATH zip=$ZIP_PATH"
