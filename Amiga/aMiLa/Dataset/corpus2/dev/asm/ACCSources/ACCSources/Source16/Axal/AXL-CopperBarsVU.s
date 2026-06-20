* Some Nice Copper VU-METERS (AAHHHHH!!!!! NOT A-M-O-S !!!!!!)

* Date: 24-6-91
* Time: 5:23
* Name: Copper EQUS
* Code: Axal

	opt c-,ow-,o+

	incdir	source:include/

	include	hardware.i

	section	Not_an_AMOS_program,data_c

	movem.l	d0-d7/a0-a6,-(sp)	save all registers
	move.l	sp,stack		save stack pointer
	bsr	openlibs		open up the librarys
	bsr	init			set up music
	bsr	killamiga		kill the operating system
	bsr	main			do the main thing
	bsr	restoreamiga		get the operating system back
	bsr	end			kill da muzak
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
	movem.l	d0-d7/a0-a6,-(sp)	blah...blah...blah...
	bsr	music			do the m u s i c 
	movem.l	(sp)+,d0-d7/a0-a6	blah...blah...blah...
	btst	#6,$bfe001		test for left mouse button
	bne.s	vert			branch if not pressed
	rts

*---------------------------------------

showmusic
	lea	copequ1(pc),a0		point to copper list
	move.w	chan1temp,d0		get channels note
	bsr	shownote		show the note

	lea	copequ2(pc),a0		point to copper list
	move.w	chan2temp,d0		get channels note
	bsr	shownote		show the note

	lea	copequ3(pc),a0		point to copper list
	move.w	chan3temp,d0		get channels note
	bsr	shownote		show the note

	lea	copequ4(pc),a0		point to copper list
	move.w	chan4temp,d0		get channels note
shownote
	move.w	#30-1,d2		many times to loop
	and.w	#$fff,d0		is it a note
	beq.s	nonote			if not branch
noteloop
	move.b	#$b1,1(a0)		show copper
	add.l	#16,a0			next line
	dbra	d2,noteloop		decrement and loop
	rts
nonote
	cmpi.b	#$41,1(a0)		is it the end of the line
	bne.s	notend			no so branch
	rts
notend
	sub.b	#2,1(a0)		subtract 2 from the list
	add.l	#16,a0			next line
	dbra	d2,notend		decrement and loop
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
	dc.w	$2041,$fffe,$180,$000,$2109,$fffe,$180,$100
	dc.w	$2141,$fffe,$180,$000,$2209,$fffe,$180,$200
	dc.w	$2241,$fffe,$180,$000,$2309,$fffe,$180,$300
	dc.w	$2341,$fffe,$180,$000,$2409,$fffe,$180,$400
	dc.w	$2441,$fffe,$180,$000,$2509,$fffe,$180,$500
	dc.w	$2541,$fffe,$180,$000,$2609,$fffe,$180,$600	
	dc.w	$2641,$fffe,$180,$000,$2709,$fffe,$180,$700
	dc.w	$2741,$fffe,$180,$000,$2809,$fffe,$180,$800
	dc.w	$2841,$fffe,$180,$000,$2909,$fffe,$180,$900
	dc.w	$2941,$fffe,$180,$000,$2a09,$fffe,$180,$a00
	dc.w	$2a41,$fffe,$180,$000,$2b09,$fffe,$180,$b00
	dc.w	$2b41,$fffe,$180,$000,$2c09,$fffe,$180,$c00
	dc.w	$2c41,$fffe,$180,$000,$2d09,$fffe,$180,$d00
	dc.w	$2d41,$fffe,$180,$000,$2e09,$fffe,$180,$e00	
	dc.w	$2e41,$fffe,$180,$000,$2f09,$fffe,$180,$f00
	dc.w	$2f41,$fffe,$180,$000,$3009,$fffe,$180,$e00
	dc.w	$3041,$fffe,$180,$000,$3109,$fffe,$180,$d00
	dc.w	$3141,$fffe,$180,$000,$3209,$fffe,$180,$c00	
	dc.w	$3241,$fffe,$180,$000,$3309,$fffe,$180,$b00	
	dc.w	$3341,$fffe,$180,$000,$3409,$fffe,$180,$a00
	dc.w	$3441,$fffe,$180,$000,$3509,$fffe,$180,$900	
	dc.w	$3541,$fffe,$180,$000,$3609,$fffe,$180,$800
	dc.w	$3641,$fffe,$180,$000,$3709,$fffe,$180,$700
	dc.w	$3741,$fffe,$180,$000,$3809,$fffe,$180,$600	
	dc.w	$3841,$fffe,$180,$000,$3909,$fffe,$180,$500
	dc.w	$3941,$fffe,$180,$000,$3a09,$fffe,$180,$400
	dc.w	$3a41,$fffe,$180,$000,$3b09,$fffe,$180,$300	
	dc.w	$3b41,$fffe,$180,$000,$3c09,$fffe,$180,$200
	dc.w	$3c41,$fffe,$180,$000,$3d09,$fffe,$180,$100
	dc.w	$3d41,$fffe,$180,$000,$3e09,$fffe,$180,$000
