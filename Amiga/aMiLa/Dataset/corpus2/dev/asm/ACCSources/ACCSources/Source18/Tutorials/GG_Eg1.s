
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

***************	Subroutine that returns the length of a file in bytes.

; Entry		a0 = address of file name

; Exit		d0 = length of file in bytes or 0 if any error occurred

; Corrupted	a0

;-------------- Save register values

FileLen		movem.l		d1-d4/a1-a4,-(sp)

;-------------- Save address of filename and clear file length

		move.l		a0,RFfile_name
		move.l		#0,RFfile_len

;-------------- Allocate some memory for the File Info block

		move.l		#fib_SIZEOF,d0
		move.l		#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l		d0,RFfile_info
		beq		.error1
		
;-------------- Lock the file
		
		move.l		RFfile_name,d1
		move.l		#ACCESS_READ,d2
		CALLDOS		Lock
		move.l		d0,RFfile_lock
		beq		.error2

;-------------- Use Examine to load the File Info block

		move.l		d0,d1
		move.l		RFfile_info,d2
		CALLSYS		Examine

;-------------- Copy the length of the file into RFfile_len

		move.l		RFfile_info,a0
		move.l		fib_Size(a0),RFfile_len

;-------------- Release the file

		move.l		RFfile_lock,d1
		CALLSYS		UnLock

;-------------- Release allocated memory

.error2		move.l		RFfile_info,a1
		move.l		#fib_SIZEOF,d0
		CALLEXEC	FreeMem


;-------------- All done so return

.error1		move.l		RFfile_len,d0
		movem.l		(sp)+,d1-d4/a1-a4
		rts

***************	Routine to display custom 'sleeping' pointer

PointerOn	movem.l		d0-d3/a0-a2,-(sp) save registers
		move.l		window.ptr,a0	a0->Window struct
		lea		newptr,a1	a1->sleepy pointer
		moveq.l		#16,d0		16 lines high
		move.l		d0,d1		16 pixels wide
		moveq.l		#0,d2		hit point X=0
		move.l		d2,d3		hit point Y=0
		CALLINT		SetPointer	turn it on
		movem.l		(sp)+,d0-d3/a0-a2 restore registers
		rts				and return

***************	Routine to display default Intuition pointer

PointerOff	movem.l		d0-d2/a0-a2,-(sp) save registers
		move.l		window.ptr,a0	a0->Window struct
		CALLINT		ClearPointer	reset std pointer
		movem.l		(sp)+,d0-d2/a0-a2 restore registers
		rts				and return

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


***************	Subroutine to search a block of memory for a given string.

; Entry		a0 addr of string to search for
;		d0 length of string
;		a1 addr of memory block
;		d1 length of memory block

; Exit		d0 addr of first occurence of string, 0 if no match found

; Corrupted	d0

Find		movem.l		d1-d2/a0-a2,-(sp) save values
		move.l		#0,_MatchFlag	clear flag, assume failure
		sub.l		d0,d1		set up counter
		subq.l		#1,d1		correct for dbra
		bmi.s		.FindError	quit if block < string

		move.b		(a0),d2		d2=1st char to match
.Floop		cmp.b		(a1)+,d2	match 1st char of string ?
		dbeq		d1,.Floop	no+not end, loop back

		bne.s		.FindError	if no match+end then quit

		bsr.s		.CompStr	else check rest of string

		beq.s		.Floop		loop back if no match

.FindError	movem.l		(sp)+,d1-d2/a0-a2 retrieve values
		move.l		_MatchFlag,d0	set d0 for return
		rts

.CompStr	movem.l		d0/a0-a2,-(sp)

		subq.l		#1,d0		correct for dbra
		move.l		a1,a2		save a copy
		subq.l		#1,a1		correct as it was bumped
.FFloop		cmp.b		(a0)+,(a1)+	compare string elements
		dbne		d0,.FFloop	while not end + not match

		bne.s		.ComprDone	no match so quit
		subq.l		#1,a2		correct this addr
		move.l		a2,_MatchFlag	save addr of match

