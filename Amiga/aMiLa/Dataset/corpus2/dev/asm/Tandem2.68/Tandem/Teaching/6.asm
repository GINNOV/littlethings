* 6.asm   Demonstration of pushing and popping    version 0.00   1.9.97

 move.l #$12345678,d0  ;let D0=$12345678     (A7level =1)
 move.l d0,-(a7)       ;push D0 to the stack (causes A7level=2)
 move.l #$87654321,d0  ;give D0 a new value
 move.l (a7)+,d0       ;pop the pushed value back to D0 (A7level back to 1)
 rts
