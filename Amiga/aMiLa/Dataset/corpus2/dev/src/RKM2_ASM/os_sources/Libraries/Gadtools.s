
	INCDIR	WORK:Include/

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	exec/lists.i
	INCLUDE	intuition/intuition_lib.i
	INCLUDE	intuition/intuition.i
	INCLUDE	graphics/graphics_lib.i
	INCLUDE	graphics/text.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE	workbench/icon_lib.i
	INCLUDE	workbench/startup.i
	INCLUDE	workbench/workbench.i
	INCLUDE	libraries/gadtools_lib.i
	INCLUDE	libraries/gadtools.i

	INCLUDE	misc/easystart.i

LIB_VER		EQU	39
FILE_SIZE	EQU	100
TRUE		EQU	-1
FALSE		EQU	0

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
	beq	exit_closedos

	moveq	#LIB_VER,d0
	lea	gfx_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_GfxBase
	beq	exit_closeint

	moveq	#LIB_VER,d0
	lea	gadtools_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_GadtoolsBase
	beq	exit_closegfx

	moveq	#LIB_VER,d0
	lea	utility_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_UtilityBase
	beq	exit_closegadtools

	moveq	#LIB_VER,d0
	lea	icon_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_IconBase
	beq	exit_closeutility

	lea	list0(pc),a0
	move.l	a0,(a0)				; LH_HEAD(a0)
	addq.l	#4,(a0)				; LH_HEAD(a0)
	clr.l	LH_TAIL(a0)
	move.l	a0,LH_TAILPRED(a0)
	move.b	#NT_UNKNOWN,LH_TYPE(a0)

	lea	node0(pc),a1
	lea	nstg0(pc),a2
	clr.l	(a1)					; LN_SUCC(a1)
	clr.l	LN_PRED(a1)
	move.b	#NT_UNKNOWN,LN_TYPE(a1)
	move.b	#0,LN_PRI(a1)
	move.l	a2,LN_NAME(a1)
	jsr	_LVOAddTail(a6)

	lea	list0(pc),a0
	lea	node1(pc),a1
	lea	nstg1(pc),a2
	clr.l	(a1)					; LN_SUCC(a1)
	clr.l	LN_PRED(a1)
	move.b	#NT_UNKNOWN,LN_TYPE(a1)
	clr.b	LN_PRI(a1)
	move.l	a2,LN_NAME(a1)
	jsr	_LVOAddTail(a6)

	lea	list0(pc),a0
	lea	node2(pc),a1
	lea	nstg2(pc),a2
	clr.l	(a1)					; LN_SUCC(a1)
	clr.l	LN_PRED(a1)
	move.b	#NT_UNKNOWN,LN_TYPE(a1)
	clr.b	LN_PRI(a1)
	move.l	a2,LN_NAME(a1)
	jsr	_LVOAddTail(a6)

	lea	list1(pc),a0
	move.l	a0,(a0)					; LH_HEAD(a0)
	addq.l	#4,(a0)					; LH_HEAD(a0)
	clr.l	LH_TAIL(a0)
	move.l	a0,LH_TAILPRED(a0)
	move.b	#NT_UNKNOWN,LH_TYPE(a0)

	lea	node3(pc),a1
	lea	nstg3(pc),a2
	clr.l	(a1)					; LN_SUCC(a1)
	clr.l	LN_PRED(a1)
	move.b	#NT_UNKNOWN,LN_TYPE(a1)
	clr.b	LN_PRI(a1)
	move.l	a2,LN_NAME(a1)
	jsr	_LVOAddTail(a6)

	lea	list1(pc),a0
	lea	node4(pc),a1
	lea	nstg4(pc),a2
	clr.l	(a1)					; LN_SUCC(a1)
	clr.l	LN_PRED(a1)
	move.b	#NT_UNKNOWN,LN_TYPE(a1)
	clr.b	LN_PRI(a1)
	move.l	a2,LN_NAME(a1)
	jsr	_LVOAddTail(a6)

	lea	list1(pc),a0
	lea	node5(pc),a1
	lea	nstg5(pc),a2
	clr.l	(a1)					; LN_SUCC(a1)
	clr.l	LN_PRED(a1)
	move.b	#NT_UNKNOWN,LN_TYPE(a1)
	clr.b	LN_PRI(a1)
	move.l	a2,LN_NAME(a1)
	jsr	_LVOAddTail(a6)

	suba.l	a0,a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOLockPubScreen(a6)
	move.l	d0,scrnptr
	move.l	d0,wndwscrn
	beq	exit_closeicon

	move.l	scrnptr(pc),a0
	suba.l	a1,a1
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGetVisualInfoA(a6)
	move.l	d0,visptr
	move.l	d0,box0vis
	beq	unlock_pubscreen

	move.l	d0,d5

	lea	menu0defs(pc),a0
	lea	menu0tags(pc),a1
	jsr	_LVOCreateMenusA(a6)
	move.l	d0,menu0ptr
	beq	free_visual

	move.l	d0,a0
	move.l	visptr(pc),a1
	lea	menu0tags(pc),a2
	jsr	_LVOLayoutMenusA(a6)
	tst.l	d0
	beq	free_menustrip

	lea	gadlistptr(pc),a0
	jsr	_LVOCreateContext(a6)
	tst.l	d0
	beq	free_menustrip

	move.l	d0,a0
	moveq	#BUTTON_KIND,d0
	lea	ngdefs0(pc),a1
	move.l	d5,gng_VisualInfo(a1)
	lea	ngtags0(pc),a2
	jsr	_LVOCreateGadgetA(a6)
	move.l	d0,ngptr0
	beq	free_menustrip

	move.l	d0,a0
	moveq	#STRING_KIND,d0
	lea	ngdefs1(pc),a1
	move.l	d5,gng_VisualInfo(a1)
	lea	ngtags1(pc),a2
	jsr	_LVOCreateGadgetA(a6)
	move.l	d0,ngptr1
	beq	free_gadgets

	move.l	d0,a0
	moveq	#CHECKBOX_KIND,d0
	lea	ngdefs2(pc),a1
	move.l	d5,gng_VisualInfo(a1)
	lea	ngtags2(pc),a2
	jsr	_LVOCreateGadgetA(a6)
	move.l	d0,ngptr2
	beq	free_gadgets

	move.l	d0,a0
	moveq	#CYCLE_KIND,d0
	lea	ngdefs3(pc),a1
	move.l	d5,gng_VisualInfo(a1)
	lea	ngtags3(pc),a2
	jsr	_LVOCreateGadgetA(a6)
	move.l	d0,ngptr3
	beq	free_gadgets

	move.l	d0,a0
	moveq	#INTEGER_KIND,d0
	lea	ngdefs4(pc),a1
	move.l	d5,gng_VisualInfo(a1)
	lea	ngtags4(pc),a2
	jsr	_LVOCreateGadgetA(a6)
	move.l	d0,ngptr4
	beq	free_gadgets

	move.l	d0,a0
	moveq	#MX_KIND,d0
	lea	ngdefs5(pc),a1
	move.l	d5,gng_VisualInfo(a1)
	lea	ngtags5(pc),a2
	jsr	_LVOCreateGadgetA(a6)
	move.l	d0,ngptr5
	beq	free_gadgets

	move.l	d0,a0
	moveq	#SLIDER_KIND,d0
	lea	ngdefs6(pc),a1
	move.l	d5,gng_VisualInfo(a1)
	lea	ngtags6(pc),a2
	jsr	_LVOCreateGadgetA(a6)
	move.l	d0,ngptr6
	beq	free_gadgets

	move.l	d0,a0
	moveq	#SCROLLER_KIND,d0
	lea	ngdefs7(pc),a1
	move.l	d5,gng_VisualInfo(a1)
	lea	ngtags7(pc),a2
	jsr	_LVOCreateGadgetA(a6)
	move.l	d0,ngptr7
	beq	free_gadgets

	move.l	d0,a0
	moveq	#TEXT_KIND,d0
	lea	ngdefs8(pc),a1
	move.l	d5,gng_VisualInfo(a1)
	lea	ngtags8(pc),a2
	jsr	_LVOCreateGadgetA(a6)
	move.l	d0,ngptr8
	beq	free_gadgets

	move.l	d0,a0
	moveq	#NUMBER_KIND,d0
	lea	ngdefs9(pc),a1
	move.l	d5,gng_VisualInfo(a1)
	lea	ngtags9(pc),a2
	jsr	_LVOCreateGadgetA(a6)
	move.l	d0,ngptr9
	beq	free_gadgets

	move.l	d0,a0
	moveq	#PALETTE_KIND,d0
	lea	ngdefs10(pc),a1
	move.l	d5,gng_VisualInfo(a1)
	lea	ngtags10(pc),a2
	jsr	_LVOCreateGadgetA(a6)
	move.l	d0,ngptr10
	beq	free_gadgets

	move.l	d0,a0
	moveq	#LISTVIEW_KIND,d0
	lea	ngdefs11(pc),a1
	move.l	d5,gng_VisualInfo(a1)
	lea	ngtags11(pc),a2
	jsr	_LVOCreateGadgetA(a6)
	move.l	d0,ngptr11
	beq	free_gadgets

	move.l	d0,a0
	moveq	#LISTVIEW_KIND,d0
	lea	ngdefs12(pc),a1
	move.l	d5,gng_VisualInfo(a1)
	lea	ngtags12(pc),a2
	jsr	_LVOCreateGadgetA(a6)
	move.l	d0,ngptr12
	beq	free_gadgets

	bsr	unlock_ps
	move.b	#1,scrlock

	suba.l	a0,a0
	lea	wndwtags(pc),a1
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,wndwptr
	beq	free_gadgets

	move.l	d0,a0
	move.l	wd_RPort(a0),wndwrp

	move.l	wndwptr(pc),a0
	move.l	menu0ptr(pc),a1
	jsr	_LVOSetMenuStrip(a6)
	tst.l	d0
	beq	close_window

	move.l	wndwrp(pc),a0
	moveq	#10,d0
	moveq	#16,d1
	move.l	#608,d2
	move.l	#230,d3
	lea	box0tags(pc),a1
	CALLGADTOOLS	DrawBevelBoxA

	CALLGRAF	WaitTOF

	move.l	wndwptr(pc),a0
	suba.l	a1,a1
	CALLGADTOOLS	GT_RefreshWindow

	lea	npmem(pc),a5

