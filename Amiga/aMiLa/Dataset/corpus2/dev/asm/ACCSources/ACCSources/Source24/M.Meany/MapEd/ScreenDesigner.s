
*****	Title		Level Editor
*****	Function	To design data files for game screens consisting of
*****			16x16 blocks. Each block may also have a collision
*****			mask assosiated and saved with it.
*****			
*****	Size		16532 bytes
*****	Author		Mark Meany
*****	Date Started	May 92
*****	This Revision	May 92

*****	Notes		Always shows screen being designed in LoRes
*****			

*****			Added Load/Save of blocks with/without masks in
*****			- interleaved or consecutive format.

*****			Added file load/save window

*****			Added mask editor

*****			Uses custom port for IDCMP communication
*****			Block selection enabled
*****			Hold down LMB to move screen cursor
*****			Hold down RMB to move cursor and draw blocks
*****			SuperBitMap scrolling enabled
*****			Startup window added to allow entry of W, H and D
*****			Added some simple Load/Save routines
*****			Added option to grab blocks from an IFF file
*****			-nb this also grabs the palette

*****			Axal - it's a start anyway!
*****			Paul - any use to you?

*****	Credits		Steve Marshall - IFF ILBM loader
*****			Dave Edwards   - Port creation routines



	incdir	sys:include/
;	incdir	df2:
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


_LVOScrollLayer	equ		-72

BuffSize	equ		7000		ILBM load buffer

; Variable offsets

		rsreset
BMEwin.ptr	rs.l		1		window 
BMEwin.rp	rs.l		1		window RastPort
BMEwin.up	rs.l		1		window IDCMP port
BMEAddr		rs.l		1		address of original mask
MaskBits	rs.w		16		buffer for copy of mask
StoredMask	rs.w		16		buffer for saved mask
SetBit		rs.l		1		flag set if setting mask
ClrBit		rs.l		1		flag set if clearing mask

_args		rs.l		1		CLI Parameter Details
_argslen	rs.l		1

MyBitMap	rs.l		1		-> BitMap structure
RasterSize	rs.w		1		byte size of playfield

_Width		rs.l		1		width of bitplane in pixels
_Height		rs.l		1		height of bitplane in pixels
_Depth		rs.l		1		number of bitplanes

screen.ptr	rs.l		1		-> Screen structure
screen.vp	rs.l		1		-> ViewPort structure

MyPort		rs.l		1		-> Shared port for IDCMP

window.ptr	rs.l		1		-> Window structure
window.rp	rs.l		1		-> windows RastPort structure
window.up	rs.l		1		-> windows UserPort structure
window.lyr	rs.l		1		-> windows Layers structure

Edwin.ptr	rs.l		1		-> Window structure
Edwin.rp	rs.l		1		-> windows RastPort

Moving		rs.l		1		flag set when LMB held down
Drawing		rs.l		1		flag set when RMB held down

MaskFlag	rs.l		1		set to include masks
ModeFlag	rs.l		1		set for interleaved

SprNum		rs.l		1		number of allocated sprite

OffsetX		rs.w		1		offset to UL block displayed
OffsetY		rs.w		1

MaxOffsetX	rs.w		1		maximum scrolled values
MaxOffsetY	rs.w		1
CurX		rs.w		1		position of screen cursor
CurY		rs.w		1

STD_OUT		rs.l		1		Output file handle

; Screen data buffer consists of 1 byte for each block contained in the
;screen.

Scrn		rs.l		1		-> allocated screen buffer
ScrnSize	rs.l		1		size of allocated buffer

; Block data buffer is large enough to contain 256 blocks of the depth
;specified. Also, each block is followed by a 1 bitplane collision mask.

Blocks		rs.l		1		-> allocated block buffer
BlockSize	rs.l		1		size of allocated buffer

; Following two variables are used to control gadget image selection and
;rendering.

TopBlock	rs.l		1		number of UL block 0->220 +10
ThisBlock	rs.l		1		-> Data for selected block
ThisBlockNum	rs.l		1		number of selected block

IFFStruct	rs.l		1		structure for loaded ILBM
IFFHandle	rs.l		1		files handle

SaveBuff	rs.b		16*2*6		save buffer

FileBuffer	rs.l		200		filename buffer

