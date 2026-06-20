
; Lezione8m5.s - Routine di stampa di punti (plot), usata in un loop per
;		 calcolare y=a*x*x, ossia delle parabole

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

	bsr.s	CalcolaParabola	; y=a*x*x

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BEQ.S	Aspetta

	btst.b	#6,$bfe001	; mouse premuto?
	bne.s	mouse
Finito:
	btst.b	#6,$bfe001	; mouse premuto?
	bne.s	Finito
	rts			; esci

;	  _       , _
;	 / \ , , /,/'
;	    \\\////
;	    /'';``\
;	   /       \
;	 _/ __  --- \_
;	(/ ___¯ ___  \)
;	/  --- (°  )  \
;	\    /  ¯¯¯   /
;	 \  ( .      /
;	  \_ o  ____/
;	   l____| T
;	      |   |xCz
;	      `---'

;	Y=a*x*x, coeff*d0*d0=d1

CalcolaParabola:
	Addq.W	#1,Miox		; Incrementa la X
	move.w	Miox(PC),d1
	Mulu.w	d1,d1		; x*x
	Mulu.w	Coeff(PC),d1	; y=a*x*x
	lsr.w	#8,d1		; dividi per 256 la Y per "allargare"

	cmp.w	#255,MioY	; siamo sotto lo schermo??
	bhi.s	Riparti		; se si, abbiamo 1 solo schermo!!! ripartiamo
	cmp.w	#319-160,MioX	; siamo all'estrema destra dello schermo??
	ble.s	NonFinito
Riparti:
	addq.w	#1,Coeff	; Aggiungi 1 al coefficiente della parabola
	cmp.w	#6,Coeff	; siamo gia' a Coeff=6
	beq.s	Finito		; Se si, usciamo!
	tst.w	Coeff		; Siamo allo zero?
	bne.s	OkCoeff		; Se no, va bene
	addq.w	#1,Coeff	; altrimenti saltiamo subito ad 1!
OkCoeff:
	move.w	#-160,Miox	; E riparti da X= -160 per la nuova parabola
	rts			; Niente da plottare questa volta.

NonFinito:
	move.w	d1,MioY

; Andiamo a plottare il punto:

	move.w	Miox(PC),d0	; Coord. X
	add.w	#160,d0		; spostati in avanti di 160, dato che calcolo
				; da -160 a +160, che devo normalizzare in
				; cordinate 0 fino 320... in questo modo ho
				; spostato la parabola a destra.
	move.w	Mioy(PC),d1	; Coord  Y
	bsr.s	plotPIX		; stampa il punto alla coord. X=d0, Y=d1

	rts


MioX:
	dc.w	-160	; parto da -160 per "centrare" la parabola.
MioY:
	dc.w	0

Coeff:
	dc.w	-5

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
	lsr.w	#3,d0		; Intanto trova l'offset orizzontale,
				; dividendo per 8 la coordinata X.
	mulu.w	#largschermo,d1
	add.w	d1,d0		; Somma scost. verticale a quello orizzontale

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

	end

In questo listato l'unica modifica e' che usiamo anche coeff negativi.

