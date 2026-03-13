;	Code and design by Bannasoft & paleface
;	Disassembled by Frantic
;	This is not the original source,
;	this has only been disassembled so you may learn...
;--------------------------------------;

WaitBlt	MACRO
.1\@	btst	#14,2(a6)
	bne.s	.1\@
	ENDM

;--------------------------------------;

	SECTION	"Melon Danish Wheels",CODE

Start
S	= Start+$8000

	movem.l	d0-a6,-(a7)
	lea	S(pc),a5

	lea	MelEnd-S(a5),a0
	move.w	#((End-MelEnd)/4)-1,d0
.1	clr.l	(a0)+
	dbf	d0,.1

	lea	SPR+2-S(a5),a0
	lea	MelSprt-S(a5),a1
	move.l	a1,d0
	move.w	d0,4(a0)
	swap	d0
	move.w	d0,(a0)
	addq.w	#8,a0
	lea	MelSprt+44-S(a5),a1
	move.l	a1,d0
	move.w	d0,4(a0)
	swap	d0
	move.w	d0,(a0)
	addq.w	#8,a0

	lea	NulSprt-S(a5),a1
	move.l	a1,d0
	moveq	#6-1,d1
.2	move.w	d0,4(a0)
	swap	d0
	move.w	d0,(a0)
	swap	d0
	addq.w	#8,a0
	dbf	d1,.2

	lea	TextScn-S(a5),a1
	move.l	a1,d0
	move.w	d0,BPL2+6-S(a5)
	swap	d0
	move.w	d0,BPL2+2-S(a5)
	lea	TextScn+(280*(336/8))-S(a5),a1
	move.l	a1,d0
	move.w	d0,BPL2+14-S(a5)
	swap	d0
	move.w	d0,BPL2+10-S(a5)

	move.l	4.w,a6
	move.b	297(a6),d0
	and.b	#$f,d0
	beq.s	.3
	jsr	-150(a6)
	move.l	d0,d1
	movec	vbr,d0
	move.l	d0,VBRStor-S(a5)
	move.l	d1,d0
	beq.s	.3
	jsr	-156(a6)
.3	move.l	$9c(a6),a0
	move.l	38(a0),OldCopr-S(a5)

	lea	$dff000,a6
	move.w	$1c(a6),IntEna-S(a5)
	or.b	#$c0,IntEna-S(a5)
	move.w	2(a6),DMACon-S(a5)
	or.b	#$80,DMACon-S(a5)
	move.w	#$7fff,d0
	move.w	d0,$96(a6)
	move.w	d0,$9a(a6)
	move.w	d0,$9c(a6)

	lea	CList-S(a5),a0
	move.l	a0,$80(a6)
	move.w	#0,$88(a6)
	move.w	#$82c0,$96(a6)

	move.l	VBRStor-S(a5),a0
	move.l	$6c(a0),OldIRQ-S(a5)
	move.l	$78(a0),-$48c0(a5)
	lea	NewIRQ-S(a5),a1
	move.l	a1,$6c(a0)

MakeSin	lea	SineCut-S(a5),a0
	lea	SinSmlI-S(a5),a1
	lea	SinSmlO-S(a5),a2
	lea	SinBigI-S(a5),a3
	lea	SinBigO-S(a5),a4
	moveq	#1,d4
	moveq	#2,d5
	moveq	#0,d6
	move.w	#256-1,d7
.1	move.w	(a0,d6),d0
	muls	d4,d0
	move.w	d0,d1
	muls	#400,d1
	swap	d1
	move.w	d1,512(a4)
	move.w	d1,(a4)+
	asr.w	#1,d1
	move.w	d1,512(a2)
	move.w	d1,(a2)+
	muls	#332,d0
	swap	d0
	move.w	d0,512(a3)
	move.w	d0,(a3)+
	asr.w	#1,d0
	move.w	d0,512(a1)
	move.w	d0,(a1)+
	add.w	d5,d6
	bpl.s	.2
	neg.w	d4
	bra.s	.3
.2	cmp.w	#64*2,d6
	blt.s	.4
.3	neg.w	d5
	add.w	d5,d6
.4	dbf	d7,.1

