*********************************************************
*							*
*		HFS.ASM					*
*							*
* 	Mac HFS file system routines			*
*							*
*	Copyright (c) 1989 Central Coast Software	*
*	424 Vista Ave, Golden, CO 80401			*
*	All rights reserved, worldwide			*
*********************************************************

;	INCLUDE	"MAC.I"
;	INCLUDE "VD0:MACROS.ASM"
	INCLUDE "PRE.OBJ"

	XDEF	InitSearch,GetFirstLeafRec,GetNextLeafRec
	XDEF	NextLeafNode
	XDEF	FindNextExtent
	XDEF	AllocateFileRec
	XDEF	InsertCatRec
	XDEF	AllocHFSBlock
	XDEF	InitBaseNode
	XDEF	InitRootDir,UpdateRootDir
	XDEF	DeleteHFSFile
	XDEF	UpdateValence
	XDEF	FindHFSFile
	XDEF	UpdateHFSName
	XDEF	AllocCatClump

	XREF	GetMacDate
	XREF	ReadExtTree
	XREF	AddCatExtent

	XREF	MacType,MacCreator
	XREF	FileDate
	XREF	ExtRecPtr,ExtRecCnt
	XREF	ForkType
	XREF	MacBlock
	XREF	VolBuf,BitMapBuf,ExtBuf,CatBuf
	XREF	MacFileNbr
	XREF	BlockOffset
	XREF	MacBlkCnt
	XREF	TMP.
	XREF	MacHandle,CurFib
	XREF	FileName.
	XREF	FITypeBuf,FICreatorBuf
	XREF	ExtDirtyFlg

RecBufSize	EQU	130		;large enough for file rec + key
IdxRecSize	EQU	42		;index rec exactly 42 bytes long
;CatIdxSize	EQU	42
;ExtIdxSize	EQU	12

NodeLnk	MACRO	;src,An
	MOVE.L	\1,D0
	LSL.L	D7,D0
	ADD.L	A4,D0
	MOVE.L	D0,\2
	ENDM

* This module contains routines which implement the HFS filing system
* for a Mac disk.

* Called when adding or deleting a file to update the "valence" (count
* of offspring) in a directory record.  Count (+1 or -1) in D1.  Dir ID
* of current dir in D0.  Returns CY=1 on error.

UpdateValence:
	PUSH	D2
	MOVE.W	D1,D2
	BSR.S	GetDirRec		;go for the directory record
	ERROR	9$
	BSR	SetRecPtr		;point to record in leaf node
	ZAP	D0
	MOVE.B	(A0)+,D0
	ADD.L	D0,A0
	BTST	#0,D0
	BNE.S	1$
	INCL	A0
1$:	ADD.W	D2,DR_Valence(A0)	;update valence
9$:	POP	D2
	RTS

* Given current dir ID in D0, finds thread record which points to
* the parent directory and contains the name of the parent dir.  Returns
* leaf node of dir record in A0 and record number in D0, or CY=1.

GetDirRec:
	PUSH	A2
	MOVE.L	CatBuf,BaseNodePtr
	LEA	Null.,A0		;thread record has 0-length key name
	BSR	BuildCatKey		;catalog key to buffer
	LEA	RecordBuffer,A0
	BSR	SearchTree		;find the thread record
	BNE.S	8$			;didn't find thread...
	BSR	SetRecPtr		;point A0 to the thread record
	MOVE.L	A0,A2
	ADDQ.L	#8,A2			;skip over thread rec key
	IFNEIB	TR_Type(A2),#3,8$	;oops...not a thread record	
	LEA	TR_NameLen(A2),A0	;point to name of parent
	STG_Z.	A0,TMP.			;convert to null terminated
	LEA	TMP.,A0
	MOVE.L	TR_ParentID(A2),D0	;get dir id of parent
	BSR	BuildCatKey
	LEA	RecordBuffer,A0
	BSR	SearchTree
	BEQ.S	9$
8$:	STC
9$:	POP	A2
	RTS

* Allocate directory record.  Directory ID in D0, ParentID in D1.
* Ptr to name string in A0.
* Returns length of record (including key) in D0.

AllocateDirRec:
	PUSH	D2/A2
	MOVE.L	D0,D2			;dir id
	MOVE.L	D1,D0			;parent id
	BSR	BuildCatKey		;A0 points to name string
	MOVE.L	A0,A2			;
	MOVE.B	#1,(A2)+		;dir type=1
	CLR.B	(A2)+			;reserved
	CLR.W	(A2)+			;all flags=0
	CLR.W	(A2)+			;valence starts at 0
	MOVE.L	D2,(A2)+		;directory id
	BSR	GetMacDate		;get current date in mac format
	MOVE.L	D0,(A2)+		;creation date
	MOVE.L	D0,(A2)+		;last mod date
	CLR.L	(A2)+			;backup date
	MOVEQ	#48,D1			;48 bytes of empty space
	BSR	ZapBytes
	MOVE.L	A2,D0			;calc record length
	SUB.L	#RecordBuffer,D0
	MOVE.W	D0,RecordLen
	POP	D2/A2
	RTS

* Updates old HFS dir record, copies it to a new one, then deletes
* the old one.

UpdateHFSName:
	PUSH	A2
	MOVE.L	MacHandle,A2		;update old record first
	MOVE.B	FR_Flags(A2),D0
	AND.B	#$FE,D0
	MOVE.L	CurFib,A1
	MOVE.B	df_Flags(A1),D1
	AND.B	#1,D1
	OR.B	D1,D0
	MOVE.B	D0,FR_Flags(A2)		;update protection
	MOVE.L	FITypeBuf,FR_FinderType(A2)
	MOVE.L	FICreatorBuf,FR_FinderCreator(A2)
	MOVE.L	NodeRecPtr,A0		;points to complete node record
	MOVE.L	CK_ParID(A0),D0		;get parent id from old file rec
	LEA	FileName.,A0		;point to new name
	BSR	BuildCatKey		;build key for new entry
	MOVE.L	A2,A1			;point to old record data
	MOVEQ	#FR_SIZE-1,D0		;move this much
1$:	MOVE.B	(A1)+,(A0)+		;do it
	DBF	D0,1$
	MOVE.L	A0,D0
	SUB.L	#RecordBuffer,D0
	MOVE.W	D0,RecordLen
	MOVE.L	NodePtr,A0		;saved from earlier search
	MOVE.W	NodeRecNbr,D0
	BSR	DeleteLeafRecord	;delete old file record
	BSR	UpdateIndexStruct	;rebuild index, if needed
	BSR	InsertCatRec		;then sort/insert new record into cat
	MOVE.L	A0,MacHandle		;points to new record
	POP	A2
	RTS	

* Builds root directory record and thread record and inserts them into
* first leaf of catalog tree structure (which it adds).
* A0 points to buffer to build into, A1 points to name string to use.

InitRootDir:
	PUSH	A2-A3
	MOVE.L	A0,BaseNodePtr		;work this buffer
	MOVE.L	A1,A3			;save name string ptr
	BSR	AddFirstLeaf		;add a leaf to the cat tree
	ERROR	9$
	MOVE.L	A0,A2			;point to the new leaf
	MOVE.L	A0,LeafPtr
	MOVEQ	#2,D0			;root dir id=2
	MOVEQ	#1,D1			;and parent id=1
	MOVE.L	A3,A0			;ptr to name string
	BSR	AllocateDirRec		;build directory record
;	MOVE.W	D0,D2			;length of directory record
	MOVEQ	#1,D0			;insert as record 1
	BSR	InsertLeafRecord	;put into leaf
	MOVEQ	#2,D1			;parent id (id of dir it belongs to)
	MOVEQ	#1,D0			;id of assoc dir (parent of dir)
	MOVE.L	A3,A0
	BSR	AllocateThreadRec	;build thread rec
	MOVEQ	#2,D0			;insert as record 2
	BSR	InsertLeafRecord	;into leaf
9$:	POP	A2-A3
	RTS

* Updates existing HFS root dir after volume name change.
* Ptr to name in A1

UpdateRootDir:
	PUSH	A2-A3
	MOVE.L	CatBuf,A0
	MOVE.L	A0,BaseNodePtr
	MOVE.L	A1,A3
	MOVE.L	BN_FLink(A0),D0		;get first leaf node
	BSR	NodeAddr		;point to node
	MOVE.L	A0,LeafPtr		;this is leaf we must update
	MOVE.L	A0,A2
	MOVEQ	#1,D0
	BSR	DeleteLeafRecord	;remove root dir
	MOVE.L	A2,A0
	MOVEQ	#1,D0
	BSR	DeleteLeafRecord	;and thread record
	MOVEQ	#2,D0			;root dir id=2
	MOVEQ	#1,D1			;and parent id=1
	MOVE.L	A3,A0			;ptr to name string
	BSR	AllocateDirRec		;build directory record
