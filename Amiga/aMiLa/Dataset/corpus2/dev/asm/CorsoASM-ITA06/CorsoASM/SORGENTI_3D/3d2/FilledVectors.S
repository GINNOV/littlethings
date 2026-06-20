wblt: MACRO			; "wblt" als Macro definieren

\@ btst #6,$dff002		; \@ = Label, das bei jedem Macro-Aufruf einen
   bne.s \@			; anderen Namen trägt

 ENDM

Start:
 move.w #$4000,$dff09a		; Interrupts sperren
 bsr.s init			; Initialisierung
 bsr DoVector			; HauptRoutine
 wblt
 move.l 4.w,a6			; System wieder herholen
 lea gfxname(pc),a1
 jsr -408(a6)
 move.l d0,a1
 move.l 38(a1),$dff080
 move.w d0,$dff088
 jsr -414(a6)
 move.l screen(pc),a1
 move.l #$12000,d0
 jsr -210(a6)
 move.l oldvbi(pc),$6c.w
 move.w intena(pc),d0
 or.w #$8000,d0
 move.w #$7fff,$dff096
 move.w #$83f0,$dff096
 move.w #$7fff,$dff09c
 move.w d0,$dff09a
 moveq #0,d0
 rts

init:				; INITIALISIERUNG
 move.l 4.w,a6
 move.l #$12000,d0
 move.l #$30002,d1
 jsr -198(a6)			; ChipRAM
 move.l d0,screen		; er reicht doch?
 lea $dff000,a6			; Register-Init
 move.w #$7fff,$96(a6)
 move.l #0,$144(a6)
 move.l #copperlist,$80(a6)
 move.w d0,$88(a6)
 move.l #$2c812cc1,$8e(a6)
 move.l #$3800d0,$92(a6)
 move.l #0,$102(a6)
 move.w #0,$1fc(a6)
 move.l #0,$108(a6)
 move.w #$3200,$100(a6)
 move.l d0,a0			; Bildschirm-Seiten
 move.l a0,a1
 add.l #$12000,a1
 move.l d0,pgh
 add.l #$8000,d0
 move.l d0,pgs
 add.l #$8000,d0
 move.l d0,tmpadr
 moveq #0,d0
clrlp:
 move.l d0,(a0)+
 cmp.l a1,a0
 blt.s clrlp
 move.l #rottab+2,rotptr
 move.w rottab(pc),rotcnt
 bsr dorot			; bei Verwendung eigener Objekte entfernen!
 move.l $6c.w,oldvbi		; Interrupt-Init
 move.l #vbiserver,$6c.w
 move.w $1c(a6),intena
 move.w #$7fff,$9a(a6)
 move.w #$c020,$9a(a6)		; Nur VBI erlauben
 move.w #$87c0,$96(a6)
 rts

vbiserver:			; INTERRUPT
 movem.l d0-d7/a0-a6,-(a7)
 lea $dff000,a6
 bsr joy			; Joystick-Abfrage
 bsr rotob			; Mutation des Rotations-Körpers (bei Ver-
                                ; wendung eigener Objekte entfernen!)
 move.w #1,vbi
 move.w #$20,$9c(a6)
 movem.l (a7)+,d0-d7/a0-a6
 rte

joy:				; JOYSTICK
 move.w $dff00c,d0
 btst #1,d0
 bne.s right
 btst #9,d0
 bne.s left
testud:
 move.w d0,d1
 lsr.w d1
 eor.w d1,d0
 btst #0,d0
 bne.s bckw
 btst #8,d0
 bne.w forw
 rts
right:				; rechts
 btst #7,$bfe001		; rechts + Feuer ?
 bne.s nfr
 addq.w #6,rzb			; Feuer -> z-rot + 3°
 cmp.w #720,rzb
 blt.s ok1
 move.w #0,rzb
ok1:
 bra.s testud
nfr:				; kein Feuer -> y-rot + 3°
 addq.w #6,ryb
 cmp.w #720,ryb
 blt.s ok
 move.w #0,ryb
ok:
 bra.s testud
left:				; links
 btst #7,$bfe001		; links + Feuer ?
 bne.s nfrl
 subq.w #6,rzb			; Feuer -> z-rot - 3°
 bge.s ok11
 add.w #720,rzb
ok11:
 bra.s testud
nfrl:
 subq.w #6,ryb			; kein Feuer -> y-rot - 3°
 bne.s ok21
 add.w #720,ryb
ok21:
 bra testud
bckw:				; zurück
 btst #7,$bfe001		; zurück + Feuer
 bne.s nfr2
 cmp.l #-5000,addzb		; Feuer -> 1000 Punkte näher ran
 bge.s ok22
 add.l #1000,addzb
ok22:
 rts
nfr2:				; kein Feuer -> x-rot - 3°
 subq.w #6,rxb
 bge.s ok23
 add.w #720,rxb
ok23:
 rts
forw:				; vorwärts
 btst #7,$bfe001		; vorwärts + Feuer
 bne.s nfr3
 cmp.l #-250000,addzb		; Feuer -> 1000 Punkte weiter weg
 ble.s ok24
 sub.l #1000,addzb
ok24:
 rts
nfr3:				; kein Feuer -> x-rot + 3°
 addq.w #6,rxb
 cmp.w #720,rxb
 blt.s ok25
 move.w #0,rxb
ok25:
 rts

DoVector:			; HAUPT-ROUTINE
 movem.l d2-d7/a2-a6,-(a7)
vcloop:				; warten auf VBI
 tst.w vbi
 beq.s vcloop
 move.w #-1,drawnum
 bsr clrscreen			; Bildlöschen starten
 bsr vector			; Berechnung und Zeichnung
 move.w #0,vbi
 btst #6,$bfe001		; Left Mouse Button ?
 bne.s vcloop
 movem.l (a7)+,d2-d7/a2-a6
 rts