copequ2
	dc.w	$4041,$fffe,$180,$000,$4109,$fffe,$180,$010
	dc.w	$4141,$fffe,$180,$000,$4209,$fffe,$180,$020	
	dc.w	$4241,$fffe,$180,$000,$4309,$fffe,$180,$030
	dc.w	$4341,$fffe,$180,$000,$4409,$fffe,$180,$040
	dc.w	$4441,$fffe,$180,$000,$4509,$fffe,$180,$050
	dc.w	$4541,$fffe,$180,$000,$4609,$fffe,$180,$060	
	dc.w	$4641,$fffe,$180,$000,$4709,$fffe,$180,$070
	dc.w	$4741,$fffe,$180,$000,$4809,$fffe,$180,$080
	dc.w	$4841,$fffe,$180,$000,$4909,$fffe,$180,$090
	dc.w	$4941,$fffe,$180,$000,$4a09,$fffe,$180,$0a0
	dc.w	$4a41,$fffe,$180,$000,$4b09,$fffe,$180,$0b0
	dc.w	$4b41,$fffe,$180,$000,$4c09,$fffe,$180,$0c0
	dc.w	$4c41,$fffe,$180,$000,$4d09,$fffe,$180,$0d0
	dc.w	$4d41,$fffe,$180,$000,$4e09,$fffe,$180,$0e0	
	dc.w	$4e41,$fffe,$180,$000,$4f09,$fffe,$180,$0f0
	dc.w	$4f41,$fffe,$180,$000,$5009,$fffe,$180,$0e0
	dc.w	$5041,$fffe,$180,$000,$5109,$fffe,$180,$0d0
	dc.w	$5141,$fffe,$180,$000,$5209,$fffe,$180,$0c0	
	dc.w	$5241,$fffe,$180,$000,$5309,$fffe,$180,$0b0	
	dc.w	$5341,$fffe,$180,$000,$5409,$fffe,$180,$0a0
	dc.w	$5441,$fffe,$180,$000,$5509,$fffe,$180,$090	
	dc.w	$5541,$fffe,$180,$000,$5609,$fffe,$180,$080
	dc.w	$5641,$fffe,$180,$000,$5709,$fffe,$180,$070
	dc.w	$5741,$fffe,$180,$000,$5809,$fffe,$180,$060	
	dc.w	$5841,$fffe,$180,$000,$5909,$fffe,$180,$050
	dc.w	$5941,$fffe,$180,$000,$5a09,$fffe,$180,$040
	dc.w	$5a41,$fffe,$180,$000,$5b09,$fffe,$180,$030	
	dc.w	$5b41,$fffe,$180,$000,$5c09,$fffe,$180,$020
	dc.w	$5c41,$fffe,$180,$000,$5d09,$fffe,$180,$010
	dc.w	$5d41,$fffe,$180,$000,$5e09,$fffe,$180,$000
