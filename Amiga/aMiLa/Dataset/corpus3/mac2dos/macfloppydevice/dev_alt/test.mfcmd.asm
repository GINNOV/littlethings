*********************************************************
*							*
*		MacFloppy.device			*
*							*
*		mfcmd.asm - ADOS interface		*
*							*
*	Copyright (c) 1989 Central Coast Software	*
*							*
*********************************************************

TEST	EQU	1	;0=normal, 1=test as normal pgm

	INCLUDE "vd0:MACROS.ASM"
	INCLUDE "mf.i"

	XDEF	SendReplyMsg
	XDEF	InitTrackGap

	XREF	_AbsExecBase
	XREF	BlitBlockComp
	XREF	ReadCmd,WriteCmd,FormatCmd

	XREF	WriteCurrentTrack,MotorOnOff
	XREF	DriveInstalled,DriveReady
	XREF	CheckProtection
	XREF	BusyDrives,FreeDrives
;;	XREF	ZapSpeedTable
	XREF	MotorChangeB
	XREF	AllocTimerB

	XREF	CalcTrkSec,Seek
	XREF	EjectDisk

	INT_ABLES

* The following code lets this driver be run as a normal program.  To do
* this, set TEST=1, assemble and link, then run from CLI with DDT.

	IFNE	TEST

	MOVE.L	A7,SaveSP
	MOVE.L	_AbsExecBase,A6
	ZAPA	A1
	CALLSYS	FindTask
	MOVE.L	D0,mfTask
	MOVE.L	#mf_Sizeof,D0
	BSR	AMem
	MOVE.L	D0,DevTbl
	BEQ	Abort
	MOVE.L	#IOSTD_SIZE,D0
	BSR	AMem
	MOVE.L	D0,IOB
	BEQ	Abort
	MOVE.L	#SectorSize*12,D0
	BSR	AMem
	MOVE.L	D0,Buffer
	BEQ	Abort
	MOVE.L	DevTbl,D0
	BSR	InitRoutine		;init device table
	IFZL	D0,Abort,L
	MOVE.L	DevTbl,A6
	MOVE.L	IOB,A1
	MOVE.L	A6,IO_DEVICE(A1)
	MOVEQ	#3,D0			;unit 3
	BSR	Open			;open the device
	IFNZL	D0,Abort
	MOVE.L	DevTbl,A6
	MOVE.L	mf_UnitPtr(A6),A3
	MOVE.L  mfTask,PrivatePort+MP_SIGTASK(A3) ;init PrivatePort signal task
	MOVE.W  #-1,CurTrk(A3)		;need to calibrate drive
	MOVE.W  #-1,OnDuty(A3)		;need to check speed
	BCLR    #td_DrvEmpty,TdFlags(A3)	;show disk loaded
;;	BSR	ZapSpeedTable
	BSR	InitTrackGap
	MOVE.L	DevTbl,A6
	MOVE.L	IOB,A1
	MOVE.W	#CMD_READ,IO_COMMAND(A1)
	MOVE.L	#SectorSize,IO_LENGTH(A1)	;two tracks=ds
	MOVE.L	Buffer,IO_DATA(A1)
	MOVE.L	#0,IO_OFFSET(A1) ;track 2
	BSR	BeginIO			;read flat dir
;	MOVE.L	IOB,A1
;	MOVE.W	#CMD_WRITE,IO_COMMAND(A1)
;	BSR	BeginIO			;write volume control block
	MOVE.L	DevTbl,A6
	MOVE.L	mf_UnitPtr(A6),A3
	BRA	InitialTaskPC		;and kick off the processing
Loop:	BRA.S	Loop	

Abort:	MOVE.L	SaveSP,A7
	MOVE.L	_AbsExecBase,A6
	MOVE.L	Buffer,A1
	MOVE.L	#SectorSize*12,D0
	BSR.S	FMem
	MOVE.L	IOB,A1
	MOVE.L	#IOSTD_SIZE,D0
	BSR.S	FMem
	MOVE.L	DevTbl,A1
	MOVE.L	#mf_Sizeof,D0
	BSR.S	FMem
	RTS				;back to ADOS

AMem:	MOVE.L	#MEMF_CLEAR!MEMF_PUBLIC,D1
	CALLSYS	AllocMem
	RTS

FMem:	IFZL	A1,1$
	CALLSYS	FreeMem
1$:	RTS

SaveSP	DC.L	0
mfTask	DC.L	0
DevTbl	DC.L	0
IOB	DC.L	0
Buffer	DC.L	0

	ENDC

	MOVEQ	#-1,D0		;just in case
	RTS

mfPri		EQU	0
Version		EQU	34

