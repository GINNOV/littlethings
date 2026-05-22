; Build modified Menu structures
; $VER: Include v1.00 / PH v2.58
; (C) Mika Lundell
;
; This source code is part of the PopHelp package.
; Freeware, use it as you like.
;
	; a3=ThisMenu, a2=ThisItem
	; d3=SubItemY, d4=ItemY
	; d5=ItemWidth, d6=UsualFlags

_BuildMenus	macro
BuildMenus	lea	MenuNames(pc),a4
		lea	CommSeqs(pc),a6
		moveq	#ITEMENABLED!ITEMTEXT!HIGHCOMP!COMMSEQ,d6

CreaMenu0	bsr	AddMenu			; Pop
		moveq	#60+COMMWIDTH,d5
		bsr	AddItem
		move.b	(a6)+,mi_Command(a2)
		bsr	AddItem
		addq.w	#2,mi_TopEdge(a2)
		move.w	#ITEMENABLED!ITEMTEXT!HIGHBOX,mi_Flags(a2)

CreaMenu1	bsr	AddMenu			; Commands
		moveq	#85+COMMWIDTH,d5
		moveq	#9,d7
1$		bsr	AddItem
		move.b	(a6)+,mi_Command(a2)
		dbf	d7,1$
		moveq	#ITEMENABLED!ITEMTEXT!HIGHCOMP,d6
		bsr	AddItem
		move.w	#42,SubItemWidth(a5)
		bsr	AddSubItem
		bsr	AddSubItem
		bsr	AddSubItem

CreaMenu2	bsr	AddMenu			; Disk
		moveq	#67,d5
		moveq	#3,d7
1$		bsr	AddItem
		dbf	d7,1$

CreaMenu3	bsr	AddMenu			; Special
		moveq	#110,d5
		bsr	AddItem
		moveq	#ITEMENABLED!ITEMTEXT,d6
		move.w	#177,SubItemWidth(a5)
		bsr	AddSubItem
		addq.b	#2,it_FrontPen(a1)
		moveq	#4,d7
1$		bsr	AddSubItem
		dbf	d7,1$
		bsr	AddSubItem
		addq.b	#2,it_FrontPen(a1)
		bsr	AddSubItem
		bsr	AddSubItem

		moveq	#ITEMENABLED!ITEMTEXT!HIGHCOMP,d6
		bsr	AddItem
		moveq	#ITEMENABLED!ITEMTEXT!HIGHCOMP!COMMSEQ,d6
		bsr	AddItem
		move.b	(a6)+,mi_Command(a2)
		moveq	#ITEMENABLED!ITEMTEXT!HIGHCOMP,d6

