	SECTION	"Robster - ADU Intro 2",CODE_C

AngleSkipX	= 1
AngleSkipY	= 1
AngleSkipZ	= 1
AngleValX	= 0
AngleValY	= 0
AngleValZ	= 0

PositionX	= 0
PositionY	= 0
PositionZ	= 400

;--------------------------------------;

WaitBlt	MACRO
	tst.b	2(a5)
WB\@	btst	#6,2(a5)
	bne.b	WB\@
	ENDM

WaitBm	MACRO
WB\@	move.b	6(a5),d0
	cmp.b	#\1,d0
	bne	WB\@
	ENDM

;--------------------------------------;

	move.l	4.w,a6
	moveq	#0,d0
	lea	GfxBase(pc),a1
	jsr	-552(a6)
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	34(a6),OldView
	sub.l	a1,a1
	jsr	-222(a6)
	jsr	-270(a6)
	jsr	-270(a6)
	jsr	-456(a6)
	lea	$dff000,a5
	WaitBlt
	move.l	4.w,a6
	jsr	-132(a6)

	move.w	$1c(a5),d0
	or.w	#$c000,d0
	move.w	d0,IntEna

	move.w	2(a5),d0
	or.w	#$8000,d0
	move.w	d0,DMACon

	lea	BPL1(pc),a0
	move.l	#Screen1,d0
	moveq	#1,d7
Pic2Cop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#140*(320/8),d0
	addq.l	#8,a0
	dbf	d7,Pic2Cop

	lea	BPL2(pc),a0
	move.l	#TxtArea,d0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.l	#RbSprte,d0
	lea	SPR1(pc),a0
	moveq	#2,d7
RobLoop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#44,d0
	addq.l	#8,a0
	dbf	d7,RobLoop

	move.l	#SBlank,d0
	lea	SPR2(pc),a0
	moveq	#4,d7
SPRLoop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	addq.l	#8,a0
	dbf	d7,SPRLoop

	move.l	#pr_data,pr_module
	bsr	pr_init
	bsr.w	GetVBR
	move.l	a4,pr_Vectorbasept
	lea	$dff000,a5
	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	$6c(a4),OldIRQ
	move.l	#NewIRQ,$6c(a4)
	move.w	#$e020,$9a(a5)

	move.w	#$7fff,$96(a5)
	move.l  #CList,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$83e0,$96(a5)

MousChk	btst	#6,$bfe001
	bne.b	MousChk

	bsr	pr_end
	lea	$dff000,a5
	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	OldIRQ(pc),$6c(a4)
	move.w	IntEna(pc),$9a(a5)

	WaitBlt
	move.l	GfxBase(pc),a6
	move.l	OldView(pc),a1
	jsr	-222(a6)
	move.w	#$7fff,$96(a5)
	move.l	38(a6),$80(a5)
	move.w	#$0000,$88(a5)
	move.w	DMACon(pc),$96(a5)
	move.l	a6,a1
	jsr	-462(a6)
	move.l	4.w,a6
	jsr	-414(a6)
	jsr	-138(a6)
	moveq	#0,d0
	rts

GetVBR	sub.l	a4,a4
	move.l	4.w,a6
	btst	#0,297(a6)
	beq.b	NoProcc
	lea	VBRExcp(pc),a5
	jsr	-30(a6)
NoProcc	rts

VBRExcp	dc.w	$4e7a,$c801
	rte

;--------------------------------------;

NewIRQ	movem.l	d0-a6,-(a7)
;	btst	#2,$dff016
;	beq.b	Pause
	bsr.w	SwpScrn
	bsr.w	NewAngl
	bsr.w	Rotate
	bsr	MoveBox
	bsr.w	Prspctv
	bsr.w	DoLines
	bsr.w	FillObj
	bsr	pr_music
	bsr	PrtText
	WaitBm	$f4
	move.w	#$0668,$180(a5)

Pause	movem.l	(a7)+,d0-a6
;	move.w	#$00f0,$180(a5)
	move.w	#$0020,$9c(a5)
	rte

;--------------------------------------;

MoveBox	moveq	#0,d0
	move.l	XSinPnt(pc),a0
	move.b	(a0)+,d0
	ext.w	d0
	move.w	d0,PstionX
	cmp.l	#YSine,a0
	bne	NoNewXS
	lea	XSine(pc),a0
