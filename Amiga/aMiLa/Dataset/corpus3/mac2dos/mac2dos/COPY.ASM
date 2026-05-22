*****************************************************************
*								*
*		Mac-2-Dos COPY command				*
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

	XDEF	COPY
	XDEF	NoMacFiles.,NoDosFiles.
	XDEF	GetMacChar,PutMacChar
	XDEF	GetDosChar,GetDosWord,GetDosLong
	XDEF	CheckMacDrive,CheckDosVol

	XDEF	PixelBuffer
	XDEF	NoMacDisk.
	XDEF	BlkCntFlg
	XDEF	InvDosVol.

* Externals in Mac.asm

	XREF	CheckForMsg
	XREF	ProcessMsg

	XREF	MacToAmy
	XREF	SysBase,DosBase,IntuitionBase,GraphicsBase
	XREF	HiResFlg
;	XREF	OptionsBuffer

* Externals in CMDS.ASM

	XREF	InitDosList,NextDosFile
	XREF	InitMacList,NextMacFile
	XREF	CalcTotBlks
	XREF	OpenCopyWind,UpdateCopyWind,CloseCopyWind
	XREF	UpdateBlocks
	XREF	ExcMac,ExcDos
	XREF	LoadConvParams

	XREF	AbortFlg,ConvFlag,EofFlag
	XREF	MacFileCnt,DosFIleCnt,TotFilCnt
	XREF	InputPtr,OutputPtr
	XREF	CpyMacAmy.,CpyAmyMac.,CpyDirPtr
	XREF	CurFib,ActFilCnt
	XREF	InputByteCount,OutputByteCount
	XREF	ProgressCount

* Externals in ILBM.asm

	XREF	CopyIFFBody
	XREF	ProcessBMHD,ProcessCMAP,ProcessCAMG
	XREF	IFFFlags

* EXTERNALS IN DOSFILES AND MACFILES

	XREF	CreateDosFile,OpenDosFile,CloseDosFile,DeleteDosFile
	XREF	CreateMacFile,OpenMacFile,CloseMacFile,DeleteMacFile
	XREF	OpenResFork,NewResFork
	XREF	AppendDosPath,TruncateDosPath
;	XREF	CurrentDosPath
	XREF	ReadDosBlock,WriteDosBlock
	XREF	ReadMacBlock,WriteMacBlock
	XREF	GetVolName
	XREF	DosSeek,WriteDosFile
	XREF	FlushMacDirectory

	XREF	TMP.,TMP2.
	XREF	MacRootLevel,MacCurLevel
	XREF	DosRootLevel,DosCurLevel
	XREF	DosBytCnt,MacBytCnt
	XREF	MacBuffer
	XREF	MacPath.
	XREF	DosVolName.,DosPath.
	XREF	AllocBlkSizeW,AllocBlkSizeL
	XREF	HFSFlag
	XREF	ValidMacVol,ValidDosVol
	XREF	MacHandle

* EXTERNALS IN WIND.ASM

	XREF	DosFileCnt,MacFileCnt

* Externals in Buffers.asm

	XREF	DosBuffer

* Externals in Xlate.asm

	XREF	AMXlate,MAXlate

* Externals in Disk.ASM

	XREF	GetDriveStatus
	XREF	CheckWrtProt

* External in MPHDR.ASM

;	XREF	MPHeader

LineBufSize	EQU	200
MaxLines	EQU	16

* Comes here when operator clicks on COPY gadget.

COPY:
	CLR.L	CurFib
	CLR.B	AbortFlg
	SETF	BlkCntFlg		;display block count
	BSR	CheckMacDrive		;got a valid Mac disk?
	ERROR	9$			;no...stop now
	BSR	CheckDosVol		;got a valid Dos volume?
	ERROR	9$
	BSR	LoadConvParams		;set up conversion params
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
	MOVE.L	#512,D0			;Amy block size always 512
	BSR	CalcTotBlks
	INCW	ActFilCnt
	BSR	UpdateCopyWind		;show what we are doing
	ZAP	D0			;force data fork for now
	BSR	OpenMacFile		;else open that sucker
	ERROR	8$			;cant open file
	BSR	CheckMPFile		;check for valid MP file
	ERROR	6$			;not valid MP file
	BSR	CreateDosFile		;try to create ADOS file
	ERROR	6$			;cant open or duplicate exists
	BSR	ConvMacAmy		;copy and convert from Mac to amiga
;	ERROR	5$			;error...something wrong
;	BSR	CloseDosFile		;else clean up
;	BSR	CloseMacFile
;	BRA.S	2$			;loop till all files done
;5$:
	BSR	CloseDosFile
6$:	BSR	CloseMacFile
	BSR	CheckAbort
	IFZB	AbortFlg,2$		;file error, but no abort
8$:	BSR	ExcMac
	BSR	CloseCopyWind		;restore dir window
9$:	RTS

* Copy from Amiga to Mac

