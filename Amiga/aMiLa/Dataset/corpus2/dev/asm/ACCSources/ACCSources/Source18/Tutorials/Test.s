
		Incdir		sys:include/
		Include		exec/exec_lib.i

		XDEF		_GfxBase,_PPBase	Export to Play.o

		XREF		PlayFile,StopPlaying	Import from Play.o

Start		move.b		#0,-1(a0,d0)		NULL CLI parameter

		move.l		a0,a5			save filename ptr

		lea		gfxname,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		open
		move.l		d0,_GfxBase		save base pointer
		beq		ERROR

		lea		ppname,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		open
		move.l		d0,_PPBase		save base pointer
		beq		ERROR1

		move.l		a5,a0			a0->filename
		jsr		PlayFile		play the music

WAIT		btst		#6,$bfe001		test LMB
		bne.s		WAIT			loop 'till pressed

		jsr		StopPlaying		stop music

		move.l		_PPBase,a1		a1->lib base
		CALLEXEC	CloseLibrary		close it

ERROR1		move.l		_GfxBase,a1		a1->lib base
		CALLEXEC	CloseLibrary		close it

ERROR		moveq.l		#0,d0			No DOS error
		rts					and finito

gfxname		dc.b		'graphics.library',0
		even
_GfxBase	dc.l		0

ppname		dc.b		'powerpacker.library',0
		even
_PPBase		dc.l		0

