
; Lezione15f2.s		Sprite largo 32 pixel. Usare il tasto destro
;			del mouse per scambiare tra LowRes e HighRes

	SECTION	AgaRulez,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110100000	; copper, bitplane, sprite DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:

;	Puntiamo la PIC "vuota"

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

;	Puntiamo tutti gli sprite allo sprite nullo

	MOVE.L	#SpriteNullo,d0		; indirizzo dello sprite in d0
	LEA	SpritePointers,a1	; Puntatori in copperlist
	MOVEQ	#8-1,d1			; tutti gli 8 sprite
NulLoop:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	addq.w	#8,a1
	dbra	d1,NulLoop

;	Puntiamo lo sprite

	MOVE.L	#MIOSPRITE32,d0		; indirizzo dello sprite in d0
	LEA	SpritePointers,a1	; Puntatori in copperlist
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#CopList,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Fmode azzerato, burst normale
	move.w	#$c00,$106(a5)		; BPLCON3 resettato
	move.w	#$11,$10c(a5)		; BPLCON4 resettato

	move.b	$dff00a,mouse_y
	move.b	$dff00b,mouse_x

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$12000,d2	; linea da aspettare = $120
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $120
	BNE.S	Waity1

	bsr.s	LeggiMouse	; questa legge il mouse
	move.w	sprite_y(pc),d0 ; prepara i parametri per la routine
	move.w	sprite_x(pc),d1 ; universale
	lea	miosprite32,a1	; indirizzo sprite
	moveq	#26,d2		; altezza sprite
	bsr.w	UniMuoviSprite32 ; chiama la routine universale

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$12000,d2	; linea da aspettare = $120
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $120
	BEQ.S	Aspetta

	btst.b	#2,$dff016	; Tasto destro premuto?
	bne.s	NonScambiareRes	; Se no non cambiare risuluzione allo sprite

	bchg.b	#7,BplCon3	; Se si, cambia da LowRes a Hires o viceversa.

NonScambiareRes:
	btst.b	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts

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


; Routine universale di posizionamento degli sprite larghi 32 pixel.

;
;	Parametri in entrata di UniMuoviSprite32:
;
;	a1 = Indirizzo dello sprite
;	d0 = posizione verticale Y dello sprite sullo schermo (0-255)
;	d1 = posizione orizzontale X dello sprite sullo schermo (0-320)
;	d2 = altezza dello sprite
;

UniMuoviSprite32:
; posizionamento verticale
	ADD.W	#$2c,d0		; aggiungi l'offset dell'inizio dello schermo

; a1 contiene l'indirizzo dello sprite
	MOVE.b	d0,(a1)		; copia il byte in VSTART
	btst.l	#8,d0
	beq.s	NonVSTARTSET
	bset.b	#2,3+2(a1)	; Setta il bit 8 di VSTART (numero > $FF)
	bra.s	ToVSTOP
NonVSTARTSET:
	bclr.b	#2,3+2(a1)	; Azzera il bit 8 di VSTART (numero < $FF)
ToVSTOP:
	ADD.w	D2,D0		; Aggiungi l'altezza dello sprite per
				; determinare la posizione finale (VSTOP)
	move.b	d0,2+2(a1)	; Muovi il valore giusto in VSTOP
	btst.l	#8,d0
	beq.s	NonVSTOPSET
	bset.b	#1,3+2(a1)	; Setta il bit 8 di VSTOP (numero > $FF)
	bra.w	VstopFIN
NonVSTOPSET:
	bclr.b	#1,3+2(a1)	; Azzera il bit 8 di VSTOP (numero < $FF)
VstopFIN:

; posizionamento orizzontale
	add.w	#128,D1		; 128 - per centrare lo sprite.
	btst.l	#0,D1		; bit basso della coordinata X azzerato?
	beq.s	BitBassoZERO
	bset.b	#0,3+2(a1)	; Settiamo il bit basso di HSTART
	bra.s	PlaceCoords

