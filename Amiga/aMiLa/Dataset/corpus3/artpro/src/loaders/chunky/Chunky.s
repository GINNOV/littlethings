;===========================================================================
;
;		Normaly Chunky loader
;
;		(c) 1997 ,Frank (Copper) Pagels /Defect Softworks
;
;		26.01.97

		MC68020

		incdir 	include:

		include	exec/exec_lib.i
		include	exec/lists.i
		include	exec/memory.i
		include intuition/intuition_lib.i
		include	intuition/intuition.i
		include	libraries/wb_lib.i
		include	graphics/graphics_lib.i
		Include utility/tagitem.i
		include	dos/dos.i		
		include	dos/dos_lib.i		
		include libraries/gadtools_lib.i
		include libraries/gadtools.i

		include misc/artpro.i
		include	render/render_lib.i		
		include	render/render.i		

		LOADERHEADER ch_NODE

		dc.b	'$VER: Chunky loader module 1.00 (28.01.97)',0
	even
;---------------------------------------------------------------------------
ch_NODE:
		dc.l	0,0
		dc.b	0,0
		dc.l	ch_name
		dc.l	ch_load
		dc.b	'CHNK'
		dc.b	'EXTR'	;for extern loader
		dc.l	0
		dc.l	ch_Tags
ch_name:
		dc.b	'CHUNKY',0
	even
;---------------------------------------------------------------------------

ch_Tags:
		dc.l	APT_Creator,ch_Creator
		dc.l	APT_Version,5
		dc.l	APT_Info,ch_Info
		dc.l	APT_Prefs,ch_Prefsrout		;routine for Prefs
		dc.l	APT_Prefsbuffer,ch_prefspuffer
		dc.l	APT_Prefsbuffersize,1
		dc.l	APT_PrefsVersion,1
		dc.l	0

ch_Creator:
		dc.b	'(c) 1997 Frank Pagels /Defect SoftWorks',0
	even
ch_Info:
		dc.b	'Chunky loader',10,10
		dc.b	'Loads left/right oriented 8 Bit Chunky Maps',10,0

	even
ch_prefspuffer:


ch_ctype:	dc.b	1

pback:		ds.b	1
	even

;---------------------------------------------------------------------------

CH_window:	dc.l	0
CH_Glist:	dc.l	0
CH_gadarray:	ds.l	4
	even

CH_pwindow:	dc.l	0
CH_pGlist:	dc.l	0
CH_pgadarray:	ds.l	4

rgbwidth	ds.l	1
rgbheight	ds.l	1
ch_chunkpuffer	ds.l	1
rgbline		=	APG_Free3

;---------------------------------------------------------------------------
ch_load
		clr.l	rgbline(a5)

		move.l	#WindowTags,APG_WindowTagList(a5) ;Tag list for the Window
		move.l	#WinWG+4,APG_WGadgets(a5)	;addr. of WA_Gadgets Tag + 4
		move.l	#winSC+4,APG_WScreen(a5)	;addr. of WA_CustomScreen Tag + 4
		move.l	#CH_window,APG_WinWnd(a5)	;a point for the Window
		move.l	#CH_Glist,APG_Glist(a5)		;a point for the Glist
		move.l	#NTypes,APG_NGads(a5)		;the NGads list
		move.l	#Gtypes,APG_GTypes(a5)		;the GTypes list
		move.l	#Gtags,APG_Gtags(a5)		;the Gtags list
		move.w	#4,APG_CNT(a5)			;the number of Gadgets
		move.l	#CH_gadarray,APG_Gadgets(a5)	;a pointer for the Gadgetsarry, size=4*number of Gadgets
		move.l	APG_Scr(a5),APG_ScrBase(a5)	;the Screenpointer , stored in APG_Scr
	
		move.l	APG_CheckMainWinPos(a5),a6	;returns d0,d1 Pos
		jsr	(a6)

		add.w	#170,d0
		add.w	#100,d1
		
		move.w	d0,APG_WinLeft(a5)		;the left pos. of the Win
		move.w	d1,APG_WinTop(a5)		;the top pos. of the Win
		move.w	#180,APG_WinWidth(a5)		;the width of the Win
		move.w	#60,APG_WinHeight(a5)		;the height of the Win

		move.l	#WinL,APG_WinL(a5)		;addr. of WA_Left Tag 
		move.l	#WinT,APG_WinT(a5)		;addr. of WA_Top Tag
		move.l	#WinW,APG_WinW(a5)		;addr. of WA_Width Tag
		move.l	#WinH,APG_WinH(a5)		;addr. of WA_Height Tag

		move.l	APG_OpenWindow(a5),a6
		jsr	(a6)