CopyAmyMac:
	MOVE.W	DosFileCnt,TotFilCnt	;any files selected?
	BNE.S	1$			;yes
	DispErr	NoDosFiles.
	BRA	9$
1$:	BSR	CheckWrtProt
	ERROR	9$
	MOVE.L	#CpyAmyMac.,CpyDirPtr	;set direction msg
	BSR	OpenCopyWind
	BSR	InitDosList		;prepare to work Dos list
;	BSR	CurrentDosPath
2$:	BSR	NextDosFile		;scan list for next selected file
	ERROR	8$			;no more files
	MOVE.L	AllocBlkSizeL,D0	;size of Mac block
	BSR	CalcTotBlks
	INCW	ActFilCnt
	BSR	UpdateCopyWind		;show what we are doing
	BSR	OpenDosFile		;else open that sucker
	ERROR	8$			;cant open file
	BSR	CheckIFFFile		;verify ILBN IFF file
	ERROR	6$
	ZAP	D0			;force data fork for now
	BSR	CreateMacFile		;try to create Mac file
	ERROR	6$			;cant open or duplicate exists
	BSR	ConvAmyMac		;copy and convert from Amiga to Mac
;	ERROR	5$			;a problem
;	BSR	CloseDosFile		;else clean up
;	BSR	CloseMacFile
;	BRA.S	2$			;loop till all files done
;5$:
	BSR	CloseMacFile
6$:	BSR	CloseDosFile
	BSR	CheckAbort
	IFZB	AbortFlg,2$		;file error, but no abort
8$:	BSR	FlushMacDirectory
	BSR	ExcDos
	BSR	CloseCopyWind		;restore dir window
9$:	RTS

ConvAmyMac:
	LEA	AmyConv,A0
	BRA.S	ConvCom

ConvMacAmy:
	LEA	MacConv,A0
ConvCom:
	ZAP	D0
	MOVE.B	ConvFlag,D0		;what type of conversion?
	LSL.L	#2,D0
	ADD.L	D0,A0
	MOVE.L	(A0),A0
	JSR	(A0)
	RTS

AmyPaint:
	LEA	PixelBuffer,A0
	ZAP	D0
	MOVE.W	#PixelBufferSize-1,D1
6$:	MOVE.B	D0,(A0)+		;zap the scanline buffer
	DBF	D1,6$

2$:	BSR	CopyIFFBody		;process image

3$:	BSR	FlushMacBuffer		;write out last buffer
9$:	RTS

AmyPS:	CLR.W	InputByteCount		;start with no input
	MOVE.L	MacBuffer,OutputPtr		;init output buffer
	MOVE.W	AllocBlkSizeW,OutputByteCount	;can store this many
1$:	BSR	GetDosChar
	ERROR	8$
	IFNEIB	D0,#10,2$		;not line feed
	MOVEQ	#13,D0			;else store CR
2$:	BSR	PutMacChar
	ERROR	9$
	BRA.S	1$
8$:	BSR	FlushMacBuffer		;write out last buffer
9$:	RTS

AmyASCII:
	LEA	AMXlate,A2		;Amiga to Mac ASCII translation table
	CLR.W	InputByteCount		;start with no input
	MOVE.L	MacBuffer,OutputPtr		;init output buffer
	MOVE.W	AllocBlkSizeW,OutputByteCount	;can store this many
;	CLR.W	OutputByteCount
1$:	BSR	GetDosChar
	ERROR	8$
	MOVE.B	0(A2,D0.W),D0		;get equivalent ASCII char
	BNE.S	2$			;got a valid char
	MOVEQ	#'?',D0			;else store '?' *********
2$:	BSR	PutMacChar
	ERROR	9$
	BRA.S	1$
8$:	BSR	FlushMacBuffer		;write out last buffer
9$:	RTS

AmyMacBin:
	PUSH	D2-D3/A2-A3
	CLR.W	InputByteCount		;start with no input
;	MOVE.L	MacBuffer,OutputPtr		;init output buffer
;	MOVE.W	AllocBlkSizeW,OutputByteCount	;can store this many
;	CLR.W	OutputByteCount
	MOVE.L	MacHandle,A2
	IFZB	HFSFlag,1$
	ADDQ.L	#2,A2
1$:	MOVEQ	#65,D3			;skip version, name length, and...
	BSR	SkipBytes		;...skip over name in header
	ERROR	9$
	LEA	FF_FinderType(A2),A3
	MOVEQ	#8,D3			;finder data
	BSR	CopyDosBytes		;type and creator
	ERROR	9$
	BSR	GetDosChar		;finder flags
	AND.B	#$FE,D0			;not inited
	MOVE.B	D0,(A3)+
	MOVEQ	#7,D3			;rest of finder data
	BSR	CopyDosBytes
	ERROR	9$
	BSR	GetDosChar		;get protected bit
	AND.B	#1,D0
	BEQ.S	2$			;not protected
	BSET	#0,FF_Flags(A2)		;else mark it