BitBassoZERO:
	bclr.b	#0,3+2(a1)	; Azzeriamo il bit basso di HSTART
PlaceCoords:
	lsr.w	#1,D1		; SHIFTIAMO, ossia spostiamo di 1 bit a destra
				; il valore di HSTART, per "trasformarlo" nel
				; valore fa porre nel byte HSTART, senza cioe'
				; il bit basso.
	move.b	D1,1(a1)	; Poniamo il valore XX nel byte HSTART
	rts

;*****************************************************************************
;*				COPPERLIST				     *
;*****************************************************************************

	CNOP	0,8	; Allineo a 64 bit

	section	coppera,data_C

COPLIST:
SpritePointers:
	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0 ; SPRITE
	dc.w	$12a,0,$12c,0,$12e,0,$130,0,$132,0
	dc.w	$134,0,$136,0,$138,0,$13a,0,$13c,0
	dc.w	$13e,0

	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop

	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,-8		; Bpl1Mod (burst 64bit, modulo=modulo-8)
	dc.w	$10a,-8		; Bpl2Mod (come sopra)

		    ; 5432109876543210
	dc.w	$100,%0001001000000001	; 1 bitplane LORES 320x256.

	dc.w	$1fc,%0111	; Burst mode a 64 bit, sprite larghi 32 pixel

; Quest'altro settaggio e' simile. Provatelo se per problemi di DMA non
; funzionasse quello sopra.

;	dc.w	$1fc,%1011	; Burst mode a 64 bit, sprite larghi 32 pixel

BPLPOINTERS:
	dc.w $e0,0,$e2,0	; primo 	bitplane
	dc.w $e4,0,$e6,0	; secondo	   "
	dc.w $e8,0,$ea,0	; terzo		   "
	dc.w $ec,0,$ee,0	; quarto	   "
	dc.w $f0,0,$f2,0	; quinto	   "
	dc.w $f4,0,$f6,0	; sesto		   "
	dc.w $f8,0,$fA,0	; settimo	   "
	dc.w $fC,0,$fE,0	; ottavo	   "

; Da notare che i colori dello sprite sono a 24 bit, anche se sono solo 3.

	DC.W	$106,$c00	; SELEZIONA PALETTE 0 (0-31), NIBBLE ALTI
COLP0:
	dc.w	$180,$000	; color0	; sfondo nero
	dc.w	$182,$123	; color1	; colore 1 del bitplane, che
						; in questo caso e' vuoto,
						; per cui non compare.

	dc.w	$1A2,$F00	; color17, ossia COLOR1 dello sprite0 - ROSSO
	dc.w	$1A4,$0F0	; color18, ossia COLOR2 dello sprite0 - VERDE
	dc.w	$1A6,$FF0	; color19, ossia COLOR3 dello sprite0 - GIALLO


	DC.W	$106,$e00	; SELEZIONA PALETTE 0 (0-31), NIBBLE BASSI
COLP0B:
	dc.w	$180,$000	; color0	; sfondo nero
	dc.w	$182,$000	; color1	; colore 1 del bitplane, che
						; in questo caso e' vuoto,
						; per cui non compare.

	dc.w	$1A2,$462	; color17, nibble bassi
	dc.w	$1A4,$2e4	; color18, nibble bassi
	dc.w	$1A6,$672	; color19, nibble bassi

	dc.w	$106	; BPLCON3
	dc.b	0
BplCon3:
	       ; 76543210
	dc.b	%00000000	; bit 7: sprites hires o lowres. Se si
				; settano sia il bit 7 che il bit 6 lo sprite
				; e' in superhires (1280x256), ma viene troppo
				; "stretto", credo sia inutile, basta hires!

	dc.w	$FFFF,$FFFE	; Fine della copperlist


;*****************************************************************************
;************ Ecco gli sprite: OVVIAMENTE devono essere in CHIP RAM! *********
;*****************************************************************************

	cnop	0,8

