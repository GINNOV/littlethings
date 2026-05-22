
	incdir	include
	include	earth/earth.i
	include	earth/earth_lib.i
	include libraries/arpbase.i
	include	numbersgame.i

	XDEF	_main
	XDEF	ResultStash,MethodStash
	XDEF	MyRexxPort,QuitFlag
	XDEF	SeedValues,NumSeeds

	XREF	CreateScheme,DeleteScheme
	XREF	CreateResult,DeleteResult
	XREF	CreateMethod,DeleteMethod
	XREF	InputSeeds,InputTarget
	XREF	EvaluateAll
	XREF	QueryScheme
	XREF	PrintMethodNicely
	XREF	ARexxStart

	LIBRARY	_EarthBase,earth.library
	LIBRARY	_EarthRexxBase,earthrexx.library,2,OPT
	LIBRARY	_ArpBase,arp.library,34
	LIBRARY _RexxSysBase,rexxsyslib.library,36,OPT

	BSS
ResultStash	ds.l	1	Stash for spare Result
MethodStash	ds.l	1	Stash for spare Method
MyRexxPort	ds.l	1	Rexx port
QuitFlag	ds.l	1	Set if quitting
NumSeeds	ds.l	1	Number of seed values
SeedValues	ds.l	8	Array of seed values

	CODE
_main	move.l	a0,a2
	lea.l	Credits(pc),a0
	BSRARP	Printf

	move.l	a2,a0
	lea.l	M_ARexx(pc),a1
	BSREARTH _StrICmp
	beq	ARexxStart		Branch if doing ARexx stuff

	bsr	InputSeeds		Input seed values
	beq.b	Exit0			Abort if error

	bsr	InputTarget		d0 = target
	move.l	d0,d2

	lea.l	M_Working(pc),a0
	BSRARP	Printf

	bsr	EvaluateAll		evaluate seed array
	beq.b	Exit0
	move.l	a0,a2			a2 = scheme
	bra.b	Outp

Loop	bsr	InputTarget
	move.l	d0,d2
	beq.b	Exit1

Outp	move.l	a2,a0
	move.l	d2,d0
	bsr	QueryScheme

	move.l	res_MethodList(a0),a0
	lea.l	-mth_ValueNode(a0),a0
	move.l	d2,d0
	bsr	PrintMethodNicely
	bra.b	Loop

Exit1	lea.l	M_Freeing(pc),a0
	BSRARP	Printf
	move.l	a2,a0
	bsr	DeleteScheme

Exit0	rts

;=========
; Strings

M_ARexx		dc.b	"AREXX",$A,0
M_Working	dc.b	"Working...",$A,0
M_Freeing	dc.b	"Freeing Memory...",$A,0
		dc.b	"$"
		dc.b	"VER: "
Credits		dc.b	"NumbersGame 1.0 (23.09.92) © Arcane Jill",$A,0