varSize		rs.l		0		size of variables block


CALLSYS		macro
		ifgt	NARG-1
		FAIL	!!!
		endc
		jsr	_LVO\1(a6)
		endm

CALLLAYERS	macro
		move.l		_LayersBase,a6
		jsr		_LVO\1(a6)
		endm

		section		Skeleton,code

; Include easystart to allow a Workbench startup.

;		include		"misc/easystart.i"

		lea		Vars,a4			a4->variable memory

		move.l		a0,_args(a4)		save addr of CLI args
		move.l		d0,_argslen(a4)		and the length

		bsr.s		Openlibs		open libraries
		tst.l		d0			any errors?
		beq.s		no_libs			if so quit

		bsr		Usage			check for usage req
		tst.l		d0			any errors?
		beq.s		no_libs			if so quit

		bsr		GetSize			determine dimensions
		tst.l		d0			any errors
		beq.s		no_libs			if so quit

		bsr		Init			allocate buffers
		tst.l		d0			any errors
		beq.s		no_scrn			exit if so

		bsr		Openscrn		open custom screen
		tst.l		d0			errors?
		beq.s		no_scrn			if so exit

		bsr		Openwin			SuperBitMap window
		tst.l		d0			any errors?
		beq.s		no_win			if so quit

		bsr		WaitForMsg		wait for user

		bsr		Closewin		close window

no_win		bsr		Closescrn		close custom screen

no_scrn		bsr		DeInit			free resources

no_libs		bsr		Closelibs		close open libraries

		rts					finish


;**************	Open all required libraries

; Open DOS, Intuition, Graphics and Layers libraries.

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

		lea		layername,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_LayersBase		save base ptr

.lib_error	rts

*************** Initialise any data

;--------------	At present just set STD_OUT and check for usage text

Usage		tst.l		returnMsg		from WorkBench?
		bne.s		.ok			if so ignore usage

		CALLDOS		Output			determine CLI handle
		move.l		d0,STD_OUT(a4)		and save it for later
		beq.s		.err			quit if no handle

		move.l		_args(a4),a0		get addr of CLI args
		cmpi.b		#'?',(a0)		is the first arg a ?
		bne.s		.ok			if not skip next bit

		lea		_UsageText,a0		a0->the usage text
		bsr		DosMsg			and display it
.err		moveq.l		#0,d0			set an error
		bra.s		.error			and finish

.ok		moveq.l		#1,d0			no errors

.error		rts					back to main

***************	Get dimensions of screen to be designed

; In finished version this will be a `preferences` window.

GetSize		bsr		DoSetupWin		get screen dimensions
		tst.l		d0			any errors
		beq		.error			exit if so!

; Set depth in Image structure used to render blocks into screen and gadgets

		lea		BlockImage,a0
		move.w		_Depth+2(a4),ig_Depth(a0) set Image depth

; Set maximum scrolling offset for SuperBitMap window

		move.l		_Width(a4),d0		bitplane width
		asr.l		#4,d0			/16 = block width
		sub.l		#20,d0			- window width
		move.w		d0,MaxOffsetX(a4)	set max X scroll val
		
		move.l		_Height(a4),d0		bitplane height
		asr.l		#4,d0			/16 = block height
		sub.l		#12,d0			- window height
		move.w		d0,MaxOffsetY(a4)	set max Y scroll val


		moveq.l		#1,d0
.error		rts

***************	Allocate required buffers

; Get a buffer for the block graphics

Init		move.l		_Depth(a4),d0		block depth
		addq.l		#1,d0			allow for mask data
		asl.l		#5,d0			x32 bytes per plane
		asl.l		#8,d0			x256 blocks
		move.l		d0,BlockSize(a4)	save size
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1 requirements
		CALLEXEC	AllocMem		request buffer
		move.l		d0,Blocks(a4)		save pointer
		move.l		d0,ThisBlock(a4)
		beq.s		.error			exit if not allcated

;################ Development only - blocks will have to be loaded from disk
;
;		lea		DummyBlocks,a0		source
;		move.l		d0,a1			dest
;		move.l		#DummySize,d0		size
;		CALLEXEC	CopyMem			copy blocks to buffer
;
;################

