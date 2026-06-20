 ifnd EXEC_LISTS_I
EXEC_LISTS_I set 1
*
*  exec/lists.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd EXEC_NODES_I
 include "exec/nodes.i"
 endc


** List Structures
 rsreset
lh_Head 	rs.l 1
lh_Tail 	rs.l 1
lh_TailPred	rs.l 1
lh_Type 	rs.b 1
lh_pad		rs.b 1
lh_SIZE 	rs 0

 rsreset
mlh_Head	rs.l 1
mlh_Tail	rs.l 1
mlh_TailPred	rs.l 1
mlh_SIZE	rs 0

 macro	 NEWLIST
 move.l  \1,(\1)
 addq.l  #lh_Tail,(\1)
 clr.l	 lh_Tail(\1)
 move.l  \1,lh_Tail+ln_Pred(\1)
 endm

 macro	 TSTLIST
 ifc	 "\1",""
 cmp.l	 lh_Tail+ln_Pred(a0),a0
 else
 cmp.l	 lh_Tail+ln_Pred(\1),\1
 endc
 endm

 macro	 SUCC
 move.l  (\1),\2
 endm

 macro	 PRED
 move.l  ln_Pred(\1),\2
 endm

 macro	 IFEMPTY
 cmp.l	 lh_Tail+ln_Pred(\1),\1
 beq	 \2
 endm

 macro	 IFNOTEMPTY
 cmp.l	 lh_Tail+ln_Pred(\1),\1
 bne	 \2
 endm

 macro	 TSTNODE
 move.l  (\1),\2
 tst.l	 (\2)
 endm

 macro	 NEXTNODE
 move.l  \1,\2
 move.l  (\2),\1
 ifc	 "\0",""
 beq	 \3
 else
 beq.s	 \3
 endc
 endm

 macro	 ADDHEAD
 move.l  (a0),d0
 move.l  a1,(a0)
 movem.l d0/a0,(a1)
 move.l  d0,a0
 move.l  a1,ln_Pred(a0)
 endm

 macro	 ADDTAIL
 addq.l  #lh_Tail,a0
 move.l  ln_Pred(a0),d0
 move.l  a1,ln_Pred(a0)
 move.l  a0,(a1)
 move.l  d0,ln_Pred(a1)
 move.l  d0,a0
 move.l  a1,(a0)
 endm

 macro	 REMOVE
 move.l  (a1),a0
 move.l  ln_Pred(a1),a1
 move.l  a0,(a1)
 move.l  a1,ln_Pred(a0)
 endm

 macro	 REMHEAD
 move.l  (a0),a1
 move.l  (a1),d0
 beq.s	 REMHEAD\@
 move.l  d0,(a0)
 exg	 d0,a1
 move.l  a0,ln_Pred(a1)
REMHEAD\@:
 endm

 macro	 REMHEADQ
 move.l  (\1),\2
 move.l  (\2),\3
 move.l  \3,(\1)
 move.l  \1,ln_Pred(\3)
 endm

 macro	 REMTAIL
 move.l  lh_Tail+ln_Pred(a0),a1
 move.l  ln_Pred(a1),d0
 beq.s	 REMTAIL\@
 move.l  d0,lh_Tail+ln_Pred(a0)
 exg	 d0,a1
 move.l  a0,(a1)
 addq.l  #4,(a1)
REMTAIL\@:
 endm

 endc	 ; EXEC_LISTS_I
