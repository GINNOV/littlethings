
; 23 Jan 92. Menu now opens it's own 8 colour screen.

*********
; Menu system for acc discs. This code previously unreleased! 

; Reads a menu descriptor ( acc0 ) from the s: directory. This file should
;contain the required commands for the menu.

; Now added a customised version of my text file viewer to the code - snazzy
;gadgets and ppLoadData included. 

; Config files can now be crunched!

; Reorganised for v2.0 machine and Devpac3.

; © M.Meany, Jan 1992.

; NOTE : ACC users. Assemble in one of two ways:

;		1/ As 'Linkable' to disk with DEBUG = 0.
;		2/ As 'Executable' to memory with DEBUG = 1.

; If assembling to disk, link with text.o, play.o and ilbm.o using blink.

; EG. >Blink menu.o text.o play.o ilbm.o to ram:Menu

DEBUG		equ		0	; Set to 1 for standalone code.


		incdir		sys:include/
		include		exec/exec_lib.i
		include		exec/exec.i
		include		libraries/dos_lib.i
		include		intuition/intuition_lib.i
		include		intuition/intuition.i
		include		graphics/graphics_lib.i
		include		graphics/gfx.i
		include		Source:include/powerpacker_lib.i
		include		Source:include/ppbase.i

; If DEBUG=0 this is the real thing, so define import/export info.

		IFEQ		DEBUG

		XDEF		screen.ptr,_DOSBase,_IntuitionBase,_GfxBase,_PPBase
		XREF		ShowFile,PlayFile,StopPlaying,ViewILBM

		ENDC

NUMG	=	20		number of gadgets

CALLNICO	macro
		move.l	_PPBase,a6
		jsr	_LVO\1(a6)
		endm

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
		beq		no_libs		if so quit

		bsr		Init		Initialise data
		tst.l		d0		any errors?
		beq		no_libs		if so quit

		bsr		Openscreen	open custom screen
		tst.l		d0
		beq		no_scrn

		bsr		Openwin		open window
		tst.l		d0		any errors?
		beq		no_win		if so quit

		bsr		WaitForMsg	wait for user

		bsr		Closewin	close our window

no_win		bsr		Closescreen	close custom scren

no_scrn		bsr		DeInit		free resources

no_libs		bsr		Closelibs	close open libraries

		rts				finish


;**************	Open all required libraries

; Open DOS, Intuition and Graphics libraries.

; If d0=0 on return then one or more libraries are not open.

Openlibs	moveq.l		#0,d0		clear base pointers
		move.l		d0,_DOSBase
		move.l		d0,_IntuitionBase
		move.l		d0,_GfxBase
		move.l		d0,_PPBase

		lea		dosname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_DOSBase	save base ptr
		beq		.lib_error

		lea		intname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_IntuitionBase	save base ptr
		beq		.lib_error

		lea		gfxname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_GfxBase	save base ptr
		beq		.lib_error

		lea		ppname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_PPBase	save base ptr

.lib_error	rts

*************** Initialise any data

;--------------	At present just set STD_OUT and check for usage text

Init		tst.l		returnMsg	are we from WorkBench?
		bne.s		.ok		if so ignore usage bit

		CALLDOS		Output		determine CLI handle
		move.l		d0,STD_OUT	and save it for later
		beq		.err		quit if there is no handle

		move.l		_args,a0	get addr of CLI args
		cmpi.b		#'?',(a0)	is the first arg a ?
		bne.s		.ok		if not skip the next bit

		lea		_UsageText,a0	a0->the usage text
		bsr			DOSPrint	and display it
.err		moveq.l		#0,d0		set an error
		bra.s		.error		and finish

;--------------	Your Initialisations should start here

.ok		moveq.l		#0,d0
		move.l		d0,TopEntry	TopEntry->1st line in box
		move.l		d0,buffer	init to zero
		move.l		d0,dir		""""""""""""

		lea		filename,a0	a0->initial menu file
		bsr		Load

		bsr		BuildList

		moveq.l		#1,d0		no errors

.error		rts				back to main


***************	Open a custom eight colour screen and set colours

Openscreen	lea		MyScreen,a0	a0->screen defs
		CALLINT		OpenScreen	and open it
		move.l		d0,screen.ptr	store screen pointer
		beq.s		.error		quit if no open
		
		move.l		d0,a0
		lea		sc_ViewPort(a0),a0	a0->vp structure
		move.l		a0,screen.vp	and store it
		
		lea		Palette,a1	a1->colour table
		moveq.l		#8,d0		number to set
		CALLGRAF	LoadRGB4	set palette
		
		moveq.l		#1,d0		no errors
