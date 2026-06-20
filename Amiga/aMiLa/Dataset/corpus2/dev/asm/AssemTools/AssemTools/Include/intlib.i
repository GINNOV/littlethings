;
;  intlib.i  intuition handler library
;  founded by tm 14.06.89
;  (c) 1989 supervisor
;

;  "getidcmp, initchrout, chrout" created 14.06.89 -> v1.0
;  "allocgad" created 15.06.89 -> v1.01
;  "gadborder, sborder" created 15.06.89 -> v1.02
;  "allocgad" - Got It Out to Work! 15.06.89 -> v1.03
;  "findgad, -w" created 15.06.89 -> v1.04
;  "request" gotten from jm (blaf) 15.06.89 -> v1.05
;  "getidcmp" debugt 16.06.89 -> v1.06
;  "gad" changed to "gg"; "AA, AR" added to "allocgad";
;  "findgad" debugt 16.06.89 -> v1.061
;  "chrcursor" added 22.06.89 -> v1.062
;  features added to "chrout" 25.06.89 -> v1.063
;  "allocmenu" created by JM 15..16.07.89 -> v1.1
;  "allocmenu" modified (rel.word, AA, AR added) 16.07.89 
;	-> v1.101 -> v1.103b
;  "getmenunum" created -> v1.104
;  -> v1.104b 07.08.89

*T
*T	INTLIB.I * Metacc Include File
*T		Version 1.104b
*T	        Date 07.08.89
*T
*B

;  getidcmp	(get a standard idcmp message)
;  in:		a0=*window; d0=flag /=0: wait, <>0 do not wait/;
;  call:	intlib	getidcmp;
;  out:		d0=class, d1=code, d2=qualifier;
;  		a0=iaddress, d3,d4=mousex,mousey;

;  request	(display an autorequester)
;  in:		a0=*window; a1=*texts; a2=*textattr (==0: deflt)
;  call:	intlib	request;
;  out:		d0=result; />0: true, =0: error, <0: false/

;  allocgg	(allocate and create a gadget structure chain)
;  in:		a0=*gadgetdata; a1=*strgad_bufr_base;
;  		a2=rel_base; a4=variable_base;
;  call:	intlib	allocgg;
;  out:		d0=a0=*firstgadget; /use execlib->free to free/
;  notes:	The gadgetdata list may contain elements
;		of the following form:
;		 type.w, x1.w, y1.w, sx.w, sy.w, userdata.l,
;		 specl.w
;		followed by "specl" bytes of additional data.
;		See "allocgg.doc" for documentation.

;  allocmenu	(allocate and create a menu structure chain)
;  in:		a0=*menudata; a1=*default_IntuiText;
;  		a2=rel_base; a4=variable_base;
;  call:	intlib	allocmenu;
;  out:		d0=a0=*menustrip; /use execlib->free to free/
;  notes:	The menudata list contains elements of the
;  		following form:
;  		 type.b, cmdkey.b, specl.w, [<special_data>],
;  		 name.str
;  		-NOTE-: Add a 'ds.w 0' after the name to word-
;  		align the rest of data.
;  		The <special_data> field contains "specl" bytes
;  		of additional data. See "allocmenu.doc" for
;  		documentation. "handler.i" contatins macros
;  		".menu, .item, .subitm" to facilitate use.

;  ggborder	(draw simple border to gadgets)
;  in:		a0=*gadgetdata; a1=*rport;
;  call:	intlib	ggborder;

;  findgg	(find a gadget by UserData)
;  in:		a0=*firstgadget; d0=userdata;
;  call:	intlib	findgg;
;  out:		a0=*gadget; /==0 if not found/

;  findggw	(find a gadget by a half of UserData)
;  in:		a0=*firstgadget; d0=(uword) userdata;
;  call:	intlib	findggw;
;  out:		a0=*gadget; /==0 if not found/

;  getmenunum	(convert a packed menu number)
;  in:		d0=packed;
;  call:	intlib	getmenunum;
;  out:		d0=menu, d1=item, d2=subitem;
;  notes:	All inputs/outputs uword (-1 returned 16
;		bits wide if parameter undefined)

;  sborder	(draw a simple border)
;  in:		d0,d1=x1,y1; d2,d3=sx,sy; a1=rport;
;  call:	intlib	sborder;

;  initchrout	(init a chrout structure)
;  in:		a0=*window; a1=*chrout;
;  call:	intlib	initchrout;

;  chrcursor	(set and read current cursor position)
;  in:		d0, d1=column, row; a1=*chrout;
;  call:	intlib	chrcursor;
;  out:		d0, d1=oldcolumn, oldrow;

;  chrout	(output text into a chrout)
;  in:		a0=*string; a1=*chrout;
;  call:	intlib	chrout;
;  notes:	Control codes are:
;		8   BS   Backspace. Cursor left
;		9   TAB  Tabulator (size 8 characters)
;		10  LF   Line feed
;		11  VT   Vertical tab. Cursor up
;		12  FF   Form feed (clearscreen)
;		13  CR   Carriage return
;		14  SO   Cursor on
;		15  SI   Cursor off
;		16  DLE  Scroll up one line
;		17  DC1  Scroll down one line
;		20  DC4  Clear to end of line
;		21  NAK  Insert character
;		22  SYN  Delete line at cursor
;		23  ETB  Insert line at cursor
;		24  CAN  Clear line at cursor and end of screen
;		25  EM   Cursor to nethermost line
;		26  SUB  Cursor home
;		28  FS   Cursor up. Scroll if out
;		29  GS   Cursor down. Scroll if out
;		30  RS   Cursor left
;		31  US   Cursor right
;		127 DEL  Delete character to right

