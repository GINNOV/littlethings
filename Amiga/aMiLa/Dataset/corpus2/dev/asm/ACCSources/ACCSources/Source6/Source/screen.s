; Intuition structures --> open / close library

openlib	=	-408
closelib	=	-414
execbase	=	4
openscreen	=	-198
closescreen	=	-66

	bsr	openint	sub to open intuition.lib
	bsr	openscr	open our screen
wait
	btst	#6,$bfe001
	bne	wait
	bsr	closescr
	rts


openscr	move.l	intbase,a6	load adr of intuition
	lea	screen_defs,a0	adr of screen details
	jsr	openscreen(a6)	open the screen
	move.l	d0,screenhd	save screen handle
	rts
closescr	move.l	intbase,a6	load adr of intuition
	move.l	screenhd,a0	get screen handle
	jsr	closescreen(a6)	close it
	rts
openint	move.l	execbase,a6	get exec
	lea	intname,a1	name of library
	jsr	openlib(a6)	open intuition.bitch
	move.l	d0,intbase	save address
	rts
closeint	move.l	execbase,a6	get exec
	move.l	intbase,a1	get address of intuit
	jsr	closelib(a6)	close it
	rts

intname	dc.b	"intuition.library",0
intbase	dc.l	0
screenhd	dc.l	0

	even
screen_defs			; start of screen struct
xpos	dc.w	0	X-corner
ypos	dc.w	0	Y-corner
width	dc.w	320	width of screen
height	dc.w	256	height of screen
depth	dc.w	2	bitplanes (NOT colours)
detail_pen	dc.b	0	colour of titlebar
block_pen	dc.b	1	background colour
view_modes	dc.w	2	screen attributes, eg lo-res
screen_type	dc.w	15	custom or workbench
font	dc.l	0	topaz
title	dc.l	sname	pointer to screen titletext
gadgets	dc.l	0	ponter to gadgets list - non!
bitmap	dc.l	0	special bitmap attributes
sname	dc.b	"Custom Intuition Screen",0	titletext

