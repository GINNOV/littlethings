
		opt		o+,ow-

; Added ARP file requester and quit requester because I was fed up with
;the program refusing to load a text file. Done away with command line
;parameters.

; Gave the window a drag bar, added © to window title and changed gadget
;colours to make them easier to read. Also alterd the position of text in
;the window so the title bar remains intact and the scrollraster call no
;longer leaves a line of garbage at the bottom of the screen. M.Meany
;2:30pm 12 Oct 90

; A couple of hours later and line_table is now allocated dynamically. This
;should reduce the code by about 4K. M.Meany  1pm 12 Oct 90

; Time for a quick note. The code is becoming untidy. The original structure
;went out the window around midnight. This is mainly due to Intuition being
;new to me. I can see loads of ways of reducing the code size and reducing
;the workload, but I'm too bloody tired to rewrite half this lot again. 
; Before writing this program I had never used Boolean gadgets or read the
;keyboard through an Intuition window. What a work up !
; I'm going to give up for now as this mess must be tidied up before I add
;any more confusion to it. Whatever happend to the days when I used to 
;flowchart a program before I sat at the keyboard ?

; Cursor up and down keys can now be used to move up and down text file.
;What will I think of next ?  M.Meany  5:50am 12 Oct 90

; Can now enter filename as cli parameter. Usage text is displayed if no
;parameters are found or first parameter is a ?. M.Meany 4:30am 12 Oct 90.

