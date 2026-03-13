	SECTION	"Wraith Intro",CODE_C

Start	move.l	4.w,a6
	jsr	-132(a6)
	lea	$dff000,a5

	bsr.w	MT_Init
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

	move.l	#TopPic,d0
	lea	BPL1(pc),a0
	moveq	#4,d7
Pic2Cop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	moveq	#40,d1
	add.l	d1,d0
	addq.l	#8,a0
	dbf	d7,Pic2Cop

	move.l	#TxtArea,d0
	lea	BPL2(pc),a0
	moveq	#2,d7
Txt2Cop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	moveq	#42,d1
	add.l	d1,d0
	addq.l	#8,a0
	dbf	d7,Txt2Cop

	move.l	#SPR1,d0
	move.w	d0,SPR+6
	swap	d0
	move.w	d0,SPR+2
	move.l	#SPR2,d0
	move.w	d0,SPR+14
	swap	d0
	move.w	d0,SPR+10

	move.w	#$7fff,$96(a5)
	move.l  #CList,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$83e0,$96(a5)

MousChk	btst	#6,$bfe001
	bne.b	MousChk

	bsr.w	MT_End
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
	bsr.b	Display
	bsr.w	MT_Music
	movem.l	(a7)+,d0-a6
	move.w	#$0020,$dff09c
	rte

;--------------------------------------;

Display	tst.w	DspWait
	beq.b	NoWait
	sub.w	#1,DspWait
	rts
NoWait	sub.b	#1,ChrWait
	bne.b	MoveTxt
	bsr.w	DisLoop

MoveTxt	bsr.w	WaitBlt
	move.l	#$c9f00000,$40(a5)
	move.l	#$ffffffff,$44(a5)
	move.l	#TxtArea,$50(a5)
	move.l	#TxtArea-(16/8),$54(a5)
	move.l	#$00000000,$64(a5)
	move.w	#3*(17*8)*64+21,$58(a5)
	tst.b	ChrStop
	beq.b	StopTxt
	sub.b	#1,ChrStop
DispEnd	rts

StopTxt	move.b	#81,ChrStop
	move.b	#1,ChrWait
	move.b	#0,TextHrz
	add.l	#600,TextPnt
	cmp.l	#TextEnd,TextPnt
	blt.b	StopEnd
	move.l	#Text,TextPnt
StopEnd	move.w	#Delay*50,DspWait
	rts

DisLoop	moveq	#0,d0
	moveq	#0,d1
	move.b	TextVrt(pc),d0
ChckHrz	move.b	TextHrz(pc),d1
	mulu	#40,d0
	add.l	d1,d0
	add.l	TextPnt(pc),d0
	move.l	d0,a0
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0),d1
	sub.b	#32,d1
	divu.w	#(320/16),d1
	move.w	d1,d0
	swap.w	d1
	mulu.w	#(16/8),d1
	mulu.w	#3*8*(320/8),d0
	add.l	d1,d0
	add.l	#Font,d0

	bsr.b	WaitBlt
	move.l	d0,$50(a5)
	move.l	TextScn(pc),$54(a5)
	move.l	#$09f00000,$40(a5)
	move.l	#$ffffffff,$44(a5)
	move.w  #38,$64(a5)
	move.w  #40,$66(a5)
	move.w  #3*8*64+1,$58(a5)

	add.l	#(3*42*8),TextScn
	add.b	#1,TextVrt
	cmp.b	#15,TextVrt
	bne.w	DisLoop
	move.b	#0,TextVrt
	add.b	#1,TextHrz
	move.l	#TxtArea+40,TextScn
	move.b	#2,ChrWait
	rts

WaitBlt	btst	#14,2(a5)
	bne.b	WaitBlt
	rts

;--------------------------------------;

mt_init:lea	mt_data,a0
	move.l	a0,a1
	add.l	#$3b8,a1
	moveq	#$7f,d0
	moveq	#0,d1
