# Arm-ageddon

Native Swift **body** for a HUENIT arm on macOS. The product is **Go play**:
the K210 on the arm reads the board, a DGX (cappella) chooses the reply, this
app places a stone with the suction cup. Spec: [`docs/go-play.md`](docs/go-play.md).
Agent briefing: [`AGENTS.md`](AGENTS.md).

This is not a webcam inspector. Do not resume the dead `camera-ml-app` plan.

## What you get today vs next

**Today (substrate, keep):** USB serial at 115200, HUENIT Marlin identity,
pose query, bounded `G1` jogs, vacuum `M1400`, priority STOP (`M1400 A0` then
`M410`), hard `G28` refusal, recorded serial fixtures, tests that never open
live hardware.

**Next (Go loop):** taught survey pose, K210 **grid over UART**, POST to
cappella Qwen, **I moved** + confirm, bowl → pick → place. No Mac webcam is
required.

## Hard rules

- Never send Marlin `G28`.
- Software STOP is a request until firmware confirms; if STOP is unconfirmed,
  use the physical power cutoff.
- Ordinary tests must not enumerate USB, open `/dev/cu.*`, request camera
  permission, or write the arm.
- The K210 is detection-only for motion (grid out, no G-code). Preview and
  in-app upload are unmeasured.
- Inference on cappella is LAN-only (`192.168.0.69:8888`). Not cloud.

## Layout

- `Sources/ArmageddonMotionBoundary/` — serial, pose, jog, vacuum, STOP
  (non-product target; app reaches it only through the fail-closed facade).
- `Sources/ArmageddonCore/` — devices, calibration math, safety types, K210
  inventory. Vision/Core ML here is leftover from the inspector; do not grow it
  as the robot’s eye.
- `Sources/ArmageddonApp/` — macOS UI. Go play embeds the Joy1 pendant
  (`../joy1`) for connect, jog, vacuum, and STOP.
- `Tests/Fixtures/Serial/` — recorded arm and camera lines.

## Build

macOS 15+, Xcode 26.6, Swift 6, arm64. Apple SDKs only at runtime.

```sh
swift test --parallel
./scripts/validate-docs.sh
./scripts/check-motion-boundary.sh
```

Keep DerivedData / `.build` outside the checkout.

## Cappella (decision host)

| | |
| --- | --- |
| Host | DGX Spark `cappella` · `192.168.0.69` · Tailscale `100.66.9.68` |
| User | `govworks` · `ssh sync-192_168_0_69` |
| Qwen | SGLang `qwen3.8-27b-sglang` · port **8888** · `http://192.168.0.69:8888/v1` |
| Do not | Run Gemma vLLM (`:8000`) at the same time; copy `gopponent`’s `G28` dry-run |

## Protocol notes

- Pose: `M1008` / `M114`. Relative mode `G91`, mm `G21`.
- Vacuum: `M1400 A1023` / `M1400 A0` (Hackaday / Python profile). Do not silently
  fall back to `M1114` without a measured profile.
- STOP: vacuum off, then `M410`; `M84` only after explicit `M410` rejection.

## Docs

| Doc | |
| --- | --- |
| [`docs/go-play.md`](docs/go-play.md) | Product loop |
| [`docs/operator.md`](docs/operator.md) | How to run, cutoff |
| [`docs/safety.md`](docs/safety.md) | Motion policy |
| [`docs/model-k210.md`](docs/model-k210.md) | K210 UART vs upload |
| [`docs/contributor.md`](docs/contributor.md) | Tests and boundaries |
| [`docs/privacy.md`](docs/privacy.md) | Local data, no cloud |
