;	Code and design by Slammer & Xience
;	Disassembled by Frantic
;	This is not the original source,
;	this has only been disassembled so you may learn...

Address	= $1a0000			;Original = $58000

	JMP	Address
	ORG	Address
	LOAD	Address

;--------------------------------------;

WaitBlt	MACRO
.1\@	btst	#\1,$dff002
	btst	#\1,$dff002
	bne.s	.1\@
	ENDM

;--------------------------------------;

Start	movem.l	d0-a6,-(a7)
	move.w	$dff01c,IntEna
	move.w	$dff002,DMACon
	lea	$dff000,a6
	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9c(a6)
	move.w	#$0000,$180(a6)
	move.w	#$0200,$100(a6)
	move.l	#NoCList,$84(a6)
	move.w	d0,$8a(a6)
	bsr.l	GetVBR
	lea	$bfd100,a6
	or.b	#$f8,(a6)
	and.b	#$87,(a6)
	or.b	#$78,(a6)

	lea	ZroArea,a0
	move.l	#(End-ZroArea)/4,d0
.1	clr.l	(a0)+
	subq.l	#1,d0
	bne.s	.1

	lea	WavExtr,a0
	move.w	#(576*(352/8)/4)-1,d0
	moveq	#-1,d7
.2	move.l	d7,(a0)+
	dbf	d0,.2

	move.w	#24*12,d0
	bsr.l	MveTxtS

	move.w	#$0020,$dff1dc
	move.w	$dff07c,d0
	cmp.b	#$f8,d0
	bne.b	.NonAGA
	move.w	#$0000,$dff106
	move.w	#$0011,$dff10c		;Original = $0000
	move.w	#$0000,$dff1fc
.NonAGA	move.w	#$8640,$dff096

	lea	$dff000,a6
	WaitBlt	14
	move.l	#Screen1+((160+256)*(352/8)),$54(a6)
	move.w	#$0000,$66(a6)
	move.w	#$ffff,$74(a6)
	move.l	#$ffffffff,$44(a6)
	move.l	#$01f00000,$40(a6)
	move.w	#160<<6+(352/16),$58(a6)

	WaitBlt	14
	move.l	#Screen2+((160+256)*(352/8)),$54(a6)
	move.w	#$0000,$66(a6)
	move.w	#$ffff,$74(a6)
	move.l	#$ffffffff,$44(a6)
	move.l	#$01f00000,$40(a6)
	move.w	#160<<6+(352/16),$58(a6)

	move.w	#0,Counter
	bsr.l	SpltScn
	move.w	#0,Counter
	bsr.l	SpltScn

	move.l	VBRStor(pc),a5
	move.l	$6c(a5),OldIRQ
	move.l	#NewIRQ,$6c(a5)
	clr.l	0.w

	WaitBlt	14
	move.w	#$7fff,$dff09c
	move.w	#$87e0,$dff096
	move.w	#$c020,$dff09a

;--------------------------------------;

MainLp	bsr.s	WaitBm
	tst.w	ExitFlg
	bne.s	Exit
	bsr.l	ChkText
	bra.s	MainLp

.1	bsr.s	WaitBm			;Unused
	dbf	d0,.1			;Unused
	rts				;Unused

WaitBm	clr.w	VBlank
.1	tst.w	VBlank
	beq.s	.1
	rts

;--------------------------------------;

GetVBR	move.l	4.w,a6
	jsr	-150(a6)
	move.l	d0,SysStck
	move.l	$10.w,IlgStor
	move.l	#.1,$10.w
	movec	VBR,a0
	bra.s	.2

.1	sub.l	a0,a0
	addq.l	#2,2(a7)
	rte

.2	move.l	IlgStor(pc),$10.w
	move.l	a0,VBRStor
	move.l	4.w,a6
	move.l	SysStck,d0
	jmp	-156(a6)

;--------------------------------------;

Exit	lea	$dff000,a6
	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9c(a6)
	move.w	#$0000,$180(a6)
	move.w	#$0200,$100(a6)

	move.l	#NoCList,$84(a6)
	move.w	d0,$8a(a6)

	movea.l	VBRStor(pc),a5
	move.l	OldIRQ(pc),$6c(a5)

	move.w	DMACon(pc),d0
	or.w	#$8000,d0
	move.w	d0,$dff096

	move.w	IntEna(pc),d0
	or.w	#$8000,d0
	move.w	d0,$dff09a

	movem.l	(a7)+,d0-a6
	moveq	#0,d0
	rts

