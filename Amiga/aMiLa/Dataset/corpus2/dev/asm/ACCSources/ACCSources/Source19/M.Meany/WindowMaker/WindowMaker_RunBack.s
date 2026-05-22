
*****	Title		WindowMaker_RunBack
*****	Function	Design an Intuition window and generate assembler
*****			source for it.
*****	Size		11250 bytes.
*****	Author		Mark Meany
*****	Date Started	30th November 1991
*****	This Revision	4th Dec 1991
*****	Notes		Full IDCMP monitoring & New facility. Also added
*****			status line display. Menu selections activate an
*****			error message for verification. Extended status
*****			reports and added load/save of raw data files.
*****			Added save source routine.
*****			Added window defenition editor.
*****			Added ARP filerequester to all load/save routines.
*****			Added a file header to raw data files for
*****			identification by Load routine.
*****			Added Run Back startup code, program now frees itself
*****			from the CLI.

;--------------	First, as always, the includes.

		incdir		sys:Include/
		include		exec/exec_lib.i
		include		exec/memory.i
		include		libraries/dosextens.i
		include		intuition/intuition.i
		include		intuition/intuition_lib.i
		include		misc/arpbase.i

; The following startup routine supplied by Trev of Artwerks, Cheers!
;If run from CLI, it frees itself.

		include		source:include/BackStart.i

;--------------	Now the program itself.

Start		OPENARP				open ARP library

		movem.l		(sp)+,d0/a0	clear stack
		move.l		a6,_ArpBase 	save base pointer

; Obtain pointers to libs open by arp.

		move.l		IntuiBase(a6),_IntuitionBase
		move.l		GFXBase(a6),_GfxBase

; Call main program

		bsr		Main		Get on with it

; Close libraries

Error1		move.l		_ArpBase,a1	a1->lib base
		CALLEXEC	CloseLibrary	and close it

		rts				end of program!

;--------------	
;--------------	Subroutines
;--------------	

;--------------	The Main routine

Main		bsr.s		Init		init variables
		tst.l		d0		any errors?
		beq.s		.error		if so quit

		bsr		OpenEdit	open editor window
		tst.l		d0		any errors?
		beq.s		.error1		if so quit

		bsr		OpenUser	open users window
		tst.l		d0		any errors?
		beq.s		.error2		if so quit

		bsr		Interaction	deal with user

		bsr		CloseUser	close user window

.error2		bsr		CloseEdit	close editor window

.error1		bsr		DeInit		release allocated memory

.error		rts				and finish


;--------------	Data Initialisation

; Allocate a block of memory for variable storage

Init		move.l		#VarsSize,d0		    size of block
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1  type of mem
		CALLEXEC	AllocMem
		tst.l		d0			    allocation ok?
		beq.s		.error			    if not quit

		move.l		d0,a4			    a4->vars mem

; Initialise file requeser structures

		moveq.l		#0,d0
		
		lea		LoadFileStruct(a4),a0
		move.l		#LoadText,(a0)+
		lea		LoadFileData(a4),a1
		move.l		a1,(a0)+
		lea		LoadDirData(a4),a1
		move.l		a1,(a0)+
		addq.l		#4,a0
		move.b		d0,(a0)
		lea		LoadFileStruct(a4),a0
		lea		LoadPathName(a4),a1
		move.l		a1,fr_SIZEOF(a0)
		
		lea		SaveFileStruct(a4),a0
		move.l		#SaveText,(a0)+
		lea		SaveFileData(a4),a1
		move.l		a1,(a0)+
		lea		SaveDirData(a4),a1
		move.l		a1,(a0)+
		addq.l		#4,a0
		move.b		d0,(a0)
		lea		SaveFileStruct(a4),a0
		lea		SavePathName(a4),a1
		move.l		a1,fr_SIZEOF(a0)

		or.b		#FRF_DoColor,d0

		lea		SaveSFileStruct(a4),a0
		move.l		#SaveSourceText,(a0)+
		lea		SaveSFileData(a4),a1
		move.l		a1,(a0)+
		lea		SaveSDirData(a4),a1
		move.l		a1,(a0)+
		addq.l		#4,a0
		move.b		d0,(a0)
		lea		SaveSFileStruct(a4),a0
		lea		SaveSPathName(a4),a1
		move.l		a1,fr_SIZEOF(a0)

