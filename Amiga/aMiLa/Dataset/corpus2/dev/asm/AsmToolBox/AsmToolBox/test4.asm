; TEST4.ASM by Warren A. Ring
;
; This program shows an example of how words can be extracted from a
; phrase.  This program allows you to enter a phrase, then it displays
; the individual words from that phrase.  Note that this example, which
; uses the "Scana" routine, treats all non-alpha-numeric characters as
; delimiters.  Thus, it skips over commas, semicolons, and other special
; characters just as if they were spaces.

   section code

   include "macros.asm"

   Start               ;Perform startup
                       ; housekeeping
X1 Display <'Enter a phrase: '>
   ReadCon #Buffer     ;Get a line from the console
   StrLen  #Buffer     ;If no characters were entered,
   BEQ     X99         ; then jump to X99
   SetScan #Buffer     ;Set to scan the console line
   Display <'Words are:',LF>
X2 Scana   #Word1      ;Scan the console line for a word
   StrLen  #Word1      ;If no word was available,
   BEQ     X1          ; then jump to X1
   WritCon #Word1      ;Display the word
   Crlf                ;Display a CR/LF
   BRA     X2          ;Jump to X2

X99
   Exit                ;Perform ending housekeeping, and exit

   include "warlib.asm"

   section data

   StrBuf  Buffer,16
   StrBuf  Word1,16

   end
