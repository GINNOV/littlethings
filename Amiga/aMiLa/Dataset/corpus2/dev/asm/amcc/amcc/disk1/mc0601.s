; mc0601.s 				; blitter
; from disk1/brev06
; explanation on letter_06.pdf / p.12
; from Mark Wrobel course letter 18		

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0601
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>object
; BEGIN>object
; END>
; SEKA>j

start:							; comments from Mark Wrobel
	move.w	#$4000,$dff09a		; INTENA clear master interupt
								; turn off disk
	or.b	#%10000000,$bfd100	; CIABPRB Disk
	and.b	#%10000111,$bfd100	; CIABPRB Disk

	move.w	#$01a0,$dff096		; DMACON clear bitplane, copper, blitter

	move.w	#$1200,$dff100		; BPLCON0 1 bitplane and color burst
	move.w	#$0000,$dff102		; BPLCON1 scroll value
	move.w	#$0000,$dff104		; BPLCON2 video priority control
	move.w	#0,$dff108			; BPL1MOD
	move.w	#0,$dff10a			; BPL2MOD
	move.w	#$2c81,$dff08e		; DIWSTRT
	;move.w	#$f4c1,$dff090		; DIWSTOP enable PAL trick
	move.w	#$38c1,$dff090		; DIWSTOP
	move.w	#$0038,$dff092		; DDFSTRT 
	move.w	#$00d0,$dff094		; DDFSTOP

	;----write screen pointer into bplcop
	lea.l	screen,a1			; put screen address into a1
	lea.l	bplcop,a2			; put bplcop address into a2
	move.l	a1,d1				; transfer screen to bitplane 1 pointer in bplcop
	move.w	d1,6(a2)
	swap	d1
	move.w	d1,2(a2)

	;-----transfer copper pointer to custom chip register
	lea.l	copper,a1			; put copper address into a1
	move.l	a1,$dff080			; COP1LCH (and COP1LCL)
	move.w	#$8180,$dff096		; DMACON set bitplane, copper

mainloop:
	;-----busy wait for line 300
	move.l	$dff004,d0			; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0				; shift right 8 positions
	andi.l	#$1ff,d0			; and for immediate data
	cmp.w	#300,d0
	bne	mainloop				; if not at line 300 goto mainloop

	;-----now at line 300---
	bsr	clear					; branch to subroutine clear

	bsr	blitin					; branch to subroutine blitin

	btst	#6,$bfe001			; test left mouse button
	bne	mainloop				; if not pressed goto mainloop

	;-----exit program---
	move.w	#$0080,$dff096		; DMACON clear copper

	move.l	$4,a6				; reestablish DMA's and copper
	move.l	156(a6),a6
	move.l	38(a6),$dff080

	move.w	#$80a0,$dff096

	move.w	#$c000,$dff09a
	rts							; exit program

clear:
	lea.l	screen,a1			; put screen address into a1

waitblit1:						; wait for blitter to finish
	btst	#6,$dff002			; DMACONR test blitter
	bne	waitblit1
	;-----blitter finished---

	;-----because no source only 0's are written to D---
	move.l	a1,$dff054			; BLTDPTH (and BLTDPTL) set to screen
	move.w	#0,$dff066			; BLTDMOD
	move.w	#$0100,$dff040		; BLTCON0 Use D channel - no source, no bool fun
	move.w	#$0000,$dff042		; BLTCON1
	move.w	#$4014,$dff058		; BLTSIZE %0100 0000 0001 0100 (256, 20)
	rts
	;-----end clear subroutine---

pos:
	dc.l	0					; allocate line position counter

blitin:							; blit
	lea.l	pos,a1				; put pos address into a1
	move.l	(a1),d1				; move line position to d1
	addq.l	#1,(a1)				; increment line position

	cmp.w	#216,d1				; blitting 40 lines. 216 + 40 = 256
	bne	notbottom				; if line pos is not 216 goto notbottom

	clr.l	d1
	clr.l	(a1)

notbottom:
	lea.l	screen,a1			; put screen address into a1
	mulu	#40,d1				; unsigned multiply - a line has 40 bytes (320/8)
	add.l	d1,a1				; add lines as number of bytes to start of screen (a1)
	add.l	#12,a1				; center blitting on screen (12 + 16 + 12 = 40)
								; the blit is 16 bytes wide
	lea.l	object,a2			; put object address into a2

waitblit2:						; wait for blitter to finish
	btst	#6,$dff002			; DMACONR test blitter
	bne	waitblit2
	;-----blitter finished---

	move.l	a1,$dff054          ; BLTDPTH (and BLTDPTL)
	move.l	a2,$dff050          ; BLTAPTH (and BLTAPTL)
	move.w	#24,$dff066         ; BLTDMOD (12 + width of blit + 12 = 40)
	move.w	#0,$dff064          ; BLTAMOD
	move.l	#$ffffffff,$dff044  ; BLTAFWM (and BLTALWM) blitter mask
	move.w	#$09f0,$dff040      ; BLTCON0
	move.w	#$0000,$dff042      ; BLTCON1
	move.w	#$0a08,$dff058      ; BLTSIZE %0000 1010 0000 1000 
								; height = 40 lines, width = 8 words -> 128 pixel
	rts                         ; return from blitin
	;-----end blitin subroutine

