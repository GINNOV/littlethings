;****** Auto-Revision Header (do not edit) *******************************
;*
;* © Copyright by MMSoftware
;*
;* Filename         : BankBuilder.s
;* Created on       : 01-Sep-93
;* Created by       : M.Meany
;* Current revision : V0.000
;*
;*
;* Purpose: Build a file of graphic images ready to load into
;*          a program. Main use is for Bob images in games/demos.
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

; IFF Load works
; Bank Save works
; Image Mask correctly built
; Show Image sort of works :-)
; Bank Load works
; Bank merge works
; Load/Save filenames displayed
; Current image number displayed


		rsreset
gfx_Succ	rs.l		1	next in list
gfx_Pred	rs.l		1	previous in list
gfx_Width	rs.w		1	width in bytes
gfx_Height	rs.w		1	height in lines
gfx_Depth	rs.w		1	depth in bpls
gfx_Data	rs.b		0	raw data goes here
gfx_SizeOf	rs.b		0	size of this data header



BuffSize	equ		10*1024		10k buffer for loading IFFs

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

		include		source:include/reqtools_lib.i
		include		source:include/reqtools.i


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
		beq.s		.lib_error		quit if error

		lea		reqname,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_ReqToolsBase		save base ptr

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

.ok		lea		ImageList(a5),a0	initialise Image List
		NEWLIST		a0

		lea		BuiltText(a5),a0	->text buffer
		lea		GeneralIText,a1		->general IntuiText
		move.l		a0,it_IText(a1)		initialise IntuiText

		moveq.l		#RT_FILEREQ,d0		structure required
		lea		LoadTags,a0		no tags
		CALLREQ		rtAllocRequestA		get structure
		move.l		d0,LoadImReq(a5)	save addr
		beq.s		.error
		
		moveq.l		#RT_FILEREQ,d0		structure required
		lea		LoadTags,a0		no tags
		CALLREQ		rtAllocRequestA		get structure
		move.l		d0,LoadBkReq(a5)	save addr
		beq.s		.error

		moveq.l		#RT_FILEREQ,d0		structure required
		suba.l		a0,a0			no tags
		CALLREQ		rtAllocRequestA		get structure
		move.l		d0,SaveBkReq(a5)	save addr
		beq.s		.error

		moveq.l		#1,d0			no errors

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

;--------------	Display basic usage text for user

		move.l		win.rp(a5),a0		a0->RastPort
		lea		WinText,a1		a1->IText structure
		moveq.l		#0,d0			X offset
		moveq.l		#0,d1			Y offset
		CALLINT		PrintIText		print this text

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
		CALLSYS		ReplyMsg		answer os

		move.l		d2,d0
		and.l		#GADGETUP!GADGETDOWN,d0
		beq.s		.test_win
		move.l		gg_UserData(a4),a0
		cmpa.l		#0,a0
		beq.s		.test_win
		jsr		(a0)

.test_win	cmp.l		#CLOSEWINDOW,d2  	window closed ?
		bne.s		WaitForMsg	 	if not then jump

		tst.w		SaveFlag(a5)
		beq.s		.YepQuit

		lea		QuitMsg,a0
		bsr		YesNoReq
		tst.l		d0
		beq.s		WaitForMsg

.YepQuit	rts


*************** Close the Intuition window.

Closewin	move.l		win.ptr(a5),a0		a0->Window struct
		CALLINT		CloseWindow		and close it
		rts

***************	Release any additional resources used

DeInit		move.l		SaveBkReq(a5),d0
		beq.s		.TryLoadBk
		move.l		d0,a1
		CALLREQ		rtFreeRequest
		
.TryLoadBk	move.l		LoadBkReq(a5),d0
		beq.s		.TryLoadIm
		move.l		d0,a1
		CALLREQ		rtFreeRequest
		
.TryLoadIm	move.l		LoadImReq(a5),d0
		beq.s		.TryIFF
		move.l		d0,a1
		CALLREQ		rtFreeRequest
		
.TryIFF		bsr		FreeIFF

		bsr		FreeImages

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
		CALLEXEC	CloseLibrary		close lib

		move.l		_GfxBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

		move.l		_ReqToolsBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.lib_error	rts

*****************************************************************************
*			Subroutines Section				    *
*****************************************************************************

;--------------
;--------------	Display string in STD_OUT
;--------------


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

