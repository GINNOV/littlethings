;	Remove the semi-colon behind the AUTO below to put it to write mode.
;	A file length of 0 will indicate an error (ie. not an "SNT!" module)
;	Depacker routines taken from the replayer, Convertion routines
;	by Robster 1993   -  This source will depack "SNT!" type modules

WORKSPACE	= $400000

;	AUTO	j\wb\WORKSPACE\a1\

	lea	WORKSPACE,a1
	lea	Module(pc),a5
	cmp.l	#"SNT!",(a5)
	bne	End

	moveq	#0,d1
	move.l	#270,d0
ClearLp:move.l	d1,(a1)+
	dbf	d0,ClearLp

	lea	WORKSPACE,a1
	move.l	#"Name",(a1)

	lea	8(a5),a0
	lea	20(a1),a1
	moveq	#30,d0
MoveLp1:lea	22(a1),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d0,MoveLp1
	move.l	#129,d0
MoveLp2:move.b	(a0)+,(a1)+
	dbf	d0,MoveLp2
	move.l	#"M.K.",(a1)+

;--------------------------------------;

	move.l	4(a5),a2
	add.l	a5,a2
	lea	770(a5),a5
	lea	PerTble(pc),a3
	lea	Last0(pc),a0
ChanlLp:cmp.l	a5,a2
	beq	PattFin

	move.l	#0,(a1)
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.b	(a5),d6
	bpl.s	pr_playchannel1
	btst	#6,d6
	bne.s	pr_playchannel0
	subq.l	#2,a5				;Nocmd
	bra.s	pr_playchannelend
pr_playchannel0:				;last
	subq.l	#2,a5
	move.b	(a0),d0
	move.b	1(a0),d1
	move.w	2(a0),d2
	bra.s	pr_playchanneljump
pr_playchannel1:				;Normal
	moveq	#$f,d0
	and.b	1(a5),d0
	move.b	d0,2(a0)
	move.b	2(a5),3(a0)
	move.w	2(a0),d2

	moveq	#1,d0
	and.b	(a5),d0
	move.b	1(a5),d1
	lsr.b	#3,d1
	bclr	#0,d1
	or.b	d1,d0
	move.b	d0,(a0)

	move.b	(a5),d1
	lsr.b	#1,d1
	move.b	d1,1(a0)

pr_playchanneljump:

	move.w	d2,2(a1)
	move.b	d0,d2
	and.b	#$f0,d0
	or.b	d0,(a1)
	lsl.b	#4,d2
	or.b	d2,2(a1)

	subq.b	#1,d1
	bmi	NPeriod
	lsl.b	#1,d1
	move.w	(a3,d1),d1
	or.w	d1,(a1)
NPeriod:

pr_playchannelend:
	addq.l	#4,a1
	addq.l	#3,a5
	addq.l	#4,a0
	cmp.l	#LastE,a0
	bne	ChanlLp
	lea	Last0(pc),a0
	bra	ChanlLp

PattFin:cmp.l	#ModuleEnd,a2
	beq	End
	move.b	(a2)+,(a1)+
	bra	PattFin

End:	rts

;--------------------------------------;

Last0	dc.b	0
	dc.b	0
	dc.w	0
Last1	dc.b	0
	dc.b	0
	dc.w	0
Last2	dc.b	0
	dc.b	0
	dc.w	0
Last3	dc.b	0
	dc.b	0
	dc.w	0
LastE

;Periodtable for Tuning 0, Normal
PerTble:dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113

Module:	incbin	"DH1:SNT!Module"
ModuleEnd:

