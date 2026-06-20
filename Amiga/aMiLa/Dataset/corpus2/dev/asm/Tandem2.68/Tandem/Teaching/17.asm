* 17.asm   macro's with parameters      version 0.00   1.9.97

* let \3 = \1 * \2
multi: macro
 move.l d0,-(a7)
 move.l \1,d0
 mulu \2,d0
 move.l d0,\3
 move.l (a7)+,d0
 endm

* do some multiplications
Program:
 moveq #16,d0
 multi d0,#16,d1
 multi d1,#16,d2
 multi d2,#16,d3
 multi d3,#16,d4
 rts
