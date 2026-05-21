*************************************************************************
*									*
*     Macintosh to AmigaDOS file conversion utility.			*
*									*
*	Copyright (c) 1988 Central Coast Software			*
*	    268 Bowie Dr, Los Osos, CA 93402				*
*	     All rights reserved, worldwide				*
*									*
*************************************************************************

	INCLUDE	"I/MACMAC.ASM"

* This program was created to perform a fast quality control check on the
* Mac-2-Dos interface using a special test jig.  Created on June 27, 1989.

* HARDWARE REGISTER DEFINITIONS

DSKPTR	EQU	$DFF020
DSKLEN	EQU	$DFF024
DSKBYTR	EQU	$DFF01A
DSKSYNC	EQU	$DFF07E
CIAA	EQU	$BFE001
CIAB	EQU	$BFD100
INTENAR	EQU	$DFF01C
INTENA	EQU	$DFF09A
INTREQ	EQU	$DFF09C
INTREQR	EQU	$DFF01E
ADKCON	EQU	$DFF09E
ADKCONR	EQU	$DFF010
VHPOSR	EQU	$DFF006

TR_ADDREQUEST	EQU	9	;TIMER IO REQUEST

CA0		EQU	$01
CA1		EQU	$02
CA2		EQU	$04
SEL		EQU	$80
Sel1		EQU	$10	;working as DF1
Sel3		EQU	$40	;use Sel3 to test RdData/WrtData

* Test jig interface uses Sel2 and Sel3 to control 2 74153 1-of-4
* data selectors: 
*	SIGNAL	       Sel2    Sel3   AMY INPUT
*	CA0		0	0	CHNG
*	CA1		0	1	CHNG
*	CA2		1	0	CHNG
*	LSTRB		1	1	CHNG
*	MTR SPEED	0	0	TRK0
*	SEL		0	1	TRK0
*	+12		1	0	TRK0
*	DrvEnable	1	1	TRK0

OutMsg	MACRO	;MSG, no CRLF FLAG
	LEA	\1,A0
	BSR	DISP..
	IFEQ	NARG-1
	BSR	CRLF..
	ENDC
	ENDM

GO:
	MOVE.L  A7,initialSP		;initial task stack pointer
	MOVEA.L 4,A6
	MOVE.L  A6,SysBase
	LEA     DosName,A1
	ZAP	D0
	CALLSYS	OpenLibrary		;OPEN DOS LIBRARY
	MOVE.L  D0,DosBase
	ZAPA	A1
	CALLSYS	FindTask
	MOVE.L	D0,TaskPtr		;save ptr for msg ports
	MOVEA.L D0,A4

	LEA	DISK_NAME,A1		;SET UP POINTER TO DISK RESOURCE
	CALLSYS	OpenResource
	MOVE.L  D0,DRBase		;POINTER TO DISK RESOURCE BLOCK
	BEQ	Exit			;DIDN'T FIND IT
	CALLSYS	Input,DosBase
	MOVE.L	D0,STDIN
	CALLSYS	Output
	MOVE.L	D0,STDOUT

	MOVE.B	#$10,LSTRB		;working as df1

MAIN:	OutMsg	Greet.
Loop:	OutMsg	LoadInt.,NoCRLF
	BSR	WaitCR
	ERROR	Exit
	BSR	BusyDrives
	CLR.B	FailFlag
	MOVE.L	#'POWR',TestCode
	BSR	CheckPower
	IFNZB	FailFlag,Bad		;bail out on power failure
	MOVE.L	#'CTL1',TestCode
	BSR	ControlLines		;ca0-ca2, sel, DrvEn, MtrSpd, LSTRB
;	ERROR	Bad
	MOVE.L	#'DrvE',TestCode	;Enable drive
	BSR	DriveEnable
;	ERROR	Bad
	MOVE.L	#'LSTB',TestCode	;make sure we can toggle LSTRB
	BSR	LoadStrobe
;	ERROR	Bad
	MOVE.L	#'MSpd',TestCode	;ditto for MotorSpeed
	BSR	MotorSpeed
;	ERROR	Bad
	MOVE.L	#'RdWr',TestCode	;check read and write paths
	BSR	ReadWriteData
