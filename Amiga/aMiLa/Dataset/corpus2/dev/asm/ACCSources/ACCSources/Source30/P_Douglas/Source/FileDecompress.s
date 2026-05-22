****************************************************************************
*
*			Utility for DeCompressing Data Files
*			    using PHD1 compression
*					
*			copyright Paul Douglas 1992
*
*				uses arp library
****************************************************************************

INTUITION_IOBSOLETE_I	set	1

		opt		c-

		incdir		sys:include/			include
		include		exec/exec_lib.i			files
		include		exec/exec.i	
		include		libraries/dos.i
		include		libraries/dosextens.i
		include		intuition/intuition_lib.i
		include		intuition/intuition.i		
		include		Source:P_Douglas/include/my_arpbase.i			

;note I've used a modified arpbase.i include file cos I had problems
;with the original one. Paul

		include		misc/easystart.i		include WB start

		OPT	O+,OW-					optimise please

****************************************************************************
;variables used in decompression

PHD_WorkspaceMem	equ	3670		
PHD_SafetyNet		equ	512
PHD_FileID		equ	'PHD'*256+1


Requesterflags		EQU	0
****************************************************************************

CALLSYS	MACRO				added CALLSYS macro - using CALLARP
	IFGT	NARG-1       		CALLINT etc can slow code down and  
	FAIL	!!!         		waste a lot of memory  
	ENDC                 		effectively calls last library opened
	JSR	_LVO\1(A6)
	ENDM
		
*****************************************************************************
*
*		 The main routine that opens and closes things
*	 OPENARP moved to front as it will print a message on the CLI then
*  	 return to easystart if it can't find the ARP library ,we don't
*                need to do any error checking of our own
*
*****************************************************************************

START

	OPENARP						use arp's own open macro
	movem.l		(sp)+,d0/a0			pop d0 and a0
	move.l		a6,_ArpBase			store arpbase
	move.l		IntuiBase(a6),_IntuitionBase	store intuition base
	move.l		GfxBase(a6),_GfxBase		store graphics base

	move.l		#PHD_WorkspaceMem,d0		allocate memory
	move.l		#MEMF_PUBLIC,d1			for Huffman buffer
	CALLARP		ArpAllocMem			roughly 4K 
	tst.l		d0				if cant alloc
	beq		.err1				exit
	lea		VariableBase(pc),a4		arp will auto dealloc on exit
	move.l		d0,WorkspacePtr(a4)		cor isnt it nice!!
	sf		FileMemAlloc(a4)		clear flag

	moveq.l		#Requesterflags,d0		initialise
	lea		LoadFileStruct(a4),a0		arp file
	move.l		#LoadText,(a0)+			requester
	lea		LoadFileData(a4),a1		structures
	move.l		a1,(a0)+
	lea		LoadDirData(a4),a1
	move.l		a1,(a0)+
	addq.l		#4,a0
	move.b		d0,(a0)
	lea		LoadFileStruct(a4),a0
	lea		LoadPathName(a4),a1
	move.l		a1,fr_SIZEOF(a0)
		
	or.b		#FRF_DoColor,d0
		
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

		
	lea		MainWindow(pc),a0		now open my main
	CALLINT		OpenWindow			window
	move.l		d0,window.ptr(a4)
	beq		.err1				goto error if fail

	move.l		d0,a0
	move.l		wd_RPort(a0),window.rp(a4)	get rastport
	move.l		wd_UserPort(a0),window.up(a4)	and userport

	move.l		window.rp(a4),a0		print text
	lea		window_text(pc),a1		in window
	moveq.l		#0,d0
	move.l		d0,d1
	CALLSYS		PrintIText

.WaitForMsg
	move.l		window.up(a4),a0		a0 window user port
	CALLEXE		WaitPort			wait for something to happen

	move.l		window.up(a4),a0		a0 window user port
	CALLSYS		GetMsg				get any messages

	tst.l		d0				was there a message ?
	beq		.WaitForMsg			if not loop back

	move.l		d0,a1				a1 message struct
	move.l		im_Class(a1),d2			d2=IDCMP flags
	move.l		im_IAddress(a1),a5 		a5=addr of structure

	CALLSYS		ReplyMsg			answer o/s or it gets angry

	cmp.l		#GADGETUP,d2			if gadgetup then a gagd
	bne.s		.WaitForMsg			been selected so goto gagd handler

	move.l		gg_UserData(a5),a0		get user data of gagdet
	jsr		(a0)				jump to handler
	beq		.WaitForMsg			if Z set then loop back

