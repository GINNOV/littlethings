;Amiga Machine Langage code to open screen and window, and draw image.
;Why doesn`t it work??

; Two reasons it never worked. Firstly, in line 17 a1 should hold the address
;of the image data and not the value held at the address of image data. The
;other reason is that image data ( as with sprites ) must be in chip memory.
;I have corrected the code and all is now OK.  M.Meany.

openlib		=	-408
closelib	=	-414
execbase	=	4
openscreen	=	-198
closescreen	=	-66
openwindow	=	-204
closewindow	=	-72
drawimage	=	-114

		bsr		openint		open intuition.lib
		bsr		openscr		open our screen
		bsr		openwind

		lea		image,a1	ptr to image struct
		move		#30,d0		x-pos
		move		#50,d1		y-
		bsr		draw		draw the image

wait		btst		#6,$bfe001	wait for left mouse
		bne		wait
		bsr		closewind
		bsr		closescr
		rts
***********************************************************************
openscr		move.l		intbase,a6	load adr of intuition
		lea		screen_defs,a0	adr of screen details
		jsr		openscreen(a6)	open the screen
		move.l		d0,screenhd	save screen handle
		rts
closescr	move.l		intbase,a6	load adr of intuition
		move.l		screenhd,a0	get screen handle
		jsr		closescreen(a6)	close it
		rts
openint		move.l		execbase,a6	get exec
		lea		intname,a1	name of library
		jsr		openlib(a6)	open intuition.bitch
		move.l		d0,intbase	save address
		rts
closeint	move.l		execbase,a6	get exec
		move.l		intbase,a1	get address of intuit
		jsr		closelib(a6)	close it
		rts
openwind	move.l		intbase,a6
		lea		windowdef,a0	adr of window structure
		jsr		openwindow(a6)
		move.l		d0,windowhd	save window handle
		rts
closewind	move.l		intbase,a6
		move.l		windowhd,a0	recover handle
		jsr		closewindow(a6)
		rts
draw		move.l		intbase,a6
		move.l		windowhd,a0
		move.l		50(a0),a0	Rastport
		jsr		drawimage(a6)
		rts
*****************************************************************************
windowhd	dc.l		0
windowdef	dc.w		10		x-pos on screen
		dc.w		20		y-pos on screen
		dc.w		300		width
		dc.w		150		height
		dc.b		1		print colour (1=white)
		dc.b		3		background   (3=red)
		dc.l		$200		IDCMP flags: CloseWindow
		dc.l		$100f		activate / all gadgets
		dc.l		0		no custom gadgets
		dc.l		0		checkmark
		dc.l		windowname	adr of name text
screenhd	dc.l		0		screen handle savepoint
		dc.l		0		no custom bitmap
		dc.w		150		smallest window width
		dc.w		50		smallest window height
		dc.w		320		max window width
		dc.w		200		max window width
		dc.w		15		screen=custom
windowname	dc.b		"A con window?",0
		even
intname		dc.b		"intuition.library",0
		even
intbase		dc.l		0
		even
screen_defs					; start of screen struct
xpos		dc.w		0		X-corner
ypos		dc.w		0		Y-corner
width		dc.w		320		width of screen
height		dc.w		256		height of screen
depth		dc.w		2		bitplanes (NOT colours)
detail_pen	dc.b		0		colour of titlebar
block_pen	dc.b		1		background colour
view_modes	dc.w		2		screen attributes, eg lo-res
screen_type	dc.w		15		custom or workbench
font		dc.l		0		topaz
title		dc.l		sname		pointer to screen titletext
gadgets		dc.l		0		pointer to gadgets list = non
bitmap		dc.l		0		special bitmap attributes
sname		dc.b		"Custom Intuition Screen",0	titletext
*****************************************************************************

		section		simons,data_c

image		dc.w		0,0		x/y-position
		dc.w		32,13		image size
		dc.w		1		bitplanes
		dc.l		imgdata		pointer to binary
		dc.b		2		drawing: red
		dc.b		1		background: white
		dc.l		0		no more images

imgdata		dc.l		%00000000000000000000000000000000
		dc.l		%00000000000000000000111000000000
		dc.l		%00011101110111000001111100000000
		dc.l		%00010101000100000001111100000000
		dc.l		%00010101100110000001111000000000
		dc.l		%00011101000100000011100000000000
		dc.l		%00000000000000000111000000000000
		dc.l		%00000000000000001110000000000000
		dc.l		%00000000000111111111100000000000
		dc.l		%00000000001111111111110000000000
		dc.l		%00000000001111111111110000000000
		dc.l		%00000000000110000001100000000000
		dc.l		%00000000000000000000000000000000

