;APS00016A8100016A8100016A810001436800016A8100016A8100016A8100016A8100016A8100016A81
******************************************************************************
* Originally written by Holger 'Lynxx' Hippenstiel somewhere around 1994-95, *
* tuned a bit for speed & high-resolution compability in May 2023.           *
* Included special loops which for example only clip MinY & MinX, and if     *
* both are negative will only try to draw lower right quadrant.              *
* Total of draw-loops is 43 variants.                                        *
******************************************************************************

;Functions:
;ClippedChunkyCircle
;a0=ChunkyScreen, d0=X, d1=Y, d3=Size (max 3840), d4=Color, d5=pixelwidth, d6=pixelheight
ClippedChunkyCircle:
	movem.l	d0-d7/a0-a6,-(a7)
	move	d4,a6
	moveq	#0,d7
	move	d1,d2		;Y
	moveq	#0,d4		;Workvar for Functionoffset
	sub	d3,d2		;-Size
	bpl.b	.NoMinYClipping

	or	#1,d4		;MinY clipping needed
.NoMinYClipping:
	move	d1,d2		;Y
	move	d1,a4		;Y
	add	d3,d2		;+Size
	lea	.ClipCircleTab(pc),a1
	cmp	d6,d2		;<=pixelheight
	blt.b	.NoMaxYClipping

	or	#2,d4		;MaxY clipping needed
.NoMaxYClipping:
	move	d0,d2		;X
	move.l	d6,a5		;pixelheight
	sub	d3,d2		;-Size
	bpl.b	.NoMinXClipping

	or	#4,d4		;MinX clipping needed
.NoMinXClipping:
	move	d0,d2		;X
	add	d0,a0		;ChunkyScreen+X
	add	d3,d2		;+Size
	cmp	d5,d2		;<=pixelwidth
	blt.b	.NoMaxXClipping

	or	#8,d4		;MaxX clipping needed
.NoMaxXClipping:
	ext.l	d5
	move.l	d0,d2		;X
	tst	d0		;X<0?
	bpl.b	.NoXBelow0

	add	d3,d0		;+Size still negative?
	bmi.w	.CircleEnd	;Circle wont be visible
	or	#1,d7		;X<0
.NoXBelow0:
	cmp	d5,d0		;X>pixelwidth?
	ble.b	.NoXAbovePW

	sub	d5,d0		;-pixelwidth
	sub	d3,d0		;-size
	bpl.b	.CircleEnd	;Circle wont be visible
	
	or	#2,d7		;X>pixelwidth
.NoXAbovePW:
	tst	d1		;Y<0?
	bpl.b	.NoYBelow0

	add	d3,d1		;+size
	bmi.b	.CircleEnd	;Circle wont be visible

	sub	d3,d1
	or	#4,d7		;Y<0
.NoYBelow0:
	cmp	d6,d1		;Y>pixelheight?
	ble.b	.NoYAbovePH

	sub	d6,d1		;-pixelheight
	sub	d3,d1		;-size
	bpl.b	.CircleEnd	;Circle wont be visible
	
	or	#8,d7		;Y>pixelheight
.NoYAbovePH:
	add	d4,d4
	add	(a1,d4.w),a1	;Which Function to use
	move.l	d5,d4		;pixelwidth
	move.l	a1,-(a7)
	move	d3,d5		;Size
	lea	CircleMultab+MAXHEIGHT*4(pc),a1
	move	a6,-(a7)	;Color
	add.l	a5,a5
	add.l	a5,a5
	move.l	(a1,a5.w),a5	;MaxY for clipping is pixelheight
	move.l	a0,a3		;ChunkyScreen
	add.l	a0,a5		;+ChunkyScreen
	move.l	a0,a2		;MinY for clipping is 0 (ChunkyScreen)
	add.l	a4,a4
	add.l	a4,a4
	lea	(a1,a4.w),a1	;First Offset in Multab we need is Y
	move.l	a0,a6		;ChunkyScreen
	add.l	(a1),a0		;+Y*pixelwidth
	move	d5,d7
	lsl	#2,d7
	add.l	(a1,d7.w),a3	;+Size*pixelwidth
	move	d5,d3		;Size
	moveq	#0,d0		;LowX
	neg	d3
	move.l	a0,a4
	move	d3,d7
	lsl	#2,d7
	add.l	(a1,d7.w),a6	;+-Size*pixelwidth
	moveq	#2,d1		;Loopvar
	move	d3,d6		;-Size
	move.l	d4,a1		;pixelwidth
	sub	d2,d4		;MaxX is pixelwidth-X
	swap	d6		;in upper 16 bits
	neg	d2		;-X
	move	d2,d6		;MinX is -X
	sub	d5,d1		;-Size
	swap	d6
	move	(a7)+,d2	;Color
	rts

.CircleEnd:
	movem.l	(a7)+,d0-d7/a0-a6
	rts

.ClipCircleTab:
	dc.w	.CircleInit_0-.ClipCircleTab	;No Clipping
	dc.w	.CircleInit_1-.ClipCircleTab	;Clipping MinY
	dc.w	.CircleInit_2-.ClipCircleTab	;Clipping MaxY
	dc.w	.CircleInit_3-.ClipCircleTab	;Clipping MinY & MaxY
	dc.w	.CircleInit_4-.ClipCircleTab	;Clipping MinX
	dc.w	.CircleInit_5-.ClipCircleTab	;Clipping MinY & MinX
	dc.w	.CircleInit_6-.ClipCircleTab	;Clipping MaxY & MinX
	dc.w	.CircleInit_7-.ClipCircleTab	;Clipping MinY & MaxY & MinX
	dc.w	.CircleInit_8-.ClipCircleTab	;Clipping MaxX
	dc.w	.CircleInit_9-.ClipCircleTab	;Clipping MinY & MaxX
	dc.w	.CircleInit_A-.ClipCircleTab	;Clipping MaxY & MaxX
	dc.w	.CircleInit_B-.ClipCircleTab	;Clipping MinY & MaxY & MaxX
	dc.w	.CircleInit_C-.ClipCircleTab	;Clipping MinX & MaxX
	dc.w	.CircleInit_D-.ClipCircleTab	;Clipping MinY & MinX & MaxX
	dc.w	.CircleInit_E-.ClipCircleTab	;Clipping MaxY & MinX & MaxX 
	dc.w	.CircleInit_F-.ClipCircleTab	;Full Clipping

	cnop	0,16

;No Clipping
.CircleInit_0:
	moveq	#0,d7
	bra.b	.CircleOuter_0	;full circle needed
	
	cnop	0,16

;full circle needed
.CircleOuter_0:
	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	addq	#1,d6
	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
	sub.l	a1,a0		;-pixelwidth
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
	add	d0,d1		;X inc
	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	add.l	a1,a4		;+pixelwidth
	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
	subq	#1,d7
	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_0

.CircleLoop_0:
	cmp	d0,d5	
	ble.b	.CircleEnd_0

	subq	#1,d5
	addq	#1,d3
	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	sub.l	a1,a3		;-pixelwidth
	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
	addq	#2,d6
	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
	add.l	a1,a6		;+pixelwidth
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
	add.l	a1,a4		;+pixelwidth
	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	sub.l	a1,a0		;-pixelwidth
	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
	subq	#1,d7
	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_0

	bra.b	.CircleOuter_0

.CircleEnd_0:
	bra.w	.CircleEnd

	cnop	0,16

;Clipping MinY
.CircleInit_1:
	subq	#4,d7			;Y<0?
	beq.b	.CircleOuter_1Y		;only lower half needed
	
	moveq	#0,d7
	bra.b	.CircleOuter_1		;full circle needed
	
	cnop	0,16
;only lower half needed
.CircleOuter_1Y:
	addq	#1,d6
	add	d0,d1		;X inc
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipA41_1Y

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipA41_1Y:
	add.l	a1,a4		;+pixelwidth
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_1Y

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_1Y:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_1Y

.CircleLoop_1Y:
	cmp	d0,d5	
	ble.b	.CircleEnd_1Y

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	sub.l	a1,a3		;-pixelwidth
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipA42_1Y

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipA42_1Y:
	add.l	a1,a4		;+pixelwidth
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_1Y

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA32_1Y:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_1Y

	bra.b	.CircleOuter_1Y

.CircleEnd_1Y:
	bra.w	.CircleEnd

	cnop	0,16

;full circle needed
.CircleOuter_1:
	addq	#1,d6
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA01_1

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_1:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipA41_1

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipA41_1:
	add.l	a1,a4		;+pixelwidth
	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA61_1

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_1:
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_1

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_1:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_1

.CircleLoop_1:
	cmp	d0,d5	
	ble.b	.CircleEnd_1

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA02_1

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
	sub.l	a1,a0		;-pixelwidth
