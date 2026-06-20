
	INCDIR	WORK:Include/

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	exec/lists.i
	INCLUDE	intuition/intuition_lib.i
	INCLUDE	intuition/intuition.i
	INCLUDE	graphics/graphics_lib.i
	INCLUDE	graphics/text.i
	INCLUDE	graphics/gfxbase.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE	dos/var.i
	INCLUDE	devices/audio.i
	INCLUDE	devices/input.i
	INCLUDE	devices/timer.i
	INCLUDE	devices/timer_lib.i
	INCLUDE	devices/trackdisk.i
	INCLUDE	devices/parallel.i
	INCLUDE	devices/printer.i
	INCLUDE	workbench/icon_lib.i
	INCLUDE	workbench/startup.i
	INCLUDE	workbench/workbench.i
	INCLUDE	utility/utility_lib.i
	INCLUDE	utility/utility.i

	INCLUDE	misc/easystart.i

LIB_VER		EQU	37
MEM_TYPE	EQU	MEMF_PUBLIC!MEMF_CLEAR
FILE_SIZE	EQU	100
TRUE		EQU	-1
FALSE		EQU	0

	move.l	4.w,a6
	move.w	LIB_VERSION(a6),ksv

	moveq.l	#LIB_VER,d0
	lea	dos_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_DOSBase
	beq	exit_quit
	move.w	ksv,d0
	cmpi.w	#36,d0
	ble	exit_wrongks

	moveq.l	#LIB_VER,d0
	lea	int_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_IntuitionBase
	beq	exit_closedos

	moveq.l	#LIB_VER,d0
	lea	graf_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_GfxBase
	beq	exit_closeint

	moveq.l	#LIB_VER,d0
	lea	icon_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_IconBase
	beq	exit_closegfx

	moveq.l	#LIB_VER,d0
	lea	wb_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_WorkbenchBase
	beq	exit_closeicon

	moveq.l	#LIB_VER,d0
	lea	utility_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_UtilityBase
	beq	exit_closewb

 * Open a Console Window.

	move.l	#MODE_NEWFILE,d2
	move.l	#cname,d1
	move.l	_DOSBase(pc),a6
	jsr	_LVOOpen(a6)
	move.l	d0,cfh
	beq	exit_closeutility
	move.l	cfh,d1
	move.l	#jw_info,d2
	move.l	#jwi_len,d3
	jsr	_LVOWrite(a6)

 * Check the ToolTypes/CLI Arguments.

	tst.l	returnMsg
	beq	from_cli
	movea.l	returnMsg,a0
	movea.l	sm_ArgList(a0),a0
	beq	zero_arguments
	move.l	(a0),d1
	jsr	_LVOCurrentDir(a6)
	move.l	d0,olddir
	movea.l	returnMsg,a0
	movea.l	sm_ArgList(a0),a0
	movea.l	wa_Name(a0),a0
	move.l	_IconBase(pc),a6
	jsr	_LVOGetDiskObject(a6)
	move.l	d0,doptr
	beq	zero_arguments
	movea.l	d0,a1
	move.l	do_ToolTypes(a1),ttptr
	movea.l	#arg_results,a3
	movea.l	ttptr,a0
	movea.l	#ftstg0,a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	devo1
	movea.l	d0,a4
	movea.l	a4,a0
	movea.l	#mvstg0,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	libo2
	move.b	#1,(a3)
	bra.s	devo1

libo2	movea.l	a4,a0
	movea.l	#mvstg1,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	libo6
	move.b	#2,(a3)
	bra.s	devo1

libo6	move.b	#6,(a3)

devo1	movea.l	ttptr,a0
	movea.l	#ftstg1,a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	fddo1
	movea.l	d0,a4
	movea.l	a4,a0
	movea.l	#mvstg0,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	devo2
	move.b	#1,1(a3)
	bra.s	fddo1

devo2	movea.l	a4,a0
	movea.l	#mvstg1,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	devo6
	move.b	#2,1(a3)
	bra.s	fddo1

devo6	move.b	#6,1(a3)

fddo1	movea.l	ttptr,a0
	movea.l	#ftstg2,a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	po1
	movea.l	d0,a4
	movea.l	a4,a0
	movea.l	#mvstg2,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	fddo2
	move.b	#1,2(a3)
	bra.s	po1

fddo2	movea.l	a4,a0
	movea.l	#mvstg3,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	fddo3
	move.b	#2,2(a3)
	bra.s	po1

fddo3	movea.l	a4,a0
	movea.l	#mvstg4,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	fddo4
	move.b	#3,2(a3)
	bra.s	po1

fddo4	movea.l	a4,a0
	movea.l	#mvstg5,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	fddo6
	move.b	#4,2(a3)
	bra.s	po1

fddo6	move.b	#6,2(a3)

po1	movea.l	ttptr,a0
	movea.l	#ftstg3,a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	cmo1
	movea.l	d0,a4
	movea.l	a4,a0
	movea.l	#mvstg6,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	po6
	move.b	#1,3(a3)
	bra.s	cmo1

po6	move.b	#6,3(a3)