;--------------
;--------------	Display an Ok/Cancel requester.
;--------------

; Entry		a0->requester text

; Exit		d0=0 if 'OK' selected

; Corrupt	d0,a6

YesNoReq	PUSH		d1-d7/a0-a5

		move.l		a0,a1		requester text
		lea		.YNGadg,a2		text for buttons
		suba.l		a3,a3			no special info
		suba.l		a4,a4			no arg array
		suba.l		a0,a0			no tags
		CALLREQ		rtEZRequestA		display requester

		PULL		d1-d7/a0-a5
		rts	

.YNGadg		dc.b		'Okay|Cancel',0
		even

;--------------
;--------------	Display an Information requester.
;--------------

; Entry		a0->requester text

; Exit		none

; Corrupt	d0,a6

OkayReq		PUSH		d1-d7/a0-a5

		move.l		a0,a1			requester text
		lea		.OkGadg,a2		text for buttons
		suba.l		a3,a3			no special info
		suba.l		a4,a4			no arg array
		suba.l		a0,a0			no tags
		CALLREQ		rtEZRequestA		display requester

		PULL		d1-d7/a0-a5
		rts	

.OkGadg		dc.b		'Okay',0
		even

;--------------
;--------------	Print name of created binary file
;--------------

PrintSaveName	PUSHALL

		lea		ImTextBuff(a5),a0
		move.l		a0,DStream(a5)
		lea		SaveStat,a0
		moveq.l		#90,d0
		moveq.l		#44,d1
		bsr		PrintText

		PULLALL
		rts

;--------------
;--------------	Print name of loaded image bank
;--------------

PrintLoadName	PUSHALL

		lea		ImTextBuff(a5),a0
		move.l		a0,DStream(a5)
		lea		SaveStat,a0
		moveq.l		#90,d0
		moveq.l		#30,d1
		bsr		PrintText

		PULLALL
		rts


;--------------
;--------------	Print stats for loaded image
;--------------

PrintStats	PUSHALL

		move.w		ImageCount(a5),DStream(a5)	prep data
		lea		CountStat,a0			->template
		moveq.l		#73,d0				x
		moveq.l		#60,d1				y
		bsr		PrintText			print it!

		move.w		CurrentImage(a5),DStream(a5)	prep data
		lea		CurrStat,a0			->template
		moveq.l		#14,d0				x
		moveq.l		#74,d1				y
		bsr		PrintText			print it!

		move.l		ImageAddress(a5),a1

		move.w		gfx_Width(a1),DStream(a5)	prep data
		lea		WidthStat,a0			->template
		moveq.l		#14,d0				x
		moveq.l		#86,d1				y
		bsr		PrintText			print it!

		move.w		gfx_Height(a1),DStream(a5)	prep data
		lea		HeightStat,a0			->template
		moveq.l		#14,d0				x
		moveq.l		#98,d1				y
		bsr		PrintText			print it!

		move.w		gfx_Depth(a1),DStream(a5)	prep data
		lea		DepthStat,a0			->template
		moveq.l		#14,d0				x
		moveq.l		#110,d1				y
		bsr		PrintText			print it!

		PULLALL
		rts

;--------------
;--------------	General text printing routine
;--------------

; Uses RawDoFmt() to build text and then prints this in the window at desired
;location! All Data should be pre copied to DStream(a5).

; Entry		a0->template
;		d0=x
;		d1=y

; Exit		None

; Corrupt	d0

PrintText	PUSHALL

		move.l		d0,d6
		move.l		d1,d7

		lea		DStream(a5),a1
		lea		.PC,a2
		lea		BuiltText(a5),a3
		CALLEXEC	RawDoFmt
		
		move.l		win.rp(a5),a0		RastPort
		lea		GeneralIText,a1		IntuiText
		move.l		d6,d0			x
		move.l		d7,d1			y
		CALLINT		PrintIText		print it

		PULLALL
		
		rts

; function called by RawDoFmt() that copies each character into dest buffer

.PC		move.b		d0,(a3)+		copy character
		rts

;--------------
;--------------	Free memory occupied by loaded IFF file
;--------------

; Entry		None

; Exit		None

; Corrupt	d0

