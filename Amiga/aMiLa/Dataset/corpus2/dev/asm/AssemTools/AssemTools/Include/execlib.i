
* Include file for Amiga metacc macro assembler *
* created 04.03.89 TM - Supervisor Software *
* for handling Exec events *

*T
*T	EXECLIB.I * Metacc Include File
*T		Version 1.09
*T	      Date 02.07.1989
*T

;  "alloc, free, stop" created -> v1.00 04.03.89
;  "createport, deleteport, createio, deleteio"
;     adapted from JM -> v1.01 05.03.89
;  "stop" changed for a68k, '.l''s remvd -> v1.02 17.03.89
;  "free" modified to return no NULL in a0
;     -> v1.03 08.04.89
;  "format, sformat" created -> v1.04 01.05.89
;  "format, sformat" modified:
;     -result to a0,a1 (formerly only a0)
;     -result is the right one now
;     -> v1.05 01.05.89
;  "alloc" debugt; now allocates 4 bytes more than the given
;     amount for industry needs -> v1.06 27.05.89
;  "c-, d-port, c-, d-io" modified not to need any special
;     includes -> v1.07 12.06.89
;  "beep" from jm (what a WORK to change not to need those
;     stupid includes, phew!) -> v1.08 12.06.89
;  "beep" debugt -> v1.085 12.06.89
;  "createport" debugged by jm -> v1.07 01.07.1989



*B

;  alloc	(allocate memory)
;  in:		d0=bytesize; d1=requirements;
;  call:	execlib	alloc;
;  out:		a0=d0=*memory;
;  notes:	/allocates 4 bytes more and saves/
;		/the length, like util.i's/

;  free		(free memory)
;  in:		a0=*memory;
;  call:	execlib	free;
;  notes:	/frees that being allocated by alloc/
;  		/doesn't care even if the pointer be/
;  		/NULL - just doesn't free it/

;  stop		(check whether SIGBREAKB_CTRL_C set)
;  call:	execlib stop;
;  out:		p.z=(boolean) result; /z=0: stop/

;  format	(format a string)
;  in:		a0=*format_string;
;  		a1=*output_buffer;
;  		a2=*data_stream;
;  call:	execlib	format;
;  out:		a0=a1=*output_buffer_end==*(NULL);
;  notes:	/data_stream may contain either words,
;  		longwords, or both. The 'l' specifiers
;  		must be used accordingly./
;  		/The format for the item specifier is:
;  		  %-0xxx.yyylc
;  		where
;  		  '-' , if specified, left-aligns the value,
;  		  '0' right-aligns the value filling the
;  		      opening space with zeros,
;  		  'xxx' and 'yyy' are the field widths,
;  		  'l' is a longword specifer, and
;  		  'c' is one of the following:
;  		     's': string output, pointer in data stream
;  		          pointer is supposed to be 'l' even if
;  		          the specifier were not used.
;  		     'c': single character output
;  		     'd': decimal value output
;  		     'x': hexadecimal value output/

;  sformat	(format a string)
;  in:		a0=*format_string;
;  		a1=*output_buffer;
;  		d0..d7=data;
;  call:	execlib sformat;
;  out:		a0=a1=*output_buffer_end==*(NULL);
;  notes:	/the same as "format", but the data is
;  		given in data registers, from d0 and higher,
;  		instead of a specific data stream. All the
;  		data must be specified as longwords, with the
;  		'l' specifier, since the data is entered into
;  		a temporary data stream allocated from stack./

;  beep		(beep)
;  in:		d0=(uword) period, d1=(uword) cycles;
;  call:	execlib	beep;
;  out:		d0=success; /0 = error/
;  notes:	/"cycles" defines the length of the beep/
;  		/if d0 is -1, default values are used for
;  		both the period (1050) and cycles (300)/

;  createport	(creates a message port)
;  in:		a0=*name; d0=sizeof;
;  call:	execlib createport;
;  out:		a0=d0=*port;
;  trashed:	a1, d1;

;  deleteport	(deletes a message port)
;  in:		a0=*port;
;  call:	execlib	deleteport;
;  trashed:	a0-a1, d0-d1;

;  createio	(creates an IORequest structure)
;  in:		a0=*messageport; d0=size;
;  call:	execlib	createio;
;  out:		a0=d0=*iorequest;
;  trashed:	a1, d1;

