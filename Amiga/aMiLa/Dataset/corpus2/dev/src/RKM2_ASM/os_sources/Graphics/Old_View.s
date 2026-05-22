
 * This code was converted from an old Amiga Book. The RKM Libraries 3rd
 * Edition has a newer example. I have not converted the new version as I am
 * not really knowledgable/Interested about View/CopperList programming.

	INCDIR	WORK:Include/

	INCLUDE	exec/funcdef.i
	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	intuition/intuition_lib.i
	INCLUDE	intuition/intuition.i
	INCLUDE	graphics/graphics_lib.i
	INCLUDE	graphics/gfxbase.i
	INCLUDE	graphics/text.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i

	INCLUDE	misc/easystart.i

LIB_VER		EQU	37
MEM_TYPE	EQU	MEMF_CHIP!MEMF_CLEAR
TRUE		EQU	-1
FALSE		EQU	0


	moveq	#LIB_VER,d0
	lea	int_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_IntuitionBase
	beq	exit_quit

	moveq	#LIB_VER,d0
	lea	graf_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_GfxBase
	beq	exit_closeint

	moveq	#LIB_VER,d0
	lea	dos_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_DOSBase
	beq	exit_closegfx

	move.l	_GfxBase(pc),a0
	move.l	gb_ActiView(a0),oldview

	move.l	#bm_SIZEOF,d0
	move.l	#MEM_TYPE,d1
	CALLEXEC	AllocMem
	move.l	d0,bm0ptr
	beq	exit_closedos
	move.l	bm0ptr(pc),a0
	moveq	#2,d0
	move.w	#320,d1
	move.w	#40,d2
	CALLGRAF	InitBitMap
	move.w	#320,d0
	move.w	#40,d1
	CALLGRAF	AllocRaster
	move.l	bm0ptr(pc),a0
	move.l	d0,8(a0)
	beq	free_bm0
	move.l	d0,a1
	move.l	#1600,d0
	move.l	#0,d1
	CALLGRAF	BltClear
	move.w	#320,d0
	move.w	#40,d1
	CALLGRAF	AllocRaster
	move.l	bm0ptr(pc),a0
	move.l	d0,12(a0)
	beq	free_plane0
	move.l	d0,a1
	move.l	#1600,d0
	move.l	#0,d1
	CALLGRAF	BltClear

	move.l	#bm_SIZEOF,d0
	move.l	#MEM_TYPE,d1
	CALLEXEC	AllocMem
	move.l	d0,bm1ptr
	beq	free_plane1
	move.l	bm1ptr(pc),a0
	moveq	#2,d0
	move.w	#640,d1
	move.w	#60,d2
	CALLGRAF	InitBitMap
	move.w	#640,d0
	move.w	#60,d1
	CALLGRAF	AllocRaster
	move.l	bm1ptr(pc),a0
	move.l	d0,8(a0)
	beq	free_bm1
	move.l	d0,a1
	move.l	#4800,d0
	move.l	#0,d1
	CALLGRAF	BltClear
	move.w	#640,d0
	move.w	#60,d1
	CALLGRAF	AllocRaster
	move.l	bm1ptr(pc),a0
	move.l	d0,12(a0)
	beq	free_plane2
	move.l	d0,a1
	move.l	#4800,d0
	move.l	#0,d1
	CALLGRAF	BltClear

	move.l	#bm_SIZEOF,d0
	move.l	#MEM_TYPE,d1
	CALLEXEC	AllocMem
	move.l	d0,bm2ptr
	beq	free_plane3
	move.l	bm2ptr(pc),a0
	moveq	#2,d0
	move.w	#1280,d1
	move.w	#100,d2
	CALLGRAF	InitBitMap
	move.w	#1280,d0
	move.w	#100,d1
	CALLGRAF	AllocRaster
	move.l	bm2ptr(pc),a0
	move.l	d0,8(a0)
	beq	free_bm2
	move.l	d0,a1
	move.l	#16000,d0
	move.l	#0,d1
	CALLGRAF	BltClear
	move.w	#1280,d0
	move.w	#100,d1
	CALLGRAF	AllocRaster
	move.l	bm2ptr(pc),a0
	move.l	d0,12(a0)
	beq	free_plane4
	move.l	d0,a1
	move.l	#16000,d0
	move.l	#0,d1
	CALLGRAF	BltClear

	move.l	#rp_SIZEOF,d0
	move.l	#MEM_TYPE,d1
	CALLEXEC	AllocMem
	move.l	d0,rp0ptr
	beq	free_plane5

	move.l	#rp_SIZEOF,d0
	move.l	#MEM_TYPE,d1
	CALLEXEC	AllocMem
	move.l	d0,rp1ptr
	beq	free_rp0

	move.l	#rp_SIZEOF,d0
	move.l	#MEM_TYPE,d1
	CALLEXEC	AllocMem
	move.l	d0,rp2ptr
	beq	free_rp1

	move.l	#vp_SIZEOF,d0
	move.l	#MEM_TYPE,d1
	CALLEXEC	AllocMem
	move.l	d0,vp0ptr
	beq	free_rp2

	move.l	#vp_SIZEOF,d0
	move.l	#MEM_TYPE,d1
	CALLEXEC	AllocMem
	move.l	d0,vp1ptr
	beq	free_vp0

	move.l	#vp_SIZEOF,d0
	move.l	#MEM_TYPE,d1
	CALLEXEC	AllocMem
	move.l	d0,vp2ptr
	beq	free_vp1

	move.l	#v_SIZEOF,d0
	move.l	#MEM_TYPE,d1
	CALLEXEC	AllocMem
	move.l	d0,viewptr
	beq	free_vp2

	move.l	#ri_SIZEOF,d0
	move.l	#MEM_TYPE,d1
	CALLEXEC	AllocMem
	move.l	d0,ri0ptr
	beq	free_view

	move.l	#ri_SIZEOF,d0
	move.l	#MEM_TYPE,d1
	CALLEXEC	AllocMem
	move.l	d0,ri1ptr
	beq	free_ri0

	move.l	#ri_SIZEOF,d0
	move.l	#MEM_TYPE,d1
	CALLEXEC	AllocMem
	move.l	d0,ri2ptr
	beq	free_ri1

	move.l	rp0ptr(pc),a1
	CALLGRAF	InitRastPort
	move.l	rp0ptr(pc),a1
	move.l	bm0ptr(pc),a2
	move.l	a2,rp_BitMap(a1)

	move.l	rp1ptr(pc),a1
	CALLGRAF	InitRastPort
	move.l	rp1ptr(pc),a1
	move.l	bm1ptr(pc),a2
	move.l	a2,rp_BitMap(a1)

	move.l	rp2ptr(pc),a1
	CALLGRAF	InitRastPort
	move.l	rp2ptr(pc),a1
	move.l	bm2ptr(pc),a2
	move.l	a2,rp_BitMap(a1)

	move.l	viewptr(pc),a1
	CALLGRAF	InitView

	move.l	vp0ptr(pc),a0
	CALLGRAF	InitVPort

	move.l	vp1ptr(pc),a0
	CALLGRAF	InitVPort

	move.l	vp2ptr(pc),a0
	CALLGRAF	InitVPort

	move.l	bm0ptr(pc),a1
	move.l	ri0ptr(pc),a2
	move.l	#0,ri_Next(a2)
	move.l	a1,ri_BitMap(a2)
	move.w	#0,ri_RxOffset(a2)
	move.w	#0,ri_RyOffset(a2)
	move.l	viewptr(pc),a0
	move.l	vp0ptr(pc),a1
	move.l	a1,v_ViewPort(a0)
	move.w	#0,v_DxOffset(a0)
	move.w	#0,v_DyOffset(a0)
	move.w	#0,v_Modes(a0)
	move.w	#128,vp_DxOffset(a1)
	move.w	#40,vp_DyOffset(a1)
	move.w	#320,vp_DWidth(a1)
	move.w	#40,vp_DHeight(a1)
	move.w	#0,vp_Modes(a1)
	move.l	a2,vp_RasInfo(a1)
	move.l	vp1ptr(pc),a0
	move.l	a0,vp_Next(a1)

	move.l	bm1ptr(pc),a1
	move.l	ri1ptr(pc),a2
	move.l	#0,ri_Next(a2)
	move.l	a1,ri_BitMap(a2)
	move.w	#0,ri_RxOffset(a2)
	move.w	#0,ri_RyOffset(a2)
	move.l	vp1ptr(pc),a1
	move.w	#256,vp_DxOffset(a1)
	move.w	#81,vp_DyOffset(a1)
	move.w	#640,vp_DWidth(a1)
	move.w	#60,vp_DHeight(a1)
	move.w	#$8000,vp_Modes(a1)
	move.l	a2,vp_RasInfo(a1)
	move.l	vp2ptr(pc),a0
	move.l	a0,vp_Next(a1)

	move.l	bm2ptr(pc),a1
	move.l	ri2ptr(pc),a2
	move.l	#0,ri_Next(a2)
	move.l	a1,ri_BitMap(a2)
	move.w	#0,ri_RxOffset(a2)
	move.w	#0,ri_RyOffset(a2)
	move.l	vp2ptr(pc),a1
	move.w	#512,vp_DxOffset(a1)
	move.w	#142,vp_DyOffset(a1)
	move.w	#1280,vp_DWidth(a1)
	move.w	#100,vp_DHeight(a1)
	move.w	#$8020,vp_Modes(a1)
	move.l	a2,vp_RasInfo(a1)
	move.l	#0,vp_Next(a1)

	moveq	#4,d0
	CALLGRAF	GetColorMap
	move.l	d0,cm0ptr
	beq	free_ri2
	move.l	vp0ptr(pc),a1
	move.l	cm0ptr(pc),vp_ColorMap(a1)

	moveq	#4,d0
	CALLGRAF	GetColorMap
	move.l	d0,cm1ptr
	beq	free_cm0
	move.l	vp1ptr(pc),a1
	move.l	cm1ptr(pc),vp_ColorMap(a1)

	moveq	#4,d0
	CALLGRAF	GetColorMap
	move.l	d0,cm2ptr
	beq	free_cm1
	move.l	vp2ptr(pc),a1
	move.l	cm2ptr(pc),vp_ColorMap(a1)

	move.l	vp0ptr(pc),a0
	lea	col0defs(pc),a1
	moveq	#4,d0
	CALLGRAF	LoadRGB4

	move.l	vp1ptr(pc),a0
	lea	col1defs(pc),a1
	moveq	#4,d0
	CALLGRAF	LoadRGB4

	move.l	vp2ptr(pc),a0
	lea	col2defs(pc),a1
	moveq	#4,d0
	CALLGRAF	LoadRGB4

	move.l	viewptr(pc),a0
	move.l	vp0ptr(pc),a1
	CALLGRAF	MakeVPort

	move.l	viewptr(pc),a0
	move.l	vp1ptr(pc),a1
	CALLGRAF	MakeVPort

	move.l	viewptr(pc),a0
	move.l	vp2ptr(pc),a1
	CALLGRAF	MakeVPort

	move.l	viewptr(pc),a1
	CALLGRAF	MrgCop

	move.l	viewptr(pc),a1
	CALLGRAF	LoadView

	move.l	rp0ptr,a1
	move.l	#1,d0
	CALLGRAF	SetRast
	move.w	#16,d0
	move.w	#16,d1
	move.l	rp0ptr,a1
	CALLGRAF Move
	lea	stg0(pc),a0
	moveq	#21,d0
	move.l	rp0ptr,a1
	CALLGRAF	Text

	move.l	rp1ptr,a1
	move.l	#2,d0
	CALLGRAF	SetRast
	move.w	#16,d0
	move.w	#16,d1
	move.l	rp1ptr,a1
	CALLGRAF Move
	lea	stg1(pc),a0
	moveq	#23,d0
	move.l	rp1ptr,a1
	CALLGRAF	Text

	move.l	rp2ptr,a1
	move.l	#3,d0
	CALLGRAF	SetRast
	move.w	#16,d0
	move.w	#16,d1
	move.l	rp2ptr,a1
	CALLGRAF Move
	lea	stg2(pc),a0
	moveq	#28,d0
	move.l	rp2ptr,a1
	CALLGRAF	Text

	CALLGRAF	WaitTOF

	move.l	#300,d1
	CALLDOS	Delay

	move.l	oldview,a1
	CALLGRAF	LoadView


