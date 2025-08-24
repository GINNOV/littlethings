	SECTION	"Another World II Intro",CODE_C

Forbid		= -132
Permit		= -138

;--------------------------------------;

	move.l	4.w,a6
	jsr	Forbid(a6)
	lea	$dff000,a5

	move.l	#Picture,d0
	lea	Screen(pc),a0
	moveq	#4,d1
PicCop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#$12c0,d0
	add.l	#8,a0
	dbf	d1,PicCop

	move.l	#TxtArea,d0
	move.w	d0,BPL+6
	swap	d0
	move.w	d0,BPL+2
	swap	d0
	add.b	#40,d0
	move.w	d0,BPL+14
	swap	d0
	move.w	d0,BPL+10

	move.w	$1c(a5),d0
	or.w	#$c000,d0
	move.w	d0,IntEna

	move.w	2(a5),d0
	or.w	#$8000,d0
	move.w	d0,DMACON

	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	$6c,OldIRQ
	move.l	#NewIRQ,$6c
	move.w	#$c028,$9a(a5)

	move.w	#$7fff,$96(a5)
	move.l  #CList,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$83c0,$96(a5)

Mouse	bsr.b	Display
	btst	#6,$bfe001
	bne.b	Mouse

	lea	$dff000,a5
	move.w	#$0020,$9a(a5)
	move.w	#$0020,$9c(a5)
	move.l	OldIRQ(pc),$6c
	move.w	IntEna(pc),$9a(a5)

	move.l	$9c(a6),a1
	move.w	#$0080,$96(a5)
	move.l	38(a1),$80(a5)
	move.w	#$0000,$88(a5)
	move.w	DMACON(pc),$96(a5)

	jsr	Permit(a6)
	moveq	#0,d0
	rts

;--------------------------------------;

NewIRQ	movem.l	d0-a6,-(a7)
	bsr.w	Cycle
	movem.l	(a7)+,d0-a6
	move.w	#$0020,$dff09c
	rte

;--------------------------------------;

Display	sub.w	#1,Delay
	tst.w	Delay
	bne.b	EndDisp
	move.w	#2000,Delay
	tst.b	TxtSwch
	beq.b	EndDisp
	moveq	#0,d0
	move.l	TxtPnt(pc),a0
	move.b	(a0),d0
	cmp.b	#0,d0
	beq.b	NewLine
	cmp.b	#1,d0
	beq.w	Reset
	sub.b	#32,d0
	mulu	#8,d0
	add.l	#CharSet,d0
	move.l	d0,a0
	move.l	CSPos(pc),a1

	move.b	(a0)+,(a1)
	move.b	(a0)+,040(a1)
	move.b	(a0)+,080(a1)
	move.b	(a0)+,120(a1)
	move.b	(a0)+,160(a1)
	move.b	(a0)+,200(a1)
	move.b	(a0)+,240(a1)
	move.b	(a0)+,280(a1)

	add.l	#1,TxtPnt
	add.l	#1,CSPos
EndDisp	rts

NewLine	cmp.b	#3,ScrlTst
	beq.b	ScrlUp
	add.b	#1,ScrlTst
	add.l	#320,CLine
	move.l	Cline(pc),CSPos
	add.l	#1,TxtPnt
	rts

ScrlUp	moveq	#7,d0
	move.l	#7000,d1
SclLoop	dbf	d1,SclLoop
	move.l	#7000,d1
WaitBlt	btst	#14,2(a5)
	bne.b	WaitBlt

	move.l	#$09f00000,$40(a5)
	move.l	#$ffffffff,$44(a5)
	move.l	#TxtArea+40,$50(a5)
	move.l	#TxtArea+00,$54(a5)
	move.l	#$00000000,$64(a5)
	move.w	#79*64*1+20,$58(a5)
	dbf	d0,SclLoop
	move.l	Cline(pc),CSPos
	add.l	#1,TxtPnt
	rts

Reset	move.l	#TxtArea,CSPos
	clr.b	CLine
	clr.b	TxtSwch
	rts

;--------------------------------------;

Cycle	move.l	CyclPnt(pc),a3

	lea	CLeftB1+2(pc),a0
	lea	CLeftB1+6(pc),a1
	moveq	#54,d0
CyclLp1	move.w	(a1),(a0)
	add.l	#4,a0
	add.l	#4,a1
	dbf	d0,CyclLp1

	lea	CLeftB2+2(pc),a2
	lea	CLeftB2+6(pc),a1
	moveq	#54,d0
CyclLp2	move.w	(a1),(a2)
	add.l	#4,a1
	add.l	#4,a2
	dbf	d0,CyclLp2

	move.w	(a3),(a0)
	move.w	(a3),(a2)
	add.l	#2,CyclPnt

	cmp.l	#CTblEnd,CyclPnt
	bne.b	CyclEnd
	move.l	#CTble,CyclPnt
CyclEnd	rts

;--------------------------------------;

DMACON	dc.w	0
IntEna	dc.w	0
OldIrq	dc.l	0

