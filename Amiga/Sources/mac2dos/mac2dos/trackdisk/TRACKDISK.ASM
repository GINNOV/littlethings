*********************************************************
*							*
*		trackdisk.device source code		*
*							*
*********************************************************

	INCLUDE "TRACKDISK.I"

 STRUCTURE UnitTable,0
	STRUCT	MsgPort,MP_SIZE		;0
	BYTE	FLAGS			;22
	BYTE	PAD			;23
	WORD	OpenCnt			;24
	WORD	Precomp1		;26
	WORD	Precomp2		;28
	WORD	Precomp3		;2A
	LONG	StepDelay		;2C
	LONG	SetDelay		;30
	BYTE	RetryLimit		;34
	BYTE	DriveType		;35
	WORD	MaxTracks		;36
	LONG	MaxOffset		;38
	LONG	DriveID			;3C
	BYTE	FlagBits		;40
	BYTE	SelBits			;41
	BYTE	RetryCnt		;42
	BYTE	UnitNum			;43
	LONG	IOReq			;44
	WORD	NewSec			;48
	WORD	NewTrk			;4A
	WORD	CurTrk			;4C
	LONG	ReadBuffer		;4E
	LONG	WriteBuffer		;52
	LONG	UserDataBuf		;56
	LONG	HdrBuf			;5A
	LONG	TimerIOReq		;5E
	LONG	ChgTimer		;86
	STRUCT	AltMsgPort,MP_SIZE	;AE
	STRUCT	PrivateMsg,MN_SIZE	;D0
	STRUCT	DMACompInt,IS_SIZE	;E4
	STRUCT	SyncInt,IS_SIZE		;FA
	STRUCT	IndexInt,IS_SIZE	;110
	LONG	ChangeCnt		;126
	LONG	ChangeIntVen		;12A
	STRUCT	tcb,TC_SIZE		;12E
	LONG	MemListPtr		;18A
	STRUCT	ChgVecList,LH_SIZE	;18E
	LABEL	UnitTbl_SIZE		;19C=412 bytes

	BRA.L   Init
	BRA.L   OpenDF0

initDDescrip
	DC.W	$4AFC		;matchword
	DC.L	initDDescrip	;ptr to MatchTag
	DC.L	EndCode		;endcode
	DC.B	01,21		;not autoinit, version 31 
	DC.B	03,14		;device type=3, priority=20
	DC.L	myName		;myName
	DC.L	idString	;idString
	DC.L	Init		;Init routine

myName		DC.B	'trackdisk.device',0,0
idString	DC.B	'trackdisk 33.127 (8 Oct 1986)',13,10,0

OpenDF0:
	LEA	-$30(A7),A7	;allocate IOreq packet on stack
	MOVEA.L A7,A1		;IOreq ptr to A1
	LEA     myName,A0    	;'trackdisk.device'
	MOVE.L  A0,$A(A1)	;into packet
	MOVEQ   #0,D0		;DF0
	MOVEQ   #0,D1		;flags
	JSR     OpenDevice(A6)
	TST.L   D0		;got it?
	BEQ.S   $1		;yes
	MOVEA.L A7,A1		;else close device
	MOVE.L  $14(A1),-(A7)
	JSR     CloseDevice(A6)
	MOVEA.L (A7)+,A1
	JSR     RemDevice(A6)
1$:	LEA     $30(A7),A7	;clean up stack
	RTS

SetClickDelay:
	BSR.L   CheckForDiskChange
	LEA     ChgTimer(A3),A1		;IOreq block for disk change timer
	MOVE.L  #500000,TV_MICRO(A1)	;0.5 second timeout
	BTST    #1,Flags(A3)		;disk loaded?
	BEQ.S   1$			;yes...use 0.5 sec timeout
	MOVEQ   #2,D0
	MOVE.L  D0,TV_SECS(A1)		;else set time value = 2.5 sec
1$:	MOVE.L  A6,-(A7)
	MOVEA.L SysBase(A6),A6
	JSR     SendIO(A6)
	MOVEA.L (A7)+,A6
	RTS

CheckForDiskChange:
	MOVEM.L D2/A2,-(A7)
	BSR.L   BusyDrives
	LEA     CIAB,A2
	MOVE.B  SelBits(A3),(A2)
	NOP
	NOP
	MOVE.B  CIAA,D2	;get drive status
	BSR.L   FreeDrives
	BTST    #2,D2			;diskette loaded?
	BEQ.L   1$      		;no
	BTST    #1,Flags(A3)		;yes...was drive empty?
	BEQ.L   5$			;no...no change
	BRA.L   3$			;else process change in status
1$:	BSET    #1,Flags(A3)		;show no disk loaded
	BNE.L   2$			;no change...already empty
	ADDQ.L  #1,ChangeCnt(A3)	;else count the change
	MOVEQ   #6,D0			;else move to track 6
	BSR.L   Seek
	MOVEQ   #0,D0
	BSR.L   MotorOnOff		;turn motor off
	BSR.L   SendSoftInt		;tell all about the change
	BSR.L   BusyDrives
	MOVE.B  SelBits(A3),(A2)
2$:	BCHG    #1,SelBits(A3)		;now step the heads
	MOVE.B  SelBits(A3),D0
	MOVE.B  D0,D1
	BCLR    #0,D1
	MOVE.B  D1,(A2)
	NOP
	NOP
	MOVE.B  D0,(A2)
	BSR.L   FreeDrives		;release without owning...****
	MOVE.L  StepDelay(A3),D0
	BSR.L   TimeDelay
3$:	BSR.L   BusyDrives
	MOVE.B  SelBits(A3),(A2)
	NOP
	NOP
	MOVE.B  CIAA,D2
	BSR.L   FreeDrives
	BTST    #2,D2			;disk loaded?
	BEQ.L   5$			;no...do nothing
	BSR.L   BusyDrives		;else check prot statius
	MOVE.B  SelBits(A3),(A2)
	MOVE.B  CIAA,D2
	BSR.L   FreeDrives
	ADDQ.L  #1,ChangeCnt(A3)	;and count the change
	BCLR    #4,Flags(A3)		;clear write prot flag
	BTST    #3,D2			;is it write protected?
	BNE.S   4$			;no
	BSET    #4,Flags(A3)		;else show write protected
4$:	MOVE.W  #-1,CurTrk(A3)		;need to calibrate drive
	BCLR    #1,Flags(A3)		;show disk loaded
	BSR.L   SendSoftInt		;tell all about change
5$:	MOVEM.L (A7)+,D2/A2
	RTS

SendSoftInt:
	MOVEM.L D2/A6,-(A7)
	MOVEA.L SysBase(A6),A6
	MOVE.L  ChangeIntVec(A3),D0	;interrupt vec set up by RemoveCmd
	BEQ.S   1$			;empty
	MOVEA.L D0,A1			;else send an int to it
	JSR     Cause(A6)		;software interrupt
1$:	MOVE.L  ChgVecList(A3),D2	;check list of change vectors
2$:	MOVEA.L D2,A1			;list structure
	MOVE.L  (A1),D2			;get first(next) entry
	BEQ.S   3$			;none
	MOVEA.L IO_DATA(A1),A1		;else get ptr to soft int structure
	JSR     Cause(A6)		;software interrupt
	BRA.S   2$			;loop for all requests in list
3$:	MOVEM.L (A7)+,D2/A6
	RTS

ChangeNumCmd:
	MOVE.L  ChangeCnt(A3),IO_ACTUAL(A1)
	BSR.L   SendReplyMsg
	RTS

ChangeStateCmd:
	MOVEQ   #0,D0
	BTST    #1,Flags(A3)		;drive empty?
	SNE     D0			;fix D0
	MOVE.L  D0,IO_ACTUAL(A1)	;return opposite from flag bit
	BSR.L   SendReplyMsg
	RTS

* This handles single change interrupt case.  Ptr to int vector
* passed in IO_DATA of IOB.

RemoveCmd:
	MOVE.L  IO_DATA(A1),ChangeIntVec(A3)
	BSR.L   SendReplyMsg
	RTS

* Called with IOB in A1 to be added to list.  IO_DATA in IOB points to
* interrupt structure.

AddChangeIntCmd:
	LEA     ChgVecList(A3),A0
	LEA     4(A0),A0	;ADDTAIL
	MOVE.L  4(A0),D0
	MOVE.L  A1,4(A0)
	MOVE.L  A0,(A1)
	MOVE.L  D0,4(A1)
	MOVEA.L D0,A0
	MOVE.L  A1,(A0)
	RTS

* Called with IOB in A1 to be removed from list.

RemChangeIntCmd:
	MOVE.L  A1,D1		;save ptr to IOB
	MOVEA.L (A1),A0		;unlink IOB from list
	MOVEA.L 4(A1),A1
	MOVE.L  A0,(A1)
	MOVE.L  A1,4(A0)
	MOVEA.L D1,A1		;restore ptr to IOB
	BSR.L   SendReplyMsg
	RTS

diskres.	DC.B	'disk.resource',0
CIABres.	DC.B	'ciab.resource',0
graphicslib.	DC.B	'graphics.library',0
timerdev.	DC.B	'timer.device',0
kbddev.		DC.B	'keyboard.device',0

Init:	MOVE.L	 A2,-(A7)
	LINK    A4,#-$8C		;work area on stack
	MOVEA.L A7,A2
	LEA     graphicslib.,A1
	MOVEQ   #0,D0
	JSR     OpenLibrary(A6)
	MOVE.L  D0,0(A2)		;GraphicsBase
	BNE.S   1$
	MOVEM.L D7/A5-A6,-(A7)
	MOVE.L  #$14038002,D7
	MOVEA.L ExecBase,A6
	JSR     Alert(A6)
	MOVEM.L (A7)+,D7/A5-A6
	BRA.L   10$
1$:	LEA     diskres.,A1
	JSR     OpenResource(A6)
	MOVE.L  D0,$84(A2)		;DRBase
	BNE.S   2$
	MOVEM.L D7/A5-A6,-(A7)
	MOVE.L  #$14058021,D7
	MOVEA.L ExecBase,A6
	JSR     Alert(A6)
	MOVEM.L (A7)+,D7/A5-A6
	BRA.L   7$
2$:	LEA     CIABres.,A1
	JSR     OpenResource(A6)
	MOVE.L  D0,$88(A2)		;CIABBase
	BNE.S   3$
	MOVEM.L D7/A5-A6,-(A7)
	MOVE.L  #$14058020,D7
	MOVEA.L ExecBase,A6
	JSR     Alert(A6)
	MOVEM.L (A7)+,D7/A5-A6
	BRA.L   7$
3$:	LEA     Kbddev.,A0
	LEA     $54(A2),A1		;IOB for keyboard IO
	MOVEQ   #0,D0
	MOVEQ   #0,D1
	JSR     OpenDevice(A6)
	TST.L   D0
	BEQ.S   4$
	MOVEM.L D7/A5-A6,-(A7)
	MOVE.L  #$14048013,D7
	MOVEA.L ExecBase,A6
	JSR     Alert(A6)
	MOVEM.L (A7)+,D7/A5-A6
	BRA.L   7$
4$:	LEA     4(A2),A1		;IOB for usec timer
	MOVEQ   #0,D0			;usec timer
	BSR.L   AllocTimer
	BNE.S   6$
	LEA     $2C(A2),A1		;IOB for VBlank timer
	MOVEQ   #1,D0			;VBlank timer
	BSR.L   AllocTimer
	BNE.S   5$
	LEA     DispatchTbl1,A0
	LEA     LibStruct,A1
	SUBA.L  A2,A2			;A2=0 - dont call init
	MOVE.L  #168,D0			;size of library
	JSR     MakeLibrary(A6)		;this is actually 'make device'
	TST.L   D0			;did it work?
	BNE.S   8$			;yes...proceed
	MOVEM.L D7/A5-A6,-(A7)		;else bail out
	MOVE.L  #$14020000,D7
	MOVEA.L ExecBase,A6
	JSR     Alert(A6)
	MOVEM.L (A7)+,D7/A5-A6
	LEA     $2C(A2),A1
	JSR     CloseDevice(A6)
5$:	LEA     4(A2),A1
	JSR     CloseDevice(A6)
6$:	LEA     $54(A2),A1
	JSR     CloseDevice(A6)
7$:	MOVEA.L 0(A2),A1
	JSR     CloseLibrary(A6)
10$:	MOVEQ   #IOERR_OPENFAIL,D0	;oops...
	BRA.L   9$

* IF we got here, library for trackdisk has been created and we can complete
* initialization of device table from area on stack

8$:	LEA     -$8C(A4),A0		;base of work area on stack
	MOVEA.L D0,A2			;ptr to device table returned by MakeLib
	MOVE.L  0(A0),GraphicsBase(A2)	;GraphicsBase
	MOVE.L  $84(A0),DRBase(A2)	;DRBase
	MOVE.L  $88(A0),CIABBase(A2)	;CIABBase
	MOVE.L  A6,SysBase(A2)		;SysBase
	MOVE.L  -$74(A4),$4E(A2)	;usec timer device
	MOVE.L  -$70(A4),$52(A2)	;usec timer unit
	MOVE.L  -$4C(A4),$56(A2)	;vblank timer device
	MOVE.L  -$48(A4),$5A(A2)	;vblank timer unit
	LEA     $78(A2),A1		;IOB for keyboard device
	MOVE.L  -$20(A4),IO_UNIT(A1)	;kbd unit
	MOVE.L  -$24(A4),IO_DEVICE(A1)	;kbd device