free_cm2
	move.l	cm2ptr(pc),a0
	CALLGRAF	FreeColorMap

free_cm1
	move.l	cm1ptr(pc),a0
	CALLGRAF	FreeColorMap

free_cm0
	move.l	cm0ptr(pc),a0
	CALLGRAF	FreeColorMap

free_ri2
	move.l	ri2ptr(pc),a1
	move.l	#ri_SIZEOF,d0
	CALLEXEC	FreeMem

free_ri1
	move.l	ri1ptr(pc),a1
	move.l	#ri_SIZEOF,d0
	CALLEXEC	FreeMem

free_ri0
	move.l	ri0ptr(pc),a1
	move.l	#ri_SIZEOF,d0
	CALLEXEC	FreeMem

free_view
	move.l	viewptr(pc),a1
	move.l	#v_SIZEOF,d0
	CALLEXEC	FreeMem

free_vp2
	move.l	vp2ptr(pc),a1
	move.l	#vp_SIZEOF,d0
	CALLEXEC	FreeMem

free_vp1
	move.l	vp1ptr(pc),a1
	move.l	#vp_SIZEOF,d0
	CALLEXEC	FreeMem

free_vp0
	move.l	vp0ptr(pc),a1
	move.l	#vp_SIZEOF,d0
	CALLEXEC	FreeMem