;	ERROR	Bad
	MOVE.L	#'CTL2',TestCode	;now deselect and check result
	BSR	ControlLines
	IFNZB	FailFlag,Bad		;bad awful

Good:	OutMsg	Passed.
	BSR	FreeDrives
	BRA	Loop

Bad:	OutMsg	Failed.
	BSR	FreeDrives
	BRA	Loop

Exit:
	MOVE.L	initialSP,A7
	MOVE.L	SysBase,A6
	MOVE.L	DosBase,D0
	BEQ.S	1$
	MOVE.L	D0,A1
	CALLSYS	CloseLibrary
1$:	CLR.L	D0
	RTS			;BACK TO AMIGA-DOS


* Performs a static test of drive control lines CA0, CA1, CA2, SEL.
* First sets all, then clears all, then sets one at a time.
* Also tests state of DrvEnable, MotorSpeed, and LSTRB.
* In all these cases DrvEnable is NOT set.

ControlLines:
	MOVE.W	#' 1',StepCode
	MOVE.B	#$FF,D0		;set all lines, reset all flops, LSTRB low,
	BSR	SetCiab		; DrvEnable low, MtrSpd high, WrtData low
	MOVE.W	#%1110111,D0	;see CheckStatus for bit definition
	BSR	CheckStatus	;find out if interface is in proper state
;	ERROR	9$		;no

	MOVE.W	#' 2',StepCode
	MOVEQ	#1,D0		;Rdy high, WrtData low
	BSR	CheckRdyTrk0
;	ERROR	9$

	MOVE.W	#' 3',StepCode
	MOVEQ	#Sel1,D0	;clear all lines except Sel1
	BSR	SetCiab
	MOVE.W	#%1010000,D0
	BSR	CheckStatus
;	ERROR	9$

	MOVE.W	#' 4',StepCode
	MOVEQ	#1,D0		;Rdy high, WrtData low
	BSR	CheckRdyTrk0
;	ERROR	9$

	MOVE.W	#' 5',StepCode
	MOVEQ	#Sel1!CA0,D0	;check CA0
	BSR	SetCiab
	MOVE.W	#%1010001,D0
	BSR	CheckStatus
;	ERROR	9$

	MOVE.W	#' 6',StepCode
	MOVEQ	#1,D0		;Rdy high, WrtData low
	BSR	CheckRdyTrk0
;	ERROR	9$

	MOVE.W	#' 7',StepCode
	MOVEQ	#Sel1!CA1,D0	;check CA1
	BSR	SetCiab
	MOVE.W	#%1010010,D0
	BSR	CheckStatus
;	ERROR	9$

	MOVE.W	#' 8',StepCode
	MOVEQ	#1,D0		;Rdy high, WrtData low
	BSR	CheckRdyTrk0
;	ERROR	9$

	MOVE.W	#' 9',StepCode
	MOVEQ	#Sel1!CA2,D0	;check CA2
	BSR	SetCiab
	MOVE.W	#%1010100,D0
	BSR	CheckStatus
;	ERROR	9$

	MOVE.W	#'10',StepCode
	MOVEQ	#1,D0		;Rdy high, WrtData low
	BSR	CheckRdyTrk0
;	ERROR	9$

	MOVE.W	#'11',StepCode
	MOVE.B	#Sel1!SEL,D0	;check SEL
	BSR	SetCiab
	MOVE.W	#%1110000,D0
	BSR	CheckStatus
;	ERROR	9$

	MOVE.W	#'12',StepCode
	MOVEQ	#1,D0		;Rdy high, WrtData low
	BSR	CheckRdyTrk0
;	ERROR	9$
	CLC
9$:	RTS


* Tests drive enable line.

DriveEnable:
	MOVE.W	#' 1',StepCode
	MOVEQ	#Sel1,D0
	BSR	SetCiab			;get ready to select
	ZAP	D0			;now select that sucker
	BSR	SetCiab
	MOVE.W	#%0010000,D0
	BSR	CheckStatus
;	ERROR	9$

	MOVE.W	#' 2',StepCode
	MOVEQ	#CA0!CA1,D0		;set some control lines
	BSR	SetCiab
	MOVE.W	#%0010011,D0
	BSR	CheckStatus
