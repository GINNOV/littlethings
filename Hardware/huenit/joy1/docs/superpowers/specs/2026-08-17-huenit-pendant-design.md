# HUENIT Joy1 Pendant

Date: 2026-08-17
Status: approved for planning
Platform: macOS SwiftUI app
Hardware: HUENIT 3-axis arm + suction cup (camera out of scope for v1)

## Goal

A native macOS teach pendant that hold-to-jogs the HUENIT arm in task space (X/Y/Z) and joint space (A/B/C), with a speed slider, suction on/off, and a live pose HUD. Cartesian motion uses the firmware’s inverse kinematics. The app does not solve IK itself in v1; it shows the FK/IK translation by displaying both spaces at once.

## Non-goals (v1)

- iPhone / iPad
- App-side IK solver (CCD, DLS, FABRIK)
- Camera stream or `HUENIT_CAM` protocol
- Go-to pose / taught waypoints
- Physical game-controller as the primary input
- Homing (`G28` is forbidden)

## Hardware contract (measured on this desk)

| Device | USB name | Serial | Port |
|---|---|---|---|
| Arm | `HUENIT_HUEARM` | `D30GQRUV_HUEARM` | `/dev/cu.usbserial-3120` @ 115200 8N1 |
| Camera | `HUENIT_CAM` | `D30GSA95_HUECAM` | `/dev/cu.usbserial-834440` (do not open) |

Arm firmware: Marlin bugfix-2.0.x (Jun 28 2025), `MACHINE_TYPE:FYSETC_E4`.

| Action | Command |
|---|---|
| Units mm | `G21` |
| Relative | `G91` |
| Absolute | `G90` |
| Cartesian step | `G1 X.. Y.. Z.. F..` (F = mm/min) |
| Tip pose | `M1008 A3` → `X: Y: Z:` |
| Joint pose | `M1008 A2` → `A: B: C:` |
| Planner pose / module | `M114` (includes `current_module`, `module_status`, `motor_status`) |
| Vacuum on | `M1400 A1023` |
| Vacuum off | `M1400 A0` |
| Flush planner | `M400` |
| Quick stop | `M410` if accepted, else `M84` (motors off) |
| Identity | `M115` |

Identity check: `M115` must look like Marlin / `FYSETC_E4`. Connect fails otherwise.

The arm has no limit switches. `G28` will crash into mechanical stops. The send path must refuse `G28`.

Joint incremental G-code is locked against the live firmware during implementation. The product contract is: hold A±/B±/C± moves that joint while held. If the firmware has no joint-space increment, implementation records the working command from a live probe (not a guessed `G1 A`). Cartesian `G1 X/Y/Z` is already proven.

## Architecture

Single-window macOS pendant.

- **Connection** — auto-detect `HUENIT_HUEARM` (FTDI `0403:6015`, serial contains `HUEARM`). Connect / disconnect. Never open the camera port.
- **Task-space jog** — hold X± Y± Z±. While held, stream small relative `G1` moves at the chosen speed. Firmware IK poses the joints.
- **Joint-space jog** — hold A± B± C±. Incremental joint commands, same hold-to-move contract.
- **Speed** — one slider for both spaces (mm/s for XYZ, °/s for joints). Map mm/s → `F` as mm/min (`speed * 60`).
- **Vacuum** — on/off via `M1400`.
- **HUD** — live tip `X Y Z` and joints `A B C` from `M1008`. Readout only; no app-side solver.
- **Safety** — release = stop sending and `M400`. Stop always available. No motion until Connect. App resigns active → Stop.

## Components

One type per file.

| Type | Role |
|---|---|
| `SerialPort` | Actor. Open/close BSD callout, raw 115200 8N1, write a line, read until `ok` or timeout. No G-code knowledge. |
| `HuenitArm` | Actor. Only client of `SerialPort`. Connect, jog step, joint step, vacuum, `m400`, stop, `queryPose()`. Parses `M1008` / `M115` / `M114`. Rejects `G28`. |
| `PortDetector` | Lists serial ports via IOKit. Scores `HUEARM` vs `HUECAM`. Camera never wins. |
| `JogEngine` | Hold bits for six Cartesian and six joint pads. 60 Hz: if held, one step from the speed slider; if idle for 0.6 s, `M400`. Does not block on pose polls. |
| `PoseMonitor` | ~2 Hz `queryPose()` for the HUD only. |
| `PendantModel` | `@MainActor` `Observable`. Connection, speed, vacuum, live pose, last error, which pads are down. |
| Views | `ContentView`, `ConnectionBar`, `CartesianPad`, `JointPad`, `SpeedSlider`, `VacuumToggle`, `PoseHUD`, `StopButton`. |

