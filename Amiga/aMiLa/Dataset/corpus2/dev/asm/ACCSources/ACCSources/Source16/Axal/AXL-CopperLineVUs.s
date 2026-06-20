* Some Nice Copper VU-METERS (AAHHHHH!!!!! NOT A-M-O-S !!!!!!)

* Date: 24-6-91
* Time: 7:00
* Name: Copper Line EQU
* Code: Axal

	opt c-,ow-,o+

	incdir	source:include/

	include	hardware.i

	section	Not_an_AMOS_program,data_c

	movem.l	d0-d7/a0-a6,-(sp)	save all registers
	move.l	sp,stack		save stack pointer
	bsr	openlibs		open up the librarys
	bsr	init
	bsr	killamiga		kill the operating system
	bsr	main			do the main thing
	bsr	restoreamiga		get the operating system back
	bsr	end
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
	move.w	#$8280,dmacon(a5)	start dma
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
	move.l	gfxbase,a6		graphic library
	move.l	$26(a6),cop1lch(a5)	get system copper
	move.l	$4,a6			execbase
	jsr	-138(a6)		permit multitasking
	rts

*--------------------------------------

main
	bsr	mainloop		do the main loop
	rts

*--------------------------------------

mainloop
vert	cmpi.b	#$ff,$006(a5)		test for vertical blank
	bne.s	vert
	bsr	showmusic		do the copper equs
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	music
	movem.l	(sp)+,d0-d7/a0-a6
	btst	#6,$bfe001		test for left mouse button
	bne.s	vert			branch if not pressed
	rts

*---------------------------------------

showmusic
	lea	copequ1(pc),a0		point to copper list
	lea	collist1(pc),a1		point to colour list
	move.w	chan1temp(pc),d0	get channels note
	bsr	shownote		show the note

	lea	copequ2(pc),a0		point to copper list
	lea	collist2(pc),a1		point to colour list
	move.w	chan2temp(pc),d0	get channels note
	bsr	shownote		show the note

	lea	copequ3(pc),a0		point to copper list
	lea	collist3(pc),a1		point to colour list
	move.w	chan3temp(pc),d0	get channels note
	bsr	shownote		show the note

	lea	copequ4(pc),a0		point to copper list
	lea	collist4(pc),a1		point to colour list
	move.w	chan4temp(pc),d0	get channels note
shownote
	move.w	#14,d2			many times to loop
	add.l	#6,a0			get position
	and.w	#$fff,d0		is it a note
	beq.s	nonote			if not branch
noteloop
	move.w	(a1)+,(a0)		replace colour
	add.l	#32,a0			next line
	dbra	d2,noteloop		decrement and loop
	rts
nonote
	move.w	(a0),d0			get colour
	move.w	d0,d1			copy it
	and.w	#$00f,d1		is there a red
	beq.s	green			branch if no colour
	subq.w	#$001,d0		subract a red
green
	move.w	d0,d1			get colour
	and.w	#$0f0,d1		is there a green
	beq.s	blue			branch if no colour
	sub.w	#$010,d0		subtract a green
blue
	move.w	d0,d1			get colour
	and.w	#$f00,d1		is there a blue
	beq.s	nocolour		branch if no colour
	sub.w	#$100,d0		subtract a blue
nocolour
	move.w	d0,(a0)			replace colour
	add.l	#32,a0			next line
	dbra	d2,nonote		decrement and loop
	rts

*---------------------------------------

	include	source:axal/pt-playabn.s

*---------------------------------------

gfxname		dc.b	'graphics.library',0
		even
gfxbase		dc.l	0
oldint		dc.l	0
stack		dc.l	0
sysine		dc.w	0
sysinr		dc.w	0
sysdma		dc.w	0
		even

*---------------------------------------

hitcopper
	dc.w	$180,$000