copper:
	dc.w	$2c01,$fffe			; wait($01,$2c)
	dc.w	$0100,$1200			; BPLCON0 enable 1 bitplane, color burst

	bplcop:
	dc.w	$00e0,$0000			; BPL1PTH
	dc.w	$00e2,$0000			; BPL1PTL

	dc.w	$0180,$0000			; COLOR00 black
	dc.w	$0182,$00ff			; COLOR01 cyan

	dc.w	$ffdf,$fffe			; wait($df,$ff) enable wait > $ff horiz

	dc.w	$2c01,$fffe			; wait($01,$12c)
	dc.w	$0100,$0200			; BPLCON0 disable bitplanes - older PAL chips
	dc.w	$ffff,$fffe			; end of copper

screen:
	blk.l	2560,0				; allocate 10kb and set to zero

object:
	blk.l	160,0				; allocate 640 bytes and set to zero
	;incbin "object"			; for asmone
	end

;------------------------------------------------------------------------------
	
start:							; comments from letter letter_06 p. 12
								;	Line 1-28: Interrupts are and the floppy are disabled. A screen with a bitplane of 320*256
								;	pixel is set up in lores and the copper is started.
								;	Line 30-42: This is the main program loop.
								;	Line 44-53: Retrieving the old screen back and finish the program.
								;	Line 55-67: This is a sub-routine which by the using blitter clears the screen (writes 0 in
								;	all display bitplanes).
								;	Line 72 -103: "This sub-routine" blitt "figure into the screen. This is done through blitt.
								;	Line 105-120: The copper-list.
								;	Line 122-126: The first "BLK" command reserves 10240 bytes for the screen memory. The
								;	second set 640 bytes of data for the image (also on diskette #1).
								;	
								;	Here is a detailed explanation of the new and unknown parts in the program:
	move.w	#$4000,$dff09a		; 9a	INTENA		Line 1-28: This should be known to all now.
							
	or.b	#%10000000,$bfd100					
	and.b	#%10000111,$bfd100					
							
	move.w	#$01a0,$dff096		; 96	DMACON		
							
	move.w	#$1200,$dff100		; 100	BPLCON0		
	move.w	#$0000,$dff102		; 102	BPLCON1		
	move.w	#$0000,$dff104		; 104	BPLCON2		
	move.w	#0,$dff108			; 108	BPL1MOD		
	move.w	#0,$dff10a			; 10a	BPL2MOD
	move.w	#$2c81,$dff08e		; 8e	DIWSTRT
	;move.w	#$f4c1,$dff090		; 90	DIWSTOP
	move.w	#$38c1,$dff090		; 90	DIWSTOP
	move.w	#$0038,$dff092		; 92	DDFSTRT
	move.w	#$00d0,$dff094		; 94	DDFSOP
					
	lea.l	screen,a1			
	lea.l	bplcop,a2			
	move.l	a1,d1			
	move.w	d1,6(a2)			
	swap	d1			
	move.w	d1,2(a2)			
					
	lea.l	copper,a1			
	move.l	a1,$dff080			; 80	COP1LCH
	move.w	#$8180,$dff096		; 96	DMACON		
							
mainloop:							
	move.l	$dff004,d0			; 04	VPOSR		Line 31-35: This routine waits until the electron beam has reached the screen line 300
	asr.l	#8,d0					
	andi.l	#$1ff,d0					
	cmp.w	#300,d0					
	bne	mainloop					
							
	bsr	clear					;			Line 37: Branching to the routine "clear"
							
	bsr	blitin					;			Line 39: Branching to the routinge "blitin"
							
	btst	#6,$bfe001			;	CIA		Lines 41-41: Check whether left mouse button is pressed. If not - then branch back to the
	bne	mainloop				;			 "main loop".
							
	move.w	#$0080,$dff096		; 96	DMACON		Line 44-53: Here the program ends.
							
	move.l	$4,a6					
	move.l	156(a6),a6					
	move.l	38(a6),$dff080		; 80	COP1LCH		
							
	move.w	#$80a0,$dff096		; 96	DMACON		
							
	move.w	#$c000,$dff09a		; 9a	INTENA		
	rts						
							
clear:							;			Line 55: This routine clears the screen (the value 0 is copied in display bitplanes). We
	lea.l	screen,a1			;			 only use the D-channel for this blitt (i.e., no SOURCE channels). This results
								;			 in only zeros are copied to the memory.
								;			Line 56: Load the effective address of the screen memory (screen) into
								;			A1.

waitblit1:						;		Line 58-60: This routine is waiting for the blitter to finish its previous job (or "blitt").
	btst	#6,$dff002			; 02	DMACONR		
	bne	waitblit1					
							
	move.l	a1,$dff054			; 54	BLTDPTH		Line 62: Moves the address of the display memory into the D-channel register.
	move.w	#0,$dff066			; 66	BLTDMOD		Line 63: Sets the modulo for D-channel to 0.
	move.w	#$0100,$dff040		; 40	BLTCON0		Line 64: Selects only D-channel and no logical operation.
	move.w	#$0000,$dff042		; 42	BLTCON1		Line 65: Move the value of 0 into BLTCON1
	move.w	#$4014,$dff058		; 58	BLTSIZE		Line 66: Move the size of the blitt to the BLITSIZE register. The height is set to 256,
								;			 and the width to 20 words (20 * 16 = 320). Write access to this register starts
								;			 the blitter (DMA channels) automatically. So you must at last write to the
								;			 register BLITSIZE ($DFF058). You need not to set any bits in the DMACON
								;			 register ($DFF096) to start the blitter.
								;			
	rts							;			Line 67: Branches back to the main routine.
								;			
pos:							;			Line 69-70: Here we reserved one long-word to store the position of the blitter-object on
	dc.l	0					;			the screen.
								;			
blitin:							;	Line 72: This routine copies the object into the screen using the blitter.
	lea.l	pos,a1				;	Line 73: Load the effective address of object position to the Al register.
	move.l	(a1),d1				;	Line 74: Moves the object position, Al points to, into the D1 register.
	addq.l	#1,(a1)				;	Line 75: Increase the object position by 1 – remember A1 points to it. This means that 1
								;			is added to our long-word and not in the register D1.
	cmp.w	#216,d1				;	Line 77: Compare 216 with D1
	bne	notbottom				;	Line 78: If D1 is not equal to 216, branch to the label "notbottom". This is a check
								;	whether the object has reached the bottom of the screen.
	clr.l	d1					;	Line 80: Clear all bits in D1 (set all bits to zero)
	clr.l	(a1)				;	Line 81: Clear all bits (set all bits to zero) in the object-position - A1 still points to.
								;			
notbottom:						;			
	lea.l	screen,a1			;			Line 84: Loads the effective address of the "screen" to the register A1.
	mulu	#40,d1				;			Line 85: Multiply D1 by 40 This is done because a display line contains 40 bytes. This
								;			 instruction, we have not encountered before, but we think it is self-explanatory.
								;			 However, we will talk about multiplication instructions (signed and unsigned)
								;			 in a later issue. For the curious the MC-68000 also has an instruction
								;			that can perform a division. It looks like this: divu #5, D1
								;			
	add.l	d1,a1				;	Line 86: Add the value located in D1 to the value of A1.
	add.l	#12,a1				;	Line 87: Add the constant of 12 to the value in A1. This makes the object is centered
								;	horizontally on the screen.
	lea.l	object,a2			; Line 89: Load the effective address of the object into A2.
								;			
waitblit2:						; Line 91-93: Wait until a previously started blitt-job is finished.
	btst	#6,$dff002			; 02	DMACONR		
	bne	waitblit2					
							
	move.l	a1,$dff054			; 54	BLTDPTH		Line 95: Move the address in A1 (the display address), to the D-channel register.
	move.l	a2,$dff050			; 50	BLTAPTH		Line 96: Move the address in the A2 (the object address) to the A-channel register.
	move.w	#24,$dff066			; 66	BLTDMOD		Line 97: Set the D-channel modulo to 24
	move.w	#0,$dff064			; 64	BLTAMOD		Line 98: Set A-channel modulo to 0
	move.l	#$ffffffff,$dff044	; 44	BLTAFWM		Line 99: Put A-mask to $FFFFFFFF. The use of this register, will be explained later.
	move.w	#$09f0,$dff040		; 40	BLTCON0		Line 100: Select the channels A and D, and set the logical operation: D = A.
	move.w	#$0000,$dff042		; 42	BLTCON1		Line 101: Move the value 0 into BLTC0N1 ($DFF042)
	move.w	#$0a08,$dff058		; 58	BLTSIZE		Line 102: Set blitt-size, height = 40 (lines) and width = 8 words (8 * 16 = 128 pixels)
	rts							;		which starts the blitt.
								;		Line 103: Return back to the calling instance here the main routine.
copper:							;		Line 105-120: The copper list is declare here
	dc.w	$2c01,$fffe					
	dc.w	$0100,$1200					
							
bplcop:							
	dc.w	$00e0,$0000					
	dc.w	$00e2,$0000					
							
	dc.w	$0180,$0000					
	dc.w	$0182,$00ff					
							
	dc.w	$ffdf,$fffe					
							
	dc.w	$2c01,$fffe					
	dc.w	$0100,$0200					
	dc.w	$ffff,$fffe					
							
screen:							;	Line 122-126: The memory for the screen and the object is reserved.
	blk.l	2560				;	To run this program you must first assemble it and then load the file "object" with the "ri"
								;	command to the label "object". The file is located in the same directory as the source code.
object:							;	Remember that the data for the blitter, the copper, the sprites, etc. must reside in chip ram –
	blk.l	160					;	since the custom-chips have only access to this kind of ram.
	
	end
	
