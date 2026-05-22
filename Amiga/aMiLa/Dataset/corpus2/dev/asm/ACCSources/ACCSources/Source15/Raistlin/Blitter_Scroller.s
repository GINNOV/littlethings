**************************************************************************
** CODE    :  BLITTER SCROLLER
** CREDITS :  CODED BY RAISTLIN, FONTS DRAWN BY NOTMAN
** NOTES   :  Main routine was adapted from MJCs tutorial source
***************************************************************************


	include	source:include/hardware.i
	opt	c-			;Any case
	
	lea	$dff000,a5	
	
	move.l	4,a6			;Exec
	jsr	-132(a6)		;Forbid
	moveq.l	#0,d0			;Any Version
	lea	gfxname,a1
	jsr	-552(a6)		;Open gfx lib
	tst.l	d0			;Did it open?
	beq	quit
	move.l	d0,gfxbase		;Save lib base address

	clr.w	plop			;Clear the counters
	clr.w	pausecnt
	clr.w	charflag

***Set-Up Playfield (1 bitplane)
	move.l	#screen,d0		;Address of screen on d0
	move.w	d0,bpl1+2		;Load bitplane pointers
	swap	d0
	move.w	d0,bph1+2

***Set-Up Hardware
	move.w	#$20,dmacon(a5)		;Disable sprites
	move.l	#copperlist,cop1lch(a5)
	move.w	#0,copjmp1(a5)		;Run my copper


Main	cmpi.b	#200,$dff006		;Test vbl
	bne	main
	bsr	scroller		;Jump to scroller
	btst	#6,$bfe001		;Test LMB
	bne	Main
	bra	Clean_up		;Jump to exit


**************************************************************************
;			SCROLLER
**************************************************************************
;The Font layout is
;     space
; 	|
;	 !"#$%&'()		;As you can see there are 10 cahacters per
;	*+,-./0123		;line. Some of the symbols represent 
;	456789:;<=		;something else in the scroller!
;	>?@ABCDEFG
;	HIJKLMNOPQ
;	RSTUVWXYZ[
;	\]^_

scroller
	btst	#$a,$dff016		;RMB?
	beq	Outscr			;If so pause text
	cmpi.w	#0,pausecnt		;Is pause required?
	beq	no_pause
	subi.w	#1,pausecnt		;Decrease pause counter
outscr	rts				

No_pause	
	cmpi.w	#1,charflag		;is it end of text?
	beq	no_need		
	lea	text,a4			;Yes, then re-load counter
no_need	move.w	#1,charflag
	cmpi.w	#0,plop			;Do we need a new character?
	beq	nextchar
contscrl
	bsr	scroll			;No, then scroll screen
	rts
Nextchar
	bsr	getchar			;Yes, then get it from text
	move.w	#16,plop			;Reset plop counter
	bra	contscrl		;An continue scrolling
	rts

getchar
	lea	font,a2			;Address of fonts in a2
	moveq.l	#0,d0	
	move.b	(a4)+,d0		;Get curreny character
	cmpi.b	#120,d0			;Is it end of text? (x)
	bne 	notend
	clr.w	charflag		;Yes, then reload text
	bra 	main
notend
	move.w	#$FFFc,bltalwm(a5)	;Mask out last line
	cmpi.b	#99,d0			;Is it a pause request? (c)
	beq	pause			;Yes, goto pause
	cmpi.b	#$0a,d0
	beq	outscr
	cmpi.b	#58,d0			;Checks for the double	
	beq	nomask			;fonts (ie Anthrax logo)		
	cmpi.b	#91,d0
	beq	nomask
	cmpi.b	#60,d0			;mask
	beq	nomask
	cmpi.b	#92,d0
	beq	nomask
	cmpi.b	#93,d0
	beq	nomask
	cmpi.b	#94,d0
	beq	nomask
	bra	mask
nomask	move.w	#$ffff,bltalwm(a5)	;No mask

mask	cmpi.b	#41,d0			;Are we on line 1?
	bgt	Line2?			
	bra	line_1
line2?
	cmpi.b	#51,d0			;Are we on line 2?
	bgt	Line3?
	bra	line_2
line3?
	cmpi.b	#61,d0			;Line 3?
	bgt	Line4?
	bra	line_3
line4?
	cmpi.b	#71,d0			;Line 4?
	bgt	line5?
	bra	line_4
line5?
	cmpi.b	#81,d0			;Line 5?
	bgt	line6?
	bra	line_5
line6?
	cmpi.b	#91,d0			;Line 6?
	bgt	line_7
	bra	line_6


line_1
	sub	#32,d0			;Find posistion in Font
	mulu	#4,d0			;Find exact position
	add.l	d0,a2
	bsr	plopit			;Plop character routine
	rts

line_2
	sub	#42,d0			;A little maths to find
	mulu	#4,d0			;The pos in font
	add.l	#40*32,d0
	add.l	d0,a2
	bsr	plopit
	rts
line_3
	sub	#52,d0
	mulu	#4,d0
	add.l	#40*64,d0
	add.l	d0,a2
	bsr	plopit
	rts

line_4
	sub	#62,d0
	mulu	#4,d0
	add.l	#40*96,d0
	add.l	d0,a2
	bsr	plopit
	rts

