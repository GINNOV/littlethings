;===========================================================================
;
;		Test für einen Bitmap loader
;		(c) 1995 ,Frank Pagels (Crazy Copper) /DFT
;
;		15.03.95

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
		
BI_RGB		=	0
BI_RLE8		=	1
BI_RLE4		=	2


		LOADERHEADER BM_NODE

		dc.b	'$VER: Windows Bitmap loader module 1.15 (17.05.97)',0
	even
;---------------------------------------------------------------------------
BM_NODE:
		dc.l	0,0
		dc.b	0,0
		dc.l	BM_name
		dc.l	BM_load
		dc.b	'BMPL'
		dc.b	'EXTR'	;for extern loader
		dc.l	0
		dc.l	BM_Tags
BM_name:
		dc.b	'BMP',0
	even
;---------------------------------------------------------------------------

BM_Tags:
		dc.l	APT_Creator,BM_Creator
		dc.l	APT_Version,5
		dc.l	APT_Info,BM_Info
		dc.l	APT_Autoload,1
		dc.l	0

BM_Creator:
		dc.b	'(c) 1995/96 Frank Pagels /DEFECT Softworks',0
	even
BM_Info:
		dc.b	'Windows bitmap loader',10,10
		dc.b	'Loads Windows Bitmaps and OS/2 Bitmaps. RLE4 and',10
		dc.b	'RLE8 are supported, but RLE8 not really tested.',10
		dc.b	'Also 24 Bit is supportet!',0

	even
;---------------------------------------------------------------------------

BM_puffermem:	dc.l	0
BM_filesize:	dc.l	0
BM_bfoffsetbits:dc.l	0
BM_biPlanes:	dc.w	0	;must be 1
BM_biBitCount:	dc.w	0	;1,4,8 or 24
BM_biCompression:	dc.l	0
BM_biSizeImage:		dc.l	0	;größe der Bitmap
BM_biXPelsPerMeter:	dc.l	0
BM_biYPelsPerMeter:	dc.l	0
BM_biClrUsed:	dc.l	0	;anzahl der benutzten Farben, 0 = alle
BM_biClrImportant:	dc.l	0
BM_Linemem:	dc.l	0
BM_24:		dc.b	0
		dc.b	0
		
BM_Spaces	= APG_Free3

;---------------------------------------------------------------------------
BM_load
		move.l	APG_FileSize(a5),d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		lea	BM_puffermem(pc),a0
		move.l	d0,(a0)
		bne	.ok
		moveq	#-4,d3		;no mem !
		rts
.ok:		
		move.l	APG_Dosbase(a5),a6
		move.l	APG_Filehandle(a5),d1
		move.l	BM_puffermem(pc),d2
		moveq	#2,d3
		jsr	_LVORead(a6)

;werte Bitmap Header aus

		move.l	BM_puffermem(pc),a0
		move.w	(a0)+,d0
		cmp.w	#'BM',d0
		beq	BM_ok

		move.l	BM_puffermem(pc),d0
		beq	.w
		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
.w		clr.l	BM_Puffermem

		moveq	#-3,d3		;File nicht erkannt
		rts

BM_ok:
		jsr	APR_OpenProcess(a5)

		move.l	APG_Dosbase(a5),a6
		move.l	APG_Filehandle(a5),d1
		move.l	BM_puffermem(pc),d2
		move.l	APG_FileSize(a5),d3
		subq.l	#2,d3
		jsr	_LVORead(a6)

		move.l	BM_Puffermem(pc),a0
		bsr	holeDword

		lea	BM_filesize(pc),a1
		move.l	d0,(a1)
		move.l	(a0)+,d0	;reserved, must be zero

		bsr	holeDword

		lea	BM_bfoffsetbits(pc),a1
		move.l	d0,(a1)

		bsr	holeDword
		move.w	d1,d7

		sf	APG_Mark1(a5)
		cmp.w	#12,d0
		bne	.ok
		st	APG_Mark1(a5)	;OS/2 Bitmap

.ok:
		tst.b	APG_Mark1(a5)
		beq	.win
		bsr	holeword
		move.l	d1,d0
		bra	.w
.win:		bsr	holeDword
.w:		move.w	d0,APG_ImageWidth(a5)

		tst.b	APG_Mark1(a5)
		beq	.win1
		bsr	holeword
		move.l	d1,d0
		lea	BM_biClrUsed(pc),a1
		clr.l	(a1)
		bra	.w1