.ComprDone	movem.l		(sp)+,d0/a0-a2
		tst.l		_MatchFlag	set Z flag as required
		rts

***************	Converts text string to upper case.

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
		dc.l		GADGETDOWN+GADGETUP+CLOSEWINDOW
		dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
		dc.l		QuitGadg	;gadgets
		dc.l		0
		dc.l		WindowName
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

WindowName	dc.b		' Test ',0
		even

QuitGadg	dc.l		0		next gadget
		dc.w		50,50		XY of hit box rel to TopLeft
		dc.w		95,19		hit box width and height
		dc.w		GADGIMAGE+GADGHIMAGE	gadget flags
		dc.w		RELVERIFY	activation flags
		dc.w		BOOLGADGET	gadget type flags
		dc.l		IM1		image to be rendered
		dc.l		IM2		alt imagery for selection
		dc.l		GadgTxt		* IntuiText structure
		dc.l		0		mutual-exclude long word
		dc.l		0		SpecialInfo structure
		dc.w		0		user-definable data
		dc.l		QuitSub		pointer to subroutine


GadgTxt		dc.b		1		FrontPen
		dc.b		0		BackPen
		dc.b		RP_JAM2		DrawMode
		dc.b		0		KludgeFill00
		dc.w		30		x position
		dc.w		6		y position
		dc.l		0		font
		dc.l		.Text		address of text to print
		dc.l		0		no more text

.Text		dc.b		'QUIT',0	the text itself
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

RFfile_name	ds.l		1
RFfile_lock	ds.l		1
RFfile_info	ds.l		1
RFfile_len	ds.l		1

STD_OUT		ds.l		1

_MatchFlag	ds.l		1

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

		section		Skeleton,code

QuitSub		move.l		#CLOSEWINDOW,D2	   simulate close window
		rts				   and return

IM1
		dc.w		0,0		; x,y 
		dc.w		95,19		; width,height
		dc.w		2		; depth
		dc.l		IM1Data		; Image def
		dc.b		3		; PlanePick
		dc.b		0		; PlaneOnOff
		dc.l		0		; no more images


IM2
		dc.w		0,0		; x,y 
		dc.w		95,19		; width,height
		dc.w		2		; depth
		dc.l		IM2Data		; Image def
		dc.b		3		; PlanePick
		dc.b		0		; PlaneOnOff
		dc.l		0		; no more images


		SECTION	im,DATA_C		; get CHIP mem

; Data For first plane of image now follows.

IM1Data
		dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFC,$8000,$0000
		dc.w	$0000,$0000,$0000,$0000,$8000,$0000,$0000,$0000
		dc.w	$0000,$0000,$8000,$0000,$0000,$0000,$0000,$0000
		dc.w	$8000,$0000,$0000,$0000,$0000,$0000,$8000,$0000
		dc.w	$0000,$0000,$0000,$0000,$8000,$0000,$0000,$0000
		dc.w	$0000,$0000,$8000,$0000,$0000,$0000,$0000,$0000
		dc.w	$8000,$0000,$0000,$0000,$0000,$0000,$8000,$0000
		dc.w	$0000,$0000,$0000,$0000,$8000,$0000,$0000,$0000
		dc.w	$0000,$0000,$8000,$0000,$0000,$0000,$0000,$0000
		dc.w	$8000,$0000,$0000,$0000,$0000,$0000,$8000,$0000
		dc.w	$0000,$0000,$0000,$0000,$8000,$0000,$0000,$0000
		dc.w	$0000,$0000,$8000,$0000,$0000,$0000,$0000,$0000
		dc.w	$8000,$0000,$0000,$0000,$0000,$0000,$8000,$0000
		dc.w	$0000,$0000,$0000,$0000,$8000,$0000,$0000,$0000
		dc.w	$0000,$0000

