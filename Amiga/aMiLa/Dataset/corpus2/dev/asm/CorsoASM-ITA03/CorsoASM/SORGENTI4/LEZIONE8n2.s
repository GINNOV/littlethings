
; Lezione8n2.s - Routine di stampa di punti (plot), ottimizzata. Viene testata
;		 la velocita' di questa routine al confronto con quella
;		 non ottimizzata. Premere il tasto DESTRO del mouse per
;		 far agire la routine ottimizzata, altrimenti agisce quella
;		 normale.

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
	bsr.s	Coordinate	; loop delle coordinate per l'intero schermo
	move.w	MioX(PC),d0	; coordinata X
	move.w	MioY(PC),d1	; coordinata Y

	btst	#2,$16(a5)	; tsato destro del mouse premuto?
	beq.s	Ottimizzata
	btst.b	#1,FaiSfai	; Azzerare o Settare?
	bne.s	Sfai
	bsr.s	PlotPIX		; stampa il punto alla coord. X=d0, Y=d1
	bra.s	OkPlottato
Sfai:
	bsr.s	ErasePIX	; azzera il punto alla coord. X=d0, Y=d1
	bra.s	OkPlottato

Ottimizzata:
	btst.b	#1,FaiSfai	; Azzerare o Settare?
	bne.s	SfaiP
	bsr.w	PlotPIXP	; stampa il punto alla coord. X=d0, Y=d1
	bra.s	OkPlottato
SfaiP:
	bsr.w	ErasePIXP	; azzera il punto alla coord. X=d0, Y=d1
OkPlottato:
	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts			; esci



MioX:
	dc.w	0
MioY:
	dc.w	0
FaiSfai:
	dc.w	0

;		    ___
;		   /_ -\
;		  ( ¢ ¢ )
;		   \ ° /
;		  /¯\¬/¯\
;		 /   Y   ·
;		·    `

; Routinetta che fa stampare e cancellare continuamente tutti lo schermo un
; punto per volta.

Coordinate:
	addq.w	#1,MioX		; prossimo pixel sulla linea
	cmp.w	#320,MioX	; ultimo pixel di questa linea?
	beq.s	FinitoLinea	; se si, cominciamo quella sotto!
	rts			; altrimenti, facciamo questo punto!

FinitoLinea:
	clr.w	MioX		; ripartiamo dall'inizio della riga
	addq.w	#1,MioY		; alla riga sotto...
	cmp.w	#256,MioY	; Abbiamo finito la schermata? Ultima riga?
	beq.s	Cambiariparti
	rts

CambiaRiparti:
	bchg.b	#1,FaiSfai	; Cambia lo stato di scrittura/cancellazione
	clr.w	MioX		; e riparti da coordinata X=0
	clr.w	MioY		; Y=0
	rts

*****************************************************************************
;		Routine di plot dei punti (dots) normale
*****************************************************************************

;	Parametri in entrata di PlotPIX:
;
;	a0 = Indirizzo bitplane destinazione
;	d0.w = Coordinata X (0-319)
;	d1.w = Coordinata Y (0-255)


PlotPIX:
	move.w	d0,d2		; Copia la coordinata X in d2
	lsr.w	#3,d0		; Intanto trova l'offset orizzontale,
				; dividendo per 8 la coordinata X.
	mulu.w	#largschermo,d1
	add.w	d1,d0		; Somma scost. verticale a quello orizzontale

	and.w	#%111,d2	; Seleziona solo i primi 3 bit di X (resto)
	not.w	d2

	bset.b	d2,(a0,d0.w)	; Setta il bit d2 del byte distante d0 bytes
				; dall'inizio dello schermo.
	rts

; Routine che CANCELLA un pixel. Basta sostituire BCLR a BSET.

ErasePIX:
	move.w	d0,d2		; Copia la coordinata X in d2
	lsr.w	#3,d0		; Intanto trova l'offset orizzontale,
				; dividendo per 8 la coordinata X.
	mulu.w	#largschermo,d1
	add.w	d1,d0		; Somma scost. verticale a quello orizzontale

	and.w	#%111,d2	; Seleziona solo i primi 3 bit di X (resto)
	not.w	d2

	bclr.b	d2,(a0,d0.w)	; Azzera il bit d2 del byte distante d0 bytes
				; dall'inizio dello schermo.
	rts

*****************************************************************************
;		Routine di plot dei punti (dots) ottimizzata
*****************************************************************************

;	Parametri in entrata di PlotPIXP:
;
;	a0 = Indirizzo bitplane destinazione
;	a1 = Indirizzo della tabella con i multipli di 40 precalcolati
;	d0.w = Coordinata X (0-319)
;	d1.w = Coordinata Y (0-255)

PlotPIXP:
	move.w	d0,d2		; Copia la coordinata X in d2
	lsr.w	#3,d0		; Intanto trova l'offset orizzontale,
				; dividendo per 8 la coordinata X.
	add.w	d1,d1		; Moltiplichiamo la Y per 2, trovando l'offset
	add.w	(a1,d1.w),d0	; scostamento verticale + offset orizzontale
	and.w	#%111,d2	; Seleziona solo i primi 3 bit di X
	not.w	d2		; nottati
	bset	d2,(a0,d0.w)	; Setta il bit d2 del byte distante d0 bytes
				; dall'inizio dello schermo.
	rts

; Routine che CANCELLA un pixel. Basta sostituire BCLR a BSET.

ErasePIXP:
	move.w	d0,d2		; Copia la coordinata X in d2
	lsr.w	#3,d0		; Intanto trova l'offset orizzontale,
				; dividendo per 8 la coordinata X.
	add.w	d1,d1		; Moltiplichiamo la Y per 2, trovando l'offset
	add.w	(a1,d1.w),d0	; scostamento verticale + offset orizzontale
	and.w	#%111,d2	; Seleziona solo i primi 3 bit di X
	not.w	d2		; nottati
	bclr	d2,(a0,d0.w)	; azzera il bit d2 del byte distante d0 bytes
				; dall'inizio dello schermo.
	rts

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

Questo listato vuole essere un test per verificare se veramente la routine
senza moltiplicazione va piu' veloce. A questo scopo viene disegnato tutto lo
schermo e ricancellato con degli "ErasePIX" che non sono altro che la routine
normale con BCLR al posto di BSET. Normalmente viene eseguita la routine non
ottimizzata, tenendo premuto il tasto destro si esegue quella ottimizzata.
A seconda dei computer e della presenza della fast ram la fisserenza sara'
diversa. Per esempio se la tabella va in CHIP ram anziche' in FAST RAM la
valocita' acquistata e' minore. Per esempio, sul 68040 le moltiplicazioni sono
molto velocizzate rispetto ai precedenti processori, al punto che se si
esegue questo listato senza fastram e con le caches disattivate e' piu' lenta
la routine senza moltiplicazione, dato che deve accedere alla tabella in CHIP
RAM. Comunque chi ha A4000 ha anche la fast ram, tranquilli, inoltre su 68030
o inferiori togliere una moltiplicazione e' sempre una buona azione.

