*****************************************************************************
*	"Startup.asm"
*
*	$VER: Startup_asm 3.9 (06.10.96)
*
*	Copyright © 1995,1996 by Kenneth C. Nilsen/Digital Surface
*	This source is freely distributable.
*
*	For instructions read the Startup_Asm.doc or the Startup_example.s
*
*SUMMARY:
*
*StartSkip	=	0 or 1 (0 = wb/cli, 1=cli only (eg. from AsmOne))
*Processor	=	0 or 680x0
*MathProc	=	0 or 6888x/68040/68060
*
*CPUCHECK	SET 1	to activate Processor check
*MATHCHECK	SET 1	to activate Math check
*
*DODUMP		SET 1	to activate DebugDump and InitDebugHandler, else
*			they will not be assembled
*
*Init:	TaskName	<"new task name in quotes">		(opt)
*	TaskPri		<priority>				(opt)
*	DefLib		<libname wo/.library>,<version>		(opt)
*	DefEnd		;must end the "Init:" section ALWAYS!	(required!)
*
*Start:	LibBase		<libname wo/.library>			(opt)
*	StartFrom	= 0 (CLI) or <>0 (WB) in D0		(opt)
*	TaskPointer	= pointer to taskstructure  (D0)	(opt)
*	NextArg		= pointer to next argument or 0  (D0)	(opt)
*	InitDebugHandler= init debug handler for DebugDump	(opt) * NEW *
*	DebugDump	<"debug text">,labelID			(opt) * NEW *
*	Return		<return value> (with RTS)		(recommended)
*
*****************************************************************************

zyxMax	= 17	;max no. of libraries for AllocMem()
zyxBufZ	= 308	;size of format buffer in bytes for AllocMem()

; Default settings will require 512 bytes allocated memory.
; The buffer is independent of this header.

*-----------------------------------------------------------------------------*
* Macros for Startup.asm
*-----------------------------------------------------------------------------*

Return:	Macro
	moveq	#\1,d0	;* if you use rtn code >127, change to "move.l"
	rts				;exit our program
	EndM

DefLib:	Macro

	lea	\1NamX(pc),a1		;make exclusive library namelabel
	move.l	a1,(a5)+		;put name into our buffer (if print)
	move.l	a1,zyxNx		;store name in local label
	moveq	#\2,d0		;if you use ver >127, change this to "move.l"
	move.l	d0,(a5)+		;store version in our buffer
	move.l	d0,zyxVx		;store version in local label
	jsr	-552(a6)		;try open library
	move.l	d0,(a5)+		;store result in our buffer

	move.l	d0,\1basX		;store result in global label
	bne.b	\1zyx			;if <>0 then ok

	bsr.w	zyxLibR			;print error message
	bra.b	\1zyx			;go on...

\1basX:	dc.l	0
\1NamX:	dc.b	"\1.library",0		;library name macro
	even
\1zyx:
	EndM

DefEnd:	Macro
	move.l	#-1,(a5)		;this terminate our library list
	rts
	EndM

LibBase:	Macro
	move.l	\1basX(pc),a6		;get library base with exclusive name
	EndM

TaskName:	Macro

	move.l	$4.w,a6			;exec base
	jsr	-132(a6)		;Forbid()
	move.l	zyxTask(pc),a0		;get stored task pointer to our task
	move.l	#.TaskN,10(a0)		;get ptr. to new name and store
	jsr	-138(a6)		;Permit()
	bra.b	.zyxTsk			;go on...

.TaskN:	dc.b	\1			;task name macro
	dc.b	0			;null terminate
	even
.zyxTsk:
	EndM

TaskPri:	Macro
	move.l	$4.w,a6			;execbase
	move.l	zyxTask(pc),a1		;get stored task pointer
	moveq	#\1,d0			;get new task priority
	jsr	-300(a6)		;SetTaskPri()
	EndM

TaskPointer:	Macro
	move.l	zyxTask(pc),d0		;give pointer to task in d0
	EndM

