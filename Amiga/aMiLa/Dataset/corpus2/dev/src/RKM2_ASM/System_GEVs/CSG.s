
	INCDIR	WORK:Include/

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	exec/execbase.i
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
PUBLIC_MEM	EQU	MEMF_PUBLIC!MEMF_CLEAR
FILE_SIZE	EQU	100
TRUE		EQU	-1
FALSE		EQU	0

	move.l	4.w,a6

	lea	config,a5
	move.w	LIB_VERSION(a6),(a5)
	move.w	LIB_REVISION(a6),2(a5)
	move.w	LIB_VERSION(a6),ksv

	moveq.l	#LIB_VER,d0
	lea	dos_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_DOSBase
	beq	exit_quit
	cmpi.w	#36,(a5)
	ble	exit_wrongks
	movea.l	_DOSBase(pc),a0
	move.w	LIB_VERSION(a0),4(a5)
	move.w	LIB_REVISION(a0),6(a5)

	moveq.l	#LIB_VER,d0
	lea	int_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_IntuitionBase
	beq	exit_closedos
	movea.l	_IntuitionBase(pc),a0
	move.w	LIB_VERSION(a0),8(a5)
	move.w	LIB_REVISION(a0),10(a5)

	moveq.l	#LIB_VER,d0
	lea	graf_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_GfxBase
	beq	exit_closeint
	movea.l	_GfxBase(pc),a0
	move.w	LIB_VERSION(a0),12(a5)
	move.w	LIB_REVISION(a0),14(a5)

	moveq.l	#LIB_VER,d0
	lea	icon_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_IconBase
	beq	exit_closegfx
	movea.l	_IconBase(pc),a0
	move.w	LIB_VERSION(a0),16(a5)
	move.w	LIB_REVISION(a0),18(a5)

	moveq.l	#LIB_VER,d0
	lea	wb_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_WorkbenchBase
	beq	exit_closeicon
	movea.l	_WorkbenchBase(pc),a0
	move.w	LIB_VERSION(a0),20(a5)
	move.w	LIB_REVISION(a0),22(a5)

	moveq.l	#LIB_VER,d0
	lea	utility_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_UtilityBase
	beq	exit_closewb
	movea.l	_UtilityBase(pc),a0
	move.w	LIB_VERSION(a0),24(a5)
	move.w	LIB_REVISION(a0),26(a5)

	moveq.l	#LIB_VER,d0
	lea	gadtools_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_GadtoolsBase
	beq	exit_closeutility
	movea.l	_GadtoolsBase(pc),a0
	move.w	LIB_VERSION(a0),28(a5)
	move.w	LIB_REVISION(a0),30(a5)

	moveq.l	#LIB_VER,d0
	lea	expansion_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_ExpansionBase
	beq	exit_closegadtools
	movea.l	_ExpansionBase(pc),a0
	move.w	LIB_VERSION(a0),32(a5)
	move.w	LIB_REVISION(a0),34(a5)

	moveq.l	#LIB_VER,d0
	lea	keymap_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_KeymapBase
	beq	exit_closeexpansion
	movea.l	_KeymapBase(pc),a0
	move.w	LIB_VERSION(a0),36(a5)
	move.w	LIB_REVISION(a0),38(a5)

	moveq.l	#LIB_VER,d0
	lea	layers_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_LayersBase
	beq	exit_closekeymap
	movea.l	_LayersBase(pc),a0
	move.w	LIB_VERSION(a0),40(a5)
	move.w	LIB_REVISION(a0),42(a5)

	moveq.l	#LIB_VER,d0
	lea	math_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_MathBase
	beq	exit_closelayers
	movea.l	_MathBase(pc),a0
	move.w	LIB_VERSION(a0),44(a5)
	move.w	LIB_REVISION(a0),46(a5)

 * Open a Console Window.

	move.l	#MODE_NEWFILE,d2
	move.l	#cname,d1
	move.l	_DOSBase(pc),a6
	jsr	_LVOOpen(a6)
	move.l	d0,cfh
	beq	exit_closemath
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
	movea.l	#mvstg20,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	mpo2
	move.b	#1,7(a3)
	bra.s	mpto1

mpo2	movea.l	a4,a0
	movea.l	#mvstg21,a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	mpo6
	move.b	#2,7(a3)
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
	movea.l	#mvstg20,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	mpa2
	move.b	#1,7(a3)
	bra.s	mpta1

mpa2	movea.l	28(a2),a0
	movea.l	#mvstg21,a1
	bsr	compare_bytes
	tst.l	d0
	bne.s	mpta1
	move.b	#2,7(a3)

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
	move.l	#PUBLIC_MEM,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,bytebuf
	beq	exit_closeconfile

 * Do the KickStart GEVs.

	move.w	ksv,d1
	bsr	convert_number
	move.l	#ksv_gev,d1
	bsr	save_ngev
	move.l	4.w,a6
	move.w	SoftVer(a6),d1
	bsr	convert_number
	move.l	#ksr_gev,d1
	bsr	save_ngev

 * Do the IPrefs, ConClip, WB, RAD, CPU, Co-Processors, FPU, EClock, VBlank,
 *        PowerSupply, Chips (Agnus, Denise, Alice and Lisa), Chip-Mode
 *        (Original, Enhanced and Best), Current TV and Default TV Modes
 *        GEVs. All the above GEVs are classed as A.S.E's basic GEVs.
 *
 * With regards to IPrefs. The Port List and TaskWait List are checked
 * for A600 and A1200 support respectively.

	lea	PortList(a3),a4
	move.l	(a4),d0
	tst.l	d0
	beq.s	iprefs
	movea.l	a4,a0
	movea.l	LH_TAILPRED(a4),a1
	cmpa.l	a0,a1
	beq.s	iprefs
	movea.l	a4,a0
	lea	ipro_stg(pc),a1
	move.l	4.w,a6
	jsr	_LVOFindName(a6)
	tst.l	d0
	beq.s	no_oip
	move.l	#ipro_gev,d1
	move.l	#mvstg6,d2
	moveq.l	#4,d3
	bsr	save_gev
	bra.s	cclip

no_oip	move.l	#ipro_gev,d1
	move.l	#mvstg16,d2
	moveq.l	#3,d3
	bsr	save_gev

cclip	movea.l	a4,a0
	lea	ccr_stg(pc),a1
	move.l	4.w,a6
	jsr	_LVOFindName(a6)
	tst.l	d0
	beq.s	no_ccr
	move.l	#ccr_gev,d1
	move.l	#mvstg6,d2
	moveq.l	#4,d3
	bsr	save_gev
	bra.s	iprefs

no_ccr	move.l	#ccr_gev,d1
	move.l	#mvstg16,d2
	moveq.l	#3,d3
	bsr	save_gev

iprefs	lea	TaskWait(a3),a4
	move.l	(a4),d0
	tst.l	d0
	beq	cpu
	movea.l	a4,a0
	movea.l	LH_TAILPRED(a4),a1
	cmpa.l	a0,a1
	beq	cpu
	movea.l	a4,a0
	lea	ipr_stg(pc),a1
	move.l	4.w,a6
	jsr	_LVOFindName(a6)
	tst.l	d0
	beq.s	no_ip
	move.l	#ipr_gev,d1
	move.l	#mvstg6,d2
	moveq.l	#4,d3
	bsr	save_gev
	bra.s	wbr

no_ip	move.l	#ipr_gev,d1
	move.l	#mvstg16,d2
	moveq.l	#3,d3
	bsr	save_gev

wbr	movea.l	a4,a0
	lea	wb_stg(pc),a1
	move.l	4.w,a6
	jsr	_LVOFindName(a6)
	tst.l	d0
	beq.s	no_wbr
	move.l	#wb_gev,d1
	move.l	#mvstg6,d2
	moveq.l	#4,d3
	bsr	save_gev
	bra.s	rad

no_wbr	move.l	#wb_gev,d1
	move.l	#mvstg16,d2
	moveq.l	#3,d3
	bsr	save_gev

rad	movea.l	a4,a0
	lea	rad_stg(pc),a1
	move.l	4.w,a6
	jsr	_LVOFindName(a6)
	tst.l	d0
	beq.s	no_rad
	move.l	#rad_gev,d1
	move.l	#mvstg6,d2
	moveq.l	#4,d3
	bsr	save_gev
	bra.s	cpu

no_rad	move.l	#rad_gev,d1
	move.l	#mvstg16,d2
	moveq.l	#3,d3
	bsr	save_gev

cpu	clr.l	d4
	clr.l	d5
	move.w	AttnFlags(a3),d5
	tst.w	d5
	beq.s	cpu_0
	move.w	d5,d4
	and.w	#$000F,d4
	cmpi.w	#$000F,d4
	beq	cpu_4
	move.w	d5,d4
	and.w	#$0007,d4
	cmpi.w	#$0007,d4
	beq.s	cpu_3
	move.w	d5,d4
	and.w	#$0003,d4
	cmpi.w	#$0003,d4
	beq.s	cpu_2
	move.w	d5,d4
	and.w	#$0001,d4
	cmpi.w	#$0001,d4
	beq.s	cpu_1
	move.l	#cpu_gev,d1
	move.l	#unknown,d2
	moveq.l	#8,d3
	bsr	save_gev
	bra.s	cop

cpu_0	move.l	#cpu_gev,d1
	move.l	#cpu0_stg,d2
	moveq.l	#6,d3
	bsr	save_gev
	bra.s	cop

cpu_1	move.l	#cpu_gev,d1
	move.l	#cpu1_stg,d2
	moveq.l	#6,d3
	bsr	save_gev
	bra.s	cop

cpu_2	move.l	#cpu_gev,d1
	move.l	#cpu2_stg,d2
	moveq.l	#6,d3
	bsr	save_gev
	bra.s	cop

cpu_3	move.l	#cpu_gev,d1
	move.l	#cpu3_stg,d2
	moveq.l	#6,d3
	bsr	save_gev
	bra.s	cop

cpu_4	move.l	#cpu_gev,d1
	move.l	#cpu4_stg,d2
	moveq.l	#6,d3
	bsr	save_gev

