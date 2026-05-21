	IFND	DEVICES_PRTBASE_I
DEVICES_PRTBASE_I	SET	1
	IFND	EXEC_NODES_I
	INCLUDE	"exec/nodes.i"
	ENDC
	IFND	EXEC_LISTS_I
	INCLUDE	"exec/lists.i"
	ENDC
	IFND	EXEC_PORTS_I
	INCLUDE	"exec/ports.i"
	ENDC
	IFND	EXEC_LIBRARIES_I
	INCLUDE	"exec/libraries.i"
	ENDC
	IFND	EXEC_TASKS_I
	INCLUDE	"exec/tasks.i"
	ENDC
	IFND	DEVICES_PARALLEL_I
	INCLUDE	"devices/parallel.i"
	ENDC
	IFND	DEVICES_SERIAL_I
	INCLUDE	"devices/serial.i"
	ENDC
	IFND	DEVICES_TIMER_I
	INCLUDE	"devices/timer.i"
	ENDC
	IFND	LIBRARIES_DOSEXTENS_I
	INCLUDE	"libraries/dosextens.i"
	ENDC
	IFND	INTUITION_INTUITION_I
	INCLUDE	"intuition/intuition.i"
	ENDC
	rsreset
DeviceData	rs.b	LIB_SIZE
dd_Segment	rs.l	1
dd_ExecBase	rs.l	1
dd_CmdVectors	rs.l	1
dd_CmdBytes	rs.l	1
dd_NumCommands	rs.w	1
dd_SIZEOF	rs.w	0
du_Flags	EQU	LN_PRI
IOB_QUEUED	equ	4
IOF_QUEUED	equ	1<<4
IOB_CURRENT	equ	5
IOF_CURRENT	equ	1<<5
IOB_SERVICING	equ	6
IOF_SERVICING	equ	1<<6
IOB_DONE	equ	7
IOF_DONE	equ	1<<7
DUB_STOPPED	equ	0
DUF_STOPPED	equ	1<<0
P_PRIORITY	EQU	0
P_STKSIZE	EQU	$800
PB_IOR0	equ	0
PF_IOR0	equ	1<<0
PB_IOR1	equ	1
PF_IOR1	equ	1<<1
PB_EXPUNGED	equ	7
PF_EXPUNGED	equ	1<<7
	rsreset
PrinterData	rs.b	dd_SIZEOF
pd_Unit	rs.b	MP_SIZE
pd_PrinterSegment	rs.l	1
pd_PrinterType	rs.w	1
pd_SegmentData	rs.l	1
pd_PrintBuf	rs.l	1
pd_PWrite	rs.l	1
pd_PBothReady	rs.l	1
	IFGT	IOEXTPar_SIZE-IOEXTSER_SIZE
pd_IOR0	rs.b	IOEXTPar_SIZE
pd_IOR1	rs.b	IOEXTPar_SIZE
	ENDC
	IFLE	IOEXTPar_SIZE-IOEXTSER_SIZE
pd_IOR0	rs.b	IOEXTSER_SIZE
pd_IOR1	rs.b	IOEXTSER_SIZE
	ENDC
pd_TIOR	rs.b	IOTV_SIZE
pd_IORPort	rs.b	MP_SIZE
pd_TC	rs.b	TC_SIZE
pd_Stk	rs.b	P_STKSIZE
pd_Flags	rs.b	1
pd_pad	rs.b	1
pd_Preferences	rs.b	pf_SIZEOF
pd_PWaitEnabled	rs.b	1
pd_SIZEOF	rs.w	0
PPCB_GFX	equ	0
PPCF_GFX	equ	1<<0
PPCB_COLOR	equ	1
PPCF_COLOR	equ	1<<1
PPC_BWALPHA	EQU	0
PPC_BWGFX	EQU	1
PPC_COLORGFX	EQU	3
PCC_BW	EQU	1
PCC_YMC	EQU	2
PCC_YMC_BW	EQU	3
PCC_YMCB	EQU	4
PCC_4COLOR	EQU	$4
PCC_ADDITIVE	EQU	$8
PCC_WB	EQU	$9
PCC_BGR	EQU	$a
PCC_BGR_WB	EQU	$b
PCC_BGRW	EQU	$c
	rsreset
PrinterExtendedData	rs.b	0
ped_PrinterName	rs.l	1
ped_Init	rs.l	1
ped_Expunge	rs.l	1
ped_Open	rs.l	1
ped_Close	rs.l	1
ped_PrinterClass	rs.b	1
ped_ColorClass	rs.b	1
ped_MaxColumns	rs.b	1
ped_NumCharSets	rs.b	1
ped_NumRows	rs.w	1
ped_MaxXDots	rs.l	1
ped_MaxYDots	rs.l	1
ped_XDotsInch	rs.w	1
ped_YDotsInch	rs.w	1
ped_Commands	rs.l	1
ped_DoSpecial	rs.l	1
ped_Render	rs.l	1
ped_TimeoutSecs	rs.l	1
ped_8BitChars	rs.l	1
ped_SIZEOF	rs.w	0
	rsreset
PrinterSegment	rs.b	0
ps_NextSegment	rs.l	1
ps_runAlert	rs.l	1
ps_Version	rs.w	1
ps_Revision	rs.w	1
ps_PED	rs.w	0
	ENDC

