;	AUTO	WB\Start\End\

;---------------------------------------;

TimeOut		= 30
TextAddr	= $190000
TextSize	= (9*14)*(320/8)
LogoSize	= 37*(320/8)
ShaydeSize	= 4*(320/8)

;---------------------------------------;

WaitBlt	MACRO
WB\@	btst	#6,2(a6)
	bne.s	WB\@
	ENDM

WaitTme	MACRO
WT\@	tst.w	(a5)
	bne.s	WT\@
	ENDM

	jmp	$180000
	org	$180000
	load	$180000

;---------------------------------------;

Start	lea	$dff000,a6
	lea	Timer(pc),a5
	WaitBlt
	st	$bfd100
	nop
	nop
	move.b	#$87,$bfd100
	nop
	nop
	st	$bfd100
	bsr.l	StUpScn

	clr.l	0.w
	move.w	#$8000,d1
	move.w	2(a6),d0
	or.w	d1,d0
	move.w	d0,-(a7)
	move.w	$1c(a6),d0
	or.w	d1,d0
	move.w	d0,-(a7)
	subq.w	#1,d1
	move.w	d1,$96(a6)
	move.w	d1,$9a(a6)
	move.w	d1,$9c(a6)
	move.l	$6c.w,-(a7)
	move.l	#NewIRQ,$6c.w
	move.l	#CopList,$84(a6)
	move.w	#$83e0,$96(a6)
	move.w	#$c020,$9a(a6)
	move.l	a7,Stack

	move.w	#30,(a5)
	WaitTme

	lea	LogoCol+2(pc),a0
	lea	LgoCols(pc),a1
	moveq	#15,d0
	bsr.s	FadeBPL

	move.w	#30,(a5)
	WaitTme
	lea	LneSkip(pc),a3
	lea	TextCol+6(pc),a4
	moveq	#13,d7
FdeLnes	tst.b	(a3)+
	beq.s	NoLine

	move.l	a4,a0
	lea	TxtCols(pc),a1
	moveq	#7,d0
	move.l	a3,-(a7)
	bsr.s	FadeBPL
	move.l	(a7)+,a3
NoLine	lea	36(a4),a4
	dbf	d7,FdeLnes

	lea	ShydCol+6(pc),a0
	lea	LgoCols(pc),a1
	moveq	#15,d0
	bsr.s	FadeBPL
	move.w	#TimeOut*50,(a5)
	WaitTme

EndInt	move.l	Stack(pc),a7
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9a(a6)
	move.l	(a7)+,$6c.w
	move.w	(a7)+,$9a(a6)
	move.w	(a7)+,$96(a6)
	moveq	#0,d0
	rts

;---------------------------------------;

FadeBPL	subq.w	#1,d0
	moveq	#14,d1
FdeWhte	move.w	d0,d2
	move.l	a0,a2
PutWtLp	add.w	#$111,(a2)
	addq.l	#4,a2
	dbf	d2,PutWtLp
	addq.w	#1,(a5)
	WaitTme
	dbf	d1,FdeWhte

	moveq	#15,d1
Fde2Col	move.w	d0,d2
	move.l	a0,a2
	move.l	a1,a3
AllCols	move.w	d1,d3
	move.w	(a3)+,d4
	move.w	d4,d5
	moveq	#$00f,d6
	and.w	d4,d6
	and.w	#$0f0,d5
	and.w	#$f00,d4
	cmp.w	d3,d6
	bgt.s	FadeRed
	move.w	d3,d6
FadeRed	lsl.w	#4,d3
	cmp.w	d3,d5
	bgt.s	FadeGrn
	move.w	d3,d5
FadeGrn	lsl.w	#4,d3
	cmp.w	d3,d4
	bgt.s	FadeBlu
	move.w	d3,d4
