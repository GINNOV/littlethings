*********************************************************
*							*
*		DOSFILES.ASM				*
*							*
* 	Mac-2-Dos Amiga file system routines		*
*							*
*	Copyright (c) 1989 Central Coast Software	*
*	424 Vista Ave, Golden, CO 80401			*
*	All rights reserved, worldwide			*
*********************************************************

;	INCLUDE	"MAC.I"
;	INCLUDE "VD0:MACROS.ASM"
	INCLUDE	"PRE.OBJ"
	INCLUDE	"boxes.asm"

	XDEF	OpenDosFile,CloseDosFile
	XDEF	ReadDosBlock,WriteDosBlock,DosSeek,WriteDosFile
	XDEF	CreateDosFile,DeleteDosFile
	XDEF	BuildDosPath,BldCurrentDosDir
	XDEF	NewAmyVol
	XDEF	AppendDosPath,TruncateDosPath
	XDEF	CurrentDosPath
	XDEF	FreeDosDirBlocks
	XDEF	ChgOrigDir
	XDEF	SortInsert,CompareNames
	XDEF	ZapLevelBlk,LimitMove
	XDEF	UpdateDosName

	XDEF	DosBuffer
	XDEF	DosRootLevel,DosCurLevel
	XDEF	LOCK,BYTPTR
	XDEF	DosBytCnt,DosFileHandle
	XDEF	DosPath.,DosVolName.
	XDEF	FILE_INFO,FIB_TYPE,FIB_NAME,FIB_SIZE
	XDEF	ValidDosVol
	XDEF	FileName.
	XDEF	DefaultTool.
	XDEF	CantDelFile.

	XREF	BuildDosDir
	XREF	ConvDosDate,ConvMacDate
	XREF	ClearDosFiles
	XREF	DeleteCurFib

	XREF	DosBase,SysBase,IconBase
	XREF	AVOL_INFO
	XREF	TMP.,TMP2.
	XREF	CurFib
	XREF	EofFlag
	XREF	AutoRepFlg
	XREF	PacketIO,PktArg2,PktArg3,PktArg4
	XREF	DupTxt
	XREF	AmyIconFlg
	XREF	AmyDiskObject
	XREF	MotorOff
	XREF	DispDosDir,GetDosVolume
	XREF	FINamBuf
	XREF	InvDosVol.

DEMO	EQU	0	;1=DEMO VERSION, 0=PRODUCTION

LineBufSize	EQU	128		;SIZE OF TEXT BUFFER
;PathSize	EQU	512		;max path size
FileNameLen	EQU	30		;max ADOS file name length
FileLimit	EQU	1000		;max files per dir...looped dir?
ACTION_DATE	EQU	34		;update date/time packet param
do_DefaultTool	EQU	50

DirBlockSize	EQU	2000	;size of directory block

* Called when Amiga dev:path is changed by operator

NewAmyVol:
	BSR	FreeDosDirBlocks	;release previous dir blocks
	CLR.L	DosCurLevel		;make sure we don't point to old dir
	BSR	GetDosVolume
	ERROR	9$
	BSR	CurrentDosPath
	BSR	DispDosDir
9$:	RTS

* Builds standard ADOS current directory.

BldCurrentDosDir:
	PUSH	D2-D7/A2-A5
	CLR.B	ValidDosVol
	BSR	ClearDosFiles
	DispMsg	#RDIR_LE+40,#RDIR_TE+56,ReadDosDir.,WHITE,BLACK
	MOVE.L	#BaseDirBlock,CurDBBase
	BSR	AllocateDirBlock	;allocate first dir block
	BSR	AllocateLevelBlock	;allocate root level block
	ERROR	BuildErr		;memory problem?
	MOVE.L	A1,DosRootLevel		;this is now the root block
	MOVE.L	A1,DosCurLevel		;start at root level
	BSR	ScanDirectory		;scan files of this directory
	ERROR	BuildErr		;bad awful
	SETF	ValidDosVol		;now have a valid volume
	MOVE.L	DosRootLevel,A0		;display current level as root level
	MOVE.L	A0,DosCurLevel
	MOVE.L	dl_ChildPtr(A0),dl_CurFib(A0)
	POP	D2-D7/A2-A5
	RTS

* Error routines for building directories.

BuildErr:
BuildNoMem:
	POP	D2-D7/A2-A5
	BSR	FreeDosDirBlocks	;release memory
	STC				;error return
	RTS