CreaMenu4	move.l	a6,-(sp)
		lea	MutualExs(pc),a6
		moveq	#CHECKWIDTH,d2
		bsr	AddMenu			; Preferences
		moveq	#107,d5
		bsr	AddItem
		move.w	#86,SubItemWidth(a5)
		moveq	#ITEMENABLED!ITEMTEXT!HIGHCOMP!CHECKIT,d6
		bsr	AddSubItem
		ori.w	#CHECKED,mi_Flags(a2)
		add.w	d2,it_LeftEdge(a1)
		move.w	(a6)+,mi_MutualExclude+2(a2)
		bsr	AddSubItem
		add.w	d2,it_LeftEdge(a1)
		move.w	(a6)+,mi_MutualExclude+2(a2)

		moveq	#ITEMENABLED!ITEMTEXT!HIGHCOMP,d6
		bsr	AddItem
		moveq	#ITEMENABLED!ITEMTEXT!HIGHCOMP!CHECKIT,d6
		move.w	#54,SubItemWidth(a5)
		bsr	AddSubItem
	;	ori.w	#CHECKED,mi_Flags(a2)
		add.w	d2,it_LeftEdge(a1)
		move.w	(a6)+,mi_MutualExclude+2(a2)
		bsr	AddSubItem
		add.w	d2,it_LeftEdge(a1)
		move.w	(a6)+,mi_MutualExclude+2(a2)

		moveq	#ITEMENABLED!ITEMTEXT!HIGHCOMP,d6
		bsr	AddItem
		moveq	#ITEMENABLED!ITEMTEXT!HIGHCOMP!CHECKIT,d6
		move.w	#110,SubItemWidth(a5)
		bsr	AddSubItem
	;	ori.w	#CHECKED,mi_Flags(a2)
		add.w	d2,it_LeftEdge(a1)
		move.w	(a6)+,mi_MutualExclude+2(a2)
		bsr	AddSubItem
		add.w	d2,it_LeftEdge(a1)
		move.w	(a6)+,mi_MutualExclude+2(a2)

		moveq	#ITEMENABLED!ITEMTEXT!HIGHCOMP,d6
		bsr	AddItem
		moveq	#ITEMENABLED!ITEMTEXT!HIGHCOMP!CHECKIT,d6
		move.w	#77,SubItemWidth(a5)
		bsr	AddSubItem
		ori.w	#CHECKED,mi_Flags(a2)
		add.w	d2,it_LeftEdge(a1)
		move.w	(a6)+,mi_MutualExclude+2(a2)
		bsr	AddSubItem
		add.w	d2,it_LeftEdge(a1)
		move.w	(a6)+,mi_MutualExclude+2(a2)

		move.w	#ITEMENABLED!ITEMTEXT!HIGHCOMP!CHECKIT!CHECKED!MENUTOGGLE,d6
		bsr	AddItem
		moveq	#ITEMENABLED!ITEMTEXT!HIGHCOMP,d6
		bsr	AddItem
		move.l	(sp)+,a6

MoveVectorsTxts	tst.b	MenuError(a5)
		bne.s	3$
		move.w	#$302,d0
		bsr	FindMenuStruct
		move.l	a0,a2
		lea	_ColdCaptureBuf(a5),a3

		moveq	#4,d7
		bsr.s	1$
		move.l	mi_NextItem(a2),a2
		moveq	#1,d7
		bsr.s	1$
		rts

1$		move.l	mi_SIZEOF+it_IText(a2),a0
		move.l	a3,mi_SIZEOF+it_IText(a2)
		move.l	a3,a1
2$		move.b	(a0)+,(a1)+
		bne.s	2$
		move.l	mi_NextItem(a2),a2
		lea	14+9(a3),a3
		dbf	d7,1$
3$		rts

AddSubItem	tst.b	MenuError(a5)
		bne.s	MAddError
		moveq	#mi_SIZEOF+it_SIZEOF,d0
		bsr	Alloc_menu
		beq.s	MAddError
		move.l	d0,a2
		move.l	PrevSubItem(a5),a0
		move.w	SubItemWidth(a5),mi_Width(a2)	; Do these in
		move.l	a2,PrevSubItem(a5)		; both cases...
		move.l	a0,d0
		beq.s	BeginSubItem

AnotherSubItem	move.l	a2,mi_NextItem(a0)
		move.w	mi_LeftEdge(a0),mi_LeftEdge(a2)
		move.w	d3,mi_TopEdge(a2)
		addi.w	#10,d3
		bra.s	TheDefault

BeginSubItem	move.l	PrevItem(a5),a0
		move.l	a2,mi_SubItem(a0)
		move.w	d5,d0
		subi.w	#19,d0
		move.w	d0,mi_LeftEdge(a2)
		addi.w	#10,d3
		bra.s	TheDefault

MAddError	move.l	Err_pad(a5),a2
		move.l	a2,a1
		rts

TheDefault	move.w	#10,mi_Height(a2)
		move.w	d6,mi_Flags(a2)
		subq.w	#1,mi_NextSelect(a2)
		lea	mi_SIZEOF(a2),a1
		move.l	a1,mi_ItemFill(a2)
		addq.b	#1,it_BackPen(a1)	; Only in RP_JAM2?
		move.l	#$00010001,it_LeftEdge(a1)
		lea	TextAttr(pc),a0
		move.l	a0,it_ITextFont(a1)
		move.l	a4,it_IText(a1)
		bsr	NxtName_Width
		rts

