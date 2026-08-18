# Joy2

macOS Lab pad for a HUENIT arm, driven by a Speedlink Competition Pro Extra joystick.

## Stick

- Stick: hold to keep moving in X/Y on the table
- Hold left fire: stick is Z (forward/back) and cup angle (left/right)
- Right fire: suction on/off
- The pad lights the cell that is active

## Run

```bash
swift run Joy2App
```

Or open the built app so a window appears on screen:

```bash
swift build --product Joy2App
open .build/arm64-apple-macosx/debug/Joy2App
```

Requires the Joy1 package next door (`../joy1`). Connect the arm USB-C (`HUENIT_HUEARM`). Do not home with `G28`. Suction uses Joy1’s `M1400` path, not `M1111`–`M1114`.

See [docs/superpowers/specs/2026-08-18-joy2-joystick-design.md](docs/superpowers/specs/2026-08-18-joy2-joystick-design.md).
