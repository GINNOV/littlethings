 ifnd EXEC_NODES_I
EXEC_NODES_I set 1
*
*  exec/nodes.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 rsreset
ln_Succ 	rs.l 1
ln_Pred 	rs.l 1
ln_Type 	rs.b 1
ln_Pri		rs.b 1
ln_Name 	rs.l 1
ln_SIZE 	rs 0

 rsreset
mln_Succ	rs.l 1
mln_Pred	rs.l 1
mln_SIZE	rs 0

** Node Types
NT_UNKNOWN	= 0
NT_TASK 	= 1
NT_INTERRUPT	= 2
NT_DEVICE	= 3
NT_MSGPORT	= 4
NT_MESSAGE	= 5
NT_FREEMSG	= 6
NT_REPLYMSG	= 7
NT_RESOURCE	= 8
NT_LIBRARY	= 9
NT_MEMORY	= 10
NT_SOFTINT	= 11
NT_FONT 	= 12
NT_PROCESS	= 13
NT_SEMAPHORE	= 14
NT_SIGNALSEM	= 15
NT_BOOTNODE	= 16
NT_KICKMEM	= 17
NT_GRAPHICS	= 18
NT_DEATHMESSAGE = 19
NT_USER 	= 254
NT_EXTENDED	= 255

 endc	 ; EXEC_NODES_I
