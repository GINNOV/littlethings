
; Test der Startup von Assembler aus

 XREF _printf                     ; Import
 XDEF _main                       ; Export

_main                             ; wird von Startup aufgerufen
  pea    txt                      ; Text auf Stack
  jsr    _printf                  ; ausgeben
  addq.l #4,sp                    ; Stackkorrektur
  rts                             ; Programmende

txt dc.b 'Hello world !',10,0     ; Formatstring für printf

  END