;--------------------------------------;

NewIRQ	addq.w	#1,VBlank
	movem.l	d0-a6,-(a7)
	move.l	#CList,$dff084
	move.w	d0,$dff08a
	bsr.s	ChkRout

	WaitBlt	14
	move.b	$dff005,d0
	lsl.w	#8,d0
	move.b	$dff006,d0
	cmp.w	RastMax,d0
	bls.s	.1
	move.w	d0,RastMax

.1	movem.l	(a7)+,d0-a6
	move.w	#$0020,$dff09c
	rte

;--------------------------------------;

ChkRout	move.w	RtnStep(pc),d0
	beq.l	FadeIn			;0
	subq.w	#1,d0
	beq.l	SprtIn			;1
	subq.w	#1,d0
	beq.l	WaveIn			;2
	subq.w	#1,d0
	beq.l	WaitMse			;3
	subq.w	#1,d0
	beq.l	WaveOut			;4
	subq.w	#1,d0
	beq.l	SprtOut			;5
	subq.w	#1,d0
	beq.s	FadeOut			;6
	rts

;--------------------------------------;
;	Sprite Data	= a0
;	SpriteX		= d0
;	SpriteY		= d1
;	SpriteHeight	= d5

WrteSpr	add.w	#$70,d0			;X aligning sprite to screen
	add.w	#$1c,d1			;Y aligning sprite to screen
	moveq	#0,d3
	moveq	#0,d4
	move.w	d0,d2			;X
	roxr.w	#1,d4
	roxr.w	#1,d2
	bcc.s	.1
	roxr.w	#1,d4
	bset	#0,d3			;H0
.1	move.w	d1,-(a7)
	ror.w	#8,d1
	roxr.b	#1,d1
	bcc.s	.2
	bset	#2,d3			;E8
	roxr.w	#1,d4
.2	or.w	d1,d2
	move.w	(a7)+,d1
	add.w	d5,d1
	ror.w	#8,d1
	roxr.b	#1,d1
	bcc.s	.3
	roxr.w	#1,d4
	bset	#1,d3			;L8
.3	or.w	d1,d3
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	rts

;--------------------------------------;

FadeOut	move.w	Counter(pc),d2
	cmp.w	#16,d2
	bhi.s	.1
	moveq	#$000,d4
	move.w	#$364,d3
	bsr.l	Fade
	move.w	d5,WavCols+2

	moveq	#$000,d4
	move.w	#$a47,d3
	bsr.l	Fade
	move.w	d5,WavCols+6

.1	addq.w	#1,Counter
	cmp.w	#17,Counter
	bne.s	.2
	move.w	#-1,ExitFlg

.2	bsr.l	SpltScn
	tst.w	Unused2			;Unused
	beq.s	.3			;Unused
	subq.w	#1,Unused2		;Unused
	subq.w	#1,Unused3		;Unused
.3	move.w	SpriteX(pc),d0
	move.w	#10,d1
	moveq	#9,d5
	lea	MelSpr1(pc),a0
	bsr.l	WrteSpr
	move.l	MelSpr1,MelSpr2
	addq.w	#8,MelSpr2
	cmp.w	#$0168,SpriteX
	bge.s	.4
	addq.w	#2,SpriteX
.4	rts

;--------------------------------------;

WaitMse	bsr.l	SpltScn
	btst	#6,$bfe001
	bne.s	.1
	addq.w	#1,RtnStep
.1	rts

;--------------------------------------;

SprtIn	addq.w	#1,Counter
	cmp.w	#25,Counter
	bne.s	.1
	clr.w	Counter
	addq.w	#1,RtnStep
	clr.w	Counter			;Obsolete

.1	move.w	SpriteX(pc),d0
	move.w	#10,d1
	moveq	#9,d5
	lea	MelSpr1(pc),a0
	bsr.l	WrteSpr
	move.l	MelSpr1,MelSpr2
	addq.w	#8,MelSpr2
	cmp.w	#$013b,SpriteX
	ble.s	.2
	subq.w	#2,SpriteX
.2	rts

;--------------------------------------;

