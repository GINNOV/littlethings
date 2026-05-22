***********************************
* Programm : Einfache Textausgabe *
* Autor    : Gerrit M. Albrecht   *
***********************************


; Konstanten.

execbase = 4


; Offsets. (besser Includes benutzen)

_LVOOpenLibrary  = -552           ; Exec
_LVOCloseLibrary = -414
_LVOOutPut       =  -60           ; Dos
_LVOWrite        =  -48


; Programm.

  lea    DOSName(PC),a1           ; String als Parameter benutzen
  moveq  #0,d0                    ; 
  move.l execbase,a6              ; Exec-Funktion
  jsr    _LVOOpenLibrary(a6)      ; OpenLibrary() - dos.library oeffnen
  tst.l  d0                       ; Returncode testen
  beq.s  Fehler                   ; Abbrechen, da keine dos.library
  move.l d0,a6
  jsr    _LVOOutPut(a6)           ; OutPut() - Handle besorgen
  move.l d0,d1                    ; steht in d0, fuer Write() nach d1
  beq.b  out                      ; auf Fehler testen
  lea    Text(PC),a0              ; Textzeiger nach d2
  move.l a0,d2
  move.l #Textende-Text,d3        ; Textlaenge nach d3
  jsr    _LVOWrite(a6)            ; Write() - alles ausgeben

out:                              ; dos.library wieder schliessen
  move.l a6,a1                    ; DosBase nach a1
  move.l execbase,a6              ; ExecBase nach a6
  jsr    _LVOCloseLibrary(a6)     ; CloseLibrary() - schliessen

Fehler:
  moveq  #0,d0                    ; Kein Returncode
  rts                             ; Programmende

DOSName:                          ; Fuer OpenLibrary()
  dc.b 'dos.library',0

Text:                             ; 12 = CLS, 10 = LF, 13 = RET
  dc.b 12,10
  dc.b "Zeile 1",10
  dc.b "Zeile 2",10
  dc.b "Zeile 3",10
  dc.b "Zeile 4",10
  dc.b "Zeile 5",10,10,13
Textende:

  END