* These next two init an interrupt vector for delaying resets (Ctrl-A-A)
* generated by the user at the keyboard.  This prevents interrupting writes
* and thereby generating a "bad" track.  Note: the A500 does not support this.

	MOVE.L  #KbdResetISR,$74(A2)	;IS_Code points to int service routine
	MOVE.L  A2,$70(A2)		;IS_Data

	LEA     $62(A2),A0		;Interrupt structure used by Keyboard
	MOVE.L  A0,IO_DATA(A1)		;Int struct ptr goes into Kbd IOB
	MOVE.B  #1,IO_FLAGS(A1)		;fuckin' magic
	MOVE.W  #$B,IO_COMMAND(A1)	;AddResetHandler
	MOVE.L  A6,-(A7)
	MOVEA.L IO_DEVICE(A1),A6	;kbd library base=device
	JSR     DEV_BEGINIO(A6)		;BeginIO
	MOVEA.L (A7)+,A6
	MOVE.W  #$D,IO_COMMAND(A1)	;change command to RemResetHandler
	MOVE.B  #1,IO_FLAGS(A1)		;fuckin' magic
	MOVEA.L A2,A1			;base of device table
	JSR     AddDevice(A6)		;make us a Dos device
	MOVEQ   #0,D0			;good init
9$:	UNLK    A4			;clean up stack
	MOVEA.L (A7)+,A2
	RTS

AllocTimer:
	MOVE.L  D0,-(A7)
	LEA     timerdev.,A0
	MOVEQ   #0,D1
	JSR     OpenDevice(A6)
	TST.L   D0
	BEQ.S   1$
	MOVEM.L D7/A5-A6,-(A7)
	MOVE.L  #$14048015,D7
	MOVEA.L ExecBase,A6
	JSR     Alert(A6)
	MOVEM.L (A7)+,D7/A5-A6
	ADDQ.L  #4,A7
	MOVEQ   #1,D0
1$:	ADDQ.L  #4,A7
	RTS

* This is a list of buffers needed to init a unit.  Used by Allocentry.

MemList:
	NODE
	DC.W	3			;number of entries
	DC.L	MEMF_CLEAR!MEMF_PUBLIC	;first entry=unit table
	DC.L	UnitTbl_SIZE		;412
	DC.L	MEMF_CLEAR		;second entry=stack
	DC.L	StackSize		;512
	DC.L	MEMF_CLEAR!MEMF_CHIP	;thrid entry=track buffer
	DC.L	TrkBufSize		;16388

* Called during an open if the unit (drive) is not already active.
* Allocates memory for the unit table, stack, and track buffer,
* and starts the unit task.
* A6=device table, D2=unit number (0-3), D1=open flags

InitUnit:
	MOVEM.L D3-D4/A2-A4,-(A7)
	MOVE.L  D1,D3			;save flags
	MOVE.L  D2,D0			;unit number
	MOVE.L  A6,-(A7)
	MOVEA.L DRBase(A6),A6
	JSR     GetDriveType(A6)	;what type of drive?
	MOVEA.L (A7)+,A6
	CMPI.L  #0,D0			;3.5"?
	BEQ.S   2$			;yes
	CMPI.L  #$55555555,D0		;5.25"?
	BNE.S   1$			;no...we don't know about this
	BTST    #0,D3			;it is 5.25"...can we use it?
	BNE.S   2$			;yes
1$:	MOVEQ   #$21,D0			;else report bad drive type
	BRA.L   7$
2$:	MOVE.L  D0,D4			;drive type to D4
	MOVE.L  D2,D0			;get unit number again
	MOVE.L  A6,-(A7)
	MOVEA.L DRBase(A6),A6
	JSR     AllocUnit(A6)		;allocate it
	MOVEA.L (A7)+,A6
	TST.L   D0			;okay?
	BNE.S   3$			;yes
	MOVEQ   #$22,D0			;else report drive allocation failed
	BRA.L   7$
3$:	LEA     MemList,A0		;list of memory needed
	MOVE.L  A6,-(A7)
	MOVEA.L SysBase(A6),A6
	JSR     AllocEntry(A6) 		;alloc required buffers
	MOVEA.L (A7)+,A6
	TST.L   D0			;okay?
	BEQ.L   8$			;no...bail out
	MOVEA.L D0,A4			;memlist ptr to A4
	MOVEA.L $10(A4),A3		;ptr to unit table

* This code initializes much of the unit table with constant data

	LEA     UnitTblInit,A1		;constant data
	MOVEA.L A3,A2			;unit table to A2
	MOVE.W  #UnitTbl_SIZE,D0	;size to clear...already clear?
	MOVE.L  A6,-(A7)
	MOVEA.L SysBase(A6),A6
	JSR     InitStruct(A6)		;init unit table
	MOVEA.L (A7)+,A6
	MOVE.L  A4,MemListPtr(A3)	;save ptr to MemList for later release
	MOVE.B  D2,UnitNum(A3)		;save unit number

* This code calculates the proper select bit based on unit number

	MOVE.B  #3,D0
	ADD.B   D2,D0
	MOVEQ   #-1,D1
	BCLR    D0,D1			;clear the proper bit
	MOVE.B  D1,SelBits(A3)		;save  select bit
	MOVE.L  D4,DriveID(A3)		;0=3.5", $55555555=5.25"
	CMPI.L  #0,D4			;3.5" drive?
	BEQ.S   4$			;yes
	LEA     ParamTbl5.25,A0		;else assume 5.25" drive
	BRA.S   5$
4$:	LEA     ParamTbl3.5,A0		;3.5" drive
5$:	LEA     Precomp1(A3),A1		;params go here in unit table
	MOVEQ   #22,D0			;22 bytes
	BSR.L   MoveData		;move params into unit table
	MOVEA.L $18(A4),A0		;get stack buffer from memlist
	MOVE.L  A0,tcb+TC_SPLOWER(A3)	;init low end of stack
	LEA     StackSize(A0),A0	;point to upper end of stack
	MOVE.L  A0,tcb+TC_SPUPPER(A3)	;init upper stack limit
	MOVE.L  A6,-(A0)		;push device ptr onto task stack
	MOVE.L  A3,-(A0)		;and unit table also
	MOVE.L  A0,tcb+TC_SPreg(A3)	;init SP for unit task
	MOVEA.L $20(A4),A1		;get track buffer from memlist
	MOVE.W  #-1,0(A1)		;mark track unknown in buffer
	CLR.B   2(A1)			;clear sector and flags
	MOVE.L  A1,WriteBuf(A3)		;buffer ptr into unit table
	LEA     4(A1),A0		;fill buffer with $AAAA
	MOVE.W  #$FFF,D0		;skip first longword
	MOVE.L  #$AAAAAAAA,D1
6$:	MOVE.L  D1,(A0)+
	DBF     D0,6$

* Each trackdisk unit task uses a private msg port in the unit table to 
* handle DMA completion, index, & sync interrupts, blitter complete
* interrupts, and timer requests.  The task initiates an action or a timeout,
* then "goes to sleep".  The ISR for these interrupts sends a message to this 
* port and sends a signal, which causes the task to wake up from its "sleep".

	LEA     AltMsgPort(A3),A0	;point to provate msg port
	MOVE.L  A0,$6C(A3)		;init msg port in usec timer IOB
	MOVE.L  A0,$DE(A3)		;init reply port in IO comp int msg
	MOVE.L  A3,$F2(A3)		;init data ptr for IO comp int structure
	MOVE.L  A3,$94(A3)		;init data ptr for int structure
	LEA     tcb(A3),A0		;unit task tcb
	MOVE.L  A0,AltMsgPort+mp_SigTask(A3)	;init altmsgport signal task
	MOVE.L  $4E(A6),$72(A3)		;usec timer device ptr
	MOVE.L  $52(A6),$76(A3)		;usec timer unit
	MOVE.L  $56(A6),$9A(A3)		;vblank timer device ptr
	MOVE.L  $5A(A6),$9E(A3)		;vblank timer unit
	LEA     ChgVecList(A3),A0	;list of disk change vectors
	MOVE.L  A0,(A0)			;NEWLIST
	ADDQ.L  #4,(A0)
	CLR.L   4(A0)
	MOVE.L  A0,8(A0)
	LEA     mp_MsgList(A3),A0	;main msg port msg list
	MOVE.L  A0,(A0)			;NEWLIST
	ADDQ.L  #4,(A0)
	CLR.L   4(A0)
	MOVE.L  A0,8(A0)
	LEA     AltMsgPort+mp_MsgList(A3),A0	;alternate msg port msg list
	MOVE.L  A0,(A0)			;NEWLIST
	ADDQ.L  #4,(A0)
	CLR.L   4(A0)
	MOVE.L  A0,8(A0)
	LEA     tcb+TC_MEMENTRY(A3),A0	;memory list for task
	MOVE.L  A0,(A0)			;NEWLIST
	ADDQ.L  #4,(A0)
	CLR.L   4(A0)
	MOVE.L  A0,8(A0)
	MOVEA.L MemListPtr(A3),A1	;get saved ptr to memlist structure
	MOVE.L  (A0),D0			;ADDHEAD - link into memlist for task
	MOVE.L  A1,(A0)
	MOVEM.L D0/A0,(A1)
	MOVEA.L D0,A0
	MOVE.L  A1,4(A0)
	MOVEA.L A3,A4			;save ptr to unit table
	LEA     tcb(A3),A1		;tcb ptr
	LEA     InitialTaskPC,A2	;task starts here
	LEA     -1,A3			;magic number
	MOVEQ   #0,D0			;required by AddTask???
	MOVE.L  A6,-(A7)
	MOVEA.L SysBase(A6),A6
	JSR     AddTask(A6)		;kick off this unit task
	MOVEA.L (A7)+,A6
	MOVEQ   #0,D0			;good open
	MOVEA.L A4,A0
7$:	MOVEM.L (A7)+,D3-D4/A2-A4
	RTS

8$:	MOVE.L  D2,D0			;cant get needed memory
	MOVE.L  A6,-(A7)
	MOVEA.L DRBase(A6),A6
	JSR     FreeUnit(A6)		;free the allocated unit
	MOVEA.L (A7)+,A6
	MOVEQ   #$1F,D0			;report not enuf memory
	BRA.S   7$

* This routine is called by keyboard routine when the operator hits CTRL-A-A.
* This code checks whether or not there might be an on-going write.  If so, it
* sets a flag and returns.  This causes the reset to be delayed until the
* write completes.  Else it lets the reset proceed.

KbdResetISR:
	MOVE.L  A2,-(A7)
	MOVEA.L A1,A2
	BSET    #4,$22(A1)		;set flag that CTRL-A-A is pending
	BTST    #5,$22(A1)		;is there a write on-going?
	BNE.S   1$			;yes...hold off the reset (except on A500)
	LEA     $72(A2),A1		;keyboard IOB
	MOVE.L  A6,-(A7)
	MOVEA.L IO_DEVICE(A1),A6	;keyboard device=library base
	JSR     DEV_BEGINIO(A6)		;BeginIO (RemResetHandler) - let reset go
	MOVEA.L (A7)+,A6
1$:	MOVEA.L (A7)+,A2
	RTS

Expunge:
	MOVEA.L ExecBase,A0
	MOVE.W  #$4000,$DFF09A		;DISABLE
	ADDQ.B  #1,$126(A0)
	TST.W   $20(A6)
	BNE.L   1$			;********does nothing!!!
1$:	MOVEA.L ExecBase,A0
	SUBQ.B  #1,$126(A0)		;ENABLE
	BGE.S   2$
	MOVE.W  #-$4000,$DFF09A
2$:	MOVEQ   #0,D0
	RTS

* Called by OpenDevice with: A6=device table, A1=callers IOB, D0=unit (1-3)
* D1=open flags

Open:
	MOVEM.L D2/A2/A4,-(A7)
	MOVEA.L A1,A4			;callers IOB to A4
	MOVE.L  D0,D2			;unit to D2
	CMPI.L  #4,D0			;out of range?
	BCS.S   1$			;no
	MOVEQ   #$20,D0			;else bad unit error
	BRA.S   4$
1$:	LSL.W   #2,D0			;mult by 4 to get index into unit table
	LEA     $24(A6),A2		;point to unit table in device table
	ADDA.L  D0,A2			;index into unit table ptrs
	MOVEA.L (A2),A0			;get entry, if any
	MOVE.L  A0,D0
	BNE.S   2$			;there already is one...no need to init
	BSR.L   InitUnit		;else init this unit
	TST.L   D0			;okay?
	BNE.L   4$			;no...report an error
	MOVE.L  A0,(A2)			;else save unit table ptr in device table
