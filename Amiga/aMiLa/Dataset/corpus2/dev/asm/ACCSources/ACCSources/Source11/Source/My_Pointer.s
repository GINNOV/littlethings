; Pointer: puts a mouse-controlled pointer on the screen.
; This pointer has more to do with me than the other one!
; One subtle difference is that this one moves 1 pixel at
; a time - quite a bit better If you really want the comments 
; for it, I might think about it.  But comments are so riveting 
; that I don't usually bother until I need to.

************************
*   Set up the screen  *
************************
	section	codec,code_c
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
	move.l	#$29483900,pointer	Put pointer at start (if it's rerun, the sprite pointer needs to be put back at top left hand corner)
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
	dc.w	COLOR17,$f00	Red
	dc.w	COLOR18,$fc0	Yellow
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
	dc.w	%1111100000000000,%1111100000000000
	dc.w	%1001000000000000,%1111000000000000
	dc.w	%1000100111100000,%1111100111100000
	dc.w	%1100011000011000,%1111111111111000
	dc.w	%1010000000000100,%1011111111111100
	dc.w	%0001001111110010,%0001110000001110
	dc.w	%0001001111110010,%0001110000001110
	dc.w	%0010000011000001,%0011111100111111
	dc.w	%0010000011000001,%0011111100111111
	dc.w	%0010000011000001,%0011111100111111
	dc.w	%0010000011000001,%0011111100111111
	dc.w	%0001000111100010,%0001111000011110
	dc.w	%0001000111100010,%0001111000011110
	dc.w	%0000100000000100,%0000111111111100
	dc.w	%0000011000011000,%0000011111111000
	dc.w	%0000000111100000,%0000000111100000
	dc.w	0,0
xpos	dc.w	0
ypos	dc.b	0
olda	dc.b	0
oldb	dc.b	0

***********************
*  The Pointer Mover  *
***********************

inter	movem.l	d0-d7/a0-a6,-(sp)
	move.b	$dff00a,d1
	move.b	d1,d0
	sub.b	olda,d0
	beq.s	noud
	asr.b	#1,d0
	bpl.s	down
	add.b	d0,ypos
	bcs.s	ud
	clr.b	ypos
	bra	ud
down	add.b	d0,ypos
	bcc.s	ud
	move.b	#255,ypos
ud	clr.l	d2
	move.b	ypos,d2
	add.w	#$29,d2
	move.b	d2,pointer
	and.b	#$fb,pointer+3
	btst	#8,d2
	beq.s	ud1
	or.b	#4,pointer+3
ud1	add.w	#16,d2
	move.b	d2,pointer+2
	and.b	#$fd,pointer+3
	btst	#8,d2
	beq.s	noud
	or.b	#2,pointer+3
noud	move.b	d1,olda
	clr.l	d1
	move.b	$dff00b,d1
	move.w	d1,d0
	sub.b	oldb,d0
	asr.b	#1,d0
	beq.s	nolr
	bpl.s	right
	or.w	#$ff00,d0
	add.w	d0,xpos
	bcs.s	lr
	clr.w	xpos
	bra	lr
right	add.w	d0,xpos
	cmp.w	#320,xpos
	bls.s	lr
	move.w	#319,xpos
lr	clr.l	d2
	move.w	xpos,d2
	and.b	#$fe,pointer+3
	lsr	#1,d2
	bcc	nothalf
	or.b	#1,pointer+3
nothalf	add.w	#$48,d2
	move.b	d2,pointer+1
nolr	move.b	d1,oldb
	movem.l	(sp)+,d0-d7/a0-a6
oldint	jmp	$00