2$:	BSR	GetDosChar		;skip fill
	BSR	GetDosLong		;get data fork length
	ERROR	9$
	MOVE.L	D0,DataForkLen
	BSR	GetDosLong		;get resource fork length
	ERROR	9$
	MOVE.L	D0,ResForkLen
	BSR	GetDosLong		;creation date
	BEQ.S	5$			;none
	MOVE.L	D0,FF_CDate(A2)
5$:	BSR	GetDosLong		;mod date
	BEQ.S	6$			;none
	MOVE.L	D0,FF_MDate(A2)
6$:	MOVEQ	#29,D3
	BSR	SkipBytes		;skip reserved and comp type
	ERROR	9$
	MOVE.L	DataForkLen,D0
	BEQ.S	3$
	BSR	CopyToFork		;copy data fork data
	ERROR	9$
3$:	BSR	NewResFork		;switch to resource fork
;	MOVE.L	MacBuffer,OutputPtr		;init output buffer
;	MOVE.W	AllocBlkSizeW,OutputByteCount	;can store this many
	MOVE.L	ResForkLen,D0
	BEQ.S	4$
	BSR	CopyToFork		;copy resource fork data
4$:;	BSR	FlushMacBuffer		;write out last of data
9$:	POP	D2-D3/A2-A3
	RTS

* Copies D0 bytes from Dos file to Mac fork.
* If length in D0 not even mult of 128, skips as necessary.

CopyToFork:
	PUSH	D2-D3
	MOVE.L	D0,D2
	MOVE.L	D2,D3
	MOVE.L	MacBuffer,OutputPtr		;init output buffer
	MOVE.W	AllocBlkSizeW,OutputByteCount	;can store this many
1$:	BSR	GetDosChar
	ERROR	9$
	BSR	PutMacChar
	ERROR	9$
	DECL	D3
	BNE.S	1$
	BSR	FlushMacBuffer	;write out last block of fork
	AND.W	#$7F,D2		;odd length?
	BEQ.S	9$
	MOVE.W	#128,D3
	SUB.W	D2,D3		;calc amount to skip
	BSR	SkipBytes	;do it
9$:	POP	D2-D3
	RTS

SkipBytes:
	DECW	D3
1$:	BSR	GetDosChar
	RTSERR
	DBF	D3,1$
	RTS

CopyDosBytes:
	DECW	D3
1$:	BSR	GetDosChar		;get file type
	RTSERR
	MOVE.B	D0,(A3)+
	DBF	D3,1$
	RTS

AmyBin:	CLR.W	InputByteCount		;start with no input
	MOVE.L	MacBuffer,OutputPtr		;init output buffer
	MOVE.W	AllocBlkSizeW,OutputByteCount	;can store this many
;	CLR.W	OutputByteCount
1$:	BSR	GetDosChar
	ERROR	8$
2$:	BSR	PutMacChar
	ERROR	9$
	BRA.S	1$
8$:	BSR	FlushMacBuffer		;write out last buffer
9$:	RTS

PixelBufferSize	EQU	800/8		;allow up to 800 pixels
MacPixelLimit	EQU	576/8		;MacPaint width in pixels
DosPixelLimit	EQU	640/8		;DOS standard limit

* First data block already loaded and ptr set to proper place.

MacPaint:
	CLR.W	InputByteCount		;start with no input
	MOVE.L	DosBuffer,OutputPtr		;init output buffer
	MOVE.W	#DosBufSize,OutputByteCount	;can store this many
;	CLR.W	OutputByteCount
	BSR	ReadMacBlock		;read first Mac block
	ERROR	9$
	MOVE.L	MacBytCnt,D0
	MOVE.L	#512,D1			;skip first 512 bytes
	SUB.L	D1,D0
	MOVE.L	D1,ProgressCount
	MOVE.W	D0,InputByteCount	;save anything left
	PUSH	A2
;;	LEA	PixelBuffer,A0					;1/24/90
;;	ZAP	D0						;1/24/90
;;	MOVE.W	#PixelBufferSize-1,D1				;1/24/90
;;6$:	MOVE.B	D0,(A0)+		;zap the scanline buffer;1/24/90
;;	DBF	D1,6$						;1/24/90
	BSR	ZapPixelBuffer		;zap the scanline buffer;1/24/90
	CLR.L	BodyCount		;count of bytes in body
	MOVE.W	#640,D0			;assume 640x400
	MOVE.W	#400,D1
	MOVE.L	#$8004,ViewMode		;hi res, lace viewmode
	IFNZB	HiResFlg,5$		;use hi res
	LSR.W	#1,D0			;else make it 320x200
	LSR.W	#1,D1
	CLR.L	ViewMode		;force low res
