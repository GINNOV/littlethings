
; File load/save window & support routines

*************** Present the File Function Selection Window

; NOTE - Uses Mask Editor vars storage space - can't have both at once!

DoFW		lea		FWWindow,a0		a0->window args

		move.l		screen.ptr(a4),nw_Screen(a0)

		CALLINT		OpenWindow		and open it
		move.l		d0,BMEwin.ptr(a4)	save struct ptr
		beq		.error			quit if error

		move.l		d0,a0			a0->win struct	
		move.l		wd_UserPort(a0),BMEwin.up(a4) save up ptr
		move.l		wd_RPort(a0),BMEwin.rp(a4)    save rp ptr

; Add some text

		move.l		BMEwin.rp(a4),a0	RastPort
		lea		FWText,a1		IntuiText
		moveq.l		#0,d0			X
		moveq.l		#0,d1			Y
		CALLINT		PrintIText		draw 'em

; Deal with User interaction

.WaitForMsg	move.l		BMEwin.up(a4),a0	a0->user port
		CALLEXEC	WaitPort		wait for event
		move.l		BMEwin.up(a4),a0	a0->user port
		CALLSYS		GetMsg			get any messages
		tst.l		d0			was there a message ?
		beq.s		.WaitForMsg		if not loop back
		move.l		d0,a1			a1-->message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		move.l		im_IAddress(a1),a5 	a5=addr of structure
		CALLSYS		ReplyMsg		answer os

		cmp.l		#GADGETDOWN,d2		toggle gadget ?
		bne.s		.test_gadg		skip if not
		move.l		gg_UserData(a5),d0	get sub addr
		beq.s		.WaitForMsg		loop if NULL
		move.l		d0,a0
		jsr		(a0)			call sub
		bra.s		.WaitForMsg		and loop


.test_gadg	cmp.l		#GADGETUP,d2		check gadget
		bne.s		.test_win
		move.l		gg_UserData(a5),d6	get sub addr
		
.go		move.l		#CLOSEWINDOW,d2

.test_win	cmp.l		#CLOSEWINDOW,d2  	window closed ?
		bne		.WaitForMsg	 	if not then jump

; Close the Intuition Block Mask Editor window.

		move.l		BMEwin.ptr(a4),a0	a0->Window struct
		CALLINT		CloseWindow		and close it

; Call required routine if CANCEL not selected

		tst.l		d6
		beq.s		.error			exit if no routine
		move.l		d6,a0			a0->routine
		jsr		(a0)			and call it!

.error		moveq.l		#0,d2			not quitting
		rts

***************	Toggle with/without masks

; Set flag according to if mask's are to be saved with data

FWSetMask	not.l		MaskFlag(a4)		toggle flag

; Switch gadget text

		move.l		gg_SIZEOF(a5),d0	get addr of alt text
		move.l		gg_GadgetText(a5),a0	a0->IText
		move.l		it_IText(a0),d1
		move.l		d0,it_IText(a0)
		move.l		d1,gg_SIZEOF(a5)

		move.l		a5,a0			Gadget
		move.l		BMEwin.ptr(a4),a1	Window
		suba.l		a2,a2			NULL
		moveq.l		#1,d0			just the one
		CALLINT		RefreshGList		redraw it

		rts

***************	Toggle block save format, consecutive or interleaved

; Set flag according to which mode, consecutive or interleaved, is required

FWSetMode	not.l		ModeFlag(a4)		toggle flag

		move.l		gg_SIZEOF(a5),d0	get addr of alt text
		move.l		gg_GadgetText(a5),a0	a0->IText
		move.l		it_IText(a0),d1
		move.l		d0,it_IText(a0)
		move.l		d1,gg_SIZEOF(a5)

		move.l		a5,a0			Gadget
		move.l		BMEwin.ptr(a4),a1	Window
		suba.l		a2,a2			NULL
		moveq.l		#1,d0			just the one
		CALLINT		RefreshGList		redraw it

		rts

