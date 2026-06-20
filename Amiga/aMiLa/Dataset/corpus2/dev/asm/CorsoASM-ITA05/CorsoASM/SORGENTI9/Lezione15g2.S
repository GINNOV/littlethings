
; Lezione15g2.s		- Scroll AGA dei bitplanes a scatti di 1/4 di pixel,
;			  per un messimo di 64 pixel. I 2 playfield scrollano
;			  indipendentemente in questo esempio.

; NOTA: I 2 bit alti dello scroll, che permettono "scatti" di 16 o di 32 pixel,
; per un massimo di 64 pixel di scroll, funzionano solo se il burst mode e'
; a 64 pixel (settando i 2 bit bassi di FMODE, ossia $dff1fc).

	SECTION	AgaRulez,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110000000	; copper, bitplane DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:

;	Puntiamo la pic AGA (planes pari)

	MOVE.L	#PIC1,d0
	LEA	EVENBPLPT,A1		; BPL POINTERS DEI BITPLANES PARI
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

;	Puntiamo la pic AGA (planes dispari)

	MOVE.L	#PIC2,d0
	LEA	ODDBPLPT,A1	; BPL POINTERS DEI BITPLANES DISPARI
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	bsr.w	MAKEMOVTAB	; Questa semplice routine fa 2 tabelle
				; con valori da 0 a 255, poi di nuovo a 0

	bsr.w	FINESCROLLC	; Questa routine "converte" i valori decimali
				; in valori di scroll per il BPLCON1 AGA

	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#AgaCopList,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Fmode azzerato, burst normale
	move.w	#$c00,$106(a5)		; BPLCON3 resettato
	move.w	#$11,$10c(a5)		; BPLCON4 resettato

LOOP:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$11000,d2	; linea da aspettare = $110
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $110
	BNE.S	Waity1

	BSR.w	WABBLE

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$11000,d2	; linea da aspettare = $110
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $110
	BEQ.S	Aspetta

	BTST	#6,$BFE001
	BNE.S	LOOP
	RTS

******************************************************************************
; Questa routine fa una tabella con valori "decimali" 0-255-0, in due tabelle
; separate, una per il playfield1 e l'altra per il playfield 2.
******************************************************************************

NUMVAL = 255	; Il nuovo bplcon1 puo' andare da 0 a 255, sfruttiamolo!

makemovtab:
	LEA	MOVTAB(PC),A0	; Tab valori playfield 1
	LEA	MOVTAB2(PC),A1	; Tab valori playfield 2
	MOVEQ	#0,D0		; MINIMO PLAYFIELD 1 : 0
	MOVE.L	#NUMVAL,d2	; MINIMO PLAYFIELD 2 : numval
	MOVE.L	#NUMVAL,D1	; MASSIMO : numval
AMTLOOP:
	MOVE.W	D0,(A0)+	; Val playfield 1
	MOVE.W	D2,(A1)+	; Val playfield 2
	ADDQ.L	#1,D0		; aggiungi 1 al val. playfield 1
	SUBQ.L	#1,D2		; togli 1 al val. playfield 2
	CMP.L	D1,D0		; pf1=numval? (allora pf2=zero)
	BNE.S	AMTLOOP		; se non ancora, continua a loopare.
AMTLOOP2:
	MOVE.W	D0,(A0)+	; Val Pf1 - (Da numval a 0)
	MOVE.W	D2,(A1)+	; Val Pf2 - lascia sempre zero... fermo!
	SUBQ.L	#1,D0		; Subba val. Pf1
	BNE.S	AMTLOOP2	; d0=zero? (flag Z) - se non ancora loopa!
	RTS

MOVTAB:
	DCB.W	NUMVAL*2,0	; *2 perche' sono words
MOVTABEND:

MOVTAB2:
	DCB.W	NUMVAL*2,0	; *2 perche' sono words
MOVTAB2END:

******************************************************************************
; Routine che converte da numeri "decimali" a valori per il bplcon1 AGA.
; In pratica scompone il numero a 8 bit posizionando i sui bit secondo lo
; schema del bplcon1 aga:
;
;	15	64 PIXEL SCROLL PF2 (AGA)
;	14 	64 PIXEL SCROLL PF2 (AGA)
;	13 	FINE SCROLL PF2 (AGA SCROLL 35ns 1/4 of pixel)
;	12 	FINE SCROLL PF2
;	11 	64 PIXEL SCROLL PF1 (AGA)
;	10 	64 PIXEL SCROLL PF1 (AGA)
;	09 	FINE SCROLL PF1 (AGA SCROLL 35ns 1/4 of pixel)
;	08	FINE SCROLL PF1
;	07	PF2H3
;	06	PF2H2
;	05	PF2H1
;	04	PF2H0
;	03	PF1H3
;	02	PF1H2
;	01	PF1H1
;	00	PF1H0

******************************************************************************

FINESCROLLC:
	LEA	MOVTAB2(PC),A0		; Tab valori playfield 2
	LEA	MOVTAB(PC),A3		; Tab valori playfield 1
	LEA	CON1VALUES(PC),A1	; Tab destinazione per $DFF002
	LEA	MOVTAB2END(PC),a2	; Fine della tabella
