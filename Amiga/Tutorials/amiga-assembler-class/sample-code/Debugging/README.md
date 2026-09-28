# Debugging examples

These examples support the debugging labs in the modern learning path.

## Build the loop example

From the course directory, assemble the deliberate off-by-one example with vasm:

```sh
mkdir -p build
vasm -m68000 -Fhunkexe -linedebug -L build/debug-loop.lst \
  -o build/debug-loop sample-code/Debugging/debug-loop.s
```

The program is intended to add one to D0 five times. It loads `5` into D1,
so `DBRA` executes the loop body six times and leaves `D0` equal to `6`.
Change the operand to `#4`, rebuild, and verify that D0 ends at `5`.

The exact debug-information flags vary between assembler versions. Keep the
68000 target, Amiga hunk-executable output, and the assembler's equivalent of
source-line or symbol information.

## Use vAmiga

1. Start vAmiga with a legal Kickstart ROM or an AROS replacement.
2. Select an A500-compatible OCS configuration.
3. Drag `build/debug-loop` into the emulator.
4. Open the CPU Inspector.
5. Set a breakpoint on `count_loop`, or use the program counter if symbols are unavailable.
6. Run to the breakpoint and single-step `ADDQ` and `DBRA`.
7. Record D0, D1, the PC, and the status flags after each `DBRA`.
8. Change `debug-loop.s` to load `#4`, rebuild, and repeat the trace.

The CPU Inspector provides the instruction, register, memory, breakpoint, and
watchpoint views used by this exercise. The Monitor Panel and RetroShell become
useful when later lessons add DMA and custom-chip state.

## Use FS-UAE

Copy `fs-uae-debug.fs-uae.example` to `build/debug.fs-uae`. Replace the
Kickstart path and the host path that contains `debug-loop`.

Launch the configuration:

```sh
fs-uae build/debug.fs-uae
```

From the Amiga Shell, run:

```text
DH0:debug-loop
```

Enter the console debugger with the configured shortcut. FS-UAE documents
`F12+D`; some configurations use the emulator modifier plus `D`. Type `?` to
list the commands for the running build.

Use these commands for the loop trace:

```text
?
r
t
d
g
```

Use `r` to inspect registers, `t` to execute one instruction, `d` to
disassemble near the current PC, and `g` to resume execution.

## Watch a memory write

Build `debug-watchpoint.s` as an Amiga hunk executable, then set a write
watchpoint in FS-UAE before running it:

```text
w 1 $100 2 W
g
```

Inspect the PC and disassembly when execution stops. Clear the watchpoint with:

```text
w 1
```

Address `$100` is used only for this isolated exercise. It overlaps the 68000
exception-vector area, so reset the emulator after the lab and do not use this
address in game code.