CH_wait:	move.l	CH_window(pc),a0
		move.l	APG_Wait(a5),a6
		jsr	(a6)				;Handle input

		cmp.l	#GADGETUP,d4
		beq.b	CH_gads
		cmp.l	#GADGETDOWN,d4
		beq.b	CH_gads
		bra.b	CH_wait

CH_gads:
		moveq	#0,d0
		move.w	38(a4),d0

		cmp.w	#GD_RGBwidth,d0
		beq	handlewidth
		cmp.w	#GD_RGBheight,d0
		beq.b	handleheight
		cmp.w	#GD_RGBOk,d0
		beq	ch_ok
		cmp.w	#GD_RGBcancel,d0
		beq	ch_cancel

		bra	ch_wait

ch_closewindow:
		move.l	CH_window(pc),a0
		move.l	APG_Intuitionbase(a5),a6
		jmp	_LVOCloseWindow(a6)

handlewidth:
		move.l	#GD_RGBwidth,d0	
		lea	CH_gadarray(pc),a0
		bsr.w	ch_holewert
		move.l	ch_number(pc),d0
		move.l	d0,rgbwidth
		move.l	d0,rwidth
		move.l	#GD_RGBheight,d0
		bsr.b	ch_activate
		bra.w	ch_wait

handleheight:
		move.l	#GD_RGBheight,d0	
 		lea	CH_gadarray(pc),a0
		bsr.w	ch_holewert
		move.l	ch_number(pc),d0
		move.l	d0,rgbheight
		move.l	d0,rheight
		move.l	#GD_RGBwidth,d0
		bsr.b	ch_activate
		bra.w	ch_wait

ch_ok:
		bsr	ch_closewindow
		bra	ch_goload
		
ch_cancel:
		bsr	ch_closewindow
		lea	ch_cancelmsg(pc),a4
		move.l	APG_Status(a5),a6
		jsr	(a6)
		move.l	#APLE_ERROR,d3
		rts
ch_cancelmsg:
		dc.b	'Load Chunky aborted!',0

	even

ch_activate:
		add.l	d0,d0
		add.l	d0,d0
		lea	CH_gadarray(pc),a0
		move.l	(a0,d0.l),a0
		move.l	CH_window(pc),a1
		sub.l	a2,a2
		move.l	APG_Intuitionbase(a5),a6
		jmp	_LVOActivateGadget(a6)		

ch_holewert:
		add.l	d0,d0
		add.l	d0,d0
		lea	CH_gadarray(pc),a0
		move.l	(a0,d0.l),a0
		move.l	CH_window(pc),a1
		sub.l	a2,a2
		lea	ch_taglist,a3		
		move.l	APG_Gadtoolsbase(a5),a6
		jmp	_LVOGT_GetGadgetAttrsA(a6)

ch_taglist:
		dc.l	GTIN_Number,ch_number
		dc.l	TAG_DONE

ch_number:	dc.l	0

;---------------------------------------------------------------------------
ch_goload:
		move.l	rgbwidth(pc),d0
		move.l	rgbheight(pc),d1
		mulu.l	d1,d0

		cmp.l	APG_FileSize(a5),d0
		beq	.sizematch

		lea	dimemsionsmsg(pc),a4
		move.l	APG_Status(a5),a6
		jsr	(a6)
		moveq	#-1,d3
		rts
