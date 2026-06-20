

		opt	d+


* NewHelper.s


* Version	: 1.00

* Revision	: 1.00


* Inspired by Mark Meany's LibHelp program, this is a pop-up utility
* that allows function parameters to be shown. It also allows the
* user to find out about 68000 instructions and other things when I
* get around to it...

* NOTE : NO MENUS! Done entirely via gadgets.

* Lives on WorkBench screen.

* Uses a data file (therefore help is editable without editing the
* source code!).

; Note, I only had an old copy of Dave's my_intuition.i file. A couple of
;structures and equates had to be added to this in order to get this file
;to assemble. When Dave sends his new versions to me I will put them on
;an ACC disk. MM


		include	source:INCLUDE/my_exec.i
		include	source:INCLUDE/my_dos.i
		include	source:INCLUDE/my_intuition.i
		include	source:INCLUDE/my_graf.i


* Equates


RawKeyConvert	equ	-48


FALSE		equ	0
TRUE		equ	-1

RastPort		equ	50
UserPort		equ	86

idcmp1		equ	CLOSEWINDOW+MOUSEBUTTONS
idcmp2		equ	GADGETDOWN+GADGETUP
idcmp3		equ	DISKINSERTED+DISKREMOVED
idcmp4		equ	RAWKEY

wf1		equ	WINDOWCLOSE+WINDOWDRAG+WINDOWDEPTH
wf2		equ	SMART_REFRESH+NOCAREREFRESH+ACTIVATE
wf3		equ	RMBTRAP

DIRCOUNT		equ	9		;no of dir listing entries

_CSI_CHAR	equ	$9B		;control sequence introducer


* main variable block declarations


		rsreset

dos_base		rs.l	1	;library bases
int_base		rs.l	1
graf_base	rs.l	1

dev_error	rs.l	1	;opendevice error code

readport		rs.l	1	;port for console dev read
readio		rs.l	1	;ioreq for console dev read

writeport	rs.l	1	;port for console dev write
writeio		rs.l	1	;ioreq for console dev write

mw_handle	rs.l	1	;main window handle
mw_viewport	rs.l	1	;plus rastport etc
mw_rastport	rs.l	1
mw_userport	rs.l	1

mw_evblock	rs.l	1	;main window EHB

mw_IDCMP		rs.l	1	;main window IDCMP


sqw_handle	rs.l	1	;sleepquit window handle
sqw_viewport	rs.l	1	;plus rastport etc
sqw_rastport	rs.l	1
sqw_userport	rs.l	1

sqw_evblock	rs.l	1	;sleepquit window EHB

sqw_IDCMP	rs.l	1	;sleepquit window IDCMP



event_class	rs.l	1	;Intuition message
menu_id		rs.w	1	;data
shift_stat	rs.w	1
gadget_id	rs.l	1
mouse_xpos	rs.w	1
mouse_ypos	rs.w	1

ReqCount		rs.w	1	;no of active requesters
ThisReq		rs.l	1	;ptr to active rhb

topaz_font	rs.l	1	;ptr to Font struct

filehandle	rs.l	1
filelock		rs.l	1
infoblock	rs.l	1

helpfile		rs.l	1	;ptr to HelpFile area
helpfilesize	rs.l	1	;size of HelpFile

currentlib	rs.l	1	;ptr to currently found library name
currentfunc	rs.l	1	;ptr to currently found function name
currentoff	rs.l	1	;ptr to current offset
firstparm	rs.l	1	;ptr to 1st parameter
parmcount	rs.l	1	;no of parms to list
searchfor	rs.l	1	;ptr to item to search for

keywords		rs.l	7	;7 ptrs to keywords

irt_itext	rs.l	1	;for InfoRequesters etc
irt_tlist	rs.l	1
irt_count	rs.w	1

lib_unopened	rs.w	1	;unopened library code etc.
error_code	rs.w	1	;DOS error code

file_flags	rs.w	1	;File handling flags

applic_flags	rs.w	1	;Application flags

vars_sizeof	rs.w	0

keyword1		equ	keywords
keyword2		equ	keywords+4
keyword3		equ	keywords+8
keyword4		equ	keywords+12
keyword5		equ	keywords+16
keyword6		equ	keywords+20
keyword7		equ	keywords+24


applic_flag1	equ	applic_flags		;Q 6 5 4 3 2 1 L
applic_flag2	equ	applic_flags+1		;R YN 5 4 3 H 1 0


* Flags:

* Flag1:

* Q	: Main application quit flag. 0 = QUIT, 1=RUNNING.

* L	: Language flag. 0=68000 Assembler, 1="C".

* Flag2:

* R	: Requester flag 1=ON, 0=OFF.

* YN	: Requester yes/no flag for those with select/cancel gadgets:
*	  1=YES, 0=NO.

* H	: Holding flag. 1=HOLDING, 0=FREE.


* Event Handler Block definition
* Pointers are :
* 1) pointer to code for mouse handling in absence of MENUVERIFY
* 2) pointer to code for event handling
* 3) pointer to IDCMP list to use


		rsreset

ehb_mousecode	rs.l	1
ehb_othercode	rs.l	1
ehb_IDCMPlist	rs.l	1

ehb_sizeof	rs.w	0


* Requester handling block structure


		rsreset

rhb_Requester	rs.l	1	;ptr to requester to handle
rhb_EHB		rs.l	1	;ptr to event handler block
rhb_Window	rs.l	1	;ptr to Window Handle to use
rhb_UserPort	rs.l	1	;ptr to UserPort of above window
rhb_IDCMP	rs.l	1	;IDCMP for this window
rhb_PreCode	rs.l	1	;Code to run before event handling

rhb_sizeof	rs.w	0


* IORequest structure


		rsreset
io_MsgNode	rs.b	mn_sizeof
io_Device	rs.l	1
io_Unit		rs.l	1
io_Command	rs.w	1
io_Flags		rs.b	1
io_Error		rs.b	1
io_sizeof	rs.w	0


* IOEXTRequest structure


		rsreset
ioext_Std	rs.b	io_sizeof
ioext_Actual	rs.l	1
ioext_Length	rs.l	1
ioext_Data	rs.l	1
ioext_Offset	rs.l	1
ioext_sizeof	rs.w	0


* This first piece of code detaches the program from the CLI and
* launches it as a separate process in its own right.


		section	Launcher,CODE


Launch		move.l	4.w,a6		;ExecBase

		lea	LDos(pc),a1
		moveq	#0,d0
		jsr	OpenLibrary(a6)
		tst.l	d0		;got DOS lib?
		beq.s	Abort_1		;exit if so

		move.l	d0,a6

		lea	Launch(pc),a4	;point to start of Launcher
		lea	-4(a4),a4	;point to 1st Segment in list
		move.l	(a4),d0		;get BCPL ptr to next

;		add.l	d0,d0
;		add.l	d0,d0		;convert to APTR

		move.l	d0,d3		;point to next segment
		clr.l	(a4)		;unlink the segments

		lea	LaunchName(pc),a0	;name of new process
		move.l	a0,d1

		moveq	#0,d2		;process pri
		move.l	#4000,d4		;stack size

		jsr	CreateProc(a6)	;create process

		move.l	a6,a1
		move.l	4.w,a6
		jsr	CloseLibrary(a6)	;close DOS library

		moveq	#0,d0		;signal launched
		rts

Abort_1		moveq	#20,d0		;signal failed!
		rts

LDos		dc.b	"dos.library",0

LaunchName	dc.b	"NewLibHelp.Proc",0
		even


		section	Program,CODE


* Actual application program code. First step is to allocate space
* for my variable block, referenced off A6.


main		move.l	#vars_sizeof,d0
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		tst.l	d0

		beq	cock_up_1

		move.l	d0,a6


* NOTE : a6 to point to my variables ALWAYS! ALL routines MUST leave
* a6 intact from this point onwards!


		bsr	InitVars

		bsr	OpenAllLibs	;open all libraries needed

		move.w	d1,lib_unopened(a6)

		tst.l	d0
		beq	cock_up_2	;can't do it


* Now open the TOPAZ80 font (which is ROM-resident). Because I'm forcing
* use of TOPAZ80 I don't need the Diskfont Library.


		lea	Topaz_80(pc),a0	;I want Topaz-80
		CALLGRAF	OpenFont
		move.l	d0,topaz_font(a6)	;got it?
		beq	cock_up_2a	;oops...


* This program opens a WorkBench window, so no custom screen needed.
* Also pre-sets intended IDCMP value!


		lea	my_main_window(pc),a0

		move.l	10(a0),d0	;newwindow_IDCMP entry
		move.l	d0,mw_IDCMP(a6)	;save it

		lea	ehb_std(pc),a1
		move.l	a1,mw_evblock(a6)

		CALLINT	OpenWindow
		move.l	d0,mw_handle(a6)	;got it?
		beq	cock_up_3	;skip if not (oops)...

		move.l	d0,a0
		bsr	InitWindow	;get useful pointers

		move.l	d0,mw_viewport(a6)	;i.e., these!
		move.l	d1,mw_rastport(a6)
		move.l	d2,mw_userport(a6)


* Now create an IORequest structure. Get a port, if can't do it, exit NOW.
* If port got, create IORequest, and abort if can't do that either.


		lea	myreadport(pc),a0
		moveq	#0,d0
		bsr	CreatePort
		move.l	d0,readport(a6)		;got a port?
		beq	cock_up_4		;ouch...

		move.l	d0,a0
		move.l	#ioext_sizeof,d0
		bsr	CreateExtIO
		move.l	d0,readio(a6)		;got an IOReq?
		beq	cock_up_5		;agh...

		lea	mywriteport(pc),a0
		moveq	#0,d0
		bsr	CreatePort
		move.l	d0,writeport(a6)		;got another port?
		beq	cock_up_6		;urgh...

		move.l	d0,a0
		move.l	#ioext_sizeof,d0
		bsr	CreateExtIO
		move.l	d0,writeio(a6)		;got another IOReq?
		beq	cock_up_7		;gah...


* Now open the console device. Once that's done, link console device
* to my Intuition window.


		lea	console_name(pc),a0
		move.l	readio(a6),a1

		move.l	mw_handle(a6),d0		;ptr to open window
		move.l	d0,ioext_Data(a1)		;save here
		moveq	#ioext_sizeof,d0		;size of IORequest
		move.l	d0,ioext_Length(a1)	;save here

		moveq	#0,d0		;unit 0
		moveq	#0,d1		;no flags
		CALLEXEC	OpenDevice
		move.l	d0,dev_error(a6)	;error on opening?
		bne	cock_up_8	;oops...


* Ok, here link in the ports, copy the device & unit from the
* readio to the writeio struct, and being setting up the console
* for MAJOR LEAGUE I/O !!!! Also do whatever else is needed.


		move.l	readio(a6),a0
		move.l	writeio(a6),a1

		move.l	io_Device(a0),io_Device(a1)
		move.l	io_Unit(a0),io_Unit(a1)


* Turn Console Device cursor off.


		lea	csroff(pc),a0
		bsr	WriteConsole


* Now set drawing mode for main RastPort.


		move.l	mw_rastport(a6),a1
		moveq	#RP_JAM2,d0
		CALLGRAF	SetDrMd


* Now set the Font for the main RastPort.


		move.l	mw_rastport(a6),a1
		move.l	topaz_font(a6),a0
		CALLGRAF	SetFont


