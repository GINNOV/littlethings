	SECTION	"Robster - Marantz Intro 2",CODE_C

AngleSkipX	= 2
AngleSkipY	= 2
AngleSkipZ	= 4
Proj		= 400

;--------------------------------------;

WaitBlt	MACRO
	tst.b	2(a5)
WB\@	btst	#6,2(a5)
	bne.b	WB\@
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

	move.l	#Page,d0
	lea	BPL5(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.l	#SBlank,d0
	lea	SPRBPL(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.l	#Bar1,d0
	move.l	#Bar2,d1
	lea	SPR1(pc),a0
	move.w	d0,6(a0)
	move.w	d1,14(a0)
	swap	d0
	swap	d1
	move.w	d0,2(a0)
	move.w	d1,10(a0)

	move.l	#RbSprte,d0
	lea	SPR2(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#44,d0
	move.w	d0,14(a0)
	swap	d0
	move.w	d0,10(a0)

	move.l	#SBlank,d0
	lea	SPR3(pc),a0
	moveq	#3,d7
SPRLoop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	addq.l	#8,a0
	dbf	d7,SPRLoop

	bsr.w	Insert
	move.l	#pr_Data,pr_Module
	bsr.w	pr_init
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
	bsr	pr_music
	bsr	PrntTxt
	bsr	DoFade1
	bsr	DoFade2
	bsr	DoWait1
	bsr	DoFade3
	bsr	DoFade4
	bsr	DoLoop1
	bchg	#0,IRQSwch
	bne	DoFill

	bsr.w	SwpScrn
	bsr	MveBoxs
	bsr.w	NewAngl
	bsr.w	Rotate
	bsr.w	Prspctv
	bsr.w	DoLines
	bra	IRQEnd

DoFill	bsr	MveBoxs
	bsr.w	FillObj
IRQEnd	movem.l	(a7)+,d0-a6
;	move.w	#$00f0,$dff180
	move.w	#$0020,$dff09c
	rte
IRQSwch	dc.b	0,0

;--------------------------------------;

MveBoxs	moveq	#0,d0
	move.w	SpeedNo(pc),d0
	addq.w	#1,d0
	cmp.w	#200,d0
	bne	NSpdRst
	moveq	#0,d0
NSpdRst	move.w	d0,SpeedNo
	lea	SpdList(pc),a0
	moveq	#0,d1
	move.b	(a0,d0),d1

	move.w	LineCnt(pc),d0
	add.w	d1,d0
ChkHigh	cmp.w	#120,d0
	blt	NotHigh
	sub.w	#120,d0
	bra	ChkHigh
NotHigh	cmp.w	#0,d0
	bge	NotLow
	add.w	#120,d0
	bra	NotHigh
NotLow	move.w	d0,LineCnt

	muls	#40,d0
	move.l	CurScrn(pc),a0
	lea	(a0,d0),a0
	move.l	a0,d0
	lea	BPL1(pc),a0
	moveq	#2,d7
CopShft	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#120*(320/8),d0
	addq.l	#8,a0
	dbf	d7,CopShft

	move.l	#$98,d0
	sub.w	LineCnt(pc),d0
	move.b	d0,CopMve1

	move.l	#$110,d0
	sub.w	LineCnt(pc),d0
	move.b	d0,CopMve2

	move.w	#$ffdf,PlArea1
	move.w	#$01fe,PlArea2
	btst	#8,d0
	bne	IsInPal
	move.w	#$01fe,PlArea1
	move.w	#$ffdf,PlArea2
IsInPal	bsr.w	Insert
	rts

Insert	move.l	CurScrn(pc),d0
	lea	BPL2(pc),a1
	lea	BPL3(pc),a2
	moveq	#2,d7
Mve2Cop	move.w	d0,6(a1)
	move.w	d0,6(a2)
	swap	d0
	move.w	d0,2(a1)
	move.w	d0,2(a2)
	swap	d0
	add.l	#120*(320/8),d0
	addq.l	#8,a1
	addq.l	#8,a2
	dbf	d7,Mve2Cop
	rts

;--------------------------------------;

SwpScrn	movem.l	CurScrn(pc),d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,CurScrn

	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	WrkScrn(pc),$54(a5)
	move.w	#3*120<<6+20,$58(a5)
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
	lea	AngleX(pc),a4
	move.l	Object(pc),a2
	addq.l	#4,a2
	move.w	(a2)+,d7
RotLoop	move.w	(a2)+,d0
	move.w	(a2)+,d1
	move.w	(a2)+,d2

	move.w	4(a4),d3
	add.w	d3,d3
	move.w	(a1,d3),d4
	move.w	(a0,d3),d3
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

	move.w	2(a4),d3
	add.w	d3,d3
	move.w	(a1,d3),d4
	move.w	(a0,d3),d3
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

	move.w	(a4),d3
	add.w	d3,d3
	move.w	(a1,d3),d4
	move.w	(a0,d3),d3
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
	move.w	d1,26(a3)
	move.w	d2,54(a3)
	dbf	d7,RotLoop

	rts

;--------------------------------------;

;	PERSPECTIVE
;	~~~~~~~~~~~
;	bx=de*x/z, by=de*y/z
;	x1...Point X Coordinate
;	y1...Point Y Coordinate
;	z1...Point Z Coordinate
;	de...Eye-Screen-Distance

Prspctv	move.l	Object(pc),a0
	move.w	4(a0),d7
	lea	CrdTble(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	#Proj,d3

PtvLoop	move.w	(a0),d0
	move.w	28(a0),d1
	move.w	56(a0),d2
	move.w	d3,d4
	ext.l	d0
	asl.l	#8,d0
	ext.l	d1
	asl.l	#8,d1
	sub.w	d2,d4
	beq.b	NoDivs
	divs	d4,d0
	divs	d4,d1

NoDivs	add.w	#160,d0
	add.w	#60,d1
	move.w	d0,(a0)+
	move.w	d1,26(a0)
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

	moveq	#2,d6
	bsr.w	HidLine
	cmp.w	d2,d0
	bge.b	DrawLp2
	bset	#2,SurfCol
	bclr	#0,SurfCol

DrawLp2	moveq	#0,d4
	move.w	(a1)+,d4
	add.w	d4,d4
	move.w	(a0,d4),d0
	move.w	28(a0,d4),d1
	moveq	#0,d4
	move.w	(a1),d4
	add.w	d4,d4
	move.w	(a0,d4),d2
	move.w	28(a0,d4),d3

	btst	#0,SurfCol
	beq.b	NoColr1
	move.l	WrkScrn(pc),a2
	bsr.b	DrawLne
NoColr1	btst	#1,SurfCol
	beq.b	NoColr2
	move.l	WrkScrn(pc),a2
	lea	120*(320/8)(a2),a2
	btst	#2,SurfCol
	beq.b	NotHidn
	lea	120*(320/8)(a2),a2
NotHidn	bsr.b	DrawLne
NoColr2	dbf	d6,DrawLp2
	addq.l	#2,a1
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

HidLine	moveq	#0,d5
	move.w	(a1),d5
	add.w	d5,d5
	move.w	(a0,d5),d0
	move.w	28(a0,d5),d1
	moveq	#0,d5
	move.w	2(a1),d5
	add.w	d5,d5
	move.w	(a0,d5),d2
	move.w	28(a0,d5),d3
	moveq	#0,d5
	move.w	4(a1),d5
	add.w	d5,d5
	move.w	(a0,d5),d4
	move.w	28(a0,d5),d5
	sub.w	d2,d0
	sub.w	d4,d2
	sub.w	d3,d1
	sub.w	d5,d3
	muls	d1,d2
	muls	d3,d0
	rts

;--------------------------------------;

FillObj	move.l	WrkScrn(pc),a0
	lea	3*120*(320/8)-2(a0),a0
	moveq	#0,d0

	WaitBlt
	move.l	#$09f00012,$40(a5)
	move.l	d0,$64(a5)
	move.l	a0,$50(a5)
	move.l	a0,$54(a5)
	move.w	#3*120<<6+20,$58(a5)
	rts

;--------------------------------------;

PrntTxt	tst.b	TxtSwch
	bne	PrntEnd
	moveq	#10,d2

PTextLp	move.l	TextPnt(pc),a0
	moveq	#0,d0
	move.b	(a0)+,d0
	beq	NxtLine
	sub.b	#32,d0
	bmi	EndChar
	move.l	a0,TextPnt

	divu	#(320/16),d0		;Number of characters per line
	move.w	d0,d1
	swap	d0
	lsl.w	#1,d0			;Width of Font
	ext.l	d0
	mulu	#11*(320/8),d1		;Planes*FontHeight*PageWidth
	add.l	d1,d0
	add.l	#Font,d0
	move.l	d0,a1
	move.l	ScrnPnt(pc),a2
	moveq	#10,d0
PrtLoop	move.b	(a1),(a2)
	lea	(320/8)(a1),a1
	lea	(320/8)(a2),a2
	dbf	d0,PrtLoop
	addq.l	#1,ScrnPnt
	dbf	d2,PTextLp
PrntEnd	rts

EndChar	cmp.l	#TextEnd,a0
	bne	NoNwTxt
	lea	Text(pc),a0
NoNwTxt	move.l	a0,TextPnt
	move.l	#TxtArea,ScrnPnt
	addq.b	#1,TxtSwch
	rts
NxtLine	move.l	a0,TextPnt
	add.l	#10*(320/8),ScrnPnt
	rts

;--------------------------------------;

DoFade1	cmp.b	#1,TxtSwch
	bne	FadeEnd
	lea	ColLst1(pc),a1
	moveq	#15,d4
	bsr	DoFades
	tst.b	d4
	bne	FadeEnd
	addq.b	#1,TxtSwch
	rts

;--------------------------------------;

DoFade2	cmp.b	#2,TxtSwch
	bne	FadeEnd
	lea	ColLst2(pc),a1
	moveq	#15,d4
	bsr	DoFades
	tst.b	d4
	bne	FadeEnd
	addq.b	#1,TxtSwch
	rts

;--------------------------------------;

DoFade3	cmp.b	#4,TxtSwch
	bne	FadeEnd
	lea	ColLst3(pc),a1
	moveq	#15,d4
	bsr	DoFades
	tst.b	d4
	bne	FadeEnd
	addq.b	#1,TxtSwch
	rts

;--------------------------------------;

DoFade4	cmp.b	#5,TxtSwch
	bne	FadeEnd
	lea	ColLst4(pc),a1
	moveq	#15,d4
	bsr	DoFades
	tst.b	d4
	bne	FadeEnd
	addq.b	#1,TxtSwch
	rts

;--------------------------------------;

DoWait1	cmp.b	#3,TxtSwch
	bne	WaitEnd
	subq.w	#1,WaitFlg
	bne	WaitEnd
	move.w	#8*50,WaitFlg
	addq.b	#1,TxtSwch
WaitEnd	rts

;--------------------------------------;

DoFades	lea	Colours+2(pc),a0
	moveq	#4,d7

FRed	moveq	#0,d3
	move.w	(a1)+,d0

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$0f00,d1
	and.w	#$0f00,d2
	cmp.w	d1,d2
	beq	FRNone
	blt.b	SubRed
	sub.w	#$0100,d2
	bra	FGreen
SubRed	add.w	#$0100,d2
	bra	FGreen
FRNone	subq.b	#1,d4
FGreen	add.w	d2,d3
	move.w	(a0),d2

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$00f0,d1
	and.w	#$00f0,d2
	cmp.w	d1,d2
	beq	FGNone
	blt.b	SubGrn
	sub.w	#$0010,d2
	bra	FBlue
SubGrn	add.w	#$0010,d2
	bra	FBlue
FGNone	subq.b	#1,d4
FBlue	add.w	d2,d3
	move.w	(a0),d2

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$000f,d1
	and.w	#$000f,d2
	cmp.w	d1,d2
	beq	FBNone
	blt.b	SubBlu
	sub.w	#$0001,d2
	bra	FFinshd
SubBlu	add.w	#$0001,d2
	bra	FFinshd
FBNone	subq.b	#1,d4
FFinshd	add.w	d2,d3
	move.w	(a0),d2

	move.w	d3,(a0)
	addq.l	#4,a0
	dbf	d7,FRed
FadeEnd	rts

;--------------------------------------;

DoLoop1	cmp.b	#6,TxtSwch
	bne	LoopEnd
	move.b	#0,TxtSwch
LoopEnd	rts

;--------------------------------------;

Music	include	"DH2:MarantzIntro2/ProRunner2.0.i"

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0
SBlank	dcb.b	40,0
Object	dc.l	D_Shape
SurfCol	dc.w	0
AngSkpX	dc.w	AngleSkipX
AngSkpY	dc.w	AngleSkipY
AngSkpZ	dc.w	AngleSkipZ
AngleX	dc.w	45
AngleY	dc.w	0
AngleZ	dc.w	0
CurScrn	dc.l	Screen1
WrkScrn	dc.l	Screen2
LineCnt	dc.w	0
SpeedNo	dc.w	0
TxtSwch	dc.b	0
	even
WaitFlg	dc.w	8*50
TextPnt	dc.l	Text
ScrnPnt	dc.l	TxtArea

;--------------------------------------;

CList	dc.w	$008e,$1c81,$0090,$40c1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0106,$0000,$01fc,$0000

SPR1	dc.w	$0120,$0000,$0122,$0000
	dc.w	$0124,$0000,$0126,$0000
SPR2	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
SPR3	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000

	dc.w	$01a2,$0cdf,$01aa,$0337
	dc.w	$01ac,$076f,$01ae,$0edf

	dc.w	$0180,$0000,$0182,$000a
	dc.w	$0184,$000f,$018a,$0ccf
	dc.w	$018c,$0fff

Colours	dc.w	$0190,$0000
	dc.w	$0192,$000a,$0194,$000f
	dc.w	$019a,$0ccf,$019c,$0fff

BPL5	dc.w	$00ec,$0000,$00ee,$0000

	dc.w	$2007,$fffe,$0100,$4200
	dc.w	$0108,$0000,$010a,$0000
BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000

CopMve1	dc.w	$9807,$fffe,$0100,$4200
BPL2	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000

PlArea1	dc.w	$ffdf,$fffe
CopMve2	dc.w	$1007,$fffe,$0100,$4200
BPL3	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000

PlArea2	dc.w	$01fe,$fffe
	dc.w	$4007,$fffe,$0100,$1200
SPRBPL	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$0108,$ffd8
	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

D_Shape	dc.l	L_Shape
	dc.w	13
	dc.w	-50,-50,-50
	dc.w	-50,-50, 50
	dc.w	 50,-50, 50
	dc.w	 50,-50,-50
	dc.w	-50, 00, 00
	dc.w	 00, 00, 50
	dc.w	 50, 00, 00
	dc.w	-50, 50,-50
	dc.w	-50, 50, 50
	dc.w	 50, 50, 50
	dc.w	 50, 50,-50
	dc.w	 00, 50, 00
	dc.w	 00, 00,-50
	dc.w	 00,-50, 00

L_Shape	dc.w	23
	dc.w	1,00,01,04,00
	dc.w	2,01,08,04,01
	dc.w	1,08,07,04,08
	dc.w	2,07,00,04,07
	dc.w	2,01,02,05,01
	dc.w	1,02,09,05,02
	dc.w	2,09,08,05,09
	dc.w	1,08,01,05,08
	dc.w	1,02,03,06,02
	dc.w	2,03,10,06,03
	dc.w	1,10,09,06,10
	dc.w	2,09,02,06,09
	dc.w	1,08,09,11,08
	dc.w	2,09,10,11,09
	dc.w	1,10,07,11,10
	dc.w	2,07,08,11,07
	dc.w	2,07,10,12,07
	dc.w	1,10,03,12,10
	dc.w	2,03,00,12,03
	dc.w	1,00,07,12,00
	dc.w	1,00,03,13,00
	dc.w	2,03,02,13,03
	dc.w	1,02,01,13,02
	dc.w	2,01,00,13,01

CrdTble	dcb.w	3*14,0

;--------------------------------------;

Bar1	dc.w	$206f,$8000
	REPT	64
	dc.w	$c000,$0000
	ENDR
	dc.w	$4000,$0000,$c000,$0000,$c000,$0000,$4000,$0000
	dc.w	$0000,$0000,$c000,$0000,$c000,$0000,$8000,$0000
	dc.w	$0000,$0000,$0000,$0000,$8000,$0000,$4000,$0000
	dc.w	$c000,$0000,$0000,$0000,$8000,$0000,$4000,$0000
	dc.w	$4000,$0000,$0000,$0000,$8000,$0000,$c000,$0000
	dc.w	$0000,$0000,$4000,$0000,$8000,$0000,$0000,$0000
	dc.w	$8000,$0000,$0000,$0000,$4000,$0000,$4000,$0000
	dc.w	$0000,$0000,$8000,$0000,$8000,$0000,$4000,$0000
	dc.w	0,0

Bar2	dc.w	$e0b1,$4002
	dc.w	$4000,$0000,$8000,$0000,$8000,$0000,$0000,$0000
	dc.w	$4000,$0000,$4000,$0000,$0000,$0000,$8000,$0000
	dc.w	$0000,$0000,$8000,$0000,$4000,$0000,$0000,$0000
	dc.w	$c000,$0000,$8000,$0000,$0000,$0000,$4000,$0000
	dc.w	$4000,$0000,$8000,$0000,$0000,$0000,$c000,$0000
	dc.w	$4000,$0000,$8000,$0000,$0000,$0000,$0000,$0000
	dc.w	$8000,$0000,$c000,$0000,$c000,$0000,$0000,$0000
	dc.w	$4000,$0000,$c000,$0000,$c000,$0000,$4000,$0000
	REPT	64
	dc.w	$c000,$0000
	ENDR
	dc.w	0,0

;--------------------------------------;

SpdList	dc.b	$78,$78,$79,$79,$79,$7a,$7a,$7a,$7b,$7b
	dc.b	$7b,$7c,$7c,$7c,$7c,$7d,$7d,$7d,$7d,$7e
	dc.b	$7e,$7e,$7e,$7f,$7f,$7f,$7f,$80,$80,$80
	dc.b	$80,$80,$81,$81,$81,$81,$81,$81,$81,$81
	dc.b	$82,$82,$82,$82,$82,$82,$82,$82,$82,$82
	dc.b	$82,$82,$82,$82,$82,$82,$82,$82,$82,$82
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81,$80,$80
	dc.b	$80,$80,$80,$7f,$7f,$7f,$7f,$7e,$7e,$7e
	dc.b	$7e,$7d,$7d,$7d,$7d,$7c,$7c,$7c,$7c,$7b
	dc.b	$7b,$7b,$7a,$7a,$7a,$79,$79,$79,$78,$78
	dc.b	$78,$78,$77,$77,$77,$76,$76,$76,$75,$75
	dc.b	$75,$74,$74,$74,$74,$73,$73,$73,$73,$72
	dc.b	$72,$72,$72,$71,$71,$71,$71,$70,$70,$70
	dc.b	$70,$70,$6f,$6f,$6f,$6f,$6f,$6f,$6f,$6f
	dc.b	$6e,$6e,$6e,$6e,$6e,$6e,$6e,$6e,$6e,$6e
	dc.b	$6e,$6e,$6e,$6e,$6e,$6e,$6e,$6e,$6e,$6e
	dc.b	$6f,$6f,$6f,$6f,$6f,$6f,$6f,$6f,$70,$70
	dc.b	$70,$70,$70,$71,$71,$71,$71,$72,$72,$72
	dc.b	$72,$73,$73,$73,$73,$74,$74,$74,$74,$75
	dc.b	$75,$75,$76,$76,$76,$77,$77,$77,$78,$78

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

ColLst1	dc.w	$0fff,$0fff,$0fff,$0fff,$0fff
ColLst2	dc.w	$0aaf,$0aaf,$0aaf,$0aaf,$0aaf
ColLst3	dc.w	$0fff,$0fff,$0fff,$0fff,$0fff
ColLst4	dc.w	$0000,$000a,$000f,$0ccf,$0fff

;--------------------------------------;

RbSprte	dc.w	$15cc,$1f06
	dc.w	$71fc,$fbfe,$1a56,$0a02,$3a56,$725c,$6a56,$4a52
	dc.w	$4a52,$4a52,$0bd2,$4a52,$499c,$0bdf,$0800,$0800
	dc.w	$0000,$0800,$0800,$0000

	dc.w	$15d4,$1f06
	dc.w	$7c7e,$feff,$c6c3,$8281,$6276,$f2ef,$32cb,$1289
	dc.w	$1289,$1289,$3281,$1289,$e261,$f2f1,$0201,$0201
	dc.w	$0000,$0201,$0201,$0000

;--------------------------------------;

Text	include	"DH2:MarantzIntro2/Marantz.txt"
TextEnd	even
Page	dcb.b	104*(320/8),0
TxtArea	dcb.b	11*8*(320/8),0

	dcb.b	3*120*(320/8),0
Screen1	dcb.b	3*120*(320/8),0
	dcb.b	3*120*(320/8),0
Screen2	dcb.b	3*120*(320/8),0
	dcb.b	3*120*(320/8),0
Font	incbin	"DH2:MarantzIntro2/Font.raw"
pr_Data	incbin	"DH2:MarantzIntro2/mod.Dance On Steel"