cmo1	movea.l	ttptr,a0
	movea.l	#ftstg4,a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	fmo1
	movea.l	d0,a4
	movea.l	a4,a0
	movea.l	#mvstg9,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	cmo2
	move.b	#1,4(a3)
	bra.s	fmo1

cmo2	movea.l	a4,a0
	movea.l	#mvstg10,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	cmo3
	move.b	#2,4(a3)
	bra.s	fmo1

cmo3	movea.l	a4,a0
	movea.l	#mvstg11,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	cmo6
	move.b	#3,4(a3)
	bra.s	fmo1

cmo6	move.b	#6,4(a3)

fmo1	movea.l	ttptr,a0
	movea.l	#ftstg5,a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	tmo1
	movea.l	d0,a4
	movea.l	a4,a0
	movea.l	#mvstg9,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	fmo2
	move.b	#1,5(a3)
	bra.s	tmo1

fmo2	movea.l	a4,a0
	movea.l	#mvstg10,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	fmo3
	move.b	#2,5(a3)
	bra.s	tmo1

fmo3	movea.l	a4,a0
	movea.l	#mvstg11,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	fmo6
	move.b	#3,5(a3)
	bra.s	tmo1

fmo6	move.b	#6,5(a3)

tmo1	movea.l	ttptr,a0
	movea.l	#ftstg6,a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	mpo1
	movea.l	d0,a4
	movea.l	a4,a0
	movea.l	#mvstg9,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tmo2
	move.b	#1,6(a3)
	bra.s	mpo1

tmo2	movea.l	a4,a0
	movea.l	#mvstg10,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tmo3
	move.b	#2,6(a3)
	bra.s	mpo1

tmo3	movea.l	a4,a0
	movea.l	#mvstg11,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tmo6
	move.b	#3,6(a3)
	bra.s	mpo1

tmo6	move.b	#6,6(a3)

mpo1	movea.l	ttptr,a0
	movea.l	#ftstg7,a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	mpto1
	movea.l	d0,a4
	movea.l	a4,a0
	movea.l	#mvstg6,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	mpo6
	move.b	#1,7(a3)
	bra.s	mpto1

mpo6	move.b	#6,7(a3)

mpto1	movea.l	ttptr,a0
	movea.l	#ftstg8,a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	dfzo1
	movea.l	d0,a4
	movea.l	a4,a0
	movea.l	#mvstg12,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	mpto2
	move.b	#1,8(a3)
	bra.s	dfzo1

mpto2	movea.l	a4,a0
	movea.l	#mvstg13,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	mpto3
	move.b	#2,8(a3)
	bra.s	dfzo1

mpto3	movea.l	a4,a0
	movea.l	#mvstg14,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	mpto6
	move.b	#3,8(a3)
	bra.s	dfzo1

mpto6	move.b	#6,8(a3)

dfzo1	movea.l	ttptr,a0
	movea.l	#ftstg9,a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	dfoo1
	movea.l	d0,a4
	movea.l	a4,a0
	movea.l	#mvstg6,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	dfzo6
	move.b	#1,9(a3)
	bra.s	dfoo1

dfzo6	move.b	#6,9(a3)

dfoo1	movea.l	ttptr,a0
	movea.l	#ftstg10,a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	dfto1
	movea.l	d0,a4
	movea.l	a4,a0
	movea.l	#mvstg6,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	dfoo6
	move.b	#1,10(a3)
	bra.s	dfto1

dfoo6	move.b	#6,10(a3)

dfto1	movea.l	ttptr,a0
	movea.l	#ftstg11,a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	dflo1
	movea.l	d0,a4
	movea.l	a4,a0
	movea.l	#mvstg6,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	dfto6
	move.b	#1,11(a3)
	bra.s	dflo1

dfto6	move.b	#6,11(a3)

dflo1	movea.l	ttptr,a0
	movea.l	#ftstg12,a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	hdo1
	movea.l	d0,a4
	movea.l	a4,a0
	movea.l	#mvstg6,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	dflo6
	move.b	#1,12(a3)
	bra.s	hdo1

dflo6	move.b	#6,12(a3)

hdo1	movea.l	ttptr,a0
	movea.l	#ftstg13,a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
	beq.s	free_diskobj
	movea.l	d0,a4
	movea.l	a4,a0
	movea.l	#mvstg6,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	hdo6
	move.b	#1,13(a3)
	bra.s	free_diskobj

hdo6	move.b	#6,13(a3)

free_diskobj
	movea.l	doptr,a0
	jsr	_LVOFreeDiskObject(a6)
	bra	zero_arguments

from_cli
	move.l	#template,d1
	lea	argv(pc),a1
	move.l	a1,d2
	clr.l	d3
	move.l	_DOSBase(pc),a6
	jsr	_LVOReadArgs(a6)
	move.l	d0,rdargs
	beq	zero_arguments
	movea.l	#arg_results,a3
	lea	argv(pc),a2
	movea.l	(a2),a0
	movea.l	#mvstg0,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	liba2
	move.b	#1,(a3)
	bra.s	deva1

