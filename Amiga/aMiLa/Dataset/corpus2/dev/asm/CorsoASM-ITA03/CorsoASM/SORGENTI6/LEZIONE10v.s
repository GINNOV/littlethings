
; Lezione10v.s	Poligono che ruota.
;		tasto sinistro per uscire

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:
;	Puntiamo la PIC "vuota"

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	move.w	#$ffff,d0	; linea continua
	bsr.w	SetPattern	; definisce pattern

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$12c00,d2	; linea da aspettare = $12c
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	BNE.S	Waity1

	bsr.w	CancellaSchermo	; pulisce lo schermo

	bsr.w	MuoviPunti	; modifica le coordinate dei punti

	bsr.w	InitLine	; inizializza line-mode

; disegna la linea tra i punti 1 e 2

	move.w	Point1(pc),d0
	move.w	Point1+2(pc),d1
	move.w	Point2(pc),d2
	move.w	Point2+2(pc),d3
	lea	bitplane,a0
	bsr.w	Drawline

; disegna la linea tra i punti 2 e 3

	move.w	Point2(pc),d0
	move.w	Point2+2(pc),d1
	move.w	Point3(pc),d2
	move.w	Point3+2(pc),d3
	lea	bitplane,a0
	bsr.w	Drawline

; disegna la linea tra i punti 3 e 4

	move.w	Point3(pc),d0
	move.w	Point3+2(pc),d1
	move.w	Point4(pc),d2
	move.w	Point4+2(pc),d3
	lea	bitplane,a0
	bsr.w	Drawline

; disegna la linea tra i punti 4 e 1

	move.w	Point4(pc),d0
	move.w	Point4+2(pc),d1
	move.w	Point1(pc),d2
	move.w	Point1+2(pc),d3
	lea	bitplane,a0
	bsr.w	Drawline

	moveq	#0,d0
	moveq	#0,d1
	lea	bitplane+178*40-2,a0
	bsr.w	Fill

	btst	#6,$bfe001	; mouse premuto?
	bne.w	mouse
	rts

;***************************************************************************
; Questa routine legge da una tabella le coordinate dei vari punti e le
; memorizza nelle apposite variabili.
;***************************************************************************

