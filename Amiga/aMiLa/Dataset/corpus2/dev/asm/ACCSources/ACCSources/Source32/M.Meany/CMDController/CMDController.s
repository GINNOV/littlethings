;****** Auto-Revision Header (do not edit) *******************************
;*
;* © Copyright by MMSoftware
;*
;* Filename         : CMDController.s
;* Created on       : 01-Oct-93
;* Created by       : M.Meany
;* Current revision : V1.003
;*
;*
;* Purpose: Copy a file to the parallel port ... for use with labels
;*          generated using 'cmd parallel <filename>'.
;*                                                    M.Meany (01-Oct-93)
;*          
;*
;* V1.003 : Window refresh code added .. Small oversight!
;*                                                    M.Meany (08-Nov-90)
;*          
;* V1.002 : Fixed bug that stopped file name being displayed during print
;*                                                    M.Meany (08-Nov-90)
;*          
;* V1.001 : Removed bug caused by gadget offsets being incorrect. This
;*          was introduced by removing 1 gadget during last revision.
;*                                                    M.Meany (01-Nov-90)
;*          
;* V1.000 : Reckon it's OK to release now, so docs have been written.
;*          
;* V0.003 : Fixed bug that left 'Print Files' gadget disabled.
;*                                                    M.Meany (29-Oct-90)
;*          
;* V0.002 : Rewritten print routines to allow multi-selection of files.
;*          Yet another users request.
;*                                                    M.Meany (29-Oct-90)
;*          
;* V0.001 : Added a 'Copies' gadget as requested by a user.
;*                                                    M.Meany (29-Oct-90)
;*          
;* V0.000 : --- Initial release ---
;*
;*************************************************************************
REVISION        MACRO
                dc.b "1.003"
                ENDM
REVDATE         MACRO
                dc.b "08-Nov-90"
                ENDM

;GD_QuitGadg                            EQU    0
;GD_LoadGadg                            EQU    1
;GD_PrintGadg                           EQU    2
;GD_PrintTextGadg                       EQU    3
;GD_SetFileGadg                         EQU    4
;GD_GrabParGadg                         EQU    5
;GD_GrabTextGadg                        EQU    6
;GD_DeviceGadg                          EQU    7
;GD_AboutGadg                           EQU    8

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


		include		libraries/gadtools.i
		include		libraries/gadtools_lib.i
		include		libraries/asl.i
		include		libraries/asl_lib.i
		include		libraries/powerpacker_lib.i
		include		libraries/ppbase.i
		include		graphics/displayinfo.i
		include		workbench/workbench.i
		include		workbench/startup.i
		include		workbench/icon.i
		include		workbench/icon_lib.i


		section		Skeleton,code

		include		misc/easystart.i

_SysBase	equ		4

		lea		Variables,a5		a5->var base
	
		move.l		a0,_args(a5)		save addr of CLI args
		move.l		d0,_argslen(a5)		and the length

		bsr		Openlibs		open libraries
		tst.l		d0			any errors?
		beq.s		no_libs			if so quit

		bsr		Init			Initialise data
		tst.l		d0			any errors?
		beq.s		no_libs			if so quit

		lea		CheckDev,a0		server routine
		bsr		ParseArgs		check args!

		bsr		Openwin			open window
		tst.l		d0			any errors?
		beq.s		no_win			if so quit

		bsr		WaitForMsg		wait for user

no_win		bsr		Closewin		close our window

no_libs		bsr		DeInit			free resources

		bsr		Closelibs		close open libraries

		rts					finish

**************	Parse tool types for this application

; Entry		a0->routine to parse argument list¹

; Exit		None

; Corrupt	d0

ParseArgs	PUSHALL

		move.l		a0,a3			supplied routine

		tst.l		returnMsg		from WB?
		beq		.error			no, exit!

; First open icon library

		lea		iconame,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_IconBase		save base ptr
		beq.s		.error			quit if error

	; get into our directory

		move.l		returnMsg,a4		WB Message
		move.l		sm_ArgList(a4),a4	arg list ptr
		move.l		(a4)+,d1		1st arg = name+lock
		CALLDOS		CurrentDir		switch dir
		move.l		d0,d7			save old lock

; grab icon so we can examine it

		move.l		(a4),a0
		CALLICON	GetDiskObject		load icon
		tst.l		d0			load ok?
		beq.s		.NoIcon			nah, get out of here!
		move.l		d0,a4			save pointer