;	MOVE.W	D0,D2			;length of directory record
	MOVEQ	#1,D0			;insert as record 1
	BSR	InsertLeafRecord	;put into leaf
	MOVEQ	#2,D1			;parent id (id of dir it belongs to)
	MOVEQ	#1,D0			;id of assoc dir (parent of dir)
	MOVE.L	A3,A0
	BSR	AllocateThreadRec	;build thread rec
	MOVEQ	#2,D0			;insert as record 2
	BSR	InsertLeafRecord	;into leaf
	SETF	IndexFlag	
	BSR	UpdateIndexStruct
	POP	A2-A3
	RTS

* Allocates file record.  File number in D0, ParentID in D1. A0 points to 
* name string.  FileType and Creator must be set correctly.  

AllocateFileRec:
	PUSH	D2/A2
	MOVE.L	D0,D2			;file number
	MOVE.L	D1,D0			;parent id
	BSR	BuildCatKey		;A0 points to name string
	MOVE.L	A0,A2			;
	MOVE.B	#2,(A2)+		;file type=1
	CLR.B	(A2)+			;reserved
	MOVE.B	#$80,(A2)+		;record is used
	CLR.B	(A2)+			;file type
	MOVE.L	MacType,(A2)+		;4 chars
	MOVE.L	MacCreator,(A2)+	;ditto
	CLR.L	(A2)+			;8 more finder bytes
	CLR.L	(A2)+
	MOVE.L	D2,(A2)+		;file number
	CLR.W	(A2)+			;data fork blk
	CLR.L	(A2)+
	CLR.L	(A2)+
	CLR.W	(A2)+			;resource fork blk
	CLR.L	(A2)+
	CLR.L	(A2)+
	MOVE.L	FileDate,D0
;	BSR	GetMacDate		;get current date in mac format
	MOVE.L	D0,(A2)+		;creation date
	MOVE.L	D0,(A2)+		;last mod date
	CLR.L	(A2)+			;backup date
	MOVEQ	#16,D1			;16 bytes of finder space
	BSR	ZapBytes
	CLR.W	(A2)+			;clump size=0
	MOVEQ	#24,D1			;zap extent descriptors
	BSR	ZapBytes		;data fork extent rec
	CLR.L	(A2)+			;reserved
	MOVE.L	A2,D0			;calc record length
	SUB.L	#RecordBuffer,D0
	MOVE.W	D0,RecordLen
	POP	D2/A2
	RTS

* Allocate thread record.  Parent ID of assoc dir in D0, ParentID in D1.
* A0 points to name string of associated dir.
* Returns length of record (including key) in D0.
* Note: thread record has 0-length name in key.  That way it ALWAYS
* sorts ahead of the other records of that same dir id.

AllocateThreadRec:
	PUSH	D2/A2-A3
	MOVE.L	A0,A3			;ptr to name of assoc dir
	MOVE.L	D0,D2			;Parent ID of assoc dir
	MOVE.L	D1,D0			;parent id
	LEA	Null.,A0		;thread record has 0-length key name
	BSR	BuildCatKey		;catalog key to buffer
	MOVE.L	A0,A2			;
	MOVE.B	#3,(A2)+		;thread type=3
	CLR.B	(A2)+			;reserved
	CLR.L	(A2)+			;8 bytes reserved
	CLR.L	(A2)+
	MOVE.L	D2,(A2)+		;parent id of assoc dir
	MOVE.L	A2,A1
	CLR.B	(A2)+			;zap length byte
1$:	MOVE.B	(A3)+,D0
	BEQ.S	2$			;end of name
	MOVE.B	D0,(A2)+		;move a byte of dir or file name
	INCB	(A1)			;else count length
	BRA.S	1$
2$:	MOVE.L	A2,D0
	INCL	D0
	BCLR	#0,D0			;round up, just in case...
	SUB.L	#RecordBuffer,D0
	MOVE.W	D0,RecordLen		;save length
	POP	D2/A2-A3
	RTS

* Enter with parent dir id in D0, A0 pointing to name string.  
* Returns ptr to file record in A0

FindHFSFile:
	MOVE.L	CatBuf,BaseNodePtr
	BSR	BuildCatKey		;build search rec for file
	LEA	RecordBuffer,A0
	BSR	SearchTree		;find matching leaf record
	BEQ.S	1$			;search succeeded
	STC				;else error retrun
	RTS
1$:	BSR	SetRecPtr
	BSR	SkipOverKey		;return ptr to record data
	CLC
	RTS

* Builds file record, searches catalog tree, and deletes file record, 
* if found.  Enter with parent dir id in D0, A0 pointing to name string.  
* Releases space allocated to both forks.
* Returns CY=1 on failure to find file.

DeleteHFSFile:
	PUSH	D2/A2
	MOVE.L	CatBuf,BaseNodePtr
	BSR	BuildCatKey		;build search rec for file
	LEA	RecordBuffer,A0
	BSR	SearchTree		;find matching leaf record
	BNE.S	8$			;didn't find exact match...
	MOVE.L	A0,A2			;node ptr
	MOVE.W	D0,D2			;record in node
	BSR	SetRecPtr
	BSR	SkipOverKey		;point A0 to record
	BSR	FreeBothExtents		;release blocks in both extents
	MOVE.L	A2,A0
	MOVE.W	D2,D0
	BSR	DeleteLeafRecord	;zap the record
	BSR	UpdateIndexStruct	;rebuild index, if needed
	BRA.S	9$
8$:	STC
9$:	POP	D2/A2
	RTS

* Inserts catalog record into catalog tree.  First searches tree, then
* inserts record, then (if necessary) updates index.
* Returns ptr to record data (NOT the key) in A0.  CY=1 on error.

InsertCatRec:
	PUSH	A2
	MOVE.L	CatBuf,BaseNodePtr
	LEA	RecordBuffer,A0		;record to insert is here
	BSR	SearchInsert		;find place to insert in the tree
	ERROR	9$
	MOVE.L	A0,A2			;points to added record
	BSR	UpdateIndexStruct
	MOVE.L	A2,A0
	BSR.S	SkipOverKey
9$:	POP	A2
	RTS

* Does just what it says...

SkipOverKey:
	ZAP	D0
	MOVE.B	(A0)+,D0
	ADD.W	D0,A0			;point to actual record data
	BTST	#0,D0			;odd length?
	BNE.S	9$			;yes...already on even boundary
	INCL	A0			;else round up
9$:	RTS

* Builds catalog key into record buffer.  ParentID in D0.
* A0 points to name string to be used as key.
* Returns A0 pointing to next byte after name.

BuildCatKey:
	PUSH	A2-A3
	MOVE.L	A0,A2
	LEA	RecordBuffer,A0		;all records go here
	MOVE.L	A0,A3			;key len goes here
	CLR.B	(A0)+			;keylen goes here later
	CLR.B	(A0)+			;internal
	MOVE.L	D0,(A0)+		;parent ID
	MOVE.L	A0,A1			;A1 points to length byte
	CLR.B	(A0)+			;zap length byte
	IFNZB	(A2),1$			;not null name
	CLR.B	(A0)+			;else store a single null
	BRA.S	2$
1$:	MOVE.B	(A2)+,D0		;get a byte of name
	BEQ.S	2$			;end of name
	MOVE.B	D0,(A0)+		;move a byte of dir or file name
	INCB	(A1)			;else count length
	BRA.S	1$
2$:	MOVE.L	A0,D0
	SUB.L	A3,D0
	DECW	D0			;because keylen not included
	MOVE.B	D0,(A3)			;store key len
	MOVE.L	A0,D1
	BTST	#0,D1			;length even?
	BEQ.S	9$			;no
	INCL	A0			;else round up
9$:	POP	A2-A3
	RTS

* Allocates next block for HFS file.
* Returns new block in MacBlock or CY=1 if disk is full.

AllocHFSBlock:
	PUSH	D2
	LEA	VolBuf,A0
	IFNZW	VB_FreeAllocBlks(A0),4$	;there is at least one free blk
	STC				;disk full
	BRA	9$