* Builds directory entries current subdirectory.
* Returns CY=1 on error: failure to allocate dir block or loop limit.
* Returns CY=0 at end of dir list for this directory.

ScanDirectory:
	PUSH	A2
	MOVE.L	DosCurLevel,A2
	MOVE.L	#DosPath.,D1
	MOVE.L	#ACCESS_READ,D2
	CALLSYS	Lock,DosBase		;get a lock on this directory
	MOVE.L	D0,LOCK
	BEQ	7$			;no lock...bad path?
	MOVE.L	D0,D1
	MOVE.L	#FILE_INFO,D2
	CALLSYS	Examine
	TST.L	D0
	BEQ	7$			;examine failed...no path
	TST.L	FIB_TYPE		;is it a dir?
	BMI	7$			;no...it is a file
	CLR.W	DirFileCnt		;start with no files
1$:	MOVE.L	LOCK,D1
	MOVE.L	#FILE_INFO,D2
	CALLSYS	ExNext,DosBase		;get next entry
	IFNZL	D0,2$			;there is one...keep going
	MOVE.L	dl_ChildPtr(A2),dl_CurFib(A2)	;reset to beg of list
	MOVE.L	LOCK,D1
	CALLSYS	UnLock
	POP	A2
	RTS				;thats all at this level

* Got an entry...build Fib block

2$:	IFGEIL	CurDBCnt,#df_SIZEOF,3$	;have enuf room for this entry
	BSR	AllocateDirBlock	;else get another block
	ERROR	8$,L			;oops...can't get any
3$:	INCW	DirFileCnt		;else count the file
	IFLEIW	DirFileCnt,#FileLimit,4$
	DispErr	FileLim.		;looping directory?
	BRA	8$
4$:	MOVE.L	CurDBPtr,A1		;point to new block
	MOVE.L	A1,dl_ScanPtr(A2)	;this fib is now current
	CLR.L	(A1)+			;no linkage yet
	MOVE.L	FIB_SIZE,(A1)+		;copy file size
	MOVE.W	FIB_DATE+2,(A1)+	;file date
	MOVE.W	FIB_TIME+2,(A1)+	;file minutes
	ZAP	D0
	MOVE.L	D0,(A1)+		;file number
	MOVE.W	D0,(A1)+		;leave room for df_FilCnt, convtype
	MOVE.L	FIB_PROT,D0
	TST.L	FIB_TYPE		;a file?
	BMI.S	5$			;yes
	BSET	#7,D0			;else show it as dir
5$:	MOVE.B	D0,(A1)+		;store flags and prot bits
	LEA	FIB_NAME,A0
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
	MOVE.L	dl_ScanPtr(A2),dl_ChildPtr(A2)	;else set it now
	BRA	1$			;no sort needed...1st entry at level
6$:	BSR	SortInsert		;else insert into list
	BRA	1$			;and loop

7$:	MOVE.L	dl_DirLock(A2),D1	;error exit
	CALLSYS	UnLock
	DispErr	DiskBad.		;disk corrupted
8$:	STC
	POP	A2
	RTS

* Moves null-terminated string A0 into buffer A1 up to number of chars in D0.
* Inserts null if limit reached.

LimitMove:
	PUSH	A2
	MOVE.L	A1,A2
	CLR.B	(A1)+			;make room for length
1$:	MOVE.B	(A0)+,(A1)+
	BEQ.S	9$
	ADD.B	#1,(A2)			;count the char
	DBF	D0,1$
	CLR.B	(A1)+			;put in a null if limit reached
9$:	POP	A2
	RTS

* Inserts new FIB into chain at proper place, depending upon name.  Dirs
* sort ahead of files.  A2 points to level block.  New FIB in dl_ScanPtr.

SortInsert:
	PUSH	A3
	LEA	dl_ChildPtr(A2),A1	;point to "head" of chain
	MOVE.L	dl_ScanPtr(A2),A0	;points to new FIB
	BTST	#7,df_Flags(A0)		;is new FIB a dir?
	BEQ.S	2$			;no...a file
1$:	MOVE.L	(A1),A3			;got a dir...get (first) next entry
	IFZL	A3,5$			;end of chain...add new FIB to end
	BTST	#7,df_Flags(A3)		;is it a dir?
	BEQ.S	4$			;no...dir goes in front
	BSR	CompareNames		;else check sort order
	BCS.S	4$			;put new FIB in front
	LEA	df_Next(A3),A1		;else advance to next entry
	BRA.S	1$