NoNewXS	move.l	a0,XSinPnt

	moveq	#0,d0
	move.l	YSinPnt(pc),a0
	move.b	(a0)+,d0
	move.b	d0,Place1
	add.w	#140,d0
	move.b	d0,Place2
	move.w	#$01fe,Pal1
	move.w	#$ffe1,Pal2
	btst	#8,d0
	beq	NoPal
	move.w	#$ffe1,Pal1
	move.w	#$01fe,Pal2
NoPal	cmp.l	#ESine,a0
	bne	NoNewYS
	lea	YSine(pc),a0
NoNewYS	move.l	a0,YSinPnt
	rts

;--------------------------------------;

SwpScrn	movem.l	CurScrn(pc),d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,CurScrn

	lea	BPL1(pc),a0
	moveq	#1,d7
Mve2Cop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#140*(320/8),d0
	addq.l	#8,a0
	dbf	d7,Mve2Cop

	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	WrkScrn(pc),$54(a5)
	move.w	#2*140<<6+20,$58(a5)
	rts

;--------------------------------------;

NewAngl
NewAngX	move.w	#360,d1
	move.w	AngSkpX(pc),d0
	add.w	d0,AngleX
	cmp.w	AngleX(pc),d1
	bgt.b	NewAngY
	sub.w	d1,AngleX
NewAngY	move.w	AngSkpY(pc),d0
	add.w	d0,AngleY
	cmp.w	AngleY(pc),d1
	bgt.b	NewAngZ
	sub.w	d1,AngleY
NewAngZ	move.w	AngSkpZ(pc),d0
	add.w	d0,AngleZ
	cmp.w	AngleZ(pc),d1
	bgt.b	NewAngF
	sub.w	d1,AngleZ
NewAngF	rts

;--------------------------------------;

;	ROTATION
;	~~~~~~~~
;	(n) = ANGLE TO ROTATE BY, n = AXIS
;	NX=X*COS(Z)-Y*SIN(Z)
;	NY=X*SIN(Z)+Y*COS(Z)
;	NX=X*COS(Y)-Z*SIN(Y)
;	NZ=X*SIN(Y)+Z*COS(Y)
;	NZ=Z*COS(X)-Y*SIN(X)
;	NY=Z*SIN(X)+Y*COS(X)

Rotate	lea	SinTble(pc),a0
	lea	CosTble(pc),a1
	lea	CrdTble(pc),a3
	move.l	Object(pc),a2
	addq.l	#4,a2
	move.w	(a2)+,d7
RotLoop	move.w	(a2)+,d0
	move.w	(a2)+,d1
	move.w	(a2)+,d2

	move.w	AngleZ(pc),d3
	add.w	d3,d3
	move.w	d3,d4
	move.w	(a0,d3),d3
	move.w	(a1,d4),d4
	move.w	d1,d5
	move.w	d0,d6
	muls	d4,d5
	muls	d4,d6
	move.l	d1,d4
	muls	d3,d4
	muls	d0,d3
	add.l	d6,d4
	sub.l	d5,d3
	asr.l	#8,d3
	asr.l	#6,d3
	asr.l	#8,d4
	asr.l	#6,d4
	move.w	d3,d1
	move.w	d4,d0

	move.w	AngleY(pc),d3
	add.w	d3,d3
	move.w	d3,d4
	move.w	(a0,d3),d3
	move.w	(a1,d4),d4
	move.w	d0,d5
	move.w	d2,d6
	muls	d4,d5
	muls	d4,d6
	move.l	d0,d4
	muls	d3,d4
	muls	d2,d3
	add.l	d6,d4
	sub.l	d5,d3
	asr.l	#8,d3
	asr.l	#6,d3
	asr.l	#8,d4
	asr.l	#6,d4
	move.w	d3,d0
	move.w	d4,d2

	move.w	AngleX(pc),d3
	add.w	d3,d3
	move.w	d3,d4
	move.w	(a0,d3),d3
	move.w	(a1,d4),d4
	move.w	d2,d5
	move.w	d1,d6
	muls	d4,d5
	muls	d4,d6
	move.l	d2,d4
	muls	d3,d4
	muls	d1,d3
	add.l	d6,d4
	sub.l	d5,d3
	asr.l	#8,d3
	asr.l	#6,d3
	asr.l	#8,d4
	asr.l	#6,d4
	move.w	d3,d2
	move.w	d4,d1

	move.w	d0,(a3)+
	move.w	d1,(a3)+
	move.w	d2,(a3)+
	dbf	d7,RotLoop

	rts