5$:	MOVE.W	D0,RasterWD
	MOVE.W	D1,RasterHT
	MOVE.W	#720,ScanLineCnt	;process this many scan lines ;1/24/90
	LEA	IFFHdr,A2		;string of chars marking IFF file
	MOVEQ	#IFFHdrLen-1,D1
1$:	MOVE.B	(A2)+,D0		;get hdr char
	BSR	PutDosChar
	DBF	D1,1$

2$:	BSR	MacFillScanLine
	ERROR	3$
	BSR	DosFlushScanLine
	DECW	ScanLineCnt		;processed one line	;1/24/90
	BNE.S	2$			;loop for all lines	;1/24/90
;;	BRA.S	2$						;1/24/90
	BRA.S	6$						;1/24/90

;;3$:	MOVE.L	BodyCount,D2					;1/24/90
3$:	IFZW	ScanLineCnt,6$					;1/24/90
	BSR	ZapPixelBuffer					;1/24/90
7$:	BSR	DosFlushScanLine	;output blank line	;1/24/90
	DECW	ScanLineCnt		;processed one line	;1/24/90
	BNE.S	7$						;1/24/90
6$:	MOVE.L	BodyCount,D2					;1/24/90
	MOVE.L	D2,BODYlen		;save length of body	;1/24/90
	BTST	#0,D2			;byte count even?
	BEQ.S	4$			;yes
	ZAP	D0
	BSR	PutDosChar		;no...odd, add a null byte
	ERROR	9$
	INCL	D2
4$:	BSR	FlushDosBuffer		;write out last buffer
	ERROR	9$

* Now reposition and write out IFF length

	ADD.L	#IFFHdrLen-8,D2
	MOVE.L	D2,FORMlen
	ZAP	D0			;reposition to start of file
	BSR	DosSeek			;get us there
	ERROR	9$
	LEA	IFFHdr,A0		;rewrite the iff hdr
	MOVEQ	#IFFHdrLen,D0
	BSR	WriteDosFile		;write out IFF hdr with lengths inserted
9$:	POP	A2
	RTS

* Added 1/24/90

ZapPixelBuffer:
	LEA	PixelBuffer,A0
	ZAP	D0
	MOVE.W	#PixelBufferSize-1,D1
1$:	MOVE.B	D0,(A0)+		;zap the scanline buffer
	DBF	D1,1$
	RTS

* Converts Mac ASCII to Amiga.

MacPS:	CLR.W	InputByteCount		;start with no input
	MOVE.L	DosBuffer,OutputPtr		;init output buffer
	MOVE.W	#DosBufSize,OutputByteCount	;can store this many
1$:	BSR	GetMacChar
	ERROR	8$
	IFNEIB	D0,#13,2$		;not CR
	MOVEQ	#10,D0			;else store LINE FEED
2$:	BSR	PutDosChar
	ERROR	9$
	BRA.S	1$
8$:	BSR	FlushDosBuffer		;write out last buffer
9$:	RTS

MacASCII:
	CLR.W	InputByteCount		;start with no input
	MOVE.L	DosBuffer,OutputPtr		;init output buffer
	MOVE.W	#DosBufSize,OutputByteCount	;can store this many
;	CLR.W	OutputByteCount
	LEA	MAXlate,A2		;Mac to Amiga ASCII translation table
1$:	BSR	GetMacChar
	ERROR	8$
	MOVE.B	0(A2,D0.W),D0		;get equivalent ASCII char
	BNE.S	2$			;got a valid char
	MOVEQ	#'?',D0			;else store '?' *********
2$:	BSR	PutDosChar
	ERROR	9$
	BRA.S	1$
8$:	BSR	FlushDosBuffer		;write out last buffer
9$:	RTS

MacMacBin:
	PUSH	D2-D3/A2-A3
	CLR.W	InputByteCount		;start with no input
	MOVE.L	DosBuffer,OutputPtr		;init output buffer
	MOVE.W	#DosBufSize,OutputByteCount	;can store this many
;	CLR.W	OutputByteCount
	ZAP	D0
	BSR	PutDosChar		;MacBinary version 0
	MOVE.L	CurFib,A2
	LEA	df_Name(A2),A3
	MOVE.L	A3,A0
	LEN.	A0
	MOVE.W	D0,D2			;save length
	BSR	PutDosChar		;store file name length
	MOVE.W	D2,D3
	BSR	CopyMacBytes		;move name into buffer
	MOVEQ	#63,D3			;fill remainder of name area
	SUB.W	D2,D3
	BSR	NullFill
	MOVE.L	MacHandle,A2
	IFZB	HFSFlag,1$
	ADDQ.L	#2,A2
