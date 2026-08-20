#!/bin/sh

set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
output_root=${1:-"$project_root/.release"}
identity=${ARMAGEDDON_DEVELOPER_IDENTITY:-}
notary_profile=${ARMAGEDDON_NOTARY_PROFILE:-}
build_root="$output_root/DerivedData"
app="$build_root/Build/Products/Release/Armageddon.app"

mkdir -p "$output_root"
xcodebuild -project "$project_root/Armageddon.xcodeproj" -scheme ArmageddonApp \
    -configuration Release -destination 'platform=macOS,arch=arm64' \
    -derivedDataPath "$build_root" CODE_SIGNING_ALLOWED=NO build

if [ -z "$identity" ]; then
    printf '%s\n' 'BLOCKED_MISSING_SIGNING_CREDENTIAL: set ARMAGEDDON_DEVELOPER_IDENTITY for Developer ID packaging' >&2
    exit 3
fi

codesign --force --deep --options runtime --sign "$identity" \
    --entitlements "$project_root/Sources/ArmageddonApp/App/ArmageddonApp.entitlements" "$app"
codesign --verify --deep --strict "$app"
spctl --assess --type execute "$app"
ditto -c -k --keepParent "$app" "$output_root/Armageddon.zip"
shasum -a 256 "$output_root/Armageddon.zip" > "$output_root/Armageddon.zip.sha256"

hdiutil create -volname Armageddon -srcfolder "$app" -ov -format UDZO "$output_root/Armageddon.dmg"
if [ -z "$notary_profile" ]; then
    printf '%s\n' 'BLOCKED_MISSING_NOTARY_CREDENTIAL: set ARMAGEDDON_NOTARY_PROFILE for notarization' >&2
    exit 4
fi
xcrun notarytool submit "$output_root/Armageddon.dmg" --keychain-profile "$notary_profile" --wait
xcrun stapler staple "$output_root/Armageddon.dmg"
xcrun stapler validate "$output_root/Armageddon.dmg"
shasum -a 256 "$output_root/Armageddon.dmg" > "$output_root/Armageddon.dmg.sha256"

printf '%s\n' "PASS: signed release at $output_root/Armageddon.zip"
