*************************************************************************
*									*
*	A program to swap file names					*
*                                                                       *
*	(C) Copyright 1992 by Tom Champion				*
*                                                                       *
*	Name - swap.asm							*
*                                                                       *
*************************************************************************

	incdir  sys:include/
	include exec/types.i
	include exec/exec_lib.i
	include libraries/dos_lib.i
	include libraries/dos.i
	include libraries/dosextens.i

	bra main

	opt	ow-, o+

* Data

DosBase			dc.l 0

WbMsg			dc.l 0
OldDir			dc.l 0
MyFileLock		dc.l 0
MyFileLock1		dc.l 0
FirstName		ds.b 128
FirstFile		ds.b 108
FirstLen		dc.l 0
SecondName		ds.b 128
SecondFile		ds.b 108
SecondLen		dc.l 0
Stay			dc.b 0

DosName			dc.b 'dos.library',0
	even

* Messages

	even
Invalid			dc.b 'argument line invalid or too long',10,0
InvalidLen		equ *-Invalid
	even
Missing			dc.b 'required argument missing',10,0
MissingLen		equ *-Missing
	even
NoFile			dc.b "Can't open ",0
NoFileLen		equ *-NoFile
	even
NoChangeFile		dc.b "Can't change ",0
NoChangeFileLen		equ *-NoChangeFile
	even
ObjectThere		dc.b 'Object already exists',10,0
ObjectThereLen		equ *-ObjectThere
	even
Return			dc.b 10
	even
TempFile		dc.b 'Temp_1',0
	even

* Macro to load a6 with the proper variable

Ready		MACRO
	IFC 	'\1','Dos'
		move.l DosBase,a6
	ENDC
	IFC	'\1','Exec'
		move.l	$4.w,a6
	ENDC
		ENDM

* Macro to call the function after you have set a6

Call		MACRO
		jsr	_LVO\1(a6)
		ENDM

	even

* Main program

main
	move.l	a0,a4				;Save commandline to a4
	move.l	d0,d4				;Save commandline length to d4

	Ready	Exec				;Ready Exec
	lea	DosName(pc),a1			;Load DosName
	moveq	#0,d0				;Any version
	Call	OpenLibrary			;Open Dos library
	move.l	d0,DosBase			;Save result in _DosBase
	beq	all_done			;If error then quit

	suba.l	a1,a1
	Call	FindTask
	movea.l	d0,a2
	tst.l	pr_CLI(a2)
	bne	Cli				;Jump if started from CLi or
						; continue if called from Workbench

	lea	pr_MsgPort(a2),a0
	Call	WaitPort
	lea	pr_MsgPort(a2),a0
	Call	GetMsg
	move.l	d0,WbMsg			;Save result in WbMsg
	bra	done				;Quit

Cli
	Ready	Dos				;Ready Dos
	Call	Output				;Get cli handle
	move.l	d0,d5				;Save result in d5

	move.b	#0,-1(a4,d4)			;Delete last character from CommandLine

	lea	FirstName(pc),a1
	bsr	ArgCopy				;Call ArgCopy
	move.l	d0,FirstLen			;Save string length in FirstLen
	beq	done				;If no result then quit

	lea	SecondName(pc),a1
	bsr	ArgCopy				;Call ArgCopy
	move.l	d0,SecondLen			;Save string length in SecondLen
	beq	done				;If no result then quit

	lea	FirstName(pc),a1
	move.l	a1,d1
	move.l	#SHARED_LOCK,d2			;Mode #SHARED_LOCK
	Call	Lock				;Call Lock
	move.l	d0,MyFileLock			;Save result in MyFileLock
	bne	.Loop				;If result then goto .Loop

	move.l	#0,d1				;Move 0 into d4
	bra	LockError			;Call LockError