.Done	tst.b		FileMemAlloc(a4)		is a file loaded
	beq.s		.ok				if not dont worry

	move.l		FileMemPtr(a4),a1		else give mem back
	move.l		FileMemLen(a4),d0		to sys
	CALLSYS		FreeMem

.ok	move.l		window.ptr(a4),a0		exit program
	CALLINT		CloseWindow			close window

.err1	move.l		_ArpBase,a1			close arp library
	CALLEXE		CloseLibrary			also deallocs buffer mem

	rts						and return

*****************************************************************************
*		Quit subroutine		called when Quit gadget selected
*****************************************************************************
Quit	moveq.l		#1,d0				clear Z flag and return
	rts

*****************************************************************************
*		ABOUT subroutine	called when about gadget selected
*****************************************************************************
About	lea		about_win,a0			open my about 
	CALLINT		OpenWindow			window
	move.l		d0,about.ptr(a4)
	beq.s		.error				if error return

	move.l		d0,a0
	move.l		wd_RPort(a0),about.rp(a4)	get rastport
	move.l		wd_UserPort(a0),about.up(a4)	and userport

	move.l		about.rp(a4),a0			display info
	lea		AboutText(pc),a1		in the window
	moveq.l		#0,d0
	move.l		d0,d1
	CALLSYS		PrintIText
		
.WaitAbout
	move.l		about.up(a4),a0		a0 window user port
	CALLEXE		WaitPort		wait for something to happen

	move.l		about.up(a4),a0		a0 window user port
	CALLSYS		GetMsg			get any messages

	tst.l		d0			was there a message ?
	beq.s		.WaitAbout		if not loop back

	move.l		d0,a1			a1 message
	move.l		im_Class(a1),d2		d2=IDCMP flags

	CALLSYS		ReplyMsg		answer o/s or it gets angry

	cmp.l		#GADGETUP,d2		if gadget then OK selected
	bne.s		.WaitAbout		if not wait again

	move.l		about.ptr(a4),a0
	CALLINT		CloseWindow		close About window

.error	moveq		#0,d0			set Z and return
	rts

*****************************************************************************
*		LOAD subroutine		called when LOAD gadget selected
*****************************************************************************
Load	bsr		PointerOn		BUSY pointer on
	bsr		ClearLoadDetails	clear any results shown
	tst.b		FileMemAlloc(a4)	is a file loaded
	beq.s		.ok			if not dont worry

	move.l		FileMemPtr(a4),a1	else give mem back
	move.l		FileMemLen(a4),d0	to sys
	CALLEXE		FreeMem

.ok	sf		FileMemAlloc(a4)	clear mem allocated flag
	bsr		ArpLoad			get file name using arp req
	beq		.load_error		if error exit

	lea		LoadPathName(a4),a0	open the file
	move.l		a0,d1			d1 points to name of file
	move.l		#MODE_OLDFILE,d2
	CALLARP		Open
	move.l		d0,d4			put file handle in d4
	beq		.load_error		exit if error

	move.l		d4,d1			get handle in d1
	moveq		#0,d2
	moveq		#1,d3
	CALLSYS		Seek			seek to EOF
	move.l		d4,d1
	moveq		#0,d2
	moveq		#-1,d3
	CALLSYS		Seek			seek Start Of File

	move.l		d0,CompFileLen(a4)	got length in d0
	beq		.file_error		if error exit and close file

	move.l		d4,d1			get handle
	lea		LoadFileID(a4),a0	
	move.l		a0,d2
	moveq		#8,d3			read 8 bytes please
	CALLSYS		Read

	move.l		d4,d1
	moveq		#0,d2
	moveq		#-1,d3
	CALLSYS		Seek			reseek Start Of File

	cmp.l		#PHD_FileID,LoadFileID(a4)	check ID
	bne.s		.file_error		if not my type exit

	bsr		Calculate_Address	get load address and mem length

	move.l		FileMemLen(a4),d0	allocate memory
	move.l		#MEMF_PUBLIC,d1		for compressed file 
	CALLEXE  	AllocMem		
	move.l		d0,FileMemPtr(a4)	save addr of mem
	beq		.file_error		if error exit
	add.l		d0,CompFilePtr(a4)	add offset to mem ptr and store
	st		FileMemAlloc(a4)	set flag that we've got mem

	move.l		d4,d1			get file handle
	move.l		CompFilePtr(a4),d2	and copy file
	move.l		CompFileLen(a4),d3	into memory
	CALLARP		Read

	move.l		d4,d1			now close the
	CALLSYS		Close			file 

	move.l		CompFilePtr(a4),a0	pointer to compressed data
	move.l		FileMemPtr(a4),a1	pointer to where we want orig
	move.l		WorkspacePtr(a4),a2	pointer to workspace
	bsr		PHD_decompress

	bsr		DisplayLoadDetails	display name and length
	bra.s		.exit			skip error handlers to exit

