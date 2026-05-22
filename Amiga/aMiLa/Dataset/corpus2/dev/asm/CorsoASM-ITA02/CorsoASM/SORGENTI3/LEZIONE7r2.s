
; Lezione7r2.s	UNO SPRITE MOSSO CON IL MOUSE CHE ARRIVA FINO AL BORDO DESTRO



	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo la vecchia COP

;	Puntiamo la PIC "vuota"

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

;	Puntiamo lo sprite

	MOVE.L	#MIOSPRITE,d0		; indirizzo dello sprite in d0
	LEA	SpritePointers,a1	; Puntatori in copperlist
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

	move.b	$dff00a,mouse_y
	move.b	$dff00b,mouse_x

mouse:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	mouse

	bsr.s	LeggiMouse	; questa legge il mouse
	move.w	sprite_y(pc),d0 ; prepara i parametri per la routine
	move.w	sprite_x(pc),d1 ; universale
	lea	miosprite,a1	; indirizzo sprite
	moveq	#13,d2		; altezza sprite
	bsr.w	UniMuoviSprite	; chiama la routine universale

Aspetta:
	cmpi.b	#$ff,$dff006	; linea 255?
	beq.s	Aspetta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la vecchia cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable
	move.l	gfxbase(PC),a1
	jsr	-$19e(a6)	; Closelibrary
	rts

;	Dati

GfxName:
	dc.b	"graphics.library",0,0

GfxBase:
	dc.l	0

OldCop:
	dc.l	0

; Questa routine legge il mouse e aggiorna i valori contenuti nelle
; variabili sprite_x e sprite_y

LeggiMouse:
	move.b	$dff00a,d1	; JOY0DAT posizione verticale mouse
	move.b	d1,d0		; copia in d0
	sub.b	mouse_y(PC),d0	; sottrai vecchia posizione mouse
	beq.s	no_vert		; se la differenza = 0, il mouse e` fermo
	ext.w	d0		; trasforma il byte in word
				; (vedi alla fine del listato)
	add.w	d0,sprite_y	; modifica posizione sprite
no_vert:
  	move.b	d1,mouse_y	; salva posizione mouse per la prossima volta

	move.b	$dff00b,d1	; posizione orizzontale mouse
	move.b	d1,d0		; copia in d0
	sub.b	mouse_x(PC),d0	; sottrai vecchia posizione
	beq.s	no_oriz		; se la differenza = 0, il mouse e` fermo
	ext.w	d0		; trasforma il byte in word
				; (vedi alla fine del listato)
	add.w	d0,sprite_x	; modifica pos. sprite
no_oriz
  	move.b	d1,mouse_x	; salva posizione mouse per la prossima volta
	RTS

SPRITE_Y:	dc.w	0	; qui viene memorizzata la Y dello sprite
SPRITE_X:	dc.w	0	; qui viene memorizzata la X dello sprite
MOUSE_Y:	dc.b	0	; qui viene memorizzata la Y del mouse
MOUSE_X:	dc.b	0	; qui viene memorizzata la X del mouse




; Routine universale di posizionamento degli sprite.

;
;	Parametri in entrata di UniMuoviSprite:
;
;	a1 = Indirizzo dello sprite
;	d0 = posizione verticale Y dello sprite sullo schermo (0-255)
;	d1 = posizione orizzontale X dello sprite sullo schermo (0-320)
;	d2 = altezza dello sprite
;

UniMuoviSprite:
; posizionamento verticale
	ADD.W	#$2c,d0		; aggiungi l'offset dell'inizio dello schermo

; a1 contiene l'indirizzo dello sprite
	MOVE.b	d0,(a1)		; copia il byte in VSTART
	btst.l	#8,d0
	beq.s	NonVSTARTSET
	bset.b	#2,3(a1)	; Setta il bit 8 di VSTART (numero > $FF)
	bra.s	ToVSTOP