cop	move.w	d5,d4
	and.w	#$0030,d4
	cmpi.w	#$0030,d4
	beq.s	cop_2
	move.w	d5,d4
	and.w	#$0010,d4
	cmpi.w	#$0010,d4
	beq.s	cop_1
	move.l	#cop_gev,d1
	move.l	#none_found,d2
	moveq.l	#11,d3
	bsr	save_gev
	bra.s	fpu

cop_1	move.l	#cop_gev,d1
	move.l	#cop1_stg,d2
	moveq.l	#6,d3
	bsr	save_gev
	bra.s	fpu

cop_2	move.l	#cop_gev,d1
	move.l	#cop2_stg,d2
	moveq.l	#6,d3
	bsr	save_gev

fpu	move.w	d5,d4
	and.w	#$0078,d4
	cmpi.w	#$0078,d4
	beq.s	fpu_e
	move.w	d5,d4
	and.w	#$0048,d4
	cmpi.w	#$0048,d4
	beq.s	fpu_o
	move.l	#fpu_gev,d1
	move.l	#none_found,d2
	moveq.l	#11,d3
	bsr	save_gev
	bra.s	ecf

fpu_o	move.l	#fpu_gev,d1
	move.l	#fpu0_stg,d2
	moveq.l	#18,d3
	bsr	save_gev
	bra.s	ecf

fpu_e	move.l	#fpu_gev,d1
	move.l	#fpu1_stg,d2
	moveq.l	#15,d3
	bsr	save_gev

ecf	clr.l	d5
	move.l	ex_EClockFrequency(a3),d5
	cmpi.l	#709379,d5
	beq.s	ecf_uk
	cmpi.l	#715909,d5
	beq.s	ecf_us
	move.l	#ecf_gev,d1
	move.l	#error_stg,d2
	moveq.l	#6,d3
	bsr	save_gev
	bra.s	vbf

ecf_uk	move.l	#ecf_gev,d1
	move.l	#ecf0_stg,d2
	moveq.l	#18,d3
	bsr	save_gev
	bra.s	vbf

ecf_us	move.l	#ecf_gev,d1
	move.l	#ecf1_stg,d2
	moveq.l	#19,d3
	bsr	save_gev

vbf	clr.l	d5
	move.b	VBlankFrequency(a3),d5
	cmpi.b	#50,d5
	beq.s	vbf_uk
	cmpi.b	#60,d5
	beq.s	vbf_us
	clr.l	d1
	move.b	d5,d1
	bsr	convert_number
	move.l	#vbf_gev,d1
	bsr	save_ngev
	bra.s	psf

vbf_uk	move.l	#vbf_gev,d1
	move.l	#hzf0_stg,d2
	moveq.l	#9,d3
	bsr	save_gev
	bra.s	psf

vbf_us	move.l	#vbf_gev,d1
	move.l	#hzf1_stg,d2
	moveq.l	#9,d3
	bsr	save_gev

psf	clr.l	d5
	move.b	PowerSupplyFrequency(a3),d5
	cmpi.b	#50,d5
	beq.s	psf_uk
	cmpi.b	#60,d5
	beq.s	psf_us
	clr.l	d1
	move.b	d5,d1
	bsr	convert_number
	move.l	#psf_gev,d1
	bsr	save_ngev
	bra.s	chips

psf_uk	move.l	#psf_gev,d1
	move.l	#hzf0_stg,d2
	moveq.l	#9,d3
	bsr	save_gev
	bra.s	chips

psf_us	move.l	#psf_gev,d1
	move.l	#hzf1_stg,d2
	moveq.l	#9,d3
	bsr	save_gev

chips	clr.l	d5
	clr.l	d4
	movea.l	_GfxBase,a3
	move.b	gb_ChipRevBits0(a3),d5
	move.b	d5,d4
	and.b	#GFXF_HR_AGNUS,d4
	cmpi.b	#GFXF_HR_AGNUS,d4
	bne.s	no_ag
	move.l	#agnus_gev,d1
	move.l	#found_stg,d2
	moveq.l	#6,d3
	bsr	save_gev
	bra.s	denise

no_ag	move.l	#agnus_gev,d1
	move.l	#not_found,d2
	moveq.l	#10,d3
	bsr	save_gev

denise	move.b	d5,d4
	and.b	#GFXF_HR_DENISE,d4
	cmpi.b	#GFXF_HR_DENISE,d4
	bne.s	no_den
	move.l	#denise_gev,d1
	move.l	#found_stg,d2
	moveq.l	#6,d3
	bsr	save_gev
	bra.s	alice

no_den	move.l	#denise_gev,d1
	move.l	#not_found,d2
	moveq.l	#10,d3
	bsr	save_gev

alice	move.b	d5,d4
	and.b	#GFXF_AA_ALICE,d4
	cmpi.b	#GFXF_AA_ALICE,d4
	bne.s	no_al
	move.l	#alice_gev,d1
	move.l	#found_stg,d2
	moveq.l	#6,d3
	bsr	save_gev
	bra.s	lisa

no_al	move.l	#alice_gev,d1
	move.l	#not_found,d2
	moveq.l	#10,d3
	bsr	save_gev

lisa	move.b	d5,d4
	and.b	#GFXF_AA_LISA,d4
	cmpi.b	#GFXF_AA_LISA,d4
	bne.s	no_lis
	move.l	#lisa_gev,d1
	move.l	#found_stg,d2
	moveq.l	#6,d3
	bsr	save_gev
	bra.s	orig

no_lis	move.l	#lisa_gev,d1
	move.l	#not_found,d2
	moveq.l	#10,d3
	bsr	save_gev

orig	cmpi.b	#17,d5
	bne.s	ecs
	move.l	#cmode_gev,d1
	move.l	#original,d2
	moveq.l	#9,d3
	bsr	save_gev
	bra.s	cur_tv

ecs	cmpi.b	#19,d5
	bne.s	best
	move.l	#cmode_gev,d1
	move.l	#enhanced,d2
	moveq.l	#9,d3
	bsr	save_gev
	bra.s	cur_tv

best	cmpi.b	#31,d5
	bne.s	u_cm
	move.l	#cmode_gev,d1
	move.l	#best_stg,d2
	moveq.l	#5,d3
	bsr	save_gev
	bra.s	cur_tv

u_cm	move.l	#cmode_gev,d1
	move.l	#unknown,d2
	moveq.l	#8,d3
	bsr	save_gev

cur_tv	clr.l	d5
	movea.l	gb_current_monitor(a3),a0
	move.w	ms_BeamCon0(a0),d5
	tst.w	d5
	beq.s	ctv_us
	cmpi.w	#32,d5
	beq.s	ctv_uk
	move.l	#ctv_gev,d1
	move.l	#unknown,d2
	moveq.l	#8,d3
	bsr	save_gev
	bra.s	def_tv

ctv_us	move.l	#ctv_gev,d1
	move.l	#ntsc_stg,d2
	moveq.l	#5,d3
	bsr	save_gev
	bra.s	def_tv

ctv_uk	move.l	#ctv_gev,d1
	move.l	#pal_stg,d2
	moveq.l	#4,d3
	bsr	save_gev

def_tv	clr.l	d5
	movea.l	gb_default_monitor(a3),a0
	move.w	ms_BeamCon0(a0),d5
	tst.w	d5
	beq.s	dtv_us
	cmpi.w	#32,d5
	beq.s	dtv_uk
	move.l	#dtv_gev,d1
	move.l	#unknown,d2
	moveq.l	#8,d3
	bsr	save_gev
	bra.s	do_lib

dtv_us	move.l	#dtv_gev,d1
	move.l	#ntsc_stg,d2
	moveq.l	#5,d3
	bsr	save_gev
	bra.s	do_lib

dtv_uk	move.l	#dtv_gev,d1
	move.l	#pal_stg,d2
	moveq.l	#4,d3
	bsr	save_gev

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
	bsr	lib_lr
	bra	do_dev

lib_lv	lea	config,a5
	clr.l	d1
	move.w	(a5),d1
	bsr	convert_number
	move.l	#execv_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	4(a5),d1
	bsr	convert_number
	move.l	#dosv_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	8(a5),d1
	bsr	convert_number
	move.l	#intv_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	12(a5),d1
	bsr	convert_number
	move.l	#gfxv_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	16(a5),d1
	bsr	convert_number
	move.l	#iconv_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	20(a5),d1
	bsr	convert_number
	move.l	#wbv_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	24(a5),d1
	bsr	convert_number
	move.l	#utilv_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	28(a5),d1
	bsr	convert_number
	move.l	#gadtv_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	32(a5),d1
	bsr	convert_number
	move.l	#expv_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	36(a5),d1
	bsr	convert_number
	move.l	#kmv_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	40(a5),d1
	bsr	convert_number
	move.l	#layv_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	44(a5),d1
	bsr	convert_number
	move.l	#mathv_gev,d1
	bsr	save_ngev
	rts

lib_lr	lea	config,a5
	clr.l	d1
	move.w	2(a5),d1
	bsr	convert_number
	move.l	#execr_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	6(a5),d1
	bsr	convert_number
	move.l	#dosr_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	10(a5),d1
	bsr	convert_number
	move.l	#intr_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	14(a5),d1
	bsr	convert_number
	move.l	#gfxr_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	18(a5),d1
	bsr	convert_number
	move.l	#iconr_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	22(a5),d1
	bsr	convert_number
	move.l	#wbr_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	26(a5),d1
	bsr	convert_number
	move.l	#utilr_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	30(a5),d1
	bsr	convert_number
	move.l	#gadtr_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	34(a5),d1
	bsr	convert_number
	move.l	#expr_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	38(a5),d1
	bsr	convert_number
	move.l	#kmr_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	42(a5),d1
	bsr	convert_number
	move.l	#layr_gev,d1
	bsr	save_ngev
	clr.l	d1
	move.w	46(a5),d1
	bsr	convert_number
	move.l	#mathr_gev,d1
	bsr	save_ngev
	rts

do_dev	lea	config,a4
	clr.l	d4
	move.b	1(a3),d4
	tst.b	d4
	beq	do_dfx
	bsr	open_audio
	cmpi.b	#23,d5
	bne.s	card
	cmpi.b	#1,d4
	beq.s	aud_v
	cmpi.b	#2,d4
	beq.s	aud_r
	clr.l	d1
	move.w	48(a4),d1
	bsr	convert_number
	move.l	#audv_gev,d1
	bsr	save_ngev
	bra.s	aud_r

