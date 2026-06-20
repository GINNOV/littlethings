	IFND	EXAMPLE_DEVICE_I
EXAMPLE_DEVICE_I	SET	1
**
**	$VER: jw_device.i 1.0 (23.12.2000)
**	Includes Release 40.15
**
**	Interface definitions for the John White device
**
**	Written By: John White, 23.12.2000
**	This include is PUBLIC DOMAIN
**

	IFND EXEC_TASKS_I
	INCLUDE "exec/tasks.i"
	ENDC

	IFND EXEC_IO_I
	INCLUDE "exec/io.i"
	ENDC

INFO_LEVEL	EQU	0
*INTRRUPT	SET	1
AUTOMOUNT	EQU	0
PROCSTACKSIZE	EQU	$900
PROCPRI		EQU	0
NUMBEROFTRACKS	EQU	40
SECTOR		EQU	512
SECSHIFT	EQU	9
SECTORSPER	EQU	10
RAMSIZE		EQU	SECTOR*NUMBEROFTRACKS*SECTORSPER
BYTESPERTRACK	EQU	SECTORSPER*SECTOR
IAMPULLING	EQU	7
INTENABLE	EQU	4
INTCTRL1	EQU	$40
INTCTRL2	EQU	$42
INTACK		EQU	$50

	BITDEF	CMD,EXTCOM,15

	DEVINIT
	DEVCMD	JWD_MOTOR		; control the disk's motor
	DEVCMD	JWD_SEEK		; explicit seek (for testing)
	DEVCMD	JWD_FORMAT		; format disk
	DEVCMD	JWD_REMOVE		; notify when disk changes
	DEVCMD	JWD_CHANGENUM		; number of disk changes
	DEVCMD	JWD_CHANGESTATE		; is there a disk in the drive?
	DEVCMD	JWD_PROTSTATUS		; is the disk write protected?
	DEVCMD	JWD_RAWREAD		; read raw bits from the disk
	DEVCMD	JWD_RAWWRITE		; write raw bits to the disk
	DEVCMD	JWD_GETDRIVETYPE	; get the type of the disk drive
	DEVCMD	JWD_GETNUMTRACKS	; get the # of tracks on this disk
	DEVCMD	JWD_ADDCHANGEINT	; CMD_REMOVE done right
	DEVCMD	JWD_REMCHANGEINT	; removes softint set by ADDCHANGEINT
	DEVCMD	MYDEV_END		; place marker. 1st illegal command.

DRIVE3_5	EQU	1
DRIVE5_25	EQU	2

; ======================================================================== 
; === Device ============================================================= 
; ======================================================================== 
;
;

      STRUCTURE	MkDosNodePkt,0
	APTR	mdn_dosName
	APTR	mdn_execName
	ULONG	mdn_unit
	ULONG	mdn_flags
	ULONG	mdn_tableSize
	ULONG	mdn_sizeBlock
	ULONG	mdn_secOrg
	ULONG	mdn_numHeads
	ULONG	mdn_secsPerBlk
	ULONG	mdn_blkTrack
	ULONG	mdn_resBlks
	ULONG	mdn_prefac
	ULONG	mdn_interleave
	ULONG	mdn_lowCyl
	ULONG	mdn_upperCyl
	ULONG	mdn_numBuffers
	ULONG	mdn_memBufType
	ULONG	mdn_dName,5
	LABEL	mdn_Sizeof

MD_NUMUNITS	EQU	4

      STRUCTURE	MyDev,LIB_SIZE
	UBYTE	md_Flags
	UBYTE	md_pad1
	ULONG	md_SysLib
	ULONG	md_SegList
	ULONG	md_Base
	STRUCT	md_Units,MD_NUMUNITS*4
	LABEL	MyDev_Sizeof

      STRUCTURE	MyDevUnit,LIB_SIZE
	UBYTE	mdu_UnitNum
	UBYTE	mdu_SigBit
	APTR	mdu_Device
	STRUCT	mdu_stack,PROCSTACKSIZE
	STRUCT	mdu_tcb,TC_SIZE
	ULONG	mdu_SigMask
	IFD	INTRRUPT
	STRUCT	mdu_is,IS_SIZE
	UWORD	mdu_pad1
	ENDC
	STRUCT	mdu_RAM,RAMSIZE
	LABEL	MyDevUnit_Sizeof

	BITDEF	MDU,STOPPED,2

DEVNAME	MACRO
	DC.B	'ramdev.device',0
	ENDM

LINKSYS	MACRO
	MOVE.L	A6,-(SP)
	MOVE.L	\2,A6
	JSR	_LVO\1(A6)
	MOVE.L	(SP)+,A6
	ENDM

XLIB	MACRO
	XREF	_LVO\1
	ENDM

	XREF	KPutFmt

PUTMSG:	MACRO	* level,msg
	IFNE	INFO_LEVEL-\1
	PEA	subSysName(PC)
	MOVEM.L	A0/A1/D0/D1,-(SP)
	LEA	msg\@(pc),A0
	LEA	4*4(SP),A1
	JSR	KPutFmt
	MOVEM.L	(SP)+,A0/A1/D0/D1
	ADDQ.L	#4,SP
	BRA.S	end\@

msg\@	DC.B	\2
	DC.B	10
	DC.B	0
	DS.W	0
end\@
	ENDC
	ENDM

	ENDC
