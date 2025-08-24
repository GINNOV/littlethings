	SECTION	"Bar Cycle",CODE_C

Start	move.l	4.w,a6
	jsr	-132(a6)
	lea	$dff000,a5

	move.w	2(a5),d0
	or.w	#$8000,d0
	move.w	d0,DMACon

	move.w	$1c(a5),d0		
	or.w	#$c000,d0
	move.w	d0,IntEna

	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	$6c.w,OldIRQ
	move.l	#NewIRQ,$6c.w
	move.w	#$c020,$9a(a5)

	move.w	#$7fff,$96(a5)
	move.l	#CList,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$87c0,$96(a5)
	move.l	#0,$144(a5)

ChkMous	btst	#6,$bfe001
	bne.b	ChkMous

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

Wait	btst	#14,2(a5)
	bne.b	Wait

	jsr	-138(a6)
	moveq	#0,d0
	rts

;--------------------------------------;

NewIRQ	movem.l	d0-a6,-(a7)
	bsr.w	CycLeft
	bsr.w	CycRght
	movem.l	(a7)+,d0-a6
	move.w	#$0020,$9c(a5)
	rte

;--------------------------------------;

CycLeft	move.l	#$09f00000,$40(a5)
	move.l	#$ffffffff,$44(a5)
	move.l	CycPntL(pc),$50(a5)
	move.l	#CycBarL+2,$54(a5)
	move.w	#0,$64(a5)
	move.w	#2,$66(a5)
	move.w	#56<<6+1,$58(a5)

	addq.l	#2,CycPntL
	cmp.l	#CycNewT,CycPntL
	bne.b	CycEndL
	move.l	#CyclTab,CycPntL
CycEndL	rts

;--------------------------------------;

CycRght	move.l	#$09f00000,$40(a5)
	move.l	#$ffffffff,$44(a5)
	move.l	CycPntR(pc),$50(a5)
	move.l	#CycBarR+2,$54(a5)
	move.w	#0,$64(a5)
	move.w	#2,$66(a5)
	move.w	#56<<6+1,$58(a5)

	subq.l	#2,CycPntR
	cmp.l	#CyclTab,CycPntR
	bne.b	CycEndR
	move.l	#CycNewT,CycPntR
CycEndR	rts

;--------------------------------------;

CycPntL	dc.l	CyclTab
CycPntR	dc.l	CycNewT

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0

;--------------------------------------;

CyclTab	dc.w	$00f0,$01f0,$02f0,$03f0,$04f0,$05f0,$06f0,$07f0
	dc.w	$08f0,$09f0,$0af0,$0bf0,$0cf0,$0df0,$0ef0,$0ff0
	dc.w	$0fe0,$0fd0,$0fc0,$0fb0,$0fa0,$0f90,$0f80,$0f70
	dc.w	$0f60,$0f50,$0f40,$0f30,$0f20,$0f10,$0f00,$0f01
	dc.w	$0f02,$0f03,$0f04,$0f05,$0f06,$0f07,$0f08,$0f09
	dc.w	$0f0a,$0f0b,$0f0c,$0f0d,$0f0e,$0f0f,$0e0f,$0d0f
	dc.w	$0c0f,$0b0f,$0a0f,$090f,$080f,$070f,$060f,$050f
	dc.w	$040f,$030f,$020f,$010f,$000f,$001f,$002f,$003f
	dc.w	$004f,$005f,$006f,$007f,$008f,$009f,$00af,$00bf
	dc.w	$00cf,$00df,$00ef,$00ff,$00fe,$00fd,$00fc,$00fb
	dc.w	$00fa,$00f9,$00f8,$00f7,$00f6,$00f5,$00f4,$00f3
	dc.w	$00f2,$00f1
