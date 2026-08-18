# Joy2 Speedlink stick pendant

Date: 2026-08-18
Status: approved for planning
Platform: macOS SwiftUI app
Hardware: HUENIT arm (via Joy1 library) + Speedlink COMPETITION PRO EXTRA USB stick

## Goal

A second macOS pendant, in `Hardware/huenit/joy2`, that drives the same HUENIT arm as Joy1 using a Speedlink Competition Pro Extra joystick. The window is the Lab-style pad from Joy1. While the stick is live, the matching pad cells light up. The app must not send motion that can wreck the arm.

## Non-goals (v1)

- iPhone / iPad
- Analog sticks or other HID devices (this VID/PID only)
- Camera / `HUENIT_CAM`
- App-side IK
- Teaching waypoints
- Changing Joy1App’s window or shipping joystick support inside Joy1
- Numeric workspace box invented in the app (firmware already refuses illegal poses)

## Hardware contract

### Arm

Unchanged from Joy1. Connect by name `HUENIT_HUEARM`. Official home is `X 0, Y 180, Z 0`. Never send `G28`. Cartesian `G1` uses firmware IK. Cup rotation is `G1 E`. Vacuum is `M1400`. Stop is `M410` then `M84`. Joy2 calls `HuenitArm`; it does not open a second serial stack.

### Stick (measured on this Mac)

| Field | Value |
|---|---|
| Retail | Speedlink COMPETITION PRO EXTRA, black-red, `SL-650212-BKRD` |
| USB vendor string | `SPEEDLINK COMPETITION PRO` |
| USB product string | `Game Controller for Android` |
| VID / PID | `0x0079` / `0x181c` |
| HID | Usage page 1, usage 5 (joystick) |
| Physical | 8-way stick, left fire, right fire |

Match this VID/PID. Do not bind a random gamepad.

## Control map (humans)

Hand on stick, free hand on the fires. Table plane first, then drop, then grab.

| Input | Intent | Pad highlight |
|---|---|---|
| Stick (left fire up) | Jog X/Y, including diagonals | Matching X/Y cells (`X+`, `Y−`, `↖︎`, …) |
| Hold left fire + stick forward/back | Jog Z | `Z+` / `Z−` |
| Hold left fire + stick left/right | Jog cup angle `E` | Angle − / + |
| Right fire (press edge) | Toggle suction | Suction control |
| Stick centered | No jog | Clear jog highlights |
| Left fire held, stick centered | No jog | Left-fire / “Z-angle mode” affordance only |

Conventions:

- Stick away from the operator is `Y+` in XY mode and `Z+` in Z mode.
- Stick right is `X+` in XY mode and `E+` in angle mode.
- Right fire is an edge: one toggle per press, not a hold.
- Left + right together do not invent a third action. Right still toggles suction; left still selects Z/E. No chord for Home, Stop, or G28.
- This stick has no analog travel. Speed stays on the Lab slider. In Hold mode the stick behaves like holding the matching pad cells. In Step mode a stick deflection issues one step of the current width, then waits for return-to-center before another step.

## Architecture

New Swift package at `Hardware/huenit/joy2`.

- Product `Joy2` (library): HID, mapper, guard, highlight set. No SwiftUI. No Joy1 dependency and no serial port — so mapper/guard tests stay offline.
- Product `Joy2App` (executable): Lab-style window. Depends on `Joy2` and `Joy1` (`../joy1`). `PilotModel` is the only type that talks to both.
- Product `Joy2Tests`: mapper, guard, highlight. No robot required.

Joy1 sources stay the arm/serial/pose/detector stack. Joy2App may duplicate Lab layout views (not a binary plugin into Joy1App) so highlight can be first-class. Shared behavior (connect, home, jog, vacuum, stop) goes through `HuenitArm` / the same command set.

```
HID (Speedlink)
    → JoystickDevice
        → JoystickMapper  → intents + HighlightSet
            → IntentGuard
                → HuenitArm (Joy1)
Pad clicks
    → PilotModel
        → IntentGuard
            → HuenitArm
PoseMonitor (Joy1)
    → PilotModel.pose
```

One commander per tick: if the stick is producing a jog, pad clicks for that axis are ignored that tick. Stop always wins.

## Components

One type per file.

