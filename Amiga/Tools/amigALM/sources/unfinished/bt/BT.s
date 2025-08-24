;	IDEA FOR OTHER INTRO
;	BARS 3D RASTER TUNNEL IN SANITY INTERFERENCE, LINE DRAWING (same grad) 

;	TO DO:
;	Must set up 2d rotation and gather figures for 360 degrees
;	then figure out from those figures the scale factors.
;

	SECTION	"Frantic - BITCH TREATLE",CODE_C

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

	move.l	#BTData,d0
	lea	BPLBT(pc),a0
	moveq	#3-1,d7
.BT	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#54*(320/8),d0
	addq.l	#8,a0
	dbf	d7,.BT

	move.l	#Screen1,d0
	move.l	#Screen2,d1
	lea	BPL1(pc),a0
	move.w	d0,6(a0)
	move.w	d1,14(a0)
	swap	d0
	swap	d1
	move.w	d0,2(a0)
	move.w	d1,10(a0)

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
	bsr	NwAngle
	bsr	RotTble
	bsr	Draw

Pause	movem.l	(a7)+,d0-a6
;	move.w	#$00f0,$180(a5)
	move.w	#$0020,$9c(a5)
	rte

;--------------------------------------;

SwpScrn	movem.l	CurScrn,d0-d2
	move.l	d0,d3
	movem.l	d1-d3,CurScrn

	lea	BPL1(pc),a0
	move.w	d1,6(a0)
	move.w	d2,14(a0)
	swap	d1
	swap	d2
	move.w	d1,2(a0)
	move.w	d2,10(a0)

	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	WrkScrn(pc),$54(a5)
	move.w	#200<<6+(320/16),$58(a5)
	rts

;--------------------------------------;

NwAngle	move.w	Angle(pc),d0
	addq.w	#1,d0
	cmp.w	#360,d0
	blt	.1
	sub.w	#360,d0
.1	move.w	d0,Angle
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
	moveq	#4-1,d7

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

Draw	WaitBlt
	move.w	#(320/8),$60(a5)
	move.w	#(320/8),$66(a5)
	move.w	#$8000,$74(a5)
	move.w	#$ffff,$44(a5)

	lea	CrdTble(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	add.w	#160,d0
	add.w	#100-32,d1
	add.w	#160,d2
	add.w	#100-32,d3
	lea	Gfx(pc),a0
	move.l	WrkScrn(pc),a1
	bsr	DrawLne
	rts

;--------------------------------------;

DrawLne	moveq	#0,d4
	sub.w	d1,d3
	roxl.b	#1,d4
	tst.w	d3
	bge	.1
	neg.w	d3
.1	sub.w	d0,d2
	roxl.b	#1,d4
	tst.w	d2
	bge	.2
	neg.w	d2
.2	move.w	d3,d5
	sub.w	d2,d5
	bge	.3
	exg	d2,d3
.3	roxl.b	#1,d4
	lea	OctTble(pc),a3
	move.b	(a3,d4),d4

	add.w	d2,d2
	move.w	d2,$62(a5)
	sub.w	d3,d2
	bge	.4
	or.b	#$40,d4
.4	move.w	d2,$52(a5)
	sub.w	d3,d2
	move.w	d2,$64(a5)

	move.w	d4,$42(a5)

	lea	CrdTble(pc),a3
	moveq	#0,d5
	moveq	#0,d6
	move.w	(a3),d5
	beq	.5
	ext.l	d5
	move.w	2(a3),d6
	swap	d6
	divs.l	d5,d6			;110/64
	move.l	d6,yop1
	moveq	#0,d5
	moveq	#0,d6

.5	move.w	d0,d2
	move.w	d1,d3
	move.w	d0,d4
	swap	d5
	swap	d6
	add.w	d5,d2
	add.w	d6,d3
	add.w	d5,d4

	and.w	#$fff0,d2
	lsr.w	#3,d2
	lea	(a1,d2.l),a2
	muls	#(320/8),d3
	lea	(a2,d3.l),a2
	move.l	a2,$48(a5)
	move.l	a2,$54(a5)
	and.w	#$f,d4
	ror.w	#4,d4
	or.w	#$bca,d4
	move.w	d4,$40(a5)
						;d2=LDelta,d3=SDelta
	moveq	#(128/16)-1,d7
	move.w	#16<<6+2,d2
.99	move.w	(a0)+,d3
	rol.w	#1,d3
	move.w	d3,$72(a5)			;mask
	move.w	d2,$58(a5)
	WaitBlt
	dbf	d7,.99
	swap	d5
	swap	d6
	add.w	yop1(pc),d5
	add.l	#$10000,d6
	add.w	#1,yop2
	cmp.w	#128,yop2
	bne	.5
	move.w	#0,yop2
	rts

OctTble	dc.b	0<<2+1,4<<2+1,2<<2+1,5<<2+1
	dc.b	1<<2+1,6<<2+1,3<<2+1,7<<2+1

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0
CurScrn	dc.l	Screen1
	dc.l	Screen2
WrkScrn	dc.l	Screen3
Angle	dc.w	0
yop1	dc.l	0
yop2	dc.l	0

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$003f
	dc.w	$0108,$0000,$010a,$0000

	dc.w	$0180,$0000,$0182,$0531
	dc.w	$0184,$0742,$0186,$0864
	dc.w	$0188,$0a86,$018a,$0ca9
	dc.w	$018c,$0edc,$018e,$0fff

BPLBT	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$2c07,$fffe,$0100,$3200

	dc.w	$6207,$fffe,$0100,$0200
	dc.w	$0180,$0000,$0182,$0fff
	dc.w	$0184,$0fff,$0186,$0fff

BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$6407,$fffe,$0100,$2200

	dc.w	$ffe1,$fffe
	dc.w	$2c07,$fffe,$0100,$0200

	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

Coords	dc.w	-64,-64
	dc.w	 64,-64
	dc.w	 64, 64
	dc.w	-64, 64

CrdTble	dcb.w	4*2,0

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

Gfx	incbin	"DH1:BT/Data.raw"
BTData	incbin	"DH1:BT/BT.raw"
	dcb.b	200*(320/8),0
Screen1	dcb.b	200*(320/8),0
	dcb.b	200*(320/8),0
Screen2	dcb.b	200*(320/8),0
	dcb.b	200*(320/8),0
Screen3	dcb.b	200*(320/8),0
	dcb.b	200*(320/8),0

	END

