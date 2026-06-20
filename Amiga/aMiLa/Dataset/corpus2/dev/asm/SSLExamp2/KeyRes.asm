; Keymap Resourcer
; (c) 1993 MJSoft System Software
; Martin Mares

;	opt	x+

	include	"ssmac.h"

	tbase	a4
	clistart

	writeln	<Keymap Resourcer 1.0, (c) 1993 MJSoft System Software>

	dtl	<keymap.resource>,a1
	call	exec,OpenResource
	tst.l	d0
	beq.s	keyload
	move.l	d0,a0
	call	Forbid
	lea	14(a0),a0
	get.l	from,a1
	call	FindName
	call	Permit
	tst.l	d0
	bne.s	keymok

keyload	get.l	from,d1
	call	dos,LoadSeg
	dv.l	myseg
	put.l	d0,myseg
	bne.s	segok
	dtl	<Unable to load %s>,a0
	geta	from,a1
	jump	ss,ExitError

segok	add.l	d0,d0
	add.l	d0,d0
	addq.l	#4,d0
keymok	put.l	d0,keymap

	dv.l	keymap
	dbuf	destname,80

	move.l	d0,a0
	move.l	10(a0),a2		; Keymap name
	get.l	to,a0
	move.l	a0,d0
	bne.s	makedest
	move.l	a2,a0
makedest	geta	destname,a1
	push	a1
	push	a2
	dtl	<kms>,a2
	moveq	#80,d0
	call	ss,AddExtension

	geta	destname,a0
	move.l	#1006,d0
	call	ss,TrackOpen	; Errors are filtered out by SSLib
	put.l	d0,destfh
	dv.l	destfh

opendest2	dtl.l	<Resourcing %s to %s.>,a0
	move.l	sp,a1
	call	Printf
	addq.l	#8,sp

	moveq	#0,d7			; Estimate number of dead keys
	moveq	#0,d5
	get.l	keymap,a0
	lea	14(a0),a0
	moveq	#$3f,d6
	bsr	analyse
	get.l	keymap,a0
	lea	30(a0),a0
	moveq	#$27,d6
	bsr	analyse
	add.l	d5,d7
	put.l	d7,maxdead
	dv.l	maxdead

	get.l	keymap,a0		; Resource the keymap
	lea	keytab0(pc),a2
	lea	14(a0),a0
	bsr.s	resource
	get.l	keymap,a0
	lea	keytab1(pc),a2
	lea	30(a0),a0
	bsr.s	resource

	rts

cleanup	get.l	myseg,d1
	beq.s	.segment
	call	dos,UnLoadSeg
.segment	rts

; A0=keymap structure, A2=key list

resource	move.l	(a0)+,a1		; A1=types
	move.l	(a0)+,a3		; A3=keymap
	move.l	(a0)+,d2		; D2=capsability
	move.l	(a0)+,d3		; D3=repeatability
	get.l	destfh,d7		; D7=dest file handle
	moveq	#0,d1			; D1=bit number
reskey	call	ss,TestBreak
	tst.b	(a2)
	beq	resend
	move.b	(a1)+,d4		; D4=key flags
	sub.l	a0,a0
	btst	d1,0(a0,d2.l)
	sne	d6			; D6=is capsable
	btst	d1,0(a0,d3.l)
	sne	d5			; D5=is repeatable
	addq.b	#1,d1
	bclr	#3,d1
	beq.s	resloop1
	addq.l	#1,d3
	addq.l	#1,d2
resloop1	btst	#7,d4			; Is it a NOP key ?
	bne	resskip
	mpush	d1-d3/a1/a3

	dtl	<DEAD >,a0		; Key type
	btst	#5,d4
	bne.s	restype
	dtl	<STRING >,a0
	btst	#6,d4
	beq.s	restype1
restype	bsr	putsit

restype1	dtl	<KEY >,a0		; Key header
	bsr	putsit
	move.l	a2,a0
	bsr	putsit
	btst	#2,d4			; CTRL
	beq.s	resctrl
	dtl	< CTRL>,a0
	bsr	putsit
resctrl	btst	#1,d4			; ALT
	beq.s	resalt
	dtl	< ALT>,a0
	bsr	putsit
resalt	btst	#0,d4			; SHIFT
	beq.s	resshift
	dtl	< SHIFT>,a0
	bsr	putsit
resshift	tst.b	d6			; Capsability
	beq.s	rescaps
	dtl	< CAPS>,a0
	bsr	putsit
rescaps	tst.b	d5			; Repeatability
	bne.s	resrep
	dtl	< NOREP>,a0
	bsr	putsit
resrep	btst	#4,d4			; DownUp flag
	beq.s	resdoup
	dtl	< DOWNUP>,a0
	bsr	putsit
resdoup	bsr	newlin			; End of header

	not.b	d4
	btst	#5,d4
	beq.s	resdead
	btst	#6,d4
	beq	resstring

	addq.l	#4,a3			; Normal key
	moveq	#0,d3			; D3=counter of meanings
	btst	#0,d4
	bne.s	norm_loop
	btst	#1,d4
	bne.s	norm_loop
	bset	#2,d4
norm_loop	move.b	d3,d0
	and.b	d4,d0
	bne.s	norm_next
	move.b	-(a3),d2
	beq.s	norm_next
	bsr	shipattr
	move.b	d2,d0
	bsr	shipcode
	bsr	newlin
norm_next	addq.b	#1,d3
	cmp.b	#8,d3
	bcs.s	norm_loop
	bra	reskend

; Dead/Modified key

resdead	moveq	#0,d3			; D3=counter of meanings
	move.l	(a3),a3
	move.l	a3,a0
dead_loop	move.b	d3,d0
	and.b	d4,d0
	bne.s	dead_next2
	move.b	(a0)+,d0
	moveq	#0,d2
	move.b	(a0)+,d2
	push	a0
	btst	#3,d0
	bne.s	dead_dead
	btst	#0,d0
	bne.s	dead_mod
	tst.b	d2
	beq.s	dead_next
	bsr	shipattr
	move.b	d2,d0
	bsr	shipcode
dead_line	bsr	newlin
dead_next	pop	a0
dead_next2	addq.b	#1,d3
	cmp.b	#8,d3
	bcs.s	dead_loop
	bra	reskend

dead_dead	bsr	shipattr
	dtl	<PREFIX >,a0
	bsr	putsit
	move.b	d2,d0
	and.b	#$0F,d0
	bsr	shipcode
	lsr.b	#4,d2
	beq.s	1$
	moveq	#',',d0
	bsr	putcit
	move.b	d2,d0
	bsr	shipcode
1$	bra.s	dead_line

dead_mod	bsr	shipattr
	dtl	<MOD >,a0
	bsr.s	putsit
	lea	0(a3,d2.w),a0
	get.l	maxdead,d2
	bra.s	dead_mod_2
dead_mod_1	move.b	(a0)+,d0
	push	a0
	bsr	shipcode
	moveq	#',',d0
	bsr.s	putcit
	pop	a0
dead_mod_2	dbra	d2,dead_mod_1
	move.b	(a0)+,d0
	bsr	shipcode
	bra.s	dead_line

; String key

resstring	moveq	#0,d3			; D3=counter of meanings
	move.l	(a3),a3
	move.l	a3,a0
string_loop	move.b	d3,d0
	and.b	d4,d0
	bne.s	string_next
	move.b	(a0)+,d2
	moveq	#0,d0
	move.b	(a0)+,d0
	tst.b	d2
	beq.s	string_next
	push	a0
	pea	0(a3,d0.w)
	bsr.s	shipattr
	moveq	#'"',d0
	bsr.s	putcit
	pop	a0
string_str	move.b	(a0)+,d0
	push	a0
	bsr	putcstr
	pop	a0
	subq.b	#1,d2
	bne.s	string_str
	moveq	#'"',d0
	bsr.s	putcit
	bsr.s	newlin
	pop	a0
string_next	addq.b	#1,d3
	cmp.b	#8,d3
	bcs.s	string_loop

reskend	bsr.s	newlin
	mpop	d1-d3/a1/a3
resskip	tst.b	(a2)+
	bne.s	resskip
	addq.l	#4,a3
	bra	reskey

resend	rts

newlin	dtl	<',10,'>,a0
putsit	move.l	d7,d1
	push	d2
	move.l	a0,d2
	call	dos,FPuts
	pop	d2
	rts

putcit	push	d2
	move.l	d7,d1
	move.l	d0,d2
	call	dos,FPutC
	pop	d2
	rts

; D3=key meaning attribute

shipattr	btst	#2,d3
	beq.s	sat_ctrl
	dtl	<CTRL >,a0
	bsr.s	putsit
sat_ctrl	btst	#1,d3
	beq.s	sat_alt
	dtl	<ALT >,a0
	bsr.s	putsit
sat_alt	btst	#0,d3
	beq.s	sat_shift
	dtl	<SHIFT >,a0
	bsr.s	putsit
sat_shift	rts

; D0=character code

shipcode	move.w	d0,-(sp)
	cmp.b	#32,d0
	bcs.s	shipcode1
	cmp.b	#127,d0
	bcs.s	shipcode2
	cmp.b	#160,d0
	bcs.s	shipcode1
shipcode2	moveq	#'''',d0
	bsr.s	putcit
	move.w	(sp)+,d0
	cmp.b	#'''',d0
	bne.s	shipcode3
	bsr.s	putcit
	moveq	#'''',d0
