
 *
 * Insert your own functions by replacing the FunctionA() and FunctionB()
 * example functions.
 *
 * Simply compile this program, as Linkable, to make an object (.o or .obj)
 * file and then BLink the created object file, with:
 *
 * BLink FROM ram:filename.o LIBRARY Libs:Amiga.lib TO ram:filename.device
 *
 * For example. Compile this program into Ram:, using the devpac Linkable
 * option instead of the Executable option. Use a filename like jw.o 
 * When the compiler has created jw.o you then:
 *
 * Blink FROM Ram:jw.o LIBRARY Libs:Amiga.lib TO Ram:jw.device
 *
 * The file created with BLink is now a Shared Run-Time Device, with the
 * FunctionA() and FunctionB() functions inside it.
 *

	SECTION	firstsection

	NOLIST

	INCDIR	WORK:Include/

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	exec/devices.i
	INCLUDE	exec/ables.i
	INCLUDE	exec/resident.i
	INCLUDE	exec/initializers.i
	INCLUDE	exec/io.i
	INCLUDE	exec/errors.i
	INCLUDE	exec/tasks.i
	INCLUDE	hardware/intbits.i
	INCLUDE	misc/jw_device.i

	IFNE	AUTOMOUNT
	INCLUDE	libraries/expansion.i
	INCLUDE	libraries/configvars.i
	INCLUDE	libraries/configregs.i
	ENDC

	LIST

	XDEF	InitTable
	XDEF	Open
	XDEF	Close
	XDEF	Expunge
	XDEF	Null
	XDEF	myName
	XDEF	BeginIO
	XDEF	AbortIO

	INT_ABLES

FirstAddress:
	moveq	#-1,d0
	rts

MYPRI	EQU	0

RomTag:
	dc.w	RTC_MATCHWORD
	dc.l	RomTag
	dc.l	EndCode
	dc.b	RTF_AUTOINIT
	dc.b	VERSION
	dc.b	NT_DEVICE
	dc.b	MYPRI
	dc.l	myName
	dc.l	idString
	dc.l	InitTable

	IFNE	INFO_LEVEL
subSysName:
	dc.b	"ramdev",0
	ENDC

myName:	DEVNAME

	IFNE	AUTOMOUNT
ExLibName	dc.b	'expansion.library',0
	ENDC

VERSION		EQU	39

REVISION	EQU	1

idString:	dc.b	'ramdev	39.1 (26.12.2000)',13,10,0

	ds.w	0

InitTable:
	dc.l	MyDev_Sizeof
	dc.l	funcTable
	dc.l	dataTable
	dc.l	initRoutine

funcTable:
	dc.l	Open
	dc.l	Close
	dc.l	Expunge
	dc.l	Null
	dc.l	BeginIO
	dc.l	AbortIO
	dc.l	FunctionA
	dc.l	FunctionB
	dc.l	-1

dataTable:
	INITBYTE	LN_TYPE,NT_DEVICE
	INITLONG	LN_NAME,myName
	INITBYTE	LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
	INITWORD	LIB_VERSION,VERSION
	INITWORD	LIB_REVISION,REVISION
	INITLONG	LIB_IDSTRING,idString
	DC.W	0

initRoutine:
*	PUTMSG	5,<'%$/Init: called'>
	movem.l	d1-d7/a0-a5,-(sp)
	move.l	d0,a5
	move.l	a6,md_SysLib(a5)
	move.l	a0,md_SegList(a5)
	IFNE	AUTOMOUNT
	lea.l	ExLibName,a1
	clr.l	d0
	jsr	_LVOOpenLibrary(a6)
	tst.l	d0
	beq	Init_Error
	move.l	d0,a4
	clr.l	d3
	lea	md_Base(a5),a0
	moveq.l	#4,d0
	LINKLIB	_LVOGetCurrentBinding,a4
	move.l	md_Base(a5),d0
	tst.l	d0
	beq	Init_End
*	PUTMSG	10,<'%$/Init: GetCurrentBinding returned non-zero'>
	move.l	d0,a0
	move.l	cd_BoardAddr(a0),md_Base(a5)
	bclr.b	#CDB_CONFIGME,cd_Flags(a0)
	move.l	#MEMF_CLEAR!MEMF_PUBLIC,d1
	move.l	#mdn_SIZEOF,d0
	jsr	AllocMem(a6)
