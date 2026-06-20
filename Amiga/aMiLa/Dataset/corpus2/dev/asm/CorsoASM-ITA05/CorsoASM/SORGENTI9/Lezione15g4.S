
; Lezione15g4.s	- 	Ondeggiamento con il bplcon1 AGA di una figura HIRES.
;			Da notare che se la pic e' HIRES lo scroll puo'
;			andare da 0 a 127, per un totale di 32 pixel lowres.
;			In pratica non e' abilitato il bit piu' alto.

	SECTION	AgaRulez,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110000000	; copper, bitplane DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:

;	Puntiamo la pic AGA

	MOVE.L	#PICTURE,d0
	LEA	BPLPOINTERS,A1
	MOVEQ	#8-1,D7		; num. bitplanes
POINTB:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	addi.l	#80*100,d0	; Lunghezza di un bitplane
	addq.w	#8,a1
	dbra	d7,POINTB		;Rifai D1 volte (D1=num of bitplanes)

	bsr.w	FaiAgaCopCon1	; Fai copperlist con WAIT+BPLCON2 ogni linea

	bsr.s	MettiColori	; Metti i colori della pic

	bsr.w	FINESCROLLC2	; Questa routine "converte" i valori decimali
				; in valori di scroll per il BPLCON1 AGA

	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#CopList,$80(a5)	; Puntiamo la nostra COP
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

;*****************************************************************************

MettiColori:
	LEA	LogoPal(PC),A0		; indirizzo della color palette 
	LEA	COLP0+2,A1		; Indirizzo del primo registro
					; settato per i nibble ALTI
	LEA	COLP0B+2,A2		; Indirizzo del primo registro
					; settato per i nibble BASSI
	MOVEQ	#8-1,d7			; 8 banchi da 32 registri ciascuno
ConvertiPaletteBank:
	moveq	#0,d0
	moveq	#0,d2
	moveq	#0,d3
	moveq	#32-1,d6	; 32 registri colore per banco

DaLongARegistri:	; loop che trasforma i colori $00RrGgBb.l nelle 2
			; word $0RGB, $0rgb adatte ai registri copper.

; Conversione dei nibble bassi da $00RgGgBb (long) al colore aga $0rgb (word)

	MOVE.B	1(A0),(a2)	; Byte alto del colore $00Rr0000 copiato
				; nel registro cop per nibble bassi
	ANDI.B	#%00001111,(a2) ; Seleziona solo il nibble BASSO ($0r)
	move.b	2(a0),d2	; Prendi il byte $0000Gg00 dal colore a 24bit
	lsl.b	#4,d2		; Sposta a sinistra di 4 bit il nibble basso
				; del GREEN, "trasformandolo" in nibble alto
				; di del byte basso di D2 ($g0)
	move.b	3(a0),d3	; Prendi il byte $000000Bb dal colore a 24bit
	ANDI.B	#%00001111,d3	; Seleziona solo il nibble BASSO ($0b)
	or.b	d2,d3		; "FONDI" i nibble bassi di green e blu...
	move.b	d3,1(a2)	; Formando il byte basso finale $gb da mettere
				; nel registro colore, dopo il byte $0r, per
				; formare la word $0rgb dei nibble bassi

