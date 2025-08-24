	SECTION	"Robster - Blurred Vectors",CODE_C

AngleSkipX	= 1
AngleSkipY	= 3
AngleSkipZ	= 4
AngleValX	= 0
AngleValY	= 0
AngleValZ	= 0

PositionX	= 0
PositionY	= 0
PositionZ	= 1300

XSpeed		= 1
YSpeed		= 3
ZSpeed		= 2

;--------------------------------------;

WaitBlt	MACRO
	tst.b	2(a5)
WB\@	btst	#6,2(a5)
	bne.b	WB\@
	ENDM
WaitBm	MACRO
WB\@	cmp.b	#\1,6(a5)
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
	move.l	#Screen,d0
	moveq	#2,d7
Pic2Cop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#(400/8),d0
	addq.l	#8,a0
	dbf	d7,Pic2Cop

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

	tst.b	CycleNo
	bne	NoMouse
	btst	#2,$dff016
	beq.b	Pause
NoMouse	bsr	pr_music
	bchg	#0,CycleNo
	bne	Cycle2

Cycle1	bsr.b	ClrScrn
	bsr.w	SineVex
	bsr.b	NewAngl
	bsr.w	Rotate
	bsr.w	Prspctv
	bsr.w	DoLines
	bsr.w	FillObj
	WaitBm	$b0
	bsr.w	MoveMsk
	bra.w	Pause

Cycle2	bsr.w	MoveVex

Pause	movem.l	(a7)+,d0-a6
;	move.w	#$00f0,$180(a5)
	move.w	#$0020,$9c(a5)
	rte

CycleNo	dc.b	0,0

;--------------------------------------;

ClrScrn	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	#WrkScrn,$54(a5)
	move.w	#2*80<<6+6,$58(a5)
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

DoLines	moveq	#12,d0
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
	moveq	#3,d6
	bsr.w	HidLine
	cmp.w	d2,d0
	blt.b	NoPoly
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
	add.w	#40,d0
	add.w	#40,d1
	add.w	#40,d2
	add.w	#40,d3

	btst	#0,SurfCol
	beq.b	NoColr1
	lea	WrkScrn(pc),a2
	bsr.b	DrawLne
NoColr1	btst	#1,SurfCol
	beq.b	NoColr2
	lea	WrkScrn(pc),a2
	lea	80*(96/8)(a2),a2
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
	muls	#12,d1
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

FillObj	lea	WrkScrn(pc),a0
	lea	2*80*(96/8)-2(a0),a0
	moveq	#0,d0

	WaitBlt
	move.l	#$09f00012,$40(a5)
	move.l	d0,$64(a5)
	move.l	a0,$50(a5)
	move.l	a0,$54(a5)
	move.w	#2*80<<6+6,$58(a5)
	rts

;--------------------------------------;

