** CODE   : Raistlin's very first blitter logo!!
** AUTHOR : erm?
** DATE   : 17.2.91.
** NOTE   :
;	 I've just spent 3 hours doing this. I't took me 25 mins to debugg
; the code & 2 hours to convert the text!! Why did nobody say you use 
; RAW NORM for the blitter -arghh!!!!

	include	source10:include/hardware.i
	opt	c-		
	section	logo,code_c	;chip ram

	lea	$dff000,a5
	
	move.l	4,a6
	jsr	-132(a6)		;forbid
	lea	gfxname,a1
	moveq.l	#0,d0		;any version
	jsr	-408(a6)		;open gfx
	tst.l	d0		;did it open correctly?
	beq	quit		;nope!
	move.l	d0,gfxbase	;safe gfx base address

**************************************************************************
;		SET-UP BITPLANES
**************************************************************************
	move.l	#picture,d0	;address of mem for bitplane
;plane1
	move.w	d0,bpl1+2		;now set-up
	swap	d0		;a 3 bitplane
	move.w	d0,bph1+2		;playfield
	swap	d0
	add.l	#256*40,d0
;plane2
	move.w	d0,bpl2+2
	swap	d0
	move.w	d0,bph2+2
	swap	d0
	add.l	#256*40,d0
;plane3
	move.w	d0,bpl3+2
	swap	d0
	move.w	d0,bph3+2

;set-up copper & disable sprites
	move.w	#$0020,dmacon(a5)	;disable sprites
	move.l	#copperlist,cop1lch(a5)
	move.w	#0,copjmp1(a5)	;use my copper

	bsr	blitter		;blit logo

wait	btst	#6,$bfe001
	bne	wait		;LMB pressed?

;clean_up
	move.w	#$83e0,dmacon(a5)	;enable sprites
	move.l	gfxbase,a1
	move.l	38(a1),cop1lch(a5)	;restore system copper
	move.l	4,a6
	jsr	-138(a6)		;permit
	move.l	gfxbase,a1
	jsr	-414(a6)		;close gfx lib
	move.l	#0,d0		;keep CLI happy
quit	rts			;bye,bye!

***************************************************************************
;			BLITTER
***************************************************************************
blitter
	move.l	#bob,d0
	move.l	#picture+1044,d1
	
	move.w	#2,d2		;number of bitplanes-1
loopy	bsr	boby
	dbra	d2,loopy		;keep going!!

boby	btst	#14,dmaconr(a5)	;is blitter working (hard I hope!)
	bne	boby		;yep! hes a working.
	move.l	d0,bltapth(a5)	;address of bob in source A
	move.l	d1,bltdpth(a5)	;address of screen in D
	move.w	#$0,bltamod(a5)
	move.w	#18,bltdmod(a5)	;18 D modulo (or bob corruption will occur!)
	move.w	#$ffff,bltafwm(a5)	;no mask
	move.w	#$ffff,bltalwm(a5)	;no mask
	move.w	#%0000100111110000,bltcon0(a5)
	move.w	#$0,bltcon1(a5)
	move.w	#%1101000001011,bltsize(a5)
	add.l	#256*40,d1	;get next bitplane
	add.l	#104*22,d0	;get next bobplane
	rts


***************************************************************************
;			COPPER LIST
*****************************************************************************
copperlist
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon0,%0011001000000000
	dc.w	bplcon1,$0

	dc.w	color00,$000
	dc.w	color01,$fff
	dc.w	color02,$ccc
	dc.w	color03,$aaa
	dc.w	color04,$888
	dc.w	color05,$666
	dc.w	color06,$444
	dc.w	color07,$222
	
bph1	dc.w	bpl1pth,$0
bpl1	dc.w	bpl1ptl,$0
bph2	dc.w	bpl2pth,$0
bpl2	dc.w	bpl2ptl,$0
bph3	dc.w	bpl3pth,$0
bpl3	dc.w	bpl3ptl,$0
	
	dc.w	$ffff,$fffe

;program variables
	
gfxname	dc.b	'graphics.library',0
	even
gfxbase	dc.l	0
	even
picture	dcb.b	256*40*3,0	;reserve memory for playfield
bob	incbin	df1:bitmaps/logo1	;raw graphics for blitter