mainloop
	move.l	wndwptr(pc),a0
	move.l	wd_UserPort(a0),a0
	CALLEXEC	WaitPort
	move.l	wndwptr(pc),a0
	move.l	wd_UserPort(a0),a0
	CALLGADTOOLS	GT_GetIMsg
	move.l	d0,a1
	move.l	im_Class(a1),iclass
	move.w	im_Code(a1),icode
	move.w	im_Qualifier(a1),iqual
	move.l	im_IAddress(a1),iadr
	move.w	im_MouseX(a1),msex
	move.w	im_MouseY(a1),msey
	CALLGADTOOLS	GT_ReplyIMsg

	cmp.l	#IDCMP_GADGETUP,iclass
	beq	which_gadgetup

	cmp.l	#IDCMP_GADGETDOWN,iclass
	beq	which_gadgetdown

	cmp.l	#IDCMP_VANILLAKEY,iclass
	beq	which_vanillakey

	cmp.l	#IDCMP_RAWKEY,iclass
	beq	which_rawkey

	cmp.l	#IDCMP_MOUSEBUTTONS,iclass
	beq	which_mousebutton

	cmp.l	#IDCMP_MENUPICK,iclass
	beq	which_menu

	cmp.l	#IDCMP_MENUHELP,iclass
	beq	which_menu

	cmp.l	#IDCMP_REFRESHWINDOW,iclass
	beq	refresh_window

	cmp.l	#IDCMP_INACTIVEWINDOW,iclass
	beq	window_inactive

	cmp.l	#IDCMP_ACTIVEWINDOW,iclass
	beq	window_active

	cmp.l	#IDCMP_CLOSEWINDOW,iclass
	beq.s	clear_menustrip

	bra	mainloop


