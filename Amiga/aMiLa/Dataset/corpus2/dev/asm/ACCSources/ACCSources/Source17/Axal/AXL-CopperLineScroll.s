* DATE: 01-09-91
* TIME: 01:35
* NAME: COPPER LINE EFFECT
* CODE: AXAL
* NOTE: 

	opt c-,ow-,o+,d+

	include	source:axal/hardware.i

	section	Bless_this_bunch_as_they_munch_their_lunch,data_c

	movem.l	d0-d7/a0-a6,-(sp)	save all registers
	move.l	sp,stack		save stack pointer
	bsr	openlibs		open up the librarys
	bsr	killamiga		kill the operating system
	bsr	main			do the main thing
	bsr	restoreamiga		get the operating system back
	bsr	closelibs		close the librarys
error1	move.l	stack,sp		restore the stack
	movem.l	(sp)+,d0-d7/a0-a6	restore all registers
	rts				quit

*---------------------------------------

openlibs
	move.l	$4,a6			execbase
	moveq.l	#0,d0			any version
	lea	gfxname(pc),a1		point to library
	jsr	-552(a6)		open lib
	move.l	d0,gfxbase		save base
	beq.s	error1			branch if error
	rts

*---------------------------------------

closelibs
	move.l	$4,a6			execbase
	move.l	gfxbase(pc),a1		point to lib
	jsr	-414(a6)		close lib
	rts

*---------------------------------------

killamiga
	move.l	$4,a6			execbase
	jsr	-132(a6)		forbid multitaksking
	lea	$dff000,a5		point to custom chips
	move.w	dmaconr(a5),sysdma	save system dma
	move.w	intenar(a5),sysine	save interupt enable
	move.w	intreqr(a5),sysinr	save interupt request
msb
	btst	#$0,$004(a5)		test msb of vpos
	bne.s	msb			branch if not 0
l310
	cmpi.b	#$55,$006(a5)		wait for line 310
	bne.s	l310			(stops spurious sprite data)
	move.w	#$7fff,intena(a5)	disable interupts
	move.w	#$7fff,dmacon(a5)	disable dma

	move.l	#axlcopper,cop1lch(a5)	insert my copper
	move.w	copjmp1(a5),d0		strode it
	rts				return

*---------------------------------------

restoreamiga
	move.w	sysine(pc),d1		get system int. enable
	bset	#$f,d1			set write bit
	move.w	d1,intena(a5)		restore int. enable
	move.w	sysinr(pc),d1		get system int. request
	bset	#$f,d1			set write bit
	move.w	d1,intreq(a5)		restore int. request
	move.w	sysdma(pc),d1		get system dma
	bset	#$f,d1			set write bit
	move.w	d1,dmacon(a5)		restore system dma
	move.l	gfxbase(pc),a6		graphic library
	move.l	$26(a6),cop1lch(a5)	get system copper
	move.l	$4,a6			execbase
	jsr	-138(a6)		permit multitasking
	rts

*--------------------------------------

main
	move.w	#$8380,dmacon(a5)	start dma (copper)
	bsr	mainloop		do the main loop
	rts

*--------------------------------------

mainloop
	cmpi.b	#$ff,$006(a5)		test for vertical blank
	bne.s	mainloop
*	move.w	#$fff,$180(a50
	bsr	scroll_color1
	bsr	scroll_color2
*	move.w	#$000,$180(a5)
	btst	#6,$bfe001		test for left mouse button
	bne.s	mainloop		branch if not pressed
	rts

*---------------------------------------

scroll_color1				;i know this is the wrong spelling!!
	lea	copline1(pc),a0		point to copper list
	lea	linecolors(pc),a1	point to colour list
	add.w	colcount,a1		add on colour position
	moveq	#50-1,d0		many times to loop
scrollcol_loop1
	move.w	(a1)+,d1		get colour
	move.w	d1,d2			copy it
	and.w	#$f000,d2		is it a colour
	beq.s	is_color		branch if 0
	lea	linecolors(pc),a1	repoint to colours
	bra.s	scrollcol_loop1		redo
