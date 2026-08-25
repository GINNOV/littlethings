* ===================================================================== * 
* Example 21-2.s   assembler patch with argument passing                *
* --------------------------------------------------------------------- *
         XDEF    _Convert
* --------------------------------------------------------------------- *

_Convert                link a5,#0                    don't need any workspace

                        movem.l d2-d7,-(sp)           normally where we save

                        move.l  12(a5),d0             retrieve mask value

                        move.l  8(a5),a0              retrieve string pointer

                        subq.l  #1,a0

* --------------------------------------------------------------------- *

CONVERT_LOOP:           addq.l  #1,a0                 move to next byte

                        tst.b   (a0)                  check it                        

                        beq     FINISH                quit if NULL terminator                         

                        cmp.b   (a0),d0               will it EOR to NULL ?

                        beq     CONVERT_LOOP          if YES don't EOR it

                        eor.b   d0,(a0)               safe to convert

                        bra     CONVERT_LOOP          keep going

* --------------------------------------------------------------------- * 

FINISH                  movem.l (sp)+,d2-d7          normally where we restore

                        unlk    a5

                        rts                           back to C

* ===================================================================== *

