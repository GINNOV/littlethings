שתשתÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
	INCDIR	INCLUDES:
	INCLUDE	MISC/DEVPACMACROS.i
	INCLUDE	POWERPC/POWERPC.i
	INCLUDE	MACROS/POWERPC.i

	XDEF	AllocMemPPC
	XDEF	FreeMemPPC
	XDEF	FreeAllMemPPC
	XDEF	FreeVec32

	XREF	_PowerPCBase

	;---- AllocMemPPC()

;d0 = Taille du bloc
;d1 = Conditions
;d2 = Alignement

AllocMemPPC:
	Move.L	_PowerPCBase,a6
	Lea	AllocMemPPC_PP(pc),a0

	Move.L	a0,a1
	Move	#PP_SIZE-1,d3
ClrPP1	Clr.B	(a1)+
	Dbf	d3,ClrPP1

	Move.L	_LVOAllocVecPPC+2(a6),PP_CODE(a0)
	Move.L	a6,PP_REGS+r3(a0)
	Move.L	d0,PP_REGS+r4(a0)	;size
	Move.L	d1,PP_REGS+r5(a0)	;condition
	Move.L	d2,PP_REGS+r6(a0)
	Jsr	_LVORunPPC(a6)

	Move.L	PP_REGS+r3(a0),d0
	Rts

	;---- FreeMemPPC()
	
;d0 = membloc

FreeMemPPC
	Movem.L	d1-a6,-(sp)
	Move.L	_PowerPCBase,a6
	Lea	FreeMemPPC_PP(pc),a0

	Move.L	a0,a1
	Move	#PP_SIZE-1,d3
ClrPP2	Clr.B	(a1)+
	Dbf	d3,ClrPP2

	Move.L	_LVOFreeVecPPC+2(a6),PP_CODE(a0)
	Move.L	a6,PP_REGS+r3(a0)
	Move.L	d0,PP_REGS+r4(a0)
	Beq.B	Skip1
	Jsr	_LVORunPPC(a6)
Skip1	Movem.L	(sp)+,d1-a6
	Rts

	;---- FreeAllMemPPC()
	
FreeAllMemPPC
	Move.L	_PowerPCBase,a6
	Lea	FreeMemPPC_PP(pc),a0
	CallPPC	FreeAllMem
	Rts

	;---- FreeVec32()

;a1 = membloc
	
FreeVec32
	Movem.L	d0-a6,-(sp)
	Tst.L	a1
	Beq.B	Skip2
	Move.L	_PowerPCBase,a6
	Jsr	_LVOFreeVec32(a6)
Skip2	Movem.L	(sp)+,d0-a6
	Rts

	;----

AllocMemPPC_PP
	Ds.B	PP_SIZE	
	Even

FreeMemPPC_PP
	Ds.B	PP_SIZE
	Even
