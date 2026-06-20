; Use cursor keys to move the vector bob object
	opt	c-
	section	Treeb,code_c

; The comments are on the other version

	include ram:hardware.i
	move.l	4,a6
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
	move.l	#20*128*3,d0
	move.l	#2,d2
	jsr	-198(a6)
	move.l	d0,temp1
	add.l	#128*20,d0
	move.l	d0,temp2
	add.l	#128*20,d0
	move.l	d0,temp3
	move.l	b1,d0
	add.l	#64*40+10,d0
	move.l	d0,bstart
	lea	$dff000,a5
	move.l	#copper,cop1lch(a5)
	move.w	#0,copjmp1(a5)
	move.l	b1,a1
	move.l	#30*256-1,d0
clear	move.l	#0,(a1)+
	dbra	d0,clear
	move.l	#16,a1
	move.l	#0,a2
wait	lea	structs,a0
	bsr	plotimage
	move.b	$bfec01,d0
	cmp.b	#$67,d0		Up arrow pressed?
	bne.s	.loop
	subq.l	#1,a1		-1 from vertical pos
	cmp.l	#-1,a1
	bne.s	.loop3		if result not negative, OK
	move.l	#71,a1
.loop	cmp.b	#$65,d0		Down arrow?
	bne.s	.loop1
	addq.l	#1,a1		+1 to vertical pos
	cmp.l	#72,a1
	bne	.loop3
	move.l	#0,a1
.loop1	cmp.b	#$61,d0		Left arrow?
	bne.s	.loop2
	subq.l	#1,a2		-1 from horizontal pos
	cmp.l	#-1,a2
	bne	.loop3
	move.l	#71,a2
.loop2	cmp.b	#$63,d0		Right arrow?
	bne.s	.loop3
	addq.l	#1,a2		+1 to horizontal pos
	cmp.l	#72,a2
	bne.s	.loop3
	move.l	#0,a2
.loop3	btst	#6,$bfe001
	bne.s	wait
	move.l	base,a2
	move.l	38(a2),cop1lch(a5)
	move.l	#128*20*3,d0
	move.l	temp1,a1
	jsr	-210(a6)
	move.l	#40*256*3,d0
	move.l	b1,a1
	jmp	-210(a6)

bwait	btst	#14,dmaconr(a5)
	bne.s	bwait
	rts

wipetemp
	bsr	bwait
	move.l	temp1,bltdpth(a5)
	move.w	#0,bltdmod(a5)
	move.w	#$ffff,bltafwm(a5)
	move.w	#$ffff,bltalwm(a5)
	move.w	#%100000000,bltcon0(a5)
	move.w	#0,bltcon1(a5)
	move.w	#%110000000001010,bltsize(a5)
	rts

copytemp
	cmp.b	#255,$dff006
	bne.s	copytemp
	moveq.l	#2,d7
	move.l	bstart,d0
	move.l	temp1,d1
.loop	bsr	bwait
	move.l	d1,bltapth(a5)
	move.l	d0,bltdpth(a5)
	move.w	#0,bltamod(a5)
	move.w	#20,bltdmod(a5)
	move.w	#%100111110000,bltcon0(a5)
	move.w	#0,bltcon1(a5)
	move.w	#%10000000001010,bltsize(a5)
	add.l	#128*20,d1
	add.l	#256*40,d0
	dbra	d7,.loop
	rts

; Entry d3 = x co-ord
;       d4 = y co-ord
;       d5 = colour (0 yellow, 1 red)

; Exit  d0,d1,d2 and d7 altered

plotball
	move.l	d5,d1
	mulu	#96,d1
	add.l	#ball1,d1
	move.l	d4,d0
	mulu	#20,d0
	move.l	d3,d2
	lsr.l	#4,d2
	lsl	d2
	add.l	d2,d0
	add.l	temp1,d0
	move.l	d3,d2
	lsl.l	#8,d2
	lsl.l	#4,d2
	move.w	d2,scroll
	or.w	#%111111100010,d2
	moveq.l	#2,d7
doball	bsr	bwait
	move.l	d1,bltapth(a5)
	move.l	#ballmask,bltbpth(a5)
	move.l	d0,bltcpth(a5)
	move.l	d0,bltdpth(a5)
	move.w	#-2,bltamod(a5)
	move.w	#0,bltbmod(a5)
	move.w	#16,bltcmod(a5)
	move.w	#16,bltdmod(a5)
	move.w	d2,bltcon0(a5)
	move.w	scroll,bltcon1(a5)
	move.w	#$ffff,bltafwm(a5)
	move.w	#$ffff,bltalwm(a5)
	move.w	#%10000000010,bltsize(a5)
	add.l	#20*128,d0
	add.l	#32,d1
	dbra	d7,doball
	rts

