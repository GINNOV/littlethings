;---------------T-------T---------------T------------------------------------T
;-----------------------------------------------------------------------------;
;- Program Title	: Library timer.	-;
;- Copyrigth Status	: PD, (c) Copyrigth Jesper Skov	-;
;- Programmed by	: Jesper Skov		-;
;- Version.Revision	: 38.1		-;
;-----------------------------------------------------------------------------;
;- Program Description	: Keeps track of calls to and spend time in library	-;
;-		  functions.		-;
;-----------------------------------------------------------------------------;
;- 		       Program History	-;
;-----------------------------------------------------------------------------;
;- 100993 -	First simple code to prove functionality
;- 110993 -	Code split up in patch and free code. Now seperate datatable.
;- 210993 -	GUI added.
;- 250993 -	Finished saver.
;-	Now does full error checking. (no report to user though)
;-	Fixed bug in listhandling (0 in succ.succ -> last in list!)
;-	Added WB startup.
;-	Cleaned GUI up a little. Removed double click.
;-	Added Sorter to library list.
;-----------------------------------------------------------------------------;

UseExec=0
UseGad=0
UseDOS=1
UseRT=0
	IncDir	Include:
	Include	Misc/MySystemMacros.i
	include	_LVO/timer_lib.i
	include	exec/lists.i
	include	exec/execbase.i

lib_NegSize=	16

	rsreset		;define structure of DataEntry
de_CallCount	rs.l	1
de_TimeCount	rs.l	2
de_SizeOf	rs.b	0

FuncNameOff=	9

b	equr	a5


	include	misc/wbeasystart.i

s	lea	BSS,b
	bsr.w	OpenGTBLibs	;get libs needed by GTB opened
	bne.w	Exit|.GTBFail

	lea	DOSNam(pc),a1
	CallE	OldOpenLibrary	;open DOS
	move.l	d0,_DOSBase(b)
	beq.w	Exit|.DOSFail

	lea	RTNam(pc),a1	;open reqtools
	Call	OldOpenLibrary
	move.l	d0,_RTBase(b)
	beq.w	Exit|.RTFail

	lea	TimerLibName(pc),a1;find timer.device
	lea	DeviceList(a6),a0
	Call	FindName
	move.l	d0,_TimerLibBase(b)
	beq.w	Exit|.notimerlib
	move.l	d0,TLB0	;store in patcher
	move.l	d0,TLB1

	bsr.w	SetupScreen	;gain ground on the WB

MainLoopInit	bsr.w	OpenProject0Window;open main window
	bne.w	Exit|.windowerror

	move.l	Project0Wnd(pc),a0;get userport
	move.l	wd_UserPort(a0),WindowPort(b)

	bsr.w	SetupLibList	;get listgadget updated
	bmi.w	Exit|.listerror

	clr.b	ExitFlag(b)	;will be used for free library
	clr.b	PatchIt(b)
	move.w	#-1,SelectedLib(b)

MainLoop	tst.b	ExitFlag(b)	;test flags
	bne.w	Exit
	tst.b	PatchIt(b)
	bne.w	PatchTheLib

	move.l	WindowPort(b),a0;if no flags, wait for userinput
	CallE	WaitPort

.MsgLoop	move.l	_GadToolsBase(pc),a6;get message
	move.l	WindowPort(b),a0
	Call	GT_GetIMsg
	tst.l	d0
	beq.b	MainLoop

	move.l	d0,a1	;copy needed data
	move.l	im_Class(a1),d7	;class
	move.l	im_IAddress(a1),d6;code
	move.w	im_Code(a1),d5	;activated entry in list

	Call	GT_ReplyIMsg	;then reply

	cmp.l	#IDCMP_REFRESHWINDOW,d7;refresh request?
	bne.b	.checkrefresh

.RefreshWindow	move.l	_GadToolsBase(pc),a6
	move.l	Project0Wnd(pc),a0;refresh window
	Call	GT_BeginRefresh
;	bsr.b	Project0Render
	move.l	Project0Wnd(pc),a0
	moveq	#1,d0
	move.l	_GadToolsBase(pc),a6
	Call	GT_EndRefresh
	bra.b	.MsgLoop

.checkrefresh	cmp.l	#IDCMP_CLOSEWINDOW,d7
	bne.b	.ExitCheck
	st.b	ExitFlag(b)
	bra.b	.MsgLoop

