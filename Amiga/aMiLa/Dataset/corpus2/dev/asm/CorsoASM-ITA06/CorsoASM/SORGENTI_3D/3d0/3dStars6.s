
; Lezione

; stelle "3d" privenienti dal "centro" in 2 bitplanes

	Section	stellucce,code

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; salva interrupt, dma eccetera.
*****************************************************************************


; Con DMASET decidiamo quali canali DMA aprire e quali chiudere

		;5432109876543210
DMASET	EQU	%1000001110000000	; copper e bitplane DMA abilitati

WaitDisk	equ	30

START:

; Puntiamo la PIC

	MOVE.L	#MioBuf,d0
	LEA	BPLPOINTERS,A1
	MOVEQ	#2-1,D1			; num di bitplanes
POINTBT:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#320*40,d0		; lunghezza del bitplane
	addq.w	#8,a1
	dbra	d1,POINTBT	; Rifai D1 volte (D1=num do bitplanes)

	bsr.s	star_init	; Genera le stelle a caso

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

	movem.l	d0-d7/a0-a7,-(SP)
	bsr.s	stars		; Stelle "3d".
	movem.l	(SP)+,d0-d7/a0-a7

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BEQ.S	Aspetta

	btst	#6,$bfe001	; Mouse premuto?
	bne.s	mouse
	rts			; esci


******************************************************************************
*		Routine che genera le stelle casuali
******************************************************************************

star_init:			;genera stelle random (casuali)
	moveq	#70-1,D3	; 70 stelle
	lea	ran_tab(PC),A0
ran_loop:
	bsr.w	get_ran		; Prendi un valore casuale
	add.w	#4008,d0	; AGGIUNGI 4008
	MOVE.W	D0,(A0)+	; Salva il valore nella tabella ran_tab
	BSR.w	get_ran		; Prendi un'altro valore casuale
	add.w	#4008,d0	; aggiungi 4008
	MOVE.W	D0,(A0)+	; Salva
	BSR.w	get_ran		; Prendi il valore casuale
	AND.W	#$1FF,D0	; Servono solo i primi 9 bit (max 511)
	MOVE.W	D0,(A0)+	; Salva
	DBRA	D3,ran_loop
	rts		

; ogni stella e' composta da 3 valori .word.

stars:
	lea	ran_tab(PC),A4	; randomtab in a4	
	MOVEQ	#70,D3		; 70 stelle
	lea	ran2_tab(PC),A5	; nuova randomtab in a5
star_loop:
	MOVE.W	(A4)+,D4	; valore 1 in d4
 	MOVE.W	(A4)+,D5	; valore 2 in d5
 	MOVE.W	(A4),D6		; valore 3 in d6
	SUBQ.W	#2,(A4)+	; subba di 2 il val 3 precedente, e vai avanti
	TST.W	D6		; D6 = 0?
	BLE.w	routMioran	; Allora stella "finita", arrivata.. new cas.
	EXT.L	D4		; d4 -> longword
	DIVS.w	D6,D4		; dividere d4/d6 ( val. orizzontale)
	ADD.W	#160,D4		; +160 = centro
	EXT.L	D5		; estensione di d5
	DIVS.w	D6,D5		; divisione val. verticale
	ADD.W	#128,D5		; +128 = centro
	TST.W	D4		; d4 = 0?
	BLT.w	routMioran	; Allora, nuovo valore casuale!
	TST.W	D5		; d5 = 0?
	BLT.w	routMioran	; Allora nuovo val. casuale
	CMP.W	#319,D4		; raggiunta la fine orizzontale? (320*)
	BGT.w	routMioran	; Nuovo random..
	CMP.W	#255,D5		; raggiunta la fine verticale? (*256)
	BGT.w	routMioran	; Allora new random
	MOVE.W	(A5),D0		; a5 (newtab val1) in d0
	MOVE.W	D4,(A5)+	; d4 copiato in newtab val1
	MOVE.W	(A5),D1		; a5 (newtab val2) in d1
	MOVE.W	d5,(A5)+	; d5 copiato in newtab val2
	BSR.w	CacellaStella	; Cacella Stella!
	MOVE.W	D4,D0		; d4 in d0 = x
	MOVE.W	D5,D1		; d5 in d1 = y
	MULU.w	#40,D1		; Y * larghezza schermo
	MOVE.W	D0,D2		; d0 in d2
	ASR.W	#3,D2		; dividi per 8
	ADD.W	D2,D1		; aggiungi a offset Y*larghezzaschermo
	ASL.W	#3,D2		; rimoltiplica per 8
	SUB.W	D0,D2		; subbagli x (mi sa che e' l'errore?)
	SUBQ.B	#1,D2		; meno 1
	CMP.W	#350,D6		; d6 = 400 (distanza)
	BGT.S	PlotColore1	; se maggiore > colore1
	CMP.W	#250,D6		; d6 = 300 (distanza)
	BGT.S	PlotColore2	; se maggiore colore2
	BRA.S	PlotColore3	; altrimenti colore3