; Find tool type DEV ....... almost there

		move.l		do_ToolTypes(a4),a1	d0->tooltypes array
		cmp.l		#0,a1
		beq.s		.NoTypes

.ToolsList	move.l		(a1)+,a0
		cmp.l		#0,a0
		beq.s		.NoTypes

		PUSHALL					save all registers
		jsr		(a3)			call user routine
		PULLALL					restore registers

		bra.s		.ToolsList

; Free disk object

.NoTypes	move.l		a4,a0
		CALLICON	FreeDiskObject

; Back to original directory

.NoIcon		move.l		d7,d1
		CALLDOS		CurrentDir

; Close icon library

		move.l		_IconBase,a1
		CALLEXEC	CloseLibrary

; and exit

.error		PULLALL
		rts

.DevTool	dc.b		'DEV',0
		even

iconame		dc.b		'icon.library',0
		even
_IconBase	ds.l		1

**************	Check ToolTypes

; a0->ToolType string

CheckDev	move.l		a0,a4

		cmp.l		#'DEV=',(a4)
		bne.s		.NotDev

; Deal with device setting

		addq.l		#4,a4			a4->device

		moveq.l		#2,d1			char counter - 1
		moveq.l		#0,d0			clear
.loop1		asl.l		#8,d0			shift char
		move.b		(a4)+,d0
		cmp.b		#'a',d0
		blt.s		.NotLower
		cmp.b		#'z',d0
		bgt.s		.NotLower
		sub.b		#'a'-'A',d0		convert to upper
.NotLower	dbra		d1,.loop1

		cmp.l		#'PAR',d0		select PAR: ?
		bne.s		.TrySer
		move.w		#0,ParFlag(a5)
		bra.s		.done

.TrySer		cmp.l		#'SER',d0		select SER: ?
		bne.s		.done
		move.w		#1,ParFlag(a5)
		bra.s		.done

; Check if Directory specified

.NotDev		cmp.l		#'DIR=',(a4)
		bne.s		.done

; Deal with directory setting

		addq.l		#4,a4
		lea		CMDir(a5),a0

.loop2		move.b		(a4)+,(a0)+
		bne.s		.loop2

.done		rts

;**************	Open all required libraries

; Open DOS, Intuition and Graphics libraries.

; If d0=0 on return then one or more libraries are not open.

Openlibs	lea		dosname,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_DOSBase		save base ptr
		beq		.lib_error		quit if error

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
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_AslBase		save base ptr
		beq.s		.lib_error		quit if error

		lea		ppname,a1
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_PPBase		save base ptr

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


.ok		move.w		#1,CopyCount(a5)	default to 1 copy

; Set default directory for CMD: sys:Tools/CMD

		lea		DefaultDir(pc),a0
		lea		CMDir(a5),a1

.DefLoop	move.b		(a0)+,(a1)+
		bne.s		.DefLoop

; Get VisualInfo for gadtools use

		bsr		SetupScreen		prep GadTools
		tst.l		d0
		bne.s		.err

; Allocate a Load file requester

		move.l		#ASL_FileRequest,d0
		lea		ASLLOADTAGS(pc),a0
		CALLASL		AllocAslRequest
		move.l		d0,LoadRequest(a5)		

; Allocate a Save file requester

		move.l		#ASL_FileRequest,d0
		lea		ASLSAVETAGS(pc),a0
		CALLASL		AllocAslRequest
		move.l		d0,SaveRequest(a5)		

.error		rts					back to main


ASLLOADTAGS	dc.l		ASLFR_TitleText,LoadTitle
		dc.l		ASLFR_Flags1,FRF_DOMULTISELECT
		dc.l		TAG_DONE		

ASLSAVETAGS	dc.l		ASLFR_Flags1,FRF_DOSAVEMODE
		dc.l		ASLFR_TitleText,SaveTitle
		dc.l		TAG_DONE		

LoadTitle	dc.b		'Load file .........',0
		even

SaveTitle	dc.b		'Redirect to .......',0
		even

DefaultDir	dc.b		'Sys:System/CMD',0
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

; Set MX gadget for the device specified:

		lea		MarksGadgets,a0		Gadget List
		move.l		24(a0),a0		Gadget
		move.l		win.ptr(a5),a1		Window
		suba.l		a2,a2			no request
		lea		.MXTags(pc),a3		a3->TagList
		move.w		ParFlag(a5),6(a3)	set flag
		CALLGAD		GT_SetGadgetAttrsA	set the baby

