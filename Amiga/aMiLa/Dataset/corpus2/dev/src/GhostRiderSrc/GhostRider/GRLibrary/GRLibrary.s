;-----------------T-------T---------------T----------------------------------T
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
; This source is © Copyright 1992-1995, Jesper Skov.
; Read "GhostRiderSource.ReadMe" for a description of what you may do with
; this source!
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
; Please do not abuse! Thanks. Jesper
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;-----------------------------------------------------------------------------;
;- Program Title	: GhostRider.Library	-;
;- Copyright Status	: (c) Copyright Jesper Skov.	-;
;- Programmed by	: Jesper Skov		-;
;- Version.Revision	: 38.2		-;
;- Project start	: 27.03.94		-;
;-----------------------------------------------------------------------------;
;- Program Description	: GhostRider system interface.
;----
;- Extract autodoc with : "autodoc -s -I <name> >dh2:autodocs/ghostrider.doc"
;-----------------------------------------------------------------------------;
;- 		       Program History	-;
;-----------------------------------------------------------------------------;
;- 030894 - Added OrgVectors to EnterGR
;-----------------------------------------------------------------------------;
;Must be made re-entrant!

	include	gri:IPIdentifiers.i

	incdir	include:
	include	exec/initializers.i

	include	libraryOffsets/exec_lib.i
	include	exec/execbase.i
	include	exec/exec.i
	include devices/input.i
	include devices/inputevent.i

	include	gr:grlibrary/include/libraries/ghostrider.i

b	equr	a5


version	set	37
revision	set	2
VERSTRING	macro
	dc.b	'37.2 (3 Aug 1994)'
	endm

Call	macro
	jsr	_LVO\1(a6)
	endm

CallE	macro
	move.l	4.w,a6
	jsr	_LVO\1(a6)
	endm

Push            macro                           ;push all or selected regs
                ifc     all,\1                  ;on the stack
                movem.l d0-a6,-(a7)
                else
                movem.l \1,-(a7)
                endc
                endm

Pull            macro                           ;pull all or selected regs
                ifc     all,\1                  ;from the stack
                movem.l (a7)+,d0-a6
                else
                movem.l (a7)+,\1
                endc
                endm



	SECTION	GhostRiderLibrary,CODE

_entry	moveq	#$14,D0
	rts

ResidentData	dc.w	$4AFC	;ID word
	dc.l	ResidentData
	dc.l	LibraryEnd	;is this correct?
	dc.b	RTF_AUTOINIT	;flags
	dc.b	version
	dc.b	NT_LIBRARY
	dc.b	0	;priority
	dc.l	GRLibraryName
	dc.l	GRLibraryID
	dc.l	Initializer

Initializer	dc.l	GRLIB_POSSIZE
	dc.l	FunctionTable
	dc.l	DataTable
	dc.l	InitGRLibrary

FunctionTable	dc.l	GR_Open
	dc.l	GR_Close
	dc.l	GR_ExpungeLib
	dc.l	GR_ExtFunc
	dc.l	GR_EnterGR
	dc.l	GR_SetEntry
	dc.l	GR_SetBreakPoint
	dc.l	GR_ClrBreakPoint
	dc.l	$FFFFFFFF	;End of functiontable

DataTable	INITBYTE LN_TYPE,9
	INITLONG LN_NAME,GRLibraryName
	INITBYTE LIB_FLAGS,LIBF_CHANGED!LIBF_SUMUSED
	INITWORD LIB_VERSION,version
	INITWORD LIB_REVISION,revision
	INITLONG LIB_IDSTRING,GRLibraryID
	dc.l	0

InitGRLibrary	move.l	A5,-(SP)
	movea.l	D0,A5
	move.l	A0,gr_seglist(A5)
	move.l	A6,gr_execbase(A5)
	movea.l	(SP)+,A5
	rts

GR_Open	addq.w	#1,LIB_OPENCNT(A6)
	bclr	#LIBB_DELEXP,LIB_FLAGS(A6)
	move.l	A6,D0
	rts

GR_Close	moveq	#0,D0
	subq.w	#1,LIB_OPENCNT(A6)
	bne.s	.noexpunge
	btst	#LIBB_DELEXP,LIB_FLAGS(A6)
	bne.w	.noexpunge
.noexpunge	rts

;Must be sure to have InputEvent patch removed
GR_ExpungeLib	movem.l	D2/A5/A6,-(SP)
	tst.w	LIB_OPENCNT(A6)	;OK to expunge?
	beq.b	.ExpungeNow
	bset	#LIBB_DELEXP,LIB_FLAGS(A6);set delayed expunge
	moveq	#0,D0
	bra.b	.InUse

