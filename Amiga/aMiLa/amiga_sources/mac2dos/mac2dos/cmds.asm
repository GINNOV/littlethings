*****************************************************************
*								*
*	Mac-2-Dos High Level Commands (except COPY)		*
*								*
*	Copyright (c) 1989 Central Coast Software		*
*	424 Vista Avenue, Golden, CO 80401			*
*	     All rights reserved, worldwide			*
*								*
*****************************************************************

;	INCLUDE	"MAC.I"	
;	INCLUDE	"VD0:MACROS.ASM"
;	INCLUDE	"BOXES.ASM"
	INCLUDE	"PRE.OBJ"

	XDEF	TypeFile,DeleteFile
	XDEF	BinaryConv,AsciiConv,MacPaintConv
	XDEF	PostConv,MacBinConv
	XDEF	IncAll,IncName,ExcAll,ExcName
	XDEF	CpyCancel
	XDEF	OpenCopyWind,CloseCopyWind,UpdateCopyWind
	XDEF	InitDosList,NextDosFile
	XDEF	InitMacList,NextMacFile
	XDEF	CalcTotBlks
	XDEF	UpdateBlocks
	XDEF	ExcDos,ExcMac
	XDEF	LoadConvParams
	XDEF	SkipFile,ProcFile
	XDEF	DeleteCurFib

	XDEF	ConvFlag
	XDEF	EofFlag
	XDEF	AbortFlg
	XDEF	TotFilCnt
	XDEF	InputPtr,OutputPtr
	XDEF	CpyMacAmy.,CpyAmyMac.,CpyDirPtr
	XDEF	CurFib,ActFilCnt
	XDEF	InputByteCount,OutputByteCount
;	XDEF	ActualBlks
	XDEF	AskDel1.,AskDel3.
	XDEF	Bin1.,Bin2.,Bin3.
	XDEF	Tool1.,Tool2.
	XDEF	IncNam.,ExcNam.,Wild.
	XDEF	ProgressCount

* Externals in MAC.ASM

	XREF	DisableMenu,EnableMenu			;gec 1/23/90

* Externals in COPY.ASM

	XREF	NoMacFiles.,NoDosFiles.
	XREF	GetMacChar,GetDosChar
	XREF	BlkCntFlg

* Externals in Mac.asm

	XREF	RefreshDirWind
	XREF	WaitForMsg

	XREF	MacToAmy
	XREF	SysBase,DosBase,IntuitionBase,GraphicsBase
	XREF	WINDOW,RefreshRoutine
	XREF	AskAmyFlg,AskMacFlg
	XREF	OptionsBuffer

* EXTERNALS IN DOSFILES AND MACFILES

	XREF	CreateDosFile,OpenDosFile,CloseDosFile,DeleteDosFile
	XREF	CreateMacFile,OpenMacFile,CloseMacFile,DeleteMacFile
	XREF	AppendDosPath,TruncateDosPath
;	XREF	CurrentDosPath
	XREF	ReadDosBlock,WriteDosBlock
	XREF	ReadMacBlock,WriteMacBlock
	XREF	GetVolName
	XREF	DosSeek,WriteDosFile
	XREF	FlushMacDirectory
	XREF	CheckMacDrive,CheckDosVol

	XREF	TMP.,TMP2.
	XREF	MacRootLevel,MacCurLevel
	XREF	DosRootLevel,DosCurLevel
	XREF	DosBytCnt,MacBytCnt
	XREF	MacVolName.,MacPath.
	XREF	DosVolName.,DosPath.
	XREF	AllocBlkSizeW
	XREF	MacType,MacCreator
	XREF	ValidMacVol,ValidDosVol
	XREF	DefaultTool.

* EXTERNALS IN WIND.ASM

	XREF	DosFileCnt,MacFileCnt
	XREF	UpdateDosWindow,UpdateMacWindow
	XREF	ReloadDosSpace,UpdateMacSpace

* EXTERNALS IN FUN

	XREF	AddGadgets,RemoveGadgets,ClearWindow
	XREF	StripAppend
	XREF	DISP_MSG
	XREF	OpenRequester,CloseRequester
	XREF	WaitRequester,CancelRequester

