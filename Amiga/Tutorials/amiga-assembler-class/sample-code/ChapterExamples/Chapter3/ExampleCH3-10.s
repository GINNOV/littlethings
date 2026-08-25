* Example CH3-10.s

START    move.b #$F,d0         initialise low  8 bit of d0 to F hex

         not.b  d0             invert lower 8 bits

         move.b d0,RESULT      copy inverted d0 to RESULT 

         clr.l  d0

         rts

RESULT   ds.b  1               allocate one byte but do NOT initialise 