CSPos	dc.l	TxtArea
TxtPnt	dc.l	Text
CLine	dc.l	TxtArea
Delay	dc.w	2000
TxtSwch	dc.b	1
ScrlTst	dc.b	0
CyclPnt	dc.l	CTble

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0096,$0020,$0104,$0000
	dc.w	$01a2,$0000,$01a4,$0000,$01a6,$0000

	dc.w	$0180,$0000,$0182,$0aaa,$0184,$0f00,$0186,$0a00
	dc.w	$0188,$0b22,$018a,$0c44,$018c,$0f70,$018e,$0d22
	dc.w	$0190,$0c00,$0192,$0a00,$0194,$0800,$0196,$0600
	dc.w	$0198,$0fff,$019a,$0ddd,$019c,$0ccc,$019e,$0aaa
	dc.w	$01a0,$0999,$01a2,$0888,$01a4,$0666,$01a6,$0555
	dc.w	$01a8,$0444,$01aa,$0333,$01ac,$0000,$01ae,$0040
	dc.w	$01b0,$0051,$01b2,$0162,$01b4,$0174,$01b6,$0335
	dc.w	$01b8,$0222,$01ba,$0200,$01bc,$0400,$01be,$0020

	dc.w	$2c09,$fffe,$0100,$5200
Screen	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$00f0,$0000,$00f2,$0000

	dc.w	$a009,$fffe,$0100,$0200
	dc.w	$be09,$fffe

CLeftB1	dc.w	$0180,$0f00,$0180,$0e00,$0180,$0d00,$0180,$0c00
	dc.w	$0180,$0b00,$0180,$0a00,$0180,$0900,$0180,$0800
	dc.w	$0180,$0700,$0180,$0600,$0180,$0500,$0180,$0400
	dc.w	$0180,$0300,$0180,$0200,$0180,$0100,$0180,$0000
	dc.w	$0180,$0100,$0180,$0200,$0180,$0300,$0180,$0400
	dc.w	$0180,$0500,$0180,$0600,$0180,$0700,$0180,$0800
	dc.w	$0180,$0900,$0180,$0a00,$0180,$0b00,$0180,$0c00
	dc.w	$0180,$0d00,$0180,$0e00,$0180,$0f00,$0180,$0e00
	dc.w	$0180,$0d00,$0180,$0c00,$0180,$0b00,$0180,$0a00
	dc.w	$0180,$0900,$0180,$0800,$0180,$0700,$0180,$0600
	dc.w	$0180,$0500,$0180,$0400,$0180,$0300,$0180,$0200
	dc.w	$0180,$0100,$0180,$0000,$0180,$0100,$0180,$0200
	dc.w	$0180,$0300,$0180,$0400,$0180,$0500,$0180,$0600
	dc.w	$0180,$0700,$0180,$0800,$0180,$0900,$0180,$0a00

	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0180,$0000,$0182,$0fff
	dc.w	$c009,$fffe,$0100,$1200
BPL	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000

	dc.w	$e009,$fffe
CLeftB2	dc.w	$0180,$0f00,$0180,$0e00,$0180,$0d00,$0180,$0c00
	dc.w	$0180,$0b00,$0180,$0a00,$0180,$0900,$0180,$0800
	dc.w	$0180,$0700,$0180,$0600,$0180,$0500,$0180,$0400
	dc.w	$0180,$0300,$0180,$0200,$0180,$0100,$0180,$0000
	dc.w	$0180,$0100,$0180,$0200,$0180,$0300,$0180,$0400
	dc.w	$0180,$0500,$0180,$0600,$0180,$0700,$0180,$0800
	dc.w	$0180,$0900,$0180,$0a00,$0180,$0b00,$0180,$0c00
	dc.w	$0180,$0d00,$0180,$0e00,$0180,$0f00,$0180,$0e00
	dc.w	$0180,$0d00,$0180,$0c00,$0180,$0b00,$0180,$0a00
	dc.w	$0180,$0900,$0180,$0800,$0180,$0700,$0180,$0600
	dc.w	$0180,$0500,$0180,$0400,$0180,$0300,$0180,$0200
	dc.w	$0180,$0100,$0180,$0000,$0180,$0100,$0180,$0200
	dc.w	$0180,$0300,$0180,$0400,$0180,$0500,$0180,$0600
	dc.w	$0180,$0700,$0180,$0800,$0180,$0900,$0180,$0a00

	dc.w	$e109,$fffe,$0100,$0200
	dc.w	$0180,$0000,$ffff,$fffe

;----------------------------------------------------------;

CTble	dc.w	$0b00,$0c00,$0d00,$0e00,$0f00,$0e00,$0d00,$0c00
	dc.w	$0b00,$0a00,$0900,$0800,$0700,$0600,$0500,$0400
	dc.w	$0300,$0200,$0100,$0000,$0100,$0200,$0300,$0400
	dc.w	$0500,$0600,$0700,$0800,$0900,$0a00
CTblEnd

;----------------------------------------------------------;

CharSet	include	"DH1:AW2Intro/ScoopexFont.chr"
Picture	incbin	"DH1:AW2Intro/SuicidalsStone.raw"
TxtArea	dcb.b	10000,0

Text	dc.b	"       ROBSTER OF THE SUICIDALS       ",0
	dc.b	"                PRESENTS              ",0
	dc.b	"     ANOTHER WORLD II - BACKFLASH     ",0
	dc.b	"     ----------------------------     ",0
	dc.b	"                                      ",0
	dc.b	"            SHORT HELLOS TO:          ",0
	dc.b	"              HYDSIE (TKK)            ",0
	dc.b	"               BAD BARTY              ",0
	dc.b	"                AWESOME               ",0
	dc.b	"                                      ",0
	dc.b	"  YOU CAN REACH ME AT - P.O. BOX 428  ",0
	dc.b	"                        WHANGAREI     ",0
	dc.b	"                        AOTEAROA      ",1
	even
