*************************************************************************
*									*
*     Macintosh to AmigaDOS file conversion utility.			*
*									*
*	Copyright (c) 1988 Central Coast Software			*
*	    268 Bowie Dr, Los Osos, CA 93402				*
*	     All rights reserved, worldwide				*
*									*
*************************************************************************

;	INCLUDE "I/MACROS.ASM"
;	INCLUDE "I/EQUATES.ASM"
	INCLUDE	"I/MACMAC.ASM"

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

DF0		EQU	$08+$10+$20
NONE		EQU	$40+$80+DF0
CA0		EQU	$01+DF0
CA1		EQU	$02+DF0
CA2		EQU	$04+DF0
DrvEnable	EQU	DF0
LSTRB		EQU	$40+DF0		;working as df3
SEL		EQU	$80+DF0
;MTRX		EQU	$80

BufferSize	EQU	20000
LIMIT	EQU	120			;1 minute at 300 rpm
OnCnt	EQU	150
OffCnt	EQU	50


GO:
	MOVE.L  A7,initialSP		;initial task stack pointer
	MOVEA.L 4,A6
	MOVE.L  A6,SysBase
	LEA     DosName,A1
	ZAP	D0
	CALLSYS	OpenLibrary		;OPEN DOS LIBRARY
	MOVE.L  D0,LIBRARY_BASE
	ZAPA	A1
	CALLSYS	FindTask
	MOVE.L	D0,D2D_TASK		;save ptr for msg ports
	MOVEA.L D0,A4
	MOVE.L	#BufferSize,D0		;GRAB A BUNCH
	MOVEQ	#2,D1			;SPECIFY CHIP MEMORY
	CALLSYS	AllocMem,SysBase	;GRAB A HUNK OF CHIP MEMORY
	MOVE.L	D0,BUFFER
	BEQ	ABORT
	LEA	DISK_NAME,A1		;SET UP POINTER TO DISK RESOURCE
	CALLSYS	OpenResource
	MOVE.L  D0,DR_BASE		;POINTER TO DISK RESOURCE BLOCK
	BEQ	ABORT			;DIDN'T FIND IT
	LEA	CIAA,A2
	BSR	BUSY_DRIVES
	MOVE.W	#$1500,ADKCON
	MOVE.W	#0,DSKLEN		;enable reading
	BSR	MotorOn
	BSR	DriveRdy		;got a diskette?
	ERROR	9$
;	BSR	WrtProt			;write protected?
;	ERROR	9$
	BSR	HomeDisk
;	BSR	Seek			;to some track
;	BSR	ReadTrack		;read track 0
	BSR	SpeedTest
	MOVE.B	#$FF,CIAB		;deselect drive and reset
9$:	BSR	FREE_DRIVES
	MOVE.L	BUFFER,A1
	MOVE.L	#BufferSize,D0
	CALLSYS	FreeMem,SysBase		;RETURN TO POOL
ABORT:	
	MOVE.L	initialSP,A7
	MOVE.L	SysBase,A6
	MOVE.L	LIBRARY_BASE,D0
	BEQ.S	1$
	MOVE.L	D0,A1
	CALLSYS	CloseLibrary
1$:	CLR.L	D0
	RTS			;BACK TO AMIGA-DOS


* SETS AMIGA-DOS DISK DRIVES BUSY FOR DURATION OF DISK OPERATION.

BUSY_DRIVES:
        PUSH    A0-A1
1$:     MOVE.L  DR_BASE,A6      ;ASK AMIGA-DOS POLITELY...
        LEA     DISK_BLOCK,A1
        MOVE.L  D2D_TASK,MP_TASK
        CALL    DR_GetUnit(A6)  ;...FOR THE DISK CONTROLLER
        TST.L   D0
        BNE     2$              ;GOT THE DISK
        LEA     MSG_PORT,A0
        CALLSYS	WaitPort,SysBase ;WILL SEND REPLY TO DRU PORT
        LEA     MSG_PORT,A0
        CALLSYS	GetMsg		;UNQUEUE REPLY
        BRA.S   1$              ;NOW TRY FOR IT AGAIN
2$:     POP     A0-A1
        RTS

* FREES AMIGA-DOS DISK DRIVES AFTER DISK OPERATION.

FREE_DRIVES:
        MOVE.L  DR_BASE,A6 
        CALL    DR_GiveUnit(A6) ;FREE THE DISK RESOURCE
        RTS 

* Turns MAC drive motor on using Apple procedures.

MotorOn:
	MOVE.B	#$FF,CIAB		;all to 0 (except DF0)
	MOVE.B	#NONE,CIAB
	MOVE.B	#DrvEnable,CIAB
	MOVE.B	#CA0!CA1,CIAB
	MOVE.B	#CA1,CIAB
	MOVE.B	#CA1!LSTRB,CIAB
	NOP
	NOP
	MOVE.B	#CA1,CIAB
	RTS

