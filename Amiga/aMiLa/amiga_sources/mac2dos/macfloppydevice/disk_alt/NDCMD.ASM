*********************************************************
*							*
*		Non-device Mac driver			*
*							*
*		mfcmd.asm - ADOS interface		*
*							*
*	Copyright (c) 1989 Central Coast Software	*
*							*
*********************************************************

	INCLUDE "vd0:MACROS.ASM"
	INCLUDE "mf.i"

	XDEF	SendReplyMsg
	XDEF	InitTrackGap
	XDEF	OpenMacDevice,CloseMacDevice,DoMacIO
	XDEF	SetClickDelay
	XDEF	CheckForDiskChange

	XREF	_AbsExecBase
	XREF	BlitBlockComp
	XREF	MotorChangeA,MotorChangeB
	XREF	MacTask
	XREF	ReadCmd,WriteCmd,FormatCmd

	XREF	WriteCurrentTrack,MotorOnOff
	XREF	DriveInstalled,DriveReady,DoubleSided
	XREF	CheckProtection
	XREF	BusyDrives,FreeDrives
	XREF	ZapSpeedTable
	XREF	CalcTrkSec,Seek
	XREF	EjectDisk
;;	XREF	FreeTimer

	XREF	DiskChgFlag

TaskPort	EQU	$5C

* This open is somewhat unusual, because it sets up the device and unit
* tables BEFORE checking on the unit.  This is because we need some things
* from the unit table to find out what unit we really are.

OpenMacDevice:
	PUSH	D2-D7/A2-A6
	MOVE.L	A1,A2			;save ptr to callers IOB
	MOVE.L	_AbsExecBase,A6
	MOVE.L	#mf_Sizeof,D0
	BSR	AMem
	MOVE.L	D0,DeviceTable
	BEQ	OpenErr3		;no mem...bail out
	MOVE.L	DeviceTable,D0
	BSR	InitRoutine		;init device table
	IFZL	D0,OpenErr2,L
	MOVE.L	DeviceTable,A6
	MOVE.L	A2,A1
	MOVE.L	A6,IO_DEVICE(A1)
;	BSR	FindUnit		;returns unit number in D0
;	MOVEQ	#3,D0			;unit number goes into D0
	MOVEQ	#1,D1			;flags=mac device
	BSR	Open			;open the device
	IFNZL	D0,OpenErr1
	MOVE.L	DeviceTable,A6
	MOVE.L	mf_UnitPtr(A6),A3
	MOVE.L	MacTask,PrivatePort+MP_SIGTASK(A3) ;init PrivatePort signal task
	MOVE.W	#-1,CurTrk(A3)		;need to calibrate drive
	BSR	ZapSpeedTable
	BSR	InitTrackGap
	MOVE.L	MacTask,MP_SIGTASK(A3)	;init msg port with our own task
	BSR	FindUnit		;find unit number and put into tbl
	ERROR	OpenErr			;oops...no hardware?
	BSR	BusyDrives
	BSR	DriveReady		;drive ready?
	ERROR	2$			;no
	BCLR	#td_DrvEmpty,TdFlags(A3) ;else show drive ready to go
2$:	BSR	FreeDrives	
	LEA	MacFlags(A3),A4
	BSR	DoubleSided		;is it double sided?
	ERROR	1$			;no
	BSET	#Mac_TwoSided,(A4)	;else show as double-sided drive
1$:	BSET	#Mac_Speed,(A4)		;force speed check on first access
	CLC
	POP	D2-D7/A2-A6
	RTS

OpenErr:
	BSR	FreeUnitTbl		;release unit table mem
OpenErr1:
	BSR	Expunge			;release timers/library
OpenErr2:
	BSR	FreeDeviceTbl		;release device table mem
OpenErr3:
	STC
	POP	D2-D7/A2-A6
	RTS

* A1=caller's IOB

CloseMacDevice:
	PUSH	D2-D7/A2-A6
	MOVE.L	DeviceTable,A6	
	MOVE.L	A1,A2			;save ptr to caller's IOB
	MOVE.L	mf_UnitPtr(A6),A3	;;
;;	MOVE.L	IO_UNIT(A2),A3		;get unit ptr from IOB
;;	CLR.B	DiskType(A3)		;zap Mac format flag
	MOVEQ   #-1,D0		
	MOVE.L  D0,IO_DEVICE(A2)	;make sure device ptr will cause trap
	MOVE.L  D0,IO_UNIT(A2)		;ditto for unit ptr
;;	BSR	FreeTimer		;release speed control timer
	BSR	CloseUnit		;get rid of unit task
	BSR	Expunge
	BSR	FreeDeviceTbl
	POP	D2-D7/A2-A6
	RTS

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
	BEQ.S   1$
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
9$:	POP	D1-D7/A0-A5
	RTS