*E

chrout_x	equ	0	;cursor pos.
chrout_y	equ	2
chrout_sx	equ	4	;size of window in chr pos's.
chrout_sy	equ	6
chrout_cx	equ	8	;character size
chrout_cy	equ	10
chrout_ox	equ	12	;offset from borders
chrout_oy	equ	14
chrout_rport	equ	16
chrout_backg	equ	20
chrout_foreg	equ	22
chrout_baseline	equ	24
chrout_cursor	equ	26
chrout_window	equ	28
chrout_pad	equ	32	;future expansion
chrout_idcmper	equ	36	;idcmp handler
chrout_SIZEOF	equ	40


intlib		macro
		ifnc	'\1',''
_INTF\1		set	1
		bsr	_INT\1
		mexit
		endc

		ifd	_INTFrequest
_INTrequest	push	d1-d7/a0-a6
		move.l	a0,d7			window*
		move.l	a1,d3			text*
		move.l	a2,d2			font*
		move.l	#it_SIZEOF*6,d0
		move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
		lib	Exec,AllocMem
		move.l	d0,d6			mem*
		beq	102$			-> no memory
		move.l	d3,a0			ASCII text*
		move.l	d6,a1			first IText*
		lea.l	201$(pc),a2		coordinate table
		moveq.l	#4,d0			#of structs
2$		move.l	a0,it_IText(a1)		save first text*
		move.l	d2,it_ITextFont(a1)	set font
		move.b	#RP_JAM1,it_DrawMode(a1)
		move.b	(a2)+,it_LeftEdge+1(a1)	set x
		move.b	(a2)+,it_TopEdge+1(a1)	set y
1$		tst.b	(a0)+			get next string*
		bne.s	1$
		lea.l	it_SIZEOF(a1),a1	next it*
		dbf	d0,2$
		move.l	d6,a0
		lea.l	it_SIZEOF(a0),a1	next*
		move.l	a1,it_NextText(a0)
		lea.l	it_SIZEOF(a1),a0	next*
		move.l	a0,it_NextText(a1)
		move.l	d7,a0
		move.l	d6,a1			bodytext
		lea.l	it_SIZEOF*3(a1),a2	positext
		lea.l	it_SIZEOF*4(a1),a3	negatext
		move.l	it_IText(a2),a6		text*
		tst.b	(a6)
		bne.s	6$			if no POSITEXT no gg needed
		sub.l	a2,a2
6$		push	a0/a1
		move.l	d6,a0
		lib	Intuition,IntuiTextLength
		moveq.l	#40,d2
		add.l	d0,d2			width
		pull	a0/a1
		moveq.l	#72,d3			height
		moveq.l	#0,d0			posiflags
		moveq.l	#0,d1			negaflags
		flib	Intuition,AutoRequest
		tst.l	d0
		bne.s	10$
		moveq.l	#-1,d7		false
		bra.s	11$
10$		moveq.l	#1,d7		true
11$		move.l	d6,a1
		move.l	#it_SIZEOF*6,d0
		lib	Exec,FreeMem
		move.l	d7,d0
		bra.s	101$
201$		dc.b	9,5,9,15,9,25,6,3,6,3
102$		moveq.l	#0,d0
101$		pull	d1-d7/a0-a6
		tst.l	d0
		rts
		endc

		ifd	_INTFggborder
_INTggborder	push	a0-a3/d0-d4
		move.l	a0,a2
		move.l	a1,a3
_INTggborder1	move.w	(a2),d4
		beq.s	_INTggborder0
		move.w	2(a2),d0
		move.w	4(a2),d1
		move.w	6(a2),d2
		move.w	8(a2),d3
		subq.w	#1,d0
		subq.w	#1,d1
		addq.w	#1,d2
		addq.w	#1,d3
		move.l	a3,a1
		intlib	sborder
		lea.l	14(a2),a2
		add.w	(a2)+,a2
		bra.s	_INTggborder1
_INTggborder0	pull	a0-a3/d0-d4
		rts
		endc

		ifd	_INTFsborder
_INTsborder	push	d0-d5/a0-a2
		add.w	d0,d2
		add.w	d1,d3
		move.l	a1,a2
		move.w	d0,d4
		move.w	d1,d5
		lib	Gfx,Move
		move.w	d4,d0
		move.w	d3,d1
		move.l	a2,a1
		flib	Gfx,Draw
		move.w	d2,d0
		move.w	d3,d1
		move.l	a2,a1
		flib	Gfx,Draw
		move.w	d2,d0
		move.w	d5,d1
		move.l	a2,a1
		flib	Gfx,Draw
		move.w	d4,d0
		move.w	d5,d1
		move.l	a2,a1
		flib	Gfx,Draw
		pull	d0-d5/a0-a2
		rts
		endc

		ifd	_INTFfindgg
_INTfindgg1	move.l	(a0),a0
_INTfindgg	cmp.l	40(a0),d0
		beq.s	_INTfindgg0
		tst.l	(a0)
		bne.s	_INTfindgg1
		sub.l	a0,a0
_INTfindgg0	rts
		endc

		ifd	_INTFfindggw
_INTfindggw1	move.l	(a0),a0
_INTfindggw	cmp.w	40(a0),d0
		beq.s	_INTfindggw0
		tst.l	(a0)
		bne.s	_INTfindggw1
		sub.l	a0,a0
_INTfindggw0	rts
		endc

		ifd	_INTFgetmenunum
_INTgetmenunum	move.w	d0,d1
		move.w	d0,d2
		and.w	#$1f,d0
		lsr.w	#5,d1
		and.w	#$3f,d1
		rol.w	#5,d2
		and.w	#$1f,d2
		cmp.w	#$1f,d0
		bne.s	1$
		moveq	#-1,d0
