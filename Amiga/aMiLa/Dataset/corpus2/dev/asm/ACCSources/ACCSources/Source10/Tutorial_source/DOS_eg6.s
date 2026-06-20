
; DOS_eg6.s

; Reading the keyboard.

;--------------	The INCLUDES

		incdir		sys:include/
		include		exec/exec_lib.i
		include		libraries/dos_lib.i

;--------------	Open the DOS library

Start		lea		dosname,a1	a1-->lib name
		moveq.l		#0,d0		d0=0; any version
		CALLEXEC	OpenLibrary	open it
		move.l		d0,_DOSBase	save base pointer
		beq		error		quit if error

;--------------	Get CLI output handle

		CALLDOS		Output		get output handle
		move.l		d0,CLI_out	and store it
		beq		error_no_out	quit if no handle

;--------------	Get CLI input handle ( keyboard )

		CALLDOS		Input		get input handle
		move.l		d0,CLI_in	and store it
		beq.s		error_no_out	quit if no handle

;--------------	Write some text into CLI window

		move.l		CLI_out,d1	d1=file handle
		move.l		#message,d2	d2=addr of message
		moveq.l		#msg_len,d3	d3=length of message
		CALLDOS		Write		write text into CLI

;--------------	Get users reply

		move.l		CLI_in,d1	d1=file handle (keyboard)
		move.l		#buffer,d2	d2=addr of buffer
		move.l		#buf_len,d3	d3=max num of chars
		CALLDOS		Read		get user reply
		move.l		d0,reply_len	save reply length

;--------------	Write greeting intoo CLI window

		move.l		CLI_out,d1	d1=file handle
		move.l		#message1,d2	d2=addr of message
		move.l		#msg1_len,d3	d3=length of message
		CALLDOS		Write		write text into CLI

;--------------	Echo users name into CLI window

		move.l		CLI_out,d1	d1=file handle
		move.l		#buffer,d2	d2=addr of message
		move.l		reply_len,d3	d3=length of message
		CALLDOS		Write		write text into CLI

;--------------	Close DOS library

error_no_out	move.l		_DOSBase,a1	a1=lib base address
		CALLEXEC	CloseLibrary	close the library

;--------------	Finish

error		rts				and quit

;--------------	Variables and Strings 

dosname		dc.b		'dos.library',0
		even
_DOSBase	dc.l		0

CLI_out		dc.l		0
CLI_in		dc.l		0

reply_len	dc.l		0

message		dc.b		$0a,'Please enter your name ( max 32 chars )',$0a
msg_len		equ		*-message
		even

buffer		ds.b		34		leave a little extra !
buf_len

message1	dc.b		$0a,'Good-day to you '
msg1_len	equ		*-message1
