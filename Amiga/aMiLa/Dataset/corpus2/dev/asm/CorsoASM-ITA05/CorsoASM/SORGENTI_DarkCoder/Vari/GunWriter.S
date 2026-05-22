*************************************************************************
*		Gunwriter for ITALIAN CHART 1992			*
*									*
* Coder: DDT	(D.Paccaloni)						*
* Date : dd/mm/1992							*
*									*
* Aggiornamento e fixamento: RANDY/RAM JAM (Fabio Ciucci)		*
* Date: 1995								*
*									*
*************************************************************************

FRAMES = 100		; Velocita' (1-254)

	Section GunWritoccio,code

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; salva interrupt, dma eccetera.
*****************************************************************************

; Con DMASET decidiamo quali canali DMA aprire e quali chiudere

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA abilitati

WaitDisk	EQU	10	; 50-150 al salvataggio (secondo i casi)

START:

; Puntiamo il nostro int di livello 3

	move.l	BaseVBR(PC),a0	     ; In a0 il valore del VBR
	move.l	#NewIRQ,$6c(a0)	     ; metto la mia rout. int. livello 3.

	MOVE.L	#plane1,D0	  ; planes
	LEA	BplPointers,A1	  ; indirizzo puntatori nella copperlist.
	moveq	#2-1,d1		  ; 2 planes
Ploop:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#40*256,d0
	addq.w	#8,a1
	dbra	d1,Ploop

	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.
	move.l	#Newclist,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

		; 5432109876543210
	move.w	#%1100000000100000,$9a(a5)    ; INTENA - abilito solo VERTB

;	MAIN PROGRAM

SetLine:
	lea	$dff000,a0
	move.w	#40,$60(a0)
	move.w	#40,$66(a0)
	move.l	#plane1,$48(a0)
	move.l	#plane1,$54(a0)
	move.l	#-1,$44(a0)
	move.w	#$8000,$74(a0)
	move.w	#$ffff,$72(a0)

	lea	MenoUno(PC),a1
	lea	LinesData(PC),a4	; Pointer to line to get
	sf	FrameN			; Reset frame number counter

qTF0:	cmp.b	#$f0,$dff006
	bne.s	qTF0
qTF1:	cmp.b	#$f0,$dff006
	beq.s	qTF1

aTF0:	cmp.b	#$f0,$dff006
	bne.s	aTF0
aTF1:	cmp.b	#$f0,$dff006
	beq.s	aTF1

aTF2:	cmp.b	#$f0,$dff006
	bne.s	aTF2
aTF3:	cmp.b	#$f0,$dff006
	beq.s	aTF3

	btst	#6,$dff002
CLS1:
	btst	#6,$dff002	;Clear text plane
	bne.s	CLS1

	move.w	#0,$dff066		;D modulo
	move.l	#plane2,$dff054		;D pointer
	move.w	#$0000,$dff042		;bltcon 1
	move.w	#$0100,$dff040		;bltcon 0
	move.w	#$4014,$dff058		;bltsize
WBLLI:
	btst	#6,$dff002
	bne.s	WBLLI

NEXTFRAME:
	btst	#10,$dff016
	beq.w	Exit

	tst.w	LastN
	bne.s	ooo

	cmp.w	#-1,(a1)	;Test for end of current Char
	bne.w	Continue

GetNewChar:
	move.w	StrVal(PC),d6	; StretchValue
	moveq	#0,d7		; Clear d7
	move.l	TxtPnt(PC),a0
GetNxt:
	move.b	(a0),d7
	bne.w	NoEOP
CLSP:				;End of PAGE {
	tst.w	LastN
	bne.s	ooo
	move.w	#1,LastN
ooo:
	lea	MenoUno(PC),a1
	cmp.w	#Frames,LastN
	bne.w	CONTINUE
	lea	Text(PC),a0
	move.l	a0,TxtPnt
	clr.w	LastN

lll:	btst	#6,$bfe001	; swappa pagina col tasto sinistro
	bne.s	lll

	sf	FrameN		;Reset frame number counter
	move.w	#Frames,d0
	mulu.w	#12,d0
	lea	LinesData(PC),a4
SetLDat:
	move.w	#-1,(a4)+
	dbra	d0,SetLDat

	lea	LinesData(PC),a4	; Pointer to line to get

	btst	#6,$dff002	;Clear text plane
	bne.s	CLSP

	move.w	#0,$dff066		;D modulo
	move.l	#plane2,$dff054		;D pointer
	move.w	#$0000,$dff042		;bltcon 1
	move.w	#$0100,$dff040		;bltcon 0
	move.w	#$4014,$dff058		;bltsize
WBLLIP:
	btst	#6,$dff002
	bne.s	WBLLIP		;}.
	bra.w	GetNxt

NoEOP:
	cmp.b	#-1,d7
	bne.s	NoEOF
	lea	Text(PC),a0
	move.l	a0,TxtPnt
	bra.w	GetNxt

NoEOF:
	cmp.b	#9,d7
	bpl.s	NoStr
	move.b	d7,d6
	subq.w	#1,d6
	move.w	d6,StrVal
	addq.w	#1,a0
	bra.w	GetNxt

NoStr:
	cmp.b	#10,d7
	bne.s	NoCR
	st.b	ACapo
	moveq	#8,d7
	lsl.w	d6,d7
	add.w	d7,CurY
	clr.w	CurX
	addq.w	#1,a0
	bra.w	GetNxt

NoCR:
	cmp.b	#11,d7
	bne.s	NoXY
	st.b	ACapo
	clr.w	CurX
	clr.w	CurY
	move.b	1(a0),CurX+1
	move.b	2(a0),CurY+1
	addq.w	#3,a0
	bra.w	GetNxt

NoXY:
	tst.b	ACapo
	beq.s	NoAC
	sf.b	ACapo
	bra.s	Skizz

