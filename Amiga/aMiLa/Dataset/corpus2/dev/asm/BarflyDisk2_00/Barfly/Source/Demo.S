;-----------------------------------------------------------------------------
; FUNCTION:	NONE
;
; INPUT:	NONE
;
; OUTPUT:	NONE
;
; REQUIREMENT:
;	- V2.x : Because 1.x is a pain
;	- 020+ : Because I wanted too
;
; NOTE:	- There was no point to make this code resident, so the program
;	  variables are in the XDATA to save us from an Allocmem.
;	- Because the code require a bit of CPU power there was no point
;	  to take the time to make it 68000 compatible.
;	- I removed the 3.x WB support, cause I was not happy with it.
;	- On my basic 3.1 A3000 blitting the image to the window take ~50%
;	  of the machine time, the C2P ~20%.Think what you want of this fact.
;	- All drawing routines are custom but use bltbitmap to display
;	  the result in a window.(With a prior c2p pass is needed)
;
;-----------------------------------------------------------------------------
;	ADDSYM
	MC68020
	OUTPUT	T:DEMO
	BOPT	x+,O+,wo-	;,OG+

;--------------------------------------
	INCDIR	"includes:"
	INCLUDE "exec/execbase.i"
	INCLUDE "exec/memory.i"
	INCLUDE	"intuition/intuition.i"
	INCLUDE	"all_lvo.i"			;File auto created with LK FDINCLUDE option

;-----------------------------------------------------------------------------
GSTRING	MACRO					;This macro should be SECTION based
	bsr.b	\@
	db	"\1",0
	EVEN
\@	movea.l	(sp)+,\2
	ENDM

TRUE	= 1
FALSE	= 0

	RSRESET					;Program Variable
DEMO_Stack		RS.L	1
DEMO_EBase		RS.L	1
DEMO_DBase		RS.L	1
DEMO_IBase		RS.L	1
DEMO_GBase		RS.L	1
DEMO_Error		RS.L	1
DEMO_Screen		RS.L	1
DEMO_WindowXPos		RS.W	1
DEMO_WindowYPos		RS.W	1
DEMO_PolyWindow		RS.L	1
DEMO_BoxWindow		RS.L	1
DEMO_PixelWindow	RS.L	1
DEMO_FireWindow		RS.L	1
DEMO_RingWindow		RS.L	1
DEMO_WeirdWindow	RS.L	1
DEMO_ZoomWindow		RS.L	1
DEMO_DiscWindow		RS.L	1
DEMO_RND		RS.L	1
DEMO_WBVP		RS.L	1
DEMO_ColorMap		RS.L	1
DEMO_HScroll		RS.L	1
DEMO_HSize		RS.W	1
DEMO_VSize		RS.W	1
DEMO_MouseX		RS.W	1
DEMO_MouseY		RS.W	1
DEMO_Dist		RS.L	1
DEMO_Chunky1		RS.L	1
DEMO_Chunky2		RS.L	1
DEMO_SinTable		RS.L	1
DEMO_Pens		RS.B	16
DEMO_AvailPens		RS.B	16
DEMO_BitMap		RS.B	bm_SIZEOF
DEMO_Maping		RS.B	256
DEMO_Points		RS.W	32*3*2
DEMO_SIZEOF		RS.L	0

;	SECTION	DEMOCode,CODE			;Read ONLY

;--------------------------------------
DEMO_Startup
	lea	(DEMO_BSS,pc),a4
	ml	a7,(DEMO_Stack,a4)

	bsr	DEMO_AllocLib
	beq	DEMO_Exit

	mw	(DEMO_EBase,a4,),a0
	mw	(AttnFlags,a0),d0
	btst	#AFB_68020,d0
	beq	DEMO_Exit

DEMO_Main
	GSTRING	<Demo Screen>,a0
	bsr	DEMO_AllocScreen
	ml	d0,(DEMO_Screen,a4)
	beq	DEMO_Quit
	movea.l	d0,a0
	mq	#0,d0
	mb	(sc_BarHeight,a0),d0
	add.b	(sc_BarVBorder,a0),d0
	mw	d0,(DEMO_WindowYPos,a4)

	GSTRING	<Fire>,a0
	bsr	DEMO_AllocWindow
	ml	d0,(DEMO_FireWindow,a4)
	beq	DEMO_Quit

	GSTRING	<Zoom>,a0
	bsr	DEMO_AllocWindow
	ml	d0,(DEMO_ZoomWindow,a4)
	beq	DEMO_Quit

	GSTRING	<Poly>,a0
	bsr	DEMO_AllocWindow
	ml	d0,(DEMO_PolyWindow,a4)
	beq	DEMO_Quit

	GSTRING	<Box>,a0
	bsr	DEMO_AllocWindow
	ml	d0,(DEMO_BoxWindow,a4)
	beq	DEMO_Quit

	GSTRING	<Pixel>,a0
	bsr	DEMO_AllocWindow
	ml	d0,(DEMO_PixelWindow,a4)
	beq	DEMO_Quit

	GSTRING	<Disc>,a0
	bsr	DEMO_AllocWindow
	ml	d0,(DEMO_DiscWindow,a4)
	beq	DEMO_Quit

	GSTRING	<Weird>,a0
	bsr	DEMO_AllocWindow
	ml	d0,(DEMO_WeirdWindow,a4)
	beq	DEMO_Quit

	GSTRING	<Ring>,a0
	bsr	DEMO_AllocWindow
	ml	d0,(DEMO_RingWindow,a4)
	beq	DEMO_Quit

	movea.l	(DEMO_Screen,a4),a0
	movea.l	(DEMO_IBase,a4),a6
	jsr	(_LVOScreenToFront,a6)		;Show screen with all window opened

.Loop	pea	.Loop(pc)
	mq	#0,D0
	lea	(DEMO_FireWindow,a4),a0
	bsr	.SetBit
	lea	(DEMO_WeirdWindow,a4),a0
	bsr	.SetBit
	lea	(DEMO_PolyWindow,a4),a0
	bsr	.SetBit
	lea	(DEMO_BoxWindow,a4),a0
	bsr	.SetBit
	lea	(DEMO_PixelWindow,a4),a0
	bsr	.SetBit
	lea	(DEMO_DiscWindow,a4),a0
	bsr	.SetBit
	lea	(DEMO_ZoomWindow,a4),a0
	bsr	.SetBit
	lea	(DEMO_RingWindow,a4),a0
	bsr	.SetBit
	beq	DEMO_Quit
	movea.l	(DEMO_EBase,a4),a6
	jsr	(_LVOWait,a6)			;Wait on any window left opened

	ml	#IDCMP_ACTIVEWINDOW,d2

	lea	(DEMO_RingWindow,a4),a0
	bsr	DEMO_GetWindowInput
	cmp.l	d2,d0
	beq	DEMO_Ring

	lea	(DEMO_FireWindow,a4),a0
	bsr	DEMO_GetWindowInput
	cmp.l	d2,d0
	beq	DEMO_Fire

	lea	(DEMO_WeirdWindow,a4),a0
	bsr	DEMO_GetWindowInput
	cmp.l	d2,d0
	beq	DEMO_Weird

	lea	(DEMO_ZoomWindow,a4),a0
	bsr	DEMO_GetWindowInput
	cmp.l	d2,d0
	beq	DEMO_Zoom
 
	lea	(DEMO_PolyWindow,a4),a0
	bsr	DEMO_GetWindowInput
	cmp.l	d2,d0
	beq	DEMO_Poly

	lea	(DEMO_BoxWindow,a4),a0
	bsr	DEMO_GetWindowInput
	cmp.l	d2,d0
	beq	DEMO_Box

	lea	(DEMO_PixelWindow,a4),a0
	bsr	DEMO_GetWindowInput
	cmp.l	d2,d0
	beq	DEMO_Pixel

	lea	(DEMO_DiscWindow,a4),a0
	bsr	DEMO_GetWindowInput
	cmp.l	d2,d0
	beq	DEMO_Disc
 
	rts

