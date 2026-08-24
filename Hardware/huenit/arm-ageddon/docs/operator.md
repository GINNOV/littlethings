# Operator guide

Armageddon is a local macOS inspection and supervised-control application for
HUENIT. Start with the recorded fixture profile. Choose **Native camera** only
after macOS grants camera access and a camera is visibly selected.

The Live workspace is detection-first. A selected detection is not a movement
command. Vision-guided movement requires a measured fixed-camera planar
calibration, a fresh arm pose, a configured safe Z band, an in-bounds XY
segment, explicit arming, and a one-use confirmation. The application never
homes the arm and never runs an unattended detection-to-motion loop.

Before any physical test, clear the work area, verify the physical power
cutoff is reachable, confirm the arm and camera identity, use a low feed and a
small dry-run target, and keep one hand ready for the cutoff. Treat software
STOP as a request until firmware confirmation is recorded. If STOP is
unconfirmed, use the physical cutoff and do not continue. `M410` is the
priority stop frame; `G28` is forbidden.

HUENIT K210 serial telemetry is detection-only. It cannot mint a motion
proposal or write to the arm.

The Live **Source** menu has a **(?)** control that opens the bundled
`documentation.md` manual for Native camera, Recorded fixture, and HUENIT
telemetry.
