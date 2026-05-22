* immediate mode addressing

 rts                  ;4E75
fred:
 nop                  ;4E71
 move.l #fred,d0      ;203C00000002
 move.l #bill,d0      ;203C0000001E
 move.l #$12345678,d0 ;203C12345678
 move.w #$1234,d0     ;303C1234
 move.b #$12,d0       ;103C0012
bill:
 rol.l #1,d1          ;E399
 rol.l #8,d1          ;E199
