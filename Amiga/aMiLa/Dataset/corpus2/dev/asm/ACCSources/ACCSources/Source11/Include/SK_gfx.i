;GRAPHICS macros ; Simon Knipe ; v1.0

;	DRAWRECT	draw rectangle of specified colour in window

*************************************************************** GFX ***
;Purpose: draw rectangle of specified colour in window
;To call: DRAWRECT WindowHandle,Colour,X,Y,Width,Height

DRAWRECT MACRO
	move.l	\1,a1	windowhandle
	move.l	50(a1),a1	RastPort
	move.l	gfxbase,a6	get gfx
	move.l	#\2,d0	colour
	jsr	setapen(a6)	set gfx colour
	move.l	#\3,d0	x-offset for draw
	move.l	#\4,d1	y-
	move.l	#\5,d2	width of rectangle
	move.l	#\6,d3	height-
	ext.l	d0
	ext.l	d1
	ext.l	d2
	ext.l	d3
	jsr	rectfill(a6)	clear the window
	ENDM