AllocTimer:
	LEA     timerdev.,A0
	ZAP	D1
	CALLSYS	OpenDevice
	TST.L	D0
	RTS

* Called by OpenDevice with: A6=device table, A1=callers IOB, D0=unit (1-3)
* D1=open flag: 0=treat as ADOS device, 1=treat as Mac device (M2D exclusive)

Open:	PUSH	D2-D3/A2/A4
	MOVE.L	A1,A4			;callers IOB to A4
	MOVE.L	D1,D3			;save usage flag
	MOVE.L	mf_UnitPtr(A6),A0	;point to unit table in device table
	IFNZL	A0,1$			;there already is one...no need to init
	BSR	InitUnit		;else init this unit
	IFNZL	D0,8$			;unit init error
	MOVE.L  A0,mf_UnitPtr(A6)	;else save unit table ptr in device table
1$:	MOVE.L  A0,IO_UNIT(A4)		;return unit ptr in caller's IOB
	ADDQ.W  #1,mf_OpenCnt(A6)	;bump device open count
	ADDQ.B  #1,OpenCnt(A0)		;bump unit open count
	MOVE.L	#MacMaxOffset,MaxOffset(A0)
	MOVE.B	D3,DiskType(A0)		;format flag: 0=ADOS, 1=Mac
	BNE.S	9$			;open for Mac access
	MOVE.L	#ADosMaxOffset,MaxOffset(A0) ;else open for ADOS access
	BRA.S	9$

7$:	MOVEQ   #TDERR_BadUnitNum,D0	;else bad unit error
8$:	MOVE.B  D0,IO_ERROR(A4)		;report error to caller
	MOVEQ   #-1,D0
	MOVE.L  D0,IO_UNIT(A4)		;make sure unit ptr will cause trap
	MOVE.L  D0,IO_DEVICE(A4)	;ditto for device ptr

9$:	POP	D2-D3/A2/A4
	RTS

Expunge:
	PUSH	A5-A6
	MOVE.L	A6,A5			;save ptr to device table
	MOVE.L	mf_SysBase(A6),A6
	LEA	mf_STimer(A5),A1
	CALLSYS	CloseDevice
	LEA	mf_LTimer(A5),A1
	CALLSYS	CloseDevice
	MOVE.L	mf_GraphicsBase(A5),A1
	CALLSYS	CloseLibrary
	POP	A5-A6
	RTS

FreeDeviceTbl:
	MOVE.L	DeviceTable,A1
	MOVE.L	#mf_Sizeof,D0
	MOVE.L	_AbsExecBase,A6
	CALLSYS	FreeMem
	RTS

* Allocates memory for the unit table, stack, and track buffer.
* A6=device table, D2=unit number (0-3).

InitUnit:
	PUSH	A2-A4
	MOVE.L  D2,D0			;unit number
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

* This code calculates the proper select bit based on unit number

	MOVE.L	$20(A4),A1		;get track buffer from memlist
	MOVE.W  #-1,0(A1)		;mark track unknown in buffer
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
	MOVE.L	A3,SpeedIntA+IS_DATA(A3)	;speed control int structure
	MOVE.L	A3,SpeedIntB+IS_DATA(A3)	;speed control int structure
	MOVE.L  A3,LongTimer+MN_REPLYPORT(A3)	;long timer uses public port
	MOVE.L	MacTask,A0			;unit task tcb
	MOVE.L  A0,PrivatePort+MP_SIGTASK(A3)	;init PrivatePort signal task
	MOVE.L  mf_STimer+IO_DEVICE(A6),ShortTimer+IO_DEVICE(A3)
	MOVE.L  mf_STimer+IO_UNIT(A6),ShortTimer+IO_UNIT(A3)
	MOVE.L  mf_LTimer+IO_DEVICE(A6),LongTimer+IO_DEVICE(A3)
	MOVE.L  mf_LTimer+IO_UNIT(A6),LongTimer+IO_UNIT(A3)
	LEA     MP_MSGLIST(A3),A0	;main msg port msg list
	NEWLIST	A0
	LEA     PrivatePort+MP_MSGLIST(A3),A0	;alternate msg port msg list
	NEWLIST	A0
	ZAP	D0			;good open
	MOVE.L	A3,A0			;return ptr to unit table in A0
7$:	POP	A2-A4
	RTS

* Called by Close to get rid of unit table.

CloseUnit:
	ZAP	D0
	BSR	MotorOnOff		;turn motor off
