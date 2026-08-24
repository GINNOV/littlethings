# Armageddon — agent briefing

Read this before `camera-ml-app`, Live source combos, or F1–F4.

## What this repo is

macOS **body** for a HUENIT arm: USB serial, pose, bounded jogs, vacuum, priority STOP.
The **product aim** is Go play. Spec: `docs/go-play.md`. Plan: `.omo/plans/go-play-huenit.md` (gitignored mirror of that spec).

It is **not** a webcam ML inspector. The Codex plan `camera-ml-app` is **dead**. Do not resume its todos, do not tick F1–F4, do not treat Native camera / Recorded fixture / Fixture detector as the product.

## Loop (do not invent another)

1. Human places a stone, taps **I moved** (does not name the intersection).
2. Arm goes to a taught survey pose. The **K210 on the arm** reads the board.
3. K210 sends a **grid over UART** (not a video stream, not a Mac webcam).
4. This Mac app POSTs the grid to **cappella** (DGX Spark). **Qwen** chooses the reply intersection.
5. Human confirms once. Suction pick from a taught bowl pose → place → release.
6. STOP is always live. Never `G28`.

## Machine split

| Role | Where | Notes |
| --- | --- | --- |
| Serial / STOP / vacuum / recipes | **This Mac app** | Keep `ArmageddonMotionBoundary`. Do not give the DGX raw G-code. |
| Board eye | **HUENIT AI Camera (K210)** on the arm | Detection-only for motion: grid out, never writes the arm. No UVC required. |
| Move decision | **cappella** Qwen3.8-27B SGLang | `http://192.168.0.69:8888/v1` · model `qwen3.8-27b-sglang` · LAN, no API key. Tailscale `100.66.9.68`. Exclusive with Gemma vLLM on `:8000`. |
| Prior Go scaffold | Cappella `~/gopponent` | Dev only. Dry-run historically emitted `G28` — **do not copy that**. Do not run the arm from Linux in this plan. |

SSH to cappella (ops only; inference is HTTP): `ssh sync-192_168_0_69` or `govworks@192.168.0.69` with NVIDIA Sync key. User `govworks`. Do not stop `qwen3.8-27b-sglang` casually; do not start Gemma (`vllm_node`) at the same time.

## Keep vs ignore in this tree

**Keep / extend:** `Sources/ArmageddonMotionBoundary/**` (serial, pose, `G1`, `M1400`, STOP `M410`, `G28` refusal, fake serial tests).

**Do not build on as the product:** Live native-camera preview, fixture detector theatre, Capture-as-hero, Core ML as the robot’s eye, 20 mm XY-only “vision nudge”, F1–F4 evidence theatre.

**Control surface:** do not invent a second pendant. Use **Joy1** (`../joy1`: `PendantModel`, Auto Connect, pad, vacuum, STOP). The Go workspace embeds `Joy1UI.ContentView`. Auto Connect uses Joy1 `PortDetector` (named HUEARM first, HUECAM refused).

Live flags (never in ordinary tests / CI):

```
ARMAGEDDON_CAPPELLA_LIVE=1
CAPPELLA_SGLANG_BASE_URL=http://192.168.0.69:8888/v1
ARMAGEDDON_LIVE_ARM=1
ARMAGEDDON_ARM_SERIAL=/dev/cu.usbserial-XXXX
ARMAGEDDON_GO_GRID_FILE=/path/to/grid.txt   # until K210 ingest is attached
```

Confirm place runs `PickPlaceRecipe` (vacuum + G1, no G28). `GoWorkspace.fixture` millimetres are not a real table — teach them first.

## Hard rules

- Never send Marlin `G28`.
- Software STOP = vacuum off + `M410`; unconfirmed STOP → physical power cutoff.
- Ordinary tests: no live USB, no `/dev/cu.*`, no TCC, no network, no hardware writes.
- K210 preview/upload remain unmeasured; do not advertise them. Next measured protocol is a **board-grid UART schema**, not a webcam pipe.
- LAN POST of an ASCII grid to cappella is local inference, not cloud.
- First board size is **9×9**. 19×19 is later.
- Webcam (FaceTime, OBSBOT, UVC) is **not** the robot’s eye and is not required to play.

## Commands

```sh
swift test --parallel
./scripts/validate-docs.sh
./scripts/check-motion-boundary.sh
```
