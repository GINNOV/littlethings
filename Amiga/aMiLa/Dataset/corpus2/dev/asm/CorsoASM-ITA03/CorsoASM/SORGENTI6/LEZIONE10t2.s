
; Lezione10t2.s	Routine tracciamento linee ottimizzata

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

	bsr.w	InitLine	; inizializza line-mode

	move.w	#$ffff,d0	; linea continua
	bsr.w	SetPattern	; definisce pattern

	move.w	#100,d0		; x1
	move.w	#100,d1		; y1
	move.w	#220,d2		; x2
	move.w	#120,d3		; y2
	lea	bitplane,a0
	bsr.s	Drawline

	move.w	#$f0f0,d0	; linea trattegiata
	bsr.w	SetPattern	; definisce pattern

	move.w	#300,d0		; x1
	move.w	#200,d1		; y1
	move.w	#240,d2		; x2
	move.w	#90,d3		; y2
	lea	bitplane,a0
	bsr.s	Drawline

	move.w	#$4444,d0	; linea trattegiata
	bsr.w	SetPattern	; definisce pattern

	move.w	#210,d0		; x1
	move.w	#24,d1		; y1
	move.w	#68,d2		; x2
	move.w	#50,d3		; y2
	lea	bitplane,a0
	bsr.s	Drawline

mouse:
	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts


;******************************************************************************
; Questa routine effettua il disegno della linea. prende come parametri gli
; estremi della linea P1 e P2, e l'indirizzo del bitplane su cui disegnarla.
; D0 - X1 (coord. X di P1)
; D1 - Y1 (coord. Y di P1)
; D2 - X2 (coord. X di P2)
; D3 - Y2 (coord. Y di P2)
; A0 - indirizzo bitplane
;******************************************************************************

;	      .---.        .-----------
;	     /     \  __  /    ------
;	    / /     \(oo)/    -----
;	   //////   ' \/ `   ---
;	  //// / // :    : ---
;	 // /   /  /`    '--
;	//          //..\\
;	-----------UU----UU-----
;	           '//||\\`
;	             ''``

; costanti

DL_Fill		=	0		; 0=NOFILL / 1=FILL

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

;нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
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

InitLine
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

In questo esempio presentiamo una routine ottimizzata per il tracciamento
di linee. La caratteristica principale di questa routine e` che i codici
degli ottanti sono contenuti in una tabella. La routine a seconda delle
posizioni dei punti calcola l'indice del giusto ottante nella tabella.
Oltre a questo la routine impiega moltissime ottimizzazioni 68000.
Questa routine contiene delle direttive assembler per l'assemblaggio
condizionale. In base al valore della costante DL_Fill vengono assemblate
o meno alcune parti della routine. In questo modo e` possibile riunire
in un unico sorgente il codice sia per la versione normale che quello
per la versione line-fill. Settando DL_Fill=0 si assembla la routine
normale, mentre con DL_Fill=1 si assembla la versione per line fill.
Per rendervene conto osservate (con il comando D di ASMONE) il codice
prodotto nei 2 casi.

