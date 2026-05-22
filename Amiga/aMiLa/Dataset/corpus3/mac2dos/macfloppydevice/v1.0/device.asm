*****************************************************************
*								*
*	Quarterback backup/restore device verify/open/close	*
*								*
* This code first checks for DF0-DF3, then opens the mountlist	*
* for a matching entry.  If the device is found, then device	*
* parameters are extracted, disk sizes calculated, and driver	*
* information preserved.					*
*								*
*****************************************************************

	INCLUDE "i/MACROS.ASM"
	INCLUDE	"I/EQUATES.ASM"
	INCLUDE	"I/IO.I"

	XDEF	CheckBRDevice,CheckDFn
	XDEF	OpenBRDevice,CloseBRDevice
	XDEF	CFAbort

	XDEF	DevErrFlg,TwoDevFlg,FlopFlg,NonFlopFlg
	XDEF	Dev0StatMsg,Dev1StatMsg
	XDEF	DF0.,DF1.

	XREF	SysBase,GraphicsBase,DosBase
	XREF	BRDevBuf1,BRDevBuf2,TMP.,TMP2.
	XREF	UnkDev.,NoDev.,MListErr.,MixedDev.,NoDFn.,DevMLErr.
	XREF	DevOpnErr.,Status.,RemAll.,NoMemory
	XREF	MaxWrites,DiskSize,BlocksPerDisk,CylBufSize
	XREF	Mode
	XREF	Dev0Params,Dev1Params
	XREF	Dev0IntS,Dev1IntS
	XREF	PacketIO,DiskIO
	XREF	AllocateBuffers,FreeBuffers
	XREF	PktArg1
	XREF	Dev0SelFlg,Dev1SelFlg,Dev0_IOB,Dev1_IOB
	XREF	_CreatePort,_DeletePort,_CreateStdIO,_DeleteStdIO

MLBufSize	EQU	8000	;temp buffer for reading mountlist
DR_GetUnitID	EQU	-30	;not the proper way to do this...
ACTION_INHIBIT	EQU	31
IntVec		EQU	$12A	;offset into trackdisk data for int vec
MaxTok		EQU	8	;number of tokens we need

* Checks to make sure that there is a valid backup/restore device, calculates
* params.  Device strings assumed to be already defined.  Returns CY=1 on
* device failure.  Sets DevErrFlg to device causing problem (1 or 2).

CheckBRDevice:
	JSR	FreeBuffers		;get rid of any possible buffers
	CLR.B	DevErrFlg		;start with no error
	CLR.B	FlopFlg			;no floppies yet
	CLR.B	NonFlopFlg		;nothing else
	CLR.B	TwoDevFlg
	STRIP_LB. BRDevBuf1		;just in case...
	CLR.B	Dev0SelFlg
	CLR.B	Dev0StatMsg
	LEN.	BRDevBuf1		;got any first device?
	IFNZB	D0,1$			;got something...check it out
	DispErr	NoDev.			;need at least 1 valid device
7$:	MOVEQ	#1,D0
	BRA	8$
1$:	LEA	Dev0Params,A5		;work the first drive table
	BSR	CheckDevice		;see what we have here
	ERROR	7$			;oops...need at least 1 device
	MOVE.	TMP.,Dev0StatMsg	;set up device name in status msg
	CLR.B	Dev1SelFlg
	CLR.B	Dev1StatMsg
	STRIP_LB. BRDevBuf2
	LEN.	BRDevBuf2
	IFZB	D0,9$			;only 1 device
	LEA	Dev1Params,A5
	BSR	CheckDevice		;else see what it is
	ERROR	3$			;invalid second device
	MOVE.	TMP.,Dev1StatMsg
	SETF	TwoDevFlg		;show two devices in use
	BRA.S	9$
