	SECTION	"GeMaNiX - Purple Intro",CODE_C

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

	move.l	#PicEnd,d0
	lea	BPL(pc),a0
	moveq	#2,d7
Pic2Cop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#82,d0
	addq.l	#8,a0
	dbf	d7,Pic2Cop

	move.l	#RbSprte,d0
	lea	SPR1(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#44,d0
	move.w	d0,14(a0)
	swap	d0
	move.w	d0,10(a0)

	move.l	#Sprite,d0
	lea	SPRBPL(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.l	#Sprite,d0
	lea	SPR2(pc),a0
	moveq	#5,d7
SPRLoop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	addq.l	#8,a0
	dbf	d7,SPRLoop

	move.w	$7c(a5),d0
	cmp.b	#$f8,d0
	bne.b	NotAGA
	move.w	#0,$106(a5)
	move.w	#0,$1fc(a5)

NotAGA	bsr.w	Display
	subq.l	#4,ComdPnt

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
	move.w	#$83e0,$96(a5)

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
	beq.w	Pause
	bsr	NoSound
	bsr.b	ComChck
Pause	movem.l	(a7)+,d0-a6
;	move.w	#$00f0,$dff180
	move.w	#$0020,$dff09c
	rte

;--------------------------------------;

NoSound	tst.w	DSound
	beq	NSndEnd
	subq.w	#1,DSound
	bne	NSndEnd
	move.w	#$000f,$96(a5)
NSndEnd	rts

;--------------------------------------;

ComChck	move.l	ComdPnt(pc),a0
	move.l	(a0),a0
	jmp	(a0)

;--------------------------------------;

Display	move.l	#(40*9),d7
DspLoop	bsr.w	DplyChr
	dbf	d7,DspLoop
	rts

DplyChr	move.l	TxtPntr(pc),a0
	moveq	#0,d0
	move.b	(a0)+,d0
	bne.b	ChkChar
	move.l	#Text,TxtPntr
	move.l	#Picture,PicPntr
	clr.w	PicHorz
	addq.l	#4,ComdPnt
	rts
ChkChar	cmp.b	#1,d0
	bne.b	FndChar
	addq.l	#1,TxtPntr
	move.l	#Picture,PicPntr
	clr.w	PicHorz
	addq.l	#4,ComdPnt
	rts
FndChar	move.l	a0,TxtPntr
	lea	ChrList(pc),a0
	moveq	#0,d1
CmpChar	addq.w	#1,d1
	cmp.b	(a0)+,d0
	bne.b	CmpChar
	subq.w	#1,d1
	divu	#40,d1
	move.w	d1,d0
	swap	d1
	mulu	#2,d1
	mulu	#3*21*80,d0
	add.l	d1,d0
	add.l	#FontPic,d0

	move.l	PicPntr(pc),a0
	add.w	PicHorz(pc),a0

	WaitBlt
	move.l	#$09f00000,$40(a5)
	move.l	#$ffffffff,$44(a5)
	move.l	d0,$50(a5)
	move.l	a0,$54(a5)
	move.w	#78,$64(a5)
	move.w	#80,$66(a5)
	move.w	#3*21<<6+1,$58(a5)

	addq.w	#2,PicHorz
	cmp.w	#80,PicHorz
	bne.b	NoNewPs
	add.l	#3*21*(656/8),PicPntr
	clr.w	PicHorz
NoNewPs	rts

;--------------------------------------;

MovePic	move.l	SinePnt(pc),a0
	moveq	#0,d0
	move.b	(a0)+,d0
	move.l	a0,SinePnt
	tst.b	d0
	bne	FindPos
	addq.l	#4,ComdPnt
	move.l	#PicSine,SinePnt
FindPos	mulu	#3*(656/8),d0
	add.l	#Picture,d0

	lea	BPL(pc),a0
	moveq	#2,d7
PicMove	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#82,d0
	addq.l	#8,a0
	dbf	d7,PicMove
	rts

;--------------------------------------;

Wait	subq.w	#1,Delay
	bne.b	WaitEnd
	move.w	#8*50,Delay
	addq.l	#4,ComdPnt
WaitEnd	rts

;--------------------------------------;

FadeLgo	subq.b	#1,ColDlay
	bne	Fade
	addq.l	#4,ComdPnt
	move.b	#16,ColDlay
	rts
Fade	moveq	#0,d0
	lea	Colours+6(pc),a0
	moveq	#6,d7
FRed	moveq	#0,d3

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$0f00,d1
	and.w	#$0f00,d2
	cmp.w	d1,d2
	beq	FGreen
	blt.b	SubRed
	sub.w	#$0100,d2
	bra	FGreen
SubRed	add.w	#$0100,d2
FGreen	add.w	d2,d3
	move.w	(a0),d2

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$00f0,d1
	and.w	#$00f0,d2
	cmp.w	d1,d2
	beq	FBlue
	blt.b	SubGrn
	sub.w	#$0010,d2
	bra	FBlue
SubGrn	add.w	#$0010,d2
FBlue	add.w	d2,d3
	move.w	(a0),d2

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$000f,d1
	and.w	#$000f,d2
	cmp.w	d1,d2
	beq	FFinshd
	blt.b	SubBlu
	sub.w	#$0001,d2
	bra	FFinshd
SubBlu	add.w	#$0001,d2
FFinshd	add.w	d2,d3
	move.w	(a0),d2

	move.w	d3,(a0)
	addq.l	#4,a0
	dbf	d7,FRed
	rts

;--------------------------------------;

SetUp	move.l	#PicEnd,d0
	lea	BPL(pc),a0
	moveq	#2,d7
SetUpPc	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#82,d0
	addq.l	#8,a0
	dbf	d7,SetUpPc

	lea	ColList(pc),a0
	lea	Colours+6(pc),a1
	moveq	#6,d0
ColLoop	move.w	(a0)+,(a1)+
	addq.l	#2,a1
	dbf	d0,ColLoop

	addq.l	#4,ComdPnt
	rts

;--------------------------------------;

Rumble1	move.l	#Sample,$a0(a5)
	move.l	#Sample,$b0(a5)
	move.l	#Sample,$c0(a5)
	move.l	#Sample,$d0(a5)
	move.w	#(SampleE-Sample)/2,$a4(a5)
	move.w	#(SampleE-Sample)/2,$b4(a5)
	move.w	#(SampleE-Sample)/2,$c4(a5)
	move.w	#(SampleE-Sample)/2,$d4(a5)
	move.w	#800,$a6(a5)
	move.w	#800,$b6(a5)
	move.w	#800,$c6(a5)
	move.w	#800,$d6(a5)
	move.w	#64,$a8(a5)
	move.w	#64,$b8(a5)
	move.w	#64,$c8(a5)
	move.w	#64,$d8(a5)
	move.w	#$800f,$96(a5)
	move.w	#32,DSound
	addq.l	#4,ComdPnt

Rumble2	move.l	ShkePnt(pc),a0
	move.l	#Picture,d0
	add.b	(a0)+,d0
	lea	BPL(pc),a1
	moveq	#2,d7
PicShke	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#82,d0
	addq.l	#8,a1
	dbf	d7,PicShke

	move.b	(a0)+,Shake+3
	move.l	a0,ShkePnt
	cmp.b	#1,(a0)
	bne	RumbEnd
	move.l	#ShkeLst,ShkePnt
	addq.l	#4,ComdPnt
RumbEnd	rts

;--------------------------------------;

LoopBck	move.l	#ComList,ComdPnt
	rts

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0
ColDlay	dc.b	16
Sprite	dcb.b	40,0
DSound	dc.w	0
Delay	dc.w	5*50
TxtPntr	dc.l	Text
PicPntr	dc.l	Picture
PicHorz	dc.w	0
SinePnt	dc.l	PicSine
ShkePnt	dc.l	ShkeLst
ComdPnt	dc.l	ComList
ComList	dc.l	MovePic
	dc.l	Rumble1
	dc.l	Rumble2
	dc.l	Wait
	dc.l	FadeLgo
	dc.l	Display
	dc.l	SetUp
	dc.l	LoopBck

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$003c,$0094,$00d4
Shake	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0108,$00a6,$010a,$00a6
	dc.w	$0180,$0213,$0182,$0fff

SPR1	dc.w	$0120,$0000,$0122,$0000
	dc.w	$0124,$0000,$0126,$0000
SPR2	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000
	dc.w	$01a2,$0337,$01a4,$076f
	dc.w	$01a6,$0edf

Colours	dc.w	$0180,$0213,$0182,$0c9b
	dc.w	$0184,$0979,$0186,$0758
	dc.w	$0188,$0545,$018a,$0323
	dc.w	$018c,$0769,$018e,$0657

	dc.w	$4507,$fffe,$0180,$0000
	dc.w	$4607,$fffe,$0180,$0888
	dc.w	$4707,$fffe,$0180,$0000

	dc.w	$4d07,$fffe,$0100,$b200
BPL	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000

	dc.w	$ffe1,$fffe
	dc.w	$0a07,$fffe,$0100,$0200
	dc.w	$1107,$fffe,$0180,$0888
	dc.w	$1207,$fffe,$0180,$0000
	dc.w	$1307,$fffe,$0180,$0213

	dc.w	$0108,$ffd8,$010a,$ffd8
	dc.w	$1507,$fffe,$0100,$1200
SPRBPL	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$1f07,$fffe,$0100,$0200

	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

ColList	dc.w	$0c9b,$0979,$0758,$0545,$0323,$0769,$0657

;--------------------------------------;

ShkeLst	dc.b	2,$22,00,$ee
	dc.b	2,$44,00,$cc
	dc.b	2,$66,00,$aa
	dc.b	2,$88,00,$88
	dc.b	2,$aa,00,$66
	dc.b	2,$cc,00,$44
	dc.b	2,$ee,00,$22
	dc.b	0,$00,01,$00

;--------------------------------------;

PicSine	dc.b	$be,$bd,$bc,$ba,$b7,$b4,$b0,$ab,$a5,$9f,$98,$90,$88
	dc.b	$80,$77,$6d,$63,$59,$4e,$43,$38,$2c,$21,$15,$09,$00

;--------------------------------------;

RbSprte	dc.w	$15cc,$1f06
	dc.w	$71fc,$fbfe,$1a56,$0a02,$3a56,$725c,$6a56,$4a52
	dc.w	$4a52,$4a52,$0bd2,$4a52,$499c,$0bdf,$0800,$0800
	dc.w	$0000,$0800,$0800,$0000
yo
	dc.w	$15d4,$1f06
	dc.w	$7c7e,$feff,$c6c3,$8281,$6276,$f2ef,$32cb,$1289
	dc.w	$1289,$1289,$3281,$1289,$e261,$f2f1,$0201,$0201
	dc.w	$0000,$0201,$0201,$0000

;--------------------------------------;

ChrList	dc.b	"ABCDEFGHIJKLMNOPQRSTUVWXYZ!'()*+,-.1234567890:? "
FontPic	incbin	"DH2:PurpleIntro/Font.raw"
	dcb.b	3*005*(656/8),0
Picture	dcb.b	3*190*(656/8),0
PicEnd	dcb.b	3*190*(656/8),0
Sample	incbin	"DH2:PurpleIntro/Boom"
SampleE	dc.l	0

Text	dc.b	"*--*--*--*--*--*--*--*--*--*--*--*--*--*"
	dc.b	"           *GEMANIX* PRESENTS           "
	dc.b	"                 BEAST 6                "
	dc.b	"                                        "
	dc.b	"                WRITE TO                "
	dc.b	"              PO BOX 77057              "
	dc.b	"                AUCKLAND                "
	dc.b	"          N E W  Z E A L A N D          "
	dc.b	"*--*--*--*--*--*--*--*--*--*--*--*--*--*",1

	dc.b	"*--*--*--*--*--*--*--*--*--*--*--*--*--*"
	dc.b	"  CALL OUR AMIGA AND CONSOLE NZ BOARDS  "
	dc.b	"                                        "
	dc.b	"    SHARK ISLAND - GMX WHQ & ATX NZHQ   "
	dc.b	"       +6 4 - 9 - 8 1 7 - 2 3 4 3       "
	dc.b	"                                        "
	dc.b	"       REALMS OF CHAOS - GMX NZHQ       "
	dc.b	"       +6 4 - 9 - 8 3 2 - 1 7 3 6       "
	dc.b	"*--*--*--*--*--*--*--*--*--*--*--*--*--*",0

