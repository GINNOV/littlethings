
; This program demonstrates use of a bob controlled by the Gels system. The
;bob is animated and will follow the mouse around it's window.

; The program uses animtools.i, an assembly language equivalent of the file
;animtools.h from Page 484 of the RKM Libraries & Devices manual.

; The large 'hagar' bob moving under MOUSEMOVE messages

; © M.Meany, June 1991.

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
		include		graphics/gels.i

CALLSYS		macro
		ifgt	NARG-1
		FAIL	!!!
		endc
		jsr	_LVO\1(a6)
		endm

GEL_SIZE	equ	70

		section		Skeleton,code

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"

		move.l		a0,_args	save addr of CLI args
		move.l		d0,_argslen	and the length

		bsr		Openlibs	open libraries
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

		bsr		Init		Initialise data
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

		bsr		Openwin		open window
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

		bsr		do_bob		deal with bob interaction

		bsr		Closewin	close our window

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
		CALLSYS		OpenLibrary	and open it
		move.l		d0,_IntuitionBase	save base ptr
		beq.s		.lib_error	quit if error

		lea		gfxname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLSYS		OpenLibrary	and open it
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

		CALLSYS		ViewPortAddress	get addr of vp
		move.l		d0,window.vp	and save it

;--------------	Display basic usage text for user

		move.l		window.rp,a0	a0->windows RastPort
		lea		WinText,a1	a1->IText structure
		moveq.l		#10,d0		X offset
		moveq.l		#15,d1		Y offset
		CALLSYS		PrintIText	print this text

		moveq.l		#1,d0		ensure no errors

.win_error	rts				all done so return

*************** Deal with the bob

; First set up a GelsInfo structure and attach it to the RastPort.
; The subroutine SetUpGelSys does all this!

do_bob		move.l		window.rp,a0	a0->RastPort
		moveq.l		#$fc,d0		d0=SprRsvd
		jsr		SetUpGelSys	init a GelsInfo struct
		move.l		d0,MyGelsInfo	save pointer
		beq		.error		leave if error

; Now set up a bob structure. The bob defenition is held in a NewBob
;structure found in the data section at the end of this code. The subroutine
;MakeBob creates a Bob structure and links a VSprite structure to this all 
;from the data held in the NewBob structure.

		lea		MyNewBob,a0	a0->NewBob structure
		jsr		MakeBob		set up the Bob structure
		move.l		d0,MyBob	save pointer
		beq		.error1		quit if error

; We must now add the Bob to the Gels system ie attach it to the RastPort.

		move.l		d0,a0		a0->Bob
		move.l		window.rp,a1	a1->ViewPort
		CALLGRAF	AddBob		and add to gel list

; We can now draw the Bob into the display. The subroutine BobDrawGList
;does just that.

		bsr		BobDrawGList	draw the sprite

; Time to interact with the user, so call the subroutine that monitors
;and acts on Intuition messages.

		bsr		WaitForMsg	deal with interaction

; We only get this far if the user has clicked on the windows close gadget
;and wants the program to quit! Remove the Bob from the gels list.

		move.l		MyBob,a0	a0->Bob structure
		move.l		window.rp,a1	a1->RastPort
		move.l		window.vp,a2	a2->ViewPort
		
		CALLGRAF	RemIBob		and remove it

; By calling BobDrawGList, the Bob will be removed from the display. It is
;not enough to simply take it out of the list!

		bsr		BobDrawGList	clear bob from display

; Time to release all that lovley memory that the Bob is tying up. Note that
;the subroutine FreeBob requires the raster depth to be supplied. This should
;be the same as that set in the NewBobStruct.

		moveq.l		#0,d0			clear register
		lea		MyNewBob,a0		a0->NewBob struct
		move.w		nb_RasDepth(a0),d0	d0=raster depth
		move.l		MyBob,a0		a0->Bob struct
		jsr		FreeBob			release resources

; Now we can release all the memory that the Gels system has tied up.

.error1		move.l		window.rp,a0		a0->RastPort
		jsr		CleanUpGelSys		release resources

; That's about the lot, so return to calling routine.

.error		rts

*************** Close the Intuition window.

Closewin	move.l		window.ptr,a0	a0->Window struct
		CALLINT		CloseWindow	and close it
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
		CALLSYS		CloseLibrary		close lib

		move.l		_GfxBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLSYS		CloseLibrary		close lib

.lib_error	rts


*************** Deal with User interaction

; Rather than use Wait() as in the RKM, I am sticking to my old friend
;WaitPort() to monitor Intuition messages.

