
 * This is an example of a few DOS functions that you might not need now
 * but might want to investigate later. Read this file before executing it.
 *

	INCDIR	WORK:Include/

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	intuition/intuition_lib.i
	INCLUDE	intuition/intuition.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE	dos/dosextens.i
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
 * 156 buffers - AddBuffers()
 * 160 dos_list
 * 164
 * 165
 * 166 Memory Buffer (12 bytes)
 * 178 Con: file
 * 182 value 1 (for ToolType/CLI result)
 * 183 value 2 (for ToolType/CLI result)
 * 184 current output
 * 188 dos_entry
 * 192 buffer (100 bytes)
 * 292 old output
 * 296 CLI 5's Process
 * 300

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

 * Make the console window the Current Output. D0 returns a pointer to the
 * old output.

	move.l	d0,d1
	jsr	_LVOSelectOutput(a6)
	move.l	d0,292(a4)

 * Get the current output Handler (which is the console window).

	jsr	_LVOOutput(a6)
	move.l	d0,184(a4)

 * Execute a command.

	lea	command(pc),a0
	move.l	a0,d1
	moveq	#0,d2
	moveq	#0,d3
	jsr	_LVOExecute(a6)
	cmp.l	#TRUE,d0
	bne	cl_conf

 * Roughly the same as Execute(). SystemTagList() returns the error number
 * from the command that was executed or -1 if SystemTagList() could not
 * execute the command.

	lea	command(pc),a0
	move.l	a0,d1
	moveq	#0,d2
	jsr	_LVOSystemTagList(a6)
	cmp.l	#TRUE,d0
	beq	cl_conf

 * Assign S: to Ram:T.

	lea	old_stg(pc),a0
	move.l	a0,d1
	lea	new_stg(pc),a0
	move.l	a0,d2
	jsr	_LVOAssignPath(a6)
	cmp.l	#TRUE,d0
	bne	cl_conf

 * Remove all assigns to old_stg (S:) except the original (S:) assignment.

	lea	old_stg(pc),a0
	move.l	a0,d1
	moveq	#0,d2
	jsr	_LVOAssignLock(a6)
	cmp.l	#TRUE,d0
	bne	cl_conf

 * Assign DEFER - Assign FONTS: to WORK:C.

	lea	fonts(pc),a0
	move.l	a0,d1
	lea	assign(pc),a0
	move.l	a0,d2
	jsr	_LVOAssignLate(a6)
	cmp.l	#TRUE,d0
	bne	cl_conf

 * Inhibit (Stop/Disable/Lock) DF1: - A nifty little command by DOS.
 * Good for security (also inhibits Hard Drive partitions).

	lea	drive(pc),a0
	move.l	a0,d1
	moveq	#TRUE,d2
	jsr	_LVOInhibit(a6)
	cmp.l	#TRUE,d0
	bne	cl_conf

	move.l	#200,d1
	jsr	_LVODelay(a6)

 * Enable DF1: again.

	lea	drive(pc),a0
	move.l	a0,d1
	moveq	#FALSE,d2
	jsr	_LVOInhibit(a6)
	cmp.l	#TRUE,d0
	bne	cl_conf

 * Relabel DF1: to `Empty'.

	lea	drive(pc),a0
	move.l	a0,d1
	lea	empty(pc),a0
	move.l	a0,d2
	jsr	_LVORelabel(a6)
	cmp.l	#TRUE,d0
	bne	cl_conf

 * Add 8 Buffers to DF1:. d0 returns the number of buffers added to DF1:
 * so far (including this add). If you pass 0 to d2 no buffers are added.
 * You just get the number of buffers added so far returned in d0.

	lea	drive(pc),a0
	move.l	a0,d1
	moveq	#8,d2
	jsr	_LVOAddBuffers(a6)
	move.l	d0,156(a4)

 * Attempt to Lock the DosList. In this example I am trying to find the
 * Locale: assign. Which in turn, gives HELP: as the Next Dos Entry.
 * Note. Locale: and HELP: are from my WB3 set up - your results may differ
 * from mine?

	moveq	#LDF_READ!LDF_ALL,d1
	jsr	_LVOAttemptLockDosList(a6)
	move.l	d0,160(a4)
	beq	cl_conf

	move.l	d0,d1
	lea	locale(pc),a0
	move.l	a0,d2
	moveq	#LDF_ALL,d3
	jsr	_LVOFindDosEntry(a6)
	move.l	d0,188(a4)
	beq.s	unlock_dlist
	bsr	show_entry

	move.l	160(a4),d1
	moveq	#LDF_ALL,d2
	jsr	_LVONextDosEntry(a6)
	move.l	d0,188(a4)
	beq.s	unlock_dlist
	bsr	show_entry

unlock_dlist
	moveq	#LDF_READ!LDF_ALL,d1
	jsr	_LVOUnLockDosList(a6)

 * This next bit of code deals with the CLI. Open up a few CLIs/Shells
 * (with WB-Execute's NEWSHELL command) so that you get up to CLI/Shell 7.

 * Get the Highest Numbered CLI Process - Not the maximum. MaxCli() should
 * of been given a name like HighestCLI() in my opinion!

	move.l	4.w,a6
	jsr	_LVOForbid(a6)
	moveq	#0,d5
	move.l	4(a4),a6
	jsr	_LVOMaxCli(a6)
	move.b	d0,d5
	move.l	d5,d1
	bsr	convert_number
	bsr	number
	bsr	eol

	cmp.l	#5,d5			; Does CLI 5 exists?
	blt.s	cli_end			; No. So exit.

	moveq	#5,d1			; Yes.
	jsr	_LVOFindCliProc(a6)	; So find its CLI Process structure.
	move.l	d0,296(a4)
	beq.s	cli_end			; CLI 5 has no Process structure.
					; Perhaps its not a Shell/CLI.
	bra.s	cli_info

cli_end	move.l	4.w,a6
	jsr	_LVOPermit(a6)
	suba.l	a0,a0
	move.l	8(a4),a6
	jsr	_LVODisplayBeep(a6)
	bra.s	cl_conf

cli_info
	move.l	4.w,a6
	jsr	_LVOPermit(a6)

 * This next bit of code deals directly with, the original format of, Dos.
 *
 * BPTR (or BPCL) is a pointer whose address has been right-shifted by 2.
 * To get the original address you simply left-shift by 2 the BPTR.
 *
 * BSTR is a pointer whose address has been right-shifted by 2. To get the
 * original address you simply left-shift by 2 the BSTR. BSTR then contains
 * the length of the string in byte 0 followed by the actual string in byte
 * 1 onwards. I.e Hello = 5 H e l l o.

	move.l	296(a4),a0
	move.l	pr_CLI(a0),a3		; Get the CLI structure.
	move.l	a3,d0
	asl.l	#2,d0
	move.l	d0,a3

 * Get the Prompt from CLI 5. Forget about using GetPrompt() - This bit of
 * code reads the prompt directly. So even if you copy the prompt into a
 * buffer, this code reads the length directly. GetPrompt() needs a buffer
 * and length beforehand. Hence you will more than likely allocate too big
 * a buffer size for GetPrompt().

	move.l	cli_Prompt(a3),a0
	move.l	a0,d0
	asl.l	#2,d0
	move.l	d0,a0
	moveq	#0,d3
	move.b	(a0)+,d3
	move.l	a0,d2
	move.l	184(a4),d1
	move.l	4(a4),a6
	jsr	_LVOWrite(a6)
	bsr	eol

 * Get the name of the Current Directory.

	move.l	cli_SetName(a3),a0
	move.l	a0,d0
	asl.l	#2,d0
	move.l	d0,a0
	moveq	#0,d3
	move.b	(a0)+,d3
	move.l	a0,d2
	move.l	184(a4),d1
	move.l	4(a4),a6
	jsr	_LVOWrite(a6)
	bsr	eol

	move.l	cli_FailLevel(a3),d1
	bsr	convert_number
	bsr	number
	bsr	eol


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

show_entry
	move.l	188(a4),a3
	move.l	dol_Type(a3),d1
	bsr	convert_number
	bsr.s	number
	bsr.s	space

 * BSTR - This kind of pointer has shifted its address right by 2 (asr.l #2)
 * so you need to convert the address back, with asl.l #2,address.
 * When you have done this the first byte in the address is the string's
 * length. A BSTR can only be upto 254 characters in length.

	move.l	dol_Name(a3),d0		; The BSTR address.
	asl.l	#2,d0			; Convert it back to its original.
	move.l	d0,a0			; Put the address into a0 so we can
					; peek into it, etc.
	move.b	(a0),d3			; Get the length.
	addq.l	#1,a0			; Increase address by 1.
	move.l	184(a4),d1
	move.l	a0,d2
	jsr	_LVOWrite(a6)
	bsr.s	eol
	rts

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

txt	move.l	184(a4),d1
	move.l	a0,d2
	move.l	d0,d3
	jsr	_LVOWrite(a6)
	rts

number	lea	166(a4),a0
	move.l	a0,d2
	move.l	184(a4),d1
	moveq	#5,d3
	jsr	_LVOWrite(a6)
	rts

space	move.l	184(a4),d1
	lea	char32(pc),a0
	move.l	a0,d2
	moveq	#1,d3
	jsr	_LVOWrite(a6)
	rts

eol	move.l	184(a4),d1
	lea	char10(pc),a0
	move.l	a0,d2
	moveq	#1,d3
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
cname		dc.b	'CON:0/0/400/160/ Miscellaneous_Dos.s',0,0
drive		dc.b	'DF1:',0,0
empty		dc.b	'Empty',0
locale		dc.b	'Locale',0,0
command		dc.b	'WORK:C/PPMore Ram:File',0,0
prompt		dc.b	'Hello',0
old_stg		dc.b	'S:',0,0
new_stg		dc.b	'Ram:T',0
fonts		dc.b	'FONTS',0
assign		dc.b	'WORK:C',0,0


 * Buffer Variables.

membuf		dcb.b	320,0
char10		dcb.b	1,10
char32		dcb.b	1,32


	SECTION	VERSION,DATA

	dc.b	'$VER: Miscellaneous_Dos.s V1.01 (22.4.2001)',0


	END