liba2	movea.l	(a2),a0
	movea.l	#mvstg1,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	liba3
	move.b	#2,(a3)
	bra.s	deva1

liba3	movea.l	(a2),a0
	movea.l	#mvstg8,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	deva1
	move.b	#6,(a3)

deva1	movea.l	4(a2),a0
	movea.l	#mvstg0,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	deva2
	move.b	#1,1(a3)
	bra.s	fdda1

deva2	movea.l	4(a2),a0
	movea.l	#mvstg1,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	deva3
	move.b	#2,1(a3)
	bra.s	fdda1

deva3	movea.l	4(a2),a0
	movea.l	#mvstg8,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	fdda1
	move.b	#6,1(a3)

fdda1	movea.l	8(a2),a0
	movea.l	#mvstg2,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	fdda2
	move.b	#1,2(a3)
	bra.s	pa1

fdda2	movea.l	8(a2),a0
	movea.l	#mvstg3,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	fdda3
	move.b	#2,2(a3)
	bra.s	pa1

fdda3	movea.l	8(a2),a0
	movea.l	#mvstg4,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	fdda4
	move.b	#3,2(a3)
	bra.s	pa1

fdda4	movea.l	8(a2),a0
	movea.l	#mvstg5,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	fdda5
	move.b	#4,2(a3)
	bra.s	pa1

fdda5	movea.l	8(a2),a0
	movea.l	#mvstg8,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	pa1
	move.b	#6,2(a3)

pa1	movea.l	12(a2),a0
	movea.l	#mvstg6,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	cma1
	move.b	#6,3(a3)

cma1	movea.l	16(a2),a0
	movea.l	#mvstg9,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	cma2
	move.b	#1,4(a3)
	bra.s	fma1

cma2	movea.l	16(a2),a0
	movea.l	#mvstg10,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	cma3
	move.b	#2,4(a3)
	bra.s	fma1

cma3	movea.l	16(a2),a0
	movea.l	#mvstg11,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	cma4
	move.b	#3,4(a3)
	bra.s	fma1

cma4	movea.l	16(a2),a0
	movea.l	#mvstg8,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	fma1
	move.b	#6,4(a3)

fma1	movea.l	20(a2),a0
	movea.l	#mvstg9,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	fma2
	move.b	#1,5(a3)
	bra.s	tma1

fma2	movea.l	20(a2),a0
	movea.l	#mvstg10,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	fma3
	move.b	#2,5(a3)
	bra.s	tma1

fma3	movea.l	20(a2),a0
	movea.l	#mvstg11,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	fma4
	move.b	#3,5(a3)
	bra.s	tma1

fma4	movea.l	20(a2),a0
	movea.l	#mvstg8,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	tma1
	move.b	#6,5(a3)

tma1	movea.l	24(a2),a0
	movea.l	#mvstg9,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	tma2
	move.b	#1,6(a3)
	bra.s	mpa1

tma2	movea.l	24(a2),a0
	movea.l	#mvstg10,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	tma3
	move.b	#2,6(a3)
	bra.s	mpa1

tma3	movea.l	24(a2),a0
	movea.l	#mvstg11,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	tma4
	move.b	#3,6(a3)
	bra.s	mpa1

tma4	movea.l	24(a2),a0
	movea.l	#mvstg8,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	mpa1
	move.b	#6,6(a3)

mpa1	movea.l	28(a2),a0
	movea.l	#mvstg6,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	mpta1
	move.b	#6,7(a3)

mpta1	movea.l	32(a2),a0
	movea.l	#mvstg12,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	mpta2
	move.b	#1,8(a3)
	bra.s	dfza1

mpta2	movea.l	32(a2),a0
	movea.l	#mvstg13,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	mpta3
	move.b	#2,8(a3)
	bra.s	dfza1

mpta3	movea.l	32(a2),a0
	movea.l	#mvstg14,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	mpta4
	move.b	#3,8(a3)
	bra.s	dfza1

mpta4	movea.l	32(a2),a0
	movea.l	#mvstg15,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	dfza1
	move.b	#6,8(a3)

dfza1	movea.l	36(a2),a0
	movea.l	#mvstg6,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	dfoa1
	move.b	#6,9(a3)

dfoa1	movea.l	40(a2),a0
	movea.l	#mvstg6,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	dfta1
	move.b	#6,10(a3)

dfta1	movea.l	44(a2),a0
	movea.l	#mvstg6,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	dfla1
	move.b	#6,11(a3)

dfla1	movea.l	48(a2),a0
	movea.l	#mvstg6,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	hda1
	move.b	#6,12(a3)

hda1	movea.l	52(a2),a0
	movea.l	#mvstg6,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	free_cliargs
	move.b	#6,13(a3)

free_cliargs
	move.l	rdargs(pc),d1
	jsr	_LVOFreeArgs(a6)

zero_arguments

 * Allocate a memory buffer for general purposes.

	moveq.l	#FILE_SIZE,d0
	move.l	#MEM_TYPE,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,bytebuf
	beq	exit_closeconfile

	clr.l	d6
