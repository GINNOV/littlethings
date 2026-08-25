* Example CH3-8.s

START move.w X,a0          copy X to lowest 16 bits of a0

      move.w a0,Y          copy lowest 16 bits of a0 to Y

      clr.l  d0

      rts

X     dc.w  10             allocate one word and initialise it to 10

Y     ds.w  1              allocate one word but do NOT initialise it