WaveIn	bsr.l	SpltScn
	addq.w	#2,Counter
	cmp.w	#256,Counter
	bne.s	.1
	addq.w	#1,RtnStep
.1	rts

;--------------------------------------;

SprtOut	move.w	#4,TxtStep
	addq.w	#1,Counter
	cmp.w	#16,Counter
	bne.s	.1
	clr.w	Counter
	addq.w	#1,RtnStep

.1	tst.w	Unused2
	beq.s	.2
	subq.w	#1,Unused2
	subq.w	#1,Unused3
.2	move.w	SpriteX(pc),d0
	move.w	#10,d1
	moveq	#9,d5
	lea	MelSpr1(pc),a0
	bsr.l	WrteSpr
	move.l	MelSpr1,MelSpr2
	addq.w	#8,MelSpr2
	cmp.w	#$0168,SpriteX
	bge.s	.3
	add.w	#3,SpriteX
.3	rts

;--------------------------------------;

WaveOut	move.w	#1,TxtWait
	subq.w	#2,Counter
	bne.s	.1
	addq.w	#1,RtnStep
.1	bsr.l	SpltScn
	cmp.w	#64,Counter
	bhi.b	.2
	tst.w	Unused2
	beq.s	.2
	subq.w	#1,Unused2
	subq.w	#1,Unused3
	clr.w	ShitReg
.2	rts

;--------------------------------------;

FadeIn	move.w	Counter(pc),d2			;Fade In routine
	cmp.w	#16,d2
	bhi.s	.1
	moveq	#$000,d3
	move.w	#$364,d4
	bsr.s	Fade
	move.w	d5,WavCols+2

	moveq	#$000,d3
	move.w	#$a47,d4
	bsr.s	Fade
	move.w	d5,WavCols+6

.1	addq.w	#1,Counter
	cmp.w	#17,Counter
	bne.s	.2
	addq.w	#1,RtnStep
	clr.w	Counter
.2	rts

;--------------------------------------;

Fade	move.w	d4,d7
	lsr.w	#8,d7
	move.w	d3,d6
	lsr.w	#8,d6
	sub.w	d6,d7
	muls	d2,d7
	asr.w	#4,d7
	add.w	d6,d7
	and.w	#$00f,d7
	lsl.w	#8,d7
	move.w	d7,d5
	move.w	d4,d7
	lsr.w	#4,d7
	and.w	#$00f,d7
	move.w	d3,d6
	lsr.w	#4,d6
	and.w	#$00f,d6
	sub.w	d6,d7
	muls	d2,d7
	asr.w	#$4,d7
	add.w	d6,d7
	and.w	#$000f,d7
	lsl.w	#4,d7
	move.b	d7,d5
	move.w	d4,d7
	and.w	#$00f,d7
	move.w	d3,d6
	and.w	#$00f,d6
	sub.w	d6,d7
	muls	d2,d7
	asr.w	#$4,d7
	add.w	d6,d7
	and.w	#$00f,d7
	or.b	d7,d5
	rts

;--------------------------------------;

ChkText	cmp.w	#3,RtnStep
	beq.s	.1
	cmp.w	#4,RtnStep
	beq.s	.1
	rts

;-------------------;

.1	move.w	TxtStep(pc),d0
	beq.l	TxtPrnt			;0
	subq.w	#1,d0
	beq.l	TxtEntr			;1
	subq.w	#1,d0
	beq.l	TxtView			;2
	subq.w	#1,d0
	beq.s	TxtExit			;3
	rts

;-------------------;

TxtExit	move.w	TxtSOff(pc),d0
	bsr.l	MveTxtS
	cmp.w	#-(24*12),TxtSOff
	beq.s	.3
	move.w	CopSOff(pc),d0
	add.w	d0,TxtSOff
	subq.w	#1,CopSOff
	tst.w	d0
	blt.s	.1
	move.w	#$243,TxtCols+2
	move.w	#$000,TxtCols+6
	move.w	#$fff,TxtCols+10
	bra.s	.2

.1	move.w	#$364,TxtCols+2
	move.w	#$364,TxtCols+6
	move.w	#$364,TxtCols+10
	cmp.w	#-(24*12),TxtSOff
	bgt.s	.2
	move.w	#-(24*12),TxtSOff
.2	rts