.ExpungeNow	movea.l	A6,A5
	movea.l	gr_execbase(A5),A6
	movea.l	A5,A1
	move.l	gr_seglist(A5),D2
	jsr	_LVORemove(A6)
	movea.l	A5,A1
	moveq	#0,D0
	moveq	#0,D1
	move.w	LIB_NEGSIZE(A5),D1
	suba.l	D1,A1
	move.w	LIB_POSSIZE(A5),D0
	add.l	D1,D0
	jsr	_LVOFreeMem(A6)
	move.l	D2,D0
.InUse	movem.l	(SP)+,D2/A5/A6
	rts

GR_ExtFunc	moveq	#0,D0
	rts

;****** ghostrider.library/grEnterGR ****************************************
*
*   NAME
*	grEnterGR -- Enter GhostRider by system call.
*
*   SYNOPSIS
*	error = grEnterGR( OrgPC, OrgStack )
*	D0		   D0,    D1
*
*	BYTE grEnterGR( APTR, APTR );
*
*   FUNCTION
*	If your program's error handler call this function you might have a
*	better chance of finding bugs in your software.
*	This function also gives you the possibility of having a look at
*	structures/tables/registers etc., on the fly.
*	With the two parameters, OrgPC and OrgStack, you may pass "fake"
*	stack and PC values to GhostRider. Now, why would you do this?
*	Here is an example; You are working on an application which have a
*	handler in the input stream. The function of this handler is to
*	notify the main program of a specific hot-key activation (quit,
*	iconify or whatever). This can be done with standard signal
*	notification (via Exec), and since you have the handler ready, you
*	decide to use it for debugging purpose as well. By using the
*	tc_ExceptCode field of your task, an extra signal and the Exec
*	function SetExcept you get a _very_ powerfull debugging facility.
*	Now, the task exception is a lovely thing because it will break
*	your task's execution and enter the exception code. Let this code
*	retrieve the task's PC and the correct stack position and pass this
*	in the call to GhostRider. When GR is invoked it's current address
*	will be positioned at the location on which the task execution was
*	halted. Also, the stackpointer will be correct. Unfortunately the
*	contents of the other registers will not be correct. However, you
*	will be able to find their correct contents at the negative side
*	of the stackpointer.
*	If OrgPC or OrgStack is NULL, the PC/Stack addresses will be
*	derived from the stack (this will be the actual caller and
*	stack addresses).
*
*   EXAMPLES
*	This example show how to use the grEnterGR call in a task. With the
*	setup below, it is possible to break the task execution even from
*	another task or an interrupt (or an input event handler). If you
*	use an interrupt/event handler you will be able to invoke GR
*	asynchronously much like with a NMI-button. This entry method has
*	the added feature of being more system friendly, though.
*
*
*	;---- This code initializes the exception
*	SetupSignalExceptions
*			move.l	$4.w,a6
*			sub.l	a1,a1			;Find task
*			jsr	_LVOFindTask(a6)
*			move.l	d0,MyTask
*
*			move.l	d0,a0			;Set exception ptr
*			move.l	#TaskExceptionCode,TC_EXCEPTCODE(a0)
*
*			moveq	#-1,d0
*			jsr	_LVOAllocSignal(a6)	;Allocate signal
*			move.w	d0,GhostRiderSignal	;and store
*
*			moveq	#0,d0			;Mark signal for
*			move.w	GhostRiderSignal(pc),d1	;exception
*			bset	d1,d0
*			move.l	d0,d1
*			jsr	_LVOSetExcept(a6)
*			rts
*
*	;---- This code frees the signal 
*			move.l	$4.w,a6
*			moveq	#0,d0
*			move.w	GhostRiderSignal(pc),d0
*			jsr	_LVOFreeSignal(a6)	;Free signal
*			rts
*
*
*	;---- This is the exception code
*	TaskExceptCode	movem.l	d0-a6,-(a7)
*
*			move.w	GhostRiderSignal(pc),d1	;Does causing
*			btst	d1,d0			;signal match?
*			beq.b	.DontInvokeGR
*
*			move.l	8+15*4(a7),d0		;Get task PC
*			move.l	a7,d1			;Calculate
*			add.l	#8+4+2+15*4+15*4,d1	;task SP
*			move.l	_GRBase(pc),a6
*			jsr	_LVOgrEnterGR(a6)	;and call GR
*
*	.DontInvokeGR	movem.l	(a7)+,d0-a6
*			rts
*
*	;---- Use the code below to invoke GhostRider
*			...
*			move.l	$4.w,a6
*			moveq	#0,d0			;Build signal
*			move.w	GhostRiderSignal(pc),d1
*			bset	d1,d0
*			move.l	MyTask(pc),a1		;Get task ptr
*			jsr	_LVOSignal(a6)		;and signal
*			... 	(I guess this is the PC you will get if
*				 this code is put in the task execution
*				 flow.)
*
*
*   INPUTS
*	OrgPC	- The value GhostRider should use to when you refer to the
*		  PC register.
*	OrgStack- The value GhostRider should use to when you refer to the
*		  stack register (see bugs note below).
*
*   BUGS
*	Since this function use the system to startup GhostRider, some of
*	the register information will be destroyed. If you want a "clean"
*	entry you should use the grSetBreakPoint() function.
*
*	This function assumes that it has been called from user mode. If
*	it is called from supervisor mode the stackpointer and SR will not
*	reflect this - the OrgStack will always be copied to USP.
*
*	When GhostRider is invoked with fake PC/SP it is not possible to
*	change the exit address (well, it is, but you will have to do it
*	on the stack yourself).
*
*   SEE ALSO
*	grSetBreakPoint()
*
*****************************************************************************
*
*/

