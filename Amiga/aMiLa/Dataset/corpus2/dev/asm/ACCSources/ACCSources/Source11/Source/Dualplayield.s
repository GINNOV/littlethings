** CODE    : EXAMPLE OF DUALPLAYFIELD PRIORITYS
** BUGS	   : SPRITE2 CORRUPRTS WHEN IT GETS TO THE BOTTOM OF THE SCREEN.
;  	     TRY CHANGING THE SECOND SPRITES COLOUR FROM RED!!!

	opt	c-			;I have capitals!
	include	source:include/hardware.i		;Include for all my custom offsets
	section	Dual,code_c		;Make sure it works on 1 meg!

	move.l	4,a6
	jsr	-132(a6)		;Forbid!

	lea	$dff000,a5

********************************************************************************
; This section loads the graphics for the first playfield (the one with the
; highest priority, unless changed. Note odd planes are used for the first
; playfield. This playfield uses Colour registers 0-7 (0 is transparent).
*******************************************************************************
	move.l	#picture1,d0	;Get address of graphic data
Plane1
	move.w	d0,bp1l		;LSW goes into bpl1ptl 
	swap	d0		;get MSW
	move.w	d0,bp1h		;MSW goes into bpl1pth
	swap	d0		;get LSW
	add.l	#$2800,d0	;Get next plane
plane3
	move.w	d0,bp3l		;LSW
	swap	d0
	move.w	d0,bp3h		;MSW
	swap	d0
	add.l	#$2800,d0		;Get next plane
plane5
	move.w	d0,bp5l		;LSW
	swap	d0
	move.w	d0,bp5h		;MSW
	swap	d0

********************************************************************************
; This section loads the graphics for playfield 2 (lowest priority, unless 
; changed. Playfield 2 uses the even bitplane pointers & colour registers 8-14
; 8 is transparent.
******************************************************************************
	move.l	#picture2,d0		;Get address of raw graphics
plane2
	move.w	d0,bp2l			;put LSW into bpl2ptl
	swap	d0			;get MSW
	move.w	d0,bp2h			;Put MSW into bpl2pth
	swap	d0			;get LSW
	add.l	#$2800,d0		;get next plane
plane4
	move.w	d0,bp4l			;LSW
	swap	d0
	move.w	d0,bp4h			;MSW
	swap	d0
	add.l	#$2800,d0		;get next plane
plane6
	move.w	d0,bp6l
	swap	d0
	move.w	d0,bp6h
	
**************************************************************************
;		Set-up sprite registers
**************************************************************************
;Car sprites
	move.l	#car1s,d0		;set-up car sprites
	move.w	d0,sp1l+2
	swap	d0
	move.w	d0,sp1h+2
	move.l	#car2s,d0
	move.w	d0,sp3l+2
	swap	d0
	move.w	d0,sp3h+2
;Dummy sprites
	move.l	#carend,d0		;Prevent garbage flashing
	move.w	d0,sp2l+2		;on screen
	move.w	d0,sp2h+2
	move.w	d0,sp4h+2
	move.w	d0,sp4l+2
	move.w	d0,sp5h+2
	move.w	d0,sp5l+2
	move.w	d0,sp6h+2
	move.w	d0,sp6l+2
	move.w	d0,sp7h+2
	move.w	d0,sp7l+2
	move.w	d0,sp8h+2
	move.w	d0,sp8l+2

;Insert my copper list
	move.l	#copperlist,cop1lch(a5)	;load copper list
	move.w	#0,copjmp1		;Start list

;Move car & check for LMB
wait	cmpi.b	#200,$dff006		;Wait vbl
	bne	wait	
	bsr	movecar
	btst	#6,$bfe001		;Wait for left mouse button
	bne	wait

*******************************************************************************
;		Clean-up ready for leaving
*******************************************************************************
cleanup
	move.l	#gfxname,a1		;a1=library name
	moveq.l	#0,d0			;any version
	jsr	-408(a6)		;open graphics lib
	move.l	d0,gfxbase		;get library base
	move.l	d0,a4			;a4=graphics lib
	move.l	38(a4),cop1lch(a5) 	;Restore System copper
	clr.w	copjmp1(a5)	
	move.w	#$83e0,dmacon(a5) 	;Enable all DMA
	jsr	-138(a6)		;Permit
	move.l	4,a6		
	move.l	gfxbase,a1		;gfx base in a1
	jsr	-414(a6)		;close gfx library
	rts				;EXIT

*****************************************************************************
;			Move the car
*****************************************************************************
movecar
	add.b	#$1,car1s+1		;Move horizontal
	add.b	#$1,car2s		;Move vertical
	add.b	#$1,car2s+2		;Ne VSTOP
	rts

*****************************************************************************
;			Sprite Data
*****************************************************************************

car1s	dc.w	$9399,$9f00		;Control Words
	dc.w	$703f,$0fc0,$7fff,$0000,$4000,$3fff,$47ff,$3fff
	dc.w	$58ff,$3fff,$5f00,$3fff,$5f00,$3fff,$5f00,$3fff
	dc.w	$5f00,$3fff,$5f00,$3fff,$5f00,$3fff,$5e00,$3fff
	dc.w	$59ff,$3fff,$47ff,$3fff,$4000,$3fff,$7fff,$0000
	dc.w	$701f,$0fe0,$0000,$0000
car2s	dc.w	$e299,$ff00		;Control Words
	dc.w	$0000,$ffff,$0000,$ffff,$3ff8,$c007,$2008,$dff7
	dc.w	$2008,$dff7,$2008,$dff7,$2008,$dff7,$3ff8,$c007
	dc.w	$3ff8,$ffff,$3ff8,$ffff,$3ff8,$efef,$3ff8,$efef
	dc.w	$3ff8,$f7df,$3ff8,$f7df,$3ff8,$fbbf,$3ff8,$f83f
	dc.w	$3c78,$fbbf,$3c78,$bbf0,$3c78,$fbbf,$3c78,$fbbf
	dc.w	$3ff8,$f83f,$3ff8,$fbbf,$3ff8,$f7df,$3ff8,$efef
	dc.w	$3ff8,$efef,$3ff8,$ffff,$0000,$ffff,$0000,$ffff
carend	dc.w	$0000,$0000


*******************************************************************************
;		Copper list data
*******************************************************************************
copperlist
	dc.w	diwstrt,$2c81	;Usual setup for a playfield
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon0,%0110011000000000	;DBPFD on
	dc.w	bplcon1,$0
	dc.w	bplcon2,%00000000001001010	;Priority control
playfield1
	dc.w	color00,$000	;colours for playfield 1
	dc.w	color01,$0c8	;note these could be loaded
	dc.w	color02,$888	from disk
	dc.w	color03,$444
	dc.w	color04,$2f0
	dc.w	color05,$070
	dc.w	color06,$fff
	dc.w	color07,$0cc
playfield2
	dc.w	color08,$000	
	dc.w	color09,$fff
	dc.w	color10,$bcc
	dc.w	color11,$333
	dc.w	color12,$f00
	dc.w	color13,$000
	dc.w	color14,$777
	dc.w	color15,$fc0

;Sprite Colours
	dc.w	color17,$555
	dc.w	color18,$900
	dc.w	color19,$000
	dc.w	color21,$555
	dc.w	color22,$900
	dc.w	color23,$000

;Sprite Pointers
sp1h	dc.w	spr0pth,$0
sp1l	dc.w	spr0ptl,$0
sp2h	dc.w	spr1pth,$0
sp2l	dc.w	spr1ptl,$0
sp3h	dc.w	spr2pth,$0
sp3l	dc.w	spr2ptl,$0
sp4h	dc.w	spr3pth,$0
sp4l	dc.w	spr3ptl,$0
sp5h	dc.w	spr4pth,$0
sp5l	dc.w	spr4ptl,$0
sp6h	dc.w	spr5pth,$0
sp6l	dc.w	spr5ptl,$0
sp7h	dc.w	spr6pth,$0
sp7l	dc.w	spr6ptl,$0
sp8h	dc.w	spr7pth,$0
sp8l	dc.w	spr7ptl,$0

;Bitplane Pointers
	dc.w	bpl1pth		;Bitplane pointers
bp1h	dc.w	0,bpl1ptl
bp1l	dc.w	0,bpl2pth
bp2h	dc.w	0,bpl2ptl
bp2l	dc.w	0,bpl3pth
bp3h	dc.w	0,bpl3ptl
bp3l	dc.w	0,bpl4pth
bp4h	dc.w	0,bpl4ptl
bp4l	dc.w	0,bpl5pth
bp5h	dc.w	0,bpl5ptl
bp5l	dc.w	0,bpl6pth
bp6h	dc.w	0,bpl6ptl
bp6l	dc.w	0

end	dc.w	$ffff,$fffe	;End of copper list


;program variables

gfxname	dc.b	'graphics.library',0
	even
gfxbase	ds.l	0
	even
picture1	incbin	df1:bitmaps/p1		;RAW graphics for playfield 1
picture2	incbin	df1:bitmaps/p2 		;RAW graphics for playfield 2