aud_v	clr.l	d1
	move.w	48(a4),d1
	bsr	convert_number
	move.l	#audv_gev,d1
	bsr	save_ngev
	bra.s	aud_c

aud_r	clr.l	d1
	move.w	50(a4),d1
	bsr	convert_number
	move.l	#audr_gev,d1
	bsr	save_ngev

aud_c	bsr	close_audio

card	clr.l	d4
	move.b	1(a3),d4
	bsr	open_carddisk
	cmpi.b	#23,d5
	bne.s	csole
	cmpi.b	#1,d4
	beq.s	card_v
	cmpi.b	#2,d4
	beq.s	card_r
	clr.l	d1
	move.w	52(a4),d1
	bsr	convert_number
	move.l	#cardv_gev,d1
	bsr	save_ngev
	bra.s	card_r

card_v	clr.l	d1
	move.w	52(a4),d1
	bsr	convert_number
	move.l	#cardv_gev,d1
	bsr	save_ngev
	bra.s	card_c

card_r	clr.l	d1
	move.w	54(a4),d1
	bsr	convert_number
	move.l	#cardr_gev,d1
	bsr	save_ngev

card_c	bsr	close_carddisk

csole	clr.l	d4
	move.b	1(a3),d4
	bsr	open_console
	cmpi.b	#23,d5
	bne.s	game
	cmpi.b	#1,d4
	beq.s	csol_v
	cmpi.b	#2,d4
	beq.s	csol_r
	clr.l	d1
	move.w	56(a4),d1
	bsr	convert_number
	move.l	#consolev_gev,d1
	bsr	save_ngev
	bra.s	csol_r

csol_v	clr.l	d1
	move.w	56(a4),d1
	bsr	convert_number
	move.l	#consolev_gev,d1
	bsr	save_ngev
	bra.s	csol_c

csol_r	clr.l	d1
	move.w	58(a4),d1
	bsr	convert_number
	move.l	#consoler_gev,d1
	bsr	save_ngev

csol_c	bsr	close_console

game	clr.l	d4
	move.b	1(a3),d4
	bsr	open_gameport
	cmpi.b	#23,d5
	bne.s	input
	cmpi.b	#1,d4
	beq.s	game_v
	cmpi.b	#2,d4
	beq.s	game_r
	clr.l	d1
	move.w	60(a4),d1
	bsr	convert_number
	move.l	#gamev_gev,d1
	bsr	save_ngev
	bra.s	game_r

game_v	clr.l	d1
	move.w	60(a4),d1
	bsr	convert_number
	move.l	#gamev_gev,d1
	bsr	save_ngev
	bra.s	game_c

game_r	clr.l	d1
	move.w	62(a4),d1
	bsr	convert_number
	move.l	#gamer_gev,d1
	bsr	save_ngev

game_c	bsr	close_gameport

input	clr.l	d4
	move.b	1(a3),d4
	bsr	open_input
	cmpi.b	#23,d5
	bne.s	keyb
	cmpi.b	#1,d4
	beq.s	inp_v
	cmpi.b	#2,d4
	beq.s	inp_r
	clr.l	d1
	move.w	64(a4),d1
	bsr	convert_number
	move.l	#inputv_gev,d1
	bsr	save_ngev
	bra.s	inp_r

inp_v	clr.l	d1
	move.w	64(a4),d1
	bsr	convert_number
	move.l	#inputv_gev,d1
	bsr	save_ngev
	bra.s	inp_c

inp_r	clr.l	d1
	move.w	66(a4),d1
	bsr	convert_number
	move.l	#inputr_gev,d1
	bsr	save_ngev

inp_c	bsr	close_input

keyb	clr.l	d4
	move.b	1(a3),d4
	bsr	open_keyboard
	cmpi.b	#23,d5
	bne.s	ramd
	cmpi.b	#1,d4
	beq.s	keyb_v
	cmpi.b	#2,d4
	beq.s	keyb_r
	clr.l	d1
	move.w	68(a4),d1
	bsr	convert_number
	move.l	#keybv_gev,d1
	bsr	save_ngev
	bra.s	keyb_r

keyb_v	clr.l	d1
	move.w	68(a4),d1
	bsr	convert_number
	move.l	#keybv_gev,d1
	bsr	save_ngev
	bra.s	keyb_c

keyb_r	clr.l	d1
	move.w	70(a4),d1
	bsr	convert_number
	move.l	#keybr_gev,d1
	bsr	save_ngev

keyb_c	bsr	close_keyboard

ramd	clr.l	d4
	move.b	1(a3),d4
	bsr	open_ramdrive
	cmpi.b	#23,d5
	bne.s	timer
	cmpi.b	#1,d4
	beq.s	ramd_v
	cmpi.b	#2,d4
	beq.s	ramd_r
	clr.l	d1
	move.w	72(a4),d1
	bsr	convert_number
	move.l	#ramdv_gev,d1
	bsr	save_ngev
	bra.s	ramd_r

ramd_v	clr.l	d1
	move.w	72(a4),d1
	bsr	convert_number
	move.l	#ramdv_gev,d1
	bsr	save_ngev
	bra.s	ramd_c

ramd_r	clr.l	d1
	move.w	74(a4),d1
	bsr	convert_number
	move.l	#ramdr_gev,d1
	bsr	save_ngev

ramd_c	bsr	close_ramdrive

timer	clr.l	d4
	move.b	1(a3),d4
	bsr	open_timer
	cmpi.b	#23,d5
	bne.s	tdisk
	cmpi.b	#1,d4
	beq.s	time_v
	cmpi.b	#2,d4
	beq.s	time_r
	clr.l	d1
	move.w	76(a4),d1
	bsr	convert_number
	move.l	#timerv_gev,d1
	bsr	save_ngev
	bra.s	time_r

time_v	clr.l	d1
	move.w	76(a4),d1
	bsr	convert_number
	move.l	#timerv_gev,d1
	bsr	save_ngev
	bra.s	time_c

time_r	clr.l	d1
	move.w	78(a4),d1
	bsr	convert_number
	move.l	#timerr_gev,d1
	bsr	save_ngev

time_c	bsr	close_timer

tdisk	clr.l	d4
	move.b	1(a3),d4
	clr.l	d6
	clr.l	d7
	bsr	open_trackdisk
	cmpi.b	#23,d5
	bne.s	do_dfx
	cmpi.b	#1,d4
	beq.s	td_v
	cmpi.b	#2,d4
	beq.s	td_r
	clr.l	d1
	move.w	80(a4),d1
	bsr	convert_number
	move.l	#tdiskv_gev,d1
	bsr	save_ngev
	bra.s	td_r

td_v	clr.l	d1
	move.w	80(a4),d1
	bsr	convert_number
	move.l	#tdiskv_gev,d1
	bsr	save_ngev
	bra.s	td_c

td_r	clr.l	d1
	move.w	82(a4),d1
	bsr	convert_number
	move.l	#tdiskr_gev,d1
	bsr	save_ngev

td_c	bsr	close_trackdisk

do_dfx	lea	config,a4
	clr.l	d4
	move.b	2(a3),d4
	tst.b	d4
	beq	do_prt
	cmpi.b	#1,d4
	beq.s	df0
	cmpi.b	#2,d4
	beq.s	df1
	cmpi.b	#3,d4
	beq.s	df2
	cmpi.b	#4,d4
	beq.s	df3
	bsr.s	do_df0
	bsr.s	do_df1
	bsr	do_df2
	bsr	do_df3
	bra	do_prt

df0	bsr.s	do_df0
	bra	do_prt

df1	bsr.s	do_df1
	bra	do_prt

df2	bsr	do_df2
	bra	do_prt

df3	bsr	do_df3
	bra	do_prt

do_df0	clr.l	d6
	clr.l	d7
	bsr	open_trackdisk
	cmpi.b	#23,d5
	bne.s	no_df0
	move.l	#dfzero_gev,d1
	move.l	#mvstg6,d2
	moveq.l	#4,d3
	bsr	save_gev
	bsr	close_trackdisk
	bra.s	df0_e

no_df0	move.l	#dfzero_gev,d1
	move.l	#mvstg16,d2
	moveq.l	#3,d3
	bsr	save_gev

df0_e	rts

do_df1	moveq.l	#1,d6
	clr.l	d7
	bsr	open_trackdisk
	cmpi.b	#23,d5
	bne.s	no_df1
	move.l	#dfone_gev,d1
	move.l	#mvstg6,d2
	moveq.l	#4,d3
	bsr	save_gev
	bsr	close_trackdisk
	bra.s	df1_e

no_df1	move.l	#dfone_gev,d1
	move.l	#mvstg16,d2
	moveq.l	#3,d3
	bsr	save_gev

df1_e	rts

do_df2	moveq.l	#2,d6
	clr.l	d7
	bsr	open_trackdisk
	cmpi.b	#23,d5
	bne.s	no_df2
	move.l	#dftwo_gev,d1
	move.l	#mvstg6,d2
	moveq.l	#4,d3
	bsr	save_gev
	bsr	close_trackdisk
	bra.s	df2_e

no_df2	move.l	#dftwo_gev,d1
	move.l	#mvstg16,d2
	moveq.l	#3,d3
	bsr	save_gev

df2_e	rts

do_df3	moveq.l	#3,d6
	clr.l	d7
	bsr	open_trackdisk
	cmpi.b	#23,d5
	bne.s	no_df3
	move.l	#dfthree_gev,d1
	move.l	#mvstg6,d2
	moveq.l	#4,d3
	bsr	save_gev
	bsr	close_trackdisk
	bra.s	df3_e

no_df3	move.l	#dfthree_gev,d1
	move.l	#mvstg16,d2
	moveq.l	#3,d3
	bsr	save_gev

df3_e	rts

do_prt	lea	config,a4
	clr.l	d4
	move.b	3(a3),d4
	tst.b	d4
	beq.s	chipm
	bsr	open_parallel
	cmpi.b	#23,d5
	bne.s	chipm
	bsr	query_parallel
	bsr	close_parallel

chipm	lea	config,a4
	clr.l	d4
	move.b	4(a3),d4
	tst.b	d4
	beq	fastm
	cmpi.b	#1,d4
	beq.s	c_free
	cmpi.b	#2,d4
	beq.s	c_tot
	cmpi.b	#3,d4
	beq.s	c_most
	bsr.s	chipf
	bsr.s	chipt
	bsr.s	chipl
	bra	fastm