* Externals in Gadgets.asm

	XREF	GadgetList,CancelGad,SkipGad,ProcGad
	XREF	AskDelTxt
	XREF	RQTxtBuf0.
	XREF	ReqMacType,ReqMacCreator
	XREF	ReqAmyTool,ToolTxt,BinTxt
	XREF	REQUEST,REQTXT,REQGAD
	XREF	ReqNameGad
	XREF	NamBuf
	XREF	INamTxt,ENamTxt

* Externals in Disk.asm

	XREF	MotorOff
	XREF	GetDriveStatus
	XREF	CheckWrtProt

* Externals in XLATE.asm

	XREF	MAXlate

LineBufSize	EQU	80
MaxLines	EQU	20
Type_LE		EQU	4
Type_TE		EQU 	12
Page_LE		EQU	Type_LE
Page_TE		EQU	Type_TE+10
Page_WD		EQU	634
Page_HT		EQU	MaxLines*8+2
TypeCnt		EQU	(638-Type_LE)/8

* Screen positions for status msgs on CopyWindow

Title_LE	EQU	256
Title_TE	EQU	22

CpyDir_LE	EQU	196
CpyDir_TE	EQU	46

* This next ??_LE sets the left edge for all remaining items

FilCnt_LE	EQU	80
FilCnt_TE	EQU	70

From_LE		EQU	FilCnt_LE
From_TE		EQU	94

To_LE		EQU	FilCnt_LE
To_TE		EQU	118

Trans_LE	EQU	FilCnt_LE
Trans_TE	EQU	142

BlkCnt_LE	EQU	FilCnt_LE
BlkCnt_TE	EQU	166

FromCnt		EQU	(638-From_LE)/8
ToCnt		EQU	(638-To_LE)/8

TypeFile:
	CLR.L	CurFib			;nothing selected
	CLR.B	AbortFlg
	CLR.B	BlkCntFlg
	IFZB	MacToAmy,TypeAmy,L	;type Amiga file
	
* Type Mac file

	BSR	CheckMacDrive
	ERROR	9$
	MOVE.W	MacFileCnt,TotFilCnt	;any files selected?
	IFNZW	MacFileCnt,1$		;yes
	DispErr	NoMacFiles.
	BRA.S	9$
1$:	BSR	OpenTypeWind
	BSR	InitMacList		;prepare to work Mac list
2$:	BSR	NextMacFile		;scan list for next selected file
	ERROR	8$			;no more files
	BSR	UpdateTypeWind		;show what we are doing
	BSR	ErasePage
	ZAP	D0			;data fork
	BSR	OpenMacFile		;else open that sucker
	ERROR	7$			;cant open file
	BSR	TypeFileContents	;type contents of file
	BSR	CloseMacFile
7$:	IFZB	AbortFlg,2$		;no abort
8$:	BSR	CloseTypeWind		;restore dir window
9$:	RTS

TypeAmy:
	BSR	CheckDosVol
	ERROR	9$
	MOVE.W	DosFileCnt,TotFilCnt	;any files selected?
	BNE.S	1$			;yes
	DispErr	NoDosFiles.
	BRA.S	9$
1$:	BSR	OpenTypeWind
	BSR	InitDosList		;prepare to work Dos list
2$:	BSR	NextDosFile		;scan list for next selected file
	ERROR	8$			;no more files
	BSR	UpdateTypeWind		;show what we are doing
	BSR	ErasePage
	BSR	OpenDosFile		;else open that sucker
	ERROR	7$			;cant open file
	BSR	TypeFileContents	;display contents
	BSR	CloseDosFile
7$:	IFZB	AbortFlg,2$		;no abort
8$:	BSR	CloseTypeWind		;restore dir window
9$:	RTS

TypeFileContents:
	PUSH	D2/A2
	LEA	MAXlate,A2		;for Mac to Dos xlate
	CLR.W	InputByteCount		;start with nothing
	CLR.W	OutputByteCount
	MOVE.L	#LineBuffer,OutputPtr	;init output buffer
	CLR.W	LineCount		;count of lines per page
1$:	IFZB	MacToAmy,2$		;input from Amiga
	BSR	GetMacChar		;get next Mac char
	ERROR	7$
	MOVE.B	0(A2,D0.W),D0		;convert to Dos char
	BNE.S	3$
	MOVEQ	#'?',D0
	BRA.S	3$
2$:	BSR	GetDosChar
	ERROR	7$
3$:	IFGEIB	D0,#32,5$		;not control...just print
	IFNEIB	D0,#9,4$		;not tab...
	MOVE.W	OutputByteCount,D2	;else interpret tab char
	AND.W	#7,D2
	NEG.W	D2
	ADDQ.W	#7,D2			;8-1
