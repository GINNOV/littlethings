	SECTION	"GeMaNiX - Sine Scroller",CODE_C

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

	bsr	MT_Init
	move.w	$1c(a5),d0
	or.w	#$c000,d0
	move.w	d0,IntEna

	move.w	2(a5),d0
	or.w	#$8000,d0
	move.w	d0,DMACon

	move.l	CurrScn(pc),d0
	lea	BPL(pc),a0
	move.w	d0,6(a0)
	move.w	d0,22(a0)
	swap	d0
	move.w	d0,2(a0)
	move.w	d0,18(a0)

	move.l	#SPR1,d0
	move.l	#SPR2,d1
	lea	SPR(pc),a0
	move.w	d0,6(a0)
	move.w	d1,14(a0)
	swap	d0
	swap	d1
	move.w	d0,2(a0)
	move.w	d1,10(a0)

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

	bsr	MT_End
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
	bsr.w	SinScrl
	bsr.w	BltScrl
	bsr.w	NxtScrn
	bsr	MT_Music
	movem.l	(a7)+,d0-a6
	move.w	#$0020,$9c(a5)
	rte

;--------------------------------------;

NxtScrn	movem.l	CurrScn(pc),d0/d1
	exg.l	d0,d1
	movem.l	d0/d1,CurrScn

Insert	lea	BPL(pc),a0
	move.w	d0,6(a0)
	move.w	d0,22(a0)
	swap	d0
	move.w	d0,2(a0)
	move.w	d0,18(a0)
	rts

;--------------------------------------;

BltScrl	tst.w	PauseP
	beq.b	Scroll
	subq.w	#1,PauseP
	rts
Scroll	tst.w	Counter
	bne.b	ScrllIt
	move.w	#8,Counter

GetTxCh	move.l	CharPnt(pc),a0
	moveq	#0,d0
	move.b	(a0)+,d0
	bne.s	GrabChr
	move.l	#ScrMess,CharPnt
	bra.s	GetTxCh

GrabChr	cmp.b	#"a",d0
	beq.w	Pause
	move.l	a0,CharPnt
	sub.b	#32,d0
	lsl.l	#5,d0
	add.l	#FntData,d0

	WaitBlt
	move.l	#$09f00000,$40(a5)
	move.l	#$ffffffff,$44(a5)
	move.l	d0,$50(a5)
	move.l	#SclArea+40,$54(a5)
	move.w	#0,$64(a5)
	move.w	#40,$66(a5)
	move.w	#16<<6+1,$58(a5)

ScrllIt	WaitBlt
	move.l	#$e9f00000,$40(a5)
	move.l	#$ffffffff,$44(a5)
	move.l	#SclArea,$50(a5)
	move.l	#SclArea-(16/8),$54(a5)
	move.l	#0,$64(a5)
	move.w	#17<<6+20,$58(a5)
	sub.w	#1,Counter
	rts

Pause	move.w	#Seconds*50,PauseP
	move.w	#0,Counter
	move.l	a0,CharPnt
	rts

;--------------------------------------;

SinScrl	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	WorkScn(pc),$54(a5)
	move.w	#196<<6+20,$58(a5)

	WaitBlt
	move.w	#38,$62(a5)
	move.w	#40,$64(a5)
	move.w	#38,$66(a5)
	move.l	#$0dfc0000,$40(a5)
	move.l	SinePnt(pc),a1
	lea	SclArea(pc),a2

	moveq	#0,d0
	move.l	d0,d1
	move.w	#%1000000000000000,d0
	moveq	#19,d6
SnLoop1	moveq	#15,d7
SnLoop2	move.l	WorkScn(pc),a0
	lea	(a0,d1),a0
	moveq	#0,d2
	move.b	(a1),d2

	move.w	d2,d3
	lsl.w	#3,d3
	lsl.w	#5,d2
	add.w	d3,d2
	add.w	d2,a0

	lea	(a2,d1),a3

	WaitBlt
	move.l	a0,$4c(a5)
	move.l	a3,$50(a5)
	move.l	a0,$54(a5)
	move.w	d0,$44(a5)
	move.w	#17<<6+1,$58(a5)

	ror.w	#1,d0
	addq.l	#1,a1
	cmp.l	#SineEnd,a1
	blt.b	NoNewSn
	sub.l	#320,a1
