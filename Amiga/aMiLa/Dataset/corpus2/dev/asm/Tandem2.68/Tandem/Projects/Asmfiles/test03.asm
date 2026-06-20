* test d of d(An), &c

 rts                     ;4E75

jack: equ $1234
jill: equ $56 
fred:
 nop                     ;4E71
 nop                     ;4E71
 move.l fred(pc),d0      ;203AFFFA 
 move.l fred(pc,d2.w),d1 ;223B20F6
 move.l jack(a4),d0      ;202C1234
 move.l jill(a4,d3.w),d1 ;22343056 
 move.l anne(a4),d0      ;202C4321
 move.l rose(a4,d3.w),d1 ;22343065
 move.l bill(pc),d0      ;203A0012
 move.l bill(pc,d2.w),d1 ;223B200E  
 move.l bill(pc),d0      ;203A000A
 move.l bill(pc,d2.w),d1 ;223B2006
 nop                     ;4E71
 nop                     ;4E71
bill:
 rts                     ;4E75
anne: equ $4321
rose: equ $65    