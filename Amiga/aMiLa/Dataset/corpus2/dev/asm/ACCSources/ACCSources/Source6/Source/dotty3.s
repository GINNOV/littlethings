MoveScreen 	= -162
OpenScreen 	= -198
CloseScreen 	= -66
CloseLibrary 	= -414
OpenLib 	= -408
ExecBase 	= 4
joy2	= $dff00c
fire	= $bfe001

	bsr	openint
	bsr	scropen
	move	#20,d2
rl	move	d2,-(a7)
	move.l	screenhd,a5
	move.l	$c0(a5),a5
	add.l	#5120,a5
	move	#2560/2-1,d0
	move.b	$bfe801,d1
fwait	cmp.b	$bfe801,d1
	beq	fwait
cl	move.l	#0,(a5)+
	dbra	d0,cl
	move.l	d2,a2
	bsr	main
	move	(a7)+,d2
	dbra	d2,rl
wait2	cmp.b	#$39,$bfec01
	beq	cont
	btst.b	#6,$bfe001
	bne	wait2
cont	bsr	scrclose
	bsr	closeint
	rts

openint:
	move.l	ExecBase,a6
	lea	IntName,a1
	jsr	OpenLib(a6)
	move.l	d0,intbase
	rts
IntName	dc.b	"intuition.library",0
	even
intbase	dc.l	0

closeint:
	move.l	ExecBase,a6
	move.l	intbase,a1
	jsr	CloseLibrary(a6)
	rts

scropen:
	move.l	intbase,a6

	lea	screen_info,a0
	jsr	OpenScreen(a6)
	move.l	d0,screenhd
	rts
	even
screenhd dc.l	0

scrclose:
	move.l	intbase,a6

	move.l	screenhd,a0
	jsr	CloseScreen(a6)
	rts

	even
d0sto	dc.l	0

screen_info:
x_pos		dc.w	0
y_pos		dc.w	0
width		dc.w	320
height		dc.w	256
depth		dc.w	1
detail_pen	dc.b	0	;Colour of text, etc...
block_pen	dc.b	1	;Background colour
view_modes	dc.w	$2	;Representation mode
screen_type	dc.w	15	;Custom screen
font		dc.l	0	;Standard font
title		dc.l	sname	;Pointer to title text
gadgets		dc.l	0	;No gadgets
bitmap		dc.l	0	;No bitmap
sname		dc.b	"DOTTY",0
	even

main:
;	move.l	#20,d2   	;y
	move.l	#10,d1		;Magnification
	move.l	#1,d3		;z
zloop	move.l	d3,d4    	;x
	lsl.l	#4,d4
	neg.l	d4
	sub.l	a2,d4
xloop	cmp.b	#$39,$bfec01
;	beq	waitkey
	move.l	d4,d7
	move.l	d1,d6
	muls	d6,d7		;m*x
	move.l	d3,d6
	divs	d6,d7		;m*x/z
	add.l	#160,d7		;m*x/z+160
	move	d7,d0		;=sx
	move.l	d2,d7
	move.l	d1,d6
	muls	d6,d7		;m*y
	move.l	d3,d6
	divs	d6,d7		;m*y/z
	add.l	#128,d7		;m*y/z+128
	move	d7,d5		;sy
	tst	d0
	bmi	offscrn
	cmp	#319,d0
	bcc	nextz
	cmp	#246,d5
	bcc	offscrn
	bsr	plot
offscrn	add.l	#10,d4
	cmp.l	#1000,d4
	ble	xloop
nextz	add.l	#1,d3
	cmp.l	#10,d3
	ble	zloop
waitkey	cmp.b	#$39,$bfec01
;	bne	waitkey
	rts			;end - close screen, libraries

plot				;Entry point for hi-res
	add.l	#10,d5		;miss title-bar
	move.l	screenhd,a5
	move.l	$c0(a5),a5	;get bit-plane0 address
	clr.l	d6
	move	d5,d6
	lsl	#3,d6		;ypos*16 > d7
	move.l	d6,d7
	lsl	#2,d6		;(ypos*16)*4=ypos*64
	add	d7,d6		;(ypos*16)+(ypos*16)=ypos*80
	add.l	d6,a5		;get correct address for y position
	clr.l	d6
	move	d0,d6
	lsr.l	#3,d6		;xpos/8
	adda.l	d6,a5		;correct address of pixel
	move	d0,d6
	and.l	#7,d6
	move.b	#128,d7
	ror.b	d6,d7		;get byte to OR onto address
	or.b	d7,(a5)		;OR-on bit
	sub.l	#10,d5		;correct d5
	rts