NoNewSn	dbf	d7,SnLoop2
	addq.l	#2,d1
	dbf	d6,SnLoop1
	subq.l	#1,a1
	move.l	a1,SinePnt
SinEnd	rts

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
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0
CharPnt	dc.l	ScrMess
Counter	dc.w	0
PauseP	dc.w	0
SinePnt	dc.l	SinTble
CurrScn	dc.l	Screen1
WorkScn	dc.l	Screen2

;--------------------------------------;

	dc.w	0
SinTble	dc.b	$00,$00,$00,$00,$00,$01,$01,$01,$01,$02,$02,$02,$03,$03,$04,$04
	dc.b	$05,$05,$06,$06,$07,$08,$09,$09,$0a,$0b,$0c,$0d,$0e,$0f,$0f,$10
	dc.b	$12,$13,$14,$15,$16,$17,$18,$19,$1b,$1c,$1d,$1f,$20,$21,$23,$24
	dc.b	$25,$27,$28,$2a,$2b,$2d,$2e,$30,$31,$33,$35,$36,$38,$39,$3b,$3d
	dc.b	$3e,$40,$42,$43,$45,$47,$48,$4a,$4c,$4e,$4f,$51,$53,$55,$56,$58
	dc.b	$5a,$5c,$5d,$5f,$61,$63,$64,$66,$68,$6a,$6b,$6d,$6f,$70,$72,$74
	dc.b	$75,$77,$79,$7a,$7c,$7d,$7f,$81,$82,$84,$85,$87,$88,$8a,$8b,$8d
	dc.b	$8e,$8f,$91,$92,$93,$95,$96,$97,$99,$9a,$9b,$9c,$9d,$9e,$9f,$a0
	dc.b	$a2,$a3,$a3,$a4,$a5,$a6,$a7,$a8,$a9,$a9,$aa,$ab,$ac,$ac,$ad,$ad
	dc.b	$ae,$ae,$af,$af,$b0,$b0,$b0,$b1,$b1,$b1,$b1,$b2,$b2,$b2,$b2,$b2
	dc.b	$b2,$b2,$b2,$b2,$b2,$b1,$b1,$b1,$b1,$b0,$b0,$b0,$af,$af,$ae,$ae
	dc.b	$ad,$ad,$ac,$ac,$ab,$aa,$a9,$a9,$a8,$a7,$a6,$a5,$a4,$a3,$a3,$a2
	dc.b	$a0,$9f,$9e,$9d,$9c,$9b,$9a,$99,$97,$96,$95,$93,$92,$91,$8f,$8e
	dc.b	$8d,$8b,$8a,$88,$87,$85,$84,$82,$81,$7f,$7d,$7c,$7a,$79,$77,$75
	dc.b	$74,$72,$70,$6f,$6d,$6b,$6a,$68,$66,$64,$63,$61,$5f,$5d,$5c,$5a
	dc.b	$58,$56,$55,$53,$51,$4f,$4e,$4c,$4a,$48,$47,$45,$43,$42,$40,$3e
	dc.b	$3d,$3b,$39,$38,$36,$35,$33,$31,$30,$2e,$2d,$2b,$2a,$28,$27,$25
	dc.b	$24,$23,$21,$20,$1f,$1d,$1c,$1b,$19,$18,$17,$16,$15,$14,$13,$12
	dc.b	$10,$0f,$0f,$0e,$0d,$0c,$0b,$0a,$09,$09,$08,$07,$06,$06,$05,$05
	dc.b	$04,$04,$03,$03,$02,$02,$02,$01,$01,$01,$01,$00,$00,$00,$00,$00
SineEnd

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0010,$0104,$0000
	dc.w	$0106,$0000,$01fc,$0000
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0180,$0000,$0182,$0fff
	dc.w	$0184,$0555,$01a2,$000f
	dc.w	$01a4,$0005,$01a6,$0000

SPR	dc.w	$0120,$0000,$0122,$0000,$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000,$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000,$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000,$013c,$0000,$013e,$0000

	dc.w	$2c07,$fffe,$0180,$000f
	dc.w	$2d07,$fffe,$0180,$0000
	dc.w	$2e07,$fffe,$0186,$0f20
	dc.w	$0100,$2200
