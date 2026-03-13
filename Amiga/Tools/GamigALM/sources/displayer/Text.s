	SECTION	"GeMaNiX - Text Displayer",CODE_C

;--------------------------------------;

WaitBlt	MACRO
	tst.b	2(a5)
WB\@	btst	#6,2(a5)
	bne.b	WB\@
	ENDM

;--------------------------------------;

	bsr.w	Display
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

	move.l	#Picture,d0
	lea	BPL1(pc),a0
	moveq	#4,d7
Pic2Cop	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40,d0
	addq.l	#8,a0
	dbf	d7,Pic2Cop

	bsr.w	GetVBR
	lea	$dff000,a5
	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	$6c(a4),OldIRQ
	move.l	#NewIRQ,$6c(a4)
	move.w	#$c020,$9a(a5)

	move.w	#$7fff,$96(a5)
	move.l  #CLst1,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$83d0,$96(a5)
	move.l	#0,$144(a5)

	btst	#6,$bfe001
	beq	End
MseChk1	tst.b	BPLSwch
	bmi	MseChk2
	btst	#6,$bfe001
	bne	MseChk1
	move.l	#ComLst2,ComdPnt
	bra	KlIntro

MseChk2	btst	#6,$bfe001
	bne	MseChk2
	move.b	#-2,BPLSwch

KlIntro	tst.b	BPLSwch
	bne	KlIntro
End	lea	$dff000,a5
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
	bsr	ComChck
	movem.l	(a7)+,d0-a6
	move.w	#$0020,$dff09c
	rte

;--------------------------------------;

ComChck	move.l	ComdPnt(pc),a0
	move.l	(a0),a0
	jmp	(a0)

;--------------------------------------;

Display	lea	Text(pc),a0
	lea	TxtArea(pc),a2
	lea	TxtArea(pc),a3

DspLoop	cmp.l	#TxtAreaEnd,a3
	bne.b	FndChar
	rts
FndChar	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#10,d0
	beq.b	NewLine
	sub.b	#32,d0
	add.l	#CharSet,d0
	move.l	d0,a1

	move.l	a2,a4
	moveq	#7,d0
TxtLoop	move.b	(a1),(a4)
	lea	188(a1),a1
	lea	80(a4),a4
	dbf	d0,TxtLoop
	addq.l	#1,a2
	bra.b	DspLoop

NewLine	lea	640(a3),a3
	move.l	a3,a2
	bra.b	DspLoop

;--------------------------------------;

DragUp	cmp.b	#-2,BPLSwch
	bne	DrgUp
	addq.l	#4,ComdPnt
	bra	DragEnd
DrgUp	move.l	SinePnt(pc),a0
	move.b	(a0)+,BPLPnt
	move.l	a0,SinePnt
	cmp.l	#SineEnd,a0
	bne.b	DragEnd
	addq.l	#4,ComdPnt
DragEnd	rts

PushDwn	cmp.b	#-2,BPLSwch
	bne	PushEnd
	move.l	SinePnt(pc),a0
	move.b	-(a0),BPLPnt
	move.l	a0,SinePnt
	cmp.l	#SinList,a0
	bne.b	PushEnd
	move.b	#0,BPLSwch
PushEnd	rts

;--------------------------------------;

FdUpInt	move.b	#30,Dummy
	addq.l	#4,ComdPnt
FdeLgoU	tst.b	Dummy
	bne	FdeLgUp
	addq.l	#4,ComdPnt
FdeLgUp	btst	#0,Dummy
	beq	FdLgUpX
	lea	Colours+2(pc),a0
	lea	ColChrt(pc),a1
	moveq	#31,d7
FadeLpU	move.w	(a1)+,d0
	bsr	WRed
	addq.l	#4,a0
	dbf	d7,FadeLpU
FdLgUpX	subq.b	#1,Dummy
	rts

;--------------------------------------;

FdDnInt	move.b	#30,Dummy
	addq.l	#4,ComdPnt
FdeLgoD	tst.b	Dummy
	bne	FdeLgDn
	addq.l	#4,ComdPnt
FdeLgDn	btst	#0,Dummy
	beq	FdLgDnX
	lea	Colours+2(pc),a0
	moveq	#31,d7
FadeLpD	moveq	#0,d0
	bsr	WRed
	addq.l	#4,a0
	dbf	d7,FadeLpD
FdLgDnX	subq.b	#1,Dummy
	rts

;--------------------------------------;

FdeScnI	move.b	#30,Dummy
	addq.l	#4,ComdPnt
FdeScrn	tst.b	Dummy
	bne	FadeScn
	addq.l	#4,ComdPnt
FadeScn	moveq	#0,d0
	lea	Col1+2(pc),a0
	bsr	WRed
	lea	Col2+6(pc),a0
	bsr	WRed
	lea	Col3+6(pc),a0
	bsr	WRed
	lea	Col4+6(pc),a0
	bsr	WRed
