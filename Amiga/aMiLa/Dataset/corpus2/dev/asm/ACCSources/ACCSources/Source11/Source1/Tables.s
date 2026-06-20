
; An example of using RawDoFmt ().

; Will display the times table specified at the CLI by a digit 0 to 9.

; Nothing spectacular, but  it does show how to use RawDoFmt. Here is an
;explanation.

; RawDoFmt ( format statement,data,copy subroutine,buffer )

;		   a0          a1      a2          a3

		incdir		sys:Include/
		include		exec/Exec_lib.i
		include		libraries/dos_lib.i

		move.l		a0,-(sp)	save addr of param list

;--------------	Open the DOS library

		lea		dosname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq.s		error

;--------------	Obtain CLI output handle and save it

		CALLDOS		Output
		move.l		d0,STD_out
		beq.s		error1

;--------------	If no params at CLI, or if 1st param is a ?, then display
;		usage text

		move.l		(sp)+,a0	retrieve addr of params
		moveq.l		#0,d0
		move.b		(a0),d0
		cmpi.b		#'?',d0
		beq		usage
		cmpi.b		#$0a,d0
		beq		usage

;--------------	Check 1st character of param list is a digit between 0 & 9
;		and display usage text if not

		cmpi.b		#'0',d0
		blt		usage
		cmpi.b		#'9',d0
		bgt		usage

;--------------	Convert character to a number and init loop counter ( d6 )
;		with this value.

		sub.b		#'0',d0
		move.w		d0,data

		moveq.l		#11,d6

;--------------	Format the next line ready for printing

loopy		bsr		format_result

;--------------	Use my standard DOS printing routine to print the line

		lea		buffer,a0
		bsr		PrintMsg

;--------------	Add 1 to multiplicator for next line in table

		add.l		#$00000001,data

;--------------	Loop back until all 12 lines are printed

		dbra		d6,loopy

;--------------	Close DOS library

error1		move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary

error		rts

;--------------	
;--------------	Subroutine that calls RawDoFmt to format the data ready
;--------------	for printing. Prior to calling RawDoFmt, the first two
;		words at data are multiplied together and the long word
;		result is saved immediately after these. RawDoFmt will
;		insert these values into the template supplied.

format_result	lea		data,a0
		moveq.l		#0,d0
		move.w		(a0)+,d0
		mulu.w		(a0)+,d0
		move.l		d0,(a0)

		lea		template,a0
		lea		data,a1
		lea		PutChar,a2
		lea		buffer,a3
		CALLEXEC	RawDoFmt

		rts

;--------------	This routine is called by RawDoFmt as each character is
;		generated. It is up to us what to do with the formated
;		data produced. This subroutine differs from the example
;		given in Autodocs manual as it tests for the 0 terminating
;		byte and inserts a line-feed byte before it as required
;		to generate a new-line in the CLI window. Note that a3 is
;		exclusive to this routine and not alterd by RawDoFmt, so
;		it points to the buffer where expanded text must go.


PutChar		tst.b		d0
		bne.s		.ok
		move.b		#$0a,(a3)+
.ok		move.b		d0,(a3)+
		rts

;--------------	
;--------------	Subroutine to display any message in the CLI window
;--------------	

; Entry		a0 must hold address of 0 terminated message.
;		STD_out should hold handle of file to be written to.
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

		move.l		STD_out,d1	d1=file handle
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

usage		lea		usage_text,a0
		bsr		PrintMsg
		bra		error1

usage_text	dc.b		'Times tables © M.Meany 1991.',$0a,$0a
		dc.b		'CLI Usage : Table <base>',$0a
		dc.b		'                        where base is a digit from 0 to 9.'
		dc.b		$0a,$0a,$0



data		dc.w		0,1
		dc.l		0

template	dc.b		'%6d x %6d = %8ld',0
		even

buffer		ds.b		30
		even

dosname		dc.b		'dos.library',0
		even

_DOSBase	dc.l		0
STD_out		dc.l		0