c_free	bsr.s	chipf
	bra	fastm

c_tot	bsr.s	chipt
	bra	fastm

c_most	bsr.s	chipl
	bra	fastm

chipf	moveq.l	#MEMF_CHIP,d1
	move.l	4.w,a6
	jsr	_LVOAvailMem(a6)
	movea.l	bytebuf(pc),a0
	bsr	bits_to_ascii
	movea.l	bytebuf(pc),a0
	addq	#2,a0
	move.l	a0,d2
	move.l	#cmfree_gev,d1
	moveq.l	#9,d3
	bsr	save_gev
	rts

chipt	move.l	#MEMF_CHIP!MEMF_TOTAL,d1
	move.l	4.w,a6
	jsr	_LVOAvailMem(a6)
	movea.l	bytebuf(pc),a0
	bsr	bits_to_ascii
	movea.l	bytebuf(pc),a0
	addq	#2,a0
	move.l	a0,d2
	move.l	#cmtotal_gev,d1
	moveq.l	#9,d3
	bsr	save_gev
	rts

chipl	move.l	#MEMF_CHIP!MEMF_LARGEST,d1
	move.l	4.w,a6
	jsr	_LVOAvailMem(a6)
	movea.l	bytebuf(pc),a0
	bsr	bits_to_ascii
	movea.l	bytebuf(pc),a0
	addq	#2,a0
	move.l	a0,d2
	move.l	#cmlargest_gev,d1
	moveq.l	#9,d3
	bsr	save_gev
	rts

fastm	lea	config,a4
	clr.l	d4
	move.b	5(a3),d4
	tst.b	d4
	beq	anym
	cmpi.b	#1,d4
	beq.s	f_free
	cmpi.b	#2,d4
	beq.s	f_tot
	cmpi.b	#3,d4
	beq.s	f_most
	bsr.s	fastf
	bsr.s	fastt
	bsr.s	fastl
	bra	anym

f_free	bsr.s	fastf
	bra	anym

f_tot	bsr.s	fastt
	bra	anym

f_most	bsr.s	fastl
	bra	anym

fastf	moveq.l	#MEMF_FAST,d1
	move.l	4.w,a6
	jsr	_LVOAvailMem(a6)
	movea.l	bytebuf(pc),a0
	bsr	bits_to_ascii
	movea.l	bytebuf(pc),a0
	addq	#2,a0
	move.l	a0,d2
	move.l	#fmfree_gev,d1
	moveq.l	#9,d3
	bsr	save_gev
	rts

fastt	move.l	#MEMF_FAST!MEMF_TOTAL,d1
	move.l	4.w,a6
	jsr	_LVOAvailMem(a6)
	movea.l	bytebuf(pc),a0
	bsr	bits_to_ascii
	movea.l	bytebuf(pc),a0
	addq	#2,a0
	move.l	a0,d2
	move.l	#fmtotal_gev,d1
	moveq.l	#9,d3
	bsr	save_gev
	rts

fastl	move.l	#MEMF_FAST!MEMF_LARGEST,d1
	move.l	4.w,a6
	jsr	_LVOAvailMem(a6)
	movea.l	bytebuf(pc),a0
	bsr	bits_to_ascii
	movea.l	bytebuf(pc),a0
	addq	#2,a0
	move.l	a0,d2
	move.l	#fmlargest_gev,d1
	moveq.l	#9,d3
	bsr	save_gev
	rts

anym	lea	config,a4
	clr.l	d4
	move.b	6(a3),d4
	tst.b	d4
	beq	jport
	cmpi.b	#1,d4
	beq.s	a_free
	cmpi.b	#2,d4
	beq.s	a_tot
	cmpi.b	#3,d4
	beq.s	a_most
	bsr.s	anyf
	bsr.s	anyt
	bsr.s	anyl
	bra	jport

a_free	bsr.s	anyf
	bra	jport

a_tot	bsr.s	anyt
	bra	jport

a_most	bsr.s	anyl
	bra	jport

anyf	moveq.l	#MEMF_ANY,d1
	move.l	4.w,a6
	jsr	_LVOAvailMem(a6)
	movea.l	bytebuf(pc),a0
	bsr	bits_to_ascii
	movea.l	bytebuf(pc),a0
	addq	#2,a0
	move.l	a0,d2
	move.l	#amfree_gev,d1
	moveq.l	#9,d3
	bsr	save_gev
	rts

anyt	move.l	#MEMF_ANY!MEMF_TOTAL,d1
	move.l	4.w,a6
	jsr	_LVOAvailMem(a6)
	movea.l	bytebuf(pc),a0
	bsr	bits_to_ascii
	movea.l	bytebuf(pc),a0
	addq	#2,a0
	move.l	a0,d2
	move.l	#amtotal_gev,d1
	moveq.l	#9,d3
	bsr	save_gev
	rts

anyl	move.l	#MEMF_ANY!MEMF_LARGEST,d1
	move.l	4.w,a6
	jsr	_LVOAvailMem(a6)
	movea.l	bytebuf(pc),a0
	bsr	bits_to_ascii
	movea.l	bytebuf(pc),a0
	addq	#2,a0
	move.l	a0,d2
	move.l	#amlargest_gev,d1
	moveq.l	#9,d3
	bsr	save_gev
	rts

jport	lea	config,a4
	clr.l	d4
	move.b	7(a3),d4
	tst.b	d4
	beq.s	ptype
	bsr	open_input
	cmpi.b	#23,d5
	bne.s	ptype
	cmpi.b	#1,d4
	beq.s	set_0
	cmpi.b	#2,d4
	beq.s	set_1
	bra.s	set_1

set_0	movea.l	inputreq(pc),a1
	move.w	#IND_SETMPORT,IO_COMMAND(a1)
	move.l	#byte0,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)
	jsr	_LVODoIO(a6)
	bsr	close_input
	bra.s	ptype

set_1	movea.l	inputreq(pc),a1
	move.w	#IND_SETMPORT,IO_COMMAND(a1)
	move.l	#byte1,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)
	jsr	_LVODoIO(a6)
	bsr	close_input

ptype	lea	config,a4
	clr.l	d4
	move.b	8(a3),d4
	tst.b	d4
	beq	do_di0
	bsr	open_input
	cmpi.b	#23,d5
	bne	do_di0
	cmpi.b	#1,d4
	beq.s	set_t0
	cmpi.b	#2,d4
	beq.s	set_t2
	cmpi.b	#3,d4
	beq.s	set_t3
	cmpi.b	#4,d4
	beq.s	set_t1
	bra.s	set_t1

set_t0	movea.l	inputreq(pc),a1
	move.w	#IND_SETMTYPE,IO_COMMAND(a1)
	move.l	#byte0,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)
	jsr	_LVODoIO(a6)
	bsr	close_input
	bra.s	do_di0

set_t2	movea.l	inputreq(pc),a1
	move.w	#IND_SETMTYPE,IO_COMMAND(a1)
	move.l	#byte2,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)
	jsr	_LVODoIO(a6)
	bsr	close_input
	bra.s	do_di0

set_t3	movea.l	inputreq(pc),a1
	move.w	#IND_SETMTYPE,IO_COMMAND(a1)
	move.l	#byte3,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)
	jsr	_LVODoIO(a6)
	bsr	close_input
	bra.s	do_di0

set_t1	movea.l	inputreq(pc),a1
	move.w	#IND_SETMTYPE,IO_COMMAND(a1)
	move.l	#byte1,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)
	jsr	_LVODoIO(a6)
	bsr	close_input

do_di0	lea	config,a4
	clr.l	d4
	move.b	9(a3),d4
	tst.b	d4
	beq.s	do_di1
	clr.l	d6
	moveq.l	#TDF_ALLOW_NON_3_5,d7
	bsr	open_trackdisk
	cmpi.b	#23,d5
	bne.s	do_di1
	move.b	#48,dfbyte
	bsr	query_hardware
	bsr	close_trackdisk
	bsr	query_software

do_di1	lea	config,a4
	clr.l	d4
	move.b	10(a3),d4
	tst.b	d4
	beq.s	do_di2
	moveq.l	#1,d6
	moveq.l	#TDF_ALLOW_NON_3_5,d7
	bsr	open_trackdisk
	cmpi.b	#23,d5
	bne.s	do_di2
	move.b	#49,dfbyte
	bsr.s	query_hardware
	bsr	close_trackdisk
	bsr	query_software

do_di2	lea	config,a4
	clr.l	d4
	move.b	11(a3),d4
	tst.b	d4
	beq.s	do_di3
	moveq.l	#2,d6
	moveq.l	#TDF_ALLOW_NON_3_5,d7
	bsr	open_trackdisk
	cmpi.b	#23,d5
	bne.s	do_di3
	move.b	#50,dfbyte
	bsr.s	query_hardware
	bsr	close_trackdisk
	bsr	query_software

do_di3	lea	config,a4
	clr.l	d4
	move.b	12(a3),d4
	tst.b	d4
	beq	hdinfo
	moveq.l	#3,d6
	moveq.l	#TDF_ALLOW_NON_3_5,d7
	bsr	open_trackdisk
	cmpi.b	#23,d5
	bne	hdinfo
	move.b	#51,dfbyte
	bsr.s	query_hardware
	bsr	close_trackdisk
	bsr	query_software
	bra	hdinfo

query_hardware
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
	movea.l	tdiskreq(pc),a1
	move.w	#TD_GETDRIVETYPE,IO_COMMAND(a1)
	bsr	sendio
	tst.b	diskerr
	bne	di_end
	move.l	disksts,d1
	cmpi.l	#DRIVE3_5,d1
	beq.s	dsize0
	cmpi.l	#DRIVE5_25,d1
	beq.s	dsize1
	cmpi.l	#DRIVE3_5_150RPM,d1
	beq.s	dsize2
	bra.s	dsizeu

dsize0	move.l	#dsize_gev,d1
	move.l	#dsize0_stg,d2
	moveq.l	#10,d3
	bsr	save_gev
	bra.s	motor

dsize1	move.l	#dsize_gev,d1
	move.l	#dsize1_stg,d2
	moveq.l	#10,d3
	bsr	save_gev
	bra.s	motor