clear_menustrip
	move.l	wndwptr(pc),a0
	CALLINT	ClearMenuStrip

close_window
	move.l	wndwptr(pc),a0
	CALLINT	CloseWindow

free_gadgets
	move.l	gadlistptr(pc),a0
	CALLGADTOOLS	FreeGadgets

free_menustrip
	move.l	menu0ptr(pc),a0
	CALLGADTOOLS	FreeMenus

free_visual
	move.l	visptr(pc),a0
	CALLGADTOOLS	FreeVisualInfo

unlock_pubscreen
	tst.b	scrlock
	bne.s	exit_closeicon
	bsr	unlock_ps

exit_closeicon
	move.l	_IconBase(pc),a1
	CALLEXEC	CloseLibrary

exit_closeutility
	move.l	_UtilityBase(pc),a1
	CALLEXEC	CloseLibrary

exit_closegadtools
	move.l	_GadtoolsBase(pc),a1
	CALLEXEC	CloseLibrary

exit_closegfx
	move.l	_GfxBase(pc),a1
	CALLEXEC	CloseLibrary

exit_closeint
	move.l	_IntuitionBase(pc),a1
	CALLEXEC	CloseLibrary

exit_closedos
	move.l	_DOSBase(pc),a1
	CALLEXEC	CloseLibrary

