

*****	Title		Example_Macros
*****	Function	Checks a number of macros :-)
*****			 Written to check v1.0 subroutines.
*****			
*****	Size		2732 bytes
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

; Open a custom screen using current colours

		OPENSCREEN	#MyScreen		use macro
		move.l		d0,screen.ptr		check for errors
		beq		no_libs			quit if found

; Open a window on this screen

		OPENWIN		#MyWindow,#WinText,,,#ProjectMenu,screen.ptr
		move.l		d0,window.ptr		save struct ptr
		beq.s		no_win			quit if error

; fade screen out

		FADEOUT		screen.ptr		use macro

; fade screen in using custom palette

		FADEIN		screen.ptr,#Palette	use macro

; Wait for close gadget to be hit

		HANDLEIDCMP	window.ptr,#DoOther	use macro
		
; fade out before removing

		FADEOUT		screen.ptr		use macro

; close the window

		CLOSEWIN	window.ptr		use macro

; close the screen

no_win		CLOSESCREEN	screen.ptr		use macro
	
no_libs		bsr		CloseLibs		close open libraries

		rts					finish

;--------------
;--------------	Routines called by gadgets and menus
;--------------

DoQuit		move.l		#CLOSEWINDOW,D2		EXIT !
		rts

DoOther		rts

DoAbout		OPENWIN		#AboutWindow,#AboutText,,,,screen.ptr
		move.l		d0,about.ptr
		beq		.Done
		
		HANDLEIDCMP	about.ptr
		
		CLOSEWIN	about.ptr

.Done		rts

;--------------	Pull in subroutines


		include		OpenCloseLibs.i
		include		Subroutines.i

;***********************************************************
;	Screen, Window and Gadget defenitions
;***********************************************************

TmpPalette	dcb.w		15,0			All BLACK palette

*---------------------------------------------------
* Gadgets created with PowerSource V3.0 { source tidied by me:-) }
* which is (c) Copyright 1990-91 by Jaba Development
* written by Jan van den Baard
*---------------------------------------------------

MyScreen:
    DC.W    0,0,640,256
    DC.W    4
    DC.B    -1,-1
    DC.W    V_HIRES
    DC.W    CUSTOMSCREEN
    DC.L    0,0,0,0

Palette
	dc.w	$0000
	dc.w	$0ECA
	dc.w	$0C00
	dc.w	$0F60
	dc.w	$0090
	dc.w	$03F1
	dc.w	$000F
	dc.w	$02CD
	dc.w	$0F0C
	dc.w	$0A0F
	dc.w	$0950
	dc.w	$0FFF
	dc.w	$0FE0
	dc.w	$0CCC
	dc.w	$0888
	dc.w	$0444



MyWindow:
    DC.W    0,18,640,226
    DC.B    0,1
    DC.L    GADGETDOWN+GADGETUP+CLOSEWINDOW+MENUPICK+VANILLAKEY
    DC.L    WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+NOCAREREFRESH+SMART_REFRESH+ACTIVATE
    DC.L    AboutGadg,0
    DC.L    _window_title
    DC.L    0,0
    DC.W    150,50,640,256,CUSTOMSCREEN

_window_title:
    DC.B    ' Complete Subroutines Example ',0
    EVEN

;--------------	Menu defenition

ProjectMenu
    DC.L    0
    DC.W    0,0,72,8
    DC.W    MENUENABLED
    DC.L    .Name
    DC.L    AboutItem
    DC.W    0,0,0,0

.Name
    DC.B    'Project',0
    EVEN

AboutItem
    DC.L    QuitItem
    DC.W    0,0,72,9
    DC.W    ITEMENABLED+HIGHCOMP+ITEMTEXT
    DC.L    0
    DC.L    .IText,0
    DC.B    0,0
    DC.L    0
    DC.W    0
    dc.l    DoAbout	pointer to routine to call if item selected
.IText
    DC.B    3,8,RP_JAM1,0
    DC.W    1,1
    DC.L    0
    DC.L    .Text,0

.Text
    DC.B    'About',0
    EVEN

QuitItem
    DC.L    0
    DC.W    0,9,72,9
    DC.W    ITEMENABLED+HIGHCOMP+ITEMTEXT
    DC.L    0
    DC.L    .IText,0
    DC.B    0,0
    DC.L    VerQuitItem
    DC.W    0
    dc.l    0		no routine to call for this item, never selected
.IText
    DC.B    3,8,RP_JAM1,0
    DC.W    1,1
    DC.L    0
    DC.L    .Text,0

.Text
    DC.B    'Quit',0
    EVEN

VerQuitItem
    DC.L    0
    DC.W    72,0,116,9
    DC.W    ITEMENABLED+HIGHCOMP+ITEMTEXT
    DC.L    0
    DC.L    .IText,0
    DC.B    0,0
    DC.L    0
    DC.W    0
    dc.l    DoQuit	Pointer to routine to call if item selected!

.IText
    DC.B    0,2,RP_JAM1,0
    DC.W    1,1
    DC.L    0
    DC.L    .Text,0

.Text
    DC.B    'Are You Sure ?',0
    EVEN

AboutGadg:
	dc.l	QuitGadg
	dc.w	25,147
	dc.w	143,26
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoAbout

.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0

.Vectors
	dc.w	0,0
	dc.w	146,0
	dc.w	146,27
	dc.w	0,27
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	42,9
	dc.l	0
	dc.l	.Text
	dc.l	0

.Text
	dc.b	'About',0
	even

QuitGadg:
	dc.l	0
	dc.w	449,148
	dc.w	143,26
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoQuit

.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0

.Vectors
	dc.w	0,0
	dc.w	146,0
	dc.w	146,27
	dc.w	0,27
	dc.w	0,0

.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	53,9
	dc.l	0
	dc.l	.Text
	dc.l	0

.Text
	dc.b	'Quit',0
	even

WinText
	dc.b	3,0,RP_JAM2,0
	dc.w	216,47
	dc.l	0
	dc.l	.Text
	dc.l	0

.Text
	dc.b	'Use menu or Gadgets ',0
	even

;--------------	Equates for about window

AboutWindow
	dc.w	166,19
	dc.w	277,155
	dc.b	0,1
	dc.l	GADGETUP
	dc.l	ACTIVATE+NOCAREREFRESH
	dc.l	ContGadg
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,200
	dc.w	CUSTOMSCREEN

ContGadg:
	dc.l	0
	dc.w	53,112
	dc.w	172,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoQuit

.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0

.Vectors
	dc.w	0,0
	dc.w	175,0
	dc.w	175,14
	dc.w	0,14
	dc.w	0,0

.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	49,3
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Continue',0
	even

AboutText
	dc.b	3,0,RP_JAM2,0
	dc.w	32,15
	dc.l	0
	dc.l	.Text
	dc.l	.IText

.Text
	dc.b	'This example was written',0
	even

.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	40,25
	dc.l	0
	dc.l	.Text1
	dc.l	.IText1

.Text1
	dc.b	'using my system macros.',0
	even

.IText1
	dc.b	3,0,RP_JAM2,0
	dc.w	90,57
	dc.l	0
	dc.l	.Text2
	dc.l	0

.Text2
	dc.b	"ACC in '92.",0
	even


;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

screen.ptr	ds.l		1

window.ptr	ds.l		1
about.ptr	ds.l		1


