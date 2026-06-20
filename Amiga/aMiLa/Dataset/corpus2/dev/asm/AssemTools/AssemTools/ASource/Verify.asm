;
; ### Verify v 1.21 ###
;
; - Created 881113 by JM -
;
;
; Copyright © 1988 by Supervisor Software
;
;
; For verifying files or directories.
;
;
; Edited:
;
; - 881113 by JM -> v1.0	- Already works (in a strange way).
; - 881113 by JM -> v1.1	- Works well.
;				- CMDLine parsing (written by TM) added.
;				- CMDLine parsing doesn't work.
; - 881113 by JM -> v1.2	- Now works.  Single file comparisons vork,
;				  too.
; - 881122 by TM -> v1.21	- Info modified
;


		include	"dos.xref"
		include	"exec.xref"
		include "JMPLibs.i"
		include	"string.i"
		include	"numeric.i"

		include "exec/types.i"
		include "exec/nodes.i"
		include "exec/lists.i"
		include "exec/memory.i"
		include "exec/interrupts.i"
		include "exec/ports.i"
		include "exec/libraries.i"
		include "exec/io.i"
		include "exec/tasks.i"
		include "exec/execbase.i"
		include "exec/devices.i"
		include "devices/trackdisk.i"
		include	"dos.i"



*************************************************************************
*									*
* Stack allocation for VyMain():					*
*									*
*************************************************************************

		relbase	-4,-			alloc backwards
		rlong	bufmem			start of temp buffer
		rlong	lockptr			pointer to a lock
		rlong	sname			pointer to new name of lock
		rlong	sold			pointer to original name of lock
		rlong	dname			pointer to dest name
		rlong	dold			pointer to end of old name


TEMPSTR		equ	256
PATHSTR		equ	256
NAME1		equ	256
NAME2		equ	256
TBUFR		equ	48
STRBUF		equ	TEMPSTR+NAME1+NAME2+PATHSTR+TBUFR+16
WRMEM		equ	fib_SIZEOF+NAME1+NAME2+16

BUFSIZ		equ	8192

LF		equ	10
CR		equ	13
CSI		equ	155

;DEBUG		equ	1

strcpy		macro	*src,dst
strcpy\@	move.b	(\1)+,(\2)+
		bne	strcpy\@
		endm

strcmp		macro	*src,dst
		push	a0/a1/d0/d1
		ifnc	'\1','a0'
		move.l	\1,a0
		endc
		ifnc	'\2','a1'
		move.l	\2,a1
		endc
		bsr	StrCmp
		pull	a0/a1/d0/d1
		endm


dcbne		macro	hlong,llong,label
		cmp.l	\1,d1
		bne	\3
		cmp.l	\2,d0
		bne	\3
		endm


bug		macro
		ifd	DEBUG
		print	<\1>
		endc
		endm


Start		move.l	d0,_CMDLen		len of cmd line
		move.l	a0,_CMDBuf		start addr of cmd line
		clr.b	-1(a0,d0.l)		add null
		openlib Dos,cleanup		open Dos library

		move.l	_CMDBuf(pc),a0
		cmp.b	#'?',(a0)
		beq	info
		cmp.b	#'!',(a0)
		beq	finfo

		bsr.s	Allocmem
		bcs.s	cleanup
		ifd	DEBUG
		bug	<'mem reserved',10>
		endc

		bsr	parse
		bcs.s	cleanup

		bsr	VeriFy


cleanup		bsr	Freemem

clean99		closlib	Dos
		moveq.l	#0,d0
		rts





*
* Subroutines:
*


