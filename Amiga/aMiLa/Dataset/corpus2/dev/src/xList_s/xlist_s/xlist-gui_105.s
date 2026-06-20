; xList-GUI v1.05 (23.10.95), an user-friendly (and cheap) GUI frontend for
; xList (allow recursivity...)
; revision 59
	incdir	raminclude:
	include	dos/dos.i
	include	dos/var.i
	include	lvo/lvos.i
	include	reqtools/reqtools_lib.i
	include	reqtools/reqtools.i
	include	exec/execbase.i
	include	exec/exec.i
	include	exec/types.i

GOOD_FILE	equ	1
NOT_PICKED	equ	0
VARSIZE		equ	8


CALL	MACRO
	jsr	_LVO\1(a6)
	ENDM

JUMP	MACRO
	jmp	_LVO\1(a6)
	ENDM


   STRUCTURE xListGUI_Vars,0
      ULONG xl_dosbase
      ULONG xl_rtbase
      ULONG xl_wbstartup
      ULONG xl_filereq
      ULONG xl_membase
      ULONG xl_fib
      ULONG xl_size
      ULONG xl_lock
      ULONG xl_oldlock
      ULONG xl_tmplock
      ULONG xl_txtdirlock
      ULONG xl_txtlock
      ULONG xl_introfile
      ULONG xl_introdir
      ULONG xl_endfile
      ULONG xl_enddir
      ULONG xl_txtfh
      ULONG xl_txtbuffer
      ULONG xl_oldlock2
      ULONG xl_rdargs
      ULONG xl_argsarray
      ULONG xl_introtxt
      ULONG xl_endtxt
      ULONG xl_append
      ULONG xl_noroot
      ULONG xl_switch
      ULONG xl_listfh
      ULONG xl_dirtoscan
      ULONG xl_varbuff
      ULONG xl_prvarargv
      ULONG xl_bigtotal
      ULONG xl_onedirtot
      ULONG xl_varfh
      ULONG xl_bigvarbuff
      ULONG xl_statfh
      STRUCT xl_typecom_buff,255
      LABEL xl_SIZEOF



progstart
	bra.b	pstart

version
	dc.b	'$VER:'
title
	dc.b	' xList-GUI v1.05 (23.10.95)',0
	even

pstart
	move.l	4.w,a6
	move.l	#xl_SIZEOF+108+fib_SIZEOF,d0
	move.l	#$10001,d1
	CALL	AllocVec
	move.l	d0,a4
	bne.b	memallocated

	bsr	getwbmsg
	move.l	d0,a1
	beq.b	cliexit2
	CALL	Forbid
	CALL	ReplyMsg
cliexit2
	moveq	#103,d0
	rts

memallocated
	add.l	#xl_SIZEOF,d0
	move.l	d0,xl_membase(a4)

	add.l	#108,d0
	move.l	d0,xl_fib(a4)

wb
	moveq	#0,d0
	bsr	getwbmsg
	move.l	d0,xl_wbstartup(a4)

	lea	dosname(pc),a1
	moveq	#36,d0
	CALL	OpenLibrary
	move.l	d0,xl_dosbase(a4)
	beq	replymsg

prog
	lea	rtname(pc),a1
	moveq	#0,d0
	CALL	OpenLibrary
	move.l	d0,xl_rtbase(a4)
	beq	closedos

testprg
	lea	xlistname(pc),a0
	bsr	lockfile
	bne.b	unlockprg

	lea	segname(pc),a0
	bsr	lockfile
	bne.b	unlockprg

	lea	body8(pc),a1
	lea	button8(pc),a2
	bsr	disp_req
	bra	closert

unlockprg
	move.l	d0,d1
	CALL	UnLock

