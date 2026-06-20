;APS000063820000638200006382000002B7000063820000638200006382000063820000638200006382
******************************************************************************
* Originally written by Holger 'Lynxx' Hippenstiel somewhere around 1994-95, *
* tuned a bit for speed & high-resolution compability in May 2023.           *
******************************************************************************

;Functions:
;ChunkyRectangle
;a0=ChunkyScreen, d0=x0, d1=y0, d2=x1, d3=y1, d4=Color, d5=pixelwidth, d6=pixelheight
;without clipping pixelheight is not needed
;
;ChunkyLine
;a0=ChunkyScreen, d0=x0, d1=y0, d2=x1, d3=y1, d4=Color, d5=pixelwidth, d6=pixelheight
;without clipping pixelheight is not needed

;Do clipping-check for lines
CLIPLINES SET 1

;a0=ChunkyScreen, d0=x0, d1=y0, d2=x1, d3=y1, d4=Color, d5=pixelwidth, d6=pixelheight
ChunkyRectangle:
	movem.l	d0-d7/a0-a6,-(a7)
	cmp	d0,d2
	bgt.b	.DontSwapX

	exg	d0,d2
.DontSwapX:
	cmp	d1,d3
	bgt.b	.DontSwapY

	exg	d1,d3
.DontSwapY:

	move.l	d1,d7
	move.l	d3,a6
	move.l	d2,a2
	
	move.l	d1,d3
	bsr.b	ChunkyLine	;Top Line

	move.l	a6,d1
	move.l	a6,d3
	bsr.b	ChunkyLine	;Bottom Line

	move.l	d7,d1
	move.l	a6,d3
	move.l	d0,d2
	bsr.b	ChunkyLine	;Left Line

	move.l	a2,d0
	move.l	a2,d2
	addq.l	#1,d3
	bsr.b	ChunkyLine	;Right Line

	movem.l	(a7)+,d0-d7/a0-a6
	rts

;a0=ChunkyScreen, d0=x0, d1=y0, d2=x1, d3=y1, d4=Color, d5=pixelwidth, d6=pixelheight
;without clipping pixelheight is not needed
	cnop	0,16

ChunkyLine:
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	d4,a1	;Color
	move.l	d5,a4	;pixelwidth

	IFNE	CLIPLINES
	bsr.w	ClipLine
	bne.b	.dontdraw
	ENDC

	cmp	d1,d3
	bne.b	.YNotEqual

	cmp	d0,d2
	beq.b	.dontdraw

.YNotEqual:
	move	d2,d4		;int dx =  abs(x1 - x0);
	sub	d0,d4
	beq.b	.VLine
	bpl.b	.abs1

	neg	d4
.abs1:	moveq	#1,d5		;int sx = x0 < x1 ? 1 : -1;
	cmp	d0,d2		;int sx = x0 < x1 ? 1 : -1;
	bgt.b	.sxpos

	moveq	#-1,d5
.sxpos:
	move	d3,d6		;int dy = -abs(y1 - y0);
	sub	d1,d6
	beq.w	.HLine
	bmi.b	.abs2

	neg	d6
.abs2:	move.l	a4,d7		;int sy = y0 < y1 ? 1 : -1; (pixelwidth)
	cmp	d1,d3		;int sy = y0 < y1 ? 1 : -1;
	bgt.b	.sypos

	neg.l	d7		;-pixelwidth
.sypos:	move.l	d5,a5		;a5 = sx
	move.l	d7,a6		;a6 = sy
	move	d2,a2		;a2 = x1
	move	d4,d2		;int err = dx [+ dy];

	move.l	a4,d5		;pixelwidth für setpixel
	mulu	d3,d5
	add.l	a0,d5
	move.l	d5,a3		;a3 = y1
	
	add	d6,d2		;+ dy;

	move.l	a4,d5		;pixelwidth für setpixel
	mulu	d1,d5		;für setpixel
	add.l	d5,a0

	move.l	a1,d7		;color

	move	d2,d3		;e2 = [2 *] err;
	bra.b	.PixelLoop

	cnop	0,16

