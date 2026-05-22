
 * A few notes:
 *
 * I have kept the code pure - I have not used the Amiga.Lib commodity
 * functions because I am programming in Assembly now and because BLink is
 * old already (1986). I have used the CreateCxObj() function instead of the
 * Amiga.lib macros CxFilter(), CxSender() and CxTranslate().
 *
 * I have not used the CXPOP, HOTKEY etc ToolTypes/CLI Arguments due to
 * Laziness on my part!
 *
 * HotKey: LSHIFT-ALT and F1. See the RKM Libraries Manual, 3rd Edition for
 * more info. Pages 736-737 in particular.
 *
 * Either press the HotKey keys or use one of the Exchange program's buttons
 * to see this commodity in action.

	INCDIR	WORK:Include/

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	intuition/intuition_lib.i
	INCLUDE	intuition/intuition.i
	INCLUDE	graphics/graphics_lib.i
	INCLUDE	graphics/text.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE	workbench/icon_lib.i
	INCLUDE	workbench/startup.i
	INCLUDE	workbench/workbench.i
	INCLUDE	libraries/commodities_lib.i
	INCLUDE	libraries/commodities.i

	INCLUDE	misc/easystart.i

LIB_VER		EQU	39
TRUE		EQU	-1
FALSE		EQU	0
EVT_HOTKEY	EQU	1

	move.l	4.w,a6

	moveq	#LIB_VER,d0
	lea	dos_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_DOSBase
	beq	quit

	moveq	#LIB_VER,d0
	lea	int_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_IntuitionBase
	beq	cl_dos

	moveq	#LIB_VER,d0
	lea	gfx_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_GfxBase
	beq	cl_int

	moveq	#LIB_VER,d0
	lea	cmod_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_CxBase
	beq	cl_gfx

	moveq	#LIB_VER,d0
	lea	icon_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_IconBase
	beq	cl_cx

	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,cxport
	beq	cl_icon

	moveq	#0,d1
	move.l	d0,a0
        move.b	MP_SIGBIT(a0),d1
	moveq	#0,d5
	bset	d1,d5

	moveq	#NewBroker_SIZEOF,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	jsr	_LVOAllocMem(a6)
	move.l	d0,brokermem
	beq	fr_port

	move.l	d0,a0
	move.b	#NB_VERSION,(a0)
	clr.b	nb_Reserve1(a0)
	lea	broker_name(pc),a1
	move.l	a1,nb_Name(a0)
	lea	broker_title(pc),a1
	move.l	a1,nb_Title(a0)
	lea	broker_info(pc),a1
	move.l	a1,nb_Descr(a0)
	move.w	#NBU_UNIQUE!NBU_NOTIFY,nb_Unique(a0)
	move.w	#COF_SHOW_HIDE,nb_Flags(a0)
	clr.b	nb_Pri(a0)
	clr.b	nb_Reserve2(a0)
	move.l	cxport(pc),nb_Port(a0)
	clr.w	nb_ReservedChannel(a0)

	moveq	#0,d0
	move.l	_CxBase(pc),a6
	jsr	_LVOCxBroker(a6)
	move.l	d0,brokerptr
	beq	del_cxobjs
	cmp.l	#CBERR_SYSERR,d0
	beq	sys_err
	cmp.l	#CBERR_DUP,d0
	beq	dup_err
	cmp.l	#CBERR_VERSION,d0
	beq	ver_err

	moveq	#CX_FILTER,d0		; create a Filter object.
	lea	brokerkeys(pc),a0
	suba.l	a1,a1
	jsr	_LVOCreateCxObj(a6)
	move.l	d0,filter
	beq	del_cxobjs

	move.l	brokerptr(pc),a0	; Attach the filter object to the
	move.l	filter(pc),a1		; broker object.
	jsr	_LVOAttachCxObj(a6)	; Call exec's AddTail() function.
	move.l	d0,obj0ptr		; Returns a pointer to the new head
	beq	del_cxobjs		; object in the list of objects.

	moveq	#CX_SEND,d0		; create a Sender object.
	move.l	cxport(pc),a0
	move.w	#EVT_HOTKEY,a1
	jsr	_LVOCreateCxObj(a6)
	move.l	d0,sender
	beq	del_cxobjs

	move.l	filter(pc),a0		; Attach the sender object to the
	move.l	sender(pc),a1		; filter object.
	jsr	_LVOAttachCxObj(a6)
	move.l	d0,obj1ptr
	beq	del_cxobjs

	moveq	#CX_TRANSLATE,d0	; create a Translate object.
	suba.l	a0,a0
	suba.l	a1,a1
	jsr	_LVOCreateCxObj(a6)
	move.l	d0,translate
	beq	del_cxobjs

	move.l	filter(pc),a0		; Attach the translate object to the
	move.l	translate(pc),a1	; filter object.
	jsr	_LVOAttachCxObj(a6)
	move.l	d0,obj2ptr
	beq	del_cxobjs

	move.l	filter(pc),a0		; Check the filter object for errors.
	jsr	_LVOCxObjError(a6)
	tst.l	d0
	beq.s	activate_broker
	cmp.l	#COERR_ISNULL,d0
	beq	in_err
	cmp.l	#COERR_NULLATTACH,d0
	beq	na_err
	cmp.l	#COERR_BADFILTER,d0
	beq	bf_err
	cmp.l	#COERR_BADTYPE,d0
	beq	bt_err
	bra	hmm_err