FreeIFF		PUSHALL

		move.l		BrushPtr(a5),d0		->custom BitMap
		beq.s		.done			exit if none

		jsr		CleanupGraf		free memory

		move.l		#0,BrushPtr(a5)		clear pointer

.done		PULLALL					and exit
		rts

;--------------
;--------------	Add loaded iff to image list
;--------------

; Entry		none

; Exit		none

; Corrupt	d0

AddImage	PUSHALL

; Get pointer to custom BitMap structure

		move.l		BrushPtr(a5),d0
		bne.s		.Ok1

		lea		NoBrushMsg,a0
		bsr		OkayReq
		bra		.done

; Determine size of raw data for this image and get memory for it

.Ok1		move.l		d0,a4			a4->GrafStruct
		moveq.l		#0,d0			clear
		move.l		d0,d1
		move.w		bm_BytesPerRow(a4),d0	width
		mulu		bm_Rows(a4),d0		width x height
		move.b		bm_Depth(a4),d1		depth
		addq.w		#1,d1			depth + 1
		mulu		d1,d0			WxHx(D+1)
		
		add.l		#gfx_SizeOf,d0		add size of header
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1 type of mem
		CALLEXEC	AllocMem
		tst.l		d0			all ok
		bne.s		.GotMem			skip if so
		
		lea		NoMemMsg,a0		error message
		bsr		OkayReq	
		bra		.done			and exit

; Copy raw data into allocated memory

.GotMem		move.l		d0,a3			a3->node
		moveq.l		#0,d0
		
		move.b		bm_Depth(a4),d0			 depth
		move.w		d0,gfx_Depth(a3)
		
		move.w		bm_BytesPerRow(a4),gfx_Width(a3) width

		move.w		bm_Rows(a4),gfx_Height(a3)	 height
		
		move.l		bm_Planes(a4),a0
		lea		gfx_Data(a3),a1
		move.w		gfx_Depth(a3),d0
		mulu		gfx_Width(a3),d0
		mulu		gfx_Height(a3),d0
		CALLEXEC	CopyMem		

; Add this node to end of list and bump node counter

		lea		ImageList(a5),a0	List Header
		move.l		a3,a1			Node
		ADDTAIL					link 'em

		addq.w		#1,ImageCount(a5)	bump counter
		move.w		ImageCount(a5),CurrentImage(a5) make current
		move.l		a3,ImageAddress(a5)

		bsr		MakeMask		for image

		bsr		PrintStats

.done		PULLALL
		rts

;--------------
;--------------	Load a previously saved image data file
;--------------

LoadBank	PUSHALL

; Obtain name of data file to create

		move.l		LoadBkReq(a5),a1	a1-> request struct
		lea		ImTextBuff(a5),a2	a2-> filename buffer
		move.b		#0,(a2)			clear file name
		lea		LoadBkTitle,a3		Requester Title
		lea		LoadTags,a0		tags
		CALLREQ		rtFileRequestA		display requester
		tst.l		d0			cancel selected?
		beq		.done			exit on error

; Change directory to where user wants to save data file

		move.l		LoadBkReq(a5),a0	a0-> request struct
		move.l		rtfi_Dir(a0),d1		d1=addr of dir name
		moveq.l		#ACCESS_READ,d2		d2=access mode
		CALLDOS		Lock
		move.l		d0,d6
		beq		.done
		
		move.l		d6,d1
		CALLSYS		CurrentDir		change directories
		move.l		d0,d6

; Open the file as an old file

		lea		ImTextBuff(a5),a0	filename
		move.l		a0,d1
		move.l		#MODE_OLDFILE,d2	access mode
		CALLSYS		Open
		move.l		d0,d7
		bne.s		.FileOpen

		lea		FileError1Msg,a0
		jsr		OkayReq
		bra		.error

; Read header for next image

.FileOpen	lea		ImageHeader(a5),a4

.LoadLoop	move.l		a4,d2			read buffer
		move.l		#gfx_SizeOf,d3		size of header
		move.l		d7,d1			handle
		CALLSYS		Read			read header

		tst.l		d0
		beq		.AllRead