IniDesc	DC.W	RTC_MATCHWORD	;matchword
	DC.L	IniDesc		;ptr to MatchTag
	DC.L	EndCode		;endcode
	DC.B	RTF_AUTOINIT	;autoinit, so we don't have to
	DC.B	Version
	DC.B	NT_DEVICE
	DC.B	mfPri
	DC.L	mfName
	DC.L	idString
	DC.L	InitTbl

mfName		DC.B	'macfloppy.device',0,0
idString	DC.B	'macfloppy 1.0 (28 Aug 1989)',13,10,0

diskres.	DC.B	'disk.resource',0
graphicslib.	DC.B	'graphics.library',0
timerdev.	DC.B	'timer.device',0
ciabres.	DC.B	'ciab.resource',0

	DS.L	0			;force word alignment

* Autoinit table used to build device table and perform initialization

InitTbl	DC.L	mf_Sizeof		;size of device table
	DC.L	FunTbl			;Open, Close, BeginIO, AbortIO
	DC.L	DevInit			;device table initializers
	DC.L	InitRoutine		;this routine performs the rest of init

FunTbl	DC.L	Open		;Open
	DC.L	Close 		;Close
	DC.L	Expunge		;Expunge
	DC.L	Null		;Null
	DC.L	BeginIO		;BeginIO
	DC.L	AbortIO		;AbortIO
	DC.L	-1 

* Called by Autoinit to build the device table

DevInit	INITBYTE LN_TYPE,03
	INITLONG LN_NAME,mfName
	INITBYTE LIB_FLAGS,06		;fm
	INITWORD LIB_VERSION,Version
	INITWORD LIB_REVISION,1
	INITLONG LIB_IDSTRING,idString
	DC.L	0

* Called to complete device initialization.  A6=SysBase, A0=segment list
* D0=device table.  Must return device ptr or 0 in D0 on exit.

InitRoutine:
	PUSH	D1-D7/A0-A5
	MOVE.L	D0,A5
	MOVE.L	A6,mf_SysBase(A5)
	MOVE.L	A0,mf_SegList(A5)
	LEA     graphicslib.,A1
	ZAP	D0
	CALLSYS	OpenLibrary
	MOVE.L  D0,mf_GraphicsBase(A5)	;GraphicsBase
	BEQ.S   9$			;
	LEA     diskres.,A1
	CALLSYS	OpenResource
	MOVE.L  D0,mf_DRBase(A5)	;DRBase
	BEQ.S   1$
	LEA     ciabres.,A1
	CALLSYS	OpenResource
	MOVE.L  D0,mf_CiaBBase(A5)	;ciab
	BEQ.S	1$			;didn't get it
	LEA	mf_STimer(A5),A1
	ZAP	D0			;usec timer (short timer)
	BSR.S	AllocTimer
	BNE.S   1$
	LEA	mf_LTimer(A5),A1
	MOVEQ   #1,D0			;VBlank timer (long timer)
	BSR.S	AllocTimer
	BEQ.S   2$			;okay
	LEA     mf_STimer(A5),A1	;else close short timer
	CALLSYS	CloseDevice
1$:	MOVE.L	mf_GraphicsBase(A5),A1	;and release graphics lib
	CALLSYS	CloseLibrary
	ZAP	D0			;init failed
	BRA.S   9$
2$:	MOVE.L	A5,D0			;good init
;	LEA	CmdTbl,A0
;	MOVE.L	A0,CmdPtr
9$:	POP	D1-D7/A0-A5
	RTS

AllocTimer:
	LEA     timerdev.,A0
	ZAP	D1
	CALLSYS	OpenDevice
	TST.L	D0
	RTS

* Called by OpenDevice with: A6=device table, A1=callers IOB, D0=unit (1-3)

Open:	PUSH	D2-D3/A2-A4
	MOVE.L	A1,A4			;callers IOB to A4
	MOVE.L	mf_UnitPtr(A6),A3	;point to unit table in device table
	IFNZL	A3,1$			;there already is one...no need to init
	BSR	InitUnit		;else init this unit
	IFNZL	D0,8$			;unit init error
	MOVE.L	A0,A3
	MOVE.L  A3,mf_UnitPtr(A6)	;else save unit table ptr in device table
	BSR	FindUnit
	ERROR	7$
1$:	MOVE.L  A3,IO_UNIT(A4)		;return unit ptr in caller's IOB
	ADDQ.W  #1,mf_OpenCnt(A6)	;bump device open count
	ADDQ.B  #1,OpenCnt(A3)		;bump unit open count
	MOVE.L	#ADosMaxOffset,MaxOffset(A3) ;else open for ADOS access
	BRA.S	9$

7$:	MOVEQ   #TDERR_BadUnitNum,D0	;else bad unit error
8$:	MOVE.B  D0,IO_ERROR(A4)		;report error to caller
	MOVEQ   #-1,D0
	MOVE.L  D0,IO_UNIT(A4)		;make sure unit ptr will cause trap
	MOVE.L  D0,IO_DEVICE(A4)	;ditto for device ptr