line_5
	sub	#72,d0
	mulu	#4,d0
	add.l	#40*128,d0
	add.l	d0,a2
	bsr	plopit
	rts

line_6
	sub	#82,d0
	mulu	#4,d0
	add.l	#40*160,d0
	add.l	d0,a2
	bsr	plopit
	rts

line_7
	sub	#92,d0
	mulu	#4,d0
	add.l	#40*192,d0
	add.l	d0,a2
	bsr	plopit
	

	rts
pause	move.w	#140,pausecnt		;Set pause delay counter
	bra	main
	rts


*************************
**THE BLITTER ROUNTINES**
*************************
Scroll
	lea	screen+6524,a0		;Address of screen + offset in a0
	bsr	tstbbusy		;Test if blitter is working
	move.l	a0,bltapth(a5)		;Screen is source
	move.l	a0,a1
	sub.l	#1,a1			;-1 from screen address
	move.l	a1,bltdpth(a5)		;This goes in destination
	move.w	#0,bltamod(a5)		;No modulos
	move.w	#0,bltdmod(a5)
	move.w	#$ffff,bltafwm(a5)	;No masking
	move.w	#$ffff,bltalwm(a5)
	move.w	#%1110100111110000,bltcon0(a5)
	move.w	#$0,bltcon1(a5)
	move.w	#%00001000000010111,bltsize(a5)
	sub.w	#1,plop			;Decrease plop counter
	rts


Plopit
	lea	screen+6524,a3		;Address of screen + offset in a0
	bsr	tstbbusy		;Test if blitter is working
	move.l	a2,bltapth(a5)		;Charcter in source
	move.l	a3,bltdpth(a5)		;Screen in destination
	move.w	#36,bltamod(a5)		;36 A modulo
	move.w	#44,bltdmod(a5)		;44 D modulo (using overscan)
	move.w	#%0000100111110000,bltcon0(a5)
	move.w	#%0000100000000010,bltsize(a5)
	rts


TstBBusy
	btst	#14,dmaconr(a5)		;Test if blitter is working
	bne	tstbbusy
	rts

Clean_up
	move.w	#$8e30,dmacon(a5)	;Re-enable sprites
	move.l	gfxbase,a1
	move.l	38(a1),cop1lch(a5)	;Restore sys copper
	move.w	#0,copjmp1(a5)		;Run sys copper
	move.l	4,a6			;Exec base
	jsr	-138(a6)		;Permit
	move.l	gfxbase,a1		;Name of lib to close in a1
	jsr	-414(a6)		;Close lib
quit	rts				;Bye! Bye!



*****************************************************************************
;			COPPER LIST
*****************************************************************************
	section	copper,code_c		;Give us chip

copperlist
	dc.w	diwstrt,$2010
	dc.w	diwstop,$36D4
	dc.w	ddfstrt,$0030
	dc.w	ddfstop,$00D4
	dc.w	bplcon0,%0001001000000000
	dc.w	bplcon1,$0

	dc.w	bpl1mod,0004
	dc.w	bpl2mod,0004

	dc.w	color00,$000

bph1	dc.w	bpl1pth,$0
bpl1	dc.w	bpl1ptl,$0
				
	dc.w	$9f01,$fffe	;This section
	dc.w	color00,$800	;does ye olde
	dc.w	$a001,$fffe	;copper bars
	dc.w	color00,$c00	;Havent done any
	dc.w	$a101,$fffe	;copper bars for ages!!
	dc.w	color00,$f00
	dc.w	$a301,$fffe	;PS these r d red uns
	dc.w	color00,$c00
	dc.w	$a401,$fffe
	dc.w	color00,$800
	dc.w	$a501,$fffe
	dc.w	color00,$000

;COPPER SHADING
	dc.w	$a801,$fffe
	dc.w	color01,$ff0
	dc.w	$aa01,$fffe
	dc.w	color01,$fe0
	dc.w	$ac01,$fffe
	dc.w	color01,$fd0
	dc.w	$ae01,$fffe
	dc.w	color01,$fc0
	dc.w	$b101,$fffe
	dc.w	color01,$fb0
	dc.w	$b301,$fffe
	dc.w	color01,$fa0
	dc.w	$b501,$fffe
	dc.w	color01,$f90
	dc.w	$b701,$fffe
	dc.w	color01,$f80
	dc.w	$b901,$fffe	
	dc.w	color01,$f70
	
	dc.w	$ca01,$fffe
	dc.w	color00,$800
	dc.w	$cb01,$fffe
	dc.w	color00,$c00
	dc.w	$cc01,$fffe
	dc.w	color00,$f00
	dc.w	$cd01,$fffe
	dc.w	color00,$c00
	dc.w	$ce01,$fffe
	dc.w	color00,$800	;all that code for those
	dc.w	$cf01,$fffe	;measily things!!
	dc.w	color00,$000	


	dc.w	$ffff,$fffe


;Program Variables
gfxname	dc.b	'graphics.library',0
	even
gfxbase	ds.l	1
	even
screen	dcb.b	356*46,0			;Memory for screen
	even
plop		dc.w	0			;Counters

pausecnt	dc.w	0

charflag	dc.w	0
	even	
Font	incbin	source:bitmaps1/font.bm

text		incbin	source:raistlin/scrolltext
