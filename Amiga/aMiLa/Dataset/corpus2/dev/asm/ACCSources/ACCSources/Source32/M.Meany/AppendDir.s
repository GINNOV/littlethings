

*****	Title		DOS start
*****	Function	
*****			
*****			
*****	Size		
*****	Author		Mark Meany
*****	Date Started	Apr 93
*****	This Revision	
*****	Notes		Variables accessed from register a5.
*****			If program is launched from WB, it simply quits!
*****			FileLen routine uses dos Seek() command.
*****			LoadFile releases buffer if Open() fails.



	incdir	sys:include2.0/
	include exec/exec.i
	include exec/exec_lib.i

	include libraries/dos.i
	include libraries/dosextens.i
	include libraries/dos_lib.i

	include graphics/gfxbase.i
	include	graphics/graphics_lib.i

	include intuition/intuition.i
	include intuition/intuition_lib.i

	include	devices/console_lib.i
	include devices/inputevent.i


		section		Skeleton,code

; Include easystart to allow a Workbench startup.

		lea		Variables,a5		a5->var base
	
		move.l		a0,_args(a5)		save addr of CLI args
		move.l		d0,_argslen(a5)		and the length

		bsr.s		Openlibs		open libraries
		tst.l		d0			any errors?
		beq.s		no_libs			if so quit

		bsr		Main

no_libs		bsr		Closelibs		close open libraries

		rts					finish


;**************	Open all required libraries

; Open DOS, Intuition and Graphics libraries.

; If d0=0 on return then one or more libraries are not open.

Openlibs	lea		dosname,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_DOSBase		save base ptr
		beq.s		.lib_error		quit if error

		lea		intname,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_IntuitionBase	save base ptr
		beq.s		.lib_error		quit if error

		lea		gfxname,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_GfxBase		save base ptr

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

*****************************************************************************
*			Data Section					    *
*****************************************************************************

;		dc.b		'$VER: v'
;		REVISION
;		dc.b		', © M.Meany ('
;		REVDATE
;		dc.b		')',0
;		even

dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even
gfxname		dc.b		'graphics.library',0
		even

;***********************************************************
;	SECTION	Vars,BSS
;***********************************************************

		rsreset
_args		rs.l		1
_argslen	rs.l		1

Buffer		rs.b		300

varsize		rs.b		0

		SECTION	Vars,BSS

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

Variables	ds.b		varsize

		section		Skeleton,code

***** Your code goes here!!!

; NOTES: dos, graphics and intuition libraries are open.
;	 Register a5 is used to access variables, add your own to defenitions
;	 above.
;	 _args(a5) and _argslen(a5) contain startup values of a0,d0

; Read in the env variable localdir
; append 'HW_Manual' to it
; Save it

Main		lea		.VarName(pc),a4
		move.l		a4,d1
		lea		Buffer(a5),a4
		move.l		a4,d2
		move.l		#256,d3
		moveq.l		#0,d4
		CALLDOS		GetVar
		tst.l		d0
		beq.s		.Done			skip if failed
		bmi.s		.Done			skip if not defined

; Locate end of directory

.DirLoop	tst.b		(a4)+
		bne.s		.DirLoop
		subq.l		#1,a4			a4->NULL

; See if we need to append a /

		cmp.b		#':',-1(a4)
		bne.s		.NotRoot
		
		move.b		#'/',(a4)+

; Append the dir name

.NotRoot	lea		.DirName(pc),a0
.CopyLoop	move.b		(a0)+,(a4)+
		bne.s		.CopyLoop
		
; Set ENV var to default

		lea		.VarName(pc),a4
		move.l		a4,d1
		lea		Buffer(a5),a4
		move.l		a4,d2
		moveq.l		#-1,d3			text NULL terminated
		moveq.l		#0,d4
		CALLDOS		SetVar
		
.Done		moveq.l		#0,d0
		rts

.VarName	dc.b		'localDir',0
		even
.DirName	dc.b		'HW_Manual',0
		even