StartFrom:	Macro
	move.l	RtnMess(pc),d0		;if started from WB, d0<>0
	EndM


NextArg:	Macro
	move.l	zyxArgP(pc),d0		;get address to argument string
	beq.b	*+8			;none? (from WB) then skip
	move.l	d0,a0			;use pointer
	bsr.w	zyxGArg			;go to our internal routine
	move.l	a0,zyxArgP		;update argument pointer
	tst.l	d0			;set/unset Z flag
	EndM

DebugDump	MACRO	;DebugDump "String",LabelID   (LabelID MUST be UNIC!)

; Please read the docs on how to use this macro.

	IFD	DODUMP	;in source: DODUMP SET 1 to enable debug dump

StartDump\2:			;Unic label (\2)

	movem.l	d0-d7/a0-a6,-(sp)	;store all regs.

	move.l	zyxDosBase(pc),a6	;use dos.library
	jsr	-60(a6)			;default output handler
	move.l	d0,d1			;use handler in D1
	bne.b	.ok

	move.l	zyxHandle(pc),d1	;use this handle
	beq.b	.debEnd			;nope so exit

.ok	move.l	#.string,d2		;debug string in D2
	move.l	#.stringSize,d3		;length of string in D3
	jsr	-48(a6)			;write string to handler

	bra.b	.debEnd			;exit

.string		dc.b	"DEBUG DUMP: ",27,"[1m",\1,27,"[0m",10
.stringSize	= *-.string
	even

.debEnd	movem.l	(sp)+,d0-d7/a0-a6	;restore regs

EndDump\2:

	ENDC
	ENDM

InitDebugHandler:	MACRO	;Usage: InitHandler "<name>"

	IFD	DODUMP

	tst.l	zyxHandle		;does handle exist already?
	bne.b	.exit			;yep, then exit

	move.l	zyxDosBase(pc),a6	;dos.library base
	jsr	-60(a6)			;try default first
	move.l	d0,zyxHandle		;got one
	bne.b	.exit			;need no more
	st	zyxDebugHand		;set flag for own handler
	move.l	#.handle,d1		;handle name
	move.l	#1006,d2		;read/write type
	jsr	-30(a6)			;Open()
	move.l	d0,zyxHandle		;store result
	bra.b	.exit

.handle	dc.b	\1,0
	even
.exit
	ENDC
	ENDM


;*! Obsolete: Don't use the Version macro from Startup.asm 3.5+ !* :

Version:	Macro			;obsolete!
	NOP
	EndM

*-----------------------------------------------------------------------------*
* MAIN routine:
*-----------------------------------------------------------------------------*

GoZYX:	move.l	a0,-(sp)		;store argument pointer

	move.l	d0,zyxArgL		;store length of arg. string
	move.l	a0,zyxArgP		;store arg. pointer in internal label

	move.l	$4.w,a6			;exec base
	move.l	a6,execbasX		;allow "LibBase exec"

	move.l	#zyxBufZ,d0		;set buffer size
	moveq	#1,d1			;requirements (public, clear)
	jsr	-198(a6)		;AllocMem()
	move.l	d0,zyxBuff		;store result in label
	beq.w	.DOS			;Null? then exit

	lea	zyxDos(pc),a1		;ptr. to dos.library name
	moveq.l	#0,d0			;version 0 (any)
	jsr	-552(a6)		;open library
	move.l	d0,zyxDosBase		;store result
	beq.w	.DOS

	sub.l	a1,a1			;a1=0 (this task)
	jsr	-294(a6)		;FindTask()
	move.l	d0,a4			;copy result
	move.l	d0,zyxTask		;store for internal use

	tst.l	172(a4)			;where we started from (wb/cli)
	bne.b	.chkPro

	moveq	#StartSkip,d0		;check if we wanne skip (eg. AsmOne)
	bne.b	.chkPro			;yepp, then skip
	lea	92(a4),a0		;get message port address
	jsr	-384(a6)		;WaitPort()
	lea	92(a4),a0		;get message port address
	jsr	-372(a6)		;GetMsg()
	move.l	d0,RtnMess		;store message pointer in label

