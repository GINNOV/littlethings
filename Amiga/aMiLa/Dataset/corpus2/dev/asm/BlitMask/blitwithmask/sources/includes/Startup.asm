*****************************************************************************
*	"Startup.asm"
*
*	$VER: Startup_asm stripped version 3.9 (10.10.96)
*
*	Copyright © 1995,1996 by Kenneth C. Nilsen/Digital Surface
*	This source is freely distributable.
*
*	For instructions read the Startup_Asm.guide or the Startup_example.s
*
*****************************************************************************

zyxMax	= 17	;max no. of libraries
zyxBufZ	= 308	;format buffer size

Return:	Macro
	moveq	#\1,d0
	rts
	EndM

DefLib:	Macro

	lea	\1NamX(pc),a1
	move.l	a1,(a5)+
	move.l	a1,zyxNx
	moveq	#\2,d0		;if you use ver >127, change this to "move.l"
	move.l	d0,(a5)+
	move.l	d0,zyxVx
	jsr	-552(a6)
	move.l	d0,(a5)+

	move.l	d0,\1basX
	bne.b	\1zyx

	bsr.w	zyxLibR
	bra.b	\1zyx

\1basX:	dc.l	0
\1NamX:	dc.b	"\1.library",0
	even
\1zyx:
	EndM

DefEnd:	Macro
	move.l	#-1,(a5)
	rts
	EndM

LibBase:	Macro
	move.l	\1basX(pc),a6
	EndM

TaskName:	Macro

	move.l	$4.w,a6
	jsr	-132(a6)
	move.l	zyxTask(pc),a0
	move.l	#.TaskN,10(a0)
	jsr	-138(a6)
	bra.b	.zyxTsk

.TaskN:	dc.b	\1
	dc.b	0
	even
.zyxTsk:
	EndM

TaskPri:	Macro
	move.l	$4.w,a6
	move.l	zyxTask(pc),a1
	moveq	#\1,d0
	jsr	-300(a6)
	EndM

TaskPointer:	Macro
	move.l	zyxTask(pc),d0
	EndM

StartFrom:	Macro
	move.l	RtnMess(pc),d0
	EndM


NextArg:	Macro
	move.l	zyxArgP(pc),d0
	beq.b	*+8
	move.l	d0,a0
	bsr.w	zyxGArg
	move.l	a0,zyxArgP
	tst.l	d0
	EndM

DebugDump	MACRO

	IFD	DODUMP

.StartDump\2:

	movem.l	d0-d7/a0-a6,-(sp)

	move.l	zyxDosBase(pc),a6
	jsr	-60(a6)
	move.l	d0,d1
	bne.b	.ok\2

	move.l	zyxHandle(pc),d1
	beq.b	.debEnd\2

.ok\2	move.l	#.string\2,d2
	move.l	#.stringSize\2,d3
	jsr	-48(a6)

	bra.b	.debEnd\2

.string\2		dc.b	"DEBUG DUMP: ",27,"[1m",\1,27,"[0m",10
.stringSize\2	= *-.string\2
	even

.debEnd\2	movem.l	(sp)+,d0-d7/a0-a6

	ENDC
	ENDM

InitDebugHandler:	MACRO

	IFD	DODUMP

	tst.l	zyxHandle
	bne.b	.exit

	move.l	zyxDosBase(pc),a6
	jsr	-60(a6)
	move.l	d0,zyxHandle
	bne.b	.exit
	st	zyxDebugHand
	move.l	#.handle,d1
	move.l	#1006,d2
	jsr	-30(a6)
	move.l	d0,zyxHandle
	bra.b	.exit

.handle	IFC	'\1',''
	dc.b	"CON:0/20/640/160/Debug Dump/CLOSE/WAIT",0
	ENDC
	IFNC	'\1',''
	dc.b	\1,0
	ENDC
	even
.exit
	ENDC
	ENDM

InitArg	MACRO
	move.l	#\1,zyxArgP
	ENDM

InitArgs	MACRO
	move.l	\1,zyxArgP
	ENDM

Version:	Macro	;obsolete!
	NOP
	EndM