2$:	MOVE.L  A0,IO_UNIT(A4)		;return unit ptr in caller's IOB
	ADDQ.W  #1,$20(A6)		;bump device open count
	ADDQ.W  #1,OpenCnt(A0)		;bump unit open count
3$:	MOVEM.L (A7)+,D2/A2/A4
	RTS
4$:	MOVE.B  D0,IO_ERROR(A4)		;report error to caller
	MOVEQ   #-1,D0
	MOVE.L  D0,IO_UNIT(A4)		;make sure unit ptr will cause trap
	MOVE.L  D0,IO_DEVICE(A4)	;ditto for device ptr
	BRA.S   3$

* Called by CloseDevice with: A6=device table, A1=caller's IOB

Close:
	MOVEM.L A2-A3,-(A7)
	MOVEA.L A1,A2			;save ptr to caller's IOB
	MOVEA.L IO_UNIT(A2),A3		;get unit ptr from IOB
	SUBQ.W  #1,OpenCnt(A3)		;decrement use counters
	BNE.S   1$			;still open
	BSET    #3,Flags(A3)		;else close the unit
1$:	SUBQ.W  #1,$20(A6)		;decrement device open count
	MOVEQ   #-1,D0		
	MOVE.L  D0,IO_DEVICE(A2)	;make sure device ptr will cause trap
	MOVE.L  D0,IO_UNIT(A2)		;ditto for unit ptr
	MOVEM.L (A7)+,A2-A3
	MOVEQ   #0,D0
	RTS

* Called with: A6=device table, A1=caller's IOB.

BeginIO:
	CLR.B   IO_ERROR(A1)		;clear io_Error
	MOVEQ   #0,D0
	MOVE.B  IO_COMMAND+1(A1),D0	;get command
	CMPI.B  #$16,D0			;command in range?
	BCC.S   3$			;no...treat as reset
	MOVEA.L IO_UNIT(A1),A0		;get unit ptr
	MOVE.L  #$C61C2,D1		;immediate commands
	BTST    D0,D1			;is this immediate?
	BNE.S   1$			;yes...
	ANDI.B  #$7E,IO_FLAGS(A1)	;else show this won't be immediate
	MOVE.L  A6,-(A7)
	MOVEA.L SysBase(A6),A6
	JSR     PutMsg(A6)		;queue request for unit task (A0)
	MOVEA.L (A7)+,A6
	BRA.S   2$
1$:	BSET    #7,IO_FLAGS(A1)		;mark as 'immediate' (but not 'quick')
	MOVE.B  #5,8(A1)		;change the node type to MSG...magic
	MOVEM.L A2-A3,-(A7)
	MOVEA.L A0,A3			;unit ptr needs to be in A3
	MOVEA.L A1,A2			;and caller's IOB in A2
	LEA     DispatchTbl2,A0		;command dispatch table
	LSL.W   #2,D0			;index table by longword
	MOVEA.L 0(A0,D0.W),A0		;get routine address
	JSR     (A0)			;and away we go...
	MOVEM.L (A7)+,A2-A3		;clean up stack on return
2$:	RTS
3$:	BSR.L   ResetCmd
	BRA.S   2$

* This routine is called when a message is received by the task.
* A1=callers IOB, A6=device table.

PerformIO:
	MOVE.L  A2,-(A7)
	MOVEA.L A1,A2
	ANDI.B  #$A,Flags(A3)		;clear ETD flag and hdr data xfer bits
	BSR.L   CheckForDiskChange
	MOVEA.L A2,A1
	MOVE.W  IO_COMMAND(A2),D0
	BTST    #$F,D0			;extended command (check change count)?
	BEQ.S   1$			;no
	BSET    #2,Flags(A3)		;show processing ETD command
	MOVE.L  ChangeCnt(A3),D1
	CMP.L   IOTD_COUNT(A2),D1
	BLS.S   1$			;count is ok
	MOVE.B  #$1D,IO_ERROR(A2)	;else error=disk changed
	BSR.L   SendReplyMsg
	BRA.S	2$
1$:	MOVEQ   #0,D1
	MOVE.B  D0,D1
	LSL.W   #2,D1
	LEA     DispatchTbl2,A0
	MOVEA.L 0(A0,D1.W),A0		;index dispatch table
	JSR     (A0)			;and away we go...
	BSR.L   CheckForDiskChange
2$:	MOVEA.L (A7)+,A2
	RTS

Null:
AbortIO:
	MOVEQ   #0,D0
	RTS

InvalidCmd:
ResetCmd:
StopCmd:
StartCmd:
FlushCmd:
	MOVE.B  #IOERR_NOCMD,IO_ERROR(A1)
	BSR.L   SendReplyMsg
	RTS

FormatCmd:
	MOVEM.L D2-D5/A2-A5,-(A7)
	MOVEA.L A1,A4			;caller's iob to A4
	MOVEA.L IO_UNIT(A4),A3		;unit table
	MOVEQ   #1,D0			;turn motor on
	BSR.L   MotorOnOff
	TST.L   D0			;error?
	BNE.S   1$			;no
	MOVE.L  #300000,D0		;wait 300MS for motor to spin up
	BSR.L   TimeDelay
1$:	MOVEA.L WriteBuf(A3),A0		;get write buffer
	MOVE.L  A0,ReadBuf(A3)
	BCLR    #0,2(A0)		;clear dirty flag
	BEQ.S   2$			;it wasn't dirty
	BSR.L   WriteCurrentTrack	;else write out current track
	TST.L   D0			;error?
	BEQ.L   2$			;no
	MOVE.B  D0,IO_ERROR(A4)		;else return error to caller
	BRA.L   6$
2$:	MOVE.L  IO_OFFSET(A4),D0	;offset tells us what track
	BSR.L   CalcTrkSec		;check it out
	MOVE.L  D0,D2			;save starting track number
	TST.L   D1			;sector better be 0 (whole track)
	BNE.L   7$			;no...can't format track
	MOVE.L  IO_LENGTH(A4),D0	;figure out how many tracks
	BSR.L   CalcTrkSec		;better be whole tracks
	TST.L   D1			;can't be anything but sector 0
	BNE.L   7$			;oops...can't format track
	MOVE.L  D0,D3			;number of tracks to format to D3
	BEQ.L   6$			;oops...zero tracks - all done
	ADD.L   D2,D0			;add number to format to starting track
	CMP.L   MaxTrack(A3),D0		;too many for disk?
	BHI.L   7$			;yes...too bad
	MOVEA.L IO_DATA(A4),A5		;get user's data to write to track
8$:	MOVE.L  D2,D0			;format this track
	BSR.L   Seek			;step to proper track
	MOVEA.L WriteBuf(A3),A2		;write from this buffer
	LEA     4(A2),A2		;skip first longword
	MOVE.W  #$FFF,D0		;init buffer to $AAAA
	MOVE.L  #$AAAAAAAA,D1
3$:	MOVE.L  D1,(A2)+
	DBF     D0,3$
	MOVEA.L WriteBuf(A3),A2		;write buffer
	LEA     $680(A2),A2		;encode data here
	MOVEQ   #11,D4			;sectors per gap
	MOVEQ   #0,D5			;start with sector 0

* Sector loop.  First builds sector header, then sector data.

4$:	MOVE.L  #$FF000000,D0		;start with ADOS format code
	MOVE.L  D5,D1			;sector number to low byte
	LSL.L   #8,D1			;swab D1
	OR.L    D1,D0			;sector into hdr info
	OR.L    D4,D0			;number of sectors to gap
	MOVE.L  D2,D1			;track number to D1
	SWAP    D1			;get trk nmber to proper position
	OR.L    D1,D0			;into hdr info
	MOVEA.L A2,A1			;encoded hdr data goes here
	MOVEA.L A5,A0			;ptr to user's data to be encoded
	BSR.L   EncodeSector		;encode one sector
	ADDQ.L  #1,D5			;one more sector completed
	ADDA.L  #1088,A2		;bump buffer ptr
	ADDA.L  #512,A5			;bump user's data ptr
	SUBQ.L  #1,D4			;loop counter
	BNE.S   4$			;loop for all sectors
	MOVEA.L WriteBuf(A3),A0		;write this buffer to disk
	LEA     4(A0),A0		;skip first longword
	MOVE.W  #13630,D0		;write this many bytes
	BSR.L   WriteTrack		;write track now
	TST.L   D0			;error?
	BEQ.S   5$			;no
	MOVE.B  D0,IO_ERROR(A4)		;else return error
	BRA.S   6$			
5$:	ADDQ.L  #1,D2			;bump track number
	SUBQ.L  #1,D3			;track loop counter
	BNE.S   8$			;loop for all tracks
	MOVEA.L WriteBuf(A3),A2		;get buffer ptr
	MOVE.W  #-1,0(A2)		;mark contents unknown
6$:	MOVEA.L A4,A1
	BSR.L   SendReplyMsg
	MOVEM.L (A7)+,D2-D5/A2-A5
	RTS

7$:	MOVE.B  #IOERR_BADLENGTH,IO_ERROR(A4)	;format error
	BRA.S   6$

* Calculate track and sector from byte offset in D0
* Returns track in D0 (range 0-159) and sector in D1 (range 0-10)
* Returns D0=D1=-1 if offset is out of range.

CalcTrkSec:
	MOVE.L  D0,D1
	ANDI.L  #$1FF,D1		;anything other than full sector?
	BNE.L   1$			;yes...must be on sector boundary
	CMP.L   MaxOffset(A3),D0	;in range for this type of diskette?
	BHI.S   1$			;no
	MOVEQ   #9,D1			;divide to by 512 to get sectors
	LSR.L   D1,D0
	DIVU    #11,D0			;divide by sectors per track to get tracks
	MOVEQ   #0,D1
	SWAP    D0
	MOVE.W  D0,D1			;remainder to D1=sector
	MOVE.W  #0,D0
	SWAP    D0			;D0=track (0-159)
	RTS
1$:	MOVEQ   #-1,D0			;error
	MOVEQ   #-1,D1
	RTS

SendReplyMsg:
	MOVE.L  A3,-(A7)
	MOVEA.L IO_UNIT(A1),A3
	BTST    #0,IO_FLAGS(A1)		;was this 'quick' io?
	BNE.S   1$			;yes...don't send reply
	MOVE.L  A6,-(A7)
	MOVEA.L SysBase(A6),A6
	JSR     ReplyMsg(A6)
	MOVEA.L (A7)+,A6
	BTST    #7,IO_FLAGS(A1)		;was request processed immediately?
	BNE.S   1$			;yes, simply return to caller
	MOVE.L  #$100,D0		;else send signal to caller
	LEA     tcb(A3),A1		;send signal to task
	MOVE.L  A6,-(A7)
	MOVEA.L SysBase(A6),A6
	JSR     Signal(A6)
	MOVEA.L (A7)+,A6
1$:	MOVEA.L (A7)+,A3
	RTS

MoveData:
	BRA.S   2$
1$:	MOVE.B  (A0)+,(A1)+
2$:	DBF     D0,1$
	RTS


LibStruct:
	INITBYTE 08,03
	INITLONG 10,myName
	INITBYTE 14,06
	INITWORD 20,31
	INITWORD 22,$7F
	DC.L	0

* Unit table initialization table

UnitTblInit:
	INITBYTE $08,04		;node type=msgport
	INITLONG $0A,myNAme	;port name
	INITBYTE $0F,09		;signal bit=9
	INITBYTE $20,05		;list type=msg
	INITWORD $4C,$FFFF	;current track undefined
	INITBYTE $40,02		;mark drive empty
	INITBYTE $B6,04		;altmsgport node type=msgport
	INITLONG $B8,myName	;port name
	INITBYTE $BD,$0A	;signal bit=10
	INITBYTE $CE,05		;list type=msg
	INITBYTE $66,05		;timer request node type=message
	INITLONG $68,myName	;node name
	INITWORD $7A,09		;IO_command for timer req=TR_ADDREQUEST
	INITBYTE $8E,05		;timer request node type=message
	INITLONG $90,myName	;node name
	INITWORD $A2,09		;IO_command for timer req=TR_ADDREQUEST
	INITLONG $A6,$0000000A	;timer value=10 seconds
	INITBYTE $136,01	;tcb node type=task
	INITBYTE $137,05	;priority=5
	INITLONG $138,myName	;node name
	INITBYTE $D8,05		;msg node type=msg
	INITLONG $DA,myName	;node name
	INITLONG $F6,BlitBlockComp ;is_Code (is_Data loaded in InitUnit code)
	DC.L	0

* Drive parameter tables - used to init unit table.

ParamTbl3.5:
	DC.W	80		;switch to precomp 1 at this track
	DC.W	$FFFF		;precomp 2 unused
	DC.W	$FFFF		;precomp 3 unused
	DC.L	3000		;head stepping delay
	DC.L	15000		;head settling delay
	DC.B	10		;error retry limit
	DC.B	1		;drive type=3.5 inch
	DC.W	160		;max tracks
	DC.L	901120		;max offset

ParamTbl5.25:
	DC.W	40		;switch to precomp 1 at this track
	DC.W	$FFFF		;precomp 2 unused
	DC.W	$FFFF		;precomp 3 unused
	DC.L	6000		;head stepping delay
	DC.L	15000		;head settling delay
	DC.B	10		;error retry limit
	DC.B	2		;drive type=5.25 inch
	DC.W	80		;max tracks
	DC.L	450560		;max offset
	
DispatchTbl1:
	DC.L	Open		;Open
	DC.L	Close 		;Close
	DC.L	Expunge		;Expunge
	DC.L	Null		;Null
	DC.L	BeginIO		;BeginIO
	DC.L	AbortIO		;AbortIO
	DC.L	-1 

DispatchTbl2:
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

CalibrateDrive:
	MOVEM.L D2,-(A7)
	BSR.L   BusyDrives
	MOVE.B  SelBits(A3),D0		;get drive select bits
	BSET    #2,D0			;set side=0
	BCLR    #1,D0			;move away from track 0
	MOVE.B  D0,CIAB			;set drive params
	MOVE.B  D0,SelBits(A3)		;save for later
	MOVEQ   #0,D2
	MOVE.W  MaxTracks(A3),D2
	LSR.L   #2,D2			;dont step more than 1/4 of max
1$:	BTST    #4,CIAA			;already on track 0?
	BNE.S   2$			;no
	BSR.L   StepHead		;else step away from 0
	DBF     D2,1$			;loop
2$:	BSET    #1,SelBits(A3)		;reverse direction (toward track 0)
	CLR.W   CurTrk(A3)		;show current track 0
	MOVE.W  MaxTracks(A3),D2
	LSR.W   #1,D2			;divide max tracks by 2 to get cyls
	ADDI.W  #20,D2			;and add 20 more for good measure
	BRA.S   4$
3$:	BSR.L   StepHead
4$:	BTST    #4,CIAA			;on track 0?
	DBEQ    D2,3$			;loop if not
	MOVE.B  CIAA,D2			;read status
	BSR.L   FreeDrives
	BTST    #4,D2			;still on track 0?
	BEQ.S   5$			;yes
	MOVEQ   #$1E,D0			;else seek error
	BRA.S   6$
5$:	MOVE.L  SetDelay(A3),D0		;settling delay
	BSR.L   TimeDelay
	MOVEQ   #0,D0			;no error
6$:	MOVEM.L (A7)+,D2
	RTS

* Desired track in D0.  Note: range 0-159

Seek:
	MOVEM.L D2-D3,-(A7)
	MOVE.W  CurTrk(A3),D2		;check current track
	BPL.L   1$			;don't need to calibrate
	MOVE.L  D0,D2			;else save desired track
	BSR.L   CalibrateDrive
	TST.L   D0			;error?
	BNE.L   8$			;yes
	EXG     D2,D0			;else get back desired track
1$:	CMP.W   D0,D2			;same as we are on?
	BEQ.L   7$			;yes...all done
	MOVE.L  D0,D3			;else save desired track
	BSR.L   BusyDrives
	MOVE.B  SelBits(A3),D1
	BSET    #2,D1			;assume side 0
	BTST    #0,D3			;odd track is side 1
	BEQ.S   2$			;side 0
	BCLR    #2,D1			;else force side 1
2$:	MOVE.B  D1,SelBits(A3)		;save corrected select bits
	MOVE.B  D1,CIAB			;output to drive
	MOVE.W  D3,CurTrk(A3)		;this is our new current track
	LSR.W   #1,D2			;divide to get cyls
	LSR.W   #1,D3			;ditto
	SUB.W   D3,D2			;figure out which way to step
	BCS.S   3$			;toward spindle (higher tracks)
	BHI.S   4$			;toward track 0
	BSR.L   FreeDrives		;else already there
	BRA.S   7$
3$:	BCLR    #1,D1			;toward spindle
	MOVE.B  D1,SelBits(A3)
	NEG.W   D2			;correct step count
	BRA.S   6$
4$:	BSET    #1,D1			;toward track 0
	MOVE.B  D1,SelBits(A3)
	BRA.S   6$
5$:	BSR.L   StepHead
6$:	DBF     D2,5$			;loop till we get there
	BSR.L   FreeDrives
	MOVE.L  SetDelay(A3),D0		;settling delay
	BSR.L   TimeDelay
7$:	MOVEQ   #0,D0			;good seek
8$:	MOVEM.L (A7)+,D2-D3
	RTS

*New motor state in D0: 1=on, 0=off.

MotorOnOff:
	MOVE.L  D2,-(A7)
	TST.L   D0			;off?
	SEQ     D1			;cute way to set D1 to opposite of D0
	ANDI.B  #$80,D1			;get motor bit
	MOVE.B  SelBits(A3),D2
	ANDI.B  #$80,D2			;get current motor state
	CMP.B   D1,D2			;match?
	BEQ.L   1$			;yes...bail out
	BCLR    #7,SelBits(A3)		;else correct state of motor bit
	OR.B    D1,SelBits(A3)
	BSR.L   BusyDrives
	MOVEQ   #-1,D1
	EOR.B   D2,D1
	MOVE.B  D1,CIAB			;output new motor bit
	MOVE.B  SelBits(A3),CIAB	;then issue select to lock it in
	BSR.L   FreeDrives
	BTST    #7,SelBits(A3)		;did we just turn it on?
	BNE.L   1$			;no
	MOVE.L  #500000,D0		;else wait 0.5 second for spin up
	BSR.L   TimeDelay
1$:	MOVEQ   #0,D0
	BTST    #7,D2			;test previous state
	SEQ     D0			;set D0 to opposite of bit - 0=off
	MOVE.L  (A7)+,D2
	RTS

StepHeads:
	MOVE.B  SelBits(A3),D0		;get select bits
	LEA     CIAB,A1			;point to disk control hdw
	MOVE.B  D0,D1
	BCLR    #0,D0
	MOVE.B  D0,(A1)			;toggle the step bit off
	NOP
	NOP
	MOVE.B  D1,(A1)			;and back on
	BSR.L   FreeDrives		;free drive hardware while waiting
	MOVE.L  StepDelay(A3),D0	;step delay
	BSR.L   TimeDelay
	BSR.L   BusyDrives		;now busy drives again
	MOVE.B  SelBits(A3),CIAB	;and reselect
	RTS

* Delay in usecs in D0.

TimeDelay:
	CMPI.L  #300,D0			;less than 300 usec?
	BLT.L   1$			;yes...use some other technique
	MOVEM.L A0-A1,-(A7)
	LEA     TimerIOReq(A3),A1	;get timer request
	CLR.L   TV_SECS(A1)		;set seconds to 0
	MOVE.L  D0,TV_MICRO(A1)		;set usecs to proper delay
	MOVE.L  A6,-(A7)
	MOVEA.L SysBase(A6),A6
	JSR     DoIO(A6)		;wait for delay to expire
	MOVEA.L (A7)+,A6
	MOVEM.L (A7)+,A0-A1
	BRA.S   2$
1$:	TST.L   (A3)			;this must be wrong ****
	DBF     D0,1$
2$:	RTS

* Buffer to read into in A0, byte count in D0.

ReadTrack:
	LEA     StartDMA,A1
	MOVEM.L D2/A2/A4,-(A7)
	MOVEA.L A0,A2			;buffer to A2
	MOVE.L  D0,D2			;byte count to D2
	MOVEA.L A1,A4			;"GO" routine to A4
	BSR.L   BusyDrives
	MOVE.B  SelBits(A3),CIAB
	MOVE.W  #$4000,$DFF024		;stop DMA
	MOVE.L  #1000,D0		;wait 1ms
	BSR.S   TimeDelay
	LEA     $DFF000,A1		;hardware base reg to A1
	MOVE.L  A2,$20(A1)		;set DMA address
	MOVE.W  #$1002,$9C(A1)		;clear pending disk comp ints
	MOVE.W  #$8002,$9A(A1)		;enable disk comp ints
	BTST    #2,CIAA			;disk loaded?
	BNE.S   2$			;yes
1$:	MOVEQ   #$1D,D2			;else error=no disk loaded
	BRA.S   3$
2$:	LSR.W   #1,D2			;divide to get word count
	ORI.W   #$8000,D2		;enable DMA with write not set
	MOVE.L  D2,D0			;byte count, DMA and GO bits to D0
	JSR     (A4)			;execute a routine to start the IO
	BSR.L   WaitForSignal		;wait for block completion signal
	LEA     $DFF000,A1		;reset A1 to base of hardware regs
	MOVE.W  #2,$9A(A1)		;clear disk block int enable
	MOVE.W  #$4000,$24(A1)		;stop DMA
	BTST    #2,CIAA			;disk still in there?
	BEQ.S   1$			;no...report it to op
	MOVEQ   #0,D2			;error=none
3$:	BSR.L   FreeDrives
	MOVE.L  D2,D0			;return error code
	MOVEM.L (A7)+,D2/A2/A4
	RTS

* Start DMA operation by sending D0 to DSKLEN twice.  D0=byte count, write bit
* and DMA enable.  A1=hardware regs base.

StartDMA:
	MOVE.W  D0,$24(A1)
	MOVE.W  D0,$24(A1)
	RTS

* Buffer to write from in A0, byte count in D0.

WriteTrack:
	LEA     StartDMA,A1
	MOVEM.L D2/A2/A4,-(A7)
	MOVEA.L A0,A2			;buffer to A2
	MOVE.L  D0,D2			;byte count to D2
	MOVEA.L A1,A4			;start DMA address to A4
	BSR.L   BusyDrives
	MOVE.B  SelBits(A3),CIAB
	MOVE.W  #$4000,$DFF024		;turn off DMA
	MOVE.L  #1000,D0
	BSR.L   TimeDelay		;wait 1ms
	LEA     $DFF000,A1		;base of hardware regs
	MOVE.L  A2,$20(A1)		;buffer address to DSKADR
	MOVE.W  #$1002,$9C(A1)		;clear pending disk block ints
	MOVE.W  #$8002,$9A(A1)		;enable disk block comp ints
	BTST    #2,CIAA			;disk loaded
	BNE.S   2$			;yes
1$:	MOVEQ   #$1D,D2			;else error=no disk loaded
	BRA.L   8$
2$:	BTST    #3,CIAA			;write protected?
	BEQ.L   9$			;yes...
	MOVEA.L ExecBase,A0
	MOVE.W  #$4000,$DFF09A		;DISABLE interrupts
	ADDQ.B  #1,$126(A0)
	BTST    #4,$22(A6)		;reset requested?
	BEQ.S   4$			;no
	MOVEQ   #$23,D2			;error=reset about to happen
	MOVEA.L ExecBase,A0		;ENABLE ints
	SUBQ.B  #1,$126(A0)
	BGE.S   3$
	MOVE.W  #$C000,$DFF09A
3$:	BRA.L   8$
4$:	BSET    #5,$22(A6)		;else show write on-going
	MOVEA.L ExecBase,A0		;ENABLE ints
	SUBQ.B  #1,$126(A0)
	BGE.S   5$
	MOVE.W  #$C000,$DFF09A
5$:	MOVE.W  #$6000,$9E(A1)		;set disk parameters
	MOVE.W  CurTrk(A3),D0		;get the track for this write
	MOVE.W  #$8000,D1		;set initial precomp param
	CMP.W   PreComp1(A3),D0		;is range for precomp 0?
	BLS.S   6$			;yes
	MOVE.W  #$A000,D1		;else switch to precomp 1
	CMP.W   PreComp2(A3),D0		;in range for precomp 1?
	BLS.S   6$			;yes
	MOVE.W  #$C000,D1		;else switch to precomp 2
	CMP.W   PreComp3(A3),D0		;in range for precomp 2
	BLS.S   6$			;yes
	MOVE.W  #$E000,D1		;else switch to precomp 3
6$:	MOVE.W  D1,$9E(A1)		;issue proper precomp command
	LSR.W   #1,D2			;divide byte count
	ORI.W   #$C000,D2		;or in DMA and write bits
	MOVE.L  D2,D0			;to D0
	JSR     (A4)			;start DMA
	BSR.L   WaitForSignal		;wait for disk block comp int
	LEA     $DFF000,A1		;reload A1
	MOVE.W  #2,$9A(A1)		;clear disk block int enable bit
	MOVE.L  #2000,D0		;wait 2ms - FM
	BSR.L   TimeDelay
	MOVE.W  #$4000,$24(A1)		;stop DMA
	MOVE.B  $22(A6),D0
	BCLR    #5,$22(A6)		;clear 'write ongoing' bit
	BTST    #4,D0			;reset pending?
	BEQ.S   7$			;no
	LEA     $78(A6),A1		;else get kbd device
	MOVE.L  A6,-(A7)
	MOVEA.L IO_DEVICE(A1),A6
	JSR     DEV_BEGINIO(A6)		;BeginIO...RemResetHandler
	MOVEA.L (A7)+,A6
7$:	BTST    #2,CIAA			;is disk still loaded?
	BEQ.L   1$			;no...complain to op
	MOVEQ   #0,D2			;else good completion
8$:	BSR.L   FreeDrives
	MOVE.L  D2,D0			;completion code to D0
	MOVEM.L (A7)+,D2/A2/A4
	RTS
