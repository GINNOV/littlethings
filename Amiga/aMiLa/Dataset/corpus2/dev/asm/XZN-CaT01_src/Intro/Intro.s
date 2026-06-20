
	Section	codice,CODE

	incdir	"dh1:programs/asmone/modem/intro/"

	Include	"DaWorkBench.s"
	include	"startup2.s"

		;5432109876543210
DMASET	EQU	%1000001110000000	; copper e bitplane abilitati

WAITDISK	equ	10

START:
	movem.l	d0-d7/a0-a6,-(SP)	; setto la musica
	lea	P61_data,a0	; Indirizzo del modulo in a0
	lea	$dff000,a6	; Ricordiamoci il $dff000 in a6!
	sub.l	a1,a1		; I samples non sono a parte, mettiamo zero
	sub.l	a2,a2		; no samples -> modulo non compattato
	jsr	P61_Init
	movem.l	(SP)+,d0-d7/a0-a6

	move.l	BaseVbr(PC),A1
	move.l	#MyInt6c,$6C(A1)
	move.w	#DMASET,$96(a5)		; DMACON - abilita bitplane e copper
	move.w	#$e020,$9a(a5)		; INTENA - Abilito Master and lev6

	move.l	#MEMPIC1,d0
	lea	BPLPOINTERS,A1	
	moveq	#4-1,D7

POINTB:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#$2800,d0
	addq.w	#8,a1
	dbra	d7,POINTB

	move.l	#COPPERLIST,$dff080
	move.w	d0,$dff088

	clr.l	VBcounter

LOGOWBLANY1:
	bsr.w	WBLAN

	bsr.w	MAINFADEINOUT

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#255,VBcounter
	blo.s	LOGOWBLANY1

	clr.l	VBcounter

LOGOWBLANY3:
	bsr.w	WBLAN

	addq.l	#1,cacca
	cmpi.l	#3,cacca	; fa stampare il testo ogni 3 fotogrammi
	blo.s	LOGOWBLANY3	; grazie al semiflag cacca
	clr.l	cacca

	bsr.w	PRINTCARATTERE

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#120,VBcounter
	blo.s	LOGOWBLANY3

	clr.l	VBcounter


	; parte dove schiaccia pics


MOUSE:
	bsr.w	WBLAN

	bsr.w	SCHIACCIA
	bsr.w	MAINFADEINOUT
	bsr.w	MAINFADEINOUT
	bsr.w	MAINFADEINOUT
	bsr.w	MAINFADEINOUT

	btst	#6,$bfe001	; LMB premuto?
	beq.w	ESCI		; se no ripeti

	cmpi.l	#1,CAZZONE	; cazzone e' un flag che viene ativato quando
	blo.s	MOUSE		; la pic e' stata schiacciata del tutto!

	clr.l	VBcounter


WBLANY:
	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#50,VBcounter
	blo.s	WBLANY

	clr.l	VBcounter

	lea 	BPLVUOTO,a1
	move.l	#VUOTO,d0

 	move.w	d0,6(a1)
 	swap	d0
 	move.w	d0,2(a1)
 	swap	d0

	move.l	#COPVUOTO,$80(a5)
	move.w	d0,$88(a5)

WBLANY1:
	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#5,VBcounter
	blo.s	WBLANY1

	clr.l	VBcounter


	; Qui mostra il putto che poppa (e poppa anche la potta) :-) 	


	move.l	#MEMPIC2,d0
	lea	BPLPOINTERS2,A1	
	moveq	#4-1,D7
CAZZO:
 	move.w	d0,6(a1)
 	swap	d0
 	move.w	d0,2(a1)
 	swap	d0
	add.l	#$2800,d0
	addq.w	#8,a1
	dbra	d7,CAZZO
	
	move.l	#VUOTO,d0
	lea	BPLPOINTERS3,A1	
 	move.w	d0,6(a1)
 	swap	d0
 	move.w	d0,2(a1)
 	swap	d0

	move.l	#COPPERLIST2,$dff080
	move.w	d0,$dff088

	move.w	#0,$dff1fc		; Disattiva l'AGA
	move.w	#$c00,$dff106		; Disattiva l'AGA

WBLANY2:
	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#120,VBcounter
	blo.s	WBLANY2

	clr.l	VBcounter


	; Qui far fare l'apparizione del testo

	clr.l	CACCA
	
	jsr	PRINTATESTO

