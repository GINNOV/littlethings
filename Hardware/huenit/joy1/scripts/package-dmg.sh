#!/bin/zsh
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
version="${1:-1.0.0}"
derived="$root/dist/DerivedData"
stage="$root/dist/dmg-stage"
dmg="$root/dist/Joy1-${version}.dmg"

rm -rf "$derived" "$stage"
mkdir -p "$stage"

xcodebuild \
  -project "$root/Joy1.xcodeproj" \
  -scheme Joy1App \
  -configuration Release \
  -derivedDataPath "$derived" \
  -destination 'platform=macOS,arch=arm64' \
  ARCHS=arm64 \
  ONLY_ACTIVE_ARCH=YES \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_ALLOWED=YES \
  build

app="$(find "$derived/Build/Products/Release" -maxdepth 1 -name '*.app' | head -1)"
if [[ -z "$app" ]]; then
  echo "Release .app not found" >&2
  exit 1
fi

cp -R "$app" "$stage/Joy1.app"
ln -s /Applications "$stage/Applications"

rm -f "$dmg"
hdiutil create \
  -volname "Joy1 ${version}" \
  -srcfolder "$stage" \
  -ov \
  -format UDZO \
  "$dmg"

echo "Created $dmg"
