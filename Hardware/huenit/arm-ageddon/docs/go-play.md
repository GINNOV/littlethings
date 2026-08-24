# Go play with HUENIT

This is the product. The old camera-ml inspector is not.

## Goal

A 9×9 (later 19×19) go board sits in the arm’s reach. A human plays a stone, tells the Mac app **I moved** without naming the point. The arm’s K210 camera looks, the DGX chooses a reply, the suction cup places a stone.

## Roles

```
human stone
    → Mac: "I moved"
    → arm: survey pose
    → K210: board grid over UART (detection-only; no video to the Mac)
    → Mac POST ASCII grid to cappella
    → Qwen: one legal intersection
    → human confirms
    → Mac recipe: bowl → suction on → lift → intersection → suction off → retract
    → STOP always available
```

- **Eye:** HUENIT AI Camera (K210) on the arm. Not a Mac/USB webcam.
- **Brain:** NVIDIA DGX Spark **cappella** (`192.168.0.69`, Tailscale `100.66.9.68`). Qwen3.8-27B via SGLang on port **8888**, served name `qwen3.8-27b-sglang`, OpenAI-compatible `POST /v1/chat/completions`. Gemma vLLM on `:8000` is a different stack; **do not run both**. LAN, no auth — trusted network only. This is not a cloud service.
- **Body:** this macOS app owns serial, pose, vacuum (`M1400`), STOP (`M410`), and the pick-place recipe. Connect/jog/vacuum/STOP are the **Joy1 pendant** (same UI as Joy1/Joy2). The DGX never receives raw G-code. Auto Connect is Joy1 `PortDetector` (HUEARM, never HUECAM).

## Cappella (from house infra)

| Item | Value |
| --- | --- |
| Host | `cappella` · Ubuntu 24.04 · DGX Spark · user `govworks` |
| SSH | `ssh sync-192_168_0_69` · key NVIDIA Sync `nvsync.key` |
| Qwen | container `qwen3.8-27b-sglang` · `http://192.168.0.69:8888/v1` |
| Home | `/home/govworks` · prior scaffold `~/gopponent` |

`gopponent` on cappella is an earlier dry-run scaffold (OpenCV, first-empty-point, and a dry-run that printed `G28`). **Do not copy its motion lines.** Reuse the idea of a Go/arm project on that box only as a decision service later if useful. Arm motion stays on the Mac.

## K210

Official HUENIT: the AI camera cannot sit on PC USB and arm USB at once. Load/train a model by plugging USB-C into a host, then put the camera back on the arm. At runtime the Mac sees **UART lines**, not 320×240 preview.

Today’s checked-in fixture is rectangles (`frame=target,x,y,w,h`). Next measurement is a **grid schema** (rows of stone/empty/color) plus a taught survey pose. Until that transcript exists, do not claim a live board reader.

Image classification on HUENIT OS is WHAT (class in a fixed square), not WHERE. The grid is WHERE. Classification is not a substitute for a board-state model.

## Motion / safety

- Never `G28`. The arm has no limit switches.
- STOP: vacuum off then `M410`; if unconfirmed, use the physical power cutoff.
- Pick-place is an explicit confirmed **recipe** (Z + suction), not a 20 mm XY nudge from a webcam box.
- Old SafetyPolicyV1 (XY-only, ≤20 mm, native-camera frames only, no suction) is **legacy** for the dead inspector. Go play replaces it with: legal grid delta, survey pose, confirmed recipe, workspace polygon, safe Z, feed cap, one-use confirm.
- K210 remains **detection-only** for actuation: it must not write the serial arm port.

## Out of scope

Unattended games, webcam-as-eye, Core ML as the robot’s eye, K210 preview/upload without a new measured protocol, G-code paste, cloud APIs, 19×19 as the first slice, running the arm from Linux on cappella.
