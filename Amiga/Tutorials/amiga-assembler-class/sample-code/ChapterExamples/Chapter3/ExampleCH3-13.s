* Example CH3-13.s

START    move.b NUMBER1,d0          load 1st number into register d0

         add.b  d0,NUMBER2          add contents of d0 to value in NUMBER2

         clr.l  d0
         
         rts

NUMBER1  dc.b  3                    set initial value to 3

NUMBER2  dc.b  4                    set initial value to 4  
