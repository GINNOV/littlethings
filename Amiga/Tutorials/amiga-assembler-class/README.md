# Amiga 68k Assembly From Scratch

This is a practical class for a Swift programmer who is new to assembly. The goal is not to memorize opcodes. The goal is to build a working mental model by reading, tracing, changing, building, and eventually writing small Amiga programs.

## How To Use This Class

### Interactive App

The most practical way to start is the browser app:

```sh
cd interactive-app
npm install
npm run dev
```

It includes lesson navigation, quizzes, progress tracking, an editable beginner 68k simulator, register display, trace output, and a first Amiga hardware-writing lesson.

### Source Lessons

Each lesson has three parts:

1. Read the short idea.
2. Build and inspect the matching source file.
3. Change the code, predict what happens, then build again.

Assembly rewards slow hands. Type changes deliberately and keep a notebook of register values.

## Requirements

The examples use `vasmm68k_mot` in Motorola syntax and build Amiga hunk executables.

From this folder:

```sh
make
make lesson LESSON=03_branches_loop
make clean
```

The later AmigaOS examples use NDK include files. The Makefile defaults to:

```sh
/opt/amiga-ndk-3.9/NDK_3.9/Include/include_i
```

Override it if needed:

```sh
make NDK_I=/path/to/include_i
```

## Class Path

| Lesson | Topic | You learn to |
| --- | --- | --- |
| 00 | Minimal program | Recognize a 68k source file and return from it |
| 01 | Registers | Treat `d0` to `d7` and `a0` to `a7` as tiny explicit variables |
| 02 | Memory and labels | Load constants, read bytes, and understand addresses |
| 03 | Branches and loops | Build `if` and `while` manually with condition codes |
| 04 | Stack and subroutines | Use `bsr`, `rts`, and the stack without fear |
| 05 | AmigaOS calls | Open `dos.library` and print text through `Write()` |
| 06 | Conditions | Compare values and choose paths |
| 07 | Records by offsets | Think of structs as bytes plus named offsets |

## Swift To 68k Mindset

Swift usually hides storage, calling convention, stack frames, and CPU flags. Assembly makes them visible.

| Swift idea | 68k version |
| --- | --- |
| `var total = 0` | Pick a register, for example `moveq #0,d0` |
| `total += 3` | `addq.l #3,d0` |
| `if total == 10` | `cmp.l #10,d0` then branch using condition codes |
| `while count > 0` | A label, a compare or decrement, and a branch |
| `func f()` | A label called with `bsr`, returned with `rts` |
| `struct Player` | A block of memory plus offsets like `player_score equ 2` |
| String | Bytes in memory ending in zero or a known length |

## Daily Practice Loop

Use this for every lesson:

1. Read the source once without editing.
2. Write down the expected final value of `d0`.
3. Build the file.
4. Change one instruction.
5. Predict again.
6. Build again.
7. Explain the program in plain English.

If you can explain every register and label in a program, you are learning assembly for real.
