
;  *** Include Library for Handling Numeric Strings ***
;  180988 v 1.42 TM       =AMIGA= Metacc Macro Assembler

;  Edited:  25.11.88 TM  'sput10, lzput10' CREATED
;	    17.12.88 TM  'sput10' RECURSIVE 'div10' CREATED
;			 'put10' RECURSIVE
;	    22.02.89 JM  'put10' now returns length in d0 again -> v 1.21
;	    		 *** If something does not work, try saving d0.
;	    04.03.89 TM  sortentry.comments added -> v1.22
;	    27.03.89 TM  'get16, put16' now save registers
;			 affected onto the stack -> v1.23
;	    21.06.89 TM  'check10' made -> v1.3
;	    22.06.89 TM  code compressed & speeded up -> v1.4
;	    01.07.89 TM	 'check16' made -> v1.42
*T
*T	NUMLIB.I * Metacc Include File
*T		Version 1.42
*T	       Date 01.07.89
*T
*B

;  get10	(string10 to integer /signed/)
;  in:		a0=*string;
;  call:	numlib get10;
;  out:		a0=*endofvalue; d0=integer;
;  		p.c=error_exit; /if no value present/

;  get16	(string16 to integer /signed/)
;  in:		a0=*string;
;  call:	numlib get16;
;  out:		a0=*endofstring; d0=integer;
;		p.c=error_exit; /if no value present/

;  getval	(string to integer /signed/)
;  in:		a0=*string;
;  call:	numlib getval;
;  out:		a0=*endofstring; d0=integer;
;  		p.c=error_exit; /if no value present/
;  notes:	/base 16 values have prefix $/
;  		/base 10 values have no prefix or prefix +/

;  check10	(check whether decimal (base10) value follows)
;  in:		a0=*ptr;
;  call:	numlib check10;
;  out:		p.z=result (NE if no value)
;  notes:	/the value may be terminated by any character
;		less than '@' (64) except a decimal digit/
;		/if any other character terminates it, it is
;		not considered to be a number/

;  check16	(check whether hexadec (base16) value follows)
;  in:		a0=*ptr;
;  call:	numlib check16;
;  out:		p.z=result (NE if no value)
;  notes:	/the value may be terminated by any character
;		less than '@' (64) except a hexadecimal digit/
;		/if any other character terminates it, it is
;		not considered to be a number/

;  put10	(integer to string10 /signed/)
;  in:		a0=*string; d0=integer;
;  call:	numlib put10;
;  out:		a0=*(NULL); d0=length;

;  div10	(divide long-integer by 10 /unsigned/)
;  in:		d0=value;
;  call:	numlib div10;
;  out:		d0=value DIV 10; d1=(UWORD) value MOD 10;

;  sput10	(short integer to string10 /signed/)
;  in:		a0=*string; d0=short_integer;
;  call:	numlib sput10;
;  out:		a0=*(NULL);

;  lzput10	(short integer to string10 /unsigned, incl. leading zeroes/)
;  in:		a0=*string; d0=short_integer;
;  call:	numlib lzput10;
;  out:		a0=*(NULL);
;  notes:	/output string always 5 characters + NULL/

;  put16	(integer to string16 /signed/)
;  in:		a0=*string; d0=integer;
;  call:	numlib put16;
;  out:		a0=*(NULL); d0=length;

;  isdigit10	(check if base10 digit)
;  in:		d0=character;
;  call:	numlib isdigit10;
;  out:		p=(flags) result /eq if true/;

;  isdigit16	(check if base16 digit /non-case-sensitive/)
;  in:		d0=character;
;  call:	numlib isdigit10;
;  out:		p=(flags) result /eq if true/;

;  skipblk	(skip blanks /32, 9, 10/)
;  in:		a0=*string;
;  call:	numlib skipblk;
;  out:		a0=*newstring; d0=num_of_skipped_chars;

*E

;;;



numlib	macro

	  ifnc	  '\1',''

_NUMF\1	    set	    1
	    jsr	    _NUM\1
	    mexit

	  endc

	    ifd	    _NUMFcheck10