; After many hours ( and many Guru's ) I've finaly got the line up/down and
;page up/down gadgets working. M.Meany 3am 12 October 90

; This program opens an intuition window with a number of boolean gadgets
;in. It then checks for gadget selection and displays a message about which
;gadget was selected. M.Meany 11 October 90

		incdir		"vd0:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
;		include		"libraries/dos_lib.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"
		include		"misc/arpbase.i"
		
ciaapra		equ		$bfe001
	
start		move.l		a0,param_ptr	save pointer to and address
		move.l		d0,param_len	of CLI parameters
		bsr		intopen		open Intuition library
		beq		error1
		bsr		dosopen		open DOS library
		beq		error2
		bsr		gfxopen		open graphics library
		beq.s		error3
		bsr		check_usage	check for valid parameters
		tst.l		d0
		beq.s		error3
		bsr		size_of_file	find length of file
		tst.l		file_len
		beq		error4
		bsr		reserve_mem	reserve some memory for text
		beq.s		error4
		bsr		read_text	read the text in
		beq.s		error5
		bsr		process_text	remove all non-alphanumeric's
		beq		error5
		bsr		openwindows	open a window to write into
		beq.s		error6
		bsr		refresh_display write the first page of text
		bsr		wait_for_msg	wait for user to do something
		
		bsr		closewindows	close our window
error6		bsr		release_table_mem
error5		bsr		release_buffer_mem  release memory used for text
error4		bsr		gfxclose	close graphics library
error3		bsr		dosclose	close DOS library
error2		bsr		intclose	close Intuition library
error1		rts				good-bye !
	
*****************************************************************************	
; Open Intuition library
*****************************************************************************	
	
intopen		lea		intname,a1	a1-->library name
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary	open this library
		move.l		d0,_IntuitionBase	store pointer to lib
		rts				return to calling routine

*****************************************************************************	
; Open ARP and DOS libraries.
*****************************************************************************	

dosopen		OPENARP
		movem.l		(sp)+,d0/a0
		move.l		a6,_ArpBase

		moveq.l		#0,d0
		lea		dosname,a1
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		rts


*****************************************************************************	
; Open Graphics library
*****************************************************************************	

gfxopen		moveq.l		#0,d0
		lea		grafname,a1
		CALLEXEC	OpenLibrary
		move.l		d0,_GfxBase
		rts

*****************************************************************************
; Check parameters. If there are non or the first is a ? then display usage
;text and clear d0 to flag main program.
*****************************************************************************

; First, get i/o handles of the calling CLI

check_usage	CALLDOS		Input
		move.l		d0,CLI_in
		CALLDOS		Output
		move.l		d0,CLI_out

; See if first parameter is a ?

		move.l		param_ptr,a0
		cmpi.b		#'?',(a0)
		bne.s		not_usage
		
; Well this idiot hasn't read the instructions so lets give him a clue
		
		move.l		#usage_text,d2
		move.l		#usage_end-usage_text,d3
		move.l		CLI_out,d1
		CALLDOS		Write
		moveq.l		#0,d0
		beq.s		NoPath

; OK, lets get a file name using the ARP filerequester.

not_usage	
		
Load:	lea		LoadFileStruct,a0	;get file struct
	CALLARP		FileRequest 		;and open requester
	tst.l		d0			;did the user cancel ?
	beq		NoPath			;yes then quit
	lea		LoadFileStruct,a0	;get file struct
	bsr		CreatePath		;make full pathname
	moveq.l		#0,d0			;reset flag
	tst.b		LoadPathName		;is there a pathname ?
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
; Find the length of the text file
*****************************************************************************	

; Allocate some memory for the File Info block

size_of_file	move.l		#0,file_len
		move.l		#fib_SIZEOF,d0
		move.l		#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l		d0,file_info
		beq		err1
		
; Lock the file
		
		move.l		#LoadPathName,d1
		move.l		#ACCESS_READ,d2
		CALLDOS		Lock
		move.l		d0,file_lock
		beq		err2

; Use Examine to load the File Info block

		move.l		d0,d1
		move.l		file_info,d2
		CALLDOS		Examine

; Copy the length of the file into file_len ( add 10 bytes to be safe )

		move.l		file_info,a0
		move.l		fib_Size(a0),file_len
		add.l		#10,file_len		to be sure !

; Release the file

		move.l		file_lock,d1
		CALLDOS		UnLock

; Release allocated memory

err2		move.l		file_info,a1
		move.l		#fib_SIZEOF,d0
		CALLEXEC	FreeMem
err1		rts

*****************************************************************************	
; Reserve memory for text file
*****************************************************************************	

reserve_mem	move.l		file_len,d0
		move.l		#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l		d0,buffer
		rts

*****************************************************************************	
; Read text from file into memory
*****************************************************************************	

; Open the file for reading

read_text	move.l		#MODE_OLDFILE,d2
		move.l		#LoadPathName,d1
		CALLDOS		Open
		move.l		d0,file_handle
		beq.s		file_error
		
; Read in the text

		move.l		d0,d1
		move.l		buffer,d2
		move.l		file_len,d3
		CALLDOS		Read
		move.l		d0,text_len
		beq.s		file_error
		
; Close the file

		move.l		file_handle,d1
		CALLDOS		Close
		moveq.l		#1,d0		no errors !
		
file_error	rts

*****************************************************************************	
; Process text. Replace all $0A's with $00 so each line becomes null
;terminated, as required by PrintIText (). Also records the start address
;of each line of text in a table for quick reference later.
*****************************************************************************	

; Count the number of lines of text in the file. Set the maximum line number

process_text	move.l		buffer,a0
		move.l		text_len,d1
		subq.b		#1,d1
		moveq.l		#1,d0
count_lines	cmpi.b		#$0A,(a0)+
		bne.s		not_CR
		addq.l		#1,d0
not_CR		dbra		d1,count_lines
		move.l		d0,line_count
		subi.l		#18,d0
		move.l		d0,max_line
		
		move.l		line_count,d0
		move.l		#MEMF_PUBLIC,d1
		add.l		#5,d0
		mulu.w		#4,d0
		move.l		d0,table_len
		CALLEXEC	AllocMem
		move.l		d0,line_table
		beq.s		memory_error
		
; Replace all $0A's with $00's. Also record line start address in table.

		move.l		line_table,a0
		move.l		text_len,d0
		subq.l		#1,d0
		move.l		buffer,a1
		move.l		buffer,(a0)+
process_loop	cmpi.b		#$0a,(a1)+
		bne.s		ignore_char
		move.b		#0,-1(a1)
		move.l		a1,d1
		move.l		d1,(a0)+
ignore_char	dbra		d0,process_loop

; Replace all non-zero, non-alphnumeric characters with spaces

		move.l		buffer,a0
		move.l		text_len,d2
remove		cmpi.b		#0,(a0)+
		beq.s		its_a_char
		cmpi.b		#32,-1(a0)
		blt.s		substitute
		cmpi.b		#127,-1(a0)
		bgt.s		substitute
		bra		its_a_char
substitute	move.b		#' ',-1(a0)
its_a_char	dbra		d2,remove
		moveq.l		#1,d0		make sure Z flag is clear

memory_error	rts		

*****************************************************************************	
; Open Intuition Windows
*****************************************************************************	
		
openwindows	lea		tutor_window,a0	a0-->window structure
		CALLINT		OpenWindow	open this window
		move.l		d0,tutor.ptr	save window pointer
		rts

*****************************************************************************	
; Deal with gadget selections
*****************************************************************************	

; Wait for intuition message. Quits if the window close gadget is selected or
;the Quit gadget is selected. If some other gadget is selected then a comment
;is displayed detailing which gadget was hit. Now even checks for keystrokes.

wait_for_msg	move.l		tutor.ptr,a0	
		move.l		wd_UserPort(a0),a0  a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		tutor.ptr,a0		a0-->window pointer
		move.l		wd_UserPort(a0),a0  	a0-->user port
		CALLEXEC	GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq		wait_for_msg	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.w		im_Code(a1),d3
		move.l		im_IAddress(a1),d7
		CALLEXEC	ReplyMsg	answer o/s or it gets angry
		cmp.l		#CLOSEWINDOW,d2	window closed ?
		beq.s		QuitReq		if so make sure
		cmp.l		#GADGETUP,d2
		beq.s		find_gadget
		cmp.l		#RAWKEY,d2
		beq		find_key
		bra		wait_for_msg	else wait for next message
got_msg		rts

; Well a gadget has been selected so lets find out which one and do something

find_gadget	cmp.l		#pupgadg,d7
		beq		page_up
		cmp.l		#pdowngadg,d7
		beq		page_down
		cmp.l		#lupgadg,d7
		beq		line_up
		cmp.l		#ldowngadg,d7
		beq		line_down
		cmp.l		#searchgadg,d7
		beq		search
		cmp.l		#printpgadg,d7
		beq		open_about
		cmp.l		#printfgadg,d7
		beq		print_f
		cmp.l		#quitgadg,d7
		beq		QuitReq
		bra		wait_for_msg

QuitReq		move.l		tutor.ptr,a0	a0-->window
		lea		body,a1		a1-->requester text
		lea		left,a2		a2-->requester button text
		lea		right,a3	a3-->requester button text
		moveq.l		#0,d0		left activated by click
		move.l		d0,d1		right activated by click
		move.l		#250,d2		requester width
		move.l		#70,d3		requester height
		CALLINT		AutoRequest	turn it on !
		tst.l		d0		CONT selected ?
		bne		dont_quit	if so continue
		rts				else quit
dont_quit	bra		wait_for_msg

; A key has been pressed, see if it is cursor up or down and if so do
;something useful.


find_key	cmp.w		#$4d,d3
		beq		line_up
		cmp.w		#$4c,d3
		beq		line_down
		bra		wait_for_msg

*****************************************************************************	
; Close the windows
*****************************************************************************	

closewindows	move.l		tutor.ptr,a0	a0-->window
		CALLINT		CloseWindow	close this window
		rts

; Release memory used for table

release_table_mem:

		move.l		line_table,a1
		move.l		table_len,d0
		CALLEXEC	FreeMem
		rts

*****************************************************************************	
; Release memory used to hold text
*****************************************************************************	

release_buffer_mem:
	
		move.l		buffer,a1
		move.l		file_len,d0
		CALLEXEC	FreeMem
		rts

*****************************************************************************	
; Close Graphics library
*****************************************************************************	

gfxclose	move.l		_GfxBase,a1
		CALLEXEC	CloseLibrary
		rts

*****************************************************************************	
; Close DOS library
*****************************************************************************	

dosclose	move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary
		rts

*****************************************************************************	
; Close Intuition library
*****************************************************************************	

intclose	move.l		_IntuitionBase,a1	a1-->library base address
		CALLEXEC	CloseLibrary	close this library
		rts				return to calling program

*****************************************************************************	
; Display the next page of text
*****************************************************************************	
		
page_up		addi.l		#16,current_line
		move.l		current_line,d0
		cmp.l		max_line,d0
		ble.s		do_page_up
		move.l		max_line,d0
		move.l		d0,current_line
do_page_up	bsr		refresh_display
		bra		wait_for_msg
		
*****************************************************************************
; Display the previous page of text
*****************************************************************************

page_down	subi.l		#16,current_line
		bpl.s		do_page_down
		move.l		#0,current_line
do_page_down	move.l		current_line,d0
		bsr		refresh_display
		bra		wait_for_msg

*****************************************************************************
; Scroll raster up and write the next line at the bottom of the screen
*****************************************************************************

line_up		move.l		current_line,d0
		cmp.l		max_line,d0
		beq.s		no_line_up
		addq.l		#1,d0
		move.l		d0,current_line
		move.l		tutor.ptr,a1
		move.l		wd_RPort(a1),a1
		move.l		#0,d0
		move.l		#8,d1
		move.l		#4,d2
		move.l		#10,d3
		move.l		#635,d4
		move.l		#146,d5
		CALLGRAF	ScrollRaster
		move.l		current_line,d0
		mulu.w		#4,d0
		move.l		line_table,a0
		move.l		64(a0,d0),line16
		lea		disp16,a1
		move.l		tutor.ptr,a0
		move.l		50(a0),a0
		moveq.l		#5,d0
		moveq.l		#0,d1
		CALLINT		PrintIText
no_line_up	bra		wait_for_msg

*****************************************************************************
; Scroll raster down and add previous line to top of page
*****************************************************************************

line_down	tst.l		current_line
		beq.s		no_line_down
		subq.l		#1,current_line
		move.l		tutor.ptr,a1
		move.l		wd_RPort(a1),a1
		move.l		#0,d0
		move.l		#-8,d1
		move.l		#4,d2
		move.l		#10,d3
		move.l		#635,d4
		move.l		#145,d5
		CALLGRAF	ScrollRaster
		move.l		current_line,d0
		mulu.w		#4,d0
		move.l		line_table,a0
		move.l		0(a0,d0),line16
		move.w		#10,ypos
		lea		disp16,a1
		move.l		tutor.ptr,a0
		move.l		50(a0),a0
		moveq.l		#5,d0
		moveq.l		#0,d1
		CALLINT		PrintIText
		move.w		#138,ypos
no_line_down	bra		wait_for_msg

*****************************************************************************
;This will be a comprehensive search facility one day
*****************************************************************************

search		move.l		#msg5,msg.ptr
		bra		print_text

*****************************************************************************	
; Display the ABOUT window
*****************************************************************************	
		
open_about	lea		about_win,a0	a0-->window structure
		CALLINT		OpenWindow	open this window
		move.l		d0,about.ptr	save window pointer
		beq.s		no_win
		lea		about_text,a1	a1-->text structure
		move.l		about.ptr,a0	a0-->window
		move.l		50(a0),a0	
		moveq.l		#0,d0		x position of text
		move.l		#0,d1		y position of text
		CALLINT		PrintIText	print the help message
wait_about	btst		#6,ciaapra	wait for left mouse button
		bne.s		wait_about
		move.l		about.ptr,a0	a0-->window
		CALLINT		CloseWindow	close this window
no_win		bra		wait_for_msg


*****************************************************************************
;And this will dump the hole buffer to prt:
*****************************************************************************

print_f		move.l		#msg7,msg.ptr
		bra		print_text

quit		rts

*****************************************************************************
;General message printing subroutine, will not be in end version
*****************************************************************************

print_text	lea		msg_text,a1	a1-->text structure
		move.l		tutor.ptr,a0	a0-->window
		move.l		50(a0),a0	
		moveq.l		#5,d0		x position of text
		move.l		linenum,d1	y position of text
		CALLINT		PrintIText	print the help message
		addi.l		#8,linenum
		bra		wait_for_msg	should be rts

*****************************************************************************
; Clear the screen and display 17 lines of text from the current line
*****************************************************************************

; Set pen to background colour

refresh_display	move.l		tutor.ptr,a1
		move.l		wd_RPort(a1),a1
		moveq.l		#0,d0
		CALLGRAF	SetAPen

; Blit a great big rectangle over the window ( clear the screen )

		move.l		#5,d0
		move.l		#10,d1
		move.l		#635,d2
		move.l		#146,d3
		ext.l		d0
		ext.l		d1
		ext.l		d2
		ext.l		d3
		move.l		tutor.ptr,a1
		move.l		wd_RPort(a1),a1
		CALLGRAF	RectFill

; Initialise all 17 text structures

		move.l		line_table,a0
		move.l		current_line,d0
		mulu.w		#4,d0
		move.l		0(a0,d0),line0
		move.l		4(a0,d0),line1
		move.l		8(a0,d0),line2
		move.l		12(a0,d0),line3
		move.l		16(a0,d0),line4
		move.l		20(a0,d0),line5
		move.l		24(a0,d0),line6
		move.l		28(a0,d0),line7
		move.l		32(a0,d0),line8
		move.l		36(a0,d0),line9
		move.l		40(a0,d0),line10
		move.l		44(a0,d0),line11
		move.l		48(a0,d0),line12
		move.l		52(a0,d0),line13
		move.l		56(a0,d0),line14
		move.l		60(a0,d0),line15
		move.l		64(a0,d0),line16

; And display the text.

		lea		display,a1
		move.l		tutor.ptr,a0
		move.l		50(a0),a0
		moveq.l		#5,d0
		moveq.l		#0,d1
		CALLINT		PrintIText
		rts
*****************************************************************************	
*****************************************************************************	
*****************************************************************************	

*Variables

intname		dc.b		'intuition.library',0
		even
dosname		dc.b		'dos.library',0
		even
grafname	dc.b		'graphics.library',0
		even
_IntuitionBase	dc.l		0
_DOSBase	dc.l		0
_GfxBase	dc.l		0
_ArpBase	dc.l		0
param_ptr	dc.l		0
param_len	dc.l		0
CLI_in		dc.l		0
CLI_out		dc.l		0
file_lock	dc.l		0
file_info	dc.l		0
file_len	dc.l		0
file_handle	dc.l		0
text_len	dc.l		0
buffer		dc.l		0
current_line	dc.l		0
max_line	dc.l		0
line_count	dc.l		0
line_mem_size	dc.l		0
line_mem_aldz	dc.l		0
tutor.ptr	dc.l		8
about.ptr	dc.l		0
linenum		dc.l		12

usage_text	dc.b		$0a,'Program by M.Meany.',$0a,$0a
		dc.b		'Usage   : MyMore <filename>',$0a,$0a
		dc.b		'Version : v1.5',$0a,$0a
usage_end	even
	ifnd	NULL
NULL	equ	0
	endc

tutor_window:
	dc.w	0,0	;window XY origin relative to TopLeft of screen
	dc.w	640,160	;window width and height
	dc.b	0,1	;detail and block pens
	dc.l	CLOSEWINDOW+GADGETUP+RAWKEY	;IDCMP flags
	dc.l	WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH+SMART_REFRESH	;other window flags
	dc.l	GadgetList1	;first gadget in gadget list
	dc.l	NULL	;custom CHECKMARK imagery
	dc.l	NewWindowName1	;window title
	dc.l	NULL	;custom screen pointer
	dc.l	NULL	;custom bitmap
	dc.w	5,5	;minimum width and height
	dc.w	640,200	;maximum width and height
	dc.w	WBENCHSCREEN	;destination screen type
NewWindowName1:
	dc.b	'MyMore v1.5    © M.Meany 1990',0
	even
GadgetList1:
pdowngadg:
	dc.l	lupgadg	;next gadget
	dc.w	82,147	;origin XY of hit box relative to window TopLeft
	dc.w	75,10	;hit box width and height
	dc.w	NULL	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border1	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText1	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	2	;user-definable data
	dc.l	NULL	;pointer to user-definable data
Border1:
	dc.w	-2,-1	;XY origin relative to container TopLeft
	dc.b	0,0,RP_JAM1	;front pen, back pen and drawmode
	dc.b	5	;number of XY vectors
	dc.l	BorderVectors1	;pointer to XY vectors
	dc.l	NULL	;next border in list
BorderVectors1:
	dc.w	0,0
	dc.w	78,0
	dc.w	78,11
	dc.w	0,11
	dc.w	0,0
IText1:
	dc.b	3,0,RP_JAM2,0	;front and back text pens, drawmode and fill byte
	dc.w	1,1	;XY origin relative to container TopLeft
	dc.l	NULL	;font pointer or NULL for default
	dc.l	ITextText1	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText1:
	dc.b	'Page Down',0
	even
lupgadg:
	dc.l	ldowngadg	;next gadget
	dc.w	162,147	;origin XY of hit box relative to window TopLeft
	dc.w	75,10	;hit box width and height
	dc.w	NULL	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border2	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText2	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	3	;user-definable data
	dc.l	NULL	;pointer to user-definable data
Border2:
	dc.w	-2,-1	;XY origin relative to container TopLeft
	dc.b	0,0,RP_JAM1	;front pen, back pen and drawmode
	dc.b	5	;number of XY vectors
	dc.l	BorderVectors2	;pointer to XY vectors
	dc.l	NULL	;next border in list
BorderVectors2:
	dc.w	0,0
	dc.w	78,0
	dc.w	78,11
	dc.w	0,11
	dc.w	0,0
IText2:
	dc.b	3,0,RP_JAM2,0	;front and back text pens, drawmode and fill byte
	dc.w	10,1	;XY origin relative to container TopLeft
	dc.l	NULL	;font pointer or NULL for default
	dc.l	ITextText2	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText2:
	dc.b	'Line Up',0
	even
ldowngadg:
	dc.l	searchgadg	;next gadget
	dc.w	243,147	;origin XY of hit box relative to window TopLeft
	dc.w	75,10	;hit box width and height
	dc.w	NULL	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border3	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText3	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	4	;user-definable data
	dc.l	NULL	;pointer to user-definable data
Border3:
	dc.w	-2,-1	;XY origin relative to container TopLeft
	dc.b	0,0,RP_JAM1	;fron| pen, back pen and dziwmode
	dc.b	5	;number of XY vectoz{
	dc.l	BorderVectors3	;pointer to XY vectors
	dc.l	NULL	;nmxt border in list
BorderVectors3:
	dc.w	0,0
	dc.w	78,0
	dc.w	78,11
	dc.w	0,91
	dc.w	0,0
IText3:
	dc.b	3,0,RP_JAM2,0	;front and back text pens, drawmode and fill byte
	dc.w	2,1	;XY origin relative to contiiner TopLeft
	dc.l	NULL	;font(pointer or NULL for lefiul|
	dc.l	ITextText3	;pointer to text
	dc.l	NULL	;next IntuiText struc|ure
ITextText3:
	dc.b	'Line Down',0
	even
searchgadg:
	dc.l	printpgadg	;next(gadget
	dc.w	324,147	;ozigin XY of hit box relative to window TopLeft
	dc.w	75,10	;hit box width and height
	dc.w	NULL	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border4	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText4	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	5	;user-definable data
	dc.l	NULL	;pointer to user-definable data
Border4:
	dc.w	-2,-1	;XY origin relative to container TopLeft
	dc.b	0,0,RP_JAM1	;front pen, back pen and drawmode
	dc.b	5	;number of XY vectors
	dc.l	BorderVectors4	;pointer to XY vectors
	dc.l	NULL	;next border in list
BorderVectors4:
	dc.w	0,0
	dc.w	78,0
	dc.w	78,11
	dc.w	0,11
	dc.w	0,0
IText4:
	dc.b	3,0,RP_JAM2,0	;front and back text pens, drawmode and fill byte
	dc.w	14,1	;XY origin relative to container TopLeft
	dc.l	NULL	;font pointer or NULL for default
	dc.l	ITextText4	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText4:
	dc.b	'Search',0
	even
printpgadg:
	dc.l	printfgadg	;next gadget
	dc.w	405,147	;origin XY of hit box relative to window TopLeft
	dc.w	75,10	;hit box width and height
	dc.w	NULL	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border5	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText5	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	6	;user-definable data
	dc.l	NULL	;pointer to user-definable data
Border5:
	dc.w	-2,-1	;XY origin relative to container TopLeft
	dc.b	0,0,RP_JAM1	;front pen, back pen and drawmode
	dc.b	5	;number of XY vectors
	dc.l	BorderVectors5	;pointer to XY vectors
	dc.l	NULL	;next border in list
BorderVectors5:
	dc.w	0,0
	dc.w	78,0
	dc.w	78,11
	dc.w	0,11
	dc.w	0,0
IText5:
	dc.b	3,0,RP_JAM1,0	;front and back text pens, drawmode and fill byte
	dc.w	8,1	;XY origin relative to container TopLeft
	dc.l	NULL	;font pointer or NULL for default
	dc.l	ITextText5	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText5:
	dc.b	' About ',0
	even
printfgadg:
	dc.l	quitgadg	;next gadget
	dc.w	486,147	;origin XY of hit box relative to window TopLeft
	dc.w	75,10	;hit box width and height
	dc.w	NULL	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border6	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText6	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	7	;user-definable data
	dc.l	NULL	;pointer to user-definable data
Border6:
	dc.w	-2,-1	;XY origin relative to container TopLeft
	dc.b	0,0,RP_JAM1	;front pen, back pen and drawmode
	dc.b	5	;number of XY vectors
	dc.l	BorderVectors6	;pointer to XY vectors
	dc.l	NULL	;next borler in list
BorderVectors6:
	dc.w	0,0
	dc.w	78,0
	dc.w	78,11
	dc.w	0,11
	dc.w	0,0
IText6:
	dc.b	3,0,RP_JAM2,0	;front and back text pens, drawmode and fill byte
	dc.w	9,1	;XY origin relative to container TopLeft
	dc.l	NULL	;font pointer or NULL for default
	dc.l	ITextText6	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText6:
	dc.b	'Print F',0
	even
quitgadg:
	dc.l	pupgadg	;next gadget
	dc.w	567,147	;origin XY of hit box relative to window TopLeft
	dc.w	66,10	;hit box width and height
	dc.w	NULL	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border7	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText7	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo stz}cture
	dc.w	8	;user-definable data
	dc.l	NULL	;pointer to user-dmfinable data
Border7:
	dc.w	-2,-1	;XY origin relative to containmr TopLent
	dc.b	8,0,RP_JAM1	;front(pen, back pen and drawmode
	dc.b	5	;number of XY vectors
	dc.l	BorderVectors7	;pointer to XY vectors
	dc.l	NULL	;next border in list
BorderVectors7:
	dc.w	0,0
	dc.w	69,0
	dc.w	69,11
	dc.w	0,11
	dc.w	0,0
IText7:
	dc.b	3,0,RP_JAM2,0	;front and back text pens, drawmode and fill byte
	dc.w	17,1	;XY origin relative to container TopLeft
	dc.l	NULL	;font pointer or NULL for default
	dc.l	ITextText7	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText7:
	dc.b	'Quit',0
	even
pupgadg:
	dc.l	NULL	;next gadget
	dc.w	10,147	;origin XY of hit box relative to window TopLeft
	dc.w	60,10	;hit box width and height
	dc.w	NULL	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border8	;gadget border or image to be rendered
	dc.l	NULL	;alternate imagery for selection
	dc.l	IText8	;first IntuiText structure
	dc.l	NULL	;gadget mutual-exclude long word
	dc.l	NULL	;SpecialInfo structure
	dc.w	1	;user-definable data
	dc.l	NULL	;pointer to user-definable data
Border8:
	dc.w	-2,-1	;XY origin relative to container TopLeft
	dc.b	0,0,RP_JAM1	;front pen, back pen and drawmode
	dc.b	5	;number of XY vectors
	dc.l	BorderVectors8	;pointer to XY vectors
	dc.l	NULL	;next border in list
BorderVectors8:
	dc.w	0,0
	dc.w	63,0
	dc.w	63,11
	dc.w	0,11
	dc.w	0,0
IText8:
	dc.b	3,0,RP_JAM2,0	;front and back text pens, drawmode and fill byte
	dc.w	3,1	;XY origin relative to container TopLeft
	dc.l	NULL	;font pointer or NULL for default
	dc.l	ITextText8	;pointer to text
	dc.l	NULL	;next IntuiText structure
ITextText8:
	dc.b	'Page Up',0
	even

*****************************************************************************
; Data for QUIT requester

body	dc.b	2,2	colours to use
	dc.b	0	mode to use (normal)
	even
	dc.w	50,10	text position in window
	dc.l	0	font to use (standard)
	dc.l	b_text	pointer to text
	dc.l	body1	end of text list
	
b_text	dc.b	'QUIT, are you sure ?',0  message
	even
body1	dc.b	2,2	colours to use
	dc.b	0	mode to use (normal)
	even
	dc.w	57,20	text position in window
	dc.l	0	font to use (standard)
	dc.l	b_text1	pointer to text
	dc.l	0	end of text list
	
b_text1	dc.b	'M.Meany  1990 ',0  message
	even


left	dc.b	2,2	colours to use
	dc.b	0	mode to use (normal)
	even
	dc.w	5,3	text position in window
	dc.l	0	font to use (standard)
	dc.l	l_text	pointer to text
	dc.l	0	end of text list
	
l_text	dc.b	'CONT',0  message
	even


right	dc.b	2,2	colours to use
	dc.b	0	mode to use (normal)
	even
	dc.w	5,3	text position in window
	dc.l	0	font to use (standard)
	dc.l	r_text	pointer to text
	dc.l	0	end of text list
	
r_text	dc.b	'QUIT',0  message
	even

*****************************************************************************

msg_text	dc.b	2,2	colours to use
		dc.b	0	mode to use (normal)
		even
		dc.w	0,8	text position in window
		dc.l	0	font to use (standard)
msg.ptr		dc.l	msg8	pointer to text
		dc.l	0	end of text list
		
msg5		dc.b	'Search gadget toggled.',0
	even
msg6		dc.b	'Print Page gadget toggled.',0
	even
msg7		dc.b	'Print File gadget toggled.',0
	even
msg8		dc.b	'Quit gadget toggled.',0
	even

display		dc.b	1,0
		dc.b	RP_JAM2,0
		dc.w	0,10
		dc.l	0
line0		dc.l	0
		dc.l	disp1

disp1		dc.b	1,0
		dc.b	RP_JAM2,0
		dc.w	0,18
		dc.l	0
line1		dc.l	0
		dc.l	disp2

disp2		dc.b	1,0
		dc.b	RP_JAM2,0
		dc.w	0,26
		dc.l	0
line2		dc.l	0
		dc.l	disp3

disp3		dc.b	1,0
		dc.b	RP_JAM2,0
		dc.w	0,34
		dc.l	0
line3		dc.l	0
		dc.l	disp4

disp4		dc.b	1,0
		dc.b	RP_JAM2,0
		dc.w	0,42
		dc.l	0
line4		dc.l	0
		dc.l	disp5

disp5		dc.b	1,0
		dc.b	RP_JAM2,0
		dc.w	0,50
		dc.l	0
line5		dc.l	0
		dc.l	disp6

disp6		dc.b	1,0
		dc.b	RP_JAM2,0
		dc.w	0,58
		dc.l	0
line6		dc.l	0
		dc.l	disp7

disp7		dc.b	1,0
		dc.b	RP_JAM2,0
		dc.w	0,66
		dc.l	0
line7		dc.l	0
		dc.l	disp8

disp8		dc.b	1,0
		dc.b	RP_JAM2,0
		dc.w	0,74
		dc.l	0
line8		dc.l	0
		dc.l	disp9

disp9		dc.b	1,0
		dc.b	RP_JAM2,0
		dc.w	0,82
		dc.l	0
line9		dc.l	0
		dc.l	disp10

disp10		dc.b	1,0
		dc.b	RP_JAM2,0
		dc.w	0,90
		dc.l	0
line10		dc.l	0
		dc.l	disp11

disp11		dc.b	1,0
		dc.b	RP_JAM2,0
		dc.w	0,98
		dc.l	0
line11		dc.l	0
		dc.l	disp12

disp12		dc.b	1,0
		dc.b	RP_JAM2,0
		dc.w	0,106
		dc.l	0
line12		dc.l	0
		dc.l	disp13

disp13		dc.b	1,0
		dc.b	RP_JAM2,0
		dc.w	0,114
		dc.l	0
line13		dc.l	0
		dc.l	disp14

disp14		dc.b	1,0
		dc.b	RP_JAM2,0
		dc.w	0,122
		dc.l	0
line14		dc.l	0
		dc.l	disp15

disp15		dc.b	1,0
		dc.b	RP_JAM2,0
		dc.w	0,130
		dc.l	0
line15		dc.l	0
		dc.l	disp16

disp16		dc.b	1,0
		dc.b	RP_JAM2,0
		dc.w	0
ypos		dc.w	138
		dc.l	0
line16		dc.l	0
		dc.l	0

	even
table_len	dc.l	0
line_table	dc.l	0

	
	
;***********************************************************
;	FileRequester Structures
;***********************************************************


;------	hail text is what will appear in requesters window title	

Requesterflags	EQU	NULL

LoadFileStruct:
	dc.l		LoadText	;pointer to hail text
	dc.l		LoadFileData	;pointer to filename buffer
	dc.l		LoadDirData	;pointer to path buffer
	dc.l		NULL		;window to attach to - none if on WB
	dc.b		Requesterflags	;flags - none
	dc.b		0		;reserved
	dc.l		0		;fr_Function
	dc.l		0		;reserved2

;------	this is not part of the Filerequest structure but is our
;	extension and can be accessed using the fr_SIZEOF offset
	dc.l		LoadPathName

LoadText:
	dc.b	'MyMore © M.Meany 1990 ',0
	even
	
*****************************************************************************
; About window data definition
*****************************************************************************

about_win	dc.w		184,12		window XY origin relative to TopLeft of screen
		dc.w		262,122		window width and height
		dc.b		0,1		detail and block pens
		dc.l		0		IDCMP flags
		dc.l		WINDOWDRAG+ACTIVATE	other window flags
		dc.l		0		first gadget in gadget list
		dc.l		0		custom CHECKMARK imagery
		dc.l		AboutName	window title
		dc.l		0		custom screen pointer
		dc.l		0		custom bitmap
		dc.w		5,5		minimum width and height
		dc.w		640,200		maximum width and height
		dc.w		WBENCHSCREEN	destination screen type

AboutName	dc.b		'About MyMore',0
		even


about_text	dc.b		2,0,RP_JAM2,0	front and back text pens, drawmode and fill byte
		dc.w		13,20		XY origin relative to container TopLeft
		dc.l		0		font pointer or 0 for default
		dc.l		AboutText1	pointer to text
		dc.l		About2		next IntuiText structure

AboutText1	dc.b		'As well as the gadgets, the',0
		even

About2		dc.b		2,0,RP_JAM2,0	front and back text pens, drawmode and fill byte
		dc.w		13,31		XY origin relative to container TopLeft
		dc.l		0		font pointer or 0 for default
		dc.l		AboutText2	pointer to text
		dc.l		About3		next IntuiText structure

AboutText2	dc.b		'cursor up and down keys may',0
		even

About3		dc.b		2,0,RP_JAM2,0	front and back text pens, drawmode and fill byte
		dc.w		15,42		XY origin relative to container TopLeft
		dc.l		0		font pointer or 0 for default
		dc.l		AboutText3	pointer to text
		dc.l		About4		next IntuiText structure

AboutText3	dc.b		'be used to scroll through',0
		even

About4		dc.b		2,0,RP_JAM2,0	front and back text pens, drawmode and fill byte
		dc.w		14,53		XY origin relative to container TopLeft
		dc.l		0		font pointer or 0 for default
		dc.l		AboutText4	pointer to text
		dc.l		About5		next IntuiText structure

AboutText4	dc.b		'the listing.',0
		even

About5		dc.b		1,0,RP_JAM2,0	front and back text pens, drawmode and fill byte
		dc.w		80,64		XY origin relative to container TopLeft
		dc.l		0		font pointer or 0 for default
		dc.l		AboutText5	pointer to text
		dc.l		About6		next IntuiText structure

AboutText5	dc.b		'Mark Meany,',0
		even

About6		dc.b		1,0,RP_JAM2,0	front and back text pens, drawmode and fill byte
		dc.w		80,74		XY origin relative to container TopLeft
		dc.l		0		font pointer or 0 for default
		dc.l		AboutText6	pointer to text
		dc.l		About7		next IntuiText structure

AboutText6	dc.b		'1 Cromwell Road,',0
		even

About7		dc.b		1,0,RP_JAM2,0	front and back text pens, drawmode and fill byte
		dc.w		80,84		XY origin relative to container TopLeft
		dc.l		0		font pointer or 0 for default
		dc.l		AboutText7	pointer to text
		dc.l		About8		next IntuiText structure

AboutText7	dc.b		'Southampton,',0
		even

About8		dc.b		1,0,RP_JAM2,0	front and back text pens, drawmode and fill byte
		dc.w		80,94		XY origin relative to container TopLeft
		dc.l		0		font pointer or 0 for default
		dc.l		AboutText8	pointer to text
		dc.l		About9		next IntuiText structure

AboutText8	dc.b		'Hants.,',0
		even

About9		dc.b		1,0,RP_JAM2,0	front and back text pens, drawmode and fill byte
		dc.w		80,104		XY origin relative to container TopLeft
		dc.l		0		font pointer or 0 for default
		dc.l		AboutText9	pointer to text
		dc.l		0		next IntuiText structure

AboutText9	dc.b		'SO1 2JH',0
		even


;***********************************************************
	SECTION	FileRequest,BSS
;***********************************************************

LoadFileData:
		ds.b	FCHARS+1	;reserve space for filename buffer
		EVEN
	
LoadDirData:
		ds.b	DSIZE+1		;reserve space for path buffer
		EVEN
	
LoadPathName	ds.b	DSIZE+FCHARS+2	;reserve space for full pathname name buffer
		EVEN

