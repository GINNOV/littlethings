*****************************************************************
*								*
* DOS-2-DOS routines for direct access to non-floppy devices	*
*								*
* This code assumes that there is a device driver in the 	*
* mountlist, and that this driver can be accessed the same way	*
* as trackdisk.device, but that the data has the logical 	*
* structure of an MS-DOS device.				*
*								*
*****************************************************************

	INCLUDE "D2DMAC.ASM"
	INCLUDE	"IO.MAC"

	XREF	SysBase,GraphicsBase,DosBase
	XREF	INPBUF.,TMP.,A.
	XREF	NotFlop
	XREF	DISK_INIT,DISK_EXIT

	XREF	_CreatePort,_DeletePort,_CreateStdIO,_DeleteStdIO
	XREF	DR_BASE,MD_DRV.,IS_3.5,D2D_TASK
	XREF	READ_ERR.,WRITE_ERR.

	XDEF	TryMountlist,OpenDev,CloseDev,OpenFlop,CloseFlop
	XDEF	DREAD_SECTOR,DWRITE_SECTOR,DMOTOR_OFF
	XDEF	CHECK_DRIVE_TYPE,ScanColon
	XDEF	DeviceReset,DeviceFlush
	XDEF	MsdosHandle,PartitionOffset

dl_Root		EQU	$22
rn_Info		EQU	$18
di_DevInfo	EQU	4
dn_Next		EQU	0
dn_Type		EQU	4
dn_Startup	EQU	$1C
dn_Name		EQU	$28
fssm_Unit	EQU	0
fssm_Device	EQU	4
fssm_Environ	EQU	8
fssm_Flags	EQU	$C
de_SizeBlock	EQU	4
de_NumHeads	EQU	$C
de_BlksPerTrack	EQU	$14
de_Reserved	EQU	$18
de_LowCyl	EQU	$24
de_HighCyl	EQU	$28

AFIX	MACRO	;reg - converts BPTR to APTR
	ADD.L	\1,\1
	ADD.L	\1,\1
	ENDM

MLBufSize	EQU	8000	;temp buffer for reading mountlist
MaxTok		EQU	4
DeviceList	EQU	$15E	;OFFSET TO EXEC DEVICE LIST FROM SYSBASE
DOSSignature	EQU	$F8001C ;DOS SIGNATURE IN ROM AREA
ACTION_INHIBIT	EQU	31
pr_MsgPort	EQU	$5C
ln_Name		EQU	10	;list node name offset
RetryLimit	EQU	5
OFFSET_BEGINNING EQU	-1	;seek offset flag

* Mult 16-bit <ea> (param1) times 32-bit reg (param2), result to param2.
* Param3 is working reg (destroyed).

LONGMUL	MACRO	;16-bit <ea>, 32-bit reg, working reg.
	MOVE.L	\2,\3
	SWAP	\3
	MULU	\1,\3
	SWAP	\3
	MULU	\1,\2
	ADD.L	\3,\2
	ENDM

* Despite the name, this routine attempts to find the device in the ADOS
* device list.  Returns CY=1 if no device, or if the device is not valid.
* Loads various params from the device list.

TryMountlist:
	PUSH	A2			;just in case...
	MOVE.L	DosBase,A2		;start from Dos library structure
	MOVE.L	dl_Root(A2),A2		;Dos RootNode
	MOVE.L	rn_Info(A2),A2		;Info structure
	AFIX	A2
	MOVE.L	di_DevInfo(A2),D0	;BPTR to device list
1$:	BNE.S	2$
	MOVE.	INPBUF.,TMP.
	APPEND.	NoDFn.,TMP.
	DISP.	TMP.			;oops...no drive
	STC
	BRA	9$
2$:	AFIX	D0			;make into APTR
	MOVE.L	D0,A2
	IFNZL	dn_Type(A2),3$		;not a device entry...
	MOVE.L	dn_Name(A2),A0		;BSTR ptr to device name
	LEA	TMP.,A1
	BSR	MoveBstr		;Move device name into TMP.
	Z_STG.	TMP.,A.			;convert to our string format
	ACHAR.	#':',A.			;ADOS doesn't keep ":"
	UCASE.	A.
	IFEQ.	INPBUF.,A.,4$		;is this the one we want?
3$:	MOVE.L	dn_Next(A2),D0		;no...get link to next entry
	BRA	1$			;and try it
