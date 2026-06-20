; DVI Typer
; (c) 1993 MJSoft System Software, Martin Mares

	include	"ssmac.h"

	tbase	a4
	start

	dv.w	postflag
	dv.l	posn
	dbuf	pfbuf,44

	get.l	from,a0
	move.l	#1005,d0
	call	TrackOpen
	move.l	d0,d7		; D7=fh
	lea	getc(pc),a3

loop	call	ss,TestBreak
	dtl	<%6ld >,a0
	geta	posn,a1
	call	Printf
	bsr	getc
	moveq	#0,d6
	move.b	d0,d6		; D6=current command
	bpl.s	setchar
	sub.b	#171,d0
	bcs.s	command
	sub.b	#64,d0
	bcs.s	setfont
command	ext.w	d0		; D0=command#-43
	add.w	d0,d0
	lea	cmdtab+43*2(pc),a0
	move.w	0(a0,d0.w),d0
	move.w	d0,d2
	and.w	#$FFF,d0
	lea	0(a4,d0.w),a0
	call	ss,Puts
	rol.w	#5,d2
	and.w	#$001E,d2
	geta	pfbuf,a2
	move.w	routs(pc,d2.w),d0
	jsr	routs(pc,d0.w)
	moveq	#10,d2
	bsr	putc
	bra.s	loop

rout	macro
	dc.w	\1-routs
	endm

routs	rout	nopar
	rout	parn
	rout	parn
	rout	parn
	rout	parn
	rout	par44
	rout	parbop
	rout	parspec
	rout	parfnt
	rout	parpre
	rout	parpost
	rout	parppost
	rout	parerr
	rout	paruns
	rout	paruns
	rout	paruns

setfont	dtl	<Font	%d',10,'>,a2
	add.b	#64,d0
	bra.s	cmdd0

setchar	dtl	<Char	%d',10,'>,a2
cmdd0	move.w	d0,-(sp)
	move.l	sp,a1
	move.l	a2,a0
	call	ss,Printf
	addq.l	#2,sp
	bra	loop

; 0=no,1=B,2=W,3=3B,4=L,5=L+L,6=BOP,7=Special,8=FntDef,9=Pre,10=Post,11=PPost
; 12=SNErr,13=unsigned B,14=unsigned W,15=unsigned 3B

cmd	macro	*name,params
	ifne	NARG-1
	dt	\@a,<\2>
	elseif
	dt.c	\@a,<>
	endc
	dc.w	\@a-TEXTBASE+(\1<<12)
	endm

cmdtab	cmd	13
	cmd	14
	cmd	15
	cmd	4,<Set>
	cmd	5,<SetRule>
	cmd	13
	cmd	14
	cmd	15
	cmd	4,<Put>
	cmd	5,<PutRule>
	cmd	0,<Nop>
	cmd	6,<Bop>
	cmd	0,<Eop>
	cmd	0,<Push>
	cmd	0,<Pop>
	cmd	1
	cmd	2
	cmd	3
	cmd	4,<Right>
	cmd	0,<W0>
	cmd	1
	cmd	2
	cmd	3
	cmd	4,<W>
	cmd	0,<X0>
	cmd	1
	cmd	2
	cmd	3
	cmd	4,<X>
	cmd	1
	cmd	2
	cmd	3
	cmd	4,<Down>
	cmd	0,<Y0>
	cmd	1
	cmd	2
	cmd	3
	cmd	4,<Y>
	cmd	0,<Z0>
	cmd	1
	cmd	2
	cmd	3
	cmd	4,<Z>
	cmd	13
	cmd	14
	cmd	15
	cmd	4,<Fnt>
	cmd	7
	cmd	7
	cmd	7
	cmd	7,<Spec>
	cmd	8
	cmd	8
	cmd	8
	cmd	8,<FntDef>
	cmd	9,<Pre>
	cmd	10,<Post>
	cmd	11,<PPost>
	cmd	12
	cmd	12
	cmd	12
	cmd	12
	cmd	12
	cmd	12,<???>

getc	addqv.l	#1,posn
	move.l	d7,d1
	call	dos,FGetC
	tst.l	d0
	bmi.s	errr
ret	rts

errr	call	IoErr
	move.l	(v),a6
	tst.l	d0
	bne.s	doserr
	tstv.b	postflag
	bne.s	exitcl
	dtl	<Unexpected end of file>,a0
	jump	ExitError
