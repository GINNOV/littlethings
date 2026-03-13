
;	For each star is an angle and distance from center
;	ø = Angle
;	H = Distance
;
;	|\
;	| \
;      Y|  \ (H)ypotenuse
;	|  ø\
;	|___(\
;	  X
;
;	sinø * H = Y
;	cosø * H = X
;
;	Add 1 to H each cycle, angle remains same until reaches border


	SECTION	"Star Field",CODE_C

StarNumber	= 150

;--------------------------------------;

WaitBlt	MACRO
	tst.b	2(a5)
WB\@	btst	#6,2(a5)
	bne.b	WB\@
	ENDM

;--------------------------------------;

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
	moveq	#1,d7
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
	move.l	a6,a1
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
	bsr	NxtScrn
	bsr.b	PutStar
	movem.l	(a7)+,d0-a6
;	move.w	#$00f0,$dff180
	move.w	#$0020,$dff09c
	rte

;--------------------------------------;

NxtScrn	movem.l	ScnPnt1(pc),d0-d2
	move.l	d0,d3
	movem.l	d1-d3,ScnPnt1

	lea	BPL(pc),a0
	moveq	#1,d7
Scn2Cop	move.w	d1,6(a0)
	swap	d1
	move.w	d1,2(a0)
	swap	d1
	add.l	#40,d1
	addq.l	#8,a0
	dbf	d7,Scn2Cop

	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	ScnPnt3(pc),$54(a5)
	move.w	#2*200<<6+20,$58(a5)
	rts

;--------------------------------------;

PutStar	lea	StarDat(pc),a0
	lea	SinTble(pc),a1
	lea	CosTble(pc),a2
	move.l	ScnPnt2(pc),a3
	move.l	#StarNumber-1,d7

StarLp	tst.w	2(a0)
	bpl.b	StarOK
	bsr.w	NewStar
StarOK	move.w	(a0),d0
	add.w	d0,4(a0)

	moveq	#0,d0
	move.l	d0,d2
	move.w	2(a0),d0
	lsl.w	#1,d0
	move.w	(a1,d0),d1
	move.w	(a2,d0),d0
	move.w	4(a0),d2
	muls	d2,d0
	muls	d2,d1
	asr.l	#6,d0
	asr.l	#8,d0
	asr.l	#6,d1
	asr.l	#8,d1
	add.w	#160,d0
	add.w	#100,d1

	cmp.w	#0,d0
	bge.b	LeftOK
	move.w	#-1,2(a0)
	bra.b	NxtStar
LeftOK	cmp.w	#320,d0
	blt.b	RghtOK
	move.w	#-1,2(a0)
	bra.b	NxtStar
RghtOK	cmp.w	#0,d1
	bgt.b	UpwdOK
	move.w	#-1,2(a0)
	bra.b	NxtStar
UpwdOK	cmp.w	#200,d1
	blt.b	DnwdOK
	move.w	#-1,2(a0)
	bra.b	NxtStar
DnwdOK
	mulu	#80,d1
	lea	(a3,d1.w),a4

	move.w	d0,d2
	not.b	d0
	lsr.w	#3,d2
	lea	(a4,d2.w),a4
	bset	d0,(a4)

NxtStar	addq.l	#6,a0
	dbf	d7,StarLp
	rts

;--------------------------------------;

NewStar	move.w	(a0),d0
	lsl.w	#3,d0
	move.w	d0,4(a0)
	move.w	$dff006,d0
	bsr	RandomSeed
	move.l	#360,d0
	bsr	Random
	move.w	d0,2(a0)
	rts

;--------------------------------------;

*  You must seed the random function first. It would be best to seed it
*  with the current time, as returned by intuition CurrentTime.
*
*  To generate the number place the limit in d0 and call Random. You are
*  returned a value in the range from 0 to limit-1.
*

;=========================
; RandomSeed(seed)
;             d0
;=========================
RandomSeed:
	ADD.L	D0,D1		;   user seed in d0 (d1 too)
	MOVEM.L	D0/D1,RND
; drops through to the main random function (not user callable)
LongRnd:
	MOVEM.L	D2-D3,-(SP)
	MOVEM.L	RND,D0/D1	;   D0=LSB's, D1=MSB's of random number
	ANDI.B	#$0E,D0		;   ensure upper 59 bits are an...
	ORI.B	#$20,D0		;   ...odd binary number
	MOVE.L	D0,D2
	MOVE.L	D1,D3
	ADD.L	D2,D2		;   accounts for 1 of 17 left shifts
	ADDX.L	D3,D3		;   [D2/D3] = RND*2
	ADD.L	D2,D0
	ADDX.L	D3,D1		;   [D0/D1] = RND*3
	SWAP	D3		;   shift [D2/D3] additional 16 times
	SWAP	D2
	MOVE.W	D2,D3
	CLR.W	D2
	ADD.L	D2,D0		;   add to [D0/D1]
	ADDX.L	D3,D1
	MOVEM.L	D0/D1,RND	;   save for next time through
	MOVE.L	D1,D0		;   most random part to D0
	MOVEM.L	(SP)+,D2-D3
	RTS

;=========================
;Random(limit)
;         d0
;=========================
Random:	MOVE.W	D2,-(SP)
	MOVE.W	D0,D2		;   save upper limit
	BEQ.S	RNG0		;   range of 0 returns 0 always
	BSR.S	LongRnd		;   get a longword random number
	CLR.W	D0		;   use upper word (it's most random)
	SWAP	D0
	DIVU.W	D2,D0		;   divide by range...
	CLR.W	D0		;   ...and use remainder for the value
	SWAP	D0		;   result in D0.W
RNG0	MOVE.W	(SP)+,D2
	RTS

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0
ScnPnt1	dc.l	Screen1
ScnPnt2	dc.l	Screen2
ScnPnt3	dc.l	Screen3
Rnd	dc.l	0,0

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0106,$0000,$01fc,$0000
	dc.w	$0108,$0028,$010a,$0028
	dc.w	$0180,$0023,$0182,$0fff

	dc.w	$4507,$fffe,$0100,$0200
	dc.w	$4607,$fffe,$0180,$0fff
	dc.w	$4707,$fffe,$0180,$0001

	dc.w	$4807,$fffe,$0100,$2200
BPL	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000

	dc.w	$ffe1,$fffe
	dc.w	$1007,$fffe,$0100,$0200
	dc.w	$1107,$fffe,$0180,$0fff
	dc.w	$1207,$fffe,$0180,$0023
	dc.w	$ffff,$fffe,$ffff,$fffe

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

StarDat
 dc.w 1,$00ba,$0005,2,$0098,$00a8,3,$00c4,$007e,2,$0140,$0052,1,$008f,$009d
 dc.w 1,$013c,$0074,2,$0108,$0028,3,$0020,$0039,2,$0130,$006c,1,$0135,$0035
 dc.w 1,$00e1,$0014,2,$00ec,$002c,3,$00fd,$0057,2,$011c,$001c,1,$00e9,$0008
 dc.w 1,$0009,$000f,2,$00ab,$003a,3,$0071,$0021,2,$00e9,$007a,1,$0104,$001b
 dc.w 1,$00de,$007a,2,$00c8,$000c,3,$002c,$0081,2,$00dd,$008e,1,$0161,$0014
 dc.w 1,$00b6,$003d,2,$00b9,$005e,3,$013d,$0033,2,$0096,$0020,1,$007b,$004a
 dc.w 1,$00e6,$0039,2,$013d,$002c,3,$0122,$001e,2,$00da,$003a,1,$00b9,$003f
 dc.w 1,$00da,$0013,2,$ffff,$0078,3,$00cb,$0018,2,$0026,$0050,1,$013b,$003d
 dc.w 1,$004b,$0016,2,$003f,$002a,3,$011f,$0024,2,$0083,$005e,1,$006f,$0067
 dc.w 1,$00d7,$0034,2,$003e,$001c,3,$00b4,$0006,2,$0134,$0066,1,$00b7,$0012
 dc.w 1,$0152,$002f,2,$0154,$0068,3,$0150,$0075,2,$003b,$0066,1,$015e,$0046
 dc.w 1,$0060,$0031,2,$0050,$0026,3,$00e0,$0069,2,$00ef,$001e,1,$0147,$0067
 dc.w 1,$00cc,$0087,2,$00a7,$0028,3,$0140,$0084,2,$0090,$0020,1,$011d,$0030
 dc.w 1,$0081,$0014,2,$00e0,$0074,3,$005f,$001e,2,$0167,$0024,1,$0061,$0016
 dc.w 1,$0084,$0048,2,$ffff,$0064,3,$0030,$002d,2,$00b1,$0052,1,$00c0,$002c
 dc.w 1,$0050,$001e,2,$000d,$008c,3,$014a,$0051,2,$0141,$0030,1,$0081,$006b
 dc.w 1,$00e7,$006c,2,$0068,$0024,3,$001d,$000c,2,$0036,$0004,1,$003a,$0034
 dc.w 1,$0042,$000b,2,$00da,$0048,3,$0141,$000c,2,$0042,$0008,1,$0011,$00a0
 dc.w 1,$0063,$0007,2,$0106,$0038,3,$014d,$0081,2,$013a,$0082,1,$015b,$0088
 dc.w 1,$008b,$0014,2,$00db,$0058,3,$0119,$004e,2,$0153,$0034,1,$0152,$00a4
 dc.w 1,$00ea,$003c,2,$0042,$004c,3,$012c,$000c,2,$004b,$0008,1,$00e4,$0014
 dc.w 1,$00f2,$0067,2,$0005,$0004,3,$0114,$0060,2,$0113,$004e,1,$013b,$001c
 dc.w 1,$0152,$0062,2,$0123,$0048,3,$001b,$0069,2,$0054,$002c,1,$0147,$0073
 dc.w 1,$001a,$0078,2,$0135,$002c,3,$ffff,$0066,2,$013b,$007e,1,$010c,$0032
 dc.w 1,$009b,$0079,2,$00cb,$00a6,3,$0123,$0069,2,$0083,$0072,1,$00b4,$006d
 dc.w 1,$000b,$000b,2,$0084,$0002,3,$00ff,$001b,2,$0083,$000c,1,$014d,$0077
 dc.w 1,$0145,$0074,2,$009c,$0098,3,$0098,$0021,2,$00bc,$0010,1,$ffff,$00b0
 dc.w 1,$00bc,$008c,2,$006c,$0048,3,$00bc,$0069,2,$002c,$0042,1,$015d,$00a2
 dc.w 1,$00fd,$0043,2,$0114,$0050,3,$0115,$0012,2,$00a5,$006a,1,$0126,$0037
 dc.w 1,$0075,$0012,2,$009d,$0054,3,$011d,$004b,2,$0145,$000e,1,$001d,$000a

;--------------------------------------;

Screen1	dcb.b	2*200*(320/8),0
Screen2	dcb.b	2*200*(320/8),0
Screen3	dcb.b	2*200*(320/8),0


