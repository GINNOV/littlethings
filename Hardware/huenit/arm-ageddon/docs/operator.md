# Operator guide

Armageddon drives a HUENIT arm from this Mac. The aim is Go play
(`docs/go-play.md`): you place a stone, tap **I moved**, the K210 looks, cappella
Qwen replies, you confirm, the cup places. No webcam is required.

## Before any physical test

Clear the work area. Keep the physical power cutoff reachable. Confirm arm
identity. Use a low feed. Keep one hand on the cutoff. Software STOP is a
request until firmware confirms; if STOP is unconfirmed, use the physical
power cutoff and do not continue. `M410` is the priority stop frame. `G28` is
forbidden.

Persistent app data lives under Application Support (`Armageddon/`).

## What the K210 does

The arm’s AI camera is the eye. It is **detection-only** for motion: UART
grid (and today’s rectangle fixture), never G-code, never a Mac preview
stream. Load models by plugging the camera USB-C into a host, then put it
back on the arm. Do not connect camera USB and arm USB to the Mac at once.

## First live Go run (operator at the cutoff)

Software STOP is a request until firmware confirms. If STOP is unconfirmed, use
the physical power cutoff. Never `G28`.

1. Qwen on cappella (`docker ps` shows `qwen3.8-27b-sglang`). Not Gemma.
2. Optional: point `ARMAGEDDON_GO_GRID_FILE` at a UART grid text file you rewrite
   after each human stone (until K210 ingest is attached).
3. Teach `GoWorkspace` numbers (bowl XY/Z, origin, step, safe/pick/place Z) before
   trusting Confirm. Defaults are a fixture, not your table.
4. Launch with live flags **only** with the cutoff in reach:

```sh
export ARMAGEDDON_CAPPELLA_LIVE=1
export CAPPELLA_SGLANG_BASE_URL=http://192.168.0.69:8888/v1
export ARMAGEDDON_LIVE_ARM=1
export ARMAGEDDON_ARM_SERIAL=/dev/cu.usbserial-XXXX
# open Armageddon.app from that environment
```

5. Connect arm → Start game → you play → **I moved** → check the reply →
   **Confirm place** (suction recipe). Ordinary tests never set these variables.

## Cappella

Move decisions: `http://192.168.0.69:8888/v1` (Tailscale `100.66.9.68:8888`),
model `qwen3.8-27b-sglang`. That host is on the LAN, not the cloud. If Qwen
is down, do not start Gemma on `:8000` just to fill the gap while a Go session
is armed — pick one heavy serve.

## Live UI leftovers

The Source menu’s Native camera / Recorded fixture / HUENIT bounce-back are
from the dead inspector. Do not treat them as the Go loop. Manual −X/+X/+Y
on Live are disabled placeholders; use a wired Control surface once it exists.