8$:	MOVE.B	#' ',D0			;store a blank
	BSR	PutLineChar
	DBF	D2,8$
	BRA.S	1$
4$:	IFEQIB	D0,#10,6$		;end of line
	IFNEIB	D0,#13,1$		;else ignore char
6$:	BSR	FlushLineBuffer
	ERROR	9$			;op wants to exit this file, at least
	BRA.S	1$			;...and go on
5$:	BSR	PutLineChar
	BRA.S	1$			;loop till end of file

* Come here on end of file.

7$:	BSR	FlushLineBuffer		;make sure last line gets on screen
	MOVE.W	#ORANGE*256+BLUE,D1	;force eof msg into orange
	LEA	Eof.,A0
	BSR	FlushLine		;display file eof msg
	IFZW	LineCount,9$		;that was last line
	BSR	WaitForInput		;wait for op to act
9$:	POP	D2/A2
	RTS				;return in any case

* Wait for op to read page and tell us what to do.

WaitForInput:
	BSR	MotorOff		;turn Mac drive off, while we wait
	CLR.B	ProcFlg			;wait for something to happen
	BSR	WaitForMsg		;process input
	ERROR	9$			;close window
	IFNZB	AbortFlg,8$		;abort...bail out
	MOVE.B	ProcFlg,D0		;check the proceed flag
	BEQ.S	WaitForInput		;no action yet...
	IFEQIB	D0,#1,9$		;proceec with this file
8$:	STC				;else skip
9$:	RTS

SkipFile:
	INCB	ProcFlg
ProcFile:
	INCB	ProcFlg
	RTS

* Write char in D0 to LineBuffer.  Write out buffer when full.
* Returns CY=1 on write error.

PutLineChar:
	IFLTIW	OutputByteCount,#LineBufSize,1$
	BSR	FlushLineBuffer
1$:	MOVE.L	OutputPtr,A0
	MOVE.B	D0,(A0)+
	MOVE.L	A0,OutputPtr
	INCW	OutputByteCount			;count the byte
	RTS

* Writes out LineBuffer.  Calculates logical byte count in buffer.  CY=1
* on write error.

FlushLineBuffer:
	MOVE.L	OutputPtr,A0
	CLR.B	(A0)				;null-terminate
	LEA	LineBuffer,A0
	MOVE.W	#WHITE*256+BLUE,D1
FlushLine:
	MOVE.W	#Page_LE+2,D0
	SWAP	D0
	MOVE.W	LineCount,D0
	LSL.W	#3,D0			;font ht=8
	ADD.W	#Page_TE+1,D0		;offset to proper place
	BSR	DISP_MSG
	CLR.W	OutputByteCount
	MOVE.L	#LineBuffer,OutputPtr	;init output buffer
FLend:	INCW	LineCount
	IFLTIW	LineCount,#MaxLines,1$	;loop till page full or eof
	BSR	WaitForInput		;wait till op acts
	RTSERR
	BSR.S	ErasePage
1$:	CLC
	RTS

ErasePage:
	CLRBOX	Page,BLUE
	CLR.W	LineCount
	RTS

* Puts up special display showing status of copying files.

OpenTypeWind:
	BSR	DisableMenu				;gec 1/23/90
	LEA	GadgetList,A0
	BSR	RemoveGadgets
	MOVE.L	#RefreshTypeWind,RefreshRoutine
	BSR	RefreshTypeWind
	LEA	SkipGad,A0
	BSR	AddGadgets
	RTS

* Restores original directory display.

CloseTypeWind:
	LEA	SkipGad,A0
	BSR	RemoveGadgets
	MOVE.L	#RefreshDirWind,RefreshRoutine
	BSR	RefreshDirWind
	LEA	GadgetList,A0
	BSR	AddGadgets
	BSR	EnableMenu				;gec 1/23/90
	RTS

RefreshTypeWind:
	BSR	ClearWindow
	GadColor SkipGad,ORANGE
	GadColor ProcGad,ORANGE
	GadColor CancelGad,ORANGE
UpdateTypeWind:
	STRING.	#32,#TypeCnt,TMP.
	DispMsg	#Type_LE,#Type_TE,TMP.,WHITE,BLUE
	DispMsg	#Type_LE,#Type_TE,TypeTitle.
	MOVE.L	CurFib,A0
	IFZL	A0,1$
	DispCur	df_Name(A0),ORANGE,BLUE