.error		rts


;--------------	Data release

DeInit		move.l		a4,a1			address of block
		move.l		#VarsSize,d0		size of block
		CALLEXEC	FreeMem			and release it
		rts


;--------------	Open Editor window

OpenEdit	lea		EditorWindow,a0		a0->window structure
		CALLINT		OpenWindow		and open it
		
		move.l		d0,edit.ptr(a4)		save pointer
		beq.s		.error			quit if error

		move.l		d0,a0			a0->window struct
		move.l		wd_RPort(a0),edit.rp(a4) save rastport ptr
		move.l		wd_UserPort(a0),edit.up(a4) save port ptr

		lea		ProjectMenu,a1		a1->menu
		CALLINT		SetMenuStrip		attach menu

		moveq.l		#1,d0			no errors

.error		rts					and finish


;--------------	Close Editor Window

CloseEdit	move.l		edit.ptr(a4),a0		a0->window
		CALLINT		ClearMenuStrip		remove menu

		move.l		edit.ptr(a4),a0		a0->window
		CALLINT		CloseWindow		and close it

		rts					and finish


;--------------	Open User window

OpenUser	lea		UserWindow,a0		a0->window structure
		CALLINT		OpenWindow		and open it
		
		move.l		d0,user.ptr(a4)		save pointer
		beq.s		.error			quit if error

		move.l		d0,a0			a0->window struct
		move.l		wd_RPort(a0),user.rp(a4) save rastport ptr

.error		rts					and finish


;--------------	Close User Window

CloseUser	move.l		user.ptr(a4),a0		a0->window
		CALLINT		CloseWindow		and close it

		rts					and finish

;--------------	Interaction routine. Deals with user i/o.

; Display required message at status line in Main window

Interaction	lea		NoError,a0	a0->Ok. message
		bsr		ClearError	check for errors
		tst.l		d0		was there one?
		beq.s		.ok		if not skip

		move.l		d0,a0		a0->error message
.ok		move.l		a0,ErrMsgPtr	set error message

		move.l		edit.rp(a4),a0	a0->windows RastPort
		lea		StatusLine,a1	a1->Itext struct
		moveq.l		#0,d0		no x offset
		move.l		d0,d1		no y offset
		CALLINT		PrintIText	print status line

; Intuition event loop

WFM		move.l		edit.up(a4),a0	a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		edit.up(a4),a0	a0-->user port
		CALLEXEC	GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WFM		if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.w		im_Code(a1),d3	d3=key or menu detail
		move.l		im_IAddress(a1),a5 a5=addr of structure
		CALLEXEC	ReplyMsg	answer os or it get angry

; Check if a menu item was selected. If so get address of required subroutine
;and call it.

		cmp.l		#MENUPICK,d2	window closed ?
		bne.s		check_closed	if not then jump
		move.l		d3,d0		d0=menu number
		lea		ProjectMenu,a0	a0->start of menu
		CALLINT		ItemAddress	get addr of struct
		tst.l		d0		got it?
		beq.s		Interaction	if not loop back
		move.l		d0,a0		a0->item structure
		move.l		mi_ItemFill(a0),d0
		move.l		mi_SIZEOF(a0),a0 a0->required subroutine
		jsr		(a0)		call subroutine
		cmp.l		#CLOSEWINDOW,d2  window closed ?
		bne		Interaction	 if not then jump
		rts

; See if user has opted to quit. Quits without confirmation!

check_closed	cmp.l		#CLOSEWINDOW,d2  window closed ?
		bne.s		WFM	 if not then jump
		rts

;--------------	Error Handaling Routines

SetError	tst.l		ErrorNum(a4)	error set already?
		bne.s		.error		if so leave it alone
		move.l		d0,ErrorNum(a4)	if not set it now
.error		rts				and finish

