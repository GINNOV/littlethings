
; Openlibs		open libraries
; Closelibs		close any opened libraries
; lib vars		move into your programs data section


;--------------
;--------------	Open system libraries
;--------------

* Function	Opens all libraries required by a program and stores base
;		pointers.

* Entry		None

* Exit		d0=0 if no errors occurred, else d0 holds addr of name
;		of library that failed to open.

* Corrupt	d0

***** To open more libraries, copy procedure adopted for DOS, Intuition and
***** Graphics libraries below.

OpenLibs	movem.l		d1-d2/a0-a2/a6,-(sp)	save registers

; Open DOS library

		lea		dosname,a1		a1->libname
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		open it
		move.l		d0,_DOSBase		save base pointer
		bne.s		.DoInt			next lib if no errors
		move.l		#dosname,d0		else set error
		bra.s		.LibError		and quit

; Open Intuition library

.DoInt		lea		intname,a1		a1->libname
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		open it
		move.l		d0,_IntuitionBase	save base pointer
		bne.s		.DoGfx			next lib if no errors
		move.l		#intname,d0		else set error
		bra.s		.LibError		and quit

; Open Graphics library

.DoGfx		lea		gfxname,a1		a1->libname
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		open it
		move.l		d0,_GfxBase		save base pointer
		bne.s		.DoNext			next lib if no errors
		move.l		#gfxname,d0		else set error
		bra.s		.LibError		and quit

; Open any addittional libraries here

.DoNext		nop				open extra libs here

.LibError	movem.l		(sp)+,d1-d2/a0-a2/a6	restore
		rts

;--------------
;--------------	Close system libraries
;--------------

* Function	Closes all libraries opened by OpenLibs. If a library base
;		pointer is NULL, does not attempt to close the library.

* Entry		None

* Exit		None

* Corrupt	None

***** To close more libraries, copy procedure adopted for DOS, Intuition and
***** Graphics libraries below.

CloseLibs	movem.l		d0-d3/a0-a3/a6,-(sp)	save

; Close DOS library

		move.l		_DOSBase,d0		get base pointer
		beq.s		.DoInt			skip if not there
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close the library

.DoInt		move.l		_IntuitionBase,d0	get base pointer
		beq.s		.DoGfx			skip if not there
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close the library

.DoGfx		move.l		_GfxBase,d0		get base pointer
		beq.s		.Done			skip if not there
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close the library

.Done		movem.l		(sp)+,d0-d3/a0-a3/a6	restore
		rts


;--------------
;--------------	Data required by OpenLibs and CloseLibs
;--------------

***** You should move the following into the data section of your program.

; library names ( must be lower case )

dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even
gfxname		dc.b		'graphics.library',0
		even

; library base pointers, official names used for compatability.

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1
