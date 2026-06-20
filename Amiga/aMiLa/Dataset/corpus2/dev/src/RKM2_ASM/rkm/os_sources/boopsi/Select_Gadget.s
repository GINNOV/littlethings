
 * This code shows how to set-up some of gadgets from the select.gadget
 * Boopsi Class, aswell as one example of SetGadgetAttrsA() which changes
 * the labels of gadget 2.
 *
 * This code is only a sample of the original SelGadgTest.c code. Really you
 * should read the select.gadget documentation for a better understanding of
 * the Class.
 *
 * select.gadget is (c) Massimo Tantignone, 2001.

	INCDIR	WORK:Include/

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	intuition/intuition_lib.i
	INCLUDE	intuition/intuition.i
	INCLUDE	intuition/gadgetclass.i
	INCLUDE	intuition/icclass.i
	INCLUDE	graphics/graphics_lib.i
	INCLUDE	graphics/text.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE dos/dosextens.i
	INCLUDE	workbench/workbench.i
	INCLUDE	workbench/icon_lib.i
	INCLUDE	workbench/startup.i
	INCLUDE	utility/utility_lib.i
	INCLUDE	utility/utility.i
	INCLUDE	utility/tagitem.i
	INCLUDE libraries/gadtools.i
	INCLUDE misc/select.i

_LVOObtainGSelect	EQU	-30
_LVOInitSelectGadgetA	EQU	-36
_LVOClearSelectGadget	EQU	-42
_LVOSetSGAttrsA		EQU	-48
_LVOGetSGAttrsA		EQU	-54

GA_ReadOnly	EQU	$80030029

LIB_VER		EQU	39
TRUE		EQU	-1
FALSE		EQU	0

	lea	membuf(pc),a4

 * membuf (Memory Buffer) is set-up so that this code can be
 * position-independant. The memory buffer contains the following
 * addresses and their data:
 *
 *   0  Startup Return Message
 *   4  _DOSBase
 *   8  _IntuitionBase
 *  12 _IconBase
 *  16 Old Directory from CurrentDir()
 *  20 Disk Object from GetDiskObject()
 *  24 Argument addresses (30*4)
 * 144 ReadArgs() return value
 * 148 Task address
 * 152 _GfxBase
 * 156 Long Storage
 * 160 _SelectGadgetBase
 * 164
 * 165
 * 166 Memory Buffer (12 bytes)
 * 178 boopsi sg2
 * 182 value 1 (for ToolType/CLI result)
 * 183 value 2 (for ToolType/CLI result)
 * 184 boopsi sg0
 * 188 boopsi sg1
 * 192 iclass
 * 196 icode
 * 198 iqualifier
 * 200 window
 * 204 window rastport
 * 208 screen rastport
 * 212 viewport
 * 216 iaddress
 * 220 mousex
 * 222 mousey
 * 224 _UtilityBase
 * 228 boopsi sg3
 * 232

 * The Startup code below reads two CLI Arguments/WB ToolTypes as an example
 * of how to programme CLI Arguments/WB ToolTypes.
 *
 * Note: The CLI Arguments/WB ToolTypes are done after Startup and Library
 *       opening, so there is no use for the A0 pointer (which contains
 *       pr_CLI).

	suba.l	a1,a1
	move.l	4.w,a6
	jsr	_LVOFindTask(a6)
	tst.l	d0
	beq	exit
	move.l	d0,a5
	move.l	a5,148(a4)
	tst.l	pr_CLI(a5)		; Was this task started from CLI?
	bne.s	_main			; Yes.
	lea	pr_MsgPort(a5),a0	; No. From Workbench.
	jsr	_LVOWaitPort(a6)
	lea	pr_MsgPort(a5),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,(a4)			; D0 = A WBStartup Message.

