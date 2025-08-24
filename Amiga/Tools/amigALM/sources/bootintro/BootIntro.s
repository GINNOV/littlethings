;-----------------------------------------------------------------------------;
;-------------   BOOT INTRO DESIGNER SOURCE BY ROBSTER IN 1993   -------------;
;-----------------------------------------------------------------------------;


;---- Exec Equates

OpenOldLib	= -408
CloseLib	= -414
WaitPort	= -384
GetMsg		= -372
ReplyMsg	= -378

;---- Intuition Equates

OpenWindow	= -204
CloseWindow	= -72
PrintIText	= -216
DrawImage	= -114
RefreshGadgets	= -222

;---- TrackDisk Equates

FindTask	= -294
AddPort		= -354
RemPort		= -360
OpenDevice	= -444
CloseDevice	= -450
DoIO		= -456

;---- BootBlock Equates

Forbid		= -132
Permit		= -138
InitBitmap	= -390
InitRastPort	= -198
SetAPen		= -342
Move		= -240
Text		= -60
ScrollRaster	= -396
FindResident	= -96

	SECTION	"Boot Designer",CODE_C

;--------------------------------------;

	bsr.b	OpenLib
	bsr.b	OpenDev
	bsr.b	OpenWin
	bsr.w	DrawImg
	bra.w	WaitEvt

End	bsr.w	ClseWin
	bsr.b	ClseDev
	bsr.b	ClseLib
	rts

;--------------------------------------;

OpenLib	move.l	4.w,a6
	lea	IntName(pc),a1
	jsr	OpenOldLib(a6)
	move.l	d0,IntBase
	rts

ClseLib	move.l	4.w,a6
	move.l	IntBase(pc),a1
	jsr	CloseLib(a6)
	rts

;--------------------------------------;

OpenDev	move.l	4.w,a6
	sub.l	a1,a1
	jsr	FindTask(a6)
	move.l	d0,RplyPrt+16
	lea	RplyPrt(pc),a1
	jsr	AddPort(a6)
	lea	DiskIO(pc),a1
	move.l	#RplyPrt,14(a1)
	moveq	#0,d0
	moveq	#0,d1
	lea	TrDName(pc),a0
	jsr	OpenDevice(a6)
	rts

ClseDev	move.l	4.w,a6
	lea	RplyPrt(pc),a1
	jsr	RemPort(a6)
	lea	DiskIO(pc),a1
	jsr	CloseDevice(a6)
	rts

;--------------------------------------;

OpenWin	move.l	IntBase(pc),a6
	lea	WinDef(pc),a0
	jsr	OpenWindow(a6)
	move.l	d0,WinHD
	rts

ClseWin	move.l	IntBase(pc),a6
	move.l	WinHD(pc),a0
	jsr	CloseWindow(a6)
	rts

;--------------------------------------;