.3	cmp.w	#3,RtnStep
	bne.s	.4
	clr.w	TxtStep
	move.w	#$ffe1,CopSOff
	move.w	#(24*12),TxtSOff
	move.w	#$243,TxtCols+2
	move.w	#$000,TxtCols+6
	move.w	#$fff,TxtCols+10
	move.w	#$624,TxtCols+14
	move.w	#$000,TxtCols+18
	move.w	#$fff,TxtCols+22
	rts

.4	move.w	#$0004,TxtStep
	rts

;-------------------;

TxtView	subq.w	#1,TxtWait
	bne.s	.1
	addq.w	#1,TxtStep
.1	rts

;-------------------;

TxtPrnt	lea	TxtArea,a6
	move.w	#(24*12)/2,d7
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	sub.l	a0,a0
	sub.l	a1,a1
	sub.l	a2,a2
	sub.l	a3,a3
.1	movem.l	d0-d6/a0-a3,(a6)	;clear 2 lines
	movem.l	d0-d6/a0-a3,(0*(352/8))+(352/8)(a6)
	movem.l	d0-d6/a0-a3,(2*(352/8))(a6)
	movem.l	d0-d6/a0-a3,(2*(352/8))+(352/8)(a6)
	add.w	#2*(2*(352/8)),a6
	dbf	d7,.1

	lea	MelText(pc),a0
	add.w	TxtPntr(pc),a0
	lea	MelFont(pc),a5
	lea	TxtArea+2*(24*(352/8))+2,a6
.2	moveq	#0,d6
.3	moveq	#0,d5
	move.b	(a0)+,d5
	beq.s	.6
	cmp.b	#10,d5
	beq.s	.5
	cmp.b	#1,d5
	beq.s	.6
	sub.b	#32,d5
	lsl.w	#3,d5

	moveq	#8-1,d7
.4	move.b	(a5,d5),d0
	move.b	d0,(a6,d6)
	add.w	#2*(352/8),d6
	addq.w	#1,d5
	dbf	d7,.4
	sub.w	#8*(2*(352/8))-1,d6
	bra.s	.3

.5	add.w	#12*(2*(352/8)),a6
	bra.s	.2

.6	move.b	(a0)+,d0
	mulu	#50,d0
	move.w	d0,TxtWait

	addq.w	#1,TxtStep
	sub.l	#MelText,a0
	move.w	a0,TxtPntr
	tst.b	d5
	bne.s	Effects
	clr.w	TxtPntr

Effects	lea	TxtArea,a0
	lea	(352/8)(a0),a1
	move.w	#(24*12)-1,d7
.1	move.w	#11-1,d6
	move.l	(a0)+,d3
.2	move.l	d3,d0
	or.l	d0,-(2*(352/8))(a1)
	or.l	d0,(2*(352/8))(a1)
	move.l	d0,d1
	move.l	d0,d2
	move.l	-(64/8)(a0),d4
	moveq	#0,d5
	roxr.l	#1,d4
	roxr.l	#1,d2
	move.l	(a0)+,d3
	move.l	d3,d4
	moveq	#0,d5
	roxl.l	#1,d4
	roxl.l	#1,d1
	or.l	d1,(a1)
	or.l	d2,(a1)+
	dbf	d6,.2
	add.w	#((352-32)/8),a0
	add.w	#(352/8),a1
	dbf	d7,.1

	lea	TxtArea+2*(2*(352/8))+(352/8),a0
	lea	TxtArea+2*(0*(352/8))+(352/8),a1
	lea	TxtArea+2*(2*(352/8))+(352/8),a2
	lea	TxtArea+2*(2*(352/8)),a3
	move.w	#(24*12)-1,d7
.3	moveq	#11-1,d6
.4	move.l	(a0)+,d0
	move.l	(a1)+,d1
	move.l	(a2)+,d2
	move.w	-6(a1),d4
	roxr.w	#1,d4
	roxr.l	#1,d1
	roxr.w	#1,d4
	roxr.l	#1,d1
	not.l	d0
	and.l	d0,d1
	not.l	d2
	and.l	d2,d1
	or.l	d1,(a3)+
	dbf	d6,.4
	add.w	#(352/8),a0
	add.w	#(352/8),a1
	add.w	#(352/8),a2
	add.w	#(352/8),a3
	dbf	d7,.3
	rts

;-------------------;

