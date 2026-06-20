
; String search and support routines and data defenitions for PPMuchMore.

; © M.Meany, April 1991

SearchString	lea		SearchBuffer(a4),a0	addr of wins buffer
		move.l		a0,SearchGadgInfo	attach to gadget
		lea		search_window,a0	a0-->window structure
		CALLINT		OpenWindow	open this window
		move.l		d0,search.ptr	save its pointer
		lea		SearchWinText,a1	a1-->text structure
		move.l		search.ptr,a0	a0-->window
		move.l		wd_RPort(a0),a0	a0-->Rastport
		moveq.l		#0,d0		x position of text
		moveq		#0,d1		y position of text
		CALLSYS		PrintIText	print the help message
		lea		SearchGadg,a0
		move.l		search.ptr,a1
		move.l		#0,a2
		CALLSYS		ActivateGadget

WaitForSearch	move.l		search.ptr,a0	a0-->window
		move.l		wd_UserPort(a0),a0  a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		search.ptr,a0	a0-->window pointer
		move.l		wd_UserPort(a0),a0  a0-->user port
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WaitForSearch	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.l		im_IAddress(a1),a5 a5=addr of structure
		CALLSYS		ReplyMsg	answer o/s or it gets angry
		cmp.l		#GADGETUP,d2
		bne.s		WaitForSearch
		move.l		gg_UserData(a5),a5
		jsr		(a5)
		
		move.l		search.ptr,a0	a0-->window
		CALLINT		CloseWindow	close this window
		bsr		refresh_display
		rts
	
;--------------	Determine length of string entered

GotSearchNum	lea		SearchBuffer(a4),a0
		move.l		a0,a1
		moveq.l		#-1,d0
		moveq.l		#0,d1
.loop		addq.l		#1,d0
		cmp.b		(a1)+,d1
		bne.s		.loop

		tst.l		d0
		beq		.error

;--------------	At this point a0->input string and d0=its length

		move.l		buffer(a4),a1
		move.l		buf_len(a4),d1
		bsr		Find
		beq		.error

;--------------	At this point d0=addr of string in buffer

		move.l		line_list(a4),a0
		moveq.l		#0,d1
.loop1		addq.l		#1,d1
		cmp.l		(a0)+,d0
		bge.s		.loop1
		subq.l		#1,d1
		cmp.l		max_top_line(a4),d1
		ble.s		.okk
		move.l		max_top_line(a4),d1
.okk		move.l		d1,top_line(a4)
.error		rts


NoSearchNum	rts


Next		move.l		top_line(a4),d0
		addq.l		#1,d0
		cmp.l		max_top_line(a4),d0
		bge.s		.error

;--------------	Calculate number of bytes to search through

		move.l		line_list(a4),a0
		subq.l		#1,d0
		asl.l		#2,d0
		move.l		0(a0,d0),d0
		move.l		d0,a1
		move.l		buf_len(a4),d1
		add.l		buffer(a4),d1
		sub.l		d0,d1

;--------------	Determine length of string to search for

		lea		SearchBuffer(a4),a0
		move.l		a0,a2
		moveq.l		#-1,d0
		moveq.l		#0,d2
.loop		addq.l		#1,d0
		cmp.b		(a2)+,d2
		bne.s		.loop

		tst.l		d0
		beq		.error

;--------------	At this point a0->string, d0=its length
;		              a1->top line on screen  d1=num of bytes left

		bsr		Find
		beq		.error

;--------------	At this point d0=addr of string in buffer

		move.l		line_list(a4),a0
		moveq.l		#0,d1
.loop1		addq.l		#1,d1
		cmp.l		(a0)+,d0
		bge.s		.loop1
		subq.l		#1,d1
		cmp.l		max_top_line(a4),d1
		ble.s		.okk
		move.l		max_top_line(a4),d1
.okk		move.l		d1,top_line(a4)
		bsr		refresh_display
.error		rts

; Subroutine to search a block of memory for a given string.
; M.Meany, April 91.

; Entry		a0 addr of string to search for
;		d0 length of string
;		a1 addr of memory block
;		d1 length of memory block

; Exit		d0 addr of first occurence of string, 0 if no match found

; Corrupted	d0

Find		movem.l		d1-d2/a0-a2,-(sp) save values
		move.l		#0,_MatchFlag	clear flag, assume failure
		sub.l		d0,d1		set up counter
		subq.l		#1,d1		correct for dbra
		bmi.s		_FindError	quit if block < string

		move.b		(a0),d2		d2=1st char to match
