
; Second subroutine file for Words v2.0

; © M.Meany, May 1991


;--------------
;--------------	clear scroll region of screen
;--------------

clear_display	move.l		window.rp(a4),a1 rastport
		moveq.l		#1,d0		foreground colour (white)
		CALLGRAF	SetAPen		and set it

;--------------	Blit a white rectangle over output area

		move.l		window.rp(a4),a1  rastport
		move.l		#375,d0		x-start
		move.l		#29,d1		y-start
		move.l		#375+250,d2	x-stop
		move.l		#29+88,d3	y-stop
		CALLGRAF	RectFill	and fill it

		rts

;--------------
;-------------- Display the users key above scroll area
;--------------

;--------------	Use RawDoFmt to ensure string occupies 30 chars and so
;		deletes previous string

display_key	move.l		#EntryBuffer,DataStream(a4)
		bsr		RDF

;--------------	Print the users entry

		move.l		window.rp(a4),a0 rastport
		lea		KeyText,a1	IText structure
		moveq.l		#0,d0		x-offset
		move.l		d0,d1		y-offset
		CALLINT		PrintIText	and print it

		rts

;--------------
;-------------- Refresh scroll area
;--------------

refresh_display	lea		start_list(a4),a0
		
		move.l		node.next(a0),a0
		tst.l		node.data(a0)
		beq		.error

		move.l		a0,a5		addr of data
		moveq.l		#0,d6		y offset
		moveq.l		#10,d5		counter, 11 lines

.loop		move.l		node.data(a5),DataStream(a4)
		bsr		RDF

		move.l		window.rp(a4),a0
		lea		ListText,a1
		moveq.l		#0,d0
		move.l		d6,d1
		CALLINT		PrintIText

		move.l		node.next(a5),a5
		tst.l		node.data(a5)
		beq.s		.error

		addq.l		#8,d6
		dbra		d5,.loop
.error		rts

;--------------
;-------------- Scroll output area up 1 line
;--------------

ScrollUp	tst.l		num_lines(a4)
		beq.s		.error

		move.l		top_line(a4),d7
		cmp.l		max_top_line(a4),d7
		beq.s		.error

		addq.l		#1,d7
		move.l		d7,top_line(a4)
		add.l		#10,d7

		move.l		window.rp(a4),a1  rastport
		moveq.l		#0,d0		dx
		moveq.l		#8,d1		dy
		move.l		#380,d2		x-start
		move.l		#29,d3		y-start
		move.l		#375+244,d4	x-stop
		move.l		#29+88,d5	y-stop
		CALLGRAF	ScrollRaster	and scroll it

		lea		start_list(a4),a0
.loop		move.l		node.next(a0),a0
		dbra		d7,.loop
		move.l		node.data(a0),DataStream(a4)
		bsr		RDF

		move.l		window.rp(a4),a0
		lea		ListText,a1
		moveq.l		#0,d0
		moveq.l		#80,d1
		CALLINT		PrintIText


.error		rts

;--------------
;-------------- Scroll output area down 1 line
;--------------

ScrollDown	tst.l		num_lines(a4)
		beq.s		.error

		move.l		top_line(a4),d7
		cmp.l		#1,d7
		beq.s		.error

		subq.l		#1,d7
		move.l		d7,top_line(a4)

		move.l		window.rp(a4),a1  rastport
		moveq.l		#0,d0		dx
		moveq.l		#-8,d1		dy
		move.l		#380,d2		x-start
		move.l		#30,d3		y-start
		move.l		#375+244,d4	x-stop
		move.l		#29+88,d5	y-stop
		CALLGRAF	ScrollRaster	and scroll it

		lea		start_list(a4),a0
		subq.l		#1,d7
.loop		move.l		node.next(a0),a0
		dbra		d7,.loop
		move.l		node.data(a0),DataStream(a4)
		bsr		RDF

		move.l		window.rp(a4),a0
		lea		ListText,a1
		moveq.l		#0,d0
		move.l		d0,d1
		CALLINT		PrintIText


.error		rts


;--------------
;-------------- Convert string to upper case chars
;--------------

;Entry		a0->start of 0 terminated string

ucase		tst.b		(a0)
		beq.s		.error

		move.l		#'a',d0
		move.l		#'z',d1
		moveq.l		#$20,d2

.loop		cmp.b		(a0)+,d0
		bgt.s		.ok

		cmp.b		-1(a0),d1
		blt.s		.ok

		sub.b		d2,-1(a0)

.ok		tst.b		(a0)
		bne.s		.loop
.error		rts

;--------------
;-------------- Use RawDoFmt to extend entry to 30 chars
;--------------

RDF		lea		Template,a0
		lea		DataStream(a4),a1
		lea		PutChar,a2
		lea		RDFbuf(a4),a3
		CALLEXEC	RawDoFmt
		rts

WriteGlosSize	move.l		window.rp(a4),a0
		lea		GlossText,a1
		moveq.l		#0,d0
		move.l		d0,d1
		CALLINT		PrintIText

		lea		Template1,a0
		lea		NumWords(a4),a1
		lea		PutChar,a2
		lea		RDFbuf(a4),a3
		move.l		a3,GlossTextPtr
		CALLEXEC	RawDoFmt

		move.l		window.rp(a4),a0
		lea		GlossText,a1
		moveq.l		#0,d0
		moveq.l		#10,d1
		CALLINT		PrintIText

		rts

PutChar		move.b		d0,(a3)+
		rts

