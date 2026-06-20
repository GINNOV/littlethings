;Bevel box Progress bar

; A0 - Window

; D0 - Bar start X coord
; D1 - Bar start Y coord
; D2 - Bar width
; D3 - Bar height

;-----------------------------------------------------------------------
BuildBar:	Move.W	D0,BarX
	Move.W	D1,BarY

	Move.L	(wd_RPort,A0),WRPort

	Lea	(ProgressBox,PC),A0
	Lea	(Coords,A0),A0

	Move.W	D2,(A0)+
	Move.W	D3,(A0)+
	Move.W	D2,(A0)+
	Addq	#2,A0
	Add.W	D2,(A0)+
	Addq	#2,A0
	Add.W	D2,(A0)+
	Move.W	D3,(A0)+
	Addq	#2,A0
	Move.W	D3,(A0)+
	Addq	#6,A0
	Move.W	D3,(A0)+
	Addq	#2,A0
	Add.W	D3,(A0)+
	Addq	#4,A0
	Add.W	D2,(A0)+

	Addq	#2,D0
	Move.W	D0,BoxX
	Add.W	D2,D0
	Subq	#4,D0
	Move.W	D0,BoxX2

	Addq	#1,D1
	Move.W	D1,BoxY
	Add.W	D3,D1
	Subq	#2,D1
	Move.W	D1,BoxY2

	Clr.L	D0
	Clr.L	D1

	Move.L	(WRPort,PC),A0
	Lea	(ProgressBox,PC),A1
	Move.W	(BarX,PC),D0
	Move.W	(BarY,PC),D1
	CALL	DrawBorder,INTUI

;-----------------------------------------------------------------------
ClearBar:	Move.W	(BoxX,PC),BarCount

	Clr.L	D1
	Clr.L	D2
	Clr.L	D3

	Move.L	(WRPort,PC),A1
	Moveq	#0,D0		;pen colour
	CALL	SetAPen,GRAPH

	Move.L	(WRPort,PC),A0
	Move.W	(BoxX,PC),D0
	Move.W	(BoxY,PC),D1
	Move.W	(BoxX2,PC),D2
	Move.W	(BoxY2,PC),D3
	CALL	RectFill
	Rts

;-----------------------------------------------------------------------
UpdateBar:	Clr.L	D3
	Clr.L	D5
	Clr.L	D6
	Clr.L	D7

	Move.L	(WRPort,PC),A3
	Move.W	(BoxX2,PC),D5
	Move.W	(BoxY,PC),D6
	Move.W	(BoxY2,PC),D7
	Move.W	(BarCount,PC),D3

	Move.L	D5,D2
	Addq	#1,D2
	Cmp.W	D2,D3
	Beq	.NoMore

	Moveq	#3,D0
	Move.L	A3,A1
	CALL	SetAPen,GRAPH

	Move.W	D3,D0
	Move.W	D6,D1
	Move.L	A3,A1
	CALL	Move

	Move.W	D3,D0
	Move.W	D7,D1
	Move.L	A3,A1
	CALL	Draw

	Addq.W	#1,BarCount
.NoMore	Rts

;-----------------------------------------------------------------------
BarCount:	Dc.W	0

BarX:	Dc.W	0
BarY:	Dc.W	0

BoxX:	Dc.W	0
BoxY:	Dc.W	0

BoxX2:	Dc.W	0
BoxY2:	Dc.W	0

WRPort:	Dc.L	0

;----------------------
ProgressBox:	Dc.W	0,0
	Dc.B	2,0,RP_JAM1
	Dc.B	5
	Dc.L	.IBorderVectors
	Dc.L	.IBorderb

.IBorderb	Dc.W	0,0
	Dc.B	1,0,RP_JAM1
	Dc.B	5
	Dc.L	.IBorderVectorsb
	Dc.L	0

Coords	Equ	*-ProgressBox
.IBorderVectors
	Dc.W	0,0
	Dc.W	0,0
	Dc.W	-1,1
	Dc.W	-1,0
	Dc.W	0,0
.IBorderVectorsb
	Dc.W	0,0
	Dc.W	0,0
	Dc.W	1,-1
	Dc.W	1,0
	Dc.W	-1,0