.ExitCheck	cmp.l	#IDCMP_GADGETUP,d7
	bne.b	.MsgLoop	;gadget?
	move.l	d6,a0
	move.w	gg_GadgetID(a0),d6;which one?
	cmp.w	#GD_PatchButton,d6
	bne.b	.CheckPatch
	tst.w	SelectedLib(b)
	bmi.b	.MsgLoop
	st.b	PatchIt(b)
	bra.b	.MsgLoop

.CheckPatch	cmp.w	#GD_UpdateButtonS,d6
	bne.w	.CheckUpdate
	bsr.w	FreeLibList
	bsr.w	SetupLibList
	bra.b	.RefreshWindow

.CheckUpdate	cmp.w	#GD_LibsGadget,d6
	bne.w	.MsgLoop
;	cmp.w	SelectedLib(b),d5;if same as before->select
;	bne.b	.doubleclicked	;(very poor doubleclick-test!)
;	st.b	PatchIt(b)
.doubleclicked	move.w	d5,SelectedLib(b)
	bra.w	.MsgLoop

Exit	bsr.w	FreeLibList	;release list from window, and free

.listerror	bsr.w	CloseProject0Window;close down
.windowerror	bsr.w	CloseDownScreen

.notimerlib	move.l	_RTBase(b),a1
	CallE	CloseLibrary

.RTFail	move.l	_DOSBase(b),a1
	CallE	CloseLibrary

.DOSFail
.GTBFail	bsr.b	CloseGTBLibs
	moveq	#0,d0
	rts

	dc.b	0,'$VER: LibraryTimer 1.1 (25.09.93) © 1993 Jesper Skov.',0
	even
	include	'misc/GTBLibsOpen.i';GTB glue

PatchTheLib	clr.b	FuncNames(b)	;find name of library to patch
	move.l	ListPool(b),a0
	move.l	(a0),a0
	move.w	SelectedLib(b),d0
	subq.w	#1,d0
	bmi.b	.found
.findname	move.l	(a0),a0
	dbra	d0,.findname
.found	move.l	LN_NAME(a0),a0
	move.l	a0,a2
	lea	DiskName(b),a2	;prepare libname to be used az FDdiskname
	move.w	#'FD',(a2)+
	move.b	#':',(a2)+
	lea	PatchName(b),a1
.copyname	move.b	(a0),(a1)+
	move.b	(a0)+,(a2)+
	bne.b	.copyname

	move.l	a2,TempLibEnd(b);for adding end

	bsr.w	FreeLibList	;free liblist
	bsr.w	CloseProject0Window;and close window

	lea	PatchName(b),a1;open patch library
	CallE	OldOpenLibrary
	move.l	d0,_PatchBase(b)
	beq.w	PatchNotOpened

	move.l	d0,a0	;get size of library
	moveq	#0,d0
	move.w	lib_NegSize(a0),d0
	divu	#6,d0
	move.w	d0,Functions(b)

MaxFuncNameLen=28
FuncTextLen=68
FuncListLen=FuncTextLen+LN_SIZE
	addq.w	#2,d0	;for Lib name and 1 LF
	mulu	#FuncListLen,d0	;alloc space for list contents
	add.l	#MLH_SIZE,d0
	move.l	d0,ListSize(b)
	moveq	#0,d1
	Call	AllocMem
	move.l	d0,ListPool(b)
	beq.w	NoListMem

	move.l	d0,a0	;build list
	add.l	#MLH_SIZE,d0
	move.l	a0,d1	;previous
	move.l	d0,(a0)+
	moveq	#0,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+	;fill endnode in later
	moveq	#6-12,d2	;function offset -2 ID lines
	move.w	Functions(b),d6
	addq.w	#1,d6	;+2 ID lines
.buildloop	move.l	d1,LN_PRED(a0)
	move.l	a0,d1	;get new pre
	clr.w	LN_TYPE(a0)	;clear both type and pri
	lea	LN_SIZE(a0),a3
	move.l	a3,LN_NAME(a0)	;pointer to name

	move.l	#' -$ ',(a3)+	;prepare  -$xxxx text
	subq.w	#1,a3
	move.w	d2,d3
	moveq	#3,d4
.setoffset	rol.w	#4,d3
	move.w	d3,d5
	and.w	#$f,d5
	add.b	#'0',d5
	cmp.b	#'9',d5
	ble.b	.chars
	addq.b	#7,d5
.chars	move.b	d5,(a3)+
	dbra	d4,.setoffset

	moveq	#FuncTextLen-7-2,d0
