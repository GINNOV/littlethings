# Changelog

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
