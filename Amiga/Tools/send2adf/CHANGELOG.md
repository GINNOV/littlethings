# Changelog

All notable changes to send2adf are documented here.

## 1.5.0 - 2026-08-04

### Added

- Recursive directory import for creating complete Amiga disk layouts in one
  command.
- Selectable AmigaOS 1.3, AmigaOS 2.0, or no boot block.
- Quiet, verbose, and debug output modes.
- Native build and test coverage for Apple Silicon macOS, Intel macOS, and
  x86-64 Linux.
- Reproducible release packaging with source, license, provenance, and
  verification artifacts.

### Changed

- Replaced the system ADFlib dependency with a pinned, project-local build.
- Added automated ADFlib update proposals that validate send2adf and ADFinder
  before an update can be merged.
- Added read-only canary checks for upcoming ADFlib releases.
- Made disk creation transactional: a failed operation no longer leaves a
  partial image or replaces an existing destination.
- Standardized CMake presets and Make targets for local and CI builds.

### Fixed

- Added strict validation for output paths, volume names, input trees, disk
  capacity, and unsupported filesystem entries.
- Added cleanup and rollback handling for failures during image creation.