TxtEntr	move.w	TxtSOff(pc),d0
	bsr.s	MveTxtS
	tst.w	TxtSOff
	beq.s	.3
	move.w	CopSOff(pc),d0
	add.w	d0,TxtSOff
	addq.w	#1,CopSOff
	tst.w	d0
	blt.s	.1
	move.w	#$0624,TxtCols+14
	move.w	#$0000,TxtCols+18
	move.w	#$0fff,TxtCols+22
	tst.w	TxtSOff
	blt.s	.2
	clr.w	TxtSOff
	bra.s	.2

.1	move.w	#$a47,TxtCols+14
	move.w	#$a47,TxtCols+18
	move.w	#$a47,TxtCols+22
.2	rts

.3	addq.w	#1,TxtStep
	move.w	#$0014,CopSOff
	rts

;--------------------------------------;

MveTxtS	lea	TxtArea,a0
	tst.w	d0
	bge.s	.1
	move.w	d0,d1
	muls	#2*(352/8),d1
	sub.l	d1,a0
.1	move.w	#$1811,d1
	move.w	#$1811,d2

	tst.w	d0
	ble.s	.3
	move.w	d0,d2
	add.w	#$001c,d2
	cmp.w	#$0100,d2
	bcs.s	.2
	move.w	#$ffe9,d1
.2	lsl.w	#8,d2
	move.b	#$11,d2
.3	move.w	#$1811,d3
	move.w	#$1811,d4
	add.w	#(24*12),d0

	tst.w	d0
	ble.s	.5
	move.w	d0,d4
	add.w	#$001c,d4
	cmp.w	#$0100,d4
	bcs.s	.4
	move.w	#$ffe9,d3
.4	lsl.w	#8,d4
	move.b	#$11,d4
.5	move.w	d1,CopOff1
	move.w	d2,CopOff2
	move.w	d3,CopOff3
	move.w	d4,CopOff4

	move.l	a0,d0
	lea	BPLText+2(pc),a0
	moveq	#2-1,d1
.6	move.w	d0,4(a0)
	swap	d0
	move.w	d0,(a0)
	swap	d0
	add.l	#(352/8),d0
	addq.w	#8,a0
	dbf	d1,.6
	rts

;--------------------------------------;

SpltScn	lea	ScnPntr(pc),a0
	move.l	(a0),d0
	lea	Screen1,a1
	lea	Screen2,a2
	cmp.l	a1,d0
	beq.s	.1
	move.l	a1,(a0)
	bra.s	.2
.1	move.l	a2,(a0)

.2	btst	#7,$dff004		;Interlace check
	bne.s	.3
	add.l	#(352/8),d0
.3	lea	BPLScrn+2(pc),a0
	move.w	d0,4(a0)
	swap	d0
	move.w	d0,(a0)

	movea.l	ScnPntr(pc),a0
	add.w	#160*(352/8),a0
	lea	$dff000,a6
	WaitBlt	14
	move.l	a0,$54(a6)
	move.w	#$0000,$66(a6)
	move.l	#$01000000,$40(a6)
	move.w	#256<<6+(352/16),$58(a6)

	lea	SinList(pc),a0
	move.w	SinPntr(pc),d4
	add.w	d4,d4
	moveq	#0,d1
	moveq	#0,d3

	move.w	(a0,d4),d1
	sub.w	#288,d1
	muls	Counter(pc),d1
	asr.l	#8,d1
	add.w	#288,d1

	add.w	#$100,d4
	and.w	#$1ff,d4
	move.w	(a0,d4),d3
	sub.w	#288,d3
	muls	Counter(pc),d3
	asr.l	#8,d3
	add.w	#288,d3

	moveq	#0,d0
	moveq	#0,d2
	move.w	#351,d2
	movem.w	d3,-(a7)
	bsr.l	DrawLne
	move.w	#351,d2
	move.l	d2,d0
	move.w	#416,d1
	movem.w	(a7)+,d3
	bsr.l	DrawLne
	addq.b	#1,SinPntr+1
	move.l	ScnPntr(pc),a0
	add.w	#(416*(352/8))-1,a0

FillScn	lea	$dff000,a6
	WaitBlt	14
	move.l	a0,$50(a6)
	move.l	a0,$54(a6)
	move.l	#$00000000,$64(a6)
	move.l	#$09f0000a,$40(a6)
	move.l	#$ffffffff,$44(a6)
	move.w	#256<<6+(352/16),$58(a6)
	rts

;--------------------------------------;

SinList	dc.w	$0121,$0124,$0127,$012a,$012e,$0131,$0134,$0137
	dc.w	$013a,$013d,$0140,$0143,$0146,$0149,$014c,$014f
	dc.w	$0152,$0155,$0158,$015a,$015d,$0160,$0163,$0165
	dc.w	$0168,$016a,$016d,$016f,$0172,$0174,$0177,$0179
	dc.w	$017b,$017d,$017f,$0181,$0183,$0185,$0187,$0189
	dc.w	$018b,$018c,$018e,$0190,$0191,$0193,$0194,$0195
	dc.w	$0196,$0197,$0199,$019a,$019a,$019b,$019c,$019d
	dc.w	$019d,$019e,$019e,$019f,$019f,$019f,$019f,$019f
	dc.w	$019f,$019f,$019f,$019f,$019f,$019e,$019e,$019d
	dc.w	$019d,$019c,$019b,$019a,$019a,$0199,$0197,$0196
	dc.w	$0195,$0194,$0193,$0191,$0190,$018e,$018c,$018b
	dc.w	$0189,$0187,$0185,$0183,$0181,$017f,$017d,$017b
	dc.w	$0179,$0177,$0174,$0172,$016f,$016d,$016a,$0168
	dc.w	$0165,$0163,$0160,$015d,$015a,$0158,$0155,$0152
	dc.w	$014f,$014c,$0149,$0146,$0143,$0140,$013d,$013a
	dc.w	$0137,$0134,$0131,$012e,$012a,$0127,$0124,$0121
	dc.w	$011f,$011c,$0119,$0116,$0112,$010f,$010c,$0109
	dc.w	$0106,$0103,$0100,$00fd,$00fa,$00f7,$00f4,$00f1
	dc.w	$00ee,$00eb,$00e8,$00e6,$00e3,$00e0,$00dd,$00db
	dc.w	$00d8,$00d6,$00d3,$00d1,$00ce,$00cc,$00c9,$00c7
	dc.w	$00c5,$00c3,$00c1,$00bf,$00bd,$00bb,$00b9,$00b7
	dc.w	$00b5,$00b4,$00b2,$00b0,$00af,$00ad,$00ac,$00ab
	dc.w	$00aa,$00a9,$00a7,$00a6,$00a6,$00a5,$00a4,$00a3
	dc.w	$00a3,$00a2,$00a2,$00a1,$00a1,$00a1,$00a1,$00a1
	dc.w	$00a1,$00a1,$00a1,$00a1,$00a1,$00a2,$00a2,$00a3
	dc.w	$00a3,$00a4,$00a5,$00a6,$00a6,$00a7,$00a9,$00aa
	dc.w	$00ab,$00ac,$00ad,$00af,$00b0,$00b2,$00b4,$00b5
	dc.w	$00b7,$00b9,$00bb,$00bd,$00bf,$00c1,$00c3,$00c5
	dc.w	$00c7,$00c9,$00cc,$00ce,$00d1,$00d3,$00d6,$00d8
	dc.w	$00db,$00dd,$00e0,$00e3,$00e6,$00e8,$00eb,$00ee
	dc.w	$00f1,$00f4,$00f7,$00fa,$00fd,$0100,$0103,$0106
	dc.w	$0109,$010c,$010f,$0112,$0116,$0119,$011c,$011f

;--------------------------------------;
;	d0-d3 = X0,Y0,X1,Y1

DrawLne	lea	$00dff000,a6
	WaitBlt	14
	move.w	#(352/8),$60(a6)
	move.l	#$ffff8000,$72(a6)
	move.l	#$ffffffff,$44(a6)

	move.l	ScnPntr(pc),a0
	cmp.w	d1,d3
	bgt.s	.1
	exg	d0,d2
	exg	d1,d3
	beq.s	.5
.1	move.w	d1,d4
	muls	#(352/8),d4
	moveq	#0,d5
	move.w	d0,d5
	add.l	a0,d4
	asr.w	#4,d5
	add.w	d5,d5
	add.l	d5,d4
	moveq	#0,d5
	sub.w	d1,d3
	sub.w	d0,d2
	bpl.s	.2
	moveq	#1,d5
	neg.w	d2
