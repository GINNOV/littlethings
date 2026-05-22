
; Lezione8n3.s - Routine di stampa di punti (plot), ottimizzata.
;		 Viene usata una tabella per "muovere" un punto. Tasto destro
;		 per far "lasciare la scia" al punto.

	Section	dotta,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; con questo include mi risparmio di
				; riscriverla ogni volta!
*****************************************************************************


; Con DMASET decidiamo quali canali DMA aprire e quali chiudere

		;5432109876543210
DMASET	EQU	%1000001110000000	; copper e bitplane DMA abilitati
;		 -----a-bcdefghij

LargSchermo	equ	40	; Larghezza dello schermo in bytes.

START:
;	 PUNTIAMO IL NOSTRO BITPLANE

	MOVE.L	#BITPLANE,d0
	LEA	BPLPOINTERS,A1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

; PRECALCOLIAMO UNA TABELLA CON I MULTIPLI DI 40, ossia della larghezza dello
; schermo, per evitare di fare una moltiplicazione per ogni plottaggio.

	lea	MulTab,a0	; Indirizzo spazio di 256 words dove scrivere
				; i multipli di 40...
	moveq	#0,d0		; Iniziamo da 0...
	move.w	#256-1,d7	; Numero di multipli di 40 necessari
PreCalcLoop
	move.w	d0,(a0)+	; Salviamo il multiplo attuale
	add.w	#LargSchermo,d0	; aggiungiamo larghschermo, prossimo multiplo
	dbra	d7,PreCalcLoop	; Creiamo tutta la MulTab

; Puntiamo la cop...

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	lea	bitplane,a0	; Indirizzo del bitplane dove stampare in a0
	lea	MulTab,a1	; Indirizzo della tabella con i multipli della
				; largh. schermo precalcolati in a1

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

	bsr.w	LeggiTabelle	; Legge le posizioni X ed Y dalle tabelle

	move.w	MioX(PC),d0	; coordinata X
	move.w	MioY(PC),d1	; coordinata Y

	bsr.w	PlotPIXP	; stampa il punto alla coord. X=d0, Y=d1

	btst	#2,$16(a5)	; tasto destro del mouse premuto?
	beq.s	NonCancellare

	move.w	MioXold(PC),d0	; coordinata X vecchia da cancellare
	move.w	MioYold(PC),d1	; coordinata Y vecchia

	bsr.w	ErasePIXP	; azzera il punto alla coord. X=d0, Y=d1

NonCancellare:
	move.w	MioX(PC),MioXold ; prepara le coord del punto che cancelleremo
	move.w	MioY(PC),MioYold ; dopo

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



MioX:
	dc.w	0
MioY:
	dc.w	0
MioXold:
	dc.w	0
MioYold:
	dc.w	0


*****************************************************************************
;		Routine di plot dei punti (dots) ottimizzata
*****************************************************************************

;	Parametri in entrata di PlotPIXP:
;
;	a0 = Indirizzo bitplane destinazione
;	a1 = Indirizzo della tabella con i multipli di 40 precalcolati
;	d0.w = Coordinata X (0-319)
;	d1.w = Coordinata Y (0-255)

;	    .....
;	  __\ oO/__
;	 / _ \./ _ \
;	/\/|  "  |\/\
;	\ \|_____|/ /
;	 \ \_(_)_| /
;	  \\\     \
;	 /   \/    \
;	 \____\____/
;	(_____\_____)eD
;

PlotPIXP:
	move.w	d0,d2		; Copia la coordinata X in d2
	lsr.w	#3,d0		; Intanto trova l'offset orizzontale,
				; dividendo per 8 la coordinata X.
	add.w	d1,d1		; Moltiplichiamo la Y per 2, trovando l'offset
	add.w	(a1,d1.w),d0	; scostamento verticale + offset orizzontale
	and.w	#%111,d2	; Seleziona solo i primi 3 bit di X (resto)
	not.w	d2		; nottati
	bset.b	d2,(a0,d0.w)	; Setta il bit d2 del byte distante d0 bytes
				; dall'inizio dello schermo.
	rts

; Routine che CANCELLA un pixel. Basta sostituire BCLR a BSET.

ErasePIXP:
	move.w	d0,d2		; Copia la coordinata X in d2
	lsr.w	#3,d0		; Intanto trova l'offset orizzontale,
				; dividendo per 8 la coordinata X.
	add.w	d1,d1		; Moltiplichiamo la Y per 2, trovando l'offset
	add.w	(a1,d1.w),d0	; scostamento verticale + offset orizzontale
	and.w	#%111,d2	; Seleziona solo i primi 3 bit di X (resto)
	not.w	d2		; nottati
	bclr.b	d2,(a0,d0.w)	; azzera il bit d2 del byte distante d0 bytes
				; dall'inizio dello schermo.
	rts

*****************************************************************************

LeggiTabelle:
	move.l	a0,-(SP)	; salva a0 nello stack
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
	move.w	d0,MioY		; salva le coordinate
	move.w	d1,MioX
	move.l	(sp)+,a0	; riprendi a0 dallo stack
	rts


TABYPOINT:
	dc.l	TABY-1		; NOTA: i valori della tabella qua sono bytes
TABXPOINT:
	dc.l	TABX-2		; NOTA: i valori della tabella qua sono word

; Tabella con coordinate Y

TABY:
	incbin	"ycoordinatok.tab"	; 200 valori .B
FINETABY:

; Tabella con coordinate X

TABX:
	incbin	"xcoordinatok.tab"	; 150 valori .W
FINETABX:

*****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:

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
	dc.w	$0182,$1af	; color1 - SCRITTE

	dc.w	$FFFF,$FFFE	; Fine della copperlist


*****************************************************************************

	SECTION	MIOPLANE,BSS_C

BITPLANE:
	ds.b	40*256	; un bitplane lowres 320x256

; Tabella che conterra' i multipli della larghezza dello schermo precalcolati
; per eliminare la moltiplicazione nella routine PlotPIX, aumentando la sua
; velocita'.

	SECTION	Precalc,bss

MulTab:
	ds.w	256

	end

In questo esempio abbiamo semplicemente aggiunto la routine che legge dalle 2
tabelle le cordinate X ed Y, come per gli sprite. Come si puo' vedere e'
utile anche per routines di punti. Facendo tabelle e routines piu' complesse
si possono ottenere onde varie.