findseg ; if xList is not yet resident
	lea	segname(pc),a0
	move.l	a0,d1
	moveq	#0,d2
	moveq	#0,d3
	CALL	FindSegment ; search
	tst.l	d0
	bne.b	readargs

	lea	xlistname(pc),a0
	move.l	a0,d1
	CALL	LoadSeg ; load code
	tst.l	d0
	bne.b	addseg

	lea	segname(pc),a0
	move.l	a0,d1
	CALL	LoadSeg ; load code
	tst.l	d0
	beq.b	readargs

addseg
	move.l	d0,d2
	lea	segname(pc),a0
	move.l	a0,d1
	moveq	#1,d3
	CALL	AddSegment ; make resident

readargs
	bsr	teststat
	bsr	deletebigvar
	bsr	getbig
	lea	template(pc),a0
	move.l	a0,d1
	lea	xl_argsarray(a4),a0
	move.l	a0,d2
	moveq	#0,d3
	move.l	xl_dosbase(a4),a6
	CALL	ReadArgs
	move.l	d0,xl_rdargs(a4)
	beq	closert
	tst.l	xl_argsarray(a4)
	beq.b	req1
	move.b	#1,xl_switch(a4)
	move.l	xl_argsarray(a4),a5
	move.l	(a5)+,xl_dirtoscan(a4)
	bra	phase2


req1
	move.l	#RT_FILEREQ,d0
	sub.l	a0,a0
	move.l	xl_rtbase(a4),a6
	CALL	rtAllocRequestA
	move.l	d0,xl_filereq(a4)
	bne.b	frallocated

	lea	body1(pc),a1
	lea	button1(pc),a2
	bsr	disp_req
	bra	freeargs

frallocated
	moveq	#0,d0
	move.l	d0,xl_txtdirlock(a4)
	move.l	d0,xl_txtlock(a4)
	move.l	d0,xl_introfile(a4)
	move.l	d0,xl_introdir(a4)
	move.l	d0,xl_endfile(a4)
	move.l	d0,xl_enddir(a4)

welcome
	lea	body2(pc),a1
	lea	button2(pc),a2
	bsr	disp_req
	tst.l	d0
	beq	freereq2

	cmpi.l	#1,d0
	beq.b	req4txt
	beq	popupfr

	lea	body6(pc),a1
	lea	button6(pc),a2
	bsr	disp_req

	lea	body7(pc),a1
	lea	button7(pc),a2
	bsr	disp_req
	bra.b	welcome


req4txt
	lea	body9(pc),a1
	lea	button9(pc),a2
	bsr	disp_req
	cmpi.l	#1,d0
	beq	popupfr
	cmpi.l	#2,d0
	beq	reqintro

reqend
	bsr	choose
	tst.l	d0
	beq.b	req4txt
	move.l	xl_txtdirlock(a4),xl_enddir(a4)
	move.l	xl_txtlock(a4),xl_endfile(a4)
	bra.b	req4txt

choose
	move.l	xl_filereq(a4),a1
	move.l	xl_membase(a4),a2
	clr.b	(a2)
	lea	text2(pc),a3
	move.l	xl_rtbase(a4),a6
	CALL	rtFileRequestA
	tst.l	d0
	bne.b	selected

	moveq	#NOT_PICKED,d0
	rts

selected
	move.l	xl_filereq(a4),a0
	move.l	rtfi_Dir(a0),a0

	bsr	lockfile ; locking dir

	bne.b	txtdirlocked

	moveq	#NOT_PICKED,d0
	rts

txtdirlocked
	move.l	d0,xl_txtdirlock(a4)

	move.l	d0,d1
	move.l	xl_dosbase(a4),a6
	CALL	CurrentDir
	move.l	d0,xl_oldlock2(a4)

	move.l	xl_membase(a4),a0
	bsr	lockfile ; 		lock file
	beq.b	txtnotlocked

txtlocked
	move.l	d0,xl_txtlock(a4)
	move.l	xl_oldlock2(a4),d1
	move.l	xl_dosbase(a4),a6
	CALL	CurrentDir
	move.l	d0,d1
	CALL	UnLock
	moveq	#GOOD_FILE,d0
	rts


