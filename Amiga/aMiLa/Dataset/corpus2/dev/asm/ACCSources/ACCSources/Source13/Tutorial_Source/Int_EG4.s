
; Int_EG4.s : Drawing Images

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
		moveq.l		#68,d0		X offset
		moveq.l		#170,d1		Y offset
		CALLINT		PrintIText	print this text

		move.l		window.rp,a0	RastPort
		lea		MyImage,a1	Image structure
		moveq.l		#8,d0		X offset
		moveq.l		#13,d1		Y offset
		CALLINT		DrawImage	and display it
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
		dc.b		'This program draws a picture of Hagar The Horrible.'
		dc.b		$0a
		dc.b		' CODE by Mark, GFX by Mark & Mo. June 1991'
		dc.b		$0a
		dc.b		0
		even

;***********************************************************
;	Window and Gadget defenitions
;***********************************************************


MyWindow	dc.w		101,9
		dc.w		210,190
		dc.b		1,2
		dc.l		GADGETDOWN+GADGETUP+CLOSEWINDOW
		dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
		dc.l		0		;gadgets
		dc.l		0
		dc.l		WindowName
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

WindowName	dc.b		' Test ',0
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

.Text		dc.b		'Hagar !!!',0		the text itself
		even


MyImage		dc.w	0
		dc.w	0
		dc.w	191
		dc.w	161
		dc.w	2
		dc.l	ImDat
		dc.b	3
		dc.b	0
		dc.l	0


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

