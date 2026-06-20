
	Section	codice,CODE

	incdir	"dh1:programs/asmone/modem/over/"

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
	lea	samples,a2	; modulo compattato! Buffer destinazione per
				; i samples (in chip ram) da indicare!
	bsr.w	P61_Init
	movem.l	(SP)+,d0-d7/a0-a6

	move.l	BaseVbr(PC),A1
	move.l	#MyInt6c,$6C(A1)
	move.w	#DMASET,$96(a5)		; DMACON - abilita bitplane e copper
	move.w	#$e020,$9a(a5)		; INTENA - Abilito Master and lev6

	move.l	#FONDINO,d0
	lea	BPLPOINTERS,A1	

	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0

	move.l	#VUOTO,d0
	lea	BPLPOINTERS2,A1	
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0

	move.l	#COPPERLIST,$dff080
	move.w	d0,$dff088

	move.w	#$c00,$dff106
	move.w	#$11,$dff10c

	clr.l	VBcounter

	lea	TESTO1(PC),a0
	bsr.w	PRINTATESTO

LOGO1a:
	bsr.w	WBLAN

	lea	PALETTE1(pc),a3
	bsr.w	FADEAGA

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#64,VBcounter
	blo.s	LOGO1a

	clr.l	VBcounter

LOGO2a:
	bsr.w	WBLAN

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#200,VBcounter
	blo.s	LOGO2a

	clr.l	VBcounter

LOGO3a:
	bsr.w	WBLAN

	lea	PALETTE1(pc),a3
	bsr.w	FADEAGA

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#64,VBcounter
	blo.s	LOGO3a

	clr.l	VBcounter

	; 2a PARTE

	clr.w	FLAGFADEINOUT
	clr.w	MULTIPLIER
	clr.l	TEMPORANEO

	lea	TESTO2(PC),a0
	bsr.w	PRINTATESTO

LOGO1b:
	bsr.w	WBLAN

	lea	PALETTE2(pc),a3
	bsr.w	FADEAGA

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#64,VBcounter
	blo.s	LOGO1b

	clr.l	VBcounter

LOGO2b:
	bsr.w	WBLAN

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#200,VBcounter
	blo.s	LOGO2b

	clr.l	VBcounter

LOGO3b:
	bsr.w	WBLAN

	lea	PALETTE2(pc),a3
	bsr.w	FADEAGA

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#64,VBcounter
	blo.s	LOGO3b

	clr.l	VBcounter

	; 3a PARTE

	clr.w	FLAGFADEINOUT
	clr.w	MULTIPLIER
	clr.l	TEMPORANEO

	lea	TESTO3(PC),a0
	bsr.w	PRINTATESTO

LOGO1c:
	bsr.w	WBLAN

	lea	PALETTE3(pc),a3
	bsr.w	FADEAGA

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#64,VBcounter
	blo.s	LOGO1c

	clr.l	VBcounter

LOGO2c:
	bsr.w	WBLAN

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#200,VBcounter
	blo.s	LOGO2c

	clr.l	VBcounter

LOGO3c:
	bsr.w	WBLAN

	lea	PALETTE3(pc),a3
	bsr.w	FADEAGA

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#64,VBcounter
	blo.s	LOGO3c

	clr.l	VBcounter

	; 4a PARTE

	clr.w	FLAGFADEINOUT
	clr.w	MULTIPLIER
	clr.l	TEMPORANEO

	lea	TESTO4(PC),a0
	bsr.w	PRINTATESTO

LOGO1d:
	bsr.w	WBLAN

	lea	PALETTE4(pc),a3
	bsr.w	FADEAGA

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#64,VBcounter
	blo.s	LOGO1d

	clr.l	VBcounter

LOGO2d:
	bsr.w	WBLAN

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#200,VBcounter
	blo.s	LOGO2d

	clr.l	VBcounter

LOGO3d:
	bsr.w	WBLAN

	lea	PALETTE4(pc),a3
	bsr.w	FADEAGA

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#64,VBcounter
	blo.s	LOGO3d

	clr.l	VBcounter

ESCI:
	lea	$dff000,a6	; stoppo la musica
	bsr.w	P61_End
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
	beq.w	NoIntCoper
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

*******************************************************************************
;			ROUTINE DI PRINTING TESTO
*******************************************************************************

PRINTATESTO:
;	LEA	TESTO(PC),A0	; lo metto nel maincode
	LEA	VUOTO,A3
	MOVEQ	#15-1,D3	; numero righe
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

TESTO1:
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"     WELCOME TO                         "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                ANOTHER                 "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                       FAAAST INTRO     "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"       FROM                             "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"               X-ZONE                   "
	dc.b	"                                        "
	even

TESTO2:
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"    CREDITS (?):                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"    C O D E         WASHBURN            "
	dc.b	"                                 AND    "
	dc.b	"                     MODEM              "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"    G F X            LANCH              "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"    M U S I C      CORROSION            "
	dc.b	"                                        "
	dc.b	"                                        "
	even

