
	move.l	#50,d0

sqr:
	movem.l	d1-d2,-(a7)
	moveq	#-1,d1
loop:
	addq.l	#1,d1
	move.l	d1,d2
	mulu	d2,d2
	cmp.l	d2,d0
	bgt.s	loop
	beq.s	noround
	subq.w	#1,d1
noround:
	move.l	d1,d0
	movem.l	(a7)+,d1-d2
	rts
