*****************************************
*					*
* 		MacFloppy.i		*
*					*
*****************************************

	INCLUDE	"exec/types.i"
	INCLUDE	"exec/devices.i"
	INCLUDE	"exec/initializers.i"
	INCLUDE	"exec/memory.i"
	INCLUDE	"exec/resident.i"
	INCLUDE	"exec/io.i"
	INCLUDE	"exec/ables.i"
	INCLUDE	"exec/errors.i"
	INCLUDE	"exec/tasks.i"
	INCLUDE	"hardware/intbits.i"
	INCLUDE "devices/timer.i"
	INCLUDE	"resources/disk.i"

Drive3_5	EQU	1

StepDelay	EQU	20000
SetDelay	EQU	50000		;settling delay after seek
RetryLimit	EQU	10
DriveType	EQU	1		;3.5"
;;SectorSize	EQU	1024
SectorSize	EQU	512
MaxSectors	EQU	11		;Mac=12, ADOS=11
MaxTracks	EQU	160		;80 cyls*2
ADOSMaxBlock	EQU	MaxTracks*11
ADosMaxOffset	EQU	ADOSMaxBlock*SectorSize
TrackGap	EQU	1656		;was 1664, multiple of 24 (6 and 4)

StackSize	EQU	512		;from TD
TrkBufSize	EQU	24000		;track gap
SlowdownDelay	EQU	1000

* Mac drive control bit definitions

CA0		EQU	1	;step
CA1		EQU	2	;direction
CA2		EQU	4	;side
SEL		EQU	$80	;motor

* Hardware register definitions

CIAA		EQU	$BFE001
CIAB		EQU	$BFD100
HdwRegsBase	EQU	$DFF000

* Original trackdisk flag bit definitions

td_HdrData	EQU	0	;1=processing header data
td_DrvEmpty	EQU	1	;1=drive has no disk
td_ETD		EQU	2	;1=processing ETD command
td_Close	EQU	3	;1=close request
td_WrtProt	EQU	4	;unused

* MacFloppy flag bit definitions

Mac_Motor	EQU	0	;1=motor on
Mac_StepDir	EQU	1	;1=step toward track 0 (outer edge)
Mac_Side	EQU	2	;0=lower head, 1=upper head
Mac_TwoSided	EQU	3	;1=drive is double-sided, 0=single-sided
Mac_Disabled	EQU	4	;1=Driver is disabled (From M2D)
Mac_TimerB	EQU	5	;1=we own timer B
Mac_Busy	EQU	6	;1=we own disk control hdw

;	BITDEF	MFU,STOPPED,2

 STRUCTURE BandEntry,0
	WORD	OnCount
	WORD	OffCount
	LABEL	BE_SIZE