shipcode3	bsr.s	putcit
	moveq	#'''',d0
	bra.s	putcit

shipcode1	clr.b	(sp)
	dtl	<%d>,a0
	mpush	d2-d3
	move.l	sp,d3
	addq.l	#8,d3
	move.l	d7,d1
	move.l	a0,d2
	call	dos,VFPrintf
	mpop	d2-d3
	addq.l	#2,sp
	rts

putcstr	cmp.b	#'"',d0
	beq.s	putcstrq
	cmp.b	#'\',d0
	beq.s	putcstr1
	cmp.b	#32,d0
	bcs.s	putcstr3
	cmp.b	#127,d0
	bcs.s	putcstr2
	cmp.b	#160,d0
	bcc.s	putcstr2
putcstr3	move.w	d0,-(sp)
	moveq	#'\',d0
	bsr.s	putcstr2
	move.w	(sp),d0
	lsr.b	#4,d0
	bsr.s	putnib
	move.w	(sp)+,d0
	bra.s	putnib

putcstrq	bsr.s	putcstrq1
	moveq	#'"',d0
	bra.s	putcstr2

putcstr1	bsr.s	putcstr2
putcstrq1	moveq	#'\',d0
putcstr2	bra	putcit

putnib	and.b	#$0f,d0
	cmp.b	#10,d0
	bcs.s	1$
	addq.l	#7,d0
1$	add.b	#'0',d0
	bra	putcit

analyse	move.l	(a0)+,a2		; A2=types
	move.l	(a0)+,a3		; A3=data
anal1	move.b	(a2)+,d4
	move.l	(a3)+,d0
	btst	#5,d4
	beq.s	anal2
	not.b	d4
	moveq	#0,d3
	move.l	d0,a0
anal3	move.b	d3,d0
	and.b	d4,d0
	bne.s	anal_skip
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	btst	#3,d0
	beq.s	anal_skip
	move.b	d1,d0
	and.b	#$0f,d0
	cmp.b	d0,d7
	bcc.s	1$
	move.b	d0,d7
1$	lsr.b	#4,d1
	ext.w	d0
	ext.w	d1
	mulu	d1,d0
	cmp.l	d0,d5
	bcc.s	anal_skip
	move.l	d0,d5
anal_skip	addq.b	#1,d3
	cmp.b	#8,d3
	bcs.s	anal3
anal2	subq.b	#1,d6
	bne.s	anal1
	rts

keytab0	dc.b	'TILDE',0,'ONE',0,'TWO',0,'THREE',0,'FOUR',0,'FIVE',0,'SIX',0,'SEVEN',0,'EIGHT',0	;0
	dc.b	'NINE',0,'ZERO',0,'MINUS',0,'EQUAL',0,'BACKSLASH',0,'???1',0,'K0',0		;9
	dc.b	'Q',0,'W',0,'E',0,'R',0,'T',0,'Y',0,'U',0,'I',0		;10
	dc.b	'O',0,'P',0,'LBRACK',0,'RBRACK',0,'???2',0,'K1',0,'K2',0,'K3',0	;18
	dc.b	'A',0,'S',0,'D',0,'F',0,'G',0,'H',0,'J',0,'K',0		;20
	dc.b	'L',0,'SEMICOLON',0,'APOSTROPHE',0,'HASH',0,'???3',0,'K4',0,'K5',0,'K6',0 ; 28
	dc.b	'LESS',0,'Z',0,'X',0,'C',0,'V',0,'B',0,'N',0,'M',0	;30
	dc.b	'COMMA',0,'DOT',0,'SLASH',0,'???4',0,'KDOT',0,'K7',0,'K8',0,'K9',0	;38
	dc.b	0

keytab1	dc.b	'SPACE',0,'BACKSPACE',0,'TAB',0,'KENTER',0,'ENTER',0,'ESC',0,'DEL',0,'???5',0	;40
	dc.b	'???6',0,'???7',0,'KMINUS',0,'???8',0,'UP',0,'DOWN',0,'RIGHT',0,'LEFT',0		;48
	dc.b	'F1',0,'F2',0,'F3',0,'F4',0,'F5',0,'F6',0,'F7',0,'F8',0				;50
	dc.b	'F9',0,'F10',0,'KLBRACK',0,'KRBRACK',0,'KSLASH',0,'KASTERISK',0,'KPLUS',0,'HELP',0		;58
	dc.b	'LSHIFT',0,'RSHIFT',0,'CAPSLOCK',0,'CONTROL',0,'LALT',0,'RALT',0,'LAMIGA',0,'RAMIGA',0 ;60
	dc.b	0

	tags

	exitrout	cleanup
	template	<FROM/A,TO>
	dv.l	from
	dv.l	to

	finish

	end