1$		cmp.w	#$3f,d1
		bne.s	2$
		moveq	#-1,d1
2$		cmp.w	#$1f,d2
		bne.s	3$
		moveq	#-1,d2
3$		tst.w	d0
		rts
		endc

		ifd	_INTFallocgg
_INTallocgg	push	a1-a5/d1-d7
		move.l	a2,d6	;rel.base
		move.l	a0,a2	;data
		move.l	a1,d7	;strbuf.base
		moveq	#0,d2
_INTallocgg1	move.w	(a0),d1
		beq.s	_INTallocgg2
		lea.l	14(a0),a0
		add.w	(a0)+,a0
		bsr	_INTallocgg.s
		add.l	d0,d2
		bra.s	_INTallocgg1
_INTallocgg2	addq.w	#4,d2
		move.l	d2,d0
		moveq	#1,d1
		lib	Exec,AllocMem
		move.l	d0,a3
		tst.l	d0
		beq	_INTallocgg0
		move.l	d2,(a3)+
		move.l	a3,a0
_INTallocgg3	move.w	(a2),d1
		beq	_INTallocgg0
		bsr	_INTallocgg.s
		add.l	a0,d0
		lea.l	14(a2),a1
		add.w	(a1)+,a1
		tst.w	(a1)
		bne.s	_INTallocgg3b
		moveq	#0,d0
_INTallocgg3b	move.l	a0,a5
		move.l	d0,(a0)+		;next
		move.l	2(a2),(a0)+		;co-ordinates
		move.l	6(a2),(a0)+		;size
		move.w	#GADGHCOMP,(a0)+	;flags
		move.w	#RELVERIFY,(a0)+	;activation
		moveq	#0,d2
		cmp.w	#BOOLGADGET,d1
		beq.s	_INTallocgg3c
		lea.l	44(a5),a1
		move.l	a1,d2
_INTallocgg3c	move.w	d1,(a0)+		;type
		clr.l	(a0)+			;render
		clr.l	(a0)+			;selrender
		clr.l	(a0)+			;text
		clr.l	(a0)+			;mutual excl
		move.l	d2,(a0)+		;specialinfo
		clr.w	(a0)+			;id
		move.l	10(a2),(a0)+		;userdata
		lea.l	14(a2),a2
		cmp.w	#BOOLGADGET,d1		;bool gad:
		beq.s	_INTallocgg3e		;no specinfo
		moveq	#8,d0
_INTallocgg3d	clr.l	(a0)+			;9 longs of wisp
		dbf	d0,_INTallocgg3d
		cmp.w	#STRGADGET,d1		;str gad:
		beq.s	_INTallocgg3e		;specinfo 36 byt
		clr.l	(a0)+
		clr.w	(a0)+
		lea.l	66(a5),a1
		move.l	a1,18(a5)		;set propptr
_INTallocgg3e	move.w	(a2)+,d0
_INTallocgg3f	tst.w	d0
		ble	_INTallocgg3
		move.w	(a2)+,d1
		subq.w	#2,d0
		lea.l	_INTallocgg.t1(pc),a1
		moveq	#-2,d2
_INTallocgg3g	addq.w	#2,d2
		tst.w	(a1)
		beq.s	_INTallocgg3f
		cmp.w	(a1)+,d1
		bne.s	_INTallocgg3g
		lea.l	_INTallocgg.t2(pc),a1
		move.b	0(a1,d2.w),d1
		move.b	1(a1,d2.w),d2
		ext.w	d2
		tst.b	d1
		beq.s	_INTallocgg3w
		cmp.b	#1,d1
		beq.s	_INTallocgg3l
		cmp.b	#3,d1
		beq.s	_INTallocgg3r
		cmp.b	#4,d1
		beq.s	_INTallocgg3t
		subq.w	#4,d0		;rel.long *
		move.l	(a2)+,d1
		add.l	d6,d1
		move.l	d1,0(a5,d2.w)
		bra.s	_INTallocgg3f
_INTallocgg3w	subq.w	#2,d0		;word *
		move.w	(a2)+,0(a5,d2.w)
		bra.s	_INTallocgg3f
_INTallocgg3l	subq.w	#4,d0		;long *
		move.l	(a2)+,0(a5,d2.w)
		bra.s	_INTallocgg3f
_INTallocgg3r	subq.w	#2,d0		;bufferptr
		move.w	(a2)+,d1
		ext.l	d1
		add.l	d7,d1
		move.l	d1,0(a5,d2.w)
		bra	_INTallocgg3f
_INTallocgg3t	tst.b	d2
		bpl.s	_INTallocgg3u	;rel. baseaddr.w
		subq.w	#2,d0
		move.w	(a2)+,d1
		move.l	a5,0(a4,d1.w)
		bra	_INTallocgg3f
_INTallocgg3u	subq.w	#4,d0		;abs. baseaddr.l
		move.l	(a2)+,a1
		move.l	a5,(a1)
		bra	_INTallocgg3f
_INTallocgg.s	moveq.l	#44,d0			;gadget_SO
		cmp.w	#BOOLGADGET,d1
		beq.s	_INTallocgg.s1
		add.w	#36,d0			;stringinfo_SO
		cmp.w	#STRGADGET,d1
		beq.s	_INTallocgg.s1
		addq.w	#6,d0			;prop needs 42
_INTallocgg.s1	rts
_INTallocgg0	move.l	a3,a0
		move.l	a0,d0
		pull	a1-a5/d1-d7
		rts
