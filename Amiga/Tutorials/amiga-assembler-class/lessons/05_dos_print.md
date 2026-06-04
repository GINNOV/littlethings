# Lesson 05: Calling AmigaOS To Print Text

## Idea

Real Amiga programs call libraries. The system library base is at address `4.w`. From there, you can open `dos.library`, ask for the output handle, and call `Write()`.

This is the first lesson where your code talks to AmigaOS.

## Swift Comparison

Swift:

```swift
print("Hello")
```

Amiga assembly has to do the work explicitly:

1. Open `dos.library`.
2. Get the console output handle.
3. Pass the handle, buffer address, and length.
4. Jump to the library vector for `Write()`.

## Practice

Open `src/05_dos_print.s`.

Build:

```sh
make lesson LESSON=05_dos_print
```

Run the executable in your Amiga emulator or AmigaOS-like runner.

Then change the message. Make sure the length still comes from:

```asm
msg_end-msg
```

## What To Notice

- `a6` conventionally holds the library base before calling AmigaOS functions.
- `jsr _LVOWrite(a6)` jumps through the library vector.
- The `_LVO... equ ...` lines are library vector offsets. Later you can get these from NDK include files, but spelling them out makes the first example easier to understand and build.
- AmigaOS calls use specific registers for arguments.
- `lea msg(pc),a0` loads an address. It does not load the bytes of the message.
