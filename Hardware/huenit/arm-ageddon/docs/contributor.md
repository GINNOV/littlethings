# Contributor guide

Read `AGENTS.md` and `docs/go-play.md` first. Do not implement `camera-ml-app`.

Use Swift 6 strict concurrency. Mutable I/O stays in actors. New UI state is
`@MainActor @Observable`. Views do not construct hardware, storage, clocks, or
inference clients. Runtime dependencies are Apple frameworks only. The cappella
client is HTTP to a LAN OpenAI-compatible endpoint, not a cloud SDK.

Ordinary tests use recorded fixtures and must not enumerate USB devices,
request real camera permission, open `/dev/cu.*`, write hardware commands, or
depend on a network. Live-arm schemes stay separately named and gated.

Run `swift test --parallel`, `./scripts/validate-docs.sh`, and
`./scripts/check-motion-boundary.sh` before submitting. Do not add `G28`,
cloud transport, raw G-code entry, K210 preview/upload claims without a new
measured protocol, or a webcam-as-eye path.

Keep extending `ArmageddonMotionBoundary` for serial/STOP/vacuum. Do not grow
Core ML / native capture as the robot’s eye.