1$:	RTS

* Puts up special display showing status of copying files.

OpenCopyWind:
	CLR.W	ActFilCnt
;	CLR.W	ActualBlks
	BSR	DisableMenu				;gec 1/23/90
	LEA	GadgetList,A0
	BSR	RemoveGadgets
	MOVE.L	#RefreshCopyWind,RefreshRoutine
	BSR	RefreshCopyWind
	LEA	CancelGad,A0
	BSR	AddGadgets
	RTS

* Restores original directory display.

CloseCopyWind:
	LEA	CancelGad,A0
	BSR	RemoveGadgets
	MOVE.L	#RefreshDirWind,RefreshRoutine
	BSR	RefreshDirWind
	LEA	GadgetList,A0
	BSR	AddGadgets
	BSR	EnableMenu				;gec 1/23/90
	RTS

RefreshCopyWind:
	BSR	ClearWindow
	DispMsg	#Title_LE,#Title_TE,CopyTitle.
	MOVE.L	CpyDirPtr,A0
	DispMsg	#CpyDir_LE,#CpyDir_TE,A0,ORANGE,BLUE
	GadColor CancelGad,ORANGE
UpdateCopyWind:
	IFZL	CurFib,1$
	BSR.S	UpdateFilCnt
	BSR	UpdateFileNames
	BSR	UpdateTrans
	BSR	UpdateBlocks
1$:	RTS

UpdateFilCnt:
	DispMsg	#FilCnt_LE,#FilCnt_TE,File.,WHITE,BLUE
	STR.	W,ActFilCnt,TMP2.,#32,#4
	BSR	StripDispCur
	DispCur	Ofstg,WHITE,BLUE
	STR.	W,TotFilCnt,TMP2.,#32,#4
	BSR	StripDispCur
	DispCur	Blanks.,WHITE,BLUE
	RTS

StripDispCur:
	STRIP_LB. TMP2.
	DispCur	TMP2.,ORANGE,BLUE
	RTS

UpdateFileNames:
	STRING.	#32,#FromCnt,TMP.
	DispMsg	#From_LE,#From_TE,TMP.,WHITE,BLUE
	STRING.	#32,#ToCnt,TMP.
	DispMsg	#To_LE,#To_TE,TMP.,WHITE,BLUE
	IFNZB	MacToAmy,1$		;From Mac
	DispMsg	#From_LE,#From_TE,FromAmy.,WHITE,BLUE
	MOVE.	DosPath.,TMP.
	BRA.S	2$

1$:	DispMsg	#From_LE,#From_TE,FromMac.,WHITE,BLUE
	MOVE.	MacVolName.,TMP.
	ACHAR.	#':',TMP.
	APPEND.	MacPath.,TMP.
2$:	MOVE.L	CurFib,A0
	IFZL	A0,22$
	LEA	df_Name(A0),A0
	APPEND.	A0,TMP.
22$:	DispCur	TMP.,ORANGE,BLUE

	IFZB	MacToAmy,3$		;To Mac
	DispMsg	#To_LE,#To_TE,ToAmy.,WHITE,BLUE
	MOVE.	DosPath.,TMP.
	BRA.S	4$

3$:	DispMsg	#To_LE,#To_TE,ToMac.,WHITE,BLUE
;	BSR	GetVolName		;get Mac vol name into TMP.
	MOVE.	MacVolName.,TMP.
	ACHAR.	#':',TMP.
	APPEND.	MacPath.,TMP.
4$:	MOVE.L	CurFib,A0
	IFZL	A0,44$
	LEA	df_Name(A0),A0
	APPEND.	A0,TMP.
44$:	DispCur	TMP.,ORANGE,BLUE
	RTS

UpdateTrans:
	DispMsg	#Trans_LE,#Trans_TE,Trans.,WHITE,BLUE
	ZAP	D0
	MOVE.B	ConvFlag,D0
	LSL.W	#2,D0			;use as long index
	LEA	TransTbl,A0
	MOVE.L	0(A0,D0.W),A0		;get ptr to proper string
	DispCur	A0,ORANGE,BLUE
	RTS

