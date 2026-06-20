
;--------------	Editor subroutines

;--------------	Turn cursor on.

cursor_on	move.w		#$0203,d0
		move.w		d0,cur_text
		bsr		calc_curx
		bsr		get_cur_char
		lea		cur_text,a1	a1-->text structure
		move.l		window.rp(a4),a0	a0-->window rastport
		move.l		cur_x(a4),d0	x position of text
		move.l		cur_y(a4),d1	y position of text
		CALLINT		PrintIText	print the cursor
		rts

;--------------	Turn cursor off.

cursor_off	movem.l		d0-d7/a0-a7,-(sp)
		move.l		#$0100,d0
		move.w		d0,cur_text
		bsr		calc_curx
		bsr		get_cur_char
		lea		cur_text,a1	a1-->text structure
		move.l		window.rp(a4),a0	a0-->window rastport
		move.l		cur_x(a4),d0	x position of text
		move.l		cur_y(a4),d1	y position of text
		CALLINT		PrintIText	unprint the cursor
		movem.l		(sp)+,d0-d7/a0-a7
		rts
		
;--------------	Get character under cursor.

get_cur_char	move.l		cur_addr(a4),a0
		move.b		(a0),d0
		cmp.b		#$0a,d0
		beq.s		.do_space
		cmp.b		#$09,d0
		beq.s		.do_space
		bra.s		.done
.do_space	move.b		#' ',d0
.done		move.b		d0,cursor
		rts

;--------------	Move the cursor right 1 character.

cursor_right	move.l		cur_addr(a4),a0
		move.b		(a0)+,d0
		cmp.b		#$0a,d0
		beq.s		.done
		move.l		a0,cur_addr(a4)
		addq.l		#1,cur_pos(a4)
		bsr		calc_curx
.done		rts

;--------------	Move the cursor left 1 character.

cursor_left	move.l		cur_pos(a4),d0
		beq.s		.done
		subq.l		#1,d0
		move.l		d0,cur_pos(a4)
		subq.l		#1,cur_addr(a4)
		bsr		calc_curx
.done		rts

;--------------	Calculate the screen x position from cur_pos.

calc_curx	lea		edit_buffer(a4),a0
		moveq.l		#0,d0
		move.l		d0,offset(a4)
		move.l		cur_pos(a4),d1
		beq.s		.done
		subq.l		#1,d1
.loop		move.b		(a0)+,d2
		addq.l		#1,d0
		cmp.b		#$09,d2
		bne.s		.not_tab
		addq.l		#7,d0
		and.b		#$f8,d0
.not_tab	dbra		d1,.loop
.done		move.l		font.width(a4),d1
		mulu		d1,d0
		addq.l		#5,d0
		move.l		d0,d1
		moveq.l		#8,d2
		move.l		font.width(a4),d3
		mulu		d2,d3
.loop1		cmp.l		max_curx(a4),d0
		bls		.dont_adjust
		sub.w		d3,d0
		add.l		d2,offset(a4)
		bra		.loop1
.dont_adjust	move.l		d0,cur_x(a4)
		divu		font.width+2(a4),d1
		move.w		d1,start_col_num+2(a4)
		rts

;--------------	Print the line that contains cursor with 8 trailing spaces.

printcurline	lea		msg1(a4),a0
		lea		edit_buffer(a4),a1
		sub.l		#node.data,a1
		bsr		expand_text
		lea		msg1(a4),a0
		moveq.l		#$0,d0
.loop		cmp.b		(a0)+,d0
		bne.s		.loop
		subq.l		#1,a0
		move.l		a0,a3
		moveq.l		#7,d0
.loop1		move.b		#' ',(a0)+
		dbra		d0,.loop1
		move.b		#0,(a0)
		lea		msg1(a4),a0
		add.l		offset(a4),a0
		move.l		a0,curline.ptr
		
		move.l		max_num_chars(a4),d0  ** NEW **
		move.b		0(a0,d0),d4
		move.b		#0,0(a0,d0)
		
		lea		curline_text,a1	a1-->text structure
		move.l		window.rp(a4),a0	a0-->window rastport
		moveq.l		#5,d0		x position of text
		move.l		cur_y(a4),d1	y position of text
		CALLINT		PrintIText	print the text
		move.b		#0,(a3)
		
		move.l		curline.ptr,a0        ** NEW **
		move.l		max_num_chars(a4),d0
		move.b		d4,0(a0,d0)
		move.l		#0,offset(a4)
		
		rts

