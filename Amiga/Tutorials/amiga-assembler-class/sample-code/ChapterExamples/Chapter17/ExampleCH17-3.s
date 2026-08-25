* ===================================================================== *
* Listing 17.3 further modifications to the routine for counting words  *
* defined as letters a-z or A-Z delimited by ANY other characters       *
* --------------------------------------------------------------------- *

* a0    is loaded with the address of the start of the buffer
* d0    is loaded with the total number of characters in the file
* d1    holds the current character being examined
* d2    is used as an 'characters available' flag

* requires long word buffer_p, buffer_size and word_count variables to be available

LOWERCASE_Z   equ   $7A
LOWERCASE_A   equ   $61
UPPERCASE_Z   equ   $5A
UPPERCASE_A   equ   $41

* NOTES: For this example the movem instructions for preserving non-scratch
* registers would only be needed for d2 (since only a0, d0, d1 and d2 are
* used). The non-scratch set are included only as a reminder.
* The NEXTCHAR routine places the NEXT character into register d1 and then
* increments pointer and decreases character counter. This means that
* characters_flag WOULD BE CLEARED BEFORE THE LAST CHARACTER WAS EXAMINED.
* I've avoided this by setting the original d0 character count to one
* more than it really is!

WordCount              movem.l a2-a6/d2-d7,-(sp)            preserve registers
                       move.l  buffer_p,a0                  start of buffer
                       move.l  #0,word_count                no words yet
                       move.l  buffer_size,d0               characters in file
                       sne     d2                           set if NOT zero size
                       addq.l  #1,d0                        now file size + 1

FINDSTART:             tst.b   d2                           zero if no characters
                       beq     EXIT_FINDSTART

NEXTCHAR:              move.b  (a0)+,d1                     new character
                       subq.l  #1,d0                        decrease characters left count
                       sne     d2                           made zero if no chars
                       cmpi.b  #LOWERCASE_Z,(d1)            is char a-z ?
                       bhi     NOTLOWERCASE
                       cmpi.b  #LOWERCASE_A,(d1)
                       bcs     NOTLOWERCASE
                       jsr     FINDEND
                       bra     FINDSTART

NOTLOWERCASE:          cmpi.b  #UPPERCASE_Z,(d1)            is char A-Z ?
                       bhi     FINDSTART
                       cmpi.b  #UPPERCASE_A,d1
                       bcs     FINDSTART
                       jsr     FINDEND
                       bra     FINDSTART

EXIT_FINDSTART:        movem.l (sp)+,a2-a6/d2-d7            re-instate registers
                       rts

FINDEND:               txt.b   d2                           zero if no characters
                       beq     EXIT_FINDEND                 end of file found so quit

NEXTCHAR2:             move.b  (a0)+,d1                     new character
                       subq.l  #1,d0                        decrease characters left count
                       sne     d2                           made zero if no chars
                       cmpi.b  #LOWERCASE_Z,d1              is char a-z ?
                       bhi     NOTLOWERCASE2
                       cmpi.b  #LOWERCASE_A,d1
                       bcs     NOTLOWERCASE2
                       bra     FINDEND

NOTLOWERCASE2:         cmpi.b  #UPPERCASE_Z,d1              is char A-Z ?
                       bhi     EXIT_FINDEND
                       cmpi.b  #UPPERCASE_A,d1
                       bcs     EXIT_FINDEND
                       bra     FINDEND

EXIT_FINDEND:          addq.l  #1,word_count                count word
                       rts
* --------------------------------------------------------------------- *