;	          _
;	     _/\/ฏ/
;	     \___/
;	     /   \
;	    / o O \
;	   (_______)
;	   _| / \ |_
;	  / |(___)| \
;	 /  l_____|  \
;	Y    | U |    Y
;	|  ฆ l___| ฆ .|
;	|  ก       ก :|
;	l__|-------l__|
;	  |        .|
;	  |    ก   :|
;	  |    ฆ   ท|
;	  |    ฆ    |
;	.-`----ท----'-.
;	ก_____| l_____กbHe
	
MuoviPunti:
	ADDQ.L	#2,TABXPOINT		; Fai puntare alla word successiva
	MOVE.L	TABXPOINT(PC),A0	; indirizzo contenuto in long TABXPOINT
					; copiato in a0
	CMP.L	#FINETABX-2,A0  	; Siamo all'ultima word della TAB?
	BNE.S	NOBSTARTX		; non ancora? allora continua
	MOVE.L	#TABX-2,TABXPOINT 	; Riparti a puntare dalla prima word-2
NOBSTARTX:
	MOVE.W	(A0),Point1		; copia il valore della coordinata
					; del punto 1 nella variabile apposita

	LEA	50(A0),A0		; Coordinata del punto seguente
	CMP.L	#FINETABX-2,A0	  	; Siamo all'ultima word della TAB?
	BLE.S	NOBSTARTX2		; no allora leggi
	SUB.L	#FINETABX-TABX,A0 	; altrimenti torna indietro nella
					; tabella
NOBSTARTX2:
	MOVE.W	(A0),Point2		; copia il valore della coordinata
					; del punto 2 nella variabile apposita

	LEA	50(A0),A0		; Coordinata del punto seguente
	CMP.L	#FINETABX-2,A0	  	; Siamo all'ultima word della TAB?
	BLE.S	NOBSTARTX3		; no allora leggi
	SUB.L	#FINETABX-TABX,A0 	; altrimenti torna indietro nella
					; tabella
NOBSTARTX3:
	MOVE.W	(A0),Point3		; copia il valore della coordinata
					; del punto 3 nella variabile apposita

	LEA	50(A0),A0		; Coordinata del punto seguente
	CMP.L	#FINETABX-2,A0	  	; Siamo all'ultima word della TAB?
	BLE.S	NOBSTARTX4		; no allora leggi
	SUB.L	#FINETABX-TABX,A0 	; altrimenti torna indietro nella
					; tabella
NOBSTARTX4:
	MOVE.W	(A0),Point4		; copia il valore della coordinata
					; del punto 4 nella variabile apposita

	ADDQ.L	#2,TABYPOINT		; Fai puntare alla word successiva
	MOVE.L	TABYPOINT(PC),A0	; indirizzo contenuto in long TABYPOINT
					; copiato in a0
	CMP.L	#FINETABY-2,A0  	; Siamo all'ultima word della TAB?
	BNE.S	NOBSTARTY		; non ancora? allora continua
	MOVE.L	#TABY-2,TABYPOINT 	; Riparti a puntare dalla prima word-2
NOBSTARTY:
	MOVE.W	(A0),Point1+2		; copia il valore della coordinata
					; del punto 1 nella variabile apposita

	LEA	50(A0),A0		; Coordinata del punto seguente
	CMP.L	#FINETABY-2,A0	  	; Siamo all'ultima word della TAB?
	BLE.S	NOBSTARTY2		; no allora leggi
	SUB.L	#FINETABY-TABY,A0 	; altrimenti torna indietro nella
					; tabella
NOBSTARTY2:
	MOVE.W	(A0),Point2+2		; copia il valore della coordinata
					; del punto 2 nella variabile apposita

	LEA	50(A0),A0		; Coordinata del punto seguente
	CMP.L	#FINETABY-2,A0	  	; Siamo all'ultima word della TAB?
	BLE.S	NOBSTARTY3		; no allora leggi
	SUB.L	#FINETABY-TABY,A0 	; altrimenti torna indietro nella
					; tabella
NOBSTARTY3:
	MOVE.W	(A0),Point3+2		; copia il valore della coordinata
					; del punto 3 nella variabile apposita

	LEA	50(A0),A0		; Coordinata del punto seguente
	CMP.L	#FINETABY-2,A0	  	; Siamo all'ultima word della TAB?
	BLE.S	NOBSTARTY4		; no allora leggi
	SUB.L	#FINETABY-TABY,A0 	; altrimenti torna indietro nella
					; tabella
NOBSTARTY4:
	MOVE.W	(A0),Point4+2		; copia il valore della coordinata
					; del punto 4 nella variabile apposita
	rts

TABXPOINT:
	dc.l	TABX	; puntatore alla tabella X

; tabella posizioni X

TABX:
	DC.W	$00D2,$00D2,$00D1,$00D1,$00D0,$00CF,$00CE,$00CD,$00CB,$00C9
	DC.W	$00C8,$00C6,$00C3,$00C1,$00BF,$00BC,$00B9,$00B7,$00B4,$00B1
	DC.W	$00AE,$00AB,$00A8,$00A5,$00A2,$009E,$009B,$0098,$0095,$0092
	DC.W	$008F,$008C,$0089,$0087,$0084,$0081,$007F,$007D,$007A,$0078
	DC.W	$0077,$0075,$0073,$0072,$0071,$0070,$006F,$006F,$006E,$006E
	DC.W	$006E,$006E,$006F,$006F,$0070,$0071,$0072,$0073,$0075,$0077
	DC.W	$0078,$007A,$007D,$007F,$0081,$0084,$0087,$0089,$008C,$008F
	DC.W	$0092,$0095,$0098,$009B,$009E,$00A2,$00A5,$00A8,$00AB,$00AE
	DC.W	$00B1,$00B4,$00B7,$00B9,$00BC,$00BF,$00C1,$00C3,$00C6,$00C8
	DC.W	$00C9,$00CB,$00CD,$00CE,$00CF,$00D0,$00D1,$00D1,$00D2,$00D2

FINETABX:

TABYPOINT:
	dc.l	TABY	; puntatore alla tabella Y

TABY:
	DC.W	$0081,$0084,$0087,$008A,$008D,$0090,$0093,$0096,$0098,$009B
	DC.W	$009E,$00A0,$00A2,$00A5,$00A7,$00A8,$00AA,$00AC,$00AD,$00AE
	DC.W	$00AF,$00B0,$00B0,$00B1,$00B1,$00B1,$00B1,$00B0,$00B0,$00AF
	DC.W	$00AE,$00AD,$00AC,$00AA,$00A8,$00A7,$00A5,$00A2,$00A0,$009E
	DC.W	$009B,$0098,$0096,$0093,$0090,$008D,$008A,$0087,$0084,$0081
	DC.W	$007D,$007A,$0077,$0074,$0071,$006E,$006B,$0068,$0066,$0063
	DC.W	$0060,$005E,$005C,$0059,$0057,$0056,$0054,$0052,$0051,$0050
	DC.W	$004F,$004E,$004E,$004D,$004D,$004D,$004D,$004E,$004E,$004F
	DC.W	$0050,$0051,$0052,$0054,$0056,$0057,$0059,$005C,$005E,$0060
	DC.W	$0063,$0066,$0068,$006B,$006E,$0071,$0074,$0077,$007A,$007D
FINETABY:

; Qui sono memorizzate i volta in volta le coordinate dei punti del poligono

Point1:	dc.w	100,20
Point2:	dc.w	200,20
Point3:	dc.w	200,40
Point4:	dc.w	100,40


;****************************************************************************
; Questa routine copia un rettangolo di schermo da una posizione fissa
; ad un indirizzo specificato come parametro. Il rettangolo di schermo che
; viene copiato racchiude interamente le 2 linee.
; Durante la copia viene effettuato anche il riempmento. Il tipo di riempimento
; e` specificato tramite i parametri.
; I parametri sono:
; A0 - indirizzo rettangolo da fillare
; D0 - se vale 0 allora effettua fill inclusivo, altrimenti fa fill esclusivo
; D1 - se vale 0 allora effettua FILL_CARRYIN=0, altrimenti FILL_CARRYIN=1
;****************************************************************************