WBLANY3:
	bsr.w	WBLAN

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.s	ESCI

	addq.l	#1,CACCA
	cmpi.l	#5,CACCA
	blo.s	WBLANY3		; semiflag cacca
	clr.l	CACCA

	lea	CSTART-2,a1
	lea	CEND-2,a2
	jsr	DOFADE

	cmpi.l	#85,VBcounter
	blo.s	WBLANY3

	clr.l	VBcounter

WBLANY4:
	bsr.w	WBLAN

	jsr	RIMBALZO

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	bne.w	WBLANY4

	clr.l	VBcounter

ESCI:
	lea	$dff000,a6	; stoppo la musica
	jsr	P61_End
	rts			; esci


******************************************************************************
;			ROUTINE CHE ASPETTA IL VBL
******************************************************************************

WBLAN:
	move.l	$dff004,d0
	and.l	#$0001ff00,d0
	cmp.l	#$00012b00,d0
	bne.s	WBLAN
WBLAN1:
	move.l	$dff004,d0
	and.l	#$0001ff00,d0
	cmp.l	#$00012b00,d0
	beq.s	WBLAN1
	rts


******************************************************************************
			; Interrupt level 3, VERTB...
******************************************************************************

	cnop	0,4
MyInt6c:
	BTST	#5,$DFF01F
	beq.s	NoIntVertb
	MOVEM.L	D0-D7/A0-A6,-(SP)
	ST	FrameFlagCounter
	addq.l	#1,VBcounter
	MOVEM.L	(SP)+,D0-D7/A0-A6
NoIntVertb:
	BTST	#4,$DFF01F
	beq.s	NoIntCoper
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVEM.L	(SP)+,D0-D7/A0-A6
NoIntCoper:
	MOVE.W	#$70,$DFF09C
	RTE

*****************************************************************************

FrameFlagCounter:
	dc.w	0


AspettaFrameFlag:
	SF	FrameFlagCounter
StoFlaNon:
	TST.B	FrameFlagCounter
	BEQ.B	StoFlaNon
	RTS

AspettVBL:
	cmp.b	#$40,$dff006
	bne.s	AspettVBL
AspettVBL2:
	cmp.b	#$40,$dff006
	beq.s	AspettVBL2
	rts

*******************************************************************************


VBcounter:
	dc.l	0

CACCA:
	dc.l	0

CAZZONE:
	dc.l	0
*******************************************************************************
;			ROUTINE DI FADE AGA
*******************************************************************************

MAINFADEINOUT:
	bsr.w	CALCOLAMETTICOL

	btst.b	#1,FLAGFADEINOUT
	bne.s	FADEOUT

FADEIN:
	addq.w	#1,MULTIPLIER
	cmp.w	#255,MULTIPLIER
	bne.s	NONFINITO
	bchg.b	#1,FLAGFADEINOUT

FADEOUT:
	subq.w	#1,MULTIPLIER
	bne.w	NONFINITO
	bchg.b	#1,FLAGFADEINOUT

NONFINITO:
	rts

FLAGFADEINOUT:
	dc.w	0

MULTIPLIER:
	dc.w	0

TEMPORANEO:
	dc.l	0

CALCOLAMETTICOL:
	lea	TEMPORANEO(pc),a0
	lea	LOGOCOLP0+2,a1
	lea	LOGOCOLP0B+2,a2
	lea	PALETTEPIC(pc),a3
	moveq	#8-1,d7

CONVERTIPALETTEBANK:
	moveq	#0,d0
	moveq	#0,d2
	moveq	#0,d3
	moveq	#32-1,d6

