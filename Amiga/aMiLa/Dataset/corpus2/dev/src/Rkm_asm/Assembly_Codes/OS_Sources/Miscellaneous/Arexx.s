	INCDIR	:Include/

	INCLUDE	exec/funcdef.i
	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/execbase.i
	INCLUDE	intuition/intuition_lib.i
	INCLUDE	misc/john_white.i
	INCLUDE	graphics/graphics_lib.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE rexx/rxslib.i

	INCLUDE	misc/easystart.i

	moveq	#LIB_VER,d0
	lea	exec_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_ExecBase
	beq	exit_quit

	moveq	#LIB_VER,d0
	lea	int_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_IntuitionBase
	beq	exit_closeexec

	moveq	#LIB_VER,d0
	lea	graf_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_GfxBase
	beq	exit_closeint

	moveq	#LIB_VER,d0
	lea	dos_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_DOSBase
	beq	exit_closegfx

	moveq #0,d4			Return/Error Number (0) in d4.

	lea	wndwdefs(pc),a0
	CALLINT	OpenWindow
	move.l	d0,wndwptr
	beq	exit_closedos

	move.l	wndwptr,a0
	CALLINT	ViewPortAddress
	move.l	d0,vpptr

	move.l	wndwptr,a0
	move.l	wd_RPort(a0),a0
	move.l	a0,wndwrp

	move.l	#FILEBUF_SIZE,d0
	move.l	#PUBLICMEM_CLEAR,d1
	CALLEXEC	AllocMem
	move.l	d0,bytebuf
	beq	exit_closewindow

	CALLEXEC	Forbid
	lea	portname(pc),a1
	CALLEXEC	FindPort
	move.l	d0,foundport
	bne	port_exists

new_port

	move.l	#MP_SIZE,d0
	move.l	#PUBLICMEM_CLEAR,d1
	CALLEXEC	AllocMem
	move.l	d0,jwport
	beq	exit_noportmem
	move.l	jwport(pc),a3
	move.l	#0,LN_SUCC(a3)
	move.l	#0,LN_PRED(a3)
	move.b	#NT_MSGPORT,LN_TYPE(a3)
	move.b	#0,LN_PRI(a3)
	lea	portname(pc),a0
	move.l	a0,LN_NAME(a3)
	move.b	#PA_SIGNAL,MP_FLAGS(a3)
	move.l	#0,a1
	CALLEXEC	FindTask
	move.l	d0,a0
	move.l	jwport(pc),a3
	move.l	a0,MP_SIGTASK(a3)
	move.l	#-1,d0
	CALLEXEC	AllocSignal
	move.b	d0,sig
	cmp.l	#-1,d0
	bne	add_port
	CALLEXEC	Permit
	move.l	jwport(pc),a1
	move.l	#MP_SIZE,d0
	CALLEXEC	FreeMem
	bra	exit_freemem

add_port
	move.l	jwport(pc),a3
	move.b	sig,MP_SIGBIT(a3)
	move.l	a3,a1
	CALLEXEC	AddPort
	CALLEXEC	Permit

	bra	mainloop

exit_noportmem
	CALLEXEC	Permit
	bra	exit_closewindow

port_exists
	CALLEXEC	Permit
	move.l	foundport(pc),a3
	move.b	MP_SIGBIT(a3),d0
	cmp.b	#0,d0
	beq	no_foundsignal
	CALLEXEC	FreeSignal

no_foundsignal

	move.l	a3,a1
	CALLEXEC	RemPort
	move.l	a3,a1
	move.l	#MP_SIZE,d0
	CALLEXEC	FreeMem
	bra	new_port

mainloop

	move.w	#16,d0
	move.w	#36,d1
	move.l	wndwrp,a1
	CALLGRAF Move

	clr.l	d1
	move.b	sig,d1
	clr.l	d0
	move.b	#1,d0
	asl.l	d1,d0
	move.b	d0,masksig
	CALLEXEC	Wait

get_msg

	move.l	jwport(pc),a0
	CALLEXEC	GetMsg
	move.l	d0,a1
	move.l	d0,rexx_msg
	beq	no_message

	move.l	rm_Args(a1),rexx_args
	move.l	rm_LibBase(a1),rexx_libbase

	move.l	rexx_args,a0
	lea	quit_stg,a1
	bsr	compare_bytes
	cmp.l	#0,d0
	bne	show_msg
	move.b	#TRUE,quit

show_msg

	move.l	rexx_args,a0
	moveq	#5,d0
	move.l	wndwrp,a1
	CALLGRAF	Text

	move.l	rexx_msg,a1
	move.l	#0,rm_Result1(a1)
	move.l	#0,rm_Result2(a1)

	move.l	rm_Action(a1),d0
	and.l	#RXFF_RESULT,d0
	cmp.l	#RXFF_RESULT,d0
	bne	zero_result

	lea	reply_stg(pc),a0
	move.l	#12,d0
	move.l	rexx_libbase,a6
	jsr	_LVOCreateArgstring(a6)
	move.l	d0,casptr
	beq	cas_error
	move.l	rexx_msg,a1
	move.l	casptr,rm_Result2(a1)

	bra	zero_result