; Determine size of raw data for this image and get memory for it

		moveq.l		#0,d0			clear
		move.l		d0,d1
		move.w		gfx_Width(a4),d0	width
		mulu		gfx_Height(a4),d0	width x height
		move.w		gfx_Depth(a4),d1	depth
		addq.w		#1,d1			depth + 1
		mulu		d1,d0			WxHx(D+1)
		
		add.l		#gfx_SizeOf,d0		add size of header
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1 type of mem
		CALLEXEC	AllocMem
		tst.l		d0			all ok
		bne.s		.GotMem			skip if so
		
		lea		NoMemMsg,a0		error message
		bsr		OkayReq	
		bra		.AllRead		and exit

; Copy raw data into allocated memory

.GotMem		move.l		d0,a3			a3->node
		moveq.l		#0,d0
		
		move.w		gfx_Depth(a4),gfx_Depth(a3)
		move.w		gfx_Width(a4),gfx_Width(a3) width
		move.w		gfx_Height(a4),gfx_Height(a3)	 height

		lea		gfx_Data(a3),a0
		move.l		a0,d2			Buffer
		move.w		gfx_Depth(a3),d3
		addq.w		#1,d3
		mulu		gfx_Width(a3),d3
		mulu		gfx_Height(a3),d3	size of gfx
		move.l		d7,d1			handle
		CALLDOS		Read

; Add this node to end of list and bump node counter

		lea		ImageList(a5),a0	List Header
		move.l		a3,a1			Node
		ADDTAIL					link 'em

		addq.w		#1,ImageCount(a5)	bump counter
		move.w		ImageCount(a5),CurrentImage(a5) make current
		move.l		a3,ImageAddress(a5)

		bsr		PrintStats

		bra		.LoadLoop		for all images

; All images read in, so close the file

.AllRead	bsr		PrintLoadName

		move.l		d7,d1
		CALLDOS		Close			close the file

; Back to original directory

.error		move.l		d6,d1
		CALLDOS		CurrentDir

		move.l		d0,d1
		CALLSYS		UnLock

; And exit

.done		PULLALL
		rts


;--------------
;--------------	Build a mask for loaded image by ORing all planes together
;--------------

; Entry		none, except ImageAddress(a5) must be set!

; Exit		none

; Corrupt	none

MakeMask	PUSH		d0-d3/a0-a2

		move.l		ImageAddress(a5),a2

		moveq.l		#0,d0
		moveq.l		#0,d1
		
		lea		gfx_Width(a2),a2	a2->width
		move.w		(a2)+,d0
		mulu		(a2)+,d0		d0=plane size
		move.l		d0,d2
		move.w		(a2)+,d1		depth
		mulu		d1,d2

		move.l		a2,a0
		add.l		d2,a0			a0->mask
		move.l		a0,a1
		asr.w		#1,d0			bytes to words

.loop		move.l		a1,a0
		move.w		d0,d2
		subq.w		#1,d2			dbcc adjust
		
.Inner		move.w		(a2)+,d3
		or.w		d3,(a0)+
		dbra		d2,.Inner

		subq.w		#1,d1
		bne.s		.loop

.error		PULL		d0-d3/a0-a2
		
		rts


;--------------
;--------------	Remove image from list
;--------------

; Entry		None, uses ImageAddress(a5)

; Exit		None

; Corrupt	d0

RemoveImage	PUSHALL

		tst.l		ImageAddress(a5)
		bne.s		.Remove

		lea		NoImageMsg,a0
		bsr		OkayReq
		bra.s		.done

; remove from list

.Remove		move.l		ImageAddress(a5),a4
		move.l		a4,a1
		REMOVE

; Free memory for this image

		moveq.l		#0,d0
		move.w		gfx_Width(a4),d0
		mulu		gfx_Height(a4),d0
		move.w		gfx_Depth(a4),d1
		addq.w		#1,d1			allow for mask
		mulu		d1,d0
		add.l		#gfx_SizeOf,d0
		move.l		a4,a1
		CALLEXEC	FreeMem

; Correct Image Count

		subq.w		#1,ImageCount(a5)

.done		PULLALL
		rts

;--------------
;--------------	Free memory occupied by all loaded images
;--------------

FreeImages	PUSHALL

		lea		ImageList(a5),a4	a4->list head

.loop		TSTLIST		a4
		beq.s		.done
		
		move.l		(a4),ImageAddress(a5)	set next image
		bsr		RemoveImage

		bra.s		.loop

.done		PULLALL
		rts

;--------------
;--------------	Save loaded images to a single binary file
;--------------

; Entry, Exit, Corrupt	None!


