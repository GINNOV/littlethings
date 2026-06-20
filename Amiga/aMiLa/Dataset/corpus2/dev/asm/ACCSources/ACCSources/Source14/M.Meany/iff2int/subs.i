

; Subroutines for IFF2GADG utility.

; © M.Meany, July 1991.


; When the user clicks on the Save gadget, the subroutine who's address is
;stored at SaveSubAddr is called. The address is set when one of the three
;selection gadgets ( Image, Gadget, Raw ) are clicked on.

Save		move.l	SaveSubAddr,a0		addr of subroutine
		jsr	(a0)			call it
		rts				and return

;--------------
;--------------	Load IFF file into memory
;--------------

; Call subroutine to display ARP filerequester

Load	bsr		arpload
	bne.s		.got_file

; If CANCEL was selected then set status message and quit.

	move.l		#status7,StatusPtr
	bra		.error

; Open the file ready for reading.

.got_file
	move.l		#FromFile,d1		;get filename to open
	move.l		#MODE_OLDFILE,d2	;open existing file
	CALLARP		Open			;open file
	move.l		d0,FileHndl		;store handle
	bne.s		.ok			;branch on error

; Set status message here and branch to an rts

	move.l		#status1,StatusPtr	;set error msg
	bra		.error

; File opened ok, clear any currently loaded data.

.ok	move.l		BMP,d0			;addr of current data
	beq.s		.get_gfx		;none loaded, so jump
	jsr		CleanupGraf		;release memory
.get_gfx
	move.l		FileHndl,d0		;get handle of file to load
	moveq		#0,d1			;specify ordinary
	jsr		LoadILBM		;load gfx file
	move.l		#status6,StatusPtr	;file loaded OK
	move.l		d0,BMP			;save result
	bne.s		.ok1			;branch on error

; Set status message here for Load failure

	cmpi.l		#$01,d1			;out of memory
	bne.s		.err2
	move.l		#status2,StatusPtr	;set error msg
	bra		.ok2

.err2	cmpi.l		#$02,d1			;compression error
	bne.s		.err3
	move.l		#status3,StatusPtr	;set error msg
	bra.s		.ok2

.err3	cmpi.l		#$04,d1			;not IFF file
	bne.s		.err4
	move.l		#status4,StatusPtr	;set error msg
	bra.s		.ok2

.err4	move.l		#status5,StatusPtr	;DOS error

	bra.s		.ok2

; A file has been loaded, so we determine the Width, Height and Depth and
;then display these values for the user.

.ok1	move.l		d0,a5			a5->Steves super BM struct
	moveq.l		#0,d0			clear reg
	move.b		bm_Depth(a5),d0		get depth
	move.w		#15,d1			set print pos
	bsr		PrintNum		and print it
	move.w		ilbm_Width(a5),d0	get width
	move.w		#25,d1			set print pos
	bsr		PrintNum		and print it
	move.w		ilbm_Height(a5),d0	get height
	move.w		#35,d1			set print pos
	bsr		PrintNum		and print it

; Now close the IFF file

.ok2	move.l		FileHndl,d1		;get file handle
	CALLARP		Close			;and close file
.error	moveq.l		#0,d2			;dont quit

	rts


;--------------
;--------------	Display the IFF picture.
;--------------

; Yep! I stole this routine from Steves ViewPort demo.

ShowPic
	move.l		BMP,d0
	bne.s		.iff_loaded

; No file in memory, so display error msg and quit

	move.l		#status8,StatusPtr
	bra		ViewError

.iff_loaded
	move.l		d0,a5			;ilbm struct in a5
	lea		MyView,a1		;get our view
	CALLGRAF	InitView		;and initialise it
	
	lea		ViewPort1,a4		;get first viewport
	move.l		a4,a0			;get first viewport
	CALLSYS		InitVPort		;initialise 2nd viewport
	
	lea		MyView,a1		;get our view
	move.w		ilbm_Modes(a5),v_Modes(a1) ;set view modes
	move.w		ilbm_Modes(a5),vp_Modes(a4);set viewport modes
	move.l		a4,(a1)			;and link to view
	
	moveq		#32,d0			;number of colours
	CALLSYS		GetColorMap		;get colourmap
	move.l		d0,vp_ColorMap(a4)	;store colormap
	
	move.l		gb_ActiView(a6),OldView ;save current view 

