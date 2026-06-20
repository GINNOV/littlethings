
		incdir		sys:include/
		include		exec/exec.i
		include		exec/exec_lib.i
		include		dos/dos.i
		include		dos/dos_lib.i

		rsreset
myio_Msg	rs.b		MN_SIZE		standard message structure
myio_Name	rs.l		1		->data to process
myio_String	rs.l		1
myio_SIZEOF	rs.b		0

; get a port

Start		CALLEXEC	CreateMsgPort
		move.l		d0,d6			d6 = our port
		beq		Error1

; Build mask for this ports signal

		move.l		d0,a0
		moveq.l		#1,d5
		moveq.l		#0,d1
		move.b		MP_SIGBIT(a0),d1
		asl.l		d1,d5			d5 = mask

; Now get an IO structure

		move.l		d6,a0			ReplyPort
		move.l		#myio_SIZEOF,d0		size
		CALLEXEC	CreateIORequest		make it!
		move.l		d0,d4			save pointer
		beq		Error2

; Tell global listener that we are here

; To be safe you must call Forbid() while you find the port and put a message
;to it, otherwise the port may be relinquished between the time when you find
;it and then put the message!

		CALLEXEC	Forbid

		lea		HostPort(pc),a1
		CALLEXEC	FindPort
		move.l		d0,d7			d7 = MMSoftware
		bne.s		FoundIt

		CALLEXEC	Permit
		bra.s		Error3

FoundIt		move.l		d4,a1
		move.l		#Msg1,myio_String(a1)	set name
		move.l		#MyName,myio_Name(a1)	set function

		move.l		d7,a0			Port
		CALLEXEC	PutMsg			send it

		CALLEXEC	Permit

; Wait for global listener to answer us

WaitLoop	move.l		d5,d0			signal set
		CALLEXEC	Wait

; Get the message

		move.l		d6,a0
		CALLEXEC	GetMsg
		tst.l		d0
		beq.s		WaitLoop

; Make sure this was the reply, if not keep waiting

		move.l		d0,a0
		cmp.b		#NT_REPLYMSG,LN_TYPE(a0)
		bne.s		WaitLoop

; Free the IO request
		
Error3		move.l		d4,a0
		CALLEXEC	DeleteIORequest

; Free the port

Error2		move.l		d6,a0
		CALLEXEC	DeleteMsgPort

; And exit

Error1		moveq.l		#0,d0
		rts

HostPort	dc.b		'ACC Global Port',0
		even

Msg1		dc.b		'Hi there Task, not so lonely now!',0
		even

MyName		dc.b		'Port Tester',0
		even
		
