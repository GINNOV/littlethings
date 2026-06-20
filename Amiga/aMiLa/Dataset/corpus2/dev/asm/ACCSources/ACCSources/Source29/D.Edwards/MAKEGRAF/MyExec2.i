

		opt	d+


* This is my standard EXEC header file. It has been ripped off
* from the Genam library files & altered to suit my own
* purposes.


ExecBase		equ	4
NULL		equ	0

* defines library offsets and macros for calling exec library
* from location execbase

* note: four of the Semaphore names changed

Supervisor	equ	-30
ExitIntr		equ	-36
Schedule		equ	-42
Reschedule	equ	-48
Switch		equ	-54
Dispatch		equ	-60
Exception	equ	-66
InitCode		equ	-72
InitStruct	equ	-78
MakeLibrary	equ	-84
MakeFunctions	equ	-90
FindResident	equ	-96
InitResident	equ	-102
Alert		equ	-108
Debug		equ	-114
Disable		equ	-120
Enable		equ	-126
Forbid		equ	-132
Permit		equ	-138
SetSR		equ	-144
SuperState	equ	-150
UserState	equ	-156
SetIntVector	equ	-162
AddIntServer	equ	-168
RemIntServer	equ	-174
Cause		equ	-180
Allocate		equ	-186
Deallocate	equ	-192
AllocMem		equ	-198
AllocAbs		equ	-204
FreeMem		equ	-210
AvailMem		equ	-216
AllocEntry	equ	-222
FreeEntry	equ	-228
Insert		equ	-234
AddHead		equ	-240
AddTail		equ	-246
Remove		equ	-252
RemHead		equ	-258
RemTail		equ	-264
Enqueue		equ	-270
FindName		equ	-276
AddTask		equ	-282
RemTask		equ	-288
FindTask		equ	-294
SetTaskPri	equ	-300
SetSignal	equ	-306
SetExcept	equ	-312
Wait		equ	-318
Signal		equ	-324
AllocSignal	equ	-330
FreeSignal	equ	-336
AllocTrap	equ	-342
FreeTrap		equ	-348
AddPort		equ	-354
RemPort		equ	-360
PutMsg		equ	-366
GetMsg		equ	-372
ReplyMsg		equ	-378
WaitPort		equ	-384
FindPort		equ	-390
AddLibrary	equ	-396
RemLibrary	equ	-402
OldOpenLibrary	equ	-408
CloseLibrary	equ	-414
SetFunction	equ	-420
SumLibrary	equ	-426
AddDevice	equ	-432
RemDevice	equ	-438
OpenDevice	equ	-444
CloseDevice	equ	-450
DoIO		equ	-456
SendIO		equ	-462
CheckIO		equ	-468
WaitIO		equ	-474
AbortIO		equ	-480
AddResource	equ	-486
RemResource	equ	-492
OpenResource	equ	-498
RawIOInit	equ	-504
RawMayGetChar	equ	-510
RawPutChar	equ	-516
RawDoFmt		equ	-522
GetCC		equ	-528
TypeOfMem	equ	-534
Procure		equ	-540
Vacate		equ	-546
OpenLibrary	equ	-552
* 1.2 added
InitSemaphore	equ	-558
ObtSemphore	equ	-564	was ObtainSemaphore	
RelSemphore	equ	-570	was ReleaseSemaphore
AttemptSemaphore	equ	-576
ObtSemaphoreList	equ	-582	was Obtain etc
RelSemaphoreList	equ	-588	was Release etc
FindSemaphore	equ	-594
AddSemaphore	equ	-600
RemSemaphore	equ	-606
SumKickData	equ	-612
AddMemList	equ	-618
CopyMem		equ	-624
CopyMemQuick	equ	-630


MEMF_CHIP	equ	2
MEMF_FAST	equ	4
MEMF_PUBLIC	equ	1
MEMF_CLEAR	equ	$10000
MEMF_LARGEST	equ	$20000

MEMF_VARS	equ	MEMF_PUBLIC+MEMF_CLEAR

PARALLEL_PRINTER	equ	$00
SERIAL_PRINTER	equ	$01

BAUD_110		equ	$00
BAUD_300		equ	$01
BAUD_1200	equ	$02
BAUD_2400	equ	$03
BAUD_4800	equ	$04
BAUD_9600	equ	$05
BAUD_19200	equ	$06
BAUD_MIDI	equ	$07

FANFOLD		equ	$00
SINGLE		equ	$80

PICA		equ	$000
ELITE		equ	$400
FINE		equ	$800

