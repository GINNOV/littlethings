# ADFinder release-readiness analysis

Date: 2026-07-29

## Remediation status

The release-integrity pass described below was completed on 2026-07-29:

- the published 1.2.4 signature was recovered from the malformed value and
  cryptographically verified against the embedded public key and DMG bytes;
- future updates now use a signed ZIP and validated appcast workflow;
- Sparkle's sandboxed installer keys and entitlements are configured;
- HDF registration, schemes, deployment settings, and entitlements are fixed;
- an ADFinder test target now covers comparison behavior and document metadata;
- README, changelog, DMG instructions, and website source are updated.

The larger test-fixture expansion and core-file refactoring remain appropriate
follow-up work, but are no longer blockers for the release pipeline.

## Executive summary

ADFinder is a substantial, working macOS application. Its current source builds
successfully with Xcode 26.6 on Apple silicon and Sparkle 2.9.2 resolves
correctly. It already offers a broad feature set: ADF and HDF access, file and
directory operations, disk creation, inspection, comparison, export, Quick
Look, App Intents, recent files, and an in-app update command.

It has not yet received the release-hardening pass applied to PixDeluxe and
AuDeluxe. The most important gaps are:

1. The published Sparkle 1.2.4 signature is malformed, so the current update
   feed cannot authenticate that release correctly.
2. The packaging script contains the same signature-handling bug that produced
   the malformed feed.
3. There is no test target.
4. A normal Debug build changes the project build number.
5. The bundled `libadf.a` is arm64-only and the app requires macOS 15.
6. The website links to the whole releases directory rather than the current
   ADFinder download and does not explain the unnotarized-app installation path.

The application is in a good position for a focused hardening pass. The release
pipeline should be repaired before publishing another build.

## Verified current state

- `xcodebuild -project ADFinder.xcodeproj -list` succeeds.
- The project contains one application target and no test target.
- A clean Debug build succeeds with code signing disabled.
- Sparkle 2.9.2 resolves through Swift Package Manager.
- The application target is version 1.2.4, build 1238.
- The application target has a macOS 15.0 deployment target.
- The checked-in `libadf.a` contains only the arm64 architecture.
- The published appcast and the 1.2.4 DMG are reachable over HTTPS.
- The ADFinder working tree was clean before and after this review.

## Priority 0: repair the Sparkle release path

### Published signature is invalid

The latest enclosure has an `edSignature` whose value contains an entire
attribute fragment:

```text
sparkle:edSignature="…signature…" length="7917850"
```

Only the base64 signature belongs in `sparkle:edSignature`.

The cause is in `distribution/build_and_package.sh`. Sparkle's `sign_update`
prints an attribute fragment, but the script assigns the whole output to
`SIGNATURE` and then writes that string as the XML attribute value. PixDeluxe
and AuDeluxe already extract the signature and length separately.

Recommended correction:

- create a ZIP of `ADFinder.app` for Sparkle, while retaining the DMG for manual
  installation;
- sign the ZIP;
- extract only `sparkle:edSignature` and `length` from `sign_update`;
- fail if either parsed value is empty;
- generate a single item per version/build;
- validate the generated XML and enclosure URL before declaring success.

The existing 1.2.4 item should be regenerated from a known-good application
artifact and key. Editing the XML text alone is not enough unless the original
signature can be independently recovered and verified.

### Feed history needs cleanup

The feed contains two entries for 1.2.3/build 1237 and an older unsigned entry
whose length is zero. Keep one valid item per build and remove unusable
historical entries.

### Automatic checks versus “What’s New”

`SPUStandardUpdaterController` starts Sparkle correctly and the menu command is
present. The app's `checkForUpdates()` helper does not check for an update; it
only presents “What’s New.” The name obscures the behavior and makes the launch
flow difficult to reason about.

Recommended correction:

- rename the app helper to describe the “What’s New” behavior;
- let Sparkle own its configured automatic-check schedule;
- keep the explicit “Check for Updates…” menu command;
- simplify `UpdaterController` to the same small wrapper used by PixDeluxe.

## Priority 1: introduce a safety net

ADFinder has no test target, despite having more mutation-heavy behavior than
either of the recently hardened applications. The first tests should focus on
boundaries that can run without UI automation:

- ADF/HDF type recognition and declared filename extensions;
- directory listing and path navigation;
- create, rename, delete, and recursive-delete behavior;
- protection-bit handling, including forced and non-forced operations;
- importing and exporting nested file structures;
- disk comparison results for equal, changed, truncated, and invalid images;
- bookmark and recent-file behavior;
- App Intent temporary-copy behavior;
- corrupt or unsupported image failures.

Small checked-in fixture images should cover OFS, FFS, empty, nested, protected,
and corrupt cases. Tests that mutate images should always work on temporary
copies.

The project should expose one shared scheme containing the application and test
target, so the same command runs locally and in CI.