;------	This next piece of code attemts to centre the piture on screen
	
	move.w		ilbm_Width(a5),d0	;get width
	move.w		ilbm_Modes(a5),d1	;get mode
	btst		#15,d1			;test for lo-res
	beq.s		Lores			;branch if lo-res
	
	move.w		#640,d2			;std hi-res width
	sub.w		d0,d2			;subtract pic width
	cmpi.w		#-64,d2			;cmp with overscan
	bge.s		Xoffsetdone		;branch if not greater
	moveq		#-64,d2			;set to overscan
	bra.s		Xoffsetdone		;branch always
Lores
	move.w		#320,d2			;std lo-res width 
	sub.w		d0,d2			;subtract pic width
	cmpi.w		#-32,d2			;cmp with overscan
	bge.s		Xoffsetdone		;branch if greater
	moveq		#-32,d2			;set to overscan		
	
Xoffsetdone	
	asr.w		#1,d2			;divide by 2
	move.w		d2,vp_DxOffset(a4)	;set vp X offset
	
	move.w		ilbm_Height(a5),d0	;get height
	btst		#2,d1			;test for interlace
	beq.s		NoLace			;branch if not interlace
	
	move.w		gb_NormalDisplayRows(a6),d2 ;set max height
	add.w		d2,d2			;correct for interlace
	cmp.w		d2,d0			;is picture larger
	blt.s		NoOffset		;branch if not
	sub.w		d0,d2			;subtract height
	bra.s		Yoffsetdone		;branch always
NoLace
	move.w		gb_NormalDisplayRows(a6),d2 ;set max height
	cmp.w		d2,d0			;is picture larger
	blt.s		NoOffset		;branch if not
	sub.w		d0,d2			;subtract height
	bra.s		Yoffsetdone		;branch always
	
NoOffset
	moveq		#0,d2			;set no offset
	
Yoffsetdone	
	asr.w		#1,d2			;divide by 2
	move.w		d2,vp_DyOffset(a4)	;set vp Y offset

;------	Next we make sure the picture is not too large to display
	
	move.w		ilbm_Width(a5),d1	;get width
	move.w		ilbm_Modes(a5),d0	;get modes
	btst		#15,d0			;test hi-res
	bne.s		.Hires			;branch on hi-res
	cmpi.w		#352,d1			;cmp width with overscan
	bls.s		.WidthOK		;branch if less or equal 
	move.w		#352,d1			;set to overscan width
	bra.s		.WidthOK		;branch always

.Hires
	cmpi.w		#704,d1			;cmp width with overscan
	bls.s		.WidthOK		;branch if less or equal 
	move.w		#704,d1			;set to overscan width
.WidthOK
	move.w		d1,vp_DWidth(a4)	;set viewport width
	
	move.w		ilbm_Height(a5),d1	;get height
	btst		#2,d0			;test for interlace
	bne.s		.Lace			;branch if interlace
	
	cmpi.w		#290,d1			;cmp with nonlace overscan
	bls.s		.HeightOK		;branch if less or equal 	
	move.w		#290,d1			;set to overscan height
	bra.s		.HeightOK		;branch always
.Lace
	cmpi.w		#580,d1			;cmp with lace overscan
	bls.s		.HeightOK		;branch if less or equal 
	move.w		#580,d1			;set to lace overscan height
.HeightOK	
	move.w		d1,vp_DHeight(a4)	;set viewport height

;------	Attach the bitmap to rasinfo and the rasinfo to the viewport

	lea		MyRasinfo1,a1		;get 1st rasinfo
	move.l		a1,vp_RasInfo(a4)	;and place in viewport
	 
	move.l		a5,ri_BitMap(a1)	;store bitmap in rasinfo
	
;------	Make view viewport then display
	
	lea		MyView,a0		;get view
	move.l		a4,a1			;get first viewport
	CALLSYS		MakeVPort		;make viewports
	
	lea		MyView,a1		;get view
	CALLSYS		MrgCop			;merge copper lists
	
	lea		MyView,a1		;get view
	CALLSYS		LoadView		;display viewports
	
	move.l		a4,a0			;get first viewport
	move.l		ilbm_ColorMap(a5),a1	;get colourmap
	move.w		(a1)+,d0		;d0 = number of colours
	CALLSYS		LoadRGB4		;set colours

;------ Wait for left mouse button
	
.chklft	btst		#6,$bfe001		LMB
	bne.s		.chklft			branch back if not

;------	Restore screen then clean up

.gogo	move.l		OldView,a1
	CALLGRAF	LoadView
	
	move.l		a4,a0			;get first viewport
	move.l		vp_ColorMap(a0),d2	;save colormap
	CALLSYS		FreeVPortCopLists	;free copper lists
	
	lea		MyView,a0		;get view
	move.l		v_SHFCprList(a0),d3	;save short frame
	move.l		v_LOFCprList(a0),a0	;set long frame
	CALLSYS		FreeCprList		;free copper list
	move.l		d3,a0			;get short frame
	CALLSYS		FreeCprList		;free copper list
	
	move.l		d2,a0			;get colormap
	CALLSYS		FreeColorMap		;and free it

ViewError
	rts



;--------------
;--------------	User selected Quit gadget, so set D2 for return.
;--------------

Quit		move.l		#CLOSEWINDOW,d2
		rts


; The following three subroutine deal with the Save options. When a gadget
;is clicked on the SELECTED bit in the gg_Flags field is set and the address
;of the subroutine that deals with this particular option is saved at label
;SaveSubAddr.

;--------------
;-------------- Deal with Image gadget selection
;--------------

AsImage

; remove gadgets from list

	lea		AsImageGadg(pc),a1	addr of 1st gadget to remove
	moveq		#3,d0			num of gadgs to remove
	bsr		RemoveGad		and remove them

; set SELECTED bit in AsImageGadget

	move.w		#SELECTED,d1		d1=SELECTED		
	lea		AsImageGadg(pc),a1	a1->gadget
	or.w		d1,gg_Flags(a1)		set its flag

; make sure other 2 option gadgets are not SELECTED

	not.w		d1
	lea		AsGadgGadg(pc),a1
	and.w		d1,gg_Flags(a1)
	lea		AsRawGadg(pc),a1
	and.w		d1,gg_Flags(a1)
	lea		AsImageGadg(pc),a1

; add gadgets back to list

	moveq		#3,d1
	bsr		AddGad

; store address of subroutine that deals with Image save at the required
; label.

	move.l		#SaveI,SaveSubAddr
	rts
	
;--------------
;-------------- Deal with Gadget gadget selection
;--------------

AsGadg

; remove option gadgets from list

	lea		AsImageGadg(pc),a1
	moveq		#3,d0
	bsr		RemoveGad

; make sure AsGadgGadg is SELECTED

	move.w		#SELECTED,d1
	lea		AsGadgGadg(pc),a1
	or.w		d1,gg_Flags(a1)

; and that the other two are not selected

	not.w		d1
	lea		AsRawGadg(pc),a1
	and.w		d1,gg_Flags(a1)
	lea		AsImageGadg(pc),a1
	and.w		d1,gg_Flags(a1)
	
; add gadgets back to list

	moveq		#3,d1
	bsr		AddGad

; store address of subroutine that deals with Gadget save at the required
; label.

	move.l		#SaveG,SaveSubAddr
	rts
	
;--------------
;-------------- Deal with Raw gadget selection
;--------------

AsRaw

; remove option gadgets from list

	lea		AsImageGadg(pc),a1
	moveq		#3,d0
	bsr		RemoveGad

; make sure AsRawGadg is SELECTED

	move.w		#SELECTED,d1
	lea		AsRawGadg(pc),a1
	or.w		d1,gg_Flags(a1)

; and the other 2 are not SELECTED

	not.w		d1
	lea		AsGadgGadg(pc),a1
	and.w		d1,gg_Flags(a1)
	lea		AsImageGadg(pc),a1
	and.w		d1,gg_Flags(a1)

; add the gadgets back into the list

	moveq		#3,d1
	bsr		AddGad

; store address of subroutine that deals with Raw save at the required
; label.

	move.l		#SaveR,SaveSubAddr
	rts

