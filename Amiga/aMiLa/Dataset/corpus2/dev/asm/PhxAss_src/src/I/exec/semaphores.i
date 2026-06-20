 ifnd EXEC_SEMAPHORES_I
EXEC_SEMAPHORES_I set 1
*
*  exec/semaphores.i
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

 ifnd EXEC_PORTS_I
 include "exec/ports.i"
 endc

 rsset mln_SIZE
ssr_Waiter	rs.l 1
ssr_SIZE	rs.w 0

* struct Signal Semaphore
 rsset ln_SIZE
ss_NestCount	rs.w 1
ss_WaitQueue	rs.b mlh_SIZE
ss_MultipleLink rs.b ssr_SIZE
ss_Owner	rs.l 1
ss_QueueCount	rs.w 1
ss_SIZE 	rs.w 0

* struct Semaphore
 rsset mp_SIZE
sm_Bids 	rs.w 1
sm_SIZE 	rs.w 0

sm_LockMsg = mp_SigTask

 endc