*************** Save blocks & masks in a format that can be read back

SaveBlocks	lea		FRQ,a0
		move.l		#SaveName1,frq_Name(a0)	set window name
		move.l		screen.ptr(a4),frq_Screen(a0) set screen ptr
		lea		FileBuffer(a4),a1
		move.l		a1,frq_Buffer(a0)
		bsr		FileRequest

		lea		FileBuffer(a4),a0
		tst.b		(a0)
		bne.s		.ok
		
		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra		.error
		
.ok		move.l		a0,d1			file name
		move.l		#MODE_NEWFILE,d2	access mode-Create
		CALLDOS		Open
		move.l		d0,d6			save handle
		bne.s		.ok1

		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra		.error

.ok1		move.l		d6,d1			handle
		move.l		Blocks(a4),d2		buffer
		move.l		BlockSize(a4),d3	buffer size
		CALLDOS		Write			save the data
		
		move.l		d6,d1			handle
		CALLDOS		Close			close file

.error		rts

***************	Read blocks and masks from previously saved file

LoadBlocks	lea		FRQ,a0
		move.l		#LoadName1,frq_Name(a0)	set window name
		move.l		screen.ptr(a4),frq_Screen(a0) set screen ptr
		lea		FileBuffer(a4),a1
		move.l		a1,frq_Buffer(a0)
		bsr		FileRequest
		tst.l		d0
		beq.s		.ok

		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra		.error
		
.ok		lea		FileBuffer(a4),a0	a0->file name
		move.l		a0,d1			file name
		move.l		#MODE_OLDFILE,d2	access mode-Read
		CALLDOS		Open
		move.l		d0,d6			save handle
		bne.s		.ok1

		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra		.error

.ok1		move.l		d6,d1			handle
		move.l		Blocks(a4),d2		buffer
		move.l		BlockSize(a4),d3	buffer size
		CALLDOS		Read			save the data
		
		move.l		d6,d1			handle
		CALLDOS		Close			close file

		bsr		SetGadgets		display loaded gfx
		
		bsr		ShowBlock		show selected block

		bsr		BuildScreen		display screen

.error		rts

***************	Decide which save format to use and save blocks

DoSaveEm	tst.l		ModeFlag(a4)
		beq.s		.consec
		
		bsr		SaveInterleaved
		rts

.consec		bsr		SaveConsecutive
		rts

***************	Save blocks in interleaved format

; Will save with or without masks following block data

SaveInterleaved	lea		FRQ,a0
		move.l		#SaveName3,frq_Name(a0)	set window name
		move.l		screen.ptr(a4),frq_Screen(a0) set screen ptr
		lea		FileBuffer(a4),a1
		move.l		a1,frq_Buffer(a0)
		bsr		FileRequest

		lea		FileBuffer(a4),a0
		tst.b		(a0)
		bne.s		.ok
		
		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra		.error
		
.ok		move.l		a0,d1			file name
		move.l		#MODE_NEWFILE,d2	access mode-Create
		CALLDOS		Open
		move.l		d0,IFFHandle(a4)	save handle
		bne.s		.ok1

		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra		.error

.ok1		move.l		#255,d5			block counter
		move.l		Blocks(a4),a5		block data buffer
.SaveLoop	move.l		a5,a0			copy
		bsr		.SaveBlock		save next block
		dbra		d5,.SaveLoop		'till all done

		move.l		IFFHandle(a4),d1	handle
		CALLDOS		Close			close file

		moveq.l		#0,d2			clear
		move.l		d2,IFFHandle(a4)

.error		rts

.SaveBlock	lea		SaveBuff(a4),a1		output buffer
		moveq.l		#15,d7			line counter

.LineLoop	move.l		_Depth(a4),d6		block depth
		move.w		(a0),(a1)+		line n, plane 1
		subq.w		#1,d6
		beq.s		.next
		move.w		32(a0),(a1)+		line n, plane 1
		subq.w		#1,d6
		beq.s		.next
		move.w		64(a0),(a1)+		line n, plane 1
		subq.w		#1,d6
		beq.s		.next
		move.w		96(a0),(a1)+		line n, plane 1
		subq.w		#1,d6
		beq.s		.next
		move.w		128(a0),(a1)+		line n, plane 1
