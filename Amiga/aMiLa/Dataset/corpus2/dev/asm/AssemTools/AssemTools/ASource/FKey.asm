;
; ### Function key handler by JM v 1.06 ###
;
; - Created 890125 by JM -
;
;
; This program links an input handler into the Input.device and converts
; the function key codes into ASCII strings.
;
;
;
;
; Bugs: yet unknown
;
;
; Edited:
;
; - 890125 by JM -> v0.01	- uh-huh
; - 890126 by JM -> v0.02	- first test
; - 890126 by JM -> v0.03	- replyport and sigbit really needed for
;				  DoIO().
; - 890126 by JM -> v0.04	- now allocates space for handler routine and
;				  key strings and creates a public message
;				  port.
; - 890126 by JM -> v0.05	- now allocates buffer for the generated
;				  input events.
; - 890126 by JM -> v0.06	- now generates the input events correctly.
; - 890126 by JM -> v0.07	- some minor changes.
; - 890126 by JM -> v0.08	- default fkey values added.
; - 890126 by JM -> v0.10	- comments improved.
; - 890127 by JM -> v0.11	- more keys defined.
; - 890127 by JM -> v1.0	- MESSAGE added.
; - 890311 by JM -> v1.01	- two branches converted to .s.
; - 890508 by JM -> v1.05	- cmd line parameters I (install) and R
;				  (remove) now processed.
; - 890513 by JM -> v1.06	- If key not defined, handler returns the
;				  original rawkey event.
;
;



		include	"exec.xref"
		include	"dos.xref"
		include	"JMPLibs.i"
		include	"relative.i"
		include	"com.i"
		include	"string.i"
		include	"exec/types.i"
		include	"exec/nodes.i"
		include	"exec/lists.i"
		include	"exec/ports.i"
		include	"exec/memory.i"
		include	"exec/devices.i"
		include	"exec/io.i"
		include	"exec/tasks.i"
		include	"devices/input.i"
		include	"devices/inputevent.i"


strcpy		macro	* a0,a1
strcpy\@	move.b	(\1)+,(\2)+
		bne.s	strcpy\@
		endm


RELATIVE	equ	1

		.var			allocates variables from stack
		dl	_DosBase	 using LINK a4,#-size
		dl	iderror
		dl	SignalB
		dl	ioreq
		dl	msgport
		dl	globport
		dl	cmd


start		.begin				this turns to LINK a4,#-NN
		bsr	ck_cmd
		move.l	d0,cmd(a4)
		moveq.l	#-1,d0
		move.l	d0,iderror(a4)
		move.l	d0,SignalB(a4)
		clr.l	_DosBase(a4)
		clr.l	globport(a4)
		lea	IORequest,a0
		move.l	a0,ioreq(a4)
		lea	MsgPort,a0
		move.l	a0,msgport(a4)

		openlib	Dos,cleanup		open dos.library

		lea	indevname(pc),a0	input.device
		moveq.l	#0,d0			unit#
		move.l	ioreq(a4),a1		IoReq
		moveq.l	#0,d1			flags
		lib	Exec,OpenDevice
		move.l	d0,iderror(a4)		flag: error if > 0
		bne	cleanup			if error

		move.l	msgport(a4),a2
		move.b	#NT_MSGPORT,LN_TYPE(a2)	msgport.mp_Node.ln_Type = 4
		clr.b	MP_FLAGS(a2)		msgport.mp_Flags = 0
		clr.l	LN_NAME(a2)		no name

		moveq.l	#-1,d0
		lib	Exec,AllocSignal	get a signal bit
		move.l	d0,SignalB(a4)
		bmi	cleanup
		move.b	d0,MP_SIGBIT(a2)	msgport.mp_SigBit = d0

		sub.l	a1,a1
		flib	Exec,FindTask		find this task
		move.l	d0,MP_SIGTASK(a2)	set msgport.mp_SigTask

		lea	MP_MSGLIST(a2),a0
		NEWLIST	a0
		move.l	ioreq(a4),a1
		move.l	a2,MN_REPLYPORT(a1)	ioreq.io_Message.mn_ReplyPort

		lea	MESSAGE(pc),a0
		printa	a0

		lea	portname(pc),a1		test if port already exists
		lib	Exec,FindPort
		move.l	d0,globport(a4)

		move.l	cmd(a4),d0
		beq.s	NoCommand
		subq.l	#1,d0
		bne.s	Command_1

		lea	USAGE(pc),a0
		printa	a0
		bra.s	clean1