DALONGAREGISTRI:
	;rosso	

	move.l	(a3),d4
	andi.l	#%000011111111,d4
	mulu.w	MULTIPLIER(pc),d4
	asr.w	#8,d4
	andi.l	#%000011111111,d4
	move.l	d4,d5

	;verde

	move.l	(a3),d4
	andi.l	#%1111111100000000,d4
	lsr.l	#8,d4
	mulu.w	MULTIPLIER(pc),d4
	asr.w	#8,d4
	andi.l	#%0000000011111111,d4
	lsl.l	#8,d4
	or.l	d4,d5

	;blu

	move.l	(a3)+,d4
	andi.l	#%111111110000000000000000,d4
	lsr.l	#8,d4
	lsr.l	#8,d4
	mulu.w	MULTIPLIER(pc),d4
	asr.w	#8,d4
	andi.l	#%0000000011111111,d4
	lsl.l	#8,d4
	lsl.l	#8,d4
	or.l	d4,d5
	move.l	d5,(a0)

	move.b	1(a0),(a2)
	andi.b	#%00001111,(a2)
	move.b	2(a0),d2
	lsl.b	#4,d2
	move.b	3(a0),d3
	andi.b	#%00001111,d3
	or.b	d2,d3
	move.b	d3,1(a2)

	move.b	1(A0),d0
	andi.b	#%11110000,d0
	lsr.b	#4,d0
	move.b	d0,(a1)
	move.b	2(a0),d2
	andi.b	#%11110000,d2
	move.b	3(a0),d3
	andi.b	#%11110000,d3
	lsr.b	#4,d3
	ori.b	d2,d3
	move.b	d3,1(a1)
	addq.w	#4,a1
	addq.w	#4,a2
	dbra	d6,DALONGAREGISTRI

	add.w	#(128+8),a1
	add.w	#(128+8),a2

	dbra	d7,CONVERTIPALETTEBANK
	rts

PALETTEPIC:
	dc.l	$00000000,$00d6d6d6,$00202010,$00303010,$00304010,$00405020
	dc.l	$00506020,$00608020,$00709030,$0080a030,$0090b030,$00a0c030
	dc.l	$00b0d040,$00ffffff,$00909090,$00101010
	cnop	0,8

******************************************************************************
;			ROUTINE DI PRINT CARATTERE
******************************************************************************

PRINTCARATTERE:
	move.l	PuntaTESTO(PC),A0 ; Indirizzo del testo da stampare in a0
	moveq	#0,D2		; Pulisci d2
	move.b	(A0)+,D2	; Prossimo carattere in d2
	cmp.b	#$ff,d2		; Segnale di fine testo? ($FF)
	beq.s	FineTesto	; Se si, esci senza stampare

NonFineRiga:
	sub.b	#$20,D2
	mulu.w	#8,D2
	move.l	D2,A2
	add.l	#FONT,A2
	move.l	PuntaBITPLANE(PC),A3

	move.b	(A2)+,(A3)
	move.b	(A2)+,40(A3)
	move.b	(A2)+,40*2(A3)
	move.b	(A2)+,40*3(A3)
	move.b	(A2)+,40*4(A3)
	move.b	(A2)+,40*5(A3)
	move.b	(A2)+,40*6(A3)
	move.b	(A2)+,40*7(A3)

	addq.l	#1,PuntaBitplane ; avanziamo di 8 bit (PROSSIMO CARATTERE)
	addq.l	#1,PuntaTesto	; prossimo carattere da stampare

FINETESTO:
	rts

PUNTATESTO:
	dc.l	TESTO

PUNTABITPLANE:
	dc.l	MEMPIC1+(40*200)

TESTO:
	dc.b	"                PRESENTS                ",$FF
	even


*****************************************************************************
;		ROUTINE CHE SCHIACCIA LA PICTURE
*****************************************************************************

MODJMP	equ	512*2	; la velocita` aumenta con multipli di 512

SCHIACCIA:
	lea	BplxMod+6,a0
	lea	modtab(pc),a1

	move.l	offmod(pc),d0
	cmpi.l	#65536,d0	; abbiamo finito? (lunghezza tab=64k)
	blt.s	stringi
	move.l	#1,Cazzone
	rts
stringi:
	bsr.s	setmod
	addi.l	#MODJMP,offmod	; salta i moduli gia` fatti
	rts

; Input: d0=offset for modtab
;	 a0=destination cop address
;	 a1=source tab address
setmod:
	lea	(a1,d0.l),a1
	move.w	#$ff-$2c,d2
loopsetmod1:
	move.w	(a1)+,d1	; give me next tab value...
	move.w	d1,(a0)		; ...e schioffalo in cop
	addq.w	#4,a0
	move.w	d1,(a0)		; ...un'altra volta
	addq.w	#8,a0
	dbra	d2,loopsetmod1
	addq.w	#4,a0
	moveq	#$2c,d2
loopsetmod2:
	move.w	(a1)+,d1	; give me next tab value...
	move.w	d1,(a0)		; ...e schioffalo in cop
	addq.w	#4,a0
	move.w	d1,(a0)		; ...un'altra volta
	addq.w	#8,a0
	dbra	d2,loopsetmod2
	rts
	
offmod	dc.l	0

modtab	incbin	"modtab.bin"

*******************************************************************************
;			ROUTINE DI PRINTING TESTO
*******************************************************************************

PRINTATESTO:
	LEA	SCROLLTESTO(PC),A0
	LEA	VUOTO,A3
	MOVEQ	#66-1,D3
.PRINTRIGA:
	MOVEQ	#40-1,D0
.PRINTCHAR2:
	MOVEQ	#0,D2
	MOVE.B	(A0)+,D2
	SUB.B	#$20,D2
	MULU.W	#8,D2
	MOVE.L	D2,A2
	ADD.L	#FONT,A2
	MOVE.B	(A2)+,(A3)
	MOVE.B	(A2)+,40(A3)
	MOVE.B	(A2)+,40*2(A3)
	MOVE.B	(A2)+,40*3(A3)
	MOVE.B	(A2)+,40*4(A3)
	MOVE.B	(A2)+,40*5(A3)
	MOVE.B	(A2)+,40*6(A3)
	MOVE.B	(A2)+,40*7(A3)

	ADDQ.w	#1,A3
	DBRA	D0,.PRINTCHAR2
	ADD.W	#40*7,A3
	DBRA	D3,.PRINTRIGA
	RTS

SCROLLTESTO:
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                 X-ZONE                 "
	dc.b	"                                        "
	dc.b	"                PRESENTS                "
	dc.b	"                                        "
	dc.b	"          COOL A TUNE ISSUE ONE         "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"             INTRO CREDITS:             "
	dc.b	"                                        "
	dc.b	"     SIMPLE CODE..............MODEM     "
	dc.b	"     OLD GFX..................LANCH     "
	dc.b	"     FAST MUSIC...........CORROSION     "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"  X-ZONE SENDS GREETINGS TO:            "
	dc.b	"                                        "
	dc.b	" * VAJRAYANA * DEGENERATION * RAM JAM * "
	dc.b	" * CYDONIA * BALANCE * MORBID VISIONS * "
	dc.b	" * BIOSYNTHETIC DESIGN * X-ZONE FANS!!! "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "

	; pagina 2

	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	" TO CONTACT US, WRITE TO:               "
	dc.b	"                                        "
	dc.b	"            MODEM OF X-ZONE             "
	dc.b	"             PAOLO D'URSO               "
	dc.b	"     VIA CACCIATORI DELLE ALPI 45       "
	dc.b	"       06049 SPOLETO  PG  ITALY         "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	" OR SIMPLY CALL ONE OF OUR BBS:         "
	dc.b	"                                        "
	dc.b	"        PLASTIC DREAM    -WHQ-          "       
	dc.b	"            +39 41/5732014              "
	dc.b	"                                        "
	dc.b	"        ALIEN ATTACK     -IHQ-          "
	dc.b	"            +39 744/422108              "
	dc.b	"                                        "
	dc.b	"         METAL MOON      -IDS-          "
	dc.b	"            +39 11/9138501              "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "

	even

*******************************************************************************
;			ROUTINE DI FADE SEMIINCROCIATO
*******************************************************************************

DOFADE:
	cmp.w	#17,FASEDELFADE
	beq.s	FADEFINITO
	lea	COPCOLORS+2,a0
	move.w	#32,d6
	bsr.w	FADE2

FADEFINITO:
	rts

; Uses d0-d6/a0-a2

FADE2:
F2MAIN:
	addq.w	#4,a0
	addq.w	#2,a1
	addq.w	#2,a2
	move.w	(a0),d0
	move.w	(a2),d1
	cmp.w	d0,d1
	beq.w	PROSSIMOCOLORE
	move.w	FASEDELFADE(pc),d4
	clr.w	COLOREFINALE

	;blu

	move.w	(a1),d0
	move.w	(a2),d2
	and.l	#$00f,d0
	and.l	#$00f,d2
	cmp.w	d2,d0
	bhi.b	SOTTRAID2
	beq.b	SOTTRAID2
	sub.w	d0,d2
	bra.b	SOTTFATTO

SOTTRAID2:
	sub.w	d2,d0
	bra.b	SOTTFATTO2

SOTTFATTO:
	move.w	d2,d0

SOTTFATTO2:
	moveq	#16,d1
	bsr.w	dodivu
	and.w	#$00f,d1
	move.w	(a1),d0
	move.w	(a2),d2
	and.w	#$00f,d0
	and.w	#$00f,d2
	cmp.w	d0,d2
	bhi.b	SOMMAD1
	beq.b	OKBLU
	sub.w	d1,d0
	bra.b	OKBLU
	
