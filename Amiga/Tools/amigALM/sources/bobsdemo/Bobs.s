	SECTION	"Bobs Demo",CODE_C

BobNo		= 253
XSpeed		= 1
YSpeed		= 2
XSpace		= 2
YSpace		= 5

;--------------------------------------;

	move.l	4.w,a6
	jsr	-132(a6)
	lea	$dff000,a5

	move.w	$1c(a5),d0
	or.w	#$c000,d0
	move.w	d0,IntEna

	move.w	2(a5),d0
	or.w	#$8000,d0
	move.w	d0,DMACon

	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	$6c.w,OldIRQ
	move.l	#NewIRQ,$6c.w
	move.w	#$c020,$9a(a5)

	move.l	CurScrn(pc),d0
	bsr	Insert

	move.w	#$7fff,$96(a5)
	move.l  #CList,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$87c0,$96(a5)
	move.l	#0,$144(a5)

MousChk	btst	#6,$bfe001
	bne.b	MousChk

	lea	$dff000,a5
	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	OldIRQ(pc),$6c.w
	move.w	IntEna(pc),$9a(a5)

	move.l	4.w,a6
	move.l	$9c(a6),a1
	move.w	#$7fff,$96(a5)
	move.l	38(a1),$80(a5)
	move.w	#$0000,$88(a5)
	move.w	DMACon(pc),$96(a5)

	jsr	-138(a6)
	moveq	#0,d0
	rts

;--------------------------------------;

NewIRQ	movem.l	d0-a6,-(a7)
	bsr.b	Bobs
	bsr.b	NxtScrn
	movem.l	(a7)+,d0-a6
	move.w	#$0001,$dff180
	move.w	#$0020,$9c(a5)
	rte

;--------------------------------------;

NxtScrn	movem.l	CurScrn(pc),d0/d1
	exg.l	d0,d1
	movem.l	d0/d1,CurScrn

Insert	lea	BPL(pc),a0
	move.w	d0,6(a0)
	move.w	d0,22(a0)
	swap	d0
	move.w	d0,2(a0)
	move.w	d0,18(a0)
	rts

;--------------------------------------;

Bobs	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	WrkScrn(pc),$54(a5)
	move.w	#199<<6+20,$58(a5)
WaitBlt	btst	#14,2(a5)
	bne	WaitBlt

	move.l	#$ffff0000,$44(a5)	;Mask
	move.l	#$0024fffe,$60(a5)	;Modulos
	move.l	#$fffe0024,$64(a5)	;Modulos

	move.l	SpeedX(pc),d0
	lea	Coords(pc),a0
	lea	SinTble(pc),a1
	move.l	WrkScrn(pc),a2

	move.l	#BobNo-1,d7
BobLoop	add.l	d0,(a0)
	and.l	#$00ff00ff,(a0)

	move.w	(a0),d1
	move.b	(a1,d1.w),d1
	add.w	#64,d1
	move.w	2(a0),d2
	move.b	(a1,d2.w),d2

	move.w	d1,d3
	and.w	#$f,d1
	ror.w	#4,d1
	move.w	d1,$42(a5)
	or.w	#$0fca,d1
	move.w	d1,$40(a5)
	lsr.l	#3,d3
	lea	(a2,d3.w),a3

	move.w	d2,d3
	lsl.w	#3,d2
	lsl.w	#5,d3
	add.w	d3,d2
	lea	(a3,d2.w),a3

	move.l	#BobData,$4c(a5)	;BLTBDAT
	move.l	#BobData,$50(a5)	;BLTADAT
	move.l	a3,$48(a5)		;BLTCDAT
	move.l	a3,$54(a5)		;BLTDDAT
	move.w	#7<<6+2,$58(a5)

	add.l	#4,a0
	dbf	d7,BobLoop

	rts

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0102,$0010

	dc.w	$0180,$0000,$0182,$0fff
	dc.w	$0184,$0666,$0186,$0fff

	dc.w	$2c09,$fffe,$0100,$1200
BPL	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$2d09,$fffe,$0100,$2200
	dc.w	$00e4,$0000,$00e6,$0000

	dc.w	$f409,$fffe,$0100,$0200
	dc.w	$ffff,$fffe

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
CurScrn	dc.l	Screen1
WrkScrn	dc.l	Screen2
SpeedX	dc.w	XSpeed
SpeedY	dc.w	YSpeed
Blitter

;--------------------------------------;

