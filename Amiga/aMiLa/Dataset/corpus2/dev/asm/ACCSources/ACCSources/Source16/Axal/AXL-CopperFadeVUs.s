* Some Nice Copper VU-METERS (AAHHHHH!!!!! NOT A-M-O-S !!!!!!)

* Date: 24-6-91
* Time: 6:10
* Name: Copper Fading EQU
* Code: Axal

	opt c-,ow-,o+

	incdir	source:include/

	include	hardware.i

	section	Not_an_AMOS_program,data_c

	movem.l	d0-d7/a0-a6,-(sp)	save all registers
	move.l	sp,stack		save stack pointer
	bsr	openlibs		open up the librarys
	bsr	init			get the music ready
	bsr	killamiga		kill the operating system
	bsr	main			do the main thing
	bsr	restoreamiga		get the operating system back
	bsr	end			kill the music
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
	move.l	gfxbase(pc),a6		graphic library
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
	movem.l	d0-d7/a0-a6,-(sp)	save all registers
	bsr	music			play the music
	movem.l	(sp)+,d0-d7/a0-a6	restore all registers
	btst	#6,$bfe001		test for left mouse button
	bne.s	vert			branch if not pressed
	rts

*---------------------------------------

showmusic
	lea	copequ1(pc),a0		point to copper list
	lea	collist1(pc),a1		point to colour list
	move.w	chan1temp,d0		get channels note
	bsr.s	shownote		show the note

	lea	copequ2(pc),a0		point to copper list
	lea	collist2(pc),a1		point to colour list
	move.w	chan2temp,d0		get channels note
	bsr.s	shownote		show the note

	lea	copequ3(pc),a0		point to copper list
	lea	collist3(pc),a1		point to colour list
	move.w	chan3temp,d0		get channels note
	bsr.s	shownote		show the note

	lea	copequ4(pc),a0		point to copper list
	lea	collist4(pc),a1		point to colour list
	move.w	chan4temp,d0		get channels note
shownote
	move.w	#29,d2			many times to loop
	add.l	#6,a0			get position
	and.w	#$fff,d0		is it a note
	beq.s	nonote			if not branch
noteloop
	move.w	(a1)+,(a0)		replace colour
	add.l	#8,a0			next line
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
	add.l	#8,a0			next line
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

copequ1
	dc.w	$2109,$fffe,$180,$000
	dc.w	$2209,$fffe,$180,$000
	dc.w	$2309,$fffe,$180,$000
	dc.w	$2409,$fffe,$180,$000
	dc.w	$2509,$fffe,$180,$000
	dc.w	$2609,$fffe,$180,$000
	dc.w	$2709,$fffe,$180,$000
	dc.w	$2809,$fffe,$180,$000
	dc.w	$2909,$fffe,$180,$000
	dc.w	$2a09,$fffe,$180,$000
	dc.w	$2b09,$fffe,$180,$000
	dc.w	$2c09,$fffe,$180,$000
	dc.w	$2d09,$fffe,$180,$000
	dc.w	$2e09,$fffe,$180,$000
	dc.w	$2f09,$fffe,$180,$000
	dc.w	$3009,$fffe,$180,$000
	dc.w	$3109,$fffe,$180,$000
	dc.w	$3209,$fffe,$180,$000
	dc.w	$3309,$fffe,$180,$000
	dc.w	$3409,$fffe,$180,$000
	dc.w	$3509,$fffe,$180,$000
	dc.w	$3609,$fffe,$180,$000
	dc.w	$3709,$fffe,$180,$000
	dc.w	$3809,$fffe,$180,$000
	dc.w	$3909,$fffe,$180,$000
	dc.w	$3a09,$fffe,$180,$000
	dc.w	$3b09,$fffe,$180,$000
	dc.w	$3c09,$fffe,$180,$000
	dc.w	$3d09,$fffe,$180,$000
	dc.w	$3e09,$fffe,$180,$000
copequ2
	dc.w	$4109,$fffe,$180,$000
	dc.w	$4209,$fffe,$180,$000
	dc.w	$4309,$fffe,$180,$000
	dc.w	$4409,$fffe,$180,$000
	dc.w	$4509,$fffe,$180,$000
	dc.w	$4609,$fffe,$180,$000
	dc.w	$4709,$fffe,$180,$000
	dc.w	$4809,$fffe,$180,$000
	dc.w	$4909,$fffe,$180,$000
	dc.w	$4a09,$fffe,$180,$000
	dc.w	$4b09,$fffe,$180,$000
	dc.w	$4c09,$fffe,$180,$000
	dc.w	$4d09,$fffe,$180,$000
	dc.w	$4e09,$fffe,$180,$000
	dc.w	$4f09,$fffe,$180,$000
	dc.w	$5009,$fffe,$180,$000
	dc.w	$5109,$fffe,$180,$000
	dc.w	$5209,$fffe,$180,$000
	dc.w	$5309,$fffe,$180,$000
	dc.w	$5409,$fffe,$180,$000
	dc.w	$5509,$fffe,$180,$000
	dc.w	$5609,$fffe,$180,$000
	dc.w	$5709,$fffe,$180,$000
	dc.w	$5809,$fffe,$180,$000
	dc.w	$5909,$fffe,$180,$000
	dc.w	$5a09,$fffe,$180,$000
	dc.w	$5b09,$fffe,$180,$000
	dc.w	$5c09,$fffe,$180,$000
	dc.w	$5d09,$fffe,$180,$000
	dc.w	$5e09,$fffe,$180,$000
