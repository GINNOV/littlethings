; Universal Macros for SS.Library, 3.5
; (c) 1993,1994 SinSoft, PCSoft & MJSoft System Software
; ------------------------------------------------------------------------------

; Global definitions

v	equr	a5
s_W	equ	1
s_b	equ	1
s_w	equ	2
s_l	equ	4

; Initialization

SYSCNT	set	4
execbase	equ	4
_NOARP	equ	1
	code

	opt	o+,w+
	opt	chkimm

; Includes

	ifnd	ALLSYSTEM
	ifnd	SYSI
	include	"system.gs"
	elseif
	include	"sys.i"
	endc
	elseif
	include	"allsystem.gs"
	endc
	ifnd	NOSS
	include	"SS.i"
	endc

; General macros

push	macro	*reg
	move.l	\1,-(sp)
	endm

pop	macro	*reg
	move.l	(sp)+,\1
	endm

mpush	macro	*reglist
	movem.l	\1,-(sp)
	endm

mpop	macro	*reglist
	movem.l	(sp)+,\1
	endm

rptr	macro	*label
	dc.w	\1-*
	endm

; Data definition macros

dv	macro	*.size,name
	ifnc	'\0','b'
SYSCNT	set	(SYSCNT+1)&$FFFE
	endc
\1	equ	SYSCNT
SYSCNT	set	SYSCNT+s_\0
	endm

dbuf	macro	*[.size],name,nritems
SYSCNT	set	(SYSCNT+1)&$FFFE
\1	equ	SYSCNT
SYSCNT	set	SYSCNT+s_\0*\2
	endm

alignlong	macro
SYSCNT	set	(SYSCNT+3)&$FFFC
	endm

; Special data access macros

vpush	macro	*var
	move.l	\1(v),-(sp)
	endm

vpop	macro	*var
	move.l	(sp)+,\1(v)
	endm

get	macro	*.type,from,to
	move.\0	\1(v),\2
	endm

put	macro	*.type,from,to
	move.\0	\1,\2(v)
	endm

geta	macro	*from,to
	lea	\1(v),\2
	endm

getad	macro	*from,via,to
	lea	\1(v),\2
	move.l	\2,\3
	endm

clv	macro	*.type,dest
	clr.\0	\1(v)
	endm

tsv	macro	*.type,src
	tst.\0	\1(v)
	endm

; Normal data access macros

negv	macro	*.size,to
	neg.\0	\1(v)
	endm

notv	macro	*.size,to
	not.\0	\1(v)
	endm

stv	macro	*.size,to
	st	\1(v)
	endm

clrv	macro	*.size,to
	clr.\0	\1(v)
	endm

seqv	macro	*.size,to
	seq	\1(v)
	endm

snev	macro	*.size,to
	sne	\1(v)
	endm

sccv	macro	*.size,to
	scc	\1(v)
	endm

scsv	macro	*.size,to
	scs	\1(v)
	endm

tstv	macro	*.size,from
	tst.\0	\1(v)
	endm

bchgv	macro	*bitnr,byte
	bchg	\1,\2(v)
	endm

bclrv	macro	*bitnr,byte
	bclr	\1,\2(v)
	endm

bsetv	macro	*bitnr,byte
	bset	\1,\2(v)
	endm

btstv	macro	*bitnr,byte
	btst	\1,\2(v)
	endm

subqv	macro	*.type,nr,byte
	subq.\0	\1,\2(v)
	endm

addqv	macro	*.type,nr,byte
	addq.\0	\1,\2(v)
	endm

vpea	macro	*var
	pea	\1(v)
	endm

eorv	macro	*.type,src,dest
	eor.\0	\1,\2(v)
	endm

divsv	macro	*src,dest
	divs	\1,\2(v)
	endm

divuv	macro	*src,dest
	divu	\1,\2(v)
	endm

mulsv	macro	*src,dest
	muls	\1,\2(v)
	endm

muluv	macro	*src,dest
	mulu	\1,\2(v)
	endm

addv	macro	*.type,src,dest
	add.\0	\1,\2(v)
	endm

vadd	macro	*.type,src,dest
	add.\0	\1(v),\2
	endm

andv	macro	*.type,src,dest
	and.\0	\1,\2(v)
	endm

vand	macro	*.type,src,dest
	and.\0	\1(v),\2
	endm

cmpv	macro	*.type,src,dest
	cmp.\0	\1,\2(v)
	endm

vcmp	macro	*.type,src,dest
	cmp.\0	\1(v),\2
	endm

movev	macro	*.type,src,dest
	move.\0	\1,\2(v)
	endm

