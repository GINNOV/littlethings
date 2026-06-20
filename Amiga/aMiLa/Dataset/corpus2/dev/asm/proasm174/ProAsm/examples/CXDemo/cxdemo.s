;-------------------------------------------------------------------------------
*                                                                              *
* CXDemo	- Commodity Demo Program                                       *
*                                                                              *
* Written 1993 by Daniel Weber                                                 *
*                                                                              *
* This small demo program shows you how to use the commodity.r routines.       *
* Don't look at this code (it's a mess), but use it as a reference.            *
* Use the C= Exchange program to test it, and try to start it again while      *
* one demo is already running...                                               *
* Have fun! Daniel.                                                            *
*                                                                              *
*                                                                              *
*       Filename        cxdemo.s                                               *
*       Author          Daniel Weber                                           *
*       Version         0.20                                                   *
*       Start           06.04.93                                               *
*                                                                              *
*       Last Revision   25.12.93                                               *
*                                                                              *
;-------------------------------------------------------------------------------

	output	'ram:cxdemo'

	opt	o+,q+,ow-,qw-,sw-,f+
	verbose
	base	progbase

;-------------------------------------------------------------------------------

	incdir	'include:'
	incdir	'routines:'

	incequ	'LVO.s'
	include	'structs.r'
	include	'exec/ports.i'
	include	'dos/dos.i'
	include	'support.mac'
	include	'basicmac.r'

;-------------------------------------------------------------------------------

version		equr	"0.10"
gea_progname	equr	"cxdemo"

;-- startup control  --
;cws_V36PLUSONLY	set	1		;only OS2.x or higher
;cws_DETACH	set	1			;detach from CLI
cws_CLIONLY	set	1			;for CLI usage only
;cws_PRI	equ	0			;set process priority to 0
;cws_FPU	set	1

;-- user definitions --
AbsExecBase	equ	4
DOS.LIB		set	36
COMMODITIES.LIB	set	36


cx_id		equ	93

;-------------------------------------------------------------------------------
progbase:
	jmp	AutoDetach(pc)
	dc.b	0,"$VER: ",gea_progname," ",version," (",__date2,")",0
	even
;----------------------------
start:

clistartup:
wbstartup:
	lea	progbase(pc),a5
	bsr	OpenLibrary
	beq.s	.out

*
* install a broker
*
	lea	myPort(pc),a0
	lea	myBroker(pc),a1
	CALL_	InitBroker		;install broker
	move.l	d0,broker(a5)
	beq.s	.out
	move.l	d1,brokerport(a5)

*
* HotKey
*
	lea	HotKeyString(pc),a0
	move.l	d0,a1			;broker
	move.l	d1,a2			;message port
	moveq	#cx_id,d0		;ID
	CALL_	InstallHotKey		;add a hot key triade
	tst.l	d0
	beq.s	.out
	move.l	broker(pc),a0
	CALL_	EnableCX
*
* do the main
*
	bsr	main			;wait...
	moveq	#0,d0
	move.l	broker(pc),a0
	move.l	brokerport(pc),a1
	CALL_	RemoveBroker		;remove all
.out:	bsr	CloseLibrary		;quit
	bra	ReplyWBMsg



;-------------------------------------------------------------------------------
*
* main - just do it...
*
;-------------------------------------------------------------------------------
main:	print_	<"CXDemo: HotKey=<lcommand help>>; press CTRL-C to quit...",$a>

loop:	moveq	#0,d0
	moveq	#0,d1
	move.l	brokerport(pc),a0
	move.b	MP_SIGBIT(a0),d1
	bset	d1,d0
	or.l	#SIGBREAKF_CTRL_C,d0	;ctrl-c
	move.l	4.w,a6
	jsr	_LVOWait(a6)
	move.l	d0,d1
	and.l	#SIGBREAKF_CTRL_C,d1
	bne	outmain

	move.l	brokerport(pc),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,a0
	move.l	a0,d0
	beq	loop			;nothing

	move.l	a0,a4			;store
	move.l	CxBase(pc),a6
	jsr	_LVOCxMsgID(a6)
	move.l	d0,d7

	move.l	a4,a0
	jsr	_LVOCxMsgType(a6)
	move.l	d0,d6

	move.l	4.w,a6
	move.l	a4,a1
	jsr	_LVOReplyMsg(a6)


	cmp.l	#CXM_IEVENT,d6
	beq	cxmevent
	cmp.l	#CXM_COMMAND,d6
	beq	cxmcommand
	print_	<"unknown message type",$a>
	bra	loop


cxmevent:
	print_	"A CXM_EVENT, "
	cmp.l	#cx_id,d7
	bne	unknownID
	print_	<"you hit the HotKey man... wooow",$a>
	bra	loop

cxmcommand:
	print_	"A command: "
	cmp.l	#CXCMD_DISABLE,d7
	bne.s	1$
	print_	<"CXCMD_DISABLE",$a>
	bra	loop

1$:	cmp.l	#CXCMD_ENABLE,d7
	bne.s	2$
	print_	<"CXCMD_ENABLE",$a>
	bra	loop

2$:	cmp.l	#CXCMD_KILL,d7
	bne.s	3$
	print_	<"CXCMD_KILL",$a>
	bra	loop

3$:	cmp.l	#CXCMD_UNIQUE,d7
	bne.s	4$
	print_	<"CXCMD_UNIQUE",$a>
	bra	loop

4$:	cmp.l	#CXCMD_APPEAR,d7
	bne.s	5$
	print_	<"CXCMD_APPEAR",$a>
	bra	loop

5$:	cmp.l	#CXCMD_DISAPPEAR,d7
	bne.s	6$
	print_	<"CXCMD_DISAPPEAR",$a>
	bra	loop

6$:	cmp.l	#CXCMD_LIST_CHG,d7
	bne.s	unknownID
	print_	<"CXCMD_LIST_CHG",$a>
	bra	loop



unknownID:
	print_	<"unknown.",$a>
	bra	loop

outmain:
	rts



;-------------------------------------------------------------------------------
*
* external routines
*
;-------------------------------------------------------------------------------
	include	startup4.r
	include	commodity.r
	include	easylibrary.r

;-------------------------------------------------------------------------------
*
* Data stuff....
*
;-------------------------------------------------------------------------------
HotKeyString:	dc.b	"lcommand help",0
		even


myPort:   PortStruct_	"CXDemo Port"
myBroker: BrokerStruct_	"CXDemo","cxdemo - commodity.r test",,,,"Juhu description!"


broker:		dc.l	0
brokerport:	dc.l	0



	end

