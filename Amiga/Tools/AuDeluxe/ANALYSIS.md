# AuDeluxe release-readiness analysis

Date: 2026-07-28

## Scope

This review applies the same lenses used for the PixDeluxe 1.0 release pass:

- clean-checkout build reproducibility;
- supported macOS and CPU architectures;
- core feature correctness;
- Quick Look integration;
- sandbox and file-access behavior;
- automated coverage;
- packaging, updates, and release documentation.

The review is based on the current source tree and a clean derived-data build with Xcode. It does not claim runtime playback validation because the project does not currently compile without machine-local Homebrew headers.

## Executive summary

AuDeluxe is a substantial application with module playback, a tracker view, folder scanning and caching, playlists, metadata editing, rating, search, sorting, shuffle/repeat, menu-bar controls, Quick Look preview, and Sparkle updates.

It is not yet at the release-readiness level reached by PixDeluxe:

- A clean build fails because both targets require `libopenmpt/libopenmpt.h` from `/opt/homebrew/include`.
- The project also contains a version-specific Homebrew search path for mpg123.
- The bundled static libraries are arm64-only and x86_64 is explicitly excluded.
- The minimum deployment target is macOS 15.5, versus the Sonoma 14.0 baseline established for PixDeluxe.
- There is no test target.
- Shuffle is neutralized by the computed playlist's unconditional sorting.
- Pause uses `stop()` and resume assumes the scheduled audio remains available.
- Seeking moves libopenmpt's decoder position without clearing and rebuilding already scheduled audio buffers.
- Quick Look advertises only `.mod`, although the app scans 24 module extensions.
- Release notes are embedded in the packaging script and there is no project README or changelog.

The correct next milestone is therefore a stabilization release, not a new feature release.

## What is already strong

### Product surface

The app already covers the core collector/player workflow:

- recursive folder discovery for 24 tracker/module extensions;
- metadata extraction through libopenmpt;
- cached library loading;
- title, artist, duration, rating, search, and sorting;
- custom playlists;
- playback controls, seek, repeat, shuffle, next/previous, and automatic advance;
- tracker-pattern visualization;
- main-window and menu-bar playback controls;
- metadata editing, rename, and move-to-Trash;
- Quick Look metadata preview;
- Sparkle 2 package integration and appcast generation.

### Concurrency direction

Direct libopenmpt access is encapsulated in `ModuleActor`. Folder scanning and metadata extraction are moved away from the main actor, while published UI state is owned by the main-actor engine. This is a sound base to refine rather than replace.

### Sandbox intent

The main target stores a security-scoped bookmark and requests user-selected read/write access. Destructive file handling uses the system Trash rather than permanent deletion.

## Findings

### P0: clean builds are not reproducible

Evidence:

- Both app targets set `HEADER_SEARCH_PATHS = /opt/homebrew/include`.
- Both targets include `/opt/homebrew/Cellar/mpg123/1.33.0/lib`.
- A clean Xcode build fails in `AuDeluxeQL-Bridging-Header.h` because `libopenmpt/libopenmpt.h` is absent.
- The project bundles `libopenmpt.a` and `libmpg123.a`, but does not bundle their headers.

Observed build result:

```text
fatal error: 'libopenmpt/libopenmpt.h' file not found
** BUILD FAILED **
```

Impact: CI, another developer, and a clean release machine cannot build the project from the repository.

Recommended correction:

1. Vendor the exact libopenmpt and mpg123 headers matching the static libraries, or replace the loose archives with pinned XCFrameworks.
2. Use project-relative header and library paths only.
3. Remove the Homebrew Cellar path.
4. Add a clean-checkout build to CI.

### P0: there is no automated safety net

`xcodebuild -list` reports only `AuDeluxe` and `AuDeluxeQL`; there is no unit-test target.

This is the largest difference from the PixDeluxe release pass, which added tests around the conversion boundary and its failure cases.

The first AuDeluxe tests should protect behavior that can be exercised without an audio device:

- supported-extension matching;
- metadata fallbacks and malformed/unsupported input;
- stable sorting;
- shuffle order preservation;
- next/previous selection within the active playlist;
- playlist filtering and search;
- cache identity and invalidation;
- metadata attribute encoding/decoding;
- rename collision and failure behavior.

Add small fixture modules covering at least MOD, XM, S3M, and IT plus malformed and truncated data.

### P1: shuffle is effectively cancelled by sorting