; Check CMD exsists

		bsr		CheckCMD
		tst.l		d0
		beq.s		.done

		moveq.l		#1,d0			no errors

.done		rts					all done so return

.MXTags		dc.l		GTMX_Active
		dc.l		0
		dc.l		TAG_DONE

**************	Check that CMD is where it's supposed to be

; Exit		d0=0 if we failed to locate CMD

CheckCMD	PUSHALL

; Try to lock CMD

.CheckLoop	lea		CMDir(a5),a0
		move.l		a0,d1
		move.l		#ACCESS_READ,d2
		CALLDOS		Lock
		move.l		d0,d1
		beq.s		.CMDNotHere

; CMD is available, so get out of here

		CALLSYS		UnLock
		moveq.l		#1,d0			found it!
		bra		.done

; No CMD, inform user and give option of locating it!

.CMDNotHere	lea		.NoCMD(pc),a0
		bsr		TFReq
		tst.l		d0			lets quit!
		beq.s		.done
		
; Throw up a file requester so they can find CMD

		move.l		LoadRequest(a5),d0
		beq		.done

; Obtain name of file to load
		
		move.l		d0,a0			request
		lea		.FindTags(pc),a1	no tags
		CALLASL		AslRequest		file request
		tst.l		d0
		beq.s		.done			cancel selected

; Build pathname of CMD

		move.l		LoadRequest(a5),a2
		lea		CMDir(a5),a1

; Copy device name over ..........

		move.l		fr_Drawer(a2),a0

.CopyLoop1	move.b		(a0)+,(a1)+
		bne.s		.CopyLoop1

		subq.l		#1,a1
		cmp.b		#':',-1(a1)
		beq.s		.NoSlash

		move.b		#'/',(a1)+

.NoSlash	move.l		fr_File(a2),a0

.CopyLoop2	move.b		(a0)+,(a1)+
		bne.s		.CopyLoop2
		
		bra		.CheckLoop

.done		PULLALL
		rts

.NoCMD		dc.b		'I cannot locate CMD!',$0a
		dc.b		'Do you want to try?',0
		even

.FindTags	dc.l		ASLFR_TitleText,.FindName
		dc.l		ASLFR_InitialDrawer,.FindDrawer
		dc.l		TAG_DONE

.FindName	dc.b		'Locate CMD ......',0
		even

.FindDrawer	dc.b		'Sys:',0
		even


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

; Deal with refresh as window has been sized. This rewrites text and bevel
;boxes using GadToolsBox routines

		cmp.l		#IDCMP_REFRESHWINDOW,d2
		bne.s		.testGadg
		
		move.l		win.ptr(a5),a0
		CALLGAD		GT_BeginRefresh
		
		bsr		MarksRender
		
		move.l		win.ptr(a5),a0
		moveq.l		#1,d0
		CALLGAD		GT_EndRefresh
		
		bra.s		WaitForMsg

.testGadg	move.l		d2,d0
		and.l		#GADGETUP!GADGETDOWN,d0
		beq.s		_test_win
		
BREAK		moveq.l		#0,d0
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
		beq		WaitForMsg

		rts

*************** Close the Intuition window.

Closewin	bsr		CloseMarksWindow

		rts

***************	Release any additional resources used

DeInit		bsr		CloseDownScreen

; Release memory for exsisting loaded data, if any.

		move.l		LoadFileBuff(a5),a1
		move.l		LoadFileBuffLen(a5),d0
		beq.s		.NoFile
		CALLEXEC	FreeMem
		move.l		#0,LoadFileBuffLen(a5)

; Free file requester structures

.NoFile		move.l		LoadRequest(a5),d0
		beq.s		.next
		move.l		d0,a0
		CALLASL		FreeAslRequest

.next		move.l		SaveRequest(a5),d0
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

		move.l		_PPBase,d0		d0=base ptr
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

		include		cmd.i

**************	Load a file using powerpacker.library

; Requires following variables accessed by a5:

;LoadFileBuff	 rs.l		1		ponter to loaded data
;LoadFileBuffLen rs.l		1		byte size of loaded data

; Subroutine that loads a file into a block of memory.

; Entry		a0-> filename
;		d0=  type of memory

; Exit		d0= length of buffer allocated
;		a0->buffer

; Corrupt	d0,a0

PPLoadFile	movem.l		d1-d7/a1-a6,-(sp)

		move.l		a0,a4
		move.l		d0,d4