9$:	POP	D2-D3/A2-A4
	RTS

* Checks Trackdisk unit table to see what drives are already attached.
* Then tries next device to see if it responds as Mac-2-Dos interface.
* Starts with first non-assigned device.

FindUnit:
	PUSH	D2
	MOVEQ	#1,D2			;start with drive 1
1$:	MOVE.L	D2,D0
	PUSH	A6
	MOVE.L	mf_DRBase(A6),A6
	JSR	DR_GETUNITID(A6)	;what type of drive?
	POP	A6
	IFZL	D0,2$			;says it is 3.5" drive
	IFEQIL	D0,#$55555555,2$	;says it is 5.25" drive
	BSR	InitUnitTbl		;set up data in unit table
	BSR	DriveInstalled		;see if hardware responds as M2D
	NOERROR	9$			;yes...all is well
2$:	INCW	D2
	IFLEIW	D2,#3,1$		;loop
	STC
9$:	POP	D2
	RTS

InitUnitTbl:
	MOVE.B	D2,UnitNum(A3)		;save number
	MOVE.B  #3,D0
	ADD.B   D2,D0
	MOVE.B	D0,LSTRB(A3)		;LSTRB is a BIT NUMBER
	MOVE.B	#$78,D1			;DF0-DF3 drive select bits only
	BCLR    D0,D1			;clear the proper bit
	MOVE.B  D1,Select(A3)		;save  select bit
	RTS

* Called during an open if the unit (drive) is not already active.
* Allocates memory for the unit table, stack, and track buffer,
* and starts the unit task.
* A6=device table, D2=unit number (0-3).

InitUnit:
	PUSH	A2-A4
	LEA     MemoryList,A0		;list of memory needed
	LINKSYS	AllocEntry,mf_SysBase(A6) ;alloc required buffers
	TST.L   D0			;okay?
	BNE.S	4$			;yes...got memory
	MOVEQ   #TDERR_NoMem,D0		;report not enuf memory
	BRA	7$

4$:	MOVE.L	D0,A4			;MemoryList ptr to A4
	MOVE.L	$10(A4),A3		;ptr to unit table

* This code initializes much of the unit table with constant data

	LEA     UnitTblInit,A1		;constant data
	MOVE.L	A3,A2			;unit table to A2
	MOVE.W  #UnitTbl_SIZE,D0	;size to clear...already clear?
	LINKSYS	InitStruct,mf_SysBase(A6) ;init unit table
	MOVE.L  A4,MemListPtr(A3)	;save ptr to MemList for later release

	MOVE.L	$18(A4),A0		;get stack buffer from memlist
	MOVE.L  A0,tcb+TC_SPLOWER(A3)	;init low end of stack
	LEA     StackSize(A0),A0	;point to upper end of stack
	MOVE.L  A0,tcb+TC_SPUPPER(A3)	;init upper stack limit
	MOVE.L  A6,-(A0)		;push device ptr onto task stack
	MOVE.L  A3,-(A0)		;and unit table also
	MOVE.L  A0,tcb+TC_SPREG(A3)	;init SP for unit task
	MOVE.L	$20(A4),A1		;get track buffer from memlist
	MOVEQ	#-1,D0
	MOVE.W	D0,0(A1)		;mark track unknown in buffer
	MOVE.W	D0,OnDuty(A3)		;force speed measurement
	CLR.B   2(A1)			;clear sector and flags
	MOVE.L  A1,WriteBuffer(A3)	;buffer ptr into unit table

