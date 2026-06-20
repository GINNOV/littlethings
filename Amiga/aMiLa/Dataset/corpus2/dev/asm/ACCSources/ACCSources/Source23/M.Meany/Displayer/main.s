
*****	Title		Displayer
*****	Function	Used to display tutorials and examples at the same
*****			time. Will also allow an example to be executed.
*****			
*****	Size		7692 bytes
*****	Author		Mark Meany
*****	Date Started	23 April 92
*****	This Revision	24 April 92
*****	Notes		Still under development, but functioning!
*****			
*****	23 April	Loads/displays tutorial.
*****			Switch betwen sections.
*****	24 April	Load/display/scroll examples.
*****			Scroll tutorial.
*****	25 April	Displays status text.
*****			Run currently loaded example.
*****			Search/Next/Previous routines.
*****			Using LMB to scroll up/down through text.

		opt o-

	incdir	sys:include/
;	incdir	df2:
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

;--------------
;--------------	The displayer variables
;--------------

; The following structure is maintained for each file loaded.

		rsreset
file.buffer	rs.l		1	address of buffer where file loaded
file.size	rs.l		1	size of the buffer
file.line	rs.l		1	address of files line list
file.lsize	rs.l		1	size of buffer holding line list
file.lnum	rs.l		1	number of lines in the file
file.topline	rs.l		1	current line at top of display
file.max	rs.l		1	max line number that can be at top
file.search	rs.l		1	line number to start searches from
file.book	rs.l		1	line number of current bookmark
file.sbuff	rs.b		32	buffer for search string
file.info	rs.w		0	size of structure

; The programs variables

		rsreset
_args		rs.l		1	pointer to CLI parameter list
_argslen	rs.l		1	bytesize of parameter list

win.ptr		rs.l		1	pointer to Window structure
win.rp		rs.l		1	pointer to RastPort structure
win.up		rs.l		1	pointer to UserPort structure

men.ptr		rs.l		1	pointer to menu Window structure
men.up		rs.l		1	pointer to menu UserPort structure
men.rp		rs.l		1	pointer to menu RastPort structure

RFfile_name	rs.l		1	pointer to files name
RFfile_lock	rs.l		1	holds key to a Lock'ed file
RFfile_info	rs.l		1	pointer to FileInfoBlock memory
RFfile_len	rs.l		1	length of file

STD_OUT		rs.l		1	CLI output stream

_MatchFlag	rs.l		1	used by search routines

LMBflag		rs.l		1	set when button down

win.title	rs.l		1	pointer to windows title
					*first line of control file

control		rs.b		file.info	example file names

tutorial	rs.b		file.info	tutorial text

example		rs.b		file.info	loaded example text

active		rs.l		1		0=>top of display, 1=>bottom

searchsection	rs.l		1		pointer to file.info to srch

WritePort	rs.l		1		pointer to port for console
WriteReq	rs.l		IOSTD_SIZE	IO struct for console
DStream		rs.l		5		DataStream
IEStructure	rs.l		ie_SIZEOF	input event structure
KeyBuffer	rs.b		40		for RawKeyConvert
VarSize		rs.w		0		size of block

;--------------
;--------------	The Program
;--------------

CALLSYS		macro
		ifgt	NARG-1
		FAIL	!!!
		endc
		jsr	_LVO\1(a6)
		endm

		section		Displayer,code

		lea		VarStart,a4		a4->variable block

		move.b		#0,-1(a0,d0)		NULL terminate args
		move.l		a0,(a4)			save addr of CLI args
		move.l		d0,_argslen(a4)		and the length

		bsr.s		Openlibs		open libraries
		tst.l		d0			any errors?
		beq.s		no_libs			if so quit

		bsr		Init			Initialise data
		tst.l		d0			any errors?
		beq.s		no_libs			if so quit

		bsr		Openwin			open window
		tst.l		d0			any errors?
		beq.s		no_win			if so quit

		bsr		OpenConsole		open console.device
		tst.l		d0			any errors?
		beq.s		no_con			if so quit

		bsr		WaitForMsg		wait for user

		bsr		CloseConsole

no_con		bsr		Closewin		close our window

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

; Set STD_OUT to parent CLI window

Init		CALLDOS		Output			determine CLI handle
		move.l		d0,STD_OUT(a4)		and save it for later
		beq.s		.err			quit if no handle

; Check if user requires usage instructions. If so display them and exit.

		move.l		(a4),a0			get addr of CLI args
		cmpi.b		#'?',(a0)		is the first arg a ?
		bne.s		.ok			if not skip next bit

		lea		_UsageText,a0		a0->the usage text
		bsr		DosMsg			and display it
.err		moveq.l		#0,d0			set an error
		bra.s		.error			and finish

;--------------	Your Initialisations should start here

; Load in main control file.

.ok		bsr		LoadControl		load control file
		tst.l		d0			check for errors
		bne.s		.ok1			skip if none

; File failed to load, display error message and exit

		lea		_ErrNoControl,a0	error message
		bsr		DosMsg			display it
		bra.s		.error			and exit

; Load in tutorial file

.ok1		bsr		LoadTutor		load tutorial file
		tst.l		d0			check for errors
		bne.s		.ok2			skip if none

; File failed to load, display error message and exit

		lea		_ErrNoTutorial,a0	error message
		bsr		DosMsg			display it
		bra.s		.error			and exit

; Both files loaded ok, so set flag and exit!

.ok2		moveq.l		#1,d0			no errors

.error		rts					back to main


*************** Open An Intuition Window

; Opens an intuition window. If d0=0 on return then window could not be
;opened.

Openwin		lea		MyWindow,a0		a0->window args
		CALLINT		OpenWindow		and open it
		move.l		d0,win.ptr(a4)		save struct ptr
		beq.s		.win_error		quit if error

		move.l		d0,a0			   a0->win struct	
		move.l		wd_UserPort(a0),win.up(a4) save up ptr
		move.l		wd_RPort(a0),win.rp(a4)    save rp ptr

.win_error	rts					all done so return

;--------------
;--------------	Opens a console device for writing to the window
;--------------

; Get a message port

OpenConsole	lea		PortName,a0		a0->name for port
		moveq.l		#0,d0			ports priority
		bsr		CreatePort		get it
		move.l		d0,WritePort(a4)	save addr
		beq		.error			quit if not allocated

; Attach port to io request block

		lea		WriteReq(a4),a1		a1->IO structure
		move.l		d0,MN_REPLYPORT(a1)	attach port

; Attach window to io request block as required by OpenDevice to link the
;two together.

		move.l		win.ptr(a4),IO_DATA(a1)	addr of structure
		move.l		#wd_Size,IO_LENGTH(a1)	and its size

; Now open the device, a1 already points to it's io request structure.

		lea		ConsoleName,a0		a0->device name
		moveq.l		#0,d0			unit number
		move.l		d0,d1			flags
		CALLEXEC	OpenDevice		and open it
		move.l		d0,d0			any errors
		beq.s		.GotDevice		if skip cleanup
		
		move.l		WritePort(a4),a0	a0->allocated port
		bsr		DeletePort		release it
		moveq.l		#0,d0			signal an error
		bra		.error			and quit
	
; Display section title bars

.GotDevice	move.l		win.rp(a4),a0		a0->windows RastPort
		lea		WinText,a1		a1->IText structure
		moveq.l		#0,d0			X offset
		moveq.l		#0,d1			Y offset
		CALLINT		PrintIText		print this text

; Initialise display and print tutorial file.

		move.l		#CursorOff,d0		Turn cursor off
		bsr		ConComm			for fast printing!

		move.l		#ScrollOff,d0		Disable auto-scroll
		bsr		ConComm

		move.l		#TopText,d0		Init display
		bsr		ConComm
		
		bsr		RefreshSection		display tutorial
		
		moveq.l		#1,d0			signal no errors
.error		rts

*************** Deal with User interaction

; At present only supports gadget selection. Address of routine to call
;when a gadget is selected should be stored in the gg_UserData field
;of that gadgets structure. All gadget/menu service subroutines should set
;d2=0 to ensure accidental QUIT is not forced. If a QUIT gadget is used
;it should set d2=CLOSEWINDOW.


WaitForMsg	move.l		win.up(a4),a0		a0-->user port
		CALLEXEC	WaitPort		wait for event
		move.l		win.up(a4),a0		a0-->user port
		CALLSYS		GetMsg			get any messages
		tst.l		d0			was there a message ?
		beq.s		WaitForMsg		if not loop back
		move.l		d0,a1			a1-->Message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		move.w		im_Code(a1),d3		d3=key code/menu
		move.w		im_Qualifier(a1),d4 	d4=special keys
		move.w		im_MouseY(a1),d5	mouse Y pos
		move.l		im_IAddress(a1),a5	a5=addr of structure

		cmp.l		#RAWKEY,d2		keyboard input ?
		bne.s		.Do_Reply		if not then skip
		move.l		a1,-(sp)		save message ptr
		bsr		DoKeys			jump to key handler
		move.l		(sp)+,a1		restore message ptr

.Do_Reply	CALLEXEC	ReplyMsg		answer os

		move.l		d2,d0			copy of Class
		and.l		#GADGETUP!GADGETDOWN,d0	was it a gadget?
		beq.s		.check_mouse		skip if not
		move.l		gg_UserData(a5),a0	else get sub address
		cmpa.l		#0,a0			check not NULL
		beq.s		.test_win		skip if it is
		jsr		(a0)			else call routine