9$:	MOVEQ   #$1C,D2			;disk write protected
	BRA.S   8$

* This is the disk complete/blitter complete ISR.  It is called by
* the system with A1 set to the proper unit table based on the current
* "owner" of the hardware, which is maintained by the Disk Resource
* routine.  The vector is through the unit table disk complete vector.
* This routine sends a msg to the sleeping task to wake it up.

BlitBlockComp:
	LEA     AltMsgPort(A1),A0	;this is the port to use
	LEA     TimerIOReq(A1),A1	;use the timer message
	MOVE.L  A6,-(A7)
	MOVEA.L ExecBase,A6
	JSR     PutMsg(A6)
	MOVEA.L (A7)+,A6
	RTS

WaitForSignal:
	MOVE.L  #$400,D0		;signal bit to wait for
	MOVE.L  A6,-(A7)
	MOVEA.L SysBase(A6),A6
	JSR     Wait(A6)
	MOVEA.L (A7)+,A6
	LEA     AltMsgPort(A3),A0	;get a msg at this port
	MOVE.L  A6,-(A7)
	MOVEA.L SysBase(A6),A6
	JSR     GetMsg(A6)
	MOVEA.L (A7)+,A6
	TST.L   D0			;got one
	BEQ.S   WaitForSignal		;no...loop
	RTS

ReadCmd:
WriteCmd:
	MOVEM.L A2-A4,-(A7)
	MOVEA.L IO_UNIT(A1),A3		;get unit table
	MOVEA.L A1,A2			;save ptr to caller's IOB
	MOVE.L  A2,IOReq(A3)		;save ptr
	MOVE.L  #0,IO_ACTUAL(A2)	;show nothing yet
	MOVE.L  IO_DATA(A2),UserDataBuf(A3) ;user's data buffer
	MOVE.L  IO_OFFSET(A2),D0	;offset to desired place on disk
	BSR.L   CalcTrkSec		;check if valid
	TST.L   D0			;error?
	BMI.L   13$			;yes
	MOVE.W  D0,NewTrk(A3)		;else save new track and sector
	MOVE.B  D1,NewSec(A3)
	MOVE.L  IO_OFFSET(A2),D0	;now check for proper end of read/write
	ADD.L   IO_LENGTH(A2),D0
	BSR.L   CalcTrkSec		;check end
	TST.L   D0			;okay?
	BMI.L   13$			;no
	BTST    #2,Flags(A3)		;extended command?
	BEQ.S   1$			;no...don't even consider hdr data
	MOVE.L  IOTD_SECLABEL(A2),HdrBuf(A3) ;else save header buffer ptr
	BEQ.S   1$			;no hdr data ptr
	BSET    #0,Flags(A3)		;show transferring hdr data
1$:	BTST    #1,Flags(A3)		;is there a disk loaded?
	BEQ.S   2$			;yes
	MOVE.B  #$1D,IO_ERROR(A2)	;no disk loaded, dummy
	BRA.L   12$
2$:	MOVE.W  NewTrk(A3),D0		;get desired track number
	BSR.L   CheckTrackBuf
	MOVE.L  A0,ReadBuf(A3)		;desired track data at ReadBuf?
	BNE.S   5$			;yes...use it
	BSR.L   GetTrkBuf		;else get write buffer address
	MOVEA.L A0,A2			;to A2
	MOVE.L  A2,ReadBuf(A3)		;make it the ReadBuf
3$:	BTST    #0,2(A2)		;is it dirty?
	BEQ.S   4$			;no
	BSR.L   WriteCurrentTrack	;else write out the current track
	TST.L   D0			;errors?
	BEQ.S   4$			;no
	MOVEA.L IOReq(A3),A1		;else return error code in D0 to caller
	MOVE.B  D0,IO_ERROR(A1)
	BRA.L   12$
4$:	MOVE.W  NewTrk(A3),0(A2)	;set up track number in track buffer
	BCLR    #0,2(A2)		;clear the dirty flag
	CLR.B   ErrorCnt(A3)		;no errors yet
	BSR.L   ReadandDecodeTrack	;see if we can read and decode the track
	MOVE.B  3(A2),D0		;is sector count in range?
	CMPI.B  #11,D0			;compare with max a traxk can have
	BCS.S   5$			;ok
	MOVE.W  #-1,0(A2)		;else return error to caller
	MOVEA.L IOReq(A3),A1
	MOVE.B  D0,IO_ERROR(A1)
	BRA.L   12$
5$:	MOVEA.L IOReq(A3),A2		;ptr to callers IOB
	MOVE.W  IO_COMMAND(A2),D0	;find the command
	MOVEA.L ReadBuf(A3),A0		;read or write, they all go here
	CMPI.B  #CMD_WRITE,D0		;write?
	BNE.L   8$			;no, read
* Write
	BSET    #0,2(A0)		;else some flag in track buffer
	MOVEQ   #0,D0
	MOVE.B  NewSec(A3),D0		;get desired sector
	SUB.B   3(A0),D0		;wrap around?
	BPL.S   6$			;no
	ADDI.B  #11,D0			;yes...correct
6$:	MULU    #1088,D0		;mult by size of 1 sector (in MFM bytes)
	LEA     $680(A0),A4		;add in track gap offset
	ADDA.L  D0,A4			;index into track buffer
	BTST    #0,Flags(A3)		;header data going too?
	BEQ.S   7$			;no
	MOVEA.L HdrBuf(A3),A0		;else process header data
	MOVE.L  #16,D0			;16 longwords
	LEA     $10(A4),A1		;it goes here in buffer
	BSR.L   BlitEncode		;encode into MFM and store into buffer
	LEA     8(A4),A0		;header starts here in buffer
	MOVE.W  #40,D1			;64 bytes for checksum
	BSR.L   CalcCksum
	LEA     $30(A4),A0		;header checksum goes here
	BSR.L   EncodeLongword		;encode and store
7$:	MOVEA.L UserDataBuf(A3),A0	;get user's buffer
	MOVE.L  #512,D0			;process one full sector
	LEA     $40(A4),A1		;sector data goes here in buffer
	BSR.L   BlitEncode		;encode into MFM and store into buffer
	LEA     $40(A4),A0		;start here to recalc checksum
	MOVE.W  #1024,D1		;1088 bytes
	BSR.L   CalcCksum		;calc data checksum
	LEA     $38(A4),A0		;goes here in buffer
	BSR.L   EncodeLongword		;so store it into buffer
	BRA.L   15$

* READ

8$:	MOVEQ   #0,D0
	MOVE.B  NewSec(A3),D0
	SUB.B   3(A0),D0
	BPL.S   9$
	ADDI.B  #11,D0
9$:	MULU    #1088,D0		;calculate offset into track buffer
	LEA     $680(A0),A4		;skip over track gap
	ADDA.L  D0,A4	
	BTST    #0,Flags(A3)		;processing header data?
	BEQ.S   10$			;no
	LEA     $10(A4),A1		;header starts here
	MOVEA.L HdrBuf(A3),A0		;user's header buffer is here
	MOVE.L  #16,D0			;16 longwords
	BSR.L   BlitMove		;move that data into user's buffer
10$:	LEA     $40(A4),A1		;sector data starts here in buffer
	MOVEA.L UserDataBuf(A3),A0	;user's data buffer
	MOVE.L  #512,D0			;one full sector
	BSR.L   BlitMove		;move header data
15$:	MOVE.L  #512,D1			;move a full sector
	ADD.L   D1,UserDataBuf(A3)	;bump user's data address by one sector
	MOVE.L  IO_ACTUAL(A2),D0	;the amount we have moved so far
	ADD.L   D1,D0			;add length of this sector
	MOVE.L  D0,IO_ACTUAL(A2)	;amount moved counting this sector
	BTST    #0,Flags(A3)		;doing header data?
	BEQ.S   11$			;no
	ADDI.L  #16,HdrBuf(A3)		;else bump header buffer ptr
11$:	CMP.L   IO_LENGTH(A2),D0	;have we done it all?
	BCC.S   12$			;yes
	MOVEA.L ReadBuf(A3),A2		;else read another sector...get track
	ADDQ.B  #1,NewSec(A3)		;bump sector #
	CMPI.B  #11,NewSec(A3)		;past last sector of track?
	BLT.L   5$			;no
	MOVE.B  #0,NewSec(A3)		;else reset to sec 0
	ADDQ.W  #1,NewTrk(A3)		;and bump to next track
	BRA.L   3$			;loop for the next sector
12$:	MOVEA.L IOReq(A3),A1		;else reply to caller...read complete
	BSR.L   SendReplyMsg
	BRA.S   14$
13$:	MOVEA.L IOReq(A3),A1		;error
	MOVE.B  #IOERR_BADLENGTH,IO_ERROR(A1)
	BRA.S   12$
14$:	MOVEM.L (A7)+,A2-A4
	RTS

* Desired track in D0.  If track we want is already in buffer, return
* buffer ptr in A0.  Else return A0=0.

CheckTrackBuf:
	MOVE.L  WriteBuf(A3),D1		;get ptr to write buffer
	TST.L   D1			;is there a buffer?
	BEQ.S   1$			;no
	MOVEA.L D1,A0
	CMP.W   0(A0),D0		;is desired track in buffer?
	BEQ.S   2$			;yes...buffer in D1
1$:	MOVEQ   #0,D0			;no...zap D0
	MOVEA.L D0,A0
2$:	RTS

GetTrkBuf:
	MOVEA.L WriteBuf(A3),A0
	RTS

WriteCurrentTrack:
	MOVEM.L D2/A2,-(A7)
	MOVEA.L ReadBuf(A3),A2		;get buffer to be written
	MOVEQ   #1,D0			;motor "on"
	BSR.L   MotorOnOff
	MOVEQ   #0,D0
	MOVE.W  0(A2),D0		;get track number from buffer
	BSR.L   Seek			;seek to that track
	LEA     4(A2),A0		;skip over first longword
	MOVE.W  #13630,D0		;write this many bytes
	BSR.L   WriteTrack
	MOVEM.L (A7)+,D2/A2
	RTS

	DC.B	'read error %ld, track %d',13,10,0

ReadandDecodeTrack:
	MOVEM.L A2,-(A7)
	MOVEA.L ReadBuf(A3),A2		;get buffer to read into
	MOVEQ   #1,D0			;motor "on"
	BSR.L   MotorOnOff
1$:	MOVEQ   #0,D0
	MOVE.W  NewTrk(A3),D0		;read from this track
	BSR.L   Seek			;seek to that track
2$:	LEA     $684(A2),A0		;don't clobber gap data
	MOVE.W  #14716,D0		;read this many bytes
	BSR.L   ReadTrack
	TST.L   D0			;error?
	BEQ.S   3$			;no
	MOVE.B  D0,3(A2)		;clobber sector # with error code
	BRA.L   4$
3$:	BSR.L   DecodeTrkData		;attempt to decode the track
	MOVE.B  D0,3(A2)		;save first sector into buffer
	CMPI.B  #11,D0			;decoding error?
	BCS.S   4$			;no
	ADDQ.B  #1,ErrorCnt(A3)		;else bump retry count
	MOVE.B  ErrorCnt(A3),D0
	CMP.B   RetryLimit(A3),D0	;reached retry limit?
	BGT.S   4$			;yes...bail out
	ANDI.B  #3,D0			;allow up to 4 tries without seeking
	BNE.S   2$			;reread without seeking
	MOVE.W  #-1,CurTrk(A3)		;else clobber track number to force seek
	BRA.S   1$
4$:	MOVEM.L (A7)+,A2
	RTS

* Turn motor on or off, and return previous state.
* A1=IOB, A6=device table.

MotorCmd:
	MOVE.L  A1,-(A7)
	MOVE.L  IO_LENGTH(A1),D0	;1=turn on, 0=turn off
	BSR.L   MotorOnOff
	MOVEA.L (A7)+,A1
	MOVE.L  D0,IO_ACTUAL(A1)	;return previous state
	BSR.L   SendReplyMsg
	RTS

* A1=IOB, A6=device table.

SeekCmd:
	MOVE.L  A2,-(A7)
	MOVEA.L A1,A2
	MOVE.L  IO_OFFSET(A1),D0	;desired byte offet
	BSR.L   CalcTrkSec		;calc track and sector
	TST.L   D0			;valid track?
	BMI.S   2$			;no...bail out
	BSR.L   Seek			;else step to specified track
1$:	MOVEA.L A2,A1
	BSR.L   SendReplyMsg
	MOVEA.L (A7)+,A2
	RTS
2$:	MOVE.B  #IOERR_BADLENGTH,IO_ERROR(A2)
	BRA.S   1$

ProtStatusCmd:
	MOVEM.L D2/A2-A3,-(A7)
	MOVEA.L A1,A2
	MOVEA.L IO_UNIT(A2),A3
	BTST    #1,Flags(A3)		;drive empty?
	BNE.S   2$			;yes
	MOVEQ   #1,D0			;else turn motor on
	BSR.L   MotorOnOff
	BSR.L   BusyDrives
	MOVE.B  SelBits(A3),CIAB
	NOP
	NOP
	MOVE.B  CIAA,D2
	BSR.L   FreeDrives
	MOVEQ   #0,D0			;start with D0=0
	BTST    #3,D2			;disk protected?
	SEQ     D0			;set D0 if protected
	MOVE.L  D0,IO_ACTUAL(A2)	;return in caller's IOB
	MOVEQ   #0,D0			;turn motor off
	BSR.L   MotorOnOff
1$:	MOVEA.L A2,A1
	BSR.L   SendReplyMsg
	MOVEM.L (A7)+,D2/A2-A3
	RTS
2$:	MOVE.B  #$1D,IO_ERROR(A1)	;no disk loaded
	BRA.S   1$


ClearCmd:
	MOVEA.L WriteBuf(A3),A0		;get ptr to write buffer
	MOVE.W  #-1,0(A0)		;mark track unknown
	BCLR    #0,2(A0)		;clear dirty bit
	BSR.L   SendReplyMsg
	RTS

UpdateCmd:
	MOVE.L  A2,-(A7)
	MOVEA.L A1,A2
	MOVEA.L WriteBuf(A3),A0		;get write buffer
	BTST    #0,2(A0)		;dirty?
	BEQ.S   2$			;no...do nothing
	BSR.L   WriteCurrentTrack	;else write out this track
	MOVEA.L A2,A1
	TST.L   D0			;error?
	BEQ.S   1$			;no
	MOVE.B  D0,IO_ERROR(A1)		;else return error code
	BRA.S   2$
1$:	MOVEA.L WriteBuf(A3),A0
	BCLR    #0,2(A0)		;clear dirty bit
2$:	BSR.L   SendReplyMsg
	MOVEA.L (A7)+,A2
	RTS

* Called to encode header data and sector data into buffer.
* A1=data buffer, A0=unencoded sector data, D0=hdr info.

EncodeSector:
	MOVEM.L D2/A2/A4,-(A7)
	MOVEA.L A1,A4			;encoded data goes here
	MOVEA.L A0,A2			;raw data comes from here
	MOVE.L  D0,D2			;hdr info
	MOVEQ   #0,D0
	LEA     0(A4),A0		;encode 0 to get $AAAAAAAA
	BSR.L   EncodeLongword
	MOVE.L  #$44894489,4(A4)	;store sync pattern
	MOVE.L  D2,D0			;hdr info
	LEA     8(A4),A0		;goes here
	BSR.L   EncodeLongword
	MOVEQ   #3,D2			;store 16 (4*4) longwords of 0
1$:	MOVEQ   #0,D0
	BSR.L   EncodeLongword		;this is header data
	DBF     D2,1$
	LEA     8(A4),A0		;header starts here
	MOVEQ   #40,D1			;40 bytes in header
	BSR.L   CalcCksum		;calc hdr checksum
	LEA     $30(A4),A0		;hdr checksum goes here
	BSR.L   EncodeLongword
	MOVE.L  #512,D0			;one full sector of data
	MOVEA.L A2,A0			;raw data ptr
	LEA     $40(A4),A1		;encoded sector data goes here
	BSR.L   BlitEncode		;encode user's data MFM and store
	LEA     $40(A4),A0		;encoded sector data starts here
	MOVE.W  #1024,D1		;512*2 bytes for checksum
	BSR.L   CalcCksum		;calculate data checksum
	LEA     $38(A4),A0		;data checksum goes here
	BSR.L   EncodeLongword
	MOVEM.L (A7)+,D2/A2/A4
	RTS

* Called to encode raw data as MFM, and move into track buffer.
* A0=raw data ptr, A1=endcoded data ptr, D0=byte count,
* A3=unit table.

BlitEncode:
	LINK    A2,#-$1E		;make room on stack
	MOVE.W  D0,D1			;size of blit
	LSL.W   #2,D1			;number of longwords to process
	ORI.W   #8,D1
	MOVE.W  D1,-$A(A2)		;store into blit block
	MOVEM.L D0/A0-A1,-$16(A2)	;store remaining params into blit block
	MOVE.L  #BlitRtn5,-$1A(A2)	;blit routine
	MOVE.L  A3,-4(A2)		;port ptr for completion signal
	LEA     -$1E(A2),A1		;ptr to blit structure
	MOVE.L  A6,-(A7)
	MOVEA.L GraphicsBase(A6),A6
	JSR     QBlit(A6)
	MOVEA.L (A7)+,A6
	BSR.L   WaitForSignal		;wait for blit to complete
	MOVEM.L -$16(A2),D0/A0-A1
	MOVE.L  D0,D1			;byte number to D1
	MOVEA.L A1,A0			;ptr to beginning of data
	BSR.L   FixClockBit		;correct border
	ADDA.L  D1,A0
	BSR.L   FixClockBit
	ADDA.L  D1,A0
	BSR.L   FixClockBit
	UNLK    A2			;clean up stack
	RTS

BlitRtn5:
	MOVE.L  A5,-(A7)
	MOVEA.L A1,A5			;save ptr to blit structure
	BSR.L   BlitInit		;init blitter
	MOVEA.L A5,A1
	MOVEM.L 8(A1),D0-D1/A5
	MOVE.L  D1,$4C(A0)		;source to sourceB
	MOVE.L  D1,$50(A0)		;source to sourceA
	MOVE.L  A5,$54(A0)		;dest to dest D
	MOVE.W  #$1DB1,$40(A0)		;BLTCON0
	MOVE.W  #0,$42(A0)		;BLTCON1
	MOVE.W  $14(A1),$58(A0)		;start blitter
	MOVE.L  #BlitRtn6,4(A1)		;ptr to next function
	MOVEA.L (A7)+,A5
	RTS

BlitRtn6:
	MOVE.L  A5,-(A7)
	MOVEM.L 8(A1),D0-D1/A5
	MOVE.L  A5,$4C(A0)		;sourceB=dest
	MOVE.L  D1,$50(A0)		;sourceA=source
	MOVE.L  A5,$54(A0)		;destD=dest
	MOVE.W  #$2D8C,$40(A0)		;BLTCON0
	MOVE.W  $14(A1),$58(A0)		;start blitter
	MOVE.L  #BlitRtn7,4(A1)		;ptr to next function
	MOVEA.L (A7)+,A5
	RTS

BlitRtn7:
	MOVE.L  A5,-(A7)
	MOVEM.L 8(A1),D0-D1/A5
	ADD.L   D0,D1			;ptr to end source
	SUBQ.L  #2,D1			;-2
	ADDA.L  D0,A5
	ADDA.L  D0,A5
	SUBQ.L  #2,A5
	MOVE.L  D1,$4C(A0)		;source B=source end
	MOVE.L  D1,$50(A0)		;source A=source end
	MOVE.L  A5,$54(A0)		;destD=destination-end
	MOVE.W  #$DB1,$40(A0)		;BLTCON0
	MOVE.W  #$1002,$42(A0)		;BLTCON1
	MOVE.W  $14(A1),$58(A0)		;start blitter
	MOVE.L  #BlitRtn8,4(A1)		;ptr to next function
	MOVEA.L (A7)+,A5
	RTS

BlitRtn8:
	MOVE.L  A5,-(A7)
	MOVEM.L 8(A1),D0-D1/A5
	ADDA.L  D0,A5			;ptr to end of first part of dest
	MOVE.L  A5,$4C(A0)		;enter from source B
	MOVE.L  D1,$50(A0)		;source A=source
	MOVE.L  A5,$54(A0)		;destD=end of first part of dest
	MOVE.W  #$1D8C,$40(A0)		;BLTCON0
	MOVE.W  #0,$42(A0)		;BLTCON1
	MOVE.W  $14(A1),$58(A0)		;start blitter
	MOVE.L  #BlitRtn9,4(A1)		;ptr to next function
	MOVEA.L (A7)+,A5
	RTS

BlitRtn9:
	MOVEQ   #0,D0
	MOVE.L  D0,4(A1)		;all done...clobber linkage
	MOVEA.L $1A(A1),A1
	BSR.L   BlitBlockComp		;signal blit complete
	MOVEQ   #0,D0
	RTS

* This code is never called, as far as I can tell.  Looks like a routine
* called by ADOS to load the contents of a sector
* This routine does not appear to work for an ADOS sector format.

UnknownSubr:
	MOVEM.L D2/A2/A4,-(A7)
	MOVEA.L A0,A2		;save dest
	MOVEA.L A1,A4		;save source
	ADDQ.L  #8,A4		;point to hdr info bytes
	MOVEA.L A4,A0
	BSR.L   DecodeLongword	;decode 2 MFM longwords into D0
	MOVE.L  D0,D2		;save decoded hdr info in D2
	ADDQ.L  #8,A4
	ADDQ.L  #8,A4		;point to offset 24...
	MOVE.L  #512,D0		;move and decode 512 bytes
	MOVEA.L A4,A1		;source ptr
	MOVEA.L A2,A0		;dest ptr
	BSR.L   BlitMove	;A0=dest, A1=encoded MFM source, D0=byte count
	MOVE.L  D2,D0		;return hdr info in D0
	MOVEM.L (A7)+,D2/A2/A4
	RTS

* Called to decode MFM from track buffer and move to user's data buffer.
* A0=destination addresss, A1=encoded MFM source, D0=byte count.

BlitMove:
	LINK    A2,#-$1E		;set up blit block on stack
	MOVEM.L D0/A0-A1,-$16(A2)	
	LSL.W   #2,D0
	ORI.W   #8,D0
	MOVE.W  D0,-$A(A2)
	MOVE.L  #BlitRtn10,-$1A(A2)	;blitter function
	MOVE.L  A3,-4(A2)
	LEA     -$1E(A2),A1		;blitter node
	MOVE.L  A6,-(A7)
	MOVEA.L GraphicsBase(A6),A6
	JSR     QBlit(A6)		;queue blitter request
	MOVEA.L (A7)+,A6
	BSR.L   WaitForSignal		;wait for blit to complete
	MOVEM.L -$16(A2),D0/A0-A1
	UNLK    A2
	RTS

BlitRtn10:
	MOVE.L  A5,-(A7)
	MOVEA.L A1,A5			;save ptr to blitter node
	BSR.L   BlitInit		;init blitter
	MOVEA.L A5,A1
	MOVEM.L 8(A1),D0-D1/A5
	ADDA.L  D0,A5
	SUBQ.L  #1,A5
	MOVE.L  A5,$50(A0)		;sourceA
	ADDA.L  D0,A5
	MOVE.L  A5,$4C(A0)		;sourceB
	ADD.L   D0,D1
	SUBQ.L  #1,D1
	MOVE.L  D1,$54(A0)		;destD
	MOVE.W  #$1DD8,$40(A0)		;BLTCON0
	MOVE.W  #2,$42(A0)		;BLTCON1
	MOVE.W  $14(A1),$58(A0)		;start blitter
	MOVE.L  #BlitRtn11,4(A1)	;next blitter function
	MOVEA.L (A7)+,A5
	RTS

BlitRtn11:
	MOVEQ   #0,D0
	MOVE.L  D0,4(A1)		;clobber linkage
	MOVEA.L $1A(A1),A1
	BSR.L   BlitBlockComp		;signal blit complete
	MOVEQ   #0,D0
	RTS

* Encodes longword in D0 into MFM data stored in 2 longwords
* into buffer at A0.

EncodeLongword:
	MOVEM.L D2-D3,-(A7)
	MOVE.L  D0,D3
	LSR.L   #1,D0
	BSR.L   AddClockStore
	MOVE.L  D3,D0
	BSR.L   AddClockStore
	BSR.L   FixClockBit
	MOVEM.L (A7)+,D2-D3
	RTS

AddClockStore:
	ANDI.L  #$55555555,D0
	MOVE.L  D0,D2
	EORI.L  #$55555555,D2
	MOVE.L  D2,D1
	LSL.L   #1,D2
	LSR.L   #1,D1
	BSET    #$1F,D1
	AND.L   D2,D1
	OR.L    D1,D0
	BTST    #0,-1(A0)
	BEQ.S   1$
	BCLR    #$1F,D0
1$:	MOVE.L  D0,(A0)+
	RTS

* Loads MFM data at A0 and decodes it into D0.

DecodeLongword:
	MOVE.L  (A0)+,D0
	MOVE.L  (A0)+,D1
	ANDI.L  #$55555555,D0
	ANDI.L  #$55555555,D1
	LSL.L   #1,D0
	OR.L    D1,D0
	RTS

* Calculates checksum of MFM encoded data at A0 for D1 bytes.  Returns 
* resulting checksum in D0.

CalcCksum:
	MOVE.L  D2,-(A7)
	LSR.W   #2,D1
	SUBQ.W  #1,D1
	MOVEQ   #0,D0
1$:	MOVE.L  (A0)+,D2
	EOR.L   D2,D0
	DBF     D1,1$
	ANDI.L  #$55555555,D0
	MOVE.L  (A7)+,D2
	RTS

