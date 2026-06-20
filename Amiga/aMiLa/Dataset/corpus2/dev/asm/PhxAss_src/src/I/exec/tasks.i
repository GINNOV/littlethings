 ifnd EXEC_TASKS_I
EXEC_TASKS_I set 1
*
*  exec/tasks.i
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

 ifnd EXEC_PORTS_I
 include "exec/ports.i"
 endc


** Task Control Structure
 rsset	ln_SIZE
tc_Flags	rs.b 1
tc_State	rs.b 1
tc_IDNestCnt	rs.b 1
tc_TDNestCnt	rs.b 1
tc_SigAlloc	rs.l 1
tc_SigWait	rs.l 1
tc_SigRecvd	rs.l 1
tc_SigExcept	rs.l 1
;tc_TrapAlloc	 rs.w 1    obsolete since V36
;tc_TrapAble	 rs.w 1
tc_ETask	rs.l 1
tc_ExceptData	rs.l 1
tc_ExceptCode	rs.l 1
tc_TrapData	rs.l 1
tc_TrapCode	rs.l 1
tc_SPReg	rs.l 1
tc_SPLower	rs.l 1
tc_SPUpper	rs.l 1
tc_Switch	rs.l 1
tc_Launch	rs.l 1
tc_MemEntry	rs.b lh_SIZE
tc_UserData	rs.l 1
tc_SIZE 	rs 0

** ETask Structure
 rsset mn_SIZE
et_Parent	rs.l 1
et_UniqueID	rs.l 1
et_Children	rs.b mlh_SIZE
et_TrapAlloc	rs.w 1
et_TrapAble	rs.w 1
et_Result1	rs.l 1
et_Result2	rs.l 1
et_TaskMsgPort	rs.b mp_SIZE
ETask_SIZEOF	rs 0

CHILD_NOTNEW	= 1
CHILD_NOTFOUND	= 2
CHILD_EXITED	= 3
CHILD_ACTIVE	= 4

** struct StackSwapStruct
 rsreset
stk_Lower	rs.l 1
stk_Upper	rs.l 1
stk_Pointer	rs.l 1
StackSwapStruct_SIZEOF rs 0

 BITDEF T,PROCTIME,0
 BITDEF T,ETASK,3
 BITDEF T,STACKCHK,4
 BITDEF T,EXCEPT,5
 BITDEF T,SWITCH,6
 BITDEF T,LAUNCH,7

TS_INVALID  = 0
TS_ADDED    = 1
TS_RUN	    = 2
TS_READY    = 3
TS_WAIT     = 4
TS_EXCEPT   = 5
TS_REMOVED  = 6

 BITDEF SIG,ABORT,0
 BITDEF SIG,CHILD,1
 BITDEF SIG,BLIT,4
 BITDEF SIG,SINGLE,4
 BITDEF SIG,INTUITION,5
 BITDEF SIG,DOS,8

SYS_SIGALLOC   = $ffff
SYS_TRAPALLOC  = $8000

 endc	 ; EXEC_TASKS_I