* Now refresh the gadgets since the Console Device erases them.


		move.l	mw_handle(a6),a1		;window
		lea	SearchText(pc),a0		;1st gadget
		sub.l	a2,a2			;no requester
		moveq	#5,d0			;5 gadgets
		CALLINT	RefreshGList		;show them again!


* Now ask for the HelpFile disc.


main_getfile	lea	IRT_1(pc),a0
		lea	_INF_NewDisc(pc),a1
		moveq	#4,d0

		move.l	a0,irt_itext(a6)
		move.l	a1,irt_tlist(a6)
		move.w	d0,irt_count(a6)

		bsr	LinkInfoText
		bsr	ShowInfoReq

		lea	HelpFileName(pc),a0	;get file name
		move.l	a0,d1
		move.l	#ACCESS_READ,d2
		CALLDOS	Lock
		tst.l	d0		;file exists?
		bne.s	main_gotfile

		lea	QRT_1(pc),a0
		lea	_ERR_Nofile(pc),a1
		moveq	#5,d0

		move.l	a0,irt_itext(a6)
		move.l	a1,irt_tlist(a6)
		move.w	d0,irt_count(a6)

		bsr	DoQueryReq

		btst	#6,applic_flag2(a6)	;retry?
		bne.s	main_getfile		;retry if so
		bra	cock_up_8		;else abort!

main_gotfile	move.l	d0,filelock(a6)

		move.l	#260,d0
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l	d0,infoblock(a6)	;got fileinfoblock?
		bne.s	main_gotblk

		lea	IRT_1(pc),a0
		lea	_ERR_NoMem1(pc),a1
		moveq	#4,d0

		move.l	a0,irt_itext(a6)	;inform user that there
		move.l	a1,irt_tlist(a6)	;is no memory for the
		move.w	d0,irt_count(a6)	;fileinfoblock

		bsr	LinkInfoText
		bsr	ShowInfoReq

		move.l	filelock(a6),d1	;free the lock
		CALLDOS	UnLock
		bra	cock_up_8

main_gotblk	move.l	filelock(a6),d1
		move.l	d0,d2
		CALLDOS	Examine		;get file info

		move.l	infoblock(a6),a0
		move.l	124(a0),d0	;get file size

		move.l	d0,helpfilesize(a6)

		move.l	#260,d0
		move.l	infoblock(a6),a1	;free the infoblock
		CALLEXEC	FreeMem

		move.l	filelock(a6),d1		;surrender file
		CALLDOS	UnLock			;lock

		move.l	helpfilesize(a6),d0
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem

		move.l	d0,helpfile(a6)	;got file buffer?
		bne.s	main_gotbuf

		lea	IRT_1(pc),a0
		lea	_ERR_NoMem2(pc),a1
		moveq	#4,d0

		move.l	a0,irt_itext(a6)	;inform user that there
		move.l	a1,irt_tlist(a6)	;is no memory for the
		move.w	d0,irt_count(a6)	;file buffer

		bsr	LinkInfoText
		bsr	ShowInfoReq

		bra	cock_up_8

main_gotbuf	lea	HelpFileName(pc),a0
		move.l	a0,d1
		move.l	#MODE_OLD,d2
		CALLDOS	Open		;open the file
		move.l	d0,filehandle(a6)	;got it?
		bne.s	main_opened

		lea	IRT_1(pc),a0
		lea	_ERR_NotOpen(pc),a1
		moveq	#3,d0

		move.l	a0,irt_itext(a6)	;inform user that the
		move.l	a1,irt_tlist(a6)	;file could not
		move.w	d0,irt_count(a6)	;be opened

		bsr	LinkInfoText
		bsr	ShowInfoReq

		bra.s	cock_up_9

main_opened	move.l	d0,d1
		move.l	helpfile(a6),d2		;read in the
		move.l	helpfilesize(a6),d3	;help file
		CALLDOS	Read

		move.l	filehandle(a6),d1	;close the file
		CALLDOS	Close


* Now convert all $0A chars to ASCII NULLs!


		move.l	helpfile(a6),a0
		move.l	helpfilesize(a6),d0

main_convert	move.b	(a0),d1
		cmp.b	#$0A,d1
		bne.s	main_c1
		clr.b	d1
main_c1		move.b	d1,(a0)+
		subq.l	#1,d0
		bne.s	main_convert


		lea	IRT_1(pc),a0
		lea	_INF_Loaded(pc),a1
		moveq	#3,d0

		move.l	a0,irt_itext(a6)	;inform user that the
		move.l	a1,irt_tlist(a6)	;file could not
		move.w	d0,irt_count(a6)	;be opened

		bsr	LinkInfoText
		bsr	ShowInfoReq


* Here handle Intuition Events. Note this application doesn't use
* any menus.


main_1		move.l	mw_userport(a6),a0
		move.l	mw_evblock(a6),a5

		bsr	DoEvent		;completely event driven!

		tst.b	applic_flag1(a6)	;quit the program?
		bmi.s	main_1		;no (quicker than btst etc)


* Once application no longer active, deallocate everything
* in a hygenic fashion & return to CLI/WorkBench.


cock_up_9	move.l	helpfile(a6),d0
		beq.s	cock_up_8
		move.l	d0,a1
		move.l	helpfilesize(a6),d0	;free the
		CALLEXEC	FreeMem			;file buffer

cock_up_8	move.l	dev_error(a6),d0	;console device OK?
		bne.s	cock_up_7	;skip if not
		move.l	readio(a6),a1
		CALLEXEC	CloseDevice	;close it if so

cock_up_7	move.l	writeio(a6),d0	;IOReq exists?
		beq.s	cock_up_6	;skip if not
		move.l	d0,a1
		bsr	DeleteExtIO	;delete it if so

cock_up_6	move.l	writeport(a6),d0	;write port exists?
		beq.s	cock_up_5	;skip if not
		move.l	d0,a0
		bsr	DeletePort	;else delete it
		
cock_up_5	move.l	readio(a6),d0	;read IOReq exists?
		beq.s	cock_up_4	;skip if not
		move.l	d0,a1
		bsr	DeleteExtIO	;else delete it

cock_up_4	move.l	readport(a6),d0	;read port exists?
		beq.s	cock_up_3	;skip if not
		move.l	d0,a0
		bsr	DeletePort	;else close it

cock_up_3	move.l	mw_handle(a6),d0	;window exists?
		beq.s	cock_up_2a	;skip if not
		move.l	d0,a0
		CALLINT	CloseWindow	;else close it

cock_up_2a	move.l	topaz_font(a6),d0	;closing font?
		beq.s	cock_up_2	;nope
		move.l	d0,a1
		CALLGRAF	CloseFont	;else stop using it

cock_up_2	bsr	CloseAllLibs	;close all libraries


* Don't forget to free the
* variable block!


		move.l	a6,a1
		move.l	#vars_sizeof,d0
		CALLEXEC	FreeMem

cock_up_1	moveq	#0,d0
		rts


* InitVars(a6)
* a6 = ptr to main program variables
* initialise any special variables

* MODIFIABLE


InitVars		lea	ReqBlock(pc),a0		;set up the
		lea	ehb_req(pc),a1		;requester event
		moveq	#0,d0			;handling block
		move.l	d0,rhb_Requester(a0)	;(static structure)
		move.l	a1,rhb_EHB(a0)
		move.l	d0,rhb_Window(a0)
		move.l	d0,rhb_UserPort(a0)
		move.l	d0,rhb_IDCMP(a0)
		move.l	d0,rhb_PreCode(a0)
		move.l	a0,ThisReq(a6)		;& save ptr to it

;		move.l	#GADGETDOWN+GADGETUP+CLOSEWINDOW,d0

;		move.l	d0,mw_IDCMP(a6)		;set main window IDCMP

		moveq	#0,d0

		lea	IRT_1(pc),a0		;ptr to InfoReq
		move.l	a0,irt_itext(a6)		;IntuiTexts
		move.l	d0,irt_tlist(a6)		;no TList
		move.w	d0,irt_count(a6)		;entry count = 0

		move.w	d0,ReqCount(a6)
		move.w	d0,applic_flags(a6)

		lea	keywords(a6),a0
		lea	__KeyWords(pc),a1
		moveq	#7,d0

IVars1		move.l	a1,(a0)+		;insert pointer into list

IVars2		tst.b	(a1)+		;skip to EOS
		bne.s	IVars2		;and then past it

		subq.l	#1,d0		;done them all
		bne.s	IVars1

		bset	#7,applic_flag1(a6)	;not quitting program!

		rts


* OpenAllLibs(a6) -> d0/d1
* a6 = ptr to my main variable block
* returns success/failure in d0 (success=TRUE)
* if failed to open any library, returns
* library code number in d1

* a1 corrupt.

* NON-MODIFIABLE.

OpenAllLibs	lea	dos_name(pc),a1	;DOS library
		moveq	#0,d0
		CALLEXEC	OpenLibrary	;get her address
		moveq	#1,d1		;code if not available
		move.l	d0,dos_base(a6)	;is it?
		beq.s	OAL_done		;bye-bye if not

		lea	int_name(pc),a1	;Intuition library
		moveq	#0,d0
		CALLEXEC	OpenLibrary	;get her address
		moveq	#2,d1		;code if not available
		move.l	d0,int_base(a6)	;is it?
		beq.s	OAL_done		;bye-bye if not

		lea	graf_name(pc),a1	;Graphics library
		moveq	#0,d0
		CALLEXEC	OpenLibrary	;get her address
		moveq	#3,d1		;code if not available
		move.l	d0,graf_base(a6)	;is it?
		beq.s	OAL_done		;bye-bye if not

		moveq	#TRUE,d0		;all's well!
		moveq	#0,d1

OAL_done		rts


* CloseAllLibs(a6)
* Close all libraries opened by OpenAllLibs()
* Only closes those that were opened!

* d0/a1 corrupt

* NON-MODIFIABLE.


CloseAllLibs	move.l	graf_base(a6),d0	;exists?
		beq.s	CAL_2		;no!
		move.l	d0,a1
		CALLEXEC	CloseLibrary	;else close it

CAL_2		move.l	int_base(a6),d0	;exists?
		beq.s	CAL_1		;no!
		move.l	d0,a1
		CALLEXEC	CloseLibrary	;else close it

CAL_1		move.l	dos_base(a6),d0	;exists?
		beq.s	CAL_done		;no!
		move.l	d0,a1
		CALLEXEC	CloseLibrary	;else close it

CAL_done		rts


* NewList(list,type)
* a0 = list (to initialise)
* d0 = type

* NON-MODIFIABLE.

NewList		move.l	a0,(a0)		;lh_head points to lh_tail
		addq.l	#4,(a0)
		clr.l	4(a0)		;lh_tail = NULL
		move.l	a0,8(a0)		lh_tailpred points to lh_head

		move.b	d0,12(a0) ;list type

		rts


* port = CreatePort(Name,Pri)
* a0 = name
* d0 = pri
* returns d0 = port, NULL if couldn't do it

* d1/d7/a1 corrupt

* NON-MODIFIABLE.


CreatePort	movem.l	d0/a0,-(sp)	;save parameters
		moveq	#-1,d0
		CALLEXEC	AllocSignal	;get a signal bit
		tst.l	d0
		bmi	cp_error1
		move.l	d0,d7		;save signal bit

