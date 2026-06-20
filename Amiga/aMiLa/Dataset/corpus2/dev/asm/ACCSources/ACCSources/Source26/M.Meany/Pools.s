
; Playing with Amiga.lib and using a few DOS 2.0 routines as well

; Assemble as executable and link with amiga.lib, ie

;blink ram:pools.o LIB amiga.lib

; Program will select 10 random numbers between 1 and 58 for entry onto a
;pools coupon. No numbers are repeated. If this program makes you rich,
;please remember me :-)

; Usage: ( CLI only )

; Pools number		where number is a decimal integer

; eg.	Pools 240792
;	Pools 220565	( my date of birth )

; Define some labels for import/export with Amiga.lib

		XDEF	_DOSBase,_stdout,_SysBase	Amiga.lib needs these
		XREF	_RangeSeed			Seed value
		XREF	_RangeRand			Random subroutine

		incdir		sys:include2.0/
		include		exec/exec_lib.i
		include		dos/dos_lib.i
		include		dos/dosextens.i

; Start by saving pointer to supplied number

Start		move.l		a0,arg			save pointer

; Open DOS library, WB 2.0 version.

		lea		dosname,a1		libname
		moveq.l		#37,d0			latest version
		CALLEXEC	OpenLibrary		open it
		move.l		a6,_SysBase		save exec base addr
		move.l		d0,_DOSBase		and DOS base addr
		beq		QuitFast		leave if error

; Get input stream

		CALLDOS		Output			input stream
		move.l		d0,_stdout		save it

; Set seed according to user input, uses a DOS routine to convert the string
;into a long word value:

; count = StrToLong( *string, *value )
;  d0			d1      d2

		move.l		arg,d1
		move.l		#_RangeSeed,d2
		CALLDOS		StrToLong

; Loop to generate the random numbers and store them in a matrix

		moveq.l		#9,d7			counter

loop		move.l		#58,-(sp)		push value
		jsr		_RangeRand		call routine
		addq.l		#4,sp			correct stack

; The following routine checks for repeats

		bsr		CheckNum
		tst.l		d0
		beq.s		loop
		
		dbra		d7,loop			10 times

; Now sort and print selections

		bsr		PrintD0

; Close DOS

		move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary

; and exit

QuitFast	moveq.l		#0,d0
		rts

*****	Subroutine that check random number and records it if not a repeat

CheckNum	lea		Table,a0
		move.l		a0,a1
		moveq.l		#9,d1
.loop		cmp.l		(a0)+,d0
		beq		repeated
		dbra		d1,.loop

		move.l		d7,d1
		asl.l		#2,d1
		move.l		d0,(a1,d1)		save in table
		rts

repeated	moveq.l		#0,d0
		rts

*****	Subroutine to sort matrix and print values

; Uses VPrintf to print data into current output stream.

; count = VPrintf(  fmt, argv )
;  d0	            d2    d3

; count		number of bytes written to file.
; fmt		C type format string, will be passed to RawDoFmt()
; argv		pointer to data stream that accompanies fmt string

PrintD0		lea		Table,a0		a5->matrix
		bsr		bubble			sort table
		
		lea		Table,a5
		moveq.l		#9,d5			counter
		move.l		#0,DStream		clear
		
.loop		move.l		(a5)+,d0

		lea		DStream,a0
		addq.w		#1,(a0)
		move.w		d0,2(a0)
		
		move.l		#Template,d1
		move.l		a0,d2
		CALLDOS		VPrintf

		dbra		d5,.loop
		
		rts


*****	Acending sort routine. Sorts a list of long words.

; Entry		a0->start of null terminated list of long words

; Exit

; Corrupted	a0,d0 fflag

bubble		move.l		#0,fflag

		tst.l		(a0)
		beq.s		.error

		move.l		a0,-(sp)

.loop		tst.l		4(a0)
		beq.s		.done
		
		move.l		(a0)+,d0
		cmp.l		(a0),d0
		ble.s		.ok
		move.l		#1,fflag
		move.l		(a0),-4(a0)
		move.l		d0,(a0)
		
.ok		bra.s		.loop

.done		move.l		(sp)+,a0
		tst.l		fflag
		bne.s		bubble
		
.error		rts


arg		dc.l		0
fflag		dc.l		0

_SysBase	dc.l		0
_DOSBase	dc.l		0
_stdout		dc.l		0

Table		ds.l		11

dosname		DOSNAME

Template	dc.b		'Selection %2d is %2d',$0a,0
		even
DStream		dc.w		0,0

