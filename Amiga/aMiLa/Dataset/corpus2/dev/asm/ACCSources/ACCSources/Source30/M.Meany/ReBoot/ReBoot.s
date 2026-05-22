
;Purpose	To inform user that manual degrading is required
;Programmer	M.Meany
;Date		January 1993
;Machine	Amiga A12OO
;Assembler	Devpac 3

		incdir		sys:Include/
		include		exec/exec_lib.i
		include		exec/libraries.i
		include		libraries/dos_lib.i


PUSH		macro
		movem.l		\1,-(sp)
		endm

PULL		macro
		movem.l		(sp)+,\1
		endm

;_LVOColdReboot	equ		-726		is not defined in 1.3 include

Start		lea		dosname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq		Error

; Obtain CLI handle

		CALLDOS		Output
		move.l		d0,std_out

; Display intro text

		lea		Intro,a0
		bsr		RDFPrint
		
; Check DOS revision

		move.l		_DOSBase,a0		a0->dos base
		move.w		LIB_VERSION(a0),d0	get library version

; See if greater that version 38

		cmpi.b		#38,d0
		ble.s		Safe
		move.w		d0,DStream

; Display warning

		lea		Warning,a0
		bsr		RDFPrint

; Wait for right mouse button to be pressed

Wait		btst		#2,$dff016
		beq.s		Safe
		btst		#6,$bfe001
		bne.s		Wait

; Reset the computer

		CALLEXEC	ColdReboot
				
; Close DOS

Safe		move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary

; And exit

Error		moveq.l		#0,d0			no return code
		rts

		********************************

*******	Build and display a text string using RawDoFmt

; Entry		a0->format string

; Exit		Nothing Useful

; Corrupt	a6 possibly

RDFPrint	PUSH		d0-d4/a0-a4

		lea		DStream,a1
		lea		_PC,a2
		lea		BuiltText,a3
		CALLEXEC	RawDoFmt
		
		lea		BuiltText,a0
		bsr		DOSPrint
		
		PULL		d0-d4/a0-a4
		rts

_PC		move.b		d0,(a3)+
		rts


; Subroutine to print a message into std_out! If std_out is NULL, a temporary
;console is opened and program will not return until user acknowledges text
;displayed.

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


		********************************


dosname		dc.b		'dos.library',0
		even
_DOSBase	dc.l		0
std_out		dc.l		0
DStream		dc.l		0

Warning		dc.b		$09,'This Amiga is fitted with v%2d operating system.',$0a
		dc.b		$09,'You should reset and hold down both mouse buttons',$0a
		dc.b		$09,'to gain access to the boot menu. From here, disable',$0a
		dc.b		$09,"CPU Cache and select 'Original' display option. All",$0a
		dc.b		$09,'games on this disk should then run.',$0a,$0a
		dc.b		$09,'  Press Left Mouse Button To Reset.',$0a
		dc.b		$09,'  Press Right Mouse Button To Continue.',$0a,$0a
		dc.b		$09,'                      Mark, Amiganuts!.',$0a
		dc.b		0
TextLength	equ		*-Warning
		even

Intro		dc.b		$09,'Amiganuts ROM test, checking Kickstart version.',$0a,$0a
		dc.b		$09,'Amiganuts Public Domain & Licenseware Library.',$0a
		dc.b		$09,'12 Hinkler Road, Southampton, Hants, England.',$0a,$0a
		dc.b		$09,'Phone: (O7O3) 47OO17 for more information.',$0a,$0a
		dc.b		0
		even

		section		datay,BSS

BuiltText	ds.b		TextLength+50
