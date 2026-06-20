
	INCDIR	WORK:Include/

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	intuition/intuition_lib.i
	INCLUDE	intuition/intuition.i
	INCLUDE	graphics/graphics_lib.i
	INCLUDE	graphics/text.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE	devices/input.i

	INCLUDE	misc/easystart.i

LIB_VER		EQU	37
FILE_SIZE	EQU	100
TRUE		EQU	-1
FALSE		EQU	0

	moveq	#LIB_VER,d0
	lea	int_name(pc),a1
	move.l	4.w,a6
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_IntuitionBase
	beq	exit_quit

	moveq	#LIB_VER,d0
	lea	graf_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_GfxBase
	beq	exit_closeint

	moveq	#LIB_VER,d0
	lea	dos_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_DOSBase
	beq	exit_closegfx

	lea	wndwdefs(pc),a0
	CALLINT	OpenWindow
	move.l	d0,wndwptr
	beq	exit_closedos

	move.l	wndwptr(pc),a0
	CALLINT	ViewPortAddress
	move.l	d0,vpptr

	move.l	wndwptr(pc),a0
	move.l	wd_RPort(a0),a0
	move.l	a0,wndwrp

	moveq	#FILE_SIZE,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	CALLEXEC	AllocMem
	move.l	d0,bytebuf
	beq	exit_closewindow

	CALLGRAF	WaitTOF