* Each unit task uses a private msg port in the unit table to 
* handle DMA completion, index, & sync interrupts, blitter complete
* interrupts, and timer requests.  The task initiates an action which
* eventually causes an interrupt or the task starts a timeout.  In either
* case, the task "goes to sleep" to wait for the interrupt or the timeout.
* The timeout or the ISR for the interrupt sends a message to this 
* port causing a signal which wakes the task from its "sleep".  Note: there
* is no timeout while waiting for the interrupt, so if the interrupt
* never occurs, the task is permanently "hung" (sleeping forever...).

	LEA     PrivatePort(A3),A0		;point to private msg port
	MOVE.L  A0,ShortTimer+MN_REPLYPORT(A3)	;short timer uses private port
	MOVE.L  A0,PrivateMsg+MN_REPLYPORT(A3)	;private msg uses private port
	MOVE.L  A3,DMAInt+IS_DATA(A3)		;IO comp int structure
	MOVE.L  A3,SpeedIntB+IS_DATA(A3)	;motor control int 
	MOVE.L  A3,LongTimer+MN_REPLYPORT(A3)	;long timer uses public port
	LEA     tcb(A3),A0			;unit task tcb
	MOVE.L  A0,PrivatePort+MP_SIGTASK(A3)	;init PrivatePort signal task
	MOVE.L  mf_STimer+IO_DEVICE(A6),ShortTimer+IO_DEVICE(A3)
	MOVE.L  mf_STimer+IO_UNIT(A6),ShortTimer+IO_UNIT(A3)
	MOVE.L  mf_LTimer+IO_DEVICE(A6),LongTimer+IO_DEVICE(A3)
	MOVE.L  mf_LTimer+IO_UNIT(A6),LongTimer+IO_UNIT(A3)
	LEA     ChgVecList(A3),A0	;list of disk change vectors
	NEWLIST	A0
	LEA     MP_MSGLIST(A3),A0	;main msg port msg list
	NEWLIST	A0
	LEA     PrivatePort+MP_MSGLIST(A3),A0	;alternate msg port msg list
	NEWLIST	A0
	LEA     tcb+TC_MEMENTRY(A3),A0	;memory list for task
	NEWLIST	A0
	MOVE.L	MemListPtr(A3),A1	;get saved ptr to memlist structure
	ADDHEAD				;link Memlist structure into TC_MEMENTRY

	MOVE.L	A3,A4			;save ptr to unit table
	LEA     tcb(A3),A1		;tcb ptr
	LEA     InitialTaskPC,A2	;task starts here
	LEA     -1,A3			;magic number
	ZAP	D0			;required by AddTask???

;;	LINKSYS	AddTask,mf_SysBase(A6)	;kick off this unit task

	ZAP	D0			;good open
	MOVE.L	A4,A0			;return ptr to unit table in A0
7$:	POP	A2-A4
	RTS

* Called by CloseDevice with: A6=device table, A1=caller's IOB

Close:	PUSH	A2-A3
	MOVE.L	A1,A2			;save ptr to caller's IOB
	MOVE.L	IO_UNIT(A2),A3		;get unit ptr from IOB
	MOVEQ   #-1,D0		
	MOVE.L  D0,IO_DEVICE(A2)	;make sure device ptr will cause trap
	MOVE.L  D0,IO_UNIT(A2)		;ditto for unit ptr
	SUBQ.B  #1,OpenCnt(A3)		;decrement use counters
	BNE.S   1$			;still open
	BSR.S	CloseUnit		;perform final write, if pending
1$:	ZAP	D0
	SUBQ.W  #1,mf_OpenCnt(A6)	;decrement device open count
	POP	A2-A3
	RTS

* Called by Close to get rid of unit table and unit task.

CloseUnit:
	MOVE.L	WriteBuffer(A3),A0	;check for dirty buffer
	BCLR	#0,2(A0)		;clear dirty flag
	BEQ.S	1$			;already clear
	MOVE.L	A0,ReadBuffer(A3)
	BSR	WriteCurrentTrack	;else write out current dirty buffer
1$:	ZAP	D0
	BSR	MotorOnOff		;turn motor off
	RTS

* Called with: A6=device table, A1=caller's IOB.

BeginIO:
	CLR.B   IO_ERROR(A1)		;clear io_Error
	ZAP	D0
	MOVE.B  IO_COMMAND+1(A1),D0	;get command
	CMPI.B  #LastCmd,D0		;command in range?
	BCC.S   3$			;no...treat as reset
	MOVE.L	IO_UNIT(A1),A0		;get unit ptr
	MOVE.L  #$C61C2,D1		;immediate commands
	BTST    D0,D1			;is this immediate?
	BNE.S   1$			;yes...
	ANDI.B  #$7E,IO_FLAGS(A1)	;else show this won't be immediate
	LINKSYS	PutMsg,mf_SysBase(A6)	;queue request for unit task (A0)
	BRA.S   2$
1$:	BSET    #7,IO_FLAGS(A1)		;mark as 'immediate' (but not 'quick')
	MOVE.B  #5,8(A1)		;change the node type to MSG...magic
	PUSH	A2-A3
	MOVE.L	A0,A3			;unit ptr needs to be in A3
	MOVE.L	A1,A2			;and caller's IOB in A2
	BTST	#Mac_Disabled,MacFlags(A3) ;driver asleep?
	BEQ.S	4$			;no
	ZAP	D0
4$:;	MOVE.L	CmdPtr,A0
;	MOVE.W	D0,(A0)+
;	MOVE.L	A0,CmdPtr
	LEA     CommandTable,A0		;command dispatch table
	LSL.W   #2,D0			;index table by longword
	MOVE.L	0(A0,D0.W),A0		;get routine address
	JSR	(A0)			;and away we go...
	POP	A2-A3			;clean up stack on return
2$:	RTS
3$:	BSR	ResetCmd
	BRA.S   2$

