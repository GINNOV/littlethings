; Pointer: puts a joystick-controlled pointer on the screen.

************************
*   Set up the screen  *
************************
	section	hello,code_c
	include source:include/hardware.i
	move.l	4,a6		Usual stuff for setting up a 3 bitplane screen
	lea	library,a1
	jsr	-408(a6)
	move.l	d0,base
	move.l	#40*256*3,d0
	move.l	#2,d1
	jsr	-198(a6)
	move.l	d0,b1
	move.w	d0,b1l
	swap	d0
	move.w	d0,b1h
	swap	d0
	add.l	#40*256,d0
	move.l	d0,b2
	move.w	d0,b2l
	swap	d0
	move.w	d0,b2h
	swap	d0
	add.l	#40*256,d0
	move.l	d0,b3
	move.w	d0,b3l
	swap	d0
	move.w	d0,b3h
	move.l	#pointer,d0	This is the pointer, sprite 0
	move.w	d0,s0l
	swap	d0
	move.w	d0,s0h
	lea	$dff000,a5
	move.l	#copper,COP1LCH(a5)
	move.w	#0,COPJMP1(a5)
	move.l	b1,a1
	move.l	#30*256,d0
clear	move.l	#0,(a1)+	Clear screen
	dbra	d0,clear
	clr.l	xpos
	move.l	#$29483400,pointer	Put pointer at start (if it's rerun, the sprite pointer needs to be put back at top left hand corner)
	move.l	$6c,oldint+2	Get my interrupt in
	move.l	#inter,$6c

*************************
*  Waits for LMB or FB  *
*************************

wait	btst	#7,$bfe001	Has fire button been pressed
	beq.s	fire		If so, do routine
	btst	#6,$bfe001	Is LMB pressed
	bne.s	wait		No, then loop again
	
**************
*  Clean up  *
**************

	move.l	oldint+2,$6c
	move.l	base,a2
	move.l	38(a2),COP1LCH(a5)
	move.l	#40*256*3,d0
	move.l	b1,a1
	jmp	-210(a6)

***********************************
*  Executed when fire is pressed  *
***********************************

; See explanation of how it works after source first
; At the moment the byte the pointer is pointing to is made into 255
; (all bits set)

fire	clr.l	d0		get ypos into a `clean' d0
	move.w	ypos,d0
	mulu	#40,d0		x 40 (40 bytes per line)
	move.w	xpos,d1		get xpos
	lsr.w	#2,d1		/ 4  (2*2) since xpos counts 1 per 2 bytes (see below)
	add.w	d1,d0		add xpos/4 to d0
	add.l	b1,d0		add start of 1st screen
	move.l	d0,a1		Now d0 pointing to wanted byte.  Put d0 into a1
	move.b	#-1,(a1)	so it can be used to make the byte 255
	bra	wait		and loop back

; At the moment, the fire button is continually registered when pressed.
; If you wait the fire button to be released, it means the fire button
; will only be registered once per press.

*****************
*  Copper List  *
*****************

; much as you'd expect, except for a couple of bits

	even
copper	dc.w	BPLCON0,%11001000000000
	dc.w	BPLCON1,0
	dc.w	BPLCON2,$20	Doing this means that the sprite has priority over the bitplane (making it 0 means the pointer gets hidden when it goes onto a byte that is more than 0)
	dc.w	BPL1MOD,0
	dc.w	BPL2MOD,0
	dc.w	DIWSTRT,$2981
	dc.w	DIWSTOP,$29c1
	dc.w	DDFSTRT,$3d
	dc.w	DDFSTOP,$d0
	dc.w	BPL1PTL
b1l	dc.w	0,BPL1PTH
b1h	dc.w	0,BPL2PTL
b2l	dc.w	0,BPL2PTH
b2h	dc.w	0,BPL3PTL
b3l	dc.w	0,BPL3PTH
b3h	dc.w	0,SPR0PTL
s0l	dc.w	0,SPR0PTH
s0h	dc.w	0
	dc.w	COLOR17,$c00	Red
	dc.w	COLOR18,$cc0	Yellow
	dc.w	COLOR19,0	Black
	dc.w	$ffff,$fffe

; Program variables

b1	dc.l	0
b2	dc.l	0
b3	dc.l	0
base	dc.l	0
library	dc.b	'graphics.library',0,0

*********************************
*  The joystick pointer sprite  *
*********************************

pointer	dc.w	$2948,$3400
	dc.w	%0111110000000000,%0111110000000000
	dc.w	%1000001000000000,%1111111000000000
	dc.w	%1111010000000000,%1000110000000000
	dc.w	%1111101000000000,%1000011000000000
	dc.w	%1111110100000000,%1001001100000000
	dc.w	%1110111010000000,%1010100110000000
	dc.w	%0100011101000000,%0100010011000000
	dc.w	%0000001110100000,%0000001001100000
	dc.w	%0000000111100000,%0000000100100000
	dc.w	%0000000011000000,%0000000011000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	0,0
xpos	dc.w	0
ypos	dc.w	0

***********************
*  The Pointer Mover  *
***********************

; The way the program tests the joystick is exactly the same as my
; `Move_Sprite' program which you may still have but if you're
; sensible you'll have written over.  If you still don't understand
; it, an explanation is at the very end.  It isn't here cos I didn't
; want to patronise you if did understand.

