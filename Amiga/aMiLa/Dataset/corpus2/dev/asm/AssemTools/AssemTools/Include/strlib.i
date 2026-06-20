
;  *** Include Library for Handling Character Strings ***
;  05.08.89 v 1.770 JM     =AMIGA= Metacc Macro Assembler

;	Edited: two bugs fixed on GETIWORD -> v1.3  12.11.88
;		<ESC>, <LF>, "*" included to BLKCPY -> v1.4 20.11.88
;		JM's STRCMP added -> v1.5 21.11.88
;		"addslash, remslash, extfname" added ->1.51 22.11.88
;		"peekword" added, "strlib" changed to use BSR ->1.52 TM 25.11.88
;		"blkncpy, getbcpl, putbcpl" -> v1.53 25.11.88
;		"stable" added, ".S"'s added to branches
;		 -> v1.55 29.12.88
;		"strscmpi" added -> v1.56 14.01.89
;		"sblk, chkslash" added -> v1.57 20.01.89
;		"getbcpl" modified to return a1 -> v1.58 19.02.89
;		"findnth" added -> v1.59 19.02.89
;		"ptrlist, listlen, strlist, tsort" added -> v1.6 20.02.89
;		"tokcmp, findtok" added -> v1.61 20.02.89
;		"gettokw" added -> v1.62 01.03.89
;		"strcmpi, tsorti, strrev" added -> v1.7 04.03.89
;		sortentry.comments added -> v1.71 04.03.88
;		bubble inflation included into "tsort" and
;		"tsorti" -> v1.72 07.03.89
;		pull's changed for a68k -> v1.73 11.03.89
;		comments of "stable" mod. -> v1.74 260389
;		"tokcmp" debugt (now does not change a0 if
;		it points to NULL) -> v1.75 110589
;		"getrawdata" created -> v1.76 210589
;		*t, *T added to "blkcpy" -> v1.761 050689
;		"blkcpy" now does not convert any T into
;		  a tabulator -> v1.762 100689
;		code compressed & speeded up -> v1.763 22.06.89
;		"findtok" debugt (now accepts also 'z' in the word)
;		  -> v1.764 02.07.89
;		"addsuffix" and "remsuffix" created by JM -> v1.77 050889
;		"findtok" changed to skip over the token (at a0),
;		  if it found the token from the list (just
;                 as 'tokcmp' does) -> v1.764b 07.08.89

*T
*T	STRLIB.I  *  Metacc Include File
*T		Version 1.77b
*T		Date 07.08.89
*T
*B

;  peekword	(peek integer string /double longword/)
;  in:		a0=*string;
;  call:	strlib peekword;
;  out:		d1:d0=string;
;  notes:	/see getiwordu/

;  getiword	(get integer string /double longword/)
;  in:		a0=*string;
;  call:	strlib getiword;
;  out:		a0=*newstring; d1:d0=string;
;  notes:	/included characters are:/
;  		/a-z, A-Z for first character/
;  		/a-z, A-Z, 0-9 for other characters/
;  		/no more than 8 characters will be fetched/

;  getiwordu	(get integer string and ucase /double longword/)
;  in:		a0=*string;
;  call:	strlib getiwordu;
;  out:		a0=*newstring; d1:d0=string;
;  notes:	/see getiword/

;  getrawdata	(get raw data string)
;  in:		a0=*from, a1=*to;
;  call:	strlib getrawdata;
;  out:		a0=*from_rest, a1=*to_end, d0=length_of_TO;
;  notes:	/The 'raw data' may include one or more
;  		 of the following elements, separated by
;  		 commas, ending with a blank or NULL:
;  		   "blubblub"	8-bit ascii data
;  		   123 or 123.b	8-bit decimal data
;  		   $ab or $ab.b	8-bit hexadec data
;  		   1234.w	16-bit decimal data
;  		   $12ab.w	16-bit hexadec data
;  		   123456.l	32-bit decimal data
;  		   $12ab56.l	32-bit hexadec data
;  		 ** Requires 'numlib' (getval)
;  		/

;  ucase	(convert character to upper case /byte/)
;  in:		d0=char;
;  call:	strlib ucase;
;  out:		d0=newchar;

;  locase	(convert character to lower case /byte/)
;  in:		d0=char;
;  call:	strlib locase;
;  out:		d0=newchar;

;  skipblk	(skip blanks /32, 9, 10/)
;  in:		a0=*string;
;  call:	strlib skipblk;
;  out:		a0=*newstring; d0=num_of_skipped_chars;

;  sblk		(simple skip blanks /32, 9, 10/)
;  in:		a0=*;
;  call:	strlib sblk;
;  out:		a0=*;

;  isalpha	(check if alpha /a-z, A-Z/)
;  in:		d0=char;
;  call:	strlib isalpha;
;  out:		p=(flags) result; /eq if true/

;  isalphanum	(check if alphanumeric /a-z, A-Z, 0-9/)
;  in:		d0=char;
;  call:	strlib isalphanum;
;  out:		p=(flags) result; /eq if true/

;  isnumeric	(check if numeric /0-9/)
;  in:		d0=char;
;  call:	strlib isnumeric;
;  out:		p=(flags) result; /eq if true/

