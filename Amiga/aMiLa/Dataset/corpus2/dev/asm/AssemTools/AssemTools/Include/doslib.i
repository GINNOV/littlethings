* include file for Amiga metacc macro assembler *
* created 21.01.89 TM - Supervisor Software *
* for handling Dos events *

* Vers. 1.23 *

;created "doslib, ioerr, isend" -> v1.0 21.01.89
;added "adddir, addpath" -> v1.01 21.01.89
;adapted "filelength" from JM -> v1.02 16.02.89
;debugt "filelength" -> v1.03 21.02.89
;created "followthread" -> v1.04 1.3.89
;added sortentry.comments -> v1.05 4.3.89
;"followthread" debugt -> v1.06 12.3.89
;"followthread" debugt -> v1.07 12.3.89
;created "typeout" -> v1.08 11.5.89
;edited "addpath" -> v1.09 15.5.89 by JM
;debugt "addpath", changed "followthread" not to
;  alloc FIB from stack -> v1.10 17.5.89
;"followthread" recursive -> v1.11 17.5.89
;"open" -> v1.115 18.5.89
;edited "filelength" -> v1.116 18.5.89 by jm
;debugt "open" -> v1.117 20.5.89
;debugt "open" -> v1.1175 21.5.89
;created "error, getcli, request, cmdname" -> v1.12 13.06.89
; -"- "infos" -> v1.121 13.6.89
;debugt "infos, open", "getdate" created -> v1.122 14.6.89
;debugt "filelength" by jm -> v1.123 16.6.89
;created "readfile, alloc, dpy_err, dpy_msg, err_lock",
;"err_mem, err_read" -> v1.13 20.06.89
;"open" debugt -> v1.2 26.06.89
;"err_#?" debugt -> v1.21 27.06.89
;"err_writ, close" created, empty files as default channels
;  added to "open" -> v1.22 14.07.89
;"open" debugt (quiet & append now work together) -> v1.23 03.08.89


*T
*T	DOSLIB.I * Metacc Include File
*T		 Version 1.23
*T	        Date 03.08.89
*T
*B

;  ioerr	(get IoErr code and convert to string)
;  in:		a0=place_for_string;
;  call:	doslib	ioerr;
;  out:		a0=*(NULL); d0=ioerr;
;  notes:	/the format is as/
;		/sprintf(" - Error code %i",IoErr());/
;		/numlib, handler must be included/;

;  isend	(skip blanks - end of command line? (0/";"))
;  in:		a0=ptr;
;  call:	doslib	isend;
;  out:		a0=ptr;
;  notes:	/strlib must be included/;

;  adddir	(move to directory)
;  in:		a0=dir_name;
;  call:	doslib	adddir;
;  out:		a0=dir_name; d0=success (0=fail);
;  notes:	/locks the new, unlocks the old/;

;  addpath	(add a dirname to path)
;  in:		a0=dir_name; a1=pathname_string;
;  call:	doslib	addpath;
;  out:		a0=dir_name; a1=pathname_string;
;  notes:	/a masterpiece - handles also parent-dirs,/
; 		/device names, rootdirs, subdirectories and yet/
; 		/all these together/
;		/strlib must be included/;

;  filelength	(find out length of a file)
;  in:		a0=file_name;
;  call:	doslib	filelength;
;  out:		d0=file_length; /-1 = error/

;  followthread	(follow the directory thread to root)
;  in:		d1=lock; a0=*name_buffer, d0=buf_length;
;  call:	doslib	followthread;
;  out:		p.c=error; (c=1 if failed)
;  notes:	/the lock is not unlock()ed during process/

;  typeout	(type a text into the current default output file)
;  in:		a0=*text;
;  call:	doslib	typeout;
;  notes:	/if the Output() returns a NULL, no text
;  		 is output. The text is written line-by-
;  		 line, thus permitting the user to inter-
;  		 rupt the output by entering a character
;  		 into the console./