SaveBank	PUSHALL

; Obtain name of data file to create

		move.l		SaveBkReq(a5),a1	a1-> request struct
		lea		ImTextBuff(a5),a2	a2-> filename buffer
		move.b		#0,(a2)			clear file name
		lea		SaveBkTitle,a3		Requester Title
		lea		SaveTags,a0		tags
		CALLREQ		rtFileRequestA		display requester
		tst.l		d0			cancel selected?
		beq		.done			exit on error

; Change directory to where user wants to save data file

		move.l		SaveBkReq(a5),a0	a0-> request struct
		move.l		rtfi_Dir(a0),d1		d1=addr of dir name
		moveq.l		#ACCESS_READ,d2		d2=access mode
		CALLDOS		Lock
		move.l		d0,d6
		beq		.done
		
		move.l		d6,d1
		CALLSYS		CurrentDir		change directories
		move.l		d0,d6

; Open the file as a new file

		lea		ImTextBuff(a5),a0	filename
		move.l		a0,d1
		move.l		#MODE_NEWFILE,d2	access mode
		CALLSYS		Open
		move.l		d0,d7
		bne.s		.FileOpen

		lea		FileError1Msg,a0
		jsr		OkayReq
		bra.s		.error

; Locate start of image list

.FileOpen	lea		ImageList(a5),a4	a4->list head

; Fetch next image, exit it at tail of list

.loop		move.l		(a4),a4			next node
		tst.l		(a4)			is it the tail?
		bne.s		.SaveIt			no, save it!

	; File saved, clear not-saved flag and exit loop
	
		move.w		#0,SaveFlag(a5)		clear flag

		bsr		PrintSaveName		inform user

		bra.s		.AllSaved		and exit

; Write this image to disk

.SaveIt		moveq.l		#0,d3			clear
		move.l		d3,d0
		move.w		gfx_Width(a4),d3	width
		mulu		gfx_Height(a4),d3	width*height
		move.w		gfx_Depth(a4),d0	
		add.w		#1,d0
		mulu		d0,d3			WxHx(D+1)
		add.l		#gfx_SizeOf,d3		size of image data

		move.l		a4,d2			addr of image
		move.l		d7,d1			handle of file
		CALLSYS		Write

		cmp.l		d0,d3			count correct?
		beq.s		.loop

		lea		WriteErrMsg,a0
		bsr		OkayReq

; Close the file

.AllSaved	move.l		d7,d1
		CALLDOS		Close

; Back to original directory

.error		move.l		d6,d1
		CALLSYS		CurrentDir

		move.l		d0,d1
		CALLSYS		UnLock

; And exit

.done		PULLALL
		rts

*****************************************************************************
*			Routines To Deal With IntuiMessages		    *
*****************************************************************************

;--------------
;--------------	Default subroutine used during development
;--------------

DoDebug		PUSHALL

		lea		NoSubMsg,a0
		bsr		OkayReq

		PULLALL
		rts

;--------------
;--------------	Respond to About gadget
;--------------

DoAbout		PUSHALL

		lea		AboutMsg,a0
		bsr		OkayReq

		PULLALL
		rts

;--------------
;--------------	Respond to close window gadget
;--------------

DoQuit		move.l		#CLOSEWINDOW,d2
		rts

;--------------
;--------------	Load an IFF ILBM Brush
;--------------

; Entry		none

; Exit		File loaded, image added & stats display updated on success
;		Error requester on failure.

; Corrupt	d0

LoadImage	PUSH		d1-d7/a0-a6

; Obtain name of file to load

		move.l		LoadImReq(a5),a1	a1-> request struct
		lea		ImTextBuff(a5),a2	a2-> filename buffer
		move.b		#0,(a2)			clear file name
		lea		LoadImTitle,a3		Requester Title
		lea		LoadTags,a0		tags
		CALLREQ		rtFileRequestA		display requester
		tst.l		d0			cancel selected?
		beq		.done			exit on error

		move.l		#0,BrushPtr(a5)		Clear pointer

; Change directory to that containing the file to load

		move.l		LoadImReq(a5),a0	a0-> request struct
		move.l		rtfi_Dir(a0),d1		d1=addr of dir name
		moveq.l		#ACCESS_READ,d2		d2=access mode
		CALLDOS		Lock
		move.l		d0,d7
		beq.s		.done
		
		move.l		d7,d1
		CALLSYS		CurrentDir		change directories
		move.l		d0,d7
		