NoAC:
	moveq	#8,d0			;NormalChar
	lsl.w	d6,d0
	add.w	d0,CurX
Skizz:
	addq.w	#1,a0
	move.l	a0,TxtPnt

	move.w	d7,d0
	sub.w	#32,d0
	lsl.w	#2,d0
	lea	CharsOffs(PC),a5
	move.l	(a5,d0.w),a1		;Start of new_Char data
	cmp.b	#-1,(a1)
	beq.w	GetNxt

Continue:				;Set next line
	tst.w	LastN
	beq.s	Normal
	move.w	#$5000,(a4)
	add.w	#24,a4
	bra.w	GoDraw

Normal:
	moveq	#6,d7		; Shift Value
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d4
	moveq	#0,d5
	move.w	GunX(PC),d0	; Get GunX pos as X0
	move.w	GunY(PC),d1	; Get GunY pos as Y0
	lsl.w	d7,d0		; Make X0 *64
	lsl.w	d7,d1		; Make Y0 *64
	move.w	d0,(a4)+	; Set X0 *64
	move.w	d1,(a4)+	; Set Y0 *64
	move.w	OldGunX(pc),d4	; Get GunX oldpos as X1
	move.w	OldGunY(pc),d5	; Get GunY oldpos as Y1
	lsl.w	d7,d4		; Make X1 *64
	lsl.w	d7,d5		; Make Y1 *64
	move.w	d4,(a4)+	; Set X1 *64
	move.w	d5,(a4)+	; Set Y1 *64

	move.w	(a1)+,d4	; Get abs dX0
	move.w	(a1)+,d5	; Get abs dY0
	lsl.w	d6,d4		; stretchval
	lsl.w	d6,d5
	add.w	CurX(PC),d4	; Make rel dX0
	add.w	CurY(PC),d5	; Make rel dY0
	move.w	d4,(a4)+	; Put dX0
	move.w	d5,(a4)+	; Put dY0
	lsl.w	d7,d4		; Make tsX0 *64
	lsl.w	d7,d5		; Make tsY0 *64
	sub.w	d0,d4		; Find total X0 step *64
	sub.w	d1,d5		; Find total Y0 step *64
	ext.l	d4
	ext.l	d5
	divs.w	#FRAMES,d4	; Find X0 step *64
	divs.w	#FRAMES,d5	; Find Y0 step *64

	move.w	(a1)+,d2	; Get abs dX1
	move.w	(a1)+,d3	; Get abs dY1
	lsl.w	d6,d2
	lsl.w	d6,d3
	add.w	CurX(PC),d2	; Make rel dX1
	add.w	CurY(PC),d3	; Make rel dY1
	move.w	d2,(a4)+	; Put dX1
	move.w	d3,(a4)+	; Put dY1
	lsl.w	d7,d2		; Make tsX1 *64
	lsl.w	d7,d3		; Make tsY1 *64
	move.w	OldGunX(pc),d0	; Get GunX oldpos as X1
	move.w	OldGunY(pc),d1	; Get GunY oldpos as Y1
	lsl.w	d7,d0		; Make X1 *64
	lsl.w	d7,d1		; Make Y1 *64
	sub.w	d0,d2		; Find total X1 step *64
	sub.w	d1,d3		; Find total Y1 step *64
	ext.l	d2
	ext.l	d3
	divs	#FRAMES,d2	; Find X1 step *64
	divs	#FRAMES,d3	; Find Y1 step *64

	move.w	d4,(a4)+	; Put sX0 *64
	move.w	d5,(a4)+	; Put sY0 *64
	move.w	d2,(a4)+	; Put sX1 *64
	move.w	d3,(a4)+	; Put sY1 *64

;LinesData:	; dc.w	X0,Y0,X1,Y1,dX0,dY0,dX1,dY1,sX0,sY0,sX1,sY1

GoDraw:
;	tst.w	LastN
;	beq.s	Jepa
;	lea	MenoUno,a1
Jepa:
	lea	LinesData(PC),a5	;Add steps
	moveq	#-1,d7
DrawNext:
	cmp.b	#-1,d7
	bne.s	NoFLin
	cmp.b	#FRAMES-1,FrameN
	bne.s	NoLast
	bra.s	Zump

NoFLin:
	cmp.b	FrameN(PC),d7
	bne.s	NoLast
Zump:
	move.w	8(a5),d0
	move.w	10(a5),d1
	move.w	12(a5),d2
	move.w	14(a5),d3
	move.l	#plane2,CurScreen
	bra.s	WBLL

NoLast:
	tst.w	LastN
	beq.s	NoBlub
	cmp.w	#$5000,(a5)
	beq.w	Blub
NoBlub:
	move.w	16(a5),d0
	add.w	d0,(a5)
	move.w	18(a5),d0
	add.w	d0,2(a5)
	move.w	20(a5),d0
	add.w	d0,4(a5)
	move.w	22(a5),d0
	add.w	d0,6(a5)

	move.w	(a5),d0
	move.w	2(a5),d1
	move.w	4(a5),d2
	move.w	6(a5),d3
	moveq	#6,d4	; per dividere /64
	lsr.w	d4,d0	; x0
	lsr.w	d4,d1	; y0
	lsr.w	d4,d2	; x1
	lsr.w	d4,d3	; y1

WBLL:

	movem.l	d0-d7/a0-a6,-(sp)
	lea	$dff000,a5
	btst	#6,2(a5) ; dmaconr
WBlit_Init:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	Wblit_Init

	moveq	#-1,d5
	move.l	d5,$44(a5)		; BLTAFWM/BLTALWM = $FFFF
	move.w	#$8000,$74(a5)		; BLTADAT = $8000
	move.w	#40,$60(a5)		; BLTCMOD = 40
	move.w	#40,$66(a5)		; BLTDMOD = 40
	move.l	CurScreen(PC),a0
	bsr.w	DrawLine
	movem.l	(sp)+,d0-d7/a0-a6

