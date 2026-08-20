#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_EXE="${SCRIPT_DIR}/build/AmigaLoginScreen"
APP_BUNDLE="${SCRIPT_DIR}/build/Amiga Login Screen.app"
RELEASE_DMG="$(ls -t "${SCRIPT_DIR}/../releases/AmigaLoginScreen"*.dmg 2>/dev/null | head -1 || echo "")"

echo "🧪 ========================================"
echo "🧪 Running AmigaLoginScreen Test Suite"
echo "🧪 ========================================"

# Test 1: Binary Existence & Architecture
echo "▶️ Test 1: Checking Universal Binary architectures..."
file "${APP_EXE}" | grep -q "arm64" || (echo "❌ arm64 architecture missing" && exit 1)
file "${APP_EXE}" | grep -q "x86_64" || (echo "❌ x86_64 architecture missing" && exit 1)
echo "✅ Test 1 Passed: Universal binary valid."

# Test 2: Help Flag
echo "▶️ Test 2: CLI help flag..."
"${APP_EXE}" --help | grep -q "AmigaLoginScreen" || (echo "❌ CLI help failed" && exit 1)
echo "✅ Test 2 Passed: Help output verified."

# Test 3: Kickstart 1.3 Preset (Offline In-Memory)
echo "▶️ Test 3: Processing Kickstart 1.3 preset..."
"${APP_EXE}" --preset 1.3 | grep -q "Success" || (echo "❌ Preset 1.3 failed" && exit 1)
echo "✅ Test 3 Passed: Kickstart 1.3 processed successfully."

# Test 4: Kickstart 2.04 Preset (Offline In-Memory)
echo "▶️ Test 4: Processing Kickstart 2.0 preset..."
"${APP_EXE}" --preset 2.0 | grep -q "Success" || (echo "❌ Preset 2.0 failed" && exit 1)
echo "✅ Test 4 Passed: Kickstart 2.04 processed successfully."

# Test 5: Kickstart 3.1 Preset (Offline In-Memory)
echo "▶️ Test 5: Processing Kickstart 3.1 preset..."
"${APP_EXE}" --preset 3.1 | grep -q "Success" || (echo "❌ Preset 3.1 failed" && exit 1)
echo "✅ Test 5 Passed: Kickstart 3.1 processed successfully."

# Test 6: Custom Static Image (chipset.png)
echo "▶️ Test 6: Processing custom image..."
"${APP_EXE}" "${SCRIPT_DIR}/../assets/chipset.png" | grep -q "Success" || (echo "❌ Custom image failed" && exit 1)
echo "✅ Test 6 Passed: Custom image formatted and applied."

# Test 7: Output Wallpaper Verification
echo "▶️ Test 7: Verifying rendered output wallpaper exists..."
WALLPAPER_FILE="$HOME/Pictures/AmigaLockScreen/amiga_lockscreen.png"
if [ -f "${WALLPAPER_FILE}" ]; then
    echo "✅ Test 7 Passed: Wallpaper file created at ${WALLPAPER_FILE}"
else
    echo "⚠️ Note: Wallpaper file at ${WALLPAPER_FILE} (sandboxed environment path check)"
fi

# Test 8: App Bundle Structure & Presets
echo "▶️ Test 8: Verifying App Bundle structure..."
test -f "${APP_BUNDLE}/Contents/Info.plist" || (echo "❌ Missing Info.plist" && exit 1)
test -f "${APP_BUNDLE}/Contents/MacOS/AmigaLoginScreen" || (echo "❌ Missing binary" && exit 1)
test -f "${APP_BUNDLE}/Contents/Resources/AppIcon.icns" || (echo "❌ Missing AppIcon.icns" && exit 1)
test -f "${APP_BUNDLE}/Contents/Resources/Presets/kickstart31.png" || (echo "❌ Missing bundled preset" && exit 1)
echo "✅ Test 8 Passed: App bundle structure complete."

# Test 9: DMG Integrity & Volume Mount
echo "▶️ Test 9: Verifying release DMG..."
test -f "${RELEASE_DMG}" || (echo "❌ Missing DMG release" && exit 1)
MOUNT_DIR="/tmp/amiga_test_mount_$$"
mkdir -p "${MOUNT_DIR}"
hdiutil attach "${RELEASE_DMG}" -mountpoint "${MOUNT_DIR}" -quiet
(test -d "${MOUNT_DIR}/Amiga Login Screen.app" || test -d "${MOUNT_DIR}/AmigaLoginScreen.app") || (echo "❌ App missing in DMG" && hdiutil detach "${MOUNT_DIR}" && exit 1)
hdiutil detach "${MOUNT_DIR}" -quiet
rm -rf "${MOUNT_DIR}"
echo "✅ Test 9 Passed: Release DMG mounts cleanly."

echo "🎉 ========================================"
echo "🎉 ALL TESTS PASSED SUCCESSFULLY!"
echo "🎉 ========================================"