.setspaces	move.b	#' ',(a3)+
	dbra	d0,.setspaces
	clr.b	(a3)+

	move.l	a3,LN_SUCC(a0)
	move.l	a3,a0
	addq.w	#6,d2
	dbra	d6,.buildloop
	
	move.l	d1,a0	;get last entry
	move.l	ListPool(b),d0
	addq.l	#4,d0
	move.l	d0,LN_SUCC(a0)	;and point succ to listheader 
	addq.l	#4,d0
	move.l	d0,a1
	move.l	a0,(a1)	;fix list's endnode

	move.l	ListPool(b),a0	;fix first two lines
	move.l	(a0),a0
	move.l	(a0),a1
	move.l	LN_NAME(a0),a0
	move.l	LN_NAME(a1),a1
	move.l	a0,a2

	moveq	#FuncTextLen-2,d0;1st clear
.setspaces2	move.b	#' ',(a1)+
	move.b	#' ',(a2)+
	dbra	d0,.setspaces2

	lea	PatchName(b),a1;then insert centered libraryname
	move.l	a1,a2
	moveq	#FuncTextLen+1,d0
.count	subq.w	#1,d0
	tst.b	(a2)+
	bne.b	.count
	lsr.w	#1,d0
	add.w	d0,a0
.copyname	move.b	(a1)+,(a0)+
	bne.b	.copyname
	move.b	#' ',-(a0)

	clr.l	FileSize(b)	;clear file-size to prevent AL_FreeTwice

	move.l	TempLibEnd(b),a1;add suffix to filename
.findspot	cmp.b	#':',(a1)
	beq.w	nofuncnames
	cmp.b	#'.',-(a1)
	bne.b	.findspot
	lea	NameEnd(pc),a0
.addend	move.b	(a0)+,(a1)+
	bne.b	.addend

	lea	DiskName(b),a0	;get info about size
	move.l	a0,d1
	move.l	#MODE_OLDFILE,d2
	CallD	Lock
	move.l	d0,ZFileLock(b)
	beq.w	nofuncnames

	move.l	d0,d1
	lea	FileInfo(b),a0
	move.l	a0,d2
	Call	Examine

	move.l	ZFileLock(b),d1
	Call	UnLock

	lea	FileInfo(b),a0	;now alloc mem needed
	move.l	fib_Size(a0),d0
	move.l	d0,FileSize(b)
	moveq	#0,d1
	CallE	AllocMem
	move.l	d0,FilePool(b)
	beq.w	nofuncnames

	lea	DiskName(b),a0	;then check open
	move.l	a0,d1
	move.l	#MODE_OLDFILE,d2
	CallD	Open
	move.l	d0,ZFileHandle(b)
	beq.w	nofuncnames

	move.l	d0,d1
	move.l	FileSize(b),d3
	move.l	FilePool(b),d2
	Call	Read	;read file

	move.l	ZFileHandle(b),d1
	Call	Close

;---- Analyze FD file
	move.l	FilePool(b),a0
	move.l	a0,d7
	add.l	FileSize(b),d7	;end of buffer

	moveq	#0,d6

.FDLoop	move.b	(a0),d0
	cmp.b	#'*',d0
	bne.b	.checkcomment

.FindLF	cmp.b	#$a,(a0)+
	beq.b	.FDLoop
	cmp.l	d7,a0
	blt.b	.FindLF

.FDError	move.b	#1,FuncNames(b)	;FD error, but file loaded
	bra.w	nofuncnames

.checkcomment	cmp.b	#'#',d0
	bne.b	.checkbiasend
	move.b	(a0)+,d0
	cmp.b	(a0)+,d0
	bne.b	.FindLF	;not ##, goto next line
	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	#'e',d0
	bne.b	.checkend
	move.b	(a0)+,d0
	asl.w	#8,d0
	move.b	(a0)+,d0
	or.w	#$2020,d0
	cmp.w	#'nd',d0
	beq.b	.FDConverted
	bra.b	.FindLF	;continue if not end

.checkend	moveq	#2,d1
.getnam	asl.l	#8,d0
	move.b	(a0)+,d0
	dbra	d1,.getnam
	or.l	#$20202020,d0
	cmp.l	#'bias',d0
	bne.b	.FindLF	;continue if not bias
.biasok	cmp.b	#' ',(a0)+
	beq.b	.biasok
	subq.l	#1,a0
	moveq	#0,d6