SOMMAD1:
	add.w	d1,d0

OKBLU:
	move.w	d0,COLOREFINALE

	;verde

	move.w	(a1),d0
	move.w	(a2),d2
	and.l	#$0f0,d0
	and.l	#$0f0,d2
	cmp.w	d2,d0
	bhi.b	SOTTRAID2V
	beq.b	SOTTRAID2V
	sub.w	d0,d2
	bra.b	SOTTFATTOV

SOTTRAID2V:
	sub.w	d2,d0
	bra.b	SOTTFATTO2V

SOTTFATTOV:
	move.w	d2,d0

SOTTFATTO2V:
	moveq	#16,d1
	bsr.w	DODIVU
	and.w	#$0f0,d1
	move.w	(a1),d0
	move.w	(a2),d2
	and.w	#$0f0,d0
	and.w	#$0f0,d2
	cmp.w	d0,d2
	bhi.b	SOMMAD1V
	beq.b	OKVERDE
	sub.w	d1,d0
	bra.b	OKVERDE

SOMMAD1V:
	add.w	d1,d0

OKVERDE:
	or.w	d0,COLOREFINALE

	;rosso

	move.w	(a1),d0
	move.w	(a2),d2
	and.l	#$f00,d0
	and.l	#$f00,d2
	cmp.w	d2,d0
	bhi.b	SOTTRAID2R
	beq.b	SOTTRAID2R
	sub.w	d0,d2
	bra.b	SOTTFATTOR

SOTTRAID2R:
	sub.w	d2,d0
	bra.b	SOTTFATTO2R

SOTTFATTOR:
	move.w	d2,d0

SOTTFATTO2R:
	moveq	#16,d1
	bsr.w	DODIVU
	and.w	#$f00,d1
	move.w	(a1),d0
	move.w	(a2),d2
	and.w	#$f00,d0
	and.w	#$f00,d2
	cmp.w	d0,d2
	bhi.b	SOMMAD1R
	beq.b	OKROSSO
	sub.w	d1,d0
	bra.b	OKROSSO

SOMMAD1R:
	add.w	d1,d0

OKROSSO:
	or.w	d0,COLOREFINALE
	move.w	COLOREFINALE(pc),(a0)

PROSSIMOCOLORE:
	dbra	d6,F2MAIN
	addq.w	#1,FASEDELFADE

NOCRS:
	rts

DODIVU:
	divu.w	d1,d0
	move.l	d0,d1
	swap	d1
	move.l	#$31000,d2
	moveq	#0,d3
	move.w	d1,d3
	mulu.w	d3,d2
	move.w	d2,d1

	and.l	#$ffff,d1
	mulu.w	d4,d1
	swap	d1
	mulu.w	d4,d0
	add.w	d0,d1
	and.l	#$ffff,d1
	rts

FASEDELFADE:
	dc.w	0

COLOREFINALE:
	dc.w	0

CSTART:
	dc.w	$6ad,$237,$347
	dc.w	$650,$358,$469,$479
	dc.w	$58b,$236,$860,$a80
	dc.w	$ca0,$ec0,$fff,$225
	dc.w	$000,$6ad,$237,$347
	dc.w	$650,$358,$469,$479
	dc.w	$58b,$236,$860,$a80
	dc.w	$ca0,$ec0,$fff,$225
CEND:
	dc.w	$6ad,$237,$347
	dc.w	$650,$358,$469,$479
	dc.w	$58b,$236,$860,$a80
	dc.w	$ca0,$ec0,$fff,$225
	dc.w	$fff,$fff,$fff,$fff
	dc.w	$fff,$fff,$fff,$fff
	dc.w	$fff,$fff,$fff,$fff
	dc.w	$fff,$fff,$fff,$fff

*******************************************************************************
;			ROUTINE DI RIMBALZO TESTO
*******************************************************************************

RIMBALZO:
	lea	BPLPOINTERS3,a1
	move.w	2(a1),d0
	swap	d0
	move.w	6(a1),d0
	addq.l	#8,RIMBALZOPUNTA
	move.l	RIMBALZOPUNTA(PC),a0
	cmp.l	#FINERIMBALZO-4,a0
	bne.s	NOSTART
	move.l	#RIMBALZOTABELLA-4,RIMBALZOPUNTA

