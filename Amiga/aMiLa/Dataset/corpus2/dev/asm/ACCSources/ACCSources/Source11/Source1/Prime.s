
; Short program to find all prime numbers between 1 and 500.

; Written for General Amiga in response to the C and MOD 2 examples.

; © M.Meany, March 1991.

; Another chapter in my quest to convert the World to programming in 
;assembly language.

; This program is less than 1K when assembled ( 760 bytes ). Though not fully
;optimised is still far quicker than the above mentioned examples. MM.

		opt		o+

		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		incdir		source:include/
		include		"arpbase.i"

		include		"sys:include/misc/easystart.i"  allow WB startup

ciaapra		equ		$bfe001

MAX_NUM		equ		500		change this if you wish


start		OPENARP				;use arp's own open macro
		movem.l		(sp)+,d0/a0	;restore d0 and a0 as the
						;the macro leaves these on
						;the stack causing corrupt
						;stack

		move.l		a6,_ArpBase	;store arpbase
		

;--------------	Open console window

		move.l		#ConName,d1	 filename
		move.l		#MODE_OLDFILE,d2 access mode
		CALLARP		Open		 and open it
		move.l		d0,STD_OUT	 store handle
		beq.s		error		 leave if error

;--------------	Display introduction to user

		lea		intro_msg,a0	a0-> addr of text
		bsr		PrintMsg	and print it

;--------------	Initialise variables

		move.l		#MAX_NUM,d7	loop terminator
		moveq.l		#3,d6		current value
		moveq.l		#2,d5		step size

;--------------	Main loop

loop		move.l		d6,d4		get copy of current value
		bsr.s		square_root	find it's square root ( INT )
		bsr.s		test_for_prime	see if number is prime
		tst.w		d0		check result
		beq.s		.ok		jump if not prime
		bsr.s		print_prime_num	else display number
.ok		add.l		d5,d6		bump counter
		cmp.l		d7,d6		finished yet ?
		bgt.s		finito		if so leave loop
		bra.s		loop		else go back and test next

;--------------	Print a closing message

finito		lea		end_msg,a0	a0-> text
		bsr		PrintMsg	and print it

;--------------	Wait for LMB to be pressed

mouse		btst		#6,ciaapra	LMB pressed ?
		bne.s		mouse		loop back if not

;--------------	Close console window

		move.l		STD_OUT,d1	d1= filehandle
		CALLARP		Close		and close file

;--------------	Close ARP library

error		move.l		_ArpBase,a1	a1 = lib base ptr
		CALLEXEC	CloseLibrary	and close it

;--------------	And leave

		rts				bye !


;--------------	Routine to find integer square root of value

; Entry		d4 = value to find root of
; Exit		d2 = the integer approx to the aquare root
; Corrupt	d1,d2

square_root	move.l		d4,d1		d1=A
		move.l		d4,d0		make a copy
		asr.l		#1,d0		d0=Xn
		move.l		#$ffff,d3	div mask

.loop		move.l		d1,d2		d2=A
		divu		d0,d2		d2=A/Xn
		and.l		d3,d2		d2=int(d2)
		add.l		d0,d2		d2=Xn+A/Xn
		asr.l		#1,d2		d2=1/2(Xn+A/Xn)
		bcc.s		.ok		if value was even jump
		addq.l		#1,d2		else bump value
.ok		cmp.l		d0,d2		end of iteration ?
		beq.s		.done		leave if so
		move.l		d2,d0		Xn+1=Xn
		bra.s		.loop		loop for next approximation

.done		rts				root obtained so return

;--------------	Subroutine to check if a number is prime

; Entry:	d2= sqr root of number
;		d6= number being tested

; Exit:		d0.w= 0 if and only if number is prime

; Corrupted	d0,d1

test_for_prime	moveq.l		#3,d1		init loop counter
.loop		move.l		d6,d0		copy of number
		divu		d1,d0		divide num by loop counter
		swap		d0		remainder into low word
		tst.w		d0		is remainder 0 ?
		beq.s		.not_prime	if so finish
		addq.l		#1,d1		bump loop counter
		cmp.l		d2,d1		end of loop?
		ble.s		.loop		if not go back again
.not_prime	rts				all done so return

;--------------	display a prime number

; Entry :	d6=prime number

; Exit :	nothing useful

; Corrupted :	a0-a3, d0,d1

print_prime_num	move.l		d6,number	put number into mem

;------	Initalise vars for RawDoFmt()

		lea		template,a0	a0-> C type format string
		lea		number,a1	a1-> data
		lea		PutChar,a2	a2-> User routine
		lea		buffer,a3	a3-> Destination buffer
		CALLEXEC	RawDoFmt	and format the number

;------	Now print the number

		lea		buffer,a0	a0-> formatted number
		bsr.s		PrintMsg	display it
		rts				and return

;--------------	User routine called by RawDoFmt (). Note this is a modified
;		version of that shown in Includes & Autodocs Reference manual

PutChar		tst.b		d0		test this char
		bne.s		.ok		jump if not 0 byte
		move.b		#$09,(a3)+	add a TAB byte
.ok		move.b		d0,(a3)+	add char to text
		rts				and return


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
		CALLARP		Write		and print it

;--------------	All done so finish

.error		rts



;--------------	Variables

_ArpBase	dc.l		0

ConName		dc.b		'con:0/0/640/200/Marks',0
		even
STD_OUT		dc.l		0

template	dc.b		'%4ld',0
		even

number		dc.l		0
buffer		ds.b		10

intro_msg	dc.b		$0a,$0a
		dc.b		'Prime Number Program.',$0a
		dc.b		'                      '
		dc.b		'by M.Meany for General Amiga ( Hi Ron ).'
		dc.b		$0a,$0a
		dc.b		'Here is a list of all prime numbers between'
		dc.b		' 1 and 500 :',$0a,$0a,0
		even

end_msg		dc.b		$0a,$0a
		dc.b		"That's all folks !  Press LMB to finish."
		dc.b		$0a,$0a,0
		even


