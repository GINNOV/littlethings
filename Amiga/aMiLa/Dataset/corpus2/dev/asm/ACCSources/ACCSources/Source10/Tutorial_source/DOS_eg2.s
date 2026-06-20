
; DOS_eg2.s

; Writing text to the CLI window.

;--------------	The INCLUDES

		incdir		sys:include/
		include		exec/exec_lib.i
		include		libraries/dos_lib.i

;--------------	Open the DOS library

Start		lea		dosname,a1	a1-->lib name
		moveq.l		#0,d0		d0=0; any version
		CALLEXEC	OpenLibrary	open it
		move.l		d0,_DOSBase	save base pointer
		beq.s		error		quit if error

;--------------	Get CLI output handle

		CALLDOS		Output		get output handle
		move.l		d0,CLI_out	and store it
		beq.s		error_no_out	quit if no handle

;--------------	Write some text into CLI window

		move.l		CLI_out,d1	d1=file handle
		move.l		#message,d2	d2=addr of message
		moveq.l		#msg_len,d3	d3=length of message
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

message		dc.b		$0a,'Hi world and all that.......',$0a
msg_len		equ		*-message
		even