txtnotlocked
	move.l	xl_oldlock2(a4),d1
	move.l	xl_dosbase(a4),a6
	CALL	CurrentDir
	move.l	d0,d1
	CALL	UnLock
	moveq	#NOT_PICKED,d0
	rts



nopicked
	lea	body3(pc),a1
	lea	button10(pc),a2
	bra	disp_req

reqintro
	bsr	choose
	tst.l	d0
	beq	req4txt
	move.l	xl_txtdirlock(a4),xl_introdir(a4)
	move.l	xl_txtlock(a4),xl_introfile(a4)
	bra	req4txt

popupfr
	move.l	xl_filereq(a4),a1
	move.l	xl_membase(a4),a2
	clr.b	(a2)
	lea	text1(pc),a3
	lea	tags1(pc),a0
	move.l	xl_rtbase(a4),a6
	CALL	rtFileRequestA
	tst.l	d0
	bne.b	picked

	lea	body3(pc),a1
	lea	button3(pc),a2
	bsr	disp_req
	tst.l	d0
	bne.b	freereq2
	bra	welcome

picked
	move.l	xl_filereq(a4),a0
	move.l	rtfi_Dir(a0),xl_dirtoscan(a4)
	bra.b	phase2

freereq2
	bsr	freereq
	bra	freeargs


freereq
	move.l	xl_filereq(a4),a1
	move.l	xl_rtbase(a4),a6
	JUMP	rtFreeRequest

phase2
	move.l	xl_dirtoscan(a4),a0
	bsr	lockfile
	move.l	d0,xl_lock(a4)
	bne.b	dirlocked

	tst.b	xl_switch(a4)
	bne	befloop

	lea	body4(pc),a1
	lea	button4(pc),a2
	bsr	disp_req
	tst.l	d0
	beq	freeargs
	bra	req1


dirlocked
	move.l	xl_lock(a4),d1
	move.l	xl_dosbase(a4),a6
	CALL	CurrentDir
	move.l	d0,xl_oldlock(a4)

	lea	outname(pc),a0
	bsr	lockfile
	beq.b	eqnoprev

	move.l	d0,d1
	CALL	UnLock

	tst.l	xl_switch(a4)
	beq.b	append_req

	tst.l	xl_append(a4)
	bne	noprev
	bra.b	testdest

append_req
	lea	body5(pc),a1
	lea	button5(pc),a2
	bsr	disp_req

	tst.l	d0
	beq	current

	cmpi.l	#1,d0
eqnoprev
	beq.b	noprev


testdest
	lea	outname2(pc),a0
	bsr	lockfile
	beq.b	rename

	move.l	d0,d1
	CALL	UnLock

	lea	outname2(pc),a0
	add.b	#1,14(a0)
	bra.b	testdest


rename
	lea	outname(pc),a0
	move.l	a0,d1
	lea	outname2(pc),a0
	move.l	a0,d2
	move.l	xl_dosbase(a4),a6
	CALL	Rename

noprev ; ****** Beginning of the serious stuff ******\\\\\\\\\\\\\\\\\\\\\
	bsr	printintro
	clr.l	xl_introfile(a4)

	lea	comline1(pc),a0 ; List >T:xltmp1 lformat "xList >>RAM:xList_out
	bsr	execute

	lea	tmpname(pc),a0
	bsr	lockfile
	move.l	d0,xl_tmplock(a4)
	beq.b	brcurrent

	move.l	d0,d1
	move.l	xl_fib(a4),d2
	CALL	Examine

	move.l	xl_fib(a4),a0
	tst.l	fib_Size(a0)
	bne.b	nonull

	move.l	xl_tmplock(a4),d1
	CALL	UnLock

	lea	dummycom(pc),a0
	bsr	execute

	bsr	printend
	clr.l	xl_endfile(a4)
brcurrent
	bra	current

nonull
	move.l	xl_tmplock(a4),d1
	CALL	UnLock

	tst.l	xl_switch(a4)
	beq.b	rootreq

	tst.l	xl_noroot(a4)
	beq	root
	bra.b	com2

