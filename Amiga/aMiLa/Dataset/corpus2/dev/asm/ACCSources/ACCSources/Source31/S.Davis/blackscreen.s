* black screen program V1.0 ©1993 Stuart Davis

            *** dosen't work on A1200??? why not??? ***

	SECTION	exe,CODE


	incdir	sys:include/
	include	devices/inputevent.i
	include	devices/timer.i
	include	devices/serial.i

	include	exec/types.i
	include	exec/exec.i
	include	exec/exec_lib.i
	include	exec/io.i
	include	exec/libraries.i
	include	exec/lists.i
	include	exec/memory.i
	include	exec/nodes.i
	include	exec/ports.i
	include	exec/semaphores.i
	include	exec/tasks.i
	include	exec/execbase.i
	include	exec/errors.i
	include	exec/interrupts.i

	include	graphics/clip.i
	include	graphics/copper.i
	include	graphics/gfx.i
	include	graphics/gfxnodes.i
	include	graphics/graphics_lib.i
	include	graphics/layers.i
	include	graphics/rastport.i
	include	graphics/text.i
	include	graphics/view.i
	include	graphics/gfxbase.i

	include	hardware/intbits.i

	include	intuition/intuition.i
	include	intuition/intuition_lib.i
	include	intuition/intuitionbase.i
	include	intuition/iobsolete.i
	include	intuition/preferences.i
	include	intuition/screens.i

	include	libraries/dos.i
	include	libraries/dos_lib.i
	include	libraries/dosextens.i
	include	libraries/translator.i
	include	libraries/translator_lib.i
	include	libraries/gadtools.i
	include	libraries/gadtools_lib.i
	include	libraries/asl.i
	include	libraries/asl_lib.i
	include	libraries/reqtools.i
	include	libraries/reqtools_lib.i

	include	utility/utility.i
	include	utility/utility_lib.i
	include	utility/tagitem.i

	include	workbench/startup.i
	include	workbench/icon_lib.i


* firstly open the intuition library
	lea	intname(pc),a1
	moveq.l	#0,d0			;dont care which version
	CALLEXEC	OpenLibrary
	move.l	d0,_IntuitionBase		;store lib pointer
	beq.s	goawayfast		;if didnt open

* make screen black
	lea	Prefs(pc),a0		;Buffer to store Prefs in
	moveq.l	#118,d0			;Buffer size
	CALLINT	GetPrefs			;get wb prefs
	lea	Prefs(pc),a0		;pointers to buffers
	move.w	#$000,110(a0)		;new screen colours
	move.w	#$000,112(a0)
	move.w	#$000,114(a0)
	move.w	#$000,116(a0)

	moveq.l	#118,d0			;Size
	moveq.w	#0,d1			;0=temp change
	CALLINT	SetPrefs			;do it

	move.l	_IntuitionBase,a1
	CALLEXEC	CloseLibrary
goawayfast:
	moveq.l	#0,d0
	rts

************************** data *******************************************

* strings here
	even
intname:	INTNAME				;name of intuition lib

* variables here
	even
_IntuitionBase:
	dc.l	0			;for int library
Prefs:	dcb.b	118			;Storage for preferences
