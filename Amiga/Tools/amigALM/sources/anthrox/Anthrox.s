	SECTION	"Anthrox Intro",CODE_C

	movem.l	d0-a6,-(a7)
	lea	OldTrap(pc),a0
	lea	$80.w,a1
	move.l	(a1),(a0)
	lea	Intro(pc),a0
	move.l	a0,(a1)
	trap	#0

	move.l	OldTrap(pc),$80.w
	and.b	#$fd,$f01(a4)
	move.w	#$7fff,$9a(a5)
	move.w	IntEna(pc),d0
	or.w	#$c008,d0
	move.w	d0,$9a(a5)
	move.w	#$7fff,$96(a5)
	clr.l	$180(a5)
	move.w	DMACon(pc),d0
	or.w	#$8020,d0
	move.w	d0,$96(a5)

	move.l	4.w,a6
	lea	GfxName(pc),a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,a1
	move.l	38(a1),$80(a5)
	jsr	-414(a6)

	jsr	-138(a6)
	movem.l	(a7)+,d0-a6
	moveq	#0,d0
	rts

Intro	bsr.s	InstSpr
	bsr.l	InstPic
	bsr.s	IntInit
	bsr.l	PrntTxt
	rte

IntInit	move.l	4.w,a6
	jsr	-132(a6)
	lea	$dff000,a5
	lea	DMACon(pc),a0
	move.w	2(a5),(a0)+
	move.w	$1c(a5),(a0)
	move.w	#$7fff,$96(a5)
	move.w	#$7fff,$9a(a5)
	lea	CList(pc),a0
	move.l	a0,$80(a5)
	movem.l	d0-a6,-(a7)
	bsr.l	MT_Init
	movem.l	(a7)+,d0-a6
	move.w	#$8380,$96(a5)
	clr.w	$88(a5)
	move.w	#$c008,$9a(a5)
	or.b	#2,$bfe001
	or.b	#$f8,$bfd100
	and.b	#$87,$bfd100
	or.b	#$f8,$bfd100
	rts

InstSpr	lea	SPRData(pc),a0
	move.l	a0,d0
	lea	SPR(pc),a1
	moveq	#7,d1
SPRLoop	bsr.s	Insert
	addq.l	#8,a0
	dbf	d1,SPRLoop
	rts

InstPic	lea	TxtArea,a0
	move.l	a0,d0
	lea	BPL1(pc),a1
	bsr.s	Insert
	lea	BPL2(pc),a1
	add.l	#88,d0
	bsr.s	Insert

	lea	PicData(pc),a0
	move.l	a0,d0
	lea	BPL3(pc),a1
	moveq	#4,d1
PicLoop	bsr.s	Insert
	addq.l	#8,a1
	add.l	#2800,d0
	dbf	d1,PicLoop
	rts

Insert	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	rts

PrntTxt	lea	Text(pc),a0
	lea	TxtArea+(3*88),a1
	moveq	#0,d4
	moveq	#88,d2
SortTxt	bsr.s	ChkChar
	beq.s	SortTxt

MainLp	cmp.b	#$be,6(a5)
	bne.s	MainLp
	movem.l	d0-a6,-(a7)
	bsr.l	MT_Music
	movem.l	(a7)+,d0-a6
	cmp.b	#$75,$bfec01
	beq.s	KeyPrsd
	btst	#2,$16(a5)
	bne.s	MainLp
KeyPrsd	rts

ChkChar	bsr.s	SkpLine
	bne.s	NoNwLne
	moveq	#88,d2
	lea	(9*88)(a1),a1
NoNwLne	tst.w	d4
	rts

SkpLine	subq.w	#1,d2
	moveq	#0,d0
	move.b	(a0)+,d0
	bne.s	NewLine
	moveq	#0,d2
	lea	88(a1),a1
	rts

NewLine	cmp.b	#-2,d0
	bne.s	EndText
	add.l	d2,a1
	moveq	#0,d2
	addq.l	#1,a1
	rts

EndText	cmp.b	#-1,d0
	bne.s	NrmChar
	moveq	#-1,d4
	rts

NrmChar	sub.b	#32,d0
	ext.w	d0
	lea	FntData(pc),a2
	lea	(a2,d0.w),a2
	moveq	#7,d0
	move.l	a1,a3
PrtLoop	move.b	(a2),(a3)
	lea	94(a2),a2
	lea	88(a3),a3
	dbf	d0,PrtLoop
	addq.l	#1,a1
	tst.w	d2
	rts