.getbias	moveq	#0,d1
	move.b	(a0)+,d1
	cmp.b	#$a,d1
	beq.b	.FDLoop
	sub.b	#'0',d1
	bmi.b	.FDError
	cmp.b	#9,d1
	bgt.b	.FDError
	mulu	#10,d6
	add.w	d1,d6
	bra.b	.getbias

.checkbiasend	move.l	d6,d0
	addq.l	#6,d6
	divu	#6,d0	;find address of first entry
	cmp.w	Functions(b),d0
	bgt.w	.FindLF	;if FDoffset not in ROM -> skip
	subq.l	#1,d0
	mulu	#FuncListLen,d0
	move.l	ListPool(b),a4
	lea	FuncListLen*2+MLH_SIZE+LN_SIZE+FuncNameOff(a4),a4;+2ID
	add.l	d0,a4	;poi to entry in list

	moveq	#MaxFuncNameLen-1,d0
.copyname2	move.b	(a0)+,(a4)+
	cmp.b	#'(',(a0)
	beq.b	.ended
	cmp.b	#$0a,(a0)
	beq.b	.ended
	dbra	d0,.copyname2

.ended	bra.w	.FindLF

.FDConverted	st.b	FuncNames(b)

nofuncnames	move.l	FilePool(b),a1	;free file memory
	move.l	FileSize(b),d0
	beq.b	.nofilemem
	CallE	FreeMem

.nofilemem	move.l	ListPool(b),a2	;insert default call names
	lea	FuncListLen*2+MLH_SIZE+LN_SIZE+FuncNameOff(a2),a2
	lea	DefaultCalls(pc),a0
	moveq	#3,d0
.insertdefault	move.l	a2,a1
	lea	FuncListLen(a2),a2
.copydefaults	move.b	(a0)+,(a1)+
	bne.b	.copydefaults
	move.b	#' ',-(a1)
	dbra	d0,.insertdefault

	bsr.w	OpenProject2Window;now open the timer-window
	bne.w	NoWindow

	move.l	Project2Wnd(pc),a0;and get the new port
	move.l	wd_UserPort(a0),WindowPort(b)

	bsr.w	PatchLibrary	;patch
	bmi.w	NoPatch

	bsr.w	PrintNumbers	;and print first numbers

	move.l	Project2Wnd(pc),a1
	move.l	Project2Gadgets+4*GD_TimeTable(pc),a0;gadget pointer
	bsr.w	SetupList	;update list

	clr.b	ExitFlag(b)
	clr.b	SaveFlag(b)

SubLoop	tst.b	ExitFlag(b)	;test flags
	bne.w	.Exit

	tst.b	SaveFlag(b)
	bne.w	SaveList

	move.l	WindowPort(b),a0;wait for userinput
	CallE	WaitPort

.MsgLoop	move.l	_GadToolsBase(pc),a6
	move.l	WindowPort(b),a0
	Call	GT_GetIMsg
	tst.l	d0
	beq.b	SubLoop

	move.l	d0,a1
	move.l	im_Class(a1),d7	;class
	move.l	im_IAddress(a1),d6;code
	move.w	im_Code(a1),d5	;activated entry in list

	Call	GT_ReplyIMsg

	cmp.l	#IDCMP_REFRESHWINDOW,d7
	bne.b	.checkrefresh

.RefreshWindow	move.l	_GadToolsBase(pc),a6
	move.l	Project2Wnd(pc),a0;refresh window
	Call	GT_BeginRefresh
	bsr.w	Project2Render
	move.l	Project2Wnd(pc),a0
	moveq	#1,d0
	move.l	_GadToolsBase(pc),a6
	Call	GT_EndRefresh
	bra.b	.MsgLoop

.checkrefresh	cmp.l	#IDCMP_CLOSEWINDOW,d7
	bne.b	.ExitCheck
	st.b	ExitFlag(b)
	bra.b	.MsgLoop

.ExitCheck	cmp.l	#IDCMP_GADGETUP,d7
	bne.b	.MsgLoop
	move.l	d6,a0
	move.w	gg_GadgetID(a0),d6
	cmp.w	#GD_SaveButton,d6
	bne.b	.CheckPatch
	st.b	SaveFlag(b)
	bra.b	.MsgLoop

.CheckPatch	cmp.w	#GD_UpdateButton,d6
	bne.w	.CheckUpdate

