;************************************************
;*                GLENZVECTORS  24 FACES        *
;*                   v2.0                       *
;*                                              *
;*  Coder: EXECUTOR                             *
;************************************************
;se si usano piu' oggetti, ricordarsi di inserire il loro indirizzo
;nella routine per calcolare gli offsets interni dei vettori

	Section	glenz,code_C

;*****************
;*   Constants   *
;*****************

OldOpenLibrary	= -408
CloseLibrary	= -414

DMASET=	%1000010111000000
;	 -----a-bcdefghij

;	a: Blitter Nasty
;	b: Bitplane DMA (if this isn't set, sprites disappear!)
;	c: Copper DMA
;	d: Blitter DMA
;	e: Sprite DMA
;	f: Disk DMA
;	g-j: Audio 3-0 DMA

	

START:
	MOVEM.L	D0-D7/A0-A6,-(A7)	; Put registers on stack
	BSR.B	DEMOIRQ			; demo irq
        bsr.w	clearscreen68000
	BSR.W	MAKELINEPOINTS
	bsr.w	objadd
	bsr.w	doubleset	
	bsr.w	movement		; to load right values in regs....
	
*******Here There is your code*********

;LOOP:

WAITbeam:
	bsr.w	WaitOF
	bsr.w	doubleset2
	bsr.w	doubleset
	bsr.w objcolors
	bsr.w movement
	bsr.w conversion
	bsr.w clearscreen
	bsr.w hidden
	bsr.w reconversion
	bsr.w line
	bsr.w gline
	bsr.w maxmin
	bsr.w fill
	bsr.w Gfade
	bsr.w transxyz
;	bsr waitblit
;	move.w #$0fff,$dff180
	btst #$06,$bfe001
	bne.b waitbeam
	

***************************************
END:

	BSR.W	SYSTEMIRQ		; system irq
	MOVEM.L	(A7)+,D0-D7/A0-A6	; Get registers from stack
	MOVEQ.L	#$00,d0
	RTS

;***********************************
;*   CLOSE ALL SYSTEM INTERRUPTS   *
;*                                 *
;*      START DEMO INTERRUPTS      *
;***********************************
DEMOIRQ:
	MOVE.L	$4.W,A6			; Exec pointer to A6
	LEA.L	GfxName(PC),A1		; Set library pointer
	MOVEQ	#0,D0
	JSR	OldOpenLibrary(A6)	; Open graphics.library
	MOVE.L	D0,A1			; Use Base-pointer
	MOVE.L	$26(A1),OLDCOP1		; Store copper1 start addr
	MOVE.L	$32(A1),OLDCOP2		; Store copper1 start addr
	JSR	CloseLibrary(A6)	; Close graphics library

	MOVE.W	$DFF01C,INTENA		; Store old INTENA
	MOVE.W	$DFF002,DMACON		; Store old DMACON
	MOVE.W	$DFF010,ADKCON		; Store old ADKCON

	MOVE.W	#$7FFF,$DFF09A		; Clear interrupt enable

	BSR.W	WAITOF

	MOVE.W	#$7FFF,$DFF096		; Clear DMA channels
	MOVE.L	#COPLIST,$DFF080	; Copper1 start address
	MOVE.W	#DMASET!$8200,$DFF096	; DMA kontrol data
	MOVE.L	$6C.W,OldIrq3		; Store old inter pointer
	MOVE.L	#IRQ3,$6C.W		; Set interrupt pointer

	MOVE.W	#$7FFF,$DFF09C		; Clear request
	MOVE.W	#$C020,$DFF09A		; Interrupt enable
	RTS
	
;*****************************************
;*					 *
;*   RESTORE SYSTEM INTERRUPTS ECT ECT   *
;*					 *
;*****************************************
SYSTEMIRQ:
	MOVE.W	#$7FFF,$DFF09A		; Disable interrupts

	BSR.W	WAITOF

	MOVE.W	#$7FFF,$DFF096
	MOVE.L	OldCop1(PC),$DFF080	; Restore old copper1
	MOVE.L	OldCop2(PC),$DFF084	; Restore old copper1
	MOVE.L	OldIrq3(PC),$6C.W	; Restore inter pointer
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
	RTS
	
;*** DATA AREA ***

GfxName		DC.B	'graphics.library',0
		even
OldIrq3		DC.L	0
OldCop1		DC.L	0
OldCop2		DC.L	0
INTENA		DC.W	0
DMACON		DC.W	0
ADKCON		DC.W	0

;**********************************
;*				  *
;*    INTERRUPT ROUTINE. LEVEL 3  *
;*				  *
;**********************************

IRQ3:
	MOVEM.L	D0-D7/A0-A6,-(A7)	; Put registers on stack

	MOVE.W	#$4020,$DFF09C		; Clear interrupt request
	MOVEM.L	(A7)+,D0-D7/A0-A6	; Get registers from stack
	RTE

;**********************************
WAITOF:	move.l	$dff004,d2		;Wait the start of the vertirq
	and.l	#$0001ff00,d2		;and the start of the video scan
	cmp.l	#$00011c00,d2
	bge.b	WAITOFE
	bra.b	WAITOF
WAITOFE:
	rts
;**********************************
	
*********************************************
;           3D  ROUTINES
*********************************************


waitblit:
	btst #$0e,$dff002
	bne.s waitblit
	rts

bltadat = $074
bltbdat = $072
bltcdat = $070
bltApth = $050
bltAptl = $052
bltBpth = $04c
bltBptl = $04e
bltCpth = $048
bltCptl = $04a
bltDpth = $054
bltDptl = $056
bltAmod = $064
bltBmod = $062
bltCmod = $060
bltDmod = $066
bltcon0 = $040
bltcon1 = $042
bltsize = $058
bltAmk1 = $044
bltAmk2 = $046


screen:	dc.l $70000,$75700
; SCHERMI ALLOCATI A $70000 e $77800

MAKELINEPOINTS:
sl2:	moveq #00,d0
	lea yposmat,a1
yposloop:
	move.l #$0000,a0
	move.l d0,d1
	mulu #84,d1
	add.l d1,a0
	move.l a0,(a1)+
	addq.w #$01,d0
	cmp.w #639,d0
	bne.s yposloop

	moveq #$00,d1
	lea xposmat,a0
xloop:	move.w d1,d0
	clr.w d2
	move.w #$0b5a,d3
	ror.w #$4,d0
	lsl.b #$1,d0
	move.b d0,d2
	add.w d2,(a0)+
	and.w #$f000,d0
	add.w d0,d3
	move.w d3,(a0)+
	addq.w #$01,d1
	cmp.w #799,d1
	bne.s xloop
	rts
	
clearscreen68000:
	clr.l $0
	lea $70000,a1
	move.w #$3fff,d0
clearloop:
	clr.l (a1)+
	dbf d0,clearloop
	rts
	

SCRIPTEFX:
	dc.l startcoords,modify,defineobj,fadepalette,transform
	
MOVEMENT:
	tst.w	efxcounter
	bne.s	movement2
	bra.W	scriptreader
movement2:
	subq.w	#1,efxcounter
	lea.l	OBJPOS,a0

	lea	xadd,a1
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
rot1:	tst.w	(a0)
	bpl.s	rot12
	add.w	#360,(a0)

rot12:	add.w	d4,2(a0)
	cmp.w	#360,2(a0)
	blt.s	rot2
	sub.w	#360,2(a0)
rot2:	tst.w	2(a0)
	bpl.s	rot22
	add.w	#360,2(a0)

rot22:	add.w	d5,4(a0)
	cmp.w	#360,4(a0)
	blt.s	rot3
	sub.w	#360,4(a0)
rot3:	tst.w	4(a0)
	bpl.s	rot33
	add.w	#360,4(a0)

rot33:
	rts

SCRIPTREADER:
	move.l	scriptloc,a0
	cmp.w	#'Z',(a0)
	beq.B	scriptgoto
	lea	scriptefx,a1
	move.w	(a0),d0
	sub.w	#65,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a1
	move.l	(a1),a3
	jmp	(a3)
	bra.w	movement
	rts

SCRIPTGOTO:
	move.l	2(a0),scriptloc
	bra.b	scriptreader
	rts     

STARTCOORDS:
	addq.l	#2,a0
	lea.l	OBJPOS,a2
	move.w	6(a0),(a2)
	move.w	8(a0),2(a2)
	move.w	10(a0),4(a2)
	tst.w	(a0)
	beq.b	sc1
	move.w	(a0),6(a2)
sc1:	tst.w	2(a0)
	beq.b	sc2
	move.w	2(a0),8(a2)
sc2:	tst.w	4(a0)
	beq.b	sc3
	move.w	4(a0),10(a2)
sc3:	add.l	#12,a0 
	move.l	a0,scriptloc
	bra.b	scriptreader
	rts
MODIFY:
	addq.l	#2,a0
	lea	xadd,a2
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

DEFINEOBJ:
	move.w	2(a0),resmod
	move.w	4(a0),fadd
	move.l	6(a0),OBJCOORDS
	move.l	10(a0),OBJCOORDS+4
	move.l	14(a0),objcolor
	add.l	#18,a0
	move.l	a0,scriptloc
	bra.w	scriptreader
	rts

FADEPALETTE:
	move.l	2(a0),frompalette
	move.l	6(a0),topalette
	move.w	#16*4,FADETIME
	move.w	#03,FADETIME2
	add.l	#10,a0
	move.l	a0,scriptloc
	bra.w	scriptreader
	
GFADE:
	tst.w	FADETIME
	beq.b	GFADEXIT
	sub.w	#01,FADETIME
	tst.w	FADETIME2
	bne.b	GFADEXIT2
	move.w	#03,FADETIME2
	move.l	frompalette,a0
	move.l	topalette,a1
	move.w 	#8-1,d7
	bsr.b	GSFUMA
	bra.b	GFADEXIT
GFADEXIT2:
	sub.w	#01,FADETIME2
GFADEXIT:
	rts

GSFUMA:
	move.w	(a0),d0
	move.w	(a0),d1
	move.w	(a0),d2
	move.w	(a1),d3
	move.w	(a1),d4
	move.w	(a1),d5
	andi.w	#$0f00,d0
	lsr.w	#$08,d0
	andi.w	#$00f0,d1
	lsr.w	#$04,d1
	andi.w	#$000f,d2
	andi.w	#$0f00,d3
	lsr.w	#$08,d3
	andi.w	#$00f0,d4
	lsr.w	#$04,d4
	andi.w	#$000f,d5
	cmp.w	d0,d3
	beq.b	GCONT1
	blt.b	GCONT2
	subi.w	#$0001,d3
	bra.b	GCONT1

GCONT2:
	addi.w	#$0001,d3

GCONT1:
	cmp.w	d1,d4
	beq.b	GCONT3
	blt.b	GCONT4
	subi.w	#$0001,d4
	bra.b	GCONT3

GCONT4:
	addi.w	#$0001,d4

GCONT3:
	cmp.w	d2,d5
	beq.b	GCONT5
	blt.b	GCONT6
	subi.w	#$0001,d5
	bra.b	GCONT5

GCONT6:
	addi.w	#$0001,d5

GCONT5:
	lsl.w	#$08,d3
	lsl.w	#$04,d4
	add.w	d3,d5
	add.w	d4,d5
	move.w	d5,(a1)
	addq.l	#02,a0
	addq.l	#02,a1
	dbf	d7,GSFUMA
	rts

TRANSFORM:
	move.w	2(a0),STEP
	move.l	4(a0),STARTOBJ
	move.l	8(a0),ENDOBJ
	add.l	#12,a0
	move.l	a0,scriptloc
	move.w	#$ffff,TRANSFLAG
	move.w	#1,STEPX
	move.l	STARTOBJ,a0
	lea	COPYTABLE,a1
	move.w	#255,d7
TRSC:	move.l	(a0)+,(a1)+
	dbf	d7,TRSC
	bra.w	scriptreader
	
TRANSXYZ:
	tst.w	TRANSFLAG
	beq.w	TREX2
	move.l	STARTOBJ,a1
	move.l	ENDOBJ,a2
		
TRANSX:	move.w	(a1),d0
	cmp.w	#$7fff,d0
	beq.b	TRANSEXIT
	cmp.w	(a2),d0
	beq.b	TRANSY
	bgt.b	TX2
	addq.w	#1,d0
	bra.b	TRANSY
TX2:	subq.w	#1,d0

TRANSY:	move.w	4(a1),d1
	cmp.w	4(a2),d1
	beq.b	TRANSZ
	bgt.b	TY2
	addq.w	#1,d1
	bra.b	TRANSZ
TY2:	subq.w	#1,d1

TRANSZ:	move.w	8(a1),d2
	cmp.w	8(a2),d2
	beq.b	TRANSOFF
	bgt.b	TZ2
	addq.w	#1,d2
	bra.b	TRANSOFF
TZ2:	subq.w	#1,d2
	

TRANSOFF:
	move.w	d0,(a1)
	move.w	d1,4(a1)
	move.w	d2,8(a1)
	
	add.l	#14,a0
	add.l	#14,a1
	add.l	#14,a2
	bra.b	TRANSX
	
TRANSEXIT:
	add.w	#1,STEPX
	move.w	STEPX,d0
	cmp.w	STEP,d0
	bne.b	TREX2
	move.w	#$0000,TRANSFLAG
	
TREX2:
	rts
	

	


**********************************

scriptloc:	dc.l	funzinescript

efxcounter:	dc.w	0

xadd:		dc.w	0
yadd:		dc.w	0
zadd:		dc.w	0
rotxinc:	dc.w	0
rotyinc:	dc.w	0
rotzinc:	dc.w	0

frompalette:	dc.l	0
topalette:	dc.l	0
FADETIME:	dc.w	0
FADETIME2:	dc.w	0

STARTOBJ:	dc.l	0
ENDOBJ:		dc.l	0
STEP:		dc.w	0
STEPX:		dc.w	0
TRANSFLAG:	dc.w	0

**********************************


DOUBLESET:
	lea	pointers,a2
	move.l	screen+4,a1
	move.l	a1,d3
	move.w	d3,6(a2)
	swap	d3
	move.w	d3,2(a2)
	swap	d3
	add.l	#28,d3
	move.w	d3,14(a2)
	swap	d3
	move.w	d3,10(a2)
	swap	d3
	add.l	#28,d3
	move.w	d3,22(a2)
	swap	d3
	move.w	d3,18(a2)
	rts

DOUBLESET2:
	move.l	screen,a0
	move.l	screen+4,a1
	move.l	a0,screen+4
	move.l	a1,screen
	rts


OBJCOLORS:
	move.l	objcolor,a0
	lea	colors,a1
	move.w	2(a0),2(a1)
	move.w	4(a0),6(a1)
	move.w	6(a0),10(a1)
	move.w	8(a0),14(a1)
	move.w	10(a0),18(a1)
	move.w	12(a0),22(a1)
	move.w	14(a0),26(a1)
	rts


objcolor:       dc.l glenzpalette


**********************************
HIDDEN:
;   a4  ftable    a5  3dcoords

	lea.l	OBJTABLE1,a5
	move.l	OBJCOORDS+4,a4
	
hiddenloop:
	move.l	(a4)+,a0
	cmp.l	#$ffffffff,a0
	beq.s	hiddenloopend
	move.l	(a0),a0
	move.l	a5,a1
	bsr.b	signtest
	bra.b	hiddenloop
hiddenloopend:
	rts

*****************
*** Sichttest ***
*****************
;a0   coordstable
;a1   coords

SIGNTEST:
	movem.l	a4/a5,-(a7)
	move.w	6(a0),d7
	lsl.w	#3,d7
	move.w	(a1,d7.w),d0
	move.w	2(a1,d7.w),d1
	move.w	4(a1,d7.w),d2
	asr.w	#1,d0
	asr.w	#1,d1
	asr.w	#1,d2
	move.w	d0,a3
	move.w	d1,a4
	move.w	d2,a5
	move.w	2+6(a0),d7
	lsl.w	#3,d7
	move.w	(a1,d7.w),d0
	move.w	2(a1,d7.w),d1
	move.w	4(a1,d7.w),d2
	asr.w	#1,d0
	asr.w	#1,d1
	asr.w	#1,d2
	move.w	4+6(a0),d7
	lsl.w	#3,d7
	move.w	(a1,d7.w),d3
	move.w	2(a1,d7.w),d4
	move.w	4(a1,d7.w),d5
	asr.w	#1,d3
	asr.w	#1,d4
	asr.w	#1,d5
	sub.w	a3,d0	;v
	sub.w	a4,d1
	sub.w	a5,d2
	sub.w	a3,d3	;w
	sub.w	a4,d4
	sub.w	a5,d5
	move.w	d0,vx+2
	move.w	d0,vx2+2
	move.w	d1,vy+2
	move.w	d1,vy2+2
	move.w	d2,vz+2
	move.w	d2,vz2+2
	move.w	d3,d0
	move.w	d4,d1
	move.w	d5,d2
vy:
	muls	#0,d5
vz:
	muls	#0,d1
	sub.w	d1,d5
			;x
vz2:
	muls	#0,d3
vx:
	muls	#0,d2
	sub.w	d2,d3
			;y
vx2:
	muls	#0,d4
vy2:
	muls	#0,d0
	sub.w	d0,d4
			;z
	move.w	a3,d0
	move.w	a4,d1
	move.w	a5,d2

	muls	d0,d5
	muls	d1,d3
	muls	d2,d4
	add.l	d3,d4
	add.l	d4,d5
	tst.l	d5
	bge.s	unsign
signok:
	move.w	#0,(a0)
	bra.s	signend
unsign:
	move.w	#1,(a0)
signend:
	movem.l	(a7)+,a4/a5
	rts


*************************************************

CONVERSION:
	lea	OBJCOORDS,a5
	lea	OBJTABLE1,a6

	move.l	(a5),a5
	lea	OBJPOS,a0
	lea	matsin,a1

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
	

convloop:
	move.w	(a5),d1
	asl.w	#2,d1
	move.w	4(a5),d2
	asl.w	#2,d2
	move.w	8(a5),d3
	asl.w	#2,d3
	add.l	#14,a5

rotxz:	tst.w	(a0)
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

rotxy:	tst.w	2(a0)
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

rotyz:	tst.w	4(a0)
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
	add.w	objpos+10,d3
	movem.w	d1-d3,(a6)
	addq.l	#8,a6
	cmp.w	#$7fff,(a5)
	bne.w	convloop
	move.w	#$7fff,(a6)
	
	rts

RECONVERSION:
	move.l	#$00001000,ymax
	move.l	#$00001000,xmax
	lea	OBJTABLE1,a0
	lea	OBJPOS,a3
	lea	OBJTABLE2,a5
	move.w	6(a3),d6
	move.w	8(a3),d7
	
reconvloop:
	move.w	(a0),d1
	move.w	2(a0),d2
	move.w	4(a0),d3

	ext.l	d1
	ext.l	d2
	ext.l	d3
	asl.l	#8,d1
	asl.l	#8,d2
	divs	d3,d1
	divs	d3,d2		
	add.w	d6,d1
	add.w	d7,d2

dpointsloop:
	move.w	d1,(a5)+
	move.w	d2,(a5)+

	cmp.w	ymax,d2
	ble.s	ymax1
	move.w	d2,ymax
ymax1:	cmp.w	ymin,d2
	bge.s	ymin1
	move.w	d2,ymin
ymin1:
	cmp.w	xmax,d1
	ble.s	xmax1
	move.w	d1,xmax
xmax1:	cmp.w	xmin,d1
	bge.s	xmin1
	move.w	d1,xmin
xmin1:
	add.w	#8,a0	
	cmp.w	#$7fff,(a0)
	bne.b	reconvloop
	rts

ymax:   dc.w 0
ymin:   dc.w 0
xmax:   dc.w 0
xmin:   dc.w 0

resmod:
	dc.w 84
fadd:
	dc.w 0 
maxmin:
	move.l	startingloc,startingloc2
	move.l	modulo,modulo2
	move.l	blitsize,blitsize2
	move.l	#00,a0
	lea	yposmat,a1
	lea	xposmat,a2
	move.w	ymax,d1
	cmp.w	#256,d1
	ble.s	maxmin2
	move.w	#256,d1
maxmin2:
	move.w	xmax,d2
	lsl.w	#2,d1
	lsl.w	#2,d2
	add.w	2(a1,d1.w),a0
	add.w	(a2,d2.w),a0
	move.w	ymax,d1
	move.w	ymin,d0
	cmp.w	#0,d0
	bge.s	maxmin3
	move.w	#0,d0
maxmin3:
	sub.w	d0,d1		;blitsizey
	addq.w	#2,d1
	move.w	d1,d6
	add.w	d6,d1
	add.w	d6,d1
	
maxmin4:
	lsl.w	#6,d1
	move.w	xmax,d2
	sub.w	xmin,d2
	lsr.w	#4,d2     
	addq.w	#2,d2
	add.w	d2,d1
	lsl.w	#1,d2
	move.w	resmod,d3
	sub.w	d2,d3
	move.w	d3,modulo
	move.w	d1,blitsize
	add.w	fadd,a0
	move.l	a0,startingloc
	clr.w	startingloc
	rts

blitsize:	dc.w $41
modulo:		dc.w $0
startingloc:	dc.l 0
blitsize2:	dc.w $41
modulo2:	dc.w $0
startingloc2:	dc.l 0
	        


line:   
        move.l	OBJCOORDS+4,a5

line2:	bsr.w	waitblit
	lea	$dff000,a0
	move.w	#84,bltcmod(a0)
	move.w	#84,bltdmod(a0)
	move.l	screen,bltcpth(a0)
	move.l	screen,bltdpth(a0)
	move.l	#$ffffffff,bltamk1(a0) 
	move.w	#$8000,bltadat(a0)
	move.w	#$ffff,bltbdat(a0)

;parametri fissi della line
;determino l'indirizzo (word dove inizia la linea)
;e lo shift

	lea	OBJTABLE2,a1
	lea	yposmat,a3  
	lea	xposmat,a4

al2:	move.l	(a5)+,a6
	cmp.l	#$ffffffff,a6
	beq.b	ll2cont

	move.l	(a6),a2
	move.w	(a2),d6
	tst.w	d6
	bne.b	al2

ll2:	move.l	(a6)+,a2
	cmp.l	#$ffffffff,a2
	beq.b	al2

	move.w	(a2)+,d6
	bra.s	ll4
ll2cont:
	rts
ll4:	move.w	(a2)+,d7
	subq.w	#2,d7
	
	move.w	(a2)+,color
	movem.l	a5/a6,-(a7)
lineloop:
	move.w	(a2)+,d6
	lsl.w	#2,d6
	move.w	(a1,d6.w),d1
	move.w	2(a1,d6.w),d3
	move.w	(a2),d6
	lsl.w	#2,d6
	move.w	(a1,d6.w),d2
	move.w	2(a1,d6.w),d4
	cmp.w	d3,d4
	ble.s	linefinal
	exg	d3,d4
	exg	d1,d2
linefinal:
	add.w	d3,d3
	add.w	d3,d3
	add.w	d1,d1
	add.w	d1,d1

	move.w	d1,d0
	move.l	screen(pc),a5
	add.l	(a3,d3.w),a5
	add.w	(a4,d1.w),a5
	lsr.w	#2,d3
	lsr.w	#2,d1

	sub.w	d3,d4;y lenght
	bpl.s	octchoose1
	neg.w	d4
	sub.w	d1,d2;xlenght
	bpl.s	octchoose2
	neg.w	d2
	cmp.w	d4,d2
	bpl.s	octchoose3
	moveq	#77-64+2,d6
	bra.s	octchoosend
octchoose1:
	sub.w	d1,d2;xlenght
	bpl.s	octchoose4
	neg.w	d2
	cmp.w	d4,d2
	bpl.s	octchoose5
	moveq	#73-64+2,d6
	bra.s	octchoosend
octchoose2:
	cmp.w	d4,d2
	bpl.s	octchoose7
	moveq	#69-64+2,d6
	bra.s	octchoosend
octchoose4:
	cmp.w	d4,d2
	bpl.s	octchoose6
	moveq	#65-64+2,d6
	bra.s	octchoosend
octchoose3:
	moveq	#93-64+2,d6
	bra.s	octchoosend1
octchoose5:
	moveq   #85-64+2,d6
	bra.s	octchoosend1
octchoose6:
	moveq	#81-64+2,d6
	bra.s	octchoosend1
octchoose7:
	moveq	#89-64+2,d6
	bra.s	octchoosend1
octchoosend:
	exg	d2,d4
octchoosend1:
	move.w	d4,d5
; 2*y - x
	sub.w	d2,d5
	move.w	d5,d3    ;(d3 = y-x)
	add.w	d4,d5
	add.w	d5,d5
; 4(y-x)
	add.w	d3,d3
	add.w	d3,d3
	bpl.b	sign
	bset	#6,d6
; 4*y
sign:
	add.w	d4,d4
	add.w	d4,d4

;size
	addq.w	#$01,d2
	lsl.w	#$06,d2
	or.w	#$2,d2

	move.l	a5,a6
	move.w	2(a4,d0.w),d1
	and.w	#$f000,d1
	rol.w	#4,d1
	neg.w	d1
	add.w	#15,d1
	bclr	#3,d1
	bne.s	corr
	addq.w	#1,a6
corr:
	btst	#$00,color+1
	beq.s	cc0
awline:
	btst	#$0e,2(a0)
	bne.s	awline

	bchg	d1,(a6)
	move.w	d3,bltamod(a0);4(y-x)
	move.w	d6,bltcon1(a0);octant
	move.w	d4,bltbmod(a0);4y
	move.w	d5,bltaptl(a0);2y-x
	move.w	a5,bltcptl(a0)
	move.w	a5,bltdptl(a0)
	move.w	2(a4,d0.w),bltcon0(a0)
	move.w	d2,bltsize(a0);xlenght
	bra	cc1
cc0:    
	lea	28(a5),a5
	
	btst	#$01,color+1
	beq.s	cc1
bwline:
	btst	#$0e,2(a0)
	bne.s	bwline
	bchg	d1,28(a6)
	move.w	d3,bltamod(a0);4(y-x)
	move.w	d6,bltcon1(a0);octant
	move.w	d4,bltbmod(a0);4y
	move.w	d5,bltaptl(a0);2y-x
	move.w	a5,bltcptl(a0)
	move.w	a5,bltdptl(a0)
	move.w	2(a4,d0.w),bltcon0(a0)
	move.w	d2,bltsize(a0);xlenght

cc1:
	dbf	d7,lineloop
	movem.l	(a7)+,a5/a6
	bra.w	ll2	



linend:	rts
color:	dc.w 0

fill:
	bsr.w	waitblit
	lea	$dff000,a0
	move.l	#$ffffffff,bltamk1(a0)
	move.l	#$09f00012,bltcon0(a0)
	move.l	screen,a1
	add.l	startingloc,a1
	move.l	a1,bltapth(a0)
	move.l	a1,bltdpth(a0)
	move.w	modulo,bltamod(a0)
	move.w	modulo,bltdmod(a0)
	move.w	blitsize,bltsize(a0)
	rts

clearscreen:
	bsr.w	waitblit
	lea	$dff000,a0
	move.l	#$01000002,bltcon0(a0)
	move.l	screen,a1
	add.l	startingloc2,a1
	move.l	a1,bltdpth(a0)
	move.w	modulo2,bltdmod(a0)
	move.w	blitsize2,d0
	move.w	d0,bltsize(a0)
	rts

*********************************************************
Gline:   
	move.l	OBJCOORDS+4,a5
	
Gline2:	bsr.w	waitblit
	lea	$dff000,a0
	move.w	#84,bltcmod(a0)
	move.w	#84,bltdmod(a0)
	move.l	screen,bltcpth(a0)
	move.l	screen,bltdpth(a0)
	move.l	#$ffffffff,bltamk1(a0) 
	move.w	#$8000,bltadat(a0)
	move.w	#$ffff,bltbdat(a0)

;parametri fissi della line
;determino l'indirizzo (word dove inizia la linea)
;e lo shift

	lea	OBJTABLE2,a1
	lea	yposmat,a3  
	lea	xposmat,a4

Gal2:	move.l	(a5)+,a6
	cmp.l	#$ffffffff,a6
	beq.b	Gll2cont

	move.l	(a6),a2
	move.w	(a2),d6
	tst.w	d6
	beq.b	Gal2

Gll2:	move.l	(a6)+,a2
	cmp.l	#$ffffffff,a2
	beq.b	Gal2

	move.w	(a2)+,d6
	bra.s	Gll4
Gll2cont:
	rts
Gll4:	move.w	(a2)+,d7
	subq.w	#2,d7
	
	move.w	(a2)+,Gcolor
	btst	#$00,Gcolor+1
	beq.s	Gll2

	movem.l	a5/a6,-(a7)
Glineloop:
	move.w	(a2)+,d6
	lsl.w	#2,d6
	move.w	(a1,d6.w),d1
	move.w	2(a1,d6.w),d3
	move.w	(a2),d6
	lsl.w	#2,d6
	move.w	(a1,d6.w),d2
	move.w	2(a1,d6.w),d4
	cmp.w	d3,d4
	ble.s	Glinefinal
	exg	d3,d4
	exg	d1,d2
Glinefinal:
	add.w	d3,d3
	add.w	d3,d3
	add.w	d1,d1
	add.w	d1,d1

	move.w	d1,d0
	move.l	screen(pc),a5
	add.l	(a3,d3.w),a5
	add.w	(a4,d1.w),a5
	lsr.w	#2,d3
	lsr.w	#2,d1

	sub.w	d3,d4;y lenght
	bpl.s	Goctchoose1
	neg.w	d4
	sub.w	d1,d2;xlenght
	bpl.w	Goctchoose2
	neg.w	d2
	cmp.w	d4,d2
	bpl.s	Goctchoose3
	moveq	#77-64+2,d6
	bra.s	Goctchoosend
Goctchoose1:
	sub.w	d1,d2;xlenght
	bpl.s	Goctchoose4
	neg.w	d2
	cmp.w	d4,d2
	bpl.s	Goctchoose5
	moveq	#73-64+2,d6
	bra.s	Goctchoosend
Goctchoose2:
	cmp.w	d4,d2
	bpl.s	Goctchoose7
	moveq	#69-64+2,d6
	bra.s	Goctchoosend
Goctchoose4:
	cmp.w	d4,d2
	bpl.s	Goctchoose6
	moveq	#65-64+2,d6
	bra.s	Goctchoosend
Goctchoose3:
	moveq	#93-64+2,d6
	bra.s	Goctchoosend1
Goctchoose5:
	moveq	#85-64+2,d6
	bra.s	Goctchoosend1
Goctchoose6:
	moveq	#81-64+2,d6
	bra.s	Goctchoosend1
Goctchoose7:
	moveq	#89-64+2,d6
	bra.s	Goctchoosend1
Goctchoosend:
	exg	d2,d4
Goctchoosend1:
	move.w	d4,d5
; 2*y - x
	sub.w	d2,d5
	move.w	d5,d3    ;(d3 = y-x)
	add.w	d4,d5
	add.w	d5,d5
; 4(y-x)
	add.w	d3,d3
	add.w	d3,d3
	bpl.s	Gsign
	bset	#6,d6
; 4*y
Gsign:
	add.w	d4,d4
	add.w	d4,d4

;size
	addq.w	#$01,d2
	lsl.w	#$06,d2
	or.w	#$2,d2

	move.l	a5,a6
	move.w	2(a4,d0.w),d1
	and.w	#$f000,d1
	rol.w	#4,d1
	neg.w	d1
	add.w	#15,d1
	bclr	#3,d1
	bne.s	Gcorr
	addq.w	#1,a6
Gcorr:
	lea	56(a5),a5
Gawline:
	btst	#$0e,2(a0)
	bne.s	Gawline

	bchg	d1,56(a6)
	move.w	d3,bltamod(a0);4(y-x)
	move.w	d6,bltcon1(a0);octant
	move.w	d4,bltbmod(a0);4y
	move.w	d5,bltaptl(a0);2y-x
	move.w	a5,bltcptl(a0)
	move.w	a5,bltdptl(a0)
	move.w	2(a4,d0.w),bltcon0(a0)
	move.w	d2,bltsize(a0);xlenght
Gcc0:    
	dbf	d7,Glineloop
	movem.l	(a7)+,a5/a6
	bra.w	Gll2	


Glinend: rts
Gcolor:  dc.w 0

*********************************************************
;This routine adds the Lableadresses to all 
;adresses in the objects.
;Insert the Load-Lables after -objectsaddtable-!!!

Objectsaddtable:
	dc.l	GLENZ0DATA
	dc.l	GLENZ1DATA
	dc.l	GLENZ2DATA
	dc.l	GLENZ3DATA
	dc.l	GLENZ4DATA
	dc.l	$ffffffff

objadd:
	lea	objectsaddtable(pc),a0
objadd1:
	move.l	(a0)+,d0
	cmp.l	#$ffffffff,d0
	beq.s	objaddend
	lea	1024,a2			
	add.l	d0,a2
objadd2:
	cmp.l	#$ffffffff,(a2)+
	beq.s	objadd1
	add.l	d0,-4(a2)
	move.l	-4(a2),a3
objadd3:
	cmp.l	#$ffffffff,(a3)+
	beq.s	objadd2
	add.l	d0,-4(a3)	
	bra.b	objadd3
objaddend:
	rts


******************************************************************************
*                                END OF CODE                                 *
******************************************************************************


;OBJECT DATA STRUCTURE------------------------------------------------

	
OBJCOORDS:
	dc.l	GLENZ1DATA,GLENZ1DATA+1024
;	questi sono gli indirizzi dell'oggetto

OBJPOS:
	dc.w	100,50,100		;xrot,yrot,zrot
	dc.w	160,100,-200		;xpos,ypos,zpos
	dc.w	0,0,0
	dc.w	0,0,0
	
OBJTABLE1:
	dcb.b	1024,0
OBJTABLE2:
	dcb.b	1024,0
COPYTABLE:
	dcb.b	1024,0

GLENZ0DATA:

	dc.w	-2,0,$1E,0,-30,0,0,$1E
	dc.w	0,$1E,0,-30,0,0,$1E,0
	dc.w	-30,0,-30,0,0,-30,0,-30
	dc.w	0,-30,0,0,0,0,0,0
	dc.w	-60,0,0,-30,0,$1E,0,$1E
	dc.w	0,0,$1E,0,$1E,0,$1E,0
	dc.w	0,$1E,0,-30,0,$1E,0,0
	dc.w	-30,0,-30,0,$1E,0,0,-60
	dc.w	0,0,0,0,0,0,0,0
	dc.w	$3C,0,0,0,0,$3C,0,0
	dc.w	0,0,0,0,0,0,-60,0
	dc.w	0,0,0,0,0,0,0,$3C
	dc.w	0,0,$7FFF,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,$4F4,0,$4FC,0,$504,0,$50C
	dc.w	0,$514,0,$51C,0,$524,0,$52C
	dc.w	0,$534,0,$53C,0,$544,0,$54C
	dc.w	0,$554,0,$55C,0,$564,0,$56C
	dc.w	0,$574,0,$57C,0,$584,0,$58C
	dc.w	0,$594,0,$59C,0,$5A4,0,$5AC
	dc.w	-1,-1,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,$5B4,-1,-1,0,$5C2
	dc.w	-1,-1,0,$5D0,-1,-1,0,$5DE
	dc.w	-1,-1,0,$5EC,-1,-1,0,$5FA
	dc.w	-1,-1,0,$608,-1,-1,0,$616
	dc.w	-1,-1,0,$624,-1,-1,0,$632
	dc.w	-1,-1,0,$640,-1,-1,0,$64E
	dc.w	-1,-1,0,$65C,-1,-1,0,$66A
	dc.w	-1,-1,0,$678,-1,-1,0,$686
	dc.w	-1,-1,0,$694,-1,-1,0,$6A2
	dc.w	-1,-1,0,$6B0,-1,-1,0,$6BE
	dc.w	-1,-1,0,$6CC,-1,-1,0,$6DA
	dc.w	-1,-1,0,$6E8,-1,-1,0,$6F6
	dc.w	-1,-1,0,$4,$2,0,$1,$4
	dc.w	0,0,$4,$3,$1,$2,$4,$1
	dc.w	0,$4,$2,$2,$3,$4,$2,0
	dc.w	$4,$3,$3,0,$4,$3,0,$4
	dc.w	$3,$1,$6,$B,$1,0,$4,$2
	dc.w	$6,$7,$B,$6,0,$4,$3,$7
	dc.w	$2,$B,$7,0,$4,$2,$6,$5
	dc.w	$D,$6,0,$4,$3,$5,$8,$D
	dc.w	$5,0,$4,$2,$8,$7,$D,$8
	dc.w	0,$4,$3,$6,$D,$7,$6,0
	dc.w	$4,$3,$5,0,$9,$5,0,$4
	dc.w	$2,0,$3,$9,0,0,$4,$3
	dc.w	$3,$8,$9,$3,0,$4,$2,$5
	dc.w	$9,$8,$5,0,$4,$3,$6,$A
	dc.w	$5,$6,0,$4,$2,$6,$1,$A
	dc.w	$6,0,$4,$3,$1,0,$A,$1
	dc.w	0,$4,$2,0,$5,$A,0,0
	dc.w	$4,$3,$8,$C,$7,$8,0,$4
	dc.w	$2,$8,$3,$C,$8,0,$4,$3
	dc.w	$3,$2,$C,$3,0,$4,$2,$2
	dc.w	$7,$C,$2,0,$4,$2,$1,$B
	dc.w	$2,$1

GLENZ1DATA:

	dc.w	-60,0,$3C,0,-60,0,0,$3C
	dc.w	0,$3C,0,-60,0,0,$3C,0
	dc.w	-60,0,-60,0,0,-60,0,-60
	dc.w	0,-60,0,0,0,0,0,0
	dc.w	-60,0,0,-60,0,$3C,0,$3C
	dc.w	0,0,$3C,0,$3C,0,$3C,0
	dc.w	0,$3C,0,-60,0,$3C,0,0
	dc.w	-60,0,-60,0,$3C,0,0,-60
	dc.w	0,0,0,0,0,0,0,0
	dc.w	$3C,0,0,0,0,$3C,0,0
	dc.w	0,0,0,0,0,0,-60,0
	dc.w	0,0,0,0,0,0,0,$3C
	dc.w	0,0,$7FFF,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,$4F4,0,$4FC,0,$504,0,$50C
	dc.w	0,$514,0,$51C,0,$524,0,$52C
	dc.w	0,$534,0,$53C,0,$544,0,$54C
	dc.w	0,$554,0,$55C,0,$564,0,$56C
	dc.w	0,$574,0,$57C,0,$584,0,$58C
	dc.w	0,$594,0,$59C,0,$5A4,0,$5AC
	dc.w	-1,-1,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,$5B4,-1,-1,0,$5C2
	dc.w	-1,-1,0,$5D0,-1,-1,0,$5DE
	dc.w	-1,-1,0,$5EC,-1,-1,0,$5FA
	dc.w	-1,-1,0,$608,-1,-1,0,$616
	dc.w	-1,-1,0,$624,-1,-1,0,$632
	dc.w	-1,-1,0,$640,-1,-1,0,$64E
	dc.w	-1,-1,0,$65C,-1,-1,0,$66A
	dc.w	-1,-1,0,$678,-1,-1,0,$686
	dc.w	-1,-1,0,$694,-1,-1,0,$6A2
	dc.w	-1,-1,0,$6B0,-1,-1,0,$6BE
	dc.w	-1,-1,0,$6CC,-1,-1,0,$6DA
	dc.w	-1,-1,0,$6E8,-1,-1,0,$6F6
	dc.w	-1,-1,0,$4,$2,0,$1,$4
	dc.w	0,0,$4,$3,$1,$2,$4,$1
	dc.w	0,$4,$2,$2,$3,$4,$2,0
	dc.w	$4,$3,$3,0,$4,$3,0,$4
	dc.w	$3,$1,$6,$B,$1,0,$4,$2
	dc.w	$6,$7,$B,$6,0,$4,$3,$7
	dc.w	$2,$B,$7,0,$4,$2,$6,$5
	dc.w	$D,$6,0,$4,$3,$5,$8,$D
	dc.w	$5,0,$4,$2,$8,$7,$D,$8
	dc.w	0,$4,$3,$6,$D,$7,$6,0
	dc.w	$4,$3,$5,0,$9,$5,0,$4
	dc.w	$2,0,$3,$9,0,0,$4,$3
	dc.w	$3,$8,$9,$3,0,$4,$2,$5
	dc.w	$9,$8,$5,0,$4,$3,$6,$A
	dc.w	$5,$6,0,$4,$2,$6,$1,$A
	dc.w	$6,0,$4,$3,$1,0,$A,$1
	dc.w	0,$4,$2,0,$5,$A,0,0
	dc.w	$4,$3,$8,$C,$7,$8,0,$4
	dc.w	$2,$8,$3,$C,$8,0,$4,$3
	dc.w	$3,$2,$C,$3,0,$4,$2,$2
	dc.w	$7,$C,$2,0,$4,$2,$1,$B
	dc.w	$2,$1

GLENZ2DATA:

	dc.w	-10,0,$A,0,-10,0,0,$A
	dc.w	0,$A,0,-10,0,0,$A,0
	dc.w	-10,0,-10,0,0,-10,0,-10
	dc.w	0,-10,0,0,0,0,0,0
	dc.w	-60,0,0,-10,0,$A,0,$A
	dc.w	0,0,$A,0,$A,0,$A,0
	dc.w	0,$A,0,-10,0,$A,0,0
	dc.w	-10,0,-10,0,$A,0,0,-10
	dc.w	0,0,0,0,0,0,0,0
	dc.w	$A,0,0,0,0,$A,0,0
	dc.w	0,0,0,0,0,0,-10,0
	dc.w	0,0,0,0,0,0,0,$3C
	dc.w	0,0,$7FFF,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,$4F4,0,$4FC,0,$504,0,$50C
	dc.w	0,$514,0,$51C,0,$524,0,$52C
	dc.w	0,$534,0,$53C,0,$544,0,$54C
	dc.w	0,$554,0,$55C,0,$564,0,$56C
	dc.w	0,$574,0,$57C,0,$584,0,$58C
	dc.w	0,$594,0,$59C,0,$5A4,0,$5AC
	dc.w	-1,-1,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,$5B4,-1,-1,0,$5C2
	dc.w	-1,-1,0,$5D0,-1,-1,0,$5DE
	dc.w	-1,-1,0,$5EC,-1,-1,0,$5FA
	dc.w	-1,-1,0,$608,-1,-1,0,$616
	dc.w	-1,-1,0,$624,-1,-1,0,$632
	dc.w	-1,-1,0,$640,-1,-1,0,$64E
	dc.w	-1,-1,0,$65C,-1,-1,0,$66A
	dc.w	-1,-1,0,$678,-1,-1,0,$686
	dc.w	-1,-1,0,$694,-1,-1,0,$6A2
	dc.w	-1,-1,0,$6B0,-1,-1,0,$6BE
	dc.w	-1,-1,0,$6CC,-1,-1,0,$6DA
	dc.w	-1,-1,0,$6E8,-1,-1,0,$6F6
	dc.w	-1,-1,0,$4,$2,0,$1,$4
	dc.w	0,0,$4,$3,$1,$2,$4,$1
	dc.w	0,$4,$2,$2,$3,$4,$2,0
	dc.w	$4,$3,$3,0,$4,$3,0,$4
	dc.w	$3,$1,$6,$B,$1,0,$4,$2
	dc.w	$6,$7,$B,$6,0,$4,$3,$7
	dc.w	$2,$B,$7,0,$4,$2,$6,$5
	dc.w	$D,$6,0,$4,$3,$5,$8,$D
	dc.w	$5,0,$4,$2,$8,$7,$D,$8
	dc.w	0,$4,$3,$6,$D,$7,$6,0
	dc.w	$4,$3,$5,0,$9,$5,0,$4
	dc.w	$2,0,$3,$9,0,0,$4,$3
	dc.w	$3,$8,$9,$3,0,$4,$2,$5
	dc.w	$9,$8,$5,0,$4,$3,$6,$A
	dc.w	$5,$6,0,$4,$2,$6,$1,$A
	dc.w	$6,0,$4,$3,$1,0,$A,$1
	dc.w	0,$4,$2,0,$5,$A,0,0
	dc.w	$4,$3,$8,$C,$7,$8,0,$4
	dc.w	$2,$8,$3,$C,$8,0,$4,$3
	dc.w	$3,$2,$C,$3,0,$4,$2,$2
	dc.w	$7,$C,$2,0,$4,$2,$1,$B
	dc.w	$2,$1

GLENZ3DATA:

	dc.w	-15,0,$F,0,0,0,0,$F
	dc.w	0,$F,0,0,0,0,$F,0
	dc.w	-15,0,0,0,0,-15,0,-15
	dc.w	0,0,0,0,0,0,0,0
	dc.w	-60,0,0,-30,0,$1E,0,$3C
	dc.w	0,0,$1E,0,$1E,0,$3C,0
	dc.w	0,$1E,0,-30,0,$3C,0,0
	dc.w	-30,0,-30,0,$3C,0,0,-19
	dc.w	0,0,0,$F,0,0,0,0
	dc.w	$13,0,$F,0,0,$13,0,0
	dc.w	0,$F,0,0,0,0,-19,0
	dc.w	$F,0,0,0,0,0,0,$3C
	dc.w	0,0,$7FFF,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,$4F4,0,$4FC,0,$504,0,$50C
	dc.w	0,$514,0,$51C,0,$524,0,$52C
	dc.w	0,$534,0,$53C,0,$544,0,$54C
	dc.w	0,$554,0,$55C,0,$564,0,$56C
	dc.w	0,$574,0,$57C,0,$584,0,$58C
	dc.w	0,$594,0,$59C,0,$5A4,0,$5AC
	dc.w	-1,-1,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,$5B4,-1,-1,0,$5C2
	dc.w	-1,-1,0,$5D0,-1,-1,0,$5DE
	dc.w	-1,-1,0,$5EC,-1,-1,0,$5FA
	dc.w	-1,-1,0,$608,-1,-1,0,$616
	dc.w	-1,-1,0,$624,-1,-1,0,$632
	dc.w	-1,-1,0,$640,-1,-1,0,$64E
	dc.w	-1,-1,0,$65C,-1,-1,0,$66A
	dc.w	-1,-1,0,$678,-1,-1,0,$686
	dc.w	-1,-1,0,$694,-1,-1,0,$6A2
	dc.w	-1,-1,0,$6B0,-1,-1,0,$6BE
	dc.w	-1,-1,0,$6CC,-1,-1,0,$6DA
	dc.w	-1,-1,0,$6E8,-1,-1,0,$6F6
	dc.w	-1,-1,0,$4,$2,0,$1,$4
	dc.w	0,0,$4,$3,$1,$2,$4,$1
	dc.w	0,$4,$2,$2,$3,$4,$2,0
	dc.w	$4,$3,$3,0,$4,$3,0,$4
	dc.w	$3,$1,$6,$B,$1,0,$4,$2
	dc.w	$6,$7,$B,$6,0,$4,$3,$7
	dc.w	$2,$B,$7,0,$4,$2,$6,$5
	dc.w	$D,$6,0,$4,$3,$5,$8,$D
	dc.w	$5,0,$4,$2,$8,$7,$D,$8
	dc.w	0,$4,$3,$6,$D,$7,$6,0
	dc.w	$4,$3,$5,0,$9,$5,0,$4
	dc.w	$2,0,$3,$9,0,0,$4,$3
	dc.w	$3,$8,$9,$3,0,$4,$2,$5
	dc.w	$9,$8,$5,0,$4,$3,$6,$A
	dc.w	$5,$6,0,$4,$2,$6,$1,$A
	dc.w	$6,0,$4,$3,$1,0,$A,$1
	dc.w	0,$4,$2,0,$5,$A,0,0
	dc.w	$4,$3,$8,$C,$7,$8,0,$4
	dc.w	$2,$8,$3,$C,$8,0,$4,$3
	dc.w	$3,$2,$C,$3,0,$4,$2,$2
	dc.w	$7,$C,$2,0,$4,$2,$1,$B
	dc.w	$2,$1

GLENZ4DATA:

	dc.w	-40,0,$28,0,-10,0,0,$28
	dc.w	0,$28,0,-10,0,0,$28,0
	dc.w	-60,0,-10,0,0,-40,0,-60
	dc.w	0,-10,0,0,0,0,0,0
	dc.w	-10,0,0,-40,0,$28,0,$A
	dc.w	0,0,$28,0,$28,0,$A,0
	dc.w	0,$28,0,-60,0,$A,0,0
	dc.w	-40,0,-60,0,$A,0,0,-60
	dc.w	0,-39,0,-3,0,0,0,0
	dc.w	$3C,0,0,0,0,$3C,0,-39
	dc.w	0,-3,0,0,0,0,-60,0
	dc.w	0,0,0,0,0,0,0,$A
	dc.w	0,0,$7FFF,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,$4F4,0,$4FC,0,$504,0,$50C
	dc.w	0,$514,0,$51C,0,$524,0,$52C
	dc.w	0,$534,0,$53C,0,$544,0,$54C
	dc.w	0,$554,0,$55C,0,$564,0,$56C
	dc.w	0,$574,0,$57C,0,$584,0,$58C
	dc.w	0,$594,0,$59C,0,$5A4,0,$5AC
	dc.w	-1,-1,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,$5B4,-1,-1,0,$5C2
	dc.w	-1,-1,0,$5D0,-1,-1,0,$5DE
	dc.w	-1,-1,0,$5EC,-1,-1,0,$5FA
	dc.w	-1,-1,0,$608,-1,-1,0,$616
	dc.w	-1,-1,0,$624,-1,-1,0,$632
	dc.w	-1,-1,0,$640,-1,-1,0,$64E
	dc.w	-1,-1,0,$65C,-1,-1,0,$66A
	dc.w	-1,-1,0,$678,-1,-1,0,$686
	dc.w	-1,-1,0,$694,-1,-1,0,$6A2
	dc.w	-1,-1,0,$6B0,-1,-1,0,$6BE
	dc.w	-1,-1,0,$6CC,-1,-1,0,$6DA
	dc.w	-1,-1,0,$6E8,-1,-1,0,$6F6
	dc.w	-1,-1,0,$4,$2,0,$1,$4
	dc.w	0,0,$4,$3,$1,$2,$4,$1
	dc.w	0,$4,$2,$2,$3,$4,$2,0
	dc.w	$4,$3,$3,0,$4,$3,0,$4
	dc.w	$3,$1,$6,$B,$1,0,$4,$2
	dc.w	$6,$7,$B,$6,0,$4,$3,$7
	dc.w	$2,$B,$7,0,$4,$2,$6,$5
	dc.w	$D,$6,0,$4,$3,$5,$8,$D
	dc.w	$5,0,$4,$2,$8,$7,$D,$8
	dc.w	0,$4,$3,$6,$D,$7,$6,0
	dc.w	$4,$3,$5,0,$9,$5,0,$4
	dc.w	$2,0,$3,$9,0,0,$4,$3
	dc.w	$3,$8,$9,$3,0,$4,$2,$5
	dc.w	$9,$8,$5,0,$4,$3,$6,$A
	dc.w	$5,$6,0,$4,$2,$6,$1,$A
	dc.w	$6,0,$4,$3,$1,0,$A,$1
	dc.w	0,$4,$2,0,$5,$A,0,0
	dc.w	$4,$3,$8,$C,$7,$8,0,$4
	dc.w	$2,$8,$3,$C,$8,0,$4,$3
	dc.w	$3,$2,$C,$3,0,$4,$2,$2
	dc.w	$7,$C,$2,0,$4,$2,$1,$B
	dc.w	$2,$1
	
;PALETTE DATAS-----------------------------------------------------------

GLENZPALETTE:	dc.w $000,$000,$000,$000,$000,$000,$000,$000

GLENZPALETTE0:	dc.w $000,$000,$000,$000,$000,$000,$000,$000
GLENZPALETTE1:	dc.w $000,$fff,$f00,$000,$000,$fee,$b00,$000
GLENZPALETTE2:	dc.w $000,$fff,$0f0,$000,$000,$fee,$0b0,$000
GLENZPALETTE3:	dc.w $000,$fff,$00f,$000,$000,$fee,$00b,$000
GLENZPALETTE4:	dc.w $000,$fff,$f0a,$000,$000,$fee,$b06,$000
GLENZPALETTE5:	dc.w $000,$fff,$0a0,$000,$000,$fee,$060,$000

;SCRIPTS DATAS-----------------------------------------------------------

;COMMANDS FOR THE SCRIPTS.........
;
; A (x,y,z,rotx,roty,rotz)		Set start coords of the vector
; B (x,y,z,rotx,roty,rotz,times)	Modify the vector's position
;					adding the values to their regs
; C (resmod,fadd,objpnts,objlns,pal)	Set a new vector
; D (frompalette,topalette)		Fade colors of vectors
; E (fromOBJ,toOBJ,step)		Transform an object into another
; Z (address)				Goto....


*********************************************
;       SCRIPT OF VECTOR'S MOVEMENTS
*********************************************

FUNZINESCRIPT:
	dc.w 'C',28,56
	DC.L GLENZ1DATA,GLENZ1DATA+1024,glenzpalette
	DC.W 'A',112,120,-6370,0,0,0
	dc.w 'D'
	dc.l glenzpalette1,glenzpalette
	DC.W 'B',0,0,29,2,0,0,180
	DC.W 'B',0,0,1,2,0,0,190
	dc.w 'B',0,0,0,2,0,0,100
	DC.W 'E',50
	dc.l glenz1data,glenz2data
	DC.W 'B',0,0,5,1,1,2,40
	dc.w 'B',0,0,1,1,1,2,30
	DC.W 'B',0,0,0,1,2,1,100
	DC.W 'B',0,0,0,2,1,0,100
	DC.W 'B',0,0,0,1,2,1,100
	DC.W 'B',0,0,0,1,1,2,100
	dc.w 'D'
	dc.l glenzpalette3,glenzpalette
	DC.W 'B',0,0,0,1,2,2,100
	DC.W 'B',0,0,0,1,1,1,200
	DC.W 'E',50
	dc.l glenz1data,glenz3data
	DC.W 'B',0,0,0,1,1,2,100
	DC.W 'B',0,0,0,1,2,1,100
	DC.W 'B',0,0,0,1,2,1,100
	dc.w 'D'
	dc.l glenzpalette4,glenzpalette
	DC.W 'B',0,0,0,1,1,1,100
	DC.W 'B',0,0,0,1,1,-1,100
	DC.W 'B',0,0,0,2,1,1,300
	dc.w 'D'
	dc.l glenzpalette5,glenzpalette
	DC.W 'B',0,0,0,1,2,-1,80
	DC.W 'B',0,0,0,1,2,1,80
	DC.W 'B',0,0,0,2,1,1,160
	DC.W 'E',50
	dc.l glenz1data,glenz4data
	DC.W 'B',0,0,0,2,0,0,4
	DC.W 'B',0,0,0,0,0,2,80
	dc.w 'D'
	dc.l glenzpalette3,glenzpalette
	DC.W 'B',0,0,0,2,0,0,80
	DC.W 'B',0,0,0,1,2,0,80
	DC.W 'B',0,0,0,2,0,0,280
	DC.W 'E',50
	dc.l glenz1data,glenz0data
	dc.w 'B',0,0,7,1,1,2,15
	dc.w 'B',0,0,0,1,1,1,260
	dc.w 'D'
	dc.l glenzpalette4,glenzpalette
	dc.w 'B',0,0,0,1,1,1,400
	dc.w 'B',0,0,0,1,1,1,300
	dc.w 'B',0,0,0,1,1,1,400
	dc.w 'D'
	dc.l glenzpalette0,glenzpalette
	DC.W 'B',0,0,0,1,1,2,140
	dc.w 'Z'
	dc.l FUNZINESCRIPT
	



******************************************************************************
*                        M A T H S     T A B L E S                           *
******************************************************************************

XPOSMAT:			;to speedup blitter operations......
	dcb.l 900,0
YPOSMAT:
	dcb.l 700,0

MATSIN:
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

******************************************************************************



	CNOP	0,4


;*****************************
;*			     *
;*      COPPER1 PROGRAM      *
;*			     *
;*****************************

COPLIST:
	dc.w	$104,$4
	dc.w	$100,$3200
	dc.w	$108,00056
	dc.w	$10a,00056
	dc.w	$92,$50
	dc.w	$94,$b8	
	dc.w	$8e,$34b1
	dc.w	$90,$1c91
	
pointers:
	dc.w $e0,$7
	dc.w $e2,0
	dc.w $e4,$7
	dc.w $e6,$28
	dc.w $e8,$7
	dc.w $ea,$50
	

colors:
	dc.w $182,$fff
	dc.w $184,$fff
	dc.w $186,$f00
	dc.w $188,0
	dc.w $18a,0
	dc.w $18c,$fee
	dc.w $18e,$b00
	
	dc.w $102,0
	dc.w $180,$6
	
	dc.w $3409,$fffe
	dc.w $180,$fff
	dc.w $3509,$fffe
	dc.w $180,0
	dc.w $ffdf,$fffe
	dc.w $1c09,$fffe
	dc.w $180,$fff
	dc.w $1d09,$fffe
	dc.w $180,$6
	dc.w $1fc,0,$106,0
	dc.w $ffff,$fffe