.win1:		bsr	holeDword
.w1		move.w	d0,APG_ImageHeight(a5)

		bsr	holeword
		lea	BM_biPlanes(pc),a1
		move.w	d1,(a1)

		sf	BM_24
		
;---- checke ob 24 Bit -----

		bsr	holeword
		lea	BM_biBitCount(pc),a1
		cmp.w	#24,d1
		bne	.pok

		st	BM_24		;es wird ein 24Bit Image geladen

		moveq	#0,d0
		move.w	APG_ImageWidth(a5),d0
		mulu	#3,d0
		move.l	d0,d3
		addq.l	#3,d0
		lsr.l	#2,d0
		lsl.l	#2,d0
		move.l	d0,d2
		sub.l	d3,d2
		move.w	d2,BM_Spaces(a5)

		move.w	APG_ImageWidth(a5),d0
		add.w	#15,d0
		lsr.w	#4,d0
		add.w	d0,d0
		move.l	d0,d2
		move.l	d0,APG_ByteWidth(a5)
		moveq	#0,d1
		move.w	APG_ImageHeight(a5),d1
		mulu	d1,d0
		move.l	d0,APG_Oneplanesize(a5)

		move.b	#24,APG_Planes(a5)	;erma für FindMonitor

		move.l	d2,d0
		moveq	#0,d1
		move.w	APG_ImageHeight(a5),d1
		jsr	APR_InitRenderMem(a5)	;Init Speicher für RGB Puffer

		tst.l	d0
		bne	.memok

		move.l	BM_puffermem(pc),d0
		beq	.wm
		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
		clr.l	BM_Puffermem
.wm
		moveq	#APLE_NOMEM,d3
		rts
;		jmp	APR_ClearProcess(a5)

;-------------------------------------------------------

.pok:		move.w	d1,(a1)

.memok:
		moveq	#0,d0
		move.w	APG_ImageHeight(a5),d0
		lea	loadbmpmsg(pc),a1
		jsr	APR_InitProcess(a5)

		lea	BM_biCompression(pc),a1
		clr.l	(a1)

		tst.b	APG_Mark1(a5)
		bne	readcoltab

		bsr	holeDword
		move.l	d0,(a1)

		bsr	holeDword
		lea	BM_biSizeImage(pc),a1
		move.l	d0,(a1)

		bsr	holeDword
		lea	BM_biXPelsPerMeter(pc),a1
		move.l	d0,(a1)
		bsr	holeDword
		lea	BM_biYPelsPerMeter(pc),a1
		move.l	d0,(a1)

		bsr	holeDword

		lea	BM_biClrUsed(pc),a1
		ext.l	d0
		move.l	d0,(a1)

		cmp.w	#$24,d7
		beq	readcoltab
		
		bsr	holeDword
		ext.l	d0
		lea	BM_biClrImportant(pc),a1
		move.l	d0,(a1)
				
;lese Colortable ein
readcoltab:
		tst.b	BM_24
		bne	BM_InitBitmap	;es gibt keine Colortab!

		moveq	#0,d0
		move.w	BM_biBitCount(pc),d0
		moveq	#1,d1
		lsl.l	d0,d1
		move.w	d1,APG_ColorCount(a5)

		move.l	BM_biClrUsed(pc),d1
		tst.l	d1
		beq	.ok		;alle farben werden benutzt

		move.w	d1,APG_ColorCount(a5)

		moveq	#0,d0		;check Planes
.wq:		lsr.l	#1,d1
		bcs	.ok
		addq.l	#1,d0
		bra	.wq
.ok:
		move.b	d0,APG_Planes(a5)

		move.w	APG_ColorCount(a5),d7
		lea	APG_Farbtab8(a5),a1
		lea	APG_Farbtab4(a5),a2
		move.w	d7,(a1)+
		clr.w	(a1)+
		subq.w	#1,d7
.nc:		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.b	(a0)+,d0	;B
		move.b	(a0)+,d1	;G
		move.b	(a0)+,d2	;R
	
		tst.b	APG_Mark1(a5)	;OS/2
		bne	.w
		addq.l	#1,a0		;reserved überlesen
