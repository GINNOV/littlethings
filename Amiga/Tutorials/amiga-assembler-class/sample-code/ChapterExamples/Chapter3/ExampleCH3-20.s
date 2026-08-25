* Example CH3-20.s
 
; address of source string should be in a0
      
; address of destination string should be in a1

      move.b   (a0)+,d0                   copy count and increment pointer

      sub.b    #1,d0                      reduce count by 1 for dbra
      
LOOP  move.b   (a0)+,(a1)+                copy character and increment pointers
          
      dbra     d0,LOOP                    loop until d0 is -1

      move.b   #0,(a1)                    add terminal NULL

      rts
