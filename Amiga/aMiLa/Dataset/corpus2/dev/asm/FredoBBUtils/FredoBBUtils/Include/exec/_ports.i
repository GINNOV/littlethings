_CreatePort:
	movem.l	d2/a2-a3/a6,-(sp)
	move	d0,d2
	move.l	a0,a2
	move.l	4.w,a6
	move.l	#MP_SIZE,d0
	move.l	#$10001,d1
	jsr	-198(a6)
	tst.l	d0
	beq.s	.end
	move.l	d0,a3
	moveq	#-1,d0
	jsr	-330(a6)	;AllocSignal()
	tst.b	d0
	bpl.s	.sig_ok
	move.l	a3,a1
	move.l	#MP_SIZE,d0
	jsr	-210(a6)
	clr.l	d0
	bra.s	.end
.sig_ok
	move.l	a2,LN_NAME(a3)
	move.b	d2,LN_PRI(a3)
	move.b	#NT_MSGPORT,LN_TYPE(a3)
	move.b	#PA_SIGNAL,MP_FLAGS(a3)
	move.b	d0,MP_SIGBIT(a3)
	move.l	276(a6),MP_SIGTASK(a3)	;ThisTask
	lea	MP_MSGLIST(a3),a1
	NEWLIST	a1
	move.l	a2,d0
	beq.s	.no_name
	move.l	a3,a1
	jsr	-390(a6)	;AddPort()
.no_name
	move.l	a3,d0
.end	movem.l	(sp)+,d2/a2-a3/a6
	rts

_DeletePort:
	movem.l	a2/a6,-(sp)
	move.l	a0,a2
	move.l	4.w,a6
	move.l	LN_NAME(a2),d0
	beq.s	.no_glob
	move.l	a2,a1
	jsr	-252(a6)	;Remove()
.no_glob
	move.b	MP_SIGBIT(a2),d0
	ext.w	d0
	ext.l	d0
	jsr	-336(a6)	;FreeSignal()
	move.l	#MP_SIZE,d0
	move.l	a2,a1
	jsr	-210(a6)
	movem.l	(sp)+,a2/a6
	rts