;--------------------------------------;

;	CENTRAL POINT PERSPECTIVE
;	~~~~~~~~~~~~~~~~~~~~~~~~~
;	qout=fz-z1
;	bx1=de*(x1+fx)/quot
;	by1=de*(y1+fy)/qout

;	x1...Point X Coordinate
;	y1...Point Y Coordinate
;	z1...Point Z Coordinate
;	fx...Central projection origin Coordinate X
;	fy...Central projection origin Coordinate Y
;	fz...Central projection origin Coordinate Z
;	de...Eye-Screen-Distance

Prspctv	move.l	Object(pc),a0
	lea	PrjOrgn(pc),a1
	move.w	4(a0),d7
	lea	CrdTble,a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2

PtvLoop	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	move.w	(a0),d0
	move.w	2(a0),d1
	move.w	4(a0),d2
	move.w	(a1),d3
	move.w	2(a1),d4
	move.w	4(a1),d5

	add.l	d0,d3
	add.l	d1,d4
	ext.l	d3
	asl.l	#8,d3
	ext.l	d4
	asl.l	#8,d4
	sub.w	d2,d5
	beq.b	NoDivs
	divs	d5,d3
	divs	d5,d4

NoDivs	move.w	d3,(a0)
	move.w	d4,2(a0)
	addq.l	#6,a0
	dbf	d7,PtvLoop
	rts

;--------------------------------------;

DoLines	moveq	#40,d0
	moveq	#-1,d1

	WaitBlt
	move.w	d1,$44(a5)
	move.w	d1,$72(a5)
	move.w	#$8000,$74(a5)
	move.w	d0,$60(a5)
	move.w	d0,$66(a5)

	move.l	Object(pc),a0
	move.l	(a0),a1
	move.w	(a1)+,d7
	lea	CrdTble(pc),a0

DrawLp1	move.w	(a1)+,d0
	move.b	d0,SurfCol
	move.w	(a1)+,d6
	bsr.w	HidLine
	sub.w	d2,d0
	blt.w	NoPoly
	moveq	#0,d2
	move.b	SurfCol(pc),d2
	lsl.w	#2,d2
	lea	Colour1(pc),a4
	lea	(a4,d2),a4
	lsr.w	#8,d0
	lsr.w	#1,d0
	cmp.b	#16,d0
	blt.b	NoShde1
	move.b	#$f,d0
NoShde1	move.w	d0,d2
	move.w	d0,d1
	lsl.w	#4,d1
	add.w	d1,d0
	lsl.w	#4,d1
	add.w	d1,d0
	move.w	d0,2(a4)

DrawLp2	moveq	#0,d4
	move.w	(a1)+,d4
	move.l	d4,d5
	add.l	d4,d4
	lsl.l	#2,d5
	add.l	d5,d4
	move.w	(a0,d4),d0
	move.w	2(a0,d4),d1
	moveq	#0,d4
	move.w	(a1),d4
	move.l	d4,d5
	add.l	d4,d4
	lsl.l	#2,d5
	add.l	d5,d4
	move.w	(a0,d4),d2
	move.w	2(a0,d4),d3
	add.w	#160,d0
	add.w	#70,d1
	add.w	#160,d2
	add.w	#70,d3

	btst	#0,SurfCol
	beq.b	NoColr1
	move.l	WrkScrn(pc),a2
	bsr.b	DrawLne
NoColr1	btst	#1,SurfCol
	beq.b	NoColr2
	move.l	WrkScrn(pc),a2
	lea	140*(320/8)(a2),a2
	bsr.b	DrawLne
NoColr2	dbf	d6,DrawLp2
	addq.l	#2,a1
	dbf	d7,DrawLp1
	rts

NoPoly	addq.w	#2,d6
	add.w	d6,d6
	add.w	d6,a1
	dbf	d7,DrawLp1
	rts

