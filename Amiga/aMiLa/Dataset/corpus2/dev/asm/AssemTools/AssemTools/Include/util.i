;METACOMCO needs:
;execlib.i, relative.i


	ifnd	def
def	macro
	ifnd	\1
\1	set	\2
	endc
	endm
	endc


ph	macro	oper
	move.l	\1,-(sp)
	endm

pl	macro	oper
	move.l	(sp)+,\1
	endm

* PH and PL are used to PusH and PulL an operand to/from stack.
* They use MOVE and therefore are more effective than PUSH
* and PULL that use MOVEM.

pk	macro	oper
	move.l	(sp),\1
	endm

* PK is used to peek a value from stack without changing the
* valueo of stack pointer. This prevents the use of sequent
* PH and PL macros with the same operand.


sro	macro	value,oper
	move.l	\2,-(sp)
	move.l	\1,\2
	endm

* SRO (Save and Replace Operand) is used to move a longword
* value to an operand. Before doing this, the operand is pushed
* onto the stack. The counterpart of this function is PL.


* ALLOC and FREE are used to allocate and free memory.

alloc	macro	pointer,size[,[requi][,clean]]
	move.l	\2,d0
	addq.l	#4,d0
	ifnc	'\3',''
	move.l	\3,d1
	endc
	ifc	'\3',''
	moveq	#0,d1
	endc
	lib	Exec,AllocMem
	clr.l	\1
	tst.l	d0
	ifnc	'\4',''
	beq	\4
	endc
	ifc	'\4',''
	bne.s	.ui\@a
	endc
	move.l	d0,a0
	move.l	\2,d0
	addq.l	#4,d0
	move.l	d0,(a0)+
	move.l	a0,\1
.ui\@a
	endm

free	macro	pointer
	move.l	\1,d0
	beq.s	.ui\@a
	move.l	d0,a1
	move.l	-(a1),d0
	lib	Exec,FreeMem
	clr.l	\1
.ui\@a
	endm

.ui.form macro	<private>
	move.l	\1,(a2)+
	ifnc	'\2',''
	.ui.form \2,\3,\4,\5,\6,\7,\8,\9
	endc
	endm
formatp	macro	param-list
	link	a3,#-4*NARG
	move.l	sp,a2
	.ui.form \1,\2,\3,\4,\5,\6,\7,\8,\9
	move.l	sp,a2
	endm
format	macro	bufptr,format-str,param-list
	ifnc	'\1','a1'
	exg.l	\1,a1
	endc
	movem.l	a0/a2,-(sp)
	link	a3,#-4*(NARG-2)
	move.l	sp,a2
	.ui.form \3,\4,\5,\6,\7,\8,\9
	move.l	sp,a2
	lea.l	.ui\@a(pc),a0
	execlib	format
	unlk	a3
	movem.l	(sp)+,a0/a2
	ifnc	'\1','a1'
	exg.l	\1,a1
	endc
	bra.s	.ui\@b
.ui\@a	dc.b	\2
	dc.b	0
	ds.w	0
.ui\@b	;;;
	endm

;  Sample usages:
;  *  format  a0,<' - Error code %ld',10>,d0
;  BUFPTR (a0) may be any address register.
;  FSTRING may be an ascii string.
;  parameters may be any locations or registers BUT NOT
;      A1, A2 or A3. Each one of them is used as LONG.
;  *  formatp fnam(a4),d0
;  Just reserves stack space for the parameters and
;  puts them there. a2 points to the beginning of the
;  data stream, a3 is the prev. stack pointer, so UNLK A3
;  frees the space from stack.


	; *** relative.i ONLY:
.share	macro
_share.cnt set	0
	endm

dm	macro	name,size
	dl	\1
_DmS.\1	set	\2
_share.cnt set	_share.cnt+(\2)
	endm

share	macro	mem,type,clean
	alloc	\1(a4),#_share.cnt,\2,\3
	move.l	\1(a4),a0
	endm

slice	macro	name[,name[,name...]]
	move.l	a0,\1(a4)
	lea	_DmS.\1(a0),a0
	ifnc	'\2',''
	slice	\2,\3,\4,\5,\6,\7,\8
	endc
	endm

;see from a program how they work!
;(they allocate a bit of memory and share it)
;they work only with relative(.i) programs


scribe	macro	rport,x,y,'text'
	move.l	\1,a1
	move.l	\2,d0
	move.l	\3,d1
	lib	Gfx,Move
	move.l	\1,a1
	lea	.s\@a(pc),a0
	moveq	#.s\@b-.s\@a,d0
	lib	Gfx,Text
	bra	.s\@c
.s\@a	dc.b	\4
.s\@b
	ds.l	0
.s\@c
	endm