.SkipA02_1:
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipA42_1

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipA42_1:
	add.l	a1,a4		;+pixelwidth
	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA62_1

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_1:
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_1

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_1:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_1

	bra.w	.CircleOuter_1

.CircleEnd_1:
	bra.w	.CircleEnd

	cnop	0,16

;Clipping MaxY
.CircleInit_2:
	subq	#8,d7		;Y>pixelheight?
	beq.b	.CircleOuter_2Y ;only upper half is needed

	moveq	#0,d7
	bra.b	.CircleOuter_2	;full circle needed

	cnop	0,16

;only upper half is needed
.CircleOuter_2Y:
	addq	#1,d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_2Y
	
	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_2Y:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_2Y

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_2Y:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_2Y

.CircleLoop_2Y:
	cmp	d0,d5	
	ble.b	.CircleEnd_2Y

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_2Y

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_2Y:
	add.l	a1,a6		;+pixelwidth
	sub.l	a1,a0		;-pixelwidth
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_2Y

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_2Y:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_2Y

	bra.b	.CircleOuter_2Y

.CircleEnd_2Y:
	bra.w	.CircleEnd

	cnop	0,16

;full circle needed
.CircleOuter_2:
	addq	#1,d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_2
	
	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_2:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA41_2

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
	add.l	a1,a4		;+pixelwidth
.SkipA41_2:	
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_2

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_2:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_2

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_2:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_2

.CircleLoop_2:
	cmp	d0,d5	
	ble.b	.CircleEnd_2

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_2

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_2:
	sub.l	a1,a0		;-pixelwidth
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA42_2

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
	add.l	a1,a4		;+pixelwidth
.SkipA42_2:
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_2

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_2:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA32_2

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_2:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_2

	bra.w	.CircleOuter_2

.CircleEnd_2:
	bra.w	.CircleEnd

	cnop	0,16

;Clipping MinY & MaxY
.CircleInit_3:
	moveq	#0,d7
	bra.b	.CircleOuter_3	;full circle needed
	
	cnop	0,16

;full circle needed
.CircleOuter_3:
	addq	#1,d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_3
	
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA11_3
	
	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_3:
	sub.l	a1,a0		;-pixelwidth
.SkipA11_3:
	add	d0,d1		;X inc
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA41_3

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD31_3

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_3:
	add.l	a1,a4		;+pixelwidth
.SkipA41_3:	
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_3

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA61_3

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_3:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_3

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_3

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_3:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_3

.CircleLoop_3:
	cmp	d0,d5	
	ble.b	.CircleEnd_3

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_3

	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA22_3

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_3:
	sub.l	a1,a0		;-pixelwidth
.SkipA22_3:
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA42_3

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_3

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_3:
	add.l	a1,a4		;+pixelwidth
.SkipA42_3:
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_3

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA62_3

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_3:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA32_3

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_3

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_3:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_3

	bra.w	.CircleOuter_3

.CircleEnd_3:
	bra.w	.CircleEnd

	cnop	0,16

;Clipping MinX
.CircleInit_4:
	move.l	d6,d4
	swap	d4
	subq	#1,d7		;X<0?
	beq.b	.CircleOuter_4X	;only right half is needed

	moveq	#0,d7
	bra.b	.CircleOuter_4	;full circle needed

	cnop	0,16	

;only right half is needed
.CircleOuter_4X:
	addq	#1,d6
	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD51_4X

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD51_4X:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	add.l	a1,a4		;+pixelwidth
	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD01_4X

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD01_4X:
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_4X

.CircleLoop_4X:
	cmp	d0,d5	
	ble.b	.CircleEnd_4X

	addq	#2,d6
	subq	#1,d5
	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD53_4X

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD53_4X:
	sub.l	a1,a0		;-pixelwidth
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	add.l	a1,a4		;+pixelwidth
	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD02_4X

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD02_4X:
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_4X

	bra.b	.CircleOuter_4X

.CircleEnd_4X:
	bra.w	.CircleEnd

	cnop	0,16

;full circle needed
.CircleOuter_4:
	addq	#1,d6
	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD51_4

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD51_4:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipA01_4

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipA01_4:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	add.l	a1,a4		;+pixelwidth
	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD01_4

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD01_4:
	cmp	d4,d7		;Clip MinX
	blt.b	.SkipD71_4

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_4:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_4

.CircleLoop_4:
	cmp	d0,d5	
	ble.b	.CircleEnd_4

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD53_4

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD53_4:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipA02_4

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipA02_4:
	sub.l	a1,a0		;-pixelwidth
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	add.l	a1,a4		;+pixelwidth
	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD02_4

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD02_4:
	cmp	d4,d7		;Clip MinX
	blt.b	.SkipA62_4

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA62_4:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_4

	bra.w	.CircleOuter_4

.CircleEnd_4:
	bra.w	.CircleEnd

	cnop	0,16

;Clipping MinY & MinX
.CircleInit_5:
	move.l	d6,d4
	swap	d4

	subq	#4+1,d7		;X<0 & Y<0?
	beq.b	.CircleOuter_5XY;only lower right quadrant needed

	addq	#4,d7		;X<0?
	beq.b	.CircleOuter_5X	;only right half is needed

	subq	#3,d7		;Y<0?
	beq.w	.CircleOuter_5Y ;only lower half is needed

	moveq	#0,d7
	bra.w	.CircleOuter_5	;full circle needed

	cnop	0,16

;only lower right quadrant needed
.CircleOuter_5XY:
	addq	#1,d6
	add	d0,d1		;X inc
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD52_5XY

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD52_5XY

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_5XY:
	add.l	a1,a4		;+pixelwidth
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_5XY

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipA31_5XY

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_5XY:
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_5XY

.CircleLoop_5XY:
	cmp	d0,d5	
	ble.b	.CircleEnd_5XY

	addq	#2,d6
	subq	#1,d5
	sub.l	a1,a3		;-pixelwidth
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_5XY

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD32_5XY

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD32_5XY:
	add.l	a1,a4		;+pixelwidth
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_5XY

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipA32_5XY

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA32_5XY:
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_5XY

	bra.b	.CircleOuter_5XY

.CircleEnd_5XY:
	bra.w	.CircleEnd

	cnop	0,16

;only right half is needed
.CircleOuter_5X:
	addq	#1,d6
	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD52_5X

	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA11_5X
	
	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipA11_5X:
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD52_5X

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_5X:
	add	d0,d1		;X inc
	sub.l	a1,a0		;-pixelwidth
	add.l	a1,a4		;+pixelwidth
	cmp	d4,d0		;Clip MinX
	blt.b	.SkipA31_5X

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipD01_5X

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD01_5X:
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_5X

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_5X:
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_5X

.CircleLoop_5X:
	cmp	d0,d5	
	ble.b	.CircleEnd_5X

	addq	#2,d6
	subq	#1,d5
	add.l	a1,a6		;+pixelwidth
	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD54_5X

	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA22_5X

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipA22_5X:
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD54_5X

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD54_5X:
	add.l	a1,a4		;+pixelwidth
	sub.l	a1,a0		;-pixelwidth
	sub.l	a1,a3		;-pixelwidth
	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD03_5X

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipD02_5X

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD02_5X:
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipD03_5X

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD03_5X:
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_5X

	bra.b	.CircleOuter_5X

.CircleEnd_5X:
	bra.w	.CircleEnd

	cnop	0,16

;only lower half is needed
.CircleOuter_5Y:
	addq	#1,d6
	add	d0,d1		;X inc
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD31_5Y

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD52_5Y

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_5Y:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipD31_5Y

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_5Y:
	add.l	a1,a4		;+pixelwidth
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_5Y

	cmp	d4,d7		;Clip MinX
	blt.b	.SkipD71_5Y

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_5Y:
	cmp	d4,d0		;Clip MinX
	blt.b	.SkipA31_5Y

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_5Y:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_5Y

.CircleLoop_5Y:
	cmp	d0,d5	
	ble.b	.CircleEnd_5Y

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	sub.l	a1,a3		;-pixelwidth
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_5Y

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD54_5Y

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD54_5Y:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipD32_5Y

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_5Y:
	add.l	a1,a4		;+pixelwidth
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_5Y

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD03_5Y

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD03_5Y:
	cmp	d4,d7		;Clip MinX
	blt.b	.SkipA32_5Y
	
	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_5Y:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_5Y

	bra.b	.CircleOuter_5Y

.CircleEnd_5Y:
	bra.w	.CircleEnd

	cnop	0,16

;full circle needed
.CircleOuter_5:
	addq	#1,d6
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA11_5
	
	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD51_5

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD51_5:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipA01_5

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_5:
	sub.l	a1,a0		;-pixelwidth
.SkipA11_5:
	add	d0,d1		;X inc
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD31_5

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD52_5

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_5:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipD31_5

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_5:
	add.l	a1,a4		;+pixelwidth