MoveMsk	lea	Screen(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	move.w	BoxX(pc),d0
	move.w	BoxY(pc),d1
	sub.w	#64,d0
	sub.w	#64,d1
	muls	#3*50,d1
	lea	(a0,d1),a1
	move.w	d0,d2
	and.w	#$f,d0
	ror.w	#4,d0
	WaitBlt
	move.w	d0,$42(a5)
	or.w	#$0fca,d0
	move.w	d0,$40(a5)
	asr.w	#3,d2
	lea	(a1,d2),a1
	move.l	#$ffffffff,$44(a5)
	move.w	#32,$60(a5)
	move.w	#0,$62(a5)
	move.w	#0,$64(a5)
	move.w	#32,$66(a5)
	move.l	#BlurMsk,$4c(a5)
	move.l	#BlurMsk,$50(a5)
	move.l	a1,$48(a5)
	move.l	a1,$54(a5)
	move.w	#3*128<<6+9,$58(a5)

	WaitBlt
	move.l	#$09f00000,$40(a5)
	move.l	#WrkScrn,$50(a5)
	move.l	#BlkScrn,$54(a5)
	move.w	#0,$64(a5)
	move.w	#0,$66(a5)
	move.w	#80<<6+6,$58(a5)

	WaitBlt
	move.w	#$0bfa,$40(a5)
	move.l	#WrkScrn+80*(96/8),$50(a5)
	move.l	#BlkScrn,$54(a5)
	move.l	#BlkScrn,$48(a5)
	move.w	#0,$60(a5)
	move.w	#80<<6+6,$58(a5)
	rts

MoveVex	lea	Screen(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	move.w	BoxX(pc),d0
	move.w	BoxY(pc),d1
	sub.w	#40,d0
	sub.w	#40,d1
	muls	#3*50,d1
	lea	(a0,d1),a1
	move.w	d0,d2
	and.w	#$f,d0
	ror.w	#4,d0
	WaitBlt
	move.w	d0,$42(a5)
	or.w	#$0f0a,d0
	move.w	d0,$40(a5)
	asr.w	#3,d2
	lea	(a1,d2),a1
	move.w	#138,$60(a5)
	move.w	#0,$62(a5)
	move.w	#0,$64(a5)
	move.w	#138,$66(a5)
	move.l	#BlkScrn,$4c(a5)
	move.l	#BlkScrn,$50(a5)
	move.l	a1,$48(a5)
	move.l	a1,$54(a5)
	move.w	#80<<6+6,$58(a5)

	lea	50(a1),a1
	WaitBlt
	move.l	#BlkScrn,$4c(a5)
	move.l	#BlkScrn,$50(a5)
	move.l	a1,$48(a5)
	move.l	a1,$54(a5)
	move.w	#80<<6+6,$58(a5)

	lea	50(a1),a1
	WaitBlt
	move.l	#BlkScrn,$4c(a5)
	move.l	#BlkScrn,$50(a5)
	move.l	a1,$48(a5)
	move.l	a1,$54(a5)
	move.w	#80<<6+6,$58(a5)

	and.w	#$f000,d0
	or.w	#$0fca,d0
	lea	-100(a1),a1
	WaitBlt
	move.w	d0,$40(a5)
	move.l	#WrkScrn,$4c(a5)
	move.l	#WrkScrn,$50(a5)
	move.l	a1,$48(a5)
	move.l	a1,$54(a5)
	move.w	#80<<6+6,$58(a5)

	lea	50(a1),a1
	WaitBlt
	move.l	#WrkScrn+80*(96/8),$4c(a5)
	move.l	#WrkScrn+80*(96/8),$50(a5)
	move.l	a1,$48(a5)
	move.l	a1,$54(a5)
	move.w	#80<<6+6,$58(a5)

	rts

;--------------------------------------;

SineVex	lea	MveSinX(pc),a0
	moveq	#0,d0
	move.b	SineX(pc),d0
	move.b	(a0,d0),d0
	lsl.w	#1,d0
	move.w	d0,BoxX
	addq.b	#XSpeed&255,SineX

	lea	MveSinY(pc),a0
	moveq	#0,d0
	move.b	SineY(pc),d0
	move.b	(a0,d0),d0
	move.w	d0,BoxY
	addq.b	#YSpeed&255,SineY

	lea	MveSinZ(pc),a0
	moveq	#0,d0
	move.b	SineZ(pc),d0
	lsl.w	#1,d0
	move.w	(a0,d0),d0
	move.w	d0,PstionZ
	addq.b	#ZSpeed&255,SineZ
	rts

;--------------------------------------;

Music	include	"DH2:BlurredVex/ProRunner2.0.i"

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0
SBlank	dc.l	0,0
Object	dc.l	D_Box
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
BoxX	dc.w	40
BoxY	dc.w	210
SineX	dc.b	0
SineY	dc.b	0
SineZ	dc.b	0
	even

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$003f
	dc.w	$0106,$0000,$01fc,$0000
	dc.w	$0108,$006e,$010a,$006e

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

	dc.w	$0180,$088a,$018e,$088a
	dc.w	$0182,$0288,$0184,$0488
	dc.w	$0186,$0688

	dc.w	$2c07,$fffe,$0100,$3200
BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000

	dc.w	$f407,$fffe
	dc.w	$0180,$0668,$018e,$0668

	dc.w	$ffe1,$fffe
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
	dc.w	-100,-100,-100
	dc.w	 100,-100,-100
	dc.w	 100, 100,-100
	dc.w	-100, 100,-100
	dc.w	-100,-100, 100
	dc.w	 100,-100, 100
	dc.w	 100, 100, 100
	dc.w	-100, 100, 100

L_Box	dc.w	5			;Surfaces-1
	dc.w	1, 0,1,2,3,0
	dc.w	1, 5,4,7,6,5
	dc.w	2, 4,0,3,7,4
	dc.w	2, 1,5,6,2,1
	dc.w	3, 4,5,1,0,4
	dc.w	3, 3,2,6,7,3

CrdTble	dcb.w	3*8,0

;--------------------------------------;

MveSinX	dc.b	$8c,$8c,$8c,$8c,$8c,$8b,$8b,$8b,$8b,$8a,$8a,$8a,$89,$89,$88,$88
	dc.b	$87,$87,$86,$85,$85,$84,$83,$82,$81,$81,$80,$7f,$7e,$7d,$7c,$7b
	dc.b	$7a,$79,$78,$77,$75,$74,$73,$72,$71,$6f,$6e,$6d,$6c,$6a,$69,$68
	dc.b	$66,$65,$64,$62,$61,$5f,$5e,$5c,$5b,$5a,$58,$57,$55,$54,$52,$51
	dc.b	$4f,$4e,$4c,$4b,$49,$48,$46,$45,$44,$42,$41,$3f,$3e,$3c,$3b,$3a
	dc.b	$38,$37,$36,$34,$33,$32,$31,$2f,$2e,$2d,$2c,$2b,$29,$28,$27,$26
	dc.b	$25,$24,$23,$22,$21,$20,$1f,$1f,$1e,$1d,$1c,$1b,$1b,$1a,$19,$19
	dc.b	$18,$18,$17,$17,$16,$16,$16,$15,$15,$15,$15,$14,$14,$14,$14,$14
	dc.b	$14,$14,$14,$14,$14,$15,$15,$15,$15,$16,$16,$16,$17,$17,$18,$18
	dc.b	$19,$19,$1a,$1b,$1b,$1c,$1d,$1e,$1f,$1f,$20,$21,$22,$23,$24,$25
	dc.b	$26,$27,$28,$29,$2b,$2c,$2d,$2e,$2f,$31,$32,$33,$34,$36,$37,$38
	dc.b	$3a,$3b,$3c,$3e,$3f,$41,$42,$44,$45,$46,$48,$49,$4b,$4c,$4e,$4f
	dc.b	$51,$52,$54,$55,$57,$58,$5a,$5b,$5c,$5e,$5f,$61,$62,$64,$65,$66
	dc.b	$68,$69,$6a,$6c,$6d,$6e,$6f,$71,$72,$73,$74,$75,$77,$78,$79,$7a
	dc.b	$7b,$7c,$7d,$7e,$7f,$80,$81,$81,$82,$83,$84,$85,$85,$86,$87,$87
	dc.b	$88,$88,$89,$89,$8a,$8a,$8a,$8b,$8b,$8b,$8b,$8c,$8c,$8c,$8c,$8c

MveSinY	dc.b	$72,$73,$74,$76,$77,$79,$7a,$7b,$7d,$7e,$80,$81,$82,$84,$85,$86
	dc.b	$87,$89,$8a,$8b,$8c,$8e,$8f,$90,$91,$92,$94,$95,$96,$97,$98,$99
	dc.b	$9a,$9b,$9c,$9d,$9e,$9e,$9f,$a0,$a1,$a2,$a2,$a3,$a4,$a4,$a5,$a5
	dc.b	$a6,$a6,$a7,$a7,$a8,$a8,$a8,$a9,$a9,$a9,$a9,$aa,$aa,$aa,$aa,$aa
	dc.b	$aa,$aa,$aa,$aa,$aa,$a9,$a9,$a9,$a9,$a8,$a8,$a8,$a7,$a7,$a6,$a6
	dc.b	$a5,$a5,$a4,$a4,$a3,$a2,$a2,$a1,$a0,$9f,$9e,$9e,$9d,$9c,$9b,$9a
	dc.b	$99,$98,$97,$96,$95,$94,$92,$91,$90,$8f,$8e,$8c,$8b,$8a,$89,$87
	dc.b	$86,$85,$84,$82,$81,$80,$7e,$7d,$7b,$7a,$79,$77,$76,$74,$73,$72
	dc.b	$70,$6f,$6e,$6c,$6b,$69,$68,$67,$65,$64,$62,$61,$60,$5e,$5d,$5c
	dc.b	$5b,$59,$58,$57,$56,$54,$53,$52,$51,$50,$4e,$4d,$4c,$4b,$4a,$49
	dc.b	$48,$47,$46,$45,$44,$44,$43,$42,$41,$40,$40,$3f,$3e,$3e,$3d,$3d
	dc.b	$3c,$3c,$3b,$3b,$3a,$3a,$3a,$39,$39,$39,$39,$38,$38,$38,$38,$38
	dc.b	$38,$38,$38,$38,$38,$39,$39,$39,$39,$3a,$3a,$3a,$3b,$3b,$3c,$3c
	dc.b	$3d,$3d,$3e,$3e,$3f,$40,$40,$41,$42,$43,$44,$44,$45,$46,$47,$48
	dc.b	$49,$4a,$4b,$4c,$4d,$4e,$50,$51,$52,$53,$54,$56,$57,$58,$59,$5b
	dc.b	$5c,$5d,$5e,$60,$61,$62,$64,$65,$67,$68,$69,$6b,$6c,$6e,$6f,$70

MveSinZ	dc.w	$0908,$0921,$0939,$0952,$096a,$0983,$099b,$09b3,$09cb,$09e3
	dc.w	$09fb,$0a13,$0a2a,$0a41,$0a58,$0a6f,$0a86,$0a9c,$0ab3,$0ac9
	dc.w	$0ade,$0af4,$0b09,$0b1d,$0b32,$0b46,$0b5a,$0b6d,$0b80,$0b92
	dc.w	$0ba5,$0bb6,$0bc8,$0bd9,$0be9,$0bf9,$0c09,$0c18,$0c26,$0c35
	dc.w	$0c42,$0c4f,$0c5c,$0c68,$0c74,$0c7f,$0c89,$0c93,$0c9d,$0ca5
	dc.w	$0cae,$0cb5,$0cbc,$0cc3,$0cc9,$0cce,$0cd3,$0cd7,$0cdb,$0cde
	dc.w	$0ce0,$0ce2,$0ce3,$0ce4,$0ce4,$0ce3,$0ce2,$0ce0,$0cde,$0cdb
	dc.w	$0cd7,$0cd3,$0cce,$0cc9,$0cc3,$0cbc,$0cb5,$0cae,$0ca5,$0c9d
	dc.w	$0c93,$0c89,$0c7f,$0c74,$0c68,$0c5c,$0c4f,$0c42,$0c35,$0c26
	dc.w	$0c18,$0c09,$0bf9,$0be9,$0bd9,$0bc8,$0bb6,$0ba5,$0b92,$0b80
	dc.w	$0b6d,$0b5a,$0b46,$0b32,$0b1d,$0b09,$0af4,$0ade,$0ac9,$0ab3
	dc.w	$0a9c,$0a86,$0a6f,$0a58,$0a41,$0a2a,$0a13,$09fb,$09e3,$09cb
	dc.w	$09b3,$099b,$0983,$096a,$0952,$0939,$0921,$0908,$08f0,$08d7
	dc.w	$08bf,$08a6,$088e,$0875,$085d,$0845,$082d,$0815,$07fd,$07e5
	dc.w	$07ce,$07b7,$07a0,$0789,$0772,$075c,$0745,$072f,$071a,$0704
	dc.w	$06ef,$06db,$06c6,$06b2,$069e,$068b,$0678,$0666,$0653,$0642
	dc.w	$0630,$061f,$060f,$05ff,$05ef,$05e0,$05d2,$05c3,$05b6,$05a9
	dc.w	$059c,$0590,$0584,$0579,$056f,$0565,$055b,$0553,$054a,$0543
	dc.w	$053c,$0535,$052f,$052a,$0525,$0521,$051d,$051a,$0518,$0516
	dc.w	$0515,$0514,$0514,$0515,$0516,$0518,$051a,$051d,$0521,$0525
	dc.w	$052a,$052f,$0535,$053c,$0543,$054a,$0553,$055b,$0565,$056f
	dc.w	$0579,$0584,$0590,$059c,$05a9,$05b6,$05c3,$05d2,$05e0,$05ef
	dc.w	$05ff,$060f,$061f,$0630,$0642,$0653,$0666,$0678,$068b,$069e
	dc.w	$06b2,$06c6,$06db,$06ef,$0704,$071a,$072f,$0745,$075c,$0772
	dc.w	$0789,$07a0,$07b7,$07ce,$07e5,$07fd,$0815,$082d,$0845,$085d
	dc.w	$0875,$088e,$08a6,$08bf,$08d7,$08f0

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

WrkScrn	dcb.b	2*80*(96/8),0
BlkScrn	dcb.b	80*(96/8),0
	dcb.b	3*100*(400/8),0
Screen	dcb.b	3*256*(400/8),0
	dcb.b	3*100*(400/8),0
BlurMsk	incbin	"DH2:BlurredVex/Blur.raw"
pr_data	incbin	"DH2:BlurredVex/mod.antipasti#16"