.Loop
	move.l	MyFileLock,d1			;Move MyFileLock into d1
	Call	UnLock				;Call UnLock

	lea	FirstName(pc),a1
	lea	FirstFile(pc),a2
	move.l	FirstLen,d1
	bsr	SplitNames			;Call SplitNames

	lea	SecondName(pc),a1
	move.l	a1,d1
	move.l	#SHARED_LOCK,d2      		;Mode #SHARED_LOCK
	Call	Lock				;Call Lock
	move.l	d0,MyFileLock			;Save result in MyFileLock
	bne	.Loop1				;If result then goto .Loop1

	move.l	#1,d1				;Move 1 into d4
	bra	LockError			;Call LockError

.Loop1
	move.l	MyFileLock,d1			;Move MyFileLock into d1
	Call	UnLock				;Call UnLock

	lea	SecondName(pc),a1
	lea	SecondFile(pc),a2
	move.l	SecondLen,d1
	bsr	SplitNames			;Call SplitNames

	lea	FirstName(pc),a1		;Load a1 with First Directory
	lea	SecondName(pc),a2           	;Load a2 with Second Directory
.Loop2
	cmp.b	(a2)+,(a1)+			;Compare
	bne	.Exit
	tst.b	(a1)
	beq	.Lp
	bra	.Loop2
.Lp
	tst.b	(a2)
	beq	.Loop4				;If they are the same goto .Loop4
.Exit

	lea	FirstName(pc),a3
	lea	SecondFile(pc),a4
	bsr	IsThere                 	;See if there is a file named SecondName
						; in the First Directory
	beq	.Loop3				;If there is no file then goto .Loop3

	move.l	d5,d1
	lea	ObjectThere(pc),a2          	;Say Object is already there
	move.l	a2,d2
	move.l	#ObjectThereLen,d3
	Call	Write                   	;Output text
	bra	done				;Quit

.Loop3
	lea	SecondName(pc),a3
	lea	FirstFile(pc),a4
	bsr	IsThere				;See if there is a file named SecondName
						; in the First Directory
	beq	.Loop4				;If there is no file then goto .Loop4

	move.l	d5,d1
	lea	ObjectThere(pc),a2     		;Say Object is already there
	move.l	a2,d2
	move.l	#ObjectThereLen,d3
	Call	Write				;Output text
	bra	done				;Quit

.Loop4
	lea	FirstName(pc),a3
	lea	FirstFile(pc),a4
	lea	TempFile(pc),a5
	move.l	FirstLen,d1
	bsr	ChangeName			;Change First file to Temp name
	beq	done				;Error, done

	lea	SecondName(pc),a3
	lea	SecondFile(pc),a4
	lea	FirstFile(pc),a5
	move.l	SecondLen,d1
	bsr	ChangeName			;Change Second file to First name
	beq	.Error				;Error, .Error

	lea	FirstName(pc),a3
	lea	TempFile(pc),a4
	lea	SecondFile(pc),a5
	move.l	FirstLen,d1
	bsr	ChangeName			;Change First file to Second name
	bra	done

.Error						;If Error change temp file back to first
	lea	FirstName(pc),a3
	lea	TempFile(pc),a4
	lea	FirstFile(pc),a5
	move.l	FirstLen,d1
	bsr	ChangeName			;Change Temp file to First name

	bra	done				;Quit


*******************************************************
* ArgCopy - Copy argument line to variables
*
* Call with
* A1 = Destination String
* A4 = CommandLine
*
* Reurn with
* D0 = string length

ArgCopy
	clr.l	d0				;Clear d0
.Copy
	cmp.b   #'"',(a4)			;Compare a4 to "
	bne 	.Loop

	cmp.b	#1,Stay				;Compare Stay to 1
	beq	.1				;Yes, then .1

	cmp.b	#0,d0				;Compare d0 with 0
	bne	.Loop				;Yes, then .Loop
.1
	add.b	#1,Stay				;Add 1 to Stay
	addq	#1,a4				;Add 1 to a4
	bra	.Copy				;Go Back to .Copy