.SkipA41_5:
	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA61_5

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD01_5

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD01_5:
	cmp	d4,d7		;Clip MinX
	blt.b	.SkipD71_5

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_5:
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_5

	cmp	d4,d7		;Clip MinX
	blt.b	.SkipD71_5

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_5:
	cmp	d4,d0		;Clip MinX
	blt.b	.SkipA31_5

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_5:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_5

.CircleLoop_5:
	cmp	d0,d5	
	ble.b	.CircleEnd_5

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA22_5

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD53_5

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD53_5:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipA02_5

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_5:
	sub.l	a1,a0		;-pixelwidth
.SkipA22_5:
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_5

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD54_5

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD54_5:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipD32_5

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_5:
	add.l	a1,a4		;+pixelwidth
.SkipA42_5:
	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA62_5

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD02_5

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD02_5:
	cmp	d4,d7		;Clip MinX
	blt.b	.SkipA62_5

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_5:
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_5

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD03_5

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD03_5:
	cmp	d4,d7		;Clip MinX
	blt.b	.SkipA32_5
	
	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_5:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_5

	bra.w	.CircleOuter_5

.CircleEnd_5:
	bra.w	.CircleEnd

	cnop	0,16

;Clipping MaxY & MinX
.CircleInit_6:
	move.l	d6,d4
	swap	d4
	
	subq	#8,d7		;Y>pixelheight?
	beq.b	.CircleOuter_6Y ;only upper half needed

	subq	#1,d7		;Y>pixelheight & X<0?
	beq.b	.CircleOuter_6XY;only right upper quadrant needed

	addq	#8,d7		;X<0?
	beq.w	.CircleOuter_6X ;only right half needed

	moveq	#0,d7
	bra.w	.CircleOuter_6	;full circle needed

	cnop	0,16

;only right upper quadrant needed
.CircleOuter_6XY:
	addq	#1,d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipD51_6XY

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD51_6XY

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD51_6XY:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipD01_6XY

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD01_6XY

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD01_6XY:
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_6XY

.CircleLoop_6XY:
	cmp	d0,d5	
	ble.b	.CircleEnd_6XY

	addq	#2,d6
	subq	#1,d5
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipD53_6XY

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD53_6XY

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD53_6XY:
	add.l	a1,a6		;+pixelwidth
	sub.l	a1,a0		;-pixelwidth
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipD02_6XY

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD02_6XY

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD02_6XY:
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_6XY

	bra.b	.CircleOuter_6XY

.CircleEnd_6XY:
	bra.w	.CircleEnd

	cnop	0,16

;only upper half needed
.CircleOuter_6Y:
	addq	#1,d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_6Y
	
	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD51_6Y

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD51_6Y:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipA01_6Y

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_6Y:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_6Y

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD01_6Y

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD01_6Y:
	cmp	d4,d7		;Clip MinX
	blt.b	.SkipA61_6Y

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_6Y:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_6Y

.CircleLoop_6Y:
	cmp	d0,d5	
	ble.b	.CircleEnd_6Y

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_6Y

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD53_6Y

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD53_6Y:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipA02_6Y

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_6Y:
	add.l	a1,a6		;+pixelwidth
	sub.l	a1,a0		;-pixelwidth
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_6Y

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD02_6Y

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD02_6Y:
	cmp	d4,d7		;Clip MinX
	blt.b	.SkipA62_6Y

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_6Y:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_6Y

	bra.b	.CircleOuter_6Y

.CircleEnd_6Y:
	bra.w	.CircleEnd

	cnop	0,16

;only right half needed
.CircleOuter_6X:
	addq	#1,d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipD51_6X
	
	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD51_6X

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD51_6X:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA41_6X

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD52_6X

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_6X:
	add.l	a1,a4		;+pixelwidth
.SkipA41_6X:	
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipD01_6X

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD01_6X

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD01_6X:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_6X

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipA31_6X

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_6X:
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_6X

.CircleLoop_6X:
	cmp	d0,d5	
	ble.b	.CircleEnd_6X

	addq	#2,d6
	subq	#1,d5
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipD53_6X

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD53_6X

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD53_6X:
	sub.l	a1,a0		;-pixelwidth
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA42_6X

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD54_6X

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD54_6X:
	add.l	a1,a4		;+pixelwidth
.SkipA42_6X:
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipD02_6X

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD02_6X

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD02_6X:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipD03_6X

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD03_6X

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD03_6X:
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_6X

	bra.w	.CircleOuter_6X

.CircleEnd_6X:
	bra.w	.CircleEnd

	cnop	0,16

;full circle needed
.CircleOuter_6:
	addq	#1,d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_6
	
	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD51_6

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD51_6:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipA01_6

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_6:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA41_6

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD52_6

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_6:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipD31_6

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_6:
	add.l	a1,a4		;+pixelwidth
.SkipA41_6:	
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_6

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD01_6

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD01_6:
	cmp	d4,d7		;Clip MinX
	blt.b	.SkipD71_6

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_6:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_6

	cmp	d4,d7		;Clip MinX
	blt.b	.SkipD71_6

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_6:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_6

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipA31_6

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_6:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_6

.CircleLoop_6:
	cmp	d0,d5	
	ble.b	.CircleEnd_6

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_6

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD53_6

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD53_6:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipA02_6

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_6:
	sub.l	a1,a0		;-pixelwidth
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA42_6

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD54_6

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD54_6:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipD32_6

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_6:
	add.l	a1,a4		;+pixelwidth
.SkipA42_6:
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_6

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD02_6

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD02_6:
	cmp	d4,d7		;Clip MinX
	blt.b	.SkipA62_6

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_6:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA32_6

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD03_6

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD03_6:
	cmp	d4,d7		;Clip MinX
	blt.b	.SkipA32_6
	
	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_6:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_6

	bra.w	.CircleOuter_6

.CircleEnd_6:
	bra.w	.CircleEnd

	cnop	0,16

;Clipping MinY & MaxY & MinX
.CircleInit_7:
	move.l	d6,d4
	swap	d4

	subq	#1,d7		;X<0?
	beq.b	.CircleOuter_7X ;only right half needed

	moveq	#0,d7
	bra.w	.CircleOuter_7	;full circle needed
	
	cnop	0,16

;only right half needed
.CircleOuter_7X:
	addq	#1,d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipD51_7X
	
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA11_7X
	
	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD51_7X

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD51_7X:
	sub.l	a1,a0		;-pixelwidth
.SkipA11_7X:
	add	d0,d1		;X inc
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA41_7X

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD52_7X

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD52_7X

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_7X:
	add.l	a1,a4		;+pixelwidth
.SkipA41_7X:	
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_7X

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA61_7X

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipA61_7X

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipA61_7X:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_7X

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_7X

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipA31_7X

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_7X:
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_7X

.CircleLoop_7X:
	cmp	d0,d5	
	ble.b	.CircleEnd_7X

	addq	#2,d6
	subq	#1,d5
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_7X

	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA22_7X

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipA02_7X

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipA02_7X:
	sub.l	a1,a0		;-pixelwidth
.SkipA22_7X:
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA42_7X

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_7X

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD32_7X

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD32_7X:
	add.l	a1,a4		;+pixelwidth
.SkipA42_7X:
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_7X

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA62_7X

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipA62_7X

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipA62_7X:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA32_7X

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_7X

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipA32_7X

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA32_7X:
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_7X

	bra.w	.CircleOuter_7X

.CircleEnd_7X:
	bra.w	.CircleEnd

	cnop	0,16

;full circle needed
.CircleOuter_7:
	addq	#1,d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_7
	
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA11_7
	
	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD51_7

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD51_7:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipA01_7

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_7:
	sub.l	a1,a0		;-pixelwidth
.SkipA11_7:
	add	d0,d1		;X inc
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA41_7

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD31_7

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD52_7

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_7:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipD31_7

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_7:
	add.l	a1,a4		;+pixelwidth
.SkipA41_7:	
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_7

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA61_7

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD01_7

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD01_7:
	cmp	d4,d7		;Clip MinX
	blt.b	.SkipD71_7

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_7:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_7

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_7

	cmp	d4,d7		;Clip MinX
	blt.b	.SkipD71_7

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_7:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_7

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_7

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipA31_7

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_7:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_7

.CircleLoop_7:
	cmp	d0,d5	
	ble.b	.CircleEnd_7

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_7

	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA22_7

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD53_7

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD53_7:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipA02_7

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_7:
	sub.l	a1,a0		;-pixelwidth
.SkipA22_7:
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA42_7

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_7

	cmp	d4,d5		;Clip MinX
	blt.b	.SkipD54_7

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD54_7:
	cmp	d4,d3		;Clip MinX
	blt.b	.SkipD32_7

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_7:
	add.l	a1,a4		;+pixelwidth