_main
	moveq	#LIB_VER,d0
        lea     dos_name(pc),a1
	move.l	4.w,a6
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,4(a4)
        beq     quit

        moveq	#LIB_VER,d0
        lea     int_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,8(a4)
        beq     cl_dos

        moveq	#LIB_VER,d0
        lea     gfx_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,152(a4)
        beq     cl_int

        moveq	#LIB_VER,d0
        lea     util_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,224(a4)
        beq     cl_gfx

	moveq	#LIB_VER,d0
        lea     icon_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,12(a4)
        beq     cl_util

        moveq	#0,d0
        lea     class_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,160(a4)
        beq     cl_icon

 * Check the ToolTypes/CLI Arguments.

        move.l	(a4),a0
        tst.l   a0
        beq	fromcli
	move.l	sm_ArgList(a0),a5
        move.l  (a5),d1
	beq	zero_args
	move.l	4(a4),a6
	jsr	_LVOCurrentDir(a6)
        move.l  d0,16(a4)
        move.l	wa_Name(a5),a0
	move.l	12(a4),a6
	jsr	_LVOGetDiskObject(a6)
        move.l  d0,20(a4)
        beq     zero_args
        move.l	d0,a5
        move.l  do_ToolTypes(a5),a5

	move.l	a5,a0
        lea	ftstg0(pc),a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	tt1
	move.l	d0,a3
	move.l	a3,a0
	lea	mtstg0(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto1
	clr.b	182(a4)
	bra.s	tt1
tto1	move.l	a3,a0
	lea	mtstg1(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tt1
	move.b	#1,182(a4)
tt1	move.l	a5,a0
        lea	ftstg1(pc),a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	tt2
	move.l	d0,a3
	move.l	a3,a0
	lea	mtstg2(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto2
	clr.b	183(a4)
	bra.s	tt2
tto2	move.l	a3,a0
	lea	mtstg3(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto3
	move.b	#1,183(a4)
	bra.s	tt2
tto3	move.l	a3,a0
	lea	mtstg4(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto4
	move.b	#2,183(a4)
	bra.s	tt2
tto4	move.l	a3,a0
	lea	mtstg5(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tt2
	move.b	#3,183(a4)
tt2
	nop


free_diskobj
        move.l	20(a4),a0
        jsr	_LVOFreeDiskObject(a6)
	bra	zero_args

fromcli	lea	template(pc),a0
	move.l  a0,d1
        lea	24(a4),a5
        move.l  a5,d2
        moveq	#0,d3
	move.l	4(a4),a6
        jsr	_LVOReadArgs(a6)
        move.l  d0,144(a4)
        beq	zero_args

	move.l	(a5),a0
	lea	mtstg0(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao1
	clr.b	182(a4)
	bra.s	ca1
cao1	move.l	(a5),a0
	lea	mtstg1(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	ca1
	move.b	#1,182(a4)
ca1	move.l	4(a5),a0
	lea	mtstg2(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao2
	clr.b	183(a4)
	bra.s	ca2
cao2	move.l	4(a5),a0
	lea	mtstg3(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao3
	move.b	#1,183(a4)
	bra.s	ca2
cao3	move.l	4(a5),a0
	lea	mtstg4(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao4
	move.b	#2,183(a4)
	bra.s	ca2
cao4	move.l	4(a5),a0
	lea	mtstg5(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	ca2
	move.b	#3,183(a4)
ca2
	nop


free_cliargs
        move.l	144(a4),d1
        jsr	_LVOFreeArgs(a6)

zero_args

	suba.l	a0,a0
	move.l	8(a4),a6
	jsr	_LVOLockPubScreen(a6)
	move.l	d0,200(a4)
	move.l	d0,wndwscrn
	beq	cl_class

	suba.l	a0,a0
	move.l	200(a4),a1
	jsr	_LVOUnlockPubScreen(a6)

	suba.l	a0,a0
	lea	wndwtags(pc),a1
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,200(a4)
	beq	cl_icon

	move.l	d0,a0
	move.l	wd_RPort(a0),204(a4)

	move.l	wndwscrn(pc),a0
	lea	sc_RastPort(a0),a1
	move.l	a1,208(a4)
	lea	sc_ViewPort(a0),a2
	move.l	a2,212(a4)

	jsr	_LVOGetScreenDrawInfo(a6)
	move.l	d0,dri0
	move.l	d0,dri1
	move.l	d0,dri2
	move.l	d0,dri3
	move.l	d0,dri4
	beq	cl_wndw

	suba.l	a0,a0
	lea	sg0_stg(pc),a1
	lea	sg0_tags(pc),a2
	jsr	_LVONewObjectA(a6)
	move.l	d0,184(a4)
	beq	fr_dri
	move.l	d0,prev0

	suba.l	a0,a0
	lea	sg1_stg(pc),a1
	lea	sg1_tags(pc),a2
	jsr	_LVONewObjectA(a6)
	move.l	d0,188(a4)
	beq	fr_sg0
	move.l	d0,prev1

	suba.l	a0,a0
	lea	sg2_stg(pc),a1
	lea	sg2_tags(pc),a2
	jsr	_LVONewObjectA(a6)
	move.l	d0,178(a4)
	beq	fr_sg1
	move.l	d0,prev2

	suba.l	a0,a0
	lea	sg3_stg(pc),a1
	lea	sg3_tags(pc),a2
	jsr	_LVONewObjectA(a6)
	move.l	d0,228(a4)
	beq	fr_sg2
	move.l	d0,prev3

	suba.l	a0,a0
	lea	sg4_stg(pc),a1
	lea	sg4_tags(pc),a2
	jsr	_LVONewObjectA(a6)
	move.l	d0,232(a4)
	beq	fr_sg3
*	move.l	d0,prev4

	move.l	200(a4),a0
	move.l	184(a4),a1
	moveq	#-1,d0
	moveq	#-1,d1
	suba.l	a2,a2
	jsr	_LVOAddGList(a6)

	move.l	184(a4),a0
	move.l	200(a4),a1
	suba.l	a2,a2
	moveq	#-1,d0
	jsr	_LVORefreshGList(a6)

msg_l	move.l	200(a4),a0
	move.l	wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
	move.l	200(a4),a0
	move.l	wd_UserPort(a0),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,a1
	move.l	im_Class(a1),192(a4)
	move.w	im_Code(a1),196(a4)
	move.w	im_Qualifier(a1),198(a4)
	move.l	im_IAddress(a1),216(a4)
	move.w	im_MouseX(a1),220(a4)
	move.w	im_MouseY(a1),222(a4)
	jsr	_LVOReplyMsg(a6)

	cmp.l	#IDCMP_GADGETUP,192(a4)
	beq.s	which_gadgetup

	cmp.l	#IDCMP_GADGETDOWN,192(a4)
	beq	which_gadgetdown

	cmp.l	#IDCMP_VANILLAKEY,192(a4)
	beq	which_vanillakey

	cmp.l	#IDCMP_RAWKEY,192(a4)
	beq	which_rawkey

	cmp.l	#IDCMP_MOUSEBUTTONS,192(a4)
	beq	which_mousebutton

	cmp.l	#IDCMP_CLOSEWINDOW,192(a4)
	beq.s	remove_glist

	bra	msg_l

which_gadgetup
	move.l	216(a4),a0
	move.w	gg_GadgetID(a0),d0
	tst.w	d0
	beq.s	gad_0
	cmp.w	#1,d0
	beq.s	gad_1
	cmp.w	#2,d0
	beq.s	gad_2
	cmp.w	#3,d0
	beq.s	gad_3
	cmp.w	#4,d0
	beq.s	gad_4
	bra	msg_l

gad_0	move.l	188(a4),a0
	move.l	200(a4),a1
	lea	new_tags(pc),a3
	move.l	#SGA_Labels,(a3)
	lea	labels0,a2
	move.l	a2,4(a3)
	move.l	#TAG_END,8(a3)
	suba.l	a2,a2
	move.l	8(a4),a6
	jsr	_LVOSetGadgetAttrsA(a6)		; Change the labels.
	bra	msg_l

gad_1

	bra	msg_l

gad_2

	bra	msg_l

gad_3

	bra	msg_l

gad_4

	bra	msg_l

which_gadgetdown

	bra	msg_l

which_vanillakey

	bra	msg_l

which_rawkey

	bra	msg_l

which_mousebutton

	bra	msg_l


remove_glist
	move.l	200(a4),a0
	move.l	184(a4),a1
	moveq	#-1,d0
	move.l	8(a4),a6
	jsr	_LVORemoveGList(a6)

fr_sg4	move.l	232(a4),a0
	move.l	8(a4),a6
	jsr	_LVODisposeObject(a6)

fr_sg3	move.l	228(a4),a0
	move.l	8(a4),a6
	jsr	_LVODisposeObject(a6)

fr_sg2	move.l	178(a4),a0
	move.l	8(a4),a6
	jsr	_LVODisposeObject(a6)

fr_sg1	move.l	188(a4),a0
	move.l	8(a4),a6
	jsr	_LVODisposeObject(a6)

fr_sg0	move.l	184(a4),a0
	move.l	8(a4),a6
	jsr	_LVODisposeObject(a6)

fr_dri	move.l	wndwscrn(pc),a0
	move.l	dri0(pc),a1
	move.l	8(a4),a6
	jsr	_LVOFreeScreenDrawInfo(a6)

cl_wndw	move.l	200(a4),a0
	move.l	8(a4),a6
	jsr	_LVOCloseWindow(a6)

cl_class
	move.l  160(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_icon	move.l  12(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_util	move.l  224(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_gfx	move.l  152(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_int	move.l  8(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_dos	move.l  4(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

quit	move.l  #8000000,d0
        moveq	#MEMF_CHIP,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.s	cleanup
	move.l	d0,a1
	move.l	#8000000,d0
	jsr	_LVOFreeMem(a6)
cleanup	tst.l	(a4)
	beq.s	exit			; Exit - Task was started from CLI.
	move.l	4.w,a6
	jsr	_LVOForbid(a6)
	move.l	(a4),a1			; Reply to the WB Startup Message and
	jsr	_LVOReplyMsg(a6)	; Exit - Task was started from WB.
exit	moveq	#0,d0
	rts


 * Sub-Routines.

cmpbyte	move.b  (a0)+,d0
        move.b  (a1)+,d1
        tst.b   d0
        beq.s   byte0
        cmp.b   d1,d0
        beq.s   cmpbyte
byte0	sub.b   d1,d0
        ext.w   d0
        ext.l   d0
        rts

findlen	move.l	a0,a1
	moveq	#0,d0
not_nil	tst.b	(a1)+
	beq.s	gotlen
	addq.l	#1,d0
	bra.s	not_nil
gotlen	rts

convert_number
	lea	166(a4),a0
	move.l	d1,d7
	bsr.s	word_to_ascii
	clr.l	(a0)
	rts

word_to_ascii
	move.b	#48,(a0)
	moveq	#0,d1
	move.w	d7,d1
	divu	#1000,d1
	and.l	#$0000FFFF,d1
	divu	#10,d1
	bsr.s	do_val
	bsr.s	do_val
	moveq	#0,d1
	move.w	d7,d1
	divu	#1000,d1
	clr.w	d1
	swap	d1
	divu	#100,d1
	bsr.s	do_val
	divu	#10,d1
	bsr.s	do_val
	bsr.s	do_val
	rts

do_val	add.w	#$30,d1
	move.b	d1,(a0)+
	clr.w	d1
	swap	d1
	rts


 * Structure Definitions.

topaz9
	dc.l	font_name
	dc.w	9
	dc.b	FS_NORMAL,FPF_ROMFONT

wndwtags
	dc.l	WA_Top,0
	dc.l	WA_Left,0
	dc.l	WA_Width,640
	dc.l	WA_Height,160
	dc.l	WA_DetailPen,0
	dc.l	WA_BlockPen,1
	dc.l	WA_Title,wndw_title
	dc.l	WA_IDCMP,IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_CLOSEWINDOW!IDCMP_IDCMPUPDATE
	dc.l	WA_Activate,TRUE
	dc.l	WA_CloseGadget,TRUE
	dc.l	WA_DepthGadget,TRUE
	dc.l	WA_DragBar,TRUE
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_SmartRefresh,TRUE
	dc.l	WA_PubScreen
wndwscrn
	dc.l	0
	dc.l	TAG_DONE

sg0_tags
	dc.l	GA_ID,0
	dc.l	GA_Top,40
	dc.l	GA_Left,20
	dc.l	GA_RelVerify,TRUE
*	dc.l	ICA_MAP,ICSPECIAL_CODE
*	dc.l	ICA_TARGET,ICTARGET_IDCMP
	dc.l	GA_DrawInfo
dri0
	dc.l	0
	dc.l	GA_Text,sg0_txt
	dc.l	SGA_Underscore,$0000005F
	dc.l	SGA_TextPlace,PLACETEXT_ABOVE
	dc.l	SGA_Labels,labels0
	dc.l	SGA_Separator,FALSE
	dc.l	SGA_PopUpDelay,400
	dc.l	SGA_ItemSpacing,2
	dc.l	SGA_FollowMode,SGFM_FULL
	dc.l	SGA_MinTime,200
	dc.l	SGA_MaxTime,200
	dc.l	SGA_PanelMode,SGPM_DIRECT_NB
	dc.l	TAG_END

sg1_tags
	dc.l	GA_ID,1
	dc.l	GA_Previous
prev0
	dc.l	0
	dc.l	GA_Top,40
	dc.l	GA_Left,220
	dc.l	GA_RelVerify,TRUE
*	dc.l	ICA_MAP,ICSPECIAL_CODE
*	dc.l	ICA_TARGET,ICTARGET_IDCMP
	dc.l	GA_DrawInfo
dri1
	dc.l	0
	dc.l	GA_Text,sg1_txt
	dc.l	SGA_Underscore,$0000005F
	dc.l	SGA_Labels,labels1
	dc.l	SGA_PopUpPos,SGPOS_RIGHT
	dc.l	SGA_Quiet,TRUE
	dc.l	SGA_Separator,FALSE
	dc.l	SGA_ReportAll,TRUE
	dc.l	SGA_BorderSize,8
	dc.l	SGA_FullPopUp,TRUE
	dc.l	SGA_PopUpDelay,1
	dc.l	SGA_DropShadow,TRUE
	dc.l	SGA_ListJustify,SGJ_LEFT
	dc.l	TAG_END

sg2_tags
	dc.l	GA_ID,2
	dc.l	GA_Previous
prev1
	dc.l	0
	dc.l	GA_Top,40
	dc.l	GA_Left,460
	dc.l	GA_RelVerify,TRUE
*	dc.l	ICA_MAP,ICSPECIAL_CODE
*	dc.l	ICA_TARGET,ICTARGET_IDCMP
	dc.l	GA_DrawInfo
dri2
	dc.l	0
	dc.l	GA_Text,sg2_txt
	dc.l	SGA_Underscore,$0000005F
	dc.l	SGA_Labels,labels1
	dc.l	SGA_Active,3
	dc.l	SGA_ItemSpacing,4
	dc.l	SGA_SymbolOnly,TRUE
	dc.l	SGA_SymbolWidth,-21
	dc.l	SGA_Sticky,TRUE
	dc.l	SGA_PopUpPos,SGPOS_BELOW
	dc.l	SGA_BorderSize,4
	dc.l	SGA_PopUpDelay,1
	dc.l	SGA_Transparent,TRUE
	dc.l	TAG_END

sg3_tags
	dc.l	GA_ID,3
	dc.l	GA_Previous
prev2
	dc.l	0
	dc.l	GA_Top,100
	dc.l	GA_Left,100
	dc.l	GA_RelVerify,TRUE
*	dc.l	ICA_MAP,ICSPECIAL_CODE
*	dc.l	ICA_TARGET,ICTARGET_IDCMP
	dc.l	GA_DrawInfo
dri3
	dc.l	0
	dc.l	GA_Text,sg3_txt
	dc.l	SGA_Underscore,$0000005F
	dc.l	SGA_Labels,labels1
	dc.l	TAG_END

sg4_tags
	dc.l	GA_ID,4
	dc.l	GA_Previous
prev3
	dc.l	0
	dc.l	GA_Top,100
	dc.l	GA_Left,300
*	dc.l	ICA_MAP,ICSPECIAL_CODE
*	dc.l	ICA_TARGET,ICTARGET_IDCMP
	dc.l	GA_DrawInfo
dri4
	dc.l	0
	dc.l	GA_Text,sg4_txt
	dc.l	GA_ReadOnly,TRUE
	dc.l	TAG_END

labels0	dc.l	opt0,opt1,opt2,opt3,0

labels1	dc.l	opt4,opt5,opt6,opt7,opt8,opt9,0


 * String Variables.

int_name	dc.b	'intuition.library',0
dos_name	dc.b	'dos.library',0
icon_name       dc.b    'icon.library',0,0
gfx_name	dc.b	'graphics.library',0
util_name	dc.b	'utility.library',0
class_name	dc.b	':Classes/Gadgets/select.gadget',0,0
mtstg0		dc.b	'ARG_ONE',0
mtstg1		dc.b	'ARG_TWO',0
mtstg2		dc.b	'ARG_THREE',0
mtstg3		dc.b	'ARG_FOUR',0,0
mtstg4		dc.b	'ARG_FIVE',0,0
mtstg5		dc.b	'ARG_SIX',0
ftstg0          dc.b    'TOOLTYPE_ONE',0,0
ftstg1          dc.b    'TOOLTYPE_TWO',0,0
template	dc.b	'KEYWORD_ONE/K,KEYWORD_TWO/K',0
wndw_title	dc.b	'select_gadget.s',0
font_name	dc.b	'topaz.font',0,0
sg0_stg		dc.b	'selectgclass',0,0
sg1_stg		dc.b	'selectgclass',0,0
sg2_stg		dc.b	'selectgclass',0,0
sg3_stg		dc.b	'selectgclass',0,0
sg4_stg		dc.b	'selectgclass',0,0
opt0		dc.b	'1st Option',0,0
opt1		dc.b	'2nd Option',0,0
opt2		dc.b	'3rd Option',0,0
opt3		dc.b	'4th Option',0,0
opt4		dc.b	'This is an',0,0
opt5		dc.b	'example of',0,0
opt6		dc.b	'my BOOPSI ',0,0
opt7		dc.b	'pop-up    ',0,0
opt8		dc.b	'gadget    ',0,0
opt9		dc.b	'class     ',0,0
sg0_txt		dc.b	'With _delay',0
sg1_txt		dc.b	'Quie_t',0,0
sg2_txt		dc.b	'Sticky b_utton',0,0
sg3_txt		dc.b	'S_imple',0
sg4_txt		dc.b	'Using select.gadget 40.18',0


 * Buffer Variables.

membuf		dcb.b	300,0
new_tags	dcb.b	40


	SECTION	VERSION,DATA

	dc.b	'$VER: Select_Gadget.s V1.01 (22.4.2001)',0


	END