*	tst.l	d0
*	beq	Init_End
	move.l	d0,a3
	move.l	d0,a2
	clr.l	d0
	lea.l	mdn_Init(pc),a1
	jsr	InitStruct(a6)
	lea.l	mdn_dName(a3),a0
	move.l	a0,mdn_dosName(a3)
	clr.l	d6

Uloop:
	move.b	d6,d0
	add.b	#48,d0
	move.b	d0,mdn_dName+2(a3)
	move.l	d6,mdn_unit(a3)
	move.l	a3,a0
	LINKLIB	_LOVMakeDosNode,a4
	move.l	d0,a0
	clr.l	d0
	clr.l	d1
*	moveq.l	#ADNF_STARTPROC,d1
	LINKLIB	_LOVAddDosNode,a4
	addq.l	#1,d6
	cmp.b	#MD_NUMUNITS,d6
	bls.s	Uloop
	move.l	a3,a1
	move.l	#mdn_Sizeof,d0
	jsr	_LVOFreeMem(a6)

Init_End:
	move.l	a4,a1
	jsr	_LVOCloseLibrary(a6)
	ENDC
	move.l	a5,d0

Init_Error:
	movem.l	(sp)+,d1-d7/a0-a5
	rts

Open:
	addq.w	#1,LIB_OPENCNT(a6)
*	PUTMSG	20,<'%$/Open: called'>
	movem.l	d2/a2/a3/a4,-(sp)
	move.l	a1,a2
	cmp.l	#MD_NUMUNITS,d0
	bcc.s	Unit_Invalid
	move.l	d0,d2
	lsl.l	#2,d0
	lea.l	md_Units(a6,d0.l),a4
	move.l	(a4),d0
	bne.s	UnitOK
	bsr	InitUnit
	move.l	(a4),d0
	beq.s	Open_Error

UnitOK:
	move.l	d0,a3
	move.l	d0,IO_UNIT(a2)
	addq.w	#1,LIB_OPENCNT(a6)
	addq.w	#1,UNIT_OPENCNT(a3)
	bclr	#LIBB_DELEXP,md_Flags(a6)
	clr.l	d0
	move.b	d0,IO_ERROR(a2)
	move.b	#NT_REPLYMSG,LN_TYPE(a2)
Open_End:
	subq.w	#1,LIB_OPENCNT(a6)
	movem.l	(sp)+,d2/a2/a3/a4
	rts

Unit_Invalid:

Open_Error:
	moveq.l	#IOERR_OPENFAIL,d0
	move.b	d0,IO_ERROR(a2)
	move.l	d0,IO_DEVICE(a2)
*	PUTMSG	2,<'%$/Open: failed'>
	bra.s	Open_End

Close:
	movem.l	d1/a2-a3,-(sp)
*	PUTMSG	20,<'%$/Close: called'>
	move.l	a1,a2
	move.l	IO_UNIT(a2),a3
	moveq.l	#-1,d0
	move.l	d0,IO_UNIT(a2)
	move.l	d0,IO_DEVICE(a2)
	subq.w	#1,UNIT_OPENCNT(a3)
*	bne.s	Close_Device
*	bsr	ExpungeUnit

Close_Device:
	clr.l	d0
	subq.w	#1,LIB_OPENCNT(a6)
	bne.s	Close_End
	btst	#LIBB_DELEXP,md_Flags(a6)
	beq.s	Close_End
	bsr.s	Expunge

Close_End:
	movem.l	(sp)+,d1/a2-a3
	rts

Expunge:
*	PUTMSG	10,<'%$/Expunge: called'>
	movem.l	d1/d2/a5/a6,-(sp)
	move.l	a6,a5
	move.l	md_SysLib(a5),a6
	tst.w	LIB_OPENCNT(a5)
	beq.s	1$
	bset	#LIBB_DELEXP,md_Flags(a5)
	clr.l	d0
	bra.s	Expunge_End