.sizematch:

		move.l	rgbwidth(pc),d0
		move.l	rgbheight(pc),d1
		move.w	d0,APG_ImageWidth(a5)
		move.w	d1,APG_ImageHeight(a5)

		add.w	#15,d0		;16er Breite bringen
		lsr.w	#4,d0
		add.l	d0,d0
		move.l	d0,d6
		move.l	d6,d5
		lsl.l	#3,d6
		move.l	d6,d7
		sub.w	APG_ImageWidth(a5),d7	;Modulo

		lsl.l	#2,d6			;*4
		lsl.l	#2,d7
		move.l	d7,APG_Free4(a5)	;Für Chunky 12
		
		move.l	d5,APG_ByteWidth(a5)
		moveq	#0,d4
		move.w	APG_ImageHeight(a5),d4
		mulu.l	d4,d5
		move.l	d5,APG_Oneplanesize(a5)

		move.l	APG_FileSize(a5),d0
		move.l	#MEMF_ANY!MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,ch_chunkpuffer
		bne	.chmemok
		clr.l	ch_chunkpuffer
.wm		moveq	#APLE_NOMEM,d0
		rts
.chmemok:
		jsr	APR_OpenProcess(a5)

		moveq	#4,d0
		lea	CH_loadmsg(pc),a1
		jsr	APR_InitProcess(a5)


		jsr	APR_Doprocess(a5)
;Lade Chunkyfile

		move.l	APG_Filehandle(a5),d1
		move.l	ch_chunkpuffer(pc),d2
		move.l	APG_Filesize(a5),d3
		move.l	APG_Dosbase(a5),a6
		jsr	_LVORead(a6)

;checke anzahl der Planes

		jsr	APR_Doprocess(a5)

		move.l	APG_Filesize(a5),d7
		subq.l	#1,d7
		move.l	ch_chunkpuffer(pc),a0

		tst.b	ch_ctype
		bne	ch_loadright

;Lade left oriented chunkys

		moveq	#0,d0
.ncl		move.b	(a0),d2
		moveq	#0,d1

		moveq	#7,d6
		moveq	#0,d1
		moveq	#1,d3
.nc		add.b	d2,d2
		bcc	.w
		or.b	d3,d1
.w		add.b	d3,d3
		dbra	d6,.nc

		move.b	d1,(a0)+
		cmp.b	d1,d0
		bhs	.wl
		move.b	d1,d0
.wl
		dbra	d7,.ncl
		bra	ch_checkplanes

ch_loadright:
		moveq	#0,d0
.nc		move.b	(a0)+,d1
		cmp.b	d1,d0
		bhs	.w
		move.b	d1,d0
.w
		dbra	d7,.nc

ch_checkplanes

		cmp.b	#2,d0
		bhi	.nix2
		moveq	#1,d0
		bra	.endcheck
.nix2		cmp.b	#4,d0
		bhi	.nix4
		moveq	#2,d0
		bra	.endcheck
.nix4:		cmp.b	#8,d0
		bhi	.nix8
		moveq	#3,d0
		bra	.endcheck
.nix8:		cmp.b	#16,d0
		bhi	.nix16
		moveq	#4,d0
		bra	.endcheck
.nix16:		cmp.b	#32,d0
		bhi	.nix32
		moveq	#5,d0
		bra	.endcheck
.nix32:		cmp.b	#64,d0
		bhi	.nix64
		moveq	#6,d0
		bra	.endcheck
.nix64:		cmp.b	#128,d0
		bhi	.nix128
		moveq	#7,d0
		bra	.endcheck
.nix128:	moveq	#8,d0

.endcheck:	move.b	d0,APG_Planes(a5)
		move.l	d0,d1

		move.l	APG_Oneplanesize(a5),d0
		mulu.l	d1,d0
		move.l	#MEMF_ANY!MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,APG_Picmem(a5)
		bne	.memok
		move.l	ch_chunkpuffer(pc),d0
		beq	.wm1
		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
		clr.l	ch_chunkpuffer
