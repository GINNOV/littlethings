
;INCLUDE THIS FILE FOR COMBI WB/CLI STARTUP CODE!
;USES NO RELOCS...
	LIST
* COMBI-START V1 PK/SM *
	NOLIST
pr_MsgPort   = $5c
pr_CLI       = $ac
_LVOForbid   = -132
_LVOFindTask = -294
_LVOGetMsg   = -372
_LVOReplyMsg = -378
_LVOWaitPort = -384

	clr.l		-(sp)			;Returnmsg on stack
	sub.l		a1,a1			;clear a1
	move.l	4.w,a6
	jsr		_LVOFindTask(a6)	;find task - us
	move.l		d0,a4			;process in a4

	tst.l		pr_CLI(a4)		;test if from CLI
	bne.s		end_startup		;run if cli....

;Workbench start up...
	lea		pr_MsgPort(a4),a0	;tasks message port in a0
	jsr		_LVOWaitPort(a6)	;wait for workbench message
	lea		pr_MsgPort(a4),a0	;tasks message port in a0
	jsr		_LVOGetMsg(a6)		;get workbench message
	move.l		d0,(sp)			;save it for later reply

end_startup
	bsr.s		_main			;call our program

	tst.l		(sp)			;test if from workbench
	beq.s		exitToDOS		;if I was a CLI
	move.l	4.w,a6
	jsr		_LVOForbid(a6)		;forbid multitasking
	move.l		(sp),a1			;get workbench message
	jsr		_LVOReplyMsg(a6)	;reply workbench message
exitToDOS
	addq.l	#4,sp				;unstack returnmsg
	moveq		#0,d0			;flag no error
	rts							;Quit our program

_main	
