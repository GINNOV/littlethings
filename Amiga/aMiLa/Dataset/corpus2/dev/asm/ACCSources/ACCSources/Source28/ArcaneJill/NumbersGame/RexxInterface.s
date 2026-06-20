
	incdir	include
	include	earth/earth.i
	include	earth/earth_lib.i
	include	earth/earthrexx.i
	include	earth/earthrexx_lib.i
	include libraries/arpbase.i
	include	rexx/rxslib.i
	include	numbersgame.i

	XDEF	ARexxStart
	XDEF	NewRexxPort

	XREF	_ArpBase
	XREF	_EarthBase
	XREF	_EarthRexxBase
	XREF	_RexxSysBase
	XREF	MyRexxPort
	XREF	QuitFlag
	XREF	NumSeeds,SeedValues

	XREF	CreateScheme,DeleteScheme
	XREF	CreateResult,DeleteResult
	XREF	CreateMethod,DeleteMethod
	XREF	ScanNumber
	XREF	EvaluateAll,QueryScheme,QuerySchemeExact
	XREF	PrintMethodNicely

;==================================================
; This is the structure required by OpenRexxPort()

NewRexxPort
	dc.l	M_NumbersGame
	dc.l	NULL			Mo file extension
	dc.l	CommandTable
	dc.l	NULL			No function table
	dc.w	RPF_COMPACT|RPF_SINGLE	A couple of flags
	dc.b	0			Priority zero
	dc.b	0			Not a function host
	dc.l	NULL			Use default dispatch function
	dc.l	NULL			Use default pass function
	dc.l	NULL			Use default fail function
	dc.l	0			No extra stack

CommandTable
	DEFCMD	GETSCHEME,RXGetScheme
	DEFCMD	GETMETHOD,RXGetMethod
	DEFCMD	FREESCHEME,RXFreeScheme
	DEFCMD	QUIT,RXQuit
	DEFCMD

;==========================================================
; The main entry point if running as an ARexx command host

ARexxStart
ARRegs	reg	a2
;
; First of all we make sure that the library is available.
;
	tst.l	_EarthRexxBase(_data)
	bne.b	.cont
	lea.l	M_NeedERXLib(pc),a0
	bra.b	.warn

.cont	tst.l	_RexxSysBase(_data)
	bne.b	ARStart
	lea.l	M_NeedRXSLib(pc),a0
.warn	BSRARP	Printf			Warn user that library needed
	rts
;
; Next we open an ARexx port.
;
ARStart	movem.l	ARRegs,-(sp)
	lea.l	NewRexxPort(pc),a0
	move.l	_data,a1
	BSRERX	OpenRexxPort		Open the ARexx port
	move.l	d0,MyRexxPort(_data)
	beq.b	ARExit0			Exit if failed
;
; The main loop goes here...
;
ARLoop	move.l	MyRexxPort(_data),a0
	move.l	rp_WaitMask(a0),d0
	BSREXEC	Wait			Wait for an ARexx message
	move.l	MyRexxPort(_data),a0
	BSRERX	ProcessRexx		Process all messages at port
	tst.l	QuitFlag(_data)
	beq.b	ARLoop			Repeat until ready to quit
;
; Tidy up and exit.
;
ARExit1	move.l	MyRexxPort(_data),a0
	BSRERX	CloseRexxPort
ARExit0	movem.l	(sp)+,ARRegs
	rts

;==================================
; Now come the commands themselves

;----------------------------------------------------------
; Result = GetScheme(RexxPort,RexxMsg,UserData,CommandLine)
; d0		     a0       a1      a2       a3
;
; ARexx command syntax:
; GetScheme <s1> <s2> [<s3> [<s4> [<s5> [<s6> [<s7> [<s8>]]]]]]

RXGetScheme
GSRegs	reg	a2/_data/a6
	movem.l	GSRegs,-(sp)
	move.l	a2,_data
	move.l	a1,a2			a2 = rexx message

	move.l	a3,a0
	bsr	GetSeedArray		Get the seed values
	beq.b	GSFail			Branch if error

	bsr	EvaluateAll		Evaluate scheme
	beq.b	GSFail			Branch if no memory

	move.l	a0,a1			a1 = address of scheme
	move.l	a2,a0			a0 = rexx message
	move.l	#0,d0
	move.l	#RP_DECIMAL,d1
	BSRERX	SetResults		Install result string

	move.l	#RP_OK,d0
	movem.l	(sp)+,GSRegs
	rts

