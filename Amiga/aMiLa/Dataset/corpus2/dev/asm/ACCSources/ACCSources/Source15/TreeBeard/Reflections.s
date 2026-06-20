; Blits a bob (160 x 32) on screen then reflects it.

; Reflection works by pointing A to the last line of the object on the
; screen you want to reflect, and using modulos move it up instead of
; down a line.  The width of the bob is 20 bytes, and of the screen is
; 40 bytes, so after a line has been blitted you need to move 60 bytes
; back (bltamod=-60).  The destination stuff does not need to be
; changed.

	section	c,code_c
	opt	c-
	include 	ram:hardware.i
	
; Usual stuff :
	move.l	4,a6
	lea	library,a1	Open gfx lib
	jsr	-408(a6)
	move.l	d0,base
	move.l	#40*256*3,d0	Set-up bitplanes
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
	lea	$dff000,a5
	move.l	#copper,cop1lch(a5)
	move.w	#0,copjmp1(a5)
	move.l	b1,a1
	move.l	#30*256-1,d0
clear	clr.l	(a1)+
	dbra	d0,clear

; Blit bob onto screen using routine doblit

	lea	bob,a0		Source (A) = Bob
	move.l	b1,a1
	add.l	#40*40,a1	Dest (D) = 40th line of screen
	move.w	#0,d0		A modulo = 0
	move.l	#640,d1		d1 = size of bob
	bsr	doblit

wait	btst	#6,$bfe001	Wait for LMB
	bne.s	wait

; Reflect the image (using the bitplanes themselves - not the bob)

	move.l	b1,a0
	add.l	#71*40,a0	Source = Last line of the bob on screen
	move.l	a0,a1
	add.l	#80,a1		Destination = First line of reflection
	move.w	#-60,d0		A modulo = -60 to move up a line
	move.l	#256*40,d1	Size of A = size of bitplane
	bsr	doblit

wait1	btst	#10,$dff016	Wait for RMB
	bne.s	wait1


; Clean Up :

	move.l	base,a2
	move.l	38(a2),cop1lch(a5)
	move.l	#40*256*3,d0
	move.l	b1,a1
	jmp	-210(a6)

; Entry a0 = A Reg (Source)
;       a1 = D Reg (Destination)
;       d0 = A Modulo
;       d1 = Size of A (number to add to get to next plane)


doblit	moveq.l	#2,d7		3 bitplanes
bwait	btst	#14,dmaconr(a5)	Wait for blitter
	bne.s	bwait
	move.l	a0,bltapth(a5)	A = a0
	move.l	a1,bltdpth(a5)	D = a1
	move.w	d0,bltamod(a5)
	move.w	#20,bltdmod(a5)
	move.w	#$ffff,bltafwm(a5)
	move.w	#$ffff,bltalwm(a5)
	move.w	#%100111110000,bltcon0(a5)	Usual A to D blit
	move.w	#0,bltcon1(a5)
	move.w	#%100000001010,bltsize(a5)	Bob size = 160x32
	add.l	d1,a0		Move source onto next plane
	add.l	#256*40,a1	Ditto destination
	dbra	d7,bwait	Do the other bitplanes
	rts

	even
copper	dc.w	bplcon0,%11001000000000
	dc.w	bplcon1,0
	dc.w	bplcon2,0
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	dc.w	diwstrt,$2981
	dc.w	diwstop,$29c1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bpl1ptl
b1l	dc.w	0,bpl1pth
b1h	dc.w	0,bpl2ptl
b2l	dc.w	0,bpl2pth
b2h	dc.w	0,bpl3ptl
b3l	dc.w	0,bpl3pth
b3h	dc.w	0
	dc.w	color00,0
	dc.w	color01,$070
	dc.w	color02,$050
	dc.w	color03,$030
	dc.w	color04,$db0
	dc.w	color05,$a70
	dc.w	color06,$600
	dc.w	$ffff,$fffe
b1	dc.l	0
b2	dc.l	0
b3	dc.l	0
base	dc.l	0
library	dc.b	'graphics.library',0,0

bob	incbin	source:bitmaps1/Reflect_bob
