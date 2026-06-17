# Lesson 01: Registers Are Your First Variables

## Idea

The Motorola 68000 has data registers `d0` to `d7` and address registers `a0` to `a7`.

For now:

- Use `d` registers for numbers.
- Use `a` registers for addresses.
- Use `d0` as your "result" register while learning.

## Swift Comparison

Swift:

```swift
var total = 10
total += 7
total -= 2
```

68k:

```asm
        moveq   #10,d0
        addq.l  #7,d0
        subq.l  #2,d0
```

The `.l` suffix means longword: 32 bits.

## Practice

Open `src/01_registers.s`.

Before building, trace it on paper:

| Step | Instruction | `d0` |
| --- | --- | --- |
| 1 | `moveq #10,d0` | ? |
| 2 | `addq.l #7,d0` | ? |
| 3 | `subq.l #2,d0` | ? |

Build:

```sh
make lesson LESSON=01_registers
```

Change the program so the final result is `42`.

## What To Notice

- The destination is usually on the right in Motorola syntax.
- `move source,destination` is the rhythm to learn early.
- Registers are not variables with names. You choose what each register means.

