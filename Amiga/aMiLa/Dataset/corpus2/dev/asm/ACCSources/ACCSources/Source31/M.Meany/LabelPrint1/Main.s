;****** Auto-Revision Header (do not edit) *******************************
;*
;* © Copyright by MMSoftware
;*
;* Filename         : Main.s
;* Created on       : 01-Sep-93
;* Created by       : M.Meany
;* Current revision : V0.000
;*
;*
;* Purpose: 3.5 Inch Label Printer
;*                                                    M.Meany (04-Jan-93)
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

		incdir		sys:Include/
		
		include 	exec/exec.i
		include 	exec/exec_lib.i

		include 	libraries/dos.i
		include 	libraries/dosextens.i
		include 	libraries/dos_lib.i

		include 	graphics/gfxbase.i
		include		graphics/graphics_lib.i

		include 	intuition/intuition.i
		include 	intuition/intuition_lib.i

		include 	devices/inputevent.i
		include		devices/printer.i

		include		ACC31:Include/reqtools.i
		include		ACC31:Include/reqtools_lib.i

		include		misc/easystart.i

BuffSize	equ		5000		size of IFF read buffer

CALLSYS		macro
		jsr		_LVO\1(a6)
		endm

CALLREQ		macro
		move.l		_reqBase,a6
		jsr		_LVO\1(a6)
		endm

Start		bsr		OpenLibs
		tst.l		d0
		beq.s		.Error
		
		bsr		OpenPrt			open printer device
		tst.l		d0
		beq.s		.Error1
		
		bsr		OpenWin
		tst.l		d0
		beq.s		.Error2
		
		lea		OpenText,a1		a1-> texts
		lea		OpenReq,a2		a2-> gadget defs
		suba.l		a3,a3			no special info
		suba.l		a4,a4			no args
		lea		QuitTags,a0		a0-> tag list
		CALLREQ		rtEZRequestA		display request

; Initialise dummy RastPort used to print the label

		lea		PrintRastPort,a1	RastPort
		CALLGRAF	InitRastPort		Initialise it

		bsr		ProcessIO

		move.l		IFFStruc,d0
		beq.s		.Error3
		jsr		CleanupGraf
		
.Error3		bsr		CloseWin
		
.Error2		bsr		ClosePrt
		
.Error1		bsr		CloseLibs
		
.Error		moveq.l		#0,d0
		rts

		*****************************************
		*	  Process All IO		*
		*****************************************

ProcessIO	move.l		WinSigMask,d0		windows signal bit
		ori.l		#$1000,d0		allow CTRLF_C breaks
		CALLEXEC	Wait			sleep

; If a user break received, exit.

		btst		#12,d0			user break?
		beq.s		.TryIntui		no, check console
		bra.s		.done			else exit

; See if it was an IDCMP message that woke us up. If not go back to sleep

.TryIntui	move.l		WinSigMask,d1		get window sig bit
		and.l		d0,d1			test
		beq.s		ProcessIO		sleep if not IDCMP
		bsr		handleIDCMP		deal with message
		tst.l		d0			Quit selected?
		bne.s		ProcessIO		loop if not!

.done		rts					else exit

		*****************************************
		*	Handle IDCMP Messages		*
		*****************************************

handleIDCMP	moveq.l		#0,d2			clear register
		move.l		window.up,a0		a0->window port
		CALLEXEC	GetMsg			get any messages
		tst.l		d0			was there a message ?
		beq.s		.done			if not exit

; Extract useful information and reply.

		move.l		d0,a1			a1-->message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		move.w		im_Code(a1),d3		ascii code
		move.l		im_IAddress(a1),a5 	a5=addr of structure
		CALLSYS		ReplyMsg		answer os

; Check for gadget messages and act accordingly

		move.l		d2,d0
		and.l		#GADGETUP!GADGETDOWN,d0	source a gadget?
		beq.s		.test_win		skip if not.
		move.l		gg_UserData(a5),a0	else a0->subroutine
		cmpa.l		#0,a0			check for NULL
		beq.s		.test_win		skip if it is
		jsr		(a0)			else call routine

; If message was CLOSEWINDOW, exit from event loop.

