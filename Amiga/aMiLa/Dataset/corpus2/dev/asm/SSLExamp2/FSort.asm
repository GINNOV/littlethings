; File Sorting Utility 1.1
; (c) 1994 MJSoft System Software, Martin Mares

;DEBUG	set	1
_GlobVec	set	1
;GATHERTX	set	1
;TEXTRACT	set	1

	include	"ssmac.h"

QUANTLOG	equ	13
QUANTUM	equ	1<<QUANTLOG

	clistart

	get.l	stdin,d7
	dt	siname,<STDIN>
	tpea	siname
	get.l	ffrom,d1
	beq.s	ReadInit
	move.l	d1,a0
	move.l	a0,(sp)
	moveq	#OPEN_OLD,d0
	call	TrackOpen
	move.l	d0,d7
	put.l	d1,srctrk
	dv.l	srctrk
ReadInit	moveq	#0,d6
	moveq	#0,d5		; Pointer to first block
	moveq	#10,d4

ReadIn	moveq	#64,d0
	lsl.l	#QUANTLOG-6,d0
	move.l	d0,d3
	call	TrackAllocPub
	move.l	d0,a3
	add.l	d0,d3
	move.l	d5,(a3)
	move.l	a3,d5
	addq.l	#6,a3
	move.l	a3,a4
	bra.s	CPL
CPL1	move.b	(a2)+,(a3)+
CPL	dbf	d6,CPL1
	move.l	d7,d1
	move.l	a3,d2
	sub.l	d2,d3
	call	TestBreak
	call	dos,Read
	move.l	(v),a6
	add.l	d0,a3
	move.l	a3,d1
	sub.l	a4,d1
	move.w	d1,-(a4)
	tst.l	d0
	ble.s	EndOrErr
	move.l	a3,d6
	subq.w	#1,d0
RIFindEOL	cmp.b	-(a3),d4
	dbeq	d0,RIFindEOL
	beq.s	RIFoundEOL
	dtl	<Line too long>,a0
	jump	ExitError

RIFoundEOL	addq.l	#1,a3
	sub.l	a3,d6
	sub.w	d6,(a4)
	move.l	a3,a2
	bra.s	ReadIn

EndOrErr	beq.s	PrepareIndex
	moveq	#err_read,d0
reperrsp	move.l	(sp),a1
	jump	ss,ReportError

PrepareIndex	tst.w	(a4)
	beq.s	LastLineOK
	cmp.b	-1(a3),d4
	beq.s	LastLineOK
	move.b	d4,(a3)
	addq.w	#1,(a4)

LastLineOK	move.l	d5,a0
	moveq	#0,d0
.pi	move.l	(a0)+,d1
	move.w	(a0)+,d2
	beq.s	.nx
	subq.w	#1,d2
.loop	cmp.b	(a0)+,d4
.next	dbeq	d2,.loop
	bne.s	.nx
	addq.l	#1,d0
	dbf	d2,.loop
.nx	move.l	d1,a0
	tst.l	d1
	bne.s	.pi

	move.l	d0,d6
	lsl.l	#2,d0
	moveq	#64,d2
	lsl.l	#4,d2
	add.l	d2,d0
	call	TrackAllocPub
	move.l	d0,a4		; A4=buf start
	move.l	d0,a1
	add.l	d2,a1
	move.l	a1,a3		; A3=buf limit
	move.l	d5,a0
.idx	move.l	(a0)+,d1
	move.w	(a0)+,d2
	beq.s	.nxx
	subq.w	#1,d2
.lin	move.l	a0,(a1)+
.chr	cmp.b	(a0)+,d4
	dbeq	d2,.chr
	bne.s	.nxx
	sf	-1(a0)
	dbf	d2,.lin
.nxx	move.l	d1,a0
	tst.l	d1
	bne.s	.idx

	move.l	d6,d0
	move.l	a3,a0
	lea	cmpf(pc),a1
	tsv.l	case
	beq.s	go1
	lea	cmpfcase(pc),a1
go1	moveq	#4,d1
	call	QuickSort

	get.l	srctrk,a0
	call	FreeObject
	get.l	stdout,d7
	dt	soname,<STDOUT>
	tpea	soname
	get.l	fto,d1
	beq.s	wrt1
	move.l	d1,a0
	moveq	#OPEN_NEW,d0
	move.l	a0,(sp)
	call	TrackOpen
	move.l	d0,d7
wrt1	move.l	a4,a2		; A2=buf current
	subq.l	#1,d6
	bmi.s	done
	move.l	d6,d5
	swap	d5
wrt2	move.l	(a3)+,a0
wrt3	cmp.l	a2,a3
	bne.s	wrt4
	push	a0
	bsr.s	flushbuf
	pop	a0
wrt4	move.b	(a0)+,(a2)+
	bne.s	wrt3
	move.b	d4,-1(a2)
	dbf	d6,wrt2
	dbf	d5,wrt2

done	bsr.s	flushbuf
	addq.l	#8,sp
	rts

flushbuf	move.l	d7,d1
	move.l	a4,d2
	move.l	a2,d3
	sub.l	d2,d3
	beq.s	flubu1
	call	ss,TestBreak
	call	dos,Write
	cmp.l	d0,d3
	bne.s	wrterr
flubu1	move.l	a4,a2
	rts

wrterr	moveq	#err_write,d0
	bra	reperrsp

cmpfcase	move.l	(a0),a0
	move.l	(a1),a1
caseloop	move.b	(a0)+,d0
	beq.s	caseend
	cmp.b	(a1)+,d0
	beq.s	caseloop
	bcs.s	bgta
agtb	moveq	#1,d0
	rts
bgta	moveq	#-1,d0
	rts
caseend	tst.b	(a1)
	bne.s	bgta
	moveq	#0,d0
	rts

cmpf	move.l	(a0),a0
	move.l	(a1),a1
cfloop	move.b	(a0)+,d0
	beq.s	caseend
	move.b	(a1)+,d1
	cmp.b	#'a',d0
	bcs.s	1$
	cmp.b	#'z'+1,d0
	bcc.s	1$
	sub.b	#32,d0
1$	cmp.b	#'a',d1
	bcs.s	2$
	cmp.b	#'z'+1,d1
	bcc.s	2$
	sub.b	#32,d1
2$	cmp.b	d1,d0
	beq.s	cfloop
	bcs.s	bgta
	bra.s	agtb

	dt	<$VER: FSort 1.1 © 1994 MJSoft System Software>
	tags
	template	<FROM,TO,CASE/S>
	dv.l	ffrom
	dv.l	fto
	dv.l	case
	finish
	end
