# Add Native vAmiga CPU Trace Backend

## Summary
Add vAmiga as a selectable native macOS emulator/debug backend in AmigaPlayground while keeping FS-UAE working. The primary goal is LLM-oriented CPU tracing: PC, instruction, registers, breakpoints/watchpoints, and enough memory-access/debug output to explain why generated 68k code behaves incorrectly.

This is viable because vAmiga exposes CPU debugger tools, breakpoints/watchpoints, RetroShell scripts, and command/debug consoles in the native app. Sources: [vAmiga UI docs](https://dirkwhoffmann.github.io/vAmiga/docs/Tutorials/Exploring.html), [vAmiga Message Queue docs](https://dirkwhoffmann.github.io/vAmiga/docs/Developer/MessageQueue.html), [Moira/vAmiga CPU integration](https://dirkwhoffmann.github.io/Moira/docs/Tutorials/UsingMoiraInYourOwnApp.html).

## Key Changes
- Refactor `EmulatorService` into a backend-aware service:
  - `fsUAE`: preserve current launch behavior.
  - `vAmiga`: launch `/Applications/vAmiga.app/Contents/MacOS/vAmiga` or a configured path.
  - Shared config model: ADF path, ROM path, model, CPU, RAM, custom args.
- Fix ROM discovery first:
  - Recursively scan `/Users/megov/code/GitHub/littlethings/Amiga/commodore-amiga-firmware`.
  - Return structured ROM entries with display name, relative path, absolute path, and inferred metadata from folder/file names.
  - Stop relying on top-level `kickstart.rom` style names.
- Add vAmiga trace support:
  - Generate a temporary `.retrosh` script/session file for debugger commands.
  - Capture process stdout/stderr or RetroShell remote/debug output when available.
  - Parse trace output into JSONL-like records for LLM consumption:
    `event`, `pc`, `instruction`, `registers`, `sr`, `memoryAccesses`, `breakpoint`, `watchpoint`, `rawLine`.
  - Store generated trace files only under ignored local temp/output paths, never in the firmware or corpus folders.
- Update AmigaPlayground UI:
  - Add "Emulator Backend" picker: `FS-UAE` and `vAmiga CPU Trace`.
  - Rename FS-UAE-specific labels to generic emulator labels where appropriate.
  - Add vAmiga executable path and vAmiga debug args fields.
  - Add a visible "Trace Output"/console mode after launching vAmiga.

## Interfaces
- Add `EmulatorBackend` enum:
  - `fsUAE`
  - `vAmiga`
- Replace `getAvailableRoms() -> [String]` with `getAvailableRoms() -> [RomEntry]`.
- Add launch result types:
  - `EmulatorLaunchResult`: success/failure, backend, message, optional trace path.
  - `CpuTraceRecord`: structured parse target for trace/debug lines.
- Keep compatibility by mapping the old selected ROM string to the new `RomEntry.relativePath` storage value.

## Test Plan
- Unit tests:
  - Recursive ROM discovery finds nested `.rom` files and ignores `.DS_Store`, zips, manifests, and hidden files.
  - Existing FS-UAE argument generation remains unchanged for the same config.
  - vAmiga command construction uses the configured app binary, selected ADF, selected ROM, and debug script path.
  - Trace parser converts representative RetroShell/debugger lines into stable `CpuTraceRecord` values and preserves unknown lines as `rawLine`.
- Manual checks:
  - Compile a known sample in AmigaPlayground and launch with FS-UAE.
  - Compile the same sample and launch with vAmiga CPU Trace.
  - Confirm failure messaging is clear when vAmiga is missing or no legal ROM is configured.
  - Confirm no generated trace, ROM, ADF, or script files are staged by git.

## Assumptions
- Native vAmiga is the target, not vAmigaWeb, because the requested value is CPU/debug tracing rather than visual validation.
- FS-UAE remains available as a stable fallback backend.
- vAmiga 4.4 is installed locally at `/Applications/vAmiga.app`; the implementation should still allow overriding this path.
- If native vAmiga's GUI process cannot provide enough non-interactive trace output, the fallback implementation path is a small adapter around vAmiga Headless/core instead of automating the GUI.