quit
	clr.b	d2
	lea	npmem(pc),a5

npm_l	addq.b	#1,d2
	cmp.b	#11,d2
	bge.s	npm_end
	move.l	(a5)+,d1
	tst.l	d1
	beq.s	npm_l
	move.l	d1,a1
	moveq	#LN_SIZE,d0
	CALLEXEC	FreeMem
	bra.s	npm_l

npm_end	moveq	#0,d0
	rts


 * Jump-To Routines.

which_gadgetup
	move.l	iadr(pc),a0
	move.w	gg_GadgetID(a0),d0
	tst.b	d0
	beq	do_button
	cmp.b	#1,d0
	beq	do_string
	cmp.b	#2,d0
	beq	do_tick
	cmp.b	#3,d0
	beq	do_cycle
	cmp.b	#4,d0
	beq	do_integer
	cmp.b	#5,d0
	beq	do_mx
	cmp.b	#6,d0
	beq	do_slider
	cmp.b	#7,d0
	beq	do_scroller
	cmp.b	#8,d0
	beq	do_text
	cmp.b	#9,d0
	beq	do_number
	cmp.b	#10,d0
	beq	do_listview
	cmp.b	#11,d0
	beq	do_readlist

	bra	mainloop

which_upid

	bra	mainloop

which_gadgetdown
	move.l	iadr(pc),a0
	move.w	gg_GadgetID(a0),d0
	cmp.b	#5,d0
	beq	do_mx

	bra	mainloop

which_downid

	bra	mainloop

which_vanillakey

	bra	mainloop

which_rawkey

	bra	mainloop

which_brownkey

	bra	mainloop

which_mousebutton

	bra	mainloop

which_menu
	move.w	icode,d0
	cmp.w	#$F800,d0
	beq.s	do_nothing
	cmp.w	#$F820,d0
	beq.s	do_nothing
	cmp.w	#$40,d0
	beq.s	do_nothing
	cmp.w	#$840,d0
	beq.s	do_nothing
	cmp.w	#$F860,d0
	beq.s	do_nothing
	cmp.w	#$F801,d0
	beq.s	do_nothing
	cmp.w	#$F821,d0
	beq.s	do_nothing
	cmp.w	#$F841,d0
	beq.s	do_nothing
	cmp.w	#$F861,d0
	beq.s	do_nothing

	bra	mainloop

do_nothing
	bra	mainloop

do_button

 * Set the slider level to 2.

	move.l	ngptr6(pc),a0
	move.l	wndwptr(pc),a1
	suba.l	a2,a2
	lea	newtags(pc),a3
	move.l	#GTSL_Level,(a3)
	move.l	#2,4(a3)
	move.l	#TAG_DONE,8(a3)
	CALLGADTOOLS	GT_SetGadgetAttrsA

 * Activate the String Gadget.

	move.l	ngptr1(pc),a0
	move.l	wndwptr(pc),a1
	suba.l	a2,a2
	CALLINT	ActivateGadget

	bra	mainloop

do_string
	move.w	#16,d0
	move.w	#26,d1
	move.l	wndwrp(pc),a1
	CALLGRAF Move
	move.l	iadr,a0
	move.l	gg_SpecialInfo(a0),a0
	move.l	(a0),a0				; si_Buffer(a0),a0
	bsr	findlen
	tst.l	d0
	ble.s	string_toosmall
	move.l	wndwrp(pc),a1
	CALLGRAF	Text

string_toosmall

	bra	mainloop

do_tick
	move.w	#16,d0
	move.w	#26,d1
	move.l	wndwrp(pc),a1
	CALLGRAF Move
	addq.b	#1,tick
	tst.b	tick
	beq.s	tick_off
	cmp.b	#1,tick
	beq.s	tick_on
	clr.b	tick

tick_off
	lea	offstg(pc),a0
	moveq	#4,d0
	move.l	wndwrp(pc),a1
	CALLGRAF	Text
	bra.s	tick_end

tick_on
	lea	onstg(pc),a0
	moveq	#4,d0
	move.l	wndwrp(pc),a1
	CALLGRAF	Text

tick_end

	bra	mainloop