clrscreen:			; BILDLÖSCHEN
 movem.l pgh,d0-d1		; Page Flipping
 move.l d0,pgs			; für Double Buffering
 move.l d1,pgh
 lea page,a0			; neue Seiten in CopperList
 move.w d0,6(a0)
 swap d0
 move.w d0,2(a0)
 swap d0
 add.l #148*40,d0
 move.w d0,14(a0)
 swap d0
 move.w d0,10(a0)
 swap d0
 add.l #148*40,d0
 move.w d0,22(a0)
 swap d0
 move.w d0,18(a0)
 movem.l addxb(pc),d0-d4	; gebufferte Joystickbewegungen
 movem.l d0-d4,addx		; für gültig erklären.
 move.w #$4000,$9a(a6)		; Int's sperren (falls Blitter auch im VBI
 wblt				; gebraucht würde)
 moveq #-1,d0
 move.l d0,$44(a6)
 move.w #0,$66(a6)
 move.l #$1000000,$40(a6)
 move.l pgh(pc),$54(a6)
 move.w #148*3*64+(40/2),$58(a6); Starten des Löschens
 move.w #$c000,$9a(a6)
 rts

quicksort:			; QUICKSORT-Algorithmus
 moveq #0,d4
 move.l #ztab,d5
 lea lrtab(pc),a0
 lea dttab(pc),a1
 move.l d5,0(a0,d4.w)
 move.l zend(pc),a5
 move.l a5,4(a0,d4.w)
l20:
 move.l 0(a0,d4.w),d5
 move.l 4(a0,d4.w),a5
 subq.w #8,d4
l30:
 move.l d5,a2
 move.l a5,a3
 move.l a2,d1
 sub.l #ztab,d1
 move.w d1,d3
 add.w d1,d1
 add.w d3,d1
 asr.w #1,d3
 add.w d3,d1
 move.l a3,d2
 sub.l #ztab,d2
 move.w d2,d3
 add.w d2,d2
 add.w d3,d2
 asr.w #1,d3
 add.w d3,d2
 move.l d5,d0
 add.l a5,d0
 asr.l #3,d0
 asl.l #2,d0
 move.l d0,a6
 move.l (a6),d3
l40:
 cmp.l (a2),d3
 ble.s l41
 addq.l #4,a2
 add.w #14,d1
 bra.s l40
l41:
 cmp.l (a3),d3
 bge.s l42
 subq.l #4,a3
 sub.w #14,d2
 bra.s l41
l42:
 cmp.l a3,a2
 bgt.s l50
 move.l (a3),d0
 move.l (a2),(a3)
 move.l d0,(a2)
 exg.l d0,d5
 movem.l 0(a1,d1.w),d5-d7
 move.l 0(a1,d2.w),0(a1,d1.w)
 move.l 4(a1,d2.w),4(a1,d1.w)
 move.l 8(a1,d2.w),8(a1,d1.w)
 movem.l d5-d7,0(a1,d2.w)
 move.w 12(a1,d1.w),d5
 move.w 12(a1,d2.w),12(a1,d1.w)
 move.w d5,12(a1,d2.w)
 exg.l d0,d5
 addq.l #4,a2
 subq.l #4,a3
 add.w #14,d1
 sub.w #14,d2
 cmp.l a3,a2
 ble.s l40
l50:
 cmp.l a5,a2
 blt.s l52
l51:
 move.l a3,a5
 cmp.l a5,d5
 blt l30
 tst.w d4
 bge l20
 rts
l52:
 addq.w #8,d4
 move.l a2,0(a0,d4.w)
 move.l a5,4(a0,d4.w)
 bra.s l51

vector:				; hier erfolgt die Hauptarbeit
 bsr transform			; Rotation + 3D-Projektion
 bsr backs			; Flächenrücken-Überprüfung
 tst.w drawnum			; keine Fläche zu sehen?
 blt end			; dann Ende
 bsr quicksort			; schneller Sortieralgorithmus
 lea dttab(pc),a5		; Tabelle mit Zeigern auf die sortierten,
 lea $dff000,a6			; verbleibenden Flächen
 lea hix(pc),a1
 move.w drawnum(pc),d7
lp:
 move.l (a5)+,a3		; Flächen-Info-Adresse
 move.l 6(a5),a2
 move.w (a3)+,d5		; Eckenzahl holen
 lea 10(a5),a5			; Zeiger auf nächste Fläche erhöhen
 subq.w #1,d5
 move.w (a3)+,-(a7)		; Farbe auf Stack
 moveq #-1,d0
 move.w #640,2(a1)		; Ausmaße für Füll- und Kopier-Fenster reseten
 move.w d0,(a1)
 move.w #640,6(a1)
 move.w d0,4(a1)
 move.w #0,line
 lea scx1(pc),a4		; Eintrag in Rechte-Rand-Clip löschen
 move.l d0,(a4)
 move.l d0,4(a4)
linelp:
 move.w (a3)+,d6		; Eckpunktnummer aus Flächen-Info holen
                                ; (Startpunkt)
 movem.w 0(a2,d6.w),d0-d1	; entsprechende 2D-Koordinaten aus ttab holen
 move.w (a3),d6
 movem.w 0(a2,d6.w),d2-d3	; Endpunkt holen
 asr.w #4,d0			; wieder durch 16 dividieren
 asr.w #4,d1
 asr.w #4,d2
 asr.w #4,d3
 bsr drawl			; Clippen + Linie zeichnen
 dbf d5,linelp			; alle Linien einer Fläche?
 tst.w scx1			; wurde Eintrag in
 blt.s noclip			; Rechte-Rand-Clip gemacht?
 tst.w scx2			; ja -> Clip-Linie zeichnen
 blt.s noclip
 lea scx1(pc),a4
 movem.w (a4),d0-d3
 bsr.s drawl			; Clip-Linie zeichnen
noclip:				; kein Rechte-Rand-Clip
 tst.w line			; gar keine Linie gezeichnet?
 beq.s nodraw
 bsr calcwindow			; erhaltene Fill-/Copy-Fenster Maße umrechnen
 move.w (a7)+,d4		; Farbe holen
 bsr copy
 dbf d7,lp			; alle Flächen?
end:
 rts
nodraw:
 move.w (a7)+,d4		; Farbe holen
 dbf d7,lp			; alle Flächen
 rts
 
drawl:				; LINIE clippen + zeichnen
 movem.l d4-d7/a5-a6,-(a7)
 cmp.w d1,d3			; weiter unten liegendes Koordinaten-Paar
 				; nach d2-d3
 bge.s ec
 exg.l d0,d2
 exg.l d1,d3
ec:
 cmp.w 6(a1),d1			; neues lo-y?
 bge.s lyk
 move.w d1,6(a1)
lyk:
 cmp.w 4(a1),d3			; neues hi-y?
 ble.s hyk
 move.w d3,4(a1)
hyk:
 move.w d0,d4			; höheres x nach d5
 move.w d2,d5			; niederes x nach d4
 cmp.w d4,d5
 bge.s ok13
 exg.l d4,d5			; d4/d6 ggf. austauschen
ok13:
 cmp.w 2(a1),d4			; neues lo-x?
 bge.s lxk
 move.w d4,2(a1)
lxk:
 cmp.w (a1),d5			; neues hi-x?
 ble.s chky
 move.w d5,(a1)
chky:				; Clipping, rechts zuerst
 move.w #319,d6
 cmp.w d6,d0			; P1 rechts von rechter Kante
 bgt.s ctx21			; ja -> x = 319 und neues y
 cmp.w d6,d2			; P2 rechts von rechter Kante
 bgt.w ctx22			; ja -> x = 319 und neues y
 moveq #0,d6
 tst.w d1			; P1 über Oberkante ?
 bmi.s cty11			; ja -> y = 0 und neues x
 tst.w d3			; P2 über Oberkante ?
 bmi.s cty12			; ja -> y = 0 und neues x
 move.w #147,d6
 cmp.w d6,d1			; P1 unter Unterkante ?
 bgt.s cty21			; ja -> x = 147 und neues y
 cmp.w d6,d3			; P2 unter Unterkante ?
 bgt.s cty22			; ja -> x = 147 und neues y
chkx:
 moveq #0,d6
 tst.w d0			; P1 links von linker Kante ?
 bmi.s ctx11			; ja -> x = 0 und neues y
 tst.w d2			; P2 links von linker Kante ?
 bmi.s ctx12			; ja -> x = 0 und neues y
 bra dline
cty11:				; Clip Oberkante
 tst.w d3			; auch P2 über Oberkante (-> Line unsichtbar) ?
 bmi.s clpend
 bsr.s clipy
 move.w d4,d0			; berechnete x-Koordinate
 moveq #0,d1			; y=0
 bra chky			; noch einmal überprüfen
cty12:
 bsr.s clipy			; Clip Oberkante
 move.w d4,d2			; berechnete x-Koordinate
 moveq #0,d3			; y=0
 bra chky
cty21:				; Clip Unterkante
 cmp.w d6,d3			; auch P2 unter Unterkante ?
 bgt.s clpend
 bsr.s clipy
 move.w d4,d0			; berechnete x-Koordinate
 move.w d6,d1			; y=147
 bra chky
cty22:				; Clip Unterkante
 bsr.s clipy
 move.w d4,d2			; berechnete x-Koordinate
 move.w d6,d3			; y=147
 bra chky
ctx11:				; Clip linke Kante
 tst.w d2			; auch P2 links von linker Kante ?
 bmi.s clpend
 bsr.s clipx
 move.w d4,d1			; berechnete y-Koordinate
 moveq #0,d0			; x=0
 bra chky
ctx12:				; Clip linke Kante
 bsr.s clipx
 move.w d4,d3			; berechnete y-Koordinate
 moveq #0,d2			; x=0
 bra chky
ctx21:				; Clip rechte Kante
 cmp.w d6,d2			; auch P2 rechts von rechter Kante ?
 bgt.s clpend
 bsr.s clipx
 move.w d4,d1			; berechnete y-Koordinate
 move.w d6,d0			; x=319
 movem.w d0-d1,(a4)		; Schnittpunkt mit rechter Kante merken
 addq.l #4,a4
 bra chky			; noch einmal überprüfen
ctx22:				; Clip rechte Kante
 bsr.s clipx
 move.w d4,d3			; berechnete y-Koordinate
 move.w d6,d2			; x=319
 movem.w d2-d3,(a4)		; Schnittpunkt mit rechter Kante merken
 addq.l #4,a4
 bra chky			; noch einmal überprüfen
clpend:				; Linie unsichtbar
 movem.l (a7)+,d4-d7/a5-a6
 rts
clipy:				; yb bekannt (Unter-/Oberkante)
 move.w d0,d4			; xn berechnen
 sub.w d2,d4			; x' = x1-x2
 move.w d3,d5
 move.w d3,d7
 sub.w d6,d7			; y' = y2-yb
 muls d7,d4			; xn = x' * y'
 sub.w d1,d5
 divs d5,d4			; xn = xn / (y2-y1)
 add.w d2,d4			; xn = xn + x2
 rts
clipx:				; xb bekannt (Linke/Rechte Kante)
 move.w d1,d4			; yn berechnen
 sub.w d3,d4			; y' = y1-y2
 move.w d2,d5
 move.w d2,d7
 sub.w d6,d7			; x' = x2-xb
 muls d7,d4			; yn = x' * y'
 sub.w d0,d5
 divs d5,d4			; yn = yn / (x2-x1)
 add.w d3,d4			; yn = yn + y2
 rts

dline:				; Hier wird gezeichnet
 cmp.w d1,d3			; Falls y1 = y2 -> Keine Linie,
 beq drawend			; da Blitter im Single-Mode
 move.w d1,d5
 move.w d1,d4
 asl.w #5,d5
 asl.w #3,d4
 add.w d4,d5
 move.l tmpadr(pc),a5		; In Hilfs-Ebene zeichnen
 lea 0(a5,d5.w),a5
 move.w d0,d4
 asr.w #4,d4
 add.w d4,d4
 lea 0(a5,d4.w),a5		; Adresse für Prozessor-EOR
 sub.w d0,d2
 sub.w d1,d3
 moveq #15,d5
 and.l d5,d0
 move.w d0,d4
 ror.l #4,d0
 eor.w d5,d4
 moveq #0,d5
 bset d4,d5			; Genaues Bit für Prozessor-EOR
 move.w #4,d0
 tst.w d2
 bpl.s d2g0
 addq.w #1,d0
 neg.w d2
