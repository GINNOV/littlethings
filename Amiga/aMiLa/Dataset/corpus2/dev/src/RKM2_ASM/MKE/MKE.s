
	INCDIR  WORK:Include/

*        INCLUDE exec/exec_lib.i
*        INCLUDE exec/memory.i
*        INCLUDE intuition/intuition_lib.i
*        INCLUDE intuition/intuition.i
*        INCLUDE intuition/intuitionbase.i
*        INCLUDE graphics/graphics_lib.i
*        INCLUDE graphics/text.i
*        INCLUDE dos/dos_lib.i
*        INCLUDE dos/dos.i
*        INCLUDE workbench/icon_lib.i
*        INCLUDE workbench/startup.i
*        INCLUDE workbench/workbench.i
*        INCLUDE utility/utility_lib.i
*        INCLUDE utility/utility.i
*        INCLUDE libraries/gadtools_lib.i
*        INCLUDE libraries/gadtools.i
*        INCLUDE devices/input.i
*        INCLUDE devices/timer.i

	INCLUDE work:devpac/large.gs

        INCLUDE misc/easystart.i

LIB_VER         EQU     39
MEM_TYPE        EQU     MEMF_PUBLIC!MEMF_CLEAR
FILE_SIZE       EQU     100
TRUE            EQU     -1
FALSE           EQU     0

	move.l	4.w,a6

        moveq.l	#LIB_VER,d0
        lea     int_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,_IntuitionBase
        beq     exit_quit

        moveq.l	#LIB_VER,d0
        lea     graf_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,_GfxBase
        beq     exit_closeint

        moveq.l	#LIB_VER,d0
        lea     dos_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,_DOSBase
        beq     exit_closegfx

        moveq.l	#LIB_VER,d0
        lea     icon_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,_IconBase
        beq     exit_closedos

        moveq.l	#LIB_VER,d0
        lea     gadtools_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,_GadtoolsBase
        beq     exit_closeicon

 * Check the ToolTypes/CLI Arguments.

        tst.l   returnMsg
        beq     fromcli
        movea.l returnMsg,a0
        movea.l sm_ArgList(a0),a0
        beq     zero_arguments
        move.l  (a0),d1
	move.l	_DOSBase(pc),a6
        jsr	_LVOCurrentDir(a6)
        move.l  d0,olddir
        movea.l returnMsg,a0
        movea.l sm_ArgList(a0),a0
        movea.l wa_Name(a0),a0
	move.l	_IconBase(pc),a6
        jsr	_LVOGetDiskObject(a6)
        move.l  d0,doptr
        beq     zero_arguments
	movea.l	d0,a1
        move.l  do_ToolTypes(a1),ttptr
        movea.l ttptr,a0
        movea.l #ftstg0,a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	kqo1
	movea.l	d0,a4
        movea.l a4,a0
        movea.l #mvstg2,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   kco2
        move.b  #0,actmx
        bra.s   kqo1
kco2	movea.l a4,a0
        movea.l #mvstg3,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   kco3
        move.b  #1,actmx
        bra.s   kqo1
kco3	movea.l a4,a0
        movea.l #mvstg4,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   kco4
        move.b  #2,actmx
        bra.s   kqo1
kco4	movea.l a4,a0
        movea.l #mvstg5,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   kqo1
        move.b  #3,actmx
kqo1	movea.l ttptr,a0
        movea.l #ftstg1,a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq	kmo1
	movea.l	d0,a4
        movea.l a4,a0
        movea.l #mvstg6,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   kqo2
        move.b  #0,qcyc
        bra	kmo1
kqo2	movea.l a4,a0
        movea.l #mvstg7,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   kqo3
        move.b  #1,qcyc
        bra.s   kmo1
kqo3	movea.l a4,a0
        movea.l #mvstg8,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   kqo4
        move.b  #2,qcyc
        bra.s   kmo1
kqo4	movea.l a4,a0
        movea.l #mvstg9,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   kqo5
        move.b  #3,qcyc
        bra.s   kmo1
kqo5	movea.l a4,a0
        movea.l #mvstg10,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   kqo6
        move.b  #4,qcyc
        bra.s   kmo1
kqo6	movea.l a4,a0
        movea.l #mvstg11,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   kmo1
        move.b  #5,qcyc
kmo1	movea.l ttptr,a0
        movea.l #ftstg2,a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq	lamo1
	movea.l	d0,a4
        movea.l a4,a0
        movea.l #mvstg14,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   kmo2
        move.b  #0,mcyc
        bra	lamo1
kmo2	movea.l a4,a0
        movea.l #mvstg15,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   kmo3
        move.b  #1,mcyc
        bra	lamo1
kmo3	movea.l a4,a0
        movea.l #mvstg16,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   kmo4
        move.b  #2,mcyc
        bra	lamo1
kmo4	movea.l a4,a0
        movea.l #mvstg17,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   kmo5
        move.b  #3,mcyc
        bra.s   lamo1
kmo5	movea.l a4,a0
        movea.l #mvstg18,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   kmo6
        move.b  #4,mcyc
        bra.s   lamo1
kmo6	movea.l a4,a0
        movea.l #mvstg19,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   kmo7
        move.b  #5,mcyc
        bra.s   lamo1
kmo7	movea.l a4,a0
        movea.l #mvstg20,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   kmo8
        move.b  #6,mcyc
        bra.s   lamo1
kmo8	movea.l a4,a0
        movea.l #mvstg21,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   lamo1
        move.b  #7,mcyc
lamo1	movea.l ttptr,a0
        movea.l #ftstg3,a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	ramo1
	movea.l	d0,a4
        movea.l a4,a0
        movea.l #mvstg0,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   lamo2
        move.b  #0,amgal
        bra.s	ramo1
lamo2	movea.l a4,a0
        movea.l #mvstg1,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   ramo1
        move.b  #1,amgal
ramo1	movea.l ttptr,a0
        movea.l #ftstg4,a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	lsho1
	movea.l	d0,a4
        movea.l a4,a0
        movea.l #mvstg0,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   ramo2
        move.b  #0,amgar
        bra.s	lsho1
ramo2	movea.l a4,a0
        movea.l #mvstg1,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   lsho1
        move.b  #1,amgar
lsho1	movea.l ttptr,a0
        movea.l #ftstg5,a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	rsho1
	move.l	d0,a4
        movea.l a4,a0
        movea.l #mvstg0,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   lsho2
        move.b  #0,shftl
        bra.s	rsho1
lsho2	movea.l a4,a0
        movea.l #mvstg1,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   rsho1
        move.b  #1,shftl
rsho1	movea.l ttptr,a0
        movea.l #ftstg6,a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	lalto1
	movea.l	d0,a4
        movea.l a4,a0
        movea.l #mvstg0,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   rsho2
        move.b  #0,shftr
        bra.s	lalto1
rsho2	movea.l a4,a0
        movea.l #mvstg1,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   lalto1
        move.b  #1,shftr
lalto1	movea.l ttptr,a0
        movea.l #ftstg7,a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	ralto1
	movea.l	d0,a4
        movea.l a4,a0
        movea.l #mvstg0,a1
        jsr	_LVOMatchToolValue(a6) 
	tst.l	d0
        beq.s   lalto2
        move.b  #0,altl
        bra.s	ralto1
lalto2	movea.l a4,a0
        movea.l #mvstg1,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   ralto1
        move.b  #1,altl
ralto1	movea.l ttptr,a0
        movea.l #ftstg8,a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	ctrlo1
	movea.l	d0,a4
        movea.l a4,a0
        movea.l #mvstg0,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   ralto2
        move.b  #0,altr
        bra.s	ctrlo1
ralto2	movea.l a4,a0
        movea.l #mvstg1,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   ctrlo1
        move.b  #1,altr
ctrlo1	movea.l ttptr,a0
        movea.l #ftstg9,a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	lmseo1
	movea.l	d0,a4
        movea.l a4,a0
        movea.l #mvstg0,a1
        jsr	_LVOMatchToolValue(a6) 
	tst.l	d0
        beq.s   ctrlo2
        move.b  #0,ctrl
        bra.s	lmseo1
ctrlo2	movea.l a4,a0
        movea.l #mvstg1,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   lmseo1
        move.b  #1,ctrl
lmseo1	movea.l ttptr,a0
        movea.l #ftstg10,a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	mmseo1
	movea.l	d0,a4
        movea.l a4,a0
        movea.l #mvstg12,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   lmseo2
        move.b  #0,msel
        bra.s	mmseo1
lmseo2	movea.l a4,a0
        movea.l #mvstg13,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   mmseo1
        move.b  #1,msel
mmseo1	movea.l ttptr,a0
        movea.l #ftstg11,a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	rmseo1
	movea.l	d0,a4
        movea.l a4,a0
        movea.l #mvstg12,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   mmseo2
        move.b  #0,msem
        bra.s	rmseo1
mmseo2	movea.l a4,a0
        movea.l #mvstg13,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   rmseo1
        move.b  #1,msem
rmseo1	movea.l ttptr,a0
        movea.l #ftstg12,a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	cvoval
	movea.l	d0,a4
        movea.l a4,a0
        movea.l #mvstg12,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   rmseo2
        move.b  #0,mser
        bra.s	cvoval
rmseo2	movea.l a4,a0
        movea.l #mvstg13,a1
        jsr	_LVOMatchToolValue(a6)
	tst.l	d0
        beq.s   cvoval
        move.b  #1,mser
cvoval


free_diskobj
        movea.l doptr,a0
        jsr	_LVOFreeDiskObject(a6)
        bra     zero_arguments

fromcli	move.l  #template,d1
        lea     argv(pc),a1
        move.l  a1,d2
        moveq	#0,d3
	move.l	_DOSBase(pc),a6
        jsr	_LVOReadArgs(a6)
        move.l  d0,rdargs
        beq     zero_arguments
        lea     argv(pc),a2
        movea.l (a2),a0
        movea.l #mvstg2,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   kca2
        move.b  #0,actmx
        bra.s   kqa1
kca2	movea.l (a2),a0
        movea.l #mvstg3,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   kca3
        move.b  #1,actmx
        bra.s   kqa1
kca3	movea.l (a2),a0
        movea.l #mvstg4,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   kca4
        move.b  #2,actmx
        bra.s   kqa1
kca4	movea.l (a2),a0
        movea.l #mvstg5,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   kqa1
        move.b  #3,actmx
kqa1	movea.l 4(a2),a0
        movea.l #mvstg6,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   kqa2
        move.b  #0,qcyc
        bra	kma1
kqa2	movea.l 4(a2),a0
        movea.l #mvstg7,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   kqa3
        move.b  #1,qcyc
        bra.s   kma1
kqa3	movea.l 4(a2),a0
        movea.l #mvstg8,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   kqa4
        move.b  #2,qcyc
        bra.s   kma1
kqa4	movea.l 4(a2),a0
        movea.l #mvstg9,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   kqa5
        move.b  #3,qcyc
        bra.s   kma1
kqa5	movea.l 4(a2),a0
        movea.l #mvstg10,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   kqa6
        move.b  #4,qcyc
        bra.s   kma1
kqa6	movea.l 4(a2),a0
        movea.l #mvstg11,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   kma1
        move.b  #5,qcyc
kma1	movea.l 8(a2),a0
        movea.l #mvstg14,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   kma2
        move.b  #0,mcyc
        bra	lama1
kma2	movea.l 8(a2),a0
        movea.l #mvstg15,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   kma3
        move.b  #1,mcyc
        bra	lama1
kma3	movea.l 8(a2),a0
        movea.l #mvstg16,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   kma4
        move.b  #2,mcyc
        bra	lama1
kma4	movea.l 8(a2),a0
        movea.l #mvstg17,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   kma5
        move.b  #3,mcyc
        bra.s   lama1
kma5	movea.l 8(a2),a0
        movea.l #mvstg18,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   kma6
        move.b  #4,mcyc
        bra.s   lama1
kma6	movea.l 8(a2),a0
        movea.l #mvstg19,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   kma7
        move.b  #5,mcyc
        bra.s   lama1
kma7	movea.l 8(a2),a0
        movea.l #mvstg20,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   kma8
        move.b  #6,mcyc
        bra.s   lama1
kma8	movea.l 8(a2),a0
        movea.l #mvstg21,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   lama1
        move.b  #7,mcyc
lama1	movea.l	12(a2),a0
        movea.l #mvstg0,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   lama2
        move.b  #0,amgal
        bra.s   rama1
lama2	movea.l	12(a2),a0
        movea.l #mvstg1,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   rama1
        move.b  #1,amgal
rama1	movea.l	16(a2),a0
        movea.l #mvstg0,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   rama2
        move.b  #0,amgar
        bra.s   lsha1
rama2	movea.l	16(a2),a0
        movea.l #mvstg1,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   lsha1
        move.b  #1,amgar
lsha1	movea.l	20(a2),a0
        movea.l #mvstg0,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   lsha2
        move.b  #0,shftl
        bra.s   rsha1
lsha2	movea.l	20(a2),a0
        movea.l #mvstg1,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   rsha1
        move.b  #1,shftl
rsha1	movea.l	24(a2),a0
        movea.l #mvstg0,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   rsha2
        move.b  #0,shftr
        bra.s   lalta1
rsha2	movea.l	24(a2),a0
        movea.l #mvstg1,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   lalta1
        move.b  #1,shftr
lalta1	movea.l	28(a2),a0
        movea.l #mvstg0,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   lalta2
        move.b  #0,altl
        bra.s   ralta1
lalta2	movea.l	28(a2),a0
        movea.l #mvstg1,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   ralta1
        move.b  #1,altl
ralta1	movea.l	32(a2),a0
        movea.l #mvstg0,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   ralta2
        move.b  #0,altr
        bra.s   ctrla1
ralta2	movea.l	32(a2),a0
        movea.l #mvstg1,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   ctrla1
        move.b  #1,altr
ctrla1	movea.l	36(a2),a0
        movea.l #mvstg0,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   ctrla2
        move.b  #0,ctrl
        bra.s   lmsea1
ctrla2	movea.l	36(a2),a0
        movea.l #mvstg1,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   lmsea1
        move.b  #1,ctrl
lmsea1	movea.l	40(a2),a0
        movea.l #mvstg12,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   lmsea2
        move.b  #0,msel
        bra.s   mmsea1
lmsea2	movea.l	40(a2),a0
        movea.l #mvstg13,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   mmsea1
        move.b  #1,msel
mmsea1	movea.l	44(a2),a0
        movea.l #mvstg12,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   mmsea2
        move.b  #0,msem
        bra.s   rmsea1
mmsea2	movea.l	44(a2),a0
        movea.l #mvstg13,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   rmsea1
        move.b  #1,msem
rmsea1	movea.l	48(a2),a0
        movea.l #mvstg12,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   rmsea2
        move.b  #0,mser
        bra.s   cvaval
rmsea2	movea.l	48(a2),a0
        movea.l #mvstg13,a1
        bsr     compare_bytes
        tst.l   d0
        bne.s   cvaval
        move.b  #1,mser
cvaval


free_cliargs
        move.l  rdargs(pc),d1
        jsr	_LVOFreeArgs(a6)

zero_arguments

 * Set-Up a Message Port.

	move.l	4.w,a6
        jsr	_LVOForbid(a6)
        lea     portname(pc),a1
        jsr	_LVOFindPort(a6)
        tst.l   d0
        bne     port_exists
        moveq.l	#MP_SIZE,d0
        move.l  #MEMF_PUBLIC!MEMF_CLEAR,d1
        jsr	_LVOAllocMem(a6)
        move.l  d0,jwport
        beq	no_portmem
        move.l  jwport(pc),a5
        move.l  #0,(a5)				; LN_SUCC(a5)
        move.l  #0,LN_PRED(a5)
        move.b  #NT_MSGPORT,LN_TYPE(a5)
        move.b  #0,LN_PRI(a5)
        lea     portname(pc),a0
        move.l  a0,LN_NAME(a5)
        move.b  #PA_SIGNAL,MP_FLAGS(a5)
        suba.l  a1,a1
        jsr	_LVOFindTask(a6)
	tst.l	d0
	beq	no_task
	move.l  d0,a0
	move.l  a0,MP_SIGTASK(a5)
        moveq.l	#-1,d0
        jsr	_LVOAllocSignal(a6)
        move.b  d0,d5
        cmpi.l  #-1,d0
        bne.s	add_port
        jsr	_LVOPermit(a6)
	bra	free_portmem
add_port
	move.l  a5,a1
        move.b  d5,MP_SIGBIT(a5)
        jsr	_LVOAddPort(a6)
        jsr	_LVOPermit(a6)
        moveq.l	#im_SIZEOF,d0
        move.l  #MEMF_PUBLIC!MEMF_CLEAR,d1
        jsr	_LVOAllocMem(a6)
        move.l  d0,jwmessage
        beq     free_port
        move.l  jwmessage(pc),a4
        move.l  #0,(a4)				; #0,LN_SUCC(a4)
        move.l  #0,LN_PRED(a4)
        move.b  #NT_MESSAGE,LN_TYPE(a4)
        move.b  #0,LN_PRI(a4)
        move.l  #0,LN_NAME(a4)
        move.l  a5,MN_REPLYPORT(a4)
        move.w  #im_SIZEOF,MN_LENGTH(a4)
        move.l  #0,im_Class(a4)
        move.w  #0,im_Code(a4)
        move.w  #0,im_Qualifier(a4)
        move.l  #0,im_IAddress(a4)
        move.w  #0,im_MouseX(a4)
        move.w  #0,im_MouseY(a4)
        move.l  #0,im_Seconds(a4)
        move.l  #0,im_Micros(a4)
        move.l  #0,im_IDCMPWindow(a4)
        move.l  #0,im_SpecialLink(a4)
        bra.s	lock_screen

port_exists
        jsr	_LVOPermit(a6)
        bra     exit_closegadtools

no_portmem
        jsr	_LVOPermit(a6)
        bra     exit_closegadtools

no_task	jsr	_LVOPermit(a6)
        bra     free_portmem

lock_screen
	suba.l  a0,a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOLockPubScreen(a6)
        move.l  d0,wndwscrn
        beq     free_message

        move.l  d0,a1
        suba.l  a0,a0
	jsr	_LVOUnlockPubScreen(a6)

	move.l  wndwscrn(pc),a0
        suba.l  a1,a1
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGetVisualInfoA(a6)
        move.l  d0,visptr
        beq     free_message
        move.l  d0,d5

        lea     gadlistptr(pc),a0
	jsr	_LVOCreateContext(a6)
        tst.l   d0
        beq     free_visual
        move.l  d0,a0

        moveq.l	#CHECKBOX_KIND,d0
        lea     ngdefs0(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags0(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr0
        beq     free_visual

        moveq.l	#CHECKBOX_KIND,d0
        move.l  ngptr0(pc),a0
        lea     ngdefs1(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags1(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr1
        beq     free_gadgets

	moveq.l	#CHECKBOX_KIND,d0
        move.l  ngptr1(pc),a0
        lea     ngdefs2(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags2(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr2
        beq     free_gadgets

        moveq.l	#CHECKBOX_KIND,d0
        move.l  ngptr2(pc),a0
        lea     ngdefs3(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags3(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr3
        beq     free_gadgets

        moveq.l	#CHECKBOX_KIND,d0
        move.l  ngptr3(pc),a0
        lea     ngdefs4(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags4(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr4
        beq     free_gadgets

        moveq.l	#CHECKBOX_KIND,d0
        move.l  ngptr4(pc),a0
        lea     ngdefs5(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags5(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr5
        beq     free_gadgets

        moveq.l	#MX_KIND,d0
        move.l  ngptr5(pc),a0
        lea     ngdefs6(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags6(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr6
        beq     free_gadgets

        moveq.l	#INTEGER_KIND,d0
        move.l  ngptr6(pc),a0
        lea     ngdefs7(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags7(pc),a2
	jsr	_LVOCreateGadgetA(a6) 
        move.l  d0,ngptr7
        beq     free_gadgets

        moveq.l	#CHECKBOX_KIND,d0
        move.l  ngptr7(pc),a0
        lea     ngdefs8(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags8(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr8
        beq     free_gadgets

        moveq.l	#MX_KIND,d0
        move.l  ngptr8(pc),a0
        lea     ngdefs9(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags9(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr9
        beq     free_gadgets

        moveq.l	#MX_KIND,d0
        move.l  ngptr9(pc),a0
        lea     ngdefs10(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags10(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr10
        beq     free_gadgets

        moveq.l	#MX_KIND,d0
        move.l  ngptr10(pc),a0
        lea     ngdefs11(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags11(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr11
        beq     free_gadgets

        moveq.l	#CYCLE_KIND,d0
        move.l  ngptr11(pc),a0
        lea     ngdefs12(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags12(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr12
        beq     free_gadgets

        moveq.l	#INTEGER_KIND,d0
        move.l  ngptr12(pc),a0
        lea     ngdefs13(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags13(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr13
        beq     free_gadgets

        moveq.l	#INTEGER_KIND,d0
        move.l  ngptr13(pc),a0
        lea     ngdefs14(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags14(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr14
        beq     free_gadgets

        moveq.l	#CYCLE_KIND,d0
        move.l  ngptr14(pc),a0
        lea     ngdefs15(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags15(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr15
        beq     free_gadgets

        suba.l  a0,a0
        lea     wndwtags(pc),a1
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOOpenWindowTagList(a6)
        move.l  d0,wndwptr
        beq     free_gadgets

        move.l  d0,a0
        move.l  wd_RPort(a0),wndwrp

        move.l  wndwptr(pc),a0
        lea     menu0(pc),a1
	jsr	_LVOSetMenuStrip(a6)
        tst.l   d0
        beq     exit_closewindow

        move.l  wndwrp,a1
        move.b	#2,d0
	move.l	_GfxBase(pc),a6
	jsr	_LVOSetAPen(a6)
        move.w  #10,d0
        move.w  #26,d1
        move.l  wndwrp,a1
	jsr	_LVOMove(a6)
        move.w  #479,d0
        move.w  #26,d1
        move.l  wndwrp,a1
	jsr	_LVODraw(a6)
        move.w  #10,d0
        move.w  #88,d1
        move.l  wndwrp,a1
	jsr	_LVOMove(a6)
        move.w  #479,d0
        move.w  #88,d1
        move.l  wndwrp,a1
	jsr	_LVODraw(a6)
        move.w	#97,d0
        move.w	#15,d1
        move.w	#98,d2
        move.w	#87,d3
        move.l  wndwrp,a1
	jsr	_LVORectFill(a6)
        move.w	#308,d0
        move.w	#15,d1
        move.w  #309,d2
        move.w	#87,d3
        move.l  wndwrp,a1
	jsr	_LVORectFill(a6)
        move.w	#17,d0
        move.w	#21,d1
        move.l  wndwrp,a1
	jsr	_LVOMove(a6)
        lea     title0(pc),a0
        moveq.l	#9,d0
        move.l  wndwrp,a1
	jsr	_LVOText(a6)
        move.w	#116,d0
        move.w	#21,d1
        move.l  wndwrp,a1
	jsr	_LVOMove(a6)
        lea     title1(pc),a0
        moveq.l	#22,d0
        move.l  wndwrp,a1
	jsr	_LVOText(a6)
        move.w	#330,d0
        move.w	#21,d1
        move.l  wndwrp,a1
	jsr	_LVOMove(a6)
        lea     title2(pc),a0
        moveq.l	#16,d0
        move.l  wndwrp,a1
	jsr	_LVOText(a6)
	jsr	_LVOWaitTOF(a6)

	move.l	_GadtoolsBase(pc),a6
	tst.b	actmx
	beq.s	chkqcyc
	moveq	#0,d0
	move.b	actmx,d0
        move.l  ngptr6(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTMX_Active,(a3)
        move.l  d0,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
chkqcyc	cmp.b	#1,qcyc
	beq.s	chkmcyc
	moveq	#0,d0
	move.b	qcyc,d0
        move.l  ngptr12(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCY_Active,(a3)
        move.l  d0,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
chkmcyc	tst.b	mcyc
	beq.s	chklam
	moveq	#0,d0
	move.b	mcyc,d0
        move.l  ngptr15(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCY_Active,(a3)
        move.l  d0,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
chklam	tst.b	amgal
	beq.s	chklsh
        move.l  ngptr0(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCB_Checked,(a3)
        move.l  #TRUE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
chklsh	tst.b	shftl
	beq.s	chklal
        move.l  ngptr1(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCB_Checked,(a3)
        move.l  #TRUE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
chklal	tst.b	altl
	beq.s	chkram
        move.l  ngptr2(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCB_Checked,(a3)
        move.l  #TRUE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
chkram	tst.b	amgar
	beq.s	chkrsh
        move.l  ngptr3(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCB_Checked,(a3)
        move.l  #TRUE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
chkrsh	tst.b	shftr
	beq.s	chkral
        move.l  ngptr4(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCB_Checked,(a3)
        move.l  #TRUE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
chkral	tst.b	altr
	beq.s	chkctrl
        move.l  ngptr5(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCB_Checked,(a3)
        move.l  #TRUE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
chkctrl	tst.b	ctrl
	beq.s	ulmse
        move.l  ngptr8(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCB_Checked,(a3)
        move.l  #TRUE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
ulmse	tst.b	msel
	beq.s	ummse
        move.l  ngptr9(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTMX_Active,(a3)
        move.l  #$00000001,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
ummse	tst.b	msem
	beq.s	urmse
        move.l  ngptr10(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTMX_Active,(a3)
        move.l  #$00000001,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
urmse	tst.b	mser
	beq.s	cvstg
        move.l  ngptr11(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTMX_Active,(a3)
        move.l  #$00000001,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
cvstg

	move.l  wndwptr(pc),a0
        suba.l  a1,a1
	jsr	_LVOGT_RefreshWindow(a6)

mainloop
        move.l  wndwptr(pc),a0
        move.l  wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
        move.l  wndwptr(pc),a0
        move.l  wd_UserPort(a0),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_GetIMsg(a6)
        move.l  d0,a1
        move.l  im_Class(a1),iclass
        move.w  im_Code(a1),icode
        move.w  im_Qualifier(a1),iqual
        move.l  im_IAddress(a1),iadr
        move.w  im_MouseX(a1),msex
        move.w  im_MouseY(a1),msey
	jsr	_LVOGT_ReplyIMsg(a6)
	move.l	iclass,d0
        cmp.l   #IDCMP_GADGETUP,d0
        beq     which_gadgetup

        cmp.l   #IDCMP_GADGETDOWN,d0
        beq     which_gadgetdown

        cmp.l   #IDCMP_VANILLAKEY,d0
        beq     which_vanillakey

        cmp.l   #IDCMP_RAWKEY,d0
        beq     which_rawkey

        cmp.l   #IDCMP_MOUSEBUTTONS,d0
        beq     which_mousebutton

        cmp.l   #IDCMP_MENUPICK,d0
        beq     which_menu

        cmp.l   #IDCMP_MENUHELP,d0
        beq     which_menu

        cmp.l   #IDCMP_REFRESHWINDOW,d0
        beq     refresh_window

        cmp.l   #IDCMP_INACTIVEWINDOW,d0
        beq     window_inactive

        cmp.l   #IDCMP_ACTIVEWINDOW,d0
        beq     window_active

        cmpi.l  #IDCMP_CLOSEWINDOW,d0
        beq.s   clear_menustrip

        bra	mainloop

clear_menustrip
        move.l  wndwptr(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOClearMenuStrip(a6)

exit_closewindow
        move.l  wndwptr(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOCloseWindow(a6)

free_gadgets
        move.l  gadlistptr(pc),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOFreeGadgets(a6)

free_visual
        move.l  visptr(pc),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOFreeVisualInfo(a6)

free_message
        move.l  jwmessage(pc),a1
        moveq.l	#im_SIZEOF,d0
	move.l	4.w,a6
        jsr	_LVOFreeMem(a6)

free_port
        move.l  jwport(pc),a5
        tst.l	a5
        beq.s	exit_closegadtools
        move.b  MP_SIGBIT(a5),d0
        tst.b	d0
        beq.s	no_signal
	move.l	4.w,a6
        jsr	_LVOFreeSignal(a6)
no_signal
        move.l  a5,a1
        jsr	_LVORemPort(a6)
free_portmem
        move.l  a5,a1
        moveq.l	#MP_SIZE,d0
	move.l	4.w,a6
        jsr	_LVOFreeMem(a6)

exit_closegadtools
        move.l  _GadtoolsBase(pc),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

exit_closeicon
        move.l  _IconBase(pc),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

exit_closedos
        move.l  _DOSBase(pc),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

exit_closegfx
        move.l  _GfxBase(pc),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

exit_closeint
        move.l  _IntuitionBase(pc),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

exit_quit
        move.l  #8000000,d0
        move.l  #MEM_TYPE,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.s	bye
	move.l	d0,a1
	move.l	#8000000,d0
	jsr	_LVOFreeMem(a6)
bye	moveq	#0,d0
	rts


 * Branch-To Routines.

which_gadgetup
        move.l  iadr(pc),a0
        move.w  gg_GadgetID(a0),d0
        tst.b	d0
        beq     amga_l
        cmpi.b	#1,d0
        beq     shft_l
        cmpi.b	#2,d0
        beq.s   alt_l
        cmpi.b	#3,d0
        beq	amga_r
        cmpi.b	#4,d0
        beq	shft_r
        cmpi.b	#5,d0
        beq.s   alt_r
        cmpi.b	#7,d0
        beq     stgcode
        cmpi.b	#8,d0
        beq     control
        cmpi.b	#12,d0
        beq     qcycle
        cmpi.b	#13,d0
        beq     stgqual
        cmpi.b	#14,d0
        beq     stgclas
        cmpi.b	#15,d0
        beq     mcycle
        bra     mainloop

alt_l   addq.b	#1,altl
        move.b  altl,d0
        tst.b	d0
        beq.s   altl_e
        cmpi.b	#1,d0
        beq.s   altl_e
        move.b  #0,altl
altl_e  bra	mainloop

alt_r   addq.b	#1,altr
        move.b  altr,d0
        tst.b	d0
        beq.s   altr_e
        cmpi.b	#1,d0
        beq.s   altr_e
        move.b  #0,altr
altr_e  bra     mainloop

shft_l  addq.b	#1,shftl
        move.b  shftl,d0
        tst.b	d0
        beq.s   shftl_e
        cmpi.b	#1,d0
        beq.s   shftl_e
        move.b  #0,shftl
shftl_e bra     mainloop

shft_r  addq.b	#1,shftr
        move.b  shftr,d0
        tst.b	d0
        beq.s   shftr_e
        cmpi.b	#1,d0
        beq.s   shftr_e
        move.b  #0,shftr
shftr_e bra     mainloop

amga_l  addq.b	#1,amgal
        move.b  amgal,d0
        tst.b	d0
        beq.s   amgal_e
        cmpi.b	#1,d0
        beq.s   amgal_e
        move.b  #0,amgal
amgal_e bra     mainloop

amga_r  addq.b	#1,amgar
        move.b  amgar,d0
        tst.b	d0
        beq.s   amgar_e
        cmpi.b	#1,d0
        beq.s   amgar_e
        move.b  #0,amgar
amgar_e bra     mainloop

control addq.b	#1,ctrl
        move.b  ctrl,d0
        tst.b	d0
        beq.s   ctrl_e
        cmpi.b	#1,d0
        beq.s   ctrl_e
        move.b  #0,ctrl
ctrl_e  bra     mainloop

qcycle	move.w  iqual,d0
        and.w   #$8001,d0
        cmpi.w  #$8001,d0
        beq.s   qc_dec
        addq.b	#1,qcyc
        bra.s   qc_chk
qc_dec  subq.b	#1,qcyc
qc_chk  moveq	#0,d0
        move.b  qcyc,d0
        tst.b	d0
        blt.s   qc_nil
        cmpi.b	#5,d0
        bgt.s   qc_nil
        bra     mainloop
qc_nil  move.b  #0,qcyc
        bra     mainloop

stgclas move.l  iadr,a0
        move.l  gg_SpecialInfo(a0),a0
        move.l  (a0),a0				; si_Buffer(a0),a0
        move.l  a0,a3
        bsr     findlen
        tst.l   d0
        ble.s   sk_nil
        move.l  a3,d1
        move.l  #longval,d2
	move.l	_DOSBase(pc),a6
        jsr	_LVOStrToLong(a6)
	cmpi.l  #-1,d0
        beq.s   sk_nil
        cmpi.l  #-2147483647,longval
        blt.s   sk_nil
        cmpi.l  #2147483647,longval
        bgt.s   sk_nil
        move.l  longval,classval
        bra     mainloop
sk_nil  move.l  #0,classval
        move.l  ngptr14(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTIN_Number,(a3)
        move.l  #0,4(a3)
        move.l  #GTIN_MaxChars,8(a3)
        move.l  #11,12(a3)
        move.l  #TAG_DONE,16(a3)
	move.l	_GadtoolsBase(pc),a6
        jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     mainloop

stgqual move.l  iadr,a0
        move.l  gg_SpecialInfo(a0),a0
        move.l  (a0),a0				; si_Buffer(a0),a0
        move.l  a0,a3
        bsr     findlen
        tst.l   d0
        ble.s   sq_nil
        move.l  a3,d1
        move.l  #longval,d2
	move.l	_DOSBase(pc),a6
        jsr	_LVOStrToLong(a6)
        cmpi.l  #-1,d0
        beq.s   sq_nil
        move.l  #longval,a0
        move.l  #qualval,a1
        and.l   #$0000FFFF,(a0)
        move.w  2(a0),(a1)
        cmpi.l  #-32767,longval
        blt.s   sq_nil
        cmpi.l  #65535,longval
        bgt.s   sq_nil
        bra     mainloop
sq_nil  move.w  #0,qualval
        move.l  ngptr13(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTIN_Number,(a3)
        move.l  #0,4(a3)
        move.l  #GTIN_MaxChars,8(a3)
        move.l  #6,12(a3)
        move.l  #TAG_DONE,16(a3)
	move.l	_GadtoolsBase(pc),a6
        jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     mainloop

stgcode move.l  iadr,a0
        move.l  gg_SpecialInfo(a0),a0
        move.l  (a0),a0				; si_Buffer(a0),a0
        move.l  a0,a3
        bsr     findlen
        tst.l   d0
        ble.s   sc_nil
        move.l  a3,d1
        move.l  #longval,d2
	move.l	_DOSBase(pc),a6
        jsr	_LVOStrToLong(a6)
        cmpi.l  #-1,d0
        beq.s   sc_nil
        move.l  #longval,a0
        move.l  #codeval,a1
        and.l   #$0000FFFF,(a0)
        move.w  2(a0),(a1)
        cmpi.l  #-32767,longval
        blt.s   sc_nil
        cmpi.l  #65535,longval
        bgt.s   sc_nil
        bra     mainloop
sc_nil  move.w  #0,codeval
        move.l  ngptr7(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTIN_Number,(a3)
        move.l  #0,4(a3)
        move.l  #GTIN_MaxChars,8(a3)
        move.l  #6,12(a3)
        move.l  #TAG_DONE,16(a3)
	move.l	_GadtoolsBase(pc),a6
        jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     mainloop

which_gadgetdown
        move.l  iadr(pc),a0
        move.w  gg_GadgetID(a0),d0
        cmpi.b	#6,d0
        beq.s   class
        cmpi.b	#9,d0
        beq.s   mse_mxl
        cmpi.b	#10,d0
        beq.s   mse_mxm
        cmpi.b	#11,d0
        beq     mse_mxr
        bra     mainloop

class	move.w  icode,d0
        cmpi.w	#1,d0
        beq.s   class1
        cmpi.w	#2,d0
        beq.s   class2
        cmpi.w	#3,d0
        beq.s   class3
        move.b  #0,actmx
        bra     mainloop

class1  move.b  #1,actmx
        bra     mainloop

class2  move.b  #2,actmx
        bra     mainloop

class3  move.b  #3,actmx
        bra     mainloop

mse_mxl	move.w  icode,d0
        cmpi.w	#1,d0
        beq.s   ml1
        move.b  #0,msel
        bra     mainloop
ml1     move.b  #1,msel
        bra     mainloop

mse_mxm	move.w  icode,d0
        cmpi.w	#1,d0
        beq.s   mm1
        move.b  #0,msem
        bra     mainloop
mm1     move.b  #1,msem
        bra     mainloop

mse_mxr	move.w  icode,d0
        cmpi.w	#1,d0
        beq.s   mr1
        move.b  #0,mser
        bra     mainloop
mr1     move.b  #1,mser
        bra     mainloop

mcycle	move.w  iqual,d0
        and.w   #$8001,d0
        cmpi.w  #$8001,d0
        beq.s   mc_dec
        addq.b	#1,mcyc
        bra.s   mc_chk
mc_dec  subq.b	#1,mcyc
mc_chk  moveq	#0,d0
        move.b  mcyc,d0
        tst.b	d0
        blt.s   mc_nil
        cmpi.b	#7,d0
        bgt.s   mc_nil
        bra     mainloop
mc_nil  move.b  #0,mcyc
        bra     mainloop

which_menu
        move.w  icode,d0
        cmpi.w	#$F800,d0
        beq     escape
        cmpi.w	#$0020,d0
        beq     fone
        cmpi.w	#$0820,d0
        beq     ftwo
        cmpi.w	#$1020,d0
        beq     fthree
        cmpi.w	#$1820,d0
        beq     ffour
        cmpi.w	#$2020,d0
        beq     ffive
        cmpi.w	#$2820,d0
        beq     fsix
        cmpi.w	#$3020,d0
        beq     fseven
        cmpi.w	#$3820,d0
        beq     feight
        cmpi.w	#$4020,d0
        beq     fnine
        cmpi.w	#$4820,d0
        beq     ften
        cmpi.w	#$F840,d0
        beq     delete
        cmpi.w	#$F860,d0
        beq     help
        cmpi.w	#$F801,d0
        beq     curs_up
        cmpi.w	#$F821,d0
        beq     curs_down
        cmpi.w	#$F841,d0
        beq     curs_left
        cmpi.w	#$F861,d0
        beq     curs_right
        cmpi.w	#$F881,d0
        beq     shift_up
        cmpi.w	#$F8A1,d0
        beq     shift_down
        cmpi.w	#$F8C1,d0
        beq     shift_left
        cmpi.w	#$F8E1,d0
        beq     shift_right
        cmpi.w	#$F802,d0
        beq     do_msg
        cmpi.w	#$F822,d0
        beq     get_window
        cmpi.w	#$F842,d0
        beq     setdly
        cmpi.w	#$F862,d0
        beq     setssn
        cmpi.w	#$F882,d0
        beq     edit_window
	cmpi.w	#$F803,d0
        beq     setkpt
        cmpi.w	#$F823,d0
        beq     setkrt
        cmpi.w	#$F843,d0
        beq     mpc
        bra     mainloop

escape  tst.b	actwp
        beq.s   end_esc
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   end_esc
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #69,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
end_esc bra     mainloop

fone    tst.b	actwp
        beq.s   end_f1
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   end_f1
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #89,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
end_f1  bra     mainloop

ftwo    tst.b	actwp
        beq.s   end_f2
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   end_f2
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #89,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
end_f2  bra     mainloop

fthree  tst.b	actwp
        beq.s   end_f3
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   end_f3
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #89,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
end_f3  bra     mainloop

ffour   tst.b	actwp
        beq.s   end_f4
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   end_f4
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #89,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
end_f4  bra     mainloop

ffive   tst.b	actwp
        beq.s   end_f5
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   end_f5
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #89,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
end_f5  bra     mainloop

fsix    tst.b	actwp
        beq.s   end_f6
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   end_f6
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #89,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
end_f6  bra     mainloop

fseven  tst.b	actwp
        beq.s   end_f7
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   end_f7
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #89,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
end_f7  bra     mainloop

feight  tst.b	actwp
        beq.s   end_f8
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   end_f8
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #89,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
end_f8  bra     mainloop

fnine   tst.b	actwp
        beq.s   end_f9
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   end_f9
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #89,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
end_f9  bra     mainloop

ften    tst.b	actwp
        beq.s   end_f10
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s	end_f10
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #89,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
end_f10 bra     mainloop

delete  tst.b	actwp
        beq.s   end_del
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   end_del
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_VANILLAKEY,im_Class(a0)
        move.w  #127,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
end_del bra     mainloop

help    tst.b	actwp
        beq.s   end_hlp
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   end_hlp
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #95,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
end_hlp bra     mainloop

curs_up	tst.b	actwp
        beq.s   cu_end
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   cu_end
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #76,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
cu_end  bra     mainloop

curs_down
        tst.b	actwp
        beq.s   cd_end
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   cd_end
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #77,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
cd_end  bra     mainloop

curs_left
        tst.b	actwp
        beq.s   cl_end
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   cl_end
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #79,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
cl_end  bra     mainloop

curs_right
        tst.b	actwp
        beq.s   cr_end
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   cr_end
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #78,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
cr_end  bra     mainloop

shift_up
        tst.b	actwp
        beq.s   pu_end
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   pu_end
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #76,im_Code(a0)
        move.w  #$8201,im_Qualifier(a0)
        bsr     poke_message
pu_end  bra     mainloop

shift_down
        tst.b	actwp
        beq.s   pd_end
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   pd_end
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #77,im_Code(a0)
        move.w  #$8201,im_Qualifier(a0)
        bsr     poke_message
pd_end  bra     mainloop

shift_left
        tst.b	actwp
        beq.s   pl_end
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s	pl_end
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #79,im_Code(a0)
        move.w  #$8201,im_Qualifier(a0)
        bsr     poke_message
pl_end  bra     mainloop

shift_right
        tst.b	actwp
        beq.s   pr_end
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   pr_end
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_RAWKEY,im_Class(a0)
        move.w  #78,im_Code(a0)
        move.w  #$8201,im_Qualifier(a0)
        bsr     poke_message
pr_end  bra     mainloop

get_window
        move.l  dlylong,d1
	move.l	_DOSBase(pc),a6
        jsr	_LVODelay(a6)

*	moveq	#0,d0
	move.l	_IntuitionBase(pc),a6
*	jsr	_LVOLockIBase(a6)
*       move.l  d0,iblock
*       beq     gw_end

        move.l  ib_ActiveWindow(a6),a3
        move.l  wd_UserPort(a3),a4
        move.b  #0,actwp
        move.l  wndwptr(pc),a1
        cmp.l   a3,a1
        beq.s   gw_end
        move.l  jwmessage(pc),a0
        move.l  a3,im_IDCMPWindow(a0)
        move.l  a3,act_wndw
        move.l  a4,act_port
        move.b  #1,actwp

        move.l  wndwptr(pc),a0
        move.l  wd_Title(a3),a1
        move.l  wd_ScreenTitle(a3),a2
        jsr	_LVOSetWindowTitles(a6)

*       move.l  iblock,a0
*	jsr	_LVOUnlockIBase(a6)

gw_end  bra     mainloop

do_msg  tst.b	actwp
        beq     sm_end
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq     sm_end
        move.l  jwmessage(pc),a0
        move.l  #0,im_Class(a0)
        move.l  #actmx,a1
        move.b  (a1),d0
        tst.b	d0
        beq.s   rkmsg
        cmpi.b	#1,d0
        beq.s   vkmsg
        cmpi.b	#2,d0
        beq.s   mbmsg
        cmpi.b	#3,d0
        beq.s   mkmsg
        bra.s   sm_clas
rkmsg   move.l  #$00000400,im_Class(a0)
        bra.s   sm_clas
vkmsg   move.l  #$00200000,im_Class(a0)
        bra.s   sm_clas
mbmsg   move.l  #$00000008,im_Class(a0)
        bra.s   sm_clas
mkmsg   move.l  #$00000100,im_Class(a0)
sm_clas move.l  #classval,a1
        move.l  (a1),d0
        tst.l   d0
        beq.s   sm_qual
        move.l  d0,im_Class(a0)
sm_qual move.w  #0,im_Qualifier(a0)
        move.l  #qcyc,a1
        move.b  (a1),d0
        tst.b	d0
        beq.s   prefix
        cmpi.b	#1,d0
        beq.s   pfrpt
        cmpi.b	#2,d0
        beq.s   pfnp
        cmpi.b	#3,d0
        beq.s   pfrptnp
        cmpi.b	#4,d0
        beq.s   sm_altl
        bra     sm_plus
prefix  move.w  #$8000,im_Qualifier(a0)
        bra.s   sm_altl
pfrpt   move.w  #$8200,im_Qualifier(a0)
        bra.s   sm_altl
pfnp    move.w  #$8100,im_Qualifier(a0)
        bra.s   sm_altl
pfrptnp move.w  #$8300,im_Qualifier(a0)
sm_altl cmp.b   #1,altl
        bne.s   sm_altr
        or.w    #$0010,im_Qualifier(a0)
sm_altr cmp.b   #1,altr
        bne.s   sm_sftl
        or.w    #$0020,im_Qualifier(a0)
sm_sftl cmp.b   #1,shftl
        bne.s   sm_sftr
        or.w    #$0001,im_Qualifier(a0)
sm_sftr cmp.b   #1,shftr
        bne.s   sm_amgl
        or.w    #$0002,im_Qualifier(a0)
sm_amgl cmp.b   #1,amgal
        bne.s   sm_amgr
        or.w    #$0040,im_Qualifier(a0)
sm_amgr cmp.b   #1,amgar
        bne.s   sm_ctrl
        or.w    #$0080,im_Qualifier(a0)
sm_ctrl cmp.b   #1,ctrl
        bne.s   sm_plus
        or.w    #$0008,im_Qualifier(a0)
sm_plus move.l  #qualval,a1
        move.w  (a1),d0
        or.w    d0,im_Qualifier(a0)
sm_code move.w  #0,im_Code(a0)
        move.l  #mcyc,a1
        move.b  (a1),d0
        tst.b	d0
        beq.s   mse_l
        cmpi.b	#1,d0
        beq.s   mse_m
        cmpi.b	#2,d0
        beq.s   mse_r
        cmpi.b	#3,d0
        beq.s   mse_lr
        cmpi.b	#4,d0
        beq.s   mse_lm
        cmpi.b	#5,d0
        beq.s   mse_mr
        cmpi.b	#6,d0
        beq.s   mse_lmr
        move.l  #codeval,a1
        move.w  (a1),d0
        tst.w   d0
        beq.s   sendmsg
        move.w  d0,im_Code(a0)
        bra.s   sendmsg
mse_l   bsr.s   m_left
        bra.s   sendmsg
mse_m   bsr.s   m_mid
        bra.s   sendmsg
mse_r   bsr.s   m_right
        bra.s   sendmsg
mse_lr  bsr.s   m_left
        bsr.s   m_right
        bra.s   sendmsg
mse_lm  bsr.s   m_left
        bsr.s   m_mid
        bra.s   sendmsg
mse_mr  bsr.s   m_mid
        bsr.s   m_right
        bra.s   sendmsg
mse_lmr bsr.s   m_left
        bsr.s   m_mid
        bsr.s   m_right
sendmsg bsr     poke_message
sm_end  bra     mainloop

m_left  cmp.b   #1,msel
        beq.s   ml_one
        or.w    #SELECTDOWN,im_Code(a0)
        bra.s   ml_end
ml_one  or.w    #SELECTUP,im_Code(a0)
ml_end  rts

m_mid   cmp.b   #1,msem
        beq.s   mm_one
        or.w    #MIDDLEDOWN,im_Code(a0)
        bra.s   mm_end
mm_one  or.w    #MIDDLEUP,im_Code(a0)
mm_end  rts

m_right cmp.b   #1,mser
        beq.s   mr_one
        or.w    #MENUDOWN,im_Code(a0)
        bra.s   mr_end
mr_one  or.w    #MENUUP,im_Code(a0)
mr_end  rts

setssn  suba.l  a0,a0
	move.l	_IntuitionBase(pc),a6
        jsr	_LVOLockPubScreen(a6)
        move.l  d0,ssnscrn
        beq     ssn_end

	move.l	d0,a1
        suba.l  a0,a0
	jsr	_LVOUnlockPubScreen(a6)

	move.l  ssnscrn(pc),a0
        suba.l  a1,a1
	move.l	_GadtoolsBase(pc),a6
        jsr	_LVOGetVisualInfoA(a6)
        move.l  d0,ssnvis
        beq     ssn_end
        move.l  d0,d5

        lea     glssnptr(pc),a0
	jsr	_LVOCreateContext(a6)
        tst.l   d0
        beq     fssnvis
        move.l  d0,a0

        moveq.l	#STRING_KIND,d0
        lea     ngdefs33(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags33(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr33
        beq     fssnvis

	moveq.l	#BUTTON_KIND,d0
	move.l	ngptr33(pc),a0
	lea	ngdefs34(pc),a1
	move.l	d5,gng_VisualInfo(a1)
	lea	ngtags34(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr34
	beq	fssnwg

	moveq.l	#STRING_KIND,d0
	move.l	ngptr34(pc),a0
	lea	ngdefs35(pc),a1
	move.l	d5,gng_VisualInfo(a1)
	lea	ngtags35(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr35
	beq	fssnwg

	suba.l  a0,a0
        lea     ssntags(pc),a1
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOOpenWindowTagList(a6)
	move.l  d0,ssnwptr
        beq     fssnwg

        move.l  d0,a0
        move.l  wd_RPort(a0),ssnwrp

	move.l	_GfxBase(pc),a6
	jsr	_LVOWaitTOF(a6)

	move.l  ssnwptr(pc),a0
        suba.l  a1,a1
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_RefreshWindow(a6)

ssnloop move.l  ssnwptr(pc),a0
        move.l  wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
        move.l  ssnwptr(pc),a0
        move.l  wd_UserPort(a0),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_GetIMsg(a6)
        move.l  d0,a1
        move.l  im_Class(a1),iclass
        move.w  im_Code(a1),icode
        move.w  im_Qualifier(a1),iqual
        move.l  im_IAddress(a1),iadr
        move.w  im_MouseX(a1),msex
        move.w  im_MouseY(a1),msey
	jsr	_LVOGT_ReplyIMsg(a6)
	move.l	iclass,d0
	cmp.l   #IDCMP_GADGETUP,d0
        beq.s	which_ssngadup

        cmp.l   #IDCMP_GADGETDOWN,d0
        beq.s	which_ssngaddown

        cmp.l   #IDCMP_VANILLAKEY,d0
        beq.s	which_ssnvankey

        cmp.l   #IDCMP_INACTIVEWINDOW,d0
        beq.s   ssnia

        cmpi.l  #IDCMP_CLOSEWINDOW,d0
        beq.s   cssnw
        bra     ssnloop

ssnia	move.l	wndwptr(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOActivateWindow(a6)

cssnw	move.l  ssnwptr(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOCloseWindow(a6)

fssnwg	move.l	glssnptr(pc),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOFreeGadgets(a6)

fssnvis move.l  ssnvis(pc),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOFreeVisualInfo(a6)

ssn_end	bra     mainloop

which_ssngadup
        move.l  iadr(pc),a0
        move.w  gg_GadgetID(a0),d0
        cmpi.b	#33,d0
        beq.s	do_ssn
        cmpi.b	#34,d0
        beq.s	ssn_sig
	bra	ssnloop

which_ssngaddown
        bra     ssnloop

which_ssnvankey
	move.w	icode,d0
        cmp.w   #$42,d0
        beq.s   actssn
        cmp.w   #$62,d0
        beq.s   actssn
        cmp.w   #$54,d0
        beq.s   actsss
        cmp.w   #$74,d0
        beq.s   actsss
        cmp.w   #$53,d0
        beq.s	ssn_sig
        cmp.w   #$73,d0
        beq.s	ssn_sig
        bra     ssnloop

actssn  move.l  ngptr33(pc),a0
        move.l  ssnwptr(pc),a1
        suba.l  a2,a2
        move.l  _IntuitionBase(pc),a6
        jsr	_LVOActivateGadget(a6)
        bra     ssnloop

actsss	move.l  ngptr35(pc),a0
        move.l  ssnwptr(pc),a1
        suba.l  a2,a2
        move.l  _IntuitionBase(pc),a6
        jsr	_LVOActivateGadget(a6)
        bra     ssnloop

do_ssn	bsr	hextobin
	bra     ssnloop

ssn_sig	move.l  ngptr35(pc),a0
        move.l  gg_SpecialInfo(a0),a0
        move.l  (a0),a0				; si_Buffer(a0),a0
        move.l  a0,a3
        bsr     findlen
        tst.l   d0
        ble.s	ss_end
	move.l	ssnlong,d4
	move.l	a3,a1
	move.l	4.w,a6
        jsr	_LVOFindTask(a6)
	tst.l	d0
	beq.s	flash
	move.l	d0,a1
	move.l	d4,d0
        jsr	_LVOSignal(a6)
	bra.s	ss_end
flash	suba.l	a0,a0
	move.l	_IntuitionBase(pc),a6
        jsr	_LVODisplayBeep(a6)
ss_end	bra     ssnloop

edit_window
        suba.l  a0,a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOLockPubScreen(a6)
        move.l  d0,ewscrn
        beq     ew_end

        move.l  d0,a1
        suba.l  a0,a0
	jsr	_LVOUnlockPubScreen(a6)

        move.l  ewscrn(pc),a0
        suba.l  a1,a1
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGetVisualInfoA(a6)
        move.l  d0,ewvis
        beq     ew_end
        move.l  d0,d5

        lea     glewptr(pc),a0
	jsr	_LVOCreateContext(a6)
        tst.l   d0
        beq     fewvis
        move.l  d0,a0

        moveq.l	#INTEGER_KIND,d0
        lea     ngdefs23(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags23(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr23
        beq     fewvis

        moveq.l	#INTEGER_KIND,d0
        move.l  ngptr23(pc),a0
        lea     ngdefs24(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags24(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr24
        beq     fewwg

        moveq.l	#INTEGER_KIND,d0
        move.l  ngptr24(pc),a0
        lea     ngdefs25(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags25(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr25
        beq     fewwg

        moveq.l	#INTEGER_KIND,d0
        move.l  ngptr25(pc),a0
        lea     ngdefs26(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags26(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr26
        beq     fewwg

        moveq.l	#INTEGER_KIND,d0
        move.l  ngptr26(pc),a0
        lea     ngdefs27(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags27(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr27
        beq     fewwg

        moveq.l	#BUTTON_KIND,d0
        move.l  ngptr27(pc),a0
        lea     ngdefs28(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags28(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr28
        beq     fewwg

        moveq.l	#BUTTON_KIND,d0
        move.l  ngptr28(pc),a0
        lea     ngdefs29(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags29(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr29
        beq     fewwg

        moveq.l	#BUTTON_KIND,d0
        move.l  ngptr29(pc),a0
        lea     ngdefs30(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags30(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr30
        beq     fewwg

        moveq.l	#BUTTON_KIND,d0
        move.l  ngptr30(pc),a0
        lea     ngdefs31(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags31(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr31
        beq     fewwg

        moveq.l	#BUTTON_KIND,d0
        move.l  ngptr31(pc),a0
        lea     ngdefs32(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags32(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr32
        beq     fewwg

        suba.l  a0,a0
        lea     ewtags(pc),a1
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOOpenWindowTagList(a6)
        move.l  d0,ewwptr
        beq     fewwg

        move.l  d0,a0
        move.l  wd_RPort(a0),ewwrp

	move.l	_GfxBase(pc),a6
	jsr	_LVOWaitTOF(a6)

        move.l  ewwptr(pc),a0
        suba.l  a1,a1
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_RefreshWindow(a6)

ewloop  move.l  ewwptr(pc),a0
        move.l  wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
        move.l  ewwptr(pc),a0
        move.l  wd_UserPort(a0),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_GetIMsg(a6)
        move.l  d0,a1
        move.l  im_Class(a1),iclass
        move.w  im_Code(a1),icode
        move.w  im_Qualifier(a1),iqual
        move.l  im_IAddress(a1),iadr
        move.w  im_MouseX(a1),msex
        move.w  im_MouseY(a1),msey
	jsr	_LVOGT_ReplyIMsg(a6)

	move.l	iclass,d0
	cmp.l   #IDCMP_GADGETUP,d0
        beq     which_ewgadup

        cmp.l   #IDCMP_GADGETDOWN,d0
        beq     which_ewgaddown

        cmp.l   #IDCMP_MOUSEBUTTONS,d0
        beq.s	which_ewmenuup

        cmp.l   #IDCMP_VANILLAKEY,d0
        beq     which_ewvankey

        cmp.l   #IDCMP_INACTIVEWINDOW,d0
        beq.s   ewwia

        cmpi.l  #IDCMP_CLOSEWINDOW,d0
        beq.s   ceww
        bra     ewloop

ewwia   move.l  wndwptr(pc),a0
	move.l	_IntuitionBase(pc),a6
        jsr	_LVOActivateWindow(a6)

ceww    move.l  ewwptr(pc),a0
	move.l	_IntuitionBase(pc),a6
        jsr	_LVOCloseWindow(a6)

fewwg   move.l  glewptr(pc),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOFreeGadgets(a6)

fewvis  move.l  ewvis(pc),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOFreeVisualInfo(a6)

ew_end  bra     mainloop

which_ewmenuup
        cmp.w   #MENUUP,icode
        bne.s   ewmu_e
        cmp.w   #137,msex
        blt.s   ewmu_e
        cmp.w   #191,msex
        bgt.s   ewmu_e
        cmp.w   #33,msey
        blt.s   ewmu_e
        cmp.w   #46,msey
        bgt.s   ewmu_e
        bra     do_cloz
ewmu_e  bra     ewloop

which_ewgadup
        move.l  iadr(pc),a0
        move.w  gg_GadgetID(a0),d0
        cmpi.b	#23,d0
        beq     do_ewx
        cmpi.b	#24,d0
        beq     do_ewy
        cmpi.b	#25,d0
        beq     do_eww
        cmpi.b	#26,d0
        beq     do_ewh
        cmpi.b	#27,d0
        beq     do_ewi
        cmpi.b	#28,d0
        beq     do_size
        cmpi.b	#29,d0
        beq     do_move
        cmpi.b	#30,d0
        beq     do_mod
        cmpi.b	#31,d0
        beq     do_clos
        cmpi.b	#32,d0
        beq     do_lims
        bra     ewloop

which_ewgaddown
        bra     ewloop

which_ewvankey
	move.w	icode,d0
        cmp.w   #$58,d0
        beq     actewx
        cmp.w   #$78,d0
        beq     actewx
        cmp.w   #$59,d0
        beq     actewy
        cmp.w   #$79,d0
        beq     actewy
        cmp.w   #$57,d0
        beq     acteww
        cmp.w   #$77,d0
        beq     acteww
        cmp.w   #$48,d0
        beq     actewh
        cmp.w   #$68,d0
        beq     actewh
        cmp.w   #$49,d0
        beq     actewi
        cmp.w   #$69,d0
        beq     actewi
        cmp.w   #$53,d0
        beq     do_size
        cmp.w   #$73,d0
        beq     do_size
        cmp.w   #$4D,d0
        beq     do_move
        cmp.w   #$6D,d0
        beq     do_move
        cmp.w   #$43,d0
        beq     do_clos
        cmp.w   #$63,d0
        beq     do_clos
        cmp.w   #$4C,d0
        beq     do_lims
        cmp.w   #$6C,d0
        beq     do_lims
        cmp.w   #$45,d0
        beq     do_mod
        cmp.w   #$65,d0
        beq     do_mod
        bra     ewloop

actewx  move.l  ngptr23(pc),a0
        move.l  ewwptr(pc),a1
        suba.l  a2,a2
	move.l	_IntuitionBase(pc),a6
        jsr	_LVOActivateGadget(a6)
        bra     ewloop

actewy  move.l  ngptr24(pc),a0
        move.l  ewwptr(pc),a1
        suba.l  a2,a2
	move.l	_IntuitionBase(pc),a6
        jsr	_LVOActivateGadget(a6)
        bra     ewloop

acteww  move.l  ngptr25(pc),a0
        move.l  ewwptr(pc),a1
        suba.l  a2,a2
	move.l	_IntuitionBase(pc),a6
        jsr	_LVOActivateGadget(a6)
        bra     ewloop

actewh  move.l  ngptr26(pc),a0
        move.l  ewwptr(pc),a1
        suba.l  a2,a2
	move.l	_IntuitionBase(pc),a6
        jsr	_LVOActivateGadget(a6)
        bra     ewloop

actewi  move.l  ngptr27(pc),a0
        move.l  ewwptr(pc),a1
        suba.l  a2,a2
	move.l	_IntuitionBase(pc),a6
        jsr	_LVOActivateGadget(a6)
        bra     ewloop

do_ewx  move.l  iadr,a0
        move.l  gg_SpecialInfo(a0),a0
        move.l  (a0),a0				; si_Buffer(a0),a0
        move.l  a0,a3
        bsr     findlen
        tst.l   d0
        ble.s   ewx_nil
        move.l  a3,d1
        move.l  #ewxlong,d2
	move.l	_DOSBase(pc),a6
        jsr	_LVOStrToLong(a6)
        cmpi.l  #-1,d0
        beq.s   ewx_nil
        cmpi.l  #-800,ewxlong
        blt.s   ewx_nil
        cmpi.l  #800,ewxlong
        bgt.s   ewx_nil
        bra     ewloop
ewx_nil move.l  #10,ewxlong
        move.l  ngptr23(pc),a0
        move.l  ewwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTIN_Number,(a3)
        move.l  #10,4(a3)
        move.l  #GTIN_MaxChars,8(a3)
        move.l  #4,12(a3)
        move.l  #TAG_DONE,16(a3)
	move.l	_GadtoolsBase(pc),a6
        jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     ewloop

do_ewy  move.l  iadr,a0
        move.l  gg_SpecialInfo(a0),a0
        move.l  (a0),a0				; si_Buffer(a0),a0
        move.l  a0,a3
        bsr     findlen
        tst.l   d0
        ble.s   ewy_nil
        move.l  a3,d1
        move.l  #ewylong,d2
	move.l	_DOSBase(pc),a6
        jsr	_LVOStrToLong(a6)
        cmpi.l  #-1,d0
        beq.s	ewy_nil
        cmpi.l  #-800,ewylong
        blt.s   ewy_nil
        cmpi.l  #800,ewylong
        bgt.s   ewy_nil
        bra     ewloop
ewy_nil move.l  #10,ewylong
        move.l  ngptr24(pc),a0
        move.l  ewwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTIN_Number,(a3)
        move.l  #10,4(a3)
        move.l  #GTIN_MaxChars,8(a3)
        move.l  #4,12(a3)
        move.l  #TAG_DONE,16(a3)
	move.l	_GadtoolsBase(pc),a6
        jsr	_LVOGT_SetGadgetAttrsA(a6)
	bra     ewloop

do_eww  move.l  iadr,a0
        move.l  gg_SpecialInfo(a0),a0
        move.l  (a0),a0				; si_Buffer(a0),a0
        move.l  a0,a3
        bsr     findlen
        tst.l   d0
        ble.s   eww_nil
        move.l  a3,d1
        move.l  #ewwlong,d2
	move.l	_DOSBase(pc),a6
        jsr	_LVOStrToLong(a6)
        cmpi.l  #-1,d0
        beq.s   eww_nil
        cmpi.l  #-800,ewwlong
        blt.s   eww_nil
        cmpi.l  #800,ewwlong
        bgt.s   eww_nil
        bra     ewloop
eww_nil move.l  #-5,ewwlong
        move.l  ngptr25(pc),a0
        move.l  ewwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTIN_Number,(a3)
        move.l  #-5,4(a3)
        move.l  #GTIN_MaxChars,8(a3)
        move.l  #4,12(a3)
        move.l  #TAG_DONE,16(a3)
	move.l	_GadtoolsBase(pc),a6
        jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     ewloop

do_ewh  move.l  iadr,a0
        move.l  gg_SpecialInfo(a0),a0
        move.l  (a0),a0				; si_Buffer(a0),a0
        move.l  a0,a3
        bsr	findlen
        tst.l   d0
        ble.s   ewh_nil
        move.l  a3,d1
        move.l  #ewhlong,d2
	move.l	_DOSBase(pc),a6
        jsr	_LVOStrToLong(a6)
        cmpi.l  #-1,d0
        beq.s   ewh_nil
        cmpi.l  #-800,ewhlong
        blt.s   ewh_nil
        cmpi.l  #800,ewhlong
        bgt.s   ewh_nil
        bra     ewloop
ewh_nil move.l  #-5,ewhlong
        move.l  ngptr26(pc),a0
        move.l  ewwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTIN_Number,(a3)
        move.l  #-5,4(a3)
        move.l  #GTIN_MaxChars,8(a3)
        move.l  #4,12(a3)
        move.l  #TAG_DONE,16(a3)
	move.l	_GadtoolsBase(pc),a6
        jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     ewloop

do_ewi  move.l  iadr,a0
        move.l  gg_SpecialInfo(a0),a0
        move.l  (a0),a0				; si_Buffer(a0),a0
        move.l  a0,a3
        bsr     findlen
        tst.l   d0
        ble.s   ewi_nil
        move.l  a3,d1
        move.l  #ewilong,d2
	move.l	_DOSBase(pc),a6
        jsr	_LVOStrToLong(a6)
        cmpi.l  #-1,d0
        beq.s   ewi_nil
        cmpi.l  #-2147483647,ewilong
        blt.s   ewi_nil
        cmpi.l  #2147483647,ewilong
        bgt.s   ewi_nil
        bra     ewloop
ewi_nil move.l  #57526127,ewilong
        move.l  ngptr27(pc),a0
        move.l  ewwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTIN_Number,(a3)
        move.l  #57526127,4(a3)
        move.l  #GTIN_MaxChars,8(a3)
        move.l  #11,12(a3)
        move.l  #TAG_DONE,16(a3)
	move.l	_GadtoolsBase(pc),a6
        jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     ewloop

do_size tst.b	actwp
        beq.s   size_e
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   size_e
        move.l  act_wndw,a0
        moveq	#0,d0
        moveq	#0,d1
        move.l  #ewwlong,a1
        move.w  2(a1),d0
        move.l  #ewhlong,a1
        move.w  2(a1),d1
	move.l	_IntuitionBase(pc),a6
        jsr	_LVOSizeWindow(a6)
size_e  bra     ewloop

do_move tst.b	actwp
        beq.s   move_e
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   move_e
        move.l  act_wndw,a0
        moveq	#0,d0
        moveq	#0,d1
        move.l  #ewxlong,a1
        move.w  2(a1),d0
        move.l  #ewylong,a1
        move.w  2(a1),d1
	move.l	_IntuitionBase(pc),a6
        jsr	_LVOMoveWindow(a6)
move_e  bra     ewloop

do_clos tst.b	actwp
        beq.s   clos_e
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   clos_e
        move.l  jwmessage(pc),a0
        move.l  #IDCMP_CLOSEWINDOW,im_Class(a0)
        move.w  #0,im_Code(a0)
        move.w  #$8200,im_Qualifier(a0)
        bsr     poke_message
        move.b  #0,actwp
        move.l  #act_wndw,a1
        move.l  #0,(a1)
        move.l  wndwptr(pc),a0
        lea     wndw_title(pc),a1
        lea     scrn_title(pc),a2
	move.l	_IntuitionBase(pc),a6
        jsr	_LVOSetWindowTitles(a6)
clos_e  bra     ewloop

do_cloz tst.b	actwp
        beq.s   cloz_e
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   cloz_e
        move.l  act_wndw,a0
	move.l	_IntuitionBase(pc),a6
        jsr	_LVOCloseWindow(a6)
        move.b  #0,actwp
        move.l  #act_wndw,a1
        move.l  #0,(a1)
        move.l  wndwptr(pc),a0
        lea     wndw_title(pc),a1
        lea     scrn_title(pc),a2
	move.l	_IntuitionBase(pc),a6
        jsr	_LVOSetWindowTitles(a6)
cloz_e  bra	ewloop

do_lims tst.b	actwp
        beq.s   lims_e
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   lims_e
        move.l  act_wndw,a0
        moveq	#0,d0
        moveq	#0,d1
        moveq	#0,d2
        moveq	#0,d3
        move.l  #ewxlong,a1
        move.w  2(a1),d0
        move.l  #ewylong,a1
        move.w  2(a1),d1
        move.l  #ewwlong,a1
        move.w  2(a1),d2
        move.l  #ewhlong,a1
        move.w  2(a1),d3
	move.l	_IntuitionBase(pc),a6
        jsr	_LVOWindowLimits(a6)
lims_e  bra     ewloop

do_mod  tst.b	actwp
        beq.s   mod_e
        move.l  #act_wndw,a1
        tst.l   (a1)
        beq.s   mod_e
        move.l  act_wndw,a0
        move.l  #ewilong,a1
        move.l  (a1),d0
	move.l	_IntuitionBase(pc),a6
        jsr	_LVOMoveWindow(a6)
mod_e   bra     ewloop

setkpt  suba.l  a0,a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOLockPubScreen(a6)
        move.l  d0,kptscrn
        beq     kpt_end

        move.l  d0,a1
        suba.l  a0,a0
	jsr	_LVOUnlockPubScreen(a6)

	move.l  kptscrn(pc),a0
        suba.l  a1,a1
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGetVisualInfoA(a6)
        move.l  d0,kptvis
        beq     kpt_end
        move.l  d0,d5

	lea     glkptptr(pc),a0
	jsr	_LVOCreateContext(a6)
        tst.l   d0
        beq     fkptvis
        move.l  d0,a0

        moveq.l	#INTEGER_KIND,d0
        lea     ngdefs17(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags17(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr17
        beq     fkptvis

        moveq.l	#INTEGER_KIND,d0
        move.l  ngptr17(pc),a0
        lea     ngdefs18(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags18(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr18
        beq     fkptwg

        moveq.l	#BUTTON_KIND,d0
        move.l  ngptr18(pc),a0
        lea     ngdefs19(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags19(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr19
        beq     fkptwg

        suba.l  a0,a0
        lea     kpttags(pc),a1
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOOpenWindowTagList(a6)
	move.l  d0,kptwptr
        beq     fkptwg

        move.l  d0,a0
        move.l  wd_RPort(a0),kptwrp

	move.l	_GfxBase(pc),a6
	jsr	_LVOWaitTOF(a6)

        move.l  kptwptr(pc),a0
        suba.l  a1,a1
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_RefreshWindow(a6)

kptloop move.l  kptwptr(pc),a0
        move.l  wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
        move.l  kptwptr(pc),a0
        move.l  wd_UserPort(a0),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_GetIMsg(a6)
        move.l  d0,a1
        move.l  im_Class(a1),iclass
        move.w  im_Code(a1),icode
        move.w  im_Qualifier(a1),iqual
        move.l  im_IAddress(a1),iadr
        move.w  im_MouseX(a1),msex
        move.w  im_MouseY(a1),msey
	jsr	_LVOGT_ReplyIMsg(a6)

	move.l	iclass,d0
	cmp.l   #IDCMP_GADGETUP,d0
        beq.s	which_kptgadup

        cmp.l   #IDCMP_GADGETDOWN,d0
        beq.s	which_kptgaddown

        cmp.l   #IDCMP_VANILLAKEY,d0
        beq.s	which_kptvankey

        cmp.l   #IDCMP_INACTIVEWINDOW,d0
        beq.s	kptwia

        cmpi.l  #IDCMP_CLOSEWINDOW,d0
        beq.s   ckptw
        bra	kptloop

kptwia  move.l  wndwptr(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOActivateWindow(a6)

ckptw   move.l  kptwptr(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOCloseWindow(a6)

fkptwg  move.l  glkptptr(pc),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOFreeGadgets(a6)

fkptvis move.l  kptvis(pc),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOFreeVisualInfo(a6)

kpt_end bra     mainloop

which_kptgadup
        move.l  iadr(pc),a0
        move.w  gg_GadgetID(a0),d0
        cmpi.b	#17,d0
        beq.s	do_kps
        cmpi.b	#18,d0
        beq     do_kpm
        cmpi.b	#19,d0
        beq     do_kbkp
        bra     kptloop

which_kptgaddown
        bra     kptloop

which_kptvankey
	move.w	icode,d0
        cmp.w   #$53,d0
        beq.s   actkps
        cmp.w   #$73,d0
        beq.s   actkps
        cmp.w   #$4D,d0
        beq.s   actkpm
        cmp.w   #$6D,d0
        beq.s   actkpm
        cmp.w   #$45,d0
        beq	do_kbkp
        cmp.w   #$65,d0
        beq     do_kbkp
        bra     kptloop

actkps  move.l  ngptr17(pc),a0
        move.l  kptwptr(pc),a1
        suba.l  a2,a2
        move.l  _IntuitionBase(pc),a6
        jsr	_LVOActivateGadget(a6)
        bra     kptloop

actkpm  move.l  ngptr18(pc),a0
        move.l  kptwptr(pc),a1
        suba.l  a2,a2
        move.l  _IntuitionBase(pc),a6
        jsr	_LVOActivateGadget(a6)
        bra     kptloop

do_kps  move.l  iadr,a0
        move.l  gg_SpecialInfo(a0),a0
        move.l  (a0),a0				; si_Buffer(a0),a0
        move.l  a0,a3
        bsr     findlen
        tst.l   d0
        ble.s   kps_nil
        move.l  a3,d1
        move.l  #kpslong,d2
	move.l	_DOSBase(pc),a6
	jsr	_LVOStrToLong(a6)
        cmpi.l  #-1,d0
        beq.s   kps_nil
        move.l  #kpslong,a0
        and.l   #$0000FFFF,(a0)
        cmpi.l  #0,kpslong
        blt.s   kps_nil
        cmpi.l  #900,kpslong
        bgt.s   kps_nil
        bra     kptloop
kps_nil move.l  #0,kpslong
        move.l  ngptr17(pc),a0
        move.l  kptwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTIN_Number,(a3)
        move.l  #0,4(a3)
        move.l  #GTIN_MaxChars,8(a3)
        move.l  #11,12(a3)
        move.l  #TAG_DONE,16(a3)
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     kptloop

do_kpm  move.l  iadr,a0
        move.l  gg_SpecialInfo(a0),a0
        move.l  (a0),a0				; si_Buffer(a0),a0
        move.l  a0,a3
        bsr     findlen
        tst.l   d0
        ble.s   kpm_nil
        move.l  a3,d1
        move.l  #kpmlong,d2
	move.l	_DOSBase(pc),a6
        jsr	_LVOStrToLong(a6)
        cmpi.l  #-1,d0
        beq.s   kpm_nil
        move.l  #kpmlong,a0
        and.l   #$0000FFFF,(a0)
        cmpi.l  #0,kpmlong
        blt.s   kpm_nil
        cmpi.l  #900000,kpmlong
        bgt.s   kpm_nil
        bra     kptloop
kpm_nil move.l  #12000,kpmlong
        move.l  ngptr18(pc),a0
        move.l  kptwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTIN_Number,(a3)
        move.l  #12000,4(a3)
        move.l  #GTIN_MaxChars,8(a3)
        move.l  #11,12(a3)
        move.l  #TAG_DONE,16(a3)
	move.l	_GadtoolsBase(pc),a6
        jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     kptloop

do_kbkp	move.l	4.w,a6
        jsr	_LVOCreateMsgPort(a6)
	tst.l   d0
        beq.s   kbkp_e
        move.l  d0,keyport
        move.l  d0,a0
        moveq.l	#IOTV_SIZE,d0
        jsr	_LVOCreateIORequest(a6)
        tst.l   d0
        beq.s   delkpmp
        move.l  d0,keyio
        move.l  d0,a1
        lea     ip_name(pc),a0
        moveq	#0,d0
        moveq	#0,d1
        jsr	_LVOOpenDevice(a6)
        tst.l   d0
        bne.s   delkpio

        movea.l keyio(pc),a1
        move.w  #IND_SETPERIOD,IO_COMMAND(a1)
        lea     IOTV_TIME(a1),a0
        move.l  kpslong,(a0)			; kpslong,TV_SECS(a0)
        move.l  kpmlong,TV_MICRO(a0)
        jsr	_LVODoIO(a6)

closekp movea.l keyio(pc),a1
        jsr	_LVOCloseDevice(a6)

delkpio movea.l keyio(pc),a0
        jsr	_LVODeleteIORequest(a6)

delkpmp movea.l keyport(pc),a0
        jsr	_LVODeleteMsgPort(a6)

kbkp_e  bra     kptloop

setkrt  suba.l  a0,a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOLockPubScreen(a6)
        move.l  d0,krtscrn
        beq     krt_end

        move.l  d0,a1
        suba.l  a0,a0
	jsr	_LVOUnlockPubScreen(a6)

        move.l  krtscrn(pc),a0
        suba.l  a1,a1
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGetVisualInfoA(a6)
        move.l  d0,krtvis
        beq     krt_end
        move.l  d0,d5

        lea     glkrtptr(pc),a0
	jsr	_LVOCreateContext(a6)
        tst.l   d0
        beq     fkrtvis
        move.l  d0,a0

        moveq.l	#INTEGER_KIND,d0
        lea     ngdefs20(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags20(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr20
        beq     fkrtvis

	moveq.l	#INTEGER_KIND,d0
        move.l  ngptr20(pc),a0
        lea     ngdefs21(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags21(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr21
        beq     fkrtwg

        moveq.l	#BUTTON_KIND,d0
        move.l  ngptr21(pc),a0
        lea     ngdefs22(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags22(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr22
        beq     fkrtwg

        suba.l  a0,a0
        lea     krttags(pc),a1
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOOpenWindowTagList(a6)
	move.l  d0,krtwptr
        beq     fkrtwg

        move.l  d0,a0
        move.l  wd_RPort(a0),krtwrp

	move.l	_GfxBase(pc),a6
	jsr	_LVOWaitTOF(a6)

        move.l  krtwptr(pc),a0
        suba.l  a1,a1
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_RefreshWindow(a6)

krtloop move.l  krtwptr(pc),a0
        move.l  wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
        move.l  krtwptr(pc),a0
        move.l  wd_UserPort(a0),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_GetIMsg(a6)
        move.l  d0,a1
        move.l  im_Class(a1),iclass
        move.w  im_Code(a1),icode
        move.w  im_Qualifier(a1),iqual
        move.l  im_IAddress(a1),iadr
        move.w  im_MouseX(a1),msex
        move.w  im_MouseY(a1),msey
	jsr	_LVOGT_ReplyIMsg(a6)

	move.l	iclass,d0
        cmp.l   #IDCMP_GADGETUP,d0
        beq.s	which_krtgadup

        cmp.l   #IDCMP_GADGETDOWN,d0
        beq.s	which_krtgaddown

        cmp.l   #IDCMP_VANILLAKEY,d0
        beq.s	which_krtvankey

        cmp.l   #IDCMP_INACTIVEWINDOW,d0
        beq.s	krtwia

        cmpi.l  #IDCMP_CLOSEWINDOW,d0
        beq.s   ckrtw
        bra     krtloop

krtwia  move.l  wndwptr(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOActivateWindow(a6)

ckrtw   move.l  krtwptr(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOCloseWindow(a6)

fkrtwg  move.l  glkrtptr(pc),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOFreeGadgets(a6)

fkrtvis move.l  krtvis(pc),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOFreeVisualInfo(a6)

krt_end bra     mainloop

which_krtgadup
        move.l  iadr(pc),a0
        move.w  gg_GadgetID(a0),d0
        cmpi.b	#20,d0
        beq.s	do_krs
        cmpi.b	#21,d0
        beq     do_krm
        cmpi.b	#22,d0
        beq     do_kbkr
        bra     krtloop

which_krtgaddown
        bra     krtloop

which_krtvankey
	move.w	icode,d0
        cmp.w   #$53,d0
        beq.s   actkrs
        cmp.w   #$73,d0
        beq.s   actkrs
        cmp.w   #$4D,d0
        beq.s   actkrm
        cmp.w   #$6D,d0
        beq.s   actkrm
        cmp.w   #$45,d0
        beq     do_kbkr
        cmp.w   #$65,d0
        beq     do_kbkr
        bra     krtloop

actkrs  move.l  ngptr20(pc),a0
        move.l  krtwptr(pc),a1
        suba.l  a2,a2
        move.l  _IntuitionBase(pc),a6
        jsr	_LVOActivateGadget(a6)
        bra     krtloop

actkrm  move.l  ngptr21(pc),a0
        move.l  krtwptr(pc),a1
        suba.l  a2,a2
        move.l  _IntuitionBase(pc),a6
        jsr	_LVOActivateGadget(a6)
	bra     krtloop

do_krs  move.l  iadr,a0
        move.l  gg_SpecialInfo(a0),a0
        move.l  (a0),a0				; si_Buffer(a0),a0
        move.l  a0,a3
        bsr     findlen
        tst.l   d0
        ble.s   krs_nil
        move.l  a3,d1
        move.l  #krslong,d2
	move.l	_DOSBase(pc),a6
	jsr	_LVOStrToLong(a6)
        cmpi.l  #-1,d0
        beq.s   krs_nil
        move.l  #krslong,a0
        and.l   #$0000FFFF,(a0)
        cmpi.l  #0,krslong
        blt.s   krs_nil
        cmpi.l  #900,krslong
        bgt.s   krs_nil
        bra     krtloop
krs_nil move.l  #1,krslong
        move.l  ngptr20(pc),a0
        move.l  krtwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTIN_Number,(a3)
        move.l  #1,4(a3)
        move.l  #GTIN_MaxChars,8(a3)
        move.l  #11,12(a3)
        move.l  #TAG_DONE,16(a3)
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     krtloop

do_krm  move.l  iadr,a0
        move.l  gg_SpecialInfo(a0),a0
        move.l  (a0),a0				; si_Buffer(a0),a0
        move.l  a0,a3
        bsr     findlen
        tst.l   d0
        ble.s   krm_nil
        move.l  a3,d1
        move.l  #krmlong,d2
	move.l	_DOSBase(pc),a6
        jsr	_LVOStrToLong(a6)
        cmpi.l  #-1,d0
        beq.s   krm_nil
        move.l  #krmlong,a0
        and.l   #$0000FFFF,(a0)
        cmpi.l  #0,krmlong
        blt.s   krm_nil
        cmpi.l  #900000,krmlong
        bgt.s   krm_nil
        bra     krtloop
krm_nil move.l  #500000,krmlong
        move.l  ngptr21(pc),a0
        move.l  krtwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTIN_Number,(a3)
        move.l  #500000,4(a3)
        move.l  #GTIN_MaxChars,8(a3)
        move.l  #11,12(a3)
        move.l  #TAG_DONE,16(a3)
	move.l	_GadtoolsBase(pc),a6
        jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     krtloop

do_kbkr	move.l	4.w,a6
        jsr	_LVOCreateMsgPort(a6)
        tst.l   d0
        beq.s   kbkr_e
        move.l  d0,keyport
        move.l  d0,a0
        moveq.l	#IOTV_SIZE,d0
        jsr	_LVOCreateIORequest(a6)
        tst.l   d0
        beq.s	delkrmp
        move.l  d0,keyio
        move.l  d0,a1
        lea     ip_name(pc),a0
        moveq	#0,d0
        moveq	#0,d1
        jsr	_LVOOpenDevice(a6)
        tst.l   d0
        bne.s   delkrio

        movea.l keyio(pc),a1
        move.w  #IND_SETTHRESH,IO_COMMAND(a1)
        lea     IOTV_TIME(a1),a0
        move.l  krslong,(a0)			; krslong,TV_SECS(a0)
        move.l  krmlong,TV_MICRO(a0)
        jsr	_LVODoIO(a6)

closekr movea.l keyio(pc),a1
        jsr	_LVOCloseDevice(a6)

delkrio movea.l keyio(pc),a0
        jsr	_LVODeleteIORequest(a6)

delkrmp movea.l keyport(pc),a0
        jsr	_LVODeleteMsgPort(a6)

kbkr_e  bra     krtloop

mpc     addq.b	#1,smpt
        move.b  smpt,d0
        tst.b	d0
        beq.s	smpt_e
        cmpi.b	#1,d0
        beq.s   smpt_e
        move.b  #0,smpt
smpt_e	move.l	4.w,a6
        jsr	_LVOCreateMsgPort(a6)
        tst.l   d0
        beq.s   mpc_end
        move.l  d0,mouseport
        move.l  d0,a0
        moveq.l	#IOSTD_SIZE,d0
        jsr	_LVOCreateIORequest(a6)
        tst.l   d0
        beq.s   delmp
        move.l  d0,mouseio
        move.l  d0,a1
        lea     ip_name(pc),a0
        moveq	#0,d0
        moveq	#0,d1
        jsr	_LVOOpenDevice(a6)
        tst.l   d0
        bne.s   delio

        movea.l mouseio(pc),a1
        move.w  #IND_SETMPORT,IO_COMMAND(a1)
        move.l  #smpt,IO_DATA(a1)
        move.l  #1,IO_LENGTH(a1)
        jsr	_LVODoIO(a6)

closemd movea.l mouseio(pc),a1
        jsr	_LVOCloseDevice(a6)

delio   movea.l mouseio(pc),a0
        jsr	_LVODeleteIORequest(a6)

delmp   movea.l mouseport(pc),a0
        jsr	_LVODeleteMsgPort(a6)

mpc_end bra     mainloop

setdly  suba.l  a0,a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOLockPubScreen(a6)
        move.l  d0,dlyscrn
        beq     sd_end

        move.l  d0,a1
        suba.l  a0,a0
	jsr	_LVOUnlockPubScreen(a6)

        move.l  dlyscrn(pc),a0
        suba.l  a1,a1
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGetVisualInfoA(a6)
        move.l  d0,dlyvis
	beq     sd_end
        move.l  d0,d5

        lea     glistptr(pc),a0
	jsr	_LVOCreateContext(a6)
        tst.l   d0
        beq     fdlyvis
        move.l  d0,a0

        moveq.l	#INTEGER_KIND,d0
        lea     ngdefs16(pc),a1
        move.l  d5,gng_VisualInfo(a1)
        lea     ngtags16(pc),a2
	jsr	_LVOCreateGadgetA(a6)
        move.l  d0,ngptr16
        beq     fdlyvis

        suba.l  a0,a0
        lea     dlytags(pc),a1
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOOpenWindowTagList(a6)
        move.l  d0,dlywptr
        beq     fdwg

        move.l  d0,a0
        move.l  wd_RPort(a0),dlywrp

	move.l	_GfxBase(pc),a6
	jsr	_LVOWaitTOF(a6)

        move.l  dlywptr(pc),a0
        suba.l  a1,a1
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_RefreshWindow(a6)

dlyloop move.l  dlywptr(pc),a0
        move.l  wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
        move.l  dlywptr(pc),a0
        move.l  wd_UserPort(a0),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_GetIMsg(a6)
        move.l  d0,a1
        move.l  im_Class(a1),iclass
        move.w  im_Code(a1),icode
        move.w  im_Qualifier(a1),iqual
        move.l  im_IAddress(a1),iadr
        move.w  im_MouseX(a1),msex
        move.w  im_MouseY(a1),msey
	jsr	_LVOGT_ReplyIMsg(a6)

	move.l	iclass,d0
        cmp.l   #IDCMP_GADGETUP,d0
        beq.s	which_dlygadup

        cmp.l   #IDCMP_GADGETDOWN,d0
        beq.s	which_dlygaddown

        cmp.l   #IDCMP_VANILLAKEY,d0
        beq.s	which_dlyvankey

        cmp.l   #IDCMP_INACTIVEWINDOW,d0
        beq.s   dwia

        cmpi.l  #IDCMP_CLOSEWINDOW,d0
        beq.s   cdw
        bra     dlyloop

dwia    move.l  wndwptr(pc),a0
	move.l	_IntuitionBase(pc),a6
        jsr	_LVOActivateWindow(a6)

cdw     move.l  dlywptr(pc),a0
	move.l	_IntuitionBase(pc),a6
        jsr	_LVOCloseWindow(a6)

fdwg    move.l  glistptr(pc),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOFreeGadgets(a6)

fdlyvis move.l  dlyvis(pc),a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOFreeVisualInfo(a6)

sd_end  bra     mainloop

which_dlygadup
        move.l  iadr(pc),a0
        move.w  gg_GadgetID(a0),d0
        cmpi.b	#16,d0
        beq.s   do_dly
        bra     dlyloop

which_dlygaddown
        bra     dlyloop

which_dlyvankey
	move.w	icode,d0
        cmp.w   #$47,d0
        beq.s   actdly
        cmp.w   #$67,d0
        beq.s   actdly
        bra     dlyloop

actdly  move.l  ngptr16(pc),a0
        move.l  dlywptr(pc),a1
        suba.l  a2,a2
        move.l  _IntuitionBase(pc),a6
        jsr	_LVOActivateGadget(a6)
        bra     dlyloop

do_dly  move.l  iadr,a0
        move.l  gg_SpecialInfo(a0),a0
        move.l  (a0),a0				; si_Buffer(a0),a0
        move.l  a0,a3
        bsr     findlen
        tst.l   d0
        ble.s   dly_nil
        move.l  a3,d1
        move.l  #dlylong,d2
	move.l	_DOSBase(pc),a6
	jsr	_LVOStrToLong(a6)
        cmpi.l  #-1,d0
        beq.s   dly_nil
        move.l  #dlylong,a0
        and.l   #$0000FFFF,(a0)
        cmpi.l  #100,dlylong
        blt.s   dly_nil
        cmpi.l  #900,dlylong
        bgt.s   dly_nil
        bra     dlyloop
dly_nil move.l  #200,dlylong
        move.l  ngptr16(pc),a0
        move.l  dlywptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTIN_Number,(a3)
        move.l  #200,4(a3)
        move.l  #GTIN_MaxChars,8(a3)
        move.l  #3,12(a3)
        move.l  #TAG_DONE,16(a3)
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     dlyloop

which_vanillakey
	move.w	icode,d0
        cmp.w   #$6B,d0
        beq     set_mx0
        cmp.w   #$61,d0
        beq     set_mx1
        cmp.w   #$75,d0
        beq     set_mx2
        cmp.w   #$6E,d0
        beq     set_mx3
        cmp.w   #$67,d0
        beq     set_tq0
        cmp.w   #$69,d0
        beq     set_tq1
        cmp.w   #$68,d0
        beq     set_tq2
        cmp.w   #$66,d0
        beq     set_tq3
        cmp.w   #$6C,d0
        beq     set_tq4
        cmp.w   #$74,d0
        beq     set_tq5
        cmp.w   #$72,d0
        beq     set_tq6
        cmp.w   #$6F,d0
        beq     set_mc0
        cmp.w   #$70,d0
        beq     set_mc1
        cmp.w   #$4D,d0
        beq     set_mc2
        cmp.w   #$55,d0
        beq     set_mc3
        cmp.w   #$44,d0
        beq     set_mc4
        cmp.w   #$52,d0
        beq     set_mc5
        cmp.w   #$43,d0
        beq     setclas
        cmp.w   #$51,d0
        beq     setqual
        cmp.w   #$4F,d0
        beq     setcode
        cmp.w   #$79,d0
        beq.s	deccycq
        cmp.w   #$7A,d0
        beq     addcycq
        cmp.w   #$78,d0
        beq.s   deccycm
        cmp.w   #$76,d0
        beq.s   addcycm
        bra     mainloop

deccycm subq.b	#1,mcyc
        tst.b	mcyc
        bge.s   acm_e
        move.b  #5,mcyc
        bra.s   acm_e
addcycm addq.b	#1,mcyc
        cmp.b   #5,mcyc
        ble.s   acm_e
        move.b  #0,mcyc
acm_e   move.l  ngptr15(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCY_Active,(a3)
        move.l  #mcyc,a4
        moveq	#0,d0
        move.b  (a4),d0
        move.l  d0,4(a3)
        move.l  #TAG_DONE,8(a3)
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     mainloop

deccycq subq.b	#1,qcyc
        tst.b	qcyc
        bge.s   acq_e
        move.b  #5,qcyc
        bra.s   acq_e
addcycq addq.b	#1,qcyc
        cmp.b   #5,qcyc
        ble.s   acq_e
        move.b  #0,qcyc
acq_e   move.l  ngptr12(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCY_Active,(a3)
        move.l  #qcyc,a4
        moveq	#0,d0
        move.b  (a4),d0
        move.l  d0,4(a3)
        move.l  #TAG_DONE,8(a3)
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     mainloop

setclas move.l  ngptr14(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  _IntuitionBase(pc),a6
        jsr	_LVOActivateGadget(a6)
        bra     mainloop

setqual move.l  ngptr13(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  _IntuitionBase(pc),a6
        jsr	_LVOActivateGadget(a6)
        bra     mainloop

setcode move.l  ngptr7(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  _IntuitionBase(pc),a6
        jsr	_LVOActivateGadget(a6)
        bra     mainloop

set_tq0	move.l	_GadtoolsBase(pc),a6
	move.l  ngptr0(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCB_Checked,(a3)
        tst.b	amgal
        bne.s   lam1
        move.l  #TRUE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        move.b  #1,amgal
        bra     mainloop
lam1    move.l  #FALSE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        move.b  #0,amgal
        bra     mainloop

set_tq1	move.l	_GadtoolsBase(pc),a6
	move.l  ngptr3(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCB_Checked,(a3)
        tst.b	amgar
        bne.s   ram1
        move.l  #TRUE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        move.b  #1,amgar
        bra     mainloop
ram1    move.l  #FALSE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
	move.b  #0,amgar
        bra     mainloop

set_tq2	move.l	_GadtoolsBase(pc),a6
	move.l  ngptr1(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCB_Checked,(a3)
        tst.b	shftl
        bne.s   shl1
        move.l  #TRUE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        move.b  #1,shftl
        bra     mainloop
shl1    move.l  #FALSE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        move.b  #0,shftl
        bra     mainloop

set_tq3	move.l	_GadtoolsBase(pc),a6
	move.l  ngptr4(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCB_Checked,(a3)
        tst.b	shftr
        bne.s   shr1
        move.l  #TRUE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        move.b  #1,shftr
        bra     mainloop
shr1    move.l  #FALSE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        move.b  #0,shftr
        bra     mainloop

set_tq4	move.l	_GadtoolsBase(pc),a6
	move.l  ngptr2(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCB_Checked,(a3)
        tst.b	altl
        bne.s   altl1
        move.l  #TRUE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        move.b  #1,altl
        bra     mainloop
altl1   move.l  #FALSE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        move.b  #0,altl
        bra     mainloop

set_tq5	move.l	_GadtoolsBase(pc),a6
	move.l  ngptr5(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCB_Checked,(a3)
        tst.b	altr
        bne.s   altr1
        move.l  #TRUE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        move.b  #1,altr
        bra     mainloop
altr1   move.l  #FALSE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        move.b  #0,altr
        bra     mainloop

set_tq6	move.l	_GadtoolsBase(pc),a6
	move.l  ngptr8(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTCB_Checked,(a3)
        tst.b	ctrl
        bne.s   ctrl1
        move.l  #TRUE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        move.b  #1,ctrl
        bra     mainloop
ctrl1   move.l  #FALSE,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        move.b  #0,ctrl
        bra     mainloop

set_mc0 move.b  #0,msel
        move.l  ngptr9(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTMX_Active,(a3)
        move.l  #0,4(a3)
        move.l  #TAG_DONE,8(a3)
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     mainloop

set_mc1 move.b  #1,msel
        move.l  ngptr9(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTMX_Active,(a3)
        move.l  #1,4(a3)
        move.l  #TAG_DONE,8(a3)
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     mainloop

set_mc2 move.b  #0,msem
        move.l  ngptr10(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTMX_Active,(a3)
        move.l  #0,4(a3)
        move.l  #TAG_DONE,8(a3)
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     mainloop

set_mc3 move.b  #1,msem
        move.l  ngptr10(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTMX_Active,(a3)
        move.l  #1,4(a3)
        move.l  #TAG_DONE,8(a3)
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     mainloop

set_mc4 move.b  #0,mser
        move.l  ngptr11(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTMX_Active,(a3)
        move.l  #0,4(a3)
        move.l  #TAG_DONE,8(a3)
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     mainloop

set_mc5 move.b  #1,mser
        move.l  ngptr11(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTMX_Active,(a3)
        move.l  #1,4(a3)
        move.l  #TAG_DONE,8(a3)
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     mainloop

set_mx0 move.b  #0,actmx
        move.l  ngptr6(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTMX_Active,(a3)
        move.l  #0,4(a3)
        move.l  #TAG_DONE,8(a3)
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     mainloop

set_mx1 move.b  #1,actmx
        move.l  ngptr6(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTMX_Active,(a3)
        move.l  #1,4(a3)
        move.l  #TAG_DONE,8(a3)
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     mainloop

set_mx2 move.b  #2,actmx
        move.l  ngptr6(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTMX_Active,(a3)
        move.l  #2,4(a3)
        move.l  #TAG_DONE,8(a3)
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     mainloop

set_mx3 move.b  #3,actmx
        move.l  ngptr6(pc),a0
        move.l  wndwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTMX_Active,(a3)
        move.l  #3,4(a3)
        move.l  #TAG_DONE,8(a3)
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_SetGadgetAttrsA(a6)
        bra     mainloop

which_rawkey

        bra     mainloop

which_mousebutton

        bra     mainloop

refresh_window
        bsr.s	begin_refresh

        bsr.s	end_refresh

        bra     mainloop

window_inactive

        bra     mainloop

window_active

        bra     mainloop


 * Sub-Routines.

begin_refresh:
        move.l  wndwptr,a0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_BeginRefresh(a6)
        rts

end_refresh:
        move.l  wndwptr,a0
        moveq.l	#-1,d0
	move.l	_GadtoolsBase(pc),a6
	jsr	_LVOGT_EndRefresh(a6)
        rts

poke_message
	move.l	4.w,a6
	jsr	_LVOForbid(a6)
        move.l  act_port,a0
        move.l  jwmessage(pc),a1
	jsr	_LVOPutMsg(a6)
	jsr	_LVOPermit(a6)
        move.l  jwport(pc),a0
	jsr	_LVOWaitPort(a6)
        move.l  jwport(pc),a0
	jsr	_LVOGetMsg(a6)
        move.l  d0,a1
        rts

findlen	move.l	a0,a1
        moveq	#0,d0
not_nil	tst.b   (a1)+
        beq.s	got_len
        addq.b	#1,d0
        bra.s	not_nil
got_len	rts

string_copy
        moveq	#0,d0
        move.l  a0,a2
again   move.b  (a1)+,(a2)+
        bne.s	again
        subq.w  #1,a2
        sub.l   a0,a2
        move.l  a2,d0
        rts

compare_bytes
        move.b  (a0)+,d0
        move.b  (a1)+,d1
        tst.b   d0
        beq.s   zero_byte
        cmp.b   d1,d0
        beq.s   compare_bytes

zero_byte
        sub.b   d1,d0
        ext.w   d0
        ext.l   d0
        rts

hextobin
	move.l	ngptr33(pc),a0
	move.l  gg_SpecialInfo(a0),a0
        move.l  (a0),a0				; si_Buffer(a0),a0
        move.l  a0,a3
	move.l	a3,a4
        bsr.s	findlen
        tst.l   d0
        ble.s   htb_end
	moveq	#0,d1
	moveq.l	#8,d0
loop	move.b	(a3),d1
	bsr.s	isithex
	addq.l	#1,a3
	subq.b	#1,d0
	cmpi.b	#1,d0
	beq.s	adj
	lsl.l	#4,d1
	bra.s	loop
adj	move.l	d1,d2
	moveq	#0,d1
	move.b	(a3),d1
	bsr.s	isithex
	lsr.b	#4,d1
	eor.b	d1,d2
	move.l	d2,ssnlong
	move.l	_GadtoolsBase(pc),a6
        move.l  ngptr33(pc),a0
        move.l  ssnwptr(pc),a1
        suba.l  a2,a2
        move.l  #newtags,a3
        move.l  #GTST_String,(a3)
        move.l  a4,4(a3)
        move.l  #TAG_DONE,8(a3)
	jsr	_LVOGT_SetGadgetAttrsA(a6)
	move.l	ssnwptr(pc),a0
	suba.l	a1,a1
	jsr	_LVOGT_RefreshWindow(a6)
htb_end	rts

isithex	cmpi.b	#102,d1
	bgt.s	zero_it		; Can't possibly be Hex.
	cmpi.b	#97,d1
	bge.s	its_af
	cmpi.b	#70,d1
	bgt.s	zero_it		; Can't possibly be Hex.
	cmpi.b	#65,d1
	bge.s	its_AF
	cmpi.b	#57,d1
	bgt.s	zero_it		; Can't possibly be Hex.
	cmpi.b	#48,d1
	bge.s	its_09
zero_it	clr.b	d1
	move.b	#48,(a3)
	bra.s	iih_e
its_af	sub.b	#87,d1
	bra.s	iih_e
its_AF	sub.b	#55,d1
	bra.s	iih_e
its_09	sub.b	#48,d1
iih_e	lsl.b	#4,d1
	rts


 * Structure Definitions.

font_name
        dc.b    'topaz.font',0
        even

topaz8
        dc.l    font_name
        dc.w    8
        dc.b    FS_NORMAL,FPF_ROMFONT

mmstg0
        dc.b    ' RAW  KEYS',0
        even

mmstg1
        dc.b    '   CURSOR  KEYS',0
        even

mmstg2
        dc.b    '  WINDOW  OPTIONS',0
        even

mmstg3
        dc.b    '   MOUSE/KEY  OPTIONS',0
        even

mistg0
        dc.b    'Esc',0
        even

mistg1
        dc.b    'F Keys',0
        even

mistg2
        dc.b    'F1',0
        even

mistg3
        dc.b    'F2',0
        even

mistg4
        dc.b    'F3',0
        even

mistg5
        dc.b    'F4',0
        even

mistg6
        dc.b    'F5',0
        even

mistg7
        dc.b    'F6',0
        even

mistg8
        dc.b    'F7',0
        even

mistg9
        dc.b    'F8',0
        even

mistg10
        dc.b    'F9',0
        even

mistg11
        dc.b    'F10',0
        even

mistg12
        dc.b    'Del',0
        even

mistg13
        dc.b    'Help',0
        even

mistg20
        dc.b    'Cursor Up',0
        even

mistg21
        dc.b    'Cursor Down',0
        even

mistg22
        dc.b    'Cursor Left',0
        even

mistg23
        dc.b    'Cursor Right',0
        even

mistg24
        dc.b    'Shift Up',0
        even

mistg25
        dc.b    'Shift Down',0
        even

mistg26
        dc.b    'Shift Left',0
        even

mistg27
        dc.b    'Shift Right',0
        even

mistg30
        dc.b    'Send Message',0
        even

mistg31
        dc.b    'Grab A Window',0
        even

mistg32
        dc.b    'G.A.W Pause',0
        even

mistg33
        dc.b    'Signal A Task',0
        even

mistg34
        dc.b    'Edit A Window',0
        even

mistg40
        dc.b    'Set KEY-Press Time',0
        even

mistg41
        dc.b    'Set KEY-Repeat Time',0
        even

mistg42
        dc.b    '   Mouse In JoyPort',0
        even

itext0
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg0,0

itext1
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg1,0

itext2
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg2,0

itext3
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg3,0

itext4
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg4,0

itext5
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg5,0

itext6
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg6,0

itext7
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg7,0

itext8
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg8,0

itext9
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg9,0

itext10
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg10,0

itext11
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg11,0

itext12
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg12,0

itext13
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg13,0

itext20
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg20,0

itext21
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg21,0

itext22
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg22,0

itext23
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg23,0

itext24
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg24,0

itext25
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg25,0

itext26
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg26,0

itext27
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg27,0

itext30
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg30,0

itext31
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg31,0

itext32
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg32,0

itext33
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg33,0

itext34
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg34,0

itext40
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg40,0

itext41
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg41,0

itext42
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz8,mistg42,0

menu0
        dc.l    menu1
        dc.w    0,0,98,10,MENUENABLED
        dc.l    mmstg0,menuitem0
        dc.w    0,0,0,0

menuitem0
        dc.l    menuitem1
        dc.w    0,0,90,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext0,0
        dc.b    81,0
        dc.l    0,0

menuitem1
        dc.l    menuitem2
        dc.w    0,10,92,10,ITEMTEXT!HIGHCOMP!ITEMENABLED
        dc.l    0,itext1,0
        dc.b    0,0
        dc.l    subitem0,0

subitem0
        dc.l    subitem1
        dc.w    96,0,78,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext2,0
        dc.b    49,0
        dc.l    0,0

subitem1
        dc.l    subitem2
        dc.w    96,10,78,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext3,0
        dc.b    50,0
        dc.l    0,0

subitem2
        dc.l    subitem3
        dc.w    96,20,78,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext4,0
        dc.b    51,0
        dc.l    0,0

subitem3
        dc.l    subitem4
        dc.w    96,30,78,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext5,0
        dc.b    52,0
        dc.l    0,0

subitem4
        dc.l    subitem5
        dc.w    96,40,78,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext6,0
        dc.b    53,0
        dc.l    0,0

subitem5
        dc.l    subitem6
        dc.w    96,50,78,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext7,0
        dc.b    54,0
        dc.l    0,0

subitem6
        dc.l    subitem7
        dc.w    96,60,78,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext8,0
        dc.b    55,0
        dc.l    0,0

subitem7
        dc.l    subitem8
        dc.w    96,70,78,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext9,0
        dc.b    56,0
        dc.l    0,0

subitem8
        dc.l    subitem9
        dc.w    96,80,78,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext10,0
        dc.b    57,0
        dc.l    0,0

subitem9
        dc.l    0
        dc.w    96,90,78,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext11,0
        dc.b    48,0
        dc.l    0,0

menuitem2
        dc.l    menuitem3
        dc.w    0,20,90,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext12,0
        dc.b    68,0
        dc.l    0,0

menuitem3
        dc.l    0
        dc.w    0,30,90,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext13,0
        dc.b    72,0
        dc.l    0,0

menu1
        dc.l    menu2
        dc.w    100,0,158,10,MENUENABLED
        dc.l    mmstg1,menuitem10
        dc.w    0,0,0,0

menuitem10
        dc.l    menuitem11
        dc.w    0,0,150,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext20,0
        dc.b    65,0
        dc.l    0,0

menuitem11
        dc.l    menuitem12
        dc.w    0,10,150,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext21,0
        dc.b    90,0
        dc.l    0,0

menuitem12
        dc.l    menuitem13
        dc.w    0,20,150,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext22,0
        dc.b    88,0
        dc.l    0,0

menuitem13
        dc.l    menuitem14
        dc.w    0,30,150,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext23,0
        dc.b    67,0
        dc.l    0,0

menuitem14
        dc.l    menuitem15
        dc.w    0,40,150,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext24,0
        dc.b    70,0
        dc.l    0,0

menuitem15
        dc.l    menuitem16
        dc.w    0,50,150,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext25,0
        dc.b    86,0
        dc.l    0,0

menuitem16
        dc.l    menuitem17
        dc.w    0,60,150,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext26,0
        dc.b    75,0
        dc.l    0,0

menuitem17
        dc.l    0
        dc.w    0,70,150,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext27,0
        dc.b    76,0
        dc.l    0,0

menu2
        dc.l    menu3
        dc.w    260,0,158,10,MENUENABLED
        dc.l    mmstg2,menuitem20
        dc.w    0,0,0,0

menuitem20
        dc.l    menuitem21
        dc.w    0,0,150,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext30,0
        dc.b    77,0
        dc.l    0,0

menuitem21
        dc.l    menuitem22
        dc.w    0,10,150,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext31,0
        dc.b    71,0
        dc.l    0,0

menuitem22
        dc.l    menuitem23
        dc.w    0,20,150,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext32,0
        dc.b    87,0
        dc.l    0,0

menuitem23
        dc.l    menuitem24
        dc.w    0,30,150,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext33,0
        dc.b    83,0
        dc.l    0,0

menuitem24
        dc.l    0
        dc.w    0,40,150,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext34,0
        dc.b    69,0
        dc.l    0,0

menu3
        dc.l    0
        dc.w    420,0,210,10,MENUENABLED
        dc.l    mmstg3,menuitem30
        dc.w    0,0,0,0

menuitem30
        dc.l    menuitem31
        dc.w    0,0,202,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext40,0
        dc.b    80,0
        dc.l    0,0

menuitem31
        dc.l    menuitem32
        dc.w    0,10,202,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext41,0
        dc.b    82,0
        dc.l    0,0

menuitem32
        dc.l    0
        dc.w    0,20,202,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ!CHECKIT!MENUTOGGLE
        dc.l    0,itext42,0
        dc.b    74,0
        dc.l    0,0

ngdefs0
        dc.w    107,30,24,11
        dc.l    ngtxt0,topaz8
        dc.w    0
        dc.l    PLACETEXT_RIGHT,0,0

ngptr0  dc.l    0

ngtxt0
        dc.b    'L.Ami_ga',0
        even

ngtags0
        dc.l    GTCB_Checked,FALSE
        dc.l    GTCB_Scaled,TRUE
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs1
        dc.w    107,44,24,11
        dc.l    ngtxt1,topaz8
        dc.w    1
        dc.l    PLACETEXT_RIGHT,0,0

ngptr1  dc.l    0

ngtxt1
        dc.b    'L.S_hift',0
        even

ngtags1
        dc.l    GTCB_Checked,FALSE
        dc.l    GTCB_Scaled,TRUE
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs2
        dc.w    107,58,24,11
        dc.l    ngtxt2,topaz8
        dc.w    2
        dc.l    PLACETEXT_RIGHT,0,0

ngptr2  dc.l    0

ngtxt2
        dc.b    'L.A_lt',0
        even

ngtags2
        dc.l    GTCB_Checked,FALSE
        dc.l    GTCB_Scaled,TRUE
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs3
        dc.w    214,30,24,11
        dc.l    ngtxt3,topaz8
        dc.w    3
        dc.l    PLACETEXT_RIGHT,0,0

ngptr3  dc.l    0

ngtxt3
        dc.b    'R.Am_iga',0
        even

ngtags3
        dc.l    GTCB_Checked,FALSE
        dc.l    GTCB_Scaled,TRUE
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs4
        dc.w    214,44,24,11
        dc.l    ngtxt4,topaz8
        dc.w    4
        dc.l    PLACETEXT_RIGHT,0,0

ngptr4  dc.l    0

ngtxt4
        dc.b    'R.Shi_ft',0
        even

ngtags4
        dc.l    GTCB_Checked,FALSE
        dc.l    GTCB_Scaled,TRUE
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs5
        dc.w    214,58,24,11
        dc.l    ngtxt5,topaz8
        dc.w    5
        dc.l    PLACETEXT_RIGHT,0,0

ngptr5  dc.l    0

ngtxt5
        dc.b    'R.Al_t',0
        even

ngtags5
        dc.l    GTCB_Checked,FALSE
        dc.l    GTCB_Scaled,TRUE
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs6
        dc.w    10,30,MX_WIDTH,MX_HEIGHT
        dc.l    0,topaz8
        dc.w    6
        dc.l    PLACETEXT_RIGHT,0,0

ngptr6  dc.l    0

ngtags6
        dc.l    GTMX_Active,0
        dc.l    GTMX_Labels,mx_labels
        dc.l    GTMX_Spacing,6
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

mx0stg  dc.b    'Raw_key',0
mx1stg  dc.b    'V_anilla',0
mx2stg  dc.b    'Mo_use',0
mx3stg  dc.b    'Me_nu',0

mx_labels       dc.l    mx0stg,mx1stg,mx2stg,mx3stg,0

ngdefs7
        dc.w    408,92,72,14
        dc.l    ngtxt7,topaz8
        dc.w    7
        dc.l    PLACETEXT_LEFT!NG_HIGHLABEL,0,0

ngptr7  dc.l    0

ngtxt7
        dc.b    'C_ODE ',0
        even

ngtags7
        dc.l    GTIN_Number,0
        dc.l    GTIN_MaxChars,6
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs8
        dc.w    107,72,24,11
        dc.l    ngtxt8,topaz8
        dc.w    8
        dc.l    PLACETEXT_RIGHT,0,0

ngptr8  dc.l    0

ngtxt8
        dc.b    'Ct_rl',0
        even

ngtags8
        dc.l    GTCB_Checked,FALSE
        dc.l    GTCB_Scaled,TRUE
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs9
        dc.w    318,30,MX_WIDTH,MX_HEIGHT
        dc.l    0,topaz8
        dc.w    9
        dc.l    PLACETEXT_RIGHT,0,0

ngptr9  dc.l    0

ngtags9
        dc.l    GTMX_Active,0
        dc.l    GTMX_Labels,mx0_labels
        dc.l    GTMX_Spacing,6
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

mx4stg  dc.b    'L.D_own',0
mx5stg  dc.b    'L.U_p',0

mx0_labels      dc.l    mx4stg,mx5stg,0

ngdefs10
        dc.w    409,30,MX_WIDTH,MX_HEIGHT
        dc.l    0,topaz8
        dc.w    10
        dc.l    PLACETEXT_RIGHT,0,0

ngptr10 dc.l    0

ngtags10
        dc.l    GTMX_Active,0
        dc.l    GTMX_Labels,mx1_labels
        dc.l    GTMX_Spacing,6
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

mx6stg  dc.b    '_M.Down',0
mx7stg  dc.b    'M._Up',0

mx1_labels      dc.l    mx6stg,mx7stg,0

ngdefs11
        dc.w    318,58,MX_WIDTH,MX_HEIGHT
        dc.l    0,topaz8
        dc.w    11
        dc.l    PLACETEXT_RIGHT,0,0

ngptr11 dc.l    0

ngtags11
        dc.l    GTMX_Active,0
        dc.l    GTMX_Labels,mx2_labels
        dc.l    GTMX_Spacing,6
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

mx8stg  dc.b    'R._Down',0
mx9stg  dc.b    '_R.Up',0

mx2_labels      dc.l    mx8stg,mx9stg,0

ngdefs12
        dc.w    194,72,106,13
        dc.l    0,topaz8
        dc.w    12
        dc.l    PLACETEXT_LEFT!NG_HIGHLABEL,0,0

ngptr12 dc.l    0

ngtags12
        dc.l    GTCY_Active,1
        dc.l    GTCY_Labels,qcg_labels
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

qcg0    dc.b    'PreFix',0
qcg1    dc.b    'PF+Rpt',0
qcg2    dc.b    'PF+NP',0
qcg3    dc.b    'PF+Rpt+NP',0
qcg4    dc.b    '+ QUAL',0
qcg5    dc.b    'QUALIFIER',0

qcg_labels      dc.l    qcg0,qcg1,qcg2,qcg3,qcg4,qcg5,0

ngdefs13
        dc.w    266,92,78,14
        dc.l    ngtxt13,topaz8
        dc.w    13
        dc.l    PLACETEXT_LEFT!NG_HIGHLABEL,0,0

ngptr13 dc.l    0

ngtxt13
        dc.b    '_QUALIFIER',0
        even

ngtags13
        dc.l    GTIN_Number,0
        dc.l    GTIN_MaxChars,6
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs14
        dc.w    58,92,112,14
        dc.l    ngtxt14,topaz8
        dc.w    14
        dc.l    PLACETEXT_LEFT!NG_HIGHLABEL,0,0

ngptr14 dc.l    0

ngtxt14
        dc.b    '_CLASS',0
        even

ngtags14
        dc.l    GTIN_Number,0
        dc.l    GTIN_MaxChars,11
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs15
        dc.w    390,70,90,13
        dc.l    0,topaz8
        dc.w    15
        dc.l    PLACETEXT_LEFT!NG_HIGHLABEL,0,0

ngptr15 dc.l    0

ngtags15
        dc.l    GTCY_Active,0
        dc.l    GTCY_Labels,mcg_labels
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

mcg0    dc.b    'Left',0
mcg1    dc.b    'Middle',0
mcg2    dc.b    'Right',0
mcg3    dc.b    'L+R',0
mcg4    dc.b    'L+M',0
mcg5    dc.b    'M+R',0
mcg6    dc.b    'L+M+R',0
mcg7    dc.b    'CODE',0

mcg_labels      dc.l    mcg0,mcg1,mcg2,mcg3,mcg4,mcg5,mcg6,mcg7,0

ngdefs16
        dc.w    90,14,48,14
        dc.l    ngtxt16,topaz8
        dc.w    16
        dc.l    PLACETEXT_LEFT!NG_HIGHLABEL,0,0

ngptr16 dc.l    0

ngtxt16
        dc.b    '_G.W Pause',0
        even

ngtags16
        dc.l    GTIN_Number
dlylong
        dc.l    200
        dc.l    GTIN_MaxChars,3
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs17
        dc.w    76,14,112,14
        dc.l    ngtxt17,topaz8
        dc.w    17
        dc.l    PLACETEXT_LEFT!NG_HIGHLABEL,0,0

ngptr17 dc.l    0

ngtxt17
        dc.b    '_Seconds',0
        even

ngtags17
        dc.l    GTIN_Number
kpslong
        dc.l    0
        dc.l    GTIN_MaxChars,11
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs18
        dc.w    316,14,112,14
        dc.l    ngtxt18,topaz8
        dc.w    18
        dc.l    PLACETEXT_LEFT!NG_HIGHLABEL,0,0

ngptr18 dc.l    0

ngtxt18
        dc.b    '_Micro Seconds',0
        even

ngtags18
        dc.l    GTIN_Number
kpmlong
        dc.l    12000
        dc.l    GTIN_MaxChars,11
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs19
        dc.w    443,14,40,14
        dc.l    ngtxt19,topaz8
        dc.w    19
        dc.l    PLACETEXT_IN!NG_HIGHLABEL,0,0

ngptr19 dc.l    0

ngtxt19
        dc.b    'S_et',0
        even

ngtags19
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs20
        dc.w    76,14,112,14
        dc.l    ngtxt17,topaz8
        dc.w    20
        dc.l    PLACETEXT_LEFT!NG_HIGHLABEL,0,0

ngptr20 dc.l    0

ngtxt20
        dc.b    '_Seconds',0
        even

ngtags20
        dc.l    GTIN_Number
krslong
        dc.l    1
        dc.l    GTIN_MaxChars,11
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs21
        dc.w    316,14,112,14
        dc.l    ngtxt18,topaz8
        dc.w    21
        dc.l    PLACETEXT_LEFT!NG_HIGHLABEL,0,0

ngptr21 dc.l    0

ngtxt21
        dc.b    '_Micro Seconds',0
        even

ngtags21
        dc.l    GTIN_Number
krmlong
        dc.l    500000
        dc.l    GTIN_MaxChars,11
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs22
        dc.w    443,14,40,14
        dc.l    ngtxt22,topaz8
        dc.w    22
        dc.l    PLACETEXT_IN!NG_HIGHLABEL,0,0

ngptr22 dc.l    0

ngtxt22
        dc.b    'S_et',0
        even

ngtags22
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs23
        dc.w    76,14,58,14
        dc.l    ngtxt23,topaz8
        dc.w    23
        dc.l    PLACETEXT_LEFT!NG_HIGHLABEL,0,0

ngptr23 dc.l    0

ngtxt23
        dc.b    '_X/Min X',0
        even

ngtags23
        dc.l    GTIN_Number
ewxlong
        dc.l    10
        dc.l    GTIN_MaxChars,4
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs24
        dc.w    214,14,58,14
        dc.l    ngtxt24,topaz8
        dc.w    24
        dc.l    PLACETEXT_LEFT!NG_HIGHLABEL,0,0

ngptr24 dc.l    0

ngtxt24
        dc.b    '_Y/Min Y',0
        even

ngtags24
        dc.l    GTIN_Number
ewylong
        dc.l    10
        dc.l    GTIN_MaxChars,4
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs25
        dc.w    352,14,58,14
        dc.l    ngtxt25,topaz8
        dc.w    25
        dc.l    PLACETEXT_LEFT!NG_HIGHLABEL,0,0

ngptr25 dc.l    0

ngtxt25
        dc.b    '_W/Max W',0
        even

ngtags25
        dc.l    GTIN_Number
ewwlong
        dc.l    -5
        dc.l    GTIN_MaxChars,4
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs26
        dc.w    490,14,58,14
        dc.l    ngtxt26,topaz8
        dc.w    26
        dc.l    PLACETEXT_LEFT!NG_HIGHLABEL,0,0

ngptr26 dc.l    0

ngtxt26
        dc.b    '_H/Max H',0
        even

ngtags26
        dc.l    GTIN_Number
ewhlong
        dc.l    -5
        dc.l    GTIN_MaxChars,4
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs27
        dc.w    468,33,112,14
        dc.l    ngtxt27,topaz8
        dc.w    27
        dc.l    PLACETEXT_LEFT!NG_HIGHLABEL,0,0

ngptr27 dc.l    0

ngtxt27
        dc.b    '_IDCMP',0
        even

ngtags27
        dc.l    GTIN_Number
ewilong
        dc.l    52526127
        dc.l    GTIN_MaxChars,11
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs28
        dc.w    12,33,46,14
        dc.l    ngtxt28,topaz8
        dc.w    28
        dc.l    PLACETEXT_IN!NG_HIGHLABEL,0,0

ngptr28 dc.l    0

ngtxt28
        dc.b    '_Size',0
        even

ngtags28
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs29
        dc.w    74,33,47,14
        dc.l    ngtxt29,topaz8
        dc.w    29
        dc.l    PLACETEXT_IN!NG_HIGHLABEL,0,0

ngptr29 dc.l    0

ngtxt29
        dc.b    '_Move',0
        even

ngtags29
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs30
        dc.w    318,33,86,14
        dc.l    ngtxt30,topaz8
        dc.w    30
        dc.l    PLACETEXT_IN!NG_HIGHLABEL,0,0

ngptr30 dc.l    0

ngtxt30
        dc.b    'S_et IDCMP',0
        even

ngtags30
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs31
        dc.w    137,33,55,14
        dc.l    ngtxt31,topaz8
        dc.w    31
        dc.l    PLACETEXT_IN!NG_HIGHLABEL,0,0

ngptr31 dc.l    0

ngtxt31
        dc.b    '_Close',0
        even

ngtags31
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs32
        dc.w    208,33,94,14
        dc.l    ngtxt32,topaz8
        dc.w    32
        dc.l    PLACETEXT_IN!NG_HIGHLABEL,0,0

ngptr32 dc.l    0

ngtxt32
        dc.b    'Set _Limits',0
        even

ngtags32
        dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngdefs33
        dc.w    107,14,86,14
        dc.l    ngtxt33,topaz8
        dc.w    33
        dc.l    PLACETEXT_LEFT!NG_HIGHLABEL,0,0

ngptr33 dc.l    0

ngtxt33
        dc.b    'Signal _Bits',0
        even

ngtags33
	dc.l	GTST_String,ngstg33
	dc.l	GTST_MaxChars,8
	dc.l    GT_Underscore,$0000005F
        dc.l    TAG_DONE

ngstg33
	dc.b	'C000D000',0
	even

ngdefs34
	dc.w	407,14,47,14
	dc.l	ngtxt34,topaz8
	dc.w	34
	dc.l	PLACETEXT_IN!NG_HIGHLABEL,0,0

ngptr34	dc.l	0

ngtxt34
	dc.b	'_Send',0
	even

ngtags34
        dc.l    GT_Underscore,$0000005F
	dc.l	TAG_DONE

ngdefs35
	dc.w	289,14,102,14
	dc.l	ngtxt35,topaz8
	dc.w	35
	dc.l	PLACETEXT_LEFT!NG_HIGHLABEL,0,0

ngptr35	dc.l	0

ngtxt35
	dc.b	'_Task Name',0
	even

ngtags35
	dc.l	GTST_String,ngstg35
	dc.l	GTST_MaxChars,32
	dc.l	GT_Underscore,$0000005F
	dc.l	TAG_DONE

ngstg35
	dc.b	'Blanker',0
	even

scrn_title
        dc.b    'J.White, 91 Comber House, Comber Grove, Camberwell, London SE5 0LL, ENGLAND.',0
        even

wndw_title
        dc.b    'Missing Key Emulator V1.01 - Shareware (£2.50).',0
        even

dlyw_title
        dc.b    ' 100-900',0
        even

ssnw_title
        dc.b    ' 0-31',0
        even

kptw_title
        dc.b    '           0-900                       0-900000',0
        even

krtw_title
        dc.b    '           0-900                       0-900000',0
        even

ewtw_title
        dc.b    '           0-900                       0-900000',0
        even

wndwtags
        dc.l    WA_Top,0
        dc.l    WA_Left,0
        dc.l    WA_Width,490
        dc.l    WA_Height,111
        dc.l    WA_DetailPen,0
        dc.l    WA_BlockPen,1
        dc.l    WA_IDCMP,IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_MENUPICK!IDCMP_MENUHELP!IDCMP_REFRESHWINDOW!IDCMP_CLOSEWINDOW!IDCMP_INTUITICKS!IDCMP_MOUSEMOVE
        dc.l    WA_ScreenTitle,scrn_title
        dc.l    WA_Title,wndw_title
        dc.l    WA_Gadgets
gadlistptr
        dc.l    0
        dc.l    WA_Activate,TRUE
        dc.l    WA_CloseGadget,TRUE
        dc.l    WA_DepthGadget,TRUE
        dc.l    WA_DragBar,TRUE
        dc.l    WA_NoCareRefresh,TRUE
        dc.l    WA_SmartRefresh,TRUE
        dc.l    WA_MenuHelp,TRUE
        dc.l    WA_PubScreen
wndwscrn
        dc.l    0
        dc.l    TAG_DONE

dlytags
        dc.l    WA_Top,0
        dc.l    WA_Left,0
        dc.l    WA_Width,150
        dc.l    WA_Height,33
        dc.l    WA_DetailPen,0
        dc.l    WA_BlockPen,1
        dc.l    WA_IDCMP,IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_REFRESHWINDOW!IDCMP_CLOSEWINDOW!IDCMP_INTUITICKS!IDCMP_MOUSEMOVE!IDCMP_INACTIVEWINDOW!IDCMP_ACTIVEWINDOW
	dc.l    WA_Title,dlyw_title
        dc.l    WA_Gadgets
glistptr
        dc.l    0
        dc.l    WA_Activate,TRUE
        dc.l    WA_CloseGadget,TRUE
        dc.l    WA_DepthGadget,TRUE
        dc.l    WA_DragBar,TRUE
        dc.l    WA_NoCareRefresh,TRUE
        dc.l    WA_SmartRefresh,TRUE
        dc.l    WA_RMBTrap,TRUE
        dc.l    WA_PubScreen
dlyscrn
        dc.l    0
        dc.l    TAG_DONE

kpttags
        dc.l    WA_Top,0
        dc.l    WA_Left,0
        dc.l    WA_Width,496
        dc.l    WA_Height,33
        dc.l    WA_DetailPen,0
        dc.l    WA_BlockPen,1
        dc.l    WA_IDCMP,IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_CLOSEWINDOW!IDCMP_INTUITICKS!IDCMP_MOUSEMOVE!IDCMP_REFRESHWINDOW!IDCMP_INACTIVEWINDOW!IDCMP_ACTIVEWINDOW
        dc.l    WA_Title,kptw_title
        dc.l    WA_Gadgets
glkptptr
        dc.l    0
        dc.l    WA_Activate,TRUE
        dc.l    WA_CloseGadget,TRUE
        dc.l    WA_DepthGadget,TRUE
        dc.l    WA_DragBar,TRUE
        dc.l    WA_NoCareRefresh,TRUE
        dc.l    WA_SmartRefresh,TRUE
        dc.l    WA_RMBTrap,TRUE
        dc.l    WA_PubScreen
kptscrn
        dc.l    0
        dc.l    TAG_DONE

krttags
        dc.l    WA_Top,0
        dc.l    WA_Left,0
        dc.l    WA_Width,496
        dc.l    WA_Height,33
        dc.l    WA_DetailPen,0
        dc.l    WA_BlockPen,1
        dc.l    WA_IDCMP,IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_CLOSEWINDOW!IDCMP_INTUITICKS!IDCMP_MOUSEMOVE!IDCMP_REFRESHWINDOW!IDCMP_INACTIVEWINDOW!IDCMP_ACTIVEWINDOW
        dc.l    WA_Title,krtw_title
        dc.l    WA_Gadgets
glkrtptr
        dc.l    0
        dc.l    WA_Activate,TRUE
        dc.l    WA_CloseGadget,TRUE
        dc.l    WA_DepthGadget,TRUE
        dc.l    WA_DragBar,TRUE
        dc.l    WA_NoCareRefresh,TRUE
        dc.l    WA_SmartRefresh,TRUE
        dc.l    WA_RMBTrap,TRUE
        dc.l    WA_PubScreen
krtscrn
        dc.l    0
        dc.l    TAG_DONE

ewtags
        dc.l    WA_Top,0
        dc.l    WA_Left,0
        dc.l    WA_Width,594
        dc.l    WA_Height,52
        dc.l    WA_DetailPen,0
        dc.l    WA_BlockPen,1
        dc.l    WA_IDCMP,IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_CLOSEWINDOW!IDCMP_INTUITICKS!IDCMP_MOUSEMOVE!IDCMP_REFRESHWINDOW!IDCMP_INACTIVEWINDOW!IDCMP_ACTIVEWINDOW
        dc.l    WA_Title,ewtw_title
        dc.l    WA_Gadgets
glewptr
        dc.l    0
        dc.l    WA_Activate,TRUE
        dc.l    WA_CloseGadget,TRUE
        dc.l    WA_DepthGadget,TRUE
        dc.l    WA_DragBar,TRUE
        dc.l    WA_NoCareRefresh,TRUE
        dc.l    WA_SmartRefresh,TRUE
        dc.l    WA_RMBTrap,TRUE
        dc.l    WA_PubScreen
ewscrn
        dc.l    0
        dc.l    TAG_DONE

ssntags
        dc.l    WA_Top,0
        dc.l    WA_Left,0
        dc.l    WA_Width,466
        dc.l    WA_Height,33
        dc.l    WA_DetailPen,0
        dc.l    WA_BlockPen,1
        dc.l    WA_IDCMP,IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_REFRESHWINDOW!IDCMP_CLOSEWINDOW!IDCMP_INTUITICKS!IDCMP_MOUSEMOVE!IDCMP_INACTIVEWINDOW!IDCMP_ACTIVEWINDOW
        dc.l    WA_Title,ssnw_title
        dc.l    WA_Gadgets
glssnptr
        dc.l    0
        dc.l    WA_Activate,TRUE
        dc.l    WA_CloseGadget,TRUE
        dc.l    WA_DepthGadget,TRUE
        dc.l    WA_DragBar,TRUE
        dc.l    WA_NoCareRefresh,TRUE
        dc.l    WA_SmartRefresh,TRUE
        dc.l    WA_RMBTrap,TRUE
        dc.l    WA_PubScreen
ssnscrn
        dc.l    0
        dc.l    TAG_DONE

 * Include Variables.

_IntuitionBase  dc.l    0
_GfxBase        dc.l    0
_DOSBase        dc.l    0
_IconBase       dc.l    0
_GadtoolsBase   dc.l    0
int_name        dc.b    'intuition.library',0
graf_name       dc.b    'graphics.library',0
dos_name        dc.b    'dos.library',0
icon_name       dc.b    'icon.library',0
gadtools_name   dc.b    'gadtools.library',0
ip_name         dc.b    'input.device',0
        even


 * Intuition Variables.

scrnrp  dc.l    0
wndwrp  dc.l    0
dlywrp  dc.l    0
ssnwrp  dc.l    0
kptwrp  dc.l    0
ewwrp   dc.l    0
krtwrp  dc.l    0
vpptr   dc.l    0
wndwptr dc.l    0
dlywptr dc.l    0
ssnwptr dc.l    0
kptwptr dc.l    0
ewwptr  dc.l    0
krtwptr dc.l    0
iclass  dc.l    0
icode   dc.w    0
iqual   dc.w    0
iadr    dc.l    0
msex    dc.w    0
msey    dc.w    0


 * Port Variables.

jwport          dc.l    0
jwmessage       dc.l    0
act_wndw        dc.l    0
act_port        dc.l    0
iblock          dc.l    0
imclass         dc.w    0
imcode          dc.w    0
portname        dc.b    'MISSINGKEYS',0
        even


 * ToolType strings.

argv            dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
rdargs          dc.l    0
doptr           dc.l    0
ttptr           dc.l    0
olddir          dc.l    0
ckstg           dc.l    0
template
        dc.b    'KEYCLASS/K,KEYQUALCYCLE/K,KEYCODECYCLE/K,LAMIGA/K,RAMIGA/K,LSHIFT/K,RSHIFT/K,LALT/K,RALT/K,CONTROL/K,LMOUSE/K,MMOUSE/K,RMOUSE/K,CLASSVALUE/N,QUALIFIERVALUE/N,CODEVALUE/N',0
        even

ftstg0          dc.b    'KEYCLASS',0
ftstg1          dc.b    'KEYQUALCYCLE',0
ftstg2          dc.b    'KEYCODECYCLE',0
ftstg3          dc.b    'LAMIGA',0
ftstg4          dc.b    'RAMIGA',0
ftstg5          dc.b    'LSHIFT',0
ftstg6          dc.b    'RSHIFT',0
ftstg7          dc.b    'LALT',0
ftstg8          dc.b    'RALT',0
ftstg9          dc.b    'CONTROL',0
ftstg10         dc.b    'LMOUSE',0
ftstg11         dc.b    'MMOUSE',0
ftstg12         dc.b    'RMOUSE',0
ftstg13         dc.b    'CLASSVALUE',0
ftstg14         dc.b    'QUALIFIERVALUE',0
ftstg15         dc.b    'CODEVALUE',0

mvstg0          dc.b    'OFF',0
mvstg1          dc.b    'ON',0
mvstg2          dc.b    'RAWKEY',0
mvstg3          dc.b    'VANILLA',0
mvstg4          dc.b    'MOUSE',0
mvstg5          dc.b    'MENU',0
mvstg6          dc.b    'PREFIX',0
mvstg7          dc.b    'PF+RPT',0
mvstg8          dc.b    'PF+NP',0
mvstg9          dc.b    'PF+RPT+NP',0
mvstg10         dc.b    '+QUAL',0
mvstg11         dc.b    'QUALIFIER',0
mvstg12         dc.b    'DOWN',0
mvstg13         dc.b    'UP',0
mvstg14         dc.b    'LEFT',0
mvstg15         dc.b    'MIDDLE',0
mvstg16         dc.b    'RIGHT',0
mvstg17         dc.b    'L+R',0
mvstg18         dc.b    'L+M',0
mvstg19         dc.b    'M+R',0
mvstg20         dc.b    'L+M+R',0
mvstg21         dc.b    'CODE',0


 * Gadtools Variables.

visptr          dc.l    0
kptvis          dc.l    0
ewvis           dc.l    0
krtvis          dc.l    0
dlyvis          dc.l    0
ssnvis          dc.l    0


 * Keyboard/Input Variables.

keyport         dc.l    0
keyio           dc.l    0


 * Mouse/Input Variables.

mouseport       dc.l    0
mouseio         dc.l    0
smpt            dcb.b   1,0
        even


 * Miscellaneous Variables.

bytebuf		dcb.b	12,0
codeval         dc.w    0
qualval         dc.w    0
classval        dc.l    0
longval         dc.l    0
ssnlong		dc.l	$C000D000
actwp           dc.b    0
actmx           dc.b    0
altl            dc.b    0
altr            dc.b    0
shftl           dc.b    0
shftr           dc.b    0
amgal           dc.b    0
amgar           dc.b    0
ctrl            dc.b    0
msel            dc.b    0
msem            dc.b    0
mser            dc.b    0
mcyc            dc.b    0
qcyc            dc.b    1

title0
        dc.b    'Key CLASS',0
        even

title1
        dc.b    'Key (Rawkey) QUALIFIER',0
        even

title2
        dc.b    'Key (Mouse) CODE',0
        even

newtags ds.b    40


	SECTION	VERSION,DATA

	dc.b	'$VER: Missing Key Emulator V1.01 (29.12.2000)',0


	END