.SetBit	ml	(a0),d1
	beq.b	.TstBit
	movea.l	d1,a0
	mb	([wd_UserPort,a0],MP_SIGBIT),d1
	bset	d1,d0
.TstBit	tst.l	d0
	rts

DEMO_Quit
	ml	(DEMO_Screen,a4),d0
	beq.b	DEMO_Exit
	movea.l	d0,a0
	movea.l	(DEMO_IBase,a4),a6
	jsr	(_LVOScreenToBack,a6)
	bsr	DEMO_FreeBuffer
	lea	(DEMO_FireWindow,a4),a0
	bsr	DEMO_FreeWindow
	lea	(DEMO_RingWindow,a4),a0
	bsr	DEMO_FreeWindow
	lea	(DEMO_ZoomWindow,a4),a0
	bsr	DEMO_FreeWindow
	lea	(DEMO_WeirdWindow,a4),a0
	bsr	DEMO_FreeWindow
	lea	(DEMO_PolyWindow,a4),a0
	bsr	DEMO_FreeWindow
	lea	(DEMO_BoxWindow,a4),a0
	bsr	DEMO_FreeWindow
	lea	(DEMO_PixelWindow,a4),a0
	bsr	DEMO_FreeWindow
	lea	(DEMO_DiscWindow,a4),a0
	bsr	DEMO_FreeWindow
	bsr	DEMO_FreeScreen
DEMO_Exit
	bsr	DEMO_FreeLib
	ml	(DEMO_Stack,a4),a7
	ml	(DEMO_Error,a4),d0
	rts

;--------------------------------------
DEMO_AllocLib
	ml	($4).w,(DEMO_EBase,a4)
	movea.l	(DEMO_EBase,a4),a6
	lea	(DName,pc),a1
	mq	#0,d0
	jsr	(_LVOOpenLibrary,a6)
	ml	d0,(DEMO_DBase,a4)
	beq.b	.Fail
	lea	(IName,pc),a1
	mq	#37,d0
	jsr	(_LVOOpenLibrary,a6)
	ml	d0,(DEMO_IBase,a4)
	beq.b	.Fail
	lea	(GName,pc),a1
	mq	#37,d0
	jsr	(_LVOOpenLibrary,a6)
	ml	d0,(DEMO_GBase,a4)
	beq.b	.Fail
.Exit	mq	#TRUE,d0
	rts
.Fail	mq	#FALSE,d0
	rts

DEMO_FreeLib
	lea	(DEMO_IBase,a4),a0
	bsr.b	.Close
	lea	(DEMO_GBase,a4),a0
	bsr.b	.Close
	lea	(DEMO_DBase,a4),a0
.Close	ml	(a0),d0
	beq.b	.Rts
	clr.l	(a0)
	movea.l	d0,a1
	movea.l	(DEMO_EBase,a4),a6
	jmp	(_LVOCloseLibrary,a6)
.Rts	rts

IName		DC.B	"intuition.library",0
GName		DC.B	"graphics.library",0
DName		DC.B	"dos.library",0
	EVEN

;--------------------------------------
DEMO_AllocScreen
	ml	a7,d2
	ml	#-1,-(sp)
	ml	a7,d3
	ml	#TAG_END,-(sp)
	ml	#5,-(sp)
	ml	#SA_Depth,-(sp)
	ml	a0,-(sp)
	ml	#SA_Title,-(sp)
	ml	#CUSTOMSCREEN,-(sp)
	ml	#SA_Type,-(sp)
	ml	#TRUE,-(sp)
	ml	#SA_Behind,-(sp)
	ml	d3,-(sp)
	ml	#SA_Pens,-(sp)
	suba.l	a0,a0
	movea.l	a7,a1
	movea.l	(DEMO_IBase,a4),a6
	jsr	(_LVOOpenScreenTagList,a6)
	ml	d2,a7
	rts

DEMO_FreeScreen
	lea	(DEMO_Screen,a4),a0
.Close	ml	(a0),d0
	beq	.Rts
	clr.l	(a0)
	movea.l	d0,a0
	movea.l	(DEMO_IBase,a4),a6
	jmp	(_LVOCloseScreen,a6)
.Rts	rts

;--------------------------------------
DEMO_AllocWindow
	ml	a7,d2
	mq	#0,d0
	ml	#TAG_END,-(sp)
	mw	(DEMO_WindowYPos,a4),d0
	ml	d0,-(sp)
	ml	#WA_Top,-(sp)
	mw	(DEMO_WindowXPos,a4),d0
	ml	d0,-(sp)
	ml	#WA_Left,-(sp)
	ml	#256,-(sp)
	ml	#WA_MaxWidth,-(sp)
	ml	#200,-(sp)
	ml	#WA_MaxHeight,-(sp)
	ml	#32,-(sp)
	ml	#WA_InnerWidth,-(sp)
	ml	#32,-(sp)
	ml	#WA_InnerHeight,-(sp)
	ml	#IDCMP_CLOSEWINDOW!IDCMP_NEWSIZE!IDCMP_ACTIVEWINDOW!IDCMP_INACTIVEWINDOW,-(sp)
	ml	#WA_IDCMP,-(sp)
	ml	#WFLG_SIZEGADGET!WFLG_CLOSEGADGET!WFLG_DRAGBAR!WFLG_DEPTHGADGET,-(sp)
	ml	#WA_Flags,-(sp)
	ml	a0,-(sp)
	ml	#WA_Title,-(sp)
	ml	(DEMO_Screen,a4),-(sp)
	ml	#WA_CustomScreen,-(sp)
	suba.l	a0,a0
	movea.l	a7,a1
	movea.l	(DEMO_IBase,a4),a6
	jsr	(_LVOOpenWindowTagList,a6)
	ml	d2,a7
	tst.l	d0
	beq.b	.Rts
	movea.l	d0,a0
	mw	(wd_Width,a0),d1
	add.w	d1,(DEMO_WindowXPos,a4)
	cmpi.w	#256,(DEMO_WindowXPos,a4)
	ble.b	.Rts
	clr.w	(DEMO_WindowXPos,a4)
	mw	(wd_TopEdge,a0),d1
	add.w	(wd_Height,a0),d1
	mw	d1,(DEMO_WindowYPos,a4)
.Rts	rts

DEMO_FreeWindow
.Close	ml	(a0),d0
	beq	.Rts
	clr.l	(a0)
	movea.l	d0,a0
	movea.l	(DEMO_IBase,a4),a6
	jmp	(_LVOCloseWindow,a6)
.Rts	rts

;--------------------------------------
DEMO_GetWindowInput
	ml	(a0),d0
	beq.b	.Rts
	movea.l	d0,a0
	movem.l	d2-d3,-(a7)
	movea.l	(DEMO_EBase,a4),a6
	movea.l	(wd_UserPort,a0),a0
	mq	#0,d2
	jsr	(_LVOGetMsg,a6)
	tst.l	d0
	beq.b	.Done
	movea.l	d0,a1
	ml	(im_Class,a1),d2
	mw	(im_Code,a1),d3
	jsr	(_LVOReplyMsg,a6)
.Done	ml	d2,d0
	mw	d3,d1
.Exit	movem.l	(a7)+,d2-d3
.Rts	rts

;--------------------------------------
DEMO_AllocBuffer
	mw	(DEMO_HSize,a4),d0
	lsr.w	#3,d0
	mw	d0,(DEMO_BitMap+bm_BytesPerRow,a4)
	mw	(DEMO_VSize,a4),(DEMO_BitMap+bm_Rows,a4)
	mb	#4,(DEMO_BitMap+bm_Depth,a4)
	lea	(DEMO_BitMap+bm_Planes,a4),a2
	mq	#4-1,d2
	movea.l	(DEMO_GBase,a4),a6
