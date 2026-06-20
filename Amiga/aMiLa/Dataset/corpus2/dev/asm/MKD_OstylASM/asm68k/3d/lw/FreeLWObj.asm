שתשתÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
	INCDIR	INCLUDES:
	INCLUDE	MISC/DEVPACMACROS.i
	INCLUDE	POWERPC/GRAPHICSPPC.i

	XDEF	FreeLWObj
	XREF	_PowerPCBase
	XREF	FreeTarga
	XREF	FreeVec32

FreeLWObj:
	Move.L	a1,d0
	Beq.W	Leave
	Move.L	d0,a4

	Move.L	lwo_StructLwSurf(a4),a5

	Move.L	lws_UVList(a5),a1
	Jsr	FreeVec32
 
	Move.L	lwo_Targa(a4),a1
	Jsr	FreeTarga

	Move.L	lwo_StructLwSurf(a4),a1
	Jsr	FreeVec32

	Move.L	lwo_VerticesFP(a4),a1
	Jsr	FreeVec32

	Lea	lwo_Transform(a4),a1
	Move.L	lwt_NewVertices(a1),a1
	Jsr	FreeVec32

	Lea	lwo_Transforms(a4),a5

	Move.L	nobj_3dVertices(a5),a1
	Jsr	FreeVec32
	
	Move.L	nobj_2dVertices(a5),a1
	Jsr	FreeVec32

	Move.L	nobj_SurfNormals(a5),a1
	Jsr	FreeVec32

	Move.L	nobj_SortList(a5),a1
	Jsr	FreeVec32

	Move.L	nobj_VertNormals(a5),a1
	Jsr	FreeVec32

	Move.L	nobj_MergeList(a5),a1
	Jsr	FreeVec32

	Move.L	nobj_PolyZMoyList(a5),a1
	Jsr	FreeVec32

	Move.L	a4,a1
	Jsr	FreeVec32

Leave	Rts