;--------------------------------------;

DrawLne	movem.l	d0-d3,-(a7)
	cmp.w	d1,d3
	bge.s	y1ly2
	exg	d0,d2
	exg	d1,d3

y1ly2	sub.w	d1,d3
	move.w	d1,d4
	lsl.w	#3,d1
	lsl.w	#5,d4
	add.w	d4,d1
	ext.l	d1
	add.l	d1,a2
	moveq	#0,d1
	sub.w	d0,d2
	bge.s	xdpos
	addq.w	#2,d1

	neg.w	d2
xdpos	moveq	#$f,d4

	and.w	d0,d4

	move.b	d4,d5			;;
	not.b	d5			;;

	lsr.w	#3,d0
	add.w	d0,a2
	ror.w	#4,d4
	or.w	#$b4a,d4		;;
	swap	d4
	cmp.w	d2,d3
	bge.s	dygdx
	addq.w	#1,d1
	exg	d2,d3
dygdx	add.w	d2,d2
	move.w	d2,d0
	sub.w	d3,d0
	addx.w	d1,d1
	move.b	Octants(pc,d1.w),d4

	swap	d2
	move.w	d0,d2
	sub.w	d3,d2
	moveq	#6,d1

	lsl.w	d1,d3
	add.w	#$42,d3
	lea	$52(a5),a3

	WaitBlt
	bchg	d5,(a2)			;;

	move.l	d4,$40(a5)
	move.l	d2,$62(a5)
	move.l	a2,$48(a5)
	move.w	d0,(a3)+
	move.l	a2,(a3)+
	move.w	d3,(a3)
	movem.l	(a7)+,d0-d3
	rts

SML	=	2 ;0 = LINE, 2 = FILL	;;
Octants	dc.b	SML+01,SML+01+$40
	dc.b	SML+17,SML+17+$40
	dc.b	SML+09,SML+09+$40
	dc.b	SML+21,SML+21+$40

;--------------------------------------;

;	HIDDEN LINES
;	~~~~~~~~~~~~
;	(Y2-Y3)*(X1-X2)-(Y1-Y2)*(X2-X3)
;	IF POSITIVE THEN DRAW IT

HidLine	moveq	#0,d4
	move.w	(a1),d4
	move.l	d4,d5
	add.l	d4,d4
	lsl.l	#2,d5
	add.l	d5,d4
	move.w	(a0,d4),d0
	move.w	2(a0,d4),d1
	moveq	#0,d4
	move.w	2(a1),d4
	move.l	d4,d5
	add.l	d4,d4
	lsl.l	#2,d5
	add.l	d5,d4
	move.w	(a0,d4),d2
	move.w	2(a0,d4),d3
	moveq	#0,d4
	move.w	4(a1),d4
	move.l	d4,d5
	add.l	d4,d4
	lsl.l	#2,d5
	add.l	d4,d5
	move.w	(a0,d5),d4
	move.w	2(a0,d5),d5
	sub.w	d2,d0
	sub.w	d4,d2
	sub.w	d3,d1
	sub.w	d5,d3
	muls	d1,d2
	muls	d3,d0
	rts

;--------------------------------------;

FillObj	move.l	WrkScrn(pc),a0
	lea	2*140*(320/8)-2(a0),a0
	moveq	#0,d0

	WaitBlt
	move.l	#$09f00012,$40(a5)
	move.l	d0,$64(a5)
	move.l	a0,$50(a5)
	move.l	a0,$54(a5)
	move.w	#2*140<<6+20,$58(a5)
	rts

;--------------------------------------;

PrtText	subq.w	#1,TextFnc
	bne	NoFunc
	addq.w	#1,TextFnc

	move.l	TextPnt(pc),a0
	move.l	TxtPntr(pc),a2

	moveq	#39,d7
TextLp1	moveq	#0,d0
	move.l	d0,d1
	move.b	(a0)+,d1
	beq	NxtLine
	sub.b	#32,d1
	bmi	NoText
	divu	#40,d1			;Number of characters per line
	move.w	d1,d0
	swap	d1
	mulu	#16*(320/8),d0		;Planes*FontHeight*PageWidth
	add.l	d1,d0
	lea	Font(pc),a1	
	lea	(a1,d0),a1
	move.l	a2,a3
	moveq	#15,d0