..	mw	(DEMO_HSize,a4),d0
	mw	(DEMO_VSize,a4),d1
	jsr	(_LVOAllocRaster,a6)
	ml	d0,(a2)+
	beq.b	.Fail
	dbra	d2,..

	mw	(DEMO_HSize,a4),d0
	mulu.w	(DEMO_VSize,a4),d0
	ml	#MEMF_CLEAR,d1
	movea.l	(DEMO_EBase,a4),a6
	jsr	(_LVOAllocMem,a6)
	ml	d0,(DEMO_Chunky1,a4)
	beq.b	.Fail

	mw	(DEMO_HSize,a4),d0
	mulu.w	(DEMO_VSize,a4),d0
	ml	#0,d1
	jsr	(_LVOAllocMem,a6)
	ml	d0,(DEMO_Chunky2,a4)
	beq.b	.Fail

	mq	#TRUE,d0
	rts
.Fail	mq	#FALSE,d0
	rts

.AllocBitMap
	movea.l	(DEMO_GBase,a4),a6
	rts

DEMO_FreeBuffer
	lea	(DEMO_BitMap+bm_Planes,a4),a2
	movea.l	(DEMO_GBase,a4),a6
	mq	#4-1,d2
..	ml	(a2)+,d0
	beq.b	0$
	clr.l	-4(a2)
	movea.l	d0,a0
	mw	(DEMO_HSize,a4),d0
	mw	(DEMO_VSize,a4),d1
	jsr	(_LVOFreeRaster,a6)
0$	dbra	d2,..
	mw	(DEMO_HSize,a4),d0
	mulu.w	(DEMO_VSize,a4),d0
	lea	(DEMO_Chunky1,a4),a0
	bsr.b	.Free
	mw	(DEMO_HSize,a4),d0
	mulu.w	(DEMO_VSize,a4),d0
	lea	(DEMO_Chunky2,a4),a0
.Free	ml	(a0),d1
	beq.b	.Rts
	clr.l	(a0)
	movea.l	d1,a1
	movea.l	(DEMO_EBase,a4),a6
	jmp	(_LVOFreeMem,a6)
.Rts	rts

;--------------------------------------
DEMO_LoadColor
	adda.w	#16*2,a1
	mq	#8-1,d0
..	ml	-(a1),-(a7)
	dbra	d0,..
	ml	(DEMO_Screen,a4),a0
	lea	(sc_ViewPort,a0),a0
	movea.l	(vp_ColorMap,a0),a1
	lea	([cm_ColorTable,a1],16*2),a1
	mq	#8-1,d0
..	ml	-(a1),-(a7)
	dbra	d0,..
	movea.l	a7,a1
	mq	#32,d0
	movea.l	(DEMO_GBase,a4),a6
	jsr	(_LVOLoadRGB4,a6)
	adda.w	#32*2,a7
	rts

;------------------------------------------------------------------------------
DEMO_Poly
	lea	(PolyColors,pc),a1
	bsr	DEMO_LoadColor

	movea.l	(DEMO_PolyWindow,a4),a0
	bsr	DEMO_Resize

	ml	#$87654321,(DEMO_RND,a4)

.Loop	bsr.b	.Poly

	movea.l	(DEMO_PolyWindow,a4),a0
	bsr	DEMO_Display
	lea	(DEMO_PolyWindow,a4),a0
	bsr	DEMO_HandleWindow
	bne.b	.Loop
	rts

.Poly	ml	(DEMO_RND,a4),d0
	mq	#0,d1
	lea	(DEMO_Points,a4),a0
	mq	#0,d2
	mq	#0,d3
	mw	(DEMO_HSize,a4),d2
	mw	(DEMO_VSize,a4),d3
	mw	#32*3-1,d4
..	add.l	d1,d0
	mq	#0,d5
	swap	d0
	add.l	d0,d1
	mw	d0,d5
	mq	#0,d6
	divu.w	d2,d5
	mw	d1,d6
	divu.w	d3,d6
	swap	d6
	mw	d6,d5
	ml	d5,(a0)+
	dbra	d4,..
	ml	d0,(DEMO_RND,a4)

	lea	(DEMO_Points,a4),a2
	lea	(DEMO_DrawTriangleDraw,pc),a5
	bsr.b	.Draw
	lea	(DEMO_DrawTriangleErase,pc),a5
.Draw	mq	#16-1,d3
..	movem.l	(a2)+,d0-d2
	movem.l	d3/a2/a4-a5,-(sp)
	and.w	#%11,d3
	lea	(DEMO_BitMap,a4),a1
	movea.l	(bm_Planes,a1,d3.w*4),a0
	bsr	DEMO_DrawTriangle
	movem.l	(sp)+,d3/a2/a4-a5
	dbra	d3,..
	rts

;------------------------------------------------------------------------------
DEMO_Box
	lea	(BoxColors,pc),a1
	bsr	DEMO_LoadColor

	movea.l	(DEMO_BoxWindow,a4),a0
	bsr	DEMO_Resize

	ml	#$1,(DEMO_RND,a4)

.Loop	bsr.b	.Box

	movea.l	(DEMO_BoxWindow,a4),a0
	bsr	DEMO_Display
	lea	(DEMO_BoxWindow,a4),a0
	bsr	DEMO_HandleWindow
	bne.b	.Loop
	rts

.Box	ml	(DEMO_RND,a4),d0
	mq	#0,d1
	lea	(DEMO_Points,a4),a0
	mq	#0,d2
	mq	#0,d3
	mw	(DEMO_HSize,a4),d2
	mw	(DEMO_VSize,a4),d3
	mq	#32-1,d4
..	add.l	d1,d0
	swap	d0
	add.l	d0,d1
	mq	#0,d5
	mw	d0,d5
	divu.w	d2,d5
	mq	#0,d7
	mw	d1,d7
	divu.w	d3,d7
	swap	d7
	mw	d7,d5
	add.l	d1,d0
	swap	d0
	add.l	d0,d1
	mq	#0,d6
	mw	d0,d6
	divu.w	d2,d6
	mq	#0,d7
	mw	d1,d7
	divu.w	d3,d7
	swap	d7
	mw	d7,d6
	cmp.l	d5,d6
	bge.b	0$
	exg.l	d5,d6
0$	cmp.w	d5,d6
	bge.b	1$
	eor.w	d5,d6
	eor.w	d6,d5
	eor.w	d5,d6
1$	ml	d5,(a0)+
	ml	d6,(a0)+
	dbra	d4,..
	ml	d0,(DEMO_RND,a4)

	lea	(DEMO_Points,a4),a2
	lea	(DEMO_DrawBox,pc),a5
	bsr.b	.Draw
	lea	(DEMO_EraseBox,pc),a5
.Draw	mq	#16-1,d4
..	movem.w	(a2)+,d0-d3
	movem.l	d4/a2/a4-a5,-(sp)
	and.w	#%11,d4
	lea	(DEMO_BitMap,a4),a1
	movea.l	(bm_Planes,a1,d4.w*4),a0
	jsr	(a5)
	movem.l	(sp)+,d4/a2/a4-a5
	dbra	d4,..
	rts

;------------------------------------------------------------------------------
DEMO_Pixel
	lea	(PixelColors,pc),a1
	bsr	DEMO_LoadColor

	movea.l	(DEMO_PixelWindow,a4),a0
	bsr	DEMO_Resize

	ml	#$87654321,(DEMO_RND,a4)

.Loop	bsr.b	.Pixel

	movea.l	(DEMO_PixelWindow,a4),a0
	bsr	DEMO_Display
	lea	(DEMO_PixelWindow,a4),a0
	bsr	DEMO_HandleWindow
	bne.b	.Loop
	rts

.Pixel	ml	(DEMO_RND,a4),d0
	mq	#0,d1
	mq	#0,d5
	mw	(DEMO_HSize,a4),d2
	mulu.w	(DEMO_VSize,a4),d2
	movem.l	(DEMO_BitMap+bm_Planes,a4),a0-a3
	mw	#512-1,d4