Allocmem	push	all
		move.l	#STRBUF,d0
		move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
		lib	Exec,AllocMem
		move.l	d0,sbuf		for temp strings
		beq.s	Allocmem_e
		add.l	#TEMPSTR,d0
		move.l	d0,pbuf		for pathname
		add.l	#PATHSTR,d0
		move.l	d0,n1buf	for filename
		add.l	#NAME1,d0
		move.l	d0,n2buf	for filename
		add.l	#NAME2,d0
		move.l	d0,tbufr	for TM

		move.l	#BUFSIZ+BUFSIZ,d0
		move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
		lib	Exec,AllocMem
		move.l	d0,buf1
		beq.s	Allocmem_e
		add.l	#BUFSIZ,d0
		move.l	d0,buf2
		pull	all
		clrc
		rts
Allocmem_e	pull	all
		setc
		rts



Freemem		push	all
		move.l	sbuf(pc),d0
		beq.s	Freemem1
		move.l	d0,a1
		move.l	#STRBUF,d0
		lib	Exec,FreeMem
		clr.l	sbuf
Freemem1	move.l	buf1(pc),d0
		beq.s	Freemem2
		move.l	d0,a1
		move.l	#BUFSIZ+BUFSIZ,d0
		lib	Exec,FreeMem
		clr.l	sbuf

Freemem2	pull	all
		rts



AddSlash	tst.b	(a1)
		beq.s	AdSl_ok			if path=NULL, no slash needed!
AdSl1		tst.b	(a1)+
		bne	AdSl1
		move.b	-2(a1),d0
		cmp.b	#':',d0
		beq.s	AdSl_ok
		cmp.b	#'/',d0
		beq.s	AdSl_ok
		move.b	#'/',-1(a1)		add slash if needed
		clr.b	(a1)
AdSl_ok		rts





*************************************************************************
*									*
* This routine handles all directories.					*
*									*
*************************************************************************

VeriFy		moveq.l	#0,d0
		move.w	d0,files		clear filecnt
		move.w	d0,errors		clear errcnt

		move.l	n1buf(pc),a1		add slash
		bsr	AddSlash
		move.l	n2buf(pc),a1		add slash
		bsr	AddSlash

		move.l	n1buf(pc),d1		main lock name
		moveq.l	#ACCESS_READ,d2
		lib	Dos,Lock
		tst.l	d0
		bne.s	VyMLock_ok
		print	<'*** Cannot get Main lock ***',LF>
		setc
		rts

VyMLock_ok	move.l	n1buf(pc),a0		spath; d0=lockptr
		move.l	n2buf(pc),a1		dpath
		bsr.s	VyMain

		move.l	d0,d1
		lib	Dos,UnLock

		bsr	PrintStat

		clrc
		rts



VyMain		link	a4,#_relof		alloc mem for temp usage
		push	a0-a3/a5/d0-d7

		move.l	d0,lockptr(a4)		save lock
		move.l	a0,sold(a4)		pathname of old lock
		move.l	a1,dold(a4)

		move.l	#WRMEM,d0
		move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
		lib	Exec,AllocMem
		move.l	d0,bufmem(a4)
		beq	VyMain_e

		add.l	#fib_SIZEOF,d0
		move.l	d0,sname(a4)		space for lock dir pathname
		add.l	#NAME1,d0
		move.l	d0,dname(a4)

		move.l	sold(a4),a0		backup source name path
		move.l	sname(a4),a1
		strcpy	a0,a1			get a copy of lock name
		subq.l	#1,a1
		move.l	a1,sold(a4)		now points to end of oldlock

		move.l	dold(a4),a0		backup dest name path
		move.l	dname(a4),a1
		strcpy	a0,a1			get a copy of lock name
		subq.l	#1,a1
		move.l	a1,dold(a4)		now points to end of oldlock

		move.l	lockptr(a4),d1
		move.l	bufmem(a4),d2		space for fib
		lib	Dos,Examine
		tst.l	d0
		beq	VyMain_e1		can't Examine()

		move.l	bufmem(a4),a5		fib
		tst.l	fib_DirEntryType(a5)	a dir?
		bmi	VyMainOneFile		no, only a single file

VyMainNextFile	bsr	ck_stop			*Handle files in this loop
		bne	VyMain_e		stopped?
		move.l	lockptr(a4),d1
		move.l	a5,d2
		lib	Dos,ExNext
		tst.l	d0
		beq.s	VyMain_Dir		no_more_entries maybe

		tst.l	fib_DirEntryType(a5)	a dir?
		bpl	VyMainNextFile		yes, skip it

		addq.l	#1,files		one more file!
		move.l	fib_Size(a5),d0
		add.l	d0,bytes		more bytes...

		lea	fib_FileName(a5),a0
		move.l	sold(a4),a1
		strcpy	a0,a1

		lea	fib_FileName(a5),a0
		move.l	dold(a4),a1
		strcpy	a0,a1

		move.l	sname(a4),a0		spath/file
		move.l	dname(a4),a1		dpath/file
		bsr	verify
		bcc.s	VyMain_Cont		if no error nor stopped
		bvs	VyMain_e		 stopped
		addq.l	#1,errors
		move.w	allflag(pc),d0
		beq	VyMain_e

VyMain_Cont	move.l	sold(a4),a0
		clr.b	(a0)			remove sfilename
		move.l	dold(a4),a0
		clr.b	(a0)			remove dfilename

		bra	VyMainNextFile		handle all files on this level


VyMain_Dir	move.l	lockptr(a4),d1		Start at beginning for Dirs
		move.l	bufmem(a4),d2		space for fib
		lib	Dos,Examine
		tst.l	d0
		beq	VyMain_e1		can't Examine()

VyMainNextDir	bsr	ck_stop			*Handle directories in this loop
		bne	VyMain_e		stopped?
		move.l	lockptr(a4),d1
		move.l	a5,d2
		lib	Dos,ExNext
		tst.l	d0
		beq	VyMain_x		no_more_entries maybe

		tst.l	fib_DirEntryType(a5)	a file?
		bmi	VyMainNextDir		yes, skip it

		addq.l	#1,dirs			one more dir!

		lea	fib_FileName(a5),a0	start of path extension
		move.l	sold(a4),a1		end of previous path
		strcpy	a0,a1			add a new name
		subq.l	#1,a1
		lea	fib_FileName(a5),a2	start of path extension
		move.l	dold(a4),a3		end of previous path
		strcpy	a2,a3			add a new name
		subq.l	#1,a3

		move.b	-1(a1),d0		If ends with / or : no slash
		cmp.b	#'/',d0			 must be added!
		beq.s	1$
		cmp.b	#':',d0
		beq.s	1$
		move.b	#'/',(a1)+		add a slash!
		move.b	#'/',(a3)+		add a slash!
		clr.b	(a1)			...and a NULL
		clr.b	(a3)			...and a NULL

1$		move.l	sname(a4),d1
		moveq.l	#ACCESS_READ,d2
		lib	Dos,Lock
		tst.l	d0
		beq.s	VyMain_e3		can't Lock()
		move.l	sname(a4),a0
		move.l	dname(a4),a1
		bsr	VyMain
		bcs.s	VyMain__e
		move.l	d0,d1
		lib	Dos,UnLock
		bra	VyMainNextDir
VyMain__e	move.l	d0,d1			Remember to UnLock() also if
		lib	Dos,UnLock		 an error occurred!
		bra	VyMain_e



VyMain_e1	print	<'*** Unable to Examine()',LF>
		bra.s	VyMain_e
VyMain_e3	print	<'*** Unable to Lock()',LF>
		bra.s	VyMain_e
VyMain_e5	print	<'*** Unable to open second file',LF>

VyMain_e	move.l	bufmem(a4),d0
		beq.s	VyMain_ee1
		move.l	d0,a1
		move.l	#WRMEM,d0
		lib	Exec,FreeMem
VyMain_ee1	pull	a0-a3/a5/d0-d7
		unlk	a4
		setc
		rts


VyMainOneFile	move.l	sold(a4),a0
		move.l	dold(a4),a1
		cmp.b	#'/',-(a0)
		bne.s	10$
		clr.b	(a0)
		subq.l	#1,sold(a4)
