

* TABS set to 9!!! <<< Trust you to be difficult Dave, MM >>>

		opt	d+


		include	"Source:INCLUDE/my_exec.i"
		include	"Source:INCLUDE/my_dos.i"


* 6809 cross assembler

* Calling synopsis:

*	A6809   <srcfile> <dstfile>

* Restrictions on 6809 assembly text supported by this assembler:

* 1) labels 13 chars max. Case IS significant.

* 2) 6809 opcodes as per "Programming the 6809" by Zaks & Labiak,
*	but addressing mode treatment differs somewhat:

*	#nnnn		immediate
*	<NNNN		direct page
*	offset,X		indexed
*	>NNNN		extended
*	offset,PC	program counter relative
*	[...]		indirect

* 3) Assembler directives supported are:
*	ORG EQU DEF RES SETDP OPT END INCLUDE

* 4) Options:

*	S+, S-	Print symbol table on/off
*	A+,A-	Assemble file/syntax check only
*	E+,E-	Wait on error on/off
*	T+,T-	List timings on/off (if I get round to it)
*	L+,L-	Listing on/off

* 5) The ';' char is used for comment delimiting.

* 6) Numbers are decimal unless prefixed by:
*	$ : Hex number
*	% : Binary number
*	@ : Octal number

* 7) Strings are delimited either by "" or ''. But they
*	cannot be mixed.

* 10) Control characters can be written ^A etc., for ease of use. The
*	^ character itself is written ^^.


* equates


_ERR_INST	equ	1	;illegal instruction
_ERR_SIZE	equ	2	;byte/word size clash
_ERR_ADMODE	equ	3	;illegal addressing mode
_ERR_LBRA	equ	4	;long branch needed
_ERR_OPT		equ	5	;illegal option specified
_ERR_IND		equ	6	;illegal indirection
_ERR_UNDEF	equ	7	;label undefined
_ERR_ISDEF	equ	8	;label already defined
_ERR_CHAR	equ	9	;missing character
_ERR_EXP		equ	10	;bad syntax in expression
_ERR_INDX	equ	11	;illegal index register
_ERR_ACC		equ	12	;illegal accumulator
_ERR_DIVZ	equ	13	;division by zero in expression
_ERR_DPAGE	equ	14	;mismatched direct page
_ERR_REGCLASH	equ	15	;PSHS/PSHU register clash
_ERR_TOOBIG	equ	16	;operand too large
_ERR_SWI		equ	17	;illegal SWI instruction
_ERR_MISSING	equ	18	;missing operand
_ERR_DTYPE	equ	19	;illegal RES/DEF type
_ERR_BIGPC	equ	20

_ERR_NOMEM	equ	21	;insufficient memory
_ERR_NODOS	equ	22	;can't open DOS
_ERR_NOSRC	equ	23	;no source file specified
_ERR_OPENSRC	equ	24	3;can't open source file
_ERR_NODST	equ	25	;no dest file specified
_ERR_OPENDST	equ	26	;can't open dest file

_LABELSIZE	equ	13	;maximum label size (MUST BE ODD!!!)

_ADR_IMM		equ	0	;immediate mode
_ADR_DIR		equ	1	;direct page mode
_ADR_IND		equ	2	;indexed mode
_ADR_EXT		equ	3	;extended page mode
_ADR_INH		equ	4	;inherent
_ADR_SREL	equ	5	;short relative
_ADR_LREL	equ	6	;long relative

_ADR_PTR		equ	$80	;indirect flag

_IX_ZERO		equ	0	;zero offset indexed
_IX_C5		equ	1	;5-bit constant indexed
_IX_C8		equ	2	;8-bit constant indexed
_IX_C16		equ	3	;16-bit constant indexed
_IX_ACC		equ	4	;accumulator offset indexed
_IX_AUTOINC	equ	5	;autoincrement
_IX_AUTODEC	equ	6	;autodecrement
_IX_PCR8		equ	7	;program counter relative 8-bit
_IX_PCR16	equ	8	;program counter relative 16-bit

_1ST_OPCODE	equ	16	;1st true opcode number

_1ST_BRA		equ	_1ST_OPCODE+6
_1ST_BIT		equ	_1ST_OPCODE+13
_LAST_BRA	equ	_1ST_OPCODE+25

_QUOTE		equ	34	;double quote char

_CSI_CHAR	equ	$9B	;control sequence introducer


* variables


		rsreset
dos_base		rs.l	1

cli_in		rs.l	1
cli_out		rs.l	1

cmd_ptr		rs.l	1
cmd_len		rs.l	1

opcodeptr	rs.l	1
opcodenum	rs.w	1	;-1 if no valid opcode found
longopcode	rs.w	1	;zero normally, 1 if LBCC etc
addrmode		rs.w	1	;addressing mode
operand		rs.w	1	;value of operand for immed etc

linestart	rs.l	1	;ptr to current text line
lineptr		rs.l	1	;ptr to current char
endptr		rs.l	1	;ptr to current string end
liststart	rs.l	1	;ptr to current listing line
spacebuf		rs.l	1	;ptr to padding buffer

currlabel	rs.l	1	;ptr to label encountered
argptr		rs.l	1	;ptr to operand for DEF etc

linenum		rs.l	1	;current line number
linefile		rs.l	1	;current include file line num

prog_buffer	rs.l	1	;ptr to program buffer
prog_pos		rs.l	1	;ptr to current loc

defarea		rs.l	1	;ptr to DEFB/RESB etc., area

src_handle	rs.l	1	;source file handle
src_name		rs.l	1	;and name ptr

dst_handle	rs.l	1	;dest file handle
dst_name		rs.l	1	;and name ptr

inc_handle	rs.l	1	;current include file handle
inc_name		rs.l	1	;and name ptr

symtab		rs.l	1	;ptr to symbol table

errcount		rs.l	1	;no of errors encountered

error_code	rs.w	1

argcount		rs.w	1	;no of args in command line

symbol_fmt	rs.w	1	;no of symtab entries per line

defcount		rs.w	1	;DEFB/W RESB/W count
resfill		rs.w	1	;filler value for RESB/RESW

numbuf		rs.b	20	;decimal number to print

pc_value		rs.w	1	;assembly value of PC after assembly
oldpc_value	rs.w	1	;assembly value of PC before assembly
indoff		rs.w	1	;offset for indexed mode

opsize		rs.b	1	;no of opcode bytes
instruction	rs.b	6	;actual instruction bytes
dpage		rs.b	1	;page number for SETDP directive
pbytes		rs.b	2	;byte(s) to print
regnum		rs.b	1	;register number for LDX etc

pb_TFR		rs.b	1	;postbyte for TFR and EXG instructions
pb_PSHS		rs.b	1	;postbyte for PSHS etc
sucheck		rs.b	1	;ensure S/U don't clash in PSHS

indtype		rs.b	1	;indexing type
indreg		rs.b	1	;index reg for indexed mode
autoskip		rs.b	1	;whether X+ or X++/-X or --X etc

timing1		rs.b	1	;base instruction timing value
timing2		rs.b	1	;timing addon for indexed
totime		rs.b	1	;total instruction time
totime2		rs.b	1	;total instruction time 2
pshtime		rs.b	1	;extend time for PSHS etc
timinc		rs.b	1	;whether + to be displayed 0/$FF
shortlong	rs.b	1	;whether short or long PC rel
endchar		rs.b	1	;temp end char save
gotlabel		rs.b	1	;flag to signal if got label
gotargs		rs.b	1	;flag to signal if got operand(s)
errchar		rs.b	4	;error char
pass		rs.b	1	;Pass 1 or Pass 2!
options		rs.b	1	;options byte

readchar		rs.b	1	;pushback char from ReadLine()

abort		rs.b	1	;aborting or not?

;filler		rs.b	1	;comment out if even rs.b's above (36)

vars_sizeof	rs.w	0


* Options bits:

* Bit 0 : 1 for full  assemble, 0 for syntax check only

* Bit 1 : 1 for wait on error, 0 for abort on error

* Bit 2 : 1 for listing on, 0 for listing off

* Bit 3 : 1 for symbol table dump on, 0 turns it off


* MAIN PROGRAM LIVES HERE !!!


main		movem.l	d0/a0,-(sp)	;save input parms

		move.l	#vars_sizeof,d0
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		tst.l	d0
		beq	cock_up_1

		move.l	d0,a6		;set up vars

		movem.l	(sp),d0/a0
		move.l	a0,cmd_ptr(a6)	;save input parms
		move.l	d0,cmd_len(a6)

		bsr	InitVars

		bsr	GetParms

		lea	dos_name(pc),a1	;open DOS library
		moveq	#0,d0
		CALLEXEC	OpenLibrary
		move.l	d0,dos_base(a6)
		beq	cock_up_2

		CALLDOS	Input
		move.l	d0,cli_in(a6)	;get CLI input

		CALLDOS	Output
		move.l	d0,cli_out(a6)	;and output handles

		lea	title(pc),a0	;print title message
		move.l	cli_out(a6),d1
		bsr	PString

		move.l	#65536,d0
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l	d0,prog_buffer(a6)	;reserve program
		beq	cock_up_3		;buffer

		move.l	d0,prog_pos(a6)		;and save here too

		move.l	#65536,d0
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l	d0,symtab(a6)	;reserve symbol table
		beq	cock_up_4	;space

		move.l	#65536,d0
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l	d0,defarea(a6)	;reserve DEFB etc area
		beq	cock_up_5	;space

		move.l	src_name(a6),d1
		bne.s	main_1

		move.w	#_ERR_NOSRC,error_code(a6)
		bsr	ReportError
		bra	cock_up_6

main_1		move.l	#MODE_OLD,d2
		CALLDOS	Open
		move.l	d0,src_handle(a6)	;got a file?
		bne.s	main_2

		move.w	#_ERR_OPENSRC,error_code(a6)
		bsr	ReportError
		bra	cock_up_6

main_2		move.l	dst_name(a6),d1
		bne.s	main_3

		move.w	#_ERR_NODST,error_code(a6)
		bsr	ReportError
		bra	cock_up_7

main_3		move.l	#MODE_NEW,d2
		CALLDOS	Open
		move.l	d0,dst_handle(a6)
		bne.s	main_4

		move.w	#_ERR_OPENDST,error_code(a6)
		bsr	ReportError
		bra	cock_up_7

main_4		lea	_ps1(pc),a0
		move.l	cli_out(a6),d1
		bsr	PString

		move.b	#1,pass(a6)
		moveq	#0,d0
		move.l	d0,linenum(a6)
		move.w	d0,pc_value(a6)

mainloop		bsr	ReadLine			;get line of text
		bne	main_5			;skip if EOF hit
		addq.l	#1,linenum(a6)		;next line number

		cmp.b	#1,pass(a6)
		bne.s	main_db1

		move.l	linenum(a6),d0
		lea	padding_buf(pc),a0
		bsr	ItoA
		lea	padding_buf(pc),a0
		bsr	StrLen
		move.l	d7,d3
		move.l	a0,d2
		move.l	cli_out(a6),d1
		CALLDOS	Write

		lea	resetcsr(pc),a0
		move.l	a0,d2
		moveq	#1,d3
		move.l	cli_out(a6),d1
		CALLDOS	Write

main_db1		cmp.b	#1,pass(a6)		;pass 1?
		beq.s	main_4b			;skip if so

		move.l	linestart(a6),a0		;line to copy
		move.l	liststart(a6),a1		;where to copy to
		moveq	#7,d0			;tab stops
		bsr	CopyLine			;copy for printing

main_4b		move.l	linestart(a6),a0
		bsr	ScanLine			;parse line, assemble

		move.b	timing1(a6),d0
		add.b	timing2(a6),d0
		move.b	d0,totime(a6)

		cmp.b	#1,pass(a6)		;pass 1?
		beq.s	main_4a			;skip if so

		btst	#2,options(a6)		;listing on?
		beq.s	main_4a			;skip if not

		bsr	ListLine			;list if pass 2

		bsr	WriteObject

main_4a		bsr	ReportError		;list any errors
		tst.b	abort(a6)		;exiting now?
		beq	mainloop			;skip if continuing
		
main_5		move.b	pass(a6),d0
		addq.b	#1,d0
		cmp.b	#2,d0		;done pass 2?
		bhi.s	main_6		;exit if so
		move.b	d0,pass(a6)

		lea	_ps2(pc),a0	;signal pass 2
		move.l	cli_out(a6),d1
		bsr	PString

		moveq	#2,d0
		bsr	LineFeeds

		moveq	#0,d0
		move.l	d0,linenum(a6)	;reset line count &
		move.w	d0,pc_value(a6)	;assembly PC value

		move.l	src_handle(a6),d1	;close source file
		CALLDOS	Close

		tst.b	abort(a6)	;aborting?
		bne.s	main_6		;exit if not

		move.l	src_name(a6),d1	;and reopen it
		move.l	#MODE_OLD,d2	;for next pass
		CALLDOS	Open
		move.l	d0,src_handle(a6)	;unless of course...
		bne	mainloop		;...we can't...

		move.w	#_ERR_OPENSRC,error_code(a6)

main_6		bsr	ReportError

		btst	#0,options(a6)		;writing out file?
		beq.s	main_6a			;skip if not

		move.l	prog_buffer(a6),d2	;write out
		move.l	prog_pos(a6),d3		;contents of
		sub.l	d2,d3			;prog buffer
		move.l	dst_handle(a6),d1		;to file
		CALLDOS	Write

main_6a		moveq	#1,d0
		bsr	LineFeeds

		move.l	errcount(a6),d0		;total errors
		move.l	linestart(a6),a0		;ptr to string buffer
		bsr	LtoAS			;make ASCII string

		move.l	cli_out(a6),d1		;ptr to output device
		bsr	PString			;print it

		lea	doneinfo(pc),a0
		move.l	cli_out(a6),d1
		bsr	PString

		moveq	#1,d0
		bsr	LineFeeds

		btst	#3,options(a6)	;listing symbol table?
		beq.s	main_7		;skip if not

		lea	stlist(pc),a0
		move.l	cli_out(a6),d1
		bsr	PString

		bsr	ShowSymbols

		moveq	#1,d0
		bsr	LineFeeds

main_7		lea	endinfo(pc),a0
		move.l	cli_out(a6),d1
		bsr	PString

cock_up_8	move.l	dst_handle(a6),d1
		beq.s	cock_up_6
		CALLDOS	Close

cock_up_7	move.l	src_handle(a6),d1
		beq.s	cock_up_5
		CALLDOS	Close

cock_up_6	move.l	defarea(a6),a1
		move.l	#65536,d0
		CALLEXEC	FreeMem

cock_up_5	move.l	symtab(a6),a1
		move.l	#65536,d0
		CALLEXEC	FreeMem

cock_up_4	move.l	prog_buffer(a6),a1
		move.l	#65536,d0
		CALLEXEC	FreeMem

cock_up_3	move.l	dos_base(a6),a1
		CALLEXEC	CloseLibrary

cock_up_2	move.l	a6,a1		;free up variables
		move.l	#vars_sizeof,d0
		CALLEXEC	FreeMem

cock_up_1	movem.l	(sp)+,d0/a0	;clean up stack
		moveq	#0,d0
__done		rts


* InitVars(a6)
* a6 = ptr to main program variables

* initialise those variables that need it.

* d0 corrupt


InitVars		moveq	#0,d0

		move.l	d0,src_handle(a6)		;no file handles
		move.l	d0,src_name(a6)		;to start with
		move.l	d0,dst_handle(a6)
		move.l	d0,dst_name(a6)
		move.l	d0,inc_handle(a6)
		move.l	d0,inc_name(a6)

		move.l	d0,linenum(a6)
		move.l	d0,errcount(a6)

		move.w	d0,pc_value(a6)
		move.w	d0,error_code(a6)
		move.w	d0,argcount(a6)

		move.b	d0,readchar(a6)
		move.b	d0,options(a6)
		move.b	d0,abort(a6)

		lea	errchar(a6),a0
		move.b	#34,(a0)+
		clr.b	(a0)+
		move.b	#34,(a0)+
		move.b	#" ",(a0)+

		lea	debug_buf(pc),a0
		move.l	a0,linestart(a6)
		lea	list_buf(pc),a0
		move.l	a0,liststart(a6)
		lea	padding_buf(pc),a0
		move.l	a0,spacebuf(a6)

		move.w	#3,symbol_fmt(a6)

		rts


* GetParms(a6)
* a6 = ptr to main program variables

* gets parameters (file names etc)

* d0/a0-a1corrupt


GetParms		move.l	cmd_ptr(a6),a0
		move.l	cmd_len(a6),d0

		clr.b	-1(a0,d0.l)	;EOS out the end $0A

GPM_1		bsr	SkipSpace	;find argument
		tst.b	(a0)		;hit EOS already?
		beq.s	GPM_2		;skip if so
		addq.w	#1,argcount(a6)	;update arg count
		bsr	SkipChars	;find end of arg
		tst.b	(a0)		;found last arg?
		beq.s	GPM_2		;skip if so
		clr.b	(a0)+		;EOS it out
		bra.s	GPM_1

GPM_2		tst.w	argcount(a6)	;any args?
		beq.s	GPM_Done		;exit if so

		move.l	cmd_ptr(a6),a0	;point to args

GPM_3		bsr	SkipSpace	;find arg

		cmp.b	#"-",(a0)	;is it an option arg?
		beq.s	GPM_4

		tst.l	src_name(a6)	;got source filename?
		bne.s	GPM_5		;yes-move on
		move.l	a0,src_name(a6)	;else save it
		bra.s	GPM_6
