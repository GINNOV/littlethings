
; Lezione7p.s	UNO SPRITE MOSSO CON IL JOYSTICK


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

mouse:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	mouse

	btst	#7,$bfe001	; Tasto FIRE premuto?
	bne.s	NonFuoco	; se no, salta l'istruzione seguente
	move.w	#$f00,$dff180	; se si, il metti un bel ROSSO nel COLOR0
NonFuoco:

	bsr.s	LeggiJoyst	; questa legge il joystick
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

; Questa routine legge il joystick e aggiorna i valori contenuti nelle
; variabili sprite_x e sprite_y

LeggiJoyst:
	MOVE.w	$dff00c,D3	; JOY1DAT
	BTST.l	#1,D3		; il bit 1 ci dice se si va a destra
	BEQ.S	NODESTRA	; se vale zero non si va a destra
	ADDQ.w	#1,SPRITE_X	; se vale 1 sposta a di un pixel lo sprite
	BRA.S	CHECK_Y		; vai al controllo della Y
NODESTRA:
	BTST.l	#9,D3		; il bit 9 ci dice se si va a sinistra
	BEQ.S	CHECK_Y		; se vale zero non si va a sinistra
	SUBQ.W	#1,SPRITE_X	; se vale 1 sposta lo sprite
CHECK_Y:
	MOVE.w	D3,D2		; copia il valore del registro
	LSR.w	#1,D2		; fa scorrere i bit di un posto verso destra 
	EOR.w	D2,D3		; esegue l'or esclusivo. Ora possiamo testare
	BTST.l	#8,D3		; testiamo se va in alto
	BEQ.S	NOALTO		; se no controlla se va in basso
	SUBQ.W	#1,SPRITE_Y	; se si sposta lo sprite
	BRA.S	ENDJOYST
NOALTO:
	BTST.l	#0,D3		; testiamo se va in basso
	BEQ.S	ENDJOYST	; se no finisci
	ADDQ.W	#1,SPRITE_Y	; se si sposta lo sprite
ENDJOYST:
	RTS

SPRITE_Y:	dc.w	0	; qui viene memorizzata la Y dello sprite
SPRITE_X:	dc.w	0	; qui viene memorizzata la X dello sprite



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

In questo esempio muoviamo uno sprite con il joystick.
La cosa piu' facile e' rilevare se il bottone FIRE e' premuto, infatti basta
un BTST #7,$bfe001, analogamente al tasto sinistro del mouse che e' il bit 6.
Per posizionare lo sprite sullo schermo usiamo la nostra routine universale,
che abbiamo gia` bella pronta risparmiandoci un po' di lavoro.
La routine Leggijoyst invece si occupa di rilevare lo stato del joystick e di
conseguenza aggiorna le coordinate dello sprite che sono memorizzate
in 2 locazioni di memoria: SPRITE_X e SPRITE_Y. Per leggere il joystick
e` necessario utilizzare l'istruzione EOR che, come abbiamo visto nella lezione
esegue un'operazione di OR ESCLUSIVO tra i bit di 2 registri.
Infatti la lettura del joystick avviene tramite il registro JOY1DAT. Per sapere
se la leva del joystick e` stata premuta a destra o a sinistra, basta sapere
lo stato dei bit 1 e 9. per le altre direzioni e` un po' piu` complicato.
Infatti, per sapere se la leva del joystick e` spinta verso l'alto bisogna
calcolare l'OR ESCLUSIVO tra il bit 8 e il bit 9 del registro JOY1DAT.
Poiche` questi 2 bit si trovano sullo stesso registro, prima copiamo il
registro in 2 registri dati del 68000, per esempio D2 e D3. Poi SHIFTIAMO
(cioe` facciamo scorrere) verso destra i bit di uno dei 2 registri dati.
In questo modo il bit 9 del registro dati viene spostato nella posizione 8.
Poiche` il registro che abbiamo SHIFTATO conteneva una copia di JOY1DAT,
dopo lo SHIFT il bit 8 del registro dati sara` uguale al bit 9 di JOY1DAT.
Nel registro non SHIFTATO, invece il bit 8 e` uguale al bit 8 di JOY1DAT.
Facendo ora l'EOR tra i due registri, nella posizione 8 ci sara` quindi l'EOR
tra il bit 8 del registro JOY1DAT e il bit 9 del registro JOY1DAT. Proprio
quello che ci serviva per sapere se dobbiamo muovere lo sprite verso l'alto.
Per quanto riguarda il basso si deve calcolare l'OR ESCLUSIVO tra i bit 0 e 1
nello stesso modo che per l'alto.

Potete provare a variare la velocita` dello sprite. Nella routine LeggiJoyst
quando viene rilevato che la leva e` stata spostata in una certa direzione 
viene corrrispondentemente spostato di 1 pixel lo sprite con una ADDQ #1,xxx
(o con una SUBQ #1,xxx) . Se invece di 1 mettete valori maggiori lo sprite
si muovera` piu` velocemente.
