
*****	Title		LibHelp.s
*****	Function	To give details on a specified library function.
*****	Size		26300 bytes
*****	Author		Mark Meany
*****	Assembler	Devpac3 ( Workbench 2.0 version )
*****	Date Started	1st Jan 91
*****	This Revision	18th Jan	Added Layers library functions
*****			2nd Jan 91	Tidied source + added comments
*****	Notes		Data obtained from v2.0 .fd files
*****			Supports the following libraries:
*****			dos
*****			exec
*****			intuition
*****			graphics
*****			asl
*****			commodities
*****			gadtools
*****			iffparse
*****			rexxsyslib
*****			utility
*****			wb
*****			layers

*---------------------------------------------------
* Gadgets created with PowerSource V3.0
* which is (c) Copyright 1990-91 by Jaba Development
* written by Jan van den Baard
*---------------------------------------------------

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

; This is a general startup module I use for most Intuition utils.

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"

		move.l		a0,_args	save addr of CLI args
		move.l		d0,_argslen	and the length

		bsr.s		Openlibs	open libraries
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

		bsr.s		Init		Initialise data
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

.ok		bsr		SetLibPtrs	init look-up tables
		moveq.l		#1,d0		no errors

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

;--------------	Display text

		move.l		window.rp,a0	a0->windows RastPort
		lea		DisplayText0,a1	a1->IText structure
		moveq.l		#0,d0		X offset
		moveq.l		#0,d1		Y offset
		CALLINT		PrintIText	print this text

;--------------	Activate the string gadget

		lea		FunctionGadg,a0	a0->gadget
		move.l		window.ptr,a1	a1->window
		suba.l		a2,a2		not a requester
		CALLSYS		ActivateGadget	turn it on !!
		
		moveq.l		#1,d0		no errors

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
		beq.s		.test_active
		move.l		gg_UserData(a5),a0
		cmpa.l		#0,a0
		beq.s		.test_active
		jsr		(a0)

.test_active	cmp.l		#ACTIVEWINDOW,d2 activated ?
		bne.s		.test_win
		
		lea		FunctionGadg,a0	a0->gadget
		move.l		window.ptr,a1	a1->window
		suba.l		a2,a2		not a requester
		CALLINT		ActivateGadget	turn it on !!
		
		moveq.l		#0,d2		no errors
		bra.s		WaitForMsg	loop
		
.test_win	cmp.l		#CLOSEWINDOW,d2  window closed ?
		bne.s		WaitForMsg	 if not then jump
		rts


*************** Close the Intuition window.

Closewin	move.l		window.ptr,d0	d0->window struct
		beq.s		.error
		move.l		d0,a0		a0->Window struct
		CALLINT		CloseWindow	and close it
.error		rts

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
		beq.s		.error		quit if not one

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

***************	This subroutine sets d2 so program will finish

Quit		move.l		#CLOSEWINDOW,d2
		rts

***************	This subroutine sends LibHelp to sleep. It opens a small
;		window and waits for MOUSEBUTTONS - MENUDOWN message.

Sleep		bsr		Closewin		close main window

		lea		SleepWindow,a0		a0->sleeping win
		CALLINT		OpenWindow		open it
		move.l		d0,window.ptr		save pointer
		beq.s		Quit			quit if error

		move.l		d0,a0			a0->window struct
		move.l		wd_UserPort(a0),window.up
		
Awaken		move.l		window.up,a0	a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		window.up,a0	a0-->window pointer
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		Awaken		if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.w		im_Code(a1),d3	d3=event code
		move.l		im_IAddress(a1),a5 a5=addr of structure
		CALLSYS		ReplyMsg	answer os or it get angry

		cmp.l		#MOUSEBUTTONS,d2 was this a button msg?
		bne.s		.test_win
		cmp.w		#MENUDOWN,d3	RMB pressed ?
		bne.s		.test_win	if not check close gadget
		
		bsr		Closewin	close sleep window
		
		bsr		Openwin		open main window
		tst.l		d0		check for errors
		beq.s		.error		quit if found
		
		moveq.l		#0,d2		dont quit,
		rts				return!
		
.error		move.l		#CLOSEWINDOW,d2	 give up!

.test_win	cmp.l		#CLOSEWINDOW,d2  window closed ?
		bne.s		Awaken		 if not then jump
		rts

***************	This is what it's all about! The routine to find information
;		on a given function. The search routine is not case
;		sensitive. Note the data was obtained from .fd files and so
;		should be correct!

FindFunction	bsr		PointerOn		custom pointer

		lea		ReqFunct,a0		a0->search string
		lea		1(a0),a1		a1->user input
		moveq.l		#0,d0

.loop		addq.l		#1,d0			determine length of
		tst.b		(a1)+			search string
		bne.s		.loop

; a0-> string, d0=string length

		lea		DataBuffer,a1		a1->info
		move.l		#DBSize,d1		d1=info size
		bsr.s		Find			search for info
		tst.l		d0			found?
		bne.s		.ok			if so skip

.error1		move.l		#NotFound-1,d0		set error msg
			
.ok		addq.l		#1,d0			bump past 0 byte
		bsr		GetLibName		find library name
		move.l		a0,Sol			write lib name addr
		bsr		SplitEntry		build output text

		move.l		window.rp,a0		a0->windows RastPort
		lea		RT1,a1			a1->IText structure
		moveq.l		#0,d0			X offset
		moveq.l		#0,d1			Y offset
		CALLINT		PrintIText		print this text
		
		move.b		#0,Functionbuf		clear entry gadget
		
		lea		FunctionGadg,a0		a0->gadget
		move.l		window.ptr,a1		a1->window
		suba.l		a2,a2			not a requester
		CALLSYS		ActivateGadget		turn it on !!

.error		moveq.l		#0,d2			dont quit
		bsr		PointerOff		normal pointer
		rts					return

***************	Subroutine to search a block of memory for a given string.

; Now case insensative !!!!

; Entry		a0 addr of string to search for
;		d0 length of string
;		a1 addr of memory block
;		d1 length of memory block

; Exit		d0 addr of first occurence of string, 0 if no match found

; Corrupted	d0

Find		movem.l		d1-d2/a0-a2,-(sp) save values

		bsr.s		ucase		convert string to upper

		move.l		#0,_MatchFlag	clear flag, assume failure
		sub.l		d0,d1		set up counter
		subq.l		#1,d1		correct for dbra
		bmi.s		.FindError	quit if block < string

		move.b		(a0),d2		d2=1st char to match
		move.b		d2,d3		make a copy
		add.b		#'a'-'A',d3	in lowercase
.Floop		cmp.b		(a1)+,d2	match 1st char of string ?
		beq.s		.Floopend
		cmp.b		-1(a1),d3	with upper or lower
.Floopend	dbeq		d1,.Floop	no+not end, loop back

		bne.s		.FindError	if no match+end then quit

		bsr.s		.CompStr	else check rest of string

		beq.s		.Floop		loop back if no match

.FindError	movem.l		(sp)+,d1-d2/a0-a2 retrieve values
		move.l		_MatchFlag,d0	set d0 for return
		rts

.CompStr	movem.l		d0-d1/a0-a2,-(sp)

		subq.l		#1,d0		correct for dbra
		move.l		a1,a2		save a copy
		subq.l		#1,a1		correct as it was bumped
.FFloop		move.b		(a1)+,d1
		cmp.b		#'a',d1
		blt.s		.fok
		cmp.b		#'z',d1
		bgt.s		.fok
		sub.b		#('a'-'A'),d1
.fok		cmp.b		(a0)+,d1	compare string elements
		dbne		d0,.FFloop	while not end + not match

		bne.s		.ComprDone	no match so quit
		subq.l		#1,a2		correct this addr
		move.l		a2,_MatchFlag	save addr of match

.ComprDone	movem.l		(sp)+,d0-d1/a0-a2
		tst.l		_MatchFlag	set Z flag as required
		rts

***************	Converts text string to upper case.

;Entry		a0->start of null terminated text string

;Exit		a0->end of text string ( the zero byte ).

;corrupted	None

ucase		move.l		a0,-(sp)

		lea		1(a0),a0		step over null

		tst.b		(a0)
		beq.s		.error
		
.loop		cmpi.b		#'a',(a0)+
		blt.s		.ok
		
		cmp.b		#'z',-1(a0)
		bgt.s		.ok
		
		subi.b		#$20,-1(a0)
		
.ok		tst.b		(a0)
		bne.s		.loop
		
