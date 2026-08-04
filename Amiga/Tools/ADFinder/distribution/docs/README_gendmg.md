# Local DMG helper

`gendmg.sh` converts an already built local ADFinder app into a versioned DMG
with the project README, Applications link, background, and volume icon. It is
a presentation helper, not a dependency resolver, signer, notarizer, license
verifier, appcast editor, or publisher.

Required arguments are supplied by `build_and_package.sh`: README, app, output
base, background image, and volume icon. The final name is derived from the
app's bundle version and build number. Run it only with an ignored output path.

The helper may require the host's `create-dmg` tool. Provision and approve that
tool before a release dry-run; do not let a release job install mutable tooling
or use an unverified user cache. A generated DMG must not be tracked or linked
until the complete ADFinder release transaction has passed hosted native builds,
signing/notarization, legal and corresponding-source verification, package
inspection, reproducibility, and protected publication approval.
