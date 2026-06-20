
*****	Title		ClipBlit
*****	Function	Demonstrates how to 'blit' into a SuperBitMap!
*****			Requires use of dummy RastPort and BitMap and then
*****			calls ClipBlit()
*****	Size		1428 bytes
*****	Author		Mark Meany
*****	Date Started	22nd June 92
*****	This Revision	
*****	Notes		resize window to see result ( width > 200 )
*****			
*****			

; Some equates for super bitmap window.

WidthSuper	equ		800
HeightSuper	equ		600
DepthSuper	equ		4


CALLSYS		macro
		ifgt	NARG-1
		FAIL	!!!
		endc
		jsr	_LVO\1(a6)
		endm


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

		bsr		DoIt

		bsr		WaitForMsg	wait for user

		bsr		Closewin	close our window

no_win		bsr		DeInit		free resources

no_libs		bsr		Closelibs	close open libraries

		rts				finish


;**************	Open all required libraries

; Open DOS, Intuition, Graphics and Layers libraries.

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
		beq.s		.lib_error	quit if error

		lea		layername,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_LayersBase	save base ptr

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

; This version opens a SuperBitmap window. Alter equates for specific size.

; Allocate memory for a BitMap structure

Openwin		moveq.l		#bm_SIZEOF,d0	mem size
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1	requirements
		CALLEXEC	AllocMem	get some memory
		move.l		d0,MyBitMap	save address
		beq		.win_error	quit if error

; Now intialise the BitMap structure

		move.l		d0,a0		a0->BitMap structure
		moveq.l		#DepthSuper,d0	SuperBitmap depth
		move.l		#WidthSuper,d1	SuperBitmap width
		move.l		#HeightSuper,d2	SuperBitmap height
		CALLGRAF	InitBitMap	initialise the structure

