
; DOS_eg4.s

; Testing the PrintMsg subroutine

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
		move.l		d0,STD_OUT	and store it
		beq.s		error_no_out	quit if no handle

;--------------	Write some text into CLI window using PrintMsg

		lea		message,a0
		bsr		PrintMsg

		lea		msg1,a0
		bsr		PrintMsg

		lea		msg2,a0
		bsr		PrintMsg


;--------------	Close DOS library

error_no_out	move.l		_DOSBase,a1	a1=lib base address
		CALLEXEC	CloseLibrary	close the library

;--------------	Finish

error		rts				and quit

;--------------
;-------------- Subroutine Area
;--------------

;--------------	Subroutine to display any message in the CLI window

; Entry		a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

PrintMsg	move.l		a0,a1		get a working copy

;--------------	Determine length of message

		moveq.l		#-1,d3		reset counter
.loop		addq.l		#1,d3		bump counter
		tst.b		(a1)+		is this byte a 0
		bne.s		.loop		if not loop back

;--------------	Make sure there was a message

		tst.l		d3		was there a message ?
		beq.s		.error		if not, graceful exit

;--------------	Get handle of output file

		move.l		STD_OUT,d1	d1=file handle
		beq.s		.error		leave if no handle

;--------------	Now print the message
;		At this point, d3 already holds length of message
;		and d1 holds the file handle.

		move.l		a0,d2		d2=address of message
		CALLDOS		Write		and print it

;--------------	All done so finish

.error		rts



;--------------
;--------------	Variables and Strings 
;--------------

dosname		dc.b		'dos.library',0
		even
_DOSBase	dc.l		0

STD_OUT		dc.l		0

message		dc.b		$0a,'Hi world and all that.......',$0a,0
		even
msg1		dc.b		'Lets just make sure',0
		even
msg2		dc.b		' that this works',$0a,$0a,0
		even