GoZYX:	move.l	a0,-(sp)

	move.l	d0,zyxArgL
	move.l	a0,zyxArgP

	move.l	$4.w,a6
	move.l	a6,execbasX

	move.l	#zyxBufZ,d0
	moveq	#1,d1
	jsr	-198(a6)
	move.l	d0,zyxBuff
	beq.w	.DOS

	lea	zyxDos(pc),a1
	moveq.l	#0,d0
	jsr	-552(a6)
	move.l	d0,zyxDosBase
	beq.w	.DOS

	sub.l	a1,a1
	jsr	-294(a6)
	move.l	d0,a4
	move.l	d0,zyxTask

	tst.l	172(a4)
	bne.b	.chkPro

	moveq	#StartSkip,d0
	bne.b	.chkPro
	lea	92(a4),a0
	jsr	-384(a6)
	lea	92(a4),a0
	jsr	-372(a6)
	move.l	d0,RtnMess

.chkPro:
	move.w	296(a6),d5

	IFD	CPUCHECK

	move.l	#Processor,d7
	beq.w	.ProOk
	cmp.w	#60,d7
	ble.w	.nxPro1
	sub.l	#68000,d7
	beq.w	.ProOk

.nxPro1:
	cmp.b	#10,d7
	bne.b	.nxPro2
	and.b	#$cf,d5
	bne.w	.ProOk
	bra.w	.ProErr

.nxPro2:
	cmp.b	#20,d7
	bne.b	.nxPro3
	and.b	#$ce,d5
	bne.w	.ProOk
	bra.b	.ProErr

.nxPro3:
	cmp.b	#30,d7
	bne.b	.nxPro4
	and.b	#$cc,d5
	bne.b	.ProOk
	bra.b	.ProErr

.nxPro4:
	cmp.b	#40,d7
	bne.b	.nxPro5
	and.b	#$c8,d5
	bne.b	.ProOk
	bra.b	.ProErr

.nxPro5:
	cmp.b	#60,d7
	bne.b	.ProWho
	btst	#7,d5
	beq.b	.ProErr
	btst	#6,d5
	bne.b	.ProOk
	bra.b	.ProErr

.ProWho:
	lea	ProcWho(pc),a0
	move.l	#Processor,ProcNum
	lea	ProcNum(pc),a1
	bsr.w	zyxPrt
	bra.w	.End

.ProErr:
	st	zyxLR
	lea	ProcErr(pc),a0
	add.l	#68000,d7
	move.l	d7,ProcNum
	lea	ProcNum(pc),a1
	bsr.w	zyxPrt

	ENDC

.ProOk:	IFD	MATHCHECK

	move.l	#MathProc,d7
	beq.w	.MathOk
	sub.l	#68000,d7

	cmp.w	#881,d7
	bne.b	.Math2
	and.b	#$70,d5
	bne.b	.MathOk
	bra.b	.MathEr

.Math2:	cmp.w	#882,d7
	bne.b	.Math3
	and.b	#$60,d5
	bne.b	.MathOk
	bra.b	.MathEr

.Math3:	cmp.b	#60,d7
	beq.b	.m60ok
	cmp.b	#40,d7
	bne.b	.MathEr
.m60ok	btst	#6,d5
	bne.b	.MathOk

.MathEr:
	st	zyxLR
	lea	ProcErr(pc),a0
	move.l	#MathProc,ProcNum
	lea	ProcNum(pc),a1
	bsr.w	zyxPrt

	ENDC

.MathOk:
	bsr.w	zyxLibO

	tst.b	zyxLR
	bne.b	.noShow

	move.l	zyxArgP(pc),a0
	move.l	zyxArgL(pc),d0

	bsr.w	Start
	move.l	d0,zyxVal

.noShow:
	bsr.w	zyxLibC

.End:	move.l	zyxBuff(pc),d0
	beq.b	.noBuff
	move.l	d0,a1
	move.l	#zyxBufZ,d0
	jsr	-210(a6)

	IFD	DODUMP

	tst.b	zyxDebugHand
	beq.b	.none

	move.l	zyxDosBase(pc),a6
	move.l	zyxHandle(pc),d1
	beq.b	.none
	jsr	-36(a6)
.none	move.l	$4.w,a6

	ENDC

	move.l	zyxDosBase(pc),a1
	jsr	-414(a6)

.noBuff:
	tst.l	RtnMess
	beq.w	.DOS

	jsr	-132(a6)
	move.l	RtnMess(pc),a1
	jsr	-378(a6)

.DOS:	move.l	(sp)+,a0
	move.l	zyxVal(pc),d0
	rts

zyxDo:	move.b	d0,(a3)+
	rts

