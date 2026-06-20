
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
	INCLUDE	libraries/gadtools_lib.i
	INCLUDE	libraries/gadtools.i

	INCLUDE	misc/easystart.i

LIB_VER		EQU	39
TRUE		EQU	-1
FALSE		EQU	0
FILE_SIZE	EQU	100

	moveq	#LIB_VER,d0
	lea	dos_name(pc),a1
	move.l	4.w,a6
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_DOSBase
	beq	exit_quit

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
	lea	gt_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_GadtoolsBase
	beq	exit_closegfx

	moveq	#LIB_VER,d0
	lea	icon_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_IconBase
	beq	exit_closegadtools

	suba.l	a0,a0
	CALLINT	LockPubScreen
	move.l	d0,scrnptr
	beq	exit_closeicon

	move.l	scrnptr(pc),a0
	suba.l	a1,a1
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGetVisualInfoA(a6)
	move.l	d0,vis
	beq	unlock_pubscreen

	lea	newmenu0(pc),a0
	lea	newmenu0tags(pc),a1
	jsr	_LVOCreateMenusA(a6)
	move.l	d0,menustrip
	beq	free_visual

	move.l	d0,a0
	move.l	vis(pc),a1
	lea	newmenu0tags(pc),a2
	jsr	_LVOLayoutMenusA(a6)
	tst.l	d0
	beq	free_menustrip

	bsr	unlock_ps
	move.b	#1,scrlock

	lea	wndwdefs(pc),a0
	CALLINT	OpenWindow
	move.l	d0,wndwptr
	beq	free_menustrip

	move.l	wndwptr,a0
	move.l	wd_RPort(a0),wndwrp

	move.l	wndwptr(pc),a0
	move.l	menustrip(pc),a1
	CALLINT	SetMenuStrip
	tst.l	d0
	beq	close_window

	CALLGRAF	WaitTOF

	move.l	wndwptr(pc),a0
	suba.l	a1,a1
	CALLGADTOOLS	GT_RefreshWindow

mainloop
	move.l	wndwptr(pc),a0
	move.l	wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
	move.l	wndwptr(pc),a0
	move.l	wd_UserPort(a0),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_GetIMsg(a6)
	move.l	d0,a1
	move.l	im_Class(a1),iclass
	move.w	im_Code(a1),icode
	move.w	im_Qualifier(a1),iqual
	move.l	im_IAddress(a1),iadr
	move.w	im_MouseX(a1),msex
	move.w	im_MouseY(a1),msey
	jsr	_LVOGT_ReplyIMsg(a6)

	move.l	iclass,d0

	cmp.l	#IDCMP_GADGETUP,d0
	beq	which_gadgetup

	cmp.l	#IDCMP_GADGETDOWN,d0
	beq	which_gadgetdown

	cmp.l	#IDCMP_VANILLAKEY,d0
	beq	which_vanillakey

	cmp.l	#IDCMP_RAWKEY,d0
	beq	which_rawkey

	cmp.l	#IDCMP_MOUSEBUTTONS,d0
	beq	which_mousebutton

	cmp.l	#IDCMP_MENUPICK,d0
	beq	which_menu

	cmp.l	#IDCMP_MENUHELP,d0
	beq	which_menu

	cmp.l	#IDCMP_REFRESHWINDOW,d0
	beq	refresh_window

	cmp.l	#IDCMP_INACTIVEWINDOW,d0
	beq	window_inactive

	cmp.l	#IDCMP_ACTIVEWINDOW,d0
	beq	window_active

	cmp.l	#IDCMP_CLOSEWINDOW,d0
	beq.s	clear_menustrip

	bra	mainloop

clear_menustrip
	move.l	wndwptr(pc),a0
	CALLINT	ClearMenuStrip

close_window
	move.l	wndwptr(pc),a0
	CALLINT	CloseWindow

free_menustrip
	move.l	menustrip,a0
	CALLGADTOOLS	FreeMenus

free_visual
	move.l	vis(pc),a0
	CALLGADTOOLS	FreeVisualInfo

unlock_pubscreen
	tst.b	scrlock
	bne.s	exit_closeicon
	bsr	unlock_ps

