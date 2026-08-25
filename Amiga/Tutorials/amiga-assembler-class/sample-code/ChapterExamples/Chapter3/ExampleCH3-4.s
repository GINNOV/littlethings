* Example CH3-4.s

START move  X,Y            copy word X to word Y

      clr.l d0
      
      rts

X     dc.w  10             allocate word and initialise to 10

Y     ds.w  1              allocate word but do NOT initialise 

