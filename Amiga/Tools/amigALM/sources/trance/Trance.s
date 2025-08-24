	SECTION	"Robster - VexIntro2",CODE_C

AngleSkipX	= 1
AngleSkipY	= 2
AngleSkipZ	= 2
AngleValX	= 0
AngleValY	= 0
AngleValZ	= 0

PositionX	= 0
PositionY	= 0
PositionZ	= 5000

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

	lea	CurScrn(pc),a0
	lea	BPL1(pc),a1
	moveq	#4,d7
Pic2Cop	move.l	(a0),d0
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	addq.l	#8,a1
	addq.l	#8,a0
	dbf	d7,Pic2Cop

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
	move.w	#$e020,$9a(a5)

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
	beq.w	Pause
	bsr.b	SwpScrn
	lea	AngleX(pc),a4
	bsr.w	RotPnts
	lea	PrjOrgn(pc),a1
	bsr.w	PtvPnts
	bsr.w	DrwLnes
	lea	AngleX(pc),a0
	bsr.w	NwAngle
Pause	movem.l	(a7)+,d0-a6
;	move.w	#$00f0,$dff180
	move.w	#$0020,$dff09c
	rte

;--------------------------------------;

SwpScrn	movem.l	CurScrn(pc),d0-a1
	movem.l	d1-a1,CurScrn
	move.l	d0,WrkScrn

	lea	CurScrn(pc),a0
	lea	BPL1(pc),a1
	moveq	#4,d7
Scn2Cop	move.l	(a0),d0
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	addq.l	#8,a1
	addq.l	#8,a0
	dbf	d7,Scn2Cop

	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	WrkScrn(pc),$54(a5)
	move.w	#250<<6+20,$58(a5)
	rts

;--------------------------------------;

NwAngle	move.w	#360*2,d1
	moveq	#2,d7
AngLoop	move.w	(a0),d0
	add.w	6(a0),d0
	cmp.w	d1,d0
	blt.b	MoveAng
	sub.w	d1,d0
MoveAng	move.w	d0,(a0)+
	dbf	d7,AngLoop
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
	move.l	RotPntr(pc),a2
	lea	CrdTble(pc),a3
	move.w	(a2)+,d7
RotLoop	move.w	d7,-(a7)
	moveq	#0,d7
	move.w	(a2)+,d0
	move.w	(a2)+,d1
	move.w	(a2)+,d2

	move.w	4(a4),d3
	lsr.w	#1,d3
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
	addx.l	d7,d3
	asr.l	#6,d3
	addx.l	d7,d3
	asr.l	#8,d4
	addx.l	d7,d4
	asr.l	#6,d4
	addx.l	d7,d4
	move.w	d3,d1
	move.w	d4,d0

	move.w	2(a4),d3
	lsr.w	#1,d3
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
	addx.l	d7,d3
	asr.l	#6,d3
	addx.l	d7,d3
	asr.l	#8,d4
	addx.l	d7,d4
	asr.l	#6,d4
	addx.l	d7,d4
	move.w	d3,d0
	move.w	d4,d2

	move.w	(a4),d3
	lsr.w	#1,d3
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
	addx.l	d7,d3
	asr.l	#6,d3
	addx.l	d7,d3
	asr.l	#8,d4
	addx.l	d7,d4
	asr.l	#6,d4
	addx.l	d7,d4
	move.w	d3,d2
	move.w	d4,d1

	move.w	d0,(a3)+
	move.w	d1,(a3)+
	move.w	d2,(a3)+
	move.w	(a7)+,d7
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

PtvPnts	move.l	RotPntr(pc),a0
	move.w	(a0),d7
	lea	CrdTble(pc),a0
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

DrwLnes	moveq	#40,d0
	moveq	#-1,d1

	WaitBlt
	move.w	d1,$44(a5)
	move.w	d1,$72(a5)
	move.w	#$8000,$74(a5)
	move.w	d0,$60(a5)
	move.w	d0,$66(a5)

	lea	CrdTble(pc),a0
	move.l	LnePntr(pc),a1
	move.w	(a1)+,d7

DrawLp1	move.l	WrkScrn(pc),a4
	moveq	#3,d6
DrawLp2	move.l	a4,a2
	moveq	#0,d4
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
	add.w	#125,d1
	add.w	#160,d2
	add.w	#125,d3

	bsr.b	DrawLne
	dbf	d6,DrawLp2
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
	muls	#40,d1
	add.l	d1,a2
	moveq	#0,d1
	sub.w	d0,d2
	bge.s	xdpos
	addq.w	#2,d1

	neg.w	d2