GR_EnterGR	Push	all

	move.l	d0,d7	;temp storage

	moveq	#ip_SysEntry,d0
	bsr.b	FindGRAddress
	bmi.b	.NoGRPort

	move.l	d7,d0	;get org d0
	jsr	(a4)

.NoGRPort	Pull	all
	rts

;---- This function will return the GR list base
;- Input:	d0 -	ip_ID
;- Output:	d0 -	0 = OK/Error
;-	a4 -	List ptr
;----
FindGRAddress	Push	d1/d7/a6
	move.l	d0,d7
	lea	GRIDName(pc),a1
	CallE	FindPort
	tst.l	d0
	beq.w	.NoGRPort
	move.l	d0,a0
	move.l	MP_SIZE(a0),a0;get IP base

.SearchEntry	move.w	(a0),d0
	bmi.b	.NoGRPort
	addq.w	#6,a0
	cmp.w	d7,d0
	bne.b	.SearchEntry
	move.l	-(a0),a4
	moveq	#0,d0
	bra.b	.Exit

.NoGRPort	moveq	#gr_grnotfound,d0

.Exit	Pull	d1/d7/a6
	tst.l	d2
	rts

;****** ghostrider.library/grSetBreakPoint **********************************
*
*   NAME	
*	grSetBreakPoint -- Add breakpoint to address.
*
*   SYNOPSIS
*	error = grSetBreakPoint( Address )
*	D0                       A0
*
*	BYTE grSetBreakPoint( APTR )
*
*   FUNCTION
*	This function makes it possible to use GhostRider as a debugger
*	while you are developing a new program. By calling this function
*	in the start of the program the breakpoint(s) will always be
*	correctly positioned.
*	Also, by using this function you can keep all GhostRider interfacing
*	in one part of your program (as opposed to using grEnterGR()), making
*	it easier to remove later.
*
*   INPUTS
*	Address - Address to be added to the breakpoint table.
*
*   RESULT
*	error	- Result of operation. If not NULL it is identifying one of
*		  the situations below:
*
*		  gr_grnotfound	- The library could not find GhostRider in
*				  the system. (Re)load GhostRider using the
*				  DeckRunner.
*		  gr_sbp_fail	- Address could not be accessed (actually a
*				  verify error)
*		  gr_sbp_full	- Breakpoint table is full.
*		  gr_sbp_isset	- Address already have a breakpoint.
*
*   EXAMPLES
*	This example shows how to have a quick look at the result of a
*	function call by invoking GhostRider immediately after the call
*	returns:
*		...
*		lea	LetsSeeWhatWeHaveGot(pc),a0 ;This could be in the
*		Call	grSetBreakPoint		;very beginning of the code.
*		...
*		Call	SomethingUtterlyBoringAndVeryConfuzing
*	LetsSeeWhatWeHaveGot:			;When the CPU reach this
*		...				;point, GhostRider will be
*						;invoked.
*
*	This example show how to deal with TRAP command conflicts (see the
*	BUGS section):
*		...
*		lea	-1,a0			;This will clear the
*		Call	grClearBreakPoint	;breakpoint table, thus
*		move.l	#MyTRAPHandler,$80+VBR	;forcing GhostRider to fetch
*		lea	SomeBreakPoint(pc),a0	;the pointer to MyTRAPHandler
*		Call	grSetBreakPoint		;when the first breakpoint is
*		...				;set.
*
*   NOTES
*	Remember: GhostRider is not system dependant, so you are able to use
*		  this function to set breakpoints in parts of your code
*		  which suffer from... er, attitude problems :^)
*
*   BUGS
*	Since GhostRider use one of the TRAP commands for breakpoint setting
*	you might get a conflict if your program also uses TRAP commands.
*	You can circumvent this problem in two ways:
*	- By not using the same TRAP command used by GhostRider (defaults
*	  to TRAP #0, but may be changed from within GhostRider)
*	- By clearing all breakpoints, set your TRAP vector and then set the
*	  needed breakpoints. GhostRider will only act upon TRAPs that match
*	  a breakpoint. Others are parsed through to the original TRAP
*	  vector. The "original TRAP vector" is fetched whenever a "first"
*	  breakpoint is set. That is why you must clear the breakpoint table
*	  before setting your own vector.
*
*   SEE ALSO
*	grEnterGR(), grClearBreakPoint(), libraries/ghostrider.i
*
*****************************************************************************
*
*/

;---- Set breakpoint at address
;- Input:	a0 -	Address
;- Output:	d0 -	Status
;----
GR_SetBreakPoint	Push	d1-a6

	move.l	a0,d7

	moveq	#ip_SetBRKPT,d0
	bsr.b	FindGRAddress
	bne.b	.Exit

	CallE	Disable
	bsr.b	GetVBR
	move.l	d7,a0
	jsr	(a4)
	move.l	d0,d7

	Call	CacheClearU
	Call	Enable
	move.l	d7,d0

.Exit	Pull	d1-a6
	rts


;****** ghostrider.library/grClearBreakPoint ********************************
*
*   NAME	
*	grClearBreakPoint -- Remove breakpoint from address or clear table.
*
*   SYNOPSIS
*	error = grClearBreakPoint( Address )
*	D0                         A0
*
*	BYTE grClearBreakPoint( APTR )
*
*   FUNCTION
*	This function removes a breakpoint set with grSetBreakPoint() or
*	clears the breakpoint table if called with the value -1.
*
*   INPUTS
*	Address - Address to be removed from the breakpoint table or -1 for
*		  clearing the breakpoint table.
*
*   RESULT
*	error	- Result of operation. If not NULL it is identifying one of
*		  the situations below:
*
*		  gr_grnotfound	- The library could not find GhostRider in
*				  the system. (Re)load GhostRider using the
*				  DeckRunner.
*		  gr_sbp_notset	- Address did not have a breakpoint.
*
*   NOTES
*	If a breakpoint is executed (i.e. GhostRider is invoked) the
*	breakpoint will be removed from the list. Because of this you should
*	be able to ignore the gr_sbp_notset error in normal situations.
*
*   SEE ALSO
*	grSetBreakPoint(), libraries/ghostrider.i
*
*****************************************************************************
*
*/


;---- Remove breakpoint from address
;- Input:	a0 -	Address to free / -1 for all breakpoints
;- Output:	d0 -	Status
;-	d1 -	# of remaining BPs if OK
;----
GR_ClrBreakPoint	Push	d2-a6

	move.l	a0,d7

	moveq	#ip_ClrBRKPT,d0
	bsr.b	FindGRAddress
	bne.b	.Exit

	CallE	Disable
	bsr.b	GetVBR
	move.l	d7,a0
	jsr	(a4)
	move.l	d0,d7
	move.l	d1,d6

	Call	CacheClearU
	Call	Enable
	move.l	d7,d0
	move.l	d6,d1

.Exit	Pull	d2-a6
	rts

;---- Function for locating the VBR
;- Input:	a6 -	Execbase
;- Output:	a1 -	VBR
;----
GetVBR	Push	a5
	sub.l	a1,a1
	btst	#0,AttnFlags+1(a6)
	beq.b	.MC68000
	lea	.SVCode(pc),a5
	Call	Supervisor
.MC68000	Pull	a5
	rts

.SVCode	movec	vbr,a1
	rte

;****** ghostrider.library/grSetEntryQualifier ******************************
*
*   NAME
*	grSetEntryQualifier -- Set qualifier for hot start.
*
*   SYNOPSIS
*	error = grSetEntryQualifier( Type, Code, Qualifier )
*	D0                           D0,   D1,   D2
*
*	BYTE grSetEntryQualifier( ULONG, UBYTE, UWORD )
*
*   FUNCTION
*	This function will initialize a "hot starter", patched into the
*	input event stream, which will activate GhostRider if the specified
*	qualifiers occur.
*
*   INPUTS
*	Type -	Type of entry qualifier:
*		 - NULL		 : This will remove the handler.
*		 - GRETB_mbutton : The middle mouse button must be pressed
*				   for activation.
*		 - GRETB_rbutton : The right mouse button must be pressed
*				   for activation.
*		 - GRETB_lbutton : The left mouse button must be pressed
*				   for activation.
*	  ; The three mouse button flags function as a mask.
*	  ; [GRETF_rbutton!GRETF_lbutton] will invoke GhostRider if
*	  ; left AND right, but NOT the middle mouse button is pressed.
*	  ; These qualifiers may not be mixed with the RAWKEY qualifier.
*
*		 - GRETB_rawkey  : ie_Code and ie_Qualifier of a RAWKEY event
*				   must match the Code and Qualifier codes
*				   specified for activation.
*				   The CapsLock flag is ignored.
*	Code -	RAWKEY code for RAWKEY hot start.
*	Qualifier -  Qualifier settings for RAWKEY hot start.
*
*   RESULT
*	error -	Result of operation. Not used.
*
*   EXAMPLES
*	moveq	#%0001,d0		;Invoke with middle mouse button.
*	Call	grSetEntryQualifier
*
*	moveq	#%1000,d0		;Type = RAWKEY event
*	moveq	#$5F,d1			;Invoke with Ctrl+HELP
*	moveq	#$08,d2
*	Call	grSetEntryQualifier
*
*   NOTES
*	The RAWKEY codes may be found in various litterature. The qualifier
*	bits are described in the system includes (IEQUALIFIERB_XXXXXXXXX).
*
*   BUGS
*	Since a GhostRider entry by hot key would cause the system to miss
*	the key releases, I have included a highly illegal fix to this
*	problem in the GhostRider. This fix will find the keyboard.device
*	in the system's device list and clear the keyboard matrix at exit.
*	Since the base of keyboard.device is not public, I have had to do
*	some research myself. The problem is that the fix may not work on
*	all KICKSTART versions, but I have checked it to do on versions
*	37.12 - 40.xx. 
*	Oh, almost forgot; you can disable this fix in the preferences
*	(default is clearing the keyboard matrix)
*	
*
*   SEE ALSO
*	libraries/ghostrider.i
*
*****************************************************************************
*
*/


;---- Setup/Free entry patch
;- Input:	d0 -	EntryType / NULL
;-	d1 -	EntryCode
;-	d2 -	EntryQualifier
;----
GR_SetEntry	Push	d1-a6
	lea	B(pc),b

	tst.w	d0
	bne.b	.setuphandler
	bsr.w	FreeInputEvent
	moveq	#0,d0
	bra.b	.exit

.setuphandler	bsr.b	PatchInputEvent

.exit	Pull	d1-a6
	rts

;---- Call when first SetEntry is called. Further changes to EntryQualifier
PatchInputEvent	move.b	d0,EntryType(b)
	move.b	d1,EntryCode(b)
	move.w	d2,EntryQualifier(b)

	tst.b	InputEventPatched(b)
	bne.w	.deviceerror

	bsr.b	SetupDevice
	bne.b	.setuperror

	lea	DevIO(b),a1	;prepare DevIO
	move.b	#NT_MESSAGE,LN_TYPE(a1)
	lea	ReplyPort(b),a0
	move.l	a0,MN_REPLYPORT(a1)
	lea	IrqStruct(b),a0	;prepare IRQStruct
	move.l	a0,IO_DATA(a1)
	clr.l	IS_DATA(a0)
	move.l	#HandlerCode,IS_CODE(a0)
	move.b	#64,LN_PRI(a0)
	move.l	#GRLauncherName,LN_NAME(a0)
	move.w	#IND_ADDHANDLER,IO_COMMAND(a1)
	Call	DoIO	;And ADD handler

	bsr.b	FreeDevice

	st.b	InputEventPatched(b)
.setuperror
.deviceerror	rts

;---- Call to remove input-patch
FreeInputEvent	tst.b	InputEventPatched(b)
	beq.b	.notset

	bsr.b	SetupDevice
	bne.b	.setuperror

	lea	DevIO(b),a1	;Remove Handler
	lea	ReplyPort(b),a0
	move.l	a0,MN_REPLYPORT(a1)
	move.w	#IND_REMHANDLER,IO_COMMAND(a1)
	lea	IrqStruct(b),a0
	move.l	a0,IO_DATA(a1)
	Call	DoIO

	bsr.b	FreeDevice

	clr.b	InputEventPatched(b)
.setuperror
.notset	rts

;---- Prepare input.device for communication
SetupDevice	moveq	#0,d0	;open input-device
	moveq	#0,d1
	lea	InputName(pc),a0
	lea	DevIO(b),a1
	CallE	OpenDevice
	tst.l	d0
	bne.b	.deviceerror

	sub.l	a1,a1
	Call	FindTask
;	move.l	d0,ThisProcess(b)

	lea	ReplyPort(b),a1	;prepare Reply port
	move.b	#NT_MSGPORT,LN_TYPE(a1)
	move.b	#PA_SIGNAL,MP_FLAGS(a1)
;	move.l	ThisProcess(b),MP_SIGTASK(a1)
	move.l	d0,MP_SIGTASK(a1)
	lea	GRSetupPortName(pc),a0
	move.l	a0,LN_NAME(a1)
	st.b	LN_PRI(a1)	;pri=-1
	Call	AddPort	;and ADD it to the system

.deviceerror	rts

;---- Close down input.device
FreeDevice	lea	DevIO(b),a1	;Close device
	CallE	CloseDevice

	lea	ReplyPort(b),a1	;And remove port
	Call	RemPort
	rts

;---- InputEvent handler code
HandlerCode	Push	d1/d5-d7/a0/a5

	lea	B(pc),b

	moveq	#IECLASS_RAWKEY,d7
	moveq	#IECLASS_RAWMOUSE,d6

	move.b	EntryType(b),d5

HandlerLoop	move.b	ie_Class(a0),d0
	cmp.b	d7,d0
	bne.b	.NotKeyPress

	btst	#GRETB_rawkey,d5
	beq.b	.NextEvent

	move.b	ie_Code+1(a0),d0
	cmp.b	EntryCode(b),d0
	bne.b	.NextEvent

	move.w	ie_Qualifier(a0),d0
	and.w	#%11111011,d0	;CAPSLOCK is a don't care
	cmp.w	EntryQualifier(b),d0; compare with qualifier
	bne.b	.NextEvent

	move.w	#$0008,$dff09a
	moveq	#0,d0
	moveq	#0,d1
	bsr.w	GR_EnterGR
	move.w	#$8008,$dff09a

	clr.b	ie_Class(a0)	;kill event
	bra.b	.NextEvent

.NotKeyPress	cmp.b	d6,d0
	bne.b	.NextEvent

	move.b	ie_Qualifier(a0),d0
	lsr.b	#4,d0	;shift mousebutton bits
	and.b	#%111,d0
	cmp.b	d5,d0	;check correct pattern
	bne.b	.NextEvent
	moveq	#0,d0
	moveq	#0,d1
	bsr.w	GR_EnterGR

.NextEvent	move.l	(a0),a0	;process all events in the
	move.l	a0,d0	;list (until a0=0)
	bne.w	HandlerLoop

.OnlyOneEntry	Pull	d1/d5-d7/a0/a5
	move.l	a0,d0
	rts

B	OFFSET	0
ThisProcess	dc.l	0
InputEventPatched	dc.b	0
	dc.b	0
IrqStruct	dcb.b	IS_SIZE,0
DevIO	dcb.b	IOSTD_SIZE,0
ReplyPort	dcb.b	MP_SIZE,0

EntryQualifier	dc.w	0	;qualifier
EntryCode	dc.b	0	;key code if key entry
EntryType	dc.b	0	;type of entry (mouse/key/none)
	ENDOFF

InputName	dc.b	'input.device',0

GRIDName	dc.b	'GhostRider.Port',0
GRSetupPortName	dc.b	'Setup '
GRLauncherName	dc.b	'GhostRider Launcher',0
GRLibraryName	dc.b	'ghostrider.library',0
GRLibraryID	dc.b	'GhostRider.library '
	VERSTRING
	dc.b	$D,$A,0

LibraryEnd	;mark end of library for the rt_EndSkip endtry

	rsreset		;Define GRLibrary base
	rs.b	LIB_SIZE
gr_seglist	rs.l	1
gr_execbase	rs.l	1

GRLIB_POSSIZE	rs.b	0