.SkipA42_7:
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_7

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA62_7

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD02_7

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD02_7:
	cmp	d4,d7		;Clip MinX
	blt.b	.SkipA62_7

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_7:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA32_7

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_7

	cmp	d4,d0		;Clip MinX
	blt.b	.SkipD03_7

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD03_7:
	cmp	d4,d7		;Clip MinX
	blt.b	.SkipA32_7
	
	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_7:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_7

	bra.w	.CircleOuter_7

.CircleEnd_7:
	bra.w	.CircleEnd

	cnop	0,16

;Clipping MaxX
.CircleInit_8:
	subq	#2,d7		;X>pixelwidth?
	beq.b	.CircleOuter_8X	;only left half needed

	moveq	#0,d7
	bra.b	.CircleOuter_8	;full circle needed
	
	cnop	0,16

;only left half needed
.CircleOuter_8X:
	addq	#1,d6
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA01_8X

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipA01_8X:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	add.l	a1,a4		;+pixelwidth
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_8X

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_8X:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_8X

.CircleLoop_8X:
	cmp	d0,d5	
	ble.b	.CircleEnd_8X

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA02_8X

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipA02_8X:
	sub.l	a1,a0		;-pixelwidth
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	add.l	a1,a4		;+pixelwidth
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA62_8X

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA62_8X:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_8X

	bra.b	.CircleOuter_8X

.CircleEnd_8X:
	bra.w	.CircleEnd

	cnop	0,16

;full circle needed
.CircleOuter_8:
	addq	#1,d6
	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD51_8

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD51_8:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA01_8

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipA01_8:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	add.l	a1,a4		;+pixelwidth
	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD01_8

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD01_8:
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_8

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_8:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_8

.CircleLoop_8:
	cmp	d0,d5	
	ble.b	.CircleEnd_8

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD53_8

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD53_8:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA02_8

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipA02_8:
	sub.l	a1,a0		;-pixelwidth
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	add.l	a1,a4		;+pixelwidth
	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD02_8

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD02_8:
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA62_8

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA62_8:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_8

	bra.w	.CircleOuter_8

.CircleEnd_8:
	bra.w	.CircleEnd

	cnop	0,16

;Clipping MinY & MaxX
.CircleInit_9:
	subq	#4,d7		;Y<0?
	beq.b	.CircleOuter_9Y	;only lower half needed

	subq	#2,d7		;Y<0 & X>pixelwidth?
	beq.b	.CircleOuter_9XY;only left lower quadrant needed

	addq	#4,d7		;X>pixelwidth?
	beq.w	.CircleOuter_9X ;only left half needed

	moveq	#0,d7
	bra.w	.CircleOuter_9	;full circle needed
	
	cnop	0,16

;only left lower quadrant needed
.CircleOuter_9XY:
	addq	#1,d6
	add	d0,d1		;X inc
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD31_9XY

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD31_9XY

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_9XY:
	add.l	a1,a4		;+pixelwidth
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_9XY

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA31_9XY

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA31_9XY:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_9XY

.CircleLoop_9XY:
	cmp	d0,d5	
	ble.b	.CircleEnd_9XY

	addq	#2,d6
	addq	#1,d3
	subq	#1,d5
	sub.l	a1,a3		;-pixelwidth
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_9XY

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD32_9XY

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_9XY:
	add.l	a1,a4		;+pixelwidth
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_9XY

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA32_9XY

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_9XY:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_9XY

	bra.b	.CircleOuter_9XY

.CircleEnd_9XY:
	bra.w	.CircleEnd

	cnop	0,16

;only lower half needed
.CircleOuter_9Y:
	addq	#1,d6
	add	d0,d1		;X inc
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD31_9Y

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD52_9Y

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_9Y:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD31_9Y

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_9Y:
	add.l	a1,a4		;+pixelwidth
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_9Y

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_9Y

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_9Y:
	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipA31_9Y

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_9Y:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_9Y

.CircleLoop_9Y:
	cmp	d0,d5	
	ble.b	.CircleEnd_9Y

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	sub.l	a1,a3		;-pixelwidth
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_9Y

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD54_9Y

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD54_9Y:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD32_9Y

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_9Y:
	add.l	a1,a4		;+pixelwidth
.SkipA42_9Y:
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_9Y

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD03_9Y

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD03_9Y:
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA32_9Y

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_9Y:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_9Y

	bra.b	.CircleOuter_9Y

.CircleEnd_9Y:
	bra.w	.CircleEnd

	cnop	0,16

;only left half needed
.CircleOuter_9X:
	addq	#1,d6
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA11_9X
	
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA01_9X

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_9X:
	sub.l	a1,a0		;-pixelwidth
.SkipA11_9X:
	add	d0,d1		;X inc
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD31_9X

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD31_9X

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_9X:
	add.l	a1,a4		;+pixelwidth
	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA61_9X

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA31_9X

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_9X:
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_9X

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA31_9X

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA31_9X:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_9X

.CircleLoop_9X:
	cmp	d0,d5	
	ble.b	.CircleEnd_9X

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA22_9X

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA02_9X

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_9X:
	sub.l	a1,a0		;-pixelwidth
.SkipA22_9X:
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_9X

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD32_9X

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_9X:
	add.l	a1,a4		;+pixelwidth
	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA62_9X

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA62_9X

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_9X:
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_9X

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA32_9X

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_9X:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_9X

	bra.w	.CircleOuter_9X

.CircleEnd_9X:
	bra.w	.CircleEnd

	cnop	0,16

;full circle needed
.CircleOuter_9:
	addq	#1,d6
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA11_9
	
	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD51_9

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD51_9:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA01_9

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_9:
	sub.l	a1,a0		;-pixelwidth
.SkipA11_9:
	add	d0,d1		;X inc
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD31_9

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD52_9

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_9:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD31_9

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_9:
	add.l	a1,a4		;+pixelwidth
.SkipA41_9:
	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA61_9

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD01_9

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD01_9:
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_9

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_9:
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_9

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_9

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_9:
	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipA31_9

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_9:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_9

.CircleLoop_9:
	cmp	d0,d5	
	ble.b	.CircleEnd_9

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA22_9

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD53_9

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD53_9:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA02_9

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_9:
	sub.l	a1,a0		;-pixelwidth
.SkipA22_9:
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_9

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD54_9

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD54_9:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD32_9

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_9:
	add.l	a1,a4		;+pixelwidth
.SkipA42_9:
	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA62_9

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD02_9

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD02_9:
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA62_9

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_9:
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_9

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD03_9

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD03_9:
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA32_9

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_9:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_9

	bra.w	.CircleOuter_9

.CircleEnd_9:
	bra.w	.CircleEnd
	cnop	0,16

;Clipping MaxY & MaxX
.CircleInit_A:
	subq	#8,d7		;Y>pixelheight?
	beq.b	.CircleOuter_AY ;only upper half needed

	subq	#2,d7		;Y>pixelheight & X>pixelwidth?
	beq.b	.CircleOuter_AXY;only left upper quadrant needed

	addq	#8,d7		;X>pixelwidth?
	beq.w	.CircleOuter_AX ;only left half needed
	
	moveq	#0,d7
	bra.w	.CircleOuter_A	;full circle needed
	
	cnop	0,16

;only left upper quadrant needed
.CircleOuter_AXY:
	addq	#1,d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_AXY
	
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA01_AXY

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_AXY:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_AXY

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA61_AXY

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_AXY:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_AXY

.CircleLoop_AXY:
	cmp	d0,d5	
	ble.b	.CircleEnd_AXY

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_AXY

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA02_AXY

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_AXY:
	add.l	a1,a6		;+pixelwidth
	sub.l	a1,a0		;-pixelwidth
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_AXY

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA62_AXY

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_AXY:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_AXY

	bra.b	.CircleOuter_AXY

.CircleEnd_AXY:
	bra.w	.CircleEnd

	cnop	0,16

;only upper half needed
.CircleOuter_AY:
	addq	#1,d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_AY

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD51_AY

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD51_AY:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA01_AY

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_AY:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_AY

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD01_AY

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD01_AY:
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA61_AY

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_AY:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_AY

.CircleLoop_AY:
	cmp	d0,d5	
	ble.b	.CircleEnd_AY

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_AY

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD53_AY

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD53_AY:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA02_AY

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_AY:
	add.l	a1,a6		;+pixelwidth
	sub.l	a1,a0		;-pixelwidth
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_AY

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD02_AY

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD02_AY:
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA62_AY

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_AY:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_AY

	bra.b	.CircleOuter_AY

.CircleEnd_AY:
	bra.w	.CircleEnd

	cnop	0,16

;only left half needed
.CircleOuter_AX:
	addq	#1,d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_AX
	
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA01_AX

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_AX:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA41_AX

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD31_AX

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_AX:
	add.l	a1,a4		;+pixelwidth