d2g0:
 cmp.w d2,d3
 ble.s d2gd3
 exg.l d2,d3
 subq.w #4,d0
 add.w d0,d0
d2gd3:
 move.w d3,d4
 sub.w d2,d4
 add.w d4,d4
 add.w d4,d4
 add.w d3,d3
 moveq #0,d6
 move.w d3,d6
 sub.w d2,d6
 bpl.s d6gd2
 or.w #16,d0
d6gd2:
 add.w d3,d3
 add.w d0,d0
 add.w d0,d0
 addq.w #1,d2
 asl.w #6,d2
 addq.w #2,d2
 swap d3
 move.w d4,d3
 or.l #$b4a0003,d0		; EOR-MiniTerms + SING-Bit + Line-Bit
 move.w #$4000,$9a(a6)		; Interrupts wegen Blitter sperren (falls
 wblt				; im VBI Blitterzugriff erfolgt)
 moveq #40,d1			; Register für Line initialisieren
 move.w d1,$60(a6)
 move.w d1,$66(a6)
 moveq #-1,d1
 move.l d1,$44(a6)
 move.w d1,$72(a6)
 move.w #$8000,$74(a6)
 eor.w d5,(a5)			; Prozessor-EOR
 move.l d3,$62(a6)
 move.l a5,$48(a6)
 move.l a5,$54(a6)
 move.w d6,$52(a6)
 move.l d0,$40(a6)
 move.w d2,$58(a6)
 move.w #$c000,$9a(a6)		; Interrupts wieder freigeben
 add.w #1,line
drawend:
 movem.l (a7)+,d4-d7/a5-a6
 rts

calcwindow:			; GRÖSSE des Fill-/Copy- Fensters
 cmp.w #319,(a1)		; in Adressen u. Modulo umrechnen
 ble.s ok14
 move.w #319,(a1)		; Überprüfung auf Rand-Überschreitung
 ok14:
  tst 2(a1)
  bge.s ok15			; ...
  move.w #0,2(a1)
 ok15:
  cmp.w #147,4(a1)
  ble.s ok16
  move.w #147,4(a1)
 ok16:
  tst.w 6(a1)
  bge.s ok17
  move.w #0,6(a1)
 ok17:
  move.w (a1),d0
  asr.w #4,d0			; x-Offset des Blitterfensters
  asl.w #1,d0
  move.w d0,woffx
  asr.w #1,d0
  move.w 2(a1),d1
  asr.w #4,d1
  sub.w d1,d0			; x-Größe des Blitterfensters
  addq.w #1,d0
  move.w d0,wsizex
  asl.w #1,d0
  moveq #40,d1			; Modulo
  sub.w d0,d1			; für temporäre
  move.w d1,tmpmod		; Hilfsebene
  move.w 4(a1),d0
  sub.w 6(a1),d0		; y-Ausdehnung des Blitterfensters
  addq.w #1,d0
  move.w d0,wsizey
  move.w 4(a1),d0
  move.w d0,d1
  asl.w #3,d0
  asl.w #5,d1			; y-Offset des Blitterfensters
  add.w d1,d0
  move.w d0,woffy
  rts

transform:			; TRANSFORMATION
 lea objpd(pc),a2		; 3D-Eckpunkt-Daten
 lea ttab(pc),a3		; Tabelle für 2D-Ergebnis-Daten
 lea sintab(pc),a0		; Zeiger auf Sinus-Tabelle
 lea costab(pc),a1		; Zeiger auf Cosinus-Tabelle
 lea z2tab(pc),a4		; Zwischen-Tabelle für 3D-Z-Koords der
 moveq #15,d6			; einzelnen Punkte
 move.w (a2)+,d5
 subq.w #1,d5			; Eckenzahl - 1
translp:
 movem.w (a2)+,d0-d2		; 3D-Koordinaten holen
 asl.w #4,d0			; Zwecks höherer Genauigkeit der
 asl.w #4,d1			; Rechnungen, Multiplikation mit 16
 asl.w #4,d2
 move.w rx(pc),d3		; Rotation um x-Achse
 move.w d1,d4
 move.w d2,d7
 muls 0(a1,d3.w),d1
 muls 0(a0,d3.w),d2
 sub.l d2,d1
 asr.l d6,d1
 muls 0(a0,d3.w),d4
 muls 0(a1,d3.w),d7
 add.l d7,d4
 asr.l d6,d4
 move.w d4,d2
 move.w ry(pc),d3		; Rotation um y-Achse
 move.w d0,d4
 move.w d2,d7
 muls 0(a1,d3.w),d0
 muls 0(a0,d3.w),d2
 add.l d2,d0
 asr.l d6,d0
 neg.w d4
 muls 0(a0,d3.w),d4
 muls 0(a1,d3.w),d7
 add.l d7,d4
 asr.l d6,d4
 move.w d4,d2
 move.w rz(pc),d3		; Rotation um z-Achse
 move.w d0,d4
 move.w d1,d7
 muls 0(a1,d3.w),d0
 muls 0(a0,d3.w),d1
 sub.l d1,d0
 asr.l d6,d0
 muls 0(a0,d3.w),d4
 muls 0(a1,d3.w),d7
 add.l d7,d4
 asr.l d6,d4
 move.w d4,d1
 move.w d2,(a4)+		; z-Koordinate jedes einzelnen Echpunktes
 ext.l d0			; nach Zwischentabelle
 ext.l d1
 ext.l d2
 add.l addx(pc),d0		; Verschiebung addieren
 add.l addy(pc),d1
 add.l addz(pc),d2
 beq.s ptjend
 moveq #10,d3			; Strahlensatz:
 asl.l d3,d0			;      f*x
 asl.l d3,d1			; x' = -
 asr.l #3,d2			;       z
 divs d2,d0
 divs d2,d1			;        f*y
 neg.w d0			; y' = - -
 add.w #160*16,d0		;         z
 add.w #74*16,d1		; Zentrieren
