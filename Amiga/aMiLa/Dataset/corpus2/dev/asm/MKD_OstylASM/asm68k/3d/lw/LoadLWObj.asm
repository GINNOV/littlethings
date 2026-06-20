ùúùúÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ;-----------------------------------------------------------------
;
;	LightWave file-object loader
;
;	Ostyl of Mankind
;	Revision date: 18.2.03
;
;	a0 = *objfilename 
;	a1 = *objtexmapname
;
;-----------------------------------------------------------------

	INCDIR	INCLUDES:
	INCLUDE	EXEC/MEMORY.i
	INCLUDE	EXEC/NODES.i
	INCLUDE	POWERPC/MEMORYPPC.i
	INCLUDE	POWERPC/GRAPHICSPPC.i
	INCLUDE	MACROS/STARTUPWOS.i
	
	XDEF	LoadLWObj

	XREF	_PowerPCBase
	XREF	LoadFile
	XREF	LoadTarga
	XREF	Messg
	XREF	MakeFixedPoint

	;----

LoadLWObj:
	Movem.L	d1-d6,-(sp)

	Move.L	a0,NamePTR
	Move.L	a1,TexPTR

	;---- Load lwo file into spacemem

	Move.L	#MEMF_FAST+MEMF_CLEAR,d0
	Jsr	LoadFile
	Move.L	d0,ObjPTR
	Beq.W	Leave
	Move.L	d1,ObjFileSize

	;---- Alloc lwobj structure

	Move.L	_PowerPCBase,a6
	Move.L	#lwo_SIZEOF,d0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d1
	Jsr	_LVOAllocVec32(a6)
	Move.L	d0,a5
	Tst.L	d0
	Beq.W	Leave

	;---- Load une texture targa

	Move.L	TexPTR(pc),d0
	Beq.B	DontLoadTexOb
	
	Move.L	d0,a0
	Sub.L	a1,a1
	Moveq	#LTGA_CONVERTCHK15,d1
	Jsr	LoadTarga
	Move.L	d0,lwo_Targa(a5)
	Beq.W	Leave

DontLoadTexOb:

	;---- Quantifie les vertices

	Move.L	ObjPTR(pc),a0
	Move.L	#"PNTS",d0
	Jsr	Search(pc)
	Move.L	a0,lwo_VerticesPTR(a5)
	Beq.W	Leave
	Divu.L	#12,d0
	Move	d0,lwo_TotalVertices(a5)

	;---- Quantifie les polygones

	Move.L	ObjPTR(pc),a0
	Move.L	#"POLS",d0
	Jsr	Search(pc)
	Move.L	a0,lwo_PolygonsPTR(a5)
	Beq.W	Leave
	Divu.L	#10,d0
	Move	d0,lwo_TotalPolygons(a5)

	;---- Quantifie les surfaces
	
	Move.L	ObjPTR(pc),a0
	Move.L	#"SRFS",d0
	Jsr	Search(pc)
	Tst.L	a0
	Beq.W	Leave
	Subq	#1,d0

CntSrf:	Tst.B	(a0)+
	Bne.B	NxtCnt
	Addq	#1,lwo_TotalSurfaces(a5)
	Tst.B	(a0)
	Bne.B	NxtCnt
	Lea	1(a0),a0
	Subq	#1,d0
NxtCnt:	Dbf	d0,CntSrf

	;---- Init FixedPoint

	Move.L	_PowerPCBase,a6
	Moveq	#0,d0
	Move	lwo_TotalVertices(a5),d0
	Mulu	#12,d0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d1
	Jsr	_LVOAllocVec32(a6)
	Move.L	d0,lwo_VerticesFP(a5)
	Beq.W	Leave

	Move.L	a5,a0
	Jsr	MakeFixedPoint

	;---- Init node 

	Lea	lwo_Node(a5),a2
	Move.B	#NT_GRAPHICS,LN_TYPE(a2)
	Move.L	NamePTR(pc),LN_NAME(a2)

