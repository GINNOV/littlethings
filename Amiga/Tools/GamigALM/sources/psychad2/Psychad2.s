	SECTION	"Frantic - Psychad Intro2",CODE_C

;--------------------------------------;

WaitBlt	MACRO
	tst.b	2(a5)
WB\@	btst	#6,2(a5)
	bne.b	WB\@
	ENDM

;--------------------------------------;

Start	bsr.w	PutText
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

	move.l	#Screen1,d0
	lea	BPL1(pc),a0
	moveq	#2-1,d7
.2	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#160*(320/8),d0
	addq.l	#8,a0
	dbf	d7,.2

	move.l	#Picture,d0
	lea	BPL2(pc),a0
	moveq	#2-1,d7
.1	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#15*(320/8),d0
	addq.l	#8,a0
	dbf	d7,.1

	move.l	#TxtArea,d0
	lea	BPL3(pc),a0
	moveq	#2-1,d7
.3	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	addq.l	#8,a0
	dbf	d7,.3

	move.l	#Frantic,d0
	lea	BPL4(pc),a0
	moveq	#2-1,d7
.4	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#14*(640/8),d0
	addq.l	#8,a0
	dbf	d7,.4

	move.w	$7c(a5),d0
	cmp.b	#$f8,d0
	bne.b	NotAGA
	move.w	#0,$106(a5)
	move.w	#0,$1fc(a5)

NotAGA	bsr.w	GetVBR
	lea	$dff000,a5
	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	$6c(a4),OldIRQ
	move.l	#NewIRQ,$6c(a4)
	move.w	#$c020,$9a(a5)

	move.w	#$7fff,$96(a5)
	move.l  #CList,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$83d0,$96(a5)
	move.l	#0,$144(a5)

MousChk	btst	#6,$bfe001
	bne.b	MousChk

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

VBRExcp	movec	vbr,a4
	rte

;--------------------------------------;

NewIRQ	movem.l	d0-a6,-(a7)
	btst	#2,$dff016
	beq.b	Pause
	bsr.w	FdeText
	bsr.b	SwpScrn
	lea	Angles(pc),a0
	bsr.w	NwAngle
	lea	R_Box(pc),a2
	lea	CrdTble(pc),a3
	lea	Angles(pc),a4
	bsr.w	RotPnts
	lea	CrdTble(pc),a0
	lea	PrjOrgn(pc),a1
	lea	R_Box(pc),a2
	bsr.w	PtvPnts
	lea	CrdTble(pc),a0
	lea	L_Box(pc),a1
	bsr.w	DoLines
	bsr.w	FillObj
Pause	movem.l	(a7)+,d0-a6
;	move.w	#$00f0,$180(a5)
	move.w	#$0020,$9c(a5)
	rte

;--------------------------------------;

SwpScrn	movem.l	CurScrn(pc),d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,CurScrn

	lea	BPL1(pc),a0
	moveq	#2-1,d7
.1	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#160*(320/8),d0
	addq.l	#8,a0
	dbf	d7,.1

	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	WrkScrn(pc),$54(a5)
	move.w	#2*160<<6+(320/16),$58(a5)
	rts

;--------------------------------------;

NwAngle	move.w	#360,d1
	moveq	#2,d7
.1	move.w	(a0),d0
	add.w	6(a0),d0
	cmp.w	d1,d0
	blt.b	.2
	sub.w	d1,d0
.2	move.w	d0,(a0)+
	dbf	d7,.1
	rts

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

RotPnts	lea	SinTble(pc),a0
	lea	CosTble(pc),a1
	move.w	(a2)+,d7
.1	move.w	(a2)+,d0
	move.w	(a2)+,d1
	move.w	(a2)+,d2

	move.w	4(a4),d3
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

	move.w	2(a4),d3
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

	move.w	(a4),d3
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
	dbf	d7,.1
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

PtvPnts	move.w	(a2),d7
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2

.1	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	move.w	(a0),d0
	move.w	2(a0),d1
	move.w	4(a0),d2
	move.w	(a1),d3
	move.w	2(a1),d4
	move.w	4(a1),d5

	ext.l	d0
	asl.l	#8,d0
	ext.l	d1
	asl.l	#8,d1
	sub.w	d2,d5
	beq.b	.2
	divs	d5,d0
	divs	d5,d1

.2	add.w	d3,d0
	add.w	d4,d1
	move.w	d0,(a0)
	move.w	d1,2(a0)
	addq.l	#6,a0
	dbf	d7,.1
	rts

