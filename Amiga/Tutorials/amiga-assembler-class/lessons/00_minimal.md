# Lesson 00: The Smallest Useful Program

## Idea

A 68k program is a list of instructions. The CPU executes one instruction, moves to the next one, and keeps doing that until control returns to whoever started the program.

In these examples, `rts` means "return from subroutine". For a tiny Amiga executable, returning from the first code section is enough to end the program.

## Swift Comparison

This Swift:

```swift
func main() {
    return
}
```

is mentally similar to:

```asm
        rts
```

The assembly version has no hidden runtime, no inferred types, and no safety rails.

## Practice

Open `src/00_minimal.s`.

Build it:

```sh
make lesson LESSON=00_minimal
```

Then change:

```asm
        moveq   #0,d0
```

to:

```asm
        moveq   #5,d0
```

Prediction question: what value is in `d0` when the program returns?

## What To Notice

- `SECTION code,CODE` starts a code section.
- `moveq #0,d0` puts the small immediate value `0` into data register `d0`.
- `rts` exits.
- The CPU does not know your intent. It only sees instructions.

