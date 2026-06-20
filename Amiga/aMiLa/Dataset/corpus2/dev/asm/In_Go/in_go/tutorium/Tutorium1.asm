;Tutorium1
; Programm für den In_Go Reassembler
;Dieses Programm dient nur Demonstrationszwecken
;und hat keinerlei Sinn und Zweck

 moveq.l #0,D0                   ;bei versehentlichem Aufrufen
 rts                             ;Kein Guru
 Beginn:                         ;Genau hier
 movem.l   D0/A0,-(A7)           ;Hier werden Die Parms auf Stack gelegt
 lea BaseA4,A4                   ;Initiere BASREG A4
 movea.l   $4,A6                 ;ExecBase nach A6
 move.l A6,ExecBase-BaseA4(A4)   ;und abspeichern
 move.l Dummy-BaseA4(a4),A6      ;nur damit was anderes in A6 ist
 move.l ExecBase-BaseA4(A4),A6   ;Base initieren
 lea DosName-BaseA4(A4),A1       ;Namen hohlen
 moveq.l #$25,D0                 ;Die Revisionsnummer
OpenLibrary Set -$228            ;Damit wir keine Includes Benötigen
 Jsr OpenLibrary(A6)             ;und Öffnen
 tst.l D0                        ;wirklich geöffnet
 beq.b Exit1                     ;Nein ? dann Raus
 move D0,_DOSBase-BaseA4(A4)     ;Dann abspeichern
 bsr Pseudotest                  ;in den Pseudotest verzweigen
 bra.b Exit2                     ;und raus
Exit1:
 movem.l (A7)+,D0/A0             ;Stack wie zuvor
 moveq.l #$0,D0                  ;Null zurück
 rts
Exit2:
 movea.l _DOSBase-BaseA4(A4),A1  ;Lib schliesen
 Bsr SchlieseLib
 bsr dietab                      ;Ohne Sinn und Zweck
 bra.b Exit1

Pseudotest:                      ;Bereich für lokale Vars dynamisch auf dem Stack anlegen
 Link A5,#-48
 move.l D0,20(A5)                ;in Lokale Var ablegen
 move.l D1,28(A5)
 moveq.l #$25,D0                 ;Die Versionsnummer
 lea UtilityName-BaseA4(A4),A1
 move.l ExecBase-BaseA4(A4),A6
OpenLibrary SET -$228            ;Damit wir keine Includes Benötigen
 Jsr OpenLibrary(A6)             ;und Öffnen
 tst.l D0
 beq.b nichtOffen
 move.l D0,-12(A5)               ;abspeichern in PseudoVar
 move.l -20(A5),D0               ;ersten multiplikannt hohlen
 move.l -28(A5),D1               ;zweiten multiplikannt hohlen
 move.l -12(A5),A6               ;UtilityBase Hohlen
Umult32 SET -144                 ;Damit wir keine Includes Benötigen
 jsr Umult32(A6)
 move.l d0,-36(A5)               ;Alles nur Fake
  movea.l -12(A5),A1
 bsr SchlieseLib
 move.l -36(A5),D0               ;Der Rückgabewert
 bra.b subraus
nichtOffen:
 move #-1,D0                     ;False zurück
subraus:
 unlk A5
 rts
SchlieseLib:
 move.l ExecBase-BaseA4(A4),A6    ;
CloseLibrary SET -$19E            ;Damit wir keine Includes Benötigen
 jsr CloseLibrary(A6)
 rts
ta:                               ;Tabellen Base und Tabellenstart
 dc.w eins-ta                     ;Diese Tabellenart ist nicht eindeutig
 dc.w zwei-ta                     ;Und könnte beim automatischen einlesen
 dc.w drei-ta                     ;zu Fehlern führen
 dc.w vier-ta                     ;Daher nicht automatisch eingelesen von In_Go
 dc.w fünf-ta
dietab:
 move.l ta(pc,D3),D0
 jsr ta(pc,D0)
 rts
 
 ;MC68020                          ;Ab hier 68020 er Code möglich
fünf: moveq.l #$5,d2
      move.l ([IrgendneVar-BaseA4,A4]),AuchIrgendneVar-BaseA4(A4)
      rts

drei: moveq.l #$3,d2
      ;Die zwei nun folgenden 68000 er Instruktionen ergeben mit
      ;In_Go optimiert einen 68020 er Befehl
      ;Ganz schön komplex . . . nicht war ?
      movea.l IrgendneVar-BaseA4(A4),A2
      move.l  (A2),AuchIrgendneVar-BaseA4(A4)
      rts
eins: moveq.l #$1,D2
      rts
zwei: move.b #$2,D2
      ext.w d2    ; mit In_Go optimiert EXTB.L
      ext.l d2
      rts

vier: moveq.l #$4,d2
      rts

 dc.w  0
 Data
BaseA4:
 dc.l Beginn
 dc.l hT
 dc.l drei
hT:         dc.b "Hier sind irgendwelche Strings und Variablen",0
 even
DosName:  dc.b "dos.library",0
 even
UtilityName: dc.b "utility.library"
even
IrgendneVar: ds.l 1
AuchIrgendneVar:ds.l 1
Irgendwas:   ds.l 10
ExecBase: ds.l 1
_DOSBase:  ds.l 1
Dummy:    ds.l 1

 END
