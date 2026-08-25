* Example CH3-19.s
 
      lea      TEXT,a0                    put address of string in a0
      
      move.b   (a0)+,d0                   copy count and increment pointer

      sub.b    #1,d0                      reduce count by 1 for dbra
      
      lea      COPY,a1                    address of copy buffer in a1

LOOP  move.b   (a0)+,(a1)+                copy character and increment pointers
          
      dbra     d0,LOOP                    loop until d0 is -1

      move.b   #0,(a1)                    add terminal NULL

      clr.l    d0

      rts

TEXT  dc.b     5,"APPLE"

COPY  ds.b    6