vmove	macro	*.type,src,dest
	move.\0	\1(v),\2
	endm

orv	macro	*.type,src,dest
	or.\0	\1,\2(v)
	endm

vor	macro	*.type,src,dest
	or.\0	\1(v),\2
	endm

subv	macro	*.type,src,dest
	sub.\0	\1,\2(v)
	endm

vsub	macro	*.type,src,dest
	sub.\0	\1(v),\2
	endm

vlea	macro	*src,dest
	lea	\1(v),\2
	endm

vmovev	macro	*.type,src,dest
	move.\0	\1(v),\2(v)
	endm

movemv	macro	*.type,src,dest
	movem.\0	\1,\2(v)
	endm

vmovem	macro	*.type,src,dest
	movem.\0	\1(v),\2
	endm

; Text macros

tbase	macro	*basereg
t	equr	\1
	section	TEXTS,DATA
TEXTBASE
	code
	endm

	ifd	TEXTRACT
dt	macro
	endm
gett	macro
	lea	\1(pc),\2
	endm
tlea	macro
	lea	\1(pc),\2
	endm
tpea	macro
	pea	\1(pc)
	endm

	elseif

dt	macro	*.type ([c][l]),[label,]text
	section	TEXTS,DATA
	ifne	NARG-1
\1	dc.b	'\2'
	elseif
	dc.b	'\1'
	endc
	ifc	'\0','W'
	dc.b	0
	endc
	ifc	'\0','l'
	dc.b	10,0
	endc
	ifc	'\0','cl'
	dc.b	10
	endc
	ifc	'\0','lc'
	dc.b	10
	endc
	code
	endm

gett	macro	*textlabel,areg
	ifd	t
	lea	\1-TEXTBASE(t),\2
	elseif
	lea	\1,\2
	endc
	endm

tlea	macro	*textlabel,areg
	ifd	t
	lea	\1-TEXTBASE(t),\2
	elseif
	lea	\1,\2
	endc
	endm

tpea	macro	*textlabel
	ifd	t
	pea	\1-TEXTBASE(t)
	elseif
	pea	\1
	endc
	endm

	endc

dtl	macro	*text,areg
	dt.\0	\@a,<\1>
	gett	\@a,\2
	endm

; System calls

call	macro	*[base,]name
	ifeq	NARG-1
	jsr	_LVO\1(a6)
	elseif
	ifc	'\1','exec'
	move.l	4.w,a6
	elseif
	ifc	'\1','ss'
	move.l	(v),a6
	elseif
	move.l	\1base(v),a6
	endc
	endc
	jsr	_LVO\2(a6)
	endc
	endm

jump	macro	*[base,]name
	ifeq	NARG-1
	jmp	_LVO\1(a6)
	elseif
	ifc	'\1','exec'
	move.l	4.w,a6
	elseif
	ifc	'\1','ss'
	move.l	(v),a6
	elseif
	move.l	\1base(v),a6
	endc
	endc
	jmp	_LVO\2(a6)
	endc
	endm

; Universal start & finish

start	macro

	ifd	GATHERTX
	opt	x+
	endc

	ifd	DEBUG	; Stub for passing of arguments
	opt	x+
Debug__Init	move.l	4.w,a1
	move.l	ThisTask(a1),a1
	move.l	pr_GlobVec(a1),a2
	move.l	pr_CIS(a1),d1
	beq.s	3$
	lsl.l	#2,d1
	move.l	d1,a3
	lea	fh_Buf(a3),a3
	move.l	(a3)+,a1
	add.l	a1,a1
	add.l	a1,a1
	clr.l	(a3)+
	move.l	d0,(a3)+
	bra.s	1$
2$	move.b	(a0)+,(a1)+
1$	dbf	d0,2$
3$
	endc

	move.l	4.w,a6

	ifnd	_nowbstart
	move.l	ThisTask(a6),a0
	moveq	#0,d7
	tst.l	pr_CLI(a0)
	bne.s	Start__1
	lea	pr_MsgPort(a0),a0
	call	GetMsg
	move.l	d0,d7
Start__1
	endc

	lea	ssname(pc),a1
	call	OldOpenLibrary
	tst.l	d0
	bne.s	_ssok

	ifd	_GlobVec
	move.l	$170(a2),a6
	elseif
	lea	_intname(pc),a1
	call	OldOpenLibrary
	tst.l	d0
	beq.s	_enderr
	move.l	d0,a6
	moveq	#0,d0
	endc
	lea	_ssalert(pc),a0
	moveq	#30,d1
	call	DisplayAlert
	ifnd	_GlobVec
	move.l	a6,a1
	call	exec,CloseLibrary
	endc
