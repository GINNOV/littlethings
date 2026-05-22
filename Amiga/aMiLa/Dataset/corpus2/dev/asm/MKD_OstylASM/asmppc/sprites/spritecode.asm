שתשתÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ;Sprites
;Revdate: 29.1.03
;Ostyl of Mankind!

	INCDIR	INCLUDES:
	INCLUDE	EXEC/MEMORY.i
	INCLUDE	EXEC/LISTS.i
	INCLUDE	POWERPC/POWERPC.i
	INCLUDE	POWERPC/GRAPHICSPPC.i
	INCLUDE	MISC/DEVPACMACROS.i
	INCLUDE	MACROS/POWERPC.i

	XDEF	AddNewSprite
	XDEF	CreateNewSingleSprite
	XDEF	RemSprite
	XDEF	FreeAllSprites
	XDEF	FreeAllMaps
	XDEF	SetSprite
	XDEF	SetSpriteFrame
	XDEF	SetFrameList
	XDEF	LoadSpriteMap
	XDEF	ViewSpriteList
	XDEF	ViewSpriteListA
	XDEF	WaitPPCSprites
	XDEF	GetSpritePosition

	XREF	_PowerPCBase
	XREF	_LinkerDB
	XREF	LoadFile
	XREF	Sprites15bPPC

;-----------------------------------------------------------------
;
;	AddNewSprite()
;
;-----------------------------------------------------------------

;a0 = struct spritelist
;a1 = sprite name
;d2 = nframe
	
AddNewSprite:
	Move.L	a0,a5
	Move.L	a1,a4

	;---- Alloc la structure newsprite

	Move.L	_PowerPCBase,a6
	Moveq	#nsp_SIZEOF,d0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d1
	Jsr	_LVOAllocVec32(a6)
	Move.L	d0,a3
	Tst.L	a3
	Beq.B	Leave_NwSpr

	Move	d2,nsp_FrameAmount(a3)
	Beq.B	Leave_NwSpr

	Movea.L	4.w,a6
	Movea.L	a5,a0
	Movea.L	a3,a1
	Move.L	a4,LN_NAME(a1)
	Jsr	_LVOAddTail(a6)

	;---- Init la framelist

	Move.L	_PowerPCBase,a6
	Moveq	#0,d0
	Move	nsp_FrameAmount(a3),d0
	Mulu	#spf_SIZEOF,d0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d1
	Jsr	_LVOAllocVec32(a6)
	Move.L	d0,nsp_FrameList(a3)
	Beq.B	Leave_NwSpr

	Move.L	a3,d0
	Rts

Leave_NwSpr
	Moveq	#0,d0
	Rts

;-----------------------------------------------------------------
;
;	RemSprite()
;
;-----------------------------------------------------------------

;a0 = struct spritelist
;a1 = sprite name

RemSprite:
	Move.L	4.w,a6
	Jsr	_LVOFindName(a6)
	Tst.L	d0
	Beq.B	Leave_RemSpr

	Move.L	d0,-(sp)

	Move.L	4.w,a6
	Move.L	d0,a1
	Jsr	_LVORemove(a6)

	Move.L	_PowerPCBase,a6
	Move.L	(sp)+,a1
	Jsr	_LVOFreeVec32(a6)

Leave_RemSpr:
	Rts

;-----------------------------------------------------------------
;
;	FreeAllSprites()
;
;-----------------------------------------------------------------

;a0 = spritelist

FreeAllSprites:
	IFEMPTY	a0,EmptySprList
	Move.L	a0,a5

RemSprLoop
	Move.L	LH_HEAD(a5),a4

	Move.L	4.w,a6
	Move.L	a4,a1
	Jsr	_LVORemove(a6)

	Move.L	_PowerPCBase,a6
	Move.L	nsp_FrameList(a4),a1
	Tst.L	a1
	Beq.B	NoFrm
	Jsr	_LVOFreeVec32(a6)

NoFrm	Move.L	_PowerPCBase,a6
	Move.L	a4,a1
	Jsr	_LVOFreeVec32(a6)

	Move.L	LH_TAILPRED(a5),a0
	Cmpa.L	a0,a5
	Bne.B	RemSprLoop

EmptySprList
	Rts

;-----------------------------------------------------------------
;
;	FreeAllMaps()
;
;-----------------------------------------------------------------

;a0 = maplist

FreeAllMaps:
	IFEMPTY	a0,EmptyMapList
	Move.L	a0,a5

RemMapLoop
	Move.L	LH_HEAD(a5),a4

	Move.L	4.w,a6
	Move.L	a4,a1
	Jsr	_LVORemove(a6)

	Move.L	_PowerPCBase,a6
	Move.L	spm_TgaMapData(a4),a1
	Jsr	_LVOFreeVec32(a6)

	Move.L	_PowerPCBase,a6
	Move.L	a4,a1
	Jsr	_LVOFreeVec32(a6)

	Move.L	LH_TAILPRED(a5),a0
	Cmpa.L	a0,a5
	Bne.B	RemMapLoop

