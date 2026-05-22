
; This utility will allow the user to load a raw data file and save it as
;an object module ready for linking by Blink. Believe it or not it produces
;a Lattice C object module!

; The object file format was decided on by studying Linkable files produced
;by Devpac II.

; This utility is intended as a suplement for the ACC project.

; © M.Meany, June 1991.

;		opt 		o+

		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"
		include		"misc/arpbase.i"

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"
		

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
		
;--------------	the ARP library opens and uses the graphics and intuition 
;		libs and it is quite legal for us to get these bases for 
;		our own use

		move.l		IntuiBase(a6),_IntuitionBase
		move.l		GFXBase(a6),_GfxBase

		bsr.s		Openwin		open window
		tst.l		d0		any errors?
		beq.s		no_win		if so quit

		bsr		WaitForMsg	wait for user

		bsr		Closewin	close our window

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
		move.l		#1,d0		no errors

.win_error	rts				return

;--------------
;--------------	Deal with gadget selection.
;--------------

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

		moveq.l		#1,d7		 set flag for no quit
		cmp.l		#CLOSEWINDOW,d2  window closed ?
		bne.s		.test_GUP	 if not then jump
		moveq.l		#0,d7		 else set quit flag
		bra.s		.done		 and quit

.test_GUP	and.l		#GADGETUP!GADGETDOWN,d2
		beq.s		.done
		move.l		gg_UserData(a5),a0
		jsr		(a0)

.done		tst.l		d7
		bne.s		WaitForMsg
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


;***********************************************************
;	Subroutines called by gadgets 
;***********************************************************

;--------------
;--------------	Deal with CHIP gadget selection
;--------------

SelectChip
	lea		ChipGadg(pc),a1		;get first excluded gadget
	moveq		#2,d0			;number of excluded gadgets
	bsr		RemoveGad		;and remove them from window
	move.w		#SELECTED,d1		;get SELECTED mask
	lea		ChipGadg(pc),a1		;get this gadget
	or.w		d1,gg_Flags(a1)		;select this gadget
	not.w		d1			;invert mask
	lea		FastGadg(pc),a1		;get other gadget
	and.w		d1,gg_Flags(a1)		;and un-select it
	
	lea		ChipGadg(pc),a1		;get first gadget again
	moveq		#2,d1			;and number of gadgets
	bsr		AddGad			;add them back + refresh

	move.w		#0,Mem			set flag for CHIP mem
	rts
	
;--------------
;-------------- Deal with FAST gadget selection
;--------------

SelectFast
	lea		ChipGadg(pc),a1
	moveq		#2,d0
	bsr		RemoveGad
	move.w		#SELECTED,d1
	lea		FastGadg(pc),a1
	or.w		d1,gg_Flags(a1)
	not.w		d1
	lea		ChipGadg(pc),a1
	and.w		d1,gg_Flags(a1)
	
	moveq		#2,d1
	bsr		AddGad

	move.w		#1,Mem			set flag for FAST mem
	rts

;--------------
;--------------	Remove last two gadgets from list
;--------------

RemoveGad
	move.l		window.ptr,a0
	CALLINT		RemoveGList
	rts

;--------------
;-------------- Add last two gadgets back to list
;--------------

AddGad
	movem.l		d1/a1,-(sp)		;save d1,a1 numgad,gadget
	move.l		window.ptr,a0		;get window ptr
	sub.l		a2,a2			;clear a2
	CALLINT		AddGList		;d0 should remain unchanged
	move.l		window.ptr,a1		;since RemoveGList
	movem.l		(sp)+,d0/a0		;set up d0,a0 numgad,gadget  
	CALLSYS		RefreshGList		;refresh gadgets	
	rts		

;--------------
;-------------- Deal with QUIT gadget selection
;--------------

Quit	move.l		#0,d7			set quit flag
	rts

;--------------
;-------------- Do Nothing routine for Label gadget
;--------------

DoDo	rts					do nothing routine

;--------------
;-------------- Deal with FROM deactivation
;--------------

