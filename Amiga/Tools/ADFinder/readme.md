# ADFinder

ADFinder is a native macOS manager for Amiga ADF and HDF disk images. It uses
ADFlib for filesystem access and provides a Finder-like interface for creating,
inspecting, modifying, comparing, and reporting disk images.

## Availability and requirements

ADFinder requires macOS 15 or later. Supported release architectures are Apple
silicon and Intel, but both must pass their hosted native Xcode jobs for the
exact candidate. Public downloads and the Sparkle enclosure are currently
disabled: the older tracked package did not contain the notices, provenance,
approved license receipt, pinned build inputs, and complete corresponding
source now required by the distribution contract. No replacement URL or
version is claimed until compliant bytes exist.

## Dependency and local build

ADFinder and send2adf consume the same immutable manifest at
`Amiga/Tools/build-support/adflib/ADFlibDependency.cmake`. ADFinder's build phase
derives an architecture-qualified private static library from the verified
source root and embeds byte-for-byte identity, transport, and provenance
records. The project contains no vendored headers, archive, system-prefix
fallback, or second ADFlib version.

Before Xcode, stage the manifest identity with
`stage_adflib.py --connected --artifacts <absolute-cache> --print-source-root`
and resolve the pinned Sparkle closure with
`distribution/resolve_swift_packages.py --project ADFinder.xcodeproj
--artifacts <absolute-cache> --print-source-packages-path`. Pass those returned
paths as `ADFLIB_VERIFIED_SOURCE_ROOT` and
`-clonedSourcePackagesDirPath`, add `-disableAutomaticPackageResolution`, and
build only on a supported architecture.

This machine's real app build is blocked by the installed Xcode 26.6 host. A
standalone derived ADFlib/lifecycle/package fixture may be used for local
contract verification, but it is not an ADFinder app-build result. Hosted
macOS arm64 and x86_64 Xcode test and Release-build legs remain required.
See [the shared dependency guide](distribution/docs/build_adflib.md).

<!-- documented-command -->
```bash
python3 Amiga/Tools/ADFinder/distribution/resolve_swift_packages.py --help
```

## Distribution

`distribution/build_and_package.sh` accepts `--project`, `--scheme`,
`--configuration Debug|Release`, `--output`, and `--include-source`. It requires
the verified ADFlib source and offline SwiftPM closure. Generated apps,
archives, DMGs, ZIPs, derived data, and source bundles belong in `.artifacts`
or another ignored output directory, never in `ADFinder/build` or the source
tree.

Local output is unsigned and is never publishable by itself. A public release
requires the exact hosted builds, signing and notarization policy, Sparkle
signature, package license inventory, approved legal receipt, complete
corresponding source including the offline package closure, reproducible
provenance, appcast validation, and protected publication approval. Packaging
must finish before any appcast item or download link is added. See the
[distribution runbook](distribution/docs/README_build_and_package.md).

The ADFinder source is MIT-licensed where applicable. Its statically linked
ADFlib distribution follows the repository's conservative
`GPL-2.0-or-later` packaging policy. Publication fails closed when approval or
source material is incomplete.

## Project links

- [Release history](CHANGELOG.md)
- [Product page](https://ginnov.github.io/littlethings/amiga/index.html)
- [Screenshots](https://ginnov.github.io/littlethings/amiga/adfinder_learnmore.html)
- [Source repository](https://github.com/GINNOV/littlethings/tree/master/Amiga/Tools/ADFinder)
