# Safety boundary

The motion boundary is fail-closed. The default policy requires confidence of
at least 0.70, detection age at most 500 ms, pose age at most 750 ms, a valid
calibration with RMS error at most 3 mm and held-out maximum error at most
5 mm, a nonempty 10 mm-inset workspace, a complete commanded XY segment inside
that inset, a delta no larger than 20 mm, a configured safe Z band, and a feed
between 0 and 300 mm/min.

Arming expires after 30 seconds. A target proposal confirmation expires after
5 seconds and is single-use. Proposals contain XY only; no Z, suction, or
automatic retry is generated from a detection.

Only trusted native-camera detections with a mapped host monotonic timestamp,
matching frame/format identity, and the active Mac model hash can enter this
boundary. K210 serial telemetry remains detection-only because its protocol
does not yet provide the required shared frame identity and trusted source
timestamp.

Software STOP cancels pending work and independently attempts vacuum-off and
`M410` through the priority path. A dispatch acknowledgement is not firmware
confirmation. When STOP is unconfirmed, use the physical power cutoff.