DRAFT		equ	$000
LETTER		equ	$100

SIX_LPI		equ	$000
EIGHT_LPI	equ	$200

IMAGE_POSITIVE	equ	0
IMAGE_NEGATIVE	equ	1

ASPECT_HORIZ	equ	0
ASPECT_VERT	equ	1

SHADE_BW		equ	$00
SHADE_GREYSCALE	equ	$01
SHADE_COLOR	equ	$02

US_LETTER	equ	$00
US_LEGAL		equ	$10
N_TRACTOR	equ	$20
W_TRACTOR	equ	$30
CUSTOM		equ	$40

CUSTOM_NAME	equ	$00
ALPHA_P_101	equ	$01
BROTHER_15XL	equ	$02
CBM_MPS1000	equ	$03
DIAB_630		equ	$04
DIAB_ADV_D25	equ	$05
DIAB_C_150	equ	$06
EPSON		equ	$07
EPSON_JX_80	equ	$08
OKIMATE_20	equ	$09
QUME_LP_20	equ	$0A
HP_LASERJET	equ	$0B
HP_LASERJET_PLUS	equ	$0C


CHECKWIDTH	equ	19
COMMWIDTH	equ	27
LOWCHECKWIDTH	equ	13
LOWCOMMWIDTH	equ	16

ALERT_TYPE	equ	$80000000
RECOVERY_ALERT	equ	$00000000
DEADEND_ALERT	equ	$80000000

* this is the list of exec node types

NT_TASK		equ	1
NT_INTERRUPT	equ	2
NT_DEVICE	equ	3
NT_MSGPORT	equ	4
NT_MESSAGE	equ	5
NT_FREEMSG	equ	6
NT_REPLYMSG	equ	7
NT_RESOURCE	equ	8
NT_LIBRARY	equ	9
NT_MEMORY	equ	10
NT_SOFTINT	equ	11
NT_FONT		equ	12
NT_PROCESS	equ	13
NT_SEMAPHORE	equ	14

* device definitions

DEV_BEGINIO	equ	-30
DEV_ABORTIO	equ	-36
IOB_QUICK	equ	0
IOF_QUICK	equ	1
CMD_INVALID	equ	0
CMD_RESET	equ	1
CMD_READ		equ	2
CMD_WRITE	equ	3
CMD_UPDATE	equ	4
CMD_CLEAR	equ	5
CMD_STOP		equ	6
CMD_START	equ	7
CMD_FLUSH	equ	8
CMD_NONSTD	equ	9


* MinNode, MinList


		rsreset
mlh_Head		rs.l	1
mlh_Tail		rs.l	1
mlh_TaiolPred	rs.l	1
mlh_Sizeof	rs.w	0


		rsreset

mln_Succ		rs.l	1
mln_Pred		rs.l	1
mln_Sizeof	rs.w	0


* node structure def

		rsreset
ln_Succ		rs.l	1
ln_Pred		rs.l	1
ln_Type		rs.b	1
ln_Pri		rs.b	1
ln_Name		rs.l	1

ln_sizeof	rs.w	0


* list structure def

		rsreset
lh_Head		rs.l	1
lh_Tail		rs.l	1
lh_TailPred	rs.l	1
lh_Type		rs.b	1
lh_Pad		rs.b	1

lh_sizeof	rs.w	0


* library structure

		rsreset
lib_node		rs.b	ln_sizeof
lib_flags	rs.b	1
lib_pad		rs.b	1
lib_negsize	rs.w	1
lib_possize	rs.w	1
lib_version	rs.w	1
lib_revision	rs.w	1
lib_idstring	rs.l	1
lib_sum		rs.l	1
lib_opencnt	rs.w	1

lib_sizeof	rs.w	0


* this is the basic interrupt structure


		rsreset
is_node		rs.b	ln_sizeof
is_data		rs.l	1
is_code		rs.l	1
is_sizeof	rs.w	0


* this is the interrupt vector structure

		rsreset
iv_data		rs.l	1
iv_code		rs.l	1
iv_node		rs.l	1
iv_sizeof	rs.w	0


* this is the interrupt server list structure


		rsreset
sl_list		rs.b	lh_sizeof
sl_IntClr1	rs.w	1
sl_IntSet	rs.w	1
sl_IntClr2	rs.w	1
sl_pad		rs.w	1
sl_sizeof	rs.w	0


* soft int list structure


		rsreset
sh_list		rs.b	lh_sizeof
sh_pad		rs.w	1
sh_sizeof	rs.w	0