FixClockBit:
	MOVE.B  (A0),D0
	BTST    #0,-1(A0)
	BNE.S   1$
	BTST    #6,D0
	BNE.S   3$
	BSET    #7,D0
	BRA.S   2$
1$:	BCLR    #7,D0
2$:	MOVE.B  D0,(A0)
3$:	RTS

BusyDrives:
	MOVEM.L A2/A4,-(A7)
	MOVEA.L A6,A2
	MOVEA.L SysBase(A2),A4
	MOVEA.L DRBase(A2),A6
1$:	LEA     $D0(A3),A1		;utility msg
	JSR     GetUnit(A6)		;try to seize the hardware
	TST.L   D0			;got it?
	BNE.S   3$			;yes
	EXG     A4,A6			;else wait till we get it
2$:	MOVE.L  #$400,D0		;signal bits for wait
	JSR     Wait(A6)
	LEA     AltMsgPort(A3),A0	;get msg at private port
	JSR     GetMsg(A6)
	TST.L   D0			;got a msg?
	BEQ.S   2$			;no...loop
	EXG     A4,A6
	BRA.S   1$

* If we get here, we have the hardware to ourselves

3$:	EXG     A2,A6
	MOVE.B  SelBits(A3),D1		;get drive select bits
	ORI.B   #$7F,D1			;turn motor ON
	MOVE.B  D1,CIAB			;do it
	LEA     $D0(A3),A0		;get utility msg
	CMPA.L  D0,A0			;did we get our msg back?
	BEQ.S   4$			;yes
	LEA     $DFF000,A0
	MOVE.W  #$600,$9E(A0)		;else init disk params
	MOVE.W  #$9100,$9E(A0)
4$:	MOVEM.L (A7)+,A2/A4
	RTS

FreeDrives:
	MOVE.L  A6,-(A7)
	MOVEA.L DRBase(A6),A6
	JSR     GiveUnit(A6)
	MOVEA.L (A7)+,A6
	RTS

* Main trackdisk processing loop

InitialTaskPC:
	MOVEA.L 8(A7),A6		;pick up device table
	MOVEA.L 4(A7),A3		;and unit table
	LEA     tcb(A3),A0		;ptr to our task
	MOVE.L  A0,$10(A3)		;init mp_SigTask with our own task
	BSR.L   SetClickDelay		;look for disk change and set up timer
1$:	BSR.S   ProcessMsg		;process the msg we have received
	MOVE.L  #$300,D0		;signal bits for wait
	MOVE.L  A6,-(A7)
	MOVEA.L SysBase(A6),A6
	JSR     Wait(A6)		;wait for some signal
	MOVEA.L (A7)+,A6
	BRA.S   1$			;loop

* Called when there is a message to process in the external msgport.

ProcessMsg:
	BSET    #0,UnitFlags(A3)	;set unit active
	BNE.L   7$			;unit already busy...ignore msg
1$:	MOVEA.L A3,A0			;external msgport is at base of unit table
	MOVE.L  A6,-(A7)
	MOVEA.L SysBase(A6),A6
	JSR     GetMsg(A6)		;get a msg from external msgport
	MOVEA.L (A7)+,A6
	TST.L   D0			;got one?
	BEQ.L   6$			;no
	MOVEA.L D0,A2			;else ptr to msg to A2
	BCLR    #3,Flags(A3)		;close device?
	BEQ.L   4$			;no
	MOVEA.L WriteBuf(A3),A0		;write buffer
	BCLR    #0,2(A0)		;not dirty now
	BEQ.L   2$			;wasn't dirty anyway
	MOVE.L  A0,ReadBuf(A3)
	BSR.L   WriteCurrentTrack	;write out current track
2$:	MOVEA.L WriteBuf(A3),A0		;write buffer
	MOVEQ   #-1,D0
	MOVE.W  D0,0(A0)		;mark track unknown
	MOVE.W  D0,CurTrk(A3)		;force recalibration
	MOVEQ   #0,D0			;turn motor off
	BSR.L   MotorOnOff
	MOVEA.L A6,A0
	MOVEA.L SysBase(A0),A6
	ADDQ.B  #1,$127(A6)		;add 1 to td_NextCnt
	MOVEA.L A0,A6
	TST.W   OpenCnt(A3)		;check unit opencnt
	BNE.L   3$			;still open
	MOVEQ   #0,D0
	MOVE.B  UnitNum(A3),D0		;get unit number
	MOVE.L  A6,-(A7)
	MOVEA.L DRBase(A6),A6
	JSR     FreeUnit(A6)		;free the unit
	MOVEA.L (A7)+,A6
	LEA     $24(A6),A0
	MOVEQ   #0,D0
	MOVE.B  UnitNum(A3),D0
	LSL.L   #2,D0
	ADDA.L  D0,A0
	CLR.L   (A0)			;clear unit table entry in device table
	SUBA.L  A1,A1
	MOVE.L  A6,-(A7)
	MOVEA.L SysBase(A6),A6
	JSR     RemTask(A6)		;remove the unit task from system
	MOVEA.L (A7)+,A6
3$:	MOVE.L  A6,-(A7)
	MOVEA.L SysBase(A6),A6
	JSR     Permit(A6)
	MOVEA.L (A7)+,A6
4$:	MOVEA.L A2,A1			;msg ptr to A1
	LEA     ChgTimer(A3),A0		;get vblank timer iob
	CMPA.L  A0,A2			;is this the vblank timer iob?
	BNE.S   5$			;no
	BSR.L   SetClickDelay		;yes...must be click delay
	BRA.L   1$
5$:	BSET    #1,UnitFlags(A3)	;set InTask
	BSR.L   PerformIO		;process msg
	BRA.L   1$			;loop back and try to get another msg
6$:	BCLR    #1,UnitFlags(A3)	;unit not in task
	BCLR    #0,UnitFlags(A3)	;unit not active
7$:	RTS

* Scans track data looking for header sync pattern, which may be shifted.
* It determines the amount of shift which must be applied to decode the data.
* A0=track buffer ptr, D0=count of WORDS to scan.  Returns A0 pointing to
* start of sync pattern and D0 contains number of bits to shift.  A0=-1 on
* no match.

ScanForHdr:
	MOVEM.L D2-D4/A2,-(A7)
	MOVE.W  #$AAAA,D3		;normal sync pattern
	MOVE.W  #$5555,D4		;shifted sync pattern
	MOVEA.L A0,A2			;save ptr to buffer
	ADDA.L  D0,A2			;point to end of buffer
1$:	MOVE.W  (A0)+,D2		;check a word
	CMP.W   D3,D2			;matches normal sync pattern?
	BEQ.S   7$			;yes
	CMP.W   D4,D2			;else matches shifted sync pattern?
	BEQ.S   3$			;yes
	CMPA.L  A0,A2			;else check for end of buffer
	BHI.S   1$			;not end...loop
2$:	MOVEQ   #-1,D0			;end...no match found
	MOVEA.L D0,A0
	BRA.S   8$			;exit
3$:	MOVEQ   #15,D0			;16 entries -1
	LEA     SyncTbl1,A1		;shifted pattern
4$:	CMPA.L  A0,A2			;end?
	BLS.S   2$			;yes
	MOVE.W  (A0)+,D1		;else load data word
	CMP.W   D2,D1			;still getting pattern?
	BEQ.S   4$			;yes
	SUBQ.L  #2,A0			;no...backup 1 word
	MOVE.L  (A0),D1			;load longword
5$:	CMP.L   (A1)+,D1		;match pair of words from table?
	BEQ.S   6$			;yes...found shifted sync pattern
	SUBQ.L  #2,D0			;treat entries as pairs
	BGE.S   5$			;loop
	BRA.S   1$			;end of table...keep on going
6$:	SUBQ.L  #4,A0			;back up to start of sync pattern
8$:	MOVEM.L (A7)+,D2-D4/A2
	RTS
7$:	MOVEQ   #14,D0			;last entry is trivial
	LEA     SyncTbl2,A1		;use normal sync table
	BRA.S   4$

* This is the 55555555 table.  It is generated by taking AAAA44894489 and
* shifting by 1 to get 55552244, etc.

SyncTbl1:
	DC.W	$2244,$A244
	DC.W	$4891,$2891 
	DC.W	$5224,$4A24 
	DC.W	$5489,$1289 
	DC.W	$5522,$44A2 
	DC.W	$5548,$9128 
	DC.W	$5552,$244A 
	DC.W	$5554,$8912 

* This is the AAAAAAAA table.  It is generated by taking AAAA44894489 and
* shifting by 2 to get 2AAA9122, etc.

SyncTbl2:
	DC.W	$9122,$5122 
	DC.W	$A448,$9448 
	DC.W	$A912,$2512 
	DC.W	$AA44,$8944 
	DC.W	$AA91,$2251 
	DC.W	$AAA4,$4894 
	DC.W	$AAA9,$1225 
	DC.W	$4489,$4489 

