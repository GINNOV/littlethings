***********************************************************************
*
*   Assembler Program Startup/Exit (Combo Version: CLI and WorkBench)
*
*  !! This startup code is not intended to be used with C programs !!
*  Modified version of mystartup.i for use with default tool programs
*
*		version 1.30 by S. Marshall  5/2/90
*                        for Newsflash UK
*
*	Note! do NOT use macros CALLDOS,CALLINT,CALLGRAF & CALLICON
*           instead use macro  -   CALL      libname,routine ie
*                       CALL         DOS,Open
*
*	       Use CALLSYS where you can to save memory 
*
************************************************************************

******* Included Files *************************************************

	INCDIR	"SYS:Include/"
	INCLUDE	"exec/exec_lib.i"
	INCLUDE	"exec/types.i"
	INCLUDE "exec/alerts.i"
	INCLUDE "exec/nodes.i"
	INCLUDE "exec/lists.i"
	INCLUDE "exec/ports.i"
	INCLUDE "exec/memory.i"
	INCLUDE "exec/libraries.i"
	INCLUDE "exec/tasks.i"
	INCLUDE "libraries/dos.i"
	INCLUDE "libraries/dos_lib.i"
	INCLUDE "libraries/dosextens.i"
	INCLUDE	"graphics/graphics_lib.i"
	INCLUDE "intuition/intuition_lib.i"
	INCLUDE "workbench/startup.i"
	INCLUDE "workbench/icon_lib.i"

******* Macros *********************************************************

CALLSYS    MACRO
      CALLLIB _LVO\1
      ENDM

ARG        MACRO
      move.l	\1*4+argvArray(a5),\2
      ENDM

CALL       MACRO
      IFC	'\1','DOS'
      move.l	(a5),a6
      ELSEIF
      move.l	_\1Base(a5),a6
      ENDC
      CALLSYS	\2
      ENDM
      
CLEAR      MACRO
      moveq	#0,\1
      ENDM
            
************************************************************************
*
*	Standard Program Entry Point
*
************************************************************************

startup:	
		move.l	sp,d5
		movem	d0/a0-a4,-(sp)
		move.l	d0,d7			
		move.l	a0,d6
		
	;------ get the address of our task
		suba.l	a1,a1
		CALLEXEC	FindTask
		move.l	d0,a4	
			
		move.l	#Buffer_SIZEOF,d0
		move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
		CALLSYS	AllocMem
		tst.l	d0
		bne.s	.MemOK
		
	;------ are we running as a son of Workbench?
		tst.l	pr_CLI(A4)
		beq.s	.WBError
		moveq.l	#103,d0
		rts	
.WBError
		bsr	waitmsg
		move.l	d0,d7
		move.l	#103,-(sp)
		bra	WBMemErr
		
.MemOK:		movea.l	d0,a5
		move.l	d5,initialSP(a5)	; initial task stack pointer
	
	;------ are we running as a son of Workbench?
		tst.l	pr_CLI(A4)
		beq	fromWorkbench

;=======================================================================
;====== CLI Startup Code ===============================================
;=======================================================================
fromCLI:
	;------	attempt to open DOS library:
		bsr	openLibs

	;------ find command name:
		movea.l	pr_CLI(a4),a0
		add.l   a0,a0			; bcpl pointer conversion
		add.l   a0,a0
		movea.l	cli_CommandName(a0),a0
		add.l   a0,a0			; bcpl pointer conversion
		add.l   a0,a0

	;------ create buffer and array:
		lea	argvBuffer(a5),a1
		lea	argvArray(a5),a2
		moveq.l	#1,d2			; param counter

	;------ fetch command name:
		moveq.l	#0,d0
		move.b	(a0)+,d0		; size of command name
		move.l	a1,(a2)+		; ptr to command name
		bra.s	1$
2$:		move.b	(a0)+,(a1)+
1$:		dbf	d0,2$
		clr.b	(a1)+
		
	;------	collect parameters:
		move.l	d7,d0
		moveq	#0,d1			; param counter
		moveq	#1,d2			
		movea.l	d6,a0

	;------ fetch command args.This has been altered to allow
	;------ spaces to be included within args if between quotes
	;------ both single and doubles may be used.
