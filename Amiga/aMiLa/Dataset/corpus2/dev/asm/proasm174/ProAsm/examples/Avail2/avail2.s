;-------------------------------------------------------------------------------
*                                                                              *
* Avail2                                                                       *
*                                                                              *
* Written 1992 by Daniel Weber                                                 *
*                                                                              *
*                                                                              *
*       Filename        avail2.s                                               *
*       Author          Daniel Weber                                           *
*       Version         1.04                                                   *
*       Start           1992                                                   *
*                                                                              *
*       Last Revision   16.09.93                                               *
*                                                                              *
;-------------------------------------------------------------------------------

	output	'ram:avail2'

;	opt	o+,q+,ow-,qw-
	super
	verbose
	base	progbase

;	multipass

	filenote	'Avail2, written 1992 by Daniel Weber'

;-------------------------------------------------------------------------------

	incdir	'include:'

	include	exec/execbase.i
	include	exec/memory.i
	incequ	'LVO.s'

;-------------------------------------------------------------------------------

version		equr	"1.04"


;-- user definitions --
AbsExecBase	equ	4


;MemList		equ	322
;MEMF_CHIP		equ	2
;MEMF_FAST		equ	4
;MEMF_LARGEST		equ	$20000
;
;MH_ATTRIBUTES		equ	14
;MH_FIRST		equ	16
;MH_LOWER		equ	20
;MH_UPPER		equ	24
;MH_FREE		equ	28
;MH_SIZE		equ	32
;
;_LVOOldOpenLibrary	equ	-408
;_LVOCloseLibrary	equ	-414
;_LVOForbid		equ	-132
;_LVOPermit		equ	-138
;_LVOAvailMem		equ	-216
;_LVORawDoFmt		equ	-522
;_LVOWrite		equ	-48
;_LVOOutput		equ	-60


;-------------------------------------------------------------------------------
progbase:
	bra.s	start
	dc.b	0,"$VER: Avail2 ",version," (",__date2,")",0
	even

;----------------------------
start:	movem.l	d0-a6,-(a7)
	lea	progbase(pc),a5
	move.l	a0,cmdline(a5)
	move.l	d0,cmdsize(a5)
	lea	DosName(pc),a1
	move.l	(AbsExecBase).w,a6
	jsr	_LVOOldOpenLibrary(a6)
	move.l	d0,DosBase(a5)
	beq.s	.nodos

	move.l	d0,a6
	jsr	_LVOOutput(a6)
	move.l	d0,outputhd(a5)

	bsr	getcommandline
	bne.s	.exit
	bsr.s	avail


.exit:	move.l	DosBase(pc),a1
	move.l	(AbsExecBase).w,a6
	jsr	_LVOCloseLibrary(a6)

.nodos:	movem.l	(a7)+,d0-a6
	moveq	#0,d0
	rts



;----------------------------------------------------------
;
; evaluate available/used memory
;
avail:	lea	menline(pc),a0
	bsr	write

	move.b	flag(pc),d0
	bmi.s	.fast
	beq.s	.chip
	subq.w	#2,d0
	bne.s	.chip

	move.l	#$7fffffff,d0
	moveq	#0,d1
	move.l	(AbsExecBase).w,a6
	jsr	_LVOAllocMem(a6)
	clr.b	flag(a5)

.chip:	move.l	(AbsExecBase).w,a6		;chip memory
	jsr	_LVOForbid(a6)
	move.l	MemList(a6),a5
	moveq	#MEMF_CHIP,d1
	bsr	takerawlist
	move.l	#memchip,(a1)+
	bsr	calcmem

	jsr	_LVOPermit(a6)
	bsr	doraw
	move.b	flag(pc),d0
	bne.s	notot
	jsr	_LVOForbid(a6)


.fast:	lea	memarray(pc),a1			;fast memory
	lea	workspace(pc),a0
	move.l	(a1),(a0)+
	move.l	4(a1),(a0)+
	move.l	8(a1),(a0)+
	move.l	12(a1),(a0)+
	bsr	takerawlist
	move.l	#memfast,(a1)+
	moveq	#MEMF_FAST,d1
	move.l	(AbsExecBase).w,a6
	move.l	MemList(a6),a5
	bsr	calcmem

	jsr	_LVOPermit(a6)
	bsr	doraw
	move.b	flag(pc),d0
	bne.s	notot

	lea	memarray(pc),a1
	lea	workspace(pc),a0
	moveq	#4-1,d7

calcloop:				;evaluate total sums
	move.l	(a0)+,d0
	add.l	d0,(a1)+
	dbra	d7,calcloop
	lea	rawlist(pc),a1
	move.l	#memtot,(a1)
	bsr.s	doraw
notot:	rts



;------------------
;
;a1: rawlist
;a5: memlist (memory region header)
;
calcmem2:
	move.w	MH_ATTRIBUTES(a5),d0
	and.w	d1,d0
	beq.s	nextblock
	move.l	MH_UPPER(a5),d3
	sub.l	MH_LOWER(a5),d3
	add.l	d3,12(a1)		;set in maximum
	add.l	d3,4(a1)		;set in maximum (later: -available)
	move.l	d1,d2
	bsr.s	availmem
	move.l	d0,(a1)			;set in availabel
	move.l	d1,d2
	ori.l	#MEMF_LARGEST,d1
	bsr.s	availmem
	move.l	d2,d1
	move.l	d0,8(a1)		;set in largest
	clr.l	16(a1)			;set end of doraw mark

