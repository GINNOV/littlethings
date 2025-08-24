;---- Exec Equates

OpenLibrary	= -552
CloseLibrary	= -414
AllocMem	= -198
FreeMem		= -210
GetMsg		= -372
ReplyMsg	= -378
WaitPort	= -384

;---- Intuition Equates

OpenWindow	= -204
CloseWindow	= -72
WBToFront	= -342
WBToBack	= -336
DrawBorder	= -108
DrawImage	= -114
RefreshGadgets	= -222
SetWindowTitles	= -276

;---- Graphics Equates

ScrollRaster	= -396
Move		= -240
Text		= -60
SetAPen		= -342

;---- ReqTools Equates

AllocRequestA	= -30
FreeRequest	= -36
FileRequestA	= -54
Window		= 1+(1<<31)
Underscore	= 11+(1<<31)
OKText		= 42+(1<<31)
ReqFSave	= 2

;---- Dos Equates

Open		= -30
Close		= -36
Read		= -42
Write		= -48
Lock		= -84
UnLock		= -90
Examine		= -102
Output		= -60

;-------------------;

GadText	MACRO
	dc.l	\1			;Next
	dc.w	\2,\3			;X & Y
	dc.w	\4,\5			;Width & Height
	dc.w	2			;Flags
	dc.w	1			;Activation Flags
	dc.w	1			;Type
	dc.l	\6			;Select1
	dc.l	\7			;Select2
	dc.l	\8			;Text
	dc.l	0			;Exclude
	dc.l	0			;SpecialInfo
	dc.w	\9			;Gadget ID
	dc.l	0			;User Data
	ENDM

;-------------------;

IText	MACRO
	dc.b	\4,\5			;Colours
	dc.b	\6			;Mode
	even
	dc.w	\2,\3			;X & Y
	dc.l	\7			;Font
	dc.l	\8			;Text
	dc.l	\1			;Next
	ENDM

;-------------------;

IImage	MACRO
	dc.w	\2,\3			;X & Y
	dc.w	\4,\5			;Width & Height
	dc.w	\7			;Bitplanes
	dc.l	\8			;Data
	dc.b	\6,0			;Colours
	dc.l	\1			;Next
	ENDM

;-------------------;

Border	MACRO
	dc.w	\1,\2			;X & Y
	dc.b	\5,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	Coords1\@		;Coords
	dc.l	Border2\@		;Next

Border2\@
	dc.w	\1,\2			;X & Y
	dc.b	\6,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	Coords2\@		;Coords
	dc.l	\7			;Next

Coords1\@
	dc.w	1,1
	dc.w	1,\4-2
	dc.w	0,\4-1
	dc.w	0,0
	dc.w	\3-2,0

Coords2\@
	dc.w	\3-2,\4-2
	dc.w	\3-2,1
	dc.w	\3-1,0
	dc.w	\3-1,\4-1
	dc.w	1,\4-1
	ENDM

;--------------------------------------;

	bsr.b	OpenReq
	bsr.b	OpenInt
	bsr.b	OpenGfx
	bsr.w	OpenDos
	bsr.w	OpenWin
	bsr.w	DrawBdr
	bsr.w	DrawImg
	lea	MsWlcme(pc),a5
	bsr	PrntMsg
	bsr.w	WB2Frnt
	bra.w	WaitEvt

End	bsr.w	FleFree
	bsr.w	WB2Back
	bsr.w	ClseWin
	bsr.b	OpenDos
	bsr.b	OpenGfx
	bsr.b	ClseInt
	bsr.b	ClseReq
	rts

;--------------------------------------;

OpenReq	move.l	4.w,a6
	moveq	#38,d0
	lea	ReqBase(pc),a1
	jsr	OpenLibrary(a6)
	move.l	d0,ReqBase
	rts

ClseReq	move.l	4.w,a6
	move.l	ReqBase(pc),a1
	jsr	CloseLibrary(a6)
	rts

;--------------------------------------;