_INTallocgg.t1	dc.b	'GFGAGRGSGTGMGIGU'
		dc.b	'PFPHPVPhPvSBSUSP'
		dc.b	'SMSDAAAR',0,0
_INTallocgg.t2	dc.b	0,12,0,14,2,18,2,22,2,26,1,30,0,38,1,40
		dc.b	0,44,0,46,0,48,0,50,0,52,3,44,3,48,0,52
		dc.b	0,54,0,56,4,1,4,-1
		endc

		ifd	_INTFgetidcmp
_INTgetidcmp	push	d5-d7/a1-a2
		move.l	d0,d7		;0=wait
		move.l	86(a0),a2	;wd_userport
_INTgetidcmp1	move.l	a2,a0
		lib	Exec,GetMsg
		tst.l	d0
		bne.s	_INTgetidcmp2
		tst.l	d7
		bne.s	_INTgetidcmp0
		moveq.l	#0,d1
		move.b	15(a2),d1
		moveq.l	#0,d0
		bset.l	d1,d0
		lib	Exec,Wait
		bra.s	_INTgetidcmp1
_INTgetidcmp2	move.l	d0,a1
		move.l	im_Class(a1),d0
		move.w	im_Code(a1),d1
		move.w	im_Qualifier(a1),d2
		move.l	im_IAddress(a1),a0
		move.w	im_MouseX(a1),d3
		move.w	im_MouseY(a1),d4
		ext.l	d1
		ext.l	d2
		ext.l	d3
		ext.l	d4
		push	a0/d0-d4
		lib	Exec,ReplyMsg
		pull	a0/d0-d4
_INTgetidcmp.x	pull	d5-d7/a1-a2
		rts
_INTgetidcmp0	moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		sub.l	a0,a0
		bra.s	_INTgetidcmp.x
		endc

		ifd	_INTFchrout
_INTchrout	push	all
		move.l	a1,a2
		lea.l	-1(a0),a5
		bsr	_INTchroutcur
_INTchrout1	addq.w	#1,a5
_INTchrout1b	move.b	(a5),d0
		cmp.b	#32,d0
		blo	_INTchroutnp
		move.l	a5,a0
		move.w	chrout_x(a2),d1
_INTchrout2	addq.w	#1,a5
		addq.w	#1,d1
		move.b	(a5),d0
		cmp.b	#32,d0
		blo.s	_INTchrout3
		cmp.w	chrout_sx(a2),d1
		blo.s	_INTchrout2
_INTchrout3	push	d1/a0
		move.w	chrout_x(a2),d0
		mulu.w	chrout_cx(a2),d0
		add.w	chrout_ox(a2),d0
		move.w	chrout_y(a2),d1
		mulu.w	chrout_cy(a2),d1
		add.w	chrout_oy(a2),d1
		add.w	chrout_baseline(a2),d1
		move.l	chrout_rport(a2),a1
		lib	Gfx,Move
		move.l	chrout_rport(a2),a1
		move.w	chrout_backg(a2),d0
		flib	Gfx,SetBPen
		move.l	chrout_rport(a2),a1
		move.w	chrout_foreg(a2),d0
		flib	Gfx,SetAPen
		pull	d1/a0
		move.l	chrout_rport(a2),a1
		move.w	d1,d0
		move.w	d1,d2
		sub.w	chrout_x(a2),d0
		flib	Gfx,Text
		move.w	d2,chrout_x(a2)
		cmp.w	chrout_sx(a2),d2
		blo	_INTchrout1b
		subq.w	#1,a5
_INTchroutlf	clr.w	chrout_x(a2)
_INTchroutcd	addq.w	#1,chrout_y(a2)
		move.w	chrout_y(a2),d0
		cmp.w	chrout_sy(a2),d0
		blo	_INTchrout1
		subq.w	#1,chrout_y(a2)
_INTchroutsc	move.l	chrout_rport(a2),a1
		move.w	chrout_backg(a2),d0
		lib	Gfx,SetBPen
		bsr.s	_INTchroutcss
		bsr.s	_INTchroutpts
		flib	Gfx,ScrollRaster
		bra	_INTchrout1
_INTchroutyy	move.l	chrout_rport(a2),a1
		move.w	chrout_backg(a2),d0
		lib	Gfx,SetBPen
		bsr.s	_INTchroutcss
		bsr.s	_INTchroutpts
		neg.w	d1
		flib	Gfx,ScrollRaster
		bra	_INTchrout1
_INTchroutpts	move.w	d3,d5
		move.w	d2,d4
		move.w	d1,d3
		move.w	d0,d2
		move.w	chrout_cy(a2),d1
		moveq	#0,d0
		move.l	chrout_rport(a2),a1
		rts
_INTchroutocr	clr.w	chrout_x(a2)
		bra	_INTchrout1
_INTchroutcss	move.w	chrout_ox(a2),d0
		move.w	chrout_oy(a2),d1
		move.w	chrout_sx(a2),d2
		move.w	chrout_sy(a2),d3
		mulu.w	chrout_cx(a2),d2
		mulu.w	chrout_cy(a2),d3
		add.w	d0,d2
		add.w	d1,d3
		subq.w	#1,d2
		subq.w	#1,d3
		rts
_INTchroutcs	move.l	chrout_rport(a2),a1
		move.w	chrout_backg(a2),d0
		lib	Gfx,SetAPen
		bsr.s	_INTchroutcss
		flib	Gfx,RectFill
_INTchroutch	clr.w	chrout_x(a2)
		clr.w	chrout_y(a2)
		bra	_INTchrout1
