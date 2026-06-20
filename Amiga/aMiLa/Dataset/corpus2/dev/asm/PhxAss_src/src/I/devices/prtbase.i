 ifnd DEVICES_PRTBASE_I
DEVICES_PRTBASE_I set 1
*
*  devices/prtbase.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1994
*

 ifnd EXEC_TYPES_I
 include "exec/types.i"
 endc
 ifnd EXEC_LISTS_I
 include "exec/lists.i"
 endc
 ifnd EXEC_PORTS_I
 include "exec/ports.i"
 endc
 ifnd EXEC_LIBRARIES_I
 include "exec/libraries.i"
 endc
 ifnd EXEC_TASKS_I
 include "exec/tasks.i"
 endc
 ifnd DEVICES_PARALLEL_I
 include "devices/parallel.i"
 endc
 ifnd DEVICES_SERIAL_I
 include "devices/serial.i"
 endc
 ifnd DEVICES_TIMER_I
 include "devices/timer.i"
 endc
 ifnd LIBRARIES_DOSEXTENS_I
 include "libraries/dosextens.i"
 endc
 ifnd INTUITION_PREFERENCES_I
 include "intuition/preferences.i"
 endc

* struct DeviceData
 rsset lib_SIZE
dd_Segment	rs.l 1
dd_ExecBase	rs.l 1
dd_CmdVectors	rs.l 1
dd_CmdBytes	rs.l 1
dd_NumCommands	rs.w 1
DeviceData_SIZEOF rs

du_Flags	= ln_Pri

 BITDEF IO,QUEUED,4
 BITDEF IO,CURRENT,5
 BITDEF IO,SERVICING,6
 BITDEF IO,DONE,7
 BITDEF DU,STOPPED,0

P_PRIORITY	= 0
P_OLDSTKSIZE	= $800
P_STKSIZE	= $1000
P_BUFSIZE	= 256
P_SAFESIZE	= 128
 BITDEF P,IOR0,0
 BITDEF P,IOR1,1
 BITDEF P,EXPUNGED,7

* struct PrinterData
 rsset DeviceData_SIZEOF
pd_Unit 		rs.b mp_SIZE
pd_PrinterSegment	rs.l 1
pd_PrinterType		rs.w 1
pd_SegmentData		rs.l 1
pd_PrintBuf		rs.l 1
pd_PWrite		rs.l 1
pd_PBothReady		rs.l 1
 ifgt IOExtPar_SIZE-IOExtSer_SIZE
pd_IOR0 		rs.b IOExtPar_SIZE
pd_IOR1 		rs.b IOExtPar_SIZE
 else
pd_IOR0 		rs.b IOExtSer_SIZE
pd_IOR1 		rs.b IOExtSer_SIZE
 endc
pd_TIOR 		rs.b iotv_SIZE
pd_IORPort		rs.b mp_SIZE
pd_TC			rs.b tc_SIZE
pd_OldStk		rs.b P_OLDSTKSIZE
pd_Flags		rs.b 1
pd_pad			rs.b 1
pd_Preferences		rs.b pf_SIZEOF
pd_PWaitEnabled 	rs.b 1
pd_Pad1 		rs.b 1
pd_Stk			rs.b P_STKSIZE
pd_SIZEOF		rs

 BITDEF PPC,GFX,0
 BITDEF PPC,COLOR,1
PPC_BWALPHA equ 0
PPC_BWGFX equ 1
PPC_COLORGFX equ 3
PCC_BW equ 1
PCC_YMC equ 2
PCC_YMC_BW equ 3
PCC_YMCB equ 4
PCC_4COLOR equ 4
PCC_ADDITIVE equ 8
PCC_WB equ 9
PCC_BGR equ 10
PCC_BGR_WB equ 11
PCC_BGRW equ 12
PCC_MULTI_PASS equ 16

* struct PrinterExtendedData
 rsreset
ped_PrinterName 	rs.l 1
ped_Init		rs.l 1
ped_Expunge		rs.l 1
ped_Open		rs.l 1
ped_Close		rs.l 1
ped_PrinterClass	rs.b 1
ped_ColorClass		rs.b 1
ped_MaxColumns		rs.b 1
ped_NumCharSets 	rs.b 1
ped_NumRows		rs.w 1
ped_MaxXDots		rs.l 1
ped_MaxYDots		rs.l 1
ped_XDotsInch		rs.w 1
ped_YDotsInch		rs.w 1
ped_Commands		rs.l 1
ped_DoSpecial		rs.l 1
ped_Render		rs.l 1
ped_TimeoutSecs 	rs.l 1
ped_8BitChars		rs.l 1
ped_PrintMode		rs.l 1
ped_ConvFunv		rs.l 1
ped_SIZEOF		rs

* struct PrinterSegment
 rsreset
ps_NextSegment	rs.l 1
ps_runAlert	rs.l 1
ps_Version	rs.w 1
ps_Revision	rs.w 1
ps_PED		rs

 endc