* got signal bit. Now create port structure.

		move.l	#mp_sizeof,d0
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		tst.l	d0
		beq.s	cp_error2	;couldn't create port struct!

* Here initialise port node structure.

		move.l	d0,a0
		movem.l	(sp)+,d0/d1	;get parms off stack
		move.l	d1,ln_Name(a0)	;set name pointer
		move.b	d0,ln_Pri(a0)	;and priority

		move.b	#NT_MSGPORT,ln_Type(a0)	;ensure it's a message
						;port

* Here initialise rest of port.

		move.b	#PA_SIGNAL,mp_Flags(a0)	;signal if msg received
		move.b	d7,mp_SigBit(a0)		;signal bit here
		move.l	a0,-(sp)
		sub.l	a1,a1
		CALLEXEC	FindTask		;find THIS task
		move.l	(sp)+,a0
		move.l	d0,mp_SigTask(a0)	;signal THIS task if msg arrived

* Here, if public port, add to public port list, else
* initialise message list header.

		tst.l	ln_Name(a0)	;got a name?
		beq.s	cp_private	;no

		move.l	a0,-(sp)
		move.l	a0,a1
		CALLEXEC	AddPort		;else add to public port list
		move.l	(sp)+,d0		;(which also NewList()s the
		rts			;mp_MsgList)

* Here initialise list header.

cp_private	lea	mp_MsgList(a0),a1	;ptr to list structure
		exg	a0,a1		;for now
		move.b	#NT_MESSAGE,d0	;type = message list
		bsr	NewList		;do it!

		move.l	a1,d0		;return ptr to port
		rts

* Here couldn't allocate. Release signal bit.

cp_error2	move.l	d7,d0
		CALLEXEC	FreeSignal

* Here couldn't get a signal so quit NOW.

cp_error1	movem.l	(sp)+,d0/a0
		moveq	#0,d0		;signal no port exists!

		rts


* DeletePort(Port)
* a0 = port

* a1 corrupt

* NON-MODIFIABLE.


DeletePort	move.l	a0,-(sp)
		tst.l	ln_Name(a0)	;public port?
		beq.s	dp_private	;no

		move.l	a0,a1
		CALLEXEC	RemPort		;remove port

* here make it difficult to re-use the port.

dp_private	move.l	(sp)+,a0
		moveq	#-1,d0
		move.l	d0,mp_SigTask(a0)
		move.l	d0,mp_MsgList(a0)

* Now free the signal.

		moveq	#0,d0
		move.b	mp_SigBit(a0),d0
		CALLEXEC	FreeSignal

* Now free the port structure.

		move.l	a0,a1
		move.l	#mp_sizeof,d0
		CALLEXEC	FreeMem

		rts


* IOReq=CreateExtIO(Port,Size)
* a0 = port
* d0 = size of IOReq to create
*	(e.g., iotd_sizeof for a
*	trackdisk.device IOreq)

* return d0=IOReq or NULL if couldn't do it

* Usage:call CreatePort() first to get a port
* to link to the IORequest. Then call this
* function to get the IORequest, passing the
* port pointer in a0.

CreateExtIO	movem.l	d0/a0,-(sp)	;save parameters

* Allocate the memory for the IORequest

		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		tst.l	d0
		beq.s	cei_error1
		move.l	d0,a1		;pointer to IORequest

		movem.l	(sp)+,d0/a0	;recover port & size

		move.b	#NT_MESSAGE,ln_Type(a1)
		move.l	a0,mn_ReplyPort(a1)	;set port pointer

;		sub.l	#mn_sizeof,d0	;leave this in for upgrades!

		move.w	d0,mn_Length(a1)		;and struct size

		move.l	a1,d0		;return argument
		rts

* Here couldn't get memory for IORequest, so bye

cei_error1	movem.l	(sp)+,d0/a0
		moveq	#0,d0
		rts


* DeleteExtIO(IORequest)

* a1 = IORequest

* Deletes an IORequest structure formed by CreateExtIO()
* uses mn_Length field to determine how much memory to
* deallocate.

* OOPS! Can't yet safely tell if any pending IORequests
* and so killing off the WaitIO() until I'm sure.

* d0/a1 corrupt


DeleteExtIO	nop

;		move.l	a1,-(sp)
;		CALLEXEC	WaitIO		;ensure no pending requests!
;		move.l	(sp)+,a1

		moveq	#0,d0
		move.w	mn_Length(a1),d0

;		add.l	#mn_sizeof,d0	;keep this for now!

		CALLEXEC	FreeMem

		rts


* BeginIO(IORequest)

* a1 = IORequest

* Pass IORequest directly to the BEGINIO vector of the
* device structure. Works exactly like SendIO() but it
* does not clear the io_Flags field first. Does not
* wait for the I/O to complete.

* a0 corrupt

* NON-MODIFIABLE

BeginIO		move.l	io_Device(a1),a0	;get device structure ptr
		jsr	-30(a0)		;execute BEGINIO routine
		rts			;and back


* StrLen(a0) -> d7
* a0 = ptr to string

* Returns length of ASCIIZ string in D7.

* No other registers corrupt


StrLen		move.l	a0,-(sp)		;save string ptr

		moveq	#0,d7		;initial string length

StrLen_1		tst.b	(a0)+		;hit EOS?
		beq.s	StrLen_2		;skip if so
		addq.l	#1,d7		;else update char count
		bra.s	StrLen_1

StrLen_2		move.l	(sp)+,a0		;recover string ptr
		rts


* WriteConsole(a0)
* a0 = ptr to string to write

* Sends a string to write to the Console.

* d7/a1 corrupt


WriteConsole	bsr	StrLen			;get string length

		move.l	a0,-(sp)			;save this

		move.l	writeio(a6),a1		;get write IOReq

		move.w	#CMD_WRITE,io_Command(a1)	;write command
		move.l	a0,ioext_Data(a1)		;data to write
		move.l	d7,ioext_Length(a1)	;no of chars

		CALLEXEC	DoIO

		move.l	(sp)+,a0

		rts


* LineFeeds(d0)
* d0 = no. of linefeeds to do (MAX 30!!!)

* Writes d0 linefeeds to console (unless d0=0!!!)

* a1 corrupt


LineFeeds	tst.l	d0
		beq.s	LFDone

		move.l	a0,-(sp)		;save this

		lea	__crlf(pc),a0	;ptr to end of crlf's
		sub.l	d0,a0		;point to how many wanted

		move.l	writeio(a6),a1
		move.w	#CMD_WRITE,io_Command(a1)
		move.l	a0,ioext_Data(a1)
		move.l	d0,ioext_Length(a1)

		CALLEXEC	DoIO		;and print them

		move.l	(sp)+,a0		;recover ptr

LFDone		rts


* ReadConsole() -> a0

* Returns pointer to string read in a0

* corrupt

ReadConsole	nop

		move.l	readio(a6),a1

		rts



* InitWindow(a0) -> d0-d2
* a0 = pointer to Window structure
* return parameters are:
* d0 = ViewPort pointer
* d1 = RastPort pointer
* d2 = User Port pointer

* NON-MODIFIABLE.


InitWindow	move.l	a0,-(sp)
		CALLINT	ViewPortAddress
		move.l	(sp)+,a0
		move.l	RastPort(a0),d1
		move.l	UserPort(a0),d2
		rts


* DoEvent(a0,a5)
* a0 = ptr to user port to WAIT upon
* a5 = ptr to Event Handler Block
* do one read of the user port & handle events once.
* Note : does NOT handle one event at a time! Rather,
* checks one event sequence & processes that entire
* sequence. Written to allow multiple windows to have
* their own DoEvent() call by virtue of passing different
* UserPort pointers to it.

* d0/a0-a1 corrupt

* NON-MODIFIABLE.


DoEvent		move.l	a0,-(sp)
		CALLEXEC	WaitPort		;Wait for port
		move.l	(sp)+,a0

		CALLEXEC	GetMsg		;now get message
		move.l	d0,a1		;here ascertain type


* Here goes code to handle such things as mouse handling in the
* absence of MENUVERIFY, and implementing MENUCANCEL if wanted.


		move.l	ehb_mousecode(a5),d0	;code exists?
		beq.s	DoEvent_1		;no-don't execute!
		move.l	d0,a0			;get pointer
		jsr	(a0)			;& execute it


* Now reply the message.


DoEvent_1	CALLEXEC	ReplyMsg		;reply the message

		move.l	ehb_othercode(a5),d0	;code exists?
		beq.s	DoEvent_2		;no-don't execute
		move.l	d0,a0			;get ptr

		move.l	ehb_IDCMPlist(a5),a1	;IDCMP list ptr
		move.l	event_class(a6),d0	;IDCMP received
		jsr	(a0)			;do it

DoEvent_2	rts


* SelectEvent(d0,a1)
* d0 = IDCMP message received from somewhere else
* a1 = ptr to IDCMP list to use to decide what to do
* executes various routines based upon IDCMP message
* & IDCMP selection list.

* This will be the normal code choice for ehb_othercode in
* the Event Handler Block structure, but the way it has been
* written allows alternative ehb_othercode's to exist using
* this as a basis.

* d1/d2/a1 corrupt by this routine. OTHER CODE
* CALLED BY THIS ROUTINE MAY WRECK OTHER REGISTERS!

* NON-MODIFIABLE.


SelectEvent	movem.l	(a1)+,d1/d2	;get flag, code pointer
		tst.l	d1		;end of list?
		beq.s	SE_done		;yes!-exit
		and.l	d0,d1		;this IDCMP?
		beq.s	SE_1		;no, skip
		movem.l	d0/a1,-(sp)	;else save these
		move.l	d2,a1		;get code pointer
		jsr	(a1)		;& execute it
		movem.l	(sp)+,d0/a1	;recover IDCMP msg & list ptr
SE_1		bra.s	SelectEvent	;and do again

SE_done		rts


* AlterEvent(a1,a6)
* a1 = ptr to received IntuiMessage
* a6 = ptr to main program variables
* Do a GetIM() (see below) and then
* alter the message before reply if needed.

* d0-d1 corrupt

* MODIFIABLE.


AlterEvent	bsr.s	GetIM

		rts


* GetIM(a1,a6)
* a1 = ptr to received IntuiMessage
* a6 = ptr to main program variables
* Read the message & store in private variables
* d0/d1 corrupt

* NON-MODIFIABLE.


GetIM		move.l	im_class(a1),d0
		move.l	d0,event_class(a6)	;IDCMP event class
		move.w	im_code(a1),d0
		move.w	d0,menu_id(a6)		;menu ID selected
		move.w	im_qualifier(a1),d0
		move.w	d0,shift_stat(a6)
		move.l	im_iaddress(a1),d0
		move.l	d0,gadget_id(a6)		;address of selected gadget
		move.w	im_mousex(a1),d0
		move.w	im_mousey(a1),d1
		move.w	d0,mouse_xpos(a6)
		move.w	d1,mouse_ypos(a6)

		rts


* DoIGadget(a6)
* a6 = ptr to main variables

* Execute a GADGIMMEDIATE routine.

* Only uses gg_UserData.


DoIGadget	move.l	gadget_id(a6),d0		;get gadget ID
		beq.s	DoneIG			;not a real one
		move.l	d0,a0
		move.l	gg_UserData(a0),d0	;get routine ptr
		beq.s	DoneIG			;there isn't one
		move.l	d0,a0
		jmp	(a0)			;else execute it
