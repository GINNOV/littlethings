
 * Memory Buffer addresses.
 *
 *  0  Startup Return Message
 *  4 Task address
 *  8 KILL NUMERICPAD Port
 * 12 NUMERICPAD Message
 * 16 pmcommand
 * 18 pmaction
 * 20 pmseconds
 * 24 pmmicros
 * 28 pmdata
 * 29 pmstatus
 *

	INCDIR	WORK:Include/

	INCLUDE	work:devpac/large.gs
	INCLUDE	misc/missing_keys.i

	lea	membuf(pc),a4

	suba.l	a1,a1
	move.l	4.w,a6
	jsr	_LVOFindTask(a6)
	tst.l	d0
	beq	exit
	move.l	d0,a5
	move.l	a5,4(a4)
	tst.l	pr_CLI(a5)		; Was this task started from CLI?
	bne.s	_main			; Yes.
	lea	pr_MsgPort(a5),a0	; No. From Workbench.
	jsr	_LVOWaitPort(a6)
	lea	pr_MsgPort(a5),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,(a4)			; D0 = A WBStartup Message.

_main

 * Set-Up a Message Port.

        jsr	_LVOForbid(a6)
        lea     portname(pc),a1
        jsr	_LVOFindPort(a6)
        tst.l   d0
	bne	exists
        moveq   #MP_SIZE,d0
        move.l  #MEMF_PUBLIC!MEMF_CLEAR,d1
        jsr	_LVOAllocMem(a6)
        move.l  d0,8(a4)
        beq	no_pmem
        move.l  d0,a0
        clr.l	(a0)				; LN_SUCC(a0)
        clr.l	LN_PRED(a0)
        move.b  #NT_MSGPORT,LN_TYPE(a0)
        clr.b	LN_PRI(a0)
        lea     portname(pc),a1
        move.l  a1,LN_NAME(a0)
        move.b  #PA_SIGNAL,MP_FLAGS(a0)
        move.l  4(a4),MP_SIGTASK(a0)
        moveq	#-1,d0
        jsr	_LVOAllocSignal(a6)
        move.b  d0,d5
        cmp.l	#-1,d0
        bne.s	ad_port
        jsr	_LVOPermit(a6)
	bra	fr_pmem
ad_port	move.l	8(a4),a1
        move.b  d5,MP_SIGBIT(a1)
        jsr	_LVOAddPort(a6)
        jsr	_LVOPermit(a6)

 * Set-Up the Message.

	moveq	#pm_SIZEOF,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	jsr	_LVOAllocMem(a6)
	move.l	d0,12(a4)
	beq	free_port
	move.l	d0,a0
	clr.l	(a0)				; LN_SUCC(a0)
	clr.l	LN_PRED(a0)
	move.b	#NT_MESSAGE,LN_TYPE(a0)
	clr.b	LN_PRI(a0)
	clr.l	LN_NAME(a0)
	move.l	8(a4),MN_REPLYPORT(a0)
	move.w	#pm_SIZEOF,MN_LENGTH(a0)

 * The start of NUMERICPAD Message data.

	move.w	#PMCOMMAND_USENUMERICPAD,pm_Command(a0)
	clr.b	pm_Status(a0)

	bra.s	send_msg

exists	jsr	_LVOPermit(a6)
        bra.s	quit

no_pmem	jsr	_LVOPermit(a6)
        bra.s	quit

send_msg
	bsr	find_port
	tst.l	d2
	beq.s	free_message

	move.l	d2,a0			; `NUMERICPAD Port'
	move.l	12(a4),a1
	jsr	_LVOPutMsg(a6)		; send a Message to `NUMERICPAD Port'
	jsr	_LVOPermit(a6)

	bsr	get_msg

 * You do not ReplyMsg() as you (this port) initiated the Message.

	bsr	find_port
	tst.l	d2
	beq.s	free_message

	move.l	d2,a0			; `NUMERICPAD Port'
	move.l	12(a4),a1
	move.w	#PMCOMMAND_GETSTATUS,pm_Command(a1)
	jsr	_LVOPutMsg(a6)		; send a Message to `NUMERICPAD Port'
	jsr	_LVOPermit(a6)

wait_l	bsr	get_msg

 * You do not ReplyMsg() as you (this port) initiated the Message.

	cmp.b	#255,pm_Status(a1)
	bne.s	wait_l


free_message
	move.l	12(a4),a1
	moveq	#pm_SIZEOF,d0
	jsr	_LVOFreeMem(a6)

free_port
	move.l	8(a4),a0
	tst.l	a0
        beq.s	quit
	move.l	4.w,a6
        tst.b	MP_SIGBIT(a0)
        beq.s	no_sig
        jsr	_LVOFreeSignal(a6)
no_sig	move.l	8(a4),a1
        jsr	_LVORemPort(a6)
fr_pmem	move.l	8(a4),a1
        moveq   #MP_SIZE,d0
	move.l	4.w,a6
        jsr	_LVOFreeMem(a6)

quit	move.l  #8000000,d0
        moveq	#MEMF_CHIP,d1
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.s	cleanup
	move.l	d0,a1
	move.l	#8000000,d0
	jsr	_LVOFreeMem(a6)
cleanup	tst.l	(a4)
	beq.s	exit			; Exit - Task was started from CLI.
	jsr	_LVOForbid(a6)
	move.l	(a4),a1			; Reply to the WB Startup Message and
	jsr	_LVOReplyMsg(a6)	; Exit - Task was started from WB.
exit	moveq	#0,d0
	rts


 * Sub-Routines.

find_port
	jsr	_LVOForbid(a6)
	lea	otherport(pc),a1
	jsr	_LVOFindPort(a6)	; Check if `NUMERICPAD Port' exists?
	move.l	d0,d2
	bne.s	fp_end
	jsr	_LVOPermit(a6)
fp_end	rts

get_msg	move.l	8(a4),a0
	jsr	_LVOWaitPort(a6)	; Wait for `NUMERICPAD Port' to reply
	move.l	8(a4),a0
	jsr	_LVOGetMsg(a6)		; get `NUMERICPAD Port' Message
	move.l	d0,a1
	move.w	pm_Command(a1),16(a4)
	move.w	pm_Action(a1),18(a4)
	move.l	pm_Seconds(a1),20(a4)
	move.l	pm_Micros(a1),24(a4)
	move.b	pm_Data(a1),28(a4)
	move.b	pm_Status(a1),29(a4)
	rts


 * String Variables.

int_name	dc.b	'intuition.library',0
dos_name	dc.b	'dos.library',0
icon_name       dc.b    'icon.library',0,0
portname        dc.b    'KILL NUMERICPAD Port',0,0
otherport	dc.b	'NUMERICPAD Port',0


 * Buffer Variables.

membuf		dcb.b	32,0