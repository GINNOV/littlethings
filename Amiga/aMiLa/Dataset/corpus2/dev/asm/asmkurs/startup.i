	include	"exec/exec.i"
	include	"libraries/exec_lib.i"
	include	"libraries/dosextens.i"

Rep:	movem.l	d0/a0,-(sp)		;save initial values
	clr.l	returnMsg
	sub.l	a1,a1
	move.l  $4.w,a6
	jsr	_LVOFindTask(a6)	;find us
	move.l	d0,a4
	tst.l	pr_CLI(a4)
	beq.s	fromWorkbench
	movem.l	(sp)+,d0/a0		;restore regs
	bra	end_startup		;and run the user prog
fromWorkbench:
	lea	pr_MsgPort(a4),a0
	move.l  $4.w,a6
	jsr	_LVOWaitPort(A6)	;wait for a message
	lea	pr_MsgPort(a4),a0
	jsr	_LVOGetMsg(A6)		;then get it
	move.l	d0,returnMsg		;save it for later reply
	movem.l	(sp)+,d0/a0		;restore
end_startup:
	bsr.s	Init			;call our program
	move.l	d0,-(sp)		;save it
	tst.l	returnMsg
	beq.s	exitToDOS		;if I was a CLI
	move.l	$4.w,a6
        jsr	_LVOForbid(a6)
	move.l	returnMsg(pc),a1
	jsr	_LVOPermit(a6)
exitToDOS:
	move.l	(sp)+,d0		;exit code
	rts

returnMsg:	dc.l	0

************************************************************************