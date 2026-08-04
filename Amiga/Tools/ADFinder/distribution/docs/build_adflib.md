# ADFlib for ADFinder

ADFinder does not carry or discover a prebuilt ADFlib. Its only dependency
definition is the repository shared manifest at
`Amiga/Tools/build-support/adflib/ADFlibDependency.cmake`. The same immutable
version, commit, Git tree, archive, tree-manifest digest, transport digest,
patch digest, and symlink policy feed send2adf.

`stage_adflib.py` downloads or reuses a verified cache, validates the exact Git
commit/tree relationship and archive bytes, safely extracts the tree, verifies
every materialized entry, and applies the reviewed patch. It emits canonical
identity and transport JSON beside the pristine source. No arbitrary branch,
system package, user cache, copied header, or prebuilt archive is accepted.

ADFinder's Xcode build phase calls `build-for-xcode.sh` with the verified source
root, derived output root, `Debug` or `Release`, and `arm64` or `x86_64`. The
script restages and verifies source, builds a private static `libadf.a`, checks
its architecture, and emits headers, identity, transport, provenance, and a
build stamp under an architecture/configuration-qualified directory. Stable
builds reject overrides. A canary requires CI mode, a complete generated
manifest, and byte-identical identity evidence.

Sparkle is independently pinned by the checked-in SwiftPM lockfile. Resolve it
once into an ignored cache with `resolve_swift_packages.py`; normal Xcode builds
must use that closure with automatic package resolution disabled. A package's
complete corresponding source includes that exact closure and lockfile as well
as ADFinder, ADFlib, the manifest, patch, and build helpers.

This host's real app build is blocked by Xcode 26.6. Local fixture success
demonstrates the derived builder and lifecycle/package boundaries only. It does
not replace the hosted macOS arm64 and x86_64 tests, Release builds, signing,
notarization, package inspection, or legal approval.

## Failure recovery

- A digest, tree, patch, architecture, or identity mismatch stops before the
  app build; discard only the ignored derived/cache directory and restage.
- Missing offline SwiftPM closure stops before package resolution; populate the
  reviewed closure in a connected provisioning step, then retry offline.
- Consumer incompatibility keeps the production manifest unchanged and removes
  only authenticated updater-owned validation state.
- Canary incompatibility is read-only and must never create an app package,
  stable PR, or appcast item.
- Rollback is a reviewed manifest-only revert or forward fix validated by both
  consumers; never manually swap a library or reuse evidence.
