*****************************************************************
*								*
*		Mac-2-Dos High Level Commands			*
*								*
*	The Mac to/from Amiga file conversion utility.		*
*								*
*	Copyright (c) 1989 Central Coast Software		*
*	424 Vista Avenue, Golden, CO 80401			*
*	     All rights reserved, worldwide			*
*								*
*****************************************************************

	INCLUDE	"MAC.I"	
	INCLUDE	"VD0:MACROS.ASM"
;	INCLUDE	"BOXES.ASM"

	XDEF	COPY,CpyCancel
	XDEF	TypeFile,DeleteFile
	XDEF	BinaryConv,AsciiConv,MacPaintConv

	XDEF	ConvFlag,CurFib
	XDEF	EofFlag,RepFlg

* Externals in Mac.asm

	XREF	RefreshDirWind

	XREF	MacToAmy
	XREF	SysBase,DosBase,IntuitionBase,GraphicsBase
	XREF	WINDOW,RefreshRoutine

* EXTERNALS IN DOSFILES AND MACFILES

	XREF	CreateDosFile,OpenDosFile,CloseDosFile,DeleteDosFile
	XREF	CreateMacFile,OpenMacFile,CloseMacFile,DeleteMacFile
	XREF	ReadDosBlock,WriteDosBlock
	XREF	ReadMacBlock,WriteMacBlock
	XREF	GetVolName

	XREF	TMP.,TMP2.
	XREF	MacRootLevel,MacCurLevel
	XREF	DosRootLevel,DosCurLevel
	XREF	DosBytCnt,MacBytCnt
	XREF	MacBuffer
	XREF	MacPath.
	XREF	DosVolName.,DosPath.

* EXTERNALS IN WIND.ASM

	XREF	DosFileCnt,MacFileCnt

* EXTERNALS IN FUN

	XREF	AddGadgets,RemoveGadgets,ClearWindow
	XREF	StripAppend

* Externals in Gadgets.asm

	XREF	GadgetList,CancelGad

* Externals in Buffers.asm

	XREF	DosBuffer

* Externals in Disk.asm

	XREF	MotorOff
	XREF	GetDriveStatus

* Comes here when operator clicks on COPY gadget.

COPY:
	CLR.B	AbortFlg
	IFZB	MacToAmy,CopyAmyMac,L	;copy from Amiga to Mac
	
* Copy from Mac to Amiga

	MOVE.W	MacFileCnt,TotFilCnt	;any files selected?
	IFNZW	MacFileCnt,1$		;yes
	DispErr	NoMacFiles.
	BRA.S	9$
1$:	MOVE.L	#CpyMacAmy.,CpyDirPtr	;set direction msg
	BSR	OpenCopyWind
	BSR	InitMacList		;prepare to work Mac list
2$:	BSR	NextMacFile		;scan list for next selected file
	ERROR	8$			;no more files
	BSR	CalcTotBlks
	INCW	ActFilCnt
	BSR	UpdateCopyWind		;show what we are doing
	BSR	OpenMacFile		;else open that sucker
	ERROR	7$			;cant open file
	BSR	CreateDosFile		;try to create ADOS file
	ERROR	6$			;cant open or duplicate exists
	BSR	ConvMacAmy		;copy and convert from Mac to amiga
	ERROR	5$			;error...something wrong
	BSR	CloseDosFile		;else clean up
	BSR	CloseMacFile
	BRA.S	2$			;loop till all files done
5$:	BSR	CloseDosFile
6$:	BSR	CloseMacFile
7$:	IFZB	AbortFlg,2$		;file error, but no abort
8$:	BSR	CloseCopyWind		;restore dir window
9$:	RTS

* Copy from Amiga to Mac

CopyAmyMac:
	MOVE.W	DosFileCnt,TotFilCnt	;any files selected?
	BNE.S	1$			;yes
	DispErr	NoDosFiles.
	BRA.S	9$
1$:	MOVE.L	#CpyAmyMac.,CpyDirPtr	;set direction msg
	BSR	OpenCopyWind
	BSR	InitDosList		;prepare to work Dos list
