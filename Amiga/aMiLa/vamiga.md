# vAmiga RetroShell Notes

This is the working knowledge gathered while making AmigaPlayground pilot vAmiga programmatically for runtime smoke tests. It is intentionally repo-safe: use placeholders for ROMs, ADFs, and artifact paths.

## Launch Model

vAmiga Desktop can be driven by opening a RetroShell script document:

```sh
open -n -a /Applications/vAmiga.app /tmp/session.retrosh
```

This is the most reliable way to get vAmiga to execute an initial script. In vAmiga 4.2.1 source, command-line arguments beginning with `-` are stripped and concatenated into a RetroShell script, but probes with direct executable arguments and `open --args` did not reliably execute commands like `shutdown`. Opening a `.retrosh` document did execute immediately.

For app-bundle installs, prefer LaunchServices:

```sh
/usr/bin/open -n -a /Applications/vAmiga.app /tmp/session.retrosh
```

For non-bundle/headless-style paths, `-source "/tmp/session.retrosh"` is a valid RetroShell command, but do not assume the installed Desktop app will process it reliably as a raw process argument.

## Minimal Boot Script

A practical boot script for an A500-style smoke run:

```text
try amiga init A500_OCS_1MB
try mem load rom "/path/to/kickstart.rom"
try df0 eject
try df0 insert "/path/to/program.adf"
try amiga power on
try amiga reset
```

Notes:
- `try` lets the script continue past command errors while still logging them in RetroShell.
- Useful presets seen in vAmiga 4.2.1 include `A1000_OCS_1MB`, `A500_OCS_1MB`, `A500_ECS_1MB`, and `A500_PLUS_1MB`.
- `df0 insert` accepts an ADF path and swaps it into drive 0.
- `amiga power on` maps to emulator run/power-on behavior; `amiga reset` hard-resets after media insertion.

## Remote Shell Server Configuration

vAmiga config schema changed across versions. The safest patcher writes both sets of keys into `[SRV]`.

vAmiga 4.2.x server indexes:

```text
SER=0
RSH=1
PROM=2
GDB=3
```

For vAmiga 4.2.x Remote Shell, enable:

```ini
[SRV]
AUTORUN1=1
PORT1=8081
PROTOCOL1=0
VERBOSE1=1
```

vAmiga 4.4+ server indexes:

```text
RSH=0
RPC=1
GDB=2
PROM=3
SER=4
```

For vAmiga 4.4+ Remote Shell / related ports, enable:

```ini
[SRV]
ENABLE0=1
PORT0=8080
PROTOCOL0=0
VERBOSE0=1

ENABLE1=1
PORT1=8081
PROTOCOL1=0
VERBOSE1=1

ENABLE3=1
PORT3=8083
PROTOCOL3=0
VERBOSE3=1

ENABLE4=1
PORT4=8085
PROTOCOL4=0
VERBOSE4=1
```

The installed 4.2.1 app ignores unknown `ENABLE*` keys but accepts the `AUTORUN*` keys. This is why writing both schemas is useful.

Important implementation detail: vAmiga reads the user-level config from the real macOS home directory, not an XCTest/app sandbox home. When patching from tests, resolve the POSIX home via `getpwuid(getuid())` rather than trusting `NSHomeDirectory()`.

Always back up `vAmiga.ini` before patching and restore it after automated runs.

## Talking To RetroShell Over TCP

Once the Remote Shell server is listening, it accepts plain TCP. A minimal manual probe:

```sh
nc 127.0.0.1 8081
```

Then type RetroShell commands such as:

```text
help
config
screenshot save "/tmp/emulator-screenshot"
```

For automation, open a TCP stream, write one command plus `\n`, then read briefly for output. Reconnect if needed; vAmiga can close the session after commands that terminate the emulator.

Candidate ports should include both version families:

```text
8080  # vAmiga 4.4+ default RSH when using app defaults
8081  # vAmiga 4.2.x RSH index 1, and also useful as current RPC/default field in the app UI
```

## Screenshots And Raw Frames

RetroShell supports:

```text
screenshot save "/path/to/base-name"
```

It writes a `.raw` file, not PNG. The observed installed vAmiga output is:

```text
716 x 285 pixels
3 bytes per pixel
RGB byte order
no alpha channel
612180 bytes total
```

`screenshot save` also exits the emulator after dumping the frame. For a benchmark loop, launch vAmiga per prompt, wait in the test harness, request `screenshot save` over the Remote Shell TCP connection, then analyze the `.raw` file.

Do not rely on a second `.retrosh` document containing `screenshot save` to capture an already-running emulator. A probe showed it can create a fresh/default vAmiga document and capture a checkerboard/default frame instead of the launched program.

## The `wait` Command Caveat

vAmiga has a hidden RetroShell command:

```text
wait <seconds>
```

It schedules a wakeup on the emulation clock. In practice it was not reliable for smoke automation: scripts like this could stall indefinitely and leave vAmiga running:

```text
wait 2
screenshot save "/tmp/frame"
```

Even `amiga power on` before `wait` did not make it reliable in our probes. Use wall-clock waits in the controlling test/process instead, then send `screenshot save` over TCP.

## Recommended Automation Flow

1. Patch `[SRV]` in `vAmiga.ini` with both 4.2.x and 4.4+ server keys, keeping a backup.
2. Generate a boot `.retrosh` document:

```text
try amiga init A500_OCS_1MB
try mem load rom "/path/to/kickstart.rom"
try df0 eject
try df0 insert "/path/to/program.adf"
try amiga power on
try amiga reset
```

3. Launch vAmiga by opening the script as a document:

```sh
open -n -a /Applications/vAmiga.app /tmp/session.retrosh
```

4. Wait in the controller/test process for the program to render.
5. Connect to RetroShell TCP on candidate ports such as `8081`, `8080` (probe both; do not assume 8080).
   `scripts/validate_emulator_runtime.py` and `AssistantChatSession.retroShellCandidatePorts` already do this.
6. Send:

```text
screenshot save "/path/to/artifacts/emulator-screenshot"
```

7. Wait for `/path/to/artifacts/emulator-screenshot.raw`.
8. Analyze the 3-byte RGB raw frame for non-black pixels and any prompt-specific visual evidence.
9. Terminate any vAmiga instance launched by the test and restore the original `vAmiga.ini`.

## Runtime Smoke Lessons

The good smoke-test signal is:

- vAmiga launches successfully.
- The Remote Shell server accepts a connection.
- `screenshot save` writes a raw frame from the active emulator.
- The raw frame has non-black pixels.
- Text prompts show a bright pixel band in the expected region.
- The benchmark report stores one artifact directory per prompt plus a summary table.

Misleading signals to avoid:

- A raw frame produced by opening a second screenshot document can be a default/checkerboard frame, not the program under test.
- A `.retrosh` script with `wait` can hang before `screenshot save`.
- A successful process launch does not mean the ADF is booting or the Remote Shell server is listening.
- vAmiga 4.2.1 will warn about unknown 4.4+ `ENABLE*` keys; those warnings are expected when writing compatibility config.