.file_error
	move.l		d4,d1			we've had an error so close
	CALLARP		Close			file and exit 
.load_error
	sub.l		a0,a0			clear a0
	CALLINT		DisplayBeep		flash screen
.exit	bsr		PointerOff		turn off pointer
	moveq.l		#0,d0			and return
	rts

*****************************************************************************
*		Calculate Address to load file to, also memory size
*****************************************************************************
Calculate_Address
	move.l		OrigFileLen(a4),d0	get original length
	add.l		#PHD_SafetyNet,d0	add safety buffer
	move.l		d0,FileMemLen(a4)	save as mem required

	sub.l		CompFileLen(a4),d0	subtract compressed length
	subq.l		#4,d0			and a bit more
	and.b		#$fe,d0			make even offset
	move.l		d0,CompFilePtr(a4)	save the offset
	rts

*****************************************************************************
*		SAVE subroutine		called when SAVE gadget selected
*****************************************************************************
Save	bsr		PointerOn		busy pointer on
	tst.b		FileMemAlloc(a4)	is decompressed file in mem
	beq		.save_error		if not exit

	bsr.s		arpsave			get arp req for filename
	beq.s		.save_error		exit if error

	lea		SavePathName(a4),a0
	move.l		a0,d1
	move.l		#MODE_NEWFILE,d2	new file mode
	CALLARP		Open			open using arp
	move.l		d0,d7
	beq.s		.save_error

	move.l		d0,d1			copy decompressed
	move.l		FileMemPtr(a4),d2	data to file
	move.l		OrigFileLen(a4),d3
	CALLSYS		Write

	move.l		d7,d1			now close the
	CALLSYS		Close			file and exit
	bra.s		.ok

.save_error
	sub.l		a0,a0			if file wont open
	CALLINT		DisplayBeep		flash the screen
.ok	bsr		PointerOff		turn busy pointer off
	moveq.l		#0,d0			and return
	rts

*****************************************************************************
*		Get filename using arp requester
*****************************************************************************
ArpLoad	lea		LoadFileStruct(a4),a0		get file struct
	CALLARP		FileRequest 			and open requester
	tst.l		d0				did the user cancel ?
	beq.s		.NoPath
	lea		LoadFileStruct(a4),a0		get file struct
	move.l		fr_File(a0),a1
	tst.b		(a1)
	beq.s		.NoPath
	bsr		CreatePath			make full pathname
	tst.b		LoadPathName(a4)		is there a pathname ?
.NoPath	rts						and return to calling routine

*****************************************************************************
*		get save filename using arp requester
*****************************************************************************
ArpSave	lea		SaveFileStruct(a4),a0		get file struct
	CALLARP		FileRequest 			and open requester 
	tst.l		d0				did the user cancel ?
	beq.s		.NoPath				yes then quit
	lea		SaveFileStruct(a4),a0		get file struct
	move.l		fr_File(a0),a1
	tst.b		(a1)
	beq.s		.NoPath
	bsr.s		CreatePath			make full pathname
	tst.b		SavePathName(a4)
.NoPath	rts						and return to calling routine

*****************************************************************************
*		General subroutines called by anybody
*****************************************************************************
;Subroutine to create a single pathname from the seperate directory
;and filename strings.Adds ':' or '/' as needed.Called by

;CreatePath(FileRequest)
;		a0

;This routine assumes that a pointer to the pathname buffer
;is placed directly after the FileRequest structure.(My extension)
		
CreatePath:
	move.l		a2,-(sp)		save a2
	move.l		a0,a2			file struct to a2
	move.l		fr_Dir(a2),a0		directory string to a0
	move.l		fr_SIZEOF(a2),a1	get destination address
	moveq		#DSIZE,d0		get size
	CALLEXE 	CopyMem			and copy dir string
	
	move.l		fr_SIZEOF(a2),a0	get path (dest) address
	move.l		fr_File(a2),a1		get file string
	CALLARP		TackOn			and tack onto dir string
	move.l		(sp)+,a2		restore a2
	rts					and return

