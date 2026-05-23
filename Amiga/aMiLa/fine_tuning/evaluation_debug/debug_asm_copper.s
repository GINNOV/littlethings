include "amiga.h"

; Define custom chip register offsets for clarity
; These are offsets relative to the custom chip base address.
; In a real program, these would be mapped into the data segment.
#define COPPER_LIST_BASE    0xDFF000
#define COPPER_LIST_WRITE   (COPPER_LIST_BASE)

; Define the commands
#define COP_SET_INFO        0x00000000 ; Command to set info registers
#define COP_WAIT            0x00000001 ; Command to wait for VBlank
#define COP_WAIT_LINE       0x00000002 ; Command to wait for a specific line

; Define the color values (assuming standard Amiga palette)
#define COLOR_BLUE          0x000000FF
#define COLOR_RED           0xFF000000

; Define the line number to wait for
#define LINE_100            100

; =============================================================================
; ROUTINE: SetCopperSequence
; Purpose: Initializes the Copper lists to achieve the desired color sequence.
; Clobbers: D0-D7, A0-A7
; Returns: Nothing.
; =============================================================================
SetCopperSequence:
    move.l #$0,d0          ; Clear D0 (used for the command word)
    move.l #$0,d1          ; Clear D1 (used for the address/value)

    ; --- Command 1: Set background to Blue ---
    ; Command: Set Info Register (0)
    move.l #%c0,d0        ; Load command word for Set Info
    move.l #COLOR_BLUE,d1 ; Load the desired background color value
    move.w #d0, (COPPER_LIST_WRITE) ; Write command to Copper list
    move.w #d1, (COPPER_LIST_WRITE + 1) ; Write value to Copper list

    ; --- Command 2: Wait for VBlank (or line 100) ---
    ; We need to wait until line 100 to change the color.
    ; This requires a command to wait, followed by the color change.

    ; Command: Wait for Line 100
    move.l #%c0,d0        ; Load command word for Set Info
    move.l #LINE_100,d1   ; Load the line number
    move.w #d0, (COPPER_LIST_WRITE) ; Write command to Copper list
    move.w #d1, (COPPER_LIST_WRITE + 1) ; Write line number to Copper list

    ; --- Command 3: Change background to Red ---
    ; This command executes AFTER the wait is over.
    move.l #%c0,d0        ; Load command word for Set Info
    move.l #COLOR_RED,d1  ; Load the new background color value
    move.w #d0, (COPPER_LIST_WRITE) ; Write command to Copper list
    move.w #d1, (COPPER_LIST_WRITE + 1) ; Write new color to Copper list

    ; --- Command 4: Enable the sequence ---
    ; After setting all commands, we must enable the sequence.
    ; This is usually done by writing to the Playback register.
    move.l #%c9,d0        ; Load command word for Playback
    move.l #0,d1           ; Playback start address (usually 0)
    move.w #d0, (COPPER_LIST_WRITE) ; Write command to Playback
    move.w #d1, (COPPER_LIST_WRITE + 1) ; Write start address

        rts