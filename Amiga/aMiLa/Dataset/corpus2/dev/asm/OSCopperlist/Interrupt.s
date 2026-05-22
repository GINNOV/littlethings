
	incdir  'includes:'
	include	'hardware/custom.i'
	include	'graphics/gfxbase.i'
	include	'lvo/exec_lib.i'

	xdef	_myCopperInt
	xdef	_loadCopperlist
	xdef	_initCopperlist

	xref	_GfxBase

; Inicjalizacja Copperlisty */
_initCopperlist

	lea	planes,a0
	move.l	#raster,d0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	rts

; Obsîuga przerwania
_myCopperInt:

	movea.l	4.w,a6
	movea.l	a1,a0
	movea.l	(a0)+,a1
	movea.l	(a0)+,d0
	jsr	_LVOSignal(a6)

	moveq	#0,d0
	rts

; Îadowanie wîasnej copperlisty
_loadCopperlist:

	movea.l	_GfxBase,a0
	move.l	#_myCopperlist,gb_LOFlist(a0)
	rts

	section	copperlist,data_c

; Wîasna copperlista
_myCopperlist:

	dc.w	bplcon0,	$1200
	dc.w	bplcon1,	$0000
	dc.w	bpl1mod,	$0000
	dc.w	ddfstrt,	$0038
	dc.w	ddfstop,	$00d0
	dc.w	diwstrt,	$2c81
	dc.w	diwstop,	$f4c1
	dc.w	color,		$0aaa
	dc.w	color+2,	$0fff
planes:
	dc.w	bplpt,		0
	dc.w	bplpt+2,	0
	dc.w	$ffff,		$fffe

; Raster
raster:
	dcb.l	2000,$ffff0000