.check_mouse	cmp.l		#MOUSEBUTTONS,d2 	mouse button pressed?
		bne.s		.test_tick		skip if not
		moveq.l		#1,d0			default is down!
		cmp.w		#SELECTDOWN,d3		was it LMB?
		beq.s		.setflag		skip if not
		moveq.l		#0,d0			must be up!
.setflag	move.l		d0,LMBflag(a4)		set flag!
		bra.s		WaitForMsg		and loop

.test_tick	cmp.l		#INTUITICKS,d2		clock?
		bne.s		.test_win
		tst.l		LMBflag(a4)		flag set?
		beq		WaitForMsg		loop if not!
		bsr		DoMouse			else service
		bra		WaitForMsg		and loop

.test_win	cmp.l		#CLOSEWINDOW,d2  	window closed ?
		bne		WaitForMsg	 	if not then loop back
		rts					else exit


*************** Close the Intuition window.

Closewin	move.l		win.ptr(a4),a0		a0->Window struct
		CALLINT		CloseWindow		and close it
		rts

***************	Release any additional resources used

; routine clears all memory used to hold text files and assosiated line
;lists. 

DeInit		lea		example(a4),a0		example file
		bsr		ScrapFile		release it
		
		lea		tutorial(a4),a0		tutorial file
		bsr		ScrapFile		release it
		
		lea		control(a4),a0		control file
		bsr		ScrapFile		release it
		
		rts					and exit

;--------------
;--------------	Close the console device
;--------------

CloseConsole	lea		WriteReq(a4),a1		a1->IO structure
		CALLEXEC	CloseDevice		close console

; must also release the reply port!

		move.l		WritePort(a4),a0	a0->Port
		bsr		DeletePort

		rts					and return

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
*			IDCMP Subroutines Section					    *
*****************************************************************************

;--------------
;--------------	Left Mouse Button Service Routine
;--------------

; Entry		d5 = MouseY position

DoMouse		tst.l		active(a4)		see which section
		bne.s		.IsBottom		skip if example

		lea		DoShiftDown,a0		subroutine
		cmp.w		#127,d5
		bgt		.error
		
		cmp.w		#119,d5
		bgt.s		.DoIt
		
		lea		DoDown,a0
		cmp.w		#67,d5
		bgt.s		.DoIt
		
		lea		DoUp,a0
		cmp.w		#15,d5
		bgt.s		.DoIt
		
		lea		DoShiftUp,a0
		cmp.w		#7,d5
		bgt.s		.DoIt
.error		rts

.IsBottom	lea		DoShiftDown,a0		subroutine
		cmp.w		#255,d5
		bgt.s		.error
		
		cmp.w		#247,d5
		bgt.s		.DoIt
		
		lea		DoDown,a0
		cmp.w		#195,d5
		bgt.s		.DoIt
		
		lea		DoUp,a0
		cmp.w		#143,d5
		bgt.s		.DoIt
		
		lea		DoShiftUp,a0
		cmp.w		#135,d5
		bgt.s		.DoIt
		rts

.DoIt		jsr		(a0)
		rts

		

;--------------
;--------------	Keyboard service routine
;--------------

DoKeys		btst		#7,d3			key up?
		bne		.done_keys		if so exit
		
		bsr		ConvertRAW		convert to ANSI

;-------------	number of chars in d0 and address of char buffer in a0

		tst.l		d0			converted ok?
		beq		.done_keys		if not return!

		cmpi.b		#$9b,(a0)		command key?
		bne.s		.next4			if not skip to ASCII

		cmpi.b		#'?',1(a0)		HELP key?
		bne.s		.next
		cmpi.b		#'~',2(a0)
		bne.s		.next
		bsr		DoHelp
		bra		.done_keys
		
.next		cmp.w		#$9b53,(a0)		scroll up?
		bne.s		.next1
		bsr		DoShiftDown
		bra		.done_keys
		
.next1		cmp.w		#$9b54,(a0)		scroll down?
		bne.s		.next2
		bsr		DoShiftUp
		bra		.done_keys

.next2		cmp.w		#$9b42,(a0)		move cursor down?
		bne.s		.next3
		bsr		DoDown
		bra		.done_keys
		
.next3		cmp.w		#$9b41,(a0)		move cursor up?
		bne.s		.next4
		bsr		DoUp
		bra		.done_keys

.next4		cmp.w		#$9b44,(a0)		move cursor left?
		bne.s		.next5
		bsr		DoSPrev			find previous
		bra		.done_keys
		
.next5		cmp.w		#$9b43,(a0)		move cursor right?
		bne.s		.next6
		bsr		DoSearch		find next
		bra		.done_keys

.next6		move.b		(a0),d0			get key code
		cmp.b		#$09,d0			TAB?
		beq.s		.isTAB			if so skip
		cmp.b		#$20,d0			check if < printable
		blt		.nextC			if so see if CTRL
		cmp.b		#$7e,d0			check if > printable
		bgt		.done_keys		if so ignore & return

;--------------
;--------------	Deal with ASCII keypresses
;--------------

.isTAB		move.l		d0,d2			d2=key code

		cmp.b		#$09,d2			TAB key?
		bne.s		.isL			check next
		bsr		DoSwitch		insert it
		bra		.done_keys		and return

.isL		cmp.b		#'l',d2			l key pressed?
		bne.s		.isL1			see if upper case
		bsr		DoLoadMenu		else Load Menu
		bra.s		.done_keys		and exit
.isL1		cmp.b		#'L',d2			L key pressed?
		bne.s		.isR			check next
		bsr		DoLoadMenu		else Load Menu
		bra.s		.done_keys		and exit

.isR		cmp.b		#'r',d2			r key pressed?
		bne.s		.isR1			see if upper case
		bsr		DoRunMenu		else Run menu
		bra.s		.done_keys		and exit
.isR1		cmp.b		#'R',d2			R key pressed
		bne.s		.isS			skip if not
		bsr		DoRunMenu		else Run menu
		bra.s		.done_keys		and exit

.isS		cmp.b		#'s',d2			r key pressed?
		bne.s		.isS1			see if upper case
		bsr		DoSearchMenu		else Run menu
		bra.s		.done_keys		and exit
.isS1		cmp.b		#'S',d2			R key pressed
		bne.s		.isP			skip if not
		bsr		DoSearchMenu		else Run menu
		bra.s		.done_keys		and exit

.isP		cmp.b		#'p',d2			r key pressed?
		bne.s		.isP1			see if upper case
		bsr		DoPrintMenu		else Run menu
		bra.s		.done_keys		and exit
.isP1		cmp.b		#'P',d2			R key pressed
		bne.s		.isQ			skip if not
		bsr		DoPrintMenu		else Run menu
		bra.s		.done_keys		and exit

.isQ		cmp.b		#'q',d2			r key pressed?
		bne.s		.isQ1			see if upper case
		bsr		DoQuitMenu		else Run menu
		rts					and exit
.isQ1		cmp.b		#'Q',d2			R key pressed
		bne.s		.done_keys		skip if not
		bsr		DoQuitMenu		else Run menu
		rts

.nextC		cmp.b		#$11,d0			CTRL-Q? $19 on 1.2!
		bne.s		.done_keys		skip if not
		move.l		#CLOSEWINDOW,d2		set to quit
		rts					and exit

.done_keys	moveq.l		#0,d2			not quitting!
		rts					exit

DoBookMenu			; Bookmark menu
ForDevelopment		rts

;--------------
;--------------	Present The Load Example Menu
;--------------

DoQuitMenu	lea		QuitWindow,a0
		bsr		DoMenuWindow
		move.l		d0,d2
		rts
		
;--------------
;--------------	Present the Load Example menu
;--------------

DoLoadMenu	lea		LoadWindow,a0
		bsr		DoMenuWindow
		rts

;--------------
;--------------	Present the Load Example menu
;--------------

DoRunMenu	lea		RunWindow,a0
		bsr		DoMenuWindow
		rts

;--------------
;--------------	Present the String Search menu
;--------------

; determine which file to search

DoSearchMenu	lea		tutorial(a4),a0		a0->file info
		tst.l		active(a4)		see which section
		beq.s		.IsTop			skip if tutorial
		lea		example(a4),a0		else set example

; file to search has been determined, set up gadget and buffer pointer

.IsTop		tst.l		file.topline(a0)	file loaded?
		beq.s		.done			exit if not!
		move.l		a0,searchsection(a4)	save file info ptr
		lea		StrGadg,a1		a1->gadget
		lea		file.sbuff(a0),a0	a0->buffer
		move.l		a0,gg_SIZEOF(a1)	attach to gadget

; Now open search menu window

		lea		SearchWindow,a0		NewWindow
		bsr		DoMenuWindow		srvice request

; All done, so exit

.done		rts
		


;--------------	Deal with help key selection
;--------------

; Display help text

DoHelp		move.l		#HelpText,d0		text to print
		bsr		ConComm

; Wait for LMB to be pressed and released