*****************************************************************************
*			Subroutines					    *
*****************************************************************************


; At present these options are not supported!

SaveG
SaveR		rts

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
;-------------- Call the ARP filerequester to obtain FROM filename
;--------------
		
arpload:
	lea		LoadFileStruct,a0	;get file struct
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


;--------------
;--------------	Print the number stored in d0 as an ASCII string
;--------------

;Entry		d0=number
;		d1=y-offset

PrintNum
	move.w		d1,y_off	set screen offset
	lea		NumPtr,a0	address of buffer for ASCII string
	bsr		dec_con		convert d0.w to ASCII
	move.l		window.rp,a0	rastport
	lea		NumText,a1	IntuiText
	moveq.l		#0,d0		x start
	move.l		d0,d1		y start
	CALLINT		PrintIText	print it
	rts
	

;--------------	I grabbed this routine from the tutorials I did on the
;		early discs.

; A subroutine to convert a word to a decimal number for printing
; ENTRY     d0=word to be converted.
; CORRUPTED a0,d0,d1
; ASCII string ready for printing starts at STRSTART

dec_con	moveq		#' ',d1		d1=ASCII code of space
	move.b		d1,(a0)+	1st char=space
	move.b		d1,(a0)+	2nd char=space
	move.b		d1,(a0)+	3rd char=space
	move.b		d1,(a0)+	4th char=space
	move.b		#'0',(a0)+	5th char=a zero (routine quits
					;if called with d0=0
.DIVLOOP
	tst.w		d0		test if d0=0
	beq.s		.FIN		if it does then exit
	divu.w		#$0A,d0		divide num by 10
	move.l		d0,d1		copy result
	swap		d1		move remainder int MSW
	addi.w		#'0',d1		convert to ASCII digit
	move.b		d1,-(a0)	store this digit
	and.l		#$FFFF,d0	mask off remainder
	bra.s		.DIVLOOP		loop back for next digit
	
.FIN	rts			finished so exit


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

;--------------
;--------------	Routine to save an Image structure and Image data
;--------------

;--------------	Open a window to obtain filename and source label

SaveI		lea		ImWindow,a0	a0->window args
		CALLINT		OpenWindow	and open it
		move.l		d0,temp.ptr	save struct ptr
		beq.s		.win_error	quit if error

		move.l		d0,a0			  ;a0->win struct	
		move.l		wd_UserPort(a0),temp.up ;save up ptr
		move.l		wd_RPort(a0),temp.rp    ;save rp ptr

;--------------	Display basic usage text for user

		move.l		temp.rp,a0	rastport
		lea		Title1,a1	IntuiText
		moveq.l		#0,d0		x start
		move.l		d0,d1		y start
		CALLSYS		PrintIText	print it

;--------------	Wait for user to hit CANCEL or SAVE gadget

.WaitMsg	move.l		temp.up,a0	a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		temp.up,a0	a0-->window pointer
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		.WaitMsg	if not loop back
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
		bne.s		.WaitMsg	 	if not then jump

		move.l		temp.ptr,a0
		CALLINT		CloseWindow

.win_error	moveq.l		#0,d2		don't quit
		rts				return

; String gadgets serve only as a means of data entry, no special code is
;required when they are used.

DoNothing	rts

; If Cancel gadget is hit then set d2 ( flag ) to CLOSEWINDOW

IMCancel	move.l		#CLOSEWINDOW,d2
		move.l		#statusD,StatusPtr
		rts

;--------------
;--------------	Saves an image structure to disc
;--------------

; Open destination file

DoSaveI		move.l		#SaveName,d1
		move.l		#MODE_NEWFILE,d2
		CALLARP		Open
		move.l		d0,STD_OUT
		bne.s		.ooo

; file would not open so set status message and quit

		move.l		#statusC,StatusPtr
		bra		.error

; determine the number of planes in the picture

.ooo		move.l		BMP,a0
		moveq.l		#1,d0
		tst.l		bm_Planes+4(a0)
		beq.s		.ok
		moveq.l		#2,d0

; Build a data stream for RawDoFmt which will insert the source label set
;by user, image width, depth and height into the image structure text.

