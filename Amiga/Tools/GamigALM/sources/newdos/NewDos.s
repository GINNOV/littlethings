	SECTION	"Text Display",CODE_C

Forbid		= -132
Permit		= -138

;--------------------------------------;

	movem.l	d0-a6,-(a7)
	move.l	4.w,a6
	jsr	Forbid(a6)
	lea	$dff000,a5

	move.l	#TxtArea,d0
	move.w	d0,BPL+6
	swap	d0
	move.w	d0,BPL+2

	move.l	#Sprite,d0
	move.w	d0,SPR+6
	swap	d0
	move.w	d0,SPR+2

	move.w	$a(a5),LstCord

	move.w	2(a5),d0
	or.w	#$8000,d0
	move.w	d0,DMACON

	move.w	#$7fff,$96(a5)
	move.l  #CList,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$83e0,$96(a5)

ChkMous	bsr.b	Display
	bsr.w	MousPos
	btst	#6,$bfe001
	bne.b	ChkMous

	move.l	$9c(a6),a1
	move.w	#$0080,$96(a5)
	move.l	38(a1),$80(a5)
	move.w	#$0000,$88(a5)
	move.w	DMACON(pc),$96(a5)

	jsr	Permit(a6)
	movem.l	(a7)+,d0-a6
	rts

;--------------------------------------;

Display	tst.w	Switch
	bne.w	TheEnd
	move.w	#$100,Switch

	tst.b	LineNum
	beq.w	MoveUp
	moveq	#0,d0
	move.l	TxtPnt(pc),a0
	move.b	(a0),d0
	cmp.b	#"{",d0
	beq.b	DsDelay
	cmp.b	#"}",d0
	beq.b	BigDlay
	cmp.b	#0,d0
	beq.b	EndLine
	cmp.b	#1,d0
	beq.w	EndText
	sub.b	#32,d0
	add.l	#CharSet,d0
	move.l	d0,a0
	move.l	CSPos(pc),a1

	moveq	#7,d0
PrintLp	move.b	(a0),(a1)
	move.b	#$ff,1(a1)
	add.l	#96,a0
	add.l	#80,a1
	dbf	d0,PrintLp

	add.l	#1,TxtPnt
	add.l	#1,CSPos
TheEnd	sub.w	#1,Switch
	rts

DsDelay	move.w	#$1000,Switch
	add.l	#1,TxtPnt
	rts

BigDlay	move.w	#$8000,Switch
	add.l	#1,TxtPnt
	rts

EndLine	sub.b	#1,LineNum
	moveq	#0,d1
	bsr.b	ClrCurs
	add.l	#640,CLine
	move.l	Cline(pc),CSPos
	moveq	#-1,d1
	bsr.b	ClrCurs
	tst.b	LineNum
	bne.b	NewLine
	sub.l	#640,CLine
	move.l	Cline(pc),CSPos
NewLine	add.l	#1,TxtPnt
	rts

EndText	moveq	#-1,d1
	bsr.b	ClrCurs
	clr.w	Switch
	rts

ClrCurs	moveq	#7,d0
	move.l	CSPos(pc),a0
ClrLoop	move.b	d1,(a0)
	add.l	#80,a0
	dbf	d0,ClrLoop
	rts

MoveUp	btst	#14,2(a5)
	bne.b	MoveUp
	move.l	#$09f00000,$40(a5)
	move.l	#$ffffffff,$44(a5)
	move.l	#TxtArea+640,$50(a5)
	move.l	#TxtArea,$54(a5)
	move.l	#$00000000,$64(a5)
	move.w	#(25*8)*64*1+40,$58(a5)
	move.b	#1,LineNum
	rts

;--------------------------------------;

MousPos	moveq	#0,d0
	moveq	#0,d1
	move.w	$a(a5),d0
	move.w	LstCord(pc),d1
	move.w	d0,LstCord
	sub.w	d1,d0
	beq.b	MousEnd

	move.l	d0,d1
	and.w	#$ff00,d0
	lsr	#8,d0
	and.w	#$00ff,d1
	cmp.b	#0,d0
	bpl.b	ChkXPos
	add.w	#$ff00,d0
ChkXPos	cmp.b	#0,d1
	bpl.b	MovePos
	add.w	#1,d0
	add.w	#$ff00,d1
