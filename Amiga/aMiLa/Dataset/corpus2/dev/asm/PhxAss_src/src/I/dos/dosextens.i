 ifnd DOS_DOSEXTENS_I
DOS_DOSEXTENS_I set 1
*
*  dos/dosextens.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd EXEC_TYPES_I
 include "exec/types.i"
 endc
 ifnd EXEC_TASKS_I
 include "exec/tasks.i"
 endc
 ifnd EXEC_PORTS_I
 include "exec/ports.i"
 endc
 ifnd EXEC_LIBRARIES_I
 include "exec/libraries.i"
 endc
 ifnd EXEC_SEMAPHORES_I
 include "exec/semaphores.i"
 endc
 ifnd DEVICES_TIMER_I
 include "devices/timer.i"
 endc

 ifnd DOS_DOS_I
 include "dos/dos.i"
 endc


** DOS Process Structure
 rsreset
pr_Task 	rs.b tc_SIZE
pr_MsgPort	rs.b mp_SIZE
pr_Pad		rs.w 1
pr_SegList	rs.l 1
pr_StackSize	rs.l 1
pr_GlobVec	rs.l 1
pr_TaskNum	rs.l 1
pr_StackBase	rs.l 1
pr_Result2	rs.l 1
pr_CurrentDir	rs.l 1
pr_CIS		rs.l 1
pr_COS		rs.l 1
pr_ConsoleTask	rs.l 1
pr_FileSystemTask rs.l 1
pr_CLI		rs.l 1
pr_ReturnAddr	rs.l 1
pr_PktWait	rs.l 1
pr_WindowPtr	rs.l 1
* following definitions are new with OS2.0
pr_HomeDir	rs.l 1
pr_Flags	rs.l 1
pr_ExitCode	rs.l 1
pr_ExitData	rs.l 1
pr_Arguments	rs.l 1
pr_LocalVars	rs.b mlh_SIZE
pr_ShellPrivate rs.l 1
pr_CES		rs.l 1
pr_SIZEOF	rs

 BITDEF PR,FREESEGLIST,0
 BITDEF PR,FREECURRDIR,1
 BITDEF PR,FREECLI,2
 BITDEF PR,CLOSEINPUT,3
 BITDEF PR,CLOSEOUTPUT,4
 BITDEF PR,FREEARGS,5


** struct FileHandle
 rsreset
fh_Link 	rs.l 1
fh_Interactive	rs.l 1
fh_Port 	= fh_Interactive
fh_Type 	rs.l 1
fh_Buf		rs.l 1
fh_Pos		rs.l 1
fh_End		rs.l 1
fh_Funcs	rs.l 1
fh_Func1	= fh_Funcs
fh_Func2	rs.l 1
fh_Func3	rs.l 1
fh_Args 	rs.l 1
fh_Arg1 	= fh_Args
fh_Arg2 	rs.l 1
fh_SIZEOF	rs

** struct DosPacket
 rsreset
dp_Link 	rs.l 1
dp_Port 	rs.l 1
dp_Type 	rs.l 1
dp_Res1 	rs.l 1
dp_Res2 	rs.l 1
dp_Arg1 	rs.l 1
dp_Arg2 	rs.l 1
dp_Arg3 	rs.l 1
dp_Arg4 	rs.l 1
dp_Arg5 	rs.l 1
dp_Arg6 	rs.l 1
dp_Arg7 	rs.l 1
dp_SIZEOF	rs
dp_Action	= dp_Type
dp_Status	= dp_Res1
dp_Status2	= dp_Res2
dp_BufAddr	= dp_Arg1

** struct StandardPacket
 rsreset
sp_Msg		rs.b mn_SIZE
sp_Pkt		rs.b dp_SIZEOF
sp_SIZEOF	rs

