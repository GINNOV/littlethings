* 9.asm  Jump about             version 0.00    1.9.97

 move.l #20,D0 ;long move to d0, the value 20
 cmp.l #20,D0  ;long compare to d0, the value 20
 beq Aeq20     ;go if equal  (BEQ stands for "branch if equal")
Ane20:
 rts           ;else, return (NE)
Aeq20:
 rts           ;return (EQ)
