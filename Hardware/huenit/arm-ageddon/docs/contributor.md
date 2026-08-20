# Contributor guide

Use Swift 6 strict concurrency and keep mutable I/O inside actors. New UI
state is `@MainActor @Observable`; views do not construct hardware, storage,
clocks, or inference services. Runtime dependencies are Apple frameworks only.

Ordinary tests use recorded fixtures and must not enumerate USB devices,
request real camera permission, open `/dev/cu.*`, write hardware commands, or
depend on a network. The live-camera and live-arm schemes are separately
named and guarded; they require explicit operator environment gates and are
never part of the ordinary test suite.

Run `swift test --parallel`, the Armageddon app build, `./scripts/validate-docs.sh`,
and `./scripts/check-motion-boundary.sh` before submitting changes. Do not add
`G28`, cloud transport, automatic capture, raw G-code entry, or a K210
preview/upload claim without a new measured protocol record and review.