Expunge:
Null:
AbortIO:
	ZAP	D0
	RTS

InitialTaskPC:
	IFEQ	TEST

	MOVE.L	8(A7),A6		;pick up device table
	MOVE.L	4(A7),A3		;and unit table
	LEA     tcb(A3),A0		;ptr to our task

	ENDC

	IFNE	TEST

	MOVE.L	mfTask,A0

	ENDC

;;	MOVE.L	8(A7),A6		;pick up device table
;;	MOVE.L	4(A7),A3		;and unit table
;;	LEA     tcb(A3),A0		;ptr to our task
	MOVE.L  A0,MP_SIGTASK(A3)	;init msg port with our own task
	LEA	MacFlags(A3),A4
	BSET	#Mac_TwoSided,(A4)	;else show as double-sided drive
	BSR	SetClickDelay		;look for disk change and set up timer
	BRA.S	ProcessMsg		;process any msgs, then go to sleep

* Main unit task msg processing loop

WaitForMsg:
	MOVE.L  #$300,D0		;signal bits for wait
	LINKSYS	Wait,mf_SysBase(A6)	;wait for some signal

ProcessMsg:
	BSET    #0,UnitFlags(A3)	;set unit active
	BNE.S	WaitForMsg		;unit already busy...ignore msg
1$:	MOVE.L	A3,A0			;public msgport is at base of unit table
	LINKSYS	GetMsg,mf_SysBase(A6)	;get a msg from public msgport
	IFZL	D0,6$,L			;no msg...clean up and go to sleep
	MOVE.L	D0,A2			;else ptr to msg to A2
	BCLR    #td_Close,TdFlags(A3)	;waiting to close device?
	BEQ.S	4$			;no
	MOVE.L	WriteBuffer(A3),A0	;write buffer
	BCLR    #0,2(A0)		;not dirty now
	BEQ.S	2$			;wasn't dirty anyway
	MOVE.L  A0,ReadBuffer(A3)
	BSR	WriteCurrentTrack	;write out current track
2$:	MOVE.L	WriteBuffer(A3),A0	;write buffer
	MOVEQ   #-1,D0
	MOVE.W  D0,0(A0)		;mark track unknown
	MOVE.W  D0,CurTrk(A3)		;force recalibration
	ZAP	D0			;turn motor off
	BSR	MotorOnOff
4$:	LEA     LongTimer(A3),A0	;get longtimer iob
	CMP.L	A0,A2			;is this the longtimer timeout?
	BNE.S   5$			;no...must be legitimate io req
	BSR.S	SetClickDelay		;else check for disk change and reset timer
;	ZAP	D0			;turn motor off
;	BSR	MotorOnOff
	BRA	1$			;check for another msg

5$:	BSET    #1,UnitFlags(A3)	;set InTask
	MOVE.L	A2,A1			;msg ptr to A1
	BSR	PerformIO		;process io request (in A1)
	BRA	1$			;loop back and try to get another msg

6$:	BCLR    #1,UnitFlags(A3)	;unit not in task
	BCLR    #0,UnitFlags(A3)	;unit not active
	BRA	WaitForMsg		;go to sleep

* This routine checks for a disk change, then starts an appropriate
* timeout to awaken task for the next check.

SetClickDelay:
	BSR	CheckForDiskChange	;see if disk has been changed
	LEA     LongTimer(A3),A1	;IORequest block for disk change timer
	MOVE.L  #500000,IO_SIZE+TV_MICRO(A1)	;0.5 second timeout
	BTST    #td_DrvEmpty,TdFlags(A3)	;disk loaded?
	BEQ.S   1$			;yes...use 0.5 sec timeout
	MOVEQ   #2,D0
	MOVE.L  D0,IO_SIZE+TV_SECS(A1)	;else set time value = 1.5 sec
1$:	LINKSYS	SendIO,mf_SysBase(A6)
	RTS

* This routine performs the check for disk change and notifies anyone who
* cares, if the disk has changed.

CheckForDiskChange:
	PUSH	D2/A2
	BTST	#Mac_Disabled,MacFlags(A3) ;driver locked out?
	BNE.S	9$			;yes...leave drive alone
	BSR	BusyDrives
	BSR	DriveReady		;is there a disk loaded?
	ERROR	1$			;no
	BTST    #td_DrvEmpty,TdFlags(A3)	;yes...was drive empty?
	BEQ	5$			;no...no change
	BRA.S	3$			;else process change in status

1$:	BSET    #td_DrvEmpty,TdFlags(A3)	;show no disk loaded
	BNE.S	5$			;no change...already empty
	ADDQ.L  #1,ChangeCnt(A3)	;else count the change
	BRA.S	2$