DoneIG		rts


* DoRGadget(a6)
* a6 = ptr to main variables

* Execute a RELVERIFY routine.

* Only uses gg_UserData+4.


DoRGadget	move.l	gadget_id(a6),d0		;get gadget ID
		beq.s	DoneRG			;not a real one
		move.l	d0,a0
		move.l	gg_UserData+4(a0),d0	;get routine ptr
		beq.s	DoneRG			;there isn't one
		move.l	d0,a0
		jmp	(a0)			;else execute it
DoneRG		rts


* DoMBCode(a6)
* a6 = ptr to main program variables

* Activate the string gadget when LMB released
* after pressing it anywhere within this window
* other than on a gadget.

* d0/a0-a2 corrupt


DoMBCode		move.w	menu_id(a6),d0	;get mouse button
		cmp.w	#SELECTUP,d0	;LMB released?
		beq.s	DoMB_1		;continue if so
		rts			;else exit

DoMB_1		move.l	mw_handle(a6),a1
		lea	SearchText(pc),a0
		sub.l	a2,a2
		CALLINT	ActivateGadget

		rts



* AltMouseButton(a6)
* a6 = ptr to main program variables

* Alternative mouse button handler for within a requester.

* d0 corrupt


AltMouseButton	and.b	#$FB,applic_flag1(a6)	;clear C flag

		move.w	menu_id(a6),d0	;check button status
		cmp.w	#SELECTDOWN,d0	;LMB pressed?
		bne.s	AMB_1		;skip if not

		or.b	#1,applic_flag1(a6)	;set LM flag
		bra.s	AMB_4

AMB_1		cmp.w	#SELECTUP,d0	;LMB released?
		bne.s	AMB_2		;skip if not

		and.b	#$FE,applic_flag1(a6)	;clear LM flag
		bra.s	AMB_4

AMB_2		cmp.w	#MENUDOWN,d0	;RMB pressed?
		bne.s	AMB_3		;skip if not

		or.b	#2,applic_flag1(a6)	;set RM flag
		bra.s	AMB_4

AMB_3		cmp.w	#MENUUP,d0	;RMB released?
		bne.s	AMB_4		;skip if not

		and.b	#$FD,applic_flag1(a6)	;clear LM flag

AMB_4		rts


* HandleRequest(a4)
* a4 = ptr to Requester handling block

* Handle all custom requesters except for DMRequesters,
* this routine kills off any VERIFY IDCMPs and then
* resets the original window IDCMP once ALL of the
* requesters are no longer active. Saves lots of
* needless hassle for other programmers using this
* code. Also sets RMBTRAP on the fly, preventing an
* accidental menu access. Note that it won't clear the
* RMBTRAP flag - that has to be done by the programmer
* if wanted once requester handling finished.

* NEVER CALL THIS WITHOUT INITIALISING THE rhb_ STRUCTURE
* BEFOREHAND!

* Note that this system maintains its integrity only if there
* is one window to condition. If several windows needed, then
* use this as a basis for a rewrite.

* ASSUME ALL REGISTERS CORRUPT-OTHER CODE ACTIVATED
* BY THIS ROUTINE!

* MODIFIABLE


HandleRequest	move.l	rhb_Window(a4),a0	;prepare to recondition
		move.l	rhb_IDCMP(a4),d0	;IDCMPs

		bset	#0,25(a0)	;set RMBTRAP also!

		move.l	#SIZEVERIFY,d1
		or.l	#MENUVERIFY,d1
		or.l	#REQVERIFY,d1

		not.l	d1
		and.l	d1,d0	;kill off all VERIFYs!

		CALLINT	ModifyIDCMP

		bset	#7,applic_flag2(a6)	;set requester on flag

		addq.w	#1,ReqCount(a6)		;1 more active Req

		move.l	rhb_Requester(a4),a0	;this requester
		move.l	rhb_Window(a4),a1		;this window
		CALLINT	Request			;set it up

		move.l	rhb_PreCode(a4),d0	;any PreCode to run?
		beq.s	HReq_1			;skip if not

		move.l	d0,a0		;else prepare to run it
		jsr	(a0)		;GO!

HReq_1		move.l	rhb_EHB(a4),a5		;get event block
		move.l	rhb_UserPort(a4),a0	;& user port
		bsr	DoEvent			;Event driven!

		btst	#7,applic_flag2(a6)	;left requester?
		bne.s	HReq_1			;back if not

		bset	#7,applic_flag2(a6)	;set in case nested call

		subq.w	#1,ReqCount(a6)		;1 fewer req's active
		bne.s	HReq_2			;skip if any still active

		move.l	rhb_Window(a4),a0		;else restore the
		move.l	rhb_IDCMP(a4),d0		;original IDCMP

		CALLINT	ModifyIDCMP

		bclr	#7,applic_flag2(a6)	;signal no more reqs

		move.l	rhb_Window(a4),a0		;and reactivate
		CALLINT	ActivateWindow		;the window.

HReq_2		rts


* ItoA(a0,d0,d1)
* a0 = ptr to buffer into which to put the resulting string
* d0 = value to convert
* d1 = field width for resulting string

* d1-d3/a1 corrupt


ItoA		move.l	a0,a1		;copy buffer ptr

		move.w	d1,d2		;copy field width
		bra.s	ItoA_a1

ItoA_l1		move.b	#" ",(a1)+	;space padding for string

ItoA_a1		dbra	d2,ItoA_l1

		clr.b	(a1)		;and terminating EOS

		move.w	d0,d3		;copy initial value

ItoA_l2		moveq	#0,d2
		move.w	d3,d2		;ensure word sized operand

		divu	#10,d2		;get trailing digit
		move.w	d2,d3		;save quotient
		swap	d2
		add.b	#"0",d2		;create ASCII digit
		move.b	d2,-(a1)		;& save it

		subq.w	#1,d1		;used entire fieldwidth?
		beq.s	ItoA_b1		;exit if so

		tst.w	d3		;quotient = 0?
		bne.s	ItoA_l2		;back for more if not

ItoA_b1		rts			;done


* QuitCode(a6)
* a6 = ptr to main program variables
* signals end of application runtime

* NON-MODIFIABLE


QuitCode		lea	QRT_1(pc),a0	;set up the text data
		lea	Quit_YN(pc),a1	;for the query
		moveq	#2,d0		;requester

		move.l	a0,irt_itext(a6)	;put said data here
		move.l	a1,irt_tlist(a6)
		move.w	d0,irt_count(a6)

		bsr	DoQueryReq	;does the lot in one go

		btst	#6,applic_flag2(a6)	;pressed "YES" gadget?
		beq.s	QuitCode_1		;skip if not

		bclr	#7,applic_flag1(a6)	;else quit program

QuitCode_1	rts


* SleepCode(a6)
* a6 = ptr to main program variables
* Signals application sleeping...

* NOTE: occurs on a RELVERIFY to ensure no extra
* IntuiMessages left on UserPort (else all hell
* breaks loose).

* d0-d2/a0-a2 corrupt


SleepCode	lea	QRT_1(pc),a0	;set up the text data
		lea	Sleep_YN(pc),a1	;for the query
		moveq	#3,d0		;requester

		move.l	a0,irt_itext(a6)	;put said data here
		move.l	a1,irt_tlist(a6)
		move.w	d0,irt_count(a6)

		bsr	DoQueryReq	;does the lot in one go

		btst	#6,applic_flag2(a6)	;pressed "YES" gadget?
		beq.s	SleepCode_1		;skip if not

SleepOn		move.l	readio(a6),a1	;close console device
		CALLEXEC	CloseDevice

		move.l	mw_handle(a6),a0	;close main Helper window
		CALLINT	CloseWindow

		lea	zzzwindow(pc),a0
		move.l	10(a0),d0
		move.l	d0,mw_IDCMP(a6)

		lea	ehb_zzz(pc),a1
		move.l	a1,mw_evblock(a6)

		CALLINT	OpenWindow	;open sleep window

		move.l	d0,mw_handle(a6)
		move.l	d0,a0

		bsr	InitWindow

		move.l	d0,mw_viewport(a6)	;obtain these for
		move.l	d1,mw_rastport(a6)	;later wakeup
		move.l	d2,mw_userport(a6)

		moveq	#-1,d0		;signal that the
		move.l	d0,dev_error(a6)	;console device is closed

SleepCode_1	rts


* WakeCode(a6)
* a6 = ptr to main program variables

* wakes up application

* NOTE : wait for Right Mouse Button to be RELEASED before
* wkaing up the code, to prevent unprocessed IntuiMessages
* being left on the UserPort (else havoc reigns).

* d0-d3/a0-a2 corrupt


WakeCode		move.w	menu_id(a6),d0	;check mouse button type
		CMP.W	#MENUUP,d0	;RMB Released?
		beq.s	WakeCode_1	;skip if so
		rts			;else do nothing

WakeCode_1	move.l	mw_handle(a6),a0	;close sleep window
		CALLINT	CloseWindow

		lea	my_main_window(pc),a0
		move.l	10(a0),d0
		move.l	d0,mw_IDCMP(a6)

		lea	ehb_std(pc),a1
		move.l	a1,mw_evblock(a6)

		CALLINT	OpenWindow	;re-open main window

		move.l	d0,mw_handle(a6)
		move.l	d0,a0

		bsr	InitWindow

		move.l	d0,mw_viewport(a6)	;recover this
		move.l	d1,mw_rastport(a6)	;lot
		move.l	d2,mw_userport(a6)

		lea	console_name(pc),a0
		moveq	#0,d0
		move.l	readio(a6),a1
		moveq	#0,d1

		move.l	mw_handle(a6),d2		;ptr to open window
		move.l	d2,ioext_Data(a1)		;save here
		moveq	#ioext_sizeof,d2		;size of IORequest
		move.l	d2,ioext_Length(a1)	;save here

		CALLEXEC	OpenDevice		;recover console
		move.l	d0,dev_error(a6)

		move.l	readio(a6),a0
		move.l	writeio(a6),a1

		move.l	io_Device(a0),io_Device(a1)
		move.l	io_Unit(a0),io_Unit(a1)

		lea	csroff(pc),a0	;turn off cursor
		bsr	WriteConsole

		move.l	mw_rastport(a6),a1	;set the
		moveq	#RP_JAM2,d0		;drawing mode
		CALLGRAF	SetDrMd

		move.l	mw_rastport(a6),a1	;set font
		move.l	topaz_font(a6),a0
		CALLGRAF	SetFont

		move.l	mw_handle(a6),a1		;window
		lea	SearchText(pc),a0		;1st gadget
		sub.l	a2,a2			;no requester
		moveq	#5,d0			;5 gadgets
		CALLINT	RefreshGList		;show them again!

		bsr	ReShowIt		;and show last HELP entry

		rts


* SleepQuit(a6)
* a6 = ptr to main program variables

* Pops up the Sleep quit requester (which is actually
* implemented as a window)

* Note that it HAS to kill off the IDCMP for the sleep window
* otherwise LOTS of SleepQuit() false requesters could come
* into being...

* Then it has to recover the original IDCMP once the false
* requester has finished its job.

* d0-d3/a0-a2 corrupt

