# Lesson 07: Structs Are Offsets

## Idea

In assembly, a struct is just bytes in memory. Field names are constants that describe offsets from the start.

## Swift Comparison

Swift:

```swift
struct Player {
    var lives: UInt8
    var level: UInt8
    var score: UInt16
}
```

68k:

```asm
player_lives equ 0
player_level equ 1
player_score equ 2
```

If `a0` points at a player record, `player_score(a0)` means "the score field inside this player".

## Practice

Open `src/07_record_offsets.s`.

Build:

```sh
make lesson LESSON=07_record_offsets
```

Change the initial data so the final score is `2500`.

Then add a `player_energy` byte after `player_level`. Update the offsets and keep the score working.

## What To Notice

- Address registers are perfect for pointing at records.
- Offset constants make raw memory readable.
- You must maintain layout yourself. There is no compiler checking the struct for you.