.error		rts				return		

*************** Open An Intuition Window

; Opens an intuition window. If d0=0 on return then window could not be
;opened.

Openwin		lea		MyWindow,a0	a0->window args

		move.l		screen.ptr,nw_Screen(a0)  set screen pointer

		CALLINT		OpenWindow	and open it
		move.l		d0,window.ptr	save struct ptr
		beq		.win_error	quit if error

		move.l		d0,a0			  ;a0->win struct	
		move.l		wd_UserPort(a0),window.up ;save up ptr
		move.l		wd_RPort(a0),window.rp    ;save rp ptr

;--------------	Display custom image

		move.l		window.rp,a0	a0->windows RastPort
		lea		Image1,a1	a1->image 
		moveq.l		#0,d0		X offset
		moveq.l		#0,d1		Y offset
		CALLINT		DrawImage	draw screen

;--------------	Add gadgets to list

		move.l		window.ptr,a0	a0->window struct
		lea		Str1Gadg,a1	a1->first gadget
		moveq.l		#0,d0		position ( 1st )
		moveq.l		#NUMG,d1		num of gadgets
		sub.l		a2,a2		zero addr reg
		CALLINT		AddGList

		move.l		dir,a0		a0->start of list
		move.l		nd_Succ(a0),a0	a0->1st entry
		bsr		BuildDisplay	set up gadget text

;--------------	Refresh all gadgets

.done		lea		Str1Gadg,a0	gadget list
		move.l		window.ptr,a1	window
		sub.l		a2,a2		not a requester
		CALLINT		RefreshGadgets	and display them

;--------------	Display menu

		move.l		window.rp,a0	a0->windows RastPort
		lea		BoxText,a1	a1->image 
		moveq.l		#0,d0		X offset
		moveq.l		#0,d1		Y offset
		CALLINT		PrintIText	draw screen

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
		beq		WaitForMsg	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.l		im_IAddress(a1),a5 a5=addr of structure
		CALLSYS		ReplyMsg	answer os or it get angry

		move.l		d2,d0
		and.l		#GADGETUP!GADGETDOWN,d0
		beq		.test_win
		move.l		gg_UserData(a5),a0
		cmpa.l		#0,a0
		beq		.test_win
		jsr		(a0)

.test_win	cmp.l		#CLOSEWINDOW,d2  window closed ?
		bne.s		WaitForMsg	 if not then jump
		rts


*************** Close the Intuition window.

Closewin	move.l		window.ptr,a0	a0->Window struct
		CALLINT		CloseWindow	and close it
		rts

***************	Close custom screen

Closescreen	move.l		screen.ptr,a0
		CALLINT		CloseScreen
		rts
		
***************	Release any additional resources used

DeInit		move.l		dir,a0
		cmp.l		#0,a0
		beq.s		.check_lines

		bsr			FreeList

.check_lines	move.l		buffer,a1
		move.l		buf_len,d0
		beq.s		.check_list
		CALLEXEC	FreeMem
		
.check_list	move.l		line_list,a1
		move.l		line_list_size,d0
		beq.s		.done
		CALLEXEC	FreeMem

.done		rts

***************	Close all open libraries

; Closes any libraries the program managed to open.

Closelibs	
		move.l		_DOSBase,d0		d0=base ptr
		beq		.pp2			quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.pp2		move.l		_IntuitionBase,d0		d0=base ptr
		beq		.pp1			quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.pp1		move.l		_GfxBase,d0		d0=base ptr
		beq		.pp			quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.pp		move.l		_PPBase,d0		d0=base ptr
		beq		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.lib_error	rts


*****************************************************************************
*			Useful Subroutines Section					    *
*****************************************************************************

*****************************************************************************

; Routine to clear all gadget texts and set colours to white.
; This routine clears the display area!

; Entry		None

; Exit		d0->mt ( a blank text string )

; Corrupt	d0,a0