mainloop
	move.l	wndwptr(pc),a0
	move.l	wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOGetMsg(a6)
	tst.l	d0
	beq	checkjoystick
	move.l	d0,a1
	move.l	im_Class(a1),iclass
	move.w	im_Code(a1),icode
	move.w	im_Qualifier(a1),iqual
	move.l	im_IAddress(a1),iadr
	move.w	im_MouseX(a1),msex
	move.w	im_MouseY(a1),msey
	jsr	_LVOReplyMsg(a6)

	cmp.l	#IDCMP_VANILLAKEY,iclass
	bne	check_mouse

	cmp.w	#$41,icode
	bne	check_mouse

 * Press A so that the mouse uses the joysick port.

	CALLEXEC	CreateMsgPort
	move.l	d0,mouseport
	beq	exit_closedos
	move.l	d0,a0
	moveq	#IOSTD_SIZE,d0
	CALLEXEC	CreateIORequest
	move.l	d0,mouseio
	beq.s	exit_mouseport
	move.l	d0,a1
	lea	ip_name(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	CALLEXEC	OpenDevice
	tst.l	d0
	bne.s	exit_mouseio

	movea.l	mouseio(pc),a1
	move.w	#IND_SETMPORT,IO_COMMAND(a1)
	move.l	#byte1,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)
	CALLEXEC	DoIO

exit_closedevice
	move.l	mouseio(pc),a1
	CALLEXEC	CloseDevice

exit_mouseio
	move.l	mouseio(pc),a0
	CALLEXEC	DeleteIORequest

exit_mouseport
	move.l	mouseport(pc),a0
	CALLEXEC	DeleteMsgPort


check_mouse

	lea	blankstg(pc),a0

	cmp.l	#IDCMP_MOUSEMOVE,iclass
	move.w	#100,d0
	move.w	#26,d1
	move.l	wndwrp(pc),a1
	CALLGRAF Move

checkm_n
	cmp.w	#0,msex
	bne.s	checkm_e
	cmp.w	#0,msey
	bge.s	checkm_e
	lea	nstg(pc),a0
	bra	print_mdirection

checkm_e
	cmp.w	#0,msex
	ble.s	checkm_s
	cmp.w	#0,msey
	bne.s	checkm_s
	lea	estg(pc),a0
	bra	print_mdirection

checkm_s
	cmp.w	#0,msex
	bne.s	checkm_w
	cmp.w	#0,msey
	ble.s	checkm_w
	lea	sstg(pc),a0
	bra	print_mdirection

checkm_w
	cmp.w	#0,msex
	bge.s	checkm_ne
	cmp.w	#0,msey
	bne.s	checkm_ne
	lea	wstg(pc),a0
	bra.s	print_mdirection

checkm_ne
	cmp.w	#0,msex
	ble.s	checkm_se
	cmp.w	#0,msey
	bge.s	checkm_se
	lea	nestg(pc),a0
	bra.s	print_mdirection

checkm_se
	cmp.w	#0,msex
	ble.s	checkm_sw
	cmp.w	#0,msey
	ble.s	checkm_sw
	lea	sestg(pc),a0
	bra.s	print_mdirection

checkm_sw
	cmp.w	#0,msex
	bge.s	checkm_nw
	cmp.w	#0,msey
	ble.s	checkm_nw
	lea	swstg(pc),a0
	bra.s	print_mdirection

checkm_nw
	cmp.w	#0,msex
	bge.s	unknown_mdirection
	cmp.w	#0,msey
	bge.s	unknown_mdirection
	lea	nwstg(pc),a0
	bra.s	print_mdirection

unknown_mdirection
	lea	unknownstg(pc),a0

print_mdirection
	moveq	#10,d0
	move.l	wndwrp(pc),a1
	CALLGRAF	Text

	cmp.l	#IDCMP_MOUSEBUTTONS,iclass
	bne.s	no_buttons
	move.w	#100,d0
	move.w	#46,d1
	move.l	wndwrp(pc),a1
	CALLGRAF Move
	lea	blankstg(pc),a0
	cmp.w	#SELECTDOWN,icode
	bne.s	checkm_mmb
	lea	lmbstg(pc),a0
	bra.s	print_button

checkm_mmb
	cmp.w	#MIDDLEDOWN,icode
	bne.s	checkm_rmb
	lea	mmbstg(pc),a0
	bra.s	print_button

checkm_rmb
	cmp.w	#MENUDOWN,icode
	bne.s	unknown_button
	lea	rmbstg(pc),a0
	bra.s	print_button

unknown_button
	lea	unknownstg(pc),a0

print_button
	moveq	#10,d0
	move.l	wndwrp(pc),a1
	CALLGRAF	Text

no_buttons

	cmp.l	#IDCMP_CLOSEWINDOW,iclass
	beq	exit_freemem

checkjoystick

	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4

	move.l	#$DFF00A,a1
	move.w	(a1),d1

	move.l	#$DFF00C,a2
	move.w	(a2),d2

	move.l	#$BFE001,a3
	move.b	(a3),d3

	move.w	d2,d4

	move.w	#16,d0
	move.w	#26,d1
	move.l	wndwrp,a1
	CALLGRAF Move
	lea	blankstg(pc),a0

checkj_n
	btst	#1,d4
	bne.s	checkj_ne
	btst	#8,d4
	beq.s	checkj_ne
	btst	#9,d4
	bne.s	checkj_ne
	lea	nstg(pc),a0
	bra	print_jdirection

checkj_ne
	btst	#1,d4
	beq.s	checkj_e
	btst	#8,d4
	beq.s	checkj_e
	btst	#9,d4
	bne.s	checkj_e
	lea	nestg(pc),a0
	bra	print_jdirection

checkj_e
	btst	#0,d4
	beq.s	checkj_se
	btst	#1,d4
	beq.s	checkj_se
	btst	#8,d4
	bne.s	checkj_se
	btst	#9,d4
	bne.s	checkj_se
	lea	estg(pc),a0
	bra.s	print_jdirection

checkj_se
	btst	#0,d4
	bne.s	checkj_s
	btst	#1,d4
	beq.s	checkj_s
	lea	sestg(pc),a0
	bra.s	print_jdirection

checkj_s
	btst	#0,d4
	beq.s	checkj_sw
	btst	#1,d4
	bne.s	checkj_sw
	btst	#9,d4
	bne.s	checkj_sw
	lea	sstg(pc),a0
	bra.s	print_jdirection

checkj_sw
	btst	#0,d4
	beq.s	checkj_w
	btst	#1,d4
	bne.s	checkj_w
	btst	#9,d4
	beq.s	checkj_w
	lea	swstg(pc),a0
	bra.s	print_jdirection

checkj_w
	btst	#0,d4
	bne.s	checkj_nw
	btst	#1,d4
	bne.s	checkj_nw
	btst	#8,d4
	beq.s	checkj_nw
	btst	#9,d4
	beq.s	checkj_nw
	lea	wstg(pc),a0
	bra.s	print_jdirection

checkj_nw
	btst	#8,d4
	bne.s	unknown_jdirection
	btst	#9,d4
	beq.s	unknown_jdirection
	lea	nwstg(pc),a0
	bra.s	print_jdirection

unknown_jdirection
	lea	unknownstg(pc),a0

print_jdirection
	moveq	#10,d0
	move.l	wndwrp(pc),a1
	CALLGRAF	Text

checkj_fire
	move.w	#16,d0
	move.w	#56,d1
	move.l	wndwrp,a1
	CALLGRAF Move
	lea	blankstg(pc),a0
	cmp.b	#124,d3
	bne.s	no_fire
	lea	firestg(pc),a0

no_fire
	moveq	#10,d0
	move.l	wndwrp(pc),a1
	CALLGRAF	Text

	bra	mainloop

exit_message

exit_freemem
	move.l	bytebuf(pc),a1
	moveq	#FILE_SIZE,d0
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

exit_quit
	moveq	#0,d0
	rts


 * Jump-To Routines.


 * Sub-Routines.

decimal_to_ascii
	divu	#1000,d1
	bsr.s	do_value
	divu	#100,d1
	bsr.s	do_value
	divu	#10,d1
	bsr.s	do_value
	nop
do_value
	add.w	#$30,d1
	move.b	d1,(a0)+
	clr.w	d1
	swap	d1
	rts


 * Object/Module Structures.

wndwdefs
	dc.w	0,0,320,100
	dc.b	0,1
	dc.l	IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_DELTAMOVE!IDCMP_MOUSEMOVE!IDCMP_CLOSEWINDOW
	dc.l	WFLG_NOCAREREFRESH!WFLG_SMART_REFRESH!WFLG_REPORTMOUSE!WFLG_RMBTRAP!WFLG_ACTIVATE!WFLG_CLOSEGADGET!WFLG_DRAGBAR!WFLG_DEPTHGADGET
	dc.l	0,0,0,0,0
	dc.w	0,0,0,0,WBENCHSCREEN


 * Long Variables.

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
_IconBase	dc.l	0
vpptr		dc.l	0
wndwptr		dc.l	0
wndwrp		dc.l	0
iclass		dc.l	0
iadr		dc.l	0
mouseport	dc.l	0
mouseio		dc.l	0
bytebuf		dc.l	0


 * Word Variables.

icode		dc.w	0
iqual		dc.w	0
msex		dc.w	0
msey		dc.w	0


 * String Variables.

int_name	dc.b	'intuition.library',0
graf_name	dc.b	'graphics.library',0,0
dos_name	dc.b	'dos.library',0
ip_name		dc.b	'input.device',0,0
blankstg	dc.b	'          ',0,0
firestg		dc.b	'Fire      ',0,0
lmbstg		dc.b	'Left      ',0,0
mmbstg		dc.b	'Middle    ',0,0
rmbstg		dc.b	'Right     ',0,0
unknownstg	dc.b	'          ',0,0
nstg		dc.b	'North     ',0,0
nestg		dc.b	'North East',0,0
estg		dc.b	'East      ',0,0
sestg		dc.b	'South East',0,0
sstg		dc.b	'South     ',0,0
swstg		dc.b	'South West',0,0
wstg		dc.b	'West      ',0,0
nwstg		dc.b	'North West',0,0


 * Buffer Variables.

byte0		dcb.b	1,0
byte1		dcb.b	1,1