.SkipA41_AX:	
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_AX

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA61_AX

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_AX:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_AX

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA31_AX

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA31_AX:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_AX

.CircleLoop_AX:
	cmp	d0,d5	
	ble.b	.CircleEnd_AX

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_AX

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA02_AX

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_AX:
	sub.l	a1,a0		;-pixelwidth
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA42_AX

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD32_AX

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_AX:
	add.l	a1,a4		;+pixelwidth
.SkipA42_AX:
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_AX

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA62_AX

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_AX:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA32_AX

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA32_AX

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_AX:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_AX

	bra.w	.CircleOuter_AX

.CircleEnd_AX:
	bra.w	.CircleEnd

	cnop	0,16

;full circle needed
.CircleOuter_A:
	addq	#1,d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_A
	
	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD51_A

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD51_A:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA01_A

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_A:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA41_A

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD52_A

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_A:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD31_A

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_A:
	add.l	a1,a4		;+pixelwidth
.SkipA41_A:	
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_A

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD01_A

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD01_A:
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_A

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_A:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_A

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_A

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_A:
	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipA31_A

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_A:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_A

.CircleLoop_A:
	cmp	d0,d5	
	ble.b	.CircleEnd_A

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_A

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD53_A

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD53_A:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA02_A

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_A:
	sub.l	a1,a0		;-pixelwidth
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA42_A

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD54_A

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD54_A:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD32_A

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_A:
	add.l	a1,a4		;+pixelwidth
.SkipA42_A:
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_A

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD02_A

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD02_A:
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA62_A

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_A:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA32_A

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD03_A

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD03_A:
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA32_A

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_A:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_A

	bra.w	.CircleOuter_A

.CircleEnd_A:
	bra.w	.CircleEnd

	cnop	0,16

;Clipping MinY & MaxY & MaxX
.CircleInit_B:
	subq	#2,d7		;X>pixelwidth?
	beq.b	.CircleOuter_BX ;only left half needed

	moveq	#0,d7
	bra.w	.CircleOuter_B	;full circle needed
	
	cnop	0,16

;only left half needed
.CircleOuter_BX:
	addq	#1,d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_BX
	
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA11_BX
	
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA01_BX

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_BX:
	sub.l	a1,a0		;-pixelwidth
.SkipA11_BX:
	add	d0,d1		;X inc
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA41_BX

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD31_BX

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD31_BX

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_BX:
	add.l	a1,a4		;+pixelwidth
.SkipA41_BX:
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_BX

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA61_BX

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA31_BX

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_BX:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_BX

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_BX

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA31_BX

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA31_BX:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_BX

.CircleLoop_BX:
	cmp	d0,d5	
	ble.b	.CircleEnd_BX

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_BX

	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA22_BX

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA02_BX

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_BX:
	sub.l	a1,a0		;-pixelwidth
.SkipA22_BX:
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA42_BX

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_BX

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD32_BX

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_BX:
	add.l	a1,a4		;+pixelwidth
.SkipA42_BX:
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_BX

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA62_BX

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA62_BX

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_BX:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA32_BX

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_BX

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA32_BX

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_BX:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_BX

	bra.w	.CircleOuter_BX

.CircleEnd_BX:
	bra.w	.CircleEnd

	cnop	0,16

;full circle needed
.CircleOuter_B:
	addq	#1,d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_B
	
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA11_B
	
	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD51_B

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD51_B:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA01_B

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_B:
	sub.l	a1,a0		;-pixelwidth
.SkipA11_B:
	add	d0,d1		;X inc
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA41_B

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD31_B

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD52_B

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_B:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD31_B

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_B:
	add.l	a1,a4		;+pixelwidth
.SkipA41_B:
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_B

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA61_B

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD01_B

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD01_B:
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_B

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_B:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_B

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_B

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_B

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_B:
	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipA31_B

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_B:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_B

.CircleLoop_B:
	cmp	d0,d5	
	ble.b	.CircleEnd_B

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_B

	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA22_B

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD53_B

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD53_B:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA02_B

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_B:
	sub.l	a1,a0		;-pixelwidth
.SkipA22_B:
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA42_B

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_B

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD54_B

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD54_B:
	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD32_B

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_B:
	add.l	a1,a4		;+pixelwidth
.SkipA42_B:
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_B

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA62_B

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD02_B

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD02_B:
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA62_B

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_B:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA32_B

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_B

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD03_B

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD03_B:
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA32_B

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_B:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_B

	bra.w	.CircleOuter_B

.CircleEnd_B:
	bra.w	.CircleEnd

	cnop	0,16

;Clipping MinX & MaxX
.CircleInit_C:
	move.l	d6,d7
	swap	d7
	move.l	d7,a2
	
	moveq	#0,d7
	bra.b	.CircleOuter_C	;full circle needed
	
	cnop	0,16

;full circle needed
.CircleOuter_C:
	addq	#1,d6
	cmp	a2,d5		;Clip MinX
	blt.b	.SkipD51_C

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD51_C

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD51_C:
	cmp	a2,d3		;Clip MinX
	blt.b	.SkipA01_C

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA01_C

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipA01_C:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	add.l	a1,a4		;+pixelwidth
	cmp	a2,d0		;Clip MinX
	blt.b	.SkipD01_C

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD01_C

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD01_C:
	cmp	a2,d7		;Clip MinX
	blt.b	.SkipD71_C

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_C

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_C:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_C

.CircleLoop_C:
	cmp	d0,d5	
	ble.b	.CircleEnd_C

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp	a2,d5		;Clip MinX
	blt.b	.SkipD53_C

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD53_C

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD53_C:
	cmp	a2,d3		;Clip MinX
	blt.b	.SkipA02_C

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA02_C

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipA02_C:
	sub.l	a1,a0		;-pixelwidth
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	add.l	a1,a4		;+pixelwidth
	cmp	a2,d0		;Clip MinX
	blt.b	.SkipD02_C

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD02_C

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD02_C:
	cmp	a2,d7		;Clip MinX
	blt.b	.SkipA62_C

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA62_C

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA62_C:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_C

	bra.w	.CircleOuter_C

.CircleEnd_C:
	bra.w	.CircleEnd

	cnop	0,16

;Clipping MinY & MinX & MaxX
.CircleInit_D:
	subq	#4,d7		 ;Y<0?
	beq.b	.ToCircleOuter_DY;only lower half needed
	
	move.l	d6,d7
	swap	d7
	move.l	d7,a5
	
	moveq	#0,d7
	bra.w	.CircleOuter_D	;full circle needed

	cnop	0,4

;only lower half needed
.ToCircleOuter_DY:
	move.l	d6,d7
	swap	d7
	move.l	d7,a5

	moveq	#0,d7
	bra.b	.CircleOuter_DY

	cnop	0,16

.CircleOuter_DY:
	addq	#1,d6
	add	d0,d1		;X inc
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD31_DY

	cmp	a5,d5		;Clip MinX
	blt.b	.SkipD52_DY

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD52_DY

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_DY:
	cmp	a5,d3		;Clip MinX
	blt.b	.SkipD31_DY

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD31_DY

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_DY:
	add.l	a1,a4		;+pixelwidth
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_DY

	cmp	a5,d7		;Clip MinX
	blt.b	.SkipD71_DY

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_DY

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_DY:
	cmp	a5,d0		;Clip MinX
	blt.b	.SkipA31_DY

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipA31_DY

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_DY:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_DY

.CircleLoop_DY:
	cmp	d0,d5	
	ble.b	.CircleEnd_DY

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	sub.l	a1,a3		;-pixelwidth
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_DY

	cmp	a5,d5		;Clip MinX
	blt.b	.SkipD54_DY

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD54_DY

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD54_DY:
	cmp	a5,d3		;Clip MinX
	blt.b	.SkipD32_DY

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD32_DY

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_DY:
	add.l	a1,a4		;+pixelwidth
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_DY

	cmp	a5,d0		;Clip MinX
	blt.b	.SkipD03_DY

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD03_DY

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD03_DY:
	cmp	a5,d7		;Clip MinX
	blt.b	.SkipA32_DY
	
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA32_DY

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_DY:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_DY

	bra.w	.CircleOuter_DY

.CircleEnd_DY:
	bra.w	.CircleEnd

	cnop	0,16

;full circle needed
.CircleOuter_D:
	addq	#1,d6
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA11_D
	
	cmp	a5,d5		;Clip MinX
	blt.b	.SkipD51_D

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD51_D

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD51_D:
	cmp	a5,d3		;Clip MinX
	blt.b	.SkipA01_D

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA01_D

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_D:
	sub.l	a1,a0		;-pixelwidth
