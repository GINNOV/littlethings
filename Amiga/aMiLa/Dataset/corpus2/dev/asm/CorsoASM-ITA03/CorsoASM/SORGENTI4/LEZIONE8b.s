
; Lezione8b.s - Utilizzo della startup universale per un esempio che e'
;		una fusione di Lezione7o.s degli sprite e della routine di
;		print della lezione 6.


	Section	UsoLaStartUp,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; con questo include mi risparmio di
				; riscriverla ogni volta!
*****************************************************************************


; Con DMASET decidiamo quali canali DMA aprire e quali chiudere

		;5432109876543210
DMASET	EQU	%1000001110100000	; copper e bitplane DMA abilitati
;		 -----a-bcdefghij

;	a: Blitter Nasty   (Per ora non ci interessa, lasciamolo a zero)
;	b: Bitplane DMA	   (Se non e' settato, spariscono anche gli sprite)
;	c: Copper DMA	   (Azzerandolo non e' eseguita nemmeno la copperlist)
;	d: Blitter DMA	   (Per ora non ci interessa, azzeriamolo)
;	e: Sprite DMA	   (Azzerandolo spariscono solo gli 8 sprite)
;	f: Disk DMA	   (Per ora non ci interessa, azzeriamolo)
;	g-j: Audio 3-0 DMA (Azzeriamo lasciando muto l'Amiga)

; MAIN PROGRAM - ricordarsi che i canali DMA sono tutti azzerati

START:
;	 PUNTIAMO IL NOSTRO BITPLANE

	MOVE.L	#BITPLANE,d0
	LEA	BPLPOINTERS,A1
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

	MOVE.L	#MIOSPRITE,d0		; indirizzo dello sprite in d0
	LEA	SpritePointers,a1	; Puntatori in copperlist
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	addq.w	#8,a1			; puntatore a sprite 1
	MOVE.L	#MIOSPRITE2,d0		; indirizzo dello sprite in d0
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

	bsr.s	PrintCarattere	; Stampa un carattere alla volta
	bsr.w	MuoviSprite	; Muovi gli sprite 0 ed 1

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BEQ.S	Aspetta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts			; esci

*****************************************************************************
;			Routine di Print
*****************************************************************************

PRINTcarattere:
	MOVE.L	PuntaTESTO(PC),A0 ; Indirizzo del testo da stampare in a0
	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	CMP.B	#$ff,d2		; Segnale di fine testo? ($FF)
	beq.s	FineTesto	; Se si, esci senza stampare
	TST.B	d2		; Segnale di fine riga? ($00)
	bne.s	NonFineRiga	; Se no, non andare a capo

	ADD.L	#40*7,PuntaBITPLANE	; ANDIAMO A CAPO
	ADDQ.L	#1,PuntaTesto		; primo carattere riga dopo
					; (saltiamo lo ZERO)
	move.b	(a0)+,d2		; primo carattere della riga dopo
					; (saltiamo lo ZERO)

NonFineRiga:
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...
	LSL.W	#3,D2		; MOLTIPLICA PER 8 IL NUMERO PRECEDENTE,
				; essendo i caratteri alti 8 pixel
	MOVE.L	D2,A2
	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...

	MOVE.L	PuntaBITPLANE(PC),A3 ; Indir. del bitplane destinazione in a3

				; STAMPIAMO IL CARATTERE LINEA PER LINEA
	MOVE.B	(A2)+,(A3)	; stampa LA LINEA 1 del carattere
	MOVE.B	(A2)+,40(A3)	; stampa LA LINEA 2  " "
	MOVE.B	(A2)+,40*2(A3)	; stampa LA LINEA 3  " "
	MOVE.B	(A2)+,40*3(A3)	; stampa LA LINEA 4  " "
	MOVE.B	(A2)+,40*4(A3)	; stampa LA LINEA 5  " "
	MOVE.B	(A2)+,40*5(A3)	; stampa LA LINEA 6  " "
	MOVE.B	(A2)+,40*6(A3)	; stampa LA LINEA 7  " "
	MOVE.B	(A2)+,40*7(A3)	; stampa LA LINEA 8  " "

	ADDQ.L	#1,PuntaBitplane ; avanziamo di 8 bit (PROSSIMO CARATTERE)
	ADDQ.L	#1,PuntaTesto	; prossimo carattere da stampare

FineTesto:
	RTS


PuntaTesto:
	dc.l	TESTO

PuntaBitplane:
	dc.l	BITPLANE

;	$00 per "fine linea" - $FF per "fine testo"

		; numero caratteri per linea: 40
TESTO:	     ;		  1111111111222222222233333333334
             ;   1234567890123456789012345678901234567890
	dc.b	'                                        ',0 ; 1
	dc.b	'    Questo listato utilizza i canali    ',0 ; 2
	dc.b	'                                        ',0 ; 3
	dc.b	'    DMA del COPPER, dei BITPLANE e      ',0 ; 4
	dc.b	'                                        ',0 ; 5
	dc.b	'    degli SPRITE, provate a non         ',0 ; 6
	dc.b	'                                        ',0 ; 7
	dc.b	'    abilitarli uno ad uno e vedrete     ',0 ; 8
	dc.b	'                                        ',0 ; 9
	dc.b	'    sparire gli sprite, poi il testo    ',0 ; 10
	dc.b	'                                        ',0 ; 11
	dc.b	'    e anche le sfumature del copper!    ',$FF ; 12

	EVEN

*****************************************************************************
;	Routines degli sprite
*****************************************************************************

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

*****************************************************************************

;	Il FONT caratteri 8x8 copiato in CHIP dalla CPU e non dal blitter,
;	per cui puo' stare anche in fast ram. Anzi sarebbe meglio!

FONT:
	incbin	"assembler2:sorgenti4/nice.fnt"

*****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
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
	dc.w	$104,$24	; BplCon2 - Tutti gli sprite sopra i bitplane
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod
		    ; 5432109876543210
	dc.w	$100,%0001001000000000	; 1 bitplane LOWRES 320x256

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;primo	 bitplane

	dc.w	$0180,$000	; color0 - SFONDO
	dc.w	$0182,$19a	; color1 - SCRITTE

	dc.w	$1A2,$F00	; color17, ossia COLOR1 dello sprite0 - ROSSO
	dc.w	$1A4,$0F0	; color18, ossia COLOR2 dello sprite0 - VERDE
	dc.w	$1A6,$FF0	; color19, ossia COLOR3 dello sprite0 - GIALLO

;	Sfumatura copperlist

	dc.w	$5007,$fffe	; WAIT linea $50
	dc.w	$180,$001	; color0
	dc.w	$5207,$fffe	; WAIT linea $52
	dc.w	$180,$002	; color0
	dc.w	$5407,$fffe	; WAIT linea $54
	dc.w	$180,$003	; color0
	dc.w	$5607,$fffe	; WAIT linea $56
	dc.w	$180,$004	; color0
	dc.w	$5807,$fffe	; WAIT linea $58
	dc.w	$180,$005	; color0
	dc.w	$5a07,$fffe	; WAIT linea $5a
	dc.w	$180,$006	; color0
	dc.w	$5c07,$fffe	; WAIT linea $5c
	dc.w	$180,$007	; color0
	dc.w	$5e07,$fffe	; WAIT linea $5e
	dc.w	$180,$008	; color0
	dc.w	$6007,$fffe	; WAIT linea $60
	dc.w	$180,$009	; color0
	dc.w	$6207,$fffe	; WAIT linea $62
	dc.w	$180,$00a	; color0


	dc.w	$FFFF,$FFFE	; Fine della copperlist


; ************ Ecco gli sprite: OVVIAMENTE devono essere in CHIP RAM! ********

SpriteNullo:			; Sprite nullo da puntare in copperlist
	dc.l	0,0,0,0		; negli eventuali puntatori inutilizzati


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


*****************************************************************************

	SECTION	MIOPLANE,BSS_C

BITPLANE:
	ds.b	40*256	; un bitplane lowres 320x256

	end

In questo listato compaiono 2 ottimizzazioni di routines gia' viste.
Una e' quella di cui si parla nella Lezione8, ossia l'attesa della linea
verticale:

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

Vi ricordo che la linea massima che potete attendere e' $138, se attendete
la $139 o oltre la routine si blocca perche' non si verifica mai tale valore.

L'altra ottimizzazione, che forse e' passata inosservata, e' un:

	MULU.W	#8,d2

Che e' stato trasformato in:

	LSL.W	#3,D2		; MOLTIPLICA PER 8 IL NUMERO PRECEDENTE,
				; essendo i caratteri alti 8 pixel

Nella routine di PRINT. Ebbene, spostare a sinistra di 3 bit corrisponde a
moltiplocare per 8, come spostare a sinistra di 1 bit significa moltiplicare
per 2 e spostare a sinistra di 2 bit significa moltiplicare per 4.
Questo e' perche' il binario agevola le moltiplicazioni e le divisioni per
potenze di 2. Vediamo un esempio:

	5 * 8 = 40

Vediamo in binario:

	%00000101 * %00001000 = %00101000

Come vedete il risultato, 40, e' lo stesso del 5, ma con i bit spostati a
sinistra di 3 posizioni. Vedremo in seguito molti di questi stratagemmi per
velocizzare il codice; la cosa piu' importante da ricordare e' che le
moltiplicazioni e le divisioni sono LENTISSIME, per cui toglierle di mezzo
sostituendole con qualcos'altro e' molto utile.

