	SECTION	"GeMaNiX - Dots Twist",CODE_C

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

	bsr.w	MT_Init
	move.l	#Screen1,d0
	lea	BPL1(pc),a0
	move.w	d0,6(a0)
	move.w	d0,14(a0)
	swap	d0
	move.w	d0,2(a0)
	move.w	d0,10(a0)

	move.l	#Logo,d0
	lea	BPL2(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.l	#Sprite,d0
	lea	SPR(pc),a0
	moveq	#1,d7
SPR2Cop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	addq.l	#8,a0
	add.l	#44,d0
	dbf	d7,SPR2Cop

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
	move.l	#0,$144(a5)

MousChk	btst	#6,$bfe001
	bne.b	MousChk

	lea	$dff000,a5
	WaitBlt
	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	OldIRQ(pc),$6c(a4)
	move.w	IntEna(pc),$9a(a5)

	bsr.w	MT_End
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
	bchg	#0,Toggle
	tst.b	Toggle
	beq.b	PrintIt
	bsr.w	ClrDots
	bsr.b	NewChar
	bsr.w	ScrlTxt
	lea	Coords2(pc),a2
	bsr.w	PrntDot
	bra.b	EndIRQ
PrintIt	lea	Coords3(pc),a2
	bsr.w	PrntDot
	bsr.b	NxtScrn
EndIRQ	bsr.w	MT_Music
	movem.l	(a7)+,d0-a6
	move.w	#$0020,$dff09c
	rte

;--------------------------------------;

NxtScrn	movem.l	CurScrn(pc),d0/d1
	exg.l	d0,d1
	movem.l	d0/d1,CurScrn

	lea	BPL1(pc),a0
	move.w	d0,6(a0)
	move.w	d0,14(a0)
	swap	d0
	move.w	d0,2(a0)
	move.w	d0,10(a0)
	rts

;--------------------------------------;

NewChar	sub.b	#1,Counter
	bne.b	CharEnd
	move.b	#8,Counter
	moveq	#0,d0
	move.l	TextPnt(pc),a0
NewText	move.b	(a0)+,d0
	bne.b	TextOK
	lea	Text(pc),a0
	bra.b	NewText
TextOK	move.l	a0,TextPnt
	sub.b	#32,d0
	lsl.w	#3,d0
	lea	FntData(pc),a0
	lea	(a0,d0),a0

	addq.l	#8,a0
	lea	Coords1+4(pc),a1
	moveq	#7,d0
	moveq	#0,d2
	moveq	#1,d3
FindLp1	moveq	#7,d1
FindLp2	btst	d2,-(a0)
	beq.b	NoPtDot
	move.b	d3,(a1)
NoPtDot	addq.l	#1,a1
	dbf	d1,FindLp2
	addq.l	#8,a0
	addq.l	#4,a1
	addq.b	#1,d2
	dbf	d0,FindLp1
CharEnd	rts

;--------------------------------------;

ScrlTxt	lea	CoordsEnd-20(pc),a0
	lea	CoordsEnd-8(pc),a1
	move.l	#79,d0
SclLoop	movem.l	(a0),d1-d2
	movem.l	d1-d2,(a1)
	lea	-12(a0),a0
	lea	-12(a1),a1
	dbf	d0,SclLoop
	rts

;--------------------------------------;

ClrDots	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	WrkScrn(pc),$54(a5)
	move.w	#200<<6+20,$58(a5)
	rts

;--------------------------------------;

PrntDot	WaitBlt
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.w	RadiusX(pc),d4
	move.w	RadiusY(pc),d5
	lea	SinTble(pc),a0
	lea	CosTble(pc),a1
	move.l	WrkScrn(pc),a3

	move.l	#35,d6
PrntLp1	move.l	(a2)+,d0
	moveq	#7,d7
PrntLp2	move.w	(a0,d0),d1
	move.w	(a1,d0),d2
	muls	d4,d1
	muls	d5,d2
	asr.l	#8,d1
	asr.l	#6,d1
	asr.l	#8,d2
	asr.l	#6,d2
	add.w	CenterX(pc),d1
	add.w	CenterY(pc),d2
	move.w	d2,d3
	lsl.w	#3,d2
	lsl.w	#5,d3
	add.l	d3,d2
	lea	(a3,d2),a4

	move.w	d1,d3
	and.w	#$f,d1
	neg.b	d1
	subq.b	#1,d1
	and.b	#$f,d1
	lsr.w	#3,d3
	lea	(a4,d3),a4
	tst.b	(a2)+
	beq.b	NoPrint
	bset	d1,(a4)

NoPrint	addq.w	#Gap,d4
	addq.w	#Gap,d5
	dbf	d7,PrntLp2
	moveq	#Gap*8,d1
	sub.w	d1,d4
	sub.w	d1,d5
	dbf	d6,PrntLp1
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

Gap	= 5
DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0
Toggle	dc.b	0
Counter	dc.b	1
RadiusX	dc.w	40
RadiusY	dc.w	40
CenterX	dc.w	160
CenterY	dc.w	95
TextPnt	dc.l	Text
CurScrn	dc.l	Screen1
WrkScrn	dc.l	Screen2

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0002,$0104,$000f
	dc.w	$0106,$0000,$01fc,$0000
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0180,$0000,$0182,$0fff
	dc.w	$0184,$0001,$0186,$0444
	dc.w	$0188,$0034,$018a,$0fff
	dc.w	$018c,$0001,$018e,$0444
	dc.w	$01a0,$0023,$01a2,$0fff
	dc.w	$01a4,$0444,$01a6,$0023

SPR	dc.w	$0120,$0000,$0122,$0000
	dc.w	$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000

	dc.w	$4c07,$fffe,$0180,$0fff
	dc.w	$4d07,$fffe,$0180,$0023
	dc.w	$4e07,$fffe,$0100,$2200
BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000

	dc.w	$9007,$fffe,$0100,$3200
BPL2	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$cb07,$fffe,$0100,$2200
	dc.w	$ffe1,$fffe

	dc.w	$0b07,$fffe,$0100,$1200
	dc.w	$0c07,$fffe,$0180,$0fff
	dc.w	$0d07,$fffe,$0180,$0000
	dc.w	$1007,$fffe,$0100,$0200
	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

	dc.l	000,0,0
Coords1	dc.l	000,0,0,000,0,0,000,0,0,000,0,0
	dc.l	000,0,0,000,0,0,000,0,0,000,0,0

Coords2	dc.l	000,0,0,002,0,0,004,0,0,006,0,0,008,0,0
	dc.l	010,0,0,012,0,0,014,0,0,016,0,0,018,0,0
	dc.l	020,0,0,022,0,0,024,0,0,026,0,0,028,0,0
	dc.l	030,0,0,032,0,0,034,0,0,036,0,0,038,0,0
	dc.l	040,0,0,042,0,0,044,0,0,046,0,0,048,0,0
	dc.l	050,0,0,052,0,0,054,0,0,056,0,0,058,0,0
	dc.l	060,0,0,062,0,0,064,0,0,066,0,0,068,0,0
	dc.l	070,0,0
Coords3	dc.l	072,0,0,074,0,0,076,0,0,078,0,0
	dc.l	080,0,0,082,0,0,084,0,0,086,0,0,088,0,0
	dc.l	090,0,0,092,0,0,094,0,0,096,0,0,098,0,0
	dc.l	100,0,0,102,0,0,104,0,0,106,0,0,108,0,0
	dc.l	110,0,0,112,0,0,114,0,0,116,0,0,118,0,0
	dc.l	120,0,0,122,0,0,124,0,0,126,0,0,128,0,0
	dc.l	130,0,0,132,0,0,134,0,0,136,0,0,138,0,0
	dc.l	140,0,0,142,0,0
CoordsEnd

SinTble	dc.w	 00000, 01428, 02845, 04240, 05604, 06924
	dc.w	 08192, 09397, 10531, 11585, 12551, 13421
	dc.w	 14189, 14849, 15396, 15826, 16135, 16322
CosTble	dc.w	 16384, 16322, 16135, 15826, 15396, 14849
	dc.w	 14189, 13421, 12551, 11585, 10531, 09397
	dc.w	 08192, 06924, 05604, 04240, 02845, 01428
	dc.w	 00000,-01428,-02845,-04240,-05604,-06924
	dc.w	-08192,-09397,-10531,-11585,-12551,-13421
	dc.w	-14189,-14849,-15396,-15826,-16135,-16322
	dc.w	-16384,-16322,-16135,-15826,-15396,-14849
	dc.w	-14189,-13421,-12551,-11585,-10531,-09397
	dc.w	-08192,-06924,-05604,-04240,-02845,-01428
	dc.w	 00000, 01428, 02845, 04240, 05604, 06924
	dc.w	 08192, 09397, 10531, 11585, 12551, 13421
	dc.w	 14189, 14849, 15396, 15826, 16135, 16322

Sprite	dc.b	$07,$cc,$10,$06,$00,$00,$33,$73,$33,$73,$4c
	dc.b	$8c,$4c,$8c,$b3,$52,$4c,$b3,$90,$0c,$54,$88
	dc.b	$8b,$11,$f3,$6a,$2c,$f7,$0c,$f7,$13,$08,$00
	dc.b	$00,$0c,$f7,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$07,$d4,$10,$06,$00,$00,$e7,$30,$e7,$30,$10
	dc.b	$c8,$18,$48,$24,$04,$1e,$48,$81,$14,$98,$50
	dc.b	$04,$8c,$ff,$ee,$60,$30,$10,$00,$8f,$c0,$10
	dc.b	$00,$00,$00,$00,$00,$10,$00,$00,$00,$00,$00

FntData	include	"DH2:DotsTwist/DotsTwist.inc"
Text	dc.b	"  The Dots Twist, Written by Robster of GeMaNiX in 1993    "
	dc.b	"Greets to Hydsie for lots of phonecalls and bugtesting all "
	dc.b	"of my intros...       ",0
	even
Screen1	dcb.b	200*(320/8),0
Screen2	dcb.b	200*(320/8),0
Logo	incbin	"DH2:DotsTwist/Gemanix.raw"
MT_Data	incbin	"DH2:DotsTwist/mod.Zapped-Out"