_Floop		cmp.b		(a1)+,d2	match 1st char of string ?
		dbeq		d1,_Floop	no+not end, loop back

		bne.s		_FindError	if no match+end then quit

		bsr.s		_CompStr	else check rest of string

		beq.s		_Floop		loop back if no match

_FindError	movem.l		(sp)+,d1-d2/a0-a2 retrieve values
		move.l		_MatchFlag,d0	set d0 for return
		rts

_CompStr	movem.l		d0/a0-a2,-(sp)

		subq.l		#1,d0		correct for dbra
		move.l		a1,a2		save a copy
		subq.l		#1,a1		correct as it was bumped
_FFloop		cmp.b		(a0)+,(a1)+	compare string elements
		dbne		d0,_FFloop	while not end + not match

		bne.s		_ComprDone	no match so quit
		subq.l		#1,a2		correct this addr
		move.l		a2,_MatchFlag	save addr of match

_ComprDone	movem.l		(sp)+,d0/a0-a2
		tst.l		_MatchFlag	set Z flag as required
		rts

_MatchFlag	dc.l		0


; Data for Go To Line window, gadgets and text.

search.ptr	dc.l		0

search_window	dc.w		150,90	
		dc.w		279,67		
		dc.b		0,2		
		dc.l		GADGETUP
		dc.l		ACTIVATE		
		dc.l		SearchGadg
		dc.l		0		
		dc.l		0		
		dc.l		0		
		dc.l		0		
		dc.w		5,5		
		dc.w		640,200		
		dc.w		WBENCHSCREEN		

SearchGadg	dc.l		SearchOKGadg		
		dc.w		110,22		
		dc.w		164,8
		dc.w		0		
		dc.w		RELVERIFY+GADGIMMEDIATE
		dc.w		STRGADGET		
		dc.l		0
		dc.l		0		
		dc.l		0		
		dc.l		0		
		dc.l		SearchGadgInfo		
		dc.w		0		
		dc.l		GotSearchNum

SearchGadgInfo	dc.l		0		addr of buffer here
		dc.l		0
		dc.w		0		
		dc.w		40
		dc.w		0		
		dc.w		0,0,0,0,0		
		dc.l		0		
		dc.l		0		
		dc.l		0		

SearchOKGadg	dc.l		SearchCancelGadg		
		dc.w		33,49		
		dc.w		64,12		
		dc.w		0		
		dc.w		RELVERIFY		
		dc.w		BOOLGADGET		
		dc.l		SearchOKBorder
		dc.l		0		
		dc.l		SearchOKStruct
		dc.l		0		
		dc.l		0		
		dc.w		0		
		dc.l		GotSearchNum		

SearchOKBorder	dc.w		-2,-1		
		dc.b		2,0,RP_JAM1		
		dc.b		5		
		dc.l		SearchOKVectors
		dc.l		0		

SearchOKVectors	dc.w		0,0
		dc.w		67,0
		dc.w		67,13
		dc.w		0,13
		dc.w		0,0

SearchOKStruct	dc.b		1,0,RP_JAM2,0		
		dc.w		24,3		
		dc.l		0		
		dc.l		SearchOKText	
		dc.l		0		

SearchOKText	dc.b		'OK',0
		even

SearchCancelGadg	dc.l		0		
		dc.w		180,49		
		dc.w		64,12		
		dc.w		0		
		dc.w		RELVERIFY		
		dc.w		BOOLGADGET		
		dc.l		SearchCancelBorder
		dc.l		0		
		dc.l		SearchCancelStruct
		dc.l		0		
		dc.l		0		
		dc.w		0		
		dc.l		NoSearchNum

SearchCancelBorder dc.w		-2,-1		
		dc.b		2,0,RP_JAM1		
		dc.b		5		
		dc.l		SearchCancelVectors
		dc.l		0		

SearchCancelVectors dc.w		0,0
		dc.w		67,0
		dc.w		67,13
		dc.w		0,13
		dc.w		0,0

SearchCancelStruct dc.b		1,0,RP_JAM2,0		
		dc.w		8,3		
		dc.l		0		
		dc.l		SearchCancelText
		dc.l		0		

SearchCancelText	dc.b		'CANCEL',0
		even

SearchWinText	dc.b		1,0,RP_JAM2,0		
		dc.w		15,23		
		dc.l		0		
		dc.l		SearchWinTextStr	
		dc.l		0		

SearchWinTextStr	dc.b		'STRING  :',0
		even

