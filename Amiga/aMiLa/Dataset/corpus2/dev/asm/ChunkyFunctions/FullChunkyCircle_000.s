;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000
******************************************************************************
* Originally written by Holger 'Lynxx' Hippenstiel somewhere around 1994-95, *
* tuned a bit for speed & high-resolution compability in May 2023.           *
******************************************************************************

;Functions:
;FullChunkyCircle
;a0=ChunkyScreen, d0=X, d1=Y, d3=Size, d4=Color, d5=pixelwidth
FullChunkyCircle:
	movem.l	d0-d7/a0-a6,-(a7)
	move	d4,d2
	ext.l	d5
	add	d0,a0		;X
	move.l	d5,d4
	lea	CircleMultab+MAXHEIGHT*4(pc),a1
	lsl	#2,d1
	move	d3,d7
	move	d3,d5
	lsl	#2,d7
	lea	(a1,d1.w),a1
	move.l	a0,a3
	add.l	(a1,d7.w),a3
	move.l	a0,a4
	move	d5,d3
	moveq	#0,d0
	neg	d3
	add.l	(a1),a4
	move	d3,d7
	move.l	a0,a6
	lsl	#2,d7
	add.l	(a1,d7.w),a6
	moveq	#2,d1
	add.l	(a1),a0
	move	d3,d6
	sub	d5,d1
	moveq	#0,d7
	bra.b	.FullCircleOuter

	cnop	0,16

.FullCircleOuter:
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	add	d0,d1			;X inc
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	addq	#1,d6
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add.l	d4,a4
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	sub.l	d4,a0
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	addq	#1,d0
	addq	#1,d1
	bmi.b	.FullCircleOuter

.FullCircleLoop:
	cmp	d0,d5	
	ble.b	.FullCircleEnd

	subq	#1,d5
	addq	#2,d6
	move.b	d2,(a0,d5.w)		;2/8 X+,Y-
	addq	#1,d3
	move.b	d2,(a4,d5.w)		;3/8 X+,Y+
	sub.l	d4,a3
	move.b	d2,(a0,d3.w)		;7/8 X-,Y-
	add.l	d4,a6
	move.b	d2,(a4,d3.w)		;6/8 X-,Y+
	add.l	d4,a4
	move.b	d2,(a6,d0.w)		;1/8 X+,Y-
	sub.l	d4,a0
	move.b	d2,(a6,d7.w)		;8/8 X-,Y-
	move.b	d2,(a3,d7.w)		;5/8 X-,Y+
	subq	#1,d7
	move.b	d2,(a3,d0.w)		;4/8 X+,Y+
	addq	#1,d0
	add	d6,d1
	bpl.b	.FullCircleLoop

	bra.b	.FullCircleOuter

.FullCircleEnd:
	movem.l	(a7)+,d0-d7/a0-a6
	rts
	
	cnop	0,4

	INCLUDE	"ChunkyMultab.s"