Text
 dc.b "    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=",-2
 dc.b "    =-=-=-=-=-=-=-=-=-=-=        A . N . T . H . R . O . X        =-=-=-=-=-=-=-=-=-=-=",-2
 dc.b "    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=",-2
 dc.b "    =-=-=-=-=-=-=-=-=-=-=             Cracked For You             =-=-=-=-=-=-=-=-=-=-=",-2
 dc.b "    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=",-2
 dc.b 0
 dc.b "                               Chuck Rock II - Son Of Chuck!",-2
 dc.b "                               @@@@@@@@@@@@@@@@@@@@@@@@@@@@@",-2
 dc.b "                                     From Core Design",-2
 dc.b 0
 dc.b "                           Original Supplied By The UK's Finest!",-2
 dc.b "                       Cracked To Perfection By Anthrox Uk Division!",-2
 dc.b 0
 dc.b "      Note:  This Release Is Dedicated To: Vindex, Mymurth, Red Alert, Cevin Key And",-2
 dc.b "                                           Mascot,    ALL Are Non-Believers! -HYDRo!",-2
 dc.b 0
 dc.b "                         -+- True QUALITY Comes In Small Doses! -+-",-2
 dc.b -1
 even

CList	dc.w	$008e,$2c75,$0090,$2cc9
	dc.w	$0092,$0030,$0094,$00d8
	dc.w	$0100,$0200
	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0108,$0000,$010a,$0000

SPR	dc.w	$0120,$0007,$0122,$fff0
	dc.w	$0124,$0007,$0126,$fff0
	dc.w	$0128,$0007,$012a,$fff0
	dc.w	$012c,$0007,$012e,$fff0
	dc.w	$0130,$0007,$0132,$fff0
	dc.w	$0134,$0007,$0136,$fff0
	dc.w	$0138,$0007,$013a,$fff0
	dc.w	$013c,$0007,$013e,$fff0

	dc.w	$0180,$0000,$0182,$0002
	dc.w	$0184,$0088,$0186,$0088

	dc.w	$2d07,$fffe,$0180,$0aaa
	dc.w	$2e07,$fffe,$0180,$0001
	dc.w	$0186,$0088,$0184,$0889

	dc.w	$3107,$fffe
BPL1	dc.w	$00e0,$0000,$00e2,$0000
BPL2	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$0100,$a200,$0102,$0001

	dc.w	$6d07,$fffe,$0186,$0889,$0184,$0aaa
	dc.w	$8e07,$fffe,$0186,$0088,$0184,$0889

	dc.w	$e007,$fffe,$0180,$0aaa,$0100,$0200
	dc.w	$e107,$fffe,$0180,$0000

	dc.w	$e201,$fffe,$0092,$0038,$0094,$00d0
BPL3	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$00f0,$0000,$00f2,$0000
	dc.w	$e307,$fffe,$0100,$5200

	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0108,$0000,$010a,$0000

	dc.w	$0182,$0eee,$0184,$0adf
	dc.w	$0186,$08bd,$0188,$079b
	dc.w	$018a,$0679,$018c,$0446
	dc.w	$018e,$0334,$0190,$0112
	dc.w	$0192,$0113,$0194,$0224
	dc.w	$0196,$0235,$0198,$0346
	dc.w	$019a,$0456,$019c,$0355
	dc.w	$019e,$0678,$01a0,$0cef
	dc.w	$01a2,$0add,$01a4,$08bb
	dc.w	$01a6,$07aa,$01a8,$0689
	dc.w	$01aa,$0567,$01ac,$0456
	dc.w	$01ae,$0234,$01b0,$0cfe
	dc.w	$01b2,$0afe,$01b4,$07ed
	dc.w	$01b6,$06cb,$01b8,$05ba
	dc.w	$01ba,$0498,$01bc,$0276
	dc.w	$01be,$0265,$ffdf,$fffe

	dc.w	$2907,$fffe,$0100,$0200
	dc.w	$2b07,$fffe,$0180,$0aaa
	dc.w	$2c07,$fffe,$0180,$0000
	dc.w	$ffff,$fffe

DMACon	dc.w	0
IntEna	dc.w	0
OldTrap	dc.l	0
SPRData	dc.l	0,0
GfxName	dc.b	"graphics.library",0,0
PicData	incbin	"DH2:Anthrox/Anthrox.raw"
FntData	incbin	"DH2:Anthrox/Anthrox.fnt"
Replay	include	"DH2:Anthrox/Replay.i"
MT_Data	incbin	"DH2:Anthrox/Anthrox.mod"
TxtArea	dcb.b	176*88,0