copequ3
	dc.w	$6109,$fffe,$180,$000
	dc.w	$6209,$fffe,$180,$000
	dc.w	$6309,$fffe,$180,$000
	dc.w	$6409,$fffe,$180,$000
	dc.w	$6509,$fffe,$180,$000
	dc.w	$6609,$fffe,$180,$000
	dc.w	$6709,$fffe,$180,$000
	dc.w	$6809,$fffe,$180,$000
	dc.w	$6909,$fffe,$180,$000
	dc.w	$6a09,$fffe,$180,$000
	dc.w	$6b09,$fffe,$180,$000
	dc.w	$6c09,$fffe,$180,$000
	dc.w	$6d09,$fffe,$180,$000
	dc.w	$6e09,$fffe,$180,$000
	dc.w	$6f09,$fffe,$180,$000
	dc.w	$7009,$fffe,$180,$000
	dc.w	$7109,$fffe,$180,$000
	dc.w	$7209,$fffe,$180,$000
	dc.w	$7309,$fffe,$180,$000
	dc.w	$7409,$fffe,$180,$000
	dc.w	$7509,$fffe,$180,$000
	dc.w	$7609,$fffe,$180,$000
	dc.w	$7709,$fffe,$180,$000
	dc.w	$7809,$fffe,$180,$000
	dc.w	$7909,$fffe,$180,$000
	dc.w	$7a09,$fffe,$180,$000
	dc.w	$7b09,$fffe,$180,$000
	dc.w	$7c09,$fffe,$180,$000
	dc.w	$7d09,$fffe,$180,$000
	dc.w	$7e09,$fffe,$180,$000
copequ4
	dc.w	$8109,$fffe,$180,$000
	dc.w	$8209,$fffe,$180,$000
	dc.w	$8309,$fffe,$180,$000
	dc.w	$8409,$fffe,$180,$000
	dc.w	$8509,$fffe,$180,$000
	dc.w	$8609,$fffe,$180,$000
	dc.w	$8709,$fffe,$180,$000
	dc.w	$8809,$fffe,$180,$000
	dc.w	$8909,$fffe,$180,$000
	dc.w	$8a09,$fffe,$180,$000
	dc.w	$8b09,$fffe,$180,$000
	dc.w	$8c09,$fffe,$180,$000
	dc.w	$8d09,$fffe,$180,$000
	dc.w	$8e09,$fffe,$180,$000
	dc.w	$8f09,$fffe,$180,$000
	dc.w	$9009,$fffe,$180,$000
	dc.w	$9109,$fffe,$180,$000
	dc.w	$9209,$fffe,$180,$000
	dc.w	$9309,$fffe,$180,$000
	dc.w	$9409,$fffe,$180,$000
	dc.w	$9509,$fffe,$180,$000
	dc.w	$9609,$fffe,$180,$000
	dc.w	$9709,$fffe,$180,$000
	dc.w	$9809,$fffe,$180,$000
	dc.w	$9909,$fffe,$180,$000
	dc.w	$9a09,$fffe,$180,$000
	dc.w	$9b09,$fffe,$180,$000
	dc.w	$9c09,$fffe,$180,$000
	dc.w	$9d09,$fffe,$180,$000
	dc.w	$9e09,$fffe,$180,$000
	dc.w	$ffff,$fffe

*---------------------------------------

collist1
	dc.w	$100,$200,$300,$400,$500,$600,$700,$800
	dc.w	$900,$a00,$b00,$c00,$d00,$e00,$f00,$e00
	dc.w	$d00,$c00,$b00,$a00,$900,$800,$700,$600
	dc.w	$500,$400,$300,$200,$100,$000
collist2
	dc.w	$1,$2,$3,$4,$5,$6,$7,$8,$9,$a,$b,$c,$d,$e,$f
	dc.w	$e,$d,$c,$b,$a,$9,$8,$7,$6,$5,$4,$3,$2,$1,$0
collist3
	dc.w	$10,$20,$30,$40,$50,$60,$70,$80,$90,$a0,$b0,$c0,$d0,$e0,$f0
	dc.w	$e0,$d0,$c0,$b0,$a0,$90,$80,$70,$60,$50,$40,$30,$20,$10,$0
collist4
	dc.w	$110,$220,$330,$440,$550,$660,$770,$880,$990,$aa0,$bb0,$cc0,$dd0,$ee0,$ff0
	dc.w	$ee0,$dd0,$cc0,$bb0,$aa0,$990,$880,$770,$660,$550,$440,$330,$220,$110,$0
	
*---------------------------------------

module	incbin	source:modules/mod.music
	even
