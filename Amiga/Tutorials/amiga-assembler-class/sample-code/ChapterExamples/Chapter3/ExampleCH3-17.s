* Example CH3-17.s
 
      lea      TEXT,a0                    put address of string in a0
      
      move.b   (a0),d0                    copy count to register d0

      addq.l   #1,a0                      skip to first real character
      
      lea      COPY,a1                    address of copy buffer in a1

LOOP  move.b   (a0),(a1)                  copy character
          
      addq.l     #1,a0                    move to next source character

      addq.l     #1,a1                    move to next destination byte
     
      subq.b   #1,d0                      decrease character counter

      bne      LOOP                       loop until d0 is zero

      move.b   #0,(a1)                    add terminal NULL

      clr.l    d0

      rts

TEXT  dc.b     5,"APPLE"

COPY  ds.b     6