mt_loop:move.l	d1,d2
	subq.w	#1,d0
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.b	mt_loop
	dbf	d0,mt_lop2
	addq.b	#1,d2

	lea	mt_samplestarts(PC),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$43c,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	or.b	#$2,$bfe001
	move.b	#$6,mt_speed
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	rts

mt_end:	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

mt_music:
	movem.l	d0-d4/a0-a3/a5-a6,-(a7)
	lea	mt_data,a0
	addq.b	#1,mt_counter
	move.b	mt_counter,D0
	cmp.b	mt_speed,D0
	blt.b	mt_nonew
	clr.b	mt_counter
	bra.w	mt_getnew

mt_nonew:
	lea	mt_voice1(PC),a6
	lea	$dff0a0,a5
	bsr.w	mt_checkcom
	lea	mt_voice2(PC),a6
	lea	$dff0b0,a5
	bsr.w	mt_checkcom
	lea	mt_voice3(PC),a6
	lea	$dff0c0,a5
	bsr.w	mt_checkcom
	lea	mt_voice4(PC),a6
	lea	$dff0d0,a5
	bsr.w	mt_checkcom
	bra.w	mt_endr

mt_arpeggio:
	moveq	#0,d0
	move.b	mt_counter,d0
	divs	#$3,d0
	swap	d0
	cmp.w	#$0,d0
	beq.b	mt_arp2
	cmp.w	#$2,d0
	beq.b	mt_arp1

	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	bra.b	mt_arp3

mt_arp1:moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	bra.b	mt_arp3

mt_arp2:move.w	$10(a6),d2
	bra.b	mt_arp4

mt_arp3:asl.w	#1,d0
	moveq	#0,d1
	move.w	$10(a6),d1
	lea	mt_periods(PC),a0
	moveq	#$24,d7

mt_arploop:
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.b	mt_arp4
	addq.l	#2,a0
	dbf	d7,mt_arploop
	rts

mt_arp4:move.w	d2,$6(a5)
	rts

mt_getnew:
	lea	mt_data,a0
	move.l	a0,a3
	move.l	a0,a2
	add.l	#$c,a3
	add.l	#$3b8,a2
	add.l	#$43c,a0

	moveq	#0,d0
	move.l	d0,d1
	move.b	mt_songpos,d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_pattpos,d1
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_voice1(PC),a6
	bsr.b	mt_playvoice
	lea	$dff0b0,a5
	lea	mt_voice2(PC),a6
	bsr.b	mt_playvoice
	lea	$dff0c0,a5
	lea	mt_voice3(PC),a6
	bsr.b	mt_playvoice
	lea	$dff0d0,a5
	lea	mt_voice4(PC),a6
	bsr.b	mt_playvoice
	bra.w	mt_setdma

mt_playvoice:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.b	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(PC),a1
	move.l	d2,d4
	subq.l	#$1,d2
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2.l),$4(a6)
	move.w	(a3,d4.l),$8(a6)
	move.w	$2(a3,d4.l),$12(a6)
	move.w	$4(a3,d4.l),d3
	tst.w	d3
	beq.b	mt_noloop
	move.l	$4(a6),d2
	asl.w	#1,d3
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$4(a3,d4.l),d0
	add.w	$6(a3,d4.l),d0
	move.w	d0,8(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
	bra.b	mt_setregs

mt_noloop:
	move.l	$4(a6),d2
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)

mt_setregs:
	move.w	(a6),d0
	and.w	#$fff,d0
	beq.w	mt_checkcom2
	move.b	$2(a6),d0
	and.b	#$F,d0
	cmp.b	#$3,d0
	bne.b	mt_setperiod
	bsr.w	mt_setmyport
	bra.w	mt_checkcom2

mt_setperiod:
	move.w	(a6),$10(a6)
	and.w	#$fff,$10(a6)
	move.w	$14(a6),d0
	move.w	d0,$dff096
	clr.b	$1b(a6)

	move.l	$4(a6),(a5)
	move.w	$8(a6),$4(a5)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	move.w	$14(a6),d0
	or.w	d0,mt_dmacon
	bra.w	mt_checkcom2

mt_setdma:
	move.b	$dff006,d0
	add.b	#3,d0

mt_wait:cmp.b	$dff006,d0
	bne.b	mt_wait
	move.w	mt_dmacon,d0
	or.w	#$8000,d0
	move.w	d0,$dff096
	move.w	#$12c,d0
mt_wai2:dbf	d0,mt_wai2
	lea	$dff000,a5
	lea	mt_voice4(PC),a6
	move.l	$a(a6),$d0(a5)
	move.w	$e(a6),$d4(a5)

	lea	mt_voice3(PC),a6
	move.l	$a(a6),$c0(a5)
	move.w	$e(a6),$c4(a5)

	lea	mt_voice2(PC),a6
	move.l	$a(a6),$b0(a5)
	move.w	$e(a6),$b4(a5)

	lea	mt_voice1(PC),a6
	move.l	$a(a6),$a0(a5)
	move.w	$e(a6),$a4(a5)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.b	mt_endr
mt_nex:	clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos,d1
	cmp.b	mt_data+$3b6,d1
	bne.b	mt_endr
	clr.b	mt_songpos
mt_endr:tst.b	mt_break
	bne.b	mt_nex
	movem.l	(a7)+,d0-d4/a0-a3/a5-a6
	rts

mt_setmyport:
	move.w	(a6),d2
	and.w	#$fff,d2
	move.w	d2,$18(a6)
	move.w	$10(a6),d0
	clr.b	$16(a6)
	cmp.w	d0,d2
	beq.b	mt_clrport
	bge.b	mt_rt
	move.b	#$1,$16(a6)
	rts

mt_clrport:
	clr.w	$18(a6)
mt_rt:	rts

mt_myport:
	move.b	$3(a6),d0
	beq.b	mt_myslide
	move.b	d0,$17(a6)
	clr.b	$3(a6)

mt_myslide:
	tst.w	$18(a6)
	beq.b	mt_rt
	moveq	#0,d0
	move.b	$17(a6),d0
	tst.b	$16(a6)
	bne.b	mt_mysub
	add.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	bgt.b	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
mt_myok:move.w	$10(a6),$6(a5)
	rts

mt_mysub:
	sub.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	blt.b	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
	move.w	$10(a6),$6(a5)
	rts

mt_vib:	move.b	$3(a6),d0
	beq.b	mt_vi
	move.b	d0,$1a(a6)

mt_vi:	move.b	$1b(a6),d0
	lea	mt_sin(PC),a4
	lsr.w	#$2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.b	$1a(a6),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	move.w	$10(a6),d0
	tst.b	$1b(a6)
	bmi.b	mt_vibmin
	add.w	d2,d0
	bra.b	mt_vib2

mt_vibmin:
	sub.w	d2,d0
mt_vib2:move.w	d0,$6(a5)
	move.b	$1a(a6),d0
	lsr.w	#$2,d0
	and.w	#$3c,d0
	add.b	d0,$1b(a6)
	rts

mt_nop:	move.w	$10(a6),$6(a5)
	rts

mt_checkcom:
	move.w	$2(a6),d0
	and.w	#$fff,d0
	beq.b	mt_nop
	move.b	$2(a6),d0
	and.b	#$f,d0
	tst.b	d0
	beq.w	mt_arpeggio
	cmp.b	#$1,d0
	beq.b	mt_portup
	cmp.b	#$2,d0
	beq.w	mt_portdown
	cmp.b	#$3,d0
	beq.w	mt_myport
	cmp.b	#$4,d0
	beq.w	mt_vib
	move.w	$10(a6),$6(a5)
	cmp.b	#$a,d0
	beq.b	mt_volslide
	rts

mt_volslide:
	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.b	mt_voldown
	add.w	d0,$12(a6)
	cmp.w	#$40,$12(a6)
	bmi.b	mt_vol2
	move.w	#$40,$12(a6)
mt_vol2:move.w	$12(a6),$8(a5)
	rts

mt_voldown:
	moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	sub.w	d0,$12(a6)
	bpl.b	mt_vol3
	clr.w	$12(a6)
