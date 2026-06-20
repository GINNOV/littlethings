
* Name		serial_3.s
* Function	receive a line of text from the serial device
* Programmer	M.Meany
* Assembler	Devpac III ( will assemble using Devpac II )
* Comments	It works!
*		Development of a NULL modem link-up of two Amigas

; Will need to send a message from other Amiga using either NComm or Serial_1
;This code will display the result. Have allowed for possability of either a
;$0a or $0d terminator so it wont hang!

		incdir		sys:Include/
		include		exec/Exec.i
		include		exec/exec_lib.i
		include		libraries/dos.i
		include		libraries/dos_lib.i
		include		devices/serial.i

; Start by opening the DOS library

Main		bsr		OpenLibs
		tst.l		d0
		beq		.Error1

; Open serial device for the really heavy stuff!

		bsr		OpenSer			open serial device
		tst.l		d0			ok?
		beq		.Error1			no, exit!
		
; Get data from serial device. Note one byte at a time is read and displayed
;until a $0a or $0d is received.

.ReadNext	move.l		WriteReq,a1		a1-> IO request
		move.w		#CMD_READ,IO_COMMAND(a1) reading data
		move.l		#1,IO_LENGTH(a1)	number of bytes
		move.l		#buffer,IO_DATA(a1)	address of data
		CALLEXEC	DoIO			get message

; display data read

		move.l		std_out,d1
		move.l		#buffer,d2
		moveq.l		#1,d3
		CALLDOS		Write

		cmp.b		#$0d,buffer
		beq.s		.done
		
		cmp.b		#$0a,buffer
		bne.s		.ReadNext

; Make sure prompt moves gracefully down

.done		move.b		#$0a,buffer
		move.l		std_out,d1
		move.l		#buffer,d2
		moveq.l		#1,d3
		CALLDOS		Write

; finished with serial device, so close it!

		bsr		CloseSer		close serial device

; Close DOS library as weve finished with it

.Error1		bsr		CloseLibs
		
; All Done so return

		moveq.l		#0,d0			no script errors
		rts

		****************************************
		*	 Open Required Libraries       *
		****************************************

OpenLibs	lea		dosname,a1		a1->library name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		open it
		move.l		d0,_DOSBase		save base pointer
		beq		.Error			exit on error

		CALLDOS		Output
		move.l		d0,std_out
		
		nop					DEBUG only
.Error		rts					and return

		****************************************
		*	   Close All Libraries	       *
		****************************************

CloseLibs	move.l		_DOSBase,d0
		beq		.Error			quit if not open
		move.l		d0,a1			a1-> lib base
		CALLEXEC	CloseLibrary		close it

.Error		rts

		****************************************
		*	  Open Serial Device	       *
		****************************************


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

dosname		dc.b		'dos.library',0
		even

_DOSBase	dc.l		0
std_out		dc.l		0		
AccPort		dc.l		0
WriteReq	dc.l		0

buffer		dc.b		2
