AngleValX = 0
AngleValY = 0
AngleValZ = 0
AngleSkpX = 1
AngleSkpY = 2
AngleSkpZ = 3
PositionX = 0
PositionY = 0
PositionZ = 1500

	SECTION	"Frantic - Dragon Ball Slow as Hell",CODE_C

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

	move.l	#Screen1,d0
	lea	BPLScrn(pc),a0
	moveq	#3-1,d7
.2	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#180*(256/8),d0
	addq.l	#8,a0
	dbf	d7,.2

	move.w	$7c(a5),d0
	cmp.b	#$f8,d0
	bne.b	.NonAGA
	move.w	#$0000,$106(a5)
	move.w	#$0011,$10c(a5)
	move.w	#$0000,$1fc(a5)

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
	beq.w	.VBR1
	lea	.VBR2(pc),a5
	jsr	-30(a6)
.VBR1	rts

.VBR2	dc.w	$4e7a,$c801
	rte

;--------------------------------------;

NewIRQ	movem.l	d0-a6,-(a7)
	btst	#2,$dff016
	beq	Pause
	bsr	SwpScrn
	bsr	ShwElps
	bsr	NwAngle
	bsr	RotPnts
	bsr	PtvPnts
	bsr	PltElps
	bsr	DoLines
	bsr	FillScn

Pause	movem.l	(a7)+,d0-a6
;	move.w	#$00f0,$180(a5)
	move.w	#$0020,$9c(a5)
	rte

;--------------------------------------;

SwpScrn	movem.l	CurScrn(pc),d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,CurScrn

	lea	BPLScrn(pc),a0
	moveq	#3-1,d7
.1	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#180*(256/8),d0
	addq.l	#8,a0
	dbf	d7,.1

	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$000c,$66(a5)
	move.l	WrkScrn(pc),a0
	lea	6(a0),a0
	move.l	a0,$54(a5)
	move.w	#3*180<<6+(160/16),$58(a5)
	rts

;--------------------------------------;

NwAngle	lea	Angles(pc),a0
	move.w	#360,d1
	moveq	#3-1,d7
.1	move.w	(a0),d0
	add.w	6(a0),d0
	cmp.w	d1,d0
	blt	.2
	sub.w	d1,d0
.2	move.w	d0,(a0)+
	dbf	d7,.1
	rts

;--------------------------------------;

ShwElps	lea	SinList(pc),a0
	moveq	#0,d0
	move.b	SinPntr(pc),d0
	move.b	(a0,d0),d0
	addq.b	#1,SinPntr
	and.b	#$7f,SinPntr
	lea	ElpsDat(pc),a0
	move.w	d0,2(a0)
	move.w	#180,d1
	sub.w	d0,d1
	moveq	#100,d2
	move.w	d2,4(a0)
	move.w	d2,6(a0)
	cmp.w	d2,d1
	bge	.1
	move.w	d1,6(a0)
	move.w	d2,d0
	sub.w	d1,d2
	add.w	d2,d0
	move.w	d0,4(a0)
.1	rts

PltElps	WaitBlt
	lea	ElpsDat(pc),a0
	lea	CrcList(pc),a1
	move.l	WrkScrn(pc),a2
	moveq	#0,d0
	moveq	#0,d1
	move.w	6(a0),d7
	move.w	2(a0),d4
	subq.w	#1,d7

.1	moveq	#0,d2
	move.b	(a1,d1),d2
	mulu	4(a0),d2
	lsr.l	#8,d2
	move.w	(a0),d3
	sub.w	d2,d3
	bsr	WrtePix
	move.w	(a0),d3
	add.w	d2,d3
	bsr	WrtePix

	addq.w	#1,d0
	move.l	d0,d1
	lsl.w	#8,d1
	divu	6(a0),d1
	addq.w	#1,d4
	dbf	d7,.1
	rts

;--------------------------------------;

WrtePix	move.w	d4,d5
	lsl.w	#5,d5
	lea	(a2,d5),a3
	move.w	d3,d5
	not.b	d3
	lsr.w	#3,d5
	bset	d3,(a3,d5)
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
	lea	Coords(pc),a2
	lea	CrdTble(pc),a3
	lea	Angles(pc),a4
	move.w	#Points-1,d7
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
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2

	move.w	#Points-1,d7
.1	moveq	#0,d3
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
	beq.b	.2
	divs	d5,d3
	divs	d5,d4

.2	move.w	d3,(a0)
	move.w	d4,2(a0)
	addq.l	#6,a0
	dbf	d7,.1
	rts

;--------------------------------------;

