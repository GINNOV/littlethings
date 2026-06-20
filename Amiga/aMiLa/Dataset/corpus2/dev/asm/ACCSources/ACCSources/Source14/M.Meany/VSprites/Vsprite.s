
; This program uses the Gels system to maintain a VSprite that follows
;the Intuition pointer around. The VSprite is updated whenever a MOUSEMOVE
;event is detected. INTUITICKS are used to control the animation.

; The program uses animtools.i, an assembly language equivalent of the file
;animtools.h from Page 484 of the RKM Libraries & Devices manual.

; Now added collision detection! VSprite changes colour if it hits the
;edge of the screen! 

; This program is an extension of the VSprite.c example from the ROM 
;Kernel Reference Manual, Libraries and devices Page 445. The extensions
;being:

;	1/ Workbench startup possible.
;	2/ Text printed in the window opened.
;	3/ VSprite movement controlled by MOUSEMOVE.
;	4/ CLI usage explanation given.

; This assembly version is 2800 bytes long, with all the extra stuff. The
;C version is 5372 bytes. A saving of 48%. The source is a little larger
;though!

; Space Invaders in an Intuition window coming soon !

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

		bsr		DoVSprite

		bsr		Closewin	close our window

no_libs		bsr		Closelibs	close open libraries

		rts				finish


DoVSprite	move.l		window.rp,a0	rastport
		moveq.l		#$fc,d0		reserved sprites
		jsr		SetUpGelSys	do initalisation
		move.l		d0,MyGelsInfo	store pointer
		beq		.error1		quit if error

		lea		MyNewVSprite,a0	internal structure def
		jsr		MakeVSprite	initalise it
		move.l		d0,MyVSprite	store pointer
		beq		.error2		quit if error

		move.l		d0,a0		VSprite
		move.w		#20,vs_SUserExt(a0)
		move.w		#1<<BORDERHIT,vs_HitMask(a0)
		move.l		#BORDERHIT,d0
		lea		BorderCheck,a0
		move.l		window.rp,a1
		move.l		rp_GelsInfo(a1),a1
		CALLGRAF	SetCollision

		move.l		MyVSprite,a0
		move.l		window.rp,a1	rastport
		CALLSYS		AddVSprite	and add it

		bsr		VSpriteDrawGList display it

		bsr		WaitForMsg

		move.l		MyVSprite,a0
		CALLGRAF	RemVSprite

		move.l		MyVSprite,a0
		jsr		FreeVSprite

.error2		jsr		VSpriteDrawGList

		move.l		window.rp,a0
		jsr		CleanUpGelSys

.error1		rts

MyGelsInfo	dc.l		0
MyVSprite	dc.l		0

MyNewVSprite	dc.l		VSData
		dc.l		VSColours
		dc.w		1
		dc.w		4
		dc.w		2
		dc.w		160
		dc.w		100
		dc.w		1		VSPRITE

VSpriteDrawGList move.l		window.rp,a1
		CALLGRAF	SortGList

		move.l		window.rp,a1
		move.l		window.vp,a0
		CALLSYS		DrawGList

		CALLINT		RethinkDisplay

		rts

BorderCheck	cmp.l		#RIGHTHIT,d0
		bne.s		.no_hit
		move.l		#SpriteAltColours,vs_SprColors(a3)
		move.w		#-40,vs_SUserExt(a3)
		bra		.done

.no_hit		cmp.l		#LEFTHIT,d0
		bne.s		.done
		move.l		#VSColours,vs_SprColors(a3)
		move.w		#20,vs_SUserExt(a3)

.done		rts

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
		moveq.l		#0,d3
		move.l		d3,d4
		move.w		im_MouseX(a1),d3
		move.w		im_MouseY(a1),d4
		CALLSYS		ReplyMsg	answer os or it get angry

		cmp.l		#MOUSEMOVE,d2
		bne.s		.test_tick
		moveq.l		#0,d0			x
		move.l		d0,d1			y
		move.l		window.ptr,a0
		move.w		wd_LeftEdge(a0),d0
		move.w		wd_TopEdge(a0),d1
		add.l		d3,d0
		add.l		d4,d1
		move.l		MyVSprite,a0
		move.w		vs_SUserExt(a0),d3
		add.l		d3,d0
		move.w		d0,vs_X(a0)
		add.l		#1,d1
		move.w		d1,vs_Y(a0)

		bra		.jumper

.test_tick	cmp.l		#INTUITICKS,d2
		bne.s		.test_win
		move.l		MyVSprite,a0
		move.l		SprSwap,a1
		move.l		vs_ImageData(a0),SprSwap
		move.l		a1,vs_ImageData(a0)
.jumper		move.l		window.rp,a1
		CALLGRAF	SortGList
		move.l		window.rp,a1
		CALLSYS		DoCollision
		jsr		VSpriteDrawGList
		bra		WaitForMsg

.test_win	cmp.l		#CLOSEWINDOW,d2  window closed ?
		bne		WaitForMsg	 if not then jump
		rts


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

; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		'This small program demonstrates use of the Gels system to move a true VSprite'
		dc.b		$0a
		dc.b		'Basic animation and collision detection are enabled!'
		dc.b		$0a
		dc.b		' By M.Meany, June 1991, from a C program on p.445 of RKM Libs & Devs.'
		dc.b		$0a,0
		even

;***********************************************************
;	Window and Gadget defenitions
;***********************************************************


MyWindow	dc.w		80,20
		dc.w		400,150
		dc.b		-1,-1
		dc.l		CLOSEWINDOW+MOUSEMOVE+INTUITICKS
		dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH+REPORTMOUSE
		dc.l		0		;gadgets
		dc.l		0
		dc.l		WindowName
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

WindowName	dc.b		' VSprite by M.Meany. © CBM Oct 89. ',0
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

.Text		dc.b		'This sprite is controlled by the Gels system.',0
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

.Text		dc.b		'The sprite will follow the mouse pointer',0
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

.Text		dc.b		'and change colour at the edge of the screen.',0
		even


SprSwap		dc.l		VSData1

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

VSData	dc.w	$7ffe,$80ff,$7c3e,$803f,$7c3e,$803f,$7ff3,$80ff

VSData1 dc.w	$7ffe,$ff01,$7c3e,$fc01,$7c3e,$fc01,$7ffe,$ff01

VSColours	dc.w	$0,$f0,$f00
		even
SpriteAltColours dc.w	$f,$f00,$ff0

		section		Skeleton,code

		include		animtools.s
