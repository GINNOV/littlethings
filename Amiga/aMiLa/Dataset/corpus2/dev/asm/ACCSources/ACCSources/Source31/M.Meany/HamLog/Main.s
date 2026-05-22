;****** Auto-Revision Header (do not edit) *******************************
;*
;* © Copyright by MMSoftware
;*
;* Filename         : Main.s
;* Created on       : 01-Sep-93
;* Created by       : M.Meany
;* Current revision : V0.000
;*
;*
;* Purpose: Ametuer Radio Log Book Program.
;*                                                    M.Meany (01-Sep-93)
;*          
;*
;* V0.000 : --- Initial release ---
;*
;*************************************************************************
REVISION        MACRO
                dc.b "0.000"
                ENDM
REVDATE         MACRO
                dc.b "01-Sep-93"
                ENDM


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

CALLSYS		macro
		ifgt	NARG-1
		FAIL	!!!
		endc
		jsr	_LVO\1(a6)
		endm

PUSH		macro			* push specified registers onto stack
		movem.l	\1,-(sp)
		endm

PULL		macro			* pull specified registers off stack
		movem.l	(sp)+,\1
		endm

PUSHALL		macro			* moves d1-d7/a0-a6 onto stack
		PUSH	d1-d7/a0-a6
		endm

PULLALL		macro			* moves d1-d7/a0-a6 off stack
		PULL	d1-d7/a0-a6
		endm

		section		Skeleton,code

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"

		include		equates.i

		lea		Variables,a5		a5->var base
	
		move.l		a0,(a5)			save addr of CLI args
		move.l		d0,_argslen(a5)		and the length

		bsr.s		Openlibs		open libraries
		tst.l		d0			any errors?
		beq.s		no_libs			if so quit

		bsr		Init			Initialise data
		tst.l		d0			any errors?
		beq.s		no_win			if so quit

		bsr		GetPassword
		tst.l		d0
		beq.s		no_win

		bsr		LoadIndex

		bsr		Openwin			open window
		tst.l		d0			any errors?
		beq.s		no_win			if so quit

		bsr		MAbout

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

		move.l		(a5),a0			get addr of CLI args
		cmpi.b		#'?',(a0)		is the first arg a ?
		bne.s		.ok			no, skip next bit

		lea		_UsageText,a0		a0->the usage text
		bsr		DosMsg			and display it
.err		moveq.l		#0,d0			set an error
		bra		.error			and finish

;--------------	Open required data files

; Open operator records file

.ok		lea		OpsFile,a0		filename
		move.l		#OpsRecSize,d0		record size
		bsr		OpenRandom
		move.l		d0,OpsHandle(a5)	save handle
		beq		.error

; Set address of password for decryption

		move.l		OpsHandle(a5),a0
		lea		Password(a5),a1
		bsr		RandPassword

; Determine number of operator records in the file

		move.l		OpsHandle(a5),a0	handle
		bsr		CountRecords		count entries
		move.w		d0,OpCount(a5)		save for later

; Open the Index file

		lea		IndexFile,a0		filename
		moveq.l		#20,d0			record size
		bsr		OpenRandom		open file
		move.l		d0,IndexHandle(a5)	save handle
		beq.s		.error1

; Set address of password for decryption

		move.l		IndexHandle(a5),a0
		lea		Password(a5),a1
		bsr		RandPassword

; Open the Log file

		lea		LogFile,a0		filename
		moveq.l		#LogRecSize,d0		record size
		bsr		OpenRandom
		move.l		d0,LogHandle(a5)	save handle
		beq.s		.error2

; Set address of password for decryption

		move.l		LogHandle(a5),a0
		lea		Password(a5),a1
		bsr		RandPassword

; Determine number of entries in the Log file

		move.l		LogHandle(a5),a0	handle
		bsr		CountRecords		count entries
		move.w		d0,LogCount(a5)		save for later

; Signal A OK!

		moveq.l		#1,d0			no errors

		rts					back to main