FadeBlu	or.w	d5,d4
	or.w	d6,d4
	move.w	d4,(a2)
	addq.l	#4,a2
	dbf	d2,AllCols
	addq.w	#1,(a5)
	WaitTme
	dbf	d1,Fde2Col
	rts

StUpScn	moveq	#$ffffffff,d0
	move.l	#$01000000,$40(a6)
	move.l	d0,$44(a6)
	move.l	#TextAddr,$54(a6)
	clr.w	$66(a6)
	move.w	#3*(14*9)<<6+20,$58(a6)
	WaitBlt
	lea	Text(pc),a0
	lea	TextAddr+1,a1
	lea	FntOffs(pc),a2
	lea	LneSkip(pc),a4
	moveq	#0,d0
	moveq	#13,d7
PutLnes	moveq	#37,d6
	sf	d1
PutChrs	move.b	(a0)+,d0
	sub.b	#32,d0
	beq.s	SkipLne
	st	d1
	add.b	d0,d0
SkipLne	lea	FontDat(pc),a3
	add.w	(a2,d0.w),a3
	move.b	0040(a3),00040(a1)
	move.b	0080(a3),00080(a1)
	move.b	0120(a3),00120(a1)
	move.b	0160(a3),00160(a1)
	move.b	0200(a3),00200(a1)
	move.b	0240(a3),00240(a1)
	move.b	0840(a3),05040(a1)
	move.b	0880(a3),05080(a1)
	move.b	0920(a3),05120(a1)
	move.b	0960(a3),05160(a1)
	move.b	1000(a3),05200(a1)
	move.b	1040(a3),05240(a1)
	move.b	1080(a3),05280(a1)
	move.b	1680(a3),10080(a1)
	move.b	1720(a3),10120(a1)
	move.b	1760(a3),10160(a1)
	move.b	1800(a3),10200(a1)
	move.b	1840(a3),10240(a1)
	move.b	1880(a3),10280(a1)
	move.b	1920(a3),10320(a1)
	move.b	(a3),(a1)+
	dbf	d6,PutChrs
	move.b	d1,(a4)+
	lea	322(a1),a1
	dbf	d7,PutLnes
	rts

;---------------------------------------;

NewIRQ	tst.w	(a5)
	beq.s	WaitMse
	subq.w	#1,(a5)
WaitMse	btst	#6,$bfe001
	bne.s	NoMouse
	move.l	#EndInt,2(a7)
NoMouse	move.w	#$0020,$9c(a6)
	rte

;---------------------------------------;

Timer	dc.w	0
Stack	dc.l	0
LneSkip	dcb.b	14,0
CopList	dc.w	$008e,$0181,$0090,$38c1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0180,$0023,$0100,$0200
	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0108,$0000,$010a,$0000

	dc.w	$0120,$0000,$0122,$0000
	dc.w	$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000

	dc.w	$4b0f,$fffe,$0180,$0aaa
	dc.w	$4c0f,$fffe,$0180,$0000

LogoCol	dc.w	$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000
	dc.w	$018e,$0000,$0190,$0000,$0192,$0000
	dc.w	$0194,$0000,$0196,$0000,$0198,$0000
	dc.w	$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$00e0,(Logo+LogoSize*0)/65535
	dc.w	$00e2,(Logo+LogoSize*0)&65535
	dc.w	$00e4,(Logo+LogoSize*1)/65536
	dc.w	$00e6,(Logo+LogoSize*1)&65535
	dc.w	$00e8,(Logo+LogoSize*2)/65536
	dc.w	$00ea,(Logo+LogoSize*2)&65535
	dc.w	$00ec,(Logo+LogoSize*3)/65535
	dc.w	$00ee,(Logo+LogoSize*3)&65535
	dc.w	$520f,$fffe,$0100,$4200
	dc.w	$770f,$fffe,$0100,$0200

	dc.w	$00e0,(TextAddr+TextSize*0)/65535
	dc.w	$00e2,(TextAddr+TextSize*0)&65535
	dc.w	$00e4,(TextAddr+TextSize*1)/65536
	dc.w	$00e6,(TextAddr+TextSize*1)&65535
	dc.w	$00e8,(TextAddr+TextSize*2)/65536
	dc.w	$00ea,(TextAddr+TextSize*2)&65535

	dc.w	$800f,$fffe,$0100,$3200
