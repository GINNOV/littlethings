*********************************************************
*							*
*		MACFILES.ASM				*
*							*
* 	Mac-2-Dos Mac file system routines		*
*							*
*	Copyright (c) 1989 Central Coast Software	*
*	424 Vista Ave, Golden, CO 80401			*
*	All rights reserved, worldwide			*
*********************************************************

;	INCLUDE	"MAC.I"
;	INCLUDE "VD0:MACROS.ASM"
	INCLUDE	"PRE.OBJ"

DEMO	EQU	0	;1=DEMO VERSION, 0=PRODUCTION

	XDEF	DiskLog,FreeMacDirBlocks,FreeBuffers
	XDEF	OpenMacFile,CloseMacFile,CreateMacFile,DeleteMacFile
	XDEF	OpenResFork,NewResFork
	XDEF	ReadMacBlock,WriteMacBlock
	XDEF	WriteVolBlock
	XDEF	AppendMacPath,TruncateMacPath
	XDEF	GetVolName
	XDEF	ConvMacDate,ConvDosDate
	XDEF	GetMacDate
	XDEF	WriteDirExtents
	XDEF	FlushMacDirectory
	XDEF	FindFileRec
	XDEF	UpdateMacName
	XDEF	ReadExtTree
	XDEF	WriteDirectory
	XDEF	AddCatExtent

	XDEF	MacRootLevel,MacCurLevel
	XDEF	MacBuffer
	XDEF	ValidMacVol
	XDEF	MacFileNbr
	XDEF	CatBufEnd
	XDEF	ExtBuf,CatBuf
	XDEF	MacPath.
	XDEF	HFSFlag
	XDEF	MacBytCnt
	XDEF	AllocBlkSizeW,AllocBlkSizeL
	XDEF	MacType,MacCreator
	XDEF	MacVolName.
	XDEF	ExtRecPtr,ExtRecCnt
	XDEF	ForkType
	XDEF	MacBlock
	XDEF	BlockOffset
	XDEF	MacBlkCnt,ExtBlkCnt
	XDEF	MacHandle
	XDEF	FileDate
	XDEF	ExtDirtyFlg

	XREF	AllocateFileRec,InsertCatRec
	XREF	ReadSector,ReadN,WriteSector,WriteN
	XREF	MotorOff
	XREF	SortInsert,CompareNames
	XREF	FlushTrack
	XREF	ZapLevelBlk,LimitMove
	XREF	InitSearch,GetFirstLeafRec,GetNextLeafRec
	XREF	NextLeafNode
	XREF	FindNextExtent
	XREF	AllocHFSBlock
	XREF	DeleteHFSFile
	XREF	UpdateValence
	XREF	FindHFSFile,UpdateHFSName
	XREF	CheckWrtProt
	XREF	DeleteCurFib
	XREF	AllocCatClump

	XREF	DosBase,SysBase
	XREF	VolBuf
	XREF	A.,TMP.,PATH.
	XREF	CurFib
	XREF	EofFlag,AutoRepFlg
	XREF	DupTxt
	XREF	FileName.
	XREF	VNAM_INFO
	XREF	FINamBuf,FITypeBuf,FICreatorBuf
	XREF	CantDelFile.
	XREF	AbortFlg

;PathSize	EQU	512		;max path size
FileNameLen	EQU	31		;max Mac file name length
DirBlockSize	EQU	2000		;size of directory block
MaxCatBlks	EQU	24		;fixed catalog tree size

* LOGS IN THE Mac DISK, AND GETS READY TO ACCESS FILES.

DiskLog:
	CLR.B	MacPath.	;zap path
	BSR	FreeBuffers	;release previously allocated buffers
	BSR	FreeMacDirBlocks ;release previous dir
	ZAP	D0
	MOVE.B	D0,DirDirtyFlg
	MOVE.B	D0,ExtDirtyFlg
	MOVE.L	D0,MacCurLevel
;	CLR.L	MacCurLevel
	BSR	ReadVolBlock	;find out what kind of disk is loaded
	ERROR	9$		;cant read disk
	BSR	CheckVolParams	;check out type of diskette
	ERROR	9$		;dont recognize format
	BSR	ReadDirectory	;load directory blocks
	ERROR	9$		;some problem
	BSR	BuildRootDir	;build the root directory
9$:	RTS

* Reads Mac disk volume block (flat or HFS).

ReadVolBlock:
	CLR.B	ValidMacVol	;vol block contents unknown
	CLR.B	MacVolName.
	MOVEQ	#2,D0		;volume info starts in block 2
	MOVEQ	#2,D1		;2 blocks
	LEA	VolBuf,A0
	BSR	ReadN		;read volume info
	ERROR	9$
	LEA	VolBuf,A0
	LEA	VB_BlockMap(A0),A1
	MOVE.L	A1,BlockMapPtr	;save ptr to start of alloc blk map (flat)
	MOVE.W	VB_FirstAlloc(A0),BlockOffset ;alloc block offset
;	BSR	GetVolName
;	SETF	ValidMacVol	;volume info is valid
9$:	RTS

WriteVolBlock:
	IFZB	ValidMacVol,9$	;dont write bad volume
	BSR	GetMacDate
	MOVE.L	D0,VolBuf+VB_MDate	;update vol mod date
	MOVEQ	#2,D0		;volume info goes in block 2
	MOVE.L	D0,D1		;write out two blocks
	LEA	VolBuf,A0
	BSR	WriteN		;write the volume info to disk
9$:	RTS

* Extract Mac params from volume block.

CheckVolParams:
	SETF	HFSFlag			;HFS file system
	LEA	VolBuf,A0
	MOVE.L	VB_AllocBlkSize(A0),D0
	MOVE.L	D0,AllocBlkSizeL
	LSR.L	#8,D0
	LSR.L	#1,D0
	MOVE.W	D0,BlksPerAllocBlk
	MOVE.W	VB_SigWord(A0),D0	;disk single-sided?
	CMP.W	#$4244,D0		;HFS format (800KB)?
	BEQ.S	1$			;yes...assumption valid
	CLR.B	HFSFlag
	CMP.W	#$D2D7,D0		;FLAT format (400KB)?
	BNE.S	8$			;no...unknown format
1$:	SETF	ValidMacVol		;volume info appears valid
	MOVE.L	AllocBlkSizeL,D0
	ZAP	D1
	CALLSYS	AllocMem,SysBase	;allocate Mac alloc block buffer
	MOVE.L	D0,MacBuffer
	BNE.S	9$
8$:	STC
9$:	RTS

* Reads Mac disk directory structure.  For flat file disks, directory 
* follows volume block.  For HFS disks, must read catalog tree.

ReadDirectory:
	PUSH	D2-D4/A2-A3
	MOVEQ	#9,D4
	LEA	VolBuf,A2
	MOVE.W	VB_DirLen(A2),D0	;size in blocks
	IFZB	HFSFlag,1$		;flat structure
	MOVE.W	VB_CTXRec+2(A2),D0	;blocks in 1st extent
	ADD.W	VB_CTXRec+6(A2),D0	;blocks of 2nd extent
	ADD.W	VB_CTXRec+10(A2),D0	;blocks of 3rd extent
1$:	IFZW	D0,8$,L			;bad format...bail out
	MOVEQ	#MaxCatBlks,D1		;*** limits catalog tree
	IFGEW	D0,D1,5$		;use larger number from disk
	MOVE.W	D1,D0			;else use minimum size
5$:	MULU	AllocBlkSizeW,D0	;size of catalog buffer
	MOVE.L	D0,CatBufSize		;save size for later release
	ZAP	D1			;any kind of memory
	CALLSYS	AllocMem,SysBase
	MOVE.L	D0,CatBuf		;got any?
	BEQ	8$			;no...bail out
	MOVE.L	D0,A0			;catalog goes here	
	ZAP	D2			;flat dir is single extent
	MOVE.W	VB_FirstDirBlk(A2),D0	;directory starts here
	MOVE.W	VB_DirLen(A2),D1	;size in blocks
	IFZB	HFSFlag,3$
	MOVEQ	#2,D2			;max 3 HFS extents
	LEA	VB_CTXRec(A2),A3	;extent rec here
2$:	MOVE.W	(A3)+,D0		;block number of extent
	MOVE.W	(A3)+,D1		;length of extent
	BEQ.S	4$			;this extent is empty
	MULU	AllocBlkSizeW,D1	;mult by allocblock size
	ASR.L	D4,D1			;convert to number of 512-byte blocks
	ADD.W	BlockOffset,D0		;adjust for alloc block
3$:	BSR	ReadN			;read blocks of catalog tree
	ERROR	9$			;oops
	DBF	D2,2$			;loop for all of catalog tree
4$:	BRA.S	9$
8$:	STC
9$:	POP	D2-D4/A2-A3
	RTS