free_rp2
	move.l	rp2ptr(pc),a1
	move.l	#rp_SIZEOF,d0
	CALLEXEC	FreeMem

free_rp1
	move.l	rp1ptr(pc),a1
	move.l	#rp_SIZEOF,d0
	CALLEXEC	FreeMem

free_rp0
	move.l	rp0ptr(pc),a1
	move.l	#rp_SIZEOF,d0
	CALLEXEC	FreeMem

free_plane5
	move.l	bm2ptr(pc),a0
	move.l	bm_Planes+4(a0),a0
	tst.l	a0
	beq	plane5_end
	move.w	#1280,d0
	move.w	#100,d1
	CALLGRAF	FreeRaster

plane5_end

free_plane4
	move.l	bm2ptr(pc),a0
	move.l	bm_Planes(a0),a0
	tst.l	a0
	beq	plane4_end
	move.w	#1280,d0
	move.w	#100,d1
	CALLGRAF	FreeRaster

plane4_end

free_bm2
	move.l	bm2ptr(pc),a1
	move.l	#bm_SIZEOF,d0
	CALLEXEC	FreeMem

free_plane3
	move.l	bm1ptr(pc),a0
	move.l	bm_Planes+4(a0),a0
	tst.l	a0
	beq	plane3_end
	move.w	#640,d0
	move.w	#60,d1
	CALLGRAF	FreeRaster