_INTchroutcl	subq.w	#1,chrout_x(a2)
		bpl	_INTchrout1
		move.w	chrout_sx(a2),d0
		subq.w	#1,d0
		move.w	d0,chrout_x(a2)
_INTchroutcu	tst.w	chrout_y(a2)
		beq	_INTchroutyy
		subq.w	#1,chrout_y(a2)
		bra	_INTchrout1
_INTchroutcr	addq.w	#1,chrout_x(a2)
		move.w	chrout_x(a2),d0
_INTchroutqr	cmp.w	chrout_sx(a2),d0
		bhs	_INTchroutlf
		bra	_INTchrout1
_INTchrouttab	move.w	chrout_x(a2),d0
		addq.w	#8,d0
		and.b	#$f8,d0
		move.w	d0,chrout_x(a2)
		bra	_INTchroutqr
_INTchroutnp	tst.b	d0
		beq	_INTchroutxx
		lea.l	_INTchrout.t1(pc),a1
		moveq	#-2,d1
_INTchroutnp1	addq.w	#2,d1
		tst.b	(a1)
		beq	_INTchrout1
		cmp.b	(a1)+,d0
		bne.s	_INTchroutnp1
		lea.l	_INTchrout.t2(pc),a1
		add.w	d1,a1
		move.l	a1,a0
		add.w	(a1),a0
		jmp	(a0)
_INTchrout.t1	dc.b	10,13,8,9,12,11,28,29,30,31
		dc.b	26,16,14,15,17,25,20,127,21
		dc.b	22,23,24,0
		ds.w	0
_INTchrout.t2	dc.w	_INTchroutlf-*
		dc.w	_INTchroutocr-*
		dc.w	_INTchroutcl-*
		dc.w	_INTchrouttab-*
		dc.w	_INTchroutcs-*
		dc.w	_INTchroutcu-*
		dc.w	_INTchroutcu-*
		dc.w	_INTchroutcd-*
		dc.w	_INTchroutcl-*
		dc.w	_INTchroutcr-*
		dc.w	_INTchroutch-*
		dc.w	_INTchroutsc-*
		dc.w	_INTchroutsi-*
		dc.w	_INTchroutsi-*
		dc.w	_INTchroutyy-*
		dc.w	_INTchroutnml-*
		dc.w	_INTchrouteol-*
		dc.w	_INTchroutdel-*
		dc.w	_INTchroutins-*
		dc.w	_INTchroutdll-*
		dc.w	_INTchroutinl-*
		dc.w	_INTchrouteos-*
_INTchroutcas	move.w	chrout_x(a2),d0
		move.w	chrout_y(a2),d1
		mulu.w	chrout_cx(a2),d0
		mulu.w	chrout_cy(a2),d1
		move.w	chrout_sx(a2),d2
		mulu.w	chrout_cx(a2),d2
		subq.w	#1,d2
		move.w	d1,d3
		add.w	chrout_cy(a2),d3
_INTchroutcas1	subq.w	#1,d3
		add.w	chrout_ox(a2),d0
		add.w	chrout_oy(a2),d1
		add.w	chrout_ox(a2),d2
		add.w	chrout_oy(a2),d3
		rts
_INTchroutcrs	moveq	#0,d0
		move.w	chrout_y(a4),d1
		mulu.w	chrout_cy(a4),d1
		move.w	chrout_sx(a4),d2
		mulu.w	chrout_cx(a4),d2
		subq.w	#1,d2
		move.w	chrout_sy(a4),d3
		mulu.w	chrout_cy(a4),d3
		bra.s	_INTchroutcas1
_INTchroutnml	move.w	chrout_sy(a2),d0
		subq.w	#1,d0
		move.w	d0,chrout_y(a2)
		bra	_INTchrout1
_INTchrouteol	move.w	chrout_backg(a2),d0
		move.l	chrout_rport(a2),a1
		lib	Gfx,SetAPen
		bsr	_INTchroutcas
		move.l	chrout_rport(a2),a1
		flib	Gfx,RectFill
		bra	_INTchrout1
_INTchroutdel	move.w	chrout_backg(a2),d0
		move.l	chrout_rport(a2),a1
		lib	Gfx,SetBPen
		bsr	_INTchroutcas
		bsr	_INTchroutpts
		moveq	#0,d1
		move.w	chrout_cx(a2),d0
		flib	Gfx,ScrollRaster
		bra	_INTchrout1
_INTchroutins	move.w	chrout_backg(a2),d0
		move.l	chrout_rport(a2),a1
		lib	Gfx,SetBPen
		bsr	_INTchroutcas
		bsr	_INTchroutpts
		moveq	#0,d1
		move.w	chrout_cx(a2),d0
		neg.w	d0
		flib	Gfx,ScrollRaster
		bra	_INTchrout1
_INTchroutdll	move.w	chrout_backg(a2),d0
		move.l	chrout_rport(a2),a1
		lib	Gfx,SetBPen
		bsr	_INTchroutcrs
		bsr	_INTchroutpts
		flib	Gfx,ScrollRaster
		bra	_INTchrout1
_INTchroutinl	move.w	chrout_backg(a2),d0
		move.l	chrout_rport(a2),a1
		lib	Gfx,SetBPen
		bsr	_INTchroutcrs
		bsr	_INTchroutpts
		neg.w	d1
		flib	Gfx,ScrollRaster
		bra	_INTchrout1
_INTchrouteos	move.w	chrout_backg(a2),d0
		move.l	chrout_rport(a2),a1
		lib	Gfx,SetAPen
		bsr	_INTchroutcrs
		flib	Gfx,RectFill
		bra	_INTchrout1