FromSet		lea		ToGadg,a0	gadget
		move.l		window.ptr,a1	window
		sub.l		a2,a2		not requester
		CALLINT		ActivateGadget	activate it
		rts

;--------------
;-------------- Deal with TO deactivation
;--------------

ToSet		lea		LabelGadg,a0	gadget
		move.l		window.ptr,a1	window
		sub.l		a2,a2		not requester
		CALLINT		ActivateGadget	activate it
		rts
		
;--------------
;-------------- Allow user to set FROM filename using ARP requester
;--------------

SetFileName	bsr		Load

		move.l		#1,d0		num of gadgets
		lea		FromGadg,a0	gadget
		move.l		window.ptr,a1	window
		sub.l		a2,a2		no requester
		CALLINT		RefreshGList	refresh it

		rts

;--------------
;-------------- Deal with CONVERT gadget selection
;--------------

DoConversion	tst.b		Label		make sure theres a label
		beq.s		.error		if not don't convert
		tst.b		FromFile	make sure theres a src file
		beq.s		.error		if not don't convert
		tst.b		ToFile		make sure theres a dst file
		beq.s		.error		if not dont convert

		bsr		PointerOn	custom sleepy pointer

		bsr		ConObj		convert the file

		bsr		PointerOff	normal pointer

.error		rts

;--------------
;-------------- The routine that actualy converts the raw file
;--------------

;-------------- determine length of from file

ConObj		lea		FromFile,a0	filename
		bsr		FileLen		call subroutine
		tst.l		d0		test result
		beq		.error		leave if error

;-------------- correct to long word and save in DLen

		addq.l		#3,d0
		and.l		#$fffffffc,d0
		move.l		d0,DLen

;-------------- div by 4 and save in DataLen

		move.l		d0,d1		copy of len
		asr.l		#2,d1		div by 4
		move.l		d1,DataLen	and write into header

;-------------- alloc mem for input file
;   d0 still holds num of bytes to allocate

		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1 requirements
		CALLEXEC	AllocMem
		move.l		d0,FileBuff		save its address
		move.l		d0,d6			and a work copy

;-------------- open, read in and close the file

		move.l		#FromFile,d1		d1=addr of filename
		move.l		#MODE_OLDFILE,d2	d2=access mode
		CALLARP		Open			and open it
		move.l		d0,d7			save handle
		beq		.error1			quit if not open

		move.l		d0,d1			handle
		move.l		d6,d2			buffer
		move.l		DLen,d3			num of bytes
		CALLSYS		Read			read in data

		move.l		d7,d1			handle
		CALLSYS		Close			and close it

;-------------- clear label buffer

		moveq.l		#0,d0			constant
		moveq.l		#7,d1			counter
		lea		LabelBuff,a0		addr of buffer

.loop		move.l		d0,(a0)+		clear buffer
		dbra		d1,.loop

;-------------- determine length of label while copying to buffer

		moveq.l		#0,d0			counter
		lea		Label,a0		addr of label
		lea		LabelBuff,a1		addr of buffer

.loop1		move.b		(a0)+,d1		get next char
		beq.s		.done_copying		quit if $0
		move.b		d1,(a1)+		copy char
		addq.l		#1,d0			bump counter
		bra.s		.loop1			and loop back

;-------------- correct for long word and save in LabelLen

.done_copying	addq.l		#3,d0
		asr.l		#2,d0			div by 4
		move.w		d0,LabelLen

;-------------- determine mem type required and save in MemType

		move.l		#$4000,d0		default CHIP
		tst.w		Mem			test flag
		beq.s		.want_chip		jump if clear
		asl.w		#1,d0			else x2 FAST
.want_chip	move.w		d0,MemType		and save in header

;-------------- open To file

		move.l		#ToFile,d1		filename
		move.l		#MODE_NEWFILE,d2	access mode
		CALLSYS		Open			and open it
		move.l		d0,d7			save handle
		beq		.error1			quit if not open

;-------------- write header

		move.l		d0,d1			handle
		move.l		#Head,d2		data addr
		move.l		#Head_len,d3		size in bytes
		CALLSYS		Write			and write it

