	xdef	SForm
	xref	Sprintf
	xref	LstPage,CurName
	opt	o+,w-
	include	"comequ.s"
;  #[ REMs:
;Sert a TTL, SUBTTL, FORMAT, LFORMAT
;
;in:
;a0=ascii buffer
;a1=format
;d0=max chars
;out:
;d0=sprinted chars
;
;add:
;mfree, time, version, macro depth, include depth, line #, listing line #
;secsize, machine code
;
;%:
;#	page #
;d	date
;f	filename of
;	i	include
;	l	listing
;	o	output
;	s	source
;m	macro source line ?
;l	last
;	e	error
;	w	warning
;n	main source name (wo suffix)
;p	path of
;	i	include
;	l	listing
;	o	output
;	s	source
;r	carriage return
;s	normal source line
;t	total
;	e	error
;	w	warning
;
;  #] REMs:
;  #[ EQUates:
BLINDOS	EQU	1
	STRUCTINIT
	PTR	START_BUF
	SIZEOF	LOCALS_SIZE
;  #] EQUates:
;  #[ Sprintf:

SForm:	move.w	#254,d0
	link	a2,#0
	movem.l	d1-d2/a0-a3,-(sp)
	addq.w	#8,a2
	bsr.s	.sprintf
	movem.l	(sp)+,d1-d2/a0-a3
	unlk	a2
	rts

.sprintf:	movem.l	d3-d7/a3-a6,-(sp)
	lea	-LOCALS_SIZE(sp),sp
	move.l	sp,a6
	move.l	a0,START_BUF(a6)
	move.l	a0,a4
	move.l	a1,a3
	move.l	d0,d7

.nxtper:	;stack checking
	;buffer checking
	tst.w	d7
	ble.s	.end
;	lea	SIGNED_FLAG(a6),a0
;	clr.l	(a0)+	;signed,char,hexa,decimal
	moveq	#'%',d1

.nxtchar:	move.b	(a3)+,d0
	cmp.b	d1,d0
	beq.s	.doper
	move.b	d0,(a4)+
	bne.s	.nxtchar
	lea	-1(a3),a1
	lea	-1(a4),a0
.ret:	move.l	a0,d0
	sub.l	START_BUF(a6),d0
	lea	LOCALS_SIZE(sp),sp
	movem.l	(sp)+,d3-d7/a3-a6
	rts
.end:	move.l	a3,a1
	move.l	a4,a0
	clr.b	(a0)
	bra.s	.ret
.doper:	moveq	#0,d0
	move.b	(a3)+,d0
	bmi	.unknown
	sub.b	#' ',d0
	bmi	.unknown
	add.w	d0,d0
	move.w	.table(pc,d0.w),d0
	jmp	.table(pc,d0.w)

