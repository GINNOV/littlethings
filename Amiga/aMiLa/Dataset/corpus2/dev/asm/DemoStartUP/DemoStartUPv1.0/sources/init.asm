
; - [ iNitialization ] - 


	xdef	_InitPreDEMO

	xref	_InitPlayer
	xref	_CPU
	xref	_CGX
	xref	_DosBase


	include basemacros.i

	incdir	include:

	include	LVO/dos_lib.i

	
_InitPreDEMO
	IFNE	MUSIC
	lea	module,a0
	sub.l	a1,a1
	sub.l	a2,a2
	moveq.l	#0,d0
	jsr     _InitPlayer     ;start music
	ENDC

	rts
	
	IFNE	MUSIC

	section Myooza,data_c
module
	incbin  sfx/p61.test

	ENDC