NOSTART:
	move.l	(a0),d1
	sub.l	d1,d0
	lea	BPLPOINTERS3,a1

	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	rts

RIMBALZOPUNTA:
	dc.l	RIMBALZOTABELLA-4

RIMBALZOTABELLA:
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0

	dc.l	-40,-40,-40,-40,-40,-40,-40,-40,-40
	dc.l	-40,-40,-2*40,-2*40
	dc.l	-2*40,-2*40,-2*40,-2*40,-2*40
	dc.l	-3*40,-3*40,-3*40,-3*40,-3*40			; acceleriamo
	dc.l	-3*40,-3*40,-3*40,-3*40,-3*40
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40

	dc.l	-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40

	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40
	dc.l	-3*40,-3*40,-3*40,-3*40,-3*40
	dc.l	-3*40,-3*40,-3*40,-3*40,-3*40
	dc.l	-2*40,-2*40,-2*40,-2*40,-2*40			; deceleriamo
	dc.l	-2*40,-2*40,-40,-40
	dc.l	-40,-40,-40,-40,-40,-40,-40,-40,-40,0,0,0,0,0	; in cima

	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0

	dc.l	0,0,40,40,40,40,40,40,40,40,40 			; in cima
	dc.l	40,40,2*40,2*40
	dc.l	2*40,2*40,2*40,2*40,2*40			; acceleriamo
	dc.l	3*40,3*40,3*40,3*40,3*40
	dc.l	3*40,3*40,3*40,3*40,3*40
	dc.l	4*40,4*40,4*40,4*40,4*40
	dc.l	4*40,4*40,4*40,4*40,4*40
	dc.l	4*40,4*40,4*40,4*40,4*40

	dc.l	5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40

	dc.l	4*40,4*40,4*40,4*40,4*40
	dc.l	4*40,4*40,4*40,4*40,4*40
	dc.l	4*40,4*40,4*40,4*40,4*40
	dc.l	3*40,3*40,3*40,3*40,3*40
	dc.l	3*40,3*40,3*40,3*40,3*40
	dc.l	2*40,2*40,2*40,2*40,2*40			; deceleriamo
	dc.l	2*40,2*40,40,40
	dc.l	40,40,40,40,40,40,40,40,40,0,0,0,0,0,0,0	; in fondo

FINERIMBALZO:
	dc.l	0

*******************************************************************************
;				ROUTINE MUSICALE
*******************************************************************************

fade  = 0
jump = 0
system = 1
CIA = 1
exec = 1
opt020 = 1
use = $940C

	include	"play.s"

	Section	modulozzo,DATA_C

P61_DATA:
	incbin	"P61.corrosion"

;=============================================================================

	SECTION	grafica,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81
	dc.w	$90,$2cc1
	dc.w	$92,$38
	dc.w	$94,$d0
	dc.w	$102,0
	dc.w	$104,0
	dc.w	$1fc,0

	dc.w	$100,%0100001000000000
	
BPLPOINTERS:
	dc.w $e0,0,$e2,0
	dc.w $e4,0,$e6,0
	dc.w $e8,0,$ea,0
	dc.w $ec,0,$ee,0

COLORCOP:
	dc.w $0180,$0,$0182,$0,$0184,$0,$0186,$0
	dc.w $0188,$0,$018a,$0,$018c,$0,$018e,$0
	dc.w $0190,$0,$0192,$0,$0194,$0,$0196,$0
	dc.w $0198,$0,$019a,$0,$019c,$0,$019e,$0

	DC.W	$106,$c00	; SELEZIONA PALETTE 0 (0-31), NIBBLE ALTI
LOGOCOLP0:
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$e00	; SELEZIONA PALETTE 0 (0-31), NIBBLE BASSI
LOGOCOLP0B:
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

BplxMod:
A set $2c07
	REPT	$ff-$2c+1
	dc.w	A,$fffe
A set A+$0100
	dc.w	$108,0		; Bpl1Mod - modulo pl. dispari
	dc.w	$10a,0		; Bpl2Mod - modulo pl. pari
	ENDR
	dc.w	$ffdf,$fffe
A set $0007
	REPT	$2c+1
	dc.w	A,$fffe
A set A+$0100
	dc.w	$108,0		; Bpl1Mod - modulo pl. dispari
	dc.w	$10a,0		; Bpl2Mod - modulo pl. pari
	ENDR

	dc.w	$ffff,$fffe