GSFail	move.l	#RXERR_NO_MEMORY,d0
	movem.l	(sp)+,GSRegs
	rts

;-------------------------------
; success = GetSeedArray(buffer)
; d0,Z

GetSeedArray
GSARegs	reg	d2/a2-a3
	movem.l	GSARegs,-(sp)
	move.l	#0,d2			d2 counts number of seeds
	lea.l	SeedValues(_data),a2	a2 = address of seed array
	move.l	a0,a3			a3 = buffer

.loop	move.l	#0,d0
	move.b	(a3)+,d0
	ISSPACE	d0
	bne.b	.loop			Skip past whitespaces

	lea.l	-1(a3),a0
	BSRREXX	CVa2i			Get next seed
	tst.l	d1
	beq.b	GSATest			Branch if no more seeds
	lea.l	-1(a3,d1.l),a3		Adjust a3 for next seed
	move.l	d0,(a2)+		Store seed in array
	add.l	#1,d2			Count it
	cmp.l	#8,d2
	blo.b	.loop

GSATest	move.l	d2,NumSeeds(_data)
	cmp.l	#2,d2
	bhs.b	GSAExit

GSAFail	move.l	#0,d2
GSAExit	move.l	d2,d0
	movem.l	(sp)+,GSARegs
	rts

;----------------------------------------------------------
; Result = GetMethod(RexxPort,RexxMsg,UserData,CommandLine)
; d0		     a0       a1      a2       a3
;
; ARexx command syntax:
; GetMethod <scheme> <target> [<index>]

RXGetMethod
GMRegs	reg	d2-d4/a2-a6
	movem.l	GMRegs,-(sp)
	move.l	a1,a4			a4 = RexxMsg
	move.l	a2,_data
	move.l	#1,d4			Set "Exact" flag
;
; Get the scheme.
;
	move.l	a3,a0			a0 = address of scheme (ASCII string)
	BSRREXX	CVa2i
	move.l	d0,a2			a2 = address of scheme
;
; Get the target.
;
	move.l	a3,a0
	BSRREXX	StcToken		a0 = target (ASCII string)
	move.l	a0,a3
	BSRREXX CVa2i			d0 = target
	move.l	d0,d2			d2 = target
;
; Get the index.
;
	move.l	a3,a0
	BSRREXX	StcToken		a0 = index (ASCII string)
	move.l	a0,a3
	move.l	a3,a0
	BSRREXX	CVa2i
	move.l	d0,d3			d3 = index
	bne.b	GMFind			Branch if index supplied
	move.l	#1,d3			Else use default value
	move.l	#0,d4			Reset exact flag
;
; Find out how to do this method.
;
GMFind	move.l	a2,a0
	move.l	d2,d0
	tst.b	d4
	bne.b	.cont1
	bsr	QueryScheme
	bra.b	.cont2
.cont1	bsr	QuerySchemeExact
.cont2	beq.b	GMEmpty
	lea.l	res_MethodList(a0),a0
	bra.b	.next

.loop	move.l	MLN_SUCC(a0),a0
	tst.l	MLN_SUCC(a0)
	beq.b	GMEmpty			Return empty string if index too high
.next	dbra	d3,.loop

	lea.l	-mth_ValueNode(a0),a0	a0 = method
	bsr	MethodToArgstring
;
; Return the argstring.
;
	move.l	a0,a1			a1 = argstring to return
	move.l	a4,a0			a0 = rexx message
	move.l	#0,d0
	move.l	#RP_ARGSTRING,d1
	BSRERX	SetResults		Install result string
	bra.b	GMExit
;
; Return the empty string.
;
GMEmpty	move.l	a4,a0
	lea.l	M_Empty(pc),a1
	move.l	#0,d0
	move.l	#RP_STRING,d1
	BSRERX	SetResults
;
; All done, so return.
;
GMExit	move.l	#RP_OK,d0
	movem.l	(sp)+,GMRegs
	rts

;--------------------------------------
; argstring = MethodToArgstring(method)
; d0,a0,Z                       a0

MethodToArgstring
MTARegs	reg	a2-a4
	movem.l	MTARegs,-(sp)
	move.l	a0,a2			a2 = method