.next		addq.l		#2,a0			step to next line
		dbra		d7,.LineLoop		for all lines
		
		tst.l		MaskFlag(a4)		want a mask to?
		beq.s		.NoMask			skip if not
		
		move.l		_Depth(a4),d0		depth
		asl.l		#5,d0			x plane size
		adda.l		d0,a5			a5->mask data
		move.l		(a5)+,(a1)+		copy 2 lines
		move.l		(a5)+,(a1)+		copy 2 lines
		move.l		(a5)+,(a1)+		copy 2 lines
		move.l		(a5)+,(a1)+		copy 2 lines
		move.l		(a5)+,(a1)+		copy 2 lines
		move.l		(a5)+,(a1)+		copy 2 lines
		move.l		(a5)+,(a1)+		copy 2 lines
		move.l		(a5)+,(a1)+		copy 2 lines

		move.l		IFFHandle(a4),d1	Handle
		lea		SaveBuff(a4),a0
		move.l		a0,d2			Buffer
		add.l		#32,d0
		move.l		d0,d3			Size
		CALLDOS		Write			save this block
		rts

.NoMask		move.l		_Depth(a4),d3		depth of block
		addq.l		#1,d3			allow for mask
		asl.l		#5,d3			x plane size (32)
		adda.l		d3,a5			a5->next
		
		move.l		IFFHandle(a4),d1	Handle
		lea		SaveBuff(a4),a0
		move.l		a0,d2			Buffer
		sub.l		#32,d3			Size
		CALLDOS		Write			and save it
		rts

***************	Save blocks in consecutive format

SaveConsecutive	lea		FRQ,a0
		move.l		#SaveName2,frq_Name(a0)	set window name
		move.l		screen.ptr(a4),frq_Screen(a0) set screen ptr
		lea		FileBuffer(a4),a1
		move.l		a1,frq_Buffer(a0)
		bsr		FileRequest

		lea		FileBuffer(a4),a0
		tst.b		(a0)
		bne.s		.ok
		
		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra		.error
		
.ok		move.l		a0,d1			file name
		move.l		#MODE_NEWFILE,d2	access mode-Create
		CALLDOS		Open
		move.l		d0,IFFHandle(a4)	save handle
		bne.s		.ok1

		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra		.error

.ok1		move.l		#255,d5			block counter
		move.l		Blocks(a4),a5		block data buffer
.SaveLoop	bsr		.SaveBlock		save next block
		dbra		d5,.SaveLoop		'till all done

		move.l		IFFHandle(a4),d1	handle
		CALLDOS		Close			close file

		moveq.l		#0,d2			clear
		move.l		d2,IFFHandle(a4)

.error		rts

.SaveBlock	move.l		IFFHandle(a4),d1	Handle
		move.l		a5,d2			Buffer
		
		move.l		_Depth(a4),d3	
		addq.l		#1,d3			allow for mask
		asl.l		#5,d3			x plane size (32)
		adda.l		d3,a5			a5->next block
		tst.l		MaskFlag(a4)		want a mask
		bne.s		.DoMask			skip if so
		sub.l		#32,d3			else adjust
.DoMask		CALLDOS		Write			and save block
		rts

***************	Save screen data

SaveScreen	lea		FRQ,a0
		move.l		#SaveName4,frq_Name(a0)	set window name
		move.l		screen.ptr(a4),frq_Screen(a0) set screen ptr
		lea		FileBuffer(a4),a1
		move.l		a1,frq_Buffer(a0)
		bsr		FileRequest

		lea		FileBuffer(a4),a0
		tst.b		(a0)
		bne.s		.ok
		
		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra		.error
		
