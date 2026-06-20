ùúùúÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ**
**	Alloc mémoire
**	pour une scene
**
**	Ostyl of Mankind
**	Revision date: 26.2.03
**

	INCDIR	INCLUDES:
	INCLUDE	EXEC/MEMORY.i
	INCLUDE	POWERPC/MEMORYPPC.i
	INCLUDE	POWERPC/GRAPHICSPPC.i
	INCLUDE	MACROS/STARTUPWOS.i
	
	XDEF	AllocLWScne
	XDEF	FreeLWScne
	XREF	FreeLWObj
	XREF	FreeVec32
	XREF	_PowerPCBase
	XREF	Messg
	
AllocLWScne:
	Move.L	_PowerPCBase,a6
	Moveq	#lwsc_SIZEOF,d0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d1
	Jsr	_LVOAllocVec32(a6)
	Tst.L	d0
	Beq.B	Leave

	;---

	Move.L	_PowerPCBase,a6
	Move.L	d0,a5
	Move.L	#640,d0
	Move	d0,lwsc_Render+rndr_MaxSegSize(a5)
	Addq.L	#3,d0
	Mulu.L	#12,d0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d1
	Jsr	_LVOAllocVec32(a6)
	Tst.L	d0
	Beq.B	Leave

	Move.L	d0,a0
	Move	lwsc_Render+rndr_MaxSegSize(a5),d0
	Addq.L	#3,d0
	Lsl.L	#2,d0
	Move.L	a0,lwsc_Render+rndr_CoeffHB(a5)
	Lea	(a0,d0.L),a0
	Move.L	a0,lwsc_Render+rndr_CoeffHM(a5)
	Lea	(a0,d0.L),a0
	Move.L	a0,lwsc_Render+rndr_CoeffMB(a5)
	Lea	(a0,d0.L),a0
	Rts

	;----

;a1 = *struct lwscne

FreeLWScne
	Move.L	a1,-(sp)
	Move.L	lwsc_FirstLwo(a1),a1
	Jsr	FreeLWObj

	Move.L	(sp)+,a1
	Jsr	FreeVec32
	Rts

	;----

Leave:	Lea	Error(pc),a0
	Jsr	Messg
	Moveq	#0,d0
	Rts


Error	Dc.B	'No enough mem to alloc 3d scene',0
