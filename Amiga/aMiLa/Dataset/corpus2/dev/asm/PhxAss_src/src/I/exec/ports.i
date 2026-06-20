 ifnd	 EXEC_PORTS_I
EXEC_PORTS_I set 1
*
*  exec/ports.i
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


** Message Port Structure
 rsset	ln_SIZE
mp_Flags	rs.b 1
mp_SigBit	rs.b 1
mp_SigTask	rs.l 1
mp_MsgList	rs.b lh_SIZE
mp_SIZE 	rs 0

mp_SoftInt  = mp_SigTask
PF_ACTION   = 3
PA_SIGNAL   = 0
PA_SOFTINT  = 1
PA_IGNORE   = 2

** Message Structure
 rsset	ln_SIZE
mn_ReplyPort	rs.l 1
mn_Length	rs.w 1
mn_SIZE 	rs 0

 endc	    ; EXEC_PORTS_I