;-----------------------------------------------------------
;
;	Création des structure surfaces
;
;-----------------------------------------------------------

	;---- Alloc les structures surface

	Move.L	_PowerPCBase,a6
	Moveq	#lws_SIZEOF,d0
	Move	lwo_TotalSurfaces(a5),d1
	Mulu	d1,d0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d1
	Jsr	_LVOAllocVec32(a6)
	Move.L	d0,lwo_StructLwSurf(a5)
	Beq.W	Leave

	;---- Alloc les UVList

	Move.L	_PowerPCBase,a6
	Moveq	#0,d0
	Move	lwo_TotalVertices(a5),d0
	Mulu	lwo_TotalSurfaces(a5),d0
	Lsl.L	#2,d0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d1
	Jsr	_LVOAllocVec32(a6)
	Move.L	d0,UVPTR

	;---- Init les structures surface

	Move.L	ObjPTR(pc),a0
	Move.L	UVPTR(pc),a2
	Move.L	lwo_StructLwSurf(a5),a4
	Move	lwo_TotalSurfaces(a5),d3
	Move	lwo_TotalVertices(a5),d2
	Subq	#1,d3

MakeSurfLoop:
	Move.L	#"SURF",d0
	Jsr	Search(pc)
	Move.L	a0,d0
	Beq.B	Leave
	Move.L	d0,LN_NAME(a4)
	Move.L	a0,a1

	Move.L	#"TFLG",d0
	Jsr	SearchQuiet(pc)
	Tst.L	a0
	Beq.B	Next
	Move	-2(a0),lws_Flags(a4)

	Move.L	a1,a0
	Move.L	#"TSIZ",d0
	Jsr	Search(pc)
	Tst.L	a0
	Beq.B	Leave
	Lea	-2(a0),a0
	Move.L	(a0)+,lws_XTxSize(a4)
	Move.L	(a0)+,lws_YTxSize(a4)
	Move.L	(a0),lws_ZTxSize(a4)

	Move.L	a1,a0
	Move.L	#"TCTR",d0
	Jsr	SearchQuiet(pc)
	Tst.L	a0
	Beq.B	Next
	Lea	-2(a0),a0
	Move.L	(a0)+,lws_XTxCenter(a4)
	Move.L	(a0)+,lws_YTxCenter(a4)
	Move.L	(a0),lws_ZTxCenter(a4)	

Next	Move.L	a1,a0
	Move.L	a2,lws_UVList(a4)
	Lea	(a2,d2.W*4),a2
	Lea	lws_SIZEOF(a4),a4
	Dbf	d3,MakeSurfLoop

	;----	

	Move.L	a5,d0
	Movem.L	(sp)+,d1-d6
	Rts

Leave	Moveq	#0,d0
	Movem.L	(sp)+,d1-d6
	Rts	

	;----

;d0 = chunk to search for
;a0 = area to search in

Search:	Move.L	ObjFileSize(pc),d1
	Subq	#1,d1
SearchLoop
	Cmp.L	(a0),d0	
	Lea	1(a0),a0
	Dbeq	d1,SearchLoop
	Tst	d1
	Bpl.B	Found
	Lea	ErrMss(pc),a0
	Jsr	Messg
	Suba.L	a0,a0
	Moveq	#0,d0
	Rts
Found	Lea	3(a0),a0
	Move.L	(a0),d0
	Lea	4(a0),a0
	Rts	

SearchQuiet:	
	Move.L	ObjFileSize(pc),d1
	Subq	#1,d1
SearchLoop1
	Cmp.L	(a0),d0	
	Lea	1(a0),a0
	Dbeq	d1,SearchLoop1
	Tst	d1
	Bpl.B	Found1
	Suba.L	a0,a0
	Moveq	#0,d0
	Rts
Found1	Lea	3(a0),a0
	Move.L	(a0),d0
	Lea	4(a0),a0
	Rts

	;----

ObjFileSize	Ds.L	1
NamePTR		Ds.L	1
TexPTR		Ds.L	1
ObjPTR		Ds.L	1
UVPTR		Ds.L	1

ErrMss	Dc.B	'Invalid LW-object',0
