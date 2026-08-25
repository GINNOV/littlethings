* Example CH3-16.s

START    move.l   #$1FFFFF,RESULT    initialise number

         add.l   #1,RESULT           increment value

         not.l    RESULT             complement result

         clr.l    d0

         rts

RESULT   ds.l     1                   space for result