COPVUOTO:

BPLVUOTO:
	dc.w $e0,$0,$e2,$0

	dc.w	$100,%0001001000000000
	dc.w	$8e,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$102,0
	dc.w	$104,0
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

	DC.W	$106,$c00
	dc.w	$180,$fff,$182,$fff
	DC.W	$106,$e00
	dc.w	$180,$fff,$182,$fff

	dc.w	$ffff,$fffe

COPPERLIST2:
	dc.w	$8E,$2c81
	dc.w	$90,$2cc1
	dc.w	$92,$38
	dc.w	$94,$d0
	dc.w	$102,0
	dc.w	$104,0
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

	dc.w	$100,%0101001000000000
	
BPLPOINTERS2:
	dc.w $e0,0,$e2,0
	dc.w $e4,0,$e6,0
	dc.w $e8,0,$ea,0
	dc.w $ec,0,$ee,0
BPLPOINTERS3:
	dc.w $f0,0,$f2,0

COPCOLORS:
	dc.w	$180,$000,$182,$6ad,$184,$237,$186,$347
	dc.w	$188,$650,$18a,$358,$18c,$469,$18e,$479
	dc.w	$190,$58b,$192,$236,$194,$860,$196,$a80
	dc.w	$198,$ca0,$19a,$ec0,$19c,$fff,$19e,$225
	dc.w	$1a0,$000,$1a2,$6ad,$1a4,$237,$1a6,$347
	dc.w	$1a8,$650,$1aa,$358,$1ac,$469,$1ae,$479
	dc.w	$1b0,$58b,$1b2,$236,$1b4,$860,$1b6,$a80
	dc.w	$1b8,$ca0,$1ba,$ec0,$1bc,$fff,$1be,$225

	dc.w	$ffff,$fffe

	SECTION	pics,DATA_C
MEMPIC1:
	incbin	"logo.raw"
MEMPIC2:
	incbin	"back.raw"


	Section	FontiDelClitunno,DATA
FONT:
; ' '
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; '!'
	dc.b	%00011000
	dc.b	%00111100
	dc.b	%00111100
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00000000
; '"'
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; '#'
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; '$'
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; '%'
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; '&'
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; "'"
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00011100
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; "("
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; ")"
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; "*"
	dc.b	%01100011
	dc.b	%00111110
	dc.b	%00110110
	dc.b	%01100011
	dc.b	%00110110
	dc.b	%00111110
	dc.b	%01100011
	dc.b	%00000000
; '+'
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%01111110
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00000000
	dc.b	%00000000
; ","
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%01110000
	dc.b	%00000000
; "-"
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00111110
	dc.b	%00111110
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; "."
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00111000
	dc.b	%00000000
; "/"
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000110
	dc.b	%00001100
	dc.b	%00011000
	dc.b	%00110000
	dc.b	%11100000
	dc.b	%00000000
; '0'
	dc.b	%00111110
	dc.b	%01100111
	dc.b	%01101011
	dc.b	%01101011
	dc.b	%01110011
	dc.b	%01100011
	dc.b	%00111110
	dc.b	%00000000
; '1'
	dc.b	%00011000
	dc.b	%01111000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00000000
; '2'
	dc.b	%00111110
	dc.b	%01000110
	dc.b	%00011100
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100010
	dc.b	%01111110
	dc.b	%00000000
; '3'
	dc.b	%01111100
	dc.b	%01000110
	dc.b	%00000011
	dc.b	%00001110
	dc.b	%00000011
	dc.b	%01000110
	dc.b	%01111100
	dc.b	%00000000
; '4'
	dc.b	%00000011
	dc.b	%00000111
	dc.b	%00001101
	dc.b	%00011001
	dc.b	%00110001
	dc.b	%01111111
	dc.b	%00000011
	dc.b	%00000000
; '5'
	dc.b	%01111111
	dc.b	%01000000
	dc.b	%01011110
	dc.b	%01100011
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%01111110
	dc.b	%00000000
; '6'
	dc.b	%00111110
	dc.b	%01110000
	dc.b	%01100000
	dc.b	%01101110
	dc.b	%01110011
	dc.b	%01100011
	dc.b	%00111110
	dc.b	%00000000
; '7'
	dc.b	%01111111
	dc.b	%01000011
	dc.b	%00000110
	dc.b	%00111111
	dc.b	%00011000
	dc.b	%00110000
	dc.b	%01111000
	dc.b	%00000000