.test_win	moveq.l		#1,d0			default to quit
		cmp.l		#CLOSEWINDOW,d2  	window closed ?
		bne.s		.done		 	yep, exit!

		lea		QuitText,a1		a1-> texts
		lea		QuitReq,a2		a2-> gadget defs
		suba.l		a3,a3			no special info
		suba.l		a4,a4			no args
		lea		QuitTags,a0		a0-> tag list
		CALLREQ		rtEZRequestA		display request
		
.done		rts					and exit

		*****************************************
		*	  Quit Gadget Routine		*
		*****************************************


Quit		move.l		#CLOSEWINDOW,d2
		rts

		*****************************************
		*	  Load An IFF File		*
		*****************************************

; At present will only accept IFF files of dimension NxNx2 ( 4 colour ). The
;palette is ignored as is any template. The graphic loaded will be displayed.

LoadIff		move.l		LoadIffReq,a1		a1-> request struct
		lea		FileName,a2		a2-> filename buffer
		lea		LoadTitle,a3		Requester Title
		lea		LoadTags,a0		tags
		CALLREQ		rtFileRequestA		display requester
		tst.l		d0			cancel selected?
		beq		.done			yep, exit!

; Release current SM_BitMap structure for any loaded file

		move.l		IFFStruc,d0
		beq.s		.Cleared
		jsr		CleanupGraf
		clr.l		IFFStruc
		lea		PrintRastPort,a0	RastPort
		clr.l		rp_BitMap(a0)

; Lock directory that file is in

.Cleared	move.l		LoadIffReq,a3		a3->requester
		move.l		rtfi_Dir(a3),d1		directory name
		moveq.l		#ACCESS_READ,d2		access mode
		CALLDOS		Lock			lock the directory
		move.l		d0,d7			save lock
		bne.s		.GotDir			skip if obtained
	
	;Unable to lock directory, inform user and exit
	
		lea		Err1Text,a1		a1-> texts
		lea		ErrReq,a2		a2-> gadget defs
		suba.l		a3,a3			no special info
		suba.l		a4,a4			no args
		lea		QuitTags,a0		a0-> tag list
		CALLREQ		rtEZRequestA		display request
		bra		.done

; Now make locked directory the current directory

.GotDir		move.l		d7,d1
		CALLDOS		CurrentDir
		move.l		d0,d6			save old dir lock

; Open the file 

		move.l		#FileName,d1		name of file to open
		move.l		#MODE_OLDFILE,d2	mode
		CALLDOS		Open
		move.l		d0,d5			save handle
		bne.s		.GotFile

	;Unable to open file, inform user and exit
	
		lea		Err2Text,a1		a1-> texts
		lea		ErrReq,a2		a2-> gadget defs
		suba.l		a3,a3			no special info
		suba.l		a4,a4			no args
		lea		QuitTags,a0		a0-> tag list
		CALLREQ		rtEZRequestA		display request
		bra		.FileError

; Attempt to load the IFF File. Note d0 already contains lock on file!

.GotFile	move.l		#ILBMCONTIGUOUS,d1
		jsr		LoadILBM
		move.l		d0,IFFStruc		save SM_BitMap ptr
		bne.s		.IffLoaded

		move.l		d1,d0			make a copy
		asr.w		#1,d0			/2 error return
		cmp.w		#2,d0
		ble.s		.GotIFFErr
		move.l		d1,ReqDStream		save DOS err code
		moveq.l		#3,d0			default error message

; Get address of error text from vector table, offset is calculated from the
;error code itself.

.GotIFFErr	asl.w		#2,d0			vector table offset
		lea		IFLErr,a1		vector table start
		add.l		d0,a1			start + offset
		move.l		(a1),a1			a1->err text
		
		lea		ErrReq,a2		a2-> gadget defs
		suba.l		a3,a3			no special info
		lea		ReqDStream,a4		args stream
		lea		QuitTags,a0		a0-> tag list
		CALLREQ		rtEZRequestA		display request
		
		bra		.LoadError

