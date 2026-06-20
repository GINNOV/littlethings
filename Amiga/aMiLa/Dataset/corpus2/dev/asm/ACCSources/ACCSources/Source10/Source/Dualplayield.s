** CODE   : MY FIRST DUAL PLAYFIELD
** AUTHOR : RAISTLIN
** DATE	: 9.2.91 (2:45:00)
** SIZE   : 396 BYTES (EXCLDING PICTURE DATA)  
** NOTES  :
;	 This was very simple to do. Just remember that the odd bitplanes
; are used for playfield 1 (1,3,5) and the even bitplanes are used for the
; second playfield (2,4,6). You can only have 7 colours per playfield ,because
; of the way playfields are set-up you loose 16 colours!!
; If you dont belive that it is two seperate playfields look at the gfx!!

	opt	c-		;I have capitals!
	include	source10:include/hardware.i	;Include for all my custom offsets
	section	Dual,code_c	;Make sure it works on 1 meg!

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
	add.l	#$2800,d0		;Get next plane
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
	move.l	#picture2,d0	;Get address of raw graphics
plane2
	move.w	d0,bp2l		;put LSW into bpl2ptl
	swap	d0		;get MSW
	move.w	d0,bp2h		;Put MSW into bpl2pth
	swap	d0		;get LSW
	add.l	#$2800,d0		;get next plane
plane4
	move.w	d0,bp4l		;LSW
	swap	d0
	move.w	d0,bp4h		;MSW
	swap	d0
	add.l	#$2800,d0		;get next plane
plane6
	move.w	d0,bp6l
	swap	d0
	move.w	d0,bp6h
	
*******************************************************************************
;Disable sprites, stop flickering. Load out copperlist. Activate it.
******************************************************************************
;Usual stuff
	move.w	#$0020,dmacon(a5)		;Disable sprites
	move.l	#copperlist,cop1lch(a5)	;load copper list
	move.w	#0,copjmp1		;Start list

;wait for left mouse button before continuing
wait	btst	#6,$bfe001	;Wait for left mouse button
	bne	wait

*******************************************************************************
;		Clean-up ready for leaving
*******************************************************************************
cleanup
	move.l	#gfxname,a1	;a1=library name
	moveq.l	#0,d0		;any version
	jsr	-408(a6)		;open graphics lib
	move.l	d0,gfxbase	;get library base
	move.l	d0,a4		;a4=graphics lib
	move.l	38(a4),cop1lch(a5) 	;Restore System copper
	clr.w	copjmp1(a5)	
	move.w	#$83e0,dmacon(a5) 	;Enable all DMA
	jsr	-138(a6)		;Permit
	move.l	4,a6		
	move.l	gfxbase,a1	;gfx base in a1
	jsr	-414(a6)		;close gfx library
	rts			;EXIT

*******************************************************************************
;		Copper list data
*******************************************************************************
copperlist
	dc.w	diwstrt,$2c81	;Usual setup for a playfield
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon0,%0110011000000000	;Using 3 bitplanes, DBPFD on & Colour on
	dc.w	bplcon1,$0
playfield1
	dc.w	color00,$000	;colours for playfield 1
	dc.w	color01,$fff	;note these could be loaded
	dc.w	color02,$b00	;from disk
	dc.w	color03,$444
	dc.w	color04,$240
	dc.w	color05,$eb0
	dc.w	color06,$b52
	dc.w	color07,$888
playfield2
	dc.w	color08,$000	;colours for playfield 2
	dc.w	color09,$fff	;note these could be loaded
	dc.w	color10,$b00	;from disk
	dc.w	color11,$444
	dc.w	color12,$240
	dc.w	color13,$eb0
	dc.w	color14,$888
	dc.w	color15,$1ff

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
picture1	incbin	df1:bitmaps/front	;RAW graphics for playfield 1
picture2	incbin	df1:bitmaps/back	;RAW graphics for playfield 2
