
		incdir		sys:include/
		include		exec/exec.i
		include		exec/exec_lib.i
		include		dos/dos.i
		include		dos/dos_lib.i

		rsreset
myio_Msg	rs.b		MN_SIZE			Message header
myio_Name	rs.b		1			-> Task Name
myio_String	rs.l		1			-> string
myio_SIZE	rs.b		0			size of IO Request

; Start by opening required libraries
		
Start		lea		dosname,a1
		moveq.l		#36,d0			at least WB2
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq		Error1

; Get a port for communication

		CALLEXEC	CreateMsgPort
		move.l		d0,MyPort
		beq		Error2

; Generate and store signal mask for this port

		move.l		d0,a1
		moveq.l		#0,d0
		moveq.l		#1,d1
		move.b		MP_SIGBIT(a1),d0
		asl.l		d0,d1
		move.l		d1,PortSigMask

; Make the port public

		move.l		#PortName,LN_NAME(a1)
		CALLEXEC	AddPort

; get an IO Request

		move.l		MyPort,a0
		move.l		#myio_SIZE,d0
		CALLEXEC	CreateIORequest
		move.l		d0,IORequest
		beq		Error1

; Wait for Messages or user to press Ctrl-C

Sleepy		move.l		PortSigMask,d0
		or.l		#$1000,d0		Ctrl-C sig mask
		CALLEXEC	Wait

; See if a Message has awoken us

		move.l		PortSigMask,d1
		and.l		d0,d1
		bne		NextMsg

; See if Ctrl-C awoke us, if not we'll go back to sleep!

		move.l		#$1000,d1
		and.l		d0,d1
		beq		Sleepy
		bra		WannaQuit

;--------------------------------------------------------------------------

; Was a Message, get it from the Port

NextMsg		move.l		MyPort,a0
		CALLEXEC	GetMsg
		tst.l		d0
		beq		Sleepy

; Got the Message, deal with it!

		move.l		d0,Received
		bsr		HandleMsg

; Now reply it and loop for more!

		move.l		Received,a1
		CALLEXEC	ReplyMsg
		bra		NextMsg

;--------------------------------------------------------------------------

; Wow, the user wants us to go away! Remove Port from Public list.

WannaQuit	move.l		MyPort,a1
		CALLEXEC	RemPort

; Reply all outstanding Messages

ByeMsg		move.l		MyPort,a0
		CALLEXEC	GetMsg
		tst.l		d0
		beq		AllGone
		
		move.l		d0,a1
		CALLEXEC	ReplyMsg
		bra		ByeMsg

; Free the IO Request

AllGone		move.l		IORequest,a0
		CALLEXEC	DeleteIORequest

; Free the port

Error2		move.l		MyPort,a0
		CALLEXEC	DeleteMsgPort

; Close dos library

Error1		move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary

; And exit, we're not wanted any more!

Error		moveq.l		#0,d0
		rts

;--------------------------------------------------------------------------

; Here is the routine that deals with received messages.

HandleMsg	move.l		Received,a0
		lea		myio_Name(a0),a0

; print details supplied by calling Task

		move.l		a0,d2
		move.l		#ourtext,d1
		CALLDOS		VPrintf

; thats it, lets go home!

		rts
		
;--------------------------------------------------------------------------

; Data section

dosname		dc.b		'dos.library',0
		even
_DOSBase	dc.l		0

MyPort		dc.l		0

PortName	dc.b		'ACC Global Port',0
		even

PortSigMask	dc.l		0

IORequest	dc.l		0

Received	dc.l		0

ourtext		dc.b		"Task '%s' says '%s'.",$0a,0
		even
		