.ok		lea		DataStream,a1
		move.l		#SourceLabel,(a1)+	label
		move.w		ilbm_Width(a0),(a1)+	width
		move.w		ilbm_Height(a0),(a1)+	height
		move.w		d0,(a1)+		depth
		move.l		#SourceLabel,(a1)+	data pointer
		move.l		#SourceLabel,(a1)+	data label

; Build assembly source using data stream set above

		lea		ImageTemplate,a0
		lea		DataStream,a1
		lea		PutChar,a2
		lea		RDFBuf,a3
		CALLEXEC	RawDoFmt

; Save this source using DosMsg ( said this was a useful subroutine! )

		lea		RDFBuf,a0
		bsr		DosMsg

; Call subroutine that saves the image data

		bsr		PrintImageData

; Close dest file

		move.l		STD_OUT,d1
		CALLARP		Close

; Set status message so user knows file was saved OK, close window and fin

		move.l		#statusB,StatusPtr
.error		move.l		#CLOSEWINDOW,d2
		rts

;--------------
;--------------	Saves image data to disc
;--------------

;		STD_OUT must be set to open disc file

; determine how many words of data each plane consists of

PrintImageData	move.l		BMP,a0
		moveq.l		#0,d7
		move.w		bm_BytesPerRow(a0),d7
		addq.l		#1,d7
		asr.w		#1,d7
		mulu.w		bm_Rows(a0),d7

; get address of first 1st bitplane

		lea		bm_Planes(a0),a0
		move.l		(a0)+,d0
		bne.s		.ok

; if we get here then there is no image data, set error message and quit

		move.l		#statusA,StatusPtr
		bra		.error

; call subroutine that saves image data as dc.w statements

.ok		move.l		d7,-(sp)
		move.l		a0,-(sp)
		move.l		d0,a5
		bsr		PrintData

; if there is a second bitplane pointer, call save image routine again

		move.l		(sp)+,a0
		move.l		(sp)+,d7
		move.l		(a0),d0
		beq.s		.error
		move.l		d0,a5
		lea		implane_msg,a0
		bsr		DosMsg
		bsr		PrintData

; add a line of text on the end to remind user how the image was created
; ( ie. leave a calling card )

		lea		term_msg,a0
		bsr		DosMsg
.error		rts
		

;--------------
;--------------	Saves an image data as dc.w statements
;--------------

; this routine is flawed at present as it ALWAYS saves a multiple of 8 words
;of data. Will sort it out soon.

PrintData	move.l		a5,a1
		lea		ImDataTemplate,a0
		lea		PutChar,a2
		lea		RDFBuf,a3
		CALLEXEC	RawDoFmt
		lea		RDFBuf,a0
		bsr		DosMsg
		add.l		#16,a5
		sub.l		#8,d7
		bpl.s		PrintData
		rts
		

;--------------
;-------------- routine called by all RawDoFmt 
;--------------

PutChar		move.b		d0,(a3)+
		rts


;--------------
;--------------	data section
;--------------



DataStream	ds.l		8

ImageTemplate	dc.b		'%s',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'0,0',$09,$09,'; x,y ',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'%3d,%3d',$09,$09,'; width,height',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'%d',$09,$09,'; depth',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'%sData',$09,$09,'; Image def',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'3',$09,$09,'; PlanePick',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'0',$09,$09,'; PlaneOnOff',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'0',$09,$09,'; no more images',$0a
		dc.b		$0a
		dc.b		$09,$09,'SECTION',$09,'im,DATA_C',$09,$09,'; get CHIP mem',$0a
		dc.b		$0a
		dc.b		'; Data For first plane of image now follows.',$0a,$0a
		dc.b		'%sData',$0a,0
		even
ITLen		equ		(*-ImageTemplate)+100

ImDataTemplate	dc.b		$09,$09,'dc.w',$09,$09,'$%04x,$%04x,$%04x,$%04x,$%04x,$%04x,$%04x,$%04x',$0a,0
		even


RDFBuf		ds.b		ITLen*2

term_msg	dc.b		$0a,$0a,'; End of source generation. © M.Meany, July 91.',0
		even
implane_msg	dc.b		$0a,'; Data for second plane of image now follows.',$0a,$0a,0
		even

SourceLabel	ds.b		50
		even

SaveName	ds.b		50
		even

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


