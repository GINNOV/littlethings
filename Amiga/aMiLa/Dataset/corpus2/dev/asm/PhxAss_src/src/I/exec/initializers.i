 ifnd EXEC_INITIALIZERS_I
EXEC_INITIALIZERS_I set 1
*
*  exec/initializers.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*


 macro	 INITBYTE
 ifle	 (\1)-255
 dc.b	 $a0,\1
 else
 dc.b	 $e0,0
 dc.w	 \1
 endc
 dc.b	 \2,0
 endm

 macro	 INITWORD
 ifle	 (\1)-255
 dc.b	 $90,\1
 else
 dc.b	 $d0,0
 dc.w	 \1
 endc
 dc.w	 \2
 endm

 macro	 INITLONG
 ifle	 (\1)-255
 dc.b	 $80,\1
 else
 dc.b	 $c0,0
 dc.w	 \1
 endc
 dc.l	 \2
 endm

 macro	 INITSTRUCT
 even
 ifc	 "\4",""
COUNT\@  set 0
 else
COUNT\@  set \4
 endc
CMD\@	 set ((\1)<<4)|COUNT\@
 ifle	 (\2)-255
 dc.b	 CMD\@|$80,\2
 MEXIT
 endc
 dc.b	 CMD\@|$c0
 dc.b	 ((\2)>>16)&$ff
 dc.w	 (\2)&$ffff
 endm

 endc	    ; EXEC_INITIALIZERS_I
