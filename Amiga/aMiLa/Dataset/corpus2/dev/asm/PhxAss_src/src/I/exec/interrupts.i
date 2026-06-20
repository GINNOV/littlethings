 ifnd EXEC_INTERRUPTS_I
EXEC_INTERRUPTS_I set 1
*
*  exec/interrupts.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd EXEC_TYPES_I
 include "exec/types.i"
 endc
 ifnd EXEC_NODES_I
 include "exec/nodes.i"
 endc
 ifnd EXEC_LISTS_I
 include "exec/lists.i"
 endc


 rsset ln_SIZE
is_Data 	rs.l 1
is_Code 	rs.l 1
is_SIZE 	rs.w 0

 rsreset
iv_Data 	rs.l 1
iv_Code 	rs.l 1
iv_Node 	rs.l 1
iv_SIZE 	rs.w 0

 BITDEF S,SAR,15
 BITDEF S,TQE,14
 BITDEF S,SINT,13

 rsset lh_SIZE
sh_Pad		rs.w 1
sh_SIZE 	rs.w 0

SIH_PRIMASK equ $0f0
SIH_QUEUES  equ 5

 BITDEF  INT,NMI,15

 endc