* Called from HFS AllocFreeNode when catalog tree runs out of nodes.
* Internally, the catbuf is fixed in size, and there is no logic to
* increase it dynamically.  So this can work only if the original
* catalog extent is smaller than the fixed catbuf.

AddCatExtent:
	PUSH	D2/A2
	LEA	VolBuf,A2
	MOVE.W	VB_CTXRec+2(A2),D0	;blocks in 1st extent
	ADD.W	VB_CTXRec+6(A2),D0	;blocks of 2nd extent
	ADD.W	VB_CTXRec+10(A2),D0	;blocks of 3rd extent
	MOVEQ	#MaxCatBlks,D2
	IFGEW	D0,D2,8$		;catbuf already full...no more
	SUB.W	D0,D2			;this many blocks left
	MOVE.W	D2,D0			;count of blocks for new extent
	BSR	AllocCatClump		;try to allocate a clump of D0 blks
	ERROR	8$			;no space left
	LEA	VB_CTXRec+4(A2),A0	;point to second extent
	IFZW	(A0),1$			;second extent is empty...use it
	ADDQ.L	#4,A0			;point to 3rd extent
	IFNZW	(A0),8$			;3rd extent is full too...
1$:	MOVE.W	D0,(A0)+		;extent starts here
	MOVE.W	D2,(A0)+		;size in blocks
	SUB.W	D2,VB_FreeAllocBlks(A2)	;these blocks are no longer free
	MULU	AllocBlkSizeW,D2	;size of additional extent
	ADD.L	D2,VB_CatSize(A2)	;new size of cat tree
	MOVE.L	CatBuf,A2
	ADD.L	D2,BN_MaxNodes(A2)	;increase max number of nodes
	ADD.L	D2,BN_FreeNodes(A2)	;and number free
	BRA.S	9$
8$:	STC
9$:	POP	D2/A2
	RTS

* Allocates extent buffer and reads ext tree into buffer.

ReadExtTree:
	PUSH	D2-D4/A2-A3
	IFNZL	ExtBuf,9$,L		;don't need to read it
	CLR.B	ExtDirtyFlg
	MOVEQ	#9,D4
	LEA	VolBuf,A2
	MOVE.W	VB_XTXRec+2(A2),D0	;blocks in 1st extent
	ADD.W	VB_XTXRec+6(A2),D0	;blocks of 2nd extent
	ADD.W	VB_XTXRec+10(A2),D0	;blocks of 3rd extent
	IFZW	D0,8$			;bad format...bail out
	MULU	AllocBlkSizeW,D0	;size of extent buffer
	MOVE.L	D0,ExtBufSize		;save size for later release
	ZAP	D1			;any kind of memory
	CALLSYS	AllocMem,SysBase
	MOVE.L	D0,ExtBuf		;got any?
	BEQ.S	8$			;no...bail out
	MOVE.L	D0,A0			;extent tree goes here	
	MOVEQ	#2,D2			;max 3 HFS extents
	LEA	VB_XTXRec(A2),A3	;extent rec here
5$:	MOVE.W	(A3)+,D0		;block number of extent
	MOVE.W	(A3)+,D1		;length of extent
	BEQ.S	9$			;this extent is empty
	MULU	AllocBlkSizeW,D1	;mult by allocblock size
	ASR.L	D4,D1			;convert to number of 512-byte blocks
	ADD.W	BlockOffset,D0		;adjust for alloc block
	BSR	ReadN			;read blocks of extent tree
	ERROR	9$			;oops
	DBF	D2,5$			;loop for all of extents tree
	BRA.S	9$
8$:	STC
9$:	POP	D2-D4/A2-A3
	RTS

WriteDirectory:
	PUSH	A2
	LEA	VolBuf,A2
	IFNZB	HFSFlag,1$
	MOVE.W	VB_FirstDirBlk(A2),D0	;directory starts here
	MOVE.W	VB_DirLen(A2),D1	;size in blocks
	MOVE.L	CatBuf,A0		;write from here
	BSR	WriteN			;write out these blocks
	BRA	9$

1$:	LEA	VB_CTXRec(A2),A1	;write out ext tree
	MOVE.L	CatBuf,A0
	BSR.S	WriteDirExtents
	ERROR	9$
	IFZB	ExtDirtyFlg,9$		;dont write extent tree unless needed
	LEA	VB_XTXRec(A2),A1
	MOVE.L	ExtBuf,A0
	BSR.S	WriteDirExtents
	CLR.B	ExtDirtyFlg
9$:	CLR.B	DirDirtyFlg
	POP	A2
	RTS

* A1 points to extent descriptors for catalog tree or extent tree.
* A0 contains base of buffer holding tree.

WriteDirExtents:
	PUSH	D2/A2
	MOVE.L	A1,A2
	MOVEQ	#2,D2			;max 3 extents
1$:	MOVE.W	(A2)+,D0		;block for write
	MOVE.W	(A2)+,D1		;number of blocks in extent
	BEQ.S	9$			;no blocks in extent?
	ADD.W	BlockOffset,D0
	MULU	AllocBlkSizeW,D1	;mult by allocblock size ;GEC 1/20/90
	ASR.L	#8,D1			;conv to 512-byte blocks ;GEC 1/20/90
	ASR.L	#1,D1						 ;GEC 1/20/90
	BSR	WriteN
	ERROR	9$
	DBF	D2,1$			;loop for all 3 extents
9$:	POP	D2/A2
	RTS

NodeLnk	MACRO	;src,An
	MOVE.L	\1,D0
	LSL.L	D7,D0
	ADD.L	A4,D0
	MOVE.L	D0,\2
	ENDM

* Builds standard Mac root dir from data in catalog buffer.
* Register usage:
*	D0=
*	D1=
*	D2= DR_DirID of dir being built
*	D3= node length
*	D4= leaf record type
*	D5= number of leaf nodes
*	D6= record counter in node
*	D7= 9 ... shift count
*	A0= key ptr
*	A1= record ptr
*	A2= dir level record
*	A3= current fib ptr
*	A4= CatBuf
*	A5= current node ptr

BuildRootDir:
	PUSH	D2-D7/A2-A5
	CLR.W	MacTotFiles		;start with no files
	MOVE.L	#BaseDirBlock,CurDBBase
	BSR	AllocateMacDirBlock	;allocate first dir block
	ERROR	BuildErr		;oops
	LEA	MacRootLevel,A2
	MOVE.L	A2,MacCurLevel		;start at root level
	MOVE.L	A2,A1
	BSR	ZapLevelBlk		;start with empty root level
	IFZB	HFSFlag,BuildFlatDir,L	;build dir from flat directory
	MOVE.L	CatBuf,A0
	BSR	InitSearch		;initialize leaf scan
	ERROR	BuildErr		;no more records??
	IFNEIB	DR_Type(A1),#1,BuildErr,L	;should be directory
	MOVE.L	#2,D2			;items in root dir have id of 2
	MOVE.L	D2,dl_DirID(A2)

* Now position to thread record for the dir level we want to process,
* then call ScanDir to process records at that level.

ScanLevel:
	MOVE.L	MacCurLevel,A2
	NodeLnk	BN_FLink(A4),A5		;point to first leaf node
	MOVE.L	BN_LeafRecs(A4),D5	;active leaf recs
	BSR	GetFirstLeafRec		;get root dir record
	BRA.S	2$
1$:	BSR	GetNextLeafRec		;scan leaves for thread record
2$:	ERROR	BuildErr,L		;end of list...something wrong
	IFNEIB	TR_Type(A1),#3,1$	;not a thread record
	IFNEL	CK_ParID(A0),D2,1$	;not thread record for desired dir
	BSR	ScanDir			;scan the files at this level
	ERROR	BuildErr
	MOVE.L	MacCurLevel,A2
	LEA	dl_ChildPtr(A2),A3
	MOVE.L	A3,dl_ScanPtr(A2)	;start from the beginning of this level

NextEntry:
	MOVE.L	dl_ScanPtr(A2),A3	;work the list
	MOVE.L	df_Next(A3),A3		;advance to next entry in list
	MOVE.L	A3,dl_ScanPtr(A2)	;save ptr to dir entry
	IFZL	A3,PrevLevel,L		;end of list...back up a level
	BTST	#7,df_Flags(A3)		;dir?
	BEQ	PrevLevel		;no...a file...stop scan at this level
	MOVE.L	A3,dl_ScanPtr(A2)	;save ptr to dir entry
	MOVE.L	df_DirID(A3),D2		;get DirID for items at this level
;	MOVE.L	df_BlockPtr(A3),A0	;ptr to directory block
;	MOVE.L	DR_DirID(A0),D2		;directory ID
	IFGEIL	CurDBCnt,#dl_SIZEOF,1$	;still room in buffer
	BSR	AllocateMacDirBlock	;else add another buffer
	ERROR	BuildErr
