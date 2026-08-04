# send2adf

`send2adf` creates 880 KiB OFS Amiga Disk File images from host files and
directories. Directory input is copied recursively. Supported build hosts are
macOS arm64, macOS x86_64, and Linux x86_64.

## Build and test

CMake 3.24 or newer, Python 3.11 or newer, a C99 compiler, and network access
for the first verified dependency staging are required. ADFlib is not installed
globally and is never selected from a user or system prefix. Both consumers use
`Amiga/Tools/build-support/adflib/ADFlibDependency.cmake`; CMake verifies the
commit-addressed archive, reviewed Git tree, transport digest, materialized
tree, patch digest, and immutable configuration before building a private
static library.

From `Amiga/Tools/send2adf`, configure, build, and test with `cmake --preset ci`,
`cmake --build --preset ci`, and `ctest --preset ci --output-on-failure`.
Equivalent Make targets are `make build`, `make test`, and `make help`.
Sanitizer presets are `asan` and `asan-ubsan`. `make install` always rebuilds
the `production` preset, which rejects test manifest overrides and canary input.

<!-- documented-command -->
```bash
cd Amiga/Tools/send2adf
make help
```

The first staging operation writes only beneath the selected build directory.
A connected fetch may populate its verified cache; subsequent offline rebuilds
must name the exact verified source directory with
`FETCHCONTENT_FULLY_DISCONNECTED=ON` and `FETCHCONTENT_SOURCE_DIR_ADF`.
See [the dependency guide](docs/build_adflib.md).

## Usage

Synopsis: `send2adf -o <output.adf> -N <name> [-B <none|1.3|2.0>] [-v|-vv] <file_or_dir> ...`

- `-o, --output <filename>` is required.
- `-N, --volname <name>` is required.
- `-B, --bootblock <name>` selects `none`, `1.3`, or `2.0`; the default is
  `1.3`.
- `-v, --verbose` enables informational output; `-vv` enables debug output.
- `-h, --help` prints the authoritative synopsis.

Examples: `./build/ci/send2adf -o work.adf -N Workbench -B 1.3 demo.exe
assets` and `./build/ci/send2adf -o data.adf -N Data -B none -vv files`.
Inputs are transactional: validation or copy failure leaves no final output,
and replacement of an existing destination occurs only after verification.

## Dependency updates and releases

Stable updates are opened only by the least-privilege updater application after
candidate tree, transport, license inventory, complete corresponding source,
and both consumers' five native validation legs pass. A no-op creates no branch
or PR. Canary runs use a complete test-only identity, remain read-only, never
package, and cannot update the stable manifest. A consumer or canary failure
deletes only updater-owned validation refs and leases.

There is currently no supported public binary download. A release may be
published only by the protected release workflow after the exact merged
identity has approved license receipts, reproducible archives, source and
binary verification, protected tag/environment rules, and hosted native jobs.
Local packaging and validation do not publish anything. See
[the release contract](docs/releasing.md) and
[the maintainer runbook](docs/build_adflib.md#maintainer-runbook).

The repository's MIT license covers original source where applicable. Because
the program statically links ADFlib, binary distribution follows the
conservative `GPL-2.0-or-later` policy and includes the required notices,
license text, provenance, approval receipts, and complete corresponding source.
Until legal approval is recorded, publication is blocked.

## History

Version 1.5 added filesystem and boot-block selection. The retired standalone
`genboot.cpp` experiment was never part of the build or runtime; its attribution
and implementation remain available in repository history. Additional early
implementation notes are retained in [learned lessons](docs/learned_lesson.md).
See the [changelog](CHANGELOG.md) for the complete release summary.
