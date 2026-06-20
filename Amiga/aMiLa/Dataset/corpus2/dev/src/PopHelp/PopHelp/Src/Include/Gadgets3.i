; Build modified Gadget structures
; $VER: Include v1.00 / PH v2.58
; (C) Mika Lundell
;
; This source code is part of the PopHelp package.
; Freeware, use it as you like.

_BuildGadgets	macro
BuildGadgets	bsr	AddStringGad
		move.w	#39,gg_TopEdge(a2)
		move.w	#11,gg_GadgetID(a2)
		move.l	StringBuf1(a5),si_Buffer(a1)

		bsr	AddStringGad
		move.w	#63,gg_TopEdge(a2)
		move.w	#12,gg_GadgetID(a2)
		move.l	StringBuf2(a5),si_Buffer(a1)

DeviceGs	lea	Dev0_txt(pc),a4
		lea	GadgetIDs(pc),a3
		move.w	#169,d3		; BoolX
		moveq	#78,d2		; BoolY
		moveq	#GADGHCOMP,d6
		moveq	#RELVERIFY,d5
		move.l	#$00160002,d4	; 22.w, 2.w
		moveq	#3,d7
1$		bsr	AddBoolGad
		dbf	d7,1$

OptionGs	moveq	#17,d3
		moveq	#90,d2
		move.w	#GADGHCOMP!GADGDISABLED,d6
		move.w	#TOGGLESELECT!GADGIMMEDIATE,d5
		move.l	#$00040002,d4	; 4.w, 2.w
		moveq	#7,d7
1$		lea	Opt_txt(pc),a4
		bsr	AddBoolGad
		dbf	d7,1$

; Begin new GList for second window...
ImageGs		lea	DwnData(a5),a4		; a3=GadgetIDs (already set)
		move.w	#298,d3
		moveq	#gg_SIZEOF+ig_SIZEOF,d2	; Flag: Right arrows...
		moveq	#GADGHCOMP!GADGIMAGE,d6
		moveq	#GADGIMMEDIATE!RELVERIFY,d5
		moveq	#5,d7
1$		bsr	AddImageGad
		dbf	d7,1$

FirstBool	move.l	PrevGadget(a5),a6	; Add FirstGadget
		lea	First_txt(pc),a4
		move.w	#152,d3
		move.w	#183,d2
		moveq	#GADGHCOMP,d6
		moveq	#RELVERIFY,d5
		move.l	#$00040002,d4	; 4.w, 2.w
		bsr	AddBoolGad
		move.w	#47,gg_Width(a2)
		move.l	FirstBorder(a5),gg_GadgetRender(a2)
		clr.l	gg_NextGadget(a6)
		move.l	a6,PrevGadget(a5)
		move.l	PrevIGadget(a5),a0
		move.l	a2,gg_NextGadget(a0)
		move.l	a2,PrevIGadget(a5)
		move.l	a2,First_Gadget(a5)

		move.l	FirstIGadget(a5),a6
		lea	DwnData(a5),a4		; a3=GadgetIDs (already set)
		moveq	#gg_SIZEOF,d2		; Flag: Left arrows, use Right
		move.w	#612,d3			; arrows image ptr...
		moveq	#GADGHCOMP!GADGIMAGE,d6
		moveq	#GADGIMMEDIATE!RELVERIFY,d5
		bsr	AddImageGad
		move.l	gg_GadgetRender(a6),gg_GadgetRender(a2)
		move.l	gg_NextGadget(a6),a6
		move.l	a2,FirstIGadget2(a5)
		moveq	#4,d7
1$		bsr	AddImageGad
		move.l	gg_GadgetRender(a6),gg_GadgetRender(a2)
		move.l	gg_NextGadget(a6),a6
		dbf	d7,1$
		rts

AddImageGad	tst.b	GadgetError(a5)
		bne.s	GAddError
		move.l	d2,d0
		bsr	Alloc_gg_Struct
		beq.s	GAddError

		move.l	d0,a2
		move.l	PrevIGadget(a5),a0
		move.l	a0,d0
		bne.s	AnotherIGad
		move.l	a2,FirstIGadget(a5)
		bra.s	WasFirstIGad
AnotherIGad	move.l	a2,gg_NextGadget(a0)

WasFirstIGad	move.l	a2,PrevIGadget(a5)
		move.w	d3,gg_LeftEdge(a2)
		move.w	#183,gg_TopEdge(a2)
		move.w	#16,gg_Width(a2)
		move.w	#11,gg_Height(a2)
		addq.w	#GADGHCOMP!GADGIMAGE,gg_Flags(a2)
		addq.w	#GADGIMMEDIATE!RELVERIFY,gg_Activation(a2)
		addq.w	#BOOLGADGET,gg_GadgetType(a2)
		move.w	(a3)+,gg_GadgetID(a2)
		lea	gg_SIZEOF(a2),a1
		cmpi.b	#gg_SIZEOF,d2
		beq.s	UseOldImagePtrs
		move.l	a1,gg_GadgetRender(a2)
		move.w	#16,ig_Width(a1)
		move.w	#11,ig_Height(a1)
		addq.w	#2,ig_Depth(a1)
		move.l	(a4)+,ig_ImageData(a1)
		addq.b	#3,ig_PlanePick(a1)
UseOldImagePtrs	subi.w	#18,d3
		rts

