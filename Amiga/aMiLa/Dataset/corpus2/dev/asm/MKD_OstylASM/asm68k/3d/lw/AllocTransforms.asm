ùúùúÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ**
**	Alloc mémoire
**	pour les transformations 3d
**
**	Ostyl of Mankind
**	Revision date: 13.2.03
**

	INCDIR	INCLUDES:
	INCLUDE	EXEC/MEMORY.i
	INCLUDE	POWERPC/MEMORYPPC.i
	INCLUDE	POWERPC/GRAPHICSPPC.i
	INCLUDE	MACROS/STARTUPWOS.i
	
	XDEF	AllocTransforms
	XREF	_PowerPCBase
	XREF	Messg

; a0 = struct.LwObj 	
; d0 = flags

AllocTransforms:
	Movem.L	d0-a6,-(sp)

	Move.L	a0,d1
	Beq.W	Leave
	Move.L	d1,a4
	
	Lea	lwo_Transforms(a4),a5
	Move	d0,nobj_Flags(a5)

	Move.L	_PowerPCBase,a6
	Moveq	#0,d2
	Move	lwo_TotalVertices(a4),d2
	Move.L	d2,d0	
	Mulu	#12,d0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d1
	Jsr	_LVOAllocVec32(a6)
	Move.L	d0,nobj_2dVertices(a5)
	Beq.W	Leave

	;----

	Move.L	_PowerPCBase,a6
	Move.L	d2,d0
	Mulu	#12,d0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d1
	Jsr	_LVOAllocVec32(a6)
	Move.L	d0,nobj_3dVertices(a5)
	Beq.W	Leave

	;----

	Move.L	_PowerPCBase,a6
	Moveq	#0,d0
	Move	lwo_TotalPolygons(a4),d0
	Mulu	#12,d0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d1
	Jsr	_LVOAllocVec32(a6)
	Move.L	d0,nobj_SurfNormals(a5)
	Beq.W	Leave

	;----

	Move.L	_PowerPCBase,a6
	Moveq	#0,d0
	Move	lwo_TotalPolygons(a4),d0
	Addq	#1,d0
	Lsl	d0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d1
	Jsr	_LVOAllocVec32(a6)
	Move.L	d0,nobj_SortList(a5)
	Beq.B	Leave

	;----

	Move.L	_PowerPCBase,a6
	Moveq	#0,d0
	Move	lwo_TotalVertices(a4),d0	
	Mulu	#12,d0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d1
	Jsr	_LVOAllocVec32(a6)
	Move.L	d0,nobj_VertNormals(a5)
	Beq.B	Leave

	Move.L	_PowerPCBase,a6
	Moveq	#0,d0
	Move	lwo_TotalVertices(a4),d0
	Move.L	d0,d1	
	Mulu	lwo_TotalPolygons(a4),d0
	Add.L	d1,d0
	Add.L	d0,d0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d1
	Jsr	_LVOAllocVec32(a6)
	Move.L	d0,nobj_MergeList(a5)
	Beq.B	Leave

	Move.L	_PowerPCBase,a6
	Moveq	#0,d0
	Move	lwo_TotalPolygons(a4),d0
	Lsl	#2,d0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d1
	Jsr	_LVOAllocVec32(a6)
	Move.L	d0,nobj_PolyZMoyList(a5)
	Beq.B	Leave
	
	;----

	Movem.L	(sp)+,d0-a6
	Move.L	a4,d0
	Rts
	
Leave	Lea	Error(pc),a0
	Jsr	Messg
	Movem.L	(sp)+,d0-a6
	Moveq	#0,d0
	Rts

	;---- Convert vertices to fixed point

	XDEF	MakeFixedPoint

;a0 = struct lwobj to fix

MakeFixedPoint:
	Movem.L	d0-a6,-(sp)
	Move.L	lwo_VerticesPTR(a0),a1
	Move.L	lwo_VerticesFP(a0),a2
	Move	lwo_TotalVertices(a0),d0
	Subq	#1,d0
	Bmi.B	Quit
	Move.L	#10000,d1
Loop:	FMove.S	(a1)+,fp0
	FMul.L	d1,fp0
	FMove.L	fp0,(a2)+
	FMove.S	(a1)+,fp0
	FMul.L	d1,fp0
	FMove.L	fp0,(a2)+
	FMove.S	(a1)+,fp0
	FMul.L	d1,fp0
	FMove.L	fp0,(a2)+
	Dbf	d0,Loop
Quit	Movem.L	(sp)+,d0-a6
	Rts

Error	Dc.B	'No enough mem for 3d allocations',0