.w:
		move.l	d2,d3
		lsl.l	#4,d3
		lsl.l	#8,d2
		swap	d2
		move.l	d2,(a1)+
		move.b	d1,d3
		lsl.l	#8,d1
		swap	d1
		move.l	d1,(a1)+
		move.l	d0,d1
		lsr.b	#4,d1
		and.w	#$ff0,d3
		or.b	d1,d3
		move.w	d3,(a2)+
		lsl.l	#8,d0
		swap	d0
		move.l	d0,(a1)+
		dbra	d7,.nc
		clr.l	(a1)+

BM_InitBitmap:
		move.l	a0,-(a7)
;erstelle bitmap

		move.l	APG_FindMonitor(a5),a6
		jsr	(a6)
		
		tst.b	BM_24
		bne	.w24

		lea	APG_PicMap(a5),a0	
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.b	APG_Planes(a5),d0
		move.w	APG_ImageWidth(a5),d1
		move.w	APG_ImageHeight(a5),d2	;höhe
		move.l	APG_Gfxbase(a5),a6
		jsr	_LVOinitbitmap(a6)

.w24		moveq	#0,d0
		move.w	APG_ImageWidth(a5),d0
		add.w	#15,d0
		lsr.w	#4,d0
		add.w	d0,d0
		move.l	d0,APG_ByteWidth(a5)
		move.w	APG_ImageHeight(a5),d1
		mulu	d1,d0
		move.l	d0,APG_Oneplanesize(a5)

		tst.b	BM_24
		bne	BM_Read24

		moveq	#0,d1
		moveq	#0,d7
		move.b	APG_Planes(a5),d7	
		subq.w	#1,d7
.next:
		add.l	d0,d1		;Simuliert mulu.l Befehl
		dbra	d7,.next

		move.l	d1,d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,APG_Picmem(a5)
		bne	.memok
		move.l	BM_puffermem(pc),d0
		beq	.wm
		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
		clr.l	BM_puffermem
.wm		moveq	#APLE_NOMEM,d3
		rts
;		jmp	APR_ClearProcess(a5)

.memok:
		moveq	#0,d0		;Speicher für eine Zeile besorgen
		move.w	APG_ImageWidth(a5),d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		jsr	_LVOAllocVec(a6)
		lea	BM_linemem(pc),a0
		move.l	d0,(a0)

		move.l	APG_Picmem(a5),d0
		lea	APG_Picmap+8(a5),a0
		moveq	#0,d7
		move.b	APG_Planes(a5),d7
		subq.w	#1,d7
.npl		move.l	d0,(a0)+
		add.l	APG_Oneplanesize(a5),d0
		dbra	d7,.npl
;-------------------------------------------------------------------
;lese Bitmap daten ein

		move.l	(a7)+,a0

		move.w	APG_ColorCount(a5),d1
		lsl.l	#2,d1
		add.l	#54,d1
		move.l	BM_bfoffsetbits(pc),d0
		cmp.l	d1,d0
		blo	.sv	;superview ???
		move.l	BM_puffermem(pc),a0
		add.l	d0,a0
.sv		
		moveq	#0,d0
		move.w	APG_ImageHeight(a5),APG_Free2(a5) ;yStart
		subq.w	#1,APG_Free2(a5)

		lea	BM_bicompression(pc),a1
		cmp.l	#BI_RLE4,(a1)
		beq	BM_readrle4

		lea	BM_biBitCount(pc),a1
		cmp.w	#4,(a1)
		beq	BM_read4
		
		cmp.w	#1,(a1)
		beq	BM_read1
		
		moveq	#0,d6
		move.w	APG_ImageHeight(a5),d6
		subq.l	#1,d6
		moveq	#0,d5
		move.b	APG_Planes(a5),d5
	;	move.l	(a7)+,a0
		moveq	#0,d7
		move.w	APG_ImageWidth(a5),d7
		addq.w	#3,d7
		lsr.w	#2,d7
		lsl.w	#2,d7
		move.l	d7,APG_Free1(a5)
.nl:
		move.l	APG_Free1(a5),d7
		subq.l	#1,d7
		move.l	BM_Linemem(pc),a1
.np:		move.b	(a0)+,d0
		move.b	d0,(a1)+
		dbra	d7,.np
		bsr	BM_copyline
		dbra	d6,.nl
		move.w	#1,APG_LoadFlag(a5)
		bra	BM_schluss

