
; Lezione skip3
;		Tasto sinistro per uscire.

	SECTION	bau,code

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; copper,bitplane,blitter DMA

Waitdisk	EQU	10

START:

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	move.l	#copperloop,$84(a5)	; carica l'indirizzo del loop
					; in COP2LC

mouse:
	bsr.s	CambiaCopper

; notare il doppio controllo sulla sincronia
; necessario perche` la muovicopper richiede MENO di UNA rasterline su 68020+

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la fine della linea $130 (304)
	BEQ.S	Waity2

	btst	#6,$bfe001		; tasto sinistro del mouse premuto?
	bne.s	mouse			; se no, torna a mouse:
	rts

*****************************************************************************
* Questa routine cicla i colori nella copperlist
*****************************************************************************

CambiaCopper:
	add.w	#$010,verde	; aumenta luminosita`
	and.w	#$0f0,verde	; evita il riporto sulla componente rossa

	add.w	#$111,bianco	; aumenta luminosita`
	cmp.w	#$fff,bianco	; evita il riporto
	bls.s	no_reset
	move.w	#$000,bianco	; ricomincia dal nero
no_reset

	add.w	#$100,rosso	; aumenta luminosita`
	and.w	#$f00,rosso	; evita il riporto

	rts

*****************************************************************************

	SECTION	MY_COPPER,CODE_C

COPPERLIST:

; barra 1
	dc.l $01800111
	dc.l $2901fffe
	dc.l $01800a0a
	dc.l $2a01fffe
	dc.l $0180011f
	dc.l $2b01fffe
	dc.l $01800000

	dc.w	$9007,$FFFE	; aspetta la linea $30

copperloop:			; da qui inizia il loop
	dc.w	$180
verde:	dc.w	$080		; colore verde

	dc.w	$806b,$00fe	; aspetta primo terzo di schermo
	dc.w	$180
bianco	dc.w	$888		; bianco

	dc.w	$80a5,$00fe	; aspetta secondo terzo di schermo

	dc.w	$180
rosso	dc.w	$800	; rosso

	dc.w	$80e1,$00FE	; aspetta la fine della riga

	dc.w	$e001,$ff01	; SKIP alla linea $60
	dc.w	$8a,0		; scrive in COPJMP2 - salta ad inizio loop

	dc.w	$180,$000
	dc.w $FFDF,$FFFE	; aspetta la linea 255

; barra 2
	dc.l $01800000
	dc.l $1401fffe
	dc.l $0180011f
	dc.l $1501fffe
	dc.l $01800a0a
	dc.l $1601fffe
	dc.l $01800111

	dc.w	$FFFF,$FFFE	; Fine della copperlist

	end

Questo esempio mostra un uso dei copperloop.
Vogliamo cambiare il COLOR0 3 volte all'interno di una riga di raster e
vogliamo ripetere gli stessi colori ad ogni riga. E` molto comodo usare
un copperloop. Le wait all'interno del loop hanno le posizioni verticali
mascherate, in modo da funzionare ad ogni riga di raster.
Per cambiare i colori, e` necessario modificare 3 sole istruzioni copper.
Se non usasassimo il copperloop dovremmo ripetere le 3 modifiche per ogni riga
di raster. Poiche` l'effetto va dalla riga $90 alla $e0, in totale abbiamo
$e0-$90=$50=80 righe di raster.
Grazie al copperloop andiamo 80 volte piu` veloci!!!

