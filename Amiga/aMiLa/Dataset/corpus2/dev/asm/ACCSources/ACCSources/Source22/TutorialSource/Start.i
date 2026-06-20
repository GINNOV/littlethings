
*****	Title		Start.i
*****	Function	A basic DOS startup module
*****			
*****			
*****	Size		812 bytes
*****	Author		Mark Meany
*****	Date Started	March 92
*****	This Revision	
*****	Notes		Subroutines -- For printing to CLI window

*****					Print	 a0->CSTR
*****					PrintNL	 a0->CSTR
*****					BPrint	 a0->BSTR
*****					BPrintNL a0->BSTR	


		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"libraries/dos_lib.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"

CALLSYS		macro
		ifgt	NARG-1
		FAIL	!!!
		endc
		jsr	_LVO\1(a6)
		endm


		section		Skeleton,code

		move.l		a0,_args		save addr of CLI args
		move.l		d0,_argslen		and the length

		lea		dosname,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_DOSBase		save base ptr
		beq.s		no_libs			if so quit

		bsr		Init			Initialise data
		tst.l		d0			any errors?
		beq.s		no_libs			if so quit

 		bsr		Main			Your routine

		move.l		_DOSBase,d0		d0=base ptr
		beq.s		no_libs			quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

no_libs		rts					finish


*************** Initialise any data

;--------------	At present just set STD_OUT and check for usage text

Init		CALLDOS		Output		determine CLI handle
		move.l		d0,STD_OUT	and save it for later
		beq.s		.err		quit if there is no handle

		move.l		_args,a0	get addr of CLI args
		cmpi.b		#'?',(a0)	is the first arg a ?
		bne.s		.ok		if not skip the next bit

		lea		_UsageText,a0	a0->the usage text
		bsr		Print		and display it
.err		moveq.l		#0,d0		set an error
		bra.s		.error		and finish

;--------------	Your Initialisations should start here

.ok		moveq.l		#1,d0		no errors

.error		rts				back to main

*****************************************************************************
*			Useful Subroutines Section					    *
*****************************************************************************

***************	Subroutine to display any message in the CLI window

; Entry		a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

Print		movem.l		d0-d3/a0-a3,-(sp) save registers

		tst.l		STD_OUT		test for open console
		beq		.error		quit if not one

		move.l		a0,a1		get a working copy

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

.error		movem.l		(sp)+,d0-d3/a0-a3 restore registers
		rts

***************	Subroutine to display any message in the CLI window

; Prints a line feed after the message

; Entry		a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

PrintNL		movem.l		d0-d3/a0-a3,-(sp) save registers

		bsr		Print

;--------------	Print a line feed

		move.l		STD_OUT,d1
		beq.s		.error
		move.l		#EOL_byte,d2
		moveq.l		#1,d3
		CALLDOS		Write

;--------------	All done so finish

.error		movem.l		(sp)+,d0-d3/a0-a3 restore registers
		rts



;--------------
;--------------	Routine to print a BSTRING into the CLI, no EOL.
;--------------

; Entry		a0->BSTR

; Exit		none

; Corrupt	none

BPrint		movem.l		d0-d4/a0-a6,-(sp)

		moveq.l		#0,d3			clear
		move.b		(a0)+,d3		string length
		beq.s		.done			skip if NULL
		
		move.l		STD_OUT,d1		handle
		move.l		a0,d2			address
		CALLDOS		Write			print it

.done		movem.l		(sp)+,d0-d4/a0-a6
		rts

;--------------
;--------------	Print a BSTR followed by a new line
;--------------

BPrintNL	movem.l		d0-d4/a0-a6,-(sp)

		bsr		BPrint

;--------------	Print a line feed

		move.l		STD_OUT,d1
		beq.s		.error
		move.l		#EOL_byte,d2
		moveq.l		#1,d3
		CALLDOS		Write

.error		movem.l		(sp)+,d0-d4/a0-a6
		rts

*****************************************************************************
*			Data Section					    *
*****************************************************************************

dosname		dc.b		'dos.library',0
		even

; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		'Exploring Exec.'
		dc.b		$0a
		dc.b		'      by M.Meany.'
		dc.b		$0a
		dc.b		0
		even

EOL_byte	dc.b		$0a
		even

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_args		ds.l		1
_argslen	ds.l		1

_DOSBase	ds.l		1

STD_OUT		ds.l		1

		section		Skeleton,code

***********************************************************
;		Your code starts here
;***********************************************************