_enderr
	ifnd	_nowbstart
	tst.l	d7
	beq.s	_endclierr
	move.l	d7,a1
	ifd	_GlobVec
	move.l	4.w,a6
	endc
	call	ReplyMsg
_endclierr
	endc
	moveq	#100,d0
	rts

	ifnd	_GlobVec
_intname	dc.b	'intuition.library'
	endc
_ssalert	dc.b	0,244,16,'You need '
ssname	dc.b	'ss.library',0,0
	even

_ssok	move.l	d0,a6
	lea	_startstruc(pc),a0
	call	StartupInit
	ifd	t
	lea	TEXTBASE,t
	endc
	ifd	DEBUG
	vmovev.l stdout,stderr
	endc
go
	endm

clistart	macro
_nowbstart	equ	1
	start
	endm

tags	macro
_startstruc	dc.w	_SYSCNT,SSVer
	endm

finish	macro
	dc.w	0
_SYSCNT	equ	SYSCNT
	ifd	TEXTRACT
	include	"t:TextHunk.i"
	endc
	ifd	GATHERTX
	section	TEXTS,DATA
_TextHunkEnd
	code
	endc
	endm

; Startup tags

wbconsole	macro
	dc.w	sst_wbconsole
	endm

template	macro	*template
	dc.w	sst_template
	dc.b	'\1',0
	even
SYSCNT	set	(SYSCNT+1)&$FFFE
	dc.w	SYSCNT
	endm

defvar	macro	*varname
	dc.w	sst_envvar
	dc.b	'\1',0
	even
	endm

exitrout	macro	*routine
	dc.w	sst_exitrout
\@a	dc.w	\1-\@a
	endm

errrout	macro	*routine
	dc.w	sst_usererr
\@a	dc.w	\1-\@a
	endm

usrtrk	macro	*table
	dc.w	sst_usertrk
\@a	dc.w	\1-\@a
	endm

library	macro	*name,version
	dv.l	\1base
	dc.w	sst_library
	dc.b	'\1.library',0
	even
	dc.w	\2,\1base
	endm

trylib	macro	*name,version
	dv.l	\1base
	dc.w	sst_trylib
	dc.b	'\1.library',0
	even
	dc.w	\2,\1base
	endm

cputype	macro	*min,max
	dc.w	sst_cputype
	dc.b	\1,\2
	endm

fputype	macro	*min,max
	dc.w	sst_fputype
	dc.b	\1,\2
	endm

sysver	macro	*min,max
	dc.w	sst_sysver
	dc.b	\1,\2
	endm

diserr	macro	*flags
	dc.w	sst_errors
	dc.l	\1
	endm

wbconname	macro	*name
	dc.w	sst_wbconname
	dc.b	'\1',0
	even
	endm

extrahelp	macro	*[text]
	dc.w	sst_extrahelp
	ifne	NARG
	dc.b	'\1',0
	even
	endc
	endm

endhelp	macro
	dc.b	0
	even
	endm

; ### Text output ###

write	macro	*text
	dtl	<\1>,a0
	call	ss,Puts
	endm

writeln	macro	*text
	dtl	<\1>,a0
	call	ss,PutsNL
	endm

printfs	macro	*[.L,]text
	dtl.\0	<\1>,a0
	move.l	sp,a1
	call	ss,Printf
	endm

printfv	macro	*[.L,]text,variable
	dtl.\0	<\1>,a0
	geta	\2,a1
	call	ss,Printf
	endm

printfr	macro	*[.L,]text,register
	push	\2
	dtl.\0	<\1>,a0
	move.l	sp,a1
	call	ss,Printf
	pop	\2
	endm

printfl	macro	*[.L,]text,reglist[,numreg]
	mpush	\2
	dtl.\0	<\1>,a0
	move.l	sp,a1
	call	ss,Printf
	ifeq	NARG-3
	ifgt	\3-2
	lea	(\3*4)(sp),sp
	elseif
	addq.l	#4*\3,sp
	endc
	elseif
	mpop	\2
	endc
	endm

err	macro	*text
	dtl	<\1>,a0
	jump	ss,ExitError
	endm

doserr	macro	*text
	dtl	<\1>,a0
	jump	ss,DosError
	endm

errc	macro	*.negcond,text
	b\0.s	\@a
	err	<\1>
\@a
	endm


BLINK	MACRO
	bchg.b #1,$bfe001		  ;Toggle the power LED
	ENDM
