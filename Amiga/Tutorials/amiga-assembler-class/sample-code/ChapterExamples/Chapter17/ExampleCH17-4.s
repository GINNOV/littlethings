
* ===================================================================== * 
* Final word counting routine for counting words                        *
* defined as letters a-z or A-Z delimited by ANY other characters       *
* --------------------------------------------------------------------- *

* a0    is loaded with the address of the start of the buffer
* d0    is loaded with  the total number of characters in the file
* d1    holds the current character being examined
* d2    is used as an 'characters available' flag
* d3   is used as the word count variable

* on return register d0 is set to this count value!

* requires long word buffer_p and buffer_size variables to be available

LOWERCASE_Z   equ   $7A
LOWERCASE_A   equ   $61
UPPERCASE_Z   equ   $5A
UPPERCASE_A   equ   $41

* --------------------------------------------------------------------- *

* NOTES: The NEXTCHAR routine places the NEXT character into register d1 and then 
* increments pointer and decreases character counter. This means that 
* d2 WOULD BE CLEARED BEFORE THE LAST CHARACTER WAS EXAMINED.
* I've avoided this by setting the original d0 character count to one 
* more than it really is!

WordCount              movem.l d2-d3,-(sp)            preserve registers
                        move.l  buffer_p,a0           start of buffer
                        moveq  #0,d3                  no words yet
                        move.l  buffer_size,d0        characters in file
                        sne     d2                    set if NOT zero size  
                        addq.l  #1,d0                 now file size + 1

FINDSTART:              tst.b   d2                    zero if no characters
                        beq.s   EXIT_FINDSTART

NEXTCHAR:               move.b  (a0)+,d1              new character
                        subq.l  #1,d0                 decrease characters left count
                        sne     d2                    made zero if no chars

                        cmpi.b  #LOWERCASE_Z,d1       is char a-z ?
                        bhi.s   NOTLOWERCASE
                        cmpi.b  #LOWERCASE_A,d1
                        bcs.s   NOTLOWERCASE

                        jsr     FINDEND
                        bra.s   FINDSTART

NOTLOWERCASE:           cmpi.b  #UPPERCASE_Z,d1       is char A-Z ?
                        bhi.s   FINDSTART
                        cmpi.b  #UPPERCASE_A,d1
                        bcs.s   FINDSTART

                        jsr     FINDEND
                        bra.s   FINDSTART

EXIT_FINDSTART:         move.l  d3,d0                 set up returned count  value
                        movem.l   (sp)+,d2-d3         re-instate registers
                        rts                           
* --------------------------------------------------------------------- * 

FINDEND:                tst.b   d2                    zero if no characters       
                        beq.s   EXIT_FINDEND          end of file found so quit

NEXTCHAR2:              move.b  (a0)+,d1              new character
                        subq.l  #1,d0                 decrease characters left count
                        sne     d2                    made zero if no chars

                        cmpi.b  #LOWERCASE_Z,d1       is char a-z ?
                        bhi.s   NOTLOWERCASE2
                        cmpi.b  #LOWERCASE_A,d1
                        bcs.s   NOTLOWERCASE2

                        bra.s   FINDEND

NOTLOWERCASE2:          cmpi.b  #UPPERCASE_Z,d1       is char A-Z ?
                        bhi.s   EXIT_FINDEND
                        cmpi.b  #UPPERCASE_A,d1
                        bcs.s   EXIT_FINDEND

                        bra.s   FINDEND

EXIT_FINDEND:           addq.l  #1,d3                 count word
                        rts
* --------------------------------------------------------------------- * 


