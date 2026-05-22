; mc0403.s				; 5 bitplane program
; from disk1/brev04
; explanation on letter_04.pdf / p.17
; from Mark Wrobel course letter 14

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0402.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>screen2
; BEGIN>screen
; END>
; SEKA>j

start:						; comments from Mark Wrobel
	move.w #$01a0,$dff096	; DMACON disable bitplane, copper, sprite

	move.w #$5200,$dff100	; BPLCON0 enable 5 bitplanes, color burst
	move.w #0,$dff102		; BPLCON1 (scroll)
	move.w #0,$dff104		; BPLCON2 (video)
	move.w #0,$dff108		; BPL1MOD
	move.w #0,$dff10a		; BPL2MOD

	move.w #$1c71,$dff08e	; DIWSTRT top right corner ($71,$1c)
	;move.w #$f4d1,$dff090	; DIWSTOP enable PAL trick
	move.w #$48d1,$dff090	; DIWSTOP buttom left corner ($1d1,$13C)
							; overscan 352x288
	move.w #$0030,$dff092	; DDFSTRT overscan
	move.w #$00d8,$dff094	; DDFSTOP overscan

	lea.l screen,a1			; address of screen into a1
	move.l #$dff180,a2		; address of COLOR00 into a2
	moveq #31,d0			; color table counter
colorloop:
	move.w (a1)+,(a2)+		; update color table
	dbra d0,colorloop		; loop over all 32 colors registers

	move.l a1,d1			; a1 now points to image data. move to d1
	lea.l bplcop,a2			; address of bplcop into a2
	addq.l #2,a2			; increment address in a2 by 2.
	moveq #4,d0				; update bitplane counter

bplloop:					; setup bitplane pointers
	swap d1					; swap data register halves
	move.w d1,(a2)			; first halve d1 into addr a2 points to
	addq.l #4,a2			; increment address in a2 by 4.
	swap d1					; swap data register halves
	move.w d1,(a2)			; first halve d1 into addr a2 points to
	addq.l #4,a2			; increment address in a2 by 4.
	add.l #12320,d1			; increment d1 to point to next bitplane
	dbra d0,bplloop			; loop over all 5 bitplanes

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
	dc.w $1c01,$fffe		; wait for line $1c
	dc.w $0100,$5200		; move to BPLCON0 enable 1 bitplane, color burst

bplcop:
	dc.w $00e0,$0000		; move to BPL1PTH
	dc.w $00e2,$0000		; move to BPL1PTL
	dc.w $00e4,$0000		; move to BPL2PTH
	dc.w $00e6,$0000		; move to BPL2PTL
	dc.w $00e8,$0000		; move to BPL3PTH
	dc.w $00ea,$0000		; move to BPL3PTL
	dc.w $00ec,$0000		; move to BPL4PTH
	dc.w $00ee,$0000		; move to BPL4PTL
	dc.w $00f0,$0000		; move to BPL5PTH
	dc.w $00f2,$0000		; move to BPL5PTL

	dc.w $ffdf,$fffe		; wait enable wait > $ff horiz
	dc.w $3401,$fffe		; wait for line $134
	dc.w $0100,$0200		; move to BPLCON0 disable bitplane
							; needed to support older PAL chips.
	dc.w $ffff,$fffe		; end of copper

screen:
	blk.l $3c38,0			; allocate block of bytes and set to 0
	;incbin "screen2"
	end

;------------------------------------------------------------------------------

