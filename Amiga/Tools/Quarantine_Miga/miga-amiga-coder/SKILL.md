---
name: miga-amiga-coder
description: Generates, builds, and verifies Amiga 68k assembly code. Use when the user wants to create bootable Amiga floppy images (.adf) with specific visual or logical behavior.
---

# Miga Amiga Coder

This skill facilitates the development of Amiga 68k assembly programs within the Miga project framework. It automates the cycle of code generation, assembly, emulation, and behavioral verification.

## Workflow

1.  **Understand Requirements:** Clarify the desired Amiga effect (e.g., Copper list, sprite movement, bitplane scrolling).
2.  **Generate Code:** Write Motorola 68k assembly code to `amiga_workspace/main.s`.
    *   Always include `registers.i` and `hardware/custom.i` for standard Amiga register access.
    *   Use `moveq #0,d0` before `rts` for clean exits in the verifier.
3.  **Build & Evaluate:** Run the evaluation harness to generate the ADF and capture signals.
    ```bash
    export VAMIGA_HEADLESS=1 AMIGA_DISABLE_VERIFY_REGEX=1 AMIGA_VERIFY_ALLOW_NONZERO_EXIT=1
    python3 amiga_eval.py
    ```
4.  **Verify Output:** 
    *   Check `score` in the output (1.000000 is ideal).
    *   Inspect `build/amiga/emulator_capture.png` if visual verification is needed.
    *   Provide the path to `build/amiga/main.adf` to the user for external use.

## Reference Material

- **Register Access:** Use the base address `lea CUSTOM,a6` then offset like `move.w #$7fff,INTENA(a6)`.
- **Copper Lists:**
    *   `WAIT`: `dc.w $YYXX,$fffe`
    *   `MOVE`: `dc.w REGISTER,$VALUE`
    *   `END`: `dc.l $fffffffe`
- **Vertical Blank Sync:**
    ```assembly
    .wait_vblank:
        move.l VPOSR(a6),d0
        and.l #$1ff00,d0
        cmp.l #$300,d0
        bne.s .wait_vblank
    ```

## Resources

- See [amiga-hardware.md](references/amiga-hardware.md) for common register offsets.
- Use [main-template.s](assets/main-template.s) as a starting point.
