# Shared ADFlib dependency contract

`send2adf` and ADFinder have one dependency definition:
`Amiga/Tools/build-support/adflib/ADFlibDependency.cmake`. Do not add a second
version, commit, URL, checksum, vendored archive, prebuilt library, package pin,
or system-prefix fallback to either consumer.

The manifest binds the stable version and tag to the exact upstream commit,
Git tree, canonical archive URL, canonical tree-manifest digest, verified
transport and local-cache digests, patch digest, and reviewed symlink
materialization policy. `stage_adflib.py` rejects redirects outside the exact
contract, traversal, special files, submodules, unreviewed symlinks, truncated
trees, tree mismatches, archive mismatches, and patch drift.

## Consumer builds

From `Amiga/Tools/send2adf`, use the `ci`, `production`, `release`, `asan`, or
`asan-ubsan` CMake preset. The `production` and `release` presets prohibit
`SEND2ADF_TESTING` and `ADFLIB_CANARY`. Install with `make install`; no global
ADFlib installation is read or modified.

ADFinder's Xcode build phase invokes `build-for-xcode.sh` with a verified source
root, output root, `Debug` or `Release`, and `arm64` or `x86_64`. The builder
creates an architecture-qualified private `libadf.a`, headers, identity,
transport, build stamp, and `adflib-provenance.json`. Stable builds reject all
test overrides. Canary builds require `ADFLIB_CANARY=ON`,
`ADFLIB_CANARY_CI=1`, a complete generated manifest, and byte-identical
identity evidence.

The real ADFinder app and package require a supported macOS/Xcode host and the
pinned offline SwiftPM closure. Xcode 26.6 is a known blocker on this host, so a
local standalone derived ADFlib/lifecycle/package fixture is evidence only; it
must not be represented as a successful app build. Hosted macOS arm64 and
x86_64 validation remains mandatory.

## Stable update policy

Run `python3 Amiga/Tools/build-support/adflib/update_adflib.py --check` from the
repository root to inspect the latest stable release. Exit 0 means current or
no stable candidate, exit 1 means an approved update is available, exit 2 is a
contract error, and exit 3 means legal review is required. `--dry-run` never
edits the manifest. A real update may replace only the six candidate identity
fields after an exact license-ledger entry and post-merge receipt approve the
candidate inventory and corresponding-source digest.

Scheduled automation creates an updater-owned candidate bundle, validates both
consumers on three send2adf and two ADFinder native legs, and opens or refreshes
one manifest-only PR at the exact tested tip. The automation application may
write only its owned refs, lease records, and PR. It cannot push or merge the
default branch. A current identity is a no-op and leaves no ref, lease, PR, or
artifact.

Canary automation follows the latest upstream default-branch commit with a
complete identity adapter. It never mutates the stable manifest, opens a PR,
uploads a release artifact, or packages either consumer. An incompatible
candidate must produce a deterministic red preflight before build mutation.

## Maintainer runbook

- **No-op:** confirm `status=current` or `status=no_stable_candidate` and that no
  updater-owned ref, lease, PR, or artifact was created.
- **Approved upgrade:** review the manifest-only diff, candidate bundle and
  transport digests, license inventory and receipt, five consumer legs, exact
  tested tip, and two-parent/tree merge proof before merging.
- **Updater failure:** preserve unowned state; remove only authenticated,
  updater-owned validation state. Do not edit the production manifest.
- **Consumer compatibility failure:** keep the stable manifest unchanged,
  delete the owned validation ref and lease, attach failure evidence, and wait
  for a new candidate or consumer fix.
- **Canary failure:** record the read-only failure; do not open a stable PR or
  create packages.
- **Release dry-run failure:** discard only the local staging directory. Never
  create a tag, release, appcast item, or download link from local validation.
- **Supervisor missing or preflight mismatch:** stop before credentials or
  dispatch, preserve all manifests and artifacts, install only the independently
  approved root-owned launcher/toolchain, then start a fresh preflight.
- **Rollback before merge:** close the owned PR and remove its authenticated
  branch/lease. **After merge:** open a reviewed manifest-only revert (or
  forward-fix) PR, validate it through the same five legs, and merge it with the
  same two-parent/tree proof.
- **Post-merge final-gate failure:** abort only owned validation state, revoke
  the dispatch token, open the reviewed revert or forward-fix PR, and start a
  fresh UUID and evidence directory. Never reuse receipts, nonces, tokens, or
  evidence directories.

The final verifier is a separate installed security boundary. Repository
fixtures prove local routing and fail-closed behavior, not installation,
reviewer approval, credentials, hosted checks, or a release verdict.

## Troubleshooting

`manifest_invalid`, `source_tree_mismatch`, `transport_digest_mismatch`, and
`patch_digest_mismatch` mean the immutable inputs disagree; delete only the
local build/cache directory and restage from the reviewed manifest. A stable
override or canary-in-production rejection is intentional. Do not bypass it by
copying headers/libraries or using a system package.
