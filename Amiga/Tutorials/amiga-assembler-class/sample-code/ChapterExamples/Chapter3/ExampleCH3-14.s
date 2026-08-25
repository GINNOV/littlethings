* Example CH3-14.s

START    move.l   #$1FFFFF,NUMBER1    initialise number

         move.l   #1,d0               load d0 with value 1

         add.l    NUMBER1,d0          increment d0 copy of NUMBER1

         not.l    d0                  complement result

         move.l   d0,RESULT

         clr.l    d0
         
         rts


NUMBER1  ds.l     1                   space for number 

RESULT   ds.l     1                   space for result
