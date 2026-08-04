# Third-party notices and distribution policy

This file records the repository's conservative technical packaging policy. It
does not itself constitute legal approval. Release automation remains blocked
until the human/legal approval ledger and its authenticated post-merge receipt
are complete.

## ADFlib

`send2adf` and ADFinder use an immutable ADFlib release. Each distributed
package records the exact version, commit, Git tree, and source URL in its
bundled provenance and corresponding-source contract. Repository builds take
the same identity from the canonical ADFlib dependency manifest.

ADFlib's `COPYING` file contains the GNU Lesser General Public License,
version 2.1. It is preserved unmodified; the bundled file has SHA-256
`20e50fe7aae3e56378ebf0417d9de904f55a0e61e4df315333e632a4d3555d95`.
ADFlib source files including `src/adflib.c`, `src/adf_version.h`, and
`src/adf_limits.h` state GNU General Public License version 2 or, at the
recipient's option, any later version. Those source notices must also remain
verbatim. A package must not describe ADFlib as LGPL-only.

The conservative distribution policy is therefore:

- original repository source retains the root MIT license where applicable;
- combined statically linked binaries are distributed under
  `GPL-2.0-or-later`;
- each binary package contains the complete GPL-2.0 text, ADFlib `COPYING`,
  and the ADFlib source-level notices;
- complete buildable corresponding source accompanies every binary release,
  rather than relying on a written offer; and
- the same package-tree contract applies to send2adf and ADFinder.

## Embedded bootblocks

The canonical ledger at
`../build-support/adflib/ADFlibLicenseApprovals.json` records byte hashes and
repository history for every embedded send2adf and ADFinder bootblock. Their
external origin and redistribution terms have not been established. Every
entry is consequently `pending_legal_review`, and release must fail closed
until a human/legal reviewer supplies provenance, terms, and an approval
decision for each exact byte sequence.

## Required release gate

`scripts/check_package_licenses.py` accepts a package only when licenses and
notices are present, corresponding source covers the application, pristine
ADFlib, patches, build helpers, and non-system packaging dependencies, and an
approved ledger entry is bound to the exact merged ledger bytes by a valid
post-merge receipt. Synthetic test approvals under `tests/fixtures` are test
data only and carry no authority.