SpriteNullo:			; Sprite nullo da puntare in copperlist
	dc.l	0,0,0,0		; negli eventuali puntatori inutilizzati


	cnop	0,8

MIOSPRITE32:		; lunghezza 13*2 linee
VSTART:
	dc.b $50	; Posizione verticale di inizio sprite (da $2c a $f2)
HSTART:
	dc.b $90	; Posizione orizzontale di inizio sprite (da $40 a $d8)
	DC.W 0		; Word "aggiunta" nello sprite largo 32 pixel
VSTOP:
	dc.b $5d	; $50+13=$5d	; posizione verticale di fine sprite
VHBITS:
	dc.b $00	; bit
	DC.W 0		; Word "aggiunta" nello sprite largo 32 pixel

 dc.l	%00000000000000000000000000000000,%00000000011000000000011000000000
 dc.l	%00000000000000000000000000000000,%00000000011100000000111000000000
 dc.l	%00000000000000000000000000000000,%00000000001110000001110000000000
 dc.l	%00000000000000000000000000000000,%00000000000111000011100000000000
 dc.l	%00000000000000000000000000000000,%00000000000011000011000000000000
 dc.l	%00000000000000000000000000000000,%00000000000011100111000000000000
 dc.l	%00000000000000111100000000000000,%00000111000001111110000011100000
 dc.l	%00000000000001111110000000000000,%00001110000001111110000001110000
 dc.l	%00000000000111111111100000000000,%00011100000111111111100000111000
 dc.l	%00000000001111111111110000000000,%00111000001111111111110000011100
 dc.l	%00000000001111111111110000000000,%01110000011001111110011000001110
 dc.l	%00000000011111111111111000000000,%11110000110000111100001100001111
 dc.l	%00000000111100111100111100000000,%11111111110000111100001111111111
 dc.l	%00000000111100111100111100000000,%01111111111000111100011111111110
 dc.l	%00000000011111111111111000000000,%00000000011111111111111000000000
 dc.l	%00000000001111111111110000000000,%00000000111111111111111100000000
 dc.l	%00000000001111111111110000000000,%00000001111110000001111110000000
 dc.l	%00000000000111111111100000000000,%00000011111111000011111111000000
 dc.l	%00000000000011111111000000000000,%00000111110011111111001111100000
 dc.l	%00000000000011111111000000000000,%00001111100011111111000111110000
 dc.l	%00000000000001111110000000000000,%00001111000001111110000011110000
 dc.l	%00000000000000011000000000000000,%00001111000000011000000011110000
 dc.l	%00000000000000000000000000000000,%11111111000000000000000011111111
 dc.l	%00000000000000000000000000000000,%11111111000000000000000011111111
 dc.l	%00000000000000000000000000000000,%11111111000000000000000011111111
 dc.l	%00000000000000000000000000000000,%11111111000000000000000011111111
 dc.l	0,0		; Fine dello sprite (2 longword anziche' 2 word).

; BINARIO 00=COLORE 0 (TRASPARENTE)
; BINARIO 10=COLORE 1 (ROSSO)
; BINARIO 01=COLORE 2 (VERDE)
; BINARIO 11=COLORE 3 (GIALLO)

	cnop	0,8

	SECTION	PLANEVUOTO,BSS_C	; Il bitplane azzerato che usiamo,
					; perche' per vedere gli sprite
					; e' necessario che ci siano bitplanes
					; abilitati
BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

Avete visto che bell'insettone largo 32 pixel?
La routine unimuovisprite e' stata modificata in modo molto semplice.
Infatti i 2 byte VSTOP e VHBITS si sono spostati una word avanti.
Per cui e' bastato sostituire:

	2(a1) e 3(a1)

In:

	2+2(a1) e 3+2(a1)

Niente di piu' facile! (Vi immaginerete come fare UniMuoviSprite 64 pixel!)