; Get buffer for the screen map

		move.l		_Width(a4),d0		pixel width of screen
		asr.l		#4,d0			/block width
		move.l		_Height(a4),d1		pixel height of scrn
		asr.l		#4,d1			/block height
		mulu		d1,d0			d0=num blocks
		move.l		d0,ScrnSize(a4)		save size
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1 requirements
		CALLSYS		AllocMem		get buffer
		move.l		d0,Scrn(a4)		save pointer
		beq.s		.error			exit if not allocated

; No errors, so set a return value

		moveq.l		#1,d0			no errors

.error		rts

***************	Open an Intuition Custom Screen

Openscrn	lea		MyScreen,a0		NewScreen struct

		move.w		_Depth+2(a4),ns_Depth(a0) set screen depth

		CALLINT		OpenScreen		open it
		move.l		d0,screen.ptr(a4)	save pointer
		beq		.error			quit if error
		
		move.l		d0,a0			a0->Screen struct
		lea		sc_ViewPort(a0),a0	a0->ViewPort
		move.l		a0,screen.vp(a4)	save this pointer
		
; write the screen pointer into the NewWindow structures

		lea		MyWindow,a1		a1->NewWindow struct
		move.l		d0,nw_Screen(a1)	attach to window

		lea		EdWindow,a1		a1->NewWindow struct
		move.l		d0,nw_Screen(a1)	attach to window

; Set up colours for screen, a0->ViewPort already.

		move.l		_Depth(a4),d1		d1=depth of screen
		moveq.l		#1,d0			init colour count
		asl.l		d1,d0			calc colours
		lea		Palette,a1		a1->colour map
		CALLGRAF	LoadRGB4		set colours

; Set up a Simple Sprite for use as a screen cursor

		moveq.l		#4,d0			get sprite 4
		lea		Sprite,a0		SimpleSprite struct
		CALLGRAF	GetSprite		get a sprite
		move.l		d0,SprNum(a4)		save sprite number
		bpl.s		.GotSprite		skip if ok

; Could not get sprite so kill screen and exit!

		move.l		screen.ptr(a4),a0	a0->screen struct
		CALLINT		CloseScreen		close it
		bra		.error

; Set colours for the sprite -- NOTE these colours may be overwritten!

.GotSprite	move.l		screen.vp(a4),a0	ViewPort
		moveq.l		#25,d0			colour register
		moveq.l		#$f,d1			Red
		moveq.l		#$f,d2			Green
		moveq.l		#$f,d3			Blue
		CALLSYS		SetRGB4			colour1 = White

		move.l		screen.vp(a4),a0	ViewPort
		moveq.l		#26,d0			colour register
		moveq.l		#$c,d1			Red
		moveq.l		#$0,d2			Green
		moveq.l		#$0,d3			Blue
		CALLSYS		SetRGB4			colour2 = Red

		move.l		screen.vp(a4),a0	ViewPort
		moveq.l		#27,d0			colour register
		moveq.l		#$0,d1			Red
		moveq.l		#$0,d2			Green
		moveq.l		#$0,d3			Blue
		CALLSYS		SetRGB4			colour3 = Black
		
; display the sprites at initial positions

		move.l		screen.vp(a4),a0	ViewPort
		lea		Sprite,a1		SimpleSprite
		moveq.l		#-1,d0			x position
		moveq.l		#0,d1			y position
		CALLSYS		MoveSprite		move it


		moveq.l		#1,d0			no errors
.error		rts					and return


*************** Open Intuition Windows

; Opens an intuition window. If d0=0 on return then window could not be
;opened.

; 1st window is a SuperBitmap window. This is the map designer.
; 2nd window is a normal window containing control gadgets and block gfx.

; Both windows share the same port. Later when monitoring message arrivals,
;the address of the subroutine to call to handle a message is obtained
;from the wd_UserData field of the window structure.

Openwin		suba.l		a0,a0			no name, private port
		moveq.l		#5,d0			priority
		bsr		CreatePort		get a port
		move.l		d0,window.up(a4)	save pointer
		beq		.win_error		exit if none

		move.l		#bm_SIZEOF,d0		mem size
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1	requirements
		CALLEXEC	AllocMem		get some memory
		move.l		d0,MyBitMap(a4)		save address
		beq		.win_error		quit if error

