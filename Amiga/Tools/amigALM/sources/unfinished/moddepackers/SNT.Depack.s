;	Remove the semi-colon behind the AUTO below to put it to write mode.
;	Depacker routines taken from the replayer, Convertion routines
;	by Robster 1993   -  This source will depack "SNT." type modules

;	AUTO	J\WB\PR_Data\PR_End\

	lea	PR_Data(pc),a0
	cmp.l	#"SNT.",1080(a0)
	bne	NotSNT

	move.l	#"M.K.",1080(a0)

	lea	952(a0),a1
	moveq	#0,d1
	moveq	#127,d0
PR_Init1:
	move.b	(a1)+,d2
	cmp.b	d1,d2
	bls	PR_Init2
	move.b	d2,d1
PR_Init2:
	dbf	d0,PR_Init1
	addq.w	#1,d1
	move.l	a0,a2
	mulu	#1024,d1
	add.l	#1084,a2
	add.l	d1,a2

	lea	1084(a0),a0

SNTLoop:cmp.b	#$d,2(a0)
	bne.s	PR_Init3
	moveq	#0,d0
	move.b	3(a0),d0
	divu	#10,d0
	move.b	d0,d1
	swap	d0
	lsl.b	#4,d1
	add.b	d1,d0
	move.b	d0,3(a0)
PR_Init3:

	moveq	#0,d0
	move.b	(a0),d0
	and.b	#%1111,d0
	lsl.b	#4,d0
	or.b	d0,2(a0)

	move.b	1(a0),d0
	and.w	#%1111<<12,(a0)
	subq.b	#1,d0
	bmi	NoPeriod
	add.w	d0,d0
	lea	PerTble(pc),a1
	add.l	d0,a1
	move.w	(a1),d0
	or.w	d0,(a0)

NoPeriod:
	addq.l	#4,a0
	cmp.l	a2,a0
	bne	SNTLoop

NotSNT:	rts

;Periodtable for Tuning 0, Normal
PerTble:dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113

PR_Data:incbin	"DH1:SNT.Module"
PR_End:

