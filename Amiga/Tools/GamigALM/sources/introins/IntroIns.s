
;---- Exec Equates

GetMsg		= -372
ReplyMsg	= -378
WaitPort	= -384
OpenLibrary	= -552
CloseLibrary	= -414
AllocMem	= -198
FreeMem		= -210
Forbid		= -132

;---- Graphics Equates

SetAPen		= -342
WritePixel	= -324
RectFill	= -306
Move		= -240
Text		= -60

;---- Intuition Equates

WBToFront	= -342
WBToBack	= -336

ClearMenuStrip	= -54
CloseWindow	= -72
OpenWindow	= -204
DrawBorder	= -108
DrawImage	= -114
PrintIText	= -216
RefreshGadgets	= -222
SetMenuStrip	= -264
SetWindowTitles	= -276
ActivateGadget	= -462
DisplayBeep	= -96

;---- Dos Equates

Open		= -30
Close		= -36
Read		= -42
Write		= -48
Lock		= -84
UnLock		= -90
Examine		= -102
Output		= -60

;---- TrackDisk Equates

FindTask	= -294
AddPort		= -354
RemPort		= -360
OpenDevice	= -444
CloseDevice	= -450
DoIO		= -456

;---- ReqTools Equates

AllocRequestA	= -30
FreeRequest	= -36
FileRequestA	= -54
Window		= 1+(1<<31)
Underscore	= 11+(1<<31)
OKText		= 42+(1<<31)
ReqFSave	= 2

;--------------------------------------;

	SECTION	"IntroIns 1.2 by Frantic in 1994",CODE

	include	"DH2:IntroIns/Macros.i"
;	include	"DH2:IntroIns/IntroIns.i"

	bsr.b	OpenReq
	beq.b	End1
	bsr.w	OpenDos
	beq.b	End2
	bsr.w	OpenGfx
	beq.b	End3
	bsr.w	OpenInt
	beq.b	End4
	bsr.w	OpenDev
	bne.b	End5
	bsr.w	OpenWin
	beq.b	End6
	bsr.w	SetTtle
	bsr.w	DrawBdr
	bsr.w	DrawImg
	bsr.w	PrntTxt
	bsr.w	SetMenu
	bsr.w	WB2Frnt
	lea	MsReady(pc),a5
	bsr.w	PrntMsg
	bra.w	WaitEvt

End	bsr.w	WB2Back
	bsr.w	ClrMenu
	bsr.w	ClseWin
End6	bsr.w	ClseDev
End5	bsr.w	ClseInt
End4	bsr.b	ClseGfx
End3	bsr.b	ClseDos
End2	bsr.b	ClseReq
End1	moveq	#0,d0
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

OpenDos	move.l	4.w,a6
	moveq	#33,d0
	lea	DosBase(pc),a1
	jsr	OpenLibrary(a6)
	move.l	d0,DosBase
	rts

ClseDos	move.l	4.w,a6
	move.l	DosBase(pc),a1
	jsr	CloseLibrary(a6)
	rts

;--------------------------------------;

OpenGfx	move.l	4.w,a6
	moveq	#33,d0
	lea	GfxBase(pc),a1
	jsr	OpenLibrary(a6)
	move.l	d0,GfxBase
	rts

ClseGfx	move.l	4.w,a6
	move.l	GfxBase(pc),a1
	jsr	CloseLibrary(a6)
	rts

;--------------------------------------;

OpenInt	move.l	4.w,a6
	moveq	#33,d0
	lea	IntBase(pc),a1
	jsr	OpenLibrary(a6)
	move.l	d0,IntBase
	rts

ClseInt	move.l	4.w,a6
	move.l	IntBase(pc),a1
	jsr	CloseLibrary(a6)
	rts

;--------------------------------------;

OpenDev	move.l	4.w,a6
	sub.l	a1,a1
	jsr	FindTask(a6)
	lea	RplyPrt(pc),a1
	move.l	d0,16(a1)
	jsr	AddPort(a6)
	lea	DiskIO(pc),a1
	move.l	#RplyPrt,14(a1)
	moveq	#0,d0
	move.b	DriveNo(pc),d0
	moveq	#0,d1
	lea	TrDName(pc),a0
	jsr	OpenDevice(a6)
	tst.l	d0
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
	move.l	d0,LWindow
	move.l	d0,SWindow
	move.l	d0,a0
	move.l	50(a0),a0
	move.l	a0,RastPrt
	tst.l	d0
	rts

ClseWin	move.l	IntBase(pc),a6
	move.l	WinHD1(pc),a0
	jsr	CloseWindow(a6)
	rts

;--------------------------------------;

SetTtle	move.l	IntBase(pc),a6
	move.l	WinHD1(pc),a0
	lea	WTitle(pc),a1
	lea	STitle(pc),a2
	jsr	SetWindowTitles(a6)
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