do_lib	clr.l	d5
	movea.l	#arg_results,a3
	move.b	(a3),d5
	tst.b	d5
	beq	do_dev
	cmpi.b	#1,d5
	beq.s	lib_v
	cmpi.b	#2,d5
	beq.s	lib_r
	cmpi.b	#6,d5
	beq.s	lib_d
	bra	do_dev
lib_v	bsr.s	lib_lv
	bra	do_dev
lib_r	bsr	lib_lr
	bra	do_dev
lib_d	bsr.s	lib_lv
	bsr.s	lib_lr
	bra	do_dev

lib_lv	move.l	#dosv_gev,d6
	bsr	do_gev
	move.l	#execv_gev,d6
	bsr	do_gev
	move.l	#expv_gev,d6
	bsr	do_gev
	move.l	#gadtv_gev,d6
	bsr	do_gev
	move.l	#gfxv_gev,d6
	bsr	do_gev
	move.l	#iconv_gev,d6
	bsr	do_gev
	move.l	#intv_gev,d6
	bsr	do_gev
	move.l	#kmv_gev,d6
	bsr	do_gev
	move.l	#layv_gev,d6
	bsr	do_gev
	move.l	#mathv_gev,d6
	bsr	do_gev
	move.l	#utilv_gev,d6
	bsr	do_gev
	move.l	#wbv_gev,d6
	bsr	do_gev
	rts

lib_lr	move.l	#dosr_gev,d6
	bsr	do_gev
	move.l	#execr_gev,d6
	bsr	do_gev
	move.l	#expr_gev,d6
	bsr	do_gev
	move.l	#gadtr_gev,d6
	bsr	do_gev
	move.l	#gfxr_gev,d6
	bsr	do_gev
	move.l	#iconr_gev,d6
	bsr	do_gev
	move.l	#intr_gev,d6
	bsr	do_gev
	move.l	#kmr_gev,d6
	bsr	do_gev
	move.l	#layr_gev,d6
	bsr	do_gev
	move.l	#mathr_gev,d6
	bsr	do_gev
	move.l	#utilr_gev,d6
	bsr	do_gev
	move.l	#wbr_gev,d6
	bsr	do_gev
	rts

do_dev	clr.l	d5
	move.b	1(a3),d5
	tst.b	d5
	beq	do_tdd
	cmpi.b	#1,d5
	beq.s	dev_v
	cmpi.b	#2,d5
	beq.s	dev_r
	cmpi.b	#6,d5
	beq.s	dev_d
	bra	do_tdd
dev_v	bsr.s	dev_lv
	bra	do_tdd
dev_r	bsr.s	dev_lr
	bra	do_tdd
dev_d	bsr.s	dev_lv
	bsr.s	dev_lr
	bra	do_tdd

dev_lv	move.l	#audv_gev,d6
	bsr	do_gev
	move.l	#cardv_gev,d6
	bsr	do_gev
	move.l	#consolev_gev,d6
	bsr	do_gev
	move.l	#gamev_gev,d6
	bsr	do_gev
	move.l	#inputv_gev,d6
	bsr	do_gev
	move.l	#keybv_gev,d6
	bsr	do_gev
	move.l	#ramdv_gev,d6
	bsr	do_gev
	move.l	#timerv_gev,d6
	bsr	do_gev
	move.l	#tdiskv_gev,d6
	bsr	do_gev
	rts

dev_lr	move.l	#audr_gev,d6
	bsr	do_gev
	move.l	#cardr_gev,d6
	bsr	do_gev
	move.l	#consoler_gev,d6
	bsr	do_gev
	move.l	#gamer_gev,d6
	bsr	do_gev
	move.l	#inputr_gev,d6
	bsr	do_gev
	move.l	#keybr_gev,d6
	bsr	do_gev
	move.l	#ramdr_gev,d6
	bsr	do_gev
	move.l	#timerr_gev,d6
	bsr	do_gev
	move.l	#tdiskr_gev,d6
	bsr	do_gev
	rts

do_tdd	clr.l	d5
	move.b	2(a3),d5
	tst.b	d5
	beq.s	do_prt
	cmpi.b	#1,d5
	beq.s	df0
	cmpi.b	#2,d5
	beq.s	df1
	cmpi.b	#3,d5
	beq.s	df2
	cmpi.b	#4,d5
	beq.s	df3
	bsr.s	do_df0
	bsr.s	do_df1
	bsr.s	do_df2
	bsr.s	do_df3
	bra.s	do_prt
df0	bsr.s	do_df0
	bra.s	do_prt
df1	bsr.s	do_df1
	bra.s	do_prt
df2	bsr.s	do_df2
	bra.s	do_prt
df3	bsr.s	do_df3
	bra.s	do_prt

do_df0	move.l	#dfzero_gev,d6
	bsr	do_gev
	rts

do_df1	move.l	#dfone_gev,d6
	bsr	do_gev
	rts

do_df2	move.l	#dftwo_gev,d6
	bsr	do_gev
	rts

do_df3	move.l	#dfthree_gev,d6
	bsr	do_gev
	rts