.wm1		moveq	#APLE_NOMEM,d3
		rts
.memok

;Init Bitmap

		jsr	APR_Doprocess(a5)

		move.l	APG_FindMonitor(a5),a6
		jsr	(a6)
		
		lea	APG_PicMap(a5),a0	
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.b	APG_Planes(a5),d0
		move.w	APG_ImageWidth(a5),d1
		move.w	APG_ImageHeight(a5),d2	;höhe
		move.l	APG_Gfxbase(a5),a6
		jsr	_LVOinitbitmap(a6)

		move.l	APG_Picmem(a5),d0
		lea	APG_Picmap+8(a5),a0
		moveq	#0,d7
		move.b	APG_Planes(a5),d7
		subq.w	#1,d7
.npl		move.l	d0,(a0)+
		add.l	APG_Oneplanesize(a5),d0
		dbra	d7,.npl

;Kopiere Chunky nach Planes

		move.l	ch_chunkpuffer(pc),a0
		moveq	#0,d0
		moveq	#0,d1
		move.w	APG_ImageWidth(a5),d2
		move.w	APG_ImageHeight(a5),d3
		lea	APG_PicMap(a5),a1
		moveq	#0,d4
		moveq	#0,d5
		lea	ch_c2btag+4(pc),a2
		move.l	d3,(a2)
		move.l	APG_Renderbase(a5),a6
		jsr	_LVOChunky2BitmapA(a6)
		
		jsr	APR_Doprocess(a5)

;erzeuge Farbtabelle
CH_Makefarbtab:
		moveq	#1,d0
		moveq	#0,d1
		move.b	APG_Planes(a5),d1
		lsl.w	d1,d0
		move.w	d0,APG_ColorCount(a5)

		lea	APG_Farbtab8+4(a5),a0
		lea	APG_Farbtab4(a5),a1
		moveq	#0,d0
		move.l	#256,d2
		move.w	APG_Colorcount(a5),d3
		divu	d3,d2
		ext.l	d2
		move.w	APG_Colorcount(a5),d7
		ext.l	d7
		subq.l	#1,d7
.nc:
		move.l	d0,d1
		lsl.l	#8,d1
		swap	d1
		move.l	d1,(a0)+
		move.l	d1,(a0)+
		move.l	d1,(a0)+
		move.l	d0,d1
		lsr.w	#4,d1
		mulu	#$111,d1
		move.w	d1,(a1)+
		add.l	d2,d0
		dbra	d7,.nc
		
		lea	APG_Farbtab8(a5),a0
		move.w	APG_Colorcount(a5),(a0)

		clr.b	APG_Colortype_Flag(a5)
		tst.b	APG_Kick3_Flag(a5)
		beq.b	.no3
		move.b	#2,APG_Colortype_Flag(a5)
.no3:
		move.l	ch_chunkpuffer(pc),d0
		beq	.nixmem
		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
.nixmem
		jsr	APR_ClearProcess(a5)

		move.w	#1,APG_LoadFlag(a5)

		moveq	#APLE_OK,d3
		rts


;--------------------------------------------------------------------------
ch_Stop:
		move.l	APG_rndr_rendermem(a5),d0
		beq	.nfr
		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
		clr.l	APG_rndr_rendermem(a5)
.nfr:
		move.l	rgbline(a5),d0
		beq	.norgb
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
.norgb:
		jsr	APR_ClearProcess(a5)
		moveq	#APLE_ABORT,d3
		rts

;---------------------------------------------------------------------------
ch_prefsrout:

;--- Init Buttons ----
		moveq	#0,d0
		move.b	ch_ctype(pc),d0
		lea	ch_ctypetag(pc),a0
		move.l	d0,(a0)
		
		lea	ch_ctype(pc),a0
		lea	pback(pc),a1
		move.b	(a0),(a1)	;Prefs backuppen

		move.l	#PWindowTags,APG_WindowTagList(a5)	;Tag list for the Window
		move.l	#PWinWG+4,APG_WGadgets(a5)	;addr. of WA_Gadgets Tag + 4
		move.l	#PwinSC+4,APG_WScreen(a5)	;addr. of WA_CustomScreen Tag + 4
		move.l	#ch_pwindow,APG_WinWnd(a5)	;a point for the Window
		move.l	#ch_pGlist,APG_Glist(a5)		;a point for the Glist
		move.l	#PNTypes,APG_NGads(a5)		;the NGads list
		move.l	#PGtypes,APG_GTypes(a5)		;the GTypes list
		move.l	#PGtags,APG_Gtags(a5)		;the Gtags list
		move.w	#3,APG_CNT(a5)			;the number of Gadgets
		move.l	#ch_pgadarray,APG_Gadgets(a5)	;a pointer for the Gadgetsarry, size=4*number of Gadgets
		move.l	APG_Scr(a5),APG_ScrBase(a5)	;the Screenpointer , stored in APG_Scr
	
		move.l	APG_CheckMainWinPos(a5),a6
		jsr	(a6)

		add.w	#70,d0
		add.w	#100,d1
		
		move.w	d0,APG_WinLeft(a5)		;the left pos. of the Win
		move.w	d1,APG_WinTop(a5)		;the top pos. of the Win
		move.w	#216,APG_WinWidth(a5)		;the width of the Win
		move.w	#65,APG_WinHeight(a5)		;the height of the Win

		move.l	#PWinL,APG_WinL(a5)		;addr. of WA_Left Tag 
		move.l	#PWinT,APG_WinT(a5)		;addr. of WA_Top Tag
		move.l	#PWinW,APG_WinW(a5)		;addr. of WA_Width Tag
		move.l	#PWinH,APG_WinH(a5)		;addr. of WA_Height Tag

		move.l	APG_OpenWindow(a5),a6
		jsr	(a6)
		tst.l	d0
		beq	.winok
		rts

.winok:		lea	Text0(pc),a2
		move.w	#Project0_TNUM,APG_TNUM(a5)
		move.l	APG_Writetext(a5),a6
		jsr	(a6)


ch_pwait:	move.l	ch_pwindow(pc),a0
		move.l	APG_Wait(a5),a6
		jsr	(a6)

		cmp.l	#GADGETUP,d4
		beq.b	ch_pgads
		cmp.l	#GADGETDOWN,d4
		beq.b	ch_pgads
		cmp.l	#CLOSEWINDOW,d4
		beq	ch_pok
		bra.b	ch_pwait

ch_pgads:
		moveq	#0,d0
		move.w	38(a4),d0

		add.l	d0,d0
		lea	ch_pjumptab(pc),a0
		move.w	(a0,d0.l),d0
		jmp	(a0,d0.w)

ch_pcancel:
		lea	ch_ctype(pc),a0
		lea	pback(pc),a1
		move.w	(a1),(a0)	;Prefs backuppen

ch_pok:
		move.l	ch_pwindow(pc),a0
		move.l	APG_Intuitionbase(a5),a6
		jmp	_LVOCloseWindow(a6)

ch_pjumptab:
		dc.w	ch_ptype-ch_pjumptab
		dc.w	ch_pok-ch_pjumptab
		dc.w	ch_pcancel-ch_pjumptab

ch_ptype:
		move.b	d5,ch_ctype
		ext.w	d5
		ext.l	d5
		move.l	d5,ch_ctypetag


		bra.w	ch_pwait

;---------------------------------------------------------------------------

ch_c2btag:
		dc.l	RND_SourceWidth
		dc.l	0
		dc.l	TAG_DONE


GD_RGBwidth	=	0
GD_RGBheight	=	1
GD_RGBOk	=	2
GD_RGBcancel	=	3

GD_ch_type	=	0
GD_ch_ok	=	1
GD_ch_cancel	=	2


Gtypes:
		dc.w	INTEGER_KIND
		dc.w	INTEGER_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND

PGTypes:
		dc.w	CYCLE_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND

NTypes:
		dc.w	35,15-11,61,14
		dc.l	rgbwithText,0
		dc.w	GD_RGBwidth
		dc.l	PLACETEXT_RIGHT,0,0
		dc.w	35,30-11,61,14
		dc.l	rgbheightText,0
		dc.w	GD_RGBheight
		dc.l	PLACETEXT_RIGHT,0,0
		dc.w	18-3,40,66,14
		dc.l	rgbokText,0
		dc.w	GD_RGBOk
		dc.l	PLACETEXT_IN,0,0
		dc.w	100,40,66,14
		dc.l	rgbcancelText,0
		dc.w	GD_RGBcancel
		dc.l	PLACETEXT_IN,0,0

PNtypes:
		dc.w	35,30,140,13
		dc.l	ch_typetext,0
		dc.w	GD_ch_type
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	12,45+5,80,13
		dc.l	rgbokText,0
		dc.w	GD_ch_ok
		dc.l	PLACETEXT_IN,0,0
		dc.w	123,45+5,80,13
		dc.l	rgbcancelText,0
		dc.w	GD_ch_cancel
		dc.l	PLACETEXT_IN,0,0

GTags:
		dc.l	GTIN_Number
rwidth:		dc.l	0
		dc.l	GTIN_MaxChars,10
		dc.l	STRINGA_Justification,GACT_STRINGRIGHT
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GTIN_Number
rheight:	dc.l	0
		dc.l	GTIN_MaxChars,10
		dc.l	STRINGA_Justification,GACT_STRINGRIGHT
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	TAG_DONE


PGTags:
		dc.l	GTCY_Labels,ch_typelabels
		dc.l	GTCY_Active
ch_ctypetag:	dc.l	0
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	TAG_DONE



rgbwithText:	dc.b	'Width',0
rgbheightText:	dc.b	'Height',0
rgbokText:	dc.b	'Ok',0
rgbcancelText:	dc.b	'Cancel',0
ch_typetext:	dc.b	'Chunky type',0

	even
	
ch_typelabels:
		dc.l	ch_lefttype
		dc.l	ch_righttype
		dc.l	0
		
ch_lefttype:	dc.b	'Left oriented',0
ch_righttype:	dc.b	'Right oriented',0

	even
Text0:
		dc.b	2,0
		dc.b	RP_JAM1
		dc.b	0
		dc.w	110,6
		dc.l	0
		dc.l	Project0IText0
		dc.l	0

Project0_TNUM EQU 1

Project0IText0:
		dc.b	'Load Format',0

	even

WindowTags:
winL:		dc.l	WA_Left,212
winT:		dc.l	WA_Top,78
winW:		dc.l	WA_Width,215
winH:		dc.l	WA_Height,100
		dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW!VANILLAKEY!INTEGERIDCMP!CYCLEIDCMP!BUTTONIDCMP!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_CLOSEGADGET!WFLG_DEPTHGADGET!WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_SMART_REFRESH!WFLG_RMBTRAP
winWG:		dc.l	WA_Gadgets,0
		dc.l	WA_Title,imagewinWTitle
winSC:		dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

imagewinWTitle:	dc.b	'Specify Image',0
dimemsionsmsg:	dc.b	'File dimensions do not match!',0

PWindowtags:
pwinL:		dc.l	WA_Left,0
pwinT:		dc.l	WA_Top,0
pwinW:		dc.l	WA_Width,0
pwinH:		dc.l	WA_Height,0
		dc.l	WA_IDCMP,MXIDCMP!BUTTONIDCMP!IDCMP_CLOSEWINDOW!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_DRAGBAR!WFLG_DEPTHGADGET!WFLG_CLOSEGADGET!WFLG_SMART_REFRESH
PwinWG:		dc.l	WA_Gadgets,0
		dc.l	WA_Title,Project0WTitle
pwinSC:		dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE
 
Project0WTitle:	dc.b	'Chunky Options',0

;-----------------------------------------------------------------------------
CH_loadmsg:	dc.b	'Reading 8 Bit Chunky Image!',0