do_cycle
	move.w	#16,d0
	move.w	#26,d1
	move.l	wndwrp(pc),a1
	CALLGRAF Move

 * Detach the List from the ListView.

	move.l	ngptr11(pc),a0
	move.l	wndwptr(pc),a1
	suba.l	a2,a2
	lea	newtags(pc),a3
	move.l	#GTLV_Labels,(a3)
	clr.l	4(a3)
	move.l	#TAG_DONE,8(a3)
	CALLGADTOOLS	GT_SetGadgetAttrsA

 * Add a new Node to the end of the list.

	addq.b	#1,cnt
	cmp.b	#11,cnt
	bge.s	node_end
	moveq	#LN_SIZE,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	CALLEXEC	AllocMem
	move.l	d0,nodeptr
	beq.s	no_node
	move.l	d0,(a5)+
	lea	list0,a0
	move.l	nodeptr(pc),a1
	lea	nnstg,a2
	clr.l	(a1)					; LN_SUCC(a1)
	clr.l	LN_PRED(a1)
	move.b	#NT_UNKNOWN,LN_TYPE(a1)
	move.b	#0,LN_PRI(a1)
	move.l	a2,LN_NAME(a1)
	CALLEXEC	AddTail

no_node

node_end


 * Re-attach the List to the ListView.

	move.l	ngptr11(pc),a0
	move.l	wndwptr(pc),a1
	suba.l	a2,a2
	lea	newtags(pc),a3
	lea	list0(pc),a4
	move.l	#GTLV_Labels,(a3)
	move.l	a4,4(a3)
	move.l	#GTLV_Selected,8(a3)
	move.l	#3,12(a3)
	move.l	#TAG_DONE,16(a3)
	CALLGADTOOLS	GT_SetGadgetAttrsA

	bra	mainloop

do_integer
	move.w	#16,d0
	move.w	#26,d1
	move.l	wndwrp(pc),a1
	CALLGRAF Move
	move.l	iadr,a0
	move.l	gg_SpecialInfo(a0),a0
	move.l	(a0),a0					; si_Buffer(a0),a0
	bsr	findlen
	tst.l	d0
	ble.s	number_toosmall
	move.l	wndwrp(pc),a1
	CALLGRAF	Text

number_toosmall

	bra	mainloop

do_mx
	move.w	#16,d0
	move.w	#26,d1
	move.l	wndwrp(pc),a1
	CALLGRAF Move
	move.w	icode(pc),d0
	tst.b	d0
	beq.s	mx0
	cmp.b	#1,d0
	beq.s	mx1
	cmp.b	#2,d0
	beq.s	mx2
	bra.s	mx_end

mx0
	lea	zerostg(pc),a0
	moveq	#4,d0
	move.l	wndwrp(pc),a1
	CALLGRAF	Text
	bra.s	mx_end

mx1
	lea	onestg(pc),a0
	moveq	#4,d0
	move.l	wndwrp(pc),a1
	CALLGRAF	Text
	bra.s	mx_end

mx2
	lea	twostg(pc),a0
	moveq	#4,d0
	move.l	wndwrp(pc),a1
	CALLGRAF	Text

mx_end

	bra	mainloop

do_slider

	bra	mainloop

do_scroller

	bra	mainloop

do_text

	bra	mainloop

do_number

	bra	mainloop

do_palette

	bra	mainloop

do_listview

	bra	mainloop

do_readlist

	bra	mainloop

refresh_window
	bsr.s	begin_refresh

	bsr.s	end_refresh

	bra	mainloop

window_inactive

	bra	mainloop

window_active

	bra	mainloop


 * Sub-Routines.

unlock_ps
	suba.l	a0,a0
	move.l	scrnptr(pc),a1
	CALLINT	UnlockPubScreen
	rts

begin_refresh:
	move.l	wndwptr(pc),a0
	CALLGADTOOLS	GT_BeginRefresh
	rts

end_refresh:
	move.l	wndwptr(pc),a0
	moveq	#-1,d0
	CALLGADTOOLS	GT_EndRefresh
	rts

findlen	move.l	a0,a1
	moveq	#0,d0
not_nil	tst.b	(a1)+
	beq.s	gotlen
	addq.l	#1,d0
	bra.s	not_nil
gotlen	rts


 * Structure Definitions.

font_name
	dc.b	'topaz.font',0
	even

topaz9
	dc.l	font_name
	dc.w	9
	dc.b	FS_NORMAL,FPF_ROMFONT