DoLines	moveq	#(256/8),d0
	moveq	#-1,d1

	WaitBlt
	move.w	d1,$44(a5)
	move.w	d1,$72(a5)
	move.w	#$8000,$74(a5)
	move.w	d0,$60(a5)
	move.w	d0,$66(a5)

	lea	CrdTble(pc),a0
	lea	LneTble(pc),a1
	lea	ElpsDat(pc),a4
	moveq	#6-1,d6
.2	move.l	WrkScrn(pc),a2
	lea	180*(256/8)(a2),a2
	move.w	(a1),d0
	tst.w	4(a0,d0)
	bmi	.3
	lea	180*(256/8)(a2),a2
.3	moveq	#10-1,d7

.1	move.w	(a1)+,d1
	move.w	(a0,d1),d0
	move.w	2(a0,d1),d1
	move.w	4(a4),d4
	muls	d4,d0
	divs	#100,d0
	add.w	#128,d0
	move.w	6(a4),d4
	muls	d4,d1
	divs	#100,d1
	lsr.w	#1,d4
	add.w	2(a4),d1
	add.w	d4,d1

	move.w	(a1)+,d3
	move.w	(a0,d3),d2
	move.w	2(a0,d3),d3

	move.w	4(a4),d4
	muls	d4,d2
	divs	#100,d2
	add.w	#128,d2
	move.w	6(a4),d4
	muls	d4,d3
	divs	#100,d3
	lsr.w	#1,d4
	add.w	2(a4),d3
	add.w	d4,d3

	bsr.b	DrawLne

	dbf	d7,.1
	dbf	d6,.2
	rts

;--------------------------------------;

DrawLne	movem.l	a2,-(a7)
	cmp.w	d1,d3
	bge.s	.1
	exg	d0,d2
	exg	d1,d3

.1	sub.w	d1,d3
	asl.w	#5,d1
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

	move.l	(a7)+,a2
	rts

SML	=	2 ;0 = LINE, 2 = FILL	;;
Octants	dc.b	SML+01,SML+01+$40
	dc.b	SML+17,SML+17+$40
	dc.b	SML+09,SML+09+$40
	dc.b	SML+21,SML+21+$40

;--------------------------------------;

FillScn	move.l	WrkScrn(pc),a0
	lea	3*180*(256/8)-6-2(a0),a0
	move.l	#$000c000c,d0

	WaitBlt
	move.l	#$09f00012,$40(a5)
	move.l	d0,$64(a5)
	move.l	a0,$50(a5)
	move.l	a0,$54(a5)
	move.w	#3*180<<6+(160/16),$58(a5)
	rts

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0
SinPntr	dc.b	128
CurScrn	dc.l	Screen1
WrkScrn	dc.l	Screen2
ElpsDat	dc.w	128,0,100,100
Angles	dc.w	AngleValX,AngleValY,AngleValZ
	dc.w	AngleSkpX,AngleSkpY,AngleSkpZ
PrjOrgn	dc.w	PositionX,PositionY,PositionZ

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0042,$0094,$00b4
	dc.w	$0102,$0000,$0104,$003f
	dc.w	$0108,$0000,$010a,$0000

	dc.w	$0180,$0848
	dc.w	$2c07,$fffe,$0180,$0fff
	dc.w	$2d07,$fffe
	dc.w	$0180,$088d,$0182,$055a
	dc.w	$0184,$088d,$0186,$0d44
	dc.w	$0188,$088d,$018a,$0d44
	dc.w	$018c,$088d,$018e,$0d44

BPLScrn	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
CopStrt	dc.w	$7807,$fffe,$0100,$3200

	dc.w	$ffe1,$fffe
	dc.w	$0007,$fffe
	dc.w	$0180,$077c,$0182,$0449
	dc.w	$0184,$077c,$0186,$0d44
	dc.w	$0188,$077c,$018a,$0d44
	dc.w	$018c,$077c,$018e,$0d44
	dc.w	$2c07,$fffe,$0100,$0200
	dc.w	$2d07,$fffe,$0180,$0fff
	dc.w	$2e07,$fffe,$0180,$0848

	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

