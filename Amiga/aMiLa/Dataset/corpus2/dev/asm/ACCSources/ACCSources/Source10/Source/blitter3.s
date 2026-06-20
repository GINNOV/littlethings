** Raistlin (an attempt! to produce a 3 colour blit)
** At last a two bitplane blit!!

	include	source10:include/hardware.i
	opt	c-
	section	BLITTER!,code_c

	lea	$dff000,a5

	move.l	4,a6
	jsr	-132(a6)		;forbid
	lea	gfxname,a1
	moveq.l	#0,d0
	jsr	-408(a6)		;open gfx.lib
	tst.l	d0
	beq	quit
	move.l	d0,gfxbase

;Bit-Planes
;----------
	move.l	#picture,d0	;set-up screen
;plane 1
	move.w	d0,bpl1+2
	swap	d0
	move.w	d0,bph1+2
	swap	d0
	add.w	#256*40,d0
	move.l	d0,pic2
;plane2
	move.w	d0,bpl2+2
	swap	d0
	move.w	d0,bph2+2

	move.w	#$20,dmacon(a5)	;disable sprites
	move.l	#copperlist,cop1lch(a5)
	move.w	#0,copjmp1(a5)	;run my copper

	bsr	blitter		;blit dat zit

wait	btst	#6,$bfe001	;left mouse butt
	bne	wait

clean_up
	move.w	#$8e30,dmacon(a5)	;enable sprites
	move.l	gfxbase,a1
	move.l	38(a1),cop1lch(a5)
	move.l	4,a6
	jsr	-138(a6)		;permit
	move.l	gfxbase,a1
	jsr	-414(a6)		;close gfx.lib
quit	rts			;bye!bye!

*******************************************************************************
;		BLITTER
****************************************************************************
Blitter
	move.l	#bob,d0		;address of bob >> d0
	move.l	#picture,d1	;address of bitplane >>d1

	add.l	#50*$40+$10,d1	centralise it so we can all see ( MM )

	move.l	#1,d2		;2 bitplanes
boby	
	bsr	bert		;blit plane
	dbra	d2,boby		;next plane

bert	btst	#14,dmaconr(a5)
	bne	bert
	
	move.l	d0,bltapth(a5)	;address of bob in A
	move.l	d1,bltdpth(a5)	;address of destination (screen)
	move.w	#$0,bltamod(a5)
	move.w	#38,bltdmod(a5)	;38 D modulo
	move.w	#%0000100111110000,bltcon0(a5)
	move.w	#$0,bltcon1(a5)
	move.w	#$ffff,bltafwm(a5)	;no mask
	move.w	#$ffff,bltalwm(a5)
	move.w	#%101000001,bltsize(a5)	
	add.l	#40*256,d1	;get next bitplane
	add.l	#2*5,d0		;get next bob plane
	rts

bob	dc.b	%11111111,%11111111	;bob plane 1
	dc.b	%10000000,%00000001
	dc.b	%10000000,%00000001
	dc.b	%10000000,%00000001
	dc.b	%11111111,%11111111
bob1	dc.b	%00000001,%10000000	;bob plane 2
	dc.b	%00000001,%10000000
	dc.b	%11111111,%11111111
	dc.b	%00000001,%10000000
	dc.b	%00000001,%10000000

*****************************************************************************
;		COPPER LIST
***************************************************************************
copperlist
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon0,%0010001000000000
	dc.w	bplcon1,$0
	dc.w	color02,$f00
	dc.w	color03,$0f0
bph1	dc.w	bpl1pth,$0
bpl1	dc.w	bpl1ptl,$0
bph2	dc.w	bpl2pth,$0
bpl2	dc.w	bpl2ptl,$0
	dc.w	$ffff,$fffe

;progam variables

gfxname	dc.b	'graphics.library',0
	even
gfxbase	dc.l	0
	even
picture	dcb.b	256*40*2,0
	even
pic2	dc.l	0