SleepQuit	move.l	mw_handle(a6),a0		;temp kill sleep
		moveq	#0,d0			;window IDCMP
		CALLINT	ModifyIDCMP

		lea	SleepQReq(pc),a0
		move.l	10(a0),d0
		move.l	d0,sqw_IDCMP(a6)

		lea	ehb_squit(pc),a1
		move.l	a1,sqw_evblock(a6)

		CALLINT	OpenWindow	;open our new "requester"

		move.l	d0,sqw_handle(a6)	;"requester" handle
		move.l	d0,a0

		bsr	InitWindow

		move.l	d0,sqw_viewport(a6)	;set this lot
		move.l	d1,sqw_rastport(a6)	;up as per usual
		move.l	d2,sqw_userport(a6)

		bset	#7,applic_flag2(a6)	;signal "in requester"

SLQ_loop		move.l	sqw_userport(a6),a0	;now wait for a
		move.l	sqw_evblock(a6),a5	;response

		bsr	DoEvent			;this does it!

		tst.b	applic_flag2(a6)		;hit req gadgets?
		bmi.s	SLQ_loop			;back if not

		btst	#6,applic_flag2(a6)	;YES gadget hit?
		beq.s	SLQ_Done			;exit if not

		bclr	#7,applic_flag1(a6)	;else quit application

SLQ_Done		move.l	sqw_handle(a6),a0		;kill off our
		CALLINT	CloseWindow		;"requester"

		move.l	mw_handle(a6),a0	;bring back old window
		move.l	mw_IDCMP(a6),d0	;IDCMP
		CALLINT	ModifyIDCMP

		move.l	mw_handle(a6),a0
		move.l	UserPort(a0),d0		;get UserPort
		move.l	d0,mw_userport(a6)	;back from the dead

		rts


* QuitReq(a6)
* a6 = ptr to main program variables
* signals end of current requester, with the
* CANCEL gadget pressed.

* NON-MODIFIABLE


QuitReq		bclr	#7,applic_flag2(a6)
		bclr	#6,applic_flag2(a6)
		rts


* LeaveReq(a6)
* a6 = ptr to main program variables
* signals end of current requester,
* with the SELECT/EXECUTE gadget pressed.


LeaveReq		bclr	#7,applic_flag2(a6)
		bset	#6,applic_flag2(a6)
		rts


* LinkInfoText(a6)
* a6 = ptr to main program variables

* Link texts described by the irt_ arguments
* into the InfoReq IntuiTexts. This to be done
* ALWAYS before popping up the requester.

* NOTE : each text is popped into TWO consecutive IntuiTexts.
* The first is the dark background text, the second is the
* main light text. This assumes that there is always an even no.
* of ITexts. At the moment there are 20 of them. Colour and
* jam mode info is fixed for now.

* Variables to be set:

* irt_itext(a6)	: pointer to IntuiText list for requester

* irt_tlist(a6)	: pointer to list of text strings to link in

* irt_count(a6)	: no. of text strings to link in.


* d0-d4/a0-a2 corrupt


LinkInfoText	move.l	irt_itext(a6),a0		;ptr to InfoReq ITexts

		move.l	irt_tlist(a6),a1		;ptr to my text list

		move.w	irt_count(a6),d0		;no. to insert

LITxt_1		move.w	(a1)+,d1			;get position info
		move.w	(a1)+,d2			;from my text list

		move.w	d1,d3			;copy positions
		move.w	d2,d4

		addq.w	#1,d3			;first position is
		addq.w	#1,d4			;displaced slightly

		move.l	a1,12(a0)		;insert text ptr

		move.w	d3,4(a0)			;pop in position
		move.w	d4,6(a0)			;info

		lea	20(a0),a2		;ptr to next IText
		move.l	a2,16(a0)		;and connect them up

		move.l	a2,a0			;point to next IText

		move.l	a1,12(a0)		;insert text ptr

		move.w	d1,4(a0)			;pop in position
		move.w	d2,6(a0)			;info

		lea	20(a0),a2		;ptr to next IText
		move.l	a2,16(a0)		;and connect them up

LITxt_3		tst.b	(a1)+			;scan until next
		bne.s	LITxt_3			;text reached

		move.l	a1,d1			;check for true
		and.b	#1,d1			;even alignment
		beq.s	LITxt_4			;after text scan

		addq.l	#1,a1			;here ensure even!

LITxt_4		subq.w	#1,d0			;done them all?
		beq.s	LITxt_2			;skip if so

		move.l	a2,a0			;point to next
		bra.s	LITxt_1

LITxt_2		clr.l	16(a0)			;signal last IText

		rts


* ShowInfoReq(a6)
* a6 = ptr to main program variables

* Display the InfoRequester until any mouse button pressed.
* This requester needs to be a NOISYREQ requester to allow
* mouse button sensing.

* d0-d1/a0-a1 corrupt


ShowInfoReq	move.l	mw_handle(a6),a0	;kill off IDCMPs for now

		moveq	#MOUSEBUTTONS+MOUSEMOVE,d0	;except these

		CALLINT	ModifyIDCMP

		lea	InfoReq(pc),a0
		move.l	mw_handle(a6),a1

		CALLINT	Request		;pop up requester

		bset	#0,applic_flag2(a6)

SIR_L1		move.l	mw_userport(a6),a0
		lea	ehb_info(pc),a5
		bsr	DoEvent

		btst	#0,applic_flag2(a6)	;finished?
		bne.s	SIR_L1

		lea	InfoReq(pc),a0
		move.l	mw_handle(a6),a1

		CALLINT	EndRequest	;kill the requester

		move.l	mw_handle(a6),a0
		move.l	mw_IDCMP(a6),d0

		CALLINT	ModifyIDCMP	;& recover old IDCMP

		rts


* DoQueryReq(a6)
* a6 = ptr to main program variables

* pop up the QueryRequester & wait for a key press.

* assume ALL registers corrupt!


DoQueryReq	bsr	LinkInfoText

		move.l	ThisReq(a6),a4

		move.l	mw_handle(a6),rhb_Window(a4)
		move.l	mw_userport(a6),rhb_UserPort(a4)
		move.l	mw_IDCMP(a6),rhb_IDCMP(a4)
		lea	QueryReq(pc),a0
		move.l	a0,rhb_Requester(a4)

		clr.l	rhb_PreCode(a4)

		bsr	HandleRequest

		rts


* ExitInfo(a6)
* a6 = ptr to main program variables
* signal exiting the InfoRequester

* If holding required, caller must set bit 2
* of applic_flag2 prior to entry.

* d0 corrupt


ExitInfo		move.w	menu_id(a6),d0		;check for button
		cmp.w	#SELECTUP,d0		;released &
		beq.s	EIF_1			;skip if so
		cmp.w	#MENUUP,d0
		beq.s	EIF_1

		bclr	#2,applic_flag2(a6)	;clear hold flag

		rts

EIF_1		bclr	#2,applic_flag2(a6)	;holding?
		bne.s	EIF_2

		bclr	#0,applic_flag2(a6)
EIF_2		rts


* CmpStrNC(a0,a1) -> CCR
* a0 = ptr to SOURCE string
* a1 = ptr to DESTINATION string

* Performs a CASE INSENSITIVE comparison of two strings.
* Functions as if it were a 68000 CMP instruction on an
* entire string, returning flags set in CCR as for CMP.

* Operating logic as if CMP (a0),(a1) but on whole string.