.Wait		move.l		win.up(a4),a0		a0-->user port
		CALLEXEC	WaitPort		wait for event
		move.l		win.up(a4),a0		a0-->user port
		CALLSYS		GetMsg			get any messages
		tst.l		d0			was there a message ?
		beq.s		.Wait			if not loop back
		move.l		d0,a1			a1-->Message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		move.w		im_Code(a1),d3		d3=key code/menu
		CALLSYS		ReplyMsg		answer os
		cmp.l		#MOUSEBUTTONS,d2 	mouse button pressed?
		bne.s		.Wait			loop if not
		cmp.w		#SELECTUP,d3		was it LMB?
		bne.s		.Wait			loop if not

; Restore original text

		bsr		RefreshSection		display text

; And exit
		rts					exit!

;--------------
;--------------	Deal with up arrow key
;--------------

DoUp		lea		tutorial(a4),a3		a3->file info
		tst.l		active(a4)		check
		beq.s		.IsTop			correct, so skip!
		lea		example(a4),a3		set for example text

; File info selected, scroll display down

.IsTop		move.l		file.topline(a3),d7	get 1st line number
		beq		.done			exit if not loaded
		subq.l		#1,d7			dec
		beq		.done			exit if at start
		move.l		d7,file.topline(a3)	save new value

; Now scroll the display. The ScrollDown console command also moves the
;cursor to the Home position.

		move.l		#ScrollDown,d0		console command
		bsr		ConComm

; And print new 1st line of display		

		move.l		d7,d0			line number
		move.l		a3,a0			file info
		bsr		LineInfo		get address/length
		tst.l		d0			check length
		beq		.done			skip if none
		
		move.l		a0,d1			address
		bsr		ConText			and print it

		bsr		SectionStatus

; All done, so exit.

.done		moveq.l		#0,d2			not quitting!
		rts					and exit		

;--------------
;--------------	Deal with down arrow key
;--------------

DoDown		lea		tutorial(a4),a3		a3->file info
		tst.l		active(a4)		check
		beq.s		.IsTop			correct, so skip!
		lea		example(a4),a3		set for example text

; File info selected, check we can scroll

.IsTop		move.l		file.topline(a3),d7	get 1st line number
		beq		.done			exit if not loaded
		cmp.l		file.max(a3),d7		see if at end
		beq.s		.done			exit if so
		addq.l		#1,d7			bump
		move.l		d7,file.topline(a3)	and save

; Must now calculate number of line to print at the bottom of display after
;the scroll has taken place.

		add.l		#14,d7			add last line offset

; Now scroll the display. The ScrollUp console command also moves the
;cursor to the start of the last line of the display.

		move.l		#ScrollUp,d0		console command
		bsr		ConComm

; And print line at bottom of display		

		move.l		d7,d0			line number
		move.l		a3,a0			file info
		bsr		LineInfo		get address/length
		tst.l		d0			check length
		beq		.done			skip if none
		
		move.l		a0,d1			address
		bsr		ConText			and print it

		bsr		SectionStatus

; All done, so exit.

.done		moveq.l		#0,d2			not quitting!
		rts					and exit		

;--------------
;--------------	Deal with shifted-up arrow key
;--------------

DoShiftUp	lea		tutorial(a4),a3		a3->file info
		tst.l		active(a4)		check
		beq.s		.IsTop			correct, so skip!
		lea		example(a4),a3		set for example text

; File info selected, check we can scroll

.IsTop		move.l		file.topline(a3),d7	get 1st line number
		beq.s		.done			exit if not loaded
		cmp.l		#14,d7			< a page down?
		bgt.s		.cango			no, so skip!
		moveq.l		#15,d7			adjust

; can now calculate new top line number

.cango		sub.l		#14,d7			move back a page
		move.l		d7,file.topline(a3)	save line number
		bsr		RefreshSection		update display

.done		moveq.l		#0,d2			not quitting
		rts					exit

;--------------
;--------------	Deal with shifted-down arrow key
;--------------

DoShiftDown	lea		tutorial(a4),a3		a3->file info
		tst.l		active(a4)		check
		beq.s		.IsTop			correct, so skip!
		lea		example(a4),a3		set for example text

; File info selected, check we can scroll

.IsTop		move.l		file.topline(a3),d7	get 1st line number
		beq.s		.done			exit if not loaded
		add.l		#14,d7			calc new value
		cmp.l		file.max(a3),d7		> a page to go?
		ble.s		.cango			yes, so skip!
		move.l		file.max(a3),d7		set to maximum

; can now calculate new top line number

.cango		move.l		d7,file.topline(a3)	save line number
		bsr		RefreshSection		update display

.done		moveq.l		#0,d2			not quitting
		rts					exit

;--------------
;--------------	Switch between upper and lower section of display
;--------------


DoSwitch	not.l		active(a4)		flip flag
		beq.s		.IsTop			skip if top active

; Bottom now active, so highlight it!

		move.l		#BottomText,d0		command
		bsr		ConComm			send it
		
		bsr		RefreshSection		redraw display
		
		; other stuff here later
		
		rts					and exit

; Top now active, so highlight it!

.IsTop		move.l		#TopText,d0		command
		bsr		ConComm			send it
		
		bsr		RefreshSection		redraw display

		; other stuff here later
		
		rts

;--------------
;--------------	Present Print Options
;--------------

DoPrintMenu	lea		PrintWindow,a0
		bsr		DoMenuWindow
		rts

*****************************************************************************
*		Menu Window Handaler And Support Routines		    *
*****************************************************************************
; All options are displayed via a window. To minimise space, this routine is
;used to control all these windows. It also kills the IDCMP for the main
;display window to stop any ambiguous messages filtering back to it after the
;menu window has closed.

; Entry		a0->NewWindow structure for the required menu window

; Exit		d0 = any return value assosiated with calling routine

; Corrupt	d0

DoMenuWindow	movem.l		d1-d7/a0-a6,-(sp)	save

; put the address of the new window structure in a safe register for now

		move.l		a0,d6			safe!

; alter main windows IDCMP to stop it queing messages.

		move.l		win.ptr(a4),a0		Window
		move.l		#CLOSEWINDOW,d0		new IDCMP
		CALLINT		ModifyIDCMP		do it!

; now open the menu window

		move.l		d6,a0			NewWindow
		moveq.l		#0,d0			clear register
		CALLSYS		OpenWindow		open it
		move.l		d0,men.ptr(a4)		save pointer
		beq		.error1			exit if error

		move.l		d0,a0
		move.l		wd_UserPort(a0),men.up(a4) UserPort
		move.l		wd_RPort(a0),men.rp(a4)	   RastPort

; Each NewWindow structure is followed by a pointer to an IntuiText structure
;for the window. Print this:

		move.l		d6,a1			a1->NewWindow
		move.l		nw_SIZE(a1),a1	a1->IntuiText
		move.l		men.rp(a4),a0		a0->windows RastPort
		moveq.l		#0,d0			X offset
		moveq.l		#0,d1			Y offset
		CALLSYS		PrintIText		print this text

; deal with messages. Windows only support CLOSEWINDOW and GADGETUP.

.Wait		move.l		men.up(a4),a0		a0-->user port
		CALLEXEC	WaitPort		wait for event
		move.l		men.up(a4),a0		a0-->user port
		CALLSYS		GetMsg			get any messages
		tst.l		d0			was there a message ?
		beq.s		.Wait			if not loop back
		move.l		d0,a1			a1-->Message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		move.w		im_Code(a1),d3		d3=key code/menu
		move.w		im_Qualifier(a1),d4 	d4=special keys
		move.l		im_IAddress(a1),a5	a5=addr of structure
		CALLSYS		ReplyMsg		answer os

		cmp.l		#GADGETUP,d2		was it a gadget?
		bne.s		.test_win		skip if not
		move.l		gg_UserData(a5),a0	else get sub address
		cmpa.l		#0,a0			check not NULL
		beq.s		.test_win		skip if it is
		jsr		(a0)			else call routine
		bra.s		.donegadget		exit

.test_win	cmp.l		#CLOSEWINDOW,d2  	window closed ?
		bne.s		.Wait		 	if not then loop back

; Close the menu window

.donegadget	move.l		men.ptr(a4),a0		Window
		CALLINT		CloseWindow		and close it!

; Reset the main windows IDCMP

.error1		move.l		win.ptr(a4),a0		Window
		move.l		#CLOSEWINDOW!RAWKEY!MOUSEBUTTONS!INTUITICKS,d0 IDCMP
		CALLINT		ModifyIDCMP		do it!

; All done so exit

.done		move.l		d7,d0			return value
		movem.l		(sp)+,d1-d7/a0-a6	restore
		rts					and exit

;--------------
;--------------	CANCEL gadget selection!
;--------------

DoCancel	move.l		#CLOSEWINDOW,d2
		moveq.l		#0,d7			no return!
		rts

;--------------
;--------------	Quit!
;--------------

DoQuit		move.l		#CLOSEWINDOW,d2
		move.l		d2,d7
		rts

;--------------
;--------------	Load next example file
;--------------

DoLoadNext	lea		control(a4),a3		file info
		move.l		file.topline(a3),d0	line number
		beq.s		.done			exit if none!
		
; See if last example is being displayed, if it is exit now!

		cmp.l		file.max(a3),d0		last example?
		beq.s		.done			if so exit!

; Bump top line on to next file

		addq.l		#1,d0			bump
		move.l		d0,file.topline(a3)	save