;
; Convert value to argstring
;
	move.l	#0,d0
	move.w	mth_Value(a2),d0	d0 = value
	BSRREXX	CVi2arg			Convert to argstring
	beq.b	MTAFail0		Branch if no memory
	move.l	a0,a3			a3 = value argstring	
;
; Convert method to expression argstring
;
	move.l	a2,a0
	bsr.b	ExpandMethod		Convert to argstring
	move.l	a0,a4
	beq.b	MTAFail1		Branch if no memory
;
; Combine the two argstrings
;
	move.l	a3,a0
	move.l	a4,a1
	move.l	#'=',d0
	BSRERX	ASPadJoin		Concatenate the argstrings
;
; Delete the now redundant argstrings
;
	exg.l	a0,a4
	BSRREXX	DeleteArgstring
MTAFail1
	move.l	a3,a0
	BSRREXX	DeleteArgstring
	move.l	a4,a0
	move.l	a0,d0
MTAFail0
	movem.l	(sp)+,MTARegs
	rts

;---------------------------------
; argstring = ExpandMethod(method)
; d0,a0,Z                  a0

ExpandMethod
EMRegs	reg	a2-a4
	movem.l	EMRegs,-(sp)	
	move.l	a0,a2			a2 = method
	tst.b	mth_Type(a2)
	bne.b	EMNotSeed		Branch unless this is a seed

	move.l	#0,d0
	move.w	mth_Value(a2),d0	d0 = value of seed
	BSRREXX	CVi2arg			Convert to argstring
	move.l	a0,a4
	bra.b	EMExit			Branch to exit

EMNotSeed
	move.l	mth_Parent1(a2),a0
	bsr.b	ExpandMethod		a0 = left argstring
	beq.b	EMExit			Abort if no memory
	move.l	a0,a3			a3 = left argstring

	move.l	mth_Parent2(a2),a0
	bsr.b	ExpandMethod		a0 = right argstring
	move.l	a0,a4			a4 = right argstring
	beq.b	EMCont1			Abort if no memory

	move.l	a3,a0
	move.l	a4,a1
	move.l	#0,d0
	move.b	mth_Type(a2),d0
	BSRERX	ASPadJoin		a0 = concatenated argstring

	exg.l	a0,a4
	BSRREXX	DeleteArgstring		Delete right argstring
EMCont1	move.l	a3,a0
	BSRREXX	DeleteArgstring		Delete left argstring

EMBrackets
	move.l	a4,a0
	move.l	a0,d0
	beq.b	EMExit			Abort if ran out of memory
	move.l	#1,d0
	move.l	#'(',d1
	BSRERX	ASPadLeft		Stick a ( at the left
	exg.l	a0,a4
	BSRREXX	DeleteArgstring		Delete original

	move.l	a4,a0
	move.l	a0,d0
	beq.b	EMExit			Abort if ran out of memory
	move.l	#1,d0
	move.l	#')',d1
	BSRERX	ASPadRight		Stick a ) at the right
	exg.l	a0,a4
	BSRREXX	DeleteArgstring		Delete original

	move.l	a4,a0
EMExit	move.l	a0,d0
	movem.l	(sp)+,EMRegs
	rts

;---------------------------------------------------------------
; Result = FreeScheme(RexxPort,RexxMsg,UserData,CommandLine)
; d0		      a0       a1      a2       a3
;
; ARexx command syntax:
; FreeScheme <scheme>

RXFreeScheme
FSRegs	reg	_data/a6
	movem.l	FSRegs,-(sp)
	move.l	a2,_data
	move.l	a3,a0			a0 = address of decimal buffer
	BSRREXX	CVa2i
	move.l	d0,a0			a0 = address of scheme
	bsr	DeleteScheme		Delete it
	move.l	#RP_OK,d0
	movem.l	(sp)+,FSRegs
	rts

;---------------------------------------------------------------
; Result = Quit(RexxPort,RexxMsg,UserData,CommandLine)
; d0            a0       a1      a2       a3

RXQuit	move.l	#1,QuitFlag(a2)		Signal "Quitting"
	move.l	#RP_OK,d0		Return all OK
	rts

;=========
; Strings

M_NeedERXLib	dc.b	'You need "earthrexx.library" version 10 or greater',$A,0
M_NeedRXSLib	dc.b	'You need "rexxsyslib.library" version 36 or greater',$A,0
M_NumbersGame	dc.b	"NUMBERSGAME",0
M_EXACT		dc.b	"EXACT",0
M_Empty		dc.b	0