4$:	MOVE.L	dn_Startup(A2),A2	;BPTR to FileSysStartupMsg
	AFIX	A2
	MOVE.L	fssm_Unit(A2),DevUnit	;save unit for open
	MOVE.L	fssm_Device(A2),A0	;BSTR ptr to driver name
	LEA	DeviceName,A1		;goes here
	BSR	MoveBstr
	MOVE.L	fssm_Flags(A2),DevFlags	;for later OpenDevice
	MOVE.L	fssm_Environ(A2),A2	;BSTR ptr to device params
	AFIX	A2
	MOVE.W	de_SizeBlock+2(A2),D0	;blocksize in longwords
	ASL	#2,D0			;convert to bytes per block
	MOVE.W	D0,BlockSize
	MOVE.W	de_NumHeads+2(A2),Surfaces
	MOVE.W	de_BlksPerTrack+2(A2),BlocksPerTrack
	MOVE.L	de_Reserved(A2),Reserved
	MOVE.L	de_LowCyl(A2),LowCyl
	MOVE.L	de_HighCyl(A2),HighCyl
	MOVE.L	LowCyl,D0		;now calculate offset based on LowCyl
	MULU	Surfaces,D0
	MULU	BlocksPerTrack,D0
	MOVE.L	D0,DriveOffset
9$:	POP	A2
	RTS

* Converts BSTR pointed to by A0 into normal stored at ptr in A1.

MoveBstr:
	CLR.B	(A1)			;zap dest string
	PUSH	A1			;dest string goes here
	AFIX	A0			;BPTR-->APTR
	ZAP	D0
	MOVE.B	(A0)+,D0		;get length of name
	BEQ.S	2$			;oops...no name?
	DECW	D0
1$:	MOVE.B	(A0)+,(A1)+
	DBF	D0,1$
	CLR.B	(A1)			;terminate name
2$:	POP	A0			;now clean up string
;	UCASE.	A0
	RTS

* Scans input string for imbedded colon, signaling dev:file.  Sets up
* MsdosHandle if all is well.

ScanColon:
	CLR.L	MsdosHandle
;	LEA	INPBUF.,A0		;check for possible dev:path/file
;	ZAP	D0
;	MOVE.B	(A0)+,D0		;get length
;	DECW	D0			;for loop
;	BEQ.S	2$			;oops...just add : and go
;3$:	MOVE.B	(A0)+,D1
;	CMPI.B	#':',D1			;found colon?
;	BEQ.S	4$			;yes...assume device:file
;	DBF	D0,3$			;else loop
;2$:	ACHAR.	#':',INPBUF.		;ELSE ADD A COLON
;	RTS
;4$:	SETF	NotFlop
	MOVE.	INPBUF.,TMP.
	STG_Z.	TMP.
	MOVE.L	#TMP.,D1
	MOVE.L	#EXISTING,D2
	CALLSYS	Open,DosBase		;try to open the device:file
	MOVE.L	D0,MsdosHandle		;handle for this file
	BEQ.S	8$
	MOVE.	MDDevice.,MD_DRV.	;use this name
	SETF	NotFlop
	CLC
	RTS
;8$:	DISP.	MDFileErr.		;cant open the MSDOS file
8$:	STC
	RTS

* Allocates a msg port and an IO block, then opens device driver.

OpenDev:
	BSR	OpenProc		;get handler task for this device
	BEQ.S	8$			;oops...no handler
	PEA	0
	PEA	0
	JSR	_CreatePort		;allocate msg port
	ADDQ.L	#8,SP
	MOVE.L	D0,DevPort
	BEQ.S	8$			;problems
	MOVE.L	D0,-(SP)
	JSR	_CreateStdIO		;allocate and init IOB
	ADDQ.L	#4,SP
	MOVE.L	D0,DevIOB
	BEQ.S	8$			;problems
	MOVE.L	D0,A1
	LEA	DeviceName,A0
	MOVE.L	DevUnit,D0		;get unit number
	MOVE.L	DevFlags,D1
	CALLSYS	OpenDevice,SysBase	;open it
	TST.L	D0
	BNE.S	8$			;bad open
	BSR	Inhibit			;keep ADos off our backs
	RTS
8$:	BSR.S	RelResources
	STC
	RTS

CloseDev:
	IFNZ	NotFlop,1$
	RTS
1$:	TST.L	MsdosHandle
	BEQ.S	2$
	MOVE.L	MsdosHandle,D1
	CALLSYS	Close,DosBase
	RTS
2$:	BSR	Enable
	MOVE.L	DevIOB,A1
	CALLSYS	CloseDevice,SysBase
