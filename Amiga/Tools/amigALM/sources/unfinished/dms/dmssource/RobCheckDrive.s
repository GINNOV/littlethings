	SECTION	"Program",CODE_C

	move.l	4.w,a6
	lea	BtBBase(pc),a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,BtBBase
	move.l	d0,a6

	lea	BtHndlr(pc),a0
	jsr	-30(a6)

	lea	Dat1(pc),a0
	lea	Dat2(pc),a1
	jsr	-48(a6)

	moveq	#0,d0
	lea	BootBlk(pc),a0
	jsr	-60(a6)

	lea	BootBlk(pc),a0
	lea	BtSttus(pc),a1
	jsr	-42(a6)
	rts

Dat1	dcb.b	50,0
Dat2	dcb.b	50,0
BtSttus	dc.l	0

BootBlk	dcb.b	1024,0

BtBBase	dc.b	"Bootblock.library",0
BtHndlr	dc.b	"L:Bootblock.brainfile",0

