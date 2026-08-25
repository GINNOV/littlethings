* Example CH3-18.s
 
      lea      TEXT,a0                    put address of string in a0
      
      move.b   (a0)+,d0                   copy count and increment pointer
      
      lea      COPY,a1                    address of copy buffer in a1

LOOP  move.b   (a0)+,(a1)+                copy character and increment pointers
          
      subq.b   #1,d0                      decrease character counter

      bne      LOOP                       loop until d0 is zero

      move.b   #0,(a1)                    add terminal NULL

      clr.l    d0

      rts

TEXT  dc.b     5,"APPLE"

COPY  ds.b     6
