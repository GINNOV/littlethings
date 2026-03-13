;---- Exec Equates

AllocMem	= -198
FreeMem		= -210
GetMsg		= -372
ReplyMsg	= -378
WaitPort	= -384
CloseLibrary	= -414
OpenLibrary	= -552

;---- Dos Equates

Open		= -30
Close		= -36
Read		= -42
Write		= -48
Seek		= -66
DeleteFile	= -72
Lock		= -84
UnLock		= -90
Examine		= -102
DateStamp	= -192

;---- Intuition Equates

CloseWindow	= -72
DrawBorder	= -108
DrawImage	= -114
ModifyIDCMP	= -150
OpenWindow	= -204
PrintIText	= -216
RefreshGadgets	= -222
WBToBack	= -336
WBToFront	= -342

;---- Graphics Equates

Text		= -60
Move		= -240
RectFill	= -306
SetAPen		= -342

;---- TrackDisk Equates

FindTask	= -294
AddPort		= -354
RemPort		= -360
OpenDevice	= -444
CloseDevice	= -450
DoIO		= -456
SendIO		= -462
WaitIO		= -474

;---- ReqTools Equates

AllocRequestA	= -30
FreeRequest	= -36
ChangeReqAttrA	= -48
FileRequestA	= -54
Window		= (1<<31)+1
Flags		= (1<<31)+40
MatchPat	= (1<<31)+51

;---- SHI BootBlock Equates

LoadBrain	= -30
CheckBoot	= -42

;---- DMS Compatiblity

Version		= 113
VersionNeeded	= 111

;--------------------------------------;

;	 00 Identifier
;	 04 DMS Type
;	 08 General Info
;	 12 Date
;	 16 Low Track
;	 18 High Track
;	 20 Packed Size
;	 24 Unpacked Size
;	 28 OS Version
;	 30 OS Revision
;	 32 Processor
;	 34 CoProcessor
;	 36 Machine Type
;	 38 Unused
;	 40 CPU Speed
;	 42 Creation Time
;	 46 Creator Version
;	 48 Version needed
;	 50 Disk Type
;	 52 Compression Mode
;	 54 InfoHeader CRC
;	 56 END

;--------------------------------------;

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

;--------------------------------------;

GadNull	MACRO
	dc.l	\1			;Next
	dc.w	\2,\3			;X & Y
	dc.w	\4,\5			;Width & Height
	dc.w	3			;Flags
	dc.w	1			;Activation Flags
	dc.w	1			;Type
	dc.l	0			;Select1
	dc.l	0			;Select2
	dc.l	0			;Text
	dc.l	0			;Exclude
	dc.l	0			;SpecialInfo
	dc.w	\6			;Gadget ID
	dc.l	0			;User Data
	ENDM

;--------------------------------------;

Border	MACRO				;NEXT,X,Y,W,H,L,S
	dc.w	\2,\3			;X & Y
	dc.b	\6,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	Coords1\@		;Coords
	dc.l	Border2\@		;Next

Border2\@
	dc.w	\2,\3			;X & Y
	dc.b	\7,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	Coords2\@		;Coords
	dc.l	\1			;Next

Coords1\@
	dc.w	1,1
	dc.w	1,\5-2
	dc.w	0,\5-1
	dc.w	0,0
	dc.w	\4-2,0

Coords2\@
	dc.w	\4-2,\5-2
	dc.w	\4-2,1
	dc.w	\4-1,0
	dc.w	\4-1,\5-1
	dc.w	1,\5-1
	ENDM

;--------------------------------------;

IText	MACRO
	dc.b	\4,\5			;Colours
	dc.b	\6			;Mode
	even
	dc.w	\2,\3			;X & Y
	dc.l	\7			;Font
	dc.l	\8			;Text
	dc.l	\1			;Next
	ENDM

;--------------------------------------;

IImage	MACRO
	dc.w	\2,\3			;X & Y
	dc.w	\4,\5			;Width & Height
	dc.w	\7			;Bitplanes
	dc.l	\8			;Data
	dc.b	\6,0			;Colours
	dc.l	\1			;Next
	ENDM

;--------------------------------------;

GadStrg	MACRO
	dc.l	\1			;Next
	dc.w	\2,\3			;X & Y
	dc.w	\4*8,8			;Width & Height
	dc.w	0			;Flags
	dc.w	1			;Activation Flags
	dc.w	4			;Type
	dc.l	\5			;Select1
	dc.l	0			;Select2
	dc.l	\6			;Text
	dc.l	0			;Exclude
	dc.l	StInf\@			;Special Info
	dc.w	\9			;Gadget ID
	dc.l	0			;User Data

StInf\@	dc.l	\7			;Text Buffer
	dc.l	0			;Undo buffer
	dc.w	0			;Cursor Pos
	dc.w	\8			;Max Chars
	dc.w	0			;Output Text From Char
	dc.w	0			;Char Position In Undo
	dc.w	0			;No. Chars In Text Buffer
	dc.w	0			;No. Chars Visible in Box
	dc.w	0			;Horz Box Offset
	dc.w	0			;Vert Box offset
	dc.l	0			;RastPort
	dc.l	0			;Longword Value
	dc.l	0			;Keyboard
	ENDM

;--------------------------------------;

	SECTION	"DiskMasher 1.13",CODE

	bsr.w	OpenLib
	bsr.w	LdBrain
	bsr.w	SrtPrfs
	bsr.w	OpenDev
	bsr.w	OpenWin
	bsr.w	DrawBdr
	bsr.w	DrawImg
	bsr.w	WB2Frnt
	bra.w	WaitEvt

End	bsr.b	PurgeRq
	bsr.w	WB2Back
	bsr.w	ClseWin
	bsr.w	ClseDev
	bsr.w	ClseLib
	rts

;--------------------------------------;

PurgeRq	tst.l	FFl1Req
	beq.s	.1
	move.l	FFl1Req(pc),a1
	move.l	ReqBase(pc),a6
	jsr	FreeRequest(a6)
.1	tst.l	FFl2Req
	beq.s	.2
	move.l	FFl2Req(pc),a1
	move.l	ReqBase(pc),a6
	jsr	FreeRequest(a6)
.2	tst.l	TFleReq
	beq.s	.3
	move.l	TFleReq(pc),a1
	move.l	ReqBase(pc),a6
	jsr	FreeRequest(a6)
.3	tst.l	FlDzReq
	beq.s	.4
	move.l	FlDzReq(pc),a1
	move.l	ReqBase(pc),a6
	jsr	FreeRequest(a6)
.4	rts

;--------------------------------------;

OpenLib	move.l	4.w,a6
	moveq	#0,d0
	lea	IntBase(pc),a1
	jsr	OpenLibrary(a6)
	move.l	d0,IntBase
	moveq	#0,d0
	lea	DosBase(pc),a1
	jsr	OpenLibrary(a6)
	move.l	d0,DosBase
	moveq	#0,d0
	lea	GfxBase(pc),a1
	jsr	OpenLibrary(a6)
	move.l	d0,GfxBase
	moveq	#0,d0
	lea	ReqBase(pc),a1
	jsr	OpenLibrary(a6)
	move.l	d0,ReqBase
	moveq	#0,d0
	lea	BtBBase(pc),a1
	jsr	OpenLibrary(a6)
	move.l	d0,BtBBase
	rts

ClseLib	move.l	4.w,a6
	move.l	BtBBase(pc),a1
	jsr	CloseLibrary(a6)
	move.l	ReqBase(pc),a1
	jsr	CloseLibrary(a6)
	move.l	GfxBase(pc),a1
	jsr	CloseLibrary(a6)
	move.l	DosBase(pc),a1
	jsr	CloseLibrary(a6)
	move.l	IntBase(pc),a1
	jsr	CloseLibrary(a6)
	rts

;--------------------------------------;

LdBrain	move.l	BtBBase(pc),a6
	lea	BtHndlr(pc),a0
	jsr	LoadBrain(a6)
	rts

;--------------------------------------;

OpenDev	tst.l	DevsPnt
	bne.b	.1
	bsr.w	FrstDev
	move.l	a0,DevsPnt