RelResources:
	MOVE.L	DevIOB,D0
	BEQ.S	1$
	MOVE.L	D0,-(SP)
	JSR	_DeleteStdIO
	ADDQ.L	#4,SP
	CLR.L	DevIOB
1$:	MOVE.L	DevPort,D0
	BEQ.S	9$			;no port
	MOVE.L	D0,-(SP)
	JSR	_DeletePort
	ADDQ.L	#4,SP
	CLR.L	DevPort
9$:	RTS

OpenFlop:
	BSR	INHIBIT_ACCESS		;turn off trackdisk for this flop
	ERROR	9$			;no task found...no handler either
	BSR	OpenProc		;set up proc code
	BEQ.S	9$			;proc open failed
	BSR	Inhibit			;make AmigaDOS stay away from flop
9$:	JSR	DISK_INIT
	RTS

CloseFlop:
	IFZ	NotFlop,1$
	RTS
1$:	BSR	PERMIT_ACCESS
	BSR	Enable
	JSR	DISK_EXIT
	RTS

* Find file handler for MS-DOS device.

OpenProc:
	MOVE.	MD_DRV.,TMP.
	STG_Z.	TMP.
	MOVE.L	#TMP.,D1		;ptr to device id
	CALLSYS	DeviceProc,DosBase	;get handler
	MOVE.L	D0,DevProc		;save handler ptr
	RTS

* Keeps AmigaDOS from fooling around with a device while we use it.

Enable:
	ZAP	D0
	BRA.S	IECom
Inhibit:
	MOVEQ	#1,D0
IECom:	MOVE.L	D0,PktArg1		;store inhibit/enable code
	MOVEQ	#ACTION_INHIBIT,D0	;packet type
	TST.L	DevProc
	BEQ.S	9$			;no file handler...
	MOVE.L	DevProc,A0		;process ID of handler
	MOVE.L	D0,PktType		;save packet type
	MOVE.L	D2D_TASK,A4
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
9$:	RTS

* READ LOGICAL SECTOR.  LOGICAL SECTOR IN D0 (0 ORIGIN), BUFFER IN A0.

DREAD_SECTOR:
	PUSH	D2
	ADD.L	PartitionOffset,D0
	ADD.L	DriveOffset,D0		;offset based on LowCyl
	MOVE.L	#SectorSize,D1
	LONGMUL	D1,D0,D2		;calculate offset to byte
	POP	D2
	IFNZL	MsdosHandle,DRFile
	MOVE.B	#RetryLimit,RetryCount
	MOVE.L	DevIOB,A1
	MOVE.L	A0,io_Data(A1)		;buffer for read
	MOVE.L	D0,io_Offset(A1)
1$:	MOVEQ	#CMD_READ,D0
	MOVE.L	#SectorSize,D1
	BSR	DiskIO
	NOERROR	9$
	DECB	RetryCount
	BEQ.S	2$
	BSR	DeviceReset
	BRA.S	1$
2$:	DISP.	READ_ERR.
	STC
9$:	RTS

* Read sector from logical MSDOS file on AmigaDOS device

DRFile:
	PUSH	D2-D3
	BSR	SeekPos			;position to proper place in file
	ERROR 	9$
	MOVE.L	A0,D2			;buffer for read
	MOVE.L	MsdosHandle,D1		;now prepare to read
	MOVE.L	#SectorSize,D3		;amount to read
	CALLSYS	Read			;do the read
9$:	POP	D2-D3
	RTS

* WRITE LOGICAL SECTOR.  LOGICAL SECTOR IN D0 (0 ORIGIN), BUFFER IN A0.

DWRITE_SECTOR:
	PUSH	D2
	ADD.L	PartitionOffset,D0
	ADD.L	DriveOffset,D0		;offset based on LowCyl
	MOVE.L	#SectorSize,D1
	LONGMUL	D1,D0,D2		;calculate offset to byte
	POP	D2
	IFNZL	MsdosHandle,DWFile	;MSDOS file write
	MOVE.B	#RetryLimit,RetryCount
	MOVE.L	DevIOB,A1
	MOVE.L	A0,io_Data(A1)		;buffer for read
1$:	MOVE.L	D0,io_Offset(A1)
	MOVE.L	#SectorSize,D1
	MOVEQ	#CMD_WRITE,D0
	BSR	DiskIO
	NOERROR	9$
	DECB	RetryCount
	BNE.S	1$
	DISP.	WRITE_ERR.
	STC