ClearDisplay	movem.l		d2-d4/a1-a6,-(sp)

		moveq.l		#0,d0		set default colour

		move.b		d0,clr1
		move.b		d0,clr2
		move.b		d0,clr3
		move.b		d0,clr4
		move.b		d0,clr5
		move.b		d0,clr6
		move.b		d0,clr7
		move.b		d0,clr8
		move.b		d0,clr9
		move.b		d0,clr10
		move.b		d0,clr11
		move.b		d0,clr12
		move.b		d0,clr13
		move.b		d0,clr14
		move.b		d0,clr15
		move.b		d0,clr16
		move.b		d0,clr17
		
		move.l		#mt,d0
		move.l		d0,ptr1
		move.l		d0,ptr2
		move.l		d0,ptr3
		move.l		d0,ptr4
		move.l		d0,ptr5
		move.l		d0,ptr6
		move.l		d0,ptr7
		move.l		d0,ptr8
		move.l		d0,ptr9
		move.l		d0,ptr10
		move.l		d0,ptr11
		move.l		d0,ptr12
		move.l		d0,ptr13
		move.l		d0,ptr14
		move.l		d0,ptr15
		move.l		d0,ptr16
		move.l		d0,ptr17

		movem.l		(sp)+,d2-d4/a1-a6
		rts

*****************************************************************************

; Routine to build text in dir display area. Does not call refresh gadgets.

; Entry		a0->node at top of list

; Exit		None

; Corrupt	d0,a0,a1

BuildDisplay	move.l		a0,-(sp)	save node pointer
		bsr		ClearDisplay	reset output area
		move.l		(sp)+,a0	restore node pointer

		tst.l		nd_Succ(a0)	end of list?
		beq		.done		if so quit!
		tst.l		nd_Data(a0)	data exsists?
		beq		.done		if not, end list
		move.l		nd_Data(a0),a1	a1->line list
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clr1		and replace it
		move.l		a1,ptr1		data pointer into text struct
		move.l		a0,TopEntry	set ptr to 1st visible entry

		move.l		nd_Succ(a0),a0	a0->1st entry
		tst.l		nd_Succ(a0)	end of list?
		beq		.done		if so quit!
		tst.l		nd_Data(a0)	data exsists?
		beq		.done		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clr2		and replace it
		move.l		a1,ptr2		data pointer into text struct

		move.l		nd_Succ(a0),a0	a0->1st entry
		tst.l		nd_Succ(a0)	end of list?
		beq		.done		if so quit!
		tst.l		nd_Data(a0)	data exsists?
		beq		.done		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clr3		and replace it
		move.l		a1,ptr3		data pointer into text struct

		move.l		nd_Succ(a0),a0	a0->1st entry
		tst.l		nd_Succ(a0)	end of list?
		beq		.done		if so quit!
		tst.l		nd_Data(a0)	data exsists?
		beq		.done		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clr4		and replace it
		move.l		a1,ptr4		data pointer into text struct

		move.l		nd_Succ(a0),a0	a0->1st entry
		tst.l		nd_Succ(a0)	end of list?
		beq		.done		if so quit!
		tst.l		nd_Data(a0)	data exsists?
		beq		.done		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clr5		and replace it
		move.l		a1,ptr5		data pointer into text struct

		move.l		nd_Succ(a0),a0	a0->1st entry
		tst.l		nd_Succ(a0)	end of list?
		beq		.done		if so quit!
		tst.l		nd_Data(a0)	data exsists?
		beq		.done		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clr6		and replace it
		move.l		a1,ptr6		data pointer into text struct

		move.l		nd_Succ(a0),a0	a0->1st entry
		tst.l		nd_Succ(a0)	end of list?
		beq		.done		if so quit!
		tst.l		nd_Data(a0)	data exsists?
		beq		.done		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clr7		and replace it
		move.l		a1,ptr7		data pointer into text struct

		move.l		nd_Succ(a0),a0	a0->1st entry
		tst.l		nd_Succ(a0)	end of list?
		beq		.done		if so quit!
		tst.l		nd_Data(a0)	data exsists?
		beq		.done		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clr8		and replace it
		move.l		a1,ptr8		data pointer into text struct

		move.l		nd_Succ(a0),a0	a0->1st entry
		tst.l		nd_Succ(a0)	end of list?
		beq		.done		if so quit!
		tst.l		nd_Data(a0)	data exsists?
		beq		.done		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clr9		and replace it
		move.l		a1,ptr9		data pointer into text struct

		move.l		nd_Succ(a0),a0	a0->1st entry
		tst.l		nd_Succ(a0)	end of list?
		beq		.done		if so quit!
		tst.l		nd_Data(a0)	data exsists?
		beq		.done		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clr10	and replace it
		move.l		a1,ptr10	data pointer into text struct

		move.l		nd_Succ(a0),a0	a0->1st entry
		tst.l		nd_Succ(a0)	end of list?
		beq		.done		if so quit!
		tst.l		nd_Data(a0)	data exsists?
		beq		.done		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clr11	and replace it
		move.l		a1,ptr11	data pointer into text struct

		move.l		nd_Succ(a0),a0	a0->1st entry
		tst.l		nd_Succ(a0)	end of list?
		beq		.done		if so quit!
		tst.l		nd_Data(a0)	data exsists?
		beq		.done		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clr12	and replace it
		move.l		a1,ptr12	data pointer into text struct

		move.l		nd_Succ(a0),a0	a0->1st entry
		tst.l		nd_Succ(a0)	end of list?
		beq		.done		if so quit!
		tst.l		nd_Data(a0)	data exsists?
		beq		.done		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clr13	and replace it
		move.l		a1,ptr13	data pointer into text struct

		move.l		nd_Succ(a0),a0	a0->1st entry
		tst.l		nd_Succ(a0)	end of list?
		beq		.done		if so quit!
		tst.l		nd_Data(a0)	data exsists?
		beq		.done		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clr14	and replace it
		move.l		a1,ptr14	data pointer into text struct

		move.l		nd_Succ(a0),a0	a0->1st entry
		tst.l		nd_Succ(a0)	end of list?
		beq		.done		if so quit!
		tst.l		nd_Data(a0)	data exsists?
		beq		.done		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clr15	and replace it
		move.l		a1,ptr15	data pointer into text struct

		move.l		nd_Succ(a0),a0	a0->1st entry
		tst.l		nd_Succ(a0)	end of list?
		beq		.done		if so quit!
		tst.l		nd_Data(a0)	data exsists?
		beq		.done		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clr16	and replace it
		move.l		a1,ptr16	data pointer into text struct

		move.l		nd_Succ(a0),a0	a0->1st entry
		tst.l		nd_Succ(a0)	end of list?
		beq		.done		if so quit!
		tst.l		nd_Data(a0)	data exsists?
		beq		.done		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clr17	and replace it
		move.l		a1,ptr17	data pointer into text struct