2$:	MOVE.L	(A1),A3			;a file...get (first) next entry
	IFZL	A3,5$			;end of chain...add new FIB to end
	BTST	#7,df_Flags(A3)		;is it a dir?
	BNE.S	3$			;yes...files go after dirs
	BSR	CompareNames		;else check sort order
	BCS.S	4$			;put new FIB here
3$:	MOVE.L	A3,A1			;advance to next entry
	BRA.S	2$
4$:	MOVE.L	A3,df_Next(A0)		;new one points to old one
	IFNEL	A3,dl_CurFib(A2),5$	;Fib being replaced not top of dir list
	MOVE.L	A0,dl_CurFib(A2)	;else reset top of list also
5$:	MOVE.L	A0,(A1)			;and correct previous linkage
	POP	A3
	RTS

* Compares names of new block (FIB_NAME) to current block (A3).  Returns
* CY=1 if new item sorts ahad of current item.  CY=0 otherwise.

CompareNames:
	PUSH	D7/A0/A3
	LEA	df_Name(A0),A0		;get pointers to name strings
	LEA	df_Name(A3),A3	
	MOVEQ	#$5F,D7			;lc mask
1$:	MOVE.B	(A0)+,D0		;get a byte of new name
	BEQ.S	9$			;new item ended...sort ahead
	AND.B	D7,D0			;make uppercase
	MOVE.B	(A3)+,D1		;get a byte of current name
	AND.B	D7,D1			;make upper case
	IFEQB	D1,D0,1$		;loop if equal
	POP	D7/A0/A3		;else return with CY set properly
	RTS
9$:	POP	D7/A0/A3
	STC				;short return
	RTS

* Allocates memory for directory blocks.

AllocateDirBlock:
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
8$:	DispErr	NoMemory.
	STC
9$:	POP	D0-D1/A0-A1/A6
	RTS

FreeDosDirBlocks:
	PUSH	A2
	BSR	FreeDosBuffer
	MOVE.L	BaseDirBlock,A2		;free the chain of dir blocks
1$:	IFZL	A2,2$			;nothing left in chain
	MOVE.L	A2,A1
	MOVE.L	(A2),A2			;pick up fwd link BEFORE releasing...
	MOVE.L	#DirBlockSize,D0
	CALLSYS	FreeMem,SysBase
	DECB	DirBlkCnt
	BRA.S	1$
2$:	MOVE.L	A2,BaseDirBlock		;show chain released
9$:	POP	A2
	RTS

* Allocates and zaps a level block.  Returns ptr to new level block in A1.

AllocateLevelBlock:
	IFGEIL	CurDBCnt,#dl_SIZEOF,1$	;still room in buffer
	BSR	AllocateDirBlock	;allocate a dir block
	RTSERR				;oops
1$:	MOVE.L	CurDBPtr,A1		;allocate root level block
	MOVEQ	#dl_SIZEOF,D0		;account for size of level block
	ADD.L	D0,CurDBPtr
	SUB.L	D0,CurDBCnt

* WARNING -- fall through

ZapLevelBlk:
	PUSH	A1
	CLR.L	(A1)+
	CLR.L	(A1)+
	CLR.L	(A1)+
	CLR.L	(A1)+
	CLR.L	(A1)+
	CLR.L	(A1)+
	CLR.L	(A1)+
	POP	A1
	RTS

* Opens DOS file for read access whose CurFib is in A1.

OpenDosFile:
	PUSH	D2/A2
	BSR	AllocDosBuffer
	ERROR	8$
	CLR.B	DosWrtFlg		;read=0
	CLR.L	DosCurFib		;no update on close
	CLR.B	EofFlag
	MOVE.L	CurFib,A1		;point to active FIB
	LEA	df_Name(A1),A2
	MOVE.L	A2,D1
	MOVEQ	#ACCESS_READ,D2		;ACCESS READ
	CALLSYS	Lock,DosBase		;TRY TO LOCK THE FILE
	MOVE.L	D0,LOCK
	BEQ	8$
	MOVE.L	D0,D1			;LOCK TO D1
	MOVE.L	#FILE_INFO,D2		;GET INFO BLOCK
	CALLSYS	Examine			;GET DATE TIME STAMP
	PUSH	D0			;SAVE RESULT
	MOVE.L	LOCK,D1			;MEANWHILE UNLOCK THE OBJECT
	CALLSYS	UnLock			;DO IT
	POP	D0
	IFZL	D0,8$			;can't get info
	MOVE.L	FIB_TYPE,D0
	BPL.S	8$			;GOT A DIRECTORY, NOT A FILE
