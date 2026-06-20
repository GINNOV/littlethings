* 18.asm    conditional assembly    version 0.00   1.9.97

* do add or sub
arith: macro
 move.l d0,-(a7)
 move.l #\1,d0
 ifc '\2','+'
 add.l #\3,d0
 endc
 ifc '\2','-'
 sub.l #\3,d0
 endc
 move.l d0,\4
 move.l (a7)+,d0
 endm

* do some math
 arith 10,+,10,d1
 arith 10,-,10,d2
 arith 20,+,10,d3
 arith 20,-,10,d4
 rts