4$:	MOVE.W	VB_NumAllocBlks(A0),D0 ;max number of alloc blks
	LEA	BitMapBuf,A0		;volume bit map is here
	BSR	AllocBitMap		;get block in D0, mark it busy
	ERROR	9$
	DECW	VolBuf+VB_FreeAllocBlks	;one less free
;;	INCW	MacBlkCnt		;this is count within file ;gec 1/22/90
	MOVE.W	D0,D2
	MOVE.W	MacBlock,D1		;get old block
	MOVE.W	D2,MacBlock		;store new block
	IFZW	D1,3$			;first block...dont test
	INCW	D1
	IFEQW	D2,D1,5$		;new block is contiguous...
	IFNZB	ExtRecCnt,1$		;else use next descriptor, if any
	BSR	AllocExtRec		;allocate another extent record
	BRA.S	3$
1$:	ADDQ.L	#4,ExtRecPtr		;bump ptr to next descriptor
3$:	DECB	ExtRecCnt		;one less descriptor
5$:	MOVE.L	ExtRecPtr,A0
	IFNZW	(A0),2$			;already have ptr to first alloc blk
	MOVE.W	D2,(A0)			;else store block number
2$:	INCW	2(A0)			;and count this block
	INCW	MacBlkCnt		;this is count within file ;gec 1/22/90
9$:	POP	D2
	RTS

* Allocates a clump of D0 blocks for HFS disk.  Returns first block in D0
* or CY=1 if required clump cannot be allocated.

AllocCatClump:
	PUSH	D2-D6/A2
	MOVE.W	D0,D2			;number of blocks to alloc
	MOVE.W	VolBuf+VB_NumAllocBlks,D6	;max number of alloc blks
	LEA	BitMapBuf,A2		;volume bit map starts here
4$:	BSR.S	AllocBlock		;allocate first block
	ERROR	8$			;Out of space
	MOVEQ	#1,D3			;one block
	MOVE.W	D0,D4			;block number of first
	MOVE.W	D0,D5			;for sequential check
1$:	BSR.S	AllocBlock		;get another
	ERROR	5$			;out of space...
	INCW	D3			;one more allocated
2$:	INCW	D5
	IFEQW	D0,D5,3$		;sequential...keep going
5$:	MOVE.W	D4,D0			;release from here
	MOVE.W	D3,D1			;release this many
	BSR	FreeExtent		;not enough for clump...free them
	BRA.S	4$			;and start again
3$:	IFLTW	D3,D2,1$		;try for another
	MOVE.W	D4,D0			;return first block of clump
8$:	POP	D2-D6/A2
	RTS

AllocBlock:
	MOVE.L	A2,A0			;start checking here
	MOVE.W	D6,D0			;for this many remaining
	BSR.S	AllocBMCont		;get block in D0, mark it busy
	RTSERR
	MOVE.L	A0,A2			;save ptr to last allocated
	MOVE.W	D1,D6			;this many remaining
	RTS

* Bitmap base in A0, max number of items to check in D0.  Marks entry
* busy.  Returns entry number (0-origin) in D0, or CY=1 if nothing free.
* A0 points to entry in bitmap and D1 contains number of items remaining

AllocBMCont:
	LEA	BitMapBuf,A1
	BRA.S	ABMcom

AllocBitMap:
	MOVE.L	A0,A1
ABMcom:
	PUSH	D2-D3
	MOVEQ	#8,D2
	MOVEQ	#-1,D1
	MOVE.W	D0,D3		;item counter
1$:	MOVE.B	(A0)+,D0
	CMP.B	D0,D1		;check out an entry
	BNE.S	2$		;not all used...check it out
	SUB.W	D2,D3		;else just checked 8
	BGT.S	1$		;loop till we find something
	STC			;oops...END OF BITMAP
	BRA.S	8$
2$:	ZAP	D1
3$:	ROL.B	#1,D0		;shift a bit into CY
	BCC.S	4$
	INCW	D1
	BRA.S	3$
4$:	DECL	A0		;back up to free entry
	MOVE.L	A0,D0
	SUB.L	A1,D0		;offset into BitMap
	LSL.W	#3,D0		;mult by 8
	ADD.W	D1,D0		;bit number within byte
	NOT.W	D1
	AND.W	#7,D1
	BSET	D1,(A0)		;mark the block busy
	MOVE.W	D3,D1		;return number of items remaining
8$:	POP	D2-D3
	RTS

* Called with ptr to file record in A0.  Deletes blocks allocated to
* either or both forks of the file.

FreeBothExtents:
	PUSH	A2
	MOVE.L	A0,A2
;;	MOVE.W	#1,BlockCount				;GEC 1/22/90
	CLR.W	BlockCount				;gec 1/22/90
	LEA	FR_DExtRec(A2),A0	;point to data fork 1st extent
	BSR	ReleaseThree
	ERROR	1$			;didn't use all 3
	ZAP	D1			;data fork
	MOVE.L	FR_FileNbr(A2),D0
	BSR	CheckExtentTree		;else check for recs in extent tree
1$:;;	MOVE.W	#1,BlockCount				;GEC 1/22/90
	CLR.W	BlockCount				;gec 1/22/90
	LEA	FR_RExtRec(A2),A0
	BSR	ReleaseThree
	ERROR	2$			;didn't use all 3
	MOVEQ	#-1,D1			;resource fork
	MOVE.L	FR_FileNbr(A2),D0
	BSR	CheckExtentTree		;else check for recs in extent tree
2$:	POP	A2
	RTS

* Checks extent tree for extent records.  Filenbr in D0, forktype
* in D1.  Next expected record in BlockCount.

CheckExtentTree:
	PUSH	D2-D4
	MOVE.L	D0,D3			;gec 1/20/90
	MOVE.L	D1,D4			;gec /120/90
	BSR	ReadExtTree		;load ext tree
	ERROR	9$
;;	MOVE.L	D0,D3			;GEC 1/20/90
;;	MOVE.L	D1,D4			;GEC 1/20/90
1$:	MOVE.L	D3,D0
	MOVE.L	D4,D1
	MOVE.W	BlockCount,D2
	BSR	BuildExtRec		;build extent record
	LEA	RecordBuffer,A0
	BSR	SearchTree		;look for matching record
	BNE.S	9$
	SETF	ExtDirtyFlg
	BSR	SetRecPtr		;point to extent record
	BSR	SkipOverKey
	BSR.S	ReleaseThree
	BRA.S	1$
9$:	POP	D2-D4
	RTS

* Checks and releases contents of 3 extent descriptors.  Ptr to first
* descriptor is in A0.  Returns CY=1 if all three not used.

ReleaseThree:
	PUSH	D2/A2
	MOVEQ	#2,D2			;3 possible extents in file rec
	MOVE.L	A0,A2
1$:	MOVE.W	(A2)+,D0		;get block number
	BNE.S	2$
	STC
	BRA.S	9$
2$:	MOVE.W	(A2)+,D1		;count of blocks in extent
	ADD.W	D1,BlockCount
	BSR.S	FreeExtent		;free blocks in extent
	DBF	D2,1$			;loop for all three descriptors
9$:	POP	D2/A2
	RTS	

* Called with first alloc block to free in D0 and count of blocks in D1.
* Marks blocks free in bitmap.

FreeExtent:
	PUSH	D2-D3
	MOVE.W	D1,D3		;count of blocks to free
	DECW	D3		;for dbf
	MOVE.W	D0,D2
1$:	MOVE.W	D2,D0
	BSR.S	FreeBlock
	BEQ.S	2$		;oops...wasn't busy
	INCW	VolBuf+VB_FreeAllocBlks
2$:	INCW	D2
	DBF	D3,1$
	POP	D2-D3
	RTS

* Clears busy bit for alloc block in D0.

FreeBlock:
;	SUB.W	BlockOffset,D0
	MOVE.W	D0,D1
	NOT.W	D1
	AND.W	#7,D1
	LSR.W	#3,D0
	LEA	BitMapBuf,A0
	BCLR	D1,0(A0,D0.W)	;mark it free
	RTS

* This routine is called when the next block of a file is not contiguous.
* Builds empty extent record, and inserts into extent tree file.
* Sets ExtRecPtr to first descriptor and ExtRecCnt=3, or CY if error.

AllocExtRec:
	PUSH	D2
	BSR	ReadExtTree		;make sure extent tree is loaded
	ERROR	9$			;oops...cant get ext tree
	MOVE.L	MacFileNbr,D0
	MOVE.B	ForkType,D1
	MOVE.W	MacBlkCnt,D2
	BSR	BuildExtRec		;builds key in RecordBuffer, via A0
	LEA	RecordBuffer,A0
	BSR	SearchInsert		;search tree and insert into leaf
	ERROR	9$