CycNewT	dc.w	$00f0,$01f0,$02f0,$03f0,$04f0,$05f0,$06f0,$07f0
	dc.w	$08f0,$09f0,$0af0,$0bf0,$0cf0,$0df0,$0ef0,$0ff0
	dc.w	$0fe0,$0fd0,$0fc0,$0fb0,$0fa0,$0f90,$0f80,$0f70
	dc.w	$0f60,$0f50,$0f40,$0f30,$0f20,$0f10,$0f00,$0f01
	dc.w	$0f02,$0f03,$0f04,$0f05,$0f06,$0f07,$0f08,$0f09
	dc.w	$0f0a,$0f0b,$0f0c,$0f0d,$0f0e,$0f0f,$0e0f,$0d0f
	dc.w	$0c0f,$0b0f,$0a0f,$090f,$080f,$070f,$060f,$050f
	dc.w	$040f,$030f,$020f,$010f,$000f,$001f,$002f,$003f
	dc.w	$004f,$005f,$006f,$007f,$008f,$009f,$00af,$00bf
	dc.w	$00cf,$00df,$00ef,$00ff,$00fe,$00fd,$00fc,$00fb
	dc.w	$00fa,$00f9,$00f8,$00f7,$00f6,$00f5,$00f4,$00f3
	dc.w	$00f2,$00f1
CyclTabEnd

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0180,$0000,$0182,$0fff

	dc.w	$2c09,$fffe,$0100,$0200
CycBarL	dc.w	$0180,$00f0,$0180,$01f0,$0180,$02f0,$0180,$03f0
	dc.w	$0180,$04f0,$0180,$05f0,$0180,$06f0,$0180,$07f0
	dc.w	$0180,$08f0,$0180,$09f0,$0180,$0af0,$0180,$0bf0
	dc.w	$0180,$0cf0,$0180,$0df0,$0180,$0ef0,$0180,$0ff0
	dc.w	$0180,$0fe0,$0180,$0fd0,$0180,$0fc0,$0180,$0fb0
	dc.w	$0180,$0fa0,$0180,$0f90,$0180,$0f80,$0180,$0f70
	dc.w	$0180,$0f60,$0180,$0f50,$0180,$0f40,$0180,$0f30
	dc.w	$0180,$0f20,$0180,$0f10,$0180,$0f00,$0180,$0f01
	dc.w	$0180,$0f02,$0180,$0f03,$0180,$0f04,$0180,$0f05
	dc.w	$0180,$0f06,$0180,$0f07,$0180,$0f08,$0180,$0f09
	dc.w	$0180,$0f0a,$0180,$0f0b,$0180,$0f0c,$0180,$0f0d
	dc.w	$0180,$0f0e,$0180,$0f0f,$0180,$0e0f,$0180,$0d0f
	dc.w	$0180,$0c0f,$0180,$0b0f,$0180,$0a0f,$0180,$090f
	dc.w	$0180,$080f,$0180,$070f,$0180,$060f,$0180,$050f
	dc.w	$2d09,$fffe,$0180,$0000

	dc.w	$f309,$fffe
CycBarR	dc.w	$0180,$00f0,$0180,$01f0,$0180,$02f0,$0180,$03f0
	dc.w	$0180,$04f0,$0180,$05f0,$0180,$06f0,$0180,$07f0
	dc.w	$0180,$08f0,$0180,$09f0,$0180,$0af0,$0180,$0bf0
	dc.w	$0180,$0cf0,$0180,$0df0,$0180,$0ef0,$0180,$0ff0
	dc.w	$0180,$0fe0,$0180,$0fd0,$0180,$0fc0,$0180,$0fb0
	dc.w	$0180,$0fa0,$0180,$0f90,$0180,$0f80,$0180,$0f70
	dc.w	$0180,$0f60,$0180,$0f50,$0180,$0f40,$0180,$0f30
	dc.w	$0180,$0f20,$0180,$0f10,$0180,$0f00,$0180,$0f01
	dc.w	$0180,$0f02,$0180,$0f03,$0180,$0f04,$0180,$0f05
	dc.w	$0180,$0f06,$0180,$0f07,$0180,$0f08,$0180,$0f09
	dc.w	$0180,$0f0a,$0180,$0f0b,$0180,$0f0c,$0180,$0f0d
	dc.w	$0180,$0f0e,$0180,$0f0f,$0180,$0e0f,$0180,$0d0f
	dc.w	$0180,$0c0f,$0180,$0b0f,$0180,$0a0f,$0180,$090f
	dc.w	$0180,$080f,$0180,$070f,$0180,$060f,$0180,$050f
	dc.w	$f409,$fffe,$0180,$0000

	dc.w	$ffff,$fffe