menu0defs
	dc.b	NM_TITLE,0
	dc.l	mmstg0,0
	dc.w	0
	dc.l	0,0

	dc.b	NM_ITEM,0
	dc.l	mistg0,lkey
	dc.w	0
	dc.l	0,0

	dc.b	NM_ITEM,0
	dc.l	mistg1,skey
	dc.w	0
	dc.l	0,0

	dc.b	NM_ITEM,0
	dc.l	NM_BARLABEL,0
	dc.w	0
	dc.l	0,0

	dc.b	NM_ITEM,0
	dc.l	mistg2,0
	dc.w	0
	dc.l	0,0

	dc.b	NM_SUB,0
	dc.l	sistg0,akey
	dc.w	0
	dc.l	0,0

	dc.b	NM_SUB,0
	dc.l	sistg1,pkey
	dc.w	0
	dc.l	0,0

	dc.b	NM_ITEM,0
	dc.l	NM_BARLABEL,0
	dc.w	0
	dc.l	0,0

	dc.b	NM_ITEM,0
	dc.l	mistg3,qkey
	dc.w	0
	dc.l	0,0

	dc.b	NM_END,0
	dc.l	0,0
	dc.w	0
	dc.l	0,0

menu0tags
	dc.l	GTMN_TextAttr,topaz9
	dc.l	TAG_DONE

wndwtags
	dc.l	WA_Top,0
	dc.l	WA_Left,0
	dc.l	WA_Width,640
	dc.l	WA_Height,256
	dc.l	WA_DetailPen,0
	dc.l	WA_BlockPen,1
	dc.l	WA_IDCMP,IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_MENUPICK!IDCMP_MENUHELP!IDCMP_REFRESHWINDOW!IDCMP_CLOSEWINDOW!IDCMP_INTUITICKS!IDCMP_MOUSEMOVE
	dc.l	WA_Title,wndw_title
	dc.l	WA_Gadgets
gadlistptr
	dc.l	0
	dc.l	WA_Activate,TRUE
	dc.l	WA_CloseGadget,TRUE
	dc.l	WA_DepthGadget,TRUE
	dc.l	WA_DragBar,TRUE
	dc.l	WA_SizeGadget,TRUE
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_SmartRefresh,TRUE
	dc.l	WA_MenuHelp,TRUE
	dc.l	WA_PubScreen
wndwscrn
	dc.l	0
	dc.l	TAG_DONE


 * Long Variables.

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
_IconBase	dc.l	0
_UtilityBase	dc.l	0
_GadtoolsBase	dc.l	0
scrnptr		dc.l	0
vpptr		dc.l	0
wndwptr		dc.l	0
wndwrp		dc.l	0
iclass		dc.l	0
iadr		dc.l	0
visptr		dc.l	0
nodeptr		dc.l	0
menu0ptr	dc.l	0


 * Word Variables.

icode		dc.w	0
iqual		dc.w	0
msex		dc.w	0
msey		dc.w	0


 * Byte Variables.

tick		dc.b	1
cnt		dc.b	0
scrlock		dc.b	0


 * String Variables.

int_name	dc.b	'intuition.library',0
dos_name	dc.b	'dos.library',0
icon_name       dc.b    'icon.library',0,0
gfx_name	dc.b	'graphics.library',0
utility_name	dc.b	'utility.library',0
gadtools_name	dc.b	'gadtools.library',0,0
asl_name	dc.b	'asl.library',0
wndw_title	dc.b	'GadTools.s',0,0
offstg		dc.b	'Off ',0,0
onstg		dc.b	'On  ',0,0
zerostg		dc.b	'Zero',0,0
onestg		dc.b	'One ',0,0
twostg		dc.b	'Two ',0,0
nstg0		dc.b	'Morning',0
nstg1		dc.b	'Afternoon',0
nstg2		dc.b	'Evening',0
nstg3		dc.b	'Zero',0,0
nstg4		dc.b	'One',0
nstg5		dc.b	'Two',0
daytime0	dc.b	'Afternoon',0
nnstg		dc.b	'I Am A New Node',0
mmstg0		dc.b	'PROJECT',0
mistg0		dc.b	'Load',0,0
mistg1		dc.b	'Save',0,0
mistg2		dc.b	'About',0
sistg0		dc.b	'This Program',0,0
sistg1		dc.b	'John White',0,0
mistg3		dc.b	'Quit',0,0
lkey		dc.b	'L',0
skey		dc.b	'S',0
akey		dc.b	'A',0
pkey		dc.b	'P',0
qkey		dc.b	'Q',0


 * Buffer Variables.

