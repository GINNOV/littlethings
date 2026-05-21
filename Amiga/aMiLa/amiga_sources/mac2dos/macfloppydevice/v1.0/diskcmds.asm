*********************************************************
*							*
*		DISKCMDS.ASM				*
*							*
* 	Mac-2-Dos Mac format/rename commands		*
*							*
*	Copyright (c) 1989 Central Coast Software	*
*	424 Vista Ave, Golden, CO 80401			*
*	All rights reserved, worldwide			*
*********************************************************

;	INCLUDE	"MAC.I"
;	INCLUDE "VD0:MACROS.ASM"
	INCLUDE	"PRE.OBJ"
	INCLUDE	"BOXES.ASM"

	XDEF	FormatDisk
;	XDEF	MakeDir
	XDEF	FileInfo
	XDEF	RenameVol
	XDEF	VerifyDisk

	XDEF	Format0.,Format1.,Format2.
	XDEF	Format3.,Verify.,Create.
	XDEF	RenVol.
	XDEF	FInfo0.,FInfo1.,FInfo2.
	XDEF	FInfo3.,FInfo4.,FInfo5.,FInfo6.

	XREF	ReadSector,ReadN,WriteSector,WriteN
	XREF	GetDriveType
	XREF	FlushTrack,MotorOff
	XREF	OpenRequester,CloseRequester
	XREF	WaitRequester,CancelRequester
	XREF	CheckMacDrive
	XREF	GetDriveStatus
	XREF	FormatTrack
	XREF	GetMacDate
	XREF	DiskLog,BuildMacDir
	XREF	WriteVolBlock
	XREF	MarkVolInvalid
	XREF	BitMapBuf
	XREF	InitBaseNode
	XREF	InitRootDir,UpdateRootDir
	XREF	InitMacList,InitDosList
	XREF	NextDosFile,NextMacFile
	XREF	FindFileRec,FlushMacDirectory
	XREF	UpdateMacName,UpdateDosName
	XREF	UpdateMacWindow,UpdateDosWindow
	XREF	UpdateMacVol
	XREF	WriteDirectory

	XREF	DosBase,SysBase
	XREF	MacVolName.
	XREF	VolBuf
	XREF	A.,TMP.,TMP2.,PATH.
	XREF	HFSFlag,MacToAmy
	XREF	ReqVolGad,ReqRenVolGad
	XREF	ReqCan
	XREF	VerifyTxt
	XREF	FormatTxt,Format2Txt
	XREF	CreateDirTxt
	XREF	RenVolTxt
	XREF	REQUEST,REQTXT,REQGAD
	XREF	NoMacDisk.
	XREF	VNAM_INFO
	XREF	CheckWrtProt
	XREF	FINameGad,FINamBuf,FITypeBuf,FICreatorBuf
	XREF	FInfoTxt,FINamInfo
	XREF	CurFib
	XREF	ConvMacDate
	XREF	MacHandle

DirBlockSize	EQU	2000	;size of directory block
FirstDirBlk	EQU	4	;first flat dir block
FlatDirSize	EQU	12	;flat dir size in blocks
BitMapBlk	EQU	3	;this is where bitmap starts
TreeSize	EQU	12	;number of blocks in tree
TreeClumpSize	EQU	MacBufSize*TreeSize
XTFirst		EQU	0	;extents tree goes in alloc blk 0
FirstID		EQU	16	;first unused file id

* Menu routines

;MakeDir:
;	DispErr	NotYet.
;	RTS

FileInfo:
	PUSH	A2
	CLR.B	ChgFlag			;no changes yet
	IFNZB	MacToAmy,1$		;Mac file selected
	CLR.B	FITypeBuf
	CLR.B	FICreatorBuf
	BSR	InitDosList
	BSR	NextDosFile
	ERROR	9$
	BRA.S	5$
1$:	BSR	InitMacList
	BSR	NextMacFile
	ERROR	9$
	BSR	FindFileRec
	ERROR	9$
	MOVE.L	MacHandle,A0
	IFZB	HFSFlag,2$
	ADDQ.L	#2,A0
