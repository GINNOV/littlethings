** AUTHOR : RAISTLIN

** A small piece of code to load bob data & blit it. Copper is used to get
** more colours.

** Hearwig, take a look at my method for clearing a bitplane. Better than
;  reserving memory dont you think? The only problem is that other programs
;  will corrupt your memory. However forbiding stops this. Why is their a 
;  little distortion at the top.


	include	source10:include/hardware.i
	opt	c-
	section	raist,code_c
	
*******************************************************************************
;		INITIALISATION
******************************************************************************
	lea	$dff000,a5	
	move.l	4,a6
	lea	gfxname,a1
	moveq.l	#0,d0
	jsr	openlib(a6)	;open gfx library
	tst.l	d0
	beq	quit		;did it open correctly?
	move.l	d0,old		;save base
	jsr	forbid(a6)	;stop multi-tasking!

	move.l	#picture,d0
;bitplane
	move.w	d0,bpl1+2
	swap	d0		;set-up bitplane
	move.w	d0,bph1+2
	
******************************************************************************
;	DISABLE SPRITES, RUN MY COPPER LIST, DO BLIT, WAIT LMB
******************************************************************************
;load copper
	move.w	#$20,dmacon(a5)	;disable sprites
	move.l	#copperlist,cop1lch(a5)
	move.w	#0,copjmp1(a5)	;run my copper list

	bsr	blitter		;do blit
wait
	btst	#6,$bfe001	;wait for LMB
	bne	wait

*******************************************************************************
;	CLEAN-UP (keep Britain tidy) & EXIT
***************************************************************************
;clean-up
	move.l	old,a4
	move.l	startlist(a4),cop1lch(a5)
	move.w	#$0,copjmp1(a5)	;restore system copper list
	move.l	4,a6
	move.l	old,a1
	jsr	closelib(a6)	;close gfx lib
	jsr	permit(a6)	;allow multi-tasking
	move.w	#$83e0,dmacon(a5)	;restore DMA
quit	rts			;end

******************************************************************************
;			BLITTER
******************************************************************************
BLITTER
	move.l	#bob,bltapth(a5)		;get address of bob
	move.l	#picture,d0		;get address of screen
	add.l	#$60,d0			;put bob in middle
	move.l	d0,bltdpth(a5)		;load destination ptr
	clr.w	bltamod(a5)		;no Amodulo
	move.w	#38,bltdmod(a5)		;38 Dmodulo
	move.w	#$ffff,bltafwm(a5)		;no mask
	move.w	#$ffff,bltalwm(a5)		;no mask
	move.w	#%100111110000,bltcon0(a5)	;enable A & D
	clr.w	bltcon1(a5)		;not needed 
	move.w	#%1011000001,bltsize(a5)	;start blit (16*16)
	rts
bob	incbin	source10:bitmaps/bob(16*16)		;call bob graphs


****************************************************************************
;		COPPER LIST
*****************************************************************************
copperlist
	dc.w	diwstrt,$2c81		;usual stuff
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon0,%0001001000000000
	dc.w	bplcon1,$0
	dc.w	color00,$000
	dc.w	color01,$fff
bph1	dc.w	bpl1pth,$0
bpl1	dc.w	bpl1ptl,$0
	dc.w	color01,$f00	;a 1 color bob (the square)
	dc.w	$2f01,$fffe	;is shaded in loads
	dc.w	color01,$a00	;& loads of colours
	dc.w	$3001,$fffe	;neat little trick eh?
	dc.w	color01,$700
	dc.w	$3101,$fffe
	dc.w	color01,$500
	dc.w	$3201,$fffe
	dc.w	color01,$300
	dc.w	$3301,$fffe	
	dc.w	color01,$500
	dc.w	$3401,$fffe
	dc.w	color01,$700
	dc.w	$3501,$fffe
	dc.w	color01,$a00
	dc.w	$3601,$fffe
	dc.w	color01,$d00
	dc.w	$3701,$fffe
	dc.w	color01,$f00	;end of shading
	
end	dc.w	$ffff,$fffe	;end of list (impossible wait!)

;program variables
openlib	equ	-408
closelib	equ	-414
forbid	equ	-132
permit	equ	-138
startlist	equ	38

gfxname	dc.b	'graphics.library',0
	even
old	ds.l	0
picture	dcb.b	256*40,0		;reserve memory for bitplane