..	add.l	d1,d0
	swap	d0
	add.l	d0,d1
	mw	d0,d5
	divu.w	d2,d5
	sub.w	d5,d5
	swap	d5
	mq	#%11,d3
	and.w	d4,d3
	bfchg	(a0){d5:1}
	mw	d1,d5
	divu.w	d2,d5
	sub.w	d5,d5
	swap	d5
	bfchg	(a1){d5:1}
	add.l	d1,d0
	swap	d0
	add.l	d0,d1
	mw	d0,d5
	divu.w	d2,d5
	sub.w	d5,d5
	swap	d5
	mq	#%11,d3
	and.w	d4,d3
	bfchg	(a2){d5:1}
	mw	d1,d5
	divu.w	d2,d5
	sub.w	d5,d5
	swap	d5
	bfchg	(a3){d5:1}
	dbra	d4,..

	ml	d0,(DEMO_RND,a4)
	rts

;------------------------------------------------------------------------------
DEMO_Disc
	lea	(DiscColors,pc),a1
	bsr	DEMO_LoadColor

	movea.l	(DEMO_DiscWindow,a4),a0
	bsr	DEMO_Resize

	ml	#$87654321,(DEMO_RND,a4)

.Loop	bsr.b	.Disc

	movea.l	(DEMO_DiscWindow,a4),a0
	bsr	DEMO_Display
	lea	(DEMO_DiscWindow,a4),a0
	bsr	DEMO_HandleWindow
	bne.b	.Loop
	rts

.Disc	ml	(DEMO_RND,a4),d0
	mq	#0,d1
	lea	(DEMO_Points,a4),a0
	mq	#0,d2
	mq	#0,d3
	mw	(DEMO_HSize,a4),d2
	mw	(DEMO_VSize,a4),d3
	subq.w	#1,d2
	subq.w	#1,d3
	mw	#32-1,d4
..	add.l	d1,d0
	swap	d0
	add.l	d0,d1
	mq	#0,d5
	mw	d0,d5
	divu.w	d2,d5
	swap	d5
	mw	d5,(a0)+
	mq	#0,d6
	mw	d1,d6
	divu.w	d3,d6
	swap	d6
	mw	d6,(a0)+

	add.l	d1,d0
	swap	d0
	add.l	d0,d1
	mq	#0,d7
	mw	d0,d7
	divu.w	d3,d7
	swap	d7
	cmp.w	d7,d5
	bgt.b	0$
	mw	d5,d7
0$	add.w	d7,d5
	cmp.w	d5,d2
	bgt.b	1$
	sub.w	d7,d5
	mw	d2,d7
	sub.w	d5,d7
1$	cmp.w	d7,d6
	bgt.b	2$
	mw	d6,d7
2$	add.w	d7,d6
	cmp.w	d6,d3
	bgt.b	3$
	sub.w	d7,d6
	mw	d3,d7
	sub.w	d6,d7
3$	mw	d7,(a0)+

	dbra	d4,..
	ml	d0,(DEMO_RND,a4)

	lea	(DEMO_Points,a4),a2
	lea	(DEMO_DrawDisc,pc),a3
	bsr.b	.Draw
	lea	(DEMO_EraseDisc,pc),a3
.Draw	mq	#16-1,d3
..	mw	(a2)+,d0
	mw	(a2)+,d1
	mw	(a2)+,d2
	beq.b	.Next2
	movem.l	d3/a2-a4,-(sp)
	and.w	#%11,d3
	lea	(DEMO_BitMap,a4),a1
	movea.l	(bm_Planes,a1,d3.w*4),a0
	mw	(bm_BytesPerRow,a1),d3
	jsr	(a3)
	movem.l	(sp)+,d3/a2-a4
.Next2	dbra	d3,..
	rts

;------------------------------------------------------------------------------
DEMO_Ring
	lea	(RingColors,pc),a1
	bsr	DEMO_LoadColor

	movea.l	(DEMO_RingWindow,a4),a0
	bsr	DEMO_Resize

	bsr	DEMO_Map2

.Loop	movea.l	(DEMO_RingWindow,a4),a0
	mw	(wd_MouseX,a0),(DEMO_MouseX,a4)
	mw	(wd_MouseY,a0),(DEMO_MouseY,a4)
	bsr.b	.Ring

	movea.l	(DEMO_RingWindow,a4),a0
	bsr	DEMO_DisplayChunky
	lea	(DEMO_RingWindow,a4),a0
	bsr	DEMO_HandleWindow
	bne.b	.Loop
	rts

.Ring	movea.l	(DEMO_Chunky2,a4),a1
	lea	(DEMO_Maping,a4),a0
	mw	(DEMO_VSize,a4),d1
	subq.w	#1,d1
	mw	(DEMO_MouseY,a4),d3
	lsl.w	#3,d3
	mq	#0,d4
	mq	#0,d2
.YLoop	mw	(DEMO_HSize,a4),d0
	subq.w	#1,d0
	mw	d4,d5
	mw	(DEMO_MouseX,a4),d7
	lsl.w	#3,d7
.XLoop	add.w	d7,d5
	subq.w	#8,d7
	mw	d5,d2
	lsr.w	#8,d2
	mb	(a0,d2.w),(a1)+
	dbra	d0,.XLoop
	add.w	d3,d4
	subq.w	#8,d3
	dbra	d1,.YLoop
	rts

;------------------------------------------------------------------------------
DEMO_Zoom
	lea	(ZoomColors,pc),a1
	bsr	DEMO_LoadColor

	movea.l	(DEMO_ZoomWindow,a4),a0
	bsr	DEMO_Resize

	bsr	DEMO_Map2

.Loop	movea.l	(DEMO_ZoomWindow,a4),a0
	mw	(wd_MouseX,a0),(DEMO_MouseX,a4)
	mw	(wd_MouseY,a0),(DEMO_MouseY,a4)
	bsr.b	.Zoom

	movea.l	(DEMO_ZoomWindow,a4),a0
	bsr	DEMO_DisplayChunky
	lea	(DEMO_ZoomWindow,a4),a0
	bsr	DEMO_HandleWindow
	bne.b	.Loop
	rts

.Zoom	movea.l	(DEMO_Chunky2,a4),a0
	lea	(DEMO_Maping,a4),a1
	add.l	(DEMO_Dist,a4),a2
	add.l	#$1000,(DEMO_Dist,a4)
	mq	#0,d0
	mq	#0,d3
	mq	#0,d4
	mw	(DEMO_VSize,a4),d1
	subq.w	#1,d1
.YLoop	mw	(DEMO_HSize,a4),d0
	subq.w	#1,d0
	ml	d4,d5
	mq	#0,d7
.XLoop	add.l	d7,d5
	add.l	a2,d7
	ml	d5,d2
	sub.w	d2,d2
	rol.l	#8,d2
	mb	(a1,d2.w),(a0)+
	dbra	d0,.XLoop
	add.l	d3,d4
	add.l	a2,d3
	dbra	d1,.YLoop
	rts

;------------------------------------------------------------------------------
DEMO_Weird
	lea	(WeirdColors,pc),a1
	bsr	DEMO_LoadColor

	movea.l	(DEMO_WeirdWindow,a4),a0
	bsr	DEMO_Resize

	bsr	DEMO_Map2

.Loop	movea.l	(DEMO_WeirdWindow,a4),a0
	mw	(wd_MouseX,a0),(DEMO_MouseX,a4)
	mw	(wd_MouseY,a0),(DEMO_MouseY,a4)
	bsr.b	.Weird

	movea.l	(DEMO_WeirdWindow,a4),a0
	bsr	DEMO_DisplayChunky
	lea	(DEMO_WeirdWindow,a4),a0
	bsr	DEMO_HandleWindow
	bne.b	.Loop
	rts

.Weird	movea.l	(DEMO_Chunky2,a4),a0
	lea	(DEMO_Maping,a4),a1
	ml	#$10000,(DEMO_HScroll,a4)
	mq	#0,d0
	mq	#0,d1
	mq	#0,d2
	mq	#0,d3
	mw	(DEMO_MouseY,a4),d0
	mw	(DEMO_VSize,a4),d2
	subq.w	#1,d2
	ml	d0,d4