; First release memory for exsisting loaded data, if any.

		move.l		LoadFileBuff(a5),a1
		move.l		LoadFileBuffLen(a5),d0
		beq.s		.NoFile
		CALLEXEC	FreeMem
		move.l		#0,LoadFileBuffLen(a5)

; Now use powerpacker.library to load data from disk

.NoFile		move.l		a4,a0			filename
		move.l		d4,d0			memf
		moveq.l		#DECR_POINTER,d0	effect
		moveq.l		#0,d1
		lea		LoadFileBuff(a5),a1
		lea		LoadFileBuffLen(a5),a2
		move.l		d1,a3
		CALLNICO	ppLoadData

; Set return data

		move.l		LoadFileBuff(a5),a0
		move.l		LoadFileBuffLen(a5),d0

		movem.l		(sp)+,d1-d7/a1-a6

		rts

*****************************************************************************
*			Data Section					    *
*****************************************************************************

; Program revision details. Can be viewed using 'version' command.

		dc.b		'$VER: CMDController v'
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
ppname		dc.b		'powerpacker.library',0
		even

; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		'This utility copies powerpacked files to par:'
		dc.b		$0a
		dc.b		'Use this for prints saved to disk using CMD.'
		dc.b		$0a
		dc.b		'Programmed and © M.Meany, October 1993.',$0a
		dc.b		$0a
		dc.b		0
		even

QuitMsg		dc.b		'Quit Program?',0
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

CopyCount	rs.w		1		number of copies to print
PCount		rs.w		1		temporary value

STD_OUT		rs.l		1

ParFlag		rs.w		1		set for ser: clear for par:

LoadRequest	rs.l		1
SaveRequest	rs.l		1

LoadFileBuff	rs.l		1		pointer to loaded data
LoadFileBuffLen	rs.l		1		byte size of loaded data

RDFBuffer	rs.b		256		space for cmd line
CMDir		rs.b		128		where to find it!

DStream		rs.l		4

varsize		rs.b		0

		SECTION	Vars,BSS

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1
_GadToolsBase	ds.l		1
_UtilityBase	ds.l		1
_AslBase	ds.l		1
_PPBase		ds.l		1

Variables	ds.b		varsize

		section		Skeleton,code

***** Your code goes here!!!

; Jump table used to locate routine for gadget based on gadget ID.

GadgetVectors	dc.l		DoQuit		0	quit
		dc.l		DoLoad		1	load .cmd
		dc.l		NoFunction	2	file name to print
		dc.l		DoSave		3	save .cmd
		dc.l		DoCMD		4	grab ( call CMD )
		dc.l		NoFunction	5	save file name
		dc.l		DoSerPar	6	select device
		dc.l		DoAbout		7	about gadget
		dc.l		SetCopies	8	Copies gadget

NoFunction	rts

**************	Set number of copies to print

; a4->Gadget

SetCopies	move.l		gg_SpecialInfo(a4),a0
		move.l		si_LongInt(a0),d0
		move.w		d0,CopyCount(a5)
		rts

**************	Obtain name of file to redirect output to

DoSave		move.l		SaveRequest(a5),d0
		beq		.done

; Obtain name of file to redirect to
		
		move.l		d0,a0			request
		suba.l		a1,a1			no tags
		CALLASL		AslRequest		file request
		tst.l		d0
		beq.s		.done			cancel selected

; Set name of file

		move.l		SaveRequest(a5),a0
		move.l		fr_File(a0),SNameHere

		lea		MarksGadgets,a0
		move.l		20(a0),a0		gadget
		move.l		win.ptr(a5),a1		window
		suba.l		a2,a2			no requester
		lea		.TextTAGS,a3
		CALLGAD		GT_SetGadgetAttrsA	refresh title

.done		moveq.l		#0,d2
		rts

.TextTAGS	dc.l		GTTX_Text
SNameHere	dc.l		.NoDataLoaded
		dc.l		TAG_DONE

.NoDataLoaded	dc.b		'Waiting to grab!',0
		even

**************	Call CMD and trap output

DoCMD		PUSHALL

; Check that there is a file loaded, exit if not

		move.l		SaveRequest(a5),a4
		tst.l		fr_File(a4)
		bne.s		.GotFile
		
	; Inform user that no file selected

		lea		.err1(pc),a0
		bsr		OKReq
		bra		.done

; Disable capture gadget

.GotFile	lea		MarksGadgets,a0
		move.l		16(a0),a0		gadget
		move.l		win.ptr(a5),a1		Window
		suba.l		a2,a2			no requester
		lea		.DisableTags(pc),a3
		CALLGAD		GT_SetGadgetAttrsA

; Switch to directory containing the file

		move.l		fr_Drawer(a4),d1
		move.l		#ACCESS_READ,d2
		CALLDOS		Lock
		move.l		d0,d7
		bne.s		.GotDir
		
		lea		.err2,a0
		bsr		OKReq
		bra.s		.NoLock

.GotDir		move.l		d0,d1
		CALLSYS		CurrentDir
		move.l		d0,d7

; Build the command line for CMD

		lea		.Dev1(pc),a0
		tst.w		ParFlag(a5)
		beq.s		.IsPar
		lea		.Dev2(pc),a0

.IsPar		move.l		a0,DStream+4(a5)
		lea		CMDir(a5),a0
		move.l		a0,DStream(a5)
		move.l		fr_File(a4),DStream+8(a5)
		
		lea		.Template(pc),a0
		lea		DStream(a5),a1
		lea		.PutC(pc),a2
		lea		RDFBuffer(a5),a3
		CALLEXEC	RawDoFmt
		
		lea		RDFBuffer(a5),a0
		move.l		a0,d1
		moveq.l		#0,d2
		moveq.l		#0,d3
		CALLDOS		Execute

; Back to initial directory

		move.l		d7,d1
		CALLSYS		CurrentDir
		move.l		d0,d1
		CALLSYS		UnLock

; Enable the gadget again

.NoLock		lea		MarksGadgets,a0
		move.l		16(a0),a0		gadget
		move.l		win.ptr(a5),a1		Window
		suba.l		a2,a2			no requester
		lea		.EnableTags(pc),a3
		CALLGAD		GT_SetGadgetAttrsA

.done		PULLALL
		rts

.PutC		move.b		d0,(a3)+
		rts

.Dev1		dc.b		'parallel',0
		even

.Dev2		dc.b		'serial',0
		even
		
.Template	dc.b		'"%s" %s "%s"',0
		even

.DisableTags	dc.l		GA_Disabled,1
		dc.l		TAG_DONE

.EnableTags	dc.l		GA_Disabled,0
		dc.l		TAG_DONE

.err1		dc.b		'No File Selected!',0
		even
.err2		dc.b		'Could not lock directory!',0
		even

**************	Display about text

DoAbout		PUSHALL

		lea		.About,a0
		bsr		OKReq

		PULLALL
		rts

.About		dc.b		'    CMD Controller, by M.Meany.    ',$0a
		dc.b		'    ~~~~~~~~~~~~~~~~~~~~~~~~~~~    ',$0a
		dc.b		'              Credits              ',$0a
		dc.b		'       Programming by M.Meany      ',$0a
		dc.b		'PowerPacker.library © Nico François',$0a
		dc.b		'   GadToolBox, © Jaba Development  ',$0a
		dc.b		'BumpRevisionDeluxe, © Peter Simons',$0a
		dc.b		$0a
		dc.b		'Paul, Dave & Nola for Beta testing',$0a
		dc.b		'   and sugestions, thanks folks!  ',$0a
		dc.b		0
		even
		
**************	Switch between serial & parallel device

; Mutually exclusive gadgets return the ordinal number of the selection in
;im_Code field. ParFlag acts as a toggle, when set to 0 parallel is selected
;and when set to 1 serial is selected.

DoSerPar	PUSHALL

		move.w		d3,ParFlag(a5)

		PULLALL
		rts

**************	Quit gadget selected

DoQuit		move.l		#CLOSEWINDOW,d2
		rts

**************	Load and print all files selected by user

DoLoad		move.l		LoadRequest(a5),d4
		beq		.done

; Disable the Print gadget

		lea		MarksGadgets,a0
		move.l		4(a0),a0		gadget
		move.l		win.ptr(a5),a1		Window
		suba.l		a2,a2			no requester
		lea		.DisableTags(pc),a3
		CALLGAD		GT_SetGadgetAttrsA

; Obtain name of file to load
		
		move.l		d4,a0			request
		suba.l		a1,a1			no tags
		CALLASL		AslRequest		file request
		tst.l		d0
		beq		.UserQuit		cancel selected