;;	ZAP	D0
;;	MOVE.B	UnitNum(A3),D0
;;	MOVE.L	A6,-(A7)
;;	MOVE.L	mf_DRBase(A6),A6
;;	JSR	DR_FREEUNIT(A6)
;;	MOVE.L	(A7)+,A6
FreeUnitTbl:
	MOVE.L	MemListPtr(A3),A0
	LINKSYS	FreeEntry,mf_SysBase(A6)
	CLR.L	mf_UnitPtr(A6)		;zap unit ptr
	RTS

AMem:	MOVE.L	#MEMF_CLEAR!MEMF_PUBLIC,D1
	CALLSYS	AllocMem
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

* This routine checks for a disk change, then starts an appropriate
* timeout to awaken task for the next check.

SetClickDelay:
	PUSH	A3/A6
	MOVE.L	DeviceTable,A6
	MOVE.L	mf_UnitPtr(A6),A3
	LEA     LongTimer(A3),A1		;IORequest block for disk change timer
	MOVE.L  #500000,IO_SIZE+TV_MICRO(A1)	;0.5 second timeout
	LINKSYS	SendIO,mf_SysBase(A6)
	POP	A3/A6
	RTS

* This routine performs the check for disk change and notifies anyone who
* cares, if the disk has changed.

CheckForDiskChange:
	PUSH	A3/A6
	MOVE.L	DeviceTable,A6
	MOVE.L	mf_UnitPtr(A6),A3
	BSR	BusyDrives
	BSR	DriveReady		;is there a disk loaded?
	ERROR	1$			;no
	BTST    #td_DrvEmpty,TdFlags(A3)	;yes...was drive empty?
	BEQ	5$			;no...no change
	BRA.S	3$			;else process change in status

1$:	BSET    #td_DrvEmpty,TdFlags(A3)	;show no disk loaded
	BNE.S	5$			;no change...already empty
;	ADDQ.L  #1,ChangeCnt(A3)	;else count the change
	BRA.S	2$
3$:;	ADDQ.L  #1,ChangeCnt(A3)	;and count the change
	MOVEQ   #-1,D0
	MOVE.L	WriteBuffer(A3),A0	;write buffer
	MOVE.W  D0,0(A0)		;mark track unknown
	MOVE.W  D0,CurTrk(A3)		;force recalibration
;	MOVE.W  #-1,CurTrk(A3)		;need to calibrate drive
	BCLR    #td_DrvEmpty,TdFlags(A3)	;show disk loaded
	BSR	ZapSpeedTable
	BSR	InitTrackGap		;set track gap to proper value
2$:	SETF	DiskChgFlag		;show a change has occurred
5$:	BSR	FreeDrives
	POP	A3/A6
	RTS

* Called here to perform some io operation.
* A1=callers IOB.

DoMacIO:
	PUSH	D2-D7/A2-A6
	MOVE.L	A1,A2
	MOVE.L	DeviceTable,A6
	MOVE.L	mf_UnitPtr(A6),A3
	MOVE.L	A1,IORequest(A3)
	BCLR	#td_ETD,TdFlags(A3)	;clear flags relating to cmd type
	BCLR	#td_HdrData,TdFlags(A3)
;	MOVE.L	A2,A1
	MOVE.W  IO_COMMAND(A2),D0
	ZAP	D1
	MOVE.B  D0,D1
	LSL.W   #2,D1
	LEA     CommandTable,A0
	MOVE.L	0(A0,D1.W),A0		;index dispatch table
	JSR	(A0)			;and away we go...

	ZAP	D0
	MOVE.L	IORequest(A3),A1
	MOVE.B	IO_ERROR(A1),D0		;return error code to caller
	POP	D2-D7/A2-A6
	RTS				;return to caller

SendReplyMsg:
	RTS

CommandTable
	DC.L	InvalidCmd	;Invalid
	DC.L	ResetCmd	;Reset
	DC.L	ReadCmd		;Read
	DC.L	WriteCmd	;Write
	DC.L	UpdateCmd	;Update
	DC.L	ClearCmd	;Clear
	DC.L	StopCmd		;Stop
	DC.L	StartCmd	;Start
	DC.L	FlushCmd	;Flush
	DC.L	MotorCmd	;Motor
	DC.L	SeekCmd		;Seek
	DC.L	FormatCmd	;Format
	DC.L	RemoveCmd	;Remove
	DC.L	ChangeNumCmd	;ChangeNum
	DC.L	ChangeStateCmd	;ChangeState
	DC.L	ProtStatusCmd	;ProtStatus
	DC.L	RawReadCmd	;RawRead
	DC.L	RawWriteCmd	;RawWrite
	DC.L	GetDriveTypeCmd	;GetDriveType
	DC.L	GetNumTracksCmd	;GetNumTracks
	DC.L	AddChangeIntCmd	;AddChangeInt
	DC.L	RemChangeIntCmd	;RemChangeInt

