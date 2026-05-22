; mc0402.s				; 1 bitplane program
; from disk1/brev04
; explanation on letter_04.pdf / p.8 ...
; from Mark Wrobel course letter 14

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0402.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>screen
; BEGIN>screen
; END>
; SEKA>j

start:						; comments from Mark Wrobel
	move.w #$01a0,$dff096	; DMACON disable bitplane, copper, sprite

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
	move.w d1,2(a2)			; first halve d1 into addr a2 points to + 2 words

	lea.l copper,a1			; address of copper into a1
	move.l a1,$dff080		; COP1LCH, move long, no need for COP1LCL

	move.w #$8180,$dff096	; DMACON enable bitplane, copper

wait:
	btst #6,$bfe001			; test left mouse button
	bne wait				; if not pressed go to wait

	move.w  #$0080,$dff096	; restablish DMA's and copper
	move.l  $4,a6
	move.l  156(a6),a1
	move.l  38(a1),$dff080
	move.w  #$80a0,$dff096
	rts

copper:
	dc.w $2c01,$fffe		; wait for line $2c
	dc.w $0100,$1200		; move to BPLCON0 enable 1 bitplane, color burst

bplcop:
	dc.w $00e0,$0000		; move to BPL1PTH
	dc.w $00e2,$0000		; move to BPL1PTL

	dc.w $0180,$0000		; move to COLOR00 black
	dc.w $0182,$0ff0		; move to COLOR01 yellow

	dc.w $ffdf,$fffe		; wait enable wait > $ff horiz
	dc.w $2c01,$fffe		; wait for line $12c
	dc.w $0100,$0200		; move to BPLCON0 disable bitplane
							; needed to support older PAL chips.
	dc.w $ffff,$fffe		; end of copper

screen:
	blk.b 10240,0			; allocate block of bytes and set to 0
	;incbin "Screen"
	end
	
;------------------------------------------------------------------------------
start:							; comments from letter_04.pdf / p.8
	move.w	#$01a0,$dff096		; DMACON, disable bitplane, copper, sprite

	move.w  #$1200,$dff100		; BPLCON0, enable 1 bitplane, enable color
	move.w  #0,$dff102			; BPLCON1 (Scroll)
	move.w  #0,$dff104			; BPLCON2 (Sprites, dual playfields)
	move.w  #0,$dff108			; BPL1MOD (odd planes)
	move.w  #0,$dff10a			; BPL2MOD (even planes)

	move.w  #$2c81,$dff08e		; DIWSTRT
	;move.w  #$f4c1,$dff090		; DIWSTOP (enable PAL trick)
	move.w  #$38c1,$dff090		; DIWSTOP (PAL trick)
	move.w  #$0038,$dff092		; DDFSTRT
	move.w  #$00d0,$dff094		; DDFSTOP

	lea.l	screen,a1			; Line 14: loads the effective address of our buffer into A1.
	lea.l	bplcop,a2			; Line 15: loads the effective address of "bplcop:" (bottom of our copper list) into A2.
	move.l	a1,d1				; Line 16: copy content of A1 to D1.
	move.w	d1,6(a2)			; Line 17: Insert the first 16 bits of D1 where the address in A2+6 points to. (A2 + 6)
								; points to the low-word of bitplane pointer 1 in the copper-list. The number 6 of
								; this instruction is called an offset. This means that 6 bytes are added to the
								; address in A2 but only for this instruction – the address in A2 is not changed.
						
	swap	d1					; Line 18: Swap the first 16 and last 16 bits in D1. This means swap the high-word with
								; the low-word of the register so you can access the high-word with a “move.w”
								; instruction which can only move the lower 16 bit of a register.
	move.w	d1,2(a2)			; Line 19: Insert the first 16 bits of D1 (which actually was the high-word before) into the
								; address as (A2 + 2) which points the high-word of the bitplane pointer 1 in the
								; copper list.

	lea.l   copper,a1
	move.l  a1,$dff080			; COP1LCH pointet to the copper list

	move.w  #$8180,$dff096		; DMACON  enable bitplane, enable copper
wait:
	btst    #6,$bfe001			; wait for left mouse click
	bne     wait

	move.w  #$0080,$dff096		; restablish DMA's and copper

	move.l  $4,a6
	move.l  156(a6),a1
	move.l  38(a1),$dff080		; 80	COP1LCH
	move.w  #$80a0,$dff096		; 96	DMACON
	
	rts

copper:
	dc.w    $2c01,$fffe			; wait for line $2c
	dc.w    $0100,$1200			; move to $DFF100 BPLCON0, use 1 bitplane, enable color
bplcop:	
	dc.w    $00e0,$0000			; move to BPL1PTH, bitplane pointer high
	dc.w    $00e2,$0000			; move to BPL1PTL, bitplane pointer low

	dc.w    $0180,$0000			; move to COLOR00, black
	dc.w    $0182,$0ff0			; move to COLOR01, yellow

	dc.w    $ffdf,$fffe			; wait - enables waits > $ff vertical
	dc.w    $2c01,$fffe			; wait for line - $2c is $12c

	dc.w    $0100,$0200			; move to $DFF100 BPLCON0, disbale bitplanes, enable color
								; needed to support older PAL chips.

	dc.w    $ffff,$fffe			; end of copper

screen:							; Line 53: This is a label for our screen.
	blk.b	10240,0				; try other patterns like $ff, $f0, $00	
	;incbin "Screen"
	
	end


Line 53: Here a block of data is reserved – it is used four our video data.
10240 bytes are enough for a screen with one bitplane and the dimensions of
320 x 256. (320 / 8 = 40. 40 * 256 = 10240. 10240 * 1 = 10240).
In line 54 we set the whole memory to 0 (blk.b 10240,0).
Try now to put a line into this:

53 screen:
54 dc.b $80
55 blk.b 10240, 0

You will now see a pixel at the top of the screen's left corner. You also can
experiment with the fill-pattern of the block, e.g., if you change (the second
parameter of) the instruction blk.b 10240,0 to blk.b 10240,$80 you will see one
pixel wide stripes with a clearance of 8 pixel.

Task 0404: Experiment with other numbers and fill patterns.
In directory "BEV04" of the course disk 1, you find the file labeled "SCREEN".
This file contains an image you can load into your screen buffer. This is done
in K-Seka via the "ri" (READ IMAGE) command. Do this:

Seka> ri
FILENAME> brev4/screen
BEGIN> screen
END>

When prompted with "BEGIN" that indicates the question where you want to load
the file to. You could now enter an absolute address or a label. In this case,
you enter our screen buffer label: "screen" and the file ends up there. On the
question "END" press only RETURN to load the entire file. Remember that you
must assemble the program first. The display buffer is cleared between each
assembling, so you must read it back again.
