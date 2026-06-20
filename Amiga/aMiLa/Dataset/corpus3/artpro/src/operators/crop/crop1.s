;APS0000171FF8266217F8266217F8266217F8266217F8266217F8266217F8266217F82662173B3D444D
;===========================================================================
;
;		Crop einen Ausschnitt 
;		(c) 1997 ,Frank (Copper) Pagels  /DFT
;
;		22.02.98

		incdir 	include:

		include	exec/exec_lib.i
		include	exec/lists.i
		include	exec/memory.i
		include intuition/intuition_lib.i
		include libraries/gadtools.i
		include	libraries/wb_lib.i
		include	libraries/reqtools_lib.i
		include	graphics/graphics_lib.i
		Include utility/tagitem.i
		include	dos/dos.i		
		include	dos/dos_lib.i		

		include misc/artpro.i
		include render/render_lib.i
		include render/render.i
		

		OPERATORHEADER cr_NODE

		dc.b	'$VER: Visual Crop  Operator Modul 0.10 (22.02.98)',0
	even
;---------------------------------------------------------------------------
cr_NODE:
		dc.l	0,0
		dc.b	0,0
		dc.l	cr_name
		dc.l	cr_Party
		dc.b	'CROP'
		dc.b	'EXTR'	;for extern loader
		dc.l	0
		dc.l	cr_Tags
cr_name:
		dc.b	'Crop Visual',0
	even
;---------------------------------------------------------------------------

cr_Tags:
		dc.l	APT_Creator,cr_Creator
		dc.l	APT_Version,5
		dc.l	APT_Info,cr_Info
;		dc.l	APT_Prefs,cr_Prefsrout		;routine for Prefs
;		dc.l	APT_Prefsbuffer,cr_mirror
;		dc.l	APT_Prefsbuffersize,1
;		dc.l	APT_PrefsVersion,1
		dc.l	TAG_DONE

cr_Creator:
		dc.b	'(c) 1998 Frank Pagels /DEFECT Softworks',0
	even
cr_Info:
		dc.b	'Crop Visual',10,10
		dc.b	'Crop a selceted area of the image',0
	even

cr_mirror:	dc.w	0

cr_newpicmem	=	APG_Free2

cr_window	dc.l	0
cr_GList	dc.l	0
cr_gadarray	dcb.l	3,0

;---------------------------------------------------------------------------
cr_Party:

		tst.w	APG_LoadFLag(a5)
		bne	.p
		moveq	#APOE_NOIMAGE,d3
		rts
.p		
		jsr	APR_Selectbrush(a5)

		tst.w	APG_Cutflag(a5)
		bne.b	.brushok
		rts
.brushok:
		tst.l	APG_rndr_rendermem(a5)
		bne	cr_normal

;erstmal rendermem anlegen

		move.w	APG_xbrush2(a5),d0
		sub.w	APG_xbrush1(a5),d0
		add.w	#15,d0
		lsr.w	#4,d0
		add.w	d0,d0
		moveq	#00,d1
		move.w	APG_ybrush2(a5),d1
		sub.w	APG_ybrush1(a5),d1
		jsr	APR_InitRenderMem(a5)
		tst.l	d0
		bne	.renderok
		move.l	#APOE_NOMEM,d3
		rts
.renderok:
		jsr	APR_MakeRGBData(a5)	


;---------------------------------------------------------------------------------
cr_normal:

		tst.l	APG_Picmem(a5)
		beq	cr_nixbitmap
		
		moveq	#0,d0
		move.w	APG_xbrush2(a5),d0
		sub.w	APG_xbrush1(a5),d0
		add.w	#15,d0
		lsr.w	#4,d0
		add.w	d0,d0
		moveq	#00,d1
		move.w	APG_ybrush2(a5),d1
		sub.w	APG_ybrush1(a5),d1
		mulu	d1,d0
		move.l	APG_OnePlaneSize(a5),APG_Free3(a5)
		move.l	d0,APG_OnePlaneSize(a5)
		moveq	#0,d1
		move.b	APG_Planes(a5),d1
		mulu.l	d1,d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,cr_newpicmem(a5)
		bne.b	.memok
		moveq	#APOE_NOMEM,d3
		rts