ImDat	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0038,$0000,$0000,$0000,$0000
	dc.w	$0380,$0000,$0000,$0000,$0000,$0000,$0000,$01FE
	dc.w	$0000,$0000,$0000,$0000,$0FF0,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$03FF,$0000,$0000,$0000,$0000
	dc.w	$1FF8,$0000,$0000,$0000,$0000,$0000,$0000,$03FF
	dc.w	$0000,$0000,$0000,$0000,$1FF8,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$03FF,$8000,$0000,$0000,$0000
	dc.w	$3FF8,$0000,$0000,$0000,$0000,$0000,$0000,$03FF
	dc.w	$C000,$0000,$0000,$0000,$7FF8,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$03FF,$E000,$0000,$0000,$0000
	dc.w	$FFF8,$0000,$0000,$0000,$0000,$0000,$0000,$03FF
	dc.w	$E000,$0000,$0000,$0000,$FFF8,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$01FF,$F000,$0000,$0000,$0001
	dc.w	$FFF0,$0000,$0000,$0000,$0000,$0000,$0000,$01FF
	dc.w	$F000,$0000,$0000,$0001,$FFF0,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$01FF,$FE00,$0000,$0000,$000F
	dc.w	$FFF0,$0000,$0000,$0000,$0000,$0000,$0000,$00FF
	dc.w	$FF80,$0000,$0000,$003F,$FFE0,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$007F,$FFF8,$0000,$0000,$03FF
	dc.w	$FFC0,$0000,$0000,$0000,$0000,$0000,$0000,$003F
	dc.w	$FFF0,$0000,$0000,$7FFF,$FF80,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$001F,$FFF0,$0000,$003F,$FFFF
	dc.w	$FF00,$0000,$0000,$0000,$0000,$0000,$0000,$000F
	dc.w	$FFE0,$0000,$007F,$FFFF,$FE00,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0003,$FFC0,$0000,$00FF,$FFFF
	dc.w	$F800,$0000,$0000,$0000,$0000,$0000,$0000,$0001
	dc.w	$FF00,$0000,$00FF,$FFFF,$F000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$3E00,$0000,$00FF,$FFFF
	dc.w	$8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0800,$0000,$00FF,$FFFE,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$007F,$FFE0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$003F,$FC00,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$6000,$0000,$0001,$F000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$7FC0,$0000,$03DB,$B000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$FFFF,$FFFF,$FFDB,$B800
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001
	dc.w	$E0FF,$FFFF,$FFF9,$C800,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0003,$E0FF,$FFFF,$FFFB,$EC00
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$000F
	dc.w	$E0FF,$FFFC,$1FFC,$FC00,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$001F,$F000,$0FFC,$1FFE,$FC00
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$001F
	dc.w	$8000,$01FC,$1FFF,$7700,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0072,$0000,$00FE,$3FE3,$1F80
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$01E0
	dc.w	$0000,$00FF,$FFFD,$C7C0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0790,$0000,$00EF,$F77E,$F3C8
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$3E70
	dc.w	$0000,$002F,$F777,$3FE4,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$1DF0,$0000,$002E,$FBF3,$CFFF
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0FE0
	dc.w	$0000,$002E,$7BFB,$C387,$8000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$1060,$0000,$046E,$7DFD,$DFF9
	dc.w	$E000,$0000,$0000,$0000,$0000,$0000,$0000,$0F1E
	dc.w	$0000,$7770,$7DFD,$CFBF,$A000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$03AF,$BFBB,$E000,$FE7F,$B07F
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$07B0
	dc.w	$3FFF,$8E07,$9F7E,$7F7C,$7C00,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$009C,$5FFF,$C01E,$6007,$C760
	dc.w	$FFC0,$0000,$0000,$0000,$0000,$0000,$0000,$0004
	dc.w	$0000,$0380,$F358,$2011,$F7F8,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$00E7,$8000,$3E79,$7680,$E90B
	dc.w	$F7CF,$0000,$0000,$0000,$0000,$0000,$0000,$0029
	dc.w	$F001,$EF73,$4CC4,$9F9B,$73F7,$8000,$0000,$0000
	dc.w	$0000,$0000,$0000,$001F,$F807,$F893,$1F20,$22C3
	dc.w	$B9F7,$8000,$0000,$0000,$0000,$0000,$0000,$0003
	dc.w	$FFFF,$C7C0,$0780,$0F17,$DCF9,$E000,$0000,$0000
	dc.w	$0000,$0000,$0FE0,$000F,$9FFF,$0F00,$0000,$007F
	dc.w	$E73D,$F800,$0000,$0000,$0000,$0000,$3000,$0000
	dc.w	$1000,$0000,$0000,$007F,$F9CE,$7C00,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$1000,$0000,$0000,$00FF
	dc.w	$FE70,$3E00,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$01FC,$FFBF,$0180,$0000,$0000
	dc.w	$0000,$0004,$0000,$0000,$0C00,$0000,$0000,$01FC
	dc.w	$3FDF,$FF80,$0000,$0000,$0000,$0004,$0014,$0000
	dc.w	$0400,$0E00,$0780,$01FF,$1FEF,$FFC0,$0000,$0000
	dc.w	$0000,$0000,$0050,$0020,$0400,$0000,$0040,$043F
	dc.w	$8FF1,$F9E0,$0000,$0000,$0000,$0000,$01C0,$0020
	dc.w	$0400,$0000,$3040,$3DDF,$D3FC,$7CF0,$0000,$0000
	dc.w	$0000,$0000,$0000,$0020,$0040,$0000,$0040,$7DE3
	dc.w	$DCFD,$BF78,$0000,$0000,$0000,$0000,$0000,$0060
	dc.w	$0020,$00C0,$0000,$FEFD,$E77F,$CF78,$0000,$0000
	dc.w	$0000,$0008,$0400,$4078,$0020,$0040,$0003,$FEFE
	dc.w	$73BF,$F3FE,$0000,$0000,$0000,$0008,$0C00,$0060
	dc.w	$0000,$0020,$0007,$FEFF,$35DF,$FDFF,$0000,$0000
	dc.w	$0000,$0004,$1000,$40E0,$0000,$8025,$001F,$FF7F
	dc.w	$B6E7,$7E7F,$8000,$0000,$0000,$0004,$0000,$20A0
	dc.w	$0E00,$0024,$003F,$BF9F,$F73F,$9FFF,$E000,$0000
	dc.w	$0000,$0000,$0000,$00A0,$0000,$401C,$00FB,$CE0F
	dc.w	$F7FF,$E7FF,$E000,$0000,$0000,$0000,$0000,$00A0
	dc.w	$0000,$C010,$01FD,$F18F,$F3FF,$E1F3,$F800,$0000
	dc.w	$0000,$0001,$0000,$00A0,$0000,$0010,$05FD,$F8E7
	dc.w	$FBF3,$F6FD,$FC00,$0000,$0000,$0000,$0100,$01A0
	dc.w	$0000,$1010,$0CFC,$FC77,$F9F0,$7B7E,$7C00,$0000
	dc.w	$0000,$01C0,$00C0,$0168,$0000,$2000,$3EFE,$FE33
	dc.w	$FDF8,$1DFF,$BC00,$0000,$0000,$0000,$0038,$0348
	dc.w	$0007,$0000,$FEFE,$7E35,$FDFE,$67FD,$DC00,$0000
	dc.w	$0000,$0000,$0008,$00C8,$0040,$0007,$FE7F,$3F9E
	dc.w	$FE7F,$BFFC,$6400,$0000,$0000,$0000,$0008,$0080
	dc.w	$0080,$003F,$FF7F,$9F8E,$FB1F,$1FDF,$7000,$0000
	dc.w	$0000,$4000,$3008,$0180,$0080,$03FE,$FF3F,$CFCF
	dc.w	$7B8B,$819F,$F400,$0000,$0000,$6040,$0000,$0100
	dc.w	$0000,$3FBF,$0FBF,$E3EF,$7D8E,$0F6F,$F400,$0000
	dc.w	$0000,$1000,$0400,$0000,$0007,$FF9F,$8F95,$F1EF
	dc.w	$BDC2,$8767,$EFC0,$0000,$0000,$0000,$0001,$07F7
	dc.w	$FD00,$1F1F,$87C0,$F8F7,$BE60,$F373,$CF80,$0000
	dc.w	$0000,$0000,$0000,$07F7,$FDFF,$F78F,$E7E0,$7C77
	dc.w	$BF78,$F87D,$DFC0,$0000,$0000,$0000,$0000,$07EF
	dc.w	$7DFD,$D707,$F3F0,$3E37,$DFFE,$FFFD,$9FC0,$0000
	dc.w	$0000,$0000,$0000,$07CF,$1B3D,$D7C7,$ECF8,$1FBB
	dc.w	$DFF7,$3FFE,$3FF0,$0000,$0000,$63C2,$0600,$0F8F
	dc.w	$53D5,$D7E3,$EE7C,$0FAB,$DF73,$BFFF,$FFF8,$0000
	dc.w	$0001,$FFFF,$FF02,$1F9C,$E7D6,$E7F2,$DF9F,$8FB1
	dc.w	$EF7B,$9FFF,$FFFE,$0000,$0000,$7FFF,$FF1F,$3F27
	dc.w	$F7D6,$F3F8,$F3CF,$8FB1,$EFBF,$CFFF,$FFFF,$C000
	dc.w	$0000,$FFFF,$FFFF,$FF37,$F3E7,$75F8,$F9E3,$C7B1
	dc.w	$F7C7,$E3FF,$FFE7,$E000,$0000,$FFFF,$FFFF,$FAFA
	dc.w	$79CF,$4DF8,$FAFB,$E7B9,$F7C3,$F8FF,$FFF1,$F000
	dc.w	$0000,$FFFF,$FFFF,$FAFA,$FDEF,$7CFC,$CB3B,$EBB9
	dc.w	$E7E0,$1EFF,$FFFC,$3000,$0000,$FFFF,$FFFF,$FBFB
	dc.w	$DDEF,$7D7D,$6DD9,$EFBD,$F1FB,$FE7F,$DFFF,$8000
	dc.w	$0001,$FFFF,$FFFF,$FBFB,$DDCF,$BFBD,$6CED,$E61D
	dc.w	$F63D,$DF3F,$CFFF,$F000,$0003,$FFFF,$FFF3,$FFFB
	dc.w	$DDDF,$BFB5,$76FD,$F1BD,$FBC7,$E7BF,$E3FF,$F800
	dc.w	$0007,$FFFF,$FFF0,$0189,$DDCF,$BFD9,$76FD,$C7BD
	dc.w	$B9FF,$FFBF,$F9FF,$F800,$000F,$FFFF,$DFFF,$FC00
	dc.w	$DFEF,$BFFB,$7E7B,$07BD,$DFFE,$00BF,$FC3F,$F000
	dc.w	$000F,$FE7F,$9FFF,$FFC0,$7FF7,$BEFB,$7EB8,$079C
	dc.w	$EFC1,$FE0F,$FFBF,$E000,$000F,$FEFF,$BFFF,$EFFC
	dc.w	$1FF7,$BEFB,$FEF0,$00FE,$FF0F,$EFE4,$FF80,$0000
	dc.w	$000F,$FC7F,$BFFF,$9FFF,$0000,$0000,$0001,$FF00
	dc.w	$006F,$EFF2,$1F80,$0000,$000F,$F8FF,$BFFF,$B7FF
	dc.w	$FFF7,$FFFF,$FFFF,$FFFF,$BFF7,$EFF8,$0400,$0000
	dc.w	$000F,$FDFF,$BFFF,$6FFF,$F7F7,$FEFF,$BFFF,$EFFF
	dc.w	$DFFB,$E9FE,$0000,$0000,$0007,$F3FF,$FFFF,$1FFF
	dc.w	$77EF,$FEFF,$DB7F,$F7FF,$EFFD,$EEFF,$0000,$0000
	dc.w	$0003,$F3FF,$FFFE,$7DFD,$77DF,$F6FF,$ED7B,$F9FF
	dc.w	$F7FE,$6F3F,$8000,$0000,$0001,$E3FF,$FFF9,$FBDC
	dc.w	$FBDF,$ECFF,$F67D,$FEFE,$F9FF,$8FDF,$C000,$0000
	dc.w	$0000,$03FF,$FFF7,$F7B2,$FBDF,$ECFF,$FB3E,$7F3F
	dc.w	$7EFF,$E7DF,$E000,$0000,$0000,$03FF,$FFEF,$EFA6
	dc.w	$FBBF,$DD7F,$FD4F,$9FDF,$BF3F,$E7E7,$E000,$0000
	dc.w	$0000,$03FF,$BFEF,$DFA5,$FBBF,$DD7B,$FD77,$E7EF
	dc.w	$BF9F,$F77F,$E000,$0000,$0000,$03FF,$7BEF,$DFCD
	dc.w	$7BBF,$DD7B,$FE7B,$F8F7,$DFCF,$F7BF,$E000,$0000
	dc.w	$0000,$07BF,$77EF,$DFDD,$7BBF,$DD7D,$FE7D,$FF3B
	dc.w	$EFC3,$F3DF,$C000,$0000,$0000,$03BF,$6FEF,$DFDD
	dc.w	$7BBF,$DD7E,$FF7E,$FF45,$F7CB,$EBE7,$C000,$0000
	dc.w	$0000,$03FF,$EFEF,$DFDD,$7B9F,$DF7E,$FF7E,$FFB8
	dc.w	$FBEF,$EBFF,$8000,$0000,$0000,$03FF,$EFEF,$FFFD
	dc.w	$BFDF,$DF7F,$7F3F,$7FDE,$FBEF,$EBFF,$8000,$0000
	dc.w	$0000,$000F,$9FEF,$07FD,$BFDF,$DF7F,$7F5F,$7FDE
	dc.w	$FDEF,$EBFF,$8000,$0000,$0000,$0000,$BFF6,$00FE
	dc.w	$BFDF,$FF7F,$FF5E,$FFEE,$FFF7,$F3FF,$8000,$0000
	dc.w	$0000,$0000,$00C0,$0306,$BFDF,$FF7F,$FF6E,$FFEF
	dc.w	$FFFF,$F3FF,$8000,$0000,$0000,$0000,$0000,$03F8
	dc.w	$1FFF,$FE3F,$FFEF,$FC00,$7FFF,$FE00,$0000,$0000
	dc.w	$0000,$0000,$0000,$01FF,$C7FF,$E080,$7FF7,$83FC
	dc.w	$01FF,$C000,$0000,$0000,$0000,$0000,$0000,$00FF
	dc.w	$F800,$0FDF,$8070,$3FFC,$0007,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$007F,$FFFF,$FFDF,$FF8D,$FFFC
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$007F
	dc.w	$FFFF,$FFDF,$FFFF,$FFF8,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$007F,$FFFF,$FFDF,$8001,$FFF8
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$007F
	dc.w	$FFFF,$FFDC,$7FFE,$0FF0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$001F,$FFFF,$FE0F,$FFFF,$F000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0FF8,$01A1,$FFFF,$FF70,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0037,$F007,$FBBE,$0FFF,$FCF0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0030
	dc.w	$3FFF,$E7BF,$8000,$01E0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$003E,$0000,$0FB8,$3F80,$0060
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001
	dc.w	$FF87,$FF87,$FFFF,$FFE0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$001F,$FFFF,$FFBF,$FF80,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$001F
	dc.w	$FFFF,$8F00,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$001F,$FFFF,$E300,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$FFFE,$1900,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$01FF,$FD00,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$C000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0001,$FC00,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$001F,$FF80,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00FF,$FFC0,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$07FF,$FFF0,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$3FFF,$FFF8,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$FFFF,$FFFC,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0003,$FFFF,$FFFE,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$000F,$FFFF,$FFFF,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$000F,$FFFF,$FFC0,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$001F,$FFFF,$FF80,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$003F,$FFFF,$FF00,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$00FF,$FFFF,$FF00,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$01FF,$FFFF,$FF00,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$07FF,$FFFF,$FF00,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0FFF,$FFFF,$FF80,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$3FFF,$FFFF,$FFC0,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$7FFF,$FFFF,$FFFF,$F000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$FFFF,$FFFF,$FFFF,$F000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$9FFF,$FFFF,$FFFF,$F000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0001,$803F,$FFFF,$FCFF,$F000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0003
	dc.w	$0000,$0000,$007F,$F800,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0006,$1F00,$0000,$003F,$FC00
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$000C
	dc.w	$1F00,$0000,$000F,$FE00,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0030,$1F00,$0003,$E00F,$FE00
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0020
	dc.w	$0800,$0003,$E00F,$FF80,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$007C,$0000,$0003,$E00F,$FF80
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$01FE
	dc.w	$0000,$0001,$C01F,$FFC0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$07F8,$0400,$00F8,$003F,$FFFC
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$3FF0
	dc.w	$0F00,$00FF,$FFFF,$FFFC,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$FFF0,$0200,$003F,$FFFF,$FFFF
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$FFF0
	dc.w	$0000,$003F,$FFFF,$FFFF,$C000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$7FF8,$0000,$003F,$FFFF,$FFFF
	dc.w	$E000,$0000,$0000,$0000,$0000,$0000,$0000,$7FFC
	dc.w	$0000,$07FF,$FFFF,$FFFF,$F000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$7FFE,$0000,$7FFF,$FFFF,$FFFF
	dc.w	$F000,$0000,$0000,$0000,$0000,$0000,$000F,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FC00,$0000,$0000,$0000
	dc.w	$0000,$0000,$007F,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFC0,$0000,$0000,$0000,$0000,$0000,$07FF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFF8,$0000,$0000,$0000
	dc.w	$0000,$0000,$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$0000,$0000,$0000,$0000,$0001,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$E000,$0000,$0000
	dc.w	$0000,$0007,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$C000,$0000,$0000,$0000,$000F,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F000,$0000,$0000
	dc.w	$0000,$001F,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FC00,$0000,$0000,$0000,$007F,$F01F,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FE00,$0000,$0000
	dc.w	$0000,$007F,$CFFF,$FFFF,$EFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FF00,$0000,$0000,$0000,$00FF,$FFFF,$FFFF
	dc.w	$EFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FF80,$0000,$0000
	dc.w	$0000,$01FF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFC0,$0000,$0000,$0000,$01FB,$FFFF,$FFFF
	dc.w	$F3FF,$FFFF,$FFFF,$FFFF,$FFFF,$FFE0,$0000,$0000
	dc.w	$0000,$07FB,$FFEB,$FFFF,$FBFF,$F1FF,$F87F,$FFFF
	dc.w	$BFFF,$FFF0,$0000,$0000,$0000,$07FF,$FFAF,$FFDF
	dc.w	$FBFF,$FFFF,$FFBF,$FFFF,$DFFF,$FFF8,$0000,$0000
	dc.w	$0000,$07FF,$FE3F,$FFDF,$FBFF,$FFFF,$CFBF,$FFFF
	dc.w	$FFFF,$FFFC,$0000,$0000,$0000,$0FFF,$FFFF,$FFDF
	dc.w	$FFBF,$FFFF,$FFBF,$FFFF,$FFFF,$FFFC,$0000,$0000
	dc.w	$0000,$1FFF,$FFFF,$FF9F,$FFDF,$FF3F,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$0000,$0000,$0000,$1FF7,$FBFF,$BF87
	dc.w	$FFDF,$FFBF,$FFFF,$FFFF,$FFFF,$FFFF,$8000,$0000
	dc.w	$0000,$1FF7,$F3FF,$FF9F,$FFFF,$FFDF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$C000,$0000,$0000,$1FFB,$EFFF,$BF1F
	dc.w	$FFFF,$7FDA,$FFFF,$FFFF,$FFFF,$FFFF,$E000,$0000
	dc.w	$0000,$1FFB,$FFFF,$DF5F,$F1FF,$FFDB,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$F000,$0000,$0000,$1FFF,$FFFF,$FF5F
	dc.w	$FFFF,$BFE3,$FFFF,$FFBF,$FFFF,$FFFF,$FC00,$0000
	dc.w	$0000,$3FFF,$FFFF,$FF5F,$FFFF,$3FEF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FE00,$0000,$0000,$7FFE,$FFFF,$FF5F
	dc.w	$FFFF,$FFEF,$FFFF,$FDFF,$FFFF,$FFFF,$FD00,$0000
	dc.w	$0000,$7FFF,$FEFF,$FE5F,$FFFF,$EFEF,$FFFF,$FEFF
	dc.w	$FFFB,$FFFF,$FCC0,$0000,$0000,$7E3F,$FF3F,$FE97
	dc.w	$FFFF,$DFFF,$FFFF,$FF7F,$FFFE,$7FFF,$FC40,$0000
	dc.w	$0000,$7FFF,$FFC7,$FCB7,$FFF8,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FC20,$0000,$0000,$7FFF,$FFF7,$FF37
	dc.w	$FFBF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FC70,$0000
	dc.w	$0000,$7FFF,$FFF7,$FF7F,$FF7F,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FCC0,$0000,$0000,$3FFF,$CFF7,$FE7F
	dc.w	$FF7F,$FFFF,$FFFF,$FFFF,$FFDF,$FFFF,$FAF0,$0000
	dc.w	$0000,$1FBF,$FFFF,$FEFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$DF9F,$FBE0,$0000,$0000,$6FFF,$FBFF,$FFFF
	dc.w	$FFFF,$FFFF,$DFFF,$FFFF,$FFFF,$7F9F,$F020,$0000
	dc.w	$0000,$FFFF,$FFFE,$FFFF,$FFFF,$FFBF,$EFF5,$FFFF
	dc.w	$FFFF,$0F8F,$F060,$0000,$0000,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFDF,$FFFC,$FFFF,$FFFF,$0783,$E020,$0000
	dc.w	$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFEF,$FFFE,$7FFF
	dc.w	$FFFF,$0003,$E038,$0000,$0001,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$3FFF,$FFFF,$C001,$C00C,$0000
	dc.w	$0001,$9C3D,$F9FF,$FFFF,$FFFF,$FFFF,$FFFF,$9FFF
	dc.w	$FFFF,$C000,$0007,$0000,$0000,$0000,$00FD,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$DFFB,$FFFF,$E000,$0001,$E000
	dc.w	$0000,$0000,$00E0,$DFFF,$FFFF,$FFFF,$FFFF,$FFFB
	dc.w	$FFFF,$F000,$0000,$3000,$0000,$0000,$0000,$1FFF
	dc.w	$FFFF,$FFFF,$FFFF,$EFFB,$FFFF,$FC00,$0018,$1800
	dc.w	$0000,$0000,$0000,$3FFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFE7,$FF00,$000E,$0800,$0000,$0000,$0001,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFB,$FF00,$0003,$C800
	dc.w	$0000,$0000,$0001,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FF80,$2000,$7800,$0000,$0000,$0003,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFC0,$3000,$0C00
	dc.w	$0000,$0000,$0007,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFC0,$1C00,$0400,$0000,$0000,$000F,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFC0,$0600,$0400
	dc.w	$0000,$0000,$2007,$FFEB,$FFFF,$FFFF,$FFFF,$EFFF
	dc.w	$FFFF,$FFC0,$03C0,$0C00,$0000,$0180,$6003,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$8FFF,$FFFF,$FFF0,$0040,$1800
	dc.w	$0000,$0100,$4003,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFB,$007F,$E000,$0000,$0380,$4007,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFD,$E040,$0000
	dc.w	$0000,$0700,$400F,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFE,$3B80,$0000,$0010,$0200,$600F,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0E00,$0000
	dc.w	$0018,$0E00,$701F,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$C000,$0000,$000C,$0E01,$F01F,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$E000,$0000
	dc.w	$0006,$1F83,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$F000,$0000,$0003,$F7FF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F000,$0000
	dc.w	$0000,$07FF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$F000,$0000,$0000,$07FF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F000,$0000
	dc.w	$0000,$0FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$F000,$0000,$0000,$0FFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F000,$0000
	dc.w	$0000,$0FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$E000,$0000,$0000,$07FF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$C000,$0000
	dc.w	$0000,$07FF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$C000,$0000,$0000,$07FF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$C000,$0000
	dc.w	$0000,$000F,$FFFF,$8FFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$C000,$0000,$0000,$0000,$FFFF,$04FF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$C000,$0000
	dc.w	$0000,$0000,$00C0,$0407,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$8000,$0000,$0000,$0000,$0000,$0200
	dc.w	$3FFF,$FF7F,$FFFF,$FC02,$7FFF,$FF00,$0000,$0000
	dc.w	$0000,$0000,$0000,$0100,$07FF,$F020,$7FFF,$C002
	dc.w	$03FF,$E000,$0000,$0000,$0000,$0000,$0000,$0180
	dc.w	$0000,$0020,$0072,$0002,$0007,$8000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0080,$0000,$0020,$0000,$0006
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0080
	dc.w	$0000,$0020,$7FFE,$0004,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0080,$0000,$0023,$8001,$F008
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$00E0
	dc.w	$0000,$01F0,$0000,$0FF8,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$007F,$F007,$FE5E,$0000,$0088
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0048
	dc.w	$0FF8,$0441,$F000,$0308,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$004F,$C000,$1840,$7FFF,$FE18
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0041
	dc.w	$FFFF,$F047,$C07F,$FF90,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$007E,$0078,$0078,$0000,$0010
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0060
	dc.w	$0000,$0040,$007F,$FFFF,$FFE0,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0020,$0000,$70FF,$FFFF,$FFFF
	dc.w	$FFE0,$0000,$0000,$0000,$0000,$0000,$0000,$3820
	dc.w	$0000,$1CFF,$FFFF,$FFFF,$FFF0,$0000,$0000,$0000
	dc.w	$0000,$0000,$003F,$FFBF,$0001,$E6FF,$FFFF,$FFFF
	dc.w	$FFFC,$0000,$0000,$0000,$0000,$0000,$01FF,$FFFF
	dc.w	$FE00,$02FF,$FFFF,$FFFF,$FFFE,$0000,$0000,$0000
	dc.w	$0000,$0000,$0FFF,$FFFF,$FFFF,$3FFF,$FFFF,$FFFF
	dc.w	$FFFF,$0000,$0000,$0000,$0000,$0000,$7FFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$8000,$0000,$0000
	dc.w	$0000,$0000,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$C000,$0000,$0000,$0000,$0003,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$C000,$0000,$0000
	dc.w	$0000,$0003,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$C000,$0000,$0000,$0000,$0003,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$C000,$0000,$0000
	dc.w	$0000,$0003,$FFFF,$FFFF,$FFFF,$F003,$FFFF,$FFFF
	dc.w	$FFFF,$C000,$0000,$0000,$0000,$0003,$FFFF,$FFFF
	dc.w	$FFFF,$C000,$1FFF,$FFFF,$FFFF,$C000,$0000,$0000
	dc.w	$0000,$0003,$FFFF,$FFFF,$FFFF,$0000,$00FF,$FFFF
	dc.w	$FFFF,$C000,$0000,$0000,$0000,$0003,$FFFF,$FFFF
	dc.w	$FFFC,$0000,$000F,$FFFF,$FFFF,$C000,$0000,$0000
	dc.w	$0000,$0003,$FFFF,$FFFF,$FFF8,$0000,$0000,$7FFF
	dc.w	$FFFF,$8000,$0000,$0000,$0000,$0001,$FFFF,$FFFF
	dc.w	$FFE0,$0000,$0000,$03FF,$FFFF,$0000,$0000,$0000
	dc.w	$0000,$0001,$FFFF,$FFFF,$FFC0,$0000,$0000,$001F
	dc.w	$FFFC,$0000,$0000,$0000,$0000,$0000,$FFFF,$FFFF
	dc.w	$FF80,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$3FFF,$FFFF,$FE00,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0FFF,$FFFF
	dc.w	$FC00,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$00FF,$FFFF,$F000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0007,$FFFF
	dc.w	$E000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		section		Skeleton,code

