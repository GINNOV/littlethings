
;Purpose	To monitor all calls to the dos.library Open() function.
;Programmer	M.Meany
;Date		January 1993
;Machine	Amiga A12OO
;Assembler	Devpac 3

		incdir		sys:Include/
		include		exec/exec_lib.i
		include		libraries/dos_lib.i


PUSHALL		macro
		movem.l		d0-d7/a0-a6,-(sp)
		endm

PULLALL		macro
		movem.l		(sp)+,d0-d7/a0-a6
		endm

		include		misc/easystart.i

Start		lea		dosname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq		FatalError

; Open a CLI for output

		move.l		#MyCli,d1
		move.l		#MODE_NEWFILE,d2
		CALLDOS		Open
		move.l		d0,std_out
		beq		StillFatal		

; Display introduction text

		lea		IntroText,a0
		bsr		DOSPrint
		
; Stop multitasking

		CALLEXEC	Forbid

; Patch the Open() function

		move.l		_DOSBase,a1
		lea		_LVOOpen(a1),a4
		addq.l		#2,a4
		move.l		(a4),Vector
		move.l		#Monitor,(a4)

; Signal that library has been changed to prevent a Guru tea break:-)

		or.b		#LIBF_CHANGED,LIB_FLAGS(a1)	signal

; Recalculate libraries checksum

		CALLEXEC	SumLibrary

; Multi tasking back on

		CALLEXEC	Permit

; Wait for user to press CTRL-C (( run from CLI only ))

waiting		move.l		#$1000,d0		CTRL-C
		CALLEXEC	Wait			wait for an event
		
		
		btst		#12,d0			test for CTRL-C
		beq.s		waiting			loop back if not

; Stop multitasking

		CALLEXEC	Forbid

; Replace systems vector

		move.l		_DOSBase,a1
		lea		_LVOOpen(a1),a4
		addq.l		#2,a4
		move.l		Vector,(a4)

; Again signal library has been changed

		or.b		#LIBF_CHANGED,LIB_FLAGS(a1)	signal

; Recalculate checksum

		CALLEXEC	SumLibrary

; multi tasking back on

		CALLEXEC	Permit

; Close the console window

		move.l		std_out,d1
		CALLDOS		Close

; Close DOS library

StillFatal	move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary

; And exit.

FatalError	moveq.l		#0,d0
		rts

*******	The patch routine for dos.library Open()
		
Monitor		PUSHALL

; Push access mode onto Data Stream for RawDoFmt().

		move.l		#NewMode,DStream
		cmp.l		#MODE_NEWFILE,d2
		beq.s		IsNew
		move.l		#OldMode,DStream

; Push files name onto Data Stream for RawDoFmt().

IsNew		move.l		d1,DStream+4

		lea		OpenTmp,a0
		bsr		RDFPrint
		
		PULLALL
		
		move.l		Vector,a0
		jsr		(a0)
		
		PUSHALL
		
		lea		OpenOk,a0
		tst.l		d0
		bne.s		IsOpen
		lea		OpenFail,a0

IsOpen		bsr		DOSPrint

		PULLALL
		
		rts

*******	Build and display a text string using RawDoFmt

; Entry		a0->format string

; Exit		Nothing Useful

; Corrupt	a6 possibly

RDFPrint	PUSHALL

		lea		DStream,a1
		lea		_PC,a2
		lea		BuiltText,a3
		CALLEXEC	RawDoFmt
		
		lea		BuiltText,a0
		bsr		DOSPrint
		
		PULLALL
		rts

_PC		move.b		d0,(a3)+
		rts

*******	Print a NULL terminated message into a console

; Entry		a0->NULL terminated message
;		std_out to be defined somewhere in calling program

; Exit		nothing in particular

; corrupt	none

DOSPrint	movem.l		d0-d4/a0-a4/a6,-(sp)

; Determine length of string

		move.l		a0,a4			copy pointer
		moveq.l		#-1,d3			clear counter

.LenLoop	addq.l		#1,d3			bump counter
		tst.b		(a0)+			check for EOL
		bne.s		.LenLoop		loop if not!

; Print the text

		move.l		std_out,d1		CLI handle
		beq.s		.done			exit if no console
		move.l		a4,d2			buffer
		CALLDOS		Write			write the text

.done		movem.l		(sp)+,d0-d4/a0-a4/a6
		rts

*******	Data section for initialised strings etc.

Vector		dc.l		0

dosname		dc.b		'dos.library',0
		even

MyCli		dc.b		'con:0/100/640/100/Moitor by M.Meany of Amiganuts',0
		even

IntroText	dc.b		'Monitor, by M.Meany of Amiganuts.',$0a
		dc.b		'Monitoring calls to Open():',$0a,$0a,0
		even

OpenTmp		dc.b		'Opening %s file "%s" ... ',0
		even

NewMode		dc.b		'new',0
		even
OldMode		dc.b		'old',0
		even

OpenOk		dc.b		'OK!',$0a,0
		even

OpenFail	dc.b		'Failed!',$0a,0
		even

		section		wild,BSS

_DOSBase	ds.l		1
std_out		ds.l		1
		
DStream		ds.l		3
BuiltText	ds.b		100