## Priority 1: stop builds from modifying source control

The Debug scheme has a post-build action that runs `agvtool bump -all`. A normal
diagnostic build changed build 1238 to 1239 and then printed errors while trying
to update unresolved paths. The build still reported success.

Build numbers should be inputs to a release, not side effects of compiling.
Remove this action from Debug. If automatic numbering is desired, assign it once
in the release workflow before archive creation, or derive it from CI.

The Release scheme also contains an empty build entry and an autogenerated test
plan reference despite there being no test target. Replace both schemes with a
single conventional shared scheme once tests exist.

## Priority 1: define the support contract

ADFinder currently ships as:

- macOS 15.0 or later;
- Apple silicon only, because `libadf.a` is arm64-only.

That is narrower than the macOS 14 baseline used for the recent PixDeluxe and
AuDeluxe work. If this is intentional, document it consistently in the README,
website, DMG, and artifact name. If it is not intentional, rebuild ADFlib for
arm64 and x86_64 and lower the deployment target only after compiling and
testing on the intended OS versions.

The project-level deployment target is also 15.4 while the application target
uses 15.0. Use one explicit value to avoid configuration-dependent results.

## Priority 2: fix metadata and permissions

The HDF exported and imported type declarations advertise `adf` as their
filename extension. They should advertise `hdf`. This can affect Finder,
document routing, and “Open With” behavior.

The sandbox includes `com.apple.security.network.server`. ADFinder appears to
need outbound networking for Sparkle, not inbound server access. Remove the
server entitlement unless a real listener requires it.

The three folder usage descriptions are inconsistent and some do not describe
why the requested access benefits the user. They should be reviewed alongside
the actual sandbox access paths.

## Priority 2: reduce architectural risk

The largest source files currently mix several responsibilities:

| File | Approximate nonblank, noncomment lines |
| --- | ---: |
| `ADFService+FileOperations.swift` | 607 |
| `FileHandlers.swift` | 364 |
| `DetailView.swift` | 350 |
| `HelperViews.swift` | 280 |
| `ADFService.swift` | 251 |

The first refactor should be behavior-preserving and test-led:

- split file import/export, mutation, navigation, and recursive traversal into
  narrow ADFlib-facing components;
- move drag/drop and document-loading coordination out of `FileHandlers`;
- move dialogs and selection coordination out of `DetailView`;
- replace optional error strings with typed Swift errors at the ADFlib boundary;
- centralize user-facing error presentation;
- replace scattered `print` calls with the existing logging facility where the
  information is useful, and remove debugging noise where it is not.

Avoid a broad rewrite. Establish tests around each seam, then extract one
responsibility at a time.

## Priority 2: refresh release documentation and website

The README is useful as a feature inventory but needs the release information
that now exists for PixDeluxe and AuDeluxe:

- supported macOS versions and CPU architectures;
- direct download link;
- installation/quarantine instructions for the unnotarized build;
- Sparkle update behavior;
- build and test commands;
- dependency and ADFlib provenance;
- changelog link.

Create a project-level `CHANGELOG.md`. The current release notes are embedded
in the packaging script, which makes them easy to leave stale.

The website's ADFinder Download button currently opens the entire releases
directory. Point it to the current DMG and add the same clear, safe first-install
guidance used for PixDeluxe and AuDeluxe. The “Learn More” page is essentially a
screenshot carousel; it should also state the support contract and link to the
changelog.

## Suggested execution order

### Pass 1 — release integrity

1. Fix the HDF type declaration.
2. Remove build-number mutation from the Debug scheme.
3. repair the packaging script using the proven ZIP/signature pattern.
4. Regenerate and validate the appcast with a new build.
5. Update the direct website download and installation guidance.

Exit criterion: a clean checkout builds without modifying tracked files, and a
fresh install can authenticate and install a Sparkle update.

### Pass 2 — tests and core boundaries

1. Add the ADFinder test target and shared scheme.
2. Add representative disk fixtures.
3. Test comparison and mutation behavior.
4. Test the highest-risk import/export and recursive operations.

Exit criterion: core disk operations have deterministic automated coverage and
the test suite runs from the command line.

### Pass 3 — maintainability

1. Introduce typed errors at the ADFlib boundary.
2. Split the oversized file-operation and UI-coordination files.
3. Consolidate logging and user-facing errors.
4. Decide and document the macOS/architecture support contract.

Exit criterion: the core files have narrow ownership, release behavior is
documented, and future changes can be made behind tests.

## Bottom line

ADFinder is not in poor shape; it is simply one hardening cycle behind the other
two applications. Its app functionality is already broad and the current source
builds. The release pipeline is the urgent issue, because the checked-in
appcast demonstrates that the signing output is being serialized incorrectly.
Fix that first, then add the test target before refactoring the mutation-heavy
core.