; Free memory tied up by current example

		lea		example(a4),a0		file info
		bsr		ScrapFile		free it

; Load the file

		bsr		LoadExample		load it
		tst.l		d0			errors?
		beq.s		.done			if so exit!
		
; Move into example section and display it.

		move.l		#BottomText,d0		command
		bsr		ConComm

		move.l		#-1,active(a4)		set flag

		bsr		RefreshSection		display example

; All done so exit

.done		rts					exit		
		
;--------------
;--------------	Load previous example file
;--------------

DoLoadPrev	lea		control(a4),a3		file info
		move.l		file.topline(a3),d0	line number
		beq.s		.done			exit if none!
		
; See if first example is being displayed, if it is exit now!

		cmp.l		#2,d0			first example?
		beq.s		.done			if so exit!

; Bump top line on to previous file

		subq.l		#1,d0			bump
		move.l		d0,file.topline(a3)	save

; Free memory tied up by current example

		lea		example(a4),a0		file info
		bsr		ScrapFile		free it

; Load the file

		bsr		LoadExample		load it
		tst.l		d0			errors?
		beq.s		.done			if so exit!
		
; Move into example section and display it.

		move.l		#BottomText,d0		command
		bsr		ConComm
		
		move.l		#-1,active(a4)

		bsr		RefreshSection		display example

; All done so exit

.done		rts					exit		

;--------------
;--------------	Run an example file
;--------------

DoRunEg		lea		control(a4),a3		file info

; Determine which example is currently loaded

		move.l		file.topline(a3),d0	get line offset
		beq.s		.done			exit if none loaded
		cmp.l		#1,d0			no example loaded yet
		beq.s		.done			exit if not

; Example is loaded, get info. d0 = lin number already!

		move.l		a3,a0			file info
		bsr		LineInfo		get data
		tst.l		d0			all ok?
		beq.s		.done			exit if not!

; Copy name to buffer

		move.l		d0,-(sp)		save
		lea		KeyBuffer(a4),a1	destination
		CALLEXEC	CopyMem			copy name

; Null terminate file name before .s extension.

		move.l		(sp)+,d0
		lea		KeyBuffer(a4),a1
		move.b		#0,-3(a1,d0)		NULL terminate

; Use DOS to execute the file

		lea		KeyBuffer(a4),a0	filename
		move.l		a0,d1			into d1
		moveq.l		#0,d2
		moveq.l		#0,d3
		CALLDOS		Execute			execute file

; All done so return

.done		rts

;--------------
;--------------	Search a file for a string
;--------------

; determine line to start searching for

DoSearch	move.l		searchsection(a4),a3	a3->file info
		move.l		file.topline(a3),d6	starting line number
		beq		.error			exit if no file
		addq.l		#1,d6			start 1 line down!

; determine length of search string

		moveq.l		#0,d5			clear
		lea		file.sbuff(a3),a0	a0->string

.LenLoop	tst.b		(a0)+			end of string yet?
		beq.s		.LenDone		exit loop if so!
		addq.l		#1,d5			else bump counter
		bra.s		.LenLoop		and loop

; If no search string, exit in error mode

.LenDone	tst.l		d5			string?
		beq		.error			exit if not

; We now have all required info to start a search loop, so do it!

.SearchLoop	move.l		a3,a0			file info
		move.l		d6,d0			line number
		bsr		LineInfo		address/length
		move.l		d0,d1			buffer length
		beq		.error			exit if invalid!
		move.l		a0,a1			buffer addr
		move.l		d5,d0			string length
		lea		file.sbuff(a3),a0	string address
		bsr		Find			find a match
		tst.l		d0			match found?
		bne.s		.Found			exit loop if so!
		
		addq.l		#1,d6			bump line number
		cmp.l		file.lnum(a3),d6	end of file?
		ble.s		.SearchLoop		loop if not
		bra.s		.error			else exit 

; String found, move to correct line.

.Found		cmp.l		file.max(a3),d6		in last page?
		ble.s		.IsOk			skip if not!
		move.l		file.max(a3),d6		else set to max

.IsOk		move.l		d6,file.topline(a3)	set new position
		bsr		RefreshSection		and display it

		rts					all done so exit!

; If a search fails for any reason, flash the display!

.error		suba.l		a0,a0			all screens
		CALLINT		DisplayBeep		flash!
		rts					and exit


;--------------
;--------------	Search a file backwards for a string
;--------------

; determine line to start searching for

DoSPrev		move.l		searchsection(a4),a3	a3->file info
		move.l		file.topline(a3),d6	starting line number
		beq		.error			exit if no file
		subq.l		#1,d6			start 1 line down!
		beq		.error			exit if at start
		
; determine length of search string

		moveq.l		#0,d5			clear
		lea		file.sbuff(a3),a0	a0->string

.LenLoop	tst.b		(a0)+			end of string yet?
		beq.s		.LenDone		exit loop if so!
		addq.l		#1,d5			else bump counter
		bra.s		.LenLoop		and loop

; If no search string, exit in error mode

.LenDone	tst.l		d5			string?
		beq		.error			exit if not

; We now have all required info to start a search loop, so do it!

.SearchLoop	move.l		a3,a0			file info
		move.l		d6,d0			line number
		bsr		LineInfo		address/length
		move.l		d0,d1			buffer length
		beq		.error			exit if invalid!
		move.l		a0,a1			buffer addr
		move.l		d5,d0			string length
		lea		file.sbuff(a3),a0	string address
		bsr		Find			find a match
		tst.l		d0			match found?
		bne.s		.Found			exit loop if so!
		
		subq.l		#1,d6			bump line number
		bne.s		.SearchLoop		loop while we can
		bra.s		.error			else exit 

; String found, move to correct line.

.Found		cmp.l		file.max(a3),d6		in last page?
		ble.s		.IsOk			skip if not!
		move.l		file.max(a3),d6		else set to max

.IsOk		move.l		d6,file.topline(a3)	set new position
		bsr		RefreshSection		and display it

		rts					all done so exit!

; If a search fails for any reason, flash the display!

.error		suba.l		a0,a0			all screens
		CALLINT		DisplayBeep		flash!
		rts					and exit

;--------------
;--------------	Print page of text
;--------------

DoPrintPage	lea		tutorial(a4),a3		default
		tst.l		active(a4)		correct?
		beq.s		.IsTop			skip if so
		lea		example(a4),a3		set for example

; section determined, get 1st line & number of lines

.IsTop		move.l		file.topline(a3),d7	1st line
		beq.s		.error			exit if no file
		moveq.l		#15,d6			number of lines
		
; print them and exit

		bsr		Print			send to printer
.error		rts					and exit

;--------------
;--------------	Print whole file
;--------------

DoPrintFile	lea		tutorial(a4),a3		default
		tst.l		active(a4)		correct?
		beq.s		.IsTop			skip if so
		lea		example(a4),a3		set for example

; section determined, get 1st line & number of lines

.IsTop		moveq.l		#1,d7			1st line
		move.l		file.lnum(a3),d6	number of lines
		beq.s		.error			exit if no file
		
; print them and exit

		bsr		Print			send to printer
.error		rts					and exit

;--------------
;--------------	Send text to printer
;--------------

; Entry		d6 = number of lines to print
;		d7 = 1st line number
;		a3-> file info

; Open the PRT: device using DOS.

Print		move.l		#printer,d1		filename
		move.l		#MODE_NEWFILE,d2	access mode
		CALLDOS		Open			open printer
		move.l		d0,d5			save handle
		beq.s		.error			exit if no printer

; Start looping! Get line start address and length

.PrintLoop	move.l		d7,d0			line number
		move.l		a3,a0			file info
		bsr		LineInfo		address/length
		tst.l		d0			error?
		beq.s		.done			exit if so!

; Print the line

		move.l		d5,d1			handle
		move.l		a0,d2			address
		move.l		d0,d3			length
		CALLSYS		Write			send to printer

; Bump line number and loop, exit when last line printed.

		addq.l		#1,d7			bump current line
		subq.l		#1,d6			dec line counter
		bne.s		.PrintLoop		loop if more lines

; Close the printer and exit

.done		move.l		d5,d1			handle
		CALLSYS		Close			close printer

		rts

.error		suba.l		a0,a0			all screens
		CALLINT		DisplayBeep		flash!
		rts					and exit


*****************************************************************************
*			Other Subroutines Section					    *
*****************************************************************************

;--------------
;--------------	Load in control file.
;--------------

; If anything goes wrong along the way, all interim memory is released.

; Entry		_args(a4) points to control file name.

; Exit		file is loaded, list created and parameters set.
;		d0=0 if error occurs.

; Corrupt	d0

LoadControl	movem.l		d1-d7/a0-a6,-(sp)	save

		lea		control(a4),a3		a3->file structure

; Load the file and save buffer pointer,size.

		move.l		(a4),a0			filename
		bsr		LoadFile		and load it
		
		move.l		d0,file.size(a3)	save buffer size
		beq		.error			quit if error
		move.l		a0,(a3)			save buffer address

; Create a line list for this file, NULL terminating each line at same time.

		move.l		a3,a0			file info
		moveq.l		#0,d0			line terminator
		bsr		BuildList		build the list
		tst.l		d0			error?
		bne.s		.error			exit if not