nextblock:
	move.l	(a5),a5			;get next (LN_SUCC (exec/nodes.i))

calcmem:
	tst.l	(a5)
	bne.s	calcmem2
	move.l	(a1),d0
	sub.l	d0,4(a1)		;set: in-use
	rts


;------------------
availmem:				;AvailMem()
	movem.l	d1-d2/a1,-(a7)
	move.l	(AbsExecBase).w,a6
	jsr	_LVOAvailMem(a6)
	movem.l	(a7)+,d1-d2/a1
	rts


;------------------
takerawlist:				;prepare raw list for doraw command
	lea	rawlist(pc),a1
	clr.l	(a1)
	clr.l	4(a1)
	clr.l	8(a1)
	clr.l	12(a1)
	clr.l	16(a1)
	clr.l	20(a1)
	rts



;----------------------------
;
; doraw - print a raw formated text
;
;
doraw:	move.l	typ(pc),a0
	lea	rawlist(pc),a1
doraw2:	lea	workmem(pc),a3			;a0: format string, a1: rawlist
doraw3:	move.l	a3,-(a7)			;a3: destination buffer
	lea	.setin(pc),a2
	move.l	(AbsExecBase).w,a6
	jsr	_LVORawDoFmt(a6)
	move.l	(a7)+,a0
	bra	write

.setin:	move.b	d0,(a3)+
	rts


;----------------------------
;
; write text to stdout
;
; a0: text to be written
;
write:	movem.l	d0-a6,-(sp)

.smartwriteloop:
	tst.b	(a0)
	beq.s	.allwritten
	move.l	a0,a1

.loop:	tst.b	(a1)
	beq.s	.nowprint
	cmp.b	#10,(a1)+			;LineFeed
	bne.s	.loop

.nowprint:
	move.l	a0,d2
	move.l	a1,-(sp)
	move.l	a1,d3
	sub.l	d2,d3
	move.l	outputhd(pc),d1
	move.l	DosBase(pc),a6
	jsr	-48(a6)
	move.l	(sp)+,a0
	bra.s	.smartwriteloop

.allwritten:
	movem.l	(sp)+,d0-a6
	rts


;--------------------------------------------------------------------
;
; simple command line parser
;
; <-h, -f, -c>
;
getcommandline:
	clr.b	flag(a5)
	move.l	cmdline(pc),a0
	move.l	cmdsize(pc),d0
gcloop:	move.b	(a0)+,d1
	cmp.b	#10,d1
	beq.s	ender
	cmp.b	#" ",d1
	bne.s	para
	dbra	d0,gcloop
ender:	moveq	#0,d0
	rts


para:	cmp.b	#"-",d1				;parameter?
	bne.s	usage
next:	move.b	(a0)+,d1
	cmp.b	#"h",d1				;hex format
	bne.s	.f
	pea	hexer(pc)
	move.l	(a7)+,typ(a5)
	bra.s	ender
.f:	moveq	#-1,d0
	cmp.b	#"f",d1				;fastmem
	beq.s	.flush
.c:	moveq	#1,d0
	cmp.b	#"c",d1				;chipmem
	bne.s	usage
.set:	move.b	d0,flag(a5)
	bra.s	ender

.flush:	cmp.b	#"l",(a0)
	bne.s	.set
	moveq	#2,d0
	addq.l	#1,a0
	cmp.b	#"u",(a0)+
	bne.s	usage
	cmp.b	#"s",(a0)+
	bne.s	usage
	cmp.b	#"h",(a0)+
	beq.s	.set

usage:	lea	usagetxt(pc),a0			;print usage
	bsr	write
badout:	moveq	#-1,d0
	rts




;-------------------------------------------------------------------------------
DosName:	dc.b	"dos.library",0
memchip:	dc.b	"chip ",0
memfast:	dc.b	"fast ",0
memtot:		dc.b	"total",0
menline:	dc.b	$9b,"1mAvail2 v",version,$9b,"0m by Daniel Weber",$a
		dc.b	"Type  Available    In-Use   Largest   Maximum",$a,0
string:		dc.b	"%-5s  %8ld  %8ld  %8ld  %8ld",$a,0
hexer:		dc.b	"%-5s $%08lx $%08lx $%08lx $%08lx",10,0

usagetxt:	dc.b	$9b,"1mAvail2",$9b,"0m by Daniel Weber",$a
		dc.b	"Usage: Avail2 (-[h|c|f|flush])",$a
		dc.b	"       -h     : output in hex format",$a
		dc.b	"       -c     : report chipmem only",$a
		dc.b	"       -f     : report fastmem only",$a
		dc.b	"       -flush : flush libraries first",$a,0
		even

typ:		dc.l	string

;-------------------------------------------------------------------------------

DosBase:	dx.l	1
outputhd:	dx.l	1
cmdline:	dx.l	1
cmdsize:	dx.l	1
flag:		dx.b	1
		aligndx.w

rawlist:	dx.l	1		;\ must be kept together!
memarray:	dx.l	5		;/
workspace:	dx.l	6,0
workmem:	dx.b	80,0

;-------------------------------------------------------------------------------
	end
