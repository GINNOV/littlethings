# Lesson 06: Conditions

## Idea

Comparisons set CPU flags. Branches read those flags.

This is the assembly version of `if`, `else`, and `switch` thinking.

## Swift Comparison

Swift:

```swift
let lives = 2
let state: Int

if lives == 0 {
    state = 0
} else {
    state = 1
}
```

68k:

```asm
        moveq   #2,d0
        cmpi.w  #0,d0
        beq.s   .dead
        moveq   #1,d1
        bra.s   .done
.dead:
        moveq   #0,d1
.done:
```

## Practice

Open `src/06_conditions.s`.

Build:

```sh
make lesson LESSON=06_conditions
```

Change `player_lives` to `0`. Trace which branch executes.

Then add a third state:

- `0` means dead
- `1` means alive
- `2` means bonus life if lives are greater than `5`

## What To Notice

- `cmpi.w #0,d0` compares an immediate value with `d0`.
- Compare instructions do not store a normal result. They update flags.
- Branch names are small, but they encode your program's decisions.

