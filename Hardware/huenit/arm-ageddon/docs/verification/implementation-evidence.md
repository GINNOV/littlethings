# Implementation evidence

Historical record of the **dead camera-ml-app inspector** (webcam + F-gates).
It is not proof of Go play. Product spec is `docs/go-play.md`.

Source revision: `59f5fd5589cc5917fd13e6cff8374562a4bda56b`

## Credential-independent checks

- `swift test --disable-sandbox --parallel`: 118 tests in 23 suites passed.
- Final exact-SHA proof repeated the full 118-test suite and Debug app build successfully.
- `xcodebuild -project Armageddon.xcodeproj -scheme ArmageddonApp -configuration Debug -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build`: passed.
- Release build completed through `scripts/package-release.sh`; Developer ID packaging stopped with `BLOCKED_MISSING_SIGNING_CREDENTIAL` before DMG signing/notarization. The script now includes DMG creation, `notarytool`, stapling, and stapled-artifact validation when credentials are supplied.
- `scripts/validate-docs.sh`: passed.
- `scripts/verify-no-live-io-in-tests.sh`: passed.
- `scripts/check-motion-boundary.sh`: passed after compiler-negative, symbol-graph, and AST callsite checks.
- Independent read-only review findings were fixed for proposal-to-permit binding, workspace inset enforcement, capture rollback, model provenance, measured K210 capabilities, valid fixture JPEGs, empty-detection capture, and model-card accessibility.
- The fixture JPEG fallback records its actual 1×1 image dimensions; unimplemented retention/model-default/serial-opt-in settings were removed rather than exposed as no-ops; the visible English catalog now includes the principal Live, Capture, Models, Settings, and safety labels.
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