;	MOVE.L	CurFib,A1
;	LEA	df_Name(A1),A1
	MOVE.L	A2,D1
	MOVE.L	#EXISTING,D2		;NOW OPEN IT FOR REAL
	CALLSYS	Open,DosBase		;OPEN ENTIRE STRING, WITH DRIVE AND PATH
	MOVE.L	D0,DosFileHandle
	BNE.S	9$			;FILE open
8$:	FileErr	A2,CantOpenDos.
	STC
9$:	POP	D2/A2
	RTS

* Creates DOS file for write based on name in CurFib.

CreateDosFile:
	PUSH	D2/A2
	BSR	AllocDosBuffer
	ERROR	8$
	SETF	DosWrtFlg		;show write operation
	CLR.L	DosFileSize
	CLR.L	DosCurFib
	MOVE.L	CurFib,A2		;point to active FIB
	MOVE.L	df_Date(A2),D0		;get Mac date/time stamp
	BSR	ConvMacDate		;convert to Amiga format in D0, D1
	MOVE.L	D0,FIB_DATE
	MOVE.L	D1,FIB_TIME
	MOVE.	df_Name(A2),FileName.	;new Dos file name
	BSR	FixFileName		;strip illegal chars and limit
	MOVE.L	DosCurLevel,A2		;check Dos list for matching file name
	LEA	dl_ChildPtr(A2),A2	;point to start of list
1$:	MOVE.L	df_Next(A2),D0		;point to next entry
	BEQ.S	2$			;no more...not in this list
	MOVE.L	D0,A2
	IFNE.	df_Name(A2),FileName.,1$ ;file exists?
	MOVE.L	A2,DosCurFib		;save for later update
	IFNZB	AutoRepFlg,5$		;just replace it, don't even ask
	DispYN	DupTxt			;ask op what to do
	ERROR	9$			;op says skip this one
	BSR	DeleteDosFile
	ERROR	8$
5$:	MOVE.W	FIB_DATE+2,df_Date(A2)	;update date/time stamp in Dos entry
	MOVE.W	FIB_TIME+2,df_Time(A2)
	BRA	3$
2$:	IFGEIL	CurDBCnt,#df_SIZEOF,4$	;have enuf room for this entry
	BSR	AllocateDirBlock	;else get another block
	ERROR	3$,L			;oops...can't get any, just go on
4$:	MOVE.L	CurDBPtr,A1		;point to new block
	MOVE.L	CurFib,A0
	MOVE.L	DosCurLevel,A2
	MOVE.L	A1,dl_ScanPtr(A2)	;this fib is now current
	MOVE.L	A1,DosCurFib
	CLR.L	(A1)+			;no linkage (yet)
	CLR.L	(A1)+			;no file size (yet)
	MOVE.W	FIB_DATE+2,(A1)+	;days since Jan 1, 1978
	MOVE.W	FIB_TIME+2,(A1)+	;mins since midnight
	ZAP	D0
	MOVE.L	D0,(A1)+		;file number
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

3$:	MOVE.L	#FileName.,D1
	MOVE.L	#NEW,D2			;ACCESS CODE
	CALLSYS	Open,DosBase		;OPEN ENTIRE STRING, WITH DRIVE AND PATH
	MOVE.L	D0,DosFileHandle
	BNE.S	9$			;FILE open
8$:	FileErr	#FileName.,CantCreateDos.
	STC
9$:	POP	D2/A2
	RTS

* Called by FileInfo (in DiskCmds) if op changes Dos file name or prot bit.
* New name in FINamBuf and protection bit updated in df_Flags of CurFib.

UpdateDosName:
	PUSH	D2/A2-A3
	MOVE.	FINamBuf,FileName.
	BSR	FixFileName		;strip illegal chars
	LEA	FileName.,A3
	IFZB	(A3),9$,L		;dont try to use null name
	MOVE.L	CurFib,A2
	LEA	df_Name(A2),A0
	MOVE.L	A0,D1			;old name
	MOVE.L	A3,D2			;new name
	CALLSYS	Rename,DosBase		;rename that sucker
	IFZL	D0,9$,L			;error
	MOVE.L	A3,D1
	ZAP	D2
	MOVE.B	df_Flags(A2),D2		;get protection bits
	AND.W	#$3F,D2			;allow 6 bits for now...
	CALLSYS	SetProtection		;a bit dangerous in the wrong hands...
	IFZL	D0,9$,L
	MOVE.L	A3,A0
	BSR	BuildFib		;build an fib entry for file
