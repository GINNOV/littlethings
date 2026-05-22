 ifnd EXEC_MEMORY_I
EXEC_MEMORY_I set 1
*
*  exec/memory.i
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


** Memory List Structures
 rsset	ln_SIZE
ml_NumEntries	rs.w 1
ml_SIZE 	rs 0
ml_ME = ml_SIZE

 rsreset
me_Reqs 	rs 0
me_Addr 	rs.l 1
me_Length	rs.l 1
me_SIZE 	rs 0

** Memory Options
MEMF_ANY	= 0
 BITDEF MEM,PUBLIC,0
 BITDEF MEM,CHIP,1
 BITDEF MEM,FAST,2
 BITDEF MEM,LOCAL,8
 BITDEF MEM,24BITDMA,9
 BITDEF MEM,CLEAR,16
 BITDEF MEM,LARGEST,17
 BITDEF MEM,REVERSE,18
 BITDEF MEM,TOTAL,19

MEM_BLOCKSIZE = 8
MEM_BLOCKMASK = MEM_BLOCKSIZE-1

** Memory Region Header
 rsset	ln_SIZE
mh_Attributes	rs.w 1
mh_First	rs.l 1
mh_Lower	rs.l 1
mh_Upper	rs.l 1
mh_Free 	rs.l 1
mh_SIZE 	rs 0

** Memory Chunk
 rsreset
mc_Next 	rs.l 1
mc_Bytes	rs.l 1
mc_SIZE 	rs 0

 endc	 ; EXEC_MEMORY_I
