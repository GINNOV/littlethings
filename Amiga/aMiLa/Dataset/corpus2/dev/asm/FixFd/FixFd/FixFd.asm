; file:FixFD.asm
;-----------------------------
;          Fix FD
;-----------------------------
; A utility to convert FD files to EQU files.
;
; Copyright (c) 1988 by Peter Wyspianski
;
; Revision History
; ----------------
; 30 Dec 88  created
; 01 Jan 89  changed to use the 'dos_lib.i' file

;----------------------------------------
; Constants

null	equ     $00
bs	equ	$08
tab	equ	$09
lf	equ     $0a ; amiga eoln
cr	equ     $0d ; CR only
esc	equ	$1b
csi	equ	$9b ; control sequence introducer

; DOS Constants:

MODE_OLDFILE	equ 1005
MODE_NEWFILE	equ 1006

SIGBREAKB_CTRL_C	EQU	$0C
SIGBREAKB_CTRL_D	EQU	$0D
SIGBREAKB_CTRL_E	EQU	$0E
SIGBREAKB_CTRL_F	EQU	$0F

SIGBREAKF_CTRL_C	EQU	$1000
SIGBREAKF_CTRL_D	EQU	$2000
SIGBREAKF_CTRL_E	EQU	$4000
SIGBREAKF_CTRL_F	EQU	$8000

;**SIGBREAK_ANY		equ	$F000
SIGBREAK_ANY		equ	$1000

; Exec Base Offsets:

ThisTask	EQU	$114

; Task Control Structure Offsets:

TC_SIGRECVD	EQU	$1A
TC_SIGALLOC	EQU	$12

;----------------------------------------
; Includes

	MACFILE "RAM:Std_Macs68k"
	INCLUDE "RAM:dos_lib.i"

;----------------------------------------
; Publics

	XDEF    _main
	XDEF	Exit
	
;----------------------------------------
; Externals:

; from std.startup:

	XREF	_exit
	XREF	_stdin,_stdout,_SysBase,_DOSBase

;----------------------------------------
; The beginning

	SECTION Main,CODE

; just a little something to brighten some file-zapper's day:

	dc.b	'Be Happy!',null
	cnop	0,2

;-------------------------------
; BCD_Left  [18 Nov 88]
;
; - converts hex word to a string of one to five left justified BCD digits
; - string is null terminated
;
; Inputs :  d0.w = hex word
;           a0.l = starting address of string
; Outputs:  all regs preserved
;
; Notes  :  - from 1 to five digits can be returned plus the zero termination
;             for a total of up to six characters
;           - starts by determining number of digits in the string

BCD_Left

	pushm	d0-d3/a0-a1
	
	move.w	#3,d2		; # digits - 2
	lea	LBCDTAB,a1	; point to ten thousands

1$	cmp.w	(a1)+,d0	; determine number of digits in result
	bcc.s	2$		; (ubge) taken if right size
	dbra	d2,1$		; taken for 10K through 10
	bra.s	6$		; we have just a ones digit

2$	subq.l	#2,a1		; compensate for following pre-decrement

3$	move.w	(a1)+,d1	; d1=BCD digit weight
	move.b	#'0',d3		; init digit to ASCII '0'
4$	cmp.w	d1,d0		; digit weight ? remainder
	blt	5$		; taken if done with this digit
	addq.b	#1,d3		; inc BCD digit result
	sub.w	d1,d0		; decrement total
	bnz.s	4$		; go for more
5$	move.b	d3,(a0)+	; stash digit
	dbra	d2,3$		; next digit position
6$	or.b	#'0',d0		; form ones digit
	move.b	d0,(a0)+
	clr.b	(a0)		; form zero terminator

	pullm	d0-d3/a0-a1
	rts

LBCDTAB	dc.w	10000,1000,100,10

;----------------------------------------
; GetDec  [30 Dec 88]
;
; - converts a decimal string to a hex value
;
; Inputs : a0 = ^ string
; Outputs: d0.l = value
;
; Reg Use: d1,a0-a1
;
; Calls  : none
; Uses   : none
;
; Notes  : - Non-numeric input produces garbage (GIGO applies).
;	   - Excessively long strings cause wrap-around.