; '8'
	dc.b	%00111110
	dc.b	%01100011
	dc.b	%01000001
	dc.b	%00111110
	dc.b	%01000001
	dc.b	%01100011
	dc.b	%00111110
	dc.b	%00000000
; '9'
	dc.b	%00111110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00111101
	dc.b	%00000001
	dc.b	%01000111
	dc.b	%01111110
	dc.b	%00000000
; ':'
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00010000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00010000
	dc.b	%00000000
; ';'
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; "<"
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; "="
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; ">"
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; '?'
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; "@"
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; "A"
	dc.b	%00111110
	dc.b	%01000001
	dc.b	%01111111
	dc.b	%01100011
	dc.b	%01000001
	dc.b	%01000001
	dc.b	%01100011
	dc.b	%00000000
; "B"
	dc.b	%01111100
	dc.b	%01100110
	dc.b	%01100010
	dc.b	%01111100
	dc.b	%01100011
	dc.b	%01100111
	dc.b	%01111110
	dc.b	%00000000
; 'C'
	dc.b	%00111110
	dc.b	%01110001
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01110001
	dc.b	%00111110
	dc.b	%00000000
; 'D'
	dc.b	%01111000
	dc.b	%01100100
	dc.b	%01100010
	dc.b	%01100010
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111110
	dc.b	%00000000
; 'E'
	dc.b	%00111110
	dc.b	%01100001
	dc.b	%01111110
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100001
	dc.b	%00111111
	dc.b	%00000000
; 'F'
	dc.b	%00111111
	dc.b	%01100000
	dc.b	%01111000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01110000
	dc.b	%00000000
; 'G'
	dc.b	%00011111
	dc.b	%01110000
	dc.b	%01100000
	dc.b	%01100110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00111110
	dc.b	%00000000
; 'H'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100111
	dc.b	%01111111
	dc.b	%01110011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00000000
; 'I'
	dc.b	%00011100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001110
	dc.b	%00000000
; 'J'
	dc.b	%00000111
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%01110011
	dc.b	%01110011
	dc.b	%00111110
	dc.b	%00000000
; 'K'
	dc.b	%01110011
	dc.b	%01100110
	dc.b	%01101100
	dc.b	%01111000
	dc.b	%01101100
	dc.b	%01100110
	dc.b	%01110011
	dc.b	%00000000
; 'L'
	dc.b	%01110000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01110001
	dc.b	%00111111
	dc.b	%00000000
; 'M'
	dc.b	%00100010
	dc.b	%01110111
	dc.b	%01101011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00000000
; 'N'
	dc.b	%01100111
	dc.b	%01110011
	dc.b	%01111111
	dc.b	%01100111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01110011
	dc.b	%00000000
; 'O'
	dc.b	%00111110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%00111110
	dc.b	%00000000
; 'P'
	dc.b	%01111110
	dc.b	%01100011
	dc.b	%01111110
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01110000
	dc.b	%00000000
; 'Q'
	dc.b	%00111110
	dc.b	%01110011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01101110
	dc.b	%00111011
	dc.b	%00000000
; 'R'
	dc.b	%01111110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111110
	dc.b	%01110000
	dc.b	%01101100
	dc.b	%01100111
	dc.b	%00000000
; 'S'
	dc.b	%00111111
	dc.b	%01100000
	dc.b	%01111110
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%01000011
	dc.b	%01111110
	dc.b	%00000000
; 'T'
	dc.b	%01111110
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00111000
	dc.b	%00000000
; 'U'
	dc.b	%01110011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01110111
	dc.b	%00111110
	dc.b	%00000000
; 'V'
	dc.b	%01110011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00110110
	dc.b	%00011100
	dc.b	%00000000
; 'W'
	dc.b	%01110011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01101011
	dc.b	%01110111
	dc.b	%00100010
	dc.b	%00000000
; 'X'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00111110
	dc.b	%00001000
	dc.b	%00111110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00000000
; 'Y'
	dc.b	%01110011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00111111
	dc.b	%00000011
	dc.b	%01000110
	dc.b	%01111100
	dc.b	%00000000
; 'Z'
	dc.b	%01111111
	dc.b	%01000011
	dc.b	%00000110
	dc.b	%00111000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01111111
	dc.b	%00000000

	Section	AreaVuota,BSS_C
VUOTO:
	ds.b	40*512
	ds.b	1000

	END
