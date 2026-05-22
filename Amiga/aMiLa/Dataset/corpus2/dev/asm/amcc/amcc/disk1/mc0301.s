; mc0301.s				; initial bitplane program
; from disk1/brev03
; explanation on letter_03 p. 23
; from Mark Wrobel course letter 13

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0301.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j

start:						; comments from Mark Wrobel
	move.w	#$01a0,$dff096	; DMACON, disable bitplane, copper, sprite

	move.w  #$1200,$dff100  ; BPLCON0, enable 1 bitplane, enable color
	move.w  #0,$dff102		; BPLCON1 (Scroll)
	move.w  #0,$dff104		; BPLCON2 (Sprites, dual playfields)
	move.w  #0,$dff108		; BPL1MOD (odd planes)
	move.w  #0,$dff10a		; BPL2MOD (even planes)

	move.w  #$2c81,$dff08e	; DIWSTRT
	;move.w  #$f4c1,$dff090  ; DIWSTOP (enable PAL trick)
	move.w  #$38c1,$dff090  ; DIWSTOP (PAL trick)
	move.w  #$0038,$dff092  ; DDFSTRT
	move.w  #$00d0,$dff094  ; DDFSTOP

	lea.l   copper,a1
	move.l  a1,$dff080      ; COP1LCH pointet to the copper list

	move.w  #$8180,$dff096  ; DMACON  enable bitplane, enable copper
wait:
	btst    #6,$bfe001		; wait for left mouse click
	bne     wait

	move.w  #$0080,$dff096	; restablish DMA's and copper

	move.l  $4,a6
	move.l  156(a6),a1
	move.l  38(a1),$dff080

	move.w  #$80a0,$dff096

	rts

copper:
	dc.w    $2c01,$fffe		; wait for line $2c
	dc.w    $0100,$1200		; move to $DFF100 BPLCON0, use 1 bitplane, enable color

	dc.w    $00e0,$0000		; move to BPL1PTH, bitplane pointer high
	dc.w    $00e2,$0000		; move to BPL1PTL, bitplane pointer low

	dc.w    $0180,$0000		; move to COLOR00, black
	dc.w    $0182,$0ff0		; move to COLOR01, yellow

	dc.w    $ffdf,$fffe		; wait - enables waits > $ff vertical
	dc.w    $2c01,$fffe		; wait for line - $2c is $12c

	dc.w    $0100,$0200		; move to $DFF100 BPLCON0, disbale bitplanes, enable color
							; needed to support older PAL chips.

	dc.w    $ffff,$fffe		; end of copper

	end
;------------------------------------------------------------------------------

start:							; comments from letter_03 p. 23
	move.w	#$01a0,$dff096		; 96	DMACON		Line 1: Close bitplane-, copper- and sprite-DMA
							
	move.w	#$1200,$dff100		; 100	BPLCON0		Line 3: Sets lores (low resolution 320 * 256) and one bitplane that are 2 colors.
	move.w	#0,$dff102			; 102	BPLCON1		Line 4: Sets scroll value to “0”
	move.w	#0,$dff104			; 104	BPLCON2		Line 5: Sets bitplane-priority to “0”
	move.w	#0,$dff108			; 108	BPL1MOD		Line 6: Sets the modulo for odd bitplanes to “0”
	move.w	#0,$dff10a			; 10a	BPL2MOD		Line 7: Sets the modulo for even bitplanes to “0”
							
	move.w	#$2c81,$dff08e		; 8e	DIWSTRT		Line 9: Sets the upper left corner of the screen to 
								;					position: Y (vertical) = $2C and X (horizontal) = $81
	;move.w	#$f4c1,$dff090		; 90	DIWSTOP		Line 10: Set the bottom right corner of the screen to the
								;					position: Y (vertical) = $F4, X (horizontal) = $C1.
	move.w	#$38c1,$dff090		; 90	DIWSTOP		Line 11: Adds $38 to Y-position, i.e. $f4 + $38 = $12C. X-position is the same.
							
	move.w	#$0038,$dff092		; 92	DDFSTRT		Line 13: Sets data-fetch-start to $0038
	move.w	#$00d0,$dff094		; 94	DDFSTOP		Line 14: Sets data-fetch-stop to $00d0.
							
	lea.l	copper,a1			;	Line 16: Loading copper list's address into Al.
	move.l	a1,$dff080			; 80	COP1LCH		Line 17: Moves the address of the copper-list in Al into the copper-pointer.
							
	move.w	#$8180,$dff096		; 96	DMACON		Line 19: Activates bitplane- and copper-DMA again (not sprite-DMA)
							
