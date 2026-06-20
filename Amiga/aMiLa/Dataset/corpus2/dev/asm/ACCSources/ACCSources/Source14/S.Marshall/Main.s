	opt	o+,o3-
; PPMuchMore .. A text file viewer for PowerPacked files. Will allow
;		multiple file viewing at any time. Requires arp.library
;		and powerpacker.library to run.

; Started 14/3/91 -- At 2pm


; 15/3/91 -- 0028 -- Got text in the windows, Horay. Load, Save and More
;		    are all working ok.

; 28/4/91 -- 1830 -- Added an About window, invoked by pressing HELP.
;         -- 1930 -- Added screen/window titles routines.
;         -- 2000 -- Now uses ARP CreatePort/DeletePort, saved 500 bytes.
;         -- 2200 -- Added Goto Line feature
; 29/4/91 -- 0015 -- Added smooth scrolling + tidied goto line code
;         -- 0200 -- Added page up/page down controls
;         -- 0215 -- Added Quit, Top and Bottom routines
;         -- 1215 -- Added case sensitive search routine
;         -- 1315 -- Added find next routine
;         -- 2215 -- Added dump file to printer routine
;         -- 2300 -- Finished adding ( meagre ) comments to source
;         -- 2301 -- Sat back and enjoyed a beer !

; 11/5/91 -- 2200 -- Added routine to read filename from CLI
;         -- 2215 -- Corrected bug so files > 64k can be read, damn DBcc!