; Allocate memory for the bitplanes. I`ve opted for segmented playfields to
;allow the user more chance of getting the memory required. Trying to
;allocate one huge chunk may fail!

		moveq.l		#DepthSuper-1,d7 loop counter, dbr adjusted
		move.l		MyBitMap,a3	 a3->BitMap structure
		moveq.l		#0,d6		 clear register
		move.w		bm_BytesPerRow(a3),d6  d6=bitplane byte width
		mulu.w		bm_Rows(a3),d6	       d6=RastetSize
		move.w		d6,RasterSize	 save for later

		lea		bm_Planes(a3),a3 a3->1st bitplane pointer
.allocplaneloop	move.l		d6,d0		 size of memory
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1 requirements
		CALLEXEC	AllocMem	get some memory
		move.l		d0,(a3)+	save addr in BitMap struct
		beq		.win_error	quit if error

		dbra		d7,.allocplaneloop for all bitplanes

		bsr		DoIt

; If we get here, all bitplanes have been allocated. Attach the BitMap
;structure to the NewWindow structure.

		lea		MyWindow,a0	a0-> NewWindow structure
		move.l		MyBitMap,nw_BitMap(a0) set nw_BitMap field

; Now open the window.

		CALLINT		OpenWindow	and open it
		move.l		d0,window.ptr	save struct ptr
		beq.s		.win_error	quit if error

; Save important structure addresses

		move.l		d0,a0			  ;a0->win struct	
		move.l		wd_UserPort(a0),window.up ;save up ptr
		move.l		wd_RPort(a0),window.rp    ;save rp ptr
		move.l		window.rp,a0		  a0->RastPort struct
		move.l		rp_Layer(a0),a0	  a0->Layers struct
		move.l		a0,window.lyr		  save pointer
		
; Display basic usage text for user

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

; Updated to deal with SuperBitMap windows. It is possible to progress quite
;some way into initialisation before, an error occurs. Best to check all
;possabilities and go from there! Closing/freing is done in reverse order
;to Opening/allocating where possible!!!

; Close the window

Closewin	move.l		window.ptr,a0	a0->Window struct
		CALLINT		CloseWindow	and close it

; Release bitplane pointers

		move.l		MyBitMap,d6	d6->BitMap structure (safe)
		beq		.error		quit if not allocated

		move.l		d6,a5		a5->BitMap structure
		lea		bm_Planes(a5),a3 a3->1st bitplane
		moveq.l		#DepthSuper-1,d7 loop counter, dbra adjusted

.planeloop	moveq.l		#0,d0		clear register
		move.w		RasterSize,d0	bytesize
		move.l		(a3)+,d1	d1->memoryBlock
		beq.s		.nextplane	skip if not allocated
		move.l		d1,a1		a1->memoryBlock
		CALLEXEC	FreeMem		and release it
.nextplane	dbra		d7,.planeloop	for all bitplanes

; Now release bitmap structure

		moveq.l		#bm_SIZEOF,d0	bytesize
		move.l		d6,a1		memoryBlock
		CALLEXEC	FreeMem		and release it

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

		move.l		_LayersBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.lib_error	rts


*****************************************************************************
*			Useful Subroutines Section					    *
*****************************************************************************

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

; time to use the blitter to slap a gfx into our SuperBitMap

DoIt		lea		Blitrport,a1
		CALLGRAF	InitRastPort
		
		lea		Blitrport,a1		RastPort
		lea		Blitmap,a0		BitMap
		move.l		a0,rp_BitMap(a1)	link 'em
		
		moveq.l		#DepthSuper,d0		depth
		moveq.l		#16,d1			pixel width
		moveq.l		#16,d2			line height
		CALLGRAF	InitBitMap
		
		lea		Blitmap,a5
		moveq.l		#32,d5
		lea		bm_Planes(a5),a0
		lea		plane1,a1

		move.l		a1,(a0)+
		adda.l		d5,a1
		move.l		a1,(a0)+
		adda.l		d5,a1
		move.l		a1,(a0)+
		adda.l		d5,a1
		move.l		a1,(a0)+
		adda.l		d5,a1
		move.l		a1,(a0)+

		lea		Blitrport,a0		src
		move.l		window.rp,a1		dest
		moveq.l		#0,d0			srcX
		moveq.l		#0,d1			srcY
		move.l		#200,d2			destX
		moveq.l		#16,d3			destY
		moveq.l		#16,d4			pixel width
		moveq.l		#16,d5			line height
		move.l		#$c0,d6			minterm, D=A
		CALLGRAF	ClipBlit
		
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
layername	dc.b		'layers.library',0
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

; Window defs for a SuperBitMap window ... Hello Layers!!!

MyWindow	dc.w	150,55		window XY origin
		dc.w	165,94		window width and height
		dc.b	0,1		detail and block pens
		dc.l	NEWSIZE+GADGETDOWN+GADGETUP+CLOSEWINDOW+INTUITICKS   IDCMP
		dc.l	WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+SUPER_BITMAP+GIMMEZEROZERO+NOCAREREFRESH	other window flags
		dc.l	0		first gadget in gadget list
		dc.l	0		custom CHECKMARK imagery
		dc.l	.WindowName	window title
		dc.l	0		custom screen pointer
		dc.l	0		custom bitmap
		dc.w	20,20		minimum width and height
		dc.w	800,600		maximum width and height
		dc.w	WBENCHSCREEN	destination screen type

.WindowName	dc.b	"Yo, Baby! We've gone SuperBitMap",0
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

.Text		dc.b		'Zippy',0	the text itself
		even

returnMsg	dc.l		0		DEBUG ONLY


;BitMap structure to use

Blitmap		dc.w		0		2 bytes per row
		dc.w		0		16 rows
		dc.b		0,0
		dc.w		0
		ds.l		8		space for plane pointers

Blitrport	ds.b		rp_SIZEOF

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_args		ds.l		1		CLI Parameter Details
_argslen	ds.l		1

_DOSBase	ds.l		1		Library Base Pointers
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1
_LayersBase	ds.l		1		

MyBitMap	ds.l		1		-> BitMap structure
RasterSize	ds.w		1		byte size of playfield

window.ptr	ds.l		1		-> Window structure
window.rp	ds.l		1		-> windows RastPort structure
window.up	ds.l		1		-> windows UserPort structure
window.lyr	ds.l		1		-> windows Layers structure

STD_OUT		ds.l		1		Output file handle


		section		dummgfx,data_c

plane1		dc.w		$ffff		1
		dc.w		$8001		2
		dc.w		$8001		3
		dc.w		$8001		4
		dc.w		$8001		5
		dc.w		$8001		6
		dc.w		$8001		7
		dc.w		$8001		8
		dc.w		$8001		9
		dc.w		$8001		10
		dc.w		$8001		11
		dc.w		$8001		12
		dc.w		$8001		13
		dc.w		$8001		14
		dc.w		$8001		15
		dc.w		$ffff		16

plane2		dc.w		$0000		1
		dc.w		$7ffe		2
		dc.w		$4002		3
		dc.w		$4002		4
		dc.w		$4002		5
		dc.w		$4002		6
		dc.w		$4002		7
		dc.w		$4002		8
		dc.w		$4002		9
		dc.w		$4002		10
		dc.w		$4002		11
		dc.w		$4002		12
		dc.w		$4002		13
		dc.w		$4002		14
		dc.w		$7ffe		15
		dc.w		$0000		16

plane3		dc.w		$0000		1
		dc.w		$0000		2
		dc.w		$3ffc		3
		dc.w		$2004		4
		dc.w		$2004		5
		dc.w		$2004		6
		dc.w		$2004		7
		dc.w		$2004		8
		dc.w		$2004		9
		dc.w		$2004		10
		dc.w		$2004		11
		dc.w		$2004		12
		dc.w		$2004		13
		dc.w		$3ffc		14
		dc.w		$0000		15
		dc.w		$0000		16

plane4		dc.w		$0000		1
		dc.w		$0000		2
		dc.w		$0000		3
		dc.w		$1ff8		4
		dc.w		$1008		5
		dc.w		$1008		6
		dc.w		$1008		7
		dc.w		$1008		8
		dc.w		$1008		9
		dc.w		$1008		10
		dc.w		$1008		11
		dc.w		$1008		12
		dc.w		$1ff8		13
		dc.w		$0000		14
		dc.w		$0000		15
		dc.w		$0000		16

plane5		dc.w		$0000		1
		dc.w		$0000		2
		dc.w		$0000		3
		dc.w		$0000		4
		dc.w		$0ff0		5
		dc.w		$0810		6
		dc.w		$0810		7
		dc.w		$0810		8
		dc.w		$0810		9
		dc.w		$0810		10
		dc.w		$0810		11
		dc.w		$0ff0		12
		dc.w		$0000		13
		dc.w		$0000		14
		dc.w		$0000		15
		dc.w		$0000		16



		section		Skeleton,code

***** Your code goes here!!