; Stampa il punto col colore1, plottando solo nel plane1

PlotColore1:
	lea	MioBuf,A1	; plane1
	ADDA.L	D1,A1
	BSET.b	D2,(A1)		; stampa il punto
	DBRA	D3,star_loop
	RTS

; Stampa il punto col colore2, plottando solo nel plane2

PlotColore2:
	lea	MioBuf2,A1	; plane2
	ADDA.L	D1,A1
	BSET	D2,(A1)		; stampa il punto
	DBRA	D3,star_loop
	RTS

; Stampa il punto col colore3, plottando nei plane1 e plane2

PlotColore3:
	lea	MioBuf,A1	; plane1
	ADDA.L	D1,A1
	BSET	D2,(A1)		; stampa il punto
	lea	MioBuf2,A1	; plane2
	ADDA.L	D1,A1
	BSET	D2,(A1)		; spampa il punto
	DBRA	D3,star_loop
	RTS

ran_pointer:	dc.w	0

; Routone che genera valori casuali tramite $dff006 (VHPOSR).

get_ran:
	move.w	$dff006,d0	; VHPOSR - posizione sempre diversa!
	LEA	RandomMult(PC),A3
	MULS.w	(A3),D0
	ADDI.W	#$1249,D0
	EXT.L	D0
	LEA	RandomMult(PC),A3
	MOVE.W	D0,(A3)
 	RTS

routMioran:
	SUBA.L #6,A4
	BSR get_ran
 	MOVE.W D0,(A4)+
 	BSR get_ran
 	MOVE.W D0,(A4)+
 	BSR get_ran
	and.w	#600,d0	 
	MOVE.W d0,(A4)+
	DBRA	D3,star_loop
	RTS

CacellaStella:
	MULU.w	#40,D1		; Y * larghezza dello schermo
 	MOVE.W	D0,D2		; X in d2
 	ASR.W	#3,D2		; diviso 8
 	ADD.W	D2,D1		; somma per offset
 	ASL.W	#3,D2		; rimoltiplica per 8
 	SUB.W	D0,D2		; subbaci X
 	SUBQ.B	#1,D2		; subbaci 1
 	lea	MioBuf,A1
 	ADDA.L	D1,A1		; + offset per trovare il byte giusto
 	BCLR.b	D2,(A1)		; cancella il punto nel plane1
 	lea	MioBuf2,A1
 	ADDA.L	D1,A1		; + offset per trovare il byte giusto
 	BCLR	D2,(A1)		; cancella il punto nel plane2
 	RTS

RandomMult:
	dc.w	0
	dc.w	0

ran_tab:
	dcb.w	210,0
ran2_tab:
	dcb.w	210,0


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

BPLPOINTERS:
	dc.w $e0,0,$e2,0		;primo 	 bitplane
	dc.w $e4,0,$e6,0		;secondo    "

	dc.w	$100,$2200	; BPLCON0 - 2 bitplanes lowres

	dc.w	$180,$000	; COLOR0
	dc.w	$182,$555	; COLOR1
	dc.w	$184,$aaa	; COLOR2
	dc.w	$186,$fff	; COLOR3

	dc.w	$FFFF,$FFFE	; Fine della copperlist

******************************************************************************

	Section	Bitplanebuf,bss_C

; 2 bitplanes 320*256

Miobuf:
	ds.b	320*40		; bitplane 320*256
Miobuf2:
	ds.b	320*40		; bitplane 320*256

	end