.ok		move.l		a0,d1			file name
		move.l		#MODE_NEWFILE,d2	access mode-Create
		CALLDOS		Open
		move.l		d0,d6			save handle
		bne.s		.ok1

		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra		.error

.ok1		move.l		d6,d1			handle
		move.l		Scrn(a4),d2		buffer
		move.l		ScrnSize(a4),d3		buffer size
		CALLDOS		Write			save the data
		
		move.l		d6,d1			handle
		CALLDOS		Close			close file

.error		rts

***************	Read screen data from previously saved file

LoadScreen	lea		FRQ,a0
		move.l		#LoadName2,frq_Name(a0)	set window name
		move.l		screen.ptr(a4),frq_Screen(a0) set screen ptr
		lea		FileBuffer(a4),a1
		move.l		a1,frq_Buffer(a0)
		bsr		FileRequest
		tst.l		d0
		beq.s		.ok

		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra		.error
		
.ok		lea		FileBuffer(a4),a0	a0->file name
		move.l		a0,d1			file name
		move.l		#MODE_OLDFILE,d2	access mode-Read
		CALLDOS		Open
		move.l		d0,d6			save handle
		bne.s		.ok1

		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra		.error

.ok1		move.l		d6,d1			handle
		move.l		Scrn(a4),d2		buffer
		move.l		ScrnSize(a4),d3		buffer size
		CALLDOS		Read			save the data
		
		move.l		d6,d1			handle
		CALLDOS		Close			close file

		bsr		BuildScreen		display screen

.error		rts

***************	Grab blocks from an IFF ILBM file

; use filerequester to obtain name of file to load

GrabBlocks	lea		FRQ,a0
		move.l		#LoadName5,frq_Name(a0)	set window name
		move.l		screen.ptr(a4),frq_Screen(a0) set screen ptr
		lea		FileBuffer(a4),a1
		move.l		a1,frq_Buffer(a0)
		bsr		FileRequest
		tst.l		d0
		beq.s		.ok

		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra		.error

; got a filename, so open file

.ok		lea		FileBuffer(a4),a0	a0->file name
		move.l		a0,d1			file name
		move.l		#MODE_OLDFILE,d2	access mode-Read
		CALLDOS		Open
		move.l		d0,IFFHandle(a4)	save handle
		bne.s		.ok1

		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra		.error

; file open, load in gfx using routine by Steve Marshall

.ok1		move.l		#0,d1			no requirements
		jsr		LoadILBM		load IFF file
		move.l		d0,IFFStruct(a4)	save pointer
		bne.s		.ok2		

		suba.l		a0,a0
		CALLINT		DisplayBeep
		bra		.error

; gfx loaded, makesure same depth as screen being displayed

.ok2		move.l		d0,a3			a3->SM's structure
		moveq.l		#0,d0
		move.b		bm_Depth(a3),d0		pics depth
		cmp.l		_Depth(a4),d0		same as screen?
		bne.s		.error2			exit if not

; use the pallete from this file

		move.l		ilbm_ColorMap(a3),a0	source
		addq.l		#2,a0			step over counter
		lea		Palette,a1		dest
		moveq.l		#64,d0			bytes
		CALLEXEC	CopyMem			copy palette
		
		move.l		screen.vp(a4),a0	ViewPort
		move.l		_Depth(a4),d1		d1=depth of screen
		moveq.l		#1,d0			init colour count
		asl.l		d1,d0			calc colours
		lea		Palette,a1		a1->colour map
		CALLGRAF	LoadRGB4		set colours

; break gfx up into 16x16 blocks - each gets a blank mask

		bsr		ExtractBlocks

.error2		move.l		IFFStruct(a4),d0	pointer
		jsr		CleanupGraf		release file

.error1		move.l		IFFHandle(a4),d1	Handle
		CALLDOS		Close			close file

		bsr		SetGadgets		display loaded gfx
		
		bsr		ShowBlock		show selected block

		bsr		BuildScreen		display screen

.error		rts


**** Extract blocks from loaded IFF file

;Entry		a3->SM's structure