;	ERROR	9$

	MOVE.W	#' 3',StepCode
	MOVE.B	#CA2!SEL,D0		;set other control lines
	BSR	SetCiab
	MOVE.W	#%0110100,D0
	BSR	CheckStatus
9$:	RTS

* Tests generation of LSTRB.

LoadStrobe:
	MOVE.W	#' 1',StepCode
	MOVE.B	LSTRB,D0		;set LSTRB
	BSR	SetCiab
	MOVE.W	#%0011000,D0
	BSR	CheckStatus
;	ERROR	9$

	MOVE.W	#' 2',StepCode
	ZAP	D0			;LSTRB OFF
	BSR	SetCiab
	MOVE.W	#%0010000,D0
	BSR	CheckStatus
9$:	RTS

* Tests generation of motor speed signal.

MotorSpeed:
	MOVE.W	#' 1',StepCode
	MOVE.B	#CA0!CA1!CA2!SEL,D0	;enable speed control, MtrSpd low
	BSR	SetCiab
	MOVE.B	#CA0!CA1!SEL,D0		;tach command (real life cmd)
	BSR	SetCiab
	MOVE.W	#%0100011,D0
	BSR	CheckStatus
;	ERROR	9$

	MOVE.W	#' 2',StepCode
	MOVE.B	LSTRB,D0		;Mtr Spd high
	OR.B	#CA0!CA1!SEL,D0		;retain tach command
	BSR	SetCiab
	MOVE.W	#%0110011,D0
	BSR	CheckStatus

	MOVE.W	#' 3',StepCode
	MOVE.B	#CA0!CA1!CA2!SEL,D0	;disable speed control, MtrSpd high
	BSR	SetCiab
	MOVE.B	LSTRB,D0		;set LSTRB again to test FF2
	BSR	SetCiab
	MOVE.W	#%0011000,D0
	BSR	CheckStatus
;	ERROR	9$

9$:	RTS

* Tests Mac-Amy data flow (read data from drive) and the Rdy line.

ReadWriteData:
	PUSH	D2-D3
	MOVE.W	#' 1',StepCode
	MOVE.L	#'Rdy ',SignalCode
	ZAP	D0
	BSR	SetCiab		;force all lines low
	ZAP	D2
	BSR	CmpRdy		;Rdy should be low
	BEQ.S	1$
	BSR	TestFailed

1$:	MOVE.W	#' 2',StepCode
	MOVE.L	#'Rdy ',SignalCode
	MOVE.B	CIAA,D3		;save state of WrtData (Trk0)
	MOVE.B	#Sel3,D0
	BSR	SetCiab		;set Sel3 to set Mac RdData input
	MOVEQ	#1,D2
	BSR	CmpRdy		;Rdy should be high
	BEQ.S	2$
	BSR	TestFailed

2$:	MOVE.W	#' 3',StepCode
	MOVE.L	#'Rdy ',SignalCode
	ZAP	D0
	BSR	SetCiab		;force Rdy low to toggle WrtData FF
	ZAP	D2
	BSR	CmpRdy		;Rdy should be low
	BEQ.S	3$
	BSR	TestFailed

3$:	MOVE.W	#' 4',StepCode
	MOVE.L	#'WrtD',SignalCode
	MOVE.B	CIAA,D2		;get new state of WrtData
	MOVE.B	D3,D1
	BCHG	#4,D1		;expected to be opposite from D3
	BSR	WrtExpected
	EOR.B	D3,D2
	AND.B	#$10,D2		;states should differ
	BNE.S	4$
	BSR	TestFailed

4$:	MOVE.W	#' 5',StepCode
	MOVE.L	#'Rdy ',SignalCode
	MOVE.B	#Sel3,D0
	BSR	SetCiab		;set Sel3 to set Mac RdData input
	MOVEQ	#1,D2
	BSR	CmpRdy		;Rdy should be high
	BEQ.S	5$
	BSR	TestFailed

5$:	MOVE.W	#' 6',StepCode
	MOVE.L	#'WrtD',SignalCode
	MOVE.B	CIAA,D2		;save state of WrtData (Trk0)
	MOVE.B	D3,D1
	BCHG	#4,D1		;expected to be opposite from D3
	BSR	WrtExpected
	EOR.B	D3,D2
	AND.B	#$10,D2		;states should still differ
	BNE.S	6$
	BSR	TestFailed