Command_1	subq.l	#1,d0
		bne.s	Command_2

		move.l	globport(a4),d0		install command
		bne.s	clean1			-> already installed
		bra.s	InstallKeys

Command_2	subq.l	#1,d0
		bne.s	clean1

		move.l	globport(a4),d0		remove command
		bne	RemoveKeys
clean1		bra	cleanup

NoCommand	move.l	globport(a4),d0
		bne.s	RemoveKeys		port exists -> remove everything

InstallKeys	bsr	CreatePort		create messageport
		bcs.s	clean1			-> can't CreatePort()

		bsr	AllocBuffer		allocate memory
		beq.s	clean1

		lea	MP_HANDLER(a2),a1	space for handler routine
		lea	HANDBEG(pc),a0		source for copy
		move.w	#HNDSIZ-1,d0		bytes to copy
1$		move.b	(a0)+,(a1)+
		dbf	d0,1$

		lea	MP_FKEYS(a2),a0
		move.l	a0,MP_DATA(a2)		set string buffer ptr

		lea	MP_HANDLER(a2),a0	a0 points to copy of hstuff
		lea	HS_HANDLER(a0),a1
		move.l	a1,HS_SERVER(a0)	set handler address
		move.l	globport(a4),HS_PORT(a0) set port address

		move.l	ioreq(a4),a1
		move.w	#IND_ADDHANDLER,IO_COMMAND(a1)
		move.l	a0,IO_DATA(a1)
		flib	Exec,DoIO		add handler
		tst.l	d0
		bne.s	cleanup

		bsr	defdef			set default fkey values

		lea	INSTALLED(pc),a0
		printa	a0

		bra.s	cleanup


RemoveKeys	move.l	ioreq(a4),a1
		move.w	#IND_REMHANDLER,IO_COMMAND(a1)
		move.l	d0,a0
		lea	MP_HANDLER(a0),a0	addr of hstuff
		move.l	a0,IO_DATA(a1)
		lib	Exec,DoIO		remove handler
		tst.l	d0
		bne.s	cleanup

		lea	REMOVED(pc),a0		inform the user
		printa	a0

		bsr	FreeBuffer		free allocated memory

		bsr	DeletePort		delete messageport

cleanup		move.l	iderror(a4),d0		test if input.device open
		bne.s	cleanup10
		move.l	ioreq(a4),a1
		lib	Exec,CloseDevice	close input.device

cleanup10	move.l	SignalB(a4),d0		test if a signal allocated
		bmi.s	cleanup11
		lib	Exec,FreeSignal		if so, free it

cleanup11	closlib	Dos			close dos.library
		moveq.l	#0,d0
		.end				UNLK and RTS



*************************************************************************
*									*
* Create messageport so that the key strings etc. can be found by	*
* other tasks like KEY.  Also needed to find the input handler and	*
* to remove it from system when desired.				*
*									*
* This messageport stays in memory as long as the function keys are	*
* active although the actual fkey program exits.  The buffers and	*
* other variables immediately follow the standard MsgPort structure.	*
*									*
*************************************************************************

CreatePort	move.l	#MYPORT,d0
		move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
		lib	Exec,AllocMem
		move.l	d0,globport(a4)
		beq.s	CreatePort_e
		move.l	d0,a2
		move.b	#0,LN_PRI(a2)
		move.b	#NT_MSGPORT,LN_TYPE(a2)

		lea	MP_MYNAME(a2),a1	pos of name within myport
		move.l	a1,LN_NAME(a2)
		lea	portname(pc),a0
		strcpy	a0,a1			copy name into myport

		move.l	a2,a1
		flib	Exec,AddPort		AddPort!  - Crash!? - No.
		clrc
		rts

CreatePort_e	setc
		rts