; Load the file

		lea		ImTextBuff(a5),a0	filename
		move.l		a0,d1
		move.l		#MODE_OLDFILE,d2	access mode
		CALLSYS		Open			open the file
		move.l		d0,d6			d6=file handle
		bne.s		.FileOpen

		lea		FileError1Msg,a0
		jsr		OkayReq
		bra.s		.error

.FileOpen	moveq.l		#ILBMCONTIGUOUS,d1	load prefs
		jsr		LoadILBM
		move.l		d0,BrushPtr(a5)
		beq.s		.IffFailure

		bsr		AddImage
		bra.s		.IffLoaded		

.IffFailure	lea		FileError1Msg,a0
		jsr		OkayReq

; Close The IFF ILBM file

.IffLoaded	move.l		d6,d1
		CALLDOS		Close

; Back to original directory

.error		move.l		d7,d1
		CALLDOS		CurrentDir		restore CD

		move.l		d0,d1
		CALLDOS		UnLock			release Lock on Dir

		move.w		#1,SaveFlag(a5)

; All done so exit

.done		PULL		d1-d7/a0-a6
		rts


GetImNum
EditMask
DeleteImage
		bsr		DoDebug
		rts

;--------------
;--------------	Display an approximation of current image
;--------------

ShowImage	PUSHALL

; Set IDCMP monitoring to a useless value to stop interfering

		move.l		#NEWSIZE,d0		impossible flags
		move.l		win.ptr(a5),a0		Window
		CALLINT		ModifyIDCMP

; Now open the show window

		lea		ShowWindow,a0
		CALLSYS		OpenWindow
		move.l		d0,d7
		beq.s		.error

		move.l		d7,a4
		move.l		wd_RPort(a4),d6		RastPort
		move.l		wd_UserPort(a4),d5	UserPort

; Initialise and display the gfx

		move.l		ImageAddress(a5),a0
		lea		GeneralImage,a1
		move.w		gfx_Width(a0),d0
		asl.w		#3,d0			x8 = pixels
		move.w		d0,ig_Width(a1)
		move.w		gfx_Height(a0),ig_Height(a1)
		lea		gfx_Data(a0),a0
		move.l		a0,ig_ImageData(a1)
		move.l		d6,a0
		moveq.l		#15,d0
		moveq.l		#15,d1
		CALLSYS		DrawImage

; Wait for close gadget

.WaitForMsg	move.l		d5,a0			a0->user port
		CALLEXEC	WaitPort		wait for message
		move.l		d5,a0			a0->user port
		CALLSYS		GetMsg			get any messages
		tst.l		d0			was there a message ?
		beq.s		.WaitForMsg		if not loop back
		move.l		d0,a1			a1-->message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		CALLSYS		ReplyMsg		answer os

		cmp.l		#CLOSEWINDOW,d2  	window closed ?
		bne.s		.WaitForMsg	 	if not then jump

; close the window

		move.l		d7,a0
		CALLINT		CloseWindow

; Reset main window IDCMP flags

.error		move.l		#CLOSEWINDOW!GADGETUP,d0 Proper flags
		move.l		win.ptr(a5),a0		Window
		CALLINT		ModifyIDCMP
		
		PULLALL
		rts		

NextImage	PUSHALL

		move.l		ImageAddress(a5),a4
		move.l		(a4),a4
		tst.l		(a4)
		bne.s		.StepOn
		
		lea		LastImageMsg,a0
		bsr		OkayReq
		bra		.done
		
.StepOn		move.l		a4,ImageAddress(a5)
		addq.w		#1,CurrentImage(a5)

		bsr		PrintStats

.done		PULLALL
		rts

PrevImage	PUSHALL

		move.l		ImageAddress(a5),a4
		tst.l		4(a4)
		beq.s		.error
		
		move.l		4(a4),a4
		tst.l		4(a4)
		beq.s		.error
		
		move.l		a4,ImageAddress(a5)
		subq.w		#1,CurrentImage(a5)
		
		bsr		PrintStats
		
		bra.s		.done

.error		lea		FirstImageMsg,a0
		bsr		OkayReq

.done		PULLALL
		rts
		

*****************************************************************************
*			String Data Section					    *
*****************************************************************************

