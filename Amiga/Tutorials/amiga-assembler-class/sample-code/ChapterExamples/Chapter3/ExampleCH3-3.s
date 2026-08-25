* Example CH3-3.s

START move.w  X,Y          copy word X to word Y

      clr.l   d0

      rts

X     dc.w  10             allocate two bytes and initialise to 10

Y     ds.w  1              allocate two bytes but do NOT initialise 