DeletePort	lea	portname(pc),a1
		lib	Exec,FindPort
		move.l	d0,a1
		move.l	d0,d2
		beq.s	DeletePort_ok
		flib	Exec,RemPort
		move.l	#MYPORT,d0
		move.l	d2,a1
		flib	Exec,FreeMem
DeletePort_ok	rts



*************************************************************************
*									*
* Allocate buffer for extra InputEvent structures created when the user	*
* presses a function key.						*
* We don't use dynamic allocation to save some time in the input	*
* handler routine.							*
*									*
*************************************************************************

AllocBuffer	move.l	globport(a4),a2
		move.l	#(64*ie_SIZEOF),d0
		move.l	d0,MP_BUFSIZ(a2)
		move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
		lib	Exec,AllocMem
		move.l	d0,MP_BUFPTR(a2)
		rts

FreeBuffer	move.l	globport(a4),a2
		move.l	MP_BUFPTR(a2),d0
		beq.s	FreeBuf_ok
		move.l	d0,a1
		move.l	MP_BUFSIZ(a2),d0
		lib	Exec,FreeMem
		clr.l	MP_BUFPTR(a2)
FreeBuf_ok	rts



*************************************************************************
*									*
* Set default function key definitions:					*
*									*
*************************************************************************

defdef		lea	deftable(pc),a0
		move.l	globport(a4),a1
		lea	MP_FKEYS(a1),a1
		moveq.l	#19,d0			counter
defloop1	lea.l	64(a1),a2		addr of next string
defloop2	move.b	(a0)+,(a1)+
		bpl.s	defloop2
		move.l	a2,a1			next
		dbf	d0,defloop1
		rts



*************************************************************************
*									*
* Check for a command:							*
*									*
*************************************************************************

ck_cmd		clr.b	-1(a0,d0)		NULL terminate cmd line
		moveq.l	#0,d1			default: no command
		move.b	(a0)+,d0		get first char
		beq.s	ck_cmd_x		if NULL, exit
		moveq.l	#1,d1			set flag: command exists
		strlib	ucase
		cmp.b	#'I',d0
		bne.s	ck_cmd_1
		moveq.l	#2,d1			'install' command
ck_cmd_1	cmp.b	#'R',d0
		bne.s	ck_cmd_x
		moveq.l	#3,d1			'remove' command
ck_cmd_x	move.l	d1,d0
		rts


		strlib
		
*************************************************************************
*									*
* My input handler routine.  It doesn't handle a linked list of input	*
* events correctly because it only checks the first event of the list.	*
* If the first one is a fkey the rest of the events in the queue are	*
* discarded.  If the first event is not a fkey the list is passed	*
* untouched to the next handler (ie. no later events are checked for	*
* fkey codes).								*
*									*
*************************************************************************

HANDBEG

hstuff		dc.l	0			ln_Succ
		dc.l	0			ln_Pred
		dc.b	2			ln_Type = NT_INTERRUPT
		dc.b	60			ln_Pri
		dc.l	0			ln_Name
glport		dc.l	0			data
hserver		dc.l	0			server

handler		push	d1-d7/a1-a6
		move.l	a0,a5
		cmpi.b	#IECLASS_RAWKEY,ie_Class(a0)
		bne.s	handex
		move.w	ie_Code(a0),d0
		sub.w	#$50,d0
		blo.s	handex
		cmp.w	#$9,d0
		bhi.s	handex
		moveq.l	#IEQUALIFIER_LSHIFT!IEQUALIFIER_RSHIFT,d1 mask
		and.w	ie_Qualifier(a0),d1	shift status
		bsr.s	handlefkeys

handex		pull	d1-d7/a1-a6
		move.l	a0,d0
		rts

handlefkeys	tst.w	d1
		beq.s	1$
		add.w	#10,d0			-> shifted keys 10...19
1$		asl.w	#6,d0			calculate index into table
		move.l	glport(pc),a0
		move.l	MP_BUFPTR(a0),a1	buffer for input events
		move.l	a1,a4			save it
		lea	MP_FKEYS(a0),a0
		add.w	d0,a0			pointer to fkey buffer
		tst.b	(a0)
		bmi.s	hndlfkeys_NULL		-> empty string

		moveq.l	#31,d2			char counter