MkeCogs	moveq	#16-1,d6
.1	lea	SinSmlI-S(a5),a0
	lea	SinSmlO-S(a5),a1
	add.w	SinPnts-S(a5),a0
	add.w	SinPnts-S(a5),a1
	moveq	#100,d4
	moveq	#70,d5
	bsr.w	DSmlCog
	addq.w	#4,SinPnts-S(a5)
	and.w	#$3f,SinPnts-S(a5)

	lea	SinSmlI-S(a5),a0
	lea	SinSmlO-S(a5),a1
	add.w	SinPnts+2-S(a5),a0
	add.w	SinPnts+2-S(a5),a1
	moveq	#10,d4
	moveq	#50,d5
	bsr.w	DSmlCog
	subq.w	#4,SinPnts+2-S(a5)
	and.w	#$3f,SinPnts+2-S(a5)

	lea	SinSmlI-S(a5),a0
	lea	SinSmlO-S(a5),a1
	add.w	SinPnts+8-S(a5),a0
	add.w	SinPnts+8-S(a5),a1
	move.w	#314,d4
	move.w	#256,d5
	bsr.w	DSmlCog
	addq.w	#4,SinPnts+8-S(a5)
	and.w	#$3f,SinPnts+8-S(a5)

	lea	SinSmlI-S(a5),a0
	lea	SinSmlO-S(a5),a1
	add.w	SinPnts+8-S(a5),a0
	add.w	SinPnts+8-S(a5),a1
	move.w	#304,d4
	moveq	#55,d5
	bsr.w	DSmlCog

	lea	SinSmlI-S(a5),a0
	lea	SinSmlO-S(a5),a1
	add.w	SinPnts+2-S(a5),a0
	add.w	SinPnts+2-S(a5),a1
	move.w	#231,d4
	moveq	#-3,d5
	bsr.w	DSmlCog

	lea	SinBigI-S(a5),a0
	lea	SinBigO-S(a5),a1
	move.w	SinPnts+4-S(a5),d0
	add.w	d0,a0
	add.w	d0,a1
	move.w	#210,d4
	move.w	#161,d5
	subq.w	#2,SinPnts+4-S(a5)
	and.w	#$1f,SinPnts+4-S(a5)
	bsr.w	DBigCog

	lea	SinBigI-S(a5),a0
	lea	SinBigO-S(a5),a1
	move.w	SinPnts+6-S(a5),d0
	add.w	d0,a0
	add.w	d0,a1
	moveq	#40,d4
	move.w	#239,d5
	addq.w	#2,SinPnts+6-S(a5)
	and.w	#$1f,SinPnts+6-S(a5)
	bsr.w	DBigCog

	move.l	AnmSPnt-S(a5),d0
	lea	AnimScn-S(a5),a0
	add.l	a0,d0
	add.l	#(290*(352/8))-2,d0
	WaitBlt
	move.l	d0,$50(a6)
	move.l	d0,$54(a6)
	moveq	#0,d0
	move.l	d0,$64(a6)
	moveq	#-1,d0
	move.l	d0,$44(a6)
	move.l	#$09f0000a,$40(a6)
	move.w	#$4896,$58(a6)
	add.l	#290*(352/8),AnmSPnt-S(a5)
	WaitBlt
	dbf	d6,.1

	movem.l	d0-a6,-(a7)
	bsr.w	pr_init
	movem.l	(a7)+,d0-a6

	move.w	#$e020,$9a(a6)

;-------------------;

MainLp	cmp.b	#$80,6(a6)
	beq.s	MainLp
.WaitBm	cmp.b	#$80,6(a6)
	bne.s	.WaitBm

	cmp.w	#100,Status-S(a5)
	bne.s	.1
	subq.w	#1,TxtWait-S(a5)
	bpl.w	MseChck
.1	addq.w	#1,Status-S(a5)
	move.w	Status-S(a5),d0
	cmp.w	#200-1,d0
	beq.w	Exit
	cmp.w	#32,d0
	bgt.s	.2
	neg.w	d0
	add.w	#32,d0
	bsr.w	SprtIn
	bra.s	MainLp

