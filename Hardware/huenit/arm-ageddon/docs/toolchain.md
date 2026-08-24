# Toolchain and build graph

## Canonical configuration

- Package manifest: Swift tools 6.2, Swift language mode 6, macOS 15 minimum.
- Reference IDE: Xcode 26.6 (build 17F113).
- Verified compiler: Apple Swift 6.3.3 supplied by Xcode 26.6.
- Concurrency: complete strict-concurrency checking in SwiftPM and Xcode.
- Runtime dependencies: Apple SDKs and the local `ArmageddonCore` product only.
  Go play additionally uses LAN HTTP to cappella Qwen; that client must be
  injectable so ordinary tests never hit the network.
- Release architecture: arm64.

`Package.swift` owns `ArmageddonCore`, the non-product
`ArmageddonMotionBoundary` target, and `ArmageddonCoreTests`.
`Armageddon.xcodeproj` owns only the `ArmageddonApp` application and
`ArmageddonUITests` UI-test bundle. The app links the local `ArmageddonCore`
package product; package sources are not members of an Xcode sources phase.

## External build roots

Keep SwiftPM scratch directories and Xcode DerivedData outside the checkout.
The baseline commands are:

```sh
swift package --scratch-path "$ARMAGEDDON_QA_BUILD_ROOT/describe" describe
xcodebuild -list -project Armageddon.xcodeproj
swift build --scratch-path "$ARMAGEDDON_QA_BUILD_ROOT/swiftpm"
xcodebuild -project Armageddon.xcodeproj -scheme ArmageddonApp \
  -destination 'platform=macOS' \
  -derivedDataPath "$ARMAGEDDON_QA_BUILD_ROOT/xcode" build
```

Run `scripts/check-source-boundary.sh` before committing build-graph changes.