activate_broker
	move.l	brokerptr,a0
	moveq	#TRUE,d0
	jsr	_LVOActivateCxObj(a6)
	tst.l	d0
	bne	del_cxobjs

	moveq	#0,d6

get_msg
	move.l	d5,d7
*	or.l	d6,d7
	move.l	d7,d0
	move.l	4.w,a6
	jsr	_LVOWait(a6)
	move.l	d0,d1
	and.l	d5,d1
	cmp.l	d5,d1
	beq.s	cx_msg
	move.l	d0,d1
	and.l	d6,d1
	cmp.l	d6,d1
	beq.s	ow_msg
	bra.s	get_msg

ow_msg	move.l	wndwptr(pc),a0
	move.l	wd_UserPort(a0),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,a3
	cmp.l	#IDCMP_CLOSEWINDOW,im_Class(a3)
	beq.s	clw
	bra.s	get_msg
clw	move.l	a3,a1
	jsr	_LVOReplyMsg(a6)
	bsr	close_window
	bra.s	get_msg

cx_msg	move.l	cxport(pc),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,a3
	move.l	a3,a0
	move.l	_CxBase(pc),a6
	jsr	_LVOCxMsgType(a6)
	move.l	d0,msgtype
	beq.s	reply_x
	move.l	a3,a0
	jsr	_LVOCxMsgID(a6)
	move.l	d0,msgid
	beq.s	reply_x
*	move.l	a3,a0
*	jsr	_LVOCxMsgData(a6)   ; only valid for Custom and Sender objs.
*	move.l	d0,msgdata	    ; The data is not valid after ReplMsg().
*	beq.s	reply_x
	move.l	a3,a1
	move.l	4.w,a6
	jsr	_LVOReplyMsg(a6)
	move.l	msgtype,d0
	cmp.l	#CXM_IEVENT,d0
	beq.s	cxm_ie
	cmp.l	#CXM_COMMAND,d0
	beq.s	cxm_cmd
	bra	get_msg
reply_x	move.l	a3,a1
	move.l	4.w,a6
	jsr	_LVOReplyMsg(a6)
	bra	get_msg

cxm_ie	move.l	msgid,d0
	cmp.l	#EVT_HOTKEY,d0
	beq	cx_hotkey
	bra	get_msg

cxm_cmd	move.l	msgid,d0
	cmp.l	#CXCMD_DISABLE,d0
	beq.s	cxcmd_d
	cmp.l	#CXCMD_ENABLE,d0
	beq.s	cxcmd_e
	cmp.l	#CXCMD_KILL,d0
	beq.s	cxcmd_k
	cmp.l	#CXCMD_APPEAR,d0
	beq.s	cxcmd_s
	cmp.l	#CXCMD_DISAPPEAR,d0
	beq.s	cxcmd_h
	cmp.l	#CXCMD_LIST_CHG,d0
	beq.s	cxcmd_l
	cmp.l	#CXCMD_UNIQUE,d0
	beq.s	cxcmd_u
	bra	get_msg

cxcmd_d	move.l	brokerptr(pc),a0
	moveq	#FALSE,d0
	move.l	_CxBase(pc),a6
	jsr	_LVOActivateCxObj(a6)
	bra	get_msg

cxcmd_e	move.l	brokerptr(pc),a0
	moveq	#TRUE,d0
	move.l	_CxBase(pc),a6
	jsr	_LVOActivateCxObj(a6)
	bra	get_msg

cxcmd_k

 * You should end this program.

	bra.s	cmod_end

cxcmd_s

	bsr	open_window
	tst.b	opened
	beq.s	cmod_end
	bra	get_msg

cxcmd_h

	bsr	close_window

	bra	get_msg

cxcmd_u

 * Someone else has this Unique name, so I cannot use it.

	bra.s	cmod_end

cxcmd_l

 * Someone changed the broker list.

	bra.s	cmod_end

cx_hotkey
	bsr	open_window
	tst.b	opened
	beq.s	cmod_end
	bra	get_msg


hmm

 * You should not be here if your cx_msg is ok.

cmod_end
	bsr	close_window
	bra.s	del_cxobjs

in_err

	bra.s	del_cxobjs

na_err

	bra.s	del_cxobjs

bf_err

	bra.s	del_cxobjs

bt_err

	bra.s	del_cxobjs

hmm_err

	nop

del_cxobjs
	move.l	brokerptr(pc),a0
	move.l	_CxBase(pc),a6
	jsr	_LVODeleteCxObjAll(a6)
	bra.s	free_brokermem

sys_err

	bra.s	free_brokermem

dup_err

	bra.s	free_brokermem

ver_err

	bra.s	free_brokermem

unknown_err

	nop

free_brokermem
	move.l	brokermem(pc),a1
	moveq	#NewBroker_SIZEOF,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

fr_port	move.l	cxport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)

cl_icon	move.l	_IconBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

cl_cx	move.l	_CxBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

cl_gfx	move.l	_GfxBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

cl_int	move.l	_IntuitionBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

cl_dos	move.l	_DOSBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

quit	moveq	#0,d0
	rts


 * Sub-Routines.

open_window
	tst.b	opened
	bne.s	ow_end
	lea	wndwdefs(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOOpenWindow(a6)
	move.l	d0,wndwptr
	beq.s	ow_end
	move.b	#1,opened
	moveq	#0,d1
	move.l	d0,a0
	move.l	wd_UserPort(a0),a0
        move.b	MP_SIGBIT(a0),d1
	moveq	#0,d6
	bset	d1,d6
ow_end	rts

close_window
	tst.b	opened
	beq.s	cw_end
	move.l	wndwptr(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOCloseWindow(a6)
	move.b	#0,opened
	moveq	#0,d6
cw_end	rts


 * Structure Definitions.

wndwdefs
	dc.w	0,14,320,100
	dc.b	0,1
	dc.l	IDCMP_CLOSEWINDOW
	dc.l	WFLG_SMART_REFRESH!WFLG_ACTIVATE!WFLG_CLOSEGADGET!WFLG_DRAGBAR!WFLG_DEPTHGADGET
	dc.l	0,0,wndw_title,0,0
	dc.w	0,0,0,0,WBENCHSCREEN
	dc.l	0


 * Long Variables.

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
_IconBase	dc.l	0
_CxBase		dc.l	0
cxport		dc.l	0
obj0ptr		dc.l	0
obj1ptr		dc.l	0
obj2ptr		dc.l	0
brokerptr	dc.l	0
brokermem	dc.l	0
filter		dc.l	0
sender		dc.l	0
translate	dc.l	0
msgid		dc.l	0
msgtype		dc.l	0
msgdata		dc.l	0
wndwptr		dc.l	0


 * Byte Variables.

opened		dc.b	0


 * String Variables.

int_name	dc.b	'intuition.library',0
dos_name	dc.b	'dos.library',0
icon_name       dc.b    'icon.library',0,0
gfx_name	dc.b	'graphics.library',0
cmod_name	dc.b	'commodities.library',0
brokerkeys	dc.b	'rawkey lshift alt f1',0,0
broker_name	dc.b	'JW HotKey Commodity',0		    ; 24 length max.
broker_title	dc.b	'HotKey: LSHIFT-ALT and F1.',0,0    ; 40 length max.
broker_info	dc.b	'A Window Opens.',0		    ; 40 length max.
wndw_title	dc.b	'Commodity Window.',0


	SECTION	VERSION,DATA

	dc.b	'$VER: HotKey_Commodity.s V1.01 (22.4.2001)',0


	END