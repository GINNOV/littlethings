* Example CH3-2.s

START move.b X,Y            copy byte X to byte Y

      clr.l  d0
      
      rts

X     dc.b  10             allocate one byte and initialise it to 10

Y     ds.b  1              allocate one byte but do NOT initialise it