UpdateBlocks:
	IFZB	BlkCntFlg,9$,L		;dont display block count
	DispMsg	#BlkCnt_LE,#BlkCnt_TE,Block.,WHITE,BLUE
	MOVEQ	#9,D1
	MOVE.L	ProgressCount,D0
	ASR.L	D1,D0			;divide to get blocks
	INCW	D0
	STR.	W,D0,TMP2.,#32,#4
	BSR	StripDispCur
	DispCur	Ofstg,WHITE,BLUE
	STR.	W,TotalBlks,TMP2.,#32,#4
	BSR	StripDispCur
	DispCur	Blanks.,WHITE,BLUE
9$:	RTS

* Calculates total blocks based on size of source file.  Block size=512.
* Source file pointed to by CurFib.

CalcTotBlks:
	MOVE.L	CurFib,A0
	MOVE.L	df_Size(A0),D0
;	ADD.L	D0,D1			;round up
;	DECL	D1
;	DIVU	D0,D1			;
	ADD.L	#511,D0			;round up
	LSR.L	#8,D0
	LSR.L	#1,D0
	MOVE.W	D0,TotalBlks
;	CLR.W	ActualBlks
	CLR.L	ProgressCount
	RTS

* Deletes selected files.

DeleteFile:
	IFZB	MacToAmy,5$		;Amiga
	BSR	CheckMacDrive
	ERROR	9$,L
	MOVE.W	MacFileCnt,D0
	BEQ	8$			;nothing selected
	BSR	AskDelete
	ERROR	9$			;don't do it
	BSR	CheckWrtProt
	ERROR	9$
	BSR	InitMacList		;prepare to work Mac list
1$:	BSR	NextMacFile		;scan list for next selected file
	ERROR	2$			;no more files
	BSR	DeleteMacFile		;mark file in directory
	ERROR	1$
	BSR	DeleteCurFib		;unlink dir entry
	BRA.S	1$
2$:	BSR	FlushMacDirectory	;now write it all out to disk
	BSR	ExcMac
	BSR	UpdateMacWindow
	BSR	UpdateMacSpace
	RTS

5$:	BSR	CheckDosVol
	ERROR	9$
	MOVE.W	DosFileCnt,D0
	BEQ.S	8$			;nothing selected
	BSR	AskDelete		;count in D0
	ERROR	9$			;dont do it
	BSR	InitDosList		;prepare to work Dos list
;	BSR	CurrentDosPath
6$:	BSR	NextDosFile		;scan list for next selected file
	ERROR	7$			;no more files
	BSR	DeleteDosFile
	ERROR	6$			;delete failed...leave in list
	BSR	DeleteCurFib
	BRA.S	6$
7$:	BSR	ExcDos
	BSR	UpdateDosWindow
	BSR	ReloadDosSpace
	RTS
8$:	DispErr	NoDelete.
9$:	RTS

* Ask operator before deleting files.  Count of files selected in D0.  
* Returns CY=1 if op says NO.

AskDelete:
	EXT.L	D0
	STR.	W,D0,TMP2.,#32,#4
	STRIP_LB. TMP2.			;get clean count in TMP2.
	LEA	MacDel2.,A0
	IFNZB	MacToAmy,1$		;delete Mac files
	LEA	DosDel2.,A0		;else delete Dos files
1$:	MOVINS.	A0,RQTxtBuf0.		;move msg and insert count
	DispYN	AskDelTxt
	RTS

* Deletes CurFib from the dir level chain into which it is linked.
* CurLevel points to active level block.  Must scan the chain to find
* previous entry, since no backward linkage exists.

DeleteCurFib:
	PUSH	A2-A3
	MOVE.L	CurLevel,A3		;scan this level looking for match
	LEA	dl_ChildPtr(A3),A1	;start at beginning
	MOVE.L	CurFib,A2		;this is record to match
1$:	MOVE.L	df_Next(A1),A0		;get link
	IFEQL	A0,A2,2$		;found match
	MOVE.L	A0,A1			;else fwd link
	BRA.S	1$
2$:	MOVE.L	df_Next(A2),df_Next(A1)	;unlink this Fib from list
	IFNEL	dl_CurFib(A3),A2,3$	;this not CurFib for level
	MOVE.L	df_Next(A2),dl_CurFib(A3) ;else
3$:	POP	A2-A3
	RTS

* Get name string

IncName:
	LEA	INamTxt,A0
	SETF	IncFlg
	BRA.S	NamCom
ExcName:
	LEA	ENamTxt,A0
	CLR.B	IncFlg