; Now intialise the BitMap structure

		move.l		d0,a0			a0->BitMap structure
		move.l		_Depth(a4),d0		SuperBitmap depth
		move.l		_Width(a4),d1		SuperBitmap width
		move.l		_Height(a4),d2		SuperBitmap height
		CALLGRAF	InitBitMap		initialise structure

; Allocate memory for the bitplanes. I`ve opted for segmented playfields to
;allow the user more chance of getting the memory required. Trying to
;allocate one huge chunk may fail!

		move.l		_Depth(a4),d7		loop counter
		subq.l		#1,d7			adjust for dbra
		move.l		MyBitMap(a4),a3		a3->BitMap structure
		moveq.l		#0,d6			clear register
		move.w		bm_BytesPerRow(a3),d6	d6=bitplane byte width
		mulu.w		bm_Rows(a3),d6		d6=RastetSize
		move.w		d6,RasterSize(a4)	save for later

		lea		bm_Planes(a3),a3	a3->1st bitplane pointer
.allocplaneloop	move.l		d6,d0			size of memory
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1 requirements
		CALLEXEC	AllocMem		get some memory
		move.l		d0,(a3)+		addr in BitMap struct
		beq		.win_error		quit if error

		dbra		d7,.allocplaneloop	for all bitplanes

; If we get here, all bitplanes have been allocated. Attach the BitMap
;structure to the NewWindow structure.

		lea		MyWindow,a0		a0-> NewWindow struct
		move.l		MyBitMap(a4),nw_BitMap(a0) nw_BitMap field

; Now open the window.

		CALLINT		OpenWindow		and open it
		move.l		d0,window.ptr(a4)	save struct ptr
		beq		.win_error		quit if error

; Save important structure addresses

		move.l		d0,a0			  a0->win struct	
		move.l		window.up(a4),wd_UserPort(a0) init win port
		move.l		wd_RPort(a0),window.rp(a4)    save rp ptr
		move.l		window.rp(a4),a0	a0->RastPort struct
		move.l		rp_Layer(a0),a0	 	a0->Layers struct
		move.l		a0,window.lyr(a4)	save pointer

; Now set windows IDCMP values

		move.l		window.ptr(a4),a0	Window
		move.l		#RAWKEY+MOUSEBUTTONS+INTUITICKS,d0	IDCMP
		CALLINT		ModifyIDCMP

; Specify address of IDCMP service subroutine for this window

		move.l		window.ptr(a4),a0	Window
		move.l		#HandleTop,wd_UserData(a0) set routine addr

; Now open the editor window. Used to select block and other menus.

		lea		EdWindow,a0		NewWindow
		CALLINT		OpenWindow		and open it
		move.l		d0,Edwin.ptr(a4)	save struct ptr
		beq.s		.win_error		quit if error

; Save important structure addresses

		move.l		d0,a0			  a0->win struct	
		move.l		window.up(a4),wd_UserPort(a0) init win port
		move.l		wd_RPort(a0),Edwin.rp(a4)    save rp ptr

; Now set windows IDCMP values

		move.l		#GADGETDOWN+GADGETUP+RAWKEY,d0 IDCMP
		CALLINT		ModifyIDCMP

; Specify address of IDCMP service subroutine for this window

		move.l		Edwin.ptr(a4),a0	Window
		move.l		#HandleBot,wd_UserData(a0) set routine addr

; Display block gfx over gadgets

		bsr		SetGadgets

; Display active block

		bsr		ShowBlock

; Display title

		move.l		Edwin.rp(a4),a0		a0->windows RastPort
		lea		WinText,a1		a1->IText structure
		moveq.l		#0,d0			X offset
		moveq.l		#0,d1			Y offset
		CALLINT		PrintIText		print this text


.win_error	rts					all done so return

*************** Deal with User interaction

; At present only supports gadget selection. Address of routine to call
;when a gadget is selected should be stored in the gg_UserData field
;of that gadgets structure. All gadget/menu service subroutines should set
;d2=0 to ensure accidental QUIT is not forced. If a QUIT gadget is used
;it should set d2=CLOSEWINDOW.


WaitForMsg	move.l		window.up(a4),a0 	a0->user port
		CALLEXEC	WaitPort		wait for event
		move.l		window.up(a4),a0	a0->user port
		CALLSYS		GetMsg			get any messages
		tst.l		d0			was there a message ?
		beq.s		WaitForMsg		if not loop back
		move.l		d0,a1			a1->message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		move.w		im_Code(a1),d3		d3=mouse/key data
		move.l		im_IDCMPWindow(a1),a3	a3->Window
		move.l		wd_UserData(a3),a3	a3->subroutine
		move.l		im_IAddress(a1),a5	a5=addr of structure
		move.w		im_MouseX(a1),CurX(a4)	save mouse X position
		move.w		im_MouseY(a1),CurY(a4)	save mouse Y position
		CALLSYS		ReplyMsg		answer OS

		jsr		(a3)			call service routine

.test_win	cmp.l		#CLOSEWINDOW,d2  	window closed ?
		bne.s		WaitForMsg	 	if not then jump
		rts

*************** Deals with messages for top window - map designer

HandleTop	cmp.l		#RAWKEY,d2		keypress
		bne.s		.test_mouse		skip if not

		bra		.done

.test_mouse	cmp.l		#MOUSEBUTTONS,d2
		bne.s		.test_tick
		cmp.w		#SELECTDOWN,d3		LMB down
		bne.s		.try_LMBup
		move.l		#1,Moving(a4)		set flag
		bra		.done
.try_LMBup	cmp.w		#SELECTUP,d3		LMB up
		bne.s		.try_RMBdown
		move.l		#0,Moving(a4)		clear flag
		bra		.done
.try_RMBdown	cmp.w		#MENUDOWN,d3		RMB down
		bne.s		.try_RMBup
		move.l		#1,Drawing(a4)		set flag
		bra.s		.done
.try_RMBup	cmp.w		#MENUUP,d3		RMB up
		bne.s		.done
		move.l		#0,Drawing(a4)		clear flag
		bra.s		.done	

.test_tick	cmp.l		#INTUITICKS,d2
		bne.s		.done
		tst.l		Moving(a4)		flag set?
		beq.s		.try_draw
		bsr		DoMouseMove
		bra.s		.done
.try_draw	tst.l		Drawing(a4)		flag set?
		beq.s		.done
		bsr		SetBlock
		bsr		DoMouseMove

.done		rts

*************** Deals with messages for bottom window - editor control

HandleBot	move.l		d2,d0			copy flags
		and.l		#GADGETUP!GADGETDOWN,d0	gadget?
		beq.s		.test_key		skip if not
		move.l		gg_UserData(a5),a0	else get sub address
		cmpa.l		#0,a0			check not NULL
		beq.s		.done			skip if it is
		jsr		(a0)			call subroutine

.test_key	cmp.l		#RAWKEY,d2		keypress
		bne.s		.done			skip if not
		
		bra.s		.done

		nop
.done		rts

*************** Release SimpleSprite & close the Intuition window.
  
; Updated to deal with SuperBitMap windows. It is possible to progress quite
;some way into initialisation before, an error occurs. Best to check all
;possabilities and go from there! Closing/freing is done in reverse order
;to Opening/allocating where possible!!!

; Close the window

Closewin	CALLEXEC	Forbid

		move.l		window.ptr(a4),a0	a0->Window struct
		move.l		#0,wd_UserPort(a0)	clear port
		CALLINT		CloseWindow		and close it

		move.l		Edwin.ptr(a4),a0	a0->Window struct
		move.l		#0,wd_UserPort(a0)	clear port
		CALLINT		CloseWindow		and close it

		CALLEXEC	Permit
		
.loop		move.l		window.up(a4),a0	port
		CALLEXEC	GetMsg			any messages?
		tst.l		d0			check
		beq.s		.cont
		
		move.l		d0,a1			a1->message
		CALLEXEC	ReplyMsg		reply it
		bra.s		.loop

.cont		move.l		window.up(a4),a0	Port
		bsr		DeletePort		remove it

; Release bitplane pointers

		move.l		MyBitMap(a4),d6		d6->BitMap structure
		beq		.error			quit if not allocated

		move.l		d6,a5			a5->BitMap structure
		lea		bm_Planes(a5),a3	a3->1st bitplane
		move.l		_Depth(a4),d7		counter
		subq.l		#1,d7			adjust for dbra

.planeloop	moveq.l		#0,d0			clear register
		move.w		RasterSize(a4),d0	bytesize
		move.l		(a3)+,d1		d1->memoryBlock
		beq.s		.nextplane		skip if not allocated
		move.l		d1,a1			a1->memoryBlock
		CALLEXEC	FreeMem			and release it
.nextplane	dbra		d7,.planeloop		for all bitplanes

; Now release bitmap structure

		move.l		#bm_SIZEOF,d0		bytesize
		move.l		d6,a1			memoryBlock
		CALLEXEC	FreeMem			and release it

.error		rts

***************	Close the screen

Closescrn	move.l		SprNum(a4),d0		sprite num
		bmi		.FreeWin		skip if not allocated
		CALLGRAF	FreeSprite		release it

.FreeWin	move.l		screen.ptr(a4),a0	a0->screen struct
		CALLINT		CloseScreen		close it
		rts					and return

***************	Release any additional resources used

DeInit		move.l		Scrn(a4),d0		pointer to buffer
		beq.s		.T1			skip if NULL
		
		move.l		d0,a1			a1->buffer
		move.l		ScrnSize(a4),d0		buffer size
		CALLEXEC	FreeMem			release it

.T1		move.l		Blocks(a4),d0		pointer to buffer
		beq.s		.error			skip if NULL
		
		move.l		d0,a1			a1->buffer
		move.l		BlockSize(a4),d0	buffer size
		CALLEXEC	FreeMem			release it

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

		move.l		_LayersBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.lib_error	rts

*****************************************************************************
*			IDCMP Handlers					    *
*****************************************************************************

***************	Deal with mouse movements

DoMouseMove	moveq.l		#0,d0			clear
		moveq.l		#0,d1
		
		move.w		CurX(a4),d0		display X position
		and.w		#$fff0,d0		MOD 16
		subq.l		#1,d0
		move.w		d0,CurX(a4)		and save

		move.w		CurY(a4),d1		display Y position
		and.w		#$fff0,d1		MOD 16
		cmp.w		#176,d1
		ble.s		.ok
		move.w		#176,d1

.ok		move.w		d1,CurY(a4)		and save

		move.l		screen.vp(a4),a0	ViewPort
		lea		Sprite,a1		SimpleSprite
		CALLGRAF	MoveSprite		move it

		rts
		
*****************************************************************************
*			Useful Subroutines Section					    *
*****************************************************************************

; Entry		a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

DosMsg		movem.l		d0-d3/a0-a3,-(sp)	save registers

		tst.l		STD_OUT(a4)		test for open console
		beq		.error			quit if not one

		move.l		a0,a1			get a working copy

;--------------	Determine length of message

		moveq.l		#-1,d3			reset counter
.loop		addq.l		#1,d3			bump counter
		tst.b		(a1)+			is this byte a 0
		bne.s		.loop			if not loop back

;--------------	Make sure there was a message

		tst.l		d3			was there a message ?
		beq.s		.error			if not, graceful exit

;--------------	Get handle of output file

		move.l		STD_OUT(a4),d1		d1=file handle
		beq.s		.error			leave if no handle

;--------------	Now print the message
;		At this point, d3 already holds length of message
;		and d1 holds the file handle.

		move.l		a0,d2			d2=address of message
		CALLDOS		Write			and print it

;--------------	All done so finish

.error		movem.l		(sp)+,d0-d3/a0-a3	restore registers
		rts

*****************************************************************************
*			Port Handling Routines				    *
*****************************************************************************

* Function List:

* NewList(List, Type)
*	  A0	D0

* Port = CreatePort(Name, Pri)
* D0		   A0	D0

* DeletePort(Port)
*	     A0

* NewList(list,type)
* a0 = list (to initialise)
* d0 = type

* NON-MODIFIABLE.

NewList		move.l		a0,(a0)			lh_head-> lh_tail
		addq.l		#4,(a0)
		clr.l		4(a0)			lh_tail = NULL
		move.l		a0,8(a0)		lh_tailpred-> lh_head

		move.b		d0,12(a0) 		list type

		rts



* port = CreatePort(Name,Pri)
* a0 = name
* d0 = pri
* returns d0 = port, NULL if couldn't do it

* d1/d7/a1 corrupt

* NON-MODIFIABLE.


CreatePort	movem.l		d0/a0,-(sp)		save parameters
		moveq		#-1,d0
		CALLEXEC	AllocSignal		get a signal bit
		tst.l		d0
		bmi.s		cp_error1
		move.l		d0,d7			save signal bit

* got signal bit. Now create port structure.

		move.l		#MP_SIZE,d0
		move.l		#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		tst.l		d0
		beq.s		cp_error2		couldnt create struct!

* Here initialise port node structure.

		move.l		d0,a0
		movem.l		(sp)+,d0/d1		get parms off stack
		move.l		d1,LN_NAME(a0)		set name pointer
		move.b		d0,LN_PRI(a0)		and priority

		move.b		#NT_MSGPORT,LN_TYPE(a0)	ensure it's a message
							;port

* Here initialise rest of port.

		move.b		#PA_SIGNAL,MP_FLAGS(a0)	signal if msg received
		move.b		d7,MP_SIGBIT(a0)	signal bit here
		move.l		a0,-(sp)
		sub.l		a1,a1
		CALLEXEC	FindTask		find THIS task
		move.l		(sp)+,a0
		move.l		d0,MP_SIGTASK(a0)	signal THIS task if
							;msg arrived

* Here, if public port, add to public port list, else
* initialise message list header.

		tst.l		LN_NAME(a0)		got a name?
		beq.s		cp_private		no

		move.l		a0,-(sp)
		move.l		a0,a1
		CALLEXEC	AddPort			add to public port list
		move.l		(sp)+,d0		(which also NewList()
		rts					the mp_MsgList)

* Here initialise list header.

cp_private	lea		MP_MSGLIST(a0),a1	ptr to list structure
		exg		a0,a1			for now
		move.b		#NT_MESSAGE,d0		type = message list
		bsr		NewList			do it!

		move.l		a1,d0			return ptr to port
		rts

* Here couldn't allocate. Release signal bit.

cp_error2	move.l		d7,d0
		CALLEXEC	FreeSignal

* Here couldn't get a signal so quit NOW.

cp_error1	movem.l		(sp)+,d0/a0
		moveq		#0,d0			signal no port exists!

		rts


* DeletePort(Port)
* a0 = port

* a1 corrupt

* NON-MODIFIABLE.


DeletePort	move.l		a0,-(sp)
		tst.l		LN_NAME(a0)		public port?
		beq.s		dp_private		no

		move.l		a0,a1
		CALLEXEC	RemPort			remove port

* here make it difficult to re-use the port.

dp_private	move.l		(sp)+,a0
		moveq		#-1,d0
		move.l		d0,MP_SIGTASK(a0)
		move.l		d0,MP_MSGLIST(a0)

* Now free the signal.

		moveq		#0,d0
		move.b		MP_SIGBIT(a0),d0
		CALLEXEC	FreeSignal

* Now free the port structure.

		move.l		a0,a1
		move.l		#MP_SIZE,d0
		CALLEXEC	FreeMem

		rts

		*******************************
		include		Subs.i
		*******************************
		include		SU_Win.i
		*******************************
		include		files.i
		*******************************
		include		filerequester.i
		*******************************
		include		MaskEd.i
		*******************************
		include		ilbm.code.s
		*******************************

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
		dc.b		'ACC Screen Map Designer.'
		dc.b		$0a
		dc.b		'       by M.Meany, May 92.'
		dc.b		$0a
		dc.b		0
		even

FRQ		dc.l		0		pointer to window name
		dc.l		0		custom screen pointer or NULL
		dc.l		Dir		pointer to directory
		dc.l		0		pointer to dest buffer
		dc.w		10		X position
		dc.w		50		Y position
		dc.l		0		Selected files length

LoadName1	dc.b		'Retrievable Block Load',0
		even
LoadName2	dc.b		'Map File Load',0
		even
LoadName3	dc.b		'ColourMap Load',0
		even
LoadName4	dc.b		'Project Load',0
		even
LoadName5	dc.b		'Grab From IFF',0
		even
LoadName6	dc.b		'Add From IFF',0
		even
SaveName1	dc.b		'Retrievable Block Save',0
		even
SaveName2	dc.b		'Consecutive Block Save',0
		even
SaveName3	dc.b		'Interleaved Block Save',0
		even
SaveName4	dc.b		'Map File Save',0
		even
SaveName5	dc.b		'ColourMap Save',0
		even
SaveName6	dc.b		'Project Save',0
		even

Dir		dc.b		'df0:',0
		even


;***********************************************************
;	Window and Gadget defenitions
;***********************************************************

MyScreen
		dc.w	0,0		;screen XY origin relative to View
		dc.w	320,256		;screen width and height
		dc.w	4		;screen depth (number of bitplanes)
		dc.b	0,1		;detail and block pens
		dc.w	0		;display modes for this screen
		dc.w	CUSTOMSCREEN	;screen type
		dc.l	0		;pointer to default screen font
		dc.l	.Title		;screen title
		dc.l	0		;first in list of custom screen gadgets
		dc.l	0		;pointer to custom BitMap structure

.Title		dc.b	'ACC Screen Designer',0
		even

Palette		dc.w	$000,$A9B,$553,$600,$324,$436,$547,$557
		dc.w	$863,$EA0,$A97,$659,$77A,$213,$DCC,$FFF
		dc.w	$000,$D22,$000,$FDB,$444,$555,$666,$777
		dc.w	$888,$999,$AAA,$BBB,$CCC,$DDD,$00E,$F00


; Window defs for a SuperBitMap window ... Hello Layers!!!

MyWindow	dc.w	0,0		window XY origin
		dc.w	320,192		window width and height
		dc.b	0,1		detail and block pens
		dc.l	0 GADGETDOWN+GADGETUP+RAWKEY+MOUSEMOVE	IDCMP
		dc.l	SUPER_BITMAP+GIMMEZEROZERO+NOCAREREFRESH+ACTIVATE+REPORTMOUSE+BORDERLESS+RMBTRAP
		dc.l	0		first gadget in gadget list
		dc.l	0		custom CHECKMARK imagery
		dc.l	0		window title
		dc.l	0		custom screen pointer
		dc.l	0		custom bitmap
		dc.w	90,40		minimum width and height
		dc.w	320,256		maximum width and height
		dc.w	CUSTOMSCREEN	destination screen type

		************************
		include		Ed_win.i
		************************

returnMsg	dc.l		0		DEBUG ONLY

; SimpleSprite structure for the screen cursor

Sprite		dc.l		SprData			pointer to CHIP data
		dc.w		16			height
		dc.w		0,0			x,y
		dc.w		0			sprite number

;################
;DummyBlocks	incbin		blockdata.bm
;DummySize	equ		*-DummyBlocks
;################


***********************************************************
	SECTION	Vars,BSS
***********************************************************


_DOSBase	ds.l		1		Library Base Pointers
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1
_LayersBase	ds.l		1		


Vars		ds.b		varSize

*******************************************************
		SECTION		gfx,data_c
*******************************************************

; Gfx data for the screen cursor - rendered as a sprite

SprData	dc.w		$0000,$0000			x,y position
	dc.w		%1111111111111111,$0000		line 0
	dc.w		%1100000000000011,$0000		line 1
	dc.w		%1010000000000101,$0000		line 2
	dc.w		%1001000000001001,$0000		line 3
	dc.w		%1000100000010001,$0000		line 4
	dc.w		%1000011111100001,$0000		line 5
	dc.w		%1000010000100001,$0000		line 6
	dc.w		%1000010000100001,$0000		line 7
	dc.w		%1000010000100001,$0000		line 8
	dc.w		%1000010000100001,$0000		line 9
	dc.w		%1000011111100001,$0000		line 10
	dc.w		%1000100000010001,$0000		line 11
	dc.w		%1001000000001001,$0000		line 12
	dc.w		%1010000000000101,$0000		line 13
	dc.w		%1100000000000011,$0000		line 14
	dc.w		%1111111111111111,$0000		line 15
	dc.w		$0000,$0000			reserved ( attached )

im1		dc.w		%1111000000000000
		dc.w		%1111000000000000
		dc.w		%1111000000000000
		dc.w		%1111000000000000

im2		dc.w		%0000000000000000
		dc.w		%0000000000000000
		dc.w		%0000000000000000
		dc.w		%0000000000000000

im3		ds.w		16

		section		Skeleton,code

***** Your code goes here!!!

