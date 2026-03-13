	SECTION	"Robster - Shaded Bobs",CODE_C

TextWait = 10 Seconds

;--------------------------------------;

WaitBlt	MACRO
	tst.b	2(a5)
WB\@	btst	#6,2(a5)
	bne.b	WB\@
	ENDM

;--------------------------------------;

	bsr	DoTextS
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
	moveq	#3,d7
Pic2Cop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#252*(320/8),d0
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

	move.l	#TxArea1,d0
	lea	BPL2(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.l	#PR_Data,pr_Module
	bsr	pr_Init
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
	move.l	#0,$144(a5)

MousChk	btst	#6,$bfe001
	bne.b	MousChk

	bsr	pr_End
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
	btst	#2,$dff016
	beq	Pause
	bsr	PrntTxt
	bsr.w	ShdBobs
	bsr.w	SubBobs
	bsr	pr_Music
;	move.w	#$00f0,$dff180
Pause
;	cmp.b	#$f8,6(a5)
;	bne	Pause
	movem.l	(a7)+,d0-a6
	move.w	#$0020,$dff09c
	rte

;--------------------------------------;

DoTextS	moveq	#-1,d7
	bsr	SetUpTx
	move.b	#1,TxtSwch
	movem.l	AreaPnt(pc),d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,AreaPnt
	move.l	AreaPnt(pc),PagePnt
	rts

;-------------------;

PrntTxt	moveq	#5,d7
SetUpTx	tst.b	TxtSwch
	beq	TxtWait
	move.l	TextPnt(pc),a0
	lea	Font(pc),a1
	move.l	PagePnt(pc),a3
TxtLoop	moveq	#0,d0
	move.b	(a0)+,d0
	bne	NoNxLne
	lea	200(a3),a3
	move.b	(a0)+,d0
NoNxLne	cmp.b	#1,d0
	beq	EndPage
	move.l	a0,TextPnt
	sub.b	#32,d0
	mulu	#5,d0
	lea	(a1,d0),a2
	move.l	a3,a4
	moveq	#4,d6
MveLoop	move.b	(a2)+,(a4)
	lea	40(a4),a4
	dbf	d6,MveLoop
	addq.l	#1,a3
	dbf	d7,TxtLoop
	move.l	a3,PagePnt
TextEnd	rts

;-------------------;

EndPage	clr.b	TxtSwch
	addq.l	#1,TextPnt
	cmp.l	#EndText,TextPnt
	bne	TextEnd
	move.l	#Text,TextPnt
	rts

;-------------------;

TxtWait	subq.w	#1,TxtPgeL
	bmi	TxtDlyF
	rts
TxtDlyF	cmp.w	#-16,TxtPgeL
	bgt	FdeTxtD
	cmp.w	#-17,TxtPgeL
	beq	SetUpNx
	cmp.w	#-32,TxtPgeL
	bgt	FdeTxtU

	move.b	#1,TxtSwch
	move.w	#TextWait*50-80-32,TxtPgeL
	rts

SetUpNx	move.l	AreaPnt(pc),d0
	lea	BPL2(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	movem.l	AreaPnt(pc),d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,AreaPnt
	move.l	AreaPnt(pc),PagePnt

	move.l	ColPntr(pc),a0
	lea	32(a0),a0
	cmp.l	#ColourE,a0
	bne	NColEnd
	lea	Colour2(pc),a0
NColEnd	move.l	a0,ColPntr
	bra	TxtWait

;-------------------;

FdeTxtD	lea	Colour1(pc),a1
	lea	ColList+2(pc),a0
	moveq	#15,d7
	bra	Fader
FdeTxtU	move.l	ColPntr(pc),a1
	lea	ColList+2(pc),a0
	moveq	#15,d7
Fader
FFRed	move.w	(a1)+,d0
	moveq	#0,d3

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$0f00,d1
	and.w	#$0f00,d2
	cmp.w	d1,d2
	beq	FFGreen
	blt.b	FSubRed
	sub.w	#$0100,d2
	bra	FFGreen
FSubRed	add.w	#$0100,d2
FFGreen	add.w	d2,d3
	move.w	(a0),d2

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$00f0,d1
	and.w	#$00f0,d2
	cmp.w	d1,d2
	beq	FFBlue
	blt.b	FSubGrn
	sub.w	#$0010,d2
	bra	FFBlue
FSubGrn	add.w	#$0010,d2
FFBlue	add.w	d2,d3
	move.w	(a0),d2

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$000f,d1
	and.w	#$000f,d2
	cmp.w	d1,d2
	beq	FFFinshd
	blt.b	FSubBlu
	sub.w	#$0001,d2
	bra	FFFinshd
FSubBlu	add.w	#$0001,d2
FFFinshd
	add.w	d2,d3
	move.w	(a0),d2

	move.w	d3,(a0)
	addq.l	#4,a0
	dbf	d7,FFRed
	rts

;--------------------------------------;

ShdBobs	lea	BobLst1(pc),a0
	lea	SinTble(pc),a1
	lea	CosTble(pc),a2
	lea	CrdLst1(pc),a3

	move.l	#Dots-1,d7
SineLp1	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3

	moveq	#3,d6
SpdLp1	move.w	(a0)+,d5
	add.w	d5,-10(a0)
	cmp.w	#360*2,-10(a0)
	blt	NoNwSn1
	sub.w	#360*2,-10(a0)
NoNwSn1	dbf	d6,SpdLp1

	move.w	(a2,d0),d4
	asr.w	#1,d4
	move.w	(a2,d1),d6
	asr.w	#1,d6
	add.l	d6,d4
	move.w	(a1,d2),d5
	asr.w	#1,d5
	move.w	(a1,d3),d6
	asr.w	#1,d6
	add.l	d6,d5
	move.l	d4,d6
	muls	#(320-32)/2,d4
	muls	#(252-32)/2,d5
	asr.l	#8,d4
	asr.l	#6,d4
	asr.l	#8,d5
	asr.l	#6,d5
	move.w	d4,(a3)+
	move.w	d5,(a3)+
	dbf	d7,SineLp1

	lea	CrdLst1(pc),a0
	lea	BobData(pc),a1
	lea	Buffer1(pc),a3
	lea	Buffer2(pc),a4

	move.w	#$0ba0,d5
	move.l	#Dots-1,d7
ShdeLp1	bsr	BltLoop
	dbf	d7,ShdeLp1
	rts

;-------------------;

SubBobs	subq.w	#1,ShdSubL
	bpl	ShdSubE
	move.w	#0,ShdSubL
	lea	BobLst2(pc),a0
	lea	SinTble(pc),a1
	lea	CosTble(pc),a2
	lea	CrdLst2(pc),a3

	move.l	#Dots-1,d7
SineLp2	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3

	moveq	#3,d6
SpdLpp2	move.w	(a0)+,d5
	add.w	d5,-10(a0)
	cmp.w	#360*2,-10(a0)
	blt	NoNwSn2
	sub.w	#360*2,-10(a0)
NoNwSn2	dbf	d6,SpdLpp2

	move.w	(a2,d0),d4
	asr.w	#1,d4
	move.w	(a2,d1),d6
	asr.w	#1,d6
	add.l	d6,d4
	move.w	(a1,d2),d5
	asr.w	#1,d5
	move.w	(a1,d3),d6
	asr.w	#1,d6
	add.l	d6,d5
	move.l	d4,d6
	muls	#(320-32)/2,d4
	muls	#(252-32)/2,d5
	asr.l	#8,d4
	asr.l	#6,d4
	asr.l	#8,d5
	asr.l	#6,d5
	move.w	d4,(a3)+
	move.w	d5,(a3)+
	dbf	d7,SineLp2

	lea	CrdLst2(pc),a0
	lea	BobData(pc),a1
	lea	Buffer1(pc),a3
	lea	Buffer2(pc),a4

	move.w	#$0b50,d5
	move.l	#Dots-1,d7
ShdeLp2	bsr	BltLoop
	dbf	d7,ShdeLp2
ShdSubE	rts

;-------------------;

BltLoop	move.w	(a0)+,d0
	move.w	(a0)+,d1
	add.w	#320/2-16,d0
	add.w	#252/2-16,d1

	lea	Screen1(pc),a2
	move.w	d1,d2
	asl.w	#3,d1
	asl.w	#5,d2
	add.w	d2,d1
	lea	(a2,d1),a2

	move.w	d0,d2
	and.w	#$f,d0
	ror.w	#4,d0
	lsr.w	#3,d2
	lea	(a2,d2),a2

	moveq	#0,d2
	moveq	#34,d3
	move.w	#32<<6+(48/16),d4
	move.w	d5,d1
	or.w	d0,d1
	WaitBlt
	move.l	#$ffffffff,$44(a5)
	move.l	d2,$64(a5)		;BLTAMOD + BLTDMOD
	move.w	d3,$60(a5)		;BLTCMOD
	move.w	d1,$40(a5)
	move.w	d2,$42(a5)
	move.l	a1,$50(a5)
	move.l	a2,$48(a5)
	move.l	a3,$54(a5)
	move.w	d4,$58(a5)

	move.w	#$0b5a,d1
	or.w	d0,d1
	WaitBlt
	move.w	d1,$40(a5)
	move.w	d3,$66(a5)
	move.l	a1,$50(a5)
	move.l	a2,$48(a5)
	move.l	a2,$54(a5)
	move.w	d4,$58(a5)

	moveq	#2,d6
ShadeLp	lea	252*(320/8)(a2),a2

	move.w	d5,d1
	WaitBlt
	move.w	d1,$40(a5)
	move.w	d2,$66(a5)
	move.l	a3,$50(a5)
	move.l	a2,$48(a5)
	move.l	a4,$54(a5)
	move.w	d4,$58(a5)

	move.w	#$0b5a,d1
	WaitBlt
	move.w	d1,$40(a5)
	move.w	d3,$66(a5)
	move.l	a3,$50(a5)
	move.l	a2,$48(a5)
	move.l	a2,$54(a5)
	move.w	d4,$58(a5)

	exg.l	a3,a4
	dbf	d6,ShadeLp
	rts

;--------------------------------------;

Music	include	"DH2:ADUIntro3/ProRunner2.0.i"

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0
SBlank	dcb.b	40,0
TxtSwch	dc.b	1
ShdSubL	dc.w	330
TxtPgeL	dc.w	TextWait*50-80-32
TextPnt	dc.l	Text
PagePnt	dc.l	TxArea1
AreaPnt	dc.l	TxArea1
	dc.l	TxArea2

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$003f
	dc.w	$0106,$0000,$01fc,$0000
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0180,$0000

SPR1	dc.w	$0120,$0000,$0122,$0000
	dc.w	$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000
SPR2	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000

	dc.w	$2c07,$fffe,$0180,$00aa
	dc.w	$2d07,$fffe
	dc.w	$0180,$0033,$0182,$0045
	dc.w	$0184,$0057,$0186,$0069
	dc.w	$0188,$007b,$018a,$008d
	dc.w	$018c,$009f,$018e,$00af
	dc.w	$0190,$009f,$0192,$008d
	dc.w	$0194,$007b,$0196,$0069
	dc.w	$0198,$0057,$019a,$0045
	dc.w	$019c,$0033,$019e,$0021
ColList	dc.w	$01a0,$0888,$01a2,$0aaa
	dc.w	$01a4,$0ccc,$01a6,$0eee
	dc.w	$01a8,$0fff,$01aa,$0fff
	dc.w	$01ac,$0fff,$01ae,$0fff
	dc.w	$01b0,$0fff,$01b2,$0fff
	dc.w	$01b4,$0fff,$01b6,$0eee
	dc.w	$01b8,$0ccc,$01ba,$0aaa
	dc.w	$01bc,$0888,$01be,$0666

	dc.w	$2e07,$fffe,$0100,$4200
BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$8e07,$fffe,$0100,$5200
BPL2	dc.w	$00f0,$0000,$00f2,$0000
	dc.w	$ca07,$fffe,$0100,$4200

	dc.w	$01a2,$0599,$01a4,$0155
	dc.w	$01aa,$0599,$01ac,$0155

	dc.w	$ffe1,$fffe
	dc.w	$2a07,$fffe,$0100,$0200
	dc.w	$2b07,$fffe,$0180,$00aa
	dc.w	$2c07,$fffe,$0180,$0000
	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

ColPntr	dc.l	Colour2
Colour1	dc.w	$0033,$0045,$0057,$0069,$007b,$008d,$009f,$00af
	dc.w	$009f,$008d,$007b,$0069,$0057,$0045,$0033,$0021

Colour2	dc.w	$0888,$0aaa,$0ccc,$0eee,$0fff,$0fff,$0fff,$0fff
	dc.w	$0fff,$0fff,$0fff,$0eee,$0ccc,$0aaa,$0888,$0666
	dc.w	$0fc8,$0fda,$0fec,$0ffe,$0fff,$0fff,$0fff,$0fff
	dc.w	$0fff,$0fff,$0fff,$0ffe,$0fec,$0fda,$0fc8,$0fb6
	dc.w	$00c8,$00da,$00ec,$00fe,$00ff,$00ff,$00ff,$00ff
	dc.w	$00ff,$00ff,$00ff,$00fe,$00ec,$00da,$00c8,$00b6
ColourE

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

BobLst1	dc.w	000,180,360,540,2*2,2*3,2*4,2*2
	dc.w	180,360,540,000,2*4,2*3,2*1,2*3
	dc.w	360,540,000,180,2*1,2*3,2*2,2*1

BobLst2	dc.w	000,180,360,540,2*2,2*3,2*4,2*2
	dc.w	180,360,540,000,2*4,2*3,2*1,2*3
	dc.w	360,540,000,180,2*1,2*3,2*2,2*1
BobListEnd
Dots	= (BobListEnd-BobLst2)/16

;--------------------------------------;

CrdLst1	REPT	Dots
	dc.w	0,0
	ENDR
CrdLst2	REPT	Dots
	dc.w	0,0
	ENDR

;--------------------------------------;

BobData	dc.w	%0000000000001111,%1111000000000000,%0000000000000000
	dc.w	%0000000001111111,%1111111000000000,%0000000000000000
	dc.w	%0000000111111111,%1111111110000000,%0000000000000000
	dc.w	%0000001111111111,%1111111111000000,%0000000000000000
	dc.w	%0000011111111111,%1111111111100000,%0000000000000000
	dc.w	%0000111111111111,%1111111111110000,%0000000000000000
	dc.w	%0001111111111111,%1111111111111000,%0000000000000000
	dc.w	%0011111111111111,%1111111111111100,%0000000000000000
	dc.w	%0011111111111111,%1111111111111100,%0000000000000000
	dc.w	%0111111111111111,%1111111111111110,%0000000000000000
	dc.w	%0111111111111111,%1111111111111110,%0000000000000000
	dc.w	%0111111111111111,%1111111111111110,%0000000000000000
	dc.w	%1111111111111111,%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%1111111111111111,%0000000000000000
	dc.w	%0111111111111111,%1111111111111110,%0000000000000000
	dc.w	%0111111111111111,%1111111111111110,%0000000000000000
	dc.w	%0111111111111111,%1111111111111110,%0000000000000000
	dc.w	%0011111111111111,%1111111111111100,%0000000000000000
	dc.w	%0011111111111111,%1111111111111100,%0000000000000000
	dc.w	%0001111111111111,%1111111111111000,%0000000000000000
	dc.w	%0000111111111111,%1111111111110000,%0000000000000000
	dc.w	%0000011111111111,%1111111111100000,%0000000000000000
	dc.w	%0000001111111111,%1111111111000000,%0000000000000000
	dc.w	%0000000111111111,%1111111110000000,%0000000000000000
	dc.w	%0000000001111111,%1111111000000000,%0000000000000000
	dc.w	%0000000000001111,%1111000000000000,%0000000000000000

Text	dc.b	"[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[",0
	dc.b	"      *AMIGA DOWN UNDER ISSUE #10*      ",0
	dc.b	"                                        ",0
	dc.b	"      ON THIS ISSUE WE'VE GOT LOTS      ",0
	dc.b	"   THINGS THAT MAKES A COVERDISK COOL   ",0
	dc.b	"                                        ",0
	dc.b	"   CHECK OUT THE PROGRAMMING SECTION    ",0
	dc.b	"  AND THE ARTICLE WRITTEN BY SOME ONE   ",0
	dc.b	"BUT YOU'VE GOTTA CHECK OUT THE NEXT PAGE",0
	dc.b	"]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]",1

	dc.b	"[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[",0
	dc.b	"                                        ",0
	dc.b	"                CREDITS                 ",0
	dc.b	"                [[[[[[[                 ",0
	dc.b	"                                        ",0
	dc.b	"            INTRO BY ROBSTER            ",0
	dc.b	"            MUSIC BY HEATBEAT           ",0
	dc.b	"                                        ",0
	dc.b	"                                        ",0
	dc.b	"]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]",1
EndText
Font	include	"DH2:ADUIntro3/Font.i"
Buffer1	dcb.b	32*(48/8),0
Buffer2	dcb.b	32*(48/8),0
Screen1	dcb.b	4*252*(320/8),0
TxArea1	dcb.b	60*(320/8),0
TxArea2	dcb.b	60*(320/8),0
PR_Data	incbin	"DH2:ADUIntro3/Mod.Nallet.New"

