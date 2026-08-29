# Changelog

## 1.8 (build 80) - 2026-08-29

- Added visible progress while recursively discovering and processing tracker
  modules, including the current nested filename and completed file count.
- Added cancellation and dismiss controls with clear completion, cancellation,
  skipped-file, and failure feedback.
- Fixed scan cancellation so the background worker stops promptly while the
  existing playlist remains available until a new scan completes successfully.

## 1.7 (build 79) - 2026-07-29

- Completed Sparkle's sandboxed installer configuration so future
  EdDSA-signed updates can be installed from inside AuDeluxe.
- Rotated the Sparkle key used by build 79 and added a packaging check that
  prevents publishing an update signed by a different key.
- Documented Sentinel as a free, user-approved first-install workaround for
  Macs that quarantine the unnotarized app.
- Build 79 is a one-time manual update; automatic updates resume after it is
  installed.

## 1.7 (build 78) - 2026-07-28

- Added universal Apple Silicon and Intel builds from a pinned, project-local
  libopenmpt dependency; Homebrew is no longer required to build.
- Fixed shuffled queue ordering, pause/resume, seeking and stale audio-buffer
  completion behavior.
- Made recursive library scanning cancellable and protected the UI from stale
  scan results.
- Made the playlist cache sensitive to supported files anywhere below the
  selected library folder.
- Added safe, user-visible handling for rating, rename and trash failures,
  including rollback when a rename cannot complete.
- Added Quick Look declarations for all 24 supported tracker formats and
  bounded preview input size.
- Added automated coverage for playback queues, formats, malformed input,
  module rendering, scanning fingerprints, cache round trips and file
  mutations.

## 1.6 (build 77) - 2025-08-18

- Added Sparkle updates, library caching, playlist search, current-song
  navigation and menu-bar playback controls.
- Fixed initial sorting and repeat timeline behavior.
