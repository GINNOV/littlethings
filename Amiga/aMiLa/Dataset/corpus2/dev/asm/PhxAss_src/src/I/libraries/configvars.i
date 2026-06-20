 ifnd LIBRARIES_CONFIGVARS_I
LIBRARIES_CONFIGVARS_I set 1
*
*  libraries/configvars.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd EXEC_NODES_I
 include "exec/nodes.i"
 endc

 ifnd LIBRARIES_CONFIGREGS_I
 include "libraries/configregs.i"
 endc


* struct ConfigDev
 rsreset
cd_Node 	rs.b ln_SIZE
cd_Flags	rs.b 1
cd_Pad		rs.b 1
cd_Rom		rs.b ExpansionRom_SIZEOF
cd_BoardAddr	rs.l 1
cd_BoardSize	rs.l 1
cd_SlotAddr	rs.w 1
cd_SlotSize	rs.w 1
cd_Driver	rs.l 1
cd_NextCD	rs.l 1
cd_Unused	rs.l 4
ConfigDev_SIZEOF rs

 BITDEF CD,SHUTUP,0
 BITDEF CD,CONFIGME,1
 BITDEF CD,BADMEMORY,2


* struct CurrentBinding
 rsreset
cb_ConfigDev	rs.l 1
cb_FileName	rs.l 1
cb_ProductString rs.l 1
cb_ToolTypes	rs.l 1
CurrentBinding_SIZE rs

 endc
