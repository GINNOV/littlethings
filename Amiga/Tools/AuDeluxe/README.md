# AuDeluxe

AuDeluxe is a macOS 14 or later tracker-module library and player. It scans a
chosen music folder, reads module metadata with libopenmpt, supports playlists,
sorting, search, ratings, shuffle and repeat, and supplies Finder Quick Look
previews.

## Supported formats

MOD, S3M, XM, IT, MED, OKT, MTM, 669, DSM, FAR, PTM, ULT, AMF, AMS, DBM, DMF,
IMF, J2B, MDL, MO3, PSM, STM, STX and UMX.

## Build

Requirements:

- Xcode with the macOS 14 SDK or later
- macOS 14 or later

The repository includes a universal, pinned libopenmpt archive and its headers,
so building the app and Quick Look extension does not require Homebrew:

```sh
xcodebuild build \
  -project AuDeluxe.xcodeproj \
  -scheme AuDeluxe \
  -destination 'platform=macOS'
```

The archive contains both `arm64` and `x86_64`. To reproduce it, run
`Libraries/build_libopenmpt.sh`; the script downloads and verifies the pinned
upstream source before compiling both architectures.

Run the automated suite with:

```sh
xcodebuild test \
  -project AuDeluxe.xcodeproj \
  -scheme AuDeluxe \
  -destination 'platform=macOS'
```

## Release packaging

`distribution/build_and_package.sh` creates a universal release archive, DMG,
Sparkle ZIP and appcast entry. `create-dmg` must already be installed, and
Sparkle signing requires either its keychain key or `SPARKLE_PRIVATE_KEY` /
`SPARKLE_PRIVATE_KEY_PATH`. The app's public key is checked against the private
key before the feed is changed.
