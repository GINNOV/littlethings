
;	DO SOMETHING ABOUT -2 STEP IN FINDVAL ROUTINE!!!

	SECTION	"Frantic - Picture Peeker",CODE_C
	include	"DH1:PicPeeker/Macros.i"
;	include	"DH1:PicPeeker/PicPeek.i"

;	move.l	4.w,a6
;	move.l	62(a6),TopChip
;	bra	FindPic
	bra.b	Start
	dc.b	"$VER: Picture Peeker 1.0 Nov 1994 - Frantic",0

Start	move.l	4.w,a6
	moveq	#0,d0
	lea	GfxBase(pc),a1
	jsr	OpenLibrary(a6)
	move.l	d0,GfxBase
	moveq	#0,d0
	lea	IntBase(pc),a1
	jsr	OpenLibrary(a6)
	move.l	d0,IntBase
	moveq	#0,d0
	lea	DosBase(pc),a1
	jsr	OpenLibrary(a6)
	move.l	d0,DosBase

	move.l	#Pointer,d0
	lea	SPR1(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.l	#NullSpr,d0
	lea	SPR2(pc),a0
	moveq	#7-1,d7
.1	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	addq.l	#8,a0
	dbf	d7,.1

	move.l	#Picture,d0
	lea	BPL2(pc),a0
	moveq	#2-1,d7
.2	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#(640/8),d0
	addq.l	#8,a0
	dbf	d7,.2

	lea	Modulo(pc),a2
	moveq	#4,d1
	bsr.w	PrtText
	lea	PicWdth(pc),a2
	moveq	#11,d1
	bsr.w	PrtText
	lea	PicHght(pc),a2
	moveq	#18,d1
	bsr.w	PrtText
	lea	PicDpth(pc),a2
	moveq	#25,d1
	bsr.w	PrtText
	bsr.w	WrtAdrs
	bsr.b	InsDisp

Mouse	bsr.w	Pressed
	tst.l	MouseX
	beq.b	End
	tst.w	MouseY
	beq.w	DragBar
	lea	MoveMsA(pc),a1
	bsr.w	ChckPos
	beq.w	MoveScn
	bra.w	ChkGads

;--------------------------------------;

End	bsr.w	Release
	tst.l	MouseX
	bne.b	Mouse
	bsr.w	RemDisp
	move.l	4.w,a6
	move.l	DosBase(pc),a1
	jsr	CloseLibrary(a6)
	move.l	IntBase(pc),a1
	jsr	CloseLibrary(a6)
	move.l	GfxBase(pc),a1
	jsr	CloseLibrary(a6)
	moveq	#0,d0
	rts

;--------------------------------------;

InsDisp	move.l	GfxBase(pc),a6
	move.l	34(a6),OldView
	sub.l	a1,a1
	jsr	LoadView(a6)
	jsr	WaitTOF(a6)
	jsr	WaitTOF(a6)
	jsr	OwnBlitter(a6)
	lea	$dff000,a5
	move.w	$a(a5),OldMous
	WaitBlt
	move.l	4.w,a6
	jsr	Forbid(a6)
	move.l	62(a6),TopChip

	move.w	2(a5),d0
	or.w	#$8000,d0
	move.w	d0,DMACon

	move.w	$7c(a5),d0
	cmp.b	#$f8,d0
	bne.b	.NonAGA
	move.w	#0,$106(a5)
	move.w	#0,$1fc(a5)

.NonAGA	move.w	#$7ff0,$96(a5)
	move.l  #CList,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$83e0,$96(a5)
	rts

;-------------------;

RemDisp	lea	$dff000,a5
	WaitBlt
	move.l	GfxBase(pc),a6
	move.l	OldView(pc),a1
	jsr	LoadView(a6)
	move.w	#$7ff0,$96(a5)
	move.l	38(a6),$80(a5)
	move.w	#$0000,$88(a5)
	move.w	DMACon(pc),$96(a5)
	jsr	DisownBlitter(a6)
	move.l	4.w,a6
	jsr	Permit(a6)
	rts

;--------------------------------------;

Pressed	bsr.b	MousPos
	bsr.w	PtMsSpr
	bsr.w	ChkBrdr
	btst	#6,$bfe001
	bne.b	Pressed
	WaitBm
	rts

;-------------------;

Release	bsr.b	MousPos
	bsr.b	PtMsSpr
	bsr.w	ChkBrdr
	btst	#6,$bfe001
	beq.b	Release
	WaitBm
	rts

;--------------------------------------;

MousPos	movem.l	d0-d3/a0,-(a7)
	move.w	$a(a5),d0
	lea	MouseX(pc),a0
	move.w	d0,d1
	move.w	OldMous(pc),d2
	move.w	d2,d3
	move.w	d0,OldMous
	and.w	#$ff,d0
	lsr.w	#8,d1
	and.w	#$ff,d2
	lsr.w	#8,d3
	sub.b	d2,d0
	ext.w	d0
	add.w	d0,(a0)
	sub.w	d3,d1
	ext.w	d1
	add.w	d1,2(a0)
	movem.l	(a7)+,d0-d3/a0
	rts

;--------------------------------------;

PtMsSpr	movem.l	d0/a0,-(a7)
	lea	Pointer(pc),a0
	move.w	MouseX(pc),d0
	lsr.w	#1,d0
	add.w	#128,d0
	lsr.w	#1,d0
	bcc.b	.1
	bset	#0,3(a0)
	bra.b	.2
.1	bclr	#0,3(a0)
.2	move.b	d0,1(a0)

	move.w	MouseY(pc),d0
	add.w	MenuBar(pc),d0
	add.w	#46,d0
	move.b	d0,(a0)
	btst	#8,d0
	beq.b	.3
	bset	#2,3(a0)
	bra.b	.4
.3	bclr	#2,3(a0)
.4	add.w	#15,d0
	move.b	d0,2(a0)
	btst	#8,d0
	beq.b	.5
	bset	#1,3(a0)
	bra.b	.6
.5	bclr	#1,3(a0)
.6	movem.l	(a7)+,d0/a0
	rts

;--------------------------------------;

ChkBrdr	movem.l	d0-d3/a0-a1,-(a7)
	lea	MouseX(pc),a0
	lea	Borders(pc),a1
	movem.w	(a1)+,d0-d3
	cmp.w	(a0),d0
	ble.b	.1
	move.w	d0,(a0)
.1	cmp.w	(a0),d2
	bge.b	.2
	move.w	d2,(a0)
.2	cmp.w	2(a0),d1
	ble.b	.3
	move.w	d1,2(a0)
.3	cmp.w	2(a0),d3
	bge.b	.4
	move.w	d3,2(a0)
.4	movem.l	(a7)+,d0-d3/a0-a1
	rts

;--------------------------------------;

DragBar	btst	#6,$bfe001
	bne.b	.1
	move.w	$a(a5),d0
	lea	MenuBar(pc),a1
	move.w	OldMous(pc),d2
	move.w	d0,OldMous
	lsr.w	#8,d0
	lsr.w	#8,d2
	sub.w	d2,d0
	ext.w	d0
	add.w	(a1),d0
	move.w	d0,(a1)
	bsr.w	ChkVals
	bsr.w	PtMsSpr
	bsr.b	MoveBPL
	bra.b	DragBar
.1	move.w	MenuBar(pc),OffsetY
	bra.w	Mouse

;--------------------------------------;

MoveBPL	WaitBm
MveMenu	movem.l	d0-d1/d7-a0,-(a7)
	moveq	#0,d7
	move.w	MenuBar(pc),d0
	lea	PAL1(pc),a0
	add.w	#44,d0
	bsr.b	.1
	lea	PAL2(pc),a0
	addq.w	#1,d0
	bsr.b	.1
	lea	PAL3(pc),a0
	add.w	#34,d0
	bsr.b	.1
	movem.l	(a7)+,d0-d1/d7-a0
	rts

.1	btst	#8,d0
	beq.b	.2
	tst.b	d7
	bmi.b	.2
	moveq	#-1,d7
	move.w	#$ffe1,(a0)
	move.w	d0,d1
	lsl.w	#8,d1
	move.b	#7,d1
	move.w	d1,4(a0)
	rts
.2	move.w	d0,d1
	lsl.w	#8,d1
	move.b	#1,d1
	move.w	d1,(a0)
	move.b	#7,d1
	move.w	d1,4(a0)
	rts

;--------------------------------------;

MoveScn	btst	#6,$bfe001
	bne.w	.6
	move.w	#$68b,SPRCols+6
	move.w	$a(a5),d0
	cmp.w	OldMous(pc),d0
	beq.b	MoveScn
	move.w	d0,d1
	move.w	OldMous(pc),d2
	move.w	d2,d3
	move.w	d0,OldMous
	and.w	#$ff,d0
	lsr.w	#8,d1
	and.w	#$ff,d2
	lsr.w	#8,d3
	sub.b	d2,d0
	ext.w	d0
	ext.l	d0
	sub.w	d3,d1
	ext.w	d1
	ext.l	d1
	asl.l	#1,d0
	move.w	PicWdth(pc),d2
	add.w	Modulo(pc),d2
	muls	d2,d1
	neg.l	d0
	neg.l	d1

	lea	PicSlct(pc),a0
	lea	PicAdrs(pc),a1
	moveq	#0,d2
	moveq	#0,d3
.1	btst	d2,(a0)
	beq.b	.5
	move.l	(a1,d3),d4
	btst	#2,$dff016
	beq.b	.2
	add.l	d0,d4
.2	add.l	d1,d4
	tst.l	d4
	bmi.b	.3
	cmp.l	TopChip(pc),d4
	blt.b	.4
	sub.l	TopChip(pc),d4
	bra.b	.4
.3	add.l	TopChip(pc),d4
.4	move.l	d4,(a1,d3)
.5	addq.w	#1,d2
	addq.w	#4,d3
	cmp.w	#8,d2
	bne.b	.1
	bsr.b	InstBPL
	bsr.b	WrtAdrs
	bra.w	MoveScn
.6	move.w	#$fff,SPRCols+6
	bra.w	Mouse

WrtAdrs	lea	PicAdrs(pc),a0
	move.l	#4,d0
	moveq	#4,d1
	moveq	#2,d2
	moveq	#2-1,d6
.1	moveq	#4-1,d7
.2	move.l	(a0)+,d3
	bsr.w	Hex2Asc
	bsr.w	PutText
	addq.w	#7,d1
	dbf	d7,.2
	add.w	#161,d0
	moveq	#4,d1
	dbf	d6,.1
	rts

;--------------------------------------;

ChckPos	movem.l	d0-d3/a0-a1,-(a7)
	lea	MouseX(pc),a0
	moveq	#0,d7
	movem.w	(a1)+,d0-d3
	cmp.w	(a0),d0
	ble.b	.1
	moveq	#-1,d7
.1	cmp.w	(a0),d2
	bge.b	.2
	moveq	#-1,d7
.2	cmp.w	2(a0),d1
	ble.b	.3
	moveq	#-1,d7
.3	cmp.w	2(a0),d3
	bge.b	.4
	moveq	#-1,d7
.4	movem.l	(a7)+,d0-d3/a0-a1
	tst.b	d7
	rts

;--------------------------------------;

InstBPL	movem.l	d0/d7-a1,-(a7)
	lea	PicAdrs(pc),a0
	lea	BPL1(pc),a1
	moveq	#8-1,d7
.1	move.l	(a0)+,d0
	add.l	BPlnOff(pc),d0
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	addq.l	#8,a1
	dbf	d7,.1
	movem.l	(a7)+,d0/d7-a1
	rts

;--------------------------------------;

PrtText	moveq	#0,d0
	move.w	(a2),d0
	bsr.w	Dec2Asc
	lea	TextBuf(pc),a1
	tst.w	(a2)
	bne.b	.1
	move.l	#"   0",(a1)
	bra.b	.3
.1	addq.l	#1,a1
.2	cmp.b	#"0",(a1)
	bne.b	.3
	move.b	#" ",(a1)+
	bra.b	.2
.3	move.w	#297,d0
	moveq	#1,d2
	bsr.b	PutText
	rts

;--------------------------------------;

PutText	movem.l	d0-a4,-(a7)
	lea	TextBuf(pc),a0
	lea	Font(pc),a1
	lea	Picture(pc),a2

.1	moveq	#0,d7
	move.b	(a0)+,d7
	beq.b	.6
	sub.b	#48,d7
	cmp.b	#17,d7
	blt.b	.2
	subq.b	#7,d7
.2	mulu	#5,d7
	lea	(a1,d7),a3

	move.w	d1,d3
	mulu	#2*(640/8),d3
	lea	(a2,d3),a4

	move.w	d0,d3
	lsr.w	#3,d3
	bclr	#0,d3
	lea	(a4,d3),a4
	move.w	d0,d4
	and.w	#$f,d4

	moveq	#5-1,d5
.3	moveq	#0,d7
	move.l	#$00ffffff,d6
	move.b	(a3)+,d7
	ror.l	#8,d7
	ror.l	d4,d7
	ror.l	d4,d6

	and.l	d6,(a4)
	btst	#0,d2
	beq.b	.4
	or.l	d7,(a4)
.4	and.l	d6,(640/8)(a4)
	btst	#1,d2
	beq.b	.5
	or.l	d7,(640/8)(a4)
.5	lea	2*(640/8)(a4),a4
	dbf	d5,.3
	addq.w	#8,d0
	bra.b	.1
.6	movem.l	(a7)+,d0-a4
	rts

;--------------------------------------;

Hex2Asc	movem.l	d1-d2/a0,-(a7)
	lea	TextBuf(pc),a0
	moveq	#8-1,d2
.1	rol.l	#4,d3
	move.b	d3,d1
	and.b	#$f,d1
	add.b	#$30,d1
	cmp.b	#$3a,d1
	bcs.b	.2
	addq.w	#7,d1
.2	move.b	d1,(a0)+
	dbf	d2,.1
	clr.b	(a0)
	movem.l	(a7)+,d1-d2/a0
	rts

;--------------------------------------;

Dec2Asc	movem.l	d0/a0,-(a7)
	lea	TextBuf(pc),a0
	move.b	#" ",(a0)+
	tst.w	d0
	bpl.b	.1
	move.b	#"G",-1(a0)
	neg.w	d0
.1	divu	#100,d0
	bsr.b	.2
	divu	#10,d0
	bsr.b	.2
	bsr.b	.2
	clr.b	(a0)
	movem.l	(a7)+,d0/a0
	rts
.2	add.b	#48,d0
	move.b	d0,(a0)+
	clr.w	d0
	swap	d0
	rts

;--------------------------------------;

EOrArea	movem.l	d0-d6/a0-a1,-(a7)
	lea	6(a0),a1
	movem.w	(a1)+,d0-d3
	sub.w	d0,d2
	addq.w	#1,d2
	sub.w	d1,d3

.1	movem.l	d0-d3,-(a7)
	lea	Picture+2*(640/8)(pc),a0
	move.l	d1,d4
	mulu	#2*(640/8),d4
	lea	(a0,d4),a1

	move.w	d0,d4
	lsr.w	#3,d4
	bclr	#0,d4
	lea	(a1,d4),a1
	move.w	d0,d4
	and.w	#$f,d4

.2	moveq	#16,d5
	sub.w	d2,d5
	bmi.b	.3
	beq.b	.3
	bra.b	.4
.3	moveq	#0,d5
.4	moveq	#-1,d6
	lsr.w	d4,d6
	subq.w	#1,d5
	bmi.b	.6
.5	bclr	d5,d6
	dbf	d5,.5
.6	eor.w	d6,(a1)
	eor.w	d6,(640/8)(a1)
	addq.l	#2,a1
	add.w	d4,d2
	moveq	#0,d4
	sub.w	#16,d2
	bmi.b	.7
	beq.b	.7
	bra.b	.2
.7	movem.l	(a7)+,d0-d3
	addq.w	#1,d1
	dbf	d3,.1
	movem.l	(a7)+,d0-d6/a0-a1
	bchg	#0,5(a0)
	rts

;--------------------------------------;

ChkGads	lea	GadList(pc),a0
.1	cmp.l	#-1,(a0)
	beq.b	.3
	lea	6(a0),a1
	bsr.w	ChckPos
	beq.b	.2
	lea	14(a0),a0
	bra.b	.1
.2	bsr.w	EOrArea
	move.l	(a0),a1
	jsr	(a1)
.3	bsr.w	Release
	bra.w	Mouse

;--------------------------------------;

ChkVals	move.w	(a1),d0
	cmp.w	2(a1),d0
	bge.b	.1
	move.w	2(a1),d0
.1	cmp.w	4(a1),d0
	ble.b	.2
	move.w	4(a1),d0
.2	move.w	d0,(a1)
	rts

;--------------------------------------;

BPL1Tgl	bchg	#0,PicSlct
	bra.b	BPLTgle
BPL2Tgl	bchg	#1,PicSlct
	bra.b	BPLTgle
BPL3Tgl	bchg	#2,PicSlct
	bra.b	BPLTgle
BPL4Tgl	bchg	#3,PicSlct
	bra.b	BPLTgle
BPL5Tgl	bchg	#4,PicSlct
	bra.b	BPLTgle
BPL6Tgl	bchg	#5,PicSlct
	bra.b	BPLTgle
BPL7Tgl	bchg	#6,PicSlct
	bra.b	BPLTgle
BPL8Tgl	bchg	#7,PicSlct
BPLTgle	bchg	#0,5(a0)
	bsr.w	Release
	rts

;--------------------------------------;

InsSwch	lea	GadList(pc),a0
	moveq	#0,d6
	moveq	#8-1,d7
.1	btst	d6,PicSlct
	bne.b	.2
	btst	#0,5(a0)
	beq.b	.3
	bsr.w	EorArea
	bchg	#0,5(a0)	
.2	btst	#0,5(a0)
	bne.b	.3
	bsr.w	EorArea
	bchg	#0,5(a0)
.3	addq.b	#1,d6
	lea	14(a0),a0
	dbf	d7,.1
	rts

;--------------------------------------;

ModuloU	moveq	#2,d6
	bra.b	ModuloX
ModuloD	moveq	#-2,d6
ModuloX	moveq	#25-1,d7
.1	lea	Modulo(pc),a1
	add.w	d6,(a1)
	bsr.w	ChkVals
	bsr.b	InstMod
	lea	Modulo(pc),a2
	moveq	#4,d1
	bsr.w	PrtText
.2	bsr.w	MousPos
	bsr.w	PtMsSpr
	bsr.w	ChkBrdr
	btst	#6,$bfe001
	bne.b	.3
	WaitBm
	tst.w	d7
	dbmi	d7,.2
	lea	6(a0),a1
	bsr.w	ChckPos
	beq.b	.1
	bra.b	.2
.3	bsr.w	EOrArea
	rts

;-------------------;

InstMod	lea	Modulos(pc),a1
	move.w	Modulo(pc),d0
	add.w	MdloOff(pc),d0
	move.w	d0,2(a1)
	move.w	d0,6(a1)
	rts

;--------------------------------------;

PcWdthU	moveq	#2,d6
	bra.b	PcWdthX
PcWdthD	moveq	#-2,d6
PcWdthX	moveq	#25-1,d7
.1	lea	PicWdth(pc),a1
	add.w	d6,(a1)
	bsr.w	ChkVals
	bsr.b	InsWdth
	lea	PicWdth(pc),a2
	moveq	#11,d1
	bsr.w	PrtText
.2	bsr.w	MousPos
	bsr.w	PtMsSpr
	bsr.w	ChkBrdr
	btst	#6,$bfe001
	bne.b	.3
	WaitBm
	tst.w	d7
	dbmi	d7,.2
	lea	6(a0),a1
	bsr.w	ChckPos
	beq.b	.1
	bra.b	.2
.3	bsr.w	EOrArea
	rts

;-------------------;

InsWdth	move.w	(a1),d0
	cmp.w	#2,d0
	beq.b	.1
	cmp.w	#42,d0
	bgt.b	.2

	move.w	#0,MdloOff
	move.l	#0,BPlnOff
	move.b	#$f1,Window+7
	lsl.w	#2,d0
	add.w	#$38-8,d0
	move.w	d0,Window+14
	bsr.w	InstMod
	bsr.w	InstBPL
	rts
.1	move.w	#-8,MdloOff
	move.l	#-8,BPlnOff
	move.b	#$81,Window+7
	move.w	#$0038,Window+14
	bsr.w	InstMod
	bsr.w	InstBPL
	rts
.2	move.b	#$f1,Window+7
	move.w	#$00d4,Window+14
	sub.w	#42,d0
	move.w	d0,MdloOff
	move.l	#0,BPlnOff
	bsr.w	InstMod
	bsr.w	InstBPL
	rts

;--------------------------------------;

PcHghtU	moveq	#1,d6
	bra.b	PcHghtX
PcHghtD	moveq	#-1,d6
PcHghtX	moveq	#25-1,d7
.1	lea	PicHght(pc),a1
	move.w	MenuBar(pc),d0
	cmp.w	(a1),d0
	bne.b	.2
	tst.w	d6
	bmi.b	.2
	addq.w	#1,MenuBar
.2	add.w	d6,(a1)
	move.w	(a1),MenuBar+4
	bsr.w	ChkVals
	lea	PicHght(pc),a2
	moveq	#18,d1
	bsr.w	PrtText
	bsr.b	InsHght
.3	bsr.w	MousPos
	bsr.w	PtMsSpr
	bsr.w	ChkBrdr
	btst	#6,$bfe001
	bne.b	.4
	WaitBm
	tst.w	d7
	dbmi	d7,.3
	lea	6(a0),a1
	bsr.w	ChckPos
	beq.b	.1
	bra.b	.3
.4	bsr.b	NHghBar
	bsr.w	EOrArea
	rts

;-------------------;

InsHght	lea	MenuBar(pc),a1
	move.w	PicHght(pc),d0
	cmp.w	OffsetY(pc),d0
	ble.b	.1
	move.w	OffsetY(pc),d0
.1	move.w	d0,4(a1)
	bsr.w	ChkVals
	bsr.w	PtMsSpr
	bsr.w	MveMenu
	rts

;-------------------;

NHghBar	lea	MenuBar(pc),a1
	move.w	PicHght(pc),d0
	cmp.w	#256,d0
	ble.b	.1
	move.w	#256,d0
.1	move.w	d0,4(a1)
	rts

;--------------------------------------;

PcDpthU	moveq	#1,d6
	bra.b	PcDpthX
PcDpthD	moveq	#-1,d6
PcDpthX	moveq	#25-1,d7
.1	lea	PicDpth(pc),a1
	add.w	d6,(a1)
	bsr.w	ChkVals
	bsr.b	InsDpth
	move.l	a1,a2
	moveq	#25,d1
	bsr.w	PrtText
.2	bsr.w	MousPos
	bsr.w	PtMsSpr
	bsr.w	ChkBrdr
	btst	#6,$bfe001
	bne.b	.3
	WaitBm
	tst.w	d7
	dbmi	d7,.2
	lea	6(a0),a1
	bsr.w	ChckPos
	beq.b	.1
	bra.b	.2
.3	bsr.w	EOrArea
	rts

;-------------------;

InsDpth	movem.l	d0/d7/a1-a2,-(a7)
	move.w	(a1),d0
	move.w	#$0200,d7
	btst	#3,d0
	beq.b	.1
	or.w	#$0010,d7
.1	and.w	#7,d0
	lsl.w	#8,d0
	lsl.w	#4,d0
	or.w	d7,d0
	lea	Depth(pc),a2
	move.w	d0,2(a2)
	movem.l	(a7)+,d0/d7/a1-a2
	rts

;--------------------------------------;

FindPic	lea	PicAdrs(pc),a4
	movem.l	NullPnt(pc),d0-d7
	movem.l	d0-d7,(a4)
	moveq	#2,d1
	btst	#2,$dff016
	bne.b	.1
	moveq	#-2,d1
.1	move.l	BPLAdrs(pc),a1
	sub.l	a2,a2
	move.l	TopChip(pc),a3
	move.w	#$00e0,d0
.2	bsr.w	FindVal
	beq.w	.9
	cmp.w	#$00e2,4(a1)
	bne.b	.2
	bsr.w	ChckTop
	bne.b	.2
	move.l	a1,BPLAdrs

	move.l	a1,a2
	move.l	a1,a3
	add.l	#1024,a3
	moveq	#2,d1

	moveq	#0,d6
	move.b	d6,PicSlct
	moveq	#7-1,d7
.3	bset	d6,PicSlct
	addq.b	#1,d6
	move.w	2(a1),d2
	swap	d2
	move.w	6(a1),d2
	move.l	d2,(a4)+
	move.l	a2,a1
	addq.w	#4,d0
	bsr.w	FindVal
	beq.b	.4
	dbf	d7,.3
	bset	d6,PicSlct
	move.w	2(a1),d2
	swap	d2
	move.w	6(a1),d2
	move.l	d2,(a4)+

.4	move.w	a2,a3
	sub.l	#1024,a2
	move.l	a2,a1
	add.l	#1024,a3
	move.w	#$0100,d0
.44	bsr.w	FindVal
	beq.b	.8
	moveq	#0,d2
	move.w	2(a1),d2
	and.w	#$10,d2
	lsr.w	#1,d2
	bne.b	.45
	move.w	2(a1),d2
	lsr.w	#8,d2
	lsr.w	#4,d2
	and.w	#7,d2
.45	move.w	d2,PicDpth
	beq.b	.44

	move.w	#$0092,d0
.5	bsr.b	FindVal
	beq.b	.7
	cmp.w	#$0094,4(a1)
	bne.b	.5
	move.w	2(a1),d2
	move.w	6(a1),d3
	sub.w	d2,d3
	addq.w	#8,d3
	lsr.w	#2,d3
	lea	PicWdth(pc),a1
	move.w	d3,(a1)
	bsr.w	ChkVals

	lea	PicDpth(pc),a1
	bsr.w	InsDpth
	move.l	a1,a2
	moveq	#25,d1
	bsr.w	PrtText

.7	lea	PicWdth(pc),a1
	bsr.w	InsWdth
	lea	PicWdth(pc),a2
	moveq	#11,d1
	bsr.w	PrtText
.8	bsr.w	InsSwch
	bsr.w	WrtAdrs

.9	rts

;
;	move.w	#$00e0,d1
;	move.l	BPLAdrs(pc),a0
;	bsr	FindCop
;	move.l	a0,BPLAdrs
;	beq	.4
;	move.l	d2,(a1)+
;	bset	#0,d6
;	move.l	a0,d3
;	add.l	#1024,d3
;	moveq	#7-1,d7
;.2	addq.w	#4,d1
;	move.l	BPLAdrs(pc),a0
;	bsr	FindCop
;	ror.b	#1,d6
;	move.l	d2,(a1)+
;	beq	.3
;	bset	#0,d6
;.3	dbf	d7,.2
;	ror.b	#1,d6
;	move.b	d6,PicSlct
;	move.w	#$0108,d1
;	move.l	BPLAdrs(pc),a0
;	sub.l	#1024,a0
;	bsr	FindCop
;	move.w	d2,Modulo
;
;	move.l	BPLAdrs(pc),a0
;	sub.l	#1024,a0
;	move.w	#$0100,d1
;.t1	add.l	d0,a0
;	cmp.l	#-2,a0
;	beq	.t3
;	cmp.l	d3,a0
;	beq	.t3
;.t2	move.w	(a0),d2
;	cmp.w	d1,d2
;	bne	.t1
;	and.w	#$7010,d2
;	beq	.t1
;	moveq	#0,d1
;	btst	#4,d2
;	beq	.t4
;	bset	#3,d1
;	bra	.t5
;.t4	lsl.w	#8,d2
;	lsl.w	#4,d2
;	or.b	d2,d1
;.t5	move.b	d1,PicDpth
;.t3
;	bsr	InstMod
;	lea	Modulo(pc),a2
;	moveq	#4,d1
;	bsr.w	PrtText
;	bsr	InsSwch
;.4	rts

;--------------------------------------;

ChckTop	move.w	2(a1),d2
	swap	d2
	move.w	6(a1),d2
	cmp.l	TopChip(pc),d2
	bgt.b	.1
	moveq	#0,d2
.1	tst.l	d2
	rts

;--------------------------------------;

FindVal	movem.l	d1-d2/a2-a3,-(a7)
.1	add.l	d1,a1
	cmp.l	a1,a2
	beq.b	.3
	cmp.l	a1,a3
	beq.b	.3
	move.w	(a1),d2
	cmp.w	d0,d2
	bne.b	.1
.2	movem.l	(a7)+,d1-d2/a2-a3
	tst.w	d0
	rts
.3	moveq	#0,d0
	bra.b	.2

;--------------------------------------;

FindCol	rts

;--------------------------------------;

SavePic	bsr.w	Release
	bsr.w	EOrArea
	lea	6(a0),a1
	bsr.w	ChckPos
	beq.b	.1
	rts
.1	bsr.w	RemDisp
	clr.b	FleName
	bsr.b	OpenWin
	bra.b	WaitEvt
SaveMem	bsr.w	PicExst
	bne.b	Error
	bsr.w	OpenFle
	beq.b	Error
	bsr.w	ClcStrc
	bsr.w	WrteFle
	bsr.w	ClseFle

NoSave	bsr.b	ClseWin
	bsr.w	InsDisp
	rts
Error	move.l	IntBase(pc),a6
	move.l	WinHD(pc),a0
	lea	WnError(pc),a1
	sub.l	a2,a2
	jsr	SetWindowTitles(a6)
	moveq	#100,d1
	bsr.b	DosWait
	bra.b	NoSave

;-------------------;

DosWait	move.l	DosBase(pc),a6
	jsr	Delay(a6)
	rts

;-------------------;

OpenWin	move.l	IntBase(pc),a6
	lea	WinDef1(pc),a0
	jsr	OpenWindow(a6)
	move.l	d0,WinHD
	rts

;-------------------;

ClseWin	move.l	IntBase(pc),a6
	move.l	WinHD(pc),a0
	jsr	CloseWindow(a6)
	rts

;-------------------;

WaitEvt	move.l	4.w,a6
	move.l	WinHD(pc),a0
	move.l	86(a0),a0
	move.l	a0,-(a7)
	jsr	WaitPort(a6)
	move.l	(a7)+,a0
	jsr	GetMsg(a6)
	move.l	d0,a1
	move.l	20(a1),d6
	cmp.l	#$200,d6
	beq.b	NoSave
	cmp.l	#$40,d6
	beq.b	FindGad
	jsr	ReplyMsg(a6)
	bra.b	WaitEvt

FindGad	move.l	28(a1),a0
	move.w	38(a0),d7
	jsr	ReplyMsg(a6)
	cmp.w	#1,d7
	beq.w	SaveMem
	bra.b	WaitEvt

;-------------------;

ClcStrc	lea	IFFStrc(pc),a0
	moveq	#0,d0
	move.w	PicDpth(pc),d0
	mulu	PicWdth(pc),d0
	mulu	PicHght(pc),d0
	move.l	d0,56(a0)
	add.l	#52,d0
	move.l	d0,4(a0)
	move.w	PicDpth(pc),d0
	move.b	d0,28(a0)
	move.w	PicWdth(pc),d0
	lsl.w	#3,d0
	move.w	d0,20(a0)
	move.w	PicHght(pc),22(a0)
	rts

;-------------------;

PicExst	move.l	DosBase(pc),a6
	move.l	#FleName,d1
	moveq	#-2,d2
	jsr	Lock(a6)
	move.l	d0,d1
	beq.b	.1
	jsr	UnLock(a6)
	moveq	#-1,d0
.1	tst.l	d0
	rts

;-------------------;

OpenFle	move.l	DosBase(pc),a6
	move.l	#FleName,d1
	move.l	#1006,d2
	jsr	Open(a6)
	move.l	d0,FleHndl
	rts

ClseFle	move.l	DosBase(pc),a6
	move.l	FleHndl(pc),d1
	jsr	Close(a6)
	rts

;-------------------;

WrteFle	move.l	DosBase(pc),a6
	move.l	FleHndl(pc),d1
	move.l	#IFFStrc,d2
	move.l	#60,d3
	jsr	Write(a6)

	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
.1	lea	PicAdrs(pc),a4
	move.w	PicDpth(pc),d7
	subq.w	#1,d7
.2	move.l	FleHndl(pc),d1
	move.l	(a4)+,d2
	add.l	d5,d2
	move.w	PicWdth(pc),d3
	jsr	Write(a6)
	dbf	d7,.2
	move.w	PicWdth(pc),d4
	add.w	Modulo(pc),d4
	add.l	d4,d5
	addq.w	#1,d6
	cmp.w	PicHght(pc),d6
	bne.b	.1
	rts

;-------------------;

DMACon	dc.w	0
OldView	dc.l	0
WinHD	dc.l	0
FleHndl	dc.l	0
DosBase	dc.b	"dos.library",0
IntBase	dc.b	"intuition.library",0
GfxBase	dc.b	"graphics.library",0
PicSlct	dc.b	0
PicAdrs	dcb.l	8,0
NullPnt	dcb.l	8,0
ColAdrs	dc.l	0
BPLAdrs	dc.l	0
TopChip	dc.l	0
OldMous	dc.w	0
MouseX	dc.w	0
MouseY	dc.w	0
Borders	dc.w	0,0,636,30
NullSpr	dc.l	0
OffsetY	dc.w	200
MenuBar	dc.w	200, 001, 256
Modulo	dc.w	000,-998, 998
MdloOff	dc.w	0
BPlnOff	dc.l	0
PicWdth	dc.w	040, 002, 998
PicHght	dc.w	256, 001, 999
PicDpth	dc.w	001, 001, 008
TextBuf	dcb.b	10,0	
MoveMsA	dc.w	429,2,571,29
GadList	dc.l	BPL1Tgl
	dc.w	0
	dc.w	69,2,115,8
	dc.l	BPL2Tgl
	dc.w	0
	dc.w	69,9,115,15
	dc.l	BPL3Tgl
	dc.w	0
	dc.w	69,16,115,22
	dc.l	BPL4Tgl
	dc.w	0
	dc.w	69,23,115,29
	dc.l	BPL5Tgl
	dc.w	0
	dc.w	116,2,162,8
	dc.l	BPL6Tgl
	dc.w	0
	dc.w	116,9,162,15
	dc.l	BPL7Tgl
	dc.w	0
	dc.w	116,16,162,22
	dc.l	BPL8Tgl
	dc.w	0
	dc.w	116,23,162,29
	dc.l	ModuloU
	dc.w	0
	dc.w	336,2,350,8
	dc.l	ModuloD
	dc.w	0
	dc.w	351,2,366,8
	dc.l	PcWdthU
	dc.w	0
	dc.w	336,9,350,15
	dc.l	PcWdthD
	dc.w	0
	dc.w	351,9,366,15
	dc.l	PcHghtU
	dc.w	0
	dc.w	336,16,350,22
	dc.l	PcHghtD
	dc.w	0
	dc.w	351,16,366,22
	dc.l	PcDpthU
	dc.w	0
	dc.w	336,23,350,29
	dc.l	PcDpthD
	dc.w	0
	dc.w	351,23,366,29
	dc.l	FindPic
	dc.w	0
	dc.w	374,2,420,15
	dc.l	FindCol
	dc.w	0
	dc.w	374,16,420,29
	dc.l	SavePic
	dc.w	0
	dc.w	576,0,639,31
	dc.l	-1

;--------------------------------------;

CList	dc.w	$0100,$0200
Window	dc.w	$008e,$1c81,$0090,$39f1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$023f
Modulos	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0180,$0000,$0182,$048f
SPRCols	dc.w	$01a2,$0000,$01a6,$0fff

SPR1	dc.w	$0120,$0000,$0122,$0000
SPR2	dc.w	$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000

	dc.w	$2b07,$fffe,$0180,$0fff
BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$00f0,$0000,$00f2,$0000
	dc.w	$00f4,$0000,$00f6,$0000
	dc.w	$00f8,$0000,$00fa,$0000
	dc.w	$00fc,$0000,$00fe,$0000
	dc.w	$2c07,$fffe,$0180,$0000
Depth	dc.w	$0100,$1200

PAL1	dc.w	$f401,$fffe
	dc.w	$f407,$fffe,$0100,$0200
	dc.w	$0180,$0fff
	dc.w	$0108,$0050,$010a,$0050
	dc.w	$008e,$1c81,$0090,$39c1
	dc.w	$0092,$003c,$0094,$00d4
PAL2	dc.w	$f501,$fffe
	dc.w	$f507,$fffe,$0100,$a200
BPL2	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000

	dc.w	$0180,$0aaa,$0182,$0000
	dc.w	$0184,$0fff,$0186,$068b

PAL3	dc.w	$ffe1,$fffe
	dc.w	$1707,$fffe,$0180,$0000
	dc.w	$0100,$0200
	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

Pointer	dc.w	$f640,$0502
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1111000000000000,%0100000000000000
	dc.w	%0111110000000000,%0011000000000000
	dc.w	%0111111100000000,%0011110000000000
	dc.w	%0011111111000000,%0001111100000000
	dc.w	%0011111111100000,%0001111111000000
	dc.w	%0001111111000000,%0000111110000000
	dc.w	%0001111111000000,%0000111110000000
	dc.w	%0000111111100000,%0000011111000000
	dc.w	%0000111111110000,%0000010011100000
	dc.w	%0000010011111000,%0000000001110000
	dc.w	%0000000001111100,%0000000000111000
	dc.w	%0000000000111000,%0000000000010000
	dc.w	%0000000000010000,%0000000000000000
	dc.w	0,0

;--------------------------------------;

WinDef1	dc.w	0,0			;X & Y
	dc.w	320,25			;Width & Height
	dc.b	0,1			;Colours
	dc.l	$240			;IDCMP
	dc.l	$100e			;Flags
	dc.l	Gadget1			;Gadgets
	dc.l	0			;CheckMark
	dc.l	WnTitle			;Title
	dc.l	0			;Screen
	dc.l	0			;BitMap
	dc.w	640,50			;X & Y Min
	dc.w	640,256			;X & Y Max
	dc.w	1			;Type
WnTitle	dc.b	"Picture Peeker - Save",0
WnError	dc.b	"Picture Peeker - !!! Error !!!",0,0
Gadget1	GadStrg	0,12,13,37,SBrder1,0,FleName,200,1
SBrder1	Border	SBrder2,-4,-1,304,10,1,2
SBrder2	Border	0,-6,-2,308,12,2,1
FleName	dcb.b	200,0

;--------------------------------------;

IFFStrc	dc.l	"FORM",0,"ILBM"

	dc.l	"BMHD",20
	dc.w	0,0			;Width,Height
	dc.w	0,0
	dc.b	0			;Planes
	dc.b	0
	dc.b	0
	dc.b	0
	dc.w	0
	dc.b	10,11
	dc.w	320,256			;Source: Width,Height

	dc.l	"CAMG",4
	dc.l	$4000			;ViewMode

	dc.l	"BODY",0

;--------------------------------------;

Font	include	"DH1:PicPeeker/Font.i"
	even
Picture	incbin	"DH1:PicPeeker/PicPeek.raw"
	END

