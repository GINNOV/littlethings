# ADFinder

ADFinder is a native macOS manager for Amiga ADF and HDF disk images. It uses
[ADFlib](https://github.com/adflib/ADFlib) for Amiga filesystem access and
provides a Finder-like interface for inspecting and modifying disk images.

## Download and requirements

- Current release: [ADFinder 1.2.5, build 1239](https://github.com/GINNOV/littlethings/raw/master/Amiga/Tools/releases/ADFinder-1.2.5_1239.dmg)
- Requires macOS 15 or later.
- The current build supports Apple silicon Macs.
- The application is free and currently distributed without Apple notarization.

macOS may quarantine the downloaded application. For a free graphical
first-install option, drag ADFinder onto
[Sentinel](https://github.com/alienator88/Sentinel), then choose
**Unquarantine**. Do not use Sentinel's self-sign action. Alternatively, after
copying ADFinder to Applications, run:

```bash
xattr -rc "/Applications/ADFinder.app"
```

Once installed, ADFinder checks for signed updates through Sparkle. You can also
select **ADFinder → Check for Updates…**.

## Features

- Open, create, and save ADF and HDF images.
- Navigate Amiga directories and inspect file metadata.
- Add, export, rename, and delete files and directories.
- Import nested macOS folder structures.
- Respect or explicitly override Amiga protection flags.
- Rename volumes and create OFS or FFS images.
- Inspect disk usage, boot blocks, sectors, and file contents.
- Edit text files and generate directory or hexadecimal reports.
- Compare two disk images sector by sector.
- Preview supported files with Quick Look.
- Open recent images and use supported actions from Shortcuts.

## Build

The checked-in ADFlib archive is currently arm64-only, so build on an Apple
silicon Mac with Xcode:

```bash
cd Amiga/Tools/ADFinder
xcodebuild \
  -project ADFinder.xcodeproj \
  -scheme ADFinder \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

To run the automated tests:

```bash
xcodebuild \
  test \
  -project ADFinder.xcodeproj \
  -scheme ADFinder \
  CODE_SIGNING_ALLOWED=NO
```

ADFlib build notes are in
[distribution/docs/build_adflib.md](distribution/docs/build_adflib.md).

## Releases

The release workflow creates a DMG for first-time installation and a signed ZIP
used by Sparkle for automatic updates.

Release signing expects the Sparkle private key in the macOS Keychain. The
matching public key is stored in `ADFinder/Info.plist`; packaging stops if the
keys do not match. Release artifacts are staged and published together only
after signing and appcast validation succeed.

The dedicated ADFinder key is stored in the `GI Business` 1Password vault under
**ADFinder Sparkle Update Keys**, tagged `development`, `Projects`, and
`Sparkle`. Import its private-key field into the `ADFinder` Sparkle Keychain
account before packaging. Version 1.2.5 is a one-time manual upgrade after the
legacy 1.2.4 key was lost; automatic updates resume after 1.2.5.

See [CHANGELOG.md](CHANGELOG.md) for release history.

## Project links

- [Product page](https://ginnov.github.io/littlethings/amiga/index.html)
- [Screenshots](https://ginnov.github.io/littlethings/amiga/adfinder_learnmore.html)
- [Source repository](https://github.com/GINNOV/littlethings/tree/master/Amiga/Tools/ADFinder)