InvalidCmd:
FlushCmd:
ResetCmd:
StopCmd:
StartCmd:
RawReadCmd:
ChangeNumCmd:
RemoveCmd:
AddChangeIntCmd:
RemChangeIntCmd:
GetNumTracksCmd:
	MOVE.B  #IOERR_NOCMD,IO_ERROR(A1)
;	BSR	SendReplyMsg
	RTS

GetDriveTypeCmd:
	ZAP	D0
	MOVE.B	MacFlags(A3),D0
	AND.B	#8,D0			;1=double-sided drive
	MOVE.L  D0,IO_ACTUAL(A1)	;return opposite from flag bit
	RTS

* Use RawWriteCmd to eject Mac disk.

RawWriteCmd:
	MOVE.L	A1,A2			;save IOB
	BSR	EjectDisk
	MOVE.L	A2,A1
;	BSR	SendReplyMsg
	RTS

	RTS

ChangeStateCmd:
	ZAP	D0
	BTST    #td_DrvEmpty,TdFlags(A3)	;drive empty?
	SNE     D0			;fix D0
	MOVE.L  D0,IO_ACTUAL(A1)	;return opposite from flag bit
;	BSR	SendReplyMsg
	RTS

* Turn motor on or off, and return previous state.
* A1=IOB, A6=device table.

MotorCmd:
	MOVE.L  A1,-(A7)
	MOVE.L  IO_LENGTH(A1),D0	;1=turn on, 0=turn off
	BSR	MotorOnOff
	MOVE.L	(A7)+,A1
	MOVE.L  D0,IO_ACTUAL(A1)	;return previous state
;	BSR	SendReplyMsg
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
;	BSR	SendReplyMsg
	MOVE.L	(A7)+,A2
	RTS
2$:	MOVE.B  #IOERR_BADLENGTH,IO_ERROR(A2)
	BRA.S   1$

ProtStatusCmd:
	PUSH	D2/A2-A3
	MOVE.L	A1,A2
	MOVE.L	IO_UNIT(A2),A3
	BTST    #td_DrvEmpty,TdFlags(A3) ;drive empty?
	BEQ.S   1$			;yes
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
;	BSR	SendReplyMsg
	POP	D2/A2-A3
	RTS

ClearCmd:
	MOVE.L	WriteBuffer(A3),A0	;get ptr to write buffer
	MOVE.W  #-1,0(A0)		;mark track unknown
	BCLR    #0,2(A0)		;clear dirty bit
;	BSR	SendReplyMsg
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
2$:;	BSR	SendReplyMsg
	MOVE.L	(A7)+,A2
	RTS

* Initializes track gap to proper value based on type of operation
* (ADOS or Mac).

InitTrackGap:
	MOVE.L	WriteBuffer(A3),A0
	ADDQ.L	#4,A0			;skip first longword
	MOVE.W  #TrackGap/4,D0		;fill rest of gap
	MOVE.L  #$AAAAAAAA,D1		;ADOS pattern
	IFZB	DiskType(A3),1$		;it is ADOS
	MOVE.L	#$FFFFFFFF,D1		;else Mac pattern
1$:	MOVE.L  D1,(A0)+
	DBF     D0,1$
	RTS

* Unit table initialization data

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
;	INITLONG LongTimer+IO_SIZE+TV_SECS,10	;timer value=10 seconds
;	INITBYTE tcb+LN_TYPE,01			;tcb node type=task
;	INITBYTE tcb+LN_PRI,05			;priority=5
;	INITLONG tcb+LN_NAME,mfName		;node name
	INITBYTE PrivateMsg+LN_TYPE,05		;msg node type=msg
	INITLONG PrivateMsg+LN_NAME,mfName	;node name
	INITLONG DMAInt+IS_CODE,BlitBlockComp 	;is_Data loaded in InitUnit code
	INITBYTE SpeedIntA+LN_TYPE,NT_INTERRUPT
	INITBYTE SpeedIntA+LN_PRI,127
	INITLONG SpeedIntA+IS_CODE,MotorChangeA
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
	DC.L	StackSize		;512
	DC.L	MEMF_CLEAR!MEMF_CHIP	;third entry=track buffer
	DC.L	TrkBufSize		;defined in MF.I

DeviceTable	DC.L	0
diskres.	DC.B	'disk.resource',0
ciabres.	DC.B	'ciab.resource',0
graphicslib.	DC.B	'graphics.library',0
timerdev.	DC.B	'timer.device',0
mfName		DC.B	'M2D',0

	END
