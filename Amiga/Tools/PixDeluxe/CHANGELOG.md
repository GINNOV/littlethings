# Changelog

All notable changes to PixDeluxe are documented here.

## 1.0 (Build 112) - 2026-07-29

### Changed

- Completed Sparkle's sandboxed installer configuration so future
  EdDSA-signed updates can be installed from inside PixDeluxe.
- Embedded the Sparkle public key used to sign build 112 and added packaging
  checks that prevent publishing with a mismatched signing key.
- Added the missing **Check for Updates** command to the application menu.
- Enabled outbound network access required for Sparkle to retrieve appcasts and
  update archives from inside the sandbox.
- Documented Sentinel as a free first-install workaround for Macs that
  quarantine the unnotarized app.
- Build 112 is a one-time manual update; automatic updates resume after it is
  installed.

## 1.0 (Build 111) - 2026-07-28

### Added

- Batch PNG and JPEG conversion to Amiga IFF/ILBM.
- Shared 1–8 bitplane selection for a conversion batch.
- Progress reporting with current filename, completed count, and cancellation.
- Collision-safe output naming that preserves existing files.
- Per-file success and failure summaries.
- Automated coverage for PNG/JPEG conversion, bitplane boundaries, batch conversion, collisions, partial failures, and cancellation.

### Changed

- Lowered the minimum supported operating system to macOS Sonoma 14.0.
- Restored Sparkle through Swift Package Manager.
- Made palette sampling deterministic.
- Made temporary conversion paths unique.

### Fixed

- Corrected generated ILBM BODY data to use scanline-interleaved bitplanes.
- Corrected ILBM row padding to use the required 16-bit alignment.
- Ensured generated IFF files can be opened by PixDeluxe after conversion.
