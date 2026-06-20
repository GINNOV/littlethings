

; RawDoFmt () Master Example Code

; by Mark Meany, April 91.


		incdir		df1:include/
		include		libraries/dos_lib.i
		include		exec/exec_lib.i


;------	Open DOS

		lea		dosname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq		error

;------	Determine CLI input/output handles

		CALLDOS		Input
		move.l		d0,STD_IN	not used !!!
		beq		error1

		CALLDOS		Output
		move.l		d0,STD_OUT
		beq		error1

;------	Examples follow each other, output instruction to user

		bsr		PrintMsg



;------	First six examples use the same string, therefore the strings addr
;	only needs to be put on the datastream once at the beggining. It will
;	be there for all six examples.

		move.l		#str_1,datastream

;------	Straight forward string format

		lea		templ_1,a0
		bsr		DoFormat
		bsr		PrintMsg

		bsr		Wait

;------	Left justified string format

		lea		templ_2,a0
		bsr		DoFormat
		bsr		PrintMsg

		bsr		Wait

;------	Display 1st 10 chars in a field 40 chars wide

		lea		templ_3,a0
		bsr		DoFormat
		bsr		PrintMsg

		bsr		Wait

;------	Display 1st 10 chars, left justified, in a field 40 chars wide

		lea		templ_4,a0
		bsr		DoFormat
		bsr		PrintMsg

		bsr		Wait

;------	Display 1st 40 chars in a field of width 10 chars.
;	This shows that num of chars takes priority over width

		lea		templ_5,a0
		bsr		DoFormat
		bsr		PrintMsg

		bsr		Wait

;------	Display 1st 40 chars, left justified, in a field of width 10 chars.
;	This shows that num of chars takes priority over width

		lea		templ_6,a0
		bsr		DoFormat
		bsr		PrintMsg

		bsr		Wait

;------	Display a string and a number

		moveq.l		#1,d7
		move.l		#50,d6

		move.l		#str_2,datastream
loopy		move.w		d7,datastream+4
		lea		templ_7,a0
		bsr		DoFormat
		bsr		PrintMsg

		add.l		#500,d7
		dbra		d6,loopy

		bsr		Wait

;------	Display two numbers

		moveq.l		#1,d7
		move.l		#254,d6

loopy1		move.w		d7,datastream
		moveq.l		#7,d0
		mulu		d7,d0
		move.w		d0,datastream+2
		lea		templ_8,a0
		bsr		DoFormat
		bsr		PrintMsg

		addq.l		#1,d7
		dbra		d6,loopy1

		bsr		Wait

;------	Close DOS

error1		move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary

;------	Finish

error		rts

*******************************************************************

;--------------	Subroutine to display any message in the CLI window

; Modified for this subroutine to display contents of buffer only

; Entry		NONE -- only mod.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

PrintMsg	lea		buffer,a0	a0->buffer
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

.error		rts

*******************************************************************

; Entry :	a0-> template for RawDoFmt()

DoFormat	lea		datastream,a1
		lea		buffer,a3
		lea		PutChar,a2
		CALLEXEC	RawDoFmt
		rts

;------- Use version of PutChar that adds a Line-Feed at end of each string

PutChar		tst.b		d0
		bne.s		.ok
		move.b		#$0a,(a3)+
.ok		move.b		d0,(a3)+
		rts


*******************************************************************

Wait		btst		#6,$bfe001
		bne.s		Wait
		rts

*******************************************************************


*******************************************************************


*******************************************************************


*******************************************************************


*******************************************************************


*******************************************************************



;--
;--- Data and variables section

dosname		dc.b		'dos.library',0
		even

_DOSBase	dc.l		0

STD_OUT		dc.l		0
STD_IN		dc.l		0

datastream	ds.l		20		space for data stream

buffer		dc.b		"After each example press the LEFT mouse button to continue.",$0a,0
		ds.b		85		space for ASCII string
		even

;---------------------------------------------------------------------
;---------------------------------------------------------------------

;			DATA FOR RawDoFmt()

;---------------------------------------------------------------------
;---------------------------------------------------------------------

templ_1		dc.b		'>>>%40s<<<',0
		even

templ_2		dc.b		'>>>%-40s<<<',0
		even

templ_3		dc.b		'>>>%40.10s<<<',0
		even

templ_4		dc.b		'>>>%-40.10s<<<',0
		even

templ_5		dc.b		'>>>%10.40s<<<',0
		even

templ_6		dc.b		'>>>%-10.40s<<<',0
		even

templ_7		dc.b		'>>>%s %4d<<<',0
		even

templ_8		dc.b		'>>>7 x %6d = %6d<<<',0
		even

;				 12345678901234567890123456789
str_1		dc.b		'This string is 29 bytes long.',0
		even

str_2		dc.b		'Number is now :',0
		even
