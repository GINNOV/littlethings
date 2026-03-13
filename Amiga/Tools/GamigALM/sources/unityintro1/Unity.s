	SECTION	"Frantic - Unity Intro 1",CODE_C

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
.2	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#25*(320/8),d0
	addq.l	#8,a0
	dbf	d7,.2

	move.l	#Screen1,d0
	lea	BPL2(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.l	#TxArea2,d0
	lea	BPL3(pc),a0
	lea	BPL4(pc),a1
	move.w	d0,6(a0)
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a0)
	move.w	d0,2(a1)

	move.l	#Frantic,d0
	lea	BPL5(pc),a0
	moveq	#2-1,d7
.3	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#15*(640/8),d0
	addq.l	#8,a0
	dbf	d7,.3

	move.w	#$7fff,$96(a5)
	move.l  #CList,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$83d0,$96(a5)
	move.l	#0,$144(a5)

.1	bsr.w	PutText
	lea	Text(pc),a0
	moveq	#0,d0
	move.w	TextOff(pc),d0
	cmp.b	#"|",1(a0,d0)
	bne.b	.1
	move.w	#1,TextDly

	move.w	$7c(a5),d0
	cmp.b	#$f8,d0
	bne.b	NonAGA
	move.w	#0,$106(a5)
	move.w	#0,$1fc(a5)

NonAGA	bsr.w	GetVBR
	lea	$dff000,a5
	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	$6c(a4),OldIRQ
	move.l	#NewIRQ,$6c(a4)
	move.w	#$c020,$9a(a5)

MousChk	btst	#6,$bfe001
	bne.b	MousChk

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
;	btst	#2,$dff016
;	beq	Pause

	bsr.w	SwpScrn
	bsr.b	NwAngle
	bsr.w	RotTble
	bsr.w	DoLines
	bsr.w	FillObj
	bsr.w	TxtCols
	bsr.b	PutText
	bsr.w	mt_music

;	move.b	$dff006,d0
;	cmp.b	MaxRast(pc),d0
;	bls.s	Pause
;	move.b	d0,MaxRast

Pause	movem.l	(a7)+,d0-a6
;	move.w	#$00f0,$180(a5)
	move.w	#$0020,$9c(a5)
	rte
;MaxRast	dc.b	0,0

;--------------------------------------;

NwAngle	moveq	#0,d0
	lea	SinTble(pc),a0
	move.w	AngSkip(pc),d0
	addq.w	#2,d0
	cmp.w	#360,d0
	blt.b	.1
	sub.w	#360,d0
.1	move.w	d0,AngSkip
	lsl.w	#1,d0
	move.w	(a0,d0),d1
	asr.w	#8,d1
	asr.w	#3,d1
	add.w	#360,d1
	move.w	Angle(pc),d0
	add.w	d1,d0
.2	cmp.w	#360,d0
	blt.b	.3
	sub.w	#360,d0
	bra.b	.2
.3	move.w	d0,Angle
	rts

;--------------------------------------;

PutText	subq.w	#1,TextDly
	bne.b	.1
	move.w	#15*50,TextDly
	addq.w	#3,TextOff
	move.w	#-1,TxtHorz
	move.w	#1,TxtVert

	movem.l	TxtPntr(pc),d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,TxtPntr

	move.l	TxtPntr(pc),d0
	lea	BPL3(pc),a0
	lea	BPL4(pc),a1
	move.w	d0,6(a0)
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a0)
	move.w	d0,2(a1)

.1	tst.w	TxtHorz
	bpl.b	.4
	lea	Text(pc),a0
	move.w	TextOff(pc),d0
	lea	(a0,d0),a0
	moveq	#0,d0
	bra.b	.3
.2	addq.b	#1,d0
.3	cmp.b	#10,(a0)+
	bne.b	.2
	lsl.w	#2,d0
	move.w	#160,d1
	sub.w	d0,d1
	move.w	d1,TxtHorz

	move.l	TxtPntr+4(pc),a0
	moveq	#0,d0
	move.w	TxtVert(pc),d0
	move.l	d0,d1
	lsl.l	#3,d0
	lsl.l	#5,d1
	add.l	d1,d0
	lea	(a0,d0),a0

	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	a0,$54(a5)
	move.w	#11<<6+(320/16),$58(a5)
	WaitBlt

.4	lea	Text(pc),a0
	move.w	TextOff(pc),d0
	lea	(a0,d0),a0
	lea	FontMap(pc),a1
	move.b	(a0),d0
	bne.b	.5
	clr.w	TextOff
	move.w	#-1,TxtHorz
	rts
.5	cmp.b	#10,d0
	bne.b	.6
	cmp.b	#"|",1(a0)
	beq.b	.10
	add.w	#11,TxtVert
	move.w	#-1,TxtHorz
	addq.w	#1,TextOff
	rts
.6	moveq	#0,d1
	bra.b	.8
.7	addq.b	#1,d1
.8	cmp.b	(a1)+,d0
	bne.b	.7
	lea	Font(pc),a1
	lea	(a1,d1),a1

	move.l	TxtPntr+4(pc),a2
	moveq	#0,d0
	move.w	TxtVert(pc),d0
	move.l	d0,d1
	lsl.l	#3,d0
	lsl.l	#5,d1
	add.l	d1,d0
	lea	(a2,d0),a2

	moveq	#0,d0
	move.w	TxtHorz(pc),d0
	move.l	d0,d1
	lsr.w	#3,d0
	bclr	#0,d0
	and.w	#$f,d1
	lea	(a2,d0),a2

	moveq	#10-1,d7