`toggleShuffle` randomizes `allPlaylistItems`, but every read of `playlistItems` finishes with `sortItems(itemsToShow)`. The UI, next/previous commands, and automatic advance all consume `playlistItems`, so they receive the selected sort order instead of the shuffled order.

Impact: the shuffle button can light up while playback order remains sorted.

Recommended correction: make the effective queue a first-class ordered collection. Apply sorting only when shuffle is off; when shuffle is on, preserve the generated queue and keep the current item anchored.

### P1: pause/resume can discard queued playback

`pause()` calls `playerNode.stop()`, while `resume()` restarts the engine and calls `playerNode.play()` without rescheduling audio. `AVAudioPlayerNode.stop()` is not equivalent to pausing a scheduled queue.

Impact: resume can be silent, jump, or prematurely finish depending on the node's queue state.

Recommended correction: use the node's pause/resume semantics, keep the engine state separate from “has a loaded module,” and add an integration test or a small manual playback harness that observes position before pause, during pause, and after resume.

### P1: seek does not rebuild scheduled audio

Playback pre-renders and schedules ten buffers. `seek(to:)` changes the two libopenmpt module positions but does not stop/reset the player node, invalidate pending completions, or refill the scheduled queue.

Impact: audible playback can continue from pre-seek buffers while the UI/tracker moves to the requested time. Buffer completions from the old queue can also mutate counters after a reset.

Recommended correction: implement seeking as one serialized engine operation:

1. suspend playback and invalidate the current buffer generation;
2. reset scheduled buffers and counters;
3. set both module positions;
4. pre-render a fresh queue;
5. resume only if playback was active.

Generation tokens should make late completion callbacks from an older queue no-ops.

### P1: the supported OS and CPU range is unnecessarily narrow

The project-level deployment target is macOS 15.5. All targets explicitly exclude x86_64, and both bundled archives contain only arm64 code.

Impact:

- Sonoma users cannot install the current build.
- Intel Macs cannot run it.
- The release target is narrower than PixDeluxe's macOS 14.0 baseline.

Recommended correction: decide the product support contract explicitly. To match PixDeluxe, target macOS 14.0 and ship universal XCFrameworks/static libraries. If Apple silicon only is intentional, document it in the README, DMG, website, and artifact name rather than leaving it as an implicit build setting.

### P1: Quick Look covers only one advertised format

The main app accepts 24 extensions, while the Quick Look extension exports and supports only `com.theblifemovement.audeluxe.mod` / `.mod`.

Impact: users do not get previews for XM, S3M, IT, MED, and the other formats that AuDeluxe itself can inspect.

Recommended correction:

- define UTTypes in the containing app's document declarations;
- cover the intended module extensions in Quick Look;
- keep the declaration in one source of truth;
- add malformed/truncated-file tests because Quick Look processes untrusted files outside the main UI.

The Quick Look parser currently reads each complete file into memory. Apply a defensible file-size limit or a streaming/file-callback API before widening registration.

### P1: metadata updates are not transactional

`updateFile` writes title and artist extended attributes before attempting the rename. If the destination already exists or the move fails, metadata has still changed. Extended-attribute write failures are also ignored.

Impact: the dialog can report an unsuccessful rename while silently retaining partial edits.

Recommended correction: validate the destination first, report collisions to the user, make attribute helpers return errors, and update in an order with defined rollback behavior.

### P2: cache invalidation is too weak

The cache is accepted when the selected folder's modification timestamp matches the cached timestamp to the second. Changes inside nested folders, metadata/xattr edits, and some file-content changes need not update the selected root directory timestamp.

Impact: added, removed, renamed, or retagged modules can remain stale until another operation forces a full scan.

Recommended correction: store a lightweight directory fingerprint derived from relevant file URLs, sizes, and modification dates. Explicitly update or invalidate the cache after rating, metadata, rename, and Trash operations.

### P2: scan work is not cancellable or incremental

Each folder change creates a new scan task. The enumerator is materialized into an array and every supported file is synchronously loaded and parsed inside one detached task. An earlier scan can finish after a newer one and overwrite its results.

Impact: large collections can consume unnecessary memory and stale scans can win races.

Recommended correction: keep one scan task, cancel it before starting another, check cancellation during enumeration, and commit results only when the scan generation still matches the selected folder.

### P2: operational errors are mostly invisible

Delete, rename, bookmark, playlist persistence, cache, and playback failures are printed or suppressed. Most users receive no actionable error.

Impact: failed operations look like ignored clicks or lost changes.

Recommended correction: introduce a small user-facing error state for boundary failures and retain structured logging for diagnostics. Do not add retries for deterministic local-file errors.