ptjend:
 movem.w d0-d1,(a3)		; und nach 2D-Tabelle speichern
 addq.l #4,a3
 dbf d5,translp
 rts

backs:				; FLÄCHENRÜCKEN-Überprüfung
 lea objad(pc),a2
 lea ttab(pc),a3
 lea z2tab(pc),a1
 lea ztab(pc),a0
 lea dttab(pc),a4
 move.w (a2)+,d7
 subq.w #1,d7
backslp:
 move.w 4(a2),d5
 movem.w 0(a3,d5.w),d0-d1	; 2D-Koordinaten der drei ersten Punkte
 move.w 6(a2),d5		; (im Text D, E, F, genannt)
 movem.w 0(a3,d5.w),d2-d3
 move.w 8(a2),d5
 movem.w 0(a3,d5.w),d4-d5
 sub.w d0,d2			; Daraus Vektoren
 sub.w d1,d3			; v
 sub.w d0,d4			; und
 sub.w d1,d5			; w berechnen
 muls d2,d5			; Multiplikation f+r
 muls d3,d4			; Vektorprodukt
 sub.l d4,d5			; und Subtraktion dazu
 bmi.s notvisib			; <0 -> nix sichtbar
 move.w (a2),d6
 subq.w #1,d6
 moveq #4,d5
 moveq #0,d1
avlp:
 move.w 0(a2,d5.w),d0		; Addition der z-Koordinaten
 asr.w #1,d0			; der Eckpunkte aus der
 add.w 0(a1,d0.w),d1		; Zwischen-Tabelle ...
 addq.w #2,d5
 dbf d6,avlp
 addq.w #1,drawnum
 ext.l d1
 divs (a2),d1			; ... Division durch Anzahl der Eckpunkte
 ext.l d1			; zur Durchschnittsberechnung
 add.l addz(pc),d1
 move.l d1,(a0)+		; In ztab zum Sortieren speichern.
 move.l a2,(a4)+		; Eintrag für sichtbare Fläche
 addq.l #6,a4			; in dttab anlegen (Zeiger auf
 move.l a3,(a4)+		; objad-Eintrag, ...)
notvisib:
 lea 22(a2),a2
 dbf d7,backslp			; alle Flächen?
 subq.l #4,a0
 move.l a0,zend			; Ende von ztab (für Quicksort)
 rts

copy:				; FÜLLEN der Fläche in Hilfsebene
 move.l tmpadr(pc),a0		; + KOPIEREN in Hauptscreen
 move.l pgh(pc),a1		; + LÖSCHEN der Hilfsebene
 moveq #0,d2
 move.w woffx(pc),d2		; berechnete Window-Werte holen
 add.w woffy(pc),d2
 add.l d2,a0
 add.l d2,a1
 move.w wsizey(pc),d2
 asl.w #6,d2
 add.w wsizex(pc),d2
 move.w tmpmod(pc),d0
 moveq #-1,d1
 move.w #$4000,$9a(a6)
 wblt
 move.w d0,$62(a6)
 move.w d0,$64(a6)
 move.w d0,$66(a6)
 move.l d1,$44(a6)
 move.l a0,$50(a6)
 move.l a0,$54(a6)
 move.l #$9f00012,$40(a6)
 move.w d2,$58(a6)		; Füllen
 move.l #$dfc0002,d1
 moveq #0,d0
 move.l #$f00000,d3		; Wechseln für
copylp:				; löschend oder
 btst d0,d4			; setzend kopieren
 bne.s ok18
 sub.l d3,d1
ok18:
 wblt
 move.l d1,$40(a6)
 move.l a0,$50(a6)
 move.l a1,$4c(a6)
 move.l a1,$54(a6)
 move.w d2,$58(a6)		; Nach Farb-Wert in die
 or.l d3,d1			; drei Ebenen kopieren
 lea 148*40(a1),a1
 addq.w #1,d0
 cmp.w #2,d0
 ble.s copylp			; Alle drei Ebenen?
 wblt
 move.l #$1000002,$40(a6)
 move.l a0,$54(a6)
 move.w d2,$58(a6)		; Fläche in Hilfsebene
 move.w #$c000,$9a(a6)		; wieder löschen
 rts

rotob:				; BEARBEITUNG von "rottab"
 subq.w #1,animcnt
 bge.s endrot			; Nur jeden dritten Aufruf
 move.w #2,animcnt		; abarbeiten
 lea objpd(pc),a2
 move.l rotptr(pc),a3
 moveq #5,d6			; sechs Einschnitte
rotlp:
 move.w 2(a2),d0
 cmp.w (a3),d0			; vorgegebenes x erreicht?
 beq.s okx
 blt.s lowx
 subq.w #2,2(a2)		; noch zu groß ->
 bra.s okx			; Verringerung um 8
lowx:
 addq.w #8,2(a2)		; noch zu klein ->
okx:				; Vergrößerung um 8
 move.w 4(a2),d0
 cmp.w 2(a3),d0			; vorgegebenes y erreicht?
 beq.s oky
 blt.s lowy
 subq.w #8,4(a2)		; noch zu groß ->
 bra.s oky			; Verringerung um 8
lowy:
 addq.w #8,4(a2)		; noch zu klein ->
oky:				; Vergrößerung um 8
 lea 8*6(a2),a2
 addq.l #4,a3
 dbf d6,rotlp
 subq.w #1,rotcnt
 bgt.s ok30			; Darstellungszeit zu ende?
 tst.w (a3)
 bge.s ok20			; "rottab" zu ende?
 lea rottab(pc),a3
ok20:
 move.w (a3)+,rotcnt
 move.l a3,rotptr
ok30:
 bsr.s dorot
endrot
 rts

dorot:				; ermittelte Kontur des
 lea sintab(pc),a0		; Körpers dreidimensionalisieren
 lea costab(pc),a1
 lea objpd(pc),a2
 moveq #5,d6			; sechs Einschnitte
 moveq #15,d7
 addq.l #2,a2
