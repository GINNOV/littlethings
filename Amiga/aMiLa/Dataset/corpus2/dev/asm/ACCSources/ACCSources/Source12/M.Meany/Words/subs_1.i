0
; First file of subroutines for Words v2.0.

; © M.Meany, May 1991.

*******************************
*******************************	Subroutines
*******************************

GoForWord	bsr		OpenWin
		beq		.quit_fast

		bsr		WaitForMsg

		bsr		CloseWin

.quit_fast	rts


;--------------
;--------------	Open the main window
;--------------


OpenWin		lea		WordWindow,a0
		CALLINT		OpenWindow
		move.l		d0,window.ptr(a4)
		beq		.error

		move.l		d0,a0
		move.l		wd_UserPort(a0),window.up(a4)
		move.l		wd_RPort(a0),window.rp(a4)

;--------------	Write text into window

		move.l		window.rp(a4),a0		rastport
		lea		IText1,a1	the text
		moveq.l		#0,d0		x=0
		move.l		d0,d1		y=0
		CALLSYS		PrintIText	and print it

;--------------	Display title in window

		move.l		window.rp(a4),a0		rastport
		lea		Image8,a1	the text
		move.l		#210,d0		x=210
		move.l		#135,d1		y=0
		CALLSYS		DrawImage	and display it

;--------------	Add choice gadgets

		bsr		AddEmOn		add choice gadgets


;--------------	Put scroll box on screen

		move.l		window.rp(a4),a1	rastport
		moveq.l		#1,d0			Foreground
		CALLGRAF	SetAPen			set it

		move.l		window.rp(a4),a1	rastpot2
		move.l		#375,d0			x1
		move.l		#29,d1			y1
		move.l		#375+250,d2		x2
		move.l		#29+88,d3		y2
		CALLGRAF	RectFill		fill it

;--------------	Initialise appropriate subroutine

		lea		Match,a0		init choice
		move.l		a0,Subroutine(a4)	and set it

;--------------	Display number of words in glossary

		bsr		WriteGlosSize

;--------------	But a border around glossary size

		move.l		window.rp(a4),a0	rastport
		lea		NiceBorder,a1		border struct
		move.l		#180,d0			left offset
		moveq.l		#54,d1			top offset
		CALLINT		DrawBorder		and draw it

;--------------	No errors so clear Z flag and finish

		moveq.l		#1,d1			no errors
		move.l		d1,quit_Flag(a4)	clear flag
.error		rts

;--------------
;--------------	Wait for user interaction
;--------------

WaitForMsg	move.l		window.up(a4),a0	a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		window.up(a4),a0	a0-->window pointer
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WaitForMsg	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.w		im_Code(a1),d3	d3=key code or menu details
		move.w		im_Qualifier(a1),d4 d4=special key details
		move.l		im_IAddress(a1),d7
		CALLEXEC	ReplyMsg	answer os or it get angry

;--------------	Message received, see if it's a CLOSEWINDOW

		cmp.l		#CLOSEWINDOW,d2	win close gadg hit ?
		beq.s		.done		if so leave

;--------------	Not CLOSEWINDOW, see if it's a GADGETUP

		cmp.l		#GADGETUP,d2	action gadg selected ?
		bne.s		.check_Gdown	if not jump to next test
		move.l		d7,a0		get gadg struct addr
		move.l		gg_UserData(a0),a0 get addr of server
		jsr		(a0)		and jump to it
		tst.l		quit_Flag(a4)	QUIT gadget hit ?
		beq.s		.done		if so leave
		bra.s		.ignore		else jump to end of checks

;--------------	Not GADGETUP, see if it's GADGETDOWN

.check_Gdown	cmp.l		#GADGETDOWN,d2	selection gadg hit ?
		bne.s		.ignore		if not jump to end of checks
		move.l		d7,a0		get gadg struct addr
		move.l		gg_UserData(a0),a0 get addr of server
		jsr		(a0)		and jump to it

.ignore		bra.s		WaitForMsg