************************************************************************
*		Clear Load filename and length
************************************************************************
ClearLoadDetails
	bsr		ClearTextBuffer
	move.w		#203,d0			x co-ord
	move.w		#12,d1			y co-ord
	bsr		PrintMyText
	move.w		#203,d0
	move.w		#22,d1
	bsr		PrintMyText
	move.w		#203,d0
	move.w		#32,d1
	bsr		PrintMyText
	rts

************************************************************************
*		fill text buffer with spaces
************************************************************************
ClearTextBuffer
	lea		TextBuffer(pc),a3	get buffer in a3
	move.l		#'    ',d0
	moveq		#3,d1			fill with spaces
.loop	move.l		d0,(a3)+		
	dbf		d1,.loop
	clr.b		(a3)			put NULL char at end
	rts

************************************************************************
*		print the text in the text buffer
************************************************************************
PrintMyText
	lea		GeneralText(pc),a1	get intuitext struct
	move.w		d0,it_leftedge(a1)	put x co-ord
	move.w		d1,it_topedge(a1)	put y co-ord
	moveq		#0,d0			clear d0,d1
	moveq		#0,d1
	move.l		Window.rp(a4),a0	get rast port ptr
	CALLINT		PrintIText		and print
	rts

************************************************************************
*			display loaded file details
************************************************************************
DisplayLoadDetails
	lea		RDFstrAddr(a4),a1
	lea		LoadFileData(a4),a0	get data stream addr
	move.l		a0,(a1)
	lea		FNameTemplate(pc),a0	get template
	move.w		#203,d6			x co-ord
	move.w		#12,d7			y co-ord
	bsr		PrintFmtText

	lea		FLengthTemplate(pc),a0	get Length template
	lea		CompFileLen(a4),a1	get file length
	move.w		#203,d6
	move.w		#22,d7
	bsr		PrintFmtText		print file length

	lea		FLengthTemplate(pc),a0	get Length template
	lea		OrigFileLen(a4),a1	get file length
	move.w		#203,d6
	move.w		#32,d7
	bsr		PrintFmtText		print file length

	rts

************************************************************************
*		put characters routine for RawDoFmt
************************************************************************
PrintFmtText
	lea		PutCharRoutine(pc),a2	get put routine
	lea		TextBuffer(pc),a3	get dest ptr
	CALLEXE		RawDoFmt		do raw format
	lea		GeneralText(pc),a1	get intuitext struct
	move.w		d6,it_leftedge(a1)	put x co-ord
	move.w		d7,it_topedge(a1)	put y co-ord
	moveq		#0,d0			clear d0,d1
	moveq		#0,d1
	move.l		Window.rp(a4),a0	get rast port ptr
	CALLINT		PrintIText		and print
	rts

PutCharRoutine
	move.b		d0,(a3)+		put into textbuffer
	rts

************************************************************************
*			Custom Busy Pointer 
************************************************************************
PointerOn
	move.l		window.ptr(a4),a0
	lea		newptr,a1
	moveq.l		#33,d0
	move.l		d0,d1
	moveq.l		#0,d2
	move.l		d2,d3
	CALLINT		SetPointer
	rts

************************************************************************
*			restore original pointer
************************************************************************
PointerOff
	move.l		window.ptr(a4),a0	
	CALLINT		ClearPointer
	rts

************************************************************************
*		include compression subroutine here
************************************************************************
PHD_decompress
	incbin		Source:P_Douglas/Source/PHD_decompress.bin


************************************************************************
************************************************************************
*		Variables and such like stuff
************************************************************************
************************************************************************
_IntuitionBase	ds.l	1		base addr for libs
_GfxBase	ds.l	1
_ArpBase	ds.l	1

		rsreset
FileMemAlloc	rs.b	1		flag ;clear if no mem allocated

FileMemPtr	rs.l	1		ptr to memory for loading file
FileMemLen	rs.l	1		length of this memory

LoadFileID	rs.l	1		ID of file ie first 4 bytes
OrigFileLen	rs.l	1		orig length ie next 4 bytes if valid

FileInfoPtr	rs.l	1		ptr to file info block
WorkspacePtr	rs.l	1		ptr to compress buffer

CompFilePtr	rs.l	1		compressed file pointer
CompFileLen	rs.l	1			~	length

window.ptr	rs.l	1		window struct pointer
window.rp	rs.l	1		window rastport pointer
window.up	rs.l	1		windows userport pointer

