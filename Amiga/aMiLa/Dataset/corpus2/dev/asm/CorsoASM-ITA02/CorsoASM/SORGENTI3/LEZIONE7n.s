
; Lezione7n.s - esempio di applicazione della routine universale:
;		uno sprite che rimbalza


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
	cmpi.b	#$aa,$dff006	; Linea $aa?
	bne.s	mouse

	btst	#2,$dff016
	beq.s	aspetta
	bsr.w	MuoviSprite	; Muovi lo sprite 0

Aspetta:
	cmpi.b	#$aa,$dff006	; linea $aa?
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

; Questa routine cambia le coordinate dello sprite aggiungendo una velocita`
; costante sia in verticale che in orizzontale. Inoltre quando lo sprite tocca
; uno dei bordi, la routine provvede a invertire la direzione.
; Per comprendere questa routine occorre sapere che l'istruzione "NEG" serve
; a trasformare un numero positivo in negativo e viceversa.

MuoviSprite:
	move.w	sprite_y(PC),d0	; leggi la vecchia posizione
	add.w	speed_y(PC),d0	; aggiungi la velocita`
	btst	#15,d0		; se il bit 15 e' settato, il numero e'
				; diventato negativo. E' diventato negativo?
	beq.s	no_tocca_sopra	; se >0 va bene
	neg.w	speed_y		; se <0 abbiamo toccato il bordo superiore
				; allora inverti la direzione
	bra.s	Muovisprite	; ricalcola la nuova posizione

no_tocca_sopra:
	cmp.w	#243,d0	; quando la posizione vale 256-13=243, lo sprite
			; tocca il bordo inferiore
	blo.s	no_tocca_sotto
	neg.w	speed_y		; se lo sprite tocca il bordo inferiore,
				; inverti la velocita`
	bra.s	Muovisprite	; ricacola la nuova posizione

no_tocca_sotto:
	move	d0,sprite_y	; aggiorna la posizione
posiz_x:
	move.w	sprite_x(PC),d1	; leggi la vecchia posizione
	add.w	speed_x(PC),d1	; aggiungi la velocita`
	btst	#15,d0		; se il bit 15 e' settato, il numero e'
				; diventato negativo. E' diventato negativo?
	beq.s	no_tocca_sinistra
	neg.w	speed_x		; se <0 tocca a sinistra: inverti la direzione
	bra.s	posiz_x		; ricalcola nuova posizione oriz.

no_tocca_sinistra:
	cmp.w	#304,d1	; quando la posizione vale 320-16=304, lo sprite
			; tocca il bordo destro
	blo.s	no_tocca_destra
	neg.w	speed_x		; se tocca a destra, inverti la direzione
	bra.s	posiz_x		; ricalcola nuova posizione oriz.

no_tocca_destra:
	move.w	d1,sprite_x	; aggiorna la posizione

	lea	miosprite,a1	; indirizzo sprite
	moveq	#13,d2		; altezza sprite
        bsr.s	UniMuoviSprite  ; esegue la routine universale che posiziona
               			; lo sprite
	rts

SPRITE_Y:
		DC.W	10	; posizione sprite
SPRITE_X:
		DC.W	0
SPEED_Y:
		dc.w	-4		; velocita` sprite
SPEED_X:
		dc.w	3

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
	dc.b $50	; Posizione verticale di inizio sprite (da $2c a $f2)
	dc.b $90	; Posizione orizzontale di inizio sprite (da $40 a $d8)
	dc.b $5d	; $50+13=$5d	; posizione verticale di fine sprite
	dc.b $00
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

In questo esempio mostriamo un modo diverso di muovere gli sprite, senza
usare le tabelle.
In qesto esempio il nostro sprite si muove in modo rettilineo, con velocita`
costante sia per la posizione orizzontale, sia per quella verticale.
La velocita` non e` altro che un numero, contenuto in una locazione di memoria,
che viene aggiunto ogni volta alla posizione che lo sprite occupava in
precedenza, calcolando cosi` la nuova posizione.
Se la velocita` e` un numero positivo, aumentera` ogni volta la posizione
dello sprite, spostandolo verso destra (o in basso nel caso Y).
Se la velocita` e` un numero negativo, diminuira` ogni volta la posizione
dello sprite, spostandolo verso sinistra (o in alto nel caso Y).
Quando lo sprite tocca uno dei bordi e` necessario invertire la direzione
in cui si sta` spostando. Per fare cio` e` sufficente cambiare di segno la
velocita`, trasformandola cioe` da positiva in negativa o viceversa.
Di questo si occupa l'istruzione NEG che cambia appunto il segno di un numero
contenuto in un registro o in una locazione di memoria.
