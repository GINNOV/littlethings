
; DOS_eg6.s

; Example of Execute () usage.

; You will need Disc 11 handy when you run this !

; M.Meany, April 1991

		Incdir		sys:Include/
		Include		exec/exec_lib.i
		Include		libraries/dos_lib.i

;--------------	Open DOS library

		lea		dosname,a1	a1-> lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and attempt open
		move.l		d0,_DOSBase	save lib base ptr
		beq		error		quit if error

;--------------	Run text editor

		move.l		#editor,d1	d1=addr of file
		moveq.l		#0,d2		CLI input
		move.l		d2,d3		CLI output
		CALLDOS		Execute		and run it

;--------------	Close DOS library

		move.l		_DOSBase,a1	a1->lib base
		CALLEXEC	CloseLibrary	and close it

;--------------	Finish

error		rts

;------
;--------------	DATA
;------

dosname		dc.b		'dos.library',0
		even

_DOSBase	dc.l		0

editor		dc.b		'club11:utils/txed+',0
		even
