OpenLibrary	= -552
CloseLibrary	= -414
OpenWindow	= -204
CloseWindow	= -72
WBToFront	= -342
WBToBack	= -336
GetMsg		= -372
ReplyMsg	= -378
WaitPort	= -384
DrawImage	= -114

;--------------------------------------;

	bsr.b	OpenLib
	bsr.b	OpenWin
	bsr.w	DrawImg
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

DrawImg	move.l	IntBase(pc),a6
	move.l	WinHD1(pc),a0
	move.l	50(a0),a0
	lea	Image(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	jsr	DrawImage(a6)
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

Image	dc.w	6,12			;X & Y
	dc.w	64,10			;Width & Height
	dc.w	2			;Bitplanes
	dc.l	ImgData			;Data
	dc.b	3,1			;Colours
	dc.l	0			;Next

;--------------------------------------;

IntName	dc.b	"intuition.library",0
IntBase	dc.l	0

	SECTION	"Image Data",DATA_C
ImgData	dc.l	$ffcffffc,$fffcffff,$03cc333c,$f03cf00f
	dc.l	$3fcc33fc,$ff0cfcff,$3ccc333c,$0f0cf0cf
	dc.l	$30cc330c,$030cc0c3,$30cff30c,$0f0cc0c3
	dc.l	$00cff3ff,$ff0cff03,$00c00000,$000c0003
	dc.l	$00c00000,$000c0003,$00000000,$00000000
	dc.l	$c0cc000c,$c00cc003,$03003330,$3030300c
	dc.l	$30c000cc,$c300c0c3,$0c000030,$0c00300c
	dc.l	$00000000,$00000000,$3003c000,$0c0000c0
	dc.l	$000c300f,$0300c300,$00000000,$00000000
	dc.l	$00c00000,$000c0003,$00c00000,$000c0003