.YLoop	swap	d4
	add.l	(DEMO_HScroll,a4),d4
	swap	d4
	ml	d2,d0
	mw	(DEMO_HSize,a4),d1
	subq.w	#1,d1
	lsl.l	#8,d2
.XLoop	mw	d0,d6
	and.w	d2,d6
	lsr.w	#4,d6
	and.w	#$f0,d6
	add.w	d4,d0
	sub.w	d1,d0
	mb	(a1,d6.w),(a0)+
	dbra	d1,.XLoop
	lsr.l	#8,d2
	dbra	d2,.YLoop
	rts

;------------------------------------------------------------------------------
DEMO_Fire
	lea	(FireColors,pc),a1
	bsr	DEMO_LoadColor

	movea.l	(DEMO_FireWindow,a4),a0
	bsr	DEMO_Resize

	bsr	DEMO_Map1

	ml	#$f0f0f0f0,(DEMO_RND,a4)

.Loop	bsr.b	.Fire

	movea.l	(DEMO_FireWindow,a4),a0
	bsr	DEMO_DisplayChunky
	lea	(DEMO_FireWindow,a4),a0
	bsr	DEMO_HandleWindow
	bne.b	.Loop
.Rts	rts

.Fire	mw	(DEMO_VSize,a4),d0
	subq.w	#2,d0
	mulu.w	(DEMO_HSize,a4),d0
	lea	([DEMO_Chunky1,a4],d0.l),a0
	mw	(DEMO_HSize,a4),d2
	lsr.w	#2,d2
	subq.w	#1,d2
	ml	(DEMO_RND,a4),d0
	mq	#0,d1
..	add.l	d1,d0
	swap	d0
	add.l	d0,d1
	ml	d0,(a0)+
	dbra	d2,..
	ml	d0,(DEMO_RND,a4)

	mw	(DEMO_HSize,a4),d0
	lea	([DEMO_Chunky1,a4],d0.w),a0
	lea	(a0,d0.w),a1
	lea	(DEMO_Maping,a4),a2
	movea.l	(DEMO_Chunky2,a4),a3
	mw	(DEMO_VSize,a4),d3
	subq.w	#3,d3
	mq	#3,d4
	mq	#0,d0
	mb	(a2),d5
.YLoop	mw	(DEMO_HSize,a4),d2
	subq.w	#1,d2
.XLoop	mb	(a1)+,d0
	add.b	(a0),d0
	roxr.b	#1,d0
	sub.b	d4,d0
	bcs.b	0$
	mb	d0,(a0)+
	mb	(a2,d0.w),(a3)+
	dbra	d2,.XLoop
	dbra	d3,.YLoop
	rts
0$	mb	d4,(a0)+
	mb	d5,(a3)+
	dbra	d2,.XLoop
	dbra	d3,.YLoop
	rts

;------------------------------------------------------------------------------
DEMO_Map1
	lea	(DEMO_Maping+256,a4),a0
	mw	#(256)-1,d0
..	mb	d0,d1
	and.b	#$f0,d1
	mb	d1,-(a0)
	dbra	d0,..
	rts

DEMO_Map2
	lea	(DEMO_Maping+256,a4),a0
	mw	#(256/2)-1,d0
	mq	#0,d1
..	mb	d1,d2
	and.b	#$f0,d2
	mb	d2,-(a0)
	addq.b	#2,d1
	dbra	d0,..
	mw	#(256/2)-1,d0
..	subq.b	#2,d1
	mb	d1,d2
	and.b	#$f0,d2
	mb	d2,-(a0)
	dbra	d0,..
	rts

;------------------------------------------------------------------------------
DEMO_HandleWindow
	pea	(a0)
	movea.l	(DEMO_GBase,a4),a6
	jsr	(_LVOWaitTOF,a6)
.Next	movea.l	(sp),a0
	bsr	DEMO_GetWindowInput
	movea.l	(sp),a0
	cmp.l	#IDCMP_INACTIVEWINDOW,d0
	beq.b	.Fail
	cmp.l	#IDCMP_NEWSIZE,d0
	bne.b	.Close
	movea.l	(a0),a0
	bsr	DEMO_Resize
	bra	.True
.Close	cmp.l	#IDCMP_CLOSEWINDOW,d0
	bne	.True
	bsr	DEMO_FreeWindow
.Fail	movea.l	(sp)+,a0
	mq	#FALSE,d0
	rts
.True	movea.l	(sp)+,a0
	mq	#TRUE,d0
	rts

;------------------------------------------------------------------------------
DEMO_Resize
	pea	(a0)
	bsr	DEMO_FreeBuffer
	movea.l	(sp)+,a0
	mb	(wd_BorderLeft,a0),d0
	add.b	(wd_BorderRight,a0),d0
	ext.w	d0
	neg.w	d0
	add.w	(wd_Width,a0),d0
	add.w	#31,d0
	and.w	#-32,d0
	mw	d0,(DEMO_HSize,a4)
	mb	(wd_BorderTop,a0),d0
	add.b	(wd_BorderBottom,a0),d0
	ext.w	d0
	neg.w	d0
	add.w	(wd_Height,a0),d0
	mw	d0,(DEMO_VSize,a4)
	pea	(a0)
	bsr	DEMO_AllocBuffer
	movea.l	(sp)+,a0
	beq	DEMO_Quit

	mq	#0,d0
	mq	#0,d1
	mq	#0,d2
	mq	#0,d3
	mb	(wd_BorderLeft,a0),d0
	mb	(wd_BorderTop,a0),d1
	mb	(wd_BorderRight,a0),d2
	mb	(wd_BorderBottom,a0),d3
	not.w	d2
	not.w	d3
	add.w	(wd_Width,a0),d2
	add.w	(wd_Height,a0),d3
	movea.l	(wd_RPort,a0),a1
	mb	(rp_Mask,a1),d4
	mb	#%10000,(rp_Mask,a1)
	movea.l	(DEMO_GBase,a4),a6
	movem.l	d4/a1,-(sp)
	jsr	(_LVORectFill,a6)
	movem.l	(sp)+,d4/a1
	mb	d4,(rp_Mask,a1)
	rts

;------------------------------------------------------------------------------
DEMO_DisplayChunky
	movem.l	a0/a4,-(sp)
	movea.l	(DEMO_Chunky2,a4),a0
	mw	(DEMO_HSize,a4),d0
	mulu.w	(DEMO_VSize,a4),d0
	lea	(a0,d0.l),a5
	movem.l	(DEMO_BitMap+bm_Planes,a4),a1-a4
	bsr	C8TOP4
	movem.l	(sp)+,a0/a4

DEMO_Display
	mq	#0,d0
	mq	#0,d1
	mq	#0,d2
	mq	#0,d3
	mb	(wd_BorderLeft,a0),d2
	mb	(wd_BorderTop,a0),d3
	ml	d2,d4
	mq	#0,d5
	add.b	(wd_BorderRight,a0),d4
	neg.w	d4
	add.w	(wd_Width,a0),d4
	mw	(DEMO_VSize,a4),d5
	mw	#$c0,d6
	movea.l	(wd_RPort,a0),a1
	lea	(DEMO_BitMap,a4),a0
	movea.l	(DEMO_GBase,a4),a6
	jmp	(_LVOBltBitMapRastPort,a6)