;;	BSR	SetRecPtr		;point to new extent rec ;;GEC 1/19/90
	ADDQ.L	#ExtKeyLen+1,A0		;bump past key
	MOVE.L	A0,ExtRecPtr
	MOVE.B	#3,ExtRecCnt		;3 empty descriptors
	SETF	ExtDirtyFlg
9$:	POP	D2
	RTS

* Builds empty extent record in RecordBuffer.
* Called with filenbr in D0 and forktype in D1.
* D2=block count to be inserted into extent key.

BuildExtRec:
	PUSH	A2
	MOVE.L	ExtBuf,BaseNodePtr	;work the extent tree
	LEA	RecordBuffer,A2		;word boundary
	MOVE.B	#ExtKeyLen,(A2)+	;keylen
	IFZB	D1,1$			;0=data fork		;gec 1/22/90
	MOVEQ	#-1,D1			;force resource fork=$ff;gec 1/22/90
1$:	MOVE.B	D1,(A2)+		;store fork type	;gec 1/22/90
	MOVE.L	D0,(A2)+		;file number
	MOVE.W	D2,(A2)+		;block count within file
	MOVEQ	#12,D1
	BSR	ZapBytes		;clear extent record
	MOVE.L	A2,D0			;calc record length
	SUB.L	#RecordBuffer,D0
	MOVE.W	D0,RecordLen
	POP	A2
	RTS

* Searches tree, and inserts record in A0 into leaf at proper place.
* Returns CY=1 on any error.  Should be no match.  Returns A0=leaf
* node ptr and D0=record number.

SearchInsert:
	BSR	SearchTree		;find proper leaf to insert this rec
	NOERROR	1$			;found exact match or insert position
	IFNZL	A0,3$			;insert new rec at end of this leaf
	BSR	AddFirstLeaf		;barren tree...add first leaf 
3$:	MOVE.L	A0,LeafPtr
	BSR	AddLeafRecord		;add record to end of leaf node
	ERROR	9$			;error adding leaf record...cat full?
	BRA.S	7$
1$:	BNE.S	2$			;exact match?
	DispErr	Int1.			;oops...should not happen
	STC
	BRA.S	9$
2$:;;	MOVE.W	D0,D2			;no match...insert before this rec
	MOVE.W	D0,LeafRec
	MOVE.L	A0,LeafPtr		;leaf node ptr
;;	MOVE.L	A0,A2
	BSR	InsertLeafRecord	;insert new record into leaf
	ERROR	9$			;probably ran out of nodes
;;	MOVE.W	D2,D0			;added record uses old rec number
;;	MOVE.L	A2,A0			;leaf node ptr
	MOVE.W	LeafRec,D0
	MOVE.L	LeafPtr,A0
	BSR	SetRecPtr		;point A0 to added record for caller
7$:	CLC
9$:	RTS

* Searches either tree using index structure.  Base of tree in BaseNodePtr.
* A0 points to search key.  Returns node leaf ptr in A0, with record number 
* in D0 of record to insert new record in front of or exact match record.
* Returns CY=0, Z=1 if exact match found.  Returns CY=1 if end of list or 
* list empty (no match and no insert position).
* If CY=1 and A0=0, list empty.  CY=1 and A0<>0, points to last leaf of tree.

SearchTree:
	PUSH	D2-D3/A2-A3
	MOVE.L	A0,A2
	CLR.L	NodePtr			;in case tree is barren
	MOVE.L	BaseNodePtr,A3
	MOVE.W	BN_TopLevel(A3),D1
	BEQ	8$			;nothing...dead tree!!
	IFEQIW	D1,#1,1$		;no index structure...try leaves
	MOVE.L	BN_RootNode(A3),D0	;point to top level index node
	BRA.S	2$	
1$:	MOVE.L	BN_FLink(A3),D0		;get leaf node, if any
	BEQ	8$			;no nodes at all...tree is barren

* Come here when we start at a new index level.

2$:	MOVE.W	D0,NodeNbr		;save current node number
	BSR	NodeAddr		;convert to node ptr
	MOVE.L	A0,NodePtr		;save ptr to this node
	MOVE.B	NL_Level(A0),NodeLevel
	MOVE.W	NL_NbrRecs(A0),NodeRecCnt ;save count of recs in node
	MOVE.B	NL_Type(A0),NodeType	;save node type
	CLR.W	NodeRecNbr		;init node record counter

* Come here to get next record of current node

3$:	BSR	GetNodeRec		;get ptr to next record in node
	ERROR	21$			;no more node recs...no match
	MOVE.L	A0,NodeRecPtr		;save ptr to this node record
	MOVE.L	A2,A1			;point to search key
	MOVE.W	(A0)+,D0		;skip over key length and pad
	MOVE.W	(A1)+,D0
	CMP.L	(A0)+,(A1)+		;compare parent id's or file nbrs
	BEQ.S	15$			;keys are equal so far...continue
	BHI.S	3$			;search key>record key...try next
	BRA.S	5$			;search key<record key...insert here

15$:	IFEQL	BaseNodePtr,CatBuf,22$	;searching catalog tree
	CMP.W	(A0)+,(A1)+		;else extent tree...check block #s
	BEQ	9$			;exact match
	BHI.S	3$			;search key>record key...try next rec
	BRA.S	5$			;search key<record key...

* If we get here, we are ready to compare file/dir names.

22$:	MOVE.B	(A0)+,D0		;length of record name
	MOVE.B	(A1)+,D1		;length of search name
4$:	IFZB	D1,20$			;end of search name...rec name longer?
	IFZB	D0,3$			;end of rec name, search name longer
	DECB	D0			;else decrement name length counters
	DECB	D1
	MOVE.B	(A0)+,D2		;get char of search name
	IFLTIB	D2,#'a',16$		;not lower case
	IFGTIB	D2,#'z',16$
	AND.B	#$5F,D2			;else force upper case for compare
16$:	MOVE.B	(A1)+,D3		;get char of record name
	IFLTIB	D3,#'a',17$		;not lc
	IFGTIB	D3,#'z',17$
	AND.B	#$5F,D3			;else force uc for compare
17$:	CMP.B	D2,D3			;compare name chars
	BEQ.S	4$			;chars match...loop till one ends
	BHI.S	3$			;search key>record key...try next rec
	BRA.S	5$			;search key<record key...insert here

* If we get here, search key is greater than all records in node.  If node
* is leaf, insert AFTER the last record.  If index, drop a level and go on.

21$:	IFEQIB	NodeType,#$FF,8$	;leaf level...add to end of this node
	MOVE.W	NodeRecNbr,D0		;get link and search lower level
	BRA.S	6$

* If we get here, search key has ended.  Has record key also?  If so, exact
* match.  If not, record key may be into null pad area.  If so, call it
* exact match.  Else, search key goes in front of record.

20$:	IFZB	D0,9$			;exact match...return node and rec
	IFZB	(A0),9$			;record key into pad area...match

* If we get here, search key goes in front of node record.  If index
* level, back up to previous record, if any, and drop a level.  If no 
* previous record, use node ptr for this record, just to get down the tree,
* but no match will be found.  If already at leaf level, all done!

5$:	IFEQIB	NodeType,#$FF,7$	;at leaf level...insert here
	MOVE.W	NodeRecNbr,D0		;get number of this record
	IFEQIW	D0,#1,6$		;first record of node...cant backup
	DECW	D0			;else use previous record
6$:	MOVE.L	NodePtr,A0		;base of this node
	BSR	SetRecPtr		;point to node record
	ZAP	D0
	MOVE.B	(A0)+,D0		;get key length
	MOVE.L	0(A0,D0.W),D0		;get linkage node number
	BRA	2$			;try that node

* If we get here, have found leaf record to insert in front of.

7$:	MOVE.L	NodePtr,A0		;insert into this leaf node
	MOVE.W	NodeRecNbr,D0		;in front of this record
	BRA.S	10$			;return CY=0, Z=0 (not exact match)

* If we get here, tree is barren or search key greater than any key in
* the existing tree.  In either case, new record goes at end (if any).

8$:	MOVE.L	NodePtr,A0		;point to last leaf node, if any
	MOVE.W	NodeRecNbr,D0		;really dont need this
	STC				;match failed, no position
	BRA.S	10$

* If we get here, we have an exact match.  Return ptr to node in A0
* and record number in node in D0.

