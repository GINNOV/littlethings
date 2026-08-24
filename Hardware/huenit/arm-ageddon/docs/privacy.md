# Privacy and data handling

Armageddon talks to the HUENIT arm on USB serial and, for Go play, POSTs an
ASCII board grid to cappella on the LAN (`192.168.0.69`). There is no cloud
service, analytics, remote frame upload, microphone capture, or hidden raw
serial transcript collection.

Persistent data lives under the Armageddon directory in macOS Application
Support. Captures from the leftover inspector UI, if used, are written only
after **Capture frame**.

Support bundles contain an allowlisted diagnostic snapshot and redacted event
metadata. Frames, thumbnails, model bytes, credentials, full device serial
numbers, and raw logs are excluded by default.

Native camera access (leftover inspector) is requested only if that UI is
used; denying it does not block the K210 UART grid path.