6$:	MOVE.W	#' 7',StepCode
	MOVE.L	#'WrtD',SignalCode
	ZAP	D0
	BSR	SetCiab		;Rdy low toggles WrtData FF
	MOVE.B	CIAA,D2		;get new state of WrtData
	MOVE.B	D3,D1
	BSR	WrtExpected
	EOR.B	D3,D2
	AND.B	#$10,D2		;states should now be same
	BEQ.S	9$		;write is ok
	BSR	TestFailed
8$:	STC
9$:	POP	D2-D3
	RTS

* Checks if control lines are in state described by value in D0.
* D0 bit encoded as follows:
*	CA0=0
*	CA1=1
*	CA2=2
*	LSTRB=3
*	MtrSpeed=4
*	SEL=5
*	DrvEnable=6
* This order MUST follow the order of the tests performed by CheckStatus.
* Returns CY=1 on error.

CheckStatus:
	PUSH	D2
	MOVE.W	D0,D2		;save test mask
	MOVE.L	#'CA0 ',SignalCode
	ZAP	D0		;CA0
	BSR	SelectInput
	BSR	CmpCHNG
	BEQ.S	1$
	BSR	TestFailed


1$:	MOVE.L	#'CA1 ',SignalCode
	LSR.W	#1,D2		;now CA1
	MOVEQ	#1,D0
	BSR	SelectInput
	BSR	CmpCHNG
	BEQ.S	2$
	BSR	TestFailed

2$:	MOVE.L	#'CA2 ',SignalCode
	LSR.W	#1,D2		;now CA2
	MOVEQ	#2,D0
	BSR	SelectInput
	BSR	CmpCHNG
	BEQ.S	3$
	BSR	TestFailed

3$:	MOVE.L	#'LSTB',SignalCode
	LSR.W	#1,D2		;now LSTRB
	MOVEQ	#3,D0
	BSR	SelectInput
	BSR	CmpCHNG
	BEQ.S	4$
	BSR	TestFailed

4$:	MOVE.L	#'MSpd',SignalCode
	LSR.W	#1,D2		;now MtrSpeed
	ZAP	D0
	BSR	SelectInput
	BSR	CmpProt
	BEQ.S	5$
	BSR	TestFailed

5$:	MOVE.L	#'SEL ',SignalCode
	LSR.W	#1,D2		;now SEL
	MOVEQ	#1,D0
	BSR	SelectInput
	BSR	CmpProt
	BEQ.S	6$
	BSR	TestFailed

6$:	MOVE.L	#'DrvE',SignalCode
	LSR.W	#1,D2		;now DrvEnable
	MOVEQ	#3,D0
	BSR	SelectInput
	BSR	CmpProt
	BEQ.S	9$
	BSR	TestFailed

8$:	STC
9$:	POP	D2
	RTS

CheckPower:
	MOVE.W	#' 1',StepCode
	MOVE.L	#'+12 ',SignalCode
	MOVEQ	#1,D2			; +12
	MOVEQ	#2,D0
	BSR	SelectInput
	BSR	CmpProt
	BEQ.S	9$
	BSR	TestFailed
	STC
9$:	RTS

* These are checked separately since they may change when drive
* is enabled and Sel3 changes.

CheckRdyTrk0:
	PUSH	D2
	MOVE.L	#'Rdy ',SignalCode
	MOVE.W	D0,D2
	BSR	CmpRdy		;load and test Rdy bit
	BEQ.S	1$
	BSR	TestFailed

1$:	MOVE.L	#'WrtD',SignalCode
	LSR.W	#1,D2		;now WrtData
	BSR	CmpTrk0		;load and test Trk0 bit
	BEQ.S	9$
	BSR	TestFailed
8$:	STC
9$:	POP	D2
	RTS

* Compares CHNG bit in CIAA with low bit of D2.  If not same, returns Z=0.
* CHNG is inverted.

CmpCHNG:
	MOVE.B	D2,D1		;get desired state in D1 (bit 0)
	BSR	Expected	;save expected value
	MOVE.B	CIAA,D0		;get status
	LSR.B	#2,D0		;get CHNG bit into bit 0
	BCHG	#0,D0		;invert bit to correct for 7438
	EOR.B	D1,D0		;same?
	AND.B	#1,D0		;ignore all other bits
	RTS			;return Z set properly

