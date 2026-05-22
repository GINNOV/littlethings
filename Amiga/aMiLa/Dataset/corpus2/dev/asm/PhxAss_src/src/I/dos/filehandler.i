 ifnd DOS_FILEHANDLER_I
DOS_FILEHANDLER_I set 1
*
*  dos/filehandler.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd EXEC_TYPES_I
 include "exec/types.i"
 endc
 ifnd EXEC_PORTS_I
 include "exec/ports.i"
 endc
 ifnd LIBRARIES_DOS_I
 include "libraries/dos.i"
 endc


** Disk Enveironment to describe the disk geometry
** struct DosEnvec
 rsreset
de_TableSize	rs.l 1
de_SizeBlock	rs.l 1
de_SecOrg	rs.l 1
de_Surfaces	rs.l 1
de_SectorPerBlock rs.l 1
de_BlocksPerTrack rs.l 1
de_Reserved	rs.l 1
de_PreAlloc	rs.l 1
de_Interleave	rs.l 1
de_LowCyl	rs.l 1
de_HighCyl	rs.l 1
de_NumBuffers	rs.l 1
de_BufMemType	rs.l 1
de_MaxTransfer	rs.l 1
de_Mask 	rs.l 1
de_BootPri	rs.l 1
de_DosType	rs.l 1
de_Baud 	rs.l 1
de_Control	rs.l 1
de_BootBlocks	rs.l 1
DosEnvec_SIZEOF rs.w 0

DE_TABLESIZE	= 0
DE_SIZEBLOCK	= 1
DE_SECORG	= 2
DE_NUMHEADS	= 3
DE_SECSPERBLK	= 4
DE_BLKSPERTRACK = 5
DE_RESERVEDBLKS = 6
DE_PREFAC	= 7
DE_INTERLEAVE	= 8
DE_LOWCYL	= 9
DE_UPPERCYL	= 10
DE_NUMBUFFERS	= 11
DE_MEMBUFTYPE	= 12
DE_BUFMEMTYPE	= 12
DE_MAXTRANSFER	= 13
DE_MASK 	= 14
DE_BOOTPRI	= 15
DE_DOSTYPE	= 16
DE_BAUD 	= 17
DE_CONTROL	= 18
DE_BOOTBLOCKS	= 19

** struct FileSysStartupMsg
 rsreset
fssm_Unit	rs.l 1
fssm_Device	rs.l 1
fssm_Environ	rs.l 1
fssm_Flags	rs.l 1
FileSysStartupMsg_SIZEOF rs.w 0

** struct DeviceNode
 rsreset
dn_Next 	rs.l 1
dn_Type 	rs.l 1
dn_Task 	rs.l 1
dn_Lock 	rs.l 1
dn_Handler	rs.l 1
dn_StackSize	rs.l 1
dn_Priority	rs.l 1
dn_Startup	rs.l 1
dn_SegList	rs.l 1
dn_GlobalVec	rs.l 1
dn_Name 	rs.l 1
DeviceNode_SIZEOF rs.w 0

 endc