is_color
	move.w	d1,2(a0)		replace colour
	addq.l	#4,a0			next register please
	dbra	d0,scrollcol_loop1	decrement and branch
	addq	#2,colcount		add 2 to counter
	cmpi.w	#(no_cols*2),colcount	is colour count 80
	bne.s	not_col80		if not end
	clr.w	colcount		clear counter
not_col80
	rts

*---------------------------------------

scroll_color2				;i know this is the wrong spelling!!
	lea	copline2(pc),a0		point to copper list
	lea	linecolors(pc),a1	point to colour list
	add.w	colcount2,a1		add on colour position
	moveq	#50-1,d0		many times to loop
scrollcol_loop2
	move.w	(a1)+,d1		get colour
	move.w	d1,d2			copy it
	and.w	#$f000,d2		is it a colour
	beq.s	is_color2		branch if 0
	lea	linecolors(pc),a1	repoint to colours
	bra.s	scrollcol_loop2		redo
is_color2
	move.w	d1,-2(a0)		replace colour
	subq.l	#4,a0			next register please
	dbra	d0,scrollcol_loop2	decrement and branch
	addq	#2,colcount2		add 2 to counter
	cmpi.w	#(no_cols*2),colcount2	is colour count 80
	bne.s	not_col802		if not end
	clr.w	colcount2		clear counter
not_col802
	rts
*---------------------------------------

gfxname		dc.b	'graphics.library',0
		even
gfxbase		dc.l	0
stack		dc.l	0
sysine		dc.w	0
sysinr		dc.w	0
sysdma		dc.w	0
colcount	dc.w	0
colcount2	dc.w	0
		even

*---------------------------------------

axlcopper
	dc.w	bplcon0,$0200		no planes
	dc.w	beamcon0,$20		50hz
	dc.w	$180,$000
	dc.w	$5031,$fffe
copline1
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000

	dc.w	$5101,$fffe,$180,$000,$5201,$fffe,$180,$101
	dc.w	$5301,$fffe,$180,$202,$5401,$fffe,$180,$303
	dc.w	$5501,$fffe,$180,$404,$5601,$fffe,$180,$505
	dc.w	$5701,$fffe,$180,$606,$5801,$fffe,$180,$707
	dc.w	$5901,$fffe,$180,$808,$5a01,$fffe,$180,$909
	dc.w	$8601,$fffe,$180,$909,$8701,$fffe,$180,$808
	dc.w	$8801,$fffe,$180,$707,$8901,$fffe,$180,$606
	dc.w	$8a01,$fffe,$180,$505,$8b01,$fffe,$180,$404
	dc.w	$8c01,$fffe,$180,$303,$8d01,$fffe,$180,$202
	dc.w	$8e01,$fffe,$180,$101,$8f01,$fffe,$180,$000

	dc.w	$9001,$fffe
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
copline2
	dc.w	$9101,$fffe,$180,$000
	dc.w	$ffff,$fffe

*---------------------------------------

linecolors
	dc.w	$639,$74a,$85b,$96c,$a7d,$b8e,$c9f,$dae
	dc.w	$ebd,$fcc,$fdb,$fea,$ff9,$fe7,$fd6,$fc5
	dc.w	$fb4,$fa3,$f92,$f81,$f70,$f60,$f50,$f40
	dc.w	$f30,$f20,$f10,$f00,$e00,$d10,$c21,$b32
	dc.w	$a43,$954,$865,$776,$687,$598,$4a9,$3ba
	dc.w	$2cb,$1dc,$0ed,$0fe,$0ff,$1ff,$2ff,$3ff
	dc.w	$4ef,$5df,$6cf,$7bf,$8af,$99f,$a8f,$b7f
	dc.w	$c6f,$d5f,$e4f,$f3f,$f2f,$f1f,$f0f,$e0f
	dc.w	$d0f,$c0f,$b0f,$a0f,$90f,$80f,$70f,$60f
	dc.w	$50f,$40f,$30f,$20f,$10f,$12f,$23e,$34d
	dc.w	$45c,$56b,$67a,$789,$898,$9a7,$ab6,$bc5
	dc.w	$cd4,$de3,$ef2,$ff1,$ff0,$fe0,$fd0,$fc0
	dc.w	$eb1,$da2,$c93,$b84,$a75,$966,$857,$748
	dc.w	$ffff		;the end
no_cols		equ	104

*---------------------------------------