ExtractBlocks	move.l		Blocks(a4),a5		a5->block buffer
		moveq.l		#0,d7			clear registers
		move.l		d7,d6
		move.l		d7,d4
		
		move.w		bm_BytesPerRow(a3),d6	byte width
		move.w		bm_Rows(a3),d7
		asr.w		#4,d7			= rows of blocks
		move.l		d6,d5
		asr.w		#1,d5			= blocks per row
.Outer		moveq.l		#0,d3			X block ordinate

.Inner		move.l		d4,d0			Y
		mulu		d5,d0			Y * blocks/row
		add.l		d3,d0			= block number
		cmp.l		#255,d0			end of buffer
		beq		.error			exit if so

		bsr		ExtBlk			pull this block

		addq.l		#1,d3			bump X
		cmp.l		d5,d3			end of row?
		blt.s		.Inner			loop if not
		
		addq.l		#1,d4			bump Y
		cmp.l		d7,d4			end of bitplane
		blt.s		.Outer			loop if not

.error		rts

ExtBlk		move.l		_Depth(a4),d1		screen depth
		subq.l		#1,d1			adjust for dbra
		lea		bm_Planes(a3),a2	
.loop		move.l		(a2)+,a1		a1->start of bpl
		move.l		d3,d2			X block ord
		asl.w		#1,d2			X pixel ord
		move.l		d4,d0			Y block ord
		asl.w		#4,d0			Y pixel ord
		mulu		d6,d0			Y * bytewidth
		add.l		d0,d2			byte offset
		adda.l		d2,a1			address
		
		moveq.l		#15,d0			line counter
.loop2		move.w		(a1),(a5)+		copy word
		add.l		d6,a1			bump to next line
		dbra		d0,.loop2		for all lines
		
		dbra		d1,.loop		in all planes

; now add blank mask

		moveq.l		#15,d1			line counter
		moveq.l		#0,d0
.loop3		move.w		d0,(a5)+		build mask
		dbra		d1,.loop3
		
		rts
		

*****************************************************************************

FWWindow
	dc.w	0,0
	dc.w	320,256
	dc.b	0,1
	dc.l	GADGETUP!GADGETDOWN
	dc.l	ACTIVATE+NOCAREREFRESH
	dc.l	FWGadg1
	dc.l	0
	dc.l	.Name
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,200
	dc.w	CUSTOMSCREEN
.Name
	dc.b	'   ScreenDesigner - File Load/Save',0
	even

FWGadg1
	dc.l	FWGadg2
	dc.w	101,25
	dc.w	41,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	LoadBlocks
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	44,0
	dc.w	44,14
	dc.w	0,14
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	4,3
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Load',0
	even
FWGadg2
	dc.l	FWGadg3
	dc.w	148,25
	dc.w	41,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SaveBlocks
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	44,0
	dc.w	44,14
	dc.w	0,14
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	4,3
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Save',0
	even
FWGadg3
	dc.l	FWGadg4
	dc.w	101,57
	dc.w	41,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	LoadBlocks
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	44,0
	dc.w	44,14
	dc.w	0,14
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	4,3
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Load',0
	even
FWGadg4
	dc.l	FWGadg5
	dc.w	149,57
	dc.w	41,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SaveBlocks
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	44,0
	dc.w	44,14
	dc.w	0,14
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	4,3
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Save',0
	even
FWGadg5
	dc.l	FWGadg6
	dc.w	43,77
	dc.w	41,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoSaveEm
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	44,0
	dc.w	44,14
	dc.w	0,14
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	4,3
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Save',0
	even
FWGadg6
	dc.l	FWGadg7
	dc.w	101,77
	dc.w	89,13
	dc.w	GADGHNONE
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	FWSetMode
	dc.l	.Text1
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	92,0
	dc.w	92,14
	dc.w	0,14
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	0,3
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Consecutive',0
	even
.Text1	dc.b	'Interleaved',0
	even
