#!/usr/bin/env bash
set -e

APP_NAME="AmigaLoginScreen"
DISPLAY_NAME="Amiga Login Screen"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
RELEASE_DIR="${SCRIPT_DIR}/../releases"
APP_BUNDLE="${BUILD_DIR}/${DISPLAY_NAME}.app"

# 1. Auto-increment build number
BUILD_FILE="${SCRIPT_DIR}/.build_number"
if [ ! -f "${BUILD_FILE}" ]; then
    CURRENT_BUILD_NUM=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${SCRIPT_DIR}/Info.plist" 2>/dev/null || echo "0")
    if [[ "$CURRENT_BUILD_NUM" =~ ^[0-9]+$ ]]; then
        BUILD_NUMBER=$((CURRENT_BUILD_NUM + 1))
    else
        BUILD_NUMBER=1
    fi
else
    BUILD_NUMBER=$(cat "${BUILD_FILE}")
    BUILD_NUMBER=$((BUILD_NUMBER + 1))
fi
echo "${BUILD_NUMBER}" > "${BUILD_FILE}"

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${SCRIPT_DIR}/Info.plist" 2>/dev/null || echo "1.0.1")
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${BUILD_NUMBER}" "${SCRIPT_DIR}/Info.plist"

echo "========================================"
echo " Building ${APP_NAME} v${VERSION} (Build ${BUILD_NUMBER})"
echo "========================================"

mkdir -p "${BUILD_DIR}/.module-cache"
mkdir -p "${RELEASE_DIR}"

# 2. Generate icon if missing
if [ ! -f "${SCRIPT_DIR}/AppIcon.icns" ]; then
    echo "🎨 Generating AppIcon.icns..."
    python3 "${SCRIPT_DIR}/generate_icon.py"
fi

# 3. Ensure Presets & Embedded Swift source exist
if [ ! -f "${SCRIPT_DIR}/Presets/kickstart31.png" ]; then
    echo "🎨 Generating Kickstart presets..."
    python3 "${SCRIPT_DIR}/create_presets.py"
fi

python3 -c "
import base64, os
code = '''// Generated embedded presets
import Foundation

struct EmbeddedPresets {
'''
for name in ['kickstart13', 'kickstart20', 'kickstart31']:
    p = os.path.join('${SCRIPT_DIR}/Presets', f'{name}.png')
    with open(p, 'rb') as f:
        data = f.read()
    b64 = base64.b64encode(data).decode('ascii')
    code += f'    static let {name}Base64 = \"{b64}\"\n'

code += '''
    static func getData(for name: String) -> Data? {
        let b64: String
        switch name {
        case \"kickstart13\": b64 = kickstart13Base64
        case \"kickstart20\": b64 = kickstart20Base64
        case \"kickstart31\": b64 = kickstart31Base64
        default: return nil
        }
        return Data(base64Encoded: b64)
    }
}
'''
with open('${SCRIPT_DIR}/EmbeddedPresets.swift', 'w') as f:
    f.write(code)
"

# 4. Compile Universal Binary (arm64 + x86_64)
echo "⚙️ Compiling Swift source for Apple Silicon (arm64)..."
swiftc -module-cache-path "${BUILD_DIR}/.module-cache" \
    -O -target arm64-apple-macos11.0 \
    "${SCRIPT_DIR}/EmbeddedPresets.swift" "${SCRIPT_DIR}/AppCore.swift" "${SCRIPT_DIR}/main.swift" \
    -o "${BUILD_DIR}/${APP_NAME}-arm64"

echo "⚙️ Compiling Swift source for Intel (x86_64)..."
swiftc -module-cache-path "${BUILD_DIR}/.module-cache" \
    -O -target x86_64-apple-macos11.0 \
    "${SCRIPT_DIR}/EmbeddedPresets.swift" "${SCRIPT_DIR}/AppCore.swift" "${SCRIPT_DIR}/main.swift" \
    -o "${BUILD_DIR}/${APP_NAME}-x86_64"

echo "🔗 Creating Universal Binary..."
lipo -create -output "${BUILD_DIR}/${APP_NAME}" \
    "${BUILD_DIR}/${APP_NAME}-arm64" \
    "${BUILD_DIR}/${APP_NAME}-x86_64"

# 5. Assemble .app Bundle
echo "📦 Assembling macOS Application Bundle..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources/Presets"

cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
cp "${SCRIPT_DIR}/Info.plist" "${APP_BUNDLE}/Contents/Info.plist"
cp "${SCRIPT_DIR}/AppIcon.icns" "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
cp -R "${SCRIPT_DIR}/Presets/"* "${APP_BUNDLE}/Contents/Resources/Presets/"

# 6. Ad-hoc Codesign
echo "🔏 Signing application bundle..."
codesign --force --deep --sign - "${APP_BUNDLE}"

# 7. Run Native XCTest & Integration Tests
echo "🧪 Running Test Suites..."
"${SCRIPT_DIR}/run_xctest.sh"
"${SCRIPT_DIR}/tests.sh"

# 8. Create Distribution ZIP
echo "📦 Creating Release ZIP..."
ZIP_NAME="${APP_NAME}-${VERSION}_${BUILD_NUMBER}.zip"
ZIP_PATH="${RELEASE_DIR}/${ZIP_NAME}"
rm -f "${ZIP_PATH}"
(cd "${BUILD_DIR}" && ditto -c -k --keepParent "${DISPLAY_NAME}.app" "${ZIP_PATH}")

# 9. Create Distribution DMG
echo "💿 Creating Release DMG..."
DMG_NAME="${APP_NAME}-${VERSION}_${BUILD_NUMBER}.dmg"
DMG_PATH="${RELEASE_DIR}/${DMG_NAME}"
rm -f "${DMG_PATH}"

DMG_TMP="${BUILD_DIR}/dmg_staging"
rm -rf "${DMG_TMP}"
mkdir -p "${DMG_TMP}"
cp -R "${APP_BUNDLE}" "${DMG_TMP}/"
ln -s /Applications "${DMG_TMP}/Applications"

hdiutil create -volname "${DISPLAY_NAME}" -srcfolder "${DMG_TMP}" -ov -format UDZO "${DMG_PATH}"
rm -rf "${DMG_TMP}"

# Clean up root stale binaries if any
rm -f "${SCRIPT_DIR}/${APP_NAME}" "${SCRIPT_DIR}/${APP_NAME}-arm64" "${SCRIPT_DIR}/${APP_NAME}-x86_64"

echo "========================================"
echo "✅ Build & Release Complete!"
echo "📦 App Bundle: ${APP_BUNDLE}"
echo "📁 Release ZIP: ${ZIP_PATH}"
echo "💿 Release DMG: ${DMG_PATH}"
echo "========================================"
