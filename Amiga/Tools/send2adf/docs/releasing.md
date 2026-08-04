# Releasing send2adf

## Authority and trigger

A production release starts only from an annotated tag matching
`send2adf-vMAJOR.MINOR.PATCH` at the reviewed `master` commit, or from the
explicit manual trigger protected by the `send2adf-release` environment. The
tag version must equal the CMake project version. ADFLIB canary identities and
canary runs are prohibited from producing release artifacts.

The protected release must stop before packaging unless tests passed and the
exact ADFlib commit/license inventory has an approved entry in
`Tools/build-support/adflib/ADFlibLicenseApprovals.json`. A separate
post-merge receipt must bind the merge commit, exact ledger bytes, and approval
entry digest. Repository structure, fixtures, or executor judgment never
substitute for human/legal sign-off.

## Published files

Exactly five files are published:

1. `send2adf-<version>-macos-arm64.tar.gz`
2. `send2adf-<version>-macos-x86_64.tar.gz`
3. `send2adf-<version>-linux-x86_64.tar.gz`
4. `send2adf-<version>-source.tar.gz`
5. `SHA256SUMS`

Every binary archive contains the native executable, the repository root MIT
license, `licenses/GPL-2.0.txt`, ADFlib's pristine `COPYING`, verbatim ADFlib
GPL-2.0-or-later source notices, `THIRD_PARTY_NOTICES.md`, `provenance.json`,
and `CORRESPONDING_SOURCE.json`. The corresponding-source record names the
co-hosted source archive, its SHA-256, release tag and URL, and the literal
relationship `accompanying-source`.

The source archive is produced once before any binary archive. It contains all
send2adf source, the pristine verified ADFlib tree, the exact applied ADFlib
patch, dependency manifest, relink/build/package/verification helpers, and the
source of every non-system packaging dependency. Its inventory must enumerate
every regular file; system-provided dependencies are declared separately.
Binary jobs consume that exact sealed source archive and may not recreate it.
The ADFinder distribution uses the same license, notice, approval, and complete
corresponding-source rules for its public binary.

## Reproducibility and validation

Archive paths are sorted bytewise. uid/gid, user/group names, permissions,
gzip headers, and mtimes are normalized from `SOURCE_DATE_EPOCH`. Two clean
package passes with identical inputs must be byte-identical. `SHA256SUMS`
contains the four archive digests in sorted filename order.

Before upload, extract each candidate into a private directory and run:

```sh
python3 Tools/send2adf/scripts/check_package_licenses.py <package-tree>
```

Success is exactly exit 0 with `license_inventory_ok`. Any missing notice,
pending approval, malformed/mismatched post-merge receipt, incomplete source
inventory, source-archive digest mismatch, or canary identity blocks release.
Prefer accompanying source; do not replace it with a written offer.

The release implementation is `scripts/package_release.py`; the independent
inventory reader is `scripts/verify_release.py`. Both use only Python's pinned
standard-library tar/gzip implementation from the checked-out repository.
send2adf publishes tarballs, not a DMG, so Homebrew `create-dmg`, a Homebrew
cache, and user caches are not inputs and the Round 41 offline-DMG cache proof
is not applicable to this product. The workflow records that boundary by never
invoking a DMG tool and by building only from its checkout, runner temporary
directory, and the sealed source artifact.

The finalized packaging CLI is intentionally split into `source`, `binary`,
and `checksums` subcommands. `source` requires the repository root, verified
ADFlib source and transport record, output path, version, and epoch. `binary`
requires that sealed source archive, native executable, approved legal root,
target identity, platform/architecture, toolchain provenance, and source
artifact service identity. `checksums` receives only the already verified
archives. There is no `--triplet` shortcut: local maintainers must use the same
separated authority boundaries as CI.

For a local, non-publishing end-to-end drill, run
`python3 Amiga/Tools/send2adf/tests/test_release_pipeline.py --case
local-success --output "$PWD/.artifacts/release-dry-run"`, then
`python3 Amiga/Tools/send2adf/scripts/verify_release.py --directory
"$PWD/.artifacts/release-dry-run" --native-archive
send2adf-1.5.0-macos-arm64.tar.gz`. The binary observable is
`release_inventory_ok`. The fixture proves deterministic construction and
inventory validation; it is not legal approval, a hosted native matrix, or
permission to publish.

`SOURCE_DATE_EPOCH` is the reviewed tag commit time. Source and binary archives
are each produced twice, with byte equality required before transfer. The
source job is authoritative: triplet jobs download its numeric artifact ID,
verify both the Actions service digest and archive SHA-256, and record that
identity in `provenance.json` and `CORRESPONDING_SOURCE.json`. The upload job
constructs sorted `SHA256SUMS` only after all runner artifacts are downloaded
and re-hashed.

## External authority gates

Repository owners must configure the active `send2adf-release-tags` and
`send2adf-release-leases` rulesets, the `send2adf-release` environment with the
configured maintainer team as reviewer and protected-branch-only deployment,
and the least-privilege `ADFLIB_AUTOMATION_APP` described by the repository
automation policy. The App private-key source remains in the `GI Business`
1Password vault with both `development` and `Projects` tags. The approved
post-merge license receipt is exposed as the base64 repository variable
`ADFLIB_POST_MERGE_LICENSE_RECEIPT_B64`; it is public provenance, not a secret.
An absent receipt, pending bootblock decision, mismatched ruleset/environment,
or unapproved protected job blocks publication.

Local packaging and the protected `mode=validate` workflow never create a tag,
release, release asset, appcast entry, or public download. Hosted native
validation is performed only after the exact-SHA merge-to-default F3 handoff.