; Conversione dei nibble alti da $00RgGgBb (long) al colore aga $0RGB (word)

	MOVE.B	1(A0),d0	; Byte alto del colore $00Rr0000 in d0
	ANDI.B	#%11110000,d0	; Seleziona solo il nibble ALTO ($R0)
	lsr.b	#4,d0		; Shifta a destra di 4 bit il nibble, in modo
				; che diventi il nibble basso del byte ($0R)
	move.b	d0,(a1)		; Copia il byte alto $0R nel color register
	move.b	2(a0),d2	; Prendi il byte $0000Gg00 dal colore a 24bit
	ANDI.B	#%11110000,d2	; Seleziona solo il nibble ALTO ($G0)
	move.b	3(a0),d3	; Prendi il byte $000000Bb dal colore a 24 bit
	ANDI.B	#%11110000,d3	; Seleziona solo il nibble ALTO ($B0)
	lsr.b	#4,d3		; Shiftalo di 4 bit a destra trasformandolo in
				; nibble basso del byte basso di d3 ($0B)
	ori.b	d2,d3		; Fondi i nibble alti di green e blu ($G0+$0B)
	move.b	d3,1(a1)	; Formando il byte basso finale $GB da mettere
				; nel registro colore, dopo il byte $0R, per
				; formare la word $0RGB dei nibble alti.

	addq.w	#4,a0		; Saltiamo al prossimo colore .l della palette
				; attaccata in fondo alla pic
	addq.w	#4,a1		; Saltiamo al prossimo registro colore per i
				; nibble ALTI in Copperlist
	addq.w	#4,a2		; Saltiamo al prossimo registro colore per i
				; nibble BASSI in Copperlist

	dbra	d6,DaLongARegistri

	add.w	#(128+8),a1	; salta i registri colore + il dc.w $106,xxx
				; dei nibble ALTI
	add.w	#(128+8),a2	; salta i registri colore + il dc.w $106,xxx
				; dei nibble BASSI

	dbra	d7,ConvertiPaletteBank	; Converte un banco da 32 colori per
	rts				; loop. 8 loop per i 256 colori.

; Palette salvata in binario con il PicCon (opzioni: save as binary, non cop)

LogoPal:
	incbin	"Pic640x100x256.pal"

;*****************************************************************************
; Routine che crea copperlist con un WAIT+BPLCON1 ogni linea
;*****************************************************************************

FaiAgaCopCon1:
	lea	AgaCon1,a0	; Indirizzo buffer in copperlist
	move.l	#$01020000,d0	; BplCon1
	move.l	#$2c07fffe,d1	; WAIT - Inizio linea Y=$2c
	move.w	#99-1,d7	; Numero linee da fare
FaiAGALoopC:
	move.l	d1,(a0)+	; Metti il wait YYXXFFFE
	move.l	d0,(a0)+	; BplCon1
	add.l	#$01000000,d1	; Fai waitare una linea sotto per la prossima
	dbra	d7,FaiAGALoopC
	rts

******************************************************************************
; Routine che converte da numeri "decimali" a valori per il bplcon1 AGA.
; In pratica scompone il numero a 8 bit posizionando i sui bit secondo lo
; schema del bplcon1 aga. Qesta versione da una sola tabella di valori 0-255
; converte in bplcon1, con lo stesso valore per i 2 playfield, adatto per
; scroll di figure come quella di questo esempio.
******************************************************************************

FINESCROLLC2:
	LEA	MOVTAB(PC),A0		; Tab valori
	LEA	CON1VALUES(PC),A1	; Tab destinazione per $DFF002
	LEA	MOVTABEND(PC),a2	; Fine della tabella
CONVLOOP:
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVE.B	(A0)+,D1	; VALORE "DECIMALE" PF1 IN D1
	MOVE.W	D1,D2		; COPIA VAL. 1 IN D2
	MOVE.W	d1,d4		; COPIA VAL. 1 IN D4
;pf1
	AND.W	#%11,D1		; Selez. bits 0-1 (SCROLL 1/4 e 1/2 pixel)
	LSL.W	#8,D1		; Shiftali al posto "giusto": bit 8 e 9
	MOVE.W	D1,D3		; Salva in d3
;pf2
	LSL.W	#4,D1		; Shiftali al posto "giusto": bit 12 e 13
	OR.W	D1,D3		; Salva in d3
;pf1
	AND.W	#%111100,d2	; Selez. i "vecchi" 4 bit dello scroll ad 1
				; pixel, max 16 pixel.
	LSR.W	#2,d2		; Shiftali al posto giusto: primi 4 bits!
	OR.W	d2,d3		; Salva in d3
;pf2
	LSL.W	#4,d2		; Shiftali al posto giusto: bits 4,5,6,7
	OR.W	d2,d3		; Salva in d3
;pf1
	AND.W	#%11000000,d4	; Selez. i bit alti: scatti di 16/32 pixel
	LSL.W	#4,d4		; Posto giusto: BITS 10&11 per PF1
	OR.W	D4,d3		; Salva in d3