1$:	MOVE.L	CurDBPtr,A1		;level goes here
	MOVEQ	#dl_SIZEOF,D0		;account for size of level block
	ADD.L	D0,CurDBPtr
	SUB.L	D0,CurDBCnt
	BSR	ZapLevelBlk
;	MOVE.L	D2,dl_DirID(A2)		;store dir id for this new level
	MOVE.L	dl_ScanPtr(A2),A0	;set ptr to sublevel
	MOVE.L	A1,df_SubLevel(A0)	;point to subdir level block
	MOVE.L	MacCurLevel,dl_ParLevel(A1) ;linkage to parent level
	MOVE.L	A1,MacCurLevel		;this is the new current level
	MOVE.L	A1,A2			;ptr to new current level
	MOVE.L	D2,dl_DirID(A2)		;store dir id for this new level
	LEA	dl_ChildPtr(A2),A3
	MOVE.L	A3,dl_ScanPtr(A2)
	BRA	ScanLevel		;process this level

PrevLevel:
	MOVE.L	dl_ParLevel(A2),A2	;back up one level
	IFZL	A2,9$			;completed root...stop now
	MOVE.L	A2,MacCurLevel
	BRA	NextEntry

9$:	POP	D2-D7/A2-A5
	RTS

* Process records up to next thread record or end of leaves.

ScanDir:
	MOVE.L	MacCurLevel,A2
	BSR	GetNextLeafRec		;no more records
	NOERROR	5$
	CLC				;end of leaf nodes...no more recs
	RTS
5$:	MOVE.B	FR_Type(A1),D4		;get record type
	BEQ	8$			;illegal record number...bad format?
	IFGTIB	D4,#3,8$,L		;legal values are 1, 2, or 3
	IFNEIB	D4,#3,1$		;not a thread record
	RTS				;stop on a thread record
1$:	IFNEIB	D4,#2,7$		;not a file
	BTST	#6,FR_FinderFlags(A1)	;invisible file?
	BNE.S	ScanDir			;yes...ignore it
7$:	IFGEIL	CurDBCnt,#df_SIZEOF,2$	;have enuf room for this entry
	BSR	AllocateMacDirBlock	;else get another (preserve all regs)
	RTSERR
2$:	MOVE.L	CurDBPtr,A3
	MOVE.L	A3,dl_ScanPtr(A2)	;this fib is now current
	CLR.L	(A3)+			;no FWD linkage yet
	DECB	D4			;dir record?
	BNE.S	3$			;no, must be file
	BSR	ProcessDirRec
	BRA.S	4$
3$:	BSR	ProcessFileRec
4$:	MOVE.L	A3,D0
	INCL	D0
	ANDI.L	#$FFFFFFFE,D0
	MOVE.L	D0,D1
	SUB.L	CurDBPtr,D1		;calc size of this fib
	MOVE.L	D0,CurDBPtr		;align ptr properly
	SUB.L	D1,CurDBCnt		;add to size of block
	IFNZL	dl_ChildPtr(A2),6$	;child already set
	MOVE.L	dl_ScanPtr(A2),D0
	MOVE.L	D0,dl_ChildPtr(A2)	;else do it now
	MOVE.L	D0,dl_CurFib(A2)
	BRA	ScanDir
6$:	BSR	SortInsert
	BRA	ScanDir

8$:	STC
	RTS

* Watch out...working regs already saved before we get here!

BuildFlatDir:
	LEA	VolBuf,A2		;volume buffer
	MOVE.W	VB_NbrFiles(A2),D6	;flat dir file count
	BEQ	9$			;no files
	DECW	D6			;for dbf
	MOVE.L	MacCurLevel,A2		;point to root block
	MOVE.L	CatBuf,A1		;directory info in this buffer
	MOVE.L	A1,D0
	ADD.L	CatBufSize,D0
	MOVE.L	D0,CatBufEnd

1$:	CMP.L	CatBufEnd,A1		;end of DirBuf?
	BCC	9$			;yes...bail out
	TST.B	(A1)			;active entry?
	BMI.S	2$			;yes
	ADDQ.L	#2,A1			;crossing block boundary?
	BRA.S	1$
	
2$:	BTST	#6,FF_FinderFlags(A1)	;invisible file?
	BEQ.S	24$			;no
	MOVE.L	A1,A0			;else skip to next entry
	BSR	SkipDirEntry
	MOVE.L	A0,A1
	BRA	17$
24$:	IFGEIL	CurDBCnt,#dl_SIZEOF,23$	;still room in buffer
	BSR	AllocateMacDirBlock	;else add another
	ERROR	9$,L
23$:	MOVE.L	CurDBPtr,A3
	MOVE.L	A3,dl_ScanPtr(A2)
	CLR.L	(A3)+			;no FWD linkage yet
	MOVE.L	FF_DataLEOF(A1),D0	;assume data file
	IFNEIL	FF_FinderType(A1),#'APPL',6$ ;not an application
	MOVE.L	FF_ResLEOF(A1),D0	;else get resource size
6$:	MOVE.L	D0,(A3)+		;store size
	MOVE.L	FF_MDate(A1),(A3)+	;mod date
	MOVE.L	FF_FileNbr(A1),(A3)+	;file number (needed only by HFS)
	ZAP	D0
	MOVE.W	D0,(A3)+		;leave room for file count
	MOVE.B	FF_Flags(A1),D0
	AND.B	#1,D0			;prot bit is bit 0
	MOVE.B	D0,(A3)+		;all other flags=0
	LEA	FF_NameLen(A1),A0	;point to name string
	MOVE.B	(A0)+,D0
	MOVE.B	D0,(A3)+		;length of name
	BEQ.S	5$			;null name?
	IFLEIB	D0,#MaxFileName,3$	;name OKAY
	MOVEQ	#MaxFileName,D0
3$:	DECW	D0
4$:	MOVE.B	(A0)+,(A3)+		;move a byte of name
	DBF	D0,4$
5$:	CLR.B	(A3)+			;follow with a null
	MOVE.L	A3,D0
	INCL	D0
	BCLR	#0,D0
	MOVE.L	D0,D1
	SUB.L	CurDBPtr,D1		;calc size of this fib
	MOVE.L	D0,CurDBPtr		;align ptr properly
	SUB.L	D1,CurDBCnt		;add to size of block
	MOVE.L	A0,D2			;save D2
	IFNZL	dl_ChildPtr(A2),16$	;child already set
;	MOVE.L	dl_ScanPtr(A2),D0
;	MOVE.L	D0,dl_ChildPtr(A2)	;else do it now
;	MOVE.L	D0,dl_CurFib(A2)
	MOVE.L	dl_ScanPtr(A2),dl_ChildPtr(A2) ;else do it now
	BRA.S	8$
16$:	BSR	SortInsert
8$:	INCL	D2			;round up
	BCLR	#0,D2			;make sure we are on word boundary
	MOVE.L	D2,A1
17$:	DBF	D6,1$			;loop for all files in dir
9$:	POP	D2-D7/A2-A5
	RTS

ProcessFileRec:
	MOVE.L	FR_DataLEOF(A1),D0	;assume data file
	IFNEIL	FR_FinderType(A1),#'APPL',4$ ;ok
	MOVE.L	FR_ResLEOF(A1),D0	;else use resource fork
4$:	MOVE.L	D0,(A3)+		;file size
	MOVE.L	FR_MDate(A1),(A3)+	;mod date
	MOVE.L	FR_FileNbr(A1),(A3)+	;file number
	ZAP	D0
	MOVE.W	D0,(A3)+		;leave room for file count/conv type
	MOVE.B	FR_Flags(A1),D0		;get file flags
	AND.B	#1,D0			;bit 0 is protection bit
	MOVE.B	D0,(A3)+		;all other flags=0
	LEA	CK_NameLen(A0),A0	;point to name string
	MOVE.B	(A0)+,D0
	MOVE.B	D0,(A3)+		;length of name
	BEQ.S	2$			;null name?
	IFLEIB	D0,#MaxFileName,3$	;name OKAY
	MOVEQ	#MaxFileName,D0
3$:	DECW	D0
1$:	MOVE.B	(A0)+,(A3)+		;move a byte of name
	DBF	D0,1$
	CLR.B	(A3)+			;follow with a null
2$:	INCW	MacTotFiles		;count this file
	RTS

* Process a directory record.