EmptyMapList
	Rts

;-----------------------------------------------------------------
;
;	SetSprite()
;
;-----------------------------------------------------------------

;a0 = struct spritelist
;a1 = name
;d1 = x_pos
;d2 = y_pos
;d3 = xscale|yscale
;d4 = rgb_lockup
;d5 = alpha
;d6 = frame#

SetSprite:	
	Movem.L	d1-d6,-(sp)
	Move.L	4.w,a6
	Jsr	_LVOFindName(a6)
	Move.L	d0,a0
	Movem.L	(sp)+,d1-d6

	;----
	
	Tst.L	a0
	Beq.B	Leave_SetSpr
	Movem	d1/d2/d4/d5,nsp_MidX(a0)
	Move.L	d3,nsp_XYScale(a0)

	;----

	Cmp	nsp_FrameAmount(a0),d6
	Ble.B	FrameOk
	Moveq	#0,d6
FrameOk	Move.B	d6,nsp_Frame(a0)
	Move.L	nsp_FrameList(a0),a1
	Mulu	#spf_SIZEOF,d6
	Lea	(a1,d6.W),a1

	;----

	Move	spf_uBeg(a1),d5
	Move	spf_uEnd(a1),d4
	Sub	d5,d4			;d4 = spritewidth
	Ext.L	d4
	Move	spf_vBeg(a1),d6
	Move	spf_vEnd(a1),d5
	Sub	d6,d5			;d5 = spriteheight
	Ext.L	d5

	Moveq	#0,d7
	Move	d3,d7			;d7 = y scale value
	Clr	d3		
	Swap	d3			;d3 = x scale value
	Muls	d3,d4
	Muls	d7,d5
	Asr.L	#8,d4			;d4 = ((spritewidth*k)/127)/2
	Asr.L	#8,d5			;d5 = ((spriteheight*k)/127)/2
	
	Move.L	d1,d6
	Move.L	d2,d7
	Sub.L	d4,d1
	Sub.L	d5,d2
	Add.L	d4,d6
	Add.L	d5,d7
	Move.L	d1,nsp_xBeg(a0)
	Move.L	d2,nsp_yBeg(a0)
	Move.L	d6,nsp_xEnd(a0)
	Move.L	d7,nsp_yEnd(a0)
	Moveq	#0,d0
	Rts

Leave_SetSpr
	Moveq	#-1,d0
	Rts

;-----------------------------------------------------------------
;
;	SetSpriteFrame()
;
;-----------------------------------------------------------------

;a0 = struct maplist
;a1 = map name
;a2 = struct spritelist
;a3 = sprite name
;d1 = frame#
;d2 = ubeg | vbeg
;d3 = uend | vend
;d4 = delay

SetSpriteFrame:
	Movem.L	d1-d4,-(sp)

	Move.L	4.w,a6
	Jsr	_LVOFindName(a6)
	Move.L	d0,a0

	Exg.L	a0,a2
	Move.L	a3,a1
	Move.L	4.w,a6
	Jsr	_LVOFindName(a6)
	Move.L	d0,a0

	Movem.L	(sp)+,d1-d4

	Tst.L	a2
	Beq.B	Leave_SetSprFrm
	Tst.L	a0
	Beq.B	Leave_SetSprFrm

	;----

	Move.L	nsp_FrameList(a0),a1
	Mulu	#spf_SIZEOF,d1
	Lea	(a1,d1.W),a1

	Move.L	a2,spf_Map(a1)
	
	;----

	Move	d2,spf_vBeg(a1)
	Move	d3,spf_vEnd(a1)
	Swap	d2
	Swap	d3
	Move	d2,spf_uBeg(a1)
	Move	d3,spf_uEnd(a1)
	
	Move.B	d4,spf_Delay(a1)
	Move.L	a0,d0
	Rts
	
Leave_SetSprFrm
	Moveq	#0,d0
	Rts

;-----------------------------------------------------------------
;
;	SetFrameList()
;
;-----------------------------------------------------------------

;a0 = struct spritelist
;a1 = sprite name
;a2 = struct maplist
;a3 = grablist
;d0 = frame#

SetFrameList:
	Move.L	d0,d7

	Move.L	4.w,a6
	Jsr	_LVOFindName(a6)
	Move.L	d0,a0
	Tst.L	a0
	Beq.B	Leave_SetSprLst

	Move.L	nsp_FrameList(a0),a4
	Move.L	a4,a5
	Cmp	nsp_FrameAmount(a0),d7
	Bgt.B	Leave_SetSprLst

	;----

	Subq	#1,d7
	Bmi.B	Leave_SetSprLst

GrabLoop:
	Move.L	4.w,a6
	Move.L	a2,a0
	Move.L	(a3)+,a1
	Jsr	_LVOFindName(a6)
	Move.L	d0,(a4)+
	Beq.B	Leave_SetSprLst
	Move.L	(a3)+,(a4)+
	Move.L	(a3)+,(a4)+
	Move	(a3)+,(a4)+
	Dbf	d7,GrabLoop

	Move.L	a5,d0
	Rts

