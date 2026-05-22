* include file for Amiga metacc macro assembler *
* created 21.01.89 TM - Supervisor Software *
* for handling Graphics events *


*T
*T	GFXLIB.I * Metacc Include File
*T		Version 1.02
*T	       Date 12.07.89
*T

;"drawrect, text, setmask, drawarray [MDAR]" created
;	-> v1.00 05.03.1989
;"drawarray [TF]" created -> v1.01 15.06.89
;"drawarray [BPW]" created -> v1.02 12.07.89

*B

;  drawrect	(draw a rectangle)
;  in:		d0=x1, d1=y1, d2=x2, d3=y2; a1=rport;
;  call:	gfxlib	drawrect;
;  notes:	/the drawing pen will be left into/
;  		/position (x1,y1)./

;  text		(write text into a rastport)
;  in:		d0=x, d1=y; a0=*string; a1=rport;
;  call:	gfxlib	text;
;  notes:	/remember the baseline in Y/

;  setmask	(set a drawing mask into a rastport)
;  in:		d0=mask; a1=rport;
;  call:	gfxlib	setmask;

;  drawarray	(draw from a table of commands)
;  in:		d0=x0, d1=y0; a0=*array; a1=rport;
;  call:	gfxlib	drawarray;
;  notes:	Possible commands are (given in Ascii):
;  		  Mx,y	Move drawing pen to (x,y)
;  		  Dx,y	Draw line to (x,y)
;  		  Rx,y	Draw rectangle to (x,y)
;  		  Tl,t  Write text "t" of length l using
;			last x,y as centre
;		  Fx,y	Fill rectangle to (x,y)
;		  Wx,y	Fill rectangle to (x,y) with BPen,
;			draw frame to (x,y) with APen
;		  Px	Set frame mode: x=0: simple,
;			x=1: double thick hor. lines
;  		  Ax	Set APen
;  		  Bx	Set BPen
;  		  'NUL'	End of array (a NULL char.)
;  		where x and y given as signed decimal
;		(base 10) integers (coordinates relative
;		to (x0,y0)).

*E


gfxlib		macro	name
		ifnc	'\1',''
_GFXF\1		set	1
		bsr	_GFX\1
		mexit
		endc

		ifd	_GFXFsetmask
_GFXsetmask	move.b	d0,24(a1)
		rts
		endc

		ifd	_GFXFdrawarray
_GFXdrawarray	push	d0-d7/a0-a5
		sub.l	a5,a5	;frame mode = 0
		move.l	a0,a2
		move.l	a1,a3
		move.w	d0,d4
		move.w	d1,d5
_GFXdrawarray1	move.b	(a2)+,d0
		beq	_GFXdrawarray0
		cmp.b	#'M',d0
		bne.s	_GFXdrawarray2
		bsr	_GFXdrawarray.b
		move.w	d0,d6
		move.w	d1,d7
		move.l	a3,a1
		lib	Gfx,Move
		bra.s	_GFXdrawarray1
_GFXdrawarray2	cmp.b	#'D',d0
		bne.s	_GFXdrawarray3
		bsr	_GFXdrawarray.b
		move.l	a3,a1
		lib	Gfx,Draw
		bra.s	_GFXdrawarray1
_GFXdrawarray3	cmp.b	#'A',d0
		bne.s	_GFXdrawarray4
		bsr	_GFXdrawarray.a
		move.l	a3,a1
		lib	Gfx,SetAPen
		bra.s	_GFXdrawarray1
_GFXdrawarray4	cmp.b	#'R',d0
		bne.s	_GFXdrawarray5
		bsr	_GFXdrawarray.b
		move.w	d6,d2
		move.w	d7,d3
_GFXdrawarray4b	move.l	a3,a1
		gfxlib	drawrect
		cmp.w	#0,a5	;frame mode
		beq	_GFXdrawarray1
		addq.w	#1,d0	;double frame
		subq.w	#1,d2
		gfxlib	drawrect
		bra	_GFXdrawarray1
_GFXdrawarray5	cmp.b	#'T',d0
		bne.s	_GFXdrawarray6
		bsr	_GFXdrawarray.a
		move.l	d0,d2
		mulu.w	60(a3),d0
		asr.w	#1,d0
		neg.w	d0
		move.l	58(a3),d1
		asr.w	#1,d1
		neg.w	d1
		add.w	d6,d0
		add.w	d7,d1
		add.w	62(a3),d1
		move.l	a3,a1
		lib	Gfx,Move
		move.l	a2,a0
		move.l	d2,d0
		move.l	a3,a1
		lib	Gfx,Text
		add.w	d2,a2
		bra	_GFXdrawarray1