about.ptr	rs.l	1		As above, but for About
about.rp	rs.l	1		window.
about.up	rs.l	1		
RDFlword	rs.l	1		stuff for RDF  
RDFstrAddr	rs.l	1		addr of string for RawDoFmt

LoadFileStruct	rs.b	fr_SIZEOF+4	space for load filerequest struct

SaveFileStruct	rs.b	fr_SIZEOF+4	space for save filerequest struct

LoadFileData	rs.b	FCHARS+2	;reserve space for filename buffer

LoadDirData	rs.b	DSIZE+1		;reserve space for path buffer

SaveFileData	rs.b	FCHARS+2	;reserve space for filename buffer

SaveDirData	rs.b	DSIZE+1		;reserve space for path buffer

LoadPathName	rs.b	DSIZE+FCHARS+3	;reserve space for full pathname name buffer

SavePathName	rs.b	DSIZE+FCHARS+3	;reserve space for full pathname name buffer

vars_SIZEOF	rs.b	0

		even
VariableBase	ds.b	vars_SIZEOF

********************************************************************************
********************************************************************************
*
*		Window ,Gadget, and Text Definitions
*
********************************************************************************
********************************************************************************
MainWindow	dc.w		138,30					start pos
		dc.w		341,68					window size
		dc.b		1,2					pens used
		dc.l		GADGETUP				events IDCMP
		dc.l		WINDOWDRAG+WINDOWDEPTH+ACTIVATE		sys gadg
		dc.l		LoadGadg				1st gadg
		dc.l		0
		dc.l		WindowName				text top
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200					max size
		dc.w		WBENCHSCREEN				type
WindowName
		dc.b		'PHD DeCompress © Paul Douglas 1992',0
		even

******************************************************

Window_text	dc.b		2,0,RP_JAM2,0
		dc.w		16,12
		dc.l		0
		dc.l		.String
		dc.l		.Line2

.String		dc.b		'   Compressed Filename:',0
		even

.Line2		dc.b		2,0,RP_JAM2,0
		dc.w		16,22
		dc.l		0
		dc.l		.String2
		dc.l		.Line3

.String2	dc.b		'Compressed File Length:',0
		even

.Line3		dc.b		2,0,RP_JAM2,0
		dc.w		16,32
		dc.l		0
		dc.l		.String3
		dc.l		0

.String3	dc.b		'  Original File Length:',0
		even


LoadText	dc.b	'Load File To DeCompress',0
		even
SaveText	dc.b	'Save DeCompressed File',0
		even
*******************************************************************************
*			Load  Gadget
*******************************************************************************

LoadGadg	dc.l		SaveGadg				next gadget
		dc.w		16,48					position
		dc.w		67,11					size
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET				type
		dc.l		Border1					border def
		dc.l		0
		dc.l		.Text					text ptr
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		Load					routine

.Text		dc.b		1,0,RP_JAM2,0
		dc.w		19,2
		dc.l		0
		dc.l		.String
		dc.l		0

.String		dc.b		'LOAD',0
		even

************************************************************************
*			Save Gadget
************************************************************************

SaveGadg	dc.l		AboutGadg
		dc.w		97,48
		dc.w		67,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border1
		dc.l		0
		dc.l		.Text
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		Save

.Text		dc.b		1,0,RP_JAM2,0
		dc.w		17,2
		dc.l		0
		dc.l		.String
		dc.l		0

.String		dc.b		'SAVE',0
		even

**************************************************************************
*			About Gadget
**************************************************************************

AboutGadg	dc.l		QuitGadg
		dc.w		178,48
		dc.w		67,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border1
		dc.l		0
		dc.l		.Text
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		About

.Text		dc.b		1,0,RP_JAM2,0
		dc.w		14,2
		dc.l		0
		dc.l		.String
		dc.l		0

.String		dc.b		'ABOUT',0
		even

************************************************************************
*			Quit Gadget
************************************************************************

QuitGadg	dc.l		0
		dc.w		258,48
		dc.w		67,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border1
		dc.l		0
		dc.l		.Text
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		QUIT

.Text		dc.b		1,0,RP_JAM2,0
		dc.w		17,2
		dc.l		0
		dc.l		.String
		dc.l		0

.String		dc.b		'QUIT',0
		even

************************************************************************
*	border type for above gagdets ie Load Save About Quit
************************************************************************
Border1		dc.w		-2,-1
		dc.b		3,0,RP_JAM1
		dc.b		5
		dc.l		Vectors1
		dc.l		0

Vectors1	dc.w		0,0
		dc.w		70,0
		dc.w		70,12
		dc.w		0,12
		dc.w		0,0