;---------

Blub:
	move.l	SwapScreen(PC),CurScreen
	addq.w	#1,d7
	add.w	#24,a5
	cmp.w	#-1,(a5)
	bne.w	DrawNext

WTF0:
	cmp.b	#$f0,$dff006
	bne.s	WTF0
WTF1:
	cmp.b	#$f0,$dff006
	beq.s	WTF1

	not.b	SwapFlag
	beq.s	Evenf
	move.l	#plane1,CurScreen
	move.l	#plane1,SwapScreen
	bra.s	Pluz
Evenf:
	move.l	#plane5,CurScreen
	move.l	#plane5,SwapScreen
Pluz:
	move.l	CurScreen(PC),d0
	LEA	BplPointers,A0	  ; indirizzo puntatori nella copperlist.
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

; Clear Screen

	btst	#6,$dff002
CLS:
	btst	#6,$dff002
	bne.s	CLS

	move.w	#0,$dff066			; D modulo
	move.l	SwapScreen(PC),$dff054		; D pointer
	move.w	#$0000,$dff042			; bltcon 1
	move.w	#$0100,$dff040			; bltcon 0
	move.w	#$4014,$dff058			; bltsize
NoDel:
	tst.w	LastN
	beq.s	Gollum
	addq.w	#1,LastN
Gollum:
	addq.b	#1,FrameN
	cmp.b	#FRAMES,FrameN
	bne.w	NEXTFRAME
	sf	FrameN
	lea	LinesData(PC),a4
	bra.w	NEXTFRAME

Exit:
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

***************************************
***	VBLANK IRQ HANDLER   ($6c)  ***
***************************************

	cnop	0,4

NewIRQ:
	btst.b	#5,$dff01f	; INTREQR - il bit 5, VERTB, e' azzerato?
	beq.w	NOIRQ_6c	; Se si, non e' un "vero" int VERTB!
	movem.l	d0-d7/a0-a6,-(sp)

; Ora gestiamo il punto generatore che ondeggia nello schermo.
; Prima deletiamo il vecchio

	moveq	#0,d0
	moveq	#0,d1
	move.w	GunX(PC),d0
	move.w	GunY(PC),d1
	move.w	d0,OldGunX
	move.w	d1,OldGunY
	move.l	SavedSCR(PC),a0	; plane destinazione

;	a0 = Indirizzo bitplane destinazione
;	d0.w = Coordinata X (0-319)
;	d1.w = Coordinata Y (0-255)

	move.w	d0,d2		; Copia la coordinata X in d2
	lsr.w	#3,d0		; Intanto trova l'offset orizzontale,
	mulu.w	#40,d1		; offset y (Y* larghschermo)
	add.w	d1,d0		; Somma lo scostam. vert. a quello orizzontale
	and.w	#%111,d2	; Seleziona solo i primi 3 bit di X, ossia
	not.w	d2		; opportunamente nottato
	bclr.b	d2,(a0,d0.w)	; Azzera il bit d2 all'ofsset giusto