zyxPrt:	movem.l	d0-a6,-(sp)

	lea	zyxDo(pc),a2
	move.l	zyxBuff(pc),a3
	jsr	-522(a6)

	move.l	zyxDosBase(pc),a6

	jsr	-60(a6)
	move.l	d0,d1
	beq.b	.clDos

	move.l	zyxBuff(pc),d2
	move.l	d2,a0
	moveq	#0,d3
.count:	addq	#1,d3
	tst.b	(a0)+
	bne.b	.count

	subq	#1,d3

	jsr	-48(a6)

.clDos:	lea	(a6),a1
	move.l	$4.w,a6
	jsr	-414(a6)

.exit:	movem.l	(sp)+,d0-a6
	rts

zyxLibO:
	move.l	#4*3*zyxMax,d0
	moveq	#1,d1
	jsr	-198(a6)
	move.l	d0,zyxMem
	beq.b	.memErr

	move.l	d0,a5
	bsr.w	Init

	rts

.memErr:
	lea	zyxFR(pc),a0
	lea	zyxMeR(pc),a1

	bsr.w	zyxPrt

	st	zyxLR
	rts

zyxLibC:
	move.l	$4.w,a6

	move.l	zyxMem(pc),d0
	beq.w	.noLibs
	move.l	d0,a5

.loop:	cmp.l	#-1,(a5)
	beq.b	.clEnd
	move.l	8(a5),d0
	beq.b	.noCl
	move.l	d0,a1
	jsr	-414(a6)
.noCl:	lea	12(a5),a5
	bra.b	.loop

.clEnd:	move.l	zyxMem(pc),a1
	move.l	#4*3*zyxMax,d0
	jsr	-210(a6)

.noLibs:
	rts

zyxLibR:
	st	zyxLR

	lea	zyxLib(pc),a0
	lea	zyxNx(pc),a1
	bsr.w	zyxPrt

	rts

zyxGArg:
	move.b	(a0)+,d0
	beq.w	.end
	cmp.b	#10,d0
	beq.w	.end
	cmp.b	#9,d0
	beq.b	zyxGArg
	cmp.b	#32,d0
	beq.b	zyxGArg

	move.l	zyxBuff(pc),a1
	lea	-1(a0),a0
.copy:	move.b	(a0)+,d0
	beq.b	.stop
	cmp.b	#10,d0
	beq.b	.stop
	cmp.b	#32,d0
	beq.b	.eol
.cont:	cmp.b	#'*',d0
	beq.b	.chkSpc
	cmp.b	#'"',d0
	beq.b	.toggle
.noChk:	move.b	d0,(a1)+
.cont2:	bra.b	.copy

.chkSpc:
	cmp.b	#'"',(a0)
	bne.b	.chk2
	move.b	#'"',(a1)+
	lea	1(a0),a0
	bra.b	.copy
.chk2:	cmp.b	#'n',(a0)
	bne.b	.noChk
	move.b	#10,(a1)+
	lea	1(a0),a0
	bra.b	.copy

.toggle:
	tst.b	zyxQ
	beq.b	.set
	sf	zyxQ
	bra.b	.stop
.set:	st	zyxQ
	bra.b	.cont2

.eol:	tst.b	zyxQ
	bne.b	.cont

.stop:	tst.b	zyxQ
	bne.b	.end
	clr.b	(a1)
	move.l	zyxBuff(pc),d0
	rts

.end:	moveq	#0,d0
	rts

RtnMess:	dc.l	0
ProcNum:	dc.l	0
execbasX:	dc.l	0
zyxArgL:	dc.l	0
zyxArgP:	dc.l	0
zyxVal:		dc.l	0
zyxMem:		dc.l	0
zyxNx:		dc.l	0
zyxVx:		dc.l	0
	IFD	DODUMP
zyxHandle:	dc.l	0
	ENDC
zyxDosbase	dc.l	0
zyxTask:	dc.l	0
zyxBuff:	dc.l	0
zyxMeR:		dc.l	zyxMemR
	IFD	DODUMP
zyxDebugHand:	dc.b	0
	ENDC
zyxLR:		dc.b	0
zyxQ:		dc.b	0

zyxDos:		dc.b	'dos.library',0
zyxLib:		dc.b	"Can't open %s v. %ld",10,0
zyxMemR:	dc.b	'Low memory!',10,0
zyxFR:		dc.b	'%s',0
ProcWho:	dc.b	'Right! %ld ?',10,0
ProcErr:	dc.b	'Need %ld or better!',10,0
		even
