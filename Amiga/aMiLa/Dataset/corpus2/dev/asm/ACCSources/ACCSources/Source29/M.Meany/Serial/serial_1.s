
* Name		serial_1.s
* Function	send a mesage to serial device
* Programmer	M.Meany
* Assembler	Devpac III ( will assemble using Devpac II )
* Comments	It works!
*		Development of a NULL modem link-up of two Amigas

; Same as first beta code, but subroutines are used to open and close the
;serial device.

		incdir		sys:Include/
		include		exec/Exec.i
		include		exec/exec_lib.i
		include		devices/serial.i

; Start by opening a port

Main		bsr		OpenSer			open serial device
		tst.l		d0			ok?
		beq		.Error1			no, exit!
		
; Send a message down the wire :-)

		move.l		WriteReq,a1		a1-> IO request
		move.w		#CMD_WRITE,IO_COMMAND(a1) writing data
		move.l		#MsgLen,IO_LENGTH(a1)	number of bytes
		move.l		#Msg1,IO_DATA(a1)	address of data
		CALLEXEC	DoIO			send message

; finished with serial device, so close it!

		bsr		CloseSer		close serial device

; All Done so return

.Error1		moveq.l		#0,d0			no script errors
		rts

		****************************************
		*	  Open Serial Device	       *
		****************************************

OpenSer		lea		pname,a0		a0->port name
		moveq.l		#0,d0			priority
		bsr		CreatePort		get a port
		move.l		d0,AccPort		save pointer
		beq		.Error1			exit if no port

; Create an IO structure for use with the port

		move.l		d0,a0			a0->port
		move.l		#IOEXTSER_SIZE,d0	size of structure
		bsr		CreateExtIO		get structure
		move.l		d0,WriteReq		save address
		beq		.Error2

; Open the serial device

		lea		sername,a0		a0->device name
		moveq.l		#0,d0			unit number
		move.l		WriteReq,a1		a1->IO structure
		moveq.l		#0,d0			no flags
		CALLEXEC	OpenDevice		open serial device
		tst.l		d0			open OK?
		bne		.Error3			no, exit now!

		moveq.l		#1,d0			no errors
		rts					so return

; Release the IO structure

.Error3		move.l		WriteReq,a1		a1->IO structure
		bsr		DeleteExtIO		release it

; Free the port

.Error2		move.l		AccPort,a0		a0->Port
		bsr		DeletePort		release it

		moveq.l		#0,d0			signal error

.Error1		rts					exit

		****************************************
		*	  Close Serial Device	       *
		****************************************

CloseSer	move.l		WriteReq,a1		a1->request
		CALLEXEC	CloseDevice		close serial device

; Release the IO structure

.Error3		move.l		WriteReq,a1		a1->IO structure
		bsr		DeleteExtIO		release it

; Free the port

.Error2		move.l		AccPort,a0		a0->Port
		bsr		DeletePort		release it

; all freed so return

		rts

		****************************************
		*	IO Routines by D.Edwards       *
		****************************************

		include		ACC29_A:include/exec_support.i

		****************************************
		*	  Program Data Area	       *
		****************************************

pname		dc.b		'Amiganuts_Port',0
		even

sername		dc.b		'serial.device',0
		even
		
AccPort		dc.l		0
WriteReq	dc.l		0

Msg1		dc.b		'A trip through your wires!',$0a
MsgLen		equ		*-Msg1
		even