.done		rts

*****************************************************************************

; Subroutine to deal with UP scroll gadget

; Entry		None

; Exit		TopEntry is updated

; Corrupted	d0,d1,a0,a1

Up		movem.l		d3-d7/a2-a6,-(sp)

		move.l		a5,-(sp)
		or.w		#$0080,gg_Flags(a5)	set on
		moveq.l		#1,d0			how many
		move.l		a5,a0			gadget
		move.l		window.ptr,a1		window
		suba.l		a2,a2			not requester
		CALLINT		RefreshGList		and refresh

;--------------	Check not at the end of the list

.loop		move.l		TopEntry,a0	a0->1st visible entry
		move.l		nd_Pred(a0),a0	a0->entry before it
		tst.l		nd_Pred(a0)	is it the 'head'?
		beq		.done		if so quit!

;--------------	Not end, so update first line pointer

		move.l		a0,TopEntry	update TopEntry

;--------------	Now scroll the display rectangle
		CALLGRAF	WaitTOF

		move.l		window.rp,a1	rastport
		moveq.l		#0,d0		dx
		moveq.l		#-9,d1		dy ( -ve => scroll up )
		moveq.l		#44,d2		x1
		moveq.l		#80,d3		y1
		move.l		#314,d4		x2
		move.l		#232,d5		y2
		CALLGRAF	ScrollRaster	and scroll the box

;--------------	Top of rectangle corrupted, so restore it

		move.l		window.rp,a1
		move.l		#3,d0
		CALLGRAF	SetAPen

		move.l		window.rp,a1
		moveq.l		#44,d0		x1
		moveq.l		#80,d1		y1
		move.l		#314,d2		x2
		moveq.l		#88,d3		y2
		CALLGRAF	RectFill	and colour it in

;--------------	Get Top Line Node Pointer

		move.l		TopEntry,a0	a0->node for top line

;--------------	Set text pointer and colour to a default

		move.b		#0,clrT
		move.l		#mt,ptrT

;--------------	Use info stored in node to set up IText

		tst.l		nd_Data(a0)	data exsists?
		beq		.ok		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clrT		and replace it
		move.l		a1,ptrT		data pointer into text struct

;--------------	Display the line

		move.l		window.rp,a0	a0->windows RastPort
		lea		clrT,a1		a1->IText struct
		moveq.l		#0,d0		X offset
		moveq.l		#0,d1		Y offset
		CALLINT		PrintIText	print it