do_prt	clr.l	d5
	move.b	3(a3),d5
	tst.b	d5
	beq.s	chipm
	move.l	#par_gev,d6
	bsr	do_gev

chipm	clr.l	d5
	move.b	4(a3),d5
	tst.b	d5
	beq.s	fastm
	cmpi.b	#1,d5
	beq.s	c_free
	cmpi.b	#2,d5
	beq.s	c_tot
	cmpi.b	#3,d5
	beq.s	c_most
	bsr.s	chipf
	bsr.s	chipt
	bsr.s	chipl
	bra.s	fastm

c_free	bsr.s	chipf
	bra.s	fastm

c_tot	bsr.s	chipt
	bra.s	fastm

c_most	bsr.s	chipl
	bra.s	fastm

chipf	move.l	#cmfree_gev,d6
	bsr	do_gev
	rts

chipt	move.l	#cmtotal_gev,d6
	bsr	do_gev
	rts

chipl	move.l	#cmlargest_gev,d6
	bsr	do_gev
	rts

fastm	clr.l	d5
	move.b	5(a3),d5
	tst.b	d5
	beq.s	anym
	cmpi.b	#1,d5
	beq.s	f_free
	cmpi.b	#2,d5
	beq.s	f_tot
	cmpi.b	#3,d5
	beq.s	f_most
	bsr.s	fastf
	bsr.s	fastt
	bsr.s	fastl
	bra.s	anym

f_free	bsr.s	fastf
	bra.s	anym

f_tot	bsr.s	fastt
	bra.s	anym

f_most	bsr.s	fastl
	bra.s	anym

fastf	move.l	#fmfree_gev,d6
	bsr	do_gev
	rts

fastt	move.l	#fmtotal_gev,d6
	bsr	do_gev
	rts

fastl	move.l	#fmlargest_gev,d6
	bsr	do_gev
	rts

anym	clr.l	d5
	move.b	6(a3),d5
	tst.b	d5
	beq.s	dbgevs
	cmpi.b	#1,d5
	beq.s	a_free
	cmpi.b	#2,d5
	beq.s	a_tot
	cmpi.b	#3,d5
	beq.s	a_most
	bsr.s	anyf
	bsr.s	anyt
	bsr.s	anyl
	bra.s	dbgevs

a_free	bsr.s	anyf
	bra.s	dbgevs

a_tot	bsr.s	anyt
	bra.s	dbgevs

a_most	bsr.s	anyl
	bra.s	dbgevs

anyf	move.l	#amfree_gev,d6
	bsr	do_gev
	rts

anyt	move.l	#amtotal_gev,d6
	bsr	do_gev
	rts

anyl	move.l	#amlargest_gev,d6
	bsr	do_gev
	rts

dbgevs	clr.l	d5
	move.b	7(a3),d5
	tst.b	d5
	beq	do_unused
	move.l	#ksv_gev,d6
	bsr	do_gev
	move.l	#ksr_gev,d6
	bsr	do_gev
	move.l	#ipr_gev,d6
	bsr	do_gev
	move.l	#wb_gev,d6
	bsr	do_gev
	move.l	#rad_gev,d6
	bsr	do_gev
	move.l	#ccr_gev,d6
	bsr	do_gev
	move.l	#ipro_gev,d6
	bsr	do_gev
	move.l	#cpu_gev,d6
	bsr	do_gev
	move.l	#cop_gev,d6
	bsr	do_gev
	move.l	#fpu_gev,d6
	bsr	do_gev
	move.l	#ecf_gev,d6
	bsr	do_gev
	move.l	#agnus_gev,d6
	bsr	do_gev
	move.l	#denise_gev,d6
	bsr	do_gev
	move.l	#alice_gev,d6
	bsr	do_gev
	move.l	#lisa_gev,d6
	bsr	do_gev
	move.l	#cmode_gev,d6
	bsr	do_gev
	move.l	#vbf_gev,d6
	bsr	do_gev
	move.l	#psf_gev,d6
	bsr	do_gev
	move.l	#dtv_gev,d6
	bsr	do_gev
	move.l	#ctv_gev,d6
	bsr	do_gev

do_unused

do_di0	clr.l	d5
	move.b	9(a3),d5
	tst.b	d5
	beq.s	do_di1
	move.b	#48,dfbyte
	bsr.s	deltdd_gevs

do_di1	clr.l	d5
	move.b	10(a3),d5
	tst.b	d5
	beq.s	do_di2
	move.b	#49,dfbyte
	bsr.s	deltdd_gevs

do_di2	clr.l	d5
	move.b	11(a3),d5
	tst.b	d5
	beq.s	do_di3
	move.b	#50,dfbyte
	bsr.s	deltdd_gevs

do_di3	clr.l	d5
	move.b	12(a3),d5
	tst.b	d5
	beq.s	hdi
	move.b	#51,dfbyte
	bsr.s	deltdd_gevs

hdi


	bra	exit_closeconfile


 * Sub-Routines.

