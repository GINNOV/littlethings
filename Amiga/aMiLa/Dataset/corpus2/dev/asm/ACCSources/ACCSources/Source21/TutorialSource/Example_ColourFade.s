

*****	Title		ColourFadeTest
*****	Function	Check Screen fade-in and fade-out routines.
*****			 Written to check v1.0 subroutines.
*****			
*****	Size		1782 bytes
*****	Author		Mark Meany
*****	Date Started	Feb 92
*****	This Revision	Feb 92
*****	Notes		Going strong
*****			


		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos_lib.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"
		


		include		SysMacros.i


		bsr		OpenLibs		open libraries
		tst.l		d0			any errors?
		beq		no_libs			if so quit

; Open a custom screen using current colours

		OPENSCREEN	#MyScreen		use macro
		move.l		d0,screen.ptr		check for errors
		beq		no_libs			quit if found

; Open a window on this screen

		OPENWIN		#MyWindow,#WinText,,,,screen.ptr
		move.l		d0,window.ptr		save struct ptr
		beq.s		no_win			quit if error

; fade screen out

		FADEOUT		screen.ptr		use macro

; fade screen in using custom palette

		FADEIN		screen.ptr,#Palette	use macro

; Wait for close gadget to be hit

		HANDLEIDCMP	window.ptr		use macro
		
; fade out before removing

		FADEOUT		screen.ptr		use macro

; close the window

		CLOSEWIN	window.ptr		use macro

; close the screen

no_win		CLOSESCREEN	screen.ptr		use macro
	
no_libs		bsr.s		CloseLibs		close open libraries

		rts					finish

		include		OpenCloseLibs.i
		include		Subroutines.i

;***********************************************************
;	Screen, Window and Gadget defenitions
;***********************************************************

MyScreen
	dc.w	0,0		;screen XY origin relative to View
	dc.w	640,256		;screen width and height
	dc.w	4		;screen depth (number of bitplanes)
	dc.b	0,1		;detail and block pens
	dc.w	V_HIRES		;display modes for this screen
	dc.w	CUSTOMSCREEN	;screen type
	dc.l	0		;pointer to default screen font
	dc.l	.Title		;screen title
	dc.l	0		;first in list of custom screen gadgets
	dc.l	0		;pointer to custom BitMap structure

.Title	dc.b	'This is a sixteen colour screen',0
	even

Palette
	dc.w	$02CD		;color #0
	dc.w	$0000		;color #1
	dc.w	$0C00		;color #2
	dc.w	$0B96		;color #3
	dc.w	$0090		;color #4
	dc.w	$03F1		;color #5
	dc.w	$0EA5		;color #6
	dc.w	$0ECA		;color #7
	dc.w	$0454		;color #8
	dc.w	$0400		;color #9
	dc.w	$0000		;color #10
	dc.w	$0101		;color #11
	dc.w	$0454		;color #12
	dc.w	$0400		;color #13
	dc.w	$0004		;color #14
	dc.w	$0C00		;color #15

TmpPalette	dcb.w		15,0			All BLACK palette

MyWindow
    DC.W    56,12,462,167
    DC.B    0,1
    DC.L    CLOSEWINDOW
    DC.L    WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+NOCAREREFRESH+SMART_REFRESH+ACTIVATE
    DC.L    0,0
    DC.L    .Window_title
    DC.L    0,0
    DC.W    150,50
    DC.W    640,256
    DC.W    CUSTOMSCREEN

.Window_title
    DC.B    'Marks Window',0
    EVEN

WinText		dc.b		1		FrontPen
		dc.b		0		BackPen
		dc.b		RP_JAM2		DrawMode
		dc.b		0		KludgeFill00
		dc.w		10		x position
		dc.w		15		y position
		dc.l		0		font
		dc.l		.Text		address of text to print
		dc.l		0		no more text

.Text		dc.b		' Hi World, Were Here! ',0		the text itself
		even

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

screen.ptr	ds.l		1

window.ptr	ds.l		1
window.rp	ds.l		1
window.up	ds.l		1
