* Example CH3-1.s

START move.b X,d0         copy byte X to lowest 8 bits of d0

      move.b d0,Y         copy lowest 8 bits of d0 to Y

      clr.l  d0
      
      rts

X     dc.b  10            allocate one byte and initialise it to 10

Y     ds.b  1             allocate one byte but do NOT initialise it

