	SECTION	"Robster - Sinus Dots",CODE_C

Dots	= 256
SpaceX1	= 5
SpaceX2	= 6
SpaceY1	= 4
SpaceY2	= 5
SpeedX1	= 1
SpeedX2	= 0
SpeedY1	= 1
SpeedY2	= 0

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

	move.l	#Screen1,d0
	lea	BPL1(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

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
	bsr.b	SwpScrn
	bsr.b	SinDots
	movem.l	(a7)+,d0-a6
;	move.w	#$00f0,$dff180
	move.w	#$0020,$dff09c
	rte

;--------------------------------------;

SwpScrn	movem.l	CurScrn(pc),d0-d5
	move.l	d0,d6
	movem.l	d1-d6,CurScrn

	lea	CurScrn(pc),a1
	lea	BPL1(pc),a0
	moveq	#3,d1
PicLoop	move.l	(a1)+,d0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	addq.l	#8,a0
	dbf	d1,PicLoop

	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	ClrScrn(pc),$54(a5)
	move.w	#256<<6+20,$58(a5)
	rts

;--------------------------------------;

SinDots	lea	X12Y12(pc),a0
	lea	SinList(pc),a1
	lea	XYSpeed(pc),a2
	lea	CrdList(pc),a3
	lea	XYSpace(pc),a4
	movem.l	Blank(pc),d0-d7
	move.b	(a0),d0
	move.b	1(a0),d1
	move.b	2(a0),d2
	move.b	3(a0),d3

	moveq	#3,d7
SpdLoop	move.b	(a2)+,d6
	add.b	d6,(a0)+
	dbf	d7,SpdLoop

	move.l	#Dots-1,d7
SinLoop	move.b	(a1,d0),d4
	lsr.b	#1,d4
	move.b	(a1,d1),d6
	lsr.b	#1,d6
	add.b	d6,d4
	move.b	(a1,d2),d5
	lsr.b	#1,d5
	move.b	(a1,d3),d6
	lsr.b	#1,d6
	add.b	d6,d5
	move.w	d4,(a3)+
	move.w	d5,(a3)+

	add.b	(a4),d0
	add.b	1(a4),d1
	add.b	2(a4),d2
	add.b	3(a4),d3
	dbf	d7,SinLoop

	lea	CrdList(pc),a0
	move.l	WrkScrn(pc),a1
	move.l	#Dots-1,d7
PltLoop	movem.l	Blank(pc),d0-d1
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	add.w	#32,d0

	move.w	d1,d2
	lsl.w	#3,d1
	lsl.w	#5,d2
	add.w	d2,d1
	lea	(a1,d1),a2

	move.w	d0,d2
	not.b	d0
	lsr.w	#3,d2
	lea	(a2,d2),a2
	bset	d0,(a2)

	dbf	d7,PltLoop
	rts

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0
CurScrn	dc.l	Screen1
	dc.l	Screen2
	dc.l	Screen3
	dc.l	Screen4
WrkScrn	dc.l	Screen5
ClrScrn	dc.l	Screen6
X12Y12	dc.b	0,0,0,0
XYSpace	dc.b	SpaceX1,SpaceX2,SpaceY1,SpaceY2
XYSpeed	dc.b	SpeedX1,SpeedX2,SpeedY1,SpeedY2
Blank	dcb.l	8,0

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0106,$0000,$01fc,$0000
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0180,$0000,$0182,$0333
	dc.w	$0184,$0777,$0186,$0777
	dc.w	$0188,$0bbb,$018a,$0bbb
	dc.w	$018c,$0bbb,$018e,$0bbb
	dc.w	$0190,$0fff,$0192,$0fff
	dc.w	$0194,$0fff,$0196,$0fff
	dc.w	$0198,$0fff,$019a,$0fff
	dc.w	$019c,$0fff,$019e,$0fff

	dc.w	$2c07,$fffe,$0100,$4200
BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000

	dc.w	$ffdf,$fffe
	dc.w	$2c07,$fffe,$0100,$0200
	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

SinList	dc.b	$80,$83,$86,$89,$8c,$8f,$92,$95,$98,$9c,$9f,$a2,$a5,$a8,$ab,$ae
	dc.b	$b0,$b3,$b6,$b9,$bc,$bf,$c1,$c4,$c7,$c9,$cc,$ce,$d1,$d3,$d5,$d8
	dc.b	$da,$dc,$de,$e0,$e2,$e4,$e6,$e8,$ea,$ec,$ed,$ef,$f0,$f2,$f3,$f5
	dc.b	$f6,$f7,$f8,$f9,$fa,$fb,$fc,$fc,$fd,$fe,$fe,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$fe,$fe,$fd,$fc,$fc,$fb,$fa,$f9,$f8,$f7
	dc.b	$f6,$f5,$f3,$f2,$f0,$ef,$ed,$ec,$ea,$e8,$e6,$e4,$e2,$e0,$de,$dc
	dc.b	$da,$d8,$d5,$d3,$d1,$ce,$cc,$c9,$c7,$c4,$c1,$bf,$bc,$b9,$b6,$b3
	dc.b	$b0,$ae,$ab,$a8,$a5,$a2,$9f,$9c,$98,$95,$92,$8f,$8c,$89,$86,$83
	dc.b	$80,$7c,$79,$76,$73,$70,$6d,$6a,$67,$63,$60,$5d,$5a,$57,$54,$51
	dc.b	$4f,$4c,$49,$46,$43,$40,$3e,$3b,$38,$36,$33,$31,$2e,$2c,$2a,$27
	dc.b	$25,$23,$21,$1f,$1d,$1b,$19,$17,$15,$13,$12,$10,$0f,$0d,$0c,$0a
	dc.b	$09,$08,$07,$06,$05,$04,$03,$03,$02,$01,$01,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$01,$01,$02,$03,$03,$04,$05,$06,$07,$08
	dc.b	$09,$0a,$0c,$0d,$0f,$10,$12,$13,$15,$17,$19,$1b,$1d,$1f,$21,$23
	dc.b	$25,$27,$2a,$2c,$2e,$31,$33,$36,$38,$3b,$3e,$40,$43,$46,$49,$4c
	dc.b	$4f,$51,$54,$57,$5a,$5d,$60,$63,$67,$6a,$6d,$70,$73,$76,$79,$7c

;--------------------------------------;

CrdList	REPT	Dots
	dc.w	0,0
	ENDR

;--------------------------------------;

Screen1	dcb.b	256*(320/8),0
Screen2	dcb.b	256*(320/8),0
Screen3	dcb.b	256*(320/8),0
Screen4	dcb.b	256*(320/8),0
Screen5	dcb.b	256*(320/8),0
Screen6	dcb.b	256*(320/8),0

