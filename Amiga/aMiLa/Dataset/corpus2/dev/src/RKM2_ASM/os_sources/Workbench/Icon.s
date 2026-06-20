
	INCDIR	WORK:Include/

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	intuition/intuition_lib.i
	INCLUDE	intuition/intuition.i
	INCLUDE	graphics/graphics_lib.i
	INCLUDE	graphics/text.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE dos/dosextens.i
	INCLUDE dos/dostags.i
	INCLUDE	workbench/workbench.i
	INCLUDE	workbench/icon_lib.i
	INCLUDE	workbench/startup.i

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
 * 156 file handle
 * 160 icon pointer
 * 164
 * 165
 * 166 Memory Buffer (12 bytes)
 * 178 disk object
 * 182 value 1 (for ToolType/CLI result)
 * 183 value 2 (for ToolType/CLI result)
 * 184 old deftool
 * 188 old ttypes
 * 192

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
        lea     icon_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,12(a4)
        beq     cl_gfx

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

 * Allocate a disk object and fill it in with your values.

	moveq	#do_SIZEOF,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,178(a4)
	beq	cl_icon

	move.l	d0,a1
	move.w	#WB_DISKMAGIC,(a1)			; do_Magic(a1)
	move.w	#WB_DISKVERSION,do_Version(a1)
	move.b	#WBPROJECT,do_Type(a1)
	clr.b	do_PAD_BYTE(a1)
	lea	tool_name(pc),a0
	move.l	a0,do_DefaultTool(a1)
	lea	tooltypes(pc),a0
	move.l	a0,do_ToolTypes(a1)
	move.l	#NO_ICON_POSITION,do_CurrentX(a1)
	move.l	#NO_ICON_POSITION,do_CurrentY(a1)
	clr.l	do_DrawerData(a1)
	clr.l	do_ToolWindow(a1)
	move.l	#4000,do_StackSize(a1)

	lea	gad0(pc),a0
	addq.l	#4,a1
	moveq	#gg_SIZEOF,d0
	jsr	_LVOCopyMem(a6)

 * Save a text file.

	lea	file_name(pc),a0
	move.l	a0,d1
	move.l	#MODE_NEWFILE,d2
	move.l	4(a4),a6
	jsr	_LVOOpen(a6)
	move.l	d0,156(a4)
	beq	fr_obj

	move.l	d0,d1
	lea	file_text(pc),a0
	move.l	a0,d2
	moveq	#34,d3
	jsr	_LVOWrite(a6)
	cmp.l	#34,d0
	bne.s	cl_file

 * Load the file's icon, if it has one?.

	lea	path_name(pc),a0
	move.l	12(a4),a6
	jsr	_LVOGetDiskObject(a6)
	move.l	d0,160(a4)
	beq.s	use_defaulticon

 * Save the current (old) values and use our (new) values, before saving the
 * icon.

	move.l	d0,a1
	move.l	do_DefaultTool(a1),184(a4)
	move.l	do_ToolTypes(a1),188(a4)
	lea	tool_name(pc),a0
	move.l	a0,do_DefaultTool(a1)
	lea	tooltypes(pc),a0
	move.l	a0,do_ToolTypes(a1)
	lea	path_name(pc),a0
	jsr	_LVOPutDiskObject(a6)
	cmp.l	#TRUE,d0
	beq.s	fr_imem		

	nop

 * Free the icon memory.

fr_imem	move.l	160(a4),a0
	move.l	184(a4),do_DefaultTool(a0)
	move.l	188(a4),do_ToolTypes(a0)
	jsr	_LVOFreeDiskObject(a6)
	bra.s	cl_file

use_defaulticon

 * The file did not have an icon, so save our default icon instead.

	move.l	178(a4),a1
	lea	path_name(pc),a0
	jsr	_LVOPutDiskObject(a6)
	tst.l	d0
	cmp.l	#TRUE,d0
	beq.s	cl_file

	nop


cl_file	move.l	156(a4),d1
	move.l	4(a4),a6
	jsr	_LVOClose(a6)

fr_obj	move.l	178(a4),a1
	moveq	#do_SIZEOF,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

cl_icon	move.l  12(a4),a1
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

