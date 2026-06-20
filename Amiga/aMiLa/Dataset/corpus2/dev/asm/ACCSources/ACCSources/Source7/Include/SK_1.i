;INTUITION/EXEC/MISC Macros; SK 10-14 Nov 1990 ; v1.0
;needs Mark`s libs.i file to work
********************************************************* INTUITION ***
;To call: OPENWIND WindowStructure,WindowHandle

OPENWIND MACRO
	move.l	intbase,a6
	lea	\1,a0	adr of window structure
	jsr	OpenWindow(a6)
	move.l	d0,\2	save window handle
	ENDM
********************************************************* INTUITION ***
;To call: CLOSEWIND WindowHandle

CLOSEWIND MACRO
	move.l	intbase,a6
	move.l	\1,a0	recover window handle
	jsr	CloseWindow(a6)
	ENDM
********************************************************* INTUITION ***
;To call: OPENSCR ScreenStruct,ScreenHandle

OPENSCR MACRO
	move.l	intbase,a6
	lea	\1,a0	screen struct
	jsr	OpenScreen(a6)
	move.l	d0,\2	save screen handle
	ENDM
********************************************************* INTUITION ***
;To call: CLOSESCR ScreenHandle

CLOSESCR MACRO
	move.l	intbase,a6
	move.l	\1,a0	get screen handle
	jsr	CloseScreen(a6)
	ENDM
********************************************************* INTUITION ***
;To call: PRINTTEXT WindowHandle,X,Y,TextAddress

PRINTTEXT MACRO
	move.l	intbase,a6
	move.l	\1,a0	window handle
	move.l	50(a0),a0	RastPort
	lea	\4,a1	text to print, 0 to mark end
	move.l	\2,d0	X position
	move.l	\3,d1	Y position
	jsr	PrintIText(a6)
	ENDM
************************************************************** EXEC ***
;To call: OPENLIB LibraryName,LibraryBase

OPENLIB MACRO
	move.l	execbase,a6	get exec
	lea	\1,a1	name of library
	jsr	OldOpenLibrary(a6)
	move.l	d0,\2	save adr of library
	ENDM
************************************************************** EXEC ***
;To call: CLOSELIB LibraryBase

CLOSELIB MACRO
	move.l	execbase,a6	get exec
	move.l	\1,a1	get adr of lib
	jsr	CloseLibrary(a6)
	ENDM
************************************************************** EXEC ***
;To call: GETMEM BytesWanted,MemPointer

GETMEM MACRO
	move.l	\1,d0	number of bytes to get
	move.l	execbase,a6
	jsr	AllocMem(a6)	exec function
	move.l	d0,\2	save adr of mem taken
	ENDM
************************************************************** EXEC ***
;To call: RETURNMEM BytesTaken,MemPointer

RETURNMEM MACRO
	move.l	\1,d0	number of bytes to release
	move.l	\2,a1	adr of memory
	move.l	execbase,a6
	jsr	FreeMem(a6)	free it
	ENDM
*************************************************************** GFX ***
;To call: DRAWRECT WindowHandle,Colour,X,Y,Width,Height

DRAWRECT MACRO
	move.l	\1,a1	windowhandle
	move.l	50(a1),a1	RastPort
	move.l	gfxbase,a6	get gfx
	move.l	#\2,d0	colour
	jsr	SetAPen(a6)	set gfx colour
	move.l	#\3,d0	x-offset for draw
	move.l	#\4,d1	y-
	move.l	#\5,d2	width of rectangle
	move.l	#\6,d3	height-
	ext.l	d0
	ext.l	d1
	ext.l	d2
	ext.l	d3
	jsr	RectFill(a6)	clear the window
	ENDM
************************************************************** MISC ***
;To call: MAKECALL LibraryBase,LibraryCallOffset

MAKECALL MACRO
	move.l	\1,a6	library to use
	jsr	\2(a6)	call to make
	ENDM
************************************************************** MISC ***
;To call: CHECKFORKEY AsciiValue,BranchIfNot,FilenameBelongingToKey

CHECKFORKEY MACRO
		cmp.b		#\1,d1		check for ascii value
		bne		\2		no then branch
		lea		\3,a2		load filename
		lea		\3end,a3
		move.l		a3,fileend
		move.l		a2,file		save file adr
		bsr		printpage
		ENDM
***********************************************************************