;-------------- write data

		move.l		d7,d1			handle
		move.l		d6,d2			data addr
		move.l		DLen,d3			size in bytes
		CALLSYS		Write			and write it

;-------------- write insert1

		move.l		d7,d1			handle
		move.l		#Ins1,d2		data addr
		move.l		#Ins1_len,d3		size in bytes
		CALLSYS		Write			and write it

;-------------- write label

		move.l		d7,d1			handle
		move.l		#LabelBuff,d2		data addr
		moveq.l		#0,d3
		move.w		LabelLen,d3		size in longs
		asl.l		#2,d3			size in bytes
		CALLSYS		Write			and write it

;-------------- write insert2

		move.l		d7,d1			handle
		move.l		#Ins2,d2		data addr
		move.l		#Ins2_len,d3		size in bytes
		CALLSYS		Write			and write it

;-------------- close file

		move.l		d7,d1			handle
		CALLSYS		Close			and close file

;-------------- release memory for data

.error1		move.l		d6,a1			buffer addr
		move.l		DLen,d0			size in bytes
		CALLEXEC	FreeMem			and free it

;-------------- all done so quit

.error		rts

;--------------
;--------------	Routine to display custom 'sleeping' pointer
;--------------

PointerOn	move.l		window.ptr,a0
		lea		newptr,a1
		moveq.l		#16,d0
		move.l		d0,d1
		moveq.l		#0,d2
		move.l		d2,d3
		CALLINT		SetPointer
		rts

;--------------
;--------------	Routine to display default Intuition pointer
;--------------

PointerOff	move.l		window.ptr,a0
		CALLINT		ClearPointer
		rts

*****************************************************************************
*			Subroutines section				    *
*****************************************************************************

;--------------
;--------------	Subroutine that returns the length of a file in bytes.
;--------------

; Entry		a0 = address of file name

; Exit		d0 = length of file in bytes or 0 if any error occurred

; Corrupted	a0

; M.Meany, Feb 91


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
		CALLARP		Lock
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

;--------------
;-------------- Call the ARP filerequester to obtain FROM filename
;--------------
		
Load:	lea		LoadFileStruct,a0	;get file struct
	CALLARP		FileRequest 		;and open requester
	tst.l		d0			;did the user cancel ?
	beq		NoPath			;yes then quit
	lea		LoadFileStruct,a0	;get file struct
	bsr		CreatePath		;make full pathname
	moveq.l		#0,d0			;reset flag
	tst.b		FromFile		;is there a pathname ?
	beq.s		NoPath			;no - then quit
	moveq.l		#1,d0			;else set flag
NoPath
	rts					;and return to calling routine
	
;***********************************************************
;	General subroutines called by anybody
;***********************************************************

;Subroutine to create a single pathname from the seperate directory
;and filename strings.Adds ':' or '/' as needed.Called by

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


*****************************************************************************
*			Data Section					    *
*****************************************************************************

RFfile_name	dc.l		0
RFfile_lock	dc.l		0
RFfile_info	dc.l		0
RFfile_len	dc.l		0

FileBuff	dc.l	0		addr of mem to read data into

DLen		dc.l	0		data length in bytes
LLen		dc.w	0		label length in bytes

Mem		dc.w	0		flag 0=CHIP 1=FAST

;--------------	Object file data structure parts

LabelBuff	dcb.l	8,0		label buffer

Head		dc.w	$0000,$03E7
		DC.W	$0000,$0003
		DC.B	'ANON'
		DC.B	'_MOD'
		DC.B	'ULE',0
		DC.W	$0000,$03E8
		DC.W	$0000,$0001
		DC.W	$4D41,$524B
MemType		DC.W	$0000,$03EA
DataLen		DC.W	$0000,$0000

Head_len	equ	*-Head		length of header

Ins1		DC.W	$0000,$03EF
		DC.W	$0100
LabelLen	DC.W	$0000

Ins1_len	equ	*-Ins1		length of first insert

Ins2		DC.W	$0000,$0000
		DC.W	$0000,$0000
		DC.W	$0000,$03F2

Ins2_len	equ	*-Ins2		length of second insert