* MacFloppy device structure

 STRUCTURE MacFlopDev,LIB_SIZE
	BYTE	mf_Flags
	BYTE	pad
	WORD	mf_OpenCnt
	LONG	mf_SysBase
	LONG	mf_GraphicsBase
	LONG	mf_DRBase
	LONG	mf_SegList	
	LONG	mf_UnitPtr
	STRUCT	mf_STimer,IOTV_SIZE
	STRUCT	mf_LTimer,IOTV_SIZE
	LONG	mf_CiaBBase
	LABEL	mf_Sizeof

 STRUCTURE UnitTable,0
	STRUCT	MsgPort,MP_SIZE		;0
	BYTE	UnitFlags		;22
	BYTE	OpenCnt			;23
	BYTE	UnitNum			;24
	BYTE	Select			;25
	BYTE	LSTRB			;26
	BYTE	TdFlags			;27
	BYTE	MacFlags		;28
	BYTE	DiskType		;29
	BYTE	SecsPerTrk		;2A
	BYTE	ErrorCnt		;2B
	WORD	NewSec			;2C
	WORD	NewTrk			;2E
	WORD	CurTrk			;30
	WORD	OnDuty			;32
	WORD	OffDuty			;34
	LONG	MaxOffset		;36
	LONG	IORequest		;3A
	LONG	ReadBuffer		;3E
	LONG	WriteBuffer		;42
	LONG	UserBuffer		;46
	LONG	LabelBuffer		;4A
	LONG	ReadLength		;4E
	LONG	WriteLength		;52
	STRUCT	ADOSTable,BE_SIZE	;6A 1 ADOS band
	STRUCT	ShortTimer,IOTV_SIZE	;6E
	STRUCT	LongTimer,IOTV_SIZE	;96
	STRUCT	PrivatePort,MP_SIZE	;BE
	STRUCT	PrivateMsg,MN_SIZE	;E0 - KEEP THESE TWO TOGETHER, OR
	STRUCT	DMAInt,IS_SIZE		;F4 - DISK COMPLETE INTERRUPT FAILS!
	STRUCT	SpeedIntB,IS_SIZE	;136
	LONG	ChangeCnt		;14C
	LONG	ChangeIntVec		;150
	STRUCT	tcb,TC_SIZE		;154
	LONG	MemListPtr		;1B0
	STRUCT	ChgVecList,LH_SIZE	;1B4
	LABEL	UnitTbl_SIZE		;x1AC=428 bytes

	DEVINIT
	DEVCMD	TD_MOTOR
	DEVCMD	TD_SEEK
	DEVCMD	TD_FORMAT
	DEVCMD	TD_REMOVE
	DEVCMD	TD_CHANGENUM
	DEVCMD	TD_CHANGESTATE
	DEVCMD	TD_PROTSTATUS
	DEVCMD	TD_RAWREAD
	DEVCMD	TD_RAWWRITE
	DEVCMD	TD_GETDRIVETYPE
	DEVCMD	TD_GETNUMTRACKS
	DEVCMD	TD_ADDCHANGEINT
	DEVCMD	TD_REMCHANGEINT
	DEVCMD	LastCmd

	BITDEF	TD,EXTCOM,15

ETD_WRITE	EQU	(CMD_WRITE!TDF_EXTCOM)
ETD_READ	EQU	(CMD_READ!TDF_EXTCOM)
ETD_MOTOR	EQU	(TD_MOTOR!TDF_EXTCOM)
ETD_SEEK	EQU	(TD_SEEK!TDF_EXTCOM)
ETD_FORMAT	EQU	(TD_FORMAT!TDF_EXTCOM)
ETD_UPDATE	EQU	(CMD_UPDATE!TDF_EXTCOM)
ETD_CLEAR	EQU	(CMD_CLEAR!TDF_EXTCOM)
ETD_RAWREAD	EQU	(TD_RAWREAD!TDF_EXTCOM)
ETD_RAWWRITE	EQU	(TD_RAWWRITE!TDF_EXTCOM)

 STRUCTURE	IOEXTTD,IOSTD_SIZE
	ULONG	IOTD_COUNT
	ULONG	IOTD_SECLABEL
	LABEL	IOTD_SIZE

	BITDEF	IOTD,INDEXSYNC,4

TD_LABELSIZE	EQU	16

	BITDEF	TD,ALLOW_NON_3_5,0

TDERR_NotSpecified	EQU	20
TDERR_NoSecHdr		EQU	21
TDERR_BadSecPreamble	EQU	22
TDERR_BadSecID		EQU	23
TDERR_BadHdrSum		EQU	24
TDERR_BadSecSum		EQU	25
TDERR_TooFewSecs	EQU	26
TDERR_BadSecHdr		EQU	27
TDERR_WriteProt		EQU	28
TDERR_DiskChanged	EQU	29
TDERR_SeekError		EQU	30
TDERR_NoMem		EQU	31
TDERR_BadUnitNum	EQU	32
TDERR_BadDriveType	EQU	33
TDERR_DriveInUse	EQU	34
TDERR_PostReset		EQU	35

