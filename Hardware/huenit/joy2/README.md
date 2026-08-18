# Joy2

macOS Lab pad for a HUENIT arm, driven by a Speedlink Competition Pro Extra joystick.

Download the disk image from [Releases](https://github.com/GINNOV/littlethings/releases?q=joy2). Open the `.dmg` and drag **Joy2** to Applications.

See [CHANGELOG.md](CHANGELOG.md) for what changed in each version.

## Stick

- Stick: hold to keep moving in X/Y on the table
- Hold left fire: stick is Z (forward/back) and cup angle (left/right)
- Right fire: suction on/off
- The pad lights the cell that is active

Open **How the stick works** in the app for a labeled photo.

## Open the app

```bash
open Joy2.xcodeproj
```

Choose the **Joy2App** scheme and press Run.

Alternatively:

```bash
swift run Joy2App
```

Requires the Joy1 package next door (`../joy1`). Connect the arm USB-C (`HUENIT_HUEARM`). Do not home with `G28`. Suction uses Joy1’s `M1400` path, not `M1111`–`M1114`.

## Tests

```bash
swift test --skip LiveStickTests
```

That suite does not move hardware.
