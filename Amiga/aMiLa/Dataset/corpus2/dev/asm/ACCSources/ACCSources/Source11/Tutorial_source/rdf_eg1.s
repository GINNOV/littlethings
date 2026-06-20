
; Example of using RawDoFmt. Assemble to MEMORY, select DEBUG, set a
;breakpoint at BreakPoint, set window 3 address to Buffer, run the program.

; M.Meany, March 91


RawDoFmt	equ		-522

CALLEXEC	macro
		move.l		$4.w,a6
		jsr		\1(a6)
		endm


		move.w		#6,apple1	init 1st variable
		move.w		#5,apple2	init 2nd variable

		moveq.l		#0,d0		clear d0
		move.w		apple1,d0	d0=apple1
		add.w		apple2,d0	d0=apple1 + apple2
		move.w		d0,SumOfApples	save result

;--------------	Use RawDoFmt to produce a printable string

		lea		Template,a0	a0->template
		lea		apple1,a1	a1->data stream
		lea		PutChar,a2	a2->our subroutine
		lea		Buffer,a3	a3->destination buffer

		CALLEXEC	RawDoFmt	produce ASCII string

BreakPoint	rts				and finish

;--------------	Subroutine called by RawDoFmt ()

PutChar		move.b		d0,(a3)+
		rts

;--------------	Data area

apple1		dc.w		0		1st variable
apple2		dc.w		0		2nd variable
SumOfApples	dc.w		0		3rd variable

;--------------	rdf template

Template	dc.b	'%d apples plus %d apples gives %d apples',0
		even

;--------------	Buffer for resulting text

Buffer		ds.b		200		leave lots of room