* Called after a read to verify the raw data in the track buffer read from the
* floppy.  Checks headers and data for valid checksum errors, moves data to
* the front of the buffer (following the track gap AAAA's) and returns the
* first sector number of the buffer in D0.  Data in buffer still is in MFM
* format (with embedded clock) but has been shifted to correct for bit
* misalignment.

DecodeTrkData:
	MOVEM.L D2-D6/A2,-(A7)
	LINK    A4,#-$10		;create work area on stack
	MOVEA.L ReadBuf(A3),A2		;read buffer
	LEA     $680(A2),A2		;skip over track gap (written, never read)
	MOVEA.L A2,A0			;buffer to A0
	ADDQ.L  #2,A0			;skip over track number
	MOVE.L  #2748,D0		;scan this many words
	BSR.L   ScanForHdr		;search raw data for hdr sync pattern
	CMPA.L  #-1,A0			;find a header?
	BEQ.L   CantFindSecHdr		;no
	MOVE.L  A0,D5			;else save ptr to sync pattern
	MOVE.L  D0,D2			;and shift count
	ADDQ.L  #8,A0			;skip past sync
	MOVEQ   #9,D4			;counter for checksum
	MOVEQ   #0,D6			;init checksum accumulator
	TST.L   D2			;need to shift header?
	BNE.S   2$			;yes
	MOVE.L  (A0),-8(A4)		;no...store header bytes 
	MOVE.L  4(A0),-4(A4)
	MOVE.L  #$55555555,D1		;clock bit filter
1$:	MOVE.L  (A0)+,D0		;get a longword
	AND.L   D1,D0			;filter clock bits
	EOR.L   D0,D6			;form checksum
	DBF     D4,1$			;loop for all header bytes
	MOVE.L  (A0)+,-$10(A4)		;store header checksum
	MOVE.L  (A0),-$C(A4)		;store data checksum
	BRA.S   4$
2$:	BSR.L   LoadShiftMFM		;load and shift header, as necessary
	MOVE.L  D0,-8(A4)		;store corrected header bytes
	BSR.L   LoadShiftMFM		;ditto
	MOVE.L  D0,-4(A4)
	MOVEA.L D5,A0			;sync address to A0
	ADDQ.L  #8,A0			;jump ahead to next header bytes
3$:	BSR.L   LoadShiftMFM		;load and shift as necessary
	ANDI.L  #$55555555,D0		;get rid of clock bits
	EOR.L   D0,D6			;form checksum
	DBF     D4,3$			;loop for all bytes
	BSR.L   LoadShiftMFM		;load and shift hdr checksum
	MOVE.L  D0,-$10(A4)		;store it
	BSR.L   LoadShiftMFM		;load and shift data checksum
	MOVE.L  D0,-$C(A4)		;store it

* When we get here we have manually shifted the first header we found in
* the buffer.

4$:	LEA     -$10(A4),A0		;load MFM hdr checksum
	BSR.L   DecodeLongword		;decode it
	CMP.L   D0,D6			;checksums match?
	BNE.L   CantReadSecHdr		;no...bad header
	LEA     -8(A4),A0		;load 4 info bytes
	BSR.L   DecodeLongword		;decode hdr info
	MOVE.L  D0,D3			;save
	MOVE.L  D3,-(A7)		;cute way to check a byte
	CMPI.B  #-1,0(A7)		;ADOS format code?
	BNE.L   CantReadSecHdr		;no...not ADOS format
	MOVE.B  1(A7),D0		;get track number
	CMP.B   NewTrk+1(A3),D0		;match track we wanted to read?
	BNE.L   CantReadSecHdr		;no...
	MOVE.L  (A7)+,D3		;restore info
	MOVEQ   #0,D0
	MOVE.B  D3,D0			;get number of sectors to the gap
	MULU    #1088,D0		;multiply by full size of sector in MFM bytes
	MOVEA.L D5,A0			;set A0 to sync bytes
	MOVEA.L A2,A1			;saved ptr to beginning of data
	MOVE.L  D2,D1			;bit shift required
	MOVE.L  D0,D4			;distance to gap...length of blit
	BSR.L   BlitMoveShift		;move data up to front and shift
	MOVEQ   #0,D2
	MOVE.B  D3,D2			;number of blocks to gap
	SUBI.L  #11,D2			;calc number remaining after gap
	NEG.L   D2
	BEQ.S   5$			;none...get 'em all
	ADD.L   D4,D5			;determine address of gap in buffer
	MOVE.L  #1660,D0		;max number of words to search after gap
	MOVEA.L D5,A0			;address of gap
	ADDQ.L  #2,A0
	BSR.L   ScanForHdr		;search gap for sector sync pattern
	CMPA.L  #-1,A0			;found header?
	BEQ.L   TooFewSec		;no...problems
	MOVE.L  D0,D1			;number of bits to shift
	MOVEA.L A2,A1			;data buffer to A1
	ADDA.L  D4,A1			;point to end of first blit
	MOVE.L  D2,D0			;number of sectors after gap
	MULU    #1088,D0		;calculate length of second blit
	BSR.L   BlitMoveShift		;do it
5$:	MOVEA.L A2,A0			;buffer address to A0
	ADDA.L  D4,A0			;newly copied data starts here
	BSR.L   FixClockBit		;correct possible clock bit error
	LEA     11968(A2),A0		;point to end of data
	MOVE.W  #$AAA8,D0		;value for marking end
	BTST    #0,-1(A0)		;test last data bit
	BEQ.L   6$			;no fix needed
	BCLR    #15,D0			;else correct first bit of end marker
6$:	MOVE.W  D0,(A0)			;store it
	MOVE.W  #$AAAA,(A2)		;store beginning sync mark

* If we get here, the sectors have been moved to the front of the track buffer
* (following the track gap area), the gap has been moved to the end, and the
* data has been bit-shifted, as necessary.  The sectors are ready for error
* checking and decoding.  Now we check for 11 valid sectors, computing the
* header and data checksums.

	MOVEQ   #0,D4			;used to count bytes of data checked
	MOVEQ   #11,D2			;this many sectors to check
	MOVE.W  D3,D5			;first header info bytes to D5
	LSR.W   #8,D5			;first sector number to low byte

SectorLoop:
	CMPI.L  #$2AAAAAAA,0(A2,D4.W)	;look for proper sector sync pattern
	BEQ.S   1$			;found it
	CMPI.L  #$AAAAAAAA,0(A2,D4.W)	;alternate sync pattern
	BNE.L   BadSecPreamble		;oops...garbage
1$:	CMPI.L  #$44894489,4(A2,D4.W)	;check for rest of pattern
	BNE.L   BadSecPreamble		;cant find sector sync pattern
	LEA     8(A2,D4.W),A0		;found sync...point to hdr data
	MOVEQ   #40,D1			;40 bytes total in hdr
	BSR.L   CalcCksum		;calc header checksum
	MOVE.L  D0,D6			;save it
	LEA     $30(A2,D4.W),A0		;point to hdr checksum in MFM
	BSR.L   DecodeLongword		;decode it
	CMP.L   D6,D0			;hdr chekcsums match?
	BNE.L   BadHdrCksum		;no
	LEA     8(A2,D4.W),A0		;point to hdr again
	BSR.L   DecodeLongword		;decode hdr info bytes
	MOVE.L  D0,-(A7)		;cute way to test a byte
	CMPI.B  #-1,0(A7)		;ADOS format code?
	BNE.L   BadSecID		;no...not ADOS format
	MOVE.B  1(A7),D1		;get track number
	CMP.B   NewTrack+1(A3),D1	;match the track we want?
	BNE.L   BadSecID		;no...
	MOVE.B  2(A7),D1		;get sector number
	CMP.B   D5,D1			;is this sector we expected (no interleave)
	BNE.L   BadSecID		;no...interleave not allowed
	MOVE.B  D2,3(A7)		;insert adjusted count of secs to gap
	MOVE.L  (A7)+,D0		;into D0
	LEA     8(A2,D4.W),A0		;info bytes go here
	BSR.L   EncodeLongword		;encode and store into hdr
	LEA     8(A2,D4.W),A0		;hdr starts here
	MOVEQ   #40,D1			;40 bytes in hdr checksum
	BSR.L   CalcCksum		;recalc hdr checksum
	LEA     $30(A2,D4.W),A0		;hdr checksum goes here
	BSR.L   EncodeLongword		;encode and store new hdr checksum
	LEA     $40(A2,D4.W),A0		;data starts here
	MOVE.W  #1024,D1		;512*2 bytes in MFM
	BSR.L   CalcCksum		;calc data checksum
	MOVE.L  D0,D6			;save it
	LEA     $38(A2,D4.W),A0		;data checksum is here
	BSR.L   DecodeLongword		;decode it
	CMP.L   D6,D0			;checksums match?
	BNE.L   BadSecCksum		;no...data error
	SUBQ.L  #1,D2			;sector ok...decrement sector count
	ADDQ.B  #1,D5			;bump expected sector number
	CMPI.B  #11,D5			;need to wrap?
	BLT.S   2$			;no
	MOVEQ   #0,D5			;else reset to sector 0
2$:	ADDI.W  #1088,D4		;bump data ptr past this sector
	CMPI.W  #11968,D4		;gone far enough?
	BNE.L   SectorLoop		;no...loop

* If we get here, all 11 sectors look good.

	MOVE.L  D3,D1			;info field of first hdr in buffer
	LSR.L   #8,D1			;sector number to low byte
	MOVEQ   #0,D0
	MOVE.B  D1,D0			;first sector in buffer to D0

DecodeTrkExit:
	UNLK    A4			;clean up stack
	MOVEM.L (A7)+,D2-D6/A2
	RTS

DecodeError:
	NOP
	BRA.S   DecodeTrkExit

CantFindSecHdr:
	MOVEQ   #$15,D0
	BRA.S   DecodeError

CantReadSecHdr:
	MOVEQ   #$1B,D0
	BRA.S   DecodeError

BadSecPreamble:
	MOVEQ   #$16,D0
	BRA.S   DecodeError

BadSecID:
	MOVEQ   #$17,D0
	BRA.S   DecodeError

BadHdrCksum:
	MOVEQ   #$18,D0
	BRA.S   DecodeError

BadSecCksum:
	MOVEQ   #$19,D0
	BRA.S   DecodeError

TooFewSec:
	MOVEQ   #$1A,D0
	BRA.S   DecodeError

LoadShiftMFM:
	MOVE.L  (A0)+,D0
	MOVE.W  (A0),D1
	MOVEQ   #16,D3
	SUB.L   D2,D3
	LSL.L   D3,D0
	LSR.W   D2,D1
	OR.W    D1,D0
	RTS

* Moves data blocks and shifts data at the same time.
* A0=destination, A1=source, D0=byte count, D1=shift count.

BlitMoveShift:
	LINK    A2,#-$1E		;blitter node
	MOVE.B  D1,-8(A2)		;save shift count
	TST.L   D1
	BEQ.S   1$			;no shift required
	ADDQ.L  #2,D0
1$:	MOVE.L  D0,D1
	ADDI.L  #$3F,D1
	ANDI.W  #-$40,D1
	ORI.W   #$20,D1
	MOVE.W  D1,-$A(A2)
	MOVEM.L D0/A0-A1,-$16(A2)
	MOVE.L  #BlitRtn1,-$1A(A2)	;blitter function
	MOVE.L  A3,-4(A2)
	LEA     -$1E(A2),A1
	MOVE.L  A6,-(A7)
	MOVEA.L GraphicsBase(A6),A6
	JSR     QBlit(A6)		;queue blitter request
	MOVEA.L (A7)+,A6
	BSR.L   WaitForSignal		;wait for blit complete
	UNLK    A2			;clean up stack
	RTS

BlitRtn1:
	MOVE.L  A5,-(A7)
	MOVEA.L A1,A5
	BSR.L   BlitInit
	MOVE.B  $16(A5),D0
	MOVEQ   #$C,D1
	LSL.W   D1,D0
	MOVE.W  #$5CC,$40(A0)		;BLTCON0
	MOVE.W  D0,$42(A0)		;BLTCON1
	MOVEM.L 8(A5),D0-D1/A1
	MOVE.L  D1,$4C(A0)		;source B
	MOVE.L  #BlitRtn4,4(A5)		;next blitter function
	TST.B   $16(A5)
	BEQ.S   1$
	SUBQ.L  #2,A1
	MOVE.L  #BlitRtn3,4(A5)		;alternate blitter function
1$:	MOVE.L  A1,$54(A0)		;destD
	MOVE.W  (A1),$18(A5)
	MOVE.W  $14(A5),$58(A0)		;start blitter
	MOVEA.L (A7)+,A5
	RTS

BlitRtn3:
	MOVEA.L $10(A1),A0
	MOVE.W  $18(A1),-2(A0)
BlitRtn4:
	MOVEQ   #0,D0
	MOVE.L  D0,4(A1)		;clobber linkage
	MOVEA.L $1A(A1),A1
	BSR.L   BlitBlockComp		;blitter finished
	MOVEQ   #0,D0
	RTS

* Blitter initialization

BlitInit:
	MOVEQ   #0,D0
	LEA     $44(A0),A1
	MOVE.L  #-1,(A1)
	LEA     $62(A0),A1
	MOVE.L  D0,(A1)+
	MOVE.W  D0,(A1)+
	ADDQ.L  #8,A1
	MOVE.W  #$5555,(A1)
	RTS

RawReadCmd:
	LEA     ReadTrack+4,A0
	BRA.S   RawCommon
RawWriteCmd:
	LEA     WriteTrack+4,A0
RawCommon:
	MOVEM.L D2-D3/A2-A4,-(A7)
	LINK    A5,#-8			;build a little data area
	MOVEA.L A1,A2
	MOVEA.L A0,A4
	MOVEQ   #1,D0
	BSR.L   MotorOnOff		;turn motor on
	MOVE.L  IO_OFFSET(A2),D0	;get requested track
	CMP.L   MaxTracks(A3),D0	;in range?
	BCC.S   RawReqError		;no
	BSR.L   Seek			;else seek to req track
	MOVE.B  D0,IO_ERROR(A2)		;seek error?
	BNE.S   RawExit
	MOVE.L  IO_LENGTH(A2),D0	;number of bytes to read/write
	CMP.L   $8000,D0		;too many? ****** bug here!!
	BCC.S   RawReqError
	MOVEA.L IO_DATA(A2),A0		;get buffer for transfer
	LEA     StartDMA,A1
	BTST    #4,IO_FLAGS(A2)		;index sync requested?
	BEQ.S   1$			;no
	LEA     -8(A5),A1		;point to data area
	MOVE.L  A1,D1
	LEA     DisableDiskIndexInt,A1
	MOVEM.L D1/A1,$11E(A3)		;save D1 and A1 in interrupt structure
	LEA     EnableDiskIndexInt,A1
1$:	JSR     (A4)
	MOVE.B  D0,IO_ERROR(A2)

RawExit:
	MOVEA.L A2,A1
	BSR.L   SendReplyMsg
	UNLK    A5			;clean up stack
	MOVEM.L (A7)+,D2-D3/A2-A4
	RTS

RawReqError:
	MOVE.B  #IOERR_BADLENGTH,IO_ERROR(A2)
	BRA.S   RawExit

* Instead of starting DMA, execute this code to enable disk index
* interrupt.  Then when that interrupt occurs, execute the following routine.

EnableDiskIndexInt:
	MOVEA.L $11E(A3),A0	;load index interrupt IS_DATA ptr
	MOVEM.L D0/A6,(A0)	;save D0 and A6
	MOVEQ   #$10,D0		;ICR bit 4 = disk index interrupt
	MOVE.L  A6,-(A7)
	MOVEA.L CIABBase(A6),A6
	JSR     SetICR(A6)	;clear any pending disk index interrupt
	MOVEA.L (A7)+,A6
	MOVE.L  #$90,D0		;int enable bit plus disk index bit
	MOVE.L  A6,-(A7)
	MOVEA.L CIABBase,A6
	JSR     AbleICR(A6)	;enable disk index interrupts
	MOVEA.L (A7)+,A6
	RTS

* When disk index interrupt occurs, start DMA transfer and disable disk
* index interrupts.

DisableDiskIndexInt:
	MOVE.L  A2,-(A7)
	MOVEA.L A1,A2
	MOVE.L  (A2),D0
	LEA     $DFF000,A1
	BSR.L   StartDMA
	MOVEA.L 4(A2),A0
	MOVEA.L CIABBase(A0),A0
	MOVEQ   #$10,D0		;bit 4=disk index interrupt
	MOVE.L  A6,-(A7)
	MOVEA.L A0,A6
	JSR     AbleICR(A6)	;disable disk index interrupts
	MOVEA.L (A7)+,A6
	MOVEA.L (A7)+,A2	;set Z=0...interrupt processed
	RTS

GetDriveTypeCmd:
	MOVEQ   #0,D0
	MOVE.B  DriveType(A3),D0
	MOVE.L  D0,IO_ACTUAL(A2)
	MOVEA.L A2,A1
	BSR.L   SendReplyMsg
	RTS

GetNumTracksCmd:
	MOVEQ   #0,D0
	MOVE.W  MaxTracks(A3),D0
	MOVE.L  D0,IO_ACTUAL(A2)
	MOVEA.L A2,A1
	BSR.L   SendReplyMsg
	RTS

EndCode	END
