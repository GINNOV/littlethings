; TEST1.ASM by Warren A. Ring
;
; This program picks up the first six
; english words on the CLI line following "TEST",
; and, for each word, displays that word, converts
; that word, if possible, to a 4-byte signed
; integer, adds that integer to a total, converts
; that integer back to an ASCII string, and
; displays that string.  A concatenation of the
; six words is displayed on the next line, and the
; total is displayed on the next line.

   section code

   include "libs:types.i"
   include "libs:dos.i"
   include "macros.asm"

   Start               ;Perform startup housekeeping
   MOVE.L  #5,D2       ;Set the counter to 5
X1
   Scanw   #Word       ;Display the first (next) english word from
   Display '='         ; the CLI residue, surrounded by "="
   WritCon #Word
   Display '='
   Space               ;Display " "
   AtoI    #Word,Value ;Convert the word to an integer, and back to a
   ItoA    Value,#Word ; string
   WritCon #Word       ;Display the resulting string
   StrCat  #Word,#Buffer;Concatenate the word onto the final string
   Crlf                ;Display a CR

   MOVE.L  Value,D0    ;Add the integer value to
   ADD.L   D0,Total    ; the total
   DBRA    D2,X1       ;Decrement the counter
                       ;If the counter is not yet negative, then jump to X1
   WritCon #Buffer     ;Display the final string
   Crlf                ;Display a CR
   Display <'The total is: '>
   ItoA    Total,#Buffer;Convert the total integer
   WritCon #Buffer     ; to a string, and display it

   Crlf                ;Display a CR
   Exit                ;Perform ending housekeeping, and exit

   include "warlib.asm"

   section data

   StrBuf  Buffer,80
   StrBuf  Word,16

Value  DS.L    1
Total  DC.L    0

   end