.IffLoaded	move.l		IFFStruc,a0		a0->BitMap
		bsr		CheckSize
		tst.l		d0
		bne.s		.SizeOk

	; IFF File is wrong dimension, tell user and exit

		lea		ReqDStream,a1
		moveq.l		#0,d0			clear
		move.w		ilbm_Width(a0),(a1)+	get width
		move.w		ilbm_Height(a0),(a1)+
		move.b		bm_Depth(a0),d0
		move.w		d0,(a1)

		lea		Err3Text,a1		a1-> texts
		lea		ErrReq,a2		a2-> gadget defs
		suba.l		a3,a3			no special info
		lea		ReqDStream,a4		arg stream
		lea		QuitTags,a0		a0-> tag list
		CALLREQ		rtEZRequestA		display request
		bra		.LoadError

; IFF image is correct size, display it and link to dummy RastPort
		
.SizeOk		lea		LabelImage,a1		a1->Image
		move.l		bm_Planes(a0),ig_ImageData(a1)

		move.l		window.rp,a0
		move.l		ImageX,d0
		move.l		ImageY,d1
		CALLINT		DrawImage

		lea		PrintRastPort,a0	RastPort
		move.l		IFFStruc,rp_BitMap(a0)	link BitMap
		
; Unlock the file

.LoadError	move.l		d5,d1			lock
		CALLDOS		Close			release it

; Restore current directory

.FileError	move.l		d6,d1			Lock
		CALLDOS		CurrentDir

; Release lock on selected directory

		move.l		d0,d1
		CALLDOS		UnLock

.done		clr.l		d2			not a quit routine
		rts					and exit!

; a0->BitMap

CheckSize	moveq.l		#0,d0

; First make sure IFF is of suitable dimensions, if not then exit.

		cmp.w		#640,ilbm_Width(a0)
		bgt.s		.done
		cmp.w		#200,ilbm_Height(a0)
		bgt.s		.done
		cmp.b		#2,bm_Depth(a0)
		bne.s		.done
		moveq.l		#1,d0

; Now calculate x,y offsets and save them. Also set image width and height.

		move.l		#640,d1
		sub.w		ilbm_Width(a0),d1
		asr.w		#1,d1
		move.w		d1,ImageX

		move.l		#200,d1
		sub.w		ilbm_Height(a0),d1
		asr.w		#1,d1
		add.w		#50,d1			add start position
		move.w		d1,ImageY

		move.w		ilbm_Width(a0),ImageW
		move.w		ilbm_Height(a0),ImageH

		lea		LabelImage,a1
		move.w		ilbm_Width(a0),ig_Width(a1)
		move.w		ilbm_Height(a0),ig_Height(a1)

.done		rts

		*****************************************
		*	     Print The Labels		*
		*****************************************

PrintLabels	move.l		NumCopies,d7		set counter
		clr.w		ReqDStream

.PrintLoop	bsr		PrintProgress

		move.l		window.ptr,a0
		move.l		wd_WScreen(a0),a0	a0->Screen
		lea		sc_ViewPort(a0),a0	a0->ViewPort
		
		move.l		PrtWrite,a1		a1->Write request
		move.w		#PRD_DUMPRPORT,IO_COMMAND(a1)
		move.l		window.rp,io_RastPort(a1)
		move.l		vp_ColorMap(a0),io_ColorMap(a1)
		move.l		vp_Modes(a0),io_Modes(a1)
		move.w		ImageX,io_SrcX(a1)
		move.w		ImageY,io_SrcY(a1)
		move.w		ImageW,io_SrcWidth(a1)
		move.w		ImageH,io_SrcHeight(a1)
		move.l		LabWidth,io_DestCols(a1)
		move.l		LabHeight,io_DestRows(a1)
		move.w		#SPECIAL_MILCOLS!SPECIAL_MILROWS!SPECIAL_TRUSTME,io_Special(a1)
		
		CALLEXEC	SendIO
		
