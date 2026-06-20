************************************************************************
*
*	A simple patch to allow Scribble Platinum to work
*		on KickStart V2.04 machines.
*
*	Problem  is  that   Scribble  tries   to  open  a  screen 
*	of  1008 * 1024. This  routine  SetFunctions   OpenScreen
*	so that we can alter these values. With  some alterations
*	we could force Scribble to use the new productivity modes
*	available with the ECS Denise, or use public screens etc.
*
*		By Steve Marshall (3/6/92) 1:04 a.m.
*
*	Written for Mark Meany 'cos he's miffed that Scribble
*	didn't work on his shiny new A500 + ;-)
*	Pity it's now a discontinued machine. :-(
*	The A600 sucks. What do you think ?
*
************************************************************************

	include		dos/dostags.i

;	Screen Dimentions for Scribble screen

Width	equ	650	;a little wider - should be 640 - slight overscan
Height	equ	266	;should be 256 - same applies

;*****************************************

TRUE	equ	-1	;just because
FALSE	equ	0

;*****************************************

CALLSYS    MACRO
	IFGT	NARG-1         
	FAIL	!!!           
	ENDC                 
	JSR	_LVO\1(A6)
	ENDM
		
;*****************************************

_start
	sub.l		a1,a1			;clear a1
	CALLEXEC	FindTask		;find task - us
	move.l		d0,a4			;process in a4

	tst.l		pr_CLI(a4)		;test if from CLI
	beq.s		FromWorkbench		;branch if from workbench
	
Create_Process
	moveq		#36,d0			;lib version 2.##
	lea		DosName,a1		;name
	CALLSYS		OpenLibrary		;open DOS
	move.l		d0,d5			;save dosbase
	beq.s		exit			;branch if no DOS

	CALLSYS		Forbid			;Forbid() Multitasking

	lea		ProcTags(pc),a0		;address of taglist 
	lea		_start-4(pc),a3		;ptr to beginning of code
	move.l		(a3),4(a0)		;place in taglist			
	move.l		a0,d1			;address of taglist 
	move.l		d5,a6			;restore dosbase to a6
	CALLSYS		CreateNewProc		;Create new Task process
	tst.l		d0			;test result
	beq.s		noproc			;branch if no process
	
	clr.l		(a3)			;detatch next section from seglist

noproc
	CALLEXEC	Permit			;Permit() Multitasking
	
	move.l		d5,a1			;dosbase
	CALLSYS		CloseLibrary		;close DOS

exit
	moveq		#0,d0			;No CLI return code
	rts


 
FromWorkbench
	lea		pr_MsgPort(a4),a0	;tasks message port in a0
	CALLSYS		WaitPort		;wait for workbench message

	lea		pr_MsgPort(a4),a0	;tasks message port in a0
	CALLSYS		GetMsg			;get workbench message

	move.l		d0,-(sp)		;save ReplyMsg to stack
	bsr.s		Create_Process		;start process
	
	CALLSYS		Forbid			;forbid multitasking
	move.l		(sp)+,a1		;get workbench message
	CALLSYS		ReplyMsg		;reply workbench message
	rts	

ProcTags
	dc.l		NP_Seglist		;type seglist (not code)
	dc.l		0			;pointer initialised at run time
	dc.l		NP_StackSize		;stacksize 3000
	dc.l		3000			;enough for this prog
	dc.l		NP_Cli			;create a cli structure
	dc.l		TRUE			;so we can find proc
	dc.l		NP_FreeSeglist		;this should be default
	dc.l		TRUE			;but doesn't seem to work
	dc.l		TAG_DONE		;end of taglist

DosName
	DOSNAME
	
****************************************************************************
 
;------ startup of new task (note: needs seperate hunk for unloaing segment)

	section		Createdtask,CODE

_main
	moveq		#36,d0			;lib version 2.##
	lea		DosName2,a1		;name
	CALLEXEC	OpenLibrary		;open DOS
	move.l		d0,d6			;save dosbase
	beq.s		Quit			;branch if no DOS
	
	move.l		#ProgName,d1		;program name
	move.l		d6,a6			;dosbase
	CALLSYS		SetProgramName		;set name

	moveq		#0,d0			;lib version
	lea		Libname(pc),a1		;int lib name
	CALLEXEC	OpenLibrary		;open it
	move.l		d0,d7			;save base
	beq.s		Quit2			;quit if not 2.00 +
	
	move.l		d0,a1			;base in a1		
	move.w		#_LVOOpenScreen,a0	;lib offset to change
	move.l		#ScreenFunc,d0		;new function address
	CALLSYS		SetFunction		;change it
	move.l		d0,OldScreen		;save old OpenScreen

	move.l		#$1000,d0		;control C mask (SIGBREAKF_CTRL_C)
;------ wait for ctrl c 
	CALLSYS		Wait			;wait - probably forever		

	move.l		d7,a1			;intuitionbase
	move.w		#_LVOOpenScreen,a0	;lib offset
	move.l		OldScreen(pc),d0	;add of original OpenScreen
	CALLSYS		SetFunction		;restore it

	move.l		d7,a1			;intuitionbase
	CALLSYS		CloseLibrary		;close intuition

Quit2	
	move.l		d6,a1			;dosbase
	CALLSYS		CloseLibrary		;close dos
	
Quit
	rts

************************************************************************
ScreenFunc
	move.l		20(a0),a1		;get name add
	cmpi.l		#'Plat',(a1)		;perform crude check
	bne.s		endfunc			;and branch if not scribble

	move.w		#Width,4(a0)		;set width
	move.w		#Height,6(a0)		;and height

endfunc
	move.l		OldScreen(pc),a1	;get openscreen add
	jmp		(a1)			;and jump to it

************************************************************************

OldScreen
	dc.l		0			;pointer for OpenScreen
	
DosName2
	DOSNAME					;dos lib name
	
Libname
	INTNAME					;intuition name
	
ProgName
	dc.b		'ScribPatch',0