.2	cmp.w	#64+1,d0
	bgt.s	.3
	sub.w	#32+1,d0
	bsr.w	FadeIn
	bra.s	MainLp

.3	cmp.w	#66,d0
	bgt.s	.4
	bsr.w	PrtText
	bra.s	MseChck

.4	cmp.w	#99,d0
	bgt.s	.5
	cmp.w	#83,d0
	blt.s	MseChck
	sub.w	#83,d0
	add.w	d0,d0
	bsr.w	FadeTxt
	bra.s	MseChck

.5	cmp.w	#132,d0
	bgt.s	.6
	cmp.w	#116,d0
	bgt.s	MseChck
	sub.w	#116,d0
	neg.w	d0
	add.w	d0,d0
	bsr.w	FadeTxt
	bra.s	MseChck

.6	tst.w	ExitFlg-S(a5)
	bne.s	.7
	move.w	#65,Status-S(a5)
	bra.s	MseChck

.7	move.w	#-1,pr_musicfadedirection-S(a5)
	cmp.w	#165,d0
	bgt.s	.8
	subi.w	#165,d0
	neg.w	d0
	bsr.s	FadeIn
	bra.w	MainLp

.8	sub.w	#166,d0
	bsr.s	SprtIn
	bra.w	MainLp

;-------------------;

MseChck	btst	#6,$bfe001
	bne.w	MainLp
	clr.w	TxtWait-S(a5)
	st	ExitFlg-S(a5)
	bra.w	MainLp

;-------------------;

FadeIn	lea	Colours-S(a5),a0
	moveq	#$000,d2
	move.w	(a0)+,d1
	bsr.w	Fade
	move.w	d3,d7
	move.w	(a0)+,d1
	bsr.w	Fade
	cmp.w	d3,d7
	bne.s	.1
	tst.w	d3
	beq.s	.1
	add.w	#$110,d7
.1	lea	BPLCols+2-S(a5),a1
	moveq	#4-1,d6
.2	move.w	d7,(a1)
	move.w	d3,4(a1)
	addq.w	#8,a1
	dbf	d6,.2
	rts

;--------------------------------------;

SprtIn	moveq	#0,d1
	move.w	#$000,d2
	bsr.w	Fade
	move.w	d3,SPRCols+2-S(a5)
	move.w	d3,SPRCols+10-S(a5)
	move.w	#$fff,d2
	bsr.w	Fade
	move.w	d3,SPRCols+6-S(a5)
	mulu	#5,d0
	add.w	#64,d0
	move.b	d0,MelSprt+1-S(a5)
	addq.b	#8,d0
	move.b	d0,MelSprt+45-S(a5)
	rts

;--------------------------------------;

FadeTxt	lea	Colours+4-S(a5),a0
	lea	BPLCols+10-S(a5),a1
	moveq	#3-1,d7
.1	move.w	#$ded,d2
	move.w	(a0)+,d1
	bsr.w	Fade
	move.w	d3,(a1)
	move.w	#$bcc,d2
	move.w	(a0)+,d1
	bsr.w	Fade
	move.w	d3,4(a1)
	addq.w	#8,a1
	dbf	d7,.1
	rts

;--------------------------------------;

Exit	movem.l	d0-a6,-(a7)
	bsr.w	pr_end
	movem.l	(a7)+,d0-a6
	move.w	#$7fff,d0
	move.w	d0,$96(a6)
	move.w	d0,$9a(a6)
	move.w	d0,$9c(a6)
	move.w	DMACon-S(a5),$96(a6)
	move.w	IntEna-S(a5),$9a(a6)
	move.l	VBRStor-S(a5),a0
	move.l	OldIRQ-S(a5),$6c(a0)
	move.l	OldCopr-S(a5),$80(a6)
	movem.l	(a7)+,d0-a6
	rts

;--------------------------------------;