start:						; comments from letter_04.pdf / p.17
	move.w	#$01a0,$dff096	; 96	DMACON		Line 1: Turn off bitplane-, copper- and sprite-DMA.
							
	move.w	#$5200,$dff100	; 100	BPLCON0		Line 3: sets 5 bitplanes.
	move.w	#0,$dff102		; 102	BPLCON1		Line 4: scroll value to 0
	move.w	#0,$dff104		; 104	BPLCON2		Line 5: bitplane priority to 0
	move.w	#0,$dff108		; 108	BPL1MOD		Line 6-7: even and odd modulo to 0
	move.w	#0,$dff10a		; 10a	BPL2MOD		
							
	move.w	#$1c71,$dff08e	; 8e	DIWSTRT		Line 9: Sets the left screen position to $71 and upper line to $1C. This results in
							;					overscan – meaning both the left and upper position 16 PIXEL longer than
							;					normal.
	move.w	#$f4d1,$dff090	; 90	DIWSTOP		Line 10: Sets the right screen position to $D1, bottom line to $F4. 
							;					This will result in that
							;					we get right 16 pixel more. The lower line is now 244 - in other words, not
							;					overscan. It comes in the next line.
	move.w	#$40d1,$dff090	; 90	DIWSTOP		Line 11: Sets the right screen position to $D1, adds $48 the bottom line position. The
							;					bottom line is now been set at $F4 + $40, so overscan.
							;					Line 9-11 has resulted in a screen which is 352 * 280
	move.w	#$0030,$dff092	; 92	DDFSTRT		Line 13: Sets the display data fetch start to $0030 (see earlier for explanation).
	move.w	#$00d8,$dff094	; 94	DDFSTOP		Line 14: Sets display data fetch stop to $00D8. (See earlier for explanation).
							
	lea.l	screen,a1		; Line 16: Loads the effective address of the "screen" into A1.
	move.l	#$dff180,a2		; Line 17: Loads #$DFF180 into A2. $DFF180 as we know is the Color register 0. Please
							; be aware that it is the actual figure is $DFF180 to be loaded into A2 and
							; not a value that address $DFF180 suggests.
	moveq	#31,d0			; Line 18: Loads the number 31 (decimal) into D0. This register is used as numerator.
colorloop:					; Line 19: The label “colorloop”.
	move.w	(a1)+,(a2)+		; Line 20: Copies the value address in A1 points to where the address A2 points to (one
							; word at a time - 2 Bytes). Then increases both addresses in A1 and A2 –
							; meaning that the next time the address in A1 and A2 point to the next word in
							; memory. This instruction will read the color data which are located in the
							; beginning of our image (which we must include after assembling with “ri”)
							; into color registers.
	dbra	d0,colorloop	; Line 21: Decreases D0 by one and tests D0 to be “-1” if not jump back to the "color
							; loop". It will run through the loop 32 times, so that we have initialized all color
							; registers.
	move.l	a1,d1			; Line 23: Copy the content of A1 into D1. A1 points to the first image display data byte.
	lea.l	bplcop,a2		; Line 24: Load the effective address of "bplcop:" into the register A2. This is the location
							; where the bitplane pointers are initialized in the copperlist.
	addq.l	#2,a2			; Line 25: “Add quick” the constant number of 2 to A2.
	moveq	#4,d0			; Line 26: Move “quick” the constant number 4 into D0. D0 is also used to count. This
							; time it counts the Bitplanes (5 planes => it loops until -1)