dsize2	move.l	#dsize_gev,d1
	move.l	#dsize2_stg,d2
	moveq.l	#10,d3
	bsr	save_gev
	bra.s	motor

dsizeu	move.l	#dsize_gev,d1
	move.l	#unknown,d2
	moveq.l	#8,d3
	bsr	save_gev

motor	movea.l	tdiskreq(pc),a1
	move.w	#TD_MOTOR,IO_COMMAND(a1)
	move.l	#0,IO_LENGTH(a1)
	bsr	sendio
	tst.b	diskerr
	bne	di_end
	move.l	disksts,d1
	tst.l	d1
	beq.s	motor0
	cmp	#1,d1
	beq.s	motor1
	bra.s	motoru

motor0	move.l	#motor_gev,d1
	move.l	#mvstg18,d2
	moveq.l	#4,d3
	bsr	save_gev
	bra.s	swaps

motor1	move.l	#motor_gev,d1
	move.l	#mvstg19,d2
	moveq.l	#3,d3
	bsr	save_gev
	bra.s	swaps

motoru	move.l	#motor_gev,d1
	move.l	#unknown,d2
	moveq.l	#8,d3
	bsr	save_gev

swaps	movea.l	tdiskreq(pc),a1
	move.w	#TD_CHANGENUM,IO_COMMAND(a1)
	bsr	sendio
	move.l	disksts,diskswaps
	tst.b	diskerr
	bne	di_end
	move.l	diskswaps,d1
	bsr	convert_number
	move.l	#swaps_gev,d1
	bsr	save_ngev
	movea.l	tdiskreq,a1
	move.w	#TD_CHANGESTATE,IO_COMMAND(a1)
	bsr	sendio
	tst.b	diskerr
	bne	di_end
	move.l	disksts,drivests
	tst.l	drivests
	bne	empty
	move.l	#empty_gev,d1
	move.l	#mvstg16,d2
	moveq.l	#3,d3
	bsr	save_gev
	moveq.l	#dg_SIZEOF,d0
	move.l	#PUBLIC_MEM,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,geoptr
	beq	di_end
	movea.l	tdiskreq(pc),a1
	move.w	#TD_GETGEOMETRY,IO_COMMAND(a1)
	move.l	geoptr(pc),IO_DATA(a1)
	jsr	_LVODoIO(a6)
        tst.l	d0
        bne	free_dgmem
	move.b	#0,diskerr
	movea.l	geoptr(pc),a0
	move.l	(a0),d1
	move.l	d1,sectorsize
	bsr	convert_number
	move.l	#sectors_gev,d1
	bsr	save_ngev
	movea.l	geoptr(pc),a0
	addq.l	#4,a0
	move.l	(a0),d1
	bsr	convert_number
	move.l	#totsects_gev,d1
	bsr	save_ngev
	movea.l	geoptr(pc),a0
	addq.l	#8,a0
	move.l	(a0),d1
	move.l	d1,cylinders
	bsr	convert_number
	move.l	#cylinders_gev,d1
	bsr	save_ngev
	movea.l	geoptr(pc),a0
	lea	12(a0),a0
	move.l	(a0),d1
	bsr	convert_number
	move.l	#cylsects_gev,d1
	bsr	save_ngev
	movea.l	geoptr(pc),a0
	lea	16(a0),a0
	move.l	(a0),d1
	move.l	d1,heads
	bsr	convert_number
	move.l	#heads_gev,d1
	bsr	save_ngev
	movea.l	geoptr(pc),a0
	lea	20(a0),a0
	move.l	(a0),d1
	move.l	d1,tracksectors
	bsr	convert_number
	move.l	#tracks_gev,d1
	bsr	save_ngev
	movea.l	geoptr(pc),a0
	lea	24(a0),a0
	move.l	(a0),d1
	cmpi.l	#MEMF_ANY,d1
	beq.s	bmt_0
	cmpi.l	#MEMF_PUBLIC,d1
	beq.s	bmt_1
	cmpi.l	#MEMF_CHIP,d1
	beq.s	bmt_2
	cmpi.l	#MEMF_FAST,d1
	beq.s	bmt_3
	cmpi.l	#MEMF_LOCAL,d1
	beq.s	bmt_4
	cmpi.l	#MEMF_24BITDMA,d1
	beq.s	bmt_5
	cmpi.l	#MEMF_KICK,d1
	beq.s	bmt_6
	bra	bmt_u

bmt_0	move.l	#bmt_gev,d1
	move.l	#bmt0_stg,d2
	moveq.l	#4,d3
	bsr	save_gev
	bra	hwtype

bmt_1	move.l	#bmt_gev,d1
	move.l	#bmt1_stg,d2
	moveq.l	#7,d3
	bsr	save_gev
	bra.s	hwtype

bmt_2	move.l	#bmt_gev,d1
	move.l	#bmt2_stg,d2
	moveq.l	#5,d3
	bsr	save_gev
	bra.s	hwtype

bmt_3	move.l	#bmt_gev,d1
	move.l	#bmt3_stg,d2
	moveq.l	#5,d3
	bsr	save_gev
	bra.s	hwtype

bmt_4	move.l	#bmt_gev,d1
	move.l	#bmt4_stg,d2
	moveq.l	#6,d3
	bsr	save_gev
	bra.s	hwtype

bmt_5	move.l	#bmt_gev,d1
	move.l	#bmt5_stg,d2
	moveq.l	#9,d3
	bsr	save_gev
	bra.s	hwtype

bmt_6	move.l	#bmt_gev,d1
	move.l	#bmt6_stg,d2
	moveq.l	#5,d3
	bsr	save_gev
	bra.s	hwtype

bmt_u	move.l	#bmt_gev,d1
	move.l	#unknown,d2
	moveq.l	#8,d3
	bsr	save_gev

hwtype	movea.l	geoptr(pc),a0
	lea	28(a0),a0
	clr.l	d1
	move.b	(a0),d1
	cmpi.b	#DG_DIRECT_ACCESS,d1
	beq.s	ddt_0
	cmpi.b	#DG_SEQUENTIAL_ACCESS,d1
	beq.s	ddt_1
	cmpi.b	#DG_PRINTER,d1
	beq.s	ddt_2
	cmpi.b	#DG_PROCESSOR,d1
	beq.s	ddt_3
	cmpi.b	#DG_WORM,d1
	beq	ddt_4
	cmpi.b	#DG_CDROM,d1
	beq	ddt_5
	cmpi.b	#DG_SCANNER,d1
	beq	ddt_6
	cmpi.b	#DG_OPTICAL_DISK,d1
	beq	ddt_7
	cmpi.b	#DG_MEDIUM_CHANGER,d1
	beq	ddt_8
	cmpi.b	#DG_COMMUNICATION,d1
	beq	ddt_9
	bra	ddt_u

ddt_0	move.l	#ddt_gev,d1
	move.l	#ddt0_stg,d2
	moveq.l	#14,d3
	bsr	save_gev
	bra	dflags

ddt_1	move.l	#ddt_gev,d1
	move.l	#ddt1_stg,d2
	moveq.l	#18,d3
	bsr	save_gev
	bra	dflags

ddt_2	move.l	#ddt_gev,d1
	move.l	#ddt2_stg,d2
	moveq.l	#8,d3
	bsr	save_gev
	bra	dflags

ddt_3	move.l	#ddt_gev,d1
	move.l	#ddt3_stg,d2
	moveq.l	#10,d3
	bsr	save_gev
	bra	dflags

ddt_4	move.l	#ddt_gev,d1
	move.l	#ddt4_stg,d2
	moveq.l	#5,d3
	bsr	save_gev
	bra.s	dflags

ddt_5	move.l	#ddt_gev,d1
	move.l	#ddt5_stg,d2
	moveq.l	#6,d3
	bsr	save_gev
	bra.s	dflags

ddt_6	move.l	#ddt_gev,d1
	move.l	#ddt6_stg,d2
	moveq.l	#8,d3
	bsr	save_gev
	bra.s	dflags

ddt_7	move.l	#ddt_gev,d1
	move.l	#ddt7_stg,d2
	moveq.l	#13,d3
	bsr	save_gev
	bra.s	dflags

ddt_8	move.l	#ddt_gev,d1
	move.l	#ddt8_stg,d2
	moveq.l	#15,d3
	bsr	save_gev
	bra.s	dflags

ddt_9	move.l	#ddt_gev,d1
	move.l	#ddt9_stg,d2
	moveq.l	#14,d3
	bsr	save_gev
	bra.s	dflags

ddt_u	move.l	#ddt_gev,d1
	move.l	#unknown,d2
	moveq.l	#8,d3
	bsr	save_gev

dflags	movea.l	geoptr(pc),a0
	lea	29(a0),a0
	clr.l	d0
	clr.l	d1
	move.b	(a0),d0
	move.b	d0,d1
	and.b	#1,d1
	cmpi.b	#DGF_REMOVABLE,d1
	beq.s	flag0
	bra.s	flagu

flag0	move.l	#flag_gev,d1
	move.l	#flag0_stg,d2
	moveq.l	#10,d3
	bsr	save_gev
	bra.s	dkbf

flagu	move.l	#flag_gev,d1
	move.l	#unknown,d2
	moveq.l	#8,d3
	bsr	save_gev

dkbf	movea.l	geoptr(pc),a0
	move.l	cylinders,d0
	move.l	heads,d3
	move.l	tracksectors,d2
	move.l	sectorsize,d1
	mulu	d0,d3
	mulu	d3,d2
	mulu	d2,d1
	divu	#1024,d1
	bsr	convert_number
	move.l	#ddfs_gev,d1
	bsr	save_ngev

free_dgmem
	movea.l	geoptr(pc),a1
	moveq.l	#dg_SIZEOF,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)
	move.b	dfbyte,tab_gev+2
	move.b	dfbyte,htest_gev+2
	move.b	dfbyte,eject_gev+2
	tst.l	drivests
	bne	empty
	movea.l	tdiskreq(pc),a1
	move.w	#TD_PROTSTATUS,IO_COMMAND(a1)
	bsr	sendio
	tst.b	diskerr
	bne	di_end
	tst.l	disksts
	beq.s	fdnp
	move.l	#tab_gev,d1
	move.l	#mvstg6,d2
	moveq.l	#4,d3
	bsr	save_gev
	bra.s	htest

