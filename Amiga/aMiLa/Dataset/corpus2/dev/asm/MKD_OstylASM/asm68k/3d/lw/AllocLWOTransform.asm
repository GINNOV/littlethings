שתשתÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
	INCDIR	INCLUDES:
	INCLUDE	EXEC/MEMORY.i
	INCLUDE	MISC/DEVPACMACROS.i
	INCLUDE	POWERPC/GRAPHICSPPC.i
		
	XDEF	AllocLWOTransform
	XREF	_PowerPCBase

	;----
	
; a0 = struct lwobj (object to mute)	
; a1 = struct lwobj (target object)

AllocLWOTransform:
	Movem.L	a0/a1,-(sp)
	Move.L	_PowerPCBase,a6
	Moveq	#0,d0
	Move	lwo_TotalVertices(a0),d0
	Mulu	#3*4,d0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d1
	Jsr	_LVOAllocVec32(a6)
	Movem.L	(sp)+,a0/a1

	;----

	Move	lwo_TotalVertices(a0),d1
	Cmp	lwo_TotalVertices(a1),d1
	Bne.B	Leave

	;----

	Lea	lwo_Transform(a0),a2
	Move.L	d0,lwt_NewVertices(a2)
	Beq.B	Leave	
	Move.L	lwo_VerticesFP(a0),lwt_SourceVertices(a2)	
	Move.L	lwo_VerticesFP(a1),lwt_TargetVertices(a2)
	Rts

Leave:	Moveq	#0,d0
	Rts