1$:	LEA	FF_FinderType(A2),A3
	MOVEQ	#16,D3
	BSR	CopyMacBytes
	MOVE.B	FF_Flags(A2),D0		;get protected byte
	AND.B	#1,D0
	BSR	PutDosChar
	ZAP	D0
	BSR	PutDosChar
	LEA	FF_DataLEOF(A2),A3
	MOVE.L	(A3),DataForkLen
	BSR	Copy4Bytes
	LEA	FF_ResLEOF(A2),A3
	MOVE.L	(A3),ResForkLen
	BSR	Copy4Bytes
	LEA	FF_CDate(A2),A3
	MOVEQ	#8,D3
	BSR	CopyMacBytes
	MOVEQ	#27,D3
	BSR	NullFill
	ZAP	D0
	BSR	PutDosChar
	MOVEQ	#1,D0			;Mac plus version
	BSR	PutDosChar
	MOVE.L	DataForkLen,D0
	BEQ.S	2$			;no data fork
	BSR	CopyFromFork		;copy data fork to Dos
	ERROR	9$
2$:	IFZL	ResForkLen,9$		;no resource fork
	BSR	OpenResFork		;switch to resource fork, if any
	MOVE.L	ResForkLen,D0
	BSR	CopyFromFork		;copy resource fork to Dos
9$:	BSR	FlushDosBuffer		;complete the last buffer
	POP	D2-D3/A2-A3
	RTS

* Copies D0 bytes from Mac fork to Dos file.
* If length in D0 not even mult of 128, fills as necessary.

CopyFromFork:
	PUSH	D2-D3
	MOVE.L	D0,D2
	MOVE.L	D2,D3
1$:	BSR	GetMacChar
	ERROR	9$
	BSR	PutDosChar
	ERROR	9$
	DECL	D3
	BNE.S	1$
	AND.W	#$7F,D2		;odd length?
	BEQ.S	9$
	MOVE.W	#128,D3
	SUB.W	D2,D3		;calc amount to fill
	BSR	NullFill	;do it
9$:	POP	D2-D3
	RTS

* Copies D3 bytes via A3 to Dos file.

Copy4Bytes:
	MOVEQ	#4,D3
CopyMacBytes:
	DECW	D3
1$:	MOVE.B	(A3)+,D0
	BSR	PutDosChar
	DBF	D3,1$
	RTS

* Stores D3 null bytes.

NullFill:
	DECW	D3
1$:	ZAP	D0
	BSR	PutDosChar
	DBF	D3,1$
	RTS

MacBin:
	CLR.W	InputByteCount		;start with no input
	MOVE.L	DosBuffer,OutputPtr		;init output buffer
	MOVE.W	#DosBufSize,OutputByteCount	;can store this many
;	CLR.W	OutputByteCount
1$:	BSR	GetMacChar
	ERROR	8$
	BSR	PutDosChar
	ERROR	9$
	BRA.S	1$
8$:	BSR	FlushDosBuffer		;write out last buffer
9$:	RTS

* First check, then skip MacPaint file header

CheckMPFile:
	IFNEIB	ConvFlag,#4,9$		;not MacPaint conversion
	MOVE.L	MacHandle,A0
	MOVE.L	FR_FinderType(A0),D0	;get file type
	IFNZB	HFSFlag,1$		;HFS...found type
	MOVE.L	FF_FinderType(A0),D0
1$:	CMP.L	#'PNTG',D0		;MacPaint format?
	BEQ.S	9$			;yes...all is well
	MOVE.L	CurFib,A0
	LEA	df_Name(A0),A0
	FileErr	A0,NotMPFile.
	STC
	RTS
9$:	CLC
	RTS

* First verify format of IFF file, and position to BODY chunk.

CheckIFFFile:
	IFNEIB	ConvFlag,#4,9$,L	;not MacPaint conversion
	CLR.B	IFFFlags		;start with no flags
	CLR.W	InputByteCount		;start with no input
	MOVE.L	MacBuffer,OutputPtr		;init output buffer
	MOVE.W	AllocBlkSizeW,OutputByteCount	;can store this many
	BSR	GetDosLong		;get firt 4 bytes of file
	CMP.L	#'FORM',D0		;IFF MUST start 'FORM' or 'CAT '
	BEQ.S	10$			;found 'FORM'
	CMP.L	#'CAT ',D0		;else try 'CAT '
	BEQ.S	11$			;okay...scan for first form
	CMP.L	#'LIST',D0		;rules say it must be one
	BNE.S	12$			;no...not an IFF file
	LEA	NoLIST.,A1		;list not supported
	BRA	18$
12$:	LEA	NotIFFFile.,A1
	BRA	18$
11$:	BSR	GetDosLong		;block size
	ERROR	8$
	BSR	GetDosLong		;CAT contents...ignore
	ERROR	8$
13$:	BSR	GetDosLong		;get first chunk in CAT
	ERROR	8$
	CMP.L	#'FORM',D0		;FORM chunk?
	BEQ.S	10$			;ah so...
	BSR	SkipChunk		;else skip that sucker...
	NOERROR	13$			;and loop looking for FORM
	BRA	8$			;eof		

