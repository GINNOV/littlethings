
*****	Title		DMRequester
*****	Function	An attempt at implementing a DMRequester.
*****			This is an adaption of a program from the ROM
*****			Kernel Reference Manual, Libraries & Devices.
*****	Size		1428 bytes.
*****	Author		Mark Meany
*****	Date Started	Dec 1991
*****	This Revision	Dec 1991
*****	Notes		Another Int_Start.s conversion!

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

Openwin		lea		MyWindow,a0	a0->window args
		CALLINT		OpenWindow	and open it
		move.l		d0,window.ptr	save struct ptr
		beq.s		.win_error	quit if error

		move.l		d0,a0			  ;a0->win struct	
		move.l		wd_UserPort(a0),window.up ;save up ptr
		move.l		wd_RPort(a0),window.rp    ;save rp ptr

;--------------	Display basic usage text for user

		move.l		window.rp,a0	a0->windows RastPort
		lea		WinText,a1	a1->IText structure
		moveq.l		#10,d0		X offset
		moveq.l		#15,d1		Y offset
		CALLINT		PrintIText	print this text

		move.l		window.ptr,a0	a0->window
		lea		MyReq,a1	a1->requester
		CALLINT		SetDMRequest	add requester

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

.test_win	cmp.l		#CLOSEWINDOW,d2  window closed ?
		bne.s		WaitForMsg	 if not then jump
		rts


*************** Close the Intuition window.

Closewin	move.l		window.ptr,a0	a0->Window struct
		CALLINT		CloseWindow	and close it
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
;	Window and Gadget defenitions
;***********************************************************


MyWindow	dc.w		101,9
		dc.w		400,190
		dc.b		1,2
		dc.l		CLOSEWINDOW
		dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
		dc.l		0		;gadgets
		dc.l		0
		dc.l		WindowName
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

WindowName	dc.b		' DMRequester trials by M.Meany. ',0
		even


WinText		dc.b		1		FrontPen
		dc.b		0		BackPen
		dc.b		RP_JAM2		DrawMode
		dc.b		0		KludgeFill00
		dc.w		0		x position
		dc.w		0		y position
		dc.l		0		font
OurText		dc.l		.Text		address of text to print
		dc.l		0		no more text

.Text		dc.b		"'Double-Click' Menu Button",0		the text itself
		even

MyReq		dc.l		0		old requester
		dc.w		79,14		leftedge,topedge
		dc.w		149,85		width,height
		dc.w		-75,-43		rel left, rel right
		dc.l		Gadg1		ptr to gadget list
		dc.l		ReqBorder	ptr to border
		dc.l		ReqText		ptr to text
		dc.w		POINTREL	flags
		dc.b		0		fill pen
		dc.b		0		Kludge Fill
		dc.l		0		Layer
		ds.b		32		God Knows
		dc.l		0		Image ptr
		dc.l		0		RWindow
		ds.b		36		God knows
		even				incase

Gadg1		dc.l		Gadg2		next gadget
		dc.w		35,20		origin XY of hit box relative to window TopLeft
		dc.w		73,10		hit box width and height
		dc.w		GADGHCOMP+GADGIMAGE		gadget flags
		dc.w		RELVERIFY+GADGIMMEDIATE+ENDGADGET+BOOLEXTEND	activation flags
		dc.w		BOOLGADGET+REQGADGET		gadget type 
		dc.l		Button		gadget border or image to be rendered
		dc.l		0		alternate imagery for selection
		dc.l		.IText		first IntuiText structure
		dc.l		0		gadget mutual-exclude long word
		dc.l		BMask		SpecialInfo structure --- BoolInfo structure
		dc.w		0		user-definable data
		dc.l		0		pointer to user-definable data

.IText		dc.b		2,0,RP_JAM1,0	front and back text pens, drawmode and fill byte
		dc.w		21,1		XY origin relative to container TopLeft
		dc.l		TOPAZ80		font pointer or NULL for default
		dc.l		.ITextText	pointer to text
		dc.l		0		next IntuiText structure

.ITextText	dc.b		'Slow',0
		even

Gadg2		dc.l		Gadg3		next gadget
		dc.w		35,40		origin XY of hit box relative to window TopLeft
		dc.w		73,10		hit box width and height
		dc.w		GADGHCOMP+GADGIMAGE		gadget flags
		dc.w		RELVERIFY+GADGIMMEDIATE+ENDGADGET+BOOLEXTEND		activation flags
		dc.w		BOOLGADGET+REQGADGET		gadget type flags
		dc.l		Button		gadget border or image to be rendered
		dc.l		0		alternate imagery for selection
		dc.l		.IText		first IntuiText structure
		dc.l		0		gadget mutual-exclude long word
		dc.l		BMask		SpecialInfo structure --- BoolInfo structure
		dc.w		0		user-definable data
		dc.l		0		pointer to user-definable data

.IText		dc.b		2,0,RP_JAM1,0	front and back text pens, drawmode and fill byte
		dc.w		22,1		XY origin relative to container TopLeft
		dc.l		TOPAZ80		font pointer or NULL for default
		dc.l		.ITextText	pointer to text
		dc.l		0		next IntuiText structure

.ITextText	dc.b		'Fast',0
		even

Gadg3		dc.l		0		next gadget
		dc.w		35,60		origin XY of hit box relative to window TopLeft
		dc.w		73,10		hit box width and height
		dc.w		GADGHCOMP+GADGIMAGE		gadget flags
		dc.w		RELVERIFY+GADGIMMEDIATE+ENDGADGET+BOOLEXTEND		activation flags
		dc.w		BOOLGADGET+REQGADGET		gadget type flags
		dc.l		Button		gadget border or image to be rendered
		dc.l		0		alternate imagery for selection
		dc.l		.IText		first IntuiText structure
		dc.l		0		gadget mutual-exclude long word
		dc.l		BMask		SpecialInfo structure --- BoolInfo structure
		dc.w		0		user-definable data
		dc.l		0		pointer to user-definable data

.IText		dc.b		2,0,RP_JAM1,0	front and back text pens, drawmode and fill byte
		dc.w		22,1		XY origin relative to container TopLeft
		dc.l		TOPAZ80		font pointer or NULL for default
		dc.l		.ITextText	pointer to text
		dc.l		0		next IntuiText structure

.ITextText	dc.b		'Exit',0
		even

Button		dc.w		0,0		leftedge topedge
		dc.w		73,10		width, height
		dc.w		1		depth
		dc.l		ImageData
		dc.b		1,0		planepick, planeonoff
		dc.l		0

BMask		dc.w		BOOLMASK		flags
		dc.l		ImageData
		dc.l		0

ReqText		dc.b		3,0,RP_JAM2,0	front and back text pens, drawmode and fill byte
		dc.w		23,3		XY origin relative to container TopLeft
		dc.l		TOPAZ80		font pointer or NULL for default
		dc.l		.ITextText	pointer to text
		dc.l		0		next IntuiText structure

.ITextText	dc.b		'Control Panel',0
		even

ReqBorder	dc.w		0,0		XY origin relative to container TopLeft
		dc.b		1,0,RP_JAM1	front pen, back pen and drawmode
		dc.b		5		number of XY vectors
		dc.l		.BorderVectors	pointer to XY vectors
		dc.l		0		next border in list

.BorderVectors	dc.w		0,0
		dc.w		148,0
		dc.w		148,84
		dc.w		0,84
		dc.w		0,0

TOPAZ80
		dc.l		TOPAZname
		dc.w		TOPAZ_EIGHTY
		dc.b		0,0
TOPAZname
		dc.b		'topaz.font',0
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

RFfile_name	ds.l		1
RFfile_lock	ds.l		1
RFfile_info	ds.l		1
RFfile_len	ds.l		1

STD_OUT		ds.l		1

_MatchFlag	ds.l		1

		section Pointer,data_c
;--------------	
;--------------	Image data
;--------------	

ImageData	dc.w		$07ff,$ffff,$ffff,$ffff,$f000
		dc.w		$3fff,$ffff,$ffff,$ffff,$fe00
		dc.w		$7fff,$ffff,$ffff,$ffff,$ff00
		dc.w		$ffff,$ffff,$ffff,$ffff,$ff80
		dc.w		$ffff,$ffff,$ffff,$ffff,$ff80
		dc.w		$ffff,$ffff,$ffff,$ffff,$ff80
		dc.w		$ffff,$ffff,$ffff,$ffff,$ff80
		dc.w		$7fff,$ffff,$ffff,$ffff,$ff00
		dc.w		$3fff,$ffff,$ffff,$ffff,$fe00
		dc.w		$07ff,$ffff,$ffff,$ffff,$f000


		section		Skeleton,code