9$:	MOVE.L	NodePtr,A0		;exact match return
	MOVE.W	NodeRecNbr,D0
	IFNEIB	NodeType,#$FF,6$	;oops...matched index...try again
	CLC				;CY=0, Z=1 (exact match)
10$:	POP	D2-D3/A2-A3
	RTS

* Sets up to access records in node in A0.

GetNodeRec:
	IFZW	NodeRecCnt,8$		;no more records in this node
	DECW	NodeRecCnt
	INCW	NodeRecNbr		;record number to process
	MOVE.W	NodeRecNbr,D0
	MOVE.L	NodePtr,A0
	BSR	SetRecPtr		;point to record in node
	CLC				;just in case
	RTS
8$:	STC
	RTS

* Searches the extent tree for the next extent record, based on file
* number, block number, and ForkType.

FindNextExtent:
	BSR	ReadExtTree		;load ext tree 		;GEC 1/20/90
	PUSH	D2
	MOVE.L	MacFileNbr,D0
	MOVE.B	ForkType,D1
	MOVE.W	MacBlkCnt,D2
	BSR	BuildExtRec
	POP	D2
	LEA	RecordBuffer,A0
	BSR	SearchTree		;see if we can find next extent
	BNE.S	8$			;oops...didn't find extent rec
	MOVE.L	A0,LeafPtr		;ext rec in this leaf node
	BSR	SetRecPtr		;D0=rec nbr, point to proper record
	ADDQ.L	#ExtKeyLen+1,A0		;point to first extent descriptor
	MOVE.L	A0,ExtRecPtr
	MOVE.B	#3,ExtRecCnt
	RTS
8$:	STC
	RTS

* Catalog index routines

* Called when index structure must be updated because first record in
* a leaf node is changed or a leaf node is added or deleted.
* Frees all index records and then rebuilds that sucker from scratch, by
* scanning the leaf records.  Drastic, but simple.
* BaseNodePtr points to proper tree (works for either tree).
* This routine is hard-coded to handle 2 index levels (2 and 3) ONLY.
* This is enough to handle 121 catalog leaf nodes (11*11).

UpdateIndexStruct:
	PUSH	D2/A2
	IFZB	IndexFlag,9$,L
	BSR	FreeIndexNodes		;get rid of all index nodes
	MOVE.L	BaseNodePtr,A2
	MOVE.W	#1,BN_TopLevel(A2)	;start with 1 level
	MOVE.L	BN_FLink(A2),D2		;if only one level...all done
	MOVE.L	D2,BN_RootNode(A2)	;if single level, leaf is root
	IFEQL	BN_BLink(A2),D2,9$,L	;only one leaf...all done
	BSR	AddFirstIndex		;else add first index node
	MOVE.L	A0,IndexPtr		;this is node we are currently working
	CLR.L	Level3Ptr		;start with no level 3 node
	MOVE.W	D2,D0			;first leaf node
2$:	MOVE.W	D0,NodeNbr		;save current node number
	BSR	NodeAddr		;convert to node ptr
	MOVE.L	A0,NodePtr		;save ptr to this node
;	CLR.W	NodeRecNbr		;start from 0
;	BSR	GetNodeRec		;always get first node record
;	ERROR	9$			;should always be a node record
	MOVEQ	#1,D0			;always use key of rec 1
	BSR	SetRecPtr
	MOVE.L	A0,NodeRecPtr		;save ptr to this node record
	MOVE.W	NodeNbr,D0
	BSR	BuildIndexRec		;make an index rec out of leaf key
	MOVE.L	IndexPtr,A0
	BSR	GetNodeSpace		;find out if index node can hold key
	IFGEIW	D0,#IdxRecSize,4$	;okay...will fit
	IFNZL	Level3Ptr,3$		;already have level 3 node
	MOVEQ	#3,D0
	MOVE.W	D0,BN_TopLevel(A2)	;now at level 3
	BSR	AddIndexNode		;else add index node
	MOVE.L	D0,BN_RootNode(A2)	;save new root node
	MOVE.L	A0,Level3Ptr		;point to node
3$:	BSR	AddLev3Rec		;move index node key to level3 node
	BSR	AddIndexNode		;and add another index node
	MOVE.L	A0,IndexPtr		;this is node we are currently working
4$:	BSR	AddIndexRec		;move index rec into index node
	MOVE.L	NodePtr,A0
	MOVE.L	NL_FLink(A0),D0		;get link to next leaf node
	BNE.S	2$			;process next leaf node
	BSR	AddLev3Rec		;move final node key into level3 node
	CLR.B	IndexFlag		;index is fixed now
9$:	POP	D2/A2
	RTS

* Makes full index record from leaf record key.  A0 points to leaf
* record key.  Node number in D0.

* Builds index record in index buffer.  Ptr to key to use in A0.
* Node number this index rec points to in D0.

BuildIndexRec:
	LEA	IndexBuffer,A1
	MOVE.B	#IdxKeyLen,(A1)+	;index rec length
	INCL	A0			;skip length from key
	MOVEQ	#4,D1			;move next 5 bytes
1$:	MOVE.B	(A0)+,(A1)+
	DBF	D1,1$
	ZAP	D1
	MOVE.B	(A0)+,D1		;get name length
	MOVE.B	D1,(A1)+		;move it
	BEQ.S	4$
	DECW	D1			;for dbf
2$:	MOVE.B	(A0)+,(A1)+		;copy name byte
	DBF	D1,2$			;loop for all bytes of name
4$:	MOVEQ	#IdxRecSize-4,D1
	ADD.L	#IndexBuffer,D1
	SUB.L	A1,D1			;this many fill bytes needed
	DECW	D1
3$:	CLR.B	(A1)+
	DBF	D1,3$
	MOVE.L	D0,(A1)+		;store node link
	RTS

* Adds index record as last record of current index node.  We already know
* there is room, so just blast away!  

AddIndexRec:
	PUSH	D2/A2
	MOVE.L	IndexPtr,A2		;point to node
	INCW	NL_NbrRecs(A2)		;one more record in node
	MOVE.W	NL_NbrRecs(A2),D2	;this is where new one goes
	MOVE.L	A2,A0
	MOVE.W	D2,D0
	BSR	SetRecPtr		;point to record
	LEA	IndexBuffer,A1		;copy record from buffer
	MOVEQ	#IdxRecSize-1,D1	;this many bytes
1$:	MOVE.B	(A1)+,(A0)+		;do it
	DBF	D1,1$
	MOVE.L	A0,D0
	SUB.L	A2,D0			;calc new free space offset
	LEA	510(A2),A0
	LSL.W	#1,D2			;word index
	NEG.W	D2
	MOVE.W	D0,0(A0,D2.W)		;store new free space offset
	POP	D2/A2
	RTS

* Moves index record from current index node into Level 3 index node.
* We already know there is enough room, so just go for it.
* If there is no level3 node, this routine does nothing.

AddLev3Rec:
	PUSH	D2/A2
	MOVE.L	Level3Ptr,A2
	IFZL	A2,9$			;no level 3 node...ignore
	INCW	NL_NbrRecs(A2)		;one more record in node
	MOVE.W	NL_NbrRecs(A2),D2	;this is where new one goes
	MOVE.L	IndexPtr,A0
	MOVEQ	#1,D0			;first rec of index node
	BSR	SetRecPtr
	MOVE.L	A0,A1			;this is source for move
	MOVE.L	A2,A0
	MOVE.W	D2,D0
	BSR	SetRecPtr		;point to dest record
	MOVEQ	#IdxRecSize-5,D1	;leave room for index node ptr
1$:	MOVE.B	(A1)+,(A0)+		;do it
	DBF	D1,1$
	MOVE.L	A0,A1
	MOVE.L	IndexPtr,A0
	BSR	AddrNode		;get node number for index node
	MOVE.L	D0,(A1)+		;store node ptr
	MOVE.L	A1,D0
	SUB.L	A2,D0			;calc new free space offset
	LEA	510(A2),A0
	LSL.W	#1,D2			;word index
	NEG.W	D2
	MOVE.W	D0,0(A0,D2.W)		;store new free space offset
9$:	POP	D2/A2
	RTS

* Quickly frees all index nodes by simply scanning the entire list of nodes.
* After all, there are only 12 or 24 (normally).

FreeIndexNodes:
	PUSH	D2/A2
	MOVE.L	BaseNodePtr,A2
	MOVE.L	BN_MaxNodes(A2),D2	;tot nbr of nodes to check
