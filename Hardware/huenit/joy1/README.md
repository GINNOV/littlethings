# Joy1

macOS teach pendant for a **HUENIT** desktop arm (suction cup). It talks to the arm over USB serial (Marlin on a FYSETC E4). The window is laid out like HUENIT Lab’s Control tab: connect, status, STOP, pad, module angle.

The `Joy1` library is separate from the app. Other tools can import the library and drive the same arm without this UI.

## What you need

- macOS 15+
- Xcode 16+ (or Swift 6.1)
- HUENIT arm powered from **DC IN**
- Arm **PC USB-C** plugged into the Mac (device name `HUENIT_HUEARM`)

The AI camera is optional for this app. Do not plug the camera in place of the arm cable. If you use HUENIT OS on the camera, that camera USB-C goes to the arm’s rear port labeled **Serial**, not to the Mac.

## Run

From this folder:

```bash
open Joy1.xcodeproj
```

Select the **Joy1App** scheme and Run. Sandbox is off so `/dev/cu.*` works.

Or from the command line:

```bash
swift run Joy1App
```

## Connect

1. Power the arm first (DC IN), then plug its PC USB-C into the Mac.
2. Click **Rescan** if the Main tile shows no port.
3. Click **Auto Connect**. The app finds `HUENIT_HUEARM` (FTDI). The TTY name (`/dev/cu.usbserial-…`) changes when you unplug; Connect always rescans.
4. Wait a couple of seconds. Opening the port resets Marlin.

If Connect fails with “No such file or directory”, the old path is gone. Rescan and Connect again. The camera (`HUENIT_CAM` / `HUECAM`) is never opened.

**Motor** On/Off is `M17` / `M84`. After Off, the arm can be moved by hand.

## Controls

**Status** shows live `x y z` (mm) and `e` (module angle). A/B/C joint angles are still read for diagnostics; they are not jogged (firmware has no joint increment we found).

**STOP** (or Esc) clears motion, turns suction off, and tries a quick stop (`M410`, else motors off). Leaving the window also stops.

**Control**

| Control | What it does |
|---|---|
| Hold / Step | Hold = stream while pressed (HUENIT OS style). Step = one tap, one move (Lab style). |
| Speed 1–400 | Lab scale. Feed is `speed × 6` mm/min (100 → 600). |
| Width 0.1 / 1 / 10 mm | Step size in Step mode. |
| Pad | X/Y/Z and diagonals. **⌂** is official home **(0, 180, 0)**, not `G28`. **Z0** sets Z to 0 and keeps X/Y. |
| Move to | Type XYZ (mm) and **Move Now**. Default is home. |
| Module | Suction on/off (`M1400`). **E− / E+** rotate the cup (`G1 E`). |

Wait for a move to finish before stacking another (same as Lab). Out-of-reach poses can fail on the firmware (“No Reachable”).

## Safety

- **Never send `G28`.** This arm has no limit switches; firmware homing can crash the mechanics. Joy1 rejects `G28`.
- Official home is **X=0 Y=180 Z=0** after power-on.
- First motion requires Connect and a pad press or Move Now. Nothing moves at launch.

## Tests

```bash
swift test --skip LiveArmTests
```

Live tests talk to the real arm (small XYZ moves, then undo). They skip if no HUEARM is plugged in. They will move the arm if it is.

## Layout

```
Sources/Joy1/          Shared library (serial, arm, pose, detector)
Sources/Joy1App/       This pendant (cards, pad, STOP)
Tests/Joy1Tests/       Offline + optional live hardware tests
```

A second app can depend on the `Joy1` product and use `HuenitArm` / `PortDetector` without the pendant views.