GPM_5		tst.l	dst_name(a6)	;got destination filename?
		bne.s	GPM_6		;yes-move on
		move.l	a0,dst_name(a6)
		bra.s	GPM_6

GPM_4		nop

GPM_6		bsr	SkipChars	;skip ptr past argument
		addq.l	#1,a0		;point past inserted EOS
		subq.w	#1,argcount(a6)	;found end one?
		bne.s	GPM_3		;back for more if not

GPM_Done		rts


* StrLen(a0) -> d7
* a0 = ptr to ASCIIZ string
* returns d7 = length of string

* No other registers corrupt


StrLen		move.l	a0,-(sp)
		moveq	#0,d7

StrLen_1		tst.b	(a0)+
		beq.s	StrLen_2
		addq.l	#1,d7
		bra.s	StrLen_1

StrLen_2		move.l	(sp)+,a0
		rts


* CopyString(a0,a1)
* a0 = ptr to ASCIIZ string to copy
* a1 = ptr to where to copy it to
* Copies strings verbatim.

* a0/a1 corrupt.


CopyString	move.b	(a0)+,(a1)+	;copy byte
		bne.s	CopyString	;continue until EOS
		rts


* CopyLabel(a0,a1,d0)
* a0 = ptr to ASCIIZ label string to copy
* a1 = ptr to where to copy it to
* d0 = max no of chars to copy

* Again verbatim copy, but restricts labels to fit
* into symbol table space.

* d0/a0-a1 corrupt


CopyLabel	move.b	(a0)+,(a1)+	;copy char
		beq.s	CL_Done		;exit if EOS copied

		subq.w	#1,d0		;copied max no of chars?
		bne.s	CopyLabel	;back if not

CL_Done		rts


