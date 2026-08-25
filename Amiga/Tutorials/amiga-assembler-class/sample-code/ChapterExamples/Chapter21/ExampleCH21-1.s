* ===================================================================== * 
* Example 21-1.s  assembler patch without argument passing              *
* --------------------------------------------------------------------- *

* a0 is loaded with the starting address of the input string

         XDEF    _Convert

         XREF   _g_input_string

         XREF   _g_EOR_mask

* --------------------------------------------------------------------- *

_Convert                move.l  #_g_input_string,a0   start of string

                        move.b  _g_EOR_mask,d0        get mask value

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

FINISH                  rts                           back to C

* ===================================================================== *