.1	move.l	4.w,a6
	sub.l	a1,a1
	jsr	FindTask(a6)
	lea	RplyPrt(pc),a1
	move.l	d0,16(a1)
	jsr	AddPort(a6)
	lea	DiskIO(pc),a1
	move.l	#RplyPrt,14(a1)
	move.l	DevsPnt(pc),a0
	move.l	28(a0),a2
	add.l	a2,a2
	add.l	a2,a2
	move.l	(a2),d0
	move.l	12(a2),d1
	move.l	4(a2),a0
	add.l	a0,a0
	add.l	a0,a0
	addq.l	#1,a0
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
	lea	WinDef1(pc),a0
	jsr	OpenWindow(a6)
	move.l	d0,WinHD1
	move.l	d0,FWindow

	move.l	GfxBase(pc),a6
	move.l	WinHD1(pc),a4
	move.l	50(a4),a1
	move.l	#257,d0
	moveq	#109,d1
	jsr	Move(a6)
	move.l	50(a4),a1
	moveq	#1,d0
	jsr	SetAPen(a6)
	move.l	50(a4),a1
	move.l	DevsPnt(pc),a0
	move.l	40(a0),a0
	add.l	a0,a0
	add.l	a0,a0
	addq.l	#1,a0
	moveq	#3,d0
	jsr	Text(a6)
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
	lea	SBrder1(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	jsr	DrawBorder(a6)
	rts

;--------------------------------------;

DrawImg	move.l	IntBase(pc),a6
	move.l	WinHD1(pc),a0
	move.l	50(a0),a0
	lea	DskImg1(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	jsr	DrawImage(a6)
	rts

;--------------------------------------;

PrntMsg	move.l	GfxBase(pc),a6
	move.l	WinHD1(pc),a4
	move.l	50(a4),a1
	moveq	#0,d0
	jsr	SetAPen(a6)
	move.l	50(a4),a1
	move.l	#8,d0
	move.l	#115,d1
	move.l	#499,d2
	move.l	#125,d3
	jsr	RectFill(a6)
	move.l	50(a4),a1
	moveq	#16,d0
	moveq	#123,d1
	jsr	Move(a6)
	move.l	50(a4),a1
	moveq	#1,d0
	jsr	SetAPen(a6)
	move.l	50(a4),a1
	move.l	a5,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	jsr	Text(a6)
	rts

;--------------------------------------;

SrtPrfs	move.l	DosBase(pc),a6
	lea	PrfNme1(pc),a5
	move.l	a5,d1
	moveq	#-2,d2
	jsr	Lock(a6)
	move.l	d0,d7
	bne.b	.1
	lea	PrfNme2(pc),a5
	move.l	a5,d1
	moveq	#-2,d2
	jsr	Lock(a6)
	move.l	d0,d7
	bne.b	.1
	move.l	d0,PrfSize
	rts

.1	move.l	d7,d1
	move.l	#InfoBlk,d2
	jsr	Examine(a6)
	move.l	d7,d1
	jsr	UnLock(a6)
	lea	InfoBlk,a0
	move.l	124(a0),d0
	move.l	d0,PrfSize
	bne.b	.2
	rts
.2	move.l	4.w,a6
	move.l	PrfSize(pc),d0
	move.l	#$10000,d1
	jsr	AllocMem(a6)
	move.l	d0,PrfAllc
	bne.b	.3
	rts
.3	move.l	DosBase(pc),a6
	move.l	a5,d1
	move.l	#1005,d2
	jsr	Open(a6)
	move.l	d0,FleHndl
	beq.w	.20
	move.l	d0,d1
	move.l	PrfAllc(pc),d2
	move.l	PrfSize(pc),d3
	jsr	Read(a6)

	lea	PrFleN1(pc),a0
	bsr.w	ChkOpts
	bne.b	.5
	lea	Fl1Bufr(pc),a1
.4	move.b	(a0)+,(a1)+
	cmp.b	#10,(a0)
	bne.b	.4
	clr.b	(a1)

.5	lea	PrFleN2(pc),a0
	bsr.w	ChkOpts
	bne.b	.7
	lea	Fl2Bufr(pc),a1
.6	move.b	(a0)+,(a1)+
	cmp.b	#10,(a0)
	bne.b	.6
	clr.b	(a1)

.7	lea	PrTxtFl(pc),a0
	bsr.w	ChkOpts
	bne.b	.9
	lea	TxtBufr(pc),a1
.8	move.b	(a0)+,(a1)+
	cmp.b	#10,(a0)
	bne.b	.8
	clr.b	(a1)

.9	lea	PrFleDz(pc),a0
	bsr.w	ChkOpts
	bne.b	.11
	lea	FDzBufr(pc),a1
.10	move.b	(a0)+,(a1)+
	cmp.b	#10,(a0)
	bne.b	.10
	clr.b	(a1)

.11	lea	PrTrack(pc),a0
	bsr.w	ChkOpts
	bne.b	.13
	lea	TrkBufr(pc),a1
.12	move.b	(a0)+,(a1)+
	cmp.b	#10,(a0)
	bne.b	.12
	clr.b	(a1)

.13	lea	PrCMode(pc),a0
	bsr.w	ChkOpts
	bne.b	.17
	lea	CrnchMd(pc),a1
	moveq	#0,d0
	moveq	#0,d1
.14	move.w	(a1)+,d0
	bmi.b	.17
	lsl.w	#3,d0
	lea	CrModes(pc),a3
	lea	(a3,d0),a3
	move.l	a0,a2
	move.l	a3,a4
.15	move.b	(a2)+,d0
	cmp.b	#10,d0
	beq.b	.16
	cmp.b	(a3)+,d0
	beq.b	.15
	addq.w	#1,d1
	bra.b	.14
.16	move.w	d1,CrnchPt
	lea	GTCMode(pc),a1
	move.l	a4,12(a1)

.17	lea	PrDrive(pc),a0
	bsr.w	ChkOpts
	bne.b	.19
.18	bsr.w	FindDev
	bne.b	.19
	move.l	a0,DevsPnt

.19	move.l	FleHndl(pc),d1
	jsr	Close(a6)
.20	move.l	4.w,a6
	move.l	PrfSize(pc),d0
	move.l	PrfAllc(pc),a1
	jsr	FreeMem(a6)
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
	cmp.l	#$20,d6
	beq.b	FindGad
	jsr	ReplyMsg(a6)
	bra.b	WaitEvt

;--------------------------------------;

FindGad	move.l	28(a1),a0
	move.w	38(a0),d7
	jsr	ReplyMsg(a6)
	cmp.w	#"RD",d7
	beq.w	ReadDMS
	cmp.w	#"TX",d7
	beq.w	TextDMS
	cmp.w	#"D1",d7
	beq.w	FleRqD1
	cmp.w	#"D2",d7
	beq.w	FleRqD2
	cmp.w	#"D3",d7
	beq.w	FleRqD3
	cmp.w	#"D4",d7
	beq.w	FleRqD4
	cmp.w	#"CM",d7
	beq.b	BtnCMde
	cmp.w	#"DV",d7
	beq.w	NxDrive
	cmp.w	#"N1",d7
	beq.w	SwapGd1
	cmp.w	#"N2",d7
	beq.w	SwapGd2
	bra.w	WaitEvt

;--------------------------------------;

BtnCMde	lea	CrnchMd(pc),a0
	lea	CrModes(pc),a1
	lea	GTCMode(pc),a2
	addq.w	#1,CrnchPt
	moveq	#0,d0
.1	move.w	CrnchPt(pc),d0
	lsl.w	#1,d0
	move.w	(a0,d0),d0
	lsl.w	#3,d0
	bpl.b	.2
	clr.w	CrnchPt
	bra.b	.1
.2	lea	(a1,d0),a5
	move.l	a5,12(a2)
	move.l	a5,a4
	moveq	#0,d7
	bra.b	.4
.3	addq.b	#1,d7
.4	tst.b	(a4)+
	bne.b	.3

	move.l	GfxBase(pc),a6
	move.l	WinHD1(pc),a4
	move.l	50(a4),a4
	move.l	a4,a1
	move.l	#245,d0
	moveq	#96,d1
	jsr	Move(a6)
	move.l	a4,a1
	moveq	#1,d0
	jsr	SetAPen(a6)
	move.l	a4,a1
	move.l	a5,a0
	move.l	d7,d0
	jsr	Text(a6)
	bra.w	BtnCycl
BtnDrve
BtnCycl	bra.w	WaitEvt

;--------------------------------------;

NxDrive	bsr.w	NextDev
	move.l	a0,DevsPnt
	bsr	ClseDev
	bsr	OpenDev
	move.l	GfxBase(pc),a6
	move.l	WinHD1(pc),a4
	move.l	50(a4),a1
	move.l	#257,d0
	moveq	#109,d1
	jsr	Move(a6)
	move.l	50(a4),a1
	moveq	#1,d0
	jsr	SetAPen(a6)
	move.l	50(a4),a1
	move.l	DevsPnt(pc),a0
	move.l	40(a0),a0
	add.l	a0,a0
	add.l	a0,a0
	addq.l	#1,a0
	moveq	#3,d0
	jsr	Text(a6)
	bra.w	WaitEvt

;--------------------------------------;

SwapGd1	move.l	GfxBase(pc),a6
	move.l	WinHD1(pc),a4
	move.l	50(a4),a1
	moveq	#16,d0
	moveq	#37,d1
	jsr	Move(a6)
	move.l	50(a4),a1
	moveq	#1,d0
	jsr	SetAPen(a6)
	lea	GdFlDsk(pc),a0
	cmp.l	#GdFile1,(a0)
	beq.b	.1
	move.l	#GdFile1,(a0)
	move.w	#"D1",38(a0)
	move.l	50(a4),a1
	lea	Fl1Text(pc),a0
	moveq	#8,d0
	jsr	Text(a6)
	bra.w	SwapUpd
.1	move.l	#GdFile2,(a0)
	move.w	#"D2",38(a0)
	move.l	50(a4),a1
	lea	Fl2Text(pc),a0
	moveq	#8,d0
	jsr	Text(a6)
	bra.b	SwapUpd

;-------------------;

SwapGd2	move.l	GfxBase(pc),a6
	move.l	WinHD1(pc),a4
	move.l	50(a4),a1
	moveq	#16,d0
	moveq	#52,d1
	jsr	Move(a6)
	move.l	50(a4),a1
	moveq	#1,d0
	jsr	SetAPen(a6)
	lea	GdTxDsk(pc),a0
	cmp.l	#GdTxtFl,(a0)
	beq.b	.1
	move.l	#GdTxtFl,(a0)
	move.w	#"D3",38(a0)
	move.l	50(a4),a1
	lea	TxtText(pc),a0
	moveq	#8,d0
	jsr	Text(a6)
	bra.b	SwapUpd
.1	move.l	#GdFleDz,(a0)
	move.w	#"D4",38(a0)
	move.l	50(a4),a1
	lea	FDzText(pc),a0
	moveq	#8,d0
	jsr	Text(a6)
	bra.w	SwapUpd

;-------------------;

SwapUpd	move.l	IntBase(pc),a6
	lea	GdFlDsk(pc),a0
	move.l	WinHD1(pc),a1
	sub.l	a2,a2
	jsr	RefreshGadgets(a6)
	bra.w	WaitEvt

;--------------------------------------;

FleRqD1	lea	FFl1Req(pc),a5
	lea	FFl1Nme(pc),a4
	lea	FFl1Pat(pc),a3
	bsr.w	FRquest
	bne.w	WaitEvt
	move.l	FFl1Req(pc),a0
	lea	Fl1Bufr(pc),a1
	lea	FFl1Nme(pc),a2
	bsr.w	JoinFle

	move.l	IntBase(pc),a6
	lea	GdFile1(pc),a0
	move.l	WinHD1(pc),a1
	sub.l	a2,a2
	jsr	RefreshGadgets(a6)
	bra.w	WaitEvt

;--------------------------------------;

FleRqD2	lea	FFl2Req(pc),a5
	lea	FFl2Nme(pc),a4
	lea	FFl2Pat(pc),a3
	bsr.w	FRquest
	bne.w	WaitEvt
	move.l	FFl2Req(pc),a0
	lea	Fl2Bufr(pc),a1
	lea	FFl2Nme(pc),a2
	bsr.w	JoinFle

	move.l	IntBase(pc),a6
	lea	GdFile2(pc),a0
	move.l	WinHD1(pc),a1
	sub.l	a2,a2
	jsr	RefreshGadgets(a6)
	bra.w	WaitEvt

;--------------------------------------;

FleRqD3	lea	TFleReq(pc),a5
	lea	TFlName(pc),a4
	lea	TFlPtrn(pc),a3
	bsr.w	FRquest
	bne.w	WaitEvt
	move.l	TFleReq(pc),a0
	lea	TxtBufr(pc),a1
	lea	TFlName(pc),a2
	bsr.w	JoinFle

	move.l	IntBase(pc),a6
	lea	GdTxtFl(pc),a0
	move.l	WinHD1(pc),a1
	sub.l	a2,a2
	jsr	RefreshGadgets(a6)
	bra.w	WaitEvt

;--------------------------------------;

FleRqD4	lea	FlDzReq(pc),a5
	lea	FDzName(pc),a4
	lea	FDzPtrn(pc),a3
	bsr.w	FRquest
	bne.w	WaitEvt
	move.l	FlDzReq(pc),a0
	lea	FDzBufr(pc),a1
	lea	FDzName(pc),a2
	bsr.w	JoinFle

	move.l	IntBase(pc),a6
	lea	GdFleDz(pc),a0
	move.l	WinHD1(pc),a1
	sub.l	a2,a2
	jsr	RefreshGadgets(a6)
	bra.w	WaitEvt

;--------------------------------------;
;--------------------------------------;

ReadDMS	move.l	DevsPnt(pc),a0
	move.l	40(a0),a0
	add.l	a0,a0
	add.l	a0,a0
	addq.l	#1,a0
	lea	JunkBuf(pc),a1
	move.b	#4,(a1)+
	moveq	#3-1,d0
.10	move.b	(a0)+,(a1)+
	dbf	d0,.10
	move.b	#":",(a1)+
	lea	TxtRDsk(pc),a0
	lea	JunkBuf(pc),a1
	bsr.w	Request
	tst.w	d0
	beq.w	WaitEvt

	move.l	4.w,a6
	lea	DiskIO(pc),a1
	move.w	#14,28(a1)		;ChangeState
	jsr	DoIO(a6)
	tst.l	32(a1)
	bne.b	ReadDMS

	move.l	DosBase(pc),a6
	move.l	#Fl1Bufr,d1
	moveq	#-2,d2
	jsr	Lock(a6)
	move.l	d0,d7
	move.l	d0,d1
	jsr	UnLock(a6)
	tst.l	d7
	beq.b	.1

	lea	TxtReq1(pc),a0
	lea	TxtReq2(pc),a1
	bsr.w	Request
	tst.w	d0
	beq.w	WaitEvt
	move.l	DosBase(pc),a6
	move.l	#Fl1Bufr,d1
	jsr	DeleteFile(a6)

.1	move.l	DosBase(pc),a6
	move.l	#Fl1Bufr,d1
	move.l	#1006,d2
	jsr	Open(a6)
	move.l	d0,FleHndl
	bne	.2
	lea	MsNWrte(pc),a5
	bsr	PrntMsg
	bra	WaitEvt

.2	move.w	#-1,CurrTrk
	bsr	GetTrSz
	lea	EncBufr(pc),a0
	bsr	FndEVal
	bsr.w	FndTrks
	bsr.w	SetUpHd

	bsr.w	OrgText
	bne	.99
	bsr	TestBrk
	bne	.4
	lea	MsAbort(pc),a5
	bsr	PrntMsg
	bra	.99

.3	addq.w	#1,CurrTrk
.4	lea	Tracks(pc),a0
	move.w	CurrTrk(pc),d0
	btst	#0,(a0,d0)
	beq	.5
	bsr	OrgTrck
	bsr	TestBrk
	bne	.5
	lea	MsAbort(pc),a5
	bsr	PrntMsg
	bra	.99

.5	cmp.w	#80,CurrTrk
	bne	.3

.99	bsr	OrgHead
	bsr	WrteHdr

	move.l	4.w,a6
	lea	DiskIO(pc),a1
	move.w	#9,28(a1)		;Motor
	move.l	#0,36(a1)		;Length
	jsr	DoIO(a6)

	move.l	DosBase(pc),a6
	move.l	FleHndl(pc),d1
	jsr	Close(a6)
	bra	WaitEvt

;--------------------------------------;

TestBrk	move.l	4.w,a6
	move.l	WinHD1(pc),a0
	move.l	86(a0),a0
	jsr	GetMsg(a6)
	move.l	d0,a1
	tst.l	d0
	beq.b	.5
	move.l	20(a1),d6
	move.w	24(a1),d7
	jsr	ReplyMsg(a6)
	cmp.l	#8,d6
	bne.b	TestBrk
	lea	MousChk(pc),a0
	cmp.w	#$68,d7
	bne.w	.1
	bset	#0,(a0)
.1	cmp.w	#$69,d7
	bne	.2
	bset	#1,(a0)
.2	cmp.w	#$e8,d7
	bne.w	.3
	bclr	#0,(a0)
.3	cmp.w	#$e9,d7
	bne	.4
	bclr	#1,(a0)
.4	cmp.b	#3,(a0)
	bne	.5

	lea	DiskIO(pc),a1
	move.w	#9,28(a1)		;Motor
	move.l	#0,36(a1)		;Length
	jsr	DoIO(a6)

	lea	TxtReq3(pc),a0
	lea	TxtReq4(pc),a1
	bsr.w	Request
	tst.w	d0
	bne	.5
	moveq	#0,d0
	bra.b	.6
.5	moveq	#-1,d0
.6	tst.l	d0
	rts

;--------------------------------------;

BootDsp	tst.w	CurrTrk
	bne.w	.5

	move.l	BtBBase(pc),a6
	move.l	UPckDat(pc),a0
	lea	JunkBuf(pc),a1
	jsr	CheckBoot(a6)
	move.l	d0,BtSttus
	move.l	JunkBuf(pc),d0
	cmp.l	#-1,d0
	beq	.5
	cmp.l	#2,d0
	beq	.5

	move.l	4.w,a6
	lea	DiskIO(pc),a1
	move.w	#9,28(a1)		;Motor
	move.l	#0,36(a1)		;Length
	jsr	DoIO(a6)
	move.l	WinHD1(pc),a1
	lea	WinDef2(pc),a0
	move.w	4(a1),d0
	move.w	6(a1),d1
	add.w	#123,d0
	add.w	#39,d1
;	move.w	d0,(a0)
;	move.w	d1,2(a0)
	move.l	IntBase(pc),a6
	jsr	OpenWindow(a6)
	move.l	d0,WinHD2
	move.l	d0,a0
	move.l	WinHD1(pc),a1
	move.l	86(a0),WinHD2+4
	move.l	86(a1),86(a0)

	move.l	50(a0),a0
	lea	BBrder1(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	jsr	DrawBorder(a6)

	move.l	UPckDat(pc),a0
	lea	BootBuf(pc),a1
	moveq	#0,d0
	move.w	#1024-1,d1
.loop	move.b	(a0)+,d0
	cmp.w	#$20,d0
	blt	.n1
	cmp.w	#$80,d0
	blt	.next
	cmp.w	#$a0,d0
	blt	.n1
.next	move.b	d0,(a1)+
	dbf	d1,.loop
	bra	.noloop
.n1	move.b	#".",d0
	bra	.next
.noloop
	move.l	GfxBase(pc),a6
	move.l	WinHD2(pc),a4
	move.l	50(a4),a1
	moveq	#1,d0
	jsr	SetAPen(a6)
	lea	BootBuf(pc),a5
	moveq	#35,d6
	moveq	#16-1,d7
.1	move.l	50(a4),a1
	move.l	#10,d0
	move.l	d6,d1
	jsr	Move(a6)
	move.l	50(a4),a1
	moveq	#64,d0
	move.l	a5,a0
	jsr	Text(a6)
	lea	64(a5),a5
	addq.l	#8,d6
	dbf	d7,.1

	move.l	GfxBase(pc),a6
	move.l	WinHD2(pc),a4
	move.l	50(a4),a1
	moveq	#0,d0
	jsr	SetAPen(a6)
	move.l	JunkBuf(pc),d0
	beq	.10
	cmp.l	#1,d0
	beq	.15
	bra	.2

.10	lea	BootTxt(pc),a1
	move.l	#0,16(a1)
	move.b	#1,(a1)
	move.l	#MsNoInf,12(a1)
	bra	.19

.15	move.l	GfxBase(pc),a6
	move.l	WinHD2(pc),a4
	move.l	50(a4),a1
	moveq	#3,d0
	jsr	SetAPen(a6)
	lea	BootTxt(pc),a1
	move.l	#VirTxt1,16(a1)
	move.b	#2,(a1)
	move.l	BtSttus(pc),a0
	addq.l	#4,a0
	move.l	a0,12(a1)

.19	move.l	GfxBase(pc),a6
	move.l	50(a4),a1
	move.l	#10,d0
	move.l	#14,d1
	move.l	#521,d2
	move.l	#25,d3
	jsr	RectFill(a6)

	lea	BootTxt(pc),a1
	move.l	12(a1),a2
	moveq	#0,d1
	bra	.191
.190	addq.w	#4,d1
.191	tst.b	(a2)+
	bne	.190
	move.w	#266,d0
	sub.w	d1,d0
	move.w	d0,4(a1)
	move.l	IntBase(pc),a6
	move.l	50(a4),a0
	moveq	#0,d0
	moveq	#0,d1
	jsr	PrintIText(a6)

.2	move.l	4.w,a6
	move.l	WinHD2(pc),a0
	move.l	86(a0),a0
	move.l	a0,-(a7)
	jsr	WaitPort(a6)
	move.l	(a7)+,a0
	jsr	GetMsg(a6)
	move.l	d0,a1
	move.l	20(a1),d6
	cmp.l	#8,d6
	beq.b	.4
	jsr	ReplyMsg(a6)
	bra.b	.2

.4	jsr	ReplyMsg(a6)
	lea	WinHD2(pc),a0
	move.l	4(a0),d0
	move.l	(a0),a0
	move.l	d0,86(a0)
	move.l	IntBase(pc),a6
	move.l	WinHD2(pc),a0
	jsr	CloseWindow(a6)
.5	rts

;--------------------------------------;

OrgText	tst.b	TxtBufr
	beq	.5
	move.l	DosBase(pc),a6
	move.l	#TxtBufr,d1
	moveq	#-2,d2
	jsr	Lock(a6)
	move.l	d0,d7
	bne	.11
	lea	TxtRNoT(pc),a0
	lea	TxtReq4(pc),a1
	bsr.w	Request
	tst.w	d0
	bne	.5
	moveq	#-1,d0
	bra	.4

.11	move.l	d0,d1
	move.l	#InfoBlk,d2
	jsr	Examine(a6)
	move.l	d7,d1
	jsr	UnLock(a6)
	lea	InfoBlk,a0
	move.l	124(a0),UPckLen

	move.l	4.w,a6
	move.l	UPckLen(pc),d0
	moveq	#0,d1
	jsr	AllocMem(a6)
	move.l	d0,UPckDat
	bne.b	.1
	moveq	#-1,d0
	rts
.1	move.l	DosBase(pc),a6
	move.l	#TxtBufr,d1
	move.l	#1005,d2
	jsr	Open(a6)
	move.l	d0,d7
	bne.w	.2
.2	move.l	d0,d1
	move.l	UPckDat(pc),d2
	move.l	UPckLen(pc),d3
	jsr	Read(a6)
	move.l	d7,d1
	jsr	Close(a6)

	bsr	PackDat
	bne	.3
	move.l	PckdDat(pc),a0
	move.l	PckdLen(pc),d0
	bpl	.22
	move.l	UPckDat(pc),a0
	move.l	UPckLen(pc),d0
.22	bsr	Encrypt
	bsr.w	SetUpTR
	bsr.w	WrteDat

	move.l	4.w,a6
	move.l	PckdDat(pc),a1
	move.l	UPckLen(pc),d0
	add.l	#$2220,d0
	jsr	FreeMem(a6)
	move.l	#0,PckdDat
.3	move.l	4.w,a6
	move.l	UPckDat(pc),a1
	move.l	UPckLen(pc),d0
	jsr	FreeMem(a6)
	move.l	#0,UPckDat
.5	moveq	#0,d0
.4	tst.l	d0
	rts

;--------------------------------------;

OrgTrck	move.l	4.w,a6
	lea	DiskIO(pc),a1
	jsr	WaitIO(a6)
	move.l	ULdgDat(pc),UPckDat
	move.l	ULdgLen(pc),UPckLen

	move.l	TrkSize(pc),d0
	move.l	d0,ULdgLen
	moveq	#0,d1
	jsr	AllocMem(a6)
	move.l	d0,ULdgDat
	bne.b	.1
	moveq	#-1,d0
	rts
.1	move.l	d0,a0
	move.l	ULdgLen(pc),d0
	bsr.w	TrkLoad

	tst.l	UPckDat
	beq	.4
	bsr.w	BootDsp
	bsr	PackDat
	bne	.3
	move.l	PckdDat(pc),a0
	move.l	PckdLen(pc),d0
	bpl	.2
	move.l	UPckDat(pc),a0
	move.l	UPckLen(pc),d0
.2	bsr	Encrypt
	bsr.w	SetUpTR
	bsr.w	WrteDat

	move.l	4.w,a6
	move.l	PckdDat(pc),a1
	move.l	UPckLen(pc),d0
	add.l	#$2220,d0
	jsr	FreeMem(a6)
	move.l	#0,PckdDat
.3	move.l	4.w,a6
	move.l	UPckDat(pc),a1
	move.l	UPckLen(pc),d0
	jsr	FreeMem(a6)
	move.l	#0,UPckDat
.4	rts

;--------------------------------------;

SetUpHd	lea	DMSHead(pc),a5
	move.l	#"DMS!",(a5)+
	move.l	#0,(a5)+
	moveq	#1,d0
	tst.b	EncBufr
	beq.b	.1
	bset	#1,d0
.1	tst.b	TxtBufr
	beq.b	.2
	bset	#3,d0
.2	tst.b	FDzBufr
	beq	.3
	bset	#8,d0
.3	move.l	d0,(a5)+

	move.l	DosBase(pc),a6
	move.l	#JunkBuf,d1
	jsr	DateStamp(a6)
	movem.l	JunkBuf(pc),d0-d2
	mulu	#24*60,d0
	moveq	#60,d7
	bsr.w	LongMul
	mulu	#60,d1
	divu	#50,d2
	ext.l	d2
	add.l	d2,d1
	move.l	d1,StrtTme
	add.l	d1,d0
	add.l	#$0f0c9360,d0
	move.l	d0,(a5)+

	lea	Tracks(pc),a0
	moveq	#0,d0
	bra	.5
.4	addq.w	#1,d0
.5	tst.b	(a0)+
	beq	.4
	move.w	d0,(a5)+
	lea	Tracks+80(pc),a0
	moveq	#80,d0
.55	subq.w	#1,d0
	tst.b	-(a0)
	beq	.55
	move.w	d0,(a5)+

	move.l	#0,(a5)+
	move.l	#0,(a5)+

	move.l	4.w,a6
	move.w	20(a6),d0
	cmp.w	#39,d0
	blt.b	.6
	or.w	#$8000,d0
.6	addq.w	#1,d0
	neg.w	d0
	move.w	d0,(a5)+
	move.w	34(a6),d0
	addq.w	#1,d0
	neg.w	d0
	move.w	d0,(a5)+

	move.w	296(a6),d0
	moveq	#5,d1
	btst	#3,d0
	bne.s	.7
	moveq	#4,d1
	btst	#2,d0
	bne.s	.7
	moveq	#3,d1
	btst	#1,d0
	bne.s	.7
	moveq	#2,d1
	btst	#0,d0
	bne.s	.7
	moveq	#1,d1
.7	move.w	d1,(a5)+
	moveq	#2,d1
	btst	#5,d0
	bne.s	.8
	moveq	#1,d1
	btst	#4,d0
	bne.s	.8
	moveq	#0,d1
.8	move.w	d1,(a5)+

	move.w	#1,(a5)+

	clr.w	(a5)+

	move.w	568(a6),d0
	mulu	#100,d0
	move.w	d0,(a5)+

	move.l	Timer(pc),(a5)+

	move.w	#Version,(a5)+
	move.w	#VersionNeeded,(a5)+

;	move.w	#DisketteType,(a5)+
	move.w	#1,(a5)+

	move.w	CrnchPt(pc),d0
	lsl.w	#1,d0
	lea	CrnchMd(pc),a0
	move.w	(a0,d0),(a5)+

	lea	DMSHead+4(pc),a1
	moveq	#50,d0
	bsr.w	CalcCRC
	move.w	d0,(a1)
	move.l	DosBase(pc),a6
	move.l	FleHndl(pc),d1
	move.l	#DMSHead,d2
	moveq	#56,d3
	jsr	Write(a6)
	rts

;-------------------;

OrgHead	move.l	DosBase(pc),a6
	move.l	#JunkBuf,d1
	jsr	DateStamp(a6)
	movem.l	JunkBuf+4(pc),d0-d1
	mulu	#60,d0
	divu	#50,d1
	ext.l	d1
	add.l	d1,d0
	sub.l	StrtTme(pc),d0
	lea	DMSHead(pc),a0
	move.l	d0,42(a0)

	move.l	a0,a1
	addq.l	#4,a1
	moveq	#50,d0
	bsr.w	CalcCRC
	move.w	d0,(a1)
	rts

;-------------------;

WrteHdr	move.l	DosBase(pc),a6
	move.l	FleHndl(pc),d1
	moveq	#0,d2
	moveq	#-1,d3
	jsr	Seek(a6)
	move.l	FleHndl(pc),d1
	move.l	#DMSHead,d2
	moveq	#56,d3
	jsr	Write(a6)
	rts

;--------------------------------------;

SetUpTR	lea	TrkHead(pc),a0
	move.w	#"TR",(a0)+
	move.w	CurrTrk(pc),(a0)+
	clr.w	(a0)+
	move.l	PckdLen(pc),d1
	bpl	.1
	move.l	UPckLen(pc),d1
.1	move.w	d1,(a0)+
	clr.w	(a0)+
	move.l	UPckLen(pc),d1
	move.w	d1,(a0)+
	move.b	CFlag(pc),(a0)+
	move.b	CMdeTrk(pc),(a0)+
	move.w	TrkUSum(pc),(a0)+
	move.l	PckdDat(pc),a1
	move.l	PckdLen(pc),d0
	bpl	.2
	move.l	UPckDat(pc),a1
	move.l	UPckLen(pc),d0
.2	bsr.w	CalcCRC
	move.w	d0,(a0)+
	lea	TrkHead(pc),a1
	moveq	#18,d0
	bsr.w	CalcCRC
	move.w	d0,(a0)+
	rts

;--------------------------------------;
;--------------------------------------;

TextDMS	move.l	DosBase(pc),a6
	move.l	#Fl1Bufr,d1
	moveq	#-2,d2
	jsr	Lock(a6)
	move.l	d0,d7
	bne	.1
	lea	MsNoFl1(pc),a5
	bsr	PrntMsg
	bra	WaitEvt

.1	move.l	DosBase(pc),a6
	move.l	#Fl1Bufr,d1
	move.l	#1005,d2
	jsr	Open(a6)
	move.l	d0,d7
	bne.w	.2
.2	move.l	d0,d1
	move.l	DMSHead(pc),d2
	moveq	#56,d3
	jsr	Read(a6)
	move.l	d7,d1
	jsr	Close(a6)






;--------------------------------------;
;--------------------------------------;

FndTrks	lea	Tracks(pc),a0
	moveq	#0,d0
	moveq	#80-1,d1
.1	move.b	d0,(a0)+
	dbf	d1,.1

	lea	Tracks(pc),a0
	lea	TrkBufr(pc),a1
	bsr.w	Asc2Val
	bne.b	.3
	bset	#0,(a0,d0)
.2	move.l	d0,d1

	tst.b	(a1)
	beq	.3
	cmp.b	#"-",(a1)
	beq.b	.4
	cmp.b	#"/",(a1)
	beq.b	.6
.3	rts

.4	addq.l	#1,a1
	bsr.w	Asc2Val
	bne.b	.3
	cmp.l	d0,d1
	beq.b	.2
	blt.b	.5
	exg.l	d0,d1
.5	addq.l	#1,d1
	bset	#0,(a0,d1)
	cmp.w	d0,d1
	bne.b	.5
	bra.b	.2

.6	addq.l	#1,a1
	bsr.w	Asc2Val
	bne.b	.3
	bra.b	.2

;--------------------------------------;

TrkLoad	move.l	TrkSize(pc),d1
	mulu	CurrTrk(pc),d1
	move.l	4.w,a6
	lea	DiskIO(pc),a1
	move.w	#2,28(a1)		;Load
	move.l	d1,44(a1)		;Start
	move.l	a0,40(a1)		;Data
	move.l	d0,36(a1)		;Length
	jsr	SendIO(a6)
	rts

;--------------------------------------;

GetTrSz	move.l	DevsPnt(pc),a1
	move.l	28(a1),a2
	add.l	a2,a2
	add.l	a2,a2
	move.l	8(a2),a4
	add.l	a4,a4
	add.l	a4,a4
	move.l	4(a4),d1
	move.l	20(a4),d2
	mulu	d2,d1
	move.l	12(a4),d2
	mulu	d2,d1
	lsl.l	#2,d1
	move.l	d1,TrkSize
	rts

;--------------------------------------;

WrteDat	move.l	DosBase(pc),a6
	move.l	FleHndl(pc),d1
	move.l	#TrkHead,d2
	moveq	#20,d3
	jsr	Write(a6)
	move.l	FleHndl(pc),d1
	move.l	PckdDat(pc),d2
	move.l	PckdLen(pc),d3
	tst.l	d3
	bpl	.1
	move.l	UPckDat(pc),d2
	move.l	UPckLen(pc),d3
.1	jsr	Write(a6)
	rts

;--------------------------------------;

Asc2Val	moveq	#0,d0
	moveq	#0,d2
.1	move.b	(a1),d2
	beq.b	.2
	sub.b	#"0",d2
	bmi.b	.2
	cmp.b	#9,d2
	bgt.b	.2
	mulu	#10,d0
	add.w	d2,d0
	addq.l	#1,a1
	bra.b	.1
.2	cmp.b	#79,d0
	bgt.b	.4
	moveq	#0,d2
.3	tst.l	d2
	rts
.4	moveq	#-1,d2
	bra.b	.3

;--------------------------------------;

FRquest	move.l	ReqBase(pc),a6
	tst.l	(a5)
	bne.b	.1
	moveq	#0,d0
	sub.l	a0,a0
	jsr	AllocRequestA(a6)
	move.l	d0,(a5)
	bne.b	.11
	lea	MsNoMem(pc),a5
	bsr.w	PrntMsg
	bra.b	.4
.11	lea	PatList(pc),a0
	move.l	a3,4(a0)
	move.l	(a5),a1
	jsr	ChangeReqAttrA(a6)

.1	move.l	(a5),a1
	lea	TagList(pc),a0
	move.l	a4,a2
	lea	FReqTxt(pc),a3
	jsr	FileRequestA(a6)
	tst.l	d0
	bne.b	.2
	bra.b	.4
.2	moveq	#0,d0
.3	tst.l	d0
	rts
.4	moveq	#-1,d0
	bra.b	.3

;--------------------------------------;

JoinFle	move.l	16(a0),a0
	tst.b	(a0)
	beq.b	.2
.1	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.b	.1
	cmp.b	#":",-1(a1)
	beq.b	.2
	move.b	#"/",(a1)+
.2	move.l	a2,a0
	tst.b	(a0)
	beq.b	.4
.3	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.b	.3
.4	clr.b	(a1)
	rts

;--------------------------------------;

LongMul	move.l	d0,d6
	subq.w	#2,d7
.1	add.l	d6,d0
	dbf	d7,.1
.2	rts

;--------------------------------------;

Request	addq.l	#1,a0
	addq.l	#1,a1
	lea	ReqTxt1(pc),a2
	lea	ReqTxt2(pc),a3
	move.l	a0,12(a2)
	move.l	a1,12(a3)

	move.l	WinHD1(pc),a1
	lea	WinDef3(pc),a0
	move.w	4(a1),d0
	move.w	6(a1),d1
	add.w	#123,d0
	add.w	#39,d1
	move.w	d0,(a0)
	move.w	d1,2(a0)
	move.l	IntBase(pc),a6
	jsr	OpenWindow(a6)
	move.l	d0,WinHD3
	move.l	d0,a0
	move.l	WinHD1(pc),a1
	move.l	86(a0),WinHD3+4
	move.l	86(a1),86(a0)

	move.l	50(a0),a0
	lea	RBrder1(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	jsr	DrawBorder(a6)

	move.l	WinHD3(pc),a0
	move.l	50(a0),a0
	lea	ReqTxt2(pc),a1
	move.l	12(a1),a2
	move.w	#131,d0
	move.b	-1(a2),d1
	lsl.w	#2,d1
	sub.w	d1,d0
	move.w	d0,4(a1)
	lea	ReqTxt1(pc),a1
	move.l	12(a1),a2
	move.w	#131,d0
	move.b	-1(a2),d1
	lsl.w	#2,d1
	sub.w	d1,d0
	move.w	d0,4(a1)
	moveq	#0,d0
	moveq	#0,d1
	jsr	PrintIText(a6)

.2	move.l	4.w,a6
	move.l	WinHD3(pc),a0
	move.l	86(a0),a0
	move.l	a0,-(a7)
	jsr	WaitPort(a6)
	move.l	(a7)+,a0
	jsr	GetMsg(a6)
	move.l	d0,a1
	move.l	20(a1),d6
	cmp.l	#$40,d6
	beq.b	.3
	jsr	ReplyMsg(a6)
	bra.b	.2

.3	move.l	28(a1),a0
	move.w	38(a0),d7
	jsr	ReplyMsg(a6)
	moveq	#1,d0
	cmp.w	#"S1",d7
	beq.b	.4
	moveq	#0,d0
	cmp.w	#"S0",d7
	beq.b	.4
	bra.b	.2

.4	move.l	d0,d7
	lea	WinHD3(pc),a0
	move.l	4(a0),d0
	move.l	(a0),a0
	move.l	d0,86(a0)
	move.l	IntBase(pc),a6
	move.l	WinHD3(pc),a0
	jsr	CloseWindow(a6)
	move.l	d7,d0
	rts

;--------------------------------------;

ChkOpts	move.l	PrfAllc(pc),a1
	move.l	a1,a2
	add.l	PrfSize(pc),a2
.1	cmp.l	a1,a2
	bne.b	.2
	moveq	#-1,d0
	bra.b	.5
.2	move.b	(a0),d0
	cmp.b	(a1)+,d0
	bne.b	.1
	move.l	a0,a3
	move.l	a1,a4
	addq.l	#1,a3

.3	tst.b	(a3)
	beq.b	.4
	move.b	(a3)+,d0
	cmp.b	(a4)+,d0
	beq.b	.3
	bra.b	.1
.4	cmp.b	#"=",(a4)+
	bne.b	.1
	move.l	a4,a0
	moveq	#0,d0
.5	tst.l	d0
	rts

;--------------------------------------;

FindDev	move.l	DosBase(pc),a6
	move.l	34(a6),a1
	move.l	24(a1),a1
	add.l	a1,a1
	add.l	a1,a1
	move.l	4(a1),d0
	bra.b	.2
.1	move.l	(a1),d0
	bne.b	.2
	moveq	#-1,d0
	bra.b	.4
.2	add.l	d0,d0
	add.l	d0,d0
	move.l	d0,a1

	tst.l	4(a1)
	bne.b	.1
	move.l	28(a1),a2
	add.l	a2,a2
	add.l	a2,a2
	move.l	8(a2),a4
	add.l	a4,a4
	add.l	a4,a4
	tst.l	36(a4)
	bne.b	.1
	cmp.l	#$4f,40(a4)
	bne.b	.1

	move.l	40(a1),a2
	add.l	a2,a2
	add.l	a2,a2
	move.l	a0,a3
	move.l	a2,a4
	moveq	#0,d1
	move.b	(a2)+,d1
	subq.b	#1,d1
.3	move.b	(a2)+,d0
	cmp.b	(a3)+,d0
	bne.b	.1
	dbf	d1,.3
	move.l	a1,a0
	moveq	#0,d0
.4	tst.l	d0
	rts

;--------------------------------------;

FrstDev	move.l	DosBase(pc),a6
	move.l	34(a6),a1
	move.l	24(a1),a1
	add.l	a1,a1
	add.l	a1,a1
	move.l	4(a1),d0
	bra.b	.2
.1	move.l	(a1),d0
	bne.b	.2
	moveq	#-1,d0
	bra.b	.3
.2	add.l	d0,d0
	add.l	d0,d0
	move.l	d0,a1

	tst.l	4(a1)
	bne.b	.1
	move.l	28(a1),a2
	add.l	a2,a2
	add.l	a2,a2
	move.l	8(a2),a4
	add.l	a4,a4
	add.l	a4,a4
	tst.l	36(a4)
	bne.b	.1
	cmp.l	#$4f,40(a4)
	bne.b	.1

	move.l	a1,a0
	moveq	#0,d0
.3	tst.l	d0
	rts

;--------------------------------------;

NextDev	move.l	DevsPnt(pc),a1
.1	move.l	(a1),d0
	beq.b	FrstDev
	add.l	d0,d0
	add.l	d0,d0
	move.l	d0,a1

	tst.l	4(a1)
	bne.b	.1
	move.l	28(a1),a2
	add.l	a2,a2
	add.l	a2,a2
	move.l	8(a2),a4
	add.l	a4,a4
	add.l	a4,a4
	tst.l	36(a4)
	bne.b	.1
	cmp.l	#$4f,40(a4)
	bne.b	.1

	move.l	a1,a0
	moveq	#0,d0
.3	tst.l	d0
	rts

;--------------------------------------;

CalcCRC	lea	CRCTble(pc),a2
	subq.w	#1,d0
	moveq	#0,d1
.1	moveq	#0,d2
	move.b	(a1)+,d2
	eor.b	d1,d2
	add.w	d2,d2
	lsr.w	#8,d1
	move.w	(a2,d2),d2
	eor.w	d2,d1
	dbf	d0,.1
	move.w	d1,d0
	rts

;--------------------------------------;

FndEVal	move.l	a0,a3
	clr.w	EncrVal
.1	tst.b	(a3)
	beq.s	.2
	move.w	EncrVal(pc),d0
	move.l	d0,d1
	lsr.w	#8,d1
	and.w	#$ff,d1
	moveq	#0,d2
	move.b	(a3)+,d2
	eor.w	d2,d0
	and.w	#$ff,d0
	moveq	#0,d2
	move.w	d0,d2
	add.l	d2,d2
	lea	CRCTble(pc),a0
	move.w	(a0,d2),d0
	eor.w	d0,d1
	move.w	d1,EncrVal
	bra.s	.1
.2	rts

;--------------------------------------;

Encrypt	move.l	a0,a3
	move.l	d0,d7
.1	move.l	d7,d0
	subq.w	#1,d7
	tst.w	d0
	beq	.2
	moveq	#$00,d0
	move.b	(a3),d0
	move.w	EncrVal(pc),d1
	eor.w	d1,d0
	move.b	d0,(a3)
	move.w	EncrVal(pc),d1
	lsr.w	#1,d1
	move.w	d1,EncrVal
	moveq	#0,d0
	move.b	(a3)+,d0
	add.w	d0,EncrVal
	bra	.1
.2	rts

;--------------------------------------;

Decrypt	move.l	a0,a3
	move.l	d0,d7
.1	move.l	d7,d0
	subq.w	#1,d7
	tst.w	d0
	beq.s	.2
	move.b	(a3),d6
	moveq	#0,d0
	move.b	(a3),d0
	move.w	EncrVal(pc),d1
	eor.w	d1,d0
	move.b	d0,(a3)+
	move.w	EncrVal(pc),d0
	lsr.w	#1,d0
	move.w	d0,EncrVal
	moveq	#0,d0
	move.b	d6,d0
	add.w	d0,EncrVal
	bra.s	.1
.2	rts

;--------------------------------------;

PackDat	move.l	UPckLen(pc),d0
	add.l	#$2220,d0
	move.l	#$10000,d1
	move.l	4.w,a6
	jsr	AllocMem(a6)
	move.l	d0,PckdDat
	bne	.1
	moveq	#-1,d0
	bra	.3
.1	bsr	.4
	cmp.l	UPckLen(pc),d0
	ble	.2
	move.w	#0,CFlag
	moveq	#-1,d0
.2	move.l	d0,PckdLen

	lea	DMSHead(pc),a0
	tst.l	d0
	bpl	.20
	move.l	UPckLen(pc),d0
.20	add.l	d0,20(a0)
	move.l	UPckLen(pc),d0
	add.l	d0,24(a0)

	moveq	#0,d0
.3	tst.l	d0
	rts
.4	move.l	UPckDat(pc),a0
	move.l	PckdDat(pc),a1
	move.l	UPckLen(pc),d0
	move.w	DMSHead+52(pc),d1
	move.b	d1,CMdeTrk
	cmp.w	#1,d1
	beq	PSimple
	bra	PNoComp

;--------------------------------------;

PNoComp	subq.w	#1,d0
	moveq	#0,d1
	moveq	#0,d2
.1	move.b	(a0)+,d2
	move.b	d2,(a1)+
	add.w	d2,d1
	dbf	d0,.1
	move.w	d1,TrkUSum
	move.l	a1,d0
	sub.l	PckdDat(pc),d0
	rts

;--------------------------------------;

PSimple	lea	(a0,d0),a2
	move.w	#$90,d2
	move.w	#$ff,d4
	move.w	#$7ffe,d5
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d6
	move.b	(a0)+,d3
	add.w	d3,d6
.1	move.w	d5,d0
.2	cmp.l	a2,a0
	bge.s	.3
	move.b	(a0)+,d1
	add.w	d1,d6
	cmp.b	d1,d3
	bne.s	.3
	dbf	d0,.2
	addq.w	#1,d0
.3	sub.w	d5,d0
	neg.w	d0
	addq.w	#1,d0
	cmp.w	#1,d0
	bne.s	.5
	cmp.b	d2,d3
	bne.s	.4
	move.b	d3,(a1)+
	clr.b	(a1)+
	bra.s	.9

.4	move.b	d3,(a1)+
	bra.s	.9

.5	cmp.w	#2,d0
	bne.s	.7
	cmp.b	d2,d3
	bne.s	.6
	move.b	d3,(a1)+
	clr.b	(a1)+
	move.b	d3,(a1)+
	clr.b	(a1)+
	bra.s	.9

.6	move.b	d3,(a1)+
	move.b	d3,(a1)+
	bra.s	.9

.7	cmp.w	d4,d0
	bge.s	.8
	move.b	d2,(a1)+
	move.b	d0,(a1)+
	move.b	d3,(a1)+
	bra.s	.9

.8	move.b	d2,(a1)+
	move.b	d4,(a1)+
	move.b	d3,(a1)+
	move.b	d0,1(a1)
	lsr.w	#8,d0
	move.b	d0,(a1)
	addq.l	#2,a1

.9	cmp.l	a2,a0
	bge.s	.10
	move.b	d1,d3
	bra.s	.1

.10	cmp.b	d1,d3
	beq.s	.12
	cmp.b	d2,d1
	bne.s	.11

	move.b	d1,(a1)+
	clr.b	(a1)+
	bra.s	.12

.11	move.b	d1,(a1)+
.12	move.w	d6,TrkUSum
	move.l	a1,d0
	sub.l	PckdDat(pc),d0
	rts

;--------------------------------------;

DSimple	lea	(a0,d0),a2
	move.b	#$90,d2
	moveq	#0,d0
	moveq	#0,d3
.1	cmp.l	a2,a0
	bge	.7
	move.b	(a0)+,d0
	cmp.b	d2,d0
	beq	.2
	move.b	d0,(a1)+
	add.w	d0,d3
	bra	.1
.2	moveq	#0,d1
	move.b	(a0)+,d1
	tst.b	d1
	bne.s	.3
	move.b	d0,(a1)+
	add.w	d0,d3
	bra	.1
.3	cmp.b	#-1,d1
	bne	.5
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	lsl.w	#8,d1
	or.b	(a0)+,d1
	subq.w	#1,d1
.4	move.b	d0,(a1)+
	add.w	d0,d3
	dbf	d1,.4
	bra	.1
.5	move.b	(a0)+,d0
	subq.w	#1,d1
.6	move.b	d0,(a1)+
	add.w	d0,d3
	dbf	d1,.6
	bra	.1
.7	move.w	d3,TrkUSum
	move.l	a1,d0
	sub.l	PckdDat(pc),d0
	rts

;--------------------------------------;

WinDef1	dc.w	0,11			;X & Y
	dc.w	508,130			;Width & Height
	dc.b	0,1			;Colours
	dc.l	$268			;IDCMP
	dc.l	$1100e			;Flags
	dc.l	GdRead			;Gadgets
	dc.l	0			;CheckMark
	dc.l	WnTitle			;Title
	dc.l	0			;Screen
	dc.l	0			;BitMap
	dc.w	508,130			;X & Y Min
	dc.w	508,130			;X & Y Max
	dc.w	1			;Type

;--------------------------------------;

WinDef2	dc.w	0,0			;X & Y
	dc.w	532,161			;Width & Height
	dc.b	0,1			;Colours
	dc.l	$208			;IDCMP
	dc.l	$11002			;Flags
	dc.l	0			;Gadgets
	dc.l	0			;CheckMark
	dc.l	0			;Title
	dc.l	0			;Screen
	dc.l	0			;BitMap
	dc.w	532,160			;X & Y Min
	dc.w	532,160			;X & Y Max
	dc.w	1			;Type

;--------------------------------------;

WinDef3	dc.w	0,0			;X & Y
	dc.w	262,50			;Width & Height
	dc.b	0,1			;Colours
	dc.l	$40			;IDCMP
	dc.l	$11002			;Flags
	dc.l	GdSlct0			;Gadgets
	dc.l	0			;CheckMark
	dc.l	0			;Title
	dc.l	0			;Screen
	dc.l	0			;BitMap
	dc.w	508,115			;X & Y Min
	dc.w	508,115			;X & Y Max
	dc.w	1			;Type

;--------------------------------------;

GdRead	GadText	GdWrite,8,13,82,13,GBrder1,GBrder2,GTRead,"RD"
GTRead	IText	0,25,3,1,0,0,0,TxRead
GdWrite	GadText	GdView,90,13,82,13,GBrder1,GBrder2,GTWrite,"WT"
GTWrite	IText	0,21,3,1,0,0,0,TxWrite
GdView	GadText	GdTest,172,13,82,13,GBrder1,GBrder2,GTView,"VW"
GTView	IText	0,25,3,1,0,0,0,TxView
GdTest	GadText	GdText,254,13,82,13,GBrder1,GBrder2,GTTest,"TS"
GTTest	IText	0,25,3,1,0,0,0,TxTest
GdText	GadText	GdRPack,336,13,82,13,GBrder1,GBrder2,GTText,"TX"
GTText	IText	0,25,3,1,0,0,0,TxText
GdRPack	GadText	GdFlDsk,418,13,82,13,GBrder1,GBrder2,GTRPack,"RP"
GTRPack	IText	0,17,3,1,0,0,0,TxRPack

GdFlDsk	GadText	GdFile1,474,28,28,14,DBrder1,DBrder2,0,"D1"
GdFile1	GadStrg	GdTxDsk,96,31,46,GBrder3,GTFile1,Fl1Bufr,256,"F1"
GTFile1	IText	0,-80,0,1,0,0,0,Fl1Text
GdFile2	GadStrg	GdTxDsk,96,31,46,GBrder3,GTFile2,Fl2Bufr,256,"F2"
GTFile2	IText	0,-80,0,1,0,0,0,Fl2Text

GdTxDsk	GadText	GdTxtFl,474,43,28,14,DBrder1,DBrder2,0,"D3"
GdTxtFl	GadStrg	GdNull1,96,46,46,GBrder3,GTTxtFl,TxtBufr,256,"T1"
GTTxtFl	IText	0,-80,0,1,0,0,0,TxtText
GdFleDz	GadStrg	GdNull1,96,46,46,GBrder3,GTFleDz,FDzBufr,256,"T2"
GTFleDz	IText	0,-80,0,1,0,0,0,FDzText
GdNull1	GadNull	GdNull2,6,28,468,14,"N1"
GdNull2	GadNull	GdEncry,6,43,468,14,"N2"
GdEncry	GadStrg	GdTrcks,96,61,49,GBrder5,GTEncry,EncBufr,128,"EN"
GTEncry	IText	0,-80,0,1,0,0,0,EncText
GdTrcks	GadStrg	GdCMode,318,76,22,GBrder7,GTTrcks,TrkBufr,128,"TR"
GTTrcks	IText	0,-73,0,1,0,0,0,TrkText

GdCMode	GadText	GdDrive,228,87,82,13,GBrder1,GBrder2,GTCMode,"CM"
GTCMode	IText	0,17,3,1,0,0,0,TxCMode
GdDrive	GadText	0,228,100,82,13,GBrder1,GBrder2,0,"DV"

;--------------------------------------;

GdSlct0	GadText	GdSlct1,172,33,82,13,GBrder1,GBrder2,GTSlct0,"S0"
GTSlct0	IText	0,18,3,1,0,0,0,TxSlct0
GdSlct1	GadText	0,8,33,82,13,GBrder1,GBrder2,GTSlct1,"S1"
GTSlct1	IText	0,26,3,1,0,0,0,TxSlct1

;--------------------------------------;

GBrder1	Border	0,0,0,82,13,2,1
GBrder2	Border	0,0,0,82,13,1,2
GBrder3	Border	GBrder4,-8,-2,(46*8)+16,12,1,2
GBrder4	Border	0,-90,-3,(46*8)+100,14,2,1
GBrder5	Border	GBrder6,-8,-2,(49*8)+20,12,1,2
GBrder6	Border	0,-90,-3,(49*8)+104,14,2,1
GBrder7	Border	GBrder8,-9,-2,(22*8)+15,12,1,2
GBrder8	Border	0,-90,-3,(22*8)+98,14,2,1

DBrder1	Border	0,0,0,28,14,2,1
DBrder2	Border	0,0,0,28,14,1,2
SBrder1	Border	SBrder2,6,73,220,40,2,1
SBrder2	Border	SBrder3,6,12,496,15,1,2
SBrder3	Border	SBrder4,6,114,496,13,2,1
SBrder4	Border	0,310,87,192,26,2,1

BBrder1	Border	BBrder2,4,11,524,148,2,1
BBrder2	Border	0,8,13,516,14,1,2

RBrder1	Border	0,4,11,254,37,2,1
ReqTxt1	IText	ReqTxt2,0,14,1,0,0,0,0
ReqTxt2	IText	0,0,22,1,0,0,0,0

BootTxt	IText	0,0,16,1,0,0,0,0
VirTxt1	IText	VirTxt2,12,16,2,0,0,0,MsVirus
VirTxt2	IText	0,464,16,2,0,0,0,MsVirus

DskImg1	IImage	DskImg2,479,30,18,10,3,2,ImgeDat
DskImg2	IImage	LogoImg,479,45,18,10,3,2,ImgeDat
LogoImg	IImage	0,6+((220-155)/2),73+((40-34)/2),155,34,3,2,LogoDat

;--------------------------------------;

MsNoMem	dc.b	13,"OUT OF MEMORY"
MsNWrte	dc.b	20,"CANNOT WRITE TO FILE"
MsNoFl1	dc.b	23,"FILENAME DOES NOT EXIST"
MsAbort	dc.b	10,"ABORTED..."

MsVirus	dc.b	"*VIRUS*",0
MsNoInf	dc.b	"Bootblock not infected",0

WnTitle	dc.b	"DMSwin TURBO 1.13 - BøøSTeD VeRsIoN by FRaNTiC/PsD",0
FReqTxt	dc.b	"Please Select A File",0
TxRead	dc.b	"READ",0
TxWrite	dc.b	"WRITE",0
TxView	dc.b	"VIEW",0
TxTest	dc.b	"TEST",0
TxText	dc.b	"TEXT",0
TxRPack	dc.b	"REPACK",0
Fl1Text	dc.b	"FILENAME",0
Fl2Text	dc.b	"PACKNAME",0
TxtText	dc.b	"TEXTFILE",0
FDzText	dc.b	"FILE.DIZ",0
EncText	dc.b	"PASSWORD",0
TrkText	dc.b	"TRACKS",0
CrModes	dc.b	"NOCOMP",0,0
	dc.b	"SIMPLE",0,0
	dc.b	"QUICK",0,0,0
	dc.b	"MEDIUM",0,0
	dc.b	"DEEP",0,0,0,0
	dc.b	"HEAVY1",0,0
TxCMode	dc.b	"HEAVY2",0,0
	dc.b	"HEAVY3",0,0
	dc.b	"HEAVY4",0,0
	dc.b	"HEAVY5",0,0
TxDrive	dc.b	"DF0:",0

;--------------------------------------;

TxSlct1	dc.b	"OKAY",0
TxSlct0	dc.b	"CANCEL",0
TxtReq1	dc.b	19,"FILE ALREADY EXISTS",0
TxtReq2	dc.b	10,"OVERWRITE?",0
TxtReq3	dc.b	5,"ABORT",0
TxtRErr	dc.b	5,"ERROR",0
TxtRNoT	dc.b	23,"TEXTFILE DOES NOT EXIST",0
TxtReq4	dc.b	24,"CONTINUE WITH OPERATION?",0
TxtRDsk	dc.b	27,"PLEASE INSERT DISK IN DRIVE",0

;--------------------------------------;

Fl1Bufr	dcb.b	256,0
Fl2Bufr	dcb.b	256,0
TxtBufr	dcb.b	256,0
FDzBufr	dcb.b	256,0
EncBufr	dcb.b	128,0
TrkBufr	dc.b	"0-79"
	dcb.b	124,0
	even

PrFleN1	dc.b	"FILENAME1",0
PrFleN2	dc.b	"FILENAME2",0
PrTxtFl	dc.b	"TEXTFILE",0
PrFleDz	dc.b	"FILEID.DIZ",0
PrTrack	dc.b	"TRACKS",0
PrCMode	dc.b	"CMODE",0
PrDrive	dc.b	"DRIVE",0
PrfNme1	dc.b	"Env:DMS.prefs",0
PrfNme2	dc.b	"EnvArc:DMS.prefs",0
	even
IntBase	dc.b	"intuition.library",0
DosBase	dc.b	"dos.library",0
GfxBase	dc.b	"graphics.library",0,0
ReqBase	dc.b	"reqtools.library",0,0
BtBBase	dc.b	"Bootblock.library",0
BtHndlr	dc.b	"L:Bootblock.brainfile",0
ConName	dc.b	"CON:0/2/640/198/Banner",0
BtSttus	dc.l	0
WinHD1	dc.l	0
WinHD2	dc.l	0,0
WinHD3	dc.l	0,0
FFl1Req	dc.l	0
FFl2Req	dc.l	0
TFleReq	dc.l	0
FlDzReq	dc.l	0
FleHndl	dc.l	0
Timer	dc.l	0
CrnchPt	dc.w	3
CrnchMd	dc.w	0,1,5,6,-1
Tracks	dcb.b	80,0
DevsPnt	dc.l	0
RplyPrt	dcb.b	32,0
DiskIO	dcb.b	80,0
JunkBuf	dcb.b	50,0
PrfAllc	dc.l	0
PrfSize	dc.l	0
DMSHead	dcb.b	56,0
TrkHead	dcb.b	20,0
ULdgDat	dc.l	0
UPckDat	dc.l	0
PckdDat	dc.l	0
ULdgLen	dc.l	0
UPckLen	dc.l	0
PckdLen	dc.l	0
NewTrck	dc.l	0
OldTrck	dc.l	0
CurrTrk	dc.w	0
CFlag	dc.b	0
CMdeTrk	dc.b	0
TrkUSum	dc.w	0
BootBuf	dcb.b	1024,0
MousChk	dc.b	0
StrtTme	dc.l	0
TrkSize	dc.l	0
EncrVal	dc.w	0

;--------------------------------------;

CRCTble	dc.l	$0000c0c1,$c1810140,$c30103c0,$0280c241
	dc.l	$c60106c0,$0780c741,$0500c5c1,$c4810440
	dc.l	$cc010cc0,$0d80cd41,$0f00cfc1,$ce810e40
	dc.l	$0a00cac1,$cb810b40,$c90109c0,$0880c841
	dc.l	$d80118c0,$1980d941,$1b00dbc1,$da811a40
	dc.l	$1e00dec1,$df811f40,$dd011dc0,$1c80dc41
	dc.l	$1400d4c1,$d5811540,$d70117c0,$1680d641
	dc.l	$d20112c0,$1380d341,$1100d1c1,$d0811040
	dc.l	$f00130c0,$3180f141,$3300f3c1,$f2813240
	dc.l	$3600f6c1,$f7813740,$f50135c0,$3480f441
	dc.l	$3c00fcc1,$fd813d40,$ff013fc0,$3e80fe41
	dc.l	$fa013ac0,$3b80fb41,$3900f9c1,$f8813840
	dc.l	$2800e8c1,$e9812940,$eb012bc0,$2a80ea41
	dc.l	$ee012ec0,$2f80ef41,$2d00edc1,$ec812c40
	dc.l	$e40124c0,$2580e541,$2700e7c1,$e6812640
	dc.l	$2200e2c1,$e3812340,$e10121c0,$2080e041
	dc.l	$a00160c0,$6180a141,$6300a3c1,$a2816240
	dc.l	$6600a6c1,$a7816740,$a50165c0,$6480a441
	dc.l	$6c00acc1,$ad816d40,$af016fc0,$6e80ae41
	dc.l	$aa016ac0,$6b80ab41,$6900a9c1,$a8816840
	dc.l	$7800b8c1,$b9817940,$bb017bc0,$7a80ba41
	dc.l	$be017ec0,$7f80bf41,$7d00bdc1,$bc817c40
	dc.l	$b40174c0,$7580b541,$7700b7c1,$b6817640
	dc.l	$7200b2c1,$b3817340,$b10171c0,$7080b041
	dc.l	$500090c1,$91815140,$930153c0,$52809241
	dc.l	$960156c0,$57809741,$550095c1,$94815440
	dc.l	$9c015cc0,$5d809d41,$5f009fc1,$9e815e40
	dc.l	$5a009ac1,$9b815b40,$990159c0,$58809841
	dc.l	$880148c0,$49808941,$4b008bc1,$8a814a40
	dc.l	$4e008ec1,$8f814f40,$8d014dc0,$4c808c41
	dc.l	$440084c1,$85814540,$870147c0,$46808641
	dc.l	$820142c0,$43808341,$410081c1,$80814040

;--------------------------------------;

TagList	dc.l	Window
FWindow	dc.l	0
	dc.l	Flags,16
	dc.l	0,0
PatList	dc.l	MatchPat,0
	dc.l	0,0

FFl1Pat	dc.b	"#?.DMS",0
FFl2Pat	dc.b	"#?.DMS",0
TFlPtrn	dc.b	0
FDzPtrn	dc.b	0
FFl1Nme	dcb.b	108,0
FFl2Nme	dcb.b	108,0
TFlName	dcb.b	108,0
FDzName	dcb.b	108,0

;--------------------------------------;

	SECTION	"Chip Data",DATA_C

InfoBlk	dcb.b	260,0
ImgeDat	incbin	"DH2:Storage/Unfinished/DMS/DiskImage.raw"
LogoDat	incbin	"DH2:Storage/Unfinished/DMS/DMS.raw"
	END

 STRUCTURE FileSysStartupMsg,0
    ULONG	fssm_Unit	; exec unit number for this device
    BSTR	fssm_Device	; null terminated bstring to the device name
    BPTR	fssm_Environ	; ptr to environment table (see above)
    ULONG	fssm_Flags	; flags for OpenDevice()
    LABEL	FileSysStartupMsg_SIZEOF

 STRUCTURE DosEnvec,0
0   ULONG de_TableSize	     ; Size of Environment vector
4   ULONG de_SizeBlock	     ; in longwords: standard value is 128
8   ULONG de_SecOrg	     ; not used; must be 0
12  ULONG de_Surfaces	     ; # of heads (surfaces). drive specific
16  ULONG de_SectorPerBlock  ; not used; must be 1
20  ULONG de_BlocksPerTrack  ; blocks per track. drive specific
24  ULONG de_Reserved	     ; DOS reserved blocks at start of partition.
28  ULONG de_PreAlloc	     ; DOS reserved blocks at end of partition
32  ULONG de_Interleave	     ; usually 0
36  ULONG de_LowCyl	     ; starting cylinder. typically 0
40  ULONG de_HighCyl	     ; max cylinder. drive specific
    ULONG de_NumBuffers	     ; Initial # DOS of buffers.
    ULONG de_BufMemType	     ; type of mem to allocate for buffers
    ULONG de_MaxTransfer     ; Max number of bytes to transfer at a time
    ULONG de_Mask	     ; Address Mask to block out certain memory
    LONG  de_BootPri	     ; Boot priority for autoboot
    ULONG de_DosType	     ; ASCII (HEX) string showing filesystem type;
			     ; 0X444F5300 is old filesystem,
			     ; 0X444F5301 is fast file system
    ULONG de_Baud	     ; Baud rate for serial handler
    ULONG de_Control	     ; Control word for handler/filesystem
    ULONG de_BootBlocks      ; Number of blocks containing boot code

    LABEL DosEnvec_SIZEOF

MousPrs	moveq	#0,d6
	moveq	#0,d7
	move.w	24(a1),d5
	move.w	32(a1),d6
	move.w	34(a1),d7
	jsr	ReplyMsg(a6)
	cmp.w	#$68,d5
	bne.w	WaitEvt

	lea	BlkStat(pc),a5
.3	move.l	4.w,a6
	move.l	WinHD1(pc),a0
	move.l	86(a0),a0
	jsr	GetMsg(a6)
	move.l	d0,a1
	tst.l	d0
	beq.b	.6
	move.l	20(a1),d6
	cmp.l	#$100,d6
	bne.b	.4
	move.w	24(a1),d5
	jsr	ReplyMsg(a6)
	cmp.w	#(-1)<<11+(2)<<5+(0),d5
	beq.b	.9
	bra.b	.6

;L531	move.l	d6,d0
;	asl.l	#$2,d0
;	movea.l	$00(a3,d0.l),a0
;	lea	L496(pc),a1
;	jsr	L1248(pc)
;	tst.w	d0
;	bne.s	L532
;	st	-$2520(a4)
;	addq.w	#$1,d6
;	move.l	d6,d0
;	asl.l	#$2,d0
;	movea.l	$00(a3,d0.l),a0
;	jsr	L626(pc)
;	bra.l	L553
;
;
;	movea.l	-$254c(a4),a0
;	jsr	E630(pc)
;
;
;
;	move.w	$0150(a4),d0
;	move.l	-$254c(a4),a0
;	bsr	E633

;	lea	PassWrd(pc),a0
;	bsr	l626

	lea	$1a004c,a0
	move.l	#$2c00,d0
	bsr	E630

	rts
