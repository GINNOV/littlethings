
* Include this at the front of your program
* after any other includes
* note that this needs exec/exec_lib.i


ciaapra	=	$bfe001
dma	=	$dff000

	incdir	"sys:include/"
	include	"exec/exec_lib.i"
	include	"exec/exec.i"
	include	"libraries/dos_lib.i"
	include	"libraries/dos.i"
	include	"libraries/dosextens.i"


	IFND	EXEC_EXEC_I
	include	"exec/exec.i"
	ENDC
	IFND	LIBRARIES_DOSEXTENS_I
	include	"libraries/dosextens.i
	ENDC


	movem.l	d0/a0,-(sp)		save initial values
	clr.l	returnMsg

	sub.l	a1,a1
	CALLEXEC FindTask		find us
	move.l	d0,a4

	tst.l	pr_CLI(a4)
	beq.s	fromWorkbench

* we were called from the CLI
	bra	end_startup		and run the user prog

* we were called from the Workbench
fromWorkbench
	lea	pr_MsgPort(a4),a0
	CALLEXEC WaitPort		wait for a message
	lea	pr_MsgPort(a4),a0
	CALLEXEC GetMsg			then get it
	move.l	d0,returnMsg		save it for later reply

* Open Dos library and a con window

end_startup	lea	DOSNAME,a1
	moveq.l	#0,d0
	CALLEXEC	OpenLibrary
	move.l	d0,_DOSBase
	tst.l	d0
	bne.s	_ok
	rts
_ok	move.l	#con_window,d1
	move.l	#MODE_OLDFILE,d2
	CALLDOS	Open
	move.l	d0,window.ptr
	movem.l	(sp)+,d0/a0		restore
	bsr	main			call our program

* returns to here with exit code in d0
	move.l	d0,-(sp)		save it

	move.l	window.ptr,d1
	CALLDOS	Close
	move.l	_DOSBase,a1
	CALLEXEC	CloseLibrary
	tst.l	returnMsg
	beq.s	exitToDOS		if I was a CLI

	CALLEXEC Forbid
	move.l	returnMsg(pc),a1
	CALLEXEC ReplyMsg

exitToDOS
	move.l	(sp)+,d0		exit code
	rts

* startup code variable
returnMsg	dc.l	0
_IntuitionBase  dc.l	0
_DOSBase	dc.l	0
window.ptr	dc.l	0
con_window	dc.b	'con:0/0/600/200/Tutorial_M.Meany',0
	even
DOSNAME	dc.b	'dos.library',0
	even
INTNAME	dc.b	'intuition.library',0
	even
* the program starts here