* here goes task structure definition


		rsreset
tc_node		rs.b	ln_sizeof
tc_flags		rs.b	1
tc_state		rs.b	1
tc_IDnestcnt	rs.b	1
tc_TDnestcnt	rs.b	1
tc_sigalloc	rs.l	1
tc_sigwait	rs.l	1
tc_sigrecvd	rs.l	1
tc_sigexecpt	rs.l	1
tc_trapalloc	rs.w	1
tc_trapable	rs.w	1
tc_exceptdata	rs.l	1
tc_exceptcode	rs.l	1
tc_trapdata	rs.l	1
tc_trapcode	rs.l	1
tc_SPreg		rs.l	1
tc_SPlower	rs.l	1
tc_SPupper	rs.l	1
tc_switch	rs.l	1
tc_launch	rs.l	1
tc_mementry	rs.b	lh_sizeof
tc_userdata	rs.l	1

tc_sizeof	rs.w	0


TC_INVALID	equ	0
TC_ADDED		equ	1
TC_RUNNING	equ	2
TC_READY		equ	3
TC_WAITING	equ	4
TC_EXCEPTION	equ	5
TC_REMOVED	equ	6


* message node structure

		rsreset
mn_Node		rs.b	ln_sizeof
mn_ReplyPort	rs.l	1
mn_Length	rs.w	1	;size of message:appended to structure!
mn_sizeof	rs.w	0


* message port structure


		rsreset
mp_Node		rs.b	ln_sizeof
mp_Flags		rs.b	1
mp_SigBit	rs.b	1
mp_SigTask	rs.l	1
mp_MsgList	rs.b	lh_sizeof	;NOT a pointer!!!

mp_sizeof	rs.w	0


PA_SIGNAL	equ	0
PA_SOFTINT	equ	1
PA_IGNORE	equ	2


* memlist structure

		rsreset
ml_node		rs.b	ln_sizeof
ml_numentries	rs.w	1
ml_me		rs.l	1


* EXECBASE STRUCTURE : Use with care!!!

		rsreset

LibNode		rs.b	lib_sizeof
SoftVer		rs.w	1
LowMemChkSum	rs.w	1
ChkBase		rs.l	1
ColdCapture	rs.l	1
CoolCapture	rs.l	1
WarmCapture	rs.l	1
SysStkUpper	rs.l	1
SysStkLower	rs.l	1
MaxLocMem	rs.l	1
DebugEntry	rs.l	1
DebugData	rs.l	1
AlertData	rs.l	1
MaxExtMem	rs.l	1
ChkSum		rs.w	1
IntVects		rs.b	iv_sizeof*16
ThisTask		rs.l	1
IdleCount	rs.l	1
DispCount	rs.l	1
Quantum		rs.w	1
Elapsed		rs.w	1
SysFlags		rs.w	1
IDNestCnt	rs.b	1
TDNestCnt	rs.b	1
AttnFlags	rs.w	1
AttnResched	rs.w	1
ResModules	rs.l	1
TaskTrapCode	rs.l	1
TaskExceptCode	rs.l	1
TaskExitCode	rs.l	1
TaskSigAlloc	rs.l	1
TaskTrapAlloc	rs.w	1
MemList		rs.b	lh_sizeof
ResourceList	rs.b	lh_sizeof
DeviceList	rs.b	lh_sizeof
IntrList		rs.b	lh_sizeof
LibList		rs.b	lh_sizeof
PortList		rs.b	lh_sizeof
TaskReady	rs.b	lh_sizeof
TaskWait		rs.b	lh_sizeof
SoftIntList	rs.b	80
LastAlert	rs.l	4
VBLFreq		rs.b	1
PSUFreq		rs.b	1
SemaphoreList	rs.b	lh_sizeof
KickMemPtr	rs.l	1
KickTagPtr	rs.l	1
KickCheckSum	rs.l	1
ExecBaseResvd	rs.b	10
ExecBaseNewResvd	rs.b	20

execbase_sizeof	rs.w	0

AFB_68010	equ	0
AFB_68020	equ	1
AFB_68881	equ	4
AFF_68010	equ	1<<0
AFF_68020	equ	1<<1
AFF_68881	equ	1<<4

AFB_RESERVED8	equ	8
AFB_RESERVED9	equ	9



* This is my macro for calling an EXEC.LIBRARY function

CALLEXEC		macro	name	;call an EXEC function

		move.l	a6,-(sp)
		move.l	ExecBase,a6
		jsr	\1(a6)
		move.l	(sp)+,a6

		endm