_INTchroutcur	tst.w	chrout_cursor(a2)
		bne.s	_INTchroutcur1
		move.l	chrout_rport(a2),a1
		moveq	#0,d7
		move.b	28(a1),d7
		moveq	#2,d0		;complement
		lib	Gfx,SetDrMd
		move.w	chrout_x(a2),d0
		move.w	chrout_y(a2),d1
		mulu.w	chrout_cx(a2),d0
		mulu.w	chrout_cy(a2),d1
		add.w	chrout_ox(a2),d0
		add.w	chrout_oy(a2),d1
		move.w	d0,d2
		move.w	d1,d3
		add.w	chrout_cx(a2),d2
		add.w	chrout_cy(a2),d3
		subq.w	#1,d2
		subq.w	#1,d3
		move.l	chrout_rport(a2),a1
		flib	Gfx,RectFill
		move.l	chrout_rport(a2),a1
		move.w	d7,d0
		flib	Gfx,SetDrMd
_INTchroutcur1	rts
_INTchroutsi	and.w	#1,d0
		move.w	d0,chrout_cursor(a2)
		bra	_INTchrout1
_INTchroutxx	bsr	_INTchroutcur
		pull	all
		rts
		endc

		ifd	_INTFchrcursor
_INTchrcursor	cmp.w	chrout_sx(a1),d0
		bhs.s	_INTchrcursor1
		move.w	d0,chrout_x(a1)
_INTchrcursor1	cmp.w	chrout_sy(a1),d1
		bhs.s	_INTchrcursor2
		move.w	d1,chrout_y(a1)
_INTchrcursor2	move.w	chrout_x(a1),d0
		ext.l	d0
		move.w	chrout_y(a1),a1
		ext.l	d1
		rts
		endc

		ifd	_INTFinitchrout
_INTinitchrout	push	all
		move.l	50(a0),a2
		clr.l	chrout_x(a1)
		move.l	a0,chrout_window(a1)
		move.w	58(a2),chrout_cy(a1)
		move.w	60(a2),chrout_cx(a1)
		move.w	#4,chrout_ox(a1)
		move.w	#12,chrout_oy(a1)
		move.l	a2,chrout_rport(a1)
		move.w	#1,chrout_foreg(a1)
		clr.w	chrout_backg(a1)
		move.w	62(a2),chrout_baseline(a1)
		move.w	#-1,chrout_cursor(a1)
		move.w	8(a0),d0
		subq.w	#8,d0
		ext.l	d0
		divs.w	8(a1),d0
		move.w	d0,chrout_sx(a1)
		move.w	10(a0),d0
		sub.w	#16,d0
		ext.l	d0
		divs.w	10(a1),d0
		move.w	d0,chrout_sy(a1)
		clr.l	chrout_idcmper(a1)
		clr.l	chrout_pad(a1)
		pull	all
		rts
		endc

		ifd	_INTFallocmenu

_INTalmnmem	set	-4	;internal structure
_INTalmntxtattr	set	-8
_INTalmnmuad	set	-12
_INTalmnmiad	set	-16
_INTalmnsavea4	set	-20
_INTalmnsource	set	-24
_INTalmnlwid	set	-26
_INTalmna2base	set	-30
_INTalmna4base	set	-34
_INTalmnitext	set	-38
_INTalmnlswid	set	-40
_INTalmnmex	set	-42
_INTalmnity	set	-44
_INTalmnfohei	set	-46

_INTallocmenu	push	a1-a4/a6/d1-d7	*a0=cmd string; a1=IntuiText (sample)
		link	a5,#_INTalmnfohei
		move.l	a0,_INTalmnsource(a5)
		move.l	a1,_INTalmnitext(a5)
		move.l	it_ITextFont(a1),_INTalmntxtattr(a5)
		clr.l	_INTalmnmem(a5)
		move.l	_INTalmntxtattr(a5),d0
		beq.s	1$
		move.l	d0,a2
		move.w	ta_YSize(a2),d0
		bra.s	2$
1$		moveq	#10,d0
2$		move.w	d0,_INTalmnfohei(a5)	set font height
		bsr	_INTalmn_len
		addq.l	#4,d0
		move.l	d0,d2
		move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
		lib	Exec,AllocMem
		tst.l	d0
		beq	_INTalmn_e
		move.l	d0,a0			bufptr
		move.l	d2,(a0)+
		move.l	a0,_INTalmnmem(a5)

		move.l	_INTalmnsource(a5),a0
		move.l	_INTalmnmem(a5),a1
		move.w	#5,_INTalmnmex(a5)	x-coord
		clr.l	_INTalmnmuad(a5)	reset menu struct pointer

* MAIN LOOP
100$		move.b	(a0)+,d0
		beq	_INTalmn_x
		cmp.b	#1,d0
		bne	200$


* PROCESS A MENU STRUCTURE

		addq.l	#1,a0			skip command key
		clr.l	_INTalmnmiad(a5)	reset menu struct pointer
		move.w	#1,_INTalmnity(a5)	first item y-coord
		move.l	_INTalmnmuad(a5),d0
		beq.s	10$
		move.l	d0,a2
		move.l	a1,mu_NextMenu(a2)	set pointer to this menu

10$		move.l	a1,_INTalmnmuad(a5)	start of this Menu
		move.w	_INTalmnmex(a5),mu_LeftEdge(a1)	mu_LeftEdge
		clr.w	mu_TopEdge(a1)		mu_TopEdge

		move.w	#11,mu_Height(a1)	mu_Height
		move.w	#MENUENABLED,mu_Flags(a1) mu_Flags
		move.l	_INTalmnmuad(a5),a2
		add.w	#mu_SIZEOF,a2
		move.l	a2,mu_FirstItem(a1)	mu_FirstItem

		move.w	(a0)+,d2
