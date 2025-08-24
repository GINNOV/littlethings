;	Remove the semi-colon behind the AUTO below to put it to write mode.
;	Convertion routines by Robster 1994
;	This source will depack Kefrens type modules

WORKSPACE	= $1a0000

	AUTO	j\wb\WORKSPACE\a1\

	lea	Module,a0
	lea	951(a0),a1
	moveq	#0,d1
	moveq	#127,d0

KFInit1:move.b	(a1)+,d2
	cmp.b	d1,d2
	bls	KFInit2
	move.b	d2,d1
KFInit2:dbf	d0,KFInit1
	addq.w	#1,d1
	move.l	a0,a2
	mulu	#768,d1
	add.l	#1084,a2
	add.l	d1,a2

	lea	WORKSPACE+1080,a1
	move.l	#"M.K.",(a1)+

	lea	Module,a0
	lea	1084(a0),a0

KFLoop3:cmp.l	a0,a2
	beq	KefrEnd
	move.l	#0,(a1)
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2

	move.b	1(a0),d2
	and.b	#$f,d2
	lsl.w	#8,d2
	move.b	2(a0),d2

	move.b	(a0),d1
	and.b	#%111111,d1

	move.b	(a0),d0
	lsr.b	#2,d0
	and.b	#%110000,d0
	move.b	1(a0),d3
	lsr.b	#4,d3
	or.b	d3,d0

	move.w	d2,2(a1)

	lea	PerTble(pc),a3
	sub.b	#1,d1
	bmi	NoPriod
	add.w	d1,d1
	move.w	(a3,d1),d1
	move.w	d1,(a1)

NoPriod:move.b	d0,d1
	and.b	#$f0,d0
	or.b	d0,(a1)
	lsl.b	#4,d1
	or.b	d1,2(a1)

	addq.l	#3,a0
	addq.l	#4,a1
	bra	KFLoop3

KefrEnd:rts

;Periodtable for Tuning 0, Normal
PerTble:dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113

module	incbin	"dh1:thing"

	END

KefFormat
~~~~~~~~~
	HiN| OFFSET|LowN|   EFFECT
	%00 0000 00 0000 0000 00000000
	|          |         |        |

ProFormat
~~~~~~~~~
	 _____byte 1_____   byte2_    _____byte 3_____   byte4_
	/                \ /      \  /                \ /      \
	0000          0000-00000000  0000          0000-00000000

	Upper four    12 bits for    Lower four    Effect command.
	bits of sam-  note period.   bits of sam-
	ple number.                  ple number.