.Reprint	move.l	Project2Wnd(pc),a1
	move.l	Project2Gadgets+4*GD_TimeTable(pc),a0
	bsr.w	UnhookList

	bsr.w	PrintNumbers

	move.l	Project2Wnd(pc),a1
	move.l	Project2Gadgets+4*GD_TimeTable(pc),a0
	bsr.b	SetupList

	bra.b	.RefreshWindow

.CheckUpdate	cmp.w	#GD_FreeButton,d6
	bne.b	.CheckFree
	st.b	ExitFlag(b)
	bra.w	.MsgLoop

.CheckFree	cmp.w	#GD_ClearButton,d6
	bne.w	.MsgLoop
	move.l	DataPool(b),a0	;clear table, then reprint
	move.w	Functions(b),d0
	subq.w	#1,d0
.clearloop	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbra	d0,.clearloop
	bra.b	.Reprint

.Exit	bsr.w	FreeLibrary

NoPatch	move.l	Project2Wnd(pc),a1
	move.l	Project2Gadgets+4*GD_TimeTable(pc),a0;gadget pointer
	bsr.b	FreeList
	bsr.w	CloseProject2Window

NoWindow
NoListMem	move.l	_PatchBase(b),d0
	beq.b	PatchNotOpened
	move.l	d0,a1
	Call	CloseLibrary
	clr.l	_PatchBase(b)

PatchNotOpened	bra.w	MainLoopInit

;---- Setup data in librarylist
SetupLibList	move.l	$4.w,a0	;build list from exec's liblist
	move.l	LibList(a0),a0
	bsr.w	BuildList
	beq.b	.listok
	rts

.listok	move.l	Project0Wnd(pc),a1
	move.l	Project0Gadgets+4*GD_LibsGadget(pc),a0;gadget pointer

;---- Setup list
;a0 - poi to gadget
;a1 - poi to window
SetupList	lea	ListCMDBuffer(b),a3;link list to gadget
	move.l	a3,a2
	move.l	#GTLV_Labels,(a2)+
	move.l	ListPool(b),(a2)+
	clr.l	(a2)
	sub.l	a2,a2
	move.l	_GadToolsBase(pc),a6
	Call	GT_SetGadgetAttrsA
	moveq	#0,d0
	rts

;---- free librarylist
;
FreeLibList	move.l	Project0Gadgets+4*GD_LibsGadget(pc),a0;gadget pointer
	move.l	Project0Wnd(pc),a1

;---- free list
;a0 - poi to gadget
;a1 - poi to window
FreeList	bsr.b	UnhookList

;---- Call to free listpool before exit/new list is created
FreeListMem	move.l	ListPool(b),a1
	move.l	ListSize(b),d0
	beq.b	.nomem
	CallE	FreeMem
.nomem	rts

;---- Unhook list
;a0 - poi to gadget
;a1 - poi to window
UnhookList	lea	ListCMDBuffer(b),a3
	move.l	a3,a2
	move.l	#GTLV_Labels,(a2)+
	moveq	#-1,d0
	move.l	d0,(a2)+	;unhook list from gadget
	clr.l	(a2)
	sub.l	a2,a2
	move.l	_GadToolsBase(pc),a6
	Call	GT_SetGadgetAttrsA
	rts

;---- Build list for use in listviewgadget
;-- Input:	a0 - List to scan
;-- Output:	ListPool(b) pointer to memorypool \ must be deallocated at
;--	ListSize(b) size of memorypool    / exit.
;----
BuildList	move.l	a0,a2	;first count entries
	moveq	#MLH_SIZE,d0	;final length
.countloop	move.l	XLN_NAME(a0),a1
.findlen	tst.b	(a1)+
	bne.b	.findlen
	move.l	a1,d1
	sub.l	XLN_NAME(a0),d1
	btst	#0,d1	;align
	beq.b	.alignok
	addq.w	#1,d1
.alignok	add.w	#LN_SIZE,d1
	add.l	d1,d0	;add to sum
	move.l	XLN_SUCC(a0),a0
	move.l	(a0),d1
	bne.b	.countloop
	move.l	d0,ListSize(b)
	moveq	#0,d1
	CallE	AllocMem
	move.l	d0,ListPool(b)
	bne.b	.ok
	moveq	#-1,d0	;return fail
	rts

.ok	move.l	d0,a0	;dest pointer
	add.l	#MLH_SIZE,d0
	move.l	a0,d1	;previous
	move.l	d0,(a0)+
	moveq	#0,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+	;fill endnode in later
.buildloop	move.l	d1,LN_PRED(a0)
	move.l	a0,d1	;get new pre
	clr.w	LN_TYPE(a0)	;clear both type and pri
	lea	LN_SIZE(a0),a3
	move.l	a3,LN_NAME(a0)	;pointer to name
	move.l	XLN_NAME(a2),a1
.copyname	move.b	(a1)+,(a3)+
	bne.b	.copyname
	move.l	a3,d0
	btst	#0,d0
	beq.b	.alignok2
	clr.b	(a3)+
.alignok2	move.l	a3,LN_SUCC(a0)
	move.l	a3,a0
	move.l	(a2),a2	;get to next entry
	move.l	(a2),d0
	bne.b	.buildloop
	move.l	d1,a0	;get last entry
	move.l	ListPool(b),d0
	addq.l	#4,d0
	move.l	d0,LN_SUCC(a0)	;and point succ to listheader 
	addq.l	#4,d0
	move.l	d0,a1
	move.l	a0,(a1)	;fix list's endnode

	move.l	ListPool(b),a0	;kill exec.library	
.findexec	move.l	(a0),d0
	beq.b	.done
	move.l	d0,a0
	move.l	LN_NAME(a0),a1
	lea	ExecName(pc),a2
.checkequ	move.b	(a2)+,d0
	beq.b	.checkother
	cmp.b	(a1)+,d0
	beq.b	.checkequ
	bra.b	.findexec

.checkother	tst.b	(a1)
	bne.b	.findexec
	move.l	(a0),a1	;next
	move.l	LN_PRED(a0),a0
	move.l	a1,LN_SUCC(a0)
	move.l	a1,d0
	bne.b	.endoflist
	move.l	ListPool(b),a1
	move.l	a0,8(a1)
	bra.b	.done

.endoflist	move.l	a0,LN_PRED(a1)

.done	bsr.b	SortList
	moveq	#0,d0
	rts
j
;---- Sort Library List
SortList	move.l	ListPool(b),a0
	move.l	(a0),a0
	move.l	a0,a1	;find # of entries
	moveq	#-2,d0	;one precomp for the preinc+1 for (2 per loop)
.findno	addq.w	#1,d0
	move.l	(a1),a1
	move.l	(a1),d1
	bne.b	.findno

;do simple bubble # times

.sortloop	move.l	a0,a1
	move.w	d0,d1
	beq.b	.notneeded
	moveq	#0,d2

.innersort	move.l	LN_NAME(a1),a2	;high node
	move.l	(a1),a3
	move.l	LN_NAME(a3),a3	;low node
.cmploop	tst.b	(a2)
	beq.b	.noswap
	cmpm.b	(a2)+,(a3)+
	beq.b	.cmploop
	bpl.b	.noswap
	moveq	#-1,d2
	move.l	LN_NAME(a1),a2	;swap pointers to strings
	move.l	(a1),a3
	move.l	LN_NAME(a3),LN_NAME(a1)
	move.l	a2,LN_NAME(a3)

.noswap	move.l	(a1),a1
	dbra	d1,.innersort

	tst.w	d2
	beq.b	.notneeded
	dbra	d0,.sortloop

.notneeded	rts


;---- print call#/timetics
PrintNumbers	CallE	Disable
	move.l	DataPool(b),a0
	move.l	ListPool(b),a2
	lea	FuncListLen*2+MLH_SIZE+LN_SIZE+FuncNameOff+MaxFuncNameLen+2(a2),a2
	move.w	Functions(b),d7
	subq.w	#1,d7
.printloop	move.l	de_CallCount(a0),d0
	move.l	a2,a1
	lea	FuncListLen(a2),a2
	move.b	#'$',(a1)+
	moveq	#7,d1
.printcalls	rol.l	#4,d0
	move.w	d0,d2
	and.w	#$f,d2
	add.b	#'0',d2
	cmp.b	#'9',d2
	ble.b	.char
	addq.w	#7,d2
.char	move.b	d2,(a1)+
	dbra	d1,.printcalls
	addq.w	#2,a1

	move.b	#'$',(a1)+
	move.l	de_TimeCount(a0),d0
	moveq	#7,d1
.printcalls2	rol.l	#4,d0
	move.w	d0,d2
	and.w	#$f,d2
	add.b	#'0',d2
	cmp.b	#'9',d2
	ble.b	.char2
	addq.w	#7,d2