; Some general notes on this part first:

; Since the pointer needs to move over all the screen, the Most
; Significant Bit for both the x position and the y positions will
; need to be changed by the program (remember, these bits are stored
; in the second control word on their own rather than part of the
; actual number:

; First control word:

; bits 8-15 lower 8 bits of VPOS start and bits 0-7 lower 8 bits of HPOS

; Second control word:

; bits 8-15 lower 8 bits of HPOS end, bit 0 highest bit of HPOS
; bit 1 highest bit of VPOS end and bit 2 highest bit of VPOS start)

; That must be the longest bracketed section I've ever done.  Since
; all three of these values must be able to go to more than 255, these
; highest bits must be changed.  The Carry Flag is used below because
; it is set if either:
; 1. 1 is subtracted from a byte when it is 0 (the byte becoming 255)
; 2. 1 is added to a byte when it is 255 (the byte becoming 0)
; otherwise it is clear.  This can be used to see if the highest bit
; must be changed (eg. if a number is going from 255 to 256, the lowest
; 8 bits will be 0, the carry will be set, and the highest bit must
; be set.  This is important

; Because this way of storing the numbers is hard to use, the variables
; xpos and ypos have been used as flags to tell where abouts the pointer
; is.  For some reason, the pointer moves 2 bits right or left, but
; 1 bit up or down.  This means that ypos does hold the normal line
; line number of the screen (0-255), but that since xpos is only altered
; by 1 when the pointer moves 2, xpos is only half of the actual
; horizontal position.  This is really easy to change if it fusses you
; (I couldn't care less).

inter	movem.l	d0-d7/a0-a6,-(sp)	Yep - save all registers
	move.b	$dff00c,d0		get left/up movement for joystick
	beq.s	nolu			no l/u movement if it =0, so skip all l/u routine
	btst	#1,d0			bit 1 is set if it is going left or left and up
	beq.s	up			so if its clear, test for up
	tst	xpos			is xpos already 0?
	beq.s	up			Yes, then it can't move any further left
	subq.w	#1,xpos			take 1 from xpos
	subq.b	#1,pointer+1		subtract 1 from pointer's x position
	bcc.s	up			if new x position is not 255, go to up
	and.b	#$fe,pointer+3		if it is, the highest HPOS bit becomes 0
up	subq.b	#1,d0			take 1 from joystick position
	btst	#1,d0			now bit 1 is 0 if it is going up or up and left
	bne.s	nolu			if it ain't, go to right/down movement
	tst	ypos			is it at the top already?
	beq.s	nolu			Yes, then don't move it
	subq.w	#1,ypos			take 1 from ypos
	subq.b	#1,pointer		move top of pointer up
	bcc.s	ncarry			if new number is not 255, go to nolu
	and.b	#$fb,pointer+3		if it is, the highest VPOS start bit becomes 0, (it was 256 before, so this bit would be set)
ncarry	subq.b	#1,pointer+2		move bottom of pointer up
	bcc.s	nolu			again, if it ain't 255, go to nolu
	and.b	#$fd,pointer+3		It is 255, so highest bit if VPOS end bit must be cleared
nolu	move.b	$dff00d,d0		Get right/down position
	beq.s	over			if its 0, there's no movement so go away
	btst	#1,d0			bit 1 is set if joystick going right or right and down
	beq.s	down			so if its clear, test for down
	cmp.w	#159,xpos		has it reached far right? (320/2-1)
	beq.s	down			if so, don't move
	addq.w	#1,xpos			add 1 to xpos
	addq.b	#1,pointer+1		add 1 to pointer number
	bcc.s	down			if new number not 256, go to down
	or.b	#1,pointer+3		if it is, highest bit of HPOS must be set
down	subq.b	#1,d0			take 1 from r/d position
	btst	#1,d0			is bit 1 clear
	bne.s	over			No, then not going down, so quit
	cmp.w	#255,ypos		is it at the bottom already?
	beq.s	over			yes, then quit
	addq.w	#1,ypos			add 1 to ypos
	addq.b	#1,pointer		add 1 to pointer y pos
	bcc.s	ncarry1			if no carry, don't make highest bit=1
	or.b	#4,pointer+3		if carry, do
ncarry1	addq.b	#1,pointer+2		same for VPOS end
	bcc.s	over
	or.b	#2,pointer+3
over	movem.l	(sp)+,d0-d7/a0-a6	old registers
oldint	jmp	$0			old interrupt

; Sorry if I've either gone into too much detail where you understood
; it anyway or not enough where you didn't.



; THE JOYSTICK

; $dff00c

; bit 1 0  | Direction
; ---------+----------
;     0 0  | neither left nor up
;     0 1  | left only
;     1 0  | up and left
;     1 1  | up only

; as you can see, bit 1 is set if it is going up.  If you check for
; no movement (neither bit set) first, and then check for upward
; movement by testing bit 1 for being set.  Then subtract 1 from
; the value.  left only becomes 00, up and left 01 and up only 10
; Now, bit 1 is clear if there is leftward movement

; $dff00d

;     0 0  | Neither right nor down
;     0 1  | right only
;     1 0  | down and right
;     1 1  | down only

; As you can see, its just the same for right and down.  Again, if
; you already knew all this, you've been wasting you time!