exit_closeicon
	move.l	_IconBase(pc),a1
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

exit_quit
	moveq	#0,d0
	rts


 * Jump-To Routines.

which_gadgetup

	bra	mainloop

which_upid

	bra	mainloop

which_gadgetdown

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

 * Menu numbers are 16 bits.
 *
 * Bits 0-4   = menu number (on the title bar).
 * Bits 5-10  = menu-item number.
 * Bits 11-15 = sub-item number.
 *
 * The bits are given the following values:
 *
 * Bits 15-11      Bits 10-5       Bits 4-0
 *
 * 16 8 4 2 1    32 16 8 4 2 1    16 8 4 2 1
 *
 * Any bits pairs (15-11, 10-5 and 4-0) that have all their bits set is
 * classed as no selection (no number) for that menu/menu-item/sub-item.
 * So. F8 (bits 15-11 set) below means no sub-item.

which_menu
	move.w	icode,d0
	cmp.w	#$F800,d0	; 11111 000000 00000
	beq.s	do_nothing
	cmp.w	#$F820,d0	; 11111 000001 00000
	beq.s	do_nothing
	cmp.w	#$0040,d0	; 00000 000010 00000
	beq.s	do_nothing
	cmp.w	#$0840,d0	; 00001 000010 00000
	beq.s	do_nothing
	cmp.w	#$F8A0,d0	; 11111 000110 00000
	beq	clear_menustrip
	bra	mainloop

do_nothing
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

begin_refresh
	move.l	wndwptr,a0
	CALLGADTOOLS	GT_BeginRefresh
	rts

end_refresh
	move.l	wndwptr,a0
	moveq	#-1,d0
	CALLGADTOOLS	GT_EndRefresh
	rts


 * Structure Definitions.

newmenu0
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

topaz9
	dc.l	font_name
	dc.w	9
	dc.b	FS_NORMAL,FPF_ROMFONT

newmenu0tags
	dc.l	GTMN_TextAttr,topaz9
	dc.l	0

wndwtags
	dc.l	WA_MenuHelp,TRUE
	dc.l	0

wndwdefs
	dc.w	0,14,640,200
	dc.b	0,1
	dc.l	IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_CLOSEWINDOW!IDCMP_MENUPICK!IDCMP_MENUHELP!IDCMP_REFRESHWINDOW!IDCMP_NEWSIZE!IDCMP_SIZEVERIFY!IDCMP_INACTIVEWINDOW!IDCMP_ACTIVEWINDOW
	dc.l	WFLG_NW_EXTENDED!WFLG_SIMPLE_REFRESH!WFLG_SIZEGADGET!WFLG_SIZEBBOTTOM!WFLG_ACTIVATE!WFLG_CLOSEGADGET!WFLG_DRAGBAR!WFLG_DEPTHGADGET
	dc.l	0,0,wndw_title,0,0
	dc.w	320,100,640,200,WBENCHSCREEN
	dc.l	wndwtags


 * Long Variables.

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
_IconBase	dc.l	0
_UtilityBase	dc.l	0
_GadtoolsBase	dc.l	0
scrnptr		dc.l	0
vpptr		dc.l	0
cmptr		dc.l	0
wndwptr		dc.l	0
wndwrp		dc.l	0
iclass		dc.l	0
iadr		dc.l	0
vis		dc.l	0
glistptr	dc.l	0
menustrip	dc.l	0


 * Word Variables.

icode		dc.w	0
iqual		dc.w	0
msex		dc.w	0
msey		dc.w	0

 * Byte Variables.

scrlock		dc.b	0


 * String Variables.

int_name	dc.b	'intuition.library',0
dos_name	dc.b	'dos.library',0
icon_name       dc.b    'icon.library',0,0
gfx_name	dc.b	'graphics.library',0
diskfont_name	dc.b	'diskfont.library',0,0
gt_name		dc.b	'gadtools.library',0,0
wndw_title	dc.b	'Gadtools_Menu.s',0
font_name	dc.b	'topaz.font',0,0
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


	SECTION	VERSION,DATA

	dc.b	'$VER: Gadtools_Menu.s V1.01 (22.4.2001)',0


	END
