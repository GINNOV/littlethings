	Include	Main.i
	var.w	FontSize
	var.w	FontXSize,FontYSize
Vars_SIZEOF	rs.w	0

;	Version 34.3 - 2/23/92 Ian Einman

	lea	Main.text(PC),a0
	pea	Start(pc)
WriteIt	move.l	StdOutput(a5),d1
	move.l	a0,d2
.findend	tst.b	(a0)+
	bne.s	.findend
	move.l	a0,d3
	sub.l	d2,d3
	subq	#1,d3
	Call	Dos,Write
	rts

NoInst	lea	NoInst.text(pc),a0
	bra.s	WriteIt
Got1.4plus	bsr.s	NoInst
	lea	Got1.4.text(PC),A0
	bra.s	WriteIt
Got1.0or1	bsr.s	NoInst
	lea	Got1.1.text(PC),A0
	bra.s	WriteIt
NoWB	bsr.s	NoInst
	lea	NoWB.text(PC),A0
	bra.s	WriteIt

Start	OpenLib	Intuition
	move.l	Base_Intuition(a5),a6
	move.w	LIB_VERSION(a6),d0
	cmp.w	#34,d0
	bgt.s	Got1.4plus
	cmp.w	#33,d0
	blt.s	Got1.0or1

	Call	Intuition,OpenWorkBench
	move.l	sc_FirstWindow(a0),a0

WBWindowFind	btst	#1,wd_Flags(a0)
	bne.s	WindowFound
	move.l	(a0),d0
	beq.s	NoWB
	move.l	d0,a0
	bra.s	WBWindowFind

WindowFound	move.l	wd_RPort(a0),a2
	move.l	rp_Font(a2),a2
	move.w	tf_YSize(a2),FontYSize(a5)
	move.w	tf_XSize(a2),FontXSize(a5)
	move.w	d5,FontSize(a5)

	lea	wd_MenuStrip(a0),a3

	move.w	#300,d7
Check4Menu	move.l	(a3),d0
	bne.s	MenuThere
	moveq	#10,d1
	Call	Dos,Delay
	dbf	d7,Check4Menu
	bra	NoWB

MenuThere	move.l	d0,a1

	lea	MenuData(pc),A0
	move.w	(a0)+,d1		Y Position
	move.w	FontXSize(a5),d5

	bsr.s	MenuChange
	bsr.s	MenuChange
	bsr.s	MenuChange	

	movem.l	(a0)+,d0-d1
	movem.w	(a0)+,d3/d6-d7

	moveq	#6,d2
	bsr.s	ChangeItems
	moveq	#2,d2
	bsr.s	ChangeItems
	moveq	#5,d2
	bsr.s	ChangeItems

Installed	lea	Inst.text(PC),A0
	bra	WriteIt

MenuChange	movem.w	(a0)+,d0/d2/d7
	mulu.w	d5,d0
	mulu.w	d5,d2
	mulu.w	d5,d7
	movem.w	d0-d2/d6,mu_LeftEdge(a1)
	move.w	d7,mu_BeatX(a1)		Item Width	= D5
	lea	mu_SIZEOF(a1),a1
	rts

;------------------------------------------------------------------------

ChangeItems	moveq	#0,d4	Set YPos to zero
	move.b	(a0)+,d5	Get Width (number of chars)
	mulu.w	FontXSize(a5),d5	Fix Width (number of pixels)
	addq	#4,d5	Give 4 more pixels

	subq	#1,d2
	move.w	d2,-(a7)

ChangeMI	movem.w	d3-d7,mi_LeftEdge(a1)
	move.b	(A0)+,mi_Command(a1)
	add.w	d6,d4	Increment Y-Position
	lea	mi_SIZEOF(a1),a1	Increment Address
	dbf	d2,ChangeMI

	move.w	(a7)+,d2
ChangeMT	movem.l	d0-d1,(a1)	TextData
	lea	it_SIZEOF(a1),a1	Increment Address
	dbf	d2,ChangeMT
	rts

;-----------------------------------------------------------------------

MenuData	DC.W	$0000	Y-Position	D1

MenuData2	DC.W	$01,$0C,$12	D0/D2/D7
	DC.W	$0F,$07,$14	ditto
	DC.W	$18,$0A,$13	ditto

TextData	DC.B	$00,$01,$01	Colors, Mode		D0
	EVEN
	DC.W	$0008,$0001	X-Position, Y-Position	D1
	
ItemData	DC.W	$0000	X-Position	D3
	DC.W	$000A	Height	D6
	DC.W	$0056	Flags	D7

	DC.B	$11,"OWCRIX"
	DC.B	$13,"TF"
	DC.B	$12,"KEDSV"
	EVEN

Main.text	DC.B	"EMenu 34.3 ©1992 Ian Einman - ",0

Inst.text	DC.B	"EMenu installed.",10,0
NoInst.text	DC.B	"EMenu not installed.",10,0
Got1.4.text	DC.B	10,27,"[3mWorkbench 1.4 and above do not require ",27,"[1mEMenu.",27,"[0m",10,10,0
Got1.1.text	DC.B	10,27,"[3mWorkbench 1.1 and below not sufficient to run ",27,"[1mEMenu.",27,"[0m",10,10,0
NoWB.text	DC.B	10,27,"[3mWorkbench must be loaded before ",27,"[1mEMenu ",27,"[0m",27,"[3mcan be installed.",27,"[0m",10,10,0