### P2: release automation and documentation need consolidation

Positive:

- Sparkle is pinned through Swift Package Manager.
- The package script checks the public key, signs the update archive, and updates an appcast.
- Versioned DMG and ZIP artifacts exist for 1.6 build 77.

Gaps:

- there is no AuDeluxe README or changelog;
- release notes are hard-coded in the shell script;
- the DMG README contains manual quarantine-removal instructions;
- `gendmg.sh` installs `create-dmg` as a side effect;
- packaging uses ad-hoc/deep signing and does not establish notarization;
- the clean build currently fails before packaging can be reproduced.

Recommended correction: add `README.md` and `CHANGELOG.md`, source release notes from the changelog, make tooling prerequisites explicit, and separate unsigned local packaging from signed/notarized release packaging.

## Comparison with the PixDeluxe release pass

| Release lens | PixDeluxe | AuDeluxe current state |
| --- | --- | --- |
| Minimum macOS | Sonoma 14.0 | 15.5 |
| Clean dependency setup | Sparkle via SPM; project builds in its prepared environment | Sparkle via SPM, but libopenmpt headers and mpg123 paths depend on Homebrew |
| CPU architecture | Release pass did not deliberately exclude Intel | arm64 archives; x86_64 excluded |
| Automated tests | Conversion and failure-path coverage added | No test target |
| Core correctness pass | ILBM layout, padding, determinism, collisions, cancellation | Shuffle, pause/resume, and seek need correction |
| Batch/long operation UX | Progress, cancellation, per-file results | Scanning has no cancellation/progress or stale-task protection |
| Quick Look hardening | Decoder safety tests and broader extension work | Metadata preview exists, `.mod` only, no safety tests |
| Release docs | Changelog added | No README/changelog; notes embedded in script |
| Reproducible artifact | Versioned Sonoma DMG produced | Existing 1.6_77 artifacts, but current clean build fails |

## Recommended implementation sequence

### Phase 1: make the project build anywhere

1. Pin and vendor libopenmpt/mpg123 headers and binaries as universal XCFrameworks.
2. Remove absolute Homebrew paths and `EXCLUDED_ARCHS`.
3. Set and verify the intended minimum macOS version, preferably 14.0 for parity.
4. Make Debug and Release build from a clean checkout.

Exit criterion: both `AuDeluxe` and `AuDeluxeQL` build with no machine-local dependencies.

### Phase 2: protect and repair the playback boundary

1. Add a unit-test target and module fixtures.
2. Separate sorted library presentation from the effective playback queue.
3. Correct pause/resume.
4. Make seek reset and refill the queue with generation-safe callbacks.
5. Cover next/previous, repeat, shuffle, automatic advance, and active-playlist behavior.

Exit criterion: tests pass and manual playback confirms play, pause, resume, seek, next, repeat, and shuffle using multiple module formats.

### Phase 3: harden files, scanning, and Quick Look

1. Make metadata/rename operations report errors and avoid partial success.
2. Replace weak cache invalidation and cancel stale scans.
3. Expand UTType coverage deliberately.
4. Add Quick Look malformed/truncated/oversized-input coverage.

Exit criterion: library changes appear without stale results, file-operation failures are visible, and Finder previews work safely for the declared formats.

### Phase 4: ship the stabilization release

1. Add README and changelog.
2. Align app and extension versions.
3. Make packaging non-interactive and free of implicit package installation.
4. Produce signed/notarized or clearly labeled unsigned artifacts.
5. Validate the DMG, installed app, Quick Look registration, and Sparkle feed on a clean Sonoma machine.

Exit criterion: a versioned release artifact installs, launches, plays fixture modules, previews declared formats in Finder, and passes its update metadata checks.

## Validation performed

- Inspected the PixDeluxe 1.0 release commit and changelog to establish the comparison criteria.
- Inspected AuDeluxe app, playback engine, module actor, metadata helpers, settings, playlist UI, Quick Look target, entitlements, Xcode settings, and distribution scripts.
- Resolved Sparkle 2.9.4 from the pinned package requirement.
- Listed Xcode targets and schemes; confirmed there is no test target.
- Ran a clean Debug build with a separate derived-data directory.
- Confirmed both bundled static archives are arm64-only.
- Confirmed existing AuDeluxe 1.6 build 77 DMG, ZIP, and appcast artifacts.

Current gate result: **not release-ready**. The first blocking issue is the non-reproducible native dependency setup.