; Program revision details. Can be viewed using 'version' command.

		dc.b		'$VER: BankBuilder v'
		REVISION
		dc.b		', © M.Meany ('
		REVDATE
		dc.b		')',0
		even

; Library names

dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even
gfxname		dc.b		'graphics.library',0
		even
reqname		dc.b		'reqtools.library',0
		even

; Error and About Requester Messages

AboutMsg	dc.b		'   BankMaker, © M,Meany 1993.   ',$0a
		dc.b		'   ~~~~~~~~~~~~~~~~~~~~~~~~~~   ',$0a
		dc.b		' Combines  multiple  IFF brushes',$0a
		dc.b		'and creates a single binary file',$0a
		dc.b		'for  use  as a list  of  Blitter',$0a
		dc.b		'Object Images in a game or demo.',$0a,$0a
		dc.b		'     Uses reqtools.library,     ',$0a
		dc.b		'        © Nico Francois.        ',$0a,0
		even

QuitMsg		dc.b		'    File not saved',$0a
		dc.b		'Sure you want to quit?',0
		even

FileError1Msg	dc.b		'Failed to load required file',0
		even

NoMemMsg	dc.b		'Not enough memory to preform',$0a
		dc.b		'         Operation!         ',0
		even

NoImageMsg	dc.b		'No Image loaded yet!',0
		even

NoBrushMsg	dc.b		'No brush loaded.',0
		even

NoSubMsg	dc.b		'This feature not yet implemeented!',0
		even

WriteErrMsg	dc.b		'Error writing data to file',$0a
		dc.b		'         Aborting!        ',$0a,0
		even

FirstImageMsg	dc.b		'This is first image!',0
		even

LastImageMsg	dc.b		'This is last image!',0
		even

; Templates for printed statistics

CountStat	dc.b		'Image ( %03d Loaded )',0
		even

CurrStat	dc.b		'Number  %3d',0
		even

WidthStat	dc.b		'Width   %3d bytes',0			73,60
		even

HeightStat	dc.b		'Height  %3d lines.',0			14,86
		even

DepthStat	dc.b		'Depth   %1d planes.',0			14,98
		even

SizeStat	dc.b		'Total Bytes Occupied: %6ld bytes.',0	14,110
		even

SaveStat	dc.b		"%-25s",0
		even

; Requester Messages

LoadImTitle	dc.b		'Load IFF Image',0
		even

LoadBkTitle	dc.b		'Load Image Bank',0
		even

SaveBkTitle	dc.b		'Save Image Bank',0
		even

; Requester tags

LoadTags	dc.l		RT_ReqPos,REQPOS_CENTERSCR	centralise
		dc.l		TAG_DONE

SaveTags	dc.l		RT_ReqPos,REQPOS_CENTERSCR	centralise
		dc.l		RTFI_Flags,FREQF_SAVE+FREQF_PATGAD
		dc.l		TAG_DONE

; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		'This program © M.Meany, Amiganuts.'
		dc.b		$0a
		dc.b		'See Doc file for more information!'
		dc.b		$0a
		dc.b		'Uses reqtools.library, © Nico Francois.'
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

BrushPtr	rs.l		1		->custom struct of loaded IFF

win.ptr		rs.l		1
win.rp		rs.l		1
win.up		rs.l		1

LoadImReq	rs.l		1		for LoadFile Requester
LoadBkReq	rs.l		1		for LoadFile Requester
SaveBkReq	rs.l		1		for SaveFile Requester

SaveFlag	rs.w		1		set when alteration made

ImageCount	rs.w		1		number of images
CurrentImage	rs.w		1		current Image number
ImageAddress	rs.l		1		pointer to current Image node
ImageList	rs.b		MLH_SIZE	Image list header

ImTextBuff	rs.b		90		space for name of IFF brush

STD_OUT		rs.l		1

ImageHeader	rs.b		gfx_Data	bytes for header

DStream		rs.w		8		data values & pointers

BuiltText	rs.b		100		for generated text

varsize		rs.b		0

		SECTION	Vars,BSS

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1
_ReqToolsBase	ds.l		1

Variables	ds.b		varsize

;		section		Skeleton,code

***** Your code goes here!!!

;--------------
;--------------	Include code to load an IFF ILBM file into memory
;--------------

		include		ilbm.code.s