DrawImg	move.l	WinHD(pc),a0
	move.l	50(a0),a0
	move.l	IntBase(pc),a6
	lea	Image(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	jsr	DrawImage(a6)
DrawEnd	rts

;--------------------------------------;

WaitEvt	move.l	4.w,a6
	move.l	WinHD(pc),a0
	move.l	86(a0),a0
	move.l	a0,-(a7)
	jsr	WaitPort(a6)
	move.l	(a7)+,a0
	jsr	GetMsg(a6)
	move.l	d0,a1
	move.l	20(a1),d0
	cmp.l	#$40,d0
	beq.b	FindGad
	bra.b	WaitEvt

;--------------------------------------;

FindGad	moveq	#0,d0
	move.l	28(a1),a0
	move.w	38(a0),d4
	move.l	4.w,a6
	jsr	ReplyMsg(a6)
	cmp.w	#1,d4
	beq.w	End
	cmp.w	#2,d4
	beq.b	Load
	cmp.w	#3,d4
	beq.w	Save
	cmp.w	#4,d4
	beq.w	PrgInfo
	cmp.w	#5,d4
	beq.w	ShowBB
	bra.b	WaitEvt

;--------------------------------------;

Load	move.l	4.w,a6
	lea	DiskIO(pc),a1
	move.w	#2,28(a1)		;Load
	move.l	#0,44(a1)		;Start
	move.l	#NewBoot,40(a1)		;Data
	move.l	#2*512,36(a1)		;Length
	jsr	DoIO(a6)
	move.w	#9,28(a1)		;Motor
	move.l	#0,36(a1)		;Length
	jsr	DoIO(a6)

	lea	NewBoot,a0
	cmp.l	#"ugra",544(a0)
	bne.b	WrgBoot
	lea	NewBoot+562,a0
	lea	ScrlTxt,a1
	move.l	#460,d0
	moveq	#0,d1
MoveTxt	move.b	(a0)+,(a1)+
	cmp.b	#0,(a0)
	bne.b	NxtMove
	move.w	d1,Chars
ClrRest	move.b	#0,(a1)+
	dbf	d0,ClrRest
	move.l	IntBase(pc),a6
	lea	Gadget6(pc),a0
	move.l	WinHD(pc),a1
	sub.l	a2,a2
	jsr	RefreshGadgets(a6)
	bra.w	WaitEvt
NxtMove	add.w	#1,d1
	dbf	d0,MoveTxt
WrgBoot	bra.w	WaitEvt

;--------------------------------------;

Save	lea	BBStart,a1
	moveq	#0,d1
	moveq	#0,d0
	move.l	d0,4(a1)
	move.w	#255,d0
	move.l	a1,a0
ChkSum1	add.l	(a0)+,d1
	bcc.b	ChkSum2
	addq	#1,d1
ChkSum2	dbf	d0,ChkSum1
	not.l	d1
	move.l	d1,4(a1)

	move.l	4.w,a6
	lea	DiskIO(pc),a1
	move.w	#3,28(a1)		;Write
	move.l	#0,44(a1)		;Start
	move.l	#BBStart,40(a1)		;Data
	move.l	#2*512,36(a1)		;Length
	jsr	DoIO(a6)
	move.w	#4,28(a1)		;Update
	move.l	#0,36(a1)		;Length
	jsr	DoIO(a6)
	move.w	#9,28(a1)		;Motor
	move.l	#0,36(a1)		;Length
	jsr	DoIO(a6)
	bra.w	WaitEvt

;--------------------------------------;

PrgInfo	move.l	IntBase(pc),a6
	lea	InfoDef(pc),a0
	jsr	OpenWindow(a6)
	move.l	d0,a0

	move.l	a0,-(a7)
	move.l	50(a0),a0
	lea	TextS1(pc),a1
	move.l	#0,d0
	move.l	#0,d1
	jsr	PrintIText(a6)

	move.l	(a7),a0
	move.l	86(a0),a0
	move.l	4.w,a6
	jsr	WaitPort(a6)
	move.l	(a7)+,a0
	move.l	IntBase(pc),a6
	jsr	CloseWindow(a6)
	bra.w	WaitEvt

;--------------------------------------;

ShowBB	move.l	4.w,a6
	lea	GfxName,a1
	jsr	OpenOldLib(a6)
	move.l	d0,a3
	move.l	$32(a3),OldCopp
	move.l	IntBase(pc),a0
	move.l	#0,68(a0)
	jsr	Start
	move.w	#"ic",DosName
	move.l	OldCopp(pc),$32(a3)
	move.l	4.w,a6
	move.l	a3,a1
	jsr	CloseLib(a6)
	bra.w	WaitEvt

;--------------------------------------;

InfoHD	dc.l	0
InfoDef	dc.w	160,100			;X Y Pos
	dc.w	320,50			;Width, Height
	dc.b	3,2			;Colours
	dc.l	$40			;IDCMPFlags
	dc.l	$11000			;ActivFlags
	dc.l	Gadget7			;Gadgets
	dc.l	0			;CheckMark
	dc.l	0			;Title
	dc.l	0			;Screen
	dc.l	0			;BitMap
	dc.w	640,200			;X and Y Min
	dc.w	640,200			;X and Y Max
	dc.w	1			;Type

;--------------------------------------;

WinHD	dc.l	0
WinDef	dc.w	0,0			;X Y Pos
	dc.w	640,200			;Width, Height
	dc.b	3,2			;Colours
	dc.l	$40			;IDCMPFlags
	dc.l	$11000			;ActivFlags
	dc.l	Gadget1			;Gadgets
	dc.l	0			;CheckMark
	dc.l	Title			;Title
	dc.l	0			;Screen
	dc.l	0			;BitMap
	dc.w	640,200			;X and Y Min
	dc.w	640,200			;X and Y Max
	dc.w	1			;Type
Title	dcb.b	30,32
	dc.b	"Boot-Intro Designer",0

;--------------------------------------;

Gadget1	dc.l	Gadget2			;Next gadget
	dc.w	6,12			;X and Y positions
	dc.w	39,12			;Width and Height
	dc.w	0			;Flags
	dc.w	1			;Activation flags
	dc.w	1			;Gadget type
	dc.l	TBrder1			;Pointer to border
	dc.l	0			;New gadget
	dc.l	Text1			;Text structure
	dc.l	0			;Exclude
	dc.l	0			;Special info
	dc.w	1			;ID
	dc.l	0			;User data

Gadget2	dc.l	Gadget3			;Next gadget
	dc.w	6,26			;X and Y positions
	dc.w	39,12			;Width and Height
	dc.w	0			;Flags
	dc.w	1			;Activation flags
	dc.w	1			;Gadget type
	dc.l	TBrder1			;Pointer to border
	dc.l	0			;New gadget
	dc.l	Text2			;Text structure
	dc.l	0			;Exclude
	dc.l	0			;Special info
	dc.w	2			;ID
	dc.l	0			;User data

Gadget3	dc.l	Gadget4			;Next gadget
	dc.w	6,40			;X and Y positions
	dc.w	39,12			;Width and Height
	dc.w	0			;Flags
	dc.w	1			;Activation flags
	dc.w	1			;Gadget type
	dc.l	TBrder1			;Pointer to border
	dc.l	0			;New gadget
	dc.l	Text3			;Text structure
	dc.l	0			;Exclude
	dc.l	0			;Special info
	dc.w	3			;ID
	dc.l	0			;User data

Gadget4	dc.l	Gadget5			;Next gadget
	dc.w	6,54			;X and Y positions
	dc.w	39,12			;Width and Height
	dc.w	0			;Flags
	dc.w	1			;Activation flags
	dc.w	1			;Gadget type
	dc.l	TBrder1			;Pointer to border
	dc.l	0			;New gadget
	dc.l	Text4			;Text structure
	dc.l	0			;Exclude
	dc.l	0			;Special info
	dc.w	4			;ID
	dc.l	0			;User data

Gadget5	dc.l	Gadget6			;Next gadget
	dc.w	6,68			;X and Y positions
	dc.w	39,12			;Width and Height
	dc.w	0			;Flags
	dc.w	1			;Activation flags
	dc.w	1			;Gadget type
	dc.l	TBrder1			;Pointer to border
	dc.l	0			;New gadget
	dc.l	Text5			;Text structure
	dc.l	0			;Exclude
	dc.l	0			;Special info
	dc.w	5			;ID
	dc.l	0			;User data

Gadget6	dc.l	0			;Next Gadget
	dc.w	14,180			;X and Y Position
	dc.w	619,10			;Width and Height
	dc.w	0			;Flags
	dc.w	$102			;Activation flags
	dc.w	4			;Gadget type
	dc.l	Border1			;Pointer to border
	dc.l	0			;Select Gadget
	dc.l	0			;Text
	dc.l	0			;Exclude
	dc.l	StrInfo			;Pointer to String Info
	dc.w	6			;Gadget ID
	dc.l	0			;User Data

Gadget7	dc.l	Gadget8			;Next gadget
	dc.w	6,35			;X and Y positions
	dc.w	39,12			;Width and Height
	dc.w	0			;Flags
	dc.w	1			;Activation flags
	dc.w	1			;Gadget type
	dc.l	TBrder1			;Pointer to border
	dc.l	0			;New gadget
	dc.l	Text7			;Text structure
	dc.l	0			;Exclude
	dc.l	0			;Special info
	dc.w	7			;ID
	dc.l	0			;User data

Gadget8	dc.l	0			;Next gadget
	dc.w	275,35			;X and Y positions
	dc.w	39,12			;Width and Height
	dc.w	0			;Flags
	dc.w	1			;Activation flags
	dc.w	1			;Gadget type
	dc.l	TBrder1			;Pointer to border
	dc.l	0			;New gadget
	dc.l	Text7			;Text structure
	dc.l	0			;Exclude
	dc.l	0			;Special info
	dc.w	7			;ID
	dc.l	0			;User data

;--------------------------------------;

TBrder1	dc.w	0,0			;X and Y offsets
	dc.b	1,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	TCoord1			;Pointer to table
	dc.l	TBrder2			;User data

TBrder2	dc.w	0,0			;X and Y offsets
	dc.b	2,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	TCoord2			;Pointer to table
	dc.l	0			;User data

TCoord1	dc.w	0,0
	dc.w	0,11
	dc.w	1,10
	dc.w	1,0
	dc.w	37,0

TCoord2	dc.w	38,11
	dc.w	38,0
	dc.w	37,1
	dc.w	37,11
	dc.w	1,11

;--------------------------------------;

Text1	dc.b	1,0			;Colours
	dc.b	1			;Mode
	even
	dc.w	4,2			;X and Y Offsets
	dc.l	0			;Standard Font
	dc.l	GText1			;Pointer to Text
	dc.l	0			;Next Text Struc

Text2	dc.b	1,0			;Colours
	dc.b	1			;Mode
	even
	dc.w	4,2			;X and Y Offsets
	dc.l	0			;Standard Font
	dc.l	GText2			;Pointer to Text
	dc.l	0			;Next Text Struc

Text3	dc.b	1,0			;Colours
	dc.b	1			;Mode
	even
	dc.w	4,2			;X and Y Offsets
	dc.l	0			;Standard Font
	dc.l	GText3			;Pointer to Text
	dc.l	0			;Next Text Struc

Text4	dc.b	1,0			;Colours
	dc.b	1			;Mode
	even
	dc.w	4,2			;X and Y Offsets
	dc.l	0			;Standard Font
	dc.l	GText4			;Pointer to Text
	dc.l	0			;Next Text Struc

Text5	dc.b	1,0			;Colours
	dc.b	1			;Mode
	even
	dc.w	4,2			;X and Y Offsets
	dc.l	0			;Standard Font
	dc.l	GText5			;Pointer to Text
	dc.l	0			;Next Text Struc

Text7	dc.b	1,0			;Colours
	dc.b	1			;Mode
	even
	dc.w	4,2			;X and Y Offsets
	dc.l	0			;Standard Font
	dc.l	GText7			;Pointer to Text
	dc.l	0			;Next Text Struc

;--------------------------------------;

StrInfo	dc.l	SclText			;Text buffer
	dc.l	0			;Undo buffer
	dc.w	0			;Cursor Position
	dc.w	461			;Max Number of Chars Visible
	dc.w	0			;Output Text from this character
	dc.w	0			;Character position in Undo buffer
Chars	dc.w	0			;Number of characters in text buffer
	dc.w	77			;Number of characters visible in box
	dc.w	0			;Horizontal Box Offset
	dc.w	0			;Vertical Box Offset
	dc.l	0			;Pointer to RastPort
	dc.l	0			;Long word with value of the input
	dc.l	0			;Standard Keyboard Table

;--------------------------------------;

Border1	dc.w	0,0			;Offsets
	dc.b	1,0			;Colours
	dc.b	0			;Border Mode
	dc.b	5			;Number of Pairs
	dc.l	Coord1			;Coordinates
	dc.l	Border2			;Next Structure

Border2	dc.w	0,0			;Offsets
	dc.b	1,0			;Colours
	dc.b	0			;Border Mode
	dc.b	5			;Number of Pairs
	dc.l	Coord2			;Coordinates
	dc.l	Border3			;Next Structure

Border3	dc.w	0,0			;Offsets
	dc.b	2,0			;Colours
	dc.b	0			;Border Mode
	dc.b	5			;Number of Pairs
	dc.l	Coord3			;Coordinates
	dc.l	Border4			;Next Structure

Border4	dc.w	0,0			;Offsets
	dc.b	2,0			;Colours
	dc.b	0			;Border Mode
	dc.b	5			;Number of Pairs
	dc.l	Coord4			;Coordinates
	dc.l	0			;Next Structure

Coord1	dc.w	 -6,-1
	dc.w	 -6, 8
	dc.w	 -7, 9
	dc.w	 -7,-2
	dc.w	619,-2

Coord2	dc.w	617, 7
	dc.w	617, 0
	dc.w	618,-1
	dc.w	618, 8
	dc.w	 -4, 8

Coord3	dc.w	619, 8
	dc.w	619,-1
	dc.w	620,-2
	dc.w	620, 9
	dc.w	 -6, 9

Coord4	dc.w	 -4, 0
	dc.w	 -4, 7
	dc.w	 -5, 8
	dc.w	 -5,-1
	dc.w	617,-1

;--------------------------------------;

TextS1	dc.b	1,0			;Colour
	dc.b	0,0			;Mode in first byte
	dc.w	4,2			;X Y Offsets
	dc.l	0			;Font
	dc.l	InfTxt1			;Pointer to Text
	dc.l	TextS2			;Next Text

TextS2	dc.b	1,0			;Colour
	dc.b	0,0			;Mode in first byte
	dc.w	8,10			;X Y Offsets
	dc.l	0			;Font
	dc.l	InfTxt2			;Pointer to Text
	dc.l	TextS3			;Next Text

TextS3	dc.b	1,0			;Colour
	dc.b	0,0			;Mode in first byte
	dc.w	8,18			;X Y Offsets
	dc.l	0			;Font
	dc.l	InfTxt3			;Pointer to Text
	dc.l	TextS4			;Next Text

TextS4	dc.b	1,0			;Colour
	dc.b	0,0			;Mode in first byte
	dc.w	4,26			;X Y Offsets
	dc.l	0			;Font
	dc.l	InfTxt4			;Pointer to Text
	dc.l	0			;Next Text

;--------------------------------------;

Image	dc.w	160,40			;X and Y Offsets
	dc.w	417,52			;Width and Height
	dc.w	2			;Bitplanes
	dc.l	ImgData			;Pointer to Data
	dc.b	3,1			;Foreground/Background colours
	dc.l	0			;Next Image

;--------------------------------------;

GText1	dc.b	"QUIT",0,0
GText2	dc.b	"LOAD",0,0
GText3	dc.b	"SAVE",0,0
GText4	dc.b	"INFO",0,0
GText5	dc.b	"SHOW",0,0
GText7	dc.b	" OK ",0,0
InfTxt1	dc.b	"---------------------------------------",0
InfTxt2	dc.b	"Boot-Intro Designer by Robster in 1993 ",0
InfTxt3	dc.b	"   Spread me, I wanna see the world!   ",0
InfTxt4	dc.b	"---------------------------------------",0
IntName	dc.b	"intuition.library",0
IntBase	dc.l	0
OldCopp	dc.l	0
TrDName	dc.b	"trackdisk.device",0,0
RplyPrt	dcb.l	8,0
DiskIO	dcb.l	20,0

	SECTION	"Graphics and TrackDisk Stuff",DATA_C
ImgData	incbin	"DH2:BootIntro/BootIntro.raw"
NewBoot	dcb.b	1024,0

;---------------------------------------;
;	      BootBlock Code		;
;---------------------------------------;

BBStart	dc.b	'DOS',0
	dc.l	0,880

Start	movem.l	d0-a6,-(a7)
	jsr	Forbid(a6)
	lea	$dff000,a5

	moveq	#0,d0
	moveq	#-1,d0
	lea	$70000,a0
	move.l	a0,a3
	move.l	a0,a4
	add.l	#$400,a4
ClrMem	move.b	#0,(a0)+
	dbf	d0,ClrMem

	lea	SinTble(pc),a0
	lea	SinePnt(pc),a1
	move.l	a0,(a1)

	lea	GfxName(pc),a1
	jsr	OpenOldLib(a6)
	move.l	d0,a6

	lea	CList(pc),a1
	move.l	a1,$32(a6)
	move.w	#$8300,$96(a5)

	move.l	a3,a0
	moveq	#1,d0
	move.l	#652,d1
	moveq	#10,d2
	jsr	InitBitmap(a6)

	move.l	a4,8(a3)
	move.l	a3,a1
	add.l	#$100,a1
	jsr	InitRastPort(a6)

	move.l	a3,a1
	add.l	#$104,a1
	move.l	a3,(a1)
	add.l	#$100,a3

	moveq	#1,d0
	move.l	a3,a1
	jsr	SetAPen(a6)

NewLine	lea	ScrlTxt(pc),a1
	lea	ScrlPnt(pc),a2
	move.l	a1,(a2)

GetPos	move.l	a3,a1
	move.l	#640,d0
	moveq	#8,d1
	jsr	Move(a6)

	lea	ScrlPnt(pc),a2
	move.l	(a2),a0
	addq.l	#1,(a2)
	moveq	#1,d0
	cmp.b	#0,(a0)
	beq.b	NewLine

ScrllIt	move.l	a3,a1
	jsr	Text(a6)
	moveq	#8,d7
DoScrl	cmp.b	#$ff,6(a5)
	bne.b	DoScrl

	lea	SinePnt(pc),a0
	lea	ScrlPos(pc),a1
	move.l	(a0),a0
	move.b	(a0)+,(a1)
	cmp.b	#$ff,(a0)
	bne.b	MoveSin
	sub.l	#SineEnd-SinTble,a0
MoveSin	lea	SinePnt(pc),a1
	move.l	a0,(a1)

	move.l	a3,a1
	moveq	#1,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.l	#656,d4
	moveq	#10,d5
	jsr	ScrollRaster(a6)
	btst	#6,$bfe001
	beq.b	Mouse
	dbf	d7,DoScrl
	bra.b	GetPos

Mouse	lea	CList2(pc),a0
	move.l	a0,$32(a6)
	movem.l	(a7)+,d0-a6
	jsr	Permit(a6)

	lea	DosName(pc),a1
	move.w	#"do",(a1)
	jsr	FindResident(a6)
	move.l	d0,a0
	move.l	$16(a0),a0
	moveq	#0,d0
	rts

;--------------------------------------;

ScrlPnt	dc.l	0
SinePnt	dc.l	0

;--------------------------------------;

SinTble	dc.b	$90,$90,$90,$90,$90,$91,$91,$91,$92,$92
	dc.b	$93,$93,$94,$94,$95,$96,$96,$97,$98,$99
	dc.b	$9a,$9b,$9c,$9d,$9e,$9f,$a0,$a1,$a2,$a4
	dc.b	$a5,$a6,$a7,$a9,$aa,$ab,$ad,$ae,$b0,$b1
	dc.b	$b3,$b4,$b6,$b7,$b9,$ba,$bc,$bd,$bf,$c0
	dc.b	$c0,$bf,$bd,$bc,$ba,$b9,$b7,$b6,$b4,$b3
	dc.b	$b1,$b0,$ae,$ad,$ab,$aa,$a9,$a7,$a6,$a5
	dc.b	$a4,$a2,$a1,$a0,$9f,$9e,$9d,$9c,$9b,$9a
	dc.b	$99,$98,$97,$96,$96,$95,$94,$94,$93,$93
	dc.b	$92,$92,$91,$91,$91,$90,$90,$90,$90,$90
SineEnd	dc.b	$ff,$00

;--------------------------------------;

CList	dc.w	$008e,$2981,$0090,$29c1
	dc.w	$0092,$003c,$0094,$00d4
	dc.w	$0108,$0002,$010a,$0002

	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0fff,$0186,$0fff

	dc.w	$8d09,$fffe,$0180,$0f22
	dc.w	$8e09,$fffe,$0180,$0422
	dc.w	$8f09,$fffe,$0180,$0622

ScrlPos	dc.w	$9009,$fffe
	dc.w	$0100,$a200,$0102,$0001
	dc.w	$00e0,$0007,$00e2,$0400
	dc.w	$00e4,$0007,$00e6,$0452

	dc.w	$cb09,$fffe,$0180,$0422
	dc.w	$cc09,$fffe,$0180,$0f22
	dc.w	$cd09,$fffe
CList2	dc.w	$0100,$0200
	dc.w	$0102,$0000,$0180,$0000
	dc.w	$ffff,$fffe

;--------------------------------------;

Idntify	dc.b	"u"
GfxName	dc.b	"graph"
DosName	dc.b	"ics.library",0
ScrlTxt	dc.b	32
SclText	dc.b	"Robster presents the Boot-Intro Designer...                  "
	dcb.b	400,0
BBEnd