Leave_SetSprLst
	Moveq	#0,d0
	Rts

;-----------------------------------------------------------------
;
;	GetSpritePosition()
;
;-----------------------------------------------------------------

;spritelist = a0
;spritename = a1

GetSpritePosition:
	IFEMPTY	a0,Leave_GetSpPos

	Move.L	4.w,a6
	Jsr	_LVOFindName(a6)
	Move.L	d0,a0
	Tst.L	a0
	Beq.B	Leave_GetSpPos

	Moveq	#0,d1
	Moveq	#0,d2
	Move	nsp_MidX(a0),d1
	Move	nsp_MidY(a0),d2
	Move.L	nsp_XYScale(a0),d3

Leave_GetSpPos
	Rts

;-----------------------------------------------------------------
;
;	CreateNewSingleSprite()
;
;-----------------------------------------------------------------

;a0 = *struct list (spritelist)
;a1 = *sprite name
;a2 = *struct list (maplist)
;a3 = *map name
;d0 = ubeg|vbeg
;d1 = uend|vend 

CreateNewSingleSprite
	Movem.L	a0-a3/d0/d1,-(sp)
	Moveq	#1,d2
	Jsr	AddNewSprite(pc)
	Movem.L	(sp)+,a0-a3/d2/d3
	Exg.L	a0,a2
	Exg.L	a1,a3
	Moveq	#0,d1
	Moveq	#0,d4
	Jsr	SetSpriteFrame(pc)
	Rts

;-----------------------------------------------------------------
;
;	ViewSpriteList()
;
;-----------------------------------------------------------------

;a0 = struct list (spritelist)
;a1 = struct chunkyscreen

ViewSpriteList:
	Moveq	#0,d1
	Bra.B	Init

ViewSpriteListA:
	Moveq	#PPF_ASYNC,d1

Init	IFEMPTY	a0,Leave_VwSpLst
	Move.L	_PowerPCBase,a6
	Lea	Sprites_PPStruct(pc),a5			
	Move.L	d1,PP_FLAGS(a5)
	Move.L	#Sprites15bPPC,PP_CODE(a5)

SetReg:	Lea	PP_REGS(a5),a5
	Move.L	#_LinkerDB,r2(a5)
	Move.L	a6,r3(a5)	
	Move.L	LH_HEAD(a0),r4(a5)
	Move.L	a1,r5(a5)
	Beq.B	Leave_VwSpLst

	Lea	Sprites_PPStruct(pc),a0
	Jsr	_LVORunPPC(a6)

Leave_VwSpLst
	Rts

	;----

WaitPPCSprites:
	Move.L	_PowerPCBase,a6
	Lea	Sprites_PPStruct(pc),a0
	Jsr	_LVOWaitForPPC(a6)
	Rts

	;----

	XDEF	Sprites_PPStruct

Sprites_PPStruct
	Ds.B	PP_SIZE
	EVEN

;-----------------------------------------------------------------
;
;	LoadSpriteMap()
;
;-----------------------------------------------------------------

;a0 = struct maplist
;a1 = targa filename
;d0 = flags

LoadSpriteMap:
	Move.L	a0,MapList
	Move.L	a1,Filename

	Move.L	4.w,a6
	Jsr	_LVOFindName(a6)
	Tst.L	d0
	Bne.W	MapExist

	Move.L	Filename(pc),a0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d0
	Jsr	LoadFile
	Move.L	d0,MapFile
	Beq.B	Leave_LoadMap

	Move.L	_PowerPCBase,a6
	Move.L	#spm_SIZEOF+(256*256*2),d0
	Move.L	#MEMF_FAST+MEMF_CLEAR,d1
	Jsr	_LVOAllocVec32(a6)
	Move.L	d0,SpMap
	Beq.B	Leave_LoadMap

	;----

	Move.L	4.w,a6
	Move.L	MapList(pc),a0
	Move.L	d0,a1
	Move.L	Filename,LN_NAME(a1)
	Jsr	_LVOAddTail(a6)

	;----

	Move.L	SpMap(pc),a0
	Move.L	MapFile(pc),a1
	Lea	spm_SIZEOF(a0),a2
	Move.L	a1,spm_TgaMapData(a0)
	Move.L	a2,spm_RawMapData(a0)

	Lea	18(a1),a1
	Move	#(256*256)-1,d1
	Move.L	#%11111000111110001111100000000000,d2

Loop2:	Move.L	(a1),d0		
	And.L	d2,d0
	Rol	#5,d0
	Swap	d0
	Rol	#5,d0
	Lsl.B	#3,d0
	Lsl	#3,d0
	Lsr.L	#6,d0
	Move	d0,(a2)+
	Lea	3(a1),a1
	Dbf	d1,Loop2

	Move.L	SpMap(pc),d0
MapExist
	Rts

Leave_LoadMap:
	Moveq	#0,d0
	Rts

Filename	Ds.L	1
MapList		Ds.L	1
SpMap		Ds.L	1
MapFile		Ds.L	1
