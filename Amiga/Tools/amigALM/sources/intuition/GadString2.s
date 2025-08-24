OpenLibrary	= -552
CloseLibrary	= -414
OpenWindow	= -204
CloseWindow	= -72
WBToFront	= -342
WBToBack	= -336
GetMsg		= -372
ReplyMsg	= -378
WaitPort	= -384

;--------------------------------------;

	bsr.b	OpenLib
	bsr.b	OpenWin
	bsr.b	WB2Frnt
	bra.w	WaitEvt

End	bsr.b	WB2Back
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
	jsr	ReplyMsg(a6)
	bra.b	WaitEvt

;--------------------------------------;

WinHD1	dc.l	0
WinDef1	dc.w	0,0			;X & Y
	dc.w	640,50			;Width & Height
	dc.b	0,1			;Colours
	dc.l	$200			;IDCMP
	dc.l	$100f			;Flags
	dc.l	Gadget1			;Gadgets
	dc.l	0			;CheckMark
	dc.l	Title			;Title
	dc.l	0			;Screen
	dc.l	0			;BitMap
	dc.w	640,50			;X & Y Min
	dc.w	640,256			;X & Y Max
	dc.w	1			;Type
Title	dc.b	"Windows Title",0

;--------------------------------------;

Gadget1	dc.l	0			;Next
	dc.w	12,14			;X & Y
	dc.w	10*8,8			;Width & Height
	dc.w	0			;Flags
	dc.w	1			;Activation Flags
	dc.w	4			;Type
	dc.l	SBrder1			;Select1
	dc.l	0			;Select2
	dc.l	0			;Text
	dc.l	0			;Exclude
	dc.l	StrInf1			;Special Info
	dc.w	1			;Gadget ID
	dc.l	0			;User Data

StrInf1	dc.l	StrBuf1			;Text Buffer
	dc.l	0			;Undo buffer
	dc.w	0			;Cursor Pos
	dc.w	50			;Max Chars
	dc.w	0			;Output Text From Char
	dc.w	0			;Char Position In Undo
	dc.w	0			;No. Chars In Text Buffer
	dc.w	0			;No. Chars Visible in Box
	dc.w	0			;Horz Box Offset
	dc.w	0			;Vert Box offset
	dc.l	0			;RastPort
	dc.l	0			;Longword Value
	dc.l	0			;Keyboard

;--------------------------------------;

SBrder1	dc.w	0,0			;X & Y
	dc.b	1,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	SCoord1			;Coords
	dc.l	SBrder2			;Next

SBrder2	dc.w	0,0			;X & Y
	dc.b	2,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	SCoord2			;Coords
	dc.l	SBrder3			;Next

SBrder3	dc.w	0,0			;X & Y
	dc.b	2,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	SCoord3			;Coords
	dc.l	SBrder4			;Next

SBrder4	dc.w	0,0			;X & Y
	dc.b	1,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	SCoord4			;Coords
	dc.l	0			;Next

SCoord1	dc.w	-3,0
	dc.w	-3,7
	dc.w	-4,8
	dc.w	-4,-1
	dc.w	(10*8)+2,-1

SCoord2	dc.w	(10*8)+2,7
	dc.w	(10*8)+2,0
	dc.w	(10*8)+3,-1
	dc.w	(10*8)+3,8
	dc.w	-3,8

SCoord3	dc.w	-5,-1
	dc.w	-5,8
	dc.w	-6,9
	dc.w	-6,-2
	dc.w	(10*8)+4,-2

SCoord4	dc.w	(10*8)+4,8
	dc.w	(10*8)+4,-1
	dc.w	(10*8)+5,-2
	dc.w	(10*8)+5,9
	dc.w	-5,9

;--------------------------------------;

StrBuf1	dcb.b	50,0

;--------------------------------------;

IntName	dc.b	"intuition.library",0
IntBase	dc.l	0

