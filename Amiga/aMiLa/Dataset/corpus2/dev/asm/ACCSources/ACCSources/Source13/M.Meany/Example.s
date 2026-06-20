
; Example of using ShowMem() subroutine.

; © M.Meany, June 1991.


		incdir		sys:include/
		include		exec/exec_lib.i
		include		exec/exec.i
		include		intuition/intuition_lib.i
		include		intuition/intuition.i
		include		libraries/dos_lib.i
		include		libraries/dos.i
		include		libraries/dosextens.i
		include		graphics/gfx.i
		include		graphics/graphics_lib.i

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"

;--------------	Open required libraries

		bsr.s		Openlibs	open libraries
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

;--------------	Call text viewer subroutine

		lea		Text,a0		addr of text into a0
		move.l		#TextLen,d0	size of text into d0
		bsr		ShowMem		display text

;--------------	Close all open libraries

no_libs		bsr		Closelibs	close open libraries

		rts				finish


;**************	Open all required libraries

; Open DOS, Intuition and Graphics libraries.

; If d0=0 on return then one or more libraries are not open.

Openlibs	lea		dosname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_DOSBase	save base ptr
		beq.s		.lib_error	quit if error

		lea		intname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_IntuitionBase	save base ptr
		beq.s		.lib_error	quit if error

		lea		gfxname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_GfxBase	save base ptr

.lib_error	rts


***************	Close all open libraries

; Closes any libraries the program managed to open.

Closelibs	move.l		_DOSBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

		move.l		_IntuitionBase,d0	d0=base ptr	
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

		move.l		_GfxBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.lib_error	rts



***************
*************** DATA SECTION
***************

dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even
gfxname		dc.b		'graphics.library',0
		even

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

***************
*************** Include the text file as a binary file.
***************

Text		incbin	doc
TextLen		equ	*-Text
		even

***************
*************** Include ShowMem() text viewer subroutine.
***************

		include	showmem.i