; change to directory containing the file

		move.l		LoadRequest(a5),a0
		move.l		fr_Drawer(a0),d1	d1->dir name
		CALLDOS		Lock			lock the directory
		move.l		d0,d1			save lock
		beq		.UserQuit			exit
		
		CALLSYS		CurrentDir
		move.l		d0,d7			d7=lock on file

; Get address of the next file to print

		move.l		LoadRequest(a5),a4	a4->requester
		move.l		fr_NumArgs(a4),d4	d4=number of files
		move.l		fr_ArgList(a4),a4	a4->WBArgs

; Load The file

.PrintLoop	move.l		#MEMF_CLEAR,d0		d0=memory type
		move.l		wa_Name(a4),a0		a0->filename
		bsr		PPLoadFile
		move.l		d0,d5			d5=load flag

; Display name of file we are attempting to print

		move.l		wa_Name(a4),NameHere	filename
		lea		MarksGadgets,a0
		move.l		8(a0),a0		gadget
		move.l		win.ptr(a5),a1		window
		suba.l		a2,a2			no requester
		lea		TextTAGS,a3
		CALLGAD		GT_SetGadgetAttrsA	refresh title

; If file loaded print it, else display an error message.

		tst.l		d5
		bne.s		.FileLoaded
		
		lea		.NoFileMsg(pc),a0
		bsr		OKReq
		bra.s		.NextFile

.FileLoaded	bsr		PrintLoadFile

.NextFile	addq.l		#wa_SIZEOF,a4		a4->next file name
		subq.l		#1,d4			dec file list ctr
		bne.s		.PrintLoop		and loop

; Must release memory for last file loaded

		move.l		LoadFileBuff(a5),a1
		move.l		LoadFileBuffLen(a5),d0
		beq.s		.NoFile
		CALLEXEC	FreeMem
		move.l		#0,LoadFileBuffLen(a5)

; Back to original directory

.NoFile		move.l		d7,d1
		CALLDOS		CurrentDir
		
		move.l		d0,d1
		CALLSYS		UnLock

; Enable 'Print' gadget and set 'nothing to print' text

.UserQuit	lea		MarksGadgets,a0
		move.l		4(a0),a0		gadget
		move.l		win.ptr(a5),a1		Window
		suba.l		a2,a2			no requester
		lea		.EnableTags(pc),a3
		CALLGAD		GT_SetGadgetAttrsA

		move.l		#NoDataLoaded,NameHere	filename
		lea		MarksGadgets,a0
		move.l		8(a0),a0		gadget
		move.l		win.ptr(a5),a1		window
		suba.l		a2,a2			no requester
		lea		TextTAGS,a3
		CALLSYS		GT_SetGadgetAttrsA	refresh title

.done		moveq.l		#0,d2
		rts

.LoadTags	dc.l		ASLFR_TitleText,LoadTitle
		dc.l		ASLFR_InitialFile,.LoadFile
		dc.l		ASLFR_Flags1,FRF_DOMULTISELECT
		dc.l		TAG_DONE

.LoadFile	dc.w		0

.NoFileMsg	dc.b		'Could not load that file!',0
		even

.DisableTags	dc.l		GA_Disabled,1
		dc.l		TAG_DONE

.EnableTags	dc.l		GA_Disabled,0
		dc.l		TAG_DONE

TextTAGS	dc.l		GTTX_Text
NameHere	dc.l		NoDataLoaded
		dc.l		TAG_DONE

NoDataLoaded	dc.b		'Waiting to print!',0
		even


**************	Copy file to device specified

PrintLoadFile	PUSHALL

; Open printer device handler

		move.l		#.CMD1,d1
		tst.w		ParFlag(a5)
		beq.s		.GotDev
		move.l		#.CMD2,d1

.GotDev		move.l		#MODE_NEWFILE,d2
		CALLDOS		Open
		move.l		d0,d7
		beq.s		.done

; Set counter for number of copies required

		move.w		CopyCount(a5),PCount(a5)

; write file to device

.PrintLoop	move.l		d7,d1			handle
		move.l		LoadFileBuff(a5),d2	buffer
		move.l		LoadFileBuffLen(a5),d3	size
		beq.s		.NoWrite		exit if no data
		CALLDOS		Write

		subq.w		#1,PCount(a5)
		bne.s		.PrintLoop

; Close device

.NoWrite	move.l		d7,d1
		CALLDOS		Close

.done		PULLALL
		rts
		
.CMD1		dc.b		'par:',0
		even

.CMD2		dc.b		'ser:',0
		even

