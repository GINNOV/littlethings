* Example CH3-11.s

START    move.b #$F,RESULT     store value directly in RESULT

         not.b  RESULT         invert value

         clr.l  d0
         
         rts

RESULT   ds.b  1               allocate one byte but do NOT initialise 