bplloop:					; Line 28: The label bplloop.
	swap	d1				; Line 29: SWAP is a new instruction, which is used for exchanging the high- with the
							; low-word of a longword (bits 0-15 and bits16-31 respectively) in a register.
	move.w	d1,(a2)			; Line 30: Copy the word content (BIT 0-15 = the low-word) to the address A2 points to.
							; As you see, it will give the upper word from Dl (note that we performed a
							; SWAP before) into the copper-list’s move instruction (into the high-word of
							; the first bitplane pointer). In this case it’s a MOVE instruction to a register.
							; $DFF000 + $00E0 = $DFF0E0 (see explanation copper in issue III), which is
							; bitplane-pointer to bitplane 1. The Bitplane-pointer at the address $DFF0E0
							; must contain the upper word (BIT 16-31 = high-word) of the address of our
							; bitplane data. The address $DFF0E2, which also belongs to bitplane 1, should
							; contain the lower-word (BIT 0-15 = low-word) of the address of our bitplane
							; data. This word is also put into the COPPER-list in line 33. (see table of
							; bitplane-registers in the previous section).
	addq.l	#4,a2			; Line 31: Adds (“quick”) the constant 4 to A2. This causes A2 to point to next COPPERinstruction.
	swap	d1				; Line 32: Exchange high and low-word in D1 again => again in original position.
	move.w	d1,(a2)			; Line 33: Insert the low-word (BIT 0-15) from D1 into address that A2 points to.
	addq.l	#4,a2			; Line 34: Adds (“quick”) the constant 4 to A2.
	add.l	#12320,d1		; Line 35: Add the number 12320 (decimal) in D1. This leads that the address in D1
							; points to the next begin of the bitplane. This is used for copying the address
							; into COPPER-list. The number is calculated as follows: Our screen is 352
							; pixels wide (because we have 16 PIXEL extra on each side) and 352 / 8 = 44
							; bytes. The height of the screen is 280 since we defined 16 PIXEL additional
							; top and bottom, and 44 * 280 = 12320.
	dbra	d0,bplloop		; Line 36: Decrease the register D0 about 1. Test the register D0 for “-1”. If not jump
							; back to "bplloop:" label. This instruction performs the loop 5 times so that we
							; cover all bitplane addresses and copy them into the copper list.
	lea.l	copper,a1		; Line 38: Load the address of the beginning of the copper-list into A1.
	move.l	a1,$dff080		; 80	COP1LCH		Line 39: Move the content of A1 at $DFF080 address - which is copper-pointer.
							
	move.w	#$8180,$dff096	; 96	DMACON		Line 41: Turn on bitplane- and copper-DMA.
							
wait:						; Line 43: The label “wait”.
	btst	#6,$bfe001		; Line 44: Check if the seventh bit (Bit nr. 6) of address $BFE001 is not set (0). Bit No. 6
							; if this address is high ("1") if the left mouse button is not pressed - and "0" if
							; the button is pressed. This instruction will set the Z-flag to "1" if the test was
							; true (i.e. the bit was zero) - and "0" if not (i.e. the bit was set).
	bne	wait				; Line 45: This instruction makes a jump to "wait" if the Z-flag is "1". If the Z-flag is "0"
							; it will continue to the next instruction.
	move.w	#$0080,$dff096	; 96	DMACON		Line 47: Turns off copper-DMA.
							
	move.l	$4,a6			; Line 49: Loads the exec-base to register A6.
	move.l	156(a6),a1		; Line 50-51: Moves the address of the old copper-list back (this is NOT good coding style!)
	move.l	38(a1),$dff080	; 80	COP1LCH		to the copper-pointer. When the old copper-list starts again, it will show the
							; Seka screen (if you started the program from Seka).
	move.w	#$80a0,$dff096	; 96	DMACON		Line 53: Enable copper- and sprite-DMA.
							
	rts						; Line 55: End – return from subroutine meaning that it will give control back to Seka.
							
copper:						; Line 57: Label to the copper-list.
	dc.w	$1c01,$fffe		; Wait		Line 58: The copper instruction represents a WAIT instruction ($01, $1C). This lets the
							; copper wait until the electron beam has reached the start ($01) of line $1C (28
							; decimal). Remember that the copper is a separate processor with its own
							; instructions that MUST not be confused with the main processor (MC68000)
							; and its instructions.
							; While the copper carries out its program (the copper-list) in this program
							; example the MC68000 most of the time does nothing but going through its
							; loop checking if the mouse button has been pressed. Another very important
							; thing is that $01 the position on the line (in this case line $1C) is NOT the
							; position 1 on the screen. The first position of the image (in this case) is $71,
							; representing 112 PIXEL longer to right than the position 1 You must imagine
							; that a screen line starts well outside the "visible" screen (about 5 cm left in the
							; air from the edge of the screen).
	dc.w	$0100,$5200		; $DFF100	BPLCON0		Line 59: Here the COPPER would move the number $5200 at the address $DFF100
							; which is BITPLANE CONTROL 0 register. View previous example.