;--------------	Delete character behind cursor.

bckspc		tst.l		cur_pos(a4)
		beq.s		.done
		move.l		#1,changes(a4)
		move.l		#1,line_changes(a4)
		move.l		cur_line_len(a4),d0
		sub.l		cur_pos(a4),d0
		subq.l		#1,d0
		move.l		cur_addr(a4),a0
.loop		move.b		(a0),-1(a0)
		addq.l		#1,a0
		dbra		d0,.loop
		moveq.l		#1,d0
		sub.l		d0,cur_pos(a4)
		sub.l		d0,cur_addr(a4)
		sub.l		d0,cur_line_len(a4)
.done		moveq.l		#0,d2
		rts

;--------------	Delete character under cursor.

del		move.l		cur_addr(a4),a0
		cmp.b		#$0a,(a0)+
		beq		.done
		add.l		#1,cur_pos(a4)
		move.l		a0,cur_addr(a4)
		bsr		bckspc
.done		rts

;--------------	Add a line feed ( deal with RETURN keypress )

line_feed	bsr		insert_char
		move.l		cur_line_len(a4),d4
		move.l		cur_pos(a4),d0
		move.l		d0,cur_line_len(a4)
		sub.l		d0,d4
		bsr		chk_ln_changes
		move.l		cur_addr(a4),a0
		move.l		d4,d0
		bsr		add_node
		add.l		#1,num_lines(a4)
		move.l		#0,cur_pos(a4)
		move.l		#0,offset(a4)
		bsr		cursor_down
		bsr		refresh_display		not needed yet
		rts

;--------------	Add a character at cursor and move cursor on.

insert_char	move.l		cur_line_len(a4),d0
		cmp.b		#$ff,d0
		beq.s		.done
		move.l		#1,changes(a4)
		move.l		#1,line_changes(a4)
		lea		edit_buffer(a4),a0
		add.l		d0,a0
		sub.l		cur_pos(a4),d0
		subq.l		#1,d0
.loop		move.b		-1(a0),(a0)
		subq.l		#1,a0
		dbra		d0,.loop
		move.l		cur_addr(a4),a0
		move.b		d2,(a0)+
		move.l		a0,cur_addr(a4)
		addq.l		#1,cur_pos(a4)
		addq.l		#1,cur_line_len(a4)
.done		rts

;--------------	Move the cursor to the top of the file.

cursor_home	lea		start_list(a4),a0
		move.l		node.next(a0),a0
		move.l		a0,start_line(a4)
		move.l		a0,cur_line(a4)
		moveq.l		#0,d0
		move.l		d0,cur_pos(a4)
		move.b		node.len(a0),d0
		move.l		d0,cur_line_len(a4)
		moveq.l		#1,d0
		move.l		d0,start_line_num(a4)
		move.l		d0,cur_line_num(a4)
		bsr		line_to_buffer
		move.l		#5,cur_x(a4)
		move.l		#10,cur_y(a4)
		rts
		
;--------------	Move the cursor to the top of the screen

cursor_top	move.l		start_line(a4),a0
		move.l		a0,cur_line(a4)
		moveq.l		#0,d0
		move.l		d0,cur_pos(a4)
		move.b		node.len(a0),cur_line_len(a4)
		move.l		start_line_num(a4),cur_line_num(a4)
		bsr		line_to_buffer
		move.l		#5,cur_x(a4)
		move.l		#10,cur_y(a4)
		rts
		
;--------------	Move cursor up 1 line, scrolling if necessary.