NewIRQ	movem.l	d0-a6,-(a7)
.1	cmp.b	#$40,$00dff006
	bne.b	.1
	lea	S(pc),a5

	lea	AnimScn-S(a5),a0
	move.w	AnimPnt-S(a5),d1
	mulu	#290*(352/8),d1
	add.l	a0,d1
	move.w	d1,BPL1+6-S(a5)
	swap	d1
	move.w	d1,BPL1+2-S(a5)
	addq.b	#1,AnimPnt+1-S(a5)
	and.b	#$f,AnimPnt+1-S(a5)

	bsr.w	pr_music
	movem.l	(a7)+,d0-a6
	move.w	#$4020,$9c(a6)
	rte	

;--------------------------------------;
;d0=Step, d1=Desired, d2=Original, d3=Output

Fade	move.w	d1,d3
	move.w	d1,d4
	move.w	d1,d5
	and.w	#$f00,d3
	and.w	#$0f0,d4
	and.w	#$00f,d5
	move.w	d2,d6
	and.w	#$f00,d6
	sub.w	d6,d3
	move.w	d2,d6
	and.w	#$0f0,d6
	sub.w	d6,d4
	move.w	d2,d6
	and.w	#$00f,d6
	sub.w	d6,d5
	muls	d0,d3
	muls	d0,d4
	muls	d0,d5
	asr.l	#5,d3
	asr.w	#5,d4
	asr.w	#5,d5
	and.w	#$ff00,d3
	and.w	#$fff0,d4
	move.w	d2,d6
	and.w	#$f00,d6
	add.w	d6,d3
	move.w	d2,d6
	and.w	#$0f0,d6
	add.w	d6,d4
	move.w	d2,d6
	and.w	#$00f,d6
	add.w	d6,d5
	or.w	d4,d3
	or.w	d5,d3
	rts

;--------------------------------------;

ShdwTxt	moveq	#0,d0
	lea	TextScn-S(a5),a0
	lea	TextScn+(280*(336/8))-S(a5),a1
	WaitBlt
	move.l	d0,$60(a6)
	move.l	d0,$64(a6)
	move.l	#$ffffffff,$44(a6)
	move.l	a0,$50(a6)
	move.l	a1,$54(a6)
	move.l	#$19f00000,$40(a6)
	move.w	#280<<6+(336/16),$58(a6)
	WaitBlt
	move.l	a0,$50(a6)
	move.l	a1,$48(a6)
	move.l	a1,$54(a6)
	move.l	#$3bfa0000,$40(a6)
	move.w	#280<<6+(336/16),$58(a6)
	WaitBlt
	lea	(352/8)(a0),a2
	move.l	a2,$50(a6)
	move.l	a1,$48(a6)
	move.l	a1,$54(a6)
	move.l	#$2bfa0000,$40(a6)
	move.w	#279<<6+(336/16),$58(a6)
	WaitBlt
	lea	(352/8)(a1),a3
	move.l	a0,$50(a6)
	move.l	a3,$48(a6)
	move.l	a3,$54(a6)
	move.l	#$2bfa0000,$40(a6)
	move.w	#279<<6+(336/16),$58(a6)
	WaitBlt
	move.l	a0,$50(a6)
	move.l	a0,$54(a6)
	move.l	#$29f00000,$40(a6)
	move.w	#280<<6+(336/16),$58(a6)
	WaitBlt
	lea	(352/8)(a2),a2
	lea	(352/8)(a3),a3
	move.l	#$2fba0000,$40(a6)
	move.l	a1,$50(a6)
	move.l	a3,$4c(a6)
	move.l	a2,$48(a6)
	move.l	a2,$54(a6)
	move.w	#278<<6+(336/16),$58(a6)
	WaitBlt
	rts

;-------------------;

PrtText	lea	TextScn-S(a5),a0
	move.w	#$0000,$66(a6)
	move.l	a0,$54(a6)
	move.l	#$01000000,$40(a6)
	move.w	#280<<6+(336/16),$58(a6)
	WaitBlt

	move.w	TxtPntr-S(a5),d0
	lea	MelText(pc,d0),a4
	lea	MelFont-S(a5),a1
.1	moveq	#0,d1
.2	moveq	#0,d0
	move.b	(a4)+,d0
	beq.s	.4
	sub.b	#32,d0
	bpl.s	.3
	sub.l	d1,a0
	lea	10*(352/8)(a0),a0
	bra.s	.1

