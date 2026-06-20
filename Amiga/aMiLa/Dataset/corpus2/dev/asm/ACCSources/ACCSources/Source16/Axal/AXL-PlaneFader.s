* Plane Fader - Fades inbetween two planes

* Date: 26-6-91
* Time: 5:30
* Name:	Plane Fader
* Code: Axal
* Note: Have just seen this on the Syntax Terror Demo on the ST
*       and decided to try in on the Amiga. Took 10 minutes

	opt c-,ow-,o+

	incdir	source:include/

	include	hardware.i

	section	plane_fader,data_c

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
	beq	error1			branch if error
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
	move.l	$6c.w,oldint		save vbl interupt
msb
	btst	#$0,$004(a5)		test msb of vpos
	bne.s	msb			branch if not 0
l310
	cmpi.b	#$55,$006(a5)		wait for line 310
	bne.s	l310			(stops spurious sprite data)
	move.w	#$7fff,intena(a5)	disable interupts
	move.w	#$7fff,dmacon(a5)	disable dma

	move.l	#hitcopper,cop1lch(a5)	insert my copper
	move.w	copjmp1(a5),d0		strode it
	move.w	#$8380,dmacon(a5)	start dma
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
	move.l	oldint(pc),$6c.w	restore vbl interupt
	move.l	gfxbase(pc),a6		graphic library
	move.l	$26(a6),cop1lch(a5)	get system copper
	move.l	$4,a6			execbase
	jsr	-138(a6)		permit multitasking
	rts

*--------------------------------------

main
	bsr	setscreens		point to the screens
	bsr	mainloop		do the main loop
	rts

*--------------------------------------

setscreens
	move.l	#pic1,d0		get pic
	move.w	d0,top1l		save low word
	swap	d0			swap them
	move.w	d0,top1h		save high word

	move.l	#pic2,d0
	move.w	d0,top2l
	swap	d0
	move.w	d0,top2h
	rts

*--------------------------------------

mainloop
vert	cmpi.b	#$ff,$006(a5)		test for vertical blank
	bne.s	vert
*	move.w	#$fff,$180(a5)		raster
	bsr	change_pic		do the pic switcher
*	move.w	#$000,$180(a5)		raster
	btst	#6,$bfe001		test for left mouse button
	bne.s	vert			branch if not pressed
	rts

*---------------------------------------

change_pic
	subq.b	#1,counter		subtract 1 from the timer
	beq.s	colready		if its 0 then branch
	rts
colready
	cmpi.b	#1,whichpic		which pic to display
	bne.s	copyright		branch if copyright

	moveq.b	#0,d0			make copyright next
	lea	copcol2(pc),a0		point to colour 2 in a0
	lea	copcol1(pc),a1		point to colour 1 in a1
	bra.s	changecols		do it (ooooeerrrr!!!) (or is it!!!)
copyright
	move.b	#1,d0			make armalyte next
	lea	copcol1(pc),a0		point to colour 1 in a0
	lea	copcol2(pc),a1		point to colour 2 in a1
changecols
	move.b	#10,counter		reset counter
	lea	white(pc),a2		point to white fade-to cols
	lea	black(pc),a3		point to black fade-to cols

	add.l	colcount,a2		add on position
	add.l	colcount,a3		add on position

	cmpi.w	#$fff,(a2)		are we at the end
	bne.s	notend			no so branch

	move.b	d0,whichpic		reset picture
	move.l	#0000,colcount		clear counter
notend
	move.w	(a2),(a0)		move in next white+ colour
	move.w	(a3),(a1)		move in next black+ colour

	add.l	#2,colcount		add to on to position
	rts				return to main loop
	
*---------------------------------------

gfxname		dc.b	'graphics.library',0
		even
gfxbase		dc.l	0
oldint		dc.l	0
stack		dc.l	0
colcount	dc.l	0
		even
savecolor	dc.w	0
sysine		dc.w	0
sysinr		dc.w	0
sysdma		dc.w	0
whichpic	dc.b	0
counter		dc.b	10
		even

*---------------------------------------

hitcopper
	dc.w	bplcon0,$2200
	dc.w	bplcon1,0
	dc.w	bplcon2,0
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$0038
	dc.w	ddfstop,$00d0
	dc.w	bpl1pth
top1h	dc.w	0
	dc.w	bpl1ptl
top1l	dc.w	0
	dc.w	bpl2pth
top2h	dc.w	0
	dc.w	bpl2ptl
top2l	dc.w	0
	dc.w	$180,$000,$182
copcol1	dc.w	$000,$184			copyright
copcol2	dc.w	$fff,$186,$fff			armalyte
	dc.w	$4501,$fffe,bplcon0,$200
	dc.w	$ffff,$fffe

*---------------------------------------

black
	dc.w	$fff,$eff,$dff,$cff,$bff,$aff,$9ff,$8ff
	dc.w	$7ff,$6ff,$5ff,$4ff,$3ff,$2ff,$1ff,$0ff
	dc.w	$0ef,$0df,$0cf,$0bf,$0af,$09f,$08f,$07f
	dc.w	$06f,$05f,$04f,$03f,$02f,$01f,$00f,$00e
	dc.w	$00d,$00c,$00b,$00a,$009,$008,$007,$006
	dc.w	$005,$004,$003,$002,$001,$000
white
	dc.w	$000,$100,$200,$300,$400,$500,$600,$700
	dc.w	$800,$900,$a00,$b00,$c00,$d00,$e00,$f00
	dc.w	$f10,$f20,$f30,$f40,$f50,$f60,$f70,$f80
	dc.w	$f90,$fa0,$fb0,$fc0,$fd0,$fe0,$ff0,$ff1
	dc.w	$ff2,$ff3,$ff4,$ff5,$ff6,$ff7,$ff8,$ff9
	dc.w	$ffa,$ffb,$ffc,$ffd,$ffe,$fff

*---------------------------------------

	incdir	source:bitmaps/
pic1	incbin 	copyright
pic2	incbin	copylyte
	even