2$:	BSR	NextDosFile		;scan list for next selected file
	ERROR	8$			;no more files
	BSR	CalcTotBlks
	INCW	ActFilCnt
	BSR	UpdateCopyWind		;show what we are doing
	BSR	OpenDosFile		;else open that sucker
	ERROR	7$			;cant open file
	BSR	CreateMacFile		;try to create Mac file
	ERROR	6$			;cant open or duplicate exists
	BSR	ConvAmyMac		;copy and convert from Amiga to Mac
	ERROR	5$			;a problem
	BSR	CloseDosFile		;else clean up
	BSR	CloseMacFile
	BRA.S	2$			;loop till all files done
5$:	BSR	CloseMacFile
6$:	BSR	CloseDosFile
7$:	IFZB	AbortFlg,2$		;file error, but no abort
8$:	BSR	CloseCopyWind		;restore dir window
9$:	RTS

ConvAmyMac:
1$:	BSR	ReadDosBlock
	ERROR	9$
	IFNZB	EofFlag,9$
	INCW	ActualBlks
	BSR	UpdateBlocks
	LEA	DosBuffer,A0
	MOVE.L	DosBytCnt,D0
	BSR	WriteMacBlock
	NOERROR	1$
9$:	RTS

ConvMacAmy:
1$:	BSR	ReadMacBlock
	ERROR	9$
	IFNZB	EofFlag,9$
	INCW	ActualBlks
	BSR	UpdateBlocks
	MOVE.L	MacBuffer,A0
	MOVE.L	MacBytCnt,D0
	BSR	WriteDosBlock
	NOERROR	1$
9$:	RTS

OpenCopyWind:
	CLR.W	ActFilCnt
	CLR.W	ActualBlks
	LEA	GadgetList,A0
	BSR	RemoveGadgets
	MOVE.L	#RefreshCopyWind,RefreshRoutine
	BSR	RefreshCopyWind
	LEA	CancelGad,A0
	BSR	AddGadgets
	RTS

CloseCopyWind:
	LEA	CancelGad,A0
	BSR	RemoveGadgets
	MOVE.L	#RefreshDirWind,RefreshRoutine
	BSR	RefreshDirWind
	LEA	GadgetList,A0
	BSR	AddGadgets
	RTS

* Screen positions for status msgs on CopyWindow

Title_LE	EQU	256
Title_TE	EQU	22

CpyDir_LE	EQU	196
CpyDir_TE	EQU	46

FilCnt_LE	EQU	160
FilCnt_TE	EQU	70

From_LE		EQU	FilCnt_LE
From_TE		EQU	94

To_LE		EQU	FilCnt_LE
To_TE		EQU	118

Trans_LE	EQU	FilCnt_LE
Trans_TE	EQU	142

BlkCnt_LE	EQU	FilCnt_LE
BlkCnt_TE	EQU	166

RefreshCopyWind:
	BSR	ClearWindow
	DispMsg	#Title_LE,#Title_TE,CopyTitle.
	MOVE.L	CpyDirPtr,A0
	DispMsg	#CpyDir_LE,#CpyDir_TE,A0
	GadColor CancelGad,ORANGE
UpdateCopyWind:
	BSR	UpdateFile
	BSR	UpdateFromTo
	BSR	UpdateTrans
	BSR	UpdateBlocks
	RTS

UpdateFile:
	MOVE.	File.,TMP.
	STR.	W,ActFilCnt,TMP2.,#32,#4
	BSR	StripAppend
	APPEND.	Of.,TMP.
	STR.	W,TotFilCnt,TMP2.,#32,#4
	BSR	StripAppend
	APPEND.	Blanks.,TMP.
	DispMsg	#FilCnt_LE,#FilCnt_TE,TMP.,WHITE,BLUE
	RTS

UpdateFromTo:
	STRING.	#32,#60,TMP2.
	DispMsg	#From_LE,#From_TE,TMP2.,WHITE,BLUE
	DispMsg	#To_LE,#To_TE,TMP2.,WHITE,BLUE
	IFNZB	MacToAmy,1$		;From Mac
	MOVE.	FromAmy.,TMP.
;	APPEND.	DosVolName.,TMP.
;	ACHAR.	#':',TMP.
	APPEND.	DosPath.,TMP.
	BRA.S	2$