10$		cmp.b	#'/',-(a1)
		bne.s	11$
		clr.b	(a1)
		subq.l	#1,dold(a4)
11$		move.l	dname(a4),d1
		moveq.l	#ACCESS_READ,d2
		lib	Dos,Lock
		move.l	d0,d7
		beq	VyMain_e5		could not open
		move.l	bufmem(a4),a5		fib
		move.l	d7,d1			lock
		move.l	a5,d2			fib
		lib	Dos,Examine
		move.l	d7,d1
		lib	Dos,UnLock

		tst.l	fib_DirEntryType(a5)	a file?
		bmi.s	VyMOF_c1		yes, continue!

		move.l	sold(a4),a0		end of source
		move.l	sname(a4),a1		start of source
1$		cmp.l	a1,a0			find start of plain name
		beq.s	2$			 (backwards)
		move.b	-(a0),d0
		cmp.b	#'/',d0
		beq.s	3$
		cmp.b	#':',d0
		bne	1$
3$		addq.l	#1,a0
2$		move.l	dold(a4),a1
		move.b	-1(a1),d0		check if a slash needed
		cmp.b	#'/',d0
		beq.s	urk
		cmp.b	#':',d0
		beq.s	urk
		move.b	#'/',(a1)+
urk		strcpy	a0,a1

VyMOF_c1	move.l	sname(a4),a0
		move.l	dname(a4),a1
		move.w	#1,onefile
		bsr.s	verify

VyMain_x	move.l	bufmem(a4),d0
		beq.s	VyMain_x1
		move.l	d0,a1
		move.l	#WRMEM,d0
		lib	Exec,FreeMem
VyMain_x1	pull	a0-a3/a5/d0-d7
		unlk	a4
		clrc
		rts


verify		push	all
		moveq.l	#0,d4
		moveq.l	#0,d5
		move.l	a0,a2
		move.l	a1,a3
		move.l	a0,d1
		move.l	#1005,d2
		lib	Dos,Open
		move.l	d0,d4
		beq	vercountopen1
		move.l	a3,d1
		lib	Dos,Open
		move.l	d0,d5
		beq	vercountopen2
		moveq	#0,d6
verif1		move.w	countflag(pc),d0
		beq.s	verif1b
		move.l	tbufr(pc),a0	; {
		move.b	#9,(a0)+
		move.b	#'$',(a0)+
		move.l	d6,d0		; to display cur adr
		numlib	put16
		move.b	#13,(a0)+
		clr.b	(a0)
		printa	tbufr(pc)	; }
verif1b		bsr	ck_stop
		bne	verbr
		move.l	d4,d1
		move.l	buf1(pc),d2
		move.l	#BUFSIZ,d3
		lib	Dos,Read
		move.l	d0,d7
		move.l	d5,d1
		move.l	buf2(pc),d2
		move.l	#BUFSIZ,d3
		lib	Dos,Read
		cmp.l	d0,d7
		bne	verld
		tst.l	d0
		beq	verok
		subq.l	#1,d7
		move.l	buf1(pc),a0
		move.l	buf2(pc),a1
verif2		cmpm.b	(a0)+,(a1)+
		dbne	d7,verif2
		bne.s	verdd
		add.l	#BUFSIZ,d6
		bra	verif1
verdd		bsr	verer
		print	<'Data difference at $'>
		move.l	a0,d0
		subq.l	#1,d0
		sub.l	buf1(pc),d0
		add.l	d6,d0
		move.l	tbufr(pc),a0
		numlib	put16
		move.b	#10,(a0)+
		clr.b	(a0)
		printa	tbufr(pc)
		bra.s	verfl
verld		bsr.s	verer
		print	<'Length difference',10>
verfl		bsr	vercn
		setc
		pull	all
		clrv
		rts
verbr		bsr	vercn
		setc
		pull	all
		setv
		rts
