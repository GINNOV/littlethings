# Joy2

A macOS Lab pad for a HUENIT robotic arm with a suction cup, driven by a Speedlink Competition Pro Extra joystick. Connect over USB, hold the stick to jog in X/Y, use the fire buttons for height, cup angle, and suction.

![Speedlink stick with the controls Joy2 uses](joy2-guide.jpg)

Download the disk image from [Releases](https://github.com/GINNOV/littlethings/releases?q=joy2). Open the `.dmg` and drag **Joy2** to Applications.

See [CHANGELOG.md](CHANGELOG.md) for what changed in each version.

## Requirements

- macOS 15 or later
- Xcode 16 or later
- Speedlink Competition Pro Extra plugged into the Mac
- Arm powered from the **DC IN** port
- Arm **PC** USB-C cable plugged into the Mac

Power the arm before plugging in USB. Do not use the camera USB-C in place of the arm cable.

Official HUENIT Lab (Windows) is documented here: [Installing HUENIT LAB](https://huenit.gitbook.io/huenit-manual-en/huenit-user-manual/how-to-use-huenit-lab/0.-getting-ready/installing-huenit-lab#windows).

## Open the app

```bash
open Joy2.xcodeproj
```

Choose the **Joy2App** scheme and press Run.

Alternatively:

```bash
swift run Joy2App
```

## Connect the arm

1. Power on the arm, then connect USB.
2. If the Main tile has no port, click **Rescan**.
3. Click **Auto Connect** and wait a few seconds.

The pad, suction, and stick motion stay hidden until the arm is linked.

macOS assigns a new serial device name after unplug/replug. Auto Connect looks up the arm by name (`HUENIT_HUEARM`), not by a fixed path.

**Motor Off** releases the joints so you can move the arm by hand. **Motor On** engages them again.

## Using the stick

See the photo above. In the app, **How the stick works** opens the same picture with arrows.

- Hold the stick to keep moving on the table (X/Y). Release to stop that direction.
- Hold **left fire** and the stick becomes height (Z) and cup angle.
- **Right fire** turns suction on or off (one press).
- The on-screen pad lights the cells the stick is using.

**STOP** (or Esc) also fires if you switch away from the app.

Let one move finish before starting the next. If the pose is outside reach, the arm will refuse it.

## Safety

- Do not home with Marlin `G28`. This arm has no limit switches and can drive into itself. The app will not send `G28`.
- Power-on / official home is **X 0, Y 180, Z 0**.
- The arm does not move until you connect and press a control or hold the stick.

## Tests

```bash
swift test --skip LiveStickTests
```

That suite does not move hardware. Live tests (not skipped) send small moves to a plugged-in arm and then undo them.
