*****************************************************************************
*	             Auto - Runback startup routines			    *
*               -----------------------------------------		    *
*									    *
*         For Inclusion on ACC disk magazine (by Trevor Mensah)		    *
*     -----------------------------------------------------------	    *
*									    *
* These routines can be used as a direct replacement for the STANDARD	    *
* WB startup routines which are normally called upon. These routines	    *
* still cater for WB Startup but when you start the program from the	    *
* CLI or SHELL enviroments the program will "RUNBACK".  The routines	    *
* create a new task using the dos library command  "CreateProc"		    *
*									    *
* Just change the name of the task. Once the new program has been	    *
* started,look using the utility XOPER ( Included on ACC club disk 12b)	    *
* and you will see that a new task will of been created using the name	    *
* which you specifed.							    *
*									    *
*****************************************************************************

	section		AlternativeWBStartup,code

	INCDIR	 	"SYS:INCLUDE/"
	;INCLUDE 	Graphics/graphics_lib.i
	;INCLUDE 	Intuition/Intuition.i
	INCLUDE 	Intuition/Intuition_lib.i
 	INCLUDE 	Exec/Exec_lib.i
	INCLUDE		Libraries/Dosextens.i
	INCLUDE		Misc/arpbase.i
		
NULL		EQU	0
ExecBase	EQU	4
;*****************************************

CALLSYS    MACRO
	IFGT	NARG-1         
	FAIL	!!!           
	ENDC                 
	JSR	_LVO\1(A6)
	ENDM
		
;*****************************************

FindTask
	sub.l		a1,a1			;clear a1
	CALLEXEC	FindTask		;find task - us
	move.l		d0,a4			;process in a4

	tst.l		pr_CLI(a4)		;test if from CLI
	beq.s		FromWorkbench		;branch if from workbench
	
	bra.s		Create_Process		;and run the user prog

 
FromWorkbench
	lea		pr_MsgPort(a4),a0	;tasks message port in a0
	CALLSYS		WaitPort		;wait for workbench message

	lea		pr_MsgPort(a4),a0	;tasks message port in a0
	CALLSYS		GetMsg			;get workbench message

	move.l		d0,-(sp)		;save ReplyMsg to stack
	bsr.s		Create_Process
	move.l		(sp)+,a4		;restore ReplyMsg

	CALLEXEC	Forbid			;forbid multitasking
	move.l		a4,a1			;get workbench message
	CALLSYS		ReplyMsg		;reply workbench message
	rts	
 
******************************
 
Create_Process
	lea		FindTask(pc),a1		;ptr to beginning of code
	move.l		-4(a1),Segment		;find segment 
	clr.l		-4(a1)			;

	move.l		(ExecBase).w,a6		;get execbase
	lea		378(a6),a0		;list 
	lea		DosName,a1		;name
	CALLSYS		FindName		;find name

	move.l		d0,-(sp)		;save dosbase to stack
	CALLSYS		Forbid			;Forbid	 () Multitasking

	move.l		#TaskName,d1		;tasks name
	moveq.l		#0,d2			;priority 0
	move.l		#FreeSegment,d3		;seglist
	subq.l		#4,d3			; 
	lsr.l		#2,d3			;calc
	move.l		#3500,d4		;stack size

	move.l		(sp)+,a6		;restore dosbase to a6
	CALLSYS		CreateProc		;Create new Task process

	CALLEXEC	Permit			;Permit () Multitasking

ExitToDos
	moveq.l		#0,d0			;No CLI return code
	rts

;------ startup of new task (note: needs seperate hunk for unloaing segment)

	section		CreatingAtask,code

FreeSegment
	bsr.s		end_startup

	move.l		(ExecBase).w,a6		;get execbase
	lea		378(a6),a0		;list
	lea		DosName,a1		;doslibrary name
	CALLSYS		FindName		;FindName
	move.l		d0,a6			;dosbase in a6

	move.l		Segment,d1		;segment to free
	CALLSYS		UnLoadSeg		;free segment
	rts	
	even 

;--------- constants used by routines

Segment
	dc.l		0
	even
TaskName
	dc.b		'OurTask',0	;name of our new task
	even
DosName
	dc.b		'dos.library',0	;dos library name
	even


end_startup

;--------- your program should start here ( eg. opening libs,etc )

	moveq.l		#0,d0			;no CLI exit code
	rts


