	SECTION	"GeMaNiX - Vex Intro",CODE_C

;--------------------------------------;

WaitBlt	MACRO
	tst.b	2(a5)
WB\@	btst	#6,2(a5)
	bne.b	WB\@
	ENDM

;--------------------------------------;

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

	lea	BPL1(pc),a0
	move.l	#Screen1,d0
	moveq	#1,d7
Pic2Cop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#140*(320/8),d0
	addq.l	#8,a0
	dbf	d7,Pic2Cop

	lea	BPL3(pc),a0
	lea	BPL4(pc),a1
	move.l	#Padding,d0
	move.w	d0,6(a0)
	move.w	d0,6(a1)
	swap	d0
	swap	d1
	move.w	d0,2(a0)
	move.w	d0,2(a1)

	lea	BPL2(pc),a0
	move.l	#SclArea,d0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	lea	BPL5(pc),a0
	move.l	#Robster,d0
	moveq	#1,d7
Rob2Cop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40,d0
	addq.l	#8,a0
	dbf	d7,Rob2Cop

	move.w	$7c(a5),d0
	cmp.b	#$f8,d0
	bne.b	NotAGA
	move.w	#0,$106(a5)
	move.w	#0,$1fc(a5)

NotAGA	bsr.w	MT_Init
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
	move.w	#$83d0,$96(a5)
	move.l	#0,$144(a5)

MousChk	btst	#6,$bfe001
	bne.b	MousChk

	bsr.w	MT_End
	lea	$dff000,a5
	WaitBlt
	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	OldIRQ(pc),$6c(a4)
	move.w	IntEna(pc),$9a(a5)

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
	beq.b	NoProcc
	lea	VBRExcp(pc),a5
	jsr	-30(a6)
NoProcc	rts

VBRExcp	dc.w	$4e7a,$c801
	rte

;--------------------------------------;

NewIRQ	movem.l	d0-a6,-(a7)
	bsr.b	SwpScrn
	bsr.w	NewAngle
	bsr.w	Rotate
	bsr.w	Prspctv
	bsr.w	DoLines
	bsr.w	FillObj

WaitPos	cmp.b	#$c0,6(a5)
	bne.b	WaitPos
	bsr.w	BltScrl
	bsr.w	MT_Music
	movem.l	(a7)+,d0-a6
;	move.w	#$00f0,$dff180
	move.w	#$0020,$dff09c
	rte

;--------------------------------------;

SwpScrn	movem.l	CurScrn(pc),d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,CurScrn

	lea	BPL1(pc),a0
	moveq	#1,d7
Mve2Cop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#140*(320/8),d0
	addq.l	#8,a0
	dbf	d7,Mve2Cop

	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	WrkScrn(pc),$54(a5)
	move.w	#2*140<<6+20,$58(a5)
	rts

;--------------------------------------;

NewAngle
NewAngX	move.w	#360,d1
	move.w	AngSkpX(pc),d0
	add.w	d0,AngleX
	cmp.w	AngleX(pc),d1
	bge.b	NewAngY
	sub.w	d1,AngleX
NewAngY	move.w	AngSkpY(pc),d0
	add.w	d0,AngleY
	cmp.w	AngleY(pc),d1
	bge.b	NewAngZ
	sub.w	d1,AngleY
NewAngZ	move.w	AngSkpZ(pc),d0
	add.w	d0,AngleZ
	cmp.w	AngleZ(pc),d1
	bge.b	NewAngF
	sub.w	d1,AngleZ
NewAngF	rts

;--------------------------------------;

;	ROTATION
;	~~~~~~~~
;	(n) = ANGLE TO ROTATE BY, n = AXIS
;	NX=X*COS(Z)-Y*SIN(Z)
;	NY=X*SIN(Z)+Y*COS(Z)
;	NX=X*COS(Y)-Z*SIN(Y)
;	NZ=X*SIN(Y)+Z*COS(Y)
;	NZ=Z*COS(X)-Y*SIN(X)
;	NY=Z*SIN(X)+Y*COS(X)

Rotate	lea	SinTble(pc),a0
	lea	CosTble(pc),a1
	lea	CrdTble(pc),a3
	move.l	Object(pc),a2
	addq.l	#4,a2
	move.w	(a2)+,d7
