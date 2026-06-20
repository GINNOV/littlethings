;
; ### Function key redefining program by JM v 1.02 ###
;
; - Created 890126 by JM -
;
;
; This program changes the default function key values set by the FKey
; program.
;
;
;
;
; Bugs: yet unknown
;
;
; Edited:
;
; - 890126 by JM -> v0.01	- uh-huh
; - 890126 by JM -> v0.02	- should work.
; - 890126 by JM -> v0.03	- well, try to learn the difference betw.
;				  a0 and d0 - that will save you from many
;				  troubles.
; - 890126 by JM -> v0.04	- ctrl key capability added.
; - 890127 by JM -> v0.10	- comments improved.
; - 890127 by JM -> v0.11	- alt and shft+alt support added (needed with
;				  some national keymaps to get a #).
; - 890127 by JM -> v0.12	- key ? can be used to list the current
;				  definitions.
; - 890127 by JM -> v1.0	- MESSAGE added.
; - 890311 by JM -> v1.01	- two branches converted to .s.
; - 890513 by JM -> v1.02	- Now makes the fkey string empty if necessary.
;
;



		include	"exec.xref"
		include	"dos.xref"
		include	"console.xref"
		include	"JMPLibs.i"
		include	"relative.i"
		include	"com.i"
		include	"string.i"
		include	"numeric.i"
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
		dl	_ConsoleDeviceBase
		dl	cmdlin
		dl	cderror
		dl	ioreq
		dl	ievent
		dl	globport
		dl	buffer


start		.begin				this turns to LINK a4,#-NN
		move.l	a0,cmdlin(a4)
		clr.b	-1(a0,d0.w)		add NULL to the end of cmd line
		moveq.l	#-1,d0
		move.l	d0,cderror(a4)		set variables to known values
		clr.l	_DosBase(a4)
		clr.l	_ConsoleDeviceBase(a4)
		lea	IORequest,a0		get addr if IORequest struct
		move.l	a0,ioreq(a4)
		lea	IEvent,a0		get addr of InputEvent struct
		move.l	a0,ievent(a4)

		openlib	Dos,cleanup		open dos.library
		bsr	getconsbase		open console.device
		bcs.s	cleanup_i

		lea	portname(pc),a1		test if port already exists
		lib	Exec,FindPort
		move.l	d0,globport(a4)		save port address
		beq.s	install_first

		move.l	cmdlin(a4),a0		check if LIST command
		cmp.b	#'?',(a0)
		bne.s	define

		lea	MESSAGE(pc),a0
		printa	a0
		bsr	listdef			list definitions
cleanup_i	bra.s	cleanup

define		bsr.s	setdef			re-define a fkey
		bra.s	cleanup

install_first	lea	INSTALLREQ(pc),a0	request the user to run fkey
		printa	a0

cleanup		bsr	closeconsole		close console.device
		closlib	Dos			close dos.library
		moveq.l	#0,d0
		.end				UNLK and RTS





*************************************************************************
*									*
* Set definitions							*
* Command line parsing is very simple.  The command name must be	*
* followed by one space and the function key number 1...20.		*
* After the number one space is needed.  The rest of the command line	*
* is interpreted as the string for the function key.			*
*									*
*************************************************************************

setdef		move.l	cmdlin(a4),a0		get fkey number
		numlib	get10			 (gets a number in d0)
		bcs.s	setdef_e1		-> illegal number
		subq.l	#1,d0
		blt.s	setdef_e1		check if legal number
		cmp.l	#19,d0
		bgt.s	setdef_e1

		move.l	globport(a4),a1		get messageport address
		move.l	MP_SIZE(a1),a1		pointer to fkey strings
		asl.w	#6,d0			multiply by 64
		add.w	d0,a1			add index to pointer

		tst.b	(a0)			see if there is no string
		beq.s	setdef_ok		-> make the fkey empty
		cmpi.b	#' ',(a0)+		must be num<spc>string
		bne.s	setdef_e1

		moveq.l	#31,d2			counter
setloop1	move.b	(a0)+,d0		get a char to convert
		beq.s	setdef_ok		null -> end of string
		moveq.l	#'^',d1
		cmp.b	d1,d0			if ^ -> ctrl code
		bne.s	setloop2
		move.b	(a0)+,d0		actual ctrl char
		beq.s	setdef_ok
		cmp.b	d1,d0			^^ converted to ^
		beq.s	setloop2
		and.w	#31,d0			convert to ctrl code
setloop2	bsr.s	give_me_raw
		bcs.s	setdef_e2		-> code unknown
		move.b	d0,(a1)+		set raw key code
		move.b	d1,31(a1)		set qualifier
		dbf	d2,setloop1
		lea	STRLONG(pc),a0
setdef_e	printa	a0			print error message
		rts
setdef_ok	move.b	#-1,(a1)		end mark
		rts

setdef_e1	lea	ILLNUM(pc),a0		error messages
		bra.s	setdef_e
setdef_e2	lea	ILLCODE(pc),a0
		bra.s	setdef_e




*************************************************************************
*									*
* Vanilla-to-Rawkey conversion routine.  Doesn't handle dead keys,	*
* however.								*
* The routine first sets the qualifier value to zero and tries all	*
* raw key codes $0...$7f with RawKeyConvert() to find the correct	*
* raw key code.  If it fails it then tries all raw key codes with	*
* different qualifier combinations as specified in the qtab.		*
* If it still fails an error is	returned to the caller.			*
*									*
* This routine is very slow because it may need to call RawKeyConvert()	*
* thousands of times.  However, this way we don't have to include a	*
* conversion table with the program code AND the program uses the	*
* keymap currently selected when doing the conversions.			*
*									*
* Inputs:  d0=vanillakey						*
* Outputs: d0=rawkeycode; d1=qualifier; if (error) -> .C=1		*
*									*
*************************************************************************

give_me_raw	push	d2-d4/a0-a3/a5/a6
		move.b	d0,d4			original vanilla code
		move.l	ievent(a4),a3		InputEvent structure
		lea	buffer(a4),a5		buffer for vanilla code
		clr.l	ie_NextEvent(a3)
		move.b	#IECLASS_RAWKEY,ie_Class(a3)
		clr.b	ie_SubClass(a3)
		clr.l	ie_EventAddress(a3)

		moveq.l	#0,d2			index to qualifier table
gmrlp1		moveq.l	#0,d3			raw key code
gmrlp2		move.w	d3,ie_Code(a3)
		move.w	qtab(pc,d2.w),ie_Qualifier(a3)
		clr.w	(a5)			clear buffer
		move.l	a3,a0			InputEvent*
		move.l	a5,a1			buffer*
		moveq.l	#1,d1			length
		sub.l	a2,a2			use default keymap
		lib	ConsoleDevice,RawKeyConvert
		cmp.b	(a5),d4			check if vanilla found
		beq.s	give_me_raw_ok
		addq.b	#1,d3
		bpl.s	gmrlp2			check all raw codes
		addq.w	#2,d2			try the next qualifier
		move.w	qtab(pc,d2.w),d0	last one?
		bpl.s	gmrlp1

give_me_raw_e	setc				flag: code unknown
		pull	d2-d4/a0-a3/a5/a6
		rts

*Known qualifiers:
qtab		dc.w	0,1,8,16,17,-1	none,lshift,ctrl,lalt,shft+lalt,end

give_me_raw_ok	move.l	d3,d0			raw key code
		move.w	qtab(pc,d2.w),d1	qualifier
		pull	d2-d4/a0-a3/a5/a6
		clrc				flag: code found
		rts



*************************************************************************
*									*
* Routine to list the current function key definitions.			*
*									*
*************************************************************************

listdef		move.l	globport(a4),a5		get messageport address
		move.l	MP_SIZE(a5),a5		pointer to fkey strings
		move.l	ievent(a4),a3		InputEvent structure

		clr.l	ie_NextEvent(a3)
		move.b	#IECLASS_RAWKEY,ie_Class(a3)
		clr.b	ie_SubClass(a3)
		clr.l	ie_EventAddress(a3)

		moveq.l	#0,d2			index to qualifier table
		move.l	#outbuffer,d5		output buffer
listlp1		move.l	d5,a0
		lea	64(a5),a1		addr of next fkey string
		move.l	a1,d4
		move.l	d2,d0
		addq.l	#1,d0
		numlib	sput10
		move.l	a0,a2
		move.b	#' ',(a2)+
listlp2		moveq.l	#0,d0
		move.b	(a5)+,d0
		bmi.s	list_k_ok		-> end of string
		move.w	d0,ie_Code(a3)
		move.b	31(a5),d0
		move.w	d0,ie_Qualifier(a3)
		move.l	a3,a0			InputEvent*
		move.l	a2,a1			buffer*
		moveq.l	#1,d1			length
		move.l	a2,d3
		sub.l	a2,a2			use default keymap
		lib	ConsoleDevice,RawKeyConvert
		move.l	d3,a2
		addq.l	#1,a2
		bra.s	listlp2
list_k_ok	move.b	#10,(a2)+		add LF
		clr.b	(a2)			add NULL
		printa	d5
		move.l	d4,a5
		addq.l	#1,d2
		cmp.w	#20,d2
		blo.s	listlp1
		rts


*************************************************************************
*									*
* Routines to open and close console.device.				*
* getconsbase also sets the console.library pointer.			*
*									*
*************************************************************************

getconsbase	lea	consname(pc),a0		open console and get lib.base
		moveq	#-1,d0			unit
		move.l	ioreq(a4),a1		iorequest
		moveq	#0,d1			flags
		lib	Exec,OpenDevice
		move.l	d0,cderror(a4)
		bne.s	getcons_e
		move.l	ioreq(a4),a0		ioreq
		move.l	IO_DEVICE(a0),_ConsoleDeviceBase(a4)
		beq.s	getcons_e
		clrc
		rts
getcons_e	setc
		rts


closeconsole	move.l	cderror(a4),d0		close console.device
		bne.s	closecons_ok
		move.l	ioreq(a4),a1
		lib	Exec,CloseDevice
closecons_ok	rts


		numlib				;contains get10 subroutine
						;(gets a base-10 number into
						; d0 from (a0))


*************************************************************************
*									*
* ASCII strings								*
*									*
*************************************************************************

consname	dc.b	'console.device',0
portname	dc.b	'FKeyPort',0
INSTALLREQ	dc.b	'Install FKeys first',10,0
ILLNUM		dc.b	'Illegal function key number',10,0
ILLCODE		dc.b	'Illegal character',10,0
STRLONG		dc.b	'String too long',10,0
MESSAGE		dc.b	'KEY 1.02 by Supervisor Software 1989',10,0



*************************************************************************
*									*
* Library names (only dos.library used in this program).		*
*									*
*************************************************************************

		libnames



*************************************************************************
*									*
* Structures defined in bss chunk to make the program file smaller.	*
*									*
*************************************************************************

		section	struct,bss

IORequest	ds.b	IO_SIZE			struct IOStdReq
IEvent		ds.b	ie_SIZEOF		struct InputEvent
outbuffer	ds.b	64			buffer for LIST command

		end