TextLp2	move.b	(a1),(a3)
	lea	40(a1),a1
	lea	40(a3),a3
	dbf	d0,TextLp2
	addq.l	#1,a2
	bra	TextLp1
NxtLine	move.l	a0,TextPnt
	add.l	#16*(320/8),TxtPntr
NoFunc	rts
NoText	cmp.l	#TextEnd,a0
	bne	NoNewTx
	lea	Text(pc),a0
NoNewTx	move.l	a0,TextPnt
	move.l	#TxtArea,TxtPntr
	move.w	#(8*50)-16,TextFnc
	rts

;--------------------------------------;

Music	include	"DH2:ADUIntro2/ProRunner2.0.i"

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0
SBlank	dc.l	0,0
Object	dc.l	D_Box
XSinPnt	dc.l	XSine
YSinPnt	dc.l	YSine+25
SurfCol	dc.w	0
AngSkpX	dc.w	AngleSkipX
AngSkpY	dc.w	AngleSkipY
AngSkpZ	dc.w	AngleSkipZ
AngleX	dc.w	AngleValX
AngleY	dc.w	AngleValY
AngleZ	dc.w	AngleValZ
PrjOrgn
PstionX	dc.w	PositionX
PstionY	dc.w	PositionY
PstionZ	dc.w	PositionZ
CurScrn	dc.l	Screen1
WrkScrn	dc.l	Screen2
TextPnt	dc.l	Text
TxtPntr	dc.l	TxtArea
TextFnc	dc.w	1

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$50c1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$003f
	dc.w	$0106,$0000,$01fc,$0000
	dc.w	$0108,$0000,$010a,$0000

SPR1	dc.w	$0120,$0000,$0122,$0000
	dc.w	$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000
SPR2	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000

	dc.w	$01a2,$0000,$01a4,$0445
	dc.w	$01aa,$0000,$01ac,$0445

Colour1	dc.w	$0180,$088a,$0184,$0000
	dc.w	$0188,$00ff,$018c,$0000

	dc.w	$0182,$0000,$0186,$0000
	dc.w	$018a,$0000,$018e,$0000

	dc.w	$2c07,$fffe,$0100,$1200
BPL2	dc.w	$00e0,$0000,$00e2,$0000
Place1	dc.w	$2c07,$fffe,$0100,$3200
BPL1	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000

Pal1	dc.w	$ffe1,$fffe
Place2	dc.w	$b807,$fffe,$0100,$1200

Pal2	dc.w	$ffe1,$fffe
	dc.w	$2c07,$fffe,$0100,$0200
	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

RbSprte	dc.w	$1ecc,$2806
	dc.w	$0fc0,$1020,$3fe0,$4010,$6630,$9940,$0c60,$1290,$19c0,$2620
	dc.w	$3f08,$0095,$3817,$4428,$6e25,$9112,$c3e7,$2418,$8079,$4086
	dc.w	$1ed4,$2806
	dc.w	$0000,$0000,$1800,$2000,$2800,$5000,$5804,$a002,$b19e,$4a00
	dc.w	$e288,$1515,$d491,$2a22,$3cb3,$c34c,$3fff,$8000,$c211,$252a
	dc.w	$1edc,$2806
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0c00,$0200
	dc.w	$ef00,$0000,$6b00,$9400,$9200,$6d00,$7700,$8000,$c200,$2500

;--------------------------------------;

D_Box	dc.l	L_Box

P_Box	dc.w	7			;Points-1
	dc.w	-60,-60,-60
	dc.w	 60,-60,-60
	dc.w	 60, 60,-60
	dc.w	-60, 60,-60
	dc.w	-60,-60, 60
	dc.w	 60,-60, 60
	dc.w	 60, 60, 60
	dc.w	-60, 60, 60

L_Box	dc.w	5			;Surfaces-1
	dc.w	1,3			;Colour, Lines in Surface-1
	dc.w	0,1,2,3,0
	dc.w	1,3
	dc.w	5,4,7,6,5
	dc.w	2,3
	dc.w	4,0,3,7,4
	dc.w	2,3
	dc.w	1,5,6,2,1
	dc.w	3,3
	dc.w	4,5,1,0,4
	dc.w	3,3
	dc.w	3,2,6,7,3