3$:	MOVEQ	#2,D0
8$:	MOVE.B	D0,DevErrFlg		;error code 1=dev0, 2=dev1
9$:	MOVE.L	MLBuffer,D0
	BEQ.S	11$			;no buffer to release
	MOVE.L	D0,A1
	MOVE.L	#MLBufSize,D0
	CALLSYS	FreeMem,SysBase		;release memory
	CLR.L	MLBuffer
11$:	IFZB	DevErrFlg,12$
	STC
12$:	RTS

* Checks device in TMP. for standard floppy.  If not, searches mountlist for
* a valid entry.  Returns CY=1 if no device, or if device not valid.
* A5 points to device parameter table (part of Main.asm)

CheckDevice:
	MOVE.L	DevNamePtr(A5),A0
	MOVE.	A0,TMP.
	UCASE.	TMP.
	IFEQ.	DF0.,TMP.,2$		;check for standard floppy
	IFEQ.	DF1.,TMP.,2$
	IFEQ.	DF2.,TMP.,2$
	IFEQ.	DF3.,TMP.,2$
	IFNZB	FlopFlg,7$,L		;can't mix devices
	BSR	CheckMountList		;not floppy...is device in mountlist?
	RTSERR				;no...don't know what we have
	SETF	NonFlopFlg		;else got a non-floppy device
	BRA.S	3$
2$:	IFNZB	NonFlopFlg,7$,L		;can't mix devices
	SETF	FlopFlg			;got a floppy
	ZAP	D6
	MOVE.B	TMP.+2,D6
	MOVE.B	D6,NoDFn.+8		;save drive number for error
	SUB.B	#'0',D6			;convert to binary
	MOVE.W	D6,DevUnit(A5)
	BSR	CheckDFn		;check that drive exists in this config
	NOERROR	4$
	DispErr	NoDFn.			;oops...no drive
	BRA.S	8$
4$:	MOVE.	TrkDev.,DeviceName	;set up proper name
	MOVE.W	#79,HighCyl		;assume standard 80-track floppy
	CLR.W	LowCyl
	MOVE.W	#11,BlocksPerTrack
	MOVE.W	#2,Surfaces
	CLR.L	DevFlags(A5)		;clear flags
3$:	BSR	CalcDiskSize		;figure max disk params
	SETF	DevSelFlg(A5)		;show drive selected
	LEA	TMP.,A0
1$:	MOVE.B	(A0)+,D0
	CMP.B	#':',D0
	BNE.S	1$
	CLR.B	-1(A0)			;zap the colon
	APPEND.	Status.,TMP.		;make into proper status msg
	BRA.S	9$
7$:	DispErr	MixedDev.		;can't mix floppies and others
8$:	STC
9$:	RTS

* This routine attempts to find the mountlist, then scans it looking
* for the device specified by the operator.  Returns CY=1 on any error.

CheckMountList:
	CLR.B	TokenCount
	ZAP	D6			;flag byte
	ZAP	D7			;mountlist handle
	IFNZL	MLBuffer,1$
	MOVE.L	#MLBufSize,D4
	MOVE.L	D4,D0
	ZAP	D1
	CALLSYS	AllocMem,SysBase	;get buffer for read
	MOVE.L	D0,MLBuffer		;mountlist buffer
	BEQ	13$			;no mem for buffer?!
	MOVE.L	#MList.,D1
	MOVE.L	#EXISTING,D2
	CALLSYS	Open,DosBase
	MOVE.L	D0,D7			;did we get the mountlist?
	BEQ	13$			;no
	MOVE.L	D0,D1
	MOVE.L	MLBuffer,D2
	MOVE.L	D4,D3
	CALLSYS	Read,DosBase		;read in entire mountlist
	MOVE.L	D0,MLCount		;what happened?
	BMI	13$			;okay...got nothing
	MOVE.L	D7,D1
	CALLSYS	Close
1$:	MOVE.L	MLBuffer,MLPtr		;init ptr to start of text
2$:	CMP.B	#MaxTok,TokenCount
	BEQ	14$			;that's it...found all we need
	BSR	NextUCToken
	ERROR	16$
	IFZB	CommentFlag,3$		;not in a comment, proceed
	IFNE.	TMP2.,Comm2.,2$		;loop till end of comment
	CLR.B	CommentFlag
	BRA.S	2$

3$:	IFNE.	TMP2.,Comm1.,4$		;not /*
	SETF	CommentFlag
	BRA.S	2$

4$:
;	CMP.B	#'#',TMP2.		;end of device table?
;	BEQ	16$
	IFNZB	TokenCount,5$		;found proper device
	IFNE.	TMP.,TMP2.,2$		;else loop till we find the device
	INCB	TokenCount
	BRA	2$

5$:	IFNE.	TMP2.,Device.,7$	;not device driver name
6$:	BSR	NextToken
	ERROR	16$
	IFEQ.	TMP2.,EQ.,6$		;found '='
	MOVE.	TMP2.,DeviceName
	INCB	TokenCount
	BRA	2$
	
7$:	IFNE.	TMP2.,Unit.,8$		;not unit number
	BSR	GetNumber
	ERROR	2$
;	SUB.B	#'0',D0			;make binary
	MOVE.W	D0,DevUnit(A5)
	INCB	TokenCount
	BRA	2$

8$:	IFNE.	TMP2.,Flags.,9$		;not device flags
	BSR	GetHex
	ERROR	2$
	MOVE.L	D0,DevFlags(A5)
	INCB	TokenCount
	BRA	2$

9$:	IFNE.	TMP2.,Surfaces.,10$	;not surfaces
	LEA	Surfaces,A4
	BSR	CheckNumber
	BRA	2$

10$:	IFNE.	TMP2.,Blockspertrack.,11$	;not blocks per track
	LEA	BlocksPerTrack,A4
	BSR	CheckNumber
	BRA	2$

11$:	IFNE.	TMP2.,HighCyl.,12$	;not high cyl
	LEA	HighCyl,A4
	BSR	CheckNumber
	BRA	2$

12$:	IFNE.	TMP2.,LowCyl.,2$	;loop if not low cyl
	LEA	LowCyl,A4
	BSR	CheckNumber
	BRA	2$

13$:	DispErr	MListErr.		;error in accessing mountlist
	BRA.S	18$
14$:	IFZB	DevErrFlg,15$
	DispErr	MixedDev.
	BRA.S	18$
15$:	INCB	D6			;successful exit
16$:	TST.L	D6			;error?
	BNE.S	19$			;no
	IFNZB	TokenCount,17$
	DispErr	UnkDev.			;unknown device
	BRA.S	18$
17$:	DispErr	DevMLErr.
18$:	STC
19$:	RTS

* Gets a number token.  If first device, stores value in variable pointed
* to by A4.  If second device, checks new value against value
* pointed to by A4.  If not same, sets DevErrFlg (incompatible devices).

CheckNumber:
	BSR.S	GetNumber		;get next token and convert to number
	RTSERR
	IFNZB	TwoDevFlg,1$		;second device...compare numbers
	MOVE.W	D0,(A4)			;store value
	BRA.S	2$
1$:	CMP.W	(A4),D0			;devices have same params?
	BEQ.S	2$			;yes...all ok
	MOVE.B	#2,DevErrFlg		;show problem with second device
2$:	INCB	TokenCount		;else count the token
	RTS
	
* Returns binary value of a n-char decimal param following keyword and 
* '='.  CY=1 on error.

GetNumber:
	BSR	NextToken		;get token in TMP.
	RTSERR				;nothing
	IFEQ.	TMP2.,EQ.,GetNumber	;ignore =
	ZAP	D0			;result in D0
	LEA	TMP2.,A0		;scan the token
1$:	ZAP	D1
	MOVE.B	(A0)+,D1
	BEQ.S	9$			;end of token
	CMP.B	#'0',D1			;in range?
	BCS.S	1$			;no...ignore it
	CMP.B	#'9',D1			;in range?
	BHI.S	1$			;no...ignore it
	SUB.B	#'0',D1			;adjust to binary
	MULU	#10,D0			;shift previous digits by 10
	ADD.W	D1,D0			;add in new value
	BRA.S	1$
9$:	RTS

* Returns binary value of a n-char hexadecimal param following keyword and 
* '='.  CY=1 on error.

GetHex:
	BSR.S	NextToken		;get token in TMP.
	RTSERR				;nothing
	IFEQ.	TMP2.,EQ.,GetHex	;ignore =
	ZAP	D0			;result in D0
	LEA	TMP2.,A0		;scan the token
1$:	ZAP	D1
	MOVE.B	(A0)+,D1
	BEQ.S	9$			;end of token
	CMP.B	#'0',D1			;in range?
	BCS.S	1$			;no...ignore it
	CMP.B	#'9',D1			;in range?
	BLS.S	2$			;YES...
	CMP.B	#'A',D1
	BCS.S	1$			;not A-F
	CMP.B	#'F',D1
	BHI.S	1$			;ditto
2$:	AND.W	#$F,D1			;strip down to nibble
	ASL.L	#4,D0			;shift previous digits by 4
	ADD.W	D1,D0			;add in new value
	BRA.S	1$
9$:	RTS

* The following routines return the next delimited token from the mountlist.

NextUCToken:
	BSR.S	NextToken
	RTSERR
	UCASE.	TMP2.
	CLC
	RTS

NextToken:
	LEA	TMP2.,A1
1$:	BSR	NextChar
	ERROR	4$		;scan out leading blanks and other garbage
	CMPI.B	#' ',D0
	BEQ.S	1$
	CMPI.B	#';',D0
	BEQ.S	1$
	CMPI.B	#10,D0
	BEQ.S	1$
	CMPI.B	#9,D0
	BEQ.S	1$
	BRA.S	3$
2$:	BSR	NextChar	;get another char
	ERROR	4$	
	CMPI.B	#' ',D0
	BEQ	4$		;stop on blank
	CMPI.B	#';',D0
	BEQ.S	4$		;also on semicolon
	CMPI.B	#'=',D0
	BEQ.S	4$		;accept '=' jammed up against token
	CMPI.B	#10,D0
	BEQ.S	4$		;stop on line end
	CMPI.B	#9,D0
	BEQ.S	4$
3$:	MOVE.B	D0,(A1)+	;store byte
	BRA.S	2$

4$:	CLR.B	(A1)+		;trailing null
	LEN.	TMP2.		;find anything?
	IFNZB	D0,6$
	STC			;got nothing
6$:	RTS


NextChar:
	TST.L	MLCount
	BLE.S	9$
	MOVE.L	MLPtr,A0
	MOVE.B	(A0)+,D0
	MOVE.L	A0,MLPtr
	DECL	MLCount
	RTS
9$:	STC
	RTS

* Calculate QB device max parameters from data from mountlist

CalcDiskSize:
	MOVE.W	HighCyl,D0		;calc number of cylinders
	SUB.W	LowCyl,D0
	INCW	D0			;account for 0 origin
	MOVE.W	D0,MaxWrites		;this is the max cyl count
	MULU	Surfaces,D0
	MOVE.W	BlocksPerTrack,D1
	MULU	D1,D0			;gives total blocks per disk
	MOVE.W	D0,BlocksPerDisk
	MULU	#SectorSize,D0
	MOVE.L	D0,DiskSize		;disk size in bytes
	MOVE.W	Surfaces,D0
;	IFLEIB	D0,#2,1$		;limit buffer size
;	MOVEQ	#2,D0
;1$:
	MULU	D0,D1
	MULU	#SectorSize,D1
	MOVE.L	D1,CylBufSize		;bytes per cyl	
	RTS

* Verify that floppy drive unit number (0-3) in D6 exists in this 
* hardware configuration.  CY=1 if not.

CheckDFn:
	IFNZL	DiskBase,1$
	LEA	DiskName,A1
	CALLSYS	OpenResource,SysBase	;get ptr to disk resource
	MOVE.L	D0,DiskBase
	BEQ.S	8$			;oops...can't open
1$:	MOVE.L	D6,D0			;unit number
	MOVE.L	DiskBase,A6
	JSR	DR_GetUnitID(A6)	;find out what kind it is
	IFZL	D0,9$			;okay...drive is available
8$:	STC
9$:	RTS

* Open either or both backup/restore devices, according to selection flags.
* Returns CY=1 on any failure.

OpenBRDevice:
	IFZB	Dev0SelFlg,1$		;not using Dev0
	IFNZL	Dev0_IOB,1$		;already have Dev0, don't do it again
	LEA	Dev0Params,A2
	BSR	InitDevice
	RTSERR
	MOVE.L	Dev0_IOB,A1		;enable disk changed interrupts
	LEA	Dev0IntS,A0
	BSR	InitDiskInt

1$:	IFZB	Dev1SelFlg,9$		;not using Dev1
	IFNZL	Dev1_IOB,9$		;already have Dev1, don't do it again
	LEA	Dev1Params,A2
	BSR	InitDevice
	RTSERR
	MOVE.L	Dev1_IOB,A1
	LEA	Dev1IntS,A0
	BSR	InitDiskInt
9$:	JSR	AllocateBuffers		;now allocate necessary buffers
	NOERROR	10$
	DispErr	NoMemory
	STC
10$:	RTS

* Allocates a msg port and an IO block, then opens the device driver.
* Drive param table in A2.

InitDevice:
	MOVE.L	DevNamePtr(A2),D1
	CALLSYS	DeviceProc,DosBase
	MOVE.L	D0,DevProc(A2)
	BEQ.S	8$			;didn't get process id...can't open
	PEA	0
	PEA	0
	JSR	_CreatePort		;allocate msg port
	ADDQ.L	#8,SP
	MOVE.L	D0,DevPort(A2)
	BEQ.S	8$			;problems
	MOVE.L	D0,-(SP)
	JSR	_CreateStdIO		;allocate and init IOB
	ADDQ.L	#4,SP
	MOVE.L	D0,DevIOB(A2)
	BEQ.S	8$			;problems
	MOVE.L	D0,A1
	ZAP	D0
	MOVE.W	DevUnit(A2),D0		;get unit ID
	LEA	DeviceName,A0
	MOVE.L	DevFlags(A2),D1		;device flags
	CALLSYS	OpenDevice,SysBase	;open it
	IFNZL	D0,8$			;bad open
	BSR	Inhibit			;make ADOS leave drive alone
	RTS
8$:	BSR	FreeDriveResources
	MOVE.	DevOpnErr.,TMP2.	;oops...cant open device
	MOVE.L	DevNamePtr(A2),A0
	APPEND.	A0,TMP2.		;tell op which one
	DispErr	TMP2.
	STC
	RTS

* Closes either or both backup/restore devices, according to selection flags.

CloseBRDevice:
	MOVE.L	Dev0_IOB,D0
	ADD.L	Dev1_IOB,D0
	BEQ.S	CFAbort			;no drives allocated...no msg
	DispErr	RemAll.			;make sure all floppies removed
CFAbort:
	LEA	Dev0Params,A2		;try to close Dev0
	BSR.S	CloseDev
	LEA	Dev1Params,A2		;try to close Dev1
	BSR.S	CloseDev
	RTS

* Close and release a single floppy drive.  A2 points to param table.
* Note: drive may never have been allocated.

CloseDev:
	IFZB	DevSelFlg(A2),9$	;drive not in use
	IFZL	DevIOB(A2),1$		;drive already closed
	BSR	Enable			;let ADOS get at drive again
	MOVE.L	DevIOB(A2),A1
	BSR	RestDiskInt
	MOVE.L	DevIOB(A2),A1
	CALLSYS	CloseDevice,SysBase
1$:	BSR.S	FreeDriveResources
9$:	RTS

FreeDriveResources:
	MOVE.L	DevIOB(A2),D0
	BEQ.S	1$
	MOVE.L	D0,-(SP)
	JSR	_DeleteStdIO
	ADDQ.L	#4,SP
	CLR.L	DevIOB(A2)
1$:	MOVE.L	DevPort(A2),D0
	BEQ.S	9$			;no port
	MOVE.L	D0,-(SP)
	JSR	_DeletePort
	ADDQ.L	#4,SP
	CLR.L	DevPort(A2)
9$:	RTS

* Keeps AmigaDOS from fooling around with the backup/restore device
* while we use it.

Enable:
	ZAP	D0
	BRA.S	IECom
Inhibit:
	MOVEQ	#1,D0
IECom:	MOVE.L	D0,PktArg1		;store inhibit/enable code
	MOVEQ	#ACTION_INHIBIT,D0	;packet type
	MOVE.L	DevProc(A2),A0		;process ID of handler
	JSR	PacketIO
	RTS

* Initialize interrupt vectors.  Vector in A0 (init)  or 0 (reset).

RestDiskInt:
	IFZB	FlopFlg,9$
	MOVE.L	DevVec(A2),A0
	IFZL	A0,9$
	BSR.S	DICom
9$:	RTS

InitDiskInt:
	IFZB	FlopFlg,9$
	PUSH	A3
	MOVE.L	io_Unit(A1),A3
	MOVE.L	IntVec(A3),DevVec(A2) ;save old int vector
	BSR.S	DICom
	POP	A3
9$:	RTS
	
DICom:	MOVE.L	A0,io_Data(A1)
	MOVE.L	#TD_REMOVE,D0
	JSR	DiskIO
	RTS

MList.		TEXTZ	'devs:Mountlist'
TrkDev.		TEXTZ	'trackdisk.device'
DiskName	TEXTZ	'disk.resource'
Comm1.		TEXTZ	'/*'
Comm2.		TEXTZ	'*/'
Device.		TEXTZ	'DEVICE'
Unit.		TEXTZ	'UNIT'
Flags.		TEXTZ	'FLAGS'
Surfaces.	TEXTZ	'SURFACES'
Blockspertrack.	TEXTZ	'BLOCKSPERTRACK'
LowCyl.		TEXTZ	'LOWCYL'
HighCyl.	TEXTZ	'HIGHCYL'
EQ.		TEXTZ	'='
DF0.		TEXTZ	'DF0:'
DF1.		TEXTZ	'DF1:'
DF2.		TEXTZ	'DF2:'
DF3.		TEXTZ	'DF3:'

	SECTION	MEM,BSS

MLBuffer	DS.L	1
MLPtr		DS.L	1
MLCount		DS.L	1
DiskBase	DS.L	1		;disk resource
Surfaces	DS.W	1		;surfaces (heads)
BlocksPerTrack	DS.W	1		;11 for standard floppy
LowCyl		DS.W	1		;from mountlist
HighCyl		DS.W	1		;ditto
TokenCount	DS.B	1
CommentFlag	DS.B	1		;1=inside comments section of mountlist
DevErrFlg	DS.B	1		;1=improper device
FlopFlg		DS.B	1		;1=first device is standard floppy
NonFlopFlg	DS.B	1		;1=first device is non floppy device
TwoDevFlg	DS.B	1		;1=using two devices
DeviceName	DS.B	80
Dev0StatMsg	DS.B	15
Dev1StatMsg	DS.B	15

	END

