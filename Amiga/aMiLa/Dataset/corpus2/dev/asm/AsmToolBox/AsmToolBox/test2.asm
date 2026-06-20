; TEST2.ASM by Warren A. Ring
;
; This program shows how the LEFT$, MID$, and RIGHT$ routines
; work.  You enter a character string, followed by two numbers, m and n.
; On the first line, it displays the left-most m characters.  On the second
; line, it displays n characters from character m in the string.  On the
; third line, it displays the right-most m characters.

   section code

   include "macros.asm"

   Start               ;Perform startup housekeeping
X1
   Scanw   #Word1      ;Set A$, m, and n,
   Scanw   #Word2      ; to the first three words
   AtoI    #Word2,I    ; found on the command
   Scanw   #Word3      ; line, respectively
   AtoI    #Word3,J

   Display <'Left$("'> ;Display "Left$(A$,m)="
   WritCon #Word1
   Display <'",'>
   WritCon #Word2
   Display <')="'>
   Left    #Word1,I,#Word4;Calculate B$, and
   WritCon #Word4      ; display it
   Display <'"'>
   Crlf

   Display <'Mid$("'>  ;Display "Mid$(A$,m,n)="
   WritCon #Word1
   Display <'",'>
   WritCon #Word2
   Display <','>
   WritCon #Word3
   Display <')="'>
   Mid     #Word1,I,J,#Word4;Calculate B$,
   WritCon #Word4      ; and display it
   Display <'"'>
   Crlf

   Display <'Right$("'>;Display "Right$(A$,m)="
   WritCon #Word1
   Display <'",'>
   WritCon #Word2
   Display <')="'>
   Right   #Word1,I,#Word4;Calculate B$,
   WritCon #Word4      ; and display it
   Display <'"'>
   Crlf

   Exit                ;Perform ending house keeping, and exit

   include "warlib.asm"

   section data

   StrBuf  Buffer,80
   StrBuf  Word1,16
   StrBuf  Word2,16
   StrBuf  Word3,16
   StrBuf  Word4,16

I      DS.L    1
J      DS.L    1

   end