; SHIT ! This source now totals over 40K, 42171 bytes to be presise. That is
;FORTY TWO THOUSAND KEYSTROKES. Now I`m no speed typist and this does not
;include all the failed mods that needed correction etc. I reckon this proggy
;has cost me over £6.00 in cig's, electric and wear 'n' tear already. What's
;worse is I know what else I want to add to it and how long it's going to
;take.
;       And this is only one of the programs ...........

; { <-- for you C programmers, so you don't feel left out --> }

;  That's my winge for today, back to this code soon ( off to bed now ).


; This source is of course PD.

; © M.Meany 1991

		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		graphics/graphics_lib.i
		include		source:include/ppbase.i
		include		source:include/powerpacker_lib.i
		include		"source:include/arpbase.i"
		include		"source:include/easystart.i"
		

;*****************************************

CALLSYS    MACRO		;added CALLSYS macro - using CALLARP
	IFGT	NARG-1       	;CALLINT etc can slow code down and  
	FAIL	!!!         	;waste a lot of memory  S.M. 
	ENDC                 
	JSR	_LVO\1(A6)
	ENDM

		
CALLNICO	Macro		Simplifies calling powerpacker.library
	move.l	_PPBase,a6	M.M
	jsr	_LVO\1(a6)
	endm
		
*****************************************************************************

; The main routine that opens and closes things

start		OPENARP				;use arp's own open macro
		movem.l		(sp)+,d0/a0	;restore d0 and a0 as the
						;the macro leaves these on
						;the stack causing corrupt
						;stack

;--------------	Save starting parameters

		move.l		a0,initial_file
		move.l		d0,CMD_len

;--------------	Save library base pointers that ARP supplies

		move.l		a6,_ArpBase	;store arpbase
		move.l		IntuiBase(a6),_IntuitionBase
		move.l		GFXBase(a6),_GfxBase

;-------------- Open PowerPacker library

		lea		pplibname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_PPBase
		beq.s		.error

;--------------	End of startup code, branch to program proper

		bsr.s		GoForIt		the program actual

;--------------	Close libraries and finish

		move.l		_PPBase,a1
		CALLEXEC	CloseLibrary

.error		move.l		_ArpBase,a1	a1->base addr of arp.library
		CALLEXEC	CloseLibrary	and close it
		rts

**************************************************************************

;-------------- 
;--------------	Program proper starts here
;-------------- 

GoForIt		
		bsr.s		OpenPort	open port for IDCMP
		tst.l		d0		all ok ?
		beq.s		.error		leave if not

		bsr.s		OpenAWindow	opens window
		tst.l		d0		all ok ?
		beq.s		.error1		leave if not

		bsr		TailLoad	load file from CLI CMD tail

		bsr		WaitOnUser	deal with user interaction
.error1		bsr		ClosePort	close IDCMP port
.error		rts				and leave

;-------------- 
;-------------- Open a port to recieve IDCMP from the windows
;-------------- 

;-------------- Create a port

OpenPort	lea		MyPortName,a0	a0->name for port
		moveq.l		#0,d0		d0=ports priority
		CALLARP		CreatePort	and get a port
		move.l		d0,MyPort	save its address
		rts				and return


;--------------	
;--------------	Open a window
;--------------	


; Note that a port must already be created and it's address stored at
;MyPort. This is attached to the user port field of the window after
;creation.

; M.Meany 10/3/91

;--------------	First allocate mem for variables for this prog

OpenAWindow	move.l		#vars_sizeof,d0
		CALLARP		DosAllocMem
		move.l		d0,d6
		beq		.error

		move.l		d0,a4

;-------------- Initialise file requeser structures

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

;--------------	Initialise IntuiText structure

		lea		msg_text(a4),a0
		move.b		#1,(a0)		;frontpen
		move.b		#RP_JAM2,it_DrawMode(a0)
		lea		line_buf(a4),a1
		move.l		a1,it_IText(a0)

;--------------	Now open the window

		lea		MyWindow,a0
		CALLINT		OpenWindow
		move.l		d0,window.ptr(a4)
		bne.s		.ok

;--------------	No window so free vars memory and quit

		move.l		d6,a1
		CALLARP		DosFreeMem
		moveq.l		#0,d0
		bra.s		.error

;--------------	We have a window, so now we need to set things. First
;		get a copy of rastport pointer.

.ok		move.l		d0,a0
		move.l		wd_RPort(a0),window.rp(a4)

;--------------	Now save vars address in User Data field of window struct

		move.l		d6,wd_UserData(a0)

;--------------	Attach a user port

		move.l		MyPort,wd_UserPort(a0)

;--------------	Set IDCMP flags

		move.l		#CLOSEWINDOW!NEWSIZE!ACTIVEWINDOW!RAWKEY,d0
		CALLINT		ModifyIDCMP

;--------------	Call win_sized to initisalise all window particulars

		bsr		win_sized

;--------------	Set screen and window titles

		move.l		window.ptr(a4),a0	a0->window
		lea		winname,a1		a1->window title
		lea		scrn_Title,a2		a2->screen title
		CALLINT		SetWindowTitles

;--------------	All went ok so set d0 ( d0=0 => an error )

		moveq.l		#1,d0

;--------------	Bump open window counter

		add.l		d0,StillHere

.error		rts

;--------------
;-------------- Attempt to load a file specified as CLI parameter
;--------------

;--------------	Make sure task was started from the CLI, if not return

TailLoad	tst.l		returnMsg
		bne.s		.no_file

;--------------	If no file name specified leave

		move.l		CMD_len,d0
		subq.l		#1,d0
		beq.s		.no_file

;--------------	Copy specified filename into correct location
;		filename must be terminated by a space or $0a byte

		lea		LoadPathName(a4),a0
		move.l		initial_file,a1
.loop		move.b		(a1)+,(a0)+
		cmpi.b		#$0a,(a1)
		beq.s		.ok
		cmpi.b		#' ',(a1)
		beq.s		.ok
		bra.s		.loop

;--------------	NULL terminate the filename

.ok		move.b		#0,(a0)

;--------------	Attempt to load the file. Jump into Load subroutine

		bsr		Entry1

.no_file	rts



;--------------
;-------------- Refreshes the screen display
;--------------

refresh_display	tst.l		line_list(a4)
		beq.s		referror

;-------------- set drawing pen to background colour

		move.l		window.rp(a4),a1
		moveq.l		#0,d0
		CALLGRAF	SetAPen

;--------------	Blit a big rectangle over window contents

		move.l		window.rp(a4),a1
		moveq.l		#4,d0
		moveq.l		#10,d1
		move.l		scrn_width(a4),d2
		move.l		scrn_height(a4),d3
		addq.l		#1,d3
		CALLGRAF	RectFill

;--------------	print text 

		move.l		#10,linenum(a4)		screen y pos
		move.l		top_line(a4),d4
		move.l		lines_on_scrn(a4),d5
		subq.l		#1,d5

plop		move.l		d4,d0
		bsr.s		print_line
		addq.l		#1,d4
		dbra		d5,plop

referror	rts

;--------------	
;--------------	Subroutine that prints a line given its number and bumps
;--------------	the screen print position

print_line	cmp.l		num_lines(a4),d0
		bgt.s		.error

;--------------	Get addr of text from line num

		subq.l		#1,d0
		asl.l		#2,d0		x4
		add.l		line_list(a4),d0
		move.l		d0,a1
		move.l		(a1),a1

;--------------	Expand the text into printable form

		lea		line_buf(a4),a0
		bsr.s		expand_text

;--------------	Clip line so window border is not corrupted

		lea		line_buf(a4),a0
		move.l		chars_on_line(a4),d0
		move.b		#0,0(a0,d0)

;--------------	And print it

		lea		msg_text(a4),a1
		move.l		window.rp(a4),a0
		moveq.l		#5,d0
		move.l		linenum(a4),d1
		CALLINT		PrintIText

;--------------	Bump screen position and finish

		move.l		font.height(a4),d0
		add.l		d0,linenum(a4)
.error		rts

;--------------	
;--------------	Expand text into printable format
;--------------	

; Given the address of a $0a terminated line of text, this subroutine will
;produce a printable line ( TAB's expanded ) in a line buffer.

; Entry		a0 must hold address of line buffer for expanded text
;		a1 must hold address of start of text string
		
		
expand_text	movem.l		d0-d7/a0-a1,-(sp) save registers
		moveq.l		#0,d6		d6=line length
		moveq.l		#$09,d2		d2=TAB
		moveq.l		#$0a,d3		d3=CR
		moveq.l		#' ',d4		d4=space
.next_char	move.b		(a1)+,d0	d0=next char
		cmp.b		d3,d0		new line ?
		beq.s		.line_done	if so finish up
		cmp.b		d2,d0		TAB ?
		beq.s		.do_tab		if so deal with it
		move.b		d0,0(a0,d6)	position character
		addq.w		#1,d6		bump counter
		bra.s		.next_char	go back for next char
		
.line_done	move.b		#0,0(a0,d6)	null terminate line
		movem.l		(sp)+,d0-d7/a0-a1 restore registers
		rts
		
.do_tab		move.l		d6,d1		copy chars so far
		asr.w		#3,d1		calculate num of spaces
		addq.w		#1,d1
		asl.w		#3,d1
		sub.w		d6,d1
		subq.w		#1,d1		adjust for dbra
.next_spc	move.b		d4,0(a0,d6)	add a space
		addq.w		#1,d6		bump line length
		dbra		d1,.next_spc	until tab position reached
		bra.s		.next_char



;-------------- 
;-------------- Deal with user interaction
;-------------- 

; First wait for a message to arrive at MyPort.

WaitOnUser	move.l		MyPort,a0	a0-->window user port
		CALLEXEC	WaitPort	wait for something to happen

; Message arrived, so get its address

		move.l		MyPort,a0	a0-->window user port
		CALLSYS		GetMsg		get any messages

; If no address returned this was a bogus message, ignore it.

		tst.l		d0		was there a message ?
		beq.s		WaitOnUser	if not loop back

; Obtain message class and message source from message structure returned.

		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.l		im_Code(a1),d3	d3=RAWKEY code
		move.l		im_Qualifier(a1),d4
		move.l		im_IDCMPWindow(a1),a5 a5=ptr to window
		move.l		im_IAddress(a1),a3 a3=addr of struct

; Answer the message now.

		CALLSYS		ReplyMsg	answer o/s or it gets angry

; Check if user has hit a close gadget

		cmp.l		#CLOSEWINDOW,d2	 flag=CLOSEWINDOW ?
		bne.s		.check_resize	 if not jump
		bsr		win_closed
		bra.s		.test_complete

; Check if window has been sized

.check_resize	cmp.l		#NEWSIZE,d2	flag=NEWSIZE ?
		bne.s		.check_key
		bsr.s		win_sized
		bra.s		.test_complete

; Check if a key has been pressed

.check_key	cmp.l		#RAWKEY,d2
		bne.s		.check_active
		bsr		do_keys
		bra.s		.test_complete

; Check if another window has been activated

.check_active	cmp.l		#ACTIVEWINDOW,d2
		bne.s		.check_gadg
		bsr		win_activate
		bra.s		.test_complete

; Check if a gadget has been selected

.check_gadg	cmp.l		#GADGETUP,d2
		bne.s		.test_complete
		move.l		gg_UserData(a3),a0
		jsr		(a0)
		
; All interactions dealt with. If 1 or more windows still open loop back

.test_complete	tst.l		StillHere
		bne		WaitOnUser

; No windows open so quit

		rts

;--------------	
;--------------	Deal with window resizing
;--------------	

win_sized	move.l		window.ptr(a4),a0

;--------------	Set font width

		move.l		window.rp(a4),a1
		moveq		#0,d1
		move.w		rp_TxWidth(a1),d1
		move.l		d1,font.width(a4)

;--------------	Set font height

		move.w		rp_TxHeight(a1),d1		
		move.l		d1,font.height(a4)

;--------------	Set screen height

		moveq.l		#0,d0
		move.w		wd_Height(a0),d0
		sub.l		#12,d0
		move.l		d0,scrn_height(a4)

;--------------	Calc and set maximum number of lines to display in window

		divu		d1,d0
		and.l		#$ffff,d0
		subq.l		#1,d0
		move.l		d0,lines_on_scrn(a4)

;--------------	Calc and set width of display

		moveq		#0,d0
		move.w		wd_Width(a0),d0
		subq.w		#4,d0
		move.l		d0,scrn_width(a4)

;--------------	Calc and set max number of characters to display per line

		divu		font.width+2(a4),d0
		subq.w		#1,d0
		and.l		#$ffff,d0
		move.l		d0,chars_on_line(a4)

;-------------- set drawing pen to background colour

		move.l		window.rp(a4),a1
		moveq.l		#0,d0
		CALLGRAF	SetAPen

;--------------	Blit a big rectangle over window contents

		move.l		window.rp(a4),a1
		moveq.l		#4,d0
		move.l		scrn_height(a4),d1
		move.l		scrn_width(a4),d2
		sub.l		#12,d2
		move.l		d1,d3
		add.l		#10,d3
		CALLGRAF	RectFill

;--------------	Display text and return

		bsr		refresh_display
		rts

;--------------	
;--------------	Deal with keypress
;--------------	

do_keys		swap		d3
		cmpi.b		#$37,d3		M key for new window
		bne.s		.is_L
		bsr		OpenAWindow
		bra		.ok

.is_L		cmpi.b		#$28,d3		L key for Load
		bne.s		.is_S
		bsr		Load
		bra		.ok

.is_S		cmpi.b		#$21,d3		S key for Save
		bne.s		.is_G
		bsr		Save
		bra		.ok

.is_G		cmpi.b		#$24,d3		G key for Goto
		bne.s		.is_Q
		bsr		GotoLine
		bra		.ok

.is_Q		cmpi.b		#$10,d3		Q key to Quit
		bne.s		.is_T
		bsr		win_closed
		bra.s		.ok

.is_T		cmpi.b		#$14,d3		T for top of file
		bne.s		.is_B
		bsr		GoTop
		bra.s		.ok

.is_B		cmpi.b		#$35,d3		B for bottom of file
		bne.s		.is_F
		bsr		GoBot
		bra.s		.ok

.is_F		cmpi.b		#$23,d3		F for Find string
		bne.s		.is_N
		bsr		SearchString
		bra.s		.ok

.is_N		cmpi.b		#$36,d3		N for find Next
		bne.s		.is_D
		bsr		Next
		bra.s		.ok

.is_D		cmpi.b		#$22,d3		D for Dump file
		bne.s		.is_up
		bsr.s		DumpFile
		bra.s		.ok

.is_up		cmpi.b		#$4d,d3		down arrow
		bne.s		.is_down
		and.l		#$30000,d4	mask shift bits
		bne.s		.is_pup
		bsr		line_up
		bra.s		.ok

.is_pup		bsr		page_up		down arrow + shift
		bra.s		.ok

.is_down	cmpi.b		#$4c,d3		up arrow
		bne.s		.is_about
		and.l		#$30000,d4	mask shift bits
		bne.s		.is_pdown
		bsr		line_down
		bra.s		.ok

.is_pdown	bsr		page_down	up arrow + shift
		bra.s		.ok

.is_about	cmpi.b		#$5f,d3		help key
		bne.s		.ok
		bsr		About
		bra.s		.ok

		nop
.ok		rts


;--------------	
;--------------	Dump file to printer
;--------------	

;--------------	Open PRT: device

DumpFile	bsr		PointerOn

		move.l		#printername,d1
		move.l		#MODE_NEWFILE,d2
		CALLARP		Open
		move.l		d0,d5
		beq.s		.error

;--------------	Dump file

		move.l		d0,d1
		move.l		buffer(a4),d2
		move.l		buf_len(a4),d3
		CALLSYS		Write

;--------------	Close PRT:

		move.l		d5,d1
		CALLSYS		Close

.error		bsr		PointerOff
		rts

;--------------	
;--------------	Go to top of file
;--------------	

GoTop		move.l		#1,top_line(a4)
		bsr		refresh_display
		rts

;--------------	
;--------------	Go to bottom of file
;--------------	

GoBot		move.l		max_top_line(a4),top_line(a4)
		bsr		refresh_display
		rts

;--------------	
;--------------	Scroll a line up
;--------------	

line_up		tst.l		line_list(a4)
		beq.s		.error

;--------------	Check were not scrolling past end of file

		move.l		top_line(a4),d0
		cmp.l		max_top_line(a4),d0
		beq.s		.error

;--------------	Bump number of 1st line to display

		addq.l		#1,d0
		move.l		d0,top_line(a4)

;--------------	Scroll contents of window up by height of font

		move.l		window.rp(a4),a1
		moveq.l		#0,d0
		move.l		font.height(a4),d1
		moveq.l		#5,d2
		moveq.l		#10,d3
		move.l		scrn_width(a4),d4
		move.l		font.height(a4),d5
		mulu		lines_on_scrn+2(a4),d5
		add.l		#9,d5
		CALLGRAF	ScrollRaster

;--------------	Print a new line at the bottom of the display

		move.l		lines_on_scrn(a4),d0
		subq.l		#1,d0
		move.l		d0,d1
		mulu		font.height+2(a4),d1
		add.l		#10,d1
		move.l		d1,linenum(a4)
		add.l		top_line(a4),d0
		bsr		print_line
.error		rts

;--------------	
;--------------	Scroll a line down
;--------------	

line_down	tst.l		line_list(a4)
		beq.s		.error

;--------------	Check to see if the start of file is already displayed

		move.l		top_line(a4),d0
		subq.l		#1,d0
		beq.s		.error
		move.l		d0,top_line(a4)

;--------------	Scroll the display down the height of the font

		move.l		window.rp(a4),a1
		moveq.l		#0,d0
		move.l		font.height(a4),d1
		neg.l		d1
		moveq.l		#5,d2
		moveq.l		#10,d3
		move.l		scrn_width(a4),d4
		move.l		font.height(a4),d5
		mulu		lines_on_scrn+2(a4),d5
		add.l		#9,d5
		CALLGRAF	ScrollRaster

;--------------	Print a new line at the top of the display

		move.l		#10,linenum(a4)
		move.l		top_line(a4),d0
		bsr		print_line
.error		rts

;--------------	
;--------------	Move up one page
;--------------	

page_up		tst.l		line_list(a4)
		beq.s		.error

;--------------	Calc which line should be at the top

		move.l		top_line(a4),d0
		add.l		lines_on_scrn(a4),d0
		subq.l		#1,d0

;--------------	If past EOF set to EOF

		cmp.l		max_top_line(a4),d0
		ble.s		.ok
		move.l		max_top_line(a4),d0

;--------------	Set top line of display and display new page

.ok		move.l		d0,top_line(a4)
		bsr		refresh_display
.error		rts

;--------------	
;--------------	Move down one page
;--------------	

page_down	tst.l		line_list(a4)
		beq.s		.error

;--------------	Calc what line should be at top of display

		move.l		top_line(a4),d0
		sub.l		lines_on_scrn(a4),d0
		addq.l		#1,d0

;--------------	Make sure this is not less than 1st line of text

		cmp.l		#1,d0
		bge.s		.ok
		moveq		#1,d0

;--------------	Display new page of text

.ok		move.l		d0,top_line(a4)
		bsr		refresh_display
.error		rts

;--------------	
;--------------	Load a text file
;--------------	

; This subroutine checks if a file is already in memory. If so all memory
;allocated to it is freed before a new file is loaded.

; Check if a file is already loaded

Load		bsr		PointerOn
		tst.l		buffer(a4)
		beq.s		.ok

; If so free the memory it occupies ( ie scrap it )
		
		move.l		buffer(a4),a1
		move.l		buf_len(a4),d0
		CALLEXEC	FreeMem
			
		move.l		#0,buffer(a4)

; Use ARP filerequester to get a filename, return if none specified

.ok		bsr		arpload
		beq		load_error

Entry1		move.l		window.ptr(a4),a0
		lea		LoadPathName(a4),a1
		lea		scrn_Title,a2
		CALLINT		SetWindowTitles

; Use powerpacker.library to load/decrunch the file

		lea		LoadPathName(a4),a0
		moveq.l		#DECR_POINTER,d0
		moveq.l		#0,d1
		lea		buffer(a4),a1
		lea		buf_len(a4),a2
		move.l		d1,a3
		CALLNICO	ppLoadData
		tst.l		d0
		bne.s		ld_mem_err

;--------------	Free memory for any table currently in mem

		move.l		line_list(a4),a1
		CALLARP		DosFreeMem

;--------------	Count num of lines in file

		moveq.l		#0,d0		init counter
		move.l		d0,d1		clear d1
		moveq.l		#$0a,d2		d2=line-feed
		move.l		buf_len(a4),d3	init loop counter
		move.l		buffer(a4),a0	a0->buffer
		movem.l		d1-d3/a0,-(sp)	save init values


lf_loop		cmp.b		(a0)+,d2	is this byte a LF
		bne.s		.ok		if not jump
		addq.l		#1,d0		else bump counter
.ok		subq.l		#1,d3		loop until end of file
		bne.s		lf_loop

;--------------	Get memory for line table, addr of start of every line
;		will be saved in this table

		move.l		d0,num_lines(a4)	save counter
		addq.l		#2,d0		to be safe
		asl.l		#2,d0		x4, 4 bytes/entry
		CALLARP		DosAllocMem	get mem for line table
		movem.l		(sp)+,d1-d3/a0	reset registers to init vals
		move.l		d0,line_list(a4)	save pointer
		beq.s		ld_mem_err		leave if error

;--------------	Find addr of start of each line and store in table

		move.l		d0,a1		a1->table
		move.l		a0,(a1)+	addr of 1st line into table

table_loop	cmp.b		(a0)+,d2	this byte a LF
		bne.s		.ok		if not then jump
		move.l		a0,(a1)+	else save addr of next line
.ok		subq.l		#1,d3		loop until end of file
		bne.s		table_loop	
		
		move.l		#1,top_line(a4)	set top line num

;--------------	Calculate the max value of top_line

		move.l		lines_on_scrn(a4),d0
		move.l		num_lines(a4),d1
		sub.l		d0,d1
		beq.s		.error
		bmi.s		.error
		bra.s		.ok1
.error		moveq.l		#1,d1
.ok1		move.l		d1,max_top_line(a4)

;--------------	Display the text for the user

		bsr		refresh_display

		bra.s		load_error


; If file was not loaded for some reason, flash the screen

ld_mem_err	move.l		#0,a0
		CALLINT		DisplayBeep
		
load_error	bsr		PointerOff
		moveq.l		#0,d0
		rts

;--------------	
;--------------	Obtain name of file to load
;--------------	

; Uses ARP filerequester to get source filename.
	
arpload		lea		LoadFileStruct(a4),a0	;get file struct
		CALLARP		FileRequest 		;and open requester
		tst.l		d0			;did the user cancel ?
		beq.s		NoPath
		lea		LoadFileStruct(a4),a0	;get file struct
		move.l		fr_File(a0),a1
		tst.b		(a1)
		beq.s		NoPath
		bsr		CreatePath		;make full pathname
		tst.b		LoadPathName(a4)	;is there a pathname ?
NoPath		rts					;and return to calling routine

;--------------	
;--------------	Save text file
;--------------	

; Files are always saved decrunched !

; First, check a file is in memory, quit if not

Save		bsr		PointerOn
		tst.l		buffer(a4)
		beq.s		save_error

; Use ARP filerequester to get filename, quit if none specified

		bsr.s		arpsave
		tst.b		SavePathName(a4)
		beq.s		save_error

; Open the desired file

		move.l		a4,d1
		add.l		#SavePathName,d1
		move.l		#MODE_NEWFILE,d2
		CALLARP		Open
		move.l		d0,d7
		bne.s		.ok

; If file would not open flash screen and quit

		move.l		#0,a0
		CALLINT		DisplayBeep
		bra.s		save_error

; Copy buffer to desired file
		
.ok		move.l		d0,d1
		move.l		buffer(a4),d2
		move.l		buf_len(a4),d3
		CALLSYS		Write

; Close the file

		move.l		d7,d1
		CALLSYS		Close

; And finish

save_error	bsr.s		PointerOff
		moveq.l		#0,d0
		rts

;--------------	
;--------------	Obtain name of file to save
;--------------	

arpsave		lea		SaveFileStruct(a4),a0	;get file struct
		CALLARP		FileRequest 		;and open requester 
		tst.l		d0			;did the user cancel ?
		beq.s		NoPath2			;yes then quit
		lea		SaveFileStruct(a4),a0	;get file struct
		move.l		fr_File(a0),a1
		tst.b		(a1)
		beq.s		NoPath2
		bsr.s		CreatePath		;make full pathname
NoPath2		rts					;and return to calling routine

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

;--------------
;--------------	Routine to display custom 'sleeping' pointer
;--------------

PointerOn	move.l		window.ptr(a4),a0
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

PointerOff	move.l		window.ptr(a4),a0
		CALLINT		ClearPointer
		rts


;--------------	
;--------------	Deal with window activation
;--------------	

win_activate	move.l		wd_UserData(a5),a4
		rts


;--------------	
;--------------	Close a window
;--------------	


win_closed	move.l		wd_UserData(a5),a3	a3->vars

;--------------	Release memory used to store line list

		move.l		line_list(a3),a1
		CALLARP		DosFreeMem

;--------------	Release memory used to hold text file

		move.l		buffer(a3),a1
		move.l		buf_len(a3),d0
		beq.s		.ok
		CALLEXEC	FreeMem

;--------------	Release the vars memory block

.ok		move.l		a3,a1
		CALLARP		DosFreeMem

;--------------	Now close the window

		move.l		a5,a0
		move.l		_IntuitionBase,a6
		bsr.s		CloseWindowSafely

;--------------	Decrease windows counter and finish

		subq.l		#1,StillHere
		rts

;------------------------------------------------------------------
;--------------	Routine to close a window with a shared IDCMP port
;--------------	Called as  CloseWindowSafely(Window)
;--------------	                               a0
;--------------	Must be called with _IntuitionBase in reg a6
;--------------	All regs except a0/a1 and d0/d1 are restored
;--------------	By Steve Marshall - Based on the CloseWindowSafely
;--------------	C code found on page 171 of RKM Libs and Devices.
;------------------------------------------------------------------

CloseWindowSafely:
		movem.l		a4-a5/d6-d7,-(sp)	;save regs

;------	Check that we have a port - just to be safe		
		move.l		wd_UserPort(a0),d0 ;get port
		beq.s		.NoPort		;no port = no messages
		
		move.l		d0,a4		;save port
		move.l		a6,a5		;save _IntuitionBase
		move.l		a0,d7		;save window ptr
		
		CALLEXEC	Forbid		;disable multi-tasking
		
		move.l		MP_MSGLIST(a4),a4 ;get first message 
.loop
		move.l		(a4),d6		;get ln_succ
		beq.s		.NoMsgs		;branch if null
		
		cmp.l		im_IDCMPWindow(a4),d7 ;is it for our window
		bne.s		.NotOurWindow	;branch if ours
				
		move.l		a4,a1		;message in a1
		CALLSYS		Remove		;remove message from list
		
		move.l		a4,a1		;message in a1
		CALLSYS		ReplyMsg	;reply to message
		
.NotOurWindow
		move.l		d6,a4		;get successor
		bra.s		.loop		;branch back to handle message
		
.NoMsgs
		moveq		#0,d0		;clear d0
		move.l		d7,a0		;window in a0
		move.l		d0,wd_UserPort(a0) ;clear port ptr
		move.l		a5,a6		;get _IntuitionBase
		CALLSYS		ModifyIDCMP	;make sure we get no more msgs
		
		CALLEXEC	Permit		;enable multi-tasking

		move.l		a5,a6		;get _IntuitionBase
		move.l		d7,a0		;window in a0
.NoPort		
		CALLSYS		CloseWindow	;and close window
		
		movem.l		(sp)+,a4-a5/d6-d7 ;restore regs
		rts				;end of subroutine


;-------------- 
;--------------	Delete the port
;-------------- 


;--------------	If pointer to port exsists, delete the port

ClosePort	move.l		MyPort,d0	d0=addr of port
		beq.s		.ok		quit if not set
		move.l		d0,a1		a1->port
		CALLARP		DeletePort	and delete it

.ok		rts				all done so return


;--------------	
;--------------	Include subroutines and data
;--------------	

		incdir		df1:ppmore/
		incdir		rrd:

		include		about_win.i
		even
		include		goto_win_1.i
		even
		include		search_win_1.i
		even

;--------------	
;--------------	Window Def's
;--------------	

MyWindow	dc.w		0,10
		dc.w		640,189
		dc.b		0,1
		dc.l		0
		dc.l		WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+NOCAREREFRESH+ACTIVATE
		dc.l		0
		dc.l		0
		dc.l		winname
		dc.l		0
		dc.l		0
		dc.w		50,50
		dc.w		640,256
		dc.w		WBENCHSCREEN

winname		dc.b		'No File Loaded',0
		even


;--------------	
;--------------	Port name ( the port is not private, so it must be named ).
;--------------	

MyPortName	dc.b		'M.Meanys-Port',0
		even

;--------------	
;--------------	Variables
;--------------	

pplibname	dc.b		'powerpacker.library',0
		even

LoadText	dc.b		'Load File ',0
		even
SaveText	dc.b		'Save File ',0
		even

scrn_Title	dc.b		'PPMuchMore © M.Meany 1991. Press HELP for instructions. ',0
		even

printername	dc.b		'prt:',0
		even

;--------------	
;--------------	Data block def`s as attached to each window
;--------------	

		rsreset