* Checks for disk in place.

DriveRdy:
	MOVE.B	#SEL,CIAB		;CSTIN=disk in place
	MOVE.B	(A2),D0
	AND.W	#$20,D0
	BEQ.S	9$
	STC
9$:	RTS

* Checks installed disk for write protection set.

WrtProt:
	MOVE.B	#SEL!CA0,CIAB		;WRTPRT=write locked
	MOVE.B	(A2),D0
	AND.W	#$20,D0
	BNE.S	9$			;write enabled
	STC				;else error
9$:	RTS

* Moves head to track 0.

HomeDisk:
	BSR.S	Track0
	NOERROR	9$
	CLR.B	DIR			;first step away from track 0
	BSR.S	SetDirection
	MOVEQ	#2,D2
2$:	BSR.S	STEP
	DBF	D2,2$			;loop
	MOVE.B	#$20,DIR		;direction=toward TRACK 0
	BSR.S	SetDirection
1$:	BSR.S	Track0
	NOERROR	9$
	BSR	STEP
	BRA.S	1$
9$:	RTS

* Checks for head over track 0.

Track0:
	MOVE.B	#SEL!CA1,CIAB		;TK0
	MOVE.B	(A2),D0
	AND.W	#$20,D0
	BEQ.S	9$			;at track 0
	STC				;else error
9$:	RTS

* STEPS head in preset direction, then waits for step flag to drop.

STEP:
	MOVE.B	#CA0!CA1,CIAB		;now issue step command
	MOVE.B	#CA0,CIAB
	MOVE.B	#CA0!LSTRB,CIAB
	NOP
	NOP
	NOP
	NOP
	MOVE.B	#CA0,CIAB
1$:	MOVE.B	(A2),D0
	AND.W	#$20,D0
	BEQ.S	1$
	RTS


Seek:
	CLR.B	DIR			;first step away from track 0
	BSR.S	SetDirection
	MOVEQ	#67,D2
2$:	BSR.S	STEP
	DBF	D2,2$			;loop
	RTS

* Sets stepping direction according to DIR: 0=away from trk 0, 1=toward 0.

SetDirection:
	MOVE.B	#CA0!CA1,CIAB
	TST.B	DIR			;toward track 0?
	BEQ.S	1$			;no...away
	MOVE.B	#CA2,CIAB
	MOVE.B	#CA2!LSTRB,CIAB		;toward 0
	NOP
	NOP
	MOVE.B	#CA2,CIAB
	BRA.S	2$
1$:	MOVE.B	#LSTRB,CIAB		;away from 0
	NOP
	NOP
;	MOVE.B	#NONE,CIAB
2$:	MOVE.B	#CA0!CA1,CIAB
	RTS

Eject:
	MOVE.B	#CA0!CA1,CIAB
	MOVE.B	#CA0!CA1!CA2,CIAB
	MOVE.B	#CA0!CA1!CA2!LSTRB,CIAB
	NOP
	NOP
	MOVE.B	#CA0!CA1,CIAB
	RTS

ReadTrack:
	MOVE.L	#OnCnt,OnCycle
	MOVE.L	#OffCnt,OffCycle
4$:	MOVE.L	OffCycle,DutyCycle
	CLR.L	COUNT
	CALLSYS	Forbid,SysBase
	DISABLE
	MOVE.B	#CA0!CA1!CA2!SEL,CIAB	;SWITCH TO MOTOR SPEED CONTROL
	MOVE.B	#CA0!CA1!SEL,D1		;don't hold that state
	MOVE.B	D1,CIAB
	NOP
1$:	SUBQ.L	#1,DutyCycle
	BNE.S	2$
	MOVE.L	OnCycle,D0
	BCHG	#6,D1			;df3
	BEQ.S	3$
	MOVE.L	OffCycle,D0
3$:	MOVE.L	D0,DutyCycle
	MOVE.B	D1,CIAB
2$:	MOVE.B	(A2),D0
	AND.W	#$20,D0
	CMP.B	STATE,D0
	BEQ.S	1$			;no change...loop
	MOVE.B	D0,STATE
	BEQ.S	1$			;count 0 to 1 transitions
	ADDQ.L	#1,COUNT
	MOVE.L	#LIMIT,D0
	CMP.L	COUNT,D0
	BHI.S	1$
;	MOVE.B	CIAB,D1
;	AND.B	#MTRX,D1		;get motor mode
	AND.B	#$78,D1			;get rid of SEL, CA0, CA1, CA2
	OR.B	#CA2,D1			;read mode, lower head
	MOVE.B	D1,CIAB
	MOVE.L	BUFFER,DSKPTR		;SET DMA ADDRESS
	MOVE.W	#$1500,ADKCON
	MOVE.W	#$8300,ADKCON		;APPLE SYNC
	MOVE.W	#$3002,INTREQ
	MOVE.W	#BufferSize/2,D0	;word count
	OR.W	#$8000,D0
	MOVE.W	D0,DSKLEN		;START THE read
	MOVE.W	D0,DSKLEN