8$:	BSR	DeleteCurFib
9$:	POP	D2/A2-A3	
	RTS

* Builds and inserts a new fib entry for name in A0.
* Extract additional data from CurFib.
* Returns ptr to new FIB in A0.

BuildFib:
	PUSH	A2-A3
	MOVE.L	A0,A3
	IFGEIL	CurDBCnt,#df_SIZEOF,1$	;have enuf room for this entry
	BSR	AllocateDirBlock	;else get another block
	ERROR	8$			;oops...can't get any, just go on
1$:	MOVE.L	CurDBPtr,A1		;point to new block
	MOVE.L	DosCurLevel,A2
	MOVE.L	A1,dl_ScanPtr(A2)	;this fib is now current
	MOVE.L	A1,DosCurFib
	CLR.L	(A1)+			;no fwd linkage yet
	MOVE.L	CurFib,A0
	ADDQ.L	#4,A0
	MOVEQ	#df_Flags-4,D1		;dont copy fwd linkage
2$:	MOVE.B	(A0)+,(A1)+		;copy CurFib up to flags
	DBF	D1,2$
	MOVE.L	A3,A0
	MOVEQ	#FileNameLen-1,D0	;limit for file names
	BSR	LimitMove
	MOVE.L	A1,D0
	INCL	D0
	ANDI.L	#$FFFFFFFE,D0
	MOVE.L	D0,D1
	SUB.L	CurDBPtr,D1		;get size of this fib
	MOVE.L	D0,CurDBPtr		;allign ptr properly
	SUB.L	D1,CurDBCnt		;add to size of block
	BSR	SortInsert		;insert into list
8$:	MOVE.L	DosCurFib,A0		;return ptr to new FIB
	POP	A2-A3
	RTS

* Reads next sequential block of Dos file into DosBuffer, and stores number
* of bytes in DosBytCnt.  Sets EofFlag on end of file.

ReadDosBlock:
	BSR	MotorOff		;turn off Mac drive, just in case
	PUSH	D2-D3
	READFILE DosFileHandle,DosBuffer,#DosBufSize ;READ FROM AMIGA
	MOVE.L	D0,DosBytCnt		;number of bytes
	BNE.S	1$			;there was some data
	SETF	EofFlag			;else show end of file
1$:	ADDQ.L	#1,D0			;WAS IT -1?
	BNE.S	9$			;no...okay
	STC
9$:	POP	D2-D3
	RTS

* Writes D0 bytes of data from buffer in A0 to current Dos file.
* Called at WriteDosBlock to count bytes in file size, or
* at WriteDosFile to write data w/o counting bytes.

WriteDosBlock:
	ADD.L	D0,DosFileSize		;running byte count
WriteDosFile:
	PUSH	D0/A0
	BSR	MotorOff
	POP	D0/A0
	PUSH	D2-D3
	ZAP	D3
	MOVE.W	D0,D3
	BEQ.S	9$			;NOTHING TO WRITE
	WRITEFILE DosFileHandle,A0,D3
	TST.L	D0
	BPL.S	9$
	STC
9$:	POP	D2-D3
	RTS

* Sets current read/write position in Dos file to value in D0, relative
* to start of file.  D0=0 positions to start of file.

DosSeek:
	PUSH	D2-D3
	MOVE.L	DosFileHandle,D1
	MOVE.L	D0,D2
	MOVEQ	#-1,D3
	CALLSYS	Seek,DosBase
	TST.L	D0
	BPL.S	9$
	STC
9$:	POP	D2-D3
	RTS	

CloseDosFile:
	PUSH	A2
	BSR	MotorOff		;turn off Mac drive
	BSR	FreeDosBuffer
	MOVE.L	DosFileHandle,D1
	BEQ	9$			;NO OPEN HANDLE
	CALLSYS	Close,DosBase		;CLOSE THE FILE
	CLR.L	DosFileHandle
	IFZB	DosWrtFlg,9$,L		;not a write op
	MOVE.L	DosCurFib,A0
	MOVE.L	DosFileSize,df_Size(A0)	;update file size
	BSR	UpdateDateTime		;update date/time stamp on Dos file
	IFZB	AmyIconFlg,9$,L		;don't need an icon
	LEA	AmyDiskObject,A1
	LEA	FileName.,A0
	MOVE.L	#DefaultTool.,do_DefaultTool(A1)
	CALLSYS	PutDiskObject,IconBase	;write the icon file
	IFNZL	D0,1$			;it worked
	FileErr	#FileName.,CantCreateInfo.	;let op know about it
	BRA.S	9$