AddItem		clr.l	PrevSubItem(a5)
		clr.w	SubItemWidth(a5)
		moveq	#0,d3
		tst.b	MenuError(a5)
		bne.s	MAddError
		moveq	#mi_SIZEOF+it_SIZEOF,d0
		bsr	Alloc_menu
		beq.s	MAddError
		move.l	d0,a2
		move.l	PrevItem(a5),a0
		move.w	d5,mi_Width(a2)		; Do these in
		move.l	a2,PrevItem(a5)		; both cases...
		move.l	a0,d0
		beq.s	BeginItem

AnotherItem	move.l	a2,mi_NextItem(a0)
		move.w	d4,mi_TopEdge(a2)
		addi.w	#10,d4
		bra.s	TheDefault

BeginItem	move.l	PrevMenu(a5),a3
		move.l	a2,mu_FirstItem(a3)
		addi.w	#10,d4
		bra	TheDefault

AddMenu		clr.l	PrevItem(a5)
		moveq	#0,d4
		tst.b	MenuError(a5)
		bne	MAddError
		moveq	#mu_SIZEOF,d0
		bsr	Alloc_menu
		beq	MAddError
		move.l	d0,a3
		move.l	PrevMenu(a5),a0
		move.l	a0,d0
		beq.s	BeginMenu

AnotherMenu	move.l	a3,mu_NextMenu(a0)
		move.w	mu_LeftEdge(a0),d0
		add.w	mu_Width(a0),d0
		addi.w	#10,d0
		move.w	d0,mu_LeftEdge(a3)
		bra.s	TheMenuDefault

BeginMenu	addq.w	#1,mu_LeftEdge(a3)
		move.l	a3,FirstMenu(a5)

TheMenuDefault	addq.w	#1,mu_TopEdge(a3)
		move.l	a4,mu_MenuName(a3)
		bsr	NxtName_Width
		addq.w	#8,d1
		move.w	d1,mu_Width(a3)
		move.w	#10,mu_Height(a3)
		move.l	a3,PrevMenu(a5)
		rts

NxtName_Width	moveq	#0,d1
1$		addq.b	#1,d1
		tst.b	(a4)+
		bne.s	1$
		subq.b	#1,d1
		lsl.l	#3,d1		; Len of txt in pixels
		rts

Alloc_menu	move.l	a6,-(sp)
		move.l	$4,a6
		move.l	#MEMF_CLEAR!MEMF_PUBLIC,d1
		jsr	AllocMem(a6)
		move.l	(sp)+,a6
		tst.l	d0
		bne.s	1$
		addq.b	#1,MenuError(a5)
		tst.l	d0
1$		rts

SmashMenus	move.l	$4,a6
		move.l	FirstMenu(a5),d0
		beq.s	NoMenusAtAll
		move.l	d0,a3
NxtMenu		move.l	mu_FirstItem(a3),d0
		beq.s	FreeMenu
		move.l	d0,a2

FreeItem	move.l	mi_NextItem(a2),d2
		move.l	mi_SubItem(a2),d4
		moveq	#mi_SIZEOF+it_SIZEOF,d0
		move.l	a2,a1
		jsr	FreeMem(a6)
		move.l	d4,a4
		tst.l	d4
		bne.s	FreeSubItem
		move.l	d2,a2
		tst.l	d2
		bne.s	FreeItem
		bra.s	FreeMenu

FreeSubItem	move.l	mi_NextItem(a4),d4		; No SubSubItems!...
		moveq	#mi_SIZEOF+it_SIZEOF,d0
		move.l	a4,a1
		jsr	FreeMem(a6)
		move.l	d4,a4
		tst.l	d4
		bne.s	FreeSubItem
		move.l	d2,a2
		tst.l	d2
		bne.s	FreeItem