9$:	RTS

DWFile:
	PUSH	D2-D3
	BSR.S	SeekPos			;position to proper place in file
	ERROR	9$
	MOVE.L	A0,D2
	MOVE.L	MsdosHandle,D1		;now prepare to write
	MOVE.L	#SectorSize,D3		;amount to write
	CALLSYS	Write 			;do the write
9$:	POP	D2-D3
	RTS

SeekPos:
	PUSH	A0			;SAVE buffer ptr
	MOVE.L	MsdosHandle,D1		;handle
	MOVE.L	D0,D2			;position
	MOVEQ	#OFFSET_BEGINNING,D3
	CALLSYS	Seek,DosBase
	POP	A0			;restore buffer ptr
	RTS

DeviceFlush:
	IFNZL	MsdosHandle,RTSex
	MOVE.W	#CMD_UPDATE,D0
	ZAP	D1
	BSR	DiskIO
	RTSERR

DeviceReset:
	IFNZL	MsdosHandle,RTSex
	MOVE.W	#CMD_RESET,D0
	ZAP	D1
	BSR	DiskIO
RTSex:	RTS

DMOTOR_OFF:
;	MOVE.W	#TD_MOTOR,D0
;	ZAP	D1
;	BSR	DiskIO
	RTS

* Command in D0 (W), io_Length in D1 (L).

DiskIO:
	MOVE.L	DevIOB,A1
	MOVE.W	D0,io_Command(A1)
	MOVE.L	D1,io_Length(A1)
	CALLSYS	DoIO,SysBase
	TST.L	D0
	BEQ.S	1$			;no error
;	MOVE.B	io_Error(A1),D0
	STC
	RTS
1$:	MOVE.L	io_Actual(A1),D0	;status, if any, returned in D0
	RTS

* THESE ROUTINES CONTROL AMIGA-DOS ACCESS TO THE DS_DOS DISK DRIVE.
* CALLED AT INHIBIT TO STOP ACCESS, OR AT PERMIT TO ALLOW AGAIN.
* TO DRIVE NAME STRING IN MD_DRV.

PERMIT_ACCESS:
	MOVE.L	DEVICE_PTR,D0
	BEQ.S	9$
	MOVE.L	D0,A0
	MOVE.B	SAVED_BITS,$41(A0) ;RESTORE DRIVE SELECT BITS
9$:	RTS

* INHIBITS AMIGADOS ACCESS TO THE MS-DOS DISK DRIVE BY SAVING AND ZAPPING 
* THE ADOS DRIVER SELECT BITS, CAUSING DOS TO "FORGET" THE DRIVE.	
* PERMIT_ACCESS RESTORES THE SELECT BITS.

INHIBIT_ACCESS:
	CLR.L	DEVICE_PTR
	MOVE.L	4,A0
	LEA	DeviceList(A0),A0	;POINT TO LIST OF DEVICES
	MOVE.L	A0,DEVICE_PTR		;SEARCH TASK LIST
2$:	MOVE.L	DEVICE_PTR,A0
	MOVE.L	(A0),D0			;GET NEXT ENTRY
	MOVE.L	D0,DEVICE_PTR
	BEQ	8$			;END OF LIST...DIDN'T FIND DISK?
	MOVE.L	D0,A0
	MOVE.L	10(A0),A1		;GET POINTER TO NAME
	JSR	CHECK_TD		;IS IT TRACK DISK?
	BNE.S	2$			;NO...KEEP ON GOING
	ZAP	D0
	MOVE.B	MD_DRV.+3,D0		;GET DRIVE NUMBER
	SUB.B	#'0',D0			;MAKE IT BINARY
	LSL.W	#2,D0			;MAKE IT INTO LONG INDEX
	MOVE.L	$24(A0,D0.W),DEVICE_PTR	;PICK UP PTR TO DRIVER TASK DATA SEG
	BEQ.S	8$			;DRIVE ISN'T KNOWN TO ADOS
	LEA	DOSSignature,A1		;POINT TO DOS IDENTIFIER
	CMP.L	#'MIGA',(A1)		;Check for V1.1 IDENT
	BNE.S	4$			;NOT V1.1
	SUB.L	#$1A,DEVICE_PTR		;ADJUST FOR V1.1
