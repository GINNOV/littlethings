
; Example of using Flood() from gfx library.

; To use Flood() you must initialise a TmpRas structure and link it to the
;RastPort you are rendering into. In this example, the RastPort belongs to
;the Window I've opened.

; NOTE. Rather than use the prescribed method of determaning the size of the
;       display by examining _GfxBase, I have assumed a 640x256 display. This
;       makes code much easier as a chunch of memory is reserved in the code
;       as opposed to allocating it.


	incdir	sys:include/
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
	include	source:include/mmMacros.i

		section		Skeleton,code

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"

		lea		Variables,a5		a5->var base
	
		move.l		a0,_args(a5)		save addr of CLI args
		move.l		d0,_argslen(a5)		and the length

		bsr.s		Openlibs		open libraries
		tst.l		d0			any errors?
		beq.s		no_libs			if so quit

		bsr		Init			Initialise data
		tst.l		d0			any errors?
		beq.s		no_libs			if so quit

		bsr		Openwin			open window
		tst.l		d0			any errors?
		beq.s		no_win			if so quit

		bsr		WaitForMsg		wait for user

		bsr		Closewin		close our window

no_win		bsr		DeInit			free resources

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

*************** Initialise any data

;--------------	At present just set STD_OUT and check for usage text

Init		tst.l		returnMsg		from WorkBench?
		bne.s		.ok			yes, ignore usage

		CALLDOS		Output			determine CLI handle
		move.l		d0,STD_OUT(a5)		save it for later
		beq.s		.err			quit if no handle

		move.l		_args(a5),a0		get addr of CLI args
		cmpi.b		#'?',(a0)		is the first arg a ?
		bne.s		.ok			no, skip next bit

		lea		_UsageText,a0		a0->the usage text
		bsr		DosMsg			and display it
.err		moveq.l		#0,d0			set an error
		bra.s		.error			and finish

;--------------	Your Initialisations should start here

.ok		moveq.l		#1,d0			no errors

.error		rts					back to main


*************** Open An Intuition Window

; Opens an intuition window. If d0=0 on return then window could not be
;opened.

Openwin		lea		MyWindow,a0		a0->window args
		CALLINT		OpenWindow		and open it
		move.l		d0,win.ptr(a5)		save struct ptr
		beq.s		.win_error		quit if error

		move.l		d0,a0			a0->win struct	
		move.l		wd_UserPort(a0),win.up(a5) save up ptr
		move.l		wd_RPort(a0),win.rp(a5)    save rp ptr

; To use flood we must get and initialise a temporary rastport. The GFX
;routines uses this as a work space:

		lea		WorkRas(a5),a0
		lea		ScratchBpl,a1
		move.l		#(640/8)*256,d0
		CALLGRAF	InitTmpRas
		tst.l		d0
		beq.s		.NoTmpRas
		
; Link TmpRas to our RastPort

		move.l		win.rp(a5),a0
		lea		WorkRas(a5),a1
		move.l		a1,rp_TmpRas(a0)

; Display nice pattern to colour

.NoTmpRas	move.l		win.rp(a5),a0
		move.l		rp_TmpRas(a0),d0
		lea		Image1,a1
		moveq.l		#50,d0
		moveq.l		#30,d1
		CALLINT		DrawImage

		moveq.l		#1,d0			no errors

.win_error	rts					all done so return

*************** Deal with User interaction

; At present only supports gadget selection. Address of routine to call
;when a gadget is selected should be stored in the gg_UserData field
;of that gadgets structure. All gadget/menu service subroutines should set
;d2=0 to ensure accidental QUIT is not forced. If a QUIT gadget is used
;it should set d2=CLOSEWINDOW.


WaitForMsg	move.l		win.up(a5),a0		a0->user port
		CALLEXEC	WaitPort		wait for message
		move.l		win.up(a5),a0		a0->user port
		CALLSYS		GetMsg			get any messages
		tst.l		d0			was there a message ?
		beq.s		WaitForMsg		if not loop back
		move.l		d0,a1			a1-->message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		move.l		im_IAddress(a1),a4 	a4=addr of structure
		move.w		im_MouseX(a1),d3
		move.w		im_MouseY(a1),d4
		move.w		im_Code(a1),d5
		CALLSYS		ReplyMsg		answer os

		cmp.l		#MOUSEBUTTONS,d2
		bne.s		.TryGadg
		cmp.w		#SELECTUP,d5
		bne.s		WaitForMsg
		bsr		DoFlood
		bra		WaitForMsg


.TryGadg	move.l		d2,d0
		and.l		#GADGETUP!GADGETDOWN,d0
		beq.s		.test_win
		move.l		gg_UserData(a4),a0
		cmpa.l		#0,a0
		beq.s		.test_win
		jsr		(a0)