.3	lsl.w	#3,d0
	move.l	a1,a2
	add.w	d0,a2
	move.b	(a2)+,(a0)+
	move.b	(a2)+,(1*(352/8))-1(a0)
	move.b	(a2)+,(2*(352/8))-1(a0)
	move.b	(a2)+,(3*(352/8))-1(a0)
	move.b	(a2)+,(4*(352/8))-1(a0)
	move.b	(a2)+,(5*(352/8))-1(a0)
	move.b	(a2)+,(6*(352/8))-1(a0)
	move.b	(a2)+,(7*(352/8))-1(a0)
	addq.w	#1,d1
	bra.s	.2

.4	move.b	(a4)+,d0
	and.w	#$ff,d0
	lsl.w	#6,d0
	move.w	d0,TxtWait-S(a5)
	move.l	a4,a0
	lea	MelText-S(a5),a1
	sub.l	a1,a0
	move.w	a0,TxtPntr-S(a5)
	tst.b	(a4)
	bne.s	.5
	clr.w	TxtPntr-S(a5)
.5	bsr.w	ShdwTxt
	rts

;--------------------------------------;

MelText	incbin	"DH2:MelonCR/Melon.txt"
	even

;--------------------------------------;

DSmlCog	moveq	#8-1,d7
.1	move.w	(a0),d0
	move.w	128(a0),d1
	move.w	8(a1),d2
	move.w	136(a1),d3
	bsr.w	CalcLne
	move.w	24(a1),d2
	move.w	152(a1),d3
	bsr.w	CalcLne
	move.w	32(a0),d2
	move.w	160(a0),d3
	bsr.w	CalcLne
	move.w	64(a0),d2
	move.w	192(a0),d3
	bsr.w	CalcLne
	lea	64(a0),a0
	lea	64(a1),a1
	dbf	d7,.1
	rts

;--------------------------------------;

SinPnts	dc.w	34,00,20,20,24

;--------------------------------------;

DBigCog	moveq	#16-1,d7
.1	move.w	(a0),d0
	move.w	128(a0),d1
	move.w	4(a1),d2
	move.w	132(a1),d3
	bsr.w	CalcLne
	move.w	12(a1),d2
	move.w	140(a1),d3
	bsr.w	CalcLne
	move.w	16(a0),d2
	move.w	144(a0),d3
	bsr.w	CalcLne
	move.w	32(a0),d2
	move.w	160(a0),d3
	bsr.w	CalcLne
	lea	32(a0),a0
	lea	32(a1),a1
	dbf	d7,.1
	rts

;--------------------------------------;

SineCut	dc.w	$00c9,$025b,$03ed,$057e,$070e,$089d,$0a2b,$0bb7
	dc.w	$0d41,$0eca,$1050,$11d3,$1354,$14d2,$164c,$17c4
	dc.w	$1937,$1aa7,$1c12,$1d79,$1edc,$203a,$2193,$22e7
	dc.w	$2435,$257e,$26c1,$27fe,$2935,$2a65,$2b8f,$2cb2
	dc.w	$2dcf,$2ee4,$2ff2,$30f9,$31f8,$32ef,$33df,$34c6
	dc.w	$35a5,$367d,$374b,$3812,$38cf,$3984,$3a30,$3ad3
	dc.w	$3b6d,$3bfd,$3c85,$3d03,$3d78,$3de3,$3e45,$3e9d
	dc.w	$3eeb,$3f30,$3f6b,$3f9c,$3fc4,$3fe1,$3ff5,$3fff

;--------------------------------------;

CalcLne	movem.w	d2-d3,-(a7)
	add.w	d4,d0
	add.w	d4,d2
	add.w	d5,d1
	add.w	d5,d3

ClipLne	movem.l	d0-d7/a2,-(a7)
	cmp.w	d0,d2
	ble.s	.1
	exg	d0,d2
	exg	d1,d3

.1	tst.w	d2
	bpl.s	.2
	move.w	d0,d4
	bmi.w	.NoDraw
	sub.w	d2,d4
	move.w	d3,d6
	sub.w	d1,d6
	muls	d2,d6
	divs	d4,d6
	add.w	d6,d3
	moveq	#0,d2

