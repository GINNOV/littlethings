;
; ### 65c02 Cross Assembler by JM,TM v 2.352 ###
;
; - Created 880425 by JM -
;
;
; Quack!
;
; Bugs: Who knows...  Many, many fixed.
; 
; * lda #-1-8 causes en ermsg: 8-bit value required
;
;
; Edited:	(Times and dates are UTC)
;=========
;
; - 880425 by JM    -> v0.00	- does not work
; - 880602 by JM    -> v0.01	- mnemonic table etc.
; - 880603 by JM,TM -> v0.02	- calc finished, seek_op, amode, slabel
;				  RELATIVE ADDRESSING???
; - 880604 by JM,TM -> v0.03	- seek_op finished   ### CPU CARD RUNS! ###
; - 880605 by JM,TM -> v0.04	- glabel&pass1 written, many Bugs fixed
; - 880606 by JM    -> v0.05	- pass2 written, many Bugs fixed
;				- IT COMPILES!!!
;				- DB, DW, DL
;				- z also accepted in symbol names
; - 880607 by JM,TM -> v1.00	- ';' works
; - 880608 by JM    -> v1.10	- listing file, conv_10
; - 880609 by JM    -> v1.11	- listing file improved, conv_16, dumplabels
; - 880610 by JM    -> v1.20	- dumplabels writes to listfile, too
;				- options allowed on cmd line
;				- MODE mnemonic added
;				- usage added
; - 880610 by JM    -> v1.30	- include added (well, that was a hard one...)
; - 880611 by JM    -> v1.34	- include edited (that took about one day)
; - 880611 by JM    -> v1.40	- conditional assembly added
; - 880611 by JM    -> v1.42	- conditional assembly improved (nesting allowed)
; - 880615 by JM    -> v1.46	- include nesting file names buffered
;				- maximum nesting level set to #INCNESTING
;				- label not found in abs or rel now only
;				  generates one error message
;				- started writing macro routines
; - 880616 by JM    -> v1.47	- FF added to the end of listfile
; - 880618 by JM    -> v1.48	- getlb written
;		    -> v1.49	- macro routines continued
;		    -> v1.50	- macro routines continued
;		    -> v1.51	- macros work without parameters and nesting
;		    -> v1.52	- macros improved
; - 880619 by JM    -> v1.57	- macros improved
;		    -> v1.60	- macros: parameters
;		    -> v1.62	- problems...
; - 880624 by JM,TM -> v1.65	- ifc/ifnc written
;				- ermsgs added
;				- ifi/ifni written (TM)
; - 880624 by JM    -> v1.67	- macros nesting without parameter nesting
; - 880625 by JM    -> v1.68	- macros nesting with parameter nesting
;		    -> v1.74	- parameter nesting finished; errhandler
;				  edited
;		    -> v1.75	- @MODE written; glabel now gives an ermsg if
;				  no symbol name is given
; - 880626 by JM    -> v1.77	- Big Params allowed in macros
;		    -> v1.90	- It seems to work well.
;		    -> v1.91	- Macros now accept four parameters
;				- Addresses > $ffff now generate an ermsg
;		    -> v1.92	- Labels also processed on macro usage lines
; - 880814 by JM    -> v1.93	- Hex mode can now be set in source file
;				  using MODE directive - NOTE: No .hex extension
;				  will be added to output file in this case!
;				- CTRL+Z is added to end of hex output file
; - 880816 by JM    -> v1.95	- Fixed a bug in conditional assembly:
;				  Nested conditions should now work properly.
;				  A 'stack' for all condition levels added.
; - 880816 by JM    -> v1.97	- Stack now consists of bytes (no need to
;				  multiply index by two -> no guru3's on 68000)
;				- CTRL_C signals now checked in pass1, pass2
;				  and MainLoad.
; - 880816 by JM    -> v2.00	- CTRL_C checked also in dumplabels
;				- endc statements now allow for labels BUT:
;				  endm's DON'T!!!
; - 880817 by JM    -> v2.02	- SET and EQU should now work properly.
;				  There was a problem when SETting a label to
;				  value label+n because slabel corrupted
;				  the LINFO value before GLABEL read it.
; - 880817 by JM    -> v2.06	- Fixed a bug: MODE L produced 1006 bytes
;				  of object code when listfile was opened.
;				  Now none of pseudos should produce object
;				  code (=increment prgc) unintentionally.
;				- Listmode is now read from userlmode, whose
;				  value is derived from cmd line option -l.
;				  Now the default listmode at start of each
;				  pass is userlmode instead of the value of
;				  listmode inherited from previous pass.
;				- Mode l/L commands no longer written to
;				  listfile.
;				- <<>> now produces an ermsg in macro exps.
;				- Macro parameters no longer contain following
;				  blanks.
;				- Macro, include and conditional nesting levels
;				  raised.
;				- Symbol definitions using EQU or SET now
;				  generate listing according to the value
;				  assigned. '=' = EQU, '>' = SET.
;				  DOESN'T WORK YET!!!
; - 880818 by JM    -> v2.10	- Fixed a new bug: listfile now opened correctly
;				- dumplabels no longer crashes is odd number of
;				  labels is printed (a bug in nextlab fixed)
;				- '=' and '>' now work in listmode.
;				- MainLoad now tells us what it is doing.
; - 880818 by JM    -> v2.15	- Fixed an old bug which caused wrong filenames
;				  and lines to be printed if any of the files
;				  was not found.
; - 880818 by JM    -> v2.2	- Macro parameters containing blanks in ''
;				  now allowed.
;				- Quote error messages added.
; - 880819 by JM    -> v2.23	- Macro parameter errors now should only
;				  print one errormsg.
;				- Macro ermsgs contain error line instead of
;				  a null.
;				- SET symbols not show their correct values
;				  in listfile.
;				- MODulo operation added (\).  Only handles
;				  signed 16-bit values for now.
; - 880819 by JM    -> v2.24	- Still a bug fixed.  Now SET symbols really
;				  work fine (with abs values, too).
; - 880819 by JM    -> v2.25	- Nested conditional assembly with FALSE
;				  block now should work properly.  This one
;				  was hard to find but easy to fix (just one
;				  clr.b pat_pend needed)
; - 880907 by JM    -> v2.26	- BBR and BBS now don't check offset value
;				  during pass 1.  So forward jumps work.
; - 880907 by JM    -> v2.30	- Macros listed properly during false condition.
; - 880907 by JM    -> v2.32	- BBR and BBS now get right mem address
;				- Abs_Sym_Mism error printed only once
; - 881201 by JM    -> v2.33	- Now an error during seek_op() should not
;				  produce an extra long destination line.
;				  So the relative branches should no longer
;				  cause extra ermsgs after an unknown label.
; - 890125 by JM    -> v2.34	- Now flushes the output buffer ALWAYS at the
;				  end of assembly
;				- Several relative branches converted to short.
; - 890131 by JM    -> v2.35	- PAGE directive added.
; - 890310 by JM    -> v2.351	- All b???.l and b???.b instructions converted
;				  to b??? to allow compiling with A68k.
; - 890310 by JM    -> v2.352	- All PULL <onereg> checked because A68k
;				  changes these into MOVE.L -> flags change.
;				  -> seems to work even if compiled with
;				  A68k.
;
;
;------------------------------------------------------------------------
;

LABELLEN	equ	16			maximum length of label name
LABELSPC	equ	LABELLEN+1+1+4+4	name,null,info,usage,value
LINFO		equ	LABELLEN+1
LUSAGE		equ	LABELLEN+1+1
LVALUE		equ	LABELLEN+1+1+4
NUMLAB		equ	5000			maximum number of label names

MAXLINE		equ	60			default value
HUGELINE	equ	MAXLINE+10		higher than maxline

INCNESTING	equ	8			maximum level of nested includes
MCNESTING	equ	8			maximum level of nested macros
CONDNESTING	equ	16			maximum level of nested conditions


NAME1BUF	equ	256			buffer sizes
NAME2BUF	equ	256
AUXBUF		equ	256
LISTBUF		equ	512
MULTIBUF	equ	NAME1BUF+NAME2BUF+AUXBUF+LISTBUF
OBUF		equ	2048			output buffer size
LABELBUF	equ	LABELSPC*NUMLAB		name,null,pad,info,value
MINSOURCE	equ	10000			minimum buffer for source


;------------------------------------------------------------------------


TAB		equ	9			some ASCII characters
LF		equ	10
FF		equ	12
CR		equ	13
CTRL_C		equ	12
CTRL_Z		equ	26
ESC		equ	27
CSI		equ	128+ESC
ID		equ	160			id byte for internal mnemonics


;------------------------------------------------------------------------


IMM		equ	0			identifiers for addressing
ABS		equ	1			modes
ZP		equ	2
ACC		equ	3
IMP		equ	4
INDX		equ	5
INDY		equ	6
ZPX		equ	7
ABSX		equ	8
ABSY		equ	9
REL		equ	10
IND		equ	11
ZPY		equ	12


;------------------------------------------------------------------------


		include	"exec.xref"
		include	"dos.xref"
		include "JMPLibs.i"

MEMF_PUBLIC	equ	1		no need of intuition.i
MEMF_CHIP	equ	2
MEMF_FAST	equ	4
MEMF_CLEAR	equ	65536


;------------------------------------------------------------------------


VERSION		macro
		dc.b	'v2.352'
		endm

otxt		macro
		push	a0/d7
		lea	otxtdat\@,a0
otxtl\@		move.b	(a0)+,d7
		beq	otxte\@
		bsr	ochr
		bra	otxtl\@
otxtdat\@	dc.b	\1
		dc.b	0
		cnop	0,4
otxte\@		pull	a0/d7
		endm


error		macro				calls error handler
		push	all
		ifnc	'\1',''
		move.w	\1,d0
		endc
		bsr	errhandler
		pull	all
		endm


;------------------------------------------------------------------------


Start		push	d2-d7/a2-a6		save regs
		move.l	d0,_CMDLen		len of cmd line
		move.l	a0,_CMDBuf		start addr of cmd line
		clr.b	-1(a0,d0.l)		add null
		openlib Dos,cleanup		open Dos library

		printa	#PAGEMSG		print starting msg
		move.b	#' ',PAGENULL
		printa	#LFLF

		lib	Dos,Output		get output file handle
		move.l	d0,clifile

		move.l	#OBUF,d0		reserve output buffer
		move.l	#MEMF_CLEAR,d1
		lib	Exec,AllocMem
		move.l	d0,obuf			save start addr
		move.l	d0,opoi			set output buffer pointer
		beq	mem_cleanup		no mem, exit

		move.l	#MULTIBUF,d0		several buffers
		move.l	#MEMF_CLEAR,d1
		lib	Exec,AllocMem		ask for mem
		move.l	d0,multibuf		save start addr for FreeMem
		beq	mem_cleanup		no mem, exit
		add.l	#NAME1BUF+NAME2BUF,d0
		move.l	d0,auxbuf		another buffer
		add.l	#AUXBUF,d0
		move.l	d0,libuf		buffer for listing

		move.l	#LABELBUF,d0		allocate mem for symbols
		move.l	#MEMF_CLEAR,d1
		lib	Exec,AllocMem
		move.l	d0,labelbuf		save start addr
		beq	mem_cleanup		no mem, exit

		bsr	OpenFiles		open files, read prg
		bcs	cleanup

		move.l	errcnt(pc),d0		errors during macro/include pass?
		bne	cleanup
		bsr	pass1
		bcs	cleanup
		bsr	pass2

		move.w	hexmode(pc),d0
		beq.s	noCTRLz
		moveq.l	#CTRL_Z,d7		end-of-file mark
		bsr	ochr

noCTRLz		moveq.l	#-1,d7			flush output buffer
		bsr	ochr

		move.l	errcnt(pc),d0		no msg below if errors
		bne.s	not_complete

		print	<'Object file complete.',LF>
not_complete	bsr	dumplabels
		bra.s	cleanup


;------------------------------------------------------------------------


mem_cleanup	error	#41
cleanup		move.w	broken(pc),d0
		beq.s	nobreak
		print	<'*** User break request ***',LF>
nobreak		move.l	outfile(pc),d1
		beq.s	cleanf1
		lib	Dos,Close

cleanf1		move.l	listfile(pc),d1
		beq.s	clean01
		print	<FF>,d1			add final form feed
		lib	Dos,Close

clean01		move.l	sourcebuf(pc),d0	if mem reserved release it
		beq.s	clean02
		move.l	d0,a1
		move.l	SOURCEBUF(pc),d0
		lib	Exec,FreeMem

clean02		move.l	obuf(pc),d0		if mem reserved release it
		beq.s	clean03
		move.l	d0,a1
		move.l	#OBUF,d0
		lib	Exec,FreeMem

clean03		move.l	multibuf(pc),d0		if mem reserved release it
		beq.s	clean04
		move.l	d0,a1
		move.l	#MULTIBUF,d0
		lib	Exec,FreeMem

clean04		move.l	labelbuf(pc),d0		if mem reserved release it
		beq.s	clean90
		move.l	d0,a1
		move.l	#LABELBUF,d0
		lib	Exec,FreeMem

clean90		closlib	Dos
		pull	d2-d7/a2-a6
		moveq.l	#0,d0
		rts



;========================================================================


output		cmp.b	#2,pass			if pass#2, write to dest.
		beq.s	output_y
		rts
output_y	push	d0-d1/a0-a1
		move.w	listmode(pc),d0		if listmode
		beq.s	output_no_b
		move.w	hexbytcnt(pc),d0	if still bytes to buffer
		beq.s	output_no_b		(writes only first 3 bytes)
		subq.w	#1,d0			Outputs assembled bytes to libuf
		move.w	d0,hexbytcnt		2.1.0
		eor.w	#3,d0			1.2.3
		mulu.w	#3,d0			3.6.9
		lea	hextable(pc),a0
		move.l	libuf(pc),a1
		moveq.l	#0,d1
		move.b	d7,d1
		lsr.b	#4,d1
		move.b	0(a0,d1.w),9(a1,d0.w)	high nybble
		move.b	d7,d1
		and.b	#15,d1
		move.b	0(a0,d1.w),10(a1,d0.w)	low nybble

output_no_b	move.w	hexmode(pc),d0
		bne.s	output_hex
		bsr	ochr
		bra.s	no_output
output_hex	bsr	ohex
no_output	pull	d0-d1/a0-a1
		rts


;------------------------------------------------------------------------


listout		push	d0-d3/a0-a1		write pc, line# & line in libuf
		move.w	listmode(pc),d0
		beq	listout_ex
		move.w	no_list(pc),d0		if a special mnemonic, no listing
		bne	listout_ex
		cmp.b	#2,pass			if not pass#2, no listing
		bne	listout_ex
		move.l	libuf(pc),a1		listing linebuffer
		lea	hextable(pc),a0		table of ASCII hex chars
		move.w	hexbytcnt(pc),d0
		subq.w	#3,d0
		bne.s	listout_pc

		move.l	equset(pc),d1		label set/equted on this line?
		beq.s	listout_noadr		no, output nothing
		addq.l	#1,a1			tab one col right
		btst	#31,d1
		beq.s	listo1
		move.b	#'=',6(a1)		flag user: symbol was EQUted
		bra.s	listo2
listo1		move.b	#'>',6(a1)		flag user: symbol was SET
listo2		bsr	listout_prgc
		subq.l	#1,a1			tab back to orig positing
		clr.l	equset			operation performed -> clear
		bra.s	listout_noadr

listout_pc	move.l	prgc(pc),d1		write pc value into buffer
		bsr	listout_prgc

listout_noadr	move.w	idepth(pc),d0
		beq.s	listout_noinc
		move.b	#'I',5(a1)		code from include file

listout_noinc	cmp.w	#-2,incstrt		code from macro expansion?
		bne.s	listout_nomac
		move.b	#'M',5(a1)

listout_nomac	move.w	condstrt(pc),d0		check if TRUE or FALSE needed
		beq.s	listout_nocond
		lea	7(a1),a1		column
		bmi.s	listout_false
		lea	LO_TRUE(pc),a0
		bra.s	listout_r_cond
listout_false	lea	LO_FALSE(pc),a0
listout_r_cond	bsr	copy_10			write string
		clr.w	condstrt
		move.l	libuf(pc),a1		get pointer back

listout_nocond	move.l	linnum(pc),d0
		setc				no zero suppression
		bsr	conv_10
		lea	buf_10+7(pc),a0
		moveq.l	#4,d1
listout_line	move.b	(a0)+,(a1)+		copy line number
		dbf	d1,listout_line

		move.l	linstrt(pc),a0		copy the line itself
		move.l	libuf(pc),a1
		add.l	#22,a1			tab to col 22
		moveq.l	#0,d1			column counter
listout_cpy	move.b	(a0)+,d0		copyloop
		cmp.b	#TAB,d0
		bne.s	listout_cpynt
listout_tab	move.b	#' ',(a1)+		replace tabs with 1...8 spaces
		addq.l	#1,d1
		move.b	d1,d2
		and.b	#7,d2
		bne.s	listout_tab
		bra.s	listout_cpy		continue with next char
listout_cpynt	move.b	d0,(a1)+
		addq.l	#1,d1			next column
		cmp.b	#LF,d0
		beq.s	listout_eol
		cmp.b	#CR,d0
		bne.s	listout_cpy

listout_eol	bsr	header			print page header if needed
		move.l	listfile(pc),d1		write it out
		move.l	libuf(pc),d2
		move.l	a1,d3
		sub.l	d2,d3
		lib	Dos,Write
		cmp.l	d3,d0			requested length written?
		beq.s	listout_wrok
		error	#62
		bra.s	listout_err
listout_wrok	addq.l	#5,d2			buffer start+5
		move.l	d2,a1
		moveq.l	#16,d0
		moveq.l	#' ',d1
listout_clr	move.b	d1,(a1)+		clear numeric bytes
		dbf	d0,listout_clr
		move.w	#3,hexbytcnt
listout_ex	clr.w	no_list
		pull	d0-d3/a0-a1
		rts
listout_err	clr.w	no_list
		pull	d0-d3/a0-a1
		setc
		rts

listout_prgc	moveq.l	#0,d0			Writes a 16-bit value into buf
		move.b	d1,d0			Value in d1.
		and.b	#15,d0
		move.b	0(a0,d0.w),10(a1)	lowest nybble
		lsr.w	#4,d1
		move.b	d1,d0
		and.b	#15,d0
		move.b	0(a0,d0.w),9(a1)
		lsr.w	#4,d1
		move.b	d1,d0
		and.b	#15,d0
		move.b	0(a0,d0.w),8(a1)
		lsr.w	#4,d1
		move.b	d1,d0
		and.b	#15,d0
		move.b	0(a0,d0.w),7(a1)	highest nybble
		rts


LO_TRUE		dc.b	'TRUE',0
LO_FALSE	dc.b	'FALSE',0
		cnop	0,4


list_clr	push	d0/a0			clear numeric bytes in buffer
		move.l	libuf(pc),a0
		moveq.l	#22,d0
list_clr1	move.b	#' ',(a0)+
		dbf	d0,list_clr1
		pull	d0/a0
		rts


;------------------------------------------------------------------------


ohex		push	d0/d7/a0		output a byte in d7 in hex
		lea	hextable(pc),a0
		move.b	d7,d0
		lsr.b	#4,d7
		and.w	#15,d7
		move.b	0(a0,d7),d7
		bsr.s	ochr
		and.w	#15,d0
		move.b	0(a0,d0),d7
		bsr.s	ochr
		pull	d0/d7/a0
		rts


ochr		push	d0-d3/a0-a1		* output one char.
		move.l	obuf(pc),a1		* Uses buffering.
		cmp.l	#-1,d7			* Buffer is written to disk
		beq.s	ochrflush		* if it becomes full or if
		add.l	#OBUF,a1		* the character ochr'ed is
		move.l	opoi(pc),a0		* -1.
		move.b	d7,(a0)+
		cmp.l	a1,a0
		blt.s	ochrok1
		move.l	obuf(pc),a0
		move.l	outfile(pc),d1
		move.l	a0,d2
		move.l	#OBUF,d3
ochrout		lib	Dos,Write
		move.l	d2,a0
		cmp.l	d3,d0
		beq.s	ochrok1
		error	#61
ochrok1		move.l	a0,opoi
		pull	d0-d3/a0-a1
		rts

ochrflush	move.l	opoi(pc),a0
		sub.l	a1,a0
		move.l	outfile(pc),d1
		move.l	a1,d2
		move.l	a0,d3
		bra.s	ochrout


chr		push	a0			read one byte
		move.l	txtptr(pc),a0
		moveq.l	#0,d0
		move.b	(a0)+,d0
		cmp.b	#CR,d0
		beq.s	chr_eol
		cmp.b	#LF,d0
		beq.s	chr_eol
		move.l	a0,txtptr
chr_eol		pull	a0
		tst.b	d0
		rts


gc		push	a0
		move.l	txtptr(pc),a0		get txtptr
		moveq.l	#0,d0
gc_sk		move.b	(a0)+,d0		get a byte
		beq.s	gc_e
		cmp.b	#';',d0			; = line end
		beq.s	gc_e
		cmp.b	#' ',d0			>' ', legal char
		bhi.s	gc_ok
		cmp.b	#CR,d0			CR means line end
		beq.s	gc_e
		cmp.b	#LF,d0			LF means line end
		beq.s	gc_e
		bra.s	gc_sk			try next char
gc_ok		move.l	a0,txtptr
		pull	a0
		cmp.b	#0,d0
		rts
gc_e		addq.b	#1,pat_pend		one LF fetched
		pull	a0
		moveq.l	#0,d0
		rts


gec		push	a0
		move.l	txtptr(pc),a0		get txtptr
		moveq.l	#0,d0
gec_sk		move.b	(a0)+,d0		get a byte
		beq.s	gec_e
		cmp.b	#';',d0			; = line end
		beq.s	gec_e
		cmp.b	#' ',d0			>' ', legal char
		bhi.s	gec_ok
		cmp.b	#CR,d0			CR means line end
		beq.s	gec_e
		cmp.b	#LF,d0			LF means line end
		beq.s	gec_e
gec_ok		move.l	a0,txtptr
		pull	a0
		cmp.b	#0,d0
		rts
gec_e		addq.b	#1,pat_pend		one LF fetched
		pull	a0
		moveq.l	#0,d0
		rts


gpeek		push	a0
		move.l	txtptr(pc),a0
		moveq.l	#0,d0
		move.b	(a0),d0
		pull	a0
		tst.b	d0
		rts

cg		tst.b	pat_pend
		beq.s	cg_ok
		subq.b	#1,pat_pend		one LF backwards
		rts
cg_ok		subq.l	#1,txtptr
cg_ex		rts


ck_stop		push	d0-d1/a0-a1		check if CTRL_C pressed
		moveq.l	#0,d0
		moveq.l	#0,d1
		lib	Exec,SetSignal
		btst	#CTRL_C,d0
		beq.s	ck_nostop
		moveq.l	#0,d0
		moveq.l	#0,d1
		bset	#CTRL_C,d1
		lib	Exec,SetSignal		clear signal
		moveq.l	#1,d0			NE: STOP!!!
		move.w	d0,broken		set flag: STOPPED!!
		pull	d0-d1/a0-a1
		rts
ck_nostop	moveq.l	#0,d0			EQ: no stop
		pull	d0-d1/a0-a1
		rts


;------------------------------------------------------------------------


mulmul		push	d0/d2-d4
		bsr	SetSignMD	d1 = d0 * d1
		move.l	d0,d4		multiplication HL * hl
		mulu.w	d1,d0		L*l
		move.l	d0,d3		low word
		move.l	d4,d0
		swap	d0		high word
		mulu.w	d1,d0		L*h
		swap	d0
		tst.w	d0
		bne.s	mulmuler	result bigger than 32 bits
		add.l	d0,d3		d3 contains L*(hl)
		swap	d1		get low word
		move.w	d4,d0
		mulu.w	d1,d0		H*l
		swap	d0		result to high word
		tst.w	d0		 (hw of mulu must be zero)
		bne.s	mulmuler
		add.l	d0,d3		d3 contains L*(hl)+H*l
		bcs.s	mulmuler

		move.l	d4,d0
		swap	d0		get low word
		mulu.w	d1,d0		H*h (must be always zero)
		bne.s	mulmuler
		btst	#31,d3		bit #31 must be zero (sign)
		bne.s	mulmuler

		move.l	d3,d1
		tst.l	d2		set appropriate sign
		bpl.s	mulmula
		neg.l	d1
mulmula		pull	d0/d2-d4
		clrc
		rts
mulmuler	setc
		pull	d0/d2-d4
		rts


divdiv		push	d0/d2-d5	d1 = d1 / d0
		tst.l	d0		divisor = 0?
		bne.s	divdiv1
		error	#131
		pull	d0/d2-d5
		rts

divdiv1		bsr.s	SetSignMD
		moveq.l	#0,d3
		moveq.l	#31,d5		bit counter
divdivloop	roxl.l	#1,d1
		roxl.l	#1,d3		d3 is a 'working accum'
		cmp.l	d0,d3
		blo.s	divdivless
		sub.l	d0,d3
		setx
		roxl.l	#1,d4		if subtracted, set bit
		dbf	d5,divdivloop
		bra.s	divdivdone
divdivless	asl.l	#1,d4
		dbf	d5,divdivloop

divdivdone	move.l	d4,d1		set appropriate sign
		tst.l	d2
		bpl.s	divdiv2
		neg.l	d1
divdiv2		pull	d0/d2-d5
		clrc
		rts


SetSignMD	move.l	d0,d2		get sign of result into d2[31]
		eor.l	d1,d2
		tst.l	d0		make d0 positive if necessary
		bpl.s	SetSign1
		neg.l	d0
SetSign1	tst.l	d1		make d1 positive
		bpl.s	SetSign2
		neg.l	d1
SetSign2	rts


;------------------------------------------------------------------------


errhandler	and.l	#$ffff,d0
		move.w	d0,errornum
		clrc
		bsr	conv_10
		lea	buf_10+7(pc),a0
		lea	ERROR_NUM(pc),a1
		bsr	copy_10
		cmp.w	#100,errornum
		blo	errhand0
		move.l	linnum(pc),d0
		clrc
		bsr	conv_10
		lea	buf_10+7(pc),a0
		lea	ERROR_LIN(pc),a1
		bsr	copy_10
		printa	#ERROR_SC
		move.l	nameptr(pc),a0
		move.l	auxbuf(pc),a1
		move.l	linnum(pc),d0	don't print line if line# = 0
		beq.s	errhand2a
err_cpname	move.b	(a0)+,d0
		beq.s	err_nameok
		cmp.b	#39,d0
		beq.s	err_nameok
		cmp.b	#' ',d0
		beq.s	err_nameok
		move.b	d0,(a1)+
		bra.s	err_cpname

err_nameok	move.l	linstrt(pc),a0
		move.b	#':',(a1)+
		move.b	#'"',(a1)+
		move.w	#128,d1		max # of chars
errhand1	move.b	(a0)+,d0	copy line
		bsr	ck_eol
		bvs.s	errhand2
		move.b	d0,(a1)+
		dbf	d1,errhand1
errhand2	move.b	#'"',(a1)+
errhand2a	move.b	#LF,(a1)+
		clr.b	(a1)
		printa	auxbuf(pc)
		move.l	listfile(pc),d0
		beq.s	errhand0
		printa	#ERROR_SC,d0		error
		printa	auxbuf(pc),d0		line
errhand0	bsr.s	print_error		msg
		addq.l	#1,errcnt
		setc
		rts

ERROR_SC	dc.b	LF,'*** Error '
ERROR_NUM	dc.b	'      on line '
ERROR_LIN	dc.b	'      ***',LF,0
		cnop	0,4


print_error	moveq.l	#0,d0		reset high word
		move.w	errornum(pc),d0
		divu.w	#10,d0		calc main error#
		lea	ermsgs(pc),a0
print_err_lp	subq.w	#1,d0		find ermsg#d0
		beq.s	print_errf
print_err_seek	tst.b	(a0)+		find end of this msg
		bne.s	print_err_seek
		tst.b	(a0)		last one?
		bpl.s	print_err_lp	no, continue
print_err_err	print	<'### INTERNAL ERROR #1: Please report ###',LF>
		bra.s	print_err_ex
print_errf	tst.b	(a0)		if no ermsg for this number
		beq.s	print_err_err
		printa	a0
		move.l	listfile(pc),d0
		beq.s	print_err_ex
		printa	a0,d0
print_err_ex	rts


;------------------------------------------------------------------------


copy_10		push	d0
copy_10_l	move.b	(a0)+,d0
		beq.s	copy_10_e
		move.b	d0,(a1)+
		bra.s	copy_10_l
copy_10_e	pull	d0
		rts


sign_10		btst	#31,d0
		beq.s	conv_10
		neg.l	d0
		clrc
		bsr.s	conv_10
		push	a0
		lea	buf_10(pc),a0
sign_10_1	cmp.b	#' ',(a0)+
		beq.s	sign_10_1
		move.b	#'-',-2(a0)
		pull	a0
		rts

print10		setc
		bsr.s	conv_10		for testing purposes only
		printa	#buf_10
		print	<LF>
		rts



conv_10		push	all		if carry clear, leading zeroes blanked
		bcs.s	conv_10_0
		moveq.l	#' ',d2
		bra.s	conv_10_spc
conv_10_0	moveq.l	#'0',d2
conv_10_spc	lea	bcd_10+6(pc),a0
		lea	res_10+6(pc),a1
		moveq.l	#0,d1			clear result first
		move.l	d1,-6(a0)
		move.l	d1,-2(a0)
		move.l	d1,-6(a1)
		move.l	d1,-2(a1)
		move.b	#1,-1(a0)		seed value
conv_10_main	lsr.l	#1,d0
		bcc.s	conv_10_next
		move.l	a0,a2
		move.l	a1,a3
		clrx
		abcd	-(a2),-(a3)		add seed value to result
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		tst.l	d0
conv_10_next	beq.s	conv_10_asc
		move.l	a0,a2			multiply seed value by 2
		move.l	a0,a3
		clrx
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		bra.s	conv_10_main
conv_10_asc	lea	res_10(pc),a0		convert to ascii
		lea	buf_10(pc),a1
		moveq.l	#5,d1
conv_10_al	move.b	(a0)+,d3
		move.b	d3,d0
		lsr.b	#4,d0
		beq.s	conv_10_al1
		moveq.l	#'0',d2
conv_10_al1	or.b	d2,d0
		move.b	d0,(a1)+
		and.b	#15,d3
		beq.s	conv_10_al2
		moveq.l	#'0',d2
conv_10_al2	or.b	d2,d3
		move.b	d3,(a1)+
		dbf	d1,conv_10_al
		or.b	#'0',d3
		move.b	d3,-1(a1)
		move.b	#0,(a1)
		pull	all
		rts

bcd_10		ds.l	2
res_10		ds.l	2
buf_10		ds.l	4


sign_16		btst	#31,d0
		beq.s	sign_16_plus
		neg.l	d0
		bsr.s	conv_16
		move.b	#'-',buf_16+3
		rts
sign_16_plus	bsr.s	conv_16
		move.b	#' ',buf_16+3
		rts


conv_16		push	d0-d2/a0-a1
		lea	buf_16+8(pc),a0
		lea	hextable(pc),a1
		moveq.l	#3,d2
		moveq.l	#0,d1
conv_16_lp	move.b	d0,d1
		and.b	#15,d1
		move.b	0(a1,d1),-(a0)
		lsr.l	#4,d0
		move.b	d0,d1
		and.b	#15,d1
		move.b	0(a1,d1),-(a0)
		lsr.l	#4,d0
		dbf	d2,conv_16_lp
		pull	d0-d2/a0-a1
		rts

buf_16		ds.l	2
		dc.w	0


ck_opt		move.l	_CMDBuf(pc),a0		check for options on cmd line
		move.l	obuf(pc),a1		copy filename into obuf
ck_opt_lp1	move.b	(a0)+,d0		search for end of filename
		move.b	d0,(a1)+		copy filename
		beq.s	ck_opt_ex
		bsr	ck_blk
		bcc.s	ck_opt_lp1
		clr.b	-1(a1)			add null to filename
ck_opt_lp2	move.b	(a0)+,d0		find '-opt'
		beq.s	ck_opt_ex
		bsr	ck_blk
		bcs.s	ck_opt_lp2		skip blanks
		cmp.b	#'-',d0
		bne.s	ck_opt_er
		move.b	(a0)+,d0
		bsr	ucase
		cmp.b	#'L',d0			listmode?
		bne.s	ck_opt_l
		move.w	#1,userlmode		set default: listmode ON
		move.w	#1,listmode
		bra.s	ck_opt_lp2
ck_opt_l	cmp.b	#'H',d0			hexmode?
		bne.s	ck_opt_h
		move.w	#1,hexmode
		bra	ck_opt_lp2
ck_opt_h	cmp.b	#'S',d0			symbolmode?
		bne.s	ck_opt_s
		move.w	#1,symbolmode
		bra	ck_opt_lp2
ck_opt_s	cmp.b	#'C',d0			CMOSmode?
		bne	ck_opt_s
		move.w	#1,procmode
		bra	ck_opt_lp2
ck_opt_c

ck_opt_er	error	#91			option error
		rts
ck_opt_ex	clrc
		rts


;------------------------------------------------------------------------


OpenFiles	bsr	ck_opt			parse options
		bcs	Open_err
		move.l	obuf(pc),a0		filename is here
		tst.b	(a0)
		bne	Open_name_ok
		error	#81
		printa	#USAGE
		bra	Open_err

USAGE		dc.b	CSI,'1mUsage: Asm65 ',60,'filename',62,' [-opt]'
		dc.b	CSI,'0m',LF
		dc.b	' where -opt is:',LF
		dc.b	'  -c for 65c02 instruction set',LF
		dc.b	'  -s for symbol table listing',LF
		dc.b	'  -h for hexadecimal output file',LF
		dc.b	'  -l for listing file'
LFLF		dc.b	LF,LF,0
		cnop	0,4


Open_name_ok	move.l	_CMDBuf(pc),linstrt	addr of cmdline
		bsr	mkname			create output filenames

		print	<'Checking file lengths...',LF>
		move.l	auxbuf(pc),a0		main filename
		move.l	#0,a1			output ptr=0: check length
		moveq.l	#0,d7			nesting level
		bsr	MainLoad
		bcs	Open_err

		move.l	total_len(pc),d0	total length of files
		move.l	d0,d1
		asr.l	#1,d1			multiply by 1.5
		add.l	d1,d0			(allow 50% for macros)
		add.l	#MINSOURCE,d0		add minimum size
		move.l	d0,SOURCEBUF

		move.l	SOURCEBUF(pc),d0	this many RAM bytes needed
		move.l	d0,d2
		sub.l	#256,d2			for safety
		move.l	#MEMF_CLEAR,d1
		lib	Exec,AllocMem		ask for them
		move.l	d0,sourcebuf		save start addr
		beq	Open_mem_er		no mem, exit
		add.l	d2,d0
		move.l	d0,sourceend		end of buffer

		print	<'Processing macros...',LF>
		move.l	auxbuf(pc),a0		filename
		move.l	sourcebuf(pc),a1	output ptr
		moveq.l	#0,d7			nesting level
		bsr	MainLoad
		bcs	Open_err

Open_ok		move.l	multibuf(pc),d1		file to write
		move.l	#1006,d2		mode: create
		lib	Dos,Open		open it
		move.l	d0,outfile		save ptr
		bne.s	Open_list
		error	#51
		bra.s	Open_err

Open_list	move.w	listmode(pc),d0		if (listmode)
		beq.s	Open_l_ok
		move.l	listfile(pc),d0
		bne.s	Open_l_ok
		move.l	multibuf(pc),d1		listfile
		add.l	#NAME1BUF,d1
		move.l	#1006,d2		mode: create
		lib	Dos,Open		open it
		move.l	d0,listfile		save ptr
		bne.s	Open_l_ok
		error	#52
		bra.s	Open_err

Open_l_ok	clrc
		rts

Open_mem_er	error	#42			mem alloc error
Open_err	setc
		rts


mkname		push	d0/a0/a1		create in/output filename
		move.l	obuf(pc),a0
		move.l	auxbuf(pc),a1		filename.asm
		bsr	strcpy
		subq.l	#1,a1
		lea	ASM_EXT(pc),a0
		bsr	strcpy			appends '.asm'
		move.l	obuf(pc),a0
		move.l	multibuf(pc),a1
		bsr	strcpy
		move.w	hexmode(pc),d0		if not in hexmode, no '.hex'
		beq.s	mkname1
		subq.l	#1,a1
		lea	HEX_EXT(pc),a0
		bsr	strcpy			appends '.hex'
mkname1		move.l	obuf(pc),a0
		move.l	multibuf(pc),a1
		add.l	#NAME1BUF,a1
		bsr	strcpy
		subq.l	#1,a1
		lea	LST_EXT(pc),a0
		bsr	strcpy			appends '.lst'
		pull	d0/a0/a1
		rts
ASM_EXT		dc.b	'.asm',0
HEX_EXT		dc.b	'.hex',0
LST_EXT		dc.b	'.lst',0
		cnop	0,4


calc		clr.b	zpabs
		bsr.s	calcq
		bcs.s	calinaa
		cmp.l	#256,d0
		blo.s	calc0
		or.b	#1,zpabs
calc0		tst.l	d0
calinaa		rts

calcq		push	d1			calculates at (txtptr)
		bsr	gnumb			calc level #0
		bcs.s	calcqere
		move.l	d0,d1
calcq0		bsr	gc
		cmp.b	#'+',d0			addition
		bne.s	calcq1
		bsr	gnumb
		bcs.s	calcqere
		add.l	d0,d1
		bvc.s	calcq0
		moveq.l	#101,d0
calcqv		error
calcqere	pull	d1
		setc
		rts
calcq1		cmp.b	#'-',d0			subtraction
		bne.s	calcq2
		bsr.s	gnumb
		bcs.s	calcqere
		sub.l	d0,d1
		bvc.s	calcq0
		move.w	#102,d0
		bra.s	calcqv
calcq2		cmp.b	#'&',d0			andition
		bne.s	calcq3
		bsr.s	gnumb
		bcs.s	calcqere
		and.l	d0,d1
		bra	calcq0
calcq3		cmp.b	#'!',d0			orition
		bne.s	calcq4
		bsr.s	gnumb
		bcs	calcqere
		or.l	d0,d1
		bra	calcq0
calcq4		cmp.b	#'^',d0			xorition
		bne.s	calcq5
		bsr.s	gnumb
		bcs	calcqere
		eor.l	d0,d1
		bra	calcq0
calcq5		cmp.b	#'<',d0			leftertion
		bne.s	calcq6
		bsr.s	gnumb
		bcs	calcqere
		asl.l	d0,d1
		bvc	calcq0
		move.w	#103,d0
		bra	calcqv
calcq6		cmp.b	#'>',d0			rightertion
		bne.s	calcq7
		bsr.s	gnumb
		bcs	calcqere
		asr.l	d0,d1
		bra	calcq0
calcq7		bsr	cg
		move.l	d1,d0
		pull	d1
		clrc
		rts


gnumb		push	d1			calc level #1
		bsr	gnumbb
		bcs.s	gnumbere
		move.l	d0,d1
gnumb0		bsr	gc
		cmp.b	#'*',d0			multiplication
		bne.s	gnumb1
		bsr.s	gnumbb
		bcs.s	gnumbere
		bsr	mulmul
		bcc	gnumb0
		moveq.l	#111,d0
gnumbv		error
gnumbere	pull	d1
		setc
		rts
gnumb1		cmp.b	#'/',d0			division
		bne.s	gnumb2
		bsr.s	gnumbb
		bcs.s	gnumbere
		bsr	divdiv
		bcc	gnumb0
		move.w	#131,d0			div. by 0
		bra	gnumbv
gnumb2		cmp.b	#'\',d0			modulo-op
		bne.s	gnumb3
		bsr.s	gnumbb
		bcs	gnumbere
		tst.w	d0
		beq.s	modmoderr
		push	d2
		move.l	d1,d2
		divs.w	d0,d2
		bvs.s	modmodvs
		clr.w	d2
		swap	d2
		ext.l	d2
		move.l	d2,d1
		pull	d2
		bra	gnumb0
modmoderr	move.w	#132,d0
		bra	gnumbv
modmodvs	pull	d2
		move.w	#286,d0
		bra	gnumbv
gnumb3		bsr	cg
		move.l	d1,d0
		pull	d1
		clrc
		rts


gnumbb		push	d1
		bsr	gc
		cmp.b	#'-',d0
		bne.s	gnumbb1
		bsr	gnumbb
		bcs.s	gnumbbere
		neg.l	d0
gnumbbx		pull	d1
		clrc
		rts
gnumbbparmism	error	#141
gnumbbere	pull	d1
		setc
		rts
gnumbb1		cmp.b	#'~',d0
		bne.s	gnumbb1_5
		bsr	gnumbb
		bcs.s	gnumbbere
		not.l	d0
		bra.s	gnumbbx
gnumbb1_5	cmp.b	#'[',d0
		bne.s	gnumbb2
		bsr	calcq
		bcs	gnumbbere
		move.l	d0,d1
		bsr	gc
		cmp.b	#']',d0
		bne	gnumbbparmism
		move.l	d1,d0
		bra	gnumbbx
gnumbb2		cmp.b	#'<',d0
		bne.s	gnumbb3
		bsr	gnumbb
		bcs	gnumbbere
		and.l	#$ff,d0
		bra	gnumbbx
gnumbb3		cmp.b	#'>',d0
		bne.s	gnumbb3_5
		bsr	gnumbb
		bcs	gnumbbere
		lsr.l	#8,d0
		bra	gnumbbx
gnumbb3_5	cmp.b	#'@',d0
		bne.s	gnumbb4
		bsr	getmn
		bcc.s	gnumbb3_5b
gnumbb3_5c	error	#532
		bra	gnumbbere
gnumbb3_5b	cmp.l	#'MODE',d0
		bne.s	gnumbb3_5c
		bsr	getmode
		bra	gnumbbx
gnumbb4		cmp.b	#'$',d0
		bne.s	gnumbb5
		bsr.s	gethex
		bcs	gnumbbere
		bra	gnumbbx
gnumbb5		cmp.b	#'%',d0
		bne.s	gnumbb6
		bsr	getbin
		bcs	gnumbbere
		bra	gnumbbx
gnumbb6		cmp.b	#'&',d0
		bne.s	gnumbb6_5
		bsr	getoct
		bcs	gnumbbere
		bra	gnumbbx
gnumbb6_5	cmp.b	#'^',d0
		bne.s	gnumbb7
		bsr	getqui
		bcs	gnumbbere
		bra	gnumbbx
gnumbb7		cmp.b	#39,d0
		bne.s	gnumbb8
		bsr	getasc
		bcs	gnumbbere
		bra	gnumbbx
gnumbb8		cmp.b	#'0',d0
		blo.s	gnumbb9
		cmp.b	#'9',d0
		bhi.s	gnumbb9
		bsr	cg
		bsr	getdec
		bcs	gnumbbere
		bra	gnumbbx
gnumbb9		bsr	cg
		bsr	glabel
		bcs	gnumbbere
		bra	gnumbbx


gethex		push	d1
		moveq.l	#0,d1
gethex1		bsr	gc
		bsr	ucase
		cmp.b	#'F',d0
		bhi.s	gethexx
		sub.b	#'0',d0
		blo.s	gethexx
		cmp.b	#10,d0
		blo.s	gethex2
		sub.b	#7,d0
gethex2		asl.l	#4,d1
		bvs.s	gethexe
		or.b	d0,d1
		bra	gethex1
gethexx		bsr	cg
		move.l	d1,d0
		pull	d1
		clrc
		rts
gethexe		error	#121
		pull	d1/d1
		rts

getbin		push	d1
		moveq.l	#0,d1
getbin1		bsr	gc
		cmp.b	#'1',d0
		bhi.s	gethexx
		sub.b	#'0',d0
		blo.s	gethexx
		add.l	d1,d1
		bvs.s	getbine
		or.b	d0,d1
		bra.s	getbin1
getbine		error	#122
		pull	d1/d1
		rts

getoct		push	d1
		moveq.l	#0,d1
getoct1		bsr	gc
		cmp.b	#'7',d0
		bhi	gethexx
		sub.b	#'0',d0
		blo	gethexx
		asl.l	#3,d1
		bvs.s	getocte
		or.b	d0,d1
		bra.s	getoct1
getocte		error	#123
		pull	d1/d1
		rts

getqui		push	d1
		moveq.l	#0,d1
getqui1		bsr	gc
		cmp.b	#'3',d0
		bhi	gethexx
		sub.b	#'0',d0
		blo	gethexx
		asl.l	#2,d1
		bvs.s	getquie
		or.b	d0,d1
		bra.s	getqui1
getquie		error	#124
		pull	d1/d1
		rts


getdec		push	d1/d2		get a decimal number
		moveq.l	#0,d1		clear result
		bsr	gc		get a byte
getdecloop	and.b	#15,d0		convert to binary
		add.l	d1,d1		multiply old value by 10
		bvs.s	getdece		if overflow
		move.l	d1,d2
		asl.l	#2,d1
		bvs.s	getdece
		add.l	d2,d1
		bvs.s	getdece
		add.l	d0,d1		add new digit
		bvs.s	getdece
		bsr	gec		get next byte
		bsr.s	ck_dig		is it a digit?
		bcs.s	getdecloop
		bsr	cg		dec txtptr
		move.l	d1,d0
		clrc
		pull	d1/d2
		rts
getdece		error	#125
		pull	d1/d2
		rts


getasc		push	d1
		moveq.l	#0,d1
getasc1		bsr	chr
		cmp.b	#' ',d0
		blo	gethexe
		cmp.b	#39,d0
		beq.s	getascx
		asl.l	#8,d1
		bvs	gethexe
		or.b	d0,d1
		bra.s	getasc1
getascx		bsr	gc
		bra	gethexx


ck_dig		cmp.b	#'0',d0		is it a digit?
		blo.s	ck_dig_n
		cmp.b	#'9',d0
		bhi.s	ck_dig_n
		setc
		rts
ck_dig_n	clrc
		rts


ck_ap		cmp.b	#'A',d0		is it alpha?
		blo.s	ck_ap_n
		cmp.b	#'Z',d0
		bhi.s	ck_ap_n
		setc
		rts
ck_ap_n		clrc
		rts

gece		bsr	gec
		bra.s	ck_eol
gce		bsr	gc

ck_eol		tst.b	d0		is it end-of-line?
		beq.s	ck_eol_y
		cmp.b	#';',d0
		bhi.s	ck_eol_n
		beq.s	ck_eol_co
		cmp.b	#CR,d0
		beq.s	ck_eol_y
		cmp.b	#LF,d0
		beq.s	ck_eol_y
ck_eol_n	clrc
		clrv
		rts
ck_eol_y	setc
		setv			v=1: null/CR/LF
		rts
ck_eol_co	setc			c=1: ;/null/CR/LF
		clrv
		rts

ck_lc		cmp.b	#'A',d0		A...Z
		blo.s	ck_lc1
		cmp.b	#'Z',d0
		bls.s	ck_lc_y
		cmp.b	#'a',d0		a...z
		blo.s	ck_lc5
		cmp.b	#'z',d0
		bls.s	ck_lc_y
ck_lc_n		clrc			not a label char
		clrv
		rts
ck_lc1		cmp.b	#'0',d0		0...9
		blo.s	ck_lc2
		cmp.b	#'9',d0
		bls.s	ck_lc_yn
ck_lc2		cmp.b	#'.',d0		'.'
		bne.s	ck_lc_n
ck_lc_y		setc			label char, non-numeric
		clrv
		rts
ck_lc_yn	setc			label char, numeric
		setv
		rts
ck_lc5		cmp.b	#'_',d0		'_'
		beq.s	ck_lc_y
		bra.s	ck_lc_n


ck_blk		cmp.b	#' ',d0		check if blank
		beq.s	ck_blk_y
		cmp.b	#TAB,d0
		beq.s	ck_blk_y
		clrc
		rts
ck_blk_y	setc			blank detected!
		rts


ck_ibit		push	d1
		bsr	gc		check if '#0,'...'#7,'
		cmp.b	#'#',d0
		bne.s	ck_ibit_n	if not #
		bsr	gec
		cmp.b	#'0',d0		if not 0...7
		blo.s	ck_ibit_n
		cmp.b	#'7',d0
		bhi.s	ck_ibit_n
		and.b	#15,d0
		move.l	d0,d1
		bsr	gec
		cmp.b	#',',d0
		bne.s	ck_ibit_n	if not comma
		move.l	d1,d0
		pull	d1
		setc
		rts
ck_ibit_n	pull	d1
		clrc
		rts


ck_lim16	cmp.l	#-32768,d0	is it -32768...65535
		blt.s	ck_lim16_n
		cmp.l	#65535,d0
		bgt.s	ck_lim16_n
		setc			yes
		rts
ck_lim16_n	clrc			no
		rts


ck_lim8		cmp.l	#255,d0
		bgt.s	ck_lim8_n
		cmp.l	#-128,d0
		blt.s	ck_lim8_n
		setc
		rts
ck_lim8_n	clrc
		rts


ck_str		bsr	gce		get string addresses for ifc, ifnc
		bcs.s	ck_str_er	end of line
		cmp.b	#39,d0
		bne.s	ck_str_er
		move.l	txtptr(pc),a0	start of first string
ck_str_lp1	bsr	gce		search for end of string 1
		bcs.s	ck_str_er
		cmp.b	#39,d0
		bne.s	ck_str_lp1
		bsr	gce
		cmp.b	#',',d0		check for comma
		bne.s	ck_str_er
		bsr	gce
		cmp.b	#39,d0
		bne.s	ck_str_er
		move.l	txtptr(pc),a1
ck_str_lp2	bsr	gce		find final '
		bcs.s	ck_str_er
		cmp.b	#39,d0
		bne.s	ck_str_lp2
		clrc
		rts
ck_str_er	error	#531		sye
		rts


ck_ifc		push	a0-a1
		bsr	ck_str
		bcs.s	ck_ifc_er
ck_ifc_lp1	move.b	(a0)+,d0	compare until '
		cmp.b	(a1)+,d0
		bne.s	ck_ifc_nequ
		cmp.b	#39,d0
		bne.s	ck_ifc_lp1
		pull	a0-a1
		moveq.l	#0,d0		equal
		rts
ck_ifc_nequ	pull	a0-a1
		moveq.l	#1,d0		differ
		rts
ck_ifc_er	pull	a0-a1		error
		rts


ck_ifi		push	a0-a3/d1
		bsr	ck_str
		bcs	ck_ifc_er
		cmp.b	#39,(a0)
		beq.s	ck_ifif
ck_ifi0		move.l	a0,a2
ck_ifi1		move.b	(a1)+,d0
		cmp.b	#39,d0
		beq.s	ck_ifinf
		cmp.b	(a2)+,d0
		bne.s	ck_ifi0
		move.l	a1,a3
ck_ifi2		move.b	(a2)+,d1
		cmp.b	#39,d1
		beq.s	ck_ifif
		move.b	(a1)+,d0
		cmp.b	#39,d0
		beq.s	ck_ifinf
		cmp.b	d0,d1
		beq.s	ck_ifi2
		move.l	a3,a1
		bra.s	ck_ifi0
ck_ifinf	pull	a0-a3/d1
		moveq.l	#-1,d0
		rts
ck_ifif		pull	a0-a3/d1
		moveq.l	#0,d0
		rts

ck_ifi_er	pull	a0-a3/d1
		rts


ucase		cmp.b	#'a',d0
		blo.s	ucase1
		cmp.b	#'z',d0
		bhi.s	ucase1
		sub.b	#32,d0
ucase1		rts


strcmp		push	d1		check if s0 = s1
strcmp1		move.b	(a0)+,d0
		beq.s	strcmp_1e
		move.b	(a1)+,d1
		beq.s	strcmp_s1l	string 1 less
		cmp.b	d1,d0
		beq.s	strcmp1
		bhi.s	strcmp_s1l	string 1 less
strcmp_s0l	pull	d1
		moveq.l	#-1,d0
		setc
		rts			s0 < s1

strcmp_1e	move.b	(a1)+,d1
		bne.s	strcmp_s0l	string 0 less
		pull	d1
		moveq.l	#0,d0
		rts			s0 = s1

strcmp_s1l	pull	d1
		moveq.l	#1,d0
		clrc
		rts			s0 > s1


strcpy		move.b	(a0)+,(a1)+	copy s0 to s1
		bne.s	strcpy
		rts


pass1		push	all
		bsr	Clr_LBuf		clear labelbuf
		move.l	sourcebuf(pc),txtptr	set text pointer
		move.l	sourcebuf(pc),linstrt
		clr.b	pat_pend	no LF's fetched
		move.w	userlmode,listmode
		moveq.l	#0,d0
		move.l	d0,prgc
		move.w	d0,cond_level	no conditioning
		moveq.l	#1,d0
		move.l	d0,linnum
		move.l	_CMDBuf(pc),nameptr	main filename for errhandler()
		move.b	#1,pass
		print	<'Pass 1 - Creating Symbol Table',LF>

pass1_loop	bsr	ck_stop
		bne	pass1_stop
		bsr	gpeek
		beq.s	pass1_end
		cmp.w	#-1,incstrt	check if a macro starts
		bne.s	pass1_nomac
		bsr	slabel		save labels on macro usage lines
		bra.s	pass1_macskip
pass1_nomac	bsr	ck_eol
		bcs.s	pass1_next
		bsr	ck_blk		if blank: no label
		bcs.s	pass1_nolab
		bsr	slabel
		bcs.s	pass1_next
		bsr	gc
		bsr	ck_eol
		bcs.s	pass1_next
		bsr	cg

pass1_nolab	bsr	seek_op
		bcs.s	pass1_next
		add.l	d0,prgc
		move.l	prgc(pc),d0
		bsr	ck_lim16
		bcc	pass_pc_high
		bsr	gce		line end?
		bcs.s	pass1_next
		error	#201
		bra.s	pass1_next
pass1_macskip	move.w	#-2,incstrt
pass1_next	bsr	condition	check conditional assembly
		bsr	seek_nexl
		clr.b	pat_pend	no LF's fetched over line end
		bra	pass1_loop
pass1_end	move.l	errcnt(pc),d0
		beq	pass1_noer
		print	<'Assembly aborted...'>
		clrc
		bsr	conv_10
		printa	#buf_10
		print	<' error(s) detected.',LF>
pass1_stop	pull	all
		setc
		rts
pass1_noer	print	<'Symbol table complete.',LF>
		pull	all
		clrc
		rts

pass_pc_high	error	#291		pc > $ffff
		bra	pass1_end


pass2		push	all
		move.l	sourcebuf(pc),txtptr	set text pointer
		move.l	sourcebuf(pc),linstrt
		clr.b	pat_pend		no LF's fetched
		bsr	list_clr
		move.w	userlmode,listmode
		moveq.l	#0,d0
		move.l	d0,prgc			pc=0
		move.w	d0,idepth		no including done
		move.w	d0,no_list		listing allowed
		move.w	d0,cond_level		no conditions operative
		move.w	d0,condstrt		no conditions started
		moveq.l	#1,d0
		move.l	d0,linnum		line=1
		move.l	_CMDBuf(pc),nameptr	main filename for errhandler()
		move.b	#2,pass			pass=2
		print	<'Pass 2 - Assembling',LF>

pass2_loop	bsr	ck_stop
		bne	pass2_stop
		clr.l	equset		no labels set yet
		bsr	gpeek
		beq	pass2_end
		cmp.w	#-1,incstrt	check if start of a macro
		beq.s	pass2_macskip	if it is, skip this line
		bsr	ck_eol
		bcs.s	pass2_nxt
		bsr	ck_blk
		bcs.s	pass2_nolab
		bsr	slabel2
		bcs.s	pass2_nxt
		bsr	gc
		bsr	ck_eol
		bcs.s	pass2_nxt
		bsr	cg

pass2_nolab	bsr	seek_op
		bcs.s	pass2_next
		bsr	listout			write listing
		bcs.s	pass2_end
		add.l	d0,prgc
		add.l	d0,totalbyt		add to bytes of object
		move.l	prgc(pc),d0
		bsr	ck_lim16
		bcc	pass_pc_high
		bsr	gce			end of line?
		bcs.s	pass2_next
		error	#202
		bra.s	pass2_next
pass2_macskip	move.w	#-2,incstrt
pass2_nxt	bsr	listout
pass2_next	bsr	condition		check start of conditional assembly
		bsr	seek_nexl
		clr.b	pat_pend		no LF's fetched
		bra	pass2_loop
pass2_end	move.l	errcnt(pc),d0
		beq	pass2_noer
		print	<'Assembly incomplete...'>
		clrc
		bsr	conv_10
		printa	#buf_10
		print	<' error(s) detected.',LF>
pass2_stop	pull	all
		setc
		rts
pass2_noer	print	<'No errors detected during this assembly.',LF>
		pull	all
		clrc
		rts


seek_nexl	push	d0/a0		seek for next source line
		move.l	txtptr(pc),a0
seek_nexl1	move.b	(a0)+,d0	find next CR/LF/NULL
		beq.s	seek_nexlend
		cmp.b	#CR,d0
		beq.s	seek_nexlf
		cmp.b	#LF,d0
		bne	seek_nexl1
		bra.s	seek_nexlf
seek_nexlend	subq.l	#1,a0
seek_nexlf	move.l	a0,txtptr
		move.l	a0,linstrt
		move.w	incstrt(pc),d0	macro/include file flag
		bmi.s	seek_macro	if macro, don't increment linnum
		beq.s	seek_not_inc	start of a new include file? eq=no
		moveq.l	#0,d0
		move.w	d0,incstrt	clear flag
		move.l	d0,linnum	reset linenumber
		addq.w	#1,idepth	processing include file now
seek_not_inc	addq.l	#1,linnum	increment line number
seek_macro	pull	d0/a0
		rts


condition	move.w	cond_level(pc),d1
		lea	condflags(pc),a0 check current state: true/false
		move.b	0(a0,d1.w),d1
		bmi.s	condit_on	MI: no assembly!!
		move.w	incstrt(pc),d1
		bmi	mac_def
		rts

condit_on	bsr	seek_nexl	get next line
		clr.b	pat_pend	DO SOME PATENTING HERE if meant to work...
		move.l	txtptr(pc),a0
		move.b	(a0),d0
		beq	condit_end	end of program

		bsr	ck_eol
		bcs	condit_next	eol or comment -> next line!

		bsr	ck_blk		if blank, no label
		bcs.s	condit_nolbel	I SAID NO LABEL!
		move.l	txtptr(pc),a0
		bsr	getlb		skip label name
		move.l	a0,txtptr

condit_nolbel	bsr	gce		get char, skip blanks
		bcs.s	condit_next	if end/comment, next
		bsr	cg		one char backwards! Don't eat 'E' of ENDC
		bsr	getmn
		bsr	condit_ck_mi	check if macro/include
		cmp.l	#'ENDC',d0
		beq.s	condit_leave
		lea	PSEUDOS(pc),a0	check if new start of cond. assembly
condit_ck_ifany	move.l	(a0)+,d1	check if it is a PSEUDO
		beq.s	condit_next
		cmp.l	d0,d1
		beq.s	condit_ck_if
		addq.l	#4,a0
		bra.s	condit_ck_ifany
condit_ck_if	lsr.l	#8,d0		check if it starts with 'IF'
		cmp.l	#'IF',d0
		beq.s	condit_deeper
		lsr.l	#8,d0
		cmp.l	#'IF',d0
		bne.s	condit_next
condit_deeper	move.w	cond_level(pc),d0
		addq.w	#1,d0		one step deeper, please!
		move.w	d0,cond_level
		lea	condflags(pc),a0
		move.b	#-1,0(a0,d0.w)	condition: false!!
		bra.s	condit_next

condit_leave	bsr	gce		if not eol, error
		bcc.s	condit_sye
		move.w	cond_level(pc),d0
		beq.s	condit_interr	internal error, no active conditions
		subq.w	#1,d0		one step upwards
		beq.s	condit_ended	no more conditions in effect
		lea	condflags(pc),a0
		tst.b	0(a0,d0.w)
		bmi.s	condit_not_yet	still in FALSE block

condit_ended	move.w	d0,cond_level	turn on assembly
		bsr	listout
		rts

condit_not_yet	move.w	d0,cond_level	one step upwards
condit_next	bsr	listout
		bra	condit_on

condit_sye	error	#203		syntax error
		bra	condit_next
condit_interr	error	#512		ENDC without cond. Should never happen.
		rts
condit_end	error	#521		missing ENDC
		rts

mac_def		cmp.w	#-4,d1		macro definition?
		beq.s	mac_def_skip
		rts
mac_def_skip	bsr	seek_nexl
		move.l	txtptr(pc),a0
		tst.b	(a0)
		beq.s	mac_def_eop
		bsr	getlb
		move.l	a0,txtptr
		bsr	getmn
		cmp.l	#'ENDM',d0
		beq.s	mac_def_done
		bsr	listout
		addq.l	#1,linnum
		bra.s	mac_def_skip
mac_def_done	bsr	listout
		clr.w	incstrt
mac_def_eop	rts


;------------------------------------------------------------------------


PSD1		equ	'INCL'
PSD2		equ	'I'<<24+ID<<16+'ND'
PSD3		equ	'M'<<24+ID<<16+'CD'
PSD4		equ	'M'<<24+ID<<16+'CU'
PSD5		equ	'ENDM'

condit_ck_mi	push	d0-d1/a0-a1		prevents internal mnemonics
		cmp.l	#PSD1,d0		and line number incrementing
		beq.s	eudo_IBEG		in macros if false condition
		cmp.l	#PSD2,d0
		beq.s	eudo_IEND
		cmp.l	#PSD3,d0
		beq.s	eudo_MACS1
		cmp.l	#PSD4,d0
		beq.s	eudo_MACS2
		cmp.l	#PSD5,d0
		beq.s	eudo_ENDM		k f p w b t y?
condit_ck_ok	pull	d0-d1/a0-a1
		rts

eudo_IBEG	bsr	cg
		bsr	getmn
		cmp.l	#'LUDE',d0		check the rest of the mnemonic
		bne.s	condit_ck_ok
		move.w	#1,incstrt		flag: include file starts
		bra.s	condit_ck_ok


eudo_IEND	move.w	#1,no_list		don't write this line into listfile!
		bra.s	condit_ck_ok


eudo_MACS1	move.w	#-4,incstrt		flag: macro definition starts
		move.w	#1,no_list
		bra.s	condit_ck_ok


eudo_MACS2	move.w	#-1,incstrt		flag: macro expansion starts
		move.w	#1,no_list
		bra.s	condit_ck_ok


eudo_ENDM	clr.w	incstrt			reset macro flag
		move.w	#1,no_list		if macro usage, don't list!
		bra.s	condit_ck_ok




*************************************************************************
*									*
* Uses this to evaluate symbol values during pass1 and to store symbols	*
* in buffer.								*
*									*
*************************************************************************

slabel		push	all		save label in buffer
		bsr	gce		get char, check for line end
		bcs	slabel_okay	line end
		cmp.b	#'*',d0
		beq	slabel_star

		move.l	linstrt(pc),a0
		bsr	getlb
		bcs.s	slabel_err	illegal char
		bvs.s	slabel_err	too long name
		move.l	a0,txtptr

		moveq.l	#LABELSPC,d1	space needed for each symbol
		move.l	labelbuf(pc),a2	get buffer start addr
		move.l	a2,a3
		add.l	#LABELBUF-48,a3	end of buffer
slabel_seek	lea	tbuffer(pc),a1	symbol in program
		move.l	a2,a0		symbol in buffer
		tst.b	(a0)		no more labels in buffer?
		beq.s	slabel_ins	add new symbol here!
		bsr	strcmp		re-definition?
		beq.s	slabel_redef	yes, possible ermsg
		add.l	d1,a2		index to next symbol
		cmp.l	a3,a2		check if end of buffer
		blo.s	slabel_seek
		error	#301		out of symbol space
slabel_err	clr.w	sl_flag		not in slabel
		setc
		pull	all
		rts
slabel_redef	move.b	LINFO(a2),d0	get info byte
		btst	#0,d0		set by prgline? Then redefinition
		beq.s	slabel_noins	NOT allowed. Otherwise no need to insert name
		btst	#1,d0
		bne.s	slabel_noins	SET - no ermsg if redefined

slabel_re_err	error	#311		redefined
		bra.s	slabel_err
slabel_ins	move.l	a2,a1		copy name into buffer
		lea	tbuffer(pc),a0
		bsr	strcpy
		clr.b	LINFO(a2)	no flags set by default
slabel_noins	move.l	txtptr(pc),a5
		bsr	getmn		is it equ or set?
		bcs.s	slabel_nomnem	no mnemonic on this line
		beq.s	slabel_nomnem	no mnemonic on this line
		move.b	LINFO(a2),d2	Temporary LINFO for set/equ set here
		cmp.l	#'EQU',d0
		beq.s	slabel_iequ
		cmp.l	#'SET',d0
		beq.s	slabel_iset
slabel_nomnem	move.b	LINFO(a2),d0
		and.b	#%110,d0
		bne.s	slabel_eror1	set or equ used before -> error
		move.l	a5,txtptr
		move.l	prgc(pc),LVALUE(a2)
		bset	#0,LINFO(a2)	in prg: absolute value
		bra.s	slabel_okay	exit

slabel_iequ	bset	#2,d2		EQUted, temp flag because GLABEL still
		bra.s	slabel_ii	 needs LINFO
slabel_iset	bset	#1,d2		SET
slabel_ii	btst	#2,LINFO(a2)
		bne.s	slabel_eror2	equ used before
		bset	#0,d2		set as ABSOLUTE for a while...
		move.w	#1,sl_flag	flag for glabel: equ or set
		bsr	calc
		bcs	slabel_err
		bsr	ck_lim16
		bcc.s	slabel_inv
		move.l	d0,LVALUE(a2)	save value!
		tst.b	zpabs
		bne.s	slabel_equset
		bclr	#0,d2		... but reset if zp
slabel_equset	move.b	d2,LINFO(a2)	Set Real Label Info!
slabel_okay	clr.w	sl_flag		not in slabel
		pull	all
		rts

slabel_eror1	error	#361		illegal prg const
		bra	slabel_err
slabel_eror2	error	#351		EQU redefined
		bra	slabel_err
slabel_inv	error	#126		illegal value
		bra	slabel_err
slabel_pc_high	error	#292		pc > $ffff
		bra	slabel_err
slabel_sye	error	#204		syntax error
		bra	slabel_err
slabel_ste	error	#205		-  "  -
		bra	slabel_err
slabel_stnmn	error	#261		equ expected
		bra	slabel_err

slabel_star	bsr	getmn		must be 'equ'
		bcs	slabel_stnmn
		cmp.l	#'EQU',d0
		bne	slabel_ste
		move.w	#1,sl_flag	flag for glabel: equ or set
		bsr	calc
		bcs	slabel_err
		bsr	ck_lim16
		bcc	slabel_pc_high
		move.l	d0,prgc		set program counter
		bra	slabel_okay		



*************************************************************************
*									*
* Uses this to evaluate symbol values during pass2.			*
*									*
* Checks if non-equset values are same as during pass1.  Passes values	*
* to listing routines.							*
*									*
*************************************************************************

slabel2		push	all		uses this during pass #2
		bsr	gce		get char, check for line end
		bcs	slabel2_okay	line end
		cmp.b	#'*',d0
		beq	slabel2_star

		move.l	linstrt(pc),a0
		bsr	getlb
		move.l	a0,txtptr


; find old symbol, its value and LINFO:

		move.l	labelbuf(pc),a2
		moveq.l	#LABELSPC,d1	offset to next symbol
slabel2_seek	move.l	a2,a1		addr in symbol buffer
		lea	tbuffer(pc),a0	current name
		tst.b	(a1)		last label?
		beq	slabel2_nf	not found
		bsr	strcmp
		beq.s	slabel2_fnd	found
		add.l	d1,a2		get addr of next symbol in buffer
		bra.s	slabel2_seek

slabel2_fnd	move.b	LINFO(a2),d2	get old LINFO value for comparison
		move.l	LVALUE(a2),d3	get old LVALUE for comparison

		move.l	txtptr(pc),a5
		bsr	getmn		is it equ or set?
		bcs.s	slabel2_nomnem	no mnemonic on this line
		beq.s	slabel2_nomnem	no mnemonic on this line
		moveq.l	#0,d4		equset value for listing routines
		cmp.l	#'EQU',d0
		beq.s	slabel2_iequ
		cmp.l	#'SET',d0
		beq.s	slabel2_iset

slabel2_nomnem	move.l	a5,txtptr
		cmp.l	prgc(pc),d3	compare with old value
		bne.s	slabel2_a_mism	absolute address mismatch
		btst	#0,d2		check if absolute during pass1
		bne	slabel2_okay	if it was, then exit
slabel2_a_mism	move.w	absmism(pc),d0	print this message only once!
		bne	slabel2_err
		move.w	#1,absmism
		error	#381		abs addr mismatch
		bra.s	slabel2_err
slabel2_e_mism	error	#391		set/equ value mismatch
		bra.s	slabel2_err

slabel2_iequ	bset	#31,d4		needs the old value during calc()
		move.w	#1,sl_flag	flag for glabel: equ or set
		bsr	calc
		bcs.s	slabel2_err
		bsr	ck_lim16
		bcc	slabel_inv
		btst	#1,d2
		bne.s	slabel2_set_va	write pass2 value to SET symbols
		bra.s	slabel2_va_ck	check values

slabel2_iset	bset	#30,d4		equset may never be zero after EQU/SET
		move.w	#1,sl_flag	flag for glabel: equ or set
		bsr	calc
		bcs.s	slabel2_err
		bsr	ck_lim16
		bcc	slabel_inv
slabel2_set_va	move.l	d0,d3		use pass2 value for SET symbols
		move.l	d0,LVALUE(a2)	update SET value in pass2, too

slabel2_va_ck	cmp.l	d0,d3		compare pass1 and pass2 values
		bne	slabel2_e_mism	 if <> -> error
		move.w	d3,d4		correct value for listing routines
		move.l	d4,equset	Pass the LVALUE and flags to lst rtns
slabel2_okay	clr.w	sl_flag		not in slabel2
		pull	all
		rts

slabel2_nf	error	#342		symbol not found in buffer
slabel2_err	clr.w	sl_flag		not in slabel2
		setc
		pull	all
		rts

slabel2_star	bsr	getmn		must be 'equ'
		move.w	#1,sl_flag	flag for glabel: equ or set
		bsr	calc
		bcs	slabel2_err
		bsr	ck_lim16
		bcc	slabel_pc_high
		move.l	d0,prgc		set program counter
		move.l	#$c0000000,d2
		move.w	d0,d2
		move.l	d2,equset
		bra	slabel2_okay



*************************************************************************
*									*
* Finds a symbol in buffer and get its value & zpabs.			*
*									*
*************************************************************************

glabel		push	d1-d2/a0-a2
		bsr	gce		is it '* + sth'?
		bcs	glabel_nam_miss	line end = error
		cmp.b	#'*',d0
		beq	glabel_star

		move.l	txtptr(pc),a0
		subq.l	#1,a0
		bsr	getlb
		bcs	glabel_nam_ierr	if not a legal label
		bvs	glabel_err	if name too long
		move.l	a0,txtptr

glabel_copied	move.l	labelbuf(pc),a2
		moveq.l	#LABELSPC,d1	offset to next symbol
glabel_seek	move.l	a2,a1		addr in symbol buffer
		lea	tbuffer(pc),a0	current name
		tst.b	(a1)		last label?
		beq.s	glabel_nf	not found
		bsr	strcmp
		beq.s	glabel_fnd	found
		add.l	d1,a2		get addr of next symbol in buffer
		bra.s	glabel_seek
glabel_nf	move.b	#1,zpabs	not zero page
		move.w	#1,lnf		label not found for ifd/ifnd
		moveq.l	#0,d0		return value zero
		move.w	sl_flag(pc),d1	if from slabel, must print error always
		bmi.s	glabel_ok	if from ifd/ifnd, never complain!
		bne.s	glabel_nf_e
		cmp.b	#1,pass		if pass#1, no error
		beq.s	glabel_ok
glabel_nf_e	error	#341		unknown symbol
		bra.s	glabel_err
glabel_fnd	move.l	LVALUE(a2),d0	get symbol value
		move.b	LINFO(a2),d1	get info
		and.b	#1,d1		only zpabs
		or.b	d1,zpabs
		cmp.b	#1,pass		if pass#1, don't increment lusage
		beq.s	glabel_ok
		addq.l	#1,LUSAGE(a2)
glabel_ok	clrc
		pull	d1-d2/a0-a2
		rts

glabel_nam_miss	error	#371
		bra.s	glabel_err
glabel_nam_ierr	error	#321
glabel_err	pull	d1-d2/a0-a2
		setc
		rts

glabel_star	move.l	prgc(pc),d0	current pc
		or.b	#1,zpabs
		bra	glabel_ok



*************************************************************************
*									*
* Print all symbol values in alphabetical order along their values.	*
* If listmode then print to listfile, too.				*
*									*
*************************************************************************

dumplabels	tst.w	symbolmode
		bne.s	dumplabels_y
		rts
dumplabels_y	push	all
		move.w	#100,prtline		change page!
		bsr	header
		printa	#DUMPL_HD
dumpl_hd	move.w	listmode(pc),d0
		beq.s	dumpl_loop
		printa	#DUMPL_HD,listfile(pc)
dumpl_loop	bsr	ck_stop			check if panic!
		bne.s	dumpl_exit
		move.l	libuf(pc),a1		write ptr
		move.l	a1,a2
		bsr	dump_one
		beq.s	dumpl_exit
		add.l	#17,a2
		bsr	fill_spc
		bsr	dump_one
		move.b	#LF,(a1)+
		clr.b	(a1)
		printa	libuf(pc)
		move.w	listmode(pc),d0
		beq.s	dumpl_nolist
		printa	libuf(pc),listfile(pc)
dumpl_nolist	bsr	header
		tst.w	prtline
		beq	dumpl_hd
		bra.s	dumpl_loop

dumpl_exit	pull	all
		rts

DUMPL_HD	dc.b	LF,'symbol_name      value type usage'
		dc.b	'           symbol_name      value type usage'
		dc.b	LF,0
		cnop	0,4


dump_one	bsr.s	next_lab		find smallest name
		beq.s	dump_onex
		move.l	a0,a3			save name ptr
		add.l	#17,a2
		bsr	strcpy			symbol name
		subq.l	#1,a1
		bsr	fill_spc
		move.l	LVALUE(a3),d0
		bsr	sign_16
		lea	buf_16+3(pc),a0
		bsr	strcpy			value
		moveq.l	#' ',d0
		move.b	d0,-1(a1)
		move.b	d0,(a1)+
		move.b	d0,(a1)+
		move.b	d0,(a1)+
		move.b	d0,(a1)+
		move.b	LINFO(a3),d0		info
		btst	#0,d0			zpabs
		bne.s	dumpo_nz
		move.b	#'z',-3(a1)		zero page
dumpo_nz	btst	#1,d0			set
		beq.s	dumpo_ns
		move.b	#'s',-1(a1)
dumpo_ns	btst	#2,d0			equ
		beq.s	dumpo_ne
		move.b	#'e',-2(a1)
dumpo_ne	add.l	#10,a2
		move.l	LUSAGE(a3),d0
		clrc
		bsr	conv_10
		lea	buf_10+6(pc),a0
		bsr	strcpy			usage
		subq.l	#1,a1
		moveq.l	#1,d0			clr z-flag
dump_onex	rts


next_lab	push	d0-d1/a1-a3
		move.l	labelbuf(pc),a2
		lea	VeryBIG(pc),a3		The biggest string in the world!
		moveq.l	#0,d1			d1 is flag: smaller found
		bra.s	next_lab1

next_lab_next	add.l	#LABELSPC,a2
next_lab1	move.l	a2,a0			labelbufptr
		move.l	a3,a1			smallestptr
		tst.b	(a0)
		beq.s	next_lext
		tst.b	LINFO(a0)
		bmi.s	next_lab_next
		bsr	strcmp
		tst.b	d0
		bpl.s	next_lab_next
		move.l	a2,a3			smaller found
		moveq.l	#1,d1			set flag
		bra.s	next_lab_next

next_lext	tst.l	d1			eq if no labels left
		beq.s	next_lexit		do NOT set LINFO of VeryBIG!!!
		move.l	a3,a0
		bset	#7,LINFO(a0)		this label used
next_lexit	tst.l	d1			eq if no labels left
		pull	d0-d1/a1-a3
		rts

VeryBIG		dc.w	$ffff,0


fill_spc	move.b	#' ',(a1)+
		cmp.l	a2,a1
		blo.s	fill_spc
		rts


header		tst.w	listmode
		beq.s	header_ex
		push	all
		move.w	prtline(pc),d0
		cmp.w	maxline(pc),d0
		bhi.s	header_new_pg
		addq.l	#1,d0
		move.w	d0,prtline
		pull	all
header_ex	rts
header_new_pg	move.w	prtpage(pc),d0		if first page, no FF
		beq.s	header_new
		lea	FFPAGEMSG(pc),a2
header_new_ex	addq.l	#1,d0
		move.w	d0,prtpage
		clr.w	prtline
		moveq.l	#0,d0
		move.w	prtpage(pc),d0
		clrc
		bsr	conv_10
		lea	buf_10+7(pc),a0
		lea	PAGENUM(pc),a1
		bsr	copy_10
		printa	a2,listfile(pc)
		pull	all
		rts
header_new	lea	PAGEMSG(pc),a2
		bra.s	header_new_ex

FFPAGEMSG	dc.b	FF
PAGEMSG		dc.b	' 65c02 Cross Assembler '
		VERSION
		dc.b	'  (c) J. & T. Marin 1988 '
PAGENULL	dc.b	0,'                --  Page #'
PAGENUM		dc.b	'     '
		dc.b	'  --',LF,LF,0
		cnop	0,4



*************************************************************************
*									*
* Resolve mnemonic and addressing mode.  Calls PSEUDOS to handle pseudo	*
* mnemonics.								*
*									*
*************************************************************************

seek_op		push	d1-d7/a0-a1		search for op codes
		lea	OpCodes(pc),a0		addr of table
		moveq.l	#Op_Codes-OpCodes,d2	bytes betw. mnemonics in table
		bsr	getmn
		beq	seek_end	line end gives zero bytes
		bcs	seek_op_e1
		move.l	d0,d1
seek_m_ok	move.l	(a0),d0		here d1/d0 contain current mnemonic
		beq	seek_nf		not found
		cmp.l	d1,d0
		beq.s	seek_found
		add.l	d2,a0		index to next entry in table
		bra.s	seek_m_ok	continue search
seek_found	clrx			not jmp-processing
		bsr	amode		resolve addressing mode (d0)
		bcs	seek_op_er
		move.b	4(a0,d0),d1	fetch opcode
		beq.s	seek_op_rel	if null, is it relative then? Or zp,y?
		moveq.l	#0,d2
		lea	OpLen(pc),a1
		move.b	0(a1,d0),d2	fetch byte#
		bra.s	seek_rdy

seek_op_rel	cmp.b	#ABS,d0		check if absolute (it could be relative)
		bne	seek_op_zpy	no, not abs/rel. Is it zp,y?
		move.b	4+REL(a0),d1	get relative opcode
		beq	seek_op_ae	if it's null, relative not available
		moveq.l	#2,d2		length is 2 bytes for rel
		cmp.b	#1,pass		don't test offset during pass#1
		beq.s	seek_rdy
		move.l	par1(pc),d3	get dest addr
		sub.l	prgc(pc),d3	substract current addr
		subq.l	#2,d3
		cmp.l	#-128,d3
		blt	seek_op_rele	offset too small
		cmp.l	#127,d3
		bgt	seek_op_rele	offset too large
		move.l	d3,par1		store actual parameter or offset
seek_rdy	moveq.l	#0,d3		calc index/bit into 65c02 check list
		move.b	d1,d3		opcode into d3
		move.l	d3,d4		and d4
		and.b	#15,d4
		eor.b	#15,d4		d4 = bit#
		lsr.b	#3,d3		d3 = index
		and.b	#%11111110,d3	address must be even
		lea	CPU(pc),a1
		move.w	0(a1,d3),d3
		btst	d4,d3
		beq.s	seek_write
		move.w	procmode(pc),d0	if CMOS mode, no error
		bne.s	seek_write
		error	#231		65c02 only
seek_write	move.l	par1(pc),d3	get possible parameter
		cmp.b	#1,pass
		beq.s	seek_done
		moveq.l	#0,d7
		move.b	d1,d7
		bsr	output		sends opcode
		cmp.b	#1,d2
		beq.s	seek_done
		move.b	d3,d7
		bsr	output		sends first param byte
		cmp.b	#2,d2
		beq.s	seek_done
		lsr.l	#8,d3
		move.b	d3,d7
		bsr	output		sends second param byte

seek_done	move.l	d2,d0		length
		clrc
		pull	d1-d7/a0-a1
		rts
seek_end	moveq.l	#0,d2		length zero
		bra	seek_done
seek_op_e1	error	#206		syntax error
		bra.s	seek_op_er
seek_op_e2	error	#207		syntax error
		bra.s	seek_op_er
seek_op_e3	error	#208		syntax error
seek_op_er	pull	d1-d7/a0-a1
		moveq.l	#0,d0		destination length: zero
		setc
		rts
seek_op_ae	error	#211		unknown addressing mode
		bra	seek_op_er
seek_op_zp	error	#221		zp expected
		bra	seek_op_er
seek_op_ie	error	#251		illegal addressing mode
		bra	seek_op_er
seek_op_rele	error	#241		offset too large
		bra	seek_op_er

seek_op_zpy	cmp.b	#ZPY,d0		if zpy, replace with abs,y
		bne	seek_op_ae
		move.b	4+ABSY(a0),d1	get abs,y opcode
		beq	seek_op_ae	if it's null, abs,y not available
		moveq.l	#3,d2		length is 3 bytes for abs,y
		bra	seek_rdy

seek_nf		move.l	d1,d7		preserve current mnemonic
		cmp.l	#'BRK',d1
		bne.s	seek_cJMP
		clrx			not jmp-processing
		bsr	amode
		bcs	seek_op_er
		cmp.b	#IMP,d0		BRK is always implied!
		bne	seek_op_ie
		moveq.l	#0,d1
		moveq.l	#1,d2		length
		bra	seek_write	d1 = opcode

seek_cJMP	cmp.l	#'JMP',d1
		bne.s	seek_cBBR
		setx			now processing a jmp instruction
		bsr	amode
		bcs	seek_op_er
		lea	OpJMP(pc),a1
		move.b	0(a1,d0),d1	fetch opcode
		beq	seek_op_ae	illegal addr mode
		moveq.l	#3,d2		length
		bra	seek_rdy

seek_cBBR	cmp.l	#'BBR',d1
		beq.s	seek_yBBR
		cmp.l	#'BBS',d1
		bne	seek_cRMB
		bsr	ck_ibit		check if immediate bit number
		bcc	seek_op_e2	sye
		move.l	d0,d1		bit#
		asl.b	#4,d1		into upper nybble
		or.b	#%10001111,d1	set opcode to $8f+bit
		bra.s	seek_yBBx
seek_yBBR	bsr	ck_ibit		check if immediate bit number
		bcc	seek_op_e2	sye
		move.l	d0,d1		bit#
		asl.b	#4,d1		into upper nybble
		or.b	#%00001111,d1	set opcode to $0f+bit
seek_yBBx	bsr	calc
		bcs	seek_op_er
		tst.b	zpabs		must be zero page
		bne	seek_op_zp
		move.l	d0,d3		mem loc addr into d3
		bsr	gc
		cmp.b	#',',d0
		bne	seek_op_e2
		bsr	calc		get dest addr
		bcs	seek_op_er
		moveq.l	#3,d2		length is 3 bytes for these
		cmp.b	#1,pass		don't test offset during pass#1
		beq	seek_rdy
		sub.l	prgc(pc),d0	subtract current addr
		subq.l	#3,d0
		cmp.l	#-128,d0
		blt	seek_op_rele	offset too small
		cmp.l	#127,d0
		bgt	seek_op_rele	offset too large
		asl.l	#8,d0		make space for mem loc addr
		or.b	d3,d0
		move.l	d0,par1		store actual parameter or offset
		moveq.l	#3,d2		length
		bra	seek_rdy	d1 contains opcode

seek_cRMB	cmp.l	#'RMB',d1
		beq.s	seek_yRMB
		cmp.l	#'SMB',d1
		bne.s	seek_PSEUDOS
		bsr	ck_ibit
		bcc	seek_op_e3	get bit#
		move.l	d0,d1
		asl.b	#4,d1		shift bit#
		or.b	#%10000111,d1	convert to opcode
		bra.s	seek_yxMB
seek_yRMB	bsr	ck_ibit
		bcc	seek_op_e3	get bit#
		move.l	d0,d1
		asl.b	#4,d1		shift bit# into right place
		or.b	#%00000111,d1	make it an opcode
seek_yxMB	bsr	calc		get addr for SMB/RMB
		bcs	seek_op_er
		tst.b	zpabs		must be on zp
		bne	seek_op_zp
		move.l	d0,par1		store it
		moveq.l	#2,d2		length
		bra	seek_rdy	d1 = opcode

seek_PSEUDOS	moveq.l	#0,d2		length: null
		lea	PSEUDOS(pc),a0	table
seek_PS_lp	move.l	(a0)+,d0
		beq.s	seek_PS_err
		cmp.l	d0,d1
		beq.s	seek_PS_found
		addq.l	#4,a0		skip address
		bra.s	seek_PS_lp

seek_PS_found	move.l	(a0),a0		get jump address
		jmp	(a0)

seek_PS_err	error	#271		unknown mnemonic
		setc
		bra	seek_op_er

PSEUDOS		dc.l	'DB',DB_main_loop
		dc.l	'DW',DW_loop
		dc.l	'DL',DL_loop
		dc.l	'MODE',MODE_loop
		dc.l	'INCL',pseudo_IBEG

		dc.b	'I',ID,'ND'
		dc.l	pseudo_IEND

		dc.l	'IFEQ',pseudo_IFEQ
		dc.l	'IFNE',pseudo_IFNE
		dc.l	'IFGT',pseudo_IFGT
		dc.l	'IFLT',pseudo_IFLT
		dc.l	'IFGE',pseudo_IFGE
		dc.l	'IFLE',pseudo_IFLE
		dc.l	'IFD',pseudo_IFD
		dc.l	'IFND',pseudo_IFND
		dc.l	'IFC',pseudo_IFC
		dc.l	'IFNC',pseudo_IFNC
		dc.l	'IFI',pseudo_IFI
		dc.l	'IFNI',pseudo_IFNI
		dc.l	'ENDC',pseudo_ENDC
		dc.l	'FAIL',pseudo_FAIL
		dc.l	'PAGE',pseudo_PAGE

		dc.b	'M',ID,'CD'
		dc.l	pseudo_MACS1

		dc.b	'M',ID,'CU'
		dc.l	pseudo_MACS2

		dc.l	'ENDM',pseudo_ENDM
		dc.l	0,0




DB_main_loop	bsr	gce		define 8-bit values
		bcs	DB_serr
		cmp.b	#39,d0
		bne.s	DB_nquo
DB_quotes	bsr	chr
		cmp.b	#39,d0
		beq.s	DB_double
		bsr	ck_eol
		bvs.s	DB_qerr		line end before closing '
		move.b	d0,d7
		bsr	output
		addq.l	#1,d2
		bra	DB_quotes
DB_double	move.l	txtptr(pc),a0	''?
		cmp.b	#39,(a0)
		bne.s	DB_comma
		moveq.l	#39,d7
		bsr	output
		addq.l	#1,d2
		bsr	chr
		bra	DB_quotes
DB_nquo		bsr	cg		txtptr--
		bsr	calc
		bcs.s	DB_err		calc error
		bsr	ck_lim8
		bcc.s	DB_ierr		illegal value
		move.b	d0,d7
		bsr	output
		addq.l	#1,d2
DB_comma	bsr	gce
		bcs.s	DB_ok
		cmp.b	#',',d0
		bne.s	DB_serr		syntax
		bra	DB_main_loop
DB_ierr		error	#223
		bra.s	DB_err
DB_qerr		error	#151		quotes upset
		bra.s	DB_err
DB_serr		error	#209
DB_err		setc
		bra	seek_op_er
DB_ok0		moveq.l	#0,d2		Produce ZERO bytes of code!!!
DB_ok		bra	seek_done	normally bytecount in d2.


DW_loop		bsr	gce
		bcs	DB_serr
		bsr	cg
		bsr	calc
		bcs	DB_err
		bsr	ck_lim16
		bcc.s	DW_ierr
		move.l	d0,d7
		bsr	output
		lsr.w	#8,d7
		bsr	output
		addq.l	#2,d2
		bsr	gce
		bcs	DB_ok
		cmp.b	#',',d0
		beq	DW_loop
		bra	DB_serr
DW_ierr		error	#128
		bra	DB_err


DL_loop		bsr	gce
		bcs	DB_serr
		bsr	cg
		bsr	calc
		bcs	DB_err
		move.l	d0,d7
		bsr	output
		lsr.l	#8,d7
		bsr	output
		lsr.l	#8,d7
		bsr	output
		lsr.l	#8,d7
		bsr	output
		addq.l	#4,d2
		bsr	gce
		bcs	DB_ok
		cmp.b	#',',d0
		beq	DL_loop
		bra	DB_serr


MODE_loop	bsr	gce
		bcs	DB_ok0
		move.l	d0,d1
		lsr.l	#5,d1
		eor.b	#1,d1
		and.b	#1,d1		d1 = flag: 0=off, 1=on
		bsr	ucase
		cmp.b	#'C',d0		CMOS
		bne.s	MODE_1
		move.w	d1,procmode
		bra	MODE_loop
MODE_1		cmp.b	#'L',d0		LIST
		bne.s	MODE_2
		move.w	d1,no_list	don't write MODE l/L cmds into listfile
		beq.s	MODE_1a
		move.w	userlmode(pc),d1 get cmdline option value
		move.w	d1,listmode	turn on listing if -l option was used
		bsr	Open_list	open listfile if necessary
		bcs	seek_op_er
		bra	MODE_loop
MODE_1a		clr.w	listmode	turn off listing in any case
		bra	MODE_loop
MODE_2		cmp.b	#'S',d0		SYMBOL TABLE
		bne.s	MODE_3
		move.w	d1,symbolmode
		bra	MODE_loop
MODE_3		cmp.b	#'H',d0		HEX
		bne.s	MODE_4
		move.w	d1,hexmode
		bra	MODE_loop
MODE_4		bra	DB_serr



pseudo_IBEG	bsr	cg
		bsr	getmn
		cmp.l	#'LUDE',d0		check the rest of the mnemonic
		bne	seek_PS_err
		bsr	gc			skip '
		move.w	idepth(pc),d0		current nesting level
		add.w	d0,d0
		add.w	d0,d0			compute index into nameptr table
		lea	incnames(pc),a0		nameptr table
		move.l	nameptr(pc),0(a0,d0.w)	save current name
		move.l	txtptr(pc),nameptr	ptr to new name
		move.w	#1,incstrt		flag: include file starts
IBEG_skip	bsr	gce
		bcc	IBEG_skip
		bra	DB_ok0


pseudo_IEND	bsr	calc
		bcs.s	IEND_err
		move.l	d0,linnum	set linenumber for this file
		move.w	#1,no_list	don't write this line into listfile!
		move.w	idepth(pc),d0
		subq.w	#1,d0		stop processing this include file
		bpl.s	IEND_ok
IEND_err	error	#461
		bra	DB_err
IEND_ok		move.w	d0,idepth	save new depth
		add.w	d0,d0
		add.w	d0,d0
		lea	incnames(pc),a0
		move.l	0(a0,d0.w),nameptr	restore previous name
		bra	DB_ok0


pseudo_MACS1	move.w	#-4,incstrt		flag: macro definition starts
		move.w	#1,no_list
		bra	DB_ok0


pseudo_MACS2	move.w	#-1,incstrt		flag: macro expansion starts
		move.w	#1,no_list
		bra	DB_ok0


pseudo_ENDM	move.w	incstrt(pc),d0		if no macro, error!
		bpl.s	ENDM_err
		clr.w	incstrt			reset macro flag
		move.w	#1,no_list		if macro usage, don't list!
		bra	DB_ok0
ENDM_err	error	#601
		bra	DB_err


pseudo_PAGE	move.w	#HUGELINE,prtline	forced FF
		bra	DB_err


pseudo_IFEQ	move.w	cond_level(pc),d1	depth of conditions (norm. 0)
		bsr	calc
		bcs	DB_err
		tst.l	d0
		bne.s	COND_n
COND_y		addq.w	#1,d1			increase depth
		cmp.w	#CONDNESTING,d1
		bge.s	IFEQ_err		too deep
		move.w	#1,condstrt		new cond. part begins: true

		lea	condflags(pc),a0
		move.b	#1,0(a0,d1.w)		condition TRUE
		bra.s	IFEQ_ok

COND_n		addq.w	#1,d1			increase depth
		cmp.w	#CONDNESTING,d1
		bge.s	IFEQ_err		too deep
		move.w	#-1,condstrt		new cond. part begins: false

		lea	condflags(pc),a0	stop assembly, because
		move.b	#-1,0(a0,d1.w)		condition FALSE

IFEQ_ok		move.w	d1,cond_level		update depth
		bra	DB_ok0
IFEQ_err	error	#501
		bra	DB_err

pseudo_IFNE	move.w	cond_level(pc),d1
		bsr	calc
		bcs	DB_err
		tst.l	d0
		bne	COND_y
		bra	COND_n

pseudo_IFGT	move.w	cond_level(pc),d1
		bsr	calc
		bcs	DB_err
		cmp.l	#0,d0
		bgt	COND_y
		bra	COND_n

pseudo_IFLT	move.w	cond_level(pc),d1
		bsr	calc
		bcs	DB_err
		cmp.l	#0,d0
		blt	COND_y
		bra	COND_n

pseudo_IFGE	move.w	cond_level(pc),d1
		bsr	calc
		bcs	DB_err
		cmp.l	#0,d0
		bge	COND_y
		bra	COND_n

pseudo_IFLE	move.w	cond_level(pc),d1
		bsr	calc
		bcs	DB_err
		cmp.l	#0,d0
		ble	COND_y
		bra	COND_n

pseudo_IFD	move.w	cond_level(pc),d1
		clr.w	lnf
		move.w	#-1,sl_flag		prevents error msg if symbol
		bsr	glabel			not defined
		clr.w	sl_flag
		move.w	lnf(pc),d0		equ: defined
		beq	COND_y
		bra	COND_n

pseudo_IFND	move.w	cond_level(pc),d1
		clr.w	lnf
		move.w	#-1,sl_flag		prevents error msg if symbol
		bsr	glabel			  not defined
		clr.w	sl_flag
		move.w	lnf(pc),d0		equ: defined
		bne	COND_y
		bra	COND_n


pseudo_IFC	move.w	cond_level(pc),d1
		bsr	ck_ifc			compare strings
		bcs	DB_err
		beq	COND_y
		bra	COND_n

pseudo_IFNC	move.w	cond_level(pc),d1
		bsr	ck_ifc			compare strings
		bcs	DB_err
		bne	COND_y
		bra	COND_n


pseudo_IFI	move.w	cond_level(pc),d1
		bsr	ck_ifi			INSTR strings (sub, main)
		bcs	DB_err
		beq	COND_y
		bra	COND_n

pseudo_IFNI	move.w	cond_level(pc),d1
		bsr	ck_ifi			INSTR strings
		bcs	DB_err
		bne	COND_y
		bra	COND_n


pseudo_ENDC	move.w	cond_level(pc),d0	if no cond active, error
		beq.s	ENDC_err
		subq.w	#1,d0			just decrement level
		move.w	d0,cond_level
		bra	DB_ok0
ENDC_err	error	#511			no condition
		bra	DB_err


pseudo_FAIL	error	#541			fail error
		bra	DB_err




getmode		push	d1
		moveq.l	#0,d0
		tst.w	idepth		into bit 4
		sne.b	d1
		lsr.b	#1,d1
		roxl.b	#1,d0

		tst.w	listmode	into bit 3
		sne.b	d1
		lsr.b	#1,d1
		roxl.b	#1,d0

		tst.w	symbolmode	into bit 2
		sne.b	d1
		lsr.b	#1,d1
		roxl.b	#1,d0

		tst.w	hexmode		into bit 1
		sne.b	d1
		lsr.b	#1,d1
		roxl.b	#1,d0

		tst.w	procmode	into bit 0
		sne.b	d1
		lsr.b	#1,d1
		roxl.b	#1,d0

		pull	d1
		rts


amode		push	d1-d4/a5
		moveq.l	#0,d4
		roxl.b	#1,d4		x->d4[0] flag: processing jmp
		move.l	txtptr(pc),a5	save txtptr
		bsr	gce		if no params, implied
		bcs	amode_imp	implied

		bsr	ucase
		cmp.b	#'A',d0
		bne.s	amode10
		bsr	gce		if a plain a, accum
		bcs	amode_acc	accum

amode10		move.l	a5,txtptr	back to start
		bsr	gc
		cmp.b	#'#',d0
		bne.s	amode11
		bsr	calc
		bcs	amodee
		move.l	d0,par1
		bsr	ck_lim8
		bcc	amodezpe
		bra	amode_imm	immediate if -129<value<256
amode11		cmp.b	#'(',d0
		bne	amode20		not indirect
		bsr	calc
		bcs.s	amodee		error?
		bsr	ck_lim16
		bcc	amodeabe
		move.l	d0,par1
		bsr	gc
		cmp.b	#')',d0
		beq.s	amode14		(ind) or (ind),y
		cmp.b	#',',d0
		bne.s	amodesye	syntax error
		bsr	gc
		bsr	ucase
		cmp.b	#'X',d0
		bne.s	amodesye
		bsr	gc
		cmp.b	#')',d0
		bne.s	amodesye
		tst.b	d4
		bne	amode_indx	if jmp (ind,x), absolute allowed
		tst.b	zpabs
		bne.s	amodezpe
		bra	amode_indx	(ind,x)

amode14		bsr	gce
		bcs.s	amode16		(ind) or (abs ind)
		cmp.b	#',',d0
		bne.s	amodesye
		bsr	gce
		bsr	ucase
		cmp.b	#'Y',d0
		beq.s	amode15
amodesye	error	#212		syntax terror
amodee		setc
		pull	d1-d4/a5
		rts
amodezpe	error	#222		zero page expected
		bra	amodee
amodeabe	error	#281
		bra	amodee

amode15		tst.b	zpabs		zero page?
		bne	amodezpe	if not, error
		bra	amode_indy	(ind),y

amode16		tst.b	zpabs		(ind) and (abs ind) processed here
		beq.s	amode_ind
		tst.b	d4
		bne.s	amode_ind	if jmp (ind), absolute allowed
		bra	amodezpe	otherwise must be zero page

amode20		move.l	a5,txtptr	not indirect or immediate, nor implied
		bsr	calc
		bcs	amodee		if calc error
		bsr	ck_lim16
		bcc	amodeabe
		move.l	d0,par1
		bsr	gce
		bcs.s	amode24		abs or zp
		cmp.b	#',',d0
		bne	amodesye
		bsr	gc
		bsr	ucase
		cmp.b	#'X',d0
		beq.s	amode26		abs,x or zp,x

		cmp.b	#'Y',d0
		bne	amodesye
		tst.b	zpabs
		beq.s	amode_zpy	zp,y
amode_absy	moveq.l	#ABSY,d0	abs,y
		bra.s	amodex
amode_zpy	moveq.l	#ZPY,d0
		bra.s	amodex

amode24		tst.b	zpabs
		beq.s	amode_zp	zp
amode_abs	moveq.l	#ABS,d0		abs
		bra.s	amodex
amode_zp	moveq.l	#ZP,d0
		bra.s	amodex

amode26		tst.b	zpabs
		beq.s	amode_zpx	zp,x
amode_absx	moveq.l	#ABSX,d0	abs,x
		bra.s	amodex
amode_zpx	moveq.l	#ZPX,d0
		bra.s	amodex

amode_ind	moveq.l	#IND,d0
		bra.s	amodex
amode_indx	moveq.l	#INDX,d0
		bra.s	amodex
amode_indy	moveq.l	#INDY,d0	
		bra.s	amodex

amode_imp	moveq.l	#IMP,d0
		bra.s	amodex
amode_acc	moveq.l	#ACC,d0
		bra.s	amodex
amode_imm	moveq.l	#IMM,d0

amodex		clrc
		pull	d1-d4/a5
		rts


getmn		push	d1		get mnemonic at (txtptr) into d0
		moveq.l	#0,d1		temp storage d1
		bsr	gce		get first char
		bcs.s	seek_mn_ok	line end causes no error
		bsr	ucase		convert to upper case
		bsr	ck_ap
		bcc.s	seek_mn_e	illegal char .c=0 if not alpha
		move.b	d0,d1
		bsr	gec		second char
		cmp.b	#ID,d0
		beq.s	getmn_id	identifier for internal reserved mns
		bsr	ucase
		bsr	ck_ap
		bcc.s	seek_mn_e
getmn_id	asl.l	#8,d1
		move.b	d0,d1
		bsr	gec		third char
		bsr	ucase
		bsr	ck_ap
		bcc.s	seek_mn_ok	mnemonic ready
		asl.l	#8,d1
		move.b	d0,d1
		bsr	gec		fourth char
		bsr	ucase
		bsr	ck_ap
		bcc.s	seek_mn_ok	mnemonic ready
		asl.l	#8,d1
		move.b	d0,d1
		bra.s	seek_mn_rdy
seek_mn_ok	bsr	cg
seek_mn_rdy	clrc
		move.l	d1,d0		result into d0
		pull	d1
		tst.l	d0
		rts
seek_mn_e	bsr	cg
		pull	d1
		setc
		rts



*************************************************************************
*									*
* Loads in the files and calculates total length.			*
*									*
* a0 points to filename							*
* a1 points to sourcebuf (file is written there)			*
*    If a1=0, just checks total length of files.			*
*    Result in total_len.						*
* d7 holds the including depth.						*
*									*
*************************************************************************

MainLoad	push	d0-d7/a2-a6	save regs
		moveq.l	#0,d5
		move.l	d5,a5		no mem reserved
		move.l	d5,d6		no file opened
		move.l	a1,a4		writeptr
		move.l	txtptr(pc),a3	save txtptr
		move.l	a0,d1		nameptr
		move.l	a0,d3		save nameptr, use still prev. name
		move.l	#1005,d2	mode_oldfile
		lib	Dos,Open
		move.l	d0,d6		fileptr
		beq	ML_not_found

		move.l	d3,nameptr	set new nameptr for error()

		move.l	d6,d1		fileptr
		moveq.l	#0,d2		pos
		moveq.l	#1,d3		mode=end
		lib	Dos,Seek	seek for end of file

		move.l	d6,d1		file
		moveq.l	#0,d2		pos
		moveq.l	#-1,d3		mode=beg
		lib	Dos,Seek	seek for beginning
		move.l	d0,d5		bytes needed for buffer
		bne.s	ML_Fok
		move.l	d6,d1		if file is empty
		lib	Dos,Close
		bra	ML_exit

ML_Fok		add.l	d5,total_len	add to total source length
		move.l	d5,d0		allocate buffer
		addq.l	#4,d0
		move.l	#MEMF_PUBLIC,d1	no need for MEMF_CLR
		lib	Exec,AllocMem
		move.l	d0,a5		buffer addr
		tst.l	d0
		beq	ML_oom		out of memory

		move.l	d6,d1		fileptr
		move.l	a5,d2		buffer
		move.l	d5,d3		length
		lib	Dos,Read
		cmp.l	d0,d3
		bne	ML_read_er
		clr.b	0(a5,d0.l)	add null

		move.l	d6,d1		close file
		lib	Dos,Close
		moveq.l	#0,d6

		move.l	a5,txtptr	set txtptr to beg of buffer
		move.l	a5,linstrt
		clr.l	linnum		reset linenumber

ML_line		bsr	ck_stop		check if CTRL_C
		bne	ML_error	 yes, exit immediately!
		move.l	txtptr(pc),a0	start addr of line into a0
		move.b	(a0),d0
		beq	ML_exit
		bsr	ck_blk
		bcc	ML_copy		if not blank, copy line
		bsr	getmn
		bcs	ML_copy		if not a mnemonic, copy line
		cmp.l	#'INCL',d0
		bne	ML_copy
		bsr	cg
		bsr	getmn
		cmp.l	#'LUDE',d0
		bne	ML_copy
ML_seek_fq	bsr	gce		seek for a '
		bcs	ML_sye
		cmp.b	#39,d0
		bne	ML_sye
		move.l	txtptr(pc),a2	a2 is a filename ptr
ML_seek_sq	bsr	gece		seek for another '
		bcs	ML_sye
		cmp.b	#39,d0
		bne	ML_seek_sq

ML_send		move.l	a4,d1
		beq.s	ML_no_send	just checking file length
ML_send_loop	move.b	(a0)+,d0	copy INCLUDE-line
		bsr	ck_eol
		bvs.s	ML_send_end
		move.b	d0,(a4)+
		bra	ML_send_loop
ML_send_end	move.b	#LF,(a4)+

ML_no_send	move.l	txtptr(pc),a0	ptr to end of filename'+1
		clr.b	-1(a0)		add null to filename in buffer
		bsr	seek_nexl	find end of line

		move.l	a2,a0		nameptr
		addq.l	#1,d7		increment depth
		cmp.w	#INCNESTING,d7	check depth
		bhi	ML_neste	too deep
		move.l	a4,a1		writeptr
		move.l	linnum(pc),d2	save linnum
		move.l	a2,linstrt	filename for the case it's not found

		bsr	MainLoad	gosub next level
		bcs	ML_error

		move.l	a1,a4		update writeptr
		move.l	d2,linnum	restore linenumber
		move.l	a4,d0
		beq	ML_line		if writeptr=0, do not send anything
		move.l	d2,d0
		clrc
		bsr	conv_10
		lea	buf_10+6(pc),a0	write current linenumber
		lea	ML_LINE(pc),a1
		bsr	copy_10
		lea	ML_PRUW(pc),a0
		bsr.s	ML_write	send 'PRUW linnum' (end of this include)
		bra	ML_line

ML_write	move.b	(a0)+,d0
		beq.s	ML_write_ex
		move.b	d0,(a4)+
		bra	ML_write
ML_write_ex	rts

ML_PRUW		dc.b	' I',ID,'ND '
ML_LINE		dc.b	'      ',LF,0
ML_MACS1	dc.b	' M',ID,'CD',LF,0	macro definition
ML_MACS2	dc.b	' M',ID,'CU',LF,0	macro usage
ML_ENDM		dc.b	' ENDM',LF
NULLSTR		dc.b	0,0			null string
		cnop	0,4

ML_copy		move.l	sourceend(pc),d1
		addq.l	#1,linnum
		move.l	a4,d2
		beq.s	ML_copy_lp
		bsr	ML_macros
		move.l	a0,txtptr
		bra	ML_line

ML_copy_lp	cmp.l	d1,a4
		bhs	ML_long		source too long
		move.b	(a0)+,d0
		beq	ML_exit
		bsr	ck_eol
		bvc	ML_copy_lp
		move.l	a0,txtptr
		bra	ML_line


ML_not_found	tst.l	d7		check if main level (main file)
		bne.s	ML_not_fnd1	no, include error
		error	#71		yes, main file not found
		bra.s	ML_not_f
ML_not_fnd1	error	#411		file not found
		bra.s	ML_not_f

ML_oom		error	#441		out of mem
		bra.s	ML_err
ML_read_er	error	#431		read error
ML_err		move.l	d6,d1		close file, too!
		lib	Dos,Close
		bra.s	ML_error

ML_sye		error	#401		incomplete
		bra.s	ML_error

ML_neste	error	#421		nesting error
		bra.s	ML_error

ML_long		error	#451		too long source

ML_error	bsr.s	ML_free
ML_not_f	move.l	a3,txtptr
		move.l	a4,a1
		pull	d0-d7/a2-a6
		subq.l	#1,d7		dec depth
		setc
		rts

ML_exit		bsr.s	ML_free
		move.l	a3,txtptr
		move.l	a4,a1
		pull	d0-d7/a2-a6
		subq.l	#1,d7		dec depth
		clrc
		rts

ML_free		move.l	a5,d0
		beq.s	ML_free_ex
		move.l	a5,a1
		move.l	d5,d0
		addq.l	#4,d0
		lib	Exec,FreeMem
		move.l	#0,a5
ML_free_ex	rts


ML_macros	push	d0-d7/a1-a3
		move.l	a0,a3		ptr to the start of line
		move.l	a0,txtptr
		move.l	a0,linstrt	line start for ermsgs

		bsr	getlb
		bvs	ML_nothing	too long symbol ***** - what to do?
		bcs	ML_no_lab	no label = no macro definition
		move.l	a0,txtptr
		bsr	ck_MACRO	mnemonic=MACRO?
		bcc	ML_no_def	not a macro definition

		bsr	ML_Redef	check if already defined
		bcs	ML_re_err

ML_save_macro	move.l	a0,a1		ptr to free storage
		lea	tbuffer(pc),a0	name
		bsr	strcpy		save name
		bsr	seek_nexl	get next line

ML_save_body	move.l	txtptr(pc),a0
		bsr	getlb		skip possible label
		move.l	a0,txtptr
		bsr	ck_MACRO
		bcs	ML_within	definition within definition
		bsr	getmn
		cmp.l	#'ENDM',d0
		beq.s	ML_body_saved
		move.l	linstrt(pc),a0
ML_copy_body	move.b	(a0)+,d0
		beq	ML_no_ENDM	ENDM missing
		move.b	d0,(a1)+
		bsr	ck_eol		copy until eol
		bvc	ML_copy_body
		addq.l	#1,linnum
		bsr	seek_nexl
		bra	ML_save_body

ML_body_saved	clr.b	(a1)+		add null = end of macro
		bsr	seek_nexl
		lea	ML_MACS1(pc),a0	mnem: macro definition
		bsr	ML_write
		move.l	txtptr(pc),a2
		move.l	a3,a1		start of a macro
ML_write_mac	move.b	(a1)+,(a4)+	copy into source buffer
		cmpa.l	a2,a1		all done?
		blo	ML_write_mac
		move.l	a2,a0
		pull	d0-d7/a1-a3
		clrc
		rts

ML_no_lab	bsr	ck_MACRO	if MACRO without name, error
		bcs	ML_no_name
ML_no_def	move.l	txtptr(pc),a0	get addr of mnemonic
ML_get_mnem	move.b	(a0)+,d0	skip until mnemonic starts
		bsr	ck_blk
		bcs	ML_get_mnem

		subq.l	#1,a0		starting position
		bsr	getlb		copies macro/mnem into tbuffer
		movea.l	a0,a2		start of parameters
		bcs.s	ML_nothing	******* what to do?
		bsr	ML_Redef	check if macro defined
		bcc.s	ML_nothing	if not defined, it may be normal opcode

		move.l	a0,a1
		lea	ML_MACS2(pc),a0	mnem: macro usage
		bsr	ML_write

		move.l	a3,a0		start of macro usage line
ML_usage_cpy	move.b	(a0)+,d0
		move.b	d0,(a4)+
		bsr	ck_eol
		bvc	ML_usage_cpy

ML_us_copied	lea	NULLSTR(pc),a0
		move.l	a0,d0		reset parameter ptrs
		move.l	a0,d1
		move.l	a0,d2
		move.l	a0,d3
		move.l	a2,a0
		bsr	ML_blk
		move.l	a0,d0
		bsr	ML_nx_pr	search for next parameter
		bcs.s	ML_us_pok
		move.l	a0,d1
		bsr	ML_nx_pr	search for next parameter
		bcs.s	ML_us_pok
		move.l	a0,d2
		bsr	ML_nx_pr	search for next parameter
		bcs.s	ML_us_pok
		move.l	a0,d3

ML_us_pok	move.l	a1,a0

ML_expand	bsr	McExpand	expand!

		lea	ML_ENDM(pc),a0
		bsr	ML_write

		bsr	seek_nexl
		move.l	txtptr(pc),a0
		pull	d0-d7/a1-a3
		clrc
		rts

ML_nothing	move.b	(a3)+,d0	copy normal lines normally
		beq.s	ML_nothnull
		move.b	d0,(a4)+
		bsr	ck_eol
		bvc	ML_nothing
		bra.s	ML_noth_done
ML_nothnull	subq.l	#1,a3		don't eat nulls!
ML_noth_done	move.l	a3,a0
		pull	d0-d7/a1-a3
		clrc
		rts


ML_within	error	#621
		bra.s	ML_mac_err
ML_no_name	error	#631
		bra.s	ML_mac_err
ML_no_ENDM	error	#641
		bra.s	ML_mac_err
ML_re_err	error	#611		redefined
ML_mac_err	bsr	seek_nexl
		move.l	txtptr(pc),a0
		pull	d0-d7/a1-a3
		setc
		rts


ML_nx_pr	push	d0-d3
ML_nx_lp1	move.b	(a0)+,d0	skip current parameter
		beq.s	ML_nx_eol
		bsr	ck_eol
		bcs.s	ML_nx_eol
		cmp.b	#'<',d0
		beq.s	ML_nx_enc	many values as a single parameter
		cmp.b	#39,d0
		beq.s	ML_nx_enc
		cmp.b	#',',d0		comma as a separator
		bne	ML_nx_lp1
ML_nx_blk	move.b	(a0)+,d0
		beq.s	ML_nx_sye
		bsr	ck_eol
		bcs.s	ML_nx_sye
		bsr	ck_blk
		bcs	ML_nx_blk
		subq.l	#1,a0
		pull	d0-d3
		clrv
		rts

ML_nx_enc	move.b	d0,d1
		cmp.b	#'<',d0
		bne.s	ML_nx_lp2
		moveq.l	#'>',d1
ML_nx_lp2	move.b	(a0)+,d0
		beq.s	ML_nx_sye_a
		bsr	ck_eol
		bcs.s	ML_nx_sye_a
		cmp.b	d1,d0
		bne	ML_nx_lp2
		bra	ML_nx_lp1

ML_nx_sye	error	#651		param error
ML_nx_sye_a	subq.l	#1,a0
		pull	d0-d3
		setc
		setv			V=1: error
		rts

ML_nx_eol	subq.l	#1,a0
		pull	d0-d3
		setc
		clrv
		rts

ML_blk		push	d0
ML_blk_lp	move.b	(a0)+,d0
		bsr	ck_blk
		bcs	ML_blk_lp
		subq.l	#1,a0
		pull	d0
		rts


McExpand	push	d4-d7/a1-a3
		link	a5,#-16
		move.l	d3,-4(a5)
		move.l	d2,-8(a5)
		move.l	d1,-12(a5)
		move.l	d0,-16(a5)
		addq.l	#1,McExpCnt	add 1 to \@nnn cntr
McExMLp		move.l	a0,a3		startptr
		move.b	(a0),d0
		beq	McExEop
		bsr	ck_blk
		bcs.s	McEx_nolb
		bsr	McExpLab	expand a label

McEx_nolb	move.l	a4,a2		save write ptr
McEx_sk1	move.b	(a0)+,d0	copy blanks after label
		move.b	d0,(a4)+
		bsr	ck_blk
		bcs	McEx_sk1
		subq.l	#1,a0
		subq.l	#1,a4
		move.l	a0,a3		processed this far
		bsr	getlb		get mnemonic/macro name
		movea.l	a0,a1		save start of parameters
		bcs	McExNoMac	no mnemonic/macro

		bsr	ML_Redef	is it a macro?
		bcc	McExNoMac	no, branch.

		move.l	a2,a4		remove blanks if mac(mac)
		clr.b	(a4)		null for safety

		push	a0		save macro start addr in buffer

		push	a4		save output pointer
		move.l	obuf(pc),a4	buffer for parameters
		moveq.l	#0,d0
		move.w	McNesting(pc),d0
		asl.l	#8,d0
		add.l	d0,a4
		move.l	a4,a2		start of string in obuf
		move.l	a1,a0		start of parameters
		bsr	McCopy		expand parameters into obuf!

		pull	a4		restore output pointer

		lea	NULLSTR(pc),a0
		move.l	a0,d0		reset parameter ptrs
		move.l	a0,d1
		move.l	a0,d2
		move.l	a0,d3
		move.l	a2,a0		get param string address
		bsr	ML_blk
		move.l	a0,d0
		bsr	ML_nx_pr	search for next parameter
		bcs.s	ML_mac_pok
		move.l	a0,d1
		bsr	ML_nx_pr	search for next parameter
		bcs.s	ML_mac_pok
		move.l	a0,d2
		bsr	ML_nx_pr	search for next parameter
		bcs.s	ML_mac_pok
		move.l	a0,d3

ML_mac_pok	pull	a0		a0 points to a new macro in buffer

		addq.w	#1,McNesting
		cmp.w	#MCNESTING,McNesting
		bls.s	McExNestOk
		error	#661		macro nesting too deep
		bra.s	McEx_Xpanded
McExNestOk	bsr	McExpand
McEx_Xpanded	subq.w	#1,McNesting
McEx_sk2	move.b	(a3)+,d0	skip until end of line
		bsr	ck_eol
		bvc	McEx_sk2
		move.l	a3,a0
		tst.b	d0
		bne	McExMLp
		bra.s	McExEop

*
* handles a macro in macro -situation
*

McExNoMac	move.l	a3,a0
		bsr.s	McCopy
		tst.b	(a0)
		bne	McExMLp
McExEop		unlk	a5
		pull	d4-d7/a1-a3
		rts


McCopy		push	a1
McCopylp	move.b	(a0)+,d0
		beq.s	McCopy_eop
		cmp.b	#'\',d0
		beq.s	McCopy_par
McCopyw		move.b	d0,(a4)+
		bsr	ck_eol
		bcc	McCopylp
		bra.s	McCopy_e
McCopy_par	move.b	(a0),d0

		bsr.s	McExpander
		bra	McCopylp

McCopy_np	moveq.l	#'\',d0		write as it is
		bra	McCopyw

McCopy_eop	subq.l	#1,a0		don't eat nulls!
McCopy_e	pull	a1/a1
		rts


McExpander	cmp.b	#'@',d0
		beq	McExTail
		bsr	ck_dig
		bcc	McExp_np
		cmp.b	#'4',d0
		bhi	McExp_np
		addq.l	#1,a0		skip param number
		and.w	#15,d0
		add.w	d0,d0
		add.w	d0,d0
		move.l	-20(a5,d0.w),a1	get right param ptr here!!!!!

McExp_par_cpy	move.b	(a1)+,d0
		bsr	ck_eol
		bcs	McExpOk		end of param
		bsr	ck_blk
		bcs	McExpOk		end of param
		cmp.b	#',',d0
		beq	McExpOk		end of param
		cmp.b	#'<',d0
		beq.s	McExpBigPar	parameter enclosed in <>
		cmp.b	#39,d0
		beq.s	McExpQuote	string parameter within quotes
		move.b	d0,(a4)+	copy a char
		bra	McExp_par_cpy

McExpBigPar	move.b	(a1)+,d0
		bsr	ck_eol
		bvs.s	McExpBigEr	no line end allowed within <>
		cmp.b	#'>',d0
		beq.s	McExpOk		> ends this parameter
		cmp.b	#'<',d0
		beq.s	McExpBigNes	no <> nesting allowed!
		move.b	d0,(a4)+
		bra	McExpBigPar
McExpBigEr	error	#652
		bra.s	McExpOk
McExpBigNes	error	#671
		bra.s	McExpOk
McExpQuoterr	error	#681		missing quote
		bra.s	McExpOk


McExpQuote	move.b	d0,(a4)+	write opening quote
McExpQuotel	move.b	(a1)+,d0	blanks also allowed within ''
		bsr	ck_eol
		bvs	McExpQuoterr	no line end allowed within ''
		move.b	d0,(a4)+
		cmp.b	#39,d0		' ends this parameter
		bne	McExpQuotel
		bra.s	McExpOk

McExTail	addq.l	#1,a0		skip @
		move.l	McExpCnt(pc),d0
		setc			zeroes needed, too!
		bsr	conv_10
		move.b	buf_10+8(pc),(a4)+
		move.b	buf_10+9(pc),(a4)+
		move.b	buf_10+10(pc),(a4)+
		move.b	buf_10+11(pc),(a4)+
		bra.s	McExpOk

McExp_np	move.b	#'\',(a4)+
		move.b	d0,(a4)+
		addq.l	#1,a0
McExpOk		rts



McExpLab	push	d0		expand a label with possible \@
McExpLabLp	move.b	(a0)+,d0
		cmp.b	#'\',d0
		beq.s	McExpLab_cka	test for @
		bsr	ck_lc
		bcc.s	McExpLab_e	end
McExpLab_cont	move.b	d0,(a4)+	copy a char
		bra	McExpLabLp
McExpLab_cka	move.b	(a0),d0
		bsr	McExpander
		bra	McExpLabLp

McExpLab_e	move.b	d0,(a4)+	don't eat this!
		pull	d0
		rts


ML_Redef	push	a1-a2		check if macro defined
		move.l	labelbuf(pc),a2
ML_R_search	lea	tbuffer(pc),a0	current name
		move.l	a2,a1		ptr into macrobuffer
		tst.b	(a1)
		beq.s	ML_R_notfound	name not found
		bsr	strcmp
		beq.s	ML_R_found
		moveq.l	#1,d0
ML_R_skip	tst.b	(a2)+		skip current name+macro in buffer
		bne	ML_R_skip
		dbf	d0,ML_R_skip
		bra	ML_R_search
ML_R_found	move.l	a1,a0		ptr to macro
		pull	a1-a2
		setc
		rts
ML_R_notfound	move.l	a1,a0		ptr to free macro space
		pull	a1-a2
		clrc
		rts


ck_MACRO	push	a5
		move.l	txtptr(pc),a5
		bsr	getmn		get mnemonic
		bcs.s	ck_MAC_n
		cmp.l	#'MACR',d0
		bne.s	ck_MAC_n	not 'MACRO'
		bsr	cg
		bsr	getmn
		cmp.l	#'RO',d0
		beq.s	ck_MAC_y	it is 'MACRO'

ck_MAC_n	move.l	a5,txtptr
		pull	a5
		clrc
		rts
ck_MAC_y	pull	a5
		setc
		rts


Clr_LBuf	move.l	labelbuf(pc),a0		fill labelbuf with nulls
		move.l	#LABELBUF,d0
		moveq.l	#0,d1
Clr_LBufLoop	move.b	d1,(a0)+
		subq.l	#1,d0
		bne	Clr_LBufLoop
		rts


getlb		push	d0-d1/a1	get label at a0
		move.b	(a0)+,d0	get a symbol name into tbuffer
		bsr	ck_lc		legal char for a label?
		bcc.s	getlb_ill	if not alphanumeric
		bvs.s	getlb_ill	if first char is numeric
		lea	tbuffer(pc),a1
		move.b	d0,(a1)+	save first char
		moveq.l	#LABELLEN-1,d1
getlb_cpy	move.b	(a0)+,d0	one char
		bsr	ck_lc		suitable for labels?
		bcc.s	getlb_copied
		move.b	d0,(a1)+
		dbf	d1,getlb_cpy
		error	#331		name too long
		bra.s	getlb_err
getlb_copied	clr.b	(a1)		add null
		subq.l	#1,a0		restore pointer at first char after label
		pull	d0-d1/a1
		clrc
		clrv
		rts

getlb_ill	subq.l	#1,a0		restore pointer at beginning
		pull	d0-d1/a1
		setc
		rts
getlb_err	pull	d0-d1/a1
		setv
		clrc
		rts









*****************************************************************
*								*
*		     MNEMONICS AND OPCODES			*
*		     =====================			*
*								*
* OpLen - Contains byte# for each addressing mode		*
*								*
*								*
* OpCodes - Table format:					*
* mnemonic							*
* imm; abs; zp; accum; implied; (ind,x); (ind),y; zpx		*
* absx; absy; rel; (ind); zp,y; (aind);				*
*								*
*****************************************************************

OpLen		dc.b	2,3,2,1,1,2,2,2,3,3,2,2,2,0,0,0
OpJMP		dc.b	$00,$4c,$4c,$00,$00,$7c,$00,$00
		dc.b	$00,$00,$00,$6c,$00,$00

OpCodes		dc.l	'LDA'
		dc.b	$a9,$ad,$a5,$00,$00,$a1,$b1,$b5
		dc.b	$bd,$b9,$00,$b2,$00,$00

Op_Codes	dc.l	'STA'
		dc.b	$00,$8d,$85,$00,$00,$81,$91,$95
		dc.b	$9d,$99,$00,$92,$00,$00

		dc.l	'JSR'
		dc.b	$00,$20,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'BRA'
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$80,$00,$00,$00

		dc.l	'CMP'
		dc.b	$c9,$cd,$c5,$00,$00,$c1,$d1,$d5
		dc.b	$dd,$d9,$00,$d2,$00,$00

		dc.l	'BNE'
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$d0,$00,$00,$00

		dc.l	'BEQ'
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$f0,$00,$00,$00

		dc.l	'LDX'
		dc.b	$a2,$ae,$a6,$00,$00,$00,$00,$00
		dc.b	$00,$be,$00,$00,$b6,$00

		dc.l	'RTS'
		dc.b	$00,$00,$00,$00,$60,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'LDY'
		dc.b	$a0,$ac,$a4,$00,$00,$00,$00,$b4
		dc.b	$bc,$00,$00,$00,$00,$00

		dc.l	'INY'
		dc.b	$00,$00,$00,$00,$c8,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'STX'
		dc.b	$00,$8e,$86,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$96,$00

		dc.l	'BCC'
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$90,$00,$00,$00

		dc.l	'BCS'
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$b0,$00,$00,$00

		dc.l	'STY'
		dc.b	$00,$8c,$84,$00,$00,$00,$00,$94
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'STZ'
		dc.b	$00,$9c,$64,$00,$00,$00,$00,$74
		dc.b	$9e,$00,$00,$00,$00,$00

		dc.l	'INX'
		dc.b	$00,$00,$00,$00,$e8,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'PHA'
		dc.b	$00,$00,$00,$00,$48,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'PHX'
		dc.b	$00,$00,$00,$00,$da,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'PHY'
		dc.b	$00,$00,$00,$00,$5a,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'ADC'
		dc.b	$69,$6d,$65,$00,$00,$61,$71,$75
		dc.b	$7d,$79,$00,$72,$00,$00

		dc.l	'PLA'
		dc.b	$00,$00,$00,$00,$68,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'PLX'
		dc.b	$00,$00,$00,$00,$fa,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'PLY'
		dc.b	$00,$00,$00,$00,$7a,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'INC'
		dc.b	$00,$ee,$e6,$1a,$1a,$00,$00,$f6
		dc.b	$fe,$00,$00,$00,$00,$00

		dc.l	'SEC'
		dc.b	$00,$00,$00,$00,$38,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'CLC'
		dc.b	$00,$00,$00,$00,$18,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'SBC'
		dc.b	$e9,$ed,$e5,$00,$00,$e1,$f1,$f5
		dc.b	$fd,$f9,$00,$f2,$00,$00

		dc.l	'ORA'
		dc.b	$09,$0d,$05,$00,$00,$01,$11,$15
		dc.b	$1d,$19,$00,$12,$00,$00

		dc.l	'AND'
		dc.b	$29,$2d,$25,$00,$00,$21,$31,$35
		dc.b	$3d,$39,$00,$32,$00,$00

		dc.l	'BMI'
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$30,$00,$00,$00

		dc.l	'TAX'
		dc.b	$00,$00,$00,$00,$aa,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'CPX'
		dc.b	$e0,$ec,$e4,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'DEX'
		dc.b	$00,$00,$00,$00,$ca,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'ASL'
		dc.b	$00,$0e,$06,$0a,$0a,$00,$00,$16
		dc.b	$1e,$00,$00,$00,$00,$00

		dc.l	'LSR'
		dc.b	$00,$4e,$46,$4a,$4a,$00,$00,$46
		dc.b	$4e,$00,$00,$00,$00,$00

		dc.l	'TXA'
		dc.b	$00,$00,$00,$00,$8a,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'CPY'
		dc.b	$c0,$cc,$c4,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'BPL'
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$10,$00,$00,$00

		dc.l	'TAY'
		dc.b	$00,$00,$00,$00,$a8,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'BIT'
		dc.b	$89,$2c,$24,$00,$00,$00,$00,$34
		dc.b	$3c,$00,$00,$00,$00,$00

		dc.l	'ROL'
		dc.b	$00,$2e,$26,$2a,$2a,$00,$00,$36
		dc.b	$3e,$00,$00,$00,$00,$00

		dc.l	'DEY'
		dc.b	$00,$00,$00,$00,$88,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'PHP'
		dc.b	$00,$00,$00,$00,$08,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'TRB'
		dc.b	$00,$1c,$14,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'TSB'
		dc.b	$00,$0c,$04,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'DEC'
		dc.b	$00,$ce,$c6,$3a,$3a,$00,$00,$d6
		dc.b	$de,$00,$00,$00,$00,$00

		dc.l	'TYA'
		dc.b	$00,$00,$00,$00,$98,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'PLP'
		dc.b	$00,$00,$00,$00,$28,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'EOR'
		dc.b	$49,$4d,$45,$00,$00,$41,$51,$55
		dc.b	$5d,$59,$00,$52,$00,$00

		dc.l	'NOP'
		dc.b	$00,$00,$00,$00,$ea,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'TXS'
		dc.b	$00,$00,$00,$00,$9a,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'SEI'
		dc.b	$00,$00,$00,$00,$78,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'CLI'
		dc.b	$00,$00,$00,$00,$58,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'ROR'
		dc.b	$00,$6e,$66,$6a,$6a,$00,$00,$76
		dc.b	$7e,$00,$00,$00,$00,$00

		dc.l	'BVS'
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$70,$00,$00,$00

		dc.l	'BVC'
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$50,$00,$00,$00

		dc.l	'SED'
		dc.b	$00,$00,$00,$00,$f8,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'CLD'
		dc.b	$00,$00,$00,$00,$d8,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'RTI'
		dc.b	$00,$00,$00,$00,$40,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'TSX'
		dc.b	$00,$00,$00,$00,$ba,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

		dc.l	'CLV'
		dc.b	$00,$00,$00,$00,$b8,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00

; JMP special case

; BRK special case!

; RMB, SMB special cases

; BBR, BBS special cases

		dc.l	0,0

CPU		dc.w	%0000100100001001	;00
		dc.w	%0010100100101001	;01
		dc.w	%0000000100000001	;02
		dc.w	%0010100100101001	;03
		dc.w	%0000000100000001	;04
		dc.w	%0010000100100001	;05
		dc.w	%0000100100000001	;06
		dc.w	%0010100100101001	;07
		dc.w	%1000000101000001	;08
		dc.w	%0010000100001011	;09
		dc.w	%0000000100000001	;10
		dc.w	%0010000100000001	;11
		dc.w	%0000000100000001	;12
		dc.w	%0010000100100001	;13
		dc.w	%0000000100000001	;14
		dc.w	%0010000100100001	;15


ermsgs		dc.b	0		1
		dc.b	0		2
		dc.b	0		3
		dc.b	'Memory allocation error',LF,0		4
		dc.b	'Cannot create file',LF,0		5
		dc.b	'Error writing file',LF,0		6
		dc.b	'File not found',LF,0			7
		dc.b	'No filename',LF,0			8
		dc.b	'Options error',LF,0			9
		dc.b	'Level 0 calculation error',LF,0	10
		dc.b	'Level 1 calculation error',LF,0	11
		dc.b	'Illegal numeric value',LF,0		12
		dc.b	'Division by zero',LF,0			13
		dc.b	'Parenthesis mismatch',LF,0		14
		dc.b	'Quotes upset',LF,0			15
		dc.b	0		16
		dc.b	0		17
		dc.b	0		18
		dc.b	0		19
		dc.b	'Syntax error',LF,0			20
		dc.b	'Unknown addressing mode',LF,0		21
		dc.b	'An 8-bit value expected',LF,0		22
		dc.b	'65c02 mode only',LF,0			23
		dc.b	'Branch too long',LF,0			24
		dc.b	'Illegal adressing mode',LF,0		25
		dc.b	'EQU expected',LF,0			26
		dc.b	'Unknown mnemonic',LF,0			27
		dc.b	'A 16-bit value expected',LF,0		28
		dc.b	'PC-value too large',LF,0		29
		dc.b	'Out of symbol buffer',LF,0		30
		dc.b	'Redefined symbol',LF,0			31
		dc.b	'Illegal symbol name',LF,0		32
		dc.b	'Symbol too long',LF,0			33
		dc.b	'Undefined symbol',LF,0			34
		dc.b	'EQU symbol cannot be redefined',LF,0	35
		dc.b	'Symbol already set by SET/EQU',LF,0	36
		dc.b	'Missing symbol name',LF,0		37
		dc.b	'Absolute symbol value mismatch',LF,0	38
		dc.b	'SET/EQU symbol value mismatch',LF,0	39
		dc.b	'Incomplete statement',LF,0		40
		dc.b	'File not found',LF,0			41
		dc.b	'Include nesting too deep',LF,0		42
		dc.b	'Read error',LF,0			43
		dc.b	'Out of memory error',LF,0		44
		dc.b	'Source file too long',LF,0		45
		dc.b	'Illegal usage of IEND symbol',LF,0	46
		dc.b	0		47
		dc.b	0		48
		dc.b	0		49
		dc.b	'Condition level overflow',LF,0		50
		dc.b	'ENDC without condition',LF,0		51
		dc.b	'Missing ENDC',LF,0			52
		dc.b	'Syntax error',LF,0			53
		dc.b	'FAIL error',LF,0			54
		dc.b	0		55
		dc.b	0		56
		dc.b	0		57
		dc.b	0		58
		dc.b	0		59
		dc.b	'ENDM without MACRO',LF,0		60
		dc.b	'Redefined Macro',LF,0			61
		dc.b	'Illegal macro definition',LF,0		62
		dc.b	'Missing macro name',LF,0		63
		dc.b	'ENDM missing',LF,0			64
		dc.b	'Macro parameter mismatch',LF,0		65
		dc.b	'Macro nesting too deep',LF,0		66
		dc.b	'No <<>> nesting allowed',LF,0		67
		dc.b	'Missing quote or syntax error',LF,0	68
		dc.b	0		69
		dc.b	-1



hextable	dc.b	'0123456789abcdef'	needs no comments
		cnop	0,4

obuf		dc.l	0		output buffer start address
opoi		dc.l	0		output buffer pointer
_CMDLen		dc.l	0		command line length
_CMDBuf		dc.l	0		command line start address
outfile		dc.l	0		output filehandle
infile		dc.l	0		input filehandle
clifile		dc.l	0		clifilehandle
listfile	dc.l	0		listing filehandle
sourcebuf	dc.l	0		source buffer start address
sourceend	dc.l	$0fffffff	source buffer end address
total_len	dc.l	0		total length of all included files
SOURCEBUF	dc.l	1000		source buffer size
auxbuf		dc.l	0		auxiliary buffer start (filenames)
multibuf	dc.l	0		buffer for filenames & errhandler & listout
libuf		dc.l	0		start of list buffer
labelbuf	dc.l	0		start address of label buffer
txtptr		dc.l	0		pointer into source buffer
par1		dc.l	0		65c02 parameter storage
prgc		dc.l	0		65c02 program counter storage
totalbyt	dc.l	0		65c02 object length in bytes
checksum	dc.l	0		65c02 object checksum
tbuffer		ds.b	32		temp buffer
zpabs		dc.b	0		flag: zeropage/absolute
pass		dc.b	0		pass identifier
errcnt		dc.l	0		error counter
errornum	dc.w	0		current error number
linnum		dc.l	0		current linenumber
linstrt		dc.l	0		current line start address
nameptr		dc.l	0		current filename ptr
McExpCnt	dc.l	0		counts \@'s during macro processing
McNesting	dc.w	0		current macro nesting level
pat_pend	dc.w	0		helps cg()
hexmode		dc.w	0		flag: build hexadecimal output file
procmode	dc.w	0		flag: 65c02 mode
userlmode	dc.w	0		flag: listmode set using option -l
listmode	dc.w	0		flag: build listing file (taken from userlmode)
no_list		dc.w	0		flag: don't list this line
idepth		dc.w	0		flag: compiling an include file
incstrt		dc.w	0		flag: new include file starts (set by INCLUDE)
condstrt	dc.w	0		flag: new conditional part starts
symbolmode	dc.w	0		flag: print symbol table
cond_level	dc.w	0		current conditional assembly level
lnf		dc.w	0		flag: label not found (for ifd/ifnd)
hexbytcnt	dc.w	3		counter: 3 hexbytes/listing line
broken		dc.w	0		flag: program stopped by user
absmism		dc.w	0		flag: absolute value mism already printed

sl_flag		dc.w	0		flag: glabel called from slabel
equset		dc.l	0		flag/value: a symbol set/equted on this line

prtline		dc.w	HUGELINE	current printer line
maxline		dc.w	MAXLINE		maximum printer line
prtpage		dc.w	0		current printer page

incnames	ds.l	INCNESTING+1	nameptrs for including
condflags	ds.b	CONDNESTING+1	true/false flags for each level
		cnop	0,2

		libnames		library names & base pointers

		end