ClearError	move.l		ErrorNum(a4),d0	set d0=error code
		move.l		#0,ErrorNum(a4)	clear error
		rts				and finish

;--------------	Open a new window for editing.

New		lea		UserWindow,a0		a0->window structure
		CALLINT		OpenWindow		and open it
		tst.l		d0			opened ok?
		bne.s		.ok			if so skip
		move.l		#ErrOpenUser,d0		set error code
		bsr.s		SetError
		bra.s		.error			and quit

.ok		move.l		d0,d7			save win pointer
		move.l		user.ptr(a4),a0		a0->old window
		CALLINT		CloseWindow		and close it

		move.l		d7,user.ptr(a4)		save pointer

		move.l		#ErrOpenOk,d0		set error=success
		bsr.s		SetError

.error		rts

;--------------	
;--------------	Load a raw file
;--------------	

; Use ARP filerequester to get a filename, return if none specified

Load		bsr.s		arpload
		beq.s		.load_error

		lea		LoadPathName(a4),a0
		move.l		a0,InFile		addr of pathname
		bsr		DoLoad

.load_error	rts

;--------------	
;--------------	Obtain name of file to load
;--------------	

; Uses ARP filerequester to get filename.
	
arpload		lea		LoadFileStruct(a4),a0	get file struct
		CALLARP		FileRequest 		and open requester
		tst.l		d0			did the user cancel ?
		bne.s		.ok			if not skip
		move.l		#ErrCancelSel,d0	else set error code
		bsr		SetError
		bra.s		.NoPath			and finish

.ok		lea		LoadFileStruct(a4),a0	get file struct
		move.l		fr_File(a0),a1
		tst.b		(a1)			check filename
		bne.s		.ok1			skip if exsists

		move.l		#ErrNoPathName,d0	else set error
		bsr		SetError
		bra.s		.NoPath			and finish


.ok1		bsr		CreatePath		make full pathname
		tst.b		LoadPathName(a4)	is there a pathname ?
.NoPath		rts					;and return to calling routine

;--------------	
;--------------	Save a raw file
;--------------	

; Use ARP filerequester to get filename, quit if none specified

SaveF		bsr.s		arpsave
		tst.b		SavePathName(a4)
		beq.s		.save_error

.ok		lea		SavePathName(a4),a0
		move.l		a0,OutFile
		bsr		DoSaveF

.save_error	rts

;--------------	
;--------------	Obtain name of file to save
;--------------	

arpsave		lea		SaveFileStruct(a4),a0	;get file struct
		CALLARP		FileRequest 		;and open requester 
		tst.l		d0			;did the user cancel ?
		bne.s		.ok			;yes then quit
		move.l		#ErrCancelSel,d0
		bsr		SetError
		bra.s		.NoPath

.ok		lea		SaveFileStruct(a4),a0	;get file struct
		move.l		fr_File(a0),a1
		tst.b		(a1)
		bne.s		.ok1
		move.l		#ErrNoPathName,d0
		bsr		SetError

		bra.s		.NoPath

.ok1		bsr.s		CreatePath		bsr.s		CreatePath		;make full pathname
.NoPath		rts					;and return to calling routine


;--------------	
;--------------	Save a source file
;--------------	

; Use ARP filerequester to get filename, quit if none specified

SaveS		bsr.s		arpsaves
		tst.b		SaveSPathName(a4)
		beq.s		.save_error

		lea		SaveSPathName(a4),a0
		move.l		a0,SourceFile
		bsr		DoSaveS

.save_error	rts

;--------------	
;--------------	Obtain name of file to save
;--------------	

arpsaves	lea		SaveSFileStruct(a4),a0	;get file struct
		CALLARP		FileRequest 		;and open requester 
		tst.l		d0			;did the user cancel ?
		bne.s		.ok			;yes then quit
		move.l		#ErrCancelSel,d0
		bsr		SetError
		bra.s		.NoPath

.ok		lea		SaveSFileStruct(a4),a0	;get file struct
		move.l		fr_File(a0),a1
		tst.b		(a1)
		bne.s		.ok1
		move.l		#ErrNoPathName,d0
		bsr		SetError
		bra.s		.NoPath