.SkipA11_D:
	add	d0,d1		;X inc
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD31_D

	cmp	a5,d5		;Clip MinX
	blt.b	.SkipD52_D

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD52_D

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_D:
	cmp	a5,d3		;Clip MinX
	blt.b	.SkipD31_D

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD31_D

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_D:
	add.l	a1,a4		;+pixelwidth
	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA61_D

	cmp	a5,d0		;Clip MinX
	blt.b	.SkipD01_D

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD01_D

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD01_D:
	cmp	a5,d7		;Clip MinX
	blt.b	.SkipD71_D

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_D

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_D:
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_D

	cmp	a5,d7		;Clip MinX
	blt.b	.SkipD71_D

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_D

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_D:
	cmp	a5,d0		;Clip MinX
	blt.b	.SkipA31_D

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipA31_D

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_D:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_D

	bra.b	.CircleLoop_D

.CircleEnd_D:
	bra.w	.CircleEnd

	cnop	0,16
	
.CircleLoop_D:
	cmp	d0,d5	
	ble.b	.CircleEnd_D

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA22_D

	cmp	a5,d5		;Clip MinX
	blt.b	.SkipD53_D

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD53_D

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD53_D:
	cmp	a5,d3		;Clip MinX
	blt.b	.SkipA02_D

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA02_D

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_D:
	sub.l	a1,a0		;-pixelwidth
.SkipA22_D:
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_D

	cmp	a5,d5		;Clip MinX
	blt.b	.SkipD54_D

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD54_D

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD54_D:
	cmp	a5,d3		;Clip MinX
	blt.b	.SkipD32_D

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD32_D

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_D:
	add.l	a1,a4		;+pixelwidth
	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA62_D

	cmp	a5,d0		;Clip MinX
	blt.b	.SkipD02_D

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD02_D

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD02_D:
	cmp	a5,d7		;Clip MinX
	blt.b	.SkipA62_D

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA62_D

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_D:
	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_D

	cmp	a5,d0		;Clip MinX
	blt.b	.SkipD03_D

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD03_D

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD03_D:
	cmp	a5,d7		;Clip MinX
	blt.b	.SkipA32_D
	
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA32_D

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_D:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.w	.CircleLoop_D

	bra.w	.CircleOuter_D

	cnop	0,16

;Clipping MaxY & MinX & MaxX 
.CircleInit_E:
	subq	#8,d7		 ;Y>pixelheight?
	beq.b	.ToCircleOuter_EY;only upper half needed

	move.l	d6,d7
	swap	d7
	move.l	d7,a2
	
	moveq	#0,d7
	bra.w	.CircleOuter_E	;full circle needed

	cnop	0,4

;only upper half needed
.ToCircleOuter_EY:
	move.l	d6,d7
	swap	d7
	move.l	d7,a2
	
	moveq	#0,d7
	bra.b	.CircleOuter_EY

	cnop	0,16

.CircleOuter_EY:
	addq	#1,d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_EY
	
	cmp	a2,d5		;Clip MinX
	blt.b	.SkipD51_EY

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD51_EY

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD51_EY:
	cmp	a2,d3		;Clip MinX
	blt.b	.SkipA01_EY

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA01_EY

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_EY:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_EY

	cmp	a2,d0		;Clip MinX
	blt.b	.SkipD01_EY

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD01_EY

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD01_EY:
	cmp	a2,d7		;Clip MinX
	blt.b	.SkipA61_EY

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA61_EY

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_EY:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_EY

.CircleLoop_EY:
	cmp	d0,d5	
	ble.b	.CircleEnd_EY

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	add.l	a1,a6		;+pixelwidth
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_EY

	cmp	a2,d5		;Clip MinX
	blt.b	.SkipD53_EY

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD53_EY

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD53_EY:
	cmp	a2,d3		;Clip MinX
	blt.b	.SkipA02_EY

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA02_EY

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_EY:
	sub.l	a1,a0		;-pixelwidth
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_EY

	cmp	a2,d0		;Clip MinX
	blt.b	.SkipD02_EY

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD02_EY

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD02_EY:
	cmp	a2,d7		;Clip MinX
	blt.b	.SkipA62_EY

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA62_EY

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_EY:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_EY

	bra.w	.CircleOuter_EY

.CircleEnd_EY:
	bra.w	.CircleEnd

	cnop	0,16

;full circle needed
.CircleOuter_E:
	addq	#1,d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_E
	
	cmp	a2,d5		;Clip MinX
	blt.b	.SkipD51_E

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD51_E

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD51_E:
	cmp	a2,d3		;Clip MinX
	blt.b	.SkipA01_E

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA01_E

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_E:
	sub.l	a1,a0		;-pixelwidth
	add	d0,d1		;X inc
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA41_E

	cmp	a2,d5		;Clip MinX
	blt.b	.SkipD52_E

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD52_E

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_E:
	cmp	a2,d3		;Clip MinX
	blt.b	.SkipD31_E

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD31_E

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_E:
	add.l	a1,a4		;+pixelwidth
.SkipA41_E:
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_E

	cmp	a2,d0		;Clip MinX
	blt.b	.SkipD01_E

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD01_E

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD01_E:
	cmp	a2,d7		;Clip MinX
	blt.b	.SkipD71_E

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_E

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_E:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_E

	cmp	a2,d7		;Clip MinX
	blt.b	.SkipD71_E

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_E

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_E:
	cmp	a2,d0		;Clip MinX
	blt.b	.SkipA31_E

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipA31_E

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_E:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_E

	bra.b	.CircleLoop_E

.CircleEnd_E:
	bra.w	.CircleEnd

	cnop	0,16
	
.CircleLoop_E:
	cmp	d0,d5	
	ble.b	.CircleEnd_E

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_E

	cmp	a2,d5		;Clip MinX
	blt.b	.SkipD53_E

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD53_E

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD53_E:
	cmp	a2,d3		;Clip MinX
	blt.b	.SkipA02_E

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA02_E

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_E:
	sub.l	a1,a0		;-pixelwidth
.SkipA22_E:
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA42_E

	cmp	a2,d5		;Clip MinX
	blt.b	.SkipD54_E

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD54_E

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD54_E:
	cmp	a2,d3		;Clip MinX
	blt.b	.SkipD32_E

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD32_E

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_E:
	add.l	a1,a4		;+pixelwidth
.SkipA42_E:
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_E

	cmp	a2,d0		;Clip MinX
	blt.b	.SkipD02_E

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD02_E

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD02_E:
	cmp	a2,d7		;Clip MinX
	blt.b	.SkipA62_E

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA62_E

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_E:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA32_E

	cmp	a2,d0		;Clip MinX
	blt.b	.SkipD03_E

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD03_E

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD03_E:
	cmp	a2,d7		;Clip MinX
	blt.b	.SkipA32_E

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA32_E

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_E:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.w	.CircleLoop_E

	bra.w	.CircleOuter_E

	cnop	0,16

;Full Clipping
.CircleInit_F:
	subq	#8,d7			;Y>pixelheight?
	beq.w	.CircleOuter_FYUInit	;only upper half needed

	subq	#2,d7			;Y>pixelheight & X>pixelwidth?
	beq.w	.CircleOuter_FLUInit	;only upper left quadrant needed

	addq	#1,d7			;Y>pixelheight & X<0?
	beq.w	.CircleOuter_FRUInit	;only upper right quadrant needed

	addq	#8-1-2,d7		;Y<0?
	beq.w	.CircleOuter_FYLInit	;only lower half needed
	
	subq	#2,d7			;Y<0 & X>pixelwidth?
	beq.w	.CircleOuter_FLLInit	;only lower left quadrant needed

	addq	#1,d7			;Y<0 & X<0?
	beq.w	.CircleOuter_FRLInit	;only lower right quadrant needed

	addq	#3,d7			;X>pixelwidth?
	beq.w	.CircleOuter_FXL	;only left half needed

	addq	#1,d7			;X<0?
	beq.b	.CircleOuter_FXR	;only right half needed

	moveq	#0,d7
	bra.w	.CircleOuter_F		;full circle needed

	cnop	0,16

;only right half needed
.CircleOuter_FXR:
	addq	#1,d6
	add	d0,d1		;X inc
	swap	d6
	cmp	d6,d5		;Clip MinX
	blt.b	.SkipD52_FXR

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD52_FXR

	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA11_FXR
	
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA11_FXR
	
	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipA11_FXR:
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA41_FXR

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD52_FXR

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_FXR:
	add.l	a1,a4		;+pixelwidth
.SkipA41_FXR:	
	sub.l	a1,a0		;-pixelwidth
	cmp	d6,d0		;Clip MinX
	blt.b	.SkipA31_FXR

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipA31_FXR

	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_FXR

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA61_FXR

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipA61_FXR:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_FXR

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_FXR

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_FXR:
	subq	#1,d7
	addq	#1,d0
	swap	d6
	addq	#1,d1
	bmi.b	.CircleOuter_FXR

