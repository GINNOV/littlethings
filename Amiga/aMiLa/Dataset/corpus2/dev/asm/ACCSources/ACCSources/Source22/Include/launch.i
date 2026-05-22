* This piece of code detaches the program from the CLI and
* launches it as a separate process in its own right.

* Command line parameters now passed in normal way!


		section	Launcher,CODE


Launch		move.l	a0,_aARGV	save entry parameters
		move.l	d0,_aARGC

		sub.l	a1,a1
		CALLEXEC FindTask	find  this task
		move.l	d0,a4

		tst.l	172(a4)		check origins, pr_CLI
		beq	fromWorkbench	exit if from WB

; If we get this far we are from CLI. Copy command line for user.

		move.l	_aARGC,d0	size of cmd line
		move.l	#0,d1		any old memory will do
		CALLEXEC AllocMem	get memory
		tst.l	d0		test return
		beq	Abort_1		quit on error

		move.l	_aARGV,a0	source
		move.l	d0,_aARGV	save addr of copy
		move.l	d0,a1		destination
		move.l	_aARGC,d0	size
		CALLEXEC CopyMem	copy it

; continue with DE's launch code from here on in.

		move.l	4.w,a6		;ExecBase

		lea	LDos(pc),a1
		moveq	#0,d0
		jsr	_LVOOpenLibrary(a6)
		tst.l	d0		;got DOS lib?
		beq.s	Abort_1		;exit if so

		move.l	d0,a6		;DOS library base

		lea	Launch(pc),a4	;point to start of Launcher
		lea	-4(a4),a4	;point to 1st Segment in list
		move.l	(a4),d0		;get BCPL ptr to next

		move.l	d0,d3		;ptr to next segment for DOS call
		clr.l	(a4)		;unlink the segments (tut, tut)

		lea	LaunchName(pc),a0	;name of new process
		move.l	a0,d1			;goes here

		moveq	#0,d2		;process pri
		move.l	#4000,d4	;stack size

		jsr	_LVOCreateProc(a6)	;create process

		move.l	a6,a1
		move.l	4.w,a6
		jsr	_LVOCloseLibrary(a6)	;close DOS library

		moveq	#0,d0		;signal launched
		rts


* Come here if no DOS library (ouch! usually means a repair bill...)


Abort_1		moveq	#20,d0		;signal failed!
		rts			;(CLI returncode)

LDos		dc.b	"dos.library",0

LaunchName	dc.b	"my program",0	;change this to suit yourself!
		even

; Called from WorkBench, reply message and exit!

fromWorkbench
		lea	92(a4),a0		pr_MSGPORT
		CALLEXEC WaitPort		wait for a message
		lea	92(a4),a0		pr_MSGPORT
		CALLEXEC GetMsg			then get it
		move.l	d0,-(sp)		save it for later reply
		CALLEXEC Forbid			system does the Permit() L8R
		move.l	(sp)+,a1
		CALLEXEC ReplyMsg		reply the message
		rts				quit

		section	Program,CODE

		move.l	_aARGV,a0	a0->copy of command line
		move.l	_aARGC,d0	d0=it's length
		bsr	_yourMain	call users application

		move.l	d0,-(sp)	save DOS return address
		move.l	_aARGV,a1	address
		move.l	_aARGC,d0	size
		CALLEXEC FreeMem	release it
		move.l	(sp)+,d0	restore return value
		rts

_aARGV		dc.l	0
_aARGC		dc.l	0

* Your program goes here!

_yourMain

