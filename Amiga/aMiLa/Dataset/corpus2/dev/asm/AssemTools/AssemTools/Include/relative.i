
*** v1.6 140189 by TM for relative variables (from stack) ***


dl	macro	name [,name [,name...] ]	;def lwords
DefSiz	set	DefSiz+4
DefPtr	set	DefPtr-4
\1	set	DefPtr
	ifnc	'\2',''
	dl	\2,\3,\4,\5,\6,\7,\8
	endc
	endm

dw	macro	name [,name [,name...] ]	;def words
DefSiz	set	DefSiz+2
DefPtr	set	DefPtr-2
\1	set	DefPtr
	ifnc	'\2',''
	dw	\2,\3,\4,\5,\6,\7,\8
	endc
	endm

db	macro	name [,name [,name...] ]	;def bytes
DefSiz	set	DefSiz+1
DefPtr	set	DefPtr-1
\1	set	DefPtr
	ifnc	'\2',''
	db	\2,\3,\4,\5,\6,\7,\8
	endc
	endm

da	macro	name,size			;def storage
DefSiz	set	DefSiz+\2
DefPtr	set	DefPtr-\2
\1	set	DefPtr
	endm

dwb	macro					;word boundary
	ifne	DefPtr&1
DefPtr	set	DefPtr-1
DefSiz	set	DefSiz+1
	endc
	endm

.var	macro					;def var section
DefPtr	set	0
DefSiz	set	0
	endm

.begin	macro					;begin subr
	link	a4,#-DefSiz
	endm

.end	macro					;end subr
	unlk	a4
	rts
	endm

ra	macro		;reset all variables
	movem.l	d0/a0,-(sp)
	move.w	#DefSiz-1,d0
	move.l	a4,a0
ra.\@	clr.b	-(a0)
	dbf	d0,ra.\@
	movem.l	(sp)+,d0/a0
	endm

rb	macro
	clr.b	\1(a4)
	ifnc	'\2',''
	rb	\2,\3,\4,\5,\6,\7,\8
	endc
	endm

rw	macro
	clr.w	\1(a4)
	ifnc	'\2',''
	rw	\2,\3,\4,\5,\6,\7,\8
	endc
	endm

rl	macro
	clr.l	\1(a4)
	ifnc	'\2',''
	rl	\2,\3,\4,\5,\6,\7,\8
	endc
	endm


