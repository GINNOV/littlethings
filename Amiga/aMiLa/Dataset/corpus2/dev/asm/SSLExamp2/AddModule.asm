; Add Resident Module
; (c) 1993 MJSoft System Software
; Martin Mares

;DEBUG	set	1

	include	"ssmac.h"

	rsreset			; KickMem & KickTag structure
kb_kickmem	rs.b	ML_SIZE
kb_kicktag	rs.l	2
kb_sizeof	rs.b	0

	clistart

	get.l	module,a0
	move.l	#1005,d0
	call	TrackOpen
	pea	freefunc(pc)
	pea	allocfunc(pc)
	get.l	dosbase,a6
	pea	_LVORead(a6)
	move.l	sp,a1
	sub.l	a0,a0
	clr.l	-(sp)
	move.l	sp,a2
	call	InternalLoadSeg
	lea	16(sp),sp
	put.l	d0,seglist
	dv.l	seglist
	bne.s	segok
	lea	errmsg(pc),a0
moderr	geta	module,a1
	jump	ss,ExitError

segok	move.l	d0,d7		; D7=copy of SegList
	lea	moderrt(pc),a0
	lsl.l	#2,d0
	move.l	d0,a1
	move.l	-(a1),d0
	lsr.l	#1,d0
	subq.l	#3,d0
	bmi.s	moderr
	move.l	d0,d1
	swap	d1
findtag1	cmp.w	#RTC_MATCHWORD,(a1)+
findtag2	dbeq	d0,findtag1
	dbeq	d1,findtag1
	bne.s	moderr
	move.l	a1,d2
	subq.l	#2,d2
	cmp.l	(a1),d2		; A1=D2+2
	bne.s	findtag2	; D2 contains address of ResidentTag

	get.l	class,d0	; Set options
	beq.s	noclass
	move.l	d0,a0
	move.l	(a0),d0
	move.l	d0,d1
	tst.b	RT_FLAGS-RT_MATCHTAG(a1)
	bpl.s	1$
	bset	#7,d0
1$	move.b	d0,RT_FLAGS-RT_MATCHTAG(a1)
	lsr.l	#7,d1
	lea	badclass(pc),a0
	bne.s	moderr

noclass	get.l	pri,d0
	beq.s	modok
	move.l	d0,a0
	move.l	(a0),d0
	move.b	d0,RT_PRI-RT_MATCHTAG(a1)
	ext.w	d0
	ext.l	d0
	cmp.l	(a0),d0
	lea	badpri(pc),a0
	bne.s	moderr

modok	moveq	#kb_sizeof+8,d0	; Calculate size of KickMem & KickTag
	moveq	#1,d6
	move.l	d7,d5		; D5=SegList
calcsize	lsl.l	#2,d7
	addq.l	#8,d0
	addq.l	#1,d6
	move.l	d7,a0
	move.l	(a0),d7
	bne.s	calcsize
	move.l	d0,d3		; D3=KM+KT size
	move.l	#MEMF_CLEAR+MEMF_PUBLIC,d1
	move.l	4.w,a6
	bsr.s	allocfunc
	tst.l	d0
	bne.s	tagok
	moveq	#err_memory,d0
	jump	ss,ReportError

tagok	move.l	d0,a0
	lea	kb_kickmem+ML_NUMENTRIES(a0),a1
	move.w	d6,(a1)+
	move.l	a0,(a1)
	subq.l	#8,(a1)+
	move.l	d3,(a1)
	addq.l	#8,(a1)+
fillmem	lsl.l	#2,d5
	move.l	d5,a2
	move.l	-(a2),d0
	move.l	a2,(a1)
	subq.l	#8,(a1)+
	addq.l	#8,d0
	move.l	d0,(a1)+
	move.l	4(a2),d5
	bne.s	fillmem

	clrv.l	seglist
	call	Forbid
	lea	KickMemPtr(a6),a2
	move.l	(a2),(a0)
	move.l	a0,(a2)+
	move.l	d2,(a1)+
	move.l	(a2),(a1)
	beq.s	1$
	bset	#7,(a1)
1$	subq.l	#4,a1
	move.l	a1,(a2)+
	call	SumKickData
	move.l	d0,(a2)
	call	Permit

	tsv.l	callinit	; Call module initialization if needed
	beq.s	cl1
	move.l	d2,a1
	jump	InitResident

cleanup	get.l	seglist,d1
	beq.s	cl1
	lea	freefunc(pc),a1
	call	dos,InternalUnLoadSeg
cl1	rts

allocfunc	addq.l	#8,d0
	mpush	d0/d1
	or.l	#MEMF_REVERSE+MEMF_KICK,d1
	call	AllocMem
	tst.l	d0
	bne.s	1$
	movem.l	(sp),d0/d1
	or.l	#MEMF_REVERSE+MEMF_LOCAL,d1
	call	AllocMem
	tst.l	d0
	beq.s	2$
1$	addq.l	#8,d0
2$	addq.l	#8,sp
	rts

freefunc	subq.l	#8,a1
	addq.l	#8,d0
	jump	FreeMem

	dc.b	'$VER: AddModule 1.1 (21.9.93)',0
errmsg	dc.b	'Error loading %s',0
moderrt	dc.b	'%s is not a resident module',0
badclass	dc.b	'Class must be in range 0 to 127',0
badpri	dc.b	'Priority must be in range -128 to 127',0
	even

	tags
	template	<MODULE/A,CLASS/K/N,PRI/K/N,INIT/S>
	dv.l	module
	dv.l	class
	dv.l	pri
	dv.l	callinit
	extrahelp
	dc.b	'Resident Module Adder 1.1 (c) 1993 Martin Mares, MJSoft System Software',10,10
	dc.b	'Usage: AddModule <module> [CLASS <class>] [PRI <priority>] [INIT]',10
	dc.b	'Switches: INIT - call initialization entry of the module after it''s added.',10
	endhelp
	exitrout cleanup
	finish

	end
