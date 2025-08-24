Music	= 1		;1 = Music, 0 = No Music
Colr0	= $448
Colr1	= $488
Colr2	= $84c
Colr3	= $88c
ColOff	= 4		;Brightness of Text compared to Effect Cols
	;  RGB
ColRGB	= %111		;Brightness Colour Mask, %100 = red, %101 = purple...

;--------------------------------------;

WaitBlt	MACRO
	tst.b	2(a5)
.WB\@	btst	#6,2(a5)
	bne.b	.WB\@
	ENDM

;-------------------;

Inc.w	MACRO
COL1	SET	\1&$f00
	IFNE	ColRGB&%100
	  IF	(\1&$f00)<((15-ColOff)<<8)
COL1	  SET	(\1&$f00)+ColOff<<8
	  ELSE
COL1	  SET	$f00
	  ENDC
	ENDC
COL2	SET	\1&$0f0
	IFNE	ColRGB&%010
	  IF	(\1&$0f0)<((15-ColOff)<<4)
COL2	  SET	(\1&$0f0)+ColOff<<4
	  ELSE
COL2	  SET	$0f0
	  ENDC
	ENDC
COL3	SET	\1&$00f
	IFNE	ColRGB&%001
	  IF	(\1&$00f)<(15-ColOff)
COL3	  SET	(\1&$00f)+ColOff
	  ELSE
COL3	  SET	$00f
	  ENDC
	ENDC
	dc.w	COL1!COL2!COL3
	ENDM

;--------------------------------------;

	SECTION	"Frantic - Psychad Intro 3",CODE_C

Start	bsr	ClrText
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

	IFNE	Music
	bsr	mt_init
	ENDC

	move.l	#TxtArea,d0
	lea	TxtBPL(pc),a0
	moveq	#2-1,d7
.1	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#256*(320/8),d0
	addq.l	#8,a0
	dbf	d7,.1

	move.l	#Frantic,d0
	lea	BPLFTC(pc),a0
	moveq	#2-1,d7
.2	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#13*(640/8),d0
	addq.l	#8,a0
	dbf	d7,.2

	move.w	$7c(a5),d0
	cmp.b	#$f8,d0
	bne.b	.NonAGA
	move.w	#0,$106(a5)
	move.w	#0,$1fc(a5)

.NonAGA	bsr.w	GetVBR
	lea	$dff000,a5
	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	$6c(a6),OldIRQ
	move.l	#NewIRQ,$6c(a4)
	move.w	#$c020,$9a(a5)

	move.w	#$7fff,$96(a5)
	move.l  #CList,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$83d0,$96(a5)
	move.l	#0,$144(a5)

Mouse	bsr	WrteTxt
	btst	#6,$bfe001
	bne.b	Mouse

	IFNE	Music
	bsr	mt_end
	ENDC

	lea	$dff000,a5
	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	OldIRQ(pc),$6c(a6)
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
.VBR1	move.l	a4,a6
	rts

.VBR2	movec	vbr,a4
	rte

;--------------------------------------;

NewIRQ	movem.l	d0-a6,-(a7)
;	btst	#2,$dff016
;	beq	Pause
	bsr	SnLines
	IFNE	Music
	bsr	mt_Music
	ENDC
	move.w	#$4200,Action+2
	tst.w	TimeOut
	beq	.2
	subq.w	#1,TimeOut
	cmp.w	#17,TimeOut
	bgt	.1
	bsr	FadeDwn
	cmp.w	#1,TimeOut
	bne	.2
	bsr	ClrScrn
	bra	.2
.1	bsr	FadeUp
.2
Pause	movem.l	(a7)+,d0-a6
;	move.w	#$00f0,$180(a5)
	move.w	#$0020,$9c(a5)
	rte

;--------------------------------------;

ClrText	moveq	#0,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,d7
	move.l	d1,a0
	move.l	d1,a1
	move.l	d1,a2
	lea	TxtArea+(2*256*(320/8)),a3
	move.w	#((2*256*(320/8))/4/8/10)-1,d0
.1	REPT	8
	movem.l	d1-a2,-(a3)
	ENDR
	dbf	d0,.1
	rts

;--------------------------------------;

ClrScrn	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	#TxtArea,$54(a5)
	move.w	#2*256<<6+(320/16),$58(a5)
	rts

;--------------------------------------;

WrteTxt	tst.w	TimeOut
	bne	.2
	move.l	TxtPntr(pc),a0
	lea	TxtArea,a1
	lea	TxtFont(pc),a2
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	TxtPntr+4(pc),d1
	move.w	TxtPntr+6(pc),d2

.0	move.b	(a0)+,d0
	bne	.1
	move.l	#Text,a0
	move.l	a0,TxtPntr
	bra	.0
.1	cmp.b	#10,d0
	beq	NewLine
	cmp.b	#"~",d0
	beq	NewPage
	bsr	PutChar
	addq.w	#8,TxtPntr+4
	addq.l	#1,TxtPntr