; If we get here, line list could not be created. Free loaded text!

		move.l		a3,a0			a0->file info
		bsr		ScrapFile		release it
		moveq.l		#0,d0			indicate error

; All done so exit.

.error		movem.l		(sp)+,d1-d7/a0-a6	restore
		rts					and exit

;--------------
;--------------	Load a tutorial file
;--------------

; The pathname of a tutorial file is always the first line of a control file!

; Entry		control file structure MUST be initalised.

; Exit		d0=0 if an error occurs

; Corrupt	d0

LoadTutor	movem.l		d1-d7/a0-a6,-(sp)	save

; First determine name of tutorial file.

		lea		control(a4),a0		a0->control struct
		move.l		file.line(a0),a0	a0->line list
		move.l		(a0),a0			a0->1st line

; Load the file and save buffer pointer,size.

		bsr		LoadFile		and load it

		lea		tutorial(a4),a3		a3->file structre
		
		move.l		d0,file.size(a3)	save buffer size
		beq		.error			quit if error
		move.l		a0,(a3)			save buffer address

; Create a line list for this file, NULL terminating each line at same time.

		move.l		a3,a0			file info
		moveq.l		#$0a,d0			line terminator
		bsr		BuildList		build the list
		tst.l		d0			error?
		bne.s		.GotFile		skip if not

; If we get here, line list could not be created. Free loaded text!

		move.l		a3,a0			a0->file info
		bsr		ScrapFile		release it
		moveq.l		#0,d0			indicate error
		bra.s		.error			and exit
		
; File loaded and line list constructed. Now determine list parameters.

.GotFile	move.l		file.lnum(a3),d0	number of lines
		sub.l		#16,d0			calc max 1st line
		bpl.s		.Lines			skip if scrollable

; If we get here, less than 16 lines to the file! Set max value accordingly!

		move.l		#1,file.max(a3)		set max value
		bra.s		.done			and continue

; If we get here, more than 15 lines, so set max value.

.Lines		addq.l		#2,d0			correct max value
		move.l		d0,file.max(a3)		and set it

; Make sure initial top line is first line of the file.

.done		moveq.l		#1,d0			no errors
		move.l		d0,file.topline(a3)	set 1st line

.error		movem.l		(sp)+,d1-d7/a0-a6	restore
		rts					and exit

;--------------
;--------------	Load an example file
;--------------

; The pathname of an example file is determined by the current topline entry
;in the control file info structure.

; Entry		control file structure MUST be initalised.

; Exit		d0=0 if an error occurs

; Corrupt	d0

LoadExample	movem.l		d1-d7/a0-a6,-(sp)	save

; First determine name of example file.

		lea		control(a4),a0		a0->control struct
		move.l		file.topline(a0),d0	line number
		bsr		LineInfo		address/length

; Load the file and save buffer pointer,size.

		bsr		LoadFile		and load it

		lea		example(a4),a3		a3->file structre
		
		move.l		d0,file.size(a3)	save buffer size
		beq		.error			quit if error
		move.l		a0,(a3)			save buffer address

; Create a line list for this file, NULL terminating each line at same time.

		move.l		a3,a0			file info
		moveq.l		#$0a,d0			line terminator
		bsr		BuildList		build the list
		tst.l		d0			error?
		bne.s		.GotFile		skip if not

; If we get here, line list could not be created. Free loaded text!

		move.l		a3,a0			a0->file info
		bsr		ScrapFile		release it
		moveq.l		#0,d0			indicate error
		bra.s		.error			and exit
		
; File loaded and line list constructed. Now determine list parameters.

.GotFile	move.l		file.lnum(a3),d0	number of lines
		sub.l		#16,d0			calc max 1st line
		bpl.s		.Lines			skip if scrollable

; If we get here, less than 16 lines to the file! Set max value accordingly!

		move.l		#1,file.max(a3)		set max value
		bra.s		.done			and continue

; If we get here, more than 15 lines, so set max value.

.Lines		addq.l		#2,d0			correct max value
		move.l		d0,file.max(a3)		and set it

; Make sure initial top line is first line of the file.

.done		moveq.l		#1,d0			no errors
		move.l		d0,file.topline(a3)	set 1st line

.error		movem.l		(sp)+,d1-d7/a0-a6	restore
		rts					and exit


;--------------
;--------------	Subroutine that loads a file into a block of memory.
;--------------

; Entry		a0-> filename

; Exit		d0= length of buffer allocated
;		a0->buffer

; Corrupt	d0,a0

LoadFile	movem.l		d1/d5-d7/a4/a5,-(sp)

		moveq.l		#0,d1			any mem will do
		move.l		a0,a5			save filename pointer

		bsr		FileLen			obtain size of file

		move.l		d0,d5			save file size
		beq.s		.error			quit if zero

;--------------	Filesize determined so allocate a buffer. NB d1= requirements.

		CALLEXEC	AllocMem		get buffer
		move.l		d0,d7			save pointer
		tst.l		d0			all ok?
		bne.s		.cont			if so skip next bit

		moveq.l		#0,d5			set error
		bra		.error			and quit

.cont		move.l		a5,d1			d1->filename
		move.l		#MODE_OLDFILE,d2	access mode
		CALLDOS		Open			open the file
		move.l		d0,d6			save handle
		bne		.cont1			quit if error

		move.l		d7,a1			buffer
		move.l		d5,d1			length
		CALLEXEC	FreeMem			and release it
		moveq.l		#0,d5			set error
		bra		.error			and quit

.cont1		move.l		d0,d1			handle
		move.l		d7,d2			buffer
		move.l		d5,d3			file length
		CALLDOS		Read			and load the file

		move.l		d6,d1			handle
		CALLDOS		Close			close the file

		move.l		d7,a0			a0->buffer
.error		move.l		d5,d0			d0=return value
		movem.l		(sp)+,d1/d5-d7/a4/a5
		rts

		***************************************

;--------------
;--------------	Subroutine that returns the length of a file in bytes.
;--------------

; Entry		a0 = address of file name

; Exit		d0 = length of file in bytes or 0 if any error occurred

; Corrupted	a0

;-------------- Save register values

FileLen		movem.l		d1-d4/a1-a4,-(sp)	save registers

;-------------- Save address of filename and clear file length

		move.l		a0,RFfile_name(a4)	save name
		move.l		#0,RFfile_len(a4)	clear length

;-------------- Allocate some memory for the File Info block

		move.l		#fib_SIZEOF,d0		size of FileInfoBlock
		moveq.l		#MEMF_PUBLIC,d1		type required
		CALLEXEC	AllocMem		request it
		move.l		d0,RFfile_info(a4)	save block address
		beq		.error1			exit if NULL
		
;-------------- Lock the file
		
		move.l		RFfile_name(a4),d1	file name
		moveq.l		#-2,d2		access mode
		CALLDOS		Lock			and Lock it
		move.l		d0,RFfile_lock(a4)	save the key
		beq		.error2			exit if NULL

;-------------- Use Examine to load the File Info block

		move.l		d0,d1			key
		move.l		RFfile_info(a4),d2	FileInfoBlock
		CALLSYS		Examine			get file data

;-------------- Copy the length of the file into RFfile_len

		move.l		RFfile_info(a4),a0		FileInfoBlock
		move.l		fib_Size(a0),RFfile_len(a4)	copy length

;-------------- Release the file

		move.l		RFfile_lock(a4),d1	key
		CALLSYS		UnLock			release file

;-------------- Release allocated memory

.error2		move.l		RFfile_info(a4),a1	FileInfoBlock
		move.l		#fib_SIZEOF,d0		size of block
		CALLEXEC	FreeMem			release it

;-------------- All done so return

.error1		move.l		RFfile_len(a4),d0	d0=files size
		movem.l		(sp)+,d1-d4/a1-a4	restore registers
		rts					and exit

		***************************************

;--------------
;--------------	Build a list of pointers to each line in a text file
;--------------

; Entry		a0->file.info structure
;		d0=line terminator - set to either $00 or $0a

; Exit		memory for line list allocated and list created.
;		address and size of line list buffer saved in file.info
;		file.topline set to first line
;		file.lnum set to number of entries
;		file.search set to line 1 of the file.
;		d0=0 if memory allocation error occurred

; Corrupt	d0

BuildList	movem.l		d1-d7/a0-a6,-(sp)

		move.l		a0,a3			a3->file.info
		move.l		d0,d7			save terminator

;--------------	Count num of lines in file

		moveq.l		#0,d0			init counter
		move.l		d0,d1			clear d1
		moveq.l		#$0a,d2			d2=line-feed
		move.l		file.size(a3),d3	init loop counter
		move.l		(a3),a0			a0->buffer
		movem.l		d1-d3/a0,-(sp)		save init values

.lf_loop	cmp.b		(a0)+,d2		is this byte a LF
		bne.s		.ok			if not jump
		addq.l		#1,d0			else bump counter
		move.b		d7,-1(a0)		and set to NULL

.ok		subq.l		#1,d3			loop 'til end of file
		bne.s		.lf_loop