2$:	LEA	FF_FinderType(A0),A0
	MOVE.L	(A0)+,FITypeBuf
	MOVE.L	(A0)+,FICreatorBuf

5$:	MOVE.L	CurFib,A2
	MOVE.	df_Name(A2),FINamBuf
	LEN.	FINamBuf
	MOVE.W	D0,FINamInfo+si_BufferPos
	MOVE.L	#FINameGad,REQGAD
	MOVE.L	#FInfoTxt,REQTXT
	BSR	OpenRequester
	ERROR	9$
	STR.	L,df_Size(A2),TMP.,#32,#8
	STRIP_LB. TMP.
	DispRMsg #FISize_LE,#FISize_TE,TMP.,BLACK,WHITE
	ZAP	D0
	MOVE.W	df_Date(A2),D0
	IFZB	MacToAmy,6$
	MOVE.L	df_Date(A2),D0		;get mac file date
	BSR	ConvMacDate		;get Dos date in D0
6$:	BSR	ConvertDosDate		;convert dos date to dd-mmm-yy
	DispRMsg #FIDate_LE,#FIDate_TE,TMP.,BLACK,WHITE
66$:	LEA	TMP.,A0
	MOVE.B	#'N',D0
	BTST	#0,df_Flags(A2)		;protected?
	BEQ.S	7$			;no
	MOVE.B	#'Y',D0			;else use X
7$:	MOVE.B	D0,(A0)+
	CLR.B	(A0)
	DECL	A0
	DispRMsg #ProtGad_LE,#ProtGad_TE,TMP.,BLACK,WHITE
8$:	BSR	WaitRequester
	ERROR	10$
	SETF	ChgFlag			;op changed something
	IFNEIB	D0,#2,66$
	BCHG	#0,df_Flags(A2)
	BRA.S	66$
10$:	IFZB	ChgFlag,9$		;no change...just exit
	IFZB	MacToAmy,11$
	BSR	UpdateMacName		;do the name update
	BSR	UpdateMacWindow
	BRA.S	9$
11$:	BSR	UpdateDosName		;else update dos name
	BSR	UpdateDosWindow
9$:	POP	A2
	RTS

* Allows renaming the Mac volume.

RenameVol:
	BSR	CheckMacDrive
	RTSERR
	MOVE.L	#RenVolTxt,REQTXT
	MOVE.L	#ReqRenVolGad,REQGAD
	BSR	OpenRequester
	ERROR	9$
	BSR	WaitRequester
	ERROR	9$
	BSR	CloseRequester
	CLRBOX	MVGAD_LE,MVGAD_TE,MVGAD_WD,MVGAD_HT,BLUE
	BSR	UpdateMacVol
;	DispMsg	#MVGAD_LE,#MVGAD_TE,MacVolName.,WHITE,BLUE 
	Z_STG.	MacVolName.,VolBuf+VB_NameLen	;move new name into volbuf
	LEA	VNAM_INFO,A0
	ZAP	D0
	MOVE.B	VolBuf+VB_NameLen,D0
	MOVE.W	D0,si_BufferPos(A0)
	MOVE.W	D0,si_NumChars(A0)
	BSR	WriteVolBlock		;write out new volume
	IFZB	HFSFlag,1$
	LEA	MacVolName.,A1
	BSR	UpdateRootDir
	BSR	WriteDirectory
1$:	BSR	FlushTrack		;force last write
	BSR	MotorOff		;turn motor off
9$:	RTS

* Reads all blocks of a disk.

VerifyDisk:
	BSR	CheckMacDrive
	RTSERR
VerifyNoCheck:
	PUSH	D2-D7
	ZAP	D7			;progress bar count
	MOVEQ	#1,D6			;error flag
	MOVE.L	D6,D0			;single-sector buffer
	BSR	AllocBuffer
	BEQ	8$			;no memory...verify failed
	MOVE.L	#VerifyTxt,REQTXT
	MOVE.L	#ReqCan,REQGAD
	BSR	OpenRequester
	ERROR	7$
	CLRRBOX	VerBar_LE,VerBar_TE,VerBar_WD,VerBar_HT,ORANGE
	ZAP	D6
	MOVE.W	#800,D2
	MOVEQ	#8,D3			;starting sectors per track
	IFZB	HFSFlag,1$		;ss
	ADD.W	D2,D2