BM_read1:
		moveq	#0,d6
		move.w	APG_ImageHeight(a5),d6
		subq.l	#1,d6
		moveq	#0,d7
		move.w	APG_ImageWidth(a5),d7
		move.l	d7,d5
		add.w	#15,d7
		lsr.w	#4,d7
		add.w	d7,d7
		move.l	d7,APG_Free1(a5)
	;	move.l	(a7)+,a0
.nl:
		move.l	APG_Free1(a5),d7
		subq.l	#1,d7
		move.l	APG_ByteWidth(a5),d5
		mulu	d6,d5
		move.l	APG_Picmem(a5),a1
		add.l	d5,a1
.np:		move.b	(a0)+,(a1)+
		dbra	d7,.np
		dbra	d6,.nl
		move.w	#1,APG_LoadFlag(a5)
		bra	BM_schluss

BM_read4:
		moveq	#0,d6
		move.w	APG_ImageHeight(a5),d6
		subq.l	#1,d6
		moveq	#0,d5
		move.b	APG_Planes(a5),d5
		moveq	#0,d7
		move.w	APG_ImageWidth(a5),d7
		addq.w	#3,d7
		lsr.w	#2,d7
		add.w	d7,d7
		move.l	d7,APG_Free1(a5)
	;	move.l	(a7)+,a0
.nl:
		move.l	APG_Free1(a5),d7
		subq.l	#1,d7
		move.l	BM_Linemem(pc),a1
.np:		move.b	(a0)+,d0
		move.b	d0,d1
		lsr.b	#4,d0
		move.b	d0,(a1)+
		and.b	#$0f,d1
		move.b	d1,(a1)+
		dbra	d7,.np
		bsr	BM_copyline
		dbra	d6,.nl
		move.w	#1,APG_LoadFlag(a5)
		bra	BM_schluss

BM_readrle4:
	;	move.l	(a7)+,a0
		move.w	APG_Imageheight(a5),d7
		subq.l	#1,d7
		move.b	APG_Planes(a5),d5
rle4_nl:
		move.l	BM_Linemem(pc),a1
rle4_newbyte:	moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.b	(a0)+,d0
		tst.b	d0
		beq	rle4_null
		cmp.b	#02,d0
		beq	BM_schluss1
		move.b	(a0)+,d1
		move.b	d1,d2
		and.b	#$0f,d1		;lower Bits
		lsr.b	#4,d2		;higher Bits
.copy:		move.b	d2,(a1)+
		subq.l	#1,d0
		beq	rle4_newbyte
		move.b	d1,(a1)+				
		subq.l	#1,d0
		beq	rle4_newbyte
		bra	.copy
rle4_null:
		move.b	(a0)+,d0
		tst.b	d0
		beq	rle4_endofline
		cmp.b	#1,d0
		beq	BM_schluss1		;bm_view ????
.copy:		move.b	(a0)+,d1
		move.b	d1,d2
		and.b	#$0f,d1
		lsr.b	#4,d2
		move.b	d2,(a1)+
		subq.l	#1,d0
		beq	rle4_testword
		move.b	d1,(a1)+
		subq.l	#1,d0
		beq	rle4_testword
		bra	.copy

rle4_testword:
		move.l	a0,d0		;teste ob wir auf einer Wordgrenze
		lsr.l	#1,d0		;liegen
		lsl.l	#1,d0
		cmp.l	a0,d0
		beq	rle4_newbyte
		addq.l	#1,a0		;korriegieren
		bra	rle4_newbyte

rle4_endofline:
		bsr	BM_copyline
		dbra	d7,rle4_nl
		bra	BM_schluss1

BM_readrle8:
	;	move.l	(a7)+,a0
		move.w	APG_Imageheight(a5),d7
		subq.l	#1,d7
		move.b	APG_Planes(a5),d5
rle8_nl:
		move.l	BM_Linemem(pc),a1
rle8_newbyte:	moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.b	(a0)+,d0
		tst.b	d0
		beq	rle8_null
		cmp.b	#02,d0
		beq	BM_schluss1
		move.b	(a0)+,d1
.copy:		move.b	d1,(a1)+
		subq.l	#1,d0
		beq	rle8_newbyte
		bra	.copy
rle8_null:
		move.b	(a0)+,d0
		tst.b	d0
		beq	rle8_endofline
		cmp.b	#1,d0
		beq	BM_schluss1		;bm_view ????