gi0
	dc.w	0,0,52,22,2
	dc.l	gd0
	dc.b	3,0
	dc.l	0

gad0
	dc.l	0
	dc.w	97,12,52,23,GFLG_GADGIMAGE!GFLG_GADGHBOX,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	gi0,0,0,0,0
	dc.w	0
        dc.l	0


 * String Variables.

int_name	dc.b	'intuition.library',0
dos_name	dc.b	'dos.library',0
icon_name       dc.b    'icon.library',0,0
gfx_name	dc.b	'graphics.library',0
mtstg0		dc.b	'ARG_ONE',0
mtstg1		dc.b	'ARG_TWO',0
mtstg2		dc.b	'ARG_THREE',0
mtstg3		dc.b	'ARG_FOUR',0,0
mtstg4		dc.b	'ARG_FIVE',0,0
mtstg5		dc.b	'ARG_SIX',0
ftstg0          dc.b    'TOOLTYPE_ONE',0,0
ftstg1          dc.b    'TOOLTYPE_TWO',0,0
template	dc.b	'KEYWORD_ONE/K,KEYWORD_TWO/K',0
path_name	dc.b	'Ram:Icon_Example',0,0
tool_name	dc.b	'C:PPMore',0,0
ttype0		dc.b	'FILETYPE=Text',0
ttype1		dc.b	'FLAGS=BOLD|ITALIC',0
file_name	dc.b	'Ram:Icon_Example',0,0
file_text	dc.b	'This is a Text File for this icon.',0,0

tooltypes	dc.l	ttype0,ttype1,0


 * Buffer Variables.

membuf		dcb.b	300,0


	SECTION	GFX,DATA_C

gd0
	dc.w	$0000,$0000,$0000,$1000,$0000,$0000,$0000,$3000
	dc.w    $0FFF,$FFFC,$0000,$3000,$0800,$0004,$0000,$3000
	dc.w    $0800,$07FF,$FFC0,$3000,$08A8,$A400,$00A0,$3000
	dc.w    $0800,$0400,$0090,$3000,$08AA,$A400,$0088,$3000
	dc.w    $0800,$042A,$A0FC,$3000,$082A,$A400,$0002,$3000
	dc.w    $0800,$0400,$0002,$3000,$0800,$A42A,$A0A2,$3000
	dc.w    $0800,$0400,$0002,$3000,$0950,$A42A,$8AA2,$3000
	dc.w    $0800,$0400,$0002,$3000,$082A,$A400,$0002,$3000
	dc.w    $0800,$042A,$2AA2,$3000,$0FFF,$FC00,$0002,$3000
	dc.w    $0000,$0400,$0002,$3000,$0000,$07FF,$FFFE,$3000
	dc.w    $0000,$0000,$0000,$3000,$7FFF,$FFFF,$FFFF,$F000

	dc.w    $FFFF,$FFFF,$FFFF,$E000,$D555,$5555,$5555,$4000
	dc.w    $D000,$0001,$5555,$4000,$D7FF,$FFF9,$5555,$4000
	dc.w    $D7FF,$F800,$0015,$4000,$D757,$5BFF,$FF55,$4000
	dc.w    $D7FF,$FBFF,$FF65,$4000,$D755,$5BFF,$FF75,$4000
	dc.w    $D7FF,$FBD5,$5F01,$4000,$D7D5,$5BFF,$FFFD,$4000
	dc.w    $D7FF,$FBFF,$FFFD,$4000,$D7FF,$5BD5,$5F5D,$4000
	dc.w    $D7FF,$FBFF,$FFFD,$4000,$D6AF,$5BD5,$755D,$4000
	dc.w    $D7FF,$FBFF,$FFFD,$4000,$D7D5,$5BFF,$FFFD,$4000
	dc.w    $D7FF,$FBD5,$D55D,$4000,$D000,$03FF,$FFFD,$4000
	dc.w    $D555,$53FF,$FFFD,$4000,$D555,$5000,$0001,$4000
	dc.w    $D555,$5555,$5555,$4000,$8000,$0000,$0000,$0000


	SECTION	VERSION,DATA

	dc.b	'$VER: Icon.s V1.01 (22.4.2001)',0


	END