1$:	MOVEQ	#4,D5			;number of bands-1
2$:	MOVEQ	#16,D4			;tracks per band-1
	IFZB	HFSFlag,4$
	ADD.W	D4,D4			;32 tracks in DS band
4$:	DECW	D4			;for DBF
3$:	BTST	#0,D7			;display even only...looks prettier
	BNE.S	11$
	DispRBar #VerBar_LE+2,#VerBar_TE+1,D7,#REQUEST ;display progress bar
11$:	MOVE.L	D2,D0			;read this sector
	SUB.W	D3,D0			;start with last block of track
	MOVE.L	LocalBuffer,A0		;read into this buffer
	BSR	ReadSector
	ERROR	5$			;read error...verify failed
	BSR	CancelRequester		;check for possible cancel request
	ERROR	5$			;yes...op wants to bail out
	SUB.W	D3,D2			;backup by one track
	INCW	D7
	IFNZB	HFSFlag,10$		;step by one for ds
	INCW	D7			;or by 2 for ss
10$:	DBF	D4,3$			;loop for all tracks in band
	INCW	D3			;one more sector per track
	DBF	D5,2$			;loop for 5 bands
	BRA.S	6$			;verify successful
5$:	INCW	D6
6$:	BSR	MotorOff
	BSR	CloseRequester
7$:	BSR	FreeBuffer
	IFZL	D6,9$
8$:	DispErr	VerifyFailed.
	STC
9$:	POP	D2-D7
	RTS

* Formats Mac diskette.

FormatDisk:
	BSR	GetDriveStatus		;got a disk loaded?
	IFZL	D0,4$			;yes
	DispErr	NoMacDisk.
	BRA	9$
4$:	BSR	CheckWrtProt
	ERROR	9$
	IFNZB	MacVolName.,3$		;already have vol name
	MOVE.	Untitled.,MacVolName.
	LEA	VNAM_INFO,A0
	MOVEQ	#8,D0
	MOVE.W	D0,si_BufferPos(A0)
	MOVE.W	D0,si_NumChars(A0)
3$:	MOVE.L	#FormatTxt,REQTXT
	MOVE.L	#ReqVolGad,REQGAD
	BSR	OpenRequester
	ERROR	8$
1$:	BSR	WaitRequester		;return gadget number in D0
	ERROR	9$			;cancelled
	CLR.B	HFSFlag			;assume single-sided
	IFEQIW	D0,#1,2$		;single-sided
	IFNEIW	D0,#2,1$		;not double-sided
	SETF	HFSFlag
2$:	BSR	CloseRequester
	IFZB	HFSFlag,5$		;single-sided
	BSR	GetDriveType		;check if drive is double-sided
	IFNZB	D0,5$			;it is
	DispErr	SSDrive.		;else tell op about it
	BRA.S	8$
5$:	BSR	MarkVolInvalid		;show volume not valid
	BSR	WriteFormatData		;format the disk
	ERROR	8$
	BSR	VerifyNoCheck		;verify readability
	ERROR	8$
	BSR	InitDisk		;write out dir structure
	ERROR	9$
	BSR	BuildMacDir		;relog disk and display empty dir
	BRA.S	9$
8$:	DispErr	FormatFailed.
9$:	RTS

WriteFormatData:
	PUSH	D2-D7
	MOVEQ	#1,D6
	MOVE.L	#Format2Txt,REQTXT
	MOVE.L	#ReqCan,REQGAD
	BSR	OpenRequester
	ERROR	8$
	CLRRBOX	FmtBar_LE,FmtBar_TE,FmtBar_WD,FmtBar_HT,ORANGE
	MOVEQ	#12,D3			;starting sectors per track
	IFZB	HFSFlag,1$		;ss
	ADD.W	D3,D3			;ds
1$:	MOVE.W	D3,D0
	BSR	AllocBuffer		;get a buffer
	BEQ	7$			;oops...
	ZAP	D6
	ZAP	D7
	MOVEQ	#4,D5			;number of bands-1
	ZAP	D2			;start with sector 0