.memok:
		
cr_nixbitmap:

;mache neuen RGB Puffer

		move.l	APG_rndr_rendermem(a5),APG_Free4(a5)
		move.l	APG_rndr_rgb(a5),APG_Free5(a5)
		move.l	APG_rndr_chunky,APG_Free6(a5)

		moveq	#0,d0
		move.w	APG_xbrush2(a5),d0
		sub.w	APG_xbrush1(a5),d0
		add.w	#15,d0
		lsr.w	#4,d0
		add.w	d0,d0
		moveq	#00,d1
		move.w	APG_ybrush2(a5),d1
		sub.w	APG_ybrush1(a5),d1

		jsr	APR_InitRenderMem(a5)
		tst.l	d0
		bne	.renderok
		tst.l	cr_newpicmem(a5)
		beq	.w
		move.l	cr_newpicmem(a5),a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a5)
		clr.l	cr_newpicmem(a5)
.w		move.l	#APOE_NOMEM,d3
		rts

.renderok:
;kopiere Bild in neuen Puffer

		move.l	APG_Picmem(a5),d0
		beq	.w1
		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
		move.l	cr_newpicmem(a5),APG_Picmem(a5)
.w1
		moveq	#0,d0
		move.w	APG_ImageWidth(a5),d0
		add.w	#15,d0
		lsr.w	#4,d0
		lsl.w	#6,d0		;länge einer zeile in bytes
		move.l	d0,apg_free8(a5)

		moveq	#0,d0
		move.w	APG_xbrush2(a5),d0
		sub.w	APG_xbrush1(a5),d0
		move.w	d0,APG_ImageWidth(a5)
		add.w	#7,d0
		lsr.w	#3,d0
		move.l	d0,APG_Bytewidth(a5)	

		move.w	APG_ybrush2(a5),d0
		sub.w	APG_ybrush1(a5),d0
		move.w	d0,APG_ImageHeight(a5)
		
		jsr	APR_InitPicMap(a5)

		move.l	apg_free5(a5),a0	;alte rgb daten
		move.l	apg_rndr_rgb(a5),a1	;platz für die neuen rgb daten

;offsets berechnen		

		jsr	apr_dummy(a5)


		moveq	#0,d0
		move.w	APG_ybrush1(a5),d0
		move.l	apg_free8(a5),d1
		move.l	d1,d2		;zeilen offset merken
		mulu	d0,d1
		add.l	d1,a0
		moveq	#0,d0
		move.w	apg_xbrush1(a5),d0
		lsl.w	#2,d0
		add.l	d0,a0

		moveq	#0,d6
		move.w	apg_xbrush2(a5),d5
		sub.w	apg_xbrush1(a5),d5
		move.l	d5,d0
		lsl.l	#2,d0
		add.w	#15,d5
		lsr.w	#4,d5
		lsl.w	#6,d5		
		sub.w	d0,d5		;offset prozeile

		move.w	apg_ybrush2(a5),d7
		sub	apg_ybrush1(a5),d7
.loopx		
		move.w	apg_xbrush2(a5),d6
		sub.w	apg_xbrush1(a5),d6
		lsl.w	#2,d6
.wx
		move.l	(a0)+,(a1)+		;eine zeile kopieren
		dbra	d6,.wx
		
		add.l	d2,a0			;offset für eine zeile kopieren
		add.l	d5,a1
		dbra	d7,.loopx
		
		jsr	APR_MakePreview(a5)

		moveq	#0,d3
		rts

;-------------------------------------------------------------------------
;flippe mit truecolor daten
cr_true:

;flippe bereich um die x achse

		move.w	APG_ybrush2(a5),d4
		sub.w	APG_ybrush1(a5),d4
		subq.w	#1,d4
		move.w	APG_xbrush2(a5),d7
		sub.w	APG_xbrush1(a5),d7
		lsr.w	#1,d7
		subq.w	#1,d7
		move.w	d7,d5
		move.l	APG_bytewidth(a5),d6
		lsl.l	#3+2,d6
		move.l	APG_rndr_rgb(a5),a0
		moveq	#0,d2
		move.w	APG_ybrush1(a5),d2
		mulu	d6,d2
		add.l	d2,a0		;erste zeile einstellen
		move.l	a0,a1
		move.b	cr_mirror(pc),d2
.nl:
		moveq	#0,d0
		moveq	#0,d1
		move.w	APG_xbrush1(a5),d0
		move.w	APG_xbrush2(a5),d1
		subq.w	#1,d1
.nx
		move.l	(a0,d0.l*4),d3
		tst.b	d2
		bne.b	.mirr
		move.l	(a0,d1.l*4),(a0,d0.l*4)
.mirr:		move.l	d3,(a0,d1.l*4)
		addq.w	#1,d0
		subq.w	#1,d1			
		dbra	d7,.nx
		add.l	d6,a1
		move.l	a1,a0
		move.w	d5,d7
		dbra	d4,.nl		

		move.b	APG_HAM_FLag(a5),d0
		add.b	APG_HAM8_FLag(a5),d0
		tst.b	d0
		beq.b	.noham

		jsr	APR_Render(a5)
		bra	.w

.noham:
		jsr	APR_MakePreview(a5)
.w
		moveq	#0,d3
		rts

;----------------------------------------------------------------------------
cr_makeham:
		tst.l	APG_rndr_rendermem(a5)
		bne.w	cr_true			:wir haben schon rgb daten

		jsr	APR_MakeRGBData(a5)
		
		bra.w	cr_true
		
;----------------------------------------------------------------------------
cr_Prefsrout
		moveq	#0,d0
		move.b	cr_mirror(pc),d0
		lea	cr_MXmirror(pc),a0
		move.l	d0,(a0)
;----------------------------------------------------------------------------

		move.l	#WindowTags,APG_WindowTagList(a5)	;Tag list for the Window
		move.l	#WinWG+4,APG_WGadgets(a5)	;addr. of WA_Gadgets Tag + 4
		move.l	#winSC+4,APG_WScreen(a5)	;addr. of WA_CustomScreen Tag + 4
		move.l	#cr_window,APG_WinWnd(a5)	;a point for the Window
		move.l	#cr_Glist,APG_Glist(a5)		;a point for the Glist
		move.l	#NTypes,APG_NGads(a5)		;the NGads list
		move.l	#Gtypes,APG_GTypes(a5)		;the GTypes list
		move.l	#Gtags,APG_Gtags(a5)		;the Gtags list
		move.w	#3,APG_CNT(a5)			;the number of Gadgets
		move.l	#cr_gadarray,APG_Gadgets(a5)	;a pointer for the Gadgetsarry, size=4*number of Gadgets
		move.l	APG_Scr(a5),APG_ScrBase(a5)	;the Screenpointer , stored in APG_Scr
	
		move.l	APG_CheckMainWinPos(a5),a6
		jsr	(a6)

		add.w	#315+30,d0
		add.w	#100,d1
		
		move.w	d0,APG_WinLeft(a5)		;the left pos. of the Win
		move.w	d1,APG_WinTop(a5)		;the top pos. of the Win
		move.w	#160,APG_WinWidth(a5)		;the width of the Win
		move.w	#70,APG_WinHeight(a5)		;the height of the Win

		move.l	#WinL,APG_WinL(a5)		;addr. of WA_Left Tag 
		move.l	#WinT,APG_WinT(a5)		;addr. of WA_Top Tag
		move.l	#WinW,APG_WinW(a5)		;addr. of WA_Width Tag
		move.l	#WinH,APG_WinH(a5)		;addr. of WA_Height Tag

		move.l	APG_OpenWindow(a5),a6
		jsr	(a6)

		lea	Text0(pc),a2
		move.w	#Project0_TNUM,APG_TNUM(a5)
		move.l	APG_Writetext(a5),a6
		jsr	(a6)

		move.b	cr_mirror(pc),APG_Mark1(a5)	;rette alte Prefs