;pf2
	LSL.W	#4,d4		; Posto giusto: BITS 14&15 per PF2
	OR.W	d4,d3		; add pf2 16 pixel scroll bits to d3

	MOVE.w	D3,(A1)+	; Salva il valore BPLCON1 finale
	CMP.L	a0,a2		; Fine della tabella?
	BNE.S	CONVLOOP	; Se non ancora, continua la conversione!
	RTS



WABBLE:
	move.l	TabPointer(PC),a0	; Punto attuale Tab in a0
	lea	Con1TabEnd(PC),a2	; Fine Tab
	lea	AGACON1+6,a1		; Effetto copper in a1
	move.w	#99-1,d7		; numero linee, ossia loops
scroll:
	move.w	(a0)+,(a1)	; Copia dalla tab al bplcon1 in copperlist
	addq.w	#8,a1		; Salta il wait - al prossimo bplcon1
	cmp.l	a2,a0		; Fine tab?
	bne.s	okay		; Se non ancora, continua
	LEA	CON1VALUES(PC),a0	; Altrimenti riparti da capo.
okay:
	dbra	d7,scroll	; D0 VOLTE

	move.l	TabPointer(PC),a0	; Punto attuale Tab in a0
	addq.w	#2,a0			; "scrollo" in avanti
	cmp.l	a2,a0		; Fine tab?
	bne.s	okay2		; Se non ancora, continua
	LEA	CON1VALUEs(PC),a0	; Altrimenti riparti da capo.
okay2:
	move.l	a0,TabPointer	; Aggiorna il puntatore
	RTS

TabPointer:
	dc.l	CON1VALUES


; Tabella con i valori finali per il $dff102 (BPLCON1)

NUMVAL	EQU	256


CON1VALUES:
	DCB.W	NUMVAL,0
CON1TABEND:

	ds.b	10000

;IS
;BEG>0
;END>360
;AMOUNT>128
;AMPLITUDE>63	; Se la figura e' in HIRES lo scroll va da 0 a 127!!
;YOFFSET>63

;AMOUNT>64
;AMPLITUDE>63	; Se la figura e' in HIRES lo scroll va da 0 a 127!!
;YOFFSET>63

;AMOUNT>32
;AMPLITUDE>63	; Se la figura e' in HIRES lo scroll va da 0 a 127!!
;YOFFSET>63

;AMOUNT>32
;AMPLITUDE>63	; Se la figura e' in HIRES lo scroll va da 0 a 127!!
;YOFFSET>63


MOVTAB:
	DC.B	$41,$44,$47,$4A,$4D,$50,$53,$56,$59,$5B,$5E,$61,$63,$66,$68,$6A
	DC.B	$6D,$6F,$71,$73,$74,$76,$77,$79,$7A,$7B,$7C,$7C,$7D,$7E,$7E,$7E
	DC.B	$7E,$7E,$7E,$7D,$7C,$7C,$7B,$7A,$79,$77,$76,$74,$73,$71,$6F,$6D
	DC.B	$6A,$68,$66,$63,$61,$5E,$5B,$59,$56,$53,$50,$4D,$4A,$47,$44,$41
	DC.B	$3D,$3A,$37,$34,$31,$2E,$2B,$28,$25,$23,$20,$1D,$1B,$18,$16,$14
	DC.B	$11,$0F,$0D,$0B,$0A,$08,$07,$05,$04,$03,$02,$02,$01,$00,$00,$00
	DC.B	$00,$00,$00,$01,$02,$02,$03,$04,$05,$07,$08,$0A,$0B,$0D,$0F,$11
	DC.B	$14,$16,$18,$1B,$1D,$20,$23,$25,$28,$2B,$2E,$31,$34,$37,$3A,$3D

	DC.B	$42,$48,$4E,$54,$5A,$5F,$65,$69,$6E,$72,$75,$78,$7A,$7C,$7D,$7E
	DC.B	$7E,$7D,$7C,$7A,$78,$75,$72,$6E,$69,$65,$5F,$5A,$54,$4E,$48,$42
	DC.B	$3C,$36,$30,$2A,$24,$1F,$19,$15,$10,$0C,$09,$06,$04,$02,$01,$00
	DC.B	$00,$01,$02,$04,$06,$09,$0C,$10,$15,$19,$1F,$24,$2A,$30,$36,$3C

	DC.B	$45,$51,$5D,$67,$70,$77,$7B,$7E,$7E,$7B,$77,$70,$67,$5D,$51,$45
	DC.B	$39,$2D,$21,$17,$0E,$07,$03,$00,$00,$03,$07,$0E,$17,$21,$2D,$39

	DC.B	$45,$51,$5D,$67,$70,$77,$7B,$7E,$7E,$7B,$77,$70,$67,$5D,$51,$45
	DC.B	$39,$2D,$21,$17,$0E,$07,$03,$00,$00,$03,$07,$0E,$17,$21,$2D,$39
