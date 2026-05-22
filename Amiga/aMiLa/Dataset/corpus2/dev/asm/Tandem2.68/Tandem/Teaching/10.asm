* 10.asm   Subroutine to convert a-z to A-Z    version 0.00   1.9.97

 move.b #'c',d0 ;try various things here
 bsr Upper
 rts

* if d0=a-z, convert to A-Z (and ignore non-alphabetic characters)
Upper:
 cmp.b #'a',d0      ;BRA extension .B  means "byte" - max jump 126 bytes
 bcs.s Up_done      ;BRA extension .W  means "word"  - max jump 32766 bytes
 cmp.b #'z'+1,d0    ;use .S where possible, since it's quicker & shorter
 bcc.s Up_done      ;default for forward jumps is .L, so put .S if short
 add.b #'A'-'a',d0  ; Tandem selects .B or .W automatically for backward
Up_done:            ; jumps, so omit .B or .W for backward jumps
 rts
