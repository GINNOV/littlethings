
; DOS_eg5.s

; Example of SetProtection () usage.

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

;--------------	Delete the file

		move.l		#filename,d1	d1=addr of file
		moveq.l		#-1,d2		clear all flags
		move.l		#%0001,d2	d2= rwe-
		CALLDOS		SetProtection	and protect

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

filename	dc.b		'ram:letter.doc',0
		even