;***********************************************************
;	FileRequester Structures
;***********************************************************


;------	hail text is what will appear in requesters window title	

Requesterflags	EQU	0

LoadFileStruct:
	dc.l		LoadText	;pointer to hail text
	dc.l		LoadFileData	;pointer to filename buffer
	dc.l		LoadDirData	;pointer to path buffer
	dc.l		0		;window to attach to - none if on WB
	dc.b		Requesterflags	;flags - none
	dc.b		0		;reserved
	dc.l		0		;fr_Function
	dc.l		0		;reserved2

;------	this is not part of the Filerequest structure but is our
;	extension and can be accessed using the fr_SIZEOF offset
	dc.l		FromFile

LoadText:
	dc.b	'MyMore © M.Meany 1990 ',0
	even


;***********************************************************
;	Window and Gadget defenitions
;***********************************************************


MyWindow	dc.w		101,9
		dc.w		400,190
		dc.b		1,2
		dc.l		GADGETDOWN+GADGETUP+CLOSEWINDOW
		dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
		dc.l		SetGadg
		dc.l		0
		dc.l		WindowName
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

WindowName	dc.b		' Objector v1.0 © M.Meany, June 1991 ',0
		even

SetGadg		dc.l		FromGadg
		dc.w		204,23
		dc.w		140,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border1
		dc.l		0
		dc.l		IText1
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		SetFileName

Border1		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors1
		dc.l		0

BorderVectors1	dc.w		0,0
		dc.w		143,0
		dc.w		143,12
		dc.w		0,12
		dc.w		0,0

IText1		dc.b		1,0,RP_JAM2,0
		dc.w		23,2
		dc.l		0
		dc.l		ITextText1
		dc.l		0

ITextText1	dc.b		'SET FILENAME',0
		even

FromGadg	dc.l		ToGadg
		dc.w		90,45
		dc.w		298,8
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		Border2
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		FromGadgSInfo
		dc.w		0
		dc.l		FromSet

FromGadgSInfo	dc.l		FromFile
		dc.l		0
		dc.w		0
		dc.w		DSIZE+FCHARS+2
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

Border2		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors2
		dc.l		0

BorderVectors2	dc.w		0,0
		dc.w		301,0
		dc.w		301,9
		dc.w		0,9
		dc.w		0,0

ToGadg		dc.l		LabelGadg
		dc.w		90,65
		dc.w		298,8
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		Border3
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		ToGadgSInfo
		dc.w		0
		dc.l		ToSet

ToGadgSInfo	dc.l		ToFile
		dc.l		0
		dc.w		0
		dc.w		DSIZE+FCHARS+2
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

Border3		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors3
		dc.l		0

BorderVectors3	dc.w		0,0
		dc.w		301,0
		dc.w		301,9
		dc.w		0,9
		dc.w		0,0

LabelGadg	dc.l		QuitGadg
		dc.w		150,105
		dc.w		200,8
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		Border4
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		LabelGadgSInfo
		dc.w		0
		dc.l		DoDo

LabelGadgSInfo	dc.l		Label
		dc.l		0
		dc.w		0
		dc.w		32
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

Label		dcb.b 32,0
		even

Border4		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors4
		dc.l		0

BorderVectors4	dc.w		0,0
		dc.w		203,0
		dc.w		203,9
		dc.w		0,9
		dc.w		0,0

QuitGadg	dc.l		ConvertGadg
		dc.w		37,161
		dc.w		101,14
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border5
		dc.l		0
		dc.l		IText2
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		Quit

Border5		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors5
		dc.l		0

BorderVectors5	dc.w		0,0
		dc.w		104,0
		dc.w		104,15
		dc.w		0,15
		dc.w		0,0

IText2		dc.b		1,0,RP_JAM2,0
		dc.w		25,3
		dc.l		0
		dc.l		ITextText2
		dc.l		0

ITextText2	dc.b		' QUIT ',0
		even

ConvertGadg	dc.l		ChipGadg
		dc.w		234,160
		dc.w		101,14
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border6
		dc.l		0
		dc.l		IText3
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		DoConversion