;--------------	User has chosen to quit, so do so !

.done		rts

;--------------
;--------------	Close the window
;--------------

CloseWin	move.l		window.ptr(a4),a0
		CALLINT		CloseWindow
		rts


*******************************
*******************************	Gadget server subroutines
*******************************


;--------------
;-------------- Deal with string entry gadget
;--------------


;-------------- Remove string gadget from list, stops multiple entries

GG1		move.l		window.ptr(a4),a0
		lea		Gadget1,a1
		CALLINT		RemoveGadget
		move.l		d0,Position(a4)

;--------------	Convert entry to UCASE, display it and clear scroll region

		lea		EntryBuffer,a0
		tst.b		(a0)
		beq.s		.error

		bsr		ucase
		bsr		clear_list
		bsr		clear_display
		bsr		display_key

;--------------	Find all words that satisfy user requirements

		move.l		Subroutine(a4),a0
		jsr		(a0)

;--------------	Clear string gadget buffer

.error		lea		EntryBuffer,a0
		move.b		#0,(a0)+
		moveq.l		#29,d0
.loop		move.b		#' ',(a0)+
		dbra		d0,.loop

;--------------	Remove text from the window

		move.l		window.rp(a4),a1
		moveq.l		#0,d0
		CALLGRAF	SetAPen

		move.l		window.rp(a4),a1
		moveq.l		#44,d0
		moveq.l		#30,d1
		move.l		#44+268,d2
		move.l		#30+8,d3
		CALLSYS		RectFill

;--------------	Restore string gadget structure

		lea		CurPos,a0
		move.l		#30,(a0)+
		move.l		#0,(a0)+
		move.w		#0,(a0)

;-------------- Add gadget back to list

		move.l		window.ptr(a4),a0
		lea		Gadget1,a1
		move.l		Position(a4),d0
		CALLINT		AddGadget

;--------------	And activate it ready for next input

		lea		Gadget1,a0
		move.l		window.ptr(a4),a1
		move.l		#0,a2
		CALLSYS		ActivateGadget

;--------------	Init variables that control scrolling of output

		move.l		#1,top_line(a4)
		move.l		num_lines(a4),d0
		sub.l		#11,d0
		beq.s		.line_ok
		bpl.s		.ok
.line_ok	moveq.l		#1,d0
.ok		move.l		d0,max_top_line(a4)
		bsr		refresh_display		
		
		rts

;--------------
;-------------- Deal with UP gadget
;--------------

GG2		bsr		ScrollDown
		btst		#6,ciaapra
		beq.s		GG2

;--------------	And activate string gadget ready for next input

		lea		Gadget1,a0
		move.l		window.ptr(a4),a1
		move.l		#0,a2
		CALLINT		ActivateGadget

		rts

;--------------
;-------------- Deal with DOWN gadget
;--------------

GG3		bsr		ScrollUp
		btst		#6,ciaapra
		beq.s		GG3

;--------------	And activate string gadget ready for next input

		lea		Gadget1,a0
		move.l		window.ptr(a4),a1
		move.l		#0,a2
		CALLINT		ActivateGadget

		rts

;--------------
;-------------- Deal with QUIT gadget
;--------------

GG4		move.l		#0,quit_Flag(a4)
		rts

;--------------
;-------------- Deal with ABOUT gadget
;--------------

GG5		bsr		About

;--------------	And activate string gadget ready for next input

		lea		Gadget1,a0
		move.l		window.ptr(a4),a1
		move.l		#0,a2
		CALLINT		ActivateGadget

		rts
		

;--------------
;-------------- Deal with MATCH gadget
;--------------

;--------------	remove choice gadgets

GG6		move.l		window.ptr(a4),a0
		lea		Gadget6,a1
		moveq.l		#3,d0
		CALLINT		RemoveGList

;--------------	make sure this gadget is inversed

		move.l		#SELECTED,d0

		lea		Gadget6,a0
		or.w		d0,gg_Flags(a0)

