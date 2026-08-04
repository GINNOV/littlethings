# PixDeluxe Quick Look Changelog

## 1.0 (40) - 2026-07-28

- Added Finder thumbnails for IFF, ILBM, LBM, and PBM images.
- Added macOS Sonoma 14 compatibility.
- Hardened IFF parsing against truncated files, oversized chunks, invalid palettes, and malformed ByteRun1 data.
- Added support for ILBM mask planes, HAM, EHB, transparency, and pixel-aspect scaling in the shared decoder.
- Restored the Sparkle package dependency so the host app builds again.
- Corrected the exported IFF file type and Quick Look extension registration metadata.
- Added sanitizer-backed decoder regression tests.
