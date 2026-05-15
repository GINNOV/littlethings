;APS00000A6CF8266217F8266217F8266217F8266217F8266217F8266217F8266217F82662173B3D2FFB
;===========================================================================
;
;		PNM Loader
;		(c) 1998 ,Frank Pagels (Crazy Copper) /DFT
;
;		22.08.98

		incdir 	include:

		include	exec/exec_lib.i
		include	exec/lists.i
		include	exec/memory.i
		include intuition/intuition_lib.i
		include	libraries/wb_lib.i
		include	graphics/graphics_lib.i
		Include utility/tagitem.i
		include	dos/dos.i		
		include	dos/dos_lib.i		

		include misc/artpro.i
		include render/render_lib.i
		
		LOADERHEADER pnm_NODE

		dc.b	'$VER: PNM loader module 1.0 (22.08.98)',0
	even
;---------------------------------------------------------------------------
pnm_NODE:
		dc.l	0,0
		dc.b	0,0
		dc.l	pnm_name
		dc.l	pnm_load
		dc.b	'PNML'		;Loaderkennung für ArtPRO
		dc.b	'EXTR'		;for extern loader
		dc.l	0
		dc.l	pnm_Tags
pnm_name:
		dc.b	'PNM',0
	even
;---------------------------------------------------------------------------

pnm_Tags:
		dc.l	APT_Creator,pnm_Creator
		dc.l	APT_Version,5
		dc.l	APT_Info,pnm_Info
		dc.l	APT_Autoload,1
		dc.l	0

pnm_Creator:
		dc.b	'(c) 1998 Frank Pagels /DEFECT SoftWorks',0
	even
pnm_Info:
		dc.b	'PNM loader',10,10
		dc.b	'Loads PNM pictures.',0
	even
;----------------------------------------------------------------------------


pnm_format:	dc.b	0
	even

pnm_linesize	=	APG_Free1

pnm_puffermem:	dc.l	0
pnm_Chunkybreite: dc.w	0
pnm_Linemem:	dc.l	0
pnm_Version:	dc.w	0
pnm_Planes:	dc.w	0
pnm_Planes1:	dc.w	0
pnm_24:		dc.b	0
		dc.b	0
;---------------------------------------------------------------------------
pnm_load
		move.l	APG_Dosbase(a5),a6
		move.l	APG_Filehandle(a5),d1
		move.l	#pnm_puffer,d2
		moveq	#3,d3
		jsr	_LVORead(a6)
		tst.l	d0
		bpl	.fok
		move.l	#APLE_ERROR,d3
		rts
.fok:
		sf	pnm_format
		lea	pnm_puffer(pc),a0
		move.w	(a0)+,d0
		cmp.w	#'P5',d0
		beq	pnm_formatok
		cmp.w	#'P6',d0
		beq	.p6
.wech:		move.l	#APLE_UNKNOWN,d3
		rts		
.p6
		st	pnm_format
pnm_formatok
		cmp.b	#$a,(a0)+
		bne	pnm_load\.wech
;read size
		bsr	pnm_holezahl
		move.w	d0,APG_ImageWidth(a5)
		add.w	#15,d0
		lsr.w	#4,d0
		add.l	d0,d0
		move.l	d0,APG_Bytewidth(a5)
		bsr	pnm_holezahl
		move.w	d0,APG_ImageHeight(a5)
		bsr	pnm_holezahl

		jsr	apr_dummy(a5)

		moveq	#0,d0
		move.w	APG_Imagewidth(a5),d0
		tst.b	pnm_format
		beq	.w
		mulu	#3,d0
.w
		move.l	d0,pnm_linesize(a5)
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		lea	pnm_puffermem(pc),a0
		move.l	d0,(a0)
		bne	.ok
		moveq	#-4,d3		;no mem !
		rts
.ok:		

;lade bild ein

		move.l	APG_ByteWidth(a5),d0
		move.w	APG_ImageHeight(a5),d1
		jsr	APR_InitRenderMem(a5)		
		tst.l	d0
		bne	pnm_loaddata
		move.l	#APLE_NOMEM,d3
		rts
pnm_loaddata:

		jsr	APR_OpenProcess(a5)
		moveq	#0,d0
		move.w	APG_ImageHeight(a5),d0
		lea	loadmsg(pc),a1
		jsr	APR_InitProcess(a5)

		move.w	APG_ImageHeight(a5),d7
		sub.w	#1,d7
		moveq	#0,d6
pnm_newline:
		moveq	#0,d5
		move.l	APG_ByteWidth(a5),d5
		lsl.l	#3+2,d5
		move.l	APG_Dosbase(a5),a6
		move.l	APG_Filehandle(a5),d1
		move.l	pnm_puffermem(pc),d2
		move.l	pnm_linesize(a5),d3
		jsr	_LVORead(a6)
		move.l	APG_rndr_rgb(a5),a0
		move.l	d6,d0
		mulu	d5,d0
		add.l	d0,a0

		move.l	pnm_puffermem(pc),a1
		move.w	APG_ImageWidth(a5),d4
		subq.w	#1,d4

		tst.b	pnm_format
		beq	.grau
.nc		clr.b	(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		dbra	d4,.nc
		bra	.we		
.grau:		
		move.b	(a1)+,d0
		clr.b	(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		dbra	d4,.grau
.we:
		addq.l	#1,d6
		jsr	APR_DoProcess(a5)
		dbra	d7,pnm_newline

		move.l	APG_ByteWidth(a5),d0
		move.w	APG_ImageHeight(a5),d1
		mulu	d1,d0
		move.l	d0,APG_Oneplanesize(a5)

		move.b	#24,APG_Planes(a5)
		move.l	APG_FindMonitor(a5),a6
		jsr	(a6)

		move.w	#1,APG_LoadFlag(a5)
		st	APG_RenderFlag(a5)

		move.l	pnm_puffermem(pc),a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)

		move.l	#APLE_OK,d3
		rts



pnm_Stop:
		moveq	#APLE_ABORT,d3
		move.l	4.w,a6
		move.l	APG_rndr_rendermem(a5),d0
		beq	.w
		move.l	d0,a1
		jsr	_LVOFreevec(a6)
		clr.l	APG_rndr_rendermem(a5)
.w		move.l	APG_Picmem(a5),d0
	;	beq	pnm_schluss1
		move.l	d0,a1
		jsr	_LVOFreeVec(a6)
		clr.l	APG_Picmem(a5)
	;	bra	pnm_schluss1

;---------------------------------------------------------------------

pnm_holezahl:
		move.l	APG_Dosbase(a5),a6
		lea	pnm_puffer(pc),a3
		move.b	#-1,-(a7)
.nz:
		move.l	APG_Filehandle(a5),d1
		move.l	#pnm_puffer,d2
		moveq	#1,d3
		jsr	_LVORead(a6)
		move.b	(a3),d0
		cmp.b	#$a,d0
		beq	.endz
		move.b	d0,-(a7)
		bra	.nz
.endz:
		moveq	#1,d0
		moveq	#0,d2
.new:		move.b	(a7)+,d1
		bmi	.voll
		sub.b	#$30,d1
		mulu	d0,d1
		add.l	d1,d2
		mulu	#10,d0
		bra	.new
.voll:		
		move.l	d2,d0
		rts

loadmsg:
		dc.b	'Loading PNM image!',0


pnm_puffer:	ds.b	32