.error2		bsr		FreeIndex

		move.l		IndexHandle(a5),a0	handle
		bsr		CloseRandom
		clr.l		IndexHandle(a5)		clear pointer

.error1		move.l		OpsHandle(a5),a0	handle
		bsr		CloseRandom
		clr.l		OpsHandle(a5)		clear pointer

.error		lea		NoFileText,a0
		bsr		OKReq
		
		moveq.l		#0,d0
		rts

*************** Get Password from user

; Entry		None

; Exit		d0=0 if window would not open

; Corrupt	d0

GetPassword	movem.l		d1-d7/a0-a6,-(sp)

; Open input window

		lea		PWWindow,a0		a0->window args
		CALLINT		OpenWindow		and open it
		move.l		d0,tmp.ptr(a5)		save struct ptr
		beq		.error			quit if error

; Extract pointers

		move.l		d0,a0			a0->win struct	
		move.l		wd_UserPort(a0),tmp.up(a5) save up ptr
		move.l		wd_RPort(a0),tmp.rp(a5)    save rp ptr

; Display prompt

		move.l		tmp.rp(a5),a0
		lea		PWText,a1
		moveq.l		#0,d0
		moveq.l		#0,d1
		CALLINT		PrintIText

; Initialise counter

		moveq.l		#0,d7			char counter
		lea		Password(a5),a4		a4->buffer

; Wait for Key Press

.WaitMsg	move.l		tmp.up(a5),a0		a0->user port
		CALLEXEC	WaitPort		wait for message
		move.l		tmp.up(a5),a0		a0->user port
		CALLSYS		GetMsg			get any messages
		tst.l		d0			was there a message ?
		beq.s		.WaitMsg		if not loop back
		move.l		d0,a1			a1-->message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		move.w		im_Code(a1),d3		d3=ASCII
		CALLSYS		ReplyMsg		answer os
		cmp.l		#VANILLAKEY,d2
		bne.s		.WaitMsg

; Add character to password & bump counter

		move.b		d3,(a4)+		copy char
		addq.w		#1,d7			bump pointer

; Echo input to user, print a '?'

		move.l		tmp.rp(a5),a0
		lea		PWQText,a1
		move.l		d7,d0
		asl.w		#3,d0			x8
		moveq.l		#0,d1
		CALLINT		PrintIText

; Exit if we have all 8 chars
		
		cmp.w		#8,d7			got all chars
		bne.s		.WaitMsg	 	if not then loop

; close the window

		move.l		tmp.ptr(a5),a0
		CALLINT		CloseWindow

		moveq.l		#1,d0			no errors

; And exit!

.error		movem.l		(sp)+,d1-d7/a0-a6
		rts

*************** Open An Intuition Window

; Opens an intuition window. If d0=0 on return then window could not be
;opened.

Openwin		lea		MainWindow,a0		a0->window args
		CALLINT		OpenWindow		and open it
		move.l		d0,win.ptr(a5)		save struct ptr
		beq.s		.win_error		quit if error

		move.l		d0,a0			a0->win struct	
		move.l		wd_UserPort(a0),win.up(a5) save up ptr
		move.l		wd_RPort(a0),win.rp(a5)    save rp ptr

;--------------	Add the menu to the window

		move.l		win.ptr(a5),a0		Window
		lea		MainMenu,a1		Menu
		CALLSYS		SetMenuStrip		add it

		bsr		SetWinName

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
		move.w		im_Code(a1),d3		d3=ASCII code
		move.w		im_Qualifier(a1),d4	d4=Qualifier bits
		move.l		im_IAddress(a1),a4 	a4=addr of structure
		CALLSYS		ReplyMsg		answer os

		cmp.l		#MENUPICK,d2
		bne.s		.test_key
		bsr		DoMenus
		bra.s		.test_win

.test_key	cmp.l		#RAWKEY,d2
		bne.s		.test_win
		bsr		DoKeys