.2	cmp.w	#343,d2
	bpl.w	.NoDraw
	cmp.w	#343,d0
	blt.s	.7
	move.w	d0,d4
	sub.w	d2,d4
	move.w	d1,d6
	sub.w	d3,d6
	sub.w	#342,d0
	muls	d0,d6
	divs	d4,d6
	sub.w	d6,d1
	move.w	#342,d0
	not.w	EscFlag-S(a5)
	beq.s	.3
	move.w	d1,EscPstn-S(a5)
	bra.s	.7

.3	movem.l	d0-d7,-(a7)
	move.w	EscPstn-S(a5),d3
	move.w	d0,d2
	cmp.w	d1,d3
	ble.s	.4
	exg	d1,d3
.4	tst.w	d3
	bge.s	.5
	moveq	#0,d3
.5	cmp.w	#289,d1
	blt.s	.6
	move.w	#289,d1
.6	bsr.s	DrawLne
	movem.l	(a7)+,d0-d7

.7	cmp.w	d1,d3
	ble.s	.8
	exg	d0,d2
	exg	d1,d3

.8	tst.w	d3
	bpl.s	.9
	move.w	d1,d4
	bmi.s	.NoDraw
	sub.w	d3,d4
	move.w	d2,d6
	sub.w	d0,d6
	muls	d1,d6
	divs	d4,d6
	add.w	d0,d6
	move.w	d6,d2
	moveq	#0,d3

.9	cmp.w	#290,d3
	bpl.s	.NoDraw
	cmp.w	#290,d1
	blt.s	.10
	move.w	d1,d4
	sub.w	d3,d4
	move.w	d2,d6
	sub.w	d0,d6
	sub.w	#289,d1
	muls	d1,d6
	divs	d4,d6
	add.w	d6,d0
	move.w	#289,d1

.10	bsr.s	DrawLne
.NoDraw	movem.l	(a7)+,d0-d7/a2

	movem.w	(a7)+,d0-d1
	rts

;--------------------------------------;

DrawLne	lea	AnimScn-S(a5),a2
	add.l	AnmSPnt-S(a5),a2
	moveq	#$f,d4
	and.w	d2,d4
	sub.w	d3,d1
	ext.l	d3
	mulu	#(352/8),d3

	sub.w	d2,d0
	blt.s	.2
	cmp.w	d0,d1
	bge.s	.1
	moveq	#$13,d7
	bra.s	.4
.1	moveq	#$03,d7
	exg	d1,d0
	bra.s	.4
.2	neg.w	d0
	cmp.w	d0,d1
	bge.s	.3
	moveq	#$17,d7
	bra.s	.4
.3	moveq	#$0b,d7
	exg	d1,d0

.4	add.w	d1,d1
	asr.w	#3,d2
	ext.l	d2
	add.l	d2,d3
	move.w	d1,d2
	swap	d4
	asr.l	#4,d4
	or.w	#$b4a,d4
	swap	d7
	move.w	d4,d7
	swap	d7
	add.l	d3,a2
	move.w	d0,d6
	addq.w	#1,d6
	asl.w	#6,d6
	addq.w	#2,d6
	lsl.l	#4,d4
	swap	d4
	not.b	d4
	sub.w	d0,d2
	bge.s	.5
	or.w	#$40,d7
.5	WaitBlt
	move.w	d1,$62(a6)
	move.w	d2,d1
	sub.w	d0,d1
	move.w	d1,$64(a6)
	moveq	#0,d1
	move.l	d7,$40(a6)
	move.l	#$ffffffff,$44(a6)
	move.w	#$002c,$60(a6)
	move.l	#$ffff8000,$72(a6)
	move.l	a2,$48(a6)
	move.l	a2,$54(a6)
	move.w	d2,$52(a6)
	bchg	d4,(a2)
	move.w	d6,$58(a6)
	rts

;--------------------------------------;

Colours	dc.w	$0ded,$0bcc,$0676,$0566
	dc.w	$0000,$0000,$0fff,$0fff

;--------------------------------------;