BPL	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$2f07,$fffe,$0186,$0f30
	dc.w	$00e4,$0000,$00e6,$0000

	dc.w	$3007,$fffe,$0186,$0f40,$3107,$fffe,$0186,$0f50
	dc.w	$3207,$fffe,$0186,$0f60,$3307,$fffe,$0186,$0f70
	dc.w	$3407,$fffe,$0186,$0f80,$3507,$fffe,$0186,$0f90
	dc.w	$3607,$fffe,$0186,$0fa0,$3707,$fffe,$0186,$0fb0
	dc.w	$3807,$fffe,$0186,$0fc0,$3907,$fffe,$0186,$0fd0
	dc.w	$3a07,$fffe,$0186,$0fe0,$3b07,$fffe,$0186,$0ff0
	dc.w	$3c07,$fffe,$0186,$0ef0,$3d07,$fffe,$0186,$0df0
	dc.w	$3e07,$fffe,$0186,$0cf0,$3f07,$fffe,$0186,$0bf0
	dc.w	$4007,$fffe,$0186,$0af0,$4107,$fffe,$0186,$09f0
	dc.w	$4207,$fffe,$0186,$08f0,$4307,$fffe,$0186,$07f0
	dc.w	$4407,$fffe,$0186,$06f0,$4507,$fffe,$0186,$05f0
	dc.w	$4607,$fffe,$0186,$04f0,$4707,$fffe,$0186,$03f0
	dc.w	$4807,$fffe,$0186,$02f0,$4907,$fffe,$0186,$01f0
	dc.w	$4a07,$fffe,$0186,$00f0,$4b07,$fffe,$0186,$00f1
	dc.w	$4c07,$fffe,$0186,$00f2,$4d07,$fffe,$0186,$00f3
	dc.w	$4e07,$fffe,$0186,$00f4,$4f07,$fffe,$0186,$00f5
	dc.w	$5007,$fffe,$0186,$00f6,$5107,$fffe,$0186,$00f7
	dc.w	$5207,$fffe,$0186,$00f8,$5307,$fffe,$0186,$00f9
	dc.w	$5407,$fffe,$0186,$00fa,$5507,$fffe,$0186,$00fb
	dc.w	$5607,$fffe,$0186,$00fc,$5707,$fffe,$0186,$00fd
	dc.w	$5807,$fffe,$0186,$00fe,$5907,$fffe,$0186,$00ff
	dc.w	$5a07,$fffe,$0186,$00ef,$5b07,$fffe,$0186,$00df
	dc.w	$5c07,$fffe,$0186,$00cf,$5d07,$fffe,$0186,$00bf
	dc.w	$5e07,$fffe,$0186,$00af,$5f07,$fffe,$0186,$009f
	dc.w	$6007,$fffe,$0186,$008f,$6107,$fffe,$0186,$007f
	dc.w	$6207,$fffe,$0186,$006f,$6307,$fffe,$0186,$005f
	dc.w	$6407,$fffe,$0186,$004f,$6507,$fffe,$0186,$003f
	dc.w	$6607,$fffe,$0186,$002f,$6707,$fffe,$0186,$001f
	dc.w	$6807,$fffe,$0186,$000f,$6907,$fffe,$0186,$010f
	dc.w	$6a07,$fffe,$0186,$020f,$6b07,$fffe,$0186,$030f
	dc.w	$6c07,$fffe,$0186,$040f,$6d07,$fffe,$0186,$050f
	dc.w	$6e07,$fffe,$0186,$060f,$6f07,$fffe,$0186,$070f
	dc.w	$7007,$fffe,$0186,$080f,$7107,$fffe,$0186,$090f
	dc.w	$7207,$fffe,$0186,$0a0f,$7307,$fffe,$0186,$0b0f
	dc.w	$7407,$fffe,$0186,$0c0f,$7507,$fffe,$0186,$0d0f
	dc.w	$7607,$fffe,$0186,$0e0f,$7707,$fffe,$0186,$0f0f
	dc.w	$7807,$fffe,$0186,$0f0e,$7907,$fffe,$0186,$0f0d
	dc.w	$7a07,$fffe,$0186,$0f0c,$7b07,$fffe,$0186,$0f0b
	dc.w	$7c07,$fffe,$0186,$0f0a,$7d07,$fffe,$0186,$0f09
	dc.w	$7e07,$fffe,$0186,$0f08,$7f07,$fffe,$0186,$0f07
	dc.w	$8007,$fffe,$0186,$0f06,$8107,$fffe,$0186,$0f05
	dc.w	$8207,$fffe,$0186,$0f04,$8307,$fffe,$0186,$0f03
	dc.w	$8407,$fffe,$0186,$0f02,$8507,$fffe,$0186,$0f01
	dc.w	$8607,$fffe,$0186,$0f00,$8707,$fffe,$0186,$0f10
	dc.w	$8807,$fffe,$0186,$0f20,$8907,$fffe,$0186,$0f30
	dc.w	$8a07,$fffe,$0186,$0f40,$8b07,$fffe,$0186,$0f50
	dc.w	$8c07,$fffe,$0186,$0f60,$8d07,$fffe,$0186,$0f70
	dc.w	$8e07,$fffe,$0186,$0f80,$8f07,$fffe,$0186,$0f90
	dc.w	$9007,$fffe,$0186,$0fa0,$9107,$fffe,$0186,$0fb0
	dc.w	$9207,$fffe,$0186,$0fc0,$9307,$fffe,$0186,$0fd0
	dc.w	$9407,$fffe,$0186,$0fe0,$9507,$fffe,$0186,$0ff0
	dc.w	$9607,$fffe,$0186,$0ef0,$9707,$fffe,$0186,$0df0
	dc.w	$9807,$fffe,$0186,$0cf0,$9907,$fffe,$0186,$0bf0
	dc.w	$9a07,$fffe,$0186,$0af0,$9b07,$fffe,$0186,$09f0
	dc.w	$9c07,$fffe,$0186,$08f0,$9d07,$fffe,$0186,$07f0
	dc.w	$9e07,$fffe,$0186,$06f0,$9f07,$fffe,$0186,$05f0
	dc.w	$a007,$fffe,$0186,$04f0,$a107,$fffe,$0186,$03f0
	dc.w	$a207,$fffe,$0186,$02f0,$a307,$fffe,$0186,$01f0
	dc.w	$a407,$fffe,$0186,$00f0,$a507,$fffe,$0186,$00f1
	dc.w	$a607,$fffe,$0186,$00f2,$a707,$fffe,$0186,$00f3
	dc.w	$a807,$fffe,$0186,$00f4,$a907,$fffe,$0186,$00f5
	dc.w	$aa07,$fffe,$0186,$00f6,$ab07,$fffe,$0186,$00f7
	dc.w	$ac07,$fffe,$0186,$00f8,$ad07,$fffe,$0186,$00f9
	dc.w	$ae07,$fffe,$0186,$00fa,$af07,$fffe,$0186,$00fb
	dc.w	$b007,$fffe,$0186,$00fc,$b107,$fffe,$0186,$00fd
	dc.w	$b207,$fffe,$0186,$00fe,$b307,$fffe,$0186,$00ff
	dc.w	$b407,$fffe,$0186,$00ef,$b507,$fffe,$0186,$00df
	dc.w	$b607,$fffe,$0186,$00cf,$b707,$fffe,$0186,$00bf
	dc.w	$b807,$fffe,$0186,$00af,$b907,$fffe,$0186,$009f
	dc.w	$ba07,$fffe,$0186,$008f,$bb07,$fffe,$0186,$007f
	dc.w	$bc07,$fffe,$0186,$006f,$bd07,$fffe,$0186,$005f
	dc.w	$be07,$fffe,$0186,$004f,$bf07,$fffe,$0186,$003f
	dc.w	$c007,$fffe,$0186,$002f,$c107,$fffe,$0186,$001f
	dc.w	$c207,$fffe,$0186,$000f,$c307,$fffe,$0186,$010f
	dc.w	$c407,$fffe,$0186,$020f,$c507,$fffe,$0186,$030f
	dc.w	$c607,$fffe,$0186,$040f,$c707,$fffe,$0186,$050f
	dc.w	$c807,$fffe,$0186,$060f,$c907,$fffe,$0186,$070f
	dc.w	$ca07,$fffe,$0186,$080f,$cb07,$fffe,$0186,$090f
	dc.w	$cc07,$fffe,$0186,$0a0f,$cd07,$fffe,$0186,$0c0f
	dc.w	$ce07,$fffe,$0186,$0d0f,$cf07,$fffe,$0186,$0e0f
	dc.w	$d007,$fffe,$0186,$0f0f,$d107,$fffe,$0186,$0f0e
	dc.w	$d207,$fffe,$0186,$0f0d,$d307,$fffe,$0186,$0f0c
	dc.w	$d407,$fffe,$0186,$0f0b,$d507,$fffe,$0186,$0f0a
	dc.w	$d607,$fffe,$0186,$0f09,$d707,$fffe,$0186,$0f08
	dc.w	$d807,$fffe,$0186,$0f07,$d907,$fffe,$0186,$0f06
	dc.w	$da07,$fffe,$0186,$0f05,$db07,$fffe,$0186,$0f04
	dc.w	$dc07,$fffe,$0186,$0f03,$dd07,$fffe,$0186,$0f02
	dc.w	$de07,$fffe,$0186,$0f01,$df07,$fffe,$0186,$0f00
	dc.w	$e007,$fffe,$0186,$0f10,$e107,$fffe,$0186,$0f20
	dc.w	$e207,$fffe,$0186,$0f30,$e307,$fffe,$0186,$0f40
	dc.w	$e407,$fffe,$0186,$0f50,$e507,$fffe,$0186,$0f60
	dc.w	$e607,$fffe,$0186,$0f70,$e707,$fffe,$0186,$0f80
	dc.w	$e807,$fffe,$0186,$0f90,$e907,$fffe,$0186,$0fa0
	dc.w	$ea07,$fffe,$0186,$0fb0,$eb07,$fffe,$0186,$0fc0
	dc.w	$ec07,$fffe,$0186,$0fd0,$ed07,$fffe,$0186,$0fe0
	dc.w	$ee07,$fffe,$0186,$0ff0,$ef07,$fffe,$0186,$0ef0

	dc.w	$f007,$fffe,$0180,$000f,$f107,$fffe,$0180,$0000
	dc.w	$f407,$fffe,$0100,$0200

	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