10$:	BSR	GetDosLong
	ERROR	8$
	MOVE.L	CurFib,A1
	MOVE.L	df_Size(A1),D1		;get size of file
	SUBQ.L	#8,D1
	IFGTL	D0,D1,8$		;file is smaller than hdr claims
	CLR.W	ChunkLength		;start with nothing to skip
	BSR	GetDosLong		;get form type...we want ILBM
	ERROR	8$
	CMP.L	#'ILBM',D0		;there are many other types
	BNE.S	8$			;we take only 'ILBM'
1$:	BSR	GetDosLong		;get chunk ID
	ERROR	8$
	CMP.L	#'CMAP',D0
	BNE.S	2$
	BSR	ProcessCMAP
	NOERROR	1$			;go get another chunk
	BRA.S	8$

2$:	CMP.L	#'BMHD',D0
	BNE.S	3$
	BSR	ProcessBMHD
	NOERROR	1$
	BRA.S	8$

3$:	CMP.L	#'CAMG',D0
	BNE.S	4$
	BSR	ProcessCAMG
	NOERROR	1$
	BRA.S	8$

4$:	CMP.L	#'BODY',D0
	BEQ.S	7$			;found BODY chunk	
	BSR	SkipChunk		;process non-body chunk
	NOERROR	1$
	BRA.S	8$			;loop till we get to BODY

7$:	BSR	GetDosLong		;skip BODY length - point to data
	ERROR	8$
	MOVE.B	IFFFlags,D0
	AND.B	#3,D0
	CMP.B	#3,D0			;got BMHD and CMAP?
	BEQ.S	9$			;yes...can process BODY
8$:	LEA	BadIFFformat.,A1
18$:	MOVE.L	CurFib,A0
	LEA	df_Name(A0),A0
	FileErr	A0,A1
	STC
	RTS
9$:	CLC
	RTS

* Skip over chunk, whose id is in D0 (ascii).

SkipChunk:
	PUSH	D2
	BSR	GetDosLong		;get chunk length
	ERROR	8$
	MOVE.W	D0,D2			;number of bytes to skip
	ADD.W	#1,D2			;round up
	BCLR	#0,D2
	DECW	D2			;for dbf
1$:	BSR	GetDosChar		;get char of chunk
	ERROR	8$
	DBF	D2,1$
8$:	POP	D2
	RTS

* Fills scan line with data from MacPaint scan line.
* Expands compressed data to 576 pixels.

MacFillScanLine:
	PUSH	D2/A2-A3
	LEA	PixelBuffer,A2
	MOVE.L	A2,A3
	ADD.L	#MacPixelLimit,A3	;point to end of line for input
1$:	BSR	GetMacChar	;now fill scanline buffer
	ERROR	9$,L
	TST.B	D0		;replicate?
	BPL.S	3$		;no...literal string

	NEG.B	D0
	MOVE.W	D0,D2		;use for DBF as is (+1, -1)
	MOVE.L	A2,D0
	ADD.L	D2,D0		;check if data will fit
	IFLTL	D0,A3,6$	;OKAY
	MOVE.L	A3,D2
	SUB.L	A2,D2
	DECW	D2		;only process this many
6$:	BSR	GetMacChar	;get replicated char
	ERROR	9$
2$:	MOVE.B	D0,(A2)+	;replicate the char
	DBF	D2,2$
	BRA.S	5$

3$:	MOVE.W	D0,D2		;use as is for DBF
	MOVE.L	A2,D0
	ADD.L	D2,D0		;check if data will fit
	IFLTL	D0,A3,4$	;OKAY
	MOVE.L	A3,D2
	SUB.L	A2,D2
	DECW	D2		;only process this many
4$:	BSR	GetMacChar	
	ERROR	9$
	MOVE.B	D0,(A2)+
	DBF	D2,4$
5$:	IFLTL	A2,A3,1$,L	;line not yet full
9$:	POP	D2/A2-A3
	RTS

* Outputs scanline data to IFF file.
* Compresses 640-pixel scanline data for iff format.
* Note: this routine fails if the last 2 bytes (16 pixels)
* in the scan line don't match.???

DosFlushScanLine:
	PUSH	D2-D3/A2-A3
	LEA	PixelBuffer,A2
	MOVE.L	A2,A3
	ADD.L	#DosPixelLimit,A3	;limit us to 640x720
;	ADD.W	RasterWD,A3
1$:	MOVE.L	A2,A0		;save ptr to literal string
	MOVE.B	(A2)+,D2	;get control byte
	IFGEL	A2,A3,7$,L	;oops...last byte by itself
	MOVE.B	(A2)+,D0	;get next byte
	CMP.B	D0,D2		;next byte identical?
	BNE.S	5$		;no...building literal string
	MOVEQ	#1,D1		;got a run of 2 bytes (n+1)
2$:	IFGEL	A2,A3,4$	;end of buffer...stop
	CMP.B	(A2)+,D2	;another match?
	BNE.S	3$		;NO...output replication
	INCL	D1		;else count it
	BRA.S	2$		;and loop for length of replication