* Compares WrtProt bit in CIAA with low bit of D2.  If not same, returns Z=0.
* WrtProt is inverted.

CmpProt:
	MOVE.B	D2,D1		;get desired state in D1 (bit 0)
	BSR	Expected	;save expected value
	MOVE.B	CIAA,D0		;get status
	LSR.B	#3,D0		;get WrtProt bit into bit 0
	BCHG	#0,D0		;invert bit to correct for 7438
	EOR.B	D1,D0		;same?
	AND.B	#1,D0		;ignore all other bits
	RTS			;return Z set properly

* Compares Trk0 bit in CIAA with low bit of D2.  If not same, returns Z=0.
* Trk0 is inverted.

CmpTrk0:
	MOVE.B	D2,D1		;get desired state in D1 (bit 0)
	BSR	Expected	;save expected value
	MOVE.B	CIAA,D0		;get status
	LSR.B	#4,D0		;get Trk0 bit into bit 0
	BCHG	#0,D0		;invert bit to correct for 7438
	EOR.B	D1,D0		;same?
	AND.B	#1,D0		;ignore all other bits
	RTS			;return Z set properly

* Compares Rdy bit in CIAA with low bit of D2.  If not same, returns Z=0.
* Rdy is NOT inverted.

CmpRdy:
	MOVE.B	D2,D1		;get desired state in D1 (bit 0)
	BSR	Expected	;save expected value
	MOVE.B	CIAA,D0		;get status
	LSR.B	#5,D0		;get Rdy bit into bit 0
	EOR.B	D1,D0		;same?
	AND.B	#1,D0		;ignore all other bits
	RTS			;return Z set properly

* Saved expected value in D1 bit 0 as ASCII char for error msg string.
* Preserves D1.  Exter at WrtExpected to use bit 4, not bit 0.

WrtExpected:
	LSR.W	#4,D1
Expected:
	MOVE.B	D1,D0
	AND.B	#1,D0
	ADD.B	#'0',D0
	MOVE.B	D0,ExpectedCode
	RTS

* Warns that a specific test failed and sets failed flag.

TestFailed:
	OutMsg	FailMsg.
	SETF	FailFlag
	RTS

* Sets CIAB to value in D0 and saves the value.  Forces bit 3 to 1 to avoid
* selecting DF0 by accident.

SetCiab:
	MOVE.B	D0,SaveCiab
	OR.B	#$08,D0		;make sure we don't select DF0
	MOVE.B	D0,CIAB
	RTS

* Sets Sel2/Sel3 lines based on value in D0.

SelectInput:
	AND.B	#3,D0		;mask down to control bits
	LSL.W	#5,D0
	MOVE.B	SaveCiab,D1	;get saved previous value
	AND.B	#$9F,D1		;get rid of previous Sel2/Sel3 bits
	OR.B	D1,D0
	BSR	SetCiab
	RTS

* SETS AMIGA-DOS DISK DRIVES BUSY FOR DURATION OF DISK OPERATION.

BusyDrives:
        PUSH    A0-A1
1$:     MOVE.L  DRBase,A6      ;ASK AMIGA-DOS POLITELY...
        LEA     DISK_BLOCK,A1
        MOVE.L  TaskPtr,MP_TASK
        CALL    DR_GetUnit(A6)  ;...FOR THE DISK CONTROLLER
        TST.L   D0
        BNE     2$              ;GOT THE DISK
        LEA     MSG_PORT,A0
        CALLSYS	WaitPort,SysBase ;WILL SEND REPLY TO DRU PORT
        LEA     MSG_PORT,A0
        CALLSYS	GetMsg		;UNQUEUE REPLY
        BRA.S   1$              ;NOW TRY FOR IT AGAIN
2$:	MOVE.B	#$7F,CIAB
;	MOVE.B	Select,CIAB
	POP     A0-A1
        RTS

* FREES AMIGA-DOS DISK DRIVES AFTER DISK OPERATION.