fdnp	move.l	#tab_gev,d1
	move.l	#mvstg16,d2
	moveq.l	#3,d3
	bsr	save_gev

htest	clr.l	d7
	movea.l	#htnums,a5

htloop	movea.l	tdiskreq(pc),a1
	move.w	#TD_SEEK,IO_COMMAND(a1)
	clr.l	d6
	move.b	(a5)+,d6
	mulu	#512,d6
	move.l	d6,IO_OFFSET(a1)
	bsr	sendio
	tst.b	diskerr
	bne.s	ht_err
	addq.b	#1,d7
	cmpi.b	#18,d7
	blt.s	htloop
	bra.s	ht_ok

ht_err	move.l	#htest_gev,d1
	move.l	#error_stg,d2
	moveq.l	#6,d3
	bsr	save_gev
	bra.s	di_end

ht_ok	move.l	#htest_gev,d1
	move.l	#okay_stg,d2
	moveq.l	#5,d3
	bsr	save_gev
	tst.l	drivests
	bne.s	geo_e
	movea.l	tdiskreq(pc),a1
	move.w	#TD_EJECT,IO_COMMAND(a1)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)
        tst.l	d0
        bne.s	not_ej
	move.b	#0,diskerr
	move.l	#eject_gev,d1
	move.l	#mvstg6,d2
	moveq.l	#4,d3
	bsr	save_gev
	bra.s	geo_e

not_ej	move.l	#eject_gev,d1
	move.l	#mvstg16,d2
	moveq.l	#3,d3
	bsr	save_gev

geo_e	bra.s	di_end

empty	move.l	#empty_gev,d1
	move.l	#mvstg6,d2
	moveq.l	#4,d3
	bsr	save_gev

di_end	rts

sendio	move.l	4.w,a6
	jsr	_LVOSendIO(a6)
	movea.l	tdiskreq(pc),a1
	jsr	_LVOWaitIO(a6)
        tst.l	d0
        bne.s	di_end
	movea.l	tdiskreq(pc),a1
        move.b	IO_ERROR(a1),diskerr
	move.l	IO_ACTUAL(a1),disksts
	rts

query_software
	move.b	dfbyte,dfstg+2
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
	tst.l	drivests
	bne	exit_disk
	move.l	#fib_SIZEOF,d0
	move.l	#PUBLIC_MEM,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,fibptr
	beq	exit_disk
	move.b	#100,diskerr
	move.l	#dfstg,d1
	moveq.l	#SHARED_LOCK,d2
	move.l	_DOSBase(pc),a6
	jsr	_LVOLock(a6)
	move.l	d0,lockptr
	beq.s	freemem_fib
	move.b	#0,diskerr
	move.l	lockptr(pc),d1
	move.l	fibptr(pc),d2
	jsr	_LVOExamine(a6)
	cmpi.l	#-1,d0
	bne.s	freemem_fib
	movea.l	fibptr(pc),a0
	addq	#8,a0
	bsr	find_length
	tst.l	d0
	ble.s	fn_err
	move.l	#fname_gev,d1
	move.l	a0,d2
	move.l	d0,d3
	bsr	save_gev
	bra.s	freemem_fib

fn_err	move.l	#fname_gev,d1
	move.l	#error_stg,d2
	moveq.l	#6,d3
	bsr	save_gev

freemem_fib
	movea.l	fibptr(pc),a1
	move.l	#fib_SIZEOF,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)
	move.b	diskerr,d0
	cmpi.b	#100,d0
	beq	exit_disk
	moveq.l	#id_SIZEOF,d0
	move.l	#PUBLIC_MEM,d1
	jsr	_LVOAllocMem(a6)
	move.l	d0,dibptr
	beq	free_lock
	move.l	lockptr(pc),d1
	move.l	dibptr(pc),d2
	move.l	_DOSBase(pc),a6
	jsr	_LVOInfo(a6)
	tst.l	d0
	beq	freemem_dib
	movea.l	dibptr(pc),a0
	lea	24(a0),a0
	move.l	(a0),d0
	cmpi.l	#ID_DOS_DISK,d0
	beq.s	dos0
	cmpi.l	#ID_FFS_DISK,d0
	beq.s	dos1
	cmpi.l	#ID_INTER_DOS_DISK,d0
	beq	dos2
	cmpi.l	#ID_INTER_FFS_DISK,d0
	beq	dos3
	cmpi.l	#ID_FASTDIR_DOS_DISK,d0
	beq	dos4
	cmpi.l	#ID_FASTDIR_FFS_DISK,d0
	beq	dos5
	cmpi.l	#ID_KICKSTART_DISK,d0
	beq	dos6
	cmpi.l	#ID_MSDOS_DISK,d0
	beq	dos7
	cmpi.l	#ID_UNREADABLE_DISK,d0
	beq	dos8
	cmpi.l	#ID_NOT_REALLY_DOS,d0
	beq	dos9
	cmpi.l	#ID_NO_DISK_PRESENT,d0
	beq	dos10
	bra	dosu

dos0	move.l	#dostype_gev,d1
	move.l	#dos0_stg,d2
	moveq.l	#15,d3
	bsr	save_gev
	bra	state

dos1	move.l	#dostype_gev,d1
	move.l	#dos1_stg,d2
	moveq.l	#15,d3
	bsr	save_gev
	bra	state

dos2	move.l	#dostype_gev,d1
	move.l	#dos2_stg,d2
	moveq.l	#20,d3
	bsr	save_gev
	bra	state

dos3	move.l	#dostype_gev,d1
	move.l	#dos3_stg,d2
	moveq.l	#20,d3
	bsr	save_gev
	bra	state

dos4	move.l	#dostype_gev,d1
	move.l	#dos4_stg,d2
	moveq.l	#21,d3
	bsr	save_gev
	bra	state

dos5	move.l	#dostype_gev,d1
	move.l	#dos5_stg,d2
	moveq.l	#21,d3
	bsr	save_gev
	bra.s	state

dos6	move.l	#dostype_gev,d1
	move.l	#dos6_stg,d2
	moveq.l	#10,d3
	bsr	save_gev
	bra.s	state

dos7	move.l	#dostype_gev,d1
	move.l	#dos7_stg,d2
	moveq.l	#7,d3
	bsr	save_gev
	bra.s	state

dos8	move.l	#dostype_gev,d1
	move.l	#dos8_stg,d2
	moveq.l	#11,d3
	bsr	save_gev
	bra.s	state

dos9	move.l	#dostype_gev,d1
	move.l	#dos9_stg,d2
	moveq.l	#5,d3
	bsr	save_gev
	bra.s	state

dos10	move.l	#dostype_gev,d1
	move.l	#dos10_stg,d2
	moveq.l	#8,d3
	bsr	save_gev
	bra.s	state

dosu	move.l	#dostype_gev,d1
	move.l	#unknown,d2
	moveq.l	#8,d3
	bsr	save_gev

state	movea.l	dibptr(pc),a0
	move.l	(a0),d1
	bsr	convert_number
	move.l	#errors_gev,d1
	bsr	save_ngev
	movea.l	dibptr(pc),a0
	addq.w	#8,a0
	move.l	(a0),d0
	cmpi.l	#80,d0
	beq.s	state0
	cmpi.l	#81,d0
	beq.s	state1
	cmpi.l	#82,d0
	beq.s	state2
	bra.s	stateu

state0	move.l	#state_gev,d1
	move.l	#state0_stg,d2
	moveq.l	#14,d3
	bsr	save_gev
	bra.s	blocks

state1	move.l	#state_gev,d1
	move.l	#state1_stg,d2
	moveq.l	#11,d3
	bsr	save_gev
	bra.s	blocks

state2	move.l	#state_gev,d1
	move.l	#state2_stg,d2
	moveq.l	#19,d3
	bsr	save_gev
	bra.s	blocks

stateu	move.l	#state_gev,d1
	move.l	#unknown,d2
	moveq.l	#8,d3
	bsr	save_gev

blocks	movea.l	dibptr(pc),a0
	lea	12(a0),a0
	move.l	(a0),d1
	move.l	d1,d5
	bsr	convert_number
	move.l	#nob_gev,d1
	bsr	save_ngev
	movea.l	dibptr(pc),a0
	lea	16(a0),a0
	move.l	(a0),d1
	move.l	d1,d6
	bsr	convert_number
	move.l	#nobu_gev,d1
	bsr	save_ngev
	movea.l	dibptr(pc),a0
	lea	20(a0),a0
	move.l	(a0),d1
	move.l	d1,bpb
	bsr	convert_number
	move.l	#bpb_gev,d1
	bsr	save_ngev
	move.l	bpb,d7
	mulu	d5,d7
	divu	#1024,d7
	clr.l	d1
	move.w	d7,d1
	movea.l	dibptr(pc),a0
	bsr	convert_number
	move.l	#kbcq_gev,d1
	bsr	save_ngev
	swap	d7
	clr.l	d1
	move.w	d7,d1
	movea.l	dibptr(pc),a0
	bsr	convert_number
	move.l	#kbcr_gev,d1
	bsr	save_ngev
	move.l	bpb,d7
	mulu	d6,d7
	divu	#1024,d7
	clr.l	d1
	move.w	d7,d1
	movea.l	dibptr(pc),a0
	bsr	convert_number
	move.l	#kbuq_gev,d1
	bsr	save_ngev
	swap	d7
	clr.l	d1
	move.w	d7,d1
	movea.l	dibptr(pc),a0
	bsr	convert_number
	move.l	#kbur_gev,d1
	bsr	save_ngev
	clr.l	d0
	move.l	bpb,d0
	mulu	d5,d0
	divu	#1024,d0
	move.l	d0,d5
	move.l	bpb,d7
	mulu	d6,d7
	divu	#1024,d7
	clr.l	d1
	clr.l	d2
	move.w	d5,d1
	move.w	d7,d2
	sub.w	d2,d1
	movea.l	dibptr(pc),a0
	bsr	convert_number
	move.l	#kbfq_gev,d1
	bsr	save_ngev
	swap	d5
	swap	d7
	clr.l	d1
	clr.l	d2
	move.w	d5,d1
	move.w	d7,d2
	cmp.l	d2,d1
	ble.s	ltoet
	sub.w	d2,d1
	bra.s	ltoet_end