;  strupr	(string to upper case /null terminated/)
;  in:		a0=*string;
;  call:	strlib strupr;

;  strlwr	(string to lower case /null terminated/)
;  in:		a0=*string;
;  call:	strlib strlwr;

;  strcpy	(string copy /null terminated/)
;  in:		a0=*source_string; a1=*target_string;
;  call:	strlib strcpy;

;  strscmp	(simple string compare /null terminated/)
;  in:		a0=*first_string; a1=*second_string;
;  call:	strlib strscmp;
;  out:		p.z=(boolean) result; /eq if equals/
;  notes:	/does not compare alpha order, just/
;  		/equality/

;  strscmpi	(simple string compare /case-insensitive/)
;  in:		a0=*first_string; a1=*second_string;
;  call:	strlib strscmpi;
;  out:		p.z=(boolean) result; /eq if equals/
;  notes:	/does not compare alpha order, just/
;  		/equality/

;  blkncpy	(string copy /length-limited blkcpy/)
;  in:		a0=*source_string; a1=*target_string; d0=max_length;
;  call:	strlib blkncpy
;  out:		a0=*rest_of_string=*(BLANK or NULL);
;  		a1=*after_target_string=(*NULL)+1;
;  		d0=num_of_chars_left_in_buffer;
;  notes:	/*n, *N = newline (10)/
;  		/*e, *E = esc (27)/
;  		/*t, *T = tab (9)/

;  blkcpy	(string copy /blank or comma terminated/)
;  in:		a0=*source_string; a1=*target_string;
;  call:	strlib blkcpy;
;  out:		a0=*rest_of_string=*(BLANK or NULL);
;  		a1=*after_target_string=(*NULL)+1;
;  notes:	/the target string will be null-terminated/
;  		/whilst the source string terminates/
;  		/with either blank, comma or null/
;		/quotes "" enbrace strings with blanks/
;		/"*" (in quotes) as in the CLI cmds/

;  isblank	(check if blank /32, 9, 10/)
;  in:		d0=char;
;  call:	strlib isblank;
;  out:		p.z=(boolean) result; /eq if blank/

;  strlen	(compute string length & end address/ null terminated)
;  in:		a0=*string;
;  call:	strlib strlen;
;  out:		d0=length; a0=(*NULL)+1;

;  strnth	(find nth string in list / null terminated/)
;  in:		a0=*string_list; d0=(uword) count;
;  call:	strlib strnth;
;  out:		a0=*string; d0=(uword) $ffff;
;  notes:	/high speed, 4 instructions incl. rts./
;		/each string of the list is terminated/
;		/with a null byte. double-null (end-of-list)/
;		/will not be noticed./

;  findnth	(find string from list /null terminated/)
;  in:		a0=*string; a1=*list;
;  call:	strlib findnth;
;  out:		d0=count;
;  notes:	/0 stands for the first string, -1 for error/
;		/the list should be terminated by an empty/
;		/string./

;  strcmp	(compare strings /null terminated/)
;  in:		a0=*first_string; a1=*second_string;
;  call:	strlib strcmp;
;  out:		p.flags=result;
;  notes:	/results flags as CMP first_string, second_string/
;  		/compares also lexicographity/

;  strcmpi	(compare strings /case-insensitive/)
;  in:		a0=*first_string; a1=*second_string;
;  call:	strlib strcmpi;
;  out:		p.flags=result;
;  notes:	/see strcmp/

;  addslash	(add slash into end of string if not / or :)
;  in:		a0=*string;
;  call:	strlib addslash;
;  out:		a0=*(NULL);

;  remslash	(remove slash , if present, from end of pathname)
;  in:		a0=*string;
;  call:	strlib remslash;
;  out:		a0=*(NULL);

;  chkslash	(check if a this string ends with a / or :)
;  in:		a0=*string;
;  call:	strlib chkslash;
;  out:		p.z=result /Z is set if no "/" or ":"/;

;  extfname	(extract file name from a valid path+filename)
;  in:		a0=*string;
;  call:	strlib extfname;
;  out:		a0=*filename;
;  notes:	if no filename is present, the last directoryname
;  		must be followed by slash (/).

;  strend	(find end of string)
;  in:		a0=*string;
;  call:	strlib strend;
;  out:		a0=*(NULL)+1;

;  putbcpl	(convert TO BCPL string)
;  in:		a0=*string; a1=*bcpl_string;
;  call:	strlib putbcpl;
;  out:		-
;  notes:	/the pointers are both APTRs and NOT BPTRs/

;  getbcpl	(convert FROM BCPL string)
;  in:		a0=*bcpl_string; a1=*string;
;  call:	strlib getbcpl;
;  out:		a1=*NULL;
;  notes:	/the pointers are both APTRs and NOT BPTRs/

;  stable	(seek string from table with modulo)
;  in:		a0=*string, a1=*string_list, d0=*modulo;
;  call:	strlib stable;
;  out:		a0=*data_item /==NULL if not found/;
;  notes:	/the value returned points to the data area/
;  		/of the string. the parameter given in d0/
;  		/specifies the length of the data entry./
;  		/this entry is overskipped between the/
;  		/string items. a NULL character must exist/
;  		/after each string./
;  		/condition codes are set according to the result./

;  ptrlist	(create string pointer list)
;  in:		a0=*string_list; a1=*room_for_ptrlist;
;  		d0=max_number_of_ptrs;
;  call:	strlib ptrlist;
;  out:		d0=number_of_ptrs;
;  notes:	/the string list in a0 should be terminated/
;  		/by an empty string/
;  		/collects the starting addresses for each/
;  		/string into the ptrlist./

;  listlen	(measure length of a string list)
;  in:		a0=*string_list;
;  call:	strlib listlen;
;  out:		d0=number_of_bytes; d1=number_of_strings;
;  notes:	/d0 is the number of bytes occupied by/
;  		/the list, including the end nulls/
;  		/d1 is the number of the string in the list/

;  strlist	(convert a ptrlist into a stringlist)
;  in:		a0=*ptr_list; a1=*room_for_stringlist;
;  		d0=len_of_buffer;
;  call:	strlib strlist;
;  out:		d0=number_of_strings;
;  notes:	/the check for overflow is only made/
;  		/between the strings, thus the value/
;  		/in d0 should be buffersize-<length-of/
;  		/longest-string>/

;  tsort	(bubble-sort a ptrlist)
;  in:		a0=*ptr_list;
;  call:	strlib tsort;
;  notes:	/a rather slow (?) way of doing this/
;		/empty strings separate "units": only/
;		/the units within a unit are ordered./
;		/the order of units is not changed./

;  tsorti	(bubble-sort a ptrlist /case-insensitive/)
;  in:		a0=*ptr_list;
;  call:	strlib tsorti;
;  notes:	/see tsort/

;  tokcmp	(token compare /case-insensitive/)
;  in:		a0=*first_string; a1=*second_string;
;  call:	strlib tokcmp;
;  out:		p.z=equality; /EQ if token match/
;  		a0=*end_of_1st_string /if they were EQ;
;  		otherwise unchanged/
;  notes:	/first_string may be terminated with/
;  		/either NULL or BLANK, the second_string/
;  		/must terminate with a NULL./
;  		/the first_string does not need to match/
;  		/the entire string, just the given chars/
;  		/from the beginning/

;  findtok	(find token from list /case-insensitive/)
;  in:		a0=*token; a1=*list;
;  call:	strlib findtok;
;  out:		d0=count; /-1 =^ not found/
;		a0=*end_of_token /not changed if not found/
;  notes:	/see tokcmp/

;  gettokw	(get a token word)
;  in:		a0=txtptr; a1=*buffer; d0=(UWORD)buffer_length;
;  call:	strlib gettokw;
;  out:		a0=txtptr /updated/ ; a1=*buffer;
;  		p.c=error; /c=1 if buffer overflow/
;  notes:	/a token word:/
;  		/- begins with a-z|A-Z|.|_/
;  		/- other chrs are a-z|A-Z|0-9|.|_/
;  		/- must be at least 1 char. long/

;  strrev	(reverse string /null-terminated/)
;  in:		a0=*string;
;  call:	strlib	strrev;
;  notes:	/created just for fun - the 40th routine!/

;  addsuffix	(add suffix (".<suffix>") into end of string)
;  in:		a0=*suffix; a1=*string;
;  call:	strlib addsuffix;
;  out:		a1=*(NULL)+1; a0=*(NULL)+1

;  remsuffix	(remove suffix, if present, from end of string)
;  in:		a0=*string;
;  call:	strlib remsuffix;
;  out:		a0=*(NULL);


*E

;;;



strlib	macro

	  ifnc	  '\1',''

_STRF\1	    set	    1
	    bsr	    _STR\1
	    mexit

	  endc


	    ifd	    _STRFgetrawdata
_STRgetrawdata	push	d1-d3/a2-a3
		move.l	a1,a3
_STRgetrawd1	move.b	(a0),d0
		beq	_STRgetrawd0
		cmp.b	#32,d0
		beq	_STRgetrawd0
		cmp.b	#9,d0
		beq	_STRgetrawd0
		cmp.b	#10,d0
		beq	_STRgetrawd0
		cmp.b	#'"',d0
		bne.s	_STRgetrawd2
		addq.w	#1,a0
_STRgetrawd1b	move.b	(a0),d0
		beq	_STRgetrawd0
		addq.w	#1,d0
		move.b	d0,(a1)+
		cmp.b	#'"',d0
		bne.s	_STRgetrawd1b
		subq.w	#1,a1
_STRgetrawd1c	cmp.b	#',',(a0)
		bne	_STRgetrawd0
		addq.w	#1,a0
		strlib	sblk
		bra.s	_STRgetrawd1
_STRgetrawd2	cmp.b	#'-',d0
		bne	_STRgetrawd3
		addq.w	#1,a0
		numlib	getval
		neg.l	d0
_STRgetrawd2a	move.l	d0,d1
		cmp.b	#'.',(a0)
		bne.s	_STRgetrawd2b
		move.b	1(a0),d0
		strlib	ucase
		cmp.b	#'B',d0
		bne.s	_STRgetrawd2c
_STRgetrawd2b	move.b	d0,(a1)+
_STRgetrawd2b1	lea.l	2(a0),a0
		bra.s	_STRgetrawd1c
_STRgetrawd2c	cmp.b	#'W',d0
		bne.s	_STRgetrawd2d
		move.b	d0,1(a1)
		lsr.l	#8,d0
		move.b	d0,(a1)
		lea.l	2(a1),a1
		bra.s	_STRgetrawd2b1
_STRgetrawd2d	cmp.b	#'L',d0
		bne	_STRgetrawd1c
		move.b	d0,3(a1)
		lsr.l	#8,d0
		move.b	d0,2(a1)
		lsr.l	#8,d0
		move.b	d0,1(a1)
		lsr.l	#8,d0
		move.b	d0,(a1)
		lea.l	4(a1),a1
		bra.s	_STRgetrawd2b1
_STRgetrawd3	numlib	getval
		bra	_STRgetrawd2a
_STRgetrawd0	move.l	a1,d0
		sub.l	a3,d0
		pull	d1-d3/a2-a3
		rts
	    endc


	    ifd	    _STRFstrrev

_STRstrrev	push	a0-a1/d0
		move.l	a0,a1
_STRstrrev1	tst.b	(a1)+
		bne.s	_STRstrrev1
		subq.w	#1,a1
		bra.s	_STRstrrev3
_STRstrrev2	move.b	(a0),d0
		move.b	-(a1),(a0)+
		move.b	d0,(a1)
_STRstrrev3	cmp.l	a1,a0
		blo.s	_STRstrrev2
		pull	a0-a1/d0
		rts

	    endc


	    ifd	    _STRFgettokw

_STRgettokw	push	d0-d1/a1
		move.l	d0,d1
		strlib	sblk
		move.b	(a0)+,d0
		cmp.b	#'.',d0
		beq.s	_STRgettokw1		;tokenword exists
		cmp.b	#'_',d0
		beq.s	_STRgettokw1
		cmp.b	#'A',d0
		blo.s	_STRgettokw0		;not tokenword
		cmp.b	#'Z',d0
		bls.s	_STRgettokw1
		cmp.b	#'a',d0
		blo.s	_STRgettokw0
		cmp.b	#'z',d0
		bls.s	_STRgettokw1
_STRgettokw0	subq.w	#1,a0
		clr.b	(a1)
		pull	d0-d1/a1
		clrc
		rts
_STRgettokw.e	pull	d0-d1/a1	;buffer overflow
		setc
		rts
_STRgettokw1	move.b	d0,(a1)+
		subq.w	#1,d1
		beq.s	_STRgettokw.e
		move.b	(a0)+,d0
		cmp.b	#'.',d0
		beq.s	_STRgettokw1
		cmp.b	#'_',d0
		beq.s	_STRgettokw1
		cmp.b	#'0',d0
		blo.s	_STRgettokw0
		cmp.b	#'9',d0
		bls.s	_STRgettokw1
		cmp.b	#'A',d0
		blo.s	_STRgettokw0
		cmp.b	#'Z',d0
		bls.s	_STRgettokw1
		cmp.b	#'a',d0
		blo.s	_STRgettokw0
		cmp.b	#'z',d0
		bls.s	_STRgettokw1
		bra.s	_STRgettokw0

	    endc


	    ifd	    _STRFtokcmp

_STRtokcmp	push	d0-d1/a1
		move.l	a0,-(sp)
		tst.b	(a0)
		beq.s	_STRtokcmp.ne
_STRtokcmp1	move.b	(a0)+,d0
		beq.s	_STRtokcmp.eq
		cmp.b	#32,d0
		beq.s	_STRtokcmp.eq
		cmp.b	#9,d0
		beq.s	_STRtokcmp.eq
		cmp.b	#10,d0
		beq.s	_STRtokcmp.eq
		strlib	ucase
		move.b	(a1)+,d1
		beq.s	_STRtokcmp.ne
		cmp.b	#'a',d1
		blo.s	_STRtokcmp.nlc
		cmp.b	#'z',d1
		bhi.s	_STRtokcmp.nlc
		sub.b	#32,d1
_STRtokcmp.nlc	cmp.b	d0,d1
		beq.s	_STRtokcmp1
_STRtokcmp.ne	move.l	(sp)+,a0
		moveq	#1,d0
		bra.s	_STRtokcmp0
_STRtokcmp.eq	tst.b	d0
		bne.s	_STRtokcmp.eq1
		subq.w	#1,a0
_STRtokcmp.eq1	addq.w	#4,sp
		moveq	#0,d0
_STRtokcmp0	pull	d0-d1/a1
		rts

	    endc


	    ifd	    _STRFlistlen

_STRlistlen	move.l	a0,-(sp)
		move.l	a0,d0
		moveq	#-1,d1
_STRlistlen1	tst.b	(a0)+
		bne.s	_STRlistlen1
		addq.l	#1,d1
		tst.b	(a0)+
		bne.s	_STRlistlen1
		sub.l	a0,d0
		neg.l	d0
		move.l	(sp)+,a0
		rts

	    endc


	    ifd	    _STRFptrlist

_STRptrlist	push	a0/a1/d1
		move.l	d0,d1
		moveq.l	#-1,d0
_STRptrlist1	move.l	a0,(a1)+
		addq.l	#1,d0
		tst.b	(a0)
		beq.s	_STRptrlist3
_STRptrlist2	tst.b	(a0)+
		bne.s	_STRptrlist2
		cmp.l	d1,d0
		blo.s	_STRptrlist1
_STRptrlist3	clr.l	-(a1)
		pull	a0/a1/d1
		tst.l	d0
		rts

	    endc


	    ifd	    _STRFstrlist

_STRstrlist	push	a0-a3/d1
		move.l	d0,a3
		add.l	a1,a3
		moveq.l	#0,d0
_STRstrlist1	move.l	(a0)+,a2
		move.l	a2,d1
		beq.s	_STRstrlist0
_STRstrlist2	move.b	(a2)+,(a1)+
		bne.s	_STRstrlist2
		clr.b	(a1)+
		addq.l	#1,d0
		cmp.l	a3,d0
		blo.s	_STRstrlist1
_STRstrlist0	clr.b	(a1)
		pull	a0-a3/d1
		tst.l	d0
		rts

	    endc


	    ifd	    _STRFtsort

_STRtsort	push	a0-a3/d0-d2
		move.l	a0,a3
_STRtsort1	move.l	a3,a2
		moveq	#0,d2
_STRtsort2	move.l	(a2)+,d0
		beq.s	_STRtsort3
		move.l	d0,a0
		move.l	(a2),d0
		beq.s	_STRtsort3
		move.l	d0,a1
		strlib	strcmp
		bhs.s	_STRtsort2	;right order?
		move.l	a0,(a2)		;no,
		move.l	a1,-4(a2)	;exc.
		addq.l	#1,d2
		subq.l	#4,a2
		cmp.l	a3,a2
		beq.s	_STRtsort2
		subq.l	#4,a2
		bra.s	_STRtsort2
_STRtsort3	tst.l	d2		;more rounds?
		bne.s	_STRtsort1
		pull	a0-a3/d0-d2
		rts

	    endc


	    ifd	    _STRFtsorti

_STRtsorti	push	a0-a3/d0-d2
		move.l	a0,a3
_STRtsorti1	move.l	a3,a2
		moveq	#0,d2
_STRtsorti2	move.l	(a2)+,d0
		beq.s	_STRtsorti3
		move.l	d0,a0
		move.l	(a2),d0
		beq.s	_STRtsorti3
		move.l	d0,a1
		strlib	strcmpi
		bhs.s	_STRtsorti2	;right order?
		move.l	a0,(a2)		;no,
		move.l	a1,-4(a2)	;exc.
		addq.l	#1,d2
		subq.l	#4,a2
		cmp.l	a3,a2
		beq.s	_STRtsorti2
		subq.l	#4,a2
		bra.s	_STRtsorti2
_STRtsorti3	tst.l	d2		;more rounds?
		bne.s	_STRtsorti1
		pull	a0-a3/d0-d2
		rts

	    endc


	    ifd	    _STRFfindnth

_STRfindnth	push	a0-a2 ;a0=str, a1=list: d0=cnt
		moveq.l	#0,d0
1$		move.l	a0,a2
2$		cmpm.b	(a1)+,(a2)+
		bne.s	3$
		tst.b	-1(a1)
		bne.s	2$
0$		pull	a0-a2
		tst.l	d0
		rts
3$		subq.w	#1,a1
31$		tst.b	(a1)+	; find end
		bne.s	31$
4$		addq.l	#1,d0
		tst.b	(a1)	; last?
		bne.s	1$
5$		moveq.l	#-1,d0	; not found
		bra.s	0$

	    endc


	    ifd	    _STRFfindtok

_STRfindtok	push	a1-a2/d1-d2 ;a0=token, a1=list: d0=cnt
		moveq.l	#0,d2
_STRfindtok1	move.l	a0,a2
_STRfindtok2	move.b	(a2)+,d0
		beq.s	_STRfindtok0	;end; found
		cmp.b	#32,d0
		beq.s	_STRfindtok0
		cmp.b	#9,d0
		beq.s	_STRfindtok0
		cmp.b	#10,d0
		beq.s	_STRfindtok0
		strlib	ucase
		move.b	(a1)+,d1
		beq.s	_STRfindtok3
		cmp.b	#'a',d1
		blo.s	_STRfindtok.nlc
		cmp.b	#'z',d1
		bhi.s	_STRfindtok.nlc
		sub.b	#32,d1
_STRfindtok.nlc	cmp.b	d0,d1
		bne.s	_STRfindtok3
		tst.b	d1
		bne.s	_STRfindtok2
_STRfindtok0	lea.l	-1(a2),a0
_STRfindtok0b	move.l	d2,d0
		pull	a1-a2/d1-d2
		rts
_STRfindtok3	tst.b	d1	; skip to next string
		beq.s	_STRfindtok4
_STRfindtok3b	tst.b	(a1)+	; find end
		bne.s	_STRfindtok3b
_STRfindtok4	addq.l	#1,d2
		tst.b	(a1)	; last?
		bne.s	_STRfindtok1
_STRfindtok5	moveq.l	#-1,d2	; not found
		bra.s	_STRfindtok0b

	    endc


	    ifd	    _STRFstrend

_STRstrend	tst.b	(a0)+
		bne.s	_STRstrend
		rts

	    endc


	    ifd	    _STRFgetbcpl

_STRgetbcpl	push	a0/d0
		moveq	#0,d0
		move.b	(a0)+,d0
		subq.w	#1,d0
		bmi.s	_getbcpl2
_getbcpl1	move.b	(a0)+,(a1)+
		dbf	d0,_getbcpl1
_getbcpl2	clr.b	(a1)
		pull	a0/d0
		rts

	    endc


	    ifd	    _STRFputbcpl

_STRputbcpl	push	a0/d0
		move.l	a1,-(sp)
		addq.l	#1,a1
		moveq	#-1,d0
_putbcpl1	addq.b	#1,d0
		move.b	(a0)+,(a1)+
		bne.s	_putbcpl1
		move.l	(sp)+,a1
		move.b	d0,(a1)
		pull	a0/d0
		rts

	    endc


	    ifd	    _STRFpeekword

_STRpeekword	move.l	a0,-(sp)
		strlib	getiwordu
		move.l	(sp)+,a0
		tst.l	d0
		rts

	    endc

	    ifd	    _STRFgetiwordu

_STRgetiwordu	strlib	getiword
		moveq	#7,d1
		push	a0
		move.l	a1,a0
_getiwordu1	move.b	(a0),d0
		strlib	ucase
		move.b	d0,(a0)+
		dbf	d1,_getiwordu1
		move.l	(a1),d1
		move.l	4(a1),d0
		bne.s	_getiwordu2
		tst.l	d1
_getiwordu2	pull	a0/a0
		rts

	    endc


	    ifd	    _STRFgetiword

_STRgetiword	moveq	#0,d1
_getiword1	move.b	(a0)+,d0
		lea	_getiwordt(pc),a1
		move.l	d1,(a1)
		move.l	d1,4(a1)
		strlib	isalpha
		bne.s	_getiword3
		move.b	d0,7(a1)
_getiword2	move.b	(a0)+,d0
		strlib	isalphanum
		bne.s	_getiword3
		move.b	1(a1),(a1)
		move.b	2(a1),1(a1)
		move.b	3(a1),2(a1)
		move.b	4(a1),3(a1)
		move.b	5(a1),4(a1)
		move.b	6(a1),5(a1)
		move.b	7(a1),6(a1)
		move.b	d0,7(a1)
		tst.b	(a1)
		beq.s	_getiword2
		addq.l	#1,a0
_getiword3	subq.l	#1,a0
		move.l	(a1),d1
		move.l	4(a1),d0
		beq.s	_getiword4
		tst.l	d1
_getiword4	rts
_getiwordt	dc.l	0,0

	    endc


	    ifd	    _STRFisalphanum

_STRisalphanum	strlib	isalpha
		beq.s	_isalphanum1
		strlib	isnumeric
_isalphanum1	rts

	    endc


	    ifd	    _STRFisalpha

_STRisalpha	cmp.b	#'A',d0
		blo.s	_isalpha1
		cmp.b	#'z',d0
		bhi.s	_isalpha1
		cmp.b	#'a',d0
		bhs.s	_isalpha2
		cmp.b	#'Z',d0
		bhi.s	_isalpha1
_isalpha2	cmp.b	d0,d0
_isalpha1	rts

	    endc


	    ifd	    _STRFisnumeric

_STRisnumeric	cmp.b	#'0',d0
		blo.s	_isnumeric1
		cmp.b	#'9',d0
		bhi.s	_isnumeric1
		cmp.b	d0,d0
_isnumeric1	rts

	    endc


	    ifd	    _STRFstrupr

_STRstrupr	push	a0
_strupr1	move.b	(a0),d0
		strlib	ucase
		move.b	d0,(a0)+
		bne.s	_strupr1
		pull	a0
		rts

	    endc


	    ifd	    _STRFstrlwr

_STRstrlwr	push	a0
_strlwr1	move.b	(a0),d0
		strlib	locase
		move.b	d0,(a0)+
		bne.s	_strlwr1
		pull	a0
		rts

	    endc


	    ifd	    _STRFucase

_STRucase	cmp.b	#'a',d0
		blo.s	_ucase1
		cmp.b	#'z',d0
		bhi.s	_ucase1
		sub.b	#32,d0
_ucase1		rts

	    endc


	    ifd	    _STRFlocase

_STRlocase	cmp.b	#'A',d0
		blo.s	_locase1
		cmp.b	#'Z',d0
		bhi.s	_locase1
		add.b	#32,d0
_locase1	rts

	    endc


	    ifd	    _STRFstrcpy

_STRstrcpy	push	a0-a1
_strcpy1	move.b	(a0)+,(a1)+
		bne.s	_strcpy1
		pull	a0-a1
		rts

	    endc


	    ifd	    _STRFblkcpy

_STRblkcpy	move.l	d0,-(sp)
		moveq	#-1,d0
		strlib	blkncpy
		move.l	(sp)+,d0
		rts

	    endc


	    ifd	    _STRFblkncpy

_STRblkncpy	push	d1
		move.l	d0,d1
		cmp.b	#34,(a0)
		beq.s	_blkncpy3
_blkncpy1	move.b	(a0)+,d0
		tst.l	d1
		beq.s	_blkncpy1b
		move.b	d0,(a1)+
		subq.l	#1,d1
_blkncpy1b	tst.b	d0
		beq.s	_blkncpy2
		cmp.b	#32,d0
		beq.s	_blkncpy2
		cmp.b	#9,d0
		beq.s	_blkncpy2
		cmp.b	#',',d0
		beq.s	_blkncpy2
		cmp.b	#10,d0
		bne.s	_blkncpy1
_blkncpy2	subq.l	#1,a0
		subq.l	#1,a1
_blkncpy5	tst.l	d1
		beq.s	_blkncpy7
		clr.b	(a1)+
		subq.l	#1,d1
_blkncpy7	move.l	d1,d0
		pull	d1/d1
		rts
_blkncpy3	addq.l	#1,a0
_blkncpy4	move.b	(a0)+,d0
		beq.s	_blkncpy5
		cmp.b	#34,d0
		beq.s	_blkncpy5
		cmp.b	#'*',d0
		bne.s	_blkncpy7i
		move.b	(a0)+,d0
		beq.s	_blkncpy5
		cmp.b	#'n',d0
		beq.s	_blkncpyN
		cmp.b	#'N',d0
		bne.s	_blkncpynN
_blkncpyN	moveq	#10,d0
		bra.s	_blkncpy6
_blkncpynN	cmp.b	#'e',d0
		beq.s	_blkncpyE
		cmp.b	#'E',d0
		bne.s	_blkncpy6
_blkncpyE	moveq	#27,d0
_blkncpy6	cmp.b	#'t',d0
		beq.s	_blkncpyT
		cmp.b	#'T',d0
		bne.s	_blkncpy7i
_blkncpyT	moveq	#9,d0
_blkncpy7i	tst.l	d1
		beq.s	_blkncpy4
		move.b	d0,(a1)+
		subq.l	#1,d1
		bra.s	_blkncpy4

	    endc


	    ifd	    _STRFstrscmp

_STRstrscmp	push	a0-a1/d0
_strscmp1	move.b	(a0)+,d0
		cmp.b	(a1)+,d1
		bne.s	_strscmp2
		tst.b	d0
		bne.s	_strscmp1
_strscmp2	pull	a0-a1/d0
		rts

	    endc


	    ifd	    _STRFstrscmpi

_STRstrscmpi	push	a0-a1/d0-d1
_strscmpi1	move.b	(a0)+,d0
		move.b	(a1)+,d1
		cmp.b	#'A',d0
		blo.s	_strscmpi3
		cmp.b	#'Z',d0
		bhi.s	_strscmpi3
		add.b	#$20,d0
_strscmpi3	cmp.b	#'A',d1
		blo.s	_strscmpi4
		cmp.b	#'Z',d1
		bhi.s	_strscmpi4
		add.b	#$20,d1
_strscmpi4	cmp.b	d1,d0
		bne.s	_strscmpi2
		tst.b	d0
		bne.s	_strscmpi1
_strscmpi2	pull	a0-a1/d0-d1
		rts

	    endc


	    ifd	    _STRFskipblk

_STRskipblk	moveq	#0,d0
_sskipblk1	cmp.b	#32,(a0)
		beq.s	_sskipblk2
		cmp.b	#10,(a0)
		beq.s	_sskipblk2
		cmp.b	#9,(a0)
		beq.s	_sskipblk2
		rts
_sskipblk2	addq.l	#1,a0
		addq.l	#1,d0
		bra	_sskipblk1

	    endc


	    ifd	    _STRFisblank

_STRisblank	cmp.b	#32,d0
		beq.s	_isblank1
		cmp.b	#10,d0
		beq.s	_isblank1
		cmp.b	#9,d0
_isblank1	rts

	    endc


	    ifd	    _STRFsblk

_STRsblk	move.w	d0,-(sp)
_STRsblk1	move.b	(a0)+,d0
		cmp.b	#32,d0
		beq.s	_STRsblk1
		cmp.b	#10,d0
		beq.s	_STRsblk1
		cmp.b	#9,d0
		beq.s	_STRsblk1
		move.w	(sp)+,d0
		subq.w	#1,a0
		rts

	    endc


	    ifd	    _STRFstrlen

_STRstrlen	move.l	a0,d0
_strlen1	tst.b	(a0)+
		bne.s	_strlen1
		sub.l	a0,d0
		addq.l	#1,d0
		neg.l	d0
		rts

	    endc


	    ifd	   _STRFstrnth

_STRstrnth1	tst.b	(a0)+
		bne.s	_STRstrnth1
_STRstrnth	dbf	d0,_STRstrnth1
		rts

	    endc


	    ifd	   _STRFstrcmp

_STRstrcmp	push	a0-a1/d0-d1
_strcmp1	move.b	(a0)+,d0	cmp str(a0),str(a1)
		beq.s	_strcmpe1
		move.b	(a1)+,d1
		beq.s	_strcmpe2
		cmp.b	d0,d1
		beq.s	_strcmp1
_strcmpe	pull	a0-a1/d0-d1
		rts
_strcmpe1	tst.b	(a1)+
		beq.s	_strcmpe
		moveq.l	#1,d0
		bra.s	_strcmpe
_strcmpe2	moveq.l	#-1,d0
		bra.s	_strcmpe

	    endc


	    ifd	   _STRFstrcmpi

_STRstrcmpi	push	a0-a1/d0-d1
_strcmpi1	move.b	(a0)+,d0	cmp str(a0),str(a1)
		beq.s	_strcmpie1
		cmp.b	#'A',d0
		blo.s	_strcmpi1a
		cmp.b	#'Z',d0
		bhi.s	_strcmpi1a
		add.b	#32,d0
_strcmpi1a	move.b	(a1)+,d1
		beq.s	_strcmpie2
		cmp.b	#'A',d1
		blo.s	_strcmpi1b
		cmp.b	#'Z',d1
		bhi.s	_strcmpi1b
		add.b	#32,d1
_strcmpi1b	cmp.b	d0,d1
		beq.s	_strcmpi1
_strcmpie	pull	a0-a1/d0-d1
		rts
_strcmpie1	tst.b	(a1)+
		beq.s	_strcmpie
		moveq.l	#1,d0
		bra.s	_strcmpie
_strcmpie2	moveq.l	#-1,d0
		bra.s	_strcmpie

	    endc


	    ifd	    _STRFstable

_STRstable	push	a1-a2/d0-d2
		move.l	a0,a2		;a0=string, a1=list, d0=modulo
		move.l	d0,d2
_stable1	move.l	a2,a0		;restore string pointer
		tst.b	(a1)
		beq.s	_stable5	;end of table?
_stable2	cmpm.b	(a0)+,(a1)+
		bne.s	_stable3	;difference found
		tst.b	-1(a0)
		bne.s	_stable2	;end of string?
		move.l	a1,a0		;return data pointer
_stable0	move.l	a0,d0		;data ptr in a0, =0 if not fnd
		pull	a1-a2/d0-d2
		rts
_stable3	subq.w	#1,a1
_stable4	tst.b	(a1)+
		bne.s	_stable4
		add.l	d2,a1		;add modulo
		bra.s	_stable1	;next string
_stable5	sub.l	a0,a0		;string not found
		bra.s	_stable0

	    endc


	    ifd    _STRFaddslash

_STRaddslash	tst.b	(a0)+
		bne.s	_STRaddslash
		subq.w	#2,a0
		cmp.b	#':',(a0)
		beq.s	_addslash2
		cmp.b	#'/',(a0)+
		beq.s	_addslash3
		move.b	#'/',(a0)+
		clr.b	(a0)
		rts
_addslash2	addq.w	#1,a0
_addslash3	rts

	    endc


	    ifd    _STRFchkslash

_STRchkslash	move.l	a0,-(sp)
_chkslash1	tst.b	(a0)+
		bne.s	_chkslash1
		subq.w	#2,a0
		cmp.b	#':',(a0)
		beq.s	_chkslash2
		cmp.b	#'/',(a0)
		beq.s	_chkslash2
		cmp.b	d0,d0		;EQ
		move.l	(sp)+,a0
		rts
_chkslash2	cmp.b	#'.',(a0)	;NE
		move.l	(sp)+,a0
		rts

	    endc


	    ifd    _STRFremslash

_STRremslash	tst.b	(a0)+
		bne.s	_STRremslash
		subq.w	#2,a0
		cmp.b	#'/',(a0)+
		bne.s	_remslash1
		clr.b	-(a0)
_remslash1	rts

	    endc


	    ifd    _STRFextfname

_STRextfname	push	d0/a1
		move.l	a0,a1
_extfname1	tst.b	(a0)+
		bne.s	_extfname1
_extfname2	move.b	-(a0),d0
		cmp.b	#':',d0
		beq.s	_extfname3
		cmp.b	#'/',d0
		beq.s	_extfname3
		cmp.l	a0,a1
		bne.s	_extfname2
		subq.w	#1,a0
_extfname3	addq.w	#1,a0
		pull	d0/a1
		rts

	    endc


	    ifd    _STRFremsuffix

_STRremsuffix	push	a1-a2		a0=string
		move.l	a0,a1
1$		tst.b	(a0)+
		bne.s	1$
		lea	-1(a0),a2	end NULL of string
2$		cmpi.b	#'.',-(a0)
		beq.s	3$
		cmp.l	a1,a0
		bhi.s	2$
		move.l	a2,a0		no suffix found
3$		clr.b	(a0)
		pull	a1-a2
		rts

	    endc


	    ifd    _STRFaddsuffix

_STRaddsuffix	push	d0		a1=dest; a0=suffix
10$		move.b	(a1)+,d0
		beq.s	11$
		cmp.b	#'.',d0
		bne.s	10$
11$		move.b	#'.',-1(a1)
12$		move.b	(a0)+,(a1)+
		bne.s	12$
		pull	d0
		rts

	    endc


	endm