.test_win	cmp.l		#CLOSEWINDOW,d2  	window closed ?
		bne.s		WaitForMsg	 	if not then jump

		lea		QuitText,a0
		bsr		TFReq
		tst.l		d0
		bne.s		WaitForMsg

		rts

**************	Handle Menu selections

DoMenus		moveq.l		#0,d7			clear
		move.l		d3,d0			d0=menu code

.Loop		lea		MainMenu,a0
		CALLINT		ItemAddress		get item address
		tst.l		d0			is there one?
		beq.s		.done			exit if not
		move.l		d0,a0			a0->Item
		move.w		mi_NextSelect(a0),LastItem(a5) save
		bsr		DoMenuItem
		move.w		LastItem(a5),d0
		cmp.l		#CLOSEWINDOW,d7
		bne.s		.Loop
		
.done		move.l		d7,d2			return code
		rts					and exitq

***************	Deal with key presses

DoKeys		btst		#7,d3			key up?
		bne		IgnoreKey		yes, ignore it!

		moveq.l		#0,d7			clear return code

; Convert RAW keycode into something usefull

		moveq.l		#0,d0			clear
		move.b		d3,d0			d0=raw code
		bsr		GetChar			convert to ASCII'ish

		tst.b		d0
		beq.s		IgnoreKey

; If shift was held, add 10 to returned value

		and.w		#3,d4			qualifier
		beq.s		.NoShift		no SHIFT keys
		cmp.w		#10,d0
		bgt.s		.NoShift
		add.b		#10,d0

.NoShift	subq.w		#1,d0
		asl.w		#2,d0			*4 for vector offset
		lea		KeyVectors,a0		a0->vector table
		move.l		0(a0,d0.w),a0		a0->routine
		jsr		(a0)

		move.l		d7,d2			return code

IgnoreKey	rts

*************** Close the Intuition window.

Closewin	move.l		win.ptr(a5),a0		a0->Window struct
		CALLINT		CloseWindow		and close it
		rts

***************	Release any additional resources used

DeInit		bsr		FreeIndex

		move.l		LogHandle(a5),d0
		beq.s		.TryIndex
		move.l		d0,a0
		bsr		CloseRandom
		
.TryIndex	move.l		IndexHandle(a5),d0
		beq.s		.TryOps
		move.l		d0,a0
		bsr		CloseRandom

.TryOps		move.l		OpsHandle(a5),d0
		beq.s		.error
		move.l		d0,a0
		bsr		CloseRandom
		
.error		rts

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

; Simple error requester that will display a requester with just an OK gadget

; Entry		a0->NULL terminated text for requester

OKReq		PUSHALL
		lea		OKReqBody,a1
		move.l		a0,it_IText(a1)		IText points to string
		move.l		win.ptr(a5),a0
		suba.l		a2,a2			no +ve text
		lea		OKReqButton,a3
		moveq.l		#0,d0
		moveq.l		#0,d1
		move.l		#200,d2
		moveq.l		#50,d3

		CALLINT		AutoRequest

		PULLALL
		rts

; TRUE or FALSE requester.

; Entry		a0->null terminated text to display

; Exit		d0=TRUE or FALSE depending on user selection

TFReq		PUSHALL
		lea		TFReqBody,a1
		move.l		a0,it_IText(a1)		IText points to string
		move.l		win.ptr(a5),a0
		lea		TFTrue,a2		no +ve text
		lea		TFFalse,a3
		moveq.l		#0,d0
		moveq.l		#0,d1
		move.l		#200,d2
		moveq.l		#50,d3

		CALLINT		AutoRequest

		PULLALL
		rts

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

		dc.b		'$VER: HamLog v'
		REVISION
		dc.b		', © M.Meany '
		REVDATE
		dc.b		' )',0
		even


; Include other files

		include		Subs.i
		include		Random.i
		include		Data.i
		include		IntuitionData.i
		include		BSS.i

