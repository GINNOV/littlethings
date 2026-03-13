	movem.l	d0/a0,-(a7)

	sub.l	a1,a1
	move.l	4.w,a6
	jsr	FindTask(a6)
	move.l	d0,a4

	tst.l	172(a4)
	bne.s	FromCLI

	lea	92(a4),a0
	move.l	4.w,a6
	jsr	WaitPort(A6)
	lea	92(a4),a0
	jsr	GetMsg(A6)
	move.l	d0,RtrnMsg

FromCLI	movem.l	(a7)+,d0/a0
	bsr.s	_Main

	move.l	d0,-(a7)
	tst.l	RtrnMsg
	beq.s	ExToDOS

	move.l	4.w,a6
	jsr	Forbid(a6)
	move.l	RtrnMsg(pc),a1
	jsr	ReplyMsg(a6)

ExToDOS	move.l	(a7)+,d0
	rts

RtrnMsg	dc.l	0
_Main