1$:	BSR	GetVolName		;get Mac vol name into TMP.
	MOVE.	TMP.,TMP2.
	ACHAR.	#':',TMP2.
	MOVE.	FromMac.,TMP.
	APPEND.	TMP2.,TMP.
	APPEND.	MacPath.,TMP.
2$:	MOVE.L	CurFib,A0
	IFZL	A0,22$
	LEA	df_Name(A0),A0
	APPEND.	A0,TMP.
22$:	DispMsg	#From_LE,#From_TE,TMP.,WHITE,BLUE

	IFZB	MacToAmy,3$		;To Mac
	MOVE.	ToAmy.,TMP.
;	APPEND.	DosVolName.,TMP.
;	ACHAR.	#':',TMP.
	APPEND.	DosPath.,TMP.
	BRA.S	4$

3$:	BSR	GetVolName		;get Mac vol name into TMP.
	MOVE.	TMP.,TMP2.
	ACHAR.	#':',TMP2.
	MOVE.	ToMac.,TMP.
	APPEND.	TMP2.,TMP.
	APPEND.	MacPath.,TMP.
4$:	MOVE.L	CurFib,A0
	IFZL	A0,44$
	LEA	df_Name(A0),A0
	APPEND.	A0,TMP.
;	LEA	TMP.,A0
;	CLR.B	31(A0)			;make sure name is truncated
44$:	DispMsg	#To_LE,#To_TE,TMP.,WHITE,BLUE
	RTS

UpdateTrans:
	MOVE.	Trans.,TMP.
	ZAP	D0
	MOVE.B	ConvFlag,D0
	LSL.W	#2,D0			;use as long index
	LEA	TransTbl,A0
	MOVE.L	0(A0,D0.W),A0		;get ptr to proper string
	APPEND.	A0,TMP.
	DispMsg	#Trans_LE,#Trans_TE,TMP.,WHITE,BLUE
	RTS

UpdateBlocks:
	MOVE.	Block.,TMP.
	STR.	W,ActualBlks,TMP2.,#32,#4
	BSR	StripAppend
	APPEND.	Of.,TMP.
	STR.	W,TotalBlks,TMP2.,#32,#4
	BSR	StripAppend
	APPEND.	Blanks.,TMP.
	DispMsg	#BlkCnt_LE,#BlkCnt_TE,TMP.,WHITE,BLUE
	RTS

CalcTotBlks:
	MOVE.L	CurFib,A0
	MOVE.L	df_Size(A0),D0
	ADD.L	#511,D0			;round up
	LSR.L	#8,D0
	LSR.L	#1,D0
	MOVE.W	D0,TotalBlks
	CLR.W	ActualBlks
	RTS

InitMacList:
	MOVE.L	MacCurLevel,SaveCurLevel
	LEA	MacRootLevel,A0		;prepare to process the list
	LEA	dl_ChildPtr(A0),A1
	MOVE.L	A1,dl_CurFib(A0)	;tricky...this kicks off root level
	MOVE.L	A0,MacCurLevel
	RTS

* Returns ptr to FIB of the next selected file to copy in A0, 
* or exits with CY=1.

NextMacFile:
	MOVE.L	MacCurLevel,A2
1$:	MOVE.L	A2,MacCurLevel
	MOVE.L	dl_CurFib(A2),A1
	MOVE.L	df_Next(A1),A1		;get ptr to next FIB
	IFNZL	A1,2$			;there is a fib
	MOVE.L	dl_ParLevel(A2),A2	;backup one level
	IFZL	A2,9$,L			;completed root...stop now
;	MOVE.L	dl_CurFib(A2),CurFib
;	MOVE.L	dl_CurFib(A2),A1	;restore last FIB at this level
	BRA.S	1$			;dont add "size" of dir

2$:	MOVE.L	A1,dl_CurFib(A2)	;save ptr to this one
	MOVE.L	A1,CurFib
11$:	BTST	#7,df_Flags(A1)		;directory?
	BEQ.S	3$			;no...use this file
;	MOVE.L	CurLevel,A2
;	MOVE.L	dl_CurFib(A2),A1
	MOVE.L	df_SubLevel(A1),A2	;switch to lower level
;	MOVE.L	A2,MacCurLevel		;this is now the current level
	LEA	dl_ChildPtr(A2),A1
	MOVE.L	A1,dl_CurFib(A2)
	BRA	1$			;now check out this level

3$:	BCLR	#6,df_Flags(A1)		;selected?
	BEQ.S	1$			;no...forget it...try next
	MOVE.L	A1,A0			;pass back ptr to this one
	RTS
9$:	MOVE.L	SaveCurLevel,A0
	MOVE.L	A0,MacCurLevel		;restore original level
	MOVE.L	dl_ChildPtr(A0),dl_CurFib(A0)
	STC
	RTS

InitDosList:
	RTS

NextDosFile:
	RTS


* REPORT DUPLICATE FILE, AND ASK IF IT SHOULD BE REPLACED.  CY=NO.

;DUP_QUERY:
;	IFNZB	REP_FLAG,9$	;AUTO REPLACE...JUST DO IT
;	STG_Z.	TMP.
;	LEA	TMP.,A0
;	LEA	ASKREP2,A1
;	MOVE.L	A0,it_IText(A1)	;SAVE PTR TO FILE NAME
;	DispReq	ASKREP1,YESTXT,CANTXT ;PUT UP REQUESTER
;9$:	RTS

* DELETES SELECTED FILE AFTER ASKING.

;DEL:	LEA	VolBuf+36,A1
;	LEA	NewName,A0
;1$:	MOVE.B	(A0)+,D0
;	BEQ.S	2$
;	MOVE.B	D0,(A1)+
;	BRA.S	1$
;2$:	JSR	WriteVolBlk
;	JSR	FlushTrack
;	RTS

;NewName	DC.B	6,'George',0

;OldDEL:
;	BSR	OPEN_FILE
;	BSR	DELETE_FILE	;GET RID OF FILE
;	BSR	BuildMacDir	;AND FINALLY RELIST DIR
;8$:	BSR	MotorOff
;9$:	RTS

* DISPLAYS ASCII FILE CONTENTS ON SCREEN.

;TYPE:	BSR	GOT_A_FILE		;ANY FILE?
;	ERROR	9$			;NONE...ABORT
;	BNE.S	1$			;CFILE
;	BSR	OPEN_AD_FILE		;TRY TO OPEN THE FILE
;	ERROR	NO_FILE			;CANT FIND IT
;	BSR	EXTRACT_AFILE		;GET ADOS FILE NAME INTO TMP.
;	BRA.S	2$
;1$:;	BSR	DiskLog			;GET DRIVE READY, READ BAM
;	ERROR	9$
;	BSR	FOLLOW_PATH		;CHECK OUT THE NAME IN CBUF
;	ERROR	NO_FILE			;OOPS...SOME PROBLEM
;	BSR	OPEN_FILE		;TRY TO OPEN C/C FILE
;	Z_STG.	CBUF,TMP.
;2$:	MOVE.	LISTOF.,TMP.
;	APPEND.	TMP.,A.
;	BSR	OpenTxtWin		;OPEN NEW WINDOW AND NAME IT
;	ERROR	8$
;	CLR.W	BYTCNT			;START WITH EMPTY BUFFER
;	CLR.B	LINCNT
;3$:	CMP.B	#21,LINCNT		;DISPLAYED ENOUGH?
;	BLS.S	4$			;NO...
;	BSR	WAIT_MORE		;ELSE WARN AND WAIT
;	ERROR	7$			;OP WANTS TO BAIL OUT
;4$:	BSR	READ_LINE		;FILL LINE BUFFER
;	ERROR	6$			;EOF
;	BSR	WRITE_LINE		;WRITE LINE BUFFER TO SCREEN
;	BRA.S	3$			;Loop
;6$:	BSR	WAIT_EOF		;END OF FILE
;7$:	BSR	CloseTxtWin
;8$:	BSR	CLOSE_AD_FILE		;THATS ALL
;9$:	BSR	MotorOff		;TURN OFF MOTOR, IF ON
;	RTS

* Deletes selected files.