deltdd_gevs
	move.b	dfbyte,dsize_gev+2
	move.b	dfbyte,motor_gev+2
	move.b	dfbyte,swaps_gev+2
	move.b	dfbyte,empty_gev+2
	move.b	dfbyte,sectors_gev+2
	move.b	dfbyte,totsects_gev+2
	move.b	dfbyte,cylinders_gev+2
	move.b	dfbyte,cylsects_gev+2
	move.b	dfbyte,heads_gev+2
	move.b	dfbyte,tracks_gev+2
	move.b	dfbyte,bmt_gev+2
	move.b	dfbyte,ddt_gev+2
	move.b	dfbyte,flag_gev+2
	move.b	dfbyte,ddfs_gev+2
	move.b	dfbyte,tab_gev+2
	move.b	dfbyte,htest_gev+2
	move.b	dfbyte,eject_gev+2
	move.b	dfbyte,fname_gev+2
	move.b	dfbyte,dostype_gev+2
	move.b	dfbyte,errors_gev+2
	move.b	dfbyte,state_gev+2
	move.b	dfbyte,nob_gev+2
	move.b	dfbyte,nobu_gev+2
	move.b	dfbyte,bpb_gev+2
	move.b	dfbyte,kbcq_gev+2
	move.b	dfbyte,kbcr_gev+2
	move.b	dfbyte,kbuq_gev+2
	move.b	dfbyte,kbur_gev+2
	move.b	dfbyte,kbfq_gev+2
	move.b	dfbyte,kbfr_gev+2
	move.b	dfbyte,inuse_gev+2
	move.l	#dsize_gev,d6
	bsr	do_gev
	move.l	#motor_gev,d6
	bsr	do_gev
	move.l	#swaps_gev,d6
	bsr	do_gev
	move.l	#empty_gev,d6
	bsr	do_gev
	move.l	#sectors_gev,d6
	bsr	do_gev
	move.l	#totsects_gev,d6
	bsr	do_gev
	move.l	#cylinders_gev,d6
	bsr	do_gev
	move.l	#cylsects_gev,d6
	bsr	do_gev
	move.l	#heads_gev,d6
	bsr	do_gev
	move.l	#tracks_gev,d6
	bsr	do_gev
	move.l	#bmt_gev,d6
	bsr	do_gev
	move.l	#ddt_gev,d6
	bsr	do_gev
	move.l	#flag_gev,d6
	bsr	do_gev
	move.l	#ddfs_gev,d6
	bsr	do_gev
	move.l	#tab_gev,d6
	bsr	do_gev
	move.l	#htest_gev,d6
	bsr.s	do_gev
	move.l	#eject_gev,d6
	bsr.s	do_gev
	move.l	#fname_gev,d6
	bsr.s	do_gev
	move.l	#dostype_gev,d6
	bsr.s	do_gev
	move.l	#errors_gev,d6
	bsr.s	do_gev
	move.l	#state_gev,d6
	bsr.s	do_gev
	move.l	#nob_gev,d6
	bsr.s	do_gev
	move.l	#nobu_gev,d6
	bsr.s	do_gev
	move.l	#bpb_gev,d6
	bsr.s	do_gev
	move.l	#kbcq_gev,d6
	bsr.s	do_gev
	move.l	#kbcr_gev,d6
	bsr.s	do_gev
	move.l	#kbuq_gev,d6
	bsr.s	do_gev
	move.l	#kbur_gev,d6
	bsr.s	do_gev
	move.l	#kbfq_gev,d6
	bsr.s	do_gev
	move.l	#kbfr_gev,d6
	bsr.s	do_gev
	move.l	#inuse_gev,d6
	bsr.s	do_gev
	rts

do_gev	move.l	d6,d1
	move.l	#delbuf,d2
	moveq.l	#31,d3
	move.l	#GVF_GLOBAL_ONLY!GVF_BINARY_VAR,d4
	move.l	_DOSBase(pc),a6
	jsr	_LVOGetVar(a6)
	cmpi.l	#-1,d0
	beq.s	gev_e
	move.l	d6,d1
	move.l	#GVF_GLOBAL_ONLY!GVF_BINARY_VAR,d2
	jsr	_LVODeleteVar(a6)
gev_e	rts

compare_bytes
	move.b	(a0)+,d0
	move.b	(a1)+,d1
	tst.b	d0
	beq.s	zero_byte
	cmp.b	d1,d0
	beq.s	compare_bytes

zero_byte
	sub.b	d1,d0
	ext.w	d0
	ext.l	d0
	rts

flush	move.l	#8000000,d0
	moveq.l	#MEMF_CHIP,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.s	bye
	move.l	d0,a1
	move.l	#8000000,d0
	jsr	_LVOFreeMem(a6)
bye	rts


 * Exit Routines.

exit_freemem
	movea.l	bytebuf(pc),a1
	moveq.l	#FILE_SIZE,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

exit_closeconfile
	move.l	cfh,d1
	move.l	_DOSBase(pc),a6
	jsr	_LVOClose(a6)

exit_closeutility
	movea.l	_UtilityBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

exit_closewb
	movea.l	_WorkbenchBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

exit_closeicon
	movea.l	_IconBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

exit_closegfx
	movea.l	_GfxBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

