;************************************************
;*                STARTUP-CODE                  *
;*						*
;*  Coder: EXECUTOR                             *
;*  Date:  xx/09/1991                           *
;************************************************


;*****************
;*   Constants   *
;*****************

OldOpenLibrary	= -408
CloseLibrary	= -414
LoadView	= -222
WaitTOF		= -270
Forbid		= -132
Permit		= -138
DMASET=	%1000010111000000
;	 -----a-bcdefghij

;	a: Blitter Nasty
;	b: Bitplane DMA (if this isn't set, sprites disappear!)
;	c: Copper DMA
;	d: Blitter DMA
;	e: Sprite DMA
;	f: Disk DMA
;	g-j: Audio 3-0 DMA

	section	pippo,code_p

TRAP:
	MOVEM.L	D0-D7/A0-A6,-(A7)	; Put registers on stack
	MOVE.L	A7,OLDSSSTACK
	LEA	SSSTACK,A7
	BSR.B	DEMOIRQ			; demo irq
	BSR.W	SETSCREEN	
	bsr.w	clearscreen68000
	bsr.w	COPYSCREENS
	bsr.w	objadd
	bsr.w	doubleset	
	bsr.w	movement		; to load right values in regs....
	bsr.w	conversion
	bsr.w	MAXCOORDS
		
*******Here There is your code*********

LAAP:
	BSR.W	WaitVB			; Wait start of VBlank
	
	bsr.w DELETESCREEN
	bsr.w MAXCOORDS
	bsr.w movement
	bsr.w conversion
	bsr.w HIDDEN
	bsr.w drawlines

	bsr.w	doubleset2
 	bsr.w	doubleset

;	move.w #$0fff,$dff180

	BTST	#6,$BFE001		; Test left mouse button
	BNE.S	LAAP

***************************************

END:	BSR.W	SYSTEMIRQ		; system irq
;	bsr	pr_end
	MOVE.L	OLDSSSTACK,A7
	MOVEM.L	(A7)+,D0-D7/A0-A6	; Get registers from stack
	MOVEQ.L	#$00,D0			; OK..........
	RTS


;***********************************
;*   CLOSE ALL SYSTEM INTERRUPTS   *
;*                                 *
;*      START DEMO INTERRUPTS      *
;***********************************
DEMOIRQ:
	bsr.w	TEST_PROCESSOR
	bsr.w	TAKE_VBR
	MOVE.L	$4.W,A6			; Exec pointer to A6
	LEA.L	GfxName(PC),A1		; Set library pointer
	MOVEQ	#0,D0
	JSR	OldOpenLibrary(A6)	; Open graphics.library
	MOVE.L	D0,GFXBASE
	MOVE.L	D0,A6			; Use Base-pointer
	MOVE.L	34(a6),WBVIEW
	MOVE.L	38(a6),WBCOP1
	MOVE.L	50(a6),WBCOP2
	MOVE.W	#0,A1
	jsr	LoadView(a6)

	jsr	WaitTOF(a6)
	jsr	WaitTOF(a6)

	move.l	$4.w,a6
	jsr	Forbid(a6)
		
	move.l	#COPLIST,$dff080

	MOVE.W	$DFF01C,INTENA		; Store old INTENA
	MOVE.W	$DFF002,DMACON		; Store old DMACON
	MOVE.W	$DFF010,ADKCON		; Store old ADKCON

	MOVE.W	#$7FFF,$DFF09A		; Clear interrupt enable
	MOVE.W	#$7FFF,$DFF096		; Clear DMA channels
;	bsr	pr_init
	MOVE.W	#DMASET!$8200,$DFF096	; DMA kontrol data
	MOVE.L	VectorBASE(pc),a1
	MOVE.L	$6C(a1),OldIrq3		; Store old inter pointer
	MOVE.L	#IRQ3,$6C(a1)		; Set interrupt pointer
	MOVE.W	#$7FFF,$DFF09C		; Clear request
	MOVE.W	#$e020,$DFF09A		; Interrupt enable
	RTS
	

TEST_PROCESSOR:
	MOVE.L	$0004.W,A0
	MOVE.B	$0129(A0),D0
	MOVEQ	#$04,D1		;68040...
	BTST	#$03,D0
	BNE.B	PROCESSOR_OK
	MOVEQ	#$03,D1		;68030...
	BTST	#$02,D0
	BNE.B	PROCESSOR_OK
	MOVEQ	#$02,D1		;68020...
	BTST	#$01,D0
	BNE.B	PROCESSOR_OK
	MOVEQ	#$01,D1		;68010...
	BTST	#$00,D0
	BNE.B	PROCESSOR_OK
	MOVEQ	#$00,D1		;68000...
PROCESSOR_OK:
	MOVE.L	D1,PROCESSOR
	RTS	

TAKE_VBR:
	LEA	$0.w,A1
	CMPI.B	#$01,PROCESSOR
	BLT.B	NO_VBR
	LEA	LDA_VBR,A5
	MOVE.L	$4.W,A6
	JSR	-$001E(A6)
NO_VBR:	MOVE.L	A1,VectorBASE
	RTS	
LDA_VBR:
	MOVEC	VBR,A1
	RTE	



;*****************************************
;*					 *
;*   RESTORE SYSTEM INTERRUPTS ECT ECT   *
;*					 *
;*****************************************
SYSTEMIRQ:
	MOVE.W	#$7FFF,$DFF09A		; Disable interrupts
	MOVE.W	#$7FFF,$DFF096
	MOVE.L	VectorBASE(pc),a1
	MOVE.L	OldIrq3(PC),$6C(a1)	; Restore inter pointer
	MOVE.W	DMACON,D0		; Restore old DMACON
	OR.W	#$8000,D0
	MOVE.W	D0,$DFF096		
	MOVE.W	ADKCON,D0		; Restore old ADKCON
	OR.W	#$8000,D0
	MOVE.W	D0,$DFF09E
	MOVE.W	INTENA,D0		; Restore inter data
	OR.W	#$C000,D0
	MOVE.W	#$7FFF,$DFF09C
	MOVE.W	D0,$DFF09A

	move.l	$4.w,a6
	jsr	Permit(a6)
	
	move.l	wbview,a1
	move.l	gfxbase,a6
	jsr	LoadView(a6)

	move.l	wbcop1,$dff080
	move.l	wbcop2,$dff084

	move.l	a6,a1
	move.l	$4.w,a6
	jsr	CloseLibrary(a6)
	rts
	
	
;*** DATA AREA ***

GfxName:	DC.B	'graphics.library',0
		even
OldIrq3:	DC.L	0
OldCop1:	DC.L	0
OldCop2:	DC.L	0
TRP0:		DC.L	0
INTENA:		DC.W	0
DMACON:		DC.W	0
ADKCON:		DC.W	0
WBVIEW:		DC.L	0
WBCOP1:		DC.L	0
WBCOP2:		DC.L	0
GFXBASE:	DC.L	0
VectorBASE:	DC.L	0
PROCESSOR:	dc.l	0	;0 = 68000
				;1 = 68010
				;2 = 68020
				;3 = 68030
				;4 = 68040


;**********************************
;*				  *
;*       SET USER'S SCREEN        *
;*	     & SPRITES		  *
;**********************************

SETSCREEN:
	
	move.l	#IM1,d0		; insert screen1 in copperlist
	lea	BPL5,a0
	move.w	d0,6(a0)
	swap.w	d0
	move.w	d0,2(a0)

	move.l	#IM2+2,d0		; insert screen1 in copperlist
	lea	BPL6,a0
	move.w	d0,6(a0)
	swap.w	d0
	move.w	d0,2(a0)
	
	rts
	

;**********************************
;*				  *
;*    INTERRUPT ROUTINE. LEVEL 3  *
;*				  *
;**********************************

IRQ3:
	MOVEM.L	D0-D7/A0-A6,-(A7)	; Put registers on stack

;	bsr	pr_music
	ADD.B	#1,VBLANK

	MOVE.W	#$4020,$DFF09C		; Clear interrupt request
	MOVEM.L	(A7)+,D0-D7/A0-A6	; Get registers from stack
	RTE

VBLANK:	DC.W	0

;**********************************
;WaitVB:	SF	VBLANK
;WaitVZ:	TST.B	VBLANK
;	BEQ.S	WaitVZ
;	rts
;**********************************
WaitVB:	move.b	VBLANK,d0
WaitVZ:	cmp.b	VBLANK,d0
	beq	WaitVZ
	cmp.b	#2,VBLANK
	blt	WaitVB
	move.b	#0,VBLANK
	rts
		

*********************************************
;           3D  ROUTINES
*********************************************


WAITBLIT:
	move.w	#$8400,$dff096
WAITBLIT2:
	btst #$0e,$dff002
	bne.s WAITBLIT2
	move.w	#$0400,$dff096
	rts

clearscreen68000:
	lea FACESCREEN,a1
	move.w #$59ff,d0
clearloop:
	clr.l (a1)+
	dbf d0,clearloop
	rts
	
**********************************

scriptefx:
	dc.l startcoords,modify,defineobj,fadepalette,0,copyscreen
	
movement:
	tst.w	efxcounter
	bne.s	movement2
	bra.W	scriptreader
movement2:
	subq.w	#1,efxcounter
	lea	OBJPOS(pc),a0

	lea	xadd(pc),a1
	move.w	(a1),d0
	move.w	2(a1),d1
	move.w	4(a1),d2
	move.w	6(a1),d3
	move.w	8(a1),d4
	move.w	10(a1),d5

	add.w	d0,6(a0)
	add.w	d1,8(a0)
	add.w	d2,10(a0)

	add.w	d3,(a0)
	cmp.w	#360,(a0)
	blt.s	rot1
	sub.w	#360,(a0)
rot1:   tst.w	(a0)
	bpl.s	rot12
	add.w	#360,(a0)

rot12:  add.w	d4,2(a0)
	cmp.w	#360,2(a0)
	blt.s	rot2
	sub.w	#360,2(a0)
rot2:   tst.w	2(a0)
	bpl.s	rot22
	add.w	#360,2(a0)

rot22:  add.w	d5,4(a0)
	cmp.w	#360,4(a0)
	blt.s	rot3
	sub.w	#360,4(a0)
rot3:   tst.w	4(a0)
	bpl.s	rot33
	add.w	#360,4(a0)

rot33:
	rts

scriptreader:
	move.l	scriptloc,a0
	cmp.w	#'Z',(a0)
	beq.B	scriptgoto
	lea	scriptefx(pc),a1
	move.w	(a0),d0
	sub.w	#65,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a1
	move.l	(a1),a3
	jmp	(a3)
	bra.w	movement
	rts

scriptgoto:
;	MOVE.W	#$ffff,ENDC
	move.l	2(a0),scriptloc
	bra.b	scriptreader
	rts     

ENDC:	dc.w	$0000

startcoords:
	addq.l	#2,a0
	lea	OBJPOS(pc),a2
	move.w	6(a0),(a2)
	move.w	8(a0),2(a2)
	move.w	10(a0),4(a2)
	move.w	(a0),6(a2)
	move.w	2(a0),8(a2)
	move.w	4(a0),10(a2)
sc3:    add.l	#12,a0 
	move.l	a0,scriptloc
	bra.b	scriptreader
	rts
modify:
	addq.l	#2,a0
	lea	xadd(pc),a2
	move.w	(a0),(a2)
	move.w	2(a0),2(a2)
	move.w	4(a0),4(a2)
	move.w	6(a0),6(a2)
	move.w	8(a0),8(a2)
	move.w	10(a0),10(a2)
	move.w	12(a0),efxcounter
	add.l	#14,a0    
	move.l	a0,scriptloc
	bra.w	movement
	rts

defineobj:
	move.l	2(a0),d0
	addq.l	#4,d0
	move.l	d0,OBJCOORDS
	move.l	2(a0),a1
	move.l	(a1),OBJCOORDS+4
	move.l	6(a0),objcolor
	add.l	#10,a0
	move.l	a0,scriptloc
	bra.w	scriptreader
	rts

fadepalette:
	move.l	2(a0),frompalette
	move.l	6(a0),topalette
	move.w	#16*4,FADETIME
	move.w	#03,FADETIME2
	add.l	#10,a0
	move.l	a0,scriptloc
	bra.w	scriptreader
	
FADE:
	tst.w	FADETIME
	beq.b	FADEXIT
	sub.w	#01,FADETIME
	tst.w	FADETIME2
	bne.b	FADEXIT2
	move.w	#03,FADETIME2
	move.l	frompalette,a0
	move.l	topalette,a1
	move.w 	#8-1,d7
	bsr.b 	XSFUMA
	bra.b	FADEXIT
FADEXIT2:
	sub.w	#01,FADETIME2
FADEXIT:
	rts

XSFUMA:
	move.w 	(a0),d0
	move.w 	(a0),d1
	move.w 	(a0),d2
	move.w 	(a1),d3
	move.w 	(a1),d4
	move.w 	(a1),d5
	andi.w 	#$0f00,d0
	lsr.w 	#$08,d0
	andi.w 	#$00f0,d1
	lsr.w 	#$04,d1
	andi.w 	#$000f,d2
	andi.w 	#$0f00,d3
	lsr.w 	#$08,d3
	andi.w 	#$00f0,d4
	lsr.w 	#$04,d4
	andi.w 	#$000f,d5
	cmp.w 	d0,d3
	beq.b 	XCONT1
	blt.b 	XCONT2
	subi.w 	#$0001,d3
	bra.b 	XCONT1

XCONT2:
	addi.w 	#$0001,d3

XCONT1:
	cmp.w 	d1,d4
	beq.b 	XCONT3
	blt.b 	XCONT4
	subi.w 	#$0001,d4
	bra.b 	XCONT3

XCONT4:
	addi.w 	#$0001,d4

XCONT3:
	cmp.w 	d2,d5
	beq.b 	XCONT5
	blt.b 	XCONT6
	subi.w 	#$0001,d5
	bra.b 	XCONT5

XCONT6:
	addi.w 	#$0001,d5

XCONT5:
	lsl.w 	#$08,d3
	lsl.w 	#$04,d4
	add.w 	d3,d5
	add.w 	d4,d5
	move.w 	d5,(a1)
	addq.l 	#02,a0
	addq.l 	#02,a1
	dbf 	d7,XSFUMA
	rts

COPYSCREEN:
	add.l	#2,a0
	move.l	a0,scriptloc
	bsr.w	WAITBLIT
	move.l	SCREEN+4,a0
	move.l	a0,$dff050
	lea	IMAGE,a1
	move.l	a1,$dff054
	move.l	#$09f00000,$dff040
	move.w	#$ffffffff,$dff044
	clr.l	$dff064
	move.w	#0*64+20,$dff058
	bsr.w	WAITBLIT
	bra.w	scriptreader
	
doubleset:
	lea	pointers,a2
	move.l	screen+4,a1
	move.l	a1,d3
	move.w	d3,6(a2)
	swap	d3
	move.w	d3,2(a2)
	swap	d3
	add.l	#40,d3
	move.w	d3,14(a2)
	swap	d3
	move.w	d3,10(a2)
	swap	d3
	add.l	#40,d3
	move.w	d3,22(a2)
	swap	d3
	move.w	d3,18(a2)
	swap	d3
	add.l	#40,d3
	move.w	d3,30(a2)
	swap	d3
	move.w	d3,26(a2)
	rts

doubleset2:
	move.l	screen,a0
	move.l	screen+4,a1
	move.l	a0,screen+4
	move.l	a1,screen
	rts

**********************************

HIDDEN:
	move.w	#0,NUMFACE
	lea	OBJTABLE1(pc),a3
	lea	OBJTABLE2(pc),a1
	lea	FACETABLE(pc),a2
	lea	FACETABLE2(pc),a5
	move.l	OBJCOORDS+4,a4
	move.w	(a4),d6
	lea	2(a4),a4
	
HIDLOP:	movem.l	(a4)+,a0
	bsr.b	FACETEST
	lea	2(a2),a2
	lea	2(a5),a5
	dbf	d6,HIDLOP
	rts

FACETEST:
	move.w	4(a0),d7
	lsl.w	#2,d7
	movem.w	(a1,d7.w),d0-d1
	move.w	6(a0),d7
	lsl.w	#2,d7
	movem.w	(a1,d7.w),d2-d3
	move.w	8(a0),d7
	lsl.w	#2,d7
	movem.w	(a1,d7.w),d4-d5
	asr.w	d0
	asr.w	d1
	asr.w	d2
	asr.w	d3
	asr.w	d4
	asr.w	d5
	
	sub.w	d0,d2
	sub.w	d1,d3
	sub.w	d0,d4
	sub.w	d1,d5
	ext.l	d2
	ext.l	d3
	ext.l	d4
	ext.l	d5
	muls	d2,d5
	muls	d3,d4
	sub.l	d4,d5
	bmi.b	FACEOK
	move.w	#0,(a2)
	rts
FACEOK:
	move.w	#1,(a2)
	add.w	#1,NUMFACE
	moveq.l	#0,d5
	move.w	(a0),d5
	move.w	d5,d4
	moveq.l	#0,d7
	moveq.l	#0,d0
	sub.w	#1,d4
FOL:	move.w	4(a0),d3
	lsl.w	d3
	add.w	(a3,d3.w),d7
;	asl.w	d0
;	add.w	d0,d7
	lea	2(a0),a0
	dbf	d4,FOL
	ext.l	d5
	ext.l	d7
	divs	d5,d7
;	asl.w	#2,d7
	move.w	d7,(a5)
	rts

**********************************

CONVERSION:
	lea	OBJCOORDS(pc),a5
	move.l	(a5),a5
	
	lea	OBJPOS(pc),a0
	lea	matsin(pc),a1
	lea	OBJTABLE1(pc),a6
	lea	OBJTABLE2(pc),a3
	
masterrotaction:
	move.w	(a0),d0	
	add.w	d0,d0
	lea	(a1,d0.w),a4	; sin(x)

	move.w	2(a0),d0
	add.w	d0,d0
	LEA	(A1,D0.W),A2	; sin(y)

	move.w	4(a0),d0
	add.w	d0,d0
	LEA	(a1,d0.w),A1	; sin(z)
	
	move.w	10(a0),d7
	
convloop:
	move.w	(a5)+,d1	; x
	asl.w	#2,d1
	move.w	(a5)+,d2	; y
	asl.w	#2,d2
	move.w	(a5)+,d3	; z
	asl.w	#2,d3

rotxz:  tst.w	(a0)
	beq.s	rotxy
	move.w	d1,d4		;x
	move.w	d3,d6		;z
	muls	180(a4),d4	;x*cos(x)
	muls	(a4),d6		;z*cos(x)
	sub.l	d6,d4		;x*cos(x)-z*cos(x)
	add.l	d4,d4
	swap	d4		;x
	muls	(a4),d1		;x*sin(x)
	muls	180(a4),d3	;z*cos(x)
	add.l	d1,d3		;x*sin(x)+z*cos(x)
	add.l	d3,d3
	swap	d3		;z
	move.w	d4,d1

rotxy:  tst.w	2(a0)
	beq.s	rotyz
	move.w	d1,d4		;x
	move.w	d2,d6		;y
	muls	180(a2),d4	;x*cos(y)
	muls	(a2),d6		;y*sin(y)
	sub.l	d6,d4		;x*cos(y)-y*sin(y)
	add.l	d4,d4
	swap	d4		;x
	muls	(a2),d1		;x*sin(y)
	muls	180(a2),d2	;y*cos(y)
	add.l	d1,d2		;x*sin(y)+y*cos(y)
	add.l	d2,d2
	swap	d2		;y
	move.w	d4,d1

rotyz:  tst.w	4(a0)
	beq.s	rotend
	move.w	d2,d4		;y
	move.w	d3,d6		;z
	muls	180(a1),d4	;y*cos(z)
	muls	(a1),d6		;z*sin(z)
	sub.l	d6,d4		;y*cos(z)-z*sin(z)
	add.l	d4,d4
	swap	d4		;y
	muls	(a1),d2		;y*sin(z)
	muls	180(a1),d3	;z*cos(z)
	add.l	d2,d3		;y*sin(z)+z*cos(z)
	add.l	d3,d3
	swap	d3		;z
	move.w	d4,d2
rotend:
	move.w	d3,(a6)+
	add.w	d7,d3
	ext.l	d1
	ext.l	d2
	ext.l	d3
	asl.l	#8,d1
	asl.l	#8,d2
	divs	d3,d1
	divs	d3,d2		
	movem.w	d1-d2,(a3)
	lea	4(a3),a3
	cmp.w	#$7fff,(a5)
	bne.w	convloop
	move.w	#$7fff,(a3)
	rts

**********************************

MAXCOORDS:
	lea	OBJTABLE2(pc),a0
	lea	XM(pc),a1
	movem.w	(a0),d0-d3
	move.w	#$7fff,d7
LOOP:	movem.w	(a0)+,d4-d5
	cmp.w	d7,d4
	beq.b	MAXEND
	cmp.w	d0,d4
	bge.b	CMP1
	move.w	d4,d0
CMP1:	cmp.w	d2,d4
	ble.b	CMP2
	move.w	d4,d2
CMP2:	cmp.w	d1,d5
	bge.b	CMP3
	move.w	d5,d1
CMP3:	cmp.w	d3,d5
	ble.b	CMP4
	move.w	d5,d3
CMP4:	bra.b	LOOP

MAXEND:
	lea	OBJPOS(pc),a5
	add.w	6(a5),d0
	add.w	8(a5),d1
	add.w	6(a5),d2
	add.w	8(a5),d3

	cmp.w	#0,d0
	bge.b	CMP5
	move.w	#0,d0
CMP5:	cmp.w	#319,d0
	ble.b	CMP6
	move.w	#319,d0
CMP6:	cmp.w	#0,d2
	bge.b	CMP7
	move.w	#0,d2
CMP7:	cmp.w	#319,d2
	ble.b	CMP8
	move.w	#319,d2
CMP8:	cmp.w	#0,d1
	bge.b	CMP9
	move.w	#0,d1
CMP9:	cmp.w	#255,d1
	ble.b	CMP10
	move.w	#255,d1
CMP10:	cmp.w	#0,d3
	bge.b	CMP11
	move.w	#0,d3
CMP11:	cmp.w	#255,d3
	ble.b	CMP12
	move.w	#255,d3
CMP12:	
	movem.w	d0-d3,(a1)
	rts

**********************************

DELETESCREEN:
	lea	XM(pc),a0
	moveq	#0,d4
	movem.w	(a0),d0-d3
	cmp.w	d0,d2
	beq.w	DSX
	cmp.w	d1,d3
	beq.w	DSX
	move.w	d1,d4
	mulu.w	#160,d4			;No. of Bitplanes	
	moveq	#0,d5
	move.w	d0,d5
	lsr.w	#3,d5
	bclr	#0,d5
	add.l	d5,d4
	sub.w	d2,d0
	sub.w	d3,d1
	beq.b	DSX
	neg.w	d0
	bmi.b	DSX
;	ext.l	d1
	neg.w	d1
	lsr.w	#4,d0
	addq.w	#2,d0
	cmp.w	#20,d0
	ble.b	CX1
	move.w	#20,d0
CX1:	move.w	#40,d5
	sub.w	d0,d5
	sub.w	d0,d5
	move.w	d1,d7
	add.w	d7,d1
	add.w	d7,d1
	add.w	d7,d1
	lsl.w	#6,d1
	or.w	d1,d0
	bsr.w	WAITBLIT
	lea	$dff000,a5
	move.l	Screen,a0
	lea	IMAGE,a1
	lea	(a0,d4.l),a0
	lea	(a1,d4.l),a1
	move.w	d5,$66(a5)
	move.w	d5,$64(a5)
	moveq	#$ffffffff,d2
	move.l	d2,$44(a5)
	clr.w	$42(a5)
	clr.w	$74(a5)
	move.w	#$09f0,d2
	move.l	a1,$50(a5)
	move.l	a0,$54(a5)
	move.w	d2,$40(a5)
	move.w	d0,$58(a5)
DSX:	rts

**********************************

DRAWLINES:   
wait	btst	#$e,$dff002
	bne.B	wait
	
	move.w	NUMFACE,d6
	sub.w	#1,d6
			
TLINE:	lea	FACETABLE(pc),a2
	lea	FACETABLE2(pc),a6
	move.l	OBJCOORDS+4,a5
	move.w	(a5),d5
	lea	2(a5),a5
	move.w	#32767,d7
	moveq.l	#0,d3
	moveq.l	#0,d2
	move.w	d5,d4

FDL:	tst.w	(a2)
	beq.b	TLINECONT
	cmp.w	(a6),d7
	ble.b	TLINECONT
	move.w	(a6),d7
	move.w	d3,d2
TLINECONT:
	add.w	#1,d3
	lea	2(a2),a2
	lea	2(a6),a6
	dbf	d4,FDL

	lea	FACETABLE(pc),a2
	lsl.w	d2
	move.w	#0,(a2,d2.w)
	lsl.w	d2
	move.l	(a5,d2.w),a5

	movem.l	d6,-(a7)
	bsr.w	waitblit

	move.w  #40,$dff060	
	move.l	#$ffff8000,$dff072
	move.l	#$ffffffff,$dff044	
	lea	FACESCREEN,a6
	lea	oct_tab(pc),a1
	lea	XMF(pc),a4
	lea	OBJTABLE2(pc),a3
	
	bsr.b	DrawLine
	bsr.w	FILLFACE
	tst.w	NOFACE
	bne.b	NF
	bsr.w	COPYFACE
	bsr.w	DELFACE
NF:	movem.l	(a7)+,d6
	dbf	d6,TLINE
TEND:	rts



DrawLine:
	move.w	(a5)+,d7
	subq.w	#1,d7
	move.l	#$10001000,(a4)
	move.l	#$00000000,4(a4)
	move.w	(a5)+,COL
Faceloop:
	move.w	(a5)+,d5
	lsl.w	#2,d5
	move.w	(a3,d5.w),d1
	move.w	2(a3,d5.w),d3
	move.w	(a5),d5
	lsl.w	#2,d5
	move.w	(a3,d5.w),d2
	move.w	2(a3,d5.w),d4
	move.l	a5,-(a7)
	lea	OBJPOS(pc),a5
	add.w	6(a5),d1
	add.w	8(a5),d3
	add.w	6(a5),d2
	add.w	8(a5),d4
	
	cmp.w	(a4),d1
	bge.b	CMP1F
	move.w	d1,(a4)
CMP1F:	cmp.w	4(a4),d1
	ble.b	CMP2F
	move.w	d1,4(a4)
CMP2F:	cmp.w	2(a4),d3
	bge.b	CMP3F
	move.w	d3,2(a4)
CMP3F:	cmp.w	6(a4),d3
	ble.b	CMP4F
	move.w	d3,6(a4)
CMP4F:	cmp.w	(a4),d2
	bge.b	CMP5F
	move.w	d2,(a4)
CMP5F:	cmp.w	4(a4),d2
	ble.b	CMP6F
	move.w	d2,4(a4)
CMP6F:	cmp.w	2(a4),d4
	bge.b	CMP7F
	move.w	d4,2(a4)
CMP7F:	cmp.w	6(a4),d4
	ble.b	CMP8F
	move.w	d4,6(a4)
CMP8F:
	cmp.w	#0,(a4)
	bge.b	CMP5S
	move.w	#0,(a4)
CMP5S:	cmp.w	#319,(a4)
	ble.b	CMP6S
	move.w	#319,(a4)
CMP6S:	cmp.w	#0,4(a4)
	bge.b	CMP7S
	move.w	#0,4(a4)
CMP7S:	cmp.w	#319,4(a4)
	ble.b	CMP8S
	move.w	#319,4(a4)
CMP8S:	cmp.w	#1,2(a4)
	bge.b	CMP9S
	move.w	#1,2(a4)
CMP9S:	cmp.w	#255,2(a4)
	ble.b	CMP10S
	move.w	#255,2(a4)
CMP10S:	cmp.w	#0,6(a4)
	bge.b	CMP11S
	move.w	#0,6(a4)
CMP11S:	cmp.w	#255,6(a4)
	ble.b	CMP12S
	move.w	#255,6(a4)
CMP12S:	
	sub.w	#1,2(a4)
	moveq.l	#0,d5
	lea	$dff000,a5

	bsr.w	DLINESTART
	
	move.l	(a7)+,a5
	dbra  d7,Faceloop	
	rts
	
Linestart:
	cmp.w	d3,d4
	ble.b	draw1
	exg	d2,d1
	exg	d4,d3
draw1:	
	BSR.W	LB_4B6E
	CMP.W	D3,D4
	BGT.B	CLB_48A6
	EXG	D1,D2
	EXG	D3,D4
CLB_48A6
	BSR.W	LB_4B54
	CMP.W	D3,D4
	BEQ.B	XZLINE

	move.w	d3,d0
	muls.w	#40,d0
;	ext.l	d0
	move.w	d1,d5
	lea	FACESCREEN,a6
	add.l	a6,d0
	asr.w	#3,d5
	ext.l	d5
	add.l	d5,d0
	moveq	#0,d5
	sub.w	d3,d4
	sub.w	d1,d2
	bpl.B	draw2
	moveq	#1,d5
	neg.w	d2
draw2:
	move.w	d4,d3
	add.w	d3,d3
	cmp.w	d2,d3
	dbhi	d4,draw3
draw3
	move.w	d4,d3
	sub.w	d2,d3
	bpl.B	draw4
	exg	d4,d2
draw4:
	addx.w	d5,d5
	add.w	d2,d2
	move.w	d2,d3
	sub.w	d4,d2
	addx	d5,d5
	andi.w	#$f,d1
	ror.w	#4,d1
	ori.w	#$a4a,d1
wait2	btst	#$e,2(a5)
	bne.B	wait2
	move.w	d2,$52(a5)
	sub.w	d4,d2
	lsl.w	#6,d4
	addq.w	#2,d4
	move.w	d1,$40(a5)
	move.b	(a1,d5.w),$43(a5)
	exg	d2,d3
	movem.w	d2-d3,$62(a5)
	move.l	d0,$48(a5)
	move.l	d0,$54(a5)
	move.w	d4,$58(a5)

XZLINE
	TST.W	LB_4BB6
	BEQ.B	CLB_4B3E
	CLR.W	LB_4BB6
	ADDQ.W	#1,LB_478A
	MOVE.W	LB_4BB8,D3
	TST.W	D3
	BPL.B	CLB_4B02
	CLR.W	D3
	BRA.B	CLB_4B10
CLB_4B02
	CMP.W	LB_4BB0,D3
	BLE.B	CLB_4B10
	MOVE.W	LB_4BB0,D3
CLB_4B10
	MOVE.W	LB_4BB4,D1
	MOVE.W	LB_4BBA,D4
	TST.W	D4
	BPL.B	CLB_4B26
	CLR.W	D4
	BRA.B	CLB_4B34
CLB_4B26
	CMP.W	LB_4BB0,D4
	BLE.B	CLB_4B34
	MOVE.W	LB_4BB0,D4
CLB_4B34
	MOVE.W	LB_4BB4,D2
	BRA.W	linestart
CLB_4B3E
	RTS

DLINESTART:
	MOVE.L	#$00001000,LB_4034
	MOVE.L	#$00001000,LB_4038
	MOVE.L	#$00001000,LB_403C
	MOVE.L	#$00001000,LB_4040
	MOVE.L	#$00001000,LB_4044
	MOVE.L	#$00001000,LB_4048
	CLR.W	LB_478A
	CLR.L	LB_4BB8
	BRA.B	LB_4BBC

LB_4B54	LEA	LB_4034(pc),A6
	CMP.W	(A6),D4
	BLE.B	LB_4B60
	MOVE.W	D4,(A6)
LB_4B60	CMP.W	$0002(A6),D3
	BGE.B	LB_4B6A
	MOVE.W	D3,$0002(A6)
LB_4B6A	RTS	
LB_4B6E LEA	LB_4038(pc),A6
	TST.W	LB_4B6C
	BEQ.B	LB_4B8A
	CLR.W	LB_4B6C
	MOVE.W	LB_4BB2,$0002(A6)
LB_4B8A	CMP.W	(A6),D2
	BLE.B	LB_4B90
	MOVE.W	D2,(A6)
LB_4B90	CMP.W	$0002(A6),D1
	BGE.B	LB_4B9A
	MOVE.W	D1,$0002(A6)
LB_4B9A	CMP.W	(A6),D1
	BLE.B	LB_4BA0
	MOVE.W	D1,(A6)
LB_4BA0	CMP.W	$0002(A6),D2
	BGE.B	LB_4BAA
	MOVE.W	D2,$0002(A6)
LB_4BAA	RTS	
LB_4BBC	MOVE.L	D6,-(A7)
	CMP.W	D1,D2
	BGT.B	LB_4BC6
	EXG	D1,D2
	EXG	D3,D4
LB_4BC6	CMP.W	LB_4BB2,D2
	BLT.W	LB_4CBE
	CMP.W	LB_4BB2,D1
	BGE.B	LB_4C10
	MOVE.W	LB_4BB2,D6
	SUB.W	D2,D6
	SUB.W	D4,D3
	MULS.W	D6,D3
	SUB.W	D2,D1
	BEQ.B	LB_4BEC
	DIVS.W	D1,D3
LB_4BEC	MOVE.W	LB_4BB2,D1
	ADD.W	D4,D3
	BPL.B	LB_4BFC
	TST.W	D4
	BMI.W	LB_4CBE
LB_4BFC	CMP.W	LB_4BB0,D3
	BLE.B	LB_4C10
	CMP.W	LB_4BB0,D4
	BLE.B	LB_4C10
	BRA.W	LB_4CBE
LB_4C10	CMP.W	LB_4BB4,D1
	BGT.W	LB_4D4C
	CMP.W	LB_4BB4,D2
	BLT.B	LB_4C52
	MOVE.W	LB_4BB4,D6
	MOVE.W	#$0001,LB_4BB6
	MOVE.W	D4,LB_4BB8
	SUB.W	D1,D6
	SUB.W	D3,D4
	MULS.W	D6,D4
	SUB.W	D1,D2
	BEQ.B	LB_4C44
	DIVS.W	D2,D4
LB_4C44	ADD.W	D3,D4
	MOVE.W	D4,LB_4BBA
	MOVE.W	LB_4BB4,D2
LB_4C52	CMP.W	D3,D4
	BGT.B	LB_4C5A
	EXG	D1,D2
	EXG	D3,D4
LB_4C5A	CMP.W	LB_4BAE,D4
	BLT.B	LB_4CBE
	CMP.W	LB_4BAE,D3
	BGT.B	LB_4C88
	MOVE.W	LB_4BAE,D6
	SUB.W	D4,D6
	SUB.W	D2,D1
	MULS.W	D6,D1
	SUB.W	D4,D3
	BEQ.B	LB_4C80
	DIVS.W	D3,D1
LB_4C80	ADD.W	D2,D1
	MOVE.W	LB_4BAE,D3
LB_4C88	CMP.W	LB_4BB0,D3
	BGT.B	LB_4CBE
	CMP.W	LB_4BB0,D4
	BLT.B	LB_4CB8
	MOVE.W	LB_4BB0,D6
	SUB.W	D3,D6
	SUB.W	D1,D2
	MULS.W	D6,D2
	SUB.W	D3,D4
	BEQ.B	LB_4CB0
	DIVS.W	D4,D2
LB_4CB0	ADD.W	D1,D2
	MOVE.W	LB_4BB0,D4
LB_4CB8	MOVE.L	(A7)+,D6
	BRA.W	linestart
LB_4CBE	MOVE.L	(A7)+,D6
	CMP.W	LB_4BB2,D1
	BGE.B	LB_4CCE
	MOVE.W	LB_4BB2,D1
LB_4CCE	CMP.W	LB_4BB4,D1
	BLE.B	LB_4CDC
	MOVE.W	LB_4BB4,D1
LB_4CDC	CMP.W	LB_4BB2,D2
	BGE.B	LB_4CEA
	MOVE.W	LB_4BB2,D2
LB_4CEA	CMP.W	LB_4BB4,D2
	BLE.B	LB_4CF8
	MOVE.W	LB_4BB4,D2
LB_4CF8	CMP.W	LB_4BAE,D3
	BGE.B	LB_4D06
	MOVE.W	LB_4BAE,D3
LB_4D06	CMP.W	LB_4BB0,D3
	BLE.B	LB_4D14
	MOVE.W	LB_4BB0,D3
LB_4D14	CMP.W	LB_4BAE,D4
	BGE.B	LB_4D22
	MOVE.W	LB_4BAE,D4
LB_4D22	CMP.W	LB_4BB0,D4
	BLE.B	LB_4D30
	MOVE.W	LB_4BB0,D4
LB_4D30	CMP.W	D1,D2
	BGT.B	LB_4D38
	EXG	D1,D2
	EXG	D3,D4
LB_4D38	BSR.W	LB_4B6E
	CMP.W	D3,D4
	BGT.B	LB_4D44
	EXG	D1,D2
	EXG	D3,D4
LB_4D44	BSR.W	LB_4B54
	BRA.W	XZLINE
LB_4D4C	MOVE.L	(A7)+,D6
	MOVE.W	D3,LB_4BB8
	MOVE.W	D4,LB_4BBA
	MOVE.W	#$0001,LB_4BB6
	BRA.W	XZLINE

**********************************

FILLFACE:
	move.w	#0,NOFACE
	lea	XMF(pc),a0
	moveq	#0,d4
	movem.w	(a0),d0-d3
	cmp.w	d0,d2
	beq.w	DSZ
	cmp.w	d1,d3
	beq.w	DSZ
	move.w	d3,d4
	mulu.w	#40,d4
	moveq	#0,d5
	move.w	d2,d5
	lsr.w	#3,d5
	bclr	#0,d5
	add.l	d5,d4
	move.w	d0,d6
	lsr.w	#3,d6
	bclr	#0,d6
	sub.w	d3,d1
	beq.b	DSZ
	neg.w	d1
	sub.w	d6,d5
	lsr.w	#1,d5
	move.w	d5,d0
	addq.w	#1,d0
;	cmp.w	#20,d0
;	ble	CX2
;	move.w	#20,d0
CX2:	move.w	d0,BLITLARG
	move.w	#40,d5
	sub.w	d0,d5
	sub.w	d0,d5
	lsl.w	#6,d1
	or.w	d1,d0
	bsr.w	WAITBLIT
	lea	$dff000,a5
	move.l	d4,BLITOFFSET
	lea.l	FACESCREEN,a0
	lea	(a0,d4.l),a0
	move.w	d5,$64(a5)
	move.w	d5,$66(a5)
	move.w	d5,BLITMODUL
	moveq	#$ffffffff,d2
	move.l	d2,$44(a5)
	move.l	#$09f00012,d2
	move.l	a0,$54(a5)
	move.l	a0,$50(a5)
	move.l	a0,BLITPOINT
	move.l	d2,$40(a5)
	move.w	d0,BLITSIZE3
	move.w	d0,$58(a5)
	rts
DSZ:	move.w	#$ffff,NOFACE
	rts

**********************************

COPYFACE:
	bsr.w	WAITBLIT
	lea	$dff000,a5
	moveq	#$ffffffff,d2
	move.l	d2,$44(a5)
	move.w	BLITLARG,d0
	move.w	#160,d1
	sub.w	d0,d1
	sub.w	d0,d1
	move.w	d1,$66(a5)
	move.w	d1,$62(a5)
	move.w	BLITMODUL,d0
	move.w	d0,$64(a5)
	move.l	BLITPOINT,a0
	lea	XMF(pc),a2
	moveq	#0,d4
	movem.w	4(a2),d0-d1
	move.w	d1,d4
	mulu.w	#160,d4
	moveq	#0,d5
	move.w	d0,d5
	lsr.w	#3,d5
	bclr	#0,d5
	add.l	d5,d4
	move.l	Screen,a1
	lea	(a1,d4.l),a1
	move.w	BLITSIZE3,d0
	move.w	COL,d6
	move.w	#$0002,d2

	move.w	#$0dfc,d1
	btst	#0,d6
	bne.b	CF1
	move.w	#$0d0c,d1
CF1:	move.l	a0,$50(a5)
	move.l	a1,$54(a5)
	move.l	a1,$4c(a5)
	move.w	d1,$40(a5)
	move.w	d2,$42(a5)
	move.w	d0,$58(a5)
	bsr.w	WAITBLIT

	lea	40(a1),a1
	move.w	#$0dfc,d1
	btst	#1,d6
	bne.b	CF2
	move.w	#$0d0c,d1
CF2:	move.l	a0,$50(a5)
	move.l	a1,$54(a5)
	move.l	a1,$4c(a5)
	move.w	d1,$40(a5)
	move.w	d2,$42(a5)
	move.w	d0,$58(a5)
	bsr.w	WAITBLIT

	lea	40(a1),a1
	move.w	#$0dfc,d1
	btst	#2,d6
	bne.b	CF3
	move.w	#$0d0c,d1
CF3:	move.l	a0,$50(a5)
	move.l	a1,$54(a5)
	move.l	a1,$4c(a5)
	move.w	d1,$40(a5)
	move.w	d2,$42(a5)
	move.w	d0,$58(a5)
	bsr.w	WAITBLIT

	lea	40(a1),a1
	move.w	#$0dfc,d1
	btst	#3,d6
	bne.b	CF4
	move.w	#$0d0c,d1
CF4:	move.l	a0,$50(a5)
	move.l	a1,$54(a5)
	move.l	a1,$4c(a5)
	move.w	d1,$40(a5)
	move.w	d2,$42(a5)
	move.w	d0,$58(a5)
	bsr.w	WAITBLIT

	rts
	
**********************************

DELFACE:
PIP:	bsr.w	WAITBLIT
	lea	$dff000,a5
	move.l	#$01000002,$40(a5)
	move.l	BLITPOINT,a0
	move.l	a0,$54(a5)
	move.w	BLITMODUL,d0
	move.w	d0,$66(a5)
	move.w	BLITSIZE3,d1
	move.w	d1,$58(a5)
	bsr.w	WAITBLIT
	rts
	

*********************************************************
;This routine adds the Lableadresses to all 
;adresses in the objects.
;Insert the Load-Lables after -objectsaddtable-!!!

OBJECTSTABLE:
	dc.l	VEKTDATA1
	dc.l	VEKTDATA2
	dc.l	$ffffffff

OBJADD:
	lea	OBJECTSTABLE(pc),a0
OBJADD1:
	move.l	(a0)+,d0
	cmp.l	#$ffffffff,d0
	beq.s	OBJADDEND
	move.l	d0,a1
	move.l	(a1),d1
	add.l	d0,d1
	move.l	d1,a2
;	addq.l	#2,d1
	move.l	d1,(a1)
	move.w	(a2)+,d2
OBJADD2:
	move.l	(a2),d1
	add.l	d0,d1
	move.l	d1,(a2)+
	dbf	d2,OBJADD2
	bra.b	OBJADD1
OBJADDEND:
	rts

**************************************************


;OBJECT DATA STRUCTURE------------------------------------------------

	
OBJCOORDS:
	dc.l	0,0
;	points,faces

OBJPOS:
	dc.w	100,50,100		;xrot,yrot,zrot
	dc.w	160,100,-200		;xpos,ypos,zpos
	dc.w	0,0,0
	dc.w	0,0,0
	
OBJCOLOR:
	dc.l	0
	
OBJTABLE1:
	blk.b	1024,0
OBJTABLE2:
	blk.b	1024,0

FACETABLE:
	blk.w	100,0
FACETABLE2:
	blk.w	100,0

VEKTDATA1:
	dc.l	FACEBASE-VEKTDATA1
	
	dc.w 0,130,0
	dc.w -20,100,0
	dc.w 0,90,-10
	dc.w 0,90,10
	dc.w 20,100,0
	dc.w -10,-50,0
	dc.w 0,-50,-5
	dc.w 0,-50,5
	dc.w 10,-50,0
	dc.w 40,-50,-10
	dc.w -40,-50,-10
	dc.w -40,-70,-10
	dc.w 40,-70,-10
	dc.w 40,-50,10
	dc.w -40,-50,10
	dc.w -40,-70,10
	dc.w 40,-70,10
	dc.w 10,-70,-10
	dc.w -10,-70,-10
	dc.w -10,-120,-10
	dc.w 10,-120,-10
	dc.w 10,-70,10
	dc.w -10,-70,10
	dc.w -10,-120,10
	dc.w 10,-120,10
	dc.w	$7fff
	
	FACEBASE:
	dc.w 18
	dc.l	FACE1-VEKTDATA1
	dc.l	FACE2-VEKTDATA1
	dc.l	FACE3-VEKTDATA1
	dc.l	FACE4-VEKTDATA1
	dc.l	FACE5-VEKTDATA1
	dc.l	FACE6-VEKTDATA1
	dc.l	FACE7-VEKTDATA1
	dc.l	FACE8-VEKTDATA1
	dc.l	FACE9-VEKTDATA1
	dc.l	FACE10-VEKTDATA1
	dc.l	FACE11-VEKTDATA1
	dc.l	FACE12-VEKTDATA1
	dc.l	FACE13-VEKTDATA1
	dc.l	FACE14-VEKTDATA1
	dc.l	FACE15-VEKTDATA1
	dc.l	FACE16-VEKTDATA1
	dc.l	FACE17-VEKTDATA1
	dc.l	FACE18-VEKTDATA1
	dc.l	FACE19-VEKTDATA1

FACE1:	dc.w 3,2,0,1,2,0
FACE2:	dc.w 3,1,0,3,1,0
FACE3:	dc.w 3,1,0,2,4,0
FACE4:	dc.w 3,2,0,4,3,0
FACE5:	dc.w 4,1,2,1,5,6,2
FACE6:	dc.w 4,2,3,7,5,1,3
FACE7:	dc.w 4,2,4,2,6,8,4
FACE8:	dc.w 4,1,4,8,7,3,4
FACE9:	dc.w 4,11,9,10,11,12,9
FACE10:	dc.w 4,11,13,16,15,14,13
FACE11:	dc.w 4,12,10,9,13,14,10
FACE12:	dc.w 4,13,11,10,14,15,11
FACE13:	dc.w 4,12,12,11,15,16,12
FACE14:	dc.w 4,13,9,12,16,13,9
FACE15:	dc.w 4,5,17,18,19,20,17
FACE16:	dc.w 4,5,21,24,23,22,21
FACE17:	dc.w 4,7,19,18,22,23,19
FACE18:	dc.w 4,6,20,19,23,24,20
FACE19:	dc.w 4,7,17,20,24,21,17

VEKTDATA2:
VEK:
	dc.l	FBASE-VEK
	dc.w 110,-60,20
	dc.w 120,-40,20
	dc.w 110,-20,20
	dc.w 120,0,20
	dc.w 110,20,20
	dc.w 120,40,20
	dc.w 110,60,20
	dc.w 120,80,20
	dc.w 110,100,20
	dc.w 60,100,20
	dc.w 40,90,20
	dc.w 30,80,20
	dc.w 20,60,20
	dc.w 30,40,20
	dc.w 40,30,20
	dc.w 60,20,20
	dc.w 20,-60,20
	dc.w -10,100,-20
	dc.w -160,100,-20
	dc.w -110,80,-20
	dc.w -100,60,-20
	dc.w -110,40,-20
	dc.w -100,20,-20
	dc.w -110,0,-20
	dc.w -100,-20,-20
	dc.w -110,-40,-20
	dc.w -90,-60,-20
	dc.w -10,-60,-20
	dc.w -10,20,-20
	dc.w -40,20,-20
	dc.w -20,-40,-20
	dc.w -80,-30,-20
	dc.w -80,80,-20
	dc.w 110,-60,-20
	dc.w 120,-40,-20
	dc.w 110,-20,-20
	dc.w 120,0,-20
	dc.w 110,20,-20
	dc.w 120,40,-20
	dc.w 110,60,-20
	dc.w 120,80,-20
	dc.w 110,100,-20
	dc.w 60,100,-20
	dc.w 40,90,-20
	dc.w 30,80,-20
	dc.w 20,60,-20
	dc.w 30,40,-20
	dc.w 40,30,-20
	dc.w 60,20,-20
	dc.w 20,-60,-20
	dc.w -10,100,20
	dc.w -160,100,20
	dc.w -110,80,20
	dc.w -100,60,20
	dc.w -110,40,20
	dc.w -100,20,20
	dc.w -110,0,20
	dc.w -100,-20,20
	dc.w -110,-40,20
	dc.w -90,-60,20
	dc.w -10,-60,20
	dc.w -10,20,20
	dc.w -40,20,20
	dc.w -20,-40,20
	dc.w -80,-30,20
	dc.w -80,80,20
	dc.w	$7fff

FBASE:
	dc.w	36
	dc.l	FAC1-VEK
	dc.l	FAC2-VEK
	dc.l	FAC3-VEK
	dc.l	FAC4-VEK
	dc.l	FAC5-VEK
	dc.l	FAC6-VEK
	dc.l	FAC7-VEK
	dc.l	FAC8-VEK
	dc.l	FAC9-VEK
	dc.l	FAC10-VEK
	dc.l	FAC11-VEK
	dc.l	FAC12-VEK
	dc.l	FAC13-VEK
	dc.l	FAC14-VEK
	dc.l	FAC15-VEK
	dc.l	FAC16-VEK
	dc.l	FAC17-VEK
	dc.l	FAC18-VEK
	dc.l	FAC19-VEK
	dc.l	FAC20-VEK
	dc.l	FAC21-VEK
	dc.l	FAC22-VEK
	dc.l	FAC23-VEK
	dc.l	FAC24-VEK
	dc.l	FAC25-VEK
	dc.l	FAC26-VEK
	dc.l	FAC27-VEK
	dc.l	FAC28-VEK
	dc.l	FAC29-VEK
	dc.l	FAC30-VEK
	dc.l	FAC31-VEK
	dc.l	FAC32-VEK
	dc.l	FAC33-VEK
	dc.l	FAC34-VEK
	dc.l	FAC35-VEK
	dc.l	FAC36-VEK
	dc.l	FAC37-VEK

FAC1:	dc.w 17,10,0,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
FAC2:	dc.w 16,9,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,17
FAC3:	dc.w 17,9,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,33
FAC4:	dc.w 4,2,1,34,33,0,1
FAC5:	dc.w 4,3,2,35,34,1,2
FAC6:	dc.w 4,4,3,36,35,2,3
FAC7:	dc.w 4,5,4,37,36,3,4
FAC8:	dc.w 4,6,5,38,37,4,5
FAC9:	dc.w 4,7,6,39,38,5,6
FAC10:	dc.w 4,6,7,40,39,6,7
FAC11:	dc.w 4,5,8,41,40,7,8
FAC12:	dc.w 4,4,9,42,41,8,9
FAC13:	dc.w 4,3,10,43,42,9,10
FAC14:	dc.w 4,2,11,44,43,10,11
FAC15:	dc.w 4,3,12,45,44,11,12
FAC16:	dc.w 4,4,13,46,45,12,13
FAC17:	dc.w 4,5,14,47,46,13,14
FAC18:	dc.w 4,6,15,48,47,14,15
FAC19:	dc.w 4,7,16,49,48,15,16
FAC20:	dc.w 4,6,0,33,49,16,0
FAC21:	dc.w 4,2,18,17,50,51,18
FAC22:	dc.w 4,3,19,18,51,52,19
FAC23:	dc.w 4,4,20,19,52,53,20
FAC24:	dc.w 4,5,21,20,53,54,21
FAC25:	dc.w 4,6,22,21,54,55,22
FAC26:	dc.w 4,7,23,22,55,56,23
FAC27:	dc.w 4,6,24,23,56,57,24
FAC28:	dc.w 4,5,25,24,57,58,25
FAC29:	dc.w 4,4,26,25,58,59,26
FAC30:	dc.w 4,3,27,26,59,60,27
FAC31:	dc.w 4,2,28,27,60,61,28
FAC32:	dc.w 4,3,29,28,61,62,29
FAC33:	dc.w 4,4,30,29,62,63,30
FAC34:	dc.w 4,5,31,30,63,64,31
FAC35:	dc.w 4,6,32,31,64,65,32
FAC36:	dc.w 4,7,17,32,65,50,17
FAC37:	dc.w 16,9,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,50,51

objpalette:
	dc.w $000,$f00,$c00,$a00,$800,$0f0,$0c0,$080
objpalette2:
	dc.w $000,$fff,$ccc,$aaa,$888,$666,$444,$222
objpalette3:
	dc.w $000,$f00,$c00,$a00,$800,$0f0,$0c0,$080

**********************************
*    GLOBAL.DATAS

SCREEN:		dc.l	SCREEN1,SCREEN2

;	SCHERMI ALLOCATI A $5a000 e $64000

SCRIPTLOC:      dc.l SCRIPT
efxcounter:	dc.w	0
xadd:		dc.w 0
yadd:		dc.w 0
zadd:		dc.w 0
rotxinc:	dc.w 0
rotyinc:	dc.w 0
rotzinc:	dc.w 0
frompalette:	dc.l	0
topalette:	dc.l	0
FADETIME:	dc.w	0
FADETIME2:	dc.w	0

****
XM:	dc.w	0
YM:	dc.w	0
XP:	dc.w	0
YP:	dc.w	0
****
XMF:	dc.w	0
YMF:	dc.w	0
XPF:	dc.w	0
YPF:	dc.w	0
****
COL:  dc.w 0
****
oct_tab:   
	dc.b $1+2,$41+2,$11+2,$51+2
	dc.b $9+2,$49+2,$15+2,$55+2
****
LB_4034	DC.W	0
LB_4038	DC.W	0
LB_403C	DC.W	0
LB_4040	DC.W	0
LB_4044	DC.W	0
LB_4048	DC.W	0
LB_478A	DC.W	0
LB_4B6C	DC.W	$0000
LB_4BAE DC.W	0	;x limitazioni
LB_4BB0 DC.W	255 
LB_4BB2	DC.W	0	;y limitazioni
LB_4BB4 DC.W	319
LB_4BB6	DC.W	$0000
LB_4BB8	DC.W	$0000
LB_4BBA	DC.W	$0000
****
BLITSIZE3:	dc.w	0
BLITPOINT:	dc.l	0
BLITMODUL:	dc.w	0
BLITOFFSET:	dc.l	0
BLITLARG:	dc.w	0
NOFACE:		dc.w	0
NUMFACE:	dc.w	0
****

COPYSCREENS:
	bsr.w	WAITBLIT
	move.l	SCREEN,a0
	move.l	a0,$dff054
	lea	IMAGE,a1
	move.l	a1,$dff050
	move.l	#$09f00000,$dff040
	move.w	#$ffffffff,$dff044
	clr.l	$dff064
	move.w	#0*64+20,$dff058
	bsr.w	WAITBLIT
	move.l	SCREEN+4,a0
	move.l	a0,$dff054
	lea	IMAGE,a1
	move.l	a1,$dff050
	move.l	#$09f00000,$dff040
	move.w	#$ffffffff,$dff044
	clr.l	$dff064
	move.w	#0*64+20,$dff058
	bsr.w	WAITBLIT
	rts

*********************************************
;       SCRIPT DEI MOVIMENTI DEI SOLIDI
;A = x,y,z,rotx,roty,rotz	   set start coordinates
;B = xadd,yadd,zadd,rotxadd,rotyadd,rotzadd,times to repeat    modify
;C = resmod,fadd,object,lines,palette    set a new object
; modulo schermo,modulo totale (rasterscreen)
;D = frompalette,topalette	  fade from 1 to 2
;F = copy screen into buffer
;Z = address			goto.....

SCRIPT:
	dc.w 'C'
	DC.L VEKTDATA1,OBJPALETTE
	DC.W 'A',-180,128,-1532,0,0,0
	DC.W 'B',4,0,0,9,0,0,87
	DC.W 'B',0,0,-6,8,0,0,100
	DC.W 'B',0,0,0,0,6,4,45
	DC.W 'B',0,0,0,0,8,4,45
	DC.W 'B',0,0,0,0,6,3,45
	DC.W 'B',0,0,0,0,8,2,45
	DC.W 'B',0,0,0,0,4,3,45
	DC.W 'B',0,0,0,0,5,0,45
	DC.W 'F'
	DC.W 'B',0,0,0,0,0,0,10		;questo serve per copiare il doubleb.
	DC.W 'A',500,128,-1532,0,0,0
	DC.W 'B',-4,0,0,9,0,0,87
	DC.W 'B',0,0,-6,8,0,0,100
	DC.W 'B',0,0,0,0,-6,-4,45
	DC.W 'B',0,0,0,0,-8,-4,45
	DC.W 'B',0,0,0,0,-6,-3,45
	DC.W 'B',0,0,0,0,-8,-2,45
	DC.W 'B',0,0,0,0,-4,-3,45
	DC.W 'B',0,0,0,0,-5,0,45
	DC.W 'F'
	DC.W 'B',0,0,0,0,0,0,10		;questo serve per copiare il doubleb.
	dc.w 'C'
	DC.L VEKTDATA2,OBJPALETTE
	DC.W 'A',-180,128,-3032,0,0,0
	DC.W 'B',8,0,0,0,0,0,43
	DC.W 'B',0,0,15,0,2,0,180
PAU	DC.W 'B',0,0,-40,0,0,0,100
	DC.W 'B',0,0,0,4,8,4,180
	DC.W 'B',0,0,22,4,4,4,180
	dc.w 'Z'
	dc.l PAU
	

matsin:
	dc.w	0,572,1144,1715,2286,2856
	dc.w	3425,3993,4560,5126,5690,6252
	dc.w	6813,7371,7927,8481,9032,9580
	dc.w	10126,10668,11207,11743,12275,12803
	dc.w	13328,13848,14364,14876,15383,15886
	dc.w	16383,16876,17364,17846,18323,18794
	dc.w	19260,19720,20173,20621,21062,21497,21925
	dc.w	22347,22762,23170,23571,23964
	dc.w	24351,24730,25101,25465,25821,26169
	dc.w	26509,26841,27165,27481,27788,28087
	dc.w	28377,28659,28932,29196,29451,29697
	dc.w	29934,30162,30381,30591,30791,30982
	dc.w	31163,31335,31498,31650,31794,31927
	dc.w	32051,32165,32269,32364,32448,32523
	dc.w	32588,32642,32687,32722,32747,32762
	dc.w	32767,32762,32747,32722,32687,32642
	dc.w	32588,32523,32448,32364,32269,32165
	dc.w	32051,31927,31794,31650,31498,31335
	dc.w	31163,30982,30791,30591,30381,30162
	dc.w	29934,29697,29451,29196,28932,28659
	dc.w	28377,28087,27788,27481,27165,26841
	dc.w	26509,26169,25821,25465,25101,24730
	dc.w	24351,23964,23571,23170,22762,22347
	dc.w	21925,21497,21062,20621,20173,19720
	dc.w	19260,18794,18323,17846,17364,16876
	dc.w	16384,15886,15383,14876,14364,13848
	dc.w	13328,12803,12275,11743,11207,10668
	dc.w	10126,9580,9032,8481,7927,7371
	dc.w	6813,6252,5690,5126,4560,3993
	dc.w	3425,2856,2286,1715,1144,572
	dc.w	0,-571,-1143,-1714,-2285,-2855
	dc.w	-3425,-3993,-4560,-5125,-5689,-6252
	dc.w	-6812,-7370,-7927,-8480,-9031,-9580
	dc.w	-10125,-10667,-11206,-11742,-12274,-12803
	dc.w	-13327,-13847,-14364,-14875,-15383,-15885
	dc.w	-16383,-16876,-17363,-17846,-18323,-18794
	dc.w	-19259,-19719,-20173,-20620,-21062,-21497
	dc.w	-21925,-22347,-22761,-23169,-23570,-23964
	dc.w	-24350,-24729,-25100,-25464,-25820,-26168
	dc.w	-26509,-26841,-27165,-27480,-27787,-28086
	dc.w	-28377,-28658,-28931,-29195,-29450,-29696
	dc.w	-29934,-30162,-30381,-30590,-30790,-30981
	dc.w	-31163,-31335,-31497,-31650,-31793,-31927
	dc.w	-32050,-32164,-32269,-32363,-32448,-32522
	dc.w	-32587,-32642,-32687,-32722,-32747,-32762
	dc.w	-32767,-32762,-32747,-32722,-32687,-32642
	dc.w	-32587,-32522,-32448,-32363,-32269,-32164
	dc.w	-32050,-31927,-31793,-31650,-31497,-31335
	dc.w	-31163,-30981,-30790,-30590,-30381,-30162
	dc.w	-29934,-29696,-29450,-29195,-28931,-28658
	dc.w	-28377,-28086,-27787,-27480,-27165,-26841
	dc.w	-26509,-26168,-25820,-25464,-25100,-24729
	dc.w	-24350,-23964,-23570,-23169,-22761,-22347
	dc.w	-21925,-21497,-21062,-20620,-20173,-19719
	dc.w	-19259,-18794,-18323,-17846,-17363,-16876
	dc.w	-16383,-15885,-15383,-14875,-14364,-13847
	dc.w	-13327,-12803,-12274,-11742,-11206,-10667
	dc.w	-10125,-9580,-9031,-8480,-7927,-7370
	dc.w	-6812,-6252,-5689,-5125,-4560,-3993
	dc.w	-3425,-2855,-2285,-1714,-1143,-571
	dc.w	0,572,1144,1715,2286,2856
	dc.w	3425,3993,4560,5126,5690,6252
	dc.w	6813,7371,7927,8481,9032,9580
	dc.w	10126,10668,11207,11743,12275,12803
	dc.w	13328,13848,14364,14876,15383,15886
	dc.w	16383,16876,17364,17846,18323,18794
	dc.w	19260,19720,20173,20621,21062,21497
	dc.w	21925,22347,22762,23170,23571,23964
	dc.w	24351,24730,25101,25465,25821,26169
	dc.w	26509,26841,27165,27481,27788,28087
	dc.w	28377,28659,28932,29196,29451,29697
	dc.w	29934,30162,30381,30591,30791,30982
	dc.w	31163,31335,31498,31650,31794,31927
	dc.w	32051,32165,32269,32364,32448,32523
	dc.w	32588,32642,32687,32722,32747,32762
	dc.w	32767,32762,32747,32722,32687,32642
	dc.w	32588,32523,32448,32364,32269,32165
	dc.w	32051,31927,31794,31650,31498,31335
	dc.w	31163,30982,30791,30591,30381,30162
	dc.w	29934,29697,29451,29196,28932,28659
	dc.w	28377,28087,27788,27481,27165,26841
	dc.w	26509,26169,25821,25465,25101,24730
	dc.w	24351,23964,23571,23170,22762,22347
	dc.w	21925,21497,21062,20621,20173,19720
	dc.w	19260,18794,18323,17846,17364,16876
	dc.w	16384,15886,15383,14876,14364,13848
	dc.w	13328,12803,12275,11743,11207,10668
	dc.w	10126,9580,9032,8481,7927,7371
	dc.w	6813,6252,5690,5126,4560,3993
	dc.w	3425,2856,2286,1715,1144,572
	dc.w	0,-571,-1143,-1714,-2285,-2855
	dc.w	-3425,-3993,-4560,-5125,-5689,-6252
	dc.w	-6812,-7370,-7927,-8480,-9031,-9580
	dc.w	-10125,-10667,-11206,-11742,-12274,-12803
	dc.w	-13327,-13847,-14364,-14875,-15383,-15885
	dc.w	-16383,-16876,-17363,-17846,-18323,-18794
	dc.w	-19259,-19719,-20173,-20620,-21062,-21497
	dc.w	-21925,-22347,-22761,-23169,-23570,-23964
	dc.w	-24350,-24729,-25100,-25464,-25820,-26168
	dc.w	-26509,-26841,-27165,-27480,-27787,-28086
	dc.w	-28377,-28658,-28931,-29195,-29450,-29696
	dc.w	-29934,-30162,-30381,-30590,-30790,-30981
	dc.w	-31163,-31335,-31497,-31650,-31793,-31927
	dc.w	-32050,-32164,-32269,-32363,-32448,-32522
	dc.w	-32587,-32642,-32687,-32722,-32747,-32762
	dc.w	-32767,-32762,-32747,-32722,-32687,-32642
	dc.w	-32587,-32522,-32448,-32363,-32269,-32164
	dc.w	-32050,-31927,-31793,-31650,-31497,-31335
	dc.w	-31163,-30981,-30790,-30590,-30381,-30162
	dc.w	-29934,-29696,-29450,-29195,-28931,-28658
	dc.w	-28377,-28086,-27787,-27480,-27165,-26841
	dc.w	-26509,-26168,-25820,-25464,-25100,-24729
	dc.w	-24350,-23964,-23570,-23169,-22761,-22347
	dc.w	-21925,-21497,-21062,-20620,-20173,-19719
	dc.w	-19259,-18794,-18323,-17846,-17363,-16876
	dc.w	-16383,-15885,-15383,-14875,-14364,-13847
	dc.w	-13327,-12803,-12274,-11742,-11206,-10667
	dc.w	-10125,-9580,-9031,-8480,-7927,-7370
	dc.w	-6812,-6252,-5689,-5125,-4560,-3993
	dc.w	-3425,-2855,-2285,-1714,-1143,-571
	CNOP	0,4
	

	section	GFX,data_c

;*****************************
;*			     *
;*      COPPER1 PROGRAM      *
;*			     *
;*****************************

COPLIST:
	DC.W	$0100,$5200	; Bit-Plane control reg.
	dc.w	$01fc,$0000
	DC.W	$0102,$0000	; Hor-Scroll
	DC.W	$0104,$0010	; Sprite/Gfx priority
	DC.W	$0108,120	; Modulo (odd)
	DC.W	$010A,120	; Modulo (even)
	DC.W	$008E,$2C81	; Screen Size
	DC.W	$0090,$2CC1	; Screen Size
	DC.W	$0092,$0038	; H-start
	DC.W	$0094,$00D0	; H-stop

POINTERS:

BPL1:	dc.w	$00e0,$0000	;Handler for 6 bitplanes
	dc.w	$00e2,$0000
BPL2:	dc.w	$00e4,$0000
	dc.w	$00e6,$0000
BPL3:	dc.w	$00e8,$0000
	dc.w	$00ea,$0000
BPL4:	dc.w	$00ec,$0000
	dc.w	$00ee,$0000
BPL5:	dc.w	$00f0,$0000
	dc.w	$00f2,$0000
	
	dc.w	$9e01,$fffe
	dc.w	$0100,$4200
	
	dc.w	$f201,$fffe
BPL6:
	dc.w	$00f0,$0000
	dc.w	$00f2,$0000
	dc.w	$0100,$5200
	

colors:
	dc.w	$0180,$0210
	dc.w	$0182,$09BD
	dc.w	$0184,$0DDE
	dc.w	$0186,$07AD
	dc.w	$0188,$069D
	dc.w	$018A,$0235
	dc.w	$018C,$0346
	dc.w	$018E,$0124
	dc.w	$0190,$0321
	dc.w	$0192,$0432
	dc.w	$0194,$0543
	dc.w	$0196,$0654
	dc.w	$0198,$0765
	dc.w	$019A,$0876
	dc.w	$019C,$0987
	dc.w	$019E,$0457

	dc.w	$01a0,$0210*$3
	dc.w	$01a2,$09BD*$2
	dc.w	$01a4,$0DDE*$2
	dc.w	$01a6,$07AD*$2
	dc.w	$01a8,$069D*$2
	dc.w	$01aA,$0235*$2
	dc.w	$01aC,$0346*$2
	dc.w	$01aE,$0124*$3
	dc.w	$01b0,$0321*$2
	dc.w	$01b2,$0432*$2
	dc.w	$01b4,$0543*$2
	dc.w	$01b6,$0654*$2
	dc.w	$01b8,$0765*$2
	dc.w	$01bA,$0876*$2
	dc.w	$01bC,$0987*$2
	dc.w	$01bE,$0457*$2




	dc.w	$ffdf,$fffe	;wait for msb vertical
	
	DC.L	$FFFFFFFE
	DC.L	$FFFFFFFE

	CNOP	0,4
	

*********STACKS.........

OLDUSSTACK:
	DC.L	0
OLDSSSTACK:
	DC.L	0
	
	blk.l	1024,0
USSTACK:
	blk.l	1024,0
SSSTACK:

	section	screens,DATA_C

IMAGE:
	ds.b	10240*4
	;incbin	"work:kazzate/raw/mountain.raw"

IM1:	;incbin	"work:kazzate/raw/tch7.1.exe"
IM2:	;incbin	"work:kazzate/raw/tch7.2.raw"
	ds.b	10240*4
		blk.b	40*10*4,0

FACESCREEN:	blk.b	40*256,0

SCREEN1:	blk.b	40*4*256,0
SCREEN2:	blk.b	40*4*256,0

