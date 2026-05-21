*****************************************************************
*								*
*		      Mac-2-Dos					*
*								*
*		Mac Disk Non-Driver Routines			*
*								*
*	Copyright (c) 1989 Central Coast Software		*
*	424 Vista Avenue, Golden, CO 80401			*
*	     All rights reserved, worldwide			*
*								*
*****************************************************************

	INCLUDE "DH1:MAC/DEV/MF.I"
	INCLUDE	"DH1:MAC/I/MACROS.ASM"

	XDEF	ReadSector,ReadN,WriteSector,WriteN
	XDEF	OpenMacDrive,CloseMacDrive
	XDEF	MotorOn,MotorOff,DiskChanged
	XDEF	GetDriveStatus,Eject
	XDEF	FormatTrack,FlushTrack
	XDEF	PacketIO,PktArg2,PktArg3,PktArg4
	XDEF	CheckWrtProt
	XDEF	GetDriveType

	XDEF	DiskChgFlag

	XREF	BuildMacDir,ClearMacWindow
	XREF	_CreatePort,_DeletePort,_CreateStdIO,_DeleteStdIO
	XREF	DISP_RETRY,NoMacDisk
	XREF	CheckForDiskChange

	XREF	SysBase,DosBase,MacTask,WINDOW
	XREF	ValidMacVol
	XREF	_AbsExecBase
	XREF	TMP.,TMP2.
	XREF	AbortFlg

	XREF	OpenMacDevice,CloseMacDevice,DoMacIO

pr_MsgPort	EQU	$5C
ln_Name		EQU	10	;list node name offset
wd_UserPort	EQU	$56	;user port in window

* Read n physical sectors (blocks).  Block number (0 origin) in D0.
* Number of contiguous blocks in D1.  User's buffer address in A0.
* Returns A0 updated.

ReadN:	DECW	D1		;FOR DBF
1$:	PUSH	D0-D1/A0
	BSR.S	ReadSector
	POP	D0-D1/A0
	ERROR	2$
	ADDA.L	#512,A0
	INCW	D0		;NEXT BLOCK
	DBF	D1,1$		;DO THEM ALL
	CLC
2$:	RTS

ReadSector:
	PUSH	D2/A2
	EXT.L	D0
	MOVE.L	D0,D2			;save input params
	MOVE.L	A0,A2
1$:	MOVE.L	DevIOB,A1		;use existing IOB
	MOVE.L	A0,IO_DATA(A1)
	MOVE.W	#CMD_READ,IO_COMMAND(A1)
	MOVEQ	#9,D1
	LSL.L	D1,D0
	MOVE.L	D0,IO_OFFSET(A1)
	MOVE.L	#512,IO_LENGTH(A1)
	BSR	PerformDiskIO		;do the read
	IFZL	D0,9$			;no error
	LEA	MacReadErr.,A0
	BSR	MacDriveError		;report error and ask what to do
	ERROR	9$			;op requested to bail out
	MOVE.L	D2,D0			;else reload input params...
	MOVE.L	A2,A0
	BRA.S	1$			;...and try again
9$:	POP	D2/A2
	RTS

* Write n physical sectors (blocks).  Block number (0 origin) in D0.
* Number of contiguous blocks in D1.  User's buffer address in A0.
* Returns A0 updated.

WriteN:	DECW	D1		;FOR DBF
1$:	PUSH	D0-D1/A0
	BSR.S	WriteSector
	POP	D0-D1/A0
	ERROR	2$
	ADDA.L	#512,A0
	INCW	D0		;NEXT BLOCK
	DBF	D1,1$		;DO THEM ALL
	CLC
2$:	RTS

* Writes one sector, as determined by sector number in D0.  A0 points to
* data buffer.

WriteSector:
	PUSH	D2/A2
	EXT.L	D0
	MOVE.L	D0,D2
	MOVE.L	A0,A2
1$:	MOVE.L	DevIOB,A1
	MOVE.W	#CMD_WRITE,IO_COMMAND(A1)
	MOVE.L	A0,IO_DATA(A1)
	MOVEQ	#9,D1
	LSL.L	D1,D0
	MOVE.L	D0,IO_OFFSET(A1)
	MOVE.L	#512,IO_LENGTH(A1)
	BSR	PerformDiskIO
	IFZL	D0,9$
	LEA	MacWriteErr.,A0
	BSR	MacDriveError
	ERROR	9$
	MOVE.L	D2,D0
	MOVE.L	A2,A0
	BRA.S	1$
