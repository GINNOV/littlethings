;	Borders

BWidth	= 30					;Screen Width
BHeight	= 50					;Screen Height
Objects = 100					;Number of Objects

	SECTION	"Frantic - Tetris",CODE_C

;--------------------------------------;

WaitBlt	MACRO
	tst.b	2(a5)
.WB\@	btst	#6,2(a5)
	bne.b	.WB\@
	ENDM

;--------------------------------------;

Start	bsr	WrteTxt
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

	move.w	$1c(a5),d0
	or.w	#$c000,d0
	move.w	d0,IntEna

	move.w	2(a5),d0
	or.w	#$8000,d0
	move.w	d0,DMACon

	move.w	$7c(a5),d0
	cmp.b	#$f8,d0
	bne.b	.NonAGA
	move.w	#0,$106(a5)
	move.w	#0,$1fc(a5)

.NonAGA	move.l	#Title,d0
	lea	BPLTitl(pc),a0
	moveq	#2-1,d7
.0	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#(320/8),d0
	addq.l	#8,a0
	dbf	d7,.0

	move.l	#TxtArea,d0
	lea	BPLText(pc),a0
	moveq	#2-1,d7
.1	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#(320/8),d0
	addq.l	#8,a0
	dbf	d7,.1

	bsr.w	GetVBR
	lea	$dff000,a5
	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	$6c(a4),OldIRQ
	move.w	#$0020,$9a(a5)

	move.w	#$7fff,$96(a5)
	move.l  #CList,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$83d0,$96(a5)
	move.l	#0,$144(a5)

.Mouse	tst.w	Option
	bmi	.2
	btst	#7,$bfe001
	bne	.2
	bsr	InitGme
.2	btst	#6,$bfe001
	bne.b	.Mouse

	lea	$dff000,a5
	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	VBRStor(pc),a4
	move.l	OldIRQ(pc),$6c(a4)
	move.w	IntEna(pc),$9a(a5)

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

GetVBR	sub.l	a4,a4
	move.l	4.w,a6
	btst	#0,297(a6)
	beq.w	.VBR1
	lea	.VBR2(pc),a5
	jsr	-30(a6)
.VBR1	move.l	a4,VBRStor
	rts

.VBR2	dc.w	$4e7a,$c801
	rte
VBRStor	dc.l	0

;--------------------------------------;

WrteTxt	lea	MainTxt(pc),a0

	moveq	#0,d6
.10	moveq	#0,d5

.11	moveq	#0,d0
	move.b	(a0)+,d0
	lea	CharSet(pc),a1
	moveq	#0,d1
	bra	.2
.1	addq.w	#1,d1
.2	cmp.b	(a1)+,d0
	bne	.1
	lea	MainFnt(pc),a1
	lea	(a1,d1),a1

	lea	TxtArea,a2
	lea	(a2,d5),a2
	lea	(a2,d6.l),a2

	moveq	#(5*6)-1,d7
.3	move.b	(a1),(a2)
	lea	(320/8)(a1),a1
	lea	(320/8)(a2),a2
	dbf	d7,.3

	addq.w	#1,d5
	cmp.w	#40,d5
	bne	.11
	add.l	#5*7*(320/8),d6
	cmp.w	#7*(5*7*(320/8)),d6
	bne	.10
	rts

;--------------------------------------;

InitGme	move.w	#-1,Option

	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	#TopScrn,$54(a5)
	move.w	#5*108<<6+(320/16),$58(a5)
	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	#TopScrn+(5*108*(320/8)),$54(a5)
	move.w	#5*108<<6+(320/16),$58(a5)

	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	#ScrnDat,$54(a5)
	move.w	#52<<6+40,$58(a5)

	lea	RndArea(pc),a0
	move.w	#Objects-1,d7
	move.b	$dff006,d0
.1	bsr	RandomSeed
	move.w	#7,d0
	bsr	Random
	move.b	d0,(a0)+
	move.l	d1,d0
	dbf	d7,.1

	lea	Player1(pc),a6
	moveq	#78,d4
	sub.w	BlkWdth(pc),d4
	lsl.w	#1,d4
	move.w	d4,26(a6)
	bsr	InitBdr
	bsr	InitPlr

	move.l	#TopScrn,d0
	lea	BPL0(pc),a0
	moveq	#5-1,d7
.0	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#(320/8),d0
	addq.l	#8,a0
	dbf	d7,.0

	move.l	#Screen1,d0
	move.l	#Screen1+(5*210*(320/8)),d1
	lea	BPL1(pc),a0
	lea	BPL2(pc),a1
	moveq	#5-1,d7
.2	move.w	d0,6(a0)
	move.w	d1,6(a1)
	swap	d0
	swap	d1
	move.w	d0,2(a0)
	move.w	d1,2(a1)
	swap	d0
	swap	d1
	add.l	#(320/8),d0
	add.l	#(320/8),d1
	addq.l	#8,a0
	addq.l	#8,a1
	dbf	d7,.2

	move.l	#Details,d0
	lea	BPL3(pc),a0
	moveq	#2-1,d7
