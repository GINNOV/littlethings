* Example CH3-5.s

START move.l X,Y            copy long word X to long word Y

      clr.l  d0

      rts

X     dc.l  10             allocate one long word and initialise to 10

Y     ds.l  1              allocate one long word but do NOT initialise 