_NUMcheck10	push	a0/d0
_NUMcheck10.1	move.b	(a0)+,d0
		cmp.b	#'-',d0
		beq.s	_NUMcheck10.1
		cmp.b	#'0',d0
		blo.s	_NUMcheck10ne
		cmp.b	#'9',d0
		bhi.s	_NUMcheck10ne
_NUMcheck10.2	move.b	(a0)+,d0
		cmp.b	#'@',d0
		bhs.s	_NUMcheck10ne
		cmp.b	#'0',d0
		blo.s	_NUMcheck10eq
		cmp.b	#'9',d0
		bls.s	_NUMcheck10.2
_NUMcheck10eq	moveq	#0,d0
		pull	a0/d0
		rts
_NUMcheck10ne	moveq	#1,d1
		pull	a0/d0
		rts

	    endc


	    ifd	    _NUMFcheck16

_NUMcheck16	push	a0/d0
_NUMcheck16.1	move.b	(a0)+,d0
		cmp.b	#'-',d0
		beq.s	_NUMcheck16.1
		numlib	isdigit16
		bne.s	_NUMcheck16ne
_NUMcheck16.2	move.b	(a0)+,d0
		numlib	isdigit16
		beq.s	_NUMcheck16.2
		cmp.b	#'@',d0
		bhs.s	_NUMcheck16ne
_NUMcheck16eq	moveq	#0,d0
		pull	a0/d0
		rts
_NUMcheck16ne	moveq	#1,d1
		pull	a0/d0
		rts

	    endc


	    ifd	    _NUMFgetval

_NUMgetval	move.b	(a0),d0
		numlib	isdigit10
		beq.s	_getval1
		cmp.b	#'+',d0
		bne.s	_getval2
		addq.l	#1,a0
_getval1	numlib	get10
		rts
_getval2	cmp.b	#'$',d0
		bne.s	_getval3
		addq.l	#1,a0
		numlib	get16
		rts
_getval3	setc
		rts

	    endc


	    ifd	    _NUMFget10

_NUMget10	cmp.b	#'-',(a0)
		beq.s	_get10n
		move.b	(a0),d0
		cmp.b	#'0',d0
		blo.s	_get10x
		cmp.b	#'9',d0
		bhi.s	_get10x
		move.l	d2,-(sp)
		moveq	#0,d0
		move.l	d0,d1
_get10a		move.b	(a0)+,d1
		sub.b	#'0',d1
		blo.s	_get10b
		cmp.b	#9,d1
		bhi.s	_get10b
		add.l	d0,d0
		move.l	d0,d2
		asl.l	#2,d0
		add.l	d2,d0
		add.l	d1,d0
		bra.s	_get10a
_get10b		subq.l	#1,a0
		move.l	(sp)+,d2
		clrc
		rts
_get10n		addq.l	#1,a0
		bsr.s	_NUMget10
		neg.l	d0
		clrc
		rts
_get10x		moveq.l	#0,d0
		setc
		rts

	    endc


	    ifd	    _NUMFget16

_NUMget16	move.l	d1,-(sp)
		cmp.b	#'-',(a0)
		beq.s	_get16n
		moveq	#0,d0
_get16a		move.b	(a0)+,d1
		sub.b	#'0',d1
		blo.s	_get16b
		cmp.b	#9,d1
		bls.s	_get16c
		cmp.b	#'a'-'0',d1
		blo.s	_get16d
		sub.b	#32,d1
_get16d		sub.b	#7,d1
		cmp.b	#10,d1
		blo.s	_get16x
		cmp.b	#15,d1
		bhi.s	_get16x
_get16c		asl.l	#4,d0
		or.b	d1,d0
		bra.s	_get16a
_get16b		subq.l	#1,a0
		move.l	(sp)+,d1
		clrc
		rts
_get16n		addq.l	#1,a0
		bsr.s	_NUMget16
		bcs.s	_get16x
		move.l	(sp)+,d1
		neg.l	d0
		clrc
		rts
_get16x		move.l	(sp)+,d1
		setc
		rts

	    endc


	    ifd	    _NUMFput10

_NUMput10	move.l	d1,-(sp)
		move.l	a0,-(sp)
		tst.l	d0
		bpl.s	_put10a
		neg.l	d0
		move.b	#'-',(a0)+
