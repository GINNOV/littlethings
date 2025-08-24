	SECTION	"Frantic - B13Intro 1",CODE_C

;--------------------------------------;

WaitBlt	MACRO
	tst.b	2(a5)
.WB\@	btst	#6,2(a5)
	bne.b	.WB\@
	ENDM

;--------------------------------------;

Start	move.l	4.w,a6
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

	bsr.w	mt_init

	move.l	#Picture,d0
	lea	BPL1(pc),a0
	moveq	#2-1,d7
.1	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*(320/8),d0
	addq.l	#8,a0
	dbf	d7,.1

	move.l	#Screen1+(42*(320/8)),d0
	lea	BPL2(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.l	#Screen3,d0
	lea	BPL3(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.l	#SclArea,d0
	lea	BPL4(pc),a0
	moveq	#2-1,d7
.2	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#(656/8),d0
	addq.l	#8,a0
	dbf	d7,.2

	move.l	#Frantic,d0
	lea	BPL5(pc),a0
	moveq	#2-1,d7
.3	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#12*(32/8),d0
	addq.l	#8,a0
	dbf	d7,.3

	move.w	$7c(a5),d0
	cmp.b	#$f8,d0
	bne.b	.NonAGA
	move.w	#0,$106(a5)
	move.w	#0,$1fc(a5)

.NonAGA	bsr.w	.GetVBR
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

.Mouse	btst	#6,$bfe001
	bne.b	.Mouse

	bsr.w	mt_end
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

.GetVBR	sub.l	a4,a4
	move.l	4.w,a6
	btst	#0,297(a6)
	beq.b	.VBR1
	lea	.VBR2(pc),a5
	jsr	-30(a6)
.VBR1	rts

.VBR2	dc.w	$4e7a,$c801
;	movec	vbr,a4
	rte

;--------------------------------------;

NewIRQ	movem.l	d0-a6,-(a7)
;	btst	#2,$dff016
;	beq.b	Pause

	bsr.b	MoveObj
	bsr.w	Burning
	bsr.w	SwpScrn
	bsr.w	NwAngle
	bsr.w	RotPnts
	bsr.w	PtvPnts
	bsr.w	DoLines
	bsr.w	BltScrl
	bsr.w	mt_music

Pause	movem.l	(a7)+,d0-a6
;	move.w	#$00f0,$180(a5)
	move.w	#$0020,$9c(a5)
	rte

;--------------------------------------;

MoveObj	moveq	#0,d0
	moveq	#0,d1
	lea	SinTble(pc),a0
	lea	CosTble(pc),a1
	movem.w	XYSteps(pc),d0-d1
	move.w	(a0,d0),d0
	move.w	(a1,d1),d1
	muls	#60,d0
	muls	#30,d1
	asr.l	#8,d0
	asr.l	#6,d0
	asr.l	#8,d1
	asr.l	#6,d1
	move.w	d0,XYOffst
	move.w	d1,XYOffst+2

	lea	XYSteps(pc),a0
	moveq	#2-1,d7
.1	move.w	(a0),d0
	add.w	4(a0),d0
	cmp.w	#360*2,d0
	blt.b	.2
	sub.w	#360*2,d0
.2	move.w	d0,(a0)
	addq.l	#2,a0
	dbf	d7,.1
	rts

;--------------------------------------;

Burning	WaitBlt	
	move.l	#$0fdc0000,$40(a5)
	move.l	#$ffffffff,$44(a5)
	move.l	#Screen3+(320/8),$50(a5)
	move.l	CurScrn(pc),d0
	add.l	#(42*(320/8)),d0
	move.l	d0,$4c(a5)
	move.l	#Static,$48(a5)
	move.l	#Screen3,$54(a5)
	move.l	#0,$64(a5)
	move.l	#0,$60(a5)
	move.w	#169<<6+(320/16),$58(a5)
	rts

;--------------------------------------;

SwpScrn	movem.l	CurScrn(pc),d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,CurScrn

	add.l	#(42*(320/8)),d0
	lea	BPL2(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	WrkScrn(pc),d0
	add.l	#(42*(320/8)),d0
	move.l	d0,$54(a5)
	move.w	#170<<6+(320/16),$58(a5)
	rts

;--------------------------------------;

NwAngle	lea	Angles(pc),a0
	move.w	#360,d1
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
	lea	P_Box(pc),a2
	lea	CrdTble(pc),a3
	lea	Angles(pc),a4

	moveq	#5-1,d7
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

PtvPnts	lea	CrdTble(pc),a0
	lea	PrjOrgn(pc),a1
	moveq	#5-1,d7
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
	add.w	XYOffst(pc),d0
	add.w	XYOffst+2(pc),d1
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

	lea	CrdTble(pc),a0
	lea	L_Box(pc),a1
	move.l	WrkScrn(pc),a2
	moveq	#5-1,d7

.1	move.w	(a1)+,d6
	bsr	HidLine
	blt	.3
.2	move.w	(a1)+,d4
	move.w	(a0,d4),d0
	move.w	2(a0,d4),d1
	move.w	(a1),d4
	move.w	(a0,d4),d2
	move.w	2(a0,d4),d3
	bsr.b	DrawLne
	dbf	d6,.2
	addq.l	#2,a1
	dbf	d7,.1
	rts
.3	addq.w	#2,d6
	lsl.w	#1,d6
	lea	(a1,d6),a1
	dbf	d7,.1
	rts

;--------------------------------------;

;	HIDDEN LINES
;	~~~~~~~~~~~~
;	(Y2-Y3)*(X1-X2)-(Y1-Y2)*(X2-X3)
;	IF POSITIVE THEN DRAW IT

HidLine	move.w	(a1),d5
	move.w	(a0,d5),d0
	move.w	2(a0,d5),d1
	move.w	2(a1),d5
	move.w	(a0,d5),d2
	move.w	2(a0,d5),d3

	move.w	4(a1),d5
	move.w	(a0,d5),d4
	move.w	2(a0,d5),d5
	sub.w	d2,d0
	sub.w	d4,d2
	sub.w	d3,d1
	sub.w	d5,d3
	muls	d1,d2
	muls	d3,d0
	cmp.w	d2,d0
	rts

;--------------------------------------;

DrawLne	movem.l	d0-d3/a2,-(a7)
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

;	move.b	d4,d5			;;
;	not.b	d5			;;

	lsr.w	#3,d0
	add.w	d0,a2
	ror.w	#4,d4
	or.w	#$bca,d4		;;
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
;	bchg	d5,(a2)			;;

	move.l	d4,$40(a5)
	move.l	d2,$62(a5)
	move.l	a2,$48(a5)
	move.w	d0,(a3)+
	move.l	a2,(a3)+
	move.w	d3,(a3)
	movem.l	(a7)+,d0-d3/a2
	rts

SML	=	0 ;0 = LINE, 2 = FILL	;;
Octants	dc.b	SML+01,SML+01+$40
	dc.b	SML+17,SML+17+$40
	dc.b	SML+09,SML+09+$40
	dc.b	SML+21,SML+21+$40

;--------------------------------------;

BltScrl	subq.w	#1,Counter
	bne.b	.5
	move.w	#8,Counter

.1	lea	SclText(pc),a0
	move.w	ScrlPnt(pc),d0
	moveq	#0,d1
	move.b	(a0,d0),d1
	bne.s	.2
	move.w	d1,ScrlPnt
	bra.s	.1

.2	moveq	#0,d0
	lea	CharSet(pc),a0
	bra.b	.4
.3	addq.b	#2,d0
.4	cmp.b	(a0)+,d1
	bne.b	.3
	lea	Font(pc),a0
	lea	(a0,d0),a0

	WaitBlt
	move.l	#$09f00000,$40(a5)
	move.l	#$ffffffff,$44(a5)
	move.l	a0,$50(a5)
	move.l	#SclArea+(640/8),$54(a5)
	move.w	#((672-16)/8),$64(a5)
	move.w	#(640/8),$66(a5)
	move.w	#2*16<<6+(16/16),$58(a5)
	addq.w	#1,ScrlPnt

.5	WaitBlt
	move.l	#$e9f00000,$40(a5)
	move.l	#$ffffffff,$44(a5)
	move.l	#SclArea,$50(a5)
	move.l	#SclArea-(16/8),$54(a5)
	move.l	#0,$64(a5)
	move.w	#2*16<<6+(656/16),$58(a5)
	rts

;--------------------------------------;

Music	include	"DH1:B13Intro1/ProTracker2.3A.i"

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0
CurScrn	dc.l	Screen1
WrkScrn	dc.l	Screen2
XYSteps	dc.w	0,0,2*2,3*2
XYOffst	dc.w	0,0
Angles	dc.w	20,50,0,1,2,2
PrjOrgn	dc.w	160,128,600
Counter	dc.w	1
ScrlPnt	dc.w	0
CharSet	dc.b	"ABCDEFGHIJKLMNOPQRSTUVWXYZ.,'!* 1234567890"

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$003f
	dc.w	$0108,$0000,$010a,$0000
PicCols	dc.w	$0180,$0446,$0182,$0112
	dc.w	$0184,$0000,$0186,$0224

	dc.w	$2c07,$fffe,$0100,$2200
BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000

	dc.w	$5407,$fffe,$0100,$0200
	dc.w	$5507,$fffe,$0182,$0446
	dc.w	$0184,$0446,$0186,$0446
	dc.w	$5607,$fffe,$0100,$2200
BPL2	dc.w	$00e0,$0000,$00e2,$0000
BPL3	dc.w	$00e4,$0000,$00e6,$0000

	dc.w	$5707,$fffe,$0182,$0557
	dc.w	$0184,$0535,$0186,$0557
	dc.w	$5807,$fffe,$0182,$0557
	dc.w	$0184,$0635,$0186,$0557
	dc.w	$5907,$fffe,$0182,$0557
	dc.w	$0184,$0735,$0186,$0557
	dc.w	$5a07,$fffe,$0182,$0557
	dc.w	$0184,$0835,$0186,$0557

	dc.w	$fc07,$fffe,$0182,$0557
	dc.w	$0184,$0735,$0186,$0557
	dc.w	$fd07,$fffe,$0182,$0557
	dc.w	$0184,$0635,$0186,$0557
	dc.w	$fe07,$fffe,$0182,$0557
	dc.w	$0184,$0535,$0186,$0557
	dc.w	$ff07,$fffe,$0100,$0200

	dc.w	$ffe1,$fffe
	dc.w	$0092,$003c,$0094,$00d4
	dc.w	$0108,$0054,$010a,$0054
	dc.w	$0007,$fffe,$0180,$0000
	dc.w	$0107,$fffe,$0180,$0aaa
	dc.w	$0207,$fffe
FntCols	dc.w	$0180,$0fff,$0182,$0555
	dc.w	$0184,$0000,$0186,$0aaa

	dc.w	$0807,$fffe,$0100,$a200
BPL4	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$1807,$fffe,$0100,$0200

	dc.w	$1f07,$fffe,$0180,$0aaa
	dc.w	$2007,$fffe,$0180,$0000
	dc.w	$2107,$fffe
FTCCols	dc.w	$0180,$0446,$0182,$0779
	dc.w	$0184,$0bbc,$0186,$0fff
	dc.w	$0092,$00c8,$0094,$00d0
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$2207,$fffe,$0100,$2200
BPL5	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$2c07,$fffe,$0100,$0200

	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

P_Box	dc.w	 000, 000,-100
	dc.w	-100,-100, 100
	dc.w	 100,-100, 100
	dc.w	 100, 100, 100
	dc.w	-100, 100, 100

L_Box	dc.w	3-1,6*0,6*1,6*2,6*0
	dc.w	3-1,6*0,6*2,6*3,6*0
	dc.w	3-1,6*0,6*3,6*4,6*0
	dc.w	3-1,6*0,6*4,6*1,6*0
	dc.w	4-1,6*4,6*3,6*2,6*1,6*4

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

SclText	dc.b	"B13,  PO BOX 35712, BROWNS BAY, AUCKLAND, NEW ZEALAND    "
	dc.b	"SUPPORT BBS,  SILICON TATTOO,  "
	dc.b	"NODE1. 649 6265622   "
	dc.b	"NODE2. 649 6265614   "
	dc.b	"     "
	even
Font	inciffi	"DH1:B13Intro1/Font.iff",FntCols
Frantic	inciff	"DH1:B13Intro1/Frantic.iff",FTCCols
Picture	inciff	"DH1:B13Intro1/B13.iff",PicCols
Screen1	dcb.b	256*(320/8),0
Screen2	dcb.b	256*(320/8),0
Screen3	dcb.b	170*(320/8),0
SclArea	dcb.b	2*16*(656/8),0
Static	inciff	"DH1:B13Intro1/Static.iff"
mt_data	incbin	"DH0:Modules/mod.Intro Number 64"

;--------------------------------------;

	SECTION	"File Identification",DATA

	dc.l	"FLID"
	dc.b	"_______         ____     __ __    _______",10
	dc.b	"_____  \_______|   /__/\|  |  |  /  ____ \",10
	dc.b	"/  ____/  ____ | _/  ____  _  | / _ \|  l \",10
	dc.b	"\   \______ \/   \      \  |  |/  |  \     \",10
	dc.b	" \  _\/   \  \_  _\  ___/__|  _______ \  __/",10
	dc.b	"  \/  \______/ \/  \/       \/       \/\/",10
	dc.b	"   [pSYCHAd pRODUCTIONs pROUDLy pRESENTs]",10
	dc.b	"v------------------------------------------v",10
	dc.b	"|     BULLETIN 13 INTRO   CODE:FRANTIC     |",10
	dc.b	"^------------------------------------------^",10
	dc.b	0

	END