DrawBdr	move.l	IntBase(pc),a6
	move.l	RastPrt(pc),a0
	lea	Border1(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	jsr	DrawBorder(a6)
	rts

;--------------------------------------;

DrawImg	move.l	IntBase(pc),a6
	move.l	RastPrt(pc),a0
	lea	SImages(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	jsr	DrawImage(a6)
	rts

;--------------------------------------;

PrntTxt	move.l	IntBase(pc),a6
	move.l	RastPrt(pc),a0
	lea	MrkTxt1(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	jsr	PrintIText(a6)
	rts

;--------------------------------------;

PrntMsg	move.l	GfxBase(pc),a6
	move.l	RastPrt(pc),a1
	moveq	#0,d0
	jsr	SetAPen(a6)
	move.l	RastPrt(pc),a1
	move.l	#8,d0
	move.l	#73,d1
	move.l	#303,d2
	move.l	#82,d3
	jsr	RectFill(a6)
	move.l	RastPrt(pc),a1
	moveq	#12,d0
	moveq	#80,d1
	jsr	Move(a6)
	move.l	RastPrt(pc),a1
	moveq	#1,d0
	jsr	SetAPen(a6)
	move.l	RastPrt(pc),a1
	move.l	a5,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	jsr	Text(a6)
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
	cmp.l	#$40,d6
	beq.b	FindGad
	cmp.l	#$20,d6
	beq.w	FindAct
	cmp.l	#$8,d6
	beq.w	MousPrs
	jsr	ReplyMsg(a6)
	bra.b	WaitEvt

;--------------------------------------;

ChkMenu	move.w	24(a1),d7
	jsr	ReplyMsg(a6)

	cmp.w	#(0)<<11+(0)<<5+(0),d7
	beq.w	ViewBtB
	cmp.w	#(1)<<11+(0)<<5+(0),d7
	beq.w	LoadBtB
	cmp.w	#(2)<<11+(0)<<5+(0),d7
	beq.w	SaveBtB
	cmp.w	#(3)<<11+(0)<<5+(0),d7
	beq.w	Clculte
	cmp.w	#(-1)<<11+(1)<<5+(0),d7
	beq.w	Insert
	cmp.w	#(-1)<<11+(2)<<5+(0),d7
	beq.w	Search
	cmp.w	#(-1)<<11+(3)<<5+(0),d7
	beq.w	DrvMode
	cmp.w	#(-1)<<11+(5)<<5+(0),d7
	beq.w	End
	bra.w	WaitEvt

;--------------------------------------;

FindGad	move.l	28(a1),a0
	move.w	38(a0),d7
	jsr	ReplyMsg(a6)
	cmp.w	#"S",d7
	beq.w	Search
	cmp.w	#"D",d7
	beq.w	DrvMode
	cmp.w	#"I",d7
	beq.w	Insert
	cmp.w	#"N1",d7
	beq.b	ActGads
	cmp.w	#"N2",d7
	beq.b	ActGads
	cmp.w	#"N3",d7
	beq.b	ActGads
	cmp.w	#"N4",d7
	beq.b	ActGads
	bra.w	WaitEvt

;--------------------------------------;

FindAct	move.l	28(a1),a0
	move.w	38(a0),d7
	jsr	ReplyMsg(a6)

ActGads	move.l	IntBase(pc),a6
	cmp.w	#34,20(a6)
	blt.w	WaitEvt
	cmp.w	#"N1",d7
	beq.b	.1
	cmp.w	#"N2",d7
	beq.b	.2
	cmp.w	#"N3",d7
	beq.b	.3
	cmp.w	#"N4",d7
	beq.b	.4
	bra.w	WaitEvt

.1	lea	GStartB(pc),a0
	move.w	#4,52(a0)
	bra.b	.5
.2	lea	GBkSize(pc),a0
	move.w	#4,52(a0)
	bra.b	.5
.3	lea	GLdAdrs(pc),a0
	move.w	#5,52(a0)
	bra.b	.5
.4	lea	GJmAdrs(pc),a0
	move.w	#5,52(a0)
.5	move.l	WinHD1(pc),a1
	sub.l	a2,a2
	jsr	ActivateGadget(a6)
	bra.w	WaitEvt

;--------------------------------------;

DrvMode	bsr.w	ClseDev

.1	addq.b	#1,DriveNo
	cmp.b	#4,DriveNo
	bne.b	.2
	clr.b	DriveNo

.2	bsr.w	OpenDev
	beq.b	.3
	lea	RplyPrt(pc),a1
	jsr	RemPort(a6)
	bra.b	.1

.3	clr.b	TDrveNo
	lea	GDrveNo(pc),a0
	move.l	WinHD1(pc),a1
	sub.l	a2,a2
	move.l	IntBase(pc),a6
	jsr	RefreshGadgets(a6)

	move.b	DriveNo(pc),d0
	ext.w	d0
	mulu	#5,d0
	lea	DrveNoT(pc),a0
	lea	(a0,d0),a0
	move.l	a0,TDrveNo+12
	lea	MDriveT+6(pc),a1
	moveq	#3,d0
.4	move.b	(a0)+,(a1)+
	dbf	d0,.4

	move.b	#1,TDrveNo
	lea	GDrveNo(pc),a0
	move.l	WinHD1(pc),a1
	sub.l	a2,a2
	move.l	IntBase(pc),a6
	jsr	RefreshGadgets(a6)
	bra.w	WaitEvt

;--------------------------------------;

Insert	bsr.w	LRquest
	bne.w	WaitEvt
	bsr.b	FleExst
	bne.w	WaitEvt
	bsr.b	FndLgth
	bne.w	WaitEvt
	bsr.w	ChkBlks
	bne.w	WaitEvt
	bsr.w	FlAlloc
	bne.w	WaitEvt
	bsr.w	FleRead
	bne.b	.1
	bsr.w	WaitDsk
	bne.b	.1
	bsr.w	WrteInt
	bsr.w	WriteBt
	bne.b	.1
	bsr.w	ClrBlkS
	lea	MsReady(pc),a5
	bsr.w	PrntMsg
.1	bsr.w	FleFree
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

FndLgth	move.l	FleLock(pc),d1
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
	bra.b	.3
.1	move.l	d0,d1
	and.l	#$1ff,d1
	beq.b	.2
	and.l	#$fffffe00,d0
	add.l	#512,d0
.2	move.l	d0,FleLgth
	moveq	#0,d0
.3	tst.l	d0
	rts

;--------------------------------------;

ChkBlks	lea	SStartB(pc),a0
	bsr.w	DecConv
	lsl.l	#8,d0
	add.l	d0,d0
	move.l	d0,BStartB
	lea	SBkSize(pc),a0
	bsr.w	DecConv
	lsl.l	#8,d0
	add.l	d0,d0
	move.l	d0,BBkSize
	cmp.l	FleLgth(pc),d0
	bge.b	.2
	lea	MsNoSze(pc),a5
	bsr.w	PrntMsg
	moveq	#-1,d0
	bra.b	.3
.2	moveq	#0,d0
.3	tst.l	d0
	rts

;--------------------------------------;

FlAlloc	move.l	4.w,a6
	move.l	FleLgth(pc),d0
	move.l	#$10002,d1
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

WrteInt	lea	MsInstg(pc),a5
	bsr.w	PrntMsg
	move.l	4.w,a6
	lea	DiskIO(pc),a1
	move.w	#3,28(a1)		;Write
	move.l	BStartB(pc),44(a1)	;Start
	move.l	FleAllc(pc),40(a1)	;Data
	move.l	FleLgth(pc),36(a1)	;Length
	jsr	DoIO(a6)
	move.w	#4,28(a1)		;Update
	move.l	#0,36(a1)		;Length
	jsr	DoIO(a6)
	move.w	#9,28(a1)		;Motor
	move.l	#0,36(a1)		;Length
	jsr	DoIO(a6)
	rts

;--------------------------------------;

WriteBt	move.l	BStartB(pc),BkOffst+2
	move.l	BBkSize(pc),IntLgth+2
	lea	SLdAdrs(pc),a0
	bsr.w	HexConv
	move.l	d0,DestAdd+2
	lea	SJmAdrs(pc),a0
	bsr.w	HexConv
	move.l	d0,JumpAdd+2

	bsr.w	ReadBtB

	move.l	#1024-(SctrEnd-SctrLdr)-12-1,d0
	lea	EndBoot-(SctrEnd-SctrLdr),a0
	lea	EndBoot,a1
.1	move.b	-(a0),-(a1)
	dbf	d0,.1
	lea	SctrLdr(pc),a0
	lea	JunkBlk+12,a1
.2	move.w	(a0)+,(a1)+
	cmp.l	#SctrEnd,a0
	bne.b	.2

	bsr.w	CalcChk
	bra.w	WrteBtB

;--------------------------------------;

FleFree	move.l	4.w,a6
	move.l	FleLgth(pc),d0
	move.l	FleAllc(pc),a1
	jsr	FreeMem(a6)
	rts

;--------------------------------------;

MousPrs	moveq	#0,d6
	moveq	#0,d7
	move.w	24(a1),d5
	move.w	32(a1),d6
	move.w	34(a1),d7
	jsr	ReplyMsg(a6)
	cmp.w	#$68,d5
	bne.w	WaitEvt

	sub.w	#388,d6
	bmi.w	WaitEvt
	sub.w	#15,d7
	bmi.w	WaitEvt
	cmp.w	#80*3,d6
	bge.w	WaitEvt
	cmp.w	#22*3,d7
	bge.w	WaitEvt

	divu	#3,d6
	divu	#3,d7
	mulu	#(640/8),d7
	add.w	d6,d7
	lea	BlkStat(pc),a5
	cmp.b	#3,(a5,d7)
	bne.w	WaitEvt
	bsr.b	ClrBlkS
	bsr.b	FndBlkS

	move.w	BlkStrt(pc),d0
	lea	SStartB(pc),a0
	bsr.w	AscConv
	move.w	BlkLgth(pc),d0
	lea	SBkSize(pc),a0
	bsr.w	AscConv

	move.l	IntBase(pc),a6
	lea	GStartB(pc),a0
	move.l	WinHD1(pc),a1
	sub.l	a2,a2
	jsr	RefreshGadgets(a6)
	bra.w	WaitEvt

;-------------------;

ClrBlkS	move.w	d7,-(a7)
	lea	BlkStat(pc),a5
	move.w	BlkStrt(pc),d7
	bmi.b	.2
.1	moveq	#3,d0
	move.b	d0,(a5,d7)
	bsr.w	PrntBlk
	cmp.b	#2,1(a5,d7)
	bne.b	.2
	addq.w	#1,d7
	bra.b	.1
.2	move.w	#-1,BlkStrt
	move.w	(a7)+,d7
	rts

;-------------------;

FndBlkS	lea	BlkStat(pc),a5
	tst.w	d7
	beq.b	.1
	cmp.b	#3,-1(a5,d7)
	bne.b	.1
	subq.w	#1,d7
	bra.b	FndBlkS
.1	move.w	d7,BlkStrt
.2	cmp.w	#1760,d7
	beq.b	.3
	moveq	#2,d0
	move.b	d0,(a5,d7)
	bsr.w	PrntBlk
	cmp.b	#3,1(a5,d7)
	bne.b	.3
	addq.w	#1,d7
	bra.b	.2
.3	move.w	BlkStrt(pc),d6
	sub.w	d6,d7
	addq.w	#1,d7
	move.w	d7,BlkLgth
	rts

;--------------------------------------;

Search	move.l	4.w,a6
	lea	DiskIO(pc),a1
	move.w	#14,28(a1)		;ChangeState
	jsr	DoIO(a6)
	tst.l	32(a1)
	beq.b	.1
	lea	MsNoDsk(pc),a5
	bsr.w	PrntMsg
	bra.w	WaitEvt

.1	move.b	#0,TSearch
	lea	GSearch(pc),a0
	move.l	WinHD1(pc),a1
	sub.l	a2,a2
	move.l	IntBase(pc),a6
	jsr	RefreshGadgets(a6)
	move.b	#1,TSearch
	move.l	#SrcStpT,TSearch+12
	lea	GSearch(pc),a0
	move.l	WinHD1(pc),a1
	sub.l	a2,a2
	jsr	RefreshGadgets(a6)
	move.l	#MBkStpT,MTBkSrc+12

	move.l	GfxBase(pc),a6
	move.l	RastPrt(pc),a1
	moveq	#0,d0
	jsr	SetAPen(a6)
	move.l	RastPrt(pc),a1
	move.l	#384,d0
	move.l	#13,d1
	move.l	#631,d2
	move.l	#82,d3
	jsr	RectFill(a6)

	move.w	#-1,BlkStrt
	lea	MsSrchg(pc),a5
	bsr.w	PrntMsg

	moveq	#0,d7
	lea	BlkStat(pc),a5
	move.w	#1760/2-1,d0
.2	move.w	d7,(a5)+
	dbf	d0,.2

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

.4	cmp.l	#$40,d6
	bne.b	.5
	move.l	28(a1),a0
	move.w	38(a0),d6
	jsr	ReplyMsg(a6)
	cmp.w	#"S",d6
	beq.b	.9
	bra.b	.6

.5	jsr	ReplyMsg(a6)
.6	move.l	d7,d0
	lsl.l	#8,d0
	add.l	d0,d0
	lea	DiskIO(pc),a1
	move.w	#2,28(a1)		;Load
	move.l	d0,44(a1)		;Start
	move.l	#JunkBlk,40(a1)		;Data
	move.l	#512,36(a1)		;Length
	jsr	DoIO(a6)

	cmp.w	#1,d7
	ble.b	.7
	bsr.w	TstBlck
	bne.b	.7
	moveq	#3,d0
	bra.b	.8
.7	moveq	#1,d0
.8	move.b	d0,(a5,d7)
	bsr.w	PrntBlk

	addq.w	#1,d7
	cmp.w	#1760,d7
	bne.w	.3

.9	move.l	4.w,a6
	lea	DiskIO(pc),a1
	move.w	#9,28(a1)		;Motor
	move.l	#0,36(a1)		;Length
	jsr	DoIO(a6)

	move.l	#MBkSrcT,MTBkSrc+12
	move.b	#0,TSearch
	lea	GSearch(pc),a0
	move.l	WinHD1(pc),a1
	sub.l	a2,a2
	move.l	IntBase(pc),a6
	jsr	RefreshGadgets(a6)
	move.b	#1,TSearch
	move.l	#SearchT,TSearch+12
	lea	GSearch(pc),a0
	move.l	WinHD1(pc),a1
	sub.l	a2,a2
	jsr	RefreshGadgets(a6)

	lea	MsReady(pc),a5
	bsr.w	PrntMsg
	bra.w	WaitEvt

;-------------------;

TstBlck	lea	JunkBlk,a0
	move.w	#127,d0
.1	tst.l	(a0)
	beq.b	.8
	lea	DosChck(pc),a1
	move.l	(a0),d2
	and.l	#$ffffff00,d2
	moveq	#11,d1
.2	cmp.l	(a1)+,d2
	beq.b	.8
	dbf	d1,.2
	bra.b	.9
.8	addq.l	#4,a0
	dbf	d0,.1
.9	addq.w	#1,d0
	tst.w	d0
	rts

;--------------------------------------;

PrntBlk	move.l	d7,d1
	divu	#(640/8),d1
	move.w	d1,d2
	swap	d1
	move.w	d1,d3
	add.w	d1,d1
	add.w	d3,d1
	move.w	d2,d3
	add.w	d2,d2
	add.w	d3,d2
	move.w	#388,d5
	move.w	#15,d6
	add.w	d1,d5
	add.w	d2,d6
	move.l	GfxBase(pc),a6
	move.l	RastPrt(pc),a1
	jsr	SetAPen(a6)
	move.w	d5,d0
	move.w	d6,d1
	jsr	WritePixel(a6)
	addq.w	#1,d5
	move.w	d5,d0
	move.w	d6,d1
	jsr	WritePixel(a6)
	subq.w	#1,d5
	addq.w	#1,d6
	move.w	d5,d0
	move.w	d6,d1
	jsr	WritePixel(a6)
	addq.w	#1,d5
	move.w	d5,d0
	move.w	d6,d1
	jsr	WritePixel(a6)
	rts

;--------------------------------------;

ViewBtB	move.l	4.w,a6
	lea	DiskIO(pc),a1
	move.w	#14,28(a1)		;ChangeState
	jsr	DoIO(a6)
	tst.l	32(a1)
	beq.b	.1
	lea	MsNoDsk(pc),a5
	bsr.w	PrntMsg
	bra.w	WaitEvt

.1	bsr.b	OpenWnB
	bne.b	.2
	lea	MsNWndw(pc),a5
	bsr.w	PrntMsg
	bra.w	WaitEvt

.2	bsr.w	ShowBtB
.3	move.l	4.w,a6
	move.l	WinHD3(pc),a0
	move.l	86(a0),a0
	move.l	a0,-(a7)
	jsr	WaitPort(a6)
	move.l	(a7)+,a0
	jsr	GetMsg(a6)
	move.l	d0,a1
	move.l	20(a1),d6
	cmp.l	#$200,d6
	beq.b	.4
	cmp.l	#$400,d6
	beq.b	.4
	jsr	ReplyMsg(a6)
	bra.b	.3
.4	bsr.b	ClseWnB
	bra.w	WaitEvt

OpenWnB	move.l	IntBase(pc),a6
	lea	WinDef3(pc),a0
	jsr	OpenWindow(a6)
	move.l	d0,WinHD3
	beq.b	.1
	move.l	d0,a0
	move.l	WinHD1(pc),a1
	move.l	86(a0),OldPrt3
	move.l	86(a1),86(a0)
	lea	BTitle(pc),a1
	lea	STitle(pc),a2
	jsr	SetWindowTitles(a6)
	move.l	WinHD3(pc),a0
	move.l	50(a0),a0
	lea	BBorder(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	jsr	DrawBorder(a6)
	moveq	#1,d0
.1	tst.l	d0
	rts

ClseWnB	move.l	IntBase(pc),a6
	move.l	OldPrt3(pc),d0
	move.l	WinHD3(pc),a0
	move.l	d0,86(a0)
	jsr	CloseWindow(a6)
	rts

ShowBtB	move.l	4.w,a6
	lea	DiskIO(pc),a1
	move.w	#2,28(a1)		;Load
	move.l	#0,44(a1)		;Start
	move.l	#JunkBlk,40(a1)		;Data
	move.l	#1024,36(a1)		;Length
	jsr	DoIO(a6)
	move.w	#9,28(a1)		;Motor
	move.l	#0,36(a1)		;Length
	jsr	DoIO(a6)
	
	lea	JunkBlk,a0
	move.l	#1024-1,d7
.1	move.b	(a0),d0
	cmp.b	#$1f,d0
	bhi.b	.2
	move.b	#".",(a0)
	bra.b	.3
.2	sub.b	#$80,d0
	cmp.b	#$1f,d0
	bhi.b	.3
	move.b	#".",(a0)
.3	addq.l	#1,a0
	dbf	d7,.1

	lea	JunkBlk,a4
	moveq	#22,d6
	moveq	#16-1,d7
	move.l	GfxBase(pc),a6
	move.l	WinHD3(pc),a5
	move.l	50(a5),a1
	moveq	#1,d0
	jsr	SetAPen(a6)
.4	move.l	50(a5),a1
	moveq	#64,d0
	move.l	d6,d1
	jsr	Move(a6)
	move.l	50(a5),a1
	move.l	a4,a0
	moveq	#64,d0
	jsr	Text(a6)
	addq.l	#8,d6
	lea	64(a4),a4
	dbf	d7,.4
	rts

;--------------------------------------;

LoadBtB	bsr.w	LRquest
	bne.w	WaitEvt
	bsr.w	FleExst
	bne.w	WaitEvt
	bsr.b	FndBtLn
	bne.w	WaitEvt
	bsr.b	FBtRead
	bne.w	WaitEvt
	bsr.w	WaitDsk
	bne.w	WaitEvt
	bsr.w	WrteBtB
	bne.w	WaitEvt
	lea	MsReady(pc),a5
	bsr.w	PrntMsg
	bra.w	WaitEvt

;-------------------;

FndBtLn	move.l	FleLock(pc),d1
	move.l	#InfoBlk,d2
	jsr	Examine(a6)
	move.l	FleLock(pc),d1
	jsr	UnLock(a6)
	lea	InfoBlk,a0
	move.l	124(a0),d0
	cmp.l	#1024,d0
	beq.b	.1
	lea	MsNotBt(pc),a5
	bsr.w	PrntMsg
	bra.b	.3
.1	moveq	#0,d0
.2	tst.l	d0
	rts
.3	moveq	#-1,d0
	bra.b	.2

;-------------------;

FBtRead	move.l	DosBase(pc),a6
	move.l	#RealNme,d1
	move.l	#1005,d2
	jsr	Open(a6)
	move.l	d0,FleName
	bne.b	.1
	lea	MsNoOpn(pc),a5
	bsr.w	PrntMsg
	bra.b	.5

.1	move.l	DosBase(pc),a6
	move.l	FleName(pc),d1
	move.l	#JunkBlk,d2
	move.l	#1024,d3
	jsr	Read(a6)
	tst.l	d0
	bpl.b	.2
	move.l	FleName(pc),d1
	jsr	Close(a6)
	lea	MsNRead(pc),a5
	bsr.w	PrntMsg
	bra.b	.5

.2	move.l	FleName(pc),d1
	jsr	Close(a6)
	lea	JunkBlk,a0
	move.l	(a0),d0
	lsr.l	#8,d0
	cmp.l	#"DOS",d0
	beq.b	.3
	lea	MsNotBt(pc),a5
	bsr.w	PrntMsg
	bra.b	.5

.3	moveq	#0,d0
.4	tst.l	d0
	rts
.5	moveq	#-1,d0
	bra.b	.4

;--------------------------------------;

SaveBtB	move.l	4.w,a6
	lea	DiskIO(pc),a1
	move.w	#14,28(a1)		;ChangeState
	jsr	DoIO(a6)
	tst.l	32(a1)
	beq.b	.1
	lea	MsNoDsk(pc),a5
	bsr.w	PrntMsg
	bra.w	WaitEvt

.1	bsr.w	ReadBtB
	bsr.w	SRquest
	bne.w	WaitEvt
	bsr.b	WrteBtF
	bne.w	WaitEvt
	lea	MsReady(pc),a5
	bsr.w	PrntMsg
	bra.w	WaitEvt

;-------------------;

WrteBtF	move.l	DosBase(pc),a6
	move.l	#RealNme,d1
	move.l	#1006,d2
	jsr	Open(a6)
	move.l	d0,FleName
	bne.b	.1
	lea	MsNWrte(pc),a5
	bsr.w	PrntMsg
	bra.b	.9
.1	move.l	d0,d1
	move.l	#JunkBlk,d2
	move.l	#1024,d3
	jsr	Write(a6)
	move.l	FleName(pc),d1
	jsr	Close(a6)
	moveq	#0,d0
.8	tst.l	d0
	rts
.9	moveq	#-1,d0
	bra.b	.8

;-------------------;

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
.2	bsr.w	JoinFle
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

Clculte	bsr.w	WaitDsk
	bne.w	WaitEvt
	bsr.b	ReadBtB
	bne.w	WaitEvt
	bsr.w	CalcChk
	bsr.b	WrteBtB
	bne.w	WaitEvt
	lea	MsReady(pc),a5
	bsr.w	PrntMsg
	bra.w	WaitEvt

;--------------------------------------;

ReadBtB	move.l	4.w,a6
	lea	DiskIO(pc),a1
	move.w	#2,28(a1)		;Load
	move.l	#0,44(a1)		;Start
	move.l	#JunkBlk,40(a1)		;Data
	move.l	#1024,36(a1)		;Length
	jsr	DoIO(a6)
	move.w	#9,28(a1)		;Motor
	move.l	#0,36(a1)		;Length
	jsr	DoIO(a6)
	rts

;--------------------------------------;

WrteBtB	lea	MsInstg(pc),a5
	bsr.w	PrntMsg
	move.l	4.w,a6
	lea	DiskIO(pc),a1
	move.w	#3,28(a1)		;Write
	move.l	#0,44(a1)		;Start
	move.l	#JunkBlk,40(a1)		;Data
	move.l	#1024,36(a1)		;Length
	jsr	DoIO(a6)
	move.w	#4,28(a1)		;Update
	move.l	#0,36(a1)		;Length
	jsr	DoIO(a6)
	move.l	d0,d7
	move.w	#9,28(a1)		;Motor
	move.l	#0,36(a1)		;Length
	jsr	DoIO(a6)

	cmp.b	#28,d7
	bne.b	.1
	lea	MsWProt(pc),a5
	bsr.w	PrntMsg
	bra.b	.3

.1	moveq	#0,d0
.2	tst.l	d0
	rts
.3	moveq	#-1,d0
	bra.b	.2

;--------------------------------------;

CalcChk	lea	JunkBlk,a0
	moveq	#0,d0
	moveq	#0,d1
	move.l	d0,4(a0)
	move.w	#255,d0
	move.l	a0,a1
.1	add.l	(a1)+,d1
	bcc.b	.2
	addq.w	#1,d1
.2	dbf	d0,.1
	not.l	d1
	move.l	d1,4(a0)
	rts

;--------------------------------------;

WaitDsk	bsr.w	OpenWnW
	bne.b	.1
	lea	MsNWndw(pc),a5
	bsr.w	PrntMsg
	bra.w	.8
.1	bsr.w	DrawWnW
	bsr.w	TextWnW
.2	move.l	4.w,a6
	move.l	WinHD2(pc),a0
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
	cmp.w	#"*O",d7
	beq.b	.4
	cmp.w	#"*C",d7
	beq.b	.5
	bra.b	.2
.4	move.l	4.w,a6
	lea	DiskIO(pc),a1
	move.w	#14,28(a1)		;ChangeState
	jsr	DoIO(a6)
	tst.l	32(a1)
	beq.b	.6
	lea	MsNoDsk(pc),a5
	bsr.w	PrntMsg
	bra.b	.2
.5	bsr.b	ClseWnW
	lea	MsNInst(pc),a5
	bsr.w	PrntMsg
	bra.b	.8

.6	bsr.b	ClseWnW
	moveq	#0,d0
.7	tst.l	d0
	rts
.8	moveq	#-1,d0
	bra.b	.7

;-------------------;

OpenWnW	move.l	IntBase(pc),a6
	lea	WinDef2(pc),a0
	jsr	OpenWindow(a6)
	move.l	d0,WinHD2
	beq.b	.1
	move.l	d0,a0
	move.l	WinHD1(pc),a1
	move.l	86(a0),OldPrt2
	move.l	86(a1),86(a0)
	sub.l	a1,a1
	lea	STitle(pc),a2
	jsr	SetWindowTitles(a6)
	moveq	#1,d0
.1	tst.l	d0
	rts

ClseWnW	move.l	IntBase(pc),a6
	move.l	OldPrt2(pc),d0
	move.l	WinHD2(pc),a0
	move.l	d0,86(a0)
	jsr	CloseWindow(a6)
	rts

DrawWnW	move.l	IntBase(pc),a6
	move.l	WinHD2(pc),a0
	move.l	50(a0),a0
	lea	ImgIcon(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	jsr	DrawImage(a6)
	rts

TextWnW	lea	TDrveNo(pc),a0
	move.l	12(a0),d0
	lea	DrveTxt(pc),a0
	move.l	d0,12(a0)
	move.l	IntBase(pc),a6
	move.l	WinHD2(pc),a5
	move.l	50(a5),a0
	lea	IconTxt(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	jsr	PrintIText(a6)
	rts

;--------------------------------------;

AscConv	moveq	#0,d1
	divu	#1000,d0
	add.w	d0,d1
	beq.b	.1
	bsr.b	.4
.1	clr.w	d0
	swap	d0
	divu	#100,d0
	add.w	d0,d1
	beq.b	.2
	bsr.b	.4
.2	clr.w	d0
	swap	d0
	divu	#10,d0
	add.w	d0,d1
	beq.b	.3
	bsr.b	.4
.3	clr.w	d0
	swap	d0
	bsr.b	.4
	clr.b	(a0)
	rts
.4	add.w	#$30,d0
	move.b	d0,(a0)+
	rts

;--------------------------------------;

DecConv	moveq	#0,d0
	moveq	#0,d1
.1	move.b	(a0)+,d1
	beq.b	.2
	sub.w	#"0",d1
	mulu	#10,d0
	add.w	d1,d0
	bra.b	.1
.2	rts

;--------------------------------------;

HexConv	moveq	#0,d0
	moveq	#0,d1
.1	move.b	(a0)+,d1
	beq.b	.3
	sub.w	#"A",d1
	bcc.b	.2
	add.w	#7,d1
.2	add.w	#10,d1
	lsl.l	#4,d0
	or.w	d1,d0
	bra.b	.1
.3	rts

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

RastPrt	dc.l	0
WinHD1	dc.l	0
WinDef1	dc.w	0,11			;X & Y
	dc.w	640,87			;Width & Height
	dc.b	1,2			;Colours
	dc.l	$368			;IDCMP
	dc.l	$100e			;Flags
	dc.l	Gadgets			;Gadgets
	dc.l	0			;CheckMark
	dc.l	WTitle			;Title
	dc.l	0			;Screen
	dc.l	0			;BitMap
	dc.w	640,87			;X & Y Min
	dc.w	640,87			;X & Y Max
	dc.w	1			;Type

;-------------------;

OldPrt2	dc.l	0
WinHD2	dc.l	0
WinDef2	dc.w	254,22			;X & Y
	dc.w	132,76			;Width & Height
	dc.b	1,2			;Colours
	dc.l	$40			;IDCMP
	dc.l	$1002			;Flags
	dc.l	GOkay			;Gadgets
	dc.l	0			;CheckMark
	dc.l	0			;Title
	dc.l	0			;Screen
	dc.l	0			;BitMap
	dc.w	132,76			;X & Y Min
	dc.w	132,76			;X & Y Max
	dc.w	1			;Type

;-------------------;

OldPrt3	dc.l	0
WinHD3	dc.l	0
WinDef3	dc.w	0,11			;X & Y
	dc.w	640,151			;Width & Height
	dc.b	1,2			;Colours
	dc.l	$600			;IDCMP
	dc.l	$1100e			;Flags
	dc.l	0			;Gadgets
	dc.l	0			;CheckMark
	dc.l	BTitle			;Title
	dc.l	0			;Screen
	dc.l	0			;BitMap
	dc.w	640,150			;X & Y Min
	dc.w	640,150			;X & Y Max
	dc.w	1			;Type

;--------------------------------------;

SImages
ImgTtle	IImage	ImgGdNx,420,26,180,43,3,2,ImTitle
ImgGdNx	IImage	ImgMrk1,131,61,16,9,3,2,ImgNext
ImgMrk1	IImage	ImgMrk2,340,16,8,4,1,2,ImgMark
ImgMrk2	IImage	ImgMrk3,340,33,8,4,3,2,ImgMark
ImgMrk3	IImage	0,340,50,8,4,2,2,ImgMark
MrkTxt1	IText	MrkTxt2,328,23,1,0,0,0,KeyTxt1
MrkTxt2	IText	MrkTxt3,320,40,1,0,0,0,KeyTxt2
MrkTxt3	IText	MrkTxt4,312,57,1,0,0,0,KeyTxt3
MrkTxt4	IText	0,312,74,1,0,0,0,KeyTxt4

ImgIcon	IImage	0,34,28,64,32,3,2,DskIcon
IconTxt	IText	DrveTxt,10,12,1,0,0,0,DskIcnT
DrveTxt	IText	0,50,20,1,0,0,0,0

;--------------------------------------;

Menu
MTPrjct	MTitle	0,2,0,64,MPrjctT,MIBtBlk
MIBtBlk	MItem	MIInsrt,0,0*9,102,9,$52,0,MTBtBlk,SIViewB
MTBtBlk	IText	0,3,1,1,0,0,0,MBtBlkT
SIViewB	MSubItm	SILoadB,90,0*9-1,(8*8)+6,9,$52,0,STViewB
STViewB	IText	0,3,1,1,0,0,0,SViewBT
SILoadB	MSubItm	SISaveB,90,1*9-1,(8*8)+6,9,$52,0,STLoadB
STLoadB	IText	0,3,1,1,0,0,0,SLoadBT
SISaveB	MSubItm	SICalcB,90,2*9-1,(8*8)+6,9,$52,0,STSaveB
STSaveB	IText	0,3,1,1,0,0,0,SSaveBT
SICalcB	MSubItm	0,90,3*9-1,(8*8)+6,9,$52,0,STCalcB
STCalcB	IText	0,3,1,1,0,0,0,SCalcBT
MIInsrt	MItem	MIBkSrc,0,1*9,102,9,$52,0,MTInsrt,0
MTInsrt	IText	0,3,1,1,0,0,0,MInsrtT
MIBkSrc	MItem	MIDrive,0,2*9,102,9,$52,0,MTBkSrc,0
MTBkSrc	IText	0,3,1,1,0,0,0,MBkSrcT
MIDrive	MItem	MIAbout,0,3*9,102,9,$52,0,MTDrive,0
MTDrive	IText	0,3,1,1,0,0,0,MDriveT
MIAbout	MItem	MIQuitP,0,4*9,102,9,$52,0,MTAbout,SIAbtI1
MTAbout	IText	0,3,1,1,0,0,0,MAboutT
SIAbtI1	MSubItm	SIAbtI2,90,0*9-1,304,9,$d2,0,STAbtI1
STAbtI1	IText	0,80,1,1,0,0,0,SAbtI1T
SIAbtI2	MSubItm	SIAbtI3,90,2*9-1,304,9,$d2,0,STAbtI2
STAbtI2	IText	0,76,1,1,0,0,0,SAbtI2T
SIAbtI3	MSubItm	SIAbtI4,90,3*9-1,304,9,$d2,0,STAbtI3
STAbtI3	IText	0,124,1,1,0,0,0,SAbtI3T
SIAbtI4	MSubItm	SIAbtI5,90,4*9-1,304,9,$d2,0,STAbtI4
STAbtI4	IText	0,88,1,1,0,0,0,SAbtI4T
SIAbtI5	MSubItm	SIAbtI6,90,5*9-1,304,9,$d2,0,STAbtI5
STAbtI5	IText	0,116,1,1,0,0,0,SAbtI5T
SIAbtI6	MSubItm	SIAbtI7,90,6*9-1,304,9,$d2,0,STAbtI6
STAbtI6	IText	0,116,1,1,0,0,0,SAbtI6T
SIAbtI7	MSubItm	SIAbtI8,90,7*9-1,304,9,$d2,0,STAbtI7
STAbtI7	IText	0,108,1,1,0,0,0,SAbtI7T
SIAbtI8	MSubItm	0,90,9*9-1,304,9,$d2,0,STAbtI8
STAbtI8	IText	0,56,1,1,0,0,0,SAbtI8T
MIQuitP	MItem	0,0,5*9,102,9,$52,0,MTQuitP,0
MTQuitP	IText	0,3,1,1,0,0,0,MQuitPT

;--------------------------------------;

Gadgets
GStartB	GadNmbr	GBkSize,124,14,6,SBrder1,TStartB,SStartB,5,"N2"
TStartB	IText	0,-104,0,1,0,0,0,StartBT
GBkSize	GadNmbr	GLdAdrs,124,26,6,SBrder1,TBkSize,SBkSize,5,"N3"
TBkSize	IText	0,-104,0,1,0,0,0,BkSizeT
GLdAdrs	GadNmbr	GJmAdrs,124,38,6,SBrder1,TLdAdrs,SLdAdrs,6,"N4"
TLdAdrs	IText	0,-108,0,1,0,0,0,LdAdrsT
GJmAdrs	GadNmbr	GNullSt,124,50,6,SBrder1,TJmAdrs,SJmAdrs,6,"N1"
TJmAdrs	IText	0,-108,0,1,0,0,0,JmAdrsT
GNullSt	GadNull	GNullSz,6,12,180,12,"N1"
GNullSz	GadNull	GNullLd,6,24,180,12,"N2"
GNullLd	GadNull	GNullJm,6,36,180,12,"N3"
GNullJm	GadNull	GInsert,6,48,180,12,"N4"
GInsert	GadText	GSearch,6,60,60,12,GBrder1,GBrder2,TInsert,"I"
TInsert	IText	0,6,2,1,0,0,0,InsertT
GSearch	GadText	GDrveNo,66,60,60,12,GBrder1,GBrder2,TSearch,"S"
TSearch	IText	0,6,2,1,0,0,0,SearchT
GDrveNo	GadText	0,126,60,60,12,GBrder1,GBrder2,TDrveNo,"D"
TDrveNo	IText	0,25,2,1,0,0,0,DrveNoT

GOkay	GadText	GCancel,6,61,60,12,GBrder1,GBrder2,TOkay,"*O"
TOkay	IText	0,22,2,1,0,0,0,OkayT
GCancel	GadText	0,66,61,60,12,GBrder1,GBrder2,TCancel,"*C"
TCancel	IText	0,6,2,1,0,0,0,CancelT

;--------------------------------------;

Border1	Border	6,72,300,12,2,1,Border2
Border2	Border	382,12,252,72,2,1,Border3
Border3	Border	306,12,76,72,2,1,Border4
Border4	Border	186,12,120,60,2,1,Border5
Border5	Border	336,14,16,8,2,1,Border6
Border6	Border	336,31,16,8,2,1,Border7
Border7	Border	336,48,16,8,2,1,Border8
Border8	Border	336,65,16,8,2,1,0

GBrder1	Border	0,0,60,12,2,1,0
GBrder2	Border	0,0,60,12,1,2,0
SBrder1	Border	-4,-1,64,10,1,2,SBrder2
SBrder2	Border	-118,-2,180,12,2,1,0

BBorder	Border	40,14,560,132,1,2,0

;--------------------------------------;

LdGText	dc.b	"_Load",0
SvGText	dc.b	"_Save",0
LoadTxt	dc.b	"Choose A File To Load",0
SaveTxt	dc.b	"Choose A File To Save",0

MsReady	dc.b	6,"READY."
MsNoDsk	dc.b	16,"NO DISK IN DRIVE"
MsSrchg	dc.b	12,"SEARCHING..."
MsNoMem	dc.b	13,"OUT OF MEMORY"
MsNoSel	dc.b	16,"NO FILE SELECTED"
MsNoFle	dc.b	19,"FILE DOES NOT EXIST"
MsEmpty	dc.b	13,"FILE IS EMPTY"
MsNoSze	dc.b	15,"FILE IS TOO BIG"
MsNoOpn	dc.b	14,"CANT OPEN FILE"
MsNRead	dc.b	14,"CANT READ FILE"
MsNWrte	dc.b	15,"CANT WRITE FILE"
MsWProt	dc.b	23,"DISK IS WRITE PROTECTED"
MsNWndw	dc.b	19,"COULDNT OPEN WINDOW"
MsNInst	dc.b	13,"NOT INSTALLED"
MsInstg	dc.b	13,"INSTALLING..."
MsNotBt	dc.b	20,"NOT A BOOTBLOCK FILE"

OkayT	dc.b	"OK",0
CancelT	dc.b	"CANCEL",0
InsertT	dc.b	"INSERT",0
SearchT	dc.b	"SEARCH",0
SrcStpT	dc.b	" STOP",0
StartBT	dc.b	"START BLOCK",0
BkSizeT	dc.b	"BLOCKS SIZE",0
LdAdrsT	dc.b	"LOAD ADDRESS",0
JmAdrsT	dc.b	"JUMP ADDRESS",0
KeyTxt1	dc.b	"USED",0
KeyTxt2	dc.b	"UNUSED",0
KeyTxt3	dc.b	"SELECTED",0
KeyTxt4	dc.b	"NO CHECK",0
DrveNoT	dc.b	"DF0:",0
	dc.b	"DF1:",0
	dc.b	"DF2:",0
	dc.b	"DF3:",0
DskIcnT	dc.b	"INSERT DISK IN",0
	even

MPrjctT	dc.b	"Project",0
MBtBlkT	dc.b	"BootBlock  »",0
SViewBT	dc.b	"View",0
SLoadBT	dc.b	"Load",0
SSaveBT	dc.b	"Save",0
SCalcBT	dc.b	"Checksum",0
MInsrtT	dc.b	"Insert",0
MBkSrcT	dc.b	"Search",0
MBkStpT	dc.b	"Stop",0
MDriveT	dc.b	"Drive DF0:",0
MAboutT	dc.b	"About",0
MQuitPT	dc.b	"Quit",0

SAbtI1T	dc.b	"»» INTROINS 1.2 ««",0
SAbtI2T	dc.b	"SEND BUG REPORTS TO",0
SAbtI3T	dc.b	"FRANTIC",0
SAbtI4T	dc.b	"27 BOUNDARY ROAD",0
SAbtI5T	dc.b	"TIKIPUNGA",0
SAbtI6T	dc.b	"WHANGAREI",0
SAbtI7T	dc.b	"NEW ZEALAND",0
SAbtI8T	dc.b	"THIS PRODUCT IS FREEWARE",0
	dc.b	"$VER: "
WTitle	dc.b	"IntroIns 1.2  -  Copyright © 1994 by Frantic, Freeware",0
STitle	dc.b	"IntroIns 1.2",0
BTitle	dc.b	"Ascii Dump of Boot Block",0
	even

;--------------------------------------;

SStartB	dc.b	"0",0,0,0,0
SBkSize	dc.b	"0",0,0,0,0
SLdAdrs	dc.b	"60000",0,0
SJmAdrs	dc.b	"60000",0,0

BStartB	dc.l	0
BBkSize	dc.l	0

FileReq	dc.l	0
FleLock	dc.l	0
FleSize	dc.l	0
FleLgth	dc.l	0
FleName	dc.l	0
FleAllc	dc.l	0
RplyPrt	dcb.l	8,0
DiskIO	dcb.l	20,0
BlkStrt	dc.w	-1
BlkLgth	dc.w	0
BlkStat	dcb.b	1760,0
BlkStatE dc.b	0
DriveNo	dc.b	0
DOSChck	dc.l	"DOS"<<8
	dc.l	"DOW"<<8
	dc.l	"DO["<<8
	dc.l	"D_S"<<8
	dc.l	"D_W"<<8
	dc.l	"D_["<<8
	dc.l	"DoS"<<8
	dc.l	"DoW"<<8
	dc.l	"Do["<<8
	dc.l	"DS"<<8
	dc.l	"DW"<<8
	dc.l	"D["<<8

ReqBase	dc.b	"reqtools.library",0,0
DosBase	dc.b	"dos.library",0
GfxBase	dc.b	"graphics.library",0,0
IntBase	dc.b	"intuition.library",0
TrDName	dc.b	"trackdisk.device",0,0

;--------------------------------------;

SctrLdr	movem.l	d0-a6,-(a7)
	move.w	#2,$1c(a1)
IntLgth	move.l	#0,$24(a1)
DestAdd	move.l	#0,$28(a1)
BkOffst	move.l	#0,$2c(a1)
	jsr	-456(a6)
	move.w	#9,$1c(a1)
	clr.l	36(a1)
	jsr	-456(a6)
JumpAdd	jsr	0
	nop
	movem.l	(a7)+,d0-a6
SctrEnd

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
JunkBlk	dcb.b	1024,0
EndBoot
ImgMark	dcb.w	2*4,-1
ImTitle	incbin	"DH2:IntroIns/IntroIns.raw"
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

DskIcon	include	"DH2:IntroIns/WaitDisk.i"

	END