.chkPro:
	move.w	296(a6),d5		;AttnFlags in execbase

	IFD	CPUCHECK

	move.l	#Processor,d7		;processor we want
	beq.w	.ProOk			;null? then any will do, skip this part
	cmp.w	#60,d7
	ble.w	.nxPro1			;then skip too...
	sub.l	#68000,d7
	beq.w	.ProOk

.nxPro1:
	cmp.b	#10,d7			;68010?
	bne.b	.nxPro2			;no, check next
	and.b	#$cf,d5			;check bits
	bne.w	.ProOk			;we got a 68010 or higher
	bra.w	.ProErr			;we got lower, we can't start...

.nxPro2:
	cmp.b	#20,d7			;same as above, just higher processor
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
	cmp.b	#60,d7			;we want a 68060 (yes, we do :) )
	bne.b	.ProWho			;not? then I dont know about any higher
	btst	#7,d5			;test if it is a 68060 we're using
	beq.b	.ProErr			;nope
	btst	#6,d5			;are you sure?
	bne.b	.ProOk			;yepp, continue
	bra.b	.ProErr			;not a 060, print error message

.ProWho:
	lea	ProcWho(pc),a0		;unknown processor required, print
	move.l	#Processor,ProcNum	;print message about it...
	lea	ProcNum(pc),a1
	bsr.w	zyxPrt
	bra.w	.End

.ProErr:
	st	zyxLR
	lea	ProcErr(pc),a0		;we don't got the processor required
	add.l	#68000,d7
	move.l	d7,ProcNum		;message about it.
	lea	ProcNum(pc),a1
	bsr.w	zyxPrt			;jump to our cli print routine

	ENDC

.ProOk:	IFD	MATHCHECK

	move.l	#MathProc,d7		;time to check for math-co-processor
	beq.w	.MathOk			;null? then any will do...
	sub.l	#68000,d7

	cmp.w	#881,d7			;a 68881?
	bne.b	.Math2			;no check next
	and.b	#$70,d5			;check flags
	bne.b	.MathOk			;we got it
	bra.b	.MathEr			;sorry...

.Math2:	cmp.w	#882,d7			;same as above
	bne.b	.Math3
	and.b	#$60,d5
	bne.b	.MathOk
	bra.b	.MathEr

.Math3:	cmp.b	#60,d7
	beq.b	.m60ok
	cmp.b	#40,d7			;we have 040/060 with FPU not 881/882
	bne.b	.MathEr			;unknown FPU if any else...
.m60ok	btst	#6,d5			;we got it?
	bne.b	.MathOk			;yepp, continue

.MathEr:
	st	zyxLR
	lea	ProcErr(pc),a0		;print error message...
	move.l	#MathProc,ProcNum	;number data
	lea	ProcNum(pc),a1
	bsr.w	zyxPrt

	ENDC

.MathOk:
	bsr.w	zyxLibO			;oki, open our libraries

	tst.b	zyxLR			;any errors?
	bne.b	.noShow			;yepp, don't start

	move.l	zyxArgP(pc),a0		;get arg. pointer
	move.l	zyxArgL(pc),d0		;get arg. length

	bsr.w	Start			;! start main program !
	move.l	d0,zyxVal		;store return code

.noShow:
	bsr.w	zyxLibC			;close libraries if any

.End:	move.l	zyxBuff(pc),d0		;get pointer to our buffer
	beq.b	.noBuff			;no buffer?!?
	move.l	d0,a1			;copy pointer
	move.l	#zyxBufZ,d0		;length of buffer
	jsr	-210(a6)		;FreeMem()

	IFD	DODUMP			;have we debugdump on?

	tst.b	zyxDebugHand		;own handler or default?
	beq.b	.none			;default -> don't close!!

	move.l	zyxDosBase(pc),a6	;if so, use dos.library base
	move.l	zyxHandle(pc),d1	;copy and test
	beq.b	.none			;if null then skip
	jsr	-36(a6)			;close handler