1$:
	move.l	md_SegList(a5),d2
	move.l	a5,a1
	jsr	_LVORemove(a6)
	move.l	a5,a1
	clr.l	d0
	move.w	LIB_NEGSIZE(a5),d0
	suba.l	d0,a1
	add.w	LIB_POSSIZE(a5),d0
	jsr	_LVOFreeMem(a6)
	move.l	d2,d0

Expunge_End:
	movem.l	(sp)+,d1/d2/a5/a6
	rts

Null:
*	PUTMSG	1,<'%$/Null: called'>
	clr.l	d0
	rts

FunctionA:
	add.l	d1,d0
	rts

FunctionB:
	add.l	d0,d0
	rts

InitUnit:
*	PUTMSG	30,<'%$/InitUnit: called'>
	movem.l	d2-d4/a2,-(sp)
	move.l	#MyDevUnit_Sizeof,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	LINKSYS	AllocMem,md_SysLib(a6)
	tst.l	d0
	beq	InitUnit_End
	move.l	d0,a3
	clr.l	d0
	move.l	a3,a2
	lea.l	mdu_Init(pc),a1
	LINKSYS	InitStruct,md_SysLib(a6)
	move.l	#$42414400,mdu_RAM(a3)
	move.b	d2,mdu_UnitNum(a3)
	move.l	a6,mdu_Device(a3)
	lea	mdu_stack(a3),a0
	move.l	a0,mdu_tcb+TC_SPLOWER(a3)
	lea	PROCSTACKSIZE(a0),a0
	move.l	a0,mdu_tcb+TC_SPUPPER(a3)
	move.l	a3,-(a0)
	move.l	a0,mdu_tcb+TC_SPREG(a3)
	lea	mdu_tcb(a3),a0
	move.l	a0,MP_SIGTASK(a3)
	IFGE	INFO_LEVEL-30
	move.l	a0,-(sp)
	move.l	a3,-(sp)
*	PUTMSG	30,<'%$/InitUnit, unit= %lx, task=%lx'>
	addq.l	#8,sp
	ENDC
	lea	MP_MSGLIST(a3),a0
	NEWLIST	a0
	IFD	INTRRUPT
	move.l	a3,mdu_is+IS_DATA(a3)
	ENDC
	lea	mdu_tcb(a3),a1
	lea	Task_Begin(PC),a2
	move.l	a3,-(sp)
	move.w	#-1,a3
	clr.l	d0
*	PUTMSG	30,<'%$/About to add task'>
	LINKSYS	AddTask,md_SysLib(a6)
	move.l	(sp)+,a3
	move.l	d2,d0
	lsl.l	#2,d0
	move.l	a3,md_Units(a6,d0.l)
*	PUTMSG	30,<'%$/InitUnit: ok'>

InitUnit_End:
	movem.l	(sp)+,d2-d4/a2
	rts

FreeUnit:
	move.l	a3,a1
	move.l	#MyDevUnit_Sizeof,d0
	LINKSYS	FreeMem,md_SysLib(a6)
	rts

ExpungeUnit:
*	PUTMSG	10,<'%$/ExpungeUnit: called'>
	move.l	d2,-(sp)
	IFD	INTRRUPT
	lea.l	mdu_is(a3),a1
	moveq.l	#INTB_PORTS,d0
	LINKSYS	RemIntServer,md_SysLib(a6)
	ENDC
	lea	mdu_tcb(a3),a1
	LINKSYS	RemTask,md_SysLib(a6)
	clr.l	d2
	move.b	mdu_UnitNum(a3),d2
	bsr.s	FreeUnit
	lsl.l	#2,d2
	clr.l	md_Units(a6,d2.l)
	move.l	(sp)+,d2
	rts

cmdtable:
	DC.L	Invalid
	DC.L	MyReset
	DC.L	RdWrt
	DC.L	RdWrt
	DC.L	Update
	DC.L	Clear
	DC.L	MyStop
	DC.L	Start
	DC.L	Flush
	DC.L	Motor
	DC.L	Seek
	DC.L	RdWrt
	DC.L	MyRemove
	DC.L	ChangeNum
	DC.L	ChangeState
	DC.L	ProtStatus
	DC.L	RawRead
	DC.L	RawWrite
	DC.L	GetDriveType
	DC.L	GetNumTracks
	DC.L	AddChangeInt
	DC.L	RemChangeInt
