
; Skeleton code written for ACC Intuition tutorials.

; Conversion of an AmigaBasic program. Boring!!!


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

		bsr		Openscrn	open a custom screen
		tst.l		d0
		beq.s		no_scrn		quit if error

		bsr		Openwin		open window
		tst.l		d0		any errors?
		beq.s		no_win		if so quit

		bsr		DoBoxes		Moire!

		bsr		WaitForMsg	wait for user

		bsr		Closewin	close our window

no_win		bsr		Closescrn	close custom screen

no_scrn		bsr		DeInit		free resources

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

Openscrn	lea		MyScreen,a0
		CALLINT		OpenScreen
		move.l		d0,scrn.ptr	save struct ptr
		move.l		d0,sc_Here	write into window struct

		rts

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

*************** Close the Intuition screen

Closescrn	move.l		scrn.ptr,a0	a0->screen struct
		CALLINT		CloseScreen	and close it
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
		dc.b		'Conversion of an AmigaBasic Program.'
		dc.b		$0a
		dc.b		'       Why did I bother ????'
		dc.b		$0a
		dc.b		0
		even

;***********************************************************
;	Screen & Window defenitions
;***********************************************************

MyScreen	dc.w		0,0		screen XY origin relative to View
		dc.w		640,200		screen width and height
		dc.w		4		screen depth (number of bitplanes)
		dc.b		0,1		detail and block pens
		dc.w		V_HIRES		display modes for this screen
		dc.w		CUSTOMSCREEN	screen type
		dc.l		0		pointer to default screen font
		dc.l		0		screen title
		dc.l		0		first in list of custom screen gadgets
		dc.l		0		pointer to custom BitMap structure

MyWindow	dc.w		20,20		window XY origin relative to TopLeft of screen
		dc.w		600,180		window width and height
		dc.b		0,1		detail and block pens
		dc.l		CLOSEWINDOW	IDCMP flags
		dc.l		WINDOWCLOSE+ACTIVATE+NOCAREREFRESH other window flags
		dc.l		0		first gadget in gadget list
		dc.l		0		custom CHECKMARK imagery
		dc.l		WinName		window title
sc_Here		dc.l		0		custom screen pointer
		dc.l		0		custom bitmap
		dc.w		5,5		minimum width and height
		dc.w		640,200		maximum width and height
		dc.w		CUSTOMSCREEN	destination screen type

WinName		dc.b		'Boxes! Converted By M.Meany. Nov 91.',0
		even

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_args		ds.l		1
_argslen	ds.l		1

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

scrn.ptr	ds.l		1
window.ptr	ds.l		1
window.rp	ds.l		1
window.up	ds.l		1

STD_OUT		ds.l		1

		section		Skeleton,code


DoBoxes		move.l		#1,d7		h

loop1		move.l		#0,d6		i

loop2		move.l		#0,d5		j

loop3		move.l		#20,d0		d0=20
		muls		d5,d0
		add.l		#50,d0		d0=20*j+50
		add.l		d7,d0		d0=20*j+50+h
		move.l		d0,x1

		add.l		#20,d0		d0=x1+20
		move.l		d7,d1		d1=h
		asl.l		#1,d1		d1=h*2
		sub.l		d1,d0		d0=x1+20-h*2
		move.l		d0,x2

		moveq.l		#20,d0		d0=20
		muls		d6,d0		d0=20*i
		add.l		#20,d0		d0=20*i+20
		add.l		d7,d0		d0=20*i+20+h
		move.l		d0,y1

		add.l		#20,d0		d0=y1+20
		move.l		d7,d1		d1=h
		asl.l		#1,d1		d1=h*2
		sub.l		d1,d0		d0=y1+20-2*h
		move.l		d0,y2

		move.l		d7,d0		d0=h
		add.l		d6,d0		d0=h+i
		add.l		d5,d0		d0=h+i+j
		addq.l		#1,d0		d0=h+i+j+1

		swap		d0

loop4		swap		d0
		divu		#15,d0
		tst.w		d0
		bne.s		loop4

		swap		d0		d0= MOD 16 ( d0 )
		move.l		window.rp,a1	a1->RastPort
		CALLGRAF	SetAPen

		move.l		window.rp,a1	a1->RastPort
		move.l		x1,d0
		move.l		y1,d1
		move.l		x2,d2
		move.l		y2,d3
		CALLGRAF	RectFill	fill a box

		addq.l		#1,d5		bump j
		cmp.l		#25,d5		past limit?
		bne		loop3		if not go back

		addq.l		#1,d6		bump i
		cmp.l		#6,d6		past limit?
		bne		loop2		if not go back

		addq.l		#1,d7		bump h
		cmp.l		#7,d7		past limit?
		bne		loop1		if not go back

		rts

x1		dc.l		1
x2		dc.l		1
y1		dc.l		1
y2		dc.l		1