SinTble	dc.b	$00,$00,$00,$00,$01,$01,$01,$02,$02,$03,$03,$04,$04,$05,$06,$07
	dc.b	$08,$09,$0a,$0b,$0c,$0d,$0e,$10,$11,$12,$14,$15,$17,$18,$1a,$1b
	dc.b	$1d,$1f,$20,$22,$24,$26,$28,$2a,$2c,$2e,$30,$32,$34,$36,$38,$3a
	dc.b	$3c,$3f,$41,$43,$45,$48,$4a,$4c,$4e,$51,$53,$55,$58,$5a,$5c,$5f
	dc.b	$61,$64,$66,$68,$6b,$6d,$6f,$72,$74,$76,$78,$7b,$7d,$7f,$81,$84
	dc.b	$86,$88,$8a,$8c,$8e,$90,$92,$94,$96,$98,$9a,$9c,$9e,$a0,$a1,$a3
	dc.b	$a5,$a6,$a8,$a9,$ab,$ac,$ae,$af,$b0,$b2,$b3,$b4,$b5,$b6,$b7,$b8
	dc.b	$b9,$ba,$bb,$bc,$bc,$bd,$bd,$be,$be,$bf,$bf,$bf,$c0,$c0,$c0,$c0
	dc.b	$c0,$c0,$c0,$c0,$bf,$bf,$bf,$be,$be,$bd,$bd,$bc,$bc,$bb,$ba,$b9
	dc.b	$b8,$b7,$b6,$b5,$b4,$b3,$b2,$b0,$af,$ae,$ac,$ab,$a9,$a8,$a6,$a5
	dc.b	$a3,$a1,$a0,$9e,$9c,$9a,$98,$96,$94,$92,$90,$8e,$8c,$8a,$88,$86
	dc.b	$84,$81,$7f,$7d,$7b,$78,$76,$74,$72,$6f,$6d,$6b,$68,$66,$64,$61
	dc.b	$5f,$5c,$5a,$58,$55,$53,$51,$4e,$4c,$4a,$48,$45,$43,$41,$3f,$3c
	dc.b	$3a,$38,$36,$34,$32,$30,$2e,$2c,$2a,$28,$26,$24,$22,$20,$1f,$1d
	dc.b	$1b,$1a,$18,$17,$15,$14,$12,$11,$10,$0e,$0d,$0c,$0b,$0a,$09,$08
	dc.b	$07,$06,$05,$04,$04,$03,$03,$02,$02,$01,$01,$01,$00,$00,$00,$00

BobData	dc.w	%0011100000000000
	dc.w	%0111110000000000
	dc.w	%1111111000000000
	dc.w	%1111111000000000
	dc.w	%1111111000000000
	dc.w	%0111110000000000
	dc.w	%0011100000000000

