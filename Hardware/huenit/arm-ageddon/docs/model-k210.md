# Model and K210 protocol notes

The HUENIT AI Camera (K210) is the Go board eye. It does not send video to
this Mac. It is **detection-only** for motion: UART out, never arm writes.

## What is measured

`Tests/Fixtures/Serial/huenit-camera-recorded.txt` is a redacted 115200
rectangle fixture (`identity=HUENIT_CAM`, `frame=label,x,y,w,h`). The probe
marks `serialTelemetry` supported and preview/upload unsupported. Host receipt
time is not a capture timestamp.

## What Go play needs next

A **board-grid UART schema** (9×9 cells: empty / black / white), decoded on
the Mac, forwarded to cappella as ASCII. Measure it with a hashed live
transcript before claiming a reader. Do not invent preview or artifact-upload
handshakes.

HUENIT OS image classification labels a fixed square (WHAT). It does not
emit WHERE. Object detection is documented as missing on some camera
firmware. A custom on-camera model that prints a grid is the intended path.
Load/train with the camera on USB-C to a host; then plug it back into the arm.
The Mac must not hold camera USB and arm USB at once.

K210 bundles (`.kmodel` + script + manifest) stay hashed in inventory. The
app does not silently upload or flash them until a measured upload protocol
exists. Copy verified bundles by hand.
