# Safety boundary

Fail-closed. Software STOP cancels work and independently attempts vacuum-off
and `M410`. A dispatch acknowledgement is not firmware confirmation. When STOP
is unconfirmed, use the physical power cutoff.

Never send `G28`.

## Go play (current product)

Motion that places a stone is a **confirmed recipe**, not an unattended
detection-to-motor loop:

- Human signals **I moved** (no intersection name).
- Arm is at a taught survey pose; K210 emits a board grid (detection-only).
- Cappella Qwen returns one intersection; the Mac legal-checks it against the
  grid.
- Arming expires; confirmation is one-use and short-lived.
- Recipe may include Z and vacuum on/off (`M1400`). Workspace polygon, safe Z
  band, and feed cap still apply.
- The K210 never writes the arm port. The DGX never receives raw G-code.

First board is 9×9. Bowl pose and intersection map are taught, not guessed.

## Legacy inspector policy (do not extend)

`SafetyPolicyV1` in code still describes the dead camera-ml path: confidence
≥0.70, detection age ≤500 ms, pose age ≤750 ms, planar calibration RMS ≤3 mm,
≤20 mm XY-only, no suction, native-camera frames only. That policy must not
be used as the Go recipe. Replace it when the pick-place path lands; until
then do not mint motion from webcam boxes or from K210 rectangles.