Coords	dc.w	000*XSpace,000*YSpace+(256/4)
	dc.w	001*XSpace,001*YSpace+(256/4)
	dc.w	002*XSpace,002*YSpace+(256/4)
	dc.w	003*XSpace,003*YSpace+(256/4)
	dc.w	004*XSpace,004*YSpace+(256/4)
	dc.w	005*XSpace,005*YSpace+(256/4)
	dc.w	006*XSpace,006*YSpace+(256/4)
	dc.w	007*XSpace,007*YSpace+(256/4)
	dc.w	008*XSpace,008*YSpace+(256/4)
	dc.w	009*XSpace,009*YSpace+(256/4)
	dc.w	010*XSpace,010*YSpace+(256/4)
	dc.w	011*XSpace,011*YSpace+(256/4)
	dc.w	012*XSpace,012*YSpace+(256/4)
	dc.w	013*XSpace,013*YSpace+(256/4)
	dc.w	014*XSpace,014*YSpace+(256/4)
	dc.w	015*XSpace,015*YSpace+(256/4)
	dc.w	016*XSpace,016*YSpace+(256/4)
	dc.w	017*XSpace,017*YSpace+(256/4)
	dc.w	018*XSpace,018*YSpace+(256/4)
	dc.w	019*XSpace,019*YSpace+(256/4)
	dc.w	020*XSpace,020*YSpace+(256/4)
	dc.w	021*XSpace,021*YSpace+(256/4)
	dc.w	022*XSpace,022*YSpace+(256/4)
	dc.w	023*XSpace,023*YSpace+(256/4)
	dc.w	024*XSpace,024*YSpace+(256/4)
	dc.w	025*XSpace,025*YSpace+(256/4)
	dc.w	026*XSpace,026*YSpace+(256/4)
	dc.w	027*XSpace,027*YSpace+(256/4)
	dc.w	028*XSpace,028*YSpace+(256/4)
	dc.w	029*XSpace,029*YSpace+(256/4)
	dc.w	030*XSpace,030*YSpace+(256/4)
	dc.w	031*XSpace,031*YSpace+(256/4)
	dc.w	032*XSpace,032*YSpace+(256/4)
	dc.w	033*XSpace,033*YSpace+(256/4)
	dc.w	034*XSpace,034*YSpace+(256/4)
	dc.w	035*XSpace,035*YSpace+(256/4)
	dc.w	036*XSpace,036*YSpace+(256/4)
	dc.w	037*XSpace,037*YSpace+(256/4)
	dc.w	038*XSpace,038*YSpace+(256/4)
	dc.w	039*XSpace,039*YSpace+(256/4)
	dc.w	040*XSpace,040*YSpace+(256/4)
	dc.w	041*XSpace,041*YSpace+(256/4)
	dc.w	042*XSpace,042*YSpace+(256/4)
	dc.w	043*XSpace,043*YSpace+(256/4)
	dc.w	044*XSpace,044*YSpace+(256/4)
	dc.w	045*XSpace,045*YSpace+(256/4)
	dc.w	046*XSpace,046*YSpace+(256/4)
	dc.w	047*XSpace,047*YSpace+(256/4)
	dc.w	048*XSpace,048*YSpace+(256/4)
	dc.w	049*XSpace,049*YSpace+(256/4)
	dc.w	050*XSpace,050*YSpace+(256/4)
	dc.w	051*XSpace,051*YSpace+(256/4)
	dc.w	052*XSpace,052*YSpace+(256/4)
	dc.w	053*XSpace,053*YSpace+(256/4)
	dc.w	054*XSpace,054*YSpace+(256/4)
	dc.w	055*XSpace,055*YSpace+(256/4)
	dc.w	056*XSpace,056*YSpace+(256/4)
	dc.w	057*XSpace,057*YSpace+(256/4)
	dc.w	058*XSpace,058*YSpace+(256/4)
	dc.w	059*XSpace,059*YSpace+(256/4)
	dc.w	060*XSpace,060*YSpace+(256/4)
	dc.w	061*XSpace,061*YSpace+(256/4)
	dc.w	062*XSpace,062*YSpace+(256/4)
	dc.w	063*XSpace,063*YSpace+(256/4)
	dc.w	064*XSpace,064*YSpace+(256/4)
	dc.w	065*XSpace,065*YSpace+(256/4)
	dc.w	066*XSpace,066*YSpace+(256/4)
	dc.w	067*XSpace,067*YSpace+(256/4)
	dc.w	068*XSpace,068*YSpace+(256/4)
	dc.w	069*XSpace,069*YSpace+(256/4)
	dc.w	070*XSpace,070*YSpace+(256/4)
	dc.w	071*XSpace,071*YSpace+(256/4)
	dc.w	072*XSpace,072*YSpace+(256/4)
	dc.w	073*XSpace,073*YSpace+(256/4)
	dc.w	074*XSpace,074*YSpace+(256/4)
	dc.w	075*XSpace,075*YSpace+(256/4)
	dc.w	076*XSpace,076*YSpace+(256/4)
	dc.w	077*XSpace,077*YSpace+(256/4)
	dc.w	078*XSpace,078*YSpace+(256/4)
	dc.w	079*XSpace,079*YSpace+(256/4)
	dc.w	080*XSpace,080*YSpace+(256/4)
	dc.w	081*XSpace,081*YSpace+(256/4)
	dc.w	082*XSpace,082*YSpace+(256/4)
	dc.w	083*XSpace,083*YSpace+(256/4)
	dc.w	084*XSpace,084*YSpace+(256/4)
	dc.w	085*XSpace,085*YSpace+(256/4)
	dc.w	086*XSpace,086*YSpace+(256/4)
	dc.w	087*XSpace,087*YSpace+(256/4)
	dc.w	088*XSpace,088*YSpace+(256/4)
	dc.w	089*XSpace,089*YSpace+(256/4)
	dc.w	090*XSpace,090*YSpace+(256/4)
	dc.w	091*XSpace,091*YSpace+(256/4)
	dc.w	092*XSpace,092*YSpace+(256/4)
	dc.w	093*XSpace,093*YSpace+(256/4)
	dc.w	094*XSpace,094*YSpace+(256/4)
	dc.w	095*XSpace,095*YSpace+(256/4)
	dc.w	096*XSpace,096*YSpace+(256/4)
	dc.w	097*XSpace,097*YSpace+(256/4)
	dc.w	098*XSpace,098*YSpace+(256/4)
	dc.w	099*XSpace,099*YSpace+(256/4)
	dc.w	100*XSpace,100*YSpace+(256/4)
	dc.w	101*XSpace,101*YSpace+(256/4)
	dc.w	102*XSpace,102*YSpace+(256/4)
	dc.w	103*XSpace,103*YSpace+(256/4)
	dc.w	104*XSpace,104*YSpace+(256/4)
	dc.w	105*XSpace,105*YSpace+(256/4)
	dc.w	106*XSpace,106*YSpace+(256/4)
	dc.w	107*XSpace,107*YSpace+(256/4)
	dc.w	108*XSpace,108*YSpace+(256/4)
	dc.w	109*XSpace,109*YSpace+(256/4)
	dc.w	110*XSpace,110*YSpace+(256/4)
	dc.w	111*XSpace,111*YSpace+(256/4)
	dc.w	112*XSpace,112*YSpace+(256/4)
	dc.w	113*XSpace,113*YSpace+(256/4)
	dc.w	114*XSpace,114*YSpace+(256/4)
	dc.w	115*XSpace,115*YSpace+(256/4)
	dc.w	116*XSpace,116*YSpace+(256/4)
	dc.w	117*XSpace,117*YSpace+(256/4)
	dc.w	118*XSpace,118*YSpace+(256/4)
	dc.w	119*XSpace,119*YSpace+(256/4)
	dc.w	120*XSpace,120*YSpace+(256/4)
	dc.w	121*XSpace,121*YSpace+(256/4)
	dc.w	122*XSpace,122*YSpace+(256/4)
	dc.w	123*XSpace,123*YSpace+(256/4)
	dc.w	124*XSpace,124*YSpace+(256/4)
	dc.w	125*XSpace,125*YSpace+(256/4)
	dc.w	126*XSpace,126*YSpace+(256/4)
	dc.w	127*XSpace,127*YSpace+(256/4)
	dc.w	128*XSpace,128*YSpace+(256/4)
	dc.w	129*XSpace,129*YSpace+(256/4)
	dc.w	130*XSpace,130*YSpace+(256/4)
	dc.w	131*XSpace,131*YSpace+(256/4)
	dc.w	132*XSpace,132*YSpace+(256/4)
	dc.w	133*XSpace,133*YSpace+(256/4)
	dc.w	134*XSpace,134*YSpace+(256/4)
	dc.w	135*XSpace,135*YSpace+(256/4)
	dc.w	136*XSpace,136*YSpace+(256/4)
	dc.w	137*XSpace,137*YSpace+(256/4)
	dc.w	138*XSpace,138*YSpace+(256/4)
	dc.w	139*XSpace,139*YSpace+(256/4)
	dc.w	140*XSpace,140*YSpace+(256/4)
	dc.w	141*XSpace,141*YSpace+(256/4)
	dc.w	142*XSpace,142*YSpace+(256/4)
	dc.w	143*XSpace,143*YSpace+(256/4)
	dc.w	144*XSpace,144*YSpace+(256/4)
	dc.w	145*XSpace,145*YSpace+(256/4)
	dc.w	146*XSpace,146*YSpace+(256/4)
	dc.w	147*XSpace,147*YSpace+(256/4)
	dc.w	148*XSpace,148*YSpace+(256/4)
	dc.w	149*XSpace,149*YSpace+(256/4)
	dc.w	150*XSpace,150*YSpace+(256/4)
	dc.w	151*XSpace,151*YSpace+(256/4)
	dc.w	152*XSpace,152*YSpace+(256/4)
	dc.w	153*XSpace,153*YSpace+(256/4)
	dc.w	154*XSpace,154*YSpace+(256/4)
	dc.w	155*XSpace,155*YSpace+(256/4)
	dc.w	156*XSpace,156*YSpace+(256/4)
	dc.w	157*XSpace,157*YSpace+(256/4)
	dc.w	158*XSpace,158*YSpace+(256/4)
	dc.w	159*XSpace,159*YSpace+(256/4)
	dc.w	160*XSpace,160*YSpace+(256/4)
	dc.w	161*XSpace,161*YSpace+(256/4)
	dc.w	162*XSpace,162*YSpace+(256/4)
	dc.w	163*XSpace,163*YSpace+(256/4)
	dc.w	164*XSpace,164*YSpace+(256/4)
	dc.w	165*XSpace,165*YSpace+(256/4)
	dc.w	166*XSpace,166*YSpace+(256/4)
	dc.w	167*XSpace,167*YSpace+(256/4)
	dc.w	168*XSpace,168*YSpace+(256/4)
	dc.w	169*XSpace,169*YSpace+(256/4)
	dc.w	170*XSpace,170*YSpace+(256/4)
	dc.w	171*XSpace,171*YSpace+(256/4)
	dc.w	172*XSpace,172*YSpace+(256/4)
	dc.w	173*XSpace,173*YSpace+(256/4)
	dc.w	174*XSpace,174*YSpace+(256/4)
	dc.w	175*XSpace,175*YSpace+(256/4)
	dc.w	176*XSpace,176*YSpace+(256/4)
	dc.w	177*XSpace,177*YSpace+(256/4)
	dc.w	178*XSpace,178*YSpace+(256/4)
	dc.w	179*XSpace,179*YSpace+(256/4)
	dc.w	180*XSpace,180*YSpace+(256/4)
	dc.w	181*XSpace,181*YSpace+(256/4)
	dc.w	182*XSpace,182*YSpace+(256/4)
	dc.w	183*XSpace,183*YSpace+(256/4)
	dc.w	184*XSpace,184*YSpace+(256/4)
	dc.w	185*XSpace,185*YSpace+(256/4)
	dc.w	186*XSpace,186*YSpace+(256/4)
	dc.w	187*XSpace,187*YSpace+(256/4)
	dc.w	188*XSpace,188*YSpace+(256/4)
	dc.w	189*XSpace,189*YSpace+(256/4)
	dc.w	190*XSpace,190*YSpace+(256/4)
	dc.w	191*XSpace,191*YSpace+(256/4)
	dc.w	192*XSpace,192*YSpace+(256/4)
	dc.w	193*XSpace,193*YSpace+(256/4)
	dc.w	194*XSpace,194*YSpace+(256/4)
	dc.w	195*XSpace,195*YSpace+(256/4)
	dc.w	196*XSpace,196*YSpace+(256/4)
	dc.w	197*XSpace,197*YSpace+(256/4)
	dc.w	198*XSpace,198*YSpace+(256/4)
	dc.w	199*XSpace,199*YSpace+(256/4)
	dc.w	200*XSpace,200*YSpace+(256/4)
	dc.w	201*XSpace,201*YSpace+(256/4)
	dc.w	202*XSpace,202*YSpace+(256/4)
	dc.w	203*XSpace,203*YSpace+(256/4)
	dc.w	204*XSpace,204*YSpace+(256/4)
	dc.w	205*XSpace,205*YSpace+(256/4)
	dc.w	206*XSpace,206*YSpace+(256/4)
	dc.w	207*XSpace,207*YSpace+(256/4)
	dc.w	208*XSpace,208*YSpace+(256/4)
	dc.w	209*XSpace,209*YSpace+(256/4)
	dc.w	210*XSpace,210*YSpace+(256/4)
	dc.w	211*XSpace,211*YSpace+(256/4)
	dc.w	212*XSpace,212*YSpace+(256/4)
	dc.w	213*XSpace,213*YSpace+(256/4)
	dc.w	214*XSpace,214*YSpace+(256/4)
	dc.w	215*XSpace,215*YSpace+(256/4)
	dc.w	216*XSpace,216*YSpace+(256/4)
	dc.w	217*XSpace,217*YSpace+(256/4)
	dc.w	218*XSpace,218*YSpace+(256/4)
	dc.w	219*XSpace,219*YSpace+(256/4)
	dc.w	220*XSpace,220*YSpace+(256/4)
	dc.w	221*XSpace,221*YSpace+(256/4)
	dc.w	222*XSpace,222*YSpace+(256/4)
	dc.w	223*XSpace,223*YSpace+(256/4)
	dc.w	224*XSpace,224*YSpace+(256/4)
	dc.w	225*XSpace,225*YSpace+(256/4)
	dc.w	226*XSpace,226*YSpace+(256/4)
	dc.w	227*XSpace,227*YSpace+(256/4)
	dc.w	228*XSpace,228*YSpace+(256/4)
	dc.w	229*XSpace,229*YSpace+(256/4)
	dc.w	230*XSpace,230*YSpace+(256/4)
	dc.w	231*XSpace,231*YSpace+(256/4)
	dc.w	232*XSpace,232*YSpace+(256/4)
	dc.w	233*XSpace,233*YSpace+(256/4)
	dc.w	234*XSpace,234*YSpace+(256/4)
	dc.w	235*XSpace,235*YSpace+(256/4)
	dc.w	236*XSpace,236*YSpace+(256/4)
	dc.w	237*XSpace,237*YSpace+(256/4)
	dc.w	238*XSpace,238*YSpace+(256/4)
	dc.w	239*XSpace,239*YSpace+(256/4)
	dc.w	240*XSpace,240*YSpace+(256/4)
	dc.w	241*XSpace,241*YSpace+(256/4)
	dc.w	242*XSpace,242*YSpace+(256/4)
	dc.w	243*XSpace,243*YSpace+(256/4)
	dc.w	244*XSpace,244*YSpace+(256/4)
	dc.w	245*XSpace,245*YSpace+(256/4)
	dc.w	246*XSpace,246*YSpace+(256/4)
	dc.w	247*XSpace,247*YSpace+(256/4)
	dc.w	248*XSpace,248*YSpace+(256/4)
	dc.w	249*XSpace,249*YSpace+(256/4)
	dc.w	250*XSpace,250*YSpace+(256/4)
	dc.w	251*XSpace,251*YSpace+(256/4)
	dc.w	252*XSpace,252*YSpace+(256/4)
	dc.w	253*XSpace,253*YSpace+(256/4)
	dc.w	254*XSpace,254*YSpace+(256/4)
	dc.w	255*XSpace,255*YSpace+(256/4)
	dc.w	256*XSpace,256*YSpace+(256/4)
	dc.w	257*XSpace,257*YSpace+(256/4)
	dc.w	258*XSpace,258*YSpace+(256/4)
	dc.w	259*XSpace,259*YSpace+(256/4)
	dc.w	260*XSpace,260*YSpace+(256/4)
	dc.w	261*XSpace,261*YSpace+(256/4)
	dc.w	262*XSpace,262*YSpace+(256/4)
	dc.w	263*XSpace,263*YSpace+(256/4)
	dc.w	264*XSpace,264*YSpace+(256/4)
	dc.w	265*XSpace,265*YSpace+(256/4)
	dc.w	266*XSpace,266*YSpace+(256/4)
	dc.w	267*XSpace,267*YSpace+(256/4)
	dc.w	268*XSpace,268*YSpace+(256/4)
	dc.w	269*XSpace,269*YSpace+(256/4)
	dc.w	270*XSpace,270*YSpace+(256/4)
	dc.w	271*XSpace,271*YSpace+(256/4)
	dc.w	272*XSpace,272*YSpace+(256/4)
	dc.w	273*XSpace,273*YSpace+(256/4)
	dc.w	274*XSpace,274*YSpace+(256/4)
	dc.w	275*XSpace,275*YSpace+(256/4)
	dc.w	276*XSpace,276*YSpace+(256/4)
	dc.w	277*XSpace,277*YSpace+(256/4)
	dc.w	278*XSpace,278*YSpace+(256/4)
	dc.w	279*XSpace,279*YSpace+(256/4)
	dc.w	280*XSpace,280*YSpace+(256/4)
	dc.w	281*XSpace,281*YSpace+(256/4)
	dc.w	282*XSpace,282*YSpace+(256/4)
	dc.w	283*XSpace,283*YSpace+(256/4)
	dc.w	284*XSpace,284*YSpace+(256/4)
	dc.w	285*XSpace,285*YSpace+(256/4)
	dc.w	286*XSpace,286*YSpace+(256/4)
	dc.w	287*XSpace,287*YSpace+(256/4)
	dc.w	288*XSpace,288*YSpace+(256/4)
	dc.w	289*XSpace,289*YSpace+(256/4)
	dc.w	290*XSpace,290*YSpace+(256/4)
	dc.w	291*XSpace,291*YSpace+(256/4)
	dc.w	292*XSpace,292*YSpace+(256/4)
	dc.w	293*XSpace,293*YSpace+(256/4)
	dc.w	294*XSpace,294*YSpace+(256/4)
	dc.w	295*XSpace,295*YSpace+(256/4)
	dc.w	296*XSpace,296*YSpace+(256/4)
	dc.w	297*XSpace,297*YSpace+(256/4)
	dc.w	298*XSpace,298*YSpace+(256/4)
	dc.w	299*XSpace,299*YSpace+(256/4)
	dc.w	300*XSpace,300*YSpace+(256/4)

Screen1	dcb.b	200*(320/8),0
Screen2	dcb.b	200*(320/8),0