1$:	MOVE.	FileName.,TMP.
	APPEND.	Info.,TMP.
	MOVE.L	DosCurLevel,A2		;check Dos list for matching file name
	LEA	dl_ChildPtr(A2),A2	;point to start of list
2$:	MOVE.L	df_Next(A2),D0		;point to next entry
	BEQ.S	3$			;no more...not in this list
	MOVE.L	D0,A2
	IFNE.	df_Name(A2),TMP.,2$ 	;no match
	BRA.S	9$			;else dont add another fib
3$:	LEA	TMP.,A0			;so add it to list
	BSR	BuildFib		;build a new fib entry for icon
	MOVE.L	#900,df_Size(A0)	;force size to some reasonable number
	BCLR	#6,df_Flags(A0)		;make sure it is deselected
9$:	CLR.L	DosFileHandle
	POP	A2
	RTS

* DELETES ADOS FILE IN CurFib.  Returns CY=1 on failure.

DeleteDosFile:
	PUSH	A2
	BSR	MotorOff
	MOVE.L	CurFib,A0
	LEA	df_Name(A0),A2	
	MOVE.L	A2,D1
	CALLSYS	DeleteFile,DosBase	;DELETE AD FILE
	IFNZL	D0,9$			;succeeded
	MOVE.L	A2,A0
	FileErr A0,CantDelFile.		;ELSE WARN OP THAT IT FAILED
	STC
9$:	POP	A2
	RTS

* Makes the current path the current dir.  Returns old dir, if you care.

CurrentDosPath:
	MOVE.L	DosBase,A6
;;	MOVE.L	LOCK,D1
;;	BEQ.S	1$
;;	CALLSYS	UnLock
;;	CLR.L	LOCK
;;1$:
	MOVE.L	#DosPath.,D1
	MOVEQ	#ACCESS_READ,D2		;ACCESS-READ
	CALLSYS	Lock			;lock the current path
	MOVE.L	DosCurLevel,A0
	MOVE.L	D0,LOCK
	BEQ.S	9$			;no lock...problem with path
	MOVE.L	D0,D1
	CALLSYS	CurrentDir		;make it current
	IFNZL	OriginalDir,2$		;already have lock for orig dir
	MOVE.L	D0,OriginalDir
	BRA.S	3$
2$:	MOVE.L	D0,D1
	CALLSYS	UnLock			;Unlock this one...no longer needed
3$:	CLC
	RTS
9$:	DispErr	CurPathErr.
	STC
	RTS

* Restores original current directory, if any

ChgOrigDir:
	MOVE.L	DosBase,A6
;;	MOVE.L	LOCK,D1
;;	BEQ.S	1$
;;	CALLSYS	UnLock
;;	CLR.L	LOCK
;;1$:
	MOVE.L	OriginalDir,D1		;make sure we are back where we belong
	BEQ.S	2$			;nothing
	CALLSYS	CurrentDir
	CLR.L	OriginalDir
	MOVE.L	D0,D1
	CALLSYS	UnLock			;unlock the other dir
2$:	RTS

* Opens dev:path specified (or current dir).  Finds volume name
* and sets up path buffer.  Starts with dev:path from DosVolName..

BuildDosPath:
	CLR.B	DosPath.		;start with empty path
	IFZB	DosVolName.,8$		;null...don't add ':'
	IFLCEQ.	DosVolName.,#':',8$	;already have trailing ':'
	ACHAR.	#':',DosVolName.	;else add one
8$:	MOVE.L	#DosVolName.,D1
	MOVEQ	#ACCESS_READ,D2		;READ ACCESS
	CALLSYS	Lock,DosBase		;get lock on desired dir, if any
	TST.L	D0	
	BNE.S	1$
;	DispErr	VolErr.
	DispErr	InvDosVol.
	STC
	RTS
