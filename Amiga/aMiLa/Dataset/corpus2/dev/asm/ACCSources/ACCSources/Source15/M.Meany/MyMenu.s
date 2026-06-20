
; A very simple menu example showing how to implement the hardware file
;viewer code of mine.

; The menu discriptor is at the end of the listing for easier access!

; © M.Meany, Aug 91.

		incdir		sys:include/
		include		exec/exec_lib.i
		include		exec/memory.i
		incdir		source:include/
		include		hardware.i
		include		powerpacker_lib.i
		include		ppbase.i

SSS		equ		40*80+79
SCROLL		equ		4

CALLNICO	macro
		move.l		_PPBase(a4),a6
		jsr		_LVO\1(a6)
		endm

Start		bsr		Init		alloc mem for vars
		tst.l		d0		error?
		beq		.quit_fast	if so quit

		bsr		PlayTune

.no_tune	bsr		SysOff		disable system, set a5
		tst.l		d0		error?
		beq		.quit		if so leave

		bsr		Main		do da

		bsr		SysOn		enable system

.quit		bsr		StopTune

		bsr		DeInit		free mem

.quit_fast	rts

*****************************************************************************
*****************************************************************************

Main		
		move.w		#$01e0,DMACON(a5) kill all dma
		move.w		#$83Cf,DMACON(a5) cop,dsk,bpl,blit,aud

.next		bsr		Menu
		tst.l		d0		QUIT selected
		beq.s		.quit

		cmpi.l		#$1,(a0)	submenu selected
		beq.s		.next

		jsr		(a0)		some other function

		bra		.next

.quit		rts

*****************************************************************************

; Display the menu screen

Menu		bsr		BuildMenu

		move.l		#MenuCopList,COP1LCH(a5)
		clr.w		COPJMP1(a5)

UnFold		lea		foldtop+2,a0	a0->last modulo value
		move.l		#208,d1		line counter
		moveq.w		#0,d0		new modulo
		moveq.l		#1,d2		flip flop

;-------------- Unmelt the screen

.Wait		cmpi.b		#$f0,$dff006	VBL
		bne.s		.Wait

		neg.w		d2
		bmi.s		.Wait

		move.w		d0,(a0)
		lea		12(a0),a0	next line
		dbra		d1,.Wait

; Routine to interpret a function keypress. Returns a pointer to a file name
;in register d0 if F1->F9 pressed, 0 if F1O pressed ( QUIT ).

.GetFile	move.l		ThisMenu(a4),a3	a3->current menu discriptor
		bsr		GetFunct	get users selection

		move.l		d0,-(sp)	push returned parameters
		move.l		a0,-(sp)

; Melt the screen

Fold		lea		foldbot+2,a0	a0->last modulo value
		move.l		#208,d1		line counter
		move.w		#-80,d3		new modulo
		moveq.l		#1,d2		flip flop

;-------------- Destroy the screen

.Wait		cmpi.b		#$f0,$dff006	VBL
		bne.s		.Wait

		neg.w		d2
		bmi.s		.Wait

		move.w		d3,(a0)
		lea		-12(a0),a0	next line
		dbra		d1,.Wait

		move.l		(sp)+,a0
		move.l		(sp)+,d0

;Check if QUIT selected

		cmp.l		#$ffffffff,(a0)	quit ?
		bne.s		.check_men	if not skip the next bit
		moveq.l		#0,d0		set error
		bra		.done		and quit
		

.check_men	cmpi.l		#$1,(a0)	new menu ?
		bne.s		.do_other	nope, so ignore next bit
		move.l		4(a0),ThisMenu(a4) set pointer to menu
		bra		.done

.do_other	move.l		a0,LoadPathName(a4) save data addr
		addq.l		#4,LoadPathName(a4) skip discriptor
		move.l		(a0),a0		

		moveq.l		#1,d0		don't quit
.done		rts

*************************************************************************

;The bar can be in one of twenty positions. Whenever this subroutine
;is called, the bar is moved back to the top position of the screen.
;The left button is used to move up a line, right to go down. To select
;an option, press both buttons.

;Exit		d0=selection number ( 0 to 19 )
;		a0->selection header ( 1 word discriptor )

GetFunct	moveq.l		#0,d6		d6=bar position
		lea		BarStart+6,a6	a6->Copper list position
		move.l		#$0fac,d5	PINK
		move.l		#$0fb0,d4	WHITE
.loop		move.w		d5,(a6)
		move.w		d5,12(a6)
		move.w		d5,24(a6)
		move.w		d5,36(a6)	highlight selection
		move.w		d5,48(a6)
		move.w		d5,60(a6)
		move.w		d5,72(a6)
		move.w		d5,84(a6)


.PoleMouse	moveq.l		#60,d1

.VBL		move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$1000,d0	is this line 16?
		bne.s		.VBL		if not loop back

		dbra		d1,.VBL

		btst		#6,CIAAPRA	lefty ?
		beq.s		.got_selection	if pressed, check right

		btst		#2,$dff016	righty ?
		bne.s		.PoleMouse	if not loop back

		bsr		SelectUp	move bar down 1 line
		bra		.loop	loop back

.got_selection	btst		#2,$dff016	righty ?
		beq		.done		if so then quit
		bsr		SelectDown	else move bar up 1 line
		bra		.loop

; program should shut down here....

.done		move.l		8(a3),a0	a0->discriptor word
		move.l		d6,d0		d0=offset to desired funct
		asl.l		#2,d0		x4 for actual offset
		move.l		0(a0,d0),a0	a0->action line
		tst.l		(a0)		header = 0 ?
		beq		.PoleMouse	if so loop back

		move.w		d4,(a6)
		move.w		d4,12(a6)
		move.w		d4,24(a6)
		move.w		d4,36(a6)	Remove highlight
		move.w		d4,48(a6)
		move.w		d4,60(a6)
		move.w		d4,72(a6)
		move.w		d4,84(a6)

		move.l		d6,d0		selection into d0
		rts				return

*************************************************************************

SelectUp	tst.l		d6		at top ?
		beq.s		.done

		subq.l		#1,d6
		move.w		d4,(a6)
		move.w		d4,12(a6)
		move.w		d4,24(a6)
		move.w		d4,36(a6)	Remove highlight
		move.w		d4,48(a6)
		move.w		d4,60(a6)
		move.w		d4,72(a6)
		move.w		d4,84(a6)

		lea		-96(a6),a6	move bar up 1 line
.done		rts				and return

*************************************************************************

SelectDown	cmp.l		#18,d6		at bottom ?
		beq.s		.done

		addq.l		#1,d6
		move.w		d4,(a6)
		move.w		d4,12(a6)
		move.w		d4,24(a6)
		move.w		d4,36(a6)	Remove highlight
		move.w		d4,48(a6)
		move.w		d4,60(a6)
		move.w		d4,72(a6)
		move.w		d4,84(a6)

		lea		96(a6),a6	move bar down 1 line
.done		rts				and return

*************************************************************************

;--------------	Fill the screen

; Entry		d0=number of line at top of display

BuildMenu	lea		menuscrn,a0	a0->crunched data
		move.l		MenuPlane(a4),a1 a1->decrunch memory block
		bsr		DeCrunch	decrunch it

		move.l		ThisMenu(a4),a6	get menu pointer

		move.l		0(a6),a0	get pointer to title
		bsr		Centralise	centre title
		moveq.l		#0,d0		put it at the top
		move.l		MenuPlane(a4),a1 a1->bitplane for text
		bsr		PrintLine	and display title

		move.l		4(a6),a6	a6->choice table
		moveq.l		#18,d6		num of selections per menu

