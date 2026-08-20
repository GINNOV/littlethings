# Privacy and data handling

Armageddon processes camera frames, detections, and imported model metadata on
this Mac. There is no cloud service, analytics, remote frame upload,
microphone capture, or hidden serial transcript collection.

Persistent data lives under the Armageddon directory in macOS Application Support,
with large files in local capture, model, and diagnostic subfolders.
Captures are written only after the operator presses **Capture frame**.

Support bundles contain an allowlisted diagnostic snapshot and redacted event
metadata. Frames, thumbnails, model bytes, credentials, full device serial
numbers, and raw logs are excluded by default. Serial excerpts are an
explicit preference and remain bounded and redacted.

The camera purpose string is shown by macOS when native camera access is first
requested. Denying access leaves the app in a recoverable detection-only state.