.2	move.w	d3,d1
	add.w	d1,d1
	cmp.w	d2,d1
	dbhi	d3,.3
.3	move.w	d3,d1
	sub.w	d2,d1
	bpl.s	.4
	exg	d2,d3
.4	addx.w	d5,d5
	add.w	d2,d2
	move.w	d2,d1
	sub.w	d3,d2
	addx.w	d5,d5
	and.w	#$f,d0
	ror.w	#4,d0
	or.w	#$0a4a,d0			;$0aca for line mode

	WaitBlt	14
	move.w	d2,$52(a6)
	sub.w	d3,d2
	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d0,$40(a6)
	move.b	Octants(pc,d5),$43(a6)
	move.l	d4,$48(a6)
	move.l	d4,$54(a6)
	movem.w	d1-d2,$62(a6)
	move.w	d3,$58(a6)
.5	WaitBlt	14
	rts

Mode	= 2	;0=Line, 2=Fill
Octants	dc.b	$01+Mode,$41+Mode,$11+Mode,$51+Mode
	dc.b	$09+Mode,$49+Mode,$15+Mode,$55+Mode

;--------------------------------------;

CList	dc.w	$008e,$1c71,$0090,$3ce1
	dc.w	$0092,$0030,$0094,$00e0

	dc.w	$0120,MelSpr1>>16,$0122,MelSpr1&$ffff
	dc.w	$0124,MelSpr2>>16,$0126,MelSpr2&$ffff
	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000

	dc.w	$0108,$ffd4,$010a,$002c

	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000
	dc.w	$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000
	dc.w	$019c,$0000,$019e,$0000

WavCols	dc.w	$0190,$0000,$0194,$0000
TxtCols	dc.w	$0192,$0243,$0198,$0000
	dc.w	$019a,$0fff,$0196,$0624
	dc.w	$019c,$0000,$019e,$0fff

	dc.w	$01a4,$0000,$01a2,$0fff

	dc.w	$1001,$fffe
BPLScrn	dc.w	$00e4,$0000
	dc.w	$00e6,$0000
BPLText	dc.w	$00e0,TxtArea>>16
	dc.w	$00e2,TxtArea&$ffff
	dc.w	$00e8,(TxtArea+(352/8))>>16
	dc.w	$00ea,(TxtArea+(352/8))&$ffff
	dc.w	$00ec,WavExtr>>16
	dc.w	$00ee,WavExtr&$ffff
	dc.w	$0100,$4204
	dc.w	$0102,$0000,$0104,$0024

	dc.w	$1701,$fffe
CopOff1	dc.w	$1801,$fffe
CopOff2	dc.w	$1801,$fffe
	dc.w	$0108,$002c
CopOff3	dc.w	$ffe1,$fffe

CopOff4	dc.w	$3c11,$fffe
	dc.w	$0108,$ffd4,$0186,$0a47
	dc.w	$018c,$0a47,$018e,$0a47

NoCList	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

VBRStor	dc.l	0
IlgStor	dc.l	0
IntEna	dc.w	0
DMACon	dc.w	0
OldIRQ	dc.l	0
TxtWait	dc.w	0
SpriteX	dc.w	356
Unused1	dc.l	0			;Obsolete
Unused2	dc.w	64			;Obsolete
Unused3	dc.w	64			;Obsolete
RtnStep	dc.w	0
Counter	dc.w	0
SinPntr	dc.w	0
ScnPntr	dc.l	Screen1
ExitFlg	dc.w	0
VBlank	dc.w	0
RastMax	dc.w	0
CopSOff	dc.w	$ffe1
TxtSOff	dc.w	(24*12)
TxtPntr	dc.w	0
TxtStep	dc.w	0

;--------------------------------------;