1$:	MOVE.L	D0,LOCK
	MOVE.L	D0,D1
	MOVE.L	#FILE_INFO,D2
	CALLSYS	Examine			;look at current dir
	TST.L	D0
	MOVE.	FIB_NAME,TMP.
	ACHAR.	#'/',TMP.		;ADD '/' TO NAME
	IFZB	DosPath.,2$		;NO PATH IN PLACE
	APPEND. DosPath.,TMP.
2$:	MOVE.	TMP.,DosPath.
	MOVE.L	LOCK,D1			;IN ROOT YET?
	BEQ.S	4$			;YES
	CALLSYS	ParentDir		;NO...GET PARENT DIR
	TST.L	D0			;GOT A VALID LOCK?
	BNE.S	1$			;YES...GO AGAIN
4$:	MOVE.	FIB_NAME,DosVolName.
	LEN.	DosVolName.
	LEA	AVOL_INFO,A0
	MOVE.W	D0,si_BufferPos(A0)
	MOVE.W	D0,si_NumChars(A0)
	IFZB	DosPath.,6$		;nothing in path
	LEA	DosPath.,A0
3$:	MOVE.B	(A0),D1
	BEQ.S	7$
	CMP.B	#'/',D1			;FOUND "/"?
	BEQ.S	5$			;YES
	INCL	A0
	BRA.S	3$
7$:	MOVE.B	#':',(A0)+
	CLR.B	(A0)
	BRA.S	6$
5$:	MOVE.B	#':',(A0)
6$:	MOVE.L	LOCK,D1
	CALLSYS	UnLock			;RELEASE LOCK
	CLC
	RTS

* Appends name pointed to by A0 to DosPath.  Limits DosPath. to PathSize.

AppendDosPath:
	MOVE.W	#PathSize-3,D1		;max path with room for '/' and null
	LEA	DosPath.,A1
1$:	TST.B	(A1)
	BEQ.S	2$			;end of DosPath.?
	INCL	A1			;no
	DBF	D1,1$			;keep searching
	RTS				;oops...already too long
2$:	MOVE.B	(A0)+,(A1)+		;add a new char
	DBEQ	D1,2$			;loop till end of new string or limit
	DECL	A1
	MOVE.B	#'/',(A1)+		;trailing slash
	CLR.B	(A1)			;null term
	RTS

TruncateDosPath:
	MOVE.	DosVolName.,TMP.
	ACHAR.	#':',TMP.
	IFEQ.	DosPath.,TMP.,4$
	LEA	DosPath.,A0		;point to path
	MOVE.L	A0,A1
1$:	TST.B	(A0)+			;find the end of it
	BNE.S	1$
	DECL	A0
	DECL	A0
2$:	MOVE.B	-(A0),D0		;get previous char
	IFEQIB	D0,#':',3$		;thats it...
	IFNEIB	D0,#'/',2$		;no...loop
3$:	IFLEL	A0,A1,4$		;out of range of DosPath.
	CLR.B	1(A0)			;else terminate string here
	RTS
4$:	STC
	RTS

* Updates date/time stamp on Dos file after it is closed.

UpdateDateTime:
	PUSH	A2
	MOVE.L	DosCurFib,A0
	MOVE.W	df_Date(A0),FIB_DATE+2
	BEQ	9$			;no date...leave it alone
	MOVE.W	df_Time(A0),FIB_TIME+2
	BEQ.S	9$			;no time
	CLR.L	FIB_TICK
	MOVE.	df_Name(A0),TMP.
	MOVE.L	#TMP.,D1
	CALLSYS	DeviceProc,DosBase	;get proc id for this file
	IFZL	D0,9$			;none...bail out
	MOVE.L	D0,A2			;save proc id
	CALLSYS	IoErr			;get lock
	MOVE.L	D0,PktArg2		;to packet
	Z_STG.	TMP.,TMP2.
	MOVE.L	#TMP2.,D0
	LSR.L	#2,D0			;make a BSTR out of path
	MOVE.L	D0,PktArg3
	MOVE.L	#FIB_DATE,PktArg4	;date stamp table
	MOVE.L	#ACTION_DATE,D0		;update file date
	MOVE.L	A2,A0
	BSR	PacketIO
9$:	POP	A2
	RTS

* Strips illegal chars "/" and ":" from FileName. and limits to
* 30 chars.  Leaves corrected name in FileName.

FixFileName:
	LEA	FileName.,A0
	MOVE.L	A0,A1
	MOVEQ	#FileNameLen-1,D1
