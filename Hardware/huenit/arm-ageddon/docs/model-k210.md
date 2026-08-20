# Model and K210 protocol notes

Mac models are imported with an `.armmodel.json` manifest. The manifest binds
the model hash, labels, input size, coordinate convention, preprocessing,
minimum OS, and provenance. Candidates are quarantined until validation,
compile, smoke test, and benchmark complete. A failed candidate cannot replace
the last-known-good model.

The HUENIT K210 camera protocol was measured only through the recorded fixture
in `Tests/Fixtures/Serial/huenit-camera-recorded.txt`. It proves line-oriented
115200 telemetry containing target rectangles. It does not prove a host
preview stream or an upload/deployment protocol. The probe reports
`serialTelemetry` as supported and preview/upload as unsupported.

K210 artifacts are imported with a safe filename allowlist and a manifest
hash. The native application does not silently upload, flash, or deploy them.