.CircleLoop_FXR:
	addq	#2,d6
	addq	#1,d3
	swap	d6
	cmp	d0,d5	
	ble.b	.CircleEnd_FXR

	subq	#1,d5
	cmp	d6,d5		;Clip MinX
	blt.b	.SkipD54_FXR

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD54_FXR

	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA22_FXR

	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA22_FXR

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipA22_FXR:
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA42_FXR

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD54_FXR

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD54_FXR:
	add.l	a1,a4		;+pixelwidth
.SkipA42_FXR:
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	sub.l	a1,a0		;-pixelwidth
	cmp	d6,d0		;Clip MinX
	blt.b	.SkipD03_FXR

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD03_FXR

	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_FXR

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA62_FXR

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipA62_FXR:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipD03_FXR

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipD03_FXR

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD03_FXR:
	subq	#1,d7
	swap	d6
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_FXR

	bra.w	.CircleOuter_FXR

.CircleEnd_FXR:
	bra.w	.CircleEnd

	cnop	0,16

;only left half needed
.CircleOuter_FXL:
	addq	#1,d6
	add	d0,d1		;X inc
	swap	d6
	cmp	d6,d3		;Clip MinX
	blt.b	.SkipD31_FXL

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD31_FXL

	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA11_FXL
	
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA11_FXL
	
	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA11_FXL:
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA41_FXL

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD31_FXL

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_FXL:
	add.l	a1,a4		;+pixelwidth
.SkipA41_FXL:	
	sub.l	a1,a0		;-pixelwidth
	cmp	d6,d7		;Clip MinX
	blt.b	.SkipD71_FXL

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_FXL

	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_FXL

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA61_FXL

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_FXL:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipD71_FXL

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipD71_FXL

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_FXL:
	subq	#1,d7
	addq	#1,d0
	swap	d6
	addq	#1,d1
	bmi.b	.CircleOuter_FXL

.CircleLoop_FXL:
	cmp	d0,d5	
	ble.b	.CircleEnd_FXL

	addq	#2,d6
	addq	#1,d3
	swap	d6
	subq	#1,d5
	cmp	d6,d3		;Clip MinX
	blt.b	.SkipD32_FXL

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD32_FXL

	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_FXL

	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA02_FXL

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_FXL:
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA42_FXL

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_FXL

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_FXL:
	add.l	a1,a4		;+pixelwidth
.SkipA42_FXL:
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	sub.l	a1,a0		;-pixelwidth
	cmp	d6,d7		;Clip MinX
	blt.b	.SkipA32_FXL
	
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA32_FXL

	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_FXL

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA62_FXL

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_FXL:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA32_FXL

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_FXL

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_FXL:
	subq	#1,d7
	swap	d6
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_FXL

	bra.w	.CircleOuter_FXL

.CircleEnd_FXL:
	bra.w	.CircleEnd

;only lower right quadrant needed
.CircleOuter_FRLInit:
	move.l	d6,d7
	swap	d7
	bra.w	.CircleOuter_FRL

	cnop	0,16

.CircleOuter_FRL:
	addq	#1,d6
	add	d0,d1		;X inc
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA41_FRL

	cmp	d7,d5		;Clip MinX
	blt.b	.SkipD31_FRL

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD31_FRL

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD31_FRL

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD31_FRL:
	add.l	a1,a4		;+pixelwidth
.SkipA41_FRL:	
	cmp	d7,d0		;Clip MinX
	blt.b	.SkipA31_FRL

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipA31_FRL

	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_FRL

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_FRL

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_FRL:
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_FRL

.CircleLoop_FRL:
	cmp	d0,d5	
	ble.b	.CircleEnd_FRL

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	sub.l	a1,a3		;-pixelwidth
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA42_FRL

	cmp	d7,d5		;Clip MinX
	blt.b	.SkipD54_FRL

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD54_FRL

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD54_FRL

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD54_FRL:
	add.l	a1,a4		;+pixelwidth
.SkipA42_FRL:
	cmp	d7,d0		;Clip MinX
	blt.b	.SkipA32_FRL

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipA32_FRL

	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA32_FRL

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_FRL

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA32_FRL:
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_FRL

	bra.b	.CircleOuter_FRL

.CircleEnd_FRL:
	bra.w	.CircleEnd

;only lower left quadrant needed
.CircleOuter_FLLInit:
	swap	d6
	move.l	d6,a6
	swap	d6
	bra.b	.CircleOuter_FLL

	cnop	0,16

.CircleOuter_FLL:
	add	d0,d1		;X inc
	addq	#1,d6
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA41_FLL

	cmp	a6,d3		;Clip MinX
	blt.b	.SkipD31_FLL

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD31_FLL

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD31_FLL

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_FLL:
	add.l	a1,a4		;+pixelwidth
.SkipA41_FLL:	
	cmp	a6,d7		;Clip MinX
	blt.b	.SkipD71_FLL

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_FLL

	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipD71_FLL

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipD71_FLL

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_FLL:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_FLL

.CircleLoop_FLL:
	cmp	d0,d5	
	ble.b	.CircleEnd_FLL

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	sub.l	a1,a3		;-pixelwidth
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA42_FLL

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_FLL

	cmp	a6,d3		;Clip MinX
	blt.b	.SkipD32_FLL

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD32_FLL

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_FLL:
	add.l	a1,a4		;+pixelwidth
.SkipA42_FLL:
	cmp	a6,d7		;Clip MinX
	blt.b	.SkipA32_FLL
	
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA32_FLL

	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA32_FLL

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_FLL

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_FLL:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_FLL

	bra.b	.CircleOuter_FLL

.CircleEnd_FLL:
	bra.w	.CircleEnd

;only lower half needed
.CircleOuter_FYLInit:
	swap	d6
	move.l	d6,a0
	swap	d6
	bra.b	.CircleOuter_FYL

	cnop	0,16

.CircleOuter_FYL:
	add	d0,d1		;X inc
	addq	#1,d6
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA41_FYL

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD31_FYL

	cmp	a0,d5		;Clip MinX
	blt.b	.SkipD52_FYL

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD52_FYL

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_FYL:
	cmp	a0,d3		;Clip MinX
	blt.b	.SkipD31_FYL

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD31_FYL

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_FYL:
	add.l	a1,a4		;+pixelwidth
.SkipA41_FYL:	
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_FYL

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_FYL

	cmp	a0,d7		;Clip MinX
	blt.b	.SkipD71_FYL

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_FYL

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_FYL:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_FYL

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_FYL

	cmp	a0,d0		;Clip MinX
	blt.b	.SkipA31_FYL

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipA31_FYL

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_FYL:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_FYL

.CircleLoop_FYL:
	cmp	d0,d5	
	ble.b	.CircleEnd_FYL

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	sub.l	a1,a3		;-pixelwidth
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA42_FYL

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_FYL

	cmp	a0,d5		;Clip MinX
	blt.b	.SkipD54_FYL

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD54_FYL

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD54_FYL:
	cmp	a0,d3		;Clip MinX
	blt.b	.SkipD32_FYL

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD32_FYL

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_FYL:
	add.l	a1,a4		;+pixelwidth
.SkipA42_FYL:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA32_FYL

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_FYL

	cmp	a0,d0		;Clip MinX
	blt.b	.SkipD03_FYL

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD03_FYL

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD03_FYL:
	cmp	a0,d7		;Clip MinX
	blt.b	.SkipA32_FYL
	
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA32_FYL

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_FYL:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_FYL

	bra.w	.CircleOuter_FYL

.CircleEnd_FYL:
	bra.w	.CircleEnd

;only upper right quadrant needed
.CircleOuter_FRUInit:
	move.l	d6,d7
	swap	d7
	bra.b	.CircleOuter_FRU

	cnop	0,16

.CircleOuter_FRU:
	addq	#1,d6
	cmp	d7,d5		;Clip MinX
	blt.b	.SkipA01_FRU

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipA01_FRU

	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_FRU
	
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA11_FRU
	
	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipA01_FRU:
	sub.l	a1,a0		;-pixelwidth
.SkipA11_FRU:
	add	d0,d1		;X inc
	cmp	d7,d0		;Clip MinX
	blt.b	.SkipA61_FRU

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipA61_FRU

	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_FRU

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA61_FRU

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipA61_FRU:
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_FRU

.CircleLoop_FRU:
	cmp	d0,d5	
	ble.b	.CircleEnd_FRU

	subq	#1,d5
	addq	#1,d3
	cmp	d7,d5		;Clip MinX
	blt.b	.SkipA02_FRU

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipA02_FRU

	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_FRU

	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA22_FRU

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipA02_FRU:
	sub.l	a1,a0		;-pixelwidth
.SkipA22_FRU:
	add.l	a1,a6		;+pixelwidth
	addq	#2,d6
	cmp	d7,d0		;Clip MinX
	blt.b	.SkipA62_FRU

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipA62_FRU

	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_FRU

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA62_FRU

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipA62_FRU:
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_FRU

	bra.b	.CircleOuter_FRU