;------------------------------------------------------------------------------
; INPUT:	A0.l = Source chunky buffer START
;		A1.l = Pointer to Planes0
;		A2.l = Pointer to Planes1
;		A3.l = Pointer to Planes2
;		A4.l = Pointer to Planes3
;		a5.l = Source chunky buffer END
;
; OUTPUT:	A0.l = Pointer to chunky buffer + 32*4
;		A1.l = Pointer to Planes0 + 4
;		A2.l = Pointer to Planes1 + 4
;		A3.l = Pointer to Planes2 + 4
;		A4.l = Pointer to Planes3 + 4
;
C8TOP4
..	ml	(a0)+,d4
	ml	(a0)+,d0
	lsr.l	#4,d0
	add.l	d0,d4
	ml	(a0)+,d5
	ml	(a0)+,d0
	lsr.l	#4,d0
	add.l	d0,d5
	ml	(a0)+,d6
	ml	(a0)+,d0
	lsr.l	#4,d0
	add.l	d0,d6
	ml	(a0)+,d7
	ml	(a0)+,d0
	lsr.l	#4,d0
	add.l	d0,d7
	ml	d4,d0
	ml	d5,d1
	swap	d0
	swap	d1
	mw	d6,d0
	mw	d7,d1
	swap	d6
	swap	d7
	mw	d6,d4
	mw	d7,d5
	ml	#$00FF00FF,d7
	ml	d7,d6
	ml	d7,d2
	ml	d7,d3
	and.l	d0,d7
	and.l	d1,d2
	and.l	d4,d6
	and.l	d5,d3
	sub.l	d7,d0
	sub.l	d2,d1
	sub.l	d6,d4
	sub.l	d3,d5
	lsl.l	#8,d7
	lsr.l	#8,d1
	lsl.l	#8,d6
	lsr.l	#8,d5
	add.l	d2,d7
	add.l	d1,d0
	add.l	d3,d6
	add.l	d5,d4
	ml	#$CCCCCCCC,d5
	ml	d5,d1
	ml	d5,d2
	ml	d5,d3
	and.l	d4,d5
	and.l	d0,d1
	and.l	d6,d2
	and.l	d7,d3
	sub.l	d5,d4
	sub.l	d1,d0
	sub.l	d2,d6
	sub.l	d3,d7
	lsl.l	#2,d4
	lsr.l	#2,d1
	lsl.l	#2,d6
	lsr.l	#2,d3
	add.l	d0,d4
	add.l	d1,d5
	add.l	d7,d6
	add.l	d3,d2
	ml	#$AAAAAAAA,d1
	ml	d1,d3
	ml	d1,d0
	ml	d1,d7
	and.l	d5,d1
	and.l	d2,d3
	sub.l	d1,d5
	sub.l	d3,d2
	lsr.l	#1,d3
	add.l	d1,d3
	ml	d3,(a4)+
	add.l	d5,d5
	add.l	d2,d5
	and.l	d4,d0
	sub.l	d0,d4
	ml	d5,(a3)+
	and.l	d6,d7
	sub.l	d7,d6
	lsr.l	#1,d7
	add.l	d7,d0
	ml	d0,(a2)+
	add.l	d4,d4
	add.l	d4,d6
	ml	d6,(a1)+
	cmp.l	a0,a5
	bne.b	..
	rts

;------------------------------------------------------------------------------
; FUNCTION:	Draw a 1 bitplane triangle
;
; INPUT:	D0.l = TP Top 2d Point? (x/y)
;		D1.l = MP Middle 2d Point? (x/y)
;		D2.l = BP Bottom 2d Point? (x/y)
;		A0.l = Destination bitplane
;		A1.l = bm_ Bitmap
;
DEMO_DrawTriangle:
	cmp.w	d0,d1
	bgt.b	0$
	beq	.Single1			;Special case: Only 2 slope /\ or \/
	exg	d0,d1
0$	cmp.w	d1,d2
	bgt.b	.Double
	beq	.Single2			;Special case: Only 2 slope /\
	exg	d1,d2
1$	cmp.w	d0,d1
	bgt.b	.Double
	beq	.Single3			;Special case: Only 2 slope \/
	exg	d0,d1
.Double	ml	d0,d5				;d0.l = TP, d1.l = MP, d2.l = BP <\ or />
	clr.w	d5				;TPX
	ml	d1,d7
	clr.w	d7				;MPX
	ml	d2,d6
	clr.w	d6				;BPX
	ml	d5,d3
	sub.l	d6,d3
	mw	d0,d4
	sub.w	d2,d4
	ext.l	d4
	divs.l	d4,d3				;D3.l = Slope TP-BP
	ml	d7,d4
	sub.l	d6,d4
	mw	d1,d6
	sub.w	d2,d6
	ext.l	d6
	divs.l	d6,d4				;D4.l = Slope MP-BP
	movea.l	d4,a4
	ml	d5,d4
	sub.l	d7,d4
	mw	d0,d7				;d7.l = YPos
	sub.w	d1,d0
	ext.l	d0
	divs.l	d0,d4				;D4.l = Slope TP-MP
	swap	d6
	mw	d0,d6
	ml	d6,d0
	not.l	d0				;d0.l:0.l:= (BYSize-1):(TYSize-1)
	mulu.w	(bm_BytesPerRow,a1),d7
	adda.l	d7,a0
	movea.w	(bm_BytesPerRow,a1),a1
	clr.w	d1
	mq	#32,d2
	ml	d3,-(sp)
	movea.l	d5,a6				; X2Pos
	cmp.l	d3,d4
	bge.b	.D
	exg	d3,d4
	movea.l	d4,a2
	jsr	(a5)
	ml	d1,d5				;New X1	(Middle point)
	swap	d0
	ml	a4,d3
	movea.l	(sp)+,a2
	jmp	(a5)
.D	movea.l	d4,a2
	jsr	(a5)
	movea.l	d1,a6				;New X2	(Middle point)
	swap	d0
	ml	(sp)+,d3
	movea.l	a4,a2
	jmp	(a5)

.Single3
	ml	d0,d5				;d0.l = TP, d1.l = MP, d2.l = BP
	clr.w	d5				;d5.l = X1Pos
	ml	d5,d3
	ml	d2,d6
	clr.w	d6
	sub.l	d6,d3
	mw	d0,d7				;d7.l = YPos
	sub.w	d2,d0
	ext.l	d0
	divs.l	d0,d3				;D3.l = Slope TP-BP
	ml	d1,d0
	clr.w	d0
	movea.l	d0,a6				;d7.l = X2Pos
	sub.l	d6,d0
	sub.w	d2,d1
	ext.l	d1
	divs.l	d1,d0
	movea.l	d0,a2				;A2.l = Slope MP-BP
	not.w	d1
	mw	d1,d0
	mulu.w	(bm_BytesPerRow,a1),d7
	adda.l	d7,a0
	movea.w	(bm_BytesPerRow,a1),a1
	cmpa.l	d5,a6
	bge.b	.S3
	exg	d5,a6
	exg	d3,a2
.S3	mq	#32,d2
	jmp	(a5)
.Exit	rts

.Single1					;d0=d1
	cmp.w	d0,d2
	bgt.b	.Single3
	beq.b	.Exit
	exg	d0,d2
.Single2
	ml	d0,d5				;d0.l = TP, d1.l = MP, d2.l = BP
	clr.w	d5				;d5.l = X1Pos
	ml	d5,d3
	ml	d2,d6
	clr.w	d6
	sub.l	d6,d3
	mw	d0,d7
	sub.w	d2,d7
	ext.l	d7
	divs.l	d7,d3				;D3.l = Slope TP-BP
	ml	d1,d7
	clr.w	d7
	ml	d5,d4
	sub.l	d7,d4
	mw	d0,d7				;d7.l = YPos
	sub.w	d2,d0
	ext.l	d0
	divs.l	d0,d4				;D4.l = Slope TP-MP
	movea.l	d5,a6				;d7.l = X2Pos
	not.w	d0
	mulu.w	(bm_BytesPerRow,a1),d7
	adda.l	d7,a0
	movea.w	(bm_BytesPerRow,a1),a1
	cmp.l	d3,d4
	bge.b	.S1
	exg	d3,d4
.S1	movea.l	d4,a2
	mq	#32,d2
	jmp	(a5)

DEMO_DrawTriangleDraw
.Loop	ml	d5,d6
	ml	a6,d7
	clr.w	d6
	swap	d6
	swap	d7
	sub.w	d6,d7
	ble.b	32$
	sub.w	d2,d7
	bgt.b	.Full
	bfset	(a0){d6:d7}
32$	add.l	d3,d5
	adda.l	a2,a6
	adda.l	a1,a0
	dbra	d0,.Loop
	rts
