# ADFinder changelog

All notable changes to ADFinder are documented here.

## 1.2.5 — 2026-07-30

- Rotated to a dedicated ADFinder Sparkle signing key stored in 1Password.
  Because the legacy private key could not be recovered, this is a one-time
  manual upgrade; automatic updates resume for subsequent releases.
- Added an ADFinder test target with coverage for sector comparison and
  document-type metadata.
- Corrected HDF registration to advertise the `.hdf` extension.
- Completed Sparkle's sandboxed installer configuration.
- Replaced the fragile DMG-signing appcast workflow with a signed ZIP workflow.
- Added validation for Sparkle signing keys and generated appcasts.
- Replaced the build-number-mutating Debug scheme with one shared scheme.
- Aligned the project and target deployment settings on macOS 15.
- Removed the unused inbound-network sandbox entitlement.
- Updated release documentation and direct website download guidance.

## 1.2.4 — 2025-08-16

- Added importing of complete folder structures.
- Added recently opened images to the Open menu.
- Added Sparkle update support.

## 1.2.3 — 2025-08-12

- Improved file operations and disk-image handling.

## 1.2.1 — 2025-08-12

- Published the first appcast-enabled ADFinder release.
