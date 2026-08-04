# ADFinder build and package runbook

`build_and_package.sh` archives an unsigned local app from preverified ADFlib
source and an offline pinned SwiftPM closure, copies the app, embeds and checks
ADFlib provenance, optionally embeds complete corresponding source, then
creates versioned ZIP and DMG candidates in the requested ignored output
directory.

Required host inputs are macOS, a supported Xcode, CMake, Python 3.11 or newer,
the verified ADFlib source root, the lockfile-bound Sparkle closure, and the DMG
assets. Set `ADFLIB_VERIFIED_SOURCE_ROOT` and either set
`ADFLIB_SWIFTPM_SOURCE_PACKAGES` or place the closure at the script's derived
lock-digest path. Automatic package resolution and code signing are disabled
for this local builder.

Options are `--project <path>`, `--scheme <name>`,
`--configuration Debug|Release`, `--output <directory>`, `--unsigned`, and
`--include-source`. Use `--include-source` for a distribution candidate; it
adds ADFinder source, the exact verified ADFlib tree, shared manifest, offline
SwiftPM closure, and lockfile to the app bundle. The public release verifier
must still prove inventory completeness, legal approval, and reproducibility.

Generated app, archive, ZIP, DMG, source bundle, and derived data are local
candidates only. Do not copy them into the tracked release directory or add an
appcast enclosure. Public release additionally requires hosted arm64 and x86_64
native tests and Release builds, signing/notarization policy, a valid Sparkle
signature over the exact ZIP, approved license and post-merge receipts,
corresponding-source verification, protected environment approval, and an
atomic publish transaction.

On failure, remove only the ignored output directory. A missing provenance file,
source root, offline closure, supported architecture, or package output is a
hard stop. A post-merge final-gate failure revokes the dispatch token, preserves
the failed evidence, opens a reviewed manifest-only revert or forward-fix PR,
and starts a fresh UUID/evidence directory after the same two-parent/tree proof.
Receipts and evidence are never reused.

The installed final-verification supervisor is a separate authority. If it is
missing or its launcher/toolchain digest differs from the independently
approved receipt, stop before credential retrieval or dispatch. Repository
fixtures do not satisfy that installed-host requirement.