ProcessDirRec:
	CLR.L	(A3)+			;no size/sublevel
	MOVE.L	DR_MDate(A1),(A3)+	;mod date
	MOVE.L	DR_DirID(A1),(A3)+	;Dir id for all items at this level
	ZAP	D0
	MOVE.W	D0,(A3)+		;leave room for file count
	MOVE.B	#$80,(A3)+		;mark as directory
	LEA	CK_NameLen(A0),A0	;point to name string
	MOVE.B	(A0)+,D0
	MOVE.B	D0,(A3)+		;length of name
	BEQ.S	2$			;null name?
	IFLEIB	D0,#MaxVolName,3$	;name too long...
	MOVEQ	#MaxVolName,D0
3$:	DECW	D0
1$:	MOVE.B	(A0)+,(A3)+		;move a byte of name
	DBF	D0,1$
	CLR.B	(A3)+			;follow with a null
2$:	RTS

BuildErr:
	DispErr	MacFmtErr.
	POP	D2-D7/A2-A5
	STC
	RTS

* Allocates memory for directory blocks.

AllocateMacDirBlock:
	PUSH	D0-D1/A0-A1/A6
	MOVE.L	#DirBlockSize,D0
	ZAP	D1			;any kind of memory
	CALLSYS	AllocMem,SysBase
	MOVE.L	CurDBBase,A0		;ptr to base of current dir block
	MOVE.L	D0,(A0)			;set up link to new dir block
	BEQ.S	8$			;oops...no memory...bad awful
	INCB	DirBlkCnt		;one more
	MOVE.L	D0,A0
	MOVE.L	A0,CurDBBase
	CLR.L	(A0)+			;no fwd link yet...
	MOVE.L	A0,CurDBPtr		;load dir block here
	MOVE.L	#DirBlockSize-4,CurDBCnt
	BRA.S	9$
8$:;	DispErr	NoMemory
	STC
9$:	POP	D0-D1/A0-A1/A6
	RTS

FreeMacDirBlocks:
	MOVE.L	BaseDirBlock,A2		;free the chain of dir blocks
1$:	IFZL	A2,2$			;nothing left in chain
	MOVE.L	A2,A1
	MOVE.L	(A2),A2			;pick up fwd link BEFORE releasing...
	MOVE.L	#DirBlockSize,D0
	CALLSYS	FreeMem,SysBase
	DECB	DirBlkCnt
	BRA.S	1$
2$:	MOVE.L	A2,BaseDirBlock		;show chain released
;	IFZB	DirBlkCnt,9$
;	DispErr	DirBlk.			;dir blocks not all released
9$:	RTS

* Release previously allocated buffers, if any.

FreeBuffers:
	MOVE.L	SysBase,A6
	MOVE.L	CatBuf,A1
	IFZL	A1,2$
	MOVE.L	CatBufSize,D0
	CALLSYS	FreeMem
	CLR.L	CatBuf
2$:	MOVE.L	ExtBuf,A1
	IFZL	A1,3$
	MOVE.L	ExtBufSize,D0
	CALLSYS	FreeMem
	CLR.L	ExtBuf
3$:	MOVE.L	MacBuffer,A1
	IFZL	A1,5$
	MOVE.L	AllocBlkSizeL,D0
	CALLSYS	FreeMem
	CLR.L	MacBuffer
5$:	RTS

* Opens data fork of Mac file pointed to by CurFib.

OpenMacFile:
	PUSH	A2
	CLR.B	MacWrtFlg		;read op
	CLR.B	ForkType		;always start with data fork
	CLR.W	MacBlkCnt		;start with no blocks
	CLR.B	EofFlag
	BSR	FindFileRec		;search for current file rec
	ERROR	8$
	MOVE.L	A0,A2
	IFNZB	HFSFlag,2$		;HFS file
	MOVE.L	FF_FileNbr(A2),MacFileNbr
	MOVE.W	FF_DataBlk(A2),MacBlock
	MOVE.L	FF_DataLEOF(A2),MacFileSize
	BRA.S	9$
2$:	MOVE.L	FR_FileNbr(A2),MacFileNbr
	LEA	FR_DExtRec(A2),A0
	MOVE.L	A0,ExtRecPtr
	MOVE.L	FR_DataLEOF(A2),MacFileSize
	MOVE.B	#3,ExtRecCnt		;count of remaining extent records
	CLR.W	ExtBlkCnt		;start with no blocks in extent
	CLR.W	MacBlock		;start with no block
	BRA.S	9$
8$:	MOVE.L	CurFib,A0
	LEA	df_Name(A0),A0
	FileErr	A0,CantOpenMac.
	STC
9$:	POP	A2
	RTS

* Called to open resource fork of file which has already been opened 
* normally (data fork).

OpenResFork:
	PUSH	A2
	MOVE.L	MacHandle,A2		;point to file block
	SETF	ForkType		;mark as resource fork
	CLR.W	MacBlkCnt		;start with no blocks
	CLR.B	EofFlag
	IFNZB	HFSFlag,1$
	MOVE.W	FF_ResBlk(A2),MacBlock
	MOVE.L	FF_ResLEOF(A2),MacFileSize
	BRA.S	9$
1$:	LEA	FR_RExtRec(A2),A0
	MOVE.L	A0,ExtRecPtr
	MOVE.L	FR_ResLEOF(A2),MacFileSize
	MOVE.B	#3,ExtRecCnt		;count of remaining extent records
	CLR.W	ExtBlkCnt		;start with no blocks in extent
	CLR.W	MacBlock		;start with no block
9$:	POP	A2
	RTS

* Creates a new Mac file for write based on name in CurFib.
* D0=0 (data fork) or $ff (resource fork)

CreateMacFile:
	PUSH	D2/A2
	CLR.B	ForkType		;start with data fork
	SETF	MacWrtFlg		;write operation
	CLR.L	MacFileSize
	CLR.L	MacCurFib
	CLR.L	MacHandle		;no dir entry...yet
	MOVE.L	CurFib,A2		;point to active FIB
	MOVE.W	df_Date(A2),D0		;get Dos date
	MOVE.W	df_Time(A2),D1		;get Dos time
	BSR	ConvDosDate		;convert to Mac format in D0
	MOVE.L	D0,FileDate		;save for later
	MOVE.	df_Name(A2),FileName.	;this is name for new Mac file
	BSR	FixFileName		;make sure name is valid on Mac
	MOVE.L	MacCurLevel,A2		;check Mac list for matching file name
	LEA	dl_ChildPtr(A2),A2	;point to start of list
1$:	MOVE.L	df_Next(A2),D0		;point to next entry
	BEQ.S	2$			;no more...not in this list
	MOVE.L	D0,A2
	IFNE.	df_Name(A2),FileName.,1$ ;file exists?
	MOVE.L	A2,MacCurFib		;save for later update
	IFNZB	AutoRepFlg,5$		;just replace it, don't even ask
	DispYN	DupTxt			;ask op what to do
	ERROR	9$			;op says skip this one
5$:	BSR	DeleteMacFile		;else get rid of this one
	ERROR	8$			;cant delete...bail out
	MOVE.L	FileDate,df_Date(A2)	;update date/time stamp in Mac entry
	BRA	3$
2$:	IFGEIL	CurDBCnt,#df_SIZEOF,4$	;have enuf room for this entry
	BSR	AllocateMacDirBlock	;else get another block
	ERROR	3$,L			;oops...can't get any, just go on
4$:	MOVE.L	CurDBPtr,A1		;point to new block
	MOVE.L	CurFib,A0
	MOVE.L	MacCurLevel,A2
	MOVE.L	A1,dl_ScanPtr(A2)	;this fib is now current
	MOVE.L	A1,MacCurFib
	CLR.L	(A1)+			;no linkage (yet)
	CLR.L	(A1)+			;no file size (yet)
	MOVE.L	FileDate,(A1)+		;seconds since Jan 1, 1904
	ZAP	D0
	MOVE.L	D0,(A1)+		;file number ************
	MOVE.W	D0,(A1)+		;leave room for df_FilCnt, convtype
	MOVE.B	D0,(A1)+		;store flags
	LEA	df_Name(A0),A0
	MOVEQ	#FileNameLen-1,D0	;limit for file names
	BSR	LimitMove
	MOVE.L	A1,D0
	INCL	D0
	ANDI.L	#$FFFFFFFE,D0
	MOVE.L	D0,D1
	SUB.L	CurDBPtr,D1		;get size of this fib
	MOVE.L	D0,CurDBPtr		;allign ptr properly
	SUB.L	D1,CurDBCnt		;add to size of block
	IFNZL	dl_ChildPtr(A2),6$	;child already set
	MOVE.L	dl_ScanPtr(A2),D0
	MOVE.L	D0,dl_ChildPtr(A2)	;else set it now
	MOVE.L	D0,dl_CurFib(A2)
	BRA.S	3$			;no sort needed...1st entry at level
6$:	BSR	SortInsert		;else insert into list

3$:	BSR	NewMacFile
	NOERROR	9$