WaitForMsg	move.l		window.up,a0	a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		window.up,a0	a0-->window pointer
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WaitForMsg	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.l		im_IAddress(a1),a5 a5=addr of structure
		moveq.l		#0,d3
		move.l		d3,d4
		move.w		im_MouseX(a1),d3 get X position of mouse
		move.w		im_MouseY(a1),d4 get Y position of mouse
		CALLSYS		ReplyMsg	answer os or it get angry

; See if a MOUSEMOVE message was received.

		cmp.l		#MOUSEMOVE,d2
		bne.s		.test_win

; Yep ! it's a MOUSEMOVE, update the sprites position.

		add.l		#20,d3		+20 onto MouseX
		addq.l		#1,d4		+1 onto MouseY
		move.l		MyBob,a0	a0->Bob struct
		move.l		bob_BobVSprite(a0),a0 a0->Bobs VSprite struct
		move.w		d3,vs_X(a0)	update X position
		move.w		d4,vs_Y(a0)	update Y position

		CALLGRAF	InitMasks
		bsr		BobDrawGList
		bra		WaitForMsg

.test_win	cmp.l		#CLOSEWINDOW,d2  window closed ?
		bne		WaitForMsg	 if not then jump
		rts

***************	Draw all elements in current gel list.

BobDrawGList	move.l		window.rp,a1	a1->RastPort
		CALLGRAF	SortGList	sort the gels

		move.l		window.rp,a1	a1->RastPort
		move.l		window.vp,a0	a0->ViewPort
		CALLSYS		DrawGList	draw all gels in list

		CALLSYS		WaitTOF		wait for vert blank

		rts

*****************************************************************************
*			Useful Subroutines Section					    *
*****************************************************************************

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


*****************************************************************************
*			Data Section					    *
*****************************************************************************

dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even
gfxname		dc.b		'graphics.library',0
		even

; The NewBob structure

MyNewBob	dc.l		SprDat1
		dc.w		8		word width
		dc.w		GEL_SIZE	line height
		dc.w		2		image depth
		dc.b		3		plane pick
		dc.b		0		plane on off
		dc.w		VSF_SAVEBACK!VSF_OVERLAY  VSprite flags
		dc.w		0		dbuf ( not double bufferd )
		dc.w		2		raster depth ( WBench )
		dc.w		160		X position
		dc.w		100		Y position

;ImageSwap	dc.l		SprDat2		image swapping buffer
MyGelsInfo	dc.l		0
MyBob		dc.l		0

; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		'This small program demonstrates use of the Gels system to move a Bob.'
		dc.b		$0a
		dc.b		'Basic animation is enabled!'
		dc.b		$0a
		dc.b		' By M.Meany, June 1991, from a C program on p.461 of RKM Libs & Devs.'
		dc.b		$0a,0
		even

;***********************************************************
;	Window and Gadget defenitions
;***********************************************************


MyWindow	dc.w		80,100
		dc.w		400,150
		dc.b		-1,-1
		dc.l		CLOSEWINDOW+MOUSEMOVE
		dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH+REPORTMOUSE
		dc.l		0		;gadgets
		dc.l		0
		dc.l		WindowName
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

WindowName	dc.b		' Bob by M.Meany. © CBM Oct 89. ',0
		even


WinText		dc.b		1		FrontPen
		dc.b		0		BackPen
		dc.b		RP_JAM2		DrawMode
		dc.b		0		KludgeFill00
		dc.w		0		x position
		dc.w		0		y position
		dc.l		0		font
OurText		dc.l		.Text		address of text to print
		dc.l		WinText1	no more text

.Text		dc.b		'This bob is controlled by the Gels system.',0
		even

WinText1	dc.b		1		FrontPen
		dc.b		0		BackPen
		dc.b		RP_JAM2		DrawMode
		dc.b		0		KludgeFill00
		dc.w		0		x position
		dc.w		10		y position
		dc.l		0		font
		dc.l		.Text		address of text to print
		dc.l		WinText2		no more text

.Text		dc.b		'The bob will follow the mouse pointer',0
		even

WinText2	dc.b		1		FrontPen
		dc.b		0		BackPen
		dc.b		RP_JAM2		DrawMode
		dc.b		0		KludgeFill00
		dc.w		0		x position
		dc.w		20		y position
		dc.l		0		font
		dc.l		.Text		address of text to print
		dc.l		0		no more text

.Text		dc.b		'within the bounds of the window.',0
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
window.vp	ds.l		1

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

;SprDat1	dc.w	$ffff,$0003,$fff0,$0003,$fff0,$0003,$ffff,$0003
;	dc.w	$3fff,$fffc,$3ff0,$0ffc,$3ff0,$0ffc,$3fff,$fffc
;SprDat2	dc.w	$c000,$ffff,$c000,$0fff,$c000,$0fff,$c000,$ffff
;	dc.w	$3fff,$fffc,$3ff0,$0ffc,$3ff0,$0ffc,$3fff,$fffc