wait:							; Line 21: The label “wait”.
	btst	#6,$bfe001			; CIA		Line 22: Check if the left mouse button pressed.
	bne	wait					; Line 23: If mouse button is not pressed, then branch back to the label "wait".
							
	move.w	#$0080,$dff096		; 96	DMACON		Line 25: Turns off copper-DMA
							
	move.l	$4,a6				; Line 27: Copies the longword that is located at address $000004 into register A6.
	move.l	156(a6),a1			; Line 28: Copies the longword A6+156 point to, into register A1.
	move.l	38(a1),$dff080		; 80	COP1LCH		Line 29: Copies the longword A1+38 points to, into the copper-pointer ($DFF080).
							
	move.w	#$80a0,$dff096		; 96	DMACON		Line 31: Opens copper and sprite-DMA again.
							
	rts							; Line 33: Exits the program and returns to the calling instance (e.g. K-Seka)
							
copper:							; Line 35: Label for our copper-list.
	dc.w	$2c01,$fffe			; Wait			Line 36: WAIT ($01, $2C)
	dc.w	$0100,$1200			; $DFF100	BPLCON0		Line 37: MOVE $1200 -> $dff100
							
	dc.w	$00e0,$0000			; $DFF0E0 	BPL0PTH		Line 39: MOVE $0000 -> $dff0E0
	dc.w	$00e2,$0000			; $DFF0E2 	BPL0PTL		Line 40: MOVE $0000 -> $dff0E2
							
	dc.w	$0180,$0000			; Line 42: MOVE $0000 -> $dff180 (black background)
	dc.w	$0182,$0ff0			; Line 43: MOVE $0FF0 -> $dff182 (yellow foreground)
							
	dc.w	$ffdf,$fffe			; Line 45: WAIT ($DF, $FF). This causes the machine to use PAL with 256 lines (in the
								; U.S. another system (NTSC) is used where the Amiga has only 200 lines).
	dc.w	$2c01,$fffe			; Wait			Line 47: WAIT ($01, $2C).
							
	dc.w	$0100,$0200			; $DFF100	BPLCON0		Line 49: MOVE $0200 -> $dff100
							
	dc.w	$ffff,$fffe			; Line 51: The end of the copper-list. Restart the list at the next vertical blank.

	end

				
						
 line 1:	move.w	#$01a0,$dff096	?$01a0	=	0000 0001 1010 0000			bit 15 = 0 (CLR)
								bit 8=1 (bitplane DMA) ,bit 7=1 (copper DMA) und bit 5 = 1 (sprite DMA) --> turn off
								
 line 3:	move.w	#$1200,$dff100	?$1200	=	0001 0010 0000 0000			bit 12 - 14:  001 -
								This is a 3-bit group to specify how many bitplanes are used.
								1 Plane - 2 Farben
								bit 9 - 1
								This bit will be set to "1" to get the color signal video output (no effect on A500).								
								
line 19:	move.w	#$8180,$dff096	?$8180	=	1000 0001 1000 0000			bit 15 = 1 (Set)
								bit 7 = copper DMA --> turn on
								bit 8 = bitplane DMA --> turn on
								
line 25:	move.w	#$0080,$dff096	?$0080	=	0000 000 1000 0000			bit 15 = 0 (Clr)
								bit 7 = copper DMA --> turn off
								
line 31:	move.w	#$80a0,$dff096	?$80a0	=	1000 0000 1010 0000			bit 15 = 1 (Set)
								bit 5 = Sprite DMA --> turn on
								bit 7 = copper DMA --> turn on
