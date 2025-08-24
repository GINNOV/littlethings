	SECTION	"Frantic - Sample Player",CODE_C

;--------------------------------------;

AllocMem	= -198
FreeMem		= -210
OpenDevice	= -444
CloseDevice	= -450

IntTime		= $180

Volume		= 64
Length		= 5888
Speed		= 214
Repeat		= 4116
RepeatLength	= 1536
;Repeat		= 0
;RepeatLength	= 2

;-------------------;

	IFNE	Repeat
SndLength	= Repeat+RepeatLength
	ELSE
SndLength	= Length
	ENDC

;--------------------------------------;

Start	bsr	AllcAud
	bne	End
	lea	$bfd000,a4
	lea	$dff000,a5
	move.l	#0,Data

Wait	btst	#6,$bfe001
	beq	PlaySnd
	btst	#2,$16(a5)
	bne	Wait
	move.w	#$0001,$96(a5)
	bsr	DAlcAud
End	moveq	#0,d0
	rts

;--------------------------------------;

CIAWait	move.w	#IntTime,d0
	move.b	d0,$400(a4)
	lsr.w	#8,d0
	move.b	d0,$500(a4)
.1	btst	#0,$d00(a4)
	beq.s	.1
	move.b	#$81,$d00(a4)
	rts

;--------------------------------------;

AllcAud	bsr	DAlcAud
	move.l	#272,d0
	move.l	#$10001,d1
	move.l	4.w,a6
	jsr	AllocMem(a6)
	move.l	d0,a2
	move.l	a2,AudAllc
	bne	.1
	bra	.4
.1	lea	8(a2),a3
	lea	AudData(pc),a4
	moveq	#127,d3
	moveq	#4,d4
	moveq	#4-1,d5
.2	move.l	a3,a1
	move.b	d3,9(a1)
	move.l	a4,34(a1)
	move.l	d4,38(a1)
	moveq	#0,d0
	moveq	#0,d1
	lea	AudName(pc),a0
	jsr	OpenDevice(a6)
	tst.l	d0
	bne.s	.3
	bset	d5,ChnlDat
.3	lea	68(a3),a3
	dbf	d5,.2
	moveq	#0,d0
	cmp.b	#%1111,ChnlDat
	beq.s	.5
.4	moveq	#-1,d0
.5	rts

;--------------------------------------;

DAlcAud	tst.l	AudAllc
	beq.s	.3
	move.l	4.w,a6
	move.l	AudAllc(pc),a4
	lea	8(a4),a3
	moveq	#3,d5
.1	btst	d5,ChnlDat
	beq.s	.2
	move.l	a3,a1
	jsr	CloseDevice(a6)
.2	lea	68(a3),a3
	dbf	d5,.1
	move.l	a4,a1
	move.l	#272,d0
	jsr	FreeMem(a6)
	moveq	#0,d0
	move.l	d0,AudAllc
.3	rts

;--------------------------------------;

PlaySnd	move.w	#$0001,$96(a5)
	move.l	#Data,$a0(a5)		;Address
	move.w	#SndLength/2,$a4(a5)	;Length/2
	move.w	#Speed,$a6(a5)		;Speed
	move.w	#Volume,$a8(a5)		;Volume
	move.w	#$8001,$96(a5)		;Start DMA
	bsr	CIAWait

	move.l	#Data+Repeat,$a0(a5)	;Address
	move.w	#RepeatLength/2,$a4(a5)	;Length/2
	bra	Wait

;--------------------------------------;

ChnlDat	dc.w	0
AudAllc	dc.l	0
AudData	dc.b	1,2,4,8
AudName	dc.b	"audio.device",0,0
Data	incbin	"DH1:WormHam"