9$:	POP	D2/A2
	RTS

* Formats one track, as determined by sector number (0-799, 0-1599) in D0.
* Sector must be first sector of track.  A0 points to data to be
* written to track.  Count of sectors to write in D1.

FormatTrack:
	PUSH	D2
	EXT.L	D0
	MOVE.L	DevIOB,A1
	MOVE.W	#TD_FORMAT,IO_COMMAND(A1)
	MOVE.L	A0,IO_DATA(A1)
	MOVEQ	#9,D2
	LSL.L	D2,D0
	MOVE.L	D0,IO_OFFSET(A1)
	LSL.L	D2,D1
	MOVE.L	D1,IO_LENGTH(A1)
	BSR	PerformDiskIO
	IFZL	D0,9$
	BSR	MotorOff
	DispErr	MacFormErr.
	STC
9$:	POP	D2
	RTS

FlushTrack:
	MOVE.W	#CMD_UPDATE,D0
	MOVE.L	DevIOB,A1
	BSR	DiskIO			;flush current track, if any
	NOERROR	9$
	DispErr	MacWriteErr.
	STC
9$:	RTS

OpenMacDrive:
	PEA	0
	PEA	0
	JSR	_CreatePort
	ADDQ.L	#8,SP
	MOVE.L	D0,DevPort
	BEQ.S	9$			;failed to create port
	MOVE.L	D0,-(SP)
	JSR	_CreateStdIO
	ADDQ.L	#4,SP
	MOVE.L	D0,DevIOB
	BEQ.S	9$			;failed to create IOB
;	MOVE.L	D0,A1
	BSR	InhibitDriver
	MOVE.L	DevIOB,A1
	BSR	OpenMacDevice
	RTS
9$:	STC
	RTS

CloseMacDrive:
	IFZL	DevIOB,9$		;device already free
	MOVE.L	DevIOB,A1
	BSR	CloseMacDevice
	BSR	EnableDriver
	MOVE.L	DevIOB,D0
;	BEQ.S	1$
	MOVE.L	D0,-(SP)
	JSR	_DeleteStdIO
	ADDQ.L	#4,SP
	CLR.L	DevIOB
1$:	MOVE.L	DevPort,D0
	BEQ.S	9$
	MOVE.L	D0,-(SP)
	JSR	_DeletePort
	ADDQ.L	#4,SP
	CLR.L	DevPort
9$:	RTS

DICom:	MOVE.L	A0,IO_DATA(A1)		;pass new vector in IOB
	MOVE.W	#TD_REMOVE,D0
DiskIO:
	MOVE.W	D0,IO_COMMAND(A1)
	CLR.B	IO_ERROR(A1)
	BSR	DoMacIO
	MOVE.L	DevIOB,A1
	IFZL	D0,1$
	MOVE.B	IO_ERROR(A1),D0
	STC
1$:	MOVE.L	IO_ACTUAL(A1),D0	;return previous vector
	RTS

* This is so we can go with either form of driver software.

PerformDiskIO:
	CLR.B	IO_ERROR(A1)	;make sure no previous errors show up
	BSR	DoMacIO
	RTS

* Uses TD_RAWWRITE to force disk to be ejected.

Eject:
	CLR.B	ValidMacVol
	BSR	ClearMacWindow
	BSR	NoMacDisk
	BSR	GetDriveStatus
	IFNZL	D0,9$			;no disk...ignore cmd
	MOVE.W	#TD_RAWWRITE,D0
	MOVE.L	DevIOB,A1
	BSR	DiskIO			;eject disk, if any
9$:	RTS

CheckWrtProt:
	MOVE.W	#TD_PROTSTATUS,D0
	MOVE.L	DevIOB,A1
	BSR	DiskIO			;check on disk protected status
	IFZL	D0,9$			;OK
	DispErr	WrtProt.
	STC
9$:	RTS

* Called after disk change interrupt.  Task wakes up to find out 
* what has happened.

DiskChanged:
	BSR	CheckForDiskChange
	BCLR	#0,DiskChgFlag
	BEQ.S	9$			;no change...ignore call
	CLR.B	ValidMacVol		;force reread of disk
	BSR	ClearMacWindow
	BSR	NoMacDisk
	BSR	GetDriveStatus		;disk loaded?
	ERROR	9$			;oos...something wrong
	IFNZL	D0,9$			;no disk loaded
	BSR	BuildMacDir		;else relog and display root
9$:	RTS

* Interrogates drive to find out if a disk is loaded.  Returns D0=0 YES,
* and D0<>0 if NO.

GetDriveStatus:
	MOVE.W	#TD_CHANGESTATE,D0
	MOVE.L	DevIOB,A1
	BSR	DiskIO			;check out status
	RTS

* Interrogates drive to find out if it is single-sided or double-sided.
* Returns D0=0 for single-sided, D0<>0 for double-sided.

GetDriveType:
	MOVE.W	#TD_GETDRIVETYPE,D0
	MOVE.L	DevIOB,A1
	BSR	DiskIO			;check out status
	RTS

* Builds signal bits for use by WAIT from the window user port.

BuildSigBits:
	MOVE.L	WINDOW,A0
	MOVE.L	wd_UserPort(A0),A0	;ptr to IDCMP msg port
	IFZL	A0,9$			;NO port
	ZAP	D0
	MOVE.B	MP_SIGBIT(A0),D1	;signal bit number=number to shift
	BSET	D1,D0
9$:	RTS

* Used to correct date on Dos file after creating it.  Called from DosFiles.

PacketIO:
	PUSH	A4
	MOVE.L	D0,PktType		;save packet type
	MOVE.L	MacTask,A4
	LEA	pr_MsgPort(A4),A4	;point to our own port
	MOVE.L	A4,PktPort		;reload reply port
	LEA	Packet,A1
	MOVE.L	#DosPkt,ln_Name(A1)
	CALLSYS	PutMsg,SysBase		;send the packet
	MOVE.L	A4,A0
	CALLSYS	WaitPort		;wait for a reply
	LEA	Packet,A1
	CALLSYS	Remove			;dequeue the packet
	MOVE.L	PktRes1,D0		;response in D0
	POP	A4
	RTS

* These routines turn off and on the Mac drive ADOS driver, which runs
* completely independently of Mac-2-Dos, and must be kept out of our hair.

InhibitDriver:
	LEA	MF.,A1
	CALLSYS	FindTask,SysBase
	MOVE.L	D0,DriverTask
	BEQ.S	9$			;cant find task
	SUB.L	#tcb,D0
	MOVE.L	D0,DriverTask
	MOVE.L	D0,A0
1$:	BTST	#Mac_Motor,MacFlags(A0)	;motor on?
	BNE.S	1$			;wait till it goes off
	BSET	#Mac_Disabled,MacFlags(A0)
9$:	RTS

EnableDriver:
	MOVE.L	DriverTask,A0
	IFZL	A0,9$
	BCLR	#Mac_Disabled,MacFlags(A0)
9$:	RTS

MotorOn:
	MOVEQ	#1,D0
	BRA.S	MotCom
MotorOff:
	ZAP	D0
MotCom:
	MOVE.L	DevIOB,A1
	MOVE.W	#TD_MOTOR,IO_COMMAND(A1)
	MOVE.L	D0,IO_LENGTH(A1)
	BSR	PerformDiskIO
	RTS

* Called with drive error code in D0, and ptr to error msg in A0.  
* Puts up retry requester and asks op what to do.  CY=1 if op wants 
* to bail out.

MacDriveError:
	PUSH	D0/A0
	BSR	MotorOff
	POP	D0/A0
	BSR	DISP_RETRY		;give op a chance to retry
	NOERROR	9$
	SETF	AbortFlg
9$:	RTS

DevIOB		DC.L	0
DevPort		DC.L	0
DevProc		DC.L	0
DevVec		DC.L	0
DriverTask	DC.L	0
DiskChgFlag	DC.B	0	;1=disk change has occurred

MF.		TEXTZ	'macfloppy.device'
MacReadErr.	TEXTZ	<'Error reading Mac disk.'>
MacWriteErr.	TEXTZ	<'Error writing Mac disk.'>
MacFormErr.	TEXTZ	<'Error formatting Mac disk.'>
WrtProt.	TEXTZ	<'Mac disk is write-protected.'>
	CNOP	0,4

Packet
PktMsg	NODE	5,0,DosPkt
	DC.L	0
	DC.W	PMsgSize
DosPkt	DC.L	PktMsg
PktPort	DC.L	0
PktType	DC.L	0
PktRes1	DC.L	0
PktRes2	DC.L	0
PktArg1	DC.L	0
PktArg2	DC.L	0
PktArg3	DC.L	0
PktArg4	DC.L	0,0,0,0
PMsgSize EQU	*-PktMsg

	END