_put10a		numlib	div10
		tst.l	d0
		beq.s	_put10b
		bsr.s	_NUMput10
_put10b		or.b	#'0',d1
		move.b	d1,(a0)+
		clr.b	(a0)
		move.l	a0,d0
		sub.l	(sp)+,d0
		move.l	(sp)+,d1
		rts

	    endc


	    ifd	    _NUMFdiv10

_NUMdiv10	move.l	d2,-(sp)
		move.l	d0,d1
		swap	d1
		ext.l	d1
		divu.w	#10,d1
		move.w	d1,d2
		swap	d2
		move.w	d0,d1
		divu.w	#10,d1
		move.w	d1,d2
		swap	d1
		move.l	d2,d0
		move.l	(sp)+,d2
		rts

	    endc


	    ifd	    _NUMFlzput10

_NUMlzput10	move.l	d1,-(sp)
		moveq	#4,d1
		addq.l	#5,a0
		clr.b	(a0)
_lzput10a	and.l	#$ffff,d0
		divu	#10,d0
		swap	d0
		or.b	#'0',d0
		move.b	d0,-(a0)
		swap	d0
		dbf	d1,_lzput10a
		addq.l	#5,a0
		move.l	(sp)+,d1
		rts

	    endc


	    ifd	    _NUMFsput10

_NUMsput10	move.l	d0,-(sp)
		tst.w	d0
		bpl.s	_sput10a
		neg.w	d0
		move.b	#'-',(a0)+
_sput10a	ext.l	d0
		divu.w	#10,d0
		beq.s	_sput10b
		bsr.s	_NUMsput10
_sput10b	swap	d0
		or.b	#'0',d0
		move.b	d0,(a0)+
		clr.b	(a0)
		move.l	(sp)+,d0
		rts

	    endc


	    ifd	    _NUMFput16

_NUMput16	push	d1-d4
		moveq	#0,d2
		move.b	d2,d3
		tst.l	d0
		bpl.s	_put16b
		neg.l	d0
		move.b	#'-',(a0)+
		addq.l	#1,d2
_put16b		moveq	#7,d4
_put16a		rol.l	#4,d0
		move.b	d0,d1
		and.w	#15,d1
		cmp.w	#9,d1
		bls.s	1$
		addq.w	#7,d1
1$		add.b	#'0',d1
		tst.b	d3
		bne.s	_put16d
		tst.b	d4
		beq.s	_put16d
		cmp.b	#'0',d1
		beq.s	_put16e
_put16d		move.b	d1,(a0)+
		addq.l	#1,d2
		moveq	#-1,d3
_put16e		dbf	d4,_put16a
		clr.b	(a0)
		move.l	d2,d0
		pull	d1-d4
		rts

	    endc


	    ifd	    _NUMFisdigit10

_NUMisdigit10	cmp.b	#'0',d0
		blo.s	_nnisdigit10.1
		cmp.b	#'9',d0
		bhi.s	_nnisdigit10.1
		cmp.b	d0,d0
_nnisdigit10.1	rts

	    endc


	    ifd	    _NUMFisdigit16

_NUMisdigit16	cmp.b	#'0',d0
		blo.s	_nnisdigit161
		cmp.b	#'f',d0
		bhi.s	_nnisdigit161
		cmp.b	#'a',d0
		bhs.s	_nnisdigit162
		cmp.b	#'F',d0
		bhi.s	_nnisdigit161
		cmp.b	#'A',d0
		bhs.s	_nnisdigit162
		cmp.b	#'9',d0
		bhi.s	_nnisdigit161
_nnisdigit162	cmp.b	d0,d0
		rts
_nnisdigit161	cmp.b	#'5',d0
		rts

	    endc


	    ifd	    _NUMFskipblk

_NUMskipblk	moveq	#0,d0
_nskipblk1	cmp.b	#32,(a0)
		beq.s	_nskipblk2
		cmp.b	#10,(a0)
		beq.s	_nskipblk2
		cmp.b	#9,(a0)
		beq.s	_nskipblk2
		rts
_nskipblk2	addq.l	#1,a0
		addq.l	#1,d0
		bra.s	_nskipblk1

	    endc

	endm