FWGadg7
	dc.l	FWGadg8
	dc.w	200,77
	dc.w	89,13
	dc.w	GADGHNONE
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	FWSetMask
	dc.l	.Text1
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	92,0
	dc.w	92,14
	dc.w	0,14
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	12,3
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Mask Off',0
	even
.Text1	dc.b	'Mask On ',0
	even
FWGadg8
	dc.l	FWGadg9
	dc.w	80,95
	dc.w	41,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	GrabBlocks
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	44,0
	dc.w	44,14
	dc.w	0,14
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	4,3
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Grab',0
	even
FWGadg9
	dc.l	FWGadg10
	dc.w	128,95
	dc.w	41,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	0
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	44,0
	dc.w	44,14
	dc.w	0,14
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	8,3
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Add',0
	even
FWGadg10
	dc.l	FWGadg11
	dc.w	80,129
	dc.w	41,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	LoadScreen
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	44,0
	dc.w	44,14
	dc.w	0,14
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	4,3
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Load',0
	even
FWGadg11
	dc.l	FWGadg12
	dc.w	129,129
	dc.w	41,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SaveScreen
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	44,0
	dc.w	44,14
	dc.w	0,14
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	4,3
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Save',0
	even
FWGadg12
	dc.l	FWGadg13
	dc.w	92,150
	dc.w	41,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	0
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	44,0
	dc.w	44,14
	dc.w	0,14
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	4,3
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Load',0
	even
FWGadg13
	dc.l	FWGadg14
	dc.w	140,150
	dc.w	41,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	0
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	44,0
	dc.w	44,14
	dc.w	0,14
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	4,3
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Save',0
	even
FWGadg14
	dc.l	FWGadg15
	dc.w	259,181
	dc.w	51,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	0
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	54,0
	dc.w	54,14
	dc.w	0,14
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	2,3
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'CANCEL',0
	even
FWGadg15
	dc.l	0
	dc.w	10,181
	dc.w	51,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	0
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	54,0
	dc.w	54,14
	dc.w	0,14
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	2,3
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'CANCEL',0
	even

FWText
	dc.b	2,0,RP_JAM2,0
	dc.w	116,13
	dc.l	0
	dc.l	.Text16
	dc.l	.IText17
.Text16
	dc.b	'Project',0
	even
.IText17
	dc.b	3,0,RP_JAM2,0
	dc.w	6,27
	dc.l	0
	dc.l	.Text17
	dc.l	.IText18
.Text17
	dc.b	'Retrievable',0
	even
.IText18
	dc.b	2,0,RP_JAM2,0
	dc.w	120,45
	dc.l	0
	dc.l	.Text18
	dc.l	.IText19
.Text18
	dc.b	'Blocks',0
	even
.IText19
	dc.b	3,0,RP_JAM2,0
	dc.w	6,60
	dc.l	0
	dc.l	.Text19
	dc.l	.IText20
.Text19
	dc.b	'Retrievable',0
	even
.IText20
	dc.b	3,0,RP_JAM2,0
	dc.w	7,80
	dc.l	0
	dc.l	.Text20
	dc.l	.IText21
.Text20
	dc.b	'Raw',0
	even
.IText21
	dc.b	3,0,RP_JAM2,0
	dc.w	7,98
	dc.l	0
	dc.l	.Text21
	dc.l	.IText22
.Text21
	dc.b	'From IFF',0
	even
.IText22
	dc.b	2,0,RP_JAM2,0
	dc.w	120,116
	dc.l	0
	dc.l	.Text22
	dc.l	.IText23
.Text22
	dc.b	'Screen',0
	even
.IText23
	dc.b	3,0,RP_JAM2,0
	dc.w	8,133
	dc.l	0
	dc.l	.Text23
	dc.l	.IText24
.Text23
	dc.b	'Map File',0
	even
.IText24
	dc.b	3,0,RP_JAM2,0
	dc.w	7,153
	dc.l	0
	dc.l	.Text24
	dc.l	0
.Text24
	dc.b	'Colour Map',0
	even

