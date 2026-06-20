 ifnd EXEC_EXECBASE_I
EXEC_EXECBASE_I set 1
*
*  exec/execbase.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd EXEC_TYPES_I
 include "exec/types.i"
 endc

 ifnd EXEC_LISTS_I
 include "exec/lists.i"
 endc

 ifnd EXEC_INTERRUPTS_I
 include "exec/interrupts.i"
 endc

 ifnd EXEC_LIBRARIES_I
 include "exec/libraries.i"
 endc


 rsset lib_SIZE
SoftVer 	rs.w 1
LowMemChkSum	rs.w 1
ChkBase 	rs.l 1
ColdCapture	rs.l 1
CoolCapture	rs.l 1
WarmCapture	rs.l 1
SysStkUpper	rs.l 1
SysStkLower	rs.l 1
MaxLocMem	rs.l 1
DebugEntry	rs.l 1
DebugData	rs.l 1
AlertData	rs.l 1
MaxExtMem	rs.l 1
ChkSum		rs.w 1
IntVects	rs 0
IVTBE		rs.b iv_SIZE
IVDSKBLK	rs.b iv_SIZE
IVSOFTINT	rs.b iv_SIZE
IVPORTS 	rs.b iv_SIZE
IVCOPER 	rs.b iv_SIZE
IVVERTB 	rs.b iv_SIZE
IVBLIT		rs.b iv_SIZE
IVAUD0		rs.b iv_SIZE
IVAUD1		rs.b iv_SIZE
IVAUD2		rs.b iv_SIZE
IVAUD3		rs.b iv_SIZE
IVRBF		rs.b iv_SIZE
IVDSKSYNC	rs.b iv_SIZE
IVEXTER 	rs.b iv_SIZE
IVINTEN 	rs.b iv_SIZE
IVNMI		rs.b iv_SIZE
ThisTask	rs.l 1
IdleCount	rs.l 1
DispCount	rs.l 1
Quantum 	rs.w 1
Elapsed 	rs.w 1
SysFlags	rs.w 1
IDNestCnt	rs.b 1
TDNestCnt	rs.b 1
AttnFlags	rs.w 1
AttnResched	rs.w 1
ResModules	rs.l 1
TaskTrapCode	rs.l 1
TaskExceptCode	rs.l 1
TaskExitCode	rs.l 1
TaskSigAlloc	rs.l 1
TaskTrapAlloc	rs.w 1
MemList 	rs.b lh_SIZE
ResourceList	rs.b lh_SIZE
DeviceList	rs.b lh_SIZE
IntrList	rs.b lh_SIZE
LibList 	rs.b lh_SIZE
PortList	rs.b lh_SIZE
TaskReady	rs.b lh_SIZE
TaskWait	rs.b lh_SIZE
SoftInts	rs.b sh_SIZE*5
LastAlert	rs.l 4
VBlankFrequency rs.b 1
PowerSupplyFrequency rs.b 1
SemaphoreList	rs.b lh_SIZE
KickMemPtr	rs.l 1
KickTagPtr	rs.l 1
KickCheckSum	rs.l 1
ex_Pad0 	rs.w 1		; V36 Additions
ex_Reserved0	rs.l 1
ex_RamLibPrivate rs.l 1
ex_EClockFrequency rs.l 1
ex_CacheControl rs.l 1
ex_TaskID	rs.l 1
ex_PuddleSize	rs.l 1
ex_PoolThreshold rs.l 1
ex_PublicPool	rs.b mln_SIZE
ex_MMULock	rs.l 1
ex_Reserved	rs.l 3
SYSBASESIZE	rs.w 0

 BITDEF AF,68010,0
 BITDEF AF,68020,1
 BITDEF AF,68030,2
 BITDEF AF,68040,3
 BITDEF AF,68881,4
 BITDEF AF,68882,5

 BITDEF CACR,EnableI,0
 BITDEF CACR,FreezeI,1
 BITDEF CACR,ClearI,3
 BITDEF CACR,IBE,4
 BITDEF CACR,EnableD,8
 BITDEF CACR,FreezeD,9
 BITDEF CACR,ClearD,11
 BITDEF CACR,DBE,12
 BITDEF CACR,WriteAllocate,13

 endc
