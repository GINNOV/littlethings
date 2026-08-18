# Joy1

A macOS controller for a HUENIT robotic arm with a suction cup. Connect over USB, jog in X/Y/Z, set home, turn suction on and off, and rotate the cup.

## Requirements

- macOS 15 or later
- Xcode 16 or later
- Arm powered from the **DC IN** port
- Arm **PC** USB-C cable plugged into the Mac

Power the arm before plugging in USB. Do not use the camera USB-C in place of the arm cable.

## Open the app

```bash
open Joy1.xcodeproj
```

Choose the **Joy1App** scheme and press Run.

Alternatively:

```bash
swift run Joy1App
```

## Connect the arm

1. Power on the arm, then connect USB.
2. If the Main tile has no port, click **Rescan**.
3. Click **Auto Connect** and wait a few seconds.

macOS assigns a new serial device name after unplug/replug. Auto Connect looks up the arm by name (`HUENIT_HUEARM`), not by a fixed path.

**Motor Off** releases the joints so you can move the arm by hand. **Motor On** engages them again.

## Using the pad

**Status** is the live tip position in millimetres (`x`, `y`, `z`) and the suction-cup angle (`e`).

**STOP** (or Esc) halts motion and turns suction off. Switching away from the window does the same.

| Control | Action |
|---|---|
| Hold | Arm moves while you hold a key |
| Step | Each click moves a fixed distance |
| Speed | 1–400 (same scale as HUENIT Lab) |
| Width | Step size: 0.1, 1, or 10 mm |
| Pad | X/Y/Z and diagonals |
| ⌂ | Home: X 0, Y 180, Z 0 |
| Z0 | Set Z to 0, keep X and Y |
| Move to | Type a pose and click **Move Now** |
| Suction | Vacuum on/off |
| E− / E+ | Rotate the cup |

Let one move finish before starting the next. If the pose is outside reach, the arm will refuse it.

## Safety

- Do not home with Marlin `G28`. This arm has no limit switches and can drive into itself. The app will not send `G28`.
- Power-on / official home is **X 0, Y 180, Z 0**.
- The arm does not move until you connect and press a control.

## Tests

```bash
swift test --skip LiveArmTests
```

That suite does not move hardware. Live tests (not skipped) send small moves to a plugged-in arm and then undo them.