1$:	DECW	D2			;0 origin
	BEQ.S	9$			;dont touch base node
	MOVE.W	D2,D0			;this is node to check
	BSR	NodeAddr		;get ptr to node
	IFNZB	NL_Type(A0),1$		;not an index node...must be 0
	IFEQIB	NL_Level(A0),#1,1$	;leaves are always level 1
	MOVE.W	D2,D0
	BSR	FreeNode		;mark node free
	BRA.S	1$
9$:	POP	D2/A2
	RTS

* Allocates and inits catalog index node.  Index level in D0.

AddIndexNode:
	PUSH	D2
	MOVE.W	D0,D2			;save level
	BSR	AllocFreeNode		;find a free node
	ERROR	9$
	MOVE.W	D2,D1			;level
	MOVE.W	D0,D2			;save node number
	ZAP	D0			;node type=0
	BSR	InitNode		;set up index node
	MOVE.W	D2,D0			;node number	
9$:	POP	D2
	RTS


***************************************************************************

* The following routines are general to either the catalog or extent trees.
* BaseNodePtr points to the base node of the proper tree.

* Node record routines
* Rigister usage:
*	D3= node length
*	D4= leaf record type
*	D5= number of leaf nodes
*	D6= record counter in node
*	D7= 9 ... shift count
*	A0= key ptr
*	A1= record ptr
*	A4= basenode ptr
*	A5= current node ptr

* Called to initialize node record parameters.
* Called with tree ptr in A0.

InitSearch:
	MOVE.L	A0,BaseNodePtr
	MOVE.L	A0,A4
	MOVE.W	BN_NodeSize(A4),D3	;node size
	MOVEQ	#9,D7			;for shifting
	NodeLnk	BN_FLink(A4),A5		;point to first leaf node
	MOVE.L	BN_LeafRecs(A4),D5	;active leaf records
	BNE.S	1$
	STC				;no leaves
	BRA.S	9$
1$:	BSR	GetFirstLeafRec		;get root dir record
9$:	RTS


* Returns next record from current node or advances to next leaf node.
* A5 points to current node, D6=current record number in node.
* D5 is count of leaf nodes remaining.
* Returns A0=ptr to record key, A1=ptr to record, and record number in D0.
* CY=1 if node is not a leaf node or node count exhausted.

NextLeafNode:
	NodeLnk	NL_FLink(A5),A5		;else advance to next node
	IFZL	A5,GFer			;bad linkage...bail out
GetFirstLeafRec:
	IFNEIB	NL_Type(A5),#$FF,GFer	;this is NOT a leaf node
	ZAP	D6
GetNextLeafRec:
	IFZW	D5,GFer			;no more leaf records
	INCW	D6			;bump record number
	IFLTW	NL_NbrRecs(A5),D6,NextLeafNode ;no more records...try next node
	MOVE.L	A5,A1			;base of node
	ADD.W	D3,A1			;point to end of node
	SUB.W	D6,A1			;back up to proper record offset
	SUB.W	D6,A1
	MOVE.L	A5,A0
	ADDA.W	(A1),A0			;point to record key
	MOVE.L	A0,A1			;point A1 to start of record data
	ZAP	D0
	MOVE.B	(A1)+,D0		;skip over key
	ADD.L	A1,D0
	INCW	D0
	BCLR	#0,D0
	MOVE.L	D0,A1			;A1 points to actual record
	DECW	D5			;one less leaf rec left
	RTS

GFer:	STC				;oops...someting wrong
	RTS

* Inserts new record as last record of leaf node.
* LeafPtr points to leaf where addition is to occur.
* BaseNodePtr points to base node of tree.

AddLeafRecord:				;insert as new last record
	PUSH	D2-D3/A2
	MOVE.L	LeafPtr,A2
	MOVE.W	NL_NbrRecs(A2),D3	;count of existing records
	INCW	D3			;force new record to end
	MOVE.W	RecordLen,D2		;size of new rec
	MOVE.L	A2,A0			;leaf node
	BSR	GetNodeSpace		;get size of free space in leaf
	IFGEW	D0,D2,1$		;leaf has room...just insert rec
;	MOVE.W	D3,D0			;new record gets this number
	BSR	AddLeafNode		;else must add a new leaf
	ERROR	9$
	MOVE.L	A0,LeafPtr		;this is now current leaf
	MOVE.L	A0,A2
	MOVEQ	#1,D3			;going to go into record 1
1$:	MOVE.W	D2,D1			;size of record to be added
	MOVE.W	D3,D0			;starting at this record
	MOVE.L	A2,A0
	BSR	InsertOneRec		;move recs down in leaf
	MOVE.W	D2,D1			;move this many bytes
	MOVE.W	D3,D0			;into this record in leaf
	LEA	RecordBuffer,A1		;this is record to add
	MOVE.L	A2,A0			;into this leaf
	BSR	MoveRecIntoLeaf		;put that sucker into leaf
	MOVE.L	BaseNodePtr,A0
	INCL	BN_LeafRecs(A0)		;one more leaf rec
	MOVE.W	D3,D0
	MOVE.L	A2,A0
	BSR	SetRecPtr		;point A0 to new record
	CLC
9$:	POP	D2-D3/A2
	RTS

* Inserts new leaf record in front of record D0 (1 origin) in leaf node.
* LeafPtr points to leaf where addition is to occur.
* BaseNodePtr points to base node of tree.

InsertLeafRecord:			;insert in front of rec D0
	PUSH	D2-D3/A2-A3
4$:	MOVE.W	D0,D3			;insert in front of this rec
	IFNEIW	D0,#1,1$		;not going into rec 1
	SETF	IndexFlag		;else need to reorg index
1$:	MOVE.L	LeafPtr,A2
	MOVE.W	RecordLen,D2		;size of new rec
	MOVE.L	A2,A0			;leaf node
	BSR	GetNodeSpace		;get size of free space in leaf
	IFGEW	D0,D2,3$		;leaf has room...just insert rec
	BSR	AddLeafNode		;else must add a new leaf and index
	ERROR	9$
	MOVE.L	A0,A3			;save ptr to new leaf
2$:	MOVE.L	A3,A0			;ptr to new leaf
	BSR	CopyLastRec		;move last record from old into new
	MOVE.L	A2,A0			
	BSR	GetNodeSpace		;now is there enough room?
	IFLTW	D0,D2,2$		;no...get a bit more
	BSR	UpdateIndexStruct
	LEA	RecordBuffer,A0		;record to insert is here
	BSR	SearchTree		;find place to insert in REVISED tree
	ERROR	5$			;no insert pos found
	BEQ.S	5$			;exact match...bad awful
	MOVE.L	A0,LeafPtr		;insert into this leaf
	MOVE.W	D0,LeafRec
	BRA	4$
5$:	STC
	BRA.S	9$
3$:	MOVE.W	D2,D1			;make this much room
	MOVE.W	D3,D0			;starting at this record
	MOVE.L	A2,A0			;insert into this leaf
	BSR	InsertOneRec		;move recs down in leaf
	MOVE.W	D2,D1			;insert this many bytes
	MOVE.L	D3,D0			;into this record in leaf
	LEA	RecordBuffer,A1		;record data ptr
	MOVE.L	A2,A0
	BSR	MoveRecIntoLeaf		;put that sucker into leaf
	MOVE.L	BaseNodePtr,A2
	INCL	BN_LeafRecs(A2)		;one more leaf rec
9$:	POP	D2-D3/A2-A3
	RTS

* Copies last record from LeafPtr node into node in A0, freeing space in
* old node.

CopyLastRec:
	PUSH	D2-D4/A2-A3
	MOVE.L	A0,A2			;save ptr to new node
	MOVE.L	LeafPtr,A0		;ptr to old node
	MOVE.W	NL_NbrRecs(A0),D0	;get number of last record
	DECW	NL_NbrRecs(A0)		;one fewer now
	BSR	SetPtrLen		;point A0 at record data and get len
	MOVE.L	A0,A3			;save ptr to data
	MOVE.W	D0,D3			;save size of record to move
	MOVEQ	#1,D0			;insert in front of rec 1
	MOVE.L	A2,A0			;in new leaf
	MOVE.W	D3,D1			;this many bytes
	BSR	InsertOneRec		;make room for record in new leaf
	MOVE.L	A3,A1			;move record data from here
	MOVE.L	A2,A0			;into new leaf node
	MOVE.W	D3,D1			;this many bytes
	MOVEQ	#1,D0			;move into rec 1 of new leaf
	BSR	MoveRecIntoLeaf		;move record into new leaf
	POP	D2-D4/A2-A3
	RTS