** Packet Types
ACTION_NIL = 0
ACTION_STARTUP = 0
ACTION_GET_BLOCK = 2
ACTION_SET_MAP = 4
ACTION_DIE = 5
ACTION_EVENT = 6
ACTION_CURRENT_VOLUME = 7
ACTION_LOCATE_OBJECT = 8
ACTION_RENAME_DISK = 9
ACTION_WRITE = 'W'
ACTION_READ = 'R'
ACTION_FREE_LOCK = 15
ACTION_DELETE_OBJECT = 16
ACTION_RENAME_OBJECT = 17
ACTION_MORE_CACHE = 18
ACTION_COPY_DIR = 19
ACTION_WAIT_CHAR = 20
ACTION_SET_PROTECT = 21
ACTION_CREATE_DIR = 22
ACTION_EXAMINE_OBJECT = 23
ACTION_EXAMINE_NEXT = 24
ACTION_DISK_INFO = 25
ACTION_INFO = 26
ACTION_FLUSH = 27
ACTION_SET_COMMENT = 28
ACTION_PARENT = 29
ACTION_TIMER = 30
ACTION_INHIBIT = 31
ACTION_DISK_TYPE = 32
ACTION_DISK_CHANGE = 33
ACTION_SET_DATE = 34
ACTION_SCREEN_MODE = 994
ACTION_READ_RETURN = 1001
ACTION_WRITE_RETURN = 1002
ACTION_SEEK = 1008
ACTION_FINDUPDATE = 1004
ACTION_FINDINPUT = 1005
ACTION_FINDOUTPUT = 1006
ACTION_END = 1007
ACTION_SET_FILE_SIZE = 1022
ACTION_WRITE_PROTECT = 1023
** new OS2.0 packets
ACTION_SAME_LOCK = 40
ACTION_FORMAT = 1020
ACTION_MAKELINK = 1021
ACTION_READLINK = 1024
ACTION_FH_FROM_LOCK = 1026
ACTION_IS_FILESYSTEM = 1027
ACTION_CHANGE_MODE = 1028
ACTION_COPY_DIR_FH = 1030
ACTION_PARENT_FH = 1031
ACTION_EXAMINE_ALL = 1033
ACTION_EXAMINE_FH = 1034
ACTION_LOCK_RECORD = 2008
ACTION_FREE_RECORD = 2009
ACTION_ADD_NOTIFY = 4097
ACTION_REMOVE_NOTIFY = 4098

** struct ErrorString
 rsreset
estr_Nums	rs.l 1
estr_Strings	rs.l 1
ErrorString_SIZEOF rs

** DOS library node structure
 rsreset
dl_lib		rs.b lib_SIZE
dl_Root 	rs.l 1
dl_GV		rs.l 1
dl_A2		rs.l 1
dl_A5		rs.l 1
dl_A6		rs.l 1
dl_SIZEOF	rs

** struct RootNode
 rsreset
rn_TaskArray	rs.l 1
rn_ConsoleSegment rs.l 1
rn_Time 	rs.b ds_SIZEOF
rn_RestartSeg	rs.l 1
rn_Info 	rs.l 1
rn_FileHandlerSegment rs.l 1
rn_CliList	rs.b mlh_SIZE
rn_BootProc	rs.l 1
rn_ShellSegment rs.l 1
rn_Flags	rs.l 1
rn_SIZEOF	rs
 BITDEF RN,WILDSTAR,0

** struct CliProcList
 rsreset
cpl_Node	rs.b mln_SIZE
cpl_First	rs.l 1
cpl_Array	rs.l 1
cpl_SIZEOF	rs

** struct DosInfo
 rsreset
di_McName	rs.l 1
di_DevInfo	rs.l 1
di_Devices	rs.l 1
di_Handlers	rs.l 1
di_NetHand	rs.l 1
di_DevLock	rs.b ss_SIZE
di_EntryLock	rs.b ss_SIZE
di_SIZEOF	rs

** struct CommandLineInterface - CLI Structure
 rsreset