; Bob data. Hagar the Horrible, 128*70*2

SprDat1	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00003,32768,00000,00000,00000,00000,00000,00000
	dc.w	00031,57344,00000,00000,00000,00000,00056,00000
	dc.w	00063,57344,00000,00000,00000,00000,00255,00000
	dc.w	00127,57344,00000,00000,00000,00000,00255,32768
	dc.w	00127,57344,00000,00000,00000,00000,00255,49152
	dc.w	00255,57344,00000,00000,00000,00000,00255,49152
	dc.w	00255,57344,00000,00000,00000,00000,00255,57344
	dc.w	00511,57344,00000,00000,00000,00000,00255,57344
	dc.w	00511,57344,00000,00000,00000,00000,00255,61440
	dc.w	01023,61440,00000,00000,00000,00000,00255,61440
	dc.w	01023,63488,00000,00000,00000,00000,00511,63488
	dc.w	01023,63488,00000,00000,00000,00000,01023,63488
	dc.w	01023,64512,00000,00000,00000,00000,01023,63488
	dc.w	01023,64512,00000,00000,00000,00000,02047,63488
	dc.w	01023,65024,00000,00000,00000,00000,02047,63488
	dc.w	01023,65280,00000,00000,00000,00000,04095,63488
	dc.w	00511,65408,00000,00000,00000,00000,08191,63488
	dc.w	00511,65504,00000,00000,00000,00000,16383,61440
	dc.w	00511,65535,64512,00000,00000,00000,65535,61440
	dc.w	00255,65535,63488,00000,00000,00511,65535,61440
	dc.w	00255,65535,61440,00000,00000,00255,65535,57344
	dc.w	00127,65535,57344,00000,00000,00127,65535,57344
	dc.w	00063,65535,49152,00000,00000,00063,65535,49152
	dc.w	00031,65535,49152,00000,00000,00063,65535,32768
	dc.w	00007,65535,32768,00000,00000,00031,65535,00000
	dc.w	00000,16383,32768,00000,00000,00015,65532,00000
	dc.w	00000,00000,00000,00000,00000,00007,65408,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,65535,65535,65535,65532,00000,00000
	dc.w	00000,00001,65535,65535,65535,65532,00000,00000
	dc.w	00000,00007,65535,65535,65535,65534,00000,00000
	dc.w	00000,00007,65535,65423,51199,65535,00000,00000
	dc.w	00000,00007,65535,65287,33791,65535,00000,00000
	dc.w	00000,00007,65535,65535,65535,65535,00000,00000
	dc.w	00000,00027,65535,65535,65535,65534,32768,00000
	dc.w	00000,00061,65535,65408,01023,65533,57344,00000
	dc.w	00000,00126,65535,63488,00063,65531,63488,00000
	dc.w	00000,00255,16383,57344,00015,65511,65024,00000
	dc.w	00000,00511,53247,32768,00003,65439,65280,00000
	dc.w	00000,01023,61695,00000,00001,63615,65408,00000
	dc.w	00000,04081,65280,00000,00000,02047,65472,00000
	dc.w	00000,16335,65534,00000,00000,65535,65504,00000
	dc.w	00000,32671,65023,00000,00001,65473,65504,00000
	dc.w	00000,32639,62463,32768,00003,65532,08176,00000
	dc.w	00000,32511,59391,57344,00015,65535,59376,00000
	dc.w	00000,32255,53247,63488,00063,65535,63984,00000
	dc.w	00000,31743,57343,49024,01023,32767,65520,00000
	dc.w	00000,32767,40959,65533,65535,16383,65504,00000
	dc.w	00000,16383,16383,49149,65535,49151,65280,00000
	dc.w	00000,04094,32767,65534,65535,49151,65408,00000
	dc.w	00000,01022,65528,08190,65535,40959,65024,00000
	dc.w	00000,00508,65408,08191,32767,53247,63488,00000
	dc.w	00000,00125,64512,16383,32767,61439,61440,00000
	dc.w	00000,00031,64512,32767,32767,61439,00000,00000
	dc.w	00000,00001,32258,65535,49151,65528,00000,00000
	dc.w	00000,00000,04094,65535,49151,65280,00000,00000
	dc.w	00000,00000,01023,65535,49148,00000,00000,00000
	dc.w	00000,00000,00031,65535,48128,00000,00000,00000
	dc.w	00000,00000,00001,65534,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,16384,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000

	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00003,32768,00000,00000,00000,00000,00000,00000
	dc.w	00028,24576,00000,00000,00000,00000,00056,00000
	dc.w	00096,04096,00000,00000,00000,00000,00199,00000
	dc.w	00064,04096,00000,00000,00000,00000,00256,49152
	dc.w	00128,04096,00000,00000,00000,00000,00256,16384
	dc.w	00128,04096,00000,00000,00000,00000,00256,08192
	dc.w	00256,04096,00000,00000,00000,00000,00256,08192
	dc.w	00256,04096,00000,00000,00000,00000,00256,04096
	dc.w	00512,04096,00000,00000,00000,00000,00256,04096
	dc.w	00512,04096,00000,00000,00000,00000,00256,02048
	dc.w	01024,02048,00000,00000,00000,00000,00256,02048
	dc.w	01024,01024,00000,04095,65024,00000,00512,01024
	dc.w	01024,01024,00000,32767,65472,00000,01024,01024
	dc.w	01024,00512,00003,49151,65520,00000,01024,01024
	dc.w	01024,00512,00015,65535,65532,00000,02048,01024
	dc.w	01024,00256,00031,65535,65535,00000,02048,01024
	dc.w	01024,00128,00127,65535,65535,32768,04096,01024
	dc.w	00512,00096,00255,65535,65535,57344,08192,01024
	dc.w	00512,00031,65535,65535,65535,61440,49152,02048
	dc.w	00512,00000,01023,65535,65535,65535,00000,02048
	dc.w	00256,00000,02047,65535,65535,65024,00000,02048
	dc.w	00256,00000,04095,65535,65535,65280,00000,04096
	dc.w	00384,00000,08191,65535,65535,65408,00000,04096
	dc.w	00064,00000,16383,65535,65535,65472,00000,12288
	dc.w	00096,00000,16383,65535,65535,65472,00000,16384
	dc.w	00024,00000,32767,65535,65535,65504,00000,49152
	dc.w	00007,49152,32767,65535,65535,65520,00003,00000
	dc.w	00000,16383,65535,65535,65535,65528,00124,00000
	dc.w	00000,00000,65535,65535,65535,65535,65408,00000
	dc.w	00000,00000,65535,65535,65535,65532,00000,00000
	dc.w	00000,00000,65535,65535,65535,65532,00000,00000
	dc.w	00000,00000,65535,65535,65535,65532,00000,00000
	dc.w	00000,00003,00000,00000,00000,00002,00000,00000
	dc.w	00000,00006,00000,00000,00000,00003,00000,00000
	dc.w	00000,00008,00000,00000,00000,00001,32768,00000
	dc.w	00000,00008,00000,00000,00000,00000,32768,00000
	dc.w	00000,00008,00000,00000,00000,00000,32768,00000
	dc.w	00000,00024,00000,00000,00000,00000,32768,00000
	dc.w	00000,00060,00000,00000,00000,00001,57344,00000
	dc.w	00000,00126,00000,00127,64512,00003,63488,00000
	dc.w	00000,00255,00000,01920,00960,00007,65024,00000
	dc.w	00000,00511,49152,06144,00048,00031,65280,00000
	dc.w	00000,01023,61440,24576,00012,00127,65408,00000
	dc.w	00000,04095,65280,32768,00002,02047,65472,00000
	dc.w	00000,16383,65535,00000,00001,65535,65504,00000
	dc.w	00000,32767,65535,00000,00001,65535,65520,00000
	dc.w	00000,65535,65535,32768,00003,65535,65520,00000
	dc.w	00000,65535,65535,57344,00015,65535,65528,00000
	dc.w	00000,65535,65535,63488,00063,65535,65528,00000
	dc.w	00000,65535,65535,65408,01023,65535,65528,00000
	dc.w	00000,65535,65535,65535,65535,65535,65528,00000
	dc.w	00000,65535,65535,65535,65535,65535,65520,00000
	dc.w	00000,32767,65535,65535,65535,65535,65504,00000
	dc.w	00000,16383,65535,65535,65535,65535,65504,00000
	dc.w	00000,04095,65535,65535,65535,65535,65408,00000
	dc.w	00000,01023,65535,65535,65535,65535,65024,00000
	dc.w	00000,00511,65535,65535,65535,65535,63488,00000
	dc.w	00000,00127,65535,65535,65535,65535,63488,00000
	dc.w	00000,00031,65535,65535,65535,65535,00000,00000
	dc.w	00000,00001,65535,65535,65535,65528,00000,00000
	dc.w	00000,00000,04095,65535,65535,65280,00000,00000
	dc.w	00000,00000,01023,65535,65532,00000,00000,00000
	dc.w	00000,00000,00031,65535,64512,00000,00000,00000
	dc.w	00000,00000,00001,65534,16384,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000



		section		Skeleton,code

		include		animtools.s
