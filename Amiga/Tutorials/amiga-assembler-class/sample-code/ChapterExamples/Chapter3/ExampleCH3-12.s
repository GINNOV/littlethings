* Example CH3-12.s

START    move.l NUMBER1,d0          load 1st number into register d0

         add.l  d0,NUMBER2          add contents of d0 to value in NUMBER2

         clr.l  d0
         
         rts

NUMBER1  dc.l  3                    set initial value to 3

NUMBER2  dc.l  4                    set initial value to 4  
