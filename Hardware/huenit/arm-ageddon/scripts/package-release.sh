#!/bin/sh

set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
output_root=${1:-}
identity=${ARMAGEDDON_DEVELOPER_IDENTITY:-}
notary_profile=${ARMAGEDDON_NOTARY_PROFILE:-}
[ -n "$output_root" ] || { printf '%s\n' 'ERROR[usage]: provide an absent external output root' >&2; exit 2; }
case "$output_root" in
    /*) ;;
    *) printf '%s\n' 'ERROR[output-root]: output root must be absolute' >&2; exit 2 ;;
esac
output_root=$(CDPATH= cd -- "$(dirname -- "$output_root")" && pwd -P)/$(basename -- "$output_root")
case "$output_root" in
    "$project_root"|"$project_root"/*) printf '%s\n' 'ERROR[output-root]: release artifacts must be external to the source project' >&2; exit 2 ;;
esac
parent_root=$(dirname -- "$output_root")
[ -d "$parent_root" ] || { printf '%s\n' 'ERROR[output-root]: output parent must already exist' >&2; exit 2; }
mkdir -m 700 "$output_root"
build_root="$output_root/DerivedData"
app="$build_root/Build/Products/Release/Armageddon.app"

xcodebuild -project "$project_root/Armageddon.xcodeproj" -scheme ArmageddonApp \
    -configuration Release -destination 'platform=macOS,arch=arm64' \
    -derivedDataPath "$build_root" CODE_SIGNING_ALLOWED=NO build

[ -d "$app" ] || { printf '%s\n' 'ERROR[release-artifact]: Release app was not produced' >&2; exit 1; }
codesign --force --deep --options runtime --sign - \
    --entitlements "$project_root/Sources/ArmageddonApp/App/ArmageddonApp.entitlements" "$app"
codesign --verify --deep --strict "$app"
codesign -d --entitlements :- "$app" >"$output_root/entitlements.plist" 2>/dev/null
plutil -p "$output_root/entitlements.plist" | grep -Eq '"com\.apple\.security\.device\.camera" => (true|1)'
if grep -Eq 'com\.apple\.security\.(app-sandbox|device\.usb|device\.serial|device\.microphone)' "$output_root/entitlements.plist"; then
    printf '%s\n' 'ERROR[entitlements]: forbidden sandbox, USB, serial, or microphone entitlement present' >&2
    exit 1
fi
python3 "$project_root/scripts/audit-network.py" \
    --app "$app" --allowlist "$project_root/Tests/Fixtures/network-static-allowlist.json" \
    --receipt "$output_root/network-audit.json"
python3 "$project_root/scripts/write-bundle-manifest.py" \
    --bundle "$app" --root "$output_root" --output "$output_root/bundle-manifest.json"
printf '{"schemaVersion":1,"kind":"sbom","app":"%s","sourceFiles":[' "$app" >"$output_root/sbom.json"
find "$project_root/Sources" -type f -print | LC_ALL=C sort | awk 'BEGIN { first=1 } { gsub(/\\/,"\\\\"); gsub(/"/,"\\\""); if (!first) printf ","; printf "\"%s\"", $0; first=0 }' >>"$output_root/sbom.json"
printf '],"runtimeDependencies":[],"outcome":"PASS"}\n' >>"$output_root/sbom.json"
shasum -a 256 "$output_root/bundle-manifest.json" "$output_root/sbom.json" "$output_root/entitlements.plist" "$output_root/network-audit.json" >"$output_root/release-artifacts.sha256"

if [ -z "$identity" ]; then
    printf '{"schemaVersion":1,"kind":"release-classification","classification":"BLOCKED_MISSING_SIGNING_CREDENTIAL","adHocVerified":true,"distributionSigned":false,"notarized":false}\n' >"$output_root/release-classification.json"
    printf '%s\n' 'BLOCKED_MISSING_SIGNING_CREDENTIAL: ad-hoc artifact checks passed; set ARMAGEDDON_DEVELOPER_IDENTITY for Developer ID packaging' >&2
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
printf '{"schemaVersion":1,"kind":"release-classification","classification":"PASS","adHocVerified":true,"distributionSigned":true,"notarized":true}\n' >"$output_root/release-classification.json"

printf '%s\n' "PASS: signed release at $output_root/Armageddon.zip"