NamCom:
	MOVE.L	A0,REQTXT
	LEA	ReqNameGad,A0
	MOVE.L	A0,REQGAD		;INIT GADGET LIST
	BSR	OpenRequester
	RTSERR
	BSR	WaitRequester		;return gadget number in D0
	RTSERR			;cancelled
	BSR	CloseRequester

NameScan:
	ZAP	D2
	IFZB	MacToAmy,2$
	BSR	InitMacList
	BRA.S	1$
2$:	BSR	InitDosList		;prepare to scan the list
1$:	MOVE.	NamBuf,TMP.		;make name u.c.
	UCASE.	TMP.
3$:	BSR	GetNextFile		;scan the list
	ERROR	5$				;done
	BSR	WildMatch		;match?
	ERROR	3$			;no...ignore it
	IFNZB	IncFlg,4$
	BCLR	#6,df_Flags(A0)		;"exclude" it
	DECW	D2
	BRA.S	3$
4$:	BSET	#6,df_Flags(A0)		;else mark as "included"
	INCW	D2
	BRA.S	3$
5$:	IFZB	MacToAmy,6$
	ADD.W	D2,MacFileCnt
	BSR	UpdateMacWindow
	RTS
6$:	ADD.W	D2,DosFileCnt
	BSR	UpdateDosWindow
	RTS

* Checks file defined by FIB with desired name in TMP. (with possible wildcards).
* Returns CY=1 on failure, CY=0 on match.

WildMatch:
	PUSH	A0
	MOVE.	df_Name(A0),TMP2.	;move filename to TMP2. and make u.c.
	UCASE.	TMP2.
	LEA	TMP2.,A1
	LEA	TMP.,A0			;POINTERS FOR WILD MATCH
1$:	MOVE.B	(A0)+,D0		;get next wildname char
	BNE.S	2$			;got one
	MOVE.B	(A1)+,D1		;get next filename char
	BEQ	9$
	BRA	8$			;ELSE TRY NEXT
2$:	CMP.B	#'?',D0			;WILD CARD?
	BNE.S	3$			;NO
	MOVE.B	(A1)+,D1
	BEQ	8$
	BRA.S	1$
3$:	CMP.B	#'#',D0			;UNIVERSAL WILD CARD?
	BNE	5$			;NO
	MOVE.B	(A0)+,D0
	BEQ.S	8$
	CMP.B	#'?',D0			;'#?' ?
	BNE.S	8$			;WILD CARD ERROR
;	MOVE.B	(A0)+,D0		;any more chars in WILDname?
;	BEQ	9$			;no...take what we have
;4$:	MOVE.B	(A1)+,D1		;get next filename char	
;	BEQ.S	8$			;name too short
;	CMP.B	D0,D1			;aligned?
;	BNE.S	4$			;no
;	BRA	1$

	LEN.	A0			;get length of remaining wild stg
	MOVE.W	D0,D1			;save it
	PUSH	A0			;save ptr
	MOVE.L	A1,A0			;how much is left of filename?
	LEN.	A0
	POP	A0			;restore other ptr
	SUB.W	D1,D0			;is there enough to check?
	BMI.S	8$			;no...no match
	BEQ.S	1$			;equal...check it out
	PUSH	A0
	MOVE.L	A1,A0			;else strip off some of filename
	CLIP.	D0,A0
	POP	A0
	BRA.S	1$

5$:	MOVE.B	(A1)+,D1		;try char-by-char
	BEQ.S	8$			;filename too short
	CMP.B	D0,D1			;OK?
	BEQ	1$			;YES...TRY NEXT PAIR
8$:	STC
9$:	POP	A0
	RTS

ExcAll:	IFZB	MacToAmy,1$
	BSR.S	ExcMac
	BSR	UpdateMacWindow
	RTS
1$:	BSR.S	ExcDos
	BSR	UpdateDosWindow
	RTS

ExcDos:	CLR.W	DosFileCnt
	BSR	InitDosList
	BRA.S	ExcCom

ExcMac:	CLR.W	MacFileCnt
	BSR	InitMacList
ExcCom:	RTSERR
1$:	BSR	GetNextFile
	RTSERR
	BCLR	#6,df_Flags(A0)
	BRA.S	1$

IncAll:	IFZB	MacToAmy,IncDos
IncMac:
	CLR.W	MacFileCnt
	BSR	InitMacList
	RTSERR
