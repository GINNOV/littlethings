OpenLibrary	= -552
CloseLibrary	= -414
OpenWindow	= -204
CloseWindow	= -72
WBToFront	= -342
WBToBack	= -336
GetMsg		= -372
ReplyMsg	= -378
WaitPort	= -384
DrawBorder	= -108

;--------------------------------------;

	bsr.b	OpenLib
	bsr.b	OpenWin
	bsr.b	DrawBdr
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

DrawBdr	move.l	IntBase(pc),a6
	move.l	WinHD1(pc),a0
	move.l	50(a0),a0
	lea	GBrder1(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	jsr	DrawBorder(a6)
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
	cmp.l	#$40,d6
	beq.b	FindGad
	jsr	ReplyMsg(a6)
	bra.b	WaitEvt

FindGad	moveq	#0,d4
	move.l	28(a1),a0
	move.w	38(a0),d7
	jsr	ReplyMsg(a6)
	cmp.w	#0,d7
	beq.b	LedChng
	bra.b	WaitEvt

LedChng	bchg	#1,$bfe001
	bra.b	WaitEvt

;--------------------------------------;

WinHD1	dc.l	0
WinDef1	dc.w	0,0			;X & Y
	dc.w	640,50			;Width & Height
	dc.b	0,1			;Colours
	dc.l	$240			;IDCMP
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
	dc.w	6,12			;X & Y
	dc.w	(6*8)+28,12		;Width & Height
	dc.w	4			;Flags
	dc.w	3			;Activation Flags
	dc.w	1			;Type
	dc.l	GImage1			;Select1
	dc.l	0			;Select2
	dc.l	GdText1			;Text
	dc.l	0			;Exclude
	dc.l	0			;SpecialInfo
	dc.w	1			;Gadget ID
	dc.l	0			;User Data

GdText1	dc.b	1,0			;Colours
	dc.b	0			;Mode
	even
	dc.w	24,2			;X & Y
	dc.l	0			;Font
	dc.l	GadTxt1			;Text
	dc.l	0			;Next

;--------------------------------------;

GBrder1	dc.w	0,0			;X & Y
	dc.b	2,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	GCoord1			;Coords
	dc.l	GBrder2			;Next

GBrder2	dc.w	0,0			;X & Y
	dc.b	1,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	GCoord2			;Coords
	dc.l	0			;Next

GCoord1	dc.w	(6)+1,(12)+1
	dc.w	(6)+1,(12)+10
	dc.w	(6)+0,(12)+11
	dc.w	(6)+0,(12)
	dc.w	(6)+(6*8)+26,(12)

GCoord2	dc.w	(6)+(6*8)+26,(12)+10
	dc.w	(6)+(6*8)+26,(12)+1
	dc.w	(6)+(6*8)+27,(12)
	dc.w	(6)+(6*8)+27,(12)+11
	dc.w	(6)+1,(12)+11

;--------------------------------------;

GImage1	dc.w	6,1			;X & Y
	dc.w	16,9			;Width & Height
	dc.w	2			;Bitplanes
	dc.l	ImgNext			;Data
	dc.b	3,1			;Colours
	dc.l	0			;Next

;--------------------------------------;

GadTxt1	dc.b	"GADGET",0,0

;--------------------------------------;

IntName	dc.b	"intuition.library",0
IntBase	dc.l	0

	SECTION	"Chip Data",DATA_C
ImgNext	dc.w	%0111111100000010
	dc.w	%1100000110000010
	dc.w	%1100000110000010
	dc.w	%1100011111100010
	dc.w	%1100001111000010
	dc.w	%1100000110000010
	dc.w	%1100000000000010
	dc.w	%1100000110000010
	dc.w	%0111111100000010
	dc.w	%0000000000000001
	dc.w	%0000000000000001
	dc.w	%0000000000000001
	dc.w	%0000000000000001
	dc.w	%0000000000000001
	dc.w	%0000000000000001
	dc.w	%0000000000000001
	dc.w	%0000000000000001
	dc.w	%0000000000000001