SPR1	dc.b	$eb,$cc,$f4,$00,$00,$00,$33,$73,$33,$73,$4c
	dc.b	$8c,$4c,$8c,$b3,$52,$4c,$b3,$90,$0c,$54,$88
	dc.b	$8b,$11,$f3,$6a,$2c,$f7,$0c,$f7,$13,$08,$00
	dc.b	$00,$0c,$f7,$00,$00,$00,$00,$00,$00,$00,$00
SPR2	dc.b	$eb,$d4,$f4,$00,$00,$00,$e7,$30,$e7,$30,$10
	dc.b	$c8,$18,$48,$24,$04,$1e,$48,$81,$14,$98,$50
	dc.b	$04,$8c,$ff,$ee,$60,$30,$10,$00,$8f,$c0,$10
	dc.b	$00,$00,$00,$00,$00,$10,$00,$00,$00,$00,$00

;--------------------------------------;

Seconds	= 5					;Number of seconds for pause
FntData	incbin	"DH2:SineScroller/Font.raw"	;Name of Raw Font
SclArea	dcb.b	17*(336/8),0
Screen1	dcb.b	200*(320/8),0
Screen2	dcb.b	200*(320/8),0

ScrMess	dc.b	"THE SINE SCROLLER, WRITTEN BY ROBSTER IN 1993...   "
	dc.b	"THIS, UNFORTUNATLY, IS JUST YOUR AVERAGE SINE SCROLLER...   "
	dc.b	"IT DOESN'T DO ANYTHING SPECIAL BUT IT DOES ALLOW YOU "
	dc.b	"TO PAUSE THE SCROLLING OF THE TEXT.  "
	dc.b	"--- GEMANIX 1993 ---a"
	dc.b	" I THINK THIS IS PRETTY COOL...  L8R  ----------------------"
	dc.b	"    ",0
	even
MT_Data	incbin	"DH0:Modules/mod.Beast3"