GetDec:

	clr.l	d0		; result
1$	move.b	(a0)+,d1	; fetch next digit
	bz.s	2$		; if 'digit' is a null then all done

; here the running result is multiplied by ten:

	asl.l	#1,d0		; x2
	move.l	d0,a1		; save the x2 value (a1 = scratch)
	asl.l	#2,d0		; x4 x8
	add.l	a1,d0		; x8 + x2 = x10
	
; the latest 'units' digit is added to the result:

	sub.b	#'0',d1		; force digit to range 0-9
	add.l	d1,d0		; splice into result
	bra.s	1$		; and go for more!

2$	rts

;----------------------------------------
; PrStr   [31 Dec 88] _stdout
; FPrStr  [31 Dec 88] a file
;
; - sends a null terminated string to a file (_stdout)
;
; Inputs : a0 = ^string
;	   a1 = file handle (FPrStr only)
;
; Outputs: none
;
; Calls  : Write    (DOS.Library)
; Uses   : _DOSBase (library base)
;	   _stdout
;
; Notes  : exits via the call to Write

PrStr:
	move.l	_stdout,a1
FPrStr:
	push.l	a1	; save file handle

	move.l	a0,a1	; find the string length
1$	tst.b	(a1)+
	bnz.s	1$	; loop until end of string
	sub.l	a0,a1	; start-end+1 = len+1
	sub.l	#1,a1	; fix the length

	pull.l	d1	; recover file handle
	move.l	a0,d2	; ^buffer
	move.l	a1,d3	; length
	move.l	_DOSBase,a6
	jmp	_LVOWrite(a6)	; exit via this routine

;----------------------------------------
; ReadLn   [31 Dec 88] from _stdin
; FReadLn  [31 Dec 88] from a file
;
; - reads a line from a file (_stdin)
; - terminator (lf) is NOT stored
; - string is returned null-terminated
;
; Inputs : a0 = ^string buffer
;	   a1 = file handle (FReadLn only)
;
; Outputs: d0 = result: 1 = ok, 0 = eof, -1 = error
;
; Reg Use: d0-d3/a0-a2
;
; Calls  : Read    (DOS.Library)
; Uses   : _DOSBase (library base)

ReadLn:
	move.l	_stdin,a1

FReadLn:

	move.l	a0,a2		; keep ^buffer safe
	move.l	a1,a3		; keep file handle safe
	
1$	move.l	a3,d1		; file handle
	move.l	a2,d2		; ^buffer
	move.l	#1,d3		; read one char
	CallDOS	Read
	cmp.l	#1,d0		; what was returned?
	bne.s	2$		; exit if error or eof
	
	move.b	(a2)+,d1	; fetch character and bump ^buffer
	cmp.b	#lf,d1		; end of line?
	bne.s	1$		; taken if not

2$	move.b	#null,-1(a2)	; null terminate the string
	rts			; and exit

;----------------------------------------
; FileOpenError  [31 Dec 88]
;
; - calls IoErr to get a specific error number for a failed file open.
; - prints an error message of the form:
;
;   Error #xxx opening file "yyyy".
;
;
; Inputs : a0 = ^filename
; Outputs: none
;
; Reg Use: d0-d1/a0-a1
;
; Calls  : IoErr    (DOS.Library)
;	   BCD_Left
;	   PrStr
; Uses   : _DOSBase (library base)
;	   BCDBuff

FileOpenError:

	push.l	a0		; save ^file name

	CallDOS	IoErr		; must do this FIRST
	push.w	d0		; save the bad news

	lea	BadOpenMsg,a0
	jsr	PrStr

	pull.w	d0		; recover error number
	lea	BCDBuff,a0
	jsr	BCD_Left
	
	lea	BCDBuff,a0
	jsr	PrStr		; show the number
	
	lea	BadOpenMsg1,a0	; second half of error message
	jsr	PrStr
	
	pull.l	a0		; fetch ^file name
	jsr	PrStr
	
	lea	BadOpenMsg2,a0	; third half of error message
	jsr	PrStr
	
	rts