; Ora stabiliamo la nuova posizione: leggiamo i valori di ADD

	lea	SinPX0(PC),a0	;Moto Armonico {
	move.w	(a0),d0		; x0
	move.w	2(a0),d2	; x1
	move.w	4(a0),d1	; y0
	move.w	6(a0),d3	; y1

; addiamoli

	add.w	#10,d0		; Inc MA pts (EVEN values)
	addq.w	#6,d2
	addq.w	#8,d1
	add.w	#14,d3

	move.w	#2047,d4	; max value
	and.w	d4,d0
	and.w	d4,d2
	and.w	d4,d1
	and.w	d4,d3

; e salviamoli

	move.w	d0,(a0)		; x0
	move.w	d2,2(a0)	; x1
	move.w	d1,4(a0)	; y0
	move.w	d3,6(a0)	; y1

; Ora prendiamo i valori dalla sintab e li salviamo per i prossimo step

	lea	SinTab(pc),a1
	move.w	(a1,d0.w),d0
	move.w	(a1,d2.w),d2
	move.w	(a1,d1.w),d1
	move.w	(a1,d3.w),d3

	add.w	d2,d0	; X
	add.w	d3,d1	; Y
	asr.w	#4,d0	; /16
	asr.w	#4,d1	; /16
	add.w	#160,d0	; centraX
	add.w	#128,d1	; centraY
	move.w	d0,GunX
	move.w	d1,GunY

; plottiamo il nuovo punto

	move.l	CurScreen(PC),a0	; plane destinazione
	move.l	a0,SavedSCR

;	a0 = Indirizzo bitplane destinazione
;	d0.w = Coordinata X (0-319)
;	d1.w = Coordinata Y (0-255)

	move.w	d0,d2		; Copia la coordinata X in d2
	lsr.w	#3,d0		; Intanto trova l'offset orizzontale,
	mulu.w	#40,d1		; offset y (Y* larghschermo)
	add.w	d1,d0		; Somma lo scostam. vert. a quello orizzontale
	and.w	#%111,d2	; Seleziona solo i primi 3 bit di X, ossia
	not.w	d2		; opportunamente nottato
	bset.b	d2,(a0,d0.w)	; Setta il bit d2 all'ofsset giusto

	movem.l	(sp)+,d0-d7/a0-a6
NOIRQ_6c:
	move.w	#%1110000,$dff09c ; INTREQ - cancello rich. BLIT,VERTB e COPER
	rte	; uscita dall'int COPER/BLIT/VERTB

SavedSCR:
	dc.l	0

	cnop	0,4
SinPX0:	dc.w	1000	;MotArm X0
SinPX1:	dc.w	1800	;MotArm X1
SinPY0:	dc.w	900	;MotArm Y0
SinPY1:	dc.w	0	;MotArm Y1

	cnop	0,4
GunX:	dc.w	0	;Gun X pos

	cnop	0,4
GunY:	dc.w	0	;Gun Y pos

	cnop	0,4
OldGunX:dc.w	0	;Gun X pos old

	cnop	0,4
OldGunY:dc.w	0	;Gun Y pos old

	cnop	0,4
TxtPnt:	dc.l	Text	;Pointer to current character in the text

	cnop	0,4
CurX:	dc.w	0	;Cursor X pos

	cnop	0,4
CurY:	dc.w	0	;Cursor Y pos

	cnop	0,4
StrVal:	dc.w	0	;Stretch value (0 = 1:1)

	cnop	0,4
AtLins:dc.w	0	;Number of lines activated

	cnop	0,4
LastN:	dc.w	0	;Last lines to draw (used at end of page)

	cnop	0,4
MenoUno:dc.w	-1	;Fake location for startup

	cnop	0,4
FrameN:	dc.b	0	;Frame number counter (compare with FRAMES)

	cnop	0,4
SwapFlag: dc.b	0	;Boolean flag for SwapScreen control

	cnop	0,4
ACapo:	dc.b	0	;Flag for CR handling

	cnop	0,4

CurScreen:	dc.l	plane1
SwapScreen:	dc.l	plane1
;---------------------------------------

*****************************************************************************

	cnop	0,4
SinTab:
	dc.w	0,6,13,$13,$19,$1F,$26,$2C,$32,$39,$3F,$45,$4B
	dc.w	$52,$58,$5E,$65,$6B,$71,$77,$7E,$84,$8A,$90,$97
	dc.w	$9D,$A3,$A9,$AF,$B6,$BC,$C2,$C8,$CE,$D4,$DB,$E1
	dc.w	$E7,$ED,$F3,$F9,$FF,$105,$10B,$112,$118,$11E,$124
	dc.w	$12A,$130,$136,$13C,$142,$148,$14E,$154,$15A,$15F
	dc.w	$165,$16B,$171,$177,$17D,$183,$188,$18E,$194,$19A
	dc.w	$1A0,$1A5,$1AB,$1B1,$1B7,$1BC,$1C2,$1C7,$1CD,$1D3
	dc.w	$1D8,$1DE,$1E3,$1E9,$1EF,$1F4,$1F9,$1FF,$204,$20A
	dc.w	$20F,$215,$21A,$21F,$225,$22A,$22F,$235,$23A,$23F
	dc.w	$244,$249,$24E,$254,$259,$25E,$263,$268,$26D,$272
	dc.w	$277,$27C,$281,$286,$28B,$28F,$294,$299,$29E,$2A3
	dc.w	$2A7,$2AC,$2B1,$2B5,$2BA,$2BE,$2C3,$2C8,$2CC,$2D1
	dc.w	$2D5,$2D9,$2DE,$2E2,$2E7,$2EB,$2EF,$2F3,$2F8,$2FC
	dc.w	$300,$304,$308,$30C,$310,$315,$319,$31C,$320,$324
	dc.w	$328,$32C,$330,$334,$337,$33B,$33F,$343,$346,$34A
	dc.w	$34D,$351,$354,$358,$35B,$35F,$362,$365,$369,$36C
	dc.w	$36F,$372,$376,$379,$37C,$37F,$382,$385,$388,$38B
	dc.w	$38E,$391,$394,$396,$399,$39C,$39F,$3A1,$3A4,$3A6
	dc.w	$3A9,$3AB,$3AE,$3B0,$3B3,$3B5,$3B8,$3BA,$3BC,$3BE
	dc.w	$3C1,$3C3,$3C5,$3C7,$3C9,$3CB,$3CD,$3CF,$3D1,$3D3
	dc.w	$3D5,$3D6,$3D8,$3DA,$3DB,$3DD,$3DF,$3E0,$3E2,$3E3
	dc.w	$3E5,$3E6,$3E8,$3E9,$3EA,$3EC,$3ED,$3EE,$3EF,$3F0
	dc.w	$3F1,$3F2,$3F3,$3F4,$3F5,$3F6,$3F7,$3F8,$3F9,$3F9
	dc.w	$3FA,$3FB,$3FB,$3FC,$3FC,$3FD,$3FD,$3FE,$3FE,$3FF
	dc.w	$3FF,$3FF,$3FF,$400,$400,$400,$400,$400,$400,$400
	dc.w	$400,$400,$400,$3FF,$3FF,$3FF,$3FF,$3FE,$3FE,$3FD
	dc.w	$3FD,$3FD,$3FC,$3FB,$3FB,$3FA,$3F9,$3F9,$3F8,$3F7
	dc.w	$3F6,$3F5,$3F4,$3F4,$3F3,$3F1,$3F0,$3EF,$3EE,$3ED
	dc.w	$3EC,$3EA,$3E9,$3E8,$3E6,$3E5,$3E4,$3E2,$3E1,$3DF
	dc.w	$3DD,$3DC,$3DA,$3D8,$3D7,$3D5,$3D3,$3D1,$3CF,$3CD
	dc.w	$3CB,$3C9,$3C7,$3C5,$3C3,$3C1,$3BF,$3BC,$3BA,$3B8
	dc.w	$3B6,$3B3,$3B1,$3AE,$3AC,$3A9,$3A7,$3A4,$3A2,$39F
	dc.w	$39C,$399,$397,$394,$391,$38E,$38B,$388,$385,$382
	dc.w	$37F,$37C,$379,$376,$373,$370,$36C,$369,$366,$363
	dc.w	$35F,$35C,$358,$355,$351,$34E,$34A,$347,$343,$33F
	dc.w	$33C,$338,$334,$330,$32D,$329,$325,$321,$31D,$319
	dc.w	$315,$311,$30D,$309,$305,$301,$2FD,$2F8,$2F4,$2F0
	dc.w	$2EC,$2E7,$2E3,$2DE,$2DA,$2D6,$2D1,$2CD,$2C8,$2C4
	dc.w	$2BF,$2BB,$2B6,$2B1,$2AD,$2A8,$2A3,$29E,$29A,$295
	dc.w	$290,$28B,$286,$281,$27D,$278,$273,$26E,$269,$264
	dc.w	$25F,$259,$254,$24F,$24A,$245,$240,$23A,$235,$230
	dc.w	$22B,$225,$220,$21B,$215,$210,$20B,$205,$200,$1FA
	dc.w	$1F5,$1EF,$1EA,$1E4,$1DF,$1D9,$1D4,$1CE,$1C8,$1C3
	dc.w	$1BD,$1B7,$1B2,$1AC,$1A6,$1A0,$19B,$195,$18F,$189
	dc.w	$184,$17E,$178,$172,$16C,$166,$160,$15A,$154,$14F
	dc.w	$149,$143,$13D,$137,$131,$12B,$125,$11F,$118,$112
	dc.w	$10C,$106,$100,$FA,$F4,$EE,$E8,$E2,$DB,$D5,$CF
	dc.w	$C9,$C3,$BD,$B6,$B0,$AA,$A4,$9E,$97,$91,$8B,$85
	dc.w	$7E,$78,$72,$6C,$65,$5F,$59,$53,$4C,$46,$40,$3A
	dc.w	$33,$2D,$27,$20,$1A,$14,13,7,1,$FFFB,$FFF4,$FFEE
	dc.w	$FFE8,$FFE1,$FFDB,$FFD5,$FFCF,$FFC8,$FFC2,$FFBC
	dc.w	$FFB5,$FFAF,$FFA9,$FFA3,$FF9C,$FF96,$FF90,$FF8A
	dc.w	$FF83,$FF7D,$FF77,$FF71,$FF6A,$FF64,$FF5E,$FF58
	dc.w	$FF52,$FF4B,$FF45,$FF3F,$FF39,$FF33,$FF2C,$FF26
	dc.w	$FF20,$FF1A,$FF14,$FF0E,$FF08,$FF02,$FEFB,$FEF5
	dc.w	$FEEF,$FEE9,$FEE3,$FEDD,$FED7,$FED1,$FECB,$FEC5
	dc.w	$FEBF,$FEB9,$FEB3,$FEAD,$FEA7,$FEA1,$FE9B,$FE96
	dc.w	$FE90,$FE8A,$FE84,$FE7E,$FE78,$FE73,$FE6D,$FE67
	dc.w	$FE61,$FE5B,$FE56,$FE50,$FE4A,$FE45,$FE3F,$FE39
	dc.w	$FE34,$FE2E,$FE28,$FE23,$FE1D,$FE18,$FE12,$FE0D
	dc.w	$FE07,$FE02,$FDFC,$FDF7,$FDF2,$FDEC,$FDE7,$FDE1
	dc.w	$FDDC,$FDD7,$FDD2,$FDCC,$FDC7,$FDC2,$FDBD,$FDB7
	dc.w	$FDB2,$FDAD,$FDA8,$FDA3,$FD9E,$FD99,$FD94,$FD8F
	dc.w	$FD8A,$FD85,$FD80,$FD7B,$FD76,$FD71,$FD6C,$FD68
	dc.w	$FD63,$FD5E,$FD59,$FD55,$FD50,$FD4B,$FD47,$FD42
	dc.w	$FD3E,$FD39,$FD35,$FD30,$FD2C,$FD27,$FD23,$FD1E
	dc.w	$FD1A,$FD16,$FD11,$FD0D,$FD09,$FD05,$FD01,$FCFC
	dc.w	$FCF8,$FCF4,$FCF0,$FCEC,$FCE8,$FCE4,$FCE0,$FCDC
	dc.w	$FCD8,$FCD4,$FCD1,$FCCD,$FCC9,$FCC5,$FCC2,$FCBE
	dc.w	$FCBA,$FCB7,$FCB3,$FCB0,$FCAC,$FCA9,$FCA5,$FCA2
	dc.w	$FC9E,$FC9B,$FC98,$FC94,$FC91,$FC8E,$FC8B,$FC88
	dc.w	$FC85,$FC82,$FC7E,$FC7B,$FC78,$FC76,$FC73,$FC70
	dc.w	$FC6D,$FC6A,$FC67,$FC65,$FC62,$FC5F,$FC5D,$FC5A
	dc.w	$FC57,$FC55,$FC52,$FC50,$FC4E,$FC4B,$FC49,$FC46
	dc.w	$FC44,$FC42,$FC40,$FC3E,$FC3B,$FC39,$FC37,$FC35
	dc.w	$FC33,$FC31,$FC2F,$FC2E,$FC2C,$FC2A,$FC28,$FC26
	dc.w	$FC25,$FC23,$FC21,$FC20,$FC1E,$FC1D,$FC1B,$FC1A
	dc.w	$FC19,$FC17,$FC16,$FC15,$FC13,$FC12,$FC11,$FC10
	dc.w	$FC0F,$FC0E,$FC0D,$FC0C,$FC0B,$FC0A,$FC09,$FC08
	dc.w	$FC08,$FC07,$FC06,$FC05,$FC05,$FC04,$FC04,$FC03
	dc.w	$FC03,$FC02,$FC02,$FC01,$FC01,$FC01,$FC01,$FC00
	dc.w	$FC00,$FC00,$FC00,$FC00,$FC00,$FC00,$FC00,$FC00
	dc.w	$FC00,$FC01,$FC01,$FC01,$FC01,$FC02,$FC02,$FC02
	dc.w	$FC03,$FC03,$FC04,$FC05,$FC05,$FC06,$FC06,$FC07
	dc.w	$FC08,$FC09,$FC0A,$FC0A,$FC0B,$FC0C,$FC0D,$FC0E
	dc.w	$FC0F,$FC11,$FC12,$FC13,$FC14,$FC15,$FC17,$FC18
	dc.w	$FC19,$FC1B,$FC1C,$FC1E,$FC1F,$FC21,$FC22,$FC24
	dc.w	$FC26,$FC27,$FC29,$FC2B,$FC2D,$FC2F,$FC31,$FC32
	dc.w	$FC34,$FC36,$FC38,$FC3B,$FC3D,$FC3F,$FC41,$FC43
	dc.w	$FC45,$FC48,$FC4A,$FC4C,$FC4F,$FC51,$FC54,$FC56
	dc.w	$FC59,$FC5B,$FC5E,$FC61,$FC63,$FC66,$FC69,$FC6C
	dc.w	$FC6F,$FC71,$FC74,$FC77,$FC7A,$FC7D,$FC80,$FC83
	dc.w	$FC86,$FC89,$FC8D,$FC90,$FC93,$FC96,$FC9A,$FC9D
	dc.w	$FCA0,$FCA4,$FCA7,$FCAB,$FCAE,$FCB2,$FCB5,$FCB9
	dc.w	$FCBC,$FCC0,$FCC4,$FCC7,$FCCB,$FCCF,$FCD3,$FCD7
	dc.w	$FCDB,$FCDE,$FCE2,$FCE6,$FCEA,$FCEE,$FCF2,$FCF6
	dc.w	$FCFB,$FCFF,$FD03,$FD07,$FD0B,$FD10,$FD14,$FD18
	dc.w	$FD1D,$FD21,$FD25,$FD2A,$FD2E,$FD33,$FD37,$FD3C
	dc.w	$FD40,$FD45,$FD49,$FD4E,$FD53,$FD57,$FD5C,$FD61
	dc.w	$FD66,$FD6A,$FD6F,$FD74,$FD79,$FD7E,$FD83,$FD88
	dc.w	$FD8D,$FD92,$FD97,$FD9C,$FDA1,$FDA6,$FDAB,$FDB0
	dc.w	$FDB5,$FDBA,$FDC0,$FDC5,$FDCA,$FDCF,$FDD5,$FDDA
	dc.w	$FDDF,$FDE4,$FDEA,$FDEF,$FDF5,$FDFA,$FDFF,$FE05
	dc.w	$FE0A,$FE10,$FE15,$FE1B,$FE21,$FE26,$FE2C,$FE31
	dc.w	$FE37,$FE3D,$FE42,$FE48,$FE4E,$FE53,$FE59,$FE5F
	dc.w	$FE64,$FE6A,$FE70,$FE76,$FE7C,$FE81,$FE87,$FE8D
	dc.w	$FE93,$FE99,$FE9F,$FEA5,$FEAB,$FEB1,$FEB7,$FEBD
	dc.w	$FEC3,$FEC9,$FECF,$FED5,$FEDB,$FEE1,$FEE7,$FEED
	dc.w	$FEF3,$FEF9,$FEFF,$FF05,$FF0B,$FF11,$FF17,$FF1E
	dc.w	$FF24,$FF2A,$FF30,$FF36,$FF3C,$FF42,$FF49,$FF4F
	dc.w	$FF55,$FF5B,$FF61,$FF68,$FF6E,$FF74,$FF7A,$FF81
	dc.w	$FF87,$FF8D,$FF93,$FF9A,$FFA0,$FFA6,$FFAC,$FFB3
	dc.w	$FFB9,$FFBF,$FFC6,$FFCC,$FFD2,$FFD8,$FFDF,$FFE5
	dc.w	$FFEB,$FFF2,$FFF8,$FFFE,4


CharsData:	; Vector-Characters definitions (x0,y0,y1,y1, ... ,-1)
Ch:
	dc.w	-1
ChEscl:
	dc.w	3,0,4,0, 4,0,4,3, 4,3,3,3, 3,3,3,0
	dc.w	3,5,4,5, 4,5,4,6, 4,6,3,6, 3,6,3,5, -1
ChVirgtt:
	dc.w	2,0,2,1, 4,0,4,1, -1
ChNumb:
	dc.w	2,0,2,6, 4,0,4,6, 0,2,6,2, 0,4,6,4, -1
ChString:
	dc.w	-1
ChPercent:
	dc.w	0,6,6,0, 0,0,1,0, 1,0,1,1, 1,1,0,1, 0,1,0,0, 6,6,5,6
	dc.w	5,6,5,5, 5,5,6,5, 6,5,6,6, -1
ChAnd:
	dc.w	-1
ChApice:
	dc.w	3,0,4,0, 4,0,4,1, 4,1,3,2, -1
ChAperta:
	dc.w	4,0,3,0, 3,0,2,1, 2,1,2,5, 2,5,3,6, 3,6,5,6, -1
ChChiusa:
	dc.w	2,0,3,0, 3,0,4,1, 4,1,4,5, 4,5,3,6, 3,6,2,6, -1
ChPer:
	dc.w	0,3,6,3, 3,0,3,6, 1,1,5,5, 1,5,5,1, -1
ChPiu:
	dc.w	3,1,3,5, 0,3,5,3, -1
ChVirgola:
	dc.w	3,5,4,5, 4,5,4,6, 4,6,3,7, -1
ChMeno:
	dc.w	0,3,5,3, -1
ChPunto:
	dc.w	3,5,4,5, 4,5,4,6, 4,6,3,6, 3,6,3,5, -1
ChSlash:
	dc.w	0,6,6,0, -1
Ch0:
	dc.w	0,1,1,0, 1,0,5,0, 5,0,6,1, 6,1,6,5, 6,5,5,6, 5,6,1,6
	dc.w	1,6,0,5, 0,5,0,1, 3,2,3,4, -1
Ch1:
	dc.w	3,0,3,6, 1,6,5,6, 1,2,3,0, -1
Ch2:
	dc.w	6,6,0,6, 0,6,0,4, 0,4,1,3, 1,3,5,3, 5,3,6,2, 6,2,6,1
	dc.w	6,1,5,0, 5,0,1,0, 1,0,0,1, -1
Ch3:
	dc.w	0,5,1,6, 1,6,5,6, 5,6,6,5, 6,5,6,4, 6,4,5,3, 5,3,3,3
	dc.w	5,3,6,2, 6,2,6,1, 6,1,5,0, 5,0,1,0, 1,0,0,1, -1
Ch4:
	dc.w	5,0,5,6, 6,4,0,4, 0,4,5,0, -1
Ch5:
	dc.w	6,0,0,0, 0,0,0,2, 0,2,5,2, 5,2,6,3, 6,3,6,5, 0,4,0,5
	dc.w	0,5,1,6, 1,6,5,6, 5,6,6,5, -1
Ch6:
	dc.w	6,1,5,0, 5,0,1,0, 1,0,0,1, 0,1,0,5, 0,5,1,6, 1,6,5,6
	dc.w	5,6,6,5, 6,5,6,4, 6,4,5,3, 5,3,0,3, -1
Ch7:
	dc.w	0,0,6,0, 6,0,6,1, 6,1,2,5, 2,5,6,5, -1
Ch8:
	dc.w	1,0,5,0, 5,0,6,1, 6,1,6,2, 6,2,5,3, 5,3,6,4, 6,4,6,5
	dc.w	6,5,5,6, 5,6,1,6, 1,6,0,5, 0,5,0,4, 0,4,1,3, 1,3,0,2
	dc.w	0,2,0,1, 0,1,1,0, 1,3,5,3, -1
Ch9:
	dc.w	0,5,1,6, 1,6,5,6, 5,6,6,5, 6,5,6,1, 6,1,5,0, 5,0,1,0
	dc.w	1,0,0,1, 0,1,0,2, 0,2,1,3, 1,3,6,3, -1
ChDueP:
	dc.w	3,5,4,5, 4,5,4,6, 4,6,4,6, 3,6,3,5
	dc.w	3,0,3,1, 3,1,4,1, 4,1,4,0, 4,0,3,0, -1
ChPuntEV:
	dc.w	3,5,4,5, 4,5,4,6, 4,6,3,7
	dc.w	3,1,3,2, 3,2,4,2, 4,2,4,1, 4,1,3,1, -1
ChMin:
	dc.w	4,1,2,3, 2,3,4,5, -1
ChUgual:
	dc.w	1,2,5,2, 1,4,5,4, -1
ChMag:
	dc.w	2,1,4,3, 4,3,2,5, -1
ChInterr:
	dc.w	-1
ChAt:
	dc.w	-1
ChA:
	dc.w	3,0,0,3, 0,3,0,6, 3,0,6,3, 6,3,6,6, 0,4,6,4, -1
ChB:
	dc.w	0,0,0,6, 0,0,5,0, 5,0,6,1, 6,1,6,2, 6,2,5,3, 5,3,6,4, 6,4,6,5
	dc.w	6,5,5,6, 5,6,0,6, 0,3,5,3, -1
ChC:
	dc.w	6,1,5,0, 5,0,1,0, 1,0,0,1, 0,1,0,5, 0,5,1,6, 1,6,5,6, 5,6,6,5, -1
ChD:
	dc.w	0,0,0,6, 0,6,4,6, 4,6,6,4, 6,4,6,2, 6,2,4,0, 4,0,0,0, -1
ChE:
	dc.w	0,0,0,6, 0,0,6,0, 0,3,5,3, 0,6,6,6, -1
ChF:
	dc.w	0,0,0,6, 0,0,6,0, 0,3,5,3, -1
ChG:
	dc.w	6,1,5,0, 5,0,1,0, 1,0,0,1, 0,1,0,5, 0,5,1,6, 1,6,5,6, 5,6,6,5
	dc.w	6,5,6,3, 6,3,4,3, -1
ChH:
	dc.w	0,0,0,6, 0,3,6,3, 6,0,6,6, -1
ChI:
	dc.w	1,0,5,0, 1,6,5,6, 3,0,3,6, -1
ChJ:
	dc.w	0,5,1,6, 1,6,5,6, 5,6,6,5, 6,5,6,0, 6,0,4,0, -1
ChK:
	dc.w	0,0,0,6, 0,3,3,3, 3,3,6,0, 3,3,6,6, -1
ChL:
	dc.w	0,0,0,6, 0,6,6,6, -1
ChM:
	dc.w	0,0,0,6, 0,0,3,3, 3,3,6,0, 6,0,6,6, -1
ChN:
	dc.w	0,0,0,6, 0,0,6,6, 6,6,6,0, -1
ChO:
	dc.w	6,1,5,0, 5,0,1,0, 1,0,0,1, 0,1,0,5, 0,5,1,6, 1,6,5,6, 5,6,6,5
	dc.w	6,5,6,1, -1
ChP:
	dc.w	0,0,0,6, 0,0,5,0, 5,0,6,1, 6,1,6,2, 6,2,5,3, 5,3,0,3, -1
ChQ:
	dc.w	6,1,5,0, 5,0,1,0, 1,0,0,1, 0,1,0,5, 0,5,1,6, 1,6,5,6, 5,6,6,5
	dc.w	6,5,6,1, 5,5,7,7,  -1
ChR:
	dc.w	0,0,0,6, 0,0,5,0, 5,0,6,1, 6,1,6,2, 6,2,5,3, 5,3,0,3
	dc.w	4,3,6,6, -1
ChS:
	dc.w	5,0,1,0, 1,0,0,1, 0,1,0,2, 0,2,1,3, 1,3,5,3, 5,3,6,4
	dc.w	6,4,6,5, 6,5,5,6, 5,6,0,6, -1
ChT:
	dc.w	0,0,6,0, 3,0,3,6, -1
ChU:
	dc.w	0,0,0,5, 0,5,1,6, 1,6,5,6, 5,6,6,5, 6,5,6,0, -1
ChV:
	dc.w	0,0,3,6, 3,6,6,0, -1
ChW:
	dc.w	0,0,0,5, 0,5,1,6, 1,6,3,4, 3,4,5,6, 5,6,6,5, 6,5,6,0, -1
ChX:
	dc.w	6,0,0,6, 0,0,6,6, -1
ChY:
	dc.w	0,0,3,3, 3,3,3,6, 3,3,6,0, -1
ChZ:
	dc.w	6,6,0,6, 0,6,6,0, 6,0,0,0, -1
ChQAperta:
	dc.w	4,0,2,0, 2,0,2,6, 2,6,4,6, -1
ChBSlash:
	dc.w	0,0,6,6, -1
ChQChiusa:
	dc.w	4,0,2,0, 4,0,4,6, 2,6,4,6, -1


	cnop	0,4

CharsOffs:
	dc.l	Ch
	dc.l	ChEscl
	dc.l	ChVirgtt
	dc.l	ChNumb
	dc.l	ChString
	dc.l	ChPercent
	dc.l	ChAnd
	dc.l	ChApice
	dc.l	ChAperta
	dc.l	ChChiusa
	dc.l	ChPer
	dc.l	ChPiu
	dc.l	ChVirgola
	dc.l	ChMeno
	dc.l	ChPunto
	dc.l	ChSlash
	dc.l	Ch0
	dc.l	Ch1
	dc.l	Ch2
	dc.l	Ch3
	dc.l	Ch4
	dc.l	Ch5
	dc.l	Ch6
	dc.l	Ch7
	dc.l	Ch8
	dc.l	Ch9
	dc.l	ChDueP
	dc.l	ChPuntEV
	dc.l	ChMin
	dc.l	ChUgual
	dc.l	ChMag
	dc.l	ChInterr
	dc.l	ChAt
	dc.l	ChA
	dc.l	ChB
	dc.l	ChC
	dc.l	ChD
	dc.l	ChE
	dc.l	ChF
	dc.l	ChG
	dc.l	ChH
	dc.l	ChI
	dc.l	ChJ
	dc.l	ChK
	dc.l	ChL
	dc.l	ChM
	dc.l	ChN
	dc.l	ChO
	dc.l	ChP
	dc.l	ChQ
	dc.l	ChR
	dc.l	ChS
	dc.l	ChT
	dc.l	ChU
	dc.l	ChV
	dc.l	ChW
	dc.l	ChX
	dc.l	ChY
	dc.l	ChZ
	dc.l	ChQAperta
	dc.l	ChBSlash
	dc.l	ChQChiusa

;------------------------------------------------------
;	0	: End Of Page
;	1 to 9	: stretchvals
;	10	: CR
;	11,x,y	: Set cursor x,y pos (pixels)

;------------------------------------------------------

Text:
	dc.b	11,0,0
	dc.b	2," MOST ORIGINAL BBS",10
	dc.b	11,0,200,2,"5 - PUBLIC ENEMY",10
	DC.B	11,64,220,1,"[INDEPENDENT]",10
	dc.b	11,0,160,2,"4 - STRANGELAND",10
	DC.B	11,64,180,1,"(HERESY)",10
	dc.b	11,0,120,2,"3 - HEART OF NOWHERE",10
	DC.B	11,64,140,1,"(MOTION)",10
	dc.b	11,0,80,2,"2 - ASYLUM",10
	DC.B	11,64,100,1,"(COPYRIGHT DESTROYERS INC.)",10
	dc.b	11,0,40,2,"1 - INFINTE DREAMS",10
	DC.B	11,64,60,1,"(HALF-BRAINS TEAM) ",10
	dc.b	0

Text1:
	dc.b	11,0,0
	dc.b	3," BEST BBS",10
	dc.b	11,0,200,2,"5 - ASYLUM",10
	DC.B	11,64,220,1,"(COPYRIGHT DESTROYERS INC.)",10
	dc.b	11,0,160,2,"4 - TEMPLE OF GURUS",10
	DC.B	11,64,180,1,"(TECHNOBRAINS)",10
	dc.b	11,0,120,2,"3 - STRANGE LAND",10
	DC.B	11,64,140,1,"(HERESY)",10
	dc.b	11,0,80,2,"2 - TEMPLE OF DESTR.",10
	DC.B	11,64,100,1,"(DIVINA)",10
	dc.b	11,0,40,2,"1 - THE HOUSE",10
	DC.B	11,64,60,1,"(ITALIAN BAD BOYS) ",10
	dc.b	0

	dc.b	-1


	cnop	0,4

LinesData:	; dc.w	X0,Y0,X1,Y1,dX0,dY0,dX1,dY1,sX0,sY0,sX1,sY1
		dcb.w	12*(FRAMES+1),-1

*****************************************************************************

	Section	miacopper,data_C

NewCList:
	dc.w	$8e,$2c81	; DiwStart
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,$24	; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

	dc.w	$100,$2200	; bplcon0 - 5 BitPlanes

bplpointers:
	dc.w    $e0,0,$e2,0
	dc.w	$e4,0,$e6,0

; Set color registers:

	dc.w	$0180,$0000	; color0 - nero (sfondo)
	dc.w	$0182,$0ff0	; color1 - giallo (cursore e gunwriter)
	dc.w	$0184,$0fff	; color2 - bianco (lettere fermate)
	dc.w	$0186,$0ff0	; color3 - giallo (gunwriter+lettere)

	dc.w    $ffff,$fffe		;end of CList

*****************************************************************************

	section	straplane,bss_C

plane1:
	ds.b	40*256
plane2:
	ds.b	40*256
plane5:
	ds.b	40*256


	end