;--------------	Get memory for line table, addr of start of every line
;		will be saved in this table

		move.l		d0,file.lnum(a3)	save counter
		addq.l		#2,d0			to be safe
		asl.l		#2,d0			x4, 4 bytes/entry
		move.l		d0,file.lsize(a3)	save size of table
		moveq.l		#MEMF_PUBLIC,d1		memory type
		CALLEXEC	AllocMem		get mem for line list
		movem.l		(sp)+,d1-d3/a0		reset registers
		move.l		d0,file.line(a3)	save pointer
		beq.s		.mem_error		leave if error

;--------------	Find addr of start of each line and store in table

		move.l		d0,a1			a1->table
		move.l		a0,(a1)+		1st line into table
		move.l		d7,d2			search for LF bytes

.table_loop	cmp.b		(a0)+,d2		this byte a LF
		bne.s		.ok1			if not then jump
		move.l		a0,(a1)+		save addr of nxt line
.ok1		subq.l		#1,d3			loop til end of file
		bne.s		.table_loop	
		
		moveq.l		#1,d0			no errors
		move.l		d0,file.topline(a3)	set top line num
		move.l		d0,file.search(a3)	and search position

.mem_error	movem.l		(sp)+,d1-d7/a0-a6	restore
		rts					and exit

		***************************************

;--------------
;--------------	Free all memory tied up by a loaded file
;--------------

; Safe to call this routine even if no file has been loaded or a file has
;been loaded, but no line list generated.

; Entry		a0->file.info

; Exit		None

; Corrupt	None

ScrapFile	movem.l		d0-d2/a0-a3,-(sp)	save

		move.l		a0,a3			into a safe register

; Free buffer holding the file

		move.l		(a3),d0			memory block
		beq.s		.nobuffer		skip if no address
		move.l		d0,a1			a1->block
		move.l		file.size(a3),d0	size of block
		CALLEXEC	FreeMem			release it

; Free memory holding the line list

.nobuffer	move.l		file.line(a3),d0	memory block
		beq.s		.nolist			skip if no address
		move.l		d0,a1			a1->block
		move.l		file.lsize(a3),d0	size of block
		CALLEXEC	FreeMem			release it

; Reset the structure

.nolist		moveq.l		#0,d0			clear register
		move.l		d0,(a3)+		clear .buffer
		move.l		d0,(a3)+		clear .size
		move.l		d0,(a3)+		clear .line
		move.l		d0,(a3)+		clear .lsize
		move.l		d0,(a3)+		clear .lnum
		move.l		d0,(a3)+		clear .current
		move.l		d0,(a3)+		clear .search
		move.l		d0,(a3)			clear .max

		movem.l		(sp)+,d0-d2/a0-a3	restore
		rts					and exit

		***************************************

;--------------
;--------------	Obatain address and length of a line of text
;--------------

; This subroutine is intended for use with lines of text that are $0a
;terminated. There should be no need for the length of a line that is NULL
;terminated in this program.

; Entry		a0->file.info
;		d0=line number ( 1 <= number <= file.lnum )

; Exit		a0->start of line
;		d0=lines length or NULL if line number out of range.

; Corrupt	d0,a0

LineInfo	movem.l		d1-d3/a1-a3,-(sp)	save

		move.l		a0,a3			safe copies
		move.l		d0,d3
		beq.s		.OutOfRange		skip if NULL

; Check line number is in specified range.

		cmp.l		file.lnum(a3),d0	check upper limit
		ble.s		.InRange		continue if ok.

.OutOfRange	moveq.l		#0,d0			signal error
		move.l		d0,a0			no mistakes
		bra.s		.error			and exit!

; Locate line of text

.InRange	move.l		file.line(a3),a0	a0->start of list
		subq.l		#1,d0			calculate offset
		asl.l		#2,d0
		adda.l		d0,a0			a0->correct entry
		move.l		(a0),a3			a3->text

; determine length of the line. The line may be terminated by either a $0a or
;a $0 byte, both cases must be addressed for consistency. In both cases, the
;length WILL include the terminating byte.

		move.l		a3,a0			a0->text
		moveq.l		#0,d0			clear counter
		moveq.l		#$0a,d1			set test byte

.CountLoop	addq.l		#1,d0			bump counter
		tst.b		(a3)+			NULL terminator?
		beq.s		.error			if so exit loop
		
		cmp.b		-1(a3),d1		LF terminator?
		beq.s		.error			if so exit loop

		bra.s		.CountLoop		loop back

; Line address and length are now determined, so exit.

.error		movem.l		(sp)+,d1-d3/a1-a3	retrieve
		rts					and exit

;--------------
;--------------	Routine to display custom 'sleeping' pointer
;--------------

PointerOn	movem.l		d0-d3/a0-a2,-(sp)	save registers
		move.l		win.ptr(a4),a0		a0->Window struct
		lea		newptr,a1		a1->sleepy pointer
		moveq.l		#16,d0			16 lines high
		move.l		d0,d1			16 pixels wide
		moveq.l		#0,d2			hit point X=0
		move.l		d2,d3			hit point Y=0
		CALLINT		SetPointer		turn it on
		movem.l		(sp)+,d0-d3/a0-a2	restore registers
		rts					and return

		***************************************

;--------------
;--------------	Routine to display default Intuition pointer
;--------------

PointerOff	movem.l		d0-d2/a0-a2,-(sp)	save registers
		move.l		win.ptr(a4),a0		a0->Window struct
		CALLINT		ClearPointer		reset std pointer
		movem.l		(sp)+,d0-d2/a0-a2	restore registers
		rts					and return

		***************************************

;--------------
;--------------	Subroutine to display any message in the CLI window
;--------------

; Entry		a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

DosMsg		movem.l		d0-d3/a0-a3,-(sp)	save registers

		tst.l		STD_OUT(a4)		test for open console
		beq		.error			quit if not one

		move.l		a0,a1			get a working copy

;--------------	Determine length of message

		moveq.l		#-1,d3			reset counter
.loop		addq.l		#1,d3			bump counter
		tst.b		(a1)+			is this byte a 0
		bne.s		.loop			if not loop back

;--------------	Make sure there was a message

		tst.l		d3			was there a message ?
		beq.s		.error			if not, graceful exit

;--------------	Get handle of output file

		move.l		STD_OUT(a4),d1		d1=file handle
		beq.s		.error			leave if no handle

;--------------	Now print the message
;		At this point, d3 already holds length of message
;		and d1 holds the file handle.

		move.l		a0,d2			d2=address of message
		CALLDOS		Write			and print it

;--------------	All done so finish

.error		movem.l		(sp)+,d0-d3/a0-a3	restore registers
		rts

		***************************************

;--------------
;--------------	Subroutine to search a block of memory for a given string.
;--------------

; Entry		a0 addr of string to search for
;		d0 length of string
;		a1 addr of memory block
;		d1 length of memory block

; Exit		d0 addr of first occurence of string, 0 if no match found

; Corrupted	d0

Find		movem.l		d1-d2/a0-a2,-(sp) 	save values
		move.l		#0,_MatchFlag(a4)	assume failure
		sub.l		d0,d1			set up counter
		subq.l		#1,d1			correct for dbra
		bmi.s		.FindError		quit if block<string

		move.b		(a0),d2			d2=1st char to match
.Floop		cmp.b		(a1)+,d2		match 1st of string ?
		dbeq		d1,.Floop		no+not end, loop back

		bne.s		.FindError		if no match+end, quit

		bsr.s		.CompStr		check rest of string

		beq.s		.Floop			loop back if no match

.FindError	movem.l		(sp)+,d1-d2/a0-a2	retrieve values
		move.l		_MatchFlag(a4),d0	set d0 for return
		rts					and exit

.CompStr	movem.l		d0/a0-a2,-(sp)

		subq.l		#1,d0			correct for dbra
		move.l		a1,a2			save a copy
		subq.l		#1,a1			correct as its bumped
.FFloop		cmp.b		(a0)+,(a1)+		compare next chars
		dbne		d0,.FFloop		while notend,no match

		bne.s		.ComprDone		no match so quit
		subq.l		#1,a2			correct this addr
		move.l		a2,_MatchFlag(a4)	save addr of match

.ComprDone	movem.l		(sp)+,d0/a0-a2
		tst.l		_MatchFlag(a4)	       set Z flag as required
		rts

		***************************************

;--------------
;--------------	Converts text string to upper case.
;--------------

;Entry		a0->start of null terminated text string

;Exit		a0->end of text string ( the zero byte ).

;corrupted	a0

ucase		tst.b		(a0)
		beq.s		.error
		
.loop		cmpi.b		#'a',(a0)+
		blt.s		.ok
		
		cmp.b		#'z',-1(a0)
		bgt.s		.ok
		
		subi.b		#$20,-1(a0)
		
.ok		tst.b		(a0)
		bne.s		.loop
		
.error		rts

****************************************************************************
*		Text Printing Subroutines					   *
****************************************************************************

;--------------
;--------------	Refresh the tutorial display
;--------------

RefreshSection	movem.l		d0-d7/a0-a6,-(sp)	save

; Determine which section is active and get 1st line number

		lea		tutorial(a4),a3		a3->file info
		tst.l		active(a4)		test flag
		beq.s		.IsTutor		skip if top section
		lea		example(a4),a3		else select example
		
.IsTutor	move.l		file.topline(a3),d7	d7=1st line number

; Now move cursor to top left of tutorial display area

		move.l		#CursorHomeCls,d0	console command
		bsr		ConComm			send it