verer		move.w	onefile(pc),d0
		bne	verer1
		bsr	verer1
		print	<'"'>
		printa	a2
		print	<'" ',60,62,' "'>
		printa	a3
		print	<'"',10,'       - '>
		rts
verer1		print	<'*** VERIFY ERROR: ',CSI,'1K'>
		rts
verok		move.w	onefile(pc),d0
		beq.s	verok1
		print	<'Verify OK - files are identical',CSI,'1K',10>
verts		bsr	vercn
		clrc
		pull	all
		rts
verok1		move.w	verbose(pc),d0
		beq	verts
		print	<'Verify OK - "',CSI,'1K'>
		printa	a2
		print	<'" = "'>
		printa	a3
		print	<'"',10>
		bra	verts
vercn		move.l	d4,d1
		beq.s	vercn1
		moveq.l	#0,d4
		lib	Dos,Close
vercn1		move.l	d5,d1
		beq.s	vercn2
		moveq.l	#0,d5
		lib	Dos,Close
vercn2		rts
vercountopen1	lib	Dos,IoErr
		move.l	d0,d7
		move.l	a2,a0
		bsr.s	vercountopen
		bra	verfl
vercountopen2	lib	Dos,IoErr
		move.l	d0,d7
		move.l	a3,a0
		bsr.s	vercountopen
		bra	verfl
vercountopen	print	<'Unable to open file "'>
		printa	a0
		print	<'" for input - error code '>
		move.l	d7,d0
		move.l	tbufr(pc),a0
		numlib	put10
		move.b	#10,(a0)+
		clr.b	(a0)
		printa	tbufr(pc)
		rts



PrintStat	move.w	onefile(pc),d0		if only one file, don't print
		beq.s	1$
		rts
1$		print	<LF,LF,' Processing Status:',LF>
		print	<'====================',LF,LF,'# of files:       '>
		move.l	files(pc),d0
		bsr	print10

		print	<LF,'# of errors:      '>
		move.l	errors(pc),d0
		bsr	print10

		print	<LF,'# of directories: '>
		move.l	dirs(pc),d0
		addq.l	#1,d0
		bsr	print10

		print	<LF,'# of bytes:       '>
		move.l	bytes(pc),d0
		bsr	print10
		print	<LF,LF>
		rts



StrCmp		moveq.l	#0,d0		compare strings at (a0) and (a1)
		moveq.l	#0,d1
StrCmp1		move.b	(a0)+,d0	cmp str(a0),str(a1)
		beq.s	eofs1
		move.b	(a1)+,d1
		beq.s	eofs2
		cmp.w	d0,d1
		beq	StrCmp1
StrEqu		rts
eofs1		tst.b	(a1)+
		beq	StrEqu
		moveq.l	#1,d0
		rts
eofs2		moveq.l	#-1,d0
		rts



ck_stop		push	d0-d1/a0-a1		checks if CTRL_C pressed
		moveq.l	#0,d0
		moveq.l	#0,d1
		lib	Exec,SetSignal
		btst	#SIGBREAKB_CTRL_C,d0
		beq.s	ck_nostop
		moveq.l	#0,d0
		moveq.l	#0,d1
		bset	#SIGBREAKB_CTRL_C,d1
		lib	Exec,SetSignal
		print	<'*** BREAK',CSI,'1K',10>
		moveq.l	#1,d0			NE: STOP!!!
		pull	d0-d1/a0-a1
		rts
ck_nostop	moveq.l	#0,d0			EQ: no stop
		pull	d0-d1/a0-a1
		rts



parse		push	all
		move.l	_CMDBuf(pc),a0
		move.l	n1buf(pc),a1
		strlib	skipblk
		tst.b	(a0)
		beq.s	parseFNAMEX
		strlib	blkcpy
		strlib	skipblk
		move.l	n2buf(pc),a1
		tst.b	(a0)
		beq.s	parseFNAMEX
		strlib	blkcpy
		move.l	n2buf(pc),a1