plane3_end

free_plane2
	move.l	bm1ptr(pc),a0
	move.l	bm_Planes(a0),a0
	tst.l	a0
	beq	plane2_end
	move.w	#640,d0
	move.w	#60,d1
	CALLGRAF	FreeRaster

plane2_end

free_bm1
	move.l	bm1ptr(pc),a1
	move.l	#bm_SIZEOF,d0
	CALLEXEC	FreeMem

free_plane1
	move.l	bm0ptr(pc),a0
	move.l	bm_Planes+4(a0),a0
	tst.l	a0
	beq	plane1_end
	move.w	#320,d0
	move.w	#40,d1
	CALLGRAF	FreeRaster

plane1_end

free_plane0
	move.l	bm0ptr(pc),a0
	move.l	bm_Planes(a0),a0
	tst.l	a0
	beq	plane0_end
	move.w	#320,d0
	move.w	#40,d1
	CALLGRAF	FreeRaster

plane0_end

free_bm0
	move.l	bm0ptr(pc),a1
	move.l	#bm_SIZEOF,d0
	CALLEXEC	FreeMem

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
	move.l	#0,d0
	rts


 * Long Variables.

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
bm0ptr		dc.l	0
bm1ptr		dc.l	0
bm2ptr		dc.l	0
rp0ptr		dc.l	0
rp1ptr		dc.l	0
rp2ptr		dc.l	0
vp0ptr		dc.l	0
vp1ptr		dc.l	0
vp2ptr		dc.l	0
viewptr		dc.l	0
cm0ptr		dc.l	0
cm1ptr		dc.l	0
cm2ptr		dc.l	0
ri0ptr		dc.l	0
ri1ptr		dc.l	0
ri2ptr		dc.l	0
oldview		dc.l	0


 * Word Variables.

col0defs	dc.w	0,4095,3000,2000
col1defs	dc.w	0,4095,3000,2000
col2defs	dc.w	0,4095,3000,2000


 * String Variables.

stg0		dc.b	'A Low-Resolution View',0
stg1		dc.b	'An High-Resolution View',0
stg2		dc.b	'A Super-High-Resolution View',0,0
int_name	dc.b	'intuition.library',0
graf_name	dc.b	'graphics.library',0,0
dos_name	dc.b	'dos.library',0


	END