bplcop:						; Line 61: The label “bplcop”
	dc.w	$00e0,$0000		; $DFF0E0 	BPL0PTH		Line 62: The copper will move the words, which were inserted by the main processor in
							; the line 23-36 and which represent the low-word of the first bitplane address to
							; the bitplane pointer $DFF0E0. As previously mentioned, these are the bits 16-
							; 31 of the address of the bitplane pointer (the high word) to bitplane 1
	dc.w	$00e2,$0000		; $DFF0E2 	BPL0PTL		Line 63: This line performs the same as above, but moves the low-word of the first
							; bitplane address to $DFF0E2, which are the bits 0-15 of the address of the
							; bitplane pointer (the low word) for bitplane 1.
	dc.w	$00e4,$0000		; $DFF0E4	BPL1PTH		Line 64-71: Performs the same as lines 62 and 63, but copies the high and low 
							;						words of the
	dc.w	$00e6,$0000		; $DFF0E6	BPL1PTL		addresses of bitplanes 2, 3, 4 and 5. Understood? We hope so since this is very
	dc.w	$00e8,$0000		; $DFF0E8	BPL2PTH		important that you fully understand this!
	dc.w	$00ea,$0000		; $DFF0EA	BPL2PTL		
	dc.w	$00ec,$0000		; $DFF0EC	BPL3PTH		
	dc.w	$00ee,$0000		; $DFF0EE	BPL3PTL		
	dc.w	$00f0,$0000		; $DFF0F0	BPL4PTH		
	dc.w	$00f2,$0000		; $DFF0F2	BPL4PTL		
							
	dc.w	$ffdf,$fffe		; Line 73: The copper waits for that the electron beam has reached the position on line
							; $DF $FF. Remember that you specify pixel in pairs for the horizontal position
							; in the WAIT instruction, so the actual position in this case is $FD * 2 = $1FA
							; or 506 decimal. The copper-instruction makes it possible to wait for a position
							; which is greater than $FF vertically. Line $100 will now be Line $00. So if we
							; want to wait in line $120 we first carry out this instruction, then we wait for
							; line $20
							
	dc.w	$3401,$fffe		; Wait		Line 75: Wait until line $34 - which is actually the line $134.
							
	dc.w	$0100,$0200		; $DFF100	BPLCON0		Line 77: The copper moves the number $0200 at $DFF100 address. As you see we have
							; at the top of a list a copper-move, which moves $5200 into the same address.
							; You may discover that the value $5200 puts the number of 5 bitplanes (see
							; previous chapter). The number $0200 will put the number to 0 bitplanes, which
							; gives a blank screen. If we don’t do that, we risk that the machine continues
							; drawing up the screen below the defined screen bottom. You will now think of
							; the screen size we defined with DIWSTRT and DIWSTOP?
							; Yes, this is correct… but some machines have an old version of the PAL chip
							; and they have problems when put to a PAL video resolution (a screen which is
							; higher than 200 lines). It is therefore best to use this method so that it works on
							; all AMIGAs.
							
	dc.w	$ffff,$fffe		; Line 79: This copper-instruction is often called STOP. The copper stops and jumps to
							; the beginning of the copper list starting again processing the program. The
							; copper will do this indefinitely until we turn off the copper-DMA.
screen:						; Line 81: Label “screen” to our screen buffer.
	blk.l	$3c38,0			; Line 82: Here we declare our screen buffer. Note that we have set a block of longwords
	;incbin "screen2"
	
	end
							(blk.l). It can be handy if you have much memory, because in some individual
							cases Seka will assemble your program twice as fast. Play with the fill-pattern
							of the block definition to change the content of the bitplanes. This is handy if
							you not include the graphics for this example…
							To get this program to show anything other than a black screen, you must put something into
							the display buffer. You find on the course disk in the directory "BREV04" a file called
							SCRÉEN2. You have already learned how to read in such a file with Seka to a certain
							position (address/label) of your assembled code. Try to load this file to the "screen" label and
							run the program. HAVE FUN!
							