FreeDrives:
;	MOVE.B	Select,CIAB	;clear control bits
	MOVE.B	#$FF,CIAB	;then deselect everything
        MOVE.L  DRBase,A6 
        CALL    DR_GiveUnit(A6) ;FREE THE DISK RESOURCE
        RTS

* Sends text pointed to by A0 to screen.

DISP..:
	PUSH	D2-D3
	MOVEQ	#-1,D0
1$:	INCL	D0
	TST.B	0(A0,D0.W)
	BNE.S	1$
	MOVE.L	D0,D3
	MOVE.L	A0,D2
	BSR.S	WriteScreen
	POP	D2-D3
	RTS

CRLF..:	MOVEQ	#2,D3
	MOVE.L	#CRLF,D2
WriteScreen:
	MOVE.L	STDOUT,D1
	CALLSYS	Write,DosBase
	RTS

WaitCR:
	BSR.S	GetInput
	IFZB	InputCnt,9$
	MOVE.B	InputBuf,D0
	BCLR	#5,D0		;make upper case
	STC
9$:	RTS

GetInput:
	MOVE.L	STDIN,D1
	MOVE.L	#InputBuf,D2
	MOVEQ	#80,D3
	CALLSYS	Read,DosBase
	DECL	D0		;don't count CR
	MOVE.B	D0,InputCnt	;number of input chars
	RTS

TaskPtr		DC.L	0	;TASK POINTER
SysBase		DC.L	0
DosBase		DC.L	0
initialSP	DC.L	0
DRBase		DC.L	0	;DISK RESOURCE POINTER
STDIN		DC.L	0
STDOUT		DC.L	0
SaveCiab	DC.B	0	;saved CIAB value
InputCnt	DC.B	0	;count of input chars
FailFlag	DC.B	0	;1=unit failed 1 or more tests
LSTRB		DC.B	0
CRLF		DC.B	13,10

InputBuf DS.B	80

DosName		TEXTZ	'dos.library',0
DISK_NAME	TEXTZ	'disk.resource',0
LoadInt. DC.B	13,10
	TEXTZ	<'Connect interface board and turn on power.  Press CR.'>
Passed.	TEXTZ	<'Passed.'>
Failed.	TEXTZ	<'********* WARNING --- FAILED TEST --- WARNING *********'>
Greet.	TEXTZ	<'CCS Mac-2-Dos interface test program V1.0 6/27/89'>

	CNOP	0,4	;WARNING--WATCH YOUR BYTE ALIGNMENT!

FailMsg.	DC.B	'Failed test:  '
TestCode	DC.B	'    '	;main test 4-char ASCII name
		DC.B	', at step:  '
StepCode	DC.B	'  '	;step number 00-99
		DC.B	', signal: '
SignalCode	DC.B	'    '
		DC.B	', expected: '
ExpectedCode	DC.B	' '
		DC.B	0

* DISK RESOURCE UNIT STRUCTURE

INT_STRUCT MACRO
        NODE 2,0,0
        DC.L    0
        DC.L    0
        ENDM

        CNOP  0,4

DISK_BLOCK
        NODE    5,0,0
DB_PORT DC.L    MSG_PORT
        DC.W    DB_MLEN
        INT_STRUCT
        INT_STRUCT
        INT_STRUCT
DB_MLEN EQU *-DISK_BLOCK

TIMER_BLOCK
	NODE	5,0,0
TB_PORT	DC.L	MSG_PORT
	DC.W	TB_MLEN
	DC.L	0,0		;DEV, UNIT
TB_CMD	DC.W	0,0		;COMMAND, FLAGS, ERROR
TB_SECS	DC.L	0		;SECONDS
TB_USEC	DC.L	0		;MICROSECONDS
	DC.L	0,0,0,0		;STANDARD IO REQ EXT
TB_MLEN	EQU *-TIMER_BLOCK

MSG_PORT:
        NODE    4,0,0
        DC.B    0       ;FLAGS=SIGNAL
        DC.B    8       ;SIGNAL 8
MP_TASK DC.L    0       ;MY TASK
MP_HEAD DC.L    MP_TAIL ;HEAD
MP_TAIL DC.L    0       ;TAIL
        DC.L    MP_HEAD ;TAIL PRED
        DC.B    5       ;TYPE
        DC.B    0       ;PAD


        END