1$:	BSR	GetNextFile
	ERROR	2$
	BSET	#6,df_Flags(A0)
	INCW	MacFileCnt
	BRA.S	1$
2$:	BSR	UpdateMacWindow
	RTS

IncDos:	CLR.W	DosFileCnt
	BSR	InitDosList
	RTSERR
1$:	BSR	GetNextFile
	ERROR	2$
	BSET	#6,df_Flags(A0)
	INCW	DosFileCnt
	BRA.S	1$
2$:	BSR	UpdateDosWindow
	RTS

InitDosList:
	MOVE.L	DosCurLevel,A0
	BRA.S	InitListCom

InitMacList:
	MOVE.L	MacCurLevel,A0
InitListCom:
	MOVE.L	A0,CurLevel
	IFZL	A0,1$
	MOVE.L	dl_ChildPtr(A0),dl_ScanPtr(A0)
	RTS
1$:	STC
	RTS

* Returns ptr to Fib in A0 or CY=1 if end of scan.
* Called to get next entry in either list.

NextMacFile:
NextDosFile:
1$:	BSR.S	GetNextFile
	RTSERR
	BTST	#6,df_Flags(A0)		;selected?
	BEQ.S	1$
	RTS

GetNextFile:
	MOVE.L	CurLevel,A1		;start with current level
	IFZL	A1,8$			;nothing in list
1$:	MOVE.L	dl_ScanPtr(A1),A0	;this is next entry to process
	IFZL	A0,8$			;end of list
	MOVE.L	df_Next(A0),dl_ScanPtr(A1) ;pick up fwd link for next time
	BTST	#7,df_Flags(A0)		;is this a dir?
	BNE.S	1$			;yes...skip it
	MOVE.L	A0,CurFib		;save ptr to this one
	RTS
8$:	STC
9$:	RTS

CpyCancel:
	SETF	AbortFlg
	RTS

BinaryConv:
	PUSH	A2
	CLR.B	ConvFlag
	IFNZB	MacToAmy,1$
	IFZB	AskMacFlg,5$		;don't ask
	LEA	BinTxt,A0
	LEA	ReqMacType,A1
	BRA.S	2$
1$:	IFZB	AskAmyFlg,5$		;don't ask
	LEA	ToolTxt,A0
	LEA	ReqAmyTool,A1
2$:	MOVE.L	A0,REQTXT
	MOVE.L	A1,REQGAD
	BSR	OpenRequester
	ERROR	9$
3$:	BSR	WaitRequester		;return gadget number in D0
	ERROR	5$
	IFZW	D0,5$			;must process both if two
	MOVE.L	WINDOW,A1		;window
	LEA	REQUEST,A2
	LEA	ReqMacCreator,A0	;this is gadget to activate
	CALLSYS	ActivateGadget,IntuitionBase
	BRA.S	3$
5$:	BSR	BinOptions
9$:	POP	A2
	RTS

BinOptions:
	MOVE.L	OptionsBuffer,A2
	LEA	so_NCType(A2),A0
	LEA	so_NCCreator(A2),A1
	LEA	so_NCTool(A2),A2
	BSR	LoadOptionParams
	RTS

MacBinConv:
	MOVE.B	#1,ConvFlag
	RTS

AsciiConv:
	MOVE.B	#2,ConvFlag
	MOVE.L	OptionsBuffer,A2
	LEA	so_ASType(A2),A0
	LEA	so_ASCreator(A2),A1
	LEA	so_ASTool(A2),A2
	BSR.S	LoadOptionParams
	RTS

PostConv:
	MOVE.B	#3,ConvFlag
	MOVE.L	OptionsBuffer,A2
	LEA	so_PSType(A2),A0
	LEA	so_PSCreator(A2),A1
	LEA	so_PSTool(A2),A2
	BSR.S	LoadOptionParams
	RTS

MacPaintConv:
	MOVE.B	#4,ConvFlag
	MOVE.L	OptionsBuffer,A2
	LEA	so_MPType(A2),A0
	LEA	so_MPCreator(A2),A1
	LEA	so_MPTool(A2),A2
	BSR.S	LoadOptionParams
	RTS

* Loads Mac file type and creator and default tool name from A0, A1, A2.

LoadOptionParams:
	PUSH	A1
	MOVE.	A0,MacType
	POP	A0
	MOVE.	A0,MacCreator
	MOVE.L	A2,A0
	MOVE.	A0,DefaultTool.
	RTS