cursor_up	bsr		chk_ln_changes
		move.l		#0,offset(a4)
		move.l		cur_y(a4),linenum(a4)
		bsr		printmsg
		move.l		cur_line_num(a4),d3
		subq.l		#1,d3
		beq.s		.done
		move.l		d3,cur_line_num(a4)
		move.l		cur_line(a4),a0
		move.l		node.prev(a0),a0
		move.l		a0,cur_line(a4)
		bsr		line_to_buffer
		sub.l		start_line_num(a4),d3
		bpl.s		.no_scroll
		bsr		scroll_down
		move.l		cur_y(a4),d0
		add.l		font.height(a4),d0
		move.l		d0,cur_y(a4)
		move.l		cur_line(a4),start_line(a4)
		move.l		cur_line_num(a4),start_line_num(a4)
.no_scroll	move.l		cur_y(a4),d0
		sub.l		font.height(a4),d0
		move.l		d0,cur_y(a4)
.done		rts

;--------------	Move the cursor down one line, scrolling if necessary.

cursor_down	bsr		chk_ln_changes
		move.l		#0,offset(a4)
		move.l		cur_y(a4),linenum(a4)
		bsr		printmsg
		move.l		cur_line_num(a4),d3
		cmp.l		num_lines(a4),d3
		beq.s		.done
		add.l		#1,d3
		move.l		d3,cur_line_num(a4)
		move.l		cur_line(a4),a0
		move.l		node.next(a0),cur_line(a4)
		bsr		line_to_buffer
		move.l		start_line_num(a4),d0
		add.l		scrn_size(a4),d0
		subq.l		#1,d0
		cmp.l		d3,d0
		bge.s		.no_scroll
		bsr		scroll_up
		move.l		cur_y(a4),d0
		sub.l		font.height(a4),d0
		move.l		d0,cur_y(a4)
		move.l		start_line(a4),a0		*BUG*
		move.l		node.next(a0),start_line(a4)
		add.l		#1,start_line_num(a4)
.no_scroll	move.l		cur_y(a4),d0
		add.l		font.height(a4),d0
		move.l		d0,cur_y(a4)
.done		rts

;--------------	Update text list if line has been alterd.

chk_ln_changes	tst.l		line_changes(a4)
		beq.s		.done
		move.l		cur_line(a4),node(a4)
		lea		edit_buffer(a4),a0
		move.l		cur_line_len(a4),d0
		bsr		add_node
		move.l		node(a4),a0
		move.l		a0,cur_line(a4)
		move.l		node.prev(a0),d0
		move.l		d0,node(a4)
		cmp.l		start_line(a4),d0
		bne.s		.ok
		move.l		a0,start_line(a4)
.ok		bsr		del_node
		move.l		#0,line_changes(a4)
.done		rts

;--------------	Copy line of text from list into edit buffer.

line_to_buffer	move.l		cur_line(a4),a0
		lea		edit_buffer(a4),a1
		moveq.l		#0,d0
		move.b		node.len(a0),d0
		move.l		d0,d1
		add.l		#node.data,a0
		subq.l		#1,d0
.loop		move.b		(a0)+,(a1)+
		dbra		d0,.loop
		move.l		d1,cur_line_len(a4)
		subq.l		#1,d1
		cmp.l		cur_pos(a4),d1
		bgt.s		.ok
		move.l		d1,cur_pos(a4)
.ok		lea		edit_buffer(a4),a0
		move.l		a0,cur_addr(a4)
		move.l		cur_pos(a4),d1
		add.l		d1,cur_addr(a4)
		rts

;--------------	Delete a line of text at the cursor
;		will not delete 1st or last line of a file.

del_line	cmpi.l		#1,cur_line_num(a4)
		beq		.dont_delete

		move.l		cur_line(a4),a5
		move.l		node.next(a5),a5
		tst.l		node.next(a5)
		beq		.dont_delete

		move.l		cur_line(a4),node(a4)
		bsr		del_node
		subq.l		#1,num_lines(a4)
		move.l		a5,cur_line(a4)
		move.l		#0,cur_pos(a4)
		move.l		#5,cur_x(a4)
		move.l		node.len(a5),cur_line_len(a4)
		move.l		#0,offset(a4)
		bsr		line_to_buffer
		bsr		refresh_display
.dont_delete	rts
