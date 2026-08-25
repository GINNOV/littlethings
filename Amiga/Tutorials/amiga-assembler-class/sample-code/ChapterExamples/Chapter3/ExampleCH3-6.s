* Example CH3-6.s

START move.l #10,X          initialze long word X to 10

      move.l X,Y            copy long word X to long word Y

      clr.l  d0
      
      rts

X     ds.l  1               allocate one long word but do NOT initialise 

Y     ds.l  1               allocate one long word but do NOT initialise 