.none	move.l	$4.w,a6			;get exebase again

	ENDC

	move.l	zyxDosBase(pc),a1	;ptr. to dosbase
	jsr	-414(a6)		;close dos.library

.noBuff:
	tst.l	RtnMess			;from WB?
	beq.w	.DOS			;nope, from CLI

	jsr	-132(a6)		;Forbid()
	move.l	RtnMess(pc),a1		;put message in a1
	jsr	-378(a6)		;ReplyMsg()

.DOS:	move.l	(sp)+,a0		;restore stack, put arg. pointer back
	move.l	zyxVal(pc),d0		;set return code
	rts				;BYE! :)

zyxDo:	move.b	d0,(a3)+		;for RawDoFmt(), process routine
	rts

zyxPrt:	movem.l	d0-a6,-(sp)		;store regs. on stack

	lea	zyxDo(pc),a2		;process
	move.l	zyxBuff(pc),a3		;format buffer
	jsr	-522(a6)		;RawDoFmt()

	move.l	zyxDosBase(pc),a6	;use dosbase

	jsr	-60(a6)			;Output()
	move.l	d0,d1			;copy, set Z, failed?
	beq.b	.clDos			;no output -> close dos.library

	move.l	zyxBuff(pc),d2		;get ptr. to our buffer
	move.l	d2,a0			;copy pointer
	moveq	#0,d3			;clear D3 (length of buffer)
.count:	addq	#1,d3			;add 1 to length of line
	tst.b	(a0)+			;get one char
	bne.b	.count			;null? yepp, found end...

	subq	#1,d3			;exclude last sign (null)

	jsr	-48(a6)			;print buffer to output handler (CLI)

.clDos:	lea	(a6),a1			;copy dosbase to a1
	move.l	$4.w,a6			;get exebase
	jsr	-414(a6)		;CloseLibrary()

.exit:	movem.l	(sp)+,d0-a6		;restore stack
	rts				;return

zyxLibO:
	move.l	#4*3*zyxMax,d0		;library buffer size 12*zyxMax (192)
	moveq	#1,d1			;any mem
	jsr	-198(a6)		;AllocMem()
	move.l	d0,zyxMem		;store result
	beq.b	.memErr			;null? then error

	move.l	d0,a5			;use buffer
	bsr.w	Init			;jump to init section (see macros)

	rts				;done

.memErr:
	lea	zyxFR(pc),a0		;get format text
	lea	zyxMeR(pc),a1		;get input string

	bsr.w	zyxPrt			;print message about low memory

	st	zyxLR			;failed, don't start main program
	rts				;return

zyxLibC:
	move.l	$4.w,a6			;execbase

	move.l	zyxMem(pc),d0		;library buffer
	beq.w	.noLibs			;null? then no libraries
	move.l	d0,a5			;use pointer

.loop:	cmp.l	#-1,(a5)		;end?
	beq.b	.clEnd			;yepp, then done!
	move.l	8(a5),d0		;get library base
	beq.b	.noCl			;null? then this lib. failed to open
	move.l	d0,a1			;use base
	jsr	-414(a6)		;CloseLibrary()
.noCl:	lea	12(a5),a5		;get next library base
	bra.b	.loop			;continue

.clEnd:	move.l	zyxMem(pc),a1		;get lib. buffer pointer
	move.l	#4*3*zyxMax,d0		;size
	jsr	-210(a6)		;FreeMem()

.noLibs:
	rts

zyxLibR:
	st	zyxLR			;if any errors, set error flag

	lea	zyxLib(pc),a0		;pointer to format text
	lea	zyxNx(pc),a1		;pointer to format data
	bsr.w	zyxPrt			;print library name

	rts				;return