8$:	FileErr	#FileName.,CantCreateMac.
	SETF	AbortFlg
	STC
9$:	POP	D2/A2
	RTS

* Creates new Mac file data fork directory entry.

NewMacFile:
	CLR.L	MacFileSize		;start with 0-length file
	CLR.W	MacBlock		;start with no block allocated
	CLR.W	MacBlkCnt		;count of allocated blocks
	IFNZB	HFSFlag,5$		;allocate HFS dir
	BSR	GetFreeFlatDir		;find a free directory entry
	RTSERR				;dir full
	MOVE.L	A0,MacHandle		;point to active dir entry
	BSR	BuildFlatDirEntry	;build an entry in dir and update vol
	BRA	7$

5$:	LEA	VolBuf,A0
	MOVE.L	VB_NextID(A0),D0	;next file id to use
	MOVE.L	D0,MacFileNbr
	MOVE.L	MacCurLevel,A0
	MOVE.L	dl_DirID(A0),D1		;parent ID
	LEA	FileName.,A0		;pointer to name to use
	BSR	AllocateFileRec		;build file record
	BSR	InsertCatRec		;insert into catalog and rebuild index
	ERROR	9$			;oops...no go
;	MOVE.L	MacCurFib,A1
	MOVE.L	A0,MacHandle		;ptr to file rec 
	LEA	FR_DExtRec(A0),A0
	MOVE.L	A0,ExtRecPtr		;point to empty extent descriptors
	MOVE.B	#3,ExtRecCnt		;3 empty extent descriptors
	MOVE.L	MacCurLevel,A0
	MOVE.L	dl_DirID(A0),D0		;parent ID
	MOVEQ	#1,D1			;add 1
	ADD.L	D1,VolBuf+VB_FilCnt	;to total file count
	BSR	UpdateValence		;and dir count
	LEA	VolBuf,A0
	IFNEIL	MacCurLevel,#MacRootLevel,8$ ;don't update count in volbuf
7$:	LEA	VolBuf,A0		;got it into catalog
	INCW	VB_NbrFiles(A0)		;and count the file
8$:	INCL	VB_NextID(A0)		;increment file id
9$:	RTS

* Called when writing MacBinary file to close data fork and open resource
* fork.  MacHandle already set to file block.

NewResFork:
	BSR.S	CloseMacFile		;close data fork
	SETF	ForkType		;switch to resource fork
	MOVE.L	MacHandle,A0		;file block already exists
	CLR.L	MacFileSize		;start with 0-length resource fork
	CLR.W	MacBlock		;start with no block allocated
	CLR.W	MacBlkCnt		;count of allocated blocks
	IFZB	HFSFlag,9$		;thats all we do for flat file
	LEA	FR_RExtRec(A0),A0
	MOVE.L	A0,ExtRecPtr		;point to empty extent descriptors
	MOVE.B	#3,ExtRecCnt		;3 empty extent descriptors
9$:	RTS

* Closes open Mac file and updates file block, if write.

CloseMacFile:
	CLR.L	MacBytCnt		;nothing in buffer
	IFZB	MacWrtFlg,9$		;was read operation
	MOVE.L	MacFileSize,D1		;actual file byte count
	MOVE.W	MacBlkCnt,D0
	MULU	AllocBlkSizeW,D0	;calculate physical size
;	EXT.L	D0
;	LSL.L	#8,D0
;	LSL.L	#1,D0			;physical size
	MOVE.L	MacHandle,A0
	IFNZB	HFSFlag,2$
	LEA	FF_DataBlk(A0),A1
	IFZB	ForkType,1$
	LEA	FF_ResBlk(A0),A1
1$:	MOVE.W	FirstFileBlock,(A1)+
;	MOVE.L	D1,(A1)+
;	MOVE.L	D0,(A1)+
	BRA.S	3$

2$:	LEA	FR_DataLEOF(A0),A1
	IFZB	ForkType,3$
	LEA	FR_ResLEOF(A0),A1
3$:	MOVE.L	D1,(A1)+		;actual file byte count
	MOVE.L	D0,(A1)+		;store allocated file length
	MOVE.L	MacCurFib,A0
	MOVE.L	MacFileSize,df_Size(A0)	;update size in fib
	SETF	DirDirtyFlg
;	BSR	FlushMacDirectory
9$:	BSR	MotorOff		;turn off the motor
	RTS

* Deletes Mac file defined by CurFib.

DeleteMacFile:
	BSR	CheckWrtProt		;disk write protected?
	ERROR	9$
	BSR	FindFileRec
	ERROR	2$
	MOVE.L	CurFib,A0
	BTST	#0,df_Flags(A0)		;file protected?
	BEQ.S	3$			;no
	MOVE.L	CurFib,A0
	LEA	df_Name(A0),A0
	FileErr	A0,CantDelFile.
2$:	STC
	BRA.S	9$
3$:	SETF	DirDirtyFlg
	IFNZB	HFSFlag,1$
	BSR	ReleaseAllocBlocks	;mark blocks free
	BSR	ReleaseFlatDir		;free up dir entry
	BRA.S	7$
1$:	LEA	df_Name(A0),A0
	MOVE.L	MacCurLevel,A1
	MOVE.L	dl_DirID(A1),D0		;parent ID
	BSR	DeleteHFSFile
	ERROR	9$
	MOVE.L	MacCurLevel,A0
	MOVE.L	dl_DirID(A0),D0		;parent ID
	MOVEQ	#-1,D1			;subtract 1
	ADD.L	D1,VolBuf+VB_FilCnt	;from total file count
	BSR	UpdateValence		;and from dir count
	IFNEIL	MacCurLevel,#MacRootLevel,9$ ;don't update count in volbuf
7$:	LEA	VolBuf,A0
	DECW	VB_NbrFiles(A0)		;one less file
	CLC
9$:	RTS

* Called from DiskCmds when op changes file name, protection, file type
* or creator.  New file name in FINamBuf, prot bit in df_Flags of CurFib.

UpdateMacName:
	PUSH	A2
	MOVE.	FINamBuf,FileName.	;this is new name for Mac file
	BSR	FixFileName		;make sure name is valid on Mac
	IFZB	FileName.,9$,L		;nothing left in name
	IFNZB	HFSFlag,4$
	BSR	UpdateFlatName
	BRA.S	3$
4$:	BSR	UpdateHFSName
3$:	SETF	DirDirtyFlg
	BSR	FlushMacDirectory
	IFGEIL	CurDBCnt,#df_SIZEOF,1$	;have enuf room for this entry
	BSR	AllocateMacDirBlock	;else get another block
	ERROR	8$			;oops...can't get any, just go on
1$:	MOVE.L	CurDBPtr,A1		;point to new block
	MOVE.L	MacCurLevel,A0
	MOVE.L	A1,dl_ScanPtr(A0)	;this fib is now current
	MOVE.L	A1,MacCurFib
	CLR.L	(A1)+			;no fwd linkage yet
	MOVE.L	CurFib,A0
	ADDQ.L	#4,A0
	MOVEQ	#df_Flags-4,D0
2$:	MOVE.B	(A0)+,(A1)+		;copy CurFib up to flags
	DBF	D0,2$
	LEA	FileName.,A0
	MOVEQ	#FileNameLen-1,D0	;limit for file names
	BSR	LimitMove
	MOVE.L	A1,D0
	INCL	D0
	ANDI.L	#$FFFFFFFE,D0
	MOVE.L	D0,D1
	SUB.L	CurDBPtr,D1		;get size of this fib
	MOVE.L	D0,CurDBPtr		;allign ptr properly
	SUB.L	D1,CurDBCnt		;add to size of block
	MOVE.L	MacCurLevel,A2
	BSR	SortInsert		;insert into list
8$:	BSR	DeleteCurFib
9$:	POP	A2
	RTS

* Creates new flat dir entry, copies old to new, then deletes old.
* Note: flat dir entries ARE NOT maintained in sorted order.  This
* is only necessary because the length of the new name may differ
* from the old.

UpdateFlatName:
	PUSH	D2/A2-A3
	MOVE.L	MacHandle,A2		;point to old flat dir entry
	MOVE.B	FF_Flags(A2),D0
	AND.B	#$FE,D0
	MOVE.L	CurFib,A1
	MOVE.B	df_Flags(A1),D1
	AND.B	#1,D1
	OR.B	D1,D0
	MOVE.B	D0,FF_Flags(A2)		;update protection
	MOVE.L	FITypeBuf,FF_FinderType(A2)
	MOVE.L	FICreatorBuf,FF_FinderCreator(A2)
	BSR	GetFreeFlatDir		;find a new dir entry
	ERROR	9$			;didn't work
	MOVE.L	A0,A3			;save ptr to new entry
	MOVE.L	A2,A1			;old dir ptr
	MOVEQ	#FF_NameLen-1,D2
