 ifnd EXEC_ABLES_I
EXEC_ABLES_I set 1
*
*  exec/ables.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd EXEC_TYPES_I
 include "exec/types.i"
 endc
 ifnd EXEC_EXECBASE_I
 include "exec/execbase.i"
 endc


INT_ABLES macro
 xref _intena
 endm

DISABLE macro
 ifc	 "\1",""
 move.w  #$4000,_intena
 addq.b  #1,IDNestCnt(a6)
 else
 move.l  4.w,\1
 move.w  #$4000,_intena
 addq.b  #1,IDNestCnt(\1)
 endc
 endm

ENABLE macro
 ifc	 "\1",""
 subq.b  #1,IDNestCnt(a6)
 bge.s	 ENABLE\@
 move.w  #$c000,_intena
ENABLE\@:
 else
 move.l  4.w,\1
 subq.b  #1,IDNestCnt(\1)
 bge.s	 ENABLE\@
 move.w  #$c000,_intena
ENABLE\@:
 endc
 endm

TASK_ABLES macro
 xref _LVOPermit
 endm

FORBID macro
 ifc	 "\1",""
 addq.b  #1,TDNestCnt(a6)
 else
 move.l  4.w,\1
 addq.b  #1,TDNestCnt(\1)
 endc
 endm

PERMIT macro
 ifc	 "\1",""
 jsr	 _LVOPermit(a6)
 else
 move.l  a6,-(sp)
 move.l  4.w,a6
 jsr	 _LVOPermit(a6)
 move.l  (sp)+,a6
 endc
 endm

 endc