cr_wait:	move.l	cr_window(pc),a0
		move.l	APG_Wait(a5),a6
		jsr	(a6)

		cmp.l	#IDCMP_CLOSEWINDOW,d4
		beq.b	cr_Cancel		
		cmp.l	#GADGETUP,d4
		beq.b	cr_gads
		cmp.l	#GADGETDOWN,d4
		beq.b	cr_gads
		bra.b	cr_wait

cr_gads:
		moveq	#0,d0
		move.w	38(a4),d0

		add.l	d0,d0
		lea	cr_jumptab(pc),a0
		move.w	(a0,d0.l),d0
		jmp	(a0,d0.w)

cr_cancel:
		move.b	APG_Mark1(a5),d0
		ext.w	d0
		ext.l	d0
		move.b	d0,cr_mirror
		move.l	d0,cr_MXmirror

cr_pok:
		move.l	cr_window(pc),a0
		move.l	APG_Intuitionbase(a5),a6
		jmp	_LVOCloseWindow(a6)

cr_jumptab:
		dc.w	handlemirror-cr_jumptab
		dc.w	cr_pok-cr_jumptab,cr_cancel-cr_jumptab

handlemirror:
		move.b	d5,cr_mirror
		ext.w	d5
		ext.l	d5
		move.l	d5,cr_MXmirror
		bra.b	cr_wait

;------------------------------------------------------------------------------
WindowTags:
winL:	dc.l	WA_Left,212
winT:	dc.l	WA_Top,78
winW:	dc.l	WA_Width,220
winH:	dc.l	WA_Height,85
		dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW!MXIDCMP!GADGETUP!VANILLAKEY!BUTTONIDCMP!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_CLOSEGADGET!WFLG_DEPTHGADGET!WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_SMART_REFRESH!WFLG_RMBTRAP
winWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title,winWTitle
winSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

WinWTitle:	dc.b	'Flip X Options',0
	even

GD_Mirror	=	0
GD_Ok		=	1
GD_Cancel	=	2

Gtypes:
		dc.w	MX_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
Gtags:
		dc.l	GTMX_Labels,Gadget00Labels
		dc.l	GTMX_Active
cr_mxmirror:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
Gadget00Labels:
		dc.l	Gadget00Lab0
		dc.l	Gadget00Lab1
		dc.l	0

Gadget00Lab0:	dc.b	'Flip',0
Gadget00Lab1:	dc.b	'Mirror',0

NTypes:
		DC.W    70,20,17,9
		DC.L    0,0
		DC.W    GD_mirror
		DC.L    0,0,0
		DC.W    10,50,60,13
		DC.L    oktext,0
		DC.W    GD_Ok
		DC.L    PLACETEXT_IN,0,0
		DC.W    85,50,60,13
		DC.L    canceltext,0
		DC.W    GD_Cancel
		DC.L    PLACETEXT_IN,0,0

oktext:		dc.b	'_Ok',0
canceltext:	dc.b	'_Cancel',0

Text0:
		DC.B    2,0
		DC.B    RP_JAM1
		DC.B    0
		DC.W    80,10
		DC.L    0
		DC.L    Project0IText0
		DC.L    0

Project0_TNUM EQU 1

Project0IText0:
		DC.B    'Choose',0

;----------------------------------------------------------------------------
		section	laber,bss
cr_bitmaptab:	ds.l	8