window.ptr	rs.l		1	pointer to windows struct
window.rp	rs.l		1	pointer to windows rastport

buffer		rs.l		1	address of text file in memory
buf_len		rs.l		1	length of text file

line_list	rs.l		1	pointer to line table

num_lines	rs.l		1	num of lines in file
top_line	rs.l		1	line number of top line on screen
lines_on_scrn	rs.l		1	max num of lines that can be printed
linenum		rs.l		1	line number of print position
max_top_line	rs.l		1	max value of top_line
chars_on_line	rs.l		1	char width of a screen line
scrn_width	rs.l		1	pixel width of screen line
scrn_height	rs.l		1	pixel height of screen

font.width	rs.l		1	width of font in use
font.height	rs.l		1	height of font in use

line_buf	rs.l		100	buffer for expanded text

SearchBuffer	rs.b		42	buffer for search string

msg_text	rs.l	it_SIZEOF	space for IntuiText structure

LoadFileStruct	rs.b	fr_SIZEOF+4	space for load filerequest struct

SaveFileStruct	rs.b	fr_SIZEOF+4	space for save filerequest struct

LoadFileData	rs.b	FCHARS+2	;reserve space for filename buffer

LoadDirData	rs.b	DSIZE+1		;reserve space for path buffer

SaveFileData	rs.b	FCHARS+2	;reserve space for filename buffer

SaveDirData	rs.b	DSIZE+1		;reserve space for path buffer

LoadPathName	rs.b	DSIZE+FCHARS+3	;reserve space for full pathname name buffer

SavePathName	rs.b	DSIZE+FCHARS+3	;reserve space for full pathname name buffer

vars_sizeof	rs.l		0

;--------------	
;--------------	Variables used by program, not unique to each window
;--------------	

		section	vars,BSS

_ArpBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1
_PPBase		ds.l		1

initial_file	ds.l		1
CMD_len		ds.l		1

about.ptr	ds.l		1
AboutFlag	ds.l		1
GotoFlag	ds.l		1

MyPort		ds.l		1
StillHere	ds.l		1

;--------------	
;--------------	Custom pointer data ( OK ! I know it`s crap )
;--------------	

	section		pointer,data_c
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

; To all who have bothered to read this far, I would like to express my
;thanks to Steve Marshall for helping me tame my Amiga.