DeleteFile:
	IFZB	MacToAmy,5$		;Amiga
	IFZW	MacFileCnt,7$		;nothing selected
	BSR	AskDelete
	ERROR	9$
	MOVE.L	MacCurLevel,A1
	LEA	dl_ChildPtr(A1),A0
	MOVE.L	A0,dl_CurFib(A1)
1$:	MOVE.L	MacCurLevel,A1
	MOVE.L	dl_CurFib(A1),A1
	MOVE.L	df_Next(A1),A0
	IFZL	A0,9$			;done
	MOVE.L	A0,dl_CurFib(A1)
	MOVE.L	A0,CurFib
	BSR	DeleteMacFile
	BRA.S	1$

5$:	IFZW	DosFileCnt,7$		;nothing selected
	BSR	AskDelete
	ERROR	9$
	MOVE.L	DosCurLevel,A1
	LEA	dl_ChildPtr(A1),A0
	MOVE.L	A0,dl_CurFib(A1)
6$:	MOVE.L	DosCurLevel,A1
	MOVE.L	dl_CurFib(A1),A1
	MOVE.L	df_Next(A1),A0
	IFZL	A0,9$			;done
	MOVE.L	A0,dl_CurFib(A1)
	MOVE.L	A0,CurFib
	BSR	DeleteDosFile
	BRA.S	6$
7$:	DispErr	NoDelete.
9$:	RTS

* ASK BEFORE DELETING FILE.  CY=NO.

AskDelete:
;	LEA	ASKDEL2,A1
;	MOVE.L	A0,it_IText(A1)		;SAVE PTR TO FILE NAME
;	DispReq	ASKDEL1,YESTXT,CANTXT	;PUT UP REQUESTER
	RTS

CpyCancel:
	SETF	AbortFlg
	RTS

TypeFile:
	DispErr	NotYet.
	RTS

BinaryConv:
	CLR.B	ConvFlag
	RTS

AsciiConv:
	MOVE.B	#1,ConvFlag
	RTS

MacPaintConv:
	MOVE.B	#2,ConvFlag
	RTS


CurFib		DC.L	0	;points to currently selected FIB
CpyDirPtr	DC.L	0	;points to copy dir string
SaveCurLevel	DC.L	0	;save current level for restoring after copy
TotFilCnt	DC.W	0	;total count of files to transfer
ActFilCnt	DC.W	0	;count of files actually transferred
TotalBlks	DC.W	0	;total number of blocks to transfer
ActualBlks	DC.W	0	;actual count of blocks transferred
AbortFlg	DC.B	0	;1=op requested an abort
ConvFlag	DC.B	0	;conversion flag
EofFlag		DC.B	0	;1=end of file found
RepFlg		DC.B	0	;1=replace existing files

* WARNING - items in this table MUST match the values of ConvFlag.

TransTbl
	DC.L	NoConv.		;conversion flag 0
	DC.L	ASCII.		;conversion flag 1
	DC.L	MPIFF.		;conversion flag 2

NoConv.		TEXTZ	<'None (pure binary)        '>
ASCII.		TEXTZ	<'Mac ASCII -- Amiga ASCII'>
MPIFF.		TEXTZ	<'MacPaint -- IFF         '>
CopyTitle.	TEXTZ	<'File Copy Status'>
CpyMacAmy.	TEXTZ	<'Copying files from Mac to Amiga'>
CpyAmyMac.	TEXTZ	<'Copying files from Amiga to Mac'>
File.		TEXTZ	<'File '>
Block.		TEXTZ	<'Block '>
Of.		TEXTZ	<' of '>
Blanks.		TEXTZ	<'    '>
FromAmy.	TEXTZ	<'From Amiga: '>
FromMac.	TEXTZ	<'From Mac: '>
ToAmy.		TEXTZ	<'To Amiga: '>
ToMac.		TEXTZ	<'To Mac: '>
Trans.		TEXTZ	<'Translation: '>
NotYet.		TEXTZ	<'Not implemented yet.'>
NoMacFiles.	TEXTZ	<'No Mac files selected to copy.'>
NoDosFiles.	TEXTZ	<'No Amiga files selected to copy.'>

	END
