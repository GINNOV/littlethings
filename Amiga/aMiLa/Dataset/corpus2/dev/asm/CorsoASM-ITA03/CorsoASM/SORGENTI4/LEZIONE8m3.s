
; Lezione8m3.s - Routine di stampa di punti (plot), usata in un loop per
;		 calcolare y=x*x, ossia una curva simile a quella prodotta
;		 dalla caduta di un sasso in una frana (parabola!)

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


START:
;	 PUNTIAMO IL NOSTRO BITPLANE

	MOVE.L	#BITPLANE,d0
	LEA	BPLPOINTERS,A1
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

	lea	bitplane,a0	; Indirizzo del bitplane dove stampare

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

	bsr.s	CalcolaPotenza	; y=x*x

	move.w	Miox(PC),d0	; Coord. X
	move.w	Mioy(PC),d1	; Coord  Y

	bsr.s	plotPIX		; stampa il punto alla coord. X=d0, Y=d1

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BEQ.S	Aspetta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
Finito:
	btst	#6,$bfe001	; mouse premuto?
	bne.s	Finito
	rts			; esci

;	 _.--._     _ 
;	|   _ .|   (_)
;	|   \__|   ||
;	|______|   ||
;	.-`--'-.   ||
;	| | |  |\__l|
;	|_| |__|__|_))
;	 ||_| |    ||
;	 |(_) |
;	 |    |
;	 |____|__
;	 |______/g®m

;	Y=x*x, d0*d0=d1

CalcolaPotenza:
	Addq.W	#1,Miox		; Incrementa la X
	move.w	Miox(PC),d1
	Mulu.w	d1,d1		; y=m*x
	lsr.w	#3,d1		; allarghiamo un po' la parabbola
	cmp.w	#255,d1		; siamo in fondo allo schermo??
	blo.s	NonFinito
	bra.s	Finito		; Se si, usciamo!
	addq.w	#1,Coeff	; Aggiungi 1 al coefficiente angolare
	cmp.w	#80,Coeff	; Abbiamo gia' fatto 39 linee?
NonFinito:
	move.w	d1,MioY
	rts

MioX:
	dc.w	0
MioY:
	dc.w	0
Coeff:
	dc.w	1

*****************************************************************************
;			Routine di plot dei punti (dots)
*****************************************************************************

;	Parametri in entrata di PlotPIX:
;
;	a0 = Indirizzo bitplane destinazione
;	d0.w = Coordinata X (0-319)
;	d1.w = Coordinata Y (0-255)

LargSchermo	equ	40	; Larghezza dello schermo in bytes.

PlotPIX:
	move.w	d0,d2		; Copia la coordinata X in d2


; Troviamo l'offset orizzontale, ossia la X

	lsr.w	#3,d0		; Intanto trova l'offset orizzontale,
				; dividendo per 8 la coordinata X. Essendo lo
				; schermo fatto di bits, sappiamo che una
				; linea orizzontale e' larga 320 pixel, ossia
				; 320/8=40 bytes. Avendo la coordinata X che
				; va da 0 a 320, cioe' in bits, la dobbiamo
				; convertire in bytes, dividendola per 8.
				; In questo modo abbiamo il byte entro cui
				; settare il nostro bit.

; Ora troviamo l'offset verticale, ossia la Y:

	mulu.w	#largschermo,d1	; moltiplica la larghezza di una linea per il
				; numero di linee, trovando l'offset
				; verticale dall'inizio dello schermo

; Infine troviamo l'offset dall'inizio dello schermo del byte dove si trova il
; punto (ossia il bit), che setteremo con l'istruzione BSET:

	add.w	d1,d0	; Somma lo scostamento verticale a quello orizzontale

; Ora abbiamo in d0 l'offset, in bytes, dall'inizio dello schermo per trovare
; il byte dove si trova il punto da settare. Abbiamo quindi da scegliere quale
; degli 8 bit del byte va settato.

; Ora troviamo quale bit del byte dobbiamo settare:

	and.w	#%111,d2	; Seleziona solo i primi 3 bit di X, ossia
				; l'offset (scostamento) nel byte,
				; ricavando in d2 il bit da settare
				; (in realta' sarebbe il resto della divisione
				;  per 8, fatta in precedenza)

	not.w	d2		; opportunamente nottato

; Ora abbiamo in d0 l'offset dall'inizio dello schermo per trovare il byte,
; in d2 il numero di bit da settare all'interno di quel bit, e in a0
; l'indirizzo del bitplane. Con una sola istruzione possiamo settare il bit:

	bset.b	d2,(a0,d0.w)	; Setta il bit d2 del byte distante d0 bytes
				; dall'inizio dello schermo.
	rts			; Esci.

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

	end

Con questa variante si puo' ammirare una cosa del genere:

*
 *

  *


   *




    *






      *


Purtroppo lavoriamo solo con i numeri interi, e non sono disponibili i pixel
tra un punto e l'altro, che sono frazionari. Comunque meglio di niente!
Questo tipo di curva e' ottenuto assegnando il valore della y come la
elevazione al quadrato della x. In questo modo abbiamo:

X = 0	-> Y=X*X, ossia 0*0, ossia 0
X = 1	-> Y= 1*1, ossia 1
X = 2	-> Y= 2*2, ossia 4
X = 3	-> Y= 3*3, ossia 9
X = 4	-> Y= 4*4, ossia 16
X = 5	-> Y= 5*5, ossia 25

Esponenzialmente (exp) la Y aumenta rispetto alla X.