.error		move.l		(sp)+,a0
		rts


***************	Sets up required tables for determaning library that a
;		function is in. Call only once.

; Corrupt	d0,d1,a0,a1,a3,a4

SetLibPtrs	lea		libstarts,a3		a3->func table
		lea		libptrs,a4		a4->addr table

		lea		DataBuffer,a1		a1->buffer
		move.l		#DBSize,d1		size of buffer

.loop		tst.l		(a3)			end of table ?
		beq.s		.done			if so quit
		
		move.l		(a3)+,a0		a0->entry
		move.l		(a0)+,d0		size of funct
		bsr		Find			find entry
		
		tst.l		d0			found entry?
		beq.s		.done			.error!!! Shit!
		
		move.l		d0,(a4)+		save pointer
		bra.s		.loop			do next
		
.done		rts
		

***************	Determines the name of library that contains a specified
;		function.

;Entry		d0=addr in buffer of entry

;Exit		a0->name of library or 'Unknown' if cant be determined.

;Corrupt	a0

GetLibName	move.l		a2,-(sp)		save
		move.l		a3,-(sp)

		lea		unknownlib,a0		default
		lea		libptrs,a2		a2->libs table
		lea		libnames,a3		a3->name table

.loop		tst.l		(a2)			end of table?
		beq.s		.done			if so quit
		
		cmp.l		(a2)+,d0		compare entry
		blt.s		.found			skip if found
		
		lea		4(a3),a3		point to next name
		bra.s		.loop			and loop back
		
.found		move.l		(a3),a0			a0->libname

.done		move.l		(sp)+,a3		retrieve
		move.l		(sp)+,a2
		rts

***************	Given the address of an entry in the buffer, this routine
;		builds the strings required for the display.

;Entry		d0->entry in buffer

;Corrupt	none

SplitEntry	movem.l		d0/a0-a1,-(sp)		save

		move.l		d0,a0			a0->entry