OpenInt	move.l	4.w,a6
	moveq	#0,d0
	lea	IntBase(pc),a1
	jsr	OpenLibrary(a6)
	move.l	d0,IntBase
	rts

ClseInt	move.l	4.w,a6
	move.l	IntBase(pc),a1
	jsr	CloseLibrary(a6)
	rts

;--------------------------------------;

OpenGfx	move.l	4.w,a6
	moveq	#0,d0
	lea	GfxBase(pc),a1
	jsr	OpenLibrary(a6)
	move.l	d0,GfxBase
	rts

ClseGfx	move.l	4.w,a6
	move.l	GfxBase(pc),a1
	jsr	CloseLibrary(a6)
	rts

;--------------------------------------;

OpenDos	move.l	4.w,a6
	moveq	#0,d0
	lea	DosBase(pc),a1
	jsr	OpenLibrary(a6)
	move.l	d0,DosBase
	rts

ClseDos	move.l	4.w,a6
	move.l	DosBase(pc),a1
	jsr	CloseLibrary(a6)
	rts

;--------------------------------------;

OpenWin	move.l	IntBase(pc),a6
	lea	WinDef1(pc),a0
	jsr	OpenWindow(a6)
	move.l	d0,WinHD1
	move.l	d0,LWindow
	move.l	d0,SWindow
	move.l	d0,a0
	move.l	50(a0),RstPort
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
	move.l	RstPort(pc),a0
	lea	SBrder1(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	jsr	DrawBorder(a6)
	rts

;--------------------------------------;

DrawImg	move.l	IntBase(pc),a6
	move.l	RstPort(pc),a0
	lea	SImage1(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	jsr	DrawImage(a6)
	rts

;--------------------------------------;

ScrlRst	move.l	GfxBase(pc),a6
	move.l	RstPort(pc),a1
	moveq	#0,d0
	moveq	#8,d1
	moveq	#18,d2
	moveq	#64,d3
	move.l	#621,d4
	move.l	#120,d5
	jsr	ScrollRaster(a6)
	rts

;--------------------------------------;

PrntMsg	movem.l	d0-a6,-(a7)
	bsr.b	ScrlRst
	move.l	RstPort(pc),a1
	moveq	#0,d0
	move.b	(a5)+,d0
	jsr	SetAPen(a6)
	move.l	a5,a0
	moveq	#0,d7
FStrLng	addq.b	#1,d7
	tst.b	(a0)+
	bne.b	FStrLng
	subq.b	#1,d7
	move.l	d7,d6
	lsl.w	#2,d7
	move.l	#320,d0
	sub.w	d7,d0
	move.l	RstPort(pc),a1
	moveq	#118,d1
	jsr	Move(a6)
	move.l	RstPort(pc),a1
	move.l	a5,a0
	move.l	d6,d0
	jsr	Text(a6)
	movem.l	(a7)+,d0-a6
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

;--------------------------------------;

FindGad	move.l	28(a1),a0
	move.w	38(a0),d7
	jsr	ReplyMsg(a6)
	cmp.w	#"L",d7
	beq.b	LoadFle
	cmp.w	#"C",d7
	beq.w	Convert
	bra.b	WaitEvt

;--------------------------------------;

LoadFle	bsr.w	LRquest
	bne.b	WaitEvt
	bsr.w	FleFree
	bsr.b	FleExst
	bne.b	WaitEvt
	bsr.b	FndLgth
	bne.b	WaitEvt
	bsr.w	GtRdMem
	bne.b	WaitEvt
	bsr.w	FleRead
	bne.b	.9
	bsr.w	CFormat
	bne.b	.10
	bsr.w	PrntFmt
.9	bra.b	WaitEvt
.10	lea	MsNoFmt(pc),a5
	bsr.w	PrntMsg
	bsr.w	FleFree
	move.l	#-1,MFormat
	bra.w	WaitEvt

;-------------------;

FleExst	move.l	DosBase(pc),a6
	move.l	#RealNme,d1
	moveq	#-2,d2
	jsr	Lock(a6)
	move.l	d0,FleLock
	bne.b	.1
	lea	MsNoFle(pc),a5
	bsr.w	PrntMsg
	moveq	#-1,d0
	bra.b	.2
.1	moveq	#0,d0
.2	tst.l	d0
	rts

;-------------------;

FndLgth	move.l	DosBase(pc),a6
	move.l	FleLock(pc),d1
	move.l	#InfoBlk,d2
	jsr	Examine(a6)
	move.l	FleLock(pc),d1
	jsr	UnLock(a6)
	lea	InfoBlk,a0
	move.l	124(a0),d0
	move.l	d0,FleSize
	bne.b	.1
	lea	MsEmpty(pc),a5
	bsr.w	PrntMsg
	moveq	#-1,d0
	bra.b	.2
.1	moveq	#0,d0
.2	tst.l	d0
	rts

;--------------------------------------;

GtRdMem	move.l	4.w,a6
	move.l	FleSize(pc),d0
	move.l	#$10000,d1
	jsr	AllocMem(a6)
	move.l	d0,FleAllc
	bne.b	.1
	lea	MsNoMem(pc),a5
	bsr.w	PrntMsg
	moveq	#-1,d0
	bra.b	.2
.1	moveq	#0,d0
.2	tst.l	d0
	rts

;--------------------------------------;

FleFree	tst.l	FleAllc
	beq.b	.1
	move.l	4.w,a6
	move.l	FleAllc(pc),a1
	move.l	FleSize(pc),d0
	jsr	FreeMem(a6)
	moveq	#0,d0
	move.l	d0,FleAllc
.1	rts

;--------------------------------------;

FleRead	move.l	DosBase(pc),a6
	move.l	#RealNme,d1
	move.l	#1005,d2
	jsr	Open(a6)
	move.l	d0,FleName
	bne.b	.1
	lea	MsNoOpn(pc),a5
	bsr.w	PrntMsg
	bra.b	.4

.1	move.l	DosBase(pc),a6
	move.l	FleName(pc),d1
	move.l	FleAllc(pc),d2
	move.l	FleSize(pc),d3
	jsr	Read(a6)
	tst.l	d0
	bpl.b	.2

	move.l	FleName(pc),d1
	jsr	Close(a6)
	lea	MsNRead(pc),a5
	bsr.w	PrntMsg
	bra.b	.4

.2	move.l	FleName(pc),d1
	jsr	Close(a6)
	moveq	#0,d0
.3	tst.l	d0
	rts
.4	moveq	#-1,d0
	bra.b	.3

;--------------------------------------;

LRquest	move.l	ReqBase(pc),a6
	tst.l	FileReq
	bne.b	.1
	moveq	#0,d0
	sub.l	a0,a0
	jsr	AllocRequestA(a6)
	move.l	d0,FileReq
	bne.b	.1
	lea	MsNoMem(pc),a5
	bsr.w	PrntMsg
	bra.b	.4

.1	move.l	FileReq(pc),a1
	lea	TagLstL(pc),a0
	lea	FlsName(pc),a2
	lea	LoadTxt(pc),a3
	jsr	FileRequestA(a6)
	tst.l	d0
	bne.b	.2
	lea	MsNoSel(pc),a5
	bsr.w	PrntMsg
	bra.b	.4
.2	bsr.b	JoinFle
	moveq	#0,d0
.3	tst.l	d0
	rts
.4	moveq	#-1,d0
	bra.b	.3

;-------------------;

SRquest	move.l	ReqBase(pc),a6
	tst.l	FileReq
	bne.b	.1
	moveq	#0,d0
	sub.l	a0,a0
	jsr	AllocRequestA(a6)
	move.l	d0,FileReq
	bne.b	.1
	lea	MsNoMem(pc),a5
	bsr.w	PrntMsg
	bra.b	.4

.1	move.l	FileReq(pc),a1
	lea	TagLstS(pc),a0
	lea	FlsName(pc),a2
	lea	SaveTxt(pc),a3
	jsr	FileRequestA(a6)
	tst.l	d0
	bne.b	.2
	lea	MsNoSel(pc),a5
	bsr.w	PrntMsg
	bra.b	.4
.2	bsr.w	JoinFle
	moveq	#0,d0
.3	tst.l	d0
	rts
.4	moveq	#-1,d0
	bra.b	.3

;--------------------------------------;

JoinFle	move.l	FileReq(pc),a0
	move.l	16(a0),a0
	lea	RealNme(pc),a1
	tst.b	(a0)
	beq.b	.2
.1	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.b	.1
	cmp.b	#":",-1(a1)
	beq.b	.2
	move.b	#"/",(a1)+
.2	lea	FlsName(pc),a0
	tst.b	(a0)
	beq.b	.4
.3	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.b	.3
.4	move.b	#0,(a1)
	rts

;--------------------------------------;

CFormat	lea	ChkList(pc),a6
	moveq	#0,d7
	bra.b	.2
.1	addq.l	#4,d7
.2	tst.l	(a6)
	bne.b	.3
	moveq	#-1,d0
	bra.b	.4
.3	move.l	FleAllc(pc),a0
	move.l	(a6)+,a1
	jsr	(a1)
	tst.l	d0
	bne.b	.1
	move.l	d7,MFormat
	moveq	#0,d0
.4	tst.l	d0
	rts

;--------------------------------------;

PrntFmt	lea	MsNthng(pc),a5
	bsr.w	PrntMsg
	lea	MsFmtFd(pc),a5
	bsr.w	PrntMsg
	move.l	MFormat(pc),d0
	lea	FmtList(pc),a0
	lea	(a0,d0),a0
	move.l	(a0),a5
	bsr.w	PrntMsg
	rts

;--------------------------------------;

Convert	move.l	MFormat(pc),d0
	bmi.b	.50
	tst.l	FleAllc
	beq.b	.50

	bsr.b	GtCnMem
	bne.w	WaitEvt
	lea	MsCnvtg(pc),a5
	bsr.w	PrntMsg
	lea	CnvList(pc),a0
	move.l	(a0,d0),a0
	jsr	(a0)
	bsr.w	SRquest
	bne.w	.1
	bsr.b	WrteMod
	bne	.1
	lea	MsWrtOK(pc),a5
	bsr	PrntMsg
.1	bsr.b	WrkFree
	bra.w	WaitEvt

.50	lea	MsHmNah(pc),a5
	bsr.w	PrntMsg
	bra.w	WaitEvt

;--------------------------------------;

GtCnMem	lea	LenList(pc),a0
	move.l	(a0,d0),a0
	jsr	(a0)
	move.l	d0,WrkSize
	move.l	4.w,a6
	move.l	#$10000,d1
	jsr	AllocMem(a6)
	move.l	d0,WrkSpce
	bne.b	.1
	lea	MsNoMem(pc),a5
	bsr.w	PrntMsg
	moveq	#-1,d0
	bra.b	.2
.1	moveq	#0,d0
.2	tst.l	d0
	rts

;--------------------------------------;

WrkFree	move.l	4.w,a6
	move.l	WrkSpce(pc),a1
	move.l	WrkSize(pc),d0
	jsr	FreeMem(a6)
	rts

;--------------------------------------;

WrteMod	move.l	DosBase(pc),a6
	move.l	#RealNme,d1
	move.l	#1006,d2
	jsr	Open(a6)
	move.l	d0,FleName
	bne.b	.1
	lea	MsNWrte(pc),a5
	bsr.w	PrntMsg
	bra.b	.3
.1	move.l	d0,d1
	move.l	WrkSpce(pc),d2
	move.l	WrkSize(pc),d3
	jsr	Write(a6)
	move.l	FleName(pc),d1
	jsr	Close(a6)
	moveq	#0,d0
.2	tst.l	d0
	rts
.3	moveq	#-1,d0
	bra.b	.2

;--------------------------------------;

LenList	dc.l	np3_Len
CnvList	dc.l	np3_Cnv
ChkList	dc.l	np3_Chk
	dc.l	0

;--------------------------------------;

NP3_Inc	include	"DH1:ModDepackers/NoisePacker3.i"

;--------------------------------------;

RstPort	dc.l	0
WinHD1	dc.l	0
WinDef1	dc.w	0,11			;X & Y
	dc.w	640,140			;Width & Height
	dc.b	0,1			;Colours
	dc.l	$240			;IDCMP
	dc.l	$100e			;Flags
	dc.l	GadLOAD			;Gadgets
	dc.l	0			;CheckMark
	dc.l	WTitle			;Title
	dc.l	0			;Screen
	dc.l	0			;BitMap
	dc.w	50,50			;X & Y Min
	dc.w	640,256			;X & Y Max
	dc.w	1			;Type
WTitle	dc.b	"Sonic Conv 1.0  -  Copyright © 1994 by Frantic, Freeware",0,0

;--------------------------------------;

GadLOAD	GadText	GadCONV,16,122,85,14,GBrder1,GBrder2,GdTLOAD,"L"
GdTLOAD	IText	0,27,3,1,0,0,0,GdLOADT
GadCONV	GadText	0,101,122,85,14,GBrder1,GBrder2,GdTCONV,"C"
GdTCONV	IText	0,15,3,1,0,0,0,GdCONVT

;--------------------------------------;

GBrder1	Border	0,0,85,14,2,1,0
GBrder2	Border	0,0,85,14,1,2,0

SBrder1	Border	16,62,608,60,2,1,0

;--------------------------------------;

SImage1	IImage	0,56,12,528,45,3,7,SncCnvI

;--------------------------------------;

LdGText	dc.b	"_Load",0
SvGText	dc.b	"_Save",0
LoadTxt	dc.b	"Choose A File To Load",0
SaveTxt	dc.b	"Choose A File To Save",0

MsNthng	dc.b	0,"Sonic Conv",0
MsWlcme	dc.b	2,"Start converting",0
MsHmNah	dc.b	1,"Hmm, Nah...",0
MsNoMem	dc.b	1,"Out of memory",0
MsNoSel	dc.b	1,"No file selected",0
MsNoFle	dc.b	1,"File doesnt exist",0
MsEmpty	dc.b	1,"File is empty",0
MsNoOpn	dc.b	1,"Cant open file",0
MsNRead	dc.b	1,"Cant read file",0
MsNWrte	dc.b	1,"Cant write file",0
MsWrtOK	dc.b	1,"Module written OK",0
MsNoFmt	dc.b	1,"Unknown module format",0
MsFmtFd	dc.b	1,"Module format recognised as",0
MsCnvtg	dc.b	1,"Converting",0
FmtNP3	dc.b	2,"NoisePacker 3.0",0

GdLOADT	dc.b	"LOAD",0
GdCONVT	dc.b	"CONVERT",0
	even
FileReq	dc.l	0
FleLock	dc.l	0
FleName	dc.l	0
FleAllc	dc.l	0
FleSize	dc.l	0
WrkSpce	dc.l	0
WrkSize	dc.l	0
MFormat	dc.l	-1
FmtList	dc.l	FmtNP3

;--------------------------------------;

PerTble	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113

;--------------------------------------;

IntBase	dc.b	"intuition.library",0
GfxBase	dc.b	"graphics.library",0,0
ReqBase	dc.b	"reqtools.library",0,0
DosBase	dc.b	"dos.library",0

;--------------------------------------;

TagLstL	dc.l	Window
LWindow	dc.l	0
	dc.l	Underscore,"_"
	dc.l	OKText,LdGText
	dc.l	0,0

;-------------------;

TagLstS	dc.l	Window
SWindow	dc.l	0
	dc.l	Underscore,"_"
	dc.l	OKText,SvGText
	dc.l	0,0

;-------------------;

FlsName	dcb.b	108,0
RealNme	dcb.b	200,0

;-------------------;

	SECTION	"Chip Data",DATA_C
InfoBlk	dcb.b	260,0
SncCnvI	incbin	"DH1:ModDepackers/SonicConv.raw"

	END
