; TEST6.ASM by Warren A. Ring
;
; This program shows how you can convert an integer from ASCII string to
; integer form and back again.  It also shows you how to display a
; binary integer as 8 hex ASCII digits.

   section code

   include "macros.asm"

   Start               ;Perform startup
                       ; housekeeping
X1 Display <'Enter a decimal number: '>
   ReadCon #Word       ;Get a line from the console
   StrLen  #Word       ;If no characters were entered,
   BEQ     X99         ; then jump to X99
   Display <'The hexadecimal equivalent is: '>
   AtoI    #Word,Value ;Convert the string from ASCII to an integer
   ItoHA8  Value,#HexCode;Convert the integer to 8-character hex ASCII
   WritCon #HexCode    ;Display the hex ASCII string
   Crlf                ;Display a CR/LF
   Display <'Enter a hexadecimal number: '>
   ReadCon #Word       ;Get a line from the console
   StrLen  #Word       ;If no characters were entered,
   BEQ     X99         ; then jump to X99
   Display <'The decimal equivalent is: '>
   HAtoI   #Word,Value ;Convert the string from hex ASCII to integer
   ItoA    Value,#Word ;Convert the integer to an ASCII string
   WritCon #Word       ;Display the ASCII string
   Crlf                ;Display a CR/LF
   BRA     X1          ;Jump to X1

X99
   Exit                ;Perform ending housekeeping, and exit

   include "warlib.asm"

   section data

   StrBuf  Word,16
   StrBuf  HexCode,8

Value  DS.L    1

   end