.test_win	cmp.l		#CLOSEWINDOW,d2  	window closed ?
		bne.s		WaitForMsg	 	if not then jump

		lea		QuitMsg,a0
		bsr		TFReq
		tst.l		d0
		beq.s		WaitForMsg

		rts


*************** Close the Intuition window.

Closewin	move.l		win.rp(a5),a0
		move.l		#0,rp_TmpRas(a0)	remove TmpRas

		move.l		win.ptr(a5),a0		a0->Window struct
		CALLINT		CloseWindow		and close it
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

**************	OK requester

; Entry		a0->text string

; Exit		none

; Corrupt	d0

OKReq		PUSHALL

		lea		.TheEasy,a1		EasyStruct
		move.l		a0,es_TextFormat(a1)	set text
		
		move.l		win.ptr(a5),a0		Window
		suba.l		a2,a2			No IDCMP
		suba.l		a3,a3
		CALLINT		EasyRequestArgs		display it

.done		PULLALL
		rts

.TheEasy	dc.l		es_SIZEOF
		dc.l		0			no flags
		dc.l		0			title
		dc.l		0			text
		dc.l		.Gadgets

.Gadgets	dc.b		'Ok',0
		even

**************	True/False requester

; Entry		a0->text string

; Exit		d0=result 1=true( OK ), 0=false( Cancel )

; Corrupt	d0

TFReq		PUSHALL

		lea		.TheEasy,a1		EasyStruct
		move.l		a0,es_TextFormat(a1)	set text
		
		move.l		win.ptr(a5),a0		Window
		suba.l		a2,a2			No IDCMP
		suba.l		a3,a3
		CALLINT		EasyRequestArgs		display it

.done		PULLALL
		rts

.TheEasy	dc.l		es_SIZEOF
		dc.l		0			no flags
		dc.l		0			title
		dc.l		0			text
		dc.l		.Gadgets

.Gadgets	dc.b		'Ok|Cancel',0
		even

**************	General CLI printing routine

; Entry		a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

DosMsg		movem.l		d0-d3/a0-a3,-(sp) 	save registers

		tst.l		STD_OUT(a5)		test for open console
		beq		.error			quit if not one

		move.l		a0,a1			get a working copy

;--------------	Determine length of message

		moveq.l		#-1,d3			reset counter
.loop		addq.l		#1,d3			bump counter
		tst.b		(a1)+			is this byte a 0
		bne.s		.loop			if not loop back

;--------------	Make sure there was a message

		tst.l		d3			was there a message ?
		beq.s		.error			no, graceful exit

;--------------	Get handle of output file

		move.l		STD_OUT(a5),d1		d1=file handle
		beq.s		.error			leave if no handle

;--------------	Now print the message
;		At this point, d3 already holds length of message
;		and d1 holds the file handle.

		move.l		a0,d2			d2=address of message
		CALLDOS		Write			and print it

;--------------	All done so finish

.error		movem.l		(sp)+,d0-d3/a0-a3	restore registers
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


QuitMsg		dc.b		'Quit Program?',0
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

		include		win.i

;***********************************************************
;	SECTION	Vars,BSS
;***********************************************************

		rsreset
_args		rs.l		1
_argslen	rs.l		1

win.ptr		rs.l		1
win.rp		rs.l		1
win.up		rs.l		1

WorkRas		rs.b		tr_SIZEOF	TmpRas structure

STD_OUT		rs.l		1

varsize		rs.b		0

		SECTION	Vars,BSS

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

Variables	ds.b		varsize

		section		Skeleton,code

***** Next 4 routines are triggered by gadgets that change pen colour:

GreyPen		PUSHALL

		move.l		#0,d0
		move.l		win.rp(a5),a1
		CALLGRAF	SetAPen
		
		PULLALL
		rts
		
BlackPen	PUSHALL

		move.l		#1,d0
		move.l		win.rp(a5),a1
		CALLGRAF	SetAPen
		
		PULLALL
		rts
		
WhitePen	PUSHALL

		move.l		#2,d0
		move.l		win.rp(a5),a1
		CALLGRAF	SetAPen
		
		PULLALL
		rts
		
BluePen		PUSHALL

		move.l		#3,d0
		move.l		win.rp(a5),a1
		CALLGRAF	SetAPen
		
		PULLALL
		rts
		
***** Here is the flood routine. On entry d3=MouseX and d4=MouseY. 

DoFlood		PUSHALL

		moveq.l		#0,d0			clear 'em
		move.l		d0,d1
		
		move.w		d3,d0			get mouse x,y
		move.w		d4,d1

		cmp.w		#29,d1			exit if y<49
		blt.s		.done
		
		moveq.l		#1,d2			colour mode
		move.l		win.rp(a5),a1		RastPort
		CALLGRAF	Flood			start filling :-)
		
.done		PULLALL
		rts


		section		gfx,data_C

; This is the screatch bitplane used by the drawing routines

ScratchBpl	ds.b		(640/8)*256
