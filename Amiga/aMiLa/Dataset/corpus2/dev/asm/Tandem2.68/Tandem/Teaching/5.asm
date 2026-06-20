* 5.asm    Pseudo op example         version 0.00   1.9.97

 move.l fred,d0
 move.l d0,bill ;initialise bill
 move.l bill,d1
 rts

fred: dc.l 4
bill: ds.l 1
