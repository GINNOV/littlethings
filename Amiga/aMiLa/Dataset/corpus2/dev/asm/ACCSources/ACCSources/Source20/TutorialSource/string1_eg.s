*****	Title		String1_eg.s
*****	Function	To demonstrate use of string gadgets
*****			
*****			
*****	Size		1226 bytes
*****	Author		Mark Meany
*****	Date Started	Jan 92
*****	This Revision	Jan 92
*****	Notes		Going strong
*****			




; Skeleton code written for ACC Intuition tutorials.

; Code will assemble and can be launched from WB or CLI. Opens an Intuition
;window and waits for close gadget. Other tests also included: Gadgets
;and menus.

; A number of useful subroutines are also included. See documentation.

; Usage text is supported from the CLI. ( see line 420 ).

; © M.Meany, June 1991.

;		opt 		o+,ow-

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
		beq.s		.test_win
		move.l		gg_UserData(a5),a0
		cmpa.l		#0,a0
		beq.s		.test_win
		jsr		(a0)

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

		include		string1.i

WinText		dc.b		1		FrontPen
		dc.b		0		BackPen
		dc.b		RP_JAM2		DrawMode
		dc.b		0		KludgeFill00
		dc.w		0		x position
		dc.w		0		y position
		dc.l		0		font
OurText		dc.l		.Text		address of text to print
		dc.l		0		no more text

.Text		dc.b		' ',0		the text itself
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

STD_OUT		ds.l		1

		section		Skeleton,code

***** Your code goes here!!!

DoWinGadg	lea		ScrnGadg,a0		string gadget
		move.l		window.ptr,a1		window
		suba.l		a2,a2			not a request
		CALLINT		ActivateGadget		activate it
		
		moveq.l		#0,d2			dont quit
		rts

DoScrnGadg	move.l		window.ptr,a0		window pointer
		lea		WinName,a1		new window name
		lea		ScrnName,a2		new screen name
		CALLINT		SetWindowTitles		and display em
		
		moveq.l		#0,d2			don`t quit
		rts					and return		
		