.3	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#(640/8),d0
	addq.l	#8,a0
	dbf	d7,.3

	move.w	#$7fff,$96(a5)
	move.l  #GCList,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$83d0,$96(a5)
	move.l	#0,$144(a5)

	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	VBRStor(pc),a4
	move.l	#GameIRQ,$6c(a4)
	move.w	#$c020,$9a(a5)

	rts

;--------------------------------------;

GameIRQ	movem.l	d0-a6,-(a7)

	move.w	$dff00c,d0
	lea	JyStat1(pc),a0
	bsr	TestJoy
	move.w	$dff00a,d0
	lea	JyStat2(pc),a0
	bsr	TestJoy

	lea	Player1(pc),a6
	bsr	ChckEnd
	bsr	ChckObj
	move.b	JyStat1(pc),d0
	bsr	Jystick
	bsr	ClrObj
	bsr	DoScDat
	bsr	ShveObj
	bsr	DspScre
	bsr	SubPrio

	move.w	#$8001,$96(a5)		;Start DMA
	move.w	#2,$a4(a5)		;Length/2

	movem.l	(a7)+,d0-a6
	move.w	#$00f0,$180(a5)
	move.w	#$0020,$9c(a5)
	rte

;--------------------------------------;

TestJoy	clr.b	(a0)
	btst	#7,$bfe001
	bne	JoyHorz
	bset	#0,(a0)
JoyHorz	btst	#9,d0
	bne	JoyLeft
	btst	#1,d0
	bne	JoyRght
	bra	JoyVert

JoyLeft	bset	#4,(a0)
	bra	JoyVert
JoyRght	bset	#3,(a0)

JoyVert	move.w	d0,d1
	lsr.w	#1,d0
	eor.w	d1,d0
	btst	#8,d0
	bne	JoyUpwd
	btst	#0,d0
	bne	JoyDown
	bra	NotHorz

JoyUpwd	bset	#2,(a0)
	bra	NotHorz
JoyDown	bset	#1,(a0)

NotHorz	rts

;--------------------------------------;

InitPlr	moveq	#0,d0
	move.b	RndArea(pc),d0
	move.w	d0,(a6)
	move.w	d0,10(a6)
	clr.w	2(a6)
	clr.w	12(a6)
	move.w	BlkWdth(pc),d0
	lsl.w	#1,d0
	move.w	d0,4(a6)
	move.w	d0,14(a6)
	clr.w	6(a6)
	clr.w	16(a6)
	clr.w	8(a6)
	clr.b	18(a6)
	move.b	#1,19(a6)
	clr.w	20(a6)
	clr.w	22(a6)
	rts

;--------------------------------------;

InitBdr	moveq	#0,d4
	moveq	#0,d5
	subq.w	#4,d4
	add.w	BlkWdth(pc),d5
	lsl.w	#2,d5
	moveq	#0,d6

	move.l	d4,d0
	move.l	d6,d1
	lea	TopScrn(pc),a0
	lea	BlckBdr(pc),a1
	bsr	BlitObj
	move.l	d5,d0
	move.l	d6,d1
	lea	TopScrn(pc),a0
	lea	BlckBdr(pc),a1
	bsr	BlitObj

	moveq	#0,d7
	move.w	BlkHght(pc),d7
	subq.w	#2,d7
	
.1	move.l	d4,d0
	move.l	d6,d1
	lea	Screen1(pc),a0
	lea	BlckBdr+(5*4*(32/8))(pc),a1
	bsr	BlitObj
	move.l	d5,d0
	move.l	d6,d1
	lea	Screen1(pc),a0
	lea	BlckBdr+(5*4*(32/8))(pc),a1
	bsr	BlitObj
	addq.w	#4,d6
	dbf	d7,.1

	move.l	d4,d0
	move.l	d6,d1
	lea	Screen1(pc),a0
	lea	BlckBdr+(5*8*(32/8))(pc),a1
	bsr	BlitObj
	move.l	d5,d0
	move.l	d6,d1
	lea	Screen1(pc),a0
	lea	BlckBdr+(5*8*(32/8))(pc),a1
	bsr	BlitObj
	rts	

;--------------------------------------;

Jystick	subq.b	#1,8(a6)
	tst.b	8(a6)
	bpl	TstButn
	clr.b	8(a6)

TstLeft	btst	#4,d0
	beq	TstRght
	subq.w	#4,4(a6)
	move.b	#1,8(a6)
	bra	TstButn

TstRght	btst	#3,d0
	beq	TstButn
	addq.w	#4,4(a6)
	move.b	#1,8(a6)

TstButn	btst	#0,9(a6)
	beq	TstBut1
	btst	#7,$bfe001
	beq	TstDown
	bclr	#0,9(a6)
TstBut1	btst	#0,d0
	beq	TstDown
	bset	#0,9(a6)

	addq.w	#1,2(a6)
	cmp.w	#4,2(a6)
	bne	TstDown
	clr.w	2(a6)

TstDown	btst	#1,d0
	bne	.1
	move.b	19(a6),d1
	cmp.b	24(a6),d1
	beq	NoTest
	subq.b	#1,19(a6)
	bra	NoTest
.1	cmp.b	#7,19(a6)
	beq	NoTest
	addq.b	#1,19(a6)
NoTest	rts

;--------------------------------------;