ltoet
	sub.w	d1,d2
	move.w	d2,d1

ltoet_end
	movea.l	dibptr(pc),a0
	bsr	convert_number
	move.l	#kbfr_gev,d1
	bsr	save_ngev
	movea.l	dibptr(pc),a0
	lea	32(a0),a0
	move.l	(a0),d1
	tst.l	d1
	beq.s	niuse
	move.l	#inuse_gev,d1
	move.l	#mvstg6,d2
	moveq.l	#4,d3
	bsr	save_gev
	bra.s	freemem_dib

niuse	move.l	#inuse_gev,d1
	move.l	#mvstg16,d2
	moveq.l	#3,d3
	bsr	save_gev

freemem_dib
	move.l	dibptr(pc),a1
	moveq.l	#id_SIZEOF,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

free_lock
	move.l	lockptr(pc),d1
	move.l	_DOSBase(pc),a6
	jsr	_LVOUnLock(a6)

exit_disk


	rts


hdinfo

	bra	exit_freemem


 * Branch-Routines.

open_audio
	clr.l	d5
	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,audport
	beq.s	aud_e
	move.l	d0,a0
	moveq.l	#ioa_SIZEOF,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,audreq
	beq.s	exit_audport
	move.l	d0,a1
	move.l	#masks,ioa_Data(a1)
	move.l	#4,ioa_Length(a1)
	move.l	#ADCMD_ALLOCATE,IO_COMMAND(a1)
	lea	aud_name(pc),a0
	clr.l	d0
	clr.l	d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne.s	exit_audreq
	move.b	#23,d5
	movea.l	audreq(pc),a5
	movea.l	IO_DEVICE(a5),a5
	move.w	LIB_VERSION(a5),48(a4)
	move.w	LIB_REVISION(a5),50(a4)

aud_e	rts