************************************************************************
*		border type for decompression gadget
************************************************************************
Border2		dc.w		-2,-1
		dc.b		3,0,RP_JAM1
		dc.b		5
		dc.l		Vectors2
		dc.l		0

Vectors2	dc.w		0,0
		dc.w		90,0
		dc.w		90,12
		dc.w		0,12
		dc.w		0,0

***************************************************************************
*			About window
***************************************************************************

about_win	dc.w		160,50
		dc.w		370,83
		dc.b		3,2
		dc.l		GADGETUP
		dc.l		ACTIVATE
		dc.l		OKGadg1
		dc.l		0
		dc.l		AboutName
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,256
		dc.w		WBENCHSCREEN

AboutName	dc.b		'  About PHD Data File DeCompression',0
		even

OKGadg1		dc.l		0
		dc.w		150,68
		dc.w		48,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		.Border
		dc.l		0
		dc.l		.Text
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		0

.Border		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		.Vectors
		dc.l		0

.Vectors	dc.w		0,0
		dc.w		50,0
		dc.w		50,12
		dc.w		0,12
		dc.w		0,0

.Text		dc.b		1,0,RP_JAM2,0
		dc.w		15,2
		dc.l		0
		dc.l		.String
		dc.l		0

.String		dc.b		'OK',0
		even

****************************************************************

AboutText	dc.b		1,0,RP_JAM2,0
		dc.w		45,13
		dc.l		0
		dc.l		.String1
		dc.l		.line2

.String1	dc.b		' AMIGANUTS VERSION  Nov/Dec 1992',0
		even

.line2		dc.b		2,0,RP_JAM2,0
		dc.w		60,23
		dc.l		0
		dc.l		.String2
		dc.l		.line3

.String2	dc.b		'Programmed by Paul Douglas',0

		even
.line3		dc.b		2,0,RP_JAM2,0
		dc.w		172,33
		dc.l		0
		dc.l		.String3
		dc.l		.line4

.String3	dc.b		'147 Winkworth Rd',0
		even

.line4		dc.b		2,0,RP_JAM2,0
		dc.w		172,43
		dc.l		0
		dc.l		.String4
		dc.l		.line5

.String4	dc.b		'Banstead',0
		even

.line5		dc.b		2,0,RP_JAM2,0
		dc.w		172,53
		dc.l		0
		dc.l		.String5
		dc.l		0

.String5	dc.b		'Surrey SM7 2JP',0
		even

**************************************************************************
GeneralText	dc.b		1,0,RP_JAM2,0
		dc.w		0,0
		dc.l		0
		dc.l		TextBuffer
		dc.l		0


TextBuffer	ds.b		40
TextBufEnd	dc.b		0	max length is 40 at moment
		even


FLengthTemplate	dc.b		'%-7ld',0	left justify maxlen7 long int.
		even

FNameTemplate	dc.b		'%-16.16s',0	left just maxlen 20 string
		even

**************************************************************************
*		data for custom busy pointer
**************************************************************************
	section		mptr,code_c

NEWPTR		dc.w	$0000,$0000	SPRxPOS,SPRxCTL

		dc.w	$0000,$ffe0
		dc.w	$7f00,$fee0
		dc.w	$3b80,$f760
		dc.w	$3b80,$f760
		dc.w	$3f00,$fee0
		dc.w	$3b80,$f760
		dc.w	$3b80,$f760
		dc.w	$7f00,$fee0

		dc.w	$0000,$ffe0
		dc.w	$3b80,$f760
		dc.w	$3b80,$f760
		dc.w	$3b80,$f760
		dc.w	$3b80,$f760
		dc.w	$3b80,$f760
		dc.w	$3b80,$f760
		dc.w	$1f80,$ff60

		dc.w	$0000,$ffe0
		dc.w	$1f00,$fee0
		dc.w	$3b80,$f760
		dc.w	$3c00,$fbe0
		dc.w	$1e00,$fde0
		dc.w	$0780,$ff60
		dc.w	$3b80,$f760
		dc.w	$1f00,$fee0

		dc.w	$0000,$ffe0
		dc.w	$71c0,$efa0
		dc.w	$71c0,$efa0
		dc.w	$3b80,$f760
		dc.w	$1f00,$fee0
		dc.w	$0e00,$fde0
		dc.w	$0e00,$fde0
		dc.w	$1f00,$fee0
		dc.w	$0000,$ffe0

		dc.w	$0000,$0000

		END
