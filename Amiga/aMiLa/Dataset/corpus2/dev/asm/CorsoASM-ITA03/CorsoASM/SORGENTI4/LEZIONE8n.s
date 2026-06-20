
; Lezione8n.s - Routine di stampa di punti (plot), ottimizzata precalcolando
;		i multipli di 40 in una tabella, rimuovendo la moltiplicazione
;		nella routine PlotPix, che si prende il valore giusto dalla
;		tabella ogni volta.

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

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

	move.w	#160,d0		; coordinata X
	move.w	#128,d1		; coordinata Y
	lea	bitplane,a0	; Indirizzo del bitplane dove stampare in a0
	lea	MulTab,a1	; Indirizzo della tabella con i multipli della
				; largh. schermo precalcolati in a1

	bsr.s	PlotPIXP	; stampa il punto alla coord. X=d0, Y=d1

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
;		Routine di plot dei punti (dots) ottimizzata
*****************************************************************************

;	Parametri in entrata di PlotPIXP:
;
;	a0 = Indirizzo bitplane destinazione
;	a1 = Indirizzo della tabella con i multipli di 40 precalcolati
;	d0.w = Coordinata X (0-319)
;	d1.w = Coordinata Y (0-255)

;	       ________________
;	 _____/                \_____  __  _
;	|   _/                  \_   ||  || |
;	|   \  ______    ______  /   ||  || |
;	|   _\ \  ___\  /___  / /_   ||  || |
;	|   /¯  \/   `  `   \/  ¯\   ||  || |
;	|   ¯\_     /|  |\     _/¯   ||  || |
;	|      \    ¯¯  ¯¯    /zO!   ||  || |
;	|       \_.--.--.--._/       ||  || |
;	`        `|  |  |  |`        ||  || |
;	__/\__    |  |  |  |         ||  || |
;	\ +O /    |  |  |  |         ||  || |
;	/ --_\    |  |  |  |         ||  || |
;	¯¯\/_ ____|  |  |  |_________||__||_|
;	          `--`--`--`

PlotPIXP:
	move.w	d0,d2		; Copia la coordinata X in d2
	lsr.w	#3,d0		; Intanto trova l'offset orizzontale,
				; dividendo per 8 la coordinata X.

; ** INIZIO MODIFICA: ecco le 2 istruzioni originali:
;
;	mulu.w	#largschermo,d1
;	add.w	d1,d0		; Somma scost. verticale a quello orizzontale
;
; e quelle senza MULU:

; Ora troviamo l'offset verticale, ossia la Y, prendendo il giusto valore
; precalcolato dalla tabella Multab, il cui indirizzo e' in a1

	add.w	d1,d1		; Moltiplichiamo la Y per 2, trovando l'offset
				; dalla tabella dei multipli, infatti ogni
				; multiplo e' una word, ossia 2 bytes. Ora, se
				; per esempio la coordinata era 0, prendiamo
				; il primo valore della tabella, che e' zero.
				; Se e' 3, allora prendiamo il terzo valore
				; della tabella, che pero' si trova al sesto
				; byte, dato che dobbiamo saltare 2 bytes, 1
				; word, per ogni valore in tabella.
	add.w	(a1,d1.w),d0	; Aggiungiamo lo scostamento verticale giusto,
				; preso dalla tabella, all'offset orizzontale

; ** FINE DELLA MODIFICA

	and.w	#%111,d2	; Seleziona solo i primi 3 bit di X (resto)
	not.w	d2

	bset.b	d2,(a0,d0.w)	; Setta il bit d2 del byte distante d0 bytes
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

Con questo listato facciamo una piccola introduzione alla lezione sulle
ottimizzazioni, infatti "TABELLIAMO" una moltiplicazione. Questa operazione e'
molto frequente nel codice delle piu' veloci demo o nei giochi 3d.
La nostra routine di stampa di un pixel funziona egregiamente, ma contiene una
LENTISSIMA moltiplicazione. dobbiamo toglierla assolutamente. Non essendo una
moltiplicazione per una potenza di 2, non possiamo sostituirlo con un LSL come
abbiamo furbescamente fatto nella routine di print in Lezione8b.s.
Ma le vie del coding sono infinite. Considerate la situazione che abbiamo:

	mulu.w	#largschermo,d1
	add.w	d1,d0		; Somma scost. verticale a quello orizzontale

Larghschermo in questo caso e' 40. In d1 abbiamo ogni volta un valore diverso,
a seconda della Y, ma sappiamo che puo' andare da 0 a 255 come massimo.
Dunque ci sono 256 risultati possibili, a seconda che capiti uno dei 256
possibili valori di Y, ossia di d1. Questi 256 risultati, se dassimo ogni
volta in entrata un numero crescende da 0 a 245 sarebbe:

0,40,80,120,160,200	ossia	40*0,40*1,40*2,40*3,40*4....

Immaginiamo di "prepararci" tutti questi 256 risultati possibili in uno spazio
azzerato preventivamente preparato:

MulTab:
	ds.w	256

Per creare la tabella dei multipli di 40 basta un semplicissimo loop:

	lea	MulTab,a0	; Indirizzo spazio di 256 words dove scrivere
				; i multipli di 40...
	moveq	#0,d0		; Iniziamo da 0...
	move.w	#256-1,d7	; Numero di multipli di 40 necessari
PreCalcLoop
	move.w	d0,(a0)+	; Salviamo il multiplo attuale
	add.w	#LargSchermo,d0	; aggiungiamo larghschermo, prossimo multiplo
	dbra	d7,PreCalcLoop	; Creiamo tutta la MulTab

Ora abbiamo la tabella coi "risultati" pronti. Ma come facciamo a "prendere"
dalla tabella il risultato giusto ogni volta? In entrata abbiamo la coordinata
Y, ossia un numero da 0 a 255. Se Y e' zero, basta prendere il primo valore
della tabella, ossia la word $0000. Se invece fosse y=1, dobbiamo prendere il
secondo valore della tabella, che pero' si trova a 2 bytes dal suo inizio,
dato che i sui valori sono words. Allo stesso modo, se volessimo prendere il
risultato giusto per la coord. Y = 50, il risultato sarebbe la cinquantesima
word della tabella, ad una distanza cioe' di 100 bytes. tutto cio' non vi
suggerisce la soluzione? Per calcolare l'offset, ossia la distanza dall'inizio
della tabella, basta moltiplicare per 2 la Y! E siccome si puo' moltiplicare
per 2 con un:

 	add.w	d1,d1

Siamo sempre senza moltiplicazioni. Ora in d1 abbiamo l'offset dall'inizio
della tabella; dobbiamo "prenderlo" e aggiungerlo a d0. Questo si puo' fare
con un'unica operazione:

	add.w	(a1,d1.w),d0	; Aggiungiamo lo scostamento verticale giusto,
				; preso dalla tabella, all'offset orizzontale

Avendo in a1 l'indirizzo della tabella MulTab.

Troveremo questo sistema di "tabellaggio" sempre piu' spesso nei listati
che svolgono molti calcoli.

