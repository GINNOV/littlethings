	SECTION	"The Unlimited Bobs Demo",CODE_C

;--------------------------------------;

WaitBlt	MACRO
	tst.b	2(a5)
WB\@	btst	#6,2(a5)
	bne.b	WB\@
	ENDM

;--------------------------------------;

_RadiusX	= 152
_RadiusY	= 92
_CenterX	= 152
_CenterY	= 92
_SkipX		= 1
_SkipY		= 1

	lea	$dff000,a5
	WaitBlt
	move.l	4.w,a6
	jsr	-132(a6)
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

	move.w	$1c(a5),d0
	or.w	#$c000,d0
	move.w	d0,IntEna

	move.w	2(a5),d0
	or.w	#$8000,d0
	move.w	d0,DMACon

	move.l	#Screen1,d0
	lea	BPL(pc),a0
	moveq	#2,d7
Pic2Cop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40,d0
	addq.l	#8,a0
	dbf	d7,Pic2Cop

	bsr.w	GetVBR
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
	WaitBlt
	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	OldIRQ(pc),$6c(a4)
	move.w	IntEna(pc),$9a(a5)

	move.l	GfxBase(pc),a6
	move.l	OldView(pc),a1
	jsr	-222(a6)
	move.w	#$7fff,$96(a5)
	move.l	38(a6),$80(a5)
	move.w	#$0000,$88(a5)
	move.w	DMACon(pc),$96(a5)

	move.l	4.w,a6
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
	bsr.b	PrntBob
	bsr.b	NxtScrn
	movem.l	(a7)+,d0-a6
;	move.w	#$00f0,$dff180
	move.w	#$0020,$dff09c
	rte

;--------------------------------------;

NxtScrn	move.l	ScrnPnt(pc),a0
	lea	3*200*(320/8)(a0),a0
	cmp.l	#ScreenEnd,a0
	bne.b	FndScrn
	lea	Screen1(pc),a0
FndScrn	move.l	a0,ScrnPnt

	move.l	a0,d0
	lea	BPL(pc),a0
	moveq	#2,d7
InstPic	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40,d0
	addq.l	#8,a0
	dbf	d7,InstPic

	
	rts

;--------------------------------------;

PrntBob	moveq	#0,d0
	move.l	d0,d2
	move.l	d0,d2
	move.l	d0,d3
	lea	SinTble(pc),a0
	lea	CosTble(pc),a1
	lea	Screen1(pc),a4
	move.w	DegreeX(pc),d0
	move.w	DegreeY(pc),d1
	moveq	#7,d7

PrintLp	lsl.w	#1,d0
	lsl.w	#1,d1
	lea	(a0,d0),a2
	lea	(a1,d1),a3
	move.w	(a2),d2
	move.w	(a3),d3
	muls	RadiusX(pc),d2
	muls	RadiusY(pc),d3
	asr.l	#8,d2
	asr.l	#6,d2
	asr.l	#8,d3
	asr.l	#6,d3
	add.l	#152,d2
	add.l	#92,d3

	move.w	d2,d4
	and.w	#$f,d2
	ror.w	#4,d2
	WaitBlt
	move.w	d2,$42(a5)
	or.w	#$0fca,d2
	move.w	d2,$40(a5)
	lsr.l	#3,d4
	lea	(a4,d4),a2

	move.w	d3,d4
	lsl.w	#7,d3
	lsl.w	#3,d4
	sub.w	d4,d3
	lea	(a2,d3),a2

	move.l	#BobData,$4c(a5)	;BLTBDAT
	move.l	#BobMask,$50(a5)	;BLTADAT
	move.l	#$ffff0000,$44(a5)	;Mask
	move.l	#36<<16,$60(a5)		;Modulos C & B
	move.l	#36,$64(a5)		;Modulos A & D
	move.l	a2,$48(a5)		;BLTCDAT
	move.l	a2,$54(a5)		;BLTDDAT
	move.w	#3*15<<6+2,$58(a5)

	lsr.w	#1,d0
	lsr.w	#1,d1
	add.w	SkipX(pc),d0
	add.w	SkipY(pc),d1

	cmp.w	#360,d0
	blt.b	XDegOK
	sub.w	#360,d0
XDegOK	cmp.w	#360,d1
	blt.b	YDegOK
	sub.w	#360,d1
YDegOK	movem.w	d0-d1,DegreeX
	lea	3*200*(320/8)(a4),a4
	dbf	d7,PrintLp
	rts

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0
DegreeX	dc.w	0
DegreeY	dc.w	0
CenterX	dc.w	_CenterX
CenterY	dc.w	_CenterY
RadiusX	dc.w	_RadiusX
RadiusY	dc.w	_RadiusY
SkipX	dc.w	_SkipX
SkipY	dc.w	_SkipY
ScrnPnt	dc.l	Screen1

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0106,$0000,$01fc,$0000
	dc.w	$0108,$0050,$010a,$0050

	dc.w	$0180,$0023,$0182,$0fff
	dc.w	$0184,$0fff,$0186,$0ddd
	dc.w	$0188,$0bbb,$018a,$0999
	dc.w	$018c,$0777,$018e,$0555

	dc.w	$4607,$fffe,$0180,$0fff
	dc.w	$4707,$fffe,$0180,$0000
	dc.w	$4807,$fffe,$0100,$3200
BPL	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000

	dc.w	$ffe1,$fffe
	dc.w	$1007,$fffe,$0100,$0200
	dc.w	$1107,$fffe,$0180,$0fff
	dc.w	$1207,$fffe,$0180,$0023
	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

BobData	incbin	"DH2:UnlimitedBobs/Bob.raw"
BobMask	incbin	"DH2:UnlimitedBobs/Mask.raw"

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

Screen1	dcb.b	3*200*(320/8),0
Screen2	dcb.b	3*200*(320/8),0
Screen3	dcb.b	3*200*(320/8),0
Screen4	dcb.b	3*200*(320/8),0
Screen5	dcb.b	3*200*(320/8),0
Screen6	dcb.b	3*200*(320/8),0
Screen7	dcb.b	3*200*(320/8),0
Screen8	dcb.b	3*200*(320/8),0
ScreenEnd
