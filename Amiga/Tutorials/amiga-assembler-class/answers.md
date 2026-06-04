# Answer Key and Tracing Notes

Use this only after you have tried the exercises. The point is not to be fast. The point is to learn to simulate the CPU in your head.

## 00 Minimal

If you change `moveq #0,d0` to `moveq #5,d0`, the program returns with `d0 = 5`.

## 01 Registers

Original trace:

| Instruction | `d0` |
| --- | --- |
| `moveq #10,d0` | 10 |
| `addq.l #7,d0` | 17 |
| `subq.l #2,d0` | 15 |

One way to make `42`:

```asm
        moveq   #40,d0
        addq.l  #4,d0
        subq.l  #2,d0
```

## 02 Memory and Labels

Original values:

- `score` loads `1200` into `d0`.
- `d1` is cleared because loading one byte into `d1` does not automatically clear all upper bits.
- Final `d0` is `1203`.

One way to make `1500`: set `score` to `1497` and keep `lives` at `3`.

## 03 Branches and Loops

Original loop adds `5 + 4 + 3 + 2 + 1`, so `d0 = 15`.

For `1...10`, start `d1` at `10`.

## 04 Stack and Subroutines

To triple `d0`, keep a copy, double, then add the copy:

```asm
double_d0:
        movem.l d1,-(sp)
        move.l  d0,d1
        add.l   d0,d0
        add.l   d1,d0
        movem.l (sp)+,d1
        rts
```

The name `double_d0` should then be renamed because names matter.

## 05 DOS Print

The length expression `msg_end-msg` is assembled into a number. If the message gets longer or shorter, the length stays correct as long as `msg_end` remains immediately after the message bytes.

## 06 Conditions

If `player_lives` is `0`, the `beq.s .dead` branch is taken and the state becomes `0`.

For the bonus state, compare against `5` before the normal alive path.

## 07 Record Offsets

Original score path:

1. `a0` points to `player`.
2. `move.w player_score(a0),d0` loads `1200`.
3. `add.w #300,d0` makes `1500`.
4. `move.w d0,player_score(a0)` stores it back.

To end at `2500`, set the initial score to `2200`.