4$:	MOVE.L	DEVICE_PTR,A0
	DISABLE
	MOVE.B	$41(A0),D0		;GET MOTOR FLAG AND SELECT BITS
	BTST	#7,D0			;MOTOR OFF?
	BNE.S	5$			;YES...LETS GRAB THE DRIVE
	ENABLE
	MOVEQ	#25,D1			;ELSE WAIT A BIT
	CALLSYS	Delay,DosBase		;WAIT TO SEE IF DRIVE GETS FREE
	BRA.S	4$
5$:	MOVE.B	D0,SAVED_BITS		;SAVE SELECT CODE
	MOVE.W	#-1,$4C(A0)		;FORCE CURRENT TRACK TO BE UNKNOWN
	MOVE.B	#-1,$41(A0)		;AND FIX SELECT BITS
	ENABLE
	RTS
8$:	STC
	RTS

* CHECKS MS-DOS DRIVE TO DETERMINE WHICH KIND IT IS, AND SETS FLAGS
* ACCORDINGLY.	

CHECK_DRIVE_TYPE:
	LEA	DISK_NAME,A1		;SET UP POINTER TO DISK RESOURCE
	CALLSYS	OpenResource,SysBase	
	MOVE.L	D0,DR_BASE		;POINTER TO DISK RESOURCE BLOCK
	BEQ.S	9$			;DIDN'T FIND IT
	ZAP	D0
	MOVE.B	D0,IS_3.5		;CLEAR 3.5-INCH DRIVE FLAG
	MOVE.B	MD_DRV.+3,D0		;GET UNIT NUMBER
	SUB.B	#'0',D0			;MAKE IT BINARY
	MOVE.L	DR_BASE,A6
	JSR	DR_GetUnitID(A6)	;FIND OUT WHAT TYPE
	TST.L	D0
	BNE.S	1$			;NOT 3.5"
	SETF	IS_3.5			;SHOW IT IS SMALL GUY
	RTS
1$:	CMP.L	#$55555555,D0
	BEQ.S	2$			;IT IS 5.25"
	CMP.L	#$AAAAAAAA,D0
	BEQ.S	2$
9$:	STC				;ELSE NOT A VALID UNIT IN THIS CONFIG
2$:	RTS

* A1 POINTS TO NAME OF NODE.  THIS SUBR COMPARES TO 'trackdisk.device'.	
* RETURNS Z=1 ON MATCH.

CHECK_TD:
	LEA	TRACKDISK,A2
1$:	MOVE.B	(A2)+,D0		;GET A BYTE
	BEQ.S	9$			;END OF STRING...MATCH
	CMP.B	(A1)+,D0		;CHARS MATCH?
	BEQ.S	1$			;YES...GO AGAIN
9$:	RTS

MList		DC.B	'devs:Mountlist',0
Comm1.		DC.B	2,'/*'
Comm2.		DC.B	2,'*/'
Device.		DC.B	6,'DEVICE'
Unit.		DC.B	4,'UNIT'
Flags.		DC.B	5,'FLAGS'
EQ.		DC.B	1,'='
TRACKDISK	DC.B	'trackdisk.device',0
DISK_NAME	DC.B	'disk.resource',0
NoDFn.	  	DC.B	18,' is not available.'
;WRITE_ERR.	DC.B	30,'MS-DOS/Atari disk write error'
;MDFileErr.	DC.B	56,'Unable to open MS-DOS volume as file on AmigaDOS device.'
MDDevice.	DC.B	6,'MSDOS:'

* INHIBIT ACCESS PACKET SENT TO 3.5-INCH DEVICE PROCESS TO STOP FILE
* SYSTEM ACCESS.

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

	SECTION	MEM,BSS

DEVICE_PTR	DS.L	1
MLBuffer	DS.L	1
MLPtr		DS.L	1
MLCount		DS.L	1
DevPort		DS.L	1
DevIOB		DS.L	1
DevFlags	DS.L	1
DevProc		DS.L	1
MsdosHandle	DS.L	1	;<>0 = MS-DOS volume is AmigaDOS file
PartitionOffset	DS.L	1	;offset to proper partition
DevUnit		DS.L	1
LowCyl		DS.L	1
HighCyl		DS.L	1
Reserved	DS.L	1
DriveOffset	DS.L	1	;block offset based on LowCyl
BlocksPerTrack	DS.W	1
Surfaces	DS.W	1
BlockSize	DS.W	1
TokenCount	DS.B	1
CommentFlag	DS.B	1
SAVED_BITS	DS.B	1	;SAVED SIGNAL BITS
RetryCount	DS.B	1
DeviceName	DS.B	80

	END
