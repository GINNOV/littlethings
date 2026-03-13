OpenLibrary	= -552
CloseLibrary	= -414
OpenWindow	= -204
CloseWindow	= -72
WBToFront	= -342
WBToBack	= -336
GetMsg		= -372
ReplyMsg	= -378
WaitPort	= -384
SetMenuStrip	= -264
ClearMenuStrip	= -54

;--------------------------------------;

	bsr.b	OpenLib
	bsr.b	OpenWin
	bsr.w	SetMenu
	bsr.b	WB2Frnt
	bra.w	WaitEvt

End	bsr.b	WB2Back
	bsr.w	ClrMenu
	bsr.b	ClseWin
	bsr.b	ClseLib
	rts

;--------------------------------------;

OpenLib	move.l	4.w,a6
	moveq	#0,d0
	lea	IntName(pc),a1
	jsr	OpenLibrary(a6)
	move.l	d0,IntBase
	rts

ClseLib	move.l	4.w,a6
	move.l	IntBase(pc),a1
	jsr	CloseLibrary(a6)
	rts

;--------------------------------------;

OpenWin	move.l	IntBase(pc),a6
	lea	WinDef1(pc),a0
	jsr	OpenWindow(a6)
	move.l	d0,WinHD1
	rts

ClseWin	move.l	IntBase(pc),a6
	move.l	WinHD1(pc),a0
	jsr	CloseWindow(a6)
	rts

;--------------------------------------;

WB2Frnt	move.l	IntBase(pc),a6
	move.l	WinHD1(pc),a0
	jsr	WBToFront(a6)
	rts

WB2Back	move.l	IntBase(pc),a6
	move.l	WinHD1(pc),a0
	jsr	WBToBack(a6)
	rts

;--------------------------------------;

SetMenu	move.l	IntBase(pc),a6
	move.l	WinHD1(pc),a0
	lea	Menu(pc),a1
	jsr	SetMenuStrip(a6)
	rts

ClrMenu	move.l	IntBase(pc),a6
	move.l	WinHD1(pc),a0
	jsr	ClearMenuStrip(a6)
	rts

;--------------------------------------;

WaitEvt	move.l	4.w,a6
	move.l	WinHD1(pc),a0
	move.l	86(a0),a0
	move.l	a0,-(a7)
	jsr	WaitPort(a6)
	move.l	(a7)+,a0
	jsr	GetMsg(a6)
	move.l	d0,a1
	move.l	20(a1),d6
	cmp.l	#$200,d6
	beq.w	End
	cmp.l	#$100,d6
	beq.b	ChkMenu
	jsr	ReplyMsg(a6)
	bra.b	WaitEvt

;--------------------------------------;

ChkMenu	moveq	#0,d0
	move.w	24(a1),d7
	jsr	ReplyMsg(a6)

	move.w	d7,$70000
	cmp.w	#(-1)<<11+(0)<<5+(0),d7		;SubMenu,MenuItem,Menu
	beq	LedChng
	bra	WaitEvt

LedChng	bchg	#1,$bfe001
	bra	WaitEvt

;--------------------------------------;

WinHD1	dc.l	0
WinDef1	dc.w	0,0			;X & Y
	dc.w	640,50			;Width & Height
	dc.b	0,1			;Colours
	dc.l	$300			;IDCMP
	dc.l	$100f			;Flags
	dc.l	0			;Gadgets
	dc.l	0			;CheckMark
	dc.l	Title			;Title
	dc.l	0			;Screen
	dc.l	0			;BitMap
	dc.w	640,50			;X & Y Min
	dc.w	640,256			;X & Y Max
	dc.w	1			;Type
Title	dc.b	"Windows Title",0

;--------------------------------------;

Menu
MNPrjc	dc.l	0			;Next
	dc.w	0,0			;X & Y
	dc.w	(7*8)+16,10		;Width & Height
	dc.w	1			;Enabled
	dc.l	MNPrjcT			;Text
	dc.l	MIZpSc			;Menu Item
	dc.w	0,0,0,0			;Reserved

;------------------;