Border6		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors6
		dc.l		0

BorderVectors6	dc.w		0,0
		dc.w		104,0
		dc.w		104,15
		dc.w		0,15
		dc.w		0,0

IText3		dc.b		1,0,RP_JAM2,0
		dc.w		21,3
		dc.l		0
		dc.l		ITextText3
		dc.l		0

ITextText3	dc.b		'CONVERT',0
		even

ChipGadg	dc.l		FastGadg
		dc.w		148,83
		dc.w		102,13
		dc.w		SELECTED!GADGIMAGE
		dc.w		GADGIMMEDIATE
		dc.w		BOOLGADGET
		dc.l		Image1
		dc.l		0
		dc.l		IText4
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		SelectChip

IText4		dc.b		3,0,RP_JAM1,0
		dc.w		33,3
		dc.l		0
		dc.l		ITextText4
		dc.l		0

ITextText4	dc.b		'CHIP',0
		even

FastGadg	dc.l		0
		dc.w		255,83
		dc.w		102,13
		dc.w		GADGIMAGE
		dc.w		GADGIMMEDIATE
		dc.w		BOOLGADGET
		dc.l		Image1
		dc.l		0
		dc.l		IText5
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		SelectFast

IText5		dc.b		3,0,RP_JAM1,0
		dc.w		33,3
		dc.l		0
		dc.l		ITextText5
		dc.l		0

ITextText5	dc.b		'FAST',0
		even


WinText		dc.b		1,0,RP_JAM2,0
		dc.w		15,25
		dc.l		0
		dc.l		ITextText6
		dc.l		IText7

ITextText6	dc.b		'Set SOURCE Filename ',0
		even

IText7		dc.b		1,0,RP_JAM2,0
		dc.w		15,45
		dc.l		0
		dc.l		ITextText7
		dc.l		IText8

ITextText7	dc.b		'SOURCE ',0
		even

IText8		dc.b		1,0,RP_JAM2,0
		dc.w		15,65
		dc.l		0
		dc.l		ITextText8
		dc.l		IText9

ITextText8	dc.b		'DEST   ',0
		even

IText9		dc.b		1,0,RP_JAM2,0
		dc.w		33,135
		dc.l		0
		dc.l		ITextText9
		dc.l		IText10

ITextText9	dc.b		'Reads raw data from SOURCE file and creates',0
		even

IText10		dc.b		1,0,RP_JAM2,0
		dc.w		79,145
		dc.l		0
		dc.l		ITextText10
		dc.l		IText11

ITextText10	dc.b		'a linkable object file, DEST.',0
		even

IText11		dc.b		1,0,RP_JAM2,0
		dc.w		15,85
		dc.l		0
		dc.l		ITextText11
		dc.l		IText12

ITextText11	dc.b		'Memory Type ',0
		even

IText12		dc.b		1,0,RP_JAM2,0
		dc.w		15,105
		dc.l		0
		dc.l		ITextText12
		dc.l		0

ITextText12	dc.b		'Data Label  ',0
		even

Image1
	dc.w	0,0
	dc.w	102,13
	dc.w	2
	dc.l	ImageData1
	dc.b	$0003,$0000
	dc.l	0

;***********************************************************
	SECTION	FileRequest,BSS
;***********************************************************

_ArpBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

window.ptr	ds.l		1
window.rp	ds.l		1
window.up	ds.l		1

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

********************************************************************
	SECTION	ImageData,DATA_C
********************************************************************


ImageData1
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FC00,$C000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0C00,$C000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0C00,$C000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0C00,$C000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0C00,$C000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0C00,$C000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0C00,$C000,$0000,$0000,$0000,$0000,$0000,$0C00
	dc.w	$C000,$0000,$0000,$0000,$0000,$0000,$0C00,$C000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0C00,$C000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0C00,$C000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0C00,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FC00,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$03FF,$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$F3FF,$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF
	dc.w	$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF,$3FFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF,$3FFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$F3FF,$3FFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$F3FF,$3FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$F3FF,$3FFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$F3FF,$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$F3FF,$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF
	dc.w	$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$03FF


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