roto:
 moveq #7,d5			; Kreis in acht Abschnitte a 45°
 moveq #0,d4			; zerteilen
 move.w (a2),d3			; x-Koordinate
 move.w 2(a2),d1		; und y-Koordinate des Kontur-
roti:				; Einschnittes holen (y nur für movem)
 move.w d3,d0
 move.w d3,d2
 muls 0(a1,d4.w),d0		; x mit cos multiplizieren -> neu_x
 muls 0(a0,d4.w),d2		; x mit sin multiplizieren -> neu_z
 asr.l d7,d0
 asr.l d7,d2
 movem d0-d2,(a2)		; als 3D-Koords in "objpd" speichern
 addq.l #6,a2
 add.w #90,d4
 dbf d5,roti
 dbf d6,roto
 rts

tmpadr dc.l 0
screen dc.l 0
vbi dc.w 0
pgh dc.l 0 			; ******
pgs dc.l 0
addx dc.l 0			; WICHTIG!!
addy dc.l 0
addz dc.l 0			; Diese
rx dc.w 0
ry dc.w 0			; Konstellation
rz dc.w 0
   dc.w 0			; darf
hix dc.w 0
lox dc.w 0			; unter
hiy dc.w 0
loy dc.w 0			; keinen
addxb dc.l 0
addyb dc.l 0			; Umständen
addzb dc.l -25000	; (Start-Z)
rxb dc.w 0			; geändert
ryb dc.w 0
rzb dc.w 0			; werden
scx1 dc.w 0			; !!
scy1 dc.w 0			; !!
scx2 dc.w 0			; !!
scy2 dc.w 0			; ******
zend dc.l 0
wsizex dc.w 1
wsizey dc.w 1
woffx dc.w 0
woffy dc.w 0
tmpmod dc.w 0
drawnum dc.w 0
line dc.w 0
animcnt dc.w 0
oldvbi dc.l 0
intena dc.w 0
rotcnt dc.w 0
rotptr dc.l 0

ttab:				; Tabelle für 2D-Koordinaten
 dcb.w 50*2

z2tab:				; Zwischen-Tabelle für z-Koords jedes Punktes
 dcb.w 50
 cnop 0,4

ztab:				; z-Koordinaten-Tabelle für Flächendurch-
 dcb.l 50			; schnitt (Sortieren)

dttab:				; Tabelle mit Einträgen der sichtbaren Flächen
 dcb.w 50*7

lrtab:				; Hilfs-Tabelle für Quicksort
 dcb.l 50

rottab:				; Tabelle für Mutation des Körpers
 dc.w 30			; Dauer der Darstellung dieser Mutation
 dc.w -$a*3,$40*3		; x, y-Ziel für ersten Einschnitt
 dc.w -$14*3,$28*3		; x, y-Ziel für zweiten Einschnitt
 dc.w -$40*3,$8*3		; x, y-Ziel für dritten Einschnitt
 dc.w -$40*3,-$8*3		; x, y-Ziel für vierten Einschnitt
 dc.w -$14*3,-$28*3		; x, y-Ziel für fünften Einschnitt
 dc.w -$a*3,-$40*3		; x, y-Ziel für sechsten Einschnitt
 dc.w 30			; Dauer der Darstellung der nächsten Mutation
 dc.w -$3a*3,$40*3
 dc.w -$24*3,$20*3
 dc.w -$10*3,$20*3
 dc.w -$10*3,-$20*3
 dc.w -$24*3,-$20*3
 dc.w -$3a*3,-$40*3
 dc.w 30
 dc.w -$a*3,$40*3
 dc.w -$34*3,$20*3
 dc.w -$10*3,$20*3
 dc.w -$10*3,-$20*3
 dc.w -$34*3,-$20*3
 dc.w -$a*3,-$40*3
 dc.w 30
 dc.w -$a*3,$28*3
 dc.w -$34*3,$8*3
 dc.w -$10*3,$8*3
 dc.w -$10*3,-$8*3
 dc.w -$34*3,-$8*3
 dc.w -$a*3,-$28*3
 dc.w 30
 dc.w -$a*3,$40*3
 dc.w -$14*3,$8*3
 dc.w -$40*3,$8*3
 dc.w -$40*3,-$8*3
 dc.w -$14*3,-$8*3
 dc.w -$a*3,-$40*3
 dc.w 30
 dc.w -$a*3,$40*3
 dc.w -$3c*3,$28*3
 dc.w -$50*3,$10*3
 dc.w -$50*3,-$10*3
 dc.w -$3c*3,-$28*3
 dc.w -$a*3,-$40*3
 dc.w 30
 dc.w -$a*3,$8*3
 dc.w -$3c*3,$28*3
 dc.w -$50*3,$10*3
 dc.w -$50*3,-$10*3
 dc.w -$3c*3,-$28*3
 dc.w -$a*3,-$8*3
 dc.w 50
 dc.w -$a*3,$40*3
 dc.w -$24*3,$30*3
 dc.w -$40*3,-$8*3
 dc.w -$10*3,-$10*3
 dc.w -$24*3,-$20*3
 dc.w -$a*3,-$40*3
 dc.w 50
 dc.w -$a*3,$40*3
 dc.w -$24*3,$20*3
 dc.w -$8*3,-$10*3
 dc.w -$20*3,-$10*3
 dc.w -$24*3,-$20*3
 dc.w -$a*3,-$40*3
 dc.w 50
 dc.w -$3a*3,$40*3
 dc.w -$24*3,$20*3
 dc.w -$20*3,$10*3
 dc.w -$8*3,$10*3
 dc.w -$c*3,-$20*3
 dc.w -$3a*3,-$40*3
 dc.w 50
 dc.w -$a*3,$10*3
 dc.w -$3c*3,$40*3
 dc.w -$20*3,$10*3
 dc.w -$8*3,$10*3
 dc.w -$c*3,-$30*3
 dc.w -$32*3,-$40*3
 dc.w 50
 dc.w -$a*3,$40*3
 dc.w -$44*3,$20*3
 dc.w -$8*3,$20*3
 dc.w -$20*3,-$10*3
 dc.w -$c*3,-$20*3
 dc.w -$a*3,-$40*3
 dc.w -1