.loop		move.l		(a6)+,a0	a1->text for this line
		bsr		Centralise	and centre it

		moveq.l		#19,d0		d0=lines on screen
		sub.l		d6,d0		this lines position
		move.l		MenuPlane(a4),a1	a1->bitplane for text
		bsr		PrintLine	and display it

		dbra		d6,.loop	for all lines

.error		rts

*****************************************************************************

;--------------	Centralise a heading in an 80 byte display

; Entry		a0->text

; Corrupt	d0,d1,a0,a1,a2 

Centralise	lea		Line(a4),a1	a1->text buffer
		move.l		a1,a2		get a working copy
		moveq.l		#80,d0		counter
		moveq.l		#' ',d1		fill byte
.blank		move.b		d1,(a2)+	fill the buffer
		dbra		d0,.blank	with 81 spaces

		tst.b		(a0)		check for text
		beq.s		.error		quit if none

		move.l		a0,a2		make a copy
		moveq.l		#-1,d0		init counter
.loop		addq.l		#1,d0		bump counter
		tst.b		(a2)+		end of text yet?
		bne.s		.loop		if not keep checking


		asr.l		#1,d0		div length by 2
		moveq.l		#40,d1		centre of screen
		sub.l		d0,d1		d1=left offset
		add.l		d1,a1		add to buffer pointer

.loop2		move.b		(a0)+,(a1)+	copy next byte
		bne.s		.loop2		until done

		move.b		#' ',-1(a1)	correct last character
.error		rts				and return


*****************************************************************************

; Display the selected file.

View		bsr		Load

		move.l		#CopList,COP1LCH(a5)
		clr.w		COPJMP1(a5)

.Why_are_we	move.l		top_line(a4),d0 get top line into d0
.Waiting	bsr		ReDisplay	display a page of text


; wait for beam to reach line 16

.VBL		move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$1000,d0	is this line 16?
		bne.s		.VBL		if not loop back

;--------------	Cycle colour bars at top of display

		lea		Cycle,a0
		lea		2(a0),a0
		move.w		(a0),d1		save 1st scroll val
		move.l		#47,d2		loop counter
.loop		move.l		a0,a1
		lea		8(a0),a0
		move.w		(a0),(a1)
		dbra		d2,.loop
		lea		constop,a0
		move.w		d1,2(a0)


.PoleMouse	btst		#6,CIAAPRA	lefty ?
		beq.s		.check_quit	if pressed, check right

		btst		#2,$dff016	righty ?
		bne.s		.Why_are_we	if not loop back

		bsr		GoingDown	move text down 1 line
		bra		.Waiting		loop back

.check_quit	btst		#2,$dff016	righty ?
		beq		.done		if so then quit
		bsr		GoingUp		else move text up 1 line
		bra		.Waiting

; program should shut down here....

.done		rts

*****************************************************************************
*****************************************************************************
**************************** Subroutines ************************************
*****************************************************************************
*****************************************************************************

;--------------	Move text up 1 line

GoingUp		move.l		top_line(a4),d0	d0=line num at top of display
		beq.s		.done
		subq.l		#1,d0
		move.l		d0,top_line(a4)
.done		rts
*****************************************************************************

;--------------	Move text down 1 line

GoingDown	move.l		top_line(a4),d0
		cmp.l		max_top_line(a4),d0	bottom of file ?
		bge.s		.done
		addq.l		#1,d0
		move.l		d0,top_line(a4)
.done		rts

*****************************************************************************

;-------------- Disable the operating system.

; On exit d0=0 if no gfx library.

SysOff		lea		$DFF000,a5	a5->hardware

		move.w		DMACONR(a5),sysDMA(a4)	save DMA settings

		lea		gfxname,a1	a1->lib name
		moveq.l		#0,d0		any version
		move.l		$4.w,a6		a6->SysBase
		jsr		-$0228(a6)	OpenLibrary
		tst.l		d0		open ok?
		beq		.error		quit if not
		move.l		d0,a0		a0->GfxBase
		move.l		38(a0),syscop(a4) save addr of sys list
		move.l		d0,a1		a1->GfxBase
		jsr		-$019E(a6)	CloseLibrary		

		jsr		-$0084(a6)	Forbid

		moveq.l		#1,d0
.error		rts

*****************************************************************************

;--------------	Bring back the operating system

SysOn		move.l		syscop(a4),COP1LCH(a5)
		clr.w		COPJMP1		restart system list

		move.w		#$8000,d0	set bit 15 of d0
		or.w		sysDMA(a4),d0	add DMA flags
		move.w		d0,DMACON(a5)	enable systems DMA

		move.l		$4.w,a6		a6->SysBase
		jsr		-$008A(a6)	Permit

		rts

*****************************************************************************

;--------------	Get memory for all variables

Init		move.l		#VarsSize,d0			size of block
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1	type
		CALLEXEC	AllocMem			get mem
		tst.l		d0
		beq		.error
		move.l		d0,a4				a4->base

		move.l		#Menu1,ThisMenu(a4)	set first menu

; Allocate memory for typer bitplane

		move.l		#(640/8)*256,d0	size of bitplane
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1	into CHIP
		CALLEXEC	AllocMem	get memory
		move.l		d0,Plane(a4)	save it's address
		beq		.error

; Decrunch logo into this

		lea		logo,a0		a0->crunched data
		move.l		d0,a1		a1->decrunch mem block
		bsr		DeCrunch	and decrunch it

; Allocate mem for the menu screen data

		lea		menuscrn,a3
		move.l		(a3),d0		size of decrunched data
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1	into CHIP
		CALLEXEC	AllocMem	get memory
		move.l		d0,MenuPlane(a4)	save it's address
		move.l		d0,scrnpos
		beq		.error1

; Write address of planes into Menu Copper list

		lea		MenuPlanes,a0	a0->bpl ptr's
		move.w		d0,4(a0)	store high part
		swap		d0
		move.w		d0,(a0)		store low part

; Set a few variables and place bpl pointers into copper list

		move.l		#21,lines_on_scrn(a4)
		bsr		PutPlanes		build copperlist

		move.l		MenuPlane(a4),a0
		lea		40*80(a0),a0
		move.l		a0,scrnpos
; Open the PowerPacker library	

		lea		niconame,a1	libname
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	open it
		move.l		d0,_PPBase(a4)	save base ptr
		bne.s		.ok		ret if no errors

		move.l		MenuPlane(a4),a1	a1->Bitplane mem
		move.l		menuscrn,d0	d0=size
		CALLEXEC	FreeMem		release it

.error1		move.l		Plane(a4),a1	a1->Bitplane mem
		move.l		#(640/8)*256,d0	d0=size
		CALLEXEC	FreeMem		release it

.error		move.l		a4,a1		a1->vars mem
		move.l		#VarsSize,d0	d0=size
		CALLEXEC	FreeMem		release it
		moveq.l		#0,d0		signal error

.ok		rts						fin

*****************************************************************************

;--------------	Free memory for variables

DeInit		tst.l		line_list(a4)	is there a file in mem?
		beq.s		.check_buf	if not skip next bit
		move.l		line_list(a4),a1 a1->mem
		move.l		list_len(a4),d0	 d0=-size of block
		CALLEXEC	FreeMem		and release it

.check_buf	tst.l		buffer(a4)	is there a file in mem?
		beq.s		.lib		if not skip next bit
		move.l		buffer(a4),a1	a1->mem
		move.l		buf_len(a4),d0	d0=-size of block
		CALLEXEC	FreeMem		and release it

.lib		move.l		_PPBase(a4),a1	lib base
		CALLEXEC	CloseLibrary	and close it

		move.l		MenuPlane(a4),a1	a1->Bitplane mem
		move.l		menuscrn,d0	d0=size
		CALLEXEC	FreeMem		release it

.error1		move.l		Plane(a4),a1	a1->Bitplane mem
		move.l		#(640/8)*256,d0	d0=size
		CALLEXEC	FreeMem		release it

		move.l		a4,a1		a1->base
		move.l		#VarsSize,d0	size
		CALLEXEC	FreeMem		and free it

		rts

*****************************************************************************

;--------------	Put address of bitplane into Copper List

PutPlanes	lea		CopPlanes,a0	a0->bpl ptr's
		move.l		Plane(a4),d0	d0=addr of plane data
		move.w		d0,4(a0)	store high part
		swap		d0
		move.w		d0,(a0)		store low part
		rts

*****************************************************************************

; ByteRun decrunch algorithm. For ArtWerk by M.Meany, July 1991.

; The 1st long word of a crunched data block is the length of the block
;when decrunched. It is up to you to allocate memory for the decrunched
;data. This is not a problem if you have crunched a series of graphics
;that all fit into the same size display as only one block need be obtained.

; Entry		a0->Crunched Data
;		a1->Memory to decrunch into

DeCrunch	lea		4(a0),a0	a0->data

.outer		tst.w		(a0)		end of crunched data ?
		beq		.done		if so quit

		move.b		(a0)+,d0	get value

; Remove the semi-colon from the following line for pp efx.

		move.w		d0,$dff180	change color0 

		moveq.l		#0,d1		clear 
		move.b		(a0)+,d1	get count
		subq.l		#1,d1		adjust for dbra

.inner		move.b		d0,(a1)+	copy next byte
		dbra		d1,.inner	count times

		bra		.outer		go back for more

.done		rts				all decrunched

*****************************************************************************

;--------------	Expand a line of text to 80 Chars