RotLoop	move.w	(a2)+,d0
	move.w	(a2)+,d1
	move.w	(a2)+,d2

	move.w	AngleZ(pc),d3
	add.w	d3,d3
	move.w	d3,d4
	move.w	(a0,d3),d3
	move.w	(a1,d4),d4
	move.w	d1,d5
	move.w	d0,d6
	muls	d4,d5
	muls	d4,d6
	move.l	d1,d4
	muls	d3,d4
	muls	d0,d3
	add.l	d6,d4
	sub.l	d5,d3
	asr.l	#8,d3
	asr.l	#6,d3
	asr.l	#8,d4
	asr.l	#6,d4
	move.w	d3,d1
	move.w	d4,d0

	move.w	AngleY(pc),d3
	add.w	d3,d3
	move.w	d3,d4
	move.w	(a0,d3),d3
	move.w	(a1,d4),d4
	move.w	d0,d5
	move.w	d2,d6
	muls	d4,d5
	muls	d4,d6
	move.l	d0,d4
	muls	d3,d4
	muls	d2,d3
	add.l	d6,d4
	sub.l	d5,d3
	asr.l	#8,d3
	asr.l	#6,d3
	asr.l	#8,d4
	asr.l	#6,d4
	move.w	d3,d0
	move.w	d4,d2

	move.w	AngleX(pc),d3
	add.w	d3,d3
	move.w	d3,d4
	move.w	(a0,d3),d3
	move.w	(a1,d4),d4
	move.w	d2,d5
	move.w	d1,d6
	muls	d4,d5
	muls	d4,d6
	move.l	d2,d4
	muls	d3,d4
	muls	d1,d3
	add.l	d6,d4
	sub.l	d5,d3
	asr.l	#8,d3
	asr.l	#6,d3
	asr.l	#8,d4
	asr.l	#6,d4
	move.w	d3,d2
	move.w	d4,d1

	move.w	d0,(a3)+
	move.w	d1,(a3)+
	move.w	d2,(a3)+
	dbf	d7,RotLoop

	rts

;--------------------------------------;

;	CENTRAL POINT PERSPECTIVE
;	~~~~~~~~~~~~~~~~~~~~~~~~~
;	qout=fz-z1
;	bx1=de*(x1+fx)/quot
;	by1=de*(y1+fy)/qout

;	x1...Point X Coordinate
;	y1...Point Y Coordinate
;	z1...Point Z Coordinate
;	fx...Central projection origin Coordinate X
;	fy...Central projection origin Coordinate Y
;	fz...Central projection origin Coordinate Z
;	de...Eye-Screen-Distance

Prspctv	move.l	Object(pc),a0
	lea	PrjOrgn(pc),a1
	move.w	4(a0),d7
	lea	CrdTble,a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2

PtvLoop	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	move.w	(a0),d0
	move.w	2(a0),d1
	move.w	4(a0),d2
	move.w	(a1),d3
	move.w	2(a1),d4
	move.w	4(a1),d5

	add.l	d0,d3
	add.l	d1,d4
	asl.w	#8,d3
	ext.l	d3
	asl.w	#8,d4
	ext.l	d4
	sub.w	d2,d5
	beq.b	NoDivs
	divs	d5,d3
	divs	d5,d4

NoDivs	move.w	d3,(a0)
	move.w	d4,2(a0)
	addq.l	#6,a0
	dbf	d7,PtvLoop
	rts

;--------------------------------------;

DoLines	moveq	#40,d0
	moveq	#-1,d1

	WaitBlt
	move.w	d1,$44(a5)
	move.w	d1,$72(a5)
	move.w	#$8000,$74(a5)
	move.w	d0,$60(a5)
	move.w	d0,$66(a5)

	move.l	Object(pc),a0
	move.l	(a0),a1
	move.w	(a1)+,d7
	lea	CrdTble(pc),a0

DrawLp1	move.w	(a1)+,d0
	move.b	d0,SurfCol
	move.w	(a1)+,d6
	bsr.w	HidLine
	cmp.w	d2,d0
	blt.b	NoPoly
DrawLp2	moveq	#0,d4
	move.w	(a1)+,d4
	move.l	d4,d5
	add.l	d4,d4
	lsl.l	#2,d5
	add.l	d5,d4
	move.w	(a0,d4),d0
	move.w	2(a0,d4),d1
	moveq	#0,d4
	move.w	(a1),d4
	move.l	d4,d5
	add.l	d4,d4
	lsl.l	#2,d5
	add.l	d5,d4
	move.w	(a0,d4),d2
	move.w	2(a0,d4),d3
	add.w	#160,d0
	add.w	#70,d1
	add.w	#160,d2
	add.w	#70,d3

	btst	#0,SurfCol
	beq.b	NoColr1
	move.l	WrkScrn(pc),a2
	bsr.b	DrawLne