.ok		btst		#6,$bfe001
		beq		.loop

.done		move.l		(sp)+,a5
		and.w		#$ff7f,gg_Flags(a5)
		moveq.l		#1,d0			how many
		move.l		a5,a0			gadget
		move.l		window.ptr,a1		window
		suba.l		a2,a2			not requester
		CALLINT		RefreshGList		and refresh

		movem.l		(sp)+,d3-d7/a2-a6

		moveq.l		#0,d2		don't quit
		rts
*****************************************************************************

; Subroutine to deal with DOWN scroll gadget

; Entry		None

; Exit		TopEntry is updated

; Corrupted	d0,d1,a0,a1

Down		movem.l		d3-d7/a2-a6,-(sp)

		move.l		a5,-(sp)
		or.w		#$0080,gg_Flags(a5)	set on
		moveq.l		#1,d0			how many
		move.l		a5,a0			gadget
		move.l		window.ptr,a1		window
		suba.l		a2,a2			not requester
		CALLINT		RefreshGList		and refresh

;--------------	Check not at the start of the list

.loop		move.l		TopEntry,a0	a0->1st visible entry
		move.l		nd_Succ(a0),a0	a0->entry before it
		tst.l		nd_Succ(a0)	is it the 'head'?
		beq		.done		if so quit!

;--------------	Not end, so update first line pointer

		move.l		a0,TopEntry	update TopEntry

;--------------	Now scroll the display rectangle
		CALLGRAF	WaitTOF

		move.l		window.rp,a1	rastport
		moveq.l		#0,d0		dx
		moveq.l		#9,d1		dy ( +ve => scroll down )
		moveq.l		#44,d2		x1
		moveq.l		#80,d3		y1
		move.l		#314,d4		x2
		move.l		#232,d5		y2
		CALLGRAF	ScrollRaster	and scroll the box

;--------------	Top of rectangle corrupted, so restore it

		move.l		window.rp,a1
		move.l		#3,d0
		CALLGRAF	SetAPen

		move.l		window.rp,a1
		moveq.l		#44,d0		x1
		move.l		#223,d1		y1
		move.l		#314,d2		x2
		move.l		#232,d3		y2
		CALLGRAF	RectFill	and colour it in

;--------------	Get Top Line Node Pointer

		move.l		TopEntry,a0	a0->node for top line

;--------------	Step through list to node to display at bottom

		moveq.l		#15,d0		num of lines displayed-1
.l1		move.l		nd_Succ(a0),a0	a0->next line
		tst.l		nd_Succ(a0)	end of list
		beq		.ok		if so skip redraw
		dbra		d0,.l1		

;--------------	Set text pointer and colour to a default

		move.b		#0,clrB
		move.l		#mt,ptrB

;--------------	Use info stored in node to set up IText

		tst.l		nd_Data(a0)	data exsists?
		beq		.ok		if not, end list
		move.l		nd_Data(a0),a1	a1->this entry
		move.l		(a1),a1		a1->this entry
		move.b		(a1)+,d0	d0=colour byte
		subi.b		#'0',d0		convert
		move.b		d0,clrB		and replace it
		move.l		a1,ptrB		data pointer into text struct

;--------------	Display the line

		move.l		window.rp,a0	a0->windows RastPort
		lea		clrB,a1		a1->IText struct
		moveq.l		#0,d0		X offset
		moveq.l		#0,d1		Y offset
		CALLINT		PrintIText	print it

.ok		btst		#6,$bfe001
		beq		.loop

.done		move.l		(sp)+,a5
		and.w		#$ff7f,gg_Flags(a5)
		moveq.l		#1,d0			how many
		move.l		a5,a0			gadget
		move.l		window.ptr,a1		window
		suba.l		a2,a2			not requester
		CALLINT		RefreshGList		and refresh

		movem.l		(sp)+,d3-d7/a2-a6

		moveq.l		#0,d2		don't quit
		rts

*****************************************************************************

DoQuit		move.l		#CLOSEWINDOW,d2		set quit flag
		rts

*****************************************************************************

;--------------	
;--------------	Load a text file
;--------------	

; This subroutine checks if a file is already in memory. If so all memory
;allocated to it is freed before a new file is loaded.

; Check if a file is already loaded

Load		move.l		a0,a4		save pointer to file name
		tst.l		buffer
		beq.s		.ok

