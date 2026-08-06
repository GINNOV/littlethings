;-----------------------------------------------------
; anim_sprite.asm
; A complete, ANIMATED Hardware Sprite example
; Takes over the system and moves a sprite using a
; vertical blank interrupt.
;-----------------------------------------------------
CUSTOM          equ     $DFF000
INTENA          equ     $09A  ; Interrupt Enable
INTREQ          equ     $09C  ; Interrupt Request
DMACON          equ     $096
SPR0PTH         equ     $120  ; Sprite 0 pointer HIGH
SPR0PTL         equ     $122  ; Sprite 0 pointer LOW
SPR0POS         equ     $140  ; Sprite 0 Position
SPR0CTL         equ     $142  ; Sprite 0 Control
SPRITE0_PAL1    equ     $1A2  ; Sprite palette color 1
SPRITE0_PAL2    equ     $1A4  ; Sprite palette color 2
SPRITE0_PAL3    equ     $1A6  ; Sprite palette color 3

LVL3_INT_VECTOR equ     $6C   ; Level 3 interrupt vector (CPU address $0000006C)

    SECTION code,CODE

; --- Program Start ---
start:
    lea     CUSTOM,a5
    
    ; --- Save old interrupt vector and disable interrupts ---
    move.l  LVL3_INT_VECTOR.w,old_int_vector
    move.w  #$7FFF,INTENA(a5)   ; Disable all interrupts

    ; --- Wait for vertical blank to safely take over ---
.waitvb:
    move.l  $4(a5),d0           ; Read VPOSR ($DFF004) & VHPOSR ($DFF006) together
    and.l   #$0001FF00,d0       ; Mask 9-bit vertical raster line (V8-V0)
    cmp.l   #$00002C00,d0       ; Wait until vertical line $2C (44)
    bne.s   .waitvb

    ; --- Install our new VBlank interrupt ---
    lea     vblank_interrupt(pc),a0
    move.l  a0,LVL3_INT_VECTOR.w
    
    ; --- Point the hardware to our sprite data ---
    lea     sprite_data,a0
    move.l  a0,SPR0PTH(a5) ; Pointer needs 32-bit access
    
    ; --- Set sprite colors ---
    move.w  #$0F80,SPRITE0_PAL1(a5) ; Red
    move.w  #$0FF0,SPRITE0_PAL2(a5) ; Yellow
    move.w  #$0FFF,SPRITE0_PAL3(a5) ; White

    ; --- Enable DMA and VBlank Interrupt ---
    move.w  #$8100,DMACON(a5)  ; Enable DMA Master and Sprites
    move.w  #$C020,INTENA(a5)  ; Enable Master and VBlank Interrupt

forever_loop:
    btst    #6,$BFE001  ; Check for left mouse click
    bne.s   forever_loop
    
; --- Exit gracefully ---
    move.w  #$0020,INTENA(a5)                ; Disable VBlank interrupt
    move.l  old_int_vector,LVL3_INT_VECTOR.w ; Restore old interrupt vector
    move.w  #$0100,DMACON(a5)                ; Disable Sprite DMA
    rts

; --- Vertical Blank Interrupt Handler ---
vblank_interrupt:
    movem.l d0-d1/a0-a1,-(sp) ; Save registers we are about to use
    lea     CUSTOM,a5
    
    ; --- Reload sprite pointer (prevents OS copper override) ---
    lea     sprite_data,a0
    move.l  a0,SPR0PTH(a5)

    ; --- Animation logic ---
    move.w  sprite_x(pc),d0
    move.w  sprite_dir(pc),d1
    add.w   d1,d0
    
    ; Check boundaries and reverse direction
    cmp.w   #$D0,d0     ; Right edge
    bge.s   .reverse
    cmp.w   #$40,d0     ; Left edge
    ble.s   .reverse
    bra.s   .no_reverse
.reverse:
    neg.w   d1
    move.w  d1,sprite_dir
.no_reverse:
    move.w  d0,sprite_x ; Store new position

    ; --- Update sprite hardware registers ---
    ; SPR0POS: VSTART in bits 15-8, HSTART (X >> 1) in bits 7-0
    move.w  #$64,d1     ; Vertical start position = 100
    lsl.w   #8,d1
    move.w  d0,d0
    lsr.w   #1,d0       ; HSTART = X >> 1
    or.b    d0,d1
    move.w  d1,SPR0POS(a5)
    
    ; SPR0CTL: VSTOP in bits 15-8, bit 0 = H0
    move.w  #$C8,d1     ; Vertical stop position = 200
    lsl.w   #8,d1
    move.w  sprite_x(pc),d0
    andi.w  #1,d0       ; Lowest bit of X (H0)
    or.b    d0,d1
    move.w  d1,SPR0CTL(a5)

    ; --- Acknowledge the interrupt and restore registers ---
    move.w  #$0020,INTREQ(a5) ; Acknowledge VBlank interrupt
    move.w  #$0020,INTREQ(a5) ; Acknowledge again (hardware quirk)
    movem.l (sp)+,d0-d1/a0-a1 ; Restore registers
    rte                   ; Return from Exception

old_int_vector: dc.l 0
sprite_x:       dc.w $80  ; Initial horizontal position
sprite_dir:     dc.w 1    ; Initial direction (1 = right, -1 = left)

; --- Sprite Data Section (MUST BE IN CHIP RAM) ---
    SECTION sprite_chip,DATA_C

sprite_data:
    ; Header words set dynamically by hardware / registers
    dc.w $0000, $0000

    ; Image Data (16 lines of a simple shape)
    dc.w $0180, $0180, $03C0, $03C0
    dc.w $07E0, $07E0, $0FF0, $0FF0
    dc.w $1FF8, $1FF8, $3FFC, $3FFC
    dc.w $7FFE, $7FFE, $FFFF, $FFFF
    dc.w $FFFF, $FFFF, $7FFE, $7FFE
    dc.w $3FFC, $3FFC, $1FF8, $1FF8
    dc.w $0FF0, $0FF0, $07E0, $07E0
    dc.w $03C0, $03C0, $0180, $0180

    ; End of sprite data
    dc.w $0000, $0000