3$:	DECW	A2		;back up to non-matching char
4$:	MOVE.W	D1,D0
;	DECW	D1
	NEG.W	D0		;negative byte count for replicate
	BSR	PutDosChar	;into Dos buffer
	INCL	BodyCount	;count char
	MOVE.B	D2,D0	
	BSR	PutDosChar	;store replicated char
	INCL	BodyCount	;count char
	IFLTL	A2,A3,1$	;not end of buffer...loop
	BRA.S	9$		;look for next string

5$:	MOVE.B	D0,D2		;save byte
	IFGEL	A2,A3,7$	;no more data
	MOVE.B	(A2)+,D0	;get next one
	CMP.B	D0,D2
	BNE.S	5$		;loop until matching pair
	SUBQ.L	#2,A2		;backup to first of matching pair
7$:	MOVE.L	A2,D2		;calc length of literal string
	SUB.L	A0,D2
	DECW	D2		;adjust per algorithm and for DBF
	MOVE.L	A0,A2		;ptr to literal string
	MOVE.B	D2,D0
	BSR	PutDosChar	;store length of run
	INCL	BodyCount
6$:	MOVE.B	(A2)+,D0	;get byte of run
	BSR	PutDosChar	;store literal char
	INCL	BodyCount
	DBF	D2,6$		;loop
	IFLTL	A2,A3,1$,L	;go until scanline completed

9$:	POP	D2-D3/A2-A3
	RTS

* Get next Dos char in D0.  CY=1 on error or EOF.

GetDosChar:
	INCL	ProgressCount
	MOVE.L	ProgressCount,D0
	AND.W	#$1FF,D0
	BNE.S	2$
	BSR	UpdateBlocks
	BSR	CheckAbort		;check for op abort
	ERROR	8$			;bail out
2$:	IFNZW	InputByteCount,1$
	BSR	ReadDosBlock		;read next block of Dos data
	RTSERR				;read error
	IFNZB	EofFlag,8$		;no more input
	MOVE.L	DosBytCnt,D0
	MOVE.W	D0,InputByteCount
	MOVE.L	DosBuffer,A0
	MOVE.L	A0,InputPtr
1$:	MOVE.L	InputPtr,A0
	ZAP	D0
	MOVE.B	(A0)+,D0
	MOVE.L	A0,InputPtr
	DECW	InputByteCount
	RTS
8$:	STC
	RTS

* Reads the next 2 bytes from DosBuffer into D0.

GetDosWord:
	PUSH	D2-D3
	MOVEQ	#1,D2
	ZAP	D3
1$:	BSR	GetDosChar
	ERROR	8$
	LSL.L	#8,D3
	MOVE.B	D0,D3
	DBF	D2,1$
	MOVE.L	D3,D0
8$:	POP	D2-D3
	RTS

* Reads the next 4 bytes from DosBuffer into D0.

GetDosLong:
	PUSH	D2-D3
	MOVEQ	#3,D2
	ZAP	D3
1$:	BSR	GetDosChar
	ERROR	8$
	LSL.L	#8,D3
	MOVE.B	D0,D3
	DBF	D2,1$
	MOVE.L	D3,D0
8$:	POP	D2-D3
	RTS

* Write char in D0 to Dos buffer.  Write out buffer when full.
* Returns CY=1 on write error.

PutDosChar:
	IFNZW	OutputByteCount,1$
	MOVE.L	DosBuffer,OutputPtr		;init output buffer
	MOVE.W	#DosBufSize,OutputByteCount	;can store this many
1$:	MOVE.L	OutputPtr,A0
	MOVE.B	D0,(A0)+
	MOVE.L	A0,OutputPtr
	DECW	OutputByteCount			;any room left?
	BNE.S	2$
	BSR	FlushDosBuffer
2$:	RTS

* Get next Mac char in D0.  CY=1 on error or EOF.

GetMacChar:
	INCL	ProgressCount
	MOVE.L	ProgressCount,D0
	AND.W	#$1FF,D0
	BNE.S	2$
	BSR	UpdateBlocks
	BSR	CheckAbort		;check for op abort
	ERROR	8$
2$:	IFNZW	InputByteCount,1$
	BSR	ReadMacBlock		;read next block of Dos data
	RTSERR				;read error
	IFNZB	EofFlag,8$		;no more input
	MOVE.L	MacBytCnt,D0
	MOVE.W	D0,InputByteCount
	MOVE.L	MacBuffer,A0
	MOVE.L	A0,InputPtr
1$:	MOVE.L	InputPtr,A0
	ZAP	D0
	MOVE.B	(A0)+,D0
	MOVE.L	A0,InputPtr
	DECW	InputByteCount
	RTS
8$:	STC
	RTS

* Write char in D0 to Mac buffer.  Write out buffer when full.
* Returns CY=1 on write error.

