
; Main routine for IFF2INT, an ILBM to source utility.

; I intend to build this up into a useful system programmers tool in the 
;same vain as PowerWindows! At present all it does is load an IFF file
;and allow you to save an image structure for it with the gfx data converted
;into dc.w statements .... just what I needed for this months tutorial!

; © M.Meany, July 1991.

; Nov '91. Corrected routines to build an Image structure ... Stage 1.

; Started 3/7/91. Will load and display an IFF picture.

;		opt 		o+

		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/gfxbase.i"
		include		"graphics/graphics_lib.i"
		include		"misc/arpbase.i"

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"

BuffSize	equ		2000		size of IFF load buffer

;*****************************************

CALLSYS    MACRO		;CALLSYS macro - using CALLARP
	IFGT	NARG-1       	;CALLINT etc can slow code down and  
	FAIL	!!!         	;waste a lot of memory  S.M. 
	ENDC                 
	JSR	_LVO\1(A6)
	ENDM
		
*****************************************************************************

; The main routine that opens and closes things
;** OPENARP moved to front as it will print a message on the CLI then **
;**   return to easystart if it can't find the ARP library ,we don't  **
;**                need to do any error checking of our own           **

start		OPENARP				;use arp's own open macro
		movem.l		(sp)+,d0/a0	;restore d0 and a0 as the
						;the macro leaves these on
						;the stack causing corrupt
						;stack

		move.l		a6,_ArpBase	;store arpbase
		move.l		a6,_DOSBase	;cheat a little
		
;--------------	the ARP library opens and uses the graphics and intuition 
;		libs and it is quite legal for us to get these bases for 
;		our own use

		move.l		IntuiBase(a6),_IntuitionBase
		move.l		GFXBase(a6),_GfxBase

		move.l		#SaveI,SaveSubAddr

		bsr.s		Openwin		open window
		tst.l		d0		any errors?
		beq.s		no_win		if so quit

		bsr		WaitForMsg	wait for user

		bsr		Closewin	close our window

		move.l		BMP,d0		;addr of current data
		beq.s		no_win		;none loaded, so jump
		jsr		CleanupGraf	;release memory

no_win		bsr		Closelibs	close open libraries

		rts				finish

;--------------
;-------------- Open An Intuition Window
;--------------

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

		move.l		window.rp,a0	rastport
		lea		WinText,a1	IntuiText
		moveq.l		#0,d0		x start
		move.l		d0,d1		y start
		CALLSYS		PrintIText	print it
		moveq.l		#1,d0		no errors

.win_error	rts				return

;--------------
;--------------	Deal with gadget selection.
;--------------

; At present only supports gadget selection. Address of routine to call
;when a gadget is selected should be stored in the gg_UserData field
;of that gadgets structure. All gadget service subroutines should set
;d2=0 to ensure accidental QUIT is not forced. If a QUIT gadget is used
;it should set d2=CLOSEWINDOW.


WaitForMsg	move.l		window.rp,a0	rastport
		lea		StatusText,a1	IntuiText
		moveq.l		#0,d0		x start
		move.l		d0,d1		y start
		CALLINT		PrintIText	print it
		move.l		#status9,StatusPtr set OK prompt

		move.l		window.up,a0	a0-->user port
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
		jsr		(a0)

.test_win	cmp.l		#CLOSEWINDOW,d2  window closed ?
		bne.s		WaitForMsg	 if not then jump
		rts

;--------------
;-------------- Close the Intuition window.
;--------------

Closewin	move.l		window.ptr,a0
		CALLINT		CloseWindow
		rts

;--------------
;-------------- Close ARP library
;--------------

; Closes any libraries the program managed to open.

Closelibs	move.l		_ArpBase,a1		a1=base ptr
		CALLEXEC	CloseLibrary		close lib

		rts

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
		CALLARP		Write		and print it

;--------------	All done so finish

.error		movem.l		(sp)+,d0-d3/a0-a3 restore registers
		rts


*****************************************************************************
*			Data Section					    *
*****************************************************************************

		include		subs.i		subroutines for gadgets
		include		win.s		window, text and gadget defs

	SECTION strings,data

status1		dc.b		"Can't open the file!   ",0
		even
status2		dc.b		'Not enough memory!     ',0
		even
status3		dc.b		'IFF compression error! ',0
		even
status4		dc.b		'Not an ILBM file!      ',0
		even
status5		dc.b		'DOS error!             ',0
		even
status6		dc.b		'File loaded OK!        ',0
		even
status7		dc.b		'CANCEL selected!       ',0
		even
status8		dc.b		'No file loaded!        ',0
		even
status9		dc.b		'OK!                    ',0
		even 
statusA		dc.b		'No gfx in memory!      ',0
		even
statusB		dc.b		'Image file created ok. ',0
		even
statusC		dc.b		"Can't open output file!",0
		even
statusD		dc.b		'Operation Aborted!     ',0
		even

		include		ilbm.code.s

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_DOSBase	ds.l		1
_ArpBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

window.ptr	ds.l		1
window.rp	ds.l		1
window.up	ds.l		1

temp.ptr	ds.l		1
temp.rp		ds.l		1
temp.up		ds.l		1

STD_OUT		ds.l		1

BMP		ds.l		1	Address of ILBM_BitMap struct

SaveSubAddr	ds.l		1	space for address of save subroutine

LoadFileData:
		ds.b	FCHARS+1	;reserve space for filename buffer
		EVEN
	
LoadDirData:
		ds.b	DSIZE+1		;reserve space for path buffer
		EVEN
	
FromFile	ds.b	DSIZE+FCHARS+2	;reserve space for full pathname name buffer
		EVEN

ToFile		ds.b	DSIZE+FCHARS+2
		even


FileHndl
	ds.l	1
OldView
	ds.l	1
MyView
	ds.b	v_SIZEOF	
ViewPort1
	ds.b	vp_SIZEOF
MyRasinfo1
	ds.b	ri_SIZEOF