Clrloop:	subq	#1,d0
		bmi.s	parmexit
		cmpi.b	#$20,(a0)+
		ble.s	Clrloop
		
	;------ check for quote (single)
		subq.l	#1,a0
		cmpi.b	#"'",(a0)
		beq.s	DoQuote
		
	;------ check for quote (double)
		cmpi.b	#'"',(a0)
		beq.s	DoQuote
		
	;------ parse unquoted arg
		move.l	a1,(a2)+
.loop		subq	#1,d0
		move.b	(a0)+,(a1)+
		cmpi.b	#$20,(a0)
		bgt.s	.loop
		bra.s	argend
		
	;------ parse arg enclosed in quotes
DoQuote:	move.b	(a0)+,d1
		subq	#1,d0
		move.l	a1,(a2)+
.loop		subq	#1,d0
		bmi.s	argend
		move.b	(a0)+,(a1)+
		cmp.b	(a0),d1
		bne.s	.loop
		
	;------ bump address,add 0 to end of arg,bump arg count
argend:		addq	#1,a0
		clr.b	(a1)+
		addq	#1,d2
		bra.s	Clrloop
		
	;------ save arg count and restore regs
parmexit:	move.l	d2,argc(a5)

*
*  The above code relies on the end of line containing a control
*  character of any type, i.e. a valid character must not be the
*  last.  This fact is ensured by DOS.
*

	;------ get standard input handle:
		movea.l	(a5),a6			; DOSBase in a6
		CALLSYS		Input
		move.l	d0,_stdin(a5)

	;------ get standard output handle:
		CALLSYS		Output
		move.l	d0,_stdout(a5)
		
		movem	(sp)+,d0/a0-a4		; restore regs
		move.l	a5,-(sp)
		
	;------ call C main entry point
		jsr	_main

		movea.l	(sp)+,a5
		move.l	initialSP(a5),sp	; restore stack ptr
		bsr	Cleanup
		
	;------ return success code:
		moveq.l	#0,D0
		rts

;=======================================================================
;====== Workbench Startup Code =========================================
;=======================================================================
fromWorkbench:
	;------ we are now set up.  wait for a message from our starter
		bsr	waitmsg

	;------ save the message so we can return it later
		move.l	d0,_WBenchMsg(a5)
		movea.l	d0,a2
	
	;------	attempt to open DOS library:
		bsr	openLibs
	
		move.l	sm_NumArgs(a2),d1
		cmpi.l	#2,d1
		blt	_exit
		move.l	d1,argc(a5)
		move.l	sm_ArgList(a2),d0
		beq.s	docons
		lea	argvArray(a5),a0
		movea.l	d0,a2
WBArgloop:	move.l	wa_Name(a2),(a0)+
		addq.l	#8,a2
		dbra	d1,WBArgloop

	;------ and set the current directory to the same directory
		movea.l	_DOSBase(a5),a6
		movea.l	d0,a0
		move.l	8(a0),d1
		CALLSYS	CurrentDir

docons:		bsr	openIcon
		movea.l	d0,a6
		movea.l	argvArray+4(a5),a0
		CALLSYS	GetDiskObject
		move.l	d0,d5
		beq	_exit
		movea.l	d0,a0
		movea.l	$36(a0),a0
		lea	Wdw(pc),a1
		CALLSYS FindToolType
		move.l	d0,d1
		beq.s	FreeDskObj

	;------ open up the file
