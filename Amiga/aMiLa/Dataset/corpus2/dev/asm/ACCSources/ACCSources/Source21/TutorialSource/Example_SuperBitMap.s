

*****	Title		SuperBitMap window test on custom screen
*****	Function	A basic Intuition startup module that opens a window
*****			on a custom screen. Written to check v1.0 
*****			subroutines.
*****			
*****	Size		1716 bytes
*****	Author		Mark Meany
*****	Date Started	Feb 92
*****	This Revision	Feb 92
*****	Notes		
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

; Open custom screen

		OPENSCREEN	#MyScreen,#Palette	use macro
		move.l		d0,screen.ptr		check for errors
		beq		no_libs			quit if found

; Allocate bitplanes and init a BitMap struct

		BITMAP		#640,#256,#4		get a BitMap struct
		move.l		d0,bitmap.ptr		save pointer
		beq		no_bm			quit if error		

; Now open a SuperBitMap window and print some text in it

		OPENSBWIN	#MyWindow,bitmap.ptr,#WinText,,,,screen.ptr
		move.l		d0,window.ptr		save pointer
		beq.s		no_win			quit if error
		
; Wait for user to click close gadget

		HANDLEIDCMP	window.ptr		use macro

; Close the window

		CLOSEWIN	window.ptr		use macro

; Free BitMap and bit plane memory

no_win		FREEBITMAP	bitmap.ptr		use macro

; Close the screen

no_bm		CLOSESCREEN	screen.ptr		use macro

; Close libraries

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

MyWindow
    DC.W    56,12,462,167
    DC.B    0,1
    DC.L    CLOSEWINDOW
    DC.L    WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+NOCAREREFRESH+SUPER_BITMAP+GIMMEZEROZERO+ACTIVATE
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

.Text		dc.b		' This text survives a resize, try it! ',0		the text itself
		even

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

screen.ptr	ds.l		1

window.ptr	ds.l		1
window.rp	ds.l		1
window.up	ds.l		1
bitmap.ptr	ds.l		1