TextCol	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000

	dc.w	$890f,$fffe
	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000

	dc.w	$920f,$fffe
	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000

	dc.w	$9b0f,$fffe
	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000

	dc.w	$a40f,$fffe
	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000

	dc.w	$ad0f,$fffe
	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000

	dc.w	$b60f,$fffe
	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000

	dc.w	$bf0f,$fffe
	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000

	dc.w	$c80f,$fffe
	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000

	dc.w	$d10f,$fffe
	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000

	dc.w	$da0f,$fffe
	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000

	dc.w	$e30f,$fffe
	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000

	dc.w	$ec0f,$fffe
	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000

	dc.w	$f50f,$fffe
	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000

	dc.w	$fe0f,$fffe,$0100,$0200
	dc.w	$ffdf,$fffe
ShydCol	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000
	dc.w	$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000
	dc.w	$019c,$0000,$019e,$0000
	dc.w	$00e0,(Shayde+ShaydeSize*0)/65535
	dc.w	$00e2,(Shayde+ShaydeSize*0)&65535
	dc.w	$00e4,(Shayde+ShaydeSize*1)/65536
	dc.w	$00e6,(Shayde+ShaydeSize*1)&65535
	dc.w	$00e8,(Shayde+ShaydeSize*2)/65536
	dc.w	$00ea,(Shayde+ShaydeSize*2)&65535
	dc.w	$00ec,(Shayde+ShaydeSize*3)/65535
	dc.w	$00ee,(Shayde+ShaydeSize*3)&65535
	dc.w	$010f,$fffe,$0100,$4200
	dc.w	$050f,$fffe,$0100,$0200

	dc.w	$070f,$fffe,$0180,$0aaa
	dc.w	$080f,$fffe,$0180,$0023
	dc.w	$ffff,$fffe

;---------------------------------------;

LgoCols	dc.w	$0ffc,$0ffb,$0ffa,$0fe9,$0ed8
	dc.w	$0dc7,$0cb6,$0ba5,$0a94,$0983
	dc.w	$0872,$0762,$0651,$0540,$0430

TxtCols	dc.w	$0ffc,$0dd9,$0bb6,$0994,$0872,$0651,$0430

;---------------------------------------;

Logo	incbin	"DH2:Reality/Logo.raw"

FntOffs	dc.w	000,002,004,006,008,010,012,014,016,018
	dc.w	020,022,024,026,028,030,032,034,036,038
	dc.w	280,282,284,286,288,290,292,294,296,298
	dc.w	300,302,304,306,308,310,312,314,316,318
	dc.w	560,562,564,566,568,570,572,574,576,578
	dc.w	580,582,584,586,588,590,592,594,596,598

FontDat	incbin	"DH2:Reality/Font.raw"
Shayde	incbin	"DH2:Reality/Shayde.raw"

;---------------------------------------;

Text	dc.b	"       ANOTHER BAD BARTY IMPORT!      "
	dc.b	"                                      "
	dc.b	"        FOR >CHEAP> AMIGA WARES       "
	dc.b	"               WRITE TO:              "
	dc.b	"                                      "
	dc.b	"           BAD BARTY/REALITY          "
	dc.b	"             P.O. BOX 120             "
	dc.b	"              SILVERDALE              "
	dc.b	"               AUCKLAND!              "
	dc.b	"                                      "
	dc.b	"                                      "
	dc.b	"     GREETS TO ALL OUR FRIENDS...     "
	dc.b	"                                      "
	dc.b	"           < HIT THE RAT!! <          "
End
