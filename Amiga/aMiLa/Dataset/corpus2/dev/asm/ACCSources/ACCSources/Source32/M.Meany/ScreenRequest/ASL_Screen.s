;****** Auto-Revision Header (do not edit) *******************************
;*
;* © Copyright by MMSoftware
;*
;* Filename         : ASL_Screen.s
;* Created on       : 01-Oct-93
;* Created by       : M.Meany
;* Current revision : V0.000
;*
;*
;* Purpose: Trying the ASL screen requester. Needs asl.library v38 or 
;*          higher to work ( WB 2.1 or higher ).
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
                dc.b "01-Oct-93"
                ENDM



; Demonstrates use of asl.libraries Screen Mode requester. No action is taken
;on the users selection!


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

		include		exec/types.i
		include		intuition/classes.i
		include		intuition/classusr.i
		include		intuition/imageclass.i
		include		intuition/gadgetclass.i
		include		libraries/gadtools.i
		include		libraries/gadtools_lib.i
		include		libraries/asl.i
		include		libraries/asl_lib.i
		include		graphics/displayinfo.i
		include		graphics/gfxbase.i

		include		misc/easystart.i

_SysBase	equ		4

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

no_win		bsr		Closewin		close our window

		bsr		DeInit			free resources

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
		beq.s		.lib_error		quit if error

		lea		gadtoolsname,a1
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_GadToolsBase	save base ptr
		beq.s		.lib_error		quit if error

		lea		utilityname,a1
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_UtilityBase		save base ptr
		beq.s		.lib_error		quit if error

		lea		aslname,a1
		moveq.l		#38,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_AslBase		save base ptr


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

; Get VisualInfo for gadtools use

.ok		bsr		SetupScreen		prep GadTools
		tst.l		d0
		bne.s		.err

; Allocate a screen requester

		move.l		#ASL_ScreenModeRequest,d0
		lea		ASLSCRNTAGS(pc),a0
		CALLASL		AllocAslRequest
		move.l		d0,ScrnRequest(a5)		

		moveq.l		#1,d0			no errors

.error		rts					back to main


ASLSCRNTAGS	dc.l		ASLFR_TitleText,ScrnTitle

; Try commenting out combinations of following flags

		dc.l		ASLSM_InitialInfoOpened,1
		dc.l		ASLSM_InitialInfoLeftEdge,400
		dc.l		ASLSM_DoWidth,1
		dc.l		ASLSM_DoHeight,1
		dc.l		ASLSM_DoDepth,1
		dc.l		ASLSM_DoOverscanType,1
		dc.l		ASLSM_DoAutoScroll,1

		dc.l		TAG_DONE		

ScrnTitle	dc.b		'Select screen mode',0
		even

*************** Open An Intuition Window

; Opens an intuition window. If d0=0 on return then window could not be
;opened.

Openwin		bsr		OpenMarksWindow
		tst.l		d0
		beq.s		.GotWin
		moveq.l		#0,d0
		bra.s		.done

.GotWin		move.l		MarksWnd,a0		   a0->win struct
		move.l		a0,win.ptr(a5)		   save window ptr
		move.l		wd_UserPort(a0),win.up(a5) save up ptr
		move.l		wd_RPort(a0),win.rp(a5)    save rp ptr

		moveq.l		#1,d0			no errors

.done		rts					all done so return

*************** Deal with User interaction

; Uses gadtools functions to get and reply messages. NOTE, will only
;accommodate 8 gadgets at this time.

WaitForMsg	move.l		win.up(a5),a0		a0->user port
		CALLEXEC	WaitPort		wait for message
		move.l		win.up(a5),a0		a0->user port
		CALLGAD		GT_GetIMsg		get any messages
		tst.l		d0			was there a message ?
		beq.s		WaitForMsg		if not loop back
		move.l		d0,a1			a1-->message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		move.w		im_Code(a1),d3		d3=Code for Msg
		move.l		im_IAddress(a1),a4 	a4=addr of structure
		CALLSYS		GT_ReplyIMsg		answer os

		move.l		d2,d0
		and.l		#GADGETUP!GADGETDOWN,d0
		beq.s		_test_win
		
		moveq.l		#0,d0
		move.w		gg_GadgetID(a4),d0
		asl.l		#2,d0			x2 = LONG offset
		lea		GadgetVectors(pc),a0
		move.l		(a0,d0),a0		a0->subroutine

		jsr		(a0)

_test_win	cmp.l		#CLOSEWINDOW,d2  	window closed ?
		bne.s		WaitForMsg	 	if not then jump

		lea		QuitMsg,a0
		bsr		TFReq
		tst.l		d0
		bne.s		WaitForMsg

		rts

; Jump table used to locate routine for gadget based on gadget ID.

GadgetVectors	dc.l		DoQuit		0
		dc.l		DoScreen	1
		dc.l		NoFunction
		dc.l		NoFunction
		dc.l		NoFunction

NoFunction	rts

DoQuit		move.l		#CLOSEWINDOW,d2
		rts

DoScreen	move.l		ScrnRequest(a5),d0
		beq.s		.done
		
		move.l		d0,a0			request
		suba.l		a1,a1			no tags
		CALLASL		AslRequest		file request
		tst.l		d0

.done		moveq.l		#0,d2
		rts

*************** Close the Intuition window.

Closewin	bsr		CloseMarksWindow

		rts

***************	Release any additional resources used

DeInit		bsr		CloseDownScreen

		move.l		ScrnRequest(a5),d0
		beq.s		.done
		move.l		d0,a0
		CALLASL		FreeAslRequest

.done		rts


***************	Close all open libraries

; Closes any libraries the program managed to open.

Closelibs	move.l		_DOSBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

		move.l		_IntuitionBase,d0	d0=base ptr	
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLSYS		CloseLibrary		close lib

		move.l		_GfxBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLSYS		CloseLibrary		close lib

		move.l		_GadToolsBase,d0	d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLSYS		CloseLibrary		close lib

		move.l		_UtilityBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLSYS		CloseLibrary		close lib

		move.l		_AslBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLSYS		CloseLibrary		close lib

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

		include		asl.i

*****************************************************************************
*			Data Section					    *
*****************************************************************************

; Program revision details. Can be viewed using 'version' command.

		dc.b		'$VER: v'
		REVISION
		dc.b		', © M.Meany ('
		REVDATE
		dc.b		')',0
		even


dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even
gfxname		dc.b		'graphics.library',0
		even
gadtoolsname	dc.b		'gadtools.library',0
		even
utilityname	dc.b		'utility.library',0
		even
aslname		dc.b		'asl.library',0
		even

; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		'Tests v38 asl.library ScreenModeRequest.'
		dc.b		$0a
		dc.b		0
		even

QuitMsg		dc.b		'Sure you want to quit?',0
		even

;***********************************************************
;	SECTION	Vars,BSS
;***********************************************************

		rsreset
_args		rs.l		1
_argslen	rs.l		1

win.ptr		rs.l		1
win.rp		rs.l		1
win.up		rs.l		1

STD_OUT		rs.l		1

ScrnRequest	rs.l		1

varsize		rs.b		0

		SECTION	Vars,BSS

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1
_GadToolsBase	ds.l		1
_UtilityBase	ds.l		1
_AslBase	ds.l		1

Variables	ds.b		varsize

		section		Skeleton,code

***** Your code goes here!!!
