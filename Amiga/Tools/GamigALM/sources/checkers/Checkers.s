	SECTION	"Checkers",CODE_C

	lea	$dff000,a5
	move.l	4.w,a6
	jsr	-132(a6)

	move.w	2(a5),d0
	or.w	#$8000,d0
	move.w	d0,DMACON

	move.w	$1c(a5),d0		
	or.w	#$c000,d0
	move.w	d0,IntEna

	move.l	#ChkData,d0
	lea	BPL(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	$6c.w,OldIRQ
	move.l	#NewIRQ,$6c.w
	move.w	#$c020,$9a(a5)

	move.w	#$00a0,$96(a5)
	move.l	#CList,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$8080,$96(a5)
	move.l	#0,$144(a5)

WaitMse	btst	#6,$bfe001
	bne	WaitMse

	move.l	$9c(a6),a0
	move.w	#$0080,$96(a5)
	move.l	38(a0),$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$80a0,$96(a5)

	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	OldIRQ(PC),$6c.w
	move.w	IntEna(PC),$9a(a5)

	jsr	-138(a6)
	moveq	#0,d0
	rts

;--------------------------------------;

NewIRQ	movem.l	d0-a6,-(a7)
	bsr	Chckers
	bsr	Chckers
	movem.l	(a7)+,d0-a6
	move.w	#$0020,$9c(a5)
	rte

;--------------------------------------;

Chckers	subq.b	#1,PsTbCnt
	bne.b	NClrGrp
	move.b	#16,PsTbCnt
	move.l	#PosTble,PsTbPnt

	moveq	#8,d2
	lea	ChkrPos+6(pc),a0
	lea	ChkrPos+10(pc),a1
ColChng	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0),d0
	move.w	(a1),d1
	move.w	d1,(a0)
	move.w	d0,(a1)
	lea	12(a0),a0
	lea	12(a1),a1
	dbf	d2,ColChng
	
NClrGrp	lea	ChkrPos(pc),a0
	move.l	PsTbPnt(pc),a1
	move.w	#8,d0
NewPosC	move.b	(a1)+,(a0)
	add.l	#12,a0
	dbf	d0,NewPosC
	add.l	#9,PsTbPnt
	rts	

;--------------------------------------;

DMACON	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
PsTbPnt	dc.l	PosTble
PsTbCnt	dc.b	1
	even

;--------------------------------------;

CList	dc.w	$008e,$0568,$0090,$40d1
	dc.w	$0092,$0028,$0094,$00d8
	dc.w	$0108,$0000,$010a,$0000

	dc.w	$b609,$fffe,$0100,$1200
BPL	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$0180,$0000,$0182,$0000

ChkrPos	dc.w	$b509,$fffe,$0180,$0000,$0182,$0333
	dc.w	$b609,$fffe,$0180,$0555,$0182,$0000
	dc.w	$b909,$fffe,$0180,$0000,$0182,$0777
	dc.w	$bd09,$fffe,$0180,$0999,$0182,$0000
	dc.w	$c109,$fffe,$0180,$0000,$0182,$0bbb
	dc.w	$c709,$fffe,$0180,$0ddd,$0182,$0000
	dc.w	$ce09,$fffe,$0180,$0000,$0182,$0fff
	dc.w	$d809,$fffe,$0180,$0fff,$0182,$0000
	dc.w	$e509,$fffe,$0180,$0000,$0182,$0fff

	dc.w	$f409,$fffe,$0100,$0200
	dc.w	$0180,$0000,$0182,$0000

	dc.w	$ffff,$fffe

;--------------------------------------;

PosTble	dc.b	$b5,$b6,$b9,$bd,$c1,$c7,$ce,$d8,$e5
	dc.b	$b5,$b6,$b9,$bd,$c1,$c7,$cf,$d9,$e6
	dc.b	$b5,$b6,$b9,$bd,$c2,$c8,$d0,$da,$e8
	dc.b	$b5,$b6,$ba,$be,$c2,$c8,$d0,$db,$e9
	dc.b	$b5,$b7,$ba,$be,$c3,$c9,$d1,$db,$ea
	dc.b	$b5,$b7,$ba,$be,$c3,$c9,$d2,$dc,$eb
	dc.b	$b5,$b7,$bb,$bf,$c3,$ca,$d3,$dd,$ec
	dc.b	$b5,$b7,$bb,$bf,$c4,$ca,$d3,$de,$ed

	dc.b	$b6,$b8,$bb,$bf,$c4,$cb,$d4,$de,$ee
	dc.b	$b6,$b8,$bb,$bf,$c5,$cb,$d4,$df,$ef
	dc.b	$b6,$b8,$bc,$c0,$c5,$cc,$d5,$e0,$f0
	dc.b	$b6,$b8,$bc,$c0,$c6,$cc,$d6,$e1,$f1
	dc.b	$b6,$b9,$bc,$c0,$c6,$cd,$d6,$e3,$f2
	dc.b	$b6,$b9,$bd,$c1,$c6,$cd,$d7,$e3,$f3
	dc.b	$b6,$b9,$bd,$c1,$c7,$ce,$d8,$e4,$f4
	dc.b	$b6,$b9,$bd,$c1,$c7,$ce,$d8,$e5,$f4

;--------------------------------------;

ChkData	incbin	"DH2:Checkers/Checkers.raw"

