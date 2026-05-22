;
; ### Print by JM v 1.11 ###
;
; - Created 880515 by JM -
;
;
; Quack!
;
; Bugs: unknown
;
;
; Edited:
;
; - 880515 by JM -> v0.00	- does not work (can't print page#)
; - 880515 by JM -> v1.00	- Works like its "C"-counterpart.
; - 890418 by JM -> v1.10	- No buffer limitations.
; - 890418 by JM -> v1.11	- Bug fixes, CTRL+C support, relativization.
;
;

;DEBUG		set	1

SOURCEBUF	equ	2048+16
OBUF		equ	1024
NAMEBUF		equ	256

TABSTEP		equ	8
LINEMAX		equ	58
FORMFEED	equ	12
LINEFEED	equ	10
LF		equ	10
CR		equ	13
TAB		equ	9

RELATIVE	set	1

		include	"exec.xref"
		include	"dos.xref"
		include "JMPLibs.i"
		include "exec/types.i"
		include "exec/memory.i"
		include "dos.i"
		include "execlib.i"
		include "relative.i"
		include "handler.i"


otxt		macro
		push	a0/d7
		lea	otxtdat\@,a0
otxtl\@		move.b	(a0)+,d7
		beq.s	otxte\@
		bsr	ochr
		bra.s	otxtl\@
otxtdat\@	dc.b	\1
		dc.b	0
		cnop	0,4
otxte\@		pull	a0/d7
		endm



		.var
		dl	_DosBase,_CMDLen,_CMDBuf
		dl	obuf,opoi,txtpoi
		dl	prtfile,infile,sourcepoi,namebuf
		dl	xpos,line,pagenum,linefd


Start		.begin
		ra				clear variables
		move.l	d0,_CMDLen(a4)		len of cmd line
		move.l	a0,_CMDBuf(a4)		start addr of cmd line
		clr.b	-1(a0,d0.l)		add null
		openlib Dos,cleanup		open Dos library

		move.l	#SOURCEBUF,d0		this many RAM bytes needed
		move.l	#MEMF_CLEAR!MEMF_PUBLIC,d1
		lib	Exec,AllocMem		ask for them
		move.l	d0,sourcepoi(a4)	save start addr
		beq	mem_cleanup		no mem, exit

		move.l	#OBUF,d0		this many RAM bytes needed
		move.l	#MEMF_CLEAR!MEMF_PUBLIC,d1
		lib	Exec,AllocMem		ask for them
		move.l	d0,obuf(a4)		save start addr
		move.l	d0,opoi(a4)		set output buffer pointer
		beq	mem_cleanup		no mem, exit

		move.l	#NAMEBUF,d0		this many RAM bytes needed
		move.l	#MEMF_CLEAR!MEMF_PUBLIC,d1
		lib	Exec,AllocMem		ask for them
		move.l	d0,namebuf(a4)	save start addr
		beq	mem_cleanup		no mem, exit

		bsr	mkname

		move.l	namebuf(a4),a0
		tst.b	(a0)
		bne	name_not_null
		print	<'*** No file name ***',LF>
		print	<'Usage: print ',60,'filename',62,LF,LF>
		bra	cleanup

name_not_null	move.l	_CMDBuf(a4),d1		file to load
		move.l	#MODE_OLDFILE,d2	mode: read only
		lib	Dos,Open		open it
		move.l	d0,infile(a4)		save ptr
		bne	in_file_ok
		print	<'*** File '>
		printa	_CMDBuf(a4)
		print	<' not found ***',LF>
		bra	cleanup

in_file_ok	lea	PRTFILE(pc),a0
		move.l	a0,d1			file to write
		move.l	#MODE_NEWFILE,d2	mode: create
		lib	Dos,Open		open it
		move.l	d0,prtfile(a4)		save ptr
		bne	out_file_ok
		print	<'*** Cannot open printer.device ***',LF>

out_file_ok	print	<'Files opened.',LF>
		otxt	<27,'c',27,'#1'>		reset
		otxt	<27,'(B'>			USA
		otxt	<27,'[2w'>			elite on
		otxt	<27,'[2"z'>			NLQ on
		print	<'Printing started.',LF>

		clr.l	pagenum(a4)
		bsr	print_header
		bsr	tabulate

read_buf	move.l	infile(a4),d1
		move.l	sourcepoi(a4),d2
		move.l	#SOURCEBUF-16,d3
		lib	Dos,Read
		move.l	d2,a0
		clr.b	0(a0,d0)	add NULL
		move.l	d2,txtpoi(a4)
		tst.l	d0
		beq	end_of_file


main_loop	execlib	stop
		bne	break_ed
		bsr	chr
		beq.s	read_buf	get more data

		cmp.b	#LINEFEED,d7	*** Handle line feeds
		bne.s	main_1
		tst.b	linefd(a4)
		beq.s	main_loop	if first line of page
		addq.l	#1,line(a4)
		clr.l	xpos(a4)
		cmp.l	#LINEMAX,line(a4)
		blt.s	main_01
		clr.l	line(a4)
		otxt	FORMFEED
		bsr	print_header
main_01		bsr	ochr
		bsr	tabulate
		bra.s	main_loop

main_1		cmp.b	#TAB,d7		*** Handle tabulators
		bne.s	main_2
		bsr	tabulate
		bra.s	main_loop

main_2		bsr	ochr
		addq.l	#1,xpos(a4)
		move.b	#1,linefd(a4)

		cmp.b	#CR,d7		*** Handle carriage returns
		bne	main_loop
		clr.l	xpos(a4)
		bra	main_loop

break_ed	print	<'*** User break request',LF>
end_of_file	
		move.l	infile(a4),d1
		lib	Dos,Close

		otxt	<FORMFEED,27,'c',27,'#1'>	reset
		moveq.l	#0,d7
		bsr	ochr				flush buffer
		print	<'Printing complete.',LF>
		bra	cleanup



mem_cleanup	print	<'*** Memory allocation failed ***',LF>
cleanup		move.l	prtfile(a4),d1
		beq	clean01
		lib	Dos,Close

clean01		move.l	sourcepoi(a4),d0	if mem reserved release it
		beq	clean02
		move.l	d0,a1
		move.l	#SOURCEBUF,d0
		lib	Exec,FreeMem

clean02		move.l	obuf(a4),d0		if mem reserved release it
		beq	clean03
		move.l	d0,a1
		move.l	#OBUF,d0
		lib	Exec,FreeMem

clean03		move.l	namebuf(a4),d0		if mem reserved release it
		beq	clean04
		move.l	d0,a1
		move.l	#NAMEBUF,d0
		lib	Exec,FreeMem

clean04		closlib	Dos
		.end

mkname		move.l	_CMDBuf(a4),a0
		move.l	namebuf(a4),a1
mkname1		strcpy	a0,a1
		rts


print_header	push	all
		otxt	<27,'[4"z        File: '>
		moveq.l	#52,d0
		move.l	namebuf(a4),a0
print_hd1	move.b	(a0)+,d7		print filename
		beq	print_hd2
		bsr	ochr
		dbf	d0,print_hd1
		bra	print_hd3
print_hd2	moveq.l	#' ',d7
		bsr	ochr
		dbf	d0,print_hd2
print_hd3	otxt	<'       Page: '>
		addq.l	#1,pagenum(a4)
		move.l	pagenum(a4),d0
		bsr	conv_10
		otxt	<CR,LF,'        ================================'>
		otxt	<'=============================================='>
		otxt	<'==',27,'[3"z',CR,LF,LF>

		clr.l	line(a4)
		clr.l	xpos(a4)
		clr.l	linefd(a4)
		pull	all
		rts


tabulate	push	d0-d1/d7
		move.l	xpos(a4),d0
		moveq.l	#' ',d7
tablate1	addq.l	#1,d0
		bsr	ochr
		move.l	d0,d1
		divu.w	#TABSTEP,d1
		swap	d1
		tst.w	d1
		bne	tablate1
		move.l	d0,xpos(a4)
		pull	d0-d1/d7
		rts


conv_10		push	d0-d1/d6-d7
		move.l	#100000,d1		first sub 100000's
		moveq.l	#' ',d6			blank leading zeros
conv_10_0	move.b	d6,d7			at least zero ASCII
conv_10_1	cmp.w	d1,d0
		bcs	conv_10_2		cannot subtract
		sub.w	d1,d0
		addq.l	#1,d7			incr. digit
		moveq.l	#'0',d6
		or.b	d6,d7
		bra	conv_10_1		sub again
conv_10_2	bsr	ochr
		divu.w	#10,d1			next digit
		tst.w	d1
		bne	conv_10_0		until all done
		pull	d0-d1/d6-d7
		rts



ohex		push	d0/d7/a0		output a byte in d7 in hex
		lea	hextable(pc),a0
		move.b	d7,d0
		lsr.b	#4,d7
		and.w	#15,d7
		move.b	0(a0,d7),d7
		bsr	ochr
		and.w	#15,d0
		move.b	0(a0,d0),d7
		bsr	ochr
		pull	d0/d7/a0
		rts




chr		push	a0			read one byte
		move.l	txtpoi(a4),a0
		moveq.l	#0,d7
chrloop		move.b	(a0)+,d7
		move.l	a0,txtpoi(a4)
		pull	a0
		tst.b	d7
		rts


ochr		push	d0-d3/a0-a1		* output one char.
		move.l	obuf(a4),a1		* Uses buffering.
		tst.b	d7			* Buffer is written to file
		beq	ochrflush		* if it becomes full or if
		add.l	#OBUF,a1		* the character ochr'ed is
		move.l	opoi(a4),a0		* a NULL.
		move.b	d7,(a0)+
		cmp.l	a1,a0
		blt	ochrok1
		move.l	obuf(a4),a0
		move.l	prtfile(a4),d1
		move.l	a0,d2
		move.l	#OBUF,d3
ochrout		lib	Dos,Write
		move.l	d2,a0
		cmp.l	d3,d0
		beq	ochrok1
		print	<'*** Error writing file ***',LF>
ochrok1		move.l	a0,opoi(a4)
		pull	d0-d3/a0-a1
		tst.b	d7
		rts

ochrflush	move.l	opoi(a4),a0
		sub.l	a1,a0
		move.l	prtfile(a4),d1
		move.l	a1,d2
		move.l	a0,d3
		bra	ochrout


		execlib


hextable	dc.b	'0123456789abcdef'

		ifd	DEBUG
PRTFILE		dc.b	'con:0/0/640/200/OutputWindow',0
		endc
		ifnd	DEBUG
PRTFILE		dc.b	'prt:',0
		endc

		libnames

		end

