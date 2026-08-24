# Live sources

The Source menu chooses what Live inspects. Only one of these is a real picture of the world.

## Native camera

A Mac or USB webcam that macOS lists as video, such as FaceTime or a UVC camera.

- Grant Camera access, then pick the device in the camera menu.
- Live shows moving pixels through the native capture session.
- Capture frame stores that JPEG in the Capture library.
- The HUENIT K210 module is not this source unless macOS lists it as a video device.

Use Native camera when you want to see the workspace.

## Recorded fixture

A fake, repeatable still: a dark grid with two detection boxes (`target` and `other`). No camera or arm is required.

- Used to exercise Live, Capture, and tests without hardware.
- Capture frame stores a synthetic JPEG of that still.
- Switching here stops the native camera session.

Use Recorded fixture when hardware is unplugged or you are checking the app, not the scene.

## HUENIT telemetry · detection only

The arm’s K210 module over serial at 115200 baud. It can send bounding-box lines. It does not send video.

- Choosing this source does not start a picture.
- Preview and in-app upload are unsupported until a measured protocol proves them.
- Serial detections cannot mint a motion proposal or write to the arm.

Use HUENIT telemetry only to inspect detection-only UART output. For a picture of what the robot is looking at, use Native camera.

# Detection models

The Model menu chooses which detector draws boxes on Live. It is separate from the Source menu: a model never turns the K210 into a webcam.

## Fixture detector

A built-in constant detector for the recorded fixture still.

- Always available, even with no imported model.
- Draws the same two boxes (`target` and `other`) so overlays, selection, and dry-run targeting can be exercised.
- Does not run a real Core ML network.

Use Fixture detector when you are checking the app, not a trained model.

## Recorded fixture detector

The same deterministic fixture path, labeled as the recorded-fixture detector.

- Same fake boxes and labels as Fixture detector.
- Kept as a distinct menu item so tests and the recorded-fixture workflow can name that model explicitly.

Use Recorded fixture detector with the Recorded fixture source when you want that named pairing.

## Imported models

Verified `.armmodel.json` bundles you add in Models.

- Import quarantines, hashes, and validates the manifest before activation.
- A failed import leaves the last-known-good model in place.
- Slow or incompatible models can stay visible for detection but will not be allowed to mint motion.

Use an imported model only after Models shows it as validated and active.