2$:	MOVEQ	#15,D4			;tracks per band-1
3$:	DispRBar #FmtBar_LE+2,#FmtBar_TE+1,D7,#REQUEST ;display progress bar
	MOVE.L	D2,D0			;format starting at this sector
	MOVE.L	D3,D1			;this many sectors
	MOVE.L	LocalBuffer,A0		;write from here
	BSR	FormatTrack		;format 1 or 2 tracks
	ERROR	5$			;oops
	BSR	CancelRequester
	ERROR	5$			;op wants to cancel
	ADD.W	D3,D2			;advance by 1 or 2 tracks
	ADDQ.W	#2,D7
	DBF	D4,3$			;loop for all tracks in band
	DECW	D3			;one less sector per track
	IFZB	HFSFlag,4$		;ss
	DECW	D3			;ds
4$:	DBF	D5,2$			;loop for 5 bands
	BRA.S	6$			;format complete...no error
5$:	INCW	D6
6$:	BSR	FreeBuffer		;release data buffer
	BSR	MotorOff
7$:	BSR	CloseRequester
	IFZL	D6,9$
8$:	STC
9$:	POP	D2-D7
	RTS

* Initializes VolBlock and empty directory.

InitDisk:
	MOVE.L	#CreateDirTxt,REQTXT
	CLR.L	REQGAD			;no gadgets during directory build
	BSR	OpenRequester
	ERROR	9$
	BSR	InitVolBlock
	ERROR	8$
	BSR	InitDirBlock
	ERROR	8$
	BSR	FlushTrack
	BSR	MotorOff
8$:	BSR	CloseRequester
9$:	RTS		

* Initializes Volume block

InitVolBlock:
	PUSH	A2
	LEA	VolBuf,A2
	MOVE.L	A2,A0			;zap the volbuf
	MOVE.W	#VolBufSize/4-1,D1	;better be on even boundary
	ZAP	D0
1$:	MOVE.L	D0,(A0)+
	DBF	D1,1$
	IFNZB	HFSFlag,InitHFSVol	;do them separately

	BSR	GetMacDate		;current date/time in Mac format
	MOVE.L	A2,A0
	MOVE.W	#$D2D7,(A0)+		;ss code
	MOVE.L	D0,(A0)+		;creation date
	MOVE.L	D0,(A0)+		;modification date
	CLR.W	(A0)+			;attributes
	CLR.W	(A0)+			;no files (yet)
	MOVE.W	#FirstDirBlk,(A0)+	;first block of dir
	MOVE.W	#FlatDirSize,(A0)+	;dir size in blocks
	MOVE.W	#391,D1			;FM
	MOVE.W	D1,(A0)+		;max alloc blocks
	MOVE.L	#2*MacBufSize,D0	;alloc block size
	MOVE.L	D0,(A0)+		;alloc block size
	ADD.L	D0,D0			;clump size
	MOVE.L	D0,(A0)+
	MOVE.W	#FirstDirBlk+FlatDirSize,(A0)+	;first block in blockmap
	MOVE.L	#1,(A0)+		;next file id
	MOVE.W	D1,(A0)+		;free alloc blocks 
	MOVE.L	A0,A1
	Z_STG.	MacVolName.,A1		;store vol name with leading length
	BRA	WriteVol

