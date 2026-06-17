# Lesson 03: Branches and Loops

## Idea

There is no `if` keyword and no `while` keyword. You build control flow with labels and branch instructions.

The important beginner branch instructions:

| Instruction | Meaning |
| --- | --- |
| `bra` | Branch always |
| `beq` | Branch if equal |
| `bne` | Branch if not equal |
| `bgt` | Branch if greater than |
| `ble` | Branch if less than or equal |
| `dbra` | Decrement and branch while not `-1` |

## Swift Comparison

Swift:

```swift
var total = 0
for n in 1...5 {
    total += n
}
```

68k:

```asm
        moveq   #0,d0
        moveq   #5,d1
.loop:
        add.w   d1,d0
        subq.w  #1,d1
        bne.s   .loop
```

## Practice

Open `src/03_branches_loop.s`.

Trace the loop. Write the value of `d0` after each pass.

Build:

```sh
make lesson LESSON=03_branches_loop
```

Change the code so it adds `1 + 2 + 3 + ... + 10`.

## What To Notice

- A label ending in `:` marks a place in the code.
- `bne.s .loop` jumps back if the previous operation did not produce zero.
- `.s` asks for a short branch when the target is nearby.