CrdTble	dcb.w	3*8,0

;--------------------------------------;

XSine	dc.b	$04,$0b,$12,$19,$20,$27,$2e,$34,$3b,$41
	dc.b	$46,$4c,$51,$56,$5b,$5f,$63,$66,$6a,$6c
	dc.b	$6e,$70,$72,$72,$73,$73,$72,$72,$70,$6e
	dc.b	$6c,$6a,$66,$63,$5f,$5b,$56,$51,$4c,$46
	dc.b	$41,$3b,$34,$2e,$27,$20,$19,$12,$0b,$04
	dc.b	$fc,$f5,$ee,$e7,$e0,$d9,$d2,$cc,$c5,$bf
	dc.b	$ba,$b4,$af,$aa,$a5,$a1,$9d,$9a,$96,$94
	dc.b	$92,$90,$8e,$8e,$8d,$8d,$8e,$8e,$90,$92
	dc.b	$94,$96,$9a,$9d,$a1,$a5,$aa,$af,$b4,$ba
	dc.b	$bf,$c5,$cc,$d2,$d9,$e0,$e7,$ee,$f5,$fc
YSine	dc.b	$66,$69,$6d,$70,$74,$77,$7a,$7d,$81,$83
	dc.b	$86,$89,$8c,$8e,$90,$92,$94,$96,$97,$99
	dc.b	$9a,$9b,$9b,$9c,$9c,$9c,$9c,$9b,$9b,$9a
	dc.b	$99,$97,$96,$94,$92,$90,$8e,$8c,$89,$86
	dc.b	$83,$81,$7d,$7a,$77,$74,$70,$6d,$69,$66
	dc.b	$62,$5f,$5b,$58,$54,$51,$4e,$4b,$47,$45
	dc.b	$42,$3f,$3c,$3a,$38,$36,$34,$32,$31,$2f
	dc.b	$2e,$2d,$2d,$2c,$2c,$2c,$2c,$2d,$2d,$2e
	dc.b	$2f,$31,$32,$34,$36,$38,$3a,$3c,$3f,$42
	dc.b	$45,$47,$4b,$4e,$51,$54,$58,$5b,$5f,$62
ESine	dc.b	$42,$59,$20,$52,$4F,$42,$53,$54,$45,$52

;--------------------------------------;

SinTble	dc.w	 00000, 00286, 00572, 00857, 01143, 01428, 01713, 01997, 02280
	dc.w	 02563, 02845, 03126, 03406, 03686, 03964, 04240, 04516, 04790
	dc.w	 05063, 05334, 05604, 05872, 06138, 06402, 06664, 06924, 07182
	dc.w	 07438, 07692, 07943, 08192, 08438, 08682, 08923, 09162, 09397
	dc.w	 09630, 09860, 10087, 10311, 10531, 10749, 10963, 11174, 11381
	dc.w	 11585, 11786, 11982, 12176, 12365, 12551, 12733, 12911, 13085
	dc.w	 13255, 13421, 13583, 13741, 13894, 14044, 14189, 14330, 14466
	dc.w	 14598, 14726, 14849, 14968, 15082, 15191, 15296, 15396, 15491
	dc.w	 15582, 15668, 15749, 15826, 15897, 15964, 16026, 16083, 16135
	dc.w	 16182, 16225, 16262, 16294, 16322, 16344, 16362, 16374, 16382