NoColr1	btst	#1,SurfCol
	beq.b	NoColr2
	move.l	WrkScrn(pc),a2
	lea	140*(320/8)(a2),a2
	bsr.b	DrawLne
NoColr2	dbf	d6,DrawLp2
	addq.l	#2,a1
	dbf	d7,DrawLp1
	rts

NoPoly	addq.w	#2,d6
	add.w	d6,d6
	add.w	d6,a1
	dbf	d7,DrawLp1
	rts

;--------------------------------------;

DrawLne	movem.l	d0-d3,-(a7)
	cmp.w	d1,d3
	bge.s	y1ly2
	exg	d0,d2
	exg	d1,d3

y1ly2	sub.w	d1,d3
	move.w	d1,d4
	lsl.w	#3,d1
	lsl.w	#5,d4
	add.w	d4,d1
	ext.l	d1
	add.l	d1,a2
	moveq	#0,d1
	sub.w	d0,d2
	bge.s	xdpos
	addq.w	#2,d1

	neg.w	d2
xdpos	moveq	#$f,d4

	and.w	d0,d4

	move.b	d4,d5			;;
	not.b	d5			;;

	lsr.w	#3,d0
	add.w	d0,a2
	ror.w	#4,d4
	or.w	#$b4a,d4		;;
	swap	d4
	cmp.w	d2,d3
	bge.s	dygdx
	addq.w	#1,d1
	exg	d2,d3
dygdx	add.w	d2,d2
	move.w	d2,d0
	sub.w	d3,d0
	addx.w	d1,d1
	move.b	Octants(pc,d1.w),d4

	swap	d2
	move.w	d0,d2
	sub.w	d3,d2
	moveq	#6,d1

	lsl.w	d1,d3
	add.w	#$42,d3
	lea	$52(a5),a3

	WaitBlt
	bchg	d5,(a2)			;;

	move.l	d4,$40(a5)
	move.l	d2,$62(a5)
	move.l	a2,$48(a5)
	move.w	d0,(a3)+
	move.l	a2,(a3)+
	move.w	d3,(a3)
	movem.l	(a7)+,d0-d3
	rts

SML	=	2 ;0 = LINE, 2 = FILL	;;
Octants	dc.b	SML+01,SML+01+$40
	dc.b	SML+17,SML+17+$40
	dc.b	SML+09,SML+09+$40
	dc.b	SML+21,SML+21+$40

;--------------------------------------;

;	HIDDEN LINES
;	~~~~~~~~~~~~
;	(Y2-Y3)*(X1-X2)-(Y1-Y2)*(X2-X3)
;	IF POSITIVE THEN DRAW IT

HidLine	moveq	#0,d4
	move.w	(a1),d4
	move.l	d4,d5
	add.l	d4,d4
	lsl.l	#2,d5
	add.l	d5,d4
	move.w	(a0,d4),d0
	move.w	2(a0,d4),d1
	moveq	#0,d4
	move.w	2(a1),d4
	move.l	d4,d5
	add.l	d4,d4
	lsl.l	#2,d5
	add.l	d5,d4
	move.w	(a0,d4),d2
	move.w	2(a0,d4),d3
	moveq	#0,d4
	move.w	4(a1),d4
	move.l	d4,d5
	add.l	d4,d4
	lsl.l	#2,d5
	add.l	d4,d5
	move.w	(a0,d5),d4
	move.w	2(a0,d5),d5
	sub.w	d2,d0
	sub.w	d4,d2
	sub.w	d3,d1
	sub.w	d5,d3
	muls	d1,d2
	muls	d3,d0
	rts

;--------------------------------------;

FillObj	move.l	WrkScrn(pc),a0
	lea	2*140*(320/8)-2(a0),a0
	moveq	#0,d0

	WaitBlt
	move.l	#$09f00012,$40(a5)
	move.l	d0,$64(a5)
	move.l	a0,$50(a5)
	move.l	a0,$54(a5)
	move.w	#2*140<<6+20,$58(a5)
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

