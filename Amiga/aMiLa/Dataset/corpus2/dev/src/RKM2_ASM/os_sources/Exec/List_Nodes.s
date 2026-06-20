
 * This code shows how to initialise and use one empty List and three
 * empty Nodes. When they are initialised you get Morning - Afternoon and
 * Evening in the list. The list is then checked to see if it is empty (this
 * is to show you how you determine an empty list - I have filled it of
 * course). `Afternoon' is then searched for via FindName() and Aternoon's
 * node name is displayed (to show you how to use FindName() only - the node
 * name will be `Afternoon' of course, as that is what has been searched for)
 * FindName() returns the node structure. Thus you can get the found node's
 * Priority for example. I have only showed you the important steps of
 * initialising a list and nodes, but you should read an amiga book about
 * the other list and node commands. The list.i and node.i includes have
 * Macros in them for checking against empty lists, etc.

	INCDIR	WORK:Include/

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	intuition/intuition_lib.i
	INCLUDE	intuition/intuition.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE dos/dosextens.i
	INCLUDE	workbench/icon_lib.i
	INCLUDE	workbench/startup.i
	INCLUDE	workbench/workbench.i

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
 * 156
 * 160
 * 164
 * 165
 * 166 Memory Buffer (12 bytes)
 * 178 Con: file
 * 182 value 1 (for ToolType/CLI result)
 * 183 value 2 (for ToolType/CLI result)
 * 184 list
 * 188 node0
 * 192 node1
 * 196 node2
 * 200

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

 * Open a console window.

	move.l	#MODE_NEWFILE,d2
	lea	cname(pc),a0
	move.l	a0,d1
	move.l	4(a4),a6
	jsr	_LVOOpen(a6)
	move.l	d0,178(a4)
	beq	cl_icon

	moveq	#LH_SIZE,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,184(a4)
	beq	cl_conf

	moveq	#LN_SIZE,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	jsr	_LVOAllocMem(a6)
	move.l	d0,188(a4)
	beq	fr_list

	moveq	#LN_SIZE,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	jsr	_LVOAllocMem(a6)
	move.l	d0,192(a4)
	beq	fr_n0

	moveq	#LN_SIZE,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	jsr	_LVOAllocMem(a6)
	move.l	d0,196(a4)
	beq	fr_n1

 * Create an empty List.

	move.l	184(a4),a0		; Put list0 address into a0.
	move.l	a0,(a0)			; Put list0 address into LH_HEAD.
	addq.l	#4,(a0)			; LH_HEAD now points to LH_TAIL.
	clr.l	LH_TAIL(a0)		; LH_TAIL is always 0.
	move.l	a0,LH_TAILPRED(a0)	; Put list0 address into LH_TAILPRED.
	clr.b	LH_TYPE(a0)		; Set LH_TYPE to NT_UNKNOWN (0).

 * Add some Nodes to the List.

	move.l	184(a4),a0		; Put list0 address into a0.
	move.l	188(a4),a1		; Put node0 address into a1.
	lea	morning(pc),a2		; Put the string to add to list in a2
	clr.l	(a1)			; Initialise LN_SUCC, to 0.
	clr.l	LN_PRED(a1)		; Initialise LN_PRED, to 0.
	clr.b	LN_TYPE(a1)		; Initialise LN_TYPE, to NT_UNKNOWN.
	clr.b	LN_PRI(a1)		; Initialise LN_PRI, to 0.
	move.l	a2,LN_NAME(a1)		; Initialise LN_NAME, to "Morning".
	jsr	_LVOAddTail(a6)		; Add node0 to the end of the list.

	move.l	184(a4),a0		; Put list0 address into a0.
	move.l	192(a4),a1		; Put node1 address into a1.
	lea	afternoon(pc),a2		; Put the string to add to list in a2
	clr.l	(a1)			; Initialise LN_SUCC, to 0.
	clr.l	LN_PRED(a1)		; Initialise LN_PRED, to 0.
	clr.b	LN_TYPE(a1)		; Initialise LN_TYPE, to NT_UNKNOWN.
	clr.b	LN_PRI(a1)		; Initialise LN_PRI, to 0.
	move.l	a2,LN_NAME(a1)		; Initialise LN_NAME, to "Afternoon".
	jsr	_LVOAddTail(a6)		; Add node1 to the end of the list.

	move.l	184(a4),a0		; Put list0 address into a0.
	move.l	196(a4),a1		; Put node2 address into a1.
	lea	evening(pc),a2		; Put the string to add to list in a2
	clr.l	(a1)			; Initialise LN_SUCC, to 0.
	clr.l	LN_PRED(a1)		; Initialise LN_PRED, to 0.
	clr.b	LN_TYPE(a1)		; Initialise LN_TYPE, to NT_UNKNOWN.
	clr.b	LN_PRI(a1)		; Initialise LN_PRI, to 0.
	move.l	a2,LN_NAME(a1)		; Initialise LN_NAME, to "Evening".
	jsr	_LVOAddTail(a6)		; Add node2 to the end of the list.

 * Check if the List is empty. If not, try and find `Afternoon' in the list.
 * If it is found (it is in node 1) it will get displayed.

	move.l	184(a4),a0		; Put list0 address into a3.
	move.l	LH_TAILPRED(a0),a1	; Put LH_TAILPRED pointer into a0.
	cmpa.l	a1,a0			; Is LH_TAILPRED pointing to list0?
	beq.s	fr_n2			; Yes. So exit - List is empty.
	lea	findit(pc),a1		; No. Put the String to find in a1.
	jsr	_LVOFindName(a6)	; Try and find the String.
	tst.l	d0			; Was the String found?
	beq.s	search_complete		; No. So exit.
	move.l	d0,a3			; Yes. Put string's node into a3.
	move.l	LN_NAME(a3),a0		; Put node's Name pointer into a0.
	bsr	findlen			; Find the node's name length.
	move.l	178(a4),d1		; show the found node's name.
	move.l	LN_NAME(a3),a0
	move.l	a0,d2
	move.l	d0,d3
	move.l	4(a4),a6
	jsr	_LVOWrite(a6)
	bsr	eol

search_complete

	nop


fr_n2	move.l	196(a4),a1
	moveq	#LN_SIZE,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

fr_n1	move.l	192(a4),a1
	moveq	#LN_SIZE,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

fr_n0	move.l	188(a4),a1
	moveq	#LN_SIZE,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

fr_list	move.l	184(a4),a1
	moveq	#LH_SIZE,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

cl_conf	move.l	#200,d1
	move.l	4(a4),a6
	jsr	_LVODelay(a6)
	move.l	178(a4),d1
	jsr	_LVOClose(a6)

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

eol	move.l	178(a4),d1
	lea	char10(pc),a0
	move.l	a0,d2
	moveq	#1,d3
	jsr	_LVOWrite(a6)
	rts

number	move.l	178(a4),d1
	lea	166(a4),a0
	move.l	a0,d2
	moveq	#5,d3
	jsr	_LVOWrite(a6)
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
cname		dc.b	'CON:0/0/240/160/ List_Nodes.s',0
morning		dc.b	'Morning',0
afternoon	dc.b	'Afternoon',0
evening		dc.b	'Evening',0
findit		dc.b	'Afternoon',0


 * Buffer Variables.

membuf		dcb.b	220,0
char10		dcb.b	1,10


	SECTION	VERSION,DATA

	dc.b	'$VER: List_Nodes.s V1.01 (22.4.2001)',0


	END