1$:	MOVE.B	(A0)+,D0
	BEQ.S	3$
	IFEQIB	D0,#':',1$		;strip out colon
	IFEQIB	D0,#'/',1$		;also slash
	MOVE.B	D0,(A1)+		;so store it already
	DBF	D1,1$			;and loop
3$:	CLR.B	(A1)			;terminate with null
	RTS

AllocDosBuffer:
	IFNZL	DosBuffer,9$		;dont need another
	MOVE.L	#DosBufSize,D0
	ZAP	D1
	CALLSYS	AllocMem,SysBase	;allocate Mac alloc block buffer
	MOVE.L	D0,DosBuffer
	BNE.S	9$
	STC
9$:	RTS

FreeDosBuffer:
	MOVE.L	DosBuffer,A1
	IFZL	A1,2$
	MOVE.L	#DosBufSize,D0
	CALLSYS	FreeMem,SysBase
	CLR.L	DosBuffer
2$:	RTS

* LOCAL DATA

DosBuffer	DC.L	0	;points to allocated Dos buffer
BaseDirBlock	DC.L	0	;points to first allocated dir block
CurDBBase	DC.L	0	;base of current dir block
CurDBPtr	DC.L	0	;dir block ptr
CurDBCnt	DC.L	0	;count of remaining bytes in dir block
DosRootLevel	DC.L	0	;root level pointer
DosCurLevel	DC.L	0	;ptr to current level
OriginalDir	DC.L	0	;lock on original dir
DosFileSize	DC.L	0	;local write byte count
DirFileCnt	DC.W	0	;count of DOS files in one dir
DosFileHandle	DC.L	0	;AMIGA-DOS FILE HANDLE
BLKPTR		DC.L	0	;BLOCK BUFFER POINTER
BYTPTR		DC.L	0
DosBytCnt	DC.L	0	;NUMBER OF BYTES IN BLOCK BUFFER
DosCurFib	DC.L	0	;CurFib on Dos writes for updates after
BLOCK		DC.W	0	;CURRENT BLOCK DURING Mac READ/WRITE
PREVBLK		DC.W	0	;PREVIOUSLY WRITTEN BLOCK 
DirBlkCnt	DC.B	0	;count of directory blocks
ValidDosVol	DC.B	0	;1=Dos volume is valid
DosWrtFlg	DC.B	0	;1=write operation

NoMemory.	TEXTZ	<'Out of memory...aborting.'>
;VolErr.	TEXTZ	<'Amiga volume undefined.'>
CurPathErr.	TEXTZ	<'Amiga path error.'>
CantDelFile.	TEXTZ	<'Can''t delete protected file:'>
CantOpenDos.	TEXTZ	<'Unable to open Amiga file:'>
CantCreateInfo.	TEXTZ	<'Unable to create icon for file:'>
CantCreateDos.	TEXTZ	<'Unable to create Amiga file:'>
FuncNotAvail.	TEXTZ	<'Function not yet implemented.'>
DiskBad.	TEXTZ	<'Amiga directory error: garbage.'>
FileLim.	TEXTZ	<'Amiga directory error: looping.'>
Info.		TEXTZ	<'.info'>
ReadDosDir.	TEXTZ	<'Loading Amiga directory...'>

* LOCAL DATA BUFFERS

	SECTION	MEM,BSS

	CNOP	0,4

FILE_INFO:			;AMIGA-DOS FILE INFO BLOCK
FIB_KEY		DS.L	1	;DISK BLOCK
FIB_TYPE 	DS.L	1	;<0=FILE, >1=DIRECTORY
FIB_NAME 	DS.L	27	;NULL-TERMINATED NAME STRING (108 BYTES)
FIB_PROT 	DS.L	1	;PROTECTION
FIB_ETYP 	DS.L	1	;?
FIB_SIZE 	DS.L	1	;SIZE IN BYTES
FIB_BLKS 	DS.L	1	;SIZE IN BLOCKS
FIB_DATE 	DS.L	1	;DAYS SINCE JAN 1, 1978
FIB_TIME	DS.L	1	;MINUTES OF DAY
FIB_TICK 	DS.L	1	;TICKS OF MINUTE
FIB_COMM 	DS.L	29	;NULL-TERMINATED COMMENT STRING (116 BYTES)

LOCK		DS.L	1	;LOCK VALUE
FileName.	DS.B	35	;leave a bit of room...just in case
DosVolName.	DS.B	MaxDosVolName
DirName.	DS.B	31
DosPath.	DS.B	PathSize
DefaultTool.	DS.B	65	;default tool name

	END