;--------------------------------------;

DoLines	moveq	#(320/8),d0
	moveq	#-1,d1

	WaitBlt
	move.w	d1,$44(a5)
	move.w	d1,$72(a5)
	move.w	#$8000,$74(a5)
	move.w	d0,$60(a5)
	move.w	d0,$66(a5)

	move.w	(a1)+,d7
.1	move.w	(a1)+,Surface
	move.w	(a1)+,d6
	bsr.w	HidLine
	sub.l	d2,d0
	blt.b	.5
.2	moveq	#0,d4
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

	btst	#0,Surface+1
	beq.b	.3
	move.l	WrkScrn(pc),a2
	bsr.b	DrawLne
.3	btst	#1,Surface+1
	beq.b	.4
	move.l	WrkScrn(pc),a2
	lea	160*(320/8)(a2),a2
	bsr.b	DrawLne
.4	dbf	d6,.2
	addq.l	#2,a1
	dbf	d7,.1
	rts
.5	addq.w	#2,d6
	add.w	d6,d6
	add.w	d6,a1
	dbf	d7,.1
	rts

;--------------------------------------;

DrawLne	movem.l	d0-d3,-(a7)
	cmp.w	d1,d3
	bge.s	.1
	exg	d0,d2
	exg	d1,d3

.1	sub.w	d1,d3
	move.l	d1,d4
	asl.l	#3,d1
	asl.l	#5,d4
	add.l	d4,d1
	ext.l	d1
	add.l	d1,a2
	moveq	#0,d1
	sub.w	d0,d2
	bge.s	.2
	addq.w	#2,d1

	neg.w	d2
.2	moveq	#$f,d4

	and.w	d0,d4

	move.b	d4,d5			;;
	not.b	d5			;;

	lsr.w	#3,d0
	add.w	d0,a2
	ror.w	#4,d4
	or.w	#$b4a,d4		;;
	swap	d4
	cmp.w	d2,d3
	bge.s	.3
	addq.w	#1,d1
	exg	d2,d3
.3	add.w	d2,d2
	move.w	d2,d0
	sub.w	d3,d0
	addx.w	d1,d1
	move.b	Octants(pc,d1),d4

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
	move.l	d5,d4
	add.l	d5,d5
	lsl.l	#2,d4
	add.l	d4,d5
	move.w	(a0,d5),d0
	move.w	2(a0,d5),d1
	moveq	#0,d5
	move.w	2(a1),d5
	move.l	d5,d4
	add.l	d5,d5
	lsl.l	#2,d4
	add.l	d4,d5
	move.w	(a0,d5),d2
	move.w	2(a0,d5),d3
	moveq	#0,d5
	move.w	4(a1),d5
	move.l	d5,d4
	add.l	d5,d5
	lsl.l	#2,d4
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
	lea	2*160*(320/8)-2(a0),a0
	moveq	#0,d0

	WaitBlt
	move.l	#$09f00012,$40(a5)
	move.l	d0,$64(a5)
	move.l	a0,$50(a5)
	move.l	a0,$54(a5)
	move.w	#2*160<<6+(320/16),$58(a5)
	rts

;--------------------------------------;

PutText	lea	Text(pc),a0
	lea	TxtArea+2*(320/8),a1
	moveq	#13-1,d7
.1	moveq	#40-1,d6
.2	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0)+,d1
	sub.b	#32,d1
	divu	#20,d1
	move.w	d1,d0
	swap	d1
	mulu	#16/8,d1
	mulu	#11*(320/8),d0
	lea	Font(pc),a2
	lea	(a2,d0),a2
	lea	(a2,d1),a2

	move.l	a1,a3
	moveq	#11-1,d5
.3	move.b	(a2),(a3)
	lea	40(a2),a2
	lea	40(a3),a3
	dbf	d5,.3
	addq.l	#1,a1
	dbf	d6,.2
	lea	(11-1)*(320/8)(a1),a1
	dbf	d7,.1
	rts

;--------------------------------------;

FdeText	subq.b	#1,FdeSwch
	bne.b	.1
	move.b	#4,FdeSwch
	lea	Colours+2(pc),a0
	lea	ColList(pc),a1
	moveq	#4-1,d7
	bsr.b	Fader
.1	rts

;-------------------;

Fader	move.w	(a1)+,d0
	moveq	#0,d3

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$0f00,d1
	and.w	#$0f00,d2
	cmp.w	d1,d2
	beq.b	.2
	blt.b	.1
	sub.w	#$0100,d2
	bra.b	.2