NonVSTARTSET:
	bclr.b	#2,3(a1)	; Azzera il bit 8 di VSTART (numero < $FF)
ToVSTOP:
	ADD.w	D2,D0		; Aggiungi l'altezza dello sprite per
				; determinare la posizione finale (VSTOP)
	move.b	d0,2(a1)	; Muovi il valore giusto in VSTOP
	btst.l	#8,d0
	beq.s	NonVSTOPSET
	bset.b	#1,3(a1)	; Setta il bit 8 di VSTOP (numero > $FF)
	bra.w	VstopFIN
NonVSTOPSET:
	bclr.b	#1,3(a1)	; Azzera il bit 8 di VSTOP (numero < $FF)
VstopFIN:

; posizionamento orizzontale
	add.w	#128,D1		; 128 - per centrare lo sprite.
	btst	#0,D1		; bit basso della coordinata X azzerato?
	beq.s	BitBassoZERO
	bset	#0,3(a1)	; Settiamo il bit basso di HSTART
	bra.s	PlaceCoords

BitBassoZERO:
	bclr	#0,3(a1)	; Azzeriamo il bit basso di HSTART
PlaceCoords:
	lsr.w	#1,D1		; SHIFTIAMO, ossia spostiamo di 1 bit a destra
				; il valore di HSTART, per "trasformarlo" nel
				; valore fa porre nel byte HSTART, senza cioe'
				; il bit basso.
	move.b	D1,1(a1)	; Poniamo il valore XX nel byte HSTART
	rts


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
SpritePointers:
	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0 ; SPRITE
	dc.w	$12a,0,$12c,0,$12e,0,$130,0,$132,0
	dc.w	$134,0,$136,0,$138,0,$13a,0,$13c,0
	dc.w	$13e,0

	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0001001000000000	; bit 12 acceso!! 1 bitplane lowres

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;primo	 bitplane

	dc.w	$180,$000	; color0	; sfondo nero
	dc.w	$182,$123	; color1	; colore 1 del bitplane, che
						; in questo caso e' vuoto,
						; per cui non compare.

	dc.w	$1A2,$F00	; color17, ossia COLOR1 dello sprite0 - ROSSO
	dc.w	$1A4,$0F0	; color18, ossia COLOR2 dello sprite0 - VERDE
	dc.w	$1A6,$FF0	; color19, ossia COLOR3 dello sprite0 - GIALLO

	dc.w	$FFFF,$FFFE	; Fine della copperlist


; ************ Ecco lo sprite: OVVIAMENTE deve essere in CHIP RAM! ************

MIOSPRITE:		; lunghezza 13 linee
VSTART:
	dc.b $50	; Posizione verticale di inizio sprite (da $2c a $f2)
HSTART:
	dc.b $90	; Posizione orizzontale di inizio sprite (da $40 a $d8)
VSTOP:
	dc.b $5d	; $50+13=$5d	; posizione verticale di fine sprite
VHBITS:
	dc.b $00	; bit

 dc.w	%0000000000000000,%0000110000110000 ; Formato binario per modifiche
 dc.w	%0000000000000000,%0000011001100000
 dc.w	%0000000000000000,%0000001001000000
 dc.w	%0000000110000000,%0011000110001100 ;BINARIO 00=COLORE 0 (TRASPARENTE)
 dc.w	%0000011111100000,%0110011111100110 ;BINARIO 10=COLORE 1 (ROSSO)
 dc.w	%0000011111100000,%1100100110010011 ;BINARIO 01=COLORE 2 (VERDE)
 dc.w	%0000110110110000,%1111100110011111 ;BINARIO 11=COLORE 3 (GIALLO)
 dc.w	%0000011111100000,%0000011111100000
 dc.w	%0000011111100000,%0001111001111000
 dc.w	%0000001111000000,%0011101111011100
 dc.w	%0000000110000000,%0011000110001100
 dc.w	%0000000000000000,%1111000000001111
 dc.w	%0000000000000000,%1111000000001111
 dc.w	0,0	; 2 word azzerate definiscono la fine dello sprite.


	SECTION	PLANEVUOTO,BSS_C	; Il bitplane azzerato che usiamo,
					; perche' per vedere gli sprite
					; e' necessario che ci siano bitplanes
					; abilitati
BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

In questo esempio muoviamo uno sprite con il mouse in modo da raggiungere
il bordo destro e da non avere problemi con un eventuale overscan verticale.

Se vogliamo raggiungere il bordo destro dobbiamo usare una word per la
posizione orizzontale dello sprite. Il mouse pero` ci fornisce delle
coordinate in forma di byte. Allora usiamo il seguente metodo:
memorizziamo separatamente le coordinate dello sprite e le coordinate fornite
dal mouse. Ogni volta che eseguiamo LeggiMouse, leggiamo delle nuove
coordinate e le confrontiamo con le vecchie. Calcoliamo la differenza tra le
vecchie e le nuove coordiante del mouse, e aggiungiamo questa differenza alle
coordinate dello sprite. In questo modo non ha importanza il fatto che quando
la posizione del mouse supera 255 ritorna a 0, perche` cio` che conta e` solo
la differenza tra la nuova e la vecchia coordinata. Vi ricordo infatti che se
un byte assume un valore da 128 a 255, quando lo usiamo in un'addizione o in 
una sottrazione viene considerato un numero negativo in complemento a due.
Per cui se la vecchia coordinata vale 255, e la nuova vale 1, facendo la
differenza 255(=$ff) viene considerato -1. Quindi 1-(-1)=2.
Questo numero 2 viene aggiunto alla coordinata x dello sprite e siccome e`
positivo provoca comunque uno spostamento verso destra.
Se invece la differenza fosse stata negativa, aggiungendola alla coordinata x
dello sprite avrebbe provocato uno spostamento verso sinistra.
C'e` comunque un particolare a cui bisogna prestare molta attenzione. Quando
facciamo la differenza tra le coordinate del mouse stiamo lavorando con due
byte. Per cui la differenza sara` ancora un byte. Questo byte poi lo sommiamo
alla coordinata dello sprite che e` una word. Cio` provoca un problema.
Prima di fare la somma e` necessario trasformare il byte in una word.
La trasformazione viene fatta dal'istruzione EXT che trasforma un byte
contenuto in un registro in una word. Vediamo come opera tale istruzione.
Ci sono 2 casi:
Il byte contiene un numero positivo, per es. 5. La EXT trasforma cosi`:

	Contenuto prima della EXT	Contenuto dopo la EXT
	$XX05				$0005
(XX indica un qualsiasi numero)

Infatti 5 in formato word si scrive proprio $0005

Il byte contiene un numero negativo, per es. -5. La EXT trasforma cosi`:
Ricordando che -5 in formato byte si scrive $FB

	Contenuto prima della EXT	Contenuto dopo la EXT
	$XXFB				$FFFB
(XX indica un qualsiasi numero)

Infatti -5 in formato word si scrive proprio $FFFB.

In pratica la EXT prende il bit 7 di un registro (il bit che indica il segno)
e lo copia nei bit da 8 a 15.
Anche se non e` usata in questo esempio sappiate che per trasformare una word
in una long-word si usa sempre l'istruzione EXT, solo in formato .L:

	EXT.L   d0	; trasforma una word in long-word

La trasformazione avviene nella stessa maniera.

Per quanto riguarda le posizioni verticali il discorso e` lo stesso, e
infatti la rouine e` identica.

Per posizionare lo sprite sullo schermo usiamo di nuovo la routine universale,
che abbiamo gia` bella pronta. Vi renderete conto che anche le routine che
gestiscono la letture del mouse e del joystick si possono usare in ogni
programma che sia gestito il joystick e il mouse. Infatti i programmatori di
giochi e demo riutilizzano gran parte delle routines.