Pause	move.w	#5*50,PauseP
	move.w	#0,Counter
	move.l	a0,CharPnt
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
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0
Object	dc.l	D_Box
SurfCol	dc.w	0
AngSkpX	dc.w	2
AngSkpY	dc.w	1
AngSkpZ	dc.w	4
AngleX	dc.w	0
AngleY	dc.w	0
AngleZ	dc.w	0
PrjOrgn
PstionX	dc.w	0
PstionY	dc.w	0
PstionZ	dc.w	400
CurScrn	dc.l	Screen1
WrkScrn	dc.l	Screen2
CharPnt	dc.l	ScrMess
Counter	dc.w	0
PauseP	dc.w	0

;--------------------------------------;

CList	dc.w	$008e,$2a81,$0090,$2ac1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0108,$0000,$010a,$0002

	dc.w	$0180,$0f44,$0182,$0f44
	dc.w	$0184,$0888,$0186,$0844
	dc.w	$0188,$08f8,$018a,$084f
	dc.w	$018c,$0484,$018e,$0048

	dc.w	$2a07,$fffe,$0180,$0000
	dc.w	$2b07,$fffe,$0180,$0fff
	dc.w	$6601,$fffe,$0100,$3200
BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e8,$0000,$00ea,$0000
BPL3	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$a401,$fffe
BPL2	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$b401,$fffe
BPL4	dc.w	$00e4,$0000,$00e6,$0000

	dc.w	$f201,$fffe,$0100,$0200
	dc.w	$ffe1,$fffe
	dc.w	$0180,$0fff,$0182,$0aaa
	dc.w	$0184,$0555,$0186,$0000
	dc.w	$0108,$0028,$010a,$0028

	dc.w	$1c01,$fffe,$0100,$2200
BPL5	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$2c01,$fffe,$0100,$0200
	dc.w	$2d07,$fffe,$0180,$0000
	dc.w	$2e07,$fffe,$0180,$088f
	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

D_Box	dc.l	L_Box

P_Box	dc.w	7			;Points-1
	dc.w	-60,-60,-60
	dc.w	 60,-60,-60
	dc.w	 60, 60,-60
	dc.w	-60, 60,-60
	dc.w	-60,-60, 60
	dc.w	 60,-60, 60
	dc.w	 60, 60, 60
	dc.w	-60, 60, 60

L_Box	dc.w	5			;Surfaces-1
	dc.w	1,3			;Colour, Lines in Surface-1
	dc.w	0,1,2,3,0
	dc.w	1,3
	dc.w	5,4,7,6,5
	dc.w	2,3
	dc.w	4,0,3,7,4
	dc.w	2,3
	dc.w	1,5,6,2,1
	dc.w	3,3
	dc.w	4,5,1,0,4
	dc.w	3,3
	dc.w	3,2,6,7,3

CrdTble	dcb.w	3*8,0

;--------------------------------------;

SinTble	dc.w	 00000, 00286, 00572, 00857, 01143, 01428, 01713, 01997, 02280
	dc.w	 02563, 02845, 03126, 03406, 03686, 03964, 04240, 04516, 04790
	dc.w	 05063, 05334, 05604, 05872, 06138, 06402, 06664, 06924, 07182
	dc.w	 07438, 07692, 07943, 08192, 08438, 08682, 08923, 09162, 09397
	dc.w	 09630, 09860, 10087, 10311, 10531, 10749, 10963, 11174, 11381
	dc.w	 11585, 11786, 11982, 12176, 12365, 12551, 12733, 12911, 13085
	dc.w	 13255, 13421, 13583, 13741, 13894, 14044, 14189, 14330, 14466
	dc.w	 14598, 14726, 14849, 14968, 15082, 15191, 15296, 15396, 15491
	dc.w	 15582, 15668, 15749, 15826, 15897, 15964, 16026, 16083, 16135
	dc.w	 16182, 16225, 16262, 16294, 16322, 16344, 16362, 16374, 16382

