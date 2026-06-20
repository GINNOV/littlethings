*********************** BC Open/Close Libraries Module *********************

	OPT O+

	XDEF	_GadToolsBase
	XDEF	_IntuitionBase
	XDEF	_GfxBase
	XDEF	_SysBase

	XDEF	OpenLibs
	XDEF	CloseLibs
	XDEF	ErrorFlag

	incdir	dh1:devpac/projects
	include	system.i			;to allow easy library opening

OpenLibs:	
	move.l	4.l,_SysBase		;initialise exec lib base
	lea	int_name(pc),a1		;name of intuition library
	moveq.l	#36,d0			;version
	CALLEXEC	OpenLibrary		;open intuition
	move.l	d0,_IntuitionBase		;save intuition base address
	beq.s	seterrorflag		;quit if unopened
	lea	graf_name(pc),a1		;name of graphics library
	moveq.l	#36,d0			;version
	CALLEXEC	OpenLibrary		;do it
	move.l	d0,_GfxBase		;save pointer
	beq.s	seterrorflag		;quit if it hasn't
	lea	gad_name(pc),a1		;name of lib
	moveq.l	#36,d0			;version
	CALLEXEC	OpenLibrary		;do it
	move.l	d0,_GadToolsBase		;save pointer
	beq.s	seterrorflag		;quit if not opened
	rts

seterrorflag:				;set flag to TRUE and return
	move.b	#1,ErrorFlag
	rts

CloseLibs:				;close libs-intuition
	tst.l	_IntuitionBase
	beq.s	closegfx
	move.l	_IntuitionBase,a1		;intuition pointer
	CALLEXEC	CloseLibrary		;close intuition
closegfx:	tst.l	_GfxBase
	beq.s	closegt
	move.l	_GfxBase,a1		;graphics pointer
	CALLEXEC	CloseLibrary		;do it
closegt:	tst.l	_GadToolsBase
	beq.s	closenomore
	move.l	_GadToolsBase,a1		;pointer to lib
	CALLEXEC	CloseLibrary		;do it
closenomore:
	rts

********************* space for lib base addresses/names *******************

	even
_IntuitionBase:
	dc.l	0			;base address of intuition
_GfxBase:	dc.l	0			;base address of graphics
_GadBase:
_GadToolsBase:
	dc.l	0			;base address of gadtools
_SysBase	dc.l	0			;base address of exec
_UtilityBase:
	dc.l	0			;base address of utility
ErrorFlag:dc.b	0			;flag to indicate error
					;in opening libraries
	even
int_name:	INTNAME				;macros for library names
	even				;from libname_lib.i files
graf_name:GRAFNAME
	even
gad_name:	GADNAME
	even
utilname:	UTILNAME