list0		dcb.b	LH_SIZE
node0		dcb.b	LN_SIZE
node1		dcb.b	LN_SIZE
node2		dcb.b	LN_SIZE
list1		dcb.b	LH_SIZE
node3		dcb.b	LN_SIZE
node4		dcb.b	LN_SIZE
node5		dcb.b	LN_SIZE
newnode		dcb.b	LN_SIZE
newtags		dcb.b	40
npmem		dcb.b	40


 * GadTool Definitions.

ngdefs0
	dc.w	116,26,100,14
	dc.l	ngtxt0,topaz9
	dc.w	0
	dc.l	PLACETEXT_IN!NG_HIGHLABEL,0
	dc.l	0

ngptr0	dc.l	0
ngtxt0
	dc.b	'_Button',0
	even

ngtags0
	dc.l	GT_Underscore,$0000005F
	dc.l	TAG_DONE

ngdefs1
	dc.w	116,46,100,14
	dc.l	ngtxt1,topaz9
	dc.w	1
	dc.l	PLACETEXT_LEFT!NG_HIGHLABEL,0
	dc.l	0

ngptr1	dc.l	0
ngtxt1
	dc.b	'_String',0
	even

ngtags1
	dc.l	GTST_String,ngstg1
	dc.l	GTST_MaxChars,50
	dc.l	GT_Underscore,$0000005F
	dc.l	TAG_DONE

ngstg1
	dc.b	'Hello',0
	even

ngdefs2
	dc.w	116,66,24,14
	dc.l	ngtxt2,topaz9
	dc.w	2
	dc.l	PLACETEXT_LEFT!NG_HIGHLABEL,0
	dc.l	0

ngptr2	dc.l	0
ngtxt2
	dc.b	'_Tick',0
	even

ngtags2
	dc.l	GTCB_Checked,TRUE
	dc.l	GT_Underscore,$0000005F
	dc.l	TAG_DONE

ngdefs3
	dc.w	116,90,124,14
	dc.l	ngtxt3,topaz9
	dc.w	3
	dc.l	PLACETEXT_LEFT!NG_HIGHLABEL,0
	dc.l	0

ngptr3	dc.l	0
ngtxt3
	dc.b	'_Cycle',0
	even

ngtags3
	dc.l	GTCY_Active,0
	dc.l	GTCY_Labels,cyl_labels
	dc.l	GT_Underscore,$0000005F
	dc.l	TAG_DONE

cl0	dc.b	'Morning',0
cl1	dc.b	'Afternoon',0
cl2	dc.b	'Evening',0

cyl_labels	dc.l	cl0,cl1,cl2,0

ngdefs4
	dc.w	116,116,124,14
	dc.l	ngtxt4,topaz9
	dc.w	4
	dc.l	PLACETEXT_LEFT!NG_HIGHLABEL,0
	dc.l	0

ngptr4	dc.l	0
ngtxt4
	dc.b	'_Integer',0
	even

ngtags4
	dc.l	GTIN_Number,100
	dc.l	GTIN_MaxChars,4
	dc.l	GT_Underscore,$0000005F
	dc.l	TAG_DONE

ngdefs5
	dc.w	336,24,MX_WIDTH,MX_HEIGHT
	dc.l	ngtxt5,topaz9
	dc.w	5
	dc.l	PLACETEXT_LEFT!NG_HIGHLABEL,0
	dc.l	0

ngptr5	dc.l	0
ngtxt5
	dc.b	'_MX',0
	even

ngtags5
	dc.l	GTMX_Active,0
	dc.l	GTMX_Labels,mx_labels
	dc.l	GTMX_Spacing,12
	dc.l	GT_Underscore,$0000005F
	dc.l	TAG_DONE

mx0stg	dc.b	'Top',0
mx1stg	dc.b	'Middle',0
mx2stg	dc.b	'Bottom',0

mx_labels	dc.l	mx0stg,mx1stg,mx2stg,0

ngdefs6
	dc.w	336,84,124,14
	dc.l	ngtxt6,topaz9
	dc.w	6
	dc.l	PLACETEXT_LEFT!NG_HIGHLABEL,0
	dc.l	0

ngptr6	dc.l	0
ngtxt6
	dc.b	'_Slider',0
	even

ngtags6
	dc.l	GTSL_Min,0
	dc.l	GTSL_Max,15
	dc.l	GTSL_Level,12
	dc.l	GTSL_MaxLevelLen,2
	dc.l	GTSL_MaxPixelLen,20
	dc.l	GTSL_LevelPlace,PLACETEXT_RIGHT
	dc.l	GTSL_LevelFormat,slfstg
	dc.l	GT_Underscore,$0000005F
	dc.l	TAG_DONE

