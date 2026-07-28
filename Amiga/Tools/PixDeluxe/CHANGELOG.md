# Changelog

All notable changes to PixDeluxe are documented here.

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
