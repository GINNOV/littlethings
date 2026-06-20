 ifnd DOS_DOSTAGS_I
DOS_DOSTAGS_I set 1
*
*  dos/dostags.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd UTILITY_TAGITEM_I
 include "utility/tagitem.i"
 endc

* System()
 rsset TAG_USER+32
SYS_Dummy	rs.b 1
SYS_Input	rs.b 1
SYS_Output	rs.b 1
SYS_Asynch	rs.b 1
SYS_UserShell	rs.b 1
SYS_CustomShell rs.b 1
;SYS_Error

* CreateNewProc()
 rsset TAG_USER+1000
NP_Dummy	rs.b 1
NP_SegList	rs.b 1
NP_FreeSegList	rs.b 1
NP_Entry	rs.b 1
NP_Input	rs.b 1
NP_Output	rs.b 1
NP_CloseInput	rs.b 1
NP_CloseOutput	rs.b 1
NP_Error	rs.b 1
NP_CloseError	rs.b 1
NP_CurrentDir	rs.b 1
NP_StackSize	rs.b 1
NP_Name 	rs.b 1
NP_Priority	rs.b 1
NP_ConsoleTask	rs.b 1
NP_WindowPtr	rs.b 1
NP_HomeDir	rs.b 1
NP_CopyVars	rs.b 1
NP_Cli		rs.b 1
NP_Path 	rs.b 1
NP_CommandName	rs.b 1
NP_Arguments	rs.b 1
NP_NotifyOnDeath rs.b 1
NP_Synchronous	rs.b 1
NP_ExitCode	rs.b 1
NP_ExitData	rs.b 1

* AllocDosObject()
 rsset TAG_USER+2000
ADO_Dummy	rs.b 1
DDO_FH_Mode	rs.b 1
ADO_DirLen	rs.b 1
ADO_CommNameLen rs.b 1
ADO_CommFileLen rs.b 1
ADO_PromptLen	rs.b 1

 endc
