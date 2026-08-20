#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
TEST_BUNDLE="${BUILD_DIR}/AmigaLoginScreenUITests.xctest"

echo "🧪 ========================================"
echo "🧪 Compiling & Running Native Apple XCTest"
echo "🧪 ========================================"

mkdir -p "${BUILD_DIR}/.module-cache"
mkdir -p "${TEST_BUNDLE}/Contents/MacOS"

DEVELOPER_DIR="$(xcode-select -p)"
SDK_PATH="$(xcrun --show-sdk-path)"
XCTEST_FRAMEWORKS="${DEVELOPER_DIR}/Platforms/MacOSX.platform/Developer/Library/Frameworks"
XCTEST_USRLIB="${DEVELOPER_DIR}/Platforms/MacOSX.platform/Developer/usr/lib"

# Create Info.plist for XCTest bundle
cat << 'EOF' > "${TEST_BUNDLE}/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>AmigaLoginScreenUITests</string>
    <key>CFBundleIdentifier</key>
    <string>org.amiga.tools.AmigaLoginScreenUITests</string>
    <key>CFBundlePackageType</key>
    <string>BNDL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.1</string>
    <key>CFBundleVersion</key>
    <string>1.0.1</string>
</dict>
</plist>
EOF

# Compile XCTest Bundle
echo "⚙️ Compiling XCTest bundle with swiftc..."
swiftc -module-cache-path "${BUILD_DIR}/.module-cache" \
    -sdk "${SDK_PATH}" \
    -target arm64-apple-macos11.0 \
    -emit-library \
    -enable-testing \
    -F "${XCTEST_FRAMEWORKS}" \
    -I "${XCTEST_USRLIB}" \
    -L "${XCTEST_USRLIB}" \
    -framework XCTest \
    "${SCRIPT_DIR}/EmbeddedPresets.swift" \
    "${SCRIPT_DIR}/AppCore.swift" \
    "${SCRIPT_DIR}/UITests.swift" \
    -o "${TEST_BUNDLE}/Contents/MacOS/AmigaLoginScreenUITests"

# Ad-hoc sign test bundle
codesign --force --sign - "${TEST_BUNDLE}"

# Run XCTest
echo "🚀 Executing native XCTest suite via xcrun xctest..."
xcrun xctest "${TEST_BUNDLE}"

echo "========================================"
echo "🎉 XCTest Suite Finished Successfully!"
echo "========================================"