.Sleep		move.l		TheSigMask,d0
		CALLEXEC	Wait
		move.l		d0,d1
				
		and.l		PrtSigMask,d0
		bne.s		.GotPrinter
		
		and.l		WinSigMask,d1
		beq.s		.Sleep
		
		move.l		window.up,a0
		CALLEXEC	GetMsg
		tst.l		d0
		beq.s		.Sleep
		
		move.l		d0,a1
		move.l		im_Class(a1),d3
		move.l		im_IAddress(a1),a3
		CALLSYS		ReplyMsg
		
		cmp.l		#GADGETUP,d3
		bne.s		.Sleep
		tst.w		gg_GadgetID(a3)
		beq.s		.Sleep
		
		move.l		PrtWrite,a1
		CALLSYS		AbortIO
		
		move.l		PrtWrite,a1
		CALLSYS		WaitIO

		lea		Err5Text,a1		a1-> texts
		lea		OpenReq,a2		a2-> gadget defs
		suba.l		a3,a3			no special info
		suba.l		a4,a4			no args
		lea		QuitTags,a0		a0-> tag list
		CALLREQ		rtEZRequestA		display request

		moveq.l		#1,d7
		bra.s		.Abort

; Get Message From Printer

.GotPrinter	move.l		PrtWrite,a1		a1->Write request
		tst.b		IO_ERROR(a1)		any errors?
		beq.s		.DoingFine		no, continue
		moveq.l		#1,d7

		lea		Err4Text,a1		a1-> texts
		lea		ErrReq,a2		a2-> gadget defs
		suba.l		a3,a3			no special info
		suba.l		a4,a4			no args
		lea		QuitTags,a0		a0-> tag list
		CALLREQ		rtEZRequestA		display request

; Check loop counter & keep printing until zero

.DoingFine	move.l		PrtWPort,a0
		CALLEXEC	GetMsg

.Abort		lea		ProgBuff,a0
		move.l		#'    ',d0
		move.l		d0,(a0)+
		move.l		d0,(a0)+
		move.l		d0,(a0)+
		move.l		d0,(a0)+
		move.l		d0,(a0)+

		move.l		window.rp,a0
		lea		ProgressText,a1
		move.l		#130,d0			x
		move.l		#157,d1
		CALLINT		PrintIText

		subq.l		#1,d7
		bne		.PrintLoop
		
		rts

		*****************************************
		*	  Display Number Printed	*
		*****************************************

PrintProgress	addq.w		#1,ReqDStream

		lea		.string,a0
		lea		ReqDStream,a1
		lea		.PChar,a2
		lea		ProgBuff,a3
		CALLEXEC	RawDoFmt
		
		move.l		window.rp,a0
		lea		ProgressText,a1
		move.l		#130,d0			x
		move.l		#157,d1
		CALLINT		PrintIText
		
		rts

.PChar		move.b		d0,(a3)+
		rts

.string		dc.b		'Printing Label: %03d',0
		even

		*****************************************
		*	  Set An Integer Gadget 	*
		*****************************************

; A subroutine to set an Integer gadget to a specified value.

; Entry		a0->Gadget structure
;		d0=long word value

BuildIntStr	movem.l		d0-d3/a0-a6,-(sp)	save registers

		move.l		gg_SpecialInfo(a0),a0	a0->StringInfo

		move.l		d0,si_LongInt(a0)	write long word

		lea		si_LongInt(a0),a1	a1->DataStream
		lea		.PutChar,a2		a2->Subroutine
		move.l		si_Buffer(a0),a3	a3->buffer
		lea		.Template,a0		a0->format string
		CALLEXEC	RawDoFmt		build text

		movem.l		(sp)+,d0-d3/a0-a6	restore registers
		rts					and return

.Template	dc.b		'%ld',0
		even

.PutChar	move.b		d0,(a3)+
		rts

		*****************************************
		*	  Open Printer Device		*
		*****************************************

OpenPrt		lea		prtport,a0		a0->port name
		moveq.l		#0,d0			priority
		bsr		CreatePort		get a port
		move.l		d0,PrtWPort		save pointer
		beq		.Error1			exit if no port

; Get port signal mask and save it

		move.l		d0,a0			a0->port
		moveq.l		#1,d0			
		moveq.l		#0,d1
		move.b		MP_SIGBIT(a0),d1
		asl.l		d1,d0
		move.l		d0,PrtSigMask

; Create an IO structure for read requests

		moveq.l		#iodrpr_SIZEOF,d0	size of structure
		bsr		CreateExtIO		get structure
		move.l		d0,PrtWrite		save address
		beq		.Error2