FdScEnd	subq.b	#1,Dummy
	rts

;--------------------------------------;

EndFade	move.b	#0,BPLSwch
	rts

;--------------------------------------;

WRed	moveq	#0,d3

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$0f00,d1
	and.w	#$0f00,d2
	cmp.w	d1,d2
	beq.b	WGreen
	blt.b	SubRed
	sub.w	#$0100,d2
	bra.b	WGreen
SubRed	add.w	#$0100,d2
WGreen	add.w	d2,d3
	move.w	(a0),d2

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$00f0,d1
	and.w	#$00f0,d2
	cmp.w	d1,d2
	beq.b	WBlue
	blt.b	SubGrn
	sub.w	#$0010,d2
	bra.b	WBlue
SubGrn	add.w	#$0010,d2
WBlue	add.w	d2,d3
	move.w	(a0),d2

	move.w	d0,d1
	move.w	(a0),d2
	and.w	#$000f,d1
	and.w	#$000f,d2
	cmp.w	d1,d2
	beq.b	WFinshd
	blt.b	SubBlu
	sub.w	#$0001,d2
	bra.b	WFinshd
SubBlu	add.w	#$0001,d2
WFinshd	add.w	d2,d3
	move.w	(a0),d2

	move.w	d3,(a0)
	rts

;--------------------------------------;

PausInt	move.w	#5*50,Dummy
	addq.l	#4,ComdPnt
Pause	tst.w	Dummy
	bne	PausEnd
	addq.l	#4,ComdPnt
PausEnd	subq.w	#1,Dummy
	rts

;--------------------------------------;

TxtStUp	move.l	#TxtArea,d0
	lea	BPL2(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.w	#$7fff,$96(a5)
	move.l  #CLst2,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$83d0,$96(a5)
	move.l	#0,$144(a5)

	addq.l	#4,ComdPnt
	move.b	#-1,BPLSwch
	rts

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0
BPLSwch	dc.b	1
Dummy	dc.w	0
SinePnt	dc.l	SinList
ComdPnt	dc.l	ComLst1
ComLst1	dc.l	FdUpInt
	dc.l	FdeLgoU
	dc.l	PausInt
	dc.l	Pause
	dc.l	FdDnInt
	dc.l	FdeLgoD
	dc.l	FdeScnI
	dc.l	FdeScrn
	dc.l	TxtStUp
	dc.l	DragUp
	dc.l	PushDwn

ComLst2	dc.l	FdDnInt
	dc.l	FdeLgoD
	dc.l	FdeScnI
	dc.l	FdeScrn
	dc.l	EndFade

;--------------------------------------;

CLst1	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0106,$0000,$01fc,$0000
	dc.w	$0108,$00a0,$010a,$00a0
Col1	dc.w	$0180,$0023,$0182,$0fff

Col2	dc.w	$7607,$fffe,$0180,$0fff
	dc.w	$7707,$fffe,$0180,$0000
	dc.w	$8007,$fffe,$0100,$5200
BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$00f0,$0000,$00f2,$0000

Colours	dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
	dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
	dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
	dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
	dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000

	dc.w	$d507,$fffe,$0100,$0200
Col3	dc.w	$e007,$fffe,$0180,$0fff
Col4	dc.w	$e107,$fffe,$0180,$0023
	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

CLst2	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$003c,$0094,$00d4
	dc.w	$0102,$0000,$0104,$0000
	dc.w	$0106,$0000,$01fc,$0000
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0180,$0000,$0182,$0fff

BPLPnt	dc.w	$f407,$fffe,$0100,$9200
BPL2	dc.w	$00e0,$0000,$00e2,$0000

	dc.w	$f407,$fffe,$0100,$0200
	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

SinList	dc.b	$f2,$ec,$e6,$e0,$d9,$d3,$cd,$c7,$c1,$bb
	dc.b	$b5,$af,$a9,$a3,$9d,$98,$92,$8d,$88,$82
	dc.b	$7d,$78,$73,$6f,$6a,$65,$61,$5d,$59,$55
	dc.b	$51,$4e,$4a,$47,$44,$41,$3e,$3c,$39,$37
	dc.b	$35,$34,$32,$30,$2f,$2e,$2d,$2d,$2c,$2c
SineEnd

;--------------------------------------;

ColChrt	dc.w	$000,$fff,$6b5,$6b5,$b54,$830,$623,$310
	dc.w	$fa5,$d73,$c63,$a53,$942,$731,$520,$410
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

;--------------------------------------;

Text	IncBin	"DH2:Displayer/Text.txt"
	even
Picture	IncBin	"DH2:Displayer/Logo.raw"
CharSet	IncBin	"DH2:Displayer/Siesta.font"
TxtArea	dcb.b	(8*25)*(640/8),0
TxtAreaEnd