* Assumes ASCIIZ strings (won't work on BCPL ASCII or EBCDIC!).

* d0-d1 corrupt


CmpStrNC		movem.l	a0-a1,-(sp)	;save original ptrs

CSNC_1		move.b	(a0)+,d0		;get src char
		move.b	(a1)+,d1		;get dst char
		and.b	#$DF,d0		;force ASCII upper case
		and.b	#$DF,d1
		cmp.b	d0,d1		;compare chars
		bne.s	CSNC_2		;exit if unequal
		tst.b	d0		;hit end of string?
		bne.s	CSNC_1		;back if not

CSNC_2		movem.l	(sp)+,a0-a1	;recover ptrs
		rts


* FindKeyWord(a0,a1,a2) -> a0
* a0 = ptr to text file to scan
* a1 = ptr to keyword to scan for
* a2 = ptr to end of file

* Scans help file for initial keyword.

* Returns a0=ptr to found keyword, or NULL if not found

* d0-d1/a0 corrupt


FindKeyWord	bsr	CmpStrNC		;strings match?
		beq.s	FKW_Done

FKW_1		tst.b	(a0)+		;skip to EOS of
		bne.s	FKW_1		;current string

		cmp.l	a2,a0		;hit EOF?
		bcs.s	FindKeyWord	;back for more if not

FKW_Done		rts


* MatchSubString(a0,a1) -> d0
* a0 = ptr to string to search within
* a1 = ptr to substring to look for

* Tests to see if the substring a1 lies
* at the beginning of the string a0. Example:

* a0 -> "Hello, World", a1 -> "Hell", returns d0 -> "Hello, World"

* a0 -> "Hello, World", a1 -> "Bye!", returns d0 = NULL.

* Again, a CASE INSENSITIVE comparison.

* Only works on ASCIIZ strings.

* Returns:

* d0 = ptr to located substring if found, NULL if not

* d1-d3 corrupt


MatchSubString	movem.l	a0-a1,-(sp)	;save pointers

		moveq	#0,d0		;initial substring ptr

MSS_1		move.l	a0,d3		;copy string ptr
		move.b	(a0)+,d1		;get string char
		move.b	(a1)+,d2		;get substring char
		beq.s	MSS_3		;if substring EOS, match found!
		and.b	#$DF,d1		;convert to upper case
		and.b	#$DF,d2
		cmp.b	d1,d2		;matching chars?
		beq.s	MSS_1		;back for more if so
		bra.s	MSS_2		;else return NULL-no match

MSS_3		move.l	d3,d0		;return correct pointer		

MSS_2		movem.l	(sp)+,a0-a1	;recover pointers
		tst.l	d0		;and signal if found
		rts


* SeekItem(a0,a1) -> d0

* a0 = ptr to file to search
* a1 = string/substring to search for within file

* Main search routine for MyLibHelp program.

* Returns :

* d0 = -1 if match found, NULL if not.

* Also conditions some pointer variables in the main
* variable table!

* d1-d3/a0 corrupt


SeekItem		move.l	a1,searchfor(a6)	;save search string

SKI_1		move.l	keyword7(a6),a1	;look for "endfile"
		bsr	MatchSubString	;found it?
		bne.s	SKI_Neg		;exit NOW if so

		move.l	keyword1(a6),a1	;look for "library"
		bsr	MatchSubString	;found it?
		bne.s	SKI_3		;continue onwards if so

		move.l	keyword2(a6),a1	;look for "function"
		bsr	MatchSubString	;found it?
		bne.s	SKI_5		;initiate main search if so

SKI_2		tst.b	(a0)+		;point to next line
		bne.s	SKI_2		;of file

		bra.s	SKI_1		;and back for more


* Come here if "LIBRARY" keyword found in file.


SKI_3		tst.b	(a0)+		;point to next line
		bne.s	SKI_3		;of file

		move.l	a0,currentlib(a6)	;and save library name ptr

SKI_4		tst.b	(a0)+		;point to next line
		bne.s	SKI_4
		bra.s	SKI_1		;and resume scan


* Come here if "FUNCTION" keyword found in file.


SKI_5		tst.b	(a0)+		;point to next line
		bne.s	SKI_5		;of file

		move.l	searchfor(a6),a1	;now look for function name
		bsr	MatchSubString	;found it?
		bne.s	SKI_7		;skip if match found

SKI_6		tst.b	(a0)+		;point to next line
		bne.s	SKI_6		;of file

		bra.s	SKI_1

SKI_7		move.l	a0,currentfunc(a6)	;save ptr to entry

SKI_8		tst.b	(a0)+		;point to next line
		bne.s	SKI_8		;of file

		move.l	a0,currentoff(a6)		;save ptr to offset

		moveq	#-1,d0
		rts

SKI_Neg		moveq	#0,d0			;signal not found
		move.l	d0,currentfunc(a6)
		rts


* GetEntry(a6)
* a6 = ptr to main program variables

* Performs a search for the library function upon
* hitting ENTER in the string gadget. Then displays
* results in the Helper window.

* d0-d3/a0-a2 corrupt


GetEntry		move.l	gadget_id(a6),a1
		move.l	gg_SpecialInfo(a1),a1
		move.l	si_Buffer(a1),a1
		lea	inputbuf(pc),a0

		movem.l	a0-a1,-(sp)	;save current ptrs

GEN_Copy		move.b	(a1)+,(a0)+	;copy text to a safe buffer
		bne.s	GEN_Copy

		movem.l	(sp)+,a0-a1	;recover ptrs

GetOldEnt	tst.b	(a1)		;any text here?
		bne.s	GetEnt

		lea	_INF_NoEntry(pc),a0
		lea	IRT_1(pc),a1
		moveq	#4,d0

		move.l	a1,irt_itext(a6)
		move.l	a0,irt_tlist(a6)
		move.w	d0,irt_count(a6)

		bsr	LinkInfoText
		bsr	ShowInfoReq

		rts

GetEnt		move.l	helpfile(a6),a0

		bsr	SeekItem		;locate it!
		bne.s	GEN_1		;skip if match found


* If it hasn't been found, pop up an InfoRequester informing
* user that it isn't in the help file.


		lea	_INF_NotFnd(pc),a0
		lea	IRT_1(pc),a1
		moveq	#4,d0

		move.l	a1,irt_itext(a6)
		move.l	a0,irt_tlist(a6)
		move.w	d0,irt_count(a6)

		bsr	LinkInfoText
		bsr	ShowInfoReq

		rts


* Come here if the entry IS in the help file, and start printing the
* details.


GEN_1		lea	__Func(pc),a0
		bsr	WriteConsole

		move.l	currentfunc(a6),a0
		bsr	WriteConsole

		moveq	#1,d0
		bsr	LineFeeds

		lea	__Lib(pc),a0
		bsr	WriteConsole

		move.l	currentlib(a6),a0
		bsr	WriteConsole

		moveq	#1,d0
		bsr	LineFeeds

		lea	__Offset(pc),a0
		bsr	WriteConsole

		move.l	currentoff(a6),a0
		bsr	WriteConsole

		moveq	#1,d0
		bsr	LineFeeds

		lea	__Parms(pc),a0
		bsr	WriteConsole

		moveq	#1,d0
		bsr	LineFeeds

		lea	__ClrWin(pc),a0
		bsr	WriteConsole

		btst	#0,applic_flag1(a6)	;68K Asm or C?
		bne	GEN_2			;skip if C


* Here, user has requested Assembler parameters. So do a search
* for APARMS keyword.


		move.l	currentoff(a6),a0

GEN_3		tst.b	(a0)+		;find next line
		bne.s	GEN_3

		move.l	keyword2(a6),a1	;look for "function" keyword
		bsr	MatchSubString	;found it?
		bne.s	GEN_4		;if so, skip

		move.l	keyword1(a6),a1	;look for "library" keyword
		bsr	MatchSubString	;found it?
		bne.s	GEN_4		;if so, skip

		move.l	keyword7(a6),a1	;look for "endfile" keyword
		bsr	MatchSubString	;found it?
		bne.s	GEN_4		;if so, skip

		move.l	keyword4(a6),a1	;look for "aparms" keyword
		bsr	MatchSubString	;found it?
		beq.s	GEN_3		;resume search if not

GEN_5		tst.b	(a0)+		;find next line
		bne.s	GEN_5

		move.l	keyword1(a6),a1	;test if it's a keyword
		bsr	MatchSubString
		bne.s	GEN_6

		move.l	keyword2(a6),a1
		bsr	MatchSubString
		bne.s	GEN_6

		move.l	keyword3(a6),a1
		bsr	MatchSubString
		bne.s	GEN_6

		move.l	keyword7(a6),a1
		bsr	MatchSubString
		bne.s	GEN_6

		bsr	WriteConsole

		moveq	#1,d0
		bsr	LineFeeds

		bra.s	GEN_5

GEN_6		rts

GEN_4		lea	__NoParms(pc),a0
		bsr	WriteConsole

		rts


* Come here if user requests C language parameters.


GEN_2		move.l	currentoff(a6),a0

GEN_7		tst.b	(a0)+		;find next line
		bne.s	GEN_7

		move.l	keyword2(a6),a1	;look for "function" keyword
		bsr	MatchSubString	;found it?
		bne.s	GEN_8		;if so, skip

		move.l	keyword1(a6),a1	;look for "library" keyword
		bsr	MatchSubString	;found it?
		bne.s	GEN_8		;if so, skip

		move.l	keyword7(a6),a1	;look for "endfile" keyword
		bsr	MatchSubString	;found it?
		bne.s	GEN_8		;if so, skip

		move.l	keyword3(a6),a1	;look for "cparms" keyword
		bsr	MatchSubString	;found it?
		beq.s	GEN_7		;resume search if not

GEN_9		tst.b	(a0)+		;find next line
		bne.s	GEN_9

		move.l	keyword1(a6),a1	;test if it's a keyword
		bsr	MatchSubString
		bne.s	GEN_10

		move.l	keyword2(a6),a1
		bsr	MatchSubString
		bne.s	GEN_10

		move.l	keyword3(a6),a1
		bsr	MatchSubString
		bne.s	GEN_10

		move.l	keyword7(a6),a1
		bsr	MatchSubString
		bne.s	GEN_10

		bsr	WriteConsole

		moveq	#1,d0
		bsr	LineFeeds

		bra.s	GEN_9

GEN_10		rts

GEN_8		lea	__NoParms(pc),a0
		bsr	WriteConsole

		rts


* SelectAsm(a6)
* a6 = ptr to main program variables

* Select 68000 assembler parameters & then list them.

* d0-d3/a0-a2 corrupt


SelectAsm	bclr	#0,applic_flag1(a6)

ReShowIt		lea	inputbuf(pc),a1
		bra	GetOldEnt


* SelectC(a6)
* a6 = ptr to main program variables

* Select C language calling parameters & list them.

* d0-d3/a0-a2 corrupt


SelectC		bset	#0,applic_flag1(a6)

		lea	inputbuf(pc),a1
		bra	GetOldEnt


* Here go IDCMP comparator lists for event handling.
* Each entry consists of:1 longword IDCMP spec, then
* 1 longword, address of routine to execute when this
* IDCMP message is received. Last longword 0 marks the
* end of the list.


IDCMPlist1	dc.l	GADGETDOWN,DoIGadget
		dc.l	GADGETUP,DoRGadget
		dc.l	CLOSEWINDOW,QuitCode
		dc.l	MOUSEBUTTONS,DoMBCode
		dc.l	0


IDCMPlist2	dc.l	GADGETDOWN,DoIGadget
		dc.l	GADGETUP,DoRGadget
		dc.l	0

IDCMPlist3	dc.l	MOUSEMOVE,DoneIG
		dc.l	MOUSEBUTTONS,ExitInfo
		dc.l	0


IDCMPlist4	dc.l	MOUSEBUTTONS,WakeCode
		dc.l	CLOSEWINDOW,SleepQuit
		dc.l	0


* Standard Event Handler Block for the main window.


ehb_std		dc.l	AlterEvent	;do VERIFYs?
		dc.l	SelectEvent	;normal OtherCode
		dc.l	IDCMPlist1	;normal IDCMP list


* Event handler block for Requesters


ehb_req		dc.l	AlterEvent	;normal MouseCode
		dc.l	SelectEvent	;normal OtherCode
		dc.l	IDCMPlist2	;requester IDCMP list


* Event handler block for InfoRequesters


ehb_info		dc.l	AlterEvent
		dc.l	SelectEvent
		dc.l	IDCMPlist3


* Event handler block for sleep window


ehb_zzz		dc.l	AlterEvent
		dc.l	SelectEvent
		dc.l	IDCMPlist4


* Event Handler Block for sleep quit "requester"


ehb_squit	dc.l	AlterEvent
		dc.l	SelectEvent
		dc.l	IDCMPlist2

* Requester handling block. Usage:set rhb_Window, rhb_UserPort with
* values for given window. Set rhb_IDCMP with the normal IDCMP for
* the window, to be restored when all requesters are inactive.
* Put ptr to Requester structure in rhb_Requester.
* Then pass pointer to this block in a4 to HandleRequest().


ReqBlock		dc.l	0,0,0,0,0,0


* Topaz-80 font TextAttr structure


Topaz_80		dc.l	Topaz_80_name
		dc.w	8		;height = 8 (TOPAZ_80)
		dc.b	0		;no style flags
		dc.b	$00		;ROM font
		even


* Window structure goes here, followed by its attached gadgets.
* Warning for all those inclined to piddle about with this list,
* the gadget structures have an extra longword appended to the
* end to accomodate separate handling for GADGIMMEDIATE and
* RELVERIFY modes (so that I can have 2 pieces of code called
* per gadget if I want-neat eh?).


my_main_window:

	dc.w	0,20
	dc.w	640,160
	dc.b	0,1
	dc.l	GADGETDOWN+GADGETUP+CLOSEWINDOW+MOUSEBUTTONS
	dc.l	WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
	dc.l	SearchText
	dc.l	NULL
	dc.l	_WinName
	dc.l	NULL
	dc.l	NULL
	dc.w	5,5
	dc.w	-1,-1
	dc.w	WBENCHSCREEN

_WinName:
	dc.b	'NewLibHelp',0
	cnop 0,2

SearchText:
	dc.l	SleepGad
	dc.w	144,106
	dc.w	380,8
	dc.w	GADGHIMAGE
	dc.w	RELVERIFY+GADGIMMEDIATE
	dc.w	STRGADGET
	dc.l	Border1
	dc.l	Border1_1
	dc.l	IText1
	dc.l	NULL
	dc.l	SearchTextSInfo
	dc.w	NULL
	dc.l	DoneIG
	dc.l	GetEntry

SearchTextSInfo:
	dc.l	SearchTextSIBuff
	dc.l	NULL
	dc.w	0
	dc.w	256
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	NULL

SearchTextSIBuff:
	dcb.b 256,0
	cnop 0,2

Border1:
	dc.w	-1,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors1
	dc.l	Border1a

BorderVectors1:
	dc.w	0,0
	dc.w	381,0
	dc.w	381,9
	dc.w	0,9
	dc.w	0,0

Border1a:
	dc.w	-3,-3
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors1a
	dc.l	NULL

BorderVectors1a:
	dc.w	0,0
	dc.w	385,0
	dc.w	385,13
	dc.w	0,13
	dc.w	0,0


Border1_1:
	dc.w	-1,-1
	dc.b	1,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors1
	dc.l	Border1_1a

Border1_1a:
	dc.w	-3,-3
	dc.b	1,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors1a
	dc.l	NULL


IText1:
	dc.b	2,0,RP_JAM1,0
	dc.w	-94,1
	dc.l	NULL
	dc.l	ITextText1
	dc.l	IText2

ITextText1:
	dc.b	'Search For:',0
	cnop 0,2

IText2:
	dc.b	1,0,RP_JAM1,0
	dc.w	-96,0
	dc.l	NULL
	dc.l	ITextText1
	dc.l	IText3


IText3:
	dc.b	2,0,RP_JAM1,0
	dc.w	56,13
	dc.l	NULL
	dc.l	ITextText3
	dc.l	IText4

ITextText3:
	dc.b	'Enter Selection In The Box Above',0
	cnop 0,2

IText4:
	dc.b	1,0,RP_JAM1,0
	dc.w	55,12
	dc.l	NULL
	dc.l	ITextText3
	dc.l	IText5


IText5:
	dc.b	2,0,RP_JAM1,0
	dc.w	-9,-90
	dc.l	NULL
	dc.l	ITextText5
	dc.l	IText6

ITextText5:
	dc.b	'New Library Helper Version 1.0 By Dave Edwards',0
	cnop 0,2

IText6:
	dc.b	1,0,RP_JAM1,0
	dc.w	-11,-91
	dc.l	NULL
	dc.l	ITextText5
	dc.l	IText5a


IText5a:
	dc.b	2,0,RP_JAM1,0
	dc.w	2,31
	dc.l	NULL
	dc.l	ITextText5a
	dc.l	IText6a

ITextText5a:
	dc.b	'Choose',0
	cnop 0,2

IText6a:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,30
	dc.l	NULL
	dc.l	ITextText5a
	dc.l	IText5b


IText5b:
	dc.b	2,0,RP_JAM1,0
	dc.w	2,41
	dc.l	NULL
	dc.l	ITextText5b
	dc.l	IText6b

ITextText5b:
	dc.b	'Language :',0
	cnop 0,2

IText6b:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,40
	dc.l	NULL
	dc.l	ITextText5b
	dc.l	NULL


SleepGad:
	dc.l	QuitGad
	dc.w	12,133
	dc.w	90,20
	dc.w	GADGHIMAGE
	dc.w	RELVERIFY+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	Border2
	dc.l	Border2a
	dc.l	IText7
	dc.l	NULL
	dc.l	NULL
	dc.w	NULL
	dc.l	DoneIG
	dc.l	SleepCode

Border2:
	dc.w	-6,-3
	dc.b	2,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors2
	dc.l	NULL

BorderVectors2:
	dc.w	0,0
	dc.w	101,0
	dc.w	101,25
	dc.w	0,25
	dc.w	0,1


Border2a:
	dc.w	-6,-3
	dc.b	1,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors2a
	dc.l	NULL

BorderVectors2a:
	dc.w	0,0
	dc.w	101,0
	dc.w	101,25
	dc.w	0,25
	dc.w	0,1


IText7:
	dc.b	2,0,RP_JAM1,0
	dc.w	24,7
	dc.l	NULL
	dc.l	ITextText7
	dc.l	IText8

ITextText7:
	dc.b	'Sleep',0
	cnop 0,2

IText8:
	dc.b	1,0,RP_JAM1,0
	dc.w	22,6
	dc.l	NULL
	dc.l	ITextText7
	dc.l	NULL


QuitGad:
	dc.l	CGadget
	dc.w	537,133
	dc.w	90,20
	dc.w	GADGHIMAGE
	dc.w	RELVERIFY+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	Border3
	dc.l	Border3a
	dc.l	IText9
	dc.l	NULL
	dc.l	NULL
	dc.w	NULL
	dc.l	DoneIG
	dc.l	QuitCode

Border3:
	dc.w	-6,-3
	dc.b	2,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors3
	dc.l	NULL

BorderVectors3:
	dc.w	0,0
	dc.w	101,0
	dc.w	101,25
	dc.w	0,25
	dc.w	0,1


Border3a:
	dc.w	-6,-3
	dc.b	1,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors3a
	dc.l	NULL

BorderVectors3a:
	dc.w	0,0
	dc.w	101,0
	dc.w	101,25
	dc.w	0,25
	dc.w	0,1


IText9:
	dc.b	2,0,RP_JAM1,0
	dc.w	32,7
	dc.l	NULL
	dc.l	ITextText9
	dc.l	IText10

ITextText9:
	dc.b	'Quit',0
	cnop 0,2

IText10:
	dc.b	1,0,RP_JAM1,0
	dc.w	30,6
	dc.l	NULL
	dc.l	ITextText9
	dc.l	NULL


CGadget:
	dc.l	AGadget
	dc.w	242,133
	dc.w	90,20
	dc.w	GADGHIMAGE
	dc.w	RELVERIFY+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	Border2
	dc.l	Border2a
	dc.l	IText11
	dc.l	NULL
	dc.l	NULL
	dc.w	NULL
	dc.l	DoneIG
	dc.l	SelectC

IText11:
	dc.b	2,0,RP_JAM1,0
	dc.w	43,7
	dc.l	NULL
	dc.l	ITextText11
	dc.l	IText12

ITextText11:
	dc.b	'C',0
	cnop 0,2

IText12:
	dc.b	1,0,RP_JAM1,0
	dc.w	41,6
	dc.l	NULL
	dc.l	ITextText11
	dc.l	NULL


AGadget:
	dc.l	NULL
	dc.w	352,133
	dc.w	90,20
	dc.w	GADGHIMAGE
	dc.w	RELVERIFY+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	Border2
	dc.l	Border2a
	dc.l	IText13
	dc.l	NULL
	dc.l	NULL
	dc.w	NULL
	dc.l	DoneIG
	dc.l	SelectAsm

IText13:
	dc.b	2,0,RP_JAM1,0
	dc.w	11,7
	dc.l	NULL
	dc.l	ITextText13
	dc.l	IText14

ITextText13:
	dc.b	'Assembler',0
	cnop 0,2

IText14:
	dc.b	1,0,RP_JAM1,0
	dc.w	9,6
	dc.l	NULL
	dc.l	ITextText13
	dc.l	NULL


* This window is for sleeping until RMB pressed (thanks for the
* idea Mark!) This window will therefore have RMBTRAP set. WARNING -
* Check equates above!


zzzwindow:

	dc.w	0,0
	dc.w	260,10
	dc.b	1,2
	dc.l	MOUSEBUTTONS+CLOSEWINDOW
	dc.l	WINDOWCLOSE+WINDOWDRAG+WINDOWDEPTH+RMBTRAP
	dc.l	NULL			;gadget ptr
	dc.l	NULL
	dc.l	SleepName
	dc.l	NULL
	dc.l	NULL
	dc.w	5,5
	dc.w	-1,-1
	dc.w	WBENCHSCREEN

SleepName:

	dc.b	"Helper...Zzzz",0
	even


* InfoRequester structure goes here! Note that it's changed
* because of the move to a 640x256 WorkBench screen. It's
* followed by its associated borders, gadgets etc.


InfoReq:
	dc.l	NULL
	dc.w	0,0
	dc.w	640,160
	dc.w	0,0
	dc.l	NULL		;gadget ptr
	dc.l	IFB		;Border ptr
	dc.l	IRT_1		;text ptr
	dc.w	NOISYREQ		;Allow mouse button sensing!
	dc.b	4,1
	dc.l	NULL
	dcb.b	32,0
	dc.l	NULL
	dc.l	NULL
	dcb.b	36,0


* Border


IFB:
	dc.w	4,2
	dc.b	2,0,RP_JAM2
	dc.b	5
	dc.l	IFBList
	dc.l	IFB2

IFB2:
	dc.w	8,4
	dc.b	2,0,RP_JAM2
	dc.b	5
	dc.l	IFBList2
	dc.l	NULL


IFBList:
	dc.w	0,0
	dc.w	629,0
	dc.w	629,153
	dc.w	0,153
	dc.w	0,0

IFBList2:
	dc.w	0,0
	dc.w	621,0
	dc.w	621,149
	dc.w	0,149
	dc.w	0,0


* InfoTexts IntuiText structures.


IRT_1:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL		;font ptr
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_ 16(An)

;IRT_2:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_

;IRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next IRT_


* This is the QueryRequester structure. Again it's altered for a
* 640x256 WorkBench screen.


QueryReq:
	dc.l	NULL
	dc.w	0,0
	dc.w	640,160
	dc.w	0,1
	dc.l	QR_Select	;gadget ptr
	dc.l	QRB		;Border ptr
	dc.l	QRT_1		;text ptr
	dc.w	NULL
	dc.b	4,1
	dc.l	NULL
	dcb.b	32,0
	dc.l	NULL
	dc.l	NULL
	dcb.b	36,0


* Gadgets used by QueryReq


QR_Select:
	dc.l	QR_Cancel
	dc.w	20,128
	dc.w	90,20
	dc.w	GADGHIMAGE
	dc.w	GADGIMMEDIATE+RELVERIFY+ENDGADGET
	dc.w	BOOLGADGET+REQGADGET
	dc.l	Border2
	dc.l	Border2a
	dc.l	QT_1
	dc.l	NULL
	dc.l	NULL
	dc.w	NULL		;18
	dc.l	DoneIG
	dc.l	LeaveReq		;extra entry!

QT_1:
	dc.b	2,0,RP_JAM1,0
	dc.w	34,7
	dc.l	NULL
	dc.l	QTT_1	;text ptr
	dc.l	QT_2

QT_2:
	dc.b	1,0,RP_JAM1,0
	dc.w	33,6
	dc.l	NULL
	dc.l	QTT_1	;text ptr
	dc.l	NULL


QTT_1:
	dc.b	"Yes",0
	cnop	0,2

QR_Cancel:
	dc.l	NULL
	dc.w	526,128
	dc.w	90,20
	dc.w	GADGHIMAGE
	dc.w	GADGIMMEDIATE+RELVERIFY+ENDGADGET
	dc.w	BOOLGADGET+REQGADGET
	dc.l	Border2
	dc.l	Border2a
	dc.l	QT_3
	dc.l	NULL
	dc.l	NULL
	dc.w	NULL		;19
	dc.l	DoneIG
	dc.l	QuitReq		;extra entry!

QT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	38,7
	dc.l	NULL
	dc.l	QTT_2	;text ptr
	dc.l	QT_4

QT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	37,6
	dc.l	NULL
	dc.l	QTT_2	;text ptr
	dc.l	NULL

QTT_2:
	dc.b	"No",0
	cnop	0,2


* Border


QRB:
	dc.w	0,0
	dc.b	3,0,RP_JAM2
	dc.b	5
	dc.l	QRBList1
	dc.l	QRB2

QRB2:
	dc.w	6,3
	dc.b	3,0,RP_JAM2
	dc.b	5
	dc.l	QRBList2
	dc.l	NULL

QRBList1:
	dc.w	0,0
	dc.w	637,0
	dc.w	637,157
	dc.w	0,157
	dc.w	0,0

QRBList2:
	dc.w	0,0
	dc.w	625,0
	dc.w	625,151
	dc.w	0,151
	dc.w	0,0


* InfoTexts IntuiText structures used by LinkInfoText()


QRT_1:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL		;font ptr
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_ 16(An)

;QRT_2:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	1,1
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_

;QRT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	0,0
	dc.l	NULL
	dc.l	NULL		;text pointer 12(An)
	dc.l	NULL		;ptr to next QRT_


* Sleep window quit requester (actually a WINDOW)


SleepQReq:

	dc.w	0,20
	dc.w	640,160
	dc.b	0,1
	dc.l	GADGETUP+GADGETDOWN
	dc.l	BORDERLESS+RMBTRAP
	dc.l	SQG_Select			;gadget ptr
	dc.l	NULL
	dc.l	NULL
	dc.l	NULL
	dc.l	NULL
	dc.w	5,5
	dc.w	-1,-1
	dc.w	WBENCHSCREEN


* Gadgets used by SleepQReq


SQG_Select:
	dc.l	SQG_Cancel
	dc.w	20,124
	dc.w	90,20
	dc.w	GADGHIMAGE
	dc.w	GADGIMMEDIATE+RELVERIFY+ENDGADGET
	dc.w	BOOLGADGET+REQGADGET
	dc.l	Border2
	dc.l	Border2a
	dc.l	SQGT_1
	dc.l	NULL
	dc.l	NULL
	dc.w	NULL		;18
	dc.l	DoneIG
	dc.l	LeaveReq		;extra entry!

SQGT_1:
	dc.b	2,0,RP_JAM1,0
	dc.w	34,7
	dc.l	NULL
	dc.l	SQGTT_1	;text ptr
	dc.l	SQGT_2

SQGT_2:
	dc.b	1,0,RP_JAM1,0
	dc.w	33,6
	dc.l	NULL
	dc.l	SQGTT_1	;text ptr
	dc.l	NULL


SQGTT_1:
	dc.b	"Yes",0
	cnop	0,2

SQG_Cancel:
	dc.l	SQG_Image
	dc.w	526,124
	dc.w	90,20
	dc.w	GADGHIMAGE
	dc.w	GADGIMMEDIATE+RELVERIFY+ENDGADGET
	dc.w	BOOLGADGET+REQGADGET
	dc.l	Border2
	dc.l	Border2a
	dc.l	SQGT_3
	dc.l	NULL
	dc.l	NULL
	dc.w	NULL		;19
	dc.l	DoneIG
	dc.l	QuitReq		;extra entry!

SQGT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	38,7
	dc.l	NULL
	dc.l	SQGTT_2	;text ptr
	dc.l	SQGT_4

SQGT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	37,6
	dc.l	NULL
	dc.l	SQGTT_2	;text ptr
	dc.l	NULL

SQGTT_2:
	dc.b	"No",0
	cnop	0,2

SQG_Image:
	dc.l	NULL
	dc.w	0,0
	dc.w	1,1
	dc.w	NULL			;gadget flags
	dc.w	NULL			;activation
	dc.w	BOOLGADGET+REQGADGET
	dc.l	SQB
	dc.l	NULL
	dc.l	SQT_1
	dc.l	NULL
	dc.l	NULL
	dc.w	NULL		;19
	dc.l	DoneIG
	dc.l	DoneRG		;extra entry!


* Border


SQB:
	dc.w	2,2
	dc.b	3,0,RP_JAM2
	dc.b	5
	dc.l	SQBList1
	dc.l	SQB2

SQB2:
	dc.w	8,5
	dc.b	3,0,RP_JAM2
	dc.b	5
	dc.l	SQBList2
	dc.l	NULL

SQBList1:
	dc.w	0,0
	dc.w	635,0
	dc.w	635,153
	dc.w	0,153
	dc.w	0,0

SQBList2:
	dc.w	0,0
	dc.w	623,0
	dc.w	623,147
	dc.w	0,147
	dc.w	0,0


* Sleep window Quit requester text


SQT_1:
	dc.b	2,0,RP_JAM1,0
	dc.w	266,21
	dc.l	NULL
	dc.l	SQTT_1	;text ptr
	dc.l	SQT_2

SQT_2:
	dc.b	1,0,RP_JAM1,0
	dc.w	264,20
	dc.l	NULL
	dc.l	SQTT_1	;text ptr
	dc.l	SQT_3

SQTT_1:
	dc.b	"Library Helper",0
	cnop	0,2


SQT_3:
	dc.b	2,0,RP_JAM1,0
	dc.w	254,49
	dc.l	NULL
	dc.l	SQTT_2	;text ptr
	dc.l	SQT_4

SQT_4:
	dc.b	1,0,RP_JAM1,0
	dc.w	252,48
	dc.l	NULL
	dc.l	SQTT_2	;text ptr
	dc.l	SQT_5

SQTT_2:
	dc.b	"Are You Sure That",0
	cnop	0,2

SQT_5:
	dc.b	2,0,RP_JAM1,0
	dc.w	254,63
	dc.l	NULL
	dc.l	SQTT_3	;text ptr
	dc.l	SQT_6

SQT_6:
	dc.b	1,0,RP_JAM1,0
	dc.w	252,62
	dc.l	NULL
	dc.l	SQTT_3	;text ptr
	dc.l	NULL

SQTT_3:
	dc.b	"You Wish To Quit?",0
	cnop	0,2



* Palette goes here.


Palette:
	dc.w	$0000,$0FFF,$004B,$008C
	dc.w	$0070,$0FF0,$0B00,$0630
	dc.w	$0741,$0951,$0A72,$0B84
	dc.w	$0DA5,$0AAA,$0777,$0555

	dc.w	$0000,$0FF0,$0A72,$0DA5	;sprite colours
	dc.w	$0070,$0FF0,$0B00,$0630
	dc.w	$0741,$0951,$0A72,$0B84
	dc.w	$0DA5,$0AAA,$0777,$0555


* Texts such as library names etc.


dos_name		dc.b	"dos.library",0

int_name		dc.b	"intuition.library",0

graf_name	dc.b	"graphics.library",0

Topaz_80_name	dc.b	"topaz.font",0

console_name	dc.b	"console.device",0

myreadport	dc.b	"LibHelp.RdPort",0

mywriteport	dc.b	"LibHelp.WrPort",0

HelpFileName	dc.b	"DF0:S/NewLibHelp.Text",0

__KeyWords	dc.b	"LIBRARY",0
		dc.b	"FUNCTION",0
		dc.b	"CPARMS",0
		dc.b	"APARMS",0
		dc.b	"COMMENT",0
		dc.b	"ENDLIB",0
		dc.b	"ENDFILE",0

csroff		dc.b	_CSI_CHAR,$30,$20,$70,0

csron		dc.b	_CSI_CHAR,$20,$70

__Func		dc.b	_CSI_CHAR,$31,$3B,$31,$48	;cursor home
		dc.b	10,10
		dc.b	"Function : "
		dc.b	_CSI_CHAR,$4B		;erase rest of line
		dc.b	0

__Lib		dc.b	"Library  : "
		dc.b	_CSI_CHAR,$4B
		dc.b	0

__Offset		dc.b	"Offset   : "
		dc.b	_CSI_CHAR,$4B
		dc.b	0

__Parms		dc.b	"Parameters :",0

__NoParms	dc.b	"None Listed In HelpFile!"
		dc.b	_CSI_CHAR,$4B
		dc.b	10,_CSI_CHAR,$4B
		dc.b	10,_CSI_CHAR,$4B
		dc.b	10,_CSI_CHAR,$4B
		dc.b	10,_CSI_CHAR,$4B
		dc.b	0

__ClrWin		dc.b	_CSI_CHAR,$4B
		dc.b	10,_CSI_CHAR,$4B
		dc.b	10,_CSI_CHAR,$4B
		dc.b	10,_CSI_CHAR,$4B
		dc.b	10,_CSI_CHAR,$4B
		dc.b	11,11,11,11
		dc.b	0

__LErase		dc.b	_CSI_CHAR,$4B,0

		dc.b	10,10,10,10,10,10,10,10,10,10
		dc.b	10,10,10,10,10,10,10,10,10,10
		dc.b	10,10,10,10,10,10,10,10,10,10
__crlf		dc.b	0

* Inforequester/Queryrequester texts.


Quit_YN		dc.w	276,20
		dc.b	"Quit Helper",0
		even

		dc.w	216,48
		dc.b	"Sure That You Wish To Quit?",0
		even


Sleep_YN		dc.w	244,20
		dc.b	"Put Helper To Sleep",0
		even

		dc.w	216,48
		dc.b	"Are You Sure That You Wish",0
		even

		dc.w	232,62
		dc.b	"To Put Helper To Sleep?",0
		even


* Texts for Normal InfoRequesters


_INF_NotFnd	dc.w	264,20
		dc.b	"Library Helper",0
		even

		dc.w	200,48
		dc.b	"The Item That You Requested To",0
		even

		dc.w	200,62
		dc.b	"Search For Has Not Been Found.",0
		even

		dc.w	236,90
		dc.b	"Press A Mouse Button.",0
		even


_INF_NoEntry	dc.w	264,20
		dc.b	"Library Helper",0
		even

		dc.w	204,48
		dc.b	"You Have Not Entered Any Text",0
		even

		dc.w	224,62
		dc.b	"Into The Text Entry Box!",0
		even

		dc.w	236,90
		dc.b	"Press A Mouse Button.",0
		even


_INF_NewDisc	dc.w	264,20
		dc.b	"Library Helper",0
		even

		dc.w	192,48
		dc.b	"Insert Disc Containing Help File",0
		even

		dc.w	220,62
		dc.b	"Into Drive DF0:, And Then",0
		even

		dc.w	236,76
		dc.b	"Press A Mouse Button.",0
		even


_INF_Loaded	dc.w	264,20
		dc.b	"Library Helper",0
		even

		dc.w	240,48
		dc.b	"HelpFile Now Loaded.",0
		even

		dc.w	236,76
		dc.b	"Press A Mouse Button.",0
		even


* Texts for Error InforRequesters


_ERR_Nofile	dc.w	240,20
		dc.b	"Library Helper Error",0
		even

		dc.w	228,48
		dc.b	"Unable To Find The File",0
		even

		dc.w	256,62
		dc.b	"S:NewLibHelp.Text",0
		even

		dc.w	224,76
		dc.b	"Want To Try Again With A",0
		even

		dc.w	260,90
		dc.b	"Different Disc?",0
		even


_ERR_NoMem1	dc.w	264,20
		dc.b	"Library Helper",0
		even

		dc.w	204,48
		dc.b	"Cannot Allocate FileInfoBlock",0
		even

		dc.w	196,62
		dc.b	"As There Is Insufficient Memory.",0
		even

		dc.w	236,90
		dc.b	"Press A Mouse Button.",0
		even


_ERR_NoMem2	dc.w	264,20
		dc.b	"Library Helper",0
		even

		dc.w	212,48
		dc.b	"Cannot Allocate File Buffer",0
		even

		dc.w	196,62
		dc.b	"As There Is Insufficient Memory.",0
		even

		dc.w	236,90
		dc.b	"Press A Mouse Button.",0
		even


_ERR_NotOpen	dc.w	264,20
		dc.b	"Library Helper",0
		even

		dc.w	212,48
		dc.b	"Cannot Open The HelpFile!"
		even

		dc.w	236,76
		dc.b	"Press A Mouse Button.",0
		even


* Buffer for input strings.


inputbuf		ds.b	256

progend		equ	*