CONVLOOP:
	MOVEQ	#0,D1
	MOVE.W	(A0)+,D1	; VALORE "DECIMALE" PF1 IN D1
	MOVE.W	(A3)+,D5	; VALORE "DECIMALE" PF2 IN D5
	MOVE.W	D1,D2		; COPIA VAL. 1 IN D2
	MOVE.W	d1,d4		; COPIA VAL. 1 IN D4
	MOVE.W	D5,D6		; COPIA VAL. 2 IN D6
;pf1
	AND.W	#%11,D1		; Selez. bits 0-1 (SCROLL 1/4 e 1/2 pixel)
	LSL.W	#8,D1		; Shiftali al posto "giusto": bit 8 e 9
	MOVE.W	D1,D3		; Salva in d3
;pf2
	AND.W	#%11,D5		; Selez. bits 0-1 (SCROLL 1/4 e 1/2 pixel)
	LSL.W	#8,D5		; Shiftali al posto "giusto", in 2 passaggi:
	LSL.W	#4,D5		; in totale shiftati di  12 bit: bit 12 e 13
	OR.W	D5,D3		; Salva in d3
;pf1
	AND.W	#%111100,d2	; Selez. i "vecchi" 4 bit dello scroll ad 1
				; pixel, max 16 pixel.
	LSR.W	#2,d2		; Shiftali al posto giusto: primi 4 bits!
	OR.W	d2,d3		; Salva in d3
;pf2
	MOVE.W	D6,D5
	AND.W	#%111100,d5	; Selez. i "vecchi" 4 bit dello scroll ad 1
				; pixel, max 16 pixel.
	LSL.W	#2,d5		; Shiftali al posto giusto: bits 4,5,6,7
	OR.W	d5,d3		; Salva in d3
;pf1
	AND.W	#%11000000,d4	; Selez. i bit alti: scatti di 16/32 pixel
	LSL.W	#4,d4		; Posto giusto: BITS 10&11 per PF1
	OR.W	D4,d3		; Salva in d3
;pf2
	AND.W	#%11000000,d6	; Selez. i bit alti: scatti di 16/32 pixel
	LSL.W	#8,d6		; Posto giusto: BITS 14&15 per PF2
	OR.W	d6,d3		; add pf2 16 pixel scroll bits to d3

	MOVE.w	D3,(A1)+	; Salva il valore BPLCON1 finale
	CMP.L	a0,a2		; Fine della tabella?
	BNE.S	CONVLOOP	; Se non ancora, continua la conversione!
	RTS

; Tabella con i valori finali per il $dff102 (BPLCON1)

CON1VALUES:
	DCB.W	NUMVAL*2,0
CON1TABEND:

******************************************************************************
; Routine che copia i valori dalla tabella CON1VALUES al bplcon1 in copper.
; Una volta letta tutta la tabella, smette.
******************************************************************************

WABBLE:
	tst.w	FLAGGY			; Abbiamo finito la tabella?
	beq.s	NOWA			; Se si, esci!
	move.l	Con1TabPointer(PC),a0	; Con1TabPointer in a0
	move.w	(a0)+,SCRLVAL		; Copia il valore in copperlist
	cmp.l	#CON1TABEND,a0		; Siamo alla fine della tab?
	bne.s	okay			; Se non ancora, ok
	clr.w	FLAGGY			; Altrimenti segna che abbiamo finito
okay:
	lea	Con1TabPointer(PC),a0	; Con1TabPointer in a0
	addq.l	#2,(a0)			; Vai al prossimo valore
NOWA:
	RTS

FLAGGY:
	dc.w	-1

Con1TabPointer:
	dc.l	CON1VALUES

*************************************************************************
;			COPPERLIST AGA
*************************************************************************

	CNOP	0,8

		Section	MiaCop,data_C

AGACOPLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop

	dc.w	$102		; BplCon1
SCRLVAL:
	dc.w	0		; Val. Bplcon1 - cambiato dalla routine

	dc.w	$104,0		; BplCon2
	dc.w	$108,-8		; Bpl1Mod
	dc.w	$10a,-8		; Bpl2Mod

	dc.w	$1fc,3		; Burst mode 64bit - NOTA: I bit alti del
				; BPLCON1 che permettono lo scroll a scatti
				; di 16 o 32 pixel funzionano solo se il
				; burst e' a 32 o 64 bit, rispettivamente.

EVENBPLPT:
	dc.w $e0,0,$e2,0		;bitplane   0
ODDBPLPT:
	dc.w $e4,0,$e6,0		;bitplane   1

		    ; 5432109876543210
	dc.w	$100,%0010001000000001	; 2 bitplane LOWRES 320x256.

	dc.w	$106,$C00	; Nibble alti
	dc.w	$180,$001	; COLOR 0 REGISTER
	dc.w	$182,$081	; COLOR 1 REGISTER
	dc.w	$184,$aa1	; COLOR 2 REGISTER
	dc.w	$186,$aa1	; COLOR 3 REGISTER
	dc.w	$106,$200	; Nibble bassi
	dc.w	$180,$124	; COLOR 0 REGISTER
	dc.w	$182,$567	; COLOR 1 REGISTER
	dc.w	$184,$413	; COLOR 2 REGISTER
	dc.w	$186,$a83	; COLOR 3 REGISTER

	dc.w	$FFFF,$FFFE	; FineCopperist

*************************************************************************
;			   BITPLANES
*************************************************************************

	CNOP	0,8

PIC1:
	dcb.b	40*256,%00000111
PIC2:
	dcb.b	40*256,%01110000

	END

