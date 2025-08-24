	SECTION	"GeMaNiX - Text Intro",CODE_C

;--------------------------------------;

WaitBlt	MACRO
	tst.b	2(a5)
WB\@	btst	#6,2(a5)
	bne.b	WB\@
	ENDM

;--------------------------------------;

	bsr	Display
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

	move.w	2(a5),d0
	or.w	#$8000,d0
	move.w	d0,DMACon

	move.l	#Picture,d0
	lea	BPL1(pc),a0
	move.w	d0,6(a0)
	move.w	d0,22(a0)
	swap	d0
	move.w	d0,2(a0)
	move.w	d0,18(a0)

	move.l	#TxtArea,d0
	lea	BPL2(pc),a0
	move.w	d0,6(a0)
	move.w	d0,22(a0)
	swap	d0
	move.w	d0,2(a0)
	move.w	d0,18(a0)

	move.w	$7c(a5),d0
	cmp.b	#$f8,d0
	bne.b	NotAGA
	move.w	#0,$106(a5)
	move.w	#0,$1fc(a5)

NotAGA	move.w	#$7fff,$96(a5)
	move.l  #CList,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$83d0,$96(a5)
	move.l	#0,$144(a5)

MousChk	btst	#6,$bfe001
	bne.b	MousChk

	lea	$dff000,a5
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

;--------------------------------------;

Display	lea	Text(pc),a0
	lea	TxtArea(pc),a2
	lea	TxtArea(pc),a3

DspLoop	cmp.l	#TxAreaE,a3
	bne.b	FndChar
	rts
FndChar	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#10,d0
	beq.b	NewLine
	sub.b	#32,d0
	add.l	#CharSet,d0
	move.l	d0,a1

	move.l	a2,a4
	moveq	#7,d0
TxtLoop	move.b	(a1),(a4)
	lea	188(a1),a1
	lea	80(a4),a4
	dbf	d0,TxtLoop
	addq.l	#1,a2
	bra.b	DspLoop

NewLine	lea	640(a3),a3
	move.l	a3,a2
	bra.b	DspLoop

;--------------------------------------;

DMACon	dc.w	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0020,$0104,$0000
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0180,$0000,$2c07,$fffe
	dc.w	$0180,$0fff,$0182,$0000
	dc.w	$0184,$0bbb,$0186,$0000

	dc.w	$3207,$fffe,$0100,$1200
BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$3407,$fffe,$0100,$2200
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$5007,$fffe,$0100,$0200

	dc.w	$5907,$fffe,$0180,$0000
	dc.w	$5a07,$fffe,$0180,$0fff
	dc.w	$0092,$003c,$0094,$00d4
	dc.w	$0102,$0010
	dc.w	$5c07,$fffe,$0100,$9200
BPL2	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$5d07,$fffe,$0100,$a200
	dc.w	$00e4,$0000,$00e6,$0000

	dc.w	$ffe1,$fffe
	dc.w	$2507,$fffe,$0100,$0200
	dc.w	$2c07,$fffe,$0180,$0000
	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

Picture	incbin	"DH2:TextIntro/Gemanix.raw"
	dcb.b	2*(320/8),0
TxtArea	dcb.b	(25*8)*(640/8),0
TxAreaE	dcb.b	(640/8),0
CharSet	incbin	"DH2:TextIntro/Siesta.font"
Text	incbin	"DH2:TextIntro/Text.txt"
