* Example CH3-9.s

START move.w X,a0          copy X to lowest 16 bits of a0

      move.w a0,Y          copy lowest 16 bits of a0 to Y

      clr.l  d0

      rts

X     dc.w  $FFFF          allocate one word and initialise to FFFF hex

Y     ds.w  1              allocate one word but do NOT initialise it