exitcl	moveq	#10,d2
	bsr	putc
	jump	ss,ExitCleanup
doserr	dtl	<Error reading %s>,a0
	geta	from,a1
	jump	DosError

parn	lsr.w	#1,d2
	move.w	d2,d3
	subq.w	#1,d3
	moveq	#0,d4
	jsr	(a3)
	move.b	d0,d4
	ext.w	d4
	ext.l	d4
	bra.s	1$
2$	jsr	(a3)
	lsl.l	#8,d4
	move.b	d0,d4
1$	dbf	d3,2$
pftwox	dtl	<%ld	%ld>,a0
pftwo	move.l	d2,(a2)+
	move.l	d4,(a2)+
	bra	printfb

paruns	lsr.w	#1,d2
	sub.w	#12,d2
	move.w	d2,d3
	subq.w	#1,d3
	bsr.s	getseq
	bra.s	pftwox

parppost	bsr.s	getl
	jsr	(a3)
	subq.b	#2,d0
	errc.eq	<Invalid postamble ID>
	dtl	<	PostPtr=%ld>,a0
	move.l	d4,(a2)+
	bsr.s	printfb
	stv	postflag
ppp1	jsr	(a3)
	cmp.b	#223,d0
	beq.s	ppp1
	err	<Garbage after PostPost>

par44	bsr.s	getl
	move.l	d4,d2
	bsr.s	getl
	dtl	<	%ld,%ld>,a0
	bra.s	pftwo

getl	moveq	#3,d3
getseq	moveq	#0,d4
.loop	jsr	(a3)
	lsl.l	#8,d4
	move.b	d0,d4
	dbra	d3,.loop
	rts

parspec	sub.b	#239,d6
	bsr.s	putxx
	moveq	#'"',d2
	bsr.s	putc
	tst.l	d4
	beq.s	retq
.doit	jsr	(a3)
	move.l	d0,d2
	bsr.s	putc
	subq.l	#1,d4
	bne.s	.doit
retq	moveq	#'"',d2
putc	get.l	stdout,d1
	jump	dos,FPutC

putxx	move.l	d6,d2
	add.b	#'1',d2
	bsr.s	putc
	moveq	#9,d2
	bsr.s	putc
	move.l	d6,d3
	bra.s	getseq

parbop	moveq	#10,d2
	bsr.s	get31
	dtl	<	%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,BackPtr=%ld>,a0
printfb	geta	pfbuf,a1
	jump	ss,Printf

get3	moveq	#2,d2
get31	bsr.s	getl
	move.l	d4,(a2)+
	dbf	d2,get31
nopar	rts

parfnt	sub.b	#243,d6
	bsr.s	putxx
	move.l	d4,(a2)+
	bsr.s	get3
	jsr	(a3)
	move.l	d0,(a2)+
	dtl	<%ld,Sum=%08lx,Scale=%ld,DesignSize=%ld,Area=%ld,">,a0
parnamepf	bsr.s	printfb
parname	jsr	(a3)
	move.l	d0,d3
	bra.s	parfnt2
parfnt1	jsr	(a3)
	move.l	d0,d2
	bsr.s	putc
parfnt2	dbf	d3,parfnt1
	bra.s	retq

parpre	jsr	(a3)
	subq.b	#2,d0
	errc.eq	<Invalid DVI type !>
	bsr.s	get3
	dtl	<	Num=%ld,Den=%ld,Mag=%ld,">,a0
	bra.s	parnamepf

parpost	moveq	#5,d2
	bsr.s	get31
	moveq	#1,d2
.xxx	moveq	#1,d3
	bsr	getseq
	move.l	d0,(a2)+
	dbf	d2,.xxx
	dtl	<	FinalBOP=%ld,Num=%ld,Den=%ld,Mag=%ld,L=%ld,U=%ld,Stack=%ld,Pages=%ld>,a0
	bra.s	printfb

parerr	err	<DVI file corrupted>

	tags
	template <FROM/A>
	dv.l	from
	extrahelp
	dc.b	'This is DVIType 1.0   (c) 1993 Martin Mares, MJSoft System Software',10,10
	dc.b	'Usage: DVIType <DVI file>',10
	endhelp
	finish
	end
