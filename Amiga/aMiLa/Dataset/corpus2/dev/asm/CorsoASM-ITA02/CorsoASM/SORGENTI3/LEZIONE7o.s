
; Lezione7o.s - esempio di applicazione della routine universale:
;		due sprite mossi dalla stessa routine


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

	addq.l	#8,a1			; puntatore a sprite 1
	MOVE.L	#MIOSPRITE2,d0		; indirizzo dello sprite in d0
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


; Questa routine legge dalle 2 tabelle le coordinate reali degli sprite.
; Cioe` la coordinata X varia da 0 a 320 e la Y da 0 a 256 (senza overscan).
; Poiche` in questo esempio non usiamo l'overscan, la tabella delle coordinate
; Y e` una tabella di byte. La tabella delle coordinate X, invece e` fatta
; di word perche` deve contenere anche valori maggiori di 256.
; Questa routine, pero` non posiziona direttamente lo sprite. Essa si limita
; semplicemente a farlo fare alla routine universale, comunicandogli le
; coordinate tramite i registri d0 e d1

MuoviSprite:
	ADDQ.L	#1,TABYPOINT	 ; Fai puntare al byte successivo
	MOVE.L	TABYPOINT(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABY-1,A0  ; Siamo all'ultimo byte della TAB?
	BNE.S	NOBSTARTY	; non ancora? allora continua
	MOVE.L	#TABY-1,TABYPOINT ; Riparti a puntare dal primo byte
NOBSTARTY:
	moveq	#0,d0		; Pulisci d0
	MOVE.b	(A0),d0		; copia il byte della tabella, cioe` la
				; coordinata Y in d0 in modo da farla
				; trovare alla routine universale

	ADDQ.L	#2,TABXPOINT	 ; Fai puntare alla word successiva
	MOVE.L	TABXPOINT(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABX-2,A0  ; Siamo all'ultima word della TAB?
	BNE.S	NOBSTARTX	; non ancora? allora continua
	MOVE.L	#TABX-2,TABXPOINT ; Riparti a puntare dalla prima word-2
NOBSTARTX:
	moveq	#0,d1		; azzeriamo d1
	MOVE.w	(A0),d1		; poniamo il valore della tabella, cioe`
				; la coordinata X in d1

	lea	MIOSPRITE,a1	; indirizzo dello sprite in A1
	moveq	#13,d2		; altezza dello sprite in d2

	bsr.w	UniMuoviSprite  ; esegue la routine universale che posiziona
				; lo sprite
; secondo sprite

	ADDQ.L	#1,TABYPOINT2	 ; Fai puntare al byte successivo
	MOVE.L	TABYPOINT2(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABY-1,A0  ; Siamo all'ultimo byte della TAB?
	BNE.S	NOBSTARTY2	; non ancora? allora continua
	MOVE.L	#TABY-1,TABYPOINT2 ; Riparti a puntare dal primo byte
NOBSTARTY2:
	moveq	#0,d0		; Pulisci d0
	MOVE.b	(A0),d0		; copia il byte della tabella, cioe` la
				; coordinata Y in d0 in modo da farla
				; trovare alla routine universale

	ADDQ.L	#2,TABXPOINT2	 ; Fai puntare alla word successiva
	MOVE.L	TABXPOINT2(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABX-2,A0  ; Siamo all'ultima word della TAB?
	BNE.S	NOBSTARTX2	; non ancora? allora continua
	MOVE.L	#TABX-2,TABXPOINT2 ; Riparti a puntare dalla prima word-2
NOBSTARTX2:
	moveq	#0,d1		; azzeriamo d1
	MOVE.w	(A0),d1		; poniamo il valore della tabella, cioe`
				; la coordinata X in d1

	lea	MIOSPRITE2,a1	; indirizzo dello sprite in A1
	moveq	#8,d2		; altezza dello sprite in d2

	bsr.w	UniMuoviSprite  ; esegue la routine universale che posiziona
				; lo sprite
	rts

; puntatori alle tabelle del primo sprite

TABYPOINT:
	dc.l	TABY-1
TABXPOINT:
	dc.l	TABX-2

; puntatori alle tabelle del secondo sprite

TABYPOINT2:
	dc.l	TABY+40-1
TABXPOINT2:
	dc.l	TABX+96-2

; Tabella con coordinate Y dello sprite precalcolate.
TABY:
	incbin	"ycoordinatok.tab"	; 200 valori .B
FINETABY:

; Tabella con coordinate X dello sprite precalcolate.
TABX:
	incbin	"xcoordinatok.tab"	; 150 valori .W
FINETABX:

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


MIOSPRITE2:		; lunghezza 8 linee
VSTART2:
	dc.b $60	; Pos. verticale (da $2c a $f2)
HSTART2:
	dc.b $60+(14*2)	; Pos. orizzontale (da $40 a $d8)
VSTOP2:
	dc.b $68	; $60+8=$68	; fine verticale.
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111000111001111
 dc.w	%0011111111111100,%1100001000100011
 dc.w	%0111111111111110,%1000000000100001
 dc.w	%0111111111111110,%1000000111000001
 dc.w	%0011111111111100,%1100001000000011
 dc.w	%0000111111110000,%1111001111101111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; fine sprite


	SECTION	PLANEVUOTO,BSS_C	; Il bitplane azzerato che usiamo,
					; perche' per vedere gli sprite
					; e' necessario che ci siano bitplanes
					; abilitati
BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

In questo esempio mostriamo la versatilita` della routine UniMuoviSprite.
Abbiamo 2 sprites di forma e altezza diversa, ed entrambi sono mossi sullo 
schermo dalla routine. Infatti la routine Muovisprite, legge dalle tabelle le
coordinate degli sprites, e poi chiama per ognuno degli sprite la routine
UniMuoviSprite. Notate come ogni volta la routine MuoviSprite metta nel
registro a1 l'indirizzo dello sprite (che e` ovviamente diverso per i 2
sprites). Poiche` inoltre i 2 sprite hanno altezze diverse, prima di chiamare
UnMuoviSprite ogni volta viene messo in d2 un valore diverso, cioe` quello
dell'altezza di ciascun sprite.
