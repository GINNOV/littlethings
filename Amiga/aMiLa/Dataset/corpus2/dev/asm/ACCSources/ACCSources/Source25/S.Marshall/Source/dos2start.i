****************************************************************************	
*
*	Startup Code for general use on KickStart V2.04 machines.
*	Uses the new library routines to parse command line args.
*	This code is pure enough to be used in programs which will
*	be made resident.
*
*			Compiles with Devpac V3
*
*		By Steve Marshall. Code is Public domain.
*
****************************************************************************	

	include		"exec/exec.i"
	include		"dos/rdargs.i


	sub.l		a1,a1			;zero a1
	move.l		4.w,a6			;execbase
	jsr		_LVOFindTask(a6)	;find us
	move.l		d0,a3			;task address

	tst.l		pr_CLI(a3)		;test if from cli
	beq		fromWorkbench		;branch if not

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* we were called from the CLI
	bsr		OpenDOS			;open dos lib
	beq.s		exitToDOS		;branch on dos error
	
	moveq		#DOS_RDARGS,d1		;object type
	moveq		#0,d0			;no tags
	CALLDOS		AllocDosObject		;ask for readargs struct
	tst.l		d0			;test result
	beq.s		exitToDOS		;branch on error
	
	move.l		d0,-(sp)		;save result
	move.l		d0,a0			;RDArg struct
	move.l		#ExtHelp,RDA_ExtHelp(a0);extended help string
	move.l		#TEMPLATE,d1		;get arg template
	move.l		#ArgList,d2		;array for result
	move.l		d0,d3			;add of myrda
	jsr		_LVOReadArgs(a6)	;read args

argsdone	
	bsr		_main			;call our program

* returns to here with exit code in d0
	move.l		d0,d3			;save it

	move.l		(sp),d1			;get myrda
	CALLDOS		FreeArgs		;and free args
	
	moveq		#DOS_RDARGS,d1		;object type
	move.l		(sp)+,d2		;get myrda
	jsr		_LVOFreeDosObject(a6)	;and free it

	move.l		d3,d0			;exit code

exitToDOS
	rts

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

fromWorkbench
	lea		pr_MsgPort(a3),a0	;get process msg port
	jsr		_LVOWaitPort(a6)	;wait for a message
	
	lea		pr_MsgPort(a3),a0	;get process msg port
	jsr		_LVOGetMsg(a6)		;then get it
	move.l		d0,-(sp)		;save it for later reply

	bsr.s		OpenDOS			;open dos lib
	beq.s		exitToWBench		;branch on dos error
	
	bsr.s		_main			;call our program

* returns to here with exit code in d0
exitToWBench
	move.l		d0,d2			;save it

	CALLEXEC	 Forbid			;kill tasking
	move.l		(sp)+,a1		;get msg
	jsr		_LVOReplyMsg(a6)	;reply WBench msg

	move.l		d2,d0			;exit code
	rts					;end of prog (workbench)

;===========================================================================

OpenDOS
	moveq		#37,d0			;lib version 2.04
	lea		Dosname(pc),a1		;lib name
	CALLEXEC	OpenLibrary		;open dos
	move.l		d0,_DOSBase		;save dosbase
	rts					;end of OpenDOS
	
* startup code variable
_DOSBase
	dc.l		0

Dosname
	DOSNAME
	
* the program starts here
	even
_main