CosTble	dc.w	 16384, 16382, 16374, 16362, 16344, 16322, 16294, 16262, 16225
	dc.w	 16182, 16135, 16083, 16026, 15964, 15897, 15826, 15749, 15668
	dc.w	 15582, 15491, 15396, 15296, 15191, 15082, 14967, 14849, 14726
	dc.w	 14598, 14466, 14330, 14189, 14044, 13894, 13741, 13583, 13421
	dc.w	 13255, 13085, 12911, 12733, 12551, 12365, 12176, 11982, 11786
	dc.w	 11585, 11381, 11174, 10963, 10749, 10531, 10311, 10087, 09860
	dc.w	 09630, 09397, 09162, 08923, 08682, 08438, 08192, 07943, 07692
	dc.w	 07438, 07182, 06924, 06664, 06402, 06138, 05872, 05604, 05334
	dc.w	 05063, 04790, 04516, 04240, 03964, 03686, 03406, 03126, 02845
	dc.w	 02563, 02280, 01997, 01713, 01428, 01143, 00857, 00572, 00286
	dc.w	 00000,-00286,-00572,-00857,-01143,-01428,-01713,-01997,-02280
	dc.w	-02563,-02845,-03126,-03406,-03686,-03964,-04240,-04516,-04790
	dc.w	-05063,-05334,-05604,-05872,-06138,-06402,-06664,-06924,-07182
	dc.w	-07438,-07692,-07943,-08192,-08438,-08682,-08923,-09162,-09397
	dc.w	-09630,-09860,-10087,-10311,-10531,-10749,-10963,-11174,-11381
	dc.w	-11585,-11786,-11982,-12176,-12365,-12551,-12733,-12911,-13085
	dc.w	-13255,-13421,-13583,-13741,-13894,-14044,-14189,-14330,-14466
	dc.w	-14598,-14726,-14849,-14968,-15082,-15191,-15296,-15396,-15491
	dc.w	-15582,-15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
	dc.w	-16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374,-16382
	dc.w	-16384,-16382,-16374,-16362,-16344,-16322,-16294,-16262,-16225
	dc.w	-16182,-16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668
	dc.w	-15582,-15491,-15396,-15296,-15191,-15082,-14967,-14849,-14726
	dc.w	-14598,-14466,-14330,-14189,-14044,-13894,-13741,-13583,-13421
	dc.w	-13255,-13085,-12911,-12733,-12551,-12365,-12176,-11982,-11786
	dc.w	-11585,-11381,-11174,-10963,-10749,-10531,-10311,-10087,-09860
	dc.w	-09630,-09397,-09162,-08923,-08682,-08438,-08192,-07943,-07692
	dc.w	-07438,-07182,-06924,-06664,-06402,-06138,-05872,-05604,-05334
	dc.w	-05063,-04790,-04516,-04240,-03964,-03686,-03406,-03126,-02845
	dc.w	-02563,-02280,-01997,-01713,-01428,-01143,-00857,-00572,-00286

	dc.w	 00000, 00286, 00572, 00857, 01143, 01428, 01713, 01997, 02280
	dc.w	 02563, 02845, 03126, 03406, 03686, 03964, 04240, 04516, 04790
	dc.w	 05063, 05334, 05604, 05872, 06138, 06402, 06664, 06924, 07182
	dc.w	 07438, 07692, 07943, 08192, 08438, 08682, 08923, 09162, 09397
	dc.w	 09630, 09860, 10087, 10311, 10531, 10749, 10963, 11174, 11381
	dc.w	 11585, 11786, 11982, 12176, 12365, 12551, 12733, 12911, 13085
	dc.w	 13255, 13421, 13583, 13741, 13894, 14044, 14189, 14330, 14466
	dc.w	 14598, 14726, 14849, 14968, 15082, 15191, 15296, 15396, 15491
	dc.w	 15582, 15668, 15749, 15826, 15897, 15964, 16026, 16083, 16135
	dc.w	 16182, 16225, 16262, 16294, 16322, 16344, 16362, 16374, 16382
	dc.w	 16384, 16382, 16374, 16362, 16344, 16322, 16294, 16262, 16225

;--------------------------------------;

Screen1	dcb.b	2*140*(320/8),0
Screen2	dcb.b	2*140*(320/8),0
FntData	incbin	"DH2:VexIntro/Font.raw"
SclArea	dcb.b	17*(336/8),0
Robster	incbin	"DH2:VexIntro/Robster.raw"
Padding	dcb.b	62*(336/8),0
ScrMess	dc.b	"GEMANIX PRESENTS -     BEAST  6     -a   "
	dc.b	"INTRO CODING BY ROBSTER, FONT FROM HORIZON, "
	dc.b	"    HELLO TO HYDSIE (HEHE BET YA!!!!),    "
	dc.b	"CATCHA IN ANOTHER RELEASE FROM  GEMANIX!!!          ",0
	even
MT_Data	incbin	"DH2:VexIntro/mod.TopGlad"