1$:	MOVE.B	(A1)+,(A0)+
	DBF	D2,1$
	BSR	StoreFileName		;add new name to dir entry
	BSR	ReleaseFlatDir		;free the old entry
	MOVE.L	A2,MacHandle		;this is now current entry
9$:	POP	D2/A2-A3
	RTS

* Returns pointer to current file record in A0.  Also sets
* MacHandle to the current file record.

FindFileRec:
	IFNZB	HFSFlag,5$
	BSR	FindFlatFile
	BRA.S	6$
5$:	MOVE.L	CurFib,A0
	LEA	df_Name(A0),A0
	MOVE.L	MacCurLevel,A1
	MOVE.L	dl_DirID(A1),D0		;current dir id
	BSR	FindHFSFile		;search for it
6$:	ERROR	9$
	MOVE.L	A0,MacHandle
9$:	RTS


* Searches flat directory looking for name match.  
* Called with ptr to name string in A0.  Returns A0=file
* entry in directory or CY=1.

FindFlatFile:
	PUSH	D2-D3/A2-A3
	MOVE.L	CatBuf,A0
	LEA	VolBuf,A1		;volume buffer
	MOVE.W	VB_NbrFiles(A1),D2	;flat dir file count
	BEQ	9$			;no files...use first entry
	DECW	D2			;for dbf
	MOVE.L	#512,D3
	MOVE.L	A0,A3
	MOVE.L	A0,D0
	ADD.L	CatBufSize,D0
	MOVE.L	D0,CatBufEnd

1$:	IFLTL	A0,A3,2$		;not end of block yet...
	ADD.L	D3,A3			;bump to next block
2$:	IFLEL	CatBufEnd,A0,8$		;end of buffer...search failed
	TST.B	(A0)			;active entry?
	BMI.S	3$			;yes...check it out
	MOVE.L	A3,A0			;else skip to end of block
	BRA.S	1$

3$:	MOVE.L	A0,A2
	STG_Z.	FF_NameLen(A0),TMP.
	MOVE.L	CurFib,A0
	IFEQ.	df_Name(A0),TMP.,9$
	MOVE.L	A2,A0
	BSR	SkipDirEntry		;advance to next entry
	DBF	D2,1$			;try it
8$:	STC
9$:	MOVE.L	A2,A0
	POP	D2-D3/A2-A3
	RTS

* Write out updated volume and directory buffers.

FlushMacDirectory:
	IFZB	DirDirtyFlg,1$		;no write necessary
	BSR	WriteDirectory		;write out updated dir info
	BSR	WriteVolBlock		;write out updated vol info
	BSR	FlushTrack
	BSR	MotorOff
	CLR.B	DirDirtyFlg
1$:	RTS

* Called to release alloc blocks allocated to flat file.

ReleaseAllocBlocks:
	PUSH	A2
	MOVE.L	MacHandle,A2		;point to dir entry for file
	MOVE.W	FF_DataBlk(A2),D0	;get first block of data fork
	BSR.S	FreeFlatChain
	MOVE.W	FF_ResBlk(A2),D0
	BSR.S	FreeFlatChain
	POP	A2
	RTS
	
FreeFlatChain:
	PUSH	D3/A2
	LEA	VolBuf,A2
1$:	IFLEIW	D0,#1,2$		;end of file or bad linkage
	MOVE.W	D0,D3			;save current alloc block
	BSR	GetVolAllocBlock	;get fwd link, if any
	EXG	D0,D3			;old to D0, new to D3
	ZAP	D1
	BSR	PutVolAllocBlock	;mark alloc blk as free
	INCW	VB_FreeAllocBlks(A2)	;one more alloc block avail
	MOVE.W	D3,D0			;now work next entry
	BRA.S	1$
2$:	POP	D3/A2
	RTS

* Erases current flat dir entry and moves up any following dir entries.
* Note: does not move entries in following blocks, if any.

ReleaseFlatDir:
	PUSH	D2-D3/A2-A3
	ZAP	D2			;length accumulator
	MOVE.L	MacHandle,A2		;dir entry to be deleted
	MOVE.L	A2,A0
	BSR	GetDirLength		;find next dir entry, if any
	MOVE.L	D0,D3			;save length for clearing
	TST.B	(A1)			;next entry active?
	BPL.S	1$			;no...just clear this entry
	MOVE.L	A1,A3			;source for move
3$:	MOVE.L	A1,A0			;point to next active
	BSR	GetDirLength		;find its length
	ADD.L	D0,D2			;count its length
	TST.B	(A1)			;is next one active?
	BMI.S	3$			;yes...loop
	DECW	D2			;no...found end
4$:	MOVE.B	(A3)+,(A2)+		;move the dirs up
	DBF	D2,4$
	MOVE.L	A2,A0			;now clear trailing area
1$:	DECW	D3
2$:	CLR.B	(A0)+
	DBF	D3,2$
	POP	D2-D3/A2-A3
	RTS

* Given ptr to dir entry in A0, returns length in D0 and ptr to next dir
* entry in A1.  A0 is undisturbed.

GetDirLength:
	LEA	FF_NameLen(A0),A1	;point to length of name
	ZAP	D0
	MOVE.B	(A1)+,D0
	ADD.L	A1,D0
	INCL	D0			;round up
	BCLR	#0,D0			;points to next entry
	MOVE.L	D0,A1			;ptr to next entry in A1
	SUB.L	A0,D0			;calc entry length
	RTS	

* Reads next (first) file allocation block into MacBuffer.
* Returns actual byte count in D0, or CY=1 on error.

ReadMacBlock:
;;	INCW	MacBlkCnt		;do it here for extent calc ;gec 1/22/90
	CLR.L	MacBytCnt		;make sure nothing in buffer
	IFNZL	MacFileSize,1$
	SETF	EofFlag			;that's all folks
	BRA	9$
1$:	IFNZB	HFSFlag,2$		;HFS file... extent records
	ZAP	D0
	MOVE.W	MacBlock,D0		;read this block
	BRA.S	5$

2$:	IFNZW	ExtBlkCnt,4$		;got another block to go
	IFNZB	ExtRecCnt,3$		;there is another extent 
	BSR	FindNextExtent		;set ExtRecPtr to next extent
	NOERROR	3$
	DispErr	Int3.			;cant find extent
	STC
	BRA	9$
3$:	MOVE.L	ExtRecPtr,A0		;this is current extent
	MOVE.W	(A0)+,MacBlock		;next extent stats here
	MOVE.W	(A0)+,ExtBlkCnt		;for this many blocks
	MOVE.L	A0,ExtRecPtr		;save ptr for next extent
	DECB	ExtRecCnt		;one less extent record
4$:	MOVE.W	MacBlock,D0
;	INCW	MacBlkCnt		;one more block in file
	INCW	MacBlkCnt		;do it here for extent calc ;gec 1/22/90	INCW	MacBlock		;point to next one
	INCW	MacBlock		;point to the next one
	DECW	ExtBlkCnt		;one less block to go in this extent

5$:	BSR	ConvAllocPhys		;convert alloc blk to physical
	MOVE.W	BlksPerAllocBlk,D1
	MOVE.L	MacBuffer,A0		;read into here
	BSR	ReadN
	ERROR	9$			;cant read block
	MOVE.L	AllocBlkSizeL,D0	;bytes in buffer
	MOVE.L	MacFileSize,D1
	IFGEL	D1,D0,6$		;is block full?
	MOVE.L	D1,D0			;no, use what is remaining
6$:	MOVE.L	D0,MacBytCnt		;this many bytes for this call
	SUB.L	D0,MacFileSize		;this many left for next time
	IFNZB	HFSFlag,7$		;not flat
	MOVE.W	MacBlock,D0
	BSR	GetVolAllocBlock	;get ptr to next block of file
	MOVE.W	D0,MacBlock		;save ptr to next block
7$:	CLC
9$:	RTS

* Converts allocation block number in D0 to physical block number in D0.

ConvAllocPhys:
	IFNZB	HFSFlag,1$
	SUB.W	#2,D0			;first alloc block is numbered 2
1$:	ZAP	D1
	MOVE.W	BlksPerAllocBlk,D1
	IFEQIW	D1,#1,2$		;no need to adjust
	MULU	D1,D0			;else multiply as necessary
2$:	ADD.W	BlockOffset,D0
	RTS

* Writes contents of MacBuffer (which matches size of allocation
* block) to disk, after allocating a new allocation block for the
* file.  D0 contains number of active bytes contained in the
* buffer, for purposes of setting logical file size.  However, the
* full buffer is actually written to disk.