copequ1	dc.w	$3101,$fffe,$180,$000
copequ2	dc.w	$315d,$fffe,$180,$000
copequ3	dc.w	$3189,$fffe,$180,$000
copequ4	dc.w	$31b5,$fffe,$180,$000

	dc.w	$3201,$fffe,$180,$000
	dc.w	$325d,$fffe,$180,$000
	dc.w	$3289,$fffe,$180,$000
	dc.w	$32b5,$fffe,$180,$000

	dc.w	$3301,$fffe,$180,$000
	dc.w	$335d,$fffe,$180,$000
	dc.w	$3389,$fffe,$180,$000
	dc.w	$33b5,$fffe,$180,$000

	dc.w	$3401,$fffe,$180,$000
	dc.w	$345d,$fffe,$180,$000
	dc.w	$3489,$fffe,$180,$000
	dc.w	$34b5,$fffe,$180,$000

	dc.w	$3501,$fffe,$180,$000
	dc.w	$355d,$fffe,$180,$000
	dc.w	$3589,$fffe,$180,$000
	dc.w	$35b5,$fffe,$180,$000

	dc.w	$3601,$fffe,$180,$000
	dc.w	$365d,$fffe,$180,$000
	dc.w	$3689,$fffe,$180,$000
	dc.w	$36b5,$fffe,$180,$000

	dc.w	$3701,$fffe,$180,$000
	dc.w	$375d,$fffe,$180,$000
	dc.w	$3789,$fffe,$180,$000
	dc.w	$37b5,$fffe,$180,$000

	dc.w	$3801,$fffe,$180,$000
	dc.w	$385d,$fffe,$180,$000
	dc.w	$3889,$fffe,$180,$000
	dc.w	$38b5,$fffe,$180,$000

	dc.w	$3901,$fffe,$180,$000
	dc.w	$395d,$fffe,$180,$000
	dc.w	$3989,$fffe,$180,$000
	dc.w	$39b5,$fffe,$180,$000

	dc.w	$3a01,$fffe,$180,$000
	dc.w	$3a5d,$fffe,$180,$000
	dc.w	$3a89,$fffe,$180,$000
	dc.w	$3ab5,$fffe,$180,$000

	dc.w	$3b01,$fffe,$180,$000
	dc.w	$3b5d,$fffe,$180,$000
	dc.w	$3b89,$fffe,$180,$000
	dc.w	$3bb5,$fffe,$180,$000

	dc.w	$3c01,$fffe,$180,$000
	dc.w	$3c5d,$fffe,$180,$000
	dc.w	$3c89,$fffe,$180,$000
	dc.w	$3cb5,$fffe,$180,$000

	dc.w	$3d01,$fffe,$180,$000
	dc.w	$3d5d,$fffe,$180,$000
	dc.w	$3d89,$fffe,$180,$000
	dc.w	$3db5,$fffe,$180,$000

	dc.w	$3e01,$fffe,$180,$000
	dc.w	$3e5d,$fffe,$180,$000
	dc.w	$3e89,$fffe,$180,$000
	dc.w	$3eb5,$fffe,$180,$000

	dc.w	$3f01,$fffe,$180,$000
	dc.w	$3f5d,$fffe,$180,$000
	dc.w	$3f89,$fffe,$180,$000
	dc.w	$3fb5,$fffe,$180,$000

	dc.w	$4001,$fffe,$180,$000

	dc.w	$ffff,$fffe
*---------------------------------------

collist1
	dc.w	$200,$400,$600,$800,$a00,$c00,$e00,$e00
	dc.w	$c00,$a00,$800,$600,$400,$200,$000
collist2
	dc.w	$2,$4,$6,$8,$a,$c,$e,$e,$c,$a,$8,$6,$4,$2,$0
collist3
	dc.w	$20,$40,$60,$80,$a0,$c0,$e0,$e0,$c0,$a0,$80,$60,$40,$20,$0
collist4
	dc.w	$220,$440,$660,$880,$aa0,$cc0,$ee0
	dc.w	$ee0,$cc0,$aa0,$880,$660,$440,$220,$0
	
*---------------------------------------

module	incbin	source:modules/mod.music
	even