Fill:
	btst	#6,2(a5) ; dmaconr
WBlit1:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit1

	move.w	#$09f0,$40(a5)		; BLTCON0 copia normale

	tst.w	d0			; testa D0 per decidere il tipo di fill
	bne.s	fill_esclusivo
	move.w	#$000a,d2		; valore di BLTCON1: settati i bit del
					; fill inclusivo e del modo discendente
	bra.s	test_fill_carry

fill_esclusivo:
	move.w	#$0012,d2		; valore di BLTCON1: settati i bit del
					; fill esclusivo e del modo discendente

test_fill_carry:
	tst.w	d1			; testa D1 per vedere se deve settare
					; il bit FILL_CARRYIN

	beq.s	fatto_bltcon1		; se D1=0 salta..
	bset	#2,d2			; altrimenti setta il bit 2 di D2

fatto_bltcon1:
	move.w	d2,$42(a5)		; BLTCON1

	move.w	#0,$64(a5)		; BLTAMOD larghezza 20 words (40-40=0)
	move.w	#0,$66(a5)		; BLTDMOD (40-40=0)

	move.l	a0,$50(a5)		; BLTAPT - indirizzo al rettangolo
					; il rettangolo sorgente racchiude
					; interamente il poligono
					; puntiamo l'ultima word del rettangolo
					; per via del modo discendente

	move.l	a0,$54(a5)		; BLTDPT - indirizzo rettangolo
	move.w	#(64*100)+20,$58(a5)	; BLTSIZE (via al blitter !)
					; larghezza 20 words
	rts				; altezza 100 righe (1 plane)


