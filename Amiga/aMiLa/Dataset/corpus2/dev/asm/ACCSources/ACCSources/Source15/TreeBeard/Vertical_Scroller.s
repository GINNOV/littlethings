	opt	c-

speed	=1	Any reasonable value which is a factor of 256

	section	TreeBeard,Code_C
	include ram:hardware.i
	move.l	4,a6
	lea	library,a1
	jsr	-408(a6)
	jsr	-132(a6)	Forbid
	move.l	d0,base
	move.l	#screen,d0	get address of first bitplane
	move.l	d0,b1		put it in variable b1
	move.w	d0,lowerb1l	and put it in the copper list
	swap	d0		after the wait instructions in the
	move.w	d0,lowerb1h	move <num>,bpl1pth and bpl1ptl commands
	move.l	#screen+256*40,d0	get address of second bitplane
	move.l	d0,b2		put it in address b2
	move.w	d0,lowerb2l	and in the copper lists as above but
	swap	d0		for bpl2pth and bpl2ptl
	move.w	d0,lowerb2h
	clr.w	loopy		loopy holds the number of the line in which the start of the bitplane is displayed
	bsr	setpointers	set b1h, b1l, b2h and b2l using b1 and b2
	lea	$dff000,a5
	move.l	#copper,cop1lch(a5)
	move.w	#0,copjmp1(a5)
wait	bsr	setwait		Scroll the screen
	btst	#6,$bfe001	LMB pressed?
	bne.s	wait		no, branch
	move.l	base,a2
	move.l	38(a2),cop1lch(a5)
	move.l	4.w,a6
	jmp	-138(a6)

setpointers
	move.l	b1,d0		Set pointers for bitplanes
	move.w	d0,b1l		in the copper lists
	swap	d0
	move.w	d0,b1h
	move.l	b2,d0
	move.w	d0,b2l
	swap	d0
	move.w	d0,b2h
	rts

; Main routine

setwait	cmp.b	#255,$dff006	Wait for vertical blanking
	bne.s	setwait
	bsr	setpointers	Set the pointers in copper list
	add.l	#speed*40,b1	add (speed) number of lines to the
	add.l	#speed*40,b2	bitplane addresses
	move.w	#$29,d0		Get the vertical electron beam line which display starts
	add.w	loopy,d0	add the number of the line in which start of bitplane is displayed
	move.w	#$0001,wait1	make the first wait a bogus one
	cmp.w	#256,d0		is the electron beam line on which bitplane loops>256?
	bcs	lower256	no, then branch
	move.w	#$ffe1,wait1	make the first wait instruction wait for 255th line
lower256	
	move.b	d0,wait2	wait for required line for screen to loop
	sub.w	#speed,loopy	move bitplane loop line up
	bpl	.end		if not scrolled over top of screen then branch
	move.w	#255,loopy	make bitplane loop line to be the bottom line
	move.l	#screen,b1	reset the bitplane pointers
	move.l	#screen+256*40,b2
.end	rts
	
	even
copper	dc.w	bplcon0,%10001000000000
	dc.w	bplcon1,0
	dc.w	bplcon2,0
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	dc.w	diwstrt,$2981
	dc.w	diwstop,$29c1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	color00,0
	dc.w	color01,$2ef
	dc.w	color02,$e20
	dc.w	color03,$c90
	dc.w	bpl1ptl
b1l	dc.w	0,bpl1pth
b1h	dc.w	0,bpl2ptl
b2l	dc.w	0,bpl2pth
b2h	dc.w	0	
wait1	dc.w	$0001,$fffe
wait2	dc.w	$0001,$fffe
	dc.w	bpl1ptl
lowerb1l	dc.w	0,bpl1pth
lowerb1h	dc.w	0,bpl2ptl
lowerb2l	dc.w	0,bpl2pth
lowerb2h	dc.w	0
	dc.w	$ffff,$fffe
b1	dc.l	0
b2	dc.l	0
base	dc.l	0
loopy	dc.w	0
library	dc.b	'graphics.library',0,0

screen	incbin	source:bitmaps1/Backdrop
