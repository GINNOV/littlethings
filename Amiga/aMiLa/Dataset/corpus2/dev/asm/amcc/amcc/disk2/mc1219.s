; file mc1219.s		; Fizzle Fade
; not on disk
; no explanation in letter_xx
; only explanation in MW_series	33
	
; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1213.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>sin_vector
; BEGIN>sin
; END>
; SEKA>j	

initial_fizzle_state = 1
pixel_value = 1

start:						; comments from Mark Wrobel
    move.w #$01a0,$dff096	; DMACON disable bitplane, copper, sprite

    ; set up 320x256
    move.w #$1200,$dff100	; BPLCON0 enable 1 bitplane, color burst
    move.w #$0000,$dff102	; BPLCON1 (scroll)
    move.w #$0000,$dff104	; BPLCON2 (video)
    move.w #0,$dff108		; BPL1MOD
    move.w #0,$dff10a		; BPL2MOD
    move.w #$2c81,$dff08e	; DIWSTRT top right corner ($81,$2c)
    ;move.w #$f4c1,$dff090	; DIWSTOP enable PAL trick
    move.w #$38c1,$dff090	; DIWSTOP buttom left corner ($1c1,$12c)
    move.w #$0038,$dff092	; DDFSTRT
    move.w #$00d0,$dff094	; DDFSTOP

    lea.l screen,a1			; address of screen into a1
    lea.l bplcop,a2			; address of bplcop into a2
    move.l a1,d1
    move.w d1,6(a2)			; first halve d1 into addr a2 points to + 6 words
    swap d1					; swap data register halves
    move.w d1,2(a2)			; second halve d1 into addr a2 points to + 2 words

    lea.l copper,a1			; address of copper into a1
    move.l a1,$dff080		; COP1LCH, move long, no need for COP1LCL

    move.w #$8180,$dff096	; DMACON enable bitplane, copper
    
    move.w #initial_fizzle_state,d0 ; initial fizzle state
    move.w #pixel_value,d2	; initial pixel value
    lea.l screen,a1			; address of screen into a1
main:        
    bsr fizzle
    cmp.l #initial_fizzle_state,d0
    bne do_not_toggle_pixel_value
    eor.b #1,d2
do_not_toggle_pixel_value:    
    btst #6,$bfe001			; test left mouse button
    bne main				; if not pressed go to main

exit_main:
    move.w  #$0080,$dff096  ; restablish DMA's and copper
    move.l  $4,a6
    move.l  156(a6),a1
    move.l  38(a1),$dff080
    move.w  #$80a0,$dff096
    rts

; fizzle subroutine
; Fills the screen with pseudo random pixels using LFSR.
; Syntax: (d0=state) = fizzle(d0=state, d2=set_or_clear, a1=screen)
; Arguments: state = state of the LFSR
;            screen = address of the screen buffer 320*256
; Result: d0: state of the LFSR
fizzle:
    movem.l d1/d5/d6,-(a7)
    move.l d0,d5
    and.l  #$1ff00,d0		; mask x value
    lsr.l  #8,d0

    move.l d5,d1
    and.l #$ff,d1			; mask y value

    move.l d5,d6    
    lsr.l #1,d5
    btst #0,d6
    beq lsb_is_zero
    eor.l #$12000,d5		; %0001 0010 000 000 000 - tabs on 17 and 14 length 17
lsb_is_zero:
    cmp.l #320,d0
    bge exit_fizzle
    bsr pixel
exit_fizzle:
    move.l d5,d0
    movem.l (a7)+,d1/d5/d6
    rts

; pixel subroutine
; Draws a pixel on the screeen given an x and y coordinate
; Syntax: pixel(d0=x, d1=y, d2=set_or_clear, a1=screen)
; Arguments: x = The x coordinate
;            y = The y coordinate
;            set_or_clear = If 0 clear pixel, otherwise set pixel
;            screen = address of the screen buffer
pixel:
    movem.l d0-d1/d3-d4,-(a7)
    lsl.w   #3,d1			; multiply d1 with 8 and store in d1
    move.w  d1,d3			; move d1 into d3
    lsl.w   #2,d1			; multiply d1 with 4 and store in d1
    add.w   d3,d1			; store (y*8)+(y*32)=y*40 in d1
    move.w  d0,d4			; move d0 into d4
    lsr.w   #3,d0			; divide d0 with 8 and store in d0
    not.b   d4				; invert d4
    andi.w  #7,d4			; keep 3 least significant bits
    add.w   d1,d0			; add the offsets from x and y 
    tst		d2
    beq     clear_pixel
    bset    d4,(a1,d0.w)	; set the d4'th bit of a1 + d0.w
    bra     cont
clear_pixel:
    bclr    d4,(a1,d0.w)	; set the d4'th bit of a1 + d0.w
cont:
    movem.l (a7)+,d0-d1/d3-d4
    rts						; return from subroutine

copper:
    dc.w $2c01,$fffe		; wait($01,$2c)
    dc.w $0100,$1200		; move to BPLCON0 enable 1 bitplane, color burst

bplcop:
    dc.w $00e0,$0000		; move to BPL1PTH
    dc.w $00e2,$0000		; move to BPL1PTL

    dc.w $0180,$0000		; move to COLOR00 black
    dc.w $0182,$0ff0		; move to COLOR01 yellow

    dc.w $ffdf,$fffe		; wait($df,$ff) enable wait > $ff horiz
    dc.w $2c01,$fffe		; wait($01,$12c)
    dc.w $0100,$0200		; move to BPLCON0 disable bitplane
							; needed to support older PAL chips.
    dc.w $ffff,$fffe		; end of copper

screen:
    blk.b 10240,0			; allocate block of bytes and set to 0

	end