WriteMacBlock:
	PUSH	D2-D3/A2
	ADD.L	D0,MacFileSize		;running byte count
	BEQ	9$			;nothing to write
	IFNZB	HFSFlag,5$
	BSR	GetFreeVolAllocBlk	;find a free block for THIS write
	ERROR	8$			;no more...disk full
	INCW	MacBlkCnt		;one more alloc block in file
	MOVE.W	MacBlock,D1		;block for last write or 0
	EXG	D0,D1			;old to D0, new to D1
	MOVE.W	D1,MacBlock		;block where this write goes
	IFNZW	D0,1$			;not initial block
;	MOVE.L	DirPtr,A0		;else update Dir block
	MOVE.W	D1,FirstFileBlock	;starting block of fork
	BRA.S	2$
1$:	BSR	PutVolAllocBlock	;store D1 as fwd link in alloc map
2$:	MOVE.W	MacBlock,D0
	MOVEQ	#1,D1			;mark this blk as last blk in file
	BSR	PutVolAllocBlock
	BRA.S	6$
5$:	BSR	AllocHFSBlock
	ERROR	8$
	INCL	VolBuf+VB_WrtCnt	;count the write
6$:	MOVE.W	MacBlock,D0		;write to this alloc block
	BSR	ConvAllocPhys		;convert alloc blk number to physical
	MOVE.W	BlksPerAllocBlk,D1
	MOVE.L	MacBuffer,A0
	BSR	WriteN			;write out blocks
	BRA.S	9$			;error writing blocks
8$:	DispErr	MacDskFull.
	SETF	AbortFlg		;make sure we bail out
	STC
9$:	POP	D2-D3/A2
	RTS

* Given current volume alloc block in D0, returns contents of block in D0.
* Meaning: 0=unallocated block, 1=last allocated block of file,
* n=next allocated block of file.  Returns CY=1 if no more blocks.
* Flat file only.

GetVolAllocBlock:
;	MOVE.W	MacBlock,D0
	IFZW	D0,10$			;not a valid block number
	IFEQIW	D0,#1,10$		;1=last block of file...stop
	SUBI.W  #2,D0			;first entry in map is alloc blk 2
	MOVE.W  D0,D1
	PUSH	D1
	ADD.W   D1,D1
	ADD.W   D0,D1
	LSR.W   #1,D1
	MOVEA.L BlockMapPtr,A0
	MOVE.B  0(A0,D1.W),D0
	LSL.W   #8,D0
	MOVE.B  1(A0,D1.W),D0
	POP	D1
	BTST    #0,D1
	BEQ.S   2$
	ANDI.W  #$FFF,D0
	BRA.S   9$
2$:	LSR.W   #4,D0
9$:	RTS

10$:	STC
	RTS

* Stores data in D1 into vol alloc block map entry in D0.

PutVolAllocBlock:
	PUSH	D2-D3
	LEA	VolBuf,A0
	MOVE.L	BlockMapPtr,A1		;Point to Vol alloc map
	ANDI.L	#$FFF,D0		;12 bits only ***********
	ANDI.L	#$FFF,D1		;
	CMP.W	VB_NumAllocBlks(A0),D0	;block number in range?
	BHI	9$			;no...number out of range
	SUB.W	#2,D0			;1st entry in map is alloc blk 2
	BMI	9$
	MOVE.W	#$F000,D3		;bit mask
	BTST	#0,D0			;alloc blk even?
	BNE.S	2$			;no
	LSL.L	#4,D1			;else shift to upper 12 bits
	ROL	#4,D3			;shift bit map also
2$:	MOVE.L	D0,D2
	ADD.L	D2,D2
	ADD.L	D0,D2			;*3
	LSR.L	#1,D2			;/2
	MOVE.B	0(A1,D2.W),D0		;get current alloc map entry
	SWAB	D0			;to upper byte
	MOVE.B	1(A1,D2.W),D0		;get other byte
	AND.W	D3,D0			;mask off old contents, preserve rest
	OR.W	D1,D0			;or in new contents
	MOVE.B	D0,1(A1,D2.W)		;now store new contents
	SWAB	D0
	MOVE.B	D0,0(A1,D2.W)
9$:	POP	D2-D3
	RTS

* Finds a free volume alloc block in the flat allocation table.  
* Returns allocation block number on D0, or CY=1 if disk is full.  
* Flat file only.  Note: for simplicity, we ignore volume clump size param
* and allocate single alloc blocks only.  Up yours, SJ.

GetFreeVolAllocBlk:
	PUSH	D2-D3/A2
	LEA	VolBuf,A2
	MOVE.W	VB_FreeAllocBlks(A2),D0	;get number of free blocks
	BEQ.S	8$			;none...disk must be full
	MOVE.W	VB_NumAllocBlks(A2),D2	;number of entries to check
	DECW	D2
	MOVEQ	#2,D3			;first entry in table is alloc block 2
1$:	MOVE.L	D3,D0			;try this alloc block
	BSR	GetVolAllocBlock	;is it free?
	IFZW	D0,2$			;0=found a free alloc blk
	INCW	D3			;else try next one
	DBF	D2,1$			;loop for all blocks in list
8$:;	DispErr	MacDskFull.
	STC				;OOPS...DISK FULL
	BRA.S	9$
2$:	MOVE.W	D3,D0			;return free alloc block in D0
	DECW	VB_FreeAllocBlks(A2)	;one more busy now
9$:	POP	D2-D3/A2
	RTS

* Finds a free entry in flat dir.  Returns ptr in A0 or CY=1 if dir full.

GetFreeFlatDir:
	PUSH	D2-D3
	LEN.	FileName.
;	MOVE.L	CurFib,A0
;	LEN.	df_Name(A0)		;get length of file name
;	MOVE.B	D0,MacFileNameLen	;save for later
	MOVEQ	#FF_NameLen+2,D1	;length of dir entry+1 (round up)
	ADD.L	D0,D1
	BCLR	#0,D1			;calculate length of entry with pad
	MOVE.L	CatBuf,A0		;directory info in this buffer
	LEA	VolBuf,A1		;volume buffer
	MOVE.W	VB_NbrFiles(A1),D2	;flat dir file count
	BEQ	9$			;no files...use first entry
	DECW	D2			;for dbf
	MOVE.L	#512,D3
	MOVE.L	A0,A1
	MOVE.L	A0,D0
	ADD.L	CatBufSize,D0
	MOVE.L	D0,CatBufEnd

1$:	IFLTL	A0,A1,2$		;not end of block yet...
	ADD.L	D3,A1			;bump to next block
2$:	IFLEL	CatBufEnd,A0,8$,L	;end of buffer...no room in dir
	TST.B	(A0)			;active entry?
	BMI.S	3$			;yes...skip over it
	MOVE.L	A1,A0
	BRA.S	1$

3$:	BSR	SkipDirEntry		;skip over flat dir entry
	DBF	D2,1$			;loop for number of active files

4$:	TST.B	(A0)			;this had better be free...
	BMI.S	8$			;dir entry should have been free
	MOVE.L	A0,D0
	ADD.L	D1,D0			;room in this block?
	IFGTL	A1,D0,9$		;there is room
	MOVE.L	A1,A0			;else advance to next block
	ADD.L	D3,A1
	BRA.S	4$
8$:	DispErr	MacDirFull.
	STC
	BRA.S	10$
9$:	CLC
10$:	POP	D2-D3
	RTS

* Advances A0 to end of current flat dir entry.

SkipDirEntry:
	LEA	FF_NameLen(A0),A0	;point to length of name
	ZAP	D0
	MOVE.B	(A0)+,D0
	ADD.L	A0,D0
	INCL	D0			;round up
	BCLR	#0,D0
	MOVE.L	D0,A0
	RTS

* Builds a flat dir entry based on CurFib data.  Also updates Volume info.

BuildFlatDirEntry:
	MOVE.L	MacHandle,A0		;build entry here
	MOVE.B	#$80,(A0)+		;active entry
	CLR.B	(A0)+			;no version
	MOVE.L	MacType,(A0)+		;ASCII file type
	MOVE.L	MacCreator,(A0)+	;ASCII Creator
	CLR.L	(A0)+			;remaining Finder bytes
	CLR.L	(A0)+
	LEA	VolBuf,A1
	MOVE.L	VB_NextID(A1),D0
	MOVE.L	D0,(A0)+		;next unused file ID
	MOVE.L	D0,MacFileNbr
	CLR.W	(A0)+			;zap data fork info
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.W	(A0)+			;zap resource fork info
	CLR.L	(A0)+
	CLR.L	(A0)+
	MOVE.L	FileDate,D0		;date/time from Dos file
	MOVE.L	D0,(A0)+		;creation date/time
	MOVE.L	D0,(A0)+		;modification date/time
;	BSR	StoreFileName	
;	RTS

* Stores new file name in FileName. into new dir entry at A0.