parse0		strlib	skipblk
		tst.b	(a0)
		beq	parsend
		move.l	a0,a2
		strlib	getiwordu
		cmp.w	#'V',d0
		beq.s	parseV
		dcbne	#'VER',#'BOSE',parse1
parseV		tst.w	verbose
		bne.s	parseOPTTWD
		move.w	#1,verbose
		bra	parse0
parseFNAMEX	print	<'*** FILE name expected',10>
		bra.s	parserr
parseOPTTWD	print	<'*** OPTION declared twice',10>
parserr		pull	all
parser		setc
		rts
parse1		cmp.w	#'A',d0
		beq.s	parseA
		dcbne	#0,#'ALL',parse2
parseA		tst.w	allflag
		bne	parseOPTTWD
		move.w	#1,allflag
		bra	parse0
parse2		cmp.w	#'C',d0
		beq.s	parseC
		dcbne	#'C',#'OUNT',parse3
parseC		tst.w	countflag
		bne	parseOPTTWD
		move.w	#1,countflag
		bra	parse0
parse3		cmp.b	#'-',(a2)
		bne.s	parse4
		move.l	a2,a0
		addq.l	#1,a0
		move.b	(a0)+,d0
		strlib	ucase
		cmp.b	#'C',d0
		beq	parseC
		cmp.b	#'A',d0
		beq	parseA
		cmp.b	#'V',d0
		beq	parseV
parseUNKOPT	print	<'*** OPTION must be of -C -A -V',10>
		bra	parserr
parse4		print	<'*** Syntax error',10>
		bra	parserr
parsend		pull	all
		clrc
		rts





print10		push	all		if carry clear, leading zeroes blanked
		lea	bcd(pc),a0
		numlib	put10
		lea	bcd(pc),a0
		printa	a0
		pull	all
		rts

info		lea	infotx(pc),a0
info1		printa	a0
		bra	cleanup
finfo		lea	finfotx(pc),a0
		bra	info1


		strlib
		numlib

bcd		ds.l	4		buffers for bin -> ASCII conversion

_CMDLen		dc.l	0		The famous ones
_CMDBuf		dc.l	0

files		dc.l	0		# of files
errors		dc.l	0		# of erraneous files
dirs		dc.l	0		# of directories
bytes		dc.l	0		# of bytes in files
sbuf		dc.l	0		pointer to string buffer used by RdMain()
pbuf		dc.l	0		pointer to pathname (used by RdMain)
n1buf		dc.l	0		pointer to filename (used by RdMain)
n2buf		dc.l	0		pointer to filename (used by RdMain)
buf1		dc.l	0		verify buffer #1
buf2		dc.l	0		verify buffer #2
tbufr		dc.l	0		temp buffer for TM

verbose		dc.w	0		flag: print verbose msgs
allflag		dc.w	0		flag: 1 -> verify all files
onefile		dc.w	0		flag: 1 -> only one file!
countflag	dc.w	0		flag: 1 -> show compare addresses



finfotx		dc.b	'*** Verify v1.21 ***',10,10
		dc.b	'© 1988 Supervisor Software',10
		dc.b	'Written by JM 881113',10,10
infotx		dc.b	'Usage: ver <file1> <file2> [options]',10
		dc.b	'Compares the contents of the two files (or directories)',10
		dc.b	'and displays a message if a difference was found. Note',10
		dc.b	'that the difference first encountered is displayed, thus',10
		dc.b	'a message about data difference may be displayed although',10
		dc.b	'the files are of different length.',10
		dc.b	'Options may contain one or more of the following:',10
		dc.b	'  [-]A|ALL     Causes the program not to stop when the first',10
		dc.b	'               is found (when comparing directories).',10
		dc.b	'  [-]V|VERBOSE Causes the program to display the result of',10
		dc.b	'               the file comparison although no difference',10
		dc.b	'               was found.',10
		dc.b	'  [-]C|COUNT   Causes the program to display a byte count',10
		dc.b	'               during comparison.',10,0

		libnames		libraries & pointers

		end

