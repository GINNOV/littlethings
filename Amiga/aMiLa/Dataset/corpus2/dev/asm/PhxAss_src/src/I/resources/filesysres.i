 ifnd RESOURCES_FILESYSRES_I
RESOURCES_FILESYSRES_I set 1
*
*  resources/filesysres.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd EXEC_NODES_I
 include "exec/nodes.i"
 endc
 ifnd EXEC_LISTS_I
 include "exec/lists.i"
 endc
 ifnd LIBRARIES_DOS_I
 include "libraries/dos.i"
 endc


FSRNAME macro
 dc.b "FileSystem.resource",0
 endm

* struct FileSysResource
 rsset ln_SIZE
fsr_Creator		rs.l 1
fsr_FileSysEntries	rs.b lh_SIZE
FileSysResource_SIZEOF	rs

* struct FileSysEntry
 rsset ln_SIZE
fse_DosType	rs.l 1
fse_Version	rs.l 1
fse_PatchFlags	rs.l 1
fse_Type	rs.l 1
fse_Task	rs.l 1
fse_Lock	rs.l 1
fse_Handler	rs.l 1
fse_StackSize	rs.l 1
fse_Priority	rs.l 1
fse_Startup	rs.l 1
fse_SegList	rs.l 1
fse_GlobalVec	rs.l 1

 endc
