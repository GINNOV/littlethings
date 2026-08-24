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