.ok1		bsr.s		CreatePath		;make full pathname
.NoPath		rts					;and return to calling routine

*****************************************************************************
;	General subroutines called by anybody
*****************************************************************************

;Subroutine to create a single pathname from the seperate directory
;and filename strings.Adds ':' or '/' as needed.

; CREDIT TO STEVE MARSHALL FOR THIS ROUTINE.

;CreatePath(FileRequest)
;		a0

;This routine assumes that a pointer to the pathname buffer
;is placed directly after the FileRequest structure.(My extension)
		

CreatePath:
	move.l		a2,-(sp)		;save a2
	move.l		a0,a2			;file struct to a2
	move.l		fr_Dir(a2),a0		;directory string to a0
	move.l		fr_SIZEOF(a2),a1	;get destination address
	moveq		#DSIZE,d0		;get size
	CALLEXEC	CopyMem			;and copy dir string
	
	move.l		fr_SIZEOF(a2),a0	;get path (dest) address
	move.l		fr_File(a2),a1		;get file string
	CALLARP		TackOn			;and tack onto dir string
	move.l		(sp)+,a2		;restore a2
	rts					;and quit


;--------------	Load a raw data file.

DoLoad		move.l		InFile,d1		filename
		move.l		#MODE_OLDFILE,d2	access mode
		CALLARP		Open			and open it
		move.l		d0,InHandle(a4)		save handle
		bne.s		.ok			skip if opened

		move.l		#ErrNoInFile,d0		set error code
		bsr		SetError
		bra		.error			and quit

.ok		move.l		d0,d7			safe copy

		move.l		d0,d1			handle
		lea		header(a4),a0		a0->buffer
		move.l		a0,d2			buffer
		moveq.l		#4,d3			buffer size
		CALLARP		Read			and read data

		cmp.l		#'Sara',header(a4)	header match?
		beq.s		.fileok			if so continue

		move.l		#ErrWrongHeader,d0	else set error
		bsr		SetError		value
		bra.s		.error			and quit

.fileok		move.l		d7,d1			handle
		lea		WinStruct(a4),a0	a0->buffer
		move.l		a0,d2			buffer
		move.l		#nw_SIZE+82,d3		buffer size
		CALLARP		Read			and read data

		move.l		InHandle(a4),d1		handle
		CALLARP		Close			close the file

		lea		WinStruct(a4),a0	a0->new win struct
		move.l		nw_IDCMPFlags(a0),Winidcmp(a4)  save IDCMP
		move.l		#0,nw_IDCMPFlags(a0)		and clear from nw

		lea		WinTitle(a4),a1		a1->window title
		move.l		a1,nw_Title(a0)		write into struct

		CALLINT		OpenWindow		and open loaded win
		tst.l		d0			open ok?
		bne.s		.ok1			if so skip

		move.l		#ErrOpenUser,d0		set error code
		bsr		SetError
		bra.s		.error			and quit

.ok1		move.l		d0,d7			save win pointer
		move.l		user.ptr(a4),a0		a0->old window
		CALLINT		CloseWindow		and close it

		move.l		d7,user.ptr(a4)		save pointer

		move.l		#ErrOpenOk,d0		set error=success
		bsr		SetError

.error		rts

;--------------	Save a raw data file.

DoSaveF		move.l		user.ptr(a4),a0		addr of window struct
		lea		WinStruct(a4),a1	addr of save buffer