; If so free the memory it occupies ( ie scrap it )
		
		move.l		buffer,a1
		move.l		buf_len,d0
		CALLEXEC	FreeMem
			
		move.l		#0,buffer

; Use acc.library to load the file

.ok		move.l		a4,a0
		move.l		#MEMF_PUBLIC,d0
		bsr			LoadFile
		move.l		a0,buffer
		move.l		d0,buf_len
		bne.s		.file_ok

		bsr		NoFile		get error file

;--------------	Free memory for any table currently in mem

.file_ok	move.l		line_list,a1
		move.l		line_list_size,d0
		beq.s		.no_list
		CALLEXEC	FreeMem

;--------------	Count num of lines in file

.no_list	moveq.l		#0,d0		init counter
		move.l		d0,d1		clear d1
		moveq.l		#$0a,d2		d2=line-feed
		move.l		buf_len,d3	init loop counter
		move.l		buffer,a0	a0->buffer
		movem.l		d1-d3/a0,-(sp)	save init values


lf_loop		cmp.b		(a0)+,d2	is this byte a LF
		bne.s		.ok		if not jump
		addq.l		#1,d0		else bump counter
		move.b		#0,-1(a0)	and set to NULL
.ok		subq.l		#1,d3		loop until end of file
		bne.s		lf_loop

;--------------	Get memory for line table, addr of start of every line
;		will be saved in this table

		move.l		d0,num_lines	save counter
		addq.l		#2,d0		to be safe
		asl.l		#2,d0		x4, 4 bytes/entry
		move.l		d0,line_list_size  save size of table
		move.l		#MEMF_PUBLIC,d1	memory type
		CALLEXEC	AllocMem	get mem for line table
		movem.l		(sp)+,d1-d3/a0	reset registers to init vals
		move.l		d0,line_list	save pointer
		beq.s		ld_mem_err		leave if error

;--------------	Find addr of start of each line and store in table

		move.l		d0,a1		a1->table
		move.l		a0,(a1)+	addr of 1st line into table
		moveq.l		#0,d2		search for NULL bytes

table_loop	cmp.b		(a0)+,d2	this byte a LF
		bne.s		.ok		if not then jump
		move.l		a0,(a1)+	else save addr of next line
.ok		subq.l		#1,d3		loop until end of file
		bne.s		table_loop	
		
		move.l		#1,top_line	set top line num

;--------------	Calculate the max value of top_line

		move.l		lines_on_scrn,d0
		move.l		num_lines,d1
		sub.l		d0,d1
		beq.s		.error
		bmi.s		.error
		bra		.ok1
.error		moveq.l		#1,d1
.ok1		move.l		d1,max_top_line

; Line list created, now build a linked list to control entries

		bra		load_error

; If file was not loaded for some reason, flash the screen

ld_mem_err	move.l		#0,a0
		CALLINT		DisplayBeep
		
load_error	moveq.l		#0,d0
		rts

*****************************************************************************

;--------------	
;--------------	Build a linked list
;--------------	


BuildList	movem.l		d2-d7/a2-a6,-(sp)

		move.l		dir,d0			get header ptr
		beq.s		.no_list		skip if none
		move.l		d0,a0
		bsr			FreeList		release list

.no_list	bsr			NewList			start a new list
		move.l		d0,dir			save header ptr
		beq		.error			quit if error

		move.l		num_lines,d4		get line counter
		asr.l		#1,d4			div by 2
		subq.l		#1,d4			adjust for dbra
		move.l		line_list,a2		a2->line table
		move.l		d0,a0			a0->header

.loop		bsr			AddNode			add a new node
		tst.l		d0			all ok?
		bne.s		.error			quit if not

		move.l		a2,nd_Data(a0)		save data ptr
		lea		8(a2),a2		a2->next entry

		dbra		d4,.loop		for all entries

.error		movem.l		(sp)+,d2-d7/a2-a6
		rts
*****************************************************************************

; If a file fails to load, this subroutine is called. It loads a self
;contained text script into a block of memory ( as ppLoadData would ) and
;then returns. This stops the program Guru'ing when a configoration file
;cannot be located.

NoFile		movem.l		d0-d7/a0-a6,-(sp)

		move.l		#NoFileSIZEOF,d0	size of message
		moveq.l		#MEMF_PUBLIC,d1		type of mem
		CALLEXEC	AllocMem		get memory
		move.l		d0,buffer		save addr of mem
		beq.s		.error			quit if none

		move.l		d0,a1			dest
		move.l		#NoFileSIZEOF,d0	size of message
		move.l		d0,buf_len		save it
		lea		NoFileMsg,a0		source
		CALLEXEC	CopyMem			and copy it