mt_vol3:move.w	$12(a6),$8(a5)
	rts

mt_portup:
	moveq	#0,d0
	move.b	$3(a6),d0
	sub.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$71,d0
	bpl.b	mt_por2
	and.w	#$f000,$10(a6)
	or.w	#$71,$10(a6)
mt_por2:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_portdown:
	clr.w	d0
	move.b	$3(a6),d0
	add.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$358,d0
	bmi.b	mt_por3
	and.w	#$f000,$10(a6)
	or.w	#$358,$10(a6)
mt_por3:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_checkcom2:
	move.b	$2(a6),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.b	mt_setfilt
	cmp.b	#$d,d0
	beq.b	mt_pattbreak
	cmp.b	#$b,d0
	beq.b	mt_posjmp
	cmp.b	#$c,d0
	beq.b	mt_setvol
	cmp.b	#$f,d0
	beq.b	mt_setspeed
	rts

mt_setfilt:
	move.b	$3(a6),d0
	and.b	#$1,d0
	asl.b	#$1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_pattbreak:
	not.b	mt_break
	rts

mt_posjmp:
	move.b	$3(a6),d0
	subq.b	#$1,d0
	move.b	d0,mt_songpos
	not.b	mt_break
	rts

mt_setvol:
	cmp.b	#$40,$3(a6)
	ble.b	mt_vol4
	move.b	#$40,$3(a6)
mt_vol4:move.b	$3(a6),$8(a5)
	rts

mt_setspeed:
	move.b	$3(a6),d0
	and.w	#$1f,d0
	beq.b	mt_rts2
	clr.b	mt_counter
	move.b	d0,mt_speed
mt_rts2:rts

mt_sin:	dc.b	$00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0
	dc.b	$eb,$f4,$fa,$fd,$ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5
	dc.b	$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods:
	dc.w	$0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a
	dc.w	$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d,$0168
	dc.w	$0153,$0140,$012e,$011d,$010d,$00fe,$00f0,$00e2
	dc.w	$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f
	dc.w	$0087,$007f,$0078,$0071,$0000,$0000

mt_speed:	dc.b	$6
mt_songpos:	dc.b	$0
mt_pattpos:	dc.w	$0
mt_counter:	dc.b	$0

mt_break:	dc.b	$0
mt_dmacon:	dc.w	$0
mt_samplestarts:blk.l	$1f,0
mt_voice1:	blk.w	10,0
		dc.w	$1
		blk.w	3,0
mt_voice2:	blk.w	10,0
		dc.w	$2
		blk.w	3,0
mt_voice3:	blk.w	10,0
		dc.w	$4
		blk.w	3,0
mt_voice4:	blk.w	10,0
		dc.w	$8
		blk.w	3,0

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
TextPnt	dc.l	Text
TextVrt	dc.b	0
TextHrz	dc.b	0
ChrWait	dc.b	1
ChrStop	dc.b	81
DspWait	dc.w	0
TextScn	dc.l	TxtArea+40

;--------------------------------------;

CList	dc.w	$008e,$2c89,$0090,$2cc9
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0104,$0000,$0102,$0077
SPR	dc.w	$0120,$0000,$0122,$0000
	dc.w	$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000
	dc.w	$01a2,$0464,$01a4,$0020
	dc.w	$01a6,$0000

	dc.w	$0108,$00a0,$010a,$00a0


;-----------	COLOURS FOR TOP PICTURE

	dc.w	$0180,$0000,$0182,$0fff,$0184,$0efe,$0186,$0ded
	dc.w	$0188,$0cdc,$018a,$0bcb,$018c,$0aba,$018e,$09a9
	dc.w	$0190,$0898,$0192,$0787,$0194,$0676,$0196,$0565
	dc.w	$0198,$0454,$019a,$0343,$019c,$0232,$019e,$0121

;-----------

BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$00f0,$0000,$00f2,$0000
	dc.w	$2c09,$fffe,$0100,$5200

	dc.w	$5e09,$fffe,$0100,$0200
	dc.w	$6009,$fffe,$0180,$0464
	dc.w	$6109,$fffe


