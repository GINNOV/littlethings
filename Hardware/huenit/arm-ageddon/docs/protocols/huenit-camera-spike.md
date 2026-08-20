# HUENIT camera protocol spike

Status: bounded, read-only transcript path implemented. Live hardware measurement is still not run in this repository.

The checked-in transcript at `Tests/Fixtures/Serial/huenit-camera-recorded.txt` is a redacted behavioral fixture. It records the identity token, the observed baud value, and rectangle telemetry. Running `HuenitCameraProbe --transcript <file>` produces a hashed, schema-versioned capability decision.

The current decision is deliberately narrow:

- serial rectangle telemetry is measured by the fixture parser;
- framed preview is unsupported because no reproducible preview handshake was measured;
- artifact upload is unsupported because no documented, verified upload handshake was measured;
- telemetry is detection-only and carries host receipt time; it is never treated as a camera capture timestamp;
- line size, buffering, malformed input, and reconnect generation are bounded.

No guessed serial writes, firmware flashing, network transport, or camera artifact download is included. A future live spike must use an explicitly reviewed transport and replace `not-measured` with a separately hashed transcript; until then the app must not advertise preview or upload support.