;  deleteio	(deletes an IORequest structure)
;  in:		a0=*iorequest;
;  call:	execlib	deleteio
;  trashed:	a0-a1, d0-d1;

*E


execlib		macro	name
		ifnc	'\1',''
_EXECF\1	set	1
		bsr	_EXEC\1
		mexit
		endc

		ifd	_EXECFbeep
_EXECbeep	push	d1-d7/a0-a5
		moveq	#0,d4
		cmp.w	#-1,d0
		bne.s	_EXECbeep1
		move.w	#1050,d0	;default period
		move.w	#300,d1		;default "cycles"
_EXECbeep1	move.l	d0,a5
		move.l	d1,a4
		sub.l	a3,a3		;success = false
		moveq.l	#-1,d5
		moveq.l	#34,d0
		sub.l	a0,a0
		execlib	createport
		move.l	d0,d7
		beq	_EXECbeep.c
		moveq.l	#68,d0
		move.l	d7,a0
		execlib	createio
		move.l	d0,d6
		beq.s	_EXECbeep.c
		lea.l	_EXECbeep.t2(pc),a0
		moveq.l	#0,d0
		move.l	d6,a1
		moveq.l	#0,d1
		move.b	#127,9(a1)
		lea.l	_EXECbeep.t1(pc),a2
		move.l	a2,34(a1)
		moveq.l	#4,d2
		move.l	d2,38(a1)
		lib	Exec,OpenDevice
		move.l	d0,d5
		bne.s	_EXECbeep.c
		moveq.l	#16,d3
		move.l	d4,d0
		moveq	#1!2,d1
		execlib	alloc
		move.l	d0,d4
		beq.s	_EXECbeep.c
		move.l	d4,a0
		move.l	#$80007f00,(a0)
		move.l	d6,a1
		move.l	d4,34(a1)
		moveq.l	#4,d0
		move.l	d0,38(a1)
		move.w	a5,42(a1)	;period
		move.w	a4,46(a1)	;cycles
		move.w	#64,44(a1)
		move.b	#(1<<4),30(a1)
		move.w	#3,28(a1)
		move.l	20(a1),a6
		jsr	-30(a6)
		move.l	d6,a1
		lib	Exec,WaitIO
		moveq	#-1,d0
		move.l	d0,a3		;success = true
_EXECbeep.c	tst.l	d5
		bne.s	_EXECbeep.c1
		move.l	d6,a1
		lib	Exec,CloseDevice
_EXECbeep.c1	move.l	d7,a0
		execlib	deleteport
		move.l	d6,a0
		execlib	deleteio
		move.l	d4,a0
		execlib	free
		move.l	a3,d0
		pull	d1-d7/a0-a5
		rts
_EXECbeep.t1	dc.b	1,2,4,8
_EXECbeep.t2	dc.b	'audio.device',0
		ds.w	0
		endc

		ifd	_EXECFalloc
_EXECalloc	push	a1/d1
		addq.l	#4,d0
		move.l	d0,-(sp)
		lib	Exec,AllocMem
		move.l	(sp)+,d1
		move.l	d0,a0
		tst.l	d0
		beq.s	_EXECalloc0
		move.l	d1,(a0)+
_EXECalloc0	move.l	a0,d0
		pull	a1/d1
		rts
		endc

		ifd	_EXECFfree
_EXECfree	push	d0-d1/a0-a1
		move.l	a0,d0
		beq.s	_EXECfree0
		move.l	-(a0),d0
		move.l	a0,a1
		lib	Exec,FreeMem
_EXECfree0	pull	d0-d1/a0-a1
		rts
		endc

		ifd	_EXECFstop
_EXECstop	push	d0-d1/a0-a1
		moveq.l	#0,d0
		moveq.l	#0,d1
		lib	Exec,SetSignal
		btst	#12,d0
		beq.s	_EXECstop0
		moveq.l	#0,d0
		moveq.l	#0,d1
		bset	#12,d1
		flib	Exec,SetSignal
		moveq.l	#1,d0			NE: STOP!!!
		pull	d0-d1/a0-a1
		rts