objpd:				; Eckpunkt-Tabelle
 dc.w 6*8			; Anzahl Eckpunkte
 dc.w -$a*3,$40*3,0		; x,y,z
 dcb.w 7*3			; sieben leer-x,y,z; werden von "dorot"
 dc.w -$14*3,$28*3,0		; beschrieben
 dcb.w 7*3
 dc.w -$40*3,$8*3,0
 dcb.w 7*3
 dc.w -$40*3,-$8*3,0
 dcb.w 7*3
 dc.w -$14*3,-$28*3,0
 dcb.w 7*3
 dc.w -$a*3,-$40*3,0
 dcb.w 7*3

objad:		; Flächen-Tabelle: Eckenzahl,Farbe, 9 mal Platz für Punkte
 dc.w 2+8+8+8+8+8 ; Anzahl der Flächen
 dc.w 8,7,0*4,1*4,2*4,3*4,4*4,5*4,6*4,7*4,0*4
 dc.w 8,7,47*4,46*4,45*4,44*4,43*4,42*4,41*4,40*4,47*4

 dc.w 4,3,40*4,41*4,33*4,32*4,40*4,0,0,0,0
 dc.w 4,4,41*4,42*4,34*4,33*4,41*4,0,0,0,0
 dc.w 4,3,42*4,43*4,35*4,34*4,42*4,0,0,0,0
 dc.w 4,4,43*4,44*4,36*4,35*4,43*4,0,0,0,0
 dc.w 4,3,44*4,45*4,37*4,36*4,44*4,0,0,0,0
 dc.w 4,4,45*4,46*4,38*4,37*4,45*4,0,0,0,0
 dc.w 4,3,46*4,47*4,39*4,38*4,46*4,0,0,0,0
 dc.w 4,4,47*4,40*4,32*4,39*4,47*4,0,0,0,0

 dc.w 4,3,8*4,9*4,1*4,0*4,8*4,0,0,0,0
 dc.w 4,4,9*4,10*4,2*4,1*4,9*4,0,0,0,0
 dc.w 4,3,10*4,11*4,3*4,2*4,10*4,0,0,0,0
 dc.w 4,4,11*4,12*4,4*4,3*4,11*4,0,0,0,0
 dc.w 4,3,12*4,13*4,5*4,4*4,12*4,0,0,0,0
 dc.w 4,4,13*4,14*4,6*4,5*4,13*4,0,0,0,0
 dc.w 4,3,14*4,15*4,7*4,6*4,14*4,0,0,0,0
 dc.w 4,4,15*4,8*4,0*4,7*4,15*4,0,0,0,0

 dc.w 4,2,16*4,17*4,9*4,8*4,16*4,0,0,0,0
 dc.w 4,1,17*4,18*4,10*4,9*4,17*4,0,0,0,0
 dc.w 4,2,18*4,19*4,11*4,10*4,18*4,0,0,0,0
 dc.w 4,1,19*4,20*4,12*4,11*4,19*4,0,0,0,0
 dc.w 4,2,20*4,21*4,13*4,12*4,20*4,0,0,0,0
 dc.w 4,1,21*4,22*4,14*4,13*4,21*4,0,0,0,0
 dc.w 4,2,22*4,23*4,15*4,14*4,22*4,0,0,0,0
 dc.w 4,1,23*4,16*4,8*4,15*4,23*4,0,0,0,0

 dc.w 4,5,24*4,25*4,17*4,16*4,24*4,0,0,0,0
 dc.w 4,6,25*4,26*4,18*4,17*4,25*4,0,0,0,0
 dc.w 4,5,26*4,27*4,19*4,18*4,26*4,0,0,0,0
 dc.w 4,6,27*4,28*4,20*4,19*4,27*4,0,0,0,0
 dc.w 4,5,28*4,29*4,21*4,20*4,28*4,0,0,0,0
 dc.w 4,6,29*4,30*4,22*4,21*4,29*4,0,0,0,0
 dc.w 4,5,30*4,31*4,23*4,22*4,30*4,0,0,0,0
 dc.w 4,6,31*4,24*4,16*4,23*4,31*4,0,0,0,0

 dc.w 4,2,32*4,33*4,25*4,24*4,32*4,0,0,0,0
 dc.w 4,1,33*4,34*4,26*4,25*4,33*4,0,0,0,0
 dc.w 4,2,34*4,35*4,27*4,26*4,34*4,0,0,0,0
 dc.w 4,1,35*4,36*4,28*4,27*4,35*4,0,0,0,0
 dc.w 4,2,36*4,37*4,29*4,28*4,36*4,0,0,0,0
 dc.w 4,1,37*4,38*4,30*4,29*4,37*4,0,0,0,0
 dc.w 4,2,38*4,39*4,31*4,30*4,38*4,0,0,0,0
 dc.w 4,1,39*4,32*4,24*4,31*4,39*4,0,0,0,0

; Neue Sinus/Cosinus-Tabelle:
; -$8000 bis $7fff

sintab DC.W 0,$23B,$477,$6B2,$8ED,$B27,$D61,$F99
       DC.W $11D0,$1405,$1639,$186C,$1A9C,$1CCA,$1EF7,$2120
       DC.W $2347,$256C,$278D,$29AB,$2BC6,$2DDE,$2FF2,$3203
       DC.W $340F,$3617,$381C,$3A1B,$3C17,$3E0D,$3FFF,$41EC
       DC.W $43D3,$45B6,$4793,$496A,$4B3B,$4D07,$4ECD,$508C
       DC.W $5246,$53F9,$55A5,$574B,$58E9,$5A81,$5C12,$5D9C
       DC.W $5F1E,$6099,$620C,$6378,$64DC,$6638,$678D,$68D9
       DC.W $6A1D,$6B58,$6C8C,$6DB6,$6ED9,$6FF2,$7103,$720B
       DC.W $730A,$7400,$74EE,$75D2,$76AD,$777E,$7846,$7905
       DC.W $79BB,$7A67,$7B09,$7BA2,$7C31,$7CB7,$7D32,$7DA4
       DC.W $7E0D,$7E6B,$7EC0,$7F0A,$7F4B,$7F82,$7FAF,$7FD2
       DC.W $7FEB,$7FFA
