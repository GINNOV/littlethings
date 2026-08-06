; ==========================================================
;   Amiga 68000 Joystick Detection Example
; ==========================================================
            SECTION    Code,CODE
            XDEF       _ReadJoy
_ReadJoy:
            move.w     $dff00c,d0           ; Read JOY1DAT (Joystick 1 Port)

            ; Decode directions
            move.w     d0,d1
            and.w      #$0001,d1            ; Bit 0: Y-axis XOR (Forward)

            move.w     d0,d2
            and.w      #$0002,d2            ; Bit 1: X-axis XOR (Right)

            ; Test for Fire button (Port $bfe001 bit 7 for Joy 0 / CIA bit for Joy 1)
            ; Typically check Game Port 1 custom pin registers
            moveq      #0,d0
            rts