CosTble	dc.w	 16384, 16382, 16374, 16362, 16344, 16322, 16294, 16262, 16225
	dc.w	 16182, 16135, 16083, 16026, 15964, 15897, 15826, 15749, 15668
	dc.w	 15582, 15491, 15396, 15296, 15191, 15082, 14967, 14849, 14726
	dc.w	 14598, 14466, 14330, 14189, 14044, 13894, 13741, 13583, 13421
	dc.w	 13255, 13085, 12911, 12733, 12551, 12365, 12176, 11982, 11786
	dc.w	 11585, 11381, 11174, 10963, 10749, 10531, 10311, 10087, 09860
	dc.w	 09630, 09397, 09162, 08923, 08682, 08438, 08192, 07943, 07692
	dc.w	 07438, 07182, 06924, 06664, 06402, 06138, 05872, 05604, 05334
	dc.w	 05063, 04790, 04516, 04240, 03964, 03686, 03406, 03126, 02845
	dc.w	 02563, 02280, 01997, 01713, 01428, 01143, 00857, 00572, 00286
	dc.w	 00000,-00286,-00572,-00857,-01143,-01428,-01713,-01997,-02280
	dc.w	-02563,-02845,-03126,-03406,-03686,-03964,-04240,-04516,-04790
	dc.w	-05063,-05334,-05604,-05872,-06138,-06402,-06664,-06924,-07182
	dc.w	-07438,-07692,-07943,-08192,-08438,-08682,-08923,-09162,-09397
	dc.w	-09630,-09860,-10087,-10311,-10531,-10749,-10963,-11174,-11381
	dc.w	-11585,-11786,-11982,-12176,-12365,-12551,-12733,-12911,-13085
	dc.w	-13255,-13421,-13583,-13741,-13894,-14044,-14189,-14330,-14466
	dc.w	-14598,-14726,-14849,-14968,-15082,-15191,-15296,-15396,-15491
	dc.w	-15582,-15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
	dc.w	-16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374,-16382
	dc.w	-16384,-16382,-16374,-16362,-16344,-16322,-16294,-16262,-16225
	dc.w	-16182,-16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668
	dc.w	-15582,-15491,-15396,-15296,-15191,-15082,-14967,-14849,-14726
	dc.w	-14598,-14466,-14330,-14189,-14044,-13894,-13741,-13583,-13421
	dc.w	-13255,-13085,-12911,-12733,-12551,-12365,-12176,-11982,-11786
	dc.w	-11585,-11381,-11174,-10963,-10749,-10531,-10311,-10087,-09860
	dc.w	-09630,-09397,-09162,-08923,-08682,-08438,-08192,-07943,-07692
	dc.w	-07438,-07182,-06924,-06664,-06402,-06138,-05872,-05604,-05334
	dc.w	-05063,-04790,-04516,-04240,-03964,-03686,-03406,-03126,-02845
	dc.w	-02563,-02280,-01997,-01713,-01428,-01143,-00857,-00572,-00286

	dc.w	 00000, 00286, 00572, 00857, 01143, 01428, 01713, 01997, 02280
	dc.w	 02563, 02845, 03126, 03406, 03686, 03964, 04240, 04516, 04790
	dc.w	 05063, 05334, 05604, 05872, 06138, 06402, 06664, 06924, 07182
	dc.w	 07438, 07692, 07943, 08192, 08438, 08682, 08923, 09162, 09397
	dc.w	 09630, 09860, 10087, 10311, 10531, 10749, 10963, 11174, 11381
	dc.w	 11585, 11786, 11982, 12176, 12365, 12551, 12733, 12911, 13085
	dc.w	 13255, 13421, 13583, 13741, 13894, 14044, 14189, 14330, 14466
	dc.w	 14598, 14726, 14849, 14968, 15082, 15191, 15296, 15396, 15491
	dc.w	 15582, 15668, 15749, 15826, 15897, 15964, 16026, 16083, 16135
	dc.w	 16182, 16225, 16262, 16294, 16322, 16344, 16362, 16374, 16382

;--------------------------------------;

Text	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"   WELCOME TO AMIGA DOWN UNDER ISSUE 8  ",0
	dc.b	"                                        ",0
	dc.b	"   THIS ISSUE HAS LOTS OF COOL THINGS   ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"      BUT FIRST...   THE CREDITS        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",1

	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"               C O D I N G              ",0
	dc.b	"               -+ROBSTER+-              ",0
	dc.b	"                                        ",0
	dc.b	"                M U S I C               ",0
	dc.b	"             -+2PAC-ZENITH+-            ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",1

TextEnd	even
Font	incbin	"DH2:ADUIntro2/Font.raw"
Screen1	dcb.b	2*140*(320/8),0
Screen2	dcb.b	2*140*(320/8),0
TxtArea	dcb.b	256*(320/8),0
pr_data	incbin	"DH2:ADUIntro2/mod.Antipasti#16"