costab DC.W $7FFF,$7FFA,$7FEB,$7FD2,$7FAF,$7F82
       DC.W $7F4B,$7F0A,$7EC0,$7E6B,$7E0D,$7DA4,$7D32,$7CB7
       DC.W $7C31,$7BA2,$7B09,$7A67,$79BB,$7905,$7846,$777E
       DC.W $76AD,$75D2,$74EE,$7400,$730A,$720B,$7103,$6FF2
       DC.W $6ED9,$6DB6,$6C8B,$6B58,$6A1D,$68D9,$678D,$6638
       DC.W $64DC,$6378,$620C,$6099,$5F1E,$5D9C,$5C12,$5A81
       DC.W $58E9,$574B,$55A5,$5EF9,$5246,$508C,$4ECD,$4D07
       DC.W $4B3B,$496A,$4793,$45B6,$43D3,$41EC,$3FFF,$3E0D
       DC.W $3C17,$3A1B,$381C,$3618,$340F,$3203,$2FF2,$2DDE
       DC.W $2BC7,$29AB,$278D,$256C,$2347,$2120,$1EF7,$1CCB
       DC.W $1A9C,$186C,$163A,$1406,$11D0,$F99,$D61,$B27
       DC.W $8ED,$6B3,$477,$23C,0,$FDC5,$FB89,$F94E
       DC.W $F713,$F4D9,$F2A0,$F067,$EE30,$EBFB,$E9C7,$E794
       DC.W $E564,$E336,$E10A,$DEE0,$DCB9,$DA95,$D873,$D655
       DC.W $D43A,$D222,$D00E,$CDFE,$CBF1,$C9E9,$C7E5,$C5E5
       DC.W $C3EA,$C1F3,$C001,$BE14,$BC2D,$BA4B,$B86E,$B696
       DC.W $B4C5,$B2F9,$B133,$AF74,$ADBB,$AC08,$AA5B,$A8B6
       DC.W $A717,$A57F,$A3EE,$A264,$A0E2,$9F67,$9DF4,$9C88
       DC.W $9B24,$99C8,$9874,$9728,$95E4,$94A8,$9375,$924A
       DC.W $9128,$900E,$8EFD,$8DF5,$8CF6,$8C00,$8B13,$8A2E
       DC.W $8954,$8882,$87BA,$86FB,$8645,$8599,$84F7,$845E
       DC.W $83CF,$8349,$82CE,$825C,$81FE,$8195,$8140,$80F6
       DC.W $80B5,$807E,$8051,$802E,$8015,$8006,$8001,$8006
       DC.W $8015,$802E,$8051,$807E,$80B5,$80F6,$8140,$8195
       DC.W $81F3,$825B,$82CD,$8349,$83CF,$845E,$84F7,$8599
       DC.W $8645,$86FB,$87B9,$8882,$8953,$8A2E,$8B12,$8BFF
       DC.W $8CF5,$8DF5,$8EFD,$900E,$9127,$9249,$9374,$94A7
       DC.W $95E3,$9727,$9873,$99C7,$9B23,$9C87,$9DF3,$9F67
       DC.W $A0E1,$A264,$A3ED,$A57E,$A716,$A8B5,$AA5B,$AC07
       DC.W $ADBA,$AF73,$B133,$B2F8,$B4C4,$B696,$B86D,$BA4A
       DC.W $BC2C,$BE14,$C000,$C1F2,$C3E9,$C5E4,$C7E4,$C9E8
       DC.W $CBF0,$CDFD,$D00D,$D221,$D439,$D654,$D872,$DA94
       DC.W $DCB8,$DEDF,$E109,$E335,$E563,$E794,$E9C6,$EBFA
       DC.W $EE30,$F066,$F29F,$F4D8,$F712,$F49D,$FB88,$FDC4
sinend DC.W 0,$23B,$477,$6B2,$8ED,$B27,$D61,$F99
       DC.W $11D0,$1405,$1639,$186C,$1A9C,$1CCA,$1EF7,$2120
       DC.W $2347,$256C,$278D,$29AB,$2BC6,$2DDE,$2FF2,$3203
       DC.W $340F,$3617,$381C,$3A1B,$3C17,$3E0D,$3FFF,$41EC
       DC.W $43D3,$45B6,$4793,$496A,$4B3B,$4D07,$4ECD,$508C
       DC.W $5246,$53F9,$55A5,$574B,$58E9,$5A81,$5C12,$5D9C
       DC.W $5F1E,$6099,$620C,$6378,$64DC,$6638,$678D,$68D9
       DC.W $6A1D,$6B58,$6C8C,$6DB6,$6ED9,$6FF2,$7103,$720B
       DC.W $730A,$7400,$74EE,$75D2,$76AD,$777E,$7846,$7905
       DC.W $79BB,$7A67,$7B09,$7BA2,$7C31,$7CB7,$7D32,$7DA4
       DC.W $7E0D,$7E6B,$7EC0,$7F0A,$7F4B,$7F82,$7FAF,$7FD2
       DC.W $7FEB,$7FFA
cosend

gfxname dc.b "graphics.library",0

   section copperlist,data_c

copperlist:
 dc.w $2001,-2
 dc.w $180,$000,$182,$0a0,$184,$080
 dc.w $186,$00c,$188,$00a,$18a,$a0a
 dc.w $18c,$808,$18e,$00f
 dc.w $5e01,-2,$180,$05a
 dc.w $5f01,-2,$180,$07c
 dc.w $6001,-2,$180,$0af
 dc.w $6101,-2,$180,$05a
 dc.w $620f,-2,$96,$8100,$180,0
page:
 dc.w $e0,0,$e2,0,$e4,0,$e6,0,$e8,0,$ea,0
 dc.w $f601,-2,$96,$100,$180,$05a
 dc.w $f701,-2,$180,$0af
 dc.w $f801,-2,$180,$07c
 dc.w $f901,-2,$180,$05a
 dc.w $fa01,-2,$180,0
 dc.w -1,-2