.char2	move.b	d2,(a1)+
	dbra	d1,.printcalls2

	move.l	de_TimeCount+4(a0),d0
	moveq	#7,d1
.printcalls3	rol.l	#4,d0
	move.w	d0,d2
	and.w	#$f,d2
	add.b	#'0',d2
	cmp.b	#'9',d2
	ble.b	.char3
	addq.w	#7,d2
.char3	move.b	d2,(a1)+
	dbra	d1,.printcalls3

	lea	de_SizeOf(a0),a0
	dbra	d7,.printloop

	Call	Enable
	rts

;---- Patch library
;-- Output:	d0 -	0/-1 OK/NoLib
;----
PatchLibrary	move.l	_PatchBase(b),a0
	move.w	Functions(b),d0
	mulu	#FuncLen,d0
	move.l	d0,MemorySize(b)
	moveq	#0,d1
	CallE	AllocMem
	move.l	d0,MemoryPool(b)
	bne.b	.memmemok
	moveq	#-1,d0
	rts

.memmemok	move.w	Functions(b),d0	;alloc memory for time tables
	mulu	#de_SizeOf,d0
	move.l	d0,DataSize(b)
	move.l	#MEMF_CLEAR,d1
	Call	AllocMem
	move.l	d0,DataPool(b)
	bne.b	.datmemok
	move.l	MemoryPool(b),a1
	move.l	MemorySize(b),d0
	Call	FreeMem
	moveq	#-1,d0
	rts

.datmemok	move.l	d0,d5

	Call	Disable
	move.l	MemoryPool(b),a4;destmem
	move.w	Functions(b),d7
	subq.w	#1,d7	;counter
	moveq	#-6,d6	;offset
.PatchLoop	move.l	_PatchBase(b),a1
	move.l	d6,a0
	move.l	a4,d0
	Call	SetFunction
	lea	PatchFunction(pc),a0
	move.l	d0,FuncOff(a0)	;set poi to patched function
	move.l	d5,DataPoi(a0)	;set poi to datatable
	moveq	#FuncLen/2-1,d0
.copypatch	move.w	(a0)+,(a4)+
	dbra	d0,.copypatch

	moveq	#de_SizeOf,d0
	add.l	d0,d5
	subq.l	#6,d6
	dbra	d7,.PatchLoop
	Call	CacheClearU	;need local flusher!
	Call	Enable
	moveq	#0,d0
	rts

;---- Free Library
FreeLibrary	CallE	Disable
	move.l	MemoryPool(b),a4;destmem
	move.w	Functions(b),d7
	subq.w	#1,d7	;counter
	moveq	#-6,d6	;offset
.DePatchLoop	move.l	_PatchBase(b),a1
	move.l	d6,a0
	move.l	FuncOff(a4),d0	;get old function
	Call	SetFunction
.notpatched	lea	FuncLen(a4),a4
	subq.l	#6,d6
	dbra	d7,.DePatchLoop
	Call	CacheClearU
	Call	Enable

	move.l	MemoryPool(b),a1
	move.l	MemorySize(b),d0
	Call	FreeMem
	move.l	DataPool(b),a1
	move.l	DataSize(b),d0
	Call	FreeMem
	rts


PatchFunction	lea	-16(a7),a7	;reserve space for time
	movem.l	d0-a6,-(a7)
TLB0=*+2
	lea	0.l,a6
	lea	15*4+8(a7),a0
	Call	ReadEClock
	movem.l	(a7)+,d0-a6
	jsr	$0
FuncOff=*-PatchFunction-4
	movem.l	d0-a6,-(a7)
TLB1=*+2
	lea	0.l,a6
	lea	15*4(a7),a0
	Call	ReadEClock
	move.w	#$4000,$dff09a	;the hard way to prevent dead loop
	lea	15*4(a7),a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	sub.l	(a0),d1
	subx.l	d2,d0
DataPoi=*-PatchFunction+2
	lea	0.l,a0
	addq.l	#1,(a0)+
	move.l	(a0)+,d2
	move.l	(a0),d3
	add.l	d1,d3
	addx.l	d0,d2
	move.l	d3,(a0)
	move.l	d2,-(a0)
	move.w	#$c000,$dff09a
	movem.l	(a7)+,d0-a6
	lea	16(a7),a7
	rts
FuncLen=*-PatchFunction