slfstg
	dc.b	'%2ld',0
	even

ngdefs7
	dc.w	336,104,200,14
	dc.l	ngtxt7,topaz9
	dc.w	7
	dc.l	PLACETEXT_LEFT!NG_HIGHLABEL,0
	dc.l	0

ngptr7	dc.l	0
ngtxt7
	dc.b	'_Scroller',0
	even

ngtags7
	dc.l	GTSC_Arrows,16
	dc.l	GTSC_Top,0
	dc.l	GTSC_Total,10
	dc.l	GTSC_Visible,2
	dc.l	GT_Underscore,$0000005F
	dc.l	TAG_DONE

ngdefs8
	dc.w	336,124,200,14
	dc.l	ngtxt8,topaz9
	dc.w	8
	dc.l	PLACETEXT_LEFT!NG_HIGHLABEL,0
	dc.l	0

ngptr8	dc.l	0
ngtxt8
	dc.b	'_Text',0
	even

ngtags8
	dc.l	GTTX_Text,ngstg8
	dc.l	GTTX_FrontPen,2
	dc.l	GTTX_BackPen,1
	dc.l	GTTX_Border,TRUE
	dc.l	GT_Underscore,$0000005F
	dc.l	TAG_DONE

ngstg8
	dc.b	'Hello',0
	even

ngdefs9
	dc.w	336,144,200,14
	dc.l	ngtxt9,topaz9
	dc.w	9
	dc.l	PLACETEXT_LEFT!NG_HIGHLABEL,0
	dc.l	0

ngptr9	dc.l	0
ngtxt9
	dc.b	'_Number',0
	even

ngtags9
	dc.l	GTNM_Number,1234
	dc.l	GTNM_MaxNumberLen,4
	dc.l	GTNM_Format,nmfstg9
	dc.l	GTNM_FrontPen,2
	dc.l	GTNM_BackPen,1
	dc.l	GTNM_Border,TRUE
	dc.l	GT_Underscore,$0000005F
	dc.l	TAG_DONE

nmfstg9
	dc.b	'%2ld',0
	even

ngdefs10
	dc.w	336,164,200,14
	dc.l	ngtxt10,topaz9
	dc.w	10
	dc.l	PLACETEXT_LEFT!NG_HIGHLABEL,0
	dc.l	0

ngptr10	dc.l	0
ngtxt10
	dc.b	'_Palette',0
	even

ngtags10
	dc.l	GTPA_Color,0
	dc.l	GTPA_IndicatorHeight,0
	dc.l	GTPA_IndicatorWidth,24
	dc.l	GTPA_Depth,2
	dc.l	GTPA_NumColors,4
	dc.l	GT_Underscore,$0000005F
	dc.l	TAG_DONE

ngdefs11
	dc.w	16,160,180,60
	dc.l	ngtxt11,topaz9
	dc.w	11
	dc.l	PLACETEXT_ABOVE!NG_HIGHLABEL,0
	dc.l	0

ngptr11	dc.l	0
ngtxt11
	dc.b	'_Selectable ListView',0
	even

ngtags11
	dc.l	GTLV_Top,0
	dc.l	GTLV_ScrollWidth,24
	dc.l	GTLV_Selected,1
	dc.l	GTLV_ShowSelected,0
	dc.l	GTLV_Labels,list0
	dc.l	GT_Underscore,$0000005F
	dc.l	TAG_DONE

ngdefs12
	dc.w	400,200,180,40
	dc.l	ngtxt12,topaz9
	dc.w	12
	dc.l	PLACETEXT_ABOVE!NG_HIGHLABEL,0
	dc.l	0

ngptr12	dc.l	0
ngtxt12
	dc.b	'_READ ONLY ListView',0
	even

ngtags12
	dc.l	GTLV_Top,0
	dc.l	GTLV_ScrollWidth,24
	dc.l	GTLV_Selected,2
	dc.l	GTLV_Labels,list1
	dc.l	GTLV_ReadOnly,TRUE
	dc.l	GT_Underscore,$0000005F
	dc.l	TAG_DONE

box0tags
	dc.l	GT_VisualInfo
box0vis
	dc.l	0
	dc.l	GTBB_Recessed,TRUE
	dc.l	TAG_DONE


	SECTION	VERSION,DATA

	dc.b	'$VER: Gadtools.s V1.01 (22.4.2001)',0


	END