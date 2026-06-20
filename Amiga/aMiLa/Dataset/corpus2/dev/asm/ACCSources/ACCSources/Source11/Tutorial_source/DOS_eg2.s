
; DOS_eg2.s

; Example of Rename () usage.

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

;--------------	Rename the file

		move.l		#oldname,d1	d1=addr of filename
		move.l		#newname,d2	d2=addr of new name
		CALLDOS		Rename		and rename it

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

oldname		dc.b		'ram:letter.doc',0
		even

newname		dc.b		'ram:letter.bak',0
		even