rootreq
	lea	body11(pc),a1
	lea	button11(pc),a2
	bsr	disp_req

	tst.l	d0
	beq.b	com2

root
	lea	dummycom(pc),a0
	bsr	execute

com2
	lea	comline2(pc),a0
;	dc.b	'Sort >NIL: T:xl_tmp1 to T:xl_tmp4',10,'Execute >NIL:'
;	dc.b	' T:xl_tmp4',0

	bsr	execute

	bsr	printend

	lea	tmpname(pc),a0
	move.l	a0,d1
	CALL	DeleteFile

	lea	sortedname(pc),a0
	move.l	a0,d1
	CALL	DeleteFile

current
	move.l	xl_oldlock(a4),d1
	move.l	xl_dosbase(a4),a6
	CALL	CurrentDir
	move.l	d0,d1
	CALL	UnLock


befloop ; scanning finished, next dir (CLI) or mainmenu (GUI)

	bsr	gettotal ; stats stuff

	tst.b	xl_switch(a4)
	beq	frallocated

	move.l	(a5)+,xl_dirtoscan(a4)
	beq	freeargs

	bra	phase2 ; scan the next dir

freeargs
	move.l	xl_rdargs(a4),d1
	move.l	xl_dosbase(a4),a6
	CALL	FreeArgs

	bsr	closestats


closert
	move.l	xl_rtbase(a4),a1
	move.l	4.w,a6
	CALL	CloseLibrary

closedos
	move.l	xl_dosbase(a4),a1
	move.l	4.w,a6
	CALL	CloseLibrary


replymsg
	move.l	xl_wbstartup(a4),d0
	beq.b	CLIExit
	move.l	d0,a1
	CALL	Forbid
	CALL	ReplyMsg

CLIExit
	move.l	a4,a1
	CALL	FreeVec

exit
	moveq	#0,d0
	rts ; My Friend This Is The End.

;************************** misc subroutines
getwbmsg
	move.l	ThisTask(a6),a5
	tst.l	pr_CLI(a5)
	bne.b	FromCLI
	lea	pr_MsgPort(a5),a0
	CALL	WaitPort
	lea	pr_MsgPort(a5),a0
	CALL	GetMsg
FromCLI
	rts

disp_req ; subroutine for RT requesters
	lea	tags2(pc),a0
	sub.l	a3,a3
	move.l	xl_rtbase(a4),a6
	move.l	a4,-(sp)
	sub.l	a4,a4
	jsr	_LVOrtEZRequestA(a6)
	move.l	(sp)+,a4
	move.l	xl_dosbase(a4),a6
	rts

lockfile ; a0 - strptr on file
	move.l	#ACCESS_READ,d2
	move.l	a0,d1
	move.l	xl_dosbase(a4),a6
	CALL	Lock
	tst.l	d0
	rts

execute ; a0 - strptr on command line
	moveq	#0,d2
	moveq	#0,d3
	move.l	a0,d1
	move.l	xl_dosbase(a4),a6
	JUMP	Execute


printintro ; unlock, currentdir
	tst.l	xl_introtxt(a4)
	beq.b	itfromgui
	move.l	xl_introtxt(a4),a0
	bsr	lockfile
	beq.b	noprintintro

	move.l	d0,d1
	CALL	UnLock

	move.l	xl_introtxt(a4),a2
	lea	comline3(pc),a0
	bsr	appendcom
noprintintro
	rts


itfromgui
	move.l	xl_introfile(a4),xl_txtlock(a4)
	beq.b	noprintintro
	bsr	printtxt2

printend
	tst.l	xl_endtxt(a4)
	beq	etfromgui
	move.l	xl_endtxt(a4),a0
	bsr	lockfile
	beq.b	noprintend

	move.l	d0,d1
	CALL	UnLock

	move.l	xl_endtxt(a4),a2
	lea	comline3(pc),a0
	bsr	appendcom
noprintend
	rts


etfromgui
	move.l	xl_endfile(a4),xl_txtlock(a4)
	beq.b	noprintend

printtxt2 ; lock in xl_txtlock(a4)
	lea	comline3(pc),a0
	bsr	appendsub

	move.l	a1,d2
	move.l	#255,d3
	sub.l	d0,d3
	move.l	xl_txtlock(a4),d1
	CALL	NameFromLock

	lea	xl_typecom_buff(a4),a0
	bra	execute

;dispbuffer
;	lea	xl_typecom_buff(a4),a0
;	move.l	a0,d1
;	CALL	PutStr
;	lea	flush(pc),a0
;	move.l	a0,d1
;	JUMP	PutStr

appendcom ; a0 - beg  a2 - end
	bsr	appendsub

	move.l	a2,a0 ; append argument

.loop2
	move.b	(a0)+,(a1)+
	bne.b	.loop2
	lea	xl_typecom_buff(a4),a0
	bra	execute

appendsub
	lea	xl_typecom_buff(a4),a1
	moveq	#-1,d0

.loop
	addq	#1,d0
	move.b	(a0)+,(a1)+ ; copy beginning of command in memory
	bne.b	.loop
	tst.b	-(a1)
return
	rts


**************************************


gettotal
; check if env:xltotal is here - if yes: get it - add to maintotal - del it -
; (maintotal's will be added to have the real total, in case of multiple dirs)

	lea	varfname(pc),a0
	bsr	lockfile
	beq.b	return

	move.l	d0,d1
	CALL	UnLock

	moveq	#VARSIZE,d0
	move.l	#$10001,d1
	move.l	a6,-(sp)
	move.l	4.w,a6
	CALL	AllocVec

	move.l	(sp)+,a6
	tst.l	d0
	beq.b	return

	move.l	d0,xl_varbuff(a4)
	move.l	d0,d2
	moveq	#VARSIZE,d3
	lea	varname(pc),a0
	move.l	a0,d1
	move.l	#GVF_GLOBAL_ONLY,d4
	CALL	GetVar

	move.l	xl_varbuff(a4),d1
	lea	xl_onedirtot(a4),a0
	move.l	a0,d2
	CALL	StrToLong

	move.l	xl_statfh(a4),d1
	lea	mtotfmt(pc),a0
	move.l	a0,d2
	lea	xl_dirtoscan(a4),a0
	move.l	a0,d3
	CALL	VFPrintf
	move.l	xl_statfh(a4),d1
	moveq	#0,d2
	move.l	#OFFSET_END,d3
	CALL	Seek

	bsr	getbig

	lea	varfname(pc),a0
	move.l	a0,d1
	CALL	DeleteFile

	lea	basevar(pc),a0
	move.l	a0,d1
	CALL	DeleteFile


freevbuff
	move.l	xl_varbuff(a4),a1
	move.l	a6,-(sp)
	move.l	4.w,a6
	CALL	FreeVec
	move.l	(sp)+,a6

endsubr
	rts


deletebigvar
	lea	bigvfname(pc),a0
	move.l	a0,d1
	JUMP	DeleteFile


getbig
	lea	bigvfname(pc),a0
	bsr	lockfile
	bne.b	gzdh

	lea	bigvname(pc),a0
	move.l	a0,d1
	move.l	xl_varbuff(a4),d2
	moveq	#VARSIZE,d3
	move.l	#GVF_GLOBAL_ONLY,d4
	JUMP	SetVar


gzdh
	move.l	d0,d1
	CALL	UnLock

	moveq	#VARSIZE,d0
	move.l	#$10001,d1
	move.l	a6,-(sp)
	move.l	4.w,a6
	CALL	AllocVec ; will be removed in v1.05, sorry

	move.l	(sp)+,a6
	tst.l	d0
	beq.b	endsubr

	move.l	d0,xl_bigvarbuff(a4)
	move.l	d0,d2
	moveq	#VARSIZE,d3
	lea	bigvname(pc),a0
	move.l	a0,d1
	move.l	#GVF_GLOBAL_ONLY,d4
	CALL	GetVar

	move.l	xl_bigvarbuff(a4),d1
	lea	xl_bigtotal(a4),a0
	move.l	a0,d2
	CALL	StrToLong

	move.l	xl_onedirtot(a4),d0

	add.l	d0,xl_bigtotal(a4)

	move.l	#MODE_NEWFILE,d2
	lea	bigvfname(pc),a0
	move.l	a0,d1
	CALL	Open
	move.l	d0,xl_varfh(a4)
	move.l	d0,d1

	lea	xl_bigtotal(a4),a0
	move.l	a0,d3
	lea	fmtvar(pc),a0
	move.l	a0,d2
	CALL	VFWritef
	move.l	xl_varfh(a4),d1
	CALL	Close

	move.l	xl_bigvarbuff(a4),a1
	move.l	a6,-(sp)
	move.l	4.w,a6
	CALL	FreeVec
	move.l	(sp)+,a6

endsub2
	rts


teststat ; void - test if ram:xl_stat.txt is already here
	lea	stattxt(pc),a0
	bsr	lockfile
	bne.b	unlockstat

	lea	stattxt(pc),a0
	bra.b	openstat

unlockstat
	move.l	d0,d1
	CALL	UnLock
	lea	stattxt(pc),a0

openstat
	move.l	a0,d1
	move.l	#MODE_NEWFILE,d2
	CALL	Open
	move.l	d0,xl_statfh(a4)
endclosesub
	rts


closestats
	move.l	xl_fib(a4),d2
	move.l	xl_statfh(a4),d1
	CALL	ExamineFH
	move.l	xl_fib(a4),a0
	tst.l	fib_Size(a0)
	beq.b	nullstats

	tst.l	xl_bigtotal(a4)
	beq.b	closestatf

	move.l	xl_statfh(a4),d1
	lea	totstat(pc),a0
	move.l	a0,d2
	lea	xl_bigtotal(a4),a0
	move.l	a0,d3
	CALL	VFPrintf

closestatf
	move.l	xl_statfh(a4),d1
	beq.b	endclosesub
	JUMP	Close


nullstats
	move.l	xl_statfh(a4),d1
	beq.b	endclosesub
	CALL	Close
	lea	stattxt(pc),a0
	move.l	a0,d1
	JUMP	DeleteFile


;---- Routine for "MicroShit's Windoze" compatibility
;MSLoop
;	nop ; tricky stuff...
;	jmp	MSLoop ; avoid bra.b

;-----------------------------------------------------------------------
tags1
	dc.l	RTFI_Flags,FREQF_NOFILES
	dc.l	TAG_END

tags2
	dc.l	RT_Underscore,'_'
	dc.l	RTEZ_ReqTitle,title
	dc.l	RTEZ_Flags,4 ; centertext
	dc.l	TAG_END

xlistname
	dc.b	'c:'
segname
	dc.b	'xList',0
tmpname
	dc.b	'T:xl_tmp1',0

sortedname
	dc.b	'T:xl_tmp4',0

stattxt
	dc.b	'RAM:xl_stats.txt',0
;stattxt2
;	dc.b	'RAM:xl_stats.txt.a',0 ; 17(an)

outname
	dc.b	'RAM:xList_out',0

outname2
	dc.b	'RAM:xList_out.a',0 ; 14(an)

dummycom
	dc.b	'xList >>RAM:xList_out LF=4 DL COF',0

comline1
	dc.b	'List >T:xl_tmp1 lformat "xList >>RAM:xList_out *"%s%s*" '
	dc.b	'LF=4 DL COF" dirs all',0

comline2
	dc.b	'Sort >NIL: T:xl_tmp1 to T:xl_tmp4',10,'Execute >NIL:'
	dc.b	' T:xl_tmp4',0

comline3
	dc.b	'Type >>RAM:xList_out ',0


varfname
	dc.b	'ENV:'
varname
	dc.b	'xlsumtot',0

bigvfname
	dc.b	'ENV:'
bigvname
	dc.b	'xlbigtot',0

basevar
	dc.b	'ENV:xltotal',0

mtotfmt
	dc.b	'                          %-15s  %5s files',10,0
totstat
	dc.b	'                          ----------------------------',10
	dc.b	'                          TOTAL:           %5ld files'
flush
	dc.b	10,0
fmtvar
	dc.b	'%N',0

dosname
	dc.b	'dos.library',0
rtname
	dc.b	'reqtools.library',0

body1
	dc.b	'Out of memory!',0
button1
	dc.b	'_!?!',0

body2
	dc.b	'Welcome to the xList-GUI !',10,10
	dc.b	'You''ll have to choose a',10
	dc.b	'directory to be recursively',10
	dc.b	'scanned, like a "MODS:" partition.',10,10
	dc.b	'Then you''ll have to wait until',10
	dc.b	'this requester is poped up again,',10
	dc.b	'allowing you to scan several dirs.',10
	dc.b	'The last created list is always',10
	dc.b	'''RAM:xList_out'', other lists are',10
	dc.b	'named like ''xList_out.a'',''.b'',...',0


button2
	dc.b	'_Let''s go!| About... |_Quit',0

body3
	dc.b	'Bad luck! Nothing selected.',0
button3
	dc.b	'_Bye|_Main menu',0

body4
	dc.b	'Unable to lock your dir.',0
button4
	dc.b	'_Try another one|_Quit this lame prog',0

button4b
	dc.b	'_Sorry',0

body5
	dc.b	'Do you want to:',10
	dc.b	'- append this dir to the existing file ?',10
	dc.b	'- write to a new file, by renaming the existing file',10
	dc.b	'to a new name ?',10
	dc.b	'(of course, your previous lists WON''T be overwritten!)',0

button5
	dc.b	'_Append|_New file|A_bort',0

body6
	dc.b	'This tool belongs to the xList project,',10
	dc.b	'started by Reez/Osmose on July 1995,',10
	dc.b	'with the BiG help of the followings:',10
	dc.b	'The Cyborg/NGC & Gryzor',10,10
	dc.b	'And thanx to these great guys:',10
	dc.b	'U.D. Mueller, for the XPK package',10
	dc.b	'Nico François, for the ReqTools stuff',0

button6
	dc.b	'I wanna ctc _you!',0

body7
	dc.b	'Feel free to write me at: (Answer Guaranteed!!!)',10,10
	dc.b	'David Le Corfec',10
	dc.b	'57 rue C.J. Romain',10
	dc.b	'94170  Le Perreux / Marne',10
	dc.b	'FRANCE',10,10
	dc.b	'Email:  <lecorfec@merlin.univ-mlv.fr>',10,10
	dc.b	'On IRC: Reez, mainly on #amigafr  (Hi Net-mates!)',0

button7
	dc.b	'_OK I see...',0

body8
	dc.b	'Cannot find ''xList'' in your path.',10
	dc.b	'Be sure to install it properly !',10
	dc.b	'(in your C: drawer, for example)',0

button8
	dc.b	'_Be right back...',0

body9
	dc.b	'Here you can choose intro and end texts for your list',0

button9
	dc.b	'_Next step!|Choose _Intro|Choose _End',0

button10
	dc.b	'_Uh?',0

body11
	dc.b	'Add a listing of the root directory ?',10
	dc.b	'(the directory you selected)',0

button11
	dc.b	'Oh _yeah!|_No, thanx.',0

text1
	dc.b	'Select a directory to list:',0

text2
	dc.b	'Select text:',0

template
	dc.b	'DIR(S)/M,IT=INTROTEXT/K,ET=ENDTEXT/K,APPEND/S,NOROOT/S',0

	end
