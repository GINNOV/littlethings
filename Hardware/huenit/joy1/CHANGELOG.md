# Changelog

## 1.0.0 — 2026-08-18

First release of Joy1, a macOS controller for a HUENIT arm with a suction cup.

- Connects to the arm over USB and finds it by name (`HUENIT_HUEARM`), even if the serial device path changes
- Jog in X, Y, and Z: hold to move, or tap a step of 0.1 / 1 / 10 mm
- Official home (X 0, Y 180, Z 0) and Z0
- Type a pose and move there
- Suction on/off and cup rotation (E)
- Motor on/off so you can pose the arm by hand
- STOP (also Esc, or leaving the window) ends motion and turns suction off
- Does not send `G28`