* CmpStr(a0,a1) -> CCR
* a0 = ptr to SOURCE string (string #1)
* a1 = ptr to DESTINATION string (string #2)

* returns result of comparing 2 strings. After
* calling this, use BEQ to branch if strings equal,
* BHI if (string #2) > (string #1). This is a CASE SENSITIVE
* comparison. Expects ASCIIZ strings.

* d0-d1 corrupt


CmpStr		movem.l	a0-a1,-(sp)	;save char pointers

CmpStr_1		move.b	(a0)+,d0		;get source char
		move.b	(a1)+,d1		;get dest char
		cmp.b	d0,d1		;compare chars
		bne.s	CmpStr_2		;skip if different
		tst.b	d0		;hit EOS?
		bne.s	CmpStr_1		;back for more if not

CmpStr_2		movem.l	(sp)+,a0-a1	;recover pointers
		rts


* CmpStrNC(a0,a1) -> CCR
* a0 = ptr to SOURCE string (string #1)
* a1 = ptr to DESTINATION string (string #2)

* returns result of comparing 2 strings. After
* calling this, use BEQ to branch if strings equal,
* BHI if (string #2) > (string #1). This is a CASE INSENSITIVE
* comparison (small letters converted to capitals prior to the
* comparison). Expects ASCIIZ strings.


* d0-d1 corrupt


CmpStrNC		movem.l	a0-a1,-(sp)	;save char pointers

CmpNC_1		move.b	(a0)+,d0		;get source char
		move.b	(a1)+,d1		;get dest char
		and.b	#$DF,d0		;force upper case
		and.b	#$DF,d1		;(ASCII only!)
		cmp.b	d0,d1		;compare chars
		bne.s	CmpNC_2		;skip if different
		tst.b	d0		;hit EOS?
		bne.s	CmpNC_1		;back for more if not

CmpNC_2		movem.l	(sp)+,a0-a1	;recover pointers
		rts
	

* HashCode(a0) -> d7
* a0 = ptr to label string to generate hash code for
* returns hash code in d7 (which is offset within the
* hash table).

* d0 corrupt


HashCode		move.l	a0,-(sp)		;save label pointer
		moveq	#0,d7		;initial hash code
		move.l	d7,d0

HashCode_1	move.b	(a0)+,d0		;get char
		beq.s	HashCode_2	;EOS met-exit

		add.l	d7,d7		;create hash code
		add.l	d0,d7
		ror.l	#8,d0		;was asl
		eor.l	#$3AC210D9,d0	;randomly chosen magic no.
		add.l	d0,d7
		bra.s	HashCode_1

HashCode_2	move.l	(sp)+,a0		;recover text ptr

		and.l	#$FFF,d7	;constrain to range 0-4095
		lsl.l	#4,d7	;make offset within hashtable

		rts


* ReHash(d7) -> d7
* d7 = Hash code returned by HashCode() above
* returns a new hash code in d7

* Used to create a new hash code if a hash table collision
* occurs.

* d0 corrupt


ReHash		move.l	d7,d0
		add.l	d7,d7		;create hash code
		add.l	d0,d7
		ror.l	#8,d0		;was asl
		eor.l	#$FA198E26,d0	;randomly chosen magic no.
		add.l	d0,d7
		addq.l	#1,d7		;prevent self-locking!

		and.l	#$FFF,d7	;constrain to range 0-4095
		lsl.l	#4,d7	;make offset within hashtable

		rts


* DoHash(a0) -> d7
* a0 = ptr to label text to hash for
* Performs a HashCode(), then if collision occurs, performs
* a ReHash() until free slot occurs.

* d0/a1 corrupt


DoHash		bsr	HashCode		;get 1st hash code

DoHash_1		move.l	d7,a1
		add.l	symtab(a6),a1	;ptr to symbol table entry
		tst.b	(a1)		;occupied already?
		beq.s	DoneHash		;exit if so
		bsr	ReHash		;else get another hashcode
		bra.s	DoHash_1		;and check that one

DoneHash		rts


* LabelExists(a0) -> d7,a1,CCR
* a0 = ptr to label text
* Checks to see if a label exists in the symbol table.
* After calling this code, use BEQ to branch if label exists.

* Also, returns either:

* Hash code of label if it exists, or
* Hash code of next free slot in the hash table in d7,
* and symtab ptr in a1 to either the existing label
* or the next free slot.

* d0-d1/d7/a1 corrupt


LabelExists	bsr	HashCode		;get hash code for label

LEX_1		move.l	d7,a1
		add.l	symtab(a6),a1	;ptr to label
		move.b	(a1),d0		;get 1st char
		seq	d0
		tst.b	d0		;label exists?
		bne.s	LEX_Done		;skip if not

		bsr	CmpStr		;compare strings
		beq.s	LEX_Done		;skip if it's this one!

		bsr	ReHash		;else try a new hash slot
		bra.s	LEX_1

LEX_Done		rts


* InsertLabel(a0,d0) -> d0
* a0 = ptr to label text to insert into symbol table
* d0 = address to insert with symbol

* Inserts label into symbol table with the given address.
* If label already exists, return error code in d0 (NULL if ok).

* d1/d7/a1 corrupt


InsertLabel	move.w	d0,-(sp)		;save address
		bsr	LabelExists	;already in table?
		beq.s	ISL_1		;skip if so

		move.l	a1,-(sp)		;save symtab ptr
		moveq	#_LABELSIZE,d0	;max label size
		bsr	CopyLabel	;insert label
		move.l	(sp)+,a1		;recover symtab ptr
		move.w	(sp)+,d0		;recover address
		move.w	d0,14(a1)	;insert address into table
		moveq	#0,d0		;signal all's well
		rts

ISL_1		tst.w	(sp)+		;clean up stack
		moveq	#_ERR_ISDEF,d0	;signal failure
		rts


* GetLabel(a0) -> d0,d1
* a0 = ptr to label text within an expression string

* Get the value of the label embedded within an expression
* string if it exists, and return an error code if no value
* exists (on Pass 2 only!)

* Returns:

* d0 = error code (0=valid label found, -1=failed)
* d1 = value of label if valid label found

* a0 corrupt


GetLabel		movem.l	a1-a2,-(sp)	;save these-needed elsewhere

		lea	labelbuf(pc),a1	;point to conversion buffer
		move.l	a1,a2
GLB_1		move.b	(a0)+,d0		;get label char
		beq.s	GLB_7		;copy EOS if hit!
		cmp.b	#"0",d0		;before "0"?
		bcs.s	GLB_2		;don't copy if so
		cmp.b	#"9",d0		;within 0-9 range?
		bls.s	GLB_3		;copy if so
		cmp.b	#"A",d0		;before "A"?
		bcs.s	GLB_2		;don't copy if so
		cmp.b	#"Z",d0		;within A-Z range?
		bls.s	GLB_3		;copy if so
		cmp.b	#"_",d0		;underscore?
		beq.s	GLB_3		;copy these
		cmp.b	#"a",d0		;before "a"?
		bcs.s	GLB_2		;don't copy if so
		cmp.b	#"z",d0		;within a-z range?
		bhi.s	GLB_2		;don't copy if not

GLB_3		move.b	d0,(a1)+		;copy char
		bra.s	GLB_1		;and back for more

GLB_2		moveq	#0,d0		;force EOS on illegal char

GLB_7		move.b	d0,(a1)		;save EOS

		move.l	a0,-(sp)		;save new text pointer!
		move.l	a2,a0		;recover ptr

		bsr	StrLen		;get label length
		cmp.w	#_LABELSIZE,d7	;too long?
		bls.s	GLB_4
		add.w	#_LABELSIZE,a0
		clr.b	(a0)		;else put EOS here

GLB_4		move.l	a2,a0
		bsr	LabelExists	;found it?
		beq.s	GLB_5		;skip if so

		moveq	#-1,d0
		bra.s	GLB_6

GLB_5		move.l	a1,a0
		add.w	#_LABELSIZE+1,a0	;point to label code
		move.w	(a0),d1
		moveq	#0,d0

GLB_6		movem.l	(sp)+,a0-a2	;recover text & operator ptrs
		rts


* GetOpcode(a0,a1) -> d0,a2
* a0 = ptr to string to test
* a1 = ptr to array of BCPL strings for legal opcodes

* Check if the string contains the given opcode. Handling
* of the postfix letters done separately.

* Returns:

* d0 = opcode number (for jump table):-1 if error
* a2 = ptr to located opcode if d0 valid

* d0-d3 corrupt


GetOpcode	movem.l	a0-a1,-(sp)	;save text & opcode pointers
		moveq	#0,d0		;initial opcode number

GTO_1		move.l	a1,a2		;copy current opcode ptr
		moveq	#0,d1
		move.b	(a1)+,d1		;get char count
		beq.s	GTO_5		;oops-hit list end

GTO_2		move.b	(a0)+,d2		;get source char
		move.b	(a1)+,d3		;get opcode char
		and.b	#$DF,d2		;convert to
		and.b	#$DF,d3		;upper case
		cmp.b	d2,d3		;chars equal?
		bne.s	GTO_3		;skip if not
		subq.w	#1,d1		;done all chars?
		bne.s	GTO_2		;back for more if not

		movem.l	(sp)+,a0-a1	;recover text, opcode pointer
		tst.w	d0		;and signal success
		rts

GTO_3		move.l	(sp),a0		;get text pointer

GTO_4		addq.l	#1,a1		;skip past this opcode
		subq.w	#1,d1		;skipped it?
		bne.s	GTO_4		;back if not

		subq.l	#1,a1		;correct ptr to BCPL string!
		addq.w	#1,d0		;new opcode number
		bra.s	GTO_1		;and try next opcode

GTO_5		movem.l	(sp)+,a0-a1	;recover pointers and
		moveq	#-1,d0		;signal failure
		rts


* IsOpcode(a0,a1) -> d0,d1,a2
* a0 = ptr to string to test
* a1 = ptr to list of assembler opcodes

* Checks to see if the string IS an opcode. Checks for
* LBCC etc if not found on first pass, to save having
* extra data in the opcode tables.

* Returns:

* d0 = opcode number (-1 if invalid) for use with jump table
* d1 = indicator for LBCC type opcodes
* a2 = ptr to located opcode

* d0-d4 corrupt


IsOpcode		moveq	#0,d4		;is nonzero when scanning LBCC

ISO_1		move.l	a0,-(sp)		;save original text ptr

ISO_5		bsr	GetOpcode	;check for normal opcode
		bpl.s	ISO_2		;exit if found

		tst.w	d4		;already checked for LBCC etc?
		bne.s	ISO_4		;error exit if so

		move.b	(a0)+,d0		;check initial char
		cmp.b	#"L",d0		;possible LBCC etc?
		beq.s	ISO_3		;skip if so
		cmp.b	#"l",d0		;possible LBCC?
		beq.s	ISO_3

ISO_4		move.l	(sp)+,a0		;recover text ptr

ISO_7		moveq	#-1,d0		;signal failure
		rts

ISO_3		addq.w	#1,d4		;signal checking for LBCC etc
		bra.s	ISO_5		;and back to check again

ISO_2		move.l	(sp)+,a0		;recover text pointer
		move.w	d4,d1		;and the LBCC indicator
		beq.s	ISO_6		;skip if not LBCC

		cmp.w	#_1ST_BIT,d0	;found LBIT by accident?
		beq.s	ISO_7		;error exit if so

		cmp.w	#_1ST_BRA,d0	;before LBCC?
		bcs.s	ISO_7		;error exit if so

		cmp.w	#_LAST_BRA,d0	;after LBVS?
		bhi.s	ISO_7		;error exit if so

ISO_6		tst.w	d0		;signal success and
		rts			;return opcode number


* GetReg(a0) -> d0
* a0 = ptr to string to test
* check if the given string is a legal 6809 register.

* Returns:

* d0 = register number (conformed to 6809 postbyte spec
*	for TFR/EXG) if valid register found
*	-1 if no valid register found

* d0-d3/a0-a1 corrupt


GetReg		lea	registers(pc),a1	;list of registers
		bsr	GetOpcode	;check if this is one
		bmi.s	GRG_1		;exit NOW if not
		and.w	#$FF,d0		;get register number
		cmp.w	#6,d0		;correct for TFR and EXG
		bcs.s	GRG_1		;(make regnum for A onwards
		addq.w	#2,d0		;fall into defined range)
GRG_1		tst.w	d0		;ensure correct CCR!
		rts


* PrintHexW(d0)
* d0 = word to print

* d1-d3/a0 corrupt


PrintHexW	move.w	d0,-(sp)
		lsr.w	#8,d0		;get high byte
		bsr.s	PrintHexB
		move.w	(sp)+,d0		;now do low byte:drop into...
		

* PrintHexB(d0)
* d0 = byte to print

* d1-d3/a0 corrupt


PrintHexB	move.w	d0,-(sp)		;save byte

		lsr.b	#4,d0		;get high nibble
		add.b	#"0",d0		;make ASCII digit
		cmp.b	#"9",d0		;range 0-9?
		bls.s	PHB_1		;skip if so
		addq.b	#7,d0		;else make A-F
PHB_1		lea	pbytes(a6),a0	;where to save it
		move.b	d0,(a0)		;save it
		move.l	cli_out(a6),d1
		move.l	a0,d2
		moveq	#1,d3
		CALLDOS	Write

		move.w	(sp),d0		;recover byte
		and.b	#$F,d0		;get low nibble
		add.b	#"0",d0		;make ASCII digit
		cmp.b	#"9",d0		;range 0-9?
		bls.s	PHB_2		;skip if so
		addq.b	#7,d0		;else make A-F
PHB_2		lea	pbytes(a6),a0	;where to save it
		move.b	d0,(a0)		;save it
		move.l	cli_out(a6),d1
		move.l	a0,d2
		moveq	#1,d3
		CALLDOS	Write

		move.w	(sp)+,d0		;clean stack
		rts			;and done


* SkipSpace(a0) -> a0
* a0 = ptr to text string
* returns ptr to 1st non-space char in a0 or ptr
* to NULL if EOS met

* No other registers corrupt


SkipSpace	tst.b	(a0)		;EOS met
		beq.s	SkippedSpace	;exit if so
		cmp.b	#9,(a0)		;hit a TAB?
		beq.s	SKS_1		;yes, so point past TAB
		cmp.b	#" ",(a0)	;hit a SPACE?
		bne.s	SkippedSpace	;no, so exit
SKS_1		addq.l	#1,a0		;point past space char
		bra.s	SkipSpace	;and do more

SkippedSpace	tst.b	(a0)		;and check for EOS
		rts


* SkipChars(a0) -> a0
* a0 = ptr to text string
* returns ptr to 1st space char in a0 or ptr
* to NULL if EOS met

* No other registers corrupt


SkipChars	tst.b	(a0)		;EOS met?
		beq.s	SkippedChars	;exit if so
		cmp.b	#9,(a0)		;TAB hit?
		beq.s	SkippedChars	;exit if so
		cmp.b	#" ",(a0)	;SPACE hit?
		beq.s	SkippedChars	;exit if so
		addq.l	#1,a0		;else point past this char
		bra.s	SkipChars

SkippedChars	tst.b	(a0)		;and check for EOS
		rts


* THINGS TO DO :

* 1) Now that it works for syntactically correct expressions,
*	make it trap errors properly.

* 2) Add the necessary code to the GetNumVal() function to
*	allow it to obtain symbol values from an assembler
*	symbol table.

* 3) Make it handle expressions containing unary minus, unary
*	NOT and functions such as SIN().


* DoExp(a0,a1,a2) -> d0,d1
* a0 = ptr to expression string
* a1 = ptr to table of binary operators to use
* a2 = ptr to table of unary operators to use

* Evaluate an expression from scratch. Initialises parenthesis
* count, then falls through to DoSimpleExp() below.

* Returns :

* d0 =	error code (NULL if ok)
* d1 =	value of expression if NULL error code,
*	(undefined if error found)

* d0-d5/a0/a3 corrupt


DoExp		moveq	#0,d4		;initial parenthesis count
		move.l	d4,d5		;initial error code

		moveq	#-1,d0
		move.w	d0,-(sp)
		bsr	DoSimpleExp
		move.w	(sp)+,d0
		move.w	d5,d0		;return error code
		rts


* DoSimpleExp(a0,a1,a2) -> d0,d1
* a0 = ptr to expression string
* a1 = ptr to table of binary operators to use
* a2 = ptr to table of unary operators to use

* Evaluate a simple expression from scratch.
* Falls through to SimpleExp() below unless an
* error encountered or EOS hit.

* Not so simple now that it handles parentheses!

* Returns :

* d0 =	error code (NULL if ok)
* d1 =	value of expression if NULL error code,
*	(undefined if error found)

* d0-d5/a0/a3 corrupt


DoSimpleExp	moveq	#-1,d0		;initial 'no operator'
		moveq	#0,d1		;initial operand

		move.l	d1,d3		;make copies
		move.w	d0,d2

		tst.b	(a0)		;hit EOS already?
		beq	SEP_Done		;exit if so

		exg	a1,a2		;check for preceding
		bsr	GetOp		;unary operator
		bmi.s	DSP_3

		cmp.b	#"(",(a0)	;hit "("?
		bne.s	DSP_4		;continue if not

		addq.l	#1,a0		;point past "("
		addq.w	#1,d4		;update () nest count
		move.w	d0,-(sp)		;save unary operator
		moveq	#-1,d0
		move.w	d0,-(sp)		;signal new level
		exg	a1,a2		;recover normal table ptrs order
		bsr	DoSimpleExp	;evaluate (...)
		tst.w	(sp)+		;tidy the stack
		move.w	(sp)+,d0		;recover operator
		bra.s	DSP_5		;and do unary op

DSP_4		move.w	d0,d2		;save operator
		bsr	GetNumVal	;get value following unary op
		move.w	d2,d0		;recover unary operator
		exg	a1,a2		;recover normal table ptrs

DSP_5		bsr	DoUnary		;perform unary operation on it
		bra.s	DSP_6

		tst.b	(a0)		;hit EOS already?
		beq	SEP_Done		;exit if so

		cmp.b	#")",(a0)	;hit ")" already?
		beq	SEP_Done		;exit if so

DSP_3		exg	a1,a2
		cmp.b	#"(",(a0)	;hit "("?
		bne.s	DSP_1		;continue if not

		addq.l	#1,a0		;point past "("
		addq.w	#1,d4		;update () nest count

		move.w	d0,-(sp)		;signal new level
		bsr	DoSimpleExp	;else evaluate (...)
		move.w	(sp)+,d0		;tidy the stack

BKPT1		tst.b	(a0)		;hit EOS?
		beq	SEP_Done		;exit if so

		cmp.b	#")",(a0)	;hit ")"?
		bne.s	DSP_2		;continue if so

		addq.l	#1,a0		;point past ")"
		subq.w	#1,d4		;update () nest count
		rts			;and return		

DSP_1		bsr	GetNumVal	;get operand value

DSP_6		tst.b	(a0)		;hit EOS?
		beq	SEP_Done		;exit if so

		cmp.b	#")",(a0)	;hit ")" already?
		bne.s	DSP_2		;continue if not

		addq.l	#1,a0		;else skip past ")"
		subq.w	#1,d4		;update () nest count
		rts			;and exit

DSP_2		bsr	GetOp		;get an operator

		bpl.s	SimpleExp
		moveq	#_ERR_EXP,d5	;else return error
		bra	SEP_Done		;(illegal operator)


* SimpleExp(d0,d1,a0,a1) -> d0,d1
* d0 = operator from previous fetch
* d1 = operand from previous fetch
* a0 = ptr to expression string
* a1 = ptr to table of operands to use

* Evaluate a 'simple' expression.

* Returns :

* d0 =	error code (NULL if ok)
* d1 =	value of expression if NULL error code,
*	(undefined if error found)

* d0-d5/a0/a3 corrupt


SimpleExp	move.l	d1,d3		;save previous op
		move.w	d0,d2		;values

		moveq	#-1,d0		;tmp invalid operator

		tst.b	(a0)		;hit EOS?
		beq	SEP_4		;do last operation if so

		exg	a1,a2		;check for a unary operator
		bsr	GetOp		;got it?
		bmi.s	SEP_9		;skip if not

		cmp.b	#"(",(a0)	;hit "("?
		bne.s	SEP_10		;skip if not

		addq.l	#1,a0		;point past "("
		addq.w	#1,d4		;update () nest count
		move.w	d0,-(sp)		;save unary operator
		moveq	#-1,d0
		move.w	d0,-(sp)		;signal new level
		exg	a1,a2		;recover normal table ptrs order
		move.l	d3,-(sp)		;save old operand & operator
		move.w	d2,-(sp)
		bsr	DoSimpleExp	;evaluate (...)
		move.w	(sp)+,d2		;recover prev operand, operator
		move.l	(sp)+,d3
		tst.w	(sp)+		;tidy the stack
		move.w	(sp)+,d0		;recover operator
		bra.s	SEP_11		;and do unary op

SEP_10		move.w	d0,-(sp)		;save unary operator
		bsr	GetNumVal	;get following operand
		move.w	(sp)+,d0		;recover operand
		exg	a1,a2		;recover normal table ptrs

SEP_11		bsr	DoUnary		;do unary operation
		bra.s	SEP_7		;and continue on

SEP_9		exg	a1,a2		;recover normal table ptrs
		cmp.b	#"(",(a0)	;hit "("?
		bne.s	SEP_5		;continue if not

		addq.l	#1,a0		;point past "("
		addq.w	#1,d4		;update () nest count

		move.l	d3,-(sp)		;save operand
		move.w	d2,-(sp)		;save operator
		move.w	d0,-(sp)		;signal new nesting level

		bsr	DoSimpleExp	;evaluate (...)

BKPT2		move.w	(sp)+,d0		;tidy stack
		move.w	(sp)+,d2		;recover operator
		move.l	(sp)+,d3		;recover operand
		bra.s	SEP_7		;and continue

SEP_5		bsr	GetNumVal	;get new operand

SEP_7		moveq	#-1,d0		;tmp invalid operator

		tst.b	(a0)		;hit EOS?
		beq.s	SEP_4		;do last operation if so

		cmp.b	#")",(a0)	;hit ")"?
		bne.s	SEP_8		;continue if not

		addq.l	#1,a0		;point past ")"
		subq.w	#1,d4		;update () nest count

		bsr	DoTerm		;do last part of (...)

		rts			;and return

SEP_8		bsr	GetOp		;get an operator
		bpl.s	SEP_3		;and continue if OK

		moveq	#_ERR_EXP,d5	;else error
		bra.s	SEP_Done		;(illegal operator)

SEP_3		cmp.b	d2,d0		;new op > prev op?
		bhi.s	SEP_1		;skip if so

SEP_4		bsr	DoTerm		;else compute this term

		tst.b	(a0)
		beq.s	SEP_Done

		tst.w	4(sp)
		bpl.s	SEP_Done

		tst.w	d0
		bpl	SimpleExp

SEP_Done		rts			;else back to caller

SEP_Error	rts


* Come here if most recent operator fetched from string has a
* higher precedence than the previous operator.


SEP_1		move.l	d3,-(sp)		;save prev opnd, op
		move.w	d2,-(sp)

;		bsr	NestExp		;get a new term to compute
		bsr	SimpleExp

BKPT3		move.w	(sp)+,d2		;recover old ops
		move.l	(sp)+,d3

		bsr	DoTerm		;compute left over term

		tst.b	(a0)		;hit EOS?
		beq.s	SEP_Done		;exit if so

		tst.w	d0		;got a following operator?
		bpl	SimpleExp	;skip if so

;		bsr	GetOp		;else get it
;		bra	SimpleExp

		rts			;else done


* DoTerm(d1,d2,d3) -> d1

* d1,d3 = operands
* d2 = operator to use

* Evaluate a term. Return value in d1.

* d2/d3/a3 corrupt


DoTerm		exg	d1,d3		;change operand order
		lea	CompTable(pc),a3
		clr.b	d2
		lsr.w	#6,d2		;operator no * 4
		add.w	d2,a3		;point to jump table entry
		move.l	(a3),a3		;get arith routine address
		jmp	(a3)		;execute it


* DoUnary(d0,d1) -> d1

* d1 = operands
* d0 = operator to use

* Evaluate a unary term. Return value in d1.

* d0/a3 corrupt


DoUnary		lea	FuncTable(pc),a3
		clr.b	d0
		lsr.w	#6,d0		;operator no * 4
		add.w	d0,a3		;point to jump table entry
		move.l	(a3),a3		;get arith routine address
		jmp	(a3)		;execute it


* GetNumVal(a0) -> d0,d1
* a0 = ptr to value string

* returns:

* d0 = error code (NULL if ok)
* d1 = value represented by ASCII digit string/label string

* This latest version accepts chars in the forms:

*		".
*		"."

* as values, converting the char following the first
* " to an ASCII char value.

* a0 corrupt


GetNumVal	moveq	#0,d1		;init value
		move.l	d1,d0

		move.l	d2,-(sp)		;save this

		move.b	(a0)+,d0		;get 1st char

		cmp.b	#_QUOTE,d0	;quoted char?
		bne.s	GNV_B1		;skip if not

		moveq	#0,d1		;ensure long zero
		move.b	(a0)+,d1		;get ASCII char
		cmp.b	#"\",d1		;backslash?
		bne.s	GNV_B3		;skip if not
		move.b	(a0)+,d1		;else copy next char verbatim
		bra.s	GNV_B4

GNV_B3		cmp.b	#"^",d1		;^ character?
		bne.s	GNV_B4
		move.b	(a0)+,d1		;get next char
		and.b	#$1F,d1		;make control char

GNV_B4		cmp.b	#_QUOTE,(a0)	;hit another quote?
		bne	GNV_B2		;no, exit
		addq.l	#1,a0		;skip past it

GNV_B2		move.l	(sp)+,d2		;recover this
		moveq	#0,d0		;signal no error
		rts

GNV_B1		cmp.b	#"0",d0		;digit?
		bcs.s	GNV_1		;skip if before "0"

		cmp.b	#"9",d0		;digit?
		bls.s	GNV_Dec		;skip if decimal value

GNV_1		cmp.b	#"$",d0		;hex value?
		beq.s	GNV_Hex		;skip if so

		cmp.b	#"%",d0		;binary value?
		beq	GNV_Bin		;skip if so

		cmp.b	#"@",d0		;octal value?
		beq	GNV_Oct		;skip if so


* Here it's a label. So use GetLabel() to obtain its value
* and return either label value or error code as required.


		subq.l	#1,a0		;point to 1st char proper
		move.l	d7,-(sp)		;save this-VITAL!
		bsr	GetLabel		;get its value
		move.l	(sp)+,d7

		tst.l	d0
		beq.s	GNV_Done		;and return if OK
		cmp.b	#1,pass(a6)	;pass 1 only?
		beq.s	GNV_Done

GNV_Err1		moveq	#_ERR_UNDEF,d5	;set error code
		subq.l	#1,a0
		move.l	(sp)+,d2
		moveq	#-1,d0
		rts

GNV_Done		subq.l	#1,a0		;point to 1st operator char!
		move.l	(sp)+,d2		;recover this
		moveq	#0,d0		;signal no error

		rts


GNV_Dec		move.l	d1,d2		;current value

		add.l	d1,d1
		add.l	d1,d1
		add.l	d2,d1
		add.l	d1,d1		;current value * 10

		sub.b	#"0",d0
		add.l	d0,d1		;plus new digit

		moveq	#0,d0
		move.b	(a0)+,d0		;get char
		cmp.b	#"0",d0		;digit?
		bcs.s	GNV_Done		;exit if not
		cmp.b	#"9",d0
		bhi.s	GNV_Done
		bra.s	GNV_Dec		;else continue evaluation


GNV_Hex		moveq	#0,d0
		move.b	(a0)+,d0		;get char
		sub.b	#"0",d0		;create digit
		cmp.b	#9,d0		;digit 0-9?
		bls.s	GNV_2		;skip if so
		subq.b	#7,d0		;digit A-F? (prev 6!)
		cmp.b	#$A,d0
		bcs.s	GNV_Done
		cmp.b	#$F,d0
		bls.s	GNV_2
		sub.b	#$20,d0
		cmp.b	#$A,d0
		bcs.s	GNV_Done
		cmp.b	#$F,d0		;digit a-f?
		bhi.s	GNV_Done		;exit if not
GNV_2		lsl.l	#4,d1
		add.l	d0,d1		;create hex value
		bra.s	GNV_Hex		;back for next char


GNV_Bin		moveq	#0,d0
		move.b	(a0)+,d0		;get char
		sub.b	#"0",d0		;ASCII to digit convert
		cmp.b	#1,d0		;check if binary digit
		bhi.s	GNV_Done		;exit if not-done
		add.l	d1,d1
		add.l	d0,d1		;create binary value
		bra.s	GNV_Bin


GNV_Oct		moveq	#0,d0
		move.b	(a0)+,d0		;get char
		sub.b	#"0",d0		;ASCII to digit convert
		cmp.b	#7,d0		;check if octal digit
		bhi.s	GNV_Done		;exit if not-done
		add.l	d1,d1
		add.l	d1,d1
		add.l	d1,d1
		add.l	d0,d1		;create octal value
		bra.s	GNV_Oct


* GetOp(a0,a1) -> d0
* a0 = ptr to expression text
* a1 = ptr to table of operators to scan

* Get operator + precedence (returns -1 if error)

* No other registers corrupt


GetOp		move.l	d2,-(sp)		;save this
		moveq	#0,d2		;operator number
		move.l	a1,-(sp)		;save operator table ptr

GetOp_0		move.b	(a1)+,d0		;char count
		beq.s	GetOp_Err	;oops...
		move.l	a0,-(sp)		;save text ptr

GetOp_1		cmp.b	(a0)+,(a1)+	;chars equal?
		bne.s	GetOp_2		;skip if not
		subq.b	#1,d0		;done all chars?
		bne.s	GetOp_1		;back for more if not

		move.b	d2,d0		;else copy operator number
		lsl.w	#8,d0
		move.b	(a1)+,d0		;and precedence

		tst.l	(sp)+		;clean stack

		move.l	(sp)+,a1		;recover table ptr
		move.l	(sp)+,d2		;recover this
		tst.w	d0		;signal OK
		rts			;done

GetOp_2		subq.b	#1,d0		;done all chars?
		beq.s	GetOp_3
		addq.l	#1,a1		;else next table char
		bra.s	GetOp_2		;and back for more

GetOp_3		addq.l	#1,a1		;point past precedence
		move.l	(sp)+,a0		;recover text pointer
		addq.w	#1,d2		;next operator number
		bra.s	GetOp_0		;and get next one

GetOp_Err	move.l	(sp)+,a1		;recover table ptr
		move.l	(sp)+,d2		;recover this
		moveq	#-1,d0		;return error code
		rts


* TABLE OF FUNCTIONS TO EXECUTE WHEN BINARY OPERATOR ENCOUNTERED


CompTable	dc.l	DoPower
		dc.l	DoL_AND
		dc.l	DoL_OR
		dc.l	DoLShift
		dc.l	DoRShift
		dc.l	DoR_GE
		dc.l	DoR_LE
		dc.l	DoR_NE
		dc.l	DoR_GT
		dc.l	DoR_LT
		dc.l	DoDiv
		dc.l	DoMul
		dc.l	DoAdd
		dc.l	DoSub
		dc.l	DoR_EQ
		dc.l	DoB_AND
		dc.l	DoB_XOR
		dc.l	DoB_OR


FuncTable	dc.l	DoNeg
		dc.l	DoL_NOT
		dc.l	DoComp
		dc.l	DoHighByte
		dc.l	DoLowByte


* DoDiv(d1,d2) -> d1
* d1,d2 = values to act on
* returns d1/d2 in d1

* Same protocol for DoMul() etc


DoDiv		move.l	d6,-(sp)		;save this

		movem.l	d1/d3,-(sp)	;save original parms

		tst.l	d1		;1st arg positive?
		bpl.s	DoDiv_5		;skip if so
		neg.l	d1		;else make positive

DoDiv_5		tst.l	d3		;2nd arg positive?
		bpl.s	DoDiv_6		;skip if so
		neg.l	d3		;else make positive

DoDiv_6		moveq	#0,d6	;shift count

		tst.l	d3	;division by zero?
		beq.s	DoDiv_1	;skip to error if so

DoDiv_4		swap	d3
		tst.w	d3	;high word zero?
		bne.s	DoDiv_2	;no, so change shift count
		swap	d3
		bra.s	DoDiv_3	;else use as is

DoDiv_2		swap	d3	;replace high word
		asr.l	#1,d3	;shift
		addq.w	#1,d6	;update shift count
		bra.s	DoDiv_4	;test again

DoDiv_3		divu	d3,d1	;perform division
		bvs.s	DoDiv_9	;oops...
		ext.l	d1	;make result full 32-bit

		asr.l	d6,d1	;normalise the result

DoDiv_10		tst.l	(sp)+	;check sign of arg #1
		bpl.s	DoDiv_7	;skip if positive
		neg.l	d1	;else negate

DoDiv_7		tst.l	(sp)+	;check sign of arg #2
		bpl.s	DoDiv_8	;skip if positive
		neg.l	d1	;else negate

DoDiv_8		move.l	(sp)+,d6	;tidy stack
		rts

DoDiv_1		moveq	#_ERR_DIVZ,d5	;return error code
		move.l	(sp)+,d6		;and tidy stack
		rts


* Come here if the result of the division won't fit into 16 bits.


DoDiv_9		addq.w	#1,d6		;shift count
		add.l	d3,d3		;divisor * 2
		divu	d3,d1		;do division again
		bvs.s	DoDiv_9		;and retry if overflow

		asl.l	d6,d1		;remultiply result
		bra.s	DoDiv_10		;and normalise result


* DoMul(d1,d3)
* d1,d3 = arguments to multiply together

* This complex routine takes account of multiplying two long ints
* together (68000 MULU/MULS only takes 16-bit args) by doing the
* multiplication in stages:

* Stage 1 : Low word of D1 * low word of D3

* Stage 2 : High word of D1 * low word of D3

* Stage 3 : Low word of D1 * high word of D3

* Stage 4 : High word of D1 * high word of D3

* Total result is a 64-bit quantity. if each stage is split
* into words as follows:

*	Stage 1 :	A B
*	Stage 2 :	C D
*	Stage 3 :	E F
*	Stage 4 :	G H

* then the final result is formed as:

*		0 0 A B		(Here 0 represents a
*		0 C D 0	+	 zero WORD, i.e.,
*		0 E F 0	+	 $0000.W)
*		G H 0 0	+

* For this code, only the LOW LONG WORD is used. Other users of
* this code might like to alter it to use the ENTIRE 64-bit
* result.


DoMul		movem.l	d4-d7,-(sp)	;save workspace
		movem.l	d1/d3,-(sp)	;save original args
		tst.l	d1
		bpl.s	DoMul_1
		neg.l	d1		;force positive
DoMul_1		tst.l	d3
		bpl.s	DoMul_2
		neg.l	d3		;force positive
DoMul_2		move.w	d1,d4
		mulu	d3,d4		;do Arg1L * Arg2L

		swap	d1
		move.w	d1,d5
		mulu	d3,d5		;do Arg1H * Arg2L

		swap	d1
		swap	d3
		move.w	d1,d6
		mulu	d3,d6		;do Arg1L * Arg2H

		swap	d1
		swap	d3
		move.w	d1,d7
		mulu	d3,d7		;do Arg1H * Arg2H

		add.l	d5,d6
		swap	d6
		clr.w	d6
		add.l	d4,d6
		move.l	d6,d1

		tst.l	(sp)+
		bpl.s	DoMul_3
		neg.l	d1
DoMul_3		tst.l	(sp)+
		bpl.s	DoMul_4
		neg.l	d1
DoMul_4		movem.l	(sp)+,d4-d7	;recover these
		rts

		muls	d3,d1
		rts

DoLShift		asl.l	d3,d1
		rts

DoRShift		asr.l	d3,d1
		rts

DoAdd		add.l	d3,d1
		rts

DoSub		sub.l	d3,d1
		rts

DoR_GE		cmp.l	d3,d1
		sge	d1
		ext.w	d1
		ext.l	d1
		rts


DoR_LE		cmp.l	d3,d1
		sle	d1
		ext.w	d1
		ext.l	d1
		rts

DoR_GT		cmp.l	d3,d1
		sgt	d1
		ext.w	d1
		ext.l	d1
		rts

DoR_LT		cmp.l	d3,d1
		slt	d1
		ext.w	d1
		ext.l	d1
		rts


DoR_NE		cmp.l	d3,d1
		sne	d1
		ext.w	d1
		ext.l	d1
		rts


DoR_EQ		cmp.l	d3,d1
		seq	d1
		ext.w	d1
		ext.l	d1
		rts

DoB_AND		and.l	d3,d1
		rts


DoB_XOR		eor.l	d3,d1
		rts

DoB_OR		or.l	d3,d1
		rts

DoL_AND		sne	d1
		ext.w	d1
		ext.l	d1
		sne	d3
		ext.w	d3
		ext.l	d3
		and.l	d3,d1
		rts


DoL_OR		sne	d1
		ext.w	d1
		ext.l	d1
		sne	d3
		ext.w	d3
		ext.l	d3
		or.l	d3,d1
		rts


DoPower		move.l	d7,-(sp)
		move.l	d1,d7
		tst.l	d3
		beq.s	DoPower_2

DoPower_1	subq.l	#1,d3
		beq.s	DoPower_3
		move.l	d3,-(sp)
		move.l	d7,d3
		bsr	DoMul
		move.l	(sp)+,d3
		bra.s	DoPower_1

DoPower_3	move.l	(sp)+,d7

		rts

DoPower_2	moveq	#1,d1
		rts


* TABLE OF FUNCTIONS TO EXECUTE WHEN UNARY OPERATOR ENCOUNTERED


DoNeg		neg.l	d1
		rts

DoComp		not.l	d1
		rts

DoL_NOT		tst.l	d1
		seq	d1
		ext.w	d1
		ext.l	d1
		rts

DoLowByte	move.b	d1,d3
		moveq	#0,d1
		move.b	d3,d1
		rts


DoHighByte	move.w	d1,d3
		moveq	#0,d1
		move.w	d3,d1
		lsr.w	#8,d1
		rts


* ItoA(d0,a0) -> d0
* d0 = UNSIGNED int to convert to string
* a0 = ptr to buffer for string creation

* Convert short int to ASCII string

* d0-d1 corrupt


ItoA		move.l	a0,-(sp)

		tst.w	d0		;initial zero?
		beq.s	ItoA_3		;skip if so

ItoA_1		tst.w	d0		;zero?
		beq.s	ItoA_2		;skip if so

		moveq	#0,d1
		move.w	d0,d1		;copy value
		divu	#10,d1		;value / 10
		move.w	d1,d0		;keep for next round
		swap	d1		;get remainder
		add.b	#"0",d1		;make ASCII digit
		move.b	d1,(a0)+		;pop char in
		bra.s	ItoA_1

ItoA_2		clr.b	(a0)		;pop EOS on end
		move.l	(sp)+,a0		;recover ptr
		rts

ItoA_3		move.b	#"0",(a0)+	;create zero string
		clr.b	(a0)
		move.l	(sp)+,a0		;recover ptr
		rts


ItoAR		link	a1,#-2		;reserve stack space

		tst.w	d0		;zero?
		beq.s	ItoAR_1

		moveq	#0,d1
		move.w	d0,d1
		divu	#10,d1		;value/10
		move.w	d1,d0		;keep for next call
		swap	d1
		add.b	#"0",d1		;make ASCII digit
		move.w	d1,-2(a1)	;store it
		bsr.s	ItoAR		;and call again
		move.w	-2(a1),d1
		move.b	d1,(a0)+		;pop in char

ItoAR_1		unlk	a1		;deallocate space
		rts			;and back


* LtoA(a0,d0) -> a0
* d0 = UNSIGNED long int to convert to string
* a0 = buffer for string creation

* Convert a long integer into an ASCII string. Returns
* pointer to ASCII digit string in a0.

* d0-d3/a0-a1 corrupt


LtoA		move.l	a0,-(sp)		;save buffer ptr

		lea	NumBase(pc),a1	;ptr to base values

LtoA_1		moveq	#0,d1		;no of B^Ns in number

		move.l	(a1)+,d2		;get B^N
		beq.s	LtoA_Done	;exit if 0 - done!
		cmp.l	d2,d0		;num > B^N?
		bcs.s	LtoA_3		;skip if not

		move.l	d2,d3		;copy B^N
LtoA_2		addq.w	#1,d1		;at least this many B^Ns
		add.l	d2,d3		;add another one
		cmp.l	d3,d0		;num > (f * B^N) ?
		bcc.s	LtoA_2		;back if so

		sub.l	d3,d0		;create num - (f * B^N)
		add.l	d2,d0		;for next round

LtoA_3		add.b	#"0",d1		;create ASCII digit
		move.b	d1,(a0)+		;insert char

		bra.s	LtoA_1

LtoA_Done	clr.b	(a0)+		;append EOS to string

		move.l	(sp)+,a0		;recover buffer ptr

LtoA_4		cmp.b	#"0",(a0)+	;skip initial "0"s
		beq.s	LtoA_4

		subq.l	#1,a0		;correct pointer
		tst.b	(a0)
		bne.s	LtoA_5

		subq.l	#1,a0		;handle zero case

LtoA_5		rts


* LtoAS(a0,d0)
* a0 = ptr to buffer for string
* d0 = SIGNED long int to convert

* Perform same as LtoA() above, but for signed long ints.

* d0-d3/a0-a1 corrupt


LtoAS		move.l	d0,-(sp)		;save original long int

		tst.l	d0		;create absolute value
		bpl.s	LtoAS_1		;skip if already positive
		neg.l	d0		;else make it positive
LtoAS_1		bsr	LtoA		;perform conversion

		tst.l	(sp)+		;original negative?
		bpl.s	LtoAS_2

		move.b	#"-",-(a0)	;prepend minus sign

LtoAS_2		rts


* ScanLine(a0,a6)
* a0 = ptr to line to scan
* a6 = ptr to main program variables

* Scan line for opcodes, labels etc.

* Assume ALL registers corrupt!


ScanLine		moveq	#0,d0
		move.l	d0,currlabel(a6)
		move.w	d0,operand(a6)
		move.w	d0,indoff(a6)
		move.w	d0,defcount(a6)
		move.b	d0,opsize(a6)
		move.b	d0,gotargs(a6)

		lea	regnum(a6),a1

		move.b	d0,(a1)+		;regnum
		move.b	d0,(a1)+		;pb_TFR
		move.b	d0,(a1)+		;pb_PSHS
		move.b	d0,(a1)+		;sucheck
		move.b	d0,(a1)+		;indreg
		move.b	d0,(a1)+		;indtype
		move.b	d0,(a1)+		;autoskip
		move.b	d0,(a1)+		;timing1
		move.b	d0,(a1)+		;timing2
		move.b	d0,(a1)+		;totime
		move.b	d0,(a1)+		;totime2
		move.b	d0,(a1)+		;pshtime
		move.b	d0,(a1)+		;timinc

		move.w	pc_value(a6),d0
		move.w	d0,oldpc_value(a6)

		bsr	SkipSpace	;find 1st true char
		beq	SCL_Null		;null line
		cmp.b	#";",(a0)	;hit comment?
		beq	SCL_Null		;ignore it

		move.l	a0,-(sp)		;save ptr to it
		bsr	SkipChars	;find end
		move.l	a0,endptr(a6)	;save ptr to it
		move.b	(a0),endchar(a6)	;save end char
		clr.b	(a0)		;temp EOS
		move.l	(sp)+,a0		;recover start ptr

		lea	opcodes(pc),a1	;opcode list
		bsr	IsOpcode		;found one?
		bpl.s	SCL_1		;skip if so

		cmp.b	#1,pass(a6)	;pass 1?
		bne.s	SCL_1a		;skip if not

		move.w	pc_value(a6),d0
		bsr	InsertLabel	;else treat text as label
		tst.w	d0		;error?
		bne	SCL_Done		;exit NOW if so

		move.l	a1,currlabel(a6)	;save label ptr

SCL_1a		move.l	endptr(a6),a0	;get end pointer
		move.b	endchar(a6),(a0)	;reset char

		bsr	SkipSpace	;find next true char
		beq	SCL_Null		;null line
		cmp.b	#";",(a0)	;hit comment?
		beq	SCL_Null		;ignore it

		move.l	a0,-(sp)		;save ptr to it
		bsr	SkipChars	;find end
		move.l	a0,endptr(a6)	;save ptr to it
		move.b	(a0),endchar(a6)	;save end char
		clr.b	(a0)		;temp EOS
		move.l	(sp)+,a0		;recover start ptr

		lea	opcodes(pc),a1	;opcode list
		bsr	IsOpcode		;found one?
		bpl.s	SCL_1		;skip if so

		moveq	#_ERR_INST,d0	;else signal error
		bra	SCL_Done		;and exit

SCL_1		move.w	d0,opcodenum(a6)	;save opcode number
		move.w	d1,longopcode(a6)	;LBCC flag
		move.l	a2,opcodeptr(a6)	;and opcode string ptr
		move.w	d0,d2

		moveq	#0,d0
		move.b	(a2),d0
		add.w	d0,a0
		add.w	d1,a0		;point to postfix chars

		tst.b	(a0)		;any postfix chars?
		beq.s	SCL_2		;skip if not

		cmp.b	#_1ST_OPCODE,d2	;hit a real 6809 instruction?
		bcc.s	SCL_2a		;skip if so

		lea	deftypes(pc),a1	;get DEFB/W/S/T type
		bsr	GetOpcode
		bpl.s	SCL_3

		move.w	#_ERR_DTYPE,d0
		bra.s	SCL_Done

SCL_2a		bsr	GetReg		;check if postifx chars=reg
		bpl.s	SCL_3		;skip if found

SCL_2b		move.w	#_ERR_ADMODE,d0	;else illegal addressing
		bra.s	SCL_Done		;mode!

SCL_3		move.b	d0,regnum(a6)	;save it

SCL_2		move.l	endptr(a6),a0	;get end pointer
		move.b	endchar(a6),(a0)	;reset char

		bsr	SkipSpace	;find next true char
		beq.s	SCL_4		;null line
		cmp.b	#";",(a0)	;hit comment?
		beq.s	SCL_4		;ignore it
		cmp.b	#_QUOTE,(a0)	;start of text arg?
		bne.s	SCL_2c

		move.l	a0,-(sp)		;save text ptr
		addq.l	#1,a0		;point past quote

SCL_2d		move.b	(a0)+,d0		;get char
		beq.s	SCL_2e		;exit if EOS hit
		cmp.b	#_QUOTE,d0	;hit end quote?
		beq.s	SCL_2e		;skip if so
		cmp.b	#"\",d0		;backslash?
		bne.s	SCL_2d		;scan more chars if not
		addq.l	#1,a0		;point past following char
		bra.s	SCL_2d		;and continue

SCL_2e		clr.b	(a0)		;append end EOS
		bra.s	SCL_2f		;and continue

SCL_2c		move.l	a0,-(sp)		;save ptr to it
		bsr	SkipChars	;find end
		move.l	a0,endptr(a6)	;save ptr to it
		move.b	(a0),endchar(a6)	;save end char
		clr.b	(a0)		;temp EOS

SCL_2f		move.l	(sp)+,a0		;recover start ptr
		move.l	a0,argptr(a6)

		st	gotargs(a6)	;we have an operand


* Here, we've got the values required. Generate the assembly code
* from the obtained information.


SCL_4		bsr	MakeCode		;now generate code

SCL_Done		move.w	d0,error_code(a6)
		rts

SCL_Null		moveq	#0,d0		;here all's well
		rts


* CheckImmediate(a0,a6) -> d0,d1
* a0 = ptr to operand argument to scan
* a6 = ptr to main program variables

* Returns:

* d0	= _ADR_IMM if true immediate operand ("#" found)
*	  -1 if not

* d1	= value of immediate operand if d0=_ADR_IMM

*	  zero if d0=-1 but no error found

*	  error code if d0=-1 and error found


* Tested & works for constants AND labels!

* d0-d5/a0-a3 corrupt


CheckImmediate	move.l	a0,-(sp)		;save text ptr

		cmp.b	#"#",(a0)+	;is it an immediate operand?
		bne.s	CIM_2

		lea	CompOps(pc),a1
		lea	Funcs(pc),a2
		bsr	DoExp		;get its value
		bne.s	CIM_2		;skip if error found

		moveq	#_ADR_IMM,d0	;set addr mode
		bra.s	CIM_1

CIM_2		moveq	#0,d1
		moveq	#-1,d0

CIM_1		move.l	(sp)+,a0
		rts


* CheckReg(a0,a6)
* a0,a6 as for CheckImmediate()

* Check if we have a register list (for such as
* TFR A,DP or PSHS D,X,Y,S)

* Returns:

* d0 = _ADR_INH if inherent addressing, -1 if not register list

* If d0 valid, then postbytes for the TFR/EXG and the push/pop
* instructions are stored in pb_TFR(a6) and pb_PSHS(a6)
* respectively.

* Tested and works for all reg lists!

* d0-d4/a0-a1 corrupt


CheckReg		move.l	a0,-(sp)		;save string ptr

		moveq	#-1,d0		;initial invalid result
		moveq	#0,d1		;initial postbytes

		move.b	d1,pb_TFR(a6)	;save them
		move.b	d1,pb_PSHS(a6)

		move.b	d1,sucheck(a6)	;which one, S or U?

CRG_1		move.l	a0,d4		;copy current string ptr

CRG_2		move.b	(a0)+,d3		;get char
		beq.s	CRG_3		;skip if EOS met
		cmp.b	#",",d3		;hit a comma?
		bne.s	CRG_2		;back for more if not

CRG_4		clr.b	-1(a0)		;EOS out the comma

		exg	d4,a0		;swap pointers
		bsr	GetReg		;found a register?
		bmi.s	CRG_5		;exit with error if not

		move.b	sucheck(a6),d1
		cmp.b	#3,d0		;U register?
		bne.s	CGR_4a		;skip if not
		or.b	#1,d1
CGR_4a		cmp.b	#4,d0		;S register?
		bne.s	CGR_4b		;skip if not
		or.b	#2,d1
CGR_4b		move.b	d1,sucheck(a6)	;set register check

		move.b	pb_TFR(a6),d1
		lsl.b	#4,d1
		add.b	d0,d1
		move.b	d1,pb_TFR(a6)	;create TFR/EXG postbyte

		lea	bitsforPSHS(pc),a1	;table of bits to set
		and.w	#$F,d0			;register no.
		add.w	d0,a1			;point to bit pattern
		move.b	(a1),d0			;get it
		move.b	pb_PSHS(a6),d1		;get postbyte
		or.b	d0,d1
		move.b	d1,pb_PSHS(a6)	;create PSHS ext postbyte

		move.l	d4,a0		;point to next reg
		bra.s	CRG_2

CRG_5		moveq	#-1,d0		;singal failure
		move.l	(sp)+,a0
		rts

CRG_3		move.l	d4,a0		;current string ptr
		bsr	GetReg
		bmi.s	CRG_5

		move.b	sucheck(a6),d1
		cmp.b	#3,d0		;U register?
		bne.s	CGR_5a		;skip if not
		or.b	#1,d1
CGR_5a		cmp.b	#4,d0		;S register?
		bne.s	CGR_5b		;skip if not
		or.b	#2,d1
CGR_5b		move.b	d1,sucheck(a6)	;set register check

		move.b	pb_TFR(a6),d1
		lsl.b	#4,d1
		add.b	d0,d1
		move.b	d1,pb_TFR(a6)	;create TFR/EXG postbyte

		lea	bitsforPSHS(pc),a1
		and.w	#$F,d0
		add.w	d0,a1
		move.b	(a1),d0
		move.b	pb_PSHS(a6),d1
		or.b	d0,d1
		move.b	d1,pb_PSHS(a6)	;create PSHS ext postbyte

		moveq	#_ADR_INH,d0	;signal success

		move.l	(sp)+,a0		;recover string ptr
		rts


bitsforPSHS	dc.b	%00000110	;D = bits 1 & 2
		dc.b	%00010000	;X = bit 4
		dc.b	%00100000	;Y = bit 5
		dc.b	%01000000	;U = bit 6
		dc.b	%01000000	;S = bit 6
		dc.b	%10000000	;PC = bit 7
		dc.b	0,0		;no values for 6,7
		dc.b	%00000010	;A = bit 1
		dc.b	%00000100	;B = bit 2
		dc.b	%00000001	;CC = bit 0
		dc.b	%00001000	;DP = bit 3
		dc.b	0,0,0,0		;no values for C,D,E,F


* CheckIndexed(a0,a6) -> d0,d1
* a0 = ptr to string to check
* a6 = ptr to main program variables

* checks the input string to see if it is a 6809 indexed
* addressing mode operand. All 6809 indexed operands consist
* of the form:

*			offset,R


* where offset is an offset operand, and R is an index register
* (X,Y,U,S usually, PC for PC relative). The comma divides the
* two parts lexically.

* 'offset' can be:

* a constant (e.g. $400);

* a label;

* an accumulator register specifier, either A, B or D.

* 'R' can be:

* An index register X,Y,U,S;

* A postincrement register specifier, e.g., X+ or S++ ;

* A predecrement register specifier, e.g., -Y, --U .


* CheckIndexed() returns:

* d0	= _ADR_IND if operand is a valid 6809 indexed operand
*	  -1 if not

* d1	= ZERO if valid indexed operand

*	  ZERO if not indexed, and no other error found

*	  ERROR CODE if indexed but error found


* Also sets some variables in a6 data table to allow assembly
* to select correct mode.

* Tested for legal ones & works for them.


* d0-d5/d7/a0-a3 corrupt


CheckIndexed	move.l	a0,-(sp)		;save string ptr

		moveq	#0,d0
		move.l	d0,d1		;initially no error
		move.w	d0,indoff(a6)	;initial offset
		move.b	d0,indtype(a6)	;initial type
		move.b	d0,autoskip(a6)	;no X+ / -X initially
		move.b	d0,indreg(a6)

CIX_1		move.b	(a0)+,d0		;get char
		beq	CIX_2		;exit loop if EOS
		cmp.b	#",",d0		;hit comma?
		bne.s	CIX_1

		clr.b	-1(a0)		;temp EOS out comma
		move.l	a0,d7		;save ptr to 2nd part
		move.l	(sp),a0		;recover original string ptr

		tst.b	(a0)		;is it zero offset?
		bne.s	CIX_3		;skip if not

		clr.w	indoff(a6)	;set zero offset

		move.b	#_IX_ZERO,indtype(a6)	;and indexed type

CIX_4		move.l	d7,a0		;get 2nd part of string

		cmp.b	#"-",(a0)	;possible autodecrement?
		beq	CIX_11		;skip if so

		cmp.b	#"+",1(a0)	;possible autoincrement?
		beq	CIX_12		;skip if so

		bsr	GetReg		;find index register
		bmi	CIX_Err1		;oops...

		move.b	d0,indreg(a6)
		cmp.b	#1,d0		;check if X,Y,U,S or PC
		bcs	CIX_Err1		;oops, it isn't!
		cmp.b	#5,d0
		bhi	CIX_Err1
		bne.s	CIX_Done		;skip if not PC relative

;		move.b	indtype(a6),d1	;get current setting
;		cmp.b	#_IX_C5,d1	;& force PC relative
;		beq.s	CIX_18		;(if 5-bit/8-bit offset
;		cmp.b	#_IX_C8,d1	;then force PCR8, else
;		beq.s	CIX_18		;PCR16).

		tst.b	shortlong(a6)	;short or long PC relative?
		beq.s	CIX_18		;skip if short

		move.b	#_IX_PCR16,indtype(a6)	;else long
		clr.b	shortlong(a6)		;next is short
		bra.s	CIX_Done

CIX_18		move.b	#_IX_PCR8,indtype(a6)	;short PC relative
		clr.b	shortlong(a6)		;next is short

CIX_Done		move.l	(sp)+,a0		;recover string ptr

		move.w	#_ADR_IND,d0	;set indexed addressing mode
		rts			;DONE!

CIX_3		bsr	GetReg		;check if accumulator offset
		bmi.s	CIX_15		;skip if it isn't

		tst.w	d0		;D?
		beq.s	CIX_16		;yes
		cmp.w	#8,d0		;A?
		beq.s	CIX_16		;yes
		cmp.w	#9,d0		;B?
		bne	CIX_Err2		;no, oops...

CIX_16		move.w	d0,indoff(a6)	;stick it here!

		move.b	#_IX_ACC,indtype(a6)
		bra	CIX_4			;now get 2nd part

CIX_15		lea	CompOps(pc),a1
		lea	Funcs(pc),a2
		bsr	DoExp		;get offset value
		bne	CIX_Err3		;exit NOW if error!

		tst.l	d1		;offset zero?
		bne.s	CIX_5		;no

		move.b	#_IX_ZERO,indtype(a6)
		bra	CIX_4			;now get 2nd part

CIX_5		move.w	d1,indoff(a6)	;save indexed offset

		bpl.s	CIX_6		;skip if already > 0
		neg.w	d1		;else make absolute value

		cmp.w	#16,d1		;abs(N) > 16?
		bhi.s	CIX_7		;skip if so

		move.b	#_IX_C5,indtype(a6)	;else 5-bit offset
		bra	CIX_4			;now get 2nd part

CIX_7		cmp.w	#128,d1		;abs(N) > 128?
		bhi.s	CIX_8		;skip if so

		move.b	#_IX_C8,indtype(a6)	;else 8-bit offset
		bra	CIX_4			;now get 2nd part

CIX_8		move.b	#_IX_C16,indtype(a6)	;here 16-bit offset
		bra	CIX_4			;now get 2nd part

CIX_6		cmp.w	#15,d1		;5-bit offset?
		bhi.s	CIX_9		;no

		move.b	#_IX_C5,indtype(a6)	;here 5-bit offset
		bra	CIX_4			;now get 2nd part

CIX_9		cmp.w	#127,d1		;8-bit offset?
		bhi.s	CIX_10		;no

		move.b	#_IX_C8,indtype(a6)	;here 8-bit offset
		bra	CIX_4			;now get 2nd part

CIX_10		move.b	#_IX_C16,indtype(a6)	;here 16-bit offset
		bra	CIX_4			;now get 2nd part

CIX_11		move.b	#1,autoskip(a6)	;autoincrement size
		addq.l	#1,a0		;point past 1st "-"
		cmp.b	#"-",(a0)	;is it --X etc?
		bne.s	CIX_13		;no
		addq.l	#1,a0		;else point past 2nd "-"
		move.b	#2,autoskip(a6)	;autoincrement size
CIX_13		bsr	GetReg		;check register no.
		bmi.s	CIX_Err1		;oops...

		cmp.b	#1,d0		;check if reg X,Y,U or S
		bcs.s	CIX_Err1		;oops...
		cmp.b	#4,d0
		bhi.s	CIX_Err1		;again oops...

		move.b	d0,indreg(a6)	;set index reg no

		move.b	#_IX_AUTODEC,indtype(a6)
		bra	CIX_Done

CIX_12		move.b	#1,autoskip(a6)
		cmp.b	#"+",2(a0)	;is is X++ etc?
		bne.s	CIX_14		;no
		move.b	#2,autoskip(a6)
CIX_14		clr.b	1(a0)		;EOS out the "+"'s

		bsr	GetReg		;check which register
		bmi.s	CIX_Err1		;oops...

		cmp.b	#1,d0		;check if reg X,Y,U or S
		bcs.s	CIX_Err1		;oops...
		cmp.b	#4,d0
		bhi.s	CIX_Err1		;again oops...

		move.b	d0,indreg(a6)	;set index reg no

		move.b	#_IX_AUTOINC,indtype(a6)
		bra	CIX_Done

CIX_Err3		move.w	d0,d1		;expression error hit
		move.b	#_IX_C16,d1
		clr.w	indoff(a6)
		bra.s	CIX_2

CIX_Err2		moveq	#_ERR_ACC,d1	;illegal accumulator

		move.b	#_IX_ACC,indtype(a6)
		clr.w	indoff(a6)
		bra.s	CIX_2

CIX_Err1		moveq	#_ERR_INDX,d1	;illegal index register

		move.b	#_IX_ZERO,indtype(a6)
		
CIX_2		move.l	(sp)+,a0		;recover string ptr
		moveq	#-1,d0		;signal failure
		rts			;and done


* CheckDirect(a0,a6) -> d0,d1
* a0 = ptr to string to scan
* a6 = ptr to main program variables

* Check for a direct addressing mode operand.

* Again, return the standard values in d0/d1 as for
* CheckIndexed() etc. this time, d0 = _ADR_DIR if direct
* page operand found and d1 is its value.

* d0-d5/d7/a0-a3 corrupt


CheckDirect	move.l	a0,-(sp)		;save string ptr

		moveq	#-1,d0		;initial return values
		moveq	#0,d1

		cmp.b	#"<",(a0)+	;direct addressing?
		bne.s	CDR_Done		;no, exit

		bsr	DoExp		;get its value
		beq.s	CDR_1		;skip if we've got it

		move.w	d0,d1
		moveq	#-1,d0		;else signal error
		bra.s	CDR_Done		;and exit

CDR_1		moveq	#_ADR_DIR,d0	;signal found

CDR_Done		tst.w	d0
		move.l	(sp)+,a0
		rts


* CheckExtended(a0,a6) -> d0,d1
* a0 = ptr to string to scan
* a6 = ptr to main program variables

* Check for an extended addressing mode operand.

* Again, return the standard values in d0/d1 as for
* CheckIndexed() etc. this time, d0 = _ADR_EXT if extended
* operand found and d1 is its value.

* d0-d5/d7/a0-a3 corrupt


CheckExtended	move.l	a0,-(sp)		;save string ptr

		moveq	#-1,d0		;initial return values
		moveq	#0,d1

		cmp.b	#">",(a0)	;extended addressing?
		bne.s	CEX_1		;not explicitly
		addq.l	#1,a0		;skip past ">" specifier

CEX_1		bsr	DoExp		;get its value
		beq.s	CEX_2		;skip if we've got it

		move.w	d0,d1
		moveq	#-1,d0		;else signal error
		bra.s	CEX_Done		;and exit

CEX_2		moveq	#_ADR_EXT,d0	;signal found

CEX_Done		tst.w	d0
		move.l	(sp)+,a0
		rts



* CheckIndirect(a0,a6) -> d0,d1
* a0 = ptr to string to scan
* a6 = ptr to main program variables

* Check for an indirect operand.

* Returns:

* d0	= -1 if not indirect (or error found)

*	  addr mode of [...] contents + $80 if valid indirect

* d1	= ZERO if valid indirect

*	  ZERO if NOT an indirect at all

*	  ERROR CODE if indirect parsing error (e.g., missing "]")

*	  VALUE of [...] contents if INDIRECT EXTENDED.

* d0-d5/d7/a0-a3 corrupt


CheckIndirect	move.l	a0,-(sp)		;save string pointer

		moveq	#-1,d0		;initial return values
		moveq	#0,d1

		cmp.b	#"[",(a0)+	;possible indirect?
		bne.s	CID_Done		;exit NOW if not

CID_1		move.b	(a0)+,d0		;find end "]"
		beq.s	CID_Err1		;EOS hit. Oops...
		cmp.b	#"]",d0		;found it?
		bne.s	CID_1		;back for more chars if not

		clr.b	-1(a0)		;EOS out the "]"
		move.l	(sp),a0		;recover char pointer
		addq.l	#1,a0		;point past "["

		bsr	CheckIndexed	;indexed operand?
		bpl.s	CID_3		;skip if so

		tst.w	d1		;error found?
		beq.s	CID_4		;no, just not indexed
		bra.s	CID_Done		;else exit with error

CID_3		cmp.b	#_IX_AUTOINC,indtype(a6)	;autoincrement?
		bne.s	CID_1a			;skip if not

		cmp.b	#1,autoskip(a6)		;,X+ etc?
		bne.s	CID_1b			;skip if not

		moveq	#_ERR_ADMODE,d1
		moveq	#-1,d0
		bra.s	CID_Done		;else exit with error

CID_1a		cmp.b	#_IX_AUTODEC,indtype(a6)	;autodecrement?
		bne.s	CID_1b			;skip if not

		cmp.b	#1,autoskip(a6)		;,-X etc?
		bne.s	CID_1b			;skip if not

		moveq	#_ERR_ADMODE,d1
		moveq	#-1,d0
		bra.s	CID_Done		;else exit with error

CID_1b		add.w	#_ADR_PTR,d0	;signal indexed indirect
		bra.s	CID_Done		;and bye-bye

CID_4		bsr	CheckExtended	;extended operand?
		bpl.s	CID_5		;skip if so

		tst.w	d1		;error found?
		bne.s	CID_Done		;yes-exit NOW

		move.w	#_ERR_ADMODE,d1	;it's an error anyway
		bra.s	CID_Done

CID_5		add.w	#_ADR_PTR,d0	;signal indirect extended
		bra.s	CID_Done

CID_Err1		move.b	#"]",errchar+1(a6)
		move.b	#_ERR_CHAR,d1

CID_Done		tst.w	d0		;ensure correct flags set!
		move.l	(sp)+,a0
		rts


* Type2Addr(a0,a6) -> d0
* a0 = ptr to operand string to analyse
* a6 = ptr to main program variables

* Check addressing mode for type 2 instructions (e.g. CLR)
* if an operand exists. Branches through into Type1Addr()
* below to do its main work if an operand exists.

* d0-d5/d7/a0-a3 corrupt


Type2Addr	tst.b	gotargs(a6)	;got an operand?
		bne.s	T2A		;test it if so

		moveq	#0,d0		;else no operand
		rts			;so return no error


* Type1Addr(a0,a6) -> d0
* a0 = ptr to operand string to analyse
* a6 = ptr to main program variables

* Check addressing mode for type 1 instructions
* (e.g., LDA)

* Returns :

* d0 = 0 if ok, else error code

* Also check Tyep 2 addressing modes for those instructions
* such as CLR, COM etc.

* d0-d5/d7/a0-a3 corrupt


Type1Addr	tst.b	gotargs(a6)	;operand to test?
		beq.s	T1A_6

T2A		bsr	CheckImmediate	;immediate operand?
		bmi.s	T1A_1		;skip if not (or error)

		move.w	d0,addrmode(a6)
		move.w	d1,operand(a6)
		moveq	#0,d0
		rts

T1A_1		tst.w	d1		;immediate error?
		bne.s	T1A_Error	;exit NOW if so

		bsr	CheckIndirect	;indirect operand?
		bmi.s	T1A_2

		move.w	d0,addrmode(a6)
		move.w	d1,operand(a6)	;in case extended indirect

		cmp.b	#_IX_C5,indtype(a6)	;[2,X] etc?
		bne.s	T1A_1A
		move.b	#_IX_C8,indtype(a6)	;change 5-bit to 8-bit

T1A_1A		moveq	#0,d0
		rts

T1A_2		tst.w	d1		;indirect error?
		bne.s	T1A_Error	;exit NOW if so

		bsr	CheckIndexed	;indexed operand?
		bmi.s	T1A_3		;skip if not (or error)

		move.w	d0,addrmode(a6)
		moveq	#0,d0
		rts

T1A_3		tst.w	d1		;indexed error?
		bne.s	T1A_Error	;exit NOW if so

		bsr	CheckDirect	;direct page?
		bmi.s	T1A_4		;skip if not

		move.w	d0,addrmode(a6)
		move.w	d1,operand(a6)
		moveq	#0,d0
		rts

T1A_4		tst.w	d1		;direct page error?
		bne.s	T1A_Error

		bsr	CheckExtended	;extended address?
		bmi.s	T1A_5		;skip if not

		move.w	d0,addrmode(a6)
		move.w	d1,operand(a6)
		moveq	#0,d0
		rts

		tst.w	d1		;error?
		bne.s	T1A_Error	;skip if so

T1A_5		move.w	#_ERR_ADMODE,d0	;illegal addressing mode!
		rts

T1A_6		move.w	#_ERR_MISSING,d0	;missing operand
		rts

T1A_Error	move.w	d1,d0
		rts


* WhichReg(a0,a6) -> d0
* a0 = ptr to string to scan
* a6 = ptr to main program variables

* Get register postbyte values for TFR/PSHS etc.

* Returns:

* d0 = 0 if all's well, -1 if not

* d0-d4/a0-a1 corrupt


WhichReg		bsr	CheckReg
		bmi.s	WCHR_1

		move.w	d0,addrmode(a6)
		moveq	#0,d0

WCHR_1		rts


* WhichImm(a0,a6) -> d0
* a0 = ptr to string to scan
* a6 = ptr to main program variables

* Get value of immediate operand for CWAI.

* d0-d5/a0-a3 corrupt


WhichImm		bsr	CheckImmediate
		bmi.s	WIMM_1

		move.w	d0,addrmode(a6)
		move.w	d1,operand(a6)
		moveq	#0,d0

WIMM_1		rts


* WhichSWI(a0,a6) -> d0
* a0 = ptr to string
* a6 = ptr to main vars

* d0-d5/a0-a3 corrupt


WhichSWI		tst.b	gotargs(a6)	;any operand?
		beq.s	WSWI_2		;no, so OK

		bsr	CheckExtended	;else check this
		bmi.s	WSWI_1

		move.w	d0,addrmode(a6)
		move.w	d1,operand(a6)
WSWI_2		moveq	#0,d0

WSWI_1		rts



* GetOpts(a0,a6) -> d0
* a0 = ptr to string to scan
* a6 = ptr to main program variables

* Set options byte according to OPT directive.
* Will ONLY perform this function on Pass 2.

* d0-d2/d4/a1 corrupt


GetOpts		cmp.b	#2,pass(a6)	;pass 2?
		bne.s	GOPT_8		;exit NOW if not

		move.l	a0,-(sp)		;save string ptr

		moveq	#-1,d0		;initial error value
		moveq	#0,d1		;options byte
		move.b	options(a6),d1	;plus any previously set/clr'd

GOPT_1		move.l	a0,d4		;save ptr to current arg

GOPT_2		move.b	(a0)+,d2		;get char
		beq.s	GOPT_3		;EOS hit-continue
		cmp.b	#",",d2		;hit separating comma?
		bne.s	GOPT_2		;back for more chars if not

		clr.b	-1(a0)		;EOS out the comma
		exg	a0,d4		;save ptr to next arg

		lea	optlist(pc),a1
		move.w	d1,-(sp)
		bsr	GetOpcode	;find options
		move.w	(sp)+,d1
		tst.w	d0
		bmi.s	GOPT_Err1	;illegal option

;		move.l	d4,a0
;		subq.l	#2,a0		;point to +/-
		addq.l	#1,a0		;point to +/-
		cmp.b	#"+",(a0)	;+ option?
		bne.s	GOPT_4

		bset	d0,d1		;set appropriate bit
		bra.s	GOPT_5

GOPT_4		cmp.b	#"-",(a0)	;- option?
		bne.s	GOPT_5

		bclr	d0,d1		;clear appropriate bit

GOPT_5		move.l	d4,a0		;point to next arg
		bra.s	GOPT_1		;and resume scan

GOPT_3		move.l	d4,a0		;point to last arg

		lea	optlist(pc),a1
		move.w	d1,-(sp)
		bsr	GetOpcode	;find options
		move.w	(sp)+,d1
		tst.w	d0
		bmi.s	GOPT_Err1	;illegal option

;		move.l	d4,a0
;		subq.l	#2,a0		;point to +/-
		addq.l	#1,a0		;point to +/-
		cmp.b	#"+",(a0)	;+ option?
		bne.s	GOPT_6

		bset	d0,d1		;set appropriate bit
		bra.s	GOPT_7

GOPT_6		cmp.b	#"-",(a0)	;- option?
		bne.s	GOPT_7

		bclr	d0,d1		;clear appropriate bit

GOPT_7		move.b	d1,options(a6)

		move.l	(sp)+,a0		;recover string ptr
GOPT_8		moveq	#0,d0
		rts

GOPT_Err1	moveq	#_ERR_OPT,d0
		rts


* WhichRel(a0,a6) -> d0
* a0 = ptr to string to parse
* a6 = ptr to main program variables

* Check for relative operand (either direct or extended)

* Returns:

* d0 = 0 if all's well
* d0 = error code if error

* d0-d5/a0-a3 corrupt


WhichRel		bsr	CheckDirect		;direct operand?
		bmi.s	WREL_1			;skip if not

WREL_3		move.w	d1,operand(a6)		;save value
		move.w	#_ADR_SREL,addrmode(a6)	;short rel branch
		moveq	#0,d0			;signal OK
		rts

WREL_1		tst.w	d1			;direct error?
		beq.s	WREL_2			;skip if not

WREL_4		clr.w	operand(a6)
		move.w	#_ADR_SREL,addrmode(a6)
		move.w	d1,d0
		rts

WREL_2		bsr	CheckExtended		;extended operand?
		bpl.s	WREL_3			;skip if so

		bra.s	WREL_4			;else report error


* MakeCode(a6)
* a6 = ptr to main program variables

* Perform actual machine code generation for a given
* set of parameters (opcode number, address mode etc).

* d0/a0 corrupt


MakeCode		moveq	#0,d0
		move.w	opcodenum(a6),d0		;opcode number
		add.l	d0,d0
		add.l	d0,d0			;jump table offset
		lea	AdModeTable(pc),a3
		add.l	d0,a3			;ptr to ptr
		move.l	(a3),d0			;ptr to routine
		beq.s	MakeCode_1		;skip if nonexistent
		move.l	d0,a3
		jsr	(a3)			;execute it!

MakeCode_1	move.w	d0,-(sp)			;save any error

		moveq	#0,d0
		move.w	opcodenum(a6),d0		;opcode number
		add.l	d0,d0
		add.l	d0,d0			;jump table offset
		lea	MakeMC(pc),a3
		add.l	d0,a3			;ptr to ptr
		move.l	(a3),d0			;ptr to routine
		beq.s	MakeCode_2		;skip if nonexistent
		move.l	d0,a3
		jsr	(a3)			;execute it!

MakeCode_2	move.w	(sp)+,d1			;get 1st error
		beq.s	MakeCode_3		;none, so skip

		move.w	d1,d0			;else signal this
		rts

MakeCode_3	tst.w	d0			;signal IF 2nd error!
		rts


* HandleORG(a0,a6) -> d0
* a0 = ptr to string to scan
* a6 = ptr to main program variables

* Obtain value for ORG directive & condition internal
* PC value of assembler to suit.

* Returns d0=0 if all's well, else error code

* d0-d5/d7/a0-a3 corrupt


HandleORG	bsr	DoExp		;get value
		bne.s	HORG_1		;skip if error

		move.w	d1,pc_value(a6)	;set PC value
		tst.w	d0		;and ensure no error signalled

HORG_1		rts


* HandleSETDP(a0,a6) -> d0
* a0 = ptr to string to scan
* a6 = ptr to main program variables

* obtain value for SETDP directive & condition internal
* direct page counter to suit.

* Returns d0=0 if all's well, else error code

* d0-d5/d7/a0-a3 corrupt


HandleSETDP	bsr	DoExp		;get value
		bne.s	HSDP_1		;skip if error

;		lsr.w	#8,d1		;get high byte

		move.b	d1,dpage(a6)	;save DPAGE value

		tst.w	d0		;and ensure no error signalled

HSDP_1		rts


* HandleEQU(a0,a6) -> d0
* a0 = ptr to value to set label equal to
* a6 = ptr to main program variables

* d0-d5/d7/a0-a3 corrupt


HandleEQU	bsr	DoExp		;get value
		bne.s	HEQU_1		;skip if error

		move.l	currlabel(a6),a1	;point to symtab entry
		add.w	#_LABELSIZE+1,a1	;point to data entry
		move.w	d1,(a1)		;save value

		tst.w	d0

HEQU_1		rts


* ReadLine(a6) -> d0
* a6 = ptr to main program variables
* Read a line of characters from source file

* Returns:

* d0 = 0 if line read, -1 if EOF

* d0-d3/a0 corrupt


ReadLine		move.l	linestart(a6),a0	;buffer starts here

ReadLine_1	move.l	a0,d2		;read for DOS read

ReadLine_2	move.l	d2,-(sp)		;save buffer ptr
		move.l	src_handle(a6),d1	;this file
		moveq	#1,d3		;1 char at a time
		CALLDOS	Read		;get the char
		tst.l	d0		;hit EOF?
		bmi.s	ReadLine_3	;exit if so
		beq.s	ReadLine_3	;ditto

		move.l	(sp)+,d2
		move.l	d2,a0		;point at char
		move.b	(a0)+,d1		;fetch char
		move.l	a0,d2		;save ptr to next pos
		cmp.b	#9,d1		;char = TAB?
		beq.s	ReadLine_2	;read another if so
		cmp.b	#" ",d1		;char = space or higher?
		bcc.s	ReadLine_2	;read another if so
		cmp.b	#$0A,d1		;hit Linefeed?
		bne.s	ReadLine_2	;keep reading until hit

		clr.b	-1(a0)		;force EOS into buffer
		moveq	#0,d0		;signal line read
		rts

ReadLine_3	move.l	(sp)+,d2		;tidy the stack
		moveq	#-1,d0		;signal EOF hit
		rts


* CopyLine(a0,a1,d0)
* a0 = ptr to string to copy
* a1 = ptr to buffer to copy it to
* d0 = tab stops

* d1-d4/a0-a2 corrupt


CopyLine		moveq	#0,d1		;initial char count
		move.w	d0,d2		;copy tab stops
		move.b	#" ",d4		;padding space for speed

		move.l	a1,a2		;copy dest pointer

CLL_1		move.b	(a0)+,d3		;get char
		beq.s	CLL_Done		;exit if EOS hit
		cmp.b	#";",d3		;hit a comment?
		beq.s	CLL_4		;exit if so
		cmp.b	#9,d3		;TAB hit?
		bne.s	CLL_2		;skip if not
CLL_3		move.b	d4,(a1)+		;insert padding space
		addq.w	#1,d1		;update char count
		cmp.w	d0,d1		;hit tab stop?
		bls.s	CLL_3		;back for more if not
		add.w	d2,d0		;set next tab stop
		bra.s	CLL_1		;and continue copying
CLL_2		move.b	d3,(a1)+		;copy char
		addq.w	#1,d1		;char count
		cmp.w	d0,d1		;hit a tab stop?
		bls.s	CLL_1		;back for more if not
		add.w	d2,d0		;else next tab stop
		bra.s	CLL_1		;and resume copying
CLL_Done		clr.b	(a1)		;append final EOS
		rts

CLL_4		cmp.l	a1,a2		;pointers still same?
		beq.s	CLL_Done		;skip if so

		move.b	-(a1),d3		;get char
		beq.s	CLL_5		;exit if EOS hit

		cmp.b	#" ",d3		;hit a preceding space?
		beq.s	CLL_4		;skip back if so
		cmp.b	#9,d3		;hit a tab char? (shouldn't!)
		beq.s	CLL_4		;skip back if so

		addq.l	#1,a1		;else point past non-space char
		clr.b	(a1)		;append EOS
CLL_5		rts			;and done


* ListLine(a6)
* a6 = ptr to main program variables

* List out the assembled line.

* Assume ALL registers corrupt!


ListLine		nop

		move.w	oldpc_value(a6),d0
		bsr	PrintHexW

		moveq	#1,d0
		bsr	PrintSpaces

		move.b	opsize(a6),d7	;got any opcodes?
		beq.s	LLL_1

		lea	instruction(a6),a5

LLL_2		move.w	d7,-(sp)

		move.b	(a5)+,d0		;list opcodes
		bsr	PrintHexB

		move.w	(sp)+,d7
		subq.b	#1,d7
		bne.s	LLL_2

LLL_1		moveq	#12,d0		;padding spaces
		moveq	#0,d1
		move.b	opsize(a6),d1
		add.w	d1,d1
		sub.w	d1,d0
		bsr	PrintSpaces

		btst	#4,options(a6)	;show timings?
		beq.s	LLL_4

		moveq	#0,d0
		move.b	totime(a6),d0	;any timing data?
		bne.s	LLL_7		;skip if so
		moveq	#0,d6		;else 6 spaces
		bra.s	LLL_5		;and skip

LLL_7		move.l	spacebuf(a6),a0
		move.l	a0,-(sp)
		bsr	ItoAR		;create string
		clr.b	(a0)
		move.l	(sp)+,a0
		move.l	cli_out(a6),d1
		bsr	PString		;print it out

		move.l	d7,d6		;save total chars printed

		tst.b	timinc(a6)	;print a "+"?
		beq.s	LLL_6		;skip if not

		addq.l	#1,d6

		lea	plus_sign(pc),a0
		move.l	cli_out(a6),d1
		bsr	PString		;print it if so

LLL_6		moveq	#0,d0
		move.b	totime2(a6),d0	;2nd timing?
		beq.s	LLL_5		;skip if not

		move.l	spacebuf(a6),a0	;else pop in
		move.b	#"/",(a0)+	;separator
		move.l	a0,-(sp)
		bsr	ItoAR		;create string for 2nd time
		clr.b	(a0)
		move.l	(sp)+,a0
		subq.l	#1,a0		;point to "/"
		move.l	cli_out(a6),d1
		bsr	PString		;print it out

		add.l	d7,d6		;total chars

LLL_5		moveq	#0,d0
		neg.w	d6
		addq.w	#6,d6
		move.w	d6,d0
		bsr	PrintSpaces

		moveq	#1,d0
		bsr	PrintSpaces

LLL_4		move.l	liststart(a6),a0	;show text line
		move.l	cli_out(a6),d1
		bsr	PString

		moveq	#1,d0
		bsr	LineFeeds

		rts


* ReportError(a6)
* a6 = ptr to main program variables
* Report any errors that are detected.

* d0-d3/d7/a0 corrupt


ReportError	move.w	error_code(a6),d0		;which error?
		beq	RER_Done			;skip if none

		cmp.b	#2,pass(a6)		;pass 2?
		bne.s	RER_1A			;skip if not

		addq.l	#1,errcount(a6)		;update error count

		btst	#2,options(a6)		;line listing on?
		bne.s	RER_1A			;skip if so-done it!

		move.w	d0,-(sp)		;else list line that
		bsr	ListLine		;is not yet listed
		move.w	(sp)+,d0

RER_1A		lea	errors(pc),a0		;point to texts

RER_1		subq.w	#1,d0		;this one?
		beq.s	RER_2		;skip if yes

RER_3		tst.b	(a0)+		;else skip to next text
		bne.s	RER_3
		bra.s	RER_1		;and go back for next

RER_2		move.l	cli_out(a6),d1
		bsr	PString

		move.b	errchar+1(a6),d0	;error char to list?
		beq.s	RER_4		;skip if not

		lea	errchar(a6),a0	;print error char
		move.l	a0,d2		;in "" quotes
		moveq	#4,d3
		move.l	cli_out(a6),d1
		CALLDOS	Write

RER_4		move.w	error_code(a6),d0
		cmp.w	#_ERR_NOMEM,d0	;fatal error?
		bcc.s	RER_5		;skip if so

		lea	report(pc),a0	;print "At Line "
		move.l	cli_out(a6),d1
		bsr	PString

		move.l	linenum(a6),d0	;current line number
		lea	numbuf(a6),a0
		bsr	LtoA		;create ASCII digit string

		move.l	cli_out(a6),d1	;print it out to here
		bsr	PString

RER_5		moveq	#1,d0
		bsr	LineFeeds

		btst	#1,options(a6)	;wait on error?
		beq.s	RER_6

		lea	waiterr(pc),a0	;print "Press key..."
		move.l	cli_out(a6),d1	;message
		bsr	PString

		nop			;echo off

RER_7		move.l	#500000,d2	;wait for a key press
		move.l	cli_in(a6),d1
		CALLDOS	WaitForChar

		tst.l	d0		;got a key?
		beq.s	RER_7		;back if not

		moveq	#1,d3		;get 1 char
		move.l	spacebuf(a6),d2	;buffer here
		move.l	cli_in(a6),d1	;from CLI
		CALLDOS	Read

		move.l	spacebuf(a6),a0	;point to char
		cmp.b	#$0A,(a0)	;got ENTER?
		bne.s	RER_8		;skip if not
		clr.b	abort(a6)	;signal NOT aborting!
		bra.s	RER_6		;and exit
RER_8		cmp.b	#27,(a0)		;ESC?
		bne.s	RER_7		;back if not
		st	abort(a6)	;signal aborting & exit...

RER_6		nop			;echo on

		clr.w	error_code(a6)	;ready for next error!

RER_Done		rts


* ShowSymbols(a6)
* a6 = ptr to main program variables

* Display symbol table.

* Assume ALL registers corrupt.


ShowSymbols	moveq	#_LABELSIZE,d6
		addq.l	#3,d6		;table entry size

		moveq	#0,d5		;format counter

		move.l	symtab(a6),a0	;start of table

SSYM_1		move.l	a0,-(sp)

		tst.b	(a0)		;entry in table?
		beq.s	SSYM_2		;skip if not

		move.l	cli_out(a6),d1	;print out symtab entry
		bsr	PString

		neg.w	d7
		add.w	#_LABELSIZE+1,d7	;no of padding chars req'd
		beq.s	SSYM_4		;skip if none needed
		move.b	#".",d0

		move.l	linestart(a6),a0	;create padding
SSYM_3		move.b	d0,(a0)+
		subq.w	#1,d7
		bne.s	SSYM_3

		clr.b	(a0)

		move.l	linestart(a6),a0
		move.l	cli_out(a6),d1
		bsr	PString		;print out padding

SSYM_4		move.l	(sp),a0		;recover symtab ptr
		add.w	#_LABELSIZE+1,a0	;point to address entry
		move.w	(a0),d0
		bsr	PrintHexW	;display address

		addq.w	#1,d5		;done a whole line?
		cmp.w	symbol_fmt(a6),d5
		bne.s	SSYM_5		;skip if not

		moveq	#0,d5		;reset counter
		moveq	#1,d0
		bsr	LineFeeds	;do a line feed
		bra.s	SSYM_2		;and back for more

SSYM_5		move.l	linestart(a6),a0
		move.b	#" ",d0
		moveq	#4,d7

SSYM_6		move.b	d0,(a0)+
		subq.w	#1,d7
		bne.s	SSYM_6

		clr.b	(a0)

		move.l	linestart(a6),a0
		move.l	cli_out(a6),d1
		bsr	PString

SSYM_2		move.l	(sp)+,a0		;recover ptr
		add.w	d6,a0

		move.l	a0,d0
		sub.l	symtab(a6),d0	;check if hit
		sub.l	#65536,d0	;end of symbol table

		bmi.s	SSYM_1

		rts


* LineFeeds(d0)
* d0 = no of linefeeds wanted (30 max)

* d1-d3/d7/a0 corrupt


LineFeeds	lea	crlf_end(pc),a0
		move.l	d0,d3
		sub.l	d0,a0
		move.l	a0,d2
		move.l	cli_out(a6),d1
		CALLDOS	Write

		rts


* PrintSpaces(d0)
* d0 = no of spaces to print (30 max)

* d1-d3/d7/a0 corrupt


PrintSpaces	lea	sp_end(pc),a0
		move.l	d0,d3
		sub.l	d0,a0
		move.l	a0,d2
		move.l	cli_out(a6),d1
		CALLDOS	Write

		rts


* PString(a0,d1)
* a0 = ptr to string to print
* d1 = output device to print to

* Print string to given output device
* unless it's zero chars long...

* d2-d3/d7/a0 corrupt


PString		bsr	StrLen
		tst.l	d7
		beq.s	PString_1
		move.l	d7,d3
		move.l	a0,d2
		CALLDOS	Write

PString_1	rts


* WriteObject(a6)
* a6 = ptr to main program variables

* Writes out the generated object code to the
* designated object file.


* d0-d3/a0 corrupt


WriteObject	move.b	opsize(a6),d0	;any instruction opcodes?
		beq.s	WOBJ_1		;skip if not

		lea	instruction(a6),a0	;ptr to opcodes
		move.l	prog_pos(a6),a1

WOBJ_3		move.b	(a0)+,(a1)+	;copy to program buffer
		subq.b	#1,d0		;this amny bytes
		bne.s	WOBJ_3

		move.l	a1,prog_pos(a6)	;save new prog position

		rts

WOBJ_1		move.w	defcount(a6),d0	;any reserved/defined data?
		beq.s	WOBJ_2

		move.l	defarea(a6),a0
		move.l	prog_pos(a6),a1

WOBJ_4		move.b	(a0)+,(a1)+	;copy to program buffer
		subq.b	#1,d0		;this amny bytes
		bne.s	WOBJ_4

		move.l	a1,prog_pos(a6)	;save new prog position

WOBJ_2		rts


* ShowDebug()

* To be taken out after debugging...


ShowDebug	lea	_db_1(pc),a0
		move.l	cli_out(a6),d1
		bsr	PString

		move.w	opcodenum(a6),d0
		bsr	PrintHexW

		lea	_db_2(pc),a0
		move.l	cli_out(a6),d1
		bsr	PString

		move.w	addrmode(a6),d0
		bsr	PrintHexW

		moveq	#1,d0
		bsr	LineFeeds

		lea	_db_3(pc),a0
		move.l	cli_out(a6),d1
		bsr	PString

		moveq	#0,d0
		move.b	indreg(a6),d0
		bsr	PrintHexW

		lea	_db_4(pc),a0
		move.l	cli_out(a6),d1
		bsr	PString

		move.w	indoff(a6),d0
		bsr	PrintHexW

		moveq	#1,d0
		bsr	LineFeeds

		lea	_db_5(pc),a0
		move.l	cli_out(a6),d1
		bsr	PString

		move.w	operand(a6),d0
		bsr	PrintHexW

		lea	_db_6(pc),a0
		move.l	cli_out(a6),d1
		bsr	PString

		move.w	indoff(a6),d0
		bsr	PrintHexW

		moveq	#1,d0
		bsr	LineFeeds

		lea	_db_7(pc),a0
		move.l	cli_out(a6),d1
		bsr	PString

		moveq	#0,d0
		move.b	indtype(a6),d0
		bsr	PrintHexW

		lea	_db_8(pc),a0
		move.l	cli_out(a6),d1
		bsr	PString

		moveq	#0,d0
		move.b	autoskip(a6),d0
		bsr	PrintHexW

		moveq	#1,d0
		bsr	LineFeeds

		lea	_db_9(pc),a0
		move.l	cli_out(a6),d1
		bsr	PString

		moveq	#0,d0
		move.b	regnum(a6),d0
		bsr	PrintHexW

		moveq	#1,d0
		bsr	LineFeeds

		lea	_db_10(pc),a0
		move.l	cli_out(a6),d1
		bsr	PString

		lea	instruction(a6),a5
		moveq	#0,d7
		move.b	opsize(a6),d7
		beq.s	ShowDB_1

ShowDB_2		move.w	d7,-(sp)
		moveq	#0,d0
		move.b	(a5)+,d0
		bsr	PrintHexB

		moveq	#1,d0
		bsr	PrintSpaces

;		lea	_db_99(pc),a0
;		move.l	cli_out(a6),d1
;		bsr	PString		

		move.w	(sp)+,d7

		subq.b	#1,d7
		bne.s	ShowDB_2

ShowDB_1		moveq	#2,d0
		bsr	LineFeeds

		rts


* Address mode jump table


AdModeTable	dc.l	HandleORG	;ORG
		dc.l	HandleEQU
		dc.l	0
		dc.l	0
		dc.l	GetOpts
		dc.l	HandleSETDP
		dc.l	0
		dc.l	Do_LONG		;LONG
		dc.l	Do_SHORT		;SHORT
		dc.l	0
		dc.l	0
		dc.l	0

		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		;MACRO

		dc.l	0		;ABX
		dc.l	Type1Addr
		dc.l	Type1Addr
		dc.l	Type1Addr
		dc.l	Type2Addr
		dc.l	Type2Addr
		dc.l	WhichRel
		dc.l	WhichRel

		dc.l	WhichRel		;BEQ
		dc.l	WhichRel
		dc.l	WhichRel
		dc.l	WhichRel
		dc.l	WhichRel
		dc.l	Type1Addr
		dc.l	WhichRel
		dc.l	WhichRel

		dc.l	WhichRel		;BLS
		dc.l	WhichRel
		dc.l	WhichRel
		dc.l	WhichRel
		dc.l	WhichRel
		dc.l	WhichRel
		dc.l	WhichRel
		dc.l	WhichRel

		dc.l	WhichRel		;BVC
		dc.l	WhichRel
		dc.l	Type2Addr
		dc.l	Type1Addr
		dc.l	Type2Addr
		dc.l	WhichImm
		dc.l	0
		dc.l	Type2Addr

		dc.l	Type1Addr	;EOR
		dc.l	WhichReg
		dc.l	Type2Addr
		dc.l	Type1Addr
		dc.l	Type2Addr
		dc.l	Type1Addr
		dc.l	Type1Addr
		dc.l	Type2Addr

		dc.l	Type2Addr	;LSR
		dc.l	0
		dc.l	Type2Addr
		dc.l	0
		dc.l	Type1Addr
		dc.l	WhichReg
		dc.l	WhichReg
		dc.l	WhichReg

		dc.l	WhichReg		;PULU
		dc.l	Type2Addr
		dc.l	Type2Addr
		dc.l	0
		dc.l	0
		dc.l	Type1Addr
		dc.l	0
		dc.l	Type1Addr

		dc.l	Type1Addr	;SUB
		dc.l	WhichSWI
		dc.l	0
		dc.l	WhichReg
		dc.l	Type2Addr


* Jump table for assembly. Once the values exist in the variable
* table to create the opcodes, these routines are called using a
* JSR (An) type instruction.


MakeMC		dc.l	0		;ORG, 0
		dc.l	0
		dc.l	Do_DEF
		dc.l	Do_RES
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	Do_LONG		;LONG
		dc.l	Do_SHORT		;SHORT
		dc.l	0
		dc.l	0
		dc.l	0

		dc.l	0		;ENDIF, 10
		dc.l	0
		dc.l	0
		dc.l	0

		dc.l	Do_ABX		;ABX, 16
		dc.l	Do_ADC
		dc.l	Do_ADC
		dc.l	Do_ADC
		dc.l	Do_CLR
		dc.l	Do_CLR
		dc.l	Do_BRA
		dc.l	Do_BRA

		dc.l	Do_BRA		;BEQ, 22
		dc.l	Do_BRA
		dc.l	Do_BRA
		dc.l	Do_BRA
		dc.l	Do_BRA
		dc.l	Do_BIT
		dc.l	Do_BRA
		dc.l	Do_BRA

		dc.l	Do_BRA		;BLS, 30
		dc.l	Do_BRA
		dc.l	Do_BRA
		dc.l	Do_BRA
		dc.l	Do_BRA
		dc.l	Do_BRA
		dc.l	Do_BRA
		dc.l	Do_BRA

		dc.l	Do_BRA		;BVC, 38
		dc.l	Do_BRA
		dc.l	Do_CLR
		dc.l	Do_CMP		;CMP
		dc.l	Do_CLR
		dc.l	Do_CWAI
		dc.l	Do_ABX
		dc.l	Do_CLR

		dc.l	Do_ADC		;EOR, 46
		dc.l	Do_EXG
		dc.l	Do_CLR
		dc.l	Do_CLR		;JMP
		dc.l	Do_JSR		;JSR
		dc.l	Do_LD		;LD
		dc.l	Do_LEA		;LEA
		dc.l	Do_CLR

		dc.l	Do_CLR		;LSR, 54
		dc.l	Do_ABX
		dc.l	Do_CLR
		dc.l	Do_ABX
		dc.l	Do_ADC
		dc.l	Do_PSHS
		dc.l	Do_PSHS
		dc.l	Do_PSHS

		dc.l	Do_PSHS		;PULU, 62
		dc.l	Do_CLR
		dc.l	Do_CLR
		dc.l	Do_ABX
		dc.l	Do_ABX
		dc.l	Do_ADC
		dc.l	Do_ABX
		dc.l	Do_ST		;ST

		dc.l	Do_ADC		;SUB, 70
		dc.l	Do_SWI
		dc.l	Do_ABX
		dc.l	Do_EXG
		dc.l	Do_CLR


* include files for code go here


		include	Source:D.Edwards/a6809.i


* Some constants


NumBase		dc.l	1000000000,100000000,10000000,1000000
		dc.l	100000,10000,1000,100,10,1,0


* Texts for various purposes.


dos_name		dc.b	"dos.library",0


* Opcode texts stored as BCPL strings. Long branches & jumps
* prefixed with "L" and instructions with postfixes are
* handled algorithmically. Handled by separate routine from
* GetOp() (case insensitivity required).


* Here directives with postfixes handled algorithmically.
* examples : DEFB/W/S/T, RESB/W. The special directives
* are:

* DEFB : define byte(s)

* DEFW : define word(s)

* DEFS : define string (1 only allowed per line)

* DEFT : define tokenised string (as above)

* RESB : reserve given no. of bytes (+ optional fill)

* RESW : reserve given no. of words (+ optional fill)


opcodes		dc.b	3,"ORG",3,"EQU",3,"DEF",3,"RES"
		dc.b	3,"OPT",5,"SETDP",3,"END"
		dc.b	4,"LONG",5,"SHORT"


* This lot of entries is reserved for future use.


		dc.b	3,"???",3,"???"
		dc.b	3,"???",3,"???"
		dc.b	3,"???",3,"???"
		dc.b	3,"???"


* Here actual 6809 opcodes go. This is done to prevent ORG clashing
* with OR, for example.


		dc.b	3,"ABX",3,"ADC",3,"ADD",3,"AND"
		dc.b	3,"ASL",3,"ASR",3,"BCC",3,"BCS"
		dc.b	3,"BEQ",3,"BGE",3,"BGT",3,"BHI"
		dc.b	3,"BHS",3,"BIT",3,"BLE",3,"BLO"
		dc.b	3,"BLS",3,"BLT",3,"BMI",3,"BNE"
		dc.b	3,"BPL",3,"BRA",3,"BRN",3,"BSR"
		dc.b	3,"BVC",3,"BVS",3,"CLR",3,"CMP"
		dc.b	3,"COM",4,"CWAI",3,"DAA",3,"DEC"
		dc.b	3,"EOR",3,"EXG",3,"INC",3,"JMP"
		dc.b	3,"JSR",2,"LD",3,"LEA",3,"LSL"
		dc.b	3,"LSR",3,"MUL",3,"NEG",3,"NOP"
		dc.b	2,"OR",4,"PSHS",4,"PSHU",4,"PULS"
		dc.b	4,"PULU",3,"ROL",3,"ROR",3,"RTI"
		dc.b	3,"RTS",3,"SBC",3,"SEX",2,"ST"
		dc.b	3,"SUB",3,"SWI",4,"SYNC",3,"TFR"
		dc.b	3,"TST"

		dc.b	0


* Operator list for expressions. Again stored as BCPL strings,
* followed by precedence value. Sorted in character length order
* as opposed to precedence order (but precedences are taken into
* account during evaluation).


CompOps		dc.b	2,"^^",12	; exponentiation
		dc.b	2,"&&",2		; logical AND
		dc.b	2,"||",1		; logical OR
		dc.b	2,"<<",10	; left shift
		dc.b	2,">>",10	; right shift
		dc.b	2,">=",7		; relational >=
		dc.b	2,"<=",7		; relational <=
		dc.b	2,"<>",6		; <> relational
		dc.b	1,">",7		; relational >
		dc.b	1,"<",7		; relational <
		dc.b	1,"/",11		; division
		dc.b	1,"*",11		; multipication
		dc.b	1,"+",9		; addition
		dc.b	1,"-",9		; subtraction
		dc.b	1,"=",6		; = relational
		dc.b	1,"&",5		; bitwise AND
		dc.b	1,"^",4		; bitwise XOR
		dc.b	1,"|",3		; bitwise OR
		dc.b	0

Funcs		dc.b	1,"-",2		;unary minus
		dc.b	2,"~~",2		;logical NOT
		dc.b	1,"~",2		;complement
		dc.b	1,">",2		;get high byte
		dc.b	1,"<",2		;get low byte
		dc.b	0


* List of legal 6809 registers to be searched for. Note the embedded
* NULL to make sure that register names will only be treated as valid
* if they occur with a trailing NULL in the given position. However,
* because GetOpcode() is used to find the register name, the case is
* not significant. Note that once this value is obtained, those for
* A,B,CC and DP are corrected to fall into the required values for the
* nibbles for the TFR and EXG instruction postbytes (as defined in the
* official Motorola 6809 instruction set).


registers	dc.b	2,"D",0
		dc.b	2,"X",0
		dc.b	2,"Y",0
		dc.b	2,"U",0
		dc.b	2,"S",0
		dc.b	3,"PC",0

		dc.b	2,"A",0
		dc.b	2,"B",0
		dc.b	3,"CC",0
		dc.b	2,"DP",0

		dc.b	0

deftypes		dc.b	2,"B",0
		dc.b	2,"W",0
		dc.b	2,"S",0
		dc.b	2,"T",0

		dc.b	0


* Opcode bases. Again only exist for the actual opcodes.


opbases		dc.b	$3A		;ABX
		dc.b	$89		;ADC
		dc.b	$8B		;ADD
		dc.b	$84		;AND
		dc.b	$08		;ASL
		dc.b	$07		;ASR
		dc.b	$24		;BCC
		dc.b	$25		;BCS
		dc.b	$27		;BEQ
		dc.b	$2C		;BGE
		dc.b	$2E		;BGT
		dc.b	$22		;BHI
		dc.b	$24		;BHS
		dc.b	$85		;BIT
		dc.b	$2F		;BLE
		dc.b	$25		;BLO
		dc.b	$23		;BLS
		dc.b	$2D		;BLT
		dc.b	$2B		;BMI
		dc.b	$26		;BNE
		dc.b	$2A		;BPL
		dc.b	$20		;BRA
		dc.b	$21		;BRN
		dc.b	$8D		;BSR
		dc.b	$28		;BVC
		dc.b	$29		;BVS
		dc.b	$0F		;CLR
		dc.b	$81		;CMP
		dc.b	$03		;COM
		dc.b	$3C		;CWAI
		dc.b	$19		;DAA
		dc.b	$0A		;DEC
		dc.b	$88		;EOR
		dc.b	$1E		;EXG
		dc.b	$0C		;INC
		dc.b	$0E		;JMP
		dc.b	$8D		;JSR
		dc.b	$86		;LD
		dc.b	$30		;LEA
		dc.b	$08		;LSL
		dc.b	$04		;LSR
		dc.b	$3D		;MUL
		dc.b	$00		;NEG
		dc.b	$12		;NOP
		dc.b	$8A		;OR
		dc.b	$34		;PSHS
		dc.b	$36		:PSHU
		dc.b	$35		;PULS
		dc.b	$37		;PULU
		dc.b	$09		;ROL
		dc.b	$06		;ROR
		dc.b	$3B		;RTI
		dc.b	$39		;RTS
		dc.b	$82		;SBC
		dc.b	$1D		;SEX
		dc.b	$97		;ST
		dc.b	$80		;SUB
		dc.b	$3F		;SWI
		dc.b	$13		;SYNC
		dc.b	$1F		;TFR
		dc.b	$0D		;TST


* Timing values by opcode. 3 bytes each (in case of BCC etc).
* In opcode order.


timelist		dc.b	6,0,0		;NEG d.p 00
		dc.b	0,0,0
		dc.b	0,0,0
		dc.b	6,0,0		;COM d.p
		dc.b	6,0,0		;LSR d.p
		dc.b	0,0,0
		dc.b	6,0,0		;ROR d.p
		dc.b	0,0,0

		dc.b	6,0,0		;ASL d.p 08
		dc.b	6,0,0		;ROL d.p
		dc.b	6,0,0		;DEC d.p
		dc.b	0,0,0
		dc.b	6,0,0		;INC d.p
		dc.b	6,0,0		;TST d.p
		dc.b	3,0,0		;JMP d.p
		dc.b	6,0,0		;CLR d.p

		dc.b	0,0,0		;prebyte-ignore 10
		dc.b	0,0,0		;prebyte-ignore
		dc.b	2,0,0		;NOP
		dc.b	4,0,0		;SYNC
		dc.b	0,0,0
		dc.b	0,0,0
		dc.b	0,5,0		;LBRA
		dc.b	0,9,0		;LBSR

		dc.b	0,0,0		;	18
		dc.b	2,0,0		;DAA
		dc.b	3,0,0		;ORCC
		dc.b	0,0,0
		dc.b	3,0,0		;ANDCC
		dc.b	2,0,0		;SEX
		dc.b	8,0,0		;EXG
		dc.b	6,0,0		;TFR

		dc.b	3,0,0		;BRA	 20
		dc.b	3,5,0		;BRN/LBRN
		dc.b	3,5,6		;BHI/LBHI
		dc.b	3,5,6		;BLS/LBLS
		dc.b	3,5,6		;BCC/LBCC/BLO/LBLO
		dc.b	3,5,6		;BCS/LBCS/BHS/LBHS
		dc.b	3,5,6		;BNE/LBNE
		dc.b	3,5,6		;BEQ/LBEQ

		dc.b	3,5,6		;BVC/LBVC 28
		dc.b	3,5,6		;BVS/LBVS
		dc.b	3,5,6		;BPL/LBPL
		dc.b	3,5,6		;BMI/LBMI
		dc.b	3,5,6		;BGE/LBGE
		dc.b	3,5,6		;BLT/LBLT
		dc.b	3,5,6		;BGT/LBGT
		dc.b	3,5,6		;BLE/LBLE

		dc.b	4,0,0		;LEAX	30
		dc.b	4,0,0		;LEAY
		dc.b	4,0,0		;LEAS
		dc.b	4,0,0		;LEAU
		dc.b	5,0,0		;PSHS
		dc.b	5,0,0		;PULS
		dc.b	5,0,0		;PSHU
		dc.b	5,0,0		;PULU

		dc.b	0,0,0		;	38
		dc.b	5,0,0		;RTS
		dc.b	3,0,0		;ABX
		dc.b	6,15,0		;RTI
		dc.b	20,0,0		;CWAI
		dc.b	11,0,0		;MUL
		dc.b	0,0,0
		dc.b	19,20,0		;SWI

		dc.b	2,0,0		;NEGA	40
		dc.b	0,0,0
		dc.b	0,0,0
		dc.b	2,0,0		;COMA
		dc.b	2,0,0		;LSRA
		dc.b	0,0,0
		dc.b	2,0,0		;RORA
		dc.b	2,0,0		;ASRA

		dc.b	2,0,0		;ASLA/LSLA	48
		dc.b	2,0,0		;ROLA
		dc.b	2,0,0		;DECA
		dc.b	0,0,0
		dc.b	2,0,0		;INCA
		dc.b	0,0,0
		dc.b	0,0,0
		dc.b	2,0,0		;CLRA

		dc.b	2,0,0		;NEGB	50
		dc.b	0,0,0
		dc.b	0,0,0
		dc.b	2,0,0		;COMB
		dc.b	2,0,0		;LSRB
		dc.b	0,0,0
		dc.b	2,0,0		;RORB
		dc.b	2,0,0		;ASRB

		dc.b	2,0,0		;ASLB/LSLB	58
		dc.b	2,0,0		;ROLB
		dc.b	2,0,0		;DECB
		dc.b	0,0,0
		dc.b	2,0,0		;INCB
		dc.b	0,0,0
		dc.b	0,0,0
		dc.b	2,0,0		;CLRB

		dc.b	6,0,0		;NEG ind		60
		dc.b	0,0,0
		dc.b	0,0,0
		dc.b	6,0,0		;COM ind
		dc.b	6,0,0		;LSR ind
		dc.b	0,0,0
		dc.b	6,0,0		;ROR ind
		dc.b	6,0,0		;ASR ind

		dc.b	6,0,0		;ASL/LSL ind	68
		dc.b	6,0,0		;ROL ind
		dc.b	6,0,0		;DEC ind
		dc.b	0,0,0
		dc.b	6,0,0		;INC ind
		dc.b	6,0,0		;TST ind
		dc.b	3,0,0		;JMP ind
		dc.b	6,0,0		;CLR ind

		dc.b	7,0,0		;NEG ext		70
		dc.b	0,0,0
		dc.b	0,0,0
		dc.b	7,0,0		;COM ext
		dc.b	7,0,0		;LSR ext
		dc.b	0,0,0
		dc.b	7,0,0		;ROR ext
		dc.b	7,0,0		;ASR ext

		dc.b	7,0,0		;ASL/LSL ext	78
		dc.b	7,0,0		;ROL ext
		dc.b	7,0,0		;DEC ext
		dc.b	0,0,0
		dc.b	7,0,0		;INC ext
		dc.b	7,0,0		;TST ext
		dc.b	4,0,0		;JMP ext
		dc.b	7,0,0		;CLR ext

		dc.b	2,0,0		;SUBA imm	80
		dc.b	2,0,0		;CMPA imm
		dc.b	2,0,0		;SBCA imm
		dc.b	4,0,0		;SUBD imm
		dc.b	2,0,0		;ANDA imm
		dc.b	2,0,0		;BITA imm
		dc.b	2,0,0		;LDA imm
		dc.b	0,0,0

		dc.b	2,0,0		;EORA imm	88
		dc.b	2,0,0		;ADCA imm
		dc.b	2,0,0		;ORA imm
		dc.b	2,0,0		;ADDA imm
		dc.b	4,0,0		;CMPX imm
		dc.b	7,0,0		;BSR
		dc.b	3,0,0		;LDX imm
		dc.b	0,0,0

		dc.b	4,0,0		;SUBA d.p	90
		dc.b	4,0,0		;CMPA d.p
		dc.b	4,0,0		;SBCA d.p
		dc.b	6,0,0		;SUBD d.p
		dc.b	4,0,0		;ANDA d.p
		dc.b	4,0,0		;BITA d.p
		dc.b	4,0,0		;LDA d.p
		dc.b	4,0,0		;STA d.p

		dc.b	4,0,0		;EORA d.p	98
		dc.b	4,0,0		;ADCA d.p
		dc.b	4,0,0		;ORA d.p
		dc.b	4,0,0		;ADDA d.p
		dc.b	6,0,0		;CMPX d.p
		dc.b	7,0,0		;JSR d.p
		dc.b	5,0,0		;LDX d.p
		dc.b	5,0,0		;STX d.p

		dc.b	4,0,0		;SUBA ind	A0
		dc.b	4,0,0		;CMPA ind
		dc.b	4,0,0		;SBCA ind
		dc.b	6,0,0		;SUBD ind
		dc.b	4,0,0		;ANDA ind
		dc.b	4,0,0		;BITA ind
		dc.b	4,0,0		;LDA ind
		dc.b	4,0,0		;STA ind

		dc.b	4,0,0		;EORA ind	A8
		dc.b	4,0,0		;ADCA ind
		dc.b	4,0,0		;ORA ind
		dc.b	4,0,0		;ADDA ind
		dc.b	6,0,0		;CMPX ind
		dc.b	7,0,0		;JSR ind
		dc.b	5,0,0		;LDX ind
		dc.b	5,0,0		;STX ind

		dc.b	5,0,0		;SUBA ext	B0
		dc.b	5,0,0		;CMPA ext
		dc.b	5,0,0		;SBCA ext
		dc.b	7,0,0		;SUBD ext
		dc.b	5,0,0		;ANDA ext
		dc.b	5,0,0		;BITA ext
		dc.b	5,0,0		;LDA ext
		dc.b	5,0,0		;STA ext

		dc.b	5,0,0		;EORA ext	B8
		dc.b	5,0,0		;ADCA ext
		dc.b	5,0,0		;ORA ext
		dc.b	5,0,0		;ADDA ext
		dc.b	7,0,0		;CMPX ext
		dc.b	8,0,0		;JSR ext
		dc.b	6,0,0		;LDX ext
		dc.b	6,0,0		;STX ext

		dc.b	2,0,0		;SUBB imm	C0
		dc.b	2,0,0		;CMPB imm
		dc.b	2,0,0		;SBCB imm
		dc.b	4,0,0		;ADDD imm
		dc.b	2,0,0		;ANDB imm
		dc.b	2,0,0		;BITB imm
		dc.b	2,0,0		;LDB imm
		dc.b	0,0,0

		dc.b	2,0,0		;EORB imm	C8
		dc.b	2,0,0		;ADCB imm
		dc.b	2,0,0		;ORB imm
		dc.b	2,0,0		;ADDB imm
		dc.b	3,0,0		;LDD imm
		dc.b	0,0,0
		dc.b	3,0,0		;LDU imm
		dc.b	0,0,0

		dc.b	4,0,0		;SUBB d.p	D0
		dc.b	4,0,0		;CMPB d.p
		dc.b	4,0,0		;SBCB d.p
		dc.b	6,0,0		;ADDD d.p
		dc.b	4,0,0		;ANDB d.p
		dc.b	4,0,0		;BITB d.p
		dc.b	4,0,0		;LDB d.p
		dc.b	4,0,0		;STB d.p

		dc.b	4,0,0		;EORB d.p	D8
		dc.b	4,0,0		;ADCB d.p
		dc.b	4,0,0		;ORB d.p
		dc.b	4,0,0		;ADDB d.p
		dc.b	5,0,0		;LDD d.p
		dc.b	5,0,0		;STD d.p
		dc.b	5,0,0		;LDU d.p
		dc.b	5,0,0		;STU d.p

		dc.b	4,0,0		;SUBB ind	E0
		dc.b	4,0,0		;CMPB ind
		dc.b	4,0,0		;SBCB ind
		dc.b	6,0,0		;ADDD ind
		dc.b	4,0,0		;ANDB ind
		dc.b	4,0,0		;BITB ind
		dc.b	4,0,0		;LDB ind
		dc.b	4,0,0		;STB ind

		dc.b	4,0,0		;EORB ind	E8
		dc.b	4,0,0		;ADCB ind
		dc.b	4,0,0		;ORB ind
		dc.b	4,0,0		;ADDB ind
		dc.b	5,0,0		;LDD ind
		dc.b	5,0,0		;STD ind
		dc.b	5,0,0		;LDX ind
		dc.b	5,0,0		;STU ind

		dc.b	5,0,0		;SUBB ext	F0
		dc.b	5,0,0		;CMPB ext
		dc.b	5,0,0		;SBCB ext
		dc.b	7,0,0		;ADDD ext
		dc.b	5,0,0		;ANDB ext
		dc.b	5,0,0		;BITB ext
		dc.b	5,0,0		;LDB ext
		dc.b	5,0,0		;STB ext

		dc.b	5,0,0		;EORB ext	F8
		dc.b	5,0,0		;ADCB ext
		dc.b	5,0,0		;ORB ext
		dc.b	5,0,0		;ADDB ext
		dc.b	6,0,0		;LDD ext
		dc.b	6,0,0		;STD ext
		dc.b	6,0,0		;LDU ext
		dc.b	6,0,0		;STU ext



optlist		dc.b	1,"A"		;assemble/check only
		dc.b	1,"E"		;wait on error/abort
		dc.b	1,"L"		;listing on/off
		dc.b	1,"S"		;symbol table on/off
		dc.b	1,"T"		;timings on/off
		dc.b	0

errhd1		dc.b	"Error : ",0

errhd2		dc.b	"FATAL ERROR : ",0

errors		dc.b	"Unrecognised Instruction ",0
		dc.b	"Operand Size Clash Byte/Word ",0
		dc.b	"Illegal Addressing Mode ",0
		dc.b	"Long Branch Required ",0
		dc.b	"Illegal Option Specified ",0
		dc.b	"Illegal Indirection ",0
		dc.b	"Label Undefined ",0
		dc.b	"Label Already Defined ",0
		dc.b	"Missing Character ",0
		dc.b	"Malformed Complex Expression ",0
		dc.b	"Illegal Index Register ",0
		dc.b	"Illegal Accumulator Specified ",0
		dc.b	"Division By Zero In Expression ",0
		dc.b	"Mismatched Direct Page Reference ",0
		dc.b	"Push/Pop Instruction Register Clash ",0
		dc.b	"Operand Too Large ",0
		dc.b	"Illegal SWI Instruction ",0
		dc.b	"Missing Operand ",0
		dc.b	"Illegal Type For DEF/RES Directive ",0
		dc.b	"PC Relative Offset Too Large ",0

		dc.b	"Insufficient memory for assembler.",10,0
		dc.b	"Cannot open DOS library",10,0
		dc.b	"No source file specified",0
		dc.b	"Cannot open source file",0
		dc.b	"No destination file specified",0
		dc.b	"Cannot open destination file",0

report		dc.b	"At Line ",0

waiterr		dc.b	"Press [RETURN] To Continue, "
		dc.b	"[ESC] then [RETURN] To Abort.",0

pausetxt		dc.b	"Paused...Press [RETURN] To Continue.",0

doneinfo		dc.b	" Errors Found",10,0

stlist		dc.b	"Symbol Table : ",10,10,0

endinfo		dc.b	10,"End Of Assembly.",10,10,0

title		dc.b	10,10

		dc.b	"A6809 Cross Assembler For Motorola 6809 "
		dc.b	"Processors",10
		dc.b	"Version 1.0",10
		dc.b	"By Dave Edwards © 1991",10,10

		dc.b	"See A6809.DOC For More Information",10
		dc.b	"Including Shareware Terms."

		dc.b	10,10,10,0

crlf		dc.b	10,10,10,10,10,10,10,10,10,10
		dc.b	10,10,10,10,10,10,10,10,10,10
		dc.b	10,10,10,10,10,10,10,10,10,10

crlf_end		dc.b	0

plus_sign	dc.b	"+",0

resetcsr		dc.b	13,0

_ps1		dc.b	"Pass 1",10,0

_ps2		dc.b	"Pass 2",10,0

_db_1		dc.b	"Opcode      : ",0

_db_2		dc.b	"    Addr Mode    : ",0

_db_3		dc.b	"Index Reg   : ",0

_db_4		dc.b	"    Accumulator  : ",0

_db_5		dc.b	"Operand     : ",0

_db_6		dc.b	"    Index Offset : ",0

_db_7		dc.b	"Index Type  : ",0

_db_8		dc.b	"    X+/X++ Size  : ",0

_db_9		dc.b	"Postfix Reg : ",0

_db_10		dc.b	"Opcode      : ",0

_db_99		dc.b	" "

		dc.b	"          "
		dc.b	"          "
		dc.b	"          "
sp_end		dc.b	0

debug_buf	ds.b	256

list_buf		ds.b	256

padding_buf	ds.b	32

labelbuf		ds.b	_LABELSIZE+2






