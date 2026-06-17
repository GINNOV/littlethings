# Lesson 02: Memory, Labels, and Sizes

## Idea

Labels are names for addresses. Data lives at addresses. Instructions can load from those addresses.

68k instructions often include a size:

- `.b` byte: 8 bits
- `.w` word: 16 bits
- `.l` longword: 32 bits

## Swift Comparison

Swift:

```swift
let lives: UInt8 = 3
let score: UInt16 = 1200
let result = Int(score) + Int(lives)
```

68k:

```asm
        move.w  score(pc),d0
        moveq   #0,d1
        move.b  lives(pc),d1
        add.w   d1,d0
```

## Practice

Open `src/02_memory_labels.s`.

Answer before building:

- What is the first value loaded into `d0`?
- Why is `d1` cleared before loading one byte into it?
- What is the final value in `d0`?

Build:

```sh
make lesson LESSON=02_memory_labels
```

Then change `lives` and `score` to make the final result `1500`.

## What To Notice

- `dc.b`, `dc.w`, and `dc.l` define data.
- `label(pc)` means "address relative to the program counter".
- `even` aligns the next data item to an even address, which the 68000 cares about for words and longwords.

