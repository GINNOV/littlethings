
; DOS_eg3.s

; Example of CreateDir () usage.

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

;--------------	Create the directory

		move.l		#mydir,d1	d1=addr of dir name
		CALLDOS		CreateDir	and create it
		move.l		d0,dir_lock	save returned key
		beq		error1		quit if error

;--------------	Unlock the directory so system can access it

		move.l		dir_lock,d1	d1=key for the dir
		CALLDOS		UnLock		and release it

;--------------	Close DOS library

error1		move.l		_DOSBase,a1	a1->lib base
		CALLEXEC	CloseLibrary	and close it

;--------------	Finish

error		rts

;------
;--------------	DATA
;------

dosname		dc.b		'dos.library',0
		even

_DOSBase	dc.l		0

mydir		dc.b		'ram:MarksDirectory1',0
		even

dir_lock	dc.l		0
