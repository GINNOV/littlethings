# Lesson 04: Stack and Subroutines

## Idea

The stack is memory used in last-in, first-out order. On 68k, `a7` is the stack pointer.

`bsr` branches to a subroutine and saves the return address on the stack. `rts` pulls that address back and continues after the call.

## Swift Comparison

Swift:

```swift
func double(_ value: Int) -> Int {
    value * 2
}

let result = double(21)
```

68k:

```asm
        moveq   #21,d0
        bsr.s   double_d0

double_d0:
        add.l   d0,d0
        rts
```

## Practice

Open `src/04_stack_subroutine.s`.

Build:

```sh
make lesson LESSON=04_stack_subroutine
```

Then modify the helper so it triples the value in `d0` instead of doubling it.

Bonus: use the stack to preserve `d1` while your subroutine borrows it.

## What To Notice

- `movem.l d1,-(sp)` pushes `d1`.
- `movem.l (sp)+,d1` pops `d1`.
- The stack grows downward on 68k.
- Subroutines need agreements: what comes in, what comes out, and which registers are preserved.

