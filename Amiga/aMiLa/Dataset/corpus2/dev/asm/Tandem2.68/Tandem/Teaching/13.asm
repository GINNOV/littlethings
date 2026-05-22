* 13.asm   Shift and rotate        version 0.00    1.9.97

 move.l #$44442222,d0  ;LSR shifts right, zero fills
 lsr.l #1,d0           ;(each shift=unsigned halve, CS if 1 falls out)
 move.l #$44442222,d0  ;LSL shifts left, zero fills
 lsl.l #1,d0           ;(each shift=unsigned double, CS if 1 falls out)
 move.l #$FFFF4444,d0  ;ASR shifts right, fills w. leftmost digit
 asr.l #8,d0           ;(each shift=signed halve, CS if 1 falls out)
 move.l #$FFFF4444,d0  ;ASL same as LSL
 asl.l #8,d0           ;(each shift=signed halve, CS if 1 falls out)
 move.l #$12345678,d0  ;ROL shifts all to left, bit that falls out
 rol.l #4,d0           ;pushed into other and and also to C flag
 ror.l #4,d0           ;(ROL #4 rotates digits, since each digit=4 bits)
 rts
