
; program to test integrity of acc.library.

; Function	: Convert an ASCII file to uppercase characters.
; Program Size	: 250 bytes.
; Author	: M.Meany.
; Date		: 8-10-91

; This program is a utility to convert a file into upper case characters.
;Enter name of file to convert as a CLI parameter.

		incdir		sys:include/
		include		exec/exec_lib.i
		include		libraries/dos_lib.i
		include		df1:project/lib_development/acc_lib.i

Start		move.b		#0,-1(a0,d0)	null the CLI parameter
		tst.b		(a0)		zero?
		beq		.quitfast	if so quit

		move.l		a0,a4		a4->filename

		lea		accname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	open it
		move.l		d0,_AccBase	save base pointer
		beq		.quitfast	quit if error

		lea		greet,a0	a0->string
		CALLACC		Ucase		convert to upper case

		lea		_DOSBase,a0	a0->addr for lib ptrs
		CALLACC		GetLibs		get lib pointers

		CALLDOS		Output		get CLI handle

		lea		greet,a0	a0->message
		CALLACC		DOSPrint	and print it

		move.l		a4,a0		a0->filename
		moveq.l		#PUBLICMEM,d0	type of mem
		CALLACC		LoadFile	load file

		move.l		d0,d5		save file length
		beq.s		.error		quit if not loaded
		move.l		a0,a5		and buffer pointer

		CALLACC		UcaseMem	convert file to uppercase

		move.l		a4,a0		a0->filename
		move.l		a5,a1		a1->buffer
		move.l		d5,d0		d0=buffer size
		CALLACC		SaveFile	and save it

		move.l		d5,d0		d0=size of buffer
		move.l		a5,a1		a1->buffer
		CALLEXEC	FreeMem		release it

.error		move.l		_AccBase,a1	a1->lib base
		CALLEXEC	CloseLibrary	and close it

.quitfast	rts				Byeeee!

accname		dc.b		'df1:project/lib_development/acc.library',0
		even
_AccBase	dc.l		0
_DOSBase	dc.l		0
_IntuitionBase	dc.l		0
_GfxBase	dc.l		0

greet		dc.b		'Utility to test acc.library',$0a,0
		even