GAddError	move.l	Err_pad(a5),a2
		move.l	a2,a1
		move.l	a2,a0
		rts

AddBoolGad	tst.b	GadgetError(a5)
		bne.s	GAddError
		moveq	#gg_SIZEOF+it_SIZEOF,d0
		bsr	Alloc_gg_Struct
		beq.s	GAddError

		move.l	d0,a2
		move.l	PrevGadget(a5),a0
		move.l	a2,gg_NextGadget(a0)
		move.l	a2,PrevGadget(a5)
		move.w	d3,gg_LeftEdge(a2)
		move.w	d2,gg_TopEdge(a2)
		move.w	#72,gg_Width(a2)
		move.w	#11,gg_Height(a2)
		move.w	d6,gg_Flags(a2)
		move.w	d5,gg_Activation(a2)
		move.w	#BOOLGADGET,gg_GadgetType(a2)
		move.l	OptionBorder(a5),gg_GadgetRender(a2)
		move.w	(a3)+,gg_GadgetID(a2)
		lea	gg_SIZEOF(a2),a1
		move.l	a1,gg_GadgetText(a2)
		move.w	#$0102,it_FrontPen(a1)
		move.l	d4,it_LeftEdge(a1)
		lea	TextAttr(pc),a0
		move.l	a0,it_ITextFont(a1)
		move.l	a4,it_IText(a1)
		bsr	NxtName_Width
		addi.w	#76,d3
		rts

AddStringGad	tst.b	GadgetError(a5)
		bne	GAddError
		moveq	#gg_SIZEOF+si_SIZEOF+it_SIZEOF,d0
		bsr	Alloc_gg_Struct
		beq	GAddError

		move.l	d0,a2
		move.l	PrevGadget(a5),a0
		move.l	a0,d0
		bne.s	AnotherString
		move.l	a2,FirstGadget(a5)
		bra.s	WasFirst
AnotherString	move.l	a2,gg_NextGadget(a0)

WasFirst	move.l	a2,PrevGadget(a5)
		move.w	#54,gg_LeftEdge(a2)
		move.w	#528,gg_Width(a2)
		move.w	#10,gg_Height(a2)
	;	addq.w	#GADGHCOMP,gg_Flags(a2)	; =0
		addq.w	#GADGIMMEDIATE!RELVERIFY,gg_Activation(a2)
		addq.w	#STRGADGET,gg_GadgetType(a2)
		move.l	StringBorder(a5),gg_GadgetRender(a2)

		lea	gg_SIZEOF(a2),a1
		move.l	StringUnDoBuf(a5),si_UndoBuffer(a1)
		move.w	#79,si_MaxChars(a1)

		lea	si_SIZEOF(a1),a0
		move.w	#$0102,it_FrontPen(a0)
		move.l	#$ffe0fff4,it_LeftEdge(a0)
		move.l	a1,-(sp)
		lea	TextAttr(pc),a1
		move.l	a1,it_ITextFont(a0)
		move.l	(sp)+,a1

		move.l	a0,gg_GadgetText(a2)
		move.l	a1,gg_SpecialInfo(a2)
		rts

Alloc_gg_Struct	movem.l	a6,-(sp)
		move.l	$4,a6
		move.l	#MEMF_CLEAR!MEMF_PUBLIC,d1
		jsr	AllocMem(a6)
		move.l	(sp)+,a6
		tst.l	d0
		bne.s	1$
		addq.b	#1,GadgetError(a5)
		tst.l	d0
1$		rts

SmashGadgets	move.l	$4,a6
		move.l	FirstGadget(a5),d4
		moveq	#gg_SIZEOF+si_SIZEOF+it_SIZEOF,d2
		bsr.s	FreeGad
		bsr.s	FreeGad
		moveq	#gg_SIZEOF+it_SIZEOF,d2
		moveq	#(4+8)-1,d7
1$		bsr.s	FreeGad
		dbf	d7,1$
		move.l	FirstIGadget(a5),d4
		moveq	#gg_SIZEOF+ig_SIZEOF,d2
		moveq	#5,d7
2$		bsr.s	FreeGad
		dbf	d7,2$
		moveq	#gg_SIZEOF+it_SIZEOF,d2
		bsr.s	FreeGad
		moveq	#gg_SIZEOF,d2
		moveq	#5,d7
3$		bsr.s	FreeGad
		dbf	d7,3$
		rts
FreeGad		tst.l	d4
		beq.s	1$
		move.l	d4,a4
		move.l	gg_NextGadget(a4),d4
		move.l	d2,d0
		move.l	a4,a1
		jsr	FreeMem(a6)
1$		rts

FindGadStruct_1	move.l	FirstGadget(a5),a0	; 0-
		subq.b	#1,d0
1$		move.l	gg_NextGadget(a0),a0
		dbf	d0,1$
		rts
		endm

_GadgetData	macro
GadgetIDs	dc.w	100,101,102,103
		dc.w	111,112,113,114,115,116,117,118
		dc.w	31,30,32,33,34,35,1,41,40,42,43,44,45

Dev0_txt	dc.b	'DF0:',0
Dev1_txt	dc.b	'DF1:',0
Dev2_txt	dc.b	'RAM:',0
Dev3_txt	dc.b	'DH0:',0

Opt_txt		dc.b	"© MpL'94",0
First_txt	dc.b	'FIRST',0
		cnop	0,2
		endm
