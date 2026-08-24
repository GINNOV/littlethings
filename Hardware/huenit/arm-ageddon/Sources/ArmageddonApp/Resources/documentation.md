# Live sources

The Source menu is leftover from a dead webcam inspector. **Go play does not
use it.** The robot’s eye is the HUENIT K210 on the arm. A Mac webcam is not
required. Product loop: human taps **I moved** → K210 grid → cappella Qwen →
confirm place.

## Native camera

A Mac or USB webcam that macOS lists as video, such as FaceTime or a UVC camera.

- Optional debug only. It is not how the arm sees a go board.
- Grant Camera access only if you use this leftover UI.
- It cannot mint a Go move.

## Recorded fixture

A fake, repeatable still used by old UI tests. Not the go board.

- Used to exercise leftover Live/Capture tests without hardware.
- Not a substitute for the K210 grid.

## HUENIT telemetry · detection only

The arm’s K210 module over serial at 115200 baud. It can send bounding-box
lines today and a board grid next. It does not send video.

- Choosing this leftover menu item does not start a picture.
- Preview and in-app upload are unsupported until a measured protocol proves them.
- Serial detections cannot mint a motion proposal or write to the arm.

Use the K210 UART grid for Go play. Do not use a webcam as the robot’s eye.

# Detection models

The Model menu is leftover. It does not run Qwen. The move is chosen on
cappella (`qwen3.8-27b-sglang`).

## Fixture detector

A built-in constant detector for the recorded fixture still.

- Always available for old tests.
- Draws canned boxes (`target` and `other`).
- Does not run a real Core ML network and does not read a go board.

## Recorded fixture detector

The same deterministic fixture path, labeled as the recorded-fixture detector.

- Same fake boxes as Fixture detector.
- Kept so tests can name that model.

## Imported models

Verified `.armmodel.json` bundles you add in Models.

- Local Mac Core ML only. Not the DGX Go decision.
- A failed import leaves the last-known-good model in place.