.table:	dc.w	.unknown-.table	;' '
	dc.w	.unknown-.table	;!
	dc.w	.unknown-.table	;"
	dc.w	.diese-.table	;#
	dc.w	.unknown-.table	;$
	dc.w	.percent-.table	;%
	dc.w	.unknown-.table	;&
	dc.w	.unknown-.table	;'
	dc.w	.unknown-.table	;(
	dc.w	.unknown-.table	;)
	dc.w	.unknown-.table	;*
	dc.w	.unknown-.table	;+
	dc.w	.unknown-.table	;,
	dc.w	.unknown-.table	;-
	dc.w	.unknown-.table	;.
	dc.w	.unknown-.table	;/
	dc.w	.unknown-.table	;0
	dc.w	.unknown-.table	;1
	dc.w	.unknown-.table	;2
	dc.w	.unknown-.table	;3
	dc.w	.unknown-.table	;4
	dc.w	.unknown-.table	;5
	dc.w	.unknown-.table	;6
	dc.w	.unknown-.table	;7
	dc.w	.unknown-.table	;8
	dc.w	.unknown-.table	;9
	dc.w	.unknown-.table	;:
	dc.w	.unknown-.table	;;
	dc.w	.unknown-.table	;<
	dc.w	.unknown-.table	;=
	dc.w	.unknown-.table	;>
	dc.w	.unknown-.table	;?
	dc.w	.unknown-.table	;@
	dc.w	.unknown-.table	;A
	dc.w	.unknown-.table	;B
	dc.w	.unknown-.table	;C
	dc.w	.unknown-.table	;D
	dc.w	.unknown-.table	;E
	dc.w	.unknown-.table	;F
	dc.w	.unknown-.table	;G
	dc.w	.unknown-.table	;H
	dc.w	.unknown-.table	;I
	dc.w	.unknown-.table	;J
	dc.w	.unknown-.table	;K
	dc.w	.unknown-.table	;L
	dc.w	.unknown-.table	;M
	dc.w	.unknown-.table	;N
	dc.w	.unknown-.table	;O
	dc.w	.unknown-.table	;P
	dc.w	.unknown-.table	;Q
	dc.w	.unknown-.table	;R
	dc.w	.unknown-.table	;S
	dc.w	.unknown-.table	;T
	dc.w	.unknown-.table	;U
	dc.w	.unknown-.table	;V
	dc.w	.unknown-.table	;W
	dc.w	.unknown-.table	;X
	dc.w	.unknown-.table	;Y
	dc.w	.unknown-.table	;Z
	dc.w	.unknown-.table	;[
	dc.w	.unknown-.table	;\
	dc.w	.unknown-.table	;]
	dc.w	.unknown-.table	;^
	dc.w	.unknown-.table	;_
	dc.w	.unknown-.table	;`
	dc.w	.unknown-.table	;a
	dc.w	.unknown-.table	;b
	dc.w	.unknown-.table	;c
	dc.w	.unknown-.table	;d
	dc.w	.unknown-.table	;e
	dc.w	.unknown-.table	;f
	dc.w	.unknown-.table	;g
	dc.w	.unknown-.table	;h
	dc.w	.unknown-.table	;i
	dc.w	.unknown-.table	;j
	dc.w	.unknown-.table	;k
	dc.w	.last-.table	;l
	dc.w	.unknown-.table	;m
	dc.w	.unknown-.table	;n
	dc.w	.unknown-.table	;o
	dc.w	.unknown-.table	;p
	dc.w	.unknown-.table	;q
	dc.w	.unknown-.table	;r
	dc.w	.unknown-.table	;s
	dc.w	.unknown-.table	;t
	dc.w	.unknown-.table	;u
	dc.w	.unknown-.table	;v
	dc.w	.unknown-.table	;w
	dc.w	.unknown-.table	;x
	dc.w	.unknown-.table	;y
	dc.w	.unknown-.table	;z
	dc.w	.unknown-.table	;{
	dc.w	.unknown-.table	;|
	dc.w	.unknown-.table	;}
	dc.w	.unknown-.table	;~
	dc.w	.unknown-.table	;delta

.percent:	move.b	d1,(a4)+
	bra	.nxtper

.diese:	move.l	LstPage,d0
.longd:	move.l	d0,-(sp)
	move.l	a4,a0
	lea	.l_fmt(pc),a1
	bsr	Sprintf
	addq.w	#4,sp
	add.w	d0,a4
	bra	.nxtper
.l_fmt:	dc.b	"%=ld",0
	even

.unknown:	IFNE	BLINDOS
	_Debugger
	ENDC
	move.b	#'?',(a4)+
	bra	.doper

.last:	move.b	(a3)+,d0
	beq.s	.unknown
	cmp.b	#'e',d0
	beq.s	.lerr
	cmp.b	#'w',d0
	bne.s	.unknown

.lwarn:	move.w	LastWarn,d0
	bra.s	.wordd
.lerr:	move.w	LastErr,d0
.wordd:	move.w	d0,-(sp)
	move.l	a4,a0
	lea	.w_fmt(pc),a1
	bsr	Sprintf
	addq.w	#2,sp
	add.w	d0,a4
	bra	.nxtper
.w_fmt:	dc.b	"%=d",0
	even

;  #] Sprintf:

