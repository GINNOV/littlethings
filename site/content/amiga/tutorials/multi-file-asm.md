---
title: "Distributing Assembly Across Multiple Files"
layout: "single"
---

When an assembly program grows beyond a short experiment, keeping everything in
one source file gets painful. Splitting the program into a few focused files
makes it easier to read, reuse, and test small pieces without scrolling through
hundreds of lines.

This tutorial shows a small, practical structure for a 68k Amiga assembly
project built with `vasm` and linked with `vlink`.

## Project Layout

Start with a folder like this:

```text
multi_file_demo/
├── include/
│   └── screen.i
├── src/
│   ├── main.s
│   └── screen.s
└── build/
```

Use `include/` for shared declarations, `src/` for code modules, and `build/`
for object files and the final executable.

## Shared Declarations

`include/screen.i` contains the public symbols that other files can use:

```asm
        xref    OpenDemoScreen
        xref    CloseDemoScreen
```

Keeping declarations in include files gives each source file a small contract.
The caller knows what routines exist without needing to know how they work.

## Main Program

`src/main.s` owns the program flow:

```asm
        include "screen.i"

        section code,code

        xdef    _start

_start:
        bsr     OpenDemoScreen

wait_mouse:
        btst    #6,$bfe001
        bne     wait_mouse

        bsr     CloseDemoScreen
        moveq   #0,d0
        rts
```

This file does not know how the screen module works. It only calls the exported
routines.

## Screen Module

`src/screen.s` owns the screen-related code and exports the routines declared in
`screen.i`:

```asm
        section code,code

        xdef    OpenDemoScreen
        xdef    CloseDemoScreen

OpenDemoScreen:
        ; Set up display state here.
        rts

CloseDemoScreen:
        ; Restore display state here.
        rts
```

`xdef` makes a symbol visible to the linker. `xref` tells a source file that the
symbol exists somewhere else and will be resolved during linking.

## How to Compile and Run with vasm

Assemble each source file into its own object file:

```bash
mkdir -p build
vasmm68k_mot -Fhunk -Iinclude -o build/main.o src/main.s
vasmm68k_mot -Fhunk -Iinclude -o build/screen.o src/screen.s
```

Then link the object files into one Amiga executable:

```bash
vlink -bamigahunk -o build/multi_file_demo build/main.o build/screen.o
```

Mount the `build/` folder in FS-UAE, vAmiga, or Amiga Playground, then run:

```text
multi_file_demo
```

## When to Split Files

Split a file when it has a clear responsibility:

- `main.s` for startup and high-level flow.
- `screen.s` for display setup and cleanup.
- `input.s` for joystick, keyboard, and mouse input.
- `audio.s` for Paula setup and playback routines.
- `assets.s` for binary includes and lookup tables.

Small modules also make it easier to reuse code between tutorials. A joystick
module, for example, can be reused in a sprite tutorial, a game prototype, and a
test program without copying the whole application.

## Common Mistakes

- Forgetting `xdef` on a routine that another file calls.
- Forgetting `xref` or the matching include file in the caller.
- Assembling only `main.s` and not linking the other object files.
- Reusing the same local label names across files without understanding your
  assembler's local-label rules.
- Mixing code and data sections casually, which can make later linking harder.

Keep the contract simple: each file exports what it owns, imports only what it
needs, and leaves the final layout to the linker.