InitHFSVol:
	BSR	GetMacDate		;current date/time in Mac format
	MOVE.L	A2,A0
	MOVE.W	#$4244,(A0)+		;ds code
	MOVE.L	D0,(A0)+		;creation date
	MOVE.L	D0,(A0)+		;modification date
	CLR.W	(A0)+			;attributes
	CLR.W	(A0)+			;no files (yet)
	MOVE.W	#BitMapBlk,(A0)+	;first block of bitmap
	CLR.W	(A0)+			;alloc ptr
	MOVE.W	#1594,D1		;FM
	MOVE.W	D1,(A0)+		;max alloc blocks
	MOVE.L	#MacBufSize,D0		;alloc block size
	MOVE.L	D0,(A0)+		;alloc block size
	LSL.L	#2,D0			;clump size=4 blocks
	MOVE.L	D0,(A0)+
	MOVE.W	#BitMapBlk+1,(A0)+	;first block in blockmap
	MOVE.L	#FirstID,(A0)+		;next file id
	SUB.L	#TreeSize*2,D1
	MOVE.W	D1,(A0)+		;free alloc blocks 
	MOVE.L	A0,A1
	Z_STG.	MacVolName.,A1		;store vol name with leading length
	LEA	VB_BDate(A2),A0		;name field is fixed-length
	CLR.L	(A0)+			;backup date
	CLR.W	(A0)+			;reserved
	CLR.L	(A0)+			;vol write count
	MOVE.L	#TreeClumpSize,D0
	MOVE.L	D0,(A0)+		;extents tree clump
	MOVE.L	D0,(A0)+		;catalog tree clump
	CLR.W	(A0)+			;number of directories in root
	CLR.L	(A0)+			;number of files on vol
	CLR.L	(A0)+			;number of dir on vol
	ADD.L	#38,A0			;skip finder info and 3 other words
	MOVE.L	D0,(A0)+		;length of extents tree
	MOVE.W	#XTFirst,(A0)+		;first block of extents tree
	MOVE.W	#TreeSize,(A0)+		;number of blocks in extents tree
	CLR.L	(A0)+
	CLR.L	(A0)+
	MOVE.L	D0,(A0)+		;length of catalog tree
	MOVE.W	#XTFirst+TreeSize,(A0)+	;first block of catalog tree
	MOVE.W	#TreeSize,(A0)+		;number of blocks in catalog tree
	LEA	BitMapBuf,A0		;point to bitmap area of volbuf
	MOVEQ	#-1,D0
	MOVE.B	D0,(A0)+		;mark 24 blocks as busy
	MOVE.B	D0,(A0)+		;12 in extents tree
	MOVE.B	D0,(A0)+		;12 in catalog tree
WriteVol:
	LEA	VolBuf,A0
	MOVEQ	#2,D0
	MOVE.L	D0,D1
	BSR	WriteN			;write out volume
	POP	A2
	RTS


InitDirBlock:
	PUSH	D2/A2
	IFNZB	HFSFlag,1$		;HFS
	MOVEQ	#FlatDirSize,D0		;size in blocks
	BSR	AllocBuffer		;get an empty dir buffer
	BEQ	8$
	MOVEQ	#FirstDirBlk,D0
	MOVEQ	#FlatDirSize,D1
	BSR	WriteTree		;write it out
	BRA.S	7$

1$:	MOVEQ	#TreeSize,D2
	MOVE.L	D2,D0
	BSR	AllocBuffer		;buffer for extents tree
	BEQ	8$
	MOVE.L	D0,A0
	MOVE.L	D2,D1			;size in blocks
	MOVEQ	#ExtKeyLen,D0
	BSR	InitBaseNode		;fix up base node
	MOVEQ	#XTFirst+BitMapBlk+1,D0
	MOVE.L	D2,D1
	BSR.S	WriteTree		;write out tree
	ERROR	8$
	MOVE.L	LocalBuffer,A0
	MOVE.L	D2,D1			;sane size
	MOVEQ	#IdxKeyLen,D0
	BSR	InitBaseNode
	MOVE.L	LocalBuffer,A0		;build empty dir records here
	LEA	MacVolName.,A1
	BSR	InitRootDir
	MOVEQ	#XTFirst+BitMapBlk+1+TreeSize,D0
	MOVE.L	D2,D1
	BSR.S	WriteTree
7$:	ERROR	8$
	BSR	FreeBuffer
	BRA.S	9$
8$:	BSR	FreeBuffer
	STC
9$:	POP	D2/A2
	RTS

WriteTree:
	MOVE.L	LocalBuffer,A0
	BSR	WriteN			;write out these blocks
	RTS

InitDesktop:
	RTS

* Allocates a buffer for local use.  Size in blocks in D0.
* Returns ptr in D0.

AllocBuffer:
	MULU	#MacBufSize,D0
	MOVE.L	D0,LocalBufSize
	MOVE.L	#$10000,D1		;MEMF_CLEAR
	CALLSYS	AllocMem,SysBase	;get a buffer for the reads
	MOVE.L	D0,LocalBuffer		;save ptr
	RTS