exit_closeint
	movea.l	_IntuitionBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)
	bra	exit_closedos

exit_wrongks

exit_closedos
	movea.l	_DOSBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

exit_quit
	bsr	flush
	clr.l	d0
	rts


 * Structure Definitions.


 * Include Variables.

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
_IconBase	dc.l	0
_UtilityBase	dc.l	0
_WorkbenchBase	dc.l	0
dos_name	dc.b	'dos.library',0
int_name	dc.b	'intuition.library',0
graf_name	dc.b	'graphics.library',0
utility_name	dc.b	'utility.library',0
wb_name		dc.b	'workbench.library',0
icon_name	dc.b	'icon.library',0
	even


 * ToolType/GEV Variables.

argv	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
rdargs	dc.l	0
doptr	dc.l	0
ttptr	dc.l	0
olddir	dc.l	0
ckstg	dc.l	0
arg_results	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
template
	dc.b	'LIBRARIES/K,DEVICES/K,DISKDRIVES/K,PRINTER/K,CHIPMEM/K,FASTMEM/K,ANYMEM/K,BASICGEVS/K,UNUSED/K,DF0INFO/K,DF1INFO/K,DF2INFO/K,DF3INFO/K,HDINFO/K',0
	even

ftstg0		dc.b	'LIBRARIES',0
ftstg1		dc.b	'DEVICES',0
ftstg2		dc.b	'DISKDRIVES',0
ftstg3		dc.b	'PRINTER',0
ftstg4		dc.b	'CHIPMEM',0
ftstg5		dc.b	'FASTMEM',0
ftstg6		dc.b	'ANYMEM',0
ftstg7		dc.b	'BASICGEVS',0
ftstg8		dc.b	'UNUSED',0
ftstg9		dc.b	'DF0INFO',0
ftstg10		dc.b	'DF1INFO',0
ftstg11		dc.b	'DF2INFO',0
ftstg12		dc.b	'DF3INFO',0
ftstg13		dc.b	'HDINFO',0
mvstg0		dc.b	'VERSIONS',0
mvstg1		dc.b	'REVISIONS',0
mvstg2		dc.b	'DF0:',0
mvstg3		dc.b	'DF1:',0
mvstg4		dc.b	'DF2:',0
mvstg5		dc.b	'DF3:',0
mvstg6		dc.b	'YES',0
mvstg7		dc.b	'TRUE',0
mvstg8		dc.b	'ALL',0
mvstg9		dc.b	'FREEONLY',0
mvstg10		dc.b	'TOTALONLY',0
mvstg11		dc.b	'LARGESTONLY',0
mvstg12		dc.b	'MOUSEISRELJOY',0
mvstg13		dc.b	'MOUSEISABSJOY',0
mvstg14		dc.b	'MOUSEISDISABLED',0
mvstg15		dc.b	'MOUSEISMOUSE',0
mvstg16		dc.b	'NO',0
mvstg17		dc.b	'FALSE',0
mvstg18		dc.b	'OFF',0
mvstg19		dc.b	'ON',0
mvstg20		dc.b	'ZERO',0
mvstg21		dc.b	'ONE',0