copequ3
	dc.w	$6041,$fffe,$180,$000,$6109,$fffe,$180,$001
	dc.w	$6141,$fffe,$180,$000,$6209,$fffe,$180,$002	
	dc.w	$6241,$fffe,$180,$000,$6309,$fffe,$180,$003
	dc.w	$6341,$fffe,$180,$000,$6409,$fffe,$180,$004
	dc.w	$6441,$fffe,$180,$000,$6509,$fffe,$180,$005
	dc.w	$6541,$fffe,$180,$000,$6609,$fffe,$180,$006	
	dc.w	$6641,$fffe,$180,$000,$6709,$fffe,$180,$007
	dc.w	$6741,$fffe,$180,$000,$6809,$fffe,$180,$008
	dc.w	$6841,$fffe,$180,$000,$6909,$fffe,$180,$009
	dc.w	$6941,$fffe,$180,$000,$6a09,$fffe,$180,$00a
	dc.w	$6a41,$fffe,$180,$000,$6b09,$fffe,$180,$00b
	dc.w	$6b41,$fffe,$180,$000,$6c09,$fffe,$180,$00c
	dc.w	$6c41,$fffe,$180,$000,$6d09,$fffe,$180,$00d
	dc.w	$6d41,$fffe,$180,$000,$6e09,$fffe,$180,$00e	
	dc.w	$6e41,$fffe,$180,$000,$6f09,$fffe,$180,$00f
	dc.w	$6f41,$fffe,$180,$000,$7009,$fffe,$180,$00e
	dc.w	$7041,$fffe,$180,$000,$7109,$fffe,$180,$00d
	dc.w	$7141,$fffe,$180,$000,$7209,$fffe,$180,$00c	
	dc.w	$7241,$fffe,$180,$000,$7309,$fffe,$180,$00b	
	dc.w	$7341,$fffe,$180,$000,$7409,$fffe,$180,$00a
	dc.w	$7441,$fffe,$180,$000,$7509,$fffe,$180,$009	
	dc.w	$7541,$fffe,$180,$000,$7609,$fffe,$180,$008
	dc.w	$7641,$fffe,$180,$000,$7709,$fffe,$180,$007
	dc.w	$7741,$fffe,$180,$000,$7809,$fffe,$180,$006	
	dc.w	$7841,$fffe,$180,$000,$7909,$fffe,$180,$005
	dc.w	$7941,$fffe,$180,$000,$7a09,$fffe,$180,$004
	dc.w	$7a41,$fffe,$180,$000,$7b09,$fffe,$180,$003	
	dc.w	$7b41,$fffe,$180,$000,$7c09,$fffe,$180,$002
	dc.w	$7c41,$fffe,$180,$000,$7d09,$fffe,$180,$001
	dc.w	$7d41,$fffe,$180,$000,$7e09,$fffe,$180,$000
copequ4
	dc.w	$8041,$fffe,$180,$000,$8109,$fffe,$180,$110
	dc.w	$8141,$fffe,$180,$000,$8209,$fffe,$180,$220	
	dc.w	$8241,$fffe,$180,$000,$8309,$fffe,$180,$330
	dc.w	$8341,$fffe,$180,$000,$8409,$fffe,$180,$440
	dc.w	$8441,$fffe,$180,$000,$8509,$fffe,$180,$550
	dc.w	$8541,$fffe,$180,$000,$8609,$fffe,$180,$660	
	dc.w	$8641,$fffe,$180,$000,$8709,$fffe,$180,$770
	dc.w	$8741,$fffe,$180,$000,$8809,$fffe,$180,$880
	dc.w	$8841,$fffe,$180,$000,$8909,$fffe,$180,$990
	dc.w	$8941,$fffe,$180,$000,$8a09,$fffe,$180,$aa0
	dc.w	$8a41,$fffe,$180,$000,$8b09,$fffe,$180,$bb0
	dc.w	$8b41,$fffe,$180,$000,$8c09,$fffe,$180,$cc0
	dc.w	$8c41,$fffe,$180,$000,$8d09,$fffe,$180,$dd0
	dc.w	$8d41,$fffe,$180,$000,$8e09,$fffe,$180,$ee0	
	dc.w	$8e41,$fffe,$180,$000,$8f09,$fffe,$180,$ff0
	dc.w	$8f41,$fffe,$180,$000,$9009,$fffe,$180,$ee0
	dc.w	$9041,$fffe,$180,$000,$9109,$fffe,$180,$dd0
	dc.w	$9141,$fffe,$180,$000,$9209,$fffe,$180,$cc0	
	dc.w	$9241,$fffe,$180,$000,$9309,$fffe,$180,$bb0	
	dc.w	$9341,$fffe,$180,$000,$9409,$fffe,$180,$aa0
	dc.w	$9441,$fffe,$180,$000,$9509,$fffe,$180,$990	
	dc.w	$9541,$fffe,$180,$000,$9609,$fffe,$180,$880
	dc.w	$9641,$fffe,$180,$000,$9709,$fffe,$180,$770
	dc.w	$9741,$fffe,$180,$000,$9809,$fffe,$180,$660	
	dc.w	$9841,$fffe,$180,$000,$9909,$fffe,$180,$550
	dc.w	$9941,$fffe,$180,$000,$9a09,$fffe,$180,$440
	dc.w	$9a41,$fffe,$180,$000,$9b09,$fffe,$180,$330	
	dc.w	$9b41,$fffe,$180,$000,$9c09,$fffe,$180,$220
	dc.w	$9c41,$fffe,$180,$000,$9d09,$fffe,$180,$110
	dc.w	$9d41,$fffe,$180,$000,$9e09,$fffe,$180,$000

	dc.w	$ffff,$fffe

*---------------------------------------

module	incbin	source:modules/mod.music
	even