101$		tst.w	d2
		ble.s	110$			-> no special data
		lea	_INTalmnmuspec(pc),a2
102$		move.w	(a0)+,d0
		subq.w	#2,d2			decr special length
103$		move.w	(a2)+,d1		end of table?
		beq.s	101$			-> get next spec cmd
		cmp.w	d0,d1
		bne.s	103$
		lea	(_INTalmnmusidcs-_INTalmnmuspec-2)(a2),a2
		moveq	#0,d0
		move.b	(a2)+,d0		get offset
		move.b	(a2)+,d1		get type (not unused any more)
		bne.s	104$
		move.w	(a0)+,d1		get special data
		subq.w	#2,d2
		move.w	d1,0(a1,d0.w)		put special info
		bra.s	101$			get next spec data
104$		move.w	(a0)+,d1		get special data
		subq.w	#2,d2
		add.w	d1,0(a1,d0.w)		add special info (relative)
		bra.s	101$

* PROCESS MenuName

110$		move.l	_INTalmnmuad(a5),a2		get menu  address
		move.l	a0,mu_MenuName(a2)		set menuname  ptr
		push	a0-a2/d1			save the rgisters
		lea	mu_SIZEOF(a1),a2		temp space for IT
		move.l	a0,it_IText(a2)			set string pointr
		move.l	a2,a0				set IntuiText ptr
		lib	Intuition,IntuiTextLength	call IntuiTextLen
		clr.l	it_IText(a2)			clear  work  area
		pull	a0-a2/d1			restore registers
		addq.w	#8,d0				greatr box
		move.w	d0,mu_Width(a2)			store menu  width
		add.w	#16,d0				space betw. menus
		add.w	d0,_INTalmnmex(a5)		incr menu x coord
		bsr	_INTalmn_skne			skip name & align
		lea	mu_SIZEOF(a1),a1
		bra	100$


200$		cmp.b	#2,d0
		bne.s	300$

* PROCESS MENU ITEM

		move.l	_INTalmnmiad(a5),d0
		beq.s	20$
		move.l	d0,a2
		move.l	a1,mi_NextItem(a2)		set pointer to this item

20$		move.l	a1,_INTalmnmiad(a5)		start of this Item
		move.w	_INTalmnity(a5),mi_TopEdge(a1)
		move.w	_INTalmnlwid(a5),mi_Width(a1)
		move.w	_INTalmnfohei(a5),mi_Height(a1)
		move.w	#ITEMTEXT!ITEMENABLED!HIGHCOMP,d0
		tst.b	(a0)
		beq.s	23$
		or.w	#COMMSEQ,d0
23$		move.w	d0,mi_Flags(a1)
		move.b	(a0)+,mi_Command(a1)
		lea	mi_SIZEOF(a1),a2
		move.l	a2,mi_ItemFill(a1)

		bsr	_INTalmn_goops			copy IntuiText

		bsr	_INTalmn_hspec			process special information

		move.l	a0,(it_IText+mi_SIZEOF)(a1)	set string address
		move.w	mi_Width(a1),_INTalmnlwid(a5)	get real width
		move.w	mi_TopEdge(a1),d0
		add.w	_INTalmnfohei(a5),d0
		move.w	d0,_INTalmnity(a5)		get real Ycoord
		move.w	mi_Width(a1),_INTalmnlswid(a5)	set subitem width
		lea	(mi_SIZEOF+it_SIZEOF)(a1),a1
		bsr	_INTalmn_skne			skip name and align
		bra	100$


* PROCESS SUBITEM

300$		moveq.l	#2,d4				reset SubItem Y
		move.l	_INTalmnmiad(a5),a2		get adr of Item
		move.l	a1,mi_SubItem(a2)		set subitem ptr
399$		move.w	_INTalmnfohei(a5),mi_Height(a1)	set subm Y size
		move.w	d4,mi_TopEdge(a1)		set sub Y coord
		move.w	_INTalmnlswid(a5),mi_Width(a1)	set subm X size
		move.w	_INTalmnlwid(a5),d0		get Xsz of Item 
		subq.w	#8,d0				decr. RightEdge
		move.w	d0,mi_LeftEdge(a1)		set sub X coord

		move.w	#ITEMTEXT!ITEMENABLED!HIGHCOMP,d0
		tst.b	(a0)				see  if COMMSEQ
		beq.s	33$				no, dont set it
		or.w	#COMMSEQ,d0			yes,  set  flag
33$		move.w	d0,mi_Flags(a1)			set  sub  Flags
		move.b	(a0)+,mi_Command(a1)		set command key
		lea	mi_SIZEOF(a1),a2		get end of SItm
		move.l	a2,mi_ItemFill(a1)		store IText ptr
		bsr	_INTalmn_goops			copy  IntuiText
		bsr	_INTalmn_hspec			sets spec. info

		move.l	a0,(it_IText+mi_SIZEOF)(a1)	set sub nameptr
		move.w	mi_TopEdge(a1),d4		get real Ycoord
		add.w	_INTalmnfohei(a5),d4		add font height
		move.w	mi_Width(a1),_INTalmnlswid(a5)	get real  width
		lea	(mi_SIZEOF+it_SIZEOF)(a1),a1	update dest ptr
		bsr	_INTalmn_skne			skip name&align
		cmpi.b	#3,(a0)+			another subitm?
		bne.s	310$				no jump to main
		move.l	a1,-(mi_SIZEOF+it_SIZEOF)(a1)	set next subptr
		bra	399$				handle next sub
310$		subq.l	#1,a0				back to type id
		bra	100$				return to  main


