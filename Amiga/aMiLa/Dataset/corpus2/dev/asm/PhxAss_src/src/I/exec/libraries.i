 ifnd EXEC_LIBRARIES_I
EXEC_LIBRARIES_I set 1
*
*  exec/libraries.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd EXEC_NODES_I
 include "exec/nodes.i"
 endc

 ifnd EXEC_TYPES_I
 include "exec/types.i"
 endc


** Special Constants
LIB_VECTSIZE   = 6
LIB_RESERVED   = 4
LIB_BASE       = -LIB_VECTSIZE
LIB_USERDEF    = LIB_BASE-LIB_RESERVED*LIB_VECTSIZE
LIB_NONSTD     = LIB_USERDEF

** Library Definition Macros
 macro	  LIBINIT
 ifc	  "\1",""
COUNT_LIB set LIB_USERDEF
 else
COUNT_LIB set \1
 endc
 endm

 macro LIBDEF
\1 equ COUNT_LIB
COUNT_LIB set COUNT_LIB-LIB_VECTSIZE
 endm

** Standard Library Functions
 LIBINIT LIB_BASE
 LIBDEF  LIB_OPEN
 LIBDEF  LIB_CLOSE
 LIBDEF  LIB_EXPUNGE
 LIBDEF  LIB_EXTFUNC

** Standard Library Data Structure
 rsset	ln_SIZE
lib_Flags	rs.b 1
lib_pad 	rs.b 1
lib_NegSize	rs.w 1
lib_PosSize	rs.w 1
lib_Version	rs.w 1
lib_Revision	rs.w 1
lib_IdString	rs.l 1
lib_Sum 	rs.l 1
lib_OpenCnt	rs.w 1
lib_SIZE	rs 0

 BITDEF  LIB,SUMMING,0
 BITDEF  LIB,CHANGED,1
 BITDEF  LIB,SUMUSED,2
 BITDEF  LIB,DELEXP,3
 BITDEF  LIB,EXP0CNT,4

** Function Invocation Macros
 macro	 CALLLIB
 ifgt	 NARG-1
 echo	 "CALLLIB MACRO - too many arguments !"
 fail
 endc
 jsr	 \1(a6)
 endm

 macro	 LINKLIB
 ifgt	 NARG-2
 echo	 "LINKLIB MACRO - too many arguments !"
 fail
 endc
 move.l  a6,-(sp)
 move.l  \2,a6
 CALLLIB \1
 move.l  (sp)+,a6
 endm

 endc	 ; EXEC_LIBRARIES_I