.Full	mq	#%11111,d4			;Get The 32 multiple
	and.w	d6,d4
	neg.w	d4
	bfset	(a0){d6:d4}			;Left mask
	lsr.w	#5,d6
	lea	(4.b,a0,d6.w*4),a3		;Start pos in plane
	add.w	d2,d4
	sub.w	d4,d7				;Sub to lengh what we just wrote
	blt.b	.Right
	mq	#-1,d6
..	ml	d6,(a3)+			;Middle
	sub.w	d2,d7
	bge.b	..
	add.w	d2,d7
	beq.b	32$
.Right	bfset	(a3){0:d7}
	add.l	d3,d5
	adda.l	a2,a6
	adda.l	a1,a0
	dbra	d0,.Loop
	rts

DEMO_DrawTriangleErase
.Loop	ml	d5,d6
	ml	a6,d7
	clr.w	d6
	swap	d6
	swap	d7
	sub.w	d6,d7
	ble.b	32$
	sub.w	d2,d7
	bgt.b	.Full
	bfclr	(a0){d6:d7}
32$	add.l	d3,d5
	adda.l	a2,a6
	adda.l	a1,a0
	dbra	d0,.Loop
	rts
.Full	mq	#%11111,d4			;Get The 32 multiple
	and.w	d6,d4
	neg.w	d4
	bfclr	(a0){d6:d4}			;Left mask
	lsr.w	#5,d6
	lea	(4.b,a0,d6.w*4),a3		;Start pos in plane
	add.w	d2,d4
	sub.w	d4,d7				;Sub to lengh what we just wrote
	blt.b	.Right
	mq	#0,d6
..	ml	d6,(a3)+			;Middle
	sub.w	d2,d7
	bge.b	..
	add.w	d2,d7
	beq.b	32$
.Right	bfclr	(a3){0:d7}
	add.l	d3,d5
	adda.l	a2,a6
	adda.l	a1,a0
	dbra	d0,.Loop
	rts

;------------------------------------------------------------------------------
; FUNCTION:	
;
; INPUT:	D0.w = XPos
;		D1.w = YPos
;		D2.w = Radius
;		D3.w = XSize
;
; OUTPUT:	NONE
;
DEMO_DrawDisc:
	movea.w	d3,a5
	ext.l	d2
	mq	#1,d5
	sub.l	d2,d5				;d=1-radius
	movea.l	#3,a6				;DeltaE=3
	mq	#-2,d7
	muls.w	d2,d7
	addq.l	#5,d7				;DeltaSE=-2*radius+5
	movea.l	d7,a4
	mw	d2,d4
	mulu.w	d3,d1
	mulu.w	d3,d4
	mw	d0,d3
	swap	d0
	mw	d3,d0
	swap	d0	
	mw	d1,d3				;D1 = YPos
	swap	d3
	mw	d1,d3				;D3 = YPos/YPos
	swap	d1
	mw	d3,d1				;D1 = YPos/YPos
	sub.w	d4,d1
	add.w	d4,d3
	swap	d1
	swap	d3
	sub.w	d2,d0
	add.w	d2,d2
	suba.l	a2,a2
.Loop						;d0,d1=XYPos,d2/d3=Radius,D4=Color,d5=D
	bsr.b	.HLine
	sub.w	a5,d1
	add.w	a5,d3
	cmp.w	a2,d2
	ble.b	.Done
	addq.l	#2,a2
	tst.l	d5
	bpl.b	.SE
.E	add.l	a6,d5				;d=d+deltaE
	addq.l	#2,a6				;DeltaE=DeltaE+2
	addq.l	#2,a4				;DeltaSE=DeltaSE+2
	sub.l	#$10000,d0			;XPos
	add.l	#$20000,d2			;XSize
	bra.b	.Loop
.Done	rts

.SE	add.l	a4,d5				;d=d+deltaSE
	addq.l	#2,a6				;DeltaE=DeltaE+2
	addq.l	#4,a4				;DeltaSE=DeltaSE+4
	addq.w	#1,d0				;XPos
	subq.w	#2,d2				;XSize
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	bsr.b	.HLine
	add.w	a5,d1
	sub.w	a5,d3
	subq.w	#1,d0				;XPos
	addq.w	#2,d2				;XSize
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	bra.b	.Loop

.HLine	ml	d0,-(sp)
	ml	d2,-(sp)
	add.w	d0,d2
	lea	(a0,d1.w),a1
	lea	(a0,d3.w),a3
	mq	#%11111,d6			;Get The 32 multiple
	and.w	d0,d6				;Mask Left
	sub.w	d6,d0				;XSize minus Left Mask
	mq	#%11111,d7			;Get The 32 multiple
	and.w	d2,d7				;Mask Right
	sub.w	d7,d2				;XSize minus Left Mask
	sub.w	d0,d2				;Get Copysize
	ble.b	.Quick				;(Interchange on triangle type demand)
.Full	lsr.w	#3,d0				;X1Pos in Byte Multyple of byte
	adda.w	d0,a1
	adda.w	d0,a3
	mq	#32,d0
	sub.w	d6,d0
	bfset	(a1){d6:d0}
	addq.l	#4,a1
	lsr.w	#5,d2				;XSize in Byte Multyple of 32 pix
	bfset	(a3){d6:d0}
	addq.l	#4,a3
	subq.w	#2,d2
	bmi.b	.Right
	mq	#-1,d0
..9	ml	d0,(a1)+			;Middle
	ml	d0,(a3)+			;Middle
	dbra	d2,..9
.Right	mq	#0,d0
	mq	#0,d6
.Quick	sub.w	d6,d7
	beq.b	32$
	lsr.w	#3,d0				;X1Pos in Byte Multyple of byte
	bfset	(a1,d0.w){d6:d7}
	bfset	(a3,d0.w){d6:d7}
32$	ml	(sp)+,d2
	ml	(sp)+,d0
	rts


;------------------------------------------------------------------------------
; FUNCTION:	
;
; INPUT:	D0.w = XPos
;		D1.w = YPos
;		D2.w = Radius
;		D3.w = XSize
;
; OUTPUT:	NONE
;
DEMO_EraseDisc:
	movea.w	d3,a5

	ext.l	d2
	mq	#1,d5
	sub.l	d2,d5				;d=1-radius
	movea.l	#3,a6				;DeltaE=3
	mq	#-2,d7
	muls.w	d2,d7
	addq.l	#5,d7				;DeltaSE=-2*radius+5

	movea.l	d7,a4
	mw	d2,d4
	mulu.w	d3,d1
	mulu.w	d3,d4

	mw	d0,d3
	swap	d0
	mw	d3,d0
	swap	d0	

	mw	d1,d3				;D1 = YPos
	swap	d3
	mw	d1,d3				;D3 = YPos/YPos
	swap	d1
	mw	d3,d1				;D1 = YPos/YPos
	sub.w	d4,d1
	add.w	d4,d3
	swap	d1
	swap	d3
	sub.w	d2,d0
	add.w	d2,d2
	suba.l	a2,a2
.Loop						;d0,d1=XYPos,d2/d3=Radius,D4=Color,d5=D
	bsr.b	.HLine
	sub.w	a5,d1
	add.w	a5,d3

	cmp.w	a2,d2
	ble.b	.Done
	addq.l	#2,a2

	tst.l	d5
	bpl.b	.SE
.E	add.l	a6,d5				;d=d+deltaE
	addq.l	#2,a6				;DeltaE=DeltaE+2
	addq.l	#2,a4				;DeltaSE=DeltaSE+2
	sub.l	#$10000,d0			;XPos
	add.l	#$20000,d2			;XSize
	bra.b	.Loop
.Done	rts

.SE	add.l	a4,d5				;d=d+deltaSE
	addq.l	#2,a6				;DeltaE=DeltaE+2
	addq.l	#4,a4				;DeltaSE=DeltaSE+4
	addq.w	#1,d0				;XPos
	subq.w	#2,d2				;XSize
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	bsr.b	.HLine
	add.w	a5,d1
	sub.w	a5,d3
	subq.w	#1,d0				;XPos
	addq.w	#2,d2				;XSize
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	bra.b	.Loop