.CircleEnd_FRU:
	bra.w	.CircleEnd

;only upper left quadrant needed
.CircleOuter_FLUInit:
	swap	d6
	move.l	d6,a4
	swap	d6
	bra.b	.CircleOuter_FLU

	cnop	0,16

.CircleOuter_FLU:
	cmp	a4,d3		;Clip MinX
	blt.b	.SkipA01_FLU

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA01_FLU

	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_FLU
	
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA11_FLU

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_FLU:
	sub.l	a1,a0		;-pixelwidth
.SkipA11_FLU:
	addq	#1,d6
	add	d0,d1		;X inc
	cmp	a4,d7		;Clip MinX
	blt.b	.SkipA61_FLU

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA61_FLU

	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_FLU

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA61_FLU

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_FLU:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_FLU

.CircleLoop_FLU:
	cmp	d0,d5	
	ble.b	.CircleEnd_FLU

	addq	#2,d6
	addq	#1,d3
	subq	#1,d5
	cmp	a4,d3		;Clip MinX
	blt.b	.SkipA02_FLU

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA02_FLU

	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_FLU

	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA22_FLU

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_FLU:
	sub.l	a1,a0		;-pixelwidth
.SkipA22_FLU:
	add.l	a1,a6		;+pixelwidth

	cmp	a4,d7		;Clip MinX
	blt.b	.SkipA62_FLU

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA62_FLU

	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_FLU

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA62_FLU

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_FLU:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_FLU

	bra.b	.CircleOuter_FLU

.CircleEnd_FLU:
	bra.w	.CircleEnd

;only upper half needed
.CircleOuter_FYUInit:
	swap	d6
	move.l	d6,a4
	swap	d6
	bra.b	.CircleOuter_FYU

	cnop	0,16

.CircleOuter_FYU:
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_FYU
	
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA11_FYU
	
	cmp	a4,d5		;Clip MinX
	blt.b	.SkipD51_FYU

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD51_FYU

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD51_FYU:
	cmp	a4,d3		;Clip MinX
	blt.b	.SkipA01_FYU

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA01_FYU

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_FYU:
	sub.l	a1,a0		;-pixelwidth
.SkipA11_FYU:
	addq	#1,d6
	add	d0,d1		;X inc
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_FYU

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA61_FYU

	cmp	a4,d0		;Clip MinX
	blt.b	.SkipD01_FYU

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD01_FYU

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD01_FYU:
	cmp	a4,d7		;Clip MinX
	blt.b	.SkipA61_FYU

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA61_FYU

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_FYU:
	subq	#1,d7
	addq	#1,d0
	addq	#1,d1
	bmi.b	.CircleOuter_FYU

.CircleLoop_FYU:
	cmp	d0,d5	
	ble.b	.CircleEnd_FYU

	addq	#2,d6
	subq	#1,d5
	addq	#1,d3
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_FYU

	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA22_FYU

	cmp	a4,d5		;Clip MinX
	blt.b	.SkipD53_FYU

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD53_FYU

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD53_FYU:
	cmp	a4,d3		;Clip MinX
	blt.b	.SkipA02_FYU

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA02_FYU

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_FYU:
	sub.l	a1,a0		;-pixelwidth
.SkipA22_FYU:
	add.l	a1,a6		;+pixelwidth
	sub.l	a1,a3		;-pixelwidth
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_FYU

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA62_FYU

	cmp	a4,d0		;Clip MinX
	blt.b	.SkipD02_FYU

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD02_FYU

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD02_FYU:
	cmp	a4,d7		;Clip MinX
	blt.b	.SkipA62_FYU

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA62_FYU

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_FYU:
	subq	#1,d7
	addq	#1,d0
	add	d6,d1
	bpl.b	.CircleLoop_FYU

	bra.w	.CircleOuter_FYU

.CircleEnd_FYU:
	bra.w	.CircleEnd

	cnop	0,16

;full circle needed
.CircleOuter_F:
	addq	#1,d6
	add	d0,d1		;X inc
	swap	d6
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA01_F
	
	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA11_F
	
	cmp	d6,d5		;Clip MinX
	blt.b	.SkipD51_F

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD51_F

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD51_F:
	cmp	d6,d3		;Clip MinX
	blt.b	.SkipA01_F

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA01_F

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA01_F:
	sub.l	a1,a0		;-pixelwidth
.SkipA11_F:
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA41_F

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD31_F

	cmp	d6,d5		;Clip MinX
	blt.b	.SkipD52_F

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD52_F

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD52_F:
	cmp	d6,d3		;Clip MinX
	blt.b	.SkipD31_F

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD31_F

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD31_F:
	add.l	a1,a4		;+pixelwidth
.SkipA41_F:	
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA61_F

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA61_F

	cmp	d6,d0		;Clip MinX
	blt.b	.SkipD01_F

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD01_F

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD01_F:
	cmp	d6,d7		;Clip MinX
	blt.b	.SkipD71_F

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_F

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA61_F:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_F

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_F

	cmp	d6,d7		;Clip MinX
	blt.b	.SkipD71_F

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipD71_F

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipD71_F:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA31_F

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA31_F

	cmp	d6,d0		;Clip MinX
	blt.b	.SkipA31_F

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipA31_F

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipA31_F:
	subq	#1,d7
	addq	#1,d0
	swap	d6
	addq	#1,d1
	bmi.w	.CircleOuter_F

	bra.b	.CircleLoop_F

.CircleEnd_F:
	bra.w	.CircleEnd

	cnop	0,16

.CircleLoop_F:
	cmp	d0,d5	
	ble.b	.CircleEnd_F

	addq	#2,d6
	addq	#1,d3
	swap	d6
	subq	#1,d5
	cmp.l	a5,a0		;Clip MaxY
	bge.b	.SkipA02_F

	cmp.l	a2,a0		;Clip MinY
	blt.b	.SkipA22_F

	cmp	d6,d5		;Clip MinX
	blt.b	.SkipD53_F

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD53_F

	move.b	d2,(a0,d5.w)	;2/8 X+,Y-
.SkipD53_F:
	cmp	d6,d3		;Clip MinX
	blt.b	.SkipA02_F

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipA02_F

	move.b	d2,(a0,d3.w)	;7/8 X-,Y-
.SkipA02_F:
	sub.l	a1,a0		;-pixelwidth
.SkipA22_F:
	sub.l	a1,a3		;-pixelwidth
	add.l	a1,a6		;+pixelwidth
	cmp.l	a5,a4		;Clip MaxY
	bge.b	.SkipA42_F

	cmp.l	a2,a4		;Clip MinY
	blt.b	.SkipD32_F

	cmp	d6,d5		;Clip MinX
	blt.b	.SkipD54_F

	cmp	d4,d5		;Clip MaxX
	bge.b	.SkipD54_F

	move.b	d2,(a4,d5.w)	;3/8 X+,Y+
.SkipD54_F:
	cmp	d6,d3		;Clip MinX
	blt.b	.SkipD32_F

	cmp	d4,d3		;Clip MaxX
	bge.b	.SkipD32_F

	move.b	d2,(a4,d3.w)	;6/8 X-,Y+
.SkipD32_F:
	add.l	a1,a4		;+pixelwidth
.SkipA42_F:
	cmp.l	a5,a6		;Clip MaxY
	bge.b	.SkipA62_F

	cmp.l	a2,a6		;Clip MinY
	blt.b	.SkipA62_F

	cmp	d6,d0		;Clip MinX
	blt.b	.SkipD02_F

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD02_F

	move.b	d2,(a6,d0.w)	;1/8 X+,Y-
.SkipD02_F:
	cmp	d6,d7		;Clip MinX
	blt.b	.SkipA62_F

	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA62_F

	move.b	d2,(a6,d7.w)	;8/8 X-,Y-
.SkipA62_F:
	cmp.l	a5,a3		;Clip MaxY
	bge.b	.SkipA32_F

	cmp.l	a2,a3		;Clip MinY
	blt.b	.SkipA32_F

	cmp	d6,d0		;Clip MinX
	blt.b	.SkipD03_F

	cmp	d4,d0		;Clip MaxX
	bge.b	.SkipD03_F

	move.b	d2,(a3,d0.w)	;4/8 X+,Y+
.SkipD03_F:
	cmp	d6,d7		;Clip MinX
	blt.b	.SkipA32_F
	
	cmp	d4,d7		;Clip MaxX
	bge.b	.SkipA32_F

	move.b	d2,(a3,d7.w)	;5/8 X-,Y+
.SkipA32_F:
	subq	#1,d7
	swap	d6
	addq	#1,d0
	add	d6,d1
	bpl.w	.CircleLoop_F

	bra.w	.CircleOuter_F

	cnop	0,4

	INCLUDE	"ChunkyMultab.s"