; Given the address of a $0a terminated line of text, this subroutine will
;produce a printable line ( TAB's expanded ) in a line buffer. The line is
;also expanded to 80 chars as required by the print routine.

; Entry		a1 must hold address of start of text string

; Exit		text is expanded into an 81 byte buffer at label Line

; All registers preserved.

expand_text	movem.l		d0-d7/a0-a1,-(sp) save registers
		lea		Line(a4),a0	addr of line buffer into a0
		moveq.l		#$09,d2		d2=TAB
		moveq.l		#$0a,d3		d3=CR
		moveq.l		#' ',d4		d4=space
		moveq.l		#1,d5		constant
		moveq.l		#0,d6		d6=line length
		moveq.l		#3,d7		constant
.next_char	move.b		(a1)+,d0	d0=next char
		cmp.b		d3,d0		new line ?
		beq.s		.line_done	if so finish up
		cmp.b		d2,d0		TAB ?
		beq.s		.do_tab		if so deal with it
		move.b		d0,0(a0,d6)	position character
		add.w		d5,d6		bump counter
		cmp.l		#80,d6		EOL ?
		bne.s		.next_char	go back for next char
		
.line_done	move.b		#' ',0(a0,d6)	add a terminate line
		add.w		d5,d6		bump counter
		cmp.w		#81,d6		EOL ?
		bne.s		.line_done	if not add another space
		movem.l		(sp)+,d0-d7/a0-a1 restore registers
		rts
		
.do_tab		move.l		d6,d1		copy chars so far
		asr.w		d7,d1		calculate num of spaces
		add.w		d5,d1
		asl.w		d7,d1
		sub.w		d6,d1
		sub.w		d5,d1		adjust for dbra
.next_spc	move.b		d4,0(a0,d6)	add a space
		add.w		d5,d6		bump line length
		cmp.w		#80,d6		EOL ?
		beq		.line_done	if so break
		dbra		d1,.next_spc	until tab position reached
		bra.s		.next_char

*************************************************************************

;--------------	Fill the screen

; Entry		d0=number of line at top of display

ReDisplay	tst.l		line_list(a4)	make sure there is text
		beq.s		.error		leave if not

		moveq.l		#20,d6		d6=lines on screen
		cmp.l		num_lines(a4),d6 make sure enough lines
		ble.s		.ok		if so skip next bit
		move.l		num_lines(a4),d6 set=size of file
		subq.l		#1,d6		adjust for dbra

.ok		asl.l		#2,d0		x4, 4 bytes per entry
		move.l		line_list(a4),a6 get addr of list
		add.l		d0,a6		a6->required entry

.loop		move.l		(a6)+,a1	a1->text for this line
		bsr		expand_text	and expand it

		moveq.l		#20,d0		d0=lines on screen
		sub.l		d6,d0		this lines position
		move.l		Plane(a4),a1	a1->bitplane for text
		bsr		PrintLine	and display it

		dbra		d6,.loop	for all lines

.error		rts


*************************************************************************

;--------------	Print a line of text to the screen

*									*
*Entry		d0=line number (0 to 20)				*
*									*
*Corrupt	d0,d1,d2 a0,a1,a2					*
*									*
*									*
* M.Meany, July 91							*
*									*

; Leaves 50 lines at top of bitplane for a logo if required.

PrintLine	cmpi.b		#20,d0		is text on screen ?
		bgt		.done		if not quit

		lea		Line(a4),a0	a0->expanded line of text
		asl.l		#3,d0		line num x 8
		add.l		#50,d0		y-start position
		mulu.w		#80,d0		address of 1st byte in line
		lea		0(a1,d0),a1	a1->bpl start position
		moveq.l		#79,d1		character counter for loop

.loop		moveq.l		#0,d2		clear register
		move.b		(a0)+,d2	get next char
		sub.l		#' ',d2		adjust ASCII to actual
		asl.l		#3,d2		x8 to get offset to data

		lea		CHARS,a2	a2->character set data
		lea		0(a2,d2),a2	a2->data for this char

		move.b		(a2)+,(a1)	1st line of char
		move.b		(a2)+,80(a1)	2nd line of char
		move.b		(a2)+,160(a1)	3rd line of char
		move.b		(a2)+,240(a1)	4th line of char
		move.b		(a2)+,320(a1)	5th line of char
		move.b		(a2)+,400(a1)	6th line of char
		move.b		(a2)+,480(a1)	7th line of char
		move.b		(a2)+,560(a1)	last line of char
		lea		1(a1),a1	bump to next screen pos

		dbra		d1,.loop	for whole line

.done		rts				all done so return


*************************************************************************

;--------------	Load a text file

; This subroutine checks if a file is already in memory. If so all memory
;allocated to it is freed before a new file is loaded.

; Entry		LoadPathName must contain the address of the filename.

; Check if a file is already loaded

Load		tst.l		buffer(a4)
		beq.s		.ok

; If so free the memory it occupies ( ie scrap it )
		
		move.l		buffer(a4),a1
		move.l		buf_len(a4),d0
		CALLEXEC	FreeMem
			
		move.l		#0,buffer(a4)

		move.l		line_list(a4),a1
		move.l		list_len(a4),d0
		CALLEXEC	FreeMem

		move.l		#0,line_list(a4)

; Use powerpacker.library to load/decrunch the file

.ok		move.l		LoadPathName(a4),a0
		moveq.l		#DECR_POINTER,d0
		moveq.l		#0,d1
		lea		buffer(a4),a1
		lea		buf_len(a4),a2
		move.l		d1,a3
		CALLNICO	ppLoadData
		tst.l		d0
		bne.s		load_error

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
		move.l		d0,list_len(a4) save table length
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1	type
		CALLEXEC	AllocMem	get mem for line table
		movem.l		(sp)+,d1-d3/a0	reset registers to init vals
		move.l		d0,line_list(a4)	save pointer
		beq.s		load_error		leave if error

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
		bra		.ok1
.error		moveq.l		#1,d1
.ok1		move.l		d1,max_top_line(a4)

load_error	moveq.l		#0,d0
		rts



*****************************************************************************
*****************************************************************************
***************************** Data ******************************************
*****************************************************************************
*****************************************************************************


gfxname		dc.b		'graphics.library',0
		even
_GfxBase	dc.l		0

niconame	PPNAME
		even

; Character set


CHARS:    DC.B	$00,$00,$00,$00,$00,$00,$00,$00 ;  
	 DC.B	$18,$3C,$3C,$18,$18,$00,$18,$00 ;! 
	 DC.B	$6C,$6C,$00,$00,$00,$00,$00,$00 ;" 
	 DC.B	$6C,$6C,$FE,$6C,$FE,$6C,$6C,$00 ;# 
	 DC.B	$18,$3E,$60,$3C,$06,$7C,$18,$00 ;$ 
	 DC.B	$00,$C6,$CC,$18,$30,$66,$C6,$00 ;% 
	 DC.B	$38,$6C,$68,$76,$DC,$CC,$76,$00 ;& 
	 DC.B	$18,$18,$30,$00,$00,$00,$00,$00 ;' 
	 DC.B	$0C,$18,$30,$30,$30,$18,$0C,$00 ;( 
	 DC.B	$30,$18,$0C,$0C,$0C,$18,$30,$00 ;) 
	 DC.B	$00,$66,$3C,$FF,$3C,$66,$00,$00 ;* 
	 DC.B	$00,$18,$18,$7E,$18,$18,$00,$00 ;+ 
	 DC.B	$00,$00,$00,$00,$00,$18,$18,$30 ;, 
	 DC.B	$00,$00,$00,$7E,$00,$00,$00,$00 ;- 
	 DC.B	$00,$00,$00,$00,$00,$18,$18,$00 ;. 
	 DC.B	$03,$06,$0C,$18,$30,$60,$C0,$00 ;/ 
	 DC.B	$3C,$66,$6E,$7E,$76,$66,$3C,$00 ;0 
	 DC.B	$18,$38,$18,$18,$18,$18,$7E,$00 ;1 
	 DC.B	$3C,$66,$06,$1C,$30,$66,$7E,$00 ;2 
	 DC.B	$3C,$66,$06,$1C,$06,$66,$3C,$00 ;3 
	 DC.B	$1C,$3C,$6C,$CC,$FE,$0C,$1E,$00 ;4 
	 DC.B	$7E,$60,$7C,$06,$06,$66,$3C,$00 ;5 
	 DC.B	$1C,$30,$60,$7C,$66,$66,$3C,$00 ;6 
	 DC.B	$7E,$66,$06,$0C,$18,$18,$18,$00 ;7 
	 DC.B	$3C,$66,$66,$3C,$66,$66,$3C,$00 ;8 
	 DC.B	$3C,$66,$66,$3E,$06,$0C,$38,$00 ;9 
	 DC.B	$00,$18,$18,$00,$00,$18,$18,$00 ;: 
	 DC.B	$00,$18,$18,$00,$00,$18,$18,$30 ;; 
	 DC.B	$0C,$18,$30,$60,$30,$18,$0C,$00 ;< 
	 DC.B	$00,$00,$7E,$00,$00,$7E,$00,$00 ;= 
	 DC.B	$30,$18,$0C,$06,$0C,$18,$30,$00 ;> 
	 DC.B	$3C,$66,$06,$0C,$18,$00,$18,$00 ;? 
	 DC.B	$7C,$C6,$DE,$DE,$DE,$C0,$78,$00 ;@ 
	 DC.B	$18,$3C,$3C,$66,$7E,$C3,$C3,$00 ;A 
	 DC.B	$FC,$66,$66,$7C,$66,$66,$FC,$00 ;B 
	 DC.B	$3C,$66,$C0,$C0,$C0,$66,$3C,$00 ;C 
	 DC.B	$F8,$6C,$66,$66,$66,$6C,$F8,$00 ;D 
	 DC.B	$FE,$66,$60,$78,$60,$66,$FE,$00 ;E 
	 DC.B	$FE,$66,$60,$78,$60,$60,$F0,$00 ;F 
	 DC.B	$3C,$66,$C0,$CE,$C6,$66,$3E,$00 ;G 
	 DC.B	$66,$66,$66,$7E,$66,$66,$66,$00 ;H 
	 DC.B	$7E,$18,$18,$18,$18,$18,$7E,$00 ;I 
	 DC.B	$0E,$06,$06,$06,$66,$66,$3C,$00 ;J 
	 DC.B	$E6,$66,$6C,$78,$6C,$66,$E6,$00 ;K 
	 DC.B	$F0,$60,$60,$60,$62,$66,$FE,$00 ;L 
	 DC.B	$82,$C6,$EE,$FE,$D6,$C6,$C6,$00 ;M 
	 DC.B	$C6,$E6,$F6,$DE,$CE,$C6,$C6,$00 ;N 
	 DC.B	$38,$6C,$C6,$C6,$C6,$6C,$38,$00 ;O 
	 DC.B	$FC,$66,$66,$7C,$60,$60,$F0,$00 ;P 
	 DC.B	$38,$6C,$C6,$C6,$C6,$6C,$3C,$06 ;Q 
	 DC.B	$FC,$66,$66,$7C,$6C,$66,$E3,$00 ;R 
	 DC.B	$3C,$66,$70,$38,$0E,$66,$3C,$00 ;S 
	 DC.B	$7E,$5A,$18,$18,$18,$18,$3C,$00 ;T 
	 DC.B	$66,$66,$66,$66,$66,$66,$3E,$00 ;U 
	 DC.B	$C3,$C3,$66,$66,$3C,$3C,$18,$00 ;V 
	 DC.B	$C6,$C6,$C6,$D6,$FE,$EE,$C6,$00 ;W 
	 DC.B	$C3,$66,$3C,$18,$3C,$66,$C3,$00 ;X 
	 DC.B	$C3,$C3,$66,$3C,$18,$18,$3C,$00 ;Y 
	 DC.B	$FE,$C6,$8C,$18,$32,$66,$FE,$00 ;Z 
	 DC.B	$3C,$30,$30,$30,$30,$30,$3C,$00 ;[ 
	 DC.B	$C0,$60,$30,$18,$0C,$06,$03,$00 ;\ 
	 DC.B	$3C,$0C,$0C,$0C,$0C,$0C,$3C,$00 ;] 
	 DC.B	$10,$38,$6C,$C6,$00,$00,$00,$00 ;^ 
	 DC.B	$00,$00,$00,$00,$00,$00,$00,$FE ;_ 
	 DC.B	$18,$18,$0C,$00,$00,$00,$00,$00 ;` 
	 DC.B	$00,$00,$3C,$06,$1E,$66,$3B,$00 ;a 
	 DC.B	$E0,$60,$6C,$76,$66,$66,$3C,$00 ;b 
	 DC.B	$00,$00,$3C,$66,$60,$66,$3C,$00 ;c 
	 DC.B	$0E,$06,$36,$6E,$66,$66,$3B,$00 ;d 
	 DC.B	$00,$00,$3C,$66,$7E,$60,$3C,$00 ;e 
	 DC.B	$1C,$36,$30,$78,$30,$30,$78,$00 ;f 
	 DC.B	$00,$00,$3B,$66,$66,$3C,$C6,$7C ;g 
	 DC.B	$E0,$60,$6C,$76,$66,$66,$E6,$00 ;h 
	 DC.B	$18,$00,$38,$18,$18,$18,$3C,$00 ;i 
	 DC.B	$06,$00,$06,$06,$06,$06,$66,$3C ;j 
	 DC.B	$E0,$60,$66,$6C,$78,$6C,$E6,$00 ;k 
	 DC.B	$38,$18,$18,$18,$18,$18,$3C,$00 ;l 
	 DC.B	$00,$00,$66,$77,$6B,$63,$63,$00 ;m 
	 DC.B	$00,$00,$7C,$66,$66,$66,$66,$00 ;n 
	 DC.B	$00,$00,$3C,$66,$66,$66,$3C,$00 ;o 
	 DC.B	$00,$00,$DC,$66,$66,$7C,$60,$F0 ;p 
	 DC.B	$00,$00,$3D,$66,$66,$3E,$06,$07 ;q 
	 DC.B	$00,$00,$EC,$76,$66,$60,$F0,$00 ;r 
	 DC.B	$00,$00,$3E,$60,$3C,$06,$7C,$00 ;s 
	 DC.B	$08,$18,$3E,$18,$18,$1A,$0C,$00 ;t 
	 DC.B	$00,$00,$66,$66,$66,$66,$3B,$00 ;u 
	 DC.B	$00,$00,$66,$66,$66,$3C,$18,$00 ;v 
	 DC.B	$00,$00,$63,$6B,$6B,$36,$36,$00 ;w 
	 DC.B	$00,$00,$63,$36,$1C,$36,$63,$00 ;x 
	 DC.B	$00,$00,$66,$66,$66,$3C,$18,$70 ;y 
	 DC.B	$00,$00,$7E,$4C,$18,$32,$7E,$00 ;z 
	 DC.B	$0E,$18,$18,$70,$18,$18,$0E,$00 ;{ 
	 DC.B	$18,$18,$18,$18,$18,$18,$18,$00 ;| 
	 DC.B	$70,$18,$18,$0E,$18,$18,$70,$00 ;} 
	 DC.B	$72,$9C,$00,$00,$00,$00,$00,$00 ;~ 
	 DC.B	$CC,$33,$CC,$33,$CC,$33,$CC,$33 ; 

	 even

		include		source:m.meany/nt_play.s

		section		menu,data

menuscrn	incbin		source:bitmaps/big_logo.cr

logo		incbin		source:bitmaps/logo.cr



		rsreset
_PPBase		rs.l		1		base pointer for pplib
sysDMA		rs.w		1		systems DMA settings
syscop		rs.l		1		addr of systems Copper list
Plane		rs.l		1		addr of typer bitplane mem
MenuPlane	rs.l		1		addr of menu bitplane mem
ThisMenu	rs.l		1		pointer to current menu

;File viewer vars

LoadPathName	rs.l		1		addr of text file name
Line		rs.b		82		buffer for expanded text
buffer		rs.l		1		addr of text data
buf_len		rs.l		1		size of text data block
line_list	rs.l		1		addr of line pointers table
list_len	rs.l		1		size of pointer table
num_lines	rs.l		1		num of lines of text
top_line	rs.l		1		number of 1st line on scrn
lines_on_scrn	rs.l		1		display size ( 20 lines )
max_top_line	rs.l		1		max value top_line can have

VarsSize	rs.l		0		size of data block


*****************************************************************************
*****************************************************************************
***************************** CHIP Data *************************************
*****************************************************************************
*****************************************************************************

		section		cop,data_c

CopList         dc.w DIWSTRT,$2c81	Top left of screen
		dc.w DIWSTOP,$2cc1	Bottom right of screen 
		dc.w DDFSTRT,$3c	Data fetch start
		dc.w DDFSTOP,$d4	Data fetch stop
		dc.w BPLCON0,$9200	Select hi-res 2 colour 
		dc.w BPLCON1,0		No horizontal offset
		dc.w BPL1MOD,0		modulos=0

		dc.w COLOR00,$0fff	white background
		dc.w COLOR01,$0000	black foreground
 
		dc.w BPL1PTH		Plane pointer for 1 plane
CopPlanes	dc.w 0,BPL1PTL
		dc.w 0
		dc.w	$2c09,$fffe			wait 0,44 line 1
Cycle		dc.w	COLOR00,$111			modulos=0
		dc.w	$2d09,$fffe			wait 0,45 line 2
		dc.w	COLOR00,$222			modulos=0
		dc.w	$2e09,$fffe			wait 0,46 line 3
		dc.w	COLOR00,$333			modulos=0
		dc.w	$2f09,$fffe			wait 0,46 line 4
		dc.w	COLOR00,$444			modulos=0
		dc.w	$3009,$fffe			wait 0,44 line 5
		dc.w	COLOR00,$555			modulos=0
		dc.w	$3109,$fffe			wait 0,45 line 6
		dc.w	COLOR00,$666			modulos=0
		dc.w	$3209,$fffe			wait 0,46 line 7
		dc.w	COLOR00,$777			modulos=0
		dc.w	$3309,$fffe			wait 0,46 line 8
		dc.w	COLOR00,$888			modulos=0
		dc.w	$3409,$fffe			wait 0,44 line 9
		dc.w	COLOR00,$999			modulos=0
		dc.w	$3509,$fffe			wait 0,45 line 10
		dc.w	COLOR00,$aaa			modulos=0
		dc.w	$3609,$fffe			wait 0,46 line 11
		dc.w	COLOR00,$bbb			modulos=0
		dc.w	$3709,$fffe			wait 0,46 line 12
		dc.w	COLOR00,$ccc			modulos=0
		dc.w	$3809,$fffe			wait 0,44 line 13
		dc.w	COLOR00,$ddd			modulos=0
		dc.w	$3909,$fffe			wait 0,45 line 14
		dc.w	COLOR00,$eee			modulos=0
		dc.w	$3a09,$fffe			wait 0,46 line 15
		dc.w	COLOR00,$fff			modulos=0
		dc.w	$3b09,$fffe			wait 0,46 line 16
		dc.w	COLOR00,$000			modulos=0
		dc.w	$3c09,$fffe			wait 0,44 line 17
		dc.w	COLOR00,$111			modulos=0
		dc.w	$3d09,$fffe			wait 0,45 line 18
		dc.w	COLOR00,$222			modulos=0
		dc.w	$3e09,$fffe			wait 0,46 line 19
		dc.w	COLOR00,$333			modulos=0
		dc.w	$3f09,$fffe			wait 0,46 line 20
		dc.w	COLOR00,$444			modulos=0
		dc.w	$4009,$fffe			wait 0,44 line 21
		dc.w	COLOR00,$555			modulos=0
		dc.w	$4109,$fffe			wait 0,45 line 22
		dc.w	COLOR00,$666			modulos=0
		dc.w	$4209,$fffe			wait 0,46 line 23
		dc.w	COLOR00,$777			modulos=0
		dc.w	$4309,$fffe			wait 0,46 line 24
		dc.w	COLOR00,$888			modulos=0
		dc.w	$4409,$fffe			wait 0,44 line 25
		dc.w	COLOR00,$999			modulos=0
		dc.w	$4509,$fffe			wait 0,45 line 26
		dc.w	COLOR00,$aaa			modulos=0
		dc.w	$4609,$fffe			wait 0,46 line 27
		dc.w	COLOR00,$bbb			modulos=0
		dc.w	$4709,$fffe			wait 0,46 line 28
		dc.w	COLOR00,$ccc			modulos=0
		dc.w	$4809,$fffe			wait 0,44 line 29
		dc.w	COLOR00,$ddd			modulos=0
		dc.w	$4909,$fffe			wait 0,45 line 30
		dc.w	COLOR00,$eee			modulos=0
		dc.w	$4a09,$fffe			wait 0,46 line 31
		dc.w	COLOR00,$fff			modulos=0
		dc.w	$4b09,$fffe			wait 0,46 line 32
		dc.w	COLOR00,$000			modulos=0
		dc.w	$4c09,$fffe			wait 0,44 line 33
		dc.w	COLOR00,$111			modulos=0
		dc.w	$4d09,$fffe			wait 0,45 line 34
		dc.w	COLOR00,$222			modulos=0
		dc.w	$4e09,$fffe			wait 0,46 line 35
		dc.w	COLOR00,$333			modulos=0
		dc.w	$4f09,$fffe			wait 0,46 line 36
		dc.w	COLOR00,$444			modulos=0
		dc.w	$5009,$fffe			wait 0,44 line 37
		dc.w	COLOR00,$555			modulos=0
		dc.w	$5109,$fffe			wait 0,45 line 38
		dc.w	COLOR00,$666			modulos=0
		dc.w	$5209,$fffe			wait 0,46 line 39
		dc.w	COLOR00,$777			modulos=0
		dc.w	$5309,$fffe			wait 0,46 line 40
		dc.w	COLOR00,$888			modulos=0
		dc.w	$5409,$fffe			wait 0,44 line 41
		dc.w	COLOR00,$999			modulos=0
		dc.w	$5509,$fffe			wait 0,45 line 42
		dc.w	COLOR00,$aaa			modulos=0
		dc.w	$5609,$fffe			wait 0,46 line 43
		dc.w	COLOR00,$bbb			modulos=0
		dc.w	$5709,$fffe			wait 0,46 line 44
		dc.w	COLOR00,$ccc			modulos=0
		dc.w	$5809,$fffe			wait 0,44 line 45
		dc.w	COLOR00,$ddd			modulos=0
		dc.w	$5909,$fffe			wait 0,45 line 46
		dc.w	COLOR00,$eee			modulos=0
		dc.w	$5a09,$fffe			wait 0,46 line 47
		dc.w	COLOR00,$fff			modulos=0
		dc.w	$5b09,$fffe			wait 0,46 line 48
constop		dc.w	COLOR00,$000			modulos=0

		dc.w $5c09,$fffe	wait for line 49
		dc.w COLOR00,$0000	black background
		dc.w COLOR01,$0fff	white foregroung

		dc.w $ffff,$fffe	End of copper list
 
MenuCopList     dc.w DIWSTRT,$2c81	Top left of screen
		dc.w DIWSTOP,$2cc1	Bottom right of screen 
		dc.w DDFSTRT,$3c	Data fetch start
		dc.w DDFSTOP,$d4	Data fetch stop
		dc.w BPLCON0,$9200	Select hi-res 2 colour 
		dc.w BPLCON1,0		No horizontal offset

		dc.w COLOR00,$0fb0	orange background
		dc.w COLOR01,$0000	black foreground
 
		dc.w BPL1PTH		Plane pointer for 1 planes          
MenuPlanes	dc.w 0,BPL1PTL          
		dc.w 0

		dc.w	$2c09,$fffe			wait 0,44 line 1
foldtop		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$2d09,$fffe			wait 0,45 line 2
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$2e09,$fffe			wait 0,46 line 3
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$2f09,$fffe			wait 0,46 line 4
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$3009,$fffe			wait 0,44 line 5
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$3109,$fffe			wait 0,45 line 6
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$3209,$fffe			wait 0,46 line 7
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$3309,$fffe			wait 0,46 line 8
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$3409,$fffe			wait 0,44 line 9
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$3509,$fffe			wait 0,45 line 10
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$3609,$fffe			wait 0,46 line 11
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$3709,$fffe			wait 0,46 line 12
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$3809,$fffe			wait 0,44 line 13
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$3909,$fffe			wait 0,45 line 14
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$3a09,$fffe			wait 0,46 line 15
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$3b09,$fffe			wait 0,46 line 16
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$3c09,$fffe			wait 0,44 line 17
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$3d09,$fffe			wait 0,45 line 18
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$3e09,$fffe			wait 0,46 line 19
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$3f09,$fffe			wait 0,46 line 20
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$4009,$fffe			wait 0,44 line 21
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$4109,$fffe			wait 0,45 line 22
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$4209,$fffe			wait 0,46 line 23
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$4309,$fffe			wait 0,46 line 24
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$4409,$fffe			wait 0,44 line 25
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$4509,$fffe			wait 0,45 line 26
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$4609,$fffe			wait 0,46 line 27
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$4709,$fffe			wait 0,46 line 28
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$4809,$fffe			wait 0,44 line 29
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$4909,$fffe			wait 0,45 line 30
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$4a09,$fffe			wait 0,46 line 31
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$4b09,$fffe			wait 0,46 line 32
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$4c09,$fffe			wait 0,44 line 33
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$4d09,$fffe			wait 0,45 line 34
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$4e09,$fffe			wait 0,46 line 35
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$4f09,$fffe			wait 0,46 line 36
		dc.w	BPL1MOD,-80,COLOR01,$0fff	modulos=0
		dc.w	$5009,$fffe			wait 0,44 line 37
		dc.w	BPL1MOD,-80,COLOR01,$0fff	modulos=0
		dc.w	$5109,$fffe			wait 0,45 line 38
		dc.w	BPL1MOD,-80,COLOR01,$0fff	modulos=0
		dc.w	$5209,$fffe			wait 0,46 line 39
		dc.w	BPL1MOD,-80,COLOR01,$0fff	modulos=0
		dc.w	$5309,$fffe			wait 0,46 line 40
		dc.w	BPL1MOD,-80,COLOR01,$0fff	modulos=0
		dc.w	$5409,$fffe			wait 0,44 line 41
		dc.w	BPL1MOD,-80,COLOR01,$0fff	modulos=0
		dc.w	$5509,$fffe			wait 0,45 line 42
		dc.w	BPL1MOD,-80,COLOR01,$0fff	modulos=0
		dc.w	$5609,$fffe			wait 0,46 line 43
		dc.w	BPL1MOD,-80,COLOR01,$0fff	modulos=0
		dc.w	$5709,$fffe			wait 0,46 line 44
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$5809,$fffe			wait 0,44 line 45
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$5909,$fffe			wait 0,45 line 46
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$5a09,$fffe			wait 0,46 line 47
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$5b09,$fffe			wait 0,46 line 48
		dc.w	BPL1MOD,-80,COLOR01,$000	modulos=0
		dc.w	$5c09,$fffe			wait 0,44 line 49
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$5d09,$fffe			wait 0,45 line 50
		dc.w	BPL1MOD,-80,COLOR00,$0cc	modulos=0
		dc.w	$5e09,$fffe			wait 0,46 line 51
		dc.w	BPL1MOD,-80,COLOR00,$0cc	modulos=0
		dc.w	$5f09,$fffe			wait 0,46 line 52
		dc.w	BPL1MOD,-80,COLOR00,$0cc	modulos=0
		dc.w	$6009,$fffe			wait 0,44 line 53
		dc.w	BPL1MOD,-80,COLOR00,$0cc	modulos=0
		dc.w	$6109,$fffe			wait 0,45 line 54
		dc.w	BPL1MOD,-80,COLOR00,$0cc	modulos=0
		dc.w	$6209,$fffe			wait 0,46 line 55
		dc.w	BPL1MOD,-80,COLOR00,$0cc	modulos=0
		dc.w	$6309,$fffe			wait 0,46 line 56
		dc.w	BPL1MOD,-80,COLOR00,$0cc	modulos=0
		dc.w	$6409,$fffe			wait 0,44 line 57
		dc.w	BPL1MOD,-80,COLOR00,$0cc	modulos=0
		dc.w	$6509,$fffe			wait 0,45 line 58
BarStart	dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$6609,$fffe			wait 0,46 line 59
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$6709,$fffe			wait 0,46 line 60
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$6809,$fffe			wait 0,44 line 61
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$6909,$fffe			wait 0,45 line 62
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$6a09,$fffe			wait 0,46 line 63
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$6b09,$fffe			wait 0,46 line 64
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$6c09,$fffe			wait 0,44 line 65
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$6d09,$fffe			wait 0,45 line 66
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$6e09,$fffe			wait 0,46 line 67
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$6f09,$fffe			wait 0,46 line 68
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$7009,$fffe			wait 0,44 line 69
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$7109,$fffe			wait 0,45 line 70
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$7209,$fffe			wait 0,46 line 71
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$7309,$fffe			wait 0,46 line 72
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$7409,$fffe			wait 0,44 line 73
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$7509,$fffe			wait 0,45 line 74
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$7609,$fffe			wait 0,46 line 75
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$7709,$fffe			wait 0,46 line 76
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$7809,$fffe			wait 0,44 line 77
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$7909,$fffe			wait 0,45 line 78
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$7a09,$fffe			wait 0,46 line 79
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$7b09,$fffe			wait 0,46 line 80
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$7c09,$fffe			wait 0,44 line 81
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$7d09,$fffe			wait 0,45 line 82
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$7e09,$fffe			wait 0,46 line 83
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$7f09,$fffe			wait 0,46 line 84
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$8009,$fffe			wait 0,44 line 85
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$8109,$fffe			wait 0,45 line 86
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$8209,$fffe			wait 0,46 line 87
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$8309,$fffe			wait 0,46 line 88
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$8409,$fffe			wait 0,44 line 89
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$8509,$fffe			wait 0,45 line 90
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$8609,$fffe			wait 0,46 line 91
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$8709,$fffe			wait 0,46 line 92
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$8809,$fffe			wait 0,44 line 93
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$8909,$fffe			wait 0,45 line 94
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$8a09,$fffe			wait 0,46 line 95
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$8b09,$fffe			wait 0,46 line 96
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$8c09,$fffe			wait 0,44 line 97
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$8d09,$fffe			wait 0,45 line 98
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$8e09,$fffe			wait 0,46 line 99
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$8f09,$fffe			wait 0,46 line 100
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$9009,$fffe			wait 0,44 line 101
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$9109,$fffe			wait 0,45 line 102
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$9209,$fffe			wait 0,46 line 103
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$9309,$fffe			wait 0,46 line 104
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$9409,$fffe			wait 0,44 line 105
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$9509,$fffe			wait 0,45 line 106
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$9609,$fffe			wait 0,46 line 107
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$9709,$fffe			wait 0,46 line 108
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$9809,$fffe			wait 0,44 line 109
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$9909,$fffe			wait 0,45 line 110
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$9a09,$fffe			wait 0,46 line 111
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$9b09,$fffe			wait 0,46 line 112
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$9c09,$fffe			wait 0,44 line 113
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$9d09,$fffe			wait 0,45 line 114
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$9e09,$fffe			wait 0,46 line 115
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$9f09,$fffe			wait 0,46 line 116
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$a009,$fffe			wait 0,44 line 117
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$a109,$fffe			wait 0,45 line 118
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$a209,$fffe			wait 0,46 line 119
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$a309,$fffe			wait 0,46 line 120
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$a409,$fffe			wait 0,44 line 121
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$a509,$fffe			wait 0,45 line 122
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$a609,$fffe			wait 0,46 line 123
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$a709,$fffe			wait 0,46 line 124
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$a809,$fffe			wait 0,44 line 125
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$a909,$fffe			wait 0,45 line 126
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$aa09,$fffe			wait 0,46 line 127
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$ab09,$fffe			wait 0,46 line 128
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$ac09,$fffe			wait 0,44 line 129
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$ad09,$fffe			wait 0,45 line 130
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$ae09,$fffe			wait 0,46 line 131
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$af09,$fffe			wait 0,46 line 132
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$b009,$fffe			wait 0,44 line 133
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$b109,$fffe			wait 0,45 line 134
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$b209,$fffe			wait 0,46 line 135
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$b309,$fffe			wait 0,46 line 136
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$b409,$fffe			wait 0,44 line 137
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$b509,$fffe			wait 0,45 line 138
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$b609,$fffe			wait 0,46 line 139
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$b709,$fffe			wait 0,46 line 140
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$b809,$fffe			wait 0,44 line 141
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$b909,$fffe			wait 0,45 line 142
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$ba09,$fffe			wait 0,46 line 143
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$bb09,$fffe			wait 0,46 line 144
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$bc09,$fffe			wait 0,44 line 145
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$bd09,$fffe			wait 0,45 line 146
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$be09,$fffe			wait 0,46 line 147
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$bf09,$fffe			wait 0,46 line 148
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$c009,$fffe			wait 0,44 line 149
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$c109,$fffe			wait 0,45 line 150
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$c209,$fffe			wait 0,46 line 151
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$c309,$fffe			wait 0,46 line 152
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$c409,$fffe			wait 0,44 line 153
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$c509,$fffe			wait 0,45 line 154
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$c609,$fffe			wait 0,46 line 155
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$c709,$fffe			wait 0,46 line 156
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$c809,$fffe			wait 0,44 line 157
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$c909,$fffe			wait 0,45 line 158
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$ca09,$fffe			wait 0,46 line 159
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$cb09,$fffe			wait 0,46 line 160
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$cc09,$fffe			wait 0,44 line 161
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$cd09,$fffe			wait 0,45 line 162
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$ce09,$fffe			wait 0,46 line 163
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$cf09,$fffe			wait 0,46 line 164
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$d009,$fffe			wait 0,44 line 165
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$d109,$fffe			wait 0,45 line 166
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$d209,$fffe			wait 0,46 line 167
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$d309,$fffe			wait 0,46 line 168
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$d409,$fffe			wait 0,44 line 169
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$d509,$fffe			wait 0,45 line 170
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$d609,$fffe			wait 0,46 line 171
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$d709,$fffe			wait 0,46 line 172
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$d809,$fffe			wait 0,44 line 173
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$d909,$fffe			wait 0,45 line 174
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$da09,$fffe			wait 0,46 line 175
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$db09,$fffe			wait 0,46 line 176
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$dc09,$fffe			wait 0,44 line 177
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$dd09,$fffe			wait 0,45 line 178
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$de09,$fffe			wait 0,46 line 179
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$df09,$fffe			wait 0,46 line 180
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$e009,$fffe			wait 0,44 line 181
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$e109,$fffe			wait 0,45 line 182
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$e209,$fffe			wait 0,46 line 183
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$e309,$fffe			wait 0,46 line 184
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$e409,$fffe			wait 0,44 line 185
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$e509,$fffe			wait 0,45 line 186
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$e609,$fffe			wait 0,46 line 187
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$e709,$fffe			wait 0,46 line 188
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$e809,$fffe			wait 0,44 line 189
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$e909,$fffe			wait 0,45 line 190
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$ea09,$fffe			wait 0,46 line 191
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$eb09,$fffe			wait 0,46 line 192
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$ec09,$fffe			wait 0,44 line 193
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$ed09,$fffe			wait 0,45 line 194
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$ee09,$fffe			wait 0,46 line 195
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$ef09,$fffe			wait 0,46 line 196
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$f009,$fffe			wait 0,44 line 197
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$f109,$fffe			wait 0,45 line 198
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$f209,$fffe			wait 0,46 line 199
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$f309,$fffe			wait 0,46 line 200
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$f409,$fffe			wait 0,46 line 201
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$f509,$fffe			wait 0,46 line 202
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$f609,$fffe			wait 0,46 line 201
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$f709,$fffe			wait 0,46 line 201
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$f809,$fffe			wait 0,46 line 201
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$f909,$fffe			wait 0,46 line 201
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$fa09,$fffe			wait 0,46 line 201
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$fb09,$fffe			wait 0,46 line 201
		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0
		dc.w	$fc09,$fffe			wait 0,46 line 201
foldbot		dc.w	BPL1MOD,-80,COLOR00,$0fb0	modulos=0

		dc.w	$fd09,$fffe			wait 0,46 line 201
		dc.w	COLOR00,$0fb0		

; End of list!
		dc.w $ffff,$fffe	End of copper list

		section		menudata,data

; Each file should be preceeded with one of the following longword values:

;		$00000000	No action, this selection is a title or empty
;		$00000001	Goto a submenu. Addr of submenu follows this
;		View		This is a text file...show it
;		Run		This is an executable file...run it
;		LoadRaw		This is a 320*200*3 piccy, display it
;		ShowRaw		This is a 320*200*1 piccy, encoded in the
;				program. Display it.
;		$ffffffff	User want's to quit, so oblige him.

Menu1		dc.l		Title1		top line of text describing menu
		dc.l		Choice1		selection names, always 10.
		dc.l		Menu1Files	action jump table

Title1		dc.b		'*** ACC Disc 16 *** Hardware Stuff *** August 91 ***',0
		even

Choice1		dc.l		.a1
		dc.l		.a2
		dc.l		.a3
		dc.l		.a4
		dc.l		.a5
		dc.l		.a6
		dc.l		.a7
		dc.l		.a8
		dc.l		.a9
		dc.l		.aa
		dc.l		.aa
		dc.l		.ab
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aj

.a1		dc.b		0
		even
.a2		dc.b		'THE NEW ACC MENU SYSTEM',0
		even
.a3		dc.b		'Use the mouse buttons to move the pink bar up and down.',0
		even
.a4		dc.b		'Press both buttons to select an option.',0
		even
.a5		dc.b		0
		even
.a6		dc.b		'I wrote this system as apposed to using one of the many sent',0
		even
.a7		dc.b		'to me because I wanted a built-in PowerPacked text file viewer.',0
		even
.a8		dc.b		'The other systems that jump back to the os and use PPMore to',0
		even
.a9		dc.b		'display text files seemed a little messy, so......',0
		even
.ab		dc.b		'>>>>>>>>>>>>>>> Get On With It <<<<<<<<<<<<<<',0
		even
.aa		dc.b		0			no title
.aj		dc.b		'QUIT',0
		even

Menu1Files	dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.bb
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.bj

.bb		dc.l		$00000001
		dc.l		Menu2

.ba		dc.l		$0000				empty

.bj		dc.l		$ffffffff			QUIT

Menu2		dc.l		Title2		top line of text describing menu
		dc.l		Choice2		selection names, always 10.
		dc.l		Menu2Files	action jump table

Title2		dc.b		'*** ACC Disc 16 *** Hardware Stuff *** August 91 ***',0
		even

Choice2		dc.l		.a1
		dc.l		.a2
		dc.l		.a3
		dc.l		.a4
		dc.l		.a5
		dc.l		.a6
		dc.l		.a7
		dc.l		.a8
		dc.l		.aa
		dc.l		.a9
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aj

.a1		dc.b		'First Copper Example',0
		even
.a2		dc.b		'Second Copper Example',0
		even
.a3		dc.b		'Example Startup Code',0
		even
.a4		dc.b		'Startup Subroutines',0
		even
.a5		dc.b		'Hardware Text Viewer',0
		even
.a6		dc.b		'Screen Melt',0
		even
.a7		dc.b		'Screen Wobble',0
		even
.a8		dc.b		'Hardware Docs',0
		even
.a9		dc.b		'>>>>>>>>>>>>>>> Goto Cruncher Menu <<<<<<<<<<<<<<<',0
		even
.aa		dc.b		0			no title
.aj		dc.b		'QUIT',0
		even

Menu2Files	dc.l		.b1
		dc.l		.b2
		dc.l		.b3
		dc.l		.b4
		dc.l		.b5
		dc.l		.b6
		dc.l		.b7
		dc.l		.b8
		dc.l		.ba
		dc.l		.b9
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.bj

.b1		dc.l		View				text file
		dc.b		'df1:hardware/cop_eg1.s',0
		even
.b2		dc.l		View				text file
		dc.b		'df1:hardware/cop_eg2.s',0
		even
.b3		dc.l		View				text file
		dc.b		'df1:hardware/start.s',0
		even
.b4		dc.l		View				text file
		dc.b		'df1:hardware/subs.i',0
		even
.b5		dc.l		View				text file
		dc.b		'df1:hardware/supertyper.s',0
		even
.b6		dc.l		View				text file
		dc.b		'df1:hardware/unfold2.s',0
		even
.b7		dc.l		View				text file
		dc.b		'df1:hardware/wobble1.s',0
		even
.b8		dc.l		View				text file
		dc.b		'df1:hardware/wobble.doc',0
		even
.b9		dc.l		$00000001			Menu
		dc.l		Menu3
		even
.ba		dc.l		$0000				empty
.bj		dc.l		$ffffffff			QUIT


Menu3		dc.l		Title3		top line of text describing menu
		dc.l		Choice3		selection names, always 10.
		dc.l		Menu3Files	action jump table

Title3		dc.b		'*** ACC Disc 16 *** Cruncher Stuff *** August 91 ***',0
		even

Choice3		dc.l		.a1
		dc.l		.a2
		dc.l		.a3
		dc.l		.a4
		dc.l		.a5
		dc.l		.a6
		dc.l		.aa
		dc.l		.a7
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aa
		dc.l		.aj

.a1		dc.b		'The Crunching Subroutine',0
		even
.a2		dc.b		'Cruncher Source',0
		even
.a3		dc.b		'Simplest DeCrunch Routine',0
		even
.a4		dc.b		'More Flexible Decrunch Routine',0
		even
.a5		dc.b		'Screen Melt Using Crunched Data',0
		even
.a6		dc.b		'Screen Wobble Using Crunched Data',0
		even
.a7		dc.b		'>>>>>>>>>>>>>>>> Goto Hardware Menu <<<<<<<<<<<<<<<',0
		even
.aa		dc.b		0			no title
		even
.aj		dc.b		'QUIT',0
		even

Menu3Files	dc.l		.b1
		dc.l		.b2
		dc.l		.b3
		dc.l		.b4
		dc.l		.b5
		dc.l		.b6
		dc.l		.ba
		dc.l		.b7
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.ba
		dc.l		.bj

.b1		dc.l		View				text file
		dc.b		'df1:cruncher/byterun_test.s',0
		even
.b2		dc.l		View				text file
		dc.b		'df1:cruncher/crunch.s',0
		even
.b3		dc.l		View				text file
		dc.b		'df1:cruncher/decrunch.s',0
		even
.b4		dc.l		View				text file
		dc.b		'df1:cruncher/decrunch_1.s',0
		even
.b5		dc.l		View				text file
		dc.b		'df1:cruncher/melt_crunched.s',0
		even
.b6		dc.l		View				text file
		dc.b		'df1:cruncher/wobble_crunched.s',0
		even
.b7		dc.l		$00000001
		dc.l		Menu2

.ba		dc.l		$0000				empty
.bj		dc.l		$ffffffff			QUIT

		even
 