.9	moveq	#0,d0
	move.b	(a1),d0
	ror.l	#8,d0
	lsr.l	d1,d0
	or.l	d0,(a2)
	lea	(320/8)(a1),a1
	lea	(320/8)(a2),a2
	dbf	d7,.9
	addq.w	#8,TxtHorz
	addq.w	#1,TextOff
.10	rts

;--------------------------------------;

TxtCols	lea	Colours+2(pc),a0
	lea	ColLst1(pc),a1
	cmp.w	#16,TextDly
	bgt.b	.1
	lea	ColLst2(pc),a1
.1	moveq	#6-1,d7
	bsr.b	Fader
	rts

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

SwpScrn	movem.l	CurScrn,d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,CurScrn

	lea	BPL2(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	WrkScrn(pc),$54(a5)
	move.w	#200<<6+(320/16),$58(a5)
	rts

;--------------------------------------;

RotTble	lea	Coords(pc),a0
	lea	CrdTble(pc),a1
	lea	SinTble(pc),a2
	lea	CosTble(pc),a3
	moveq	#0,d0
	move.w	Angle(pc),d0
	lsl.w	#1,d0
	move.l	d0,d1
	move.w	(a2,d0),d0
	move.w	(a3,d1),d1
	moveq	#5-1,d7

.1	moveq	#0,d2
	moveq	#0,d3
	move.w	(a0),d2
	move.w	2(a0),d3
	muls	d0,d3
	muls	d1,d2
	sub.l	d3,d2
	asr.l	#8,d2
	asr.l	#6,d2
	move.w	d2,(a1)+
	moveq	#0,d2
	moveq	#0,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	muls	d0,d2
	muls	d1,d3
	add.l	d3,d2
	asr.l	#8,d2
	asr.l	#6,d2
	move.w	d2,(a1)+
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
	lea	LneTble(pc),a1
	moveq	#5-1,d7
.1	moveq	#0,d1
	move.w	(a1)+,d1
	move.w	(a0,d1),d0
	move.w	2(a0,d1),d1
	add.w	#160,d0
	add.w	#102,d1

	moveq	#0,d3
	move.w	(a1),d3
	move.w	(a0,d3),d2
	move.w	2(a0,d3),d3
	add.w	#160,d2
	add.w	#102,d3

	move.l	WrkScrn(pc),a2
	bsr.b	DrawLne
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

FillObj	move.l	WrkScrn(pc),a0
	lea	200*(320/8)-2(a0),a0
	moveq	#0,d0

	WaitBlt
	move.l	#$09f00012,$40(a5)
	move.l	d0,$64(a5)
	move.l	a0,$50(a5)
	move.l	a0,$54(a5)
	move.w	#200<<6+(320/16),$58(a5)
	rts

;--------------------------------------;

Music	include	"DH2:UnityIntro1/ProTracker2.3A.i"

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0
CurScrn	dc.l	Screen1
WrkScrn	dc.l	Screen2
AngSkip	dc.w	0
Angle	dc.w	0
FontMap	dc.b	" ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!*^"
TextDly	dc.w	0
TextOff	dc.w	0
TxtHorz	dc.w	-1
TxtVert	dc.w	1
TxtPntr	dc.l	TxArea1
	dc.l	TxArea2

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$003f
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0180,$0023,$0182,$0489
	dc.w	$0184,$0fff,$0186,$0000

	dc.w	$2c07,$fffe,$0100,$2200
BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$4507,$fffe,$0100,$0200

	dc.w	$0182,$0034
Colours	dc.w	$0184,$0023,$0186,$0034
	dc.w	$0188,$0023,$018a,$0034
	dc.w	$018c,$0023,$018e,$0034

	dc.w	$4a07,$fffe,$0100,$2200
BPL2	dc.w	$00e0,$0000,$00e2,$0000
BPL3	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$4c07,$fffe,$0100,$3200
BPL4	dc.w	$00e8,$0000,$00ea,$0000

	dc.w	$ffe1,$fffe
	dc.w	$1207,$fffe,$0100,$0200
	dc.w	$0092,$003c,$0094,$00d4
	dc.w	$0180,$0023,$0182,$0fff
	dc.w	$0184,$0489,$0186,$0000

	dc.w	$1d07,$fffe,$0100,$a200
BPL5	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$2c07,$fffe,$0100,$0200

	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

ColLst1	dc.w	$0fff,$0fff,$0001,$0012,$0fff,$0fff
ColLst2	dc.w	$0023,$0034,$0023,$0034,$0023,$0034

;--------------------------------------;

Coords	dc.w	 00,-95
	dc.w	 90,-29
	dc.w	 56, 77
	dc.w	-56, 77
	dc.w	-90,-29

LneTble	dc.w	0,8,16,4,12,0

CrdTble	dcb.w	2*5,0

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

Text	incbin	"DH2:UnityIntro1/Unity.txt"
	dc.b	0,10
	even

;--------------------------------------;

Frantic	incbin	"DH2:UnityIntro1/Frantic.raw"
Font	incbin	"DH2:UnityIntro1/Font.raw"
Picture	incbin	"DH2:UnityIntro1/Unity.raw"
Screen1	dcb.b	200*(320/8),0
Screen2	dcb.b	200*(320/8),0
TxArea1	dcb.b	200*(320/8),0
TxArea2	dcb.b	200*(320/8),0
mt_data	incbin	"DH2:UnityIntro1/mod.-your-face-"