StoreFileName:
	PUSH	A0
	LEN.	FileName.
	POP	A1
	MOVE.B	D0,(A1)+
	MOVE.	FileName.,A1
	RTS

* MOVES MAC volume name into MacVolName.

GetVolName:
	MOVEQ	#MaxVolName,D1		;max size of mac volume name
	LEA	VolBuf+VB_NameLen,A0
	ZAP	D3
	MOVE.B	(A0)+,D3		;get length of name
	LEA	VNAM_INFO,A1
	MOVE.W	D3,si_BufferPos(A1)
	MOVE.W	D3,si_NumChars(A1)
	DECW	D3
	LEA	MacVolName.,A1
2$:	MOVE.B	(A0)+,(A1)+		;GET A NAME BYTE
	DECW	D1			;COUNT IT
	BEQ.S	1$			;FINISHED...BAIL OUT
	DBF	D3,2$			;MOVE THE WHOLE NAME
1$:	CLR.B	(A1)+			;terminate with null
	RTS

* Appends name pointed to by A0 to MacPath.  Limits MacPath. to PathSize.

AppendMacPath:
	MOVE.W	#PathSize-3,D1		;max path with room for '/' and null
	LEA	MacPath.,A1
1$:	TST.B	(A1)
	BEQ.S	2$			;end of MacPath.?
	INCL	A1			;no
	DBF	D1,1$			;keep searching
	RTS				;oops...already too long
2$:	MOVE.B	(A0)+,(A1)+		;add a new char
	DBEQ	D1,2$			;loop till end of new string or limit
	DECL	A1
	MOVE.B	#'/',(A1)+		;trailing slash
	CLR.B	(A1)			;null term
	RTS

TruncateMacPath:
	IFZB	MacPath.,9$
	LEA	MacPath.,A0		;point to path
	MOVE.L	A0,A1
1$:	TST.B	(A0)+			;find the end of it
	BNE.S	1$
	DECL	A0
	DECL	A0
2$:	IFLEL	A0,A1,4$		;nothing left...
	MOVE.B	-(A0),D0		;get previous char
	IFEQIB	D0,#':',3$		;thats it...
	IFNEIB	D0,#'/',2$		;no...loop
3$:	CLR.B	1(A0)			;else terminate string here
	BRA.S	9$
4$:	CLR.B	(A1)
9$:	RTS
	

* Converts Mac date/time format to Amiga date/time format.
* Mac stores date/time in a single long word of seconds since Jan 1, 1904.
* Amiga stores date as a long word of days since Jan 1, 1978, 
* and time as a long word of minutes since midnight (we ignore ticks of minute).
* Called with Mac date/time in D0.  Returns Amiga days in D0 and mins in D1.

MagicNumber	EQU	27029	;Jan 1, 1978 - Jan 1, 1904

ConvMacDate:
	ZAP	D1
	LSR.L	#1,D0		;divide by 86400 to get days since 1904
	ROXR.L	#1,D1		;preserve low order bit
	DIVU	#43200,D0	;avoid long divide
	SWAP	D0
	MOVE.W	D0,D1		;remainder=secs of day
	ROL.L	#1,D1		;restore low order bit
	CLR.W	D0
	SWAP	D0		;days since 1904 in D0.L
	SUB.L	#MagicNumber,D0	;gets days since jan 1, 1978
	DIVU	#60,D1		;minutes since midnight
	EXT.L	D1		;fix high order word
	RTS

* Converts Dos date in D0 and minutes in D1 to seconds since Jan 1, 1904 in D0.

ConvDosDate:
	MULU	#60,D1		;get seconds of today
	ADD.L	#MagicNumber,D0	;adjust days for 1904
	LSL.L	#1,D0		;avoid long mult
	MULU	#43200,D0	;mult by 86400 secs per day
	ADD.L	D1,D0		;add in seconds of today
	RTS

* Gets current date/time from ADOS and converts to Mac format in D0.

GetMacDate:
	PUSH	A2
	LEA	DateStamp,A2
	MOVE.L	A2,D1
	CALLSYS	DateStamp,DosBase	;current date/time
	MOVE.L	(A2)+,D0		;days
	MOVE.L	(A2)+,D1		;minutes
	BSR.S	ConvDosDate		;convert to Mac format
	POP	A2
	RTS

* Deletes invalid char ":" and leading "." from potential Mac file name.
* Limits name to 31 chars.  Leaves result in FileName, with length in
* MacFileNameLen.

FixFileName:
	LEA	FileName.,A0
	MOVE.L	A0,A1
	MOVEQ	#FileNameLen-1,D1
	MOVE.B	(A0)+,D0		;get first byte
	BEQ.S	3$			;null name...
	IFNEIB	D0,#'.',2$		;not a leading period
1$:	MOVE.B	(A0)+,D0
	BEQ.S	3$
2$:	IFEQIB	D0,#':',1$		;strip out colon
	MOVE.B	D0,(A1)+		;so store it already
	DBF	D1,1$			;and loop
3$:	CLR.B	(A1)			;terminate with null
;	MOVE.L	A1,D0
;	SUB.L	#FileName.,D0
;	MOVE.B	D0,MacFileNameLen
	RTS

* LOCAL DATA

BaseDirBlock	DC.L	0	;points to first allocated dir block
CurDBBase	DC.L	0	;base of current dir block
CurDBPtr	DC.L	0	;dir block ptr
CurDBCnt	DC.L	0	;count of remaining bytes in dir block
MacCurLevel	DC.L	0	;ptr to current level
;DirPtr		DC.L	0	;pointer to active flat dir
CatBuf		DC.L	0	;HFS catalog buffer
CatBufEnd	DC.L	0	;end of active dir buffer
CatBufSize	DC.L	0	;size of CatBuf
ExtBuf		DC.L	0	;extent buffer
ExtBufSize	DC.L	0	;size of HFS ExtBuf
BlockMapPtr	DC.L	0	;flat file block map ptr
MacBytCnt	DC.L	0	;Mac buffer byte count
MacFileSize	DC.L	0	;logical size of file in bytes
MacBuffer	DC.L	0	;Mac data buffer
ExtRecPtr	DC.L	0	;ptr to HFS extent record
FileDate	DC.L	0	;Dos date converted to Mac format
MacType		DC.L	0	;Mac file type: 4 ASCII bytes
		DC.W	0	;LEAVE THIS ALONE!!!
MacCreator	DC.L	0	;Mac file creator: 4 ASCII bytes
		DC.W	0	;LEAVE THIS ALONE!!!
MacCurFib	DC.L	0	;ptr to current FIB
DateStamp	DC.L	0,0,0	;date/time stamp buffer
MacFileNbr	DC.L	0	;File number of open Mac file
MacHandle	DC.L	0	;ptr to file block, valid during r/w only
AllocBlkSizeL	DC.W	0	;high order part of alloc block size
AllocBlkSizeW	DC.W	0	;size of allocation block in bytes
MacBlock	DC.W	0	;next block to be read/written
MacBlkCnt	DC.W	0	;running count of blocks during read/write
ExtBlkCnt	DC.W	0	;count of blocks in extent
MacTotFiles	DC.W	0	;count of total mac files
BlockOffset	DC.W	0	;block logical to physical conversion constant
BlksPerAllocBlk	DC.W	0	;number of physical blocks per alloc block
AllocBlksPerClump DC.W	0	;number of alloc blks to allocate
FirstFileBlock	DC.W	0	;first alloc block of flat file
ValidMacVol	DC.B	0	;1=volume table is valid, 0=not
HFSFlag		DC.B	0	;1=disk is HFS format, 0=Flat format
DirBlkCnt	DC.B	0	;count of directory blocks
ExtRecCnt	DC.B	0	;number of extent recs remaining 
ForkType	DC.B	0	;0=data fork, <>0=resource fork
MacWrtFlg	DC.B	0	;1=write operation
DirDirtyFlg	DC.B	0	;1=need to update directory
ExtDirtyFlg	DC.B	0	;1=need to write out ext tree

;CantDelFile.	TEXTZ	<'Can''t delete protected file:'>
CantOpenMac.	TEXTZ	<'Unable to open Mac file:'>
CantCreateMac.	TEXTZ	<'Unable to create Mac file:'>
MacFmtErr.	TEXTZ	<'Unknown Mac disk format.'>
MacDskFull.	TEXTZ	<'Mac disk is full.'>
MacDirFull.	TEXTZ	<'Mac directory is full.'>
Int3.		TEXTZ	<'HFS error 3'>

* LOCAL DATA BUFFERS

	SECTION	MEM,BSS

	CNOP	0,4

MacRootLevel	DS.B	dl_SIZEOF	;root level entry
MacPath.	DS.B	PathSize
MacVolName.	DS.B	MaxVolName+1	;leave room for trailing null

	END