* Moves record data A1 with length D1 into leaf A0 at record number 
* D0 (1 origin).

MoveRecIntoLeaf:
	PUSH	D2/A2
	MOVE.L	A1,A2			;save leaf address
	MOVE.W	D1,D2			;save byte count
	BSR	SetRecPtr		;set A0 to first byte of record
	DECW	D2			;count of bytes to move
1$:	MOVE.B	(A2)+,(A0)+
	DBF	D2,1$
	POP	D2/A2
	RTS

* Sets A0 to record data and D0 to length of record (valid only for
* actual record), given leaf in A0 and record number in D0.

SetPtrLen:
	PUSH	D2/A2-A3
	MOVE.W	D0,D2			;save record number
	MOVE.L	A0,A2			;save leaf node
	INCW	D0			;advance to next rec or free space
	BSR.S	SetRecPtr		;point to next record data
	MOVE.L	A0,A3			;save it
	MOVE.L	A2,A0
	MOVE.W	D2,D0
	BSR.S	SetRecPtr		;point to desired rec
	MOVE.L	A3,D0
	SUB.L	A0,D0			;calc length of record
	POP	D2/A2-A3
	RTS

* Returns ptr to first byte of record in A0, given record number in D0 and
* leaf ptr in A0.  Also returns size of record in D0.
* 

SetRecPtr:
	LSL.W	#1,D0			;index by word
	NEG.W	D0			;negative index
	ADD.W	#512,D0
	ADD.W	0(A0,D0.W),A0		;offset to data
	RTS

* Moves existing records in A0 leaf down by D1 bytes, starting at record D0,
* to make room for a new record.  Also handles adding record to end
* of list, in which case D0 must be 1 greater than node record count.
* Adding to empty node is same as adding to end of list.

InsertOneRec:
	PUSH	D2-D4/A2
	MOVE.W	D0,D3			;save rec number we want to use
	MOVE.L	A0,A2			;point to leaf node for move
	MOVE.W	NL_NbrRecs(A2),D2	;active record count
	INCW	D2			;one more record
	MOVE.W	D2,NL_NbrRecs(A2)	;update record count
	IFEQW	D2,D3,3$		;adding record to end of list
	BSR	SetRecPtr		;point to rec we want to use
	MOVE.L	A0,D4			;save ptr for length calc
	MOVE.W	D2,D0			;"rec" number for free space
	MOVE.L	A2,A0
	BSR	SetRecPtr		;point to free area	
	MOVE.L	A0,D0
	SUB.L	D4,D0			;must move this many bytes
	BEQ.S	3$			;none...inserting at end?
	MOVE.L	A0,A1
	ADD.W	D1,A1			;move up to here
	DECW	D0
1$:	MOVE.B	-(A0),-(A1)
	DBF	D0,1$			;do it
3$:	MOVE.W	D2,D0
	SUB.W	D3,D0			;calc recs moved
	MOVE.W	D0,D3
	LSL.W	#1,D2			;word index
	NEG.W	D2			;negative index
	LEA	510(A2),A0
2$:	MOVE.W	2(A0,D2.W),D0		;get old rec offset entry
	ADD.W	D1,D0			;add length rec was moved down
	MOVE.W	D0,0(A0,D2.W)		;store as new offset for rec+1
	ADDQ.W	#2,D2			;
	DBF	D3,2$			;loop for recs moved+1
9$:	POP	D2-D4/A2
	RTS

* Deletes leaf record.  A0=node, D0=record number.

DeleteLeafRecord:
	PUSH	D2-D3/A2-A4
	MOVE.L	A0,A2			;save leaf ptr
	MOVE.W	D0,D3			;save rec number to be deleted
	IFNEIW	D0,#1,4$		;not first record of node
	SETF	IndexFlag		;else recalc index
4$:	MOVE.W	NL_NbrRecs(A2),D2	;active record count
	BEQ	9$			;oops...none busy...something wrong
	IFEQW	D3,D2,3$,L		;deleting last rec...thats real easy
	BSR	SetPtrLen		;ptr to rec to delete, get length
	MOVE.L	A0,A3			;save ptr to destination
	MOVE.W	D0,D1			;number of bytes change in pos
	MOVE.L	A0,A4			;source for move
	ADD.W	D0,A4			;point to start of following rec
	MOVE.L	A2,A0
	MOVE.W	D2,D0
	INCW	D0			;last active record+1=free space
	BSR	SetRecPtr		;point to start of free space
	MOVE.L	A0,D0			;calc length of move
	SUB.L	A4,D0
	BEQ.S	3$			;nothing to move???
	DECW	D0
1$:	MOVE.B	(A4)+,(A3)+		;move data
	DBF	D0,1$
	MOVE.W	D2,D0			;calc number of recs moved
	SUB.W	D3,D0
	DECW	D0			;for dbf
	MOVE.W	D0,D2
	INCW	D3			;start with rec after
	LSL.W	#1,D3			;now number of free space offset
	NEG.W	D3
	LEA	510(A2),A0
2$:	MOVE.W	0(A0,D3.W),D0		;get old offset entry
	SUB.W	D1,D0			;adjust for size of rec deleted
	MOVE.W	D0,2(A0,D3.W)		;store adjusted offset
	SUBQ.W	#2,D3
	DBF	D2,2$			;fix offsets
3$:	MOVE.L	BaseNodePtr,A0
	DECL	BN_LeafRecs(A0)		;one less leaf rec
	DECW	NL_NbrRecs(A2)		;one less active recs
	BNE.S	9$
	MOVE.L	A2,A0
	BSR	DeleteLeafNode		;free the node
9$:	POP	D2-D3/A2-A4
	RTS

* Adds leaves to tree.  BaseNodePtr points to base node of tree.
* Returns A0 pointing to added leaf and  CY=1 if anything goes wrong 
* (like running out of nodes).  This routine DOES NOT allocate an 
* additional extent if tree becomes full.  This is a future enhancement.

AddFirstLeaf:
	BSR	AllocFreeNode		;scan node bitmap for free node
	ERROR	9$			;no more nodes...bad awful
	MOVE.L	BaseNodePtr,A1
	MOVE.L	D0,BN_FLink(A1)		;set up basenode linkage
	MOVE.L	D0,BN_BLink(A1)
	MOVE.L	D0,BN_RootNode(A1)
	MOVE.B	#$FF,D0			;type=leaf
	MOVEQ	#1,D1			;level
	MOVE.W	D1,BN_TopLevel(A1)	;top level is leaf level
	BSR	InitNode		;initialize node
9$:	RTS

* Adds new leaf node to chain of leaves AFTER node in LeafPtr.  
* Returns address of new node in A0, node number
* in D0, or CY=1 on any error.

AddLeafNode:
	PUSH	D2/A2
	BSR	AllocFreeNode		;scan node bitmap for free node
	ERROR	9$			;no more nodes
	MOVE.L	D0,D2			;save new node number
	MOVE.L	A0,A2			;new node address	
	MOVE.B	#$FF,D0			;type=leaf
	MOVEQ	#1,D1			;level
	BSR	InitNode		;initialize node
	MOVE.L	LeafPtr,A0		;get addr of old node to link it
	BSR	AddrNode		;convert A0 to node number in D0
	MOVE.L	D0,NL_BLink(A2)		;set new leaf back link to old node
	MOVE.L	NL_FLink(A0),D0		;this is node we have to fix
	MOVE.L	D0,NL_FLink(A2) 	;forward link to new node
	MOVE.L	D2,NL_FLink(A0)		;old leaf links to new
	BSR	NodeAddr		;convert fol leaf node nbr in D0 addr
	IFNZW	D0,1$			;not node 0
	ADD.W	#BN_FLink,A0		;else point to leaf linkage
1$:	MOVE.L	D2,NL_BLink(A0)		;his back link points to new leaf
	MOVE.L	D2,D0			;node number of new leaf
	MOVE.L	A2,A0
	SETF	IndexFlag		;need to fix index
9$:	POP	D2/A2
	RTS

* Deletes leaf node in A0 from linked list and frees it.

DeleteLeafNode:
	PUSH	D2-D3/A2-A4
	MOVE.L	A0,A2
	MOVE.L	NL_FLink(A0),D2		;number of following node
	MOVE.L	NL_BLink(A0),D3		;number of preceeding node
	MOVE.W	D2,D0
	BSR	NodeAddr		;get ptr to following node
	IFNZW	D0,1$			;not node 0
	ADD.W	#BN_FLink,A0		;else point to leaf linkage