MovePos	add.w	d1,MseXPos
	add.w	d0,MseYPos
	bsr.b	CheckUp

	lea	Sprite(pc),a0
	move.w	MseYPos(pc),d0
	move.b	d0,(a0)
	add.b	#$10,d0
	move.b	d0,2(a0)

	move.w	MseXPos(pc),d0
	move.b	#1,3(a0)
	lsr.w	#1,d0
	bcs.b	CarrySt
	move.b	#0,3(a0)
CarrySt	move.b	d0,1(a0)
MousEnd	rts

CheckUp	cmp.w	#$30,MseYPos
	bge.b	ChkDown
	move.w	#$30,MseYPos
ChkDown	cmp.w	#$f7,MseYPos
	ble	ChkLeft
	move.w	#$f7,MseYPos
ChkLeft	cmp.w	#$7e,MseXPos
	bge	ChkRght
	move.w	#$7e,MseXPos
ChkRght	cmp.w	#$1bc,MseXPos
	ble	ChkGone
	move.w	#$1bc,MseXPos
ChkGone	rts

;--------------------------------------;

DMACON	dc.w	0

CSPos	dc.l	TxtArea
CLine	dc.l	TxtArea
TxtPnt	dc.l	Text
Switch	dc.w	0
LineNum	dc.b	25
	even
LstCord	dc.w	0
MseYPos	dc.w	$30
MseXPos	dc.w	$7e

;--------------------------------------;

CList	dc.w	$008e,$287f,$0090,$28bf
	dc.w	$0092,$003b,$0094,$00cd

SPR	dc.w	$0120,$0000,$0122,$0000
	dc.w	$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000

	dc.w	$01a0,$0000,$01a2,$0f00
	dc.w	$01a4,$0000,$01a6,$0fff

PosOne	dc.w	$2c09,$fffe,$0180,$0f0f
	dc.w	$0108,$0000,$010a,$0000

	dc.w	$2d09,$fffe,$0180,$0044
	dc.w	$3009,$fffe,$0100,$9200

	dc.w	$0182,$0fff,$0184,$0000
	dc.w	$0186,$0f00

BPL	dc.w	$00e0,$0000,$00e2,$0000

	dc.w	$f809,$fffe,$0100,$0200
	dc.w	$fb09,$fffe,$0180,$0f0f
	dc.w	$fc09,$fffe,$0180,$0000
	dc.w	$ffff,$fffe

;--------------------------------------;

Text
 dc.b "Copyright 1992 Commodore-Amiga, Inc.",0
 dc.b "All rights reserved.",0
 dc.b "Release 3.5",0
 dc.b 0
 dc.b ">}}T{y{p{e{ {M{e{s{s{a{g{e{.{t{x{t{",0
 dc.b "}}",0
 dc.b "           ____/\ __  /\ /\   _____________    __    /\      ______",0
 dc.b "          // ___// / / // /  / ___________ \  /  \  / /     /     /",0
 dc.b "       /\/___  /// \/ /// \ // \___ / \ /\\ \/ /  \// \    // \__/",0
 dc.b "      //      ///    ///  ///     /// ///   //    //  /___/___  /",0
 dc.b "      \______/ \____//___/ \_____//__//____/\_/__/\____________/",0
 dc.b 0
 dc.b "                     Mini Intro by Robster, 1992",0
 dc.b 0
 dc.b 0
 dc.b 0
 dc.b ">}}M{o{u{s{e{P{r{e{s{s{.{e{x{e{",0
 dc.b "}}Press left mouse button to continue... ",1
 even
;--------------------------------------;

Sprite	dc.w	$303f,$4000
	dc.w	%1100000000000000,%0100000000000000
	dc.w	%0111000000000000,%1011000000000000
	dc.w	%0011110000000000,%0100110000000000
	dc.w	%0011111000000000,%0100001000000000
	dc.w	%0001110000000000,%0010010000000000
	dc.w	%0001011000000000,%0010101000000000
	dc.w	%0000001100000000,%0001010100000000
	dc.w	%0000000110000000,%0000001010000000
	dc.w	%0000000011000000,%0000000101000000
	dc.w	%0000000000000000,%0000000010000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	0,0

;--------------------------------------;

CharSet	incbin	DH2:NewDos/Font.raw
TxtArea	dcb.b	16000,0
	dcb.b	640,0