;******************************************************************************
; Questa routine effettua il disegno della linea. prende come parametri gli
; estremi della linea P1 e P2, e l'indirizzo del bitplane su cui disegnarla.
; D0 - X1 (coord. X di P1)
; D1 - Y1 (coord. Y di P1)
; D2 - X2 (coord. X di P2)
; D3 - Y2 (coord. Y di P2)
; A0 - indirizzo bitplane
;******************************************************************************

; costanti

DL_Fill		=	1		; 0=NOFILL / 1=FILL

	IFEQ	DL_Fill
DL_MInterns	=	$CA
	ELSE
DL_MInterns	=	$4A
	ENDC


DrawLine:
	sub.w	d1,d3	; D3=Y2-Y1

	IFNE	DL_Fill
	beq.s	.end	; per il fill non servono linee orizzontali 
	ENDC

	bgt.s	.y2gy1	; salta se positivo..
	exg	d0,d2	; ..altrimenti scambia i punti
	add.w	d3,d1	; mette in D1 la Y piu` piccola
	neg.w	d3	; D3=DY
.y2gy1:
	mulu.w	#40,d1		; offset Y
	add.l	d1,a0
	moveq	#0,d1		; D1 indice nella tabella ottanti
	sub.w	d0,d2		; D2=X2-X1
	bge.s	.xdpos		; salta se positivo..
	addq.w	#2,d1		; ..altrimenti sposta l'indice
	neg.w	d2		; e rendi positiva la differenza
.xdpos:
	moveq	#$f,d4		; maschera per i 4 bit bassi
	and.w	d0,d4		; selezionali in D4
		
	IFNE	DL_Fill		; queste istruzioni vengono assemblate
				; solo se DL_Fill=1
	move.b	d4,d5		; calcola numero del bit da invertire
	not.b	d5		; (la BCHG numera i bit in modo inverso	
	ENDC

	lsr.w	#3,d0		; offset X:
				; Allinea a byte (serve per BCHG)
	add.w	d0,a0		; aggiunge all'indirizzo
				; nota che anche se l'indirizzo
				; e` dispari non fa nulla perche`
				; il blitter non tiene conto del
				; bit meno significativo di BLTxPT

	ror.w	#4,d4		; D4 = valore di shift A
	or.w	#$B00+DL_MInterns,d4	; aggiunge l'opportuno
					; Minterm (OR o EOR)
	swap	d4		; valore di BLTCON0 nella word alta
		
	cmp.w	d2,d3		; confronta DiffX e DiffY
	bge.s	.dygdx		; salta se >=0..
	addq.w	#1,d1		; altrimenti setta il bit 0 del'indice
	exg	d2,d3		; e scambia le Diff
.dygdx:
	add.w	d2,d2		; D2 = 2*DiffX
	move.w	d2,d0		; copia in D0
	sub.w	d3,d0		; D0 = 2*DiffX-DiffY
	addx.w	d1,d1		; moltiplica per 2 l'indice e
				; contemporaneamente aggiunge il flag
				; X che vale 1 se 2*DiffX-DiffY<0
				; (settato dalla sub.w)
	move.b	Oktants(PC,d1.w),d4	; legge l'ottante
	swap	d2			; valore BLTBMOD in word alta
	move.w	d0,d2			; word bassa D2=2*DiffX-DiffY
	sub.w	d3,d2			; word bassa D2=2*DiffX-2*DiffY
	moveq	#6,d1			; valore di shift e di test per
					; la wait blitter 

	lsl.w	d1,d3		; calcola il valore di BLTSIZE
	add.w	#$42,d3

	lea	$52(a5),a1	; A1 = indirizzo BLTAPTL
				; scrive alcuni registri
				; consecutivamente con delle 
				; MOVE #XX,(Ax)+

	btst	d1,2(a5)	; aspetta il blitter
.wb:
	btst	d1,2(a5)
	bne.s	.wb

	IFNE	DL_Fill		; questa istruzione viene assemblata
				; solo se DL_Fill=1
	bchg	d5,(a0)		; Inverte il primo bit della linea
	ENDC

	move.l	d4,$40(a5)	; BLTCON0/1
	move.l	d2,$62(a5)	; BLTBMOD e BLTAMOD
	move.l	a0,$48(a5)	; BLTCPT
	move.w	d0,(a1)+	; BLTAPTL
	move.l	a0,(a1)+	; BLTDPT
	move.w	d3,(a1)		; BLTSIZE
.end:
	rts

;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ
; se vogliamo eseguire linee per il fill, il codice ottante setta ad 1 il bit
; SING attraverso la costante SML

	IFNE	DL_Fill
SML		= 	2
	ELSE
SML		=	0
	ENDC

; tabella ottanti

Oktants:
	dc.b	SML+1,SML+1+$40
	dc.b	SML+17,SML+17+$40
	dc.b	SML+9,SML+9+$40
	dc.b	SML+21,SML+21+$40

;******************************************************************************
; Questa routine setta i registri del blitter che non devono essere
; cambiati tra una line e l'altra
;******************************************************************************

InitLine:
	btst	#6,2(a5) ; dmaconr
WBlit_Init:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	Wblit_Init

	moveq	#-1,d5
	move.l	d5,$44(a5)		; BLTAFWM/BLTALWM = $FFFF
	move.w	#$8000,$74(a5)		; BLTADAT = $8000
	move.w	#40,$60(a5)		; BLTCMOD = 40
	move.w	#40,$66(a5)		; BLTDMOD = 40
	rts

;******************************************************************************
; Questa routine definisce il pattern che deve essere usato per disegnare
; le linee. In pratica si limita a settare il registro BLTBDAT.
; D0 - contiene il pattern della linea 
;******************************************************************************

SetPattern:
	btst	#6,2(a5) ; dmaconr
WBlit_Set:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	Wblit_Set

	move.w	d0,$72(a5)	; BLTBDAT = pattern linee
	rts

;****************************************************************************
; Questa routine cancella lo schermo mediante il blitter.
;****************************************************************************

CancellaSchermo:
	move.l	#bitplane+78*40,a0	; indirizzo area da cancellare

	btst	#6,2(a5)
WBlit3:
	btst	#6,2(a5)		 ; attendi che il blitter abbia finito
	bne.s	wblit3

	move.l	#$01000000,$40(a5)	; BLTCON0 e BLTCON1: Cancella
	move.w	#$0000,$66(a5)		; BLTDMOD=0
	move.l	a0,$54(a5)		; BLTDPT
	move.w	#(64*100)+20,$58(a5)	; BLTSIZE (via al blitter !)
					; cancella tutto lo schermo
	rts


;****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

	dc.w	$100,$1200	; Bplcon0 - 1 bitplane lowres

BPLPOINTERS:
	dc.w	$e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$eee	; color1
	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

	Section	IlMioPlane,bss_C

BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

;****************************************************************************

In questo esempio realizziamo un poligono che ruota.
Il poligono e` formato da 4 punti la cui posizione viene modificata ad ogni
frame leggendola da una tabella precalcolata. Questa tecnica comporta un grande
spreco di memoria. Piu` in la` nel corso vedremo come calcolare le coordinate
dei punti mediante formule matematiche.
Per disegnare il poligono e` sufficente disegnare i lati e fillare. Prima
delle operazioni di disegno e` ovviamente necessario cancellare lo schermo
con il blitter.
L'area di schermo da cancellare e quella da fillare sono state calcolate
in modo da comprendere sempre tutto il poligono.