## Data flow

```
View (press/release, slider, vacuum, connect)
    → PendantModel (@MainActor)
        → JogEngine (hold bits + speed)
            → HuenitArm.jogStep(...)
        → HuenitArm.setVacuum / stop / connect
            → SerialPort.writeLine
        ← SerialPort bytes
            ← "ok" completes the command
PoseMonitor (2 Hz)
    → HuenitArm.queryPose()
        → PendantModel.pose  → PoseHUD
```

Rules:

- Only one writer: `HuenitArm` serializes jog steps and pose polls so `M1008` cannot interleave mid-`G1`.
- Jog path does not wait on HUD polls. Polls queue in the actor, never on the main thread.
- Views set hold bits and sliders only. They do not send G-code.
- Disconnect or Stop: clear holds, vacuum off, stop/motors-off, then close if disconnecting.
- App resigns active (window deactivate / sleep): same as Stop.

## Error handling and safety

- **Connect** — missing port, port in use, or `M115` not Marlin/`FYSETC_E4` → stay disconnected, show the reason. No infinite retry.
- **Write/read timeout** — dead link: stop jog loop, mark disconnected, keep last pose on screen as stale.
- **Hard firmware error** — show the line; stop streaming steps.
- **Release** — that hold bit clears immediately. When no pads are down, `M400`.
- **Stop** — clear all holds, `M1400 A0`, then `M410` if accepted else `M84`. Available even if a command is in flight.
- **Forbidden** — `G28` rejected at `HuenitArm`.
- **No auto-home, no auto-move on launch.** First motion needs Connect and a held pad.
- **Camera** — detector refuses `HUECAM`.
- **Stale HUD** — `M1008` failure freezes last numbers and marks them stale. Never jump to zero.

## Testing — hardware-in-the-loop

The desk is the source of truth. Default live tests talk to the real HUEARM. The camera port is never opened.

Live suite (Swift Testing). Skip the whole suite if HUEARM is absent. Motion tests are explicit and always try to undo. First live test is read-only.

1. **Identity** — `M115` is Marlin / `FYSETC_E4`. Detector picks `HUEARM`, refuses `HUECAM`.
2. **Pose consistency** — `M1008 A3` and `A2` parse. A second read within ~200 ms stays inside a noise band.
3. **Cartesian jog, then measure** — snapshot → small `G91 G1` (3 mm) → `M400` → encoders. Commanded axis moves ~3 mm; the other two stay in a tight band. Repeat ±X ±Y ±Z. Return to start after each axis.
4. **Joint jog, then measure** — same pattern on A/B/C with a small degree step. Commanded joint changes; HUD XYZ updates (firmware FK/IK visible).
5. **Speed** — same displacement at two slider values; faster setting uses less wall time.
6. **Vacuum** — `M1400 A1023` then `A0` both `ok`.
7. **Stop** — start a jog, Stop, holds clear, vacuum off, pose settles on a follow-up read.
8. **Unplug** — manual: pull arm USB at idle; app goes disconnected and does not keep writing.

Safety in the live suite: no `G28`; tiny steps; undo after each axis; skip if the arm is missing.

Offline tests exist only for things the arm cannot teach: reject `G28` at the API, parse a broken firmware line, detector scoring when both ports are mocked.

## IK stance (Wendy article)

Joint space is A/B/C. Task space is X/Y/Z. Firmware IK is the bridge for `G1 X/Y/Z`. v1 shows both spaces live so the translation is visible. An app-side solver is a later add-on, not a v1 requirement.

## Stack

- macOS, SwiftUI, Swift 6, Swift Testing
- No third-party packages
- Serial via `FileHandle` + termios / IOKit, not a Python sidecar
