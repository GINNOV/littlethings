****************************************************************************
*	POLYCLIP.I	Polynomial clip routine
****************************************************************************
*	On entry	d7.w = number of vertices
****************************************************************************
*	On exit	zero flag set = fill area visible & clipped
*		zero flag clear = fill area not visible
****************************************************************************
*	register usage:
*
*	d0/d1	coords of current vertex
*	d2/d3	coords of previous vertex
*	d4/d5	acumulators
*	d6	new vertex counter
*	d7	vertex counter
*	a0	original vertex list ptr (unchanged)
*	a1	ptr to old vertex list
*	a2	ptr to new vertex list
*	a3	copy of start of new list
*	a4	window extent coord
******************************************************************************
X_MIN	equ	16
X_MAX	equ	319-16
Y_MIN	equ	1
Y_MAX	equ	199

******************************************************************************
horiz_cross	MACRO
	move.w	d2,d4          copy of x1
	move.w	a4,d5          copy of yval
	sub.w	d3,d5          (yval-y1)
	sub.w	d0,d2          (x1-x2)
	muls	d5,d2
	sub.w	d1,d3          (y1-y2)
	divs	d3,d2
	add.w	d4,d2          new x

	move.w	d2,(a2)+
	move.w	a4,(a2)+
	addq.w	#1,d6
	ENDM

vert_cross	MACRO
	move.w	d3,d4          copy of y1
	move.w	a4,d5          copy of xval
	sub.w	d2,d5          (xval-x1)
	sub.w	d1,d3          (y1-y2)
	muls	d5,d3
	sub.w	d0,d2          (x1-x2)
	divs	d2,d3
	add.w	d4,d3          new y

	move.w	a4,(a2)+
	move.w	d3,(a2)+
	addq.w	#1,d6
	ENDM

******************************************************************************
cliploops	MACRO
	movem.w	-4(a3),d2-d3	previous x coord/y coord
	cmp.w	a4,d\5
	b\1.s	.outsideloop\@
	bra.s	.insideloop\@

.crosstoin\@	beq.s	.startinside\@	vertex on boundary
	\3
	bra.s	.startinside\@

.insideloop\@	movem.w	(a1)+,d0-d1    x coord/y coord
	cmp.w	a4,d\4
	b\1.s	.crosstoout\@
.startinside\@	move.w	d0,(a2)+
	move.w	d1,(a2)+
	addq.w	#1,d6
	move.w	d0,d2
	move.w	d1,d3
	dbra	d7,.insideloop\@
	bra.s	.nonetest\@

.crosstoout\@	cmp.w	a4,d\5
	beq.s	.startoutside\@
	\3
	bra.s	.startoutside\@

.outsideloop\@	movem.w	(a1)+,d0-d1    x coord/y coord
	cmp.w	a4,d\4
	b\2.s	.crosstoin\@
.startoutside\@ move.w	d0,d2
	move.w	d1,d3
	dbra	d7,.outsideloop\@

.nonetest\@	tst.w	d6
	beq	.offscreen
	ENDM

******************************************************************************
*	Handle top of screen
_polyclip	lea	_polydata(pc),a1  start of old list
	move.l	a1,a2
	move.w	d7,d0
	lsl.w	#2,d0
	add.w	d0,a2          start of new list
	move.l	a2,a3          copy of start of new list
	subq.w	#1,d7          decrement for dbcc
	clr.w	d6             new vertex count
	move.w	#Y_MAX,a4      y max

******************************************************************************
	cliploops	gt,le,horiz_cross,1,3

******************************************************************************
*	Handle bottom of screen
.lab1	move.w	d6,d7
	move.l	a3,a1          start of old list
	move.l	a2,a3          copy of start of new list
	subq.w	#1,d7          decrement for dbcc
	clr.w	d6             new vertex count
	move.w	#Y_MIN,a4      y min

******************************************************************************
	cliploops	lt,ge,horiz_cross,1,3

******************************************************************************
*	Handle left of screen
.lab2	move.w	d6,d7
	move.l	a3,a1          start of old list
	move.l	a2,a3          copy of start of new list
	subq.w	#1,d7          decrement for dbcc
	clr.w	d6             new vertex count
	move.w	#X_MIN,a4      x min

******************************************************************************
	cliploops	lt,ge,vert_cross,0,2

******************************************************************************
*	Handle right of screen
.lab3	move.w	d6,d7
	move.l	a3,a1          start of old list
	move.l	a2,a3          end of old list
	lea	_polydata,a2    start of new list
	subq.w	#1,d7          decrement for dbcc
	clr.w	d6             new vertex count
	move.w	#X_MAX,a4         x max

******************************************************************************
	cliploops	gt,le,vert_cross,0,2

******************************************************************************
.clipdone	move.w	d6,d7          updated number of vertices
	clr.w	d0             set zero flag
	rts

******************************************************************************
.offscreen	moveq	#1,d0         clear zero flag
	rts

maxpolyorder	EQU	30
_polydata	DS.W	maxpolyorder*2*2*3