TESTO3:
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"   WE WANT TO SAY 'YUHUUU!'             "
	dc.b	"                                        "
	dc.b	"                TO A LOT OF FRIENDS:    "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"ABYSS - AGRESSIONE - ALONE - AMIGACIRCLE"
	dc.b	"BALANCE - CAPSULE - CHAOS AGE - CYDONIA "
	dc.b	"DTC - ELVEN - ESSENCE - ETERNALLY - KNB "
	dc.b	"FENIXCORPORATION - GODS - HAUJOBB - LLFB"
	dc.b	"METRO - MORBID VISION - NETWORK - NIVEL7"
	dc.b	"ODRUSBA - QKP - RAM JAM - SOFT ONE - TL3"
	dc.b	"                                        "
	dc.b	"            AND THE OTHERS???           "
	dc.b	"                                        "
	even

TESTO4:
	dc.b	"                                        "
	dc.b	" THIS BUNCH OF BYTES                    "
	dc.b	"                                        "
	dc.b	"       WAS PUT TOGHETHER                "
	dc.b	"                                        "
	dc.b	"                ONLY FOR FUN,           "
	dc.b	"                                        "
	dc.b	"                   FOR FRIENDSHIP       "
	dc.b	"                                        "
	dc.b	"                   AND FOR MY MOTHER    "
	dc.b	"                                        "
	dc.b	"  ...IN ONLY 6 HOURS!!!                 "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	" THAT'S ALL FOR NOW... TIME IS  O-V-E-R "
	dc.b	"                                        "
	even

*******************************************************************************
;			ROUTINE DI FADE AGA
*******************************************************************************

FADEAGA:
	bsr.w	CALCOLAMETTICOL

	btst.b	#1,FLAGFADEINOUT
	bne.s	FADEOUT

FADEIN:
	addq.w	#4,MULTIPLIER
	cmp.w	#256,MULTIPLIER
	bne.s	NONFINITO
	bchg.b	#1,FLAGFADEINOUT

FADEOUT:
	subq.w	#4,MULTIPLIER
	bne.w	NONFINITO

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
	lea	COL0+2,a1
	lea	COL0B+2,a2
;	lea	PALETTE1(pc),a3		; lo metto nel maincode
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

PALETTE1:
	dc.l	$131131,$462462,$ffffff,$ffffff
	cnop	0,8

PALETTE2:
	dc.l	$131000,$462000,$ffffff,$ffffff
	cnop	0,8

PALETTE3:
	dc.l	$030131,$060462,$ffffff,$ffffff
	cnop	0,8

PALETTE4:
	dc.l	$0e3222,$335033,$ffffff,$ffffff
	cnop	0,8

*******************************************************************************
;				ROUTINE MUSICALE
*******************************************************************************

fade  = 0
jump = 0
system = 1
CIA = 1
exec = 1
opt020 = 1
use = $409504

	include	"play.s"

	Section	modulozzo,DATA
P61_DATA:
	incbin	"P61.over-theme"	; Compresso

	Section	smp,BSS_C
SAMPLES:
	ds.b	3398

;=============================================================================

	SECTION	grafica,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81
	dc.w	$90,$2cc1
	dc.w	$92,$38
	dc.w	$94,$d0
	dc.w	$102,0
	dc.w	$104,0
	dc.w	$108,-8
	dc.w	$1fc,3

	dc.w	$100,%0010001000000000
	
BPLPOINTERS:
	dc.w $e0,0,$e2,0
BPLPOINTERS2:
	dc.w $e4,0,$e6,0

	DC.W	$106,$c00	; SELEZIONA PALETTE 0 (0-31), NIBBLE ALTI
COL0:
	DC.W	$180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
	DC.W	$190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
	DC.W	$1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
	DC.W	$1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

	DC.W	$106,$e00	; SELEZIONA PALETTE 0 (0-31), NIBBLE BASSI
COL0B:
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

A set $2c+1
	REPT	($ff-$2c)/2
	dc.b	A,$01,$ff,$fe
	dc.w	$10a,-8-40
A set A+1
	dc.b	A,$01,$ff,$fe
	dc.w	$10a,-8
A set A+1
	ENDR
	dc.w	$ffdf,$fffe
A set 0
	REPT	$2c/2+1
	dc.b	A,$01,$ff,$fe
	dc.w	$10a,-8-40
A set A+1
	dc.b	A,$01,$ff,$fe
	dc.w	$10a,-8
A set A+1
	ENDR

	dc.w	$ffff,$fffe

	SECTION	pics,DATA_C
FONDINO:incbin	"fondino.raw"

	SECTION	picsvuote,BSS_C
VUOTO:	ds.b	40*256

	SECTION	fontidelclitunno,DATA
FONT:	incbin	"nice.fnt"
	END