.1	add.w	#$0100,d2
.2	add.w	d2,d3

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$00f0,d1
	and.w	#$00f0,d2
	cmp.w	d1,d2
	beq.b	.4
	blt.b	.3
	sub.w	#$0010,d2
	bra.b	.4
.3	add.w	#$0010,d2
.4	add.w	d2,d3

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$000f,d1
	and.w	#$000f,d2
	cmp.w	d1,d2
	beq.b	.6
	blt.b	.5
	sub.w	#$0001,d2
	bra.b	.6
.5	add.w	#$0001,d2
.6	add.w	d2,d3

	move.w	d3,(a0)
	addq.l	#4,a0
	dbf	d7,Fader
	rts

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0
FdeSwch	dc.b	4
Surface	dc.w	0
CurScrn	dc.l	Screen1
WrkScrn	dc.l	Screen2
Angles	dc.w	45,25,0,1,1,1
PrjOrgn	dc.w	160,80,600
SurfCol	dc.w	0

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$003f
	dc.w	$0108,$0000,$010a,$0000

	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0003,$018a,$0003
	dc.w	$018c,$0003,$018e,$0003
	dc.w	$0190,$0005,$0192,$0005
	dc.w	$0194,$0005,$0196,$0005
	dc.w	$0198,$0007,$019a,$0007
	dc.w	$019c,$0007,$019e,$0007

	dc.w	$2c07,$fffe,$0100,$4200
BPL1	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000

	dc.w	$7407,$fffe
BPL2	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$0180,$0000,$0182,$0aaa
	dc.w	$0184,$0fff,$0186,$0555
	dc.w	$0188,$0003,$018a,$000d
	dc.w	$018c,$000f,$018e,$0008
	dc.w	$0190,$0005,$0192,$000f
	dc.w	$0194,$000f,$0196,$000a
	dc.w	$0198,$0007,$019a,$000f
	dc.w	$019c,$000f,$019e,$000c

	dc.w	$8307,$fffe
BPL3	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
Colours	dc.w	$0186,$0000,$018e,$0003
	dc.w	$0196,$0005,$019e,$0007

	dc.w	$cc07,$fffe,$0100,$2200
	dc.w	$ffe1,$fffe
	dc.w	$1f07,$fffe,$0100,$a200
BPL4	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$0092,$003c,$0094,$00d4
	dc.w	$0180,$0000,$0182,$0225
	dc.w	$0184,$055a,$0186,$088f
	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

ColList	dc.w	$0fff,$000f,$000f,$000f

;--------------------------------------;

R_Box	dc.w	8-1
	dc.w	-100,-100,-100
	dc.w	 100,-100,-100
	dc.w	 100, 100,-100
	dc.w	-100, 100,-100
	dc.w	-100,-100, 100
	dc.w	 100,-100, 100
	dc.w	 100, 100, 100
	dc.w	-100, 100, 100

L_Box	dc.w	6-1
	dc.w	1,4-1,0,1,2,3,0
	dc.w	1,4-1,5,4,7,6,5
	dc.w	2,4-1,4,0,3,7,4
	dc.w	2,4-1,1,5,6,2,1
	dc.w	3,4-1,4,5,1,0,4
	dc.w	3,4-1,3,2,6,7,3

CrdTble	dcb.w	3*8,0

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

Text	dc.b	"         P R O D U C T I O N S          "
	dc.b	"                                        "
	dc.b	"             PRESENT TO YOU             "
	dc.b	"         SHADOW OF THE BEAST 6          "
	dc.b	"                                        "
	dc.b	"      * CALL THESE ELITE BOARDS *       "
	dc.b	"                                        "
	dc.b	"    @ +649 1234567 @ +649 1234567 @     "
	dc.b	"    @ +649 1234567 @ +649 1234567 @     "
	dc.b	"    @ +649 1234567 @ +649 1234567 @     "
	dc.b	"    @ +649 1234567 @ +649 1234567 @     "
	dc.b	"    @ +649 1234567 @ +649 1234567 @     "
	dc.b	"                                        "
Font	incbin	"DH2:Psychad2/Font.raw"
Frantic	incbin	"DH2:Psychad2/Frantic.raw"
Picture	incbin	"DH2:Psychad2/Logo.raw"
Screen1	dcb.b	2*160*(320/8),0
Screen2	dcb.b	2*160*(320/8),0
TxtArea	dcb.b	156*(320/8),0