Points	= 60
Coords	dc.w	 000, 100, 278
	dc.w	 029, 040, 278
	dc.w	 095, 031, 278
	dc.w	 048,-015, 278
	dc.w	 059,-081, 278
	dc.w	 000,-050, 278
	dc.w	-059,-081, 278
	dc.w	-048,-015, 278
	dc.w	-095, 031, 278
	dc.w	-029, 040, 278

	dc.w	 000, 100,-278
	dc.w	 029, 040,-278
	dc.w	 095, 031,-278
	dc.w	 048,-015,-278
	dc.w	 059,-081,-278
	dc.w	 000,-050,-278
	dc.w	-059,-081,-278
	dc.w	-048,-015,-278
	dc.w	-095, 031,-278
	dc.w	-029, 040,-278

	dc.w	-278, 100, 000
	dc.w	-278, 040, 029
	dc.w	-278, 031, 095
	dc.w	-278,-015, 048
	dc.w	-278,-081, 059
	dc.w	-278,-050, 000
	dc.w	-278,-081,-059
	dc.w	-278,-015,-048
	dc.w	-278, 031,-095
	dc.w	-278, 040,-029

	dc.w	 278, 100, 000
	dc.w	 278, 040, 029
	dc.w	 278, 031, 095
	dc.w	 278,-015, 048
	dc.w	 278,-081, 059
	dc.w	 278,-050, 000
	dc.w	 278,-081,-059
	dc.w	 278,-015,-048
	dc.w	 278, 031,-095
	dc.w	 278, 040,-029

	dc.w	 000, 278, 100
	dc.w	 029, 278, 040
	dc.w	 095, 278, 031
	dc.w	 048, 278,-015
	dc.w	 059, 278,-081
	dc.w	 000, 278,-050
	dc.w	-059, 278,-081
	dc.w	-048, 278,-015
	dc.w	-095, 278, 031
	dc.w	-029, 278, 040

	dc.w	 000,-278, 100
	dc.w	 029,-278, 040
	dc.w	 095,-278, 031
	dc.w	 048,-278,-015
	dc.w	 059,-278,-081
	dc.w	 000,-278,-050
	dc.w	-059,-278,-081
	dc.w	-048,-278,-015
	dc.w	-095,-278, 031
	dc.w	-029,-278, 040

CrdTble	dcb.w	3*Points,0
LneTble
Count	SET	0
	REPT	6
	REPT	9
	dc.w	2*3*(Count),2*3*(Count+1)
Count	SET	Count+1
	ENDR
	dc.w	2*3*(Count),2*3*(Count-9)
Count	SET	Count+1
	ENDR

;--------------------------------------;

CrcList	dc.b	012,020,025,030,034,037,040,043,046,048,051,053,055,057,059,061
	dc.b	063,065,066,068,069,071,072,074,075,076,078,079,080,082,083,084
	dc.b	085,086,087,088,089,090,091,092,093,094,095,096,097,098,098,099
	dc.b	100,101,101,102,103,104,104,105,106,106,107,108,108,109,110,110
	dc.b	111,111,112,112,113,113,114,114,115,115,116,116,117,117,117,118
	dc.b	118,119,119,119,120,120,120,121,121,121,122,122,122,123,123,123
	dc.b	123,124,124,124,124,124,125,125,125,125,125,126,126,126,126,126
	dc.b	126,126,126,127,127,127,127,127,127,127,127,127,127,127,127,127
	dc.b	127,127,127,127,127,127,127,127,127,127,127,127,127,126,126,126
	dc.b	126,126,126,126,126,125,125,125,125,125,124,124,124,124,124,123
	dc.b	123,123,123,122,122,122,121,121,121,120,120,120,119,119,119,118
	dc.b	118,117,117,117,116,116,115,115,114,114,113,113,112,112,111,111
	dc.b	110,110,109,108,108,107,106,106,105,104,104,103,102,101,101,100
	dc.b	099,098,098,097,096,095,094,093,092,091,090,089,088,087,086,085
	dc.b	084,083,082,080,079,078,076,075,074,072,071,069,068,066,065,063
	dc.b	061,059,057,055,053,051,048,046,043,040,037,034,030,025,020,012

SinList	dc.b	$00,$00,$00,$01,$01,$02,$03,$04,$05,$06,$08,$0a,$0b,$0d,$0f,$11
	dc.b	$13,$16,$18,$1b,$1d,$20,$23,$25,$28,$2b,$2e,$31,$34,$37,$3b,$3e
	dc.b	$41,$44,$47,$4a,$4d,$50,$53,$56,$59,$5c,$5f,$62,$64,$67,$69,$6c
	dc.b	$6e,$70,$72,$74,$76,$77,$79,$7a,$7b,$7d,$7d,$7e,$7f,$7f,$80,$80
	dc.b	$80,$80,$80,$7f,$7f,$7e,$7d,$7c,$7b,$7a,$78,$76,$75,$73,$71,$6f
	dc.b	$6d,$6a,$68,$65,$63,$60,$5d,$5b,$58,$55,$52,$4f,$4c,$49,$45,$42
	dc.b	$3f,$3c,$39,$36,$33,$30,$2d,$2a,$27,$24,$21,$1e,$1c,$19,$17,$14
	dc.b	$12,$10,$0e,$0c,$0a,$09,$07,$06,$05,$03,$03,$02,$01,$01,$00,$00

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

Screen1	dcb.b	3*180*(256/8),0
Screen2	dcb.b	3*180*(256/8),0

	END