MelSprt	dc.w	$30f0,$3900
	dc.w	%1111111111111100,%1111111111111111
	dc.w	%1111111111111100,%1111111111111111
	dc.w	%1101011100110100,%1010101011011111
	dc.w	%1010101011010101,%1101011111111111
	dc.w	%1010101000010101,%1111111111111111
	dc.w	%1010101011110101,%1111111111111011
	dc.w	%1010101100011000,%1111111011110101
	dc.w	%1111111111111100,%1111111111111111
	dc.w	%1111111111111100,%1111111111111111
NulSprt	dc.w	0,0

	dc.w	$30f8,$3900
	dc.w	%0000000000000000,%1111111110000000
	dc.w	%0000000000000000,%1111111110000000
	dc.w	%1100111000000000,%1111111110000000
	dc.w	%0010100100000000,%1111111110000000
	dc.w	%0010100100000000,%1111111110000000
	dc.w	%0010100100000000,%1111111110000000
	dc.w	%1100100100000000,%1111111110000000
	dc.w	%0000000000000000,%1111111110110000
	dc.w	%0000000000000000,%1111111110110000
	dc.w	0,0

;--------------------------------------;

CList	dc.w	$008e,$2071,$0090,$3cd1
	dc.w	$0092,$0030,$0094,$00d8
	dc.w	$0096,$83e0,$0096,$0400
	dc.w	$0100,$0200,$0102,$0000
	dc.w	$0104,$0024,$0106,$0c00
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$01e4,$2100,$01fc,$0000

BPLCols	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000

SPR	dc.w	$0120,$0000,$0122,$0000
	dc.w	$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000

SPRCols	dc.w	$01a2,$0000,$01a4,$0000
	dc.w	$01a6,$0000

BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$0100,$1200
	dc.w	$2a01,$ff00
BPL2	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$0100,$3200

	dc.w	$ffdf,$fffe
	dc.w	$2f01,$ff00
	dc.w	$0100,$1200

	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

Music	include	"DH2:MelonCR/ProRunner.i"

;--------------------------------------;

MelFont	incbin	"DH2:MelonCR/Font.raw"

;--------------------------------------;

pr_data	incbin	"DH2:MelonCR/mod.1patternloop1v3"

;--------------------------------------;
;	Melon intro ends here, These buffers are so precious memory is
;	not taken. No more gurus.
MelEnd

pr_startposition:		dc.w	0
pr_speed:			dc.w	6
pr_highestpattern:		dc.w	0
pr_currentpattern:		dc.w	0
pr_framecounter:		dc.w	0
pr_patterndelaytime:		dc.w	0
pr_patternhasbeenbreaked:	dc.w	0
pr_Patternpositions:		ds.l	128
pr_Patternpt:			dc.l	0
pr_Currentposition:		dc.l	0
pr_Patternct:			dc.w	0
pr_oldledvalue:			dc.w	0
pr_dontcalcnewposition:		dc.w	0
pr_commandnotedelay:		dc.w	0
pr_old78:			dc.l	0
pr_Channel0:			dc.w	1
				ds.w	30
pr_Channel1:			dc.w	1
				ds.w	30
pr_Channel2:			dc.w	1
				ds.w	30
pr_Channel3:			dc.w	1
				ds.w	30
pr_dmacon:			dc.w	$8000

pr_Arpeggiofastlist:		ds.b	1000
pr_Arpeggiofastdivisionlist:	ds.b	$100
pr_fastperiodlist:		ds.l	16
pr_Sampleinfos:			ds.b	32*32

AnmSPnt	dc.l	0
TxtPntr	dc.w	0
ExitFlg	dc.w	0
TxtWait	dc.w	0
Status	dc.w	0
SinSmlI	dcb.b	1024,0
SinSmlO	dcb.b	1024,0
SinBigI	dcb.b	1024,0
SinBigO	dcb.b	1024,0
OldCopr	dc.l	0
IntEna	dc.w	0
DMACon	dc.w	0
OldIRQ	dc.l	0
VBRStor	dc.l	0
AnimPnt	dc.w	0
EscFlag	dc.w	0
EscPstn	dc.w	0
TextScn	dcb.b	2*280*(336/8),0
AnimScn	dcb.b	16*290*(352/8),0

End	END
