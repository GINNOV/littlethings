; Build modified Border structures
; $VER: Include v1.00 / PH v2.40
; (C) Mika Lundell
;
; This source code is part of the PopHelp package.
; Freeware, use it as you like.

_BuildBorders	macro
BuildBorders	move.l	$4,a6
		move.l	#(7*2)*bd_SIZEOF,d0
		move.l	#MEMF_CLEAR!MEMF_PUBLIC,d1
		jsr	AllocMem(a6)
		move.l	d0,Borders(a5)
		beq	BBdErr

		move.l	d0,a2
		sub.w	#2*bd_SIZEOF,a2
		lea	BorderVecs(pc),a3
		lea	ActBorder(a5),a4

		moveq	#5,d7
1$		bsr.s	BorderConstants
		move.l	a2,(a4)+
		dbf	d7,1$

		bsr.s	BorderConstants
		lea	StringVecs(pc),a3
		subq.w	#6,bd_LeftEdge(a2)
		subq.w	#3,bd_TopEdge(a2)
		addq.b	#5,bd_Count(a2)
		move.l	a3,bd_XY(a2)
		subq.w	#6,bd_LeftEdge(a1)
		subq.w	#3,bd_TopEdge(a1)
		addq.b	#5,bd_Count(a1)
		add.w	#20*2,a3
		move.l	a3,bd_XY(a1)
		move.l	a2,(a4)+

		lea	DirVecs(pc),a0
		lea	_DirVecs(a5),a1
		moveq	#(20*2)*2,d0
		jsr	CopyMem(a6)
		lea	_DirVecs(a5),a0
		move.l	DirBorder(a5),a1
		move.l	a0,bd_XY(a1)
		add.w	#10*2,a0
		move.l	a0,bd_SIZEOF+bd_XY(a1)
		lea	_TypeVecs(a5),a0
		move.l	TypeBorder(a5),a1
		move.l	a0,bd_XY(a1)
		add.w	#10*2,a0
		move.l	a0,bd_SIZEOF+bd_XY(a1)
		rts

BBdErr		addq.b	#1,BorderError(a5)
		rts

BorderConstants	add.w	#2*bd_SIZEOF,a2
		addq.b	#1,bd_FrontPen(a2)
		addq.b	#2,bd_BackPen(a2)
		addq.b	#5,bd_Count(a2)
		move.l	a3,bd_XY(a2)
		add.w	#10*2,a3

		lea	bd_SIZEOF(a2),a1
		move.l	a1,bd_NextBorder(a2)
		addq.b	#2,bd_FrontPen(a1)
		addq.b	#1,bd_BackPen(a1)
		addq.b	#5,bd_Count(a1)
		move.l	a3,bd_XY(a1)
		add.w	#10*2,a3
		rts

SmashBorders	move.l	Borders(a5),d2
		beq.s	1$
		move.l	$4,a6
		move.l	#(7*2)*bd_SIZEOF,d0
		move.l	d2,a1
		jsr	FreeMem(a6)
1$		rts
		endm

_BorderData	macro
BorderVecs	dc.w	0,0,0,11,1,11,1,0,602,0		; ActBorder
		dc.w	603,11,603,0,602,1,602,11,1,11
		dc.w	0,0,0,40,1,40,1,0,602,0		; MsgBorder
		dc.w	603,40,603,0,602,1,602,40,1,40
		dc.w	0,0,0,10,1,10,1,0,71,0		; OptionBorder
		dc.w	71,10,71,0,70,1,70,10,1,10
		dc.w	0,0,0,10,1,10,1,0,46,0		; FirstBorder
		dc.w	46,10,46,0,45,1,45,10,1,10
DirVecs		dc.w	0,0,0,167,1,167,1,0,309,0	; DirBorder
		dc.w	310,167,310,0,309,1,309,167,1,167
TypeVecs	dc.w	0,0,0,167,1,167,1,0,623,0	; TypeBorder
		dc.w	624,167,624,0,623,1,623,167,1,167
; StringBorder
StringVecs	dc.w	0,0,0,13,1,12,1,0,538,0,537,0,537,12,536,2,536,12,4,12
		dc.w	536,1,4,1,4,11,3,1,3,12,1,13,538,13,538,1,539,13,539,0
		endm