.2	rts

NewPage	move.w	TimeOut+2(pc),TimeOut
	clr.w	TimeOut+2
	clr.w	TxtPntr+4
	clr.w	TxtPntr+6
	addq.l	#1,TxtPntr
	rts

NewLine	move.w	#(320/2),d0
	bra	.2
.1	subq.w	#4,d0
.2	cmp.b	#10,(a0)+
	bne	.1
	add.w	#40,TimeOut+2
	move.w	d0,TxtPntr+4
	add.w	#10,TxtPntr+6
	addq.l	#1,TxtPntr
	rts

PutChar	sub.b	#32,d0
	lsl.w	#3,d0
	lea	(a2,d0),a3
	mulu	#(320/8),d2
	lea	(a1,d2),a4
	subq.w	#8,d1
	move.w	d1,d2
	lsr.w	#3,d2
	bclr	#0,d2
	lea	(a4,d2),a4
	and.w	#$f,d1

	moveq	#8-1,d4

.1	moveq	#0,d0
	move.b	(a3)+,d0
	swap	d0
	lsr.l	d1,d0
	or.l	d0,(a4)
	rol.l	#1,d0

	lea	(255*(320/8))(a4),a4

	moveq	#3-1,d2
.2	moveq	#3-1,d3
.3	or.l	d0,(a4)
	ror.l	#1,d0
	dbf	d3,.3
	rol.l	#3,d0
	lea	(320/8)(a4),a4
	dbf	d2,.2
	lea	-(257*(320/8))(a4),a4
	dbf	d4,.1
	rts

;--------------------------------------;

FadeUp	lea	FdeCols+2(pc),a0
	lea	FadeIn(pc),a1
	moveq	#8-1,d7
.1	move.w	(a1)+,d0
	bsr	Fader
	addq.l	#4,a0
	dbf	d7,.1
	rts

;-------------------;

FadeDwn	lea	FdeCols+2(pc),a0
	lea	FadeOut(pc),a1
	moveq	#8-1,d7
.1	move.w	(a1)+,d0
	bsr	Fader
	addq.l	#4,a0
	dbf	d7,.1
	rts

;-------------------;

Fader	move.w	d0,d1
	move.w	d0,d2
	and.w	#$0f00,d0
	and.w	#$00f0,d1
	and.w	#$000f,d2
	move.w	(a0),d3
	move.w	d3,d4
	move.w	d3,d5
	and.w	#$0f00,d3
	and.w	#$00f0,d4
	and.w	#$000f,d5
	move.w	#$0100,d6
	cmp.w	d3,d0
	beq	.2
	bpl	.1
	neg.w	d6
.1	add.w	d6,(a0)
.2	move.w	#$0010,d6
	cmp.w	d4,d1
	beq	.4
	bpl	.3
	neg.w	d6
.3	add.w	d6,(a0)
.4	move.w	#$0001,d6
	cmp.w	d5,d2
	beq	.6
	bpl	.5
	neg.w	d6
.5	add.w	d6,(a0)
.6	rts

;--------------------------------------;

SnLines	lea	SOffst1(pc),a0
	lea	SOffst2(pc),a1
	lea	SinList(pc),a2
	lea	PicMask(pc),a3
	lea	BPL(pc),a4
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0),d0
	move.b	1(a0),d1
	move.b	(a1),d2
	move.b	1(a1),d3

	move.b	4(a0),d4
	move.b	5(a0),d5
	move.b	4(a1),d6
	move.b	5(a1),d7
	add.b	d4,(a0)
	add.b	d5,1(a0)
	add.b	d6,(a1)
	add.b	d7,1(a1)

	move.w	#40-1,d7
	swap	d7
	move.w	#210-1,d7
.1	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	move.b	(a2,d0),d4
	move.b	(a2,d1),d5
	add.w	d5,d4
	lsr.w	#1,d4
	move.b	(a2,d2),d5
	move.b	(a2,d3),d6
	add.w	d6,d5
	lsr.w	#1,d5

	move.w	d4,d6
	lsl.w	#3,d4
	lsl.w	#5,d6
	add.w	d6,d4			;	mulu	#(320/8),d4
	move.w	d5,d6
	lsl.w	#3,d5
	lsl.w	#5,d6
	add.w	d6,d5			;	mulu	#(320/8),d4
	add.l	a3,d4
	add.l	a3,d5
	move.w	d4,6(a4)
	move.w	d5,14(a4)
	swap	d4
	swap	d5
	move.w	d4,2(a4)
	move.w	d5,10(a4)

	add.b	2(a0),d0
	add.b	3(a0),d1
	add.b	2(a1),d2
	add.b	3(a1),d3
	lea	20(a4),a4
.2	dbf	d7,.1
	addq.l	#4,a4
	swap	d7
	tst.w	d7
	bpl	.2
	rts