_EXECstop0	moveq.l	#0,d0			EQ: no stop
		pull	d0-d1/a0-a1
		rts
		endc

		ifd	_EXECFsformat	;a0=*format_string;
_EXECsformat	move.l	a2,-(sp)	;a1=*output_string;
		link	a4,#-32		;d0..d7=data;
		move.l	sp,a2
		movem.l	d0-d7,(a2)
		execlib	format
		unlk	a4
		move.l	(sp)+,a2
		rts
		endc

		ifd	_EXECFformat	;a0=*format_string;
_EXECformat	push	a2-a3/d0-d1	;a1=*output_string;
		move.l	a1,a3		;a2=*data_stream;
		move.l	a2,a1
		lea.l	_EXECformat_s(pc),a2
		lib	Exec,RawDoFmt
_EXECformat1	tst.b	(a3)+
		bne.s	_EXECformat1
		move.l	a3,a1
		subq.w	#1,a1
		move.l	a1,a0
		pull	a2-a3/d0-d1
		rts			;a1=*(NULL) /of_outstr/
_EXECformat_s	move.b	d0,(a3)+
		rts
		endc

		ifd	_EXECFcreateport
_EXECcreateport	push	d2/a2-a3	in: d0 = SIZEOF; out: d0 = port
		move.l	a0,a3		name*
		addq.l	#4,d0		space for SIZEOF
		move.l	d0,d2
		move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
		lib	Exec,AllocMem
		move.l	d0,a2
		tst.l	d0
		beq.s	_EXECcreaport1		-> no mem
		move.l	d2,(a2)+		save SIZEOF
		moveq.l	#-1,d0
		flib	Exec,AllocSignal
		move.b	d0,MP_SIGBIT(a2)
		bmi.s	_EXECcreaporte		-> no sigbit
		sub.l	a1,a1
		flib	Exec,FindTask
		move.l	d0,MP_SIGTASK(a2)
		move.b	#NT_MSGPORT,LN_TYPE(a2)
		move.l	a3,LN_NAME(a2)
		move.b	#PA_SIGNAL,MP_FLAGS(a2)
		lea	MP_MSGLIST(a2),a0
		;  NEWLIST A0:
		move.l	a0,(a0)
		addq.l	#LH_TAIL,(a0)
		clr.l	LH_TAIL(a0)
		move.l	a0,(LH_TAIL+LN_PRED)(a0)
		;  ;
		move.l	a2,d0
		bra.s	_EXECcreaport1
_EXECdeleteport	push	d2/a2-a3		In: port in a0
		move.l	a0,d0
		beq.s	_EXECcreaport1		-> no port to delete
		move.l	a0,a2
		moveq.l	#0,d0
		move.b	MP_SIGBIT(a2),d0
		bmi.s	_EXECcreaporte		-> no sigbit to free
		lib	Exec,FreeSignal
_EXECcreaporte	move.l	-(a2),d0		SIZEOF
		move.l	a2,a1
		lib	Exec,FreeMem
		moveq.l	#0,d0
_EXECcreaport1	pull	d2/a2-a3
		move.l	d0,a0
		rts
		endc

		ifd	_EXECFcreateio
_EXECcreateio	push	d2/a2		in: d0=SIZEOF, a0=MsgPort; out: d0=ioreq
		move.l	a0,a2		save msgport*
		addq.l	#4,d0		space for SIZEOF
		move.l	d0,d2
		move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
		lib	Exec,AllocMem
		move.l	d0,a0
		tst.l	d0
		beq.s	_EXECcreateio.e		-> no mem
		move.l	d2,(a0)+		save SIZEOF
		move.l	a2,MN_REPLYPORT(a0)
		move.b	#NT_MESSAGE,LN_TYPE(a0)
		subq.l	#4,d2			subtract SIZEOF(SIZEOF)
		move.w	d2,MN_LENGTH(a0)
		move.l	a0,d0
_EXECcreateio.e	pull	d2/a2
		rts
		endc

		ifd	_EXECFdeleteio
_EXECdeleteio	move.l	a0,d0			in: a0 = ioreq
		beq.s	_EXECdeleteio0		-> nothing to delete
		move.l	a0,a1
		move.l	-(a1),d0		get SIZEOF
		lib	Exec,FreeMem
_EXECdeleteio0	rts
		endc

		endm

