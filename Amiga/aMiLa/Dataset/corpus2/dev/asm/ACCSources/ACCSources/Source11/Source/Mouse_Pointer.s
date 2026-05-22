; Pointer: puts a joystick-controlled pointer on the screen.

************************
*   Set up the screen  *
************************
	section	tooti,code_c	
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
	move.b	$dff00a,olda
	move.b	$dff00b,oldb
	move.l	#$29483400,pointer	Put pointer at start (if it's rerun, the sprite pointer needs to be put back at top left hand corner)
	move.l	$6c,oldint+2	Get my interrupt in
	move.l	#inter,$6c

*************************
*  Waits for LMB or FB  *
*************************

wait	btst	#6,$bfe001	Is LMB pressed
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

*****************
*  Copper List  *
*****************

; much as you'd expect

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

******************************
*  The mouse pointer sprite  *
******************************

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
xpos	dc.b	0
ypos	dc.b	0
olda	dc.b	0	old vertical position of mouse
oldb	dc.b	0	old horizontal position of mouse


***********************
*  The Pointer Mover  *
***********************

; This is where the source changes.  A word (except with me it's a book):

; Interrupts still used.  olda stores old $dff00a (vertical mouse position)
; and oldb stores old $dff00b (horizontal mouse position).  Here's a chart
; on how mouse moves:

; Left - $dff00b decreases
; Right - $dff00b increases
; Up - $dff00a decreases
; Down - $dff00a increases

; So if it goes down, current value of $dff00a will be more than olda
; So increase in y=$dff00a-olda.  This value is divided by two since
; otherwise I think it's too quick (you might prefer it without).
; Right, so if this y value is 0, no sigificant vertical movement
; has taken place, so check for l/r movement.  If it's positive, mouse
; has been moved down, so add it to y position (eg. if olda=$df and
; $dff00a=$e3, $e3-$df = 4, /2 =2.  2 is added to ypos).  It makes sure
; ypos doen't exceed 255 (if it does, eg. ypos=254 and moved down 2,
; ypos=0 (it's a byte so it can't hold 256), and carry is set.  If carry
; is set, ypos is reset to 255, bottom of screen).

; If the increase in y is negative, you also add it to ypos (eg. =-2, that's
; $fe in hex.  If ypos=8 then 8+$fe in a byte = 6).  This time the carry
; flag is clear if it goes too far up.  So if carry is clear, make ypos=0,
; top of screen.

; The l/r movement works in exactly the same way except it is divided by
; 4, since the sprites move 2 pixels horizontally at a time as opposed to
; 1 pixel vertically.

inter	movem.l	d0-d7/a0-a6,-(sp)	Save regs
	move.b	$dff00a,d1	get current v pos
	move.b	d1,d0		copy it into d1
	sub.b	olda,d0		take away old v pos
	beq.s	noud		it its 0, no new v movement
	asr.b	#1,d0		arithmetic shift left once (keeps most significant bit the same so it stays negative if it was negative originally)
	bpl.s	down		>0 then move down
	add.b	d0,ypos		add to ypos
	bcs.s	ud		if it didn't go off top of screen, go to ud
	clr.b	ypos		if it did, make ypos=0
	bra	ud		and then go to ud
down	add.b	d0,ypos		add to ypos
	bcc.s	ud		if it didn't go off bottom of screen, go to ud
	move.b	#255,ypos	if it did, make ypos=255
ud	clr.l	d2		work out sprite pointer's position
	move.b	ypos,d2		add $29 (the top of the screen) to ypos (in d2)
	add.w	#$29,d2
	move.b	d2,pointer	lowest 8 bits go into VPOS start byte in sprite's 2 control words
	and.b	#$fb,pointer+3	clear highest bit of VPOS start (its in the third byte)
	btst	#8,d2		is highest bit of VPOS start=1?
	beq.s	ud1		no, then skip
	or.b	#4,pointer+3	set highest bit of VPOS start
ud1	add.w	#11,d2		add 11 to this number to get end of sprite (change this to the height of the sprite pointer if you change the sprite pointer)
	move.b	d2,pointer+2	do the same as before with VPOS end
	and.b	#$fd,pointer+3
	btst	#8,d2
	beq.s	noud
	or.b	#2,pointer+3
noud	move.b	d1,olda		put current $dff00a into olda for next time
	move.b	$dff00b,d1	get new mouse x position
	move.b	d1,d0		and put it into d0 aswell
	sub.b	oldb,d0		take old mouse x position form d0
	asr.b	#2,d0		divide it by 4
	beq.s	nolr		if d0=0, no left/right movement
	bpl.s	right		if d0>0, move right
	add.b	d0,xpos		move left - add d0 to xpos
	bcs.s	lr		if carry is clear the pointer has gone too far left, so bring it under control if it is
	clr.b	xpos
	bra	lr
right	add.b	d0,xpos		add d0 to xpos
	cmp.b	#160,xpos	is xpos>159
	bls.s	lr		No, good
	move.b	#159,xpos	make xpos=159
lr	clr.l	d2		get xpos into d2
	move.b	xpos,d2
	add.w	#$48,d2		add screen's horizontal starting position, which I got by trial and error
	move.b	d2,pointer+1	and this is the new HPOS.
nolr	move.b	d1,oldb		make this value of $dff00b the old one for next time
	movem.l	(sp)+,d0-d7/a0-a6
oldint	jmp	$00