.Loop
	cmp.b	#1,Stay				;Compare Stay to 1
	beq     .Loop1				;Yes, then .Loop1
	cmp.b	#" ",(a4)			;Compare a4 to space
	bne     .Loop1				;No, then .Loop1
	addq	#1,a4				;Add 1 to a4
	bra	.End				;Goto .End
.Loop1
	tst.b	(a4)				;test a4
	beq	.End				;Yes, then .End
	move.b	(a4)+,(a1)+			;Copy a4 to a1
	addq	#1,d0				;Add 1 to d0
	bne	.Copy				;Goto .Copy
.End
	addq	#1,d0				;Add 1 to d0
	move.b	#0,(a1)				;Add 1 to a1

	cmp.b	#1,Stay                 	;Compare Stay to 1
	bgt	.Loop2				;Greater than, then .Loop2
	blt	.Loop2				;Less than, then .Loop2

	move.l	d5,d1                   	;Move Output handle into d1
	lea	Invalid(pc),a1			;Say Invalid Command Line
	move.l  a1,d2
	move.l	#InvalidLen,d3
	Call	Write				;Output text
	move.l	#0,d0				;Move 0 to d0

.Loop2
	cmp.b	#1,d0 				;Compare 1 to d0
	bne	.Loop3				;No, then .Loop3

	move.l	d5,d1
	lea     Missing(pc),a1			;Say Missing File Name
	move.l	a1,d2
	move.l	#MissingLen,d3
	Call	Write				;Output text
	move.l	#0,d0				;Move 0 to d0

.Loop3
	move.b	#0,Stay				;Move string length into d0
	rts					;Return


********************************************************
* SplitNames - Split the Dir name and the File name
* 	       if no Dir name then Dir name is blank
*
* Call with
* a1 = Destination String returned from ArgCopy
* a2 = Destination File name String
* d1 = String Length return from ArgCopy

SplitNames
	add.l	d1,a1				;Add d1 to a1
.Copy
	cmp.b	#-1,d1				;Compare d1 to -1
	beq	.End				;Yes, then .End
	cmp.b	#'/',(a1)               	;Compare a1 to /
	beq	.End				;Yes, then .End
	cmp.b	#':',(a1)			;Compare a1 to :
	beq	.End				;Yes, then .End
	subq	#1,a1				;Subtract 1 from a1
	subq	#1,d1				;Subtract 1 from d1
	bra	.Copy				;Goto .Copy
.End
	addq	#1,a1				;Add 1 to a1
.Loop
	tst.b	(a1)				;Test a1
	beq	.Exit				;Yes, then .Exit
	move.b	(a1)+,(a2)+			;Copy a1 to a2
	move.b	#0,-1(a1)			;Move Null into a1
	bra	.Loop				;Goto .Loop
.Exit
	rts					;Return


********************************************************
* LockErrror - Print Error if no Lock
*
* Call with
* d1 = Error Number

LockError
	move.l  d1,d4                   	;Move Error Number to d4

	move.l	d5,d1				;Move Cli handle to d1
	lea	NoFile(pc),a2
	move.l	a2,d2              		;Say No File
	move.l	#NoFileLen,d3
	Call	Write				;Output text

	cmp.b	#1,d4                   	;Compare Error Number to 1
	beq	.Loop				;Yes, then .Loop

	move.l	d5,d1                   	;Move Cli handle to d1
	lea	FirstName(pc),a2
	move.l	a2,d2				;Say First name
	move.l	FirstLen,d3
	Call	Write				;Output text

	move.l	d5,d1				;Move Cli handle to d1
	lea	Return(pc),a2
	move.l	a2,d2				;Say Newline
	move.l	#1,d3
	Call	Write				;Ouput text

	bra	done				;Quit

.Loop
	move.l	d5,d1				;Move Cli handle to d1
	lea	SecondName(pc),a2
	move.l	a2,d2				;Say Second name
	move.l	SecondLen,d3
	Call	Write				;Ouput text

	move.l	d5,d1				;Move Cli handle to d1
	lea	Return(pc),a2
	move.l	a2,d2				;Say NewLine
	move.l	#1,d3
	Call	Write				;Output text

	bra	done				;Quit