3$:	ADDQ.L  #1,ChangeCnt(A3)	;and count the change
	MOVEQ   #-1,D0
	MOVE.L	WriteBuffer(A3),A0	;write buffer
	MOVE.W  D0,0(A0)		;mark track unknown
	MOVE.W  D0,CurTrk(A3)		;force recalibration
;	MOVE.W  #-1,OnDuty(A3)		;need to check drive speed
	BCLR    #td_DrvEmpty,TdFlags(A3)	;show disk loaded
2$:	BSR	SendSoftInt		;tell all there has been a disk change
;;	BSR	ZapSpeedTable
	BSR	InitTrackGap		;set track gap to proper value
5$:	BSR	FreeDrives
9$:	POP	D2/A2
	RTS

* This routine sends a software interrupt to anybody who wants to know
* about a disk change.  There is a single-entry vector at ChangeIntVev
* (controlled by the TD_REMOVE command) and a list of change vectors at
* ChgVecList (maintained by the AddIntVec and RemIntVec commands).
* Note that the type of disk loaded must be determined BEFORE issuing the
* soft int, so that the proper routine is notified.  ADOS doesn't want
* to know about Mac floppies!

SendSoftInt:
	PUSH	D2/A6
	MOVE.L	mf_SysBase(A6),A6
	MOVE.L  ChangeIntVec(A3),D0	;interrupt vec set up by RemoveCmd
	BEQ.S   1$			;empty
	MOVE.L	D0,A1			;else send an int to it
	CALLSYS	Cause			;software interrupt
1$:	MOVE.L  ChgVecList(A3),D2	;check list of change vectors
2$:	MOVE.L	D2,A1			;list structure
	MOVE.L  (A1),D2			;get first(next) entry
	BEQ.S   3$			;none
	MOVE.L	IO_DATA(A1),A1		;else get ptr to soft int structure
	CALLSYS	Cause			;software interrupt
	BRA.S   2$			;loop for all requests in list
3$:	POP	D2/A6
	RTS

* Initializes track gap to proper value based on type of operation
* (ADOS or Mac).

InitTrackGap:
	MOVE.L	WriteBuffer(A3),A0
	ADDQ.L	#4,A0			;skip first longword
	MOVE.W  #TrackGap/4,D0		;fill rest of gap
	MOVE.L  #$AAAAAAAA,D1		;ADOS pattern
1$:	MOVE.L  D1,(A0)+
	DBF     D0,1$
	RTS

* This routine is called when a message is received by the task.
* A1=callers IOB, A6=device table.

PerformIO:
	MOVE.L  A2,-(A7)
	MOVE.L	A1,A2
	BCLR	#td_ETD,TdFlags(A3)	;clear flags relating to cmd type
	BCLR	#td_HdrData,TdFlags(A3)
	BSR	CheckForDiskChange
	MOVE.L	A2,A1
	MOVE.W  IO_COMMAND(A2),D0
	BTST    #$F,D0			;extended command (check change count)?
	BEQ.S   1$			;no
	BSET    #td_ETD,TdFlags(A3)	;show processing ETD command
	MOVE.L  ChangeCnt(A3),D1
	CMP.L   IOTD_COUNT(A2),D1
	BLS.S   1$			;count is ok
	MOVE.B  #TDERR_DiskChanged,IO_ERROR(A2)	;else error
	BSR	SendReplyMsg
	BRA.S	2$
1$:	ZAP	D1
	BTST	#Mac_Disabled,MacFlags(A3) ;driver asleep?
	BEQ.S	4$			;no
	ZAP	D0
4$:	MOVE.B  D0,D1
;	MOVE.L	CmdPtr,A0
;	MOVE.W	D1,(A0)+
;	MOVE.L	A0,CmdPtr
	LSL.W   #2,D1
	LEA     CommandTable,A0
	MOVE.L	0(A0,D1.W),A0		;index dispatch table
	JSR	(A0)			;and away we go...
	BSR	CheckForDiskChange
2$:	MOVE.L	(A7)+,A2
	RTS

SendReplyMsg:
	MOVE.L  A3,-(A7)
	MOVE.L	IO_UNIT(A1),A3
	BTST    #0,IO_FLAGS(A1)		;was this 'quick' io?
	BNE.S   1$			;yes...don't send reply
	LINKSYS	ReplyMsg,mf_SysBase(A6)
	BTST    #7,IO_FLAGS(A1)		;was request processed immediately?
	BNE.S   1$			;yes, simply return to caller
	MOVE.L  #$100,D0		;else send signal to caller
	LEA     tcb(A3),A1		;send signal to task
	LINKSYS	Signal,mf_SysBase(A6)
1$:	MOVE.L	(A7)+,A3
	RTS

CommandTable
	DC.L	InvalidCmd	;0 Invalid
	DC.L	ResetCmd	;1 Reset x
	DC.L	ReadCmd		;2 Read
	DC.L	WriteCmd	;3 Write
	DC.L	UpdateCmd	;4 Update
	DC.L	ClearCmd	;5 Clear
	DC.L	StopCmd		;6 Stop x
	DC.L	StartCmd	;7 Start x
	DC.L	FlushCmd	;8 Flush x
	DC.L	MotorCmd	;9 Motor
	DC.L	SeekCmd		;10 Seek
	DC.L	FormatCmd	;11 Format
	DC.L	RemoveCmd	;12 Remove
	DC.L	ChangeNumCmd	;13 ChangeNum x
	DC.L	ChangeStateCmd	;14 ChangeState x
	DC.L	ProtStatusCmd	;15 ProtStatus
	DC.L	RawReadCmd	;16 RawRead
	DC.L	RawWriteCmd	;17 RawWrite
	DC.L	GetDriveTypeCmd	;18 GetDriveType x
	DC.L	GetNumTracksCmd	;19 GetNumTracks x
	DC.L	AddChangeIntCmd	;20 AddChangeInt
	DC.L	RemChangeIntCmd	;21 RemChangeInt

InvalidCmd:
FlushCmd:
ResetCmd:
StopCmd:
StartCmd:
RawReadCmd:
;RawWriteCmd:
	MOVE.B  #IOERR_NOCMD,IO_ERROR(A1)
	BSR	SendReplyMsg
	RTS

* Use RawWriteCmd to eject Mac disk.

RawWriteCmd:
	MOVE.L	A1,A2			;save IOB
	BSR	EjectDisk
	MOVE.L	A2,A1
	BSR	SendReplyMsg
	RTS

ChangeNumCmd:
	MOVE.L  ChangeCnt(A3),IO_ACTUAL(A1)
	BSR	SendReplyMsg
	RTS

ChangeStateCmd:
	ZAP	D0
	BTST    #td_DrvEmpty,TdFlags(A3)	;drive empty?
	SNE     D0			;fix D0
	MOVE.L  D0,IO_ACTUAL(A1)	;return opposite from flag bit
	BSR	SendReplyMsg
	RTS

* This handles single change interrupt case.  Ptr to int vector
* passed in IO_DATA of IOB.

RemoveCmd:
;	MOVE.L	ChangeIntVec(A3),D0
	MOVE.L  IO_DATA(A1),ChangeIntVec(A3)
;	MOVE.L	D0,IO_ACTUAL(A1)	;return old vector
	BSR	SendReplyMsg
	RTS

* Called with IOB in A1 containing int structure to be added to list.
* IO_DATA in IOB points to interrupt structure.

AddChangeIntCmd:
	LEA     ChgVecList(A3),A0
;	MOVE.L	A1,D1
;	MOVE.L	IO_DATA(A1),A1	;get ptr to iot structure
	ADDTAIL			;interrupt structure to list in A0
;	MOVE.L	D1,A1
	BSR	SendReplyMsg
	RTS

* Called with IOB in A1 containing int structure to be removed from list.
* IO_DATA in IOB points to interrupt structure.

RemChangeIntCmd:
	MOVE.L  A1,D1		;save ptr to IOB
;	MOVE.L	IO_DATA(A1),A1	;get ptr to interrupt structure
	REMOVE			;remove item in A1 from list
	MOVE.L	D1,A1		;restore ptr to IOB
	BSR	SendReplyMsg
	RTS

GetDriveTypeCmd:
	MOVE.L  #Drive3_5,IO_ACTUAL(A2)
	MOVE.L	A2,A1
	BSR	SendReplyMsg
	RTS

GetNumTracksCmd:
	MOVE.L  #MaxTracks,IO_ACTUAL(A2)
	MOVE.L	A2,A1
	BSR	SendReplyMsg
	RTS

* Turn motor on or off, and return previous state.
* A1=IOB, A6=device table.

MotorCmd:
	MOVE.L  A1,-(A7)
	MOVE.L  IO_LENGTH(A1),D0	;1=turn on, 0=turn off
	BSR	MotorOnOff
	MOVE.L	(A7)+,A1
	MOVE.L  D0,IO_ACTUAL(A1)	;return previous state
	BSR	SendReplyMsg
	RTS

* A1=IOB, A6=device table.

SeekCmd:
	MOVE.L  A2,-(A7)
	MOVE.L	A1,A2
	MOVE.L  IO_OFFSET(A1),D0	;desired byte offet
	BSR	CalcTrkSec		;calc track and sector
	TST.L   D0			;valid track?
	BMI.S   2$			;no...bail out
	BSR	Seek			;else step to specified track
1$:	MOVE.L	A2,A1
	BSR	SendReplyMsg
	MOVE.L	(A7)+,A2
	RTS