;-------------- And de-activate other 2 mutualy exclusive gadgets

		not.w		d0			complement bits

		lea		Gadget7,a0
		and.w		d0,gg_Flags(a0)

		lea		Gadget8,a0
		and.w		d0,gg_Flags(a0)

;-------------- Add the gadgets back

		bsr		AddEmOn

;--------------	Set pointer to appropriate subroutine

		lea		Match,a0
		move.l		a0,Subroutine(a4)

		rts

;--------------
;-------------- Deal with ANAGRAM gadget
;--------------

;--------------	Remove the mutualy exclusive gadgets from list

GG7		move.l		window.ptr(a4),a0
		lea		Gadget6,a1
		moveq.l		#3,d0
		CALLINT		RemoveGList

;-------------- SELECT appropriate gadget

		move.l		#SELECTED,d0

		lea		Gadget7,a0
		or.w		d0,gg_Flags(a0)

;-------------- De-SELECT other two

		not.w		d0			complement bits

		lea		Gadget6,a0
		and.w		d0,gg_Flags(a0)

		lea		Gadget8,a0
		and.w		d0,gg_Flags(a0)

;-------------- Add the gadgets back and return

		bsr		AddEmOn

;--------------	Set pointer to appropriate subroutine

		lea		Anagram,a0
		move.l		a0,Subroutine(a4)

		rts

;--------------
;-------------- Deal with MAKE gadget
;--------------

;--------------	Remove the mutualy exclusive gadgets from list

GG8		move.l		window.ptr(a4),a0
		lea		Gadget6,a1
		moveq.l		#3,d0
		CALLINT		RemoveGList

;-------------- SELECT appropriate gadget

		move.l		#SELECTED,d0

		lea		Gadget8,a0
		or.w		d0,gg_Flags(a0)

;-------------- De-SELECT other two

		not.w		d0			complement bits

		lea		Gadget6,a0
		and.w		d0,gg_Flags(a0)

		lea		Gadget7,a0
		and.w		d0,gg_Flags(a0)

;-------------- Add the gadgets back and return

		bsr		AddEmOn

;--------------	Set pointer to appropriate subroutine

		lea		Make,a0
		move.l		a0,Subroutine(a4)

		rts

;--------------
;-------------- Add selection gadgets to window and display them
;--------------

AddEmOn		move.l		window.ptr(a4),a0	window pointer
		lea		Gadget6,a1	addr of 1st gadg
		moveq.l		#-1,d0		add to end of GList
		moveq.l		#3,d1		num of gadgs to add
		move.l		#0,a2		no requester
		CALLINT		AddGList	and add them
	
		lea		Gadget6,a0	addr of 1st gadg
		move.l		window.ptr(a4),a1	window pointer
		move.l		#0,a2		no requester
		moveq.l		#3,d0		num of gadgs
		CALLSYS		RefreshGList	and show them

;--------------	And activate string gadget ready for next input

		lea		Gadget1,a0
		move.l		window.ptr(a4),a1
		move.l		#0,a2
		CALLSYS		ActivateGadget

		rts


Match		lea		EntryBuffer,a0	user string

;--------------	Determine length of entry

		move.l		a0,a1		copy of addr
		move.l		a0,a3		copy of addr
		moveq.l		#0,d0		entry length
		move.l		d0,d1		CONSTANT  0
		moveq.l		#1,d2		CONSTANT  1
		moveq.l		#'?',d3		CONSTANT '?'

.loop		add.b		d2,d0		bump counter
		cmp.b		(a1)+,d1	zero byte ?
		bne.s		.loop		loop back if not

		move.l		line_list(a4),a2 a2->line list
.check_next	move.l		(a2)+,a1	a1->next word
		move.w		(a2)+,d1	d1=len of word
		beq		.all_done	quit if no more words

		cmp.b		d0,d1		same length ?
		bne.s		.check_next	loop back if not

		move.l		d0,d4		init counter
		sub.l		d2,d4		adjust for DBRA