********************************************************
* ChangeName - Change current dir and rename file
*
* Call with
* a3 = Directory name
* a4 = Source name
* a5 = Destination name
* d1 = Source name length
*
* Return with
* d0 = 0 Error, 1 Success

ChangeName
	tst.b 	(a3)				;Test a3
	beq	.Loop				;No, then .Loop

	move.l	d1,d4				;Move length to d4
	
	move.l	a3,d1
	move.l	#SHARED_LOCK,d2         	;Mode #SHARED_LOCK
	Call	Lock				;Lock Directory
	move.l	d0,MyFileLock			;Move result to MyFileLock

	move.l	d0,d1
	Call	CurrentDir  			;Make Directory Current
	move.l	d0,OldDir			;Move Old Dir to OldDir

.Loop
	move.l	a4,d1
	move.l	a5,d2
	Call	Rename                  	;Rename Source
	move.l	d0,d6
	bne	.Exit

	move.l	d5,d1				;Move Cli handle to d1
	lea	NoChangeFile(pc),a2		
	move.l	a2,d2				;Say Can't change file
	move.l	#NoChangeFileLen,d3
	Call	Write				;Output text
	
	move.l	d5,d1				;Move Cli handle to d1
	move.l	a4,d2				;Move Source name to d2
	move.l	d4,d3
	Call	Write				;Output text
	
	move.l	d5,d1				;Move Cli handle to d1
	lea	Return(pc),a2
	move.l	a2,d2				;Say Newline	
	move.l	#1,d3
	Call	Write				;Output text
	
.NoError
	tst.b	(a3)				;Test a3
	beq	.Exit				;No, then .Exit

	move.l	OldDir,d1
	Call	CurrentDir			;Make OldDir Current

	move.l	MyFileLock,d1
	Call	UnLock                  	;UnLock Directory

.Exit	
	tst.l	d6				;Test Rename Return
	bne	.Ne				;No Error
	
	move.l	#0,d0				;Error, Return 0
	rts					;Return
.Ne	
	move.l	#1,d0				;NoError, Return 1
	rts					;Return

	
********************************************************
* IsThere - See if the file name is already there
*
* Call with
* a3 = Directory name
* a4 = File name
*
* Return with
* d0 = File Lock

IsThere
	tst.b 	(a3)				;Test a3
	beq	.Loop                   	;No, then .Loop

	move.l	a3,d1
	move.l	#SHARED_LOCK,d2         	;Mode #SHARED_LOCK
	Call	Lock				;Lock Directory
	move.l	d0,MyFileLock			;Move d0 to MyFileLock

	move.l	d0,d1
	Call	CurrentDir			;Make Directory Current
	move.l	d0,OldDir			;Move Old Dir to OldDir

.Loop
	move.l	a4,d1
	move.l	#SHARED_LOCK,d2         	;Mode #SHARED_LOCK
	Call	Lock				;Lock File
	move.l	d0,MyFileLock1          	;Move d0 to MyFileLock1
	move.l	d0,d3
	beq	.Loop1				;No, then .Loop1

	move.l	MyFileLock1,d1
	Call	UnLock                  	;UnLock File

.Loop1
	tst.b	(a3)				;Test a3
	beq	.Exit                   	;No, then .Exit

	move.l	OldDir,d1
	Call	CurrentDir			;Make OldDir Current

	move.l	MyFileLock,d1
	Call	UnLock                  	;UnLock Directory

.Exit
	move.l	d3,d0
	rts                             	;Return


* End

done
	Ready	Exec
	move.l	DosBase,a1
	Call	CloseLibrary			;Close Dos library

	tst.l	WbMsg   			;Test WbMsg
	beq		all_done                ;No, then all_done

	Call	Forbid

	move.l	WbMsg(pc),a1
	Call	ReplyMsg			;Return WbMsg to Workbench

all_done
	clr.l	d0				;Clear d0
	rts

	END