;---- Save list to disk
SaveList	move.l	_RTBase(b),a6
	sub.l	a0,a0	;Allocate filerequester
	moveq	#RT_FILEREQ,d0
	Call	rtAllocRequestA
	move.l	d0,AllocedReq(b)
	beq.w	.savefail	;cancel if not enough mem

	lea	FileReqText(pc),a3
	lea	Name(b),a2
	move.l	AllocedReq(b),a1
	lea	rtTagList(pc),a0
	Call	rtFileRequestA	;get path
	tst.l	d0	;if canceled ask for new choice...
	beq.w	.Dealloc

	move.l	AllocedReq(b),a0;else get path...
	lea	rtfi_Dir(a0),a0
	move.l	(a0),d1
	move.l	#MODE_OLDFILE,d2
	CallD	Lock
	move.l	d0,d1
	beq.w	.Dealloc
	Call	CurrentDir
	move.l	d0,ZFileLock(b)

	lea	Name(b),a0
	move.l	a0,d1
	move.l	#MODE_NEWFILE,d2
	Call	Open
	move.l	d0,FileHandle(b)
	beq.b	.notopened

	lea	SaveText(pc),a0
	move.l	a0,d2
	move.l	#SaveTextLen,d3
	move.l	FileHandle(b),d1
	Call	Write
	tst.l	d1
	bmi.b	.writeerror

	move.l	ListPool(b),a4
.WriteDataLoop	move.l	(a4),a4
	move.l	(a4),d0
	beq.b	.closefile
	lea	LN_SIZE(a4),a0
	move.l	a0,d2
	moveq	#FuncTextLen-1,d3
	move.l	FileHandle(b),d1
	Call	Write
	tst.l	d0
	bmi.b	.writeerror

	lea	LFChar(pc),a0
	move.l	a0,d2
	moveq	#1,d3
	move.l	FileHandle(b),d1
	Call	Write
	tst.l	d0
	bmi.b	.writeerror

	bra.b	.WriteDataLoop

.writeerror
.closefile	move.l	FileHandle(b),d1
	Call	Close

.notopened	move.l	ZFileLock(b),d1
	Call	CurrentDir
	move.l	d0,d1
	beq.b	.Dealloc
	Call	UnLock

.Dealloc	move.l	_RTBase(b),a6
	move.l	AllocedReq(b),a1;free requester
	Call	rtFreeRequest

.savefail	clr.b	SaveFlag(b)
	bra.w	SubLoop

	incdir
	include	LibraryTimerGui.s

rtTagList	dc.l	RTFI_Flags,FREQF_SAVE;if saving
	dc.l	0

RTNam	RTName
DOSNam	DOSName
TimerLibName	dc.b	'timer.device',0
NameEnd	dc.b	'_lib.fd',0
ExecName	dc.b	'exec.library',0
FileReqText	dc.b	'Save file...',0

DefaultCalls	dc.b	'LIB_OPEN',0
	dc.b	'LIB_CLOSE',0
	dc.b	'LIB_EXPUNGE',0
	dc.b	'LIB_EXTFUNC',0

SaveText	dcb.b	14,' '
	dc.b	'***************************************',10
	dcb.b	14,' '
	dc.b	'*   Created with LibraryTimer V1.1    *',10
	dcb.b	14,' '
	dc.b	'*  Programmed in 1993 by Jesper Skov  *',10
	dcb.b	14,' '
	dc.b	'***************************************',10
LFChar	dc.b	10
SaveTextLen=*-SaveText

	section	bssarea,bss

	rsreset
FileInfo	rs.b	fib_SIZEOF

_PatchBase	rs.l	1
_TimerLibBase	rs.l	1
_DOSBase	rs.l	1
_RTBase	rs.l	1

MemorySize	rs.l	1
MemoryPool	rs.l	1
DataSize	rs.l	1
DataPool	rs.l	1
ListPool	rs.l	1
ListSize	rs.l	1
FilePool	rs.l	1
FileSize	rs.l	1

TempLibEnd	rs.l	1

ZFileHandle	rs.l	1
ZFileLock	rs.l	1

SelectedLib	rs.w	1	;# place in list

WindowPort	rs.l	1

ListCMDBuffer	rs.l	3

Functions	rs.w	1

ExitFlag	rs.b	1	;flag exit
PatchIt	rs.b	1	;flag patch
FuncNames	rs.b	1
SaveFlag	rs.b	1


PatchName	rs.b	96
DiskName	rs.b	96

AllocedReq	rs.l	1
Name	rs.b	108

BSSSize	rs.b	0

BSS	ds.b	BSSSize
B