FreeBuffer:
	MOVE.L	LocalBufSize,D0
	MOVE.L	LocalBuffer,D1
	BEQ.S	9$
	MOVE.L	D1,A1
	CALLSYS	FreeMem,SysBase
9$:	RTS

* Calculates day, month, and year from AmigaDOS date stamp in D0.  
* Stores in result in TMP.  FROM EDN OCT 17, 1985 P. 168

ConvertDosDate:
	PUSH	D2
	ADDI.L	#28431,D0		;MAGIC NUMBER CONVERTS TO MARCH 1, 1900
	MULU	#4,D0
	SUBQ.L	#1,D0			;K2=4*K-1
	MOVE.L	D0,D2
	DIVU	#1461,D2		;Y=INT(K2/1461)
	MOVE.L	D2,D1
	SWAP	D1			;D=INT (K2 MOD 1461)
	ADDQ.W	#4,D1
	LSR.W	#2,D1			;D=INT ((D+4)/4)
	MULU	#5,D1
	SUBQ.L	#3,D1
	DIVU	#153,D1	 		;M=INT ((5*D-3)/153)
	MOVE.W	D1,D0
	SWAP	D1
	EXT.L	D1			;D=INT ((5*D-3) MOD 153)
	ADDQ.L	#5,D1
	DIVU	#5,D1			;D=INT ((D+5)/5)
	CMPI.W	#10,D0
	BLT.S	1$
	SUBI.W	#9,D0			;M=M-9
	ADDQ.W	#1,D2			;Y=Y+1
	BRA.S	2$
1$:	ADDQ.W	#3,D0
; month in D0, day in D1, year in D2 at this point
2$:	PUSH	D0			;save month
	STR.	W,D1,TMP2.,#32,#2	;convert day
	MOVE.	TMP2.,TMP.
	ACHAR.	#'-',TMP.
	POP	D0
	DECW	D0
	LSL.W	#2,D0			;change into long index
	LEA	MONTHS(D0.W),A0		;index month names
	APPEND.	A0,TMP.
	ACHAR.	#'-',TMP.
	STR.	W,D2,TMP2.,#'0',#2
	APPEND.	TMP2.,TMP.
;	ACHAR.	#32,TMP.		;add a trailing space
	POP	D2
	RTS

* Warning - don't move this table...must be right here.

MONTHS	TEXTZ	'JAN'
	TEXTZ	'FEB'
	TEXTZ	'MAR'
	TEXTZ	'APR'
	TEXTZ	'MAY'
	TEXTZ	'JUN'
	TEXTZ	'JUL'
	TEXTZ	'AUG'
	TEXTZ	'SEP'
	TEXTZ	'OCT'
	TEXTZ	'NOV'
	TEXTZ	'DEC'

LocalBuffer	DC.L	0	;local data buffer ptr
LocalBufSize	DC.L	0
DosDate		DC.L	0,0,0
ChgFlag		DC.B	0

Format0. TEXTZ	<'Format Macintosh diskette'>
Format1. TEXTZ	<'WARNING - Old contents will be lost!'>
RenVol.
Format2. TEXTZ	<'Enter new volume name:'>
Format3. TEXTZ	<'Formatting Mac disk ... please wait'>
Verify.	 TEXTZ	<'Verifying Mac disk ... please wait'>
Create.	 TEXTZ	<'Creating directory ... please wait'>
Untitled. TEXTZ	<'Untitled'>
;VerifyPassed.	TEXTZ	<'Mac disk has no errors.'>
VerifyFailed.	TEXTZ	<'Mac disk verify failed.'>
FormatFailed.	TEXTZ	<'Formatting attempt unsuccessful.'>
SSDrive.	TEXTZ	<'Your Mac drive is single-sided.'>
FInfo0.	TEXTZ	<'FILE INFO'>
FInfo1.	TEXTZ	<'Name:'>
FInfo2.	TEXTZ	<'Size:'>
FInfo3.	TEXTZ	<'Date:'>
FInfo4.	TEXTZ	<'Protected:'>
FInfo5.	TEXTZ	<'Type:'>
FInfo6.	TEXTZ	<'Creator:'>	


	END