_INTalmn_x	move.l	_INTalmnmem(a5),d0
		move.l	d0,a0
		unlk	a5
		pull	a1-a4/a6/d1-d7
		rts

_INTalmn_e	moveq	#0,d0
		move.l	d0,a0
		unlk	a5
		pull	a1-a4/a6/d1-d7
		rts


_INTalmn_tab	dc.w	0,mu_SIZEOF,mi_SIZEOF+it_SIZEOF,mi_SIZEOF+it_SIZEOF
_INTalmn_len	push	a0-a1/d1
		sub.l	a1,a1
100$		moveq	#0,d0
		move.b	(a0)+,d0
		beq.s	_INTalmn_len_x
		add.w	d0,d0
		add.w	_INTalmn_tab(pc,d0.w),a1 add length
		addq.l	#1,a0			skip cmd key
		add.w	(a0)+,a0		skip special data
101$		tst.b	(a0)+			skip name
		bne.s	101$
		addq.l	#1,a0
		move.l	a0,d1
		and.w	#$fffe,d1
		move.l	d1,a0
		bra.s	100$			process next menu
_INTalmn_len_x	move.l	a1,d0
		addq.l	#8,d0			for safety
		pull	a0-a1/d1
		rts


_INTalmn_goops	move.l	_INTalmnitext(a5),a2
		move.b	it_FrontPen(a2),(it_FrontPen+mi_SIZEOF)(a1)
		move.b	it_BackPen(a2),(it_BackPen+mi_SIZEOF)(a1)
		move.b	it_DrawMode(a2),(it_DrawMode+mi_SIZEOF)(a1)
		move.w	it_LeftEdge(a2),(it_LeftEdge+mi_SIZEOF)(a1)
		move.w	it_TopEdge(a2),(it_TopEdge+mi_SIZEOF)(a1)
		move.l	it_ITextFont(a2),(it_ITextFont+mi_SIZEOF)(a1)
		rts


_INTalmn_skne	tst.b	(a0)+
		bne.s	_INTalmn_skne
		move.l	a0,d0
		addq.l	#1,d0
		and.w	#$fffe,d0
		move.l	d0,a0
		rts


* HANDLE SPECIAL COMMANDS FOR ITEM AND SUBITEM

_INTalmn_hspec	move.w	(a0)+,d2
701$		tst.w	d2
		ble.s	750$			-> no special data
		lea	_INTalmnmispec(pc),a2
702$		move.w	(a0)+,d0
		subq.w	#2,d2			decr special length
703$		move.w	(a2)+,d1		end of table?
		beq.s	701$			-> get next spec cmd
		cmp.w	d0,d1
		bne.s	703$
		lea	(_INTalmnmisidcs-_INTalmnmispec-2)(a2),a2
		moveq	#0,d0
		move.b	(a2)+,d0		get offset
		move.b	(a2)+,d1		get type
		bne.s	710$
		move.w	(a0)+,d1		get special data
		subq.w	#2,d2
		move.w	d1,0(a1,d0.w)		put special info
		bra.s	701$			get next spec data
710$		cmp.b	#1,d1
		bne.s	720$
		move.l	(a0)+,d1		get special data
		subq.w	#4,d2
		move.l	d1,0(a1,d0.w)		put special info
		bra.s	701$			get next spec data
720$		cmp.b	#2,d1
		bne.s	730$
		move.l	(a0)+,d1		get special data
		subq.w	#4,d2
		add.l	_INTalmna2base(a5),d1
		move.l	d1,0(a1,d0.w)		put special info
		bra.s	701$			get next spec data
730$		cmp.b	#3,d1
		bne.s	751$
		tst.b	d0
		bne.s	740$
		move.l	_INTalmna4base(a5),a2
		add.w	(a0)+,a2		get special data
		subq.w	#2,d2
		move.l	a1,(a2)
		bra	701$			get next spec data
740$		move.l	(a0)+,a2
		subq.w	#4,d2
		move.l	a1,(a2)
		bra	701$
750$		rts
751$		cmp.b	#4,d1
		bne.s	752$
		move.w	(a0)+,d1
		subq.w	#2,d2
		move.b	d1,0(a1,d0.w)
		bra	701$
752$		move.w	(a0)+,d1		get special data
		subq.w	#2,d2
		add.w	d1,0(a1,d0.w)		add special info (relative)
		bra	701$			get next spec data

_INTalmnmuspec	dc.b	'MLMTMWMHMF',0,0
_INTalmnmusidcs	dc.b	mu_LeftEdge,5,mu_TopEdge,5,mu_Width,0,mu_Height,0
		dc.b	mu_Flags,0

_INTalmnmispec	dc.b	'ILITIWIHIFIMIIISTFTBTDTLTTTAAAAR',0,0
_INTalmnmisidcs	dc.b	mi_LeftEdge,5,mi_TopEdge,5,mi_Width,0,mi_Height,0
		dc.b	mi_Flags,0,mi_MutualExclude,1,mi_ItemFill,2
		dc.b	mi_SelectFill,2
		dc.b	mi_SIZEOF+it_FrontPen,4
		dc.b	mi_SIZEOF+it_BackPen,4
		dc.b	mi_SIZEOF+it_DrawMode,4
		dc.b	mi_SIZEOF+it_LeftEdge,5
		dc.b	mi_SIZEOF+it_TopEdge,5
		dc.b	mi_SIZEOF+it_ITextFont,2
		dc.b	1,3,0,3

;0=short, 1=long, 2=aptr(a2), 3=AR (0) / AA (<>0), 4=byte, 5=rel.word

		endc
		endm