MIZpSc	dc.l	MIOldS			;Next
	dc.w	0,0*8			;X & Y
	dc.w	(14*8),8		;Width & Height
	dc.w	$52			;Flags
	dc.l	0			;Exclude
	dc.l	MITZpSc			;Text
	dc.l	0			;ItemFill
	dc.b	0			;HotKey
	even
	dc.l	0			;SubMenu Item
	dc.l	0			;Next Select
MITZpSc	dc.b	2,0			;Colours
	dc.b	0			;Mode
	even
	dc.w	0,0			;X & Y
	dc.l	0			;Font
	dc.l	MIZpScT			;Text
	dc.l	0			;Next

;------------------;

MIOldS	dc.l	MIRead			;Next
	dc.w	0,1*8			;X & Y
	dc.w	(14*8),8		;Width & Height
	dc.w	$52			;Flags
	dc.l	0			;Exclude
	dc.l	MITOldS			;Text
	dc.l	0			;ItemFill
	dc.b	0			;HotKey
	even
	dc.l	0			;SubMenu Item
	dc.l	0			;Next Select
MITOldS	dc.b	2,0			;Colours
	dc.b	0			;Mode
	even
	dc.w	0,0			;X & Y
	dc.l	0			;Font
	dc.l	MIOldST			;Text
	dc.l	0			;Next

;------------------;

MIRead	dc.l	0			;Next
	dc.w	0,2*8			;X & Y
	dc.w	(14*8),8		;Width & Height
	dc.w	$52			;Flags
	dc.l	0			;Exclude
	dc.l	MITRead			;Text
	dc.l	0			;ItemFill
	dc.b	0			;HotKey
	even
	dc.l	SMRSrc			;SubMenu Item
	dc.l	0			;Next Select
MITRead	dc.b	2,0			;Colours
	dc.b	0			;Mode
	even
	dc.w	0,0			;X & Y
	dc.l	0			;Font
	dc.l	MIReadT			;Text
	dc.l	0			;Next

SMRSrc	dc.l	SMRBin			;Next
	dc.w	(14*8)-16,0*8		;X & Y
	dc.w	(10*8),8		;Width & Height
	dc.w	$52			;Flags
	dc.l	0			;Exclude
	dc.l	SMTRSrc			;Text
	dc.l	0			;ItemFill
	dc.b	0			;HotKey
	even
	dc.l	0			;Nothing
	dc.l	0			;Next Select
SMTRSrc	dc.b	2,0			;Colours
	dc.b	0			;Mode
	even
	dc.w	0,0			;X & Y
	dc.l	0			;Font
	dc.l	SMRSrcT			;Text
	dc.l	0			;Next

SMRBin	dc.l	SMRObj			;Next
	dc.w	(14*8)-16,1*8		;X & Y
	dc.w	(10*8),8		;Width & Height
	dc.w	$52			;Flags
	dc.l	0			;Exclude
	dc.l	SMTRBin			;Text
	dc.l	0			;ItemFill
	dc.b	0			;HotKey
	even
	dc.l	0			;Nothing
	dc.l	0			;Next Select
SMTRBin	dc.b	2,0			;Colours
	dc.b	0			;Mode
	even
	dc.w	0,0			;X & Y
	dc.l	0			;Font
	dc.l	SMRBinT			;Text
	dc.l	0			;Next

SMRObj	dc.l	0			;Next
	dc.w	(14*8)-16,2*8		;X & Y
	dc.w	(10*8),8		;Width & Height
	dc.w	$52			;Flags
	dc.l	0			;Exclude
	dc.l	SMTRObj			;Text
	dc.l	0			;ItemFill
	dc.b	0			;HotKey
	even
	dc.l	0			;Nothing
	dc.l	0			;Next Select
SMTRObj	dc.b	2,0			;Colours
	dc.b	0			;Mode
	even
	dc.w	0,0			;X & Y
	dc.l	0			;Font
	dc.l	SMRObjT			;Text
	dc.l	0			;Next

;------------------;

MNPrjcT	dc.b	"Project",0
MIZpScT	dc.b	"Zap Source  ZS",0
MIOldST	dc.b	"Old         O",0
MIReadT	dc.b	"Read..",0
SMRSrcT	dc.b	"Source  R",0
SMRBinT	dc.b	"Binary  RB",0
SMRObjT	dc.b	"Object  RO",0
	even

;--------------------------------------;

IntName	dc.b	"intuition.library",0
IntBase	dc.l	0