close_audio
	movea.l	audreq(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

exit_audreq
	movea.l	audreq(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

exit_audport
	movea.l	audport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)
	bsr	flush
	rts

open_carddisk
	clr.l	d5
	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,cardport
	beq.s	card_e
	move.l	d0,a0
	moveq.l	#IOSTD_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,cardreq
	beq.s	exit_cardport
	move.l	d0,a1
	lea	card_name(pc),a0
	clr.l	d0
	clr.l	d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne.s	exit_cardreq
	move.b	#23,d5
	movea.l	cardreq(pc),a5
	movea.l	IO_DEVICE(a5),a5
	move.w	LIB_VERSION(a5),52(a4)
	move.w	LIB_REVISION(a5),54(a4)

card_e	rts

close_carddisk
	movea.l	cardreq(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

exit_cardreq
	movea.l	cardreq(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

exit_cardport
	movea.l	cardport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)
	bsr	flush
	rts

open_console
	clr.l	d5
	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,consoleport
	beq.s	csol_e
	move.l	d0,a0
	moveq.l	#IOSTD_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,consolereq
	beq.s	exit_consoleport
	move.l	d0,a1
	lea	console_name(pc),a0
	moveq.l	#-1,d0
	clr.l	d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne.s	exit_consolereq
	move.b	#23,d5
	movea.l	consolereq(pc),a5
	movea.l	IO_DEVICE(a5),a5
	move.w	LIB_VERSION(a5),56(a4)
	move.w	LIB_REVISION(a5),58(a4)

csol_e	rts

close_console
	movea.l	consolereq(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

exit_consolereq
	movea.l	consolereq(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

exit_consoleport
	movea.l	consoleport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)
	bsr	flush
	rts

open_gameport
	clr.l	d5
	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,gameport
	beq.s	game_e
	move.l	d0,a0
	moveq.l	#IOSTD_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,gamereq
	beq.s	exit_gameport
	move.l	d0,a1
	lea	game_name(pc),a0
	clr.l	d0
	clr.l	d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne.s	exit_gamereq
	move.b	#23,d5
	movea.l	gamereq(pc),a5
	movea.l	IO_DEVICE(a5),a5
	move.w	LIB_VERSION(a5),60(a4)
	move.w	LIB_REVISION(a5),62(a4)

game_e	rts

close_gameport
	movea.l	gamereq(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

exit_gamereq
	movea.l	gamereq(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

exit_gameport
	movea.l	gameport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)
	bsr	flush
	rts

open_input
	clr.l	d5
	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,inputport
	beq.s	inp_e
	move.l	d0,a0
	moveq.l	#IOSTD_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,inputreq
	beq.s	exit_inputport
	move.l	d0,a1
	lea	input_name(pc),a0
	clr.l	d0
	clr.l	d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne.s	exit_inputreq
	move.b	#23,d5
	movea.l	inputreq(pc),a5
	movea.l	IO_DEVICE(a5),a5
	move.w	LIB_VERSION(a5),64(a4)
	move.w	LIB_REVISION(a5),66(a4)

inp_e	rts

close_input
	movea.l	inputreq(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

exit_inputreq
	movea.l	inputreq(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

exit_inputport
	movea.l	inputport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)
	bsr	flush
	rts

open_keyboard
	clr.l	d5
	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,keybport
	beq.s	keyb_e
	move.l	d0,a0
	moveq.l	#IOSTD_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,keybreq
	beq.s	exit_keybport
	move.l	d0,a1
	lea	keyb_name(pc),a0
	clr.l	d0
	clr.l	d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne.s	exit_keybreq
	move.b	#23,d5
	movea.l	keybreq(pc),a5
	movea.l	IO_DEVICE(a5),a5
	move.w	LIB_VERSION(a5),68(a4)
	move.w	LIB_REVISION(a5),70(a4)

keyb_e	rts

close_keyboard
	movea.l	keybreq(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

exit_keybreq
	movea.l	keybreq(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

exit_keybport
	movea.l	keybport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)
	bsr	flush
	rts

open_ramdrive
	clr.l	d5
	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,ramdport
	beq.s	ramd_e
	move.l	d0,a0
	moveq.l	#IOSTD_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,ramdreq
	beq.s	exit_ramdport
	move.l	d0,a1
	lea	ramd_name(pc),a0
	clr.l	d0
	clr.l	d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne.s	exit_ramdreq
	move.b	#23,d5
	movea.l	ramdreq(pc),a5
	movea.l	IO_DEVICE(a5),a5
	move.w	LIB_VERSION(a5),72(a4)
	move.w	LIB_REVISION(a5),74(a4)

ramd_e	rts

close_ramdrive
	movea.l	ramdreq(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

exit_ramdreq
	movea.l	ramdreq(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

exit_ramdport
	movea.l	ramdport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)
	bsr	flush
	rts

open_timer
	clr.l	d5
	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,timerport
	beq.s	time_e
	move.l	d0,a0
	moveq.l	#IOTV_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,timerreq
	beq.s	exit_timerport
	move.l	d0,a1
	lea	timer_name(pc),a0
	clr.l	d0
	clr.l	d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne.s	exit_timerreq
	move.l	timerreq(pc),a0
	move.l	IO_DEVICE(a0),_TimerBase
	move.b	#23,d5
	movea.l	timerreq(pc),a5
	movea.l	IO_DEVICE(a5),a5
	move.w	LIB_VERSION(a5),76(a4)
	move.w	LIB_REVISION(a5),78(a4)

time_e	rts

close_timer
	movea.l	timerreq(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

exit_timerreq
	movea.l	timerreq(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

exit_timerport
	movea.l	timerport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)
	bsr	flush
	rts

open_trackdisk
	clr.l	d5
	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,tdiskport
	beq.s	td_e
	move.l	d0,a0
	moveq.l	#IOTD_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,tdiskreq
	beq.s	exit_tdiskport
	move.l	d0,a1
	lea	tdisk_name(pc),a0
	move.l	d6,d0
	move.l	d7,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne.s	exit_tdiskreq
	move.b	#23,d5
	movea.l	tdiskreq(pc),a5
	movea.l	IO_DEVICE(a5),a5
	move.w	LIB_VERSION(a5),80(a4)
	move.w	LIB_REVISION(a5),82(a4)

td_e	rts

close_trackdisk
	movea.l	tdiskreq(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

exit_tdiskreq
	movea.l	tdiskreq(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

exit_tdiskport
	movea.l	tdiskport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)
	bsr	flush
	rts

open_parallel
	clr.l	d5
	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,parport
	beq.s	par_e
	move.l	d0,a0
	moveq.l	#IOEXTPar_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,parreq
	beq.s	exit_parport
	move.l	d0,a1
	lea	par_name(pc),a0
	clr.l	d0
	moveq.l	#PARF_SHARED,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne.s	exit_parreq
	move.b	#23,d5

par_e	rts

close_parallel
	movea.l	parreq(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

exit_parreq
	movea.l	parreq(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

exit_parport
	movea.l	parport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)
	bsr	flush
	rts

query_parallel
	clr.l	d6
	clr.l	d7
	movea.l	parreq(pc),a1
	move.w	#PDCMD_QUERY,IO_COMMAND(a1)
	move.l	4.w,a6
	jsr	_LVOSendIO(a6)
	movea.l	parreq(pc),a1
	move.b	IO_PARSTATUS(a1),d7
	jsr	_LVOWaitIO(a6)
        tst.l	d0
        bne.s	par_error
	move.b	d7,d6
	and.b	#$01,d6
	cmpi.b	#1,d6
	beq.s	par_offline
	move.b	d7,d6
	and.b	#$02,d6
	cmpi.b	#2,d6
	beq.s	par_paperout
	move.b	d7,d6
	and.b	#$04,d6
	cmpi.b	#4,d6
	bne.s	par_busy
	move.l	#par_gev,d1
	move.l	#ready,d2
	moveq.l	#14,d3
	bsr.s	save_gev
	bra.s	query_end

par_offline
	move.l	#par_gev,d1
	move.l	#offline,d2
	moveq.l	#9,d3
	bsr.s	save_gev
	bra.s	query_end

par_paperout
	move.l	#par_gev,d1
	move.l	#paperout,d2
	moveq.l	#10,d3
	bsr.s	save_gev
	bra.s	query_end

par_busy
	move.l	#par_gev,d1
	move.l	#busy_stg,d2
	moveq.l	#5,d3
	bsr.s	save_gev
	bra.s	query_end

par_error
	move.l	#par_gev,d1
	move.l	#error_stg,d2
	moveq.l	#6,d3
	bsr.s	save_gev

query_end
	rts


 * Sub-Routines.

save_ngev
	move.l	a0,d2
	moveq.l	#5,d3
	bsr.s	save_gev
	rts

save_gev
	move.l	#GVF_GLOBAL_ONLY!GVF_BINARY_VAR,d4
	move.l	_DOSBase(pc),a6
	jsr	_LVOSetVar(a6)
	rts

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

find_length
	movea.l	a0,a1
	clr.l	d0

not_nil
	tst.b	(a1)+
	beq.s	length_found
	addq.l	#1,d0
	bra.s	not_nil

length_found
	rts

convert_number
	movea.l	bytebuf(pc),a0
	bsr.s	long_to_ascii
	move.l	#0,(a0)
	subq.w	#4,a0
	rts

long_to_ascii
	divu	#1000,d1
	bsr.s	do_value
	divu	#100,d1
	bsr.s	do_value
	divu	#10,d1
	bsr	do_value

do_value
	add.w	#$30,d1
	move.b	d1,(a0)+
	clr.w	d1
	swap	d1
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

bits_to_ascii
	move.l	d0,d7
	move.l	#1000000000,d6
	moveq.l	#9,d5
do_num	move.l	d7,d0
	move.l	d6,d1
	move.l	_UtilityBase(pc),a6
	jsr	_LVOSDivMod32(a6)
	move.l	d1,d7
	add.b	#$30,d0
	move.b	d0,(a0)+
	move.l	d6,d0
	moveq.l	#10,d1
	jsr	_LVOUDivMod32(a6)
	move.l	d0,d6
	dbra	d5,do_num
	rts


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

exit_closemath
	movea.l	_MathBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

exit_closelayers
	movea.l	_LayersBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

exit_closekeymap
	movea.l	_KeymapBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

exit_closeexpansion
	movea.l	_ExpansionBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

exit_closegadtools
	movea.l	_GadtoolsBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

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
_GadtoolsBase	dc.l	0
_ExpansionBase	dc.l	0
_KeymapBase	dc.l	0
_MathBase	dc.l	0
_LayersBase	dc.l	0
_TimerBase	dc.l	0
dos_name	dc.b	'dos.library',0
int_name	dc.b	'intuition.library',0
graf_name	dc.b	'graphics.library',0
gadtools_name	dc.b	'gadtools.library',0
utility_name	dc.b	'utility.library',0
wb_name		dc.b	'workbench.library',0
expansion_name	dc.b	'expansion.library',0
layers_name	dc.b	'layers.library',0
math_name	dc.b	'mathffp.library',0
keymap_name	dc.b	'keymap.library',0
icon_name	dc.b	'icon.library',0
aud_name	dc.b	'audio.device',0
card_name	dc.b	'carddisk.device',0
game_name	dc.b	'gameport.device',0
input_name	dc.b	'input.device',0
keyb_name	dc.b	'keyboard.device',0
console_name	dc.b	'console.device',0
ramd_name	dc.b	'ramdrive.device',0
timer_name	dc.b	'timer.device',0
tdisk_name	dc.b	'trackdisk.device',0
par_name	dc.b	'parallel.device',0
	even


 * Device Variables.

audport		dc.l	0
audreq		dc.l	0
cardport	dc.l	0
cardreq		dc.l	0
consoleport	dc.l	0
consolereq	dc.l	0
gameport	dc.l	0
gamereq		dc.l	0
inputport	dc.l	0
inputreq	dc.l	0
keybport	dc.l	0
keybreq		dc.l	0
ramdport	dc.l	0
ramdreq		dc.l	0
timerport	dc.l	0
timerreq	dc.l	0
tdiskport	dc.l	0
tdiskreq	dc.l	0
parport		dc.l	0
parreq		dc.l	0
masks		dc.b	1,2,4,8
disksts		dc.l	0
diskswaps	dc.l	0
drivests	dc.l	0
geoptr		dc.l	0
fibptr		dc.l	0
dibptr		dc.l	0
lockptr		dc.l	0
diskkbsize	dc.l	0
diskkbused	dc.l	0
diskkbfree	dc.l	0
sectorsize	dc.l	0
totalsectors	dc.l	0
cylinders	dc.l	0
cylsectors	dc.l	0
heads		dc.l	0
tracksectors	dc.l	0
bufmemtype	dc.l	0
diskerr		dc.b	0
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
	dc.b	'LIBRARIES/K,DEVICES/K,DISKDRIVES/K,PRINTER/K,CHIPMEM/K,FASTMEM/K,ANYMEM/K,MOUSEINPORT/K,MOUSEPORTTYPE/K,DF0INFO/K,DF1INFO/K,DF2INFO/K,DF3INFO/K,HDINFO/K',0
	even

ftstg0		dc.b	'LIBRARIES',0
ftstg1		dc.b	'DEVICES',0
ftstg2		dc.b	'DISKDRIVES',0
ftstg3		dc.b	'PRINTER',0
ftstg4		dc.b	'CHIPMEM',0
ftstg5		dc.b	'FASTMEM',0
ftstg6		dc.b	'ANYMEM',0
ftstg7		dc.b	'MOUSEINPORT',0
ftstg8		dc.b	'MOUSEPORTTYPE',0
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

ipr_stg		dc.b	'« IPrefs »',0
wb_stg		dc.b	'Workbench',0
ipro_stg	dc.b	'IPrefs.rendezvous',0
ccr_stg		dc.b	'ConClip.rendezvous',0
rad_stg		dc.b	'RAD',0
cpu0_stg	dc.b	'68000',0
cpu1_stg	dc.b	'68010',0
cpu2_stg	dc.b	'68020',0
cpu3_stg	dc.b	'68030',0
cpu4_stg	dc.b	'68040',0
cop1_stg	dc.b	'68881',0
cop2_stg	dc.b	'68882',0
fpu0_stg	dc.b	'INSTRUCTIONS ONLY',0
fpu1_stg	dc.b	'EMULATION CODE',0
ecf0_stg	dc.b	'7.09379 MHZ - PAL',0
ecf1_stg	dc.b	'7.15909 MHZ - NTSC',0
original	dc.b	'ORIGINAL',0
enhanced	dc.b	'ENHANCED',0
best_stg	dc.b	'BEST',0
hzf0_stg	dc.b	'50 HERTZ',0
hzf1_stg	dc.b	'60 HERTZ',0
offline		dc.b	'OFF-LINE',0
paperout	dc.b	'PAPER-OUT',0
busy_stg	dc.b	'BUSY',0
ready		dc.b	'READY FOR USE',0
dsize0_stg	dc.b	'3½ INCHES',0
dsize1_stg	dc.b	'5¼ INCHES',0
dsize2_stg	dc.b	'3½ 150RPM',0
bmt0_stg	dc.b	'ANY',0
bmt1_stg	dc.b	'PUBLIC',0
bmt2_stg	dc.b	'CHIP',0
bmt3_stg	dc.b	'FAST',0
bmt4_stg	dc.b	'LOCAL',0
bmt5_stg	dc.b	'24BITDMA',0
bmt6_stg	dc.b	'KICK',0
ddt0_stg	dc.b	'DIRECT ACCESS',0
ddt1_stg	dc.b	'SEQUENTIAL ACCESS',0
ddt2_stg	dc.b	'PRINTER',0
ddt3_stg	dc.b	'PROCESSOR',0
ddt4_stg	dc.b	'WORM',0
ddt5_stg	dc.b	'CDROM',0
ddt6_stg	dc.b	'SCANNER',0
ddt7_stg	dc.b	'OPTICAL DISK',0
ddt8_stg	dc.b	'MEDIUM CHANGER',0
ddt9_stg	dc.b	'COMMUNICATION',0
flag0_stg	dc.b	'REMOVABLE',0
dos0_stg	dc.b	'OFS - ORIGINAL',0
dos1_stg	dc.b	'FFS - ORIGINAL',0
dos2_stg	dc.b	'OFS - INTERNATIONAL',0
dos3_stg	dc.b	'FFS - INTERNATIONAL',0
dos4_stg	dc.b	'OFS - FAST DIRECTORY',0
dos5_stg	dc.b	'FFS - FAST DIRECTORY',0
dos6_stg	dc.b	'KICKSTART',0
dos7_stg	dc.b	'MS-DOS',0
dos8_stg	dc.b	'UNREADABLE',0
dos9_stg	dc.b	'NDOS',0
dos10_stg	dc.b	'NO DISK',0
state0_stg	dc.b	'READABLE ONLY',0
state1_stg	dc.b	'VALIDATING',0
state2_stg	dc.b	'READABLE/WRITEABLE',0
dfstg		dc.b	'DF0:',0
okay_stg	dc.b	'OKAY',0
pal_stg		dc.b	'PAL',0
ntsc_stg	dc.b	'NTSC',0
unknown		dc.b	'UNKNOWN',0
none_found	dc.b	'NONE FOUND',0
not_found	dc.b	'NOT FOUND',0
found_stg	dc.b	'FOUND',0
error_stg	dc.b	'ERROR',0
	even


 * File Variables.

cfh	dc.l	0
config	ds.b	100
cname	dc.b	'CON:0/0/640/160/ Create Set-Up GEVs V2.01 - Written by: John White - Shareware (£2.50).',0
	even

jw_info
	dc.b	' ',10,'John White',10,'91 Comber House',10,'Comber Grove',10
	dc.b	'Camberwell',10,'London',10,'SE5 0LL',10,'ENGLAND',10,10
	dc.b	'Telephone: (+44) (020) 77018546',10,10
	dc.b	'Set-Up GEVs now being created.....',10,10,10
	even
jwi_len		equ	*-jw_info


 * Misc Variables, etc.

bytebuf		dc.l	0
bpb		dc.l	0
ksv		dc.w	0
byte0		dcb.b	1,0
byte1		dcb.b	1,1
byte2		dcb.b	1,2
byte3		dcb.b	1,3
htnums		dc.b	79,1,10,21,33,72,4,50,51,52,44,78,6,9,18,36,66,0
dfbyte		dc.b	0
	even


	END