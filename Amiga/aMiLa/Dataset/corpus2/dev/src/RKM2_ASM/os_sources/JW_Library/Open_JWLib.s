
	INCDIR	WORK:Include/

	INCLUDE ram:system.gs

	INCLUDE	misc/easystart.i

LIB_VER		EQU	39
TRUE		EQU	-1
FALSE		EQU	0
_LVODouble	EQU	-30
_LVOAddThese	EQU	-36


	moveq	#LIB_VER,d0
	lea	int_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_IntuitionBase
	beq	exit_quit

	moveq	#LIB_VER,d0
	lea	graf_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_GfxBase
	beq	exit_closeint

	moveq	#LIB_VER,d0
	lea	dos_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_DOSBase
	beq	exit_closegfx

 * Open a console window.

	move.l	#MODE_NEWFILE,d2
	move.l	#cname,d1
	CALLDOS	Open
	move.l	d0,cfh
	beq	exit_closedos

	moveq	#37,d0
	lea	jwlib_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_JwBase
	beq	exit_error

	lea	bytebuf(pc),a4

	move.l	_JwBase(pc),a6
	move.l	#67,d0
	move.l	#1,d1
	jsr	_LVOAddThese(a6)
	move.b	d1,(a4)

	move.l	cfh,d1
	move.l	a4,d2
	move.l	#1,d3
	CALLDOS	Write
	move.l	cfh,d1
	move.l	#10,d2
	move.l	#1,d3
	CALLDOS	Write

exit_closejw
	movea.l	_JwBase(pc),a1
	CALLEXEC	CloseLibrary
	bra	exit_closeconfile

exit_error
	suba.l	a0,a0
	CALLINT	DisplayBeep

exit_closeconfile
	move.l	#200,d1
	CALLDOS	Delay
	move.l	cfh,d1
	CALLDOS	Close

exit_closedos
	movea.l	_DOSBase(pc),a1
	CALLEXEC	CloseLibrary

exit_closegfx
	move.l	_GfxBase(pc),a1
	CALLEXEC	CloseLibrary

exit_closeint
	movea.l	_IntuitionBase(pc),a1
	CALLEXEC	CloseLibrary

exit_quit
	move.l	d4,d0
	rts


 * Sub-Routines.


 * Structure Definitions.


 * Include Variables.

_IntuitionBase	dc.l	0
_DOSBase	dc.l	0
_GfxBase	dc.l	0
_JwBase		dc.l	0
int_name	dc.b	'intuition.library',0
dos_name	dc.b	'dos.library',0
graf_name	dc.b	'graphics.library',0
jwlib_name	dc.b	'jw.library',0
	even


 * File Variables.

cfh		dc.l	0
cnode		dc.l	0
cname	dc.b	'CON:0/0/100/100/ Debug',0
	even


 * Misc Variables, etc.

bytebuf	dcb.b	12,0


	END