PutMacChar:
	IFNZW	OutputByteCount,1$
	MOVE.L	MacBuffer,OutputPtr		;init output buffer
	MOVE.W	AllocBlkSizeW,OutputByteCount	;can store this many
1$:	MOVE.L	OutputPtr,A0
	MOVE.B	D0,(A0)+
	MOVE.L	A0,OutputPtr
	DECW	OutputByteCount			;any room left?
	BNE.S	2$
	BSR	FlushMacBuffer
2$:	RTS

* Write out MacBuffer.  Calculates logical byte count in buffer.  CY=1
* on write error.

FlushMacBuffer:
	ZAP	D0
	MOVE.W	AllocBlkSizeW,D0
	SUB.W	OutputByteCount,D0		;calc useful byte count
	BSR	WriteMacBlock			;else write out full buffer
	RTS

* Write out Dos buffer.  Calculates logical byte count in buffer.  CY=1
* on write error.

FlushDosBuffer:
	ZAP	D0
	MOVE.W	#DosBufSize,D0
	SUB.W	OutputByteCount,D0		;calc useful byte count
	MOVE.L	DosBuffer,A0
	BSR	WriteDosBlock			;else write out full buffer
	RTS

* Tests for disk loaded in Mac drive and rejects cmd if not valid.

CheckMacDrive:
	BSR	GetDriveStatus
	IFZL	D0,1$			;there is a disk
	LEA	NoMacDisk.,A0
	BRA.S	8$
1$:	IFNZB	ValidMacVol,9$		;valid Mac disk...proceed
	LEA	InvMacDisk.,A0
8$:	DispErr	A0
	STC
9$:	RTS

* Tests for valid Dos volume/path.

CheckDosVol:
	IFNZB	ValidDosVol,9$		;valid Dos vol...proceed
	DispErr	InvDosVol.
	STC
9$:	RTS

* Checks for possible operator-directed abort or read/write error.

CheckAbort:
	BSR	CheckForMsg		;see if anything is happening
	ERROR	8$			;oops...bail out
	IFZL	D0,1$
	BSR	ProcessMsg
1$:	IFZB	AbortFlg,9$		;bail out
8$:	SETF	AbortFlg
	STC
9$:	RTS

* LOCAL DATA

* The items in this list MUST match the values of ConvFlag.

AmyConv		DC.L	AmyBin
		DC.L	AmyMacBin
		DC.L	AmyASCII
		DC.L	AmyPS
		DC.L	AmyPaint

MacConv		DC.L	MacBin
		DC.L	MacMacBin
		DC.L	MacASCII
		DC.L	MacPS
		DC.L	MacPaint

DataForkLen	DC.L	0
ResForkLen	DC.L	0

BodyCount	DC.L	0	;count of bytes in BODY
ChunkLength	DC.W	0
ScanLineCnt	DC.W	0	;max scan line count		;1/24/90
CAMGFlag	DC.B	0
BlkCntFlg	DC.B	0	;1=display block counts

NoMacFiles.	TEXTZ	<'No Mac files selected to process.'>
NoDosFiles.	TEXTZ	<'No Amiga files selected to process.'>
NotMPFile.	TEXTZ	<'File is not in MacPaint format:'>
NotIFFFile.	TEXTZ	<'File is not in IFF format:'>
NoLIST.		TEXTZ	<'IFF LIST format not supported:'>
BadIFFformat.	TEXTZ	<'IFF file data corrupted:'>
NoMacDisk.	TEXTZ	<'No Mac diskette loaded.'>
InvMacDisk.	TEXTZ	<'Not a Mac disk in Mac drive.'>
InvDosVol.	TEXTZ	<'Amiga volume undefined.'>

* Standard IFF medium res file header

	CNOP	0,4

IFFHdr		DC.B	'FORM'
FORMlen		DC.L	0		;length of chunk (filled in later)
		DC.B	'ILBM'		;interleaved bitmap
		DC.B	'BMHD'		;bitmap header
		DC.L	20		;length of bitmap hdr
		DC.W	640		;width
		DC.W	720		;ht in pixels
		DC.W	0,0		;display pos x, y
		DC.B	1		;number of bitplanes
		DC.B	0		;no mask
		DC.B	1		;standard compression
		DC.B	0		;pad
		DC.W	0		;no transparent color
		DC.B	20,11		;Amiga aspect ratio
RasterWD	DC.W	640		;page width
RasterHT	DC.W	400		;page ht in pixels
		DC.B	'CMAG'
		DC.L	4
ViewMode	DC.L	$8004		;hires, lace
		DC.B	'CMAP'		;color map
		DC.L	6
		DC.B	$F0,$F0,$F0,0,0,0 ;white, black
		DC.B	'BODY'
BODYlen		DC.L	0		;length of chunk (filled in later)

IFFHdrLen	EQU	*-IFFHdr

		DC.B	0		;terminator

MP.		TEXTZ	'PNTGMPNT'

PixelBuffer	DS.B	PixelBufferSize

	END
