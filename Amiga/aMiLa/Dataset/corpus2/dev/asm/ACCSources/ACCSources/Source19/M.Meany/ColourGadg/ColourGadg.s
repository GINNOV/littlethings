
*****	Title		ColourGadg
*****	Function	Demonstrates how to open a custom screen and then
*****			display colourfull gadgets in it. Makes a joke of
*****			it at the same time!
*****	Size		11306 bytes.
*****	Author		Mark Meany
*****	Date Started	15th Dec 1991
*****	This Revision	15th Dec 1991
*****	Notes		Thanks DAZ for the GFX.
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

CALLSYS		macro
		ifgt	NARG-1
		FAIL	!!!
		endc
		jsr	_LVO\1(a6)
		endm

		section		Skeleton,code

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"

		move.l		a0,_args	save addr of CLI args
		move.l		d0,_argslen	and the length

		bsr.s		Openlibs	open libraries
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

		bsr		Init		Initialise data
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

		bsr		Openwin		open window
		tst.l		d0		any errors?
		beq.s		no_win		if so quit

		bsr		WaitForMsg	wait for user

		bsr		Closewin	close our window

no_win		bsr		DeInit		free resources

no_libs		bsr		Closelibs	close open libraries

		rts				finish


;**************	Open all required libraries

; Open DOS, Intuition and Graphics libraries.

; If d0=0 on return then one or more libraries are not open.

Openlibs	lea		dosname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_DOSBase	save base ptr
		beq.s		.lib_error	quit if error

		lea		intname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_IntuitionBase	save base ptr
		beq.s		.lib_error	quit if error

		lea		gfxname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_GfxBase	save base ptr

.lib_error	rts

*************** Initialise any data

;--------------	At present just set STD_OUT and check for usage text

Init		tst.l		returnMsg	are we from WorkBench?
		bne.s		.ok		if so ignore usage bit

		CALLDOS		Output		determine CLI handle
		move.l		d0,STD_OUT	and save it for later
		beq.s		.err		quit if there is no handle

		move.l		_args,a0	get addr of CLI args
		cmpi.b		#'?',(a0)	is the first arg a ?
		bne.s		.ok		if not skip the next bit

		lea		_UsageText,a0	a0->the usage text
		bsr		DosMsg		and display it
.err		moveq.l		#0,d0		set an error
		bra.s		.error		and finish

;--------------	Your Initialisations should start here

.ok		moveq.l		#1,d0		no errors

.error		rts				back to main


*************** Open An Intuition Window

; Opens an intuition window. If d0=0 on return then window could not be
;opened.

Openwin		lea		MyScreen,a0
		CALLINT		OpenScreen
		move.l		d0,screen.ptr
		beq.s		.win_error

		move.l		d0,a0
		lea		sc_ViewPort(a0),a0
		move.l		a0,screen.vp

		move.l		d0,win_scrn

		lea		Palette,a1
		moveq.l		#8,d0
		CALLGRAF	LoadRGB4

		lea		MyWindow,a0	a0->window args
		CALLINT		OpenWindow	and open it
		move.l		d0,window.ptr	save struct ptr
		beq.s		.win_error	quit if error

		move.l		d0,a0			  ;a0->win struct	
		move.l		wd_UserPort(a0),window.up ;save up ptr
		move.l		wd_RPort(a0),window.rp    ;save rp ptr

.win_error	rts				all done so return

*************** Deal with User interaction

; At present only supports gadget selection. Address of routine to call
;when a gadget is selected should be stored in the gg_UserData field
;of that gadgets structure. All gadget/menu service subroutines should set
;d2=0 to ensure accidental QUIT is not forced. If a QUIT gadget is used
;it should set d2=CLOSEWINDOW.


WaitForMsg	move.l		window.up,a0	a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		window.up,a0	a0-->window pointer
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WaitForMsg	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.l		im_IAddress(a1),a5 a5=addr of structure
		CALLSYS		ReplyMsg	answer os or it get angry

		move.l		d2,d0
		and.l		#GADGETUP!GADGETDOWN,d0
		beq.s		WaitForMsg

		rts


*************** Close the Intuition window.

Closewin	move.l		window.ptr,a0	a0->Window struct
		CALLINT		CloseWindow	and close it

		move.l		screen.ptr,a0
		CALLINT		CloseScreen

		rts

***************	Release any additional resources used

DeInit
		rts

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
*			Useful Subroutines Section					    *
*****************************************************************************


***************	Subroutine to display any message in the CLI window

; Entry		a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

DosMsg		movem.l		d0-d3/a0-a3,-(sp) save registers

		tst.l		STD_OUT		test for open console
		beq		.error		quit if not one

		move.l		a0,a1		get a working copy

;--------------	Determine length of message

		moveq.l		#-1,d3		reset counter
.loop		addq.l		#1,d3		bump counter
		tst.b		(a1)+		is this byte a 0
		bne.s		.loop		if not loop back

;--------------	Make sure there was a message

		tst.l		d3		was there a message ?
		beq.s		.error		if not, graceful exit

;--------------	Get handle of output file

		move.l		STD_OUT,d1	d1=file handle
		beq.s		.error		leave if no handle

;--------------	Now print the message
;		At this point, d3 already holds length of message
;		and d1 holds the file handle.

		move.l		a0,d2		d2=address of message
		CALLDOS		Write		and print it

;--------------	All done so finish

.error		movem.l		(sp)+,d0-d3/a0-a3 restore registers
		rts


*****************************************************************************
*			Data Section					    *
*****************************************************************************

dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even
gfxname		dc.b		'graphics.library',0
		even

; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		'This is only a skeleton routine written for:'
		dc.b		$0a
		dc.b		'       ACC discs Intuition Tutorials!'
		dc.b		$0a
		dc.b		0
		even

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_args		ds.l		1
_argslen	ds.l		1

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

window.ptr	ds.l		1
window.rp	ds.l		1
window.up	ds.l		1

screen.ptr	ds.l		1
screen.vp	ds.l		1

STD_OUT		ds.l		1

		section win,data

MyScreen	dc.w		0,0		screen XY origin
		dc.w		640,200		screen width and height
		dc.w		3		screen depth
		dc.b		0,1		detail and block pens
		dc.w		V_HIRES		display modes for this screen
		dc.w		CUSTOMSCREEN	screen type
		dc.l		0		default font
		dc.l		0		screen title
		dc.l		0		first custom screen gadgets
		dc.l		0		pointer to custom BitMap

Palette		dc.w		$0000		color00
		dc.w		$0FFF		color01
		dc.w		$03B0		color02
		dc.w		$0F47		color03
		dc.w		$0F9E		color04
		dc.w		$0E6B		color05
		dc.w		$03F5		color06
		dc.w		$0DCF		color07

ColorCount 	equ 		8

MyWindow	dc.w		125,5		window XY origin
		dc.w		302,187		window width and height
		dc.b		0,1		detail and block pens
		dc.l		GADGETUP	IDCMP flags
		dc.l		ACTIVATE+NOCAREREFRESH	other window flags
		dc.l		JokeGadg	first gadget in gadget list
		dc.l		0		custom CHECKMARK imagery
		dc.l		0		window title
win_scrn	dc.l		0		custom screen pointer
		dc.l		0		custom bitmap
		dc.w		5,5		minimum width and height
		dc.w		640,200		maximum width and height
		dc.w		CUSTOMSCREEN	destination screen type

JokeGadg	dc.l		0		next gadget
		dc.w		1,1		origin XY of hit box
		dc.w		300,185		hit box width and height
		dc.w		GADGHIMAGE+GADGIMAGE	gadget flags
		dc.w		RELVERIFY	activation flags
		dc.w		BOOLGADGET	gadget type flags
		dc.l		.Im1		select image to be rendered
		dc.l		.Im2		render image to be rendered
		dc.l		0		first IntuiText structure
		dc.l		0		mutual-exclude
		dc.l		0		SpecialInfo structure
		dc.w		0		user-definable data
		dc.l		0		user data

.Im1		dc.w		0,0		XY origin
		dc.w		300,185		Image width and height
		dc.w		3		number of bitplanes in Image
		dc.l		ImData1		pointer to ImageData
		dc.b		$0007,$0000	PlanePick and PlaneOnOff
		dc.l		0		next Image structure

.Im2		dc.w		2,1		XY origin
		dc.w		300,185		Image width and height
		dc.w		3		number of bitplanes in Image
		dc.l		ImData2		pointer to ImageData
		dc.b		$0007,$0000	PlanePick and PlaneOnOff
		dc.l		0		next Image structure


		section		im,data_c

ImData1		incbin		joke.bm

ImData2		incbin		punch.bm