cli_Result2	rs.l 1
cli_SetName	rs.l 1
cli_CommandDir	rs.l 1
cli_ReturnCode	rs.l 1
cli_CommandName rs.l 1
cli_FailLevel	rs.l 1
cli_Prompt	rs.l 1
cli_StandardInput rs.l 1
cli_CurrentInput rs.l 1
cli_CommandFile rs.l 1
cli_Interactive rs.l 1
cli_Background	rs.l 1
cli_CurrentOutput rs.l 1
cli_DefaultStack rs.l 1
cli_StandardOutput rs.l 1
cli_Module	rs.l 1
cli_SIZEOF	rs

** struct DeviceList
 rsreset
dl_Next 	rs.l 1
dl_Type 	rs.l 1
dl_Task 	rs.l 1
dl_Lock 	rs.l 1
dl_VolumeDate	rs.b ds_SIZEOF
dl_LockList	rs.l 1
dl_DiskType	rs.l 1
dl_unused	rs.l 1
dl_Name 	rs.l 1
DevList_SIZEOF	rs

** struct DevInfio
 rsreset
dvi_Next	rs.l 1
dvi_Type	rs.l 1
dvi_Task	rs.l 1
dvi_Lock	rs.l 1
dvi_Handler	rs.l 1
dvi_Stacksize	rs.l 1
dvi_Priority	rs.l 1
dvi_Startup	rs.l 1
dvi_SegList	rs.l 1
dvi_GlobVec	rs.l 1
dvi_Name	rs.l 1
dvi_SIZEOF	rs

** struct DosList
 rsreset
dol_Next	rs.l 1
dol_Type	rs.l 1
dol_Task	rs.l 1
dol_Lock	rs.l 1
dol_misc	rs
* union member dol_assign
dol_AssignName	rs.l 1
dol_List	rs.l 1
* union member dol_volume
 rsset dol_misc
dol_VolumeDate	rs.b ds_SIZEOF
dol_LockList	rs.l 1
dol_DiskType	rs.l 1
* union member dol_handler
 rsset	dol_misc
dol_Handler	rs.l 1
dol_StackSize	rs.l 1
dol_Priority	rs.l 1
dol_Startup	rs.l 1
dol_SegList	rs.l 1
dol_GlobVec	rs.l 1
* union END
dol_Name	rs.l 1
DosList_SIZEOF	rs

DLT_DEVICE	= 0
DLT_DIRECTORY	= 1
DLT_VOLUME	= 2
DLT_LATE	= 3
DLT_NONBINDING	= 4
DLT_PRIVATE	= -1

** struct DevProc - returned by GetDeviceProc()
 rsreset
dvp_Port	rs.l 1
dvp_Lock	rs.l 1
dvp_Flags	rs.l 1
dvp_DevNode	rs.l 1
dvp_SIZEOF	rs
 BITDEF DVP,UNLOCK,0
 BITDEF DVP,ASSIGN,1

 BITDEF LD,READ,0
 BITDEF LD,WRITE,1
 BITDEF LD,DEVICES,2
 BITDEF LD,VOLUMES,3
 BITDEF LD,ASSIGNS,4
 BITDEF LD,ENTRY,5
LDF_ALL = LDF_DEVICES|LDF_VOLUMES|LDF_ASSIGNS

** struct FileLock
 rsreset
fl_Link 	rs.l 1
fl_Key		rs.l 1
fl_Access	rs.l 1
fl_Task 	rs.l 1
fl_Volume	rs.l 1
fl_SIZEOF	rs

REPORT_STREAM	= 0
REPORT_TASK	= 1
REPORT_LOCK	= 2
REPORT_VOLUME	= 3
REPORT_INSERT	= 4

ABORT_DISK_ERROR = 296
ABORT_BUSY	= 288

RUN_EXECUTE	= -1
RUN_SYSTEM	= -2
RUN_SYSTEM_ASYNCH = -3

 endc