.error		movem.l		(sp)+,d0-d7/a0-a6
		rts


****************

; Subroutine that loads a file into a block of memory.

; Entry		a0-> filename
;		d0=  type of memory ( either CHIPMEM, FASTMEM or MEMF_PUBLIC )

; Exit		d0= length of buffer allocated
;		a0->buffer

; Corrupt	d0,a0

LoadFile	movem.l		d1-d7/a1-a6,-(sp)


		moveq.l		#DECR_POINTER,d0
		moveq.l		#0,d1
		lea		buffer,a1
		lea		buf_len,a2
		move.l		d1,a3
		CALLNICO	ppLoadData

		move.l		buffer,a0
		move.l		buf_len,d0
		movem.l		(sp)+,d1-d7/a1-a6

		rts

****************

;--------------	Subroutine to display any message in an open file.

; Entry		a0 must hold address of 0 terminated message.
;		d0 should hold handle of open file to be written to.

; Exit		None
;Corrupted	d0,d1,a0,a1

DOSPrint	move.l		d3,-(sp)	save work registers
		move.l		d2,-(sp)

		move.l		d0,d1		get a working copy of handle
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

		tst.l		d1		d1=file handle
		beq.s		.error		leave if no handle

;--------------	Now print the message
;		At this point, d3 already holds length of message
;		and d1 holds the file handle.

		move.l		a0,d2		d2=address of message
		CALLDOS		Write		and print it

;--------------	All done so finish

.error		move.l		(sp)+,d2	restore registers
		move.l		(sp)+,d3
		rts				and return

*****************************************************************************

; Create an empty list

; Entry		None
; Exit		d0=addr of list header or zero if no memory available
; Corrupted	d0,d1,a0,a1

NewList		moveq.l		#nd_SIZEOF,d0		size of node
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1 type of mem
		CALLEXEC	AllocMem		and get a block
		move.l		d0,d1			save pointer
		beq.s		.error			quit if error

		move.l		d0,a0			a0->header
		move.l		d0,8(a0)		head pointer
		addq.l		#4,d0			addr of tail
		move.l		d0,(a0)			tail pointer
		move.l		a0,d0			d0=addr of header

.error		rts

*****************************************************************************

; Add node to list

; Entry		a0->node to insert after.

; Exit		d0 is non zero if an error occurred.
;		   Specific error codes: d0=1 if no memory for node structure
;		   d0=2 if attempting to write node after the Tail

; Corrupt	d0,d1,a0,a1

AddNode		move.l		a0,-(sp)	save node pointer

		tst.l		(a0)	end of list?
		bne.s		.do_it		if not skip next bit
		move.l		(sp)+,a0
		moveq.l		#2,d0		set error code ( 2=Tail )
		bra.s		.error		and leave

.do_it		moveq.l		#nd_SIZEOF,d0	size of block
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1	type of mem
		CALLEXEC	AllocMem	get block
		move.l		d0,d1		save pointer
		bne.s		.ok		branch if mem obtained

		move.l		(sp)+,a0
		moveq.l		#1,d0		set error code ( 1=no mem )
		bra.s		.error		and leave

.ok		move.l		d0,a1		a1->new nodes structure

		move.l		(sp)+,a0	a0->list header
		move.l		a0,nd_Pred(a1)	new node has head as pred

		move.l		(a0),nd_Succ(a1) new node succ=heads old succ

		move.l		a1,(a0)		head points to new node

		move.l		nd_Succ(a1),a0	a0->heads old successor
		move.l		a1,nd_Pred(a0)	heads old succ has node as pred

		move.l		a1,a0		a0->this node
		moveq.l		#0,d0		no errors

.error		rts

*****************************************************************************

; Delete a node from a list.

; Note, this routine only releases the memory occupied by the nodes
;structure, not by the nodes data!

; Entry		a0->node to delete
; Exit		none, but node will not be released if it is the Head or Tail
; Corrupted	d0,d1,a0.a1

DeleteNode	movem.l		d2-d4/a2-a4,-(sp)	save registers

		move.l		nd_Succ(a0),d3	get pointer to successor
		beq		.error		quit if this is lists Tail

		move.l		nd_Pred(a0),d4	get pointer to predecessor
		beq		.error		quit if this is lists Head

		move.l		a0,a1		a1->node
		move.l		#nd_SIZEOF,d0	d0=structure size
		CALLEXEC	FreeMem		and release memory

		move.l		d3,a0		a0->old successor
		move.l		d4,a1		a1->old predecessor

		move.l		d3,nd_Succ(a1)	link succ to pred
		move.l		d4,nd_Pred(a0)

.error		movem.l		(sp)+,d2-d4/a2-a4	restore registers
		rts

*****************************************************************************

; Release all memory used by a list

; Entry		a0->list header
; Exit		none
; Corrupted	d0,d1,a0,a1

FreeList	move.l		a4,-(sp)	save registers
		move.l		d4,-(sp)

		move.l		a0,a4		get copy of header ptr

		move.l		nd_Succ(a4),d4	d4 = addr of next node

.loop		move.l		d4,a1		a1->node to release
		tst.l		(a1)		is this the tail?
		beq.s		.done_nodes	yep! so quit loop

		move.l		nd_Succ(a1),d4	d4=addr of next node

		move.l		#nd_SIZEOF,d0	d0=size of mem to free
		CALLEXEC	FreeMem		and release this node

		bra.s		.loop		loop back for next node

.done_nodes	move.l		a4,a1		a1->list header
		move.l		#nd_SIZEOF,d0	size of mem to free
		CALLEXEC	FreeMem		and release it

		move.l		(sp)+,d4	restore registers
		move.l		(sp)+,a4
		rts				all done so return


*****************************************************************************

		include		Menu_Subs.i

*****************************************************************************
*			Data Section					    *
*****************************************************************************

dosname		dc.b		'dos.library',0
		even

intname		dc.b		'intuition.library',0
		even

gfxname		dc.b		'graphics.library',0
		even

ppname		dc.b		'powerpacker.library',0
		even

filename	dc.b		's:acc0',0
		even

; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		'ACC Front End. Coded by ',$9b,"0;33;40m",'M.Meany, 91.',$9b,"0;31;40m"
		dc.b		$0a
		dc.b		'Run from CLI only,with no parameters.'
		dc.b		$0a
		dc.b		0
		even

;***********************************************************
;	Window and Gadget defenitions
;***********************************************************

WinText		dc.b		1		FrontPen
		dc.b		0		BackPen
		dc.b		RP_JAM2		DrawMode
		dc.b		0		KludgeFill00
		dc.w		0		x position
		dc.w		0		y position
		dc.l		0		font
OurText		dc.l		0		address of text to print
		dc.l		0		no more text

lines_on_scrn	dc.l		13

print_comm	dc.b		'ram:ppmore '
exe_string	ds.b		50
		even
;				  01234567890123456789012345678901
NoFileMsg	dc.b		"0Sorry old chap, can't find the",$0a
		dc.b		"@",$0a
		dc.b		"1required config file. I'm afraid",$0a
		dc.b		"@",$0a
		dc.b		"2you're going to have to quit!",$0a
		dc.b		"@",$0a
		dc.b		"4This is a colour test ... ",$0a
		dc.b		"@",$0a
		dc.b		"5All that is gold,",$0a
		dc.b		"@",$0a
		dc.b		"6does not glitter.",$0a
		dc.b		"@",$0a
		dc.b		"1 ",$0a
		dc.b		"@",$0a
		dc.b		"7       ! QUIT PROGRAM !",$0a
		dc.b		"Q",$0a
NoFileSIZEOF	equ		*-NoFileMsg
		even


***************


; Node structure

		rsreset
nd_Succ		rs.l		1	pointer to next node
nd_Pred		rs.l		1	pointer to previous node
nd_Data		rs.l		1	pointer to nodes data
nd_SIZEOF	rs.l		0	size of node structure


;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_args		ds.l		1
_argslen	ds.l		1

_PPBase		ds.l		1
_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

screen.ptr	ds.l		1
screen.vp	ds.l		1

window.ptr	ds.l		1
window.rp	ds.l		1
window.up	ds.l		1

dir		ds.l		1	points to list header

TopEntry	ds.l		1	points to 1st visible entry

buffer		ds.l		1
buf_len		ds.l		1
num_lines	ds.l		1
max_top_line	ds.l		1
line_list	ds.l		1
line_list_size	ds.l		1
top_line	ds.l		1

STD_OUT		ds.l		1

		SECTION  PROGGY,DATA

		INCLUDE		Menu_win.i	INCLUDE WINDOW DEFS