cmdtable_end:

IMMEDIATES	EQU	$FFFFF7F3

	IFD	INTRRUPT
	NEVERIMMED	EQU	$0000080C
	ENDC

BeginIO:
	IFGE	INFO_LEVEL-1
	bchg.b	#1,$bfe001
	ENDC
	IFGE	INFO_LEVEL-3
	clr.l	-(sp)
	move.w	IO_COMMAND(a1),2(sp)
*	PUTMSG	3,<'%$/BeginIO  -- $%lx'>
	addq.l	#4,sp
	ENDC
	movem.l	d1/a0/a3,-(sp)
	move.b	#NT_MESSAGE,LN_TYPE(a1)
	move.l	IO_UNIT(a1),a3
	move.w	IO_COMMAND(a1),d0
	cmp.w	#MYDEV_END,d0
	bcc	BeginIO_NoCmd
	move.l	#IMMEDIATES,d1
	DISABLE	a0
	btst.l	d0,d1
	bne.s	BeginIO_Immediate
	IFD	INTRRUPT
	move.w	#NEVERIMMED,d1
	btst	d0,d1
	bne.s	BeginIO_QueueMsg
	ENDC
	btst	#MDUB_STOPPED,UNIT_FLAGS(a3)
	bne.s	BeginIO_QueueMsg
	bset	#UNITB_ACTIVE,UNIT_FLAGS(a3)
	beq.s	BeginIO_Immediate

BeginIO_QueueMsg:
	bset	#UNITB_INTASK,UNIT_FLAGS(a3)
	bclr	#IOB_QUICK,IO_FLAGS(a1)
	ENABLE	a0
	IFGE	INFO_LEVEL-250
	move.l	a1,-(sp)
	move.l	a3,-(sp)
*	PUTMSG	250,<'%$/PutMsg: port=%lx, message=%lx'>
	addq.l	#8,sp
	ENDC
	move.l	a3,a0
	LINKSYS	PutMsg,md_SysLib(a6)
	bra.s	BeginIO_End

BeginIO_Immediate:
	ENABLE	a0
	bsr.s	PerformIO

BeginIO_End:
*	PUTMSG	200,<'%$/BeginIO_End'>
	movem.l	(sp)+,d1/a0/a3
	rts

BeginIO_NoCmd:
	move.b	#IOERR_NOCMD,IO_ERROR(a1)
	bra.s	BeginIO_End

PerformIO:
	IFGE	INFO_LEVEL-150
	clr.l	-(sp)
	move.w	IO_COMMAND(a1),2(sp)
*	PUTMSG	150,<'%$/PerformIO  -- $%lx'>
	addq.l	#4,sp
	ENDC
	clr.l	d0
	move.b	d0,IO_ERROR(A1)
	move.b	IO_COMMAND+1(a1),d0
	lsl.w	#2,d0
	lea.l	cmdtable(pc),a0
	move.l	0(a0,d0.w),a0
	jmp	(a0)

TermIO:
*	PUTMSG	160,<'%$/TermIO'>
	move.w	IO_COMMAND(a1),d0
	move.w	#IMMEDIATES,d1
	btst	d0,d1
	bne.s	TermIO_Immediate
	btst	#UNITB_INTASK,UNIT_FLAGS(a3)
	bne.s	TermIO_Immediate
	bclr	#UNITB_ACTIVE,UNIT_FLAGS(a3)

TermIO_Immediate:
	btst	#IOB_QUICK,IO_FLAGS(a1)
	bne.s	TermIO_End
	LINKSYS	ReplyMsg,md_SysLib(a6)

TermIO_End:
	rts

AbortIO:
	moveq.l	#IOERR_NOCMD,d0
	rts

RawRead:

RawWrite:

Invalid:
	move.b	#IOERR_NOCMD,IO_ERROR(a1)
	bra.s	TermIO

Update:

Clear:

MyReset:

AddChangeInt:

RemChangeInt:

MyRemove:

Seek:

Motor:

ChangeNum:

ChangeState:

ProtStatus:
	clr.l	IO_ACTUAL(a1)
	bra.s	TermIO

GetDriveType:
	moveq.l	#53,d0
	move.l	d0,IO_ACTUAL(a1)
	bra.s	TermIO

GetNumTracks:
	move.l	#RAMSIZE/BYTESPERTRACK,IO_ACTUAL(a1)
	bra.s	TermIO

Foo:

Bar:
	clr.l	IO_ACTUAL(a1)
	bra	TermIO

RdWrt:
	IFGE	INFO_LEVEL-200
	move.l	IO_DATA(a1),-(sp)
	move.l	IO_OFFSET(a1),-(sp)
	move.l	IO_LENGTH(a1),-(sp)
*	PUTMSG	200,<'%$/RdWrt len %ld offset %ld data $%lx'>
	addq.l	#8,sp
	addq.l	#4,sp
	ENDC
	movem.l	a2/a3,-(sp)
	move.l	a1,a2
	move.l	IO_UNIT(a2),a3
	btst.b	#0,IO_DATA+3(a2)
	bne.s	IO_LenErr
	move.l	IO_OFFSET(a2),d0
	move.l	d0,d1
	and.l	#SECTOR-1,d1
	bne.s	IO_LenErr
	add.l	IO_LENGTH(a2),d0
	bcs.s	IO_LenErr
	cmp.l	#RAMSIZE,d0
	bhi.s	IO_LenErr
	and.l	#SECTOR-1,d0
	bne.s	IO_LenErr
	IFD	INTRRUPT
	move.l	mdu_SigMask(a3),d0
	LINKSYS	Wait,md_SysLib(a6)
	ENDC
	lea.l	mdu_RAM(a3),a0
	add.l	IO_OFFSET(a2),a0
	move.l	IO_LENGTH(a2),d0
	move.l	d0,IO_ACTUAL(a2)
	beq.s	RdWrt_End
	move.l	IO_DATA(a2),a1
	cmp.b	#CMD_READ,IO_COMMAND+1(a2)
	beq.s	CopyTheBlock
	exg	a0,a1

CopyTheBlock:
	LINKSYS	CopyMemQuick,md_SysLib(a6)

RdWrt_End:
	move.l	a2,a1
	movem.l	(sp)+,a2/a3
	bra	TermIO

IO_LenErr:
*	PUTMSG	10,<'%$/bad length'>
	move.b	#IOERR_BADLENGTH,IO_ERROR(a2)

IO_End:
	clr.l	IO_ACTUAL(a2)
	bra.s	RdWrt_End

MyStop:
*	PUTMSG	30,<'%$/MyStop: called'>
	bset	#MDUB_STOPPED,UNIT_FLAGS(a3)
	bra	TermIO

Start:
*	PUTMSG	30,<'%$/Start: called'>
	bsr.s	InternalStart
	bra	TermIO

InternalStart:
	move.l	a1,-(sp)
	bclr	#MDUB_STOPPED,UNIT_FLAGS(a3)
	move.b	MP_SIGBIT(a3),d1
	clr.l	d0
	bset	d1,d0
	move.l	MP_SIGTASK(a3),a1
	LINKSYS	Signal,md_SysLib(a6)
	move.l	(sp)+,a1
	rts

Flush:
*	PUTMSG	30,<'%$/Flush: called'>
	movem.l	d2/a1/a6,-(sp)
	move.l	md_SysLib(a6),a6
	bset	#MDUB_STOPPED,UNIT_FLAGS(a3)
	sne	d2

Flush_Loop:
	move.l	a3,a0
	jsr	_LVOGetMsg(a6)
	tst.l	d0
	beq.s	Flush_End
	move.l	d0,a1
	move.b	#IOERR_ABORTED,IO_ERROR(a1)
	jsr	_LVOReplyMsg(a6)
	bra.s	Flush_Loop

Flush_End:
	move.l	d2,d0
	movem.l	(sp)+,d2/a1/a6
	tst.b	d0
	beq.s	1$
	bsr	InternalStart
1$:
	bra	TermIO

	cnop	0,4
	DC.L	16