.PixelLoop:
	add	d3,d3		;2 * err;
	move.b	d7,(a0,d0.w)	;setpixel
	cmp	d3,d6		;if (e2 > dy) {
	bgt.b	.e2dy

	add	d6,d2		;err += dy;
	add	a5,d0		;x0 += sx;
.e2dy:
	cmp	d3,d4		;if (e2 < dx) {
	blt.b	.e2dx

	add	d4,d2		;err += dx;
	add.l	a6,a0		;y0 += sy; (erspart mul)
.e2dx:
	move	d2,d3		;e2 = [2 *] err;
	cmp	d0,a2		;if (x0 == x1 && [y0 == y1]) break;
	bne.b	.PixelLoop

	cmp.l	a0,a3		;y0 == y1 ?
	bne.b	.PixelLoop

.dontdraw:
	movem.l	(a7)+,d0-d7/a0-a6
	rts

	cnop	2,4
	
.VLine:	cmp	d1,d3
	bgt.b	.DontSwapY

	exg	d1,d3
.DontSwapY:
	move	d3,d6
	move.l	a1,d7	;color
	sub	d1,d6
	move.l	a4,d5	;pixelwidth für setpixel
	subq	#1,d6
	mulu	d1,d5	;für setpixel
	add.l	d5,a0
	add	d0,a0

.VLineL:move.b	d7,(a0)
	add.l	a4,a0
	dbf	d6,.VLineL

	movem.l	(a7)+,d0-d7/a0-a6
	rts

	cnop	0,4
	
.HLine:	cmp	d0,d2
	bgt.b	.DontSwapX

	exg	d0,d2
.DontSwapX:
	move	d2,d4
	move.l	a1,d7	;color
	sub	d0,d4
	move.l	a4,d5	;pixelwidth für setpixel
	move	d7,d6
	lsl.l	#8,d7
	mulu	d1,d5	;für setpixel
	move.b	d6,d7
	add.l	d5,a0
	move	d7,d6
	swap	d7
	add	d0,a0
	move	d6,d7

	btst	#0,d0
	beq.b	.NotOdd

	subq	#1,d4
	bmi.b	.IllegalLine

	move.b	d7,(a0)+
.NotOdd:
	lsr	#1,d4
	beq.b	.NoWordRemain

	bcs.b	.DrawLongByteR

	lsr	#1,d4
	beq.b	.WordRemain

	bcs.b	.DrawLongWordR

	subq	#1,d4
.DrawLong1:
	move.l	d7,(a0)+
	dbf	d4,.DrawLong1

	bra.b	.IllegalLine

	cnop	2,4

.DrawLongWordR:
	subq	#1,d4
.DrawLong2:
	move.l	d7,(a0)+
	dbf	d4,.DrawLong2

.WordRemain:
	move	d7,(a0)
	bra.b	.IllegalLine

	cnop	0,4

.DrawLongByteR:
	lsr	#1,d4
	beq.b	.ThreeBytes

	bcs.b	.DrawLongThreeR

	subq	#1,d4
.DrawLong3:
	move.l	d7,(a0)+
	dbf	d4,.DrawLong3

.ByteRemain:
	move.b	d7,(a0)
	bra.b	.IllegalLine

.DrawLongThreeR:
	subq	#1,d4
.DrawLong4:
	move.l	d7,(a0)+
	dbf	d4,.DrawLong4

.ThreeBytes:
	move	d7,(a0)+
	move.b	d7,(a0)
	bra.b	.IllegalLine

.NoWordRemain:
	bcs.b	.ByteRemain

.IllegalLine:
	movem.l	(a7)+,d0-d7/a0-a6
	rts

	IFNE	CLIPLINES
	INCLUDE	"ClipLine.s"
	ENDC