.loop1		cmp.b		(a0),d3		is char a ?
		bne.s		.check		if not jump
		add.l		d2,a0		bump ptr
		add.l		d2,a1		bump ptr
		bra.s		.same		and jump

.check		cmp.b		(a0)+,(a1)+	compare chars
.same		dbne		d4,.loop1	loop while same

		bne.s		.no_match	not same, so branch

		movem.l		d0-d3/a0-a3,-(sp) save vars
		move.l		-6(a2),a0	a0->start of this word
		bsr		add_node	add word to list
		movem.l		(sp)+,d0-d3/a0-a3 retrieve vars

.no_match	move.l		a3,a0
		bra.s		.check_next

.all_done	rts

Anagram		lea		EntryBuffer,a0
		move.l		a0,a3
		moveq.l		#0,d3
		move.l		d3,d1
		moveq.l		#1,d2

.loop		add.b		d2,d3
		cmp.b		(a0)+,d1
		bne.s		.loop

		move.l		a3,a0
		bsr		ByteBubble

		move.l		line_list(a4),a2
		lea		CheckBuf(a4),a5
.check_next	move.l		(a2)+,a1
		move.w		(a2)+,d1
		beq.s		.all_done

		cmp.b		d1,d3		compare lengths
		bne.s		.check_next

		subq.l		#1,d1
		move.l		a5,a0
.loop1		move.b		(a1)+,(a0)+
		dbra		d1,.loop1

		move.l		a5,a0
		bsr		ByteBubble

		move.l		a5,a0
		move.l		a3,a1
		move.l		d3,d0
		sub.l		d2,d0		adjust for dbra
.check		cmp.b		(a0)+,(a1)+
		dbne		d0,.check
		bne.s		.check_next

		movem.l		d2-d3/a2/a3/a5,-(sp)
		move.l		-6(a2),a0
		bsr		add_node
		movem.l		(sp)+,d2-d3/a2/a3/a5
		bra.s		.check_next

.all_done	rts
		rts

Make		lea		EntryBuffer,a0
		move.l		a0,a3
		moveq.l		#0,d3
		move.l		d3,d1
		moveq.l		#1,d2

.loop		add.b		d2,d3
		cmp.b		(a0)+,d1
		bne.s		.loop

		move.l		a3,a0
		bsr		ByteBubble

		move.l		line_list(a4),a2
		lea		CheckBuf(a4),a5
.check_next	move.l		(a2)+,a1
		move.w		(a2)+,d1
		beq.s		.all_done

		cmp.b		d1,d3		compare lengths
		blt.s		.check_next

		subq.l		#1,d1
		move.l		a5,a0
.loop1		move.b		(a1)+,(a0)+
		dbra		d1,.loop1

		move.l		a5,a0
		bsr		ByteBubble

		move.l		a5,a0
		move.l		a3,a1
.outer		move.b		(a0),d1
.next		cmp.b		(a1)+,d1
		beq.s		.got_char
		tst.b		(a1)
		beq		.check_next
		bra.s		.next

.got_char	tst.b		(a0)+
		tst.b		(a0)
		bne.s		.outer

		movem.l		d2-d3/a2-a5,-(sp)
		move.l		-6(a2),a0
		bsr		add_node
		movem.l		(sp)+,d2-d3/a2-a5
		bra.s		.check_next

.all_done	rts


;--------------
;-------------- Ascending sort routine. Sorts a string of bytes.
;--------------

;Entry		a0-> NULL terminated string of bytes

;Corrupt	a0,a1,d0,d4

ByteBubble	move.l		#0,flag(a4)
		tst.b		(a0)
		beq.s		.error

		move.l		a0,a1
		moveq.l		#1,d4

.loop		tst.b		1(a0)
		beq.s		.done
		move.b		(a0)+,d0
		cmp.b		(a0),d0
		ble.s		.loop

		move.l		d4,flag(a4)
		move.b		(a0),-1(a0)
		move.b		d0,(a0)
		bra		.loop

.done		move.l		a1,a0
		tst.l		flag(a4)
		bne.s		ByteBubble

.error		rts