ChckEnd	cmp.w	#-2,Option
	bne	.1
	move.w	#0,Option

	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.w	#$0020,$9a(a5)

	move.w	#$7fff,$96(a5)
	move.l  #CList,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$83d0,$96(a5)
	move.l	#0,$144(a5)

	addq.l	#4,a7
	movem.l	(a7)+,d0-a6
	rte

.1	rts

;--------------------------------------;

ClrObj	lea	ShpPtrn(pc),a4
	moveq	#0,d0
	move.w	(a6),d0
	lsl.w	#6,d0
	lea	(a4,d0),a4
	move.w	12(a6),d0
	lsl.w	#4,d0
	lea	(a4,d0),a4

	moveq	#0,d0
	moveq	#0,d1
	move.w	14(a6),d0
	move.w	16(a6),d1
	lsr.w	#1,d1
	moveq	#4-1,d7
.1	moveq	#4-1,d6
.2	tst.b	(a4)+
	beq	.3
	lea	Screen1(pc),a0
	lea	BlckDat(pc),a1
	bsr	BlitObj
.3	addq.w	#4,d0
	dbf	d6,.2
	move.w	BlkWdth(pc),d6
	lea	(a0,d6),a0
	move.l	a0,a1
	sub.w	#4*4,d0
	addq.w	#4,d1
	dbf	d7,.1

ClrObj2	lea	ScrnDat(pc),a0
	lea	ShpPtrn(pc),a4
	moveq	#0,d0
	move.w	(a6),d0
	lsl.w	#6,d0
	lea	(a4,d0),a4
	move.w	12(a6),d0
	lsl.w	#4,d0
	lea	(a4,d0),a4
	move.w	14(a6),d4
	asr.w	#2,d4
	lea	(a0,d4),a0
	move.w	16(a6),d5
	lsr.w	#1,d5
	asr.w	#2,d5
	moveq	#0,d3
	move.w	d5,d3
	mulu	BlkWdth(pc),d3
	lea	(a0,d3),a0

	move.l	a0,a1
	moveq	#4-1,d7
.1	moveq	#4-1,d6
.2	move.b	(a4)+,d0
	beq	.3
	clr.b	(a1)
.3	addq.l	#1,a1
	addq.w	#1,d4
	dbf	d6,.2
	move.w	BlkWdth(pc),d6
	lea	(a0,d6),a0
	move.l	a0,a1
	subq.w	#4,d4
	addq.w	#1,d5
	dbf	d7,.1
	rts

;--------------------------------------;

ShveObj	lea	ShpPtrn(pc),a4
	moveq	#0,d0
	move.w	(a6),d0
	lsl.w	#6,d0
	lea	(a4,d0),a4
	move.w	2(a6),d0
	lsl.w	#4,d0
	lea	(a4,d0),a4

	lea	BlckDat(pc),a3
	moveq	#4-1,d7
	moveq	#0,d5
.1	moveq	#4-1,d6
	moveq	#0,d4
.2	moveq	#0,d0
	move.b	(a4)+,d0
	beq	.3
	mulu	#5*4*(32/8),d0
	lea	(a3,d0),a1
	lea	Screen1(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	move.w	4(a6),d0
	move.w	6(a6),d1
	lsr.w	#1,d1
	add.w	d4,d0
	add.w	d5,d1
	bsr	BlitObj
.3	addq.w	#4,d4
	dbf	d6,.2
	addq.w	#4,d5
	dbf	d7,.1
	rts

;--------------------------------------;
;	d0-X, d1-Y, a0-Screen, a1-BrkData

BlitObj	movem.l	d0-d3/a2,-(a7)
	move.l	d1,d2
	move.l	d1,d3
	lsl.l	#3,d1
	lsl.l	#6,d2
	lsl.l	#7,d3
	add.l	d3,d2
	add.l	d2,d1
	lea	(a0,d1.l),a2

	add.w	26(a6),d0
	move.w	d0,d2
	and.w	#$f,d0
	ror.w	#4,d0
	WaitBlt
	move.w	d0,$42(a5)
	or.w	#$0fca,d0
	move.w	d0,$40(a5)
	lsr.w	#3,d2
	lea	(a2,d2),a2

	move.l	#$ffff0000,$44(a5)	;Mask
	move.l	#$00240000,$60(a5)	;Modulos
	move.l	#$00000024,$64(a5)	;Modulos
	move.l	a1,$4c(a5)		;BLTBDAT
	move.l	#BlckMsk,$50(a5)	;BLTADAT
	move.l	a2,$48(a5)		;BLTCDAT
	move.l	a2,$54(a5)		;BLTDDAT
	move.w	#5*4<<6+(32/16),$58(a5)
	movem.l	(a7)+,d0-d3/a2
	rts

;--------------------------------------;

DoScDat
ChkHorz	lea	ScrnDat(pc),a0
	lea	ShpPtrn(pc),a4
	moveq	#0,d0
	move.w	(a6),d0
	lsl.w	#6,d0
	lea	(a4,d0),a4
	move.w	12(a6),d0
	lsl.w	#4,d0
	lea	(a4,d0),a4
	move.w	4(a6),d4
	asr.w	#2,d4
	lea	(a0,d4),a0
	move.w	16(a6),d5
	move.w	d5,d6
	asr.w	#3,d5
	moveq	#0,d1
	and.w	#%111,d6
	beq	.0
	moveq	#1,d1
	addq.w	#1,d5
.0	moveq	#0,d3
	move.w	d5,d3
	mulu	BlkWdth(pc),d3
	lea	(a0,d3),a0
	bsr	ChkClsh
	bne	.1
	tst.b	d1
	bne	.2
	move.w	4(a6),14(a6)
	bra	.4
.1	move.w	14(a6),4(a6)
	clr.b	8(a6)
	bra	.4

.2	lea	ScrnDat(pc),a0
	lea	ShpPtrn(pc),a4
	moveq	#0,d0
	move.w	(a6),d0
	lsl.w	#6,d0
	lea	(a4,d0),a4
	move.w	12(a6),d0
	lsl.w	#4,d0
	lea	(a4,d0),a4
	move.w	4(a6),d4
	asr.w	#2,d4
	lea	(a0,d4),a0
	move.w	16(a6),d5
	asr.w	#3,d5
	moveq	#0,d3
	move.w	d5,d3
	mulu	BlkWdth(pc),d3
	lea	(a0,d3),a0
	bsr	ChkClsh
	bne	.3
	move.w	4(a6),14(a6)
	bra	.4
.3	move.w	14(a6),4(a6)
	clr.b	8(a6)
.4

ChkVert	lea	ScrnDat(pc),a0
	lea	ShpPtrn(pc),a4
	moveq	#0,d0
	move.w	(a6),d0
	lsl.w	#6,d0
	lea	(a4,d0),a4
	move.w	12(a6),d0
	lsl.w	#4,d0
	lea	(a4,d0),a4
	move.w	4(a6),d4
	asr.w	#2,d4
	lea	(a0,d4),a0
	move.w	6(a6),d5
	move.w	d5,d6
	asr.w	#3,d5
	and.w	#%111,d6
	beq	.0
	addq.w	#1,d5
.0	moveq	#0,d3
	move.w	d5,d3
	mulu	BlkWdth(pc),d3
	lea	(a0,d3),a0
	bsr	ChkClsh
	bne	.1
	move.w	6(a6),16(a6)
	clr.b	18(a6)
	bra	.2
.1	and.w	#$fff8,6(a6)
	move.w	6(a6),16(a6)
	addq.b	#1,18(a6)
	cmp.b	#1,18(a6)
	bne	.2
	lea	Collide,a0
	bsr	PlaySnd
.2

ChkRott	lea	ScrnDat(pc),a0
	lea	ShpPtrn(pc),a4
	moveq	#0,d0
	move.w	(a6),d0
	lsl.w	#6,d0
	lea	(a4,d0),a4
	move.w	2(a6),d0
	lsl.w	#4,d0
	lea	(a4,d0),a4
	move.w	4(a6),d4
	asr.w	#2,d4
	lea	(a0,d4),a0
	move.w	6(a6),d5
	move.w	d5,d6
	asr.w	#3,d5
	and.w	#%111,d6
	beq	.0
	addq.w	#1,d5
.0	moveq	#0,d3
	move.w	d5,d3
	mulu	BlkWdth(pc),d3
	lea	(a0,d3),a0
	bsr	ChkClsh
	bne	.1
	move.w	2(a6),d0
	cmp.w	12(a6),d0
	beq	.11
	lea	Rotate,a0
	bsr	PlaySnd
.11	move.w	2(a6),12(a6)
	bra	.2
.1	move.w	12(a6),2(a6)
.2

PlceObj	lea	ScrnDat(pc),a0
	lea	ShpPtrn(pc),a4
	moveq	#0,d0
	move.w	(a6),d0
	lsl.w	#6,d0
	lea	(a4,d0),a4
	move.w	2(a6),d0
	lsl.w	#4,d0
	lea	(a4,d0),a4
	move.w	4(a6),d4
	asr.w	#2,d4
	lea	(a0,d4),a0
	move.w	6(a6),d5
;	lsr.w	#1,d5
	asr.w	#3,d5
	moveq	#0,d3
	move.w	d5,d3
	mulu	BlkWdth(pc),d3
	lea	(a0,d3),a0

	move.l	a0,a1
	moveq	#4-1,d7
.2	moveq	#4-1,d6
.3	move.b	(a4)+,d0
	beq	.4
	move.b	d0,(a1)
.4	addq.l	#1,a1
	addq.w	#1,d4
	dbf	d6,.3
	move.w	BlkWdth(pc),d6
	lea	(a0,d6),a0
	move.l	a0,a1
	subq.w	#4,d4
	addq.w	#1,d5
	dbf	d7,.2
	rts

;-------------------;

ChkClsh	move.l	a0,a1
	moveq	#4-1,d7
.1	moveq	#4-1,d6
.2	move.b	(a4)+,d0
	beq	.3
	cmp.w	#0,d4
	blt	BadClsh
	cmp.w	BlkWdth(pc),d4
	bge	BadClsh
	cmp.w	BlkHght(pc),d5
	bge	BadClsh

	tst.b	(a1)
	bne	BadClsh

.3	addq.l	#1,a1
	addq.w	#1,d4
	dbf	d6,.2
	move.w	BlkWdth(pc),d6
	lea	(a0,d6),a0
	move.l	a0,a1
	subq.w	#4,d4
	addq.w	#1,d5
	dbf	d7,.1
	moveq	#0,d0
EndClsh	tst.w	d0
	rts

BadClsh	moveq	#-1,d0
	bra	EndClsh

;--------------------------------------;

ChckObj	cmp.b	#25,18(a6)
	beq	.1
	moveq	#0,d0
	move.b	19(a6),d0
	add.w	d0,6(a6)
	rts

;-------------------;

.1	moveq	#0,d0
	move.w	BlkWdth(pc),d0
	lsl.w	#1,d0
	move.w	d0,4(a6)
	moveq	#0,d0
	move.w	d0,2(a6)
	move.l	d0,6(a6)
	move.l	d0,10(a6)
	move.l	d0,14(a6)
	move.b	d0,18(a6)
	addq.w	#1,20(a6)
	move.w	20(a6),d0
	cmp.w	#Objects,d0
	bne	.2
	clr.w	d0
	move.w	d0,20(a6)
.2	lea	RndArea(pc),a0
	moveq	#0,d1
	move.b	(a0,d0),d1
	move.w	d1,(a6)
	addq.w	#1,22(a6)

;-------------------;

ChkLnes	moveq	#0,d3
	lea	ScrnDat(pc),a0
	moveq	#0,d5
	move.w	BlkHght(pc),d7
	subq.w	#1,d7
.1	move.l	a0,a1
	move.w	BlkWdth(pc),d6
	subq.w	#1,d6
.2	tst.b	(a1)+
	beq	.3
	dbf	d6,.2
	addq.b	#1,d3
	movem.l	d3/d5-a1,-(a7)
	bsr	LineMde
	movem.l	(a7)+,d3/d5-a1
.3	addq.w	#1,d5
	move.w	BlkWdth(pc),d0
	lea	(a0,d0),a0
	dbf	d7,.1

	moveq	#0,d4
	lea	ScreLst(pc),a0
	move.b	(a0,d3),d4
	add.w	d4,22(a6)
	tst.w	d3
	beq	.4
	subq.w	#1,d3
	lea	PriList(pc),a0
	lsl.w	#1,d3
	move.w	(a0,d3),Priorty
	lsl.w	#1,d3
	lea	SndList(pc),a0
	move.l	(a0,d3),a0
	bsr	PlaySnd

.4	lea	ScrnDat(pc),a0
	lea	ShpPtrn(pc),a4
	moveq	#0,d0
	move.w	(a6),d0
	lsl.w	#6,d0
	lea	(a4,d0),a4
	move.w	2(a6),d0
	lsl.w	#4,d0
	lea	(a4,d0),a4
	move.w	4(a6),d4
	asr.w	#2,d4
	lea	(a0,d4),a0
	move.w	6(a6),d5
	asr.w	#3,d5
	moveq	#0,d3
	move.w	d5,d3
	mulu	BlkWdth(pc),d3
	lea	(a0,d3),a0
	bsr	ChkClsh
	beq	.5
	move.w	#-2,Option

.5	rts

LineMde	moveq	#0,d0
	move.w	d5,d0
	move.l	d0,d1
	mulu	#5*4,d0
	lsl.w	#6,d0
	or.w	#(320/16),d0

	lea	Screen1(pc),a1
	mulu	#5*4*(320/8),d1
	lea	(a1,d1.l),a1
	lea	-2(a1),a1
	lea	5*4*(320/8)(a1),a2
	WaitBlt
	move.l	#$09f00002,$40(a5)	;BLTCON0
	move.l	#$ffffffff,$44(a5)	;Mask
	move.l	#$00000000,$64(a5)	;Modulos
	move.l	a1,$50(a5)		;BLTADAT
	move.l	a2,$54(a5)		;BLTDDAT
	move.w	d0,$58(a5)

	lea	ScrnDat(pc),a1
	moveq	#0,d0
	move.w	d5,d0
	mulu	BlkWdth(pc),d0
	move.w	d0,d4
	lea	(a1,d0),a1
	move.w	BlkWdth(pc),d0
	lea	(a1,d0),a2
	move.l	a1,a3
	move.l	a2,a4
	subq.w	#1,d4
.1	move.b	-(a1),-(a2)
	dbf	d4,.1

	moveq	#0,d0
	lea	BlkAbve(pc),a2
	move.w	BlkWdth(pc),d7
	subq.w	#1,d7
.2	moveq	#0,d6
	move.b	(a3),d6
	move.b	(a2,d6),d6
	move.b	d6,(a3)+
	moveq	#0,d1
	move.w	d5,d1
	lsl.w	#2,d1
	lea	Screen1(pc),a0
	mulu	#5*4*(32/8),d6
	lea	BlckDat(pc),a1
	lea	(a1,d6),a1
	bsr	BlitObj
	addq.w	#4,d0
	dbf	d7,.2

	move.w	d5,d1
	addq.w	#1,d1
	cmp.w	BlkHght(pc),d1
	beq	.4
	moveq	#0,d0
	lea	BlkBlow(pc),a2
	move.w	BlkWdth(pc),d7
	subq.w	#1,d7
.3	moveq	#0,d6
	move.b	(a4),d6
	move.b	(a2,d6),d6
	move.b	d6,(a4)+
	moveq	#0,d1
	move.w	d5,d1
	addq.w	#1,d1
	lsl.w	#2,d1
	lea	Screen1(pc),a0
	mulu	#5*4*(32/8),d6
	lea	BlckDat(pc),a1
	lea	(a1,d6),a1
	bsr	BlitObj
	addq.w	#4,d0
	dbf	d7,.3

.4	rts

;--------------------------------------;

*  You must seed the random function first. It would be best to seed it
*  with the current time, as returned by intuition CurrentTime.
*
*  To generate the number place the limit in d0 and call Random. You are
*  returned a value in the range from 0 to limit-1.
*

;=========================
; RandomSeed(seed)
;             d0
;=========================
RandomSeed:
	ADD.L	D0,D1		;   user seed in d0 (d1 too)
	MOVEM.L	D0/D1,RND
; drops through to the main random function (not user callable)
LongRnd:
	MOVEM.L	D2-D3,-(SP)
	MOVEM.L	RND,D0/D1	;   D0=LSB's, D1=MSB's of random number
	ANDI.B	#$0E,D0		;   ensure upper 59 bits are an...
	ORI.B	#$20,D0		;   ...odd binary number
	MOVE.L	D0,D2
	MOVE.L	D1,D3
	ADD.L	D2,D2		;   accounts for 1 of 17 left shifts
	ADDX.L	D3,D3		;   [D2/D3] = RND*2
	ADD.L	D2,D0
	ADDX.L	D3,D1		;   [D0/D1] = RND*3
	SWAP	D3		;   shift [D2/D3] additional 16 times
	SWAP	D2
	MOVE.W	D2,D3
	CLR.W	D2
	ADD.L	D2,D0		;   add to [D0/D1]
	ADDX.L	D3,D1
	MOVEM.L	D0/D1,RND	;   save for next time through
	MOVE.L	D1,D0		;   most random part to D0
	MOVEM.L	(SP)+,D2-D3
	RTS

;=========================
;Random(limit)
;         d0
;=========================
Random:	MOVE.W	D2,-(SP)
	MOVE.W	D0,D2		;   save upper limit
	BEQ.S	RNG0		;   range of 0 returns 0 always
	BSR.S	LongRnd		;   get a longword random number
	CLR.W	D0		;   use upper word (it's most random)
	SWAP	D0
	DIVU.W	D2,D0		;   divide by range...
	CLR.W	D0		;   ...and use remainder for the value
	SWAP	D0		;   result in D0.W
RNG0	MOVE.W	(SP)+,D2
	RTS

RND	DC.L	0,0

;--------------------------------------;

DspScre	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	#Details,$54(a5)
	move.w	#2*14<<6+(640/16),$58(a5)

	moveq	#0,d7
	move.w	BlkWdth(pc),d7
	lsr.w	#1,d7
	moveq	#0,d2
	move.w	22(a6),d2
	divu	#10000,d2
	bsr	InsChar
	addq.w	#2,d7
	clr.w	d2
	swap	d2
	divu	#1000,d2
	bsr	InsChar
	addq.w	#2,d7
	clr.w	d2
	swap	d2
	divu	#100,d2
	bsr	InsChar
	addq.w	#2,d7
	clr.w	d2
	swap	d2
	divu	#10,d2
	bsr	InsChar
	addq.w	#2,d7
	clr.w	d2
	swap	d2
	bsr	InsChar
	rts

;-------------------;

InsChar	lea	ScorFnt(pc),a0
	moveq	#0,d0
	move.w	d2,d0
	move.w	d0,d1
	lsl.w	#6,d0
	lsl.w	#3,d1
	sub.w	d1,d0
	lea	(a0,d0),a0

	lea	Details(pc),a1
	lea	(a1,d7),a1

	WaitBlt
	move.l	#$09f00000,$40(a5)	;BLTCON0
	move.l	#$ffffffff,$44(a5)	;Mask
	move.l	#$0000004e,$64(a5)	;Modulos
	move.l	a0,$50(a5)		;BLTADAT
	move.l	a1,$54(a5)		;BLTDDAT
	move.w	#2*14<<6+(16/16),$58(a5)
	rts

;--------------------------------------;
;a0-Data

PlaySnd	btst	#15,Priorty
	bne	.0
	tst.w	Priorty
	bne	.1
.0	bclr	#15,Priorty
	move.w	#$0001,$96(a5)
	move.w	(a0)+,$a4(a5)		;Length/2
	move.w	(a0)+,$a6(a5)		;Speed
	move.l	#0,(a0)
	move.l	a0,$a0(a5)		;Address
	move.w	#64,$a8(a5)		;Volume
.1	rts

SubPrio	tst.w	Priorty
	beq	.1
	subq.w	#1,Priorty
.1	rts

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0
Option	dc.w	0
BlkWdth	dc.w	BWidth
BlkHght	dc.w	BHeight
ScreLst	dc.b	0,10,40,70,100
	even
SndList	dc.l	Single,Double,Triple,Quad
PriList	dc.w	(1<<15)+30,(1<<15)+15,(1<<15)+60,(1<<15)+60
Priorty	dc.w	0

Player1	dc.w	0		;0	Number
	dc.w	0		;2	Rotation
	dc.w	0		;4	X
	dc.w	0		;6	Y
	dc.b	0		;8	Movement Delay
	dc.b	0		;9	Button (Debouncing)
	dc.w	0		;10	Store Number
	dc.w	0		;12	Store Rotation
	dc.w	0		;14	Store X
	dc.w	0		;16	Store Y
	dc.b	0		;18	Vertical TimeOut
	dc.b	0		;19	Speed
	dc.w	0		;20	Pointer (Random List)
	dc.w	0		;22	Player Score
	dc.b	1		;24	Speed Minimum
	even
	dc.w	0		;26	BorderX

JyStat1	dc.b	%00000
JyStat2	dc.b	%00000
;		 |||||
;		 ||||0 Fire
;		 |||1  Down
;		 ||2   Up
;		 |3    Right
;		 4     Left

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$38c1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$003f
	dc.w	$0108,$0028,$010a,$0028

	dc.w	$0180,$0000,$0182,$0555
	dc.w	$0184,$0aaa,$0186,$0fff

	dc.w	$2c07,$fffe,$0100,$2200
BPLTitl	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$3b07,$fffe,$0100,$0200

	dc.w	$0180,$0000,$0182,$055a
	dc.w	$0184,$0aaf,$0186,$0fff

	dc.w	$5007,$fffe,$0100,$2200
	dc.w	$0108,$00a0,$010a,$00a0
BPLText	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000

	dc.w	$5e07,$fffe,$0182,$055a
	dc.w	$0184,$0aaf,$0186,$0fff

	dc.w	$6507,$fffe,$0182,$055a
	dc.w	$0184,$0aaf,$0186,$0fff

	dc.w	$6c07,$fffe,$0182,$055a
	dc.w	$0184,$0aaf,$0186,$0fff

	dc.w	$7a07,$fffe,$0182,$0a5a
	dc.w	$0184,$0faf,$0186,$0fff

	dc.w	$8007,$fffe,$0100,$0200

	dc.w	$ffff,$fffe

;--------------------------------------;

GCList	dc.w	$008e,$2c81,$0090,$38c1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$003f
	dc.w	$0108,$00a0,$010a,$00a0

	dc.w	$0180,$0000,$0182,$0f8f,$0184,$0d6d,$0186,$0b4b
	dc.w	$0188,$0f80,$018a,$0d60,$018c,$0b40,$018e,$0f44
	dc.w	$0190,$0d22,$0192,$0b00,$0194,$044f,$0196,$022d
	dc.w	$0198,$000b,$019a,$0aaf,$019c,$088d,$019e,$066b
	dc.w	$01a0,$0afa,$01a2,$08d8,$01a4,$06b6,$01a6,$0ff4
	dc.w	$01a8,$0dd2,$01aa,$0bb0,$01ac,$0fff,$01ae,$0aaa
	dc.w	$01b0,$0555,$01b2,$0000,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000

	dc.w	$2c07,$fffe,$0100,$5200
BPL0	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$00f0,$0000,$00f2,$0000

	dc.w	$3007,$fffe,$0100,$5200
BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$00f0,$0000,$00f2,$0000

	dc.w	$ffe1,$fffe
	dc.w	$0407,$fffe,$0100,$0200
	dc.w	$0108,$ff10,$010a,$ff10

	dc.w	$0180,$0002,$0182,$0f8f,$0184,$0d6d,$0186,$0b4b
	dc.w	$0188,$0f80,$018a,$0d60,$018c,$0b40,$018e,$0f44
	dc.w	$0190,$0d22,$0192,$0b00,$0194,$044f,$0196,$022d
	dc.w	$0198,$000b,$019a,$0aaf,$019c,$088d,$019e,$066b
	dc.w	$01a0,$0afa,$01a2,$08d8,$01a4,$06b6,$01a6,$0ff4
	dc.w	$01a8,$0dd2,$01aa,$0bb0,$01ac,$0fff,$01ae,$0aaa
	dc.w	$01b0,$0555,$01b2,$055a,$01b4,$0aaf,$01b6,$0fff
	dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000

BPL2	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$00f0,$0000,$00f2,$0000
	dc.w	$0607,$fffe,$0100,$5200
	
	dc.w	$1f07,$fffe,$0100,$0200
	dc.w	$0108,$0050,$010a,$0050
	dc.w	$0092,$003c,$0094,$00d4
	dc.w	$0180,$0002,$0182,$0fff
	dc.w	$0184,$0aaa,$0186,$0555

BPL3	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$2007,$fffe,$0100,$a200
	dc.w	$2e07,$fffe,$0100,$0200
	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

ShpPtrn
Purple	dc.b	00,01,11,06,00,08,00,00,00,00,00,00,00,00,00,00
	dc.b	00,02,00,00,00,10,00,00,00,07,06,00,00,00,00,00
	dc.b	00,00,00,02,00,04,11,09,00,00,00,00,00,00,00,00
	dc.b	00,04,03,00,00,00,10,00,00,00,08,00,00,00,00,00
Brown	dc.b	00,15,23,17,00,00,19,00,00,00,00,00,00,00,00,00
	dc.b	00,13,00,00,00,24,17,00,00,19,00,00,00,00,00,00
	dc.b	00,00,13,00,00,15,25,17,00,00,00,00,00,00,00,00
	dc.b	00,00,13,00,00,15,26,00,00,00,19,00,00,00,00,00
Red	dc.b	30,37,37,32,00,00,00,00,00,00,00,00,00,00,00,00
	dc.b	00,28,00,00,00,36,00,00,00,36,00,00,00,34,00,00
	dc.b	30,37,37,32,00,00,00,00,00,00,00,00,00,00,00,00
	dc.b	00,28,00,00,00,36,00,00,00,36,00,00,00,34,00,00
Blue	dc.b	00,38,40,00,00,44,46,00,00,00,00,00,00,00,00,00
	dc.b	00,38,40,00,00,44,46,00,00,00,00,00,00,00,00,00
	dc.b	00,38,40,00,00,44,46,00,00,00,00,00,00,00,00,00
	dc.b	00,38,40,00,00,44,46,00,00,00,00,00,00,00,00,00
Cyan	dc.b	00,00,50,00,00,49,57,00,00,56,00,00,00,00,00,00
	dc.b	00,52,51,00,00,00,55,54,00,00,00,00,00,00,00,00
	dc.b	00,00,50,00,00,49,57,00,00,56,00,00,00,00,00,00
	dc.b	00,52,51,00,00,00,55,54,00,00,00,00,00,00,00,00
Green	dc.b	00,61,00,00,00,66,62,00,00,00,67,00,00,00,00,00
	dc.b	00,00,60,65,00,63,68,00,00,00,00,00,00,00,00,00
	dc.b	00,61,00,00,00,66,62,00,00,00,67,00,00,00,00,00
	dc.b	00,00,60,65,00,63,68,00,00,00,00,00,00,00,00,00
Yellow	dc.b	00,74,81,73,00,00,00,78,00,00,00,00,00,00,00,00
	dc.b	00,00,72,00,00,00,80,00,00,74,79,00,00,00,00,00
	dc.b	00,72,00,00,00,77,81,76,00,00,00,00,00,00,00,00
	dc.b	00,71,76,00,00,80,00,00,00,78,00,00,00,00,00,00

;--------------------------------------;

BlkAbve	dc.b	00
	dc.b	04,05,06,04,05,06,07,08,09,08,11
	dc.b	15,16,17,15,16,17,18,19,20,19,22,22,18,25,20
	dc.b	30,31,32,30,31,32,33,34,35,34,37
	dc.b	41,42,43,41,42,43,44,45,46,45,48
	dc.b	52,53,54,52,53,54,55,56,57,56,59
	dc.b	63,64,65,63,64,65,66,67,68,67,70
	dc.b	74,75,76,74,75,76,77,78,79,78,81
	even

BlkBlow	dc.b	00
	dc.b	01,02,03,04,05,06,04,05,06,02,11
	dc.b	12,13,14,15,16,17,15,16,17,13,22,23,12,22,12
	dc.b	27,28,29,30,31,32,30,31,32,28,37
	dc.b	38,39,40,41,42,43,41,42,43,39,48
	dc.b	49,50,51,52,53,54,52,53,54,50,59
	dc.b	60,61,62,63,64,65,63,64,65,61,70
	dc.b	71,72,73,74,75,76,74,75,76,72,81
	even

;--------------------------------------;

CharSet	dc.b	"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ+.- "
	even
;--------------------------------------;

MainTxt	dc.b	"      WRITTEN BY ROBERT VAN GELDER      "
	dc.b	"                                        "
	dc.b	"            BLOCK WIDTH - 30            "
	dc.b	"              PLAYERS - 1               "
	dc.b	"               LEVEL - 1                "
	dc.b	"                                        "
	dc.b	"               PLAY GAME                "

;--------------------------------------;

ScrnDat	dcb.b	80*52,0
ScorFnt	incbin	"DH1:Tetris/Font.raw"
MainFnt	incbin	"DH1:Tetris/Write.raw"
BlckDat	incbin	"DH1:Tetris/Block.raw"
BlckBdr	incbin	"DH1:Tetris/Border.raw"
BlckMsk	incbin	"DH1:Tetris/Mask.raw"
RndArea	dcb.b	Objects,0

Details	dcb.b	2*14*(640/8),0
TopScrn	dcb.b	5*4*(320/8),0
Screen1	dcb.b	5*212*(320/8),0

Title	incbin	"DH1:Tetris/Minitris.raw"
TxtArea	dcb.b	5*80*(320/8),0

Collide	dc.w	3482/2,50
	incbin	"DH1:Tetris/Collide.snd"
Rotate	dc.w	1788/2,300
	incbin	"DH1:Tetris/Rotate.snd"
Single	dc.w	4752/2,285
	incbin	"DH1:Tetris/Single.snd"
Double	dc.w	3302/2,285
	incbin	"DH1:Tetris/Double.snd"
Triple	dc.w	7484/2,570
	incbin	"DH1:Tetris/Triple.snd"
Quad	dc.w	7664/2,570
	incbin	"DH1:Tetris/Quad.snd"
END

