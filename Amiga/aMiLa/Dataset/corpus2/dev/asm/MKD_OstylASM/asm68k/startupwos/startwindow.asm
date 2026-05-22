שתשתÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
;	Window on startup
;
;	OSTYL^MKD 
;	7 July 02

	INCDIR	INCLUDES:

	INCLUDE	EXEC/EXECBASE.i
	INCLUDE	EXEC/LIBRARIES.i
	INCLUDE	INTUITION/INTUITION.i
	INCLUDE	LIBRARIES/GADTOOLS.i
	INCLUDE	MISC/DEVPACMACROS.i

	XREF	_IntuiBase
	XREF	_GadBase

	XDEF	StartWindow

StartWindow:

	;---- init gadget

	Move.L	_IntuiBase,a6
	Jsr	_LVOOpenWorkBench(a6)
	Move.L	d0,a0
	Beq.W	Leave
	
	Move.L	_GadBase,a6
	Sub.L	a1,a1
	Jsr     _LVOGetVisualInfoA(a6)
	Move.L  d0,GadVisualInfo
	Beq.W	Leave
	
	Move.L	_GadBase,a6
	Lea	GList(pc),a0
	Jsr	_LVOCreateContext(a6)
	Move.L	d0,GadContext
	Beq.W	Leave

	;---- create start gadget
	
	Move.L	_GadBase,a6
	Move.L	GadContext(pc),a0
	Lea	NewGad0(pc),a1
	Move.L	GadVisualInfo(pc),gng_VisualInfo(a1)
	Lea	Gad0_Tags(pc),a2
	Moveq	#BUTTON_KIND,d0
	Jsr	_LVOCreateGadgetA(a6)
	Move.L	d0,StructGad0
	Beq.W	Leave
	
	;---- open a window

	Move.L	_IntuiBase,a6
	Lea	StructNewWin(pc),a0
	Lea	WinTags(pc),a1
	Jsr	_LVOOpenWindowTagList(a6)
	Move.L	d0,StructWin
	Beq.W	Leave

	;---- draw bevel box

	Move.L	_GadBase,a6
	Move.L	GadVisualInfo(pc),Bevel0VI
	Move.L	StructWin(pc),a0
	Move.L	wd_RPort(a0),a0
	Lea	Bevel0Tags(pc),a1
	Moveq	#10,d0
	Moveq	#14,d1
	Move.L	#268,d2
	Move.L	#113,d3
	Jsr	_LVODrawBevelBoxA(a6)

	;---- print texts

	Move.L	_IntuiBase,a6
	Move.L	StructWin(pc),a0
	Move.L	wd_RPort(a0),a0
	Lea	Win0Texts(pc),a1
	Moveq	#0,d0
	Moveq	#0,d1
	Jsr	_LVOPrintIText(a6)

	;----

;	Move.L	_IntuiBase,a6
;	Move.L	GadContext(pc),a0
;	Move.L	StructWin(pc),a1
;	Sub.L	a2,a2
;	Jsr	_LVORefreshGadgets(a6)	

	;---- messages processing

	Move.L	4.w,a6
	Move.L	StructWin(pc),a0
	Move.L	wd_UserPort(a0),a0	
	Jsr	_LVOWaitPort(a6)

	Move.L	_GadBase,a6
	Move.L	StructWin(pc),a0
	Move.L	wd_UserPort(a0),a0
	Jsr	_LVOGT_GetIMsg(a6)

	Move.L	_GadBase,a6
	Move.L	d0,a1
	Jsr	_LVOGT_ReplyIMsg(a6)

	;----
		
Leave:	Move.L	_IntuiBase,a6
	Move.L	StructWin(pc),a0
	Tst.L	a0
	Beq.B	FreeGadgets
	Jsr	_LVOCloseWindow(a6)

FreeGadgets:
	Move.L	_GadBase,a6
	Move.L	GList(pc),a0
	Tst.L	a0
	Beq.B	FreeVisual
	Jsr     _LVOFreeGadgets(a6)