* Called after loading options file, to set MacType, MacCreator, and
* DefaultTool. according to the data from the file.

LoadConvParams:
	ZAP	D0
	MOVE.B	ConvFlag,D0
	LEA	OptionsTbl,A0
	LSL.W	#2,D0
	MOVE.L	0(A0,D0.W),A0
	JMP	(A0)

* Warning - these MUST match order of conv flag

OptionsTbl
	DC.L	BinOptions
	DC.L	MacBinConv
	DC.L	AsciiConv
	DC.L	PostConv
	DC.L	MacPaintConv



CurFib		DC.L	0	;points to currently selected FIB
CurLevel	DC.L	0	;local level ptr
CpyDirPtr	DC.L	0	;points to copy dir string
SaveCurLevel	DC.L	0	;save level for detecting Dos level changes
InputPtr	DC.L	0	;input buffer ptr
OutputPtr	DC.L	0	;output buffer ptr
ProgressCount	DC.L	0	;for progress display
InputByteCount	DC.W	0	;count of bytes remaining in input buffer
OutputByteCount	DC.W	0	;count of empty bytes in output buffer
TotFilCnt	DC.W	0	;total count of files to transfer
ActFilCnt	DC.W	0	;count of files actually transferred
TotalBlks	DC.W	0	;total number of blocks to transfer
;ActualBlks	DC.W	0	;actual count of blocks transferred
LineCount	DC.W	0	;count of displayed lines during Type
AbortFlg	DC.B	0	;1=op requested an abort
ConvFlag	DC.B	0	;conversion flag
EofFlag		DC.B	0	;1=end of file found
IncFlg		DC.B	0	;1=including
ProcFlg		DC.B	0	;waiting for op action

* WARNING - items in this table MUST match the values of ConvFlag.

		CNOP	0,2
TransTbl
	DC.L	NoConv.		;conversion flag 0
	DC.L	MacBin.		;conversion flag 1
	DC.L	ASCII.		;conversion flag 2
	DC.L	Post.		;conversion flag 4
	DC.L	MPIFF.		;conversion flag 5

NoConv.		TEXTZ	<'None (pure binary)        '>
MacBin.		TEXTZ	<'MacBinary                 '>
ASCII.		DC.B	 'Mac ASCII <--> Amiga ASCII',0
Post.		TEXTZ	<'PostScript                '>
MPIFF.		DC.B	 'MacPaint <--> Amiga IFF   ',0
CopyTitle.	TEXTZ	<'File Copy Status'>
TypeTitle.	TEXTZ	<'Contents of file: '>
CpyMacAmy.	TEXTZ	<'Copying files from Mac to Amiga'>
CpyAmyMac.	TEXTZ	<'Copying files from Amiga to Mac'>
File.		TEXTZ	<'File '>
Block.		TEXTZ	<'Block '>
Ofstg		TEXTZ	<' of '>
Blanks.		TEXTZ	<'    '>
FromAmy.	TEXTZ	<'From Amiga: '>
FromMac.	TEXTZ	<'From Mac: '>
ToAmy.		TEXTZ	<'To Amiga: '>
ToMac.		TEXTZ	<'To Mac: '>
;Trans.		TEXTZ	<'Translation: '>
Trans.		TEXTZ	<'Conversion: '>
NoDelete.	TEXTZ	<'No files selected to delete.'>
AskDel1.	TEXTZ	<'WARNING - You are about to delete'>
MacDel2.	TEXTZ	<'% Mac file(s).'>
DosDel2.	TEXTZ	<'% Amiga file(s).'>
AskDel3.	TEXTZ	<'Are you sure you want to proceed?'>
Tool1.		TEXTZ	<'Enter Amiga tool type:'>
Bin1.		TEXTZ	<'Enter Mac file type:'>
Bin2.		TEXTZ	<'Enter Mac file creator:'>
IncNam.		TEXTZ	<'Enter name of file to be included.'>
ExcNam.		TEXTZ	<'Enter name of file to be excluded.'>
Wild.		TEXTZ	<'Use wildcards ''?'' or ''#?'' for groups.'>
Tool2.
Bin3.		TEXTZ	<'See User''s Guide for details.'>
Eof.		TEXTZ	<'End of file.'>
;SavePath.	DS.B	PathSize
LineBuffer	DS.B	LineBufSize

	END
