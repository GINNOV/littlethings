* ===================================================================== *
* Listing 17-1 Assembler routine for analysing an ASCII file and counting words *
* defined as letters a-z or A-Z delimited by ANY other characters       *
* --------------------------------------------------------------------- *

* a0    is loaded with the address of the start of the buffer
* d0    is loaded with the total number of characters in the file

* requires long word buffer_p, buffer_size and word_count variables to be available

LOWERCASE_Z   equ   $7A
LOWERCASE_A   equ   $61
UPPERCASE_Z   equ   $5A
UPPERCASE_A   equ   $41

* --------------------------------------------------------------------- *
* NOTE: For this example the movem instructions for preserving non-scratch
* registers are NOT needed (only a0 and d0 are used). They are included
* only as a reminder of their potential location:

WordCount              movem.l a2-a6/d2-d7,-(sp)            preserve registers
                       move.l  buffer_p,a0                  start of buffer
                       move.l  #0,word_count                no words yet
                       move.l  buffer_size,d0               characters in file

* last instruction also clears the zero flag unless file is empty!

FINDSTART:             beq     EXIT_FINDSTART
                       cmpi.b  #LOWERCASE_Z,(a0)            is char a-z ?
                       bhi     NOTLOWERCASE
                       cmpi.b  #LOWERCASE_A,(a0)
                       bcs     NOTLOWERCASE
                       addq.l  #l,a0                        move to next character
                       subq.l  #1,d0                        decrease characters left count
                       jsr     FINDEND
                       bra     FINDSTART

NOTLOWERCASE:          cmpi.b  #UPPERCASE_Z,(a0)            is char A-Z ?
                       bhi     NOTLETTER
                       cmpi.b  #UPPERCASE_A,(a0)
                       bcs     NOTLETTER
                       addq.l  #1,a0                        move to next character
                       subq.l  #l,d0                        decrease characters left count
                       jsr     FINDEND
                       bra     FINDSTART

NOTLETTER:
                       addq.l  #1,a0                        move to next character
                       subq.l  #1,d0                        decrease characters left count
                       bne     FINDSTART                    and see if that's the word start

EXIT_FINDSTART:        movem.l (sp)+,a2-a6/d2-d7            re-instate registers
                       rts
* --------------------------------------------------------------------- *
* Following routine returns with zero flag SET if buffer_size characters have now been dealt with: *

FINDEND:               beq     EXIT_FINDEND                 end of file found so quit
                       cmpi.b  #LOWERCASE_Z,(a0)            is char a-z ?
                       bhi     NOTLOWERCASE2
                       cmpi.b  #LOWERCASE_A,(a0)
                       bcs     NOTLOWERCASE2
                       addq.l  #1,a0                        move to next character
                       subq.l  #1,d0                        decrease characters left count
                       bra     FINDEND

NOTLOWERCASE2:         cmpi.b  #UPPERCASE_Z,(a0)            is char A-Z ?
                       bhi     NOTLETTER2
                       cmpi.b  #UPPERCASE_A,(a0)
                       bcs     NOTLETTER2
                       addq.l  #1,a0                        move to next character
                       subq.l  #1,d0                        decrease characters left count
                       bra     FINDEND

NOTLETTER2:            addq.l  #1,word_count                count word
                       addq.l  #1,a0                        move to next character
                       subq.l  #1,d0                        decrease characters left count
                       rts

EXIT_FINDEND:          addq.l  #1,word_count                count this word
                       move.b  #0,d0                        set zero flag
                       rts
* --------------------------------------------------------------------- *