;--------------------------------------;

	IFNE	Music
PTMusic	include	"DH1:Psychad3/ProTracker2.3A.i"
	ENDC

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0
SOffst1	dc.b	0,0,1,8,256-5,256-4
SOffst2	dc.b	0,0,1,7,5,3
TxtPntr	dc.l	Text
	dc.w	0,0
TimeOut	dc.w	0,0

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$36c1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$003f
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0180,$0000

	dc.w	$2c07,$fffe
	dc.w	$0180,$0fff,$0182,Colr1
	dc.w	$0184,Colr2,$0186,Colr3

FdeCols	dc.w	$0190,Colr0
	dc.w	$0192,Colr1
	dc.w	$0194,Colr2
	dc.w	$0196,Colr3
	dc.w	$0198,Colr0
	dc.w	$019a,Colr1
	dc.w	$019c,Colr2
	dc.w	$019e,Colr3

TxtBPL	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000

	dc.w	$2e07,$fffe,$0180,Colr0
Action	dc.w	$0100,$0200

BPL	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000

COUNT	SET	$2f07
	REPT	210-1
	dc.w	COUNT,$fffe
	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
COUNT	SET	COUNT+$100
	ENDR

	dc.w	$ffe1,$fffe

COUNT	SET	$0007
	REPT	40-1
	dc.w	COUNT,$fffe
	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
COUNT	SET	COUNT+$100
	ENDR

	dc.w	$2707,$fffe,$0100,$0200
	dc.w	$0180,$0fff,$0182,$0fff
	dc.w	$0184,$0aaa,$0186,$0555
	dc.w	$0092,$003c,$0094,$00d4
	dc.w	$2907,$fffe,$0100,$a200
	dc.w	$0180,$0000
BPLFTC	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$3607,$fffe,$0100,$0200

	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

FadeIn	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	Inc.w	Colr0
	Inc.w	Colr1
	Inc.w	Colr2
	Inc.w	Colr3

FadeOut	dc.w	Colr0
	dc.w	Colr1
	dc.w	Colr2
	dc.w	Colr3
	dc.w	Colr0
	dc.w	Colr1
	dc.w	Colr2
	dc.w	Colr3

;--------------------------------------;

SinList	dc.b	$0f,$10,$10,$10,$11,$11,$11,$12,$12,$12,$13,$13,$14,$14,$14,$15
	dc.b	$15,$15,$16,$16,$16,$17,$17,$17,$17,$18,$18,$18,$19,$19,$19,$19
	dc.b	$1a,$1a,$1a,$1a,$1b,$1b,$1b,$1b,$1c,$1c,$1c,$1c,$1c,$1c,$1d,$1d
	dc.b	$1d,$1d,$1d,$1d,$1d,$1e,$1e,$1e,$1e,$1e,$1e,$1e,$1e,$1e,$1e,$1e
	dc.b	$1e,$1e,$1e,$1e,$1e,$1e,$1e,$1e,$1e,$1e,$1e,$1d,$1d,$1d,$1d,$1d
	dc.b	$1d,$1d,$1c,$1c,$1c,$1c,$1c,$1c,$1b,$1b,$1b,$1b,$1a,$1a,$1a,$1a
	dc.b	$19,$19,$19,$19,$18,$18,$18,$17,$17,$17,$17,$16,$16,$16,$15,$15
	dc.b	$15,$14,$14,$14,$13,$13,$12,$12,$12,$11,$11,$11,$10,$10,$10,$0f
	dc.b	$0f,$0e,$0e,$0e,$0d,$0d,$0d,$0c,$0c,$0c,$0b,$0b,$0a,$0a,$0a,$09
	dc.b	$09,$09,$08,$08,$08,$07,$07,$07,$07,$06,$06,$06,$05,$05,$05,$05
	dc.b	$04,$04,$04,$04,$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$01,$01
	dc.b	$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01
	dc.b	$01,$01,$02,$02,$02,$02,$02,$02,$03,$03,$03,$03,$04,$04,$04,$04
	dc.b	$05,$05,$05,$05,$06,$06,$06,$07,$07,$07,$07,$08,$08,$08,$09,$09
	dc.b	$09,$0a,$0a,$0a,$0b,$0b,$0c,$0c,$0c,$0d,$0d,$0d,$0e,$0e,$0e,$0f

;--------------------------------------;

Text	incbin	"DH1:Psychad3/Psychad3.txt"
	dc.b	0
	even
PicMask	incbin	"DH1:Psychad3/SinMask.raw"
TxtFont	include	"DH1:Psychad3/Font.i"
Frantic	incbin	"DH1:Psychad3/Frantic.raw"
	IFNE	Music
mt_data	incbin	"DH0:Modules/mod.Intro Number 60"
	ENDC
	SECTION	"Text Area",BSS_C

TxtArea	ds.b	2*256*(320/8)

	END