5$:	SUBQ.L	#1,DutyCycle
	BNE.S	6$
	MOVE.L	OnCycle,D0
	BCHG	#6,D1			;working as DF3
	BEQ.S	7$
	MOVE.L	OffCycle,D0
7$:	MOVE.L	D0,DutyCycle
	MOVE.B	D1,CIAB
6$:	MOVE.W	INTREQR,D0		;DONE YET?
	BTST	#1,D0
	NOP
	NOP
	NOP
	BEQ.S	5$			;LOOP TILL DONE
	MOVE.W	#$4000,DSKLEN		;STOP DMA
	MOVE.W	#$3002,INTREQ
	CALLSYS	Permit,SysBase
	ENABLE
	RTS


RHLOOP:
	DISABLE
	BSR.S	WAIT_CHAR		;GET A CHAR
	CMP.B	#$D5,D0			;START OF HEADER?
	BNE.S	RHLOOP
	BSR.S	WAIT_CHAR		;GET NEXT CHAR
	CMP.B	#$AA,D0			;REALLY A HEADER?
	BNE.S	RHLOOP
	BSR.S	WAIT_CHAR
	CMP.B	#$96,D0			;MUST BE $D5AA96 FOR REAL HEADER
	BNE.S	RHLOOP

	LEA	HDRBUF,A4		;HEADER GOES HERE
	MOVEQ	#6,D5			;7 BYTES IN HEADER
8$:	BSR	WAIT_CHAR		;GET ANOTHER HEADER CHAR
9$:	MOVE.B	D0,(A4)+		;STORE THE HEADER BYTE
	DBF	D5,8$			;STORE ALL OF HEADER
	ENABLE
	MOVE.W	NEWHDR,D0
	CMP.W	HDRBUF,D0		;COMPARE WITH THE DESIRED TRACK/SEC
	BNE	RHLOOP			;NO MATCH...WRONG SECTOR OR TRACK
	MOVE.W	#$4000,DSKLEN		;FOUND HEADER...STOP ANY MORE DMA
	RTS

WAIT_CHAR:
	MOVE.W	(A0),D0			;GOT A CHAR?
	BPL.S	WAIT_CHAR		;NOT YET
	RTS				;ELSE RETURN WITH CHAR IN D0

SpeedTest:
	MOVE.B	#CA0!CA1!CA2!SEL,CIAB	;FORCE MOTOR CONTROL MODE
	MOVE.L	#OnCnt,OnCycle
	MOVE.L	#OffCnt,OffCycle
4$:	MOVE.L	OffCycle,DutyCycle
	CLR.L	COUNT
	CALLSYS	Forbid,SysBase
;	DISABLE
	MOVE.B	#CA0!CA1!SEL,D1
	MOVE.B	D1,CIAB
	NOP
1$:	SUBQ.L	#1,DutyCycle
	BNE.S	2$
	MOVE.L	OnCycle,D0
	BCHG	#6,D1
	BEQ.S	3$
	MOVE.L	OffCycle,D0
3$:	MOVE.L	D0,DutyCycle
	MOVE.B	D1,CIAB
2$:	MOVE.B	CIAA,D0
	AND.W	#$20,D0
	CMP.B	STATE,D0
	BEQ.S	1$			;no change...loop
	MOVE.B	D0,STATE
	BEQ.S	1$			;count 0 to 1 transitions
	ADDQ.L	#1,COUNT
	MOVE.L	#LIMIT,D0
	CMP.L	COUNT,D0
	BHI.S	1$
;	ENABLE
	CALLSYS	Permit,SysBase
	TST.B	EndTest
	BEQ	4$			;loop till we want to stop
	RTS


DosName		DC.B	'dos.library',0
DISK_NAME	DC.B	'disk.resource',0

D2D_TASK	DC.L	0	;TASK POINTER
SysBase		DC.L	0
LIBRARY_BASE	DC.L	0

initialSP	DC.L	0
DR_BASE		DC.L	0	;DISK RESOURCE POINTER
BUFFER		DC.L	0
COUNT		DC.L	0
DutyCycle	DC.L	0
OnCycle		DC.L	0
OffCycle	DC.L	0
DIR		DC.B	0	;step direction
STATE		DC.B	0	;tach state
EndTest		DC.B	0

HDRBUF	DCB.B	16,0		;SECTOR HEADER
NEWHDR	DCB.B	16,0		;ENCODED DESIRED SECTOR HEADER

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


