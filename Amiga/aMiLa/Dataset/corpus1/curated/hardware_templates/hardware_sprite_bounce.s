;==============================================================================
; Title:       Amiga Hardware Sprite Position Update
; Assembler:   vasmm68k_mot
; Description: Shows how to dynamically update the 4-byte sprite control header
;              to animate a hardware sprite. Calculates vertical and horizontal
;              start bytes, handles the vertical overflow bit (VSTART bit 8),
;              and sets the control words correctly.
;==============================================================================

    SECTION Code,CODE

; Update hardware sprite control header
; A0 = Pointer to Sprite Data block in Chip RAM (first 4 bytes are header)
; D0 = New X coordinate (0-320)
; D1 = New Y coordinate (0-256)
; D2 = Height in lines of the sprite
UpdateSpriteHeader:
    movem.l d2-d4,-(sp)

    ; Calculate VSTART (Y start)
    move.b  d1,d3               ; Low 8 bits of Y to d3 (Low byte of Word 0)
    
    ; Calculate VSTOP (Y start + height)
    move.w  d1,d4
    add.w   d2,d4               ; Y + Height
    move.b  d4,d2               ; Low 8 bits of VSTOP to d2 (Low byte of Word 1)
    
    ; Calculate HSTART (X start)
    ; In sprite format, X is represented as bits 1-8 in Word 0 byte 1,
    ; and bit 0 of X is represented as bit 0 in Word 1 byte 1.
    move.w  d0,d0
    lsr.w   #1,d0               ; Shift X to fit bits 1-8
    move.b  d0,d0               ; This is HSTART (High byte of Word 0)
    
    ; Build word 0 and word 1 control bits (X/Y bit 8 overflow bits)
    ; Word 0: [ HSTART (8 bits) | VSTART (8 bits) ]
    ; Word 1: [ HSTOP  (8 bits) | Control bits    ]
    ; Let's write them cleanly to the sprite header
    
    ; Set HSTART and VSTART in first word
    move.b  d3,1(a0)            ; Write VSTART to low byte of word 0
    move.b  d0,(a0)             ; Write HSTART to high byte of word 0
    
    ; Set VSTOP in high byte of second word
    move.b  d2,2(a0)            ; Write VSTOP to high byte of word 1 (offset 2)
    
    ; Build the control byte (low byte of word 1, offset 3)
    ; Bit 2: VSTART bit 8
    ; Bit 1: VSTOP bit 8
    ; Bit 0: HSTART bit 0 (X bit 0)
    moveq   #0,d3
    
    ; Check if VSTART (Y) > 255
    cmp.w   #255,d1
    ble.s   .check_vstop
    bset    #2,d3               ; Set VSTART bit 8
    
.check_vstop:
    cmp.w   #255,d4
    ble.s   .check_hstart
    bset    #1,d3               ; Set VSTOP bit 8
    
.check_hstart:
    ; Retrieve X bit 0
    and.w   #1,d0
    beq.s   .write_control
    bset    #0,d3               ; Set HSTART bit 0
    
.write_control:
    move.b  d3,3(a0)            ; Write control bits to low byte of word 1
    
    movem.l (sp)+,d2-d4
    rts
