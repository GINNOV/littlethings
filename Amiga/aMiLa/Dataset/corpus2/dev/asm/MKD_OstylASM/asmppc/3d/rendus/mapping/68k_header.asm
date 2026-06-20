שתשתÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ;MappingPPC (WarpOS)
;Ostyl of Mankind!
;Revdate: 19.2.03
;a0 = *struct lwobj
;a1 = *struct chunkyscreen

	INCDIR	INCLUDES:
	INCLUDE	POWERPC/GRAPHICSPPC.i
	INCLUDE	POWERPC/POWERPC.i
	INCLUDE	MACROS/POWERPC.i

	XREF	_LinkerDB
	XREF	_PowerPCBase
	XREF	PolyDraw15PPC
	XDEF	RenderPolyList
	XDEF	RenderPolyListA
	XDEF	WaitPPCRender
	XDEF	Mapping_PPStruct	

RenderPolyListA
	Moveq	#PPF_ASYNC,d0
	Bra.B	Run

RenderPolyList
	Moveq	#0,d0

Run	Move.L	_PowerPCBase,a6
	Lea	Mapping_PPStruct(pc),a5		
	Move.L	d0,PP_FLAGS(a5)	
	Move.L	#PolyDraw15PPC,PP_CODE(a5)
	Lea	PP_REGS(a5),a5
	Move.L	#_LinkerDB,r2(a5)
	Move.L	a6,r3(a5)	
	Move.L	a0,r4(a5)
	Beq.B	Leave
	Move.L	a1,r5(a5)
	Beq.B	Leave
	Lea	Mapping_PPStruct(pc),a0
	Jsr	_LVORunPPC(a6)

Leave	Rts

	;----

WaitPPCRender:
	Move.L	_PowerPCBase,a6
	Lea	Mapping_PPStruct(pc),a0
	Jsr	_LVOWaitForPPC(a6)
	Rts

	;----

Mapping_PPStruct
	Ds.B	PP_SIZE