; And print 15 successive lines of text!

		moveq.l		#14,d6			line counter
		move.l		file.lnum(a3),d5	number of entries

.LineLoop	move.l		a3,a0			file info
		move.l		d7,d0			line number
		bsr		LineInfo		get info
		tst.l		d0			valid line number?
		beq.s		.done			exit loop if not!
		
		move.l		a0,d1
		bsr		ConText			print line

		addq.l		#1,d7			bump line number
		dbra		d6,.LineLoop		and loop

; If we get here, all 15 lines have been printed or text exhausted!


.done		bsr		SectionStatus		refresh status!
		movem.l		(sp)+,d0-d7/a0-a6	restore
		rts
		
;--------------
;--------------	Section Status, displays position through text.
;--------------

; Entry		file info structures MUST exsist

; Exit		Screen updated

; Corrupt	None

SectionStatus	movem.l		d0-d7/a0-a6,-(sp)

; determine which section of display is currently active

		tst.l		active(a4)		see where we are
		bne		.IsExample		skip if example

; must be tutorial file, so build status text

		lea		DStream(a4),a0		a0->DataStream
		lea		tutorial(a4),a3		file info
		move.l		file.topline(a3),(a0)+	save 1st line number
		move.l		file.lnum(a3),(a0)+	save total lines
		move.l		#440,d6			x offset
		moveq.l		#0,d7			y offset
		lea		StatusT,a0		template
		bra		.DoStatus		and display it

; must be example file, so build status text

.IsExample	lea		DStream(a4),a0		a0->DataStream
		lea		control(a4),a3		file info
		move.l		file.topline(a3),d0	example number
		beq		.done			exit if no example
		subq.l		#1,d0			correct it
		move.l		d0,(a0)+		save
		move.l		file.lnum(a3),d0	total examples
		subq.l		#1,d0			correct
		move.l		d0,(a0)+		save
		lea		example(a4),a3		file info
		move.l		file.topline(a3),(a0)+	save 1st line number
		beq		.done			exit if no example
		move.l		file.lnum(a3),(a0)+	save total lines
		move.l		#344,d6			x offset
		move.l		#128,d7			y offset
		lea		StatusE,a0		template

; can now build status text

.DoStatus	lea		DStream(a4),a1		DataStream
		lea		PutChar,a2		subroutine
		lea		KeyBuffer(a4),a3	Buffer
		CALLEXEC	RawDoFmt		build text

; and print it

		move.l		win.rp(a4),a0		RastPort
		lea		KeyBuffer(a4),a1	text
		move.l		a1,StatusPtr		connect to IText
		lea		StatusText,a1		IText
		move.l		d6,d0			x offset
		move.l		d7,d1			y offset
		CALLINT		PrintIText		and display it
		
; all done so exit
		
.done		movem.l		(sp)+,d0-d7/a0-a6	restore
		rts					and exit
		
****************************************************************************
*		Console Subroutines					   *
****************************************************************************

;--------------
;--------------	Convert RAWKEY into an ANSI string
;--------------

; Entry		a1->IntuiMessage

; Exit		KeyBuffer will contain ANSI string, NULL terminated.
;		a0->KeyBuffer
;		d0=length of string or NULL, or -1 if buffer overflow
; Corrupt	None

ConvertRAW	movem.l		d1-d2/a1-a2/a6,-(sp)	save

; Copy required data from IntuiMessage into InputEvent message and init the
;InputEvent structure.

		lea		IEStructure(a4),a0
		move.b		#IECLASS_RAWKEY,ie_Class(a0)
		move.w		im_Code(a1),ie_Code(a0)
		move.w		im_Qualifier(a1),ie_Qualifier(a0)
		move.l		im_IAddress(a1),ie_EventAddress(a0)

; Use the console.device to convert from RAWKEY to ANSI.

		lea		WriteReq(a4),a1
		move.l		IO_DEVICE(a1),a6
		lea		KeyBuffer(a4),a1
		moveq		#40,d1
		sub.l		a2,a2			use default keymap
		jsr		_LVORawKeyConvert(a6)
		lea		KeyBuffer(a4),a0
		move.b		#0,0(a0,d0.w)		null terminate string

		movem.l		(sp)+,d1-d2/a1-a2/a6	restore
		rts					and exit

;--------------	
;--------------	Subroutine to send command to console device
;--------------

; Entry		d0=address of NULL terminated command string

; Exit		NONE

; Corrupt	assume d0,d1,a0,a1

ConComm		lea		WriteReq(a4),a1		IO structure
		move.w		#CMD_WRITE,IO_COMMAND(a1) device command
		move.l		d0,IO_DATA(a1)		ptr to data buffer
		move.l		#-1,IO_LENGTH(a1)	NULL terminated
		CALLEXEC	DoIO			send message
		rts

;--------------	
;--------------	Subroutine to send a line of text to console device
;--------------

; Entry		d1=address of text
;		d0=length of text

; Exit		NONE

; Corrupt	assume d0,d1,a0,a1

ConText		lea		WriteReq(a4),a1		IO structure
		move.w		#CMD_WRITE,IO_COMMAND(a1) device command
		move.l		d1,IO_DATA(a1)		ptr to data buffer
		move.l		d0,IO_LENGTH(a1)	length of line
		CALLEXEC	DoIO			send message
		rts

*****************************************************************************
*			Exec Support Routines				    *
*****************************************************************************

;--------------
;--------------	Create and initialise a List
;--------------

* NewList(list,type)
* a0 = list (to initialise)
* d0 = type

* NON-MODIFIABLE.

NewList		move.l		a0,(a0)			lh_head-> lh_tail
		addq.l		#4,(a0)
		clr.l		4(a0)			lh_tail = NULL
		move.l		a0,8(a0)		lh_tailpred-> lh_head

		move.b		d0,12(a0)		list type

		rts

;--------------
;--------------	Create and initialise a Port
;--------------

* port = CreatePort(Name,Pri)
* a0 = name
* d0 = pri
* returns d0 = port, NULL if couldn't do it

* d1/d7/a1 corrupt

* NON-MODIFIABLE.


CreatePort	movem.l		d0/a0,-(sp)		save parameters
		moveq		#-1,d0
		CALLEXEC	AllocSignal		get a signal bit
		tst.l		d0
		bmi.s		cp_error1
		move.l		d0,d7			save signal bit

* got signal bit. Now create port structure.

		moveq.l		#MP_SIZE,d0
		move.l		#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		tst.l		d0
		beq.s		cp_error2		couldn't create port

* Here initialise port node structure.

		move.l		d0,a0
		movem.l		(sp)+,d0/d1		get parms off stack
		move.l		d1,LN_NAME(a0)		set name pointer
		move.b		d0,LN_PRI(a0)		and priority

		move.b		#NT_MSGPORT,LN_TYPE(a0)	it's a message
						;port

* Here initialise rest of port.

		move.b		#PA_SIGNAL,MP_FLAGS(a0)	signal if msg received
		move.b		d7,MP_SIGBIT(a0)	signal bit here
		move.l		a0,-(sp)
		sub.l		a1,a1
		CALLEXEC	FindTask		find THIS task
		move.l		(sp)+,a0
		move.l		d0,MP_SIGTASK(a0)	signal THIS task if msg arrived

* Here, if public port, add to public port list, else
* initialise message list header.

		tst.l		LN_NAME(a0)		got a name?
		beq.s		cp_private		no

		move.l		a0,-(sp)
		move.l		a0,a1
		CALLEXEC	AddPort			add to public list
		move.l		(sp)+,d0		(which also NewList()s
		rts					the mp_MsgList)

* Here initialise list header.

cp_private	lea		MP_MSGLIST(a0),a1	ptr to list structure
		exg		a0,a1			for now
		move.b		#NT_MESSAGE,d0		type = message list
		bsr		NewList			do it!

		move.l		a1,d0			return ptr to port
		rts

* Here couldn't allocate. Release signal bit.

cp_error2	move.l		d7,d0
		CALLEXEC	FreeSignal

* Here couldn't get a signal so quit NOW.

cp_error1	movem.l		(sp)+,d0/a0
		moveq		#0,d0			signal no port exists!

		rts

;--------------
;--------------	Delete a Port
;--------------

* DeletePort(Port)
* a0 = port

* a1 corrupt

* NON-MODIFIABLE.


DeletePort	move.l		a0,-(sp)
		tst.l		LN_NAME(a0)		public port?
		beq.s		dp_private		no

		move.l		a0,a1
		CALLEXEC	RemPort			remove port

* here make it difficult to re-use the port.

dp_private	move.l		(sp)+,a0
		moveq		#-1,d0
		move.l		d0,MP_SIGTASK(a0)
		move.l		d0,MP_MSGLIST(a0)

* Now free the signal.

		moveq		#0,d0
		move.b		MP_SIGBIT(a0),d0
		CALLEXEC	FreeSignal

* Now free the port structure.

		move.l		a0,a1
		moveq.l		#MP_SIZE,d0
		CALLEXEC	FreeMem

		rts

;--------------
;--------------	Subroutine called by RawDoFmt
;--------------

PutChar		move.b		d0,(a3)+
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

ConsoleName	dc.b		'console.device',0
		even

PortName	dc.b		'acc_port',0
		even

printer		dc.b		'PRT:',0
		even