1$:	MOVE.L	D3,NL_BLink(A0)		;fix up back link
	MOVE.W	D3,D0
	BSR	NodeAddr		;get ptr to following node
	IFNZW	D0,2$			;not node 0
	ADD.W	#BN_FLink,A0		;else point to leaf linkage
2$:	MOVE.L	D2,NL_FLink(A0)		;fix up fwd link
	MOVE.L	A2,A0
	BSR	AddrNode		;get this node number
	BSR	FreeNode		;mark it free
	SETF	IndexFlag
	POP	D2-D3/A2-A4
	RTS

* Allocates first index node and inits it as root node.  Returns
* ptr to node in A0 or CY=1.

AddFirstIndex:
	BSR	AllocFreeNode		;scan node bitmap for free node
	ERROR	9$			;no more nodes...bad awful
	MOVE.L	BaseNodePtr,A1
	MOVE.L	D0,BN_RootNode(A1)	;set up basenode linkage
	ZAP	D0			;type=index
	MOVEQ	#2,D1			;level
	MOVE.W	D1,BN_TopLevel(A1)	;new top level
	BSR	InitNode		;initialize node
9$:	RTS


* Converts node number in D0 to node address in A0.
* Preserves D0.

NodeAddr:
	PUSH	D0
	MOVEQ	#9,D1
	LSL.W	D1,D0
	ADD.L	BaseNodePtr,D0
	MOVE.L	D0,A0
	POP	D0
	RTS
	
* Converts node address in A0 to node number in D0.

AddrNode:
	MOVEQ	#9,D1
	MOVE.L	A0,D0
	SUB.L	BaseNodePtr,D0
	LSR.L	D1,D0
	RTS

* Allocates a free node from pool for tree.  Marks node busy and
* returns ptr in A0, with node number (0-origin) in D0.  CY=1 if
* no free nodes.

AllocFreeNode:
	PUSH	D2/A2-A3
	MOVE.L	BaseNodePtr,A2		;this is base we work
;	IFZL	BN_FreeNodes(A2),8$	;no free nodes...so sorry!
	IFNZL	BN_FreeNodes(A2),1$	;there are free nodes
	MOVE.L	A2,A0			;pass tree ptr
	BSR	AddCatExtent		;try to allocate another cat extent
	ERROR	8$			;no go...bail out now
1$:	DECL	BN_FreeNodes(A2)	;else one fewer NOW
	LEA	506(A2),A1		;point to bitmap offset
	MOVE.L	A2,A0
	ADD.W	(A1),A0			;point to bitmap
	MOVE.L	BN_MaxNodes(A2),D0	;max number of nodes in bitmap
	BSR	AllocBitMap		;get a free bitmap entry
	ERROR	8$			;oops...
	MOVEQ	#9,D2
	MOVE.W	D0,D1			;node number in D0
	LSL.W	D2,D1			;offset by node length
	MOVE.L	A2,A0			;base node here
	ADD.W	D1,A0			;point to real node address
	BRA.S	9$
8$:	STC
9$:	POP	D2/A2-A3
	RTS

* Releases node in D0 back to node bitmap.

FreeNode:
	MOVE.L	BaseNodePtr,A0		;this is base we work
	MOVE.L	A0,A1
	MOVE.W	#506,D1
	ADD.W	0(A0,D1.W),A1		;point to bitmap
	MOVE.W	D0,D1
	NOT.W	D1
	AND.W	#7,D1
	LSR.W	#3,D0
	BCLR	D1,0(A1,D0.W)		;mark it free
	BEQ.S	9$			;oops...was already free
	INCL	BN_FreeNodes(A0)	;else one more free node
9$:	RTS

* Called to initialize base node for catalog tree and extent tree.
* A0=base of buffer, D0=index key length, D1=max nodes.

BNodeBMap	EQU	248		;FM
BNodeBMapSize	EQU	256		;DITTO

InitBaseNode:
	PUSH	D2/A2
	PUSH	D0-D1
	MOVE.L	A0,A2
	MOVEQ	#1,D0			;base node always 1
	ZAP	D1			;level=0
	BSR.S	InitNode		;do basic init
	MOVE.W	#3,NL_NbrRecs(A0)	;base node always has 3 recs
	LEA	512(A0),A1		;offset area ptr (used by PutOffset)
	LEA	NL_SIZE(A0),A0		;point to first "record"
	BSR.S	PutOffset		;offset to first record
	CLR.W	(A0)+			;top level=0 (not even any leaves)
	CLR.L	(A0)+			;no root nade
	CLR.L	(A0)+			;no leaf recs yet
	CLR.L	(A0)+			;so no FLink or BLink
	CLR.L	(A0)+
	MOVE.W	#512,(A0)+		;node size
	POP	D0-D1
	MOVE.W	D0,(A0)+		;length of index key
	MOVE.L	D1,(A0)+		;max nodes (12?)
	DECL	D1			;one node already used
	MOVE.L	D1,(A0)+		;free nodes (base node is not free)
	LEA	120(A2),A0
	BSR.S	PutOffset		;offset to second record
	LEA	BNodeBMap(A2),A0	;point to bitmap record
	MOVE.B	#$80,(A0)		;one node in use
	BSR.S	PutOffset		;bitmap offset
	ADD.L	#BNodeBMapSize,A0
	BSR.S	PutOffset		;ptr to empty space
	POP	D2/A2
	RTS

* Calculates offset to current rec in node, and stores value in next extry
* in offset table at end of node.  A1 is offset ptr.

PutOffset:
	MOVE.L	A0,D2			;Calc offset
	SUB.L	A2,D2
	MOVE.W	D2,-(A1)		;store into offset table
	RTS

* Initialize node.  Node type in D0, level in D1.
* Node ptr in A0.  Returns node ptr in A0.

InitNode:
	MOVE.L	A0,A1			;ptr to new leaf
	CLR.L	(A1)+			;flink
	CLR.L	(A1)+			;blink
	MOVE.B	D0,(A1)+		;node type
	MOVE.B	D1,(A1)+		;level
	CLR.W	(A1)+			;no recs yet
	CLR.W	(A1)+			;reserved pad
	MOVE.L	A1,D0
	SUB.L	A0,D0			;offset to empty space
	LEA	510(A0),A1		;offset goes here
	MOVE.W	D0,(A1)			;initial "empty" offset
	RTS

* Returns node free space in D0 for node A0.

GetNodeSpace:
	MOVE.W	NL_NbrRecs(A0),D1	;active record count
	LSL.W	#1,D1			;word index
	LEA	510(A0),A1		;use 510 to get free space ptr
	SUB.W	D1,A1			;point to proper record offset
	MOVE.W	(A1),D1			;get offset to start of free space
	MOVE.L	A1,D0
	SUB.L	A0,D0			;offset to free space offset
	SUB.W	D1,D0			;calculate what is left
	SUBQ.W	#2,D0			;leave room for offset
	BPL.S	9$			;positive space?
	ZAP	D0			;no, no room
9$:	RTS

* Clears bytes 4 at a time via A2.  Note: count in D1 MUST be multiple
* of 4.

ZapBytes:
	LSR.W	#2,D1
	DECW	D1
	ZAP	D0
1$:	MOVE.L	D0,(A2)+
	DBF	D1,1$
	RTS

LeafPtr		DC.L	0	;ptr to current leaf node
IndexPtr	DC.L	0	;ptr to current index node
BaseNodePtr	DC.L	0	;ptr to base node of tree
Level3Ptr	DC.L	0	;index level 3 ptr (one only)
NodePtr		DC.L	0	;ptr to current node
NodeRecPtr	DC.L	0	;ptr to current node record
LeafRec		DC.W	0	;number of current leaf record
BlockCount	DC.W	0	;count of blocks for extent tree search
NodeNbr		DC.W	0	;node number of current node
NodeRecCnt	DC.W	0	;count of remaining recs in node
NodeRecNbr	DC.W	0	;record number of current node rec
RecordLen	DC.W	0	;actual length of new record, including key
NodeLevel	DC.B	0	;level of current node (debugging)
NodeType	DC.B	0	;node type of current node (debugging)
IndexFlag	DC.B	0	;1=need to rebuild index

* WARNING - MUST BE ON WORD BOUNDARY

	CNOP	0,2

RecordBuffer:
	DS.B	RecBufSize
IndexBuffer
	DS.B	IdxRecSize

Null.	DC.B	0
Int1.	TEXTZ	<'HFS error 1'>
Int2.	TEXTZ	<'HFS error 2'>
	END