.HLine	ml	d0,-(sp)
	ml	d2,-(sp)
	add.w	d0,d2
	lea	(a0,d1.w),a1
	lea	(a0,d3.w),a3
	mq	#%11111,d6			;Get The 32 multiple
	and.w	d0,d6				;Mask Left
	sub.w	d6,d0				;XSize minus Left Mask
	mq	#%11111,d7			;Get The 32 multiple
	and.w	d2,d7				;Mask Right
	sub.w	d7,d2				;XSize minus Left Mask
	sub.w	d0,d2				;Get Copysize
	ble.b	.Quick				;(Interchange on triangle type demand)
.Full	lsr.w	#3,d0				;X1Pos in Byte Multyple of byte
	adda.w	d0,a1
	adda.w	d0,a3
	mq	#32,d0
	sub.w	d6,d0
	bfclr	(a1){d6:d0}
	addq.l	#4,a1
	lsr.w	#5,d2				;XSize in Byte Multyple of 32 pix
	bfclr	(a3){d6:d0}
	addq.l	#4,a3
	subq.w	#2,d2
	bmi.b	.Right
	mq	#0,d0
..9	ml	d0,(a1)+			;Middle
	ml	d0,(a3)+			;Middle
	dbra	d2,..9
.Right	mq	#0,d0
	mq	#0,d6
.Quick	sub.w	d6,d7
	beq.b	32$
	lsr.w	#3,d0				;X1Pos in Byte Multyple of byte
	bfclr	(a1,d0.w){d6:d7}
	bfclr	(a3,d0.w){d6:d7}
32$	ml	(sp)+,d2
	ml	(sp)+,d0
	rts

;------------------------------------------------------------------------------
; INPUT:	a1 = rp_Bitmap
;		d0 = XPos
;		d1 = YPos
;		d2 = XSize
;		d3 = YSize
;
DEMO_DrawBox
	sub.w	d1,d3
	subq.w	#1,d3				;Could test for zero size...
	bmi.b	.Exit
	add.w	d0,d2				;Create x2

	lea	BMask(pc),a6

	mq	#%11111,d5
	and.w	d0,d5				;Mask Left
	sub.w	d5,d0
	lsr.w	#3,d0				;XPos in Byte Multyple of 32 pixels
	mq	#%11111,d6
	and.w	d2,d6				;Mask Right
	sub.w	d6,d2				;XSize minus Left Mask
	lsr.w	#3,d2

	mw	(bm_BytesPerRow,a1),d4
	mulu.w	d4,d1
	ext.l	d0
	add.l	d0,d1
	adda.l	d1,a0

	sub.w	d0,d2				;Width of middle copy
	bne.b	.Full				;Not Quick
	ml	(a6,d6.w*4),d1
	not.l	d1
	and.l	(a6,d5.w*4),d1
	movea.l	d4,a5
..	or.l	d1,(a0)
	adda.w	a5,a0
	dbra	d3,..
.Exit	rts
.Full	exg	d4,a5
	lsr.w	#2,d2
	ml	(a6,d5.w*4),d1
	bmi.b	0$
	movem.l	d3/a0,-(a7)
..	or.l	d1,(a0)
	adda.w	a5,a0
	dbra	d3,..
	movem.l	(a7)+,d3/a0
	subq.w	#1,d2
	addq.l	#4,a0
0$
	subq.w	#1,d2
	bmi.b	1$
	mw	d2,d5
	addq.l	#1,d5
	lsl.w	#2,d5
	movem.l	d3/d5/a0/a5,-(a7)
	suba.w	d5,a5
	mq	#-1,d1
.Loop	mw	d2,d5
..	ml	d1,(a0)+
	dbra	d5,..
	adda.w	a5,a0
	dbra	d3,.Loop

	movem.l	(a7)+,d3/d5/a0/a5
	adda.w	d5,a0
1$	ml	(a6,d6.w*4),d1
	bmi.b	2$
	not.l	d1
..	or.l	d1,(a0)
	adda.w	a5,a0
	dbra	d3,..
2$	rts

;------------------------------------------------------------------------------
; INPUT:	a1 = rp_Bitmap
;		d0 = X1
;		d1 = Y1
;		d2 = X2
;		d3 = Y2
;
DEMO_EraseBox
	sub.w	d1,d3
	subq.w	#1,d3				;Could test for zero size...
	bmi.b	.Exit

	lea	BMask(pc),a6

	mq	#%11111,d5
	and.w	d0,d5				;Mask Left
	sub.w	d5,d0
	lsr.w	#3,d0				;XPos in Byte Multyple of 32 pixels
	mq	#%11111,d6
	and.w	d2,d6				;Mask Right
	sub.w	d6,d2				;XSize minus Left Mask
	lsr.w	#3,d2

	mw	(bm_BytesPerRow,a1),d4
	mulu.w	d4,d1
	ext.l	d0
	add.l	d0,d1
	adda.l	d1,a0

	sub.w	d0,d2				;Width of middle copy
	bne.b	.Full				;Not Quick
	ml	(a6,d6.w*4),d0
	not.l	d0
	and.l	(a6,d5.w*4),d0
	not.l	d0
	movea.l	d4,a5
..	and.l	d0,(a0)
	adda.w	a5,a0
	dbra	d3,..
.Exit	rts
.Full	exg	d4,a5
	lsr.w	#2,d2
	ml	(a6,d5.w*4),d1
	bmi.b	0$
	movem.l	d3/a0,-(a7)
	ml	d1,d0
	not.l	d0
..	and.l	d0,(a0)
	adda.w	a5,a0
	dbra	d3,..
	movem.l	(a7)+,d3/a0
	subq.w	#1,d2
	addq.l	#4,a0
0$
	subq.w	#1,d2
	bmi.b	1$
	mw	d2,d5
	addq.l	#1,d5
	lsl.w	#2,d5
	movem.l	d3/d5/a0/a5,-(a7)
	suba.w	d5,a5
	mq	#0,d0
	mq	#-1,d1
.Loop	mw	d2,d5
..	ml	d0,(a0)+
	dbra	d5,..
	adda.w	a5,a0
	dbra	d3,.Loop

	movem.l	(a7)+,d3/d5/a0/a5
	adda.w	d5,a0
1$	ml	(a6,d6.w*4),d0
	bmi.b	2$
..	and.l	d0,(a0)
	adda.w	a5,a0
	dbra	d3,..
2$	rts

BMask:	dl	$ffffffff,$7fffffff,$3fffffff,$1fffffff,$0fffffff,$07ffffff,$03ffffff,$01ffffff
	dl	$00ffffff,$007fffff,$003fffff,$001fffff,$000fffff,$0007ffff,$0003ffff,$0001ffff
	dl	$0000ffff,$00007fff,$00003fff,$00001fff,$00000fff,$000007ff,$000003ff,$000001ff
	dl	$000000ff,$0000007f,$0000003f,$0000001f,$0000000f,$00000007,$00000003,$00000001

;------------------------------------------------------------------------------
FireColors
	dw	$000,$100,$200,$300,$400,$500,$600,$700
	dw	$811,$922,$a33,$b44,$c55,$d66,$e77,$f88
RingColors
	dw	$000,$001,$002,$003,$004,$005,$006,$007
	dw	$118,$229,$33a,$44b,$55c,$66d,$77e,$88f
WeirdColors
	dw	$000,$111,$222,$333,$444,$555,$666,$777
	dw	$887,$996,$aa5,$bb4,$cc3,$dd2,$ee1,$ff0
ZoomColors
	dw	$000,$010,$020,$030,$040,$050,$060,$070
	dw	$181,$292,$3a3,$4b4,$5c5,$6d6,$7e7,$8f8
DiscColors
BoxColors
PolyColors
PixelColors
	dw	$000,$800,$080,$880,$008,$808,$088,$888
	dw	$888,$F88,$8F8,$ff8,$88f,$f8f,$8ff,$fff

;	SECTION	RTGData,DATA			;Read/Write
DEMO_BSS	dx.b	DEMO_SIZEOF
