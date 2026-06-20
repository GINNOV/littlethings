* 11.asm   Demonstate a DBRA loop       version 0.00    1.9.97

 move.l #0,d0
 move.w #9,d1 ;D1 is the control variable: see line 0006. Loops D1-1 times
Loop:
 add.l #10,d0
 dbra d1,Loop ;decrement D1, go to loop if D1<>$FFFF
 rts          ;if D1=$FFFF, falls through to this line