;  open		(open a file and display possible errors)
;  in:		a0=*name, d0=access_mode;
;  call:	doslib	open;
;  out:		d0=file; /NULL==error/
;  notes:	/access_mode =	0:  Read
;  				1:  Write
;  				2:  Append
;  				8:  Quiet (or'ed with others)/
;  		/if no filename is present, the default IO
;  		 channel (Input(), Output()) is used./
;  		/doslib CLOSE should be used for closing the
;  		 file./
;		/needs execlib, handler/

;  close	(close a file)
;  in:		d0=*file;
;  call:	doslib	close;
;  notes:	/does not attempt to close Input(), Output()
;		 or NULL/

;  getdate	(convert a datestamp)
;  in:		a0=*datestamp;
;  call:	doslib	getdate;
;  out:		d0=year, d1=month /1..12 Jan..Dec/,
;		d2=day_of_month, d3=day_of_week /0..6 Mon..Fri/;

;  fmtdate	(format a date)
;  in:		a0=*datestamp; a1=*output_buffer;
;		a2=*format, a3=*parameters;
;  call:	doslib	fmtdate;
;  out:		a1=*NULL;
;  notes:	/"format" contains an ordinary "sformat" string
;		defining how the parameters are formatted/
;		/"parameters" is a character queue containing
;		the following characters:
;		y - number of year	Y - the last two digits
;		m - number of month	M - name of month
;		d - day-of-month	D - name of day-of-week
;		The characters M and D require a %s declaration
;		in the "format", the others a (word) %d./

;  getcli	(get the address of CLIStruct)
;  call:	doslib	getcli;
;  out:		a0=*clistruct; /0 if not a cli process/
;  notes:	/flags set according to the result/

;  error	(set/read the dos error return code)
;  in:		d0=error;
;  call:	doslib	error;
;  out:		d0=old_error;
;		p.c=failed /C is set if not a CLI process/

;  findproc	(find a cli process by the number)
;  in:		d0=number;
;  call:	doslib	findproc;
;  out:		a0=d0=*task; /NULL if error/

;  cmdname	(get the current command name)
;  in:		a0=*buffer;
;  call:	doslib	cmdname;
;  out:		a0=*end_of_name==*NULL;

;  request	(set/read requester window pointer)
;  in:		d0=*window;
;  call:	doslib	request;
;  out:		d0=*old_window;
;  notes:	/the pointers are in data register because
;		there are two values with a special meaning:
;		0	No default window. The requesters ap-
;			pear into the WorkBench screen.
;		-1	No requesters are displayed./

;  infos	(type info/finfo/sinfo texts)
;  in:		a0=*cmdlin, a1=*usage, a2=*finfo_info;
;  call:	doslib	infos;
;  out:		d0=flag /==0 if nothing done/
;  notes:	/at the address a2 is give the "finfotx",
;		then NULL, then "infotxt" and another null./
;		/The string at a1 does not contain the word
;		"usage" or the command name./

;  alloc	(allocate memory and argue if not got)
;  in:		d0=bytesize, d1=requirements;
;  call:	doslib	alloc;
;  out:		a0=d0=location;

;  readfile	(allocate a buffer and read a file into it)
;  in:		a0=*name; d0=mode; /d0=0 or d0=open_quiet/
;  call:	doslib	readfile;
;  out:		d0=*buffer /0=error/

;  dpy_msg	(display a formatted message)
;  in:		a0=*format_string; d0..d7=parameters;
;  call:	doslib	dpy_msg;

;  dpy_err	(display a formatted error message)
;  in:		a0=*format_string; d0..d7=parameters;
;  call:	doslib	dpy_err;
;  notes:	/" - error code %d\n" will be automatically
;		added before printing/

;  err_lock	(display "unable to get information")
;  in:		a0=*name;
;  call:	doslib	err_lock;

;  err_mem	(display "unable to allocate memory")
;  in:		d0=*size;
;  call:	doslib	err_mem;

;  err_read	(display "error reading file")
;  in:		a0=*name;
;  call:	doslib	err_read;

;  err_writ	(display "error writing file")
;  in:		a0=*name;
;  call:	doslib	err_writ;


*E


doslib		macro	routine
		ifnc	'\1',''
		bsr	_DOS\1
_DOSF\1		set	-1
		mexit
		endc

		ifd	_DOSFreadfile
_DOSreadfile	push	a0-a3/d1-d5
		move.l	d0,d5
		move.l	a0,a3
		doslib	filelength
		tst.l	d0
		bmi	_DOSreadfile.e1
		addq.l	#8,d0
		move.l	d0,d2
		moveq	#1,d1
		tst.b	d5
		bne.s	_DOSreadfile1
		doslib	alloc
		bra.s	_DOSreadfile2
_DOSreadfile1	execlib	alloc
_DOSreadfile2	move.l	d0,a2
		tst.l	d0
		beq.s	_DOSreadfile.e
		move.l	d5,d0
		and.b	#$f8,d0
		move.l	a3,a0
		doslib	open
		move.l	d0,d4
		beq.s	_DOSreadfile.e
		move.l	d0,d1
		move.l	d2,d3
		move.l	a2,d2
		lib	Dos,Read
		ph	d0
		move.l	d4,d1
		lib	Dos,Close
		pl	d0
		bmi.s	_DOSreadfile.e2
		move.l	d2,a0
		clr.b	0(a0,d0.l)
		move.l	a2,d0
_DOSreadfile0	pull	a0-a3/d1-d5
		rts
_DOSreadfile.e	moveq	#0,d0
		bra.s	_DOSreadfile0
_DOSreadfile.e1	tst.b	d5
		bne.s	_DOSreadfile.e
		move.l	a3,a0
		doslib	err_lock
		bra.s	_DOSreadfile.e
_DOSreadfile.e2	tst.b	d5
		bne.s	_DOSreadfile.e
		move.l	a3,a0
		doslib	err_read
		bra.s	_DOSreadfile.e
		endc

		ifd	_DOSFalloc
_DOSalloc	move.l	d0,-(sp)
		execlib	alloc
		tst.l	d0
		bne.s	_DOSalloc0
		move.l	(sp),d0
		doslib	err_mem
		moveq	#0,d0
		sub.l	a0,a0
_DOSalloc0	addq.w	#4,sp
		rts
		endc

		ifd	_DOSFerr_mem
_DOSerr_mem	push	a0-a1/d0-d1
		lstr	a0,<'Unable to allocate memory %ld bytes%'>
		doslib	dpy_msg
		pull	a0-a1/d0-d1
		rts
		endc

		ifd	_DOSFerr_lock
_DOSerr_lock	push	a0-a1/d0-d1
		move.l	a0,d0
		lstr	a0,<'Unable to get information for "%s"'>
		doslib	dpy_err
		pull	a0-a1/d0-d1
		rts
		endc

		ifd	_DOSFerr_read
_DOSerr_read	push	a0-a1/d0-d1
		move.l	a0,d0
		lstr	a0,<'Error reading file "%s"'>
		doslib	dpy_err
		pull	a0-a1/d0-d1
		rts
		endc

		ifd	_DOSFerr_writ
_DOSerr_writ	push	a0-a1/d0-d1
		move.l	a0,d0
		lstr	a0,<'Error writing file "%s"'>
		doslib	dpy_err
		pull	a0-a1/d0-d1
		rts
		endc

		ifd	_DOSFdpy_msg
_DOSdpy_msg	push	a0-a1/d0-d1
		link	a2,#-256
		move.l	sp,a1
		execlib	sformat
		move.l	sp,a0
		doslib	typeout
		unlk	a2
		pull	a0/a1/d0-d1
		rts
		endc

		ifd	_DOSFdpy_err
_DOSdpy_err	push	a0-a1/d0-d1
		link	a2,#-256
		move.l	sp,a1
		execlib	sformat
		doslib	ioerr
		move.b	#10,(a0)+
		clr.b	(a0)
		move.l	sp,a0
		doslib	typeout
		unlk	a2
		pull	a0/a1/d0-d1
		rts
		endc

		ifd	_DOSFfmtdate
_DOSfmtdate	push	a0/a2-a5/d0-d7
		doslib	getdate
		move.l	a2,a0
		lea.l	-32(sp),sp
		move.l	sp,a2
_DOSfmtdate1	move.b	(a3)+,d4
		beq.s	_DOSfmtdate.f
		cmp.b	#'y',d4
		bne.s	_DOSfmtdate2
		move.w	d0,(a2)+
		bra.s	_DOSfmtdate1
_DOSfmtdate2	cmp.b	#'Y',d4
		bne.s	_DOSfmtdate3
		move.l	d0,d4
		divu.w	#100,d4
		swap	d4
		move.w	d4,(a2)+
		bra.s	_DOSfmtdate1
_DOSfmtdate3	cmp.b	#'m',d4
		bne.s	_DOSfmtdate4
		move.w	d1,(a2)+
		bra.s	_DOSfmtdate1
_DOSfmtdate4	cmp.b	#'M',d4
		bne.s	_DOSfmtdate5
		push	a0/d0
		lea.l	_DOSfmtdate.t1(pc),a0
		move.w	d1,d0
		subq.w	#1,d0
_DOSfmtdate4b	strlib	strnth
		move.l	a0,(a2)+
		pull	a0/d0
		bra.s	_DOSfmtdate1
_DOSfmtdate5	cmp.b	#'d',d4
		bne.s	_DOSfmtdate6
		move.w	d2,(a2)+
		bra	_DOSfmtdate1
_DOSfmtdate6	cmp.b	#'D',d4
		bne.s	_DOSfmtdate.f
		push	a0/d0
		lea.l	_DOSfmtdate.t2(pc),a0
		move.w	d3,d0
		bra.s	_DOSfmtdate4b
_DOSfmtdate.f	move.l	sp,a2
		execlib	format
		lea.l	32(sp),sp
		pull	a0/a2-a5/d0-d7
		rts
_DOSfmtdate.t1	dc.b	'January',0,'February',0,'March',0,'April',0
		dc.b	'May',0,'June',0,'July',0,'August',0
		dc.b	'September',0,'October',0,'November',0,'December',0
_DOSfmtdate.t2	dc.b	'Monday',0,'Tuesday',0,'Wednesday',0
		dc.b	'Thursday',0,'Friday',0,'Saturday',0,'Sunday',0
		ds.w	0
		endc

		ifd	_DOSFopen
_DOSopen	push	d1-d3/a0-a3
		tst.b	(a0)
		beq	_DOSopen_d
		move.l	a0,d1
		move.l	d0,d2
		move.l	a0,a2
		move.l	d0,d3
		and.w	#3,d2
		add.w	#1005,d2
		cmp.w	#1007,d2
		bne.s	_DOSopen_1
		subq.l	#2,d2
_DOSopen_1	lib	Dos,Open
_DOSopen_.5	tst.l	d0
		bne	_DOSopen0
		btst	#3,d3
		bne	_DOSopen1b
		link	a3,#-256
		move.l	sp,a1
		move.l	a2,d0
		lstr	a0,<'input'>
		tst.b	d3
		beq.s	_DOSopen1
		lstr	a0,<'output'>
		cmp.b	#1,d3
		beq.s	_DOSopen1
		lstr	a0,<'append'>
_DOSopen1	move.l	a0,d1
		lstr	a0,<'Unable to open "%s" for %s'>
		execlib	sformat
		doslib	ioerr
		doslib	error
		plf	a0
		pnull	a0
		move.l	sp,a0
		printa	a0
		unlk	a3
_DOSopen1b	moveq	#0,d0
		bra.s	_DOSopen00
_DOSopen0	btst	#1,d3		;append?
		beq.s	_DOSopen00
		ph	d0
		move.l	d0,d1
		moveq	#0,d2
		moveq	#1,d3
		lib	Dos,Seek
		pl	d0
_DOSopen00	pull	d1-d3/a0-a3
		tst.l	d0
		rts
_DOSopen_d	; open default channel
		move.l	d0,d3
		and.w	#3,d0
		bne.s	1$
		lib	Dos,Input
		bra.s	2$
1$		lib	Dos,Output
2$		lea.l	3$(pc),a2
		bra	_DOSopen_.5
3$		dc.b	'*',0	;length even, no pad
		endc

		ifd	_DOSFclose
_DOSclose	push	d0-d2/a0-a1
		move.l	d0,d2	;if null, dnt close
		beq.s	_DOSclose0
		lib	Dos,Input
		cmp.l	d0,d2	;if deflt input, dnt close
		beq.s	_DOSclose0
		flib	Dos,Output
		cmp.l	d0,d2	;if deflt output, dnt close
		beq.s	_DOSclose0
		move.l	d2,d1
		flib	Dos,Close	;do close
_DOSclose0	pull	d0-d2/a0-a1
		rts
		endc

		ifd	_DOSFinfos
_DOSinfos	push	a0-a1/d0-d1
		move.b	(a0),d0
		cmp.b	#'*',d0
		beq.s	_DOSinfos.s
		cmp.b	#'!',d0
		beq.s	_DOSinfos.f
		cmp.b	#'?',d0
		beq.s	_DOSinfos.i
		pull	a0-a1/d0-d1
		moveq	#0,d0
		rts
_DOSinfos.f	move.l	a2,a0
		doslib	typeout
_DOSinfos.i	bsr.s	_DOSinfos.s1
		move.l	a2,a0
_DOSinfos.i1	tst.b	(a0)+
		bne.s	_DOSinfos.i1
		doslib	typeout
_DOSinfos.x	pull	a0-a1/d0-d1
		moveq	#-1,d0
		rts
_DOSinfos.s	pea.l	_DOSinfos.x(pc)
_DOSinfos.s1	push	a2-a3
		move.l	a1,a3
		move.l	#256,d0
		moveq	#1,d1
		lib	Exec,AllocMem
		tst.l	d0
		beq.s	_DOSinfos.s3
		move.l	d0,a2
		move.l	a2,a0
		move.l	#'Usag',(a0)+
		move.l	#'e: .',(a0)+
		subq.w	#1,a0
		doslib	cmdname
_DOSinfos.s2	move.b	(a3)+,(a0)+
		bne.s	_DOSinfos.s2
		move.b	#LF,-1(a0)
		clr.b	(a0)
		move.l	a2,a0
		doslib	typeout
		move.l	a2,a1
		move.l	#256,d0
		lib	Exec,FreeMem
_DOSinfos.s3	pull	a2-a3
		rts
		endc

		ifd	_DOSFgetdate
_DOSgetdate	push	d4-d7	;d7=n	d6=y	d5=m	d4=d
		move.l	(a0),d0
		sub.l	#2251,d0
		move.l	d0,d7
		add.l	d0,d0
		add.l	d0,d0
		addq.l	#3,d0
		divs	#1461,d0
		ext.l	d0
		move.l	d0,d6
		muls.w	#1461,d0
		asr.l	#2,d0
		sub.l	d0,d7
		add.l	#1984,d6
		move.l	d7,d0
		muls.w	#5,d0
		addq.l	#2,d0
		divs.w	#153,d0
		ext.l	d0
		move.l	d0,d5
		muls.w	#153,d0
		addq.l	#2,d0
		divs.w	#5,d0
		move.l	d7,d1
		sub.l	d0,d1
		addq.l	#1,d1
		move.l	d1,d4
		addq.l	#3,d5
		cmp.l	#12,d5
		bls.s	_DOSgetdate1
		addq.l	#1,d6
		sub.l	#12,d5
_DOSgetdate1	move.l	d6,d0	;year
		move.l	d5,d1	;month
		move.l	d4,d2	;day-of-month
		ext.l	d2
		move.l	(a0),d3
		subq.l	#1,d3
		divu.w	#7,d3
		swap	d3
		ext.l	d3	;day-of-week
		pull	d4-d7
		rts
		endc

		ifd	_DOSFcmdname
_DOScmdname	push	a1/d0-d1
		move.l	a0,a1
		doslib	getcli
		beq.s	_DOScmdname0
		move.l	16(a0),a0
		add.l	a0,a0
		add.l	a0,a0
		move.b	(a0)+,d0
		beq.s	_DOScmdname0
_DOScmdname1	move.b	(a0)+,(a1)+
		subq.b	#1,d0
		bne.s	_DOScmdname1
_DOScmdname0	move.l	a1,a0
		clr.b	(a0)
		pull	a1/d0-d1
		rts
		endc

		ifd	_DOSFfindproc
_DOSfindproc	lbase	Dos,a0
		move.l	34(a0),a0
		move.l	(a0),a0
		add.l	a0,a0
		add.l	a0,a0
		cmp.l	(a0),d0
		bhi.s	_DOSfindproc0	;proc #>max
		add.l	d0,d0
		add.l	d0,d0
		move.l	0(a0,d0.l),d0
		beq.s	_DOSfindproc0
		sub.l	#92,d0
_DOSfindproc1	move.l	d0,a0
		rts
_DOSfindproc0	moveq	#0,d0
		bra.s	_DOSfindproc1
		endc

		ifd	_DOSFrequest
_DOSrequest	push	d1-d2/a0-a1
		move.l	d0,d2
		sub.l	a1,a1
		lib	Exec,FindTask
		move.l	d0,a0
		move.l	$80+56(a0),d0
		move.l	d2,$80+56(a0)
		pull	d1-d2/a0-a1
		tst.l	d0
		rts
		endc

		ifd	_DOSFtypeout
_DOStypeout	push	d0-d3/a0-a2
		move.l	a0,a2
_DOStypeout1	tst.b	(a2)
		beq.s	_DOStypeout0
		lib	Dos,Output
		move.l	d0,d1
		beq.s	_DOStypeout0
		move.l	a2,d2
		moveq	#0,d3
_DOStypeout2	move.b	(a2)+,d0
		beq.s	_DOStypeout3
		addq.l	#1,d3
		cmp.b	#10,d0
		bne.s	_DOStypeout2
		addq.w	#1,a2
_DOStypeout3	subq.w	#1,a2
		lib	Dos,Write
		bra.s	_DOStypeout1
_DOStypeout0	pull	d0-d3/a0-a2
		rts
		endc

		ifd	_DOSFfollowthread
_DOSfollowthread push	all
		move.w	d0,d5	;buf
		move.l	a0,a5	;buflen
		bsr	_DOSfollthre.s
		bcs.s	_DOSfollthre.re
		tst.w	d5
		beq.s	_DOSfollthre.re
		clr.b	(a5)
		clrc
		pull	all
		rts
_DOSfollthre.re	setc
		pull	all
		rts
_DOSfollthre.s	push	d0-d4/a0-a4
		move.l	d1,d3	;lock
		move.l	#268,d0
		moveq	#1,d1
		lib	Exec,AllocMem
		move.l	d0,d4
		beq	_DOSfollthre.me
		move.l	d3,d1
		move.l	d4,d2
		lib	Dos,Examine
		tst.l	d0
		beq	_DOSfollthre.e
		move.l	d3,d1
		lib	Dos,ParentDir
		move.l	d0,d2
		beq.s	_DOSfollthre.rt
		move.l	d0,d1
		bsr.s	_DOSfollthre.s	;recall
		bcc.s	_DOSfollthre.s3
		move.l	d2,d1
		lib	Dos,UnLock
		bra.s	_DOSfollthre.e
_DOSfollthre.s3	move.l	d4,a0
		lea.l	8(a0),a1
_DOSfollthre.s1	move.b	(a1)+,d0
		beq.s	_DOSfollthre.s2
		bsr	_DOSfollthre.pc
		bra.s	_DOSfollthre.s1
_DOSfollthre.s2	tst.l	4(a0)
		bmi.s	_DOSfollthre.fi
		moveq	#'/',d0
		bsr	_DOSfollthre.pc
		bra.s	_DOSfollthre.fi
_DOSfollthre.rt	move.l	d4,a0
		lea.l	8(a0),a1
_DOSfollthre.r1	move.b	(a1)+,d0
		beq.s	_DOSfollthre.r2
		bsr	_DOSfollthre.pc
		bra.s	_DOSfollthre.r1
_DOSfollthre.r2 moveq	#':',d0
		bsr	_DOSfollthre.pc
_DOSfollthre.fi	move.l	d2,d1
		lib	Dos,UnLock
		move.l	d4,a1
		move.l	#268,d0
		lib	Exec,FreeMem
		pull	d0-d4/a0-a4
		clrc
		rts
_DOSfollthre.e	move.l	d4,a1
		move.l	#268,d0
		lib	Exec,FreeMem
_DOSfollthre.me	pull	d0-d4/a0-a4
		setc
		rts
_DOSfollthre.pc	tst.w	d5
		beq.s	_DOSfollthre.pc1
		move.b	d0,(a5)+
		subq.w	#1,d5
_DOSfollthre.pc1 rts
		endc

		ifd	_DOSFioerr
_DOSioerr	push	a1/d1
		pstr	a0,<' - Error code '>
		ph	a0
		lib	Dos,IoErr
		pl	a0
		numlib	sput10
		pull	a1/d1
		rts
		endc

		ifd	_DOSFerror
_DOSerror	push	a0-a1/d1
		move.l	d0,d1
		doslib	getcli
		setc
		beq.s	_DOSerror0
		move.l	(a0),d0
		move.l	d1,(a0)
		tst.l	d0
_DOSerror0	pull	a0-a1/d1
		rts
		endc

		ifd	_DOSFgetcli
_DOSgetcli	push	a1/d0-d1
		sub.l	a1,a1
		lib	Exec,FindTask
		move.l	d0,a0
		move.l	$80+44(a0),d0
		add.l	d0,d0
		add.l	d0,d0
		move.l	d0,a0
		pull	a1/d0-d1
		rts
		endc

		ifd	_DOSFisend
_DOSisend	strlib	sblk
		tst.b	(a0)
		beq.s	_DOSisend1
		cmp.b	#';',(a0)
_DOSisend1	rts
		endc

		ifd	_DOSFadddir
_DOSadddir	move.l	a0,-(sp)
		move.l	a0,d1
		moveq	#-2,d2
		lib	Dos,Lock
		move.l	d0,d1
		beq.s	_adddir1
		lib	Dos,CurrentDir
		move.l	d0,d1
		lib	Dos,UnLock
		moveq	#-1,d0
_adddir1	move.l	(sp)+,a0
		rts
		endc

		ifd	_DOSFaddpath
_DOSaddpath	push	a0-a2
_addpath0	tst.b	(a0)
		beq	_addpath9
		cmp.b	#'/',(a0)
		bne.s	_addpath1
		exg	a0,a1		a0 begins with a /
		move.l	a0,-(sp)
		strlib	remslash	remove from a1
		move.l	(sp),a0
		strlib	extfname	remove last dirname from a1
		tst.b	(a0)
		beq.s	_addpath1b
		lea	1(a1),a1	skip first / in a0
_addpath1c	clr.b	(a0)
		move.l	(sp)+,a0
		exg	a1,a0
		bra.s	_addpath0
_addpath1b	move.b	(a1)+,(a0)+	if we could not remove latdir,
		bra.s	_addpath1c	vanillacopy '/'
_addpath1	cmp.b	#':',(a0)
		bne.s	_addpath2	a0 begins with a :
		move.b	(a0)+,(a1)	copy : to dest
		clr.b	1(a1)
		bra.s	_addpath0
_addpath2	move.l	a0,a2
		move.l	a1,-(sp)
		exg	a0,a1
		strlib	addslash	add slash to a1 if needed
		exg	a0,a1
_addpath3	move.b	(a0)+,d0	if not : or /
		cmp.b	#'/',d0
		beq.s	_addpath7
		cmp.b	#':',d0
		beq.s	_addpath6
		move.b	d0,(a1)+	copy path to end of a1
		bne.s	_addpath3
_addpath5	move.l	(sp)+,a1
_addpath9	pull	a0-a2
		rts
_addpath7	clr.b	(a1)
_addpath4	move.l	(sp)+,a1	original a1
		bra	_addpath0
_addpath6	move.l	(sp),a1		original a1
		move.l	a2,a0		original a0
_addpath8	move.b	(a0)+,d0
		move.b	d0,(a1)+	copy until : or NULL
		beq.s	_addpath5
		cmp.b	#':',d0
		bne.s	_addpath8
		bra.s	_addpath7
		endc

		ifd	_DOSFfilelength
_DOSfilelength	push	d1-d3/a0-a2/a6
		move.l	a0,d3
		ifnd	fib_SIZEOF
fib_SIZEOF	set	260
		endc
		move.l	#fib_SIZEOF+8,d0
		moveq	#1,d1
		lib	Exec,AllocMem
		tst.l	d0
		beq.s	3$			-> no mem gotten
		move.l	d0,a2			fib*
		move.l	d3,d1			name*
		moveq.l	#-2,d2			ACCESS_READ -> -2
		lib	Dos,Lock
		move.l	d0,d3			lock*
		beq.s	2$
		move.l	d3,d1
		move.l	a2,d2
		flib	Dos,Examine
		move.l	d0,d2
		move.l	d3,d1
		flib	Dos,UnLock
		tst.l	d2
		beq.s	2$
		move.l	124(a2),d3		file size, fib_Size -> 124
		bra.s	1$
2$		moveq.l	#-1,d3			error: cannot examine
1$		move.l	a2,a1
		move.l	#fib_SIZEOF+8,d0
		lib	Exec,FreeMem
		move.l	d3,d0
		pull	d1-d3/a0-a2/a6
		rts
3$		pull	d1-d3/a0-a2/a6
		moveq	#-2,d0			error: no mem
		rts
		endc

		endm