FreeMenu	move.l	mu_NextMenu(a3),d3
		moveq	#mu_SIZEOF,d0
		move.l	a3,a1
		jsr	FreeMem(a6)
		move.l	d3,a3
		tst.l	d3
		bne.s	NxtMenu
NoMenusAtAll	rts

FindMenuStruct	movem.l	d1/d5-d7,-(sp)	; (First)Menu0=0, (First)Item=0
		moveq	#$000f,d1	; BUT (First)SubItem=1 !!! (0=NoSIs)
		move.w	d0,d5
		and.w	d1,d5	; SubItem 1-
		lsr.w	#4,d0
		move.w	d0,d6
		and.w	d1,d6	; Item 0-
		lsr.w	#4,d0
		move.w	d0,d7
		and.w	d1,d7	; Menu 0-

		move.l	FirstMenu(a5),a0
		tst.w	d7
		beq.s	MenuZero
		subq.w	#1,d7
1$		move.l	mu_NextMenu(a0),a0
		dbf	d7,1$
MenuZero	move.l	mu_FirstItem(a0),a0
		tst.w	d6
		beq.s	ItemZero
		subq.w	#1,d6
1$		move.l	mi_NextItem(a0),a0
		dbf	d6,1$
ItemZero	tst.w	d5
		beq.s	SubItemZero		; No SubItems at all...
		move.l	mi_SubItem(a0),a0
		subq.w	#1,d5
		beq.s	SubItemZero
		subq.w	#1,d5
1$		move.l	mi_NextItem(a0),a0
		dbf	d5,1$
SubItemZero	movem.l	(sp)+,d1/d5-d7
		rts
		endm

_MenuData	macro
MenuNames	dc.b	'Pop',0
		dc.b	'About',0
		dc.b	'Quit',0

		dc.b	'Commands',0
		dc.b	'Copy',0
IText102	dc.b	'ReName',0
IText103	dc.b	'Delete',0
		dc.b	'Move',0
IText105	dc.b	'MakeDir',0
IText106	dc.b	'Protect',0
		dc.b	'Dir',0
IText110	dc.b	'Execute',0
IText111	dc.b	'FileNote',0
		dc.b	'Type',0
		dc.b	'SetClock    »',0
		dc.b	'Load',0
		dc.b	'Save',0
		dc.b	'Reset',0

		dc.b	'Disk',0
		dc.b	'ReLabel',0
IText202	dc.b	'Install',0
		dc.b	'Format',0
		dc.b	'DiskCopy',0

		dc.b	'Special',0
		dc.b	'Vectors     »',0
		dc.b	'Reset Vectors:',0
		dc.b	' ColdCapture $',0
		dc.b	' CoolCapture $',0
		dc.b	' WarmCapture $',0
		dc.b	' KickMemPtr  $',0
		dc.b	' KickTagPtr  $',0
		dc.b	'IO Vectors:',0
		dc.b	' DoIO        $',0
		dc.b	' SendIO      $',0
		dc.b	'Make .fastdir',0
		dc.b	'ShowGfx',0

		dc.b	'Preferences',0
		dc.b	'CopyBuffer  »',0
		dc.b	'AutoSize',0
		dc.b	'SetSize',0
		dc.b	'ScreenMode  »',0
		dc.b	'PAL',0
		dc.b	'NTSC',0
		dc.b	'Borders     »',0
		dc.b	'White/Black',0
		dc.b	'Black/White',0
		dc.b	'MarkBADD    »',0
		dc.b	'Tracks',0
		dc.b	'Sectors',0
		dc.b	'   PH Pointer',0
		dc.b	' Save Prefs',0
CommSeqs	dc.b	'ACRZTMPDEFSG'
		cnop	0,2
MutualExs	dc.w	%10,%01
		dc.w	%10,%01,%10,%01,%10,%01
		endm