2$:	MOVE.B  #IOERR_BADLENGTH,IO_ERROR(A2)
	BRA.S   1$

ProtStatusCmd:
	PUSH	D2/A2-A3
	MOVE.L	A1,A2
	MOVE.L	IO_UNIT(A2),A3
	BTST    #td_DrvEmpty,TdFlags(A3) ;drive empty?
	BEQ.S   1$			;NO...check it out
	MOVE.B  #TDERR_DiskChanged,IO_ERROR(A1)	;no disk loaded
	BRA.S   9$
1$:	BSR	BusyDrives
	ZAP	D2
	BSR	CheckProtection		;disk protected?
	NOERROR	2$			;no
	MOVEQ	#-1,D2			;set D0 if protected
2$:	MOVE.L  D2,IO_ACTUAL(A2)	;return in caller's IOB
	BSR	FreeDrives
9$:	MOVE.L	A2,A1
	BSR	SendReplyMsg
	POP	D2/A2-A3
	RTS

ClearCmd:
	MOVE.L	WriteBuffer(A3),A0	;get ptr to write buffer
	MOVE.W  #-1,0(A0)		;mark track unknown
	BCLR    #0,2(A0)		;clear dirty bit
	BSR	SendReplyMsg
	RTS

UpdateCmd:
	MOVE.L  A2,-(A7)
	MOVE.L	A1,A2
	MOVE.L	WriteBuffer(A3),A0	;get write buffer
	BTST    #0,2(A0)		;dirty?
	BEQ.S   2$			;no...do nothing
	BSR	WriteCurrentTrack	;else write out this track
	MOVE.L	A2,A1
	TST.L   D0			;error?
	BEQ.S   1$			;no
	MOVE.B  D0,IO_ERROR(A1)		;else return error code
	BRA.S   2$
1$:	MOVE.L	WriteBuffer(A3),A0
	BCLR    #0,2(A0)		;clear dirty bit
2$:	BSR	SendReplyMsg
	MOVE.L	(A7)+,A2
	RTS

* Unit table initialization data

EndCode:

UnitTblInit:
	INITBYTE LN_TYPE,04			;node type=msgport
	INITLONG LN_NAME,mfName			;port name
	INITBYTE MP_SIGBIT,09			;signal bit=9
	INITBYTE MP_MSGLIST+LH_TYPE,05		;list type=msg
	INITWORD CurTrk,$FFFF			;current track undefined
	INITBYTE TdFlags,02			;mark drive empty
	INITBYTE PrivatePort+LN_TYPE,04		;node type=msgport
	INITLONG PrivatePort+LN_NAME,mfName	;port name
	INITBYTE PrivatePort+MP_SIGBIT,10	;signal bit=10
	INITBYTE PrivatePort+MP_MSGLIST+LH_TYPE,05	;list type=msg
	INITBYTE ShortTimer+LN_TYPE,05		;timer request node type=message
	INITLONG ShortTimer+LN_NAME,mfName	;node name
	INITWORD ShortTimer+IO_COMMAND,09	;timer req=TR_ADDREQUEST
	INITBYTE LongTimer+LN_TYPE,05		;timer request node type=message
	INITLONG LongTimer+LN_NAME,mfName	;node name
	INITWORD LongTimer+IO_COMMAND,09	;timer req=TR_ADDREQUEST
	INITLONG LongTimer+IO_SIZE+TV_SECS,10	;timer value=10 seconds
	INITBYTE tcb+LN_TYPE,01			;tcb node type=task
	INITBYTE tcb+LN_PRI,05			;priority=5
	INITLONG tcb+LN_NAME,mfName		;node name
	INITBYTE PrivateMsg+LN_TYPE,05		;msg node type=msg
	INITLONG PrivateMsg+LN_NAME,mfName	;node name
	INITLONG DMAInt+IS_CODE,BlitBlockComp 	;is_Data loaded in InitUnit code
	INITBYTE SpeedIntB+LN_TYPE,NT_INTERRUPT
	INITBYTE SpeedIntB+LN_PRI,127
	INITLONG SpeedIntB+IS_CODE,MotorChangeB
	DC.L	0

* This is a list of buffers needed to init a unit.  Used by AllocEntry.

MemoryList:
	DCB.B	LN_SIZE,0		;a node
	DC.W	3			;number of entries
	DC.L	MEMF_CLEAR!MEMF_PUBLIC	;first entry=unit table
	DC.L	UnitTbl_SIZE		;
	DC.L	MEMF_CLEAR		;second entry=stack
	DC.L	StackSize		;defined in MF.I
	DC.L	MEMF_CLEAR!MEMF_CHIP	;third entry=track buffer
	DC.L	TrkBufSize		;defined in MF.I

;CmdPtr	DC.L	0
;CmdTbl	DS.B	200

	END