zyxGArg:
	move.b	(a0)+,d0		;get a char from arg. line
	beq.w	.end			;null? end of line
	cmp.b	#10,d0			;linefeed?
	beq.w	.end			;end of line
	cmp.b	#9,d0			;tab?
	beq.b	zyxGArg			;get another char
	cmp.b	#32,d0			;space?
	beq.b	zyxGArg			;get another char

	move.l	zyxBuff(pc),a1		;our text buffer
	lea	-1(a0),a0		;go back one byte on arg. line
.copy:	move.b	(a0)+,d0		;copy char to d0
	beq.b	.stop			;null? then stop copy
	cmp.b	#10,d0			;linefeed?
	beq.b	.stop			;stop copy
	cmp.b	#32,d0			;space?
	beq.b	.eol			;then this arg. is done
.cont:	cmp.b	#'*',d0			;asterix?
	beq.b	.chkSpc			;check for special functions
	cmp.b	#'"',d0			;quote?
	beq.b	.toggle			;toggle copy mode
.noChk:	move.b	d0,(a1)+		;copy passed char to our buffer
.cont2:	bra.b	.copy			;continue copy

.chkSpc:
	cmp.b	#'"',(a0)		;a quote want to be used?
	bne.b	.chk2			;no, check for a linefeed then...
	move.b	#'"',(a1)+		;copy a quote to our buffer
	lea	1(a0),a0		;skip one byte (2(*")->1("))
	bra.b	.copy			;continue copy argument
.chk2:	cmp.b	#'n',(a0)		;a linefeed?
	bne.b	.noChk			;nope, skip special funcs.
	move.b	#10,(a1)+		;copy a linefeed to our buffer
	lea	1(a0),a0		;make 2 -> 1
	bra.b	.copy			;continue copy

.toggle:
	tst.b	zyxQ			;already toggled?
	beq.b	.set			;nope, then toggle
	sf	zyxQ			;re toggle
	bra.b	.stop			;end of argument
.set:	st	zyxQ			;toggle so we can use space in arg.
	bra.b	.cont2			;continue copying argument

.eol:	tst.b	zyxQ			;end of line -> toggled?
	bne.b	.cont			;jepp, continue

.stop:	tst.b	zyxQ			;toggled?
	bne.b	.end			;jepp,don't care about this arg (error)
	clr.b	(a1)			;terminate buffer
	move.l	zyxBuff(pc),d0		;pointer to extracted argument
	rts				;return to macro

.end:	moveq	#0,d0			;no more args
	rts				;return to macro

RtnMess:	dc.l	0		;pointer to WB message
ProcNum:	dc.l	0		;processor wanted
execbasX:	dc.l	0		;pointer to execbase
zyxArgL:	dc.l	0		;argument line length
zyxArgP:	dc.l	0		;pointer to argument string
zyxVal:		dc.l	0		;return code
zyxMem:		dc.l	0		;pointer to library buffer
zyxNx:		dc.l	0		;temp lib. name
zyxVx:		dc.l	0		;temp lib. version
	IFD	DODUMP			;want debug info ?
zyxHandle:	dc.l	0		;then add space for debug handler
	ENDC				;End Check
zyxDosbase	dc.l	0		;space for dosbase
zyxTask:	dc.l	0		;pointer to task structure
zyxBuff:	dc.l	0		;pointer to string buffer
zyxMeR:		dc.l	zyxMemR		;pointer to a format string
	IFD	DODUMP
zyxDebugHand:	dc.b	0		;flag to distinguish defualt handler
	ENDC
zyxLR:		dc.b	0		;error flag
zyxQ:		dc.b	0		;toggle flag for quotes

zyxDos:		dc.b	'dos.library',0
zyxLib:		dc.b	"Can't open %s v. %ld",10,0
zyxMemR:	dc.b	'Low memory!',10,0
zyxFR:		dc.b	'%s',0
ProcWho:	dc.b	'Right! %ld ?',10,0
ProcErr:	dc.b	'Need %ld or better!',10,0
		even