; First get the function name, terminated by a (

		lea		dispName,a1		destination

.nameloop	move.b		(a0)+,d0		get next char
		cmp.b		#'(',d0			end of name?
		beq.s		.donename		if so skip
		
		move.b		d0,(a1)+		else copy byte
		bra.s		.nameloop		and loop back
		
.donename	move.b		#0,(a1)			null terminate

; Now copy calling parameters, this may be an empty string

		lea		dispParam,a1		destination

.paramloop	move.b		(a0)+,d0		get next char
		cmp.b		#')',d0			end of parameters?
		beq.s		.doneparam		if so skip
		
		move.b		d0,(a1)+		else copy byte
		bra.s		.paramloop		and loop back
		
.doneparam	move.b		#0,(a1)			null terminate

; Next copy register data, if supplied.

		lea		dispReg,a1		destination

		cmp.b		#'(',(a0)+		end of entry?
		bne.s		.donereg		if so skip
		
.regloop	move.b		(a0)+,d0		get next char
		cmp.b		#')',d0			end of registers?
		beq.s		.donereg		if so skip
		
		move.b		d0,(a1)+		else copy byte
		bra.s		.regloop		and loop back
		
.donereg	move.b		#0,(a1)			null terminate
				
; All done so return

.done		movem.l		(sp)+,d0/a0-a1		restore
		rts

***************	Subroutine that displays About window and text

About		bsr		PointerOn		custom pointer

		lea		AboutWindow,a0		a0->sleeping win
		CALLINT		OpenWindow		open it
		move.l		d0,about.ptr		save pointer
		beq.s		.error			quit if error

		move.l		d0,a0			a0->window struct
		move.l		wd_UserPort(a0),about.up
		move.l		wd_RPort(a0),about.rp    ;save rp ptr

;--------------	Display About text

		move.l		about.rp,a0	a0->windows RastPort
		lea		AboutTexts0,a1	a1->IText structure
		moveq.l		#0,d0		X offset
		moveq.l		#0,d1		Y offset
		CALLINT		PrintIText	print this text

;--------------	The event loop revisited

.WaitAbout	move.l		about.up,a0	a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		about.up,a0	a0-->window pointer
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		.WaitAbout	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		CALLSYS		ReplyMsg	answer os or it get angry

		cmp.l		#CLOSEWINDOW,d2 window closed ?
		bne.s		.WaitAbout	if not then jump

		move.l		about.ptr,a0	a0->window struct
		CALLINT		CloseWindow	and close

.error		bsr.s		PointerOff	restore pointer
		moveq.l		#0,d2		dont quit
		rts				and return

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


;***********************************************************
;		Lookup tables and other subroutine data
;***********************************************************

unknownlib	dc.b		'Unknown library ... Data error!',0
		even

;--------------	The following tables are for determining the library a
;		particular function is in. This method has been adopted
;		to allow easy upgrades/additions when necessary. No need
;		to alter the code, just add a few entries below.

; A table of pointers to the first function in each supported library

libstarts	dc.l		dstart
		dc.l		estart
		dc.l		gstart
		dc.l		istart
		dc.l		astart
		dc.l		cstart
		dc.l		gastart
		dc.l		ifstart
		dc.l		rstart
		dc.l		ustart
		dc.l		wstart
		dc.l		lstart
		dc.l		0		end of entries

; The names of the first function in each library. Determine these by
;examaning the .fd file prior to addittion.

dstart		dc.l		6			 bytes
		dc.b		0,'Open('
		even
estart		dc.l		12
		dc.b		0,'Supervisor('
		even
gstart		dc.l		11
		dc.b		0,'BltBitMap('
		even
istart		dc.l		15
		dc.b		0,'OpenIntuition('
		even
astart		dc.l		18
		dc.b		0,'AllocFileRequest('
		even
cstart		dc.l		13
		dc.b		0,'CreateCxObj('
		even
gastart		dc.l		15
		dc.b		0,'CreateGadgetA('
		even
ifstart		dc.l		10
		dc.b		0,'AllocIff('
		even
rstart		dc.l		17
		dc.b		0,'CreateArgstring('
		even
ustart		dc.l		13
		dc.b		0,'FindTagItem('
		even
wstart		dc.l		17
		dc.b		0,'UpdateWorkbench('
		even
lstart		dc.l		12
		dc.b		0,'InitLayers('
		even

; A table of pointers into the information buffer. These point to the
;start of info for each of the supported libs in the buffer
		
libptrs		dc.l		0		start of DOS entries
		dc.l		0		start of Exec entries
		dc.l		0		start of Graf entries
		dc.l		0		start of Int entries
		dc.l		0		asl
		dc.l		0		commodities
		dc.l		0		gadtools
		dc.l		0		iffparse
		dc.l		0		rexxsys
		dc.l		0		utility
		dc.l		0		wb
		dc.l		0		layers
		dc.l		BufEnd		end of info buffer
		dc.l		0		end of table.

; A table of assosiated library names that corelates to the above table

libnames	dc.l		unknownlib
		dc.l		dname
		dc.l		ename
		dc.l		gname
		dc.l		iname
		dc.l		aname
		dc.l		cname
		dc.l		ganame
		dc.l		ifname
		dc.l		rname
		dc.l		uname
		dc.l		wname
		dc.l		lname
		dc.l		unknownlib	just in case!
		
; The names of all supported libraries in order of occurence in the info
;buffer

dname		dc.b		'dos.library',0
		even
ename		dc.b		'exec.library',0
		even
gname		dc.b		'graphics.library',0
		even
iname		dc.b		'intuition.library',0
		even
aname		dc.b		'asl.library',0
		even
cname		dc.b		'commodities.library',0
		even
ganame		dc.b		'gadtools.library',0
		even
ifname		dc.b		'iffparse.library',0
		even
rname		dc.b		'rexxsys.library',0
		even
uname		dc.b		'utility.library',0
		even
wname		dc.b		'wb.library',0
		even
lname		dc.b		'layers.library',0
		even

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
		dc.b		'LibHelp, © M.Meany Jan 1992.'
		dc.b		$0a
		dc.b		'A utility that outlines library functions.'
		dc.b		$0a
		dc.b		0
		even

;***********************************************************
;	Window and Gadget defenitions
;***********************************************************

***************	User input buffer for string gadget

ReqFunct	dc.b	0
Functionbuf:
	DCB.B   30
	EVEN	

***************	Main window + gadgets + IText structures

; These ITexts display information for a function once found

RT1
	DC.B	1,0
	DC.B	RP_JAM2
	DC.W	140,16
	DC.L	0
	DC.L	RTIText1
	DC.L	RT2

RT2
	DC.B	1,0
	DC.B	RP_JAM2
	DC.W	140,16
	DC.L	0
	DC.L	dispName			ptr to function name
	DC.L	RT3

RT3
	DC.B	1,0
	DC.B	RP_JAM2
	DC.W	140,27
	DC.L	0
	DC.L	RTIText1
	DC.L	RT4

RT4
	DC.B	1,0
	DC.B	RP_JAM2
	DC.W	140,27
	DC.L	0
Sol	DC.L	0				ptr to lib name
	DC.L	RT5

RT5
	DC.B	1,0
	DC.B	RP_JAM2
	DC.W	140,38
	DC.L	0
	DC.L	RTIText1
	DC.L	RT6

RT6
	DC.B	1,0
	DC.B	RP_JAM2
	DC.W	140,38
	DC.L	0
	DC.L	dispParam			ptr to functio prototype
	DC.L	RT7

RT7
	DC.B	1,0
	DC.B	RP_JAM2
	DC.W	140,49
	DC.L	0
	DC.L	RTIText1
	DC.L	RT8

RT8
	DC.B	1,0
	DC.B	RP_JAM2
	DC.W	140,49
	DC.L	0
	DC.L	dispReg				ptr to registers
	DC.L	0

RTIText1:
	DC.B	'                                                              ',0				'd0',0
	EVEN	

NotFound	dc.b		'No Details Available, Sorry!()()',0
		even

SharedBordersPairs0:
    DC.W    -2,-1,-2,11,-1,11,-1,-1,224,-1
SharedBordersPairs1:
    DC.W    -1,11,224,11,224,0,225,-1,225,11
SharedBordersPairs2:
    DC.W    0,0,0,14,1,14,1,0,91,0
SharedBordersPairs3:
    DC.W    1,14,91,14,91,1,92,0,92,14
SharedBordersPairs4:
    DC.W    0,0,0,14,1,14,1,0,91,0
SharedBordersPairs5:
    DC.W    1,14,91,14,91,1,92,0,92,14

SharedBorders0:
    DC.W    0,-1
    DC.B    2,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs0,SharedBorders1

SharedBorders1:
    DC.W    0,-1
    DC.B    1,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs1,0

SharedBorders2:
    DC.W    0,-1
    DC.B    1,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs0,SharedBorders3

SharedBorders3:
    DC.W    0,-1
    DC.B    2,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs1,0

SharedBorders4:
    DC.W    0,0
    DC.B    2,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs2,SharedBorders5

SharedBorders5:
    DC.W    0,0
    DC.B    1,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs3,0

SharedBorders6:
    DC.W    0,0
    DC.B    1,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs2,SharedBorders7

SharedBorders7:
    DC.W    0,0
    DC.B    2,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs3,0

SharedBorders8:
    DC.W    0,0
    DC.B    2,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs4,SharedBorders9

SharedBorders9:
    DC.W    0,0
    DC.B    1,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs5,0

SharedBorders10:
    DC.W    0,0
    DC.B    1,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs4,SharedBorders11

SharedBorders11:
    DC.W    0,0
    DC.B    2,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs5,0

DisplayText0:
    DC.B    3,0
    DC.B    RP_JAM1+RP_COMPLEMENT
    DC.W    12,16
    DC.L    0
    DC.L    DisplayTextIText0
    DC.L    DisplayText1

DisplayTextIText0:
    DC.B    'Name       -->',0
    CNOP    0,2

DisplayText1
    DC.B    3,1
    DC.B    RP_JAM1
    DC.W    12,27
    DC.L    0
    DC.L    DisplayTextIText1
    DC.L    DisplayText2

DisplayTextIText1:
    DC.B    'In Library -->',0
    CNOP    0,2

DisplayText2
    DC.B    3,0
    DC.B    RP_JAM1
    DC.W    12,38
    DC.L    0
    DC.L    DisplayTextIText2
    DC.L    DisplayText3

DisplayTextIText2:
    DC.B    'Call With  -->',0
    CNOP    0,2

DisplayText3
    DC.B    3,0
    DC.B    RP_JAM1
    DC.W    12,49
    DC.L    0
    DC.L    DisplayTextIText3
    DC.L    DisplayText4

DisplayTextIText3:
    DC.B    'Registers  -->',0
    CNOP    0,2

DisplayText4
    DC.B    1,0
    DC.B    RP_JAM1
    DC.W    12,65
    DC.L    0
    DC.L    DisplayTextIText4
    DC.L    0

DisplayTextIText4:
    DC.B    'Search For -->',0
    CNOP    0,2

SleepGadg_text0:
    DC.B    1,0
    DC.B    RP_JAM1
    DC.W    24,3
    DC.L    0
    DC.L    SleepGadg_itext0
    DC.L    0

SleepGadg_itext0:
    DC.B    'Sleep',0
    CNOP    0,2

SleepGadg_ID   EQU     3

SleepGadg:
    DC.L    0
    DC.W    271,81
    DC.W    93,15
    DC.W    GADGHIMAGE
    DC.W    RELVERIFY
    DC.W    BOOLGADGET
    DC.L    SharedBorders8
    DC.L    SharedBorders10
    DC.L    SleepGadg_text0,0
    DC.L    0
    DC.W    SleepGadg_ID
    DC.L    Sleep

QuitGadg_text0:
    DC.B    1,0
    DC.B    RP_JAM1
    DC.W    30,4
    DC.L    0
    DC.L    QuitGadg_itext0
    DC.L    0

QuitGadg_itext0:
    DC.B    'Quit',0
    CNOP    0,2

QuitGadg_ID   EQU     2

QuitGadg:
    DC.L    SleepGadg
    DC.W    510,81
    DC.W    93,15
    DC.W    GADGHIMAGE
    DC.W    RELVERIFY
    DC.W    BOOLGADGET
    DC.L    SharedBorders8
    DC.L    SharedBorders10
    DC.L    QuitGadg_text0,0
    DC.L    0
    DC.W    QuitGadg_ID
    DC.L    Quit

HelpGadg_text0:
    DC.B    1,0
    DC.B    RP_JAM1
    DC.W    23,4
    DC.L    0
    DC.L    HelpGadg_itext0
    DC.L    0

HelpGadg_itext0:
    DC.B    'About',0
    CNOP    0,2

HelpGadg_ID   EQU     1

HelpGadg:
    DC.L    QuitGadg
    DC.W    15,81
    DC.W    93,15
    DC.W    GADGHIMAGE
    DC.W    RELVERIFY
    DC.W    BOOLGADGET
    DC.L    SharedBorders4
    DC.L    SharedBorders6
    DC.L    HelpGadg_text0,0
    DC.L    0
    DC.W    HelpGadg_ID
    DC.L    About

FunctionGadg_info:
    DC.L    Functionbuf
    DC.L    0
    DC.W    0,30
    DC.W    0,0,0,0,0,0
    DC.L    0,0,0

FunctionGadg_ID   EQU     0

FunctionGadg:
    DC.L    HelpGadg
    DC.W    137,63
    DC.W    224,11
    DC.W    GADGHIMAGE
    DC.W    RELVERIFY+STRINGCENTER
    DC.W    STRGADGET
    DC.L    SharedBorders0
    DC.L    SharedBorders2
    DC.L    0,0
    DC.L    FunctionGadg_info
    DC.W    FunctionGadg_ID
    DC.L    FindFunction

MyWindow:
    DC.W    0,25,640,108
    DC.B    0,1
    DC.L    GADGETUP+CLOSEWINDOW+ACTIVEWINDOW
    DC.L    WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+NOCAREREFRESH+SMART_REFRESH+ACTIVATE
    DC.L    FunctionGadg,0
    DC.L    MyWindow_title
    DC.L    0,0
    DC.W    150,50,640,256,WBENCHSCREEN

MyWindow_title:
    DC.B    'LibHelp © 1992, M.Meany. Amiga Format Version. Supports v2.0 Functions.',0
    CNOP    0,2

***************	Sleeping window structure

SleepWindow:
    DC.W    30,0,175,12
    DC.B    0,1
    DC.L    CLOSEWINDOW+MOUSEBUTTONS
    DC.L    WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+NOCAREREFRESH+SMART_REFRESH+ACTIVATE+RMBTRAP
    DC.L    0,0
    DC.L    SleepWindow_title
    DC.L    0,0
    DC.W    150,50,640,256,WBENCHSCREEN

SleepWindow_title:
    DC.B    'LibHelp zzzZZZ',0
    EVEN

***************	About window + IText structures

AboutTexts0:
    DC.B    1,0
    DC.B    RP_JAM1
    DC.W    68,15
    DC.L    0
    DC.L    AboutTextsIText0
    DC.L    AboutTexts1

AboutTextsIText0:
    DC.B    'LibHelp © M.Meany 1992',0
    EVEN

AboutTexts1
    DC.B    1,0
    DC.B    RP_JAM1
    DC.W    69,23
    DC.L    0
    DC.L    AboutTextsIText1
    DC.L    AboutTexts2

AboutTextsIText1:
    DC.B    '~~~~~~~~~~~~~~~~~~~~~~',0
    EVEN

AboutTexts2
    DC.B    1,0
    DC.B    RP_JAM1
    DC.W    18,28
    DC.L    0
    DC.L    AboutTextsIText2
    DC.L    AboutTexts3

AboutTextsIText2:
    DC.B    'This program is Freeware, spread as',0
    EVEN

AboutTexts3
    DC.B    1,0
    DC.B    RP_JAM1
    DC.W    20,38
    DC.L    0
    DC.L    AboutTextsIText3
    DC.L    AboutTexts4

AboutTextsIText3:
    DC.B    'you wish. No charge may be made for',0
    EVEN

AboutTexts4
    DC.B    1,0
    DC.B    RP_JAM1
    DC.W    20,48
    DC.L    0
    DC.L    AboutTextsIText4
    DC.L    AboutTexts5

AboutTextsIText4:
    DC.B    'a copy of this program. Source will',0
    EVEN

AboutTexts5
    DC.B    1,0
    DC.B    RP_JAM1
    DC.W    36,59
    DC.L    0
    DC.L    AboutTextsIText5
    DC.L    AboutTexts6

AboutTextsIText5:
    DC.B    'be made available upon request.',0
    EVEN

AboutTexts6
    DC.B    1,0
    DC.B    RP_JAM1
    DC.W    47,72
    DC.L    0
    DC.L    AboutTextsIText6
    DC.L    AboutTexts7

AboutTextsIText6:
    DC.B    'This version submitted to:',0
    EVEN

AboutTexts7
    DC.B    1,0
    DC.B    RP_JAM1
    DC.W    66,87
    DC.L    0
    DC.L    AboutTextsIText7
    DC.L    AboutTexts8

AboutTextsIText7:
    DC.B    'AMIGA FORMAT MAGAZINE',0
    EVEN

AboutTexts8
    DC.B    1,0
    DC.B    RP_JAM1
    DC.W    68,84
    DC.L    0
    DC.L    AboutTextsIText8
    DC.L    AboutTexts9

AboutTextsIText8:
    DC.B    '~~~~~~~~~~~~~~~~~~~~~',0
    EVEN

AboutTexts9
    DC.B    1,0
    DC.B    RP_JAM1
    DC.W    67,95
    DC.L    0
    DC.L    AboutTextsIText9
    DC.L    0

AboutTextsIText9:
    DC.B    '~~~~~~~~~~~~~~~~~~~~~',0
    EVEN

AboutWindow:
    DC.W    112,25,315,106
    DC.B    0,1
    DC.L    CLOSEWINDOW
    DC.L    WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+NOCAREREFRESH+SMART_REFRESH+ACTIVATE
    DC.L    0,0
    DC.L    AboutWindow_title
    DC.L    0,0
    DC.W    150,50,640,256,WBENCHSCREEN

AboutWindow_title:
    DC.B    '     LibHelp About Window',0
    EVEN

***************	Function Data

; The following data buffer was constructed from .fd files by converting all
;line feeds to NULL bytes. The .fd files were joined together to save having
;loads of incbins.

DataBuffer	dc.b		0
		incbin		NewLibHelpData.i
DBSize		equ		*-DataBuffer
		even
BufEnd		

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

about.ptr	ds.l		1
about.up	ds.l		1
about.rp	ds.l		1

_MatchFlag	ds.l		1

STD_OUT		ds.l		1

dispName	ds.b		40
dispParam	ds.b		80
dispReg		ds.b		30

;***********************************************************
		section Pointer,data_c
;***********************************************************

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
		