;-----------	COLOURS FOR FONT

	dc.w	$0180,$0000,$0182,$0fff,$0184,$0cdc,$0186,$09b9
	dc.w	$0188,$0686,$018a,$0464,$018c,$0242,$018e,$0121

;-----------

	dc.w	$0108,$0058,$010a,$0058
	dc.w	$0092,$0034,$0094,$00c4
BPL2	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$6b09,$fffe,$0100,$3200

	dc.w	$ec09,$fffe,$0180,$0464
	dc.w	$ed09,$fffe,$0180,$0000
	dc.w	$f409,$fffe,$0100,$0200
	dc.w	$ffff,$fffe
	dc.w	$496e,$7472,$6f20,$6d61
	dc.w	$6465,$2062,$7920,$526f
	dc.w	$6273,$7465,$7220,$696e
	dc.w	$2031,$3939,$3321,$2020

SPR1	dc.b	$e7,$cc,$f0,$00,$00,$00,$33,$73,$33,$73,$4c
	dc.b	$8c,$4c,$8c,$b3,$52,$4c,$b3,$90,$0c,$54,$88
	dc.b	$8b,$11,$f3,$6a,$2c,$f7,$0c,$f7,$13,$08,$00
	dc.b	$00,$0c,$f7,$00,$00,$00,$00,$00,$00,$00,$00
SPR2	dc.b	$e7,$d4,$f0,$00,$00,$00,$e7,$30,$e7,$30,$10
	dc.b	$c8,$18,$48,$24,$04,$1e,$48,$81,$14,$98,$50
	dc.b	$04,$8c,$ff,$ee,$60,$30,$10,$00,$8f,$c0,$10
	dc.b	$00,$00,$00,$00,$00,$10,$00,$00,$00,$00,$00

;--------------------------------------;

Text	dc.b	" @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ "
	dc.b	" @                                    @ "
	dc.b	" @                                    @ "
	dc.b	" @ YO MAN, HERES THE INTRO YOU WANTED @ "
	dc.b	" @  I HOPE THIS IS THE SORT YOU LIKE  @ "
	dc.b	" @                                    @ "
	dc.b	" @   EACH SCREEN HAS TO BE 15 LINES   @ "
	dc.b	" @         DOWN AND 38 ACROSS         @ "
	dc.b	" @                                    @ "
	dc.b	" @    EACH SCREEN TAKES 20 SECONDS    @ "
	dc.b	" @ TO CHANGE OVER AND YOU CAN HAVE AS @ "
	dc.b	" @   MANY SCREENS AS YOU CAN HANDLE   @ "
	dc.b	" @                                    @ "
	dc.b	" @                                    @ "
	dc.b	" @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ "

	dc.b	" @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ "
	dc.b	" @                                    @ "
	dc.b	" @              @@@@@@@@@             @ "
	dc.b	" @             @         @            @ "
	dc.b	" @             @  @@ @@  @            @ "
	dc.b	" @             @  @@ @@  @            @ "
	dc.b	" @             @  @@ @@  @            @ "
	dc.b	" @             @         @            @ "
	dc.b	" @             @ @@   @@ @            @ "
	dc.b	" @             @ @@   @@ @            @ "
	dc.b	" @             @  @@@@@  @            @ "
	dc.b	" @             @         @            @ "
	dc.b	" @              @@@@@@@@@             @ "
	dc.b	" @                                    @ "
	dc.b	" @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ "

TextEnd	dcb.b	40,32

;--------------------------------------------------------------------;

Delay		= 20				;Seconds before next screen

TopPic	incbin	"DH2:Wraith/Wraith.raw"		;Raw Blit of Logo
Font	incbin	"DH2:Wraith/Font.raw"		;Raw Blit of Font
MT_Data	incbin	"DH2:Wraith/mod.IntroFronty"	;ST-Format Module
TxtArea	dcb.b	3*(20*8)*(336/8),0
