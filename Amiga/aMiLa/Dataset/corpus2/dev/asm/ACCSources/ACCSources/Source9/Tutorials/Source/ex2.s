; Solution to exersise 2. Assumes the file ram:junk exsists and adds
;a line of text to it. All that has been modified from write-to-file.s
;is the access mode used to open the file. This program uses MODE_OLDFILE
;so file is not erased before opening.

; Assemble and then run this source. To see the result load the file ram:junk

; Create a file in ram and write some text to it.

; Assemble and run this, then load the file ram:junk to see result.

;--------------	First the includes

		incdir		sys:include/
		include		exec/exec_lib.i
		include		exec/exec.i
		include		libraries/dos_lib.i
		include		libraries/dos.i
		include		misc/easystart.i

;--------------	Open the DOS library

		lea		dosname,a1	a1->library name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_DOSBase	save base pointer
		beq		error_NO_DOS	branch if error

;--------------	Open the file

		move.l		#filename,d1	d1=address of files name
		move.l		#MODE_OLDFILE,d2 d2=access mode
		CALLDOS		Open		and open the file
		move.l		d0,handle	save files handle
		beq		error_NO_FILE	branch if error

;-------------- Write text to the file

		move.l		handle,d1	d1=files handle
		move.l		#text,d2	d2=address of text
		move.l		#text_len,d3	d3=length of text
		CALLDOS		Write		write the text

;--------------	Now close the file

		move.l		handle,d1	d1=files handle
		CALLDOS		Close		close the file

;--------------	Close the DOS library

		move.l		_DOSBase,a1	a1=lib base pointer
error_NO_FILE	CALLEXEC	CloseLibrary	close the library

;--------------	All done so finish

error_NO_DOS	rts				finish


;--------------	Program data section

dosname		dc.b		'dos.library',0	name of library
		even				to be safe
_DOSBase	dc.l		0		space for lib base addr

filename	dc.b		'ram:Junk',0	name of file to create
		even				to be safe
handle		dc.l		0		space for file handle

text		dc.b		'And this is the second one.',$0a
text_len	equ		*-text
		even				to be safe

