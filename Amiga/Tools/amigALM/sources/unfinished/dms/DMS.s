	include	"DH1:DMSWin/Macros.i"

;--------------------------------------;

OpenWindow	= -204
CloseWindow	= -72
WBToFront	= -342
WBToBack	= -336

;--------------------------------------;

OpenLibrary	= -552
CloseLibrary	= -414
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
	cmp.l	#$40,d6
	beq.b	FindGad
	jsr	ReplyMsg(a6)
	bra.b	WaitEvt

FindGad	moveq	#0,d4
	move.l	28(a1),a0
	move.w	38(a0),d7
	jsr	ReplyMsg(a6)
	cmp.w	#0,d7
	beq.w	LedChng
	bra.b	WaitEvt

LedChng	bchg	#1,$bfe001
	bra.b	WaitEvt

;--------------------------------------;

WinHD1	dc.l	0
WinDef1	dc.w	0,11			;X & Y
	dc.w	590,130			;Width & Height
	dc.b	0,1			;Colours
	dc.l	$240			;IDCMP
	dc.l	$1100e			;Flags
	dc.l	Gadgets			;Gadgets
	dc.l	0			;CheckMark
	dc.l	WnTitle			;Title
	dc.l	0			;Screen
	dc.l	0			;BitMap
	dc.w	508,130			;X & Y Min
	dc.w	508,130			;X & Y Max
	dc.w	1			;Type
WnTitle	dc.b	"DMS Win",0

;--------------------------------------;
;Next,X,Y,Sel1,Sel2,Text,TextLen,ID 

Gadgets
GdRead	GadText	GdWrite,8,13,GBrder1,GBrder2,TxRead,4,"RD"
GdWrite	GadText	GdAppnd,90,13,GBrder1,GBrder2,TxWrite,5,"WR"
GdAppnd	GadText	GdRepck,172,13,GBrder1,GBrder2,TxAppnd,6,"AP"
GdRepck	GadText	GdView,254,13,GBrder1,GBrder2,TxRepck,6,"RE"
GdView	GadText	GdText,336,13,GBrder1,GBrder2,TxView,4,"VI"
GdText	GadText	GdTest,418,13,GBrder1,GBrder2,TxText,4,"TX"
GdTest	GadText	0,500,13,GBrder1,GBrder2,TxTest,4,"TE"

;--------------------------------------;

GBrder1	Border	0,0,0,82,13,2,1
GBrder2	Border	0,0,0,82,13,1,2

;--------------------------------------;

TxRead	dc.b	"READ",0
TxWrite	dc.b	"WRITE",0
TxAppnd	dc.b	"APPEND",0
TxRepck	dc.b	"REPACK",0
TxView	dc.b	"VIEW",0
TxText	dc.b	"TEXT",0
TxTest	dc.b	"TEST",0

;--------------------------------------;

IntName	dc.b	"intuition.library",0
IntBase	dc.l	0

	END



GdRead	GadText	GdWrite,8,13,82,13,GBrder1,GBrder2,GTRead,"RD"
GdWrite	GadText	GdView,90,13,82,13,GBrder1,GBrder2,GTWrite,"WT"
GdView	GadText	GdTest,172,13,82,13,GBrder1,GBrder2,GTView,"VW"
GdTest	GadText	GdText,254,13,82,13,GBrder1,GBrder2,GTTest,"TS"
GdText	GadText	GdRPack,336,13,82,13,GBrder1,GBrder2,GTText,"TX"
GdRPack	GadText	GdFlDsk,418,13,82,13,GBrder1,GBrder2,GTRPack,"RP"

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