myproc_seglist:
	DC.L	0

Task_Begin:
*	PUTMSG	35,<'%$/Task_Begin'>
	move.l	4.w,a6
	move.l	4(sp),a3
	move.l	mdu_Device(a3),a5
	IFD	INTRRUPT
	moveq.l	#-1,d0
	jsr	_LVOAllocSignal(a6)
	move.b	d0,mdu_SigBit(a3)
	clr.l	d7
	bset	d0,d7
	move.l	d7,mdu_SigMask(a3)
	lea.l	mdu_is(a3),a1
	moveq	#INTB_PORTS,d0
	jsr	AddIntServer(a6)
	move.l	md_Base(a5),a0
	bset.b	#INTENABLE,INTCTRL2(a0)
	ENDC
	moveq.l	#-1,d0
	jsr	_LVOAllocSignal(a6)
	move.b	d0,MP_SIGBIT(a3)
	move.b	#PA_SIGNAL,MP_FLAGS(a3)
	clr.l	d7
	bset	d0,d7
	IFGE	INFO_LEVEL-40
	move.l	#$114(a6),-(sp)
	move.l	a5,-(sp)
	move.l	a3,-(sp)
	move.l	d0,-(sp)
*	PUTMSG	40,<'%$/Signal=%ld, Unit=%lx, Device=%lx, Task=%lx'>
	add.l	#4*4,sp
	ENDC
	bra.s	Task_StartHere

Task_Unlock:
	and.b	#$FF&(~(UNITF_ACTIVE!UNITF_INTASK)),UNIT_FLAGS(a3)

Task_MainLoop:
*	PUTMSG	75,<'%$/++Sleep'>
	move.l	d7,d0
	jsr	_LVOWait(a6)
	IFGE	INFO_LEVEL-5
	bchg.b	#1,$bfe001
	ENDC

Task_StartHere:
*	PUTMSG	75,<'%$/++Wakeup'>
	btst	#MDUB_STOPPED,UNIT_FLAGS(a3)
	bne.s	Task_MainLoop
	bset	#UNITB_ACTIVE,UNIT_FLAGS(a3)
	bne.s	Task_MainLoop

Task_NextMessage:
	move.l	a3,a0
	jsr	_LVOGetMsg(a6)
*	PUTMSG	1,<'%$/GotMsg'>
	tst.l	d0
	beq	Task_Unlock
	move.l	d0,a1
	exg	a5,a6
	bsr	PerformIO
	exg	a5,a6
	bra.s	Task_NextMessage
	IFD	INTRRUPT
myintr:
	move.l	mdu_Device(a1),a0
	move.l	mdu_SigMask(a1),d0
	lea.l	mdu_tcb(a1),a1
	move.l	md_SysLib(a0),a6
	jsr	_LVOSignal(a6)

myexnm:	clr.l	d0

myexit:	rts
	ENDC

mdu_Init:
	INITBYTE	MP_FLAGS,PA_IGNORE
	INITBYTE	LN_TYPE,NT_MSGPORT
	INITLONG	LN_NAME,myName
	INITLONG	mdu_tcb+LN_NAME,myName
	INITBYTE	mdu_tcb+LN_TYPE,NT_TASK
	INITBYTE	mdu_tcb+LN_PRI,5
	IFD	INTRRUPT
	INITBYTE	mdu_is+LN_PRI,4
	INITLONG	mdu_is+IS_CODE,myintr
	INITLONG	mdu_is+LN_NAME,myName
	ENDC
	DC.W	0

	IFNE	AUTOMOUNT
mdn_init:
	INITLONG	mdn_execName,myName
	INITLONG	mdn_tableSize,12
	INITLONG	mdn_dName,$524D0000
	INITLONG	mdn_sizeBlock,SECTOR/4
	INITLONG	mdn_numHeads,1
	INITLONG	mdn_secsPerBlk,1
	INITLONG	mdn_blkTrack,SECTORSPER
	INITLONG	mdn_resBlks,1
	INITLONG	mdn_upperCyl,(RAMSIZE/BYTESPERTRACK)-1
	INITLONG	mdn_numBuffers,1
	DC.W	0
	ENDC

EndCode:

	END