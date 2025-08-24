	SECTION	"GeMaNiX - Blue Intro",CODE_C

Delay	= 10				;Seconds before next screen

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

	move.l	#Picture,d0
	lea	BPL1(pc),a0
	moveq	#3,d7
Pic2Cop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40,d0
	addq.l	#8,a0
	dbf	d7,Pic2Cop

	move.l	#TxtArea,d0
	lea	BPL2(pc),a0
	moveq	#2,d7
Txt2Cop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40,d0
	addq.l	#8,a0
	dbf	d7,Txt2Cop

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
	bsr.b	ComChck
	movem.l	(a7)+,d0-a6
	move.w	#$0020,$dff09c
	rte

;--------------------------------------;

ComChck	move.l	ComdPnt(pc),a0
	move.l	(a0),a0
	jmp	(a0)
ComLoop	move.l	#ComList,ComdPnt
	rts

;--------------------------------------;

PrtInit	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	#TxtArea,$54(a5)
	move.w	#3*140<<6+20,$58(a5)
	move.b	#20,Dummy
	addq.l	#4,ComdPnt
	rts

PrtText	move.l	TextPnt(pc),a0
	move.l	PagePnt(pc),a1
	move.l	#$8000<<16,d2
	moveq	#2,d3
	swap	d3
	moveq	#0,d4

	moveq	#39,d7
PrtLoop	moveq	#0,d0
	move.l	d0,d1
	move.b	(a0)+,d1
	sub.b	#32,d1
	divu	#20,d1			;Number of characters per line
	move.w	d1,d0
	swap.w	d1
	ext.l	d1
	lsl.l	#1,d1			;Width of Font
	mulu	#3*7*40,d0		;Planes*FontHeight*PageWidth
	add.l	d1,d0
	add.l	#Font,d0

	WaitBlt
	move.w	d2,d4
	or.w	#$0bfa,d4
	move.w	d4,$40(a5)
	move.w	#0,$42(a5)
	move.l	#$ffffffff,$44(a5)
	move.l	d0,$50(a5)
	move.l	a1,$48(a5)
	move.l	a1,$54(a5)
	move.w	#38,$60(a5)
	move.w	#38,$64(a5)
	move.w	#38,$66(a5)
	move.w	#3*7<<6+1,$58(a5)

	move.w	d3,d4
	add.l	d4,a1
	swap	d3
	swap	d2
	dbf	d7,PrtLoop
	add.l	#3*7*(320/8),PagePnt
	add.l	#41,TextPnt
	subq.b	#1,Dummy
	bne	PrntEnd
	move.l	#TxtArea,PagePnt
	addq.l	#4,ComdPnt
	cmp.b	#-1,1(a0)
	bne	PrntEnd
	move.l	#Text,TextPnt
PrntEnd	rts

;--------------------------------------;

FdeUInt	move.b	#15,Dummy
	addq.l	#4,ComdPnt
FadeUp	lea	Colours+2(pc),a0
	lea	ColChrt(pc),a1
	moveq	#7,d7
FadeLpU	move.w	(a1)+,d0
	bsr	FRed
	addq.l	#4,a0
	dbf	d7,FadeLpU
	bra	FadeEnd

;--------------------------------------;

FdeDInt	move.b	#15,Dummy
	addq.l	#4,ComdPnt
FadeDwn	lea	Colours+2(pc),a0
	moveq	#0,d0
	moveq	#7,d7
FadeLpD	bsr	FRed
	addq.l	#4,a0
	dbf	d7,FadeLpD

;--------------------------------------;

FadeEnd	tst.b	Dummy
	bne	FdNtFin
	addq.l	#4,ComdPnt
FdNtFin	subq.b	#1,Dummy
	rts

;--------------------------------------;

FRed	moveq	#0,d3

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$0f00,d1
	and.w	#$0f00,d2
	cmp.w	d1,d2
	beq.b	FGreen
	blt.b	SubRed
	sub.w	#$0100,d2
	bra.b	FGreen
SubRed	add.w	#$0100,d2
FGreen	add.w	d2,d3
	move.w	(a0),d2

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$00f0,d1
	and.w	#$00f0,d2
	cmp.w	d1,d2
	beq.b	FBlue
	blt.b	SubGrn
	sub.w	#$0010,d2
	bra.b	FBlue
SubGrn	add.w	#$0010,d2
FBlue	add.w	d2,d3
	move.w	(a0),d2

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$000f,d1
	and.w	#$000f,d2
	cmp.w	d1,d2
	beq.b	FFinshd
	blt.b	SubBlu
	sub.w	#$0001,d2
	bra.b	FFinshd
SubBlu	add.w	#$0001,d2
FFinshd	add.w	d2,d3
	move.w	(a0),d2

	move.w	d3,(a0)
	rts

;--------------------------------------;

TxWaitI	move.w	#Delay*50,Dummy
	addq.l	#4,ComdPnt
TxtWait	subq.w	#1,Dummy
	bne	TxWtEnd
	addq.l	#4,ComdPnt
TxWtEnd	rts

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0
Dummy	dc.w	0
TextPnt	dc.l	Text
PagePnt	dc.l	TxtArea
ComdPnt	dc.l	ComList
ComList	dc.l	PrtInit
	dc.l	PrtText
	dc.l	FdeUInt
	dc.l	FadeUp
	dc.l	TxWaitI
	dc.l	TxtWait
	dc.l	FdeDInt
	dc.l	FadeDwn
	dc.l	ComLoop

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0106,$0000,$01fc,$0000

	dc.w	$0180,$0000,$0182,$046f
	dc.w	$0184,$035e,$0186,$024d
	dc.w	$0188,$013c,$018a,$002b
	dc.w	$018c,$001a,$018e,$0009
	dc.w	$0190,$0008,$0192,$0007
	dc.w	$0194,$0006,$0196,$0005
	dc.w	$0198,$0004,$019a,$0003
	dc.w	$019c,$0002,$019e,$034e

	dc.w	$0108,$0078,$010a,$0078
	dc.w	$4d07,$fffe,$0100,$4200
BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000

	dc.w	$6107,$fffe,$0100,$0200
	dc.w	$6307,$fffe,$0180,$024e
	dc.w	$6407,$fffe

Colours	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000

	dc.w	$0108,$0050,$010a,$0050
	dc.w	$6507,$fffe,$0100,$3200
BPL2	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000

	dc.w	$f107,$fffe,$0100,$0200
	dc.w	$f207,$fffe,$0180,$024e
	dc.w	$f307,$fffe,$0180,$0000
	dc.w	$f407,$fffe,$0100,$0200
	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

ColChrt	dc.w	$0000,$0fff,$0cde,$09be,$079d,$047d,$026c,$004c

Picture	incbin	"DH2:BlueIntro/Gemanix.raw"
Font	incbin	"DH2:BlueIntro/Font.raw"
TxtArea	dcb.b	3*140*(320/8),0
Text	incbin	"DH2:BlueIntro/BlueIntro.txt"
	dc.b	-1,0
