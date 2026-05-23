include "amiga_custom.i"

;------------------------------------------------------------------------------
; Routine: WaitVBlank
; Purpose: Waits for the vertical blanking interval by polling the VHPOSR register.
; Registers Used: D0, D1 (caller must save if needed)
; Condition: The routine assumes the VHPOSR register is readable and that a specific
; condition code indicates VBLANK has begun.
; Returns: Execution continues immediately after the VBLANK condition is met.
;------------------------------------------------------------------------------
WaitVBlank:
    move.l  $0,d0             ; Clear D0 (good practice)
    cli     #0                ; Disable interrupts during the wait (optional, but safer)

WaitLoop:
    ; Read the current status of the custom chips.
    ; In a real implementation, this read would be a specific I/O operation
    ; or mapped memory read of the VHPOSR equivalent.
    move.l  $VHPOSR,d1        ; Read the Video Horizontal Position Status Register

    ; Check the VBLANK flag bit.
    ; Assume bit 0 is the VBLANK indicator bit.
    and.l   #$00000001,d1    ; Isolate the VBLANK flag
    beq.s   #$0,EQUIV_VBLANK_SET ; If the flag is zero, VBLANK has started.

    ; If VBLANK has not started, spin in place.
    bra     WaitLoop          ; Busy wait

    ; Execution continues here once the loop breaks (VBLANK has begun)
    rc             #0

    relse    #0,d0             ; Restore D0 if necessary
    rc             #1                ; Return from subroutine

        bze     WaitVBlank_Exit   ; If the wait was successful, exit cleanly

WaitVBlank_Exit:
    relse    #0,d0             ; Restore D0
    rc             #0                ; Return from subroutine

        rc