MOVTABEND:


;*****************************************************************************
;*				COPPERLIST				     *
;*****************************************************************************

	CNOP	0,8	; Allineo a 64 bit

	section	coppera,data_C

COPLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop

; Nota: il ddfstart/stop HIRES sarebbero $003c e $00d4, ma con il burst attivo
; va bene lo stesso valore del LOWRES, ossia $0038 e $00d0.

	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,-8		; Bpl1Mod (burst 64bit, modulo=modulo-8)
	dc.w	$10a,-8		; Bpl2Mod (come sopra)

		    ; 5432109876543210
	dc.w	$100,%1000001000010001	; 8 bitplane HIRES 640x256. Per
					; settare 8 planes setto il bit 4 e
					; azzero i bit 12,13,14. Il bit 0 e'
					; settato dato che abilita molte
					; funzioni AGA che vedremo dopo.

	dc.w	$1fc,3		; Burst mode a 64 bit

BPLPOINTERS:
	dc.w $e0,0,$e2,0	; primo 	bitplane
	dc.w $e4,0,$e6,0	; secondo	   "
	dc.w $e8,0,$ea,0	; terzo		   "
	dc.w $ec,0,$ee,0	; quarto	   "
	dc.w $f0,0,$f2,0	; quinto	   "
	dc.w $f4,0,$f6,0	; sesto		   "
	dc.w $f8,0,$fA,0	; settimo	   "
	dc.w $fC,0,$fE,0	; ottavo	   "

; In questo caso la palette viene aggiornata da una routine, per cui basta
; lasciare azzerati i valori dei registri.

	DC.W	$106,$c00	; SELEZIONA PALETTE 0 (0-31), NIBBLE ALTI
COLP0:
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$e00	; SELEZIONA PALETTE 0 (0-31), NIBBLE BASSI
COLP0B:
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$2C00	; SELEZIONA PALETTE 1 (32-63), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$2E00	; SELEZIONA PALETTE 1 (32-63), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$4C00	; SELEZIONA PALETTE 2 (64-95), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$4E00	; SELEZIONA PALETTE 2 (64-95), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$6C00	; SELEZIONA PALETTE 3 (96-127), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$6E00	; SELEZIONA PALETTE 3 (96-127), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$8C00	; SELEZIONA PALETTE 4 (128-159), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$8E00	; SELEZIONA PALETTE 4 (128-159), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$AC00	; SELEZIONA PALETTE 5 (160-191), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$AE00	; SELEZIONA PALETTE 5 (160-191), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$CC00	; SELEZIONA PALETTE 6 (192-223), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$CE00	; SELEZIONA PALETTE 6 (192-223), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$EC00	; SELEZIONA PALETTE 7 (224-255), NIBBLE ALTI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$EE00	; SELEZIONA PALETTE 7 (224-255), NIBBLE BASSI

	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

AgaCon1:
	dcb.l	99*2		; Ossia: 99 linee * 2 long:
				; 1 per il wait,
				; 1 per il bplcon1
	dc.w	$9007,$fffe	; aspetta la fine del logo
	dc.w	$100,$200	; zero bitplanes

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;******************************************************************************

; Figura RAW ad 8 bitplanes, cioe' a 256 colori

	CNOP	0,8	; allineo a 64 bit

PICTURE:
	INCBIN	"Pic640x100x256.RAW"	; (C) by Cristiano "KREEX" Evangelisti

	end

Per le figure hires abbiamo una limitazione hardware nello scroll: non e'
abilitato il bit piu' alto, quello dello scroll di 32 pixel alla volta,
per cui il valore va da 0 a 127, anziche' da 0 a 255.