sine	movem.l	d2/a0,-(sp)
	divu	#72,d0
	clr.w	d0
	swap	d0
	ext.w	d1
	move.l	d0,d2
	cmp.b	#36,d2
	bcs	.loop
	sub.b	#36,d2
.loop	cmp.b	#19,d2
	bcs	.loop1
	move.b	d2,-(sp)
	move.b	#36,d2
	sub.b	(sp)+,d2
.loop1	lsl.l	#2,d2
	add.l	#sines,d2
	move.l	d2,a0
	muls	(a0)+,d1
	divs	(a0)+,d1
	ext.l	d1
	cmp.b	#36,d0
	bcs	.loop2
	neg.l	d1
.loop2	movem.l	(sp)+,d2/a0
	rts

; a0=address of image
; a1=sine no.

plotimage
	bsr	wipetemp
	move.l	(a0)+,d6
	clr.l	d3
	clr.l	d4
	clr.l	d5
	cmp.l	#18,a1
	bcs	.loop1
	cmp.l	#54,a1
	bcc	.loop1
.loop	lea	firstback,a4
	bra	.loop2
.loop1	move.l	d6,d0
	mulu	#3,d0
	add.l	#3,d0
	add.l	d0,a0
	lea	lastback,a4
.loop2	clr.l	d2
	clr.l	d7
	jsr	(a4)
	add.l	a2,d2
	move.l	d2,d0
	move.l	d7,d1
	bsr	sine
	add.l	#64,d1
	move.l	d1,d3
	move.l	d2,d0
	add.l	#54,d0
	move.l	d7,d1
	bsr	sine
	move.l	a1,d0
	bsr	sine
	add.l	#64,d1
	move.l	d1,d4
	bsr	plotball
	dbra	d6,.loop2
.loop3	bra	copytemp
	rts

firstback
	move.b	(a0)+,d7
	move.b	(a0)+,d2
	move.b	(a0)+,d5
	rts

lastback
	move.b	-(a0),d5
	move.b	-(a0),d2
	move.b	-(a0),d7
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
	dc.w	color00,$000
	dc.w	color01,$c90
	dc.w	color02,$bbb
	dc.w	color03,$000
	dc.w	color04,$b60
	dc.w	color05,$f40
	dc.w	color06,$c30
	dc.w	color07,$0ef
	dc.w	$ffff,$fffe
b1	dc.l	0
b2	dc.l	0
b3	dc.l	0
temp1	dc.l	0
temp2	dc.l	0
temp3	dc.l	0
scroll	dc.w	0
bstart	dc.l	0
base	dc.l	0
library	dc.b	'graphics.library',0,0
	even
ball1	incbin	source:bitmaps1/balls

ballmask
	dc.w	%0000111110000000,0
	dc.w	%0011111111100000,0
	dc.w	%0111111111110000,0
	dc.w	%0111111111110000,0
	dc.w	%1111111111111000,0
	dc.w	%1111111111111000,0
	dc.w	%1111111111111000,0
	dc.w	%1111111111111000,0
	dc.w	%1111111111111000,0
	dc.w	%0111111111110000,0
	dc.w	%0111111111110000,0
	dc.w	%0011111111100000,0
	dc.w	%0000111110000000,0,0,0,0,0,0

sines
	dc.w	0,1
	dc.w	210,2409
	dc.w	167,962
	dc.w	85,328
	dc.w	38,111
	dc.w	168,398
	dc.w	1,2
	dc.w	68,119
	dc.w	56,81
	dc.w	99,140
	dc.w	94,123
	dc.w	50,61
	dc.w	45,52
	dc.w	64,71
	dc.w	31,33
	dc.w	29,30
	dc.w	66,67
	dc.w	262,263
	dc.w	1,1

structs
	dc.l	25
	dc.b	50,63,0
	dc.b	50,9,0
	dc.b	40,63,1
	dc.b	40,9,1
	dc.b	30,63,0
	dc.b	30,9,0
	dc.b	20,63,1
	dc.b	20,9,1
	dc.b	10,63,0
	dc.b	10,9,0
	dc.b	50,54,0
	dc.b	40,54,1
	dc.b	30,54,0
	dc.b	20,54,1
	dc.b	10,54,0
	dc.b	0,0,1
	dc.b	10,18,0
	dc.b	20,18,1
	dc.b	30,18,0
	dc.b	40,18,1
	dc.b	50,18,0
	dc.b	10,36,0
	dc.b	20,36,1
	dc.b	30,36,0
	dc.b	40,36,1
	dc.b	50,36,0

	even