*----------------------------------------
* Main  [30 Dec 88]
*
* here is a picture of the entry stack:
*
*   12  ---        not ours!
*    8  ^argvArray pointer to argvArray
*    4  argc       argument count
* sp 0  RA     our return address

_main:
	clr.l	TheError	; default good return
	
	move.l  sp,savesp	; to ensure that we clean up on exit
	pull.l	ReturnAddr	; just in case we need it...

; make a pointer to our TC_SIGRECVD:

	move.l	_SysBase,a0	; base of the Exec library
	move.l	ThisTask(a0),a0	; ^Task Control Structure (that's us!)
	lea	TC_SIGRECVD(a0),a0 ; ^the flags
	move.l	a0,TaskSigs	; save the pointer for later

; and we're off:

	lea	GreetMsg,a0	; say hello
	jsr	PrStr

	pull.l	argc		; argc (argument count)
	pull.l	argv		; ^argv (argument array)
	
	move.l	argc,d0		; argv format: <name> <source> <dest>
	cmp.l	#3,d0		; we need three arguments...
	blt.l	Help		; ...taken if 'confused user' error!

	move.l	argv,a0		; fetch ^argv
	move.l	4(a0),a0	; point to first argument
	move.l	a0,SName	; save ^source file name

	move.l	argv,a0		; fetch ^argv
	move.l	8(a0),a0	; point to second argument
	move.l	a0,DName	; save ^dest file name

; open the input file:

	move.l	SName,d1
	move.l	#MODE_OLDFILE,d2	; must already exist
	CallDOS	Open

	move.l	d0,sfile	; save source file handle
	bnz.s	1$		; taken if ok

; handle problems opening the input file:

	move.l	SName,a0
	jsr	FileOpenError
	move.l	#30,TheError
	bra.l	Exit			; bye!

; open the output file:

1$	move.l	DName,d1
	move.l	#MODE_NEWFILE,d2
	CallDOS	Open

	move.l	d0,dfile	; save dest file handle
	bnz.s	ScanFD		; taken if ok

; handle problems opening the output file:

	move.l	DName,a0
	jsr	FileOpenError
	move.l	#30,TheError
	bra.l	Exit2
	
; read lines of the input file until EOF is true:

ScanFD:

; If the output file is acutally the tube then we don't want
; line numbers cluttering the display:

	move.l	dfile,d1	; output file handle
	CallDOS	IsInteractive
	move.b	d0,TubeOut	; -1 = yeah, 0 = nope
	
	lea	HeaderMsg,a0
	move.l	dfile,a1	; output file handle
	jsr	FPrStr

	move.l	DName,a0
	move.l	dfile,a1	; output file handle
	jsr	FPrStr
	
	lea	HeaderMsg1,a0
	move.l	dfile,a1	; output file handle
	jsr	FPrStr

	tst.b	TubeOut		; skip screen formatting if outfile...
	bnz.s	1$		; ... is connected to the tube.
	
	lea	StatusMsg,a0
	jsr	PrStr

	lea	CursorOff,a0
	jsr	PrStr

1$	move.w	line,d0		; bump line number
	add.w	#1,d0
	move.w	d0,line

	tst.b	TubeOut		; gonna use the tube?
	bnz.s	8$		; taken if not (being used by out file)

	lea	BCDBuff,a0	; convert line number to a dec string
	jsr	BCD_Left

	lea	BCDBuff,a0	; show the line number
	jsr	PrStr

; This gets REAL fancy by adding one 'bs' to StrBuff for every
; non-null char in BCDBuff:

	lea	BCDBuff,a0
	lea	StrBuff,a1
	
2$	move.b	#bs,(a1)+	; put one in there
	tst.b	(a0)+		; check for a null
	bnz.s	2$		; taken if not
	
	move.b	#null,-1(a1)	; kill the last bs and null terminate

	lea	StrBuff,a0	; backup
	jsr	PrStr

8$	move.l	TaskSigs,a0	; see if the user hit ctrl-c thru ctrl-f
	move.l	(a0),d0		; d0 = SigsRecvd
	and.l	#SIGBREAK_ANY,d0	; mask all but ours
	bnz.l	Abort		; taken if we hit

	lea	StrBuff,a0	; fetch a line from the input file
	move.l	sfile,a1
	jsr	FReadLn	

	tst.l	d0		; see what's up!
	
	bz.l	Exit0		; taken if EOF
	bmi.l	Exit0		; taken if error

;----------------------------------------
; determine what sort of line it is here:
;
; 		# = option (process further)
; A-Z,a-z,'_','.' = FD entry (strip)
;
; all others are ignored ('*',';', and anything else)

	move.b	StrBuff,d0	; fetch first char
	
	cmp.b	#'#',d0		; option?
	beq	6$		; taken if so
	
	cmp.b	#'.',d0		; fd entry?
	beq.s	3$		; taken if so
	
	cmp.b	#'_',d0		; fd entry?
	beq.s	3$		; taken if so
	
	cmp.b	#'A',d0		; fd entry?
	blt.l	1$		; taken if NOT (ignore)
	
	or.b	#$20,d0		; force to lowercase
	cmp.b	#'z',d0		; fd entry?
	bgt.l	1$		; taken if NOT (ignore)

;---------------------------------------------------------------
; strip the line (scan for a space, open paren, or end of line)
; there are NO blank lines here (eliminated above):
;

3$	lea	LVOMsg,a0	; prefix the routine name with '_LVO'
	move.l	dfile,a1
	jsr	FPrStr
	
	lea	StrBuff,a0
5$	move.b	(a0)+,d0	; fetch a char and bump pointer
	bz.s	4$		; taken if end of line
	cmp.b	#' ',d0		; space?
	beq.s	4$		; taken if so
	cmp.b	#'(',d0		; open paren?
	bne.s	5$		; taken if so

4$	move.b	#null,-1(a0)	; null-terminate right AT the 1st excess char

	pea	-1(a0)		; save ^end of string (for later)
	
	lea	StrBuff,a0	; show the line
	move.l	dfile,a1	; output file handle
	jsr	FPrStr
	
	lea	StrBuff,a0
	pull.l	d0		; fetch ^end of string
;***	sub.l	a0,d0		; d0 = string len
;***	lea	EQU8Msg,a0	; <tab> <tab> equ <tab>-
;***	cmp.l	#8,d0		; seven chars or less?
;***	blt.s	44$		; taken if so (output extra tab)

	lea	EQUMsg,a0	; <tab> equ <tab>-
44$	move.l	dfile,a1	; output file handle
	jsr	FPrStr
	
	move.w	bias,d0		; convert the bias to a decimal string
	lea	BCDBuff,a0
	jsr	BCD_Left
	
	lea	BCDBuff,a0
	move.l	dfile,a1	; output file handle
	jsr	FPrStr		; show the bias

	lea	EQUMsg1,a0	; finish the line off
	move.l	dfile,a1	; output file handle
	jsr	FPrStr

	move.w	#6,d0		; bump bias
	add.w	d0,bias

	bra.l	1$		; and go again!

;----------------------------------------
; check for the '##bias' option:

6$	move.l	StrBuff+2,d0	; fetch 4 chars (should be 'bias')
	or.l	#$20202020,d0	; force to lowercase
	cmp.l	#'bias',d0
	bne.l	1$		; ignore if not the option

; scan for a space:

	lea	StrBuff+6,a0	; skip the '##bias'

7$	move.b	(a0)+,d0	; fetch a char and bump pointer
	bz.l	1$		; taken if end of line (ignore)
	cmp.b	#' ',d0		; space?
	bne.s	7$		; taken if not

; fetch and show the bias:

	jsr	GetDec		; a0 should be pointing at the number
	move.w	d0,bias		; save it
	
; show the 'bias = ' message:

	lea	BiasMsg,a0
	move.l	dfile,a1	; output file handle
	jsr	FPrStr

	move.w	bias,d0		; convert the bias to a decimal string
	lea	BCDBuff,a0
	jsr	BCD_Left
	
	lea	BCDBuff,a0
	move.l	dfile,a1	; output file handle
	jsr	FPrStr		; show the bias

	lea	BiasMsg1,a0
	move.l	dfile,a1	; output file handle
	jsr	FPrStr
	
	bra.l	1$		; go for another line


;-------------------------------------------
; show the help message and exit:

Help:
	lea	HelpMsg,a0
	jsr	PrStr
	bra.s	Exit

;-------------------------------------------
; show the 'break...' message and exit:

Abort:
	lea	BreakMsg,a0
	jsr	PrStr
	bra.s	ExitA

;-----------------------------
; Exit routines  [30 Dec 88]
;

Exit0:

	lea	DoneMsg,a0
	jsr	PrStr

ExitA:
	lea	CursorOn,a0
	jsr	PrStr

Exit1:
	move.l	dfile,d1	; close the dest file
	CallDOS	Close

Exit2:
	move.l	sfile,d1	; close the source file
	CallDOS	Close

Exit:
	push.l	TheError	; error code
	jsr	_exit		; and wind it up

;----------------------------------------
; constants

	SECTION Constants,DATA

GreetMsg:
	dc.b	lf
	dc.b	csi,'0;33;40m'
	dc.b	' FixFD '
	dc.b	csi,'0;31;40m'
	dc.b	'v1.0 - Copyright ',$a9
	dc.b	' 1988, Peter Wyspianski',lf,lf
	dc.b	null

HelpMsg
	dc.b	' This utility takes an ''.FD'' file and generates a set of',lf
	dc.b	' EQUates that can be used by an assembler.',lf,lf
	dc.b	' Parameters: source_file dest_file.',lf,lf
	dc.b	' See the docs for more info! -PW',lf,lf,null

BadOpenMsg:
	dc.b	csi,'0;33;40m'
	dc.b	' Error '
	dc.b	csi,'0;31;40m'
	dc.b	'#'
	dc.b	null

BadOpenMsg1:
	dc.b	' opening file "',null

BadOpenMsg2:
	dc.b	'"',lf,lf,null

CursorOff
	dc.b	csi
	dc.b	'0 p'
	dc.b	null

CursorOn
	dc.b	csi
	dc.b	' p'
	dc.b	null

StatusMsg:
	dc.b	'   Reading line '
	dc.b	null

DoneMsg
	dc.b	lf,lf
	dc.b	csi,'0;33;40m'
	dc.b	' Finished.'
	dc.b	csi,'0;31;40m'
	dc.b	lf,lf,null

BreakMsg
	dc.b	lf,lf
;***	dc.b	csi,'0;33;40m'
	dc.b	'*** BREAK'
;***	dc.b	csi,'0;31;40m'
	dc.b	lf,lf,null
	
HeaderMsg
	dc.b	'; file:',null

HeaderMsg1
	dc.b	lf
	dc.b	';',lf
	dc.b	'; generated by FixFD v1.0',lf
	dc.b	';',lf
	dc.b	null

BiasMsg
	dc.b	'; Bias = ',null
	
BiasMsg1
	dc.b	lf
	dc.b	';',lf
	dc.b	null

LVOMsg
	dc.b	'_LVO',null
	
EQU8Msg
	dc.b	tab
EQUMsg
	dc.b	tab
	dc.b	'equ -'
	dc.b	null

EQUMsg1
	dc.b	lf
	dc.b	null

;----------------------------------------
; Uninitialized storage

	SECTION Variables,BSS

TaskSigs	ds.l	1	; pointer to our TC_SIGRECVD

TheError	ds.l	1	; error return code

SName		ds.l	1	; ^source file name
DName		ds.l	1	; ^dest file name

sfile		ds.l	1	; source file handle
dfile		ds.l	1	; dest file handle

savesp		ds.l    1	; entry stack pointer

argc		ds.l	1	; argument count
argv		ds.l	1	; argument array pointer

ReturnAddr	ds.l	1	; program return address

bias		ds.w	1	; library entry bias
line		ds.w	1	; current line number

TubeOut		ds.b	1	; -1 = yes, 0 = nope
		ds.b	1	; alignment

BCDBuff		ds.b	6	; bcd string buffer

StrBuff		ds.b	256	; longest possible string

