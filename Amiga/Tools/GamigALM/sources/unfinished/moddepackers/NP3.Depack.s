;	Remove the semi-colon before the AUTO below to put it to write mode.
;	The workspace should be previously cleared with zeros.
;	Depacker and convertion routines by Robster 1993
;	-  This source will depack "NoisePacker 3.0" type modules

;	AUTO	j\wb\WORKSPACE\a1\

WORKSPACE	= $180000

	move.l	Module(pc),a0
	move.l	a0,a1
	lea	np_Pos(pc),a2
	moveq	#0,d0
	moveq	#3,d1
OffstLp	move.w	(a0)+,d0
	add.l	d0,a1
	move.l	a1,(a2)+
	dbf	d1,OffstLp

	move.l	WorkSpc(pc),a1
	lea	42(a1),a1
	move.l	np_Pos(pc),a2
	subq.l	#4,a2
SamLoop	move.w	(a0),2(a1)
	move.w	6(a0),(a1)
	move.w	14(a0),4(a1)
	move.w	12(a0),6(a1)
	lea	16(a0),a0
	lea	30(a1),a1
	cmp.l	a0,a2
	bne	SamLoop

	move.l	np_Pos(pc),a0
	move.l	np_Trck(pc),a2
	move.l	WorkSpc(pc),a1
	lea	950(a1),a1

	move.l	a2,d0
	sub.l	a0,d0
	lsr.w	#1,d0
	move.b	d0,(a1)+
	move.b	#127,(a1)+
MovePat	move.w	(a0)+,d0
	lsr.w	#3,d0
	move.b	d0,(a1)+
	cmp.l	a0,a2
	bne	MovePat

	move.l	a2,a0
	move.l	WorkSpc(pc),a1
	lea	1080(a1),a1
	move.l	#"M.K.",(a1)+

	move.l	np_Trck(pc),a0
	move.l	a1,a3
	move.l	np_PDat(pc),a2
	moveq	#12,d6
	moveq	#0,d5

PattnLp	cmp.l	a0,a2
	beq	MveSmpl
	moveq	#0,d0
	move.w	(a0)+,d0
	lea	(a2,d0),a4
	lea	(a3,d5),a1
	lea	(a1,d6),a1

	moveq	#63,d7
	bsr	DCdTrck

	subq.b	#4,d6
	bpl	PattnLp
	moveq	#12,d6
	add.l	#1024,d5
	bra	PattnLp

DCdTrck	tst.b	d7
	bpl	DoPattn
	rts
DoPattn	tst.b	(a4)
	bpl	DataOK
	moveq	#0,d0
	move.b	(a4)+,d0
	neg.b	d0
	sub.b	d0,d7
	subq.b	#1,d0
MinLoop	lea	16(a1),a1
	dbf	d0,MinLoop
	bra	DCdTrck

DataOK	moveq	#0,d2
	move.b	1(a4),d2
	and.b	#$f,d2
	cmp.b	#$e,d2
	beq	CmdE
	cmp.b	#$d,d2
	beq	CmdD
	cmp.b	#$b,d2
	beq	CmdB
	cmp.b	#8,d2
	beq	Cmd8
	cmp.b	#7,d2
	beq	Cmd7
	cmp.b	#5,d2
	beq	Cmd5
	cmp.b	#6,d2
	beq	Cmd6

	lsl.w	#8,d2
	move.b	2(a4),d2

ChngCmd	moveq	#0,d0
	move.b	(a4),d0
	and.b	#1,d0
	lsl.b	#4,d0
	move.b	1(a4),d1
	lsr.b	#4,d1
	or.b	d1,d0

	moveq	#0,d1
	move.b	(a4),d1
	lsr.b	#1,d1

	move.l	#0,(a1)
	move.w	d2,2(a1)

	sub.b	#1,d1
	bmi	NoPriod
	add.w	d1,d1
	lea	PerTble(pc),a5
	move.w	(a5,d1),d1
	move.w	d1,(a1)

NoPriod	move.b	d0,d1
	and.b	#$f0,d0
	or.b	d0,(a1)
	lsl.b	#4,d1
	or.b	d1,2(a1)

	subq.b	#1,d7
	addq.l	#3,a4
	lea	16(a1),a1
	bra	DCdTrck

CmdE	lsl.w	#8,d2
	move.b	2(a4),d2
	lsr.b	#1,d2
	bra	ChngCmd

CmdD	lsl.w	#8,d2
	moveq	#0,d7
	move.b	d7,d2
	bra	ChngCmd

CmdB	lsl.w	#8,d2
	move.b	2(a4),d2
	lsr.b	#1,d2
	addq.b	#2,d2
	bra	ChngCmd

Cmd8	move.b	#0,d2
	lsl.w	#8,d2
	move.b	2(a4),d2
	bra	ChngCmd

Cmd7	move.b	#$a,d2
Cmd5
Cmd6	lsl.w	#8,d2
	move.b	2(a4),d2
	tst.b	d2
	bpl	ChngCmd
	neg.b	d2
	bra	ChngCmd

MveSmpl	lea	(a3,d5),a1
	move.l	np_Smpl(pc),a0
	move.l	Module(pc),a2
	add.l	ModSize(pc),a2
MveLoop	cmp.l	a0,a2
	beq	End
	move.b	(a0)+,(a1)+
	bra	MveLoop
End	rts

;Periodtable for Tuning 0, Normal
PerTble:dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113

Module	dc.l	np_Data
ModSize	dc.l	np_DataEnd-np_Data
WorkSpc	dc.l	WORKSPACE
np_Pos	dc.l	0
np_Trck	dc.l	0
np_PDat	dc.l	0
np_Smpl	dc.l	0

np_Data	incbin	"DH1:NP3.Module"
np_DataEnd
	END


NoisePacker data format:

   NOTE  SAMPLE     EFFECT
|       |      |             |
.0000000.0 0000.0000 00000000.
|  1st    |   2nd   |  3rd   |

