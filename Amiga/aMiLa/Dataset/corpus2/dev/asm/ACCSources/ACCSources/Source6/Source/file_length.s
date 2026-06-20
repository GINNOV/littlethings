; This program uses functions from the DOS library to determine the size 
;(in bytes) of a given file.

; NOTE: You can only see the result by using a monitor, eg MonAm2.

		opt		o+,ow-

		incdir		"df0:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"libraries/dos_lib.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		
ciaapra		equ		$bfe001

; Open the DOS library

start		moveq.l		#0,d0
		lea		dosname,a1
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq		error

; Allocate some memory for the File Info block

		move.l		#fib_SIZEOF,d0
		move.l		#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l		d0,file_info
		beq		error1
		
; Lock the file
		
		move.l		#filename,d1
		move.l		#ACCESS_READ,d2
		CALLDOS		Lock
		move.l		d0,file_lock
		beq		error2

; Use Examine to load the File Info block

		move.l		d0,d1
		move.l		file_info,d2
		CALLDOS		Examine

; Copy the length of the file into file_len

		move.l		file_info,a0
		move.l		fib_Size(a0),file_len

; Release the file

		move.l		file_lock,d1
		CALLDOS		UnLock

; Release allocated memory

error2		move.l		file_info,a1
		move.l		#fib_SIZEOF,d0
		CALLEXEC	FreeMem

; Close the DOS library

error1		move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary

; All done so return

error		rts
	
	
filename	dc.b		'source6:source/file_length.s',0
		even
dosname		dc.b		'dos.library',0
		even
_DOSBase	dc.l		0
file_lock	dc.l		0
file_info	dc.l		0
file_len	dc.l		0