xdpos	moveq	#$f,d4

	and.w	d0,d4

;	move.b	d4,d5
;	not.b	d5

	lsr.w	#3,d0
	add.w	d0,a2
	ror.w	#4,d4
	or.w	#$bca,d4
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
;	bchg	d5,(a2)

	move.l	d4,$40(a5)
	move.l	d2,$62(a5)
	move.l	a2,$48(a5)
	move.w	d0,(a3)+
	move.l	a2,(a3)+
	move.w	d3,(a3)
	movem.l	(a7)+,d0-d3
	rts

SML	= 0 	;0 = LINE, 2 = FILL
Octants	dc.b	SML+01,SML+01+$40
	dc.b	SML+17,SML+17+$40
	dc.b	SML+09,SML+09+$40
	dc.b	SML+21,SML+21+$40

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0
RotPntr	dc.l	R_Box
LnePntr	dc.l	L_Box
AngleX	dc.w	AngleValX
AngleY	dc.w	AngleValY
AngleZ	dc.w	AngleValZ
AngSkpX	dc.w	AngleSkipX
AngSkpY	dc.w	AngleSkipY
AngSkpZ	dc.w	AngleSkipZ
PrjOrgn	dc.w	PositionX
	dc.w	PositionY
	dc.w	PositionZ
CurScrn	dc.l	Screen1
	dc.l	Screen2
	dc.l	Screen3
	dc.l	Screen4
	dc.l	Screen5
	dc.l	Screen6
	dc.l	Screen7
	dc.l	Screen8
	dc.l	Screen9
WrkScrn	dc.l	Screen0

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$003f
	dc.w	$0108,$0000,$010a,$0000

	dc.w	$0180,$0023
	dc.w	$2d07,$fffe,$0180,$0fff
	dc.w	$2e07,$fffe

	dc.w	$0180,$0000,$0182,$0336
	dc.w	$0184,$0336,$0186,$0669
	dc.w	$0188,$0336,$018a,$0669
	dc.w	$018c,$0669,$018e,$099c
	dc.w	$0190,$0336,$0192,$0669
	dc.w	$0194,$0669,$0196,$099c
	dc.w	$0198,$0669,$019a,$099c
	dc.w	$019c,$099c,$019e,$0ccf
	dc.w	$01a0,$0336,$01a2,$0669
	dc.w	$01a4,$0669,$01a6,$099c
	dc.w	$01a8,$0669,$01aa,$099c
	dc.w	$01ac,$099c,$01ae,$0ccf
	dc.w	$01b0,$0669,$01b2,$099c
	dc.w	$01b4,$099c,$01b6,$0ccf
	dc.w	$01b8,$099c,$01ba,$0ccf
	dc.w	$01bc,$0ccf,$01be,$0fff

	dc.w	$2f07,$fffe,$0100,$5200
BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$00f0,$0000,$00f2,$0000

	dc.w	$ffe1,$fffe
	dc.w	$2907,$fffe,$0100,$0200
	dc.w	$2a07,$fffe,$0180,$0fff
	dc.w	$2b07,$fffe,$0180,$0023
	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

R_Box	dc.w	8-1
	dc.w	-90*12,-90*12,-90*12
	dc.w	 90*12,-90*12,-90*12
	dc.w	 90*12, 90*12,-90*12
	dc.w	-90*12, 90*12,-90*12
	dc.w	-90*12,-90*12, 90*12
	dc.w	 90*12,-90*12, 90*12
	dc.w	 90*12, 90*12, 90*12
	dc.w	-90*12, 90*12, 90*12

L_Box	dc.w	6-1			;Surfaces-1
	dc.w	0,1,2,3,0
	dc.w	5,4,7,6,5
	dc.w	4,0,3,7,4
	dc.w	1,5,6,2,1
	dc.w	4,5,1,0,4
	dc.w	3,2,6,7,3

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

Screen1	dcb.b	250*(320/8),0
Screen2	dcb.b	250*(320/8),0
Screen3	dcb.b	250*(320/8),0
Screen4	dcb.b	250*(320/8),0
Screen5	dcb.b	250*(320/8),0
Screen6	dcb.b	250*(320/8),0
Screen7	dcb.b	250*(320/8),0
Screen8	dcb.b	250*(320/8),0
Screen9	dcb.b	250*(320/8),0
Screen0	dcb.b	250*(320/8),0