cas_error
	move.l	#0,a0
	CALLINT	DisplayBeep

zero_result

	move.l	rexx_msg,a1
	CALLEXEC	ReplyMsg

	move.l	casptr,a0
	beq	no_cas
	move.l	rexx_libbase,a6
	jsr	_LVODeleteArgstring(a6)

no_cas

	move.b	quit,d0
	cmp.b	#TRUE,d0
	beq	quit_rexx
	bra	get_msg

no_message

	bra	mainloop

quit_rexx

	move.l	#200,d1
	CALLDOS	Delay


exit_message


exit_freeport
	move.l	jwport(pc),a3
	cmp.l	#0,a3
	beq	no_port
	clr.l	d0
	move.b	masksig,d0
	cmp.b	#0,d0
	beq	no_signal
	move.b	MP_SIGBIT(a3),d0
	CALLEXEC	FreeSignal
	move.l	a3,a1
	CALLEXEC	RemPort
	move.l	a3,a1
	move.l	#MP_SIZE,d0
	CALLEXEC	FreeMem

no_port

no_signal


exit_freemem
	move.l	bytebuf(pc),a1
	move.l	#FILEBUF_SIZE,d0
	CALLEXEC	FreeMem

exit_closewindow
	move.l	wndwptr(pc),a0
	CALLINT	CloseWindow

exit_closedos
	move.l	_DOSBase(pc),a1
	CALLEXEC	CloseLibrary

exit_closegfx
	move.l	_GfxBase(pc),a1
	CALLEXEC	CloseLibrary

exit_closeint
	move.l	_IntuitionBase(pc),a1
	CALLEXEC	CloseLibrary

exit_closeexec
	move.l	_ExecBase(pc),a1
	CALLEXEC	CloseLibrary

exit_quit

	move.l	#8000000,d0
	move.l	#CHIPMEM_CLEAR,d1
	CALLEXEC	AllocMem
	move.l	d0,a1
	beq	goodbye
	move.l	#8000000,d0
	CALLEXEC	FreeMem

goodbye
	move.l	d4,d0                   Move return/error number (d4) into d0.
	rts


 * Jump-To Routines.


 * Sub-Routines.

compare_bytes
	move.b	(a0)+,d0
	move.b	(a1)+,d1
	tst.b	d0
	beq	zero_byte
	cmp.b	d1,d0
	beq	compare_bytes

zero_byte
	sub.b	d1,d0
	ext.w	d0
	ext.l	d0
	rts

find_length
	move.l	a0,a1
	clr.l	d0

not_nil
	tst.b	(a1)+
	beq	length_found
	addq.l	#1,d0
	bra	not_nil

length_found
	rts

decimal_to_ascii
	divu	#1000,d1
	bsr	do_value
	divu	#100,d1
	bsr	do_value
	divu	#10,d1
	bsr	do_value

do_value
	add.w	#$30,d1
	move.b	d1,(a0)+
	clr.w	d1
	swap	d1
	rts


 * Object/Module Structures.

wndwdefs
	dc.w	0,0,200,40
	dc.b	0,1
	dc.l	IDCMP_CLOSEWINDOW
	dc.l	WFLG_SMART_REFRESH!WFLG_ACTIVATE!WFLG_CLOSEGADGET!WFLG_DRAGBAR!WFLG_DEPTHGADGET
	dc.l	0,0,0,0,0
	dc.w	0,0,0,0,WBENCHSCREEN


 * Include Variables.

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
_IconBase	dc.l	0
_ExecBase	dc.l	0
int_name	INTNAME
graf_name	GRAFNAME
dos_name	DOSNAME
exec_name
	dc.b	'exec.library',0
	even


 * Intuition Variables.

vpptr	dc.l	0
wndwptr	dc.l	0
wndwrp	dc.l	0
iclass	dc.l	0
icode	dc.w	0
iqual	dc.w	0
iadr	dc.l	0
msex	dc.w	0
msey	dc.w	0


 * Port/Arexx Variables.

jwport		dc.l	0
foundport	dc.l	0
sig		dc.b	0
masksig		dc.b	0
rexx_libbase	dc.l	0
rexx_args	dc.l	0
rexx_msg	dc.l	0
casptr		dc.l	0
quit		dc.b	FALSE
portname
	dc.b	'JWAREXXPORT',0
	even

reply_stg
	dc.b	'Hello Arexx!',0
	even

quit_stg
	dc.b	'Goodbye',0
	even


 * Misc Variables, etc.

ksv		dc.w	0
bytebuf		dc.l	0