; Data for second plane of image now follows.

		dc.w	$0000,$0000,$0000,$0000,$0000,$0002,$0000,$0000
		dc.w	$0000,$0000,$0000,$0002,$0000,$0000,$0000,$0000
		dc.w	$0000,$0002,$0000,$0000,$0000,$0000,$0000,$0002
		dc.w	$0000,$0000,$0000,$0000,$0000,$0002,$0000,$0000
		dc.w	$0000,$0000,$0000,$0002,$0000,$0000,$0000,$0000
		dc.w	$0000,$0002,$0000,$0000,$0000,$0000,$0000,$0002
		dc.w	$0000,$0000,$0000,$0000,$0000,$0002,$0000,$0000
		dc.w	$0000,$0000,$0000,$0002,$0000,$0000,$0000,$0000
		dc.w	$0000,$0002,$0000,$0000,$0000,$0000,$0000,$0002
		dc.w	$0000,$0000,$0000,$0000,$0000,$0002,$0000,$0000
		dc.w	$0000,$0000,$0000,$0002,$0000,$0000,$0000,$0000
		dc.w	$0000,$0002,$0000,$0000,$0000,$0000,$0000,$0002
		dc.w	$0000,$0000,$0000,$0000,$0000,$0002,$0000,$0000
		dc.w	$0000,$0000,$0000,$0002,$7FFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFE


; Data For first plane of image now follows.

IM2Data
		dc.w	$0000,$0000,$0000,$0000,$0000,$0002,$0000,$0000
		dc.w	$0000,$0000,$0000,$0002,$0000,$0000,$0000,$0000
		dc.w	$0000,$0002,$0000,$0000,$0000,$0000,$0000,$0002
		dc.w	$0000,$0000,$0000,$0000,$0000,$0002,$0000,$0000
		dc.w	$0000,$0000,$0000,$0002,$0000,$0000,$0000,$0000
		dc.w	$0000,$0002,$0000,$0000,$0000,$0000,$0000,$0002
		dc.w	$0000,$0000,$0000,$0000,$0000,$0002,$0000,$0000
		dc.w	$0000,$0000,$0000,$0002,$0000,$0000,$0000,$0000
		dc.w	$0000,$0002,$0000,$0000,$0000,$0000,$0000,$0002
		dc.w	$0000,$0000,$0000,$0000,$0000,$0002,$0000,$0000
		dc.w	$0000,$0000,$0000,$0002,$0000,$0000,$0000,$0000
		dc.w	$0000,$0002,$0000,$0000,$0000,$0000,$0000,$0002
		dc.w	$0000,$0000,$0000,$0000,$0000,$0002,$0000,$0000
		dc.w	$0000,$0000,$0000,$0002,$7FFF,$FFFF,$FFFF,$FFFF
		dc.w	$FFFF,$FFFE

; Data for second plane of image now follows.

		dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFC,$8000,$0000
		dc.w	$0000,$0000,$0000,$0000,$8000,$0000,$0000,$0000
		dc.w	$0000,$0000,$8000,$0000,$0000,$0000,$0000,$0000
		dc.w	$8000,$0000,$0000,$0000,$0000,$0000,$8000,$0000
		dc.w	$0000,$0000,$0000,$0000,$8000,$0000,$0000,$0000
		dc.w	$0000,$0000,$8000,$0000,$0000,$0000,$0000,$0000
		dc.w	$8000,$0000,$0000,$0000,$0000,$0000,$8000,$0000
		dc.w	$0000,$0000,$0000,$0000,$8000,$0000,$0000,$0000
		dc.w	$0000,$0000,$8000,$0000,$0000,$0000,$0000,$0000
		dc.w	$8000,$0000,$0000,$0000,$0000,$0000,$8000,$0000
		dc.w	$0000,$0000,$0000,$0000,$8000,$0000,$0000,$0000
		dc.w	$0000,$0000,$8000,$0000,$0000,$0000,$0000,$0000
		dc.w	$8000,$0000,$0000,$0000,$0000,$0000,$8000,$0000
		dc.w	$0000,$0000,$0000,$0000,$8000,$0000,$0000,$0000
		dc.w	$0000,$0000