; Open the printer device

		lea		prtname,a0		a0->device name
		moveq.l		#0,d0			unit number
		move.l		PrtWrite,a1		a1->IO structure
		moveq.l		#0,d0			no flags
		CALLEXEC	OpenDevice		open serial device
		tst.l		d0			open OK?
		bne		.Error3			no, exit now!

; Signal no errors and exit

		moveq.l		#1,d0			no errors
.Error1		rts					so return

.Error3		move.l		PrtWrite,a1
		bsr		DeleteExtIO

.Error2		move.l		PrtWPort,a0
		bsr		DeletePort
		
		moveq.l		#0,d0
		rts

		*****************************************
		*	  Close Printer Device		*
		*****************************************

; All IO must have completed prior to calling this routine else there will
;be unanswered messages qued at port when it is released :-(

ClosePrt	move.l		PrtWrite,a1
		CALLEXEC	CloseDevice

		move.l		PrtWrite,a1
		bsr		DeleteExtIO

		move.l		PrtWPort,a0
		bsr		DeletePort
		
		rts
		
		*****************************************
		*	  Open Main Window		*
		*****************************************

; Opens an intuition window. If d0=0 on return then window could not be
;opened.

OpenWin		lea		LabelWin,a0		a0->window args
		CALLINT		OpenWindow		and open it
		move.l		d0,window.ptr		save struct ptr
		beq		.win_error		quit if error

		move.l		d0,a0			  ;a0->win struct	
		move.l		wd_UserPort(a0),window.up ;save up ptr
		move.l		wd_RPort(a0),window.rp    ;save rp ptr

; Get window signal bit

		move.l		window.up,a0
		moveq.l		#1,d0
		moveq.l		#0,d1
		move.b		MP_SIGBIT(a0),d1
		asl.l		d1,d0
		move.l		d0,WinSigMask
		or.l		PrtSigMask,d0
		move.l		d0,TheSigMask
		
; Display window gfx

		move.l		window.rp,a0		a0->windows RastPort
		lea		WindowGfx,a1		a1->Image structure
		moveq.l		#0,d0			X offset
		moveq.l		#0,d1			Y offset
		CALLSYS		DrawImage		display gfx

; Attach gadgets and refresh them

		move.l		window.ptr,a0		Window
		lea		LoadGadg,a1		Gadget
		moveq.l		#0,d0			position
		moveq.l		#9,d1			num gadgets
		suba.l		a2,a2			no requester
		CALLSYS		AddGList

; Set gadgets to default values for 1 copy of a 3" by 3" label

		lea		WidthGadg,a0
		move.l		#2750,d0
		bsr		BuildIntStr

		lea		HeightGadg,a0
		move.l		#2500,d0
		bsr		BuildIntStr

		lea		CopiesGadg,a0
		moveq.l		#1,d0
		bsr		BuildIntStr

		lea		LoadGadg,a0		Gadget
		move.l		window.ptr,a1		Window
		suba.l		a2,a2			Requester
		moveq.l		#9,d0			num gadgets
		CALLSYS		RefreshGList		display them

; Obtain a file requester structure

		moveq.l		#RT_FILEREQ,d0		structure required
		suba.l		a0,a0			tag list
		CALLREQ		rtAllocRequestA		get structure
		move.l		d0,LoadIffReq		save addr

		moveq.l		#1,d0			no errors

.win_error	rts					all done so return

		*****************************************
		*	  Close Main Window		*
		*****************************************

CloseWin	move.l		LoadIffReq,d0
		beq.s		.close
		move.l		d0,a1
		CALLREQ		rtFreeRequest

.close		move.l		window.ptr,a0		a0->Window struct
		CALLINT		CloseWindow		and close it

		rts

		*****************************************
		*	  Open Required Libraries	*
		*****************************************

; Open Reqtools library.

; If d0=0 on return then one or more libraries are not open.

OpenLibs	lea		reqname,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_reqBase		save base ptr

; reqtools opens DOS, Intuition and Graphics libraries and we can use the
;base pointers stored in it's base structure :-)

		move.l		d0,a0			a0->library base
		move.l		rt_IntuitionBase(a0),_IntuitionBase
		move.l		rt_GfxBase(a0),_GfxBase
		move.l		rt_DOSBase(a0),_DOSBase

		rts

		*****************************************
		*	  Close All Libraries		*
		*****************************************

; Closes any libraries the program managed to open.

CloseLibs	move.l		_reqBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.lib_error	rts

		*****************************************
		*	  Include Subroutine & Data	*
		*****************************************

		include		exec_support.i
		include		ILBM.code.s
		include		LabelWin.i

		*****************************************
		*	  Itialised Variables		*
		*****************************************

		dc.b		'$VER: LabelPrint v'
		REVISION
		dc.b		', © M.Meany '
		REVDATE
		dc.b		' )',0
		even

reqname		dc.b		'reqtools.library',0
		even
prtport		dc.b		'AmiganutsPrtWrite',0
		even
prtname		dc.b		'printer.device',0
		even

OpenText	dc.b		'    Amiganuts Label Printer     ',$0a
		dc.b		'         Release Version ',$0a,$0a
		
		dc.b		'   Programmed by Mark Meany.    ',$0a,$0a
		
		dc.b		' Credits to    Steve Marshall   ',$0a
		dc.b		'               Dave Edwards     ',$0a,$0a
		
		dc.b		'Reqtools.library © Nico François',0
		even

OpenReq		dc.b		'Okay',0
		even
		
QuitText	dc.b		'Are you sure you wish to quit?',$0a
		dc.b		' Please confirm your request.',0
		even

QuitReq		dc.b		'Cancel|Confirm',0
		even

Err1Text	dc.b		'Unable To Lock The Directory',$0a
		dc.b		' Containing Selected File !',0
		even

Err2Text	dc.b		'Unable To Open Selected File!',0
		even

Err3Text	dc.b		'IFF file incorrect dimensions.',$0a
		dc.b		'MUST be 200x90x2 ( 4 Colours ).',$0a
		dc.b		'File Selected: %dx%dx%d !',0
		even

Err4Text	dc.b		'Printer Error Has Occurred.',$0a
		dc.b		'    Aborting Operation',0
		even

Err5Text	dc.b		'Print Job Aborted!',0
		even

DevText		dc.b		'Selected File Locked & Waiting',0
		even
		
ErrReq		dc.b		'Abort',0
		even
QuitTags	dc.l		RT_ReqPos,REQPOS_CENTERSCR
		dc.l		RTEZ_ReqTitle,QuitTitle
		dc.l		TAG_DONE

QuitTitle	dc.b		'              Amiganuts',0
		even

LoadTags	dc.l		RT_ReqPos,REQPOS_CENTERSCR	centralise
		dc.l		RTFI_Flags,FREQF_PATGAD
		dc.l		TAG_DONE

LoadTitle	dc.b		'Select IFF File To Load',0
		even

; Error Messages associated with SM's IFF loader

IFLErr		dc.l		IFLErr1
		dc.l		IFLErr2
		dc.l		IFLErr3
		dc.l		IFLErr4
		
IFLErr1		dc.b		'Insufficient Memory To Load File!',0
		even
IFLErr2		dc.b		'IFF Compression Error Encountered',0
		even
IFLErr3		dc.b		'Not An IFF-ILBM File!',0
		even
IFLErr4		dc.b		'DOS Error %ld Occurred!',0
		even		

		*****************************************
		*	  Uninitialised Variables	*
		*****************************************

		section		vars,BSS

_reqBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1
_DOSBase	ds.l		1

WinSigMask	ds.l		1		signal mask for window
PrtSigMask	ds.l		1		signal mask for printer
TheSigMask	ds.l		1		combined signals

PrtWPort	ds.l		1		Port for serial writes
PrtWrite	ds.l		1		IO write structure

window.ptr	ds.l		1
window.rp	ds.l		1
window.up	ds.l		1

ImageX		ds.w		1
ImageY		ds.w		1
ImageW		ds.w		1
ImageH		ds.w		1

LoadIffReq	ds.l		1		pointer to file request struc
FileName	ds.b		82		filename buffer

IFFStruc	ds.l		1		pointer to SM structure

ReqDStream	ds.l		4

PrintRastPort	ds.b		rp_SIZEOF	Dummy RastPort for printing

		section		bdata,data_c

WindowIm	incbin		labelprint.bm
