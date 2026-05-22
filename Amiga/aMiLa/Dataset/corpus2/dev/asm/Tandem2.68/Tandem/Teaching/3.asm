* 3.asm    demonstrate the MOVE opcode     version 0.00   1.9.97

 MOVE.L #$22222222,D0
 MOVE.W #$3333,D0
 MOVE.B #$AA,D0
 MOVE.L D0,D1
 MOVE.L #4,A0
 MOVE.L 4,A0
 RTS
