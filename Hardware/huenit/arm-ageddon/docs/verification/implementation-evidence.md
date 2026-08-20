# Implementation evidence

Source revision: `9f655e9531e2448d3f96825565040f642586c548`

## Credential-independent checks

- `swift test --disable-sandbox --parallel`: 116 tests in 23 suites passed.
- `xcodebuild -project Armageddon.xcodeproj -scheme ArmageddonApp -configuration Debug -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build`: passed.
- Release build completed through `scripts/package-release.sh`; Developer ID packaging stopped with `BLOCKED_MISSING_SIGNING_CREDENTIAL`.
- `scripts/validate-docs.sh`: passed.
- `scripts/verify-no-live-io-in-tests.sh`: passed.
- `scripts/check-motion-boundary.sh`: passed after compiler-negative, symbol-graph, and AST callsite checks.
- `xcodebuild -list` resolves the ordinary app scheme and the separately named `LiveCameraAcceptance` and `LiveArmAcceptance` schemes.

## Measured protocol evidence

The recorded HUENIT fixture proves line-oriented 115200 serial telemetry with
rectangle detections. It does not prove preview or upload, so those capabilities
remain unsupported and the Models workflow labels K210 as detection-only.

## Manual and hardware limits

Fresh visual inspection was attempted against the fixture launch profile, but
the desktop automation layer reported that the Mac was locked and could not
unlock it. No screenshot or manual UI pass is claimed. No physical camera,
K210, arm, Developer ID identity, notarization credential, or operator hardware
acceptance was available in this environment.