MelText	dc.b	10
	dc.b	"    * C  R  Y  S  T  A  L * cracked:",10
	dc.b	10
	dc.b	"               BODY BLOWS",10
	dc.b	"               ||||||||||",10
	dc.b	10
	dc.b	"   All the rocket ships are climbing",10
	dc.b	"    through the sky, the holy books",10
	dc.b	"   are open wide, the doctors working",10
	dc.b	"    day and night, but they'll never",10
	dc.b	"      ever find that cure for love.",10
	dc.b	"     There ain't no drink, no drug,",10
	dc.b	"     there's nothing pure enough to",10
	dc.b	"          be a cure for love..",10
	dc.b	10
	dc.b	"         Accept no imitations..",10
	dc.b	"         We are the world's #1!",10
	dc.b	1,10

	dc.b	10
	dc.b	" For quick and reliable trading, write:",10
	dc.b	10
	dc.b	"             a) P.O. Box 2",10
	dc.b	"                8330 Beder",10
	dc.b	"                 Denmark",10
	dc.b	10
	dc.b	"    b) Fermo Posta   c) P.O. Box 116",10
	dc.b	"      C.I.83429870     Upper Poppleton",10
	dc.b	"     Milano Cordusio    York, YO2 6YY",10
	dc.b	"          Italy            England",10
	dc.b	10
	dc.b	" a) All in games and utilities on Amiga",10
	dc.b	" and PC. Include phone# if possible!",10
	dc.b	" b) and c) replace a) in Italy and the",10
	dc.b	" United Kingdom respectively..",10
	dc.b	1,10

	dc.b	10
	dc.b	"Call us NOW for the very best deals in",10
	dc.b	"Video Game Console Disk back-up Systems",10
	dc.b	"for the SUPER NINTENDO/SUPER FAMICOM and",10
	dc.b	"MEGADRIVE/GENESIS. We stock Super Wild-",10
	dc.b	"card(Magicom 2) for SNES and Super Magic",10
	dc.b	"Drive for Megadrive/Genesis consoles.",10
	dc.b	"These systems allow the backing-up of",10
	dc.b	"all game cartridges to floppy disks and",10
	dc.b	"allow them to be reloaded independantly",10
	dc.b	"of the original cartridge. The system",10
	dc.b	"includes a high quality PC compatable,",10
	dc.b	"3.5"" HD disk drive. A MUST for all real",10
	dc.b	"Console videogame freaks!",10
	dc.b	10
	dc.b	"     0382 739 192        (U.K.)",10
	dc.b	"     917-462-5071        (USA ONLY)",10
	dc.b	"     ++44 382 739192     (WorldWide)",10
	dc.b	1,10

	dc.b	10
	dc.b	"Credits for this intro:",10
	dc.b	"|||||||||||||||||||||||",10
	dc.b	" Code'n design by  * Slammer & Xience *",10
	dc.b	0,3
	even

;--------------------------------------;

MelSpr1	dc.w	0,0
	dc.w	%0000000000000011,%1111111111111100
	dc.w	%0000000000000011,%1111111111111100
	dc.w	%0010100011001011,%1101011100110100
	dc.w	%0101010100101011,%1010101011010100
	dc.w	%0101010111101011,%1010101000010100
	dc.w	%0101010100001011,%1010101011110100
	dc.w	%0101010011100101,%1010101100011010
	dc.w	%0000000000000011,%1111111111111100
	dc.w	%0000000000000011,%1111111111111100
	dc.w	0,0

MelSpr2	dc.w	0,0
	dc.w	%1111111111000000,%0000000000000000
	dc.w	%1111111111000000,%0000000000000000
	dc.w	%1001100011000000,%0110011100000000
	dc.w	%0110101101000000,%1001010010000000
	dc.w	%0110101101000000,%1001010010000000
	dc.w	%0110101101000000,%1001010010000000
	dc.w	%1001101101000000,%0110010010000000
	dc.w	%1111111111011000,%0000000000000000
	dc.w	%1111111111011000,%0000000000000000
	dc.w	0,0

;--------------------------------------;

MelFont	include	"DH2:MelonBB/Melon.fnt"

;--------------------------------------;

ZroArea	dc.w	0
ShitReg	dc.w	0			;Obsolete
SysStck	dc.l	0

;--------------------------------------;
;	Melon intro ends here, These buffers are so precious memory is
;	not taken. No more gurus.

Screen1	dcb.b	160*(352/8),0
	dcb.b	256*(352/8),0
	dcb.b	160*(352/8),0
Screen2	dcb.b	160*(352/8),0
	dcb.b	256*(352/8),0
	dcb.b	160*(352/8),0

	dcb.b	4*(352/8),0

TxtArea	dcb.b	2*(29*12*(352/8)),0
WavExtr	dcb.b	160*(352/8),0
	dcb.b	256*(352/8),0
	dcb.b	160*(352/8),0
End	END