; Copy details from windows structure into new window i/o buffer.

		move.w		wd_LeftEdge(a0),nw_LeftEdge(a1)
		move.w		wd_TopEdge(a0),nw_TopEdge(a1)
		move.w		wd_Width(a0),nw_Width(a1)
		move.w		wd_Height(a0),nw_Height(a1)
		move.b		wd_DetailPen(a0),nw_DetailPen(a1)
		move.b		wd_BlockPen(a0),nw_BlockPen(a1)
		move.l		Winidcmp(a4),nw_IDCMPFlags(a1)
		move.l		wd_Flags(a0),nw_Flags(a1)
		move.l		#0,nw_FirstGadget(a1)
		move.l		#0,nw_CheckMark(a1)
		move.l		#0,nw_Title(a1)
		move.l		#0,nw_Screen(a1)
		move.l		#0,nw_BitMap(a1)
		move.w		wd_MinWidth(a0),nw_MinWidth(a1)
		move.w		wd_MinHeight(a0),nw_MinHeight(a1)
		move.w		wd_MaxWidth(a0),nw_MaxWidth(a1)
		move.w		wd_MaxHeight(a0),nw_MaxHeight(a1)
		move.w		#$1,nw_Type(a1) 	WBENCHSCREEN

; Now copy windows title into buffer. No overflow check ( you'll know! ).

		move.l		wd_Title(a0),a0		a0->windows title
		lea		WinTitle(a4),a1		a1->buffer space
.loop		move.b		(a0)+,(a1)+		copy char
		bne.s		.loop			until end of name

; Open the file

		move.l		OutFile,d1		filename
		move.l		#MODE_NEWFILE,d2	access mode
		CALLARP		Open			and open it
		move.l		d0,OutHandle(a4)	save handle
		bne.s		.ok			skip if opened

		move.l		#ErrNoOutFile,d0	set error code
		bsr		SetError
		bra.s		.error			and finish

; Save file header

.ok		move.l		d0,d7			save handle
		move.l		d0,d1			handle
		lea		header(a4),a0		a0->buffer
		move.l		#'Sara',(a0)		write header
		move.l		a0,d2			buffer
		moveq.l		#4,d3			buffer size
		CALLARP		Write			and save it

; Now save raw data

		move.l		d7,d1			handle
		lea		WinStruct(a4),a0	a0->save buffer
		move.l		a0,d2			buffer
		move.l		#nw_SIZE+82,d3		buffer size
		CALLARP		Write			and save it

; Close the file

		move.l		OutHandle(a4),d1	handle
		CALLARP		Close			and close the file

; Set error message to signal save successfull

		move.l		#ErrSaveOk,d0		set error=success
		bsr		SetError

.error		rts					and finish

;--------------	Save out source code for window structure.

DoSaveS		move.l		#WinLabel,WinLab(a4)	copy addr of label

		move.l		user.ptr(a4),a0		a0->window
		lea		WinStruct(a4),a1	a1->DataStream

; Copy details from windows structure into new window i/o buffer.

		move.w		wd_LeftEdge(a0),nw_LeftEdge(a1)
		move.w		wd_TopEdge(a0),nw_TopEdge(a1)
		move.w		wd_Width(a0),nw_Width(a1)
		move.w		wd_Height(a0),nw_Height(a1)
		move.b		wd_DetailPen(a0),nw_DetailPen(a1)
		move.b		wd_BlockPen(a0),nw_BlockPen(a1)
		move.l		Winidcmp(a4),nw_IDCMPFlags(a1)
		move.l		wd_Flags(a0),nw_Flags(a1)
		move.l		#0,nw_FirstGadget(a1)
		move.l		#0,nw_CheckMark(a1)
		move.l		#TitleLabel,nw_Title(a1)
		move.l		#0,nw_Screen(a1)
		move.l		#0,nw_BitMap(a1)
		move.w		wd_MinWidth(a0),nw_MinWidth(a1)
		move.w		wd_MinHeight(a0),nw_MinHeight(a1)
		move.w		wd_MaxWidth(a0),nw_MaxWidth(a1)
		move.w		wd_MaxHeight(a0),nw_MaxHeight(a1)
		move.w		#$1,nw_Type(a1) 	WBENCHSCREEN
		lea		WinTitle(a4),a0
		move.l		a0,nw_SIZE(a1)

; Now copy windows title into buffer. No overflow check ( you'll know! ).

		move.l		user.ptr(a4),a0		a0->window struct
		move.l		wd_Title(a0),a0		a0->windows title
		lea		WinTitle(a4),a1		a1->buffer space
.loop		move.b		(a0)+,(a1)+		copy char
		bne.s		.loop			until end of name

; Use RawDoFmt() to generate source in RDFBuffer.

		move.l		#0,Count		zero buffer count

		lea		SourceTemplate,a0	a0->template
		lea		WinLab(a4),a1	a1->DataStream
		lea		PutChar,a2		a2->subroutine
		lea		RDFBuffer(a4),a3	a3->buffer
		CALLEXEC	RawDoFmt		and build text

; Now save data to source file. Open the file

		move.l		SourceFile,d1		filename
		move.l		#MODE_NEWFILE,d2	access mode
		CALLARP		Open			and open it
		move.l		d0,OutHandle(a4)	save handle
		bne.s		.ok			skip if opened

		move.l		#ErrNoSrcFile,d0	set error code
		bsr		SetError
		bra.s		.error			and finish

; Save the source

.ok		move.l		d0,d1			handle
		lea		RDFBuffer(a4),a0	a0->save buffer
		move.l		a0,d2			buffer
		move.l		Count,d3		buffer size
		subq.l		#1,d3			for NULL terminator
		CALLARP		Write			and save it

; And close the file

		move.l		OutHandle(a4),d1	handle
		CALLARP		Close			and close the file

		move.l		#ErrSaveSrcOk,d0	set error=success
		bsr		SetError

.error		rts					and finish


;--------------	User has selected About, display the message!

About		move.l		#AboutErr,d0
		bsr		SetError
		rts

;--------------	User has selected quit from menu, set d2=CLOSEWINDOW.

; Should add a confirmation mechanism to this!!!

Quit		move.l		#CLOSEWINDOW,d2		simulated quit!
		rts

;--------------	PutChar routine called by RawDoFmt()

; This version counts the number of bytes it copies

PutChar		move.b		d0,(a3)+		copy char
		addq.l		#1,Count		bump char counter
		rts

;--------------	Strings

WinLabel	dc.b		'YourWindow',0
		even
TitleLabel	dc.b		'.WinTitle',0
		even
LoadText	dc.b		'Load File ',0
		even
SaveText	dc.b		'Save File ',0
		even
SaveSourceText	dc.b		'Save Source File ',0
		even

;--------------	Template Data For RawDoFmt()

SourceTemplate	dc.b		';-------------	Source for window structure.',$0a
		dc.b		'%s',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'$%04x,$%04x',$09,'(x,y) orogin',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'$%04x,$%04x',$09,'width, height',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'$%04x',$09,$09,'detail & block pens',$0a
		dc.b		$09,$09,'dc.l',$09,$09,'$%08lx',$09,'IDCMP',$0a
		dc.b		$09,$09,'dc.l',$09,$09,'$%08lx',$09,'activation flags',$0a
		dc.b		$09,$09,'dc.l',$09,$09,'$%08lx',$09,'gadget pointer',$0a
		dc.b		$09,$09,'dc.l',$09,$09,'$%08lx',$09,'custom checkmark pointer',$0a
		dc.b		$09,$09,'dc.l',$09,$09,'%s',$09,'pointer to window title',$0a
		dc.b		$09,$09,'dc.l',$09,$09,'$%08lx',$09,'custom screen pointer',$0a
		dc.b		$09,$09,'dc.l',$09,$09,'$%08lx',$09,'custom bitmap pointer',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'$%04x,$%04x',$09,'min width, height',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'$%04x,$%04x',$09,'max width, height',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'$%04x',$09,$09,'screen type',$0a
		dc.b		'.WinTitle',$09,'dc.b',$09,$09,"'%s',0",$0a,$09,$09,'even',$0a,$0a
		dc.b		'; Source by WindowMaker, © M.Meany December 1991.',$0a,0
		even

;--------------	Variables

_ArpBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

OutFile		ds.l		1
InFile		ds.l		1
SourceFile	ds.l		1

Count		ds.l		1		character counter for RDF

;--------------	Include required files.

		include		editwinsubs.s		Subroutines
		include		vars.i			Variable Offsets
		include		editorwin.i		Main window defs
		include		userwin.i		User window defs
		include		editwin.i		Edit window defs
		include		errors.i		Error messages

