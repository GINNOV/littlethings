* 8.asm   Program branching        version 0.00   1.9.97

 move.l #0,d0
 bra fred      ;BRA stands for "branch" (like GOTO in AmigaBASIC)
bill:
 rts
fred:
 bra bill