.copy:		move.b	(a0)+,d1
		move.b	d1,(a1)+
		subq.l	#1,d0
		beq	rle4_testword
		bra	.copy

rle8_endofline:
		bsr	BM_copyline
		dbra	d7,rle8_nl
		bra	BM_Schluss1

;-----------------------------------------------------------------------------
BM_Read24:
		move.l	(a7)+,a0
		
		move.b	#24,APG_Planes(a5)

		move.l	APG_ByteWidth(a5),d7
		lsl.l	#3+2,d7			;Größe einer Zeile

		moveq	#0,d6
		move.w	APG_ImageHeight(a5),d6
		subq.w	#1,d6

.nextline:
		move.l	APG_rndr_rgb(a5),a1
		move.l	d6,d4
		mulu.w	d7,d4			;Offset

		add.l	d4,a1		;zeilen anfang

		moveq	#0,d5
		move.w	APG_Imagewidth(a5),d5
		subq.w	#1,d5

.nch:		moveq	#0,d0
		move.b	(a0)+,d0	;B
		ror.l	#8,d0
		move.b	(a0)+,d0	;G
		ror.l	#8,d0
		move.b	(a0)+,d0	;R
		swap	d0
		move.l	d0,(a1)+
				
		dbra	d5,.nch

		move.w	BM_Spaces(a5),d5
		add.l	d5,a0

		jsr	APR_DoProcess(a5)
		tst.l	d0
		beq	BMP_Stop

		dbra	d6,.nextline

		st	APG_RenderFlag(a5)

;-----------------------------------------------------------------------------
BM_schluss1:
		move.w	#1,APG_LoadFlag(a5)
		moveq	#APLE_OK,d3
BM_schluss
		
		move.l	4,a6
		move.l	BM_linemem(pc),d0
		beq	.w
		move.l	d0,a1
		jsr	_LVOFreeVec(a6)
		clr.l	BM_linemem
.w		
		move.l	BM_puffermem(pc),d0
		beq	BM_wech
		move.l	d0,a1
		jsr	_LVOFreeVec(a6)		
		clr.l	BM_Puffermem
BM_wech:
		rts
;		jmp	APR_ClearProcess(a5)

BMP_Stop:
		move.l	4.w,a6
		move.l	APG_rndr_rendermem(a5),d0
		beq	.w
		move.l	d0,a1
		jsr	_LVOFreeVec(a6)
		clr.l	APG_rndr_rendermem(a5)
.w
		move.l	APG_Picmem(a5),d0
		beq	.w1
		move.l	d0,a1
		jsr	_LVOFreeVec(a6)
		clr.l	APG_Picmem(a5)
.w1		moveq	#APLE_ABORT,d3
		bra	BM_schluss


BM_copyline:
		movem.l	d0-a6,-(a7)

		move.l	BM_Linemem(pc),a0
		lea	APG_PicMap(a5),a1
		sub.l	a2,a2
		moveq	#0,d0
		moveq	#0,d1
		move.l	APG_ByteWidth(a5),d2
		lsl.l	#3,d2
		moveq	#1,d3		;eine Zeile
		moveq	#0,d4
		move.w	APG_Free2(a5),d5	;yStart
		move.l	APG_Renderbase(a5),a6
		jsr	_LVOChunky2BitmapA(a6)

		subq.w	#1,APG_Free2(a5)	;yStart
		jsr	APR_DoProcess(a5)
		tst.l	d0
		beq	.wech

		movem.l	(a7)+,d0-a6
		rts
.wech:
		movem.l	(a7)+,d0-a6
		addq.l	#4,a7
		bra	BMP_Stop
		
holeDword:
		moveq	#0,d0
		move.b	(a0)+,d0
		move.b	(a0)+,d1
		lsl.l	#8,d1
		move.b	d0,d1
		moveq	#0,d0
		move.b	(a0)+,d0
		move.b	(a0)+,d2
		lsl.l	#8,d2
		move.b	d0,d2
		swap	d0
		move.w	d1,d0
		rts

holeword:
		moveq	#0,d0
		move.b	(a0)+,d0
		move.b	(a0)+,d1
		lsl.l	#8,d1
		move.b	d0,d1
		rts

		
loadbmpmsg:	dc.b	'Load BMP Image!',0