openWdw:	move.l	#MODE_OLDFILE,d2
		movea.l	_DOSBase(a5),a6
		CALLSYS	Open

	;------ set the C input and output descriptors
		move.l	d0,_stdin(a5)
		move.l	d0,_stdout(a5)
		move.l	d0,_MyCON(a5)
		beq.s	FreeDskObj

	;------ set the console task (so Open( "*", mode ) will work
	;	waitmsg has left the task pointer in A4 for us
		lsl.l	#2,d0
		movea.l	d0,a0
		move.l	fh_Type(a0),pr_ConsoleTask(A4)
		
FreeDskObj:	movea.l	d5,a0
		movea.l	_IconBase(a5),a6
		CALLSYS	FreeDiskObject
		
		
domain:		movem	(sp)+,d0/a0-a4
		move.l	a5,-(sp)
		movea.l	_DOSBase(a5),a6
		jsr	_main
		moveq.l	#0,d0			;Successful return code
		movea.l	(sp)+,a5

************************************************************************
*
*	C Program Exit Function
*
************************************************************************
*
*  Warning: this function really needs to do more than this.
*  This version requires that a5 is restored to it's original
*  value before _exit is called.D0 should contain error code.
*
************************************************************************

_exit:		
		move.l  initialSP(a5),SP	; restore stack pointer
		move.l	d0,-(SP)		; save return code
	
	;------ if we opened a window,close it
		
		move.l	_MyCON(a5),d1
		beq.s	NoWindow
		movea.l	_DOSBase(a5),a6
		CALLSYS	Close
		
	;----- if we ran from Cli,skip workbench cleanup
NoWindow:	
		move.l	_WBenchMsg(a5),d7
		bsr.s	Cleanup
		tst.l	d7
		beq.s	exitToDOS

	;------ return the startup message to our parent
	;	we forbid so workbench can't UnLoadSeg() us
	;	before we are done:
		
		
WBMemErr:	CALLSYS Forbid
		movea.l	d7,a1
		CALLSYS	ReplyMsg
		
exitToDOS:
		move.l	(SP)+,d0		;error message in d0
		
	;------ this rts sends us back to DOS:
		rts


;-----------------------------------------------------------------------
;Routine to print text,a0 = address of text,text terminated with a 0
;a5 = system varible block (that is initial contents of a5 on the 
;jump to subroutine _main) 
;	Print(textpointer,System variable block)
;	         a0		    a5

Print:
	movem.l		d2-d3/a6,-(sp)		;save modified regs
	move.l		_stdout(a5),d1		;get std output handle
	beq.s		.noOutput		;no output - then quit
	move.l		a0,d2			;address of text in d2
	moveq		#-1,d3			;initialise d3 to for loop

	;------ Count the number of chars
.Count
	tst.b		(a0)+			;check for end of text
	dbeq		d3,.Count		;decrement d3 and loop
	neg.l		d3			;make d3 positive
	subq.l		#1,d3			;count -1 (forget the 0)
	movea.l		(a5),a6			;DOS lib base in a6
	CALLSYS		Write			;write message
.noOutput:
	movem.l		(sp)+,d2-d3/a6		;restore regs
	rts	

;-----------------------------------------------------------------------
	
	;------ create a recoverable alert to signal no DOS lib
	;	    (as we can't print one to the console)
	;	Note! with current OS (1.2 & 1.3) this will turn
	;	into a dead end alert on expanded Amigas unless 
	;	you have run SetPatch.Something really bad must
	;	have happened if this gets called though.
			
noDOS:
		ALERT	(AG_OpenLib!AO_DOSLib)
		bra.s	AlertEnd
		
	;------ Print Icon library error message
		
noIcon:		lea	IconMsg(pc),a0
		bsr.s	Print
		bra.s	AlertEnd
	
	;------ Print Graphics library error message
		
noGraf:		lea	GrafMsg(pc),a0
		bsr.s	Print
		bra.s	AlertEnd
	
	;------ Print Intuition library error message
		
noInt:		lea	IntMsg(pc),a0
		bsr.s	Print
		
AlertEnd:	moveq.l	#100,d0
		bra	_exit
		
;-----------------------------------------------------------------------
Cleanup:
	;------ close Icon library if it was open
		movea.l	4.w,a6
		move.l	_IconBase(a5),d0
		beq.s	.NotIcon
		movea.l	d0,a1
		CALLSYS	CloseLibrary
.NotIcon
	;------ close DOS library if it was open
		move.l	_DOSBase(a5),d0
		beq.s	.NotDOS
		movea.l	d0,a1
		CALLSYS	CloseLibrary
.NotDOS		
	;------ close Graphics library if it was open
		move.l	_GfxBase(a5),d0
		beq.s	.NotGraf
		movea.l	d0,a1
		CALLSYS	CloseLibrary
.NotGraf
	;------ close Intuition library if it was open
		move.l	_IntuitionBase(a5),d0
		beq.s	FreeMemblk
		movea.l	d0,a1
		CALLSYS	CloseLibrary
FreeMemblk:
	;------ free memory used by startup routine
		movea.l	a5,a1
		move.l	#Buffer_SIZEOF,d0
		CALLSYS	FreeMem
		rts
		
;-----------------------------------------------------------------------
;  Open the Libraries:

	IFND	Libversion
Libversion EQU 0
	ENDC

openLibs:	lea	DOSName(pc),A1
		moveq	#Libversion,d0
		CALLSYS OpenLibrary
		move.l	D0,_DOSBase(a5)
		beq	noDOS
		
		lea	GrafName(pc),A1
		moveq	#Libversion,d0
		CALLSYS	OpenLibrary
		move.l	D0,_GfxBase(a5)
		beq.s	noGraf
		
		lea	IntName(pc),A1
		moveq	#Libversion,d0
		CALLSYS	OpenLibrary
		move.l	D0,_IntuitionBase(a5)
		beq.s	noInt
		rts
		
;-----------------------------------------------------------------------
;  Open the Icon library:

openIcon	lea	IconName(pc),a1
		moveq.l	#LIBRARY_VERSION,d0
		CALLEXEC OpenLibrary
		move.l	d0,_IconBase(a5)
		beq	noIcon
		rts
		
;-----------------------------------------------------------------------
; This routine gets the message that workbench will send to us
; called with task id in A4

waitmsg:
		lea	pr_MsgPort(A4),a0  	* our process base
		CALLSYS	WaitPort
		lea	pr_MsgPort(A4),a0  	* our process base
		CALLSYS GetMsg
		rts



;-----------------------------------------------------------------------
; Simple routine to parse ascii decimal string to binary
; On entry a0 points to string,result returned in d0
; routine terminates on first non numerical character 

Asctobin:	moveq		#0,d0
chrloop:	cmpi.b		#'9',(a0)
		bhi.s		.error
		cmpi.b		#'0',(a0)
		blt.s		.error
		add.l		d0,d0
		move.l		d0,d1
		lsl.l		#2,d0
		add.l		d1,d0
		move.b		(a0)+,d1
		andi.l		#$0f,d1
		add.l		d1,d0
		bra.s		chrloop
.error		rts

;-----------------------------------------------------------------------
; System Variable Block
; create offsets to access memory block
; use offset(a5) - ie movea.l	DOSBase(a5),a6

		rsreset
	;------ DOS library base (initialised)
_DOSBase	rs.l	1

	;------ Icon library base (only initialise if run from WB)
_IconBase	rs.l	1

	;------ Intuition library base
_IntuitionBase	rs.l	1

	;------ Graphics library base
_GfxBase	rs.l	1

	;------ std input and output handles (initialised)
_stdin		rs.l	1
_stdout		rs.l	1
_MyCON		rs.l	1

	;------ initial stack pointer and workbench message
initialSP	rs.l	1
_WBenchMsg	rs.l	1

	;------ command line argument and workbench message info
argc		rs.l	1
argvArray	rs.l	32
argvBuffer	rs.b	256


	;------ extra space for programmers use
	IFD	StartMem
temp		rs.b	StartMem
	ENDC
	
Buffer_SIZEOF	rs.b	0

;-----------------------------------------------------------------------
; initialised data

	;------ Graphics library error message	

GrafMsg		dc.b	'Cannot open Graphics library',$0a,0
		
		EVEN

	;------ Intuition library error message	

IntMsg		dc.b	'Cannot open Intuition library',$0a,0
		
		EVEN	
	
	;------ Icon library error message	

IconMsg		dc.b	'Cannot open Icon library',$0a,0
		
		EVEN

	;------ string for FindToolType to search for

Wdw		dc.b	"WINDOW",0
		EVEN
	
	;------ DOS library name
	
DOSName		DOSNAME

	;------ Icon library name
	
IconName	ICONNAME

	;------ Graphics library name
	
GrafName	GRAFNAME

	;------ Intuition library name
	
IntName		INTNAME

		EVEN

******************************************************************
	SECTION	 Main,CODE
******************************************************************

	;------ program main entry point
_main:
