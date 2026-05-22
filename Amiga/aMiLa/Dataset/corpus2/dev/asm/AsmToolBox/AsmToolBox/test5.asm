; TEST5.ASM by Warren A. Ring
;
; This program shows examples of character conversion from ASCII to hex
; ASCII.  It allows you to enter a phrase, then it displays the individual
; ASCII characters and their hexadecimal equivalents for each character
; you entered.

   section code

   include "macros.asm"

   Start               ;Perform startup
                       ; housekeeping
X1 Display <'Enter a phrase: '>
   ReadCon #Word       ;Get a line from the console
   StrLen  #Word       ;If no characters were entered,
   BEQ     X99         ; then jump to X99
   SetScan #Word       ;Set to scan the console line
   Display <'Characters are:',LF>
X2 Scanc   #Char       ;Scan the console line for the next character
   StrLen  #Char       ;If no character is available,
   BEQ     X1          ; then jump to X1
   WritCon #Char       ;Display the character
   Space               ;Display a space
   ItoHA2  Char+8,#HexCode;Convert the character from ASCII to hex ASCII
   WritCon #HexCode    ;Display the hex ASCII code
   Crlf                ;Display a CR/LF
   BRA     X2          ;Jump to X2

X99
   Exit                ;Perform ending housekeeping, and exit

   include "warlib.asm"

   section data

   StrBuf  Word,16
   StrBuf  Char,1
   StrBuf  HexCode,2

   end