_GFXdrawarray6	cmp.b	#'F',d0
		bne.s	_GFXdrawarray7
		bsr	_GFXdrawarray.b
		move.w	d6,d2
		move.w	d7,d3
		bsr	_GFXdrawarray.c
		move.l	a3,a1
		lib	Gfx,RectFill
		bra	_GFXdrawarray1
_GFXdrawarray7	cmp.b	#'B',d0
		bne.s	_GFXdrawarray8
		bsr	_GFXdrawarray.a
		move.l	a3,a1
		lib	Gfx,SetBPen
		bra	_GFXdrawarray1
_GFXdrawarray8	cmp.b	#'P',d0
		bne.s	_GFXdrawarray9
		bsr	_GFXdrawarray.a
		move.l	d0,a5	;frame mode
		bra	_GFXdrawarray1
_GFXdrawarray9	cmp.b	#'W',d0
		bne.s	_GFXdrawarray10
		bsr	_GFXdrawarray.b
		move.w	d6,d2
		move.w	d7,d3
		bsr	_GFXdrawarray.c
		push	d0-d3
		move.l	a3,a1
		move.b	25(a1),d6
		move.b	26(a1),d0
		ext.w	d0
		lib	Gfx,SetAPen
		peek	d0-d3
		move.l	a3,a1
		lib	Gfx,RectFill
		move.l	a3,a1
		move.b	d6,d0
		ext.w	d0
		lib	Gfx,SetAPen
		pull	d0-d3
		bra	_GFXdrawarray4b
_GFXdrawarray10	;add commands here!!!
		cmp.b	#10,d0
		beq	_GFXdrawarray1
		cmp.b	#32,d0
		beq	_GFXdrawarray1
_GFXdrawarray0	pull	d0-d7/a0-a5
		rts
_GFXdrawarray.a	cmp.b	#'-',(a2)
		bne.s	_GFXdrawarray.a3
		addq.w	#1,a2
		bsr.s	_GFXdrawarray.a
		neg.w	d0
		rts
_GFXdrawarray.a3 move.w	d1,-(sp)
		moveq	#0,d0
		clr.w	d1
_GFXdrawarray.a1 move.b	(a2)+,d1
		sub.b	#'0',d1
		blo.s	_GFXdrawarray.a2
		cmp.b	#9,d1
		bhi.s	_GFXdrawarray.a2
		mulu.w	#10,d0
		add.w	d1,d0
		bvc.s	_GFXdrawarray.a1
_GFXdrawarray.a2 move.b	-1(a2),d1
		cmp.b	#',',d1
		beq.s	_GFXdrawarray.a0
		subq.w	#1,a2
_GFXdrawarray.a0 move.w	(sp)+,d1
		rts
_GFXdrawarray.b	bsr	_GFXdrawarray.a
		move.w	d0,d1
		bsr	_GFXdrawarray.a
		exg.l	d0,d1
		add.w	d4,d0
		add.w	d5,d1
		rts
_GFXdrawarray.c	cmp.w	d0,d2
		bhs.s	001$
		exg.l	d0,d2
001$		cmp.w	d1,d3
		bhs.s	002$
		exg.l	d1,d3
002$		rts
		endc

		ifd	_GFXFtext
_GFXtext	push	a0-a3/d0-d1
		move.l	a0,a2
		move.l	a1,a3
		lib	Gfx,Move
		move.l	a2,a0
		move.l	a3,a1
		moveq	#-1,d0
_GFXtext1	addq.w	#1,d0
		tst.b	(a2)+
		bne.s	_GFXtext1
		flib	Gfx,Text
		pull	a0-a3/d0-d1
		rts
		endc

		ifd	_GFXFdrawrect
_GFXdrawrect	push	a0-a2/d0-d5
		move.l	a1,a2
		move.w	d0,d4
		move.w	d1,d5
		lib	Gfx,Move
		move.l	a2,a1
		move.w	d2,d0
		move.w	d5,d1
		flib	Gfx,Draw
		move.l	a2,a1
		move.w	d2,d0
		move.w	d3,d1
		flib	Gfx,Draw
		move.l	a2,a1
		move.w	d4,d0
		move.w	d3,d1
		flib	Gfx,Draw
		move.l	a2,a1
		move.w	d4,d0
		move.w	d5,d1
		flib	Gfx,Draw
		pull	a0-a2/d0-d5
		rts
		endc

		endm


