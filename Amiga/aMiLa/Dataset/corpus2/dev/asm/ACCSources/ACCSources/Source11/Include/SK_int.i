;INTUITION macros ; Simon Knipe ; v1.0

;	OPENWIND	open intuition window
;	SMARTOPENWIND	open intuition window, jump if error
;	CLOSEWIND	close previously opened window
;	OPENSCR		open custom screen
;	CLOSESCR	close previously opened screen
;	PRINTTEXT	print text into window

********************************************************* INTUITION ***
;Purpose: open intuition window
;To call: OPENWIND WindowStructure,WindowHandle

OPENWIND MACRO
	move.l	intbase,a6
	lea	\1,a0	adr of window structure
	jsr	openwindow(a6)
	move.l	d0,\2	save window handle
	ENDM
********************************************************* INTUITION ***
;Purpose: open intuition window, jump if error
;To call: SMARTOPENWIND WindowStructure,WindowHandle,BranchIfError

SMARTOPENWIND MACRO
	move.l	intbase,a6
	lea	\1,a0	adr of window structure
	jsr	openwindow(a6)
	move.l	d0,\2	save window handle
	tst.l	d0	check if error
	beq	\4
	ENDM
********************************************************* INTUITION ***
;Purpose: close previously opened window
;To call: CLOSEWIND WindowHandle

CLOSEWIND MACRO
	move.l	intbase,a6
	move.l	\1,a0	recover window handle
	jsr	closewindow(a6)
	ENDM
********************************************************* INTUITION ***
;Purpose: open custom screen
;To call: OPENSCR ScreenStruct,ScreenHandle

OPENSCR MACRO
	move.l	intbase,a6
	lea	\1,a0	screen struct
	jsr	openscreen(a6)
	move.l	d0,\2	save screen handle
	ENDM
********************************************************* INTUITION ***
;Purpose: close previously opened screen
;To call: CLOSESCR ScreenHandle

CLOSESCR MACRO
	move.l	intbase,a6
	move.l	\1,a0	get screen handle
	jsr	closescreen(a6)
	ENDM
********************************************************* INTUITION ***
;Purpose: print text into a window
;To call: PRINTTEXT WindowHandle,X,Y,TextAddress

PRINTTEXT MACRO
	move.l	intbase,a6
	move.l	\1,a0	window handle
	move.l	50(a0),a0	RastPort
	lea	\4,a1	text to print, 0 to mark end
	move.l	\2,d0	X position
	move.l	\3,d1	Y position
	jsr	printitext(a6)
	ENDM