hndl_next	clr.l	ie_NextEvent(a1)	initialize IEvent structure
		move.b	#IECLASS_RAWKEY,ie_Class(a1)
		clr.b	ie_SubClass(a1)
		moveq.l	#0,d0
		move.b	(a0)+,d0
		move.w	d0,ie_Code(a1)
		move.b	31(a0),d0
		move.w	d0,ie_Qualifier(a1)
		clr.l	ie_EventAddress(a1)
		move.l	ie_TimeStamp(a5),ie_TimeStamp(a1)
		move.l	ie_TimeStamp+4(a5),ie_TimeStamp+4(a1)
		tst.b	(a0)
		bmi.s	hndl_no_more		-> no more chars
		subq.w	#1,d2
		bmi.s	hndl_no_more
		lea	ie_SIZEOF(a1),a2
		move.l	a2,(a1)			set ptr to next ie
		move.l	a2,a1
		bra.s	hndl_next

hndl_no_more	move.l	a4,a0			-> return addr of new stream
		rts
hndlfkeys_NULL	move.l	a5,a0			-> original event
		rts

HANDEND
HS_SERVER	equ	hserver-hstuff		define offsets
HS_HANDLER	equ	handler-hstuff
HS_PORT		equ	glport-hstuff
HNDSIZ		equ	HANDEND-HANDBEG



*************************************************************************
*									*
* Allocate space within messageport for port name, function key strings *
* and the handler routine.						*
*									*
*************************************************************************

MP_DATA		equ	MP_SIZE			pointer to string buffer
MP_HANDLER	equ	MP_DATA+4		space for handler routine
MP_BUFPTR	equ	MP_HANDLER+HNDSIZ	input event buffer pointer
MP_BUFSIZ	equ	MP_BUFPTR+4		input event buffer size
MP_MYNAME	equ	MP_BUFSIZ+4		pointer to buffer
MP_FKEYS	equ	MP_MYNAME+16		buffer for key strings
MYPORT		equ	MP_FKEYS+1340		size of my msgport




indevname	dc.b	'input.device',0
portname	dc.b	'FKeyPort',0
INSTALLED	dc.b	'FKeys installed',10,0
REMOVED		dc.b	'FKeys removed',10,0
MESSAGE		dc.b	'FKEY 1.06 by Supervisor Software 1989',10,0
USAGE		dc.b	'Usage: FKEY [I|R] where I=install; R=remove',10,0

*************************************************************************
*									*
* Default function key definitions in raw key codes.			*
* No qualifiers can be set here.					*
*									*
*************************************************************************

deftable	dc.b	$36,$12,$11,$33,$28,$17,$44,-1	   newcli<cr>
		dc.b	$12,$36,$22,$33,$28,$17,$44,-1	   endcli<cr>
		dc.b	$22,$17,$13,$44,-1		   dir<cr>
		dc.b	$28,$17,$21,$14,$44,-1		   list<cr>
		dc.b	$33,$22,$40,-1			   cd<spc>
		dc.b	$13,$16,$36,$40,-1		   run<spc>
		dc.b	$12,$32,$12,$33,$16,$14,$12,$40,-1 execute<spc>
		dc.b	$17,$36,$23,$18,$44,-1		   info<cr>
		dc.b	$20,$34,$20,$17,$28,$44,-1	   avail<cr>
		dc.b	$35,$13,$12,$20,$27,$40,-1	   break<spc>
		dc.b	-1			11
		dc.b	-1			12
		dc.b	-1			13
		dc.b	-1			14
		dc.b	-1			15
		dc.b	-1			16
		dc.b	-1			17
		dc.b	-1			18
		dc.b	-1			19
		dc.b	-1			20



*************************************************************************
*									*
* This macro produces only the dos.library name in this program.	*
*									*
*************************************************************************

		libnames



*************************************************************************
*									*
* Structures defined in a bss chunk to make the program file smaller.	*
*									*
*************************************************************************

		section	struct,bss

IORequest	ds.b	IO_SIZE			struct IOStdReq
MsgPort		ds.b	MP_SIZE			struct MsgPort

		end