ksv_gev		dc.b	'KickstartVer',0
ksr_gev		dc.b	'KickstartRev',0
dosv_gev	dc.b	'DosVer',0
dosr_gev	dc.b	'DosRev',0
execv_gev	dc.b	'ExecuteVer',0
execr_gev	dc.b	'ExecuteRev',0
expv_gev	dc.b	'ExpansionVer',0
expr_gev	dc.b	'ExpansionRev',0
gadtv_gev	dc.b	'GadtoolsVer',0
gadtr_gev	dc.b	'GadtoolsRev',0
gfxv_gev	dc.b	'GraphicsVer',0
gfxr_gev	dc.b	'GraphicsRev',0
iconv_gev	dc.b	'IconVer',0
iconr_gev	dc.b	'IconRev',0
intv_gev	dc.b	'IntuitionVer',0
intr_gev	dc.b	'IntuitionRev',0
kmv_gev		dc.b	'KeymapVer',0
kmr_gev		dc.b	'KeymapRev',0
layv_gev	dc.b	'LayersVer',0
layr_gev	dc.b	'LayersRev',0
mathv_gev	dc.b	'MathVer',0
mathr_gev	dc.b	'MathRev',0
utilv_gev	dc.b	'UtilityVer',0
utilr_gev	dc.b	'UtilityRev',0
wbv_gev		dc.b	'WorkbenchVer',0
wbr_gev		dc.b	'WorkbenchRev',0
audv_gev	dc.b	'AudioVer',0
audr_gev	dc.b	'AudioRev',0
cardv_gev	dc.b	'CarddiskVer',0
cardr_gev	dc.b	'CarddiskRev',0
consolev_gev	dc.b	'ConsoleVer',0
consoler_gev	dc.b	'ConsoleRev',0
gamev_gev	dc.b	'GameportVer',0
gamer_gev	dc.b	'GameportRev',0
inputv_gev	dc.b	'InputVer',0
inputr_gev	dc.b	'InputRev',0
keybv_gev	dc.b	'KeyboardVer',0
keybr_gev	dc.b	'KeyboardRev',0
ramdv_gev	dc.b	'RamdriveVer',0
ramdr_gev	dc.b	'RamdriveRev',0
timerv_gev	dc.b	'TimerVer',0
timerr_gev	dc.b	'TimerRev',0
tdiskv_gev	dc.b	'TrackdiskVer',0
tdiskr_gev	dc.b	'TrackdiskRev',0
ipr_gev		dc.b	'IPrefsTaskActive',0
wb_gev		dc.b	'WBActive',0
rad_gev		dc.b	'RADActive',0
ccr_gev		dc.b	'ConClipActive',0
ipro_gev	dc.b	'IPrefsPortActive',0
cpu_gev		dc.b	'CPUProcessor',0
cop_gev		dc.b	'COProcessor',0
fpu_gev		dc.b	'FPUProcessor',0
ecf_gev		dc.b	'EClockFrequency',0
agnus_gev	dc.b	'HRAgnusChip',0
denise_gev	dc.b	'HRDeniseChip',0
alice_gev	dc.b	'AAAliceChip',0
lisa_gev	dc.b	'AALisaChip',0
cmode_gev	dc.b	'ChipMode',0
vbf_gev		dc.b	'VBlankFrequency',0
psf_gev		dc.b	'PowerSupplyFrequency',0
dtv_gev		dc.b	'DefaultTVMode',0
ctv_gev		dc.b	'CurrentTVMode',0
dfzero_gev	dc.b	'DF0Connected',0
dfone_gev	dc.b	'DF1Connected',0
dftwo_gev	dc.b	'DF2Connected',0
dfthree_gev	dc.b	'DF3Connected',0
par_gev		dc.b	'ParallelStatus',0
cmfree_gev	dc.b	'FreeChipMemory',0
cmtotal_gev	dc.b	'TotalChipMemory',0
cmlargest_gev	dc.b	'LargestChipMemory',0
fmfree_gev	dc.b	'FreeFastMemory',0
fmtotal_gev	dc.b	'TotalFastMemory',0
fmlargest_gev	dc.b	'LargestFastMemory',0
amfree_gev	dc.b	'FreeAnyMemory',0
amtotal_gev	dc.b	'TotalAnyMemory',0
amlargest_gev	dc.b	'LargestAnyMemory',0
dsize_gev	dc.b	'DF0SizeType',0
motor_gev	dc.b	'DF0MotorStatus',0
swaps_gev	dc.b	'DF0MediaSwaps',0
empty_gev	dc.b	'DF0Empty',0
sectors_gev	dc.b	'DF0Sectors',0
totsects_gev	dc.b	'DF0TotalSectors',0
cylinders_gev	dc.b	'DF0Cylinders',0
cylsects_gev	dc.b	'DF0CylSectors',0
heads_gev	dc.b	'DF0Heads',0
tracks_gev	dc.b	'DF0Tracks',0
bmt_gev		dc.b	'DF0BufMemType',0
ddt_gev		dc.b	'DF0DeviceType',0
flag_gev	dc.b	'DF0Attributes',0
ddfs_gev	dc.b	'DF0KBCapacity',0
tab_gev		dc.b	'DF0MediaProtected',0
htest_gev	dc.b	'DF0HeadsTest',0
eject_gev	dc.b	'DF0MediaEjected',0
fname_gev	dc.b	'DF0MediaName',0
dostype_gev	dc.b	'DF0MediaFormat',0
errors_gev	dc.b	'DF0MediaErrors',0
state_gev	dc.b	'DF0MediaMode',0
nob_gev		dc.b	'DF0MediaBlocks',0
nobu_gev	dc.b	'DF0MediaBlocksUsed',0
bpb_gev		dc.b	'DF0MediaBytesPerBlock',0
kbcq_gev	dc.b	'DF0MediaKBCQ',0
kbcr_gev	dc.b	'DF0MediaKBCR',0
kbuq_gev	dc.b	'DF0MediaKBUQ',0
kbur_gev	dc.b	'DF0MediaKBUR',0
kbfq_gev	dc.b	'DF0MediaKBFQ',0
kbfr_gev	dc.b	'DF0MediaKBFR',0
inuse_gev	dc.b	'DF0MediaInUse',0
	even


 * File Variables.

cfh	dc.l	0
config	ds.b	100
cname	dc.b	'CON:0/0/640/160/ Delete Set-Up GEVs V2.01 - Written by: John White - Shareware (£2.50).',0
	even

jw_info
	dc.b	' ',10,'John White',10,'91 Comber House',10,'Comber Grove',10
	dc.b	'Camberwell',10,'London',10,'SE5 0LL',10,'ENGLAND',10,10
	dc.b	'Telephone: (+44) (020) 77018546',10,10
	dc.b	'Set-Up GEVs now being deleted.....',10,10,10
	even
jwi_len		equ	*-jw_info


 * Misc Variables, etc.

bytebuf		dc.l	0
delbuf		dcb.b	30,0
ksv		dc.w	0
dfbyte		dc.b	0
	even


	END