| Type | Role |
|---|---|
| `JoystickDevice` | Poll HID for VID `0x0079` PID `0x181c`. Publish stick X/Y (digital 8-way), left fire, right fire, connected. Unplug → disconnected. |
| `JoystickMapper` | Pure. Raw stick → `PilotIntent` + `HighlightSet`. Encodes the table above. Dead-zone so chatter is center. |
| `PilotIntent` | `none` / `jog(axis,sign)` / `jogDiagonal` / `toggleVacuum` / `stop`. Never `home`, never `g28`. |
| `HighlightSet` | Which `PadCell` values are pressed. Equatable for tests and the view. |
| `PadCell` | `xPlus`, `xMinus`, `yPlus`, `yMinus`, `xy` diagonals, `zPlus`, `zMinus`, `ePlus`, `eMinus`, `suction`, `zAngleMode`. Home / Z0 / Move Now are click-only and do not highlight from the stick. |
| `IntentGuard` | Allows an intent only if: arm connected (except stop), no in-flight `HuenitArm` call, intent is not `G28`. Firmware throw (out of reach / error) fails the in-flight call, is shown, and does not retry. |
| `PilotModel` | `@MainActor` `Observable`. Connection (Joy1 `PortDetector` + `HuenitArm`), Lab speed / hold-vs-step / step width, motors, Home / Z0 / move-to, vacuum, live pose, last error, `highlights`. Owns the 60 Hz tick that reads the mapper and feeds the guard. |
| Views | Lab pad, connection bar, pose HUD, STOP, module angle, speed — same information architecture as Joy1, plus pressed styling driven by `HighlightSet`. |

## Data flow

1. `JoystickDevice` polls at ~60 Hz.
2. `JoystickMapper` produces at most one jog (or one vacuum edge) and a highlight set. Center stick → no jog; highlights for fires can remain while held.
3. `IntentGuard` either forwards to `HuenitArm` or records a reject reason.
4. Passed jogs use Joy1 `jogCartesian` / `jogModule` / `step` with the Lab feed (`speed × 6` mm/min, same as Joy1). Vacuum uses `setVacuum`.
5. `PoseMonitor` (~2 Hz) updates the HUD only.
6. STOP (Esc, window resign, HID unplug, on-screen STOP) calls `HuenitArm.stop()`, clears holds and highlights, suction off.

Pad buttons call the same `PilotModel` methods the mapper uses. They go through the guard.

## Safety (do not break the arm)

- No `G28`. Not from the stick, not from the pad, not from a typed line. `HuenitArm` still rejects it; Joy2 never asks.
- Home is official pose `X0 Y180 Z0` only, click on ⌂, not a stick gesture.
- No motion on launch. First move needs Connect and a stick deflection or pad press.
- One in-flight arm call. Digital chatter does not queue a backlog of `G1`.
- XY and Z/E never in the same tick. Left fire selects the plane.
- Stick unplug or arm TTY vanish → STOP, then the matching error. Do not keep the last jog.
- App resigns active → STOP (same as Joy1).
- Motors-off: stick jogs are rejected with “motors off” until Motor On.
- Camera port is never opened (`PortDetector` already refuses `HUECAM`).
- Firmware reject (illegal pose) → show the reason, stop streaming that hold, do not hammer the same `G1`.
- Live tests, if run, use tiny steps and undo. They never home with `G28`.

## Errors

Shown in the status strip. No silent motion.

| Condition | Message / action |
|---|---|
| No matching HID | “Plug in the Speedlink stick”. Pad still works. |
| Stick unplug mid-move | STOP, then that message. |
| No HUEARM / TTY gone | Joy1 connect error. Rescan / Auto Connect. |
| Guard: busy | “still moving” |
| Guard: not connected | “not connected” |
| Guard: motors off | “motors off” |
| Firmware / serial throw | Existing Joy1 error string; stop streaming. |

## Testing

Default: `swift test` in `joy2` does not move hardware.

### Offline

- Mapper: XY including diagonals; left fire switches to Z/E; right fire is one toggle per press; release returns to center / clears jog highlights; both fires do not create Home/Stop/G28.
- Guard: blocks when disconnected, busy, or motors off; never emits `G28`; allows a legal jog when connected and idle.
- Highlight matches intent (`stick right` → `{xPlus}` only; `left+forward` → `{zPlus, zAngleMode}`).

### Live (skipped unless HUEARM is present)

Same discipline as Joy1: identity, a small XY jog from a synthetic stick event, undo, vacuum toggle, stop. Skip if the arm is missing.

## Stack

- macOS 15+, Swift 6, SwiftUI, Swift Testing
- Joy1 as a local package
- HID via IOKit / `IOHIDManager` (no third-party gamepad library)
- No Python sidecar