FreeVisual:
	Move.L	_GadBase,a6
	Move.L	GadVisualInfo(pc),a0
	Tst.L	a0
	Beq.B	Done
	Jsr     _LVOFreeVisualInfo(a6)

Done:	Rts

;-----------------STRUCTURES---------------------


StructNewWin:	Ds.B	nw_SIZEOF
StructWin:	Ds.L	1

		;----

WinTags:	Dc.L	WA_Left,176
		Dc.L	WA_Top,40
		Dc.L	WA_Width,288
		Dc.L	WA_Height,160
		Dc.L	WA_Title,WinTitle
		Dc.L	WA_MinWidth,150
		Dc.L	WA_MinHeight,25
		Dc.L	WA_MaxWidth,288
		Dc.L	WA_MaxHeight,160
		Dc.L	WA_DragBar,1
		Dc.L	WA_DepthGadget,1
		Dc.L	WA_CloseGadget,1
		Dc.L	WA_Activate,1
		Dc.L	WA_NewLookMenus,1
		Dc.L	WA_SmartRefresh,1
		Dc.L	WA_AutoAdjust,1
		Dc.L	WA_Zoom,WinZoomInfo
		Dc.L	WA_PubScreen
PubScreen:	Dc.L	0
		Dc.L	WA_Gadgets
GList:		Dc.L	0
		Dc.L	WA_IDCMP,CLOSEWINDOW+REFRESHWINDOW+GADGETUP
		Dc.L	TAG_END

		;----

WinZoomInfo:	Dc	200,0

WinTitle:	Dc.B	'Mankind',0
		EVEN

;----

Bevel0Tags:	Dc.L	GTBB_Recessed
		Dc.L	1
		Dc.L	GT_VisualInfo
Bevel0VI:	Dc.L	0
		Dc.L	TAG_DONE

;----

Win0Texts:
Win0Text0:	Dc.B	1,3		; FrontPen,BackPen
		Dc.B	0,0		; DrawMode
		Dc	18,16		; LeftEdge,TopEdge
		Dc.L	Topaz8		; TextAttr
		Dc.L	Text0
		Dc.L	Win0Text1

Win0Text1:	Dc.B	1,3		; FrontPen,BackPen
		Dc.B	0,0		; DrawMode
		Dc	18,40		; LeftEdge,TopEdge
		Dc.L	Topaz8		; TextAttr
		Dc.L	Text1
		Dc.L	Win0Text2

Win0Text2:	Dc.B	1,3		; FrontPen,BackPen
		Dc.B	0,0		; DrawMode
		Dc	18,50		; LeftEdge,TopEdge
		Dc.L	Topaz8		; TextAttr
		Dc.L	Text2
		Dc.L	Win0Text3

Win0Text3:	Dc.B	1,3		; FrontPen,BackPen
		Dc.B	0,0		; DrawMode
		Dc	18,60		; LeftEdge,TopEdge
		Dc.L	Topaz8		; TextAttr
		Dc.L	Text3
		Dc.L	0

Text0:		Dc.B	'     - Equinoxe Invtro -',0
		EVEN

Text1:		Dc.B	'         Code: OSTYL',0
		EVEN

Text2:		Dc.B	'    Music : UNISON (upfront)',0
		EVEN

Text3:		Dc.B	'  Graphics : GWEN, KRABOB, BLA',0
		EVEN

;----

GadVisualInfo	Ds.L	1
GadContext	Ds.L	1
StructGad0	Ds.L	1

NewGad0:	Dc	70,130,145,22
		Dc.L	Gad0_Txt,Topaz8
		Dc	0
		Dc.L	PLACETEXT_IN
		Dc.L	0
		Dc.L	0

Topaz8:		Dc.L	Topaz8Name
		Dc	8
		Dc.B	0,0

Topaz8Name:	Dc.B	'topaz.font',0
		EVEN

Gad0_Txt:	Dc.B	'!! START !!',0
		EVEN

Gad0_Tags:	Dc.L	TAG_DONE
