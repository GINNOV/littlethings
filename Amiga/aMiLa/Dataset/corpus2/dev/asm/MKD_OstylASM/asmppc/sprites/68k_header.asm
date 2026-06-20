שתשתÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ;Sprites
;Revdate: 30.1.03
;Ostyl of Mankind!

	INCDIR	INCLUDES:
	INCLUDE	EXEC/LISTS.i
	INCLUDE	POWERPC/POWERPC.i
	INCLUDE	MACROS/POWERPC.i

	XREF	_LinkerDB
	XREF	_PowerPCBase
	XREF	Sprites15bPPC

	XDEF	ViewSpriteList
	XDEF	ViewSpriteListA
	XDEF	WaitPPCSprites

	XDEF	Sprites_PPStruct

	;----

;a0 = struct list (spritelist)
;a1 = struct chunkyscreen

ViewSpriteList:
	Moveq	#0,d1
	Bra.B	Init

ViewSpriteListA:
	Moveq	#PPF_ASYNC,d1

Init	Lea	Sprites_PPStruct(pc),a5	
	IFEMPTY	a0,Leave
	Move.L	d1,PP_FLAGS(a5)
	Move.L	_PowerPCBase,a6
	Lea	Sprites_PPStruct(pc),a5			
	Move.L	#Sprites15bPPC,PP_CODE(a5)
	Lea	PP_REGS(a5),a5
	Move.L	#_LinkerDB,r2(a5)
	Move.L	a6,r3(a5)	
	Move.L	LH_HEAD(a0),r4(a5)
	Move.L	a1,r5(a5)
	Lea	Sprites_PPStruct(pc),a0
	Jsr	_LVORunPPC(a6)
Leave	Rts

	;----

WaitPPCSprites:
	Move.L	_PowerPCBase,a6
	Lea	Sprites_PPStruct(pc),a0
	Jsr	_LVOWaitForPPC(a6)
	Rts

	;----

Sprites_PPStruct
	Ds.B	PP_SIZE