StatusT		dc.b		'Line %6ld of %-6ld',0
		even		19 chars
		
StatusE		dc.b		'%2ld of %-2ld    Line %6ld of %-6ld',0
		even		36 chars
		
; replace the usage text below with your own particulars

_UsageText	dc.b		$0a,$0a
		dc.b		'Amiga Coders Manual Tutorial Displayer.'
		dc.b		$0a
		dc.b		'	Copyright    : M.Meany, April 92.',$0a
		dc.b		'	Programmer   : M.Meany, April 92.',$0a
		dc.b		'	Language Used: Assembly Language.',$0a
		dc.b		$0a,$0a
		dc.b		'Usage: Display <control file>'
		dc.b		$0a,$0a
		dc.b		' The control file must be an ASCII file set out as follows:',$0a,$0a
		dc.b		'Line 1:	full pathname of tutorial file.',$0a
		dc.b		'Line 2: full pathname of first example file.',$0a
		dc.b		'Line 3: full pathname of second example file.',$0a
		dc.b		'  "	"	"	"	"	"',$0a
		dc.b		'Line n: full pathname of nth example file.',$0a
		dc.b		$0a,$0a
		dc.b		0
		even

; Error messages printed into CLI window.

_ErrNoControl	dc.b		$0a
		dc.b		'Could not load control file .... Aborted!'
		dc.b		$0a,$0a,0
		even

_ErrNoTutorial	dc.b		$0a
		dc.b		' Could not load tutorial file as specified',$0a
		dc.b		' in control file .... Aborted!'
		dc.b		$0a,$0a,0
		even

; Commands for the console device.

CSI		equ		$9b		Command Sequence Introducer

Return		dc.b	CSI,$4b,$0d,$0a,CSI,$4c,0  line feed
		even
CursorOn	dc.b	CSI,$20,$70,0		Turn cursor on
		even
CursorOff	dc.b	CSI,$30,$20,$70,0	Turn cursor off
		even
ScrollOff	dc.b	CSI,$3e,$31,$6c,0	Disable auto scrolling
		even
CursorHome	dc.b	CSI,'H',0		cursor to (1,1)
		even
CursorHomeCls	dc.b	CSI,'H',CSI,'J',0	cursor to (1,1) and Cls
		even
CursorEnd	dc.b	CSI,'15;1H',0		cursor to (1,15)
		even
HomeTop		dc.b	CSI,'2;1H',0		cursor to (1,2)
		even
HomeBottom	dc.b	CSI,'18;1H',0		cursor to (1,18)
		even
EndTop		dc.b	CSI,'16;1H',0		cursor to (1,16)
		even
EndBottom	dc.b	CSI,'32;1H',0		cursor to (1,32)
		even

; These commands scroll the display and position the cursor at the correct
;place.

ScrollDown	dc.b	CSI,'1',$54		scroll window down 1 line
		dc.b	CSI,'H',0		cursor to (1,1)
		even

ScrollUp	dc.b	CSI,'1',$53		scroll window up 1 line
		dc.b	CSI,'15;1H',0		cursor to (1,15)
		even

; The following are console commands to highlight which section is active.
;They also define the area of the window that the console.device is working
;in. This effectively defines an area of the window for text output and
;makes tasks such as scrolling a piece of cake!

; Top section active

TopText		dc.b	CSI,'0',$79		Top Offset = 0 pixels
		dc.b	CSI,'32',$74		Page Length = 32 lines
		
		dc.b	CSI,'1;36H'		cursor to (36,1)
		dc.b	CSI,'1;32;43m'		BOLD, black on blue
		dc.b	'Tutorial'		text to render
		dc.b	CSI,'0;31;40m'		NORMAL, black on grey
		dc.b	CSI,'17;36H'		cursor to (36,17)
		dc.b	CSI,'3;31;43m'		ITALICS, white on blue
		dc.b	'Example'		text to render
		dc.b	CSI,'0;31;40m'		NORMAL, black on grey
		dc.b	CSI,'8',$79		Top Offset = 8 pixels
		dc.b	CSI,'15',$74		Page Length = 15 lines
		dc.b	0			end of command
		even

; Bottom section active

BottomText	dc.b	CSI,'0',$79		Top Offset = 0 pixels
		dc.b	CSI,'32',$74		Page Length = 32 lines
		
		dc.b	CSI,'1;36H'		cursor to (36,1)
		dc.b	CSI,'3;31;43m'		BOLD, black on blue
		dc.b	'Tutorial'		text to render
		dc.b	CSI,'0;31;40m'		NORMAL, black on grey
		dc.b	CSI,'17;36H'		cursor to (36,17)
		dc.b	CSI,'1;32;43m'		ITALICS, white on blue
		dc.b	'Example'		text to render
		dc.b	CSI,'0;31;40m'		NORMAL, black on grey
				
		dc.b	CSI,'136',$79		Top Offset = 136 pixels
		dc.b	CSI,'15',$74		Page Length = 15 lines
		dc.b	0			end of command
		even

HelpText	dc.b	CSI,'H',CSI,'J'		Home & Cls
		dc.b	'		KEY		   ACTION',$0a
		dc.b	'		 Q		Quit the program!',$0a
		dc.b	'		 L		Load Example Menu',$0a
		dc.b	'		 R		Run Example Menu',$0a
		dc.b	'		 S		Search Menu',$0a
		dc.b	'		 P		Print Menu',$0a
		dc.b	'		 B		Bookmark Menu',$0a
		dc.b	'		TAB		Toggle Tutorial/Example',$0a
		dc.b	'	  cursor up/down	move through text',$0a
		dc.b	'	 cursor left/right	Find Previous/Next',$0a
		dc.b	'	       HELP		This Text',$0a
		dc.b	' NB: Can use shift with the cursor keys to move a page at a time!',$0a
		dc.b	'		Programmed by Mark Meany, April 92.',$0a
		dc.b	$0a
		dc.b	CSI,'4;32;40m','		Press Left Mouse Button To Continue'
		dc.b	CSI,'0;31;40m',0
		even

;***********************************************************
;	Window and Gadget defenitions
;***********************************************************

MyWindow:
    DC.W    0,0,640,256
    DC.B    0,1
    DC.L    CLOSEWINDOW!RAWKEY!MOUSEBUTTONS!INTUITICKS
    DC.L    NOCAREREFRESH+SMART_REFRESH+ACTIVATE+RMBTRAP+BORDERLESS
    DC.L    0,0
    DC.L    0
    DC.L    0,0
    DC.W    150,50,640,256,WBENCHSCREEN

NEWWINDOW:   DC.L   MyWindow
WDBACKFILL   EQU    0

WinText		dc.b		1		FrontPen
		dc.b		3		BackPen
		dc.b		RP_JAM2		DrawMode
		dc.b		0		KludgeFill00
		dc.w		0		x position
		dc.w		0		y position
		dc.l		0		font
		dc.l		.Text		address of text to print
		dc.l		WinText1	more text

;				          1         2         3         4         5         6         7         8
;	80 chars		 12345678901234567890123456789012345678901234567890123456789012345678901234567890
;										        Line nnnnnn of nnnnnn
.Text		dc.b		'                                   Tutorial                                     ',0		the text itself
		even

WinText1	dc.b		1		FrontPen
		dc.b		3		BackPen
		dc.b		RP_JAM2		DrawMode
		dc.b		0		KludgeFill00
		dc.w		0		x position
		dc.w		128		y position
		dc.l		0		font
		dc.l		.Text		address of text to print
		dc.l		0		no more text

;				          1         2         3         4         5         6         7         8
;	80 chars		 12345678901234567890123456789012345678901234567890123456789012345678901234567890
;									    nn of nn    Line nnnnnn of nnnnnn
.Text		dc.b		'                                   Example                                      ',0		the text itself
		even

; Include other structures here, this files big enough already!

StatusText	dc.b		2		FrontPen
		dc.b		3		BackPen
		dc.b		RP_JAM2		DrawMode
		dc.b		0		KludgeFill00
		dc.w		0		x position
		dc.w		0		y position
		dc.l		0		font
StatusPtr	dc.l		0		address of text to print
		dc.l		0

		include		MenuWin.i

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

; Note that variable memory has been defined in this BSS section. This still
;minimises the program size on disk and allows variables to be referenced as
;offsets into this block. Most importantly, it saves having to allocate the
;memory as part of the program!

_DOSBase	ds.l		1		library base pointers
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

VarStart	ds.b		VarSize		variable block

		section Pointer,data_c
;--------------	
;--------------	Custom pointer data ( OK ! I know it`s crap )
;--------------	

newptr
	dc.w		$0000,$0000

	dc.w		$0000,$7ffe
	dc.w		$3ffc,$4002
	dc.w		$3ffc,$5ff6
	dc.w		$0018,$7fee
	dc.w		$0030,$7fde
	dc.w		$0060,$7fbe
	dc.w		$00c0,$7f7e
	dc.w		$0180,$7efe
	dc.w		$0300,$7dfe
	dc.w		$0600,$7bfe
	dc.w		$0c00,$77fe
	dc.w		$1ffc,$6ffa
	dc.w		$3ffc,$4002
	dc.w		$0000,$7ffe
	dc.w		$0000,$0000
	dc.w		$0000,$0000

	dc.w		$0000,$0000



		section		Displayer,code






