;
; This file is part of ArtPRO.
; Copyright (C) 1996-2018 Frank Pagels
;
; ArtPRO is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; ArtPRO is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with ArtPRO.  If not, see <http://www.gnu.org/licenses/>.
;

;APS0007874300012DE000007DFC00000000000000000000000000000000000000000000000000000000
; noch zu machen: 
;
; bei save 24 und HAM bilder aufpassen
; bei load mit datatype pic ins fast kopieren
; crackschutz --> Programm löscht sich selber nach ner weile
; crackschutz weiter verbessern, an den markierten Stellen !!!
; Palette save 0RGB RGB RGB0 einbauen
;
;
; Later Stuff:
;
; Icon Saver
; Palette bei Loadraw behalten
; IFF depacken beim laden
				
;==========================================================================
;
;     ArtPRO
;     IFF-Converter and Image-Processor
;
;     (c) Copyright 1993-97 Defect SoftWorks
;     All Rights reserved
;
;     idea, conception & coding  : Frank Pagels /DFT
;     some basic routines,
;     suggestions and GUI design : Timm S. Müller /TEK
;     some help	and suggestions	 : Buggs /DFT
;
;     Begin Work: 19.09.93  (original von 13.06.93 neu überarbeitet)
;
;
*-- Das wurde gemacht --*
;bug in pnm loader -> speicher crash


executable	= 0
final		= 1
needkey		= 1

;bei final folgene codes eintragen
;lastreqcheck --> lastreqcode  ,checksumme bei checkloader, test bei setmodi
				;colorbias (pc_copyline)
;lastreqcheck1 -- lastreqcode1  ;checksumme checksaver  ,setmode,changemoni
							;loadbodychunk
Version		macro
		dc.b	'1.20b'
		endm


;date		macro
;		dc.b	'03.06.98'
;		endm

ver		= '1.11'

		incdir 	include:

		include	exec/exec_lib.i
		include	rexx/storage.i
		include	exec/lists.i
		include	exec/memory.i
		include	exec/execbase.i
		include intuition/intuition_lib.i
		include	intuition/intuition.i
		include libraries/gadtools_lib.i
		include libraries/gadtools.i
		include libraries/dos_lib.i
		include	libraries/reqtools.i
		include	libraries/reqtools_lib.i
		include	libraries/wb_lib.i
		include	libraries/mathffp_lib.i
		include	libraries/mathtrans_lib.i
		include	libraries/diskfont_lib.i
		include	libraries/icon_lib.i
		include	graphics/graphics_lib.i
		include	graphics/displayinfo.i
		include	graphics/scale.i
		include	graphics/gfxbase.i
		include utility/tagitem.i
		include utility/utility_lib.i
		include	dos/dos.i		
		include	devices/inputevent.i
		include	workbench/workbench.i
		include	workbench/startup.i
		include	datatypes/datatypes.i
		include	datatypes/datatypesclass.i
		include datatypes/pictureclass.i
		include	libraries/datatypes_lib.i
		include	misc/artpro.i
		include	render/render.i
		include	render/render_lib.i
		include	render/renderhooks.i
		include	guigfx/guigfx.i
		include	guigfx/guigfx_lib.i
		
		include	libraries/cybergraphics.i
		include	libraries/cybergraphics_lib.i


mainwinLeft	=	0
mainwinTop	=	0
mainwinWidth	=	624
mainwinHeight	=	242

prefswinLeft	=	0
prefswinTop	=	0
prefswinWidth	=	432
prefswinHeight	=	135

choosewinLeft	=	20
choosewinTop	=	80
choosewinWidth	=	279
choosewinHeight	=	137+11

newchoosewinLeft	=	40
newchoosewinLeft1	=	340
newchoosewinTop		=	80
newchoosewinWidth	=	260
newchoosewinHeight	=	157-8

nc_choosewinLeft	=	314
nc_choosewinLeft1	=	105
nc_choosewinTop		=	80
nc_choosewinWidth	=	220
nc_choosewinHeight	=	115

screenwinLeft	=	170
screenwinTop	=	70
screenwinWidth	=	320
screenwinHeight	=	99

imagewinLeft	=	180
imagewinTop	=	95
imagewinWidth	=	216
imagewinHeight	=	89

linkwinLeft	=	170
linkwinTop	=	90
linkwinWidth	=	220
linkwinHeight	=	74

spritewinLeft	=	170
spritewinTop	=	90
spritewinWidth	=	210
spritewinHeight	=	86

logoLeft	=	430
logoTop		=	5
logoWidth	=	170
logoHeight	=	75

labelwinLeft	=	170
labelwinTop	=	90
labelwinWidth	=	228
labelwinHeight	=	55

MAXLOGOWIDTH	=	400

start:
		bra.b	begin

		dc.b	'$VER: ArtPRO '
		version
		dc.b	' ('
		%getdate
		dc.b	')',32
		dc.b	'by Frank (Copper) Pagels / Defect SoftWorks',0
	even
;=============================================================================
begin:
		
		lea	daten,a5
		bsr.w	clearbss

	ifeq	executable
		bra.b	fromcli
	endc

		clr.l	WBMessage(a5)
		move.l	4.w,a6
		sub.l	a1,a1
		jsr	_LVOfindtask(a6)
		move.l	d0,a4
		tst.l	$ac(a4)
		bne.s	fromcli

		lea	$5c(a4),a0
		jsr	_LVOwaitport(a6)
		lea	$5c(a4),a0
		jsr	_LVOgetmsg(a6)
		move.l	d0,-(sp)

		move.l	d0,WBMessage(a5)

		bsr.b	fromcli
		move.l	4.w,a6
		jsr	_LVOforbid(a6)

		moveq	#0,d0
 		move.l	(sp)+,a1
		jmp	_LVOreplymsg(a6)
fromcli:
;	Test auf >020

		move.l	4.w,a6
		moveq	#0,d0
		btst.b	#1,$129(a6)	;Maybe a 68020
		bne.b	prozok		;wir haben einen 020'er oder besser

;----------------------------------------------------------------------------
		lea	doslibname(pc),a1
		moveq	#0,d0
		jsr	_LVOopenlibrary(a6)
		move.l	d0,a6
		lea	conwin2(pc),a0
		move.l	a0,d1
		move.l	#1005,d2
		jsr	_LVOopen(a6)
		tst.l	d0
		beq.s	.w	;Nicht einmal AUSGABE auf CON: funtioniert
		move.l	d0,d6
		move.l	d0,d1

		lea	conout2(pc),a0
		move.l	a0,d2
		moveq	#conlen2,d3
		jsr	_LVOwrite(a6)	;Ausgabe "Needs Amiga OS2.04 or higher"
		move.l	#250,d1		;~5 Sekunden warten
		jsr	_LVOdelay(a6)

		move.l	d6,d1		;Con schließen
		jsr	_LVOclose(a6)
.w:
		move.l	a6,a1
		move.l	4.w,a6
		jsr	_LVOCloselibrary(a6)
		bra.w	aus

;---------------------------------------------------------------------
prozok:
		bsr.w	checkkick
		tst	d0
		bne.w	aus		;Falsche Kick
		bsr.w	openlibs
		tst	d0
		bne.w	aus		;keine ReqToolslib gefunden

		move.l	dosbase(a5),a6
		jsr	_LVOGetProgramDir(a6)
		move.l	d0,ProgramDirlock(a5)

		bsr.w	checkaga

		bsr.w	initreq			;Init ReqT Struck

;-----------------------------------------------------------------

		move.l	#packcolor,operator(a5)

;------------------------------------------------------------------

		tst.b	availdatatype(a5)
		bne.b	.DTOk

		lea	gloadreqNodes2(pc),a1
		remove
.DTOk:

		bsr.w	checkloader
		bsr.w	checksaver
		bsr	checkoperator
		
		lea	gloadreqList(pc),a0
	;	bsr	sortnodes

		lea	gsavereqList(pc),a0
	;	bsr	sortnodes
		
		lea	goperatorList(pc),a0
	;	bsr	sortnodes

		bsr.w	initloadersaver	;Init einige Loader und saver 
					;falls es keine Prefs gibt
		bsr.w	checktooltypes

		move.l	_loadername(pc),a0
;		lea	loaderlistname(pc),a0
		move.l	#nc_selectload,loadsavemark(a5)
		bsr.w	loadlistconf

		move.l	_savername(pc),a0
;		lea	saverlistname(pc),a0
		move.l	#nc_selectsaver,loadsavemark(a5)
		bsr.w	loadlistconf

		move.l	_operatorname(pc),a0
		move.l	#nc_selectoperator,loadsavemark(a5)
		bsr.w	loadlistconf

		jsr	checkwbsize	;ermittle Workbench Größe
		bsr.w	checkprefs	;lade und init Preferenz
	;	tst.b	d0
	;	bne.w	.nopub	     ;WB daten konnten nicht ermittelt werden

.nopub:
		lea	chunkylogo,a0
		lea	logopuffer,a1
		bsr.w	MashUnpack		;entpacke logo

		jsr	setupscreen		;öffne Screen
		tst.l	d0
		beq.b	screenok
		bra.w	ende			;hat nicht geklappt

screenok:
		move.l	scr(a5),d0
		move.l	d0,rt_screen
		move.l	d0,rt_screen1
		sub.l	#5461,execbasepuffer(a5)
						
		moveq	#0,d0
		move.l	scr(a5),a0
		move.l	40(a0),a0
		move.w	4(a0),d0		;Fonthöhe
		addq.l	#3,d0
		move.w	d0,zoomheight
		move.w	d0,biaszoomheight
		move.w	d0,cutzoomheight
		
		clr.b	fontallready(a5)
		lea	MainwinWindowTags,a0
		move.l	a0,windowtaglist(a5)
		lea	MainwinWG+4,a0
		move.l	a0,gadgets(a5)
		lea	MainwinSC+4,a0
		move.l	a0,winscreen(a5)
		lea	MainwinWnd(a5),a0
		move.l	a0,window(a5)
		lea	MainwinGlist(a5),a0
		move.l	a0,Glist(a5)
		lea	MainwinNgads,a0
		move.l	a0,NGads(a5)
		lea	MainwinGTypes,a0
		move.l	a0,GTypes(a5)
		lea	MainwinGadgets,a0
		move.l	a0,WinGadgets(a5)
		move.w	#Mainwin_CNT,win_CNT(a5)
		lea	MainwinGtags,a0
		move.l	a0,windowtags(a5)
		move.l	scr(a5),screenbase(a5)

		move.w	#mainwinWidth,WinWidth(a5)
		move.w	#mainwinHeight,WinHeight(a5)
		move.w	#mainwinTop,WinTop(a5)
		move.w	#mainwinLeft,WinLeft(a5)
		lea	MainWinL,a0
		move.l	a0,WinL(a5)
		lea	MainWinT,a0
		move.l	a0,WinT(a5)
		lea	MainWinW,a0
		move.l	a0,WinW(a5)
		lea	MainWinH,a0
		move.l	a0,WinH(a5)

		move.w	mainx(a5),d0
		move.w	mainy(a5),d1
		add.w	#mainwinLeft,d0
		add.w	#mainwinTop,d1

		move.w	d1,WinTop(a5)
		move.w	d0,WinLeft(a5)

		jsr	openwindowF	;öffne Mainwindow
		tst.l	d0
		beq.b	winok
		bra.w	fail			;hat nicht geklappt
winok:
		jsr	mainwinRender

		tst.b	customscr(a5)
		beq.b	.nocust
		jsr	makescreencolors
.nocust:
		move.l	mainwinwnd(a5),a0
		move.l	a0,rt_window
		move.l	a0,rt_window1
		
		move.l	50(a0),mainRastport(a5) ;Rastport sichern
		move.l 	mainwinWnd(a5),a0
		move.l  IntBase(a5),a6
		jsr     _LVOViewPortAddress(a6)
		move.l	d0,Uviewport(a5)

		lea	start(pc),a0
		move.l	a0,startbase(a5)

		bsr.w	imageandgagetset

		move.w	#2,anzcolor(a5)	;erst initialisieren damit bei Iconify
					;kein mist kommt
		move.l	#2,ren_colorlevel(a5)
		move.l	#2,ren_usedcolors(a5)
		clr.l	ren_colvis

		lea	scrx,a0	;für Spritesave
		move.l	#$80,(a0)
		lea	scry,a0
		move.l	#$2c,(a0)

		move.l	words(a5),a0
		lea	farbtab4,a1
		move.l	checkkey3rout(a5),a6
		move.l	#32,d0
		jsr	-534(a6)
		
		bsr.w	initglobal

		move.l	font(a5),a0
		move.l	(a0),fontname
		move.w	4(a0),d0
		move.l	d0,fontheight
		move.l	fontreq(a5),a1
		lea	fonttags(pc),a0
		move.l	reqtbase(a5),a6
		jsr	_LVOrtChangeReqAttrA(a6)

		lea	labelpuffer,a0
		move.l	#'Spri',(a0)+
		move.l	#'te'<<16,(a0)+

		lea	welcomemsg,a4
		jsr	status

		jsr	opnewblib	;Öffne Workbench Lib

		jsr	makeappwindow

		move.l	renderbase(a5),a6
		sub.l	a1,a1
		tst.b	kick3(a5)
		beq.b	.no3
		lea	.rndr_memtag(pc),a1	;Kick 3.0 , wir können Pool benutzen
.no3:
		jsr	_LVOCreateRMHandlerA(a6)
		move.l	d0,rndr_memhandler(a5)

		lea	.rndr_paltag(pc),a1
		move.l	rndr_memhandler(a5),4(a1)
		move.l	renderbase(a5),a6
		jsr	_LVOCreatePaletteA(a6)
		move.l	d0,rndr_palette(a5)

		bsr.l	makearexx		;öffne Arexxport

		bra.w	waitaction

.rndr_memtag:
		dc.l	RND_MemType,RMHTYPE_POOL
		dc.l	TAG_DONE

.rndr_paltag:	dc.l	RND_RMHandler,0
		dc.l	RND_HSType,HSTYPE_15BIT_TURBO
		dc.l	TAG_DONE

fonttags:
		dc.l	RTFO_FontName
fontname:	dc.l	0
		dc.l	RTFO_FontHeight
fontheight:	dc.l	0	
		dc.l	TAG_DONE
endall:
;		bsr	endmemshow

;Speicher load und savepaths

		cmp.l	#'NOSA',Free1(a5)
		beq.w	nolock

		move.l	dosbase(a5),a6
		lea	envloadpath(pc),a0
		move.l	a0,d1
		move.l	dirname(a5),a0
		cmp.l	#0,a0
		beq.b	savedir
		move.l	a0,d2
		moveq	#-1,d3
		move.l	#$1100,d4
		jsr	_LVOSetVar(a6)

savedir:
		lea	envsavepath(pc),a0
		move.l	a0,d1
		move.l	sdirname(a5),a0
		cmp.l	#0,a0
		beq.b	saverout
		move.l	a0,d2
		moveq	#-1,d3
		move.l	#$1100,d4
		jsr	_LVOSetVar(a6)

;---- Save Load/Savename -----
saverout:
		move.l	lastreq(a5),a6
		move.l	a4,d0
		move.l	#$1101,d4
		moveq	#-1,d2
		jsr	-112(a6)
saverend:
		move.l	dosbase(a5),a6
		lea	loadsavestring(a5),a1

		move.w	nc_lroutine(a5),(a1)+
		move.w	nc_sroutine(a5),(a1)+
		move.w	nc_oroutine(a5),(a1)
		
		lea	envloadsave(pc),a0
		move.l	a0,d1
		lea	loadsavestring(a5),a1
		move.l	a1,d2
		moveq	#6,d3
		move.l	#$1100,d4
		jsr	_LVOSetVar(a6)

;---- Save Windowpositionen -----
savepos:
		cmp.b	#5,merk2(a5)
		beq.b	.w
		jsr	checkmainwinpos

		move.w	d0,mainx(a5)
		move.w	d1,mainy(a5)
.w		
		move.l	dosbase(a5),a6
		lea	envposition(pc),a0
		move.l	a0,d1
		lea	mainx(a5),a0
		move.l	a0,d2
		moveq	#8,d3
		move.l	#$1100,d4
		jsr	_LVOSetVar(a6)
savelock:
		move.l	check2(a5),d1
		lea	infoblock,a1
		add.l	24(a1),d1
		moveq	#0,d0
		move.b	check1(a5),d0
		add.w	finalcheck(a5),d0
		cmp.w	locktest(a5),d0
		beq.s	.ok
		move.l	d1,APG_Free12(a5)
		mulu	#3,d1
		move.l	d1,dummymerk(a5)
		bra.b	nolock

.ok		lea	lockmerk(a5),a0
		moveq	#0,d0
		moveq	#0,d1
		move.b	lockcheck(a5),d0
		tst.b	d0
		beq.b	.w
		st	d1
.w		move.w	d1,(a0)
		move.l	DisplayID(a5),2(a0)
		move.l	a0,d2		
		lea	envlock(pc),a0
		move.l	a0,d1
		moveq	#6,d3
		move.l	#$1100,d4
		jsr	_LVOSetVar(a6)

nolock:
;===================================================================

		bsr.w	freemem
		bsr.w	freeloaders
		bsr.w	freesavers
		bsr.w	freelisten
		bsr.l	removearexx
		
		bsr.w	freereqt		;Reqtoolsstruck freigeben

;		cmp.l	#-1,d7
		tst.b	nogadremove(a5)
		bne.b	ende

error:
;lösche previewstuff

		move.l	guigfxbase(a5),a6
		move.l	dp_drawhandle(a5),d0
		beq	.nf
		move.l	d0,a0
		jsr	_LVOReleaseDrawHandle(a6)
		clr.l	dp_drawhandle(a5)
.nf
		move.l	dp_picture(a5),d0
		beq	.np
		move.l	d0,a0
		jsr	_LVODeletePicture(a6)
		clr.l	dp_picture(a5)
.np:
		move.l	dp_psm(a5),d0
		beq	.npsm
		move.l	d0,a0
		jsr	_LVODeletePenShareMap(a6)
		clr.l	dp_psm(a5)
.npsm
;-----------------------------------------------------------------------------
		lea	MainwinWnd(a5),a0
		move.l	a0,window(a5)
		lea	MainwinGlist(a5),a0
		move.l	a0,Glist(a5)

		jsr	deleteappwindow

		jsr	deletetmp

		jsr	gt_CloseWindow
fail:
		jsr	ClosedownScreen
ende:
		bsr.w	closelibs

		jsr	closewblib
aus:
		moveq	#0,d0

;	ifeq	executable
;		illegal
;	else
		rts	
;	endc

imageandgagetset:
		tst.b	iconifyflag(a5)
		bne.w	.w
		move.l	mainrastport(a5),a0
		move.l	checkkey2rout(a5),a6
		move.l	#400,d0
		move.l	#20,d1
		jsr	-422(a6)
		moveq	#0,d0
		move.b	check2(a5),d0
		add.w	d0,finalcheck(a5)
		move.b	check3(a5),d0
		add.w	d0,finalcheck(a5)

		move.w	#logoLeft,d0
		jsr	ComputeX
		add.w	OffX(a5),d0
		move.w	d0,newlogoleft(a5)
		move.w	#logotop,d0
		jsr	ComputeY
		add.w	OffY(a5),d0
		move.w	d0,newlogotop(a5)
		move.w	#logowidth,d0
		jsr	ComputeX
	cmp.w	#400,d0
	bls.b	.wok
	move.w	#400,d0
.wok:
		move.w	d0,newlogowidth(a5)
		move.w	#logoHeight,d0
		jsr	ComputeY
	cmp.w	#400,d0
	bls.b	.hok
	move.w	#400,d0
.hok:
		move.w	d0,newlogoheight(a5)
.w:
		tst.b	iconifyflag(a5)
		beq.b	.nopic
		tst.w	loadflag(a5)
		beq	.nopic
		bsr	makepreview
		bra	.cp
.nopic:

		move.l	scr(a5),a0
		lea	sc_viewport(a0),a0
		move.l	4(a0),a0	;Colormap
		move.l	cm_colorTable(a0),a1	;Colortable
		lea	coltab(pc),a0
		move.w	(a1),d0
		move.w	d0,(a0)

		moveq	#0,d1
		move.l	#139,mp_height(a5)
		move.l	#147,mp_width(a5)
		move.l	#16,mp_colors(a5)
		lea	coltab(pc),a0
		move.l	a0,mp_palette(a5)
		move.l	#PALFMT_RGB4,mp_palfmt(a5)
		lea	logopuffer,a0
		move.l	#PIXFMT_CHUNKY_CLUT,d0
		move.l	#'LOGO',d7
		bsr	drawpreview

.cp
		tst.b	customscr(a5)
		beq.b	.nop
		bsr.l	checkpalette

.nop

.nologo:
		move.l	endbase(a5),d0
		sub.l	startbase(a5),d0
		lea	BufNewGad,a1
		cmp.l	68(a1),d0
		beq.b	.wm
		move.l	execbasepuffer(a5),a0
		move.l	mainwinWnd(a5),(a0)

.wm		jmp	memcheck
		

coltab		dc.w	$09A8,$0EBA,$035E,$03B5,$0A44,$0FEC,$0888,$0999
		dc.w	$0CBA,$0AAA,$0578,$0413,$0413,$0A98,$0FFF,$0000

;------------------------------------------------------------------------
;--- Malt ein Puffer in die rechte obere ecke des main window
;------------------------------------------------------------------------
drawpreview:
		move.l	d0,APG_Free2(a5)	;format
		move.l	a0,APG_Free3(a5)	;buffer

		move.l	guigfxbase(a5),a6

		move.l	dp_drawhandle(a5),d0
		beq	.nf
		move.l	d0,a0
		jsr	_LVOReleaseDrawHandle(a6)
		clr.l	dp_drawhandle(a5)
.nf
		move.l	dp_picture(a5),d0
		beq	.np
		move.l	d0,a0
		jsr	_LVODeletePicture(a6)
		clr.l	dp_picture(a5)
.np:
		move.l	dp_psm(a5),d0
		beq	.npsm
		move.l	d0,a0
		jsr	_LVODeletePenShareMap(a6)
		clr.l	dp_psm(a5)
.npsm
		sub.l	a0,a0
		jsr	_LVOCreatePenShareMapA(a6)
		move.l	d0,dp_psm(a5)		;psm

		move.l	APG_Free3(a5),a0	;logopuffer
		move.l	#TAG_DONE,-(a7)
		move.l	mp_colors(a5),-(a7)		
		move.l	#GGFX_NumColors,-(a7)
		move.l	mp_palfmt(a5),-(a7)
		move.l	#GGFX_PaletteFormat,-(a7)
		move.l	mp_palette(a5),-(a7)
		move.l	#GGFX_Palette,-(a7)
		move.l	APG_Free2(a5),-(a7)
		move.l	#GGFX_PixelFormat,-(a7)

		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		moveq	#0,d6

		move.l	mp_width(a5),d0
		move.l	mp_height(a5),d1
		move.w	newlogowidth(a5),d2
		move.w	newlogoheight(a5),d3

		move.l	d2,d4
		swap	d4
		divu.l	d0,d4
		move.l	d3,d5
		swap	d5
		divu.l	d1,d5

		move.l	d5,d6
		cmp.l	d4,d5
		blo	.wh
		move.l	d4,d6
.wh:
		mulu.l	d6,d0
		mulu.l	d6,d1
		swap	d0
		swap	d1
		ext.l	d0
		ext.l	d1

		moveq	#0,d2
		moveq	#0,d3
		move.w	newlogowidth(a5),d2
		move.w	newlogoheight(a5),d3
		sub.l	d0,d2
		lsr.l	#1,d2
		sub.l	d1,d3
		lsr.l	#1,d3
		move.l	d2,mp_woffset(a5)
		move.l	d3,mp_hoffset(a5)

		move.l	d1,-(a7)
		move.l	#GGFX_DestHeight,-(a7)
		move.l	d0,-(a7)
		move.l	#GGFX_DestWidth,-(a7)

		move.l	a7,a1

		move.l	mp_width(a5),d0
		move.l	mp_height(a5),d1

		jsr	_LVOMakePictureA(a6)
		lea	36+16(a7),a7
		tst.l	d0
		beq	dp_fault
		move.l	d0,dp_picture(a5)		;logopic

		move.l	dp_psm(a5),a0
		move.l	dp_picture(a5),a1
		sub.l	a2,a2
		jsr	_LVOAddPictureA(a6)

;lösche altes bild
		moveq	#0,d0
		move.l	mainRastport(a5),a1
		move.l	gfxbase(a5),a6
		jsr	_LVOSetAPen(a6)

		move.w	newlogoleft(a5),d0
		move.w	newlogotop(a5),d1

		move.w	newlogoleft(a5),d2
		add.w	newlogowidth(a5),d2
		move.w	newlogoheight(a5),d3
		add.w	d1,d3

		move.l	mainRastport(a5),a1
		jsr	_LVORectFill(a6)

		move.l	dp_psm(a5),a0
		move.l	mainRastport(a5),a1
		move.l	Uviewport(a5),a2
		move.l	vp_colormap(a2),a2
		sub.l	a3,a3
		move.l	guigfxbase(a5),a6
		jsr	_LVOObtainDrawHandleA(a6)
		move.l	d0,dp_drawhandle(a5)		;drawhandle
		move.l	d0,a0

		move.l	dp_picture(a5),a1
		move.w	newlogoleft(a5),d0
		add.l	mp_woffset(a5),d0
		move.w	newlogotop(a5),d1
		add.l	mp_hoffset(a5),d1
		sub.l	a2,a2
		jsr	_LVODrawpictureA(a6)
		rts

dp_fault:
		lea	db_cant(pc),a4
		bsr.l	status

		move.l	dp_psm(a5),d0
		beq	.npsm
		move.l	d0,a0
		jsr	_LVODeletePenShareMap(a6)
		clr.l	dp_psm(a5)
.npsm
		move.l	scr(a5),a0
		lea	sc_viewport(a0),a0
		move.l	4(a0),a0	;Colormap
		move.l	cm_colorTable(a0),a1	;Colortable
		lea	coltab(pc),a0
		move.w	(a1),d0
		move.w	d0,(a0)

		moveq	#0,d1
		move.l	#139,mp_height(a5)
		move.l	#147,mp_width(a5)
		move.l	#16,mp_colors(a5)
		lea	coltab(pc),a0
		move.l	a0,mp_palette(a5)
		move.l	#PALFMT_RGB4,mp_palfmt(a5)
		lea	logopuffer,a0
		move.l	#PIXFMT_CHUNKY_CLUT,d0
		move.l	#'LOGO',d7
		bra	drawpreview

db_cant:	dc.b	"Can't draw preview!",0
		even
;-------------------------------------------------------------------------
makepreview:
		cmp.b	#24,planes(a5)
		beq	mp_drawrgb
;		tst.l	rndr_rgb(a5)	;24 Bit daten ?
;		bne	mp_drawrgb

		lea	PicMap(a5),a0
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.b	planes(a5),d0
		move.w	breite(a5),d1
		move.w	hoehe(a5),d2
		move.l	gfxbase(a5),a6
		jsr	_LVOinitbitmap(a6)

		lea	picmap+8(a5),a0
		move.l	picmem(a5),d0
		moveq	#0,d7		
		moveq	#8-1,d7	
.newplane8
		move.l	d0,(a0)+	;Planes in Strucktur einbinden
		add.l	oneplanesize(a5),d0
		dbra	d7,.newplane8
		bra	.initstruck

		moveq	#0,d7		
		move.b	planes(a5),d7	
		subq	#1,d7
.newplane
		move.l	d0,(a0)+	;Planes in Strucktur einbinden
		add.l	oneplanesize(a5),d0
		dbra	d7,.newplane
		
.initstruck
	;	move.l	APG_Bytewidth(a5),d0
	;	lsl.l	#3,d0
		moveq	#0,d0
		move.w	breite(a5),d0
		move.l	d0,mp_width(a5)
		moveq	#0,d0
		move.w	hoehe(a5),d0
		move.l	d0,mp_height(a5)
		move.w	anzcolor(a5),d0
		move.l	d0,mp_colors(a5)
		lea	farbtab8+4(a5),a0
		move.l	a0,mp_palette(a5)
		move.l	#PALFMT_RGB32,mp_palfmt(a5)
		lea	picmap(a5),a0
		move.l	#PIXFMT_BITMAP_CLUT,d0
		tst.b	ham8(a5)
		beq	.n8
		move.l	#PIXFMT_BITMAP_HAM8,d0
.n8		tst.b	ham(a5)
		beq	.n6
		move.l	#PIXFMT_BITMAP_HAM6,d0
.n6
		bsr	drawpreview

		rts
		
mp_drawrgb:
		move.l	APG_Bytewidth(a5),d0
		lsl.l	#3,d0
		move.l	d0,mp_width(a5)
		moveq	#0,d0
		move.w	hoehe(a5),d0
		move.l	d0,mp_height(a5)
		clr.l	mp_colors(a5)
		clr.l	mp_palette(a5)
		clr.l	mp_palfmt(a5)
		move.l	rndr_rgb(a5),a0
		move.l	#PIXFMT_0RGB_32,d0
		bsr	drawpreview

		rts

;--------------------------------------------------------------------
;		MashUnpack
;
;	>	a0	InBuf
;		a1	OutBuf


MashUnpack:	movem.l	d0-d5/a0-a5,-(sp)
		addq.w	#4,a0
		move.l	(a0)+,d0
		add.l	a1,d0
		lea	lbL0009D8(pc),a4
		lea	lbL00099C(pc),a5
		move.l	#$FF00,d5
		moveq	#0,d4
		moveq	#-$80,d3
lbC000880	add.b	d3,d3
		bne.s	lbC000888
		move.b	(a0)+,d3
		addx.b	d3,d3
lbC000888	bcc.s	lbC0008EA
		add.b	d3,d3
		bne.s	lbC000892
		move.b	(a0)+,d3
		addx.b	d3,d3
lbC000892	bcc.s	lbC0008E8
		add.b	d3,d3
		bne.s	lbC00089C
		move.b	(a0)+,d3
		addx.b	d3,d3
lbC00089C	bcc.s	lbC0008E6
		add.b	d3,d3
		bne.s	lbC0008A6
		move.b	(a0)+,d3
		addx.b	d3,d3
lbC0008A6	bcc.s	lbC0008E4
		add.b	d3,d3
		bne.s	lbC0008B0
		move.b	(a0)+,d3
		addx.b	d3,d3
lbC0008B0	bcc.s	lbC0008E2
		add.b	d3,d3
		bne.s	lbC0008BA
		move.b	(a0)+,d3
		addx.b	d3,d3
lbC0008BA	bcc.s	lbC0008E0
		move.l	a4,a2
lbC0008BE	addq.l	#4,a2
		add.b	d3,d3
		bne.s	lbC0008C8
		move.b	(a0)+,d3
		addx.b	d3,d3
lbC0008C8	bcs.s	lbC0008BE
		move.w	(a2)+,d4
lbC0008CC	add.b	d3,d3
		bne.s	lbC0008D4
		move.b	(a0)+,d3
		addx.b	d3,d3
lbC0008D4	addx.w	d4,d4
		bcc.s	lbC0008CC
		add.w	(a2),d4
lbC0008DA	move.b	(a0)+,(a1)+
		dbra	d4,lbC0008DA
lbC0008E0	move.b	(a0)+,(a1)+
lbC0008E2	move.b	(a0)+,(a1)+
lbC0008E4	move.b	(a0)+,(a1)+
lbC0008E6	move.b	(a0)+,(a1)+
lbC0008E8	move.b	(a0)+,(a1)+
lbC0008EA	add.b	d3,d3
		bne.s	lbC0008F2
		move.b	(a0)+,d3
		addx.b	d3,d3
lbC0008F2	bcs.s	lbC000906
		moveq	#1,d2
		add.b	d3,d3
		bne.s	lbC0008FE
		move.b	(a0)+,d3
		addx.b	d3,d3
lbC0008FE	bcs.s	lbC000924
		move.l	d5,d1
		moveq	#0,d2
		bra.s	lbC00094C

lbC000906	move.l	a5,a2
lbC000908	addq.l	#4,a2
		add.b	d3,d3
		bne.s	lbC000912
		move.b	(a0)+,d3
		addx.b	d3,d3
lbC000912	bcs.s	lbC000908
		move.w	(a2)+,d2
lbC000916	add.b	d3,d3
		bne.s	lbC00091E
		move.b	(a0)+,d3
		addx.b	d3,d3
lbC00091E	addx.w	d2,d2
		bcc.s	lbC000916
		add.w	(a2),d2
lbC000924	moveq	#0,d4
		add.b	d3,d3
		bne.s	lbC00092E
		move.b	(a0)+,d3
		addx.b	d3,d3
lbC00092E	addx.w	d4,d4
		add.b	d3,d3
		bne.s	lbC000938
		move.b	(a0)+,d3
		addx.b	d3,d3
lbC000938	addx.w	d4,d4
		add.b	d3,d3
		bne.s	lbC000942
		move.b	(a0)+,d3
		addx.b	d3,d3
lbC000942	addx.w	d4,d4
		add.w	d4,d4
		add.w	d4,d4
		move.l	lbW000980(pc,d4.w),d1
lbC00094C	move.w	d1,d4
lbC00094E	add.b	d3,d3
		bne.s	lbC00095E
		cmp.w	d5,d4
		bcs.s	lbC00095A
		lsl.w	#8,d4
		move.b	(a0)+,d4
lbC00095A	move.b	(a0)+,d3
		addx.b	d3,d3
lbC00095E	addx.w	d4,d4
		bcs.s	lbC00094E
		swap	d1
		add.w	d1,d4
		move.l	a1,a3
		sub.l	d4,a3
lbC00096A	move.b	(a3)+,(a1)+
		dbra	d2,lbC00096A
		move.b	(a3)+,(a1)+
		cmp.l	a1,d0
		bhi.w	lbC000880

;--------------------------------------------------------------------------
		lea	daten,a5
		lea	diskobjektstruck,a0
		add.l	#lo_test-diskobjektstruck,a0
		moveq	#$30,d0
		lsl.w	#1,d0
		or.w	#7,d0
		move.b	(a0),d1
		cmp.b	d0,d1
		beq.b	.w			;crackschutz für
		move.b	d0,dosbase(a5)
.w						;Lockmon
;---------------------------------------------------------------------------
		movem.l	(sp)+,d0-d5/a0-a5
		rts

lbW000980	dc.w	0
		dc.w	$F000
		dc.w	$20
		dc.w	$FC00
		dc.w	$A0
		dc.w	$FF00
		dc.w	$2A0
		dc.w	$FF80
		dc.w	$6A0
		dc.w	$FFC0
		dc.w	$EA0
		dc.w	$FFE0
		dc.w	$1EA0
		dc.w	$FFF0
lbL00099C	dc.l	$3EA0FFF8
		dc.l	$80000002
		dc.l	$40000004
		dc.l	$20000008
		dc.l	$10000010
		dc.l	$8000020
		dc.l	$4000040
		dc.l	$2000080
		dc.l	$1000100
		dc.l	$800200
		dc.l	$400400
		dc.l	$200800
		dc.l	$101000
		dc.l	$82000
		dc.l	$44000
lbL0009D8	dc.l	$28000
		dc.l	$80000000
		dc.l	$40000002
		dc.l	$20000006
		dc.l	$1000000E
		dc.l	$800001E
		dc.l	$400003E
		dc.l	$200007E
		dc.l	$10000FE
		dc.l	$8001FE
		dc.l	$4003FE
		dc.l	$2007FE
		dc.l	$100FFE
		dc.l	$81FFE
		dc.l	$43FFE
		dc.l	$27FFE
		dc.l	$1FFFE

;****************************************************************************
;*** Auf Kick 2.0 testen ****************************************************
;****************************************************************************
checkkick:
		clr.b	kick3(a5)
		move.l	4.w,a6
		move.w	20(a6),d0
		cmp.w	#37,d0
		blo.b	falsekick1
		cmp.b	#39,d0
		blo.b	.nokick3
		move.b	#1,kick3(a5)
.nokick3:
		moveq	#0,d0
		rts
falsekick1:
		lea	doslibname(pc),a1
		moveq	#0,d0
		jsr	_LVOopenlibrary(a6)
		move.l	d0,a6
		lea	conwin(pc),a0
		move.l	a0,d1
		move.l	#1005,d2
		jsr	_LVOopen(a6)
		tst.l	d0
		beq.s	falsekick	;Nicht einmal AUSGABE auf CON: funtioniert
		move.l	d0,d6
		move.l	d0,d1

		lea	conout(pc),a0
		move.l	a0,d2
		moveq	#conlen,d3
		jsr	_LVOwrite(a6)	;Ausgabe "Needs Amiga OS2.04 or higher"
		move.l	#250,d1		;~5 Sekunden warten
		jsr	_LVOdelay(a6)

		move.l	d6,d1		;Con schließen
		jsr	_LVOclose(a6)

falsekick:
		move.l	a6,a1
		move.l	4.w,a6
		jsr	_LVOCloselibrary(a6)
		moveq	#1,d0
		rts

Conwin:	dc.b	`CON:10/10/250/45/ArtPRO`,0
Conout:	dc.b	10,`Needs Amiga OS2.04 or higher to run`,0
Conlen = *-Conout
Conwin2:	dc.b	`CON:10/10/250/45/ArtPRO`,0
Conout2:	dc.b	10,`Needs a 68020 or higher to run`,0
Conlen2 = *-Conout2
		even

;****************************************************************************
;----------------------- CLEAR BSS-SECTION ---------------------------------*
;****************************************************************************
clearbss:
		lea	daten,a5
		move.l	a5,a0
		move.l	#datalen-1,d0
;		add.l	#datalen,d0
.clr		clr.b	(a0)+		;lösche Bss Section
		dbra	d0,.clr

		lea	bytepuffer,a0
		move.l	#datalen1-1,d0
.clr1		clr.b	(a0)+		;lösche Bss Section
		dbra	d0,.clr1
		lea	saverout+14(pc),a0
		move.l	#$4eaeff90,(a0)
		rts

;****************************************************************************
;*--------------------- CHECK AUF AGA ODER ECS -----------------------------*
;****************************************************************************
checkaga:
		sf	ecs(a5)
		sf	aga(a5)

		lea	aboutmsg,a0
		move.l	a0,abouttest(a5)

		lea	promptcheck+684,a0
		move.l	a0,checkprompt(a5)
		move.w	#316,locktest(a5)
		move.l	gfxbase(a5),a0
		moveq	#0,d0
		move.b	gb_ChipRevBits0(a0),d0

		moveq	#0,d1
		move.b	d0,d1
		and.b	#SETCHIPREV_AA,d1
		cmp.b	#SETCHIPREV_AA,d1
		bne.b	.noaga
		st	aga(a5)
		rts
.noaga:
		move.b	d0,d1
		and.b	#SETCHIPREV_ECS,d1
		cmp.b	#SETCHIPREV_ECS,d1
		bne.b	.noecs
		st	ecs(a5)
.noecs:
		rts
		
;****************************************************************************
;*-------------------------- OPEN LIBS -------------------------------------*
;****************************************************************************
openlibs:
		clr.b	nofont(a5)
		move.l	$4,a6
		moveq	#29,d0
		lea	rendername(pc),a1
		jsr	_LVOopenlibrary(a6)
		move.l	d0,renderbase(a5)
		beq.w	norender
		lea	guigfxname(pc),a1
		moveq	#11,d0
		jsr	_LVOOpenLibrary(a6)
		move.l	d0,guigfxbase(a5)
		beq	norender
		moveq	#38,d0
		lea	endrequester+112,a1
		move.l	a1,lastreq(a5)
		lea	reqtools(pc),a1
		jsr	_LVOopenlibrary(a6)
		move.l	d0,reqtbase(a5)
		beq.w	noreqt		;Keine Reqtools.library gefunden
		move.l	d0,reqtbase1(a5)
		moveq	#0,d0
		clr.b	availdatatype(a5)
		lea	dataname(pc),a1
		jsr	_LVOOpenLibrary(a6)
		move.l	d0,DTbase(a5)
		beq.b	.nodata
		tst.b	kick3(a5)
		beq.b	.nodata
		st	availdatatype(a5)
.nodata:	moveq	#0,d0
		lea	gfxname(pc),a1
		jsr	_LVOopenlibrary(a6)
		move.l	d0,gfxbase(a5)
		lea	checkkey1+312,a1
		move.l	a1,checkkey1rout(a5)
		lea	doslibname(pc),a1
		moveq	#0,d0
		jsr	_LVOopenlibrary(a6)
		move.l	d0,dosbase(a5)
		lea	checkkey2+422,a1
		move.l	a1,checkkey2rout(a5)
		moveq	#0,d0
		lea	intuiname(pc),a1
		jsr	_LVOopenlibrary(a6)
		move.l	d0,intbase(a5)
		lea	checkkey3+534,a1
		move.l	a1,checkkey3rout(a5)
		lea	gadname(pc),a1
		moveq	#0,d0
		jsr	_LVOopenlibrary(a6)
		move.l	d0,gadbase(a5)
		lea	diskname(pc),a1
		moveq	#36,d0
		jsr	_LVOOpenlibrary(a6)
		move.l	d0,diskbase(a5)
		bne.b	.dok
		st	nofont(a5)

;		lea	sm_Title(pc),a0
;		lea	lockcode,a1
;		move.w	(a1)+,38(a0)

.dok:
		moveq	#0,d0
		lea	mathname(pc),a1
		jsr	_LVOopenlibrary(a6)
		move.l	d0,mathbase(a5)
		moveq	#0,d0
		lea	mathtraname(pc),a1
		jsr	_LVOopenlibrary(a6)
		move.l	d0,mathtransbase(a5)
		moveq	#0,d0
		lea	utilname(pc),a1
		jsr	_LVOopenlibrary(a6)
		move.l	d0,utilbase(a5)		
		moveq	#0,d0
		lea	cybername(pc),a1
		jsr	_LVOopenlibrary(a6)
		move.l	d0,cyberbase(a5)
		moveq	#0,d0
		rts				
noreqt:
		lea	doslibname(pc),a1
		moveq	#0,d0
		jsr	_LVOopenlibrary(a6)
		move.l	d0,a6
		lea	conwin1(pc),a0
		move.l	a0,d1
		move.l	#1005,d2
		jsr	_LVOopen(a6)
		tst.l	d0
		beq.s	nort	;Nicht einmal AUSGABE auf CON: funtioniert
		move.l	d0,d6
		move.l	d0,d1

		lea	conout1(pc),a0
		move.l	a0,d2
		moveq	#conlen1,d3
		jsr	_LVOwrite(a6)	;Ausgabe "Needs Amiga OS2.04 or higher"
		move.l	#250,d1		;~5 Sekunden warten
		jsr	_LVOdelay(a6)

		move.l	d6,d1		;Con schließen
		jsr	_LVOclose(a6)

nort:
		move.l	a6,a1
		move.l	4,a6
		jsr	_LVOCloselibrary(a6)

		move.l	renderbase(a5),a6
		jsr	_LVOCloselibrary(a6)
		
		moveq	#-1,d0
		rts

norender:
		lea	doslibname(pc),a1
		moveq	#0,d0
		jsr	_LVOopenlibrary(a6)
		move.l	d0,a6
		lea	renwin1(pc),a0
		move.l	a0,d1
		move.l	#1005,d2
		jsr	_LVOopen(a6)
		tst.l	d0
		beq.s	.nort	;Nicht einmal AUSGABE auf CON: funtioniert
		move.l	d0,d6
		move.l	d0,d1

		lea	renout1(pc),a0
		move.l	a0,d2
		moveq	#renlen1,d3
		jsr	_LVOwrite(a6)	;Ausgabe "Needs Amiga OS2.04 or higher"
		move.l	#250,d1		;~5 Sekunden warten
		jsr	_LVOdelay(a6)

		move.l	d6,d1		;Con schließen
		jsr	_LVOclose(a6)

.nort:
		move.l	a6,a1
		move.l	4,a6
		jsr	_LVOCloselibrary(a6)

		moveq	#-1,d0
		rts



Conwin1:	dc.b	`CON:10/10/250/40/ArtPRO`,0
Conout1:	dc.b	10,`You need ReqTools.library v38+!`,0
Conlen1 = *-Conout1
	even
renwin1:	dc.b	`CON:10/10/250/40/ArtPRO`,0
renout1:	dc.b	10,`You need Render.library 29.0+`,10
		dc.b	'and guigfx.library 11.0!',0
renlen1 = *-renout1
	even
gfxname:	dc.b	'graphics.library',0
doslibname:	dc.b	'dos.library',0
reqtools:	dc.b	'reqtools.library',0
intuiname:	dc.b	'intuition.library',0
gadname:	dc.b	'gadtools.library',0
mathname:	dc.b	'mathffp.library',0
dataname:	dc.b	'datatypes.library',0
diskname:	dc.b	'diskfont.library',0
utilname:	dc.b	'utility.library',0
rendername:	dc.b	'render.library',0
cybername:	dc.b	'cybergraphics.library',0
guigfxname:	dc.b	'guigfx.library',0
mathtraname:	dc.b	'mathtrans.library',0

	even
;****************************************************************************
;*-------------------------- CLOSE LIBS ------------------------------------*
;****************************************************************************
closelibs:
		move.l	$4,a6
		tst.b	availdatatype(a5)
		beq.b	.nodata
		move.l	DTbase(a5),a1
		jsr	_LVOcloselibrary(a6)
.nodata:	move.l	reqtbase(a5),a1
		jsr	_LVOcloselibrary(a6)
	tst.l	cyberbase(a5)
	beq.b	.nocyber
	move.l	cyberbase(a5),a1
	jsr	_LVOCloselibrary(a6)
.nocyber:
		move.l	gfxbase(a5),a1
		jsr	_LVOcloselibrary(a6)
		move.l	dosbase(a5),a1
		jsr	_LVOcloselibrary(a6)
		move.l	intbase(a5),a1
		jsr	_LVOcloselibrary(a6)
		move.l	mathbase(a5),a1
		jsr	_LVOcloselibrary(a6)
		move.l	mathtransbase(a5),a1
		jsr	_LVOcloselibrary(a6)
		move.l	renderbase(a5),a1
		jsr	_LVOcloselibrary(a6)
		move.l	guigfxbase(a5),a1
		jsr	_LVOCloselibrary(a6)
		move.l	gadbase(a5),a1
		jmp	_LVOcloselibrary(a6)


;----------------------------------------------------------------------------
;----- Kucke ob es Tooltypes gibt -------------------------------------------
;----------------------------------------------------------------------------
checktooltypes:
		sf	merk1(a5)
		clr.l	free1(a5)
		clr.l	free2(a5)
		clr.l	free3(a5)

		lea	ct_tmpname(pc),a1
		move.w	#'t:',(a1)+	;default t:
		move.l	#'ARTT',(a1)+
		move.l	#'EMP.',(a1)+
		move.l	a1,tmpname(a5)

		move.l	#2,undolevel(a5)
		clr.l	st_first(a5)
		sf	st_overflow(a5)
		move.l	#-1,st_lasttmp(a5)

		lea	iconlibname,a1
		moveq	#0,d0
		move.l	4.w,a6
		jsr	_LVOOpenlibrary(a6)
		move.l	d0,free1(a5)		
		beq.w	ct_end		;keine Iconlib --> nix tooltypes
		move.l	d0,a6
		
		move.l	programdirlock(a5),d1

		lea	cb_farbtab4,a3
		move.l	a3,d2
		move.l	#260*2,d3
		move.l	dosbase(a5),a6
		jsr	_LVONameFromLock(a6)	;hole Dir Name aus dem wir 
		tst.l	d0			;gestartet wurden
		beq.w	ct_end1

		move.l	a3,a1
.w		tst.b	(a1)+
		bne.b	.w

		subq.l	#2,a1
		cmp.b	#':',(a1)+
		beq.b	.noslash
		move.b	#'/',(a1)+
.noslash:
		move.l	WBMessage(a5),d0
		beq.b	.nowb
		move.l	d0,a0
		move.l	sm_ArgList(a0),a0
		move.l	wa_Name(a0),a0

.nz:		move.b	(a0)+,d0
		beq.b	.ze
		move.b	d0,(a1)+
		bra.b	.nz
.ze:		clr.b	(a1)+

		bra.b	.geticon
		
.nowb:		move.l	a1,d1
		move.l	#200,d2
		jsr	_LVOGetProgramName(a6)
		tst.l	d0
		beq.w	ct_end1

.geticon
		move.l	a3,a0

		move.l	free1(a5),a6	;Iconlib
		jsr	_LVOGetDiskObject(a6)

		move.l	d0,free2(a5)	;Unser Icon merken
		beq.w	ct_end1		;Kein Icon gefunden

		move.l	d0,a0
		move.l	do_tooltypes(a0),a0
		move.l	a0,a3
		lea	ct_loadtype(pc),a1
		jsr	_LVOFindTooltype(a6)		

		tst.l	d0
		beq.b	ct_next
		move.l	d0,a0
		lea	ct_loadname(pc),a1
		lea	_loadername(pc),a2
		move.l	a1,(a2)
.wc		move.b	(a0)+,d0
		move.b	d0,(a1)+
		bne.b	.wc	

ct_next:
		move.l	a3,a0
		lea	ct_savetype(pc),a1
		jsr	_LVOFindTooltype(a6)		
		tst.l	d0

		beq.b	ct_next1
		move.l	d0,a0
		lea	ct_savename(pc),a1
		lea	_savername(pc),a2
		move.l	a1,(a2)
.w		move.b	(a0)+,d0
		move.b	d0,(a1)+
		bne.b	.w	

;tmpdir ?

ct_next1:
		move.l	a3,a0
		lea	ct_tmp(pc),a1
		jsr	_LVOFindTooltype(a6)		
		lea	ct_tmpname(pc),a1
		tst.l	d0
		beq.b	ct_next2
		move.l	d0,a0
.w		move.b	(a0)+,d0
		move.b	d0,(a1)+
		bne.b	.w	
		subq.l	#1,a1
		move.l	#'ARTT',(a1)+
		move.l	#'EMP.',(a1)+
		move.l	a1,tmpname(a5)

;anzahl der undolevel

ct_next2:
		move.l	a3,a0
		lea	ct_ulevel(pc),a1
		jsr	_LVOFindTooltype(a6)		
		tst.l	d0
		beq.b	ct_end1

		move.l	d0,a0
		move.l	d0,a1
.w		tst.b	(a1)+
		bne	.w
		subq.l	#1,a1
		move.l	a1,a0
		sub.l	d0,a0
		move.l	a0,d0
		subq.w	#1,d0
		moveq	#1,d2
		moveq	#0,d3		;wandle dez in zahl
.nd:		moveq	#0,d1
		move.b	-(a1),d1
		sub.b	#$30,d1
		mulu	d2,d1
		add.l	d1,d3
		mulu	#10,d2
		dbra	d0,.nd		
		move.l	d3,undolevel(a5)

ct_end1:
		move.l	apg_free2(a5),d0
		beq	.nodisk
		move.l	d0,a0
		move.l	APG_Free1(a5),a6
		jsr	_LVOFreeDiskObject(a6)
.nodisk:		
		move.l	APG_Free1(a5),a1
		move.l	4.w,a6
		jsr	_LVOCloseLibrary(a6)
ct_end:


checkuae:
		move.l	gfxbase(a5),a6
		moveq	#INVALID_ID,d0
.nextcheck:
		jsr	_LVONextDisplayInfo(a6)
		move.l	d0,a4
		cmp.l	#INVALID_ID,d0
		beq	keinuae
		jsr	_LVOFindDisplayInfo(a6)
		move.l	d0,a0
		
		moveq	#32+16,d0
		move.l	#DTAG_NAME,d1
		lea	datapuffer,a1
		moveq	#0,d2
		move.l	gfxbase(a5),a6
		jsr	_LVOGetDisplayInfoData(a6)
		tst.l	d0
		bne	.wertaus
		move.l	a4,d0
		bra	.nextcheck
.wertaus:
		lea	datapuffer+nif_name,a0
		move.l	(a0)+,d0
		rol.l	#5,d0
		cmp.l	#$a828a8ea,d0	;UAEG
		bne	.nextcheck
		moveq	#0,d0
		move.w	(a0),d0
		ror.l	#5,d0
		cmp.l	#$c0000232,d0	;FX
		bne	.nextcheck
		move.l	#$a828a8ea,d0
		rts
keinuae:
		moveq	#0,d0
		rts


ct_loadtype:	dc.b	'LOADLIST',0
ct_savetype:	dc.b	'SAVELIST',0
ct_tmp:		dc.b	'TMPDIR',0
ct_ulevel:	dc.b	'UNDOLEVEL',0

		even

ct_loadname:	ds.b	100
ct_savename:	ds.b	100
ct_tmpname:	ds.b	100

		even

;****************************************************************************
;*----------------------- Gebe Speicher wieder frei ------------------------*
;****************************************************************************
freemem:
		move.l	4,a6
		tst.w	loadflag(a5)
		beq.b	noload
		clr.w	loadflag(a5)
	;	move.l	memsize(a5),d0
	;	beq.b	noload
		move.l	picmem(a5),a1
		cmp.l	#0,a1
		beq.b	.nopicmem
		jsr	_LVOFreeVec(a6)
		clr.l	picmem(a5)
.nopicmem:	move.l	rndr_rendermem(a5),a1
		cmp.l	#0,a1
		jsr	_LVOFreeVec(a6)
		clr.l	rndr_rendermem(a5)

		move.l	renderbase(a5),a6
		move.l	rndr_histogram(a5),d0
		beq.b	.w2
		move.l	d0,a0
		jsr	_LVODeleteHistogram(a6)
		clr.l	rndr_histogram(a5)
.w2:
		move.l	rndr_palette(a5),d0
		beq.b	.np
		move.l	d0,a0
		jsr	_LVODeletePalette(a6)
		clr.l	rndr_palette(a5)
.np		move.l	APG_rndr_memhandler(a5),d0
		beq.b	noload
		move.l	d0,a0
		move.l	renderbase(a5),a6
		jsr	_LVODeleteRMHandler(a6)
		clr.l	APG_rndr_memhandler(a5)
noload:
		rts
;***************************************************************************
;*------------------------ Init Reqtoolsstruck ----------------------------*
;***************************************************************************
initreq:
;RequesterStrucktur anfordern 

		sub.l	a0,a0
		moveq	#0,d0			;Struktur-Type
		move.l	reqtbase(a5),a6
		jsr	_LVORTAllocRequestA(a6)
		move.l	d0,struckAdr(a5)	;Loadstruck

		sub.l	a0,a0
		moveq	#0,d0			;Struktur-Type
		jsr	_LVORTAllocRequestA(a6)
		move.l	d0,struckAdr1(a5)	;Savestruck

		sub.l	a0,a0
		moveq	#0,d0			;Struktur-Type
		jsr	_LVORTAllocRequestA(a6)
		move.l	d0,struckAdr2(a5)	;PrefsStruck

		sub.l	a0,a0
		moveq	#0,d0			;Struktur-Type
		jsr	_LVORTAllocRequestA(a6)
		move.l	d0,struckAdr3(a5)	;LoaderStruck

		sub.l	a0,a0
		moveq	#0,d0			;Struktur-Type
		jsr	_LVORTAllocRequestA(a6)
		move.l	d0,struckAdr4(a5)	;LoaderStruck

		sub.l	a0,a0
		move.l	#RT_SCREENMODEREQ,d0
		jsr	_LVOrtAllocRequestA(a6)
		move.l	d0,scrmodereq(a5)

		sub.l	a0,a0
		move.l	#RT_SCREENMODEREQ,d0
		jsr	_LVOrtAllocRequestA(a6)
		move.l	d0,scrmodereqprefs(a5)

		sub.l	a0,a0
		move.l	#RT_FONTREQ,d0
		jsr	_LVOrtAllocRequestA(a6)
		move.l	d0,fontreq(a5)

		move.l	#5465,execbasepuffer(a5)

		sub.l	a0,a0
		move.l	#RT_REQINFO,d0
		jsr	_LVOrtAllocRequestA(a6)
		move.l	d0,colorreq(a5)
		rts

;***************************************************************************
;*------------------------ Free Reqtoolsstruck ----------------------------*
;***************************************************************************
freereqt:
;RequesterStrucktur freigeben 

		move.l	reqtbase(a5),a6
		move.l	struckAdr(a5),a1
		cmp.l	#0,a1
		beq.b	.rt_schonwech
		jsr	_LVORTFreeRequest(a6)
		clr.l	struckAdr(a5)
.rt_schonwech:
		move.l	struckAdr1(a5),a1
		cmp.l	#0,a1
		beq.b	.rt_schonwech1
		jsr	_LVORTFreeRequest(a6)
		clr.l	struckAdr1(a5)
.rt_schonwech1
		move.l	struckAdr2(a5),a1
		cmp.l	#0,a1
		beq.b	.rt_schonwech2
		jsr	_LVORTFreeRequest(a6)
		clr.l	struckAdr2(a5)
.rt_schonwech2:
		move.l	struckAdr3(a5),a1
		cmp.l	#0,a1
		beq.b	.rt_schonwech3
		jsr	_LVORTFreeRequest(a6)
		clr.l	struckAdr3(a5)
.rt_schonwech3:
		move.l	struckAdr4(a5),a1
		cmp.l	#0,a1
		beq.b	.rt_schonwech4
		jsr	_LVORTFreeRequest(a6)
		clr.l	struckAdr4(a5)
.rt_schonwech4:
		move.l	scrmodereq(a5),a1
		cmp.l	#0,a1
		beq.b	.wech
		jsr	_LVOrtFreeRequest(a6)
		clr.l	scrmodereq(a5)
.wech:
		move.l	fontreq(a5),a1
		cmp.l	#0,a1
		beq.b	.wech1
		jsr	_LVOrtFreeRequest(a6)
		clr.l	fontreq(a5)
.wech1:
		move.l	scrmodereqprefs(a5),a1
		cmp.l	#0,a1
		beq.b	.wech2
		jsr	_LVOrtFreeRequest(a6)
		clr.l	scrmodereqprefs(a5)
.wech2:
		move.l	colorreq(a5),a1
		cmp.l	#0,a1
		beq.b	.wech3
		jsr	_LVOrtFreeRequest(a6)
		clr.l	colorreq(a5)
.wech3		
		moveq	#0,d0
		rts

;=========================================================================
;------ Init Globalroutines ------
;=========================================================================
initglobal:
		move.l	#TagItemListe1,rtrequestsTags(a5)
		lea	status,a0
		move.l	a0,statusrout(a5)
		lea	filesize1,a0
		move.l	a0,filesizerout(a5)
		move.l	#checkfirstword,checkfirstwordrout(a5)
		move.l	#bpl2chunkyLine,bpl2chunkyLinerout(a5)
		move.l	#openwindowF,openwinrout(a5)
		move.l	#wait,waitrout(a5)
		move.l	#writetext,writetextrout(a5)
		move.l	#checkmainwinpos,checkmainwinposrout(a5)

		move.l	check2(a5),d1
		lea	infoblock,a1
		add.l	24(a1),d1
		moveq	#0,d0
		move.b	check1(a5),d0
		add.w	finalcheck(a5),d0
		cmp.w	locktest(a5),d0
		beq.b	.ok
		mulu	#3,d1
		move.l	d1,dummymerk(a5)
		bra.b	.wech

.ok		lea	lockmerk(a5),a0
		lea	envlock(pc),a1
		move.l	a1,d1
		move.l	a0,d2
		moveq	#7,d3
		move.l	#$100,d4
		move.l	dosbase(a5),a6
		jsr	_LVOGetVar(a6)
		
		tst.w	lockmerk(a5)
		beq.b	.wech

		lea	checktag(pc),a3
		lea	mainwinGadgets,a0
		move.l	#GD_glockmon,d0
		lsl.l	#2,d0
		move.l	(a0,d0.l),a0
		move.l	mainwinWnd(a5),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		st	lockcheck(a5)
		move.l	dispmerk(a5),d0
		beq.b	.wech
		move.l	d0,DisplayID(a5)
		bsr.l	setmodi
		st	firstmode(a5)

.wech
		move.l	#TurboCopyMem,TurboCopyMemrout(a5)
		lea	checkmoni,a0
		move.l	a0,checkmonirout(a5)
		lea	findmonitor,a0
		move.l	a0,findmonitorrout(a5)

		move.l	#doprocess_hookstruck,doprocesshook(a5)

		lea	jmp_tab,a0
		lea	jmp_begin,a1
		move.l	#jmp_sizeof-1,d0
.nj:		move.b	(a1)+,(a0)+
		dbra	d0,.nj

		rts

checktag:
		dc.l	GTCB_Checked
		dc.l	1
		dc.l	TAG_DONE


;***************************************************************************
;*------------------ Lade und werte prefs aus -----------------------------*
;***************************************************************************
checkprefs:
		lea	dirENVname(pc),a0
		bsr.w	openit
		move.l	d0,filehandle(a5)
		bne.w	loadit
		lea	dirSname(pc),a0
		bsr.w	openit
		move.l	d0,filehandle(a5)
		bne.w	loadit
		lea	dirsysname(pc),a0
		bsr.w	openit
		move.l	d0,filehandle(a5)
		bne.w	loadit
default:
		move.l	#loadiff,loader(a5)
		move.l	#saveraw,saver(a5)
		st	overwrite(a5)
		st	littlewin(a5)
		st	drawgrid(a5)
		st	workbench(a5)

		st	nofont(a5)
		st	mpreview(a5)
		st	pundo(a5)
		
		lea	aktpubscreen(a5),a1
		lea	pubscreen,a0
		moveq	#9,d7
.nn		move.b	(a0)+,(a1)+	;kopiere Workbench als default Pub
		dbra	d7,.nn

		move.l	WBModeID(a5),prefsDisplayID(a5)
		move.w	WBwidth(a5),prefsdisplayWidth(a5)
		move.w	WBheight(a5),prefsDisplayHeight(a5)
		move.w	#2,prefsDisplayDepth(a5)
		move.w	#1,prefsoverscantype(a5)
		move.l	#$4000,prefsautoroll(a5)

		move.w	#4,anzmaincolors(a5)
		
		lea	prefspurefarbtab(a5),a1
		lea	defaultcolor(pc),a0
		moveq	#8-1,d7
.nc:		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		dbra	d7,.nc
		bsr.l	initscreen
		
		move.b	#1,hsize(a5)
		move.l	#1,TAG_hsize

		bra.w	initpath

oldprefsfound:
		lea	pr_msg(pc),a1
		lea	pr_msg1(pc),a2
		sub.l	a3,a3
		sub.l	a4,a4
		lea	tagitemliste1,a0
		move.l	reqtbase(a5),a6
		jsr	_LVOrtEZRequestA(a6)

		bra.w	default

pr_msg:		dc.b	'Old Settings file found',10
		dc.b	'using deafult settings!',0

pr_msg1:	dc.b	'I see',0
	even
defaultcolor:
		dc.b	149,149,149,0,0,0,255,255,255,59,103,162,123,123,123
		dc.b	175,175,175,170,144,124,255,169,151

openit:
		move.l	a0,-(a7)
		move.l	a0,d1
		move.l	#1005,d2
		move.l	dosbase(a5),a6
		jsr	_LVOOpen(a6)
		move.l	(a7)+,a1
		rts
loadit:
		move.l	d0,-(a7)
		jsr	filesize1
		move.l	(a7)+,d0
		move.l	d0,d1
		move.l	#prefssavepuffer,d2
		move.l	size(a5),d3
		jsr	_LVORead(a6)
		move.l	filehandle(a5),d1
		jsr	_LVOClose(a6)

;WertePrefs aus
		lea	prefssavepuffer,a0
		cmp.l	#'ARTP',(a0)+
		bne.w	default
		move.l	(a0)+,d0
		swap	d0
		cmp.w	#'0.',d0
		beq	oldprefsfound
		swap	d0

		lea	overwrite(a5),a1
		lea	words(a5),a2
		sub.l	a1,a2
		move.l	a2,d7
.np:		move.b	(a0)+,(a1)+
		dbra	d7,.np

		cmp.l	#"1.10",d0
		bhs	.pk
		st	mpreview(a5)
.pk
		cmp.l	#'1.11',d0
		bhs	.pok
		move.b	#1,hsize(a5)
		move.l	#1,TAG_hsize
.pok:
		moveq	#0,d0
		move.b	hsize(a5),d0
		move.l	d0,TAg_hsize

		move.l	(a0)+,TAG_showpic
		move.l	(a0)+,TAG_drawgrid
		move.l	(a0)+,TAG_autosave
		move.l	(a0)+,TAG_overwrite
		move.l	(a0)+,TAG_iconify
		move.l	(a0)+,TAG_screens
		move.l	(a0)+,TAG_askforexit

		move.l	(a0)+,prefsDisplayID(a5)
		move.w	(a0)+,prefsdisplayWidth(a5)
		move.w	(a0)+,prefsDisplayHeight(a5)
		move.w	(a0)+,prefsDisplayDepth(a5)
		move.w	(a0)+,prefsoverscantype(a5)
		move.l	(a0)+,prefsautoroll(a5)

		move.l	(a0)+,OpScreenmode(a5)
		move.l	(a0)+,OpdisplayWidth(a5)    ;zusammen mit Height
		move.w	(a0)+,OpDisplayDepth(a5)
		move.b	(a0)+,OpColMode(a5)

		lea	TAG_videpth,a1
		moveq	#0,d0
		move.b	OpColMode(a5),d0
		move.l	d0,(a1)

		add.l	#4*5+1,a0		;reserve überlesen
		
		move.w	prefsDisplayDepth(a5),d0
		moveq	#1,d1
		lsl.w	d0,d1
		move.w	d1,anzmaincolors(a5)

;lese Farbtab ein

		lea	prefspurefarbtab(a5),a1
		move.l	#256-1,d7
.nc:		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		dbra	d7,.nc

		lea	newfontname(a5),a1
.nfc:		move.b	(a0)+,d0
		beq.b	.endfont
		move.b	d0,(a1)+	;speicher Fontname
		bra.b	.nfc
.endfont:
	;	addq.l	#1,a0
		moveq	#0,d0
		move.b	(a0)+,d0
		move.w	d0,newfontheight(a5)
		
		lea	aktpubscreen(a5),a1
.nps:		move.b	(a0)+,d0
		beq.b	.endpub
		move.b	d0,(a1)+
		bra.b	.nps
.endpub:
		move.l	#loadiff,loader(a5)
		move.l	#saveraw,saver(a5)

		lea	TAG_preview,a0
		moveq	#0,d0
		tst.b	mpreview(a5)
		beq	.noprew
		moveq	#1,d0
.noprew:	move.l	d0,(a0)
		lea	TAG_scale,a0
		moveq	#0,d0
		tst.b	dscale(a5)
		beq	.noscale
		moveq	#1,d0
.noscale:	move.l	d0,(a0)

		lea	tag_pundo,a0
		moveq	#0,d0
		tst.b	pundo(a5)
		beq	.noundo
		moveq	#1,d0
.noundo:	move.l	d0,(a0)

		bsr.l	initscreen	;fülle Screentaglist

		bsr.w	initfontstuck

;lade load- und savepath
initpath:
loadpath:
		lea	envloadpath(pc),a1
		move.l	a1,d1
		lea	loaddirname(a5),a4
		move.l	a4,d2
		move.l	#200,d3
		move.l	#$100,d4
		move.l	dosbase(a5),a6
		jsr	_LVOGetVar(a6)
		tst.l	d0
		beq.b	noloadpath
		
		lea	dirname1(pc),a0
		move.l	a4,(a0)
		
		lea	dirtag1(pc),a0
		move.l	struckadr(a5),a1
		move.l	reqtbase(a5),a6
		jsr	_LVORTChangeReqAttrA(a6)

noloadpath:
		lea	envsavepath(pc),a1
		move.l	a1,d1
		lea	savedirname(a5),a4
		move.l	a4,d2
		move.l	#200,d3
		move.l	#$100,d4
		move.l	dosbase(a5),a6
		jsr	_LVOGetVar(a6)
		tst.l	d0
		beq.b	nopath

		lea	dirname1(pc),a0
		move.l	a4,(a0)
		
		lea	dirtag1(pc),a0
		move.l	struckadr1(a5),a1
		move.l	reqtbase(a5),a6
		jsr	_LVORTChangeReqAttrA(a6)
nopath:
;---- Lade windowposition ----
		move.w	#18,mainy(a5)
		move.w	#18,prefsy(a5)

		lea	envposition(pc),a1
		move.l	a1,d1
		lea	mainx(a5),a4
		move.l	a4,d2
		move.l	#9,d3
		move.l	#$100,d4
		move.l	dosbase(a5),a6
		jsr	_LVOGetVar(a6)
;		tst.l	d0
;		bgt	posok

;---- Load Load/SaveNumber -----
posok:
		clr.l	loader(a5)
		clr.l	saver(a5)
		clr.l	operator(a5)
		clr.l	loadername(a5)
		clr.l	savername(a5)
		clr.l	operatorname(a5)
		
		lea	envloadsave(pc),a0
		move.l	a0,d1
		lea	loadsavestring(a5),a4
		move.l	a4,d2
		move.l	#9,d3
		move.l	#$100,d4
		move.l	dosbase(a5),a6
		jsr	_LVOGetVar(a6)
		tst.l	d0
		bpl.b	vok

	;*--- Keine Load/Save prefs gefunden ---

		lea	nc_loadernode(pc),a0
		TSTLIST
		beq.b	.nol
		move.l	(a0),a0			;wir nehmen den ersten Loader
		move.l	NC_JUMP(a0),loader(a5)
		lea	NC_NAMESTRING(a0),a0
		move.l	a0,TAG_loadstring
		move.l	a0,loadername(a5)
.nol:
		lea	nc_savernode(pc),a0
		TSTLIST
		beq.w	.nsl
		move.l	(a0),a0			;wir nehmen den ersten Loader
		move.l	NC_JUMP(a0),saver(a5)
		lea	NC_NAMESTRING(a0),a0
		move.l	a0,TAG_savestring
		move.l	a0,savername(a5)
.nsl:
		lea	nc_operatornode(pc),a0
		TSTLIST
		beq.w	loadkey
		move.l	(a0),a0			;wir nehmen den ersten Loader
		move.l	NC_JUMP(a0),operator(a5)
		lea	NC_NAMESTRING(a0),a0
		move.l	a0,TAG_effect
		move.l	a0,operatorname(a5)

		bra.w	loadkey

vok:		
		move.w	(a4)+,nc_lroutine(a5)
		move.w	(a4)+,nc_sroutine(a5)
		move.w	(a4),nc_oroutine(a5)
		
		lea	nc_loadernode(pc),a3
		move.l	a3,a0
		TSTLIST
		beq.b	.nollist

		move.l	(a0),a0

		moveq	#0,d0
.w		move.l	(a0),d1
		beq.b	.end
		addq.l	#1,d0
		move.l	d1,a0
		bra.b	.w
.end
		subq.w	#1,d0

		move.w	nc_lroutine(a5),d7
		cmp.w	d0,d7
		bls.b	.nok		;nummer ist zu groß
		moveq	#0,d7
		clr.w	nc_lroutine(a5)	;nehmen wir den ersten loader
.nok
		move.l	a3,a0
.nln		move.l	(a0),a0
		dbra	d7,.nln

		move.l	NC_JUMP(a0),loader(a5)
		move.l	a0,loadernode(a5)
		lea	NC_NAMESTRING(a0),a0
		move.l	a0,TAG_loadstring
		move.l	a0,loadername(a5)

	;*---------- Check Saver ---------------------

.nollist:
		lea	nc_savernode(pc),a3
		move.l	a3,a0
		TSTLIST
		beq.b	noslist

		move.l	(a0),a0

		moveq	#0,d0
.sw		move.l	(a0),d1
		beq.b	.send
		addq.l	#1,d0
		move.l	d1,a0
		bra.b	.sw
.send
		subq.w	#1,d0

		move.w	nc_sroutine(a5),d7
		cmp.w	d0,d7
		bls.b	.snok		;nummer ist zu groß
		moveq	#0,d7
		clr.w	nc_sroutine(a5)	;nehmen wir den ersten loader
.snok
		move.l	a3,a0
.nsn		move.l	(a0),a0
		dbra	d7,.nsn

		move.l	NC_JUMP(a0),saver(a5)
		move.l	a0,savernode(a5)
		lea	NC_NAMESTRING(a0),a0
		move.l	a0,TAG_savestring
		move.l	a0,savername(a5)

	;*---------- Check Operator ---------------------

noslist:
		lea	nc_operatornode(pc),a3
		move.l	a3,a0
		TSTLIST
		beq.b	loadkey

		move.l	(a0),a0

		moveq	#0,d0
.sw		move.l	(a0),d1
		beq.b	.send
		addq.l	#1,d0
		move.l	d1,a0
		bra.b	.sw
.send
		subq.w	#1,d0

		move.w	nc_oroutine(a5),d7
		cmp.w	d0,d7
		bls.b	.snok		;nummer ist zu groß
		moveq	#0,d7
		clr.w	nc_oroutine(a5)	;nehmen wir den ersten loader
.snok
		move.l	a3,a0
.nsn		move.l	(a0),a0
		dbra	d7,.nsn

		move.l	NC_JUMP(a0),operator(a5)
		move.l	a0,operatornode(a5)
		lea	NC_NAMESTRING(a0),a0
		move.l	a0,TAG_effect
		move.l	a0,operatorname(a5)

;----------------------------------------------------------------------------

;Lade Keyfile
loadkey		clr.b	keyfound(a5)
		lea	keyname(pc),a1
		jsr	filesize1
		tst.l	d0
		bne.b	.wech
		move.l	size(a5),keylen(a5)
		lea	keyname(pc),a0
		move.l	a0,d1
		move.l	#1005,d2
		move.l	dosbase(a5),a6
		jsr	_LVOOpen(a6)
		tst.l	d0
		beq.b	.wech
		move.l	d0,d7
		move.l	d0,d1
		lea	keypuffer,a0
		move.l	a0,d2
		move.l	size(a5),d3
		jsr	_LVORead(a6)
		tst.l	d0
		beq.b	.wech
		st	keyfound(a5)
		move.l	d7,d1
		jsr	_LVOClose(a6)
.wech		rts

;--- Init Fontstuck ---
initfontstuck:
		tst.b	nofont(a5)
		bne.w	initpath
		lea	newfontname(a5),a0	;erzeuge richtigen
		lea	finalfontname(a5),a1	;fontnamen
		move.l	a1,a2
		cmp.b	#0,(a0)
		beq.b	.w
.nf:		move.b	(a0)+,d0
		cmp.b	#'.',d0
		beq.b	.endf
		move.b	d0,(a1)+
		bra.b	.nf
.endf:
		move.b	#'.',(a1)+
		move.b	#'f',(a1)+
		move.b	#'o',(a1)+
		move.b	#'n',(a1)+
		move.b	#'t',(a1)+
		clr.b	(a1)
		
		lea	usefontname(pc),a0
		move.l	a2,(a0)
		move.w	newfontheight(a5),d0
		move.w	d0,4(a0)

		move.l	diskbase(a5),a6
		jsr	_LVOOpenDiskFont(a6)
		
		move.l	d0,userfont(a5)
		bne.w	initpath
.w
		st	nofont(a5)
		rts

dirsysname:	dc.b	'ArtPRO.Prefs',0
dirSname:	dc.b	's:ArtPRO.Prefs',0
keyname:	dc.b	'devs:ARTPro.key',0
dirENVname:	dc.b	'ENV:ArtPRO/ArtPRO.Prefs',0
;direnvarcname:	dc.b	'ENVARC:ArtPRO/ArtPRO.Prefs',0
envloadpath:	dc.b	'ArtPRO/Loadpath',0
envsavepath:	dc.b	'ArtPRO/Savepath',0
envloadsave:	dc.b	'ArtPRO/LoadSaveRoutine',0
envposition:	dc.b	'ArtPRO/Position',0
envlock:	dc.b	'ArtPRO/Lock',0
	even
dirtag1:	dc.l	$80000032	;RTFI_Dir
dirname1:	dc.l	0
		dc.l	$80000034
		dc.l	0
	even

usefontname:	dc.l	0
usefontheight:	dc.w	0
		dc.b	0,1

;==========================================================================
;------------- Search for Loaders -----------------------------------------
;==========================================================================
checkloader:
		clr.b	merk2(a5)     ;wir wurden nicht von choose aufgerufen

;-------------------------------------------------------------------
		lea	fonttags(pc),a0
		lea	(saverout-fonttags)(a0),a0
		move.w	#((saverend-saverout)/2),d7
		moveq	#0,d0
		moveq	#0,d1
.ns:		move.w	(a0)+,d1
		add.l	d1,d0
		dbra	d7,.ns
		move.l	d0,lastreqcheck(a5)
;---------------------------------------------------------------------

checkloader1:
		move.l	programdirlock(a5),d1
		move.l	dosbase(a5),a6
		jsr	_LVOCurrentDir(a6)
		move.l	d0,lastcurrentdirlock(a5)
		
		clr.l	dirlock(a5)
		move.l	ch_dirname(a5),d1
		tst.b	merk2(a5)
		bne.b	.w		
		lea	loaderdir(pc),a0
		move.l	a0,d1
.w		moveq	#-2,d2
		move.l	dosbase(a5),a6
		jsr	_LVOLock(a6)
		move.l	d0,dirlock(a5)
		beq.w	cl_noloader
		move.l	d0,d1
		jsr	_LVOCurrentDir(a6)
		move.l	d0,lastcurrentdirlock1(a5)

		move.l	dirlock(a5),d1
		move.l	#infoblock1,d2
		jsr	_LVOExamine(a6)
		tst.l	d0
		beq.w	cl_noloader

		move.l	dirlock(a5),d1
		move.l	#infoblock1,d2
		jsr	_LVOExNext(a6)
		tst.l	d0
		beq.w	cl_noloader

		lea	infoblock1,a0
		cmp.l	#0,fib_DirEntryType(a0)
		bgt.b	cl_nextentry

;Checke den ersten Loader
		lea	fib_Filename(a0),a0
		move.l	a0,d1
		jsr	_LVOLoadSeg(a6)
		move.l	d0,firstloader(a5)
		beq.b	cl_nextentry
		move.l	d0,lastloader(a5)
		move.l	d0,a1
		add.l	a1,a1
		add.l	a1,a1
		addq.l	#4,a1
		move.l	12(a1),a1
		move.l	d0,26(a1)
		move.l	#'FIRS',d7
		bsr.b	cl_check

cl_nextentry:
		move.l	dirlock(a5),d1
		move.l	#infoblock1,d2
		jsr	_LVOExNext(a6)
		tst.l	d0
		beq.b	cl_noloader

		lea	infoblock1,a0
		cmp.l	#0,fib_DirEntryType(a0)
		bgt.b	cl_nextentry
;Checke Loader
		lea	fib_Filename(a0),a0
		move.l	a0,d1
		jsr	_LVOLoadSeg(a6)
		tst.l	d0
		beq.b	cl_nextentry
		move.l	d0,a1
		add.l	a1,a1
		add.l	a1,a1
		addq.l	#4,a1
		move.l	12(a1),a1
		move.l	d0,26(a1)	;trage eingene addresse in Node ein
	
		bsr.b	cl_check

		bra.b	cl_nextentry

cl_noloader
		move.l	lastcurrentdirlock1(a5),d1
		beq.b	.nl
		jsr	_LVOCurrentDir(a6)
.nl		
		move.l	lastcurrentdirlock(a5),d1
		beq.b	.nc
		jsr	_LVOCurrentDir(a6)
.nc		
		move.l	dirlock(a5),d1
		beq.b	.w
		jsr	_LVOUnlock(a6)
.w		rts

cl_check:
		move.l	d0,d2
		
		add.l	d0,d0
		add.l	d0,d0
		addq.l	#4,d0
		move.l	d0,a1
		cmp.l	#'ART-',4(a1)
		bne.b	cl_novalidentry
		cmp.l	#'PROL',8(a1)
		bne.b	cl_novalidentry
		cmp.l	#1,16(a1)	;Version
		bne.b	cl_novalidentry

		lea	gloadreqList(pc),a0

		move.l	12(a1),a1	;Node Adress

		move.l	(a0),a2
		move.l	18(a1),d3
.nn:		cmp.l	18(a2),d3
		beq.b	cl_novalidentry
		move.l	(a2),a2
		cmp.l	#0,a2
		beq.b	.ok
		bra.b	.nn	
.ok
		addtail

		cmp.l	#'FIRS',d7
		beq.b	.w
		move.l	lastloader(a5),a0
		move.l	a0,d1
		add.l	a0,a0
		add.l	a0,a0
		addq.l	#4,a0
		move.l	d2,(a0)			;letzten Loader merken
		move.l	d2,lastloader(a5)
		move.l	d2,a0
		add.l	a0,a0
		add.l	a0,a0
		addq.l	#4,a0
		move.l	d1,4(a0)

.w:		moveq	#0,d7
		moveq	#0,d0
		rts

cl_novalidentry:
		move.l	d2,d1
		jsr	_LVOUnLoadSeg(a6)
		moveq	#-1,d0
		rts

;==========================================================================
;------------- Search for Savers -----------------------------------------
;==========================================================================
checksaver:
		clr.b	merk2(a5)     ;wir wurden nicht von choose aufgerufen
;-------------------------------------------------------------------
		lea	setgitter(pc),a0
		lea	(endreq1-setgitter)(a0),a0
		move.w	#((drawlines-endreq1)/2),d7
		moveq	#0,d0
		moveq	#0,d1
.ns:		move.w	(a0)+,d1
		add.l	d1,d0
		dbra	d7,.ns
		move.l	d0,lastreqcheck1(a5)
;-----------------------------------------------------------------------

checksaver1:
		move.l	programdirlock(a5),d1
		move.l	dosbase(a5),a6
		jsr	_LVOCurrentDir(a6)
		move.l	d0,lastcurrentdirlock(a5)
		
		clr.l	dirlock(a5)
		move.l	ch_dirname(a5),d1
		tst.b	merk2(a5)
		bne.b	.w		
		lea	saverdir(pc),a0
		move.l	a0,d1
.w		moveq	#-2,d2
		move.l	dosbase(a5),a6
		jsr	_LVOLock(a6)
		move.l	d0,dirlock(a5)
		beq.w	cl_noloader
		move.l	d0,d1
		jsr	_LVOCurrentDir(a6)
		move.l	d0,lastcurrentdirlock1(a5)

		move.l	dirlock(a5),d1
		move.l	#infoblock1,d2
		jsr	_LVOExamine(a6)
		tst.l	d0
		beq.w	cl_noloader

		move.l	dirlock(a5),d1
		move.l	#infoblock1,d2
		jsr	_LVOExNext(a6)
		tst.l	d0
		beq.w	cl_noloader

		lea	infoblock1,a0
		cmp.l	#0,fib_DirEntryType(a0)
		bgt.w	cl_nextentry1

;Checke den ersten Saver
		lea	fib_Filename(a0),a0
		move.l	a0,d1
		jsr	_LVOLoadSeg(a6)
		move.l	d0,firstsaver(a5)
		beq.b	cl_nextentry1
		move.l	d0,lastsaver(a5)
		move.l	d0,a1
		add.l	a1,a1
		add.l	a1,a1
		addq.l	#4,a1
		move.l	12(a1),a1
		move.l	d0,26(a1)
		move.l	#'FIRS',d7
		bsr.b	cl_check1

cl_nextentry1:
		move.l	dirlock(a5),d1
		move.l	#infoblock1,d2
		jsr	_LVOExNext(a6)
		tst.l	d0
		beq.w	cl_noloader

		lea	infoblock1,a0
		cmp.l	#0,fib_DirEntryType(a0)
		bgt.b	cl_nextentry1
;Checke Loader
		lea	fib_Filename(a0),a0
		move.l	a0,d1
		jsr	_LVOLoadSeg(a6)
		tst.l	d0
		beq.b	cl_nextentry1
		move.l	d0,a1
		add.l	a1,a1
		add.l	a1,a1
		addq.l	#4,a1
		move.l	12(a1),a1
		move.l	d0,26(a1)	;trage eingene addresse in Node ein
	
		bsr.b	cl_check1

		bra.b	cl_nextentry1

cl_check1:
		move.l	d0,d2
		
		add.l	d0,d0
		add.l	d0,d0
		addq.l	#4,d0
		move.l	d0,a1
		cmp.l	#'ART-',4(a1)
		bne.w	cl_novalidentry
		cmp.l	#'PROS',8(a1)
		bne.w	cl_novalidentry
		cmp.l	#1,16(a1)		;Version !!!!!!!
		bne.w	cl_novalidentry

		lea	gsavereqList(pc),a0

		move.l	12(a1),a1	;Node Adress

		move.l	(a0),a2
		move.l	18(a1),d3
.nn:		cmp.l	18(a2),d3
		beq.w	cl_novalidentry
		move.l	(a2),a2
		cmp.l	#0,a2
		beq.b	.ok
		bra.b	.nn	
.ok
		addtail

		cmp.l	#'FIRS',d7
		beq.b	.w
		move.l	lastsaver(a5),a0
		move.l	a0,d1
		add.l	a0,a0
		add.l	a0,a0
		addq.l	#4,a0
		move.l	d2,(a0)			;letzten Loader merken
		move.l	d2,lastsaver(a5)
		move.l	d2,a0
		add.l	a0,a0
		add.l	a0,a0
		addq.l	#4,a0
		move.l	d1,4(a0)

.w:		moveq	#0,d7
		moveq	#0,d0
		rts

;==========================================================================
;------------- Search for Operators  -----------------------------------------
;==========================================================================
checkoperator:
		clr.b	merk2(a5)     ;wir wurden nicht von choose aufgerufen

		move.l	programdirlock(a5),d1
		move.l	dosbase(a5),a6
		jsr	_LVOCurrentDir(a6)
		move.l	d0,lastcurrentdirlock(a5)
		
		clr.l	dirlock(a5)
		move.l	ch_dirname(a5),d1
		tst.b	merk2(a5)
		bne.b	.w		
		lea	operatordir(pc),a0
		move.l	a0,d1
.w		moveq	#-2,d2
		move.l	dosbase(a5),a6
		jsr	_LVOLock(a6)
		move.l	d0,dirlock(a5)
		beq.w	cl_noloader
		move.l	d0,d1
		jsr	_LVOCurrentDir(a6)
		move.l	d0,lastcurrentdirlock1(a5)

		move.l	dirlock(a5),d1
		move.l	#infoblock1,d2
		jsr	_LVOExamine(a6)
		tst.l	d0
		beq.w	cl_noloader

		move.l	dirlock(a5),d1
		move.l	#infoblock1,d2
		jsr	_LVOExNext(a6)
		tst.l	d0
		beq.w	cl_noloader

		lea	infoblock1,a0
		cmp.l	#0,fib_DirEntryType(a0)
		bgt.w	cl_nextentry2

;Checke den ersten Saver
		lea	fib_Filename(a0),a0
		move.l	a0,d1
		jsr	_LVOLoadSeg(a6)
		move.l	d0,firstoperator(a5)
		beq.w	cl_nextentry1
		move.l	d0,lastoperator(a5)
		move.l	d0,a1
		add.l	a1,a1
		add.l	a1,a1
		addq.l	#4,a1
		move.l	12(a1),a1
		move.l	d0,26(a1)
		move.l	#'FIRS',d7
		bsr.b	cl_check2

cl_nextentry2:
		move.l	dirlock(a5),d1
		move.l	#infoblock1,d2
		jsr	_LVOExNext(a6)
		tst.l	d0
		beq.w	cl_noloader

		lea	infoblock1,a0
		cmp.l	#0,fib_DirEntryType(a0)
		bgt.b	cl_nextentry2
;Checke Loader
		lea	fib_Filename(a0),a0
		move.l	a0,d1
		jsr	_LVOLoadSeg(a6)
		tst.l	d0
		beq.b	cl_nextentry2
		move.l	d0,a1
		add.l	a1,a1
		add.l	a1,a1
		addq.l	#4,a1
		move.l	12(a1),a1
		move.l	d0,26(a1)	;trage eingene addresse in Node ein
	
		bsr.b	cl_check2

		bra.b	cl_nextentry2

cl_check2:
		move.l	d0,d2
		
		add.l	d0,d0
		add.l	d0,d0
		addq.l	#4,d0
		move.l	d0,a1
		cmp.l	#'ART-',4(a1)
		bne.w	cl_novalidentry
		cmp.l	#'PROO',8(a1)
		bne.w	cl_novalidentry
		cmp.l	#1,16(a1)		;Version !!!!!!!
		bne.w	cl_novalidentry

		lea	goperatorList(pc),a0

		move.l	12(a1),a1	;Node Adress

		move.l	(a0),a2
		move.l	18(a1),d3
.nn:		cmp.l	18(a2),d3
		beq.w	cl_novalidentry
		move.l	(a2),a2
		cmp.l	#0,a2
		beq.b	.ok
		bra.b	.nn	
.ok
		addtail

		cmp.l	#'FIRS',d7
		beq.b	.w
		move.l	lastoperator(a5),a0
		move.l	a0,d1
		add.l	a0,a0
		add.l	a0,a0
		addq.l	#4,a0
		move.l	d2,(a0)			;letzten Loader merken
		move.l	d2,lastoperator(a5)
		move.l	d2,a0
		add.l	a0,a0
		add.l	a0,a0
		addq.l	#4,a0
		move.l	d1,4(a0)

.w:		moveq	#0,d7
		moveq	#0,d0
		rts

loaderdir:
	ifne	executable
		dc.b	'ALoaders/',0
	else
		dc.b	'sources:converter/ALoaders/',0
	endc
	even

saverdir:
	ifne	executable
		dc.b	'ASavers/',0
	else
		dc.b	'sources:converter/ASavers/',0
	endc
	even

operatordir:
	ifne	executable
		dc.b	'AOperators/',0
	else
		dc.b	'sources:converter/AOperators/',0
	endc
	even
	
;==========================================================================
;----------- Gebe loader wieder frei --------------------------------------
;=======================================================================
freeloaders:
		move.l	firstloader(a5),a4
freesave:	cmp.l	#0,a4
		beq.b	.wech		;es gibt keine loader
.w		move.l	a4,d1		;merken
		add.l	a4,a4
		add.l	a4,a4
		addq.l	#4,a4
		move.l	(a4),a4
		move.l	dosbase(a5),a6
		jsr	_LVOUnLoadSeg(a6)
		cmp.l	#$70ff4e75,a4
		bne.b	.w
.wech:	
		rts
freesavers:
		move.l	firstsaver(a5),a4
		bra.b	freesave

;-------- Lade Listen Config -----------------------------------------
;
loadlistconf:
		move.l	a0,d1
		move.l	d1,d5
		move.l	#MODE_OLDFILE,d2
		move.l	dosbase(a5),a6
		jsr	_LVOOpen(a6)
		tst.l	d0
		beq.w	ll_makedefault	;Fülle die Liste mit dafaultwerten
		
.fok		move.l	d0,filehandle(a5)

		move.l	d5,a1
		bsr.l	filesize1
		tst.l	d0
		beq.b	.o
.we		move.l	filehandle(a5),d1
		jmp	_LVOClose(a6)

.o		move.l	size(a5),d0
		move.l	d0,APG_Free3(a5)

		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		tst.l	d0
		beq.b	.we
		move.l	d0,APG_Free2(a5)

		move.l	filehandle(a5),d1
		move.l	d0,d2
		move.l	size(a5),d3
		move.l	dosbase(a5),a6
		jsr	_LVORead(a6)
		tst.l	d0
		bpl.b	.w
		move.l	filehandle(a5),d1
		jsr	_LVOClose(a6)
		move.l	APG_Free2(a5),a1
		move.l	4.w,a6
		jmp	_LVOFreeVec(a6)

		
.w		move.l	filehandle(a5),d1
		jsr	_LVOClose(a6)

		move.l	APG_Free2(a5),a0
		move.l	loadsavemark(a5),d0
		lsl.l	#2,d0
		lea	nc_prefsheader(pc),a1
		lea	(a1,d0.l),a1
		move.l	(a1),d0
		cmp.l	(a0)+,d0
		bne.w	ncl_lwech
		cmp.l	#nc_prefsversion,(a0)
		bmi.w	ncl_lwech		;Zu alte Prefsversion


		bsr.w	nc_holemainlist

	;--------------------------------------------------------------

		move.l	APG_Free2(a5),a3
		addq.l	#8,a3		;Header überlesen

		move.l	APG_Free3(a5),d7   ;Filelänge
		subq.l	#8,d7
		divu	#NS_SAVELISTsizeof,d7
		swap	d7
		tst.w	d7
		bne.w	ncl_lwech
		swap	d7
		subq.l	#1,d7
		
		move.l	loadsavemark(a5),d0
		lsl.l	#2,d0
		lea	nc_nodelist(pc),a0
		move.l	(a0,d0.l),d5	;Node List

	;*--- Adde Nodes -----*

NCl_lnewnode:
		lea	NS_MOTHERNODENAME(a3),a1
		move.l	d5,a0
		move.l	4.w,a6
		jsr	_LVOFindName(a6)
		tst.l	d0
		bne.b	.nodeok
		lea	NS_SAVELISTsizeof(a3),a3
		bra.w	ncl_nixnode

.nodeok:
		move.l	d0,APG_Free4(a5)	;Node merken
		
		moveq	#NC_NODEsizeof,d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		tst.l	d0
		bne.b	.nc_addnodememok

		lea	nc_notenoughmem(pc),a4
		bsr.l	status
		bra.w	ncl_lwech

.nc_addnodememok:

		move.l	a4,a0		;Node List
		move.l	d0,a1		;neue Node

		ADDTAIL

	*-- Fülle neue Node mit Stuff --*

		move.l	d5,a0		;Node List

		lea	NC_NAMESTRING(a1),a2
		move.l	a2,NC_NAME(a1)
		moveq	#22-1,d6
.ns:		move.b	(a3)+,(a2)+
		dbra	d6,.ns

		lea	NC_PREFS(a1),a2
		moveq	#50-1,d6
.np:		move.b	(a3)+,(a2)+
		dbra	d6,.np

		move.l	(a3)+,NC_PREFSLEN(a1)

		lea	NC_MOTHERNODENAME(a1),a2
		moveq	#20-1,d6
.mn:		move.b	(a3)+,(a2)+
		dbra	d6,.mn


		move.l	APG_Free4(a5),a0
		move.l	14(a0),NC_JUMP(a1)

		move.l	30(a0),d6	;Taglist der original node

		move.l	utilbase(a5),a6
		
		clr.l	NC_PREFSROUT(a1)

		move.l	a1,-(a7)

		move.l	d6,a0
		move.l	#APT_Prefs,d0
		jsr	_LVOFindTagItem(a6)		
		move.l	(a7)+,a1
		tst.l	d0
		beq.b	.nc_noprefs
		move.l	d0,a0
		move.l	4(a0),NC_PREFSROUT(a1)

		move.l	a1,-(a7)
		move.l	d0,a0
		move.l	#APT_Prefsbuffer,d0
		jsr	_LVOFindTagItem(a6)		
		move.l	(a7)+,a1
		tst.l	d0
		bne.b	.nc_ok
		clr.l	NC_PREFSROUT(a1)
		bra.b	.nc_noprefs
.nc_ok		move.l	d0,a0
		move.l	4(a0),a0
		move.l	a0,NC_PREFSORIBUF(a1)
.nc_noprefs
ncl_nixnode:
		dbra	d7,ncl_lnewnode
ncl_lwech:
		move.l	APG_Free2(a5),a1
		move.l	4.w,a6
		jmp	_LVOFreeVec(a6)


_loadername:	dc.l	loaderlistname
_savername:	dc.l	saverlistname
_operatorname	dc.l	operatorlistname

loaderlistname:		dc.b	'ENV:ArtPRO/loaderdefault.cfg',0
saverlistname:		dc.b	'ENV:ArtPRO/saverdefault.cfg',0
operatorlistname:	dc.b	'ENV:ArtPRO/operatordefault.cfg',0

	even

;---------------------------------------------------------------------------
;--- Übernehme einfach die geladenen Loader/Saver in die Liste -------------
;---------------------------------------------------------------------------
ll_makedefault:
		move.l	loadsavemark(a5),d0
		lsl.l	#2,d0
		lea	nc_nodelist(pc),a0
		move.l	(a0,d0.l),a0	;Node List
		move.l	(a0),d5

		bsr.w	nc_holemainlist
		move.l	a4,APG_Free1(a5)

ll_newnode:

;		tst.l	(a0)		;keine Nodes mehr ?
;		beq	ll_enddefault

		moveq	#NC_NODEsizeof,d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		tst.l	d0
		bne.b	ll_addnodememok

		lea	nc_notenoughmem(pc),a4
		bra.l	status			;Kein Speicher mehr
		
ll_addnodememok:
		move.l	d0,-(a7)

		move.l	APG_Free1(a5),a0	;Node List
		move.l	(a7)+,a1		;neue Node

		ADDTAIL

	*-- Fülle neue Node mit Stuff --*

		move.l	d5,a0			;Mothernode
		move.l	14(a0),NC_JUMP(a1)	;eigendliche Routine

		*-- Übertrage name --*
	
		move.l	LN_NAME(a0),a2		;Originaler Name
		lea	NC_NAMESTRING(a1),a3
		lea	NC_MOTHERNODENAME(a1),a4
		move.l	a3,NC_NAME(a1)
.nc		move.b	(a2)+,d0
		beq.b	.wech
		move.b	d0,(a3)+
		move.b	d0,(a4)+
		bra.b	.nc
.wech:		clr.b	(a3)
		clr.b	(a4)

	*-- Kopiere Prefs --*

		move.l	a1,a4		;aktuelle neue Node
		move.l	30(a0),a3	;Taglist der original node

		move.l	utilbase(a5),a6
		
		clr.l	NC_PREFSROUT(a4)

		move.l	a3,a0
		move.l	#APT_Prefs,d0
		jsr	_LVOFindTagItem(a6)		
		tst.l	d0
		beq.b	.ll_noprefs
		move.l	d0,a0
		move.l	4(a0),NC_PREFSROUT(a4)

		move.l	a3,a0
		move.l	#APT_Prefsbuffersize,d0
		jsr	_LVOFindTagItem(a6)		
		tst.l	d0
		bne.b	.nc_prefsbuffer
.nc_nop		clr.l	NC_PREFSROUT(a4)
		bra.b	.ll_noprefs
.nc_prefsbuffer:
		move.l	d0,a0
		move.l	4(a0),NC_PREFSLEN(a4)	;Länge der Prefs

		move.l	a3,a0
		move.l	#APT_Prefsbuffer,d0
		jsr	_LVOFindTagItem(a6)		
		tst.l	d0
		beq.b	.nc_nop
		move.l	d0,a0
		move.l	4(a0),a0
		move.l	a0,NC_PREFSORIBUF(a4)

		move.l	NC_PREFSLEN(a4),d7
		subq.l	#1,d7
		lea	NC_PREFS(a4),a1
.np		move.b	(a0)+,(a1)+		;Kopiere prefs
		dbra	d7,.np
.ll_noprefs:
		move.l	d5,a0
		move.l	(a0),a0
		tst.l	(a0)
		beq.b	ll_enddefault
		move.l	a0,d5
		bne.w	ll_newnode
ll_enddefault:
		rts

;---------------------------------------------------------------------------
;---- Gebe Speicher für die Listen frei
;---------------------------------------------------------------------------
freelisten:
		lea	nc_loadernode,a3
		bsr.b	clearnodes
		lea	nc_savernode,a3
		bra.w	clearnodes

clearnodes:
		IFEMPTY	a3,.nonode

		move.l	(a3),d5
		beq.b	.nonode
.nextnode	move.l	d5,a1
		move.l	a1,a3
		move.l	(a1),d5		;next node
		beq.b	.nonode
		
		REMOVE

		move.l	a3,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)

		bra.b	.nextnode

.nonode:
		rts

;--------------------------------------------------------------------------
initloadersaver:

;Raw saver Init:
		st	SRAW_outsource(a5)
		st	SRAW_blitnone(a5)
		st	SRAW_asmsource(a5)
		st	SRAW_word(a5)
		move.b	#1,sraw_widthtag(a5)
		st	SRAW_dtabs(a5)
		move.b	#2,sraw_indents(a5)	
		move.b	#8,sraw_entri(a5)

;Palette saver init

		st	pal_source(a5)
		st	pal_copper(a5)
		st	pal_asmsource(a5)
		st	pal_depth4(a5)
		st	pal_word(a5)
		move.b	#1,pal_widthtag(a5)
		st	pal_dtabs(a5)
		move.b	#2,pal_indents(a5)	
		move.b	#8,pal_entri(a5)

;Sprite saver Init
		st	spr_source(a5)
		st	spr_spritewidth16(a5)
		st	spr_sprite04(a5)
		st	spr_cwnone(a5)
		st	spr_asmsource(a5)
		st	spr_byte(a5)
		st	spr_dtabs(a5)
		move.b	#2,spr_indents(a5)	
		move.b	#8,spr_entri(a5)

;Chunky Saver Init

		st	chk_source(a5)
		st	chk_normaltype(a5)
		st	chk_righttype(a5)
		move.b	#1,chk_normaltypetag(a5)
		st	chk_24bit(a5)
		move.b	#2,chk_rgbtypetag(a5)
		st	chk_asmsource(a5)
		st	chk_word(a5)
		move.b	#1,chk_widthtag(a5)
		st	chk_dtabs(a5)
		move.b	#2,chk_indents(a5)	
		move.b	#8,chk_entri(a5)

;Color loader init

		st	lpal_iff(a5)
		st	lpal_depth4(a5)

;Init IFF_Saver
		st	SIFF_Pack(a5)
		
;Init für Random Dither

		move.l	#45,ren_damount(a5)

		rts

;---------------------------------------------------------------------------
;	sortiert eine node liste nach den namen
;>a0 liste
sortnodes:
		move.l	a5,-(a7)
		move.l	a0,d5	;ersma merken
		move.l	a0,a4
		moveq	#0,d7
.newnode:
		move.l	(a4),d0
		beq	sn_end
		move.l	d0,a4
.newnode1:
		move.l	LN_NAME(a4),a1
		move.l	(a4),d0
		beq	sn_end
		move.l	d0,a5
	tst.l	(a5)
	beq	sn_end
		move.l	LN_NAME(a5),a3
		bsr	sn_compare		;vergleiche die strings in a1,a3
		tst.l	d0
		beq	.noswap

;tausche die nodes in der liste

		move.l	a4,a1
		REMOVE

		move.l	d5,a0		;liste
		move.l	a4,a1		;einzufügene node
		move.l	a5,a2
		move.l	4.w,a6
		jsr	_LVOInsert(a6)
		moveq	#-1,d7		;flag das was getauscht wurde
		bra	.newnode1
		
.noswap:	move.l	a5,a4
		bra	.newnode1

sn_end
		tst.l	d7
		beq	.wech
		move.l	d5,a4
		moveq	#0,d7
		bra	sortnodes\.newnode
.wech
		move.l	(a7)+,a5
		rts

sn_compare:
.next
		move.b	(a1)+,d0
		beq	.testend
		move.b	(a3)+,d1
		beq	.kleiner
		bclr	#5,d0
		bclr	#5,d1		;auf großbuchstaben bringen
		cmp.b	d0,d1
		blo	.kleiner
		bhi	.greater
		beq	.gleich
.gleich:	
		bra	.next

.testend:	tst.b	(a3)		;andere string auch zuende
		bne	.greater	;sie sind gleich

.kleiner:	moveq	#1,d0		;es muß getauscht werden
		rts
.greater:	moveq	#0,d0		;es braucht nicht getauscht werden
		rts


;***************************************************************************
;*---------------------- Warte auf Eingaben -------------------------------*
;***************************************************************************
wait:
		move.l	a0,port(a5)
waitagain:
		move.l	port(a5),a0
		move.l	wd_Userport(a0),a0	;Zeige auf MsgPort
		move.l	a0,a4			;Sichern
		move.l	4,a6
		jsr	_LVOwaitport(a6)	;warte auf Nachricht	

		move.l	a4,a0			;hole Port-Adresse
		move.l	gadbase(a5),a6
		jsr	_LVOGT_getimsg(a6)	;hole Msg
		tst.l	d0
		beq.b	waitagain
		move.l	d0,a1			;muss nach a1
		move.l	im_Class(a1),d4		;Msg-Type
		move.w	im_Code(a1),d5		;Untergruppe
		move.l	im_Seconds(a1),d6	;Systemzeit
		move.w	im_Qualifier(a1),d3
		move.l	im_IAddress(a1),a4	;Adr. für Gadgets
.weit		jmp	_LVOGT_replyiMsg(a6)	;quittiere Msg in a1

;***************************************************************************
;*---------------- Warte auf Eingaben und werte aus -----------------------*
;***************************************************************************
waitaction:
		move.l	mainwinWnd(a5),a0
		move.l	wd_Userport(a0),a0	;Zeige auf MsgPort
		move.l	a0,port(a5)		;Sichern

		moveq	#0,d0
		move.b	MP_SIGBIT(a0),d1
		bset	d1,d0

		move.l	appmsgport(a5),d2
		beq.b	.noappmsg
		move.l	d2,a0
		move.b	MP_SIGBIT(a0),d1
		bset	d1,d0
.noappmsg:		
		move.l	rxPort(a5),d2
		beq.b	.norexx
		move.l	d2,a0
		move.b	MP_SIGBIT(a0),d1
		bset	d1,d0
.norexx:
		move.l	d0,SignalBits(a5)

	*--------------------- Wait ---------------------*
waitagain1:

;kucke nach alten msg's

		move.l	port(a5),a0		;hole Port-Adresse
		move.l	gadbase(a5),a6
		jsr	_LVOGT_getimsg(a6)	;hole Msg
		tst.l	d0
		bne.b	wp_checkmsg

		move.l	AppMsgPort(a5),a0	;hole Port-Adresse
		move.l	gadbase(a5),a6
		jsr	_LVOGT_getimsg(a6)	;hole Msg
		tst.l	d0
		bne.w	checkapp

		move.l	rxPort(a5),a0		;hole Port-Adresse
		move.l	4.w,a6
		jsr	_LVOGetMsg(a6)		;hole Msg
		tst.l	d0
		bne.w	checkrexx

;warten auf msg
		move.l	SignalBits(a5),d0
		move.l	4.w,a6
		jsr	_LVOwait(a6)		;warte auf Nachricht	

		moveq	#0,d1
		move.l	port(a5),a0
		move.b	MP_SIGBIT(a0),d1
		btst	d1,d0
		bne.b	WartenMainwin

		move.l	appmsgport(a5),d2
		beq.b	.checkrx
		move.l	d2,a0
		move.b	MP_SIGBIT(a0),d1
		btst	d1,d0
		bne.b	wartenappwindow
.checkrx
		move.l	rxPort(a5),d2
		beq.b	waitagain1
		move.l	d2,a0
		move.b	MP_SIGBIT(a0),d1
		btst	d1,d0
		bne.w	wartenrxport

		bra.b	waitagain1

WartenMainwin:
		move.l	port(a5),a0		;hole Port-Adresse
		move.l	gadbase(a5),a6
		jsr	_LVOGT_getimsg(a6)	;hole Msg
		tst.l	d0
		beq.w	waitagain1
wp_checkmsg
		move.l	d0,a1			;muss nach a1
		move.l	im_Class(a1),d4		;Msg-Type
		move.w	im_Code(a1),d5		;Untergruppe
		move.l	im_Seconds(a1),d6	;Systemzeit
		move.w	im_Qualifier(a1),d3
		move.l	im_IAddress(a1),a4	;Adr. für Gadgets
.weit		jsr	_LVOGT_replyiMsg(a6)	;quittiere Msg in a1

		jsr	memcheck
		
		cmp.l	#IDCMP_NewSize,d4
		beq.w	handlenewsize
		cmp.l	#IDCMP_CLOSEWINDOW,d4
		beq.w	endall1
		cmp.l	#GADGETUP,d4
		beq.w	gads
		cmp.l	#IDCMP_VANILLAKEY,d4
		beq.w	tast		;es wurde eine Taste gedrückt

		bra.w	waitagain1	;nichts wichtiges

;-----------------------------------------------------------------------------
wartenappwindow:
		move.l	AppMsgPort(a5),a0	;hole Port-Adresse
		move.l	gadbase(a5),a6
		jsr	_LVOGT_getimsg(a6)	;hole Msg
		tst.l	d0
		beq.w	waitagain1
checkapp:
		move.l	d0,a1			;muss nach a1
		move.w	am_Type(a1),d4		;Msg-Type
		move.l	am_ArgList(a1),a4	;WBArgs

		cmp.w	#MTYPE_APPWINDOW,d4
		bne.w	waitagain1

		move.l	wa_Name(a4),a3
		tst.b	(a3)
		bne.b	.file
.wech		jsr	_LVOGT_replyiMsg(a6)	;quittiere Msg in a1
		bra.w	waitagain1
.file:
		lea	FileName(a5),a0		;Kopiere Filename in Puffer
.nm:		move.b	(a3)+,d0
		beq.b	.endname
		move.b	d0,(a0)+
		bra.b	.nm
.endname:
		clr.b	(a0)+
;hole Directory
		move.l	a1,-(a7)
		move.l	wa_Lock(a4),d1
		lea	cb_farbtab4,a3
		move.l	a3,d2
		move.l	#260*2,d3
		move.l	dosbase(a5),a6
		jsr	_LVONameFromLock(a6)
		move.l	(a7)+,a1
		tst.l	d0
		beq.b	.wech
		move.l	a3,dirname(a5)

		move.l	gadbase(a5),a6
		jsr	_LVOGT_replyiMsg(a6)	;quittiere Msg in a1

		jsr	memcheck
		
		bra.w	loadappfile

;-----------------------------------------------------------------------------
wartenrxport:
		move.l	rxPort(a5),a0		;hole Port-Adresse
		move.l	4.w,a6
		jsr	_LVOGetMsg(a6)		;hole Msg
		tst.l	d0
		beq.w	waitagain1
checkrexx:
		move.l	d0,a1			;muss nach a1
          	move.l   ARG0(a1),d0      ; Kommandozeile holen

		move.l	4.w,a6
		jsr	_LVOReplyMsg(a6)

		bra.w	waitagain1	;nichts wichtiges

;***************************************************************************
;*------------------------ Werte Gadgets aus ------------------------------*
;***************************************************************************
gads:
		moveq	#0,d0
		move.w	38(a4),d0
		cmp.w	#GD_gexit,d0
		beq.w	endall1		;beende Programm
		cmp.w	#GD_gload,d0
		beq.w	Load
		cmp.w	#GD_gsave,d0
		beq.w	save
		cmp.w	#GD_gviewpic,d0
		beq.w	viewpic
		cmp.w	#GD_gcutbrush,d0
		beq.w	cutbrush
		cmp.w	#GD_gpreferences,d0
		beq.l	settings
		cmp.w	#GD_gabout,d0
		beq.l	about
		cmp.w	#GD_giconify,d0
		beq.l	iconify
		cmp.w	#GD_gexecutepalette,d0
		beq.l	palette
		cmp.w	#GD_glockmon,d0
		beq.l	lockmon
		cmp.w	#GD_gloadrout,d0
		beq.w	chooseloaderoutineNew	;chooseloadroutine
		cmp.w	#GD_gsaverout,d0
		beq.w	choosesaveroutineNew
		cmp.w	#GD_gmon,d0
		beq.l	changemoni
		cmp.w	#GD_gexecuteoperator,d0
		beq.l	makeoperator
		cmp.w	#GD_gpaletteoption,d0
		beq.l	colorbias
		cmp.w	#GD_grenderset,d0
		beq.w	rendercontrol
		cmp.w	#GD_goperator,d0
		beq	chooseoperatorroutine
		cmp.w	#GD_gclear,d0
		beq	clearbrush
		cmp.w	#GD_gundo,d0
		beq.l	undo
		cmp.w	#GD_gredo,d0
		beq.l	redo
		
		bra.w	waitaction	;kein Gadget dabei
		
;-------------------------------------------------------------------
endall1:
		move.w	d3,d0
		and.w	#IEQUALIFIER_LSHIFT,d0
		cmp.w	#IEQUALIFIER_LSHIFT,d0
		beq.b	.nosave
		and	#IEQUALIFIER_RSHIFT,d3
		cmp.w	#IEQUALIFIER_RSHIFT,d3
		bne.b	endall2		
.nosave:
		move.l	#'NOSA',Free1(a5)
endall2:

		tst.b	askforexit(a5)
		beq.w	endall

		lea	exitmsg(pc),a1
		lea	exitmsg1(pc),a2
		sub.l	a3,a3
		sub.l	a4,a4
		lea	tagitemliste1,a0
		move.l	reqtbase(a5),a6
		jsr	_LVOrtEZRequestA(a6)
		tst.l	d0
		beq.w	waitaction
		bra.w	endall

exitmsg:
		dc.b	'Really Exit?',0
exitmsg1:
		dc.b	'Yes|No',0

	even

;***************************************************************************
;*------------------------ Werte Tasten aus -------------------------------*
;***************************************************************************
tast:
		move.l	mainwinWnd(a5),aktwin(a5)
		lea	mainwinGadgets,a0
		move.l	d5,d3
		cmp.w	#'l',d3
		bne.b	.noload
		lea	load(pc),a3
		move.l	#GD_gload,d0
		bra.w	setandjump
.noload:		
		cmp.w	#'s',d3
		bne.b	.nosave
		lea	save(pc),a3
		move.l	#GD_gsave,d0
		bra.w	setandjump
.nosave:
		cmp.w	#'x',d3
		bne.b	.noexit
		lea	endall1(pc),a3
		move.l	#GD_gexit,d0
		bra.w	setandjump
.noexit:
		cmp.w	#'X',d3
		bne.b	.noexit1
		lea	endall2(pc),a3
		move.l	#'NOSA',Free1(a5)
		move.l	#GD_gexit,d0
		bra.w	setandjump
.noexit1:
		cmp.w	#'a',d3
		bne.b	.noabout
		lea	about,a3
		move.l	#GD_gabout,d0
		bra.w	setandjump
.noabout:
		cmp.w	#'g',d3
		bne.b	.noprefs
		lea	settings(pc),a3
		move.l	#GD_gpreferences,d0
		bra.w	setandjump
.noprefs:
		cmp.w	#'r',d3
		bne.b	.noview
		lea	viewpic(pc),a3
		move.l	#GD_gviewpic,d0
		bra.w	setandjump
.noview:
		cmp.w	#'c',d3
		bne.b	.nocut
		lea	cutbrush(pc),a3
		move.l	#GD_gcutbrush,d0
		bra.w	setandjump
.nocut:
		cmp.w	#'m',d3
		bne.b	.nomon
		lea	changemoni,a3
		move.l	#GD_gmon,d0
		bra.w	setandjump
.nomon:
		cmp.w	#'i',d3
		bne.b	.noiconify
		lea	iconify,a3
		move.l	#GD_giconify,d0
		bra.w	setandjump
.noiconify:
		cmp.w	#'t',d3
		bne.b	.nocolor
		lea	palette,a3
		move.l	#GD_gexecutepalette,d0
		bra.w	setandjump
.nocolor:
		cmp.w	#'e',d3
		bne.b	.nooperator
		tst.w	loadflag(a5)
		beq	.nooper

		lea	makeoperator,a3
		move.l	#GD_gexecuteoperator,d0
		bra.b	setandjump
.nooperator:
		cmp.w	#'1',d3
		bne.b	.noloadrout
		lea	chooseloaderoutineNew(pc),a3
		move.l	#GD_gloadrout,d0
		bra.b	setandjump
.noloadrout:
		cmp.w	#'2',d3
		bne.b	.nosaverout
		lea	choosesaveroutineNew(pc),a3
		move.l	#GD_gsaverout,d0
		bra.b	setandjump
.nosaverout:
		cmp.w	#'3',d3
		bne.b	.nomoni
		lea	changemoni,a3
		move.l	#GD_gmon,d0
		bra.b	setandjump
.nomoni:
		cmp.w	#'d',d3
		bne.b	.norender
		lea	rendercontrol(pc),a3
		move.l	#GD_grenderset,d0
		bra.b	setandjump
.norender:
		cmp.w	#'b',d3
		bne.b	.nobias
		lea	colorbias,a3
		move.l	#GD_gpaletteoption,d0
		bra.b	setandjump
.nobias
		cmp.w	#'4',d3
		bne.b	.nooper
		lea	chooseoperatorroutine(pc),a3
		move.l	#GD_goperator,d0
		bra.b	setandjump
.nooper:
		bra.w	waitaction


;***************************************************************************
;*--------------- selecte Gadget und jump zur Routine ---------------------*
;***************************************************************************
;a0=Gadgets d0=Gadget a3=Routine, in aktwin das aktuelle Fenster
setandjump:
		lsl.l	#2,d0
		move.l	(a0,d0.l),a0
		move.l	a0,gadmerk(a5)
		or.w	#$80,gg_Flags(a0)	;setzte Gadget Selected
		bsr.b	.refresh

		moveq	#5,d1
		move.l	dosbase(a5),a6
		jsr	_LVODelay(a6)

		move.l	gadmerk(a5),a0
		and.w	#$ff7f,gg_Flags(a0)
		bsr.b	.refresh

		jmp	(a3)
.refresh:
		move.l	aktwin(a5),a1
		sub.l	a2,a2
		moveq	#1,d0
		move.l	intbase(a5),a6
		jmp	_LVORefreshGlist(a6)

;---- zeichne neu wenn Zoom Gadget geklickt -----
handlenewsize:
		moveq	#-6,d0
		move.b	d0,iconifyflag(a5)
		jsr	mainwinRender

		move.l	TAG_monitor,d5
		move.l	#GD_gmonitor,d6
		bsr.w	setnewname
		move.l	TAG_project,d5
		move.l	#GD_gproject,d6
		bsr.w	setnewname
;		move.l	TAG_cutmode,d5
;		move.l	#GD_gcutmode,d6
;		bsr.w	setnewname
		move.l	#GD_gpaletteoption,d6

		move.l	#GD_geffect,d6
		move.l	TAG_effect,d5
		bsr.w	setnewname

		bra.l	ic_makegads

;***************************************************************************
;*-------------------------- Lade File ------------------------------------*
;***************************************************************************
load:
		tst.l	loader(a5)
		bne.b	.lok
		lea	noloadermsg(pc),a4
		bsr.l	status
		bra.w	waitaction
.lok:
		cmp.l	#loadscreen,loader(a5)
		bne.b	.noscreen
		move.l	loader(a5),a0
		jmp	(a0)		;Springe loader für Screen extra an
.noscreen:				

		move.l	mainwinWnd(a5),a1
;		move.l	a1,a0

		move.l	StruckAdr(a5),a1

		lea	FileName(a5),a2			
		lea	loadfile,a3
		lea	TagItemListe,a0		;Tag-Liste
		move.l	reqtbase(a5),a6
		jsr	_LVORTFileRequestA(a6)
		tst.l	d0
		bne.b	loadok			;File ok	
		lea	loaderrormsg,a4
		jsr	status			;Loaderror ausgeben

		move.l	mainwinWnd(a5),a1
	;	bsr.w	gadson
		move.l	a1,a0
;		bsr.w	clearwaitpointer

		bra.w	waitaction
loadok:

		lea	FileName(a5),a0		;damit in save der
		lea	SFileName(a5),a1	;selbe filename steht
.w		move.b	(a0)+,(a1)+
		bne	.w
		clr.b	(a1)+

		move.l	struckadr(a5),a0
		move.l	16(a0),dirname(a5)

; ============== Loadnamen zusammenstellen =================
loadappfile:
		lea	loadname(a5),a0
		move.l	dirname(a5),a1
		tst.b	(a1)
		beq.b	no
newchar:
		move.b	(a1)+,(a0)+
		bne.b	newchar
		subq.l	#2,a0
		cmp.b	#':',(a0)+
		beq.b	no
		move.b	#'/',(a0)+
no:		lea	filename(a5),a1
		moveq	#0,d0
newchar1:
		move.b	(a1)+,(a0)+
		addq.b	#1,d0
		tst.b	(a1)
		bne.b	newchar1
		move.b 	d0,filelenght(a5)
		move.b	#0,(a0)

;--------------------------------
loadnow:
		move.l	endbase(a5),d0		;
		sub.l	startbase(a5),d0	;
		lea	BufNewGad,a1
		cmp.l	68(a1),d0
		beq.b	.w			;
		move.l	execbasepuffer(a5),a0	;
		move.l	mainwinWnd(a5),(a0)	;
		jmp	memcheck		;

.w
		cmp.l	#loadcolor,loader(a5)
		beq.b	.w1
		cmp.l	#loadcoloriff,loader(a5)
		beq.b	.w1
		jsr	oldpicwech	;Altes Bild freigeben
.w1
		lea	loadfilemsg,a4
		jsr	status

		jsr	filesize
		tst.l	d0
		beq.b	.openfile
		bra.w	.errmsg			;Fehler
.openfile	lea	loadname(a5),a1
		move.l	a1,d1
		move.l	#1005,d2
		move.l	dosbase(a5),a6
		jsr	_LVOopen(a6)		;Open File
		move.l	d0,filehandle(a5)		
		bne.b	.openok
		bra.w	.errmsg			;konnte nicht geöffnet werden
.openok
		move.l	mainwinWnd(a5),a0
	;	jsr	setwaitpointer

		clr.b	usedatatype(a5)
		
		st	newloaded(a5)
		
		move.l	rndr_rendermem(a5),d0
		beq.b	.wp

		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
		clr.l	rndr_rendermem(a5)
		clr.l	rndr_rgb(a5)
		clr.l	rndr_chunky(a5)
.wp
		cmp.l	#loadcolor,loader(a5)
		beq.b	.w2
		cmp.l	#loadcoloriff,loader(a5)
		beq.b	.w2


		tst.b	ham(a5)
		beq.b	.noh
		move.w	#'M6',anzcolor(a5)
.noh		tst.b	ham8(a5)
		beq.b	.noh8
		move.w	#'M8',anzcolor(a5)
.noh8		tst.b	ehb(a5)
		beq.b	.noehb
		move.w	#'HB',anzcolor(a5)
.noehb:
		
		sf	ham(a5)
		sf	ham8(a5)
		sf	ehb(a5)

		move.l	renderbase(a5),a6
		move.l	rndr_histogram(a5),d0
		beq.b	.w2
		move.l	d0,a0
		jsr	_LVODeleteHistogram(a6)
		clr.l	rndr_histogram(a5)
.w2

	;*--- Kopiere Prefs ----*
	
		move.l	loadernode(a5),a0
		tst.l	NC_PREFSROUT(a0)
		beq.b	.noprefs		
		move.l	NC_PREFSORIBUF(a0),a1
		move.l	NC_PREFSLEN(a0),d7
		subq.w	#1,d7
		lea	NC_PREFS(a0),a0
.np		move.b	(a0)+,(a1)+
		dbra	d7,.np
.noprefs:
		move.l	mainwinwnd(a5),a0
		bsr.l	setwaitpointer

		move.l	loader(a5),a0
		jsr	(a0)

		bsr.l	clearprocess

		move.l	filehandle(a5),d1
		move.l	dosbase(a5),a6
		jsr	_LVOClose(a6)

		cmp.l	#APLE_ABORT,d3
		bne.b	.na
		lea	loadingabortmsg(pc),a4
		jsr	status
		move.l	mainwinwnd(a5),a0
		bsr.l	clearwaitpointer
		bra.w	waitaction

.na:		cmp.l	#-4,d3
		bne.b	.ww2
		lea	notmemmsg,a4
		jsr	status
		move.l	mainwinwnd(a5),a0
		bsr.l	clearwaitpointer
		bra.w	waitaction
		
.ww2:		cmp.l	#-3,d3		;file nicht erkannt
		beq.b	.errmsg
		
		cmp.l	#-2,d3
		beq.b	.r1

		cmp.l	#-1,d3
		bne.b	.ready		;Fehler beim Laden ?
		move.l	mainwinwnd(a5),a0
		bsr.l	clearwaitpointer
		bra.w	waitaction
.errmsg:
		lea	loaderrormsg,a4
		jsr	status
		move.l	mainwinwnd(a5),a0
		bsr.l	clearwaitpointer
		bra.w	waitaction
		
.ready:		lea	readymsg,a4
		jsr	status

		tst.b	ehb(a5)
		beq	.r1
		bsr	makeehpalette

.r1:
		tst.b	mpreview(a5)
		beq	.nixp
		bsr	makepreview
.nixp:
		move.l	mainwinwnd(a5),a0
		bsr.l	clearwaitpointer

		move.w	anzcolor(a5),anzcolorbak(a5)
		tst.b	ehb(a5)
		beq.b	.neh
		move.w	#'HB',anzcolorbak(a5)
		move.l	#32,ren_colorlevel(a5)
.neh:		tst.b	ham(a5)
		beq.b	.nh6
		move.w	#'M6',anzcolorbak(a5)
		move.l	#16,ren_colorlevel(a5)
.nh6:		tst.b	ham8(a5)
		beq.b	.nh8
		move.w	#'M8',anzcolorbak(a5)
		move.l	#64,ren_colorlevel(a5)
.nh8:
		lea	disp(pc),a0
		move.l	displayID(a5),(a0)
		lea	screenmodetag(pc),a0
		move.l	scrmodereq(a5),a1
		move.l	reqtbase1(a5),a6
		jsr	_LVORTChangeReqAttrA(a6)

		jsr	memcheck
		
;init für Palette
		cmp.l	#loadcolor,loader(a5)
		beq.b	.w3
		cmp.l	#loadcoloriff,loader(a5)
		beq.b	.w3
		
		moveq	#1,d0
		move.l	d0,aktcolor(a5)	;Color 1 als Startwert für
		move.l	d0,realaktcolor(a5)
						;Palette
		clr.l	coloroffset(a5)

		moveq	#0,d0

;aktuallisiere Gadgets

		bsr.w	setpicsizegads
.w3
		lea	FileName(a5),a0
		lea	TAG_project,a1
		move.l	a0,(a1)
		move.l	a0,d5
		move.l	#GD_gproject,d6
		bsr.w	setnewname

;Bild puffern

		jsr	APR_Save2TMP(a5)

endcolor:
		tst.b	showpic(a5)
		beq.b	.goout

;Zeige Pic nach dem Laden an

		bsr.w	openpic
		cmp.l	#-1,d0
		beq.w	waitaction
		
		move.l	scr1(a5),a0
		move.l	intbase(a5),a6
		jsr	_LVOScreentoFront(a6)

.waitview:
		move.l	viewWnd(a5),a0
		bsr.w	wait

		cmp.l	#IDCMP_MouseButtons,d4
		beq.b	.pressbutton
		bra.b	.waitview
.pressbutton:
		move.l	scr1(a5),a0
		move.l	intbase(a5),a6
		jsr	_LVOScreentoBack(a6)

		bsr.b	CloseViewWindow
		bsr.b	CloseDownViewScreen
		jsr	memcheck
.goout:
		bra.w	waitaction

CloseViewWindow:
		movem.l d0-d1/a0-a2/a6,-(sp)
		move.l  IntBase(a5),a6
		move.l  ViewWnd(a5),a0
		cmpa.l  #0,a0
		beq.b   ViewNWnd
		jsr	_LVOCloseWindow(a6)
		move.l  #0,ViewWnd(a5)
ViewNWnd:
		move.l  GadBase(a5),a6
		movem.l (sp)+,d0-d1/a0-a2/a6
		rts

CloseDownViewScreen:
		movem.l d0-d1/a0-a1/a6,-(sp)
		move.l  GadBase(a5),a6
		move.l  VisualInfo1,a0
		cmpa.l  #0,a0
		beq.b   NoVis1
		jsr	_LVOFreeVisualInfo(a6)
		move.l  #0,VisualInfo1
NoVis1:
		move.l  IntBase(a5),a6
		move.l  Scr1(a5),a0
		cmpa.l  #0,a0
		beq.s   NoScr1
		jsr	_LVOCloseScreen(a6)
		move.l  #0,Scr1(a5)
NoScr1:
		movem.l (sp)+,d0-d1/a0-a1/a6
		rts

;----------------------------------------------------------------------------------
;verdopple palette bei ehb
makeehpalette:
		lea	APG_Farbtab8(a5),a0
		move.l	#64,d0
		swap	d0
		move.l	d0,(a0)+
		lea	32*4*3(a0),a1
		moveq	#32*3-1,d7
		move.l	(a0)+,d0
		lsr.l	#1,d0
		move.l	d0,(a1)+
		clr.l	(a1)
		move.w	#64,anzcolor(a5)
		rts


screenmodetag:
		dc.l	_RTSC_DisplayID
disp:		dc.l	0
		dc.l	0

loadingabortmsg:	dc.b	'Loading stopped!',0

		even
noloadermsg:	dc.b	'No loader selected!',0
		even	

;***************************************************************************
;*-------------------------- Save File ------------------------------------*
;***************************************************************************
save:
		tst.w	loadflag(a5)
		bne.b	.saveok
		lea	noimageload,a4
		jsr	status
		bra.w	waitaction
.saveok
		tst.l	saver(a5)
		bne.b	.sok
		lea	nosavermsg(pc),a4
		bsr.l	status
		bra.w	waitaction
.sok:
		cmp.b	#24,planes(a5)
		beq.b	.nixrender

		tst.b	APG_RenderFlag(a5)
		beq.b	.nixrender
		lea	rendermsg(pc),a4
		bsr.l	status
		bra.w	waitaction
.nixrender:
		move.l	mainwinWnd(a5),a1
;		move.l	a1,a0

		move.l	StruckAdr1(a5),a1
		lea	SFileName(a5),a2			
		lea	savefile,a3
		lea	TagItemListe,a0		;Tag-Liste
		move.l	reqtbase(a5),a6
		jsr	_LVORTFileRequestA(a6)
		tst.l	d0
		bne.b	saveok			;File ok	
		lea	noimagesavemsg,a4
		jsr	status			;Saveerror ausgeben
		move.l	mainwinWnd(a5),a1
	;	bsr.w	gadson
		move.l	a1,a0
	;	jsr	clearwaitpointer
		bra.w	waitaction
saveok:
		move.l	#640,d1		;für check below
		moveq	#10,d2
		
		move.l	struckadr1(a5),a0
		move.l	16(a0),Sdirname(a5)

; ============== Savenamen zusammenstellen =================

		lea	savename(a5),a0
		move.l	Sdirname(a5),a1
		tst.b	(a1)
		beq.b	sno
snewchar:
		move.b	(a1)+,(a0)+
		bne.b	snewchar
		subq.l	#2,a0
		cmp.b	#':',(a0)+
		beq.b	sno
		move.b	#'/',(a0)+
sno:		lea	Sfilename(a5),a1
		moveq	#0,d0
snewchar1:
		move.b	(a1)+,(a0)+
		addq.b	#1,d0
		tst.b	(a1)
		bne.b	snewchar1
		move.b 	d0,Sfilelenght(a5)
		move.b	#0,(a0)

		moveq	#0,d0
		move.b	check1(a5),d0
		add.w	finalcheck(a5),d0
		cmp.w	locktest(a5),d0
		beq.s	.ok
		moveq	#20,d2
.ok		divu	d2,d1
		lsr	#6,d1
		move.b	d1,APG_Mark1(a5)

		jsr	checkoverwrite
		tst.l	d0
		beq.w	err

	;--- Öffne File ---
		lea	Savename(a5),a1
		move.l	a1,d1
		move.l	#1006,d2	;newfile
		move.l	dosbase(a5),a6
		jsr	_LVOOpen(a6)
		move.l	d0,filehandle(a5)
		beq.w	err

		lea	savefilemsg,a4
		jsr	status

		move.l	savernode(a5),a0
		tst.l	NC_PREFSROUT(a0)
		beq.b	.noprefs
		move.l	NC_PREFSORIBUF(a0),a1
		move.l	NC_PREFSLEN(a0),d7
		subq.w	#1,d7
		lea	NC_PREFS(a0),a0
.np		move.b	(a0)+,(a1)+
		dbra	d7,.np
.noprefs:
		move.l	mainwinwnd(a5),a0
		bsr.l	setwaitpointer

		move.l	saver(a5),a0
		jsr	(a0)		;Springe Saveroutine an

		bsr.l	clearprocess

		move.l	mainwinwnd(a5),a0
		bsr.l	clearwaitpointer
		
		move.l	filehandle(a5),d1
		move.l	dosbase(a5),a6
		jsr	_LVOClose(a6)

		tst.l	d3
		bpl.b	.oksave
		lea	savename(a5),a1
		move.l	a1,d1
		jsr	_LVODeleteFile(a6)  ;lösche File
		cmp.l	#-2,d3
		bne.b	.nixmem
		lea	notenoughtmsg,a4
		jsr	status
		bra.w	waitaction
.nixmem:
		cmp.l	#APSE_Abort,d3
		bne.b	.nixabort
		lea	saveabortmsg(pc),a4
		bsr.l	status
		bra.w	waitaction		
.nixabort:
		cmp.l	#APSE_NoBitmap,d3
		bne.w	waitaction
		lea	nobitmapmsg(pc),a4
		bsr.l	status
		bra.w	waitaction

.oksave
		lea	readymsg,a4
		jsr	status

		move.l	d2,-(a7)
;		bsr.w	makecomment	;Setzte ArtPRO Comment
		move.l	(a7)+,d2
		
		cmp.b	#'c',d2
		bne.w	sok	;keine Colorlist absaven
		
		tst.b	autosavecolor(a5)
		beq.w	sok
		lea	savename(a5),a0
.wei		cmp.b	#0,(a0)+
		bne.b	.wei
		subq.l	#1,a0
		tst.b	pal_binary(a5)
		beq.b	.savesource
		move.b	#'.',(a0)+
		move.b	#'c',(a0)+
		move.b	#'o',(a0)+
		move.b	#'l',(a0)+
		bra.b	.save		
.savesource:
		move.b	#'.',(a0)+
		tst.b	pal_asmsource(a5)
		beq.b	.nasm
		move.b	#'a',(a0)+
		move.b	#'s',(a0)+
		move.b	#'m',(a0)+
		bra.b	.end
.nasm:
		tst.b	pal_scsource(a5)
		beq.b	.noc
		move.b	#'c',(a0)+
		bra.b	.end
.noc:			
		tst.b	pal_pascal(a5)
		beq.b	.nop
		move.b	#'p',(a0)+
		bra.b	.end
.nop:
		tst.b	pal_esource(a5)
		beq.b	.noe
		move.b	#'e',(a0)+
		bra.b	.end
.noe:
		move.b	#'b',(a0)+
		move.b	#'a',(a0)+
		move.b	#'s',(a0)+
		
.end		move.b	#0,(a0)
.save:
		lea	savename(a5),a1
		move.l	a1,d1
		move.l	#1006,d2	;newfile
		move.l	dosbase(a5),a6
		jsr	_LVOOpen(a6)
		move.l	d0,filehandle(a5)
		beq.b	err

		jsr	savecolor

		move.l	filehandle(a5),d1
		move.l	dosbase(a5),a6
		jsr	_LVOClose(a6)

;		bsr.b	makecomment	;Setzte ArtPRO Comment

		bra.b	sok
err:
		lea	saveerrormsg,a4
		jsr	status
		bra.w	waitaction

sok:
		cmp.w	#-1,d3
		beq.b	.noready
		lea	readymsg,a4
		jsr	status
.noready:
		bra.w	waitaction


;---------------------------------------------------------------------------
;setzte Kommenttar im File
;>a0 Saver Name
; d0 breite
; d1 höhe
; d2 tiefe

SetComment:

		lea	keymsgpuffer(a5),a1
.w		move.b	(a0)+,(a1)+
		bne	.w
		subq.l	#1,a1
		move.b	#32,(a1)+	;space einfügen
		bsr.l	sc_hexdez
		move.b	#32,(a1)+
		move.b	#'x',(a1)+
		move.b	#32,(a1)+
		move.l	d1,d0
		move.l	a1,a0
		bsr.l	sc_hexdez
		move.b	#32,(a1)+
		move.b	#'x',(a1)+
		move.b	#32,(a1)+
		move.l	d2,d0
		move.l	a1,a0
		bsr.l	sc_hexdez
		move.b	#32,(a1)+
		lea	commenttext(pc),a0
		moveq	#commlen-1,d7
.nc		move.b	(a0)+,(a1)+
		dbra	d7,.nc

		lea	savename(a5),a1
		move.l	a1,d1
		lea	keymsgpuffer(a5),a1
		move.l	a1,d2
		move.l	dosbase(a5),a6
		jmp	_LVOSetComment(a6)

;------------------------------------------------------------------------
sc_hexdez:
		movem.l	d0-d3,-(a7)
		moveq	#0,d7		;flag für die nullen
		lea	sc_hexdeztab(pc),a0	;Tabellendisgs
		moveq	#4,d3
.Hexdez2:	move.l	(a0)+,d1		;Tabellenzahl
		moveq	#0,d2			;Zahl
.Hexdez3:	addq.l	#1,d2
		sub.l	d1,d0
		bcc.s	.Hexdez3
		add.l	d1,d0
		add.b	#$2f,d2
	cmp.b	#$30,d2
	bne	.cp
	tst.l	d7	;waren schon andere zahlen  ?
	beq	.np	
.cp:		move.b	d2,(a1)+
		moveq	#1,d7
.np:		dbf	d3,.Hexdez2

		movem.l	(a7)+,d0-d3
		rts

sc_Hexdeztab:	dc.l	10000,1000,100,10,1


nobitmapmsg:	dc.b	'No bitmap data present! Render before!',0
rendermsg:	dc.b	'Depth changed! Render new please!',0
saveabortmsg:	dc.b	'File save aborted!',0

commenttext:
		dc.b	'saved with ArtPRO v'
		version	
		dc.b	0

commlen		= *-commenttext

	even		
nosavermsg:	dc.b	'No saver selected!',0

	even
;***************************************************************************
;*---------------------- Wähle LoadSaveRoutine aus ------------------------*
;***************************************************************************

ch_envname:
		dc.b	'ArtPRO/'
		ds.b	8

	even

;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
;--- Neue Loader, Saver, Operator Auswahlroutine mit Listen verwaltung ----
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------

chooseloaderoutineNew:
		move.l	#nc_selectload,loadsavemark(a5)
		lea	newnodelist,a0
		move.l	#nc_loadernode,(a0)
		lea	nc_chooseloader(pc),a0
		lea	newwintitle(pc),a1
		move.l	a0,(a1)
		move.w	nc_lroutine(a5),nc_routine(a5)

		bsr.w	nc_startjetzt		

		tst.l	d7
		bmi.w	waitaction

		move.w	nc_routine(a5),nc_lroutine(a5)
		move.l	APG_Free1(a5),d5	;neuer Name

	move.l	d5,loadername(a5)

		moveq	#GD_gloader,d6
		bsr.w	setnewname

		move.l	APG_Free2(a5),loader(a5)
		move.l	APG_Free3(a5),loadernode(a5)

		tst.l	d7
		beq.w	waitaction

		bra.w	load

choosesaveroutineNew:
		move.l	#nc_selectsaver,loadsavemark(a5)
		lea	newnodelist,a0
		move.l	#nc_savernode,(a0)
		lea	nc_choosesaver(pc),a0
		lea	newwintitle(pc),a1
		move.l	a0,(a1)
		move.w	nc_sroutine(a5),nc_routine(a5)

		bsr.w	nc_startjetzt

		tst.l	d7
		bmi.w	waitaction

		move.w	nc_routine(a5),nc_sroutine(a5)
		move.l	APG_Free1(a5),d5	;neuer Name

	move.l	d5,savername(a5)

		moveq	#GD_gsaver,d6
		bsr.w	setnewname

		move.l	APG_Free2(a5),saver(a5)
		move.l	APG_Free3(a5),savernode(a5)

		tst.l	d7
		beq.w	waitaction

		bra.l	save

chooseoperatorroutine:
		move.l	#nc_selectoperator,loadsavemark(a5)
		lea	newnodelist,a0
		move.l	#nc_operatornode,(a0)
		lea	nc_chooseoperator(pc),a0
		lea	newwintitle(pc),a1
		move.l	a0,(a1)
		move.w	nc_oroutine(a5),nc_routine(a5)

		bsr.b	nc_startjetzt

		tst.l	d7
		bmi.w	waitaction

		move.w	nc_routine(a5),nc_oroutine(a5)
		move.l	APG_Free1(a5),d5	;neuer Name

		move.l	d5,operatorname(a5)

		moveq	#GD_geffect,d6
		bsr.w	setnewname

		move.l	APG_Free2(a5),operator(a5)
		move.l	APG_Free3(a5),operatornode(a5)

		tst.l	d7
		beq.w	waitaction

		bra.l	makeoperator

;----------------------------------------------------------------------------
nc_startjetzt:

	;*------ Ersma ein Fenster öffen ------*

		move.l	mainwinWnd(a5),a0
		jsr	setwaitpointer

		move.l	loadsavemark(a5),d0
		lsl.l	#2,d0
		lea	nc_nodelist1(pc),a0
		move.l	(a0,d0.l),a0

		lea	nc_erasedis,a1
		move.l	#1,(a1)
		lea	nc_stringdis,a2
		move.l	#1,(a2)
		lea	nc_clonedis,a3
		move.l	#1,(a3)
		lea	nc_updis,a4
		move.l	#1,(a4)
		lea	nc_downdis,a6
		move.l	#1,(a6)

		TSTLIST

		beq.b	.emptylist	;Liste ist leer - erase bleibt disabled

		clr.l	(a1)
		clr.l	(a2)
		clr.l	(a3)
		clr.l	(a4)
		clr.l	(a6)
.emptylist:
		lea	newchoosewinWindowTags(pc),a0
		move.l	a0,windowtaglist(a5)
		lea	newchoosewinWG+4(pc),a0
		move.l	a0,gadgets(a5)
		lea	newchoosewinSC+4(pc),a0
		move.l	a0,winscreen(a5)
		lea	newchoosewinWnd(a5),a0
		move.l	a0,window(a5)
		lea	newchoosewinGlist(a5),a0
		move.l	a0,Glist(a5)
		move.l	#newchoosewinNgads,NGads(a5)
		move.l	#newchoosewinGTypes,GTypes(a5)
		move.l	#newchoosewinGadgets,WinGadgets(a5)
		move.w	#newchoosewin_CNT,win_CNT(a5)
		move.l	#newchoosewinGtags,windowtags(a5)
		move.l	scr(a5),screenbase(a5)

		jsr	checkmainwinpos

		movem.l	d0-d1,-(a7)
		move.l	#newchoosewinTop,d0
		bsr.l	computey
		move.l	d0,d2
		move.l	#newchoosewinLeft,d0
		cmp.l	#nc_selectoperator,loadsavemark(a5)
		bne	.w
		move.l	#newchoosewinLeft1,d0
.w		bsr.l	computex
		move.l	d0,d3
		movem.l	(a7)+,d0-d1

		add.l	d3,d0
		add.l	d2,d1

		move.w	d1,WinTop(a5)
		move.w	d0,WinLeft(a5)

		move.w	#newchoosewinWidth,WinWidth(a5)
		move.w	#newchoosewinHeight,WinHeight(a5)
		lea	newchooseWinL(pc),a0
		move.l	a0,WinL(a5)
		lea	newchooseWinT(pc),a0
		move.l	a0,WinT(a5)
		lea	newchooseWinW(pc),a0
		move.l	a0,WinW(a5)
		lea	newchooseWinH(pc),a0
		move.l	a0,WinH(a5)

		jsr	openwindowF

		tst.l	d0
		beq.b	.winok
		move.l	mainwinWnd(a5),a0
		jmp	clearwaitpointer
		
.winok:

		bsr.w	nc_holemainlist

		lea	nc_addtag(pc),a3
		move.l	a4,4(a3)		;GTLV_Labels

		moveq	#0,d5
		move.w	nc_routine(a5),d5
		move.l	d5,12(a3)		;GTLV_Selected
		move.l	d5,20(a3)		;GTLV_MakeVisible

		lea	newchoosewinGadgets,a0
		move.l	(a0),a0
		move.l	newchoosewinWnd(a5),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)


		move.l	a4,a0

		TSTLIST
		beq.b	.noprefs

.nr		move.l	(a0),a0
		dbra	d5,.nr

		move.l	a0,a4

		lea	NC_NAMESTRING(a0),a0
		lea	nc_strtag(pc),a3
		move.l	a0,4(a3)

		lea	newchoosewinGadgets,a0
		move.l	GD_nname<<2(a0),a0
		move.l	newchoosewinWnd(a5),a1
		sub.l	a2,a2
		move.l	Gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		moveq	#GD_nconfig,d0
		moveq	#1,d1
		tst.l	NC_PREFSROUT(a4)
		beq.b	.noprefs
		moveq	#0,d1
.noprefs:
		bsr.w	nc_ghostmain
;-----------------------------------------------------------------------
nc_wait:
		move.l	newchoosewinWnd(a5),a0
		bsr.w	wait		;Warte auf eingabe im Choosewin

		cmp.l	#IDCMP_CLOSEWINDOW,d4
		beq.w	nc_cancel
		cmp.l	#GADGETUP,d4
		beq.b	nc_gads
		cmp.l	#VANILLAKEY,d4
		beq.w	nc_keys
		cmp.l	#RAWKEY,d4
		beq.w	nc_mainarrowsn
		bra.b	nc_wait


;------- Werte gadgets aus ----------------------------------------

nc_gads:
		moveq	#0,d0
		move.w	GG_GadgetID(a4),d0
		add.l	d0,d0
		lea	nc_mainjumptab1(pc),a0
		move.w	(a0,d0.l),d0
		ext.l	d0
		jmp	(a0,d0.l)

nc_mainjumptab1:
		dc.w	nc_newroutw-nc_mainjumptab1
		dc.w	nc_configw-nc_mainjumptab1
		dc.w	nc_clonew-nc_mainjumptab1
		dc.w	nc_addentry-nc_mainjumptab1
		dc.w	nc_earsew-nc_mainjumptab1
		dc.w	nc_nup-nc_mainjumptab1
		dc.w	nc_ndown-nc_mainjumptab1
		dc.w	nc_nload-nc_mainjumptab1
		dc.w	nc_nsave-nc_mainjumptab1
		dc.w	nc_okandmake-nc_mainjumptab1
		dc.w	nc_accept-nc_mainjumptab1
		dc.w	nc_cancel-nc_mainjumptab1
		dc.w	nc_newname2-nc_mainjumptab1


nc_wech:	lea	newchoosewinWnd(a5),a0
		move.l	a0,window(a5)
		lea	newchoosewinGlist(a5),a0
		move.l	a0,Glist(a5)

		jsr	gt_CloseWindow

		lea	nc_choosewinWnd(a5),a0
		tst.l	(a0)
		beq.b	.w
		move.l	a0,window(a5)
		lea	newmodulewinGlist(a5),a0
		move.l	a0,Glist(a5)
		jsr	gt_CloseWindow

.w		move.l	mainwinWnd(a5),a0
		jmp	clearwaitpointer

nc_earsew:
		bsr.w	nc_erase
		bra.w	nc_wait
nc_newname2:
		bsr.w	nc_newname
		bra.w	nc_wait
nc_newroutw:
		bsr.w	nc_newrout
		bra.w	nc_wait
nc_clonew:
		bsr.w	nc_clone
		bra.w	nc_wait
nc_configw:
		bsr.w	nc_config
		bra.w	nc_wait
nc_nup:
		bsr.w	nc_up
		bra.w	nc_wait
nc_ndown:
		bsr.w	nc_down
		bra.w	nc_wait
nc_nsave:
		bsr.w	nc_save
		bra.w	nc_wait
nc_nload:
		bsr.w	nc_load
		bra.w	nc_wait
nc_mainarrowsn:
		bsr.w	nc_mainarrows
		bra.w	nc_wait

;-------------------------------------------------------------------------

nc_keys:
		move.l	newchoosewinWnd(a5),aktwin(a5)
		lea	newchoosewinGadgets,a0

		cmp.w	#27,d5	;ESC
		beq.w	nc_cancel
		cmp.w	#'a',d5
		bne.b	.noadd
		lea	nc_addentry(pc),a3
		move.l	#GD_nadd,d0
		bra.w	setandjump
.noadd:
		cmp.w	#'g',d5
		bne.b	.nocan
		lea	nc_configw(pc),a3
		move.l	#GD_nconfig,d0
		bsr.w	nc_checkghost_
		bra.w	setandjump
.nocan:
		cmp.w	#'n',d5
		bne.b	.noclone
		lea	nc_clonew(pc),a3
		move.l	#GD_nclone,d0
		bsr.w	nc_checkghost_
		bra.w	setandjump
.noclone:
		cmp.w	#'e',d5
		bne.b	.noerase
		lea	nc_earsew(pc),a3
		move.l	#GD_nerase,d0
		bsr.w	nc_checkghost_
		bra.w	setandjump
.noerase:
		cmp.w	#'u',d5
		bne.b	.noup
		lea	nc_nup(pc),a3
		move.l	#GD_nup,d0
		bsr.w	nc_checkghost_
		bra.w	setandjump
.noup:
		cmp.w	#'d',d5
		bne.b	.nodown
		lea	nc_ndown(pc),a3
		move.l	#GD_ndown,d0
		bsr.b	nc_checkghost_
		bra.w	setandjump
.nodown:
		cmp.w	#'t',d5
		bne.b	.noop
		lea	nc_okandmake(pc),a3
		move.l	#GD_nAcceptandLoad,d0
		bra.w	setandjump
.noop:
		cmp.w	#'o',d5
		bne.b	.nook
		lea	nc_accept(pc),a3
		move.l	#GD_nAccept,d0
		bra.w	setandjump
.nook:
		cmp.w	#'c',d5
		bne.b	.nocancel
		lea	nc_cancel(pc),a3
		move.l	#GD_nCancel,d0
		bra.w	setandjump
.nocancel:
		cmp.w	#'l',d5
		bne.b	.noload
		lea	nc_nload(pc),a3
		move.l	#GD_nload,d0
		bra.w	setandjump
.noload:
		cmp.w	#'s',d5
		bne.w	nc_wait
		lea	nc_nsave(pc),a3
		move.l	#GD_nsave,d0
		bra.w	setandjump

		bra.w	nc_wait

nc_checkghost_:
		move.l	(a0,d0.l*4),a1
		move.w	gg_FLAGS(a1),d1
		and.w	#GFLG_DISABLED,d1
		bne.b	.nc_warten
		rts
.nc_warten
		addq.l	#4,a7
		bra.w	nc_wait


;------------------------
nc_accept_:
		addq.l	#4,a7
nc_accept:
		moveq	#0,d7
nc_acc:
		bsr.w	nc_holemainlist

		move.l	a4,a0
		move.w	nc_routine(a5),d0

.nr		move.l	(a0),a0
		dbra	d0,.nr

		move.l	a0,APG_Free3(a5)
		move.l	NC_JUMP(a0),d0
		move.l	d0,APG_Free2(a5)
		lea	NC_NAMESTRING(a0),a0
		move.l	a0,APG_Free1(a5)	;Name merken

		bra.w	nc_wech

nc_okandmake_:
		addq.l	#4,a7
nc_okandmake:
		moveq	#1,d7
		bra.b	nc_acc

nc_cancel:
		moveq	#-1,d7
		bra.w	nc_wech

;--- Es wurde eine neue Routine angewählt ---
nc_newrout:
		cmp.w	nc_routine(a5),d5
		beq.b	.testtime
		move.w	d5,nc_routine(a5)	;Sichere nummer der Routine
		move.w	d6,nc_addtime(a5)
		bra.b	nc_newrout_
.testtime:
		move.w	nc_addtime(a5),d0
		sub.w	d6,d0
		cmp.w	#1,d0
		bls.b	nc_okandmake_
		move.w	d6,nc_addtime(a5)
nc_newrout_:

		bsr.w	nc_holemainlist

		move.l	a4,a0

.nr		move.l	(a0),a0
		dbra	d5,.nr

		move.l	a0,a4

		lea	NC_NAMESTRING(a0),a0
		lea	nc_strtag(pc),a3
		move.l	a0,4(a3)

		lea	newchoosewinGadgets,a0
		move.l	GD_nname<<2(a0),a0
		move.l	newchoosewinWnd(a5),a1
		sub.l	a2,a2
		move.l	Gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		moveq	#GD_nconfig,d0
		moveq	#1,d1
		tst.l	NC_PREFSROUT(a4)
		beq.b	.noprefs
		moveq	#0,d1
.noprefs:
		bsr.w	nc_ghostmain

		rts


;--- Lösche eine Node ----
nc_erase:

		bsr.w	nc_holemainlist

		move.l	a4,a0

		TSTLIST

		bne.b	.clearnode

		rts	;Liste ist leer

;-- alte liste losmachen vom Listview
.clearnode
		bsr.w	nc_detachmain		;Liste detach , losmachen

		bsr.w	nc_holemainlist

		moveq	#0,d0
		move.w	nc_routine(a5),d0
		move.l	a4,a1

.nn		move.l	(a1),a1
		dbra	d0,.nn

		move.l	a1,a2

		REMOVE

		move.l	a2,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)

	*-- Update die Hauptliste im Listview --*

nc_addlist:	lea	nc_addtag1(pc),a3
		move.l	a4,4(a3)		;Node List

		lea	newchoosewinGadgets,a0
		move.l	(a0),a0
		move.l	newchoosewinWnd(a5),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		lea	newchoosewinGadgets,a0
		move.l	(a0),a0
		move.l	newchoosewinWnd(a5),a1
		sub.l	a2,a2
		lea	nc_firsttag(pc),a3
		lea	nc_listpos(pc),a4
		move.l	a4,4(a3)
		tst.b	kick3(a5)
		beq.b	.nokick

;unter Kick3.0 können wir den aktuellen entry abfragen

		jsr	_LVOGT_GetGadgetAttrsA(a6)
		move.l	(a4),d0
		move.w	d0,nc_routine(a5)
		bra.b	.testlist

; Unter Kick 2.0 setzen wir auf dem ersten entry zurück 
.nokick
		clr.l	4(a3)		;auf ersten Tag setzen
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		clr.w	nc_routine(a5)

.testlist:
		bsr.w	nc_holemainlist

		move.l	a4,a0

		TSTLIST
		bne.b	.wech

;ghoste erase gadget da liste leer

		moveq	#GD_nerase,d0
		moveq	#1,d1
		bsr.w	nc_ghostmain

		moveq	#GD_nname,d0
		moveq	#1,d1
		bsr.w	nc_ghostmain

		moveq	#GD_nclone,d0
		moveq	#1,d1
		bsr.w	nc_ghostmain

		moveq	#GD_nup,d0
		moveq	#1,d1
		bsr.w	nc_ghostmain

		moveq	#GD_ndown,d0
		moveq	#1,d1
		bsr.w	nc_ghostmain

		moveq	#GD_nconfig,d0
		moveq	#1,d1
		bsr.w	nc_ghostmain

		lea	nc_strtag(pc),a3
		clr.l	4(a3)

		lea	newchoosewinGadgets,a0
		move.l	GD_nname<<2(a0),a0
		move.l	newchoosewinWnd(a5),a1
		sub.l	a2,a2
		jmp	_LVOGT_SetGadgetAttrsA(a6)

.wech
		moveq	#0,d5
		move.w	nc_routine(a5),d5
		bra.w	nc_newrout_

;--- Clone ein Entry -----
nc_clone:
		bsr.w	nc_holemainlist

		move.l	a4,a0
		TSTLIST

		bne.b	.clonenode
		rts	;Liste ist leer
.clonenode:
		moveq	#NC_NODEsizeof,d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		tst.l	d0
		bne.b	nc_clonenodememok

		lea	nc_notenoughmem(pc),a4
		bra.l	status

nc_clonenodememok:
		move.l	d0,-(a7)

		bsr.w	nc_detachmain		;Liste detach , losmachen

		bsr.w	nc_holemainlist

		moveq	#0,d0
		move.w	nc_routine(a5),d0
		move.l	a4,a2

.nn		move.l	(a2),a2	; zu clonende Node
		dbra	d0,.nn

		move.l	a2,d2

		move.l	(a7)+,a3

		moveq	#NC_NODEsizeof-1,d7
		move.l	a3,a1
.nc		move.b	(a2)+,(a1)+
		dbra	d7,.nc

		lea	NC_NAMESTRING(a3),a1
		move.l	a1,NC_NAME(a3)

		move.l	a4,a0
		move.l	a3,a1
		move.l	d2,a2

		move.l	4.w,a6
		jsr	_LVOInsert(a6)
		
		bra.w	nc_addlist

;--- Führe die Config aus falls eine vorhanden ist ---
nc_config:
		bsr.w	nc_holemainlist

		moveq	#0,d0
		move.w	nc_routine(a5),d0
		move.l	a4,a0

.nn		move.l	(a0),a0		; angewählte Node
		dbra	d0,.nn

		move.l	NC_PREFSORIBUF(a0),a1
		lea	NC_PREFS(a0),a2
		move.l	NC_PREFSLEN(a0),d7
	tst.l	d7
	beq	.nopr
		subq.l	#1,d7

.cp		move.b	(a2)+,(a1)+	;Kopiere Locale Prefs in den Buffer des
		dbra	d7,.cp		;Moduls
.nopr
		move.l	NC_PREFSROUT(a0),d0
		bne.b	.ok
		rts
.ok		move.l	a0,-(a7)

		move.l	d0,a1
		jsr	(a1)		;Rufe die Conf routine auf

		move.l	(a7)+,a0
		move.l	a0,a4
		
		move.l	loadsavemark(a5),d0
		lsl.l	#2,d0
		lea	nc_nodelist(pc),a1
		move.l	(a1,d0.l),d5	;Node List

		lea	NC_MOTHERNODENAME(a0),a1
		move.l	d5,a0
		move.l	4.w,a6
		jsr	_LVOFindName(a6)
		tst.l	d0
		beq	.nixnode

		move.l	d0,a0
		move.l	30(a0),a3	;Taglist der original node

		move.l	utilbase(a5),a6
		
		move.l	a3,a0
		move.l	#APT_Prefsbuffersize,d0
		jsr	_LVOFindTagItem(a6)		
		tst.l	d0
		beq	.nixnode
		move.l	d0,a1
		move.l	4(a1),NC_PREFSLEN(a4)	;Länge der Prefs

;-- Kopiere Prefs wieder zurück ---
.nixnode:
		move.l	a4,a0
		move.l	NC_PREFSORIBUF(a0),a1
		lea	NC_PREFS(a0),a2
		move.l	NC_PREFSLEN(a0),d7
	tst.l	d7
	beq	.rt
		subq.l	#1,d7

.cp1		move.b	(a1)+,(a2)+	;Kopiere Locale Prefs in den Buffer des
		dbra	d7,.cp1		;Moduls
.rt
		rts

;-------------------------------------------------------------------------
nc_ghostmain:
;d0 = Gadget d1 = Ghost 

		lea	newchoosewinGadgets,a0
		lsl.l	#2,d0
		move.l	(a0,d0.l),a0
		move.l	newchoosewinWnd(a5),a1
		sub.l	a2,a2
		lea	nc_ghost(pc),a3
		move.l	d1,4(a3)
		move.l	gadbase(a5),a6
		jmp	_LVOGT_SetGadgetAttrsA(a6)


nc_firsttag:	dc.l	GTLV_Selected,nc_listpos,TAG_DONE

nc_listpos:	dc.l	0

nc_ghost:	dc.l	GA_Disabled,0,0


;------- Kopple Liste vom Listview ab --------
nc_detachmain:
		lea	newchoosewinGadgets,a0
		move.l	(a0),a0
		move.l	newchoosewinWnd(a5),a1
		sub.l	a2,a2
		lea	nc_addtag1(pc),a3
		move.l	#~0,4(a3)		;Liste detach , losmachen
		move.l	gadbase(a5),a6
		jmp	_LVOGT_SetGadgetAttrsA(a6)

nc_holemainlist:
		move.l	loadsavemark(a5),d0
		lsl.l	#2,d0
		lea	nc_nodelist1(pc),a0
		move.l	(a0,d0.l),a4
		rts

;-----------------------------------------------------------------------
;-- Es wurde ein neuer name eingetragen ---*
nc_newname:
		bsr.b	nc_detachmain		;Liste detach , losmachen

		bsr.b	nc_holemainlist

		moveq	#0,d0
		move.w	nc_routine(a5),d0
		move.l	a4,a1

.nn		move.l	(a1),a1
		dbra	d0,.nn

		lea	NC_NAMESTRING(a1),a1
		move.l	a1,d5
		lea	nc_stringget(pc),a3

		lea	newchoosewinGadgets,a0
		move.l	GD_nname<<2(a0),a0
		move.l	newchoosewinWnd(a5),a1
		sub.l	a2,a2
		jsr	_LVOGT_GetGadgetAttrsA(a6)

		move.l	nc_stringbuffer(pc),a0
		move.l	d5,a1
.n		move.b	(a0)+,d0
		beq.b	.w
		move.b	d0,(a1)+
		bra.b	.n
.w		clr.b	(a1)

		lea	nc_addtag1(pc),a3
		move.l	a4,4(a3)		;Node List

		lea	newchoosewinGadgets,a0
		move.l	(a0),a0
		move.l	newchoosewinWnd(a5),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		rts


nc_stringget:	dc.l	GTST_String,nc_stringbuffer,TAG_DONE

nc_stringbuffer: dc.l	0


;--- Bewege einen Entry einen eintrag nach oben in der Liste ---
nc_up:
		tst.w	nc_routine(a5)
		beq.b	nc_upwech

		bsr.w	nc_detachmain

		bsr.w	nc_holemainlist	;in A4 gibs die liste zurück
		
		moveq	#0,d0
		move.w	nc_routine(a5),d0

		move.l	a4,a3
.nn		move.l	(a3),a3
		dbra	d0,.nn

		move.l	a3,a1
		REMOVE

		move.l	a4,a2
		move.w	nc_routine(a5),d0
		subq.w	#2,d0
		bmi.b	.w
.nnn		move.l	(a2),a2
		dbra	d0,.nnn

.w
		move.l	a3,a1	;zu addende Node
		move.l	a4,a0

		move.l	4.w,a6
		jsr	_LVOInsert(a6)
		
		lea	nc_addtag(pc),a3
		move.l	a4,4(a3)		;GTLV_Labels

		moveq	#0,d0
		move.w	nc_routine(a5),d0
		subq.w	#1,d0
		move.l	d0,12(a3)		;GTLV_Selected
		move.l	d0,20(a3)		;GTLV_MakeVisible

		move.w	d0,nc_routine(a5)
		
		lea	newchoosewinGadgets,a0
		move.l	(a0),a0
		move.l	newchoosewinWnd(a5),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

nc_upwech
		rts
		
;--- Bewege einen Entry einen eintrag nach unten in der Liste ---
nc_down:
		bsr.w	nc_holemainlist	;in A4 gibs die liste zurück

		move.l	a4,a0

		move.l	(a0),a0

		moveq	#0,d0
.w		move.l	(a0),d1
		beq.b	.end
		addq.l	#1,d0
		move.l	d1,a0
		bra.b	.w
.end
		subq.w	#1,d0

		cmp.w	nc_routine(a5),d0
		beq.b	.nc_downwech		;Ist schon der Letzte eintrag

		bsr.w	nc_detachmain

		moveq	#0,d0
		move.w	nc_routine(a5),d0

		move.l	a4,a3
.nn		move.l	(a3),a3
		dbra	d0,.nn

		move.l	a3,a1

		REMOVE

		move.l	a4,a2
		move.w	nc_routine(a5),d0
.nnn		move.l	(a2),a2
		dbra	d0,.nnn


		move.l	a3,a1	;zu addende Node
		move.l	a4,a0

		move.l	4.w,a6
		jsr	_LVOInsert(a6)
		
		lea	nc_addtag(pc),a3
		move.l	a4,4(a3)		;GTLV_Labels

		moveq	#0,d0
		move.w	nc_routine(a5),d0
		addq.w	#1,d0
		move.l	d0,12(a3)		;GTLV_Selected
		move.l	d0,20(a3)		;GTLV_MakeVisible

		move.w	d0,nc_routine(a5)
		
		lea	newchoosewinGadgets,a0
		move.l	(a0),a0
		move.l	newchoosewinWnd(a5),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

.nc_downwech
		rts

;--------------------------------------------------------------------------
;---- Hole Aktuelle Node --------------------------------------------------
;--------------------------------------------------------------------------
;>d0 = Welcher Nodetype
;<a0 Node
GetAktNode:
		lea	nc_nodelist1(pc),a0
		move.l	(a0,d0.l*4),a0

		lea	nc_lroutine(a5),a1
		move.w	(a1,d0.l*2),d7
		
.nn		move.l	(a0),a0
		dbra	d7,.nn

		rts

;--------------------------------------------------------------------------
;Finde aus aktueller Node einen Tag
;--------------------------------------------------------------------------
;>d0 = NodeType
;>d1 = Tag
;<d0 = Ergebniss vom Tag, EROR wenn Fehler aufgetreten
Gettag:
		move.l	d1,d5
		bsr	GetAktNode
		lea	NC_MOTHERNODENAME(a0),a1
		lea	nc_nodelist(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	4.w,a6
		jsr	_LVOFindName(a6)
		tst.l	d0
		bne	.w
.te
		move.l	#'EROR',d0
		rts
.w
		move.l	d0,a0
		move.l	30(a0),a0		;TagList
		move.l	d5,d0
		move.l	APG_UtilBase(a5),a6
		jsr	_LVOFindTagItem(a6)
		tst.l	d0
		beq	.te
		move.l	d0,a0
		move.l	4(a0),d0
		rts

;--------------------------------------------------------------------------
;------ Save Liste ab -----------------------------------------------------
nc_save:
	STRUCTURE	NS_SAVELIST,0
		
		STRUCT	NS_NAMESTRING,22 	;Platz für den Namen des Nodes
		STRUCT	NS_PREFS,50		;Buffer für die Prefs
		LONG	NS_PREFSLEN		;Länge der Prefs
		STRUCT	NS_MOTHERNODENAME,20	;Originaler Node Name

		LABEL	NS_SAVELISTsizeof
		
;--------------------------------------------------------------------------

		bsr.w	nc_holemainlist

		move.l	a4,a0
		TSTLIST
		bne.b	.listok
		lea	nolistmsg(pc),a4
		bra.l	status
.listok:		
	;-----------------------------------------------
		clr.l	APG_Free1(a5)
		clr.l	APG_Free2(a5)

		move.l	a4,a0
		move.l	(a0),a0
		moveq	#0,d0
.wz		move.l	(a0),d1
		beq.b	.end
		addq.l	#1,d0
		move.l	d1,a0
		bra.b	.wz
.end
	;--- Allociere Speicher für die gesamte Prefs ---

		mulu	#NS_SAVELISTsizeof,d0
		add.l	#100,d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		tst.l	d0
		bne.b	.doprefs
		lea	pal_rnomemmsg,a4
		bra.l	status
.doprefs:
		move.l	d0,APG_Free2(a5)		

		sub.l	a0,a0
		moveq	#0,d0			;Struktur-Type
		move.l	reqtbase(a5),a6
		jsr	_LVORTAllocRequestA(a6)
		move.l	d0,APG_Free1(a5)	;Savestruck

		lea	nc_dirtag(pc),a0
		move.l	d0,a1
		jsr	_LVORTChangeReqAttrA(a6)
		
		lea	nc_loaderprefs(pc),a0
		cmp.l	#nc_selectload,loadsavemark(a5)
		beq.b	.ws
		lea	nc_saverprefs(pc),a0
		cmp.l	#nc_selectsaver,loadsavemark(a5)
		beq.b	.ws
		lea	nc_operatorprefs(pc),a0
.ws

		lea	PFilename(a5),a1
.nextchar:	move.b	(a0)+,d0
		beq.b	.wend
		move.b	d0,(a1)+
		bra.b	.nextchar
.wend		clr.b	(a1)

		move.l	APG_Free1(a5),a1
		lea	PFileName(a5),a2			
		lea	savepref(pc),a3
		lea	TagItemListe1,a0		;Tag-Liste
		jsr	_LVORTFileRequestA(a6)
		tst.l	d0
		bne.b	.saveok			;File ok	
		lea	nosavemsg(pc),a4
		bra.l	status			;Saveerror ausgeben

.saveok:
		move.l	APG_Free1(a5),a0
		move.l	rtfi_dir(a0),pdirname(a5)

; ============== Savenamen zusammenstellen =================

		lea	PSavename(a5),a0
		move.l	pdirname(a5),a1
		tst.b	(a1)
		beq.b	.pno
.pnewchar:
		move.b	(a1)+,(a0)+
		bne.b	.pnewchar
		subq.l	#2,a0
		cmp.b	#':',(a0)+
		beq.b	.pno
		move.b	#'/',(a0)+
.pno:		lea	pfilename(a5),a1
		moveq	#0,d0
.pnewchar1:
		move.b	(a1)+,(a0)+
		addq.b	#1,d0
		tst.b	(a1)
		bne.b	.pnewchar1
		move.b 	d0,filelenght(a5)
		move.b	#0,(a0)

nc_prefsnameok:
		lea	pSavename(a5),a0
		move.l	a0,d1
		move.l	#MODE_NEWFILE,d2	;newfile
		move.l	dosbase(a5),a6
		jsr	_LVOOpen(a6)
		tst.l	d0
		bne.b	.fok
		lea	loaderrormsg,a4
		bsr.l	status
		bra.w	nc_swech

.fok		move.l	d0,filehandle(a5)
	
	;*--- Fülle Prefs Puffer ---*

		move.l	APG_Free2(a5),a0
		
		move.l	loadsavemark(a5),d0
		lsl.l	#2,d0
		lea	nc_prefsheader(pc),a1
		lea	(a1,d0.l),a1

		move.l	(a1),(a0)+
		move.l	#nc_prefsversion,(a0)+

		move.l	a4,a1

.nextnode:	move.l	(a1),a1

		tst.l	(a1)
		beq.b	.lastnode

		lea	NC_NAMESTRING(a1),a2
		moveq	#22-1,d0
.ns:		move.b	(a2)+,(a0)+
		dbra	d0,.ns

		lea	NC_PREFS(a1),a2
		moveq	#50-1,d0
.np		move.b	(a2)+,(a0)+
		dbra	d0,.np

		move.l	NC_PREFSLEN(a1),(a0)+

		lea	NC_MOTHERNODENAME(a1),a2
		moveq	#20-1,d0
.nm		move.b	(a2)+,(a0)+
		dbra	d0,.nm

		bra.b	.nextnode
.lastnode:

	;*---- Save Puffer ----*

		move.l	filehandle(a5),d1
		move.l	APG_Free2(a5),d2
		move.l	a0,d3
		sub.l	d2,d3
		move.l	d3,d5
		move.l	dosbase(a5),a6
		jsr	_LVOWrite(a6)

		move.l	filehandle(a5),d1
		jsr	_LVOClose(a6)

		lea	pSavename(a5),a0
		cmp.l	#'ENVA',(a0)
		bne.b	.w

		addq.l	#3,a0
		move.l	a0,a1
		move.b	#'E',(a1)+
		move.b	#'N',(a1)+
		move.b	#'V',(a1)+

		move.l	a0,d1
		move.l	#1006,d2	;newfile
		jsr	_LVOOpen(a6)
		move.l	d0,filehandle(a5)
		beq.b	.w

		move.l	d5,d3
		move.l	filehandle(a5),d1
		move.l	APG_Free2(a5),d2
		jsr	_LVOWrite(a6)

		move.l	filehandle(a5),d1
		jsr	_LVOClose(a6)

.w
		move.l	APG_Free1(a5),d0
		beq.b	nc_swech
		move.l	d0,a1
		move.l	reqtbase(a5),a6
		jsr	_LVORTFreeRequest(a6)
		clr.l	APG_Free1(a5)
nc_swech
		move.l	APG_Free2(a5),d0
		beq.b	.nofree
		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
.nofree:		
		rts

nc_dirtag:	dc.l	_RTFI_DIR	;RTFI_Dir
		dc.l	PrefsDir
		dc.l	RTFI_AddEntry
		dc.l	0

nc_prefsdir:
		dc.b	'Envarc:ArtPRO/',0
		
nc_loaderprefs:	dc.b	'loaderdefault.cfg',0
nc_saverprefs:	dc.b	'saverdefault.cfg',0
nc_operatorprefs dc.b	'operatordefault.cfg',0

nolistmsg:	dc.b	'The list is empty!',0

nosavemsg:	dc.b	'Operation aborted!',0

	even
nc_prefsheader:
		dc.b	'APLP'
		dc.b	'APSP'
		dc.b	'APOP'

;--------------------------------------------------------------------------
;------ Lade Liste ein -----------------------------------------------------
nc_load:
		clr.l	APG_Free1(a5)
		clr.l	APG_Free2(a5)

		sub.l	a0,a0
		moveq	#0,d0			;Struktur-Type
		move.l	reqtbase(a5),a6
		jsr	_LVORTAllocRequestA(a6)
		move.l	d0,APG_Free1(a5)	;Savestruck

		lea	nc_dirtag(pc),a0
		move.l	d0,a1
		jsr	_LVORTChangeReqAttrA(a6)
		
		lea	nc_loaderprefs(pc),a0
		cmp.l	#nc_selectload,loadsavemark(a5)
		beq.b	.ws
		cmp.l	#nc_selectsaver,loadsavemark(a5)
		bne.b	.ws
		lea	nc_saverprefs(pc),a0
.ws
		lea	PFilename(a5),a1
.nextchar:	move.b	(a0)+,d0
		beq.b	.wend
		move.b	d0,(a1)+
		bra.b	.nextchar
.wend		clr.b	(a1)

		move.l	APG_Free1(a5),a1
		lea	PFileName(a5),a2			
		lea	loadpref(pc),a3
		lea	TagItemListe1,a0		;Tag-Liste
		jsr	_LVORTFileRequestA(a6)
		tst.l	d0
		bne.b	.saveok			;File ok	
		lea	nosavemsg(pc),a4
		bra.l	status			;Saveerror ausgeben

.saveok:
		move.l	APG_Free1(a5),a0
		move.l	rtfi_dir(a0),pdirname(a5)

; ============== Savenamen zusammenstellen =================

		lea	PSavename(a5),a0
		move.l	pdirname(a5),a1
		tst.b	(a1)
		beq.b	.pno
.pnewchar:
		move.b	(a1)+,(a0)+
		bne.b	.pnewchar
		subq.l	#2,a0
		cmp.b	#':',(a0)+
		beq.b	.pno
		move.b	#'/',(a0)+
.pno:		lea	pfilename(a5),a1
		moveq	#0,d0
.pnewchar1:
		move.b	(a1)+,(a0)+
		addq.b	#1,d0
		tst.b	(a1)
		bne.b	.pnewchar1
		move.b 	d0,filelenght(a5)
		move.b	#0,(a0)

nc_pnameok:
		lea	pSavename(a5),a0
		move.l	a0,d1
		move.l	#MODE_OLDFILE,d2
		move.l	dosbase(a5),a6
		jsr	_LVOOpen(a6)
		tst.l	d0
		bne.b	.fok
		lea	loaderrormsg,a4
		bsr.l	status
		bra.w	nc_lwech

.fok		move.l	d0,filehandle(a5)

		lea	pSavename(a5),a1
		bsr.l	filesize1
		tst.l	d0
		bne.w	nc_lwech1

		move.l	size(a5),d0
		move.l	d0,APG_Free3(a5)

		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		tst.l	d0
		beq.w	nc_lwech1
		move.l	d0,APG_Free2(a5)

		move.l	filehandle(a5),d1
		move.l	d0,d2
		move.l	dosbase(a5),a6
		jsr	_LVORead(a6)
		tst.l	d0
		bpl.b	.w
		move.l	filehandle(a5),d1
		jsr	_LVOClose(a6)
		bra.w	nc_lwech
		
.w		move.l	filehandle(a5),d1
		jsr	_LVOClose(a6)

		move.l	APG_Free2(a5),a0
		move.l	loadsavemark(a5),d0
		lsl.l	#2,d0
		lea	nc_prefsheader(pc),a1
		lea	(a1,d0.l),a1
		move.l	(a1),d0
		cmp.l	(a0)+,d0
		bne.w	nc_lwech
		cmp.l	#nc_prefsversion,(a0)
		bmi.w	nc_lwech		;Zu alte Prefsversion

	;Test ob schon Liste vorhanden ist und wenn dann lösche sie

		bsr.w	nc_holemainlist

		move.l	a4,a0
		TSTLIST
		beq.b	.nolist		; Es gibt noch keine Liste

		move.l	a4,a3
		move.l	4.w,a6
		
		move.l	(a3),d5
		beq.b	.nonode
.nextnode	move.l	d5,a1
		move.l	a1,a3
		move.l	(a1),d5		;next node
		beq.b	.nonode
		
		REMOVE

		move.l	a3,a1
		jsr	_LVOFreeVec(a6)

		bra.b	.nextnode
.nonode:

.nolist:
		bsr.w	nc_detachmain

	;--------------------------------------------------------------

		move.l	APG_Free2(a5),a3
		addq.l	#8,a3		;Header überlesen

		move.l	APG_Free3(a5),d7   ;Filelänge
		subq.l	#8,d7
		divu	#NS_SAVELISTsizeof,d7
		swap	d7
		tst.w	d7
		bne.w	nc_lwech
		swap	d7
		subq.l	#1,d7
		
		move.l	loadsavemark(a5),d0
		lsl.l	#2,d0
		lea	nc_nodelist(pc),a0
		move.l	(a0,d0.l),d5	;Node List

	;*--- Adde Nodes -----*

NC_lnewnode:
		lea	NS_MOTHERNODENAME(a3),a1
		move.l	d5,a0
		move.l	4.w,a6
		jsr	_LVOFindName(a6)
		tst.l	d0
		bne.b	.nodeok
		lea	NC_NODEsizeof(a3),a3
		bra.w	nc_nixnode

.nodeok:
		move.l	d0,APG_Free4(a5)	;Node merken

		moveq	#NC_NODEsizeof,d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		tst.l	d0
		bne.b	.nc_addnodememok

		lea	nc_notenoughmem(pc),a4
		bsr.l	status
		bra.w	nc_lwech

.nc_addnodememok:

		move.l	a4,a0		;Node List
		move.l	d0,a1		;neue Node

		ADDTAIL

	*-- Fülle neue Node mit Stuff --*

		move.l	d5,a0		;Node List

		lea	NC_NAMESTRING(a1),a2
		move.l	a2,NC_NAME(a1)
		moveq	#22-1,d6
.ns:		move.b	(a3)+,(a2)+
		dbra	d6,.ns

		lea	NC_PREFS(a1),a2
		moveq	#50-1,d6
.np:		move.b	(a3)+,(a2)+
		dbra	d6,.np

		move.l	(a3)+,NC_PREFSLEN(a1)

		lea	NC_MOTHERNODENAME(a1),a2
		moveq	#20-1,d6
.mn:		move.b	(a3)+,(a2)+
		dbra	d6,.mn

		move.l	APG_Free4(a5),a0
		move.l	14(a0),NC_JUMP(a1)

		move.l	30(a0),d6	;Taglist der original node

		move.l	utilbase(a5),a6
		
		clr.l	NC_PREFSROUT(a1)

		move.l	a1,-(a7)

		move.l	d6,a0
		move.l	#APT_Prefs,d0
		jsr	_LVOFindTagItem(a6)		
		move.l	(a7)+,a1
		tst.l	d0
		beq.b	.nc_noprefs
		move.l	d0,a0
		move.l	4(a0),NC_PREFSROUT(a1)

		move.l	a1,-(a7)
		move.l	d0,a0
		move.l	#APT_Prefsbuffer,d0
		jsr	_LVOFindTagItem(a6)		
		move.l	(a7)+,a1
		tst.l	d0
		bne.b	.nc_ok
		clr.l	NC_PREFSROUT(a1)
		bra.b	.nc_noprefs
.nc_ok		move.l	d0,a0
		move.l	4(a0),a0
		move.l	a0,NC_PREFSORIBUF(a1)
.nc_noprefs
nc_nixnode:
		dbra	d7,nc_lnewnode

	;*--- Füge Liste wieder an Listview an ----*
nc_addend:
		lea	nc_addtag(pc),a3
		move.l	a4,4(a3)		;GTLV_Labels

		clr.w	nc_routine(a5)
		clr.l	12(a3)		;GTLV_Selected
		clr.l	20(a3)		;GTLV_MakeVisible

		lea	newchoosewinGadgets,a0
		move.l	(a0),a0
		move.l	newchoosewinWnd(a5),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

nc_lwech1:
		move.l	APG_Free1(a5),d0
		beq.b	nc_lwech
		move.l	d0,a1
		move.l	reqtbase(a5),a6
		jsr	_LVORTFreeRequest(a6)
		clr.l	APG_Free1(a5)
nc_lwech
		move.l	APG_Free2(a5),d0
		beq.b	.nofree
		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
.nofree:		
		rts

;---------------------------------------------------------------------------
nc_mainarrows:
		cmp.w	#CURSORUP,d5
		beq.b	nc_chooseup
		cmp.w	#CURSORDOWN,d5
		beq.b	nc_choosedown
nc_awech:	rts
		
nc_chooseup:
		moveq	#0,d5
		tst.b	nc_arrowmerk(a5)
		beq.b	nc_nochnix
		move.w	nc_routine(a5),d5
		beq.b	nc_awech
		subq.w	#1,d5
		bra.b	nc_nochnix

nc_choosedown:
		moveq	#0,d5
		tst.b	nc_arrowmerk(a5)
		beq.b	nc_nochnix
		bsr.b	nc_checklistlenght
		move.w	nc_routine(a5),d5
		addq.w	#1,d5
		cmp.w	d5,d0
		bmi.b	nc_awech
nc_nochnix:
		st	nc_arrowmerk(a5)
		lea	newchoosewinGadgets,a0
		move.l	(a0),a0
		move.l	newchoosewinWnd(a5),a1
		sub.l	a2,a2
		lea	nc_ar_tags(pc),a3
		move.l	gadbase(a5),a6
		lea	nc_ar_item(pc),a4
		move.l	d5,(a4)			;Routine
		move.l	d5,8(a4)		;Routine
		jsr	_LVOGT_SetGadgetAttrsA(a6)
		tst.b	nc_arrowmerk(a5)
		beq.b	nc_awech

		move.w	d5,nc_routine(a5)
		bra.w	nc_newrout_

nc_checklistlenght:
		move.l	loadsavemark(a5),d0
		lsl.l	#2,d0
		lea	nc_nodelist1(pc),a0
		move.l	(a0,d0.l),a0	;Node List

		move.l	(a0),a0

		moveq	#0,d0
.w		move.l	(a0),d1
		beq.b	.endlist
		move.l	d1,a0
		addq.l	#1,d0
		bra.b	.w
.endlist:
		subq.l	#1,d0
		rts

;---------------------------------------------------------------------------
;----- Öffne zweites Window um einen neuen loader/saver zu adden ----

nc_addentry:

		clr.w	nc_addroutine(a5)
		sf	nc_addarrowmerk(a5)	;es wurde ein Routine angeklickt

;ghoste erstmal 'add' gadget

		moveq	#GD_nadd,d0
		moveq	#1,d1
		bsr.w	nc_ghostmain

;-- Was wollen wir auswählen loader/saver ... --

		lea	newmodulenodelist,a0
		cmp.l	#nc_selectload,loadsavemark(a5)
		bne.b	.tw
		move.l	#gloadreqList,(a0)
		lea	nc_chooseloader1(pc),a0
		lea	nc_wintitle(pc),a1
		move.l	a0,(a1)
		bra.b	nc_addopenwin

.tw:
		cmp.l	#nc_selectsaver,loadsavemark(a5)
		bne.b	.tw1
		move.l	#gsavereqList,(a0)
		lea	nc_choosesaver1(pc),a0
		lea	nc_wintitle(pc),a1
		move.l	a0,(a1)
		bra.w	nc_addopenwin
.tw1:
		cmp.l	#nc_selectoperator,loadsavemark(a5)
		bne.b	.tw2
		move.l	#goperatorList,(a0)
		lea	nc_chooseoperator1(pc),a0
		lea	nc_wintitle(pc),a1
		move.l	a0,(a1)
		bra.w	nc_addopenwin
.tw2:

nc_addopenwin:
		lea	nc_choosemodulTags(pc),a0
		move.l	a0,windowtaglist(a5)
		lea	nc_choosewinWG+4(pc),a0
		move.l	a0,gadgets(a5)
		lea	nc_choosewinSC+4(pc),a0
		move.l	a0,winscreen(a5)
		lea	nc_choosewinWnd(a5),a0
		move.l	a0,window(a5)
		lea	newmodulewinGlist(a5),a0
		move.l	a0,Glist(a5)
		move.l	#newmodulewinNgads,NGads(a5)
		move.l	#newmodulewinGTypes,GTypes(a5)
		move.l	#newmodulewinGadgets,WinGadgets(a5)
		move.w	#newmodulewin_CNT,win_CNT(a5)
		move.l	#newmodulewinGtags,windowtags(a5)
		move.l	scr(a5),screenbase(a5)

		jsr	checkmainwinpos

		move.l	d0,-(a7)

		move.l	#nc_choosewinleft,d0
		cmp.l	#nc_selectoperator,loadsavemark(a5)
		bne	.w
		move.l	#nc_choosewinleft1,d0
.w		bsr.l	computex
		move.l	d0,d4

		move.l	#nc_choosewinTop,d0
		bsr.l	computey
		move.l	d0,d5
		movem.l	(a7)+,d0
		add.w	d4,d0

;		add.w	#nc_choosewinLeft,d0
		add.w	d5,d1

		move.w	d1,WinTop(a5)
		move.w	d0,WinLeft(a5)

		move.w	#nc_choosewinWidth,WinWidth(a5)
		move.w	#nc_choosewinHeight,WinHeight(a5)
		lea	nc_chooseWinL(pc),a0
		move.l	a0,WinL(a5)
		lea	nc_chooseWinT(pc),a0
		move.l	a0,WinT(a5)
		lea	nc_chooseWinW(pc),a0
		move.l	a0,WinW(a5)
		lea	nc_chooseWinH(pc),a0
		move.l	a0,WinH(a5)

		jsr	openwindowF

		tst.l	d0
		beq.b	.winok
		lea	nc_erroropenmsg(pc),a4
		bsr.l	status
		bra.w	nc_wait
.winok:

;I/O Handling
;Init MsgPort
		move.l	newchoosewinWnd(a5),a0
		move.l	WD_UserPort(a0),a0	:MSGPort
		move.l	a0,WinMsgPort1(a5)

	*--------------- SignalBits setzen ---------------*
		moveq	#0,d6
		moveq	#0,d0
		move.b	mp_SigBit(a0),d0
		bset	d0,d6

		move.l	nc_choosewinWnd(a5),a0
		move.l	WD_UserPort(a0),a0
		move.l	a0,WinMsgPort2(a5)

	*--------------- SignalBits setzen ---------------*
		moveq	#0,d0
		move.b	mp_SigBit(a0),d0
		bset	d0,d6

		move.l	d6,SignalBits(a5)

	*--------------------- Wait ---------------------*
nc_mainwait:	move.l	SignalBits(a5),d0
		or.w	#$1000,d0		;Break-Signal
		move.l	4.w,a6
		jsr	_LVOWait(a6)

	*------- War es eine newchoose Message ------*
		move.l	WinMsgPort1(a5),d2
		beq.s	.NoPort
		move.l	d2,a0
		moveq	#0,d1
		move.b	mp_SigBit(a0),d1
		btst	d1,d0
		bne.b	nc_WartenWinPort1	

	*----- war es eine nc_module Message ----*
.NoPort:	move.l	WinMsgPort2(a5),d2		;Testen ob Window-Port
		beq.s	.NoMain
		move.l	d2,a0
		move.b	mp_SigBit(a0),d1
		btst	d1,d0
		bne.b	nc_WartenWinPort2
.NoMain:	bra.b	nc_mainWait

;----------------------------------------------------------------------------
nc_Warten:	
nc_WartenWinPort1:
		move.l	WinMsgPort1(a5),d0
		beq.s	nc_WartenWinPort2
		move.l	d0,a0
		move.l	gadbase(a5),a6
		jsr	_LVOGT_getimsg(a6)	;hole Msg
		tst.l	d0
		beq.b	nc_WartenWinPort2
		bra.b	nc_WindowMessage1

nc_WartenWinPort2:
		move.l	WinMsgPort2(a5),d0
		beq.b	nc_mainWait
		move.l	d0,a0
		move.l	gadbase(a5),a6
		jsr	_LVOGT_getimsg(a6)	;hole Msg
		tst.l	d0
		beq.b	nc_mainWait
		bra.b	nc_WindowMessage2

nc_WindowMessage1:
		move.l	d0,a1			;muss nach a1
		move.l	im_Class(a1),d4		;Msg-Type
		move.w	im_Code(a1),d5		;Untergruppe
		move.l	im_Seconds(a1),d6	;Systemzeit
		move.l	im_IAddress(a1),a4	;Adr. für Gadgets
		move.l	gadbase(a5),a6
		jsr	_LVOGT_replyIMsg(a6)	;quittiere Msg in a1

		cmp.l	#IDCMP_CLOSEWINDOW,d4
		beq.w	nc_cancel
		cmp.l	#GADGETUP,d4
		beq.b	nc_maingads
		cmp.l	#VANILLAKEY,d4
		beq.w	nc_mainkeys
		cmp.l	#RAWKEY,d4
		beq.w	nc_mainarrows1
		bra.b	nc_warten

nc_WindowMessage2:
		move.l	d0,a1			;muss nach a1
		move.l	im_Class(a1),d4		;Msg-Type
		move.w	im_Code(a1),d5		;Untergruppe
		move.l	im_Seconds(a1),d6	;Systemzeit
		move.l	im_IAddress(a1),a4	;Adr. für Gadgets
		move.l	gadbase(a5),a6
		jsr	_LVOGT_replyIMsg(a6)	;quittiere Msg in a1

		cmp.l	#IDCMP_CLOSEWINDOW,d4
		beq.w	nc_addwech
		cmp.l	#GADGETUP,d4
		beq.w	nc_addgads
		cmp.l	#VANILLAKEY,d4
		beq.w	nc_addkeys
		cmp.l	#RAWKEY,d4
		beq.w	nc_addarrows
		bra.w	nc_warten


;--------------------------------------------------------------------------
;--- Werte Gadgets im Haupt Window aus ---

nc_maingads:
		moveq	#0,d0
		move.w	GG_GadgetID(a4),d0
		add.l	d0,d0
		lea	nc_mainjumptab(pc),a0
		move.w	(a0,d0.l),d0
		ext.l	d0
		jmp	(a0,d0.l)

nc_mainjumptab:

		dc.w	nc_newrout1-nc_mainjumptab
		dc.w	nc_config1-nc_mainjumptab
		dc.w	nc_clone1-nc_mainjumptab
		dc.w	0
		dc.w	nc_earse1-nc_mainjumptab
		dc.w	nc_up1-nc_mainjumptab
		dc.w	nc_down1-nc_mainjumptab
		dc.w	nc_load1-nc_mainjumptab
		dc.w	nc_save1-nc_mainjumptab
		dc.w	nc_okandmake-nc_mainjumptab
		dc.w	nc_accept-nc_mainjumptab
		dc.w	nc_cancel-nc_mainjumptab
		dc.w	nc_newname1-nc_mainjumptab

nc_mainkeys:
		move.l	newchoosewinWnd(a5),aktwin(a5)
		lea	newchoosewinGadgets,a0

		cmp.w	#27,d5
		beq.w	nc_cancel
		cmp.w	#9,d5
		bne.b	.notab
		move.l	nc_choosewinWnd(a5),a0
		bsr.l	aktiwin
		bra.w	nc_warten
.notab
		cmp.w	#'g',d5
		bne.b	.nocan
		lea	nc_config1(pc),a3
		move.l	#GD_nconfig,d0
		bsr.w	nc_checkghost
		bra.w	setandjump
.nocan:
		cmp.w	#'n',d5
		bne.b	.noclone
		lea	nc_clone1(pc),a3
		move.l	#GD_nclone,d0
		bsr.w	nc_checkghost
		bra.w	setandjump
.noclone:
		cmp.w	#'e',d5
		bne.b	.noerase
		lea	nc_earse1(pc),a3
		move.l	#GD_nerase,d0
		bsr.w	nc_checkghost
		bra.w	setandjump
.noerase:
		cmp.w	#'u',d5
		bne.b	.noup
		lea	nc_up1(pc),a3
		move.l	#GD_nup,d0
		bsr.w	nc_checkghost
		bra.w	setandjump
.noup:
		cmp.w	#'d',d5
		bne.b	.nodown
		lea	nc_down1(pc),a3
		move.l	#GD_ndown,d0
		bsr.b	nc_checkghost
		bra.w	setandjump
.nodown:
		cmp.w	#'t',d5
		bne.b	.noop
		lea	nc_okandmake(pc),a3
		move.l	#GD_nAcceptandLoad,d0
		bsr.b	nc_checkghost
		bra.w	setandjump
.noop:
		cmp.w	#'o',d5
		bne.b	.nook
		lea	nc_accept(pc),a3
		move.l	#GD_nAccept,d0
		bra.w	setandjump
.nook:
		cmp.w	#'c',d5
		bne.b	.nocancel
		lea	nc_cancel(pc),a3
		move.l	#GD_nCancel,d0
		bra.w	setandjump
.nocancel:
		cmp.w	#'l',d5
		bne.b	.noload
		lea	nc_load1(pc),a3
		move.l	#GD_nload,d0
		bra.w	setandjump
.noload:
		cmp.w	#'s',d5
		bne.w	nc_wait
		lea	nc_save1(pc),a3
		move.l	#GD_nsave,d0
		bra.w	setandjump

nc_checkghost:
		move.l	(a0,d0.l*4),a1
		move.w	gg_FLAGS(a1),d1
		and.w	#GFLG_DISABLED,d1
		bne.b	.nc_warten
		rts
.nc_warten
		addq.l	#4,a7
		bra.w	nc_warten

;--- Lösche Node aus Main Window
nc_earse1:
		bsr.w	nc_erase
		bra.w	nc_warten

;--- Er wurde eine neue routine im Main windowangewählt
nc_newrout1:
		bsr.w	nc_newrout
		bra.w	nc_warten
nc_newname1:
		bsr.w	nc_newname
		bra.w	nc_warten
nc_clone1:
		bsr.w	nc_clone
		bra.w	nc_warten
nc_config1:
		bsr.w	nc_config
		bra.w	nc_warten
nc_up1:
		bsr.w	nc_up
		bra.w	nc_warten
nc_down1:
		bsr.w	nc_down
		bra.w	nc_warten
nc_save1:
		bsr.w	nc_save
		bra.w	nc_warten
nc_load1:
		bsr.w	nc_load
		bra.w	nc_warten

nc_mainarrows1:
		bsr.w	nc_mainarrows
		bra.w	nc_warten


;-----------------------------------------------------------------------------
;--- Werte Gadgets im Add Window aus ---
nc_addgads:
		moveq	#0,d0
		move.w	GG_GadgetID(a4),d0
		add.l	d0,d0
		lea	nc_addjumptab(pc),a0
		move.w	(a0,d0.l),d0
		ext.l	d0
		jmp	(a0,d0.l)
		
nc_addjumptab:
		dc.w	nc_newaddrout-nc_addjumptab
		dc.w	nc_info-nc_addjumptab
		dc.w	nc_addrout-nc_addjumptab
		dc.w	nc_addwech-nc_addjumptab

;---------------------------------------------------------------------------
nc_addkeys:
		move.l	nc_choosewinWnd(a5),aktwin(a5)
		lea	newmodulewinGadgets,a0

		cmp.w	#27,d5	;ESC
		beq.w	nc_addwech
		cmp.w	#'a',d5
		bne.b	.noadd
		lea	nc_addrout(pc),a3
		move.l	#GD_ncadd,d0
		bra.w	setandjump
.noadd:
		cmp.w	#'i',d5
		bne.b	.noinfo
		lea	nc_info(pc),a3
		move.l	#GD_ncinfo,d0
		bra.w	setandjump
.noinfo
		cmp.w	#'x',d5
		bne.b	.noexit
		lea	nc_addwech(pc),a3
		move.l	#GD_ncok,d0
		bra.w	setandjump
.noexit:
		cmp.w	#$d,d5
		beq.b	nc_addenter
		cmp.w	#9,d5
		bne.w	nc_warten
		move.l	newchoosewinWnd(a5),a0
		bsr.l	aktiwin
		bra.w	nc_warten

;----------------------------------------------------------------------------
nc_addenter:
		tst.b	nc_addarrowmerk(a5)
		beq.w	nc_warten
		bra.w	nc_addrout

;----------------------------------------------------------------------------

nc_addarrows:
		cmp.w	#CURSORUP,d5
		beq.b	nc_addchooseup
		cmp.w	#CURSORDOWN,d5
		beq.b	nc_addchoosedown
		bra.w	nc_warten

nc_addchooseup:
		moveq	#0,d5
		tst.b	nc_addarrowmerk(a5)
		beq.b	nc_addnochnix
		move.w	nc_addroutine(a5),d5
		beq.w	nc_warten
		subq.w	#1,d5
		bra.b	nc_addnochnix

nc_addchoosedown:
		moveq	#0,d5
		tst.b	nc_addarrowmerk(a5)
		beq.b	nc_addnochnix
		bsr.b	nc_addchecklistlenght
		move.w	nc_addroutine(a5),d5
		addq.w	#1,d5
		cmp.w	d5,d0
		bmi.w	nc_warten
nc_addnochnix:
		st	nc_addarrowmerk(a5)
		lea	newmodulewinGadgets,a0
		move.l	(a0),a0
		move.l	nc_choosewinWnd(a5),a1
		sub.l	a2,a2
		lea	nc_ar_tags(pc),a3
		move.l	gadbase(a5),a6
		lea	nc_ar_item(pc),a4
		move.l	d5,(a4)		;Routine
		move.l	d5,8(a4)		;Routine
		jsr	_LVOGT_SetGadgetAttrsA(a6)
		tst.b	nc_addarrowmerk(a5)
		beq.w	nc_warten

		move.w	d5,nc_addroutine(a5)	;nummer der Routine
		bra.w	nc_warten


nc_addchecklistlenght:
		move.l	loadsavemark(a5),d0
		lsl.l	#2,d0
		lea	nc_nodelist(pc),a0
		move.l	(a0,d0.l),a0	;Node List

		move.l	(a0),a0

		moveq	#0,d0
.w		move.l	(a0),d1
		beq.b	.endlist
		move.l	d1,a0
		addq.l	#1,d0
		bra.b	.w
.endlist:
		subq.l	#1,d0
		rts

;----------------------------------------------------------------------------
	*-- Es wurde eine neue Routine angewählt --*
nc_newaddrout:
		cmp.w	nc_addroutine(a5),d5
		beq.b	.testtime
		move.w	d5,nc_addroutine(a5)	;Sichere nummer der Routine
		move.w	d6,nc_addtime(a5)
		bra.w	nc_warten
.testtime:
		move.w	nc_addtime(a5),d0
		sub.w	d6,d0
		cmp.w	#1,d0
		bls.b	nc_addrout
		move.w	d6,nc_addtime(a5)
		bra.w	nc_warten

	*-- Addiere ein Node zur Hauptliste dazu --*
nc_addrout:
		moveq	#NC_NODEsizeof,d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		tst.l	d0
		bne.b	nc_addnodememok

		lea	nc_notenoughmem(pc),a4
		bsr.l	status
		bra.w	nc_warten

nc_addnodememok:
		move.l	d0,-(a7)

		bsr.w	nc_detachmain		;Liste detach , losmachen

		bsr.w	nc_holemainlist

		move.l	a4,a0		;Node List
		move.l	(a7)+,a1	;neue Node

		ADDTAIL

	*-- Fülle neue Node mit Stuff --*

		move.l	loadsavemark(a5),d0
		lsl.l	#2,d0
		lea	nc_nodelist(pc),a0
		move.l	(a0,d0.l),a0	;Node List

		move.w	nc_addroutine(a5),d0
.nn		move.l	(a0),a0
		dbra	d0,.nn

		move.l	14(a0),NC_JUMP(a1)	;eigendliche Routine

		*-- Übertrage name --*
	
		move.l	LN_NAME(a0),a2		;Originaler Name
		lea	NC_NAMESTRING(a1),a3
		lea	NC_MOTHERNODENAME(a1),a4
		move.l	a3,NC_NAME(a1)
.nc		move.b	(a2)+,d0
		beq.b	.wech
		move.b	d0,(a3)+
		move.b	d0,(a4)+
		bra.b	.nc
.wech:		clr.b	(a3)
		clr.b	(a4)

	*-- Kopiere Prefs --*

		move.l	a1,a4		;aktuelle neue Node
		move.l	30(a0),a3	;Taglist der original node

		move.l	utilbase(a5),a6
		
		clr.l	NC_PREFSROUT(a4)

		move.l	a3,a0
		move.l	#APT_Prefs,d0
		jsr	_LVOFindTagItem(a6)		
		tst.l	d0
		beq.b	.nc_noprefs
		move.l	d0,a0
		move.l	4(a0),NC_PREFSROUT(a4)

		move.l	a3,a0
		move.l	#APT_Prefsbuffersize,d0
		jsr	_LVOFindTagItem(a6)		
		tst.l	d0
		bne.b	.nc_prefsbuffer
.nc_nop		clr.l	NC_PREFSROUT(a4)
		bra.b	.nc_noprefs
.nc_prefsbuffer:
		move.l	d0,a0
		move.l	4(a0),NC_PREFSLEN(a4)	;Länge der Prefs

		move.l	a3,a0
		move.l	#APT_Prefsbuffer,d0
		jsr	_LVOFindTagItem(a6)		
		tst.l	d0
		beq.b	.nc_nop
		move.l	d0,a0
		move.l	4(a0),a0
		move.l	a0,NC_PREFSORIBUF(a4)

		move.l	NC_PREFSLEN(a4),d7
		subq.l	#1,d7
		lea	NC_PREFS(a4),a1
.np		move.b	(a0)+,(a1)+		;Kopiere prefs
		dbra	d7,.np

.nc_noprefs:

	*-- Update die Hauptliste im Listview --*

		move.l	a4,-(a7)
		
		bsr.w	nc_holemainlist
		move.l	a4,a0

		lea	nc_addtag(pc),a3
		move.l	a0,4(a3)		;GTLV_Labels

		move.l	(a0),a0

		moveq	#0,d0
.w		move.l	(a0),d1
		beq.b	.end
		addq.l	#1,d0
		move.l	d1,a0
		bra.b	.w
.end
	;	tst.l	d0
	;	beq	.nonode

		subq.w	#1,d0
		move.l	d0,12(a3)		;GTLV_Selected
		move.l	d0,20(a3)		;GTLV_MakeVisible

		move.w	d0,nc_routine(a5)
		
		lea	newchoosewinGadgets,a0
		move.l	(a0),a0
		move.l	newchoosewinWnd(a5),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

	*-- Setze Stringgadget im Main window --*

		move.l	(a7)+,a4
		
		lea	NC_NAMESTRING(a4),a0
		lea	nc_strtag(pc),a3
		move.l	a0,4(a3)

		lea	newchoosewinGadgets,a0
		move.l	GD_nname<<2(a0),a0
		move.l	newchoosewinWnd(a5),a1
		sub.l	a2,a2
		jsr	_LVOGT_SetGadgetAttrsA(a6)
				
;deghoste Erase etc. gadget, da jetzt einträge in liste

		moveq	#GD_nerase,d0
		moveq	#0,d1
		bsr.w	nc_ghostmain

		moveq	#GD_nname,d0
		moveq	#0,d1
		bsr.w	nc_ghostmain

		moveq	#GD_nclone,d0
		moveq	#0,d1
		bsr.w	nc_ghostmain

		moveq	#GD_nup,d0
		moveq	#0,d1
		bsr.w	nc_ghostmain

		moveq	#GD_ndown,d0
		moveq	#0,d1
		bsr.w	nc_ghostmain

		moveq	#GD_nconfig,d0
		moveq	#1,d1
		tst.l	NC_PREFSROUT(a4)
		beq.b	.nopre
		moveq	#0,d1
.nopre:		bsr.w	nc_ghostmain

		bra.w	nc_warten


nc_addtag:	dc.l	GTLV_Labels
		dc.l	0
nc_ar_tags:	dc.l	GTLV_Selected
nc_ar_item:	dc.l	0
		dc.l	GTLV_MakeVisible	;only v39
nc_ar_item1:	dc.l	0
		dc.l	TAG_DONE

nc_addtag1:	dc.l	GTLV_Labels,0,TAG_DONE

nc_strtag:	dc.l	GTST_String,0,TAG_DONE


	;*-- geben informationen zu eiem entry aus --*
nc_info:
		move.l	loadsavemark(a5),d0
		lsl.l	#2,d0
		lea	nc_nodelist(pc),a0
		move.l	(a0,d0.l),a0
		moveq	#0,d0
		move.w	nc_addroutine(a5),d0

.nn		move.l	(a0),a0
		dbra	d0,.nn


		move.l	30(a0),a4	;Taglist
		lea	keymsgpuffer(a5),a3
;checktags
		move.l	utilbase(a5),a6
		
		move.l	a4,a0
		move.l	#APT_Info,d0
		jsr	_LVOFindTagItem(a6)		
		tst.l	d0
		beq.b	nc_noinfo
		addq.l	#4,d0
		move.l	d0,a0
		move.l	(a0),a1
		lea	nc_infomsg(pc),a0
		bsr.w	nc_copy
		move.b	#10,(a3)+
		move.l	a1,a0
		bsr.w	nc_copy
		
.endcreator:	move.b	#10,(a3)+
		move.b	#10,(a3)+
		
nc_noinfo:
		move.l	a4,a0
		move.l	#APT_Creator,d0
		jsr	_LVOFindTagItem(a6)		
		tst.l	d0
		beq.b	nc_nocreator
		addq.l	#4,d0
		move.l	d0,a0
		move.l	(a0),a1
		lea	nc_creatormsg(pc),a0
		bsr.b	nc_copy
		move.b	#10,(a3)+
		move.l	a1,a0
		bsr.b	nc_copy
		move.b	#10,(a3)+
		move.b	#10,(a3)+
nc_nocreator:

		move.l	a4,a0
		move.l	#APT_Version,d0
		jsr	_LVOFindTagItem(a6)		
		tst.l	d0
		beq.b	nc_noversion
		addq.l	#4,d0
		move.l	d0,a0
		move.l	(a0),d1
		lea	nc_vermsg(pc),a0
		bsr.b	nc_copy
		add.b	#$30,d1
		move.b	d1,(a3)+
		move.b	#10,(a3)+
nc_noversion:
		clr.b	(a3)+

		lea	keymsgpuffer(a5),a1
		lea	nc_verymsg(pc),a2
		sub.l	a3,a3
		sub.l	a4,a4
		lea	tagitemliste1,a0
		move.l	reqtbase(a5),a6
		jsr	_LVOrtEZRequestA(a6)
		
		move.l	nc_choosewinWnd(a5),a0
		bsr.l	aktiwin

		bra.w	nc_warten

nc_copy:
.w		move.b	(a0)+,d0
		beq.b	.end
		move.b	d0,(a3)+
		bra.b	.w
.end:		rts

nc_creatormsg:	dc.b	'Creator:',0
nc_vermsg:	dc.b	'Version:',0
nc_infomsg:	dc.b	'Info:',0

nc_verymsg:	dc.b	'Very interesting!',0

	even
		
	;*-- Beende Add Window --*
nc_addwech:
		lea	nc_choosewinWnd(a5),a0
		move.l	a0,window(a5)
		lea	newmodulewinGlist(a5),a0
		move.l	a0,Glist(a5)

		jsr	gt_CloseWindow

		move.l	newchoosewinWnd(a5),a0
		bsr.l	aktiwin

		moveq	#GD_nadd,d0
		moveq	#0,d1
		bsr.w	nc_ghostmain

;ewentuell noch auf alte msg vom ersten window warten

		bra.w	nc_wait

;-- Beende alle windows ------

nc_allwech:
		lea	nc_choosewinWnd(a5),a0
		tst.l	(a0)
		beq.w	nc_wech
		move.l	a0,window(a5)
		lea	newmodulewinGlist(a5),a0
		move.l	a0,Glist(a5)
		jsr	gt_CloseWindow

		bra.w	nc_wech


;-----------------------------------------------------------------------------

nc_nodelist:	dc.l	gloadreqList
		dc.l	gsavereqList
		dc.l	goperatorList

nc_nodelist1:
		dc.l	nc_loadernode
		dc.l	nc_savernode
		dc.l	nc_operatornode


nc_loadernode:
.lh_head	dc.l	.lh_tail
.lh_tail	dc.l	0
		dc.l	.lh_head
		dc.l	0

nc_savernode:
.lh_head	dc.l	.lh_tail
.lh_tail	dc.l	0
		dc.l	.lh_head
		dc.l	0

nc_operatornode:
.lh_head	dc.l	.lh_tail
.lh_tail	dc.l	0
		dc.l	.lh_head
		dc.l	0


nc_notenoughmem: dc.b	'Not enought memory to add a new node!',0
		even

;----------------------------------------------------------------------------
NewchoosewinWindowTags:
newchoosewinL:	dc.l	WA_Left,0
newchoosewinT:	dc.l	WA_Top,80
newchoosewinW:	dc.l	WA_Width,274
newchoosewinH:	dc.l	WA_Height,148
		dc.l	WA_IDCMP,RAWKEY!LISTVIEWIDCMP!IDCMP_VANILLAKEY!BUTTONIDCMP!IDCMP_CLOSEWINDOW!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_DEPTHGADGET!WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_CLOSEGADGET!WFLG_SMART_REFRESH
newchoosewinWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title
newwintitle:	dc.l	nc_chooseloader
		dc.l	WA_ScreenTitle,mainwinstitle  ;choosewinSTitle
newchoosewinSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

nc_chooseloader:	dc.b    'Choose loader',0
nc_choosesaver:		dc.b    'Choose saver',0
nc_chooseoperator:	dc.b	'Choose operator',0
	even

nc_choosemodulTags:
nc_choosewinL:	dc.l	WA_Left,0
nc_choosewinT:	dc.l	WA_Top,80
nc_choosewinW:	dc.l	WA_Width,274
nc_choosewinH:	dc.l	WA_Height,148
		dc.l	WA_IDCMP,RAWKEY!LISTVIEWIDCMP!IDCMP_VANILLAKEY!BUTTONIDCMP!IDCMP_CLOSEWINDOW!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_DEPTHGADGET!WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_CLOSEGADGET!WFLG_SMART_REFRESH
nc_choosewinWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title
nc_wintitle:	dc.l	nc_chooseloader
		dc.l	WA_ScreenTitle,mainwinstitle  ;choosewinSTitle
nc_choosewinSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

nc_chooseloader1:	dc.b    'Add a loader',0
nc_choosesaver1:	dc.b    'Add a saver',0
nc_chooseoperator1:	dc.b	'Add a operator',0


nc_erroropenmsg: dc.b	'Error open window!',0

	even
;---------------------------------------------------------------------------
		;*--- Nodelist für Loader ---*

gloadreqNodes0:
		dc.l	gloadreqNodes1
		dc.l	gloadreqList
		dc.b	0,0
		dc.l	gloadreqName7
		dc.l	autoload		;Loadroutine
		dc.b	'AUTO'
		dc.b	'INTR'		;es ist ein Internes Modul
		dc.l	0
		dc.l	AUTO_Tags

gloadreqNodes1:
		dc.l	gloadreqNodes2
		dc.l	gloadreqNodes0
		dc.b	0,0
		dc.l	gloadreqName0
		dc.l	loadiff		;Loadroutine
		dc.b	'LIFF'
		dc.b	'INTR'		;es ist ein Internes Modul
		dc.l	0
		dc.l	LIFF_Tags

gloadreqNodes2:
		dc.l	gloadreqNodes3
		dc.l	gloadreqNodes1
		dc.b	0,0
		dc.l	gloadreqName6
		dc.l	loaddatatype
		dc.b	'LDTC'
		dc.b	'INTR'
		dc.l	0
		dc.l	LDTC_Tags

gloadreqNodes3:
		dc.l	gloadreqNodes4
		dc.l	gloadreqNodes2
		dc.b	0,0
		dc.l	gloadreqName1
		dc.l	loadscreen	;Lade ein Screen
		dc.b	'LSCR'
		dc.b	'INTR'
		dc.l	0
		dc.l	LSCR_Tags

gloadreqNodes4:
		dc.l	gloadreqNodes5
		dc.l	gloadreqNodes3
		dc.b	0,0
		dc.l	gloadreqName2
		dc.l	loadraw		;loadrawblit
		dc.b	'LRAW'
		dc.b	'INTR'
		dc.l	0
		dc.l	LRAW_Tags

gloadreqNodes5:
		dc.l	gloadreqNodes6
		dc.l	gloadreqNodes4
		dc.b	0,0
		dc.l	gloadreqName3
		dc.l	loadrawblitt
		dc.b	'LRAB'
		dc.b	'INTR'
		dc.l	0
		dc.l	LRAB_Tags

gloadreqNodes6:
		dc.l	gloadreqList+4
		dc.l	gloadreqNodes5
		dc.b	0,0
		dc.l	gloadreqName4
		dc.l	loadcolor
		dc.b	'LCOR'
		dc.b	'INTR'
		dc.l	0
		dc.l	LCOR_Tags

gloadreqList:
		dc.l	gloadreqNodes0,0,gloadreqNodes6

gloadreqName0:		dc.b	'IFF ILBM',0
gloadreqName1:		dc.b	'SCREEN',0
gloadreqName2:		dc.b	'RAW',0
gloadreqName3:		dc.b	'RAW INTERLEAVED',0
gloadreqName4:		dc.b	'PALETTE',0
gloadreqName6:		dc.b	'DATATYPE',0
gloadreqName7:		dc.b	'UNIVERSAL',0

	even

LIFF_Tags:
		dc.l	APT_Creator,DEF_Creator
		dc.l	APT_Version,1
		dc.l	APT_Info,LIFF_Info
		dc.l	APT_Autoload,1
		dc.l	0

LIFF_Info:
		dc.b	'Interchange File Format',10
		dc.b	'InterLeaved BitMap loader',10,10
		dc.b	'Loads any IFF ILBM picture. The first frame',10
		dc.b	'of IFF ANIMs is read as well.',10
		dc.b	'24Bit is supported.',0

	even
LDTC_Tags:
		dc.l	APT_Creator,DEF_Creator
		dc.l	APT_Version,1
		dc.l	APT_Info,LDTC_Info
		dc.l	0
LDTC_Info:
		dc.b	'OS3.x system datatype loader',10,10
		dc.b	'Uses the OS3.x system datatypes for loading',10
		dc.b	'alien file formats. Only picture class datatypes',10
		dc.b	'are supported.',0
	even		
LSCR_Tags
		dc.l	APT_Creator,DEF_Creator
		dc.l	APT_Version,1
		dc.l	APT_Info,LSCR_Info
		dc.l	0
LSCR_Info:
		dc.b	'Screen grabber',10,10
		dc.b	'This loader is a screen grabber that allows you',10
		dc.b	'to fetch any screen that is open on your system.',0
	even		
LRAW_Tags:
		dc.l	APT_Creator,DEF_Creator
		dc.l	APT_Version,1
		dc.l	APT_Info,LRAW_Info
		dc.l	0
LRAW_Info:
		dc.b	'raw bitplane loader',10,10
		dc.b	'Tries to load raw bitplane data. Be prepared to',10
		dc.b	'specify width, height, and the number of bitplanes.',0
	even		
LRAB_Tags:
		dc.l	APT_Creator,DEF_Creator
		dc.l	APT_Version,1
		dc.l	APT_Info,LRAB_Info
		dc.l	0
LRAB_Info:
		dc.b	'raw interleaved bitplane loader',10,10
		dc.b	'Tries to load raw interleaved bitplane data. Be',10
		dc.b	'prepared to specify width, height, and the number',10
		dc.b	'of bitplanes.',0
	even
LCOR_Tags:
		dc.l	APT_Creator,DEF_Creator
		dc.l	APT_Version,1
		dc.l	APT_Info,LCOR_Info
		dc.l	APT_Prefs,lpal_Prefs		;routine for Prefs
		dc.l	APT_Prefsbuffer,daten+lpal_iff ;buffer for Prefs
		dc.l	APT_Prefsbuffersize,8		;size of buffer
		dc.l	APT_PrefsVersion,1		;Prefs Version
		dc.l	0
LCOR_Info:
		dc.b	'color information loader',10,10
		dc.b	'Loads raw palette data over a previously',10
		dc.b	'loaded picture. The raw data will be interpreted',10
		dc.b	'according to your preferred color settings.',10
		dc.b	'If IFF selected, you can also rip the palette out',10
		dc.b	'of an IFF picture',0
	even
AUTO_Tags:
		dc.l	APT_Creator,DEF_Creator
		dc.l	APT_Version,1
		dc.l	APT_Info,AUTO_Info
AUTO_Info:
		dc.b	'Universal Loader',10,10
		dc.b	'Trying to detect automaticly the image format!',0
	even

DEF_Creator:
		dc.b	'(c) 1994/96 Frank Pagels /DEFECT SoftWorks',0


		;*--- Nodelist für Saver ---*

		even
gsavereqNodes0:
		dc.l	gsavereqNodes1
		dc.l	gsavereqList
		dc.b	0,0
		dc.l	gsavereqName0
		dc.l	Saveiff		;saveroutine
		dc.b	'SIFF'
		dc.b	'INTR'
		dc.l	0
		dc.l	SIFF_Tags
gsavereqNodes1:
		dc.l	gsavereqNodes3
		dc.l	gsavereqNodes0
		dc.b	0,0
		dc.l	gsavereqName1
		dc.l	saveraw
		dc.l	'SRAW'
		dc.b	'INTR'
		dc.l	0
		dc.l	SRAW_Tags
gsavereqNodes3:
		dc.l	gsavereqNodes4
		dc.l	gsavereqNodes1
		dc.b	0,0
		dc.l	gsavereqName3
		dc.l	saveSprite
		dc.b	'SSPR'
		dc.b	'INTR'
		dc.l	0
		dc.l	SSPR_Tags

gsavereqNodes4:
		dc.l	gsavereqNodes5
		dc.l	gsavereqNodes3
		dc.b	0,0
		dc.l	gsavereqName4
		dc.l	savecolor	 ;savecolor
		dc.b	'SCOL'
		dc.b	'INTR'
		dc.l	0
		dc.l	SCOL_Tags

gsavereqNodes5:
		dc.l	gsavereqList+4
		dc.l	gsavereqNodes4
		dc.b	0,0
		dc.l	gsavereqName7
		dc.l	savechunky		;savechunky
		dc.b	'SCHK'
		dc.b	'INTR'
		dc.l	0
		dc.l	CHKL_Tags

gsavereqList:
		dc.l	gsavereqNodes0,0,gsavereqNodes5

gsavereqName0:		dc.b	'IFF ILBM',0
gsavereqName1:		dc.b	'RAW',0
gsavereqName3:		dc.b	'SPRITE',0
gsavereqName4:		dc.b	'PALETTE',0
gsavereqName7:		dc.b	'CHUNKY',0
	even

SIFF_Tags:
		dc.l	APT_Creator,DEF_Creator
		dc.l	APT_Version,1
		dc.l	APT_Info,SIFF_Info
		dc.l	APT_Prefs,SIFF_Prefs	;routine for Prefs
		dc.l	APT_Prefsbuffer,daten+SIFF_pack	;buffer for Prefs
		dc.l	APT_Prefsbuffersize,2		;size of buffer
		dc.l	APT_PrefsVersion,2		;Prefs Version
		dc.l	APT_OperatorUse,1
		dc.l	0

SIFF_Info:
		dc.b	'Interchange File Format',10
		dc.b	'InterLeaved BitMap saver',10,10
		dc.b	'Saves an image as compressed IFF ILBM.',0
	even
SRAW_Tags:
		dc.l	APT_Creator,DEF_Creator
		dc.l	APT_Version,1
		dc.l	APT_Info,SRAW_Info
		dc.l	APT_Prefs,SRAW_Prefs		;routine for Prefs
		dc.l	APT_Prefsbuffer,daten+SRAW_outsource ;buffer for Prefs
		dc.l	APT_Prefsbuffersize,27		;size of buffer
		dc.l	APT_PrefsVersion,1		;Prefs Version
		dc.l	0
SRAW_Info:
		dc.b	'raw bitplane saver',10,10
		dc.b	'Saves an image or brush as raw bitplanes.',10
		dc.b	'The width is aligned to words (multiples of 16 pixels).',0
	even
SSPR_Tags:
		dc.l	APT_Creator,DEF_Creator
		dc.l	APT_Version,1
		dc.l	APT_Info,SSPR_Info
		dc.l	APT_Prefs,spr_Prefs		;routine for Prefs
		dc.l	APT_Prefsbuffer,daten+spr_asmsource ;buffer for Prefs
		dc.l	APT_Prefsbuffersize,32		;size of buffer
		dc.l	APT_PrefsVersion,1		;Prefs Version
		dc.l	0
SSPR_Info:
		dc.b	'sprite(s) saver',10,10
		dc.b	'Saves an image or brush as raw sprite data.',0
	even			
SCOL_Tags:
		dc.l	APT_Creator,DEF_Creator
		dc.l	APT_Version,1
		dc.l	APT_Info,SCOL_Info
		dc.l	APT_Prefs,pal_Prefs		;routine for Prefs
		dc.l	APT_Prefsbuffer,daten+pal_asmsource ;buffer for Prefs
		dc.l	APT_Prefsbuffersize,27		;size of buffer
		dc.l	APT_PrefsVersion,1		;Prefs Version
		dc.l	0
SCOL_Info:
		dc.b	'palette saver',10,10
		dc.b	"Saves an image's palette according to the color settings.",0
	even
CHKL_Tags:
		dc.l	APT_Creator,DEF_Creator
		dc.l	APT_Version,1
		dc.l	APT_Info,CHKL_Info
		dc.l	APT_Prefs,chk_Prefs		;routine for Prefs
		dc.l	APT_Prefsbuffer,daten+chk_asmsource ;buffer for Prefs
		dc.l	APT_Prefsbuffersize,31		;size of buffer
		dc.l	APT_PrefsVersion,1		;Prefs Version
		dc.l	0

CHKL_Info:
		dc.b	'raw one-byte-per-pixel saver',10,10
		dc.b	'Saves an image or brush as chunkies.',10
		dc.b	'Each pixel is represented by a byte that informs',10
		dc.b	'about the pen number.',0

	even

		;*--- Nodelist für Operator ---*

operatorNodes0:
		dc.l	goperatorList+4
		dc.l	goperatorList
		dc.b	0,0
		dc.l	operatorName0
		dc.l	packcolor
		dc.b	'PCOL'
		dc.b	'INTR'
		dc.l	0
		dc.l	PCOL_Tags

goperatorList:
		dc.l	OperatorNodes0,0,OperatorNodes0


operatorName0:	dc.b	'Pack colors',0

PCOL_Tags:
		dc.l	APT_Creator,DEF_Creator
		dc.l	APT_Version,1

;***************************************************************************
;*------------------------ Ändere Text im Gadget --------------------------*
;***************************************************************************
;d5 = Text d6 = Gadget
setnewname:
		movem.l d1-d3/a0-a2/a6,-(sp)
		lsl.l	#2,d6
		lea	mainwinGadgets,a0
		move.l	(a0,d6),a0
		lea	nametext(pc),a1
		move.l	d5,(a1)
		move.l	mainwinWnd(a5),a1
		sub.l	a2,a2
		lea	nametag(pc),a3
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
		movem.l (sp)+,d1-d3/a0-a2/a6
		rts		

nametag:
		dc.l	GTTX_Text
nametext:	dc.l	0
		dc.l	TAG_DONE

		
;***************************************************************************
;*---------------- aktuallisiere Picsize and Color Gads -------------------*
;***************************************************************************
setpicsizegads:
		moveq	#0,d1
		move.w	breite(a5),d1
		move.l	#GD_gxsize,d0
		jsr	setnumber
		
		move.w	hoehe(a5),d1
		move.l	#GD_gysize,d0
		jsr	setnumber

		move.l	#GD_gxbrush,d0
		moveq	#0,d1
		jsr	setnumber	;Lösche brush x,y
		move.l	#GD_gybrush,d0
		moveq	#0,d1
		jsr	setnumber	;Lösche brush x,y

		cmp.l	#'ICON',d7	;wir kommen von iconify !
		beq.w	.w
		clr.w	cutflag(a5)
		
;Gebe farbmodus aus
.w
		cmp.l	#'ICON',d7	;wir kommen von iconify !
		bne.b	.w1
		rts
		
.w1		moveq	#0,d0
		move.w	anzcolor(a5),d0	

		cmp.b	#24,planes(a5)
		bne.b	.no24
		rts			;wir haben ein 24 Bit Pic eingeladen

.no24:
		moveq	#0,d7
		tst.b	ehb(a5)
		beq.b	.noehb
		moveq	#8,d1
		moveq	#5,d6
		move.l	#64,d0
		bra.b	setcolor
.noehb:
		tst.b	ham(a5)		;Hambild ?
		beq.b	.noham
		moveq	#9,d1
		moveq	#3,d6
		moveq	#16,d0
		bra.b	setcolor
.noham:
		tst.b	ham8(a5)
		beq.b	.noh8
		moveq	#10,d1
		moveq	#5,d6
		moveq	#64,d0
		bra.b	setcolor
.noh8
		cmp.w	#2,d0		;nur 2 Farben ?
		bne.b	.nomono
		moveq	#0,d1
		moveq	#0,d6
		bra.b	setcolor
.nomono:
		cmp.w	#4,d0		
		bne.b	.no4
		moveq	#1,d1
		moveq	#1,d6
		bra.b	setcolor
.no4:
		cmp.w	#8,d0		
		bne.b	.no8
		moveq	#2,d1
		moveq	#2,d6
		bra.b	setcolor
.no8:
		cmp.w	#16,d0		
		bne.b	.no16
		moveq	#3,d1
		moveq	#3,d6
		bra.b	setcolor
.no16:
		cmp.w	#32,d0		
		bne.b	.no32
		moveq	#4,d1
		moveq	#4,d6
		bra.b	setcolor
.no32:
		cmp.w	#64,d0		
		bne.b	.no64
		moveq	#5,d1
		moveq	#5,d6
		bra.b	setcolor
.no64:
		cmp.w	#128,d0		
		bne.b	.no128
		moveq	#6,d1
		moveq	#6,d6
		bra.b	setcolor
.no128:
		cmp.w	#256,d0		
		bne.b	.no256
		moveq	#7,d1
		moveq	#7,d6
		bra.w	setcolor
.no256:
		
setcolor:
		move.l	d1,aktcolordepth(a5)
		move.l	d6,ren_colvis
		move.l	d0,ren_ucolmax

		clr.b	depthchange(a5)	 ;Es muß noch nicht gerendert werden
		
		moveq	#0,d0
		tst.b	ehb(a5)
		beq.b	.w
		moveq	#3,d0
.w		tst.b	ham(a5)
		beq.b	.wnh
		moveq	#2,d0
.wnh		tst.b	ham8(a5)
		beq.b	.wh8
		moveq	#1,d0
.wh8		lea	ren_palmodetag(pc),a0
		move.l	d0,(a0)

		moveq	#2,d0
		lsl.l	d6,d0
		move.l	d0,ren_colorlevel(a5)

		lea	de_tab(pc),a2
		move.l	(a2,d1.l*4),a0
		move.l	a0,TAG_depthcolor
		
		lea	ren_texttag(pc),a3
		move.l	a0,4(a3)
		lea	ren_paltext(pc),a1
		move.l	(a2,d6.l*4),(a1)
		move.l	#GD_gdepth,d0
		lea	mainwingadgets,a0
		move.l	(a0,d0.l*4),a0
		move.l	mainwinWnd(a5),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jmp	_LVOGT_SetGadgetAttrsA(a6)

de_tab:
		dc.l	de0,de1,de2,de3,de4,de5,de6,de7,de8,de9,de10,de11

de0		dc.b	'2',0
de1		dc.b	'4',0
de2		dc.b	'8',0
de3		dc.b	'16',0
de4		dc.b	'32',0
de5		dc.b	'64',0
de6		dc.b	'128',0
de7		dc.b	'256',0
de8		dc.b	'EHB',0
de9		dc.b	'HAM6',0
de10		dc.b	'HAM8',0
de11		dc.b	'16M',0

	even
	
;***************************************************************************
;*------------------------ Zeige Bild an ----------------------------------*
;***************************************************************************
viewpic:
		move.l	mainwinwnd(a5),a0
		bsr.l	setwaitpointer

		clr.b	merk(a5)	;das Pic wird nur angeschaut
		bsr.w	openpic
		cmp.l	#-1,d0
		bne.b	.w
		move.l	mainwinwnd(a5),a0
		bsr.l	clearwaitpointer
		bra.w	waitaction		

.w		
		move.l	scr1(a5),a0
		move.l	intbase(a5),a6
		jsr	_LVOScreentoFront(a6)
.waitview:
		move.l	viewWnd(a5),a0
		bsr.w	wait

		cmp.l	#IDCMP_MouseButtons,d4
		beq.b	.pressbutton
		cmp.l	#IDCMP_VANILLAKEY,d4
		beq.b	.keys
		bra.b	.waitview
.keys:
		cmp.w	#27,d5	;ESC
		bne.b	.waitview

.pressbutton:
		move.l	scr1(a5),a0
		move.l	intbase(a5),a6
		jsr	_LVOScreentoBack(a6)

		bsr.w	CloseViewWindow

		bsr.w	checkscreenpos
		sf	newloaded(a5)

		bsr.w	CloseDownViewScreen

		jsr	memcheck
		
		lea	readymsg,a4
		jsr	status
		
		move.l	mainwinwnd(a5),a0
		bsr.l	clearwaitpointer

		move.l	mainwinwnd(a5),a0
		jsr	aktiwin

		bra.w	waitaction

;--------------------------------------------------------------------------
;------------------   Render ----------------------------------------------
;--------------------------------------------------------------------------
;render ein Pic auf die eingestellen Farbe hin
render:

;unterteilung des Rendermem:
;
;chunkypuffer
;rgbpuffer

;besorge Speicher für Histogramm

;berechne Speicher

		bsr.w	openprocess

		moveq	#0,d7
		move.l	renderbase(a5),a6
		tst.l	rndr_memhandler(a5)
		bne.b	rndr_inithisto
;Init Render 

		move.l	renderbase(a5),a6
		sub.l	a1,a1
		tst.b	kick3(a5)
		beq.b	.no3
		lea	.rndr_memtag(pc),a1	;Kick 3.0 , wir können Pool benutzen
.no3:
		jsr	_LVOCreateRMHandlerA(a6)
		tst.l	d0
		bne.b	.ok
		bsr.w	clearprocess
		moveq	#-1,d0
		rts		
.rndr_memtag:
		dc.l	RND_MemType,RMHTYPE_POOL
		dc.l	TAG_DONE

.ok:
		move.l	d0,rndr_memhandler(a5)

rndr_inithisto:
		move.l	#'NOHI',APG_Free8(a5)
		tst.l	rndr_histogram(a5)
		bne.b	.nixhisto

		clr.l	rndr_histogram(a5)

		lea	rndr_histotag(pc),a1
		move.l	rndr_memhandler(a5),4(a1)
		lea	rdnr_htab(pc),a2
		moveq	#0,d0
		move.b	hsize(a5),d0
		move.l	(a2,d0*4),12(a1)	;Histo size
		jsr	_LVOCreateHistogramA(a6)
		tst.l	d0
		beq.w	rndr_fail2

		move.l	d0,rndr_histogram(a5)

		clr.l	APG_Free8(a5)
		
.nixhisto:
		moveq	#0,d7
		tst.l	rndr_rendermem(a5)
		beq	rndr_preparepic
		move.l	#'RGBU',d7	;es soll add rgb benutzt werden
		bra	rndr_dohisto

rndr_preparepic:

		lea	rndr_preparemsg(pc),a1
		moveq	#3,d0
		bsr.w	initprocess

		tst.l	rndr_rendermem(a5)
		bne.w	rndr_memok1

		move.l	bytebreite(a5),d0
		lsl.l	#3,d0
		mulu.w	hoehe(a5),d0
		move.l	d0,d7		;Chunky8 größe
		move.l	d0,rndr_chunky8size(a5)
		mulu.l	#4,d0
		move.l	d0,rndr_rgbsize(a5)
		add.l	d0,d7
	;	add.l	#rndr_buffersize,d7
		move.l	d7,d0
	;	add.l	#rndr_workpuffer,d0
		
		move.l	4.w,a6
		move.l	#MEMF_ANY+MEMF_CLEAR,d1		
		jsr	_LVOAllocVec(a6)
		tst.l	d0
		bne.w	rndr_memok
rndr_norender:	lea	norendermsg(pc),a4
		jsr	status
		move.l	mainwinWnd(a5),a0
		bsr.l	clearwaitpointer
		bsr.w	clearprocess
		moveq	#-1,d0
		rts
		

rdnr_htab:
		dc.l	HSTYPE_12BIT_TURBO
		dc.l	HSTYPE_15BIT_TURBO
		dc.l	HSTYPE_18BIT_TURBO
		dc.l	HSTYPE_21BIT
		dc.l	HSTYPE_24BIT
		
rndr_histotag:
		dc.l	RND_RMHandler,0
		dc.l	RND_HSType
rndr_hsize:	dc.l	HSTYPE_15BIT_TURBO
		dc.l	TAG_DONE

rndr_c2rtag:
		dc.l	RND_ColorMode,0
		dc.l	RND_LeftEdge,0
		dc.l	TAG_DONE

rndr_paltag:	dc.l	RND_RMHandler,0
		dc.l	RND_HSType,HSTYPE_18BIT
		dc.l	TAG_DONE

rndr_palitag:	dc.l	RND_PaletteFormat,PALFMT_RGB8
		dc.l	TAG_DONE

rndr_exttag:
		dc.l	RND_ColorMode,0
		dc.l	RND_ProgressHook,doprocess_hookstruck
		dc.l	RND_NewPalette,1
		dc.l	TAG_DONE
rndr_addtag:
		dc.l	RND_ProgressHook,doprocess_hookstruck
		dc.l	TAG_DONE
rndr_sorttag:
		dc.l	RND_Histogram,0
		dc.l	TAG_DONE


norendermsg:	dc.b	'Cannot render! Out of memory!',0

rndr_memok:
		move.l	d0,rndr_rendermem(a5)
;erzeuge ein RGB Pic

;Loadrgb32 tab convertieren
rndr_memok1

		bsr.w	doprocess
		tst.l	d0
		beq.w	rndr_fail1

		lea	farbtab8(a5),a0
		lea	farbtab8pure,a1
		move.l	(a0)+,d7
		swap	d7
		move.l	d7,d6
		subq.w	#1,d7

.ncc		moveq	#0,d1
		move.l	(a0)+,d0
		lsr.l	#8,d0
		move.l	(a0)+,d1
		swap	d1
		or.w	d1,d0
		move.l	(a0)+,d1
		rol.l	#8,d1
		or.b	d1,d0

		move.l	d0,(a1)+

		dbra	d7,.ncc		

		tst.b	ehb(a5)
		beq.b	.nehb

		lea	farbtab8(a5),a0
		move.l	(a0)+,d7
		add.l	d6,d6
		swap	d7
		subq.w	#1,d7

.cc		moveq	#0,d1
		move.l	(a0)+,d0
		lsr.l	#1,d0
		lsr.l	#8,d0
		move.l	(a0)+,d1
		lsr.l	#1,d1
		swap	d1
		or.w	d1,d0
		move.l	(a0)+,d1
		lsr.l	#1,d1
		rol.l	#8,d1
		or.b	d1,d0

		move.l	d0,(a1)+
		dbra	d7,.cc

;Palette erzeugen

.nehb
		tst.l	rndr_palette(a5)
		bne.b	.wp
		lea	rndr_paltag(pc),a1
		move.l	rndr_memhandler(a5),4(a1)
		move.l	renderbase(a5),a6
		jsr	_LVOCreatePaletteA(a6)
		move.l	d0,rndr_palette(a5)
.wp
		move.l	rndr_palette(a5),a0
		move.l	d6,d0		;Farbanzahl
		lea	farbtab8pure,a1
		lea	rndr_palitag(pc),a2
		move.l	renderbase(a5),a6
		jsr	_LVOImportPaletteA(a6)		

;zuerst ein Chunky Pic erzeugen

		lea	rndr_planetab(pc),a1	;init Planetab
		move.l	a1,a0
		moveq	#0,d7
		move.b	planes(a5),d7
		subq.l	#1,d7
		move.l	picmem(a5),d0
.np		move.l	d0,(a1)+
		add.l	oneplanesize(a5),d0
		dbra	d7,.np
.weiter
		move.l	rndr_rendermem(a5),a1
	;	add.l	#rndr_buffersize,a1	;Chunkypuffer
		move.l	a1,rndr_chunky(a5)	;merken
		move.l	APG_ByteWidth(a5),d0
		move.w	hoehe(a5),d1
		moveq	#0,d2
		move.b	planes(a5),d2
		move.l	APG_ByteWidth(a5),d3
		
		move.l	renderbase(a5),a6
		
		sub.l	a2,a2
		
		jsr	_LVOPlanar2Chunky(a6)

		bsr.w	doprocess

		tst.l	d0
		beq.w	rndr_fail1

;jetzt ein RGB pic erzeugen

		move.l	rndr_chunky(a5),a0	;Chunkypuffer
		move.l	a0,a1
		add.l	rndr_chunky8size(a5),a1	;RGB puffer
		move.l	a1,rndr_rgb(a5)
		move.l	a1,d7
;		lea	farbtab8pure,a2		;Palette
		move.l	rndr_palette(a5),a2

		moveq	#0,d0

		move.l	bytebreite(a5),d0
		lsl.l	#3,d0			;gesamt Chunkybreite
		move.w	hoehe(a5),d1
		moveq	#COLORMODE_CLUT,d5

		tst.b	ham(a5)
		beq.b	.w
		moveq	#COLORMODE_HAM6,d5
		bra.b	.ren
.w		tst.b	ham8(a5)
		beq.b	.ren
		moveq	#COLORMODE_HAM8,d5
.ren
		lea	rndr_c2rtag(pc),a3
		move.l	d5,4(a3)		;Colormode eintragen

		jsr	_LVOChunky2RGBA(a6)
				
		bsr.w	doprocess
		tst.l	d0
		beq.w	rndr_fail1

;erzeuge Histogram

rndr_dohisto:
		cmp.l	#'NOHI',APG_Free8(a5)
		beq.b	rndr_median

		lea	rndr_buildhistomsg(pc),a1
		moveq	#1,d0
		bsr.w	initprocess

		move.b	ham(a5),d0
		add.b	ham8(a5),d0
		tst.b	d0
		bne.b	.ham

		cmp.b	#24,planes(a5)
		beq.b	.ham

		cmp.l	#'RGBU',d7
		beq	.ham
		
		move.l	rndr_histogram(a5),a0
		move.l	rndr_chunky(a5),a1	;Chunkypuffer
;		lea	farbtab8pure,a2		;Palette
		move.l	rndr_palette(a5),a2
		
		move.l	bytebreite(a5),d0
		lsl.l	#3,d0
		move.w	hoehe(a5),d1
		lea	rndr_addtag(pc),a3
		
		jsr	_LVOAddChunkyImageA(a6)
;		cmp.l	#ADDH_SUCCESS,d0	;!!!!!!!!!!!!!
		cmp.l	#ADDH_CALLBACK_ABORTED,d0
		beq.w	rndr_fail1
		bra.b	.addok
.ham:
		move.l	rndr_histogram(a5),a0
		move.l	rndr_rgb(a5),a1		;RGB Pic
		move.l	bytebreite(a5),d0
		lsl.l	#3,d0
		move.w	hoehe(a5),d1
		lea	rndr_addtag(pc),a2
		jsr	_LVOAddRGBImageA(a6)
;		cmp.l	#ADDH_SUCCESS,d0	;!!!!!!!!!!!!!
		cmp.l	#ADDH_CALLBACK_ABORTED,d0
		beq.w	rndr_fail1
		
.addok
		move.l	d1,rndr_timepuffer

;------------------------------------------------------------------------
;Median Cut
rndr_median:
		move.l	rndr_palette(a5),a0
		move.l	renderbase(a5),a6
		jsr	_LVOFlushPalette(a6)

		lea	rndr_choosecolormsg(pc),a1
		moveq	#1,d0
		bsr.w	initprocess

		lea	rndr_exttag(pc),a2		
		move.l	#COLORMODE_CLUT,4(a2)

		moveq	#0,d7
		move.w	anzcolorbak(a5),d7
		cmp.w	#'HB',d7
		bne.b	.noehb1
		moveq	#32,d7
.noehb1:
		cmp.w	#'M6',d7
		bne.b	.noham61
		moveq	#16,d7
		move.l	#COLORMODE_HAM6,4(a2)
.noham61:
		cmp.w	#'M8',d7
		bne.b	.noham81
		moveq	#64,d7
		move.l	#COLORMODE_HAM8,4(a2)
.noham81:
		move.l	rndr_histogram(a5),a0
;		lea	farbtab8pure,a1
		move.l	rndr_palette(a5),a1
		move.l	d7,d0			;anz Colors

		tst.l	ren_cust(a5)
		beq.b	.nixcust		;Keine Custom Palette
		move.l	ren_usedcolors(a5),d0
.nixcust:
		jsr	_LVOExtractPaletteA(a6)

		cmp.l	#EXTP_CALLBACK_ABORTED,d0
		beq.w	rndr_fail2
		move.l	d1,rndr_timepuffer+4

;render Palette
		cmp.w	#'HB',anzcolorbak(a5)
		bne.b	.noehb3			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;verdoppel Palette für ehb

		move.l	rndr_palette(a5),a0
		lea	farbtab8pure,a1
;		move.l	#32,d0
		lea	rndr_palitag(pc),a2
		jsr	_LVOExportPaletteA(a6)
		
		lea	farbtab8pure,a0
		lea	4*32(a0),a1
		moveq	#32-1,d7
.ncehb:		move.l	(a0)+,d0
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#1,d1
		lsr.w	#8,d0
		move.b	d0,d2
		lsr.b	#1,d2
		lsl.l	#8,d2
		or.w	d2,d1
		swap	d0
		lsr.b	#1,d0
	;	lsl.w	#8,d0
		swap	d0
		and.l	#$00ff0000,d0
		or.l	d0,d1
		move.l	d1,(a1)+
		dbra	d7,.ncehb

		move.l	rndr_palette(a5),a0
		lea	farbtab8pure,a1
		move.l	#64,d0
		lea	rndr_palitag(pc),a2
		jsr	_LVOImportPaletteA(a6)

		moveq	#64,d7
.noehb3:

;---- sortiere Palette -------
rndr_sort:
		tst.l	ren_palsortmode(a5)
		beq.b	rndr_render		;nicht sortieren
		move.l	rndr_palette(a5),a0

		move.l	ren_palsortmode(a5),d0
		or.l	ren_palordermode(a5),d0

		lea	rndr_sorttag(pc),a1
		move.l	rndr_histogram(a5),4(a1)
		jsr	_LVOSortPaletteA(a6)		

;------------------------------------------------------------------------
rndr_render:
		lea	rndr_renderimagemsg(pc),a1
		moveq	#1,d0
		bsr.w	initprocess

		move.l	rndr_histogram(a5),a0
		move.w	anzcolorbak(a5),d7
		moveq	#COLORMODE_CLUT,d0
		cmp.w	#'HB',d7
		bne.b	.noehb1
		moveq	#32,d7
.noehb1:
		cmp.w	#'M6',d7
		bne.b	.noham61
		moveq	#16,d7
		moveq	#COLORMODE_HAM6,d0
.noham61:
		cmp.w	#'M8',d7
		bne.b	.noham81
		moveq	#64,d7
		moveq	#COLORMODE_HAM8,d0
.noham81:
		lea	rndr_rendertag(pc),a3
		move.l	d0,4(a3)
		clr.l	20(a3)		;Coloroffsetzero

		tst.l	ren_cust(a5)
		beq.b	.nixcust
		move.l	ren_firstcolors(a5),20(a3)
.nixcust:
		move.l	ren_dithermode(a5),12(a3)	;Dither Mode eintragen
		move.l	ren_damount(a5),28(a3)		;Dither Amount
		move.l	rndr_rgb(a5),a0		;RGB Pic
		move.l	rndr_chunky(a5),a1	;Chunkypuffer
		move.l	rndr_palette(a5),a2
		move.l	bytebreite(a5),d0
		lsl.l	#3,d0
		move.w	hoehe(a5),d1
		jsr	_LVORenderA(a6)

		cmp.l	#REND_SUCCESS,d0
		bne.w	rndr_fail2

;erzeuge fertiges Bild
		lea	rndr_makeplanes(pc),a1
		moveq	#2,d0
		bsr.w	initprocess

;lösche altes Bild

		move.l	4.w,a6
		move.l	picmem(a5),d0
		beq.b	.nofree
		move.l	d0,a1
		jsr	_LVOFreeVec(a6)	
		clr.l	picmem(a5)
.nofree:
;Lege neues Bild an

		sf	ham(a5)
		sf	ham8(a5)
		sf	ehb(a5)

		moveq	#0,d1
		move.w	anzcolorbak(a5),d1
		cmp.w	#'HB',d1
		beq.b	rndr_ehb
		cmp.w	#'M6',d1
		beq.b	rndr_ham6
		cmp.w	#'M8',d1
		beq.b	rndr_ham8
		bra.b	rndr_normal

rndr_ehb:
		move.w	#32,anzcolor(a5)
		moveq	#6,d0
		move.b	d0,APG_Planes(a5)
		st	ehb(a5)
		bra.b	rndr_makepic
rndr_ham6:
		move.w	#16,anzcolor(a5)
		moveq	#6,d0
		move.b	d0,APG_Planes(a5)
		st	ham(a5)
		bra.b	rndr_makepic
rndr_ham8:
		move.w	#64,anzcolor(a5)
		moveq	#8,d0
		move.b	d0,APG_Planes(a5)
		st	ham8(a5)
		bra.b	rndr_makepic

rndr_normal:
		moveq	#0,d0		;check Planes
.wq:		lsr.l	#1,d1
		bcs.b	.ok
		addq.l	#1,d0
		bra.b	.wq
.ok:
		move.b	d0,APG_Planes(a5)

rndr_makepic:
		move.l	oneplanesize(a5),d1
		mulu.l	d1,d0			;neue Größe des Pic

		move.l	4.w,a6
		move.l	#MEMF_ANY+MEMF_CLEAR,d1		
		jsr	_LVOAllocVec(a6)
		tst.l	d0
		beq.w	rndr_fail
		move.l	d0,picmem(a5)		

		bsr.w	doprocess
		tst.l	d0
		beq.w	rndr_fail2

		lea	picmap(a5),a0	
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.b	planes(a5),d0
		move.l	bytebreite(a5),d1
		lsl.l	#3,d1
		move.w	hoehe(a5),d2
		move.l	gfxbase(a5),a6
		jsr	_LVOinitbitmap(a6)

		lea	picmap+8(a5),a0
		move.l	picmem(a5),d0
		moveq	#0,d7		
		move.b	planes(a5),d7	
		subq	#1,d7
.newplane
		move.l	d0,(a0)+	;Planes in Strucktur einbinden
		add.l	oneplanesize(a5),d0
		dbra	d7,.newplane

		move.l	renderbase(a5),a6

		move.l	rndr_chunky(a5),a0	;chunky
		lea	picmap(a5),a1
		moveq	#0,d0
		moveq	#0,d1
		move.l	bytebreite(a5),d2
		lsl.l	#3,d2
		move.w	hoehe(a5),d3
		moveq	#0,d4
		moveq	#0,d5
		sub.l	a2,a2			;TagList
		jsr	_LVOChunky2BitmapA(a6)

		bsr.w	doprocess
		tst.l	d0
		beq.w	rndr_fail2

;mäch neue Loadrgb32 Tab

maech32:
		move.l	rndr_palette(a5),a0
		lea	farbtab8pure,a1
		move.w	anzcolor(a5),d7
		tst.b	ham(a5)
		beq.b	.nh6
		moveq	#16,d7
.nh6:		tst.b	ham8(a5)
		beq.b	.nh8
		moveq	#64,d7
.nh8:
		move.l	d7,d6
		tst.l	ren_cust(a5)
		beq.b	.nixcust
		move.l	d7,d5
		subq.l	#1,d5
		move.l	a1,a3
.nc:		clr.l	(a3)+
		dbra	d5,.nc
		move.l	ren_firstcolors(a5),d0
		lsl.l	#2,d0
		add.l	d0,a1
.nixcust:
		lea	rndr_palitag(pc),a2
		jsr	_LVOExportPaletteA(a6)


		lea	farbtab8pure,a0
		lea	farbtab8(a5),a1
;		move.w	anzcolor(a5),d7
;		tst.b	ham(a5)
;		beq.b	.nh6
;		moveq	#16,d7
;.nh6:		tst.b	ham8(a5)
;		beq.b	.nh8
;		moveq	#64,d7
;.nh8:
		move.l	d6,d7

		move.w	d7,(a1)+
		clr.w	(a1)+
		subq.w	#1,d7

.lc		move.l	(a0)+,d0

		moveq	#0,d1
		bfins	d0,d1{0:8}
		lsr.l	#8,d0		
		moveq	#0,d2
		bfins	d0,d2{0:8}
		lsr.l	#8,d0		
		moveq	#0,d3
		bfins	d0,d3{0:8}

		tst.b	ham(a5)
		beq.b	.w

		move.l	d3,d0
		lsr.l	#4,d0
		or.l	d0,d3
		move.l	d2,d0
		lsr.l	#4,d0
		or.l	d0,d2
		move.l	d1,d0
		lsr.l	#4,d0
		or.l	d0,d1

.w		move.l	d3,(a1)+
		move.l	d2,(a1)+
		move.l	d1,(a1)+
		dbra	d7,.lc
		clr.l	(a1)

;		move.l	renderbase(a5),a6
;		move.l	rndr_histogram(a5),a0
;		jsr	_LVODeleteHistogram(a6)

		sf	depthchange(a5)
		bsr.w	clearprocess

		move.l	mainwinWnd(a5),a0
		bsr.l	aktiwin
		
		move.l	mainwinWnd(a5),a0
		bsr.l	clearwaitpointer

		jsr	APR_Save2Tmp(a5)

		bsr	makepreview

		moveq	#0,d0
		rts
rndr_fail:
		move.l	4.w,a6
		move.l	rndr_rendermem(a5),a1
		jsr	_LVOFreeVec(a6)
		clr.l	rndr_rendermem(a5)
		bsr.w	clearprocess
		move.l	mainwinWnd(a5),a0
		bsr.l	aktiwin
		bra.w	rndr_norender
rndr_fail1:
		move.l	renderbase(a5),a6
		move.l	rndr_histogram(a5),d0
		beq.b	.w2
		move.l	d0,a0
		jsr	_LVODeleteHistogram(a6)
		clr.l	rndr_histogram(a5)
.w2
		move.l	4.w,a6
		move.l	rndr_rendermem(a5),a1
		jsr	_LVOFreeVec(a6)
		clr.l	rndr_rendermem(a5)
		bsr.w	clearprocess
		lea	rndr_abortmsg(pc),a4
		bsr.l	status
		st	depthchange(a5)
		move.l	mainwinWnd(a5),a0
		bsr.l	aktiwin
		move.l	mainwinWnd(a5),a0
		bsr.l	clearwaitpointer
		moveq	#-1,d0
		rts
rndr_fail2:
		lea	rndr_abortmsg(pc),a4
		bsr.l	status
		st	depthchange(a5)
		bsr.w	clearprocess
		move.l	mainwinWnd(a5),a0
		bsr.l	aktiwin
		move.l	mainwinWnd(a5),a0
		bsr.l	clearwaitpointer
		moveq	#-1,d0
		rts		


rndr_rendertag:
		dc.l	RND_ColorMode,0
		dc.l	RND_DitherMode,0
		dc.l	RND_OffsetColorZero,0
		dc.l	RND_DitherAmount,0
		dc.l	RND_ProgressHook,doprocess_hookstruck
		dc.l	TAG_DONE
		
rndr_planetab:
		ds.l	8
		

rndr_timepuffer: ds.l	4

rndr_preparemsg: dc.b     'Preparing image ...',0
rndr_buildhistomsg:  dc.b 'Creating histogram ...',0
rndr_choosecolormsg: dc.b 'Choosing colors ...',0
rndr_renderimagemsg: dc.b 'Rendering image ...',0
rndr_makeplanes: dc.b	  'Making bitplanes ...',0

rndr_abortmsg:	dc.b	  'Rendering aborted!',0
	even

;Allociere Speicher für Render:
;
; >d0 = Bytebreite
;  d1 = ZeilenHöhe
; <d0 = Error	0=Error

initrendermem:
		movem.l	d1-a6,-(a7)
		lsl.l	#3,d0
		mulu.w	d1,d0
		move.l	d0,d7		;Chunky8 größe
		move.l	d0,rndr_chunky8size(a5)
		mulu.l	#4,d0
		move.l	d0,rndr_rgbsize(a5)
		add.l	d0,d7
		move.l	d7,d0
		move.l	4.w,a6
		move.l	#MEMF_ANY+MEMF_CLEAR,d1		
		jsr	_LVOAllocVec(a6)
		tst.l	d0
		bne.b	.memok
		moveq	#0,d0
		movem.l	(a7)+,d1-a6
		rts
.memok:
		move.l	d0,rndr_rendermem(a5)
	;	add.l	#rndr_buffersize,d0	;Chunkypuffer
		move.l	d0,rndr_chunky(a5)	;merken
		add.l	rndr_chunky8size(a5),d0	;RGB puffer
		move.l	d0,rndr_rgb(a5)
		moveq	#-1,d0
		movem.l	(a7)+,d1-a6
		rts

;--------------------------------------------------------------------------
;-------- Render Settings -------------------------------------------------
;--------------------------------------------------------------------------
rendercontrol:

		move.l	#ren_WindowTags,APG_WindowTagList(a5) ;Tag list for the Window
		move.l	#ren_WinWG+4,APG_WGadgets(a5)	;addr. of WA_Gadgets Tag + 4
		move.l	#ren_winSC+4,APG_WScreen(a5)	;addr. of WA_CustomScreen Tag + 4
		move.l	#ren_window,APG_WinWnd(a5)	;a point for the Window
		move.l	#ren_Glist,APG_Glist(a5)	;a point for the Glist
		move.l	#ren_NGads,APG_NGads(a5)	;the NGads list
		move.l	#ren_Gtypes,APG_GTypes(a5)	;the GTypes list
		move.l	#ren_Gtags,APG_Gtags(a5)	;the Gtags list
		move.w	#ren_gadanz,APG_CNT(a5)		;the number of Gadgets
		move.l	#ren_gadarray,APG_Gadgets(a5)	;a pointer for the Gadgetsarry, size=4*number of Gadgets
		move.l	APG_Scr(a5),APG_ScrBase(a5)	;the Screenpointer , stored in APG_Scr
	
		move.l	mainwinWnd(a5),a0

		move.l	#185,d0
		bsr.l	computey
				
;zentrier window

		move.w	wd_height(a0),d1
		sub.w	d0,d1
		lsr.w	#1,d1
		add.w	wd_TopEdge(a0),d1
		move.w	d1,APG_WinTop(a5)

		move.l	#100,d0
		bsr.l	computex

		move.w	wd_width(a0),d1
		sub.w	d0,d1
		lsr.w	#1,d1
		add.w	wd_LeftEdge(a0),d1
		move.w	d1,APG_WinLeft(a5)

		move.w	#306,APG_WinWidth(a5)		;the width of the Win
		move.w	#185,APG_WinHeight(a5)		;the height of the Win

		move.l	#ren_WinL,APG_WinL(a5)		;addr. of WA_Left Tag 
		move.l	#ren_WinT,APG_WinT(a5)		;addr. of WA_Top Tag
		move.l	#ren_WinW,APG_WinW(a5)		;addr. of WA_Width Tag
		move.l	#ren_WinH,APG_WinH(a5)		;addr. of WA_Height Tag

		move.l	APG_OpenWindow(a5),a6
		jsr	(a6)

		move.l	ren_window(pc),a0
		moveq	#3,d0
		moveq	#3,d1
		move.l	#299,d2
		move.l	#35,d3
		moveq	#0,d4
		bsr.l	drawframe

		move.l	ren_window(pc),a0
		moveq	#3,d0
		moveq	#41,d1
		move.l	#299,d2
		move.l	#80,d3
		moveq	#0,d4
		bsr.l	drawframe

		move.l	ren_window(pc),a0
		moveq	#3,d0
		moveq	#124,d1
		move.l	#299,d2
		move.l	#36,d3
		moveq	#0,d4
		bsr.l	drawframe

		move.l	MainwinWnd(a5),a0
		bsr.l	setwaitpointer

		move.l	ren_window(pc),a0
		bsr.l	aktiwin

		move.l	ren_palmodetag(pc),d0
		tst.l	d0
		beq.b	.checkdither

		move.l	#GD_ren_colorsslider,d0
		moveq	#1,d1
		bsr.w	ren_ghost

.checkdither:
		moveq	#1,d6
		move.l	#GD_ren_amountslide,d0
		cmp.l	#DITHERMODE_RANDOM,ren_dithermode(a5)
		bne	.w
		moveq	#0,d6
.w
		move.l	d6,d1
		bsr.w	ren_ghost

		move.l	#GD_ren_amount,d0
		move.l	d6,d1
		bsr	ren_ghost
		

;-- Backuppe alte Einstellung
ren_bak
		move.l	ren_colorlevel(a5),ren_colorlevelbak(a5)
		move.l	ren_colormode(a5),ren_colormodebak(a5)
		move.l	ren_palmodetag(pc),ren_palmodetabbak(a5)
		move.l	ren_colvis(pc),ren_colvisbak(a5)
		move.l	ren_paltext(pc),ren_paltextbak(a5)
		move.l	ren_dithertag(pc),ren_dithertagbak(a5)
		move.l	ren_dithermode(a5),ren_dithermodebak(a5)
		move.l	ren_palsortmode(a5),ren_palsortmodebak(a5)
		move.l	ren_palsorttag(pc),ren_palsorttagbak(a5)
		move.l	ren_palordermode(a5),ren_palordermodebak(a5)
		move.l	ren_palodertag(pc),ren_palodertagbak(a5)
		move.l	ren_custtag(pc),ren_custtagbak(a5)
		move.l	ren_cust(a5),ren_custbak(a5)
		move.l	ren_ucolvis(pc),ren_ucolvisbak(a5)
		move.l	ren_usedcolors(a5),ren_usedcolorsbak(a5)
		move.l	ren_firstvis(pc),ren_firstvisbak(a5)
		move.l	ren_firstcolors(a5),ren_firstcolorsbak(a5)
		move.l	ren_ucolmax(pc),ren_ucolmaxbak(a5)
		move.l	ren_ucolnum(pc),ren_ucolnumbak(a5)
		move.l	ren_fnum(pc),ren_fnumbak(a5)

		move.l	ren_damount(a5),ren_damountbak(a5)
		

		moveq	#1,d6
		tst.l	ren_cust(a5)
		beq.b	.w
		moveq	#0,d6
.w		bsr.w	ren_checkghost


ren_wait:	move.l	ren_window(pc),a0
		move.l	APG_Wait(a5),a6
		jsr	(a6)				;Handle input

		cmp.l	#GADGETDOWN,d4
		beq.w	ren_slider
		cmp.l	#GADGETUP,d4
		beq.b	ren_gads
		cmp.l	#IDCMP_CLOSEWINDOW,d4
		beq.w	ren_cancel
		cmp.l	#VANILLAKEY,d4
		beq.b	ren_keys
		bra.b	ren_wait

ren_gads:
		moveq	#0,d0
		move.w	38(a4),d0
		add.l	d0,d0
		add.l	d0,d0
		lea	ren_jumptab(pc),a0
		move.l	(a0,d0.l),d0
		jmp	(a0,d0.l)

ren_jumptab:
		dc.l	ren_palmode-ren_jumptab
		dc.l	ren_colors-ren_jumptab
		dc.l	ren_wait-ren_jumptab
		dc.l	ren_wait-ren_jumptab
		dc.l	ren_wait-ren_jumptab
		dc.l	ren_palsort-ren_jumptab
		dc.l	ren_palorder-ren_jumptab
		dc.l	ren_custom-ren_jumptab
		dc.l	ren_dither-ren_jumptab
		dc.l	ren_ditheramountslide-ren_jumptab
		dc.l	ren_dithernum-ren_jumptab
		dc.l	ren_use-ren_jumptab
		dc.l	ren_cancel-ren_jumptab
		dc.l	ren_render-ren_jumptab
		dc.l	ren_usednum-ren_jumptab
		dc.l	ren_firstnum-ren_jumptab

ren_keys:
		move.l	ren_window(pc),aktwin(a5)

;a0=Gadgets d0=Gadget a3=Routine, in aktwin das aktuelle Fenster

		lea	ren_gadarray(pc),a0

		cmp.w	#'a',d5
		beq	ren_dithertast
		cmp.w	#'m',d5
		beq.w	ren_tastmode
		cmp.w	#'s',d5
		beq.w	ren_tastsort
		cmp.w	#'o',d5
		beq.w	ren_tastorder
		cmp.w	#'d',d5
		beq.w	ren_tastdither
		cmp.w	#'t',d5
		beq.w	ren_tastcust
		cmp.w	#'f',d5
		beq.w	ren_tastfirst
		cmp.w	#'e',d5
		beq.w	ren_tastused
		cmp.w	#'u',d5
		bne.b	.nixuse
		moveq	#GD_ren_use,d0
		lea	ren_use(pc),a3
		bra.w	setandjump
.nixuse:
		cmp.w	#'r',d5
		bne.b	.nixrender
		moveq	#GD_ren_render,d0
		lea	ren_render(pc),a3
		bra.w	setandjump
.nixrender:
		cmp.w	#'c',d5
		bne.w	ren_wait
		moveq	#GD_ren_cancel,d0
		lea	ren_cancel(pc),a3
		bra.w	setandjump
		bra.w	ren_wait

ren_cancel:
		move.l	ren_colorlevelbak(a5),ren_colorlevel(a5)
		move.l	ren_colormodebak(a5),ren_colormode(a5)
		move.l	ren_palmodetabbak(a5),ren_palmodetag
		move.l	ren_colvisbak(a5),ren_colvis
		move.l	ren_paltextbak(a5),ren_paltext
		move.l	ren_dithertagbak(a5),ren_dithertag
		move.l	ren_dithermodebak(a5),ren_dithermode(a5)
		move.l	ren_palsortmodebak(a5),ren_palsortmode(a5)
		move.l	ren_palsorttagbak(a5),ren_palsorttag
		move.l	ren_palordermodebak(a5),ren_palordermode(a5)
		move.l	ren_palodertagbak(a5),ren_palodertag
		move.l	ren_custtagbak(a5),ren_custtag
		move.l	ren_custbak(a5),ren_cust(a5)
		move.l	ren_ucolvisbak(a5),ren_ucolvis
		move.l	ren_usedcolorsbak(a5),ren_usedcolors(a5)
		move.l	ren_firstvisbak(a5),ren_firstvis
		move.l	ren_firstcolorsbak(a5),ren_firstcolors(a5)
		move.l	ren_ucolmaxbak(a5),ren_ucolmax
		move.l	ren_ucolnumbak(a5),ren_ucolnum
		move.l	ren_fnumbak(a5),ren_fnum
		move.l	ren_damountbak(a5),ren_damount(a5)
		move.l	ren_damountbak(a5),ren_damslide
		move.l	ren_damountbak(a5),ren_amountnum

ren_wech:
		move.l	MainwinWnd(a5),a0
		bsr.l	clearwaitpointer

		move.l	ren_window(pc),a0
		move.l	APG_Intuitionbase(a5),a6
		jsr	_LVOCloseWindow(a6)

		cmp.l	#'REND',d7
		beq.w	viewpic


		bra.w	waitaction

ren_use:
		st	depthchange(a5)

		lea	ren_palmodetag(pc),a0
		tst.l	(a0)
		bne.b	.nixpalette	; Ham oder EHB
		move.l	ren_paltext(pc),a0
		move.l	a0,TAG_depthcolor
.set		
		lea	ren_texttag(pc),a3
		move.l	a0,4(a3)
		move.l	#GD_gdepth,d0
		lea	mainwingadgets,a0
		move.l	(a0,d0.l*4),a0
		move.l	mainwinWnd(a5),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
		bra.b	ren_wech
.nixpalette:
		cmp.w	#'HB',anzcolor(a5)
		bne.b	.nhb
		lea	de8(pc),a0
.nhb:		cmp.w	#'M6',anzcolor(a5)
		bne.b	.nh6
		lea	de9(pc),a0
.nh6:		cmp.w	#'M8',anzcolor(a5)
		bne.b	.set
		lea	de10(pc),a0
		bra.b	.set

ren_render:
		move.l	#'REND',d7
		bra.b	ren_use

;-----------------------------------------------------------------------
ren_palmode:
		ext.l	d5
		lea	ren_palmodetag(pc),a0
		move.l	d5,(a0)
		move.l	d5,ren_colormode(a5)
		
		moveq	#0,d6
		tst.w	d5
		bne.b	.w
		move.l	ren_colorlevel(a5),d0
		move.w	d0,anzcolor(a5)
.w:		cmp.w	#1,d5
		bne.b	.wnh8
		move.w	#'M8',anzcolor(a5)
		moveq	#1,d6
		move.l	#64,ren_colorlevel(a5)
		moveq	#5,d4
.wnh8:		cmp.w	#2,d5
		bne.b	.wnh6
		move.w	#'M6',anzcolor(a5)
		moveq	#1,d6
		move.l	#16,ren_colorlevel(a5)
		moveq	#3,d4
.wnh6		cmp.w	#3,d5
		bne.b	.palweiter
		move.w	#'HB',anzcolor(a5)
		moveq	#1,d6
		move.l	#32,ren_colorlevel(a5)
		moveq	#4,d4
.palweiter
		move.w	anzcolor(a5),anzcolorbak(a5)

		move.l	#GD_ren_colorsslider,d0
		move.l	d6,d1
		bsr.w	ren_ghost

		move.l	#'NOWA',d7
		tst.l	d5		;Palette
		beq.w	ren_korrslider
		move.l	d4,d5

		lea	ren_leveltag(pc),a3
		move.l	d5,4(a3)
		lea	ren_colvis(pc),a1
		move.l	d5,(a1)
		move.l	#GD_ren_colorsslider,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		bra.b	ren_korrcolors

ren_maxtag:
		dc.l	GTSL_Max,0
		dc.l	TAG_DONE

;---------------- Es würde über eine Taste angewählt ---------------
ren_tastmode:
		move.l	ren_palmodetag(pc),d5
		addq.l	#1,d5
		cmp.l	#4,d5
		blo.b	.kl
		moveq	#0,d5
.kl:
		moveq	#GD_ren_palmode,d0
		move.l	d5,d1
		lea	ren_gadarray(pc),a0
		move.l	ren_window(pc),a1
		bsr.l	setcyle	

		bra.w	ren_palmode
		
;---------------------------------------------------------------------------
ren_colors:
		moveq	#0,d7
		ext.l	d5
		lea	ren_colvis(pc),a0
		move.l	d5,(a0)
		moveq	#2,d0
		lsl.l	d5,d0
		move.l	d0,ren_colorlevel(a5)
		move.w	d0,anzcolor(a5)
		move.w	d0,anzcolorbak(a5)
ren_korrcolors:
		lea	ren_coltab(pc),a0
		move.l	(a0,d5.l*4),a0

		lea	ren_texttag(pc),a3
		move.l	a0,4(a3)
		lea	ren_paltext(pc),a1
		move.l	a0,(a1)
		move.l	#GD_ten_textcolors,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)


;Korregiere Used Color slider
ren_korrslider:

		lea	ren_maxtag(pc),a3
		move.l	ren_colorlevel(a5),d0
		move.l	d0,4(a3)
		cmp.l	ren_usedcolors(a5),d0
		bhs.b	.w
		move.l	d0,ren_usedcolors(a5)
		move.l	d0,ren_ucolnum
.w
		lea	ren_ucolmax(pc),a0
		move.l	ren_colorlevel(a5),(a0)
		
		move.l	#GD_ren_usedcolorslide,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)


		move.l	ren_usedcolors(a5),d0
		lea	ren_ucolvis(pc),a0
		move.l	d0,(a0)
		lea	ren_numtag(pc),a3
		move.l	d0,4(a3)
		move.l	#GD_ren_usedcolors,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)


;Korregiere First Color slider

		move.l	ren_colorlevel(a5),d0
		sub.l	ren_usedcolors(a5),d0

		lea	ren_maxtag(pc),a3
		move.l	d0,4(a3)
		lea	ren_fcolmax(pc),a0
		move.l	d0,(a0)
		move.l	#GD_ren_firstcolorslide,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		move.l	ren_colorlevel(a5),d0
		sub.l	ren_usedcolors(a5),d0
		cmp.l	ren_firstcolors(a5),d0
		bhs.b	.wf
		move.l	d0,ren_firstcolors(a5)
		lea	ren_fnum(pc),a0
		move.l	d0,(a0)
.wf:
		lea	ren_numtag(pc),a3
		move.l	ren_firstcolors(a5),4(a3)
		move.l	#GD_ren_firstcolor,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		cmp.l	#'NOWA',d7
		beq.w	ren_wait	;wir wurden vom PalMode aufgerufen

ren_sliderwait:
		move.l	ren_window(pc),a0
		bsr.w	wait

		cmp.l	#GADGETUP,d4
		beq.w	ren_wait	;Slidergadet wurde losgelassen

		cmp.l	#IDCMP_MOUSEMOVE,d4
		beq.b	ren_slider
		bra.b	ren_sliderwait

ren_slider:
		move.w	38(a4),d0
		cmp.w	#GD_ren_colorsslider,d0
		beq.w	ren_colors
		cmp.w	#GD_ren_usedcolorslide,d0
		beq.b	ren_usedcol
		cmp.w	#GD_ren_firstcolorslide,d0
		beq.w	ren_firstcol
		cmp.w	#GD_ren_amountslide,d0
		beq	ren_ditheramountslide
		bra.w	ren_wait


ren_coltab:	dc.l	.0,.1,.2,.3,.4,.5,.6,.7

.0		dc.b	'2',0
.1		dc.b	'4',0
.2		dc.b	'8',0
.3		dc.b	'16',0
.4		dc.b	'32',0
.5		dc.b	'64',0
.6		dc.b	'128',0
.7		dc.b	'256',0

	even
	
ren_texttag:	dc.l	GTTX_Text
		dc.l	0
		dc.l	TAG_DONE
		
;---------------------------------------------------------------------------
ren_usedcol:
		ext.l	d5
		lea	ren_ucolvis(pc),a0
		move.l	d5,(a0)
		move.l	d5,ren_usedcolors(a5)

		lea	ren_numtag(pc),a3
		move.l	d5,4(a3)
		lea	ren_ucolnum(pc),a0
		move.l	d5,(a0)

		move.l	#GD_ren_usedcolors,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		move.l	ren_colorlevel(a5),d0
		sub.l	ren_usedcolors(a5),d0

		lea	ren_maxtag(pc),a3
		move.l	d0,4(a3)
		lea	ren_fcolmax(pc),a0
		move.l	d0,(a0)
		move.l	#GD_ren_firstcolorslide,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
		
		move.l	ren_colorlevel(a5),d0
		sub.l	ren_usedcolors(a5),d0
		cmp.l	ren_firstcolors(a5),d0
		bhs.b	.wf
		move.l	d0,ren_firstcolors(a5)
.wf:
		lea	ren_numtag(pc),a3
		move.l	ren_firstcolors(a5),4(a3)
		move.l	#GD_ren_firstcolor,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
		bra.w	ren_sliderwait
		
ren_numtag:
		dc.l	GTIN_Number,0
		dc.l	TAG_DONE

;---------------------------------------------------------------------------
ren_usednum:
		lea	ren_numtag1(pc),a3
		move.l	#GD_ren_usedcolors,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_GetGadgetAttrsA(a6)

		move.l	ren_number(pc),d5
		move.l	ren_ucolmax(pc),d4
		cmp.l	d5,d4
		bhs.b	.w
		move.l	d4,d5		;eingetragener wert war zu hoch

		lea	ren_numtag(pc),a3
		move.l	d5,4(a3)
		move.l	#GD_ren_usedcolors,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
.w
		lea	ren_ucolnum(pc),a0
		move.l	d5,(a0)

		move.l	d5,ren_usedcolors(a5)
		lea	ren_ucolvis(pc),a0
		move.l	d5,(a0)
		lea	ren_leveltag(pc),a3
		move.l	d5,4(a3)
		move.l	#GD_ren_usedcolorslide,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		bra.w	ren_wait
ren_numtag1:
		dc.l	GTIN_Number,ren_number
		dc.l	TAG_DONE

ren_number:	dc.l	0

ren_leveltag:
		dc.l	GTSL_Level,0
		dc.l	TAG_DONE

ren_tastused:
		tst.l	ren_cust(a5)
		beq.w	ren_wait
		lea	ren_gadarray(pc),a0
		move.l	GD_ren_usedcolors*4(a0),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	intbase(a5),a6
		jsr	_LVOActivateGadget(a6)		

		bra.w	ren_wait


;---------------------------------------------------------------------------
ren_firstnum:
		lea	ren_numtag1(pc),a3
		move.l	#GD_ren_firstcolor,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_GetGadgetAttrsA(a6)

		move.l	ren_number(pc),d5
		move.l	ren_fcolmax(pc),d4
		cmp.l	d5,d4
		bhs.b	.w
		move.l	d4,d5		;eingetragener wert war zu hoch

		lea	ren_numtag(pc),a3
		move.l	d5,4(a3)
		move.l	#GD_ren_firstcolor,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
.w
		lea	ren_fnum(pc),a0
		move.l	d5,(a0)

		move.l	d5,ren_firstcolors(a5)
		lea	ren_firstvis(pc),a0
		move.l	d5,(a0)
		lea	ren_leveltag(pc),a3
		move.l	d5,4(a3)
		move.l	#GD_ren_firstcolorslide,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		bra.w	ren_wait

ren_tastfirst:
		tst.l	ren_cust(a5)
		beq.w	ren_wait
		lea	ren_gadarray(pc),a0
		move.l	GD_ren_firstcolor*4(a0),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	intbase(a5),a6
		jsr	_LVOActivateGadget(a6)		

		bra.w	ren_wait

;---------------------------------------------------------------------------
ren_firstcol:
		ext.l	d5
		lea	ren_firstvis(pc),a0
		move.l	d5,(a0)
		move.l	d5,ren_firstcolors(a5)

		lea	ren_fnum(pc),a0
		move.l	d5,(a0)

		lea	ren_numtag(pc),a3
		move.l	d5,4(a3)
		move.l	#GD_ren_firstcolor,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		bra.w	ren_sliderwait
		
;---------------------------------------------------------------------------
ren_dither:
		ext.l	d5
		lea	ren_dithertag(pc),a0
		move.l	d5,(a0)
		lea	ren_dithertab(pc),a0
		move.l	(a0,d5*4),ren_dithermode(a5)

		moveq	#1,d6
		move.l	#GD_ren_amountslide,d0
		cmp.l	#DITHERMODE_RANDOM,ren_dithermode(a5)
		bne	.w
		moveq	#0,d6
.w
		move.l	d6,d1
		bsr.w	ren_ghost

		move.l	#GD_ren_amount,d0
		move.l	d6,d1
		bsr	ren_ghost
		
		bra.w	ren_wait

ren_tastdither:
		move.l	ren_dithertag(pc),d5
		addq.l	#1,d5
		cmp.l	#4,d5
		blo.b	.kl
		moveq	#0,d5
.kl:
		moveq	#GD_ren_dither,d0
		move.l	d5,d1
		lea	ren_gadarray(pc),a0
		move.l	ren_window(pc),a1
		bsr.l	setcyle
		bra.b	ren_dither

ren_dithertab:
		dc.l	DITHERMODE_NONE
		dc.l	DITHERMODE_FS
		dc.l	DITHERMODE_RANDOM
		dc.l	DITHERMODE_EDD
		
;---------------------------------------------------------------------------
ren_ditheramountslide:
		ext.l	d5
		move.l	d5,ren_damount(a5)
		move.l	d5,ren_damslide
		move.l	d5,ren_amountnum

		lea	ren_numtag(pc),a3
		move.l	ren_damount(a5),4(a3)
		move.l	#GD_ren_amount,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		bra	ren_sliderwait
;---------------------------------------------------------------------------
ren_dithernum:
		lea	ren_numtag1(pc),a3
		move.l	#GD_ren_amount,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_GetGadgetAttrsA(a6)

		move.l	ren_number(pc),d5
		cmp.l	#255,d5
		bls.b	.w		;eingetragener wert war zu hoch
		move.l	#255,d5

		lea	ren_numtag(pc),a3
		move.l	d5,4(a3)
		move.l	#GD_ren_amount,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
.w

		move.l	d5,ren_damount(a5)
		move.l	d5,ren_damslide
		move.l	d5,ren_amountnum

;setze slider
		lea	ren_leveltag(pc),a3
		move.l	d5,4(a3)
		move.l	#GD_ren_amountslide,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		bra	ren_wait

;---------------------------------------------------------------------------
ren_dithertast:		
		cmp.l	#DITHERMODE_RANDOM,ren_dithermode(a5)
		bne	ren_wait

		lea	ren_gadarray(pc),a0
		move.l	GD_ren_amount*4(a0),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	intbase(a5),a6
		jsr	_LVOActivateGadget(a6)		

		bra	ren_wait

;---------------------------------------------------------------------------
ren_palsort:
		ext.l	d5
		lea	ren_palsorttag(pc),a0
		move.l	d5,(a0)
		lea	ren_sorttab(pc),a0
		move.l	(a0,d5.l*4),ren_palsortmode(a5)
		bra.w	ren_wait

ren_sorttab:
.0		dc.l	PALMODE_NONE
.1		dc.l	PALMODE_BRIGHTNESS
.2		dc.l	PALMODE_SATURATION
.3		dc.l	PALMODE_POPULARITY
.4		dc.l	PALMODE_SIGNIFICANCE
.5		dc.l	PALMODE_REPRESENTATION

ren_tastsort:
		move.l	ren_palsorttag(pc),d5
		addq.l	#1,d5
		cmp.l	#6,d5
		blo.b	.kl
		moveq	#0,d5
.kl:
		moveq	#GD_ren_sortmode,d0
		move.l	d5,d1
		lea	ren_gadarray(pc),a0
		move.l	ren_window(pc),a1
		bsr.l	setcyle	
		bra.b	ren_palsort

;---------------------------------------------------------------------------
ren_palorder:
		ext.l	d5
		lea	ren_palodertag(pc),a0
		move.l	d5,(a0)
		moveq	#0,d0
		tst.l	d5
		beq.b	.w
		moveq	#PALMODE_ASCENDING,d0
.w		move.l	d0,ren_palordermode(a5)	
		bra.w	ren_wait

ren_tastorder:
		move.l	ren_palodertag(pc),d5
		addq.l	#1,d5
		cmp.l	#2,d5
		blo.b	.kl
		moveq	#0,d5
.kl:
		moveq	#GD_ren_sortorder,d0
		move.l	d5,d1
		lea	ren_gadarray(pc),a0
		move.l	ren_window(pc),a1
		bsr.l	setcyle	
		bra.b	ren_palorder

;---------------------------------------------------------------------------
ren_custom:
		moveq	#GD_ren_custom,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		moveq	#1,d6
		moveq	#0,d5
		move.w	gg_Flags(a0),d0
		and.w	#SELECTED,d0
		beq.b	.w	;nicht selected
		moveq	#0,d6
		moveq	#1,d5
.w
ren_custcheck
		bsr.b	ren_checkghost

		lea	ren_custtag(pc),a0
		move.l	d5,(a0)
		move.l	d5,ren_cust(a5)

		bra.w	ren_wait
ren_tastcust:
		moveq	#0,d6
		moveq	#1,d5
		move.l	ren_custtag(pc),d0
		beq.b	.nixselect
		moveq	#1,d6
		moveq	#0,d5
.nixselect:
		lea	.custtag(pc),a3
		move.l	d5,4(a3)
		moveq	#GD_ren_custom,d0
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
		bra.b	ren_custcheck

.custtag:
		dc.l	GTCB_Checked,0,TAG_DONE

;--------------------------------------------------------------------------
ren_checkghost:
		moveq	#GD_ren_usedcolorslide,d0
		move.l	d6,d1
		bsr.b	ren_ghost
		moveq	#GD_ren_firstcolorslide,d0
		move.l	d6,d1
		bsr.b	ren_ghost
		moveq	#GD_ren_usedcolors,d0
		move.l	d6,d1
		bsr.b	ren_ghost
		moveq	#GD_ren_firstcolor,d0
		move.l	d6,d1
		bra.w	ren_ghost


;---------------------------------------------------------------------------
ren_ghost:
		lea	doghost(pc),a0
		move.l	d1,(a0)
		lea	ren_gadarray(pc),a0
		move.l	(a0,d0.l*4),a0
		move.l	ren_window(pc),a1
		sub.l	a2,a2
		lea	ghosttag(pc),a3
		move.l	gadbase(a5),a6
		jmp	_LVOGT_SetGadgetAttrsA(a6)

;----------------------------------------------------------------------------

GD_ren_palmode		EQU	0
GD_ren_colorsslider	EQU	1
GD_ten_textcolors	EQU	2
GD_ren_usedcolorslide	EQU	3
GD_ren_firstcolorslide	EQU	4
GD_ren_sortmode		EQU	5
GD_ren_sortorder	EQU	6
GD_ren_custom		EQU	7
GD_ren_dither		EQU	8
GD_ren_amountslide	EQU	9
GD_ren_amount		EQU	10
GD_ren_use		EQU	11
GD_ren_cancel		EQU	12
GD_ren_render		EQU	13
GD_ren_usedcolors	EQU	14
GD_ren_firstcolor	EQU	15

ren_gadanz	=	16

ren_window:	dc.l	0
ren_Glist:	dc.l	0
ren_gadarray:	ds.l	16*4


ren_GTypes:
		dc.w	CYCLE_KIND
		dc.w	SLIDER_KIND
		dc.w	TEXT_KIND
		dc.w	SLIDER_KIND
		dc.w	SLIDER_KIND
		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND
		dc.w	CHECKBOX_KIND
		dc.w	CYCLE_KIND
		dc.w	SLIDER_KIND
		dc.w	INTEGER_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	INTEGER_KIND
		dc.w	INTEGER_KIND

ren_NGads:
		dc.w	102,7,197,13
		dc.l	ren_palmodeText,0
		dc.w	GD_ren_palmode
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	102,22,159,13
		dc.l	ren_colorssliderText,0
		dc.w	GD_ren_colorsslider
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	264,22,35,13
		dc.l	0,0
		dc.w	GD_ten_textcolors
		dc.l	0,0,0
		dc.w	150,58+2,149,13
		dc.l	0,0
		dc.w	GD_ren_usedcolorslide
		dc.l	0,0,0
		dc.w	150,73+2,149,13
		dc.l	0,0
		dc.w	GD_ren_firstcolorslide
		dc.l	0,0,0
		dc.w	102,88+2,197,13
		dc.l	ren_sortmodeText,0
		dc.w	GD_ren_sortmode
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	102,103+2,197,13
		dc.l	ren_sortorderText,0
		dc.w	GD_ren_sortorder
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	25,43+2,26,11
		dc.l	ren_customText,0
		dc.w	GD_ren_custom
		dc.l	PLACETEXT_RIGHT,0,0
		dc.w	102,128,197,13
		dc.l	ren_ditherText,0
		dc.w	GD_ren_dither
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	150,144,149,13
		dc.l	0,0
		dc.w	GD_ren_amountslide
		dc.l	0,0,0
		dc.w	102,144,45,13
		dc.l	ren_amountText,0
		dc.w	GD_ren_amount
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	3,167,90,15
		dc.l	ren_useText,0
		dc.w	GD_ren_use
		dc.l	PLACETEXT_IN,0,0
		dc.w	213,167,90,15
		dc.l	ren_cancelText,0
		dc.w	GD_ren_cancel
		dc.l	PLACETEXT_IN,0,0
		dc.w	108,167,90,15
		dc.l	ren_renderText,0
		dc.w	GD_ren_render
		dc.l	PLACETEXT_IN,0,0
		dc.w	102,58+2,45,13
		dc.l	ren_usedcolorsText,0
		dc.w	GD_ren_usedcolors
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	102,73+2,45,13
		dc.l	ren_firstcolorText,0
		dc.w	GD_ren_firstcolor
		dc.l	PLACETEXT_LEFT,0,0


ren_GTags:
		dc.l	GTCY_Labels,ren_palmodeLabels
		dc.l	GT_Underscore,'_'
		dc.l	GTCY_ACTIVE
ren_palmodetag:	dc.l	0
		dc.l	TAG_DONE
		dc.l	PGA_Freedom,LORIENT_HORIZ
		dc.l	GA_RelVerify,1
		dc.l	GA_Immediate,1
		dc.l	GTSL_min,0
		dc.l	GTSL_Max,7
		dc.l	GTSL_Level
ren_colvis:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTTX_Text
ren_paltext:	dc.l	de0
		dc.l	GTTX_Border,1
		dc.l	TAG_DONE
		dc.l	GTSL_min,2
		dc.l	GTSL_Max
ren_ucolmax:	dc.l	2
		dc.l	GTSL_Level
ren_ucolvis:	dc.l	2
		dc.l	PGA_Freedom,LORIENT_HORIZ
		dc.l	GA_RelVerify,1
		dc.l	GA_Immediate,1
		dc.l	TAG_DONE
		dc.l	GTSL_min,0
		dc.l	GTSL_Max
ren_fcolmax:	dc.l	0
		dc.l	GTSL_Level
ren_firstvis:	dc.l	0
		dc.l	GA_Immediate,1
		dc.l	PGA_Freedom,LORIENT_HORIZ
		dc.l	GA_RelVerify,1
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,ren_sortmodeLabels
		dc.l	GT_Underscore,'_'
		dc.l	GTCY_ACTIVE
ren_palsorttag:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,ren_sortorderLabels
		dc.l	GT_Underscore,'_'
		dc.l	GTCY_ACTIVE
ren_palodertag:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	GTCB_Checked
ren_custtag:	dc.l	0
		dc.l	GTCB_Scaled,1
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,ren_ditherLabels
		dc.l	GT_Underscore,'_'
		dc.l	GTCY_ACTIVE
ren_dithertag:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GA_Immediate,1
		dc.l	GTSL_Max,255
		dc.l	GTSL_Level
ren_damslide:	dc.l	45
		dc.l	GTSL_LevelPlace,PLACETEXT_RIGHT
		dc.l	PGA_Freedom,LORIENT_HORIZ
		dc.l	GA_RelVerify,1
		dc.l	GA_Disabled,1
		dc.l	TAG_DONE
		dc.l	GTIN_Number
ren_amountnum:	dc.l	45
		dc.l	GTIN_MaxChars,3
		dc.l	GT_Underscore,'_'
		dc.l	GA_Disabled,1
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GTIN_Number
ren_ucolnum:	dc.l	2
		dc.l	GTIN_MaxChars,3
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GTIN_Number
ren_fnum:	dc.l	0
		dc.l	GTIN_MaxChars,3
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE

ren_colorssliderFormat:	dc.b	'%ld',0
    CNOP     0,2

ren_palmodeText:	dc.b	'_Mode',0
ren_colorssliderText:	dc.b	'Colors',0
ren_sortmodeText:	dc.b	'_Sort Mode',0
ren_sortorderText:	dc.b	'Sort _Order',0
ren_customText:		dc.b	'Cus_tom Palette',0
ren_ditherText:		dc.b	'_Dither',0
ren_amountText:		dc.b	'_Amount',0
ren_useText:		dc.b	'_Use',0
ren_cancelText:		dc.b	'_Cancel',0
ren_renderText:		dc.b	'_Render',0
ren_usedcolorsText:	dc.b	'Colors Us_ed',0
ren_firstcolorText:	dc.b	'_First Color',0

	even

ren_palmodeLabels:
			dc.l	ren_palmodeLab0
			dc.l	ren_palmodeLab1
			dc.l	ren_palmodeLab2
			dc.l	ren_palmodeLab3
			dc.l	0

ren_sortmodeLabels:
			dc.l	ren_sortmodeLab0
			dc.l	ren_sortmodeLab1
			dc.l	ren_sortmodeLab2
			dc.l	ren_sortmodeLab3
			dc.l	ren_sortmodeLab4
			dc.l	ren_sortmodeLab5
			dc.l	0

ren_sortorderLabels:
			dc.l	ren_sortorderLab0
			dc.l	ren_sortorderLab1
			dc.l	0

ren_ditherLabels:
			dc.l	ren_ditherLab0
			dc.l	ren_ditherLab1
			dc.l	ren_ditherLab2
			dc.l	ren_ditherLab3
			dc.l	0

ren_palmodeLab0:	dc.b	'Palette',0
ren_palmodeLab1:	dc.b	'HAM8',0
ren_palmodeLab2:	dc.b	'HAM6',0
ren_palmodeLab3:	dc.b	'EHB Palette',0

    CNOP    0,2

ren_sortmodeLab0:	dc.b	'None',0
ren_sortmodeLab1:	dc.b	'Brightness',0
ren_sortmodeLab2:	dc.b	'Saturation',0
ren_sortmodeLab3:	dc.b	'Popularity',0
ren_sortmodeLab4:	dc.b	'Significance',0
ren_sortmodeLab5:	dc.b	'Representation',0

    CNOP    0,2

ren_sortorderLab0:	dc.b	'High to Low',0
ren_sortorderLab1:	dc.b	'Low to High',0

    CNOP    0,2

ren_ditherLab0:		dc.b	'None',0
ren_ditherLab1:		dc.b	'Floyd-Steinberg',0
ren_ditherLab2:		dc.b	'Random',0
ren_ditherLab3:		dc.b	'EDD-Dither',0

		even

ren_WindowTags:
ren_WinL:	dc.l	WA_Left,0
ren_WinT:	dc.l	WA_Top,0
ren_WinW:	dc.l	WA_Width,0
ren_WinH:	dc.l	WA_Height,0
		dc.l	WA_IDCMP,VANILLAKEY!CYCLEIDCMP!SLIDERIDCMP!TEXTIDCMP!CHECKBOXIDCMP!STRINGIDCMP!BUTTONIDCMP!INTEGERIDCMP!IDCMP_INTUITICKS!IDCMP_MOUSEBUTTONS!IDCMP_CLOSEWINDOW!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_DRAGBAR!WFLG_DEPTHGADGET!WFLG_CLOSEGADGET!WFLG_SIZEBBOTTOM!WFLG_SMART_REFRESH
ren_WinWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title,ren_WTitle
ren_WinSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE
ren_WTitle:
		dc.b	'Render Control',0
    CNOP    0,2

;--------------------------------------------------------------------------
;-------- Open Process ----------------------------------------------------
;--------------------------------------------------------------------------
; Öffne Processwindow

openprocess:
		tst.l	ProcessWnd(a5)
		beq.b	.w
		rts

.w		movem.l	d0-a6,-(a7)

		lea	ProcessWindowTags(pc),a0
		move.l	a0,windowtaglist(a5)
		lea	ProcesswinWG+4(pc),a0
		move.l	a0,gadgets(a5)
		lea	ProcesswinSC+4(pc),a0
		move.l	a0,winscreen(a5)
		lea	ProcessWnd(a5),a0
		move.l	a0,window(a5)
		lea	ProcessGlist(a5),a0
		move.l	a0,Glist(a5)
		lea	ProcessNgads(pc),a0
		move.l	a0,NGads(a5)
		lea	ProcessGTypes(pc),a0
		move.l	a0,GTypes(a5)
		lea	ProcessGadgets(pc),a0
		move.l	a0,WinGadgets(a5)
		move.w	#Process_CNT,win_CNT(a5)
		lea	ProcessGtags(pc),a0
		move.l	a0,windowtags(a5)
		move.l	scr(a5),screenbase(a5)

		move.w	#300,WinWidth(a5)
		move.w	#35+13,WinHeight(a5)
		lea	ProcessWinL(pc),a0
		move.l	a0,WinL(a5)
		lea	ProcessWinT(pc),a0
		move.l	a0,WinT(a5)
		lea	ProcessWinW(pc),a0
		move.l	a0,WinW(a5)
		lea	ProcessWinH(pc),a0
		move.l	a0,WinH(a5)

		move.l	mainwinWnd(a5),a0

		move.l	#300,d0
		bsr.l	computex
				
		move.w	wd_width(a0),d1		;screenbreite
		sub.w	d0,d1
		lsr.w	#1,d1
		add.w	wd_LeftEdge(a0),d1
		move.w	d1,WinLeft(a5)

		move.l	#30,d0
		bsr.l	computey

		move.w	wd_height(a0),d1
		lsr.w	#1,d1
		sub.w	d0,d1
		lsr.w	#1,d1
		add.w	wd_TopEdge(a0),d1
		move.w	d1,WinTop(a5)

		jsr	openwindowF	;öffne Mainwindow
		tst.l	d0
		beq.b	pc_winok
		movem.l	(a7)+,d0-a6
		moveq	#-1,d0
		rts

pc_winok:
		move.l	ProcessWnd(a5),a0
		move.l  wd_RPort(a0),a0
		move.l	a0,processrastport(a5)
		move.l  VisualInfo(a5),IR+4
		lea	IR,a1

		move.l  #3+13,d0
		bsr.l	ComputeY
		add.w   OffY(a5),d0
		move.l	d0,d1
		move.l	d1,pc_top(a5)
		add.l	#1,pc_top(a5)
		move.l  #280,d0
		bsr.l	ComputeX
		move.l	d0,d2
		move.l	d2,pc_width(a5)
		sub.l	#5,pc_width(a5)
		move.l  #15,d0
		bsr.l	ComputeY
		move.l	d0,d3
		move.l	d3,pc_height(a5)
		sub.l	#3,pc_height(a5)
		move.l	pc_top(a5),d4
		add.l	d4,pc_height(a5)
		move.l  #10,d0
		bsr.l	ComputeX
		add.w	OffX(a5),d0
		move.l	d0,pc_left(a5)
		add.l	#2,pc_left(a5)
		move.l	gadbase(a5),a6
		jsr	_LVODrawBevelBoxA(a6)

		movem.l	(a7)+,d0-a6
		moveq	#0,d0
		rts
		
;--------------------------------------------------------------------------
;-------- Init Process ----------------------------------------------------
;--------------------------------------------------------------------------
; Init den Process requester
;
;
; > d0	anzahl steps
;   d1  ghost Stopgadget, 'stop' disabled gadget
;   a1  titel string

initprocess:
		ext.l	d0
		
		tst.l	ProcessWnd(a5)
		bne.b	.dp
		rts
.dp
		movem.l	d0-a6,-(a7)
		move.l	d1,d5
		tst.l	d0
		bne.b	.w
		moveq	#1,d0
.w		move.l	d0,pc_step(a5)
		clr.l	pc_stepcounter(a5)

		lea	rndr_IText(pc),a0
		move.l	a1,it_Itext(a0)
		move.l	Font(a5),it_ITextFont(a0)
		move.l	intbase(a5),a6
		jsr	_LVOIntuiTextLength(a6)
		move.l	d0,-(a7)		;länge des Textes in Pixel

		move.l	processrastport(a5),a1
		moveq	#0,d0
		move.l	gfxbase(a5),a6
		jsr	_LVOSetAPen(a6)

;lösche alten Balken

		move.l	pc_left(a5),d0
		move.l	pc_top(a5),d1

		move.l	pc_left(a5),d2
		add.l	pc_width(a5),d2
		move.l	pc_height(a5),d3

		move.l	processrastport(a5),a1
		move.l	gfxbase(a5),a6
		jsr	_LVORectFill(a6)

;lösche alten Text

		move.l	processrastport(a5),a1
		move.l	rp_font(a1),a0
		move.w	tf_YSize(a0),d3
	;	addq.w	#3,d3
		moveq	#3,d0
		bsr.l	computey
		add.w   OffY(a5),d0
		move.l	d0,d1
		add.l	d1,d3
		move.l	#300,d0
		bsr.l	computex
		subq.l	#5,d0
		move.l	d0,d2
		moveq	#5,d0
		move.l	gfxbase(a5),a6
		jsr	_LVORectFill(a6)

		move.l	processrastport(a5),a1
		moveq	#3,d0
		move.l	gfxbase(a5),a6
		jsr	_LVOSetAPen(a6)

		lea	rndr_IText(pc),a1

		moveq	#3,d0
		bsr.l	computey
		add.w   OffY(a5),d0
		move.w	d0,it_TopEdge(a1)
		
		move.l	#300,d0
		bsr.l	computex
		move.l	(a7)+,d1
		sub.l	d1,d0
		lsr.l	#1,d0		;left offset
		move.w	d0,it_LeftEdge(a1)

		moveq	#0,d0
		moveq	#0,d1
		move.l	processrastport(a5),a0
		move.l	intbase(a5),a6
		jsr	_LVOPrintIText(a6)		
		

		cmp.l	#'STOP',d5
		bne.b	.nixghost

		lea	doghost(pc),a0
		move.l	#1,(a0)
		move.l	ProcessGlist(a5),a0
		move.l	(a0),a0
		move.l	ProcessWnd(a5),a1
		sub.l	a2,a2
		lea	ghosttag(pc),a3
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

.nixghost:
		movem.l	(a7)+,d0-a6
		rts

rndr_IText:
		dc.b	1,0
		dc.b	RP_JAM2
		dc.b	0
		dc.w	0,0
		dc.l	0
		dc.l	0
		dc.l	0

;-----------------------------------------------------------------
clearprocess:
		lea	ProcessWnd(a5),a0
		tst.l	(a0)
		beq.b	.wech
		move.l	a0,window(a5)
		lea	ProcessGlist(a5),a0
		move.l	a0,Glist(a5)
		jsr	gt_CloseWindow
		clr.l	ProcessWnd(a5)
.wech:	rts
		
;-------------------------------------------------------------------
;do process
;
doprocess:
		movem.l	d0-a6,-(a7)

		lea	daten,a5
		
		addq.l	#1,pc_stepcounter(a5)

		move.l	pc_stepcounter(a5),d0
		mulu.l	#100,d0
		move.l	pc_step(a5),d1
		divu.l	d1,d0

doprocess_go:
		move.l	pc_width(a5),d1
		mulu.l	d1,d0
		divu.l	#100,d0
		move.l	d0,-(a7)

;bereite Polygon vor		

		move.l	pc_left(a5),d0
		move.l	pc_top(a5),d1

		move.l	pc_left(a5),d2
		add.l	(a7)+,d2
		move.l	pc_height(a5),d3

		move.l	processrastport(a5),a1
		move.l	gfxbase(a5),a6
		jsr	_LVORectFill(a6)

		move.l	processWnd(a5),a0
		move.l	wd_Userport(a0),a0	;Zeige auf MsgPort
		move.l	gadbase(a5),a6
		jsr	_LVOGT_GetImsg(a6)
		tst.l	d0
		beq.b	.nomsg

		move.l	d0,a1			;muss nach a1
		move.l	im_Class(a1),d4		;Msg-Type
		move.l	im_IAddress(a1),a4	;Adr. für Gadgets
		jsr	_LVOGT_replyiMsg(a6)	;quittiere Msg in a1

		cmp.l	#GADGETUP,d4
		bne.b	.nomsg
			
		move.l	38(a4),d0
		tst.l	d0
		bne.b	.nomsg

		movem.l	(a7)+,d0-a6
		moveq	#0,d0
		rts

.nomsg:
		movem.l	(a7)+,d0-a6
		moveq	#-1,d0
		rts

doprocess_hook:

		movem.l	d0-a6,-(a7)
		lea	daten,a5

		tst.l	ProcessWnd(a5)
		beq.b	.nixprocess

		move.l	RND_PMsg_count(a1),d0
		move.l	RND_PMsg_total(a1),d1
		
		mulu.l	#100,d0
		divu.l	d1,d0
		bra.w	doprocess_go

.nixprocess:
		movem.l	(a7)+,d0-a6
		moveq	#-1,d0
		rts


doprocess_hookstruck:
		dcb.b	MLN_SIZE
		dc.l	doprocess_hook
		dc.l	doprocess_hook
		dc.l	0


ProcessWindowTags:

processwinL:	dc.l	WA_Left,0
processwinT:	dc.l	WA_Top,0
processwinW:	dc.l	WA_Width,0
processwinH:	dc.l	WA_Height,0
		dc.l	WA_IDCMP,IDCMP_VANILLAKEY!BUTTONIDCMP!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_DRAGBAR!WFLG_ACTIVATE!WFLG_SMART_REFRESH
processwinWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title,processtitel
processwinSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

ProcessGTypes:
		dc.w	BUTTON_KIND

ProcessNgads:
		dc.w	100,21+13,100,12
		dc.l	pc_stoptext,0
		dc.w	0		;nur ein Gadget
		dc.l	PLACETEXT_IN,0,0

ProcessGtags:	dc.l	TAG_DONE


ProcessGadgets:	ds.l	1

Process_CNT	=	1

processtitel:	dc.b	'Working...',0

pc_stoptext:	dc.b	'Stop',0
	even

;***************************************************************************
;*---------------------- Öffne Screen für Pic -----------------------------*
;***************************************************************************
openpic:
		tst.w	loadflag(a5)
		bne.b	.viewok		;Es wurde was geladen
		lea	noimageload,a4
		jsr	status		;kein Bild geladen
		moveq	#-1,d0
		rts
.viewok:
		sf	cybertest(a5)
		move.l	cyberbase(a5),d0
		beq.w	.nocyber
		move.l	d0,a6
		move.l	displayID(a5),d0
		jsr	_LVOIsCyberModeID(a6)
		tst.l	d0
		beq.w	.nocyber

		move.l	displayID(a5),stype

		st	cybertest(a5)		
		move.l	displayID(a5),d1
		move.l	#CYBRIDATTR_DEPTH,d0
		jsr	_LVOGetCyberIDAttr(a6)

		move.l	d0,sdepth
		cmp.l	#$20,d0
		beq.b	.mok
		cmp.l	#$18,d0
		beq	.mok
		cmp.l	#$10,d0
		beq.b	.mok
		cmp.l	#$f,d0
		beq.b	.mok
		sf	cybertest(a5)
		bra.w	.nocyber
.mok:
		tst.l	rndr_rendermem(a5)
		bne.w	vp_norender

;-----------------------------------------------------------------------------
;es sind noch keine RGB Daten vorhanden, also machen wir schnell welche

		bsr	makergbdatas
		tst.l	d0
		beq	vp_norender

		rts

;---------------------------------------------------------------------------
.nocyber:
		tst.b	depthchange(a5)
		beq.b	vp_norender

		bsr.w	render		;berechne neues Pic
		tst.l	d0
		beq.b	vp_norender
		bra.w	waitaction

vp_norender:
		move.l	displayID(a5),d0
		move.l	gfxbase(a5),a6
		jsr	_LVOModeNotAvailable(a6)
		tst.l	d0
		beq.b	modeok
		lea	screenmodemsg1(pc),a4
		jsr	status		;Screenmode not Available
		moveq	#-1,d0
		rts
modeok:		

		tst.b	cybertest(a5)
		bne.b	modesupportet

		sub.l	a0,a0
		lea	infopuffer,a1
		moveq	#88,d0
		move.l	#$80001000,d1	;Tag für DimsInfo
		move.l	displayID(a5),d2
		and.l	#~(ham_key+$80),d2

		tst.b	ham(a5)
		beq.b	.noh
		or.w	#$800,d2
.noh
		tst.b	ham8(a5)
		beq.b	.noh8
		or.w	#$800,d2
.noh8
;		tst.b	ehb(a5)
;		beq	.noe
;		or.w	#$80,d2
.noe:
		jsr	_LVOGetDisplayInfoData(a6)

		lea	infopuffer,a1
		move.w	dim_maxDepth(a1),d0

		moveq	#1,d1
		lsl.l	d0,d1	;Anzahl der zulässigen Farben

		moveq	#0,d2
		move.w	anzcolor(a5),d2
		tst.b	ham(a5)
		beq.b	.noha
		move.w	#64,d2
		bra.b	wertaus
.noha:
		tst.b	ham8(a5)
		beq.b	.noha8
		tst.b	aga(a5)
		beq.b	nomode
.noha8
		tst.b	ehb(a5)
		beq.b	wertaus
		move.w	#32,d2
wertaus:
		cmp.l	d1,d2
		bls.b	modesupportet
nomode:
		lea	screenmodemsg(pc),a4
		jsr	status
		moveq	#-1,d0
		rts

modesupportet:
		move.l	endbase(a5),d0		;
		sub.l	startbase(a5),d0	;
		lea	BufNewGad,a1
		cmp.l	68(a1),d0
		beq.b	.w			;
		move.l	execbasepuffer(a5),a0	;
		move.l	mainwinWnd(a5),(a0)	;
		jmp	memcheck		;

.w
		moveq	#0,d0
		moveq	#0,d1
		move.w	breite(a5),d0		;Screen- und Windowstruck
		move.w	hoehe(a5),d1		;Initialisieren

	tst.b	cybertest(a5)
	bne.b	.cutok
		move.w	displaywidth(a5),d3
	;	move.w	displayheight(a5),d4
								
		move.w	#256,d4
		
;Passe Screengröße an

		cmp.w	d3,d0		;ist Pic Breiter
		bhi.b	.weidthok
		move.w	d3,d0
.weidthok:

		cmp.w	d4,d1
		bhi.b	.heightok
		move.w	d4,d1
.heightok:
		tst.b	merk(a5)	;wird ein Brush ausgeschitten ?
		beq.b	.cutok

		move.l	scale(a5),d5
		move.l	#18,d6
		lsl.l	d5,d6	;Berechen Anfangshöhe des Screens

		add.l	d6,d1		;um x Pixel höher machen da sonst
					;der KoordinatenScreen stört
.cutok:
		move.w	d0,ViewWidth	;Screen- und Windowstruck
		move.w	d1,ViewHeight	;Initialisieren
		move.l	d0,swidth
		move.l	d1,sheight
		moveq	#0,d2
		tst.b	cybertest(a5)
		bne.b	vp_cy
		move.b	planes(a5),d2
		move.l	d2,sdepth

		move.l	displayID(a5),d2	;Aktueller Screenmode
		and.l	#~(ham_key+$80),d2

		tst.b	ham(a5)
		beq.b	.noham
		or.w	#Ham_key,d2
.noham:
		tst.b	ham8(a5)
		beq.b	noham8
		or.w	#Ham_key,d2
noham8:
		tst.b	ehb(a5)
		beq.b	noehb
		or.w	#$80,d2
noehb
		move.l	d2,stype
vp_cy:
		bsr.l	SetupViewScreen
		tst.l	d0
		beq.b	.screenok
.wech:
		lea	screenfailed,a4
		jsr	status		;Nicht genug mem für Screen o. Wind.
		moveq	#-1,d0
		rts
.screenok:
		bsr.l	OpenViewWindow
		tst.l	d0
		beq.b	.winok
		bsr.w	CloseDownViewScreen
		bra.b	.wech
		
;ViewPort ermitteln
.winok:
		move.l  viewWnd(a5),a0
		move.l  IntBase(a5),a6
		jsr     _LVOViewPortAddress(a6)
		move.l	d0,Uviewport1(a5)
		move.l	d0,a0			;Viewport

;Farbtabelle anpassen

		cmp.l	#32,sdepth
		beq.b	initbit
		cmp.l	#16,sdepth
		beq.b	initbit
		cmp.l	#15,sdepth
		beq.b	initbit
		move.l	gfxbase(a5),a6

		cmp.w	#32,anzcolor(a5)
		bhi.b	load32		;AGA

		tst.b	kick3(a5)
		bne.b	load32

		moveq	#0,d0
		move.w	anzcolor(a5),d7
		subq.w	#1,d7
		lea	farbtab8+4(a5),a1
		lea	farbtab4(a5),a2

.nc		move.l	(a1)+,d0
		move.l	(a1)+,d1
		move.l	(a1)+,d2

		rol.l	#8,d0
		rol.l	#8,d1
		rol.l	#8,d2

		and.b	#$f0,d0
		lsl.w	#4,d0
		and.b	#$f0,d1
		or.b	d1,d0
		and.b	#$f0,d2
		lsr.w	#4,d2
		or.w	d2,d0

		move.w	d0,(a2)+
		dbra	d7,.nc

		move.w	anzcolor(a5),d0
		lea	farbtab4(a5),a1
		jsr	_LVOloadrgb4(a6)
		bra.b	initbit
load32:
		lea	farbtab8(a5),a1
		jsr	-882(a6)	;_LVOLoadRGB32

;Bitplane Initialisieren
initbit:
		bra.b	copyimage2bitmap


notsupport:
		lea	screenmodemsg(pc),a4
		jsr	status
		moveq	#-1,d0
		rts	


;--------------------------------------------------------------------------
copyimage2bitmap:

;erzeuge eine TMP Zeile

		tst.b	cybertest(a5)
		bne.w	vp_makecyber

		moveq	#0,d0
		move.b	planes(a5),d0
		move.l	bytebreite(a5),d1
		lsl.l	#3,d1
		mulu.w	d1,d0
		move.l	#MEMF_CLEAR+MEMF_CHIP,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		tst.l	d0
		bne.b	.memok
		bsr.w	CloseViewWindow
		bsr.w	CloseDownViewScreen
		moveq	#-1,d0
		rts
.memok:		
		move.l	d0,tmp_line(a5)

		lea	picmap(a5),a0	
		moveq	#0,d0
		moveq	#0,d1
		move.b	planes(a5),d0
		move.l	bytebreite(a5),d1
		lsl.l	#3,d1
		moveq	#1,d2
		move.l	gfxbase(a5),a6
		jsr	_LVOinitbitmap(a6)
		
		lea	picmap+8(a5),a0
		move.l	tmp_line(a5),d0
		moveq	#0,d7		
		move.b	planes(a5),d7	
		subq	#1,d7
.newplane
		move.l	d0,(a0)+	;Planes in Strucktur einbinden
		add.l	bytebreite(a5),d0
		dbra	d7,.newplane

;Pic in Window kopieren

		move.l	viewWnd(a5),a1		;Fensteradresse

		clr.b	brush(a5)
		move.l	viewWnd(a5),a1		;Fensteradresse
		move.l	50(a1),a1		;Rastport (Ziel)
		move.l	a1,viewRastport(a5)

		move.w	hoehe(a5),d7
		subq.w	#1,d7
		move.l	picmem(a5),a4
		sub.l	a3,a3
.cp_newline:
		moveq	#0,d6
		move.b	planes(a5),d6
		subq.w	#1,d6
		move.l	a4,a0
		move.l	tmp_line(a5),a1
.nl		move.l	bytebreite(a5),d0
		lsr.l	#1,d0
		subq.w	#1,d0
.lo		move.w	(a0)+,(a1)+
		dbra	d0,.lo
		add.l	oneplanesize(a5),a0
		sub.l	bytebreite(a5),a0
		dbra	d6,.nl
		
		add.l	bytebreite(a5),a4
		
		lea	picmap(a5),a0		;Bitmap (Quelle)
		move.l	viewRastport(a5),a1
		moveq	#0,d0			;X1
		moveq	#0,d1			;Y1	
		moveq	#0,d2			;X dest
		move.l	a3,d3			;Y dest

		lea	1(a3),a3

		moveq	#0,d4
		move.w	breite(a5),d4		;Breite
		moveq	#1,d5			;Höhe
		move.l	#$c0,d6			;Miniterm = nur kopieren

		move.l	gfxbase(a5),a6
		jsr	_LVObltbitmaprastport(a6)

		dbra	d7,.cp_newline

		move.l	tmp_line(a5),d0
		beq.b	.w
		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)

.w		jmp	memcheck

vp_makecyber:
		move.l	rndr_rgb(a5),d0
		beq.b	.wech
		move.l	d0,a0
		moveq	#0,d0
		moveq	#0,d1
		move.l	bytebreite(a5),d2
		lsl.l	#3,d2
		add.l	d2,d2
		add.l	d2,d2
		move.l	viewWnd(a5),a1		;Fensteradresse
		move.l	50(a1),a1		;Rastport (Ziel)
		moveq	#0,d3
		moveq	#0,d4
		move.w	breite(a5),d5
		move.w	hoehe(a5),d6
		move.l	#RECTFMT_ARGB,d7
		move.l	cyberbase(a5),a6
		jsr	_LVOWritePixelArray(a6)
				
.wech		jmp	memcheck


screenmodemsg:	dc.b	'Screenmode not supported!',0
screenmodemsg1:	dc.b	'Screenmode not available!',0


;------------------------------------------------------------------------
checkscreenpos:
		move.l	scr1(a5),a0
		moveq	#0,d0
		move.w	sc_leftedge(a0),d0
		move.l	d0,sleftmerk(a5)
		move.w	sc_topedge(a0),d0
		move.l	d0,stopmerk(a5)
		rts

;-----------------------------------------------------------------------
;----     Erzeuge chunky und rgb datas
;-----------------------------------------------------------------------
makergbdatas:
		move.l	bytebreite(a5),d0
		move.w	hoehe(a5),d1
		jsr	APR_InitRenderMem(a5)
		tst.l	d0
		bne.b	.memok	
		lea	notmemmsg,a4
		jsr	status		;Screenmode not Available
		moveq	#-1,d0
		rts

.memok:
		lea	farbtab8(a5),a0
		lea	farbtab8pure,a1
		move.l	(a0)+,d7
		swap	d7
		move.l	d7,d6
		subq.w	#1,d7

.ncc		moveq	#0,d1
		move.l	(a0)+,d0
		lsr.l	#8,d0
		move.l	(a0)+,d1
		swap	d1
		or.w	d1,d0
		move.l	(a0)+,d1
		rol.l	#8,d1
		or.b	d1,d0

		move.l	d0,(a1)+

		dbra	d7,.ncc		

		tst.b	ehb(a5)
		beq.b	.nehb

		lea	farbtab8(a5),a0
		move.l	(a0)+,d7
		add.l	d6,d6
		swap	d7
		subq.w	#1,d7

.cc		moveq	#0,d1
		move.l	(a0)+,d0
		lsr.l	#1,d0
		lsr.l	#8,d0
		move.l	(a0)+,d1
		lsr.l	#1,d1
		swap	d1
		or.w	d1,d0
		move.l	(a0)+,d1
		lsr.l	#1,d1
		rol.l	#8,d1
		or.b	d1,d0

		move.l	d0,(a1)+
		dbra	d7,.cc
;zuerst ein Chunky Pic erzeugen

.nehb
		tst.l	rndr_palette(a5)
		bne.b	.wp
		lea	rndr_paltag(pc),a1
		move.l	rndr_memhandler(a5),4(a1)
		move.l	renderbase(a5),a6
		jsr	_LVOCreatePaletteA(a6)
		move.l	d0,rndr_palette(a5)
.wp
		move.l	rndr_palette(a5),a0
		move.l	d6,d0		;Farbanzahl
		lea	farbtab8pure,a1
		lea	rndr_palitag(pc),a2
		move.l	renderbase(a5),a6
		jsr	_LVOImportPaletteA(a6)		

		lea	rndr_planetab(pc),a1	;init Planetab
		move.l	a1,a0
		moveq	#0,d7
		move.b	planes(a5),d7
		subq.l	#1,d7
		move.l	picmem(a5),d0
.np		move.l	d0,(a1)+
		add.l	oneplanesize(a5),d0
		dbra	d7,.np
.weiter
		move.l	rndr_chunky(a5),a1
		move.l	APG_ByteWidth(a5),d0
		move.w	hoehe(a5),d1
		moveq	#0,d2
		move.b	planes(a5),d2
		move.l	APG_ByteWidth(a5),d3
		
		move.l	renderbase(a5),a6
		
		sub.l	a2,a2
		
		jsr	_LVOPlanar2Chunky(a6)

;jetzt ein RGB pic erzeugen

		move.l	rndr_chunky(a5),a0	;Chunkypuffer
		move.l	rndr_rgb(a5),a1
		move.l	a1,d7
		move.l	rndr_palette(a5),a2		;Palette

		move.l	bytebreite(a5),d0
		lsl.l	#3,d0			;gesamt Chunkybreite
		move.w	hoehe(a5),d1
		moveq	#COLORMODE_CLUT,d5

		tst.b	ham(a5)
		beq.b	.w
		moveq	#COLORMODE_HAM6,d5
		bra.b	.ren
.w		tst.b	ham8(a5)
		beq.b	.ren
		moveq	#COLORMODE_HAM8,d5
.ren
		lea	.vtag(pc),a3
		move.l	d5,4(a3)

		jsr	_LVOChunky2RGBA(a6)
		moveq	#0,d0
		rts

.vtag:
		dc.l	RND_ColorMode,0
		dc.l	TAG_DONE


;-----  Check nochmal um vieviel die Screenhöhe geteilt werden muß ------
checkmode:
		move.l	d6,d0
		moveq	#0,d4
		move.l	d0,d1
		and.l	#$a1000,d0
		cmp.l	#$a1000,d0
		bne.b	.nodblpal
		cmp.l	#-5,d7
		bne.b	.w
.mw		move.l	d0,(a0)
		bra.w	ko_checkdlbscale
.w		move.l	#$a1000+$8000,(a0)
		bra.w	ko_checkdlbscale
.nodblpal:
		move.l	d6,d0
		and.l	#$91000,d0
		cmp.l	#$91000,d0
		bne.b	.nodblntsc
		cmp.l	#-5,d7
		beq.b	.mw
		move.l	#$91000+$8000,(a0)
		bra.w	ko_checkdlbscale
.nodblntsc:
		move.l	d6,d0
		and.l	#$81000,d0
		cmp.l	#$81000,d0
		bne.b	.nosuper72
		cmp.l	#-5,d7
		bne.b	.w1
		move.l	#$81000+$8000,(a0)
		bra.w	ko_checknormal
.w1:		move.l	#$81000+$8020,(a0)
		bra.w	ko_checknormal
.nosuper72:
		move.l	d6,d0
		and.l	#$71000,d0
		cmp.l	#$71000,d0
		bne.b	.noeuro36
		cmp.l	#-5,d7
		bne.b	.w2
.mw1		move.l	d0,(a0)
		bra.w	ko_checknormal
.w2		move.l	#$71000+$8000,(a0)
		bra.w	ko_checknormal
.noeuro36:
		move.l	d6,d0
		and.l	#$61000,d0
		cmp.l	#$61000,d0
		bne.b	.noeuro72
		cmp.l	#-5,d7
		bne.b	.w3
		move.l	#$61000+$8000,(a0)
		bra.w	ko_checkdlbscale
.w3		move.l	#$61000+$8020,(a0)
		bra.w	ko_checkdlbscale
.noeuro72
		move.l	d6,d0
		and.l	#$31000,d0
		cmp.l	#$31000,d0
		bne.b	.novga
		cmp.l	#-5,d7
		bne.b	.w4
		move.l	#$31000+$8000,(a0)
		bra.b	ko_checkdlbscale
.w4		move.l	#$31000+$8020,(a0)
		bra.b	ko_checkdlbscale
.novga:
		move.l	d6,d0
		and.l	#$21000,d0
		cmp.l	#$21000,d0
		bne.b	.nopal
		cmp.l	#-5,d7
		beq.b	.mw1
		move.l	#$21000+$8000,(a0)
		bra.b	ko_checknormal
.nopal:
		move.l	d6,d0
		and.l	#$11000,d0
		cmp.l	#$11000,d0
		bne.b	.nontsc
		cmp.l	#-5,d7
		beq.w	.mw1
		move.l	#$11000+$8000,(a0)
		bra.b	ko_checknormal
.nontsc:
		tst.l	d6
		bne.b	.ww
		cmp.l	#-5,d7
		beq.b	.www
		or.w	#$8000,d6
.www		move.l	d6,(a0)
		bra.b	.ww1
.ww		move.l	d6,(a0)		;unbekannter ScreenMode
.ww1		clr.l	scale(a5)
		rts

ko_checkdlbscale:
		move.l	d6,d0
		and.l	#5,d0
		cmp.b	#5,d0
		bne.b	ko_nodbllace
		move.l	#2,scale(a5)
		bra.b	ko_nolace
ko_nodbllace:
		move.l	d6,d0
		and.l	#4,d0
		cmp.b	#4,d0
		bne.b	ko_nodblnonlace
		move.l	#1,scale(a5)
ko_nodblnonlace:
		bra.b	ko_nolace

ko_checknormal:
		move.l	d6,d0
		and.l	#4,d0
		beq.b	ko_nolace
		move.l	#1,scale(a5)
ko_nolace:
		rts

rect:
		dc.w	0,0,0,0

checkoverscan:
		move.l	viewWnd(a5),a0
		move.l	intbase(a5),a6
		jsr	_LVOViewPortAddress(a6)

		move.l	d0,a0		;Viewport des ViewScreens
		beq.b	.opendefault
		
		move.l	gfxbase(a5),a6
		jsr	_LVOGetVPModeID(a6) ;hole DisplayID vom ViewScreen
		move.l	d0,d6		    ;weil sie ja durch ForceMonitor
		bmi.b	.opendefault	    ;verändert sein kann

		move.l	d6,a0
		lea	rect(pc),a1
		move.l	#OSCAN_STANDARD,d0
		move.l	intbase(a5),a6
		jsr	_LVOQueryOverscan(a6)
		tst.l	d0
		beq.b	.opendefault		

		lea	rect(pc),a0
		move.w	6(a0),d5
		addq.w	#1,d5
		bra.b	.go
		
.opendefault:
		moveq	#0,d0
		move.w	hoehe(a5),d5
.go:
		rts
		
;***************************************************************************
;*-------------------------- Schneide Brush aus ---------------------------*
;***************************************************************************
chcol:
		move.l	a4,a0
		move.l	#13,d1
		move.l	#13,d2
		move.l	#13,d3
		cmp.w	#32,anzcolor(a5)
		bhi.b	.agacolors
		jmp	_LVOSetRGB4(a6)
.agacolors:	lsl.l	#8,d1
		swap	d1
		lsl.l	#8,d2
		swap	d2
		lsl.l	#8,d3
		swap	d3
		jmp	-996(a6)	;_LVOSetRGB32

;-------------------------------------------------------------------------------
clearbrush:
		clr.w	clrflag(a5)
		clr.w	cutflag(a5)

		move.l	#GD_gxbrush,d0
		moveq	#0,d1
		jsr	setnumber	;Lösche brush x,y
		move.l	#GD_gybrush,d0
		moveq	#0,d1
		jsr	setnumber	;Lösche brush x,y

		bra	waitaction

;---------------------------------------------------------------------------------
selectbrush:

		st	cb_actbin(a5)	;flag das cut extern aufgerufen wurde
		bsr	cutbrush1
		rts

cutbrush:
		sf	cb_actbin(a5)
		
		tst.w	loadflag(a5)
		bne.b	.lok		;Es wurde was geladen
		lea	noimageload,a4
		jsr	status		;kein Bild geladen
		bra.l	waitaction

.lok:
cutbrush1:
		jsr	APR_OpenVisualScreen(a5)

		tst.l	d0
		beq	.sok
		lea	cantopenmsg(pc),a4
		move.l	APG_Status(a5),a6
		jsr	(a6)
		tst.b	cb_actbin(a5)
		beq.l	waitaction
		move.l	#'FAIL',d7
		rts	

.sok
		move.l	vi_window(a5),a1	;Fensteradresse
		move.l	50(a1),a1		;Rastport (Ziel)
		move.l	a1,viewRastport(a5)

;öffne kontroll window
		moveq	#1,d0
		tst.b	dscale(a5)
		beq	.scok
		moveq	#0,d0
.scok		lea	TAG_kscale,a0
		move.l	d0,(a0)

		lea	konwinWindowTags,a0
		move.l	a0,windowtaglist(a5)
		lea	konwinWG+4,a0
		move.l	a0,gadgets(a5)
		lea	konwinSC+4,a0
		move.l	a0,winscreen(a5)
		lea	konwinWnd(a5),a0
		move.l	a0,window(a5)

		lea	konwinGlist(a5),a0
		move.l	a0,Glist(a5)
		lea	konwinNgads,a0
		move.l	a0,NGads(a5)
		lea	konwinGTypes,a0
		move.l	a0,GTypes(a5)
		lea	konwinGadgets,a0
		move.l	a0,WinGadgets(a5)
		move.w	#konwin_CNT,win_CNT(a5)
		lea	konwinGtags,a0
		move.l	a0,windowtags(a5)
		move.l	vi_screen(a5),screenbase(a5)

		move.w	#140,WinWidth(a5)
		move.w	#125-11,WinHeight(a5)

		move.l	#140,d0
		bsr	computex

		move.l	d0,d5

		move.l	vi_screen(a5),a0
		lea	sc_viewport(a0),a0
		jsr	APR_GetViewSize(a5)

		move.w	d2,d1
		sub.w	d5,d1
		sub.w	offx(a5),d1
		move.w	d1,WinLeft(a5)

		move.l	#125-11,d0
		bsr	computey

;		move.w	sc_height(a2),d1
		sub.w	d0,d3
		sub.w	offy(a5),d3
		move.w	d3,WinTop(a5)

		lea	KonWinL,a0
		move.l	a0,WinL(a5)
		lea	KonWinT,a0
		move.l	a0,WinT(a5)
		lea	KonWinW,a0
		move.l	a0,WinW(a5)
		lea	KonWinH,a0
		move.l	a0,WinH(a5)

		bsr.l	openwindowF	;öffne Mainwindow

		moveq	#12,d3
		moveq	#15,d2
		moveq	#61,d1
		moveq	#116,d0
		moveq	#1,d4
		move.l	konwinWnd(a5),a0
		bsr	drawframe

		move.l	viewWnd(a5),a0
		move.l	intbase(a5),a6
		jsr	_LVOActivateWindow(a6)
		
		bsr.w	cut

		lea	konwinWnd(a5),a0
		move.l	a0,window(a5)
		lea	konwinGlist(a5),a0
		move.l	a0,Glist(a5)

		jsr	gt_CloseWindow

		jsr	APR_CloseVisualScreen(a5)

		sf	newloaded(a5)

		bsr.l	memcheck
	
		moveq	#0,d4
		moveq	#0,d5

		tst.w	cutflag(a5)
		beq.w	.cutnull

		move.w	cu_x(a5),d0
		move.w	d0,xbrush1(a5)
		add.w	cu_width(a5),d0
		move.w	d0,xbrush2(a5)
		
		move.w	cu_y(a5),d0
		move.w	d0,ybrush1(a5)
		add.w	cu_height(a5),d0
		move.w	d0,ybrush2(a5)

		moveq	#0,d4
		moveq	#0,d5
		move.w	cu_width(a5),d4
		move.w	cu_height(a5),d5
.cutnull:

		tst.b	cb_actbin(a5)	;vom operator aufgerufen ?
		beq	.w
		moveq	#0,d0
		rts
.w
		move.l	d4,d1
		move.l	#GD_gxbrush,d0
		bsr.l	setnumber

		move.l	d5,d1
		move.l	#GD_gybrush,d0
		bsr.l	setnumber

		move.l	mainwinwnd(a5),a0
		bsr.l	aktiwin

		bra.w	waitaction

nocutmsg:	dc.b	'No Cut with this Screen Mode on ECS',0
konscreenfailmsg:dc.b	'Control Screen open failed!',0

;***************************************************************************
;*------------------------- Zeichne Fadenkreuz ----------------------------*
;***************************************************************************
cut:
;Zeichen Modus setzen
;RP_JAM1        EQU 0
;RP_JAM2        EQU 1
;RP_COMPLEMENT  EQU 2
;RP_INVERSVID   EQU 4	      ; inverse video for drawing modes

		move.l	viewRastport(a5),a1
		move.l	#RP_JAM2!RP_COMPLEMENT,d0
		move.l	GfxBase(a5),a6
		jsr	_LVOSetDrMd(a6)		;setze Zeichenmodus

;Stelle zeichenfarbe ein

		moveq	#2,d0		
		move.l	viewRastport(a5),a1
		jsr	_LVOSetAPen(a6)

		clr.b	Toflag(a5)	;Flag ob Controlscreen hinten ist	

		tst.w	cutflag(a5)
		beq.b	new
		bsr.w	drawbox

		move.l	vi_window(a5),a0
		move.l	WD_UserPort(a0),a0	:MSGPort
		move.l	a0,WinMsgPort1(a5)

	*--------------- SignalBits setzen ---------------*

		moveq	#0,d6
		moveq	#0,d0
		move.b	15(a0),d0
		bset	d0,d6

		move.l	konwinWnd(a5),a0
		move.l	WD_UserPort(a0),a0
		move.l	a0,WinMsgPort2(a5)

	*--------------- SignalBits setzen ---------------*
		moveq	#0,d0
		move.b	15(a0),d0
		bset	d0,d6
		move.l	d6,SignalBits(a5)
	bsr	setboxreal
	bra	testweit
;		moveq	#-5,d7
;		bra.w	setboxkor

new:
		move.l	vi_screen(a5),a0
		move.w	16(a0),d4		;MouseY
		move.w	18(a0),d5		;MouseX
				
		move.w	d4,oldy(a5)
		move.w	d5,oldx(a5)

		bsr.w	drawlines

		lea	doghost(pc),a0
		move.l	#1,(a0)
		move.l	#GD_autocut,d0
		lsl.l	#2,d0
		lea	konwinGadgets,a0
		move.l	(a0,d0),a0
		move.l	konwinWnd(a5),a1
		sub.l	a2,a2
		lea	ghosttag(pc),a3
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

wait1:
		move.l	vi_window(a5),a0
		move.l	WD_UserPort(a0),a0	:MSGPort
		move.l	a0,WinMsgPort1(a5)

	*--------------- SignalBits setzen ---------------*
		moveq	#0,d6
;		move.l	SignalBits(a5),d6
		moveq	#0,d0
		move.b	15(a0),d0
		bset	d0,d6

		move.l	konwinWnd(a5),a0
		move.l	WD_UserPort(a0),a0
		move.l	a0,WinMsgPort2(a5)

	*--------------- SignalBits setzen ---------------*
		moveq	#0,d0
		move.b	15(a0),d0
		bset	d0,d6
		move.l	d6,SignalBits(a5)

	*--------------------- Wait ---------------------*
cu_Wait:	move.l	SignalBits(a5),d0
		or.w	#$1000,d0		;Break-Signal
		move.l	4.w,a6
		jsr	_LVOWait(a6)

	*------- War es ein Break Signal -----*
;		btst	#12,d0			;Break-Signal
;		bne.w	Return

	*------- War es ein UserMessage ------*
;		move.l	Signal(a5),d1
		move.l	WinMsgPort1(a5),d2
		beq.s	.NoPort
		move.l	d2,a0
		moveq	#0,d1
		move.b	15(a0),d1
		btst	d1,d0
		bne.b	WartenWinPort1	

	*----- war es eine Window-Message ----*
.NoPort:	move.l	WinMsgPort2(a5),d2		;Testen ob Window-Port
		beq.s	.NoMain
		move.l	d2,a0
		move.b	15(a0),d1
		btst	d1,d0
		bne.b	WartenWinPort2
.NoMain:	bra.b	cu_Wait


Warten:	
WartenWinPort1:	move.l	WinMsgPort1(a5),d0
		beq.s	WartenWinPort2
		move.l	d0,a0
		move.l	4.w,a6
		jsr	_LVOGetmsg(a6)
		tst.l	d0			;Scrollen erlaubt
		beq.b	WartenWinPort2
		bra.b	WindowMessage1

WartenWinPort2:	move.l	WinMsgPort2(a5),d0
		beq.b	cu_Wait
		move.l	d0,a0
		move.l	4.w,a6
		jsr	_LVOGetmsg(a6)
		tst.l	d0			;Scrollen erlaubt
		beq.b	cu_Wait
		bra.b	WindowMessage2

WindowMessage1:
		move.l	d0,a1			;muss nach a1
		move.l	im_Class(a1),d4		;Msg-Type
		move.w	im_Code(a1),d5		;Untergruppe
		move.l	im_Seconds(a1),d6	;Systemzeit
		move.l	im_IAddress(a1),a4	;Adr. für Gadgets
		move.l	4,a6
		jsr	_LVOreplyMsg(a6)	;quittiere Msg in a1

		cmp.l	#IDCMP_MOUSEMOVE,d4
		beq.w	mouse
		cmp.l	#VANILLAKEY,d4
		beq.w	keys		;es wurde eine Taste gedrückt
		cmp.l	#IDCMP_MouseButtons,d4
		beq.w	pressbutton
		bra.b	warten
		
WindowMessage2:
		move.l	d0,a1			;muss nach a1
		move.l	im_Class(a1),d4		;Msg-Type
		move.w	im_Code(a1),d5		;Untergruppe
		move.l	im_Seconds(a1),d6	;Systemzeit
		move.l	im_IAddress(a1),a4	;Adr. für Gadgets
		move.l	4,a6
		jsr	_LVOreplyMsg(a6)	;quittiere Msg in a1

		cmp.l	#IDCMP_CLOSEWINDOW,d4
		beq	schulz		
		cmp.l	#IDCMP_Newsize,d4
		beq	c_newsize
		cmp.l	#VANILLAKEY,d4
		beq.w	keys		;es wurde eine Taste gedrückt
		cmp.l	#GADGETUP,d4
		beq.w	cgads
		bra.w	warten


c_makenewsize:
		move.l	KonwinWnd(a5),a0
		move.l	gadbase(a5),a6
		jsr	_LVOGT_BeginRefresh(a6)
		move.l	KonwinWnd(a5),a0
		moveq	#-1,d0
		jsr	_LVOGT_EndRefresh(a6)
		moveq	#12,d3
		moveq	#15,d2
		moveq	#61,d1
		moveq	#116,d0
		moveq	#1,d4
		move.l	konwinWnd(a5),a0
		bra	drawframe

c_newsize:
		bsr	c_makenewsize
		bra	warten

mouse:
		moveq	#0,d4
		moveq	#0,d5
		move.w	oldy(a5),d4
		move.w	oldx(a5),d5

		move.l	vi_screen(a5),a0
		cmp.w	16(a0),d4	;MouseY
		bne.b	.ok
		cmp.w	18(a0),d5	;MouseX
		bne.b	.ok
		bra.w	warten
.ok
		bsr.w	drawlines

		move.l	vi_screen(a5),a0
		move.w	16(a0),d4	;MouseY
		move.w	18(a0),d5	;MouseX
				
		move.w	d4,oldy(a5)
		move.w	d5,oldx(a5)
	
		bsr.w	drawlines

		move.w	oldx(a5),d4
		move.w	oldy(a5),d5

;----------------------------------------------------------------------------
		move.l	renderbase(a5),a6

		move.w	breite(a5),d1
		move.l	OpDestWidth(a5),d0
		move.l	d4,d2
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d4

		move.w	hoehe(a5),d1
		move.l	OpDestHeight(a5),d0
		move.l	d5,d2
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d5
;----------------------------------------------------------------------------

		cmp.w	breite(a5),d4
		blo.b	.checky
		move.w	breite(a5),d4
		subq.w	#1,d4
.checky
		cmp.w	hoehe(a5),d5
		blo.b	.setit
		move.w	hoehe(a5),d5
		subq.w	#1,d5
.setit:
		bsr.w	setkoord	;Setze Koordinaten im Hilfscreen

		bra.w	warten
schulz:
		clr.w	cutflag(a5)
		rts

cgads:
		move.w	38(a4),d0
		cmp.w	#GD_kscale,d0
		beq	c_checkscale
		cmp.w	#GD_kok,d0
		beq.b	schulz		;beende Programm
		cmp.w	#GD_kcancel,d0
		beq.b	schulz
		bra.w	warten


;noch nicht in benutzung  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
c_checkscale:
		moveq	#0,d0
		moveq	#1,d1
		lea	konwinGadgets,a0
		move.l	GD_kscale*4(a0),a0
		move.w	gg_Flags(a0),d0
		and.w	#SELECTED,d0
		beq.w	.w	;nicht selected
		moveq	#1,d0
		moveq	#0,d1
.w		move.l	d0,TAG_kscale
	;	move.b	d1,dscale(a5)
	;	move.l	d1,TAG_scale
		bra	warten



;es wurde eine Taste gerückt
keys:
		moveq	#-1,d7
		cmp.l	#$1b,d5
		beq.b	schulz
		cmp.l	#'g',d5		;g gedrückt
		beq.b	setg2
		cmp.l	#'a',d5
		bne.b	.w
		lea	schulz(pc),a3
		move.l	#GD_kok,d0
		lea	konwingadgets,a0
		move.l	konwinwnd(a5),aktwin(a5)
		bra.w	setandjump
.w:		cmp.l	#'c',d5
		bne.b	.we
		lea	schulz(pc),a3
		move.l	#GD_kcancel,d0
		lea	konwingadgets,a0
		move.l	konwinwnd(a5),aktwin(a5)
		bra.w	setandjump
.we
		bra.w	warten

setg2:
		bsr.w	setgitter
		bra.w	warten
keys1:
		moveq	#0,d7
		cmp.l	#$1b,d5
		beq.w	schulz
		cmp.l	#'g',d5		;g gedrückt
		beq.b	setg
		cmp.l	#'a',d5
		bne.b	.w
		lea	schulz(pc),a3
		move.l	#GD_kok,d0
		lea	konwingadgets,a0
		move.l	konwinwnd(a5),aktwin(a5)
		bra.w	setandjump
.w:		cmp.l	#'c',d5
		bne.b	.we
		lea	schulz(pc),a3
		move.l	#GD_kcancel,d0
		lea	konwingadgets,a0
		move.l	konwinwnd(a5),aktwin(a5)
		bra.w	setandjump
.we
		bra.w	cutwait

setg:
		bsr.w	setgitter
		bra.w	cutwait


keysauswert:
		cmp.l	#$1b,d5
		beq.b	.wech		;Escape
		cmp.l	#$4c,d5
;		beq.w	up
		cmp.l	#$4d,d5
;		beq.w	down
		cmp.l	#$4e,d5
;		beq.w	right
		cmp.l	#$4f,d5
;		beq.w	left
		cmp.l	#'g',d5		;g gedrückt
		beq.w	setgitter
		moveq	#0,d0
		rts
.wech:
		moveq	#-1,d0
		rts

;***************************************************************************
;*---------------------- Zeichne Cut-Rechteck -----------------------------*
;***************************************************************************
pressbutton:
		cmp.w	#iecode_lbutton,d5
		bne.w	wait1

		move.b	#1,nomove(a5) ;es wurde zum erstem mal geklickt
		
		moveq	#0,d4
		moveq	#0,d5
		move.w	oldy(a5),d4
		move.w	oldx(a5),d5

		bsr.w	drawlines	;Fadenkreuz Clearn

		move.l	vi_screen(a5),a0
		move.w	16(a0),d4	;MouseY
		move.w	18(a0),d5	;MouseX
		
		move.w	d4,ybox(a5)	;Merke anfangskoordinaten
		move.w	d5,xbox(a5)	;vom Rechteck

		lea	doghost(pc),a0
		move.l	#1,(a0)
		move.l	#GD_autocut,d0
		lsl.l	#2,d0
		lea	konwinGadgets,a0
		move.l	(a0,d0),a0
		move.l	konwinWnd(a5),a1
		sub.l	a2,a2
		lea	ghosttag(pc),a3
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
cutwait:
	*--------------------- Wait ---------------------*
cu_Wait1:	move.l	SignalBits(a5),d0
		or.w	#$1000,d0		;Break-Signal
		move.l	4.w,a6
		jsr	_LVOWait(a6)

	*------- War es ein Break Signal -----*
;		btst	#12,d0			;Break-Signal
;		bne.w	Return

	*------- War es ein UserMessage ------*
;		move.l	Signal(a5),d1
		move.l	WinMsgPort1(a5),d2
		beq.s	.NoPort
		move.l	d2,a0
		moveq	#0,d1
		move.b	15(a0),d1
		btst	d1,d0
		bne.b	WartenWinPort11

	*----- war es eine Window-Message ----*
.NoPort:	move.l	WinMsgPort2(a5),d2		;Testen ob Window-Port
		beq.s	.NoMain
		move.l	d2,a0
		move.b	15(a0),d1
		btst	d1,d0
		bne.b	WartenWinPort21
.NoMain:	bra.b	cu_Wait1

Warten1:	
WartenWinPort11:
		move.l	WinMsgPort1(a5),d0
		beq.s	WartenWinPort21
		move.l	d0,a0
		move.l	4.w,a6
		jsr	_LVOGetmsg(a6)
		tst.l	d0			
		beq.b	WartenWinPort21
		bra.b	WindowMessage11

WartenWinPort21:
		move.l	WinMsgPort2(a5),d0
		beq.b	cu_Wait1
		move.l	d0,a0
		move.l	4,a6
		jsr	_LVOGetmsg(a6)
		tst.l	d0
		beq.b	cu_Wait1
		bra.b	WindowMessage21

WindowMessage11:
		move.l	d0,a1			;muss nach a1
		move.l	im_Class(a1),d4		;Msg-Type
		move.w	im_Code(a1),d5		;Untergruppe
		move.l	im_Seconds(a1),d6	;Systemzeit
		move.l	im_IAddress(a1),a4	;Adr. für Gadgets
		move.l	4,a6
		jsr	_LVOreplyMsg(a6)	;quittiere Msg in a1

		cmp.l	#IDCMP_MOUSEMOVE,d4
		beq.w	newdraw
;		cmp.l	#RAWKEY,d4
		cmp.l	#VANILLAKEY,d4
		beq.w	keys1		;es wurde eine Taste gedrückt
		cmp.l	#IDCMP_MouseButtons,d4
		beq.w	testbutton
		bra.b	warten1

WindowMessage21:
		move.l	d0,a1			;muss nach a1
		move.l	im_Class(a1),d4		;Msg-Type
		move.w	im_Code(a1),d5		;Untergruppe
		move.l	im_Seconds(a1),d6	;Systemzeit
		move.l	im_IAddress(a1),a4	;Adr. für Gadgets
		move.l	4,a6
		jsr	_LVOreplyMsg(a6)	;quittiere Msg in a1

		cmp.l	#IDCMP_CLOSEWINDOW,d4
		beq	schulz		
		cmp.l	#IDCMP_Newsize,d4
		beq	c_newsize1
		cmp.l	#VANILLAKEY,d4
		beq.w	keys1		;es wurde eine Taste gedrückt
		cmp.l	#GADGETUP,d4
		beq.b	cgads1
		bra.w	warten1

c_newsize1:
		bsr	c_makenewsize
		bra	warten1

cgads1:
		move.w	38(a4),d0
		cmp.w	#GD_kok,d0
		beq.w	schulz		;beende Programm
		cmp.w	#GD_kcancel,d0
		beq.w	schulz
		bra.w	cutwait

newdraw:
		move.l	vi_screen(a5),a0
		move.w	16(a0),ymouse(a5)
		move.w	18(a0),xmouse(a5)
		
		move.w	xmouse(a5),d0
		move.w	ymouse(a5),d1
		cmp.w	oldx(a5),d0
		bne.b	.ok
		cmp.w	oldy(a5),d1
		bne.b	.ok
;		bra.w	cutwait
		bra.w	warten1
.ok:
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		moveq	#0,d6
		
		tst.w	clrflag(a5)
		beq.b	.noclr

;lösche Rechteck

		tst.b	nomove(a5)
		bne.b	.noclr

		bsr.w	clrbox

;Zeichne Rechteck
.noclr:
		clr.b	nomove(a5) 

		bsr.w	drawbox
		
		moveq	#0,d4
		moveq	#0,d5

		move.w	xbox(a5),d4
		move.w	ybox(a5),d5

		cmp.w	xmouse(a5),d4
		blo	.xk
		move.w	xmouse(a5),d4
.xk:		cmp.w	ymouse(a5),d5
		blo	.yk
		move.w	ymouse(a5),d5
.yk

;----------------------------------------------------------------------------
		move.l	renderbase(a5),a6

		move.w	breite(a5),d1
		move.l	OpDestWidth(a5),d0
		move.l	d4,d2
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d4

		move.w	hoehe(a5),d1
		move.l	OpDestHeight(a5),d0
		move.l	d5,d2
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d5
;----------------------------------------------------------------------------

	;	move.w	xmouse(a5),d4
	;	move.w	ymouse(a5),d5

		clr.b	merk1(a5)
		clr.b	merk2(a5)
		cmp.w	breite(a5),d4
		blo.b	.checky
		move.w	breite(a5),d4
		subq.w	#1,d4
.checky
		cmp.w	hoehe(a5),d5
		blo.b	.setit
		move.w	hoehe(a5),d5
		subq.w	#1,d5
.setit:
		bsr.w	setkoord	;Setze Koordinaten im Hilfscreen

		move.w	xmouse(a5),d4
		move.w	ymouse(a5),d5

;----------------------------------------------------------------------------
		move.l	renderbase(a5),a6

		move.w	breite(a5),d1
		move.l	OpDestWidth(a5),d0
		move.l	d4,d2
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d4

		move.w	hoehe(a5),d1
		move.l	OpDestHeight(a5),d0
		move.l	d5,d2
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d5
;----------------------------------------------------------------------------

laber11
		move.w	xbox(a5),d2
		move.w	ybox(a5),d3

;----------------------------------------------------------------------------
		move.w	d2,d6

		move.w	breite(a5),d1
		move.l	OpDestWidth(a5),d0
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d6

		move.w	hoehe(a5),d1
		move.l	OpDestHeight(a5),d0
		move.l	d3,d2
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d3

		move.l	d6,d2
;----------------------------------------------------------------------------

		cmp.w	breite(a5),d2
		bls.b	.checky1
		move.w	breite(a5),d2
.checky1
		cmp.w	hoehe(a5),d3
		bls.b	.setit1
		move.w	hoehe(a5),d3
.setit1:
		sub.w	d2,d4
		bpl.b	.xok
		neg	d4
		ext.l	d4
.xok:
		sub.w	d3,d5
		bpl.b	.yok
		neg	d5
		ext.l	d5
.yok:
		addq.w	#1,d4
		addq.w	#1,d5
		bsr.w	setkoord1
		moveq	#0,d0
		divu	#16,d4
		swap	d4
		tst.w	d4
		bne.b	.keinword
		moveq	#3,d0
.keinword:
		bsr.w	setwordzeiger
		
		move.w	#1,clrflag(a5)	;beim nächsten mal muß vorher gelöscht
					;werden
		move.w	xmouse(a5),oldx(a5)
		move.w	ymouse(a5),oldy(a5)

;		bra.w	cutwait		
		bra.w	warten1
testbutton:
		cmp.w	#iecode_lbutton,d5
		beq.b	testweit
		bra.w	warten1
testweit:
		move.w	xbox(a5),d2
		move.w	breite(a5),d1
		move.l	OpDestWidth(a5),d0
		move.l	renderbase(a5),a6
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d3

		move.w	ybox(a5),d2
		move.w	hoehe(a5),d1
		move.l	OpDestHeight(a5),d0
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d4		

		move.w	xmouse(a5),d2
		move.w	breite(a5),d1
		move.l	OpDestWidth(a5),d0
		move.l	renderbase(a5),a6
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d5

		move.w	ymouse(a5),d2
		move.w	hoehe(a5),d1
		move.l	OpDestHeight(a5),d0
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d6		

		sub.w	d3,d5		;diff xbox xmouse
		sub.w	d4,d6		;diff ybox ymouse

		move.w	d5,xdiff(a5)
		move.w	d6,ydiff(a5)

;-------------------------------------------------------------------------------

		lea	doghost(pc),a0
		move.l	#0,(a0)
		move.l	#GD_autocut,d0
		lsl.l	#2,d0
		lea	konwinGadgets,a0
		move.l	(a0,d0),a0
		move.l	konwinWnd(a5),a1
		sub.l	a2,a2
		lea	ghosttag(pc),a3
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

;hole werte aus den integer gagets
cu_checkint
		move.l	#GD_aktx,d0
		jsr	cu_getinteger
		move.w	d0,cu_x(a5)
		move.l	#GD_akty,d0
		jsr	cu_getinteger
		move.w	d0,cu_y(a5)
		move.l	#GD_brushx,d0
		jsr	cu_getinteger
		move.w	d0,cu_width(a5)
		move.l	#GD_brushy,d0
		jsr	cu_getinteger
		move.w	d0,cu_height(a5)
		move.l	#GD_kwords,d0
		jsr	cu_getinteger
		move.w	d0,cu_word(a5)
		
warte:		
	*--------------------- Wait ---------------------*
		move.l	SignalBits(a5),d0
		or.w	#$1000,d0		;Break-Signal
		move.l	4,a6
		jsr	_LVOWait(a6)

	*------- War es ein Break Signal -----*
;		btst	#12,d0			;Break-Signal
;		bne.w	Return

	*------- War es ein UserMessage ------*
;		move.l	Signal(a5),d1
		move.l	WinMsgPort1(a5),d2
		beq.s	.NoPort
		move.l	d2,a0
		moveq	#0,d1
		move.b	15(a0),d1
		btst	d1,d0
		bne.b	WartenWinPort12

	*----- war es eine Window-Message ----*
.NoPort:	move.l	WinMsgPort2(a5),d2		;Testen ob Window-Port
		beq.s	.NoMain
		move.l	d2,a0
		move.b	15(a0),d1
		btst	d1,d0
		bne.b	WartenWinPort22
.NoMain:	bra.b	warte

Warten2:	
WartenWinPort12:
		move.l	WinMsgPort1(a5),d0
		beq.s	WartenWinPort22
		move.l	d0,a0
		move.l	4.w,a6
		jsr	_LVOGetmsg(a6)
		tst.l	d0			;Scrollen erlaubt
		beq.b	WartenWinPort22
		bra.b	WindowMessage12

WartenWinPort22:
		move.l	WinMsgPort2(a5),d0
		beq.b	warte
		move.l	d0,a0
		move.l	4.w,a6
		jsr	_LVOGetmsg(a6)
		tst.l	d0			;Scrollen erlaubt
		beq.b	warte
		bra.b	WindowMessage22

WindowMessage12:
		move.l	d0,a1			;muss nach a1
		move.l	im_Class(a1),d4		;Msg-Type
		move.w	im_Code(a1),d5		;Untergruppe
		move.l	im_Seconds(a1),d6	;Systemzeit
		move.l	im_IAddress(a1),a4	;Adr. für Gadgets
		move.w	im_qualifier(a1),d3
		move.l	4,a6
		jsr	_LVOreplyMsg(a6)	;quittiere Msg in a1

		cmp.l	#VANILLAKEY,d4
		beq.w	keys2		;es wurde eine Taste gedrückt
		cmp.l	#RAWKEY,d4
		beq.w	arrows
		cmp.l	#IDCMP_MouseButtons,d4
		beq.w	button
		bra.b	warten2

;------------------------------------------------------------------
WindowMessage22:
		move.l	d0,a1			;muss nach a1
		move.l	im_Class(a1),d4		;Msg-Type
		move.w	im_Code(a1),d5		;Untergruppe
		move.l	im_Seconds(a1),d6	;Systemzeit
		move.l	im_IAddress(a1),a4	;Adr. für Gadgets
		move.w	im_qualifier(a1),d3
		move.l	4,a6
		jsr	_LVOReplyMsg(a6)	;quittiere Msg in a1

		cmp.l	#IDCMP_CLOSEWINDOW,d4
		beq	kcan		
		cmp.l	#IDCMP_Newsize,d4
		beq	c_newsize2
		cmp.l	#GADGETUP,d4
		beq.b	kongads
		cmp.l	#VANILLAKEY,d4
		beq.w	keys2		;es wurde eine Taste gedrückt
		cmp.l	#RAWKEY,d4
		beq.w	arrows
		cmp.l	#IDCMP_MouseButtons,d4
		beq.w	button
		bra.w	warten2

c_newsize2:
		bsr	c_makenewsize
		bra	warten2

kongads:
		move.w	38(a4),d0
		cmp.w	#GD_autocut,d0
		beq.w	autocut
		move.w	38(a4),d0
		cmp.w	#GD_kok,d0
		beq.w	schulz1		;beende Programm
		cmp.w	#GD_kcancel,d0
		beq.w	kcan
		cmp.w	#GD_aktx,d0
		beq	cu_newx		;Integer gadget
		cmp.w	#GD_akty,d0
		beq	cu_newy
		cmp.w	#GD_brushx,d0
		beq	cu_newbx
		cmp.w	#GD_brushy,d0
		beq	cu_newby
		cmp.w	#GD_kwords,d0
		beq	cu_newword
		bra.w	warten2

cu_getinteger:
		lea	konwinGadgets,a0
		move.l	(a0,d0.l*4),a0
		move.l	konwinWnd(a5),a1
		jmp	getintegervalue

cu_setinteger:
		lea	konwinGadgets,a0
		move.l	(a0,d0.l*4),a0
		move.l	konwinWnd(a5),a1
		move.l	d1,d0
		jmp	setintegervalue

;-------------------------------------------------------------------------------
cu_newx:
		move.l	#GD_aktx,d0
		jsr	cu_getinteger
		move.l	d0,d5
		move.l	#GD_brushx,d0
		jsr	cu_getinteger
		add.w	d5,d0
		cmp.w	breite(a5),d0
		bls	.xok
		move.w	cu_x(a5),d5		;wert ist nicht möglich
		move.l	#GD_aktx,d0
		move.l	d5,d1
		jsr	cu_setinteger
.xok:				
		move.w	d5,cu_x(a5)

		move.l	renderbase(a5),a6

		move.l	d5,d2
		move.w	breite(a5),d0
		move.l	OpDestWidth(a5),d1
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d6

		moveq	#0,d4
		moveq	#0,d5

		move.w	xbox(a5),d4

		cmp.w	xmouse(a5),d4
		blo	.xk
		move.w	xmouse(a5),d4
.xk:
		sub.l	d4,d6

		move.w	xbox(a5),d3
		add.w	d6,d3
		cmp.w	#0,d3
		bmi.w	.end

		move.l	vi_screen(a5),a0
		move.w	sc_width(a0),d1		;Screen breite,höhe
		cmp.w	d1,d3
		bhi.w	.end

		move.w	xmouse(a5),d4
		add.w	d6,d4
		cmp.w	#0,d4
		bmi.w	.end

		cmp.w	d1,d4
		bhs.w	.end

		bsr	clrbox1

		move.w	d3,xbox(a5)
		move.w	d4,xmouse(a5)
		
		move.w	ybox(a5),oldybox(a5)
		move.w	ymouse(a5),oldy(a5)
		move.w	xbox(a5),oldxbox(a5)
		move.w	xmouse(a5),oldx(a5)
		bsr.w	drawbox
.end
		bra	warten2		
;-------------------------------------------------------------------
cu_newy:
		move.l	#GD_akty,d0
		jsr	cu_getinteger
		move.l	d0,d5
		move.l	#GD_brushy,d0
		jsr	cu_getinteger
		add.w	d5,d0
		cmp.w	hoehe(a5),d0
		bls	.xok
		move.w	cu_y(a5),d5		;wert ist nicht möglich
		move.l	#GD_akty,d0
		move.l	d5,d1
		jsr	cu_setinteger
.xok:				
		move.w	d5,cu_y(a5)

		move.l	renderbase(a5),a6

		move.l	d5,d2
		move.w	hoehe(a5),d0
		move.l	OpDestHeight(a5),d1
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d6

		moveq	#0,d4
		moveq	#0,d5

		move.w	ybox(a5),d4

		cmp.w	ymouse(a5),d4
		blo	.xk
		move.w	ymouse(a5),d4
.xk:
		sub.l	d4,d6

		move.w	ybox(a5),d3
		add.w	d6,d3
		cmp.w	#0,d3
		bmi.w	.end

		move.l	vi_screen(a5),a0
		move.w	sc_height(a0),d1		;Screen breite,höhe
		cmp.w	d1,d3
		bhi.w	.end

		move.w	ymouse(a5),d4
		add.w	d6,d4
		cmp.w	#0,d4
		bmi.w	.end

		cmp.w	d1,d4
		bhs.w	.end

		bsr	clrbox1

		move.w	d3,ybox(a5)
		move.w	d4,ymouse(a5)
		
		move.w	ybox(a5),oldybox(a5)
		move.w	ymouse(a5),oldy(a5)
		move.w	xbox(a5),oldxbox(a5)
		move.w	xmouse(a5),oldx(a5)
		bsr.w	drawbox

.end
		bra	warten2		

;-------------------------------------------------------------------
cu_newbx:
		move.l	#GD_brushx,d0
		jsr	cu_getinteger
		move.l	d0,d5
		move.l	#GD_aktx,d0
		jsr	cu_getinteger
		add.w	d5,d0
		cmp.w	breite(a5),d0
		bls	.xok
		move.w	cu_width(a5),d5		;wert ist nicht möglich
		move.l	#GD_brushx,d0
		move.l	d5,d1
		jsr	cu_setinteger
.xok:				
		move.w	d5,cu_width(a5)
cu_newbx1:
		move.l	d5,a4
		move.l	d5,d6

		move.l	renderbase(a5),a6

		moveq	#0,d4
		moveq	#0,d5

		move.w	xbox(a5),d4

		moveq	#0,d7
		cmp.w	xmouse(a5),d4
		blo	.xk
		moveq	#-1,d7
		move.w	xmouse(a5),d4
.xk:
		move.l	d4,d2
		move.w	breite(a5),d1
		move.l	OpDestWidth(a5),d0
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d5

		add.w	d5,d6

		move.l	d6,d2
		move.w	breite(a5),d0
		move.l	OpDestWidth(a5),d1
		jsr	_LVOScaleOrdinate(a6)

		tst.l	d7
		beq	.xm
		move.w	d0,xbox(a5)
		bra	.cb
.xm:		move.w	d0,xmouse(a5)
		
.cb
		bsr	clrbox1

		move.w	ybox(a5),oldybox(a5)
		move.w	ymouse(a5),oldy(a5)
		move.w	xbox(a5),oldxbox(a5)
		move.w	xmouse(a5),oldx(a5)
		bsr.w	drawbox

.end
		moveq	#3,d0
		move.l	a4,d1
		divu	#16,d1
		swap	d1
		tst.w	d1
		beq.b	.word
		moveq	#0,d0
		add.l	#$00010000,d1
.word:
		swap	d1
		ext.l	d1
		move.l	d1,d5
		bsr.w	setwordzeiger
		move.l	#GD_kwords,d0
		move.l	d5,d1
		jsr	cu_setinteger

		bra	warten2

;-------------------------------------------------------------------
cu_newby:
		move.l	#GD_brushy,d0
		jsr	cu_getinteger
		move.l	d0,d5
		move.l	#GD_akty,d0
		jsr	cu_getinteger
		add.w	d5,d0
		cmp.w	hoehe(a5),d0
		bls	.yok
		move.w	cu_height(a5),d5		;wert ist nicht möglich
		move.l	#GD_brushy,d0
		move.l	d5,d1
		jsr	cu_setinteger
.yok:				
		move.w	d5,cu_height(a5)

		move.l	d5,d6

		move.l	renderbase(a5),a6

		moveq	#0,d4
		moveq	#0,d5

		move.w	ybox(a5),d4

		moveq	#0,d7
		cmp.w	ymouse(a5),d4
		blo	.xk
		moveq	#-1,d7
		move.w	ymouse(a5),d4
.xk:
		move.l	d4,d2
		move.w	hoehe(a5),d1
		move.l	OpDestHeight(a5),d0
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d5

		add.w	d5,d6

		move.l	d6,d2
		move.w	hoehe(a5),d0
		move.l	OpDestHeight(a5),d1
		jsr	_LVOScaleOrdinate(a6)

		tst.l	d7
		beq	.xm
		move.w	d0,ybox(a5)
		bra	.cb
.xm:		move.w	d0,ymouse(a5)
		
.cb
		bsr	clrbox1

		move.w	ybox(a5),oldybox(a5)
		move.w	ymouse(a5),oldy(a5)
		move.w	xbox(a5),oldxbox(a5)
		move.w	xmouse(a5),oldx(a5)
		bsr.w	drawbox
.end
		bra	warten2

;-------------------------------------------------------------------
cu_newword:
		move.l	#GD_kwords,d0
		jsr	cu_getinteger
		move.l	d0,d5
		lsl.l	#4,d0
		move.l	d0,d4
		move.l	#GD_aktx,d0
		jsr	cu_getinteger
		add.w	d4,d0
		cmp.w	breite(a5),d0
		bls	.wok
		move.w	cu_word(a5),d5
		move.l	d5,d1
		move.l	#GD_kwords,d0
		jsr	cu_getinteger
.wok:
		move.w	d5,cu_word(a5)

		move.l	#GD_brushx,d0
		lsl.l	#4,d5
		move.l	d5,d1
		jsr	cu_setinteger

		bra	cu_newbx1

;-------------------------------------------------------------------
button:
		cmp.w	#iecode_rbutton,d5
		beq.w	cutnew
		cmp.w	#iecode_lbutton,d5
		beq.b	movebox
		bra.w	warten2

;Bewege Box mit der Mouse
movebox:
		move.l	vi_screen(a5),a0
		move.w	16(a0),d4	;MouseY
		move.w	18(a0),d5	;MouseX
		
;check ob in Box geklickt wurde

		move.w	xmouse(a5),d0
		sub.w	xbox(a5),d0
		bpl.b	mb_checkx1	;normal 
		cmp.w	xbox(a5),d5
		bhi.w	warten2		
		cmp.w	xmouse(a5),d5
		bmi.w	warten2
		bra.b	mb_ycheck
mb_checkx1:
		cmp.w	xbox(a5),d5
		bmi.w	warten2		
		cmp.w	xmouse(a5),d5
		bhi.w	warten2
mb_ycheck:
		move.w	ymouse(a5),d0
		sub.w	ybox(a5),d0
		bpl.b	mb_checky1	;normal 
		cmp.w	ybox(a5),d4
		bhi.w	warten2
		cmp.w	ymouse(a5),d4
		bmi.w	warten2
		bra.b	mb_ok
mb_checky1:
		cmp.w	ybox(a5),d4
		bmi.w	warten2
		cmp.w	ymouse(a5),d4
		bhi.w	warten2
mb_ok:
		move.w	d4,ymerk(a5)	;anfangswert merken
		move.w	d5,xmerk(a5)

		sf	merk1(a5)
		tst.b	drawgrid(a5)
		beq.b	.o
		moveq	#0,d7
		bsr.w	setgitter
		st	merk1(a5)	;merken das das Gitter wieder gezeichent wird
		sf	drawgrid(a5)
.o
mb_wait:	move.l	vi_window(a5),a0
		bsr.w	wait

		cmp.l	#IDCMP_MOUSEBUTTONS,d4
		beq.w	mb_checkend
mb_checkagain:	cmp.l	#IDCMP_MOUSEMOVE,d4
		beq.b	mb_mousemove

		tst.b	merk1(a5)
		beq.w	warten2
		moveq	#0,d7
		bsr.w	setgitter

		bra.w	warten2
mb_mousemove:
		move.l	vi_screen(a5),a0
		move.w	16(a0),d4	;MouseY
		move.w	18(a0),d5	;MouseX
		
		move.w	xmerk(a5),d0
		move.w	ymerk(a5),d1
		
		move.w	d4,ymerk(a5)
		move.w	d5,xmerk(a5)
		
		sub.w	d0,d5	;xdiff
		sub.w	d1,d4	;ydiff
		
		move.w	ybox(a5),d0
		add.w	d4,d0
		cmp.w	#0,d0
		bmi.b	mb_wait

		move.l	vi_screen(a5),a0
		move.w	sc_height(a0),d1		;Screen breite,höhe
		cmp.w	d1,d0
		bhi.b	mb_wait


;		movem.l	d0/d1,-(a7)
;		move.l	d0,d2
;		move.w	hoehe(a5),d1
;		move.l	OpDestHeight(a5),d0
;		move.l	renderbase(a5),a6
;		jsr	_LVOScaleOrdinate(a6)
;		add.w	ydiff(a5),d0
;
;		move.w	d0,d2
;		move.w	hoehe(a5),d0
;		move.l	OpDestHeight(a5),d1
;		jsr	_LVOScaleOrdinate(a6)
;		move.l	d0,d2		
;		movem.l	(a7)+,d0/d1

		move.w	ymouse(a5),d2
		add.w	d4,d2

		cmp.w	#0,d2
		bmi.w	mb_wait

		cmp.w	d1,d2
		bhs.w	mb_wait

		move.w	xbox(a5),d3
		add.w	d5,d3
		cmp.w	#0,d3
		bmi.w	mb_wait

		move.l	vi_screen(a5),a0
		move.w	sc_width(a0),d1		;Screen breite,höhe
		cmp.w	d1,d3
		bhi.w	mb_wait

		move.w	xmouse(a5),d4
		add.w	d5,d4
		cmp.w	#0,d4
		bmi.w	mb_wait

		cmp.w	d1,d4
		bhs.w	mb_wait

		move.w	d0,ybox(a5)
		move.w	d2,ymouse(a5)
		bsr.w	clrbox1
		move.w	d3,xbox(a5)
		move.w	d4,xmouse(a5)
		
		move.w	ybox(a5),oldybox(a5)
		move.w	ymouse(a5),oldy(a5)
		move.w	xbox(a5),oldxbox(a5)
		move.w	xmouse(a5),oldx(a5)
		bsr.w	drawbox

		moveq	#-6,d7	;das setboxkor wieder zurück kommt
		bsr.w	setboxkor
				
		bra.w	mb_wait
		
mb_checkend:
		cmp.w	#SELECTDOWN,d5
		bne.w	mb_checkagain

		tst.b	merk1(a5)
		beq.w	warten2
		moveq	#0,d7
		bsr.w	setgitter
		bra.w	warten2

;-------------------------------------------------------------------
kcan:
		clr.w	cutflag(a5)
		bra.w	clrbox	

;bereite für neuen ausschnitt vor

cutnew:
		move.l	vi_window(a5),a0
		move.l	intbase(a5),a6
		jsr	_LVOActivateWindow(a6)

		moveq	#0,d4
		moveq	#0,d5
		bsr.w	setkoord1
		moveq	#0,d0
		bsr.w	setwordzeiger		

		tst.b	nomove(a5)
		bne.b	.nc
		bsr.w	clrbox		
.nc
		clr.w	clrflag(a5)
		bra.w	new		;Fange ganz von vorne an

schulz1:
		move.w	#1,cutflag(a5)
		bra.w	clrbox
keys2:
		moveq	#0,d7
		cmp.w	#'x',d5
		beq	cu_aktx
		cmp.w	#'y',d5
		beq	cu_akty
		cmp.w	#'w',d5
		beq	cu_bx
		cmp.w	#'h',d5
		beq	cu_by
		cmp.w	#'r',d5
		beq	cu_bw
		cmp.l	#$1b,d5
		beq.b	schulz1
		cmp.l	#'g',d5		;g gedrückt
		beq.w	setg1
		cmp.w	#8,d5
		beq.w	boxup
		cmp.l	#'a',d5
		bne.b	.w
		lea	schulz1(pc),a3
		move.l	#GD_kok,d0
		lea	konwingadgets,a0
		move.l	konwinwnd(a5),aktwin(a5)
		bra.w	setandjump
.w:		cmp.l	#'c',d5
		bne.b	.we
		lea	kcan(pc),a3
		move.l	#GD_kcancel,d0
		lea	konwingadgets,a0
		move.l	konwinwnd(a5),aktwin(a5)
		bra.w	setandjump
.we
		cmp.l	#'u',d5
		bne.b	.w1
		lea	autocut(pc),a3
		move.l	#GD_autocut,d0
		lea	konwingadgets,a0
		move.l	konwinwnd(a5),aktwin(a5)
		bra.w	setandjump
.w1		
		bra.w	warten2

cu_aktint:
		lea	konwinGadgets,a0
		move.l	(a0,d0.l*4),a0
		move.l	konwinWnd(a5),a1
		sub.l	a2,a2
		move.l	intbase(a5),a6
		jsr	_LVOActivateGadget(a6)		
		bra	warten2
			
;aktiviere integer gadgets über tasten
cu_aktx:
		move.l	#GD_aktx,d0
		bra	cu_aktint
cu_akty:
		move.l	#GD_akty,d0
		bra	cu_aktint
cu_bx:
		move.l	#GD_brushx,d0
		bra	cu_aktint
cu_by:
		move.l	#GD_brushy,d0
		bra	cu_aktint
cu_bw:
		move.l	#GD_kwords,d0
		bra	cu_aktint

arrows:
		moveq	#0,d7
		cmp.w	#$4c,d5
		beq.b	boxup
		cmp.w	#$4d,d5
		beq.w	boxdown
		cmp.w	#$4e,d5
		beq.w	boxright
		cmp.w	#$4f,d5
		beq.w	boxleft
		bra.w	warten2
setg1:
		bsr.w	setgitter
		bra.w	warten2

boxup:
		and.w	#$00ff,d3
		cmp.w	#IEQUALIFIER_LALT,d3
		beq.b	boxleftup	;alt	linke obere ecke
		cmp.w	#IEQUALIFIER_RALT,d3
		beq.b	boxleftup	;alt	linke obere ecke
		cmp.w	#IEQUALIFIER_LSHIFT,d3
		beq.b	boxrightup	;shift	rechte untere ecke
		cmp.w	#IEQUALIFIER_RSHIFT,d3
		beq.b	boxrightup	;shift	rechte untere ecke
		move.w	ybox(a5),d0
		subq.w	#1,d0
		bmi.w	warten2
		move.w	ymouse(a5),d1
		subq.w	#1,d1
		bmi.w	warten2
boxupgo		bsr.w	clrbox1
	;	move.w	xmouse(a5),oldx(a5)
		move.w	d0,ybox(a5)
		move.w	d1,ymouse(a5)
		move.w	ybox(a5),oldybox(a5)
		move.w	ymouse(a5),oldy(a5)
		bsr.w	drawbox
		bra.w	setboxkor
boxleftup:
		move.w	ybox(a5),d0
		move.w	ymouse(a5),d1
		cmp.w	d1,d0
		blo.b	.yboxsub
		subq.w	#1,d1
		bmi.w	warten2
		cmp.w	d0,d1
		beq.w	warten2
		bra.b	boxupgo
.yboxsub:
		subq.w	#1,d0
		bmi.w	warten2
		cmp.w	d0,d1
		beq.w	warten2
		bra.b	boxupgo

boxrightup:
		move.w	ybox(a5),d0
		move.w	ymouse(a5),d1
		cmp.w	d0,d1
		beq.w	setboxkor
		blo.b	.yboxsub
		subq.w	#1,d1
		beq.w	warten2
		cmp.w	d0,d1
		beq.w	warten2
		bra.b	boxupgo
.yboxsub:
		subq.w	#1,d0
		beq.w	warten2
		cmp.w	d0,d1
		beq.w	warten2
		bra.b	boxupgo

boxdown:
		and.w	#$00ff,d3
		cmp.w	#IEQUALIFIER_LALT,d3
		beq.b	boxleftdown	;alt
		cmp.w	#IEQUALIFIER_RALT,d3
		beq.b	boxleftdown	;alt
		cmp.w	#IEQUALIFIER_LSHIFT,d3
		beq.w	boxrightdown	;shift
		cmp.w	#IEQUALIFIER_RSHIFT,d3
		beq.w	boxrightdown	;shift
		move.w	ybox(a5),d0
		addq.w	#1,d0
		move.l	vi_screen(a5),a0
		move.w	sc_height(a0),d2		;Screen breite,höhe
		cmp.w	d0,d2
		blo.w	warten2
		move.w	ymouse(a5),d1
		addq.w	#1,d1
		move.l	vi_screen(a5),a0
		move.w	sc_height(a0),d2		;Screen breite,höhe
		cmp.w	d1,d2
		blo.w	warten2
boxdowngo:	bsr.w	clrbox1
	;	move.w	xmouse(a5),oldx(a5)
		move.w	d0,ybox(a5)
		move.w	ybox(a5),oldybox(a5)
		move.w	d1,ymouse(a5)
		move.w	ymouse(a5),oldy(a5)
		bsr.w	drawbox
		bra.w	setboxkor

boxleftdown:
		move.w	ybox(a5),d0
		move.w	ymouse(a5),d1
		cmp.w	d0,d1
		beq.w	setboxkor
		blo.b	.ymouseadd
		addq.w	#1,d0
		cmp.w	d0,d1
		beq.w	warten2
		move.l	vi_screen(a5),a0
		move.w	sc_height(a0),d2		;Screen breite,höhe
		cmp.w	d1,d2
		blo.w	warten2
		bra.b	boxdowngo
.ymouseadd:
		addq.w	#1,d1
		cmp.w	d0,d1
		beq.w	warten2
		move.l	vi_screen(a5),a0
		move.w	sc_height(a0),d2		;Screen breite,höhe
		cmp.w	d0,d2
		blo.w	warten2
		bra.b	boxdowngo
		
boxrightdown:
		move.w	ybox(a5),d0
		move.w	ymouse(a5),d1
		cmp.w	d1,d0
		blo.b	.ymousesub
		addq.w	#1,d0
		cmp.w	d0,d1
		beq.w	warten2
		bra.b	boxdowngo
.ymousesub:
		addq.w	#1,d1
		cmp.w	d0,d1
		beq.w	warten2
		bra.b	boxdowngo

boxleft:
		and.w	#$00ff,d3
		cmp.w	#IEQUALIFIER_LALT,d3
		beq.b	boxleftleft	;alt
		cmp.w	#IEQUALIFIER_RALT,d3
		beq.b	boxleftleft	;alt
		cmp.w	#IEQUALIFIER_LSHIFT,d3
		beq.b	boxrightleft	;shift
		cmp.w	#IEQUALIFIER_RSHIFT,d3
		beq.b	boxrightleft	;shift
		move.w	xbox(a5),d0
		subq.w	#1,d0
		bmi.w	warten2
		move.w	xmouse(a5),d1
		subq.w	#1,d1
		bmi.w	warten2
boxleftgo:	bsr.w	clrbox1
	;	move.w	xmouse(a5),oldx(a5)
		move.w	d0,xbox(a5)
		move.w	xbox(a5),oldxbox(a5)
		move.w	d1,xmouse(a5)
		move.w	xmouse(a5),oldx(a5)
		bsr.w	drawbox
		bra.w	setboxkor

boxleftleft:
		move.w	xbox(a5),d0
		move.w	xmouse(a5),d1
		cmp.w	d1,d0
		blo.b	.xboxsub
		subq.w	#1,d1
		bmi.w	warten2
		cmp.w	d0,d1
		beq.w	warten2
		bra.b	boxleftgo
.xboxsub:
		subq.w	#1,d0
		bmi.w	warten2
		cmp.w	d0,d1
		beq.w	warten2
		bra.b	boxleftgo
		
boxrightleft:
		move.w	xbox(a5),d0
		move.w	xmouse(a5),d1
		cmp.w	d0,d1
		beq.w	setboxkor
		blo.b	.xboxsub
		subq.w	#1,d1
		beq.w	warten2
		cmp.w	d0,d1
		beq.w	warten2
		bra.b	boxleftgo
.xboxsub:
		subq.w	#1,d0
		beq.w	warten2
		cmp.w	d0,d1
		beq.w	warten2
		bra.b	boxleftgo

boxright:
		and.w	#$00ff,d3
		cmp.w	#IEQUALIFIER_LALT,d3
		beq.b	boxleftright	;alt
		cmp.w	#IEQUALIFIER_RALT,d3
		beq.b	boxleftright	;alt
		cmp.w	#IEQUALIFIER_LSHIFT,d3
		beq.w	boxrightright	;shift
		cmp.w	#IEQUALIFIER_RSHIFT,d3
		beq.w	boxrightright	;shift
		move.w	xbox(a5),d0
		addq.w	#1,d0
		move.l	vi_screen(a5),a0
		move.w	sc_width(a0),d2		;Screen breite,höhe
		cmp.w	d0,d2
		blo.w	warten2
		move.w	xmouse(a5),d1
		addq.w	#1,d1
		move.l	vi_screen(a5),a0
		move.w	sc_width(a0),d2		;Screen breite,höhe
		cmp.w	d1,d2
		beq.w	warten2
boxrightgo:	bsr.w	clrbox1
	;	move.w	xmouse(a5),oldx(a5)
		move.w	d0,xbox(a5)
		move.w	xbox(a5),oldxbox(a5)
		move.w	d1,xmouse(a5)
		move.w	xmouse(a5),oldx(a5)
		bsr.w	drawbox
		bra.w	setboxkor

boxleftright:
		move.w	xbox(a5),d0
		move.w	xmouse(a5),d1
		cmp.w	d0,d1
		beq.w	setboxkor
		blo.b	.xmousesub
		addq.w	#1,d0
		cmp.w	d0,d1
		beq.w	warten2
		move.l	vi_screen(a5),a0
		move.w	sc_width(a0),d2		;Screen breite,höhe
		cmp.w	d0,d2
		beq.w	warten2
		bra.b	boxrightgo
.xmousesub:
		addq.w	#1,d1
		cmp.w	d0,d1
		beq.w	warten2
		move.l	vi_screen(a5),a0
		move.w	sc_width(a0),d2		;Screen breite,höhe
		cmp.w	d1,d2
		beq.w	warten2
		bra.b	boxrightgo
		
boxrightright:
		move.w	xbox(a5),d0
		move.w	xmouse(a5),d1
		cmp.w	d1,d0
		blo.b	.xmouseadd
		addq.w	#1,d0
		cmp.w	d0,d1
		beq.w	warten2
		move.l	vi_screen(a5),a0
		move.w	sc_width(a0),d2		;Screen breite,höhe
		cmp.w	d1,d2
		beq.w	warten2
		bra.w	boxrightgo
.xmouseadd:
		addq.w	#1,d1
		cmp.w	d0,d1
		beq.w	warten2
		move.l	vi_screen(a5),a0
		move.w	sc_width(a0),d2		;Screen breite,höhe
		cmp.w	d1,d2
		beq.w	warten2
		bra.w	boxrightgo

setboxreal:
		move.w	cu_x(a5),d4
		move.w	cu_y(a5),d5
		bsr	setkoord

		move.w	cu_width(a5),d4
		move.w	cu_height(a5),d5
		bsr	setkoord1

		moveq	#0,d0
		divu	#16,d4
		swap	d4
		tst.w	d4
		bne.b	.keinword
		moveq	#3,d0
.keinword:
		bra.w	setwordzeiger


setboxkor:
		moveq	#0,d4
		moveq	#0,d5

		moveq	#0,d4
		moveq	#0,d5

		move.w	xbox(a5),d4
		move.w	ybox(a5),d5

		cmp.w	xmouse(a5),d4
		blo	.xk
		move.w	xmouse(a5),d4
.xk:		cmp.w	ymouse(a5),d5
		blo	.yk
		move.w	ymouse(a5),d5
.yk

;----------------------------------------------------------------------------
		move.l	renderbase(a5),a6

		move.w	breite(a5),d1
		move.l	OpDestWidth(a5),d0
		move.l	d4,d2
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d4

		move.w	hoehe(a5),d1
		move.l	OpDestHeight(a5),d0
		move.l	d5,d2
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d5
;----------------------------------------------------------------------------

		cmp.w	breite(a5),d4
		blo.b	.checky
		move.w	breite(a5),d4
		subq.w	#1,d4
.checky
		cmp.w	hoehe(a5),d5
		blo.b	.setit
		move.w	hoehe(a5),d5
		subq.w	#1,d5
.setit:
		bsr.w	setkoord	;Setze Koordinaten im Hilfscreen

		move.w	xmouse(a5),d4
		move.w	ymouse(a5),d5

		move.l	renderbase(a5),a6

		move.w	breite(a5),d1
		move.l	OpDestWidth(a5),d0
		move.l	d4,d2
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d4

		move.w	hoehe(a5),d1
		move.l	OpDestHeight(a5),d0
		move.l	d5,d2
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d5

		move.w	xbox(a5),d2
		move.w	ybox(a5),d3

;----------------------------------------------------------------------------
		move.w	d2,d6

		move.w	breite(a5),d1
		move.l	OpDestWidth(a5),d0
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d6

		move.w	hoehe(a5),d1
		move.l	OpDestHeight(a5),d0
		move.l	d3,d2
		jsr	_LVOScaleOrdinate(a6)
		move.l	d0,d3

		move.l	d6,d2
;----------------------------------------------------------------------------

		cmp.w	breite(a5),d2
		bls.b	.checky1
		move.w	breite(a5),d2
.checky1
		cmp.w	hoehe(a5),d3
		bls.b	.setit1
		move.w	hoehe(a5),d3
.setit1:
		sub.w	d2,d4
		bpl.b	.xok
		neg	d4
		ext.l	d4
.xok:
		sub.w	d3,d5
		bpl.b	.yok
		neg	d5
		ext.l	d5
.yok:
		addq.w	#1,d4
		addq.w	#1,d5

		bsr.w	setkoord1

		moveq	#0,d0
		divu	#16,d4
		swap	d4
		tst.w	d4
		bne.b	.keinword
		moveq	#3,d0
.keinword:
		bsr.w	setwordzeiger
		move.l	d2,d0
		cmp.l	#'AU',d7
		beq	.wech
		cmp.l	#-5,d7
		beq.w	testweit
		cmp.l	#-6,d7	;wir wurden von Boxmove aufgerufen
		beq.b	.wech
		bra.w	warten2
.wech		rts

;===================================================================
;		Passe CutBox an Image automatisch an
;===================================================================
autocut:
		move.l	vi_window(a5),a0
		bsr.w	setwaitpointer
		move.l	konwinWnd(a5),a0
		bsr.w	setwaitpointer

		tst.l	picmem(a5)
		beq	.nixmap
;Rastport init
		lea	datapuffer,a1		;Puffer für tmp rastport
		move.l	gfxbase(a5),a6
		jsr	_LVOInitRastPort(a6)
		
		lea	picmap(a5),a0	
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.b	planes(a5),d0
		move.l	bytebreite(a5),d1
		lsl.l	#3,d1
		move.w	hoehe(a5),d2
		move.l	gfxbase(a5),a6
		jsr	_LVOinitbitmap(a6)

		lea	picmap+8(a5),a0
		move.l	picmem(a5),d0
		moveq	#0,d7		
		move.b	planes(a5),d7	
		subq	#1,d7
.newplane
		move.l	d0,(a0)+	;Planes in Strucktur einbinden
		add.l	oneplanesize(a5),d0
		dbra	d7,.newplane
		
		lea	datapuffer,a1		;Puffer für tmp rastport
		lea	picmap(a5),a0
		move.l	a0,rp_bitmap(a1)
.nixmap:
		move.l	renderbase(a5),a6
		move.w	breite(a5),d1
		move.l	OpDestWidth(a5),d0
		move.w	xbox(a5),d2
		jsr	_LVOScaleOrdinate(a6)
		move.w	d0,xboxreal(a5)
		move.w	breite(a5),d1
		move.l	OpDestWidth(a5),d0
		move.w	xmouse(a5),d2
		jsr	_LVOScaleOrdinate(a6)
		move.w	d0,xmousereal(a5)

		move.w	hoehe(a5),d1
		move.l	OpDestHeight(a5),d0
		move.w	ybox(a5),d2
		jsr	_LVOScaleOrdinate(a6)
		move.w	d0,yboxreal(a5)
		move.w	hoehe(a5),d1
		move.l	OpDestHeight(a5),d0
		move.w	ymouse(a5),d2
		jsr	_LVOScaleOrdinate(a6)
		move.w	d0,ymousereal(a5)
		
		sf	merk2(a5)

		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		moveq	#0,d6
		moveq	#0,d7
		sub.l	a4,a4

		tst.b	drawgrid(a5)
		beq.b	.o
		bsr.w	setgitter
		move.l	#1,a4	;merken das das Gitter wieder gezeichent wird
.o
		bsr.w	clrbox

		move.w	xboxreal(a5),d0	;X
		move.w	yboxreal(a5),d1	;Y
;		move.l	viewrastport(a5),a1

;		lea	datapuffer,a1		;Puffer für tmp rastport

		move.l	gfxbase(a5),a6
		bsr	au_readpixel

	;	jsr	_LVOReadPixel(a6)
	;	move.b	d0,merk1(a5)
		move.l	d0,APG_Free1(a5)
.ok
		moveq	#1,d2
		move.w	yboxreal(a5),d0
		move.w	ymousereal(a5),d1
		cmp.w	d0,d1	      ;position von ybox und Ymouse zueinander
		beq.b	au_testx2x2
		bhi.b	.ok1
		moveq	#-1,d2
.ok1:
		moveq	#1,d4
		move.w	xboxreal(a5),d6
		move.w	xmousereal(a5),d7
		cmp.w	d6,d7
		bhs.b	.noneg
		moveq	#-1,d4
.noneg:
		move.w	yboxreal(a5),d5

		bsr.w	testxline

		tst.w	d0
		bne.b	au_testx2x2	;line kann nicht mehr verschoben werden

;		bsr.w	clrbox
		add.w	d2,yboxreal(a5)
;		bsr.w	drawbox
		bra.b	.ok
				
au_testx2x2:
		moveq	#-1,d2
		move.w	yboxreal(a5),d0
		move.w	ymousereal(a5),d1
		cmp.w	d0,d1
		beq.b	au_testy1y1
		bhi.b	.o1
		moveq	#1,d2
.o1
		move.w	xmousereal(a5),d0	;X
		move.w	ymousereal(a5),d1	;Y
;		move.l	viewrastport(a5),a1

	;	lea	datapuffer,a1		;Puffer für tmp rastport

	;	jsr	_LVOReadPixel(a6)

		bsr	au_readpixel

	;	move.b	d0,merk1(a5)
		move.l	d0,APG_Free1(a5)
.ok1:
		moveq	#1,d4
		move.w	xboxreal(a5),d6
		move.w	xmousereal(a5),d7
		cmp.w	d6,d7
		bhs.b	.noneg
		moveq	#-1,d4
.noneg:
		move.w	ymousereal(a5),d5

		move.l	gfxbase(a5),a6
		bsr.w	testxline

		tst.w	d0
		bne.b	au_testy1y1.1	;line kann nicht mehr verschoben werden

;		bsr.w	clrbox
		add.w	d2,ymousereal(a5)
;		bsr.w	drawbox
		move.w	xmousereal(a5),oldx(a5)		!!!!!!!!!!!!!!!!!!!!!!!!
		move.w	ymousereal(a5),oldy(a5)		!!!!!!!!!!!!!!!!!!!!!!!!

		bra.b	au_testx2x2

au_testy1y1.1
		move.w	xboxreal(a5),d0		;X
		move.w	ymousereal(a5),d1	;Y
;		move.l	viewrastport(a5),a1

	;	lea	datapuffer,a1		;Puffer für tmp rastport
	;	jsr	_LVOReadPixel(a6)

		bsr	au_readpixel

	;	move.b	d0,merk1(a5)
		move.l	d0,APG_Free1(a5)
au_testy1y1:
		moveq	#1,d2
		move.w	xboxreal(a5),d0
		move.w	xmousereal(a5),d1
		cmp.w	d0,d1
		beq.b	au_testy2y2
		bhi.b	.ok1
		moveq	#-1,d2
.ok1:
		moveq	#1,d4
		move.w	yboxreal(a5),d6
		move.w	ymousereal(a5),d7
		cmp.w	d6,d7
		bhs.b	.noneg
		moveq	#-1,d4
.noneg:
		move.w	xboxreal(a5),d5

		move.l	gfxbase(a5),a6
		bsr.w	testYline

		tst.w	d0
		bne.b	au_testy2y2.1	;line kann nicht mehr verschoben werden

		add.w	d2,xboxreal(a5)
		bra.b	au_testy1y1

au_testy2y2.1:
		move.w	xmousereal(a5),d0	;X
		move.w	ymousereal(a5),d1	;Y
;		move.l	viewrastport(a5),a1

	;	lea	datapuffer,a1		;Puffer für tmp rastport
	;	jsr	_LVOReadPixel(a6)

		bsr	au_readpixel

	;	move.b	d0,merk1(a5)
		move.l	d0,APG_Free1(a5)
au_testy2y2:
		moveq	#-1,d2
		move.w	xboxreal(a5),d0
		move.w	xmousereal(a5),d1
		cmp.w	d0,d1
		beq.b	au_end
		bhi.b	.ok1
		moveq	#1,d2
.ok1:
		moveq	#1,d4
		move.w	yboxreal(a5),d6
		move.w	ymousereal(a5),d7
		cmp.w	d6,d7
		bhs.b	.noneg
		moveq	#-1,d4
.noneg:
		move.w	xmousereal(a5),d5

		move.l	gfxbase(a5),a6
		bsr.w	testYline

		tst.w	d0
		bne.b	au_end		;line kann nicht mehr verschoben werden

		add.w	d2,xmousereal(a5)
		move.w	xmousereal(a5),oldx(a5)		!!!!!!!!!!!!!!!!!!!!!!!
		move.w	ymousereal(a5),oldy(a5)		!!!!!!!!!!!!!!!!!!!!!!!

		bra.b	au_testy2y2

au_end:
		move.w	xmousereal(a5),oldx(a5)		!!!!!!!!!!!!!!!!!!!!!!!!
		move.w	ymousereal(a5),oldy(a5)		!!!!!!!!!!!!!!!!!!!!!!!!

		move.l	renderbase(a5),a6

		move.w	breite(a5),d0
		move.l	OpDestWidth(a5),d1
		move.w	xboxreal(a5),d2
		jsr	_LVOScaleOrdinate(a6)
		move.w	d0,xbox(a5)
		move.w	breite(a5),d0
		move.l	OpDestWidth(a5),d1
		move.w	xmousereal(a5),d2
		jsr	_LVOScaleOrdinate(a6)
		move.w	d0,xmouse(a5)
		move.w	breite(a5),d0
		move.l	OpDestWidth(a5),d1
		move.w	oldx(a5),d2
		jsr	_LVOScaleOrdinate(a6)
		move.w	d0,oldx(a5)
.nix
		move.w	hoehe(a5),d0
		move.l	OpDestHeight(a5),d1
		move.w	yboxreal(a5),d2
		jsr	_LVOScaleOrdinate(a6)
		move.w	d0,ybox(a5)
		move.w	hoehe(a5),d0
		move.l	OpDestHeight(a5),d1
		move.w	ymousereal(a5),d2
		jsr	_LVOScaleOrdinate(a6)
		move.w	d0,ymouse(a5)
		move.w	hoehe(a5),d0
		move.l	OpDestHeight(a5),d1
		move.w	oldy(a5),d2
		jsr	_LVOScaleOrdinate(a6)
		move.w	d0,oldy(a5)
.nix1
	move.l	a4,-(a7)
		bsr.w	drawbox
	move.l	(a7)+,a4
		move.l	a4,d0
		tst.l	d0
		beq.b	.nogrid
		moveq	#0,d7
		bsr.w	setgitter
.nogrid:

;-------- Setze Koordinaten neu ------------------
au_set:
		move.l	#'AU',d7
		bsr	setboxkor

		move.l	vi_window(a5),a0
		bsr.w	clearwaitpointer
		move.l	konwinWnd(a5),a0
		bsr.w	clearwaitpointer

		bra.w	warten2

;------------ Teste eine Linie ob sie nur gleiche Pixel hat ---------------
testXline:
		move.w	d6,d0	;X
		move.w	d5,d1	;Y
;		move.l	viewrastport(a5),a1

	;	lea	datapuffer,a1		;Puffer für tmp rastport
	;	jsr	_LVOReadPixel(a6)

		bsr	au_readpixel

	;	cmp.b	merk1(a5),d0
		cmp.l	APG_Free1(a5),d0
		bne.b	.noeq
.np:
		cmp.w	d7,d6
		beq.b	au_wech

		move.l	d0,d3		;merken

		add.w	d4,d6

		move.w	d6,d0
		move.w	d5,d1
;		move.l	viewrastport(a5),a1

	;	lea	datapuffer,a1		;Puffer für tmp rastport
	;	jsr	_LVOReadPixel(a6)

		bsr	au_readpixel

		cmp.w	d0,d3
		beq.b	.np
.noeq
		moveq	#-1,d0
		rts		
au_wech		
	;	move.b	d0,merk1(a5)
		move.l	d0,APG_Free1(a5)
		moveq	#0,d0
		rts
;--------------------------------------------------------------------
testYline:
		move.w	d5,d0	;X
		move.w	d6,d1	;Y
;		move.l	viewrastport(a5),a1

	;	lea	datapuffer,a1		;Puffer für tmp rastport
	;	jsr	_LVOReadPixel(a6)

		bsr	au_readpixel

	;	cmp.b	merk1(a5),d0
		cmp.l	APG_Free1(a5),d0
		bne.b	.noeq

.np:
		cmp.w	d7,d6
		beq.b	au_wech1

		move.l	d0,d3		;merken

		add.w	d4,d6

		move.w	d5,d0
		move.w	d6,d1
;		move.l	viewrastport(a5),a1

	;	lea	datapuffer,a1		;Puffer für tmp rastport
	;	jsr	_LVOReadPixel(a6)

		bsr	au_readpixel

		cmp.w	d0,d3
		beq.b	.np
.noeq:
		moveq	#-1,d0
		rts		
au_wech1:
	;	move.b	d0,merk1(a5)
		move.l	d0,APG_Free1(a5)
		moveq	#0,d0
		rts
;---------------------------------------------------------------------------
;----------------- Readpixel für Autocut -----------------------------------
;---------------------------------------------------------------------------
;>d0,d1	x,y
au_readpixel:
		ext.l	d0
		ext.l	d1
		tst.l	picmem(a5)
		bne	au_readbitmap

		move.l	d2,-(a7)
		move.l	rndr_rgb(a5),a0
		move.l	bytebreite(a5),d2
		lsl.l	#5,d2
		lsl.l	#2,d0		;mal 4
		mulu	d1,d2
		add.l	d2,d0
		move.l	(a0,d0.l),d0
		move.l	(a7)+,d2
		rts

au_readbitmap:
		move.l	gfxbase(a5),a6
		lea	datapuffer,a1		;Puffer für tmp rastport
		jsr	_LVOReadPixel(a6)
		rts


;***************************************************************************
;*--------------------------- Lösche Box ----------------------------------*
;***************************************************************************
clrbox:
		move.w	xbox(a5),d3
		move.w	ybox(a5),d4
				
		move.w	oldx(a5),d5
		move.w	ybox(a5),d6

		bsr.w	drawline

		move.w	oldx(a5),d5
		move.w	d5,d3

		move.w	oldy(a5),d6

		cmp.w	d6,d4
		beq.b	.nodraw
		
		cmp.w	d6,d4
		blo.b	.kleiner
		subq.w	#1,d4
		addq.w	#1,d6
		bra.b	.go
.kleiner:	addq.w	#1,d4
		subq.w	#1,d6
.go:

		bsr.w	drawline
;		bsr.w	drawwider	;es nur noch vom letzen Punkt
					;weiter gezeichnet

		move.w	oldx(a5),d3
		move.w	oldy(a5),d4
		move.w	xbox(a5),d5
;		move.w	oldy(a5),d6
		move.w	d4,d6
		
		cmp.w	d3,d5
		beq.b	.nodraw

		bsr.w	drawline
;		bsr.w	drawwider

		move.w	xbox(a5),d3
		move.w	oldx(a5),d5
		cmp.w	d3,d5
		beq.b	.nodraw

		move.w	ybox(a5),d4
		move.w	d3,d5
		move.w	oldy(a5),d6

		cmp.w	d6,d4
		blo.b	.klei
		subq.w	#1,d4
		addq.w	#1,d6
		bra.b	.go1
.klei:		addq.w	#1,d4
		subq.w	#1,d6
.go1:

		bsr.w	drawline
;		bsr.w	drawwider

.nodraw:
		tst.b	drawgrid(a5)
		beq.b	.nogrid
		move.w	oldx(a5),xwert(a5)
		move.w	oldy(a5),ywert(a5)
		bsr.w	drawgitter
.nogrid:
		rts
clrbox1:
		movem.l	d0/d1/d3/d4/d5,-(a7)
		move.w	xbox(a5),d3
		move.w	oldybox(a5),d4
				
		move.w	oldx(a5),d5
		move.w	oldybox(a5),d6

		bsr.w	drawline

		move.w	oldx(a5),d5
		move.w	d5,d3

		move.w	oldy(a5),d6

		cmp.w	d6,d4
		beq.b	.nodraw
		
		cmp.w	d6,d4
		blo.b	.kleiner
		subq.w	#1,d4
		addq.w	#1,d6
		bra.b	.go
.kleiner:	addq.w	#1,d4
		subq.w	#1,d6
.go:

		bsr.w	drawline
					;weiter gezeichnet
		move.w	oldx(a5),d3
		move.w	oldy(a5),d4
		move.w	xbox(a5),d5
		move.w	d4,d6
		
		cmp.w	d3,d5
		beq.b	.nodraw

		bsr.w	drawline

		move.w	xbox(a5),d3
		move.w	oldx(a5),d5
		cmp.w	d3,d5
		beq.b	.nodraw

		move.w	oldybox(a5),d4
		move.w	d3,d5
		move.w	oldy(a5),d6


		cmp.w	d6,d4
		blo.b	.klei
		subq.w	#1,d4
		addq.w	#1,d6
		bra.b	.go1
.klei:		addq.w	#1,d4
		subq.w	#1,d6
.go1:

		bsr.w	drawline
.nodraw:
		tst.b	drawgrid(a5)
		beq.b	.nogrid
		move.w	oldx(a5),xwert(a5)
		move.w	oldy(a5),ywert(a5)
		bsr.w	drawgitter
.nogrid:
		movem.l	(a7)+,d0/d1/d3/d4/d5
		rts

;***************************************************************************
;*--------------------------- Zeichne Box ---------------------------------*
;***************************************************************************
drawbox:
		move.w	xbox(a5),d3
		move.w	ybox(a5),d4
				
		move.w	xmouse(a5),d5
		move.w	ybox(a5),d6

		bsr.w	drawline

		move.w	xmouse(a5),d5
		move.w	d5,d3
		move.w	ymouse(a5),d6

		cmp.w	d6,d4	
		beq.b	.nodraw	    ;es wird eine Höhe von eins ausgeschnitten

		cmp.w	d6,d4
		blo.b	.kleiner
		subq.w	#1,d4
		addq.w	#1,d6
		bra.b	.go
.kleiner:	addq.w	#1,d4
		subq.w	#1,d6
.go:
		
		bsr.w	drawline
					;weiter gezeichnet
		move.w	xmouse(a5),d3
		move.w	ymouse(a5),d4
		move.w	xbox(a5),d5
		move.w	d4,d6
		
		cmp.w	d3,d5
		beq.b	.nodraw
		
		bsr.w	drawline

		move.w	xbox(a5),d3
		move.w	xmouse(a5),d5

		cmp.w	d3,d5
		beq.b	.nodraw

		move.w	ybox(a5),d4
		move.w	d3,d5
		move.w	ymouse(a5),d6


		cmp.w	d6,d4
		blo.b	.klei
		subq.w	#1,d4
		addq.w	#1,d6
		bra.b	.go1
.klei:		addq.w	#1,d4
		subq.w	#1,d6
.go1:
		bsr.w	drawline

.nodraw:
		tst.b	drawgrid(a5)
		beq.b	.nogrid
		move.w	xmouse(a5),xwert(a5)
		move.w	ymouse(a5),ywert(a5)
		bsr.b	drawgitter
.nogrid:
		move.w	ybox(a5),oldybox(a5)
		rts

;------------------ Zeichnet Gitter in Box ------------------------
drawgitter:
		move.w	#1,xtest(a5)		;check in welcher Richtung
		move.w	#1,ytest(a5)		;Box aufgemacht wurde
		move.w	xbox(a5),d0
		move.w	xwert(a5),d1
		sub.w	d0,d1
		bpl.b	.xok
		move.w	#-1,xtest(a5)
.xok:
		move.w	ybox(a5),d0
		move.w	ywert(a5),d1
		sub.w	d0,d1
		bpl.b	.yok
		move.w	#-1,ytest(a5)
.yok:
		move.w	xbox(a5),d1
		move.w	xwert(a5),d0
		sub.w	d1,d0

	add.w	xtest(a5),d0
	
		muls	xtest(a5),d0		;Korrigiere Vorzeichen
		move.w	d0,d1
		lsr.w	#4,d1		;/16
		move.w	d1,anzgitter(a5)
		lsl.w	#4,d1
		cmp.w	d1,d0
		bne.b	.gitterok		;wenn durch 16 teilbar
		sub.w	#1,anzgitter(a5)	;ein abziehen
.gitterok
		move.w	anzgitter(a5),d7
		sub.w	#1,d7
		bmi.b	gwech
		move.w	xbox(a5),xzaehler(a5)
		moveq	#1,d0
		muls	xtest(a5),d0		;korr. vorzeichen
		sub.w	d0,xzaehler(a5)
		move.w	#16,d2
		muls	xtest(a5),d2
.nline:
		add.w	d2,xzaehler(a5)
		move.w	xzaehler(a5),d3
		move.w	ybox(a5),d4
		move.w	xzaehler(a5),d5
		move.w	ywert(a5),d6
		bsr.w	drawline
		dbra	d7,.nline
gwech
		rts

;==== Setze oder lösche Gitter wenn taste gedrückt ===

setgitter:
		tst.b	drawgrid(a5)	;wird schon ein gitter gezeichnet
		bne.b	.clrgrid	;ja
		move.b	#1,drawgrid(a5)
		tst	d7
		bne.b	.wech
		move.w	xmouse(a5),xwert(a5)
		move.w	ymouse(a5),ywert(a5)
		bra.b	.make
.clrgrid:
		clr.b	drawgrid(a5)
		tst	d7
		bne.b	.wech
.make:
		bsr.w	drawgitter
.wech:
		move.l	TAG_drawgrid,d0
		not.l	d0
		move.l	d0,TAG_drawgrid
		moveq	#0,d0
		rts		

endrequester:
		lea	tagitemliste1,a0
		lea	lastmsg-7720,a1
		lea	lastmsg1-8230,a2
endreq1:	tst.b	keyfound(a5)		;wurde wegecrackt
		bne.s	.w			;crack !!!!
		move.w	finalcheck(a5),d0
		lsr.w	#1,d0
		cmp.w	#151,d0
		beq.s	.w
		move.l	#_LVOrtEZRequestA*4,d0
		asr.l	#2,d0
		sub.l	a3,a3
		sub.l	a4,a4
		lea	7720(a1),a1
		lea	8230(a2),a2
		move.l	reqtbase(a5),a6
		jsr	(a6,d0.l)
.w		move.b	d0,merk1(a5)
		rts

;***************************************************************************
;*------------------------- Zeichne Linien --------------------------------*
;***************************************************************************
;d4 = Y  d5= X
drawlines:
		move.l	GfxBase(a5),a6
		moveq	#0,d0	;x
		move.l	d4,d1
		move.l	viewRastport(a5),a1
		jsr	_LVOMove(a6)

		move.l	vi_screen(a5),a0
		move.w	sc_width(a0),d0		;Screen breite,höhe
		move.l	d4,d1
		move.l	viewRastport(a5),a1
		jsr	_LVODraw(a6)

		move.l	d5,d0	;x
		moveq	#0,d1
		move.l	viewRastport(a5),a1
		jsr	_LVOMove(a6)

		move.l	d5,d0
		move.l	vi_screen(a5),a0
		move.w	sc_height(a0),d1

		move.l	viewRastport(a5),a1
		jmp	_LVODraw(a6)
		
;***************************************************************************
;*------------------------- Zeichne Linie ---------------------------------*
;***************************************************************************
;d3 = x1,  d4 = y1,  d5 = x2,  d6 = y2
drawline:
		move.l	GfxBase(a5),a6
		move.l	d3,d0	;x
		move.l	d4,d1	;y
		move.l	viewRastport(a5),a1
		jsr	_LVOMove(a6)
drawwider:
		move.l	GfxBase(a5),a6
		move.l	d5,d0
		move.l	d6,d1
		move.l	viewRastport(a5),a1
		jmp	_LVODraw(a6)


;***************************************************************************
;*------------------------- gebe X,Y Koords aus ---------------------------*
;***************************************************************************
;d4=x d5=y
setkoord:
		move.w	d4,cu_x(a5)
		move.w	d5,cu_y(a5)
		move.l	#GD_aktx,d0
		lsl.l	#2,d0
		lea	konwinGadgets,a4
		move.l	(a4,d0),a0
		lea	number(pc),a3
		move.l	d4,(a3)
		bsr.b	set
		move.l	#GD_akty,d0
		lsl.l	#2,d0
		move.l	(a4,d0),a0
		lea	number(pc),a3
		move.l	d5,(a3)
		bra.b	set
setkoord1:
		move.w	d4,cu_width(a5)
		move.w	d5,cu_height(a5)
		lea	number(pc),a3
		move.l	#GD_brushx,d0
		lsl.l	#2,d0
		lea	konwinGadgets,a4
		move.l	(a4,d0),a0
		lea	number(pc),a3
		move.l	d4,(a3)
		bsr.b	set
		move.l	#GD_brushy,d0
		lsl.l	#2,d0
		move.l	(a4,d0),a0
		lea	number(pc),a3
		move.l	d5,(a3)
		bsr.b	set
		move.l	d4,d0
		add.l	#15,d0
		lsr.l	#4,d0
		lea	number(pc),a3
		move.l	d0,(a3)
		move.l	d0,kwords(a5)
		move.l	#GD_kwords,d0
		lsl.l	#2,d0
		move.l	(a4,d0),a0

set:
		move.l	konwinWnd(a5),a1
		sub.l	a2,a2
		lea	numbertag(pc),a3
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
		rts
numbertag:
		dc.l	GTIN_Number
number:		dc.l	0
		dc.l	TAG_DONE
		
;***************************************************************************
;*------------------------- Setzte Word-Zeiger ----------------------------*
;***************************************************************************
setwordzeiger:
;d0=Farbe
		movem.l	d0-a6,-(a7)
		move.l	konwinWnd(a5),a1
		move.l	50(a1),a1	;Rastport
		move.l	a1,a4
		move.l	gfxbase(a5),a6
		jsr	_LVOSetAPen(a6)
		
		move.l	a4,a1
		moveq	#61+12,d0
		bsr	computey
		add.w	OffY(a5),d0
		move.l	d0,d3
		subq.w	#1,d3
		move.l	#15+116,d0
		bsr	computex
		add.w	OffX(a5),d0
		move.l	d0,d2
		subq.w	#1,d2
		moveq	#61,d0
		bsr	computey
		addq.w	#1,d0
		add.w	OffY(a5),d0
		move.l	d0,d1
		move.l	#116,d0
		bsr	computex
		addq.w	#1,d0
		add.w	OffX(a5),d0
		move.l	d0,d4
		jsr	_LVORectFill(a6)

		movem.l	(a7)+,d0-a6
		rts

loadfile:	dc.b	'Load file',0
savefile:	dc.b	'Save file',0
savepref:	dc.b	'Save settings',0
loadpref:	dc.b	'Load settings',0
prefsname:	dc.b	'ArtPRO.Prefs',0
prefsdir:	dc.b	'ENVARC:ArtPRO',0
	even


;;--- Initialisiere Screen mit Starwerten --
initscreen:
		moveq	#0,d0
		move.w	prefsdisplayWidth(a5),d0
		move.l	d0,mainwidth
		move.w	prefsDisplayHeight(a5),d0
		move.l	d0,mainheight
		move.w	prefsDisplayDepth(a5),d0
		move.l	d0,maindepth
		move.l	prefsDisplayID(a5),mainID
		moveq	#0,d0
		move.w	prefsoverscantype(a5),d0
		move.l	d0,mainoscan
		move.l	prefsautoroll(a5),mainscroll
		rts
;
;---- Benutze neuen Font -----
makenewwindow:
		tst.b	newfont(a5)
		beq.b	.fontok
		clr.b	nofont(a5)

		lea	usefontname,a0
		move.l	newfontname1(a5),(a0)
		move.w	newfontheight(a5),d0
		move.w	d0,4(a0)

		move.l	diskbase(a5),a6
		jsr	_LVOOpenDiskFont(a6)
		
		move.l	d0,userfont(a5)
		bne.b	.fontok
		st	nofont(a5)

.fontok:
		bsr.w	deleteappwindow

		lea	MainwinWnd(a5),a0
		move.l	a0,window(a5)
		lea	MainwinGlist(a5),a0
		move.l	a0,Glist(a5)
		bsr.w	gt_CloseWindow

		tst.b	newscr(a5)
		beq.b	.nopub

	;	lea	logostruck,a0
	;	move.l	gfxbase(a5),a6
	;	bsr.w	freelogo

		bsr.w	ClosedownScreen

		bsr.w	initscreen
		
		bsr.w	setupscreen		;öffne Screen
		tst.l	d0
		bne.w	.fail	
		move.l	scr(a5),d0
		move.l	d0,rt_screen
		move.l	d0,rt_screen1

.nopub:
		moveq	#0,d0
		move.l	scr(a5),a0
		move.l	40(a0),a0
		move.w	4(a0),d0		;Fonthöhe
		addq.l	#3,d0
		move.w	d0,zoomheight

		clr.b	fontallready(a5)

		sf	iconifyflag(a5)

		lea	MainwinWindowTags,a0
		move.l	a0,windowtaglist(a5)
		lea	MainwinWG+4,a0
		move.l	a0,gadgets(a5)
		lea	MainwinSC+4,a0
		move.l	a0,winscreen(a5)
		lea	MainwinWnd(a5),a0
		move.l	a0,window(a5)
		lea	MainwinGlist(a5),a0
		move.l	a0,Glist(a5)
		lea	MainwinNgads,a0
		move.l	a0,NGads(a5)
		lea	MainwinGTypes,a0
		move.l	a0,GTypes(a5)
		lea	MainwinGadgets,a0
		move.l	a0,WinGadgets(a5)
		move.w	#Mainwin_CNT,win_CNT(a5)
		lea	MainwinGtags,a0
		move.l	a0,windowtags(a5)
		move.l	scr(a5),screenbase(a5)

		move.w	#mainwinWidth,WinWidth(a5)
		move.w	#mainwinHeight,WinHeight(a5)
		move.w	#mainwinTop,WinTop(a5)
		move.w	#mainwinLeft,WinLeft(a5)
		lea	MainWinL,a0
		move.l	a0,WinL(a5)
		lea	MainWinT,a0
		move.l	a0,WinT(a5)
		lea	MainWinW,a0
		move.l	a0,WinW(a5)
		lea	MainWinH,a0
		move.l	a0,WinH(a5)

		move.w	mainx(a5),d0
		move.w	mainy(a5),d1
		add.w	#mainwinLeft,d0
		add.w	#mainwinTop,d1

		move.w	d1,WinTop(a5)
		move.w	d0,WinLeft(a5)

		bsr.w	openwindowF	;öffne Mainwindow
		tst.l	d0
		beq.b	.winok
		bra.w	.fail			;hat nicht geklappt
.winok:
	st	iconifyflag(a5)
		bsr.w	mainwinRender

		bsr.w	makeappwindow

		tst.b	customscr(a5)
		beq.b	.nocust
		bsr.w	makescreencolors
.nocust:

		move.l	mainwinwnd(a5),a0
		move.l	a0,rt_window
		move.l	a0,rt_window1
		
		move.l	50(a0),mainRastport(a5) ;Rastport sichern
		move.l 	mainwinWnd(a5),a0
		move.l  IntBase(a5),a6
		jsr     _LVOViewPortAddress(a6)
		move.l	d0,Uviewport(a5)

		move.l	loadername(a5),d5
		move.l	#GD_gloader,d6
		bsr.w	setnewname
		move.l	savername(a5),d5
		move.l	#GD_gsaver,d6
		bsr.w	setnewname
		
		bsr.l	imageandgagetset

	sf	iconifyflag(a5)

		lea	readymsg,a4
		bsr.w	status

		move.l	#'ICON',d7	;damit cutflag nicht gelöscht wird
		bsr.w	setpicsizegads	;Set Länge und Breit neu

		move.l	#GD_gxbrush,d0
		move.l	bxsize(a5),d1
		bsr.w	setnumber

		move.l	#GD_gybrush,d0
		move.l	bysize(a5),d1
		bsr.w	setnumber
		
;		move.l	TAG_brushsize,d1
;		move.l	#GD_gbrushsize,d0
;		bsr.w	setnumber

;		move.l	kwords(a5),d1
;		move.l	#GD_gwords,d0
;		bsr.w	setnumber

		sf	iconifyflag(a5)
		moveq	#0,d0
		rts
.fail:
		moveq	#-1,d0
		rts

;;--- Holt Palette vom Screen für Prefs ---
checkpalette:
		move.l 	mainwinWnd(a5),a0
		move.l  IntBase(a5),a6
		jsr     _LVOViewPortAddress(a6)
		move.l	d0,a0
		move.l	4(a0),a0	;Colormap

		move.b	cm_Type(a0),d3	;ColormapTyp 0=old 0<>neu
		moveq	#0,d0
;		move.l	maindepth(pc),d0
;		moveq	#1,d1
;		lsl.l	d0,d1
;		move.w	d1,d7
;		move.w	d7,anzmaincolors(a5)

		move.w	prefsDisplayDepth(a5),d0
		cmp.w	#8,d0
		bls	.cok
		move.l	#256,d7
		bra	.w
.cok:		move.w	anzmaincolors(a5),d7
.w		
		move.l	cm_colorTable(a0),a1	;Colortable
		move.l	cm_LowColorBits(a0),a2	;Tab mit den unteren Bits

		lea	prefspurefarbtab(a5),a0

		subq.l	#1,d7
		cmp.b	#2,d3		;colortype
		bhs.b	cp_newcolor

.nc:		move.w	(a1)+,d0
		move.w	d0,d1
		and.w	#$f00,d1
		lsr.w	#4,d1
		move.b	d1,(a0)+
		move.w	d0,d1
		and.w	#$0f0,d1
		move.b	d1,(a0)+
		and.w	#$f,d0
		lsl.w	#4,d0
		move.b	d0,(a0)+
		dbra	d7,.nc
		rts

cp_newcolor:		
.nc:		move.w	(a1)+,d0
		move.w	(a2)+,d1

		moveq	#0,d2
		moveq	#0,d3
		move.w	d0,d2
		and.w	#$f00,d2
		lsl.w	#4,d2
		move.w	d1,d3
		and.w	#$f00,d3
		or.w	d3,d2
		lsr.w	#8,d2
		move.b	d2,(a0)+	;Rot

		moveq	#0,d2
		moveq	#0,d3
		move.w	d0,d2
		and.w	#$f0,d2
		move.w	d1,d3
		and.w	#$f0,d3
		lsr.w	#4,d3
		or.w	d3,d2
		move.b	d2,(a0)+	;grün		

		moveq	#0,d2
		moveq	#0,d3
		move.w	d0,d2
		and.w	#$f,d2
		lsl.w	#4,d2
		move.w	d1,d3
		and.w	#$f,d3
		or.w	d3,d2
		move.b	d2,(a0)+	;blau
		dbra	d7,.nc			
		rts

lastmsg:
		dc.b	'Remember, this version of ArtPRO',10,10
		dc.b	'    is still not registered!',10,10
		dc.b	'        When will you do?',0
	even
lastmsg1:
		dc.b	'Right now!',0		
	even

;--------------------------------------------------------------------------
;-------------- Neue Preferenz --------------------------------------------
;--------------------------------------------------------------------------
settings:
		move.l	#set_WindowTags,APG_WindowTagList(a5) ;Tag list for the Window
		move.l	#set_WinWG+4,APG_WGadgets(a5)	;addr. of WA_Gadgets Tag + 4
		move.l	#set_winSC+4,APG_WScreen(a5)	;addr. of WA_CustomScreen Tag + 4
		move.l	#set_window,APG_WinWnd(a5)	;a point for the Window
		move.l	#set_Glist,APG_Glist(a5)	;a point for the Glist
		move.l	#set_NGads,APG_NGads(a5)	;the NGads list
		move.l	#set_Gtypes,APG_GTypes(a5)	;the GTypes list
		move.l	#set_Gtags,APG_Gtags(a5)	;the Gtags list
		move.w	#Prefs_CNT,APG_CNT(a5)		;the number of Gadgets
		move.l	#set_gadarray,APG_Gadgets(a5)	;a pointer for the Gadgetsarry, size=4*number of Gadgets
		move.l	APG_Scr(a5),APG_ScrBase(a5)	;the Screenpointer , stored in APG_Scr
	
		move.l	mainwinWnd(a5),a0

		move.l	#430,d0
		bsr.w	computex
				
;zentrier window

		move.w	wd_width(a0),d1		;screenbreite
		sub.w	d0,d1
		lsr.w	#1,d1
		add.w	wd_LeftEdge(a0),d1
		move.w	d1,APG_WinLeft(a5)

		move.l	#22,d0
		bsr.w	computey
		add.w	wd_TopEdge(a0),d0

		move.w	d0,APG_WinTop(a5)

		move.w	#430,APG_WinWidth(a5)		;the width of the Win
		move.w	#195+15,APG_WinHeight(a5)		;the height of the Win

		move.l	#set_WinL,APG_WinL(a5)		;addr. of WA_Left Tag 
		move.l	#set_WinT,APG_WinT(a5)		;addr. of WA_Top Tag
		move.l	#set_WinW,APG_WinW(a5)		;addr. of WA_Width Tag
		move.l	#set_WinH,APG_WinH(a5)		;addr. of WA_Height Tag

		move.l	APG_OpenWindow(a5),a6
		jsr	(a6)

		tst.l	d0
		bne.w	waitaction
		
		lea	set_Text0(pc),a2
		move.w	#4,APG_TNUM(a5)
		move.l	APG_Writetext(a5),a6
		jsr	(a6)

		move.l	set_window(pc),a0
		moveq	#5,d0
		moveq	#4,d1
		move.l	#417,d2
		move.l	#202,d3
		moveq	#0,d4
		bsr.w	drawframe

		move.l	set_window(pc),a0
		moveq	#15,d0
		moveq	#20,d1
		move.l	#170+5,d2
		move.l	#85-8+14,d3
		moveq	#0,d4
		bsr.w	drawframe

		move.l	set_window(pc),a0
		move.l	#190+5,d0
		moveq	#20,d1
		move.l	#215,d2
		move.l	#85-8+14,d3
		moveq	#0,d4
		bsr.w	drawframe

		move.l	set_window(pc),a0
		move.l	#15,d0
		moveq	#101+12+14,d1
		move.l	#215+40,d2
		move.l	#20+13+7+15,d3
		moveq	#0,d4
		bsr.w	drawframe

		move.l	set_window(pc),a0
		move.l	#275,d0
		moveq	#101+12+14,d1
		move.l	#135,d2
		move.l	#20+13+7+15,d3
		moveq	#0,d4
		bsr.w	drawframe

		move.l	mainwinWnd(a5),a0
		bsr.w	setwaitpointer

		bsr.w	set_checkghost

;----------------------------------------------------------------------------
;Sichere die alten Einstellungen

		lea	overwrite(a5),a0	;Sichere die alten
		lea	hsize(a5),a1		;Einstellungen
		sub.l	a0,a1
		move.l	a1,d0
		lea	poverwrite(a5),a1
.np:		move.b	(a0)+,(a1)+
		dbra	d0,.np

		move.l	TAG_showpic(pc),ptag_show(a5)
		move.l	TAG_drawgrid(pc),ptad_drawgrid(a5)
		move.l	TAG_autosave(pc),ptag_autosave(a5)
		move.l	TAG_overwrite(pc),ptag_overwrite(a5)
		move.l	TAG_iconify(pc),pTAG_iconify(a5)
		move.l	TAG_screens(pc),pTag_screens(a5)
		move.l	TAG_askforexit(pc),pTAG_askforexit(a5)
		move.l	TAG_videpth(pc),pTAG_videpth(a5)
		move.l	TAG_dither(pc),pTAG_vidither(a5)
		move.l	TAG_preview(pc),pTAG_preview(a5)
		move.l	TAG_scale(pc),pTAG_scale(a5)
		move.l	TAG_Hsize(pc),pTAG_Hsize(a5)
		
		lea	prefsDisplayID(a5),a0
		lea	pprefsDisplayID(a5),a1
		move.l	#displen-1,d7
.ndis		move.b	(a0)+,(a1)+
		dbra	d7,.ndis
		
		lea	newfontname(a5),a0
		lea	pnewfontname(a5),a1
		move.l	#fonlen-1,d7
.nf:		move.b	(a0)+,(a1)+
		dbra	d7,.nf

		lea	OpScreenmode(a5),a0
		lea	pOpScreenmode(a5),a1
		moveq	#10-1,d7
.nop		move.b	(a0)+,(a1)+
		dbra	d7,.nop

		move.b	OpColMode(a5),pOpColMode(a5)


set_wait:	move.l	set_window(pc),a0
		move.l	APG_Wait(a5),a6
		jsr	(a6)				;Handle input

		cmp.l	#GADGETUP,d4
		beq.w	set_gads
		cmp.l	#CLOSEWINDOW,d4
		beq.b	set_cancel
		cmp.l	#IDCMP_VANILLAKEY,d4
		beq.w	set_tast		;es wurde eine Taste gedrückt
		bra.b	set_wait

set_tast:
		move.l	set_window(pc),aktwin(a5)
		lea	set_gadarray(pc),a0
		move.l	d5,d3
		cmp.w	#$1b,d3
		beq	set_cancel
		cmp.w	#'s',d3
		bne.b	.nosave
		lea	set_save(pc),a3
		move.l	#GD_psave,d0
		bra.w	setandjump
.nosave:
		cmp.w	#'u',d3
		bne.b	.nouse
		lea	set_use(pc),a3
		move.l	#GD_puse,d0
		bra.w	setandjump
.nouse:
		cmp.w	#'c',d3
		bne.b	.nocancel
		lea	set_cancel(pc),a3
		move.l	#GD_pcancel,d0
		bra.w	setandjump
.nocancel:		
		bra	set_wait


set_cancel:

;hole die alten Einstellungen zurück

		lea	overwrite(a5),a0	;hole die alten
		lea	pundo(a5),a1		;Einstellungen
		sub.l	a0,a1
		move.l	a1,d0
		lea	poverwrite(a5),a1
.np:		move.b	(a1)+,(a0)+
		dbra	d0,.np

		lea	TAG_showpic(pc),a0
		move.l	ptag_show(a5),(a0)
		lea	TAG_drawgrid(pc),a0
		move.l	ptad_drawgrid(a5),(a0)
		lea	TAG_autosave(pc),a0
		move.l	ptag_autosave(a5),(a0)
		lea	TAG_overwrite(pc),a0
		move.l	ptag_overwrite(a5),(a0)
		lea	TAG_iconify(pc),a0
		move.l	pTAG_iconify(a5),(a0)
		lea	TAG_screens(pc),a0
		move.l	pTag_screens(a5),(a0)
		lea	TAG_askforexit(pc),a0
		move.l	pTAG_askforexit(a5),(a0)
		lea	TAG_videpth(pc),a0
		move.l	pTAG_videpth(a5),(a0)
		lea	TAG_dither(pc),a0
		move.l	pTAG_vidither(a5),(a0)
		lea	TAG_preview(pc),a0
		move.l	pTAG_preview(a5),(a0)
		lea	TAG_scale(pc),a0
		move.l	pTAG_scale(a5),(a0)
		lea	TAG_hsize(pc),a0
		move.l	pTAG_hsize(a5),(a0)

		lea	prefsDisplayID(a5),a0
		lea	pprefsDisplayID(a5),a1
		move.l	#displen-1,d7
.ndis		move.b	(a1)+,(a0)+
		dbra	d7,.ndis

		lea	newfontname(a5),a0
		lea	pnewfontname(a5),a1
		move.l	#fonlen-1,d7
.nf:		move.b	(a1)+,(a0)+
		dbra	d7,.nf

		lea	OpScreenmode(a5),a1
		lea	pOpScreenmode(a5),a0
		moveq	#10-1,d7
.nop		move.b	(a0)+,(a1)+
		dbra	d7,.nop

		move.b	pOpColMode(a5),OpColMode(a5)

		clr.b	usepref(a5)

		tst.b	customscr(a5)
		beq.b	.nixcolor
		bsr.w	makescreencolors
.nixcolor:

set_ende
		move.l	mainwinWnd(a5),a0
		bsr.w	clearwaitpointer

		move.l	set_window(pc),a0
		move.l	APG_Intuitionbase(a5),a6
		jsr	_LVOCloseWindow(a6)

		move.l	mainwinwnd(a5),a0
		bsr.w	aktiwin

		bra.w	waitaction

;-----------------------------------------------------------------------
set_use:
		tst.b	pundo(a5)
		bne	.nodel
		bsr.l	deletetmp
		clr.l	st_akttmp(a5)
		clr.l	st_filehandle(a5)
		clr.l	st_first(a5)
		clr.w	st_overflow(a5)
		clr.l	st_lastmax(a5)
		move.l	#-1,st_lasttmp(a5)
		move.l	#1,tag_undodis
		move.l	#1,tag_redodis
		moveq	#1,d1

		move.l	gadbase(a5),a6
		lea	mainwinGadgets,a0
		move.l	GD_gundo*4(a0),a0
		move.l	mainwinWnd(a5),a1
		sub.l	a2,a2
		lea	nc_ghost(pc),a3
		move.l	d1,4(a3)
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		move.l	gadbase(a5),a6
		lea	mainwinGadgets,a0
		move.l	GD_gredo*4(a0),a0
		move.l	mainwinWnd(a5),a1
		sub.l	a2,a2
		lea	nc_ghost(pc),a3
		move.l	d1,4(a3)
		jsr	_LVOGT_SetGadgetAttrsA(a6)
.nodel:


		move.l	mainwinWnd(a5),a0
		bsr.w	clearwaitpointer

		move.l	set_window(pc),a0
		move.l	APG_Intuitionbase(a5),a6
		jsr	_LVOCloseWindow(a6)

		tst.b	newwin(a5)
		beq.b	.nofont

		bsr.w	makenewwindow
		tst.l	d0
		beq.b	.draw

		bsr.w	ClosedownScreen
		st	nogadremove(a5)	;fenster ist schon zu !!!

		clr.b	usepref(a5)
		clr.b	newwin(a5)

		bra.l	endall
.draw:
.nofont:
		tst.b	customscr(a5)
		beq.b	.nocheck
		bsr.w	checkpalette
.nocheck
		clr.b	usepref(a5)
		clr.b	newwin(a5)
		clr.b	newfont(a5)

		move.l	mainwinwnd(a5),a0
		bsr.w	aktiwin

		bra.w	waitaction

set_gads:
		moveq	#0,d7
		moveq	#0,d0
		move.w	38(a4),d0
		add.l	d0,d0
		add.l	d0,d0
		lea	prefsjumptab(pc),a0
		move.l	(a0,d0.l),d0
		jmp	(a0,d0.l)

prefsjumptab:
		dc.l	set_setshow-prefsjumptab
		dc.l	set_setgrid-prefsjumptab
		dc.l	set_autosave-prefsjumptab
		dc.l	set_exit-prefsjumptab
		dc.l	set_iconifymode-prefsjumptab
		dc.l	set_cancel-prefsjumptab
		dc.l	set_save-prefsjumptab
		dc.l	set_use-prefsjumptab
		dc.l	set_colors-prefsjumptab
		dc.l	set_cancel-prefsjumptab
		dc.l	set_screenmode-prefsjumptab
		dc.l	set_setfont-prefsjumptab
		dc.l	set_overwrite-prefsjumptab
		dc.l	set_screen-prefsjumptab
		dc.l	set_opmode-prefsjumptab
		dc.l	set_opdepth-prefsjumptab
		dc.l	set_dither-prefsjumptab
		dc.l	set_preview-prefsjumptab
		dc.l	set_scale-prefsjumptab
		dc.l	set_hsize-prefsjumptab
		dc.l	set_undo-prefsjumptab
		
		dc.l	set_cancel-prefsjumptab

	;----------------------------------;
set_undo:
		lea	pundo(a5),a2		;Don't Scale picture on Operatorscreen
		lea	TAG_pundo,a1
		clr.l	(a1)
		move.l	#GD_pundo,d0
		bra.w	set_setcheck

	;----------------------------------;
set_hsize:
		move.b	d5,Hsize(a5)
		ext.l	d5
		lea	TAG_hsize(pc),a0
		move.l	d5,(a0)

		move.l	rndr_histogram(a5),d0
		beq.w	set_wait
		move.l	d0,a0
		move.l	renderbase(a5),a6
		jsr	_LVODeleteHistogram(a6)
		clr.l	rndr_histogram(a5)
	move.b	#24,planes(a5)		;damit addrgb chunky genommen wird
	st	depthchange(a5)
		bra	set_wait

	;----------------------------------;
set_scale:
		lea	dscale(a5),a2		;Don't Scale picture on Operatorscreen
		lea	TAG_scale(pc),a1
		clr.l	(a1)
		move.l	#GD_scale,d0
		bra.w	set_setcheck
	;----------------------------------;
set_preview:
		lea	mpreview(a5),a2		;Show Pic after Load
		lea	TAG_preview(pc),a1
		clr.l	(a1)
		move.l	#GD_preview,d0
		bra.w	set_setcheck
	;----------------------------------;
set_dither:
		lea	vidither(a5),a2		;Show Pic after Load
		lea	TAG_dither(pc),a1
		clr.l	(a1)
		move.l	#GD_dither,d0
		bra.w	set_setcheck

	;----------------------------------;
set_setshow:
		lea	showpic(a5),a2		;Show Pic after Load
		lea	TAG_showpic(pc),a1
		clr.l	(a1)
		move.l	#GD_pshowpic,d0
		bra.w	set_setcheck
	;----------------------------------;
set_setgrid:
		lea	drawgrid(a5),a2		;Draw a Grid
		lea	TAG_drawgrid(pc),a1
		clr.l	(a1)
		move.l	#GD_pdrawgrid,d0
		bra.w	set_setcheck
	;----------------------------------;
set_autosave:
		lea	autosavecolor(a5),a2	;Save Colors automatisch
		lea	TAG_autosave(pc),a1
		clr.l	(a1)
		move.l	#GD_pautosavecolor,d0
		bra.w	set_setcheck
	;----------------------------------;
set_overwrite:
		lea	overwrite(a5),a2	;Überschreibe File beim Saven
		lea	TAG_overwrite(pc),a1
		clr.l	(a1)
		move.l	#GD_poverwrite,d0
		bra.w	set_setcheck
	;----------------------------------;
set_exit:
		lea	TAG_askforexit(pc),a1
		lea	askforexit(a5),a2	;
		clr.l	(a1)
		move.l	#GD_pconfirmexit,d0
		bra.w	set_setcheck
	;----------------------------------;
set_iconifymode:
		lea	TAG_iconify(pc),a0
		moveq	#2,d7
		lea	littlewin(a5),a1
		bra.w	set_setflags
	;----------------------------------;
set_colors:
		move.l	scr(a5),sf_screen
		move.l	set_window(pc),sf_window

		lea	sf_Tags(pc),a0
		lea	set_colortitle(pc),a2
		move.l	colorreq(a5),a3
		move.l	reqtbase(a5),a6
		jsr	_LVORTPaletteRequestA(a6)
		cmp.l	#-1,d0
		beq.w	set_wait

		bsr	checkpalette

		st	newwin(a5)
		
		bra.w	set_wait

set_colortitle:
		dc.b	'Choose the colors!',0

	even
;	;----------------------------------;	;frage nach Font für Screen
set_setfont:
		move.l	scr(a5),sf_screen
		move.l	set_window(pc),sf_window

		move.l	fontreq(a5),a1
		cmp.l	#0,a1
		beq.w	set_wait
		lea	sf_Title(pc),a3
		lea	sf_tags(pc),a0
		move.l	reqtbase(a5),a6
		jsr	_LVOrtFontRequestA(a6)
		tst.l	d0
		beq.w	set_wait
		
		st	newwin(a5)
		st	newfont(a5)

		move.l	fontreq(a5),a0
		lea	rtfo_Attr(a0),a0
		move.l	a0,newfontstruck(a5)
		moveq	#0,d0
		move.w	4(a0),d0
		move.w	d0,newfontheight(a5)
		move.l	(a0),a0
		move.l	a0,newfontname1(a5)
		lea	newfontname(a5),a1
.nc		move.b	(a0)+,d1
		cmp.b	#'.',d1
		beq.b	.endfontname
		move.b	d1,(a1)+
		bra.b	.nc
.endfontname:
		move.b	#'.',(a1)+

		clr.b	merk(a5)
		lea	sf_hexdeztab(pc),a2	;Tabellendisgs
		moveq	#2,d3
.Hexdez2:	move.l	(a2)+,d1		;Tabellenzahl
		moveq	#0,d2			;Zahl
.Hexdez3:	addq.l	#1,d2
		sub.l	d1,d0
		bcc.s	.Hexdez3
		add.l	d1,d0
		add.b	#$2f,d2
		tst.b	merk(a5)
		bne.b	.w1
		cmp.b	#'0',d2
		beq.b	.w
.w1		st	merk(a5)
		move.b	d2,(a1)+
.w		dbf	d3,.Hexdez2
		
		clr.b	(a1)
		
		move.l	#GD_pfont,d6
		lsl.l	#2,d6
		lea	set_gadarray(pc),a0
		move.l	(a0,d6),a0
		lea	nametext(pc),a1
		lea	newfontname(a5),a2
		move.l	a2,(a1)
		move.l	set_window(pc),a1
		sub.l	a2,a2
		lea	nametag(pc),a3
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		bra.w	set_wait


sf_Hexdeztab:	dc.l	100,10,1


sf_Tags:

		dc.l	$80000000+7		;_RT_Screen
sf_screen:	dc.l	0		
		dc.l	_rt_window
sf_window:	dc.l	0
		dc.l	RT_Reqpos,0
		dc.l	RT_LockWindow,1
		dc.l	TAG_DONE

sf_Title:
	dc.b	'Select a Font',0
	
	;----------------------------------;
set_screen:
		st	newwin(a5)
		st	newscr(a5)
		lea	TAG_screens(pc),a0
		moveq	#2,d7
		lea	workbench(a5),a1
		bra.w	set_setflags

;-----------------------------------------------------------------------

set_screenmode:
		tst.b	publicscr(a5)
		bne.w	set_choosepublic

		move.l	scr(a5),psm_screen
		move.l	set_window(pc),psm_window

		move.l	scrmodereqprefs(a5),a1
		move.l	#SCREQF_DEPTHGAD!SCREQF_SIZEGADS+SCREQF_AUTOSCROLLGAD+SCREQF_OVERSCANGAD,rtsc_Flags(a1)
		lea	sm_Title(pc),a3
		lea	psm_Tags(pc),a0
		move.l	reqtbase(a5),a6
		jsr	_LVOrtScreenModeRequestA(a6)
		tst.l	d0
		beq.w	set_wait

		move.l	scrmodereqprefs(a5),a0
		move.l	rtsc_DisplayID(a0),prefsDisplayID(a5)
		move.w	rtsc_DisplayWidth(a0),prefsdisplayWidth(a5)
		move.w	rtsc_DisplayHeight(a0),prefsDisplayHeight(a5)
		move.w	rtsc_DisplayDepth(a0),prefsDisplayDepth(a5)
		move.w	rtsc_OverscanType(a0),prefsoverscantype(a5)
		move.l	rtsc_AutoScroll(a0),prefsautoroll(a5)

		move.w	prefsDisplayDepth(a5),d0
		moveq	#1,d1
		lsl.w	d0,d1
		move.w	d1,anzmaincolors(a5)

;-------------------------------------------------------------------------
	ifne	final
		lea	lastreqcode1(pc),a0
		move.l	(a0),a0
		cmp.l	lastreqcheck1(a5),a0
		beq.b	.codeok
		move.l	(a0),reqtbase(a5)
	endc
;--------------------------------------------------------------------------
.codeok:	st	newwin(a5)
		st	newscr(a5)
		bra.w	set_wait
psm_Tags:
		dc.l	_rt_screen
psm_screen:	dc.l	0		
		dc.l	_rt_window
psm_window:	dc.l	0
		dc.l	RT_Reqpos,0
		dc.l	RT_LockWindow,1
		dc.l	TAG_DONE

;--------------------------------------------------------------------------
set_opmode
		tst.l	OpScreenmode(a5)
		beq	.nixmode

;stelle prefs mode ein

		move.l	#TAG_DONE,-(a7)
		moveq	#0,d0
		move.w	OpdisplayWidth(a5),d0
		move.l	d0,-(a7)
		move.l	#RTSC_DisplayWidth,-(a7)
		move.w	OpDisplayHeight(a5),d0
		move.l	d0,-(a7)
		move.l	#RTSC_DisplayHeight,-(a7)
		move.w	OpDisplayDepth(a5),d0
		move.l	d0,-(a7)
		move.l	#RTSC_DisplayDepth,-(a7)
		move.l	OpScreenmode(a5),-(a7)
		move.l	#RTSC_DisplayID,-(a7)
		move.l	a7,a0
		move.l	scrmodereqprefs(a5),a1
		move.l	reqtbase(a5),a6
		jsr	_LVOrtChangeReqAttrA(a6)

		lea	36(a7),a7

.nixmode:
		move.l	scr(a5),psm_screen1
		move.l	set_window(pc),psm_window1

		move.l	scrmodereqprefs(a5),a1
		move.l	#SCREQF_DEPTHGAD!SCREQF_SIZEGADS,rtsc_Flags(a1)
		lea	sm_Title(pc),a3
		lea	psm_Tags1(pc),a0
		move.l	reqtbase(a5),a6
		jsr	_LVOrtScreenModeRequestA(a6)
		tst.l	d0
		beq.w	set_wait

		move.l	scrmodereqprefs(a5),a0
		move.l	rtsc_DisplayID(a0),OpScreenmode(a5)

		move.w	rtsc_DisplayWidth(a0),OpdisplayWidth(a5)
		move.w	rtsc_DisplayHeight(a0),OpDisplayHeight(a5)
		move.w	rtsc_DisplayDepth(a0),OpDisplayDepth(a5)

		bra	set_wait

psm_Tags1:
		dc.l	_rt_screen
psm_screen1:	dc.l	0		
		dc.l	_rt_window
psm_window1:	dc.l	0
		dc.l	RT_Reqpos,0
		dc.l	RT_LockWindow,1
		dc.l	RTSC_MinDepth,4
		dc.l	RTSC_MaxDepth,24
		dc.l	TAG_DONE

;---------------------------------------------------------------
set_opdepth:
		move.b	d5,OpColMode(a5)
		ext.l	d5
		lea	TAG_videpth(pc),a0
		move.l	d5,(a0)
		bra	set_wait

;---------------------------------------------------------------
set_choosepublic:
		move.l	intbase(a5),a6
		jsr	_LVOLockPubScreenList(a6)
		move.l	d0,d6
		beq.b	cp_nopub

		jsr	_LVOUnLockPubScreenList(a6)

		move.l	d6,a0
		lea	screenreqlist,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+

		st	choosepub(a5)

		move.l	d6,-(a7)
		jsr	openscreenwin

		lea	screenwinWnd(a5),a0
		move.l	a0,window(a5)
		lea	screenwinGlist(a5),a0
		move.l	a0,Glist(a5)

		bsr.w	gt_CloseWindow

		move.l	(a7)+,d6
		cmp.l	#'CANC',d7
		beq.w	set_wait
				
		move.l	d6,a0
		move.l	(a0),a0
		
		moveq	#0,d7
		move.w	ls_screen(a5),d7

		subq.l	#1,d7
		bmi.b	cp_firstnode	;es war der erste Eintrag
.nn:		move.l	(a0),a0		;ermittle LoaderNode Adresse
		dbra	d7,.nn

cp_firstnode:
		move.l	10(a0),a0	;Name des Screens
		lea	aktpubscreen(a5),a1
.np:		move.b	(a0)+,d0
		beq.b	cp_nopub
		move.b	d0,(a1)+
		bra.b	.np
cp_nopub:
		st	newwin(a5)
		st	newscr(a5)
		clr.b	(a1)

		bra.w	set_wait

;-------------------------------------------------------------------------
set_ENVname:	dc.b	'ENV:ArtPRO',0
	even

set_save:
		lea	pSavename(a5),a0
		lea	prefsdir(pc),a1
.nn:		move.b	(a1)+,d0
		beq.b	.enddirname
		move.b	d0,(a0)+
		bra.b	.nn
.enddirname:
		clr.b	(a0)
		move.l	a0,-(a7)
		lea	pSavename(a5),a0
		move.l	a0,d1
		move.l	#ACCESS_READ,d2
		move.l	dosbase(a5),a6
		jsr	_LVOLock(a6)
		bne.b	.dirok
		
		lea	pSavename(a5),a0
		move.l	a0,d1
		jsr	_LVOCreateDir(a6)
		bne.b	.dirok
		move.l	(a7)+,a0
		lea	psavename(a5),a0
		move.b	#'s',(a0)+
		move.b	#':',(a0)+
		clr.b	(a0)
		move.l	a0,-(a7)
		bra.b	.dirok1

.dirok:
		move.l	d0,d1
		jsr	_LVOUnlock(a6)

		lea	set_ENVname(pc),a0
		move.l	a0,d1
		move.l	#ACCESS_READ,d2
		move.l	dosbase(a5),a6
		jsr	_LVOLock(a6)
		bne.b	.envok
		lea	set_ENVname(pc),a0
		move.l	a0,d1
		jsr	_LVOCreateDir(a6)
.envok:
		move.l	d0,d1
		jsr	_LVOUnlock(a6)

.dirok1:				
		move.l	(a7)+,a0
		move.b	#'/',(a0)+
		lea	prefsname(pc),a1
.nn1:		move.b	(a1)+,d0
		beq.b	.endprefsname
		move.b	d0,(a0)+
		bra.b	.nn1
.endprefsname:
		clr.b	(a0)

		lea	pSavename(a5),a0
		move.l	a0,d1
		move.l	#1006,d2	;newfile
		move.l	dosbase(a5),a6
		jsr	_LVOOpen(a6)
		move.l	d0,filehandle(a5)
		bne.b	openok

		bra.w	set_wait		;!!!!!

openok:
		lea	prefssavepuffer,a0
		move.l	a0,-(a7)
		move.l	#'ARTP',(a0)+
		move.l	#ver,(a0)+

		lea	overwrite(a5),a1	;Kopiere Prefs
		lea	words(a5),a2	;in SavePuffer
		sub.l	a1,a2
		move.l	a2,d7
.nextentry:
		move.b	(a1)+,(a0)+
		dbra	d7,.nextentry

		move.l	TAG_showpic(pc),(a0)+
		move.l	TAG_drawgrid(pc),(a0)+
		move.l	TAG_autosave(pc),(a0)+
		move.l	TAG_overwrite(pc),(a0)+
		move.l	TAG_iconify(pc),(a0)+
		move.l	TAG_screens(pc),(a0)+
		move.l	TAG_askforexit(pc),(a0)+

		move.l	prefsDisplayID(a5),(a0)+
		move.w	prefsdisplayWidth(a5),(a0)+
		move.w	prefsDisplayHeight(a5),(a0)+
		move.w	prefsDisplayDepth(a5),(a0)+
		move.w	prefsoverscantype(a5),(a0)+
		move.l	prefsautoroll(a5),(a0)+

		move.l	OpScreenmode(a5),(a0)+
		move.l	OpdisplayWidth(a5),(a0)+    ;zusammen mit Height
		move.w	OpDisplayDepth(a5),(a0)+
		move.b	OpColMode(a5),(a0)+

		clr.b	(a0)+	;reserve
		clr.l	(a0)+	;
		clr.l	(a0)+	;
		clr.l	(a0)+	;
		clr.l	(a0)+	;
		clr.l	(a0)+	;

		lea	prefspurefarbtab(a5),a1
		move.l	#256-1,d7
.nc:		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		dbra	d7,.nc

		lea	newfontname(a5),a1
.nfc:		move.b	(a1)+,d0
		beq.b	.endfont
		move.b	d0,(a0)+	;speicher Fontname
		bra.b	.nfc
.endfont:
		clr.b	(a0)+
		move.w	newfontheight(a5),d0
		move.b	d0,(a0)+
		
		lea	aktpubscreen(a5),a1
.nps:		move.b	(a1)+,d0
		beq.b	.endpub
		move.b	d0,(a0)+
		bra.b	.nps
.endpub:
		clr.b	(a0)+

		move.l	(a7)+,d5
		sub.l	d5,a0
		move.l	a0,d3		;Länge der Prefs
		move.l	d3,d5
		move.l	filehandle(a5),d1
		lea	prefssavepuffer,a0
		move.l	a0,d2
		jsr	_LVOWrite(a6)

		move.l	filehandle(a5),d1
		jsr	_LVOClose(a6)

		lea	pSavename(a5),a0
		cmp.l	#'ENVA',(a0)
		bne.b	.w

		lea	dirENVname,a0
		move.l	a0,d1
		move.l	#1006,d2	;newfile
		jsr	_LVOOpen(a6)
		move.l	d0,filehandle(a5)
		beq.b	.w

		move.l	d5,d3
		move.l	filehandle(a5),d1
		lea	prefssavepuffer,a0
		move.l	a0,d2
		jsr	_LVOWrite(a6)

		move.l	filehandle(a5),d1
		jsr	_LVOClose(a6)
.w

		bra	set_use
;		bra.w	set_wait

;--------------------------------------------------------------------------
set_holegadaddr:
		lea	set_gadarray(pc),a0
		lsl.l	#2,d0			;Bestimme Adresse der
		move.l	(a0,d0.l),a0		;Gadgetadresse
		rts

set_setcheck:
		bsr.b	set_holegadaddr
		clr.b	(a2)
		move.w	gg_Flags(a0),d0
		and.w	#SELECTED,d0
		beq.w	set_wait	;nicht selected
		st	(a2)
		move.l	#1,(a1)
		bra.w	set_wait

set_setflags:
		move.l	a1,a2
.nc:
		clr.b	(a1)+
		dbra	d7,.nc
		ext.l	d5
		move.b	#1,(a2,d5.l)
		move.l	d5,(a0)
		bsr.b	set_checkghost
		bra.w	set_wait


set_checkghost:
		moveq	#0,d1
		tst.b	workbench(a5)
		beq.b	.nixwb
		moveq	#1,d1
.nixwb
		moveq	#GD_psetscreen,d0
		bsr.b	set_ghost

		moveq	#1,d1
		tst.b	custmerk(a5)
		beq.b	.nixcust
		tst.b	customscr(a5)
		beq.b	.nixcust
		moveq	#0,d1
.nixcust:
		moveq	#GD_psetcolors,d0
		bra.w	set_ghost

set_ghost:
		lea	doghost(pc),a0
		move.l	d1,(a0)
		lsl.l	#2,d0
		lea	set_gadarray(pc),a0
		move.l	(a0,d0),a0
		move.l	set_window(pc),a1
		sub.l	a2,a2
		lea	ghosttag(pc),a3
		move.l	gadbase(a5),a6
		jmp	_LVOGT_SetGadgetAttrsA(a6)
		
ghosttag:
		dc.l	GA_Disabled
doghost:	dc.l	0
		dc.l	TAG_DONE

;--------------------------------------------------------------------------
Prefs_CNT		=	21


GD_pshowpic		=	0
GD_pdrawgrid		=	1
GD_pautosavecolor	=	2
GD_pconfirmexit		=	3
GD_piconifymode		=	4
GD_pcancel		=	5
GD_psave		=	6
GD_puse			=	7
GD_psetcolors		=	8
GD_pfont		=	9
GD_psetscreen		=	10
GD_psetfont		=	11
GD_poverwrite		=	12
GD_pscreen		=	13
GD_vimode		=	14
GD_videpth		=	15
GD_dither		=	16
GD_preview		=	17
GD_scale		=	18
GD_Histo		=	19
GD_pundo		=	20

set_window:	ds.l	1
set_Glist:	ds.l	1
set_gadarray:	ds.l	Prefs_CNT

set_GTypes:
		dc.w	CHECKBOX_KIND
		dc.w	CHECKBOX_KIND
		dc.w	CHECKBOX_KIND
		dc.w	CHECKBOX_KIND
		dc.w	CYCLE_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	TEXT_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	CHECKBOX_KIND
		dc.w	CYCLE_KIND
		dc.w	BUTTON_KIND
		dc.w	CYCLE_KIND
		dc.w	CHECKBOX_KIND
		dc.w	CHECKBOX_KIND
		dc.w	CHECKBOX_KIND
		dc.w	CYCLE_KIND
		dc.w	CHECKBOX_KIND

set_NGads:
		dc.w	25,26,26,11
		dc.l	pdisplaypicText,0
		dc.w	GD_pshowpic
		dc.l	PLACETEXT_RIGHT,0,0
		dc.w	25,38+2,26,11
		dc.l	pdrawgridText,0
		dc.w	GD_pdrawgrid
		dc.l	PLACETEXT_RIGHT,0,0
		dc.w	25,82+14,26,11
		dc.l	pautosavepalText,0
		dc.w	GD_pautosavecolor
		dc.l	PLACETEXT_RIGHT,0,0
		dc.w	25,50+4,26,11
		dc.l	pconfirmexitText,0
		dc.w	GD_pconfirmexit
		dc.l	PLACETEXT_RIGHT,0,0
		dc.w	294,28,103,13
		dc.l	piconifyText,0
		dc.w	GD_piconifymode
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	306,112+15+20+5+12+9+15,92,14
		dc.l	pcancelText,0
		dc.w	GD_pcancel
		dc.l	PLACETEXT_IN,0,0
		dc.w	25,112+15+20+5+12+9+15,92,14
		dc.l	psaveText,0
		dc.w	GD_psave
		dc.l	PLACETEXT_IN,0,0
		dc.w	165,112+15+20+5+12+9+15,92,14
		dc.l	puseText,0
		dc.w	GD_puse
		dc.l	PLACETEXT_IN,0,0
		dc.w	207,75,191,13
		dc.l	padjustpalText,0
		dc.w	GD_psetcolors
		dc.l	PLACETEXT_IN,0,0
		dc.w	206,43,134,13
		dc.l	0,0
		dc.w	GD_pfont
		dc.l	0,0,0
		dc.w	342,58,55,13
		dc.l	psetscreenText,0
		dc.w	GD_psetscreen
		dc.l	PLACETEXT_IN,0,0
		dc.w	342,43,55,13
		dc.l	psetfontText,0
		dc.w	GD_psetfont
		dc.l	PLACETEXT_IN,0,0
		dc.w	25,62+6,26,11
		dc.l	poverwriteText,0
		dc.w	GD_poverwrite
		dc.l	PLACETEXT_RIGHT,0,0
		dc.w	206,58,133,13
		dc.l	0,0
		dc.w	GD_pscreen
		dc.l	0,0,0
		dc.w	25,105+12+14,100,13
		dc.l	vimodeText,0
		dc.w	GD_vimode
		dc.l	PLACETEXT_IN,0,0

		dc.w	160,105+12+14,100,13
		dc.l	videpthText,0
		dc.w	GD_videpth
		dc.l	PLACETEXT_BELOW,0,0

		dc.w	25,147+5,26,11
		dc.l	vidithertext,0
		dc.w	GD_dither
		dc.l	PLACETEXT_RIGHT,0,0
		dc.w	25,82,26,11
		dc.l	previewText,0
		dc.w	GD_preview
		dc.l	PLACETEXT_RIGHT,0,0

		dc.w	25,147+5+15,26,11
		dc.l	scaletext,0
		dc.w	GD_scale
		dc.l	PLACETEXT_RIGHT,0,0

		dc.w	284,150,120,13
		dc.l	histotext,0
		dc.w	GD_histo
		dc.l	PLACETEXT_ABOVE,0,0

		dc.w	207,92,26,11
		dc.l	pundoText,0
		dc.w	GD_pundo
		dc.l	PLACETEXT_RIGHT,0,0


set_GTags:

GA_showpic:	dc.l	GTCB_Checked
TAG_showpic:	dc.l	0
		dc.l	GTCB_Scaled,1
		dc.l	TAG_DONE
GA_drawgrid:	dc.l	GTCB_Checked
TAG_drawgrid:	dc.l	1
		dc.l	GTCB_Scaled,1
		dc.l	TAG_DONE
GA_autosave:	dc.l	GTCB_Checked
TAG_autosave:	dc.l	0
		dc.l	GTCB_Scaled,1
		dc.l	TAG_DONE
GA_askforexit:	dc.l	GTCB_Checked
TAG_askforexit:	dc.l	0
		dc.l	GTCB_Scaled,1
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,iconifyLabels
GA_iconify:	dc.l	GTCY_ACTIVE
TAG_iconify:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	GTTX_Text,newfontname+daten
		dc.l	GTTX_Border,1
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	TAG_DONE
GA_overwrite:	dc.l	GTCB_Checked
TAG_overwrite:	dc.l	1
		dc.l	GTCB_Scaled,1
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,pscreenLabels
GA_screens:	dc.l	GTCY_ACTIVE
TAG_screens:	dc.l	0
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,videpthLabels
GA_videpth:	dc.l	GTCY_ACTIVE
TAG_videpth:	dc.l	0
		dc.l	TAG_DONE
GA_dither:	dc.l	GTCB_Checked
TAG_dither:	dc.l	0
		dc.l	GTCB_Scaled,1
		dc.l	TAG_DONE
GA_preview:	dc.l	GTCB_Checked
TAG_preview:	dc.l	1
		dc.l	GTCB_Scaled,1
		dc.l	TAG_DONE
GA_scale:	dc.l	GTCB_Checked
TAG_scale:	dc.l	0
		dc.l	GTCB_Scaled,1
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,histoLabels
GA_hdepth:	dc.l	GTCY_ACTIVE
TAG_hsize:	dc.l	0
		dc.l	TAG_DONE
GA_pundo:	dc.l	GTCB_Checked
TAG_pundo:	dc.l	1
		dc.l	GTCB_Scaled,1
		dc.l	TAG_DONE

	
pdisplaypicText:dc.b	'Display Picture',0
pdrawgridText:	dc.b	'Draw Grid',0
pautosavepalText:dc.b	'Autosave Pal.',0
pconfirmexitText:dc.b	'Confirm Exit',0
piconifyText:	dc.b	'Iconify to',0
pcancelText:	dc.b	'_Cancel',0
psaveText:	dc.b	'_Save',0
puseText:	dc.b	'_Use',0
padjustpalText:	dc.b	'Adjust Palette',0
psetscreenText:	dc.b	'Set',0
psetfontText:	dc.b	'Font',0
poverwriteText:	dc.b	'Conf. Overwrite',0
vimodeText:	dc.b	'Screenmode',0
videpthtext:	dc.b	'Colormode',0
vidithertext:	dc.b	'dither image',0
previewText:	dc.b	'Show Preview',0
scaletext:	dc.b	"don't scale image",0
histotext:	dc.b	'Histogram size',0
pundoText:	dc.b	'Enable Undo',0
	even
	
iconifyLabels:
		dc.l	iconifyLab0
		dc.l	iconifyLab1
		dc.l	iconifyLab2
		dc.l	0

pscreenLabels:
		dc.l	pscreenLab0
		dc.l	pscreenLab1
		dc.l	pscreenLab2
		dc.l	0

videpthLabels:
		dc.l	vilab0
		dc.l	vilab1
		dc.l	0
		
histoLabels:
		dc.l	hdepthlab0
		dc.l	hdepthlab1
		dc.l	hdepthlab2
		dc.l	hdepthlab3
		dc.l	hdepthlab4
		dc.l	0


iconifyLab0:	dc.b	'Window',0
iconifyLab1:	dc.b	'App Icon',0
iconifyLab2:	dc.b	'Toolmenu',0

    CNOP    0,2

pscreenLab0:	dc.b	'Workbench',0
pscreenLab1:	dc.b	'PublicScreen',0
pscreenLab2:	dc.b	'CustomScreen',0

    CNOP    0,2

vilab0:		dc.b	'gray',0
vilab1:		dc.b	'color',0

    CNOP    0,2

hdepthlab0:	dc.b	'12 Bit',0
hdepthlab1:	dc.b	'15 Bit',0
hdepthlab2:	dc.b	'18 Bit',0
hdepthlab3:	dc.b	'21 Bit',0
hdepthlab4:	dc.b	'24 Bit',0

	even
set_WindowTags:
set_winL:	dc.l	WA_Left,0
set_winT:	dc.l	WA_Top,0
set_winW:	dc.l	WA_Width,0
set_winH:	dc.l	WA_Height,0
		dc.l	WA_IDCMP,IDCMP_VANILLAKEY!CHECKBOXIDCMP!CYCLEIDCMP!BUTTONIDCMP!IDCMP_GADGETDOWN!IDCMP_MOUSEMOVE!IDCMP_CLOSEWINDOW!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_CLOSEGADGET!WFLG_DEPTHGADGET!WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_SMART_REFRESH!WFLG_RMBTRAP

set_winWG:
		dc.l	WA_Gadgets,0
		dc.l	WA_Title,set_WTitle
set_winSC:
		dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

set_WTitle:
		dc.b	'ArtPRO Settings',0
    CNOP    0,2

set_Text0:
		dc.b	2,0
		dc.b	RP_JAM1
		dc.b	0
		dc.w	300,12
		dc.l	0
		dc.l	set_IText0
		dc.l	0

set_Text1:
		dc.b	2,0
		dc.b	RP_JAM1
		dc.b	0
		dc.w	77+20,12
		dc.l	0
		dc.l	set_IText1
		dc.l	0
set_Text2:
		dc.b	2,0
		dc.b	RP_JAM1
		dc.b	0
		dc.w	140,120
		dc.l	0
		dc.l	set_IText2
		dc.l	0
set_Text3:
		dc.b	2,0
		dc.b	RP_JAM1
		dc.b	0
		dc.w	345,120
		dc.l	0
		dc.l	set_IText3
		dc.l	0

set_IText0:	dc.b	'System',0
set_IText1:	dc.b	'Global',0
set_IText2:	dc.b	'Operator Screen',0
set_IText3:	dc.b	'Histogram',0
	even

;***************************************************************************
;*------------------- Gebe Meldung über Programm aus ----------------------*
;***************************************************************************
about:
		move.l	mainwinWnd(a5),a1
		move.l	a1,a0
		bsr.w	setwaitpointer
		
		lea	aboutmsg,a1
		lea	okmsg,a2
		sub.l	a3,a3
		sub.l	a4,a4
		lea	tagitemliste1,a0
		move.l	reqtbase(a5),a6
		jsr	_LVOrtEZRequestA(a6)

		tst.l	d0
		bne.w	.wech

		cmp.b	#14,check1(a5)
		beq.b	.re
		lea	keymsg,a1
		lea	key1msg,a2
.draw		sub.l	a3,a3
		sub.l	a4,a4
		lea	tagitemliste1,a0
		move.l	reqtbase(a5),a6
		jsr	_LVOrtEZRequestA(a6)
		bra.w	.wech

.re:
		cmp.w	#302,finalcheck(a5)
		bne.w	.wech
		lea	keymsgpuffer(a5),a0
		lea	reqmsg,a1
		move.l	#reqmsglen-1,d7
.nm:		move.b	(a1)+,(a0)+
		dbra	d7,.nm
		
		lea	vorname(a5),a1
		lea	name(a5),a2
		moveq	#0,d0
		moveq	#0,d3
		move.b	(a1)+,d0	;länge
		move.b	(a2)+,d3
		move.l	d0,d2
		moveq	#45,d1
		sub.l	d0,d1
		sub.l	d3,d1
		lsr.l	#1,d1
		subq.l	#1,d1
.np	;	move.b	#32,(a0)+
		dbra	d1,.np
		subq.l	#1,d0
.nw		move.b	(a1)+,(a0)+
		dbra	d0,.nw
		move.b	#32,(a0)+
		subq.l	#1,d3
.nw1		move.b	(a2)+,(a0)+
		dbra	d3,.nw1
		move.b	#10,(a0)+
		lea	strasse(a5),a1
		bsr.b	ab_copy
		lea	ort(a5),a1
		bsr.b	ab_copy
		lea	plz(a5),a1
		bsr.b	ab_copy
		lea	staat(a5),a1
		bsr.b	ab_copy

		move.b	#10,(a0)+
		
		lea	usernummermsg(pc),a1
		moveq	#45,d1
		sub.l	#19,d1
		lsr.l	#1,d1
		subq.l	#1,d1
.np2	;	move.b	#32,(a0)+
		dbra	d1,.np2
		moveq	#12-1,d0
.nw2		move.b	(a1)+,(a0)+
		dbra	d0,.nw2

		moveq	#0,d0
		move.w	usernummer(a5),d0
		move.l	a0,-(a7)
		lea	usepuffer,a0
		bsr.w	hexdez
		move.l	(a7)+,a0
		lea	usepuffer+2(pc),a1
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		clr.b	(a0)

		lea	keymsgpuffer(a5),a1
		lea	thanxmsg,a2
		bra.w	.draw
.wech:
		move.l	mainwinWnd(a5),a1
	;	bsr.b	gadson
		move.l	a1,a0
		bsr.w	clearwaitpointer
		
		bra.l	waitaction

ab_copy:
		moveq	#0,d0
		move.b	(a1)+,d0	;länge
		move.l	d0,d2
		moveq	#45,d1
		sub.l	d0,d1
		lsr.l	#1,d1
		subq.l	#1,d1
.np1	;	move.b	#32,(a0)+
		dbra	d1,.np1
		subq.l	#1,d0
.nw1		move.b	(a1)+,(a0)+
		dbra	d0,.nw1
		move.b	#10,(a0)+
		rts

usernummermsg:	dc.b	'Usernumber: '

;=====================================================================
;    ------------------       Iconify       -----------------------
;======================================================================
iconify:
		clr.b	nogadremove(a5)
		
		bsr.w	checkmainwinpos
		move.w	d0,mainx(a5)
		move.w	d1,mainy(a5)

		bsr.w	deleteappwindow

		lea	MainwinWnd(a5),a0
		move.l	a0,window(a5)
		lea	MainwinGlist(a5),a0
		move.l	a0,Glist(a5)
		bsr.w	gt_CloseWindow

	;	bsr.w	ClosemainwinWindow

		bsr.w	ClosedownScreen

		tst.b	littlewin(a5)
		bne.b	ic_littlewin
		tst.b	_appicon(a5)
		bne.w	ic_appicon
		tst.b	appitem(a5)
		bra.w	ic_appItem


ic_littlewin:
		bsr.w	checkwbsize
		move.l	wbfontstruck(a5),a0
		moveq	#0,d0
		move.w	4(a0),d0		;Fonthöhe
		addq.l	#3,d0
		move.l	d0,ic_height+4
		move.l	d0,ic_top+4
		move.l  IntBase(a5),a6
		suba.l  a0,a0
		lea	ic_left(pc),a1
		jsr	_LVOOpenWindowTagList(a6)
		move.l  d0,ic_Wnd(a5)
		tst.l   d0
		beq.w	ic_openallagain
.w
		move.l	ic_Wnd(a5),a0
		bsr.l	wait

		clr.b	merk2(a5)
		cmp.w	#IDCMP_Closewindow,d4
		bne.b	.nowech
		move.b	#5,merk2(a5)
		move.b	#1,nogadremove(a5)	;beim verlassen brauchen keine

		tst.b	askforexit(a5)
		beq.b	.nowech

		lea	exitmsg,a1
		lea	exitmsg1,a2
		sub.l	a3,a3
		sub.l	a4,a4
	;	lea	tagitemliste1,a0
		sub.l	a0,a0
		move.l	reqtbase(a5),a6
		jsr	_LVOrtEZRequestA(a6)
		tst.l	d0
		beq.b	.w

.nowech		
		move.l	ic_Wnd(a5),a0
		move.l	Intbase(a5),a6
		jsr	_LVOCloseWindow(a6)

		tst.b	merk2(a5)
		bne.l	endall
		bra.w	ic_openallagain

;--------- Erzeuge ein AppMenuItem ---------------
ic_appItem:
	;	bsr.w	opnewblib
	;	tst.l	d0
	;	beq.w	ic_openallagain		;waitaction

		move.l	4,a6
		jsr	_LVOCreatemsgPort(a6)
		move.l	d0,msgport(a5)
		beq.b	.closewb

		lea	MenuItemName(pc),a0
		move.l	msgport(a5),a1
		sub.l	a2,a2
		moveq	#0,d0
		moveq	#0,d1
		move.l	wbbase(a5),a6
		jsr	_LVOAddAppMenuItemA(a6)
		move.l	d0,itemstruck(a5)
		beq.b	.closeport

.ic_waitagain:
		move.l	msgport(a5),a0
		move.l	4.w,a6
		jsr	_LVOWaitport(a6)

		move.l	msgport(a5),a0
		jsr	_LVOGetmsg(a6)
		tst.l	d0
		beq.b	.ic_waitagain

		move.l	d0,a1			;muss nach a1
		move.w	20(a1),d4		;Msg-Type
;		move.l	im_Code(a1),d5		;Untergruppe
		jsr	_LVOreplyMsg(a6)	;quittiere Msg in a1
		
;		cmp.w	#MTYPE_APPMENUITEM,d4

		move.l	itemstruck(a5),a0
		move.l	wbbase(a5),a6
		jsr	_LVORemoveAppMenuItem(a6)
		
.closeport:
		move.l	msgport(a5),a0
		move.l	4.w,a6
		jsr	_LVODeleteMsgPort(a6)
.closewb:
	;	bsr.w	closewblib
		bra.w	ic_openallagain
		
;--------- Erzeuge ein AppIcon ---------------
ic_appicon:

;checke Tooltypes

		sf	merk1(a5)
		clr.l	free1(a5)
		clr.l	free2(a5)
		clr.l	free3(a5)
		
		lea	iconlibname(pc),a1
		moveq	#0,d0
		move.l	4.w,a6
		jsr	_LVOOpenlibrary(a6)
		move.l	d0,free1(a5)		
		beq.w	ic_standart	;keine Iconlib --> öffne normales Icon
		move.l	d0,a6
		
		move.l	programdirlock(a5),d1

		lea	cb_farbtab4,a3
		move.l	a3,d2
		move.l	#260*2,d3
		move.l	dosbase(a5),a6
		jsr	_LVONameFromLock(a6)	;hole Dir Name aus dem wir 
		tst.l	d0			;gestartet wurden
		beq.b	ic_standart

		move.l	a3,a1
.w		tst.b	(a1)+
		bne.b	.w

		subq.l	#2,a1
		cmp.b	#':',(a1)+
		beq.b	.noslash
		move.b	#'/',(a1)+
.noslash:
		move.l	WBMessage(a5),d0
		beq.b	.nowb
		move.l	d0,a0
		move.l	sm_ArgList(a0),a0
		move.l	wa_Name(a0),a0


.nz:		move.b	(a0)+,d0
		beq.b	.ze
		move.b	d0,(a1)+
		bra.b	.nz
.ze:		clr.b	(a1)+

		bra.b	.geticon
		
.nowb:		move.l	a1,d1
		move.l	#200,d2
		jsr	_LVOGetProgramName(a6)
		tst.l	d0
		beq.b	ic_standart

.geticon
		move.l	a3,a0

		move.l	free1(a5),a6	;Iconlib
		jsr	_LVOGetDiskObject(a6)

		move.l	d0,free2(a5)	;Unser Icon merken
		beq.b	ic_standart	;Kein Icon gefunden

		move.l	d0,a0
		move.l	do_tooltypes(a0),a0
		lea	ic_pathtypename,a1
		jsr	_LVOFindTooltype(a6)		

		tst.l	d0
		beq.b	ic_standart

		move.l	d0,a0
		jsr	_LVOGetDiskObject(a6)
		tst.l	d0
		beq.b	ic_standart	;Eigenes AppIcon nicht gefunden
		move.l	d0,free3(a5)
		st	merk1(a5)	;neues AppIcon Benutzen

ic_standart:
	;	bsr.w	opnewblib
	;	tst.l	d0
	;	beq.w	ic_openallagain		;waitaction

		move.l	4,a6
		jsr	_LVOCreatemsgPort(a6)
		move.l	d0,msgport(a5)
		beq.b	.closewb

		moveq	#0,d0
		moveq	#0,d1
		lea	MenuItemName(pc),a0
		move.l	msgport(a5),a1
		sub.l	a2,a2
		lea	diskobjektstruck(pc),a3
		tst.b	merk1(a5)
		beq.b	.wi
		move.l	free3(a5),a3	;neues AppIcon
.wi		sub.l	a4,a4
		move.l	wbbase(a5),a6
		jsr	_LVOAddAppIconA(a6)
		move.l	d0,itemstruck(a5)
		beq.b	.closeport

.ic_waitagain:
		move.l	msgport(a5),a0
		move.l	4,a6
		jsr	_LVOWaitport(a6)

		move.l	msgport(a5),a0
		jsr	_LVOGetmsg(a6)
		tst.l	d0
		beq.b	.ic_waitagain

		move.l	d0,a1			;muss nach a1
		move.w	20(a1),d4		;Msg-Type
		move.l	30(a1),d5		;im_NumArgs
		jsr	_LVOreplyMsg(a6)	;quittiere Msg in a1

		tst.l	d5
		bne.b	.ic_waitagain

		move.l	itemstruck(a5),a0
		move.l	wbbase(a5),a6
		jsr	_LVORemoveAppIcon(a6)

.closeport:
		move.l	msgport(a5),a0
		move.l	4,a6
		jsr	_LVODeleteMsgPort(a6)
.closewb:
	;	bsr.w	closewblib

		move.l	lastcurrentdirlock(a5),d1
		move.l	dosbase(a5),a6
		jsr	_LVOCurrentDir(a6)

		move.l	free2(a5),d0
		beq.b	.w1
		move.l	d0,a0
		move.l	free1(a5),a6
	;	jsr	_LVOFreeDiskObject(a6)

.w1:		move.l	free1(a5),d0
		beq.b	.w
		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOCloseLibrary(a6)
.w		
;----------------------------------------------------------------------
ic_openallagain:			;Stelle alles wieder her
		bsr.w	setupscreen
		tst.l	d0
		bne.l	endall
		
		move.l	scr(a5),d0
		move.l	d0,rt_screen
		move.l	d0,rt_screen1

		moveq	#0,d0
		move.l	scr(a5),a0
		move.l	40(a0),a0
		move.w	4(a0),d0		;Fonthöhe
		addq.l	#3,d0
		move.w	d0,zoomheight

		clr.b	fontallready(a5)
		st	iconifyflag(a5)
		lea	MainwinWindowTags,a0
		move.l	a0,windowtaglist(a5)
		lea	MainwinWG+4,a0
		move.l	a0,gadgets(a5)
		lea	MainwinSC+4,a0
		move.l	a0,winscreen(a5)
		lea	MainwinWnd(a5),a0
		move.l	a0,window(a5)
		lea	MainwinGlist(a5),a0
		move.l	a0,Glist(a5)
		lea	MainwinNgads,a0
		move.l	a0,NGads(a5)
		lea	MainwinGTypes,a0
		move.l	a0,GTypes(a5)
		lea	MainwinGadgets,a0
		move.l	a0,WinGadgets(a5)
		move.w	#Mainwin_CNT,win_CNT(a5)
		lea	MainwinGtags,a0
		move.l	a0,windowtags(a5)
		move.l	scr(a5),screenbase(a5)

		move.w	#mainwinWidth,WinWidth(a5)
		move.w	#mainwinHeight,WinHeight(a5)
		move.w	#mainwinTop,WinTop(a5)
		move.w	#mainwinLeft,WinLeft(a5)
		lea	MainWinL,a0
		move.l	a0,WinL(a5)
		lea	MainWinT,a0
		move.l	a0,WinT(a5)
		lea	MainWinW,a0
		move.l	a0,WinW(a5)
		lea	MainWinH,a0
		move.l	a0,WinH(a5)

		move.w	mainx(a5),d0
		move.w	mainy(a5),d1
		add.w	#mainwinLeft,d0
		add.w	#mainwinTop,d1

		move.w	d1,WinTop(a5)
		move.w	d0,WinLeft(a5)

		bsr.w	openwindowF	;öffne Mainwindow
		tst.l	d0
		beq.b	.ok
		jsr	endall
.ok		bsr.w	mainwinRender

		bsr.w	makeappwindow

		tst.b	customscr(a5)
		beq.b	.nocust
		bsr.w	makescreencolors
.nocust:

.nd:
		move.l	mainwinwnd(a5),a0
		move.l	a0,rt_window
		move.l	a0,rt_window1
		
		move.l	50(a0),mainRastport(a5) ;Rastport sichern
		move.l 	mainwinWnd(a5),a0
		move.l  IntBase(a5),a6
		jsr     _LVOViewPortAddress(a6)
		move.l	d0,Uviewport(a5)

ic_makegads:
		move.l	loadername(a5),d5
		move.l	#GD_gloader,d6
		bsr.w	setnewname
		move.l	savername(a5),d5
		move.l	#GD_gsaver,d6
		bsr.w	setnewname
		move.l	operatorname(a5),d5
		move.l	#GD_geffect,d6
		bsr.w	setnewname
		
		bsr.l	imageandgagetset

		lea	welcombackmsg(pc),a4
		bsr.w	status

		move.l	#'ICON',d7	;damit cutflag nicht gelöscht wird
		bsr.w	setpicsizegads	;Set Länge und Breit neu

		move.l	#GD_gxbrush,d0
		move.l	bxsize(a5),d1
		bsr.w	setnumber

		move.l	#GD_gybrush,d0
		move.l	bysize(a5),d1
		bsr.w	setnumber
		
;		move.l	TAG_brushsize,d1
;		move.l	#GD_gbrushsize,d0
;		bsr.w	setnumber

;		move.l	kwords(a5),d1
;		move.l	#GD_gwords,d0
;		bsr.w	setnumber

;		bsr.w	setmodi

		move.b	iconifyflag(a5),d0
		sf	iconifyflag(a5)

		cmp.b	#-6,d0		;wurden wir vom Zip gadget aufgerufen
		beq.l	wartenmainwin

		bra.l	waitaction		;waitaction
opnewblib:
		lea	wbname(pc),a1
		moveq	#0,d0
		move.l	4.w,a6
		jsr	_LVOOpenlibrary(a6)
		move.l	d0,wbbase(a5)
		rts
closewblib:
		move.l	wbbase(a5),a1
		move.l	4.w,a6
		jsr	_LVOCloselibrary(a6)
		clr.l	wbbase(a5)
		rts
		
ic_pathtypename:
		dc.b	'APPICON',0

iconlibname:	dc.b	'icon.library',0
wbname:		dc.b	'workbench.library',0
MenuItemName:	dc.b	'ArtPRO',0
	even
	
ic_left:	dc.l	WA_Left,0
ic_Top:		dc.l	WA_Top,0
ic_width:	dc.l	WA_Width,180
ic_height:	dc.l	WA_Height,0
		dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_SMART_REFRESH!WFLG_DRAGBAR!WFLG_DEPTHGADGET!WFLG_CLOSEGADGET
		dc.l	WA_Gadgets,0
		dc.l	WA_ScreenTitle,mainwinSTitle
		dc.l	WA_Title,ic_title
		dc.l	WA_Zoom,zoomtab
		dc.l	TAG_DONE

zoomtab:	dcb.w	8,0

ic_title:
		dc.b	'ArtPRO V'
		version
		dc.b	0
	even		

appiconimagestruck1:
		dc.w	0,0
		dc.w	86,38
		dc.w	2	
		dc.l	appiconimage1
		dc.b	$0003,$0000
		dc.l	0
appiconimagestruck2:
		dc.w	0,0
		dc.w	86,38
		dc.w	2	
		dc.l	appiconimage2
		dc.b	$0003,$0000
		dc.l	0
		
diskobjektstruck:
		dc.w	0,0

		dc.l	0
		dc.w	0,0
		dc.w	86,38
		dc.w	GADGHIMAGE
		dc.w	0,0
		dc.l	appiconimagestruck1
		dc.l	appiconimagestruck2
		dc.l	0,0,0
		dc.w	0
		dc.l	0

		dc.w	0
		dc.l	0,0
		dc.l	$80000000,$80000000	;No_icon_position
		dc.l	0,0,0
		

;***************************************************************************
;*----------------------- Wähle neuen Monitor aus -------------------------*
;***************************************************************************
changemoni:
		clr.b	merk1(a5)
changemoni1:
		move.l	mainwinWnd(a5),a1
	tst.b	merk1(a5)
	bne.w	.no
		move.l	a1,a0
	;	bsr.w	setwaitpointer
.no

		move.l	scr(a5),sm_screen
		move.l	mainwinwnd(a5),sm_window

		move.l	scrmodereq(a5),a1
		lea	sm_Title(pc),a3
		lea	sm_Tags(pc),a0
		move.l	reqtbase(a5),a6
		jsr	_LVOrtScreenModeRequestA(a6)
		tst.l	d0
		bne.b	sm_selectok
		lea	noscreenmsg(pc),a4
		bsr.w	status
		move.l	mainwinWnd(a5),a1
	;	bsr.w	gadson
		move.l	a1,a0
		bsr.w	clearwaitpointer
		tst.b	merk1(a5)
		beq.l	waitaction
		rts

sm_selectok:
		move.l	scrmodereq(a5),a0
		move.l	rtsc_DisplayID(a0),DisplayID(a5)
;		move.w	rtsc_DisplayWidth(a0),displayWidth(a5)
;		move.w	rtsc_DisplayHeight(a0),DisplayHeight(a5)
;		move.w	rtsc_DisplayDepth(a0),DisplayDepth(a5)
;		move.w	rtsc_OverscanType(a0),d0
;		move.l	rtsc_AutoScroll(a0),d0

	tst.b	Merk1(a5)
	bne	.no
		move.l	mainwinWnd(a5),a1
	;	bsr.w	gadson
		move.l	a1,a0
		bsr.w	clearwaitpointer
.no		
;Berichtige Gadget
		bsr.w	setmodi

;-------------------------------------------------------------------------
	ifne	final
		lea	lastreqcode1(pc),a0
		move.l	(a0),a0
		cmp.l	lastreqcheck1(a5),a0
		beq.b	.codeok
		move.l	(a0),reqtbase(a5)
	endc
;--------------------------------------------------------------------------
.codeok:	st	firstmode(a5)
		tst.b	merk1(a5)
		beq.l	waitaction
		rts
sm_Tags:

	dc.l	$80000000+7		;_RT_Screen
sm_screen:	dc.l	0		
		dc.l	_rt_window
sm_window:	dc.l	0
		dc.l	RT_Reqpos,0
		dc.l	RT_LockWindow,1
;	dc.l	RTSC_PropertyFlags,$0
;	dc.l	RTSC_PropertyMask,$0

;	dc.l	RTSC_Flags,SCREQF_DEPTHGAD+SCREQF_SIZEGADS+SCREQF_AUTOSCROLLGAD+SCREQF_OVERSCANGAD
	dc.l	TAG_DONE

sm_Title:
	dc.b	'Select a Screenmode',0

;==========================================================================
;---------- Lock Monitor --------------
;==========================================================================
lockmon:
		moveq	#0,d0
		clr.b	lockcheck(a5)
		move.b	check1(a5),d0
		add.w	finalcheck(a5),d0
		cmp.w	locktest(a5),d0
lo_test:	beq.s	.ok			;gecrackt !!!!!!!!!!!!!

		lea	locktag(pc),a3
		move.l	mainwinWnd(a5),a1
		sub.l	a2,a2
		move.l	#GD_glockmon,d0
		lsl	#2,d0
		lea	mainwinGadgets,a0
		move.l	(a0,d0),a0
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
		
		lea	lockmsg-5520,a1
		lea	key1msg-1520,a2
		move.l	#_LVOrtEZRequestA*8,d0
		asr.l	#3,d0
		sub.l	a3,a3
		sub.l	a4,a4
		lea	tagitemliste1,a0
		move.l	reqtbase(a5),a6
		lea	5520(a1),a1
		lea	1520(a2),a2
		jsr	(a6,d0.l)
		bra.l	waitaction
.ok:
		lea	TAG_check,a1
		clr.l	(a1)
		move.l	#GD_glockmon,d0
		lsl	#2,d0
		lea	mainwinGadgets,a0
		move.l	(a0,d0),a0
		move.w	gg_Flags(a0),d0
		and.w	#SELECTED,d0
		bne.s	.w
		clr.b	firstmode(a5)
		bra.l	waitaction
.w		move.b	locktest+1(a5),lockcheck(a5)
		move.l	#1,(a1)
		bra.l	waitaction


locktag:	dc.l	GTCB_Checked,0
		dc.l	TAG_DONE

;***************************************************************************
;*-------------------- Gebe aktuellen ScreenMode aus ----------------------*
;***************************************************************************
setmodi:
		lea	_PAL(a5),a0
		moveq	#9-1,d7
.n:
		move.b	#0,(a0)+	;lösche alle monitore
		dbra	d7,.n
		move.l	#0,scale(a5)

		clr.b	nocut(a5)

;-------------------------------------------------------------------------
	ifne	final
		lea	lastreqcode(pc),a0
		move.l	(a0),a0
		cmp.l	lastreqcheck(a5),a0
		beq.b	.codeok
		move.l	(a0),reqtbase(a5)
	endc
;--------------------------------------------------------------------------

.codeok:
		move.l	displayID(a5),a0
		lea	rect(pc),a1
		move.l	#OSCAN_STANDARD,d0
		move.l	intbase(a5),a6
		jsr	_LVOQueryOverscan(a6)

		lea	rect(pc),a0
		move.w	4(a0),d0
		addq.w	#1,d0
		move.w	d0,displayWidth(a5)
		move.w	6(a0),d0
		addq.w	#1,d0
		move.w	d0,DisplayHeight(a5)
		

		moveq	#32+16,d0
		move.l	#DTAG_NAME,d1
		move.l	displayID(a5),d2
		lea	mo_Itext,a1
		sub.l	a0,a0
		move.l	gfxbase(a5),a6
		jsr	_LVOGetDisplayInfoData(a6)
		
		tst.l	d0
		beq.b	mo_writemodeid

mo_textout:
		lea	mo_Itext+16,a0
		move.l	a0,TAG_monitor
		move.l	a0,d5
		move.l	#GD_gmonitor,d6
		bra.w	setnewname

mo_writemodeid:
		move.l	displayID(a5),d0
		bsr.w	hexascii
		lea	mo_Itext+16,a0
		lea	mo_distext(pc),a1
		moveq	#mo_dislen,d7
.nm		move.b	(a1)+,(a0)+
		dbra	d7,.nm

		lea	zpuff(pc),a1
		moveq	#8-1,d7
.nm1		move.b	(a1)+,(a0)+
		dbra	d7,.nm1

		clr.b	(a0)
		bra.b	mo_textout

mo_distext:	dc.b	'ModeID = 0x'
mo_dislen	=	*-mo_distext-1

	even
;--------------------------------------------------------------------
;----- Stelle Monitor ein - wird von dem Externen Loadern aufgerufen
;--------------------------------------------------------------------
checkmoni:
		tst.b	lockcheck(a5)
		beq.b	.nolock
		tst.b	firstmode(a5)
		bne.b	.we
.nolock:
		move.l	PicModeID(a5),DisplayID(a5)
		bsr.w	setmodi

		st	firstmode(a5)
.we
		rts

;--------------------------------------------------------------------
;---- versuche aus den Pic Daten einen Monitor auszuwählen --
;--------------------------------------------------------------------
findmonitor:
		movem.l	d0-a6,-(a7)
		tst.b	lockcheck(a5)
		beq.b	.nolock
		tst.b	firstmode(a5)
		bne.b	fm_wech
.nolock:
		move.l	cyberbase(a5),d0
		bne	fm_findcyber

		move.l	#$21000,DisplayID(a5)
		tst.b	kick3(a5)
		beq.b	fm_end
		lea	fm_width+4(pc),a0
		moveq	#0,d0
		move.w	breite(a5),d0
		move.l	d0,(a0)
		lea	fm_height+4(pc),a0
		move.w	hoehe(a5),d0
		move.l	d0,(a0)
		moveq	#0,d0
		move.b	planes(a5),d0
		cmp.b	#24,d0
		blo	.w
		moveq.l	#4,d0
.w		lea	fm_Depth+4(pc),a0
		move.l	d0,(a0)
		lea	fm_flags+4(pc),a0
		clr.l	(a0)
		move.b	ham(a5),d0
		add.b	ham8(a5),d0
		tst.b	d0
		beq.b	.noham
		move.l	#DIPF_IS_HAM,(a0)
.noham:
		move.l	gfxbase(a5),a6
		lea	fm_taglist(pc),a0
		jsr	_LVOBestModeIDA(a6)
		cmp.l	#INVALID_ID,d0
		beq.b	fm_end
		move.l	d0,DisplayID(a5)
fm_end:
		bsr.w	setmodi
		st	firstmode(a5)
fm_wech:
		movem.l	(a7)+,d0-a6
		rts

fm_findcyber:
		move.l	d0,a6
		lea	fm_cwidth+4(pc),a0
		moveq	#0,d0
		move.w	breite(a5),d0
		move.l	d0,(a0)
		lea	fm_cheight+4(pc),a0
		move.w	hoehe(a5),d0
		move.l	d0,(a0)
		moveq	#0,d0
		move.b	planes(a5),d0
		move.b	ham(a5),d5
		add.b	ham8(a5),d5
		tst.b	d5
		beq.b	.noham
		moveq	#24,d0
.noham:
		lea	fm_cDepth+4(pc),a0
		move.l	d0,(a0)

		lea	fm_cybertag(pc),a0
		jsr	_LVOBestCModeIDTagList(a6)
		cmp.l	#INVALID_ID,d0
		beq.b	fm_end
		move.l	d0,DisplayID(a5)
		bra	fm_end

fm_taglist:
fm_width:	dc.l	BIDTAG_NominalWidth,0
fm_height:	dc.l	BIDTAG_NominalHeight,0
fm_Depth:	dc.l	BIDTAG_Depth,0
fm_flags:	dc.l	BIDTAG_DIPFMustHave,0
		dc.l	0
		
fm_cybertag:
fm_cwidth:	dc.l	CYBRBIDTG_NominalWidth,0
fm_cheight:	dc.l	CYBRBIDTG_NominalHeight,0
fm_cDepth:	dc.l	CYBRBIDTG_Depth,0
		dc.l	TAG_DONE


;***************************************************************************
;*------------------ Verändere Anzahl der Farbe mit Dither ----------------*
;***************************************************************************
;		transformiert 24Bit-RGB Longword in drei Bytes für R,G,B
;
;		c24to3Byte dx,dy,dz
;
;	>	dx.l	24Bit-Source
;	<	dx.l	r
;	<	dy.l	g
;	<	dz.l	b

c24to3Byte	macro
		move.l	\1,\2
		and.l	#$0000ff00,\2
		lsr.l	#8,\2
		move.l	\1,\3
		and.l	#$000000ff,\3
		and.l	#$00ff0000,\1
		swap	\1
		endm
changecolors:
		bra.l	waitaction
		rts

;======================================================================
makeoperator:
		tst.w	loadflag(a5)
		beq.l	waitaction

		move.l	Operatornode(a5),a0
		tst.l	NC_PREFSROUT(a0)
		beq.b	.noprefs
		move.l	NC_PREFSORIBUF(a0),a1
		move.l	NC_PREFSLEN(a0),d7
		subq.w	#1,d7
		lea	NC_PREFS(a0),a0
.np		move.b	(a0)+,(a1)+
		dbra	d7,.np
.noprefs:
		move.l	mainwinwnd(a5),a0
;		bsr	setwaitpointer

		move.l	Operator(a5),a0
		jsr	(a0)		;Springe Operoutine an

		cmp.l	#'NOCL',d7
		beq	.nc
		move.l	mainwinwnd(a5),a0
;		bsr	clearwaitpointer
.nc
		bsr.l	clearprocess


;		move.l	mainwinwnd(a5),a0
;		bsr.l	clearwaitpointer
;		bra.w	waitaction
;

		cmp.l	#APOE_OK,d3
		bne	.w
		lea	readymsg(pc),a4
		jsr	status
		bra.l	waitaction
.w		
		cmp.l	#APOE_NOMEM,d3
		bne.b	.ww2
		lea	notmemmsg,a4
		jsr	status
.ww2
		cmp.l	#APOE_ABORT,d3
		bne.b	.na
		lea	operatorabortmsg(pc),a4
		jsr	status
.na
		cmp.l	#APOE_NOIMAGE,d3
		bne.b	.ni
		lea	noimageload,a4
		jsr	status
.ni
		bra.l	waitaction

operatorabortmsg:	dc.b	'Operator stopped!',0
	even
;======================================================================
;------ Palette ---- Palette editor
;======================================================================
pal_noscreenmsg:dc.b	'Can',39,'t open controlscreen in this mode!',0
pal_no24msg:	dc.b	'No Palette with 24 Bit images!',0
	even
palette:
		tst.w	loadflag(a5)
		bne.b	.lok		;Es wurde was geladen
		lea	noimageload,a4
		jsr	status		;kein Bild geladen
		bra.l	waitaction

.lok:
		cmp.b	#24,APG_Planes(a5)
		bne	.pok
		lea	pal_no24msg(pc),a4
		jsr	status
		bra.l	waitaction
.pok:
		sf	merk1(a5)	;Flag ob remapt wurde

		move.b	ham(a5),cbhammerk(a5)
		move.b	ham8(a5),d0
		add.b	d0,cbhammerk(a5)

		sf	Toflag(a5)
		lea	colorpuffer1,a0		;Palette backupen
		lea	farbtab8(a5),a1
		move.l	(a1)+,d7
		move.l	d7,(a0)+
		swap	d7
;		move.w	anzcolor(a5),d7
		subq.w	#1,d7
.nc		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		dbra	d7,.nc
		clr.l	(a0)+
						
		clr.b	merk(a5)	;das Pic wird nur angeschaut
		bsr.w	openpic
		cmp.l	#-1,d0
		beq.l	waitaction
		
		move.l	scr1(a5),a0
		move.l	intbase(a5),a6
		jsr	_LVOScreentoFront(a6)

		bsr.w	checkoverscan
		clr.l	scale(a5)
		moveq	#-5,d7	;merker das wir von Palette aufgerufen wurden
		lea	ptype,a0
		bsr.w	checkmode
pal_openit:		
		move.l	scale(a5),d1
		lsr.l	d1,d5		;Berechen Anfangshöhe des Screens
		sub.l	#58+3,d5
		move.l	d5,ptop	

		moveq	#0,d0
		move.b	planes(a5),d0
		cmp.b	#1,d0
		bne.b	.w1
		moveq	#2,d0
.w1		addq.w	#1,d0
		cmp.w	#5,d0
		bls.b	.w
		moveq	#5,d0
.w		move.l	d0,pdepth

		moveq	#0,d7
		bsr.w	setuppalscreen
		tst.l	d0
		beq.b	.screenok
		bsr.l	CloseViewWindow
		bsr.l	closedownviewscreen
		lea	pal_noscreenmsg(pc),a4
		bsr.w	status
		bra.l	waitaction
.screenok:
		lea	palwinWindowTags,a0
		move.l	a0,windowtaglist(a5)
		lea	palwinWG+4,a0
		move.l	a0,gadgets(a5)
		lea	palwinSC+4,a0
		move.l	a0,winscreen(a5)
		lea	palwinWnd1(a5),a0
		move.l	a0,window(a5)
;		lea	palwinGlist1(a5),a0
;		move.l	a0,Glist(a5)
;		lea	palwinNgads1,a0
;		move.l	a0,NGads(a5)
;		lea	palwinGTypes1,a0
;		move.l	a0,GTypes(a5)
;		lea	palwinGadgets1,a0
;		move.l	a0,WinGadgets(a5)
;		move.w	#palwin1_CNT,win_CNT(a5)
;		lea	palwinGtags1,a0
;		move.l	a0,windowtags(a5)
		move.l	scr4(a5),screenbase(a5)

		move.l	#'NOGA',d7
		bsr.w	openwindow
		tst.l	d0
		beq.b	.winok
		moveq	#0,d7
		bsr.w	closedownpalscreen
		bsr.l	CloseViewWindow
		bsr.l	CloseDownViewScreen
		bra.l	waitaction

.winok:
		bsr.w	checkoverscan
		clr.l	scale(a5)
		moveq	#0,d7	
		lea	ptype1,a0
		bsr.w	checkmode
pal_openit1:		
		move.l	scale(a5),d1
		lsr.l	d1,d5		;Berechen Anfangshöhe des Screens
		sub.l	#44,d5
		move.l	d5,ptop1

		moveq	#-1,d7
		bsr.w	setuppalscreen
		tst.l	d0
		beq.b	.screenok
		lea	palwinWnd1(a5),a0
		move.l	a0,window(a5)
		lea	palwinGlist1(a5),a0
		move.l	a0,Glist(a5)
		move.l	#'NOGA',d7
		jsr	gt_CloseWindow
		moveq	#0,d7
		bsr.w	closedownpalscreen
		bsr.l	CloseViewWindow
		bsr.l	CloseDownViewScreen
		lea	pal_noscreenmsg(pc),a4
		bsr.w	status
		bra.l	waitaction
.screenok:
		move.l	scr5(a5),a0
		sub.l	a1,a1
		move.l	gadbase(a5),a6
		jsr	_LVOGetVisualInfoA(a6)
		move.l	visualinfo(a5),tmpvisual(a5)
		move.l	d0,visualinfo(a5)

		lea	palwinWindowTags1,a0
		move.l	a0,windowtaglist(a5)
		lea	palwinWG1+4,a0
		move.l	a0,gadgets(a5)
		lea	palwinSC1+4,a0
		move.l	a0,winscreen(a5)
		lea	palwinWnd2(a5),a0
		move.l	a0,window(a5)
		lea	palwinGlist2(a5),a0
		move.l	a0,Glist(a5)
		lea	palwinNgads2,a0
		move.l	a0,NGads(a5)
		lea	palwinGTypes2,a0
		move.l	a0,GTypes(a5)
		lea	palwinGadgets2,a0
		move.l	a0,WinGadgets(a5)
		move.w	#palwin2_CNT,win_CNT(a5)
		lea	palwinGtags2,a0
		move.l	a0,windowtags(a5)
		move.l	scr5(a5),screenbase(a5)
		moveq	#0,d7
		bsr.w	openwindow
		bsr.w	palwinRender
		move.l	palwinWnd2(a5),a0
		move.l	50(a0),free4(a5)	;Rastport

;Make Palette einträge
;Setze Palette
		move.l  PalwinWnd1(a5),a0
		move.l  IntBase(a5),a6
		jsr     _LVOViewPortAddress(a6)
		move.l	d0,free1(a5)	;Viewport

		bsr.w	pal_setnewrange1

		move.l  PalwinWnd2(a5),a0
		move.l  IntBase(a5),a6
		jsr     _LVOViewPortAddress(a6)
		move.l	d0,free5(a5)	;Viewport

;zuerst die Borders

		move.l	palwinWnd1(a5),a0
		move.l	50(a0),a4	;Rastport
		move.l	a4,free2(a5)
		moveq	#1+1,d2
		moveq	#4,d3
		moveq	#0,d7
		move.w	anzcolor(a5),d7
		cmp.w	#32,d7
		blo.b	.bw
		moveq	#28,d7
.bw		subq.w	#1,d7
		lea	palcol1(pc),a0
		move.b	#2,(a0)
		lea	palcol2(pc),a0
		move.b	#1,(a0)
.nborder:	
		lea	palstruck,a1
		move.l	d2,d0
		move.l	d3,d1
		move.l	a4,a0
		move.l	intbase(a5),a6
		jsr	_LVODrawBorder(a6)
		add.w	#11,d2
		dbra	d7,.nborder

;Jetzt die Farben:
		moveq	#0,d7
		move.w	anzcolor(a5),d7
		cmp.w	#32,d7
		blo.b	.w
		moveq	#28,d7
.w		subq.w	#1,d7
		moveq	#4,d4
		moveq	#1+1,d5
		moveq	#9+1,d6
		move.l	gfxbase(a5),a6

.ncolor:	move.l	d4,d0
		move.l	a4,a1
		jsr	_LVOSetAPen(a6)
		
		move.l	a4,a1
		move.l	d5,d0
		move.l	#4,d1
		move.l	d6,d2
		move.l	#8+3,d3
		jsr	_LVORectFill(a6)

		addq.w	#1,d4
		add.w	#11,d5
		add.w	#11,d6
		dbra	d7,.ncolor


		bsr.w	pal_setmaker

;--- Wähle zu letzt angewählte Farbe an ---

		move.l	TAG_colorsys,d5
		bsr.w	pal_setsystem

;setze Palette range slider
		move.l	coloroffset(a5),d0

		move.l	#GD_pal_rangeslider,d1
		bsr.w	pal_setrangeslider

		bsr.w	pal_setrangeinfo

;		move.l	aktcolor(a5),d3
;		add.l	coloroffset(a5),d3
		move.l	realaktcolor(a5),d3

		lea	farbtab8+4(a5),a0
		mulu	#12,d3
		add.l	d3,a0
		move.l	(a0)+,d0
		rol.l	#8,d0
		move.l	(a0)+,d1
		rol.l	#8,d1
		move.l	(a0)+,d2
		rol.l	#8,d2

		move.l	d0,pal_aktred(a5)
		move.l	d1,pal_aktgreen(a5)
		move.l	d2,pal_aktblue(a5)

		move.l	d0,pal_undored(a5)
		move.l	d1,pal_undogreen(a5)
		move.l	d2,pal_undoblue(a5)
		
		tst.b	usergb(a5)
		bne.b	.w3
.w0:		tst.b	usecmy(a5)
		beq.b	.we
		bsr.w	pal_rgb2cmy
.we:		tst.b	usehsv(a5)
		beq.b	.w1
		bsr.w	pal_rgb2hsv
.w1		tst.b	useyuv(a5)
		beq.b	.w2
		bsr.w	pal_rgb2yuv
.w2		tst.b	useyiq(a5)
		beq.b	.w3
		bsr.w	pal_rgb2yiq
.w3
		move.l	d0,redlevel(a5)
		move.l	d1,greenlevel(a5)
		move.l	d2,bluelevel(a5)
		move.l	d1,d4
		move.l	d2,d5

		move.w	#GD_pal_red,d1
		bsr.w	pal_setslider
		move.l	d4,d0
		move.w	#GD_pal_green,d1
		bsr.w	pal_setslider
		move.l	d5,d0
		move.w	#GD_pal_blue,d1
		bsr.w	pal_setslider

		moveq	#4,d0
		move.l	free4(a5),a1
		move.l	gfxbase(a5),a6
		jsr	_LVOSetAPen(a6)
		
		move.l	free4(a5),a1
		move.l	#237+2,d0
		move.l	#17+1,d1
		move.l	#56-4+237+1,d2
		move.l	#24-4+17+2,d3
		jsr	_LVORectFill(a6)

;setze Farbe
		move.l	pal_aktred(a5),d1	;Lese aktuelle farbe aus
		move.l	pal_aktgreen(a5),d2
		move.l	pal_aktblue(a5),d3
		move.l	free5(a5),a0
		moveq	#4,d0

	tst.b	kick3(a5)
	bne	.wr

		lsr.w	#4,d1
		lsr.w	#4,d2
		lsr.w	#4,d2
		jsr	_LVOSetRGB4(a6)
		bra	.k2

.wr
		ror.l	#8,d1
		ror.l	#8,d2
		ror.l	#8,d3
		jsr	_LVOSetRGB32(a6)

;mäch border
.k2		move.l	realaktcolor(a5),d4
		move.l	coloroffset(a5),d1
		move.l	aktcolor(a5),d0

		cmp.w	d1,d4
		blo.b	.noset	;angewählte Farbe ist nicht zu sehen
		add.w	#27,d1
		cmp.w	d1,d4
		bhi.b	.noset

		move.l	d4,d0
		sub.l	coloroffset(a5),d0
		mulu	#11,d0
		addq.w	#1,d0
		move.l	d0,free3(a5)
		moveq	#0,d7
		bsr.w	makeborder

;setze Numbergadget
.noset:
		lea	pal_numbertags(pc),a3
;		move.l	aktcolor(a5),d0
;		add.l	coloroffset(a5),d0
		move.l	realaktcolor(a5),4(a3)

		move.l	palwinWnd2(a5),a1
		sub.l	a2,a2
		move.l	#GD_pal_number,d0
		lsl.l	#2,d0
		lea	palwingadgets2,a0
		move.l	(a0,d0.w),a0
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		tst.b	cbhammerk(a5)
		beq.b	.noghost	;pick gadget ghosten wenn ham

		move.l	#GD_pal_pick,d0
		lsl.l	#2,d0
		lea	palwingadgets2,a0
		move.l	(a0,d0),a0
		move.l	palwinWnd2(a5),a1
		sub.l	a2,a2
		lea	ghosttag(pc),a3
		moveq	#1,d1
		move.l	d1,4(a3)
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
		
.noghost:
;------------------------------------------------------------------------
;I/O Handling
;Init MsgPort
		move.l	PalwinWnd1(a5),a0
		move.l	WD_UserPort(a0),a0	:MSGPort
		move.l	a0,WinMsgPort1(a5)

	*--------------- SignalBits setzen ---------------*
		moveq	#0,d6
		moveq	#0,d0
		move.b	15(a0),d0
		bset	d0,d6

		move.l	palwinWnd2(a5),a0
		move.l	WD_UserPort(a0),a0
		move.l	a0,WinMsgPort2(a5)

	*--------------- SignalBits setzen ---------------*
		moveq	#0,d0
		move.b	15(a0),d0
		bset	d0,d6

		move.l	ViewWnd(a5),a0
		move.l	WD_UserPort(a0),a0
		move.l	a0,WinMsgPort3(a5)

	*--------------- SignalBits setzen ---------------*
		moveq	#0,d0
		move.b	15(a0),d0
		bset	d0,d6
		move.l	d6,SignalBits(a5)

	*--------------------- Wait ---------------------*
pal_Wait:	move.l	SignalBits(a5),d0
		or.w	#$1000,d0		;Break-Signal
		move.l	4.w,a6
		jsr	_LVOWait(a6)

	*------- War es ein UserMessage ------*
		move.l	WinMsgPort1(a5),d2
		beq.s	.NoPort
		move.l	d2,a0
		moveq	#0,d1
		move.b	15(a0),d1
		btst	d1,d0
		bne.b	pal_WartenWinPort1	;Palettewindow

	*----- war es eine Window-Message ----*
.NoPort:	move.l	WinMsgPort2(a5),d2
		beq.s	.NoMain
		move.l	d2,a0
		move.b	15(a0),d1
		btst	d1,d0
		bne.b	pal_WartenWinPort2
.NoMain:
		move.l	WinMsgPort3(a5),d2
		beq.s	.NoView
		move.l	d2,a0
		move.b	15(a0),d1
		btst	d1,d0
		bne.b	pal_WartenWinPort3
.NoView:	bra.b	pal_Wait

pal_Warten:	
pal_WartenWinPort1:
		move.l	WinMsgPort1(a5),d0
		beq.s	pal_WartenWinPort2
		move.l	d0,a0
		move.l	gadbase(a5),a6
		jsr	_LVOGT_getimsg(a6)
		tst.l	d0
		beq.b	pal_WartenWinPort2
		bra.b	pal_WindowMessage1

pal_WartenWinPort2:
		move.l	WinMsgPort2(a5),d0
		beq.b	pal_WartenWinPort3
		move.l	d0,a0
		move.l	gadbase(a5),a6
		jsr	_LVOGT_getimsg(a6)
		tst.l	d0
		beq.b	pal_WartenWinPort3
		bra.b	pal_WindowMessage2

pal_WartenWinPort3:
		move.l	WinMsgPort3(a5),d0
		beq.b	pal_Wait
		move.l	d0,a0
		move.l	gadbase(a5),a6
		jsr	_LVOGT_getimsg(a6)
		tst.l	d0
		beq.w	pal_Wait
		bra.b	pal_WindowMessage3

pal_WindowMessage1:
		move.l	d0,a1			;muss nach a1
		move.l	im_Class(a1),d4		;Msg-Type
		move.w	im_Code(a1),d5		;Untergruppe
		move.l	im_IAddress(a1),a4	;Adr. für Gadgets
		move.l	gadbase(a5),a6
		jsr	_LVOGT_replyiMsg(a6)	;quittiere Msg in a1

		cmp.l	#IDCMP_MOUSEMOVE,d4
		beq.w	pal_mouse
		cmp.l	#VANILLAKEY,d4
		beq.w	pal_keys		;es wurde eine Taste gedrückt
		cmp.l	#IDCMP_MouseButtons,d4
		beq.w	pal_pressbutton
		bra.b	pal_warten
		
pal_WindowMessage2:
		move.l	d0,a1			;muss nach a1
		move.l	im_Class(a1),d4		;Msg-Type
		move.w	im_Code(a1),d5		;Untergruppe
		move.l	im_Seconds(a1),d6	;Systemzeit
		move.l	im_IAddress(a1),a4	;Adr. für Gadgets
		move.l	gadbase(a5),a6
		jsr	_LVOGT_replyiMsg(a6)	;quittiere Msg in a1

		cmp.l	#VANILLAKEY,d4
		beq.w	pal_keys		;es wurde eine Taste gedrückt
		cmp.l	#GADGETdown,d4
		beq.w	pal_slider	;Es wurde ein Slidergadet gedrückt
		cmp.l	#GADGETUP,d4
		beq.w	pal_gads
		cmp.l	#IDCMP_MouseButtons,d4
		beq.b	pal_pressbutton1
		bra.w	pal_warten

pal_WindowMessage3:
		move.l	d0,a1			;muss nach a1
		move.l	im_Class(a1),d4		;Msg-Type
		move.w	im_Code(a1),d5		;Untergruppe
		move.l	gadbase(a5),a6
		jsr	_LVOGT_replyiMsg(a6)	;quittiere Msg in a1

		cmp.l	#IDCMP_MouseButtons,d4
		beq.b	pal_pressbutton1
		cmp.l	#VANILLAKEY,d4
		beq.w	pal_keys		;es wurde eine Taste gedrückt
		bra.w	pal_warten
		
pal_pressbutton1:
		cmp.w	#Menudown,d5
		bne.w	pal_warten

;screens nach hinten

		move.l	intbase(a5),a6
		move.l	scr4(a5),a0
		jsr	_LVOScreentoBack(a6)
		move.l	scr5(a5),a0
		jsr	_LVOScreentoBack(a6)

		move.l	viewWnd(a5),a0
		bsr.w	aktiwin

.w		move.l	viewWnd(a5),a0
		bsr.l	wait

		cmp.l	#IDCMP_MouseButtons,d4
		bne.b	.w

		cmp.w	#Menudown,d5
		bne.b	.w

		move.l	intbase(a5),a6
		move.l	scr4(a5),a0
		jsr	_LVOScreentoFront(a6)
		move.l	scr5(a5),a0
		jsr	_LVOScreentoFront(a6)

		move.l	palwinWnd2(a5),a0
		bsr.w	aktiwin

		bra.w	pal_warten


pal_pressbutton
		cmp.w	#Menudown,d5
		beq.b	pal_pressbutton1
pal_mouse:
		move.l	scr4(a5),a0
		moveq	#0,d0
		moveq	#0,d1
		move.w	16(a0),d1	;MouseY
		move.w	18(a0),d0	;MouseX

		divu	#11,d0
		move.w	anzcolor(a5),d2
		subq.w	#1,d2
		cmp.w	d2,d0
		bhi.w	pal_wait
		cmp.w	#28,d0
		beq.w	pal_wait
		ext.l	d0
		move.l	d0,aktcolor(a5)

		move.l	d0,-(a7)
		move.l	free3(a5),d0
		moveq	#1,d1
		moveq	#-1,d7
		bsr.w	makeborder
		move.l	(a7)+,d0
pal_wart
		mulu	#11,d0
		addq.w	#1,d0
		move.l	d0,free3(a5)	;Letzten eintrag merken
		moveq	#0,d7
		bsr.w	makeborder

		move.l	aktcolor(a5),d6
		add.l	coloroffset(a5),d6
		move.l	d6,realaktcolor(a5)

		bsr.w	pal_setbigcolor
				
		lea	pal_numbertags(pc),a3
		move.l	d6,4(a3)
		move.l	palwinWnd2(a5),a1
		sub.l	a2,a2
		move.l	#GD_pal_number,d0
		lsl.l	#2,d0
		lea	palwingadgets2,a0
		move.l	(a0,d0.w),a0
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
				
		move.l	pal_aktred(a5),pal_undored(a5)
		move.l	pal_aktgreen(a5),pal_undogreen(a5)
		move.l	pal_aktblue(a5),pal_undoblue(a5)

		bsr.w	pal_setaktslider	;setzte slider auf aktuellen
						;wert
		tst.b	toflag(a5)
		beq.w	pal_wait
		cmp.b	#1,toflag(a5)
		beq.w	pal_dospread
		cmp.b	#2,toflag(a5)
		beq.w	pal_docopy
		cmp.b	#3,toflag(a5)
		beq.w	pal_doswap
		bra.w	pal_wait
		
;--- Werte Gadgets aus ---
pal_gads:
		move.w	38(a4),d0
		cmp.w	#GD_pal_ok,d0
		beq.w	pal_ende	;beende Programm
		cmp.w	#GD_pal_colorsystem,d0
		beq.w	pal_newcolorsystem
		cmp.w	#GD_pal_undo,d0
		beq.w	pal_undo
		cmp.w	#GD_pal_reset,d0
		beq.w	pal_reset
		cmp.w	#GD_pal_spread,d0
		beq.w	pal_spread
		cmp.w	#GD_pal_copy,d0
		beq.w	pal_copy
		cmp.w	#GD_pal_swap,d0
		beq.w	pal_swap
		cmp.w	#GD_pal_remap,d0
		beq.w	pal_remap
		cmp.w	#GD_pal_sort,d0
		beq.w	pal_sort
		cmp.w	#GD_pal_pick,d0
		beq.w	pal_pick
		bra.w	pal_wait

;--------------------------------------------------------------
pal_keys:
		move.l	palwinWnd2(a5),aktwin(a5)
		lea	palwinGadgets2,a0
		move.l	d5,d3
		cmp.w	#'o',d3
		bne.b	.nook
		lea	pal_ende(pc),a3
		move.l	#GD_pal_ok,d0
		bra.l	setandjump
.nook:
		cmp.w	#'u',d3
		bne.b	.noundo
		lea	pal_undo(pc),a3
		move.l	#GD_pal_undo,d0
		bra.l	setandjump
.noundo:
		cmp.w	#'r',d3
		bne.b	.noreset
		lea	pal_reset(pc),a3
		move.l	#GD_pal_reset,d0
		bra.l	setandjump
.noreset:
		cmp.w	#'s',d3
		bne.b	.nospread
		lea	pal_spread(pc),a3
		move.l	#GD_pal_spread,d0
		bra.l	setandjump
.nospread:
		cmp.w	#'c',d3
		bne.b	.nocopy
		lea	pal_copy(pc),a3
		move.l	#GD_pal_copy,d0
		bra.l	setandjump
		bra.w	pal_wait
.nocopy:
		cmp.w	#'w',d3
		bne.b	.noswap
		lea	pal_swap(pc),a3
		move.l	#GD_pal_swap,d0
		bra.l	setandjump
.noswap:
		cmp.w	#'p',d3
		bne.b	.noremap
		lea	pal_remap(pc),a3
		move.l	#GD_pal_remap,d0
		bra.l	setandjump
.noremap:
		cmp.w	#'t',d3
		bne.b	.nosort
		lea	pal_sort(pc),a3
		move.l	#GD_pal_sort,d0
		bra.l	setandjump
.nosort:
		bra.w	pal_wait
;-----------------------------------------------------------------
pal_slider:
		move.w	38(a4),d0
		cmp.w	#GD_pal_red,d0
		beq.b	pal_setred
		cmp.w	#GD_pal_green,d0
		beq.b	pal_setgreen
		cmp.w	#GD_pal_blue,d0
		beq.b	pal_setblue
		cmp.w	#GD_pal_rangeslider,d0
		beq.b	pal_setnewrange
		bra.w	pal_wait

pal_sliderwait:
		move.l	palwinWnd2(a5),a0
		bsr.l	wait		;Warte auf eingabe im Prefswin

		cmp.l	#GADGETUP,d4
		beq.b	pal_sliderend	;Slidergadet wurde losgelassen

		cmp.l	#IDCMP_MOUSEMOVE,d4
		beq.b	pal_slider
		bra.b	pal_sliderwait

pal_sliderend:
		move.l	viewWnd(a5),a0	;aktiviere ViewWin wenn Slider
		bsr.w	aktiwin		;loßgelassen wurde für GFX-Karten

		bra.w	pal_wait
		

;---- Lese ersten (Red) Slider aus und setzte den neuen Wert -----
pal_setred:
		ext.l	d5
		move.l	d5,redlevel(a5)
		bsr.w	pal_convertandset
		bra.b	pal_sliderwait
pal_setgreen:
		ext.l	d5
		move.l	d5,greenlevel(a5)
		bsr.w	pal_convertandset
		bra.b	pal_sliderwait
pal_setblue:
		ext.l	d5
		move.l	d5,bluelevel(a5)
		bsr.w	pal_convertandset
		bra.b	pal_sliderwait
		
;=======================================================================
;---- Setzte Palette range neu -----------
pal_setnewrange:
		ext.l	d5
		move.l	d5,coloroffset(a5)

;alte makierung entfernen

		move.l	free3(a5),d0
		moveq	#1,d1
		moveq	#-1,d7
		bsr.w	makeborder

		move.l	realaktcolor(a5),d0
		move.l	d0,d2
		move.l	coloroffset(a5),d1
		sub.l	d1,d0
		bmi.b	.nonewborder
		add.w	#27,d1
		cmp.w	d1,d2
		bhi.b	.nonewborder
		
		mulu	#11,d0
		addq.w	#1,d0
		move.l	d0,free3(a5)	;Letzten eintrag merken
		moveq	#0,d7
		bsr.w	makeborder

.nonewborder:
		bsr.b	pal_setnewrange1
		bsr.w	pal_setmaker
		bra.w	pal_sliderwait

;setzte Colors in palette screen
pal_setnewrange1:

		lea	colorpuffer1+4,a0
		lea	cb_farbtab8,a1
		move.l	a1,a2
		moveq	#0,d7
		move.w	anzcolor(a5),d7
		cmp.w	#32,d7
		blo.b	.ok
		moveq	#28,d7
.ok:		move.w	d7,(a1)+	;Anz Farben in Farbtab
		move.w	#4,(a1)+      ;erste Farbe die eingetragen werden soll
		subq.w	#1,d7
		move.l	coloroffset(a5),d0
		mulu	#12,d0
		lea	(a0,d0),a0

.nc		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra	d7,.nc
		clr.l	(a1)

		move.l	a2,a1
		move.l	free1(a5),a0	;Viewport
		move.l	gfxbase(a5),a6

		tst.b	kick3(a5)
		bne	.kickok

		bsr	pal_setcolor4
		bra.w	pal_setrangeinfo


.kickok:	jsr	_LVOLoadrgb32(a6)
		bra.w	pal_setrangeinfo


pal_setcolor4:
		move.l	a1,a2

		move.l	a0,a3		;Viewport merken
		move.l	(a2)+,d7
		move.w	d7,d6		;erste farbe die eingetragen werden soll
		swap	d7		;anzahlfarben
		move.l	d7,d5		;für loadrgb4 vorbereiten
		subq.w	#1,d7

.nc		move.l	(a2)+,d1
		move.l	(a2)+,d2
		move.l	(a2)+,d3
		
		rol.l	#8,d1
		rol.l	#8,d2
		rol.l	#8,d3
		lsr.w	#4,d1
		lsr.w	#4,d2
		lsr.w	#4,d3
	
		move.l	d6,d0

		move.l	a3,a0
		jsr	_LVOSetrgb4(a6)
		
		addq.w	#1,d6
		dbra	d7,.nc
		rts		


pal_setrangeinfo:
		move.l	coloroffset(a5),d0
		lea	usepuffer(pc),a0
		bsr.w	hexdez		

		lea	pal_rangetext+6(pc),a4
		move.l	a3,a0
		addq.l	#5,a0
		move.b	(a0)+,(a4)+
		move.b	(a0)+,(a4)+
		move.b	(a0)+,(a4)+
		move.b	#' ',(a4)+
		move.w	#'to',(a4)+
		move.b	#' ',(a4)+

		move.w	anzcolor(a5),d0
		cmp.w	#32,d0
		blo.b	.w
		move.l	coloroffset(a5),d0
		add.w	#28,d0
.w		subq.w	#1,d0
		move.l	a3,a0
		bsr.w	hexdez
		addq.l	#5,a3
		move.b	(a3)+,(a4)+
		move.b	(a3)+,(a4)+
		move.b	(a3)+,(a4)+

		lea	pal_rangetag(pc),a3
		move.l	palwinWnd2(a5),a1
		sub.l	a2,a2
		move.l	#GD_pal_rangeinfo,d0
		lsl.l	#2,d0
		lea	palwingadgets2,a0
		move.l	(a0,d0.w),a0
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		rts


pal_rangetag:	dc.l	GTTX_Text,pal_rangetext
		dc.l	TAG_DONE

pal_rangetext:
		dc.b	' from           ',0
	
	even	

;----------------------------------------------------------------
pal_setmaker:

;lösche erstmal die alten marker

		move.l	gfxbase(a5),a6
		move.l	palwinWnd1(a5),a0
		move.l	50(a0),a4	;rastport
		move.l	a4,a1	
		moveq	#0,d0
		jsr	_LVOSetAPen(a6)
		move.l	a4,a1		
		moveq	#0,d0
		moveq	#0,d1
		move.w	#315,d2
		moveq	#2,d3
		jsr	_LVORectFill(a6)
		
;setze die neuen

		move.l	coloroffset(a5),d5
		
;setzte 16'er marker

		move.l	d5,d6
		tst.l	d5
		beq.b	.ok
		moveq	#0,d6
.w		add.l	#16,d6
		cmp.w	d6,d5
		bhi.b	.w
		sub.w	d5,d6
.ok:
		move.l	d6,d7
		add.w	#27,d7
		
		lea	pal_makercol(pc),a3
		move.b	#1,(a3)			;erste farbe

		move.l	intbase(a5),a6
.n16		cmp.w	anzcolor(a5),d6
		bhi.b	.wech16
		move.l	a4,a0		;Rastport
		lea	pal_makerstruck(pc),a1
		move.l	d6,d0
		mulu	#11,d0
		addq.w	#1,d0
		moveq	#0,d1
		jsr	_LVODrawBorder(a6)
		add.w	#16,d6
		cmp.w	d6,d7
		bhs.b	.n16

;setzte 8'er marker
.wech16
		moveq	#0,d6
.w8		add.l	#8,d6
		cmp.w	d6,d5
		bhi.b	.w8

		move.l	d6,d0
		lsr.w	#4,d0
		lsl.w	#4,d0
		cmp.w	d0,d6
		bne.b	.nicht16
		add.w	#8,d6
.nicht16:

		sub.w	d5,d6

		move.l	d6,d7
		add.w	#27,d7
		
		lea	pal_makercol(pc),a3
		move.b	#3,(a3)			;erste farbe

.n8		cmp.w	anzcolor(a5),d6
		bhi.b	.wech
		move.l	a4,a0		;Rastport
		lea	pal_makerstruck(pc),a1
		move.l	d6,d0
		mulu	#11,d0
		addq.w	#1,d0
		moveq	#0,d1
		jsr	_LVODrawBorder(a6)
		add.w	#16,d6
		cmp.w	d6,d7
		bhs.b	.n8

;setzte 4'er marker
.wech:
		moveq	#0,d6
.w4		add.l	#4,d6
		cmp.w	d6,d5
		bhi.b	.w4

		move.l	d6,d0
		lsr.w	#4,d0
		lsl.w	#4,d0
		cmp.w	d0,d6
		bne.b	.nicht161
		add.w	#4,d6
.nicht161:
		move.l	d6,d0
		lsr.w	#3,d0
		lsl.w	#3,d0
		cmp.w	d0,d6
		bne.b	.nicht8
		add.w	#4,d6
.nicht8:
		sub.w	d5,d6

		move.l	d6,d7
		add.w	#27,d7
		cmp.w	anzcolor(a5),d7
		bls.b	.ok4
		move.w	anzcolor(a5),d7
		subq.w	#1,d7
.ok4:		
		lea	pal_makercol(pc),a3
		move.b	#2,(a3)			;erste farbe

.n4		cmp.w	anzcolor(a5),d6
		bhi.b	.wech4

		move.l	a4,a0		;Rastport
		lea	pal_makerstruck(pc),a1
		move.l	d6,d0
		mulu	#11,d0
		addq.w	#1,d0
		moveq	#0,d1
		jsr	_LVODrawBorder(a6)
		add.w	#8,d6
		cmp.w	d6,d7
		bhs.b	.n4
.wech4:
		rts


pal_makerstruck:
		dc.w	-1,-1	;XY origin relative to container TopLeft
pal_makercol:	dc.b	1,0,RP_JAM1	;front pen, back pen and drawmode
		dc.b	2	;number of XY vectors
		dc.l	.border	;pointer to XY vectors
		dc.l	0

.border:
		dc.w	0,3
		dc.w	0,0

;-----------------------------------------------------------------
pal_convertandset:
		move.l	redlevel(a5),d0
		move.l	greenlevel(a5),d1
		move.l	bluelevel(a5),d2

		tst.b	usergb(a5)
		bne.b	.w3
.w0:		tst.b	usecmy(a5)
		beq.b	.we
		bsr.w	pal_rgb2cmy
.we:		tst.b	usehsv(a5)
		beq.b	.w1
		bsr.w	pal_hsv2rgb
.w1		tst.b	useyuv(a5)
		beq.b	.w2
		bsr.w	pal_yuv2rgb
.w2		tst.b	useyiq(a5)
		beq.b	.w3
		bsr.w	pal_yiq2rgb
.w3

		move.l	d0,pal_aktred(a5)
		move.l	d1,pal_aktgreen(a5)
		move.l	d2,pal_aktblue(a5)

		bra.w	pal_setcolor
pal_setcolor:		
		move.l	d2,d3
		move.l	d1,d2
		move.l	d0,d1
		move.l	free5(a5),a0
		moveq	#4,d0
		move.l	gfxbase(a5),a6
	tst.b	kick3(a5)
	bne	.w
		lsr.w	#4,d1
		lsr.w	#4,d2
		lsr.w	#4,d3
		jsr	_LVOSetRGB4(a6)
		bra	.k2

.w
		ror.l	#8,d3
		ror.l	#8,d2
		ror.l	#8,d1
		jsr	_LVOSetRGB32(a6)

.k2		move.l	realaktcolor(a5),d0
		sub.l	coloroffset(a5),d0
;		move.l	aktcolor(a5),d0
		addq.l	#4,d0
		cmp.w	#3,d0
		bls.b	.novisit
		cmp.w	#32,d0
		bhi.b	.novisit
		move.l	pal_aktred(a5),d1
		move.l	pal_aktgreen(a5),d2
		move.l	pal_aktblue(a5),d3
		move.l	free1(a5),a0
	tst.b	kick3(a5)
	bne	.w1
		lsr.w	#4,d1
		lsr.w	#4,d2
		lsr.w	#4,d3
		jsr	_LVOSetRGB4(a6)
		bra	.novisit
	
.w1
		ror.l	#8,d3
		ror.l	#8,d2
		ror.l	#8,d1
		jsr	_LVOSetRGB32(a6)

.novisit:
		lea	colorpuffer1+4,a0
		move.l	a0,a2
;		move.l	aktcolor(a5),d0
;		add.l	coloroffset(a5),d0
		move.l	realaktcolor(a5),d0

		mulu	#3*4,d0
		add.l	d0,a0
		move.l	pal_aktred(a5),d1
		move.l	pal_aktgreen(a5),d2
		move.l	pal_aktblue(a5),d3
		ror.l	#8,d3
		ror.l	#8,d2
		ror.l	#8,d1
		move.l	d1,(a0)+		
		move.l	d2,(a0)+		
		move.l	d3,(a0)+		

		move.l	a2,a1
		subq.l	#4,a1
		move.l	Uviewport1(a5),a0
		tst.b	kick3(a5)
		bne	.w2
		bra	pal_setcolor4
		
.w2		jmp	_LVOLoadrgb32(a6)

;--------------------------------------------------------------
pal_undo:
		move.l	pal_undored(a5),d0
		move.l	pal_undogreen(a5),d1
		move.l	pal_undoblue(a5),d2

		move.l	d0,pal_aktred(a5)
		move.l	d1,pal_aktgreen(a5)
		move.l	d2,pal_aktblue(a5)

		bsr.w	pal_setcolor
		bsr.w	pal_setaktslider

		move.l	viewWnd(a5),a0	;aktiviere ViewWin wenn Slider
		bsr.w	aktiwin		;loßgelassen wurde für GFX-Karten

		bra.w	pal_wait
		
;-----------------------------------------------------------------------
pal_reset:
		lea	colorpuffer1,a0
		move.l	a0,a2
		lea	farbtab8(a5),a1
		move.l	(a1)+,(a0)+
		moveq	#0,d7
		move.w	anzcolor(a5),d7
		subq.w	#1,d7
.nc		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		dbra	d7,.nc
		clr.l	(a0)+

		move.l	a2,a1
		move.l	Uviewport1(a5),a0
		move.l	gfxbase(a5),a6
		tst.b	kick3(a5)
		bne	.w
		bsr	pal_setcolor4
		bra	.k2

.w		jsr	_LVOLoadrgb32(a6)	;setze Colors im Pic zurück

.k2
		lea	farbtab8+4(a5),a0
		lea	cb_farbtab8,a1
		move.l	a1,a2
		moveq	#0,d7
		move.w	anzcolor(a5),d7
		cmp.w	#32,d7
		blo.b	.ok
		moveq	#28,d7
.ok:		move.w	d7,(a1)+	;Anz Farben in Farbtab
		move.w	#4,(a1)+      ;erste Farbe die eingetragen werden soll
		subq.w	#1,d7

		move.l	coloroffset(a5),d0
		mulu	#12,d0
		lea	(a0,d0),a0
.nc1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra	d7,.nc1
		clr.l	(a1)

		move.l	a2,a1
		move.l	free1(a5),a0	;Viewport
		move.l	gfxbase(a5),a6
	tst.b	kick3(a5)
	bne	.k3
	bsr	pal_setcolor4
	bra	.k22

.k3		jsr	_LVOLoadrgb32(a6)

.k22		bsr.b	pal_setbigcolor

		move.l	pal_aktred(a5),d1
		move.l	pal_aktgreen(a5),d2
		move.l	pal_aktblue(a5),d3

		move.l	d1,pal_undored(a5)
		move.l	d2,pal_undogreen(a5)
		move.l	d3,pal_undoblue(a5)

		bsr.w	pal_setaktslider

		move.l	viewWnd(a5),a0	;aktiviere ViewWin wenn Slider
		bsr.w	aktiwin		;loßgelassen wurde für GFX-Karten

		bra.w	pal_wait
		
pal_setbigcolor:
		move.l	realaktcolor(a5),d0
		lea	colorpuffer1+4,a0
		mulu	#12,d0
		add.l	d0,a0
		move.l	(a0)+,d1	;Lese aktuelle farbe aus
		move.l	(a0)+,d2
		move.l	(a0)+,d3
		move.l	d1,d4
		rol.l	#8,d4
		move.l	d4,pal_aktred(a5)
		move.l	d2,d4
		rol.l	#8,d4
		move.l	d4,pal_aktgreen(a5)
		move.l	d3,d4
		rol.l	#8,d4
		move.l	d4,pal_aktblue(a5)
		move.l	free5(a5),a0
		moveq	#4,d0
		move.l	gfxbase(a5),a6
	tst.b	kick3(a5)
	bne	.w
	rol.l	#8,d1
	rol.l	#8,d2
	rol.l	#8,d3
	lsr.w	#4,d1
	lsr.w	#4,d2
	lsr.w	#4,d3
	jmp	_LVOSetRGB4(a6)

.w		jmp	_LVOSetRGB32(a6)

;-----------------------------------------------------------------
pal_swap:
		move.l	palwinWnd1(a5),a0
		bsr.w	pal_setpointer
		move.l	palwinWnd2(a5),a0
		bsr.w	pal_setpointer

		move.l	realaktcolor(a5),d0

		move.l	d0,free6(a5)	;First Spread color
		move.b	#3,Toflag(a5)
		bra.w	pal_wait
pal_doswap:
		move.l	realaktcolor(a5),d6
		
		move.l	d6,free7(a5)	;First Spread color

		lea	colorpuffer1+4,a2
		move.l	free6(a5),d1	;erste farbe
		mulu	#12,d1
		move.l	(a2,d1.l),d3
		move.l	4(a2,d1.l),d4
		move.l	8(a2,d1.l),d5

		move.l	free7(a5),d2
		mulu	#12,d2
		move.l	(a2,d2.l),(a2,d1.l)
		move.l	d3,(a2,d2.l)
		move.l	4(a2,d2.l),4(a2,d1.l)
		move.l	d4,4(a2,d2.l)
		move.l	8(a2,d2.l),8(a2,d1.l)
		move.l	d5,8(a2,d2.l)

		bra.b	pal_copyweiter

;------------------------------------------------------------------------
pal_copy:
		move.l	palwinWnd1(a5),a0
		bsr.w	pal_setpointer
		move.l	palwinWnd2(a5),a0
		bsr.w	pal_setpointer

		move.l	aktcolor(a5),d0
		add.l	coloroffset(a5),d0
		move.l	d0,free6(a5)	;First Spread color
		move.b	#2,Toflag(a5)
		bra.w	pal_wait
pal_docopy:
		move.l	aktcolor(a5),d6
		add.l	coloroffset(a5),d6
		move.l	d6,free7(a5)	;First Spread color

		lea	colorpuffer1+4,a2
		move.l	free6(a5),d1	;erste farbe
		mulu	#12,d1
		move.l	(a2,d1.l),d2
		move.l	4(a2,d1.l),d3
		move.l	8(a2,d1.l),d4

		move.l	free7(a5),d1
		mulu	#12,d1
		move.l	d2,(a2,d1.l)
		move.l	d3,4(a2,d1.l)
		move.l	d4,8(a2,d1.l)

pal_copyweiter:
		lea	colorpuffer1,a1
		move.l	Uviewport1(a5),a0
		move.l	gfxbase(a5),a6
	tst.b	kick3(a5)
	bne	.w
	bsr	pal_setcolor
	bra	.k2
.w		jsr	_LVOLoadrgb32(a6)	;setze Colors im Pic zurück

.k2		bsr.w	pal_setselector

		sf	toflag(a5)
		move.l	palwinWnd1(a5),a0
		bsr.w	pal_clearpointer
		move.l	palwinWnd2(a5),a0
		bsr.w	pal_clearpointer

		move.l	viewWnd(a5),a0	;aktiviere ViewWin wenn Slider
		bsr.w	aktiwin		;loßgelassen wurde für GFX-Karten

		bra.w	pal_wait

;-----------------------------------------------------------------
pal_spread:
		move.l	palwinWnd1(a5),a0
		bsr.w	pal_setpointer
		move.l	palwinWnd2(a5),a0
		bsr.w	pal_setpointer

		move.l	aktcolor(a5),d0
		add.l	coloroffset(a5),d0
		move.l	d0,free6(a5)	;First Spread color
		move.b	#1,Toflag(a5)
		bra.w	pal_wait
pal_dospread:
		move.l	aktcolor(a5),d6
		add.l	coloroffset(a5),d6
		move.l	d6,free7(a5)	;First Spread color

		cmp.l	free6(a5),d6	;die selbe farbe angeklickt?
		bne.b	.w
		sf	toflag(a5)
		move.l	palwinWnd1(a5),a0
		bsr.w	pal_clearpointer
		move.l	palwinWnd2(a5),a0
		bsr.w	pal_clearpointer

		move.l	viewWnd(a5),a0	;aktiviere ViewWin wenn Slider
		bsr.w	aktiwin		;loßgelassen wurde für GFX-Karten

		bra.w	pal_wait

.w
		moveq	#12,d4
		sub.l	free6(a5),d6	;schritte
		bpl.b	.ok
		neg.l	d6
		neg.l	d4
.ok:
		move.l	d4,a4		;addierer für Colortab
		move.l	d6,d7
		cmp.w	#1,d6
		beq.w	pal_wait		

;spread Red
		lea	colorpuffer1+4,a2
		move.l	free7(a5),d1
		mulu	#12,d1
		move.l	(a2,d1.l),d5		;zweites red
		move.l	free6(a5),d1
		mulu	#12,d1
		add.l	d1,a2
		move.l	(a2),d4		;erstes red
		rol.l	#8,d4
		rol.l	#8,d5
		sub.l	d4,d5
		move.l	mathbase(a5),a6
		
		move.l	d5,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d5
		move.l	d6,d0		;schritte
		jsr	_LVOSPFlt(a6)
		move.l	d0,d1
		move.l	d5,d0
		jsr	_LVOSPDiv(a6)
		move.l	d0,d5		;wert der Addiert wird
		
		move.l	d4,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d4		;anfangswert

		subq.w	#2,d6
		add.l	a4,a2

.nred:		move.l	d4,d0
		move.l	d5,d1
		jsr	_LVOSPAdd(a6)
		move.l	d0,d4
		jsr	_LVOSPFix(a6)
		ror.l	#8,d0
		move.l	d0,(a2)
		add.l	a4,a2
		dbra	d6,.nred

;spread Green
pal_g
		move.l	d7,d6
		lea	colorpuffer1+4,a2
		move.l	free7(a5),d1
		mulu	#12,d1
		move.l	4(a2,d1.l),d5		;zweites red
		move.l	free6(a5),d1
		mulu	#12,d1
		add.l	d1,a2
		move.l	4(a2),d4		;erstes red
		rol.l	#8,d4
		rol.l	#8,d5
		sub.l	d4,d5
		move.l	mathbase(a5),a6
		
		move.l	d5,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d5
		move.l	d6,d0		;schritte
		jsr	_LVOSPFlt(a6)
		move.l	d0,d1
		move.l	d5,d0
		jsr	_LVOSPDiv(a6)
		move.l	d0,d5		;wert der Addiert wird
		
		move.l	d4,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d4		;anfangswert

		subq.w	#2,d6
		add.l	a4,a2
.nred:		move.l	d4,d0
		move.l	d5,d1
		jsr	_LVOSPAdd(a6)
		move.l	d0,d4
		jsr	_LVOSPFix(a6)
		ror.l	#8,d0
		move.l	d0,4(a2)
		add.l	a4,a2
		dbra	d6,.nred
;spread Blue
pal_b
		move.l	d7,d6
		lea	colorpuffer1+4,a2
		move.l	free7(a5),d1
		mulu	#12,d1
		move.l	8(a2,d1.l),d5		;zweites red
		move.l	free6(a5),d1
		mulu	#12,d1
		add.l	d1,a2
		move.l	8(a2),d4		;erstes red
		rol.l	#8,d4
		rol.l	#8,d5
		sub.l	d4,d5
		move.l	mathbase(a5),a6
		
		move.l	d5,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d5
		move.l	d6,d0		;schritte
		jsr	_LVOSPFlt(a6)
		move.l	d0,d1
		move.l	d5,d0
		jsr	_LVOSPDiv(a6)
		move.l	d0,d5		;wert der Addiert wird
		
		move.l	d4,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d4		;anfangswert

		subq.w	#2,d6
		add.l	a4,a2
.nred:		move.l	d4,d0
		move.l	d5,d1
		jsr	_LVOSPAdd(a6)
		move.l	d0,d4
		jsr	_LVOSPFix(a6)
		ror.l	#8,d0
		move.l	d0,8(a2)
		add.l	a4,a2
		dbra	d6,.nred

		lea	colorpuffer1,a1
		move.l	Uviewport1(a5),a0
		move.l	gfxbase(a5),a6
	tst.b	kick3(a5)
	bne	.w
	bsr	pal_setcolor4
	bra	.k2
.w		jsr	_LVOLoadrgb32(a6)	;setze Colors im Pic zurück

.k2		bsr.b	pal_setselector

		sf	toflag(a5)
		move.l	palwinWnd1(a5),a0
		bsr.b	pal_clearpointer
		move.l	palwinWnd2(a5),a0
		bsr.b	pal_clearpointer

		move.l	viewWnd(a5),a0	;aktiviere ViewWin wenn Slider
		bsr.w	aktiwin		;loßgelassen wurde für GFX-Karten

		bra.w	pal_wait
		

pal_setselector:
		lea	colorpuffer1+4,a0
		lea	cb_farbtab8,a1
		move.l	a1,a2
		moveq	#0,d7
		move.w	anzcolor(a5),d7
		cmp.w	#32,d7
		blo.b	.ok
		moveq	#28,d7
.ok:		move.w	d7,(a1)+	;Anz Farben in Farbtab
		move.w	#4,(a1)+      ;erste Farbe die eingetragen werden soll
		subq.w	#1,d7
		move.l	coloroffset(a5),d0
		mulu	#12,d0
		lea	(a0,d0),a0

.nc		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra	d7,.nc
		clr.l	(a1)

		move.l	a2,a1
		move.l	free1(a5),a0	;Viewport
		move.l	gfxbase(a5),a6
	tst.b	kick3(a5)
	bne	.w
	bra	pal_setcolor4
.w		jmp	_LVOLoadrgb32(a6)

;-------------------------------------------------------------------------
pal_setpointer:
;a0= Window
		lea	pal_ToPointer,a1
pal_setpointer1:
		moveq	#16,d0
		moveq	#16,d1
		moveq	#0,d2
		moveq	#0,d3
		move.l	intbase(a5),a6
		jmp	_LVOSetpointer(a6)

pal_clearpointer:
;a0= Window
		move.l	intbase(a5),a6
		jmp	_LVOClearPointer(a6)
		
;------------------------------------------------------------------
;------ Picke Color aus dem Pic
;---------------------------------------------------------------
pal_pick:
		move.l	palwinWnd2(a5),a0
		lea	pal_pickPointer,a1
		bsr.b	pal_setpointer1
		move.l	ViewWnd(a5),a0
		lea	pal_pickPointer,a1
		bsr.b	pal_setpointer1

		move.l	intbase(a5),a6
		move.l	scr4(a5),a0
		jsr	_LVOScreentoBack(a6)
		move.l	scr5(a5),a0
		jsr	_LVOScreentoBack(a6)

		move.l	viewWnd(a5),a0
		bsr.w	aktiwin

.w		move.l	viewWnd(a5),a0
		bsr.l	wait

		cmp.l	#IDCMP_MouseButtons,d4
		bne.b	.w

		cmp.w	#iecode_lbutton,d5
		bne.b	.w

		move.l	scr1(a5),a0
		move.w	16(a0),d1	;MouseY
		move.w	18(a0),d0	;MouseX

		move.l	viewrastport(a5),a1
		move.l	gfxbase(a5),a6
		jsr	_LVOReadPixel(a6)

		tst.l	d0
		bmi.w	.wech	;Farbe konnte nicht gelesen werden

;Selectiere angewählte Farbe

		move.l	d0,d5

		tst.b	ehb(a5)
		beq.b	.noehb
		cmp.w	#32,d5
		bls.b	.noehb
		sub.w	#32,d5
.noehb
		move.l	free3(a5),d0
		moveq	#1,d1
		moveq	#-1,d7
		bsr.w	makeborder

;checke ob gewählte schon sichtbar ist 

		move.l	coloroffset(a5),d0
		cmp.w	d0,d5
		blo.b	.newrange
		add.w	#27,d0
		cmp.w	d0,d5
		blo.b	.set

;stelle den Range so ein das die angewählte farbe sichtbar ist
.newrange:
		moveq	#0,d0
		move.l	d0,d1
.wb		add.w	#28,d1
		cmp.w	d5,d1
		bhi.b	.ok	;das ist die bank
		move.l	d1,d0
		bra.b	.wb		
.ok:		
		move.w	anzcolor(a5),d2
		cmp.w	d2,d1		;haben wir einen überlauf?
		bls.b	.rok
		sub.w	d2,d1
		sub.w	d1,d0

.rok:		move.l	d0,coloroffset(a5)

		bsr.w	pal_setnewrange1	;setze palette neu

		move.l	coloroffset(a5),d0
		move.l	#GD_pal_rangeslider,d1
		bsr.w	pal_setrangeslider	;setze Slider neu

		bsr.w	pal_setrangeinfo
.set:
		sub.l	coloroffset(a5),d5
		move.l	d5,aktcolor(a5)
		move.l	aktcolor(a5),d0

		mulu	#11,d0
		addq.w	#1,d0
		move.l	d0,free3(a5)	;Letzten eintrag merken
		moveq	#0,d7
		bsr.w	makeborder

		move.l	coloroffset(a5),d0
		add.l	aktcolor(a5),d0
		move.l	d0,realaktcolor(a5)
		bsr.w	pal_setbigcolor

		move.l	pal_aktred(a5),pal_undored(a5)
		move.l	pal_aktgreen(a5),pal_undogreen(a5)
		move.l	pal_aktblue(a5),pal_undoblue(a5)

		bsr.w	pal_setaktslider	;setzte slider auf aktuellen
						;wert
		move.l	aktcolor(a5),d0
		add.l	coloroffset(a5),d0
		lea	pal_numbertags(pc),a3
		move.l	d0,4(a3)
		move.l	palwinWnd2(a5),a1
		sub.l	a2,a2
		move.l	#GD_pal_number,d0
		lsl.l	#2,d0
		lea	palwingadgets2,a0
		move.l	(a0,d0.w),a0
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

.wech:
		move.l	palwinWnd2(a5),a0
		bsr.w	pal_clearpointer
		move.l	ViewWnd(a5),a0
		bsr.w	pal_clearpointer

		move.l	intbase(a5),a6
		move.l	scr4(a5),a0
		jsr	_LVOScreentoFront(a6)
		move.l	scr5(a5),a0
		jsr	_LVOScreentoFront(a6)

		move.l	palwinWnd2(a5),a0
		bsr.w	aktiwin

		bra.w	pal_wait

;----------------------------------------------------------------
;--- 	Remape Pic mit Vorgegebene Palette wieder hin
;-----------------------------------------------------------------
pal_remap:

;allociere erstmal nötiges Mem

		tst.b	cbhammerk(a5)
		beq.w	pal_remapchunky	;kein Ham, wir können nur mit Chunkys
					;arbeiten

;weil Ham müssen wir mit RGB Chunkys arbeiten

		move.l	palwinWnd2(a5),a0
		bsr.w	setwaitpointer

		st	merk1(a5)	;es wird remappt
		
		clr.l	rgbmem(a5)	;Puffer für RGB Pic

		tst.l	rndr_rgb(a5)	; Haben wir schon rgb daten ?
		bne.w	pal_renderrgb

;Keine RGB Daten vorhanden, also erstellen wir schnell welche :)

		move.l	bytebreite(a5),d0
		move.w	hoehe(a5),d1
		jsr	APR_InitRenderMem(a5)
		tst.l	d0
		beq.w	pal_remap_nomem

		lea	farbtab8(a5),a0
		lea	farbtab8pure,a1
		move.l	(a0)+,d7
		swap	d7
		move.l	d7,d6
		subq.w	#1,d7

.ncc		moveq	#0,d1
		move.l	(a0)+,d0
		lsr.l	#8,d0
		move.l	(a0)+,d1
		swap	d1
		or.w	d1,d0
		move.l	(a0)+,d1
		rol.l	#8,d1
		or.b	d1,d0

		move.l	d0,(a1)+

		dbra	d7,.ncc		

		move.l	renderbase(a5),a6
		tst.l	rndr_memhandler(a5)
		bne.b	pal_initpal
;Init Render 
		sub.l	a1,a1
		tst.b	kick3(a5)
		beq.b	.no3
		lea	.rndr_memtag(pc),a1	;Kick 3.0 , wir können Pool benutzen
.no3:
		jsr	_LVOCreateRMHandlerA(a6)
		move.l	d0,rndr_memhandler(a5)
		bra.b	pal_initpal			;!!!!!!!!!!!!!!!!!!!

.rndr_memtag:
		dc.l	RND_MemType,RMHTYPE_POOL
		dc.l	TAG_DONE

pal_initpal:
		tst.l	rndr_palette(a5)
		bne.b	.wp
		lea	rndr_paltag(pc),a1
		move.l	rndr_memhandler(a5),4(a1)
		move.l	renderbase(a5),a6
		jsr	_LVOCreatePaletteA(a6)
		move.l	d0,rndr_palette(a5)
.wp
		move.l	rndr_palette(a5),a0
		move.l	d6,d0		;Farbanzahl
		lea	farbtab8pure,a1
		lea	rndr_palitag(pc),a2
		move.l	renderbase(a5),a6
		jsr	_LVOImportPaletteA(a6)		

;zuerst ein Chunky Pic erzeugen

		lea	rndr_planetab(pc),a1	;init Planetab
		move.l	a1,a0
		moveq	#0,d7
.noham8:
		move.b	planes(a5),d7
		subq.l	#1,d7
		move.l	picmem(a5),d0
.np		move.l	d0,(a1)+
		add.l	oneplanesize(a5),d0
		dbra	d7,.np
.weiter
		move.l	rndr_chunky(a5),a1
		move.l	APG_ByteWidth(a5),d0
		move.w	hoehe(a5),d1
		moveq	#0,d2
		move.b	planes(a5),d2
		move.l	APG_ByteWidth(a5),d3
		
		move.l	renderbase(a5),a6
		
		sub.l	a2,a2
		
		jsr	_LVOPlanar2Chunky(a6)

;jetzt ein RGB pic erzeugen

		move.l	rndr_chunky(a5),a0	;Chunkypuffer
		move.l	rndr_rgb(a5),a1
		move.l	a1,d7
;		lea	farbtab8pure,a2		;Palette
		move.l	rndr_palette(a5),a2

		move.l	bytebreite(a5),d0
		lsl.l	#3,d0			;gesamt Chunkybreite
		move.w	hoehe(a5),d1
		moveq	#COLORMODE_CLUT,d5

		tst.b	ham(a5)
		beq.b	.w
		moveq	#COLORMODE_HAM6,d5
		bra.b	.ren
.w		tst.b	ham8(a5)
		beq.b	.ren
		moveq	#COLORMODE_HAM8,d5
.ren
		lea	.vtag(pc),a3
		move.l	d5,4(a3)

		jsr	_LVOChunky2RGBA(a6)

		bra.b	pal_renderrgb
.vtag:
		dc.l	RND_ColorMode,0
		dc.l	TAG_DONE

pal_renderrgb:

pal_render:
		lea	colorpuffer1+4,a1
		jsr	convtab1

		move.l	rndr_palette(a5),a0
		lea	farbtab8pure,a1
		lea	rndr_palitag(pc),a2
		move.l	colorpuffer1,d0
		swap	d0			;anz Colors
		move.l	renderbase(a5),a6
		jsr	_LVOImportPaletteA(a6)

		move.w	anzcolor(a5),d7
		moveq	#COLORMODE_CLUT,d0

		tst.b	ham(a5)
		beq.b	.w
		moveq	#COLORMODE_HAM6,d0
.w		tst.b	ham8(a5)
		beq.b	.nh
		moveq	#COLORMODE_HAM8,d0
.nh
		lea	rndr_rendertag(pc),a3
		move.l	d0,4(a3)
		
		move.l	ren_dithermode(a5),12(a3)	;Dither Mode eintragen
		
		move.l	rndr_rgb(a5),a0		;RGB Pic
		move.l	rndr_chunky(a5),a1	;Chunkypuffer
		move.l	rndr_palette(a5),a2
		move.l	bytebreite(a5),d0
		lsl.l	#3,d0
		move.w	hoehe(a5),d1
		jsr	_LVORenderA(a6)

		lea	picmap(a5),a0	
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.b	planes(a5),d0
		move.l	bytebreite(a5),d1
		lsl.l	#3,d1
		move.w	hoehe(a5),d2
		move.l	gfxbase(a5),a6
		jsr	_LVOinitbitmap(a6)

		lea	picmap+8(a5),a0
		move.l	picmem(a5),d0
		moveq	#0,d7		
		move.b	planes(a5),d7	
		subq	#1,d7
.newplane
		move.l	d0,(a0)+	;Planes in Strucktur einbinden
		add.l	oneplanesize(a5),d0
		dbra	d7,.newplane

		move.l	renderbase(a5),a6

		move.l	rndr_chunky(a5),a0	;chunky
		lea	picmap(a5),a1
		moveq	#0,d0
		moveq	#0,d1
		move.l	bytebreite(a5),d2
		lsl.l	#3,d2
		move.w	hoehe(a5),d3
		moveq	#0,d4
		moveq	#0,d5
		sub.l	a2,a2			;TagList
		jsr	_LVOChunky2BitmapA(a6)

;Copy Pic in Viewwindow
pal_copypic:
		bsr.w	copyimage2bitmap

		lea	colorpuffer1,a0		;Palette backupen
		lea	farbtab8(a5),a1
		move.l	(a0)+,(a1)+
		moveq	#0,d7
		move.w	anzcolor(a5),d7
		subq.w	#1,d7
.nc		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra	d7,.nc
		clr.l	(a1)+

		move.l	palwinWnd2(a5),a0
		bsr.w	clearwaitpointer

pal_rende:
		move.l	viewWnd(a5),a0	;aktiviere ViewWin wenn Slider
		bsr.w	aktiwin		;loßgelassen wurde für GFX-Karten

		bra.w	pal_wait
		

;------ Remappe nur mit normalen Chunkys -----

	rsreset
pal_left	rs.l	1
pal_right	rs.l	1
pal_key		rs.l	1
pal_color	rs.l	1

pal_remapchunky:
		clr.l	rgbtemp(a5)

		move.l	bytebreite(a5),d0
		lsl.l	#3,d0
		mulu	hoehe(a5),d0
		move.l	d0,anzchunky(a5)

;berechne Puffer für Suchbaum

		moveq	#0,d1
		move.w	anzcolor(a5),d1
		lsl.l	#4,d1		;*16
		add.w	#32,d1
		add.l	d1,d0	;gesamter benötigter Speicher

		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,rgbmem(a5)
		beq.w	pal_remap_nomem

		add.l	anzchunky(a5),d0
		move.l	d0,histobuffer(a5)
		
		move.l	palwinWnd2(a5),a0
		bsr.w	setwaitpointer

		jsr	convtab		;originale Colortab
		
		lea	cb_pufferfarbtab,a0
		lea	farbtab8pure,a1
		move.w	anzcolor(a5),d7
		subq.w	#1,d7
.nc		move.l	(a1)+,(a0)+
		dbra	d7,.nc		

		lea	colorpuffer1+4,a1
		jsr	convtab1	;farbtab auf die gerendert werden soll

;mäch chunkys
		lea	rgbmap(a5),a1	;puffer für BitmapPointerTab
		move.l	a1,a0
		move.l	Picmem(a5),d0
		moveq	#0,d1
		move.b	planes(a5),d1		
		subq.w	#1,d1
.ncp:		move.l	d0,(a1)+	;erzeuge bitmappointer Tab
		add.l	oneplanesize(a5),d0
		dbra	d1,.ncp

		move.l	rgbmem(a5),a1
		move.l	bytebreite(a5),d0
		move.w	hoehe(a5),d1
		moveq	#0,d2
		move.b	planes(a5),d2
		move.l	d0,d3
		sub.l	a2,a2
		move.l	renderbase(a5),a6
		jsr	_LVOPlanar2Chunky(a6)
		

	;*---------- Convert Chunkys--------------*

		move.l	rgbmem(a5),a0
		move.l	anzchunky(a5),d7
		subq.l	#1,d7
		move.l	histobuffer(a5),a4	;histobuffer wird auch für
pal_initbaum:
		move.l	a4,d0
		move.l	d0,pal_left(a4)		;init Z knoten
		move.l	d0,pal_right(a4)

		lea	16(a4),a6
		move.l	a6,cb_lastnode(a5)	;kopf des baums
		
		move.w	#-1,pal_key(a6)	;-1 statt null
		move.l	d0,pal_left(a6)
		move.l	d0,pal_right(a6)
		
		clr.l	cb_actbin(a5)		;letzter eintrag in Tabelle

		lea	cb_pufferfarbtab,a1	;original

pal_nextchunky:
		moveq	#0,d6
		move.b	(a0),d6
		move.w	d6,pal_key(a4)

		lea	16(a4),a6	;head
		move.l	d6,d5
		ror.l	#8,d5	;wir brauchen ja nur das untere Byte

pal_searchloop:
		move.l	a6,a3
		rol.l	#1,d5
		bcs.b	.right
		move.l	pal_left(a6),a6
		bra.b	.go
.right:		move.l	pal_right(a6),a6
.go:		cmp.w	pal_key(a6),d6
		bne.b	pal_searchloop

		cmp.l	a4,a6
		beq.b	pal_notfound

		move.b	pal_color(a6),(a0)+

		subq.l	#1,d7
		bne.b	pal_nextchunky

		bra.b	pal_mappechunkys

;--- Wir müssen alles durchrechnen da Farbe noch nicht behandelt wurde
pal_notfound:
		move.l	d7,-(a7)

		lea	farbtab8pure,a2		;rendertab
		move.l	#$7fffffff,d4		; maximal schlechte Abweichung
		moveq	#0,d2			; Schleifen (Index-) Zähler

		move.l	d6,d0
		add.w	d0,d0
		add.w	d0,d0
		move.l	(a1,d0.l),d6	;originaler RGB wert
		
		move.w	anzcolor(a5),d7
		subq.w	#1,d7

pal_normlop:	move.l	d6,d0
		move.l	(a2)+,d1
		bsr.w	RGBDiversity24		; Abweichung ermitteln

		cmp.l	d4,d0

		bhi.b	pal_worse
		move.l	d0,d4			; diese Abweichung merken
		move.w	d2,d3			; deren Index merken
		
pal_worse	addq.w	#1,d2
		dbra	d7,pal_normlop

	;*---- trage ergebnis in Suchbaum ein ----*

		move.l	(a7)+,d7

		lea	16(a4),a6		;head

		moveq	#0,d0
		move.b	(a0),d0

		move.l	cb_lastnode(a5),a6	;erzeuge neue Node
		lea	16(a6),a6
		move.l	a6,cb_lastnode(a5)
		
		move.w	d0,pal_key(a6)	; RGB und Pen in binären Buffer
		move.b	planes(a5),d1
;		ror.b	d1,d3		;für chunky2bpl vorschiften
		move.b	d3,pal_color(a6)
		addq.l	#1,cb_actbin(a5)

		move.l	a4,pal_left(a6)
		move.l	a4,pal_right(a6)

		and.b	#1,d5		;war letztes bit gesetzt ?
		bne.b	.right1
		move.l	a6,pal_left(a3)		;p
		bra.b	pal_savecolor
.right1:	move.l	a6,cb_right(a3)
		
pal_savecolor:
		move.b	d3,(a0)+

		subq.l	#1,d7
		bne.w	pal_nextchunky

	;*--- Convertiere Chunkys wieder in Bitmap ---*

pal_mappechunkys:
		lea	rgbmap(a5),a0	
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.b	planes(a5),d0
		move.l	bytebreite(a5),d1
		lsl.l	#3,d1
		move.w	hoehe(a5),d2
		move.l	gfxbase(a5),a6
		jsr	_LVOinitbitmap(a6)
		
		lea	rgbmap+8(a5),a0
		move.l	picmem(a5),d0
		moveq	#0,d7		
		move.b	planes(a5),d7	
		subq	#1,d7
.newplane
		move.l	d0,(a0)+		;Planes in Strucktur einbinden
		add.l	oneplanesize(a5),d0
		dbra	d7,.newplane

		move.l	rgbmem(a5),a0
		lea	rgbmap(a5),a1
		moveq	#0,d0
		moveq	#0,d1
		move.l	bytebreite(a5),d2
		lsl.l	#3,d2
		move.w	hoehe(a5),d3
		moveq	#0,d4
		moveq	#0,d5
		sub.l	a2,a2
		move.l	renderbase(a5),a6
		jsr	_LVOChunky2BitmapA(a6)

		clr.l	histobuffer(a5)	;damit nicht nochmal versucht wird
					;was freizugeben
		bra.w	pal_copypic

;----------------------------------------------------------------------
pal_remap_nomem:
		move.l	palwinWnd2(a5),a0
		bsr.w	clearwaitpointer

		lea	pal_screen(pc),a0
		move.l	scr5(a5),(a0)
		move.l	palwinWnd2(a5),8(a0)

		lea	pal_rnomemmsg(pc),a1
		lea	pal_rnomemmsg1(pc),a2
		sub.l	a3,a3
		sub.l	a4,a4
		lea	pal_TagItemListe(pc),a0
		move.l	reqtbase(a5),a6
		jsr	_LVOrtEZRequestA(a6)
		bra.w	pal_rende

pal_rnomemmsg:
		dc.b	'Not enough memory for this operation!',0
pal_rnomemmsg1:
		dc.b	'Ok',0
		
	even
pal_TagItemListe:
		dc.l	$80000000+7		
pal_screen:	dc.l	0			
		dc.l	_rt_window
pal_window:	dc.l	0
		dc.l	RT_REQPOS
		dc.l	2			;Centriert
		dc.l	RTEZ_ReqTitle
		dc.l	reqtitle
		dc.l	RT_LOckWindow,1
		dc.l	_RTFI_Flags,FREQF_PATGAD
		dc.l	0
;----------------------------------------------------------------
;	Sortiere Palette

pal_sort:

;Frage erstmal wie sortiert werden soll

		move.l	palwinWnd2(a5),a0
		bsr.w	setwaitpointer

		lea	palsortwintags,a0
		move.l	a0,windowtaglist(a5)
		lea	palwinWG2+4,a0
		move.l	a0,gadgets(a5)
		lea	palwinSC2+4,a0
		move.l	a0,winscreen(a5)
		lea	palwinWnd3(a5),a0
		move.l	a0,window(a5)
		lea	palwinGlist3(a5),a0
		move.l	a0,Glist(a5)
		lea	palwinNgads3,a0
		move.l	a0,NGads(a5)
		lea	palwinGTypes3,a0
		move.l	a0,GTypes(a5)
		lea	palwinGadgets3,a0
		move.l	a0,WinGadgets(a5)
		move.w	#palwin3_CNT,win_CNT(a5)
		lea	palwinGtags3,a0
		move.l	a0,windowtags(a5)
		move.l	scr5(a5),screenbase(a5)
		moveq	#0,d7
		bsr.w	openwindow

pal_sortwait:	move.l	palwinWnd3(a5),a0
		bsr.l	wait

		cmp.l	#GADGETUP,d4
		beq.b	pal_sortgads
		cmp.l	#IDCMP_VANILLAKEY,d4
		beq.b	pal_sorttast		;es wurde eine Taste gedrückt
		bra.b	pal_sortwait

;-----------------------------------------------------
pal_sorttast:
		move.l	palwinWnd3(a5),aktwin(a5)
		lea	palwinGadgets3,a0
		move.l	d5,d3
		cmp.w	#'d',d3
		bne.b	.nodark
		lea	pal_sortdarktolight(pc),a3
		move.l	#GD_pal_sortdark,d0
		bra.l	setandjump
.nodark:
		cmp.w	#'l',d3
		bne.b	.nolight
		lea	pal_sortlighttodark(pc),a3
		move.l	#GD_pal_sortlight,d0
		bra.l	setandjump
.nolight:
		cmp.w	#'c',d3
		bne.b	.nocancel
		lea	pal_sortwech(pc),a3
		move.l	#GD_pal_sortcancel,d0
		bra.l	setandjump
.nocancel:
		bra.b	pal_sortwait

;-----------------------------------------------------------------
pal_sortgads:
		moveq	#0,d0
		move.w	38(a4),d0
		cmp.w	#GD_pal_sortdark,d0
		beq.b	pal_sortdarktolight
		cmp.w	#GD_pal_sortlight,d0
		beq.w	pal_sortlighttodark
		cmp.w	#GD_pal_sortcancel,d0
		beq.b	pal_sortwech
		bra.w	pal_sortwait

pal_sortwech:
		bsr.w	pal_sortclosewindow

pal_sortend:
		move.l	palwinWnd2(a5),a0
		bsr.w	clearwaitpointer

		move.l	viewWnd(a5),a0	;aktiviere ViewWin wenn Slider
		bsr.w	aktiwin		;loßgelassen wurde für GFX-Karten

		bra.w	pal_wait

;--------------------------------------------------------------------
pal_sortdarktolight:

		bsr.w	pal_sortclosewindow

		bsr.w	pal_sortmakelights

.nochmal:	lea	farbtab8pure,a0
		lea	farbtab4pure,a1		;Helligkeitswerte

		moveq	#0,d6		;merker		
		moveq	#1,d7

		move.w	(a1)+,d0
.nc:		move.w	(a1)+,d1
		cmp.w	d0,d1
		bhs.b	.ok
		move.w	d0,d2
		move.w	d1,d0
		move.w	d2,d1
		move.w	d7,d5
		subq.w	#1,d5
		add.w	d5,d5
		add.w	d5,d5
		move.l	4(a0,d5.w),d3
		move.l	(a0,d5.w),4(a0,d5.w)
		move.l	d3,(a0,d5.w)
		move.w	d0,-4(a1)
		move.w	d1,-2(a1)
		moveq	#-1,d6
.ok:
		move.w	d1,d0
		addq.w	#1,d7
		cmp.w	anzcolor(a5),d7
		bne.b	.nc
		tst.l	d6
		bne.b	.nochmal

pal_sortlightend:
		bsr.w	pal_sortmakecolortab	;wandle wieder in Loadrgb32 um

		lea	colorpuffer1,a1
		move.l	Uviewport1(a5),a0
		move.l	gfxbase(a5),a6
	tst.b	kick3(a5)
	bne	.w
	bsr	pal_setcolor4
	bra	.k2
.w		jsr	_LVOLoadrgb32(a6)	;setze Colors im Pic zurück

.k2		bsr.w	pal_setselector
		bsr.w	pal_setbigcolor
		bsr.w	pal_setaktslider
				
		bra.w	pal_sortend

;--------------------------------------------------------------------
pal_sortlighttodark:
		bsr.b	pal_sortclosewindow

		bsr.b	pal_sortmakelights

.nochmal:	lea	farbtab8pure,a0
		lea	farbtab4pure,a1		;Helligkeitswerte

		moveq	#0,d6		;merker		
		moveq	#1,d7

		move.w	(a1)+,d0
.nc:		move.w	(a1)+,d1
		cmp.w	d0,d1
		bls.b	.ok
		move.w	d0,d2
		move.w	d1,d0
		move.w	d2,d1
		move.w	d7,d5
		subq.w	#1,d5
		add.w	d5,d5
		add.w	d5,d5
		move.l	4(a0,d5.w),d3
		move.l	(a0,d5.w),4(a0,d5.w)
		move.l	d3,(a0,d5.w)
		move.w	d0,-4(a1)
		move.w	d1,-2(a1)
		moveq	#-1,d6
.ok:
		move.w	d1,d0
		addq.w	#1,d7
		cmp.w	anzcolor(a5),d7
		bne.b	.nc
		tst.l	d6
		bne.b	.nochmal

		bra.w	pal_sortlightend
;--------------------------------------------------------------------
pal_sortclosewindow:
		lea	palwinWnd3(a5),a0
		move.l	a0,window(a5)
		lea	palwinGlist3(a5),a0
		move.l	a0,Glist(a5)
		moveq	#0,d7
		jmp	gt_CloseWindow

;--------------------------------------------------------------------
;Errechne die Helligkeitswerte von jedem Farbeintrag

pal_sortmakelights:

		lea	colorpuffer1+4,a1
		bsr.l	convtab1

;Y=0.299R+0.587G+0.114B

		move.l	mathbase(a5),a6
		lea	colorpuffer1+4,a3
		lea	farbtab4pure,a4
		move.w	anzcolor(a5),d7
		subq.w	#1,d7
.nextcolor
		move.l	(a3)+,d0
		lsr.l	#8,d0
		swap	d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d2		;R
		move.l	(a3)+,d0
		lsr.l	#8,d0
		swap	d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d3		;G
		move.l	(a3)+,d0
		lsr.l	#8,d0
		swap	d0
		jsr	_LVOSPFlt(a6)	;d0 = B
		move.l	d0,d4

		move.l	d2,d0
		move.l	#$9916873f,d1	;.299
		jsr	_LVOspmul(a6)
		move.l	d0,d6
		move.l	d3,d0
		move.l	#$9645a240,d1	;0.587
		jsr	_LVOspmul(a6)
		move.l	d6,d1
		jsr	_LVOspadd(a6)
		move.l	d0,d6
		move.l	d4,d0
		move.l	#$e978d53d,d1	;0.114
		jsr	_LVOspmul(a6)
		move.l	d6,d1
		jsr	_LVOspadd(a6)
		jsr	_LVOSPFix(a6)
		move.w	d0,(a4)+	;=Y

		dbra	d7,.nextcolor

		rts		
;*----------------------------------------------------------------*
;Convertiere normale RGBs nach einer LoadRGB32 Tab
;a0=RGB Tab a1=ziel d7=anzahl colors
pal_sortmakecolortab:

		lea	farbtab8pure,a0
		lea	colorpuffer1,a1
		move.w	anzcolor(a5),d7

pal_sortmakecolortab1:

		move.w	d7,(a1)+
		clr.w	(a1)+
		subq.w	#1,d7
.nc:		move.l	(a0)+,d0
		
		c24to3Byte d0,d1,d2

		lsl.l	#8,d0
		lsl.l	#8,d1
		lsl.l	#8,d2
		swap	d0
		swap	d1
		swap	d2
		move.l	d0,(a1)+
		move.l	d1,(a1)+
		move.l	d2,(a1)+
		dbra	d7,.nc
		clr.l	(a1)
		rts

;-------------------------------------------------------------------
;Colorsystemtransformroutinen
;-----------------------------------------------------------------
;	>d0	R
;	>d1	G
;	>d2	B
;	<d0	C
;	<d1	M
;	<d2	Y
pal_rgb2cmy:			;auch für cmy2rgb
		move.w	#255,d3
		sub.w	d3,d0
		neg.w	d0
		sub.w	d3,d1
		neg.w	d1
		sub.w	d3,d2
		neg.w	d2
		rts

pal_rgb2hsv:
		movem.l	d5-d7,-(a7)

		move.l	d0,d7	;ma
		cmp.w	d1,d7
		bhi.b	.g
		move.l	d1,d7
.g		cmp.w	d2,d7
		bhi.b	.g1
		move.l	d2,d7	;ma
				
.g1		move.l	d7,-(a7)	;V
		move.l	d0,d6	;mi
		cmp.w	d1,d6
		blo.b	.k
		move.l	d1,d6
.k		cmp.w	d2,d6
		blo.b	.k1
		move.l	d2,d6
.k1
		moveq	#0,d5	;S
		tst.l	d7
		beq.b	.sok
		move.l	d7,d5
		sub.l	d6,d5	;ma-mi
		mulu	#255,d5
		divu	d7,d5
		ext.l	d5
.sok:		move.l	d5,-(a7)	;S

		tst.l	d5
		bne.b	.calcH
		clr.l	-(a7)
		bra.b	.hsvend
.calcH:
		move.l	d7,d5
		sub.l	d6,d5
		cmp.w	d0,d7	;r=ma
		bne.b	.w
		sub.l	d2,d1
		muls	#60,d1
		divs	d5,d1
		ext.l	d1
		move.l	d1,-(a7)
		bra.b	.hsvend
.w:
		cmp.w	d1,d7
		bne.b	.w1
		sub.l	d0,d2
		muls	#255,d2
		divs	d5,d2
		add.l	#510,d2
		muls	#60,d2
		divs	#255,d2
		ext.l	d2
		move.l	d2,-(a7)
		bra.b	.hsvend
.w1:
		sub.l	d1,d0
		muls	#255,d0
		divs	d5,d0
		add.l	#4*255,d0
		muls	#60,d0
		divs	#255,d0
		ext.l	d0
		move.l	d0,-(a7)
.hsvend:
		movem.l	(a7)+,d0/d1/d2	;H/S/V
		tst.l	d0
		bpl.b	.pos
		add.l	#360,d0
.pos
		movem.l	(a7)+,d5-d7
		rts
pal_hsv2rgb:
		move.l	d0,d7
		divu	#60,d7
		swap	d7
		move.w	d7,d6	;f
		swap	d7
		ext.l	d7	;i

		move.l	#255,d5
		sub.l	d1,d5	;255-s
		mulu	d2,d5
		divu	#255,d5
		ext.l	d5	;p1

		move.l	d1,d4
		mulu	d6,d4
		divu	#60,d4
		ext.l	d4
		move.l	#255,d3
		sub.l	d4,d3	;1-(s*f)
		mulu	d2,d3	;*v
		divu	#255,d3
		ext.l	d3	
		move.l	d3,a0	;p2	

		move.l	#255,d4
		move.l	d4,d3
		mulu	#255,d6
		divu	#60,d6
		sub.l	d6,d4
		mulu	d1,d4	;s*(255-f)
		divu	#255,d4
		ext.l	d4
		sub.l	d4,d3
		mulu	d2,d3
		divu	#255,d3
		ext.l	d3	;p3
		
		lea	pal_switchtab(pc),a1
		add.l	d7,d7
		move.w	(a1,d7),d7
		jmp	(a1,d7)

pal_switchtab:
		dc.w	.case0-pal_switchtab,.case1-pal_switchtab
		dc.w	.case2-pal_switchtab,.case3-pal_switchtab
		dc.w	.case4-pal_switchtab,.case5-pal_switchtab
.case0:
		move.l	d2,d0
		move.l	d3,d1
		move.l	d5,d2
		rts
.case1:
		move.l	a0,d0
		move.l	d2,d1
		move.l	d5,d2
		rts
.case2:
		move.l	d5,d0
		move.l	d2,d1
		move.l	d3,d2
		rts
.case3:
		move.l	d5,d0
		move.l	a0,d1
		rts		
.case4:
		move.l	d3,d0
		move.l	d5,d1
		rts
.case5:
		move.l	d2,d0
		move.l	d5,d1
		move.l	a0,d2
		rts

;--------------------------------------------------------------------------
pal_rgb2yuv:
		movem.l	d3-a6,-(a7)
		move.l	mathbase(a5),a6
		move.l	d1,d4
		jsr	_LVOSPFlt(a6)
		move.l	d0,d3	;R
		move.l	d4,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d4	;G
		move.l	d2,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d5	;B

		move.l	d3,d0
		move.l	#$9916873f,d1	;.299
		jsr	_LVOspmul(a6)
		move.l	d0,d6
		move.l	d4,d0
		move.l	#$9645a240,d1	;0.587
		jsr	_LVOspmul(a6)
		move.l	d6,d1
		jsr	_LVOspadd(a6)
		move.l	d0,d6
		move.l	d5,d0
		move.l	#$e978d53d,d1	;0.114
		jsr	_LVOspmul(a6)
		move.l	d6,d1
		jsr	_LVOspadd(a6)
		move.l	d0,a2		;=Y
		
		move.l	d0,d1
		move.l	d5,d0
		jsr	_LVOspsub(a6)
		move.l	#$fc6a7f3f,d1	;0.493
		jsr	_LVOspmul(a6)
		move.l	d0,a3		;=U
				
		move.l	a2,d1
		move.l	d3,d0
		jsr	_LVOspsub(a6)
		move.l	#$e0831240,d1	;0.877
		jsr	_LVOspmul(a6)
		move.l	d0,a4		;=V

		move.l	a4,d0
		jsr	_LVOspfix(a6)
		move.l	d0,-(a7)
		move.l	a3,d0
		jsr	_LVOspfix(a6)
		move.l	d0,-(a7)
		move.l	a2,d0
		jsr	_LVOspfix(a6)
		move.l	d0,-(a7)

		movem.l	(a7)+,d0-d2
		movem.l	(a7)+,d3-a6
		
		rts
pal_yuv2rgb:
		movem.l	d3-a6,-(a7)
		move.l	mathbase(a5),a6
		move.l	d1,d4
		jsr	_LVOSPFlt(a6)
		move.l	d0,d3	;Y
		move.l	d4,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d4	;U
		move.l	d2,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d5	;V

		move.l	#1140,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,a0
		move.l	#1000,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d7
		move.l	a0,d0
		move.l	d0,d1
		jsr	_LVOSPDiv(a6)
		move.l	d5,d1
		jsr	_LVOSPMul(a6)
		move.l	d3,d1
		jsr	_LVOSPAdd(a6)
		move.l	d0,a2	;R

		move.l	#396,d0
		jsr	_LVOSPFlt(a6)
		move.l	d7,d1
		jsr	_LVOSPDiv(a6)
		move.l	d4,d1
		jsr	_LVOSPMul(a6)
		move.l	d0,d6
		move.l	#581,d0
		jsr	_LVOSPFlt(a6)
		move.l	d7,d1
		jsr	_LVOSPDiv(a6)
		move.l	d5,d1
		jsr	_LVOSPMul(a6)
		move.l	d0,a3

		move.l	d3,d0
		move.l	d6,d1
		jsr	_LVOSpsub(a6)
		move.l	a3,d1
		jsr	_LVOSPsub(a6)
		move.l	d0,a3
		
		move.l	#2029,d0
		jsr	_LVOSPFlt(a6)
		move.l	d7,d1
		jsr	_LVOSPDiv(a6)
		move.l	d4,d1
		jsr	_LVOSPMul(a6)
		move.l	d3,d1
		jsr	_LVOSPAdd(a6)
		move.l	d0,a4

		bsr.w	pal_fixwerte
		movem.l	(a7)+,d3-a6

		rts				
;---------------------------------------------------------------------
pal_rgb2YIQ:
		movem.l	d3-a6,-(a7)
		move.l	mathbase(a5),a6
		move.l	d1,d4
		jsr	_LVOSPFlt(a6)
		move.l	d0,d3	;Y
		move.l	d4,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d4	;I
		move.l	d2,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d5	;Q

		move.l	d3,d0
		move.l	#$9916873f,d1	;.299
		jsr	_LVOspmul(a6)
		move.l	d0,d6
		move.l	d4,d0
		move.l	#$9645a240,d1	;0.587
		jsr	_LVOspmul(a6)
		move.l	d6,d1
		jsr	_LVOspadd(a6)
		move.l	d0,d6
		move.l	d5,d0
		move.l	#$e978d53d,d1	;0.114
		jsr	_LVOspmul(a6)
		move.l	d6,d1
		jsr	_LVOspadd(a6)
		move.l	d0,a2		;=Y

		move.l	d3,d0
		move.l	a2,d1
		jsr	_LVOSPSub(a6)	;(r-y)
		move.l	d0,d6
		move.l	#$bd70a440,d1	;.74
		jsr	_LVOSPMul(a6)
		move.l	d0,d7
		move.l	d5,d0
		move.l	a2,d1
		jsr	_LVOSPSub(a6)	;b-y
		move.l	d0,a4
		move.l	#$8a3d713f,d1	;.27
		jsr	_LVOSPMul(a6)

		move.l	d0,d1
		move.l	d7,d0
		jsr	_LVOSPSub(a6)
		move.l	d0,a3		;I		

		move.l	d6,d0		;r-y
		move.l	#$f5c28f3f,d1	;.48
		jsr	_LVOSPMul(a6)
		move.l	d0,d6
		move.l	a4,d0		;b-y
		move.l	#$d1eb853f,d1	;.41
		jsr	_LVOSPMul(a6)
		move.l	d6,d1
		jsr	_LVOSPAdd(a6)
		move.l	d0,a4		;Q
		
		move.l	a4,d0
		jsr	_LVOspfix(a6)
		move.l	d0,-(a7)
		move.l	a3,d0
		jsr	_LVOspfix(a6)
		move.l	d0,-(a7)
		move.l	a2,d0
		jsr	_LVOspfix(a6)
		move.l	d0,-(a7)

		movem.l	(a7)+,d0-d2
		movem.l	(a7)+,d3-a6
		rts

pal_yiq2rgb:
		movem.l	d3-a6,-(a7)
		move.l	mathbase(a5),a6
		move.l	d1,d4
		jsr	_LVOSPFlt(a6)
		move.l	d0,d3	;Y
		move.l	d4,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d4	;I
		move.l	d2,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d5	;Q

		move.l	d5,d0
		move.l	#$9ef9db40,d1
		jsr	_LVOSPMul(a6)
		move.l	d0,d6
		move.l	d4,d0
		move.l	#$f4bc6a40,d1
		jsr	_LVOSPMul(a6)
		move.l	d3,d1
		jsr	_LVOSPAdd(a6)	;y+0.956*I
		move.l	d6,d1
		jsr	_LVOSPAdd(a6)	;+.621*Q
		move.l	d0,a2		;R
		
		move.l	d5,d0
		move.l	#$a5a1cb40,d1	;.647
		jsr	_LVOSPMul(a6)
		move.l	d0,d6
		move.l	d4,d0
		move.l	#$8b43963f,d1	;.272
		jsr	_LVOSPMul(a6)
		move.l	d0,d1
		move.l	d3,d0
		jsr	_LVOSPSub(a6)
		move.l	d6,d1
		jsr	_LVOSPSub(a6)
		move.l	d0,a3		;G

		move.l	d5,d0
		move.l	#$d9db2341,d1	;1.702
		jsr	_LVOSPMul(a6)
		move.l	d0,d6
		move.l	d4,d0
		move.l	#$8d70a441,d1	;1.105
		jsr	_LVOSPMul(a6)
		move.l	d0,d1
		move.l	d3,d0
		jsr	_LVOSPSub(a6)
		move.l	d6,d1
		jsr	_LVOSPAdd(a6)
		move.l	d0,a4		;B

		bsr.b	pal_fixwerte
		movem.l	(a7)+,d3-a6
		rts				

;----------------------------------------------------------------------
pal_fixwerte:
		move.l	a4,d0
		jsr	_LVOspfix(a6)
		move.l	d0,d2
		tst.l	d2
		bpl.b	.rpo
		moveq	#0,d2
		bra.b	.rok
.rpo		cmp.l	#255,d2
		bls.b	.rok
		move.w	#255,d2
.rok:		move.l	d2,-(a7)
		move.l	a3,d0
		jsr	_LVOspfix(a6)
		move.l	d0,d3
		tst.l	d3
		bpl.b	.gpo
		moveq	#0,d3
		bra.b	.gok
.gpo		cmp.l	#255,d3
		bls.b	.gok
		move.w	#255,d3
.gok:		move.l	d3,-(a7)
		move.l	a2,d0
		jsr	_LVOspfix(a6)
		move.l	d0,d4
		tst.l	d4
		bpl.b	.bpo
		moveq	#0,d4
		bra.b	.bok
.bpo		cmp.l	#255,d4
		bls.b	.bok
		move.w	#255,d4
.bok
		move.l	d4,-(a7)
		movem.l	(a7)+,d0-d2
		rts
;-------------------------------------------------------------------
pal_newcolorsystem:
		lea	useRGB(a5),a0
		move.l	a0,a1
		clr.l	(a1)+
		clr.b	(a1)
		ext.l	d5
		st	(a0,d5.l)
		
		lea	TAG_colorsys,a0
		move.l	d5,(a0)
		bsr.b	pal_setsystem		
		bsr.b	pal_setaktslider
		bra.w	pal_wait

pal_setaktslider:
		move.l	pal_aktred(a5),d0
		move.l	pal_aktgreen(a5),d1
		move.l	pal_aktblue(a5),d2

		tst.b	usergb(a5)
		bne.b	.w3
.w0:		tst.b	usecmy(a5)
		beq.b	.we
		bsr.w	pal_rgb2cmy
.we:		tst.b	usehsv(a5)
		beq.b	.w1
		bsr.w	pal_rgb2hsv
.w1		tst.b	useyuv(a5)
		beq.b	.w2
		bsr.w	pal_rgb2yuv
.w2		tst.b	useyiq(a5)
		beq.b	.w3
		bsr.w	pal_rgb2yiq
.w3
		move.l	d0,redlevel(a5)
		move.l	d1,greenlevel(a5)
		move.l	d2,bluelevel(a5)

		move.l	d1,d4
		move.l	d2,d5

		move.w	#GD_pal_red,d1
		bsr.b	pal_setslider
		move.l	d4,d0
		move.w	#GD_pal_green,d1
		bsr.b	pal_setslider
		move.l	d5,d0
		move.w	#GD_pal_blue,d1
		bra.b	pal_setslider
		
pal_setsystem:
;d5 Systemnummer
		lea	formattab(pc),a4
		mulu	#18,d5
		add.l	d5,a4
		moveq	#0,d5
		moveq	#3-1,d7
		lea	formattagstab(pc),a6
.nsl:
		move.l	(a6)+,a3
;		lea	pal_format(pc),a3
		move.w	(a4)+,d0
		move.b	d0,(a3)
		move.l	(a6)+,a3
;		lea	formattags(pc),a3
		move.w	(a4)+,d0
		ext.l	d0
		move.l	d0,4(a3)	;min
		move.w	(a4)+,d0
		ext.l	d0
		move.l	d0,12(a3)	;max
		move.l	palwinWnd2(a5),a1
		sub.l	a2,a2
		move.l	d5,d0
		lsl.l	#2,d0
		lea	palwingadgets2,a0
		move.l	(a0,d0.w),a0
		move.l	a6,-(a7)
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
		move.l	(a7)+,a6
		addq.w	#1,d5
		dbra	d7,.nsl
		rts

pal_setslider:
		lea	pal_farbwert(pc),a4
		move.l	d0,(a4)
		lsl.l	#2,d1
		lea	palwinGadgets2,a0
		move.l	(a0,d1),a0
		move.l	palwinWnd2(a5),a1
		sub.l	a2,a2
		lea	pal_colortag(pc),a3
		move.l	gadbase(a5),a6
		jmp	_LVOGT_SetGadgetAttrsA(a6)

pal_setrangeslider:
		lea	pal_colorbanktag(pc),a3
		move.l	d0,4(a3)
		move.w	anzcolor(a5),d0
		move.l	d0,d2
		cmp.w	#32,d0
		blo.b	.w
		moveq	#28,d0
.w		move.l	d0,12(a3)
		move.l	d2,20(a3)

		lsl.l	#2,d1
		lea	palwinGadgets2,a0
		move.l	(a0,d1),a0
		move.l	palwinWnd2(a5),a1
		sub.l	a2,a2
		move.l	gadbase(a5),a6
		jmp	_LVOGT_SetGadgetAttrsA(a6)

pal_colortag:
		dc.l	GTSL_Level
pal_farbwert:	dc.l	0
		dc.l	TAG_DONE


formattags1:
		dc.l	GTSL_Min,0
		dc.l	GTSL_Max,255
		dc.l	GTSL_LevelFormat,pal_format1
		dc.l	TAG_DONE
formattags2:
		dc.l	GTSL_Min,0
		dc.l	GTSL_Max,255
		dc.l	GTSL_LevelFormat,pal_format2
		dc.l	TAG_DONE
formattags3:
		dc.l	GTSL_Min,0
		dc.l	GTSL_Max,255
		dc.l	GTSL_LevelFormat,pal_format3
		dc.l	TAG_DONE

pal_colorbanktag:
		dc.l	GTSC_Top,0
		dc.l	GTSC_Visible,0
		dc.l	GTSC_Total,0
		dc.l	TAG_DONE
		
pal_format1:		dc.b	'R:%ld ',0
pal_format2:		dc.b	'G:%ld ',0
pal_format3:		dc.b	'B:%ld ',0

	even
formattab:		dc.w	' R',0,255,' G',0,255,' B',0,255
			dc.w	' C',0,255,' M',0,255,' Y',0,255
			dc.w	' H',0,359,' S',0,255,' V',0,255
			dc.w	' Y',0,255,' U',-111,111,' V',-156,156
			dc.w	' Y',0,255,' I',-151,151,' Q',-133,133
			
formattagstab:	dc.l	pal_format1,formattags1,pal_format2,formattags2
		dc.l	pal_format3,formattags3

;---------------------------------------------------------------------
pal_ende:
		lea	colorpuffer1,a0
		lea	farbtab8(a5),a1
		lea	farbtab4(a5),a2
		move.l	(a0)+,(a1)+
		moveq	#0,d7
		move.w	anzcolor(a5),d7
.nc:		move.l	(a0)+,d0
		move.l	(a0)+,d1
		move.l	(a0)+,d2
		move.l	d0,(a1)+
		move.l	d1,(a1)+
		move.l	d2,(a1)+
		rol.l	#8,d0
		lsl.w	#4,d0
		rol.l	#8,d1
		move.b	d1,d0
		and.b	#$f0,d0
		rol.l	#8,d2
		lsr.b	#4,d2
		or.b	d2,d0
		move.w	d0,(a2)+
		dbra	d7,.nc

		move.l	scr4(a5),a0
		move.l	intbase(a5),a6
		jsr	_LVOScreentoBack(a6)
		move.l	scr5(a5),a0
		jsr	_LVOScreentoBack(a6)
		move.l	scr1(a5),a0
		jsr	_LVOScreentoBack(a6)

		lea	palwinWnd1(a5),a0
		move.l	a0,window(a5)
		lea	palwinGlist1(a5),a0
		move.l	a0,Glist(a5)
		move.l	#'NOGA',d7
		jsr	gt_CloseWindow

		moveq	#0,d7
		bsr.w	CloseDownpalScreen

		move.l	visualinfo(a5),a0
		move.l	gadbase(a5),a6
		jsr	_LVOFreeVisualInfo(a6)
		move.l	tmpvisual(a5),visualinfo(a5)

		lea	palwinWnd2(a5),a0
		move.l	a0,window(a5)
		lea	palwinGlist2(a5),a0
		move.l	a0,Glist(a5)
		moveq	#0,d7
		jsr	gt_CloseWindow
		moveq	#-1,d7
		bsr.w	CloseDownpalScreen

		jsr	CloseViewWindow

		jsr	CloseDownViewScreen

		tst.b	merk1(a5)	;Wurde remappt ?
		beq.b	.w		;nein
		move.l	rndr_histogram(a5),d0
		beq.b	.w
		move.l	d0,a0
		move.l	renderbase(a5),a6
		jsr	_LVODeleteHistogram(a6)
		clr.l	rndr_histogram(a5)
.w
		bsr.w	memcheck
		
		lea	readymsg(pc),a4
		bsr.w	status

		jsr	APR_Save2Tmp(a5)
		
		jmp	waitaction
makeborder:
		addq.w	#1,d0

		lea	palcol1(pc),a0
		move.b	#1,(a0)
		lea	palcol2(pc),a1
		move.b	#2,(a1)
		tst.l	d7
		beq.b	.nborder
		move.b	#2,(a0)
		move.b	#1,(a1)
.nborder:	
		lea	palstruck,a1
		moveq	#4,d1
		move.l	free2(a5),a0	;rastport
		move.l	intbase(a5),a6
		jmp	_LVODrawBorder(a6)


palstruck:
		dc.w	-1,-1	;XY origin relative to container TopLeft
palcol1:	dc.b	2,0,RP_JAM1	;front pen, back pen and drawmode
		dc.b	3	;number of XY vectors
		dc.l	.border	;pointer to XY vectors
		dc.l	.bstruck1

.border:
		dc.w	0,9
		dc.w	0,0
		dc.w	9,0

.bstruck1
		dc.w	-1,-1	
palcol2:	dc.b	1,0,RP_JAM1
		dc.b	3	
		dc.l	.border1
		dc.l	0	
.border1:
		dc.w	10,0
		dc.w	10,9
		dc.w	1,9

pal_numbertags:
		dc.l	GTNM_Number,0
		dc.l	TAG_DONE

;======================================================================
;------ PackColors ----- versucht palette zu optimieren 
;======================================================================

packcolor:
		tst.l	picmem(a5)
		bne.b	.picok
		moveq	#APSE_NOBITMAP,d3
		rts

.picok:
		tst.w	loadflag(a5)
		bne.b	.packok
		lea	noimageload,a4
		bra.w	status
.packok:
		move.b	ham(a5),d0
		add.b	ham8(a5),d0
		add.b	ehb(a5),d0
		tst.b	d0
		beq.b	.packok1
		lea	nohammsg(pc),a4
		bra.w	status
.packok1:
;		move.l	mainwinWnD(a5),a0
;		bsr.w	setwaitpointer
		
;berechne speicher für Chunkys

		move.l	bytebreite(a5),d0
		lsl.l	#3,d0
		move.l	d0,d7
		mulu	hoehe(a5),d0
		move.l	d0,free1(a5)
		add.l	#256*4+256,d0
		add.l	d7,d0

		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,rgbmem(a5)
		bne.b	.memok
.we		lea	notenoughtmsg(pc),a4
		bra.w	status
;		move.l	mainwinWnD(a5),a0
;		bra.w	clearwaitpointer

.memok:
		add.l	free1(a5),d0
		move.l	d0,free2(a5)	;countertab
		add.l	#256*4,d0
		move.l	d0,free3(a5)
		add.l	#256,d0
		move.l	d0,free4(a5)	;chunkyline

		bsr.l	convtab
		
;mäch chunkys
		lea	rgbmap(a5),a1	;puffer für BitmapPointerTab
		move.l	a1,a0
		move.l	Picmem(a5),d0
		moveq	#0,d1
		move.b	planes(a5),d1		
		subq.w	#1,d1
.ncp:		move.l	d0,(a1)+	;erzeuge bitmappointer Tab
		add.l	oneplanesize(a5),d0
		dbra	d1,.ncp

		move.l	rgbmem(a5),a1	;Chunky-Buffer
		move.l	bytebreite(a5),d0
		move.w	hoehe(a5),d1
		moveq	#0,d2
		move.b	planes(a5),d2
		move.l	d0,d3
		move.l	renderbase(a5),a6

		sub.l	a2,a2

		jsr	_LVOPlanar2Chunky(a6)

;Zähle Colors
		bsr.w	openprocess
		lea	pc_countmsg(pc),a1
		move.w	hoehe(a5),d0
		bsr.w	initprocess
		
		move.l	free2(a5),a0
		move.l	rgbmem(a5),a1
		move.w	hoehe(a5),d7
		move.l	bytebreite(a5),d5
		lsl.l	#3,d5
		sub.w	breite(a5),d5		;Modulo
		subq.w	#1,d7
.nl:		move.w	breite(a5),d6
		subq.w	#1,d6
.nch:		moveq	#0,d0
		move.b	(a1)+,d0
		add.w	d0,d0
		add.w	d0,d0
		add.l	#1,(a0,d0.w)
		dbra	d6,.nch
		add.l	d5,a1		;modulo für eine Zeile

		bsr.w	doprocess
		tst.l	d0
		bne.b	.ok

		move.l	rgbmem(a5),a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
		clr.l	rgbmem(a5)
		bsr.w	clearprocess
		move.l	mainwinWnD(a5),a0
		bsr.w	clearwaitpointer
		lea	pc_abortmsg(pc),a4
		bra.w	status
;		bra.l	waitaction
.ok:
		dbra	d7,.nl

		bsr.w	clearprocess
		
		lea	cb_pufferfarbtab,a3
		move.w	#256-1,d7
.nclr:		clr.l	(a3)+
		dbra	d7,.nclr
;werte aus
pc_wertaus:
		move.l	free2(a5),a0	;counttab
		move.l	free3(a5),a1	;chunky convert tab
		lea	farbtab8pure,a2
		lea	cb_pufferfarbtab,a3
		move.w	anzcolor(a5),d7
		subq.w	#1,d7
		moveq	#0,d6		;farb counter
		moveq	#0,d3		;counter für doppelte einträge
.nc:		move.l	(a2)+,d1	;farbe
		move.l	(a0)+,d0	;anzahl
		bne.b	.fok
		move.b	d6,(a1)+
		dbra	d7,.nc
		bra.b	.endc
.fok:
		lea	cb_pufferfarbtab,a4 ;checke doppelte einträge
		move.l	d6,d5		    ;in Colortab
		tst.w	d5
		beq.b	.nodub
		subq.w	#1,d5
		moveq	#0,d4
.cnc:		cmp.l	(a4)+,d1
		beq.b	.gleich
		add.w	#1,d4
		dbra	d5,.cnc
		bra.b	.nodub		;kein eintrag gefunden
.gleich:		
		move.b	d4,(a1)+
		addq.w	#1,d3
		bra.b	.weiter
		
.nodub:		move.b	d6,(a1)+
		move.l	d1,(a3)+
		addq.w	#1,d6
.weiter:	dbra	d7,.nc
.endc:
		move.w	anzcolor(a5),d7
		add.w	d3,d6
		sub.w	d6,d7
		bne.b	pc_io
		tst.w	d3
		bne.b	pc_io

;		move.l	mainwinWnD(a5),a0
;		bsr.w	clearwaitpointer

		lea	pack1msg(pc),a1
		lea	packokmsg(pc),a2
		sub.l	a3,a3
		sub.l	a4,a4
		lea	tagitemliste1,a0
		move.l	reqtbase(a5),a6
		jsr	_LVOrtEZRequestA(a6)
		bra.w	pc_wech

pc_io:
		lea	pc_array(pc),a4
		move.l	d7,(a4)
		move.l	d3,4(a4)

		lea	pc_foundmsg(pc),a1
		lea	foundokmsg(pc),a2
		sub.l	a3,a3
		lea	tagitemliste1,a0
		move.l	reqtbase(a5),a6
		jsr	_LVOrtEZRequestA(a6)
		tst.l	d0
		bne.b	pc_render
		
		lea	packcanceled(pc),a4
		bsr.w	status
		bra.w	pc_wech
pc_render:
;		move.l	mainwinWnD(a5),a0
;		bsr.w	clearwaitpointer

;		move.l	mainwinWnD(a5),a0
;		bsr.w	setwaitpointer

		lea	APG_PicMap(a5),a0	
		moveq	#0,d0
		move.b	APG_planes(a5),d0
		moveq	#0,d1
		moveq	#0,d2
		move.w	APG_ImageWidth(a5),d1
		move.w	APG_ImageHeight(a5),d2	;höhe
		move.l	APG_Gfxbase(a5),a6
		jsr	_LVOinitbitmap(a6)

		move.l	picmem(a5),d0
		lea	APG_Picmap+8(a5),a0
		moveq	#0,d7
		move.b	APG_Planes(a5),d7
		subq.w	#1,d7
.np		move.l	d0,(a0)+
		add.l	APG_Oneplanesize(a5),d0
		dbra	d7,.np

		bsr.w	openprocess
		lea	pc_convpalmsg(pc),a1
		move.w	hoehe(a5),d0
		move.l	#'STOP',d1
		bsr.w	initprocess

		move.l	rgbmem(a5),a0
		move.l	free3(a5),a1
		move.w	hoehe(a5),d7
		move.l	bytebreite(a5),d5
		lsl.l	#3,d5
		sub.w	breite(a5),d5		;Modulo
		subq.w	#1,d7
		sub.l	a4,a4	;linecounter
		moveq	#0,d4
		move.b	planes(a5),d4
.nl:		move.w	breite(a5),d6
		subq.w	#1,d6
		move.l	free4(a5),a2	;chunkyline
.nch:		moveq	#0,d0
		move.b	(a0)+,d0
		move.b	(a1,d0.w),d0
	;	ror.b	d4,d0		;für chunky2bpl vorshiften
		move.b	d0,(a2)+
		dbra	d6,.nch
		bsr.w	pc_copyline
		add.l	d5,a0		;modulo für eine Zeile
		addq.l	#1,a4
		dbra	d7,.nl

		bsr.w	clearprocess

;mäch neue Farbtab

		lea	farbtab8+4(a5),a0
		lea	farbtab4(a5),a1
		lea	cb_pufferfarbtab,a2
		move.w	anzcolor(a5),d7
		move.l	pc_array(pc),d6
		add.l	pc_array+4(pc),d6
		sub.w	d6,d7
		subq.w	#1,d7
.nc		move.l	(a2)+,d0

		c24to3Byte d0,d1,d2

		move.l	d0,d3
		ror.l	#8,d0
		move.l	d0,(a0)+
		lsl.w	#4,d3
		move.b	d1,d3
		ror.l	#8,d1
		move.l	d1,(a0)+
		move.l	d2,d0
		ror.l	#8,d2
		move.l	d2,(a0)+
		and.w	#$ff0,d3
		and.b	#$f0,d0
		lsr.b	#4,d0
		or.b	d0,d3
		move.w	d3,(a1)+
		dbra	d7,.nc

		move.l	pc_array(pc),d6
		add.l	pc_array+4(pc),d6
		subq.w	#1,d6
.ncc:		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
 		clr.w	(a1)+
		dbra	d6,.ncc

		jsr	APR_Save2TMP(a5)

pc_wech:
		move.l	#'NOCL',d7

		move.l	rgbmem(a5),a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
		clr.l	rgbmem(a5)
		rts	
	
pc_countmsg:	dc.b	'Counting colors ...',0
pc_convpalmsg:	dc.b	'Convert palette ...',0
pc_abortmsg:	dc.b	'Counting aborted!',0
	even
pc_copyline:
		movem.l	d0-a6,-(a7)

;-------------------------------------------------------------------------
	ifne	final
		lea	lastreqcode(pc),a0
		move.l	(a0),a0
		cmp.l	lastreqcheck(a5),a0
		beq.b	.codeok
		move.l	(a0),reqtbase(a5)
	endc
;--------------------------------------------------------------------------
.codeok:
		move.l	free4(a5),a0
		lea	APG_PicMap(a5),a1
		sub.l	a2,a2
		moveq	#0,d0
		moveq	#0,d1
		move.w	breite(a5),d2
		moveq	#1,d3
		moveq	#0,d4
		move.l	a4,d5

		move.l	renderbase(a5),a6
		jsr	_LVOChunky2BitmapA(a6)

		movem.l	(a7)+,d0-a6

		bsr.w	doprocess
;		tst.l	d0
;		beq	.abort
		rts

.abort:
		addq.l	#4,a7

		bsr.w	clearprocess
		lea	packcanceled(pc),a4
		bsr.w	status
		bra.w	pc_wech
		

nohammsg:	dc.b	'No ColorPack with HAM or EHB-Images',0
notenoughtmsg:	dc.b	'Not enough memory for this Operation!',0
pack1msg:	dc.b	'No double or unused Colors found!',10
		dc.b	'    No compression possible!',0
packokmsg:	dc.b	'Ok',0
pc_foundmsg:	dc.b	'Found %ld unused and %ld double colors!',10
		dc.b	'         Compress palette?',0
foundokmsg:	dc.b	'Yes|No',0
packcolormsg:	dc.b	'Pack palette ....',0
packcanceled:	dc.b	'Pack Colors canceled!',0
	even
pc_array:	dc.l	0,0,0

;***************************************************************************
;*---------------------------- Color-Bias ---------------------------------*
;***************************************************************************
;
;		C24to12	dx,dy
;		   
;		"Cut rgb24 to rgb12"
;
;		transformiert 24Bit-RGB in 12Bit-RGB.
;		die unteren 4 Bit jeder Farbkomponente
;		werden ohne Runden abgeschnitten.
;
;	>	dx.l	24Bit-Source	(wird zerstört)
;	<	dy.w	12Bit-Dest

C24to12		macro
		moveq	#0,\2
		lsr.w	#4,\1		; ..Rr.GgB
		and.l	#$f00f0f,\1	; ..R..G.B
		move.b	\1,\2		; xxxxxx.B
		lsr.w	#4,\1		; ..R...G.
		or.b	\1,\2		; xxxxxxGB
		swap	\1		; ..G...R.
		lsl.w	#4,\1		; ..G..R..
		or.w	\1,\2		; xxxx.RGB
		endm

;========================================================================
;
;		R24to24	dx,dy
;		   
;		"Round rgb24 to rgb24"
;
;		transformiert 24Bit-RGB in 24Bit-RGB,
;		in dem nur die höchstwertigen 4 Bit
;		jeder Farbkomponente beibehalten werden.
;		Die niederwertigen 4 Bit werden gerundet.
;
;		Beispiel:	$0873fe	-> $1070f0
;
;	>	dx.l	24Bit-Source
;		dy.w	Trash-Register
;	<	dx.l	24Bit-Dest


R24to24		macro
		swap	\1
		moveq	#0,\2
		move.b	\1,\2
		addq.w	#8,\2
		and.w	#$1f0,\2
		bclr	#8,\2
		beq.b	*+6
		move.w	#$f0,\2
		move.b	\2,\1
		swap	\1
		move.b	\1,\2
		addq.w	#8,\2
		and.w	#$1f0,\2
		bclr	#8,\2
		beq.b	*+6
		move.w	#$f0,\2
		move.b	\2,\1
		ror.w	#8,\1
		move.b	\1,\2
		addq.w	#8,\2
		and.w	#$1f0,\2
		bclr	#8,\2
		beq.b	*+6
		move.w	#$f0,\2
		move.b	\2,\1
		ror.w	#8,\1
		endm

;---------------------------------------------------------------------------
cantopenmsg:	dc.b	'Error open operatorscreen!',0
	even
colorbias:
		tst.w	loadflag(a5)
		bne.b	.lok		;Es wurde was geladen
		lea	noimageload,a4
		jsr	status		;kein Bild geladen
		bra.l	waitaction

.lok:
		move.l	#OPV_COLOR_NOTTRUE,d0		;Kein Truecolor zulassen
		jsr	APR_OpenVisualScreen(a5)

		tst.l	d0
		bpl	.screenok
		lea	cantopenmsg(pc),a4
		bsr	status		
		moveq	#-1,d0
		bra.l	waitaction

.screenok:
		move.l	vi_window(a5),a1	;Fensteradresse
		move.l	50(a1),a1		;Rastport (Ziel)
		move.l	a1,viewRastport(a5)

;---------------------------------------------------------------------------------
;öffne kontroll window

		lea	biaswinWindowTags,a0
		move.l	a0,windowtaglist(a5)
		lea	biaswinWG+4,a0
		move.l	a0,gadgets(a5)
		lea	biaswinSC+4,a0
		move.l	a0,winscreen(a5)
		lea	biaswinWnd(a5),a0
		move.l	a0,window(a5)
		lea	biaswinGlist(a5),a0
		move.l	a0,Glist(a5)
		lea	biaswinNgads,a0
		move.l	a0,NGads(a5)
		lea	biaswinGTypes,a0
		move.l	a0,GTypes(a5)
		lea	biaswinGadgets,a0
		move.l	a0,WinGadgets(a5)
		move.w	#biaswin_CNT,win_CNT(a5)
		lea	biaswinGtags,a0
		move.l	a0,windowtags(a5)
		move.l	vi_screen(a5),screenbase(a5)

		move.w	#292,WinWidth(a5)
		move.w	#110+12,WinHeight(a5)

		move.l	#292,d0
		bsr	computex

		move.l	vi_screen(a5),a2
		moveq	#0,d0
		move.w	sc_width(a2),d1
		sub.w	d0,d1
		move.w	d1,WinLeft(a5)

		move.l	#110+12,d0
		bsr	computey

		move.w	sc_height(a2),d1
		sub.w	d0,d1
		move.w	d1,WinTop(a5)

		lea	BiasWinL,a0
		move.l	a0,WinL(a5)
		lea	BiasWinT,a0
		move.l	a0,WinT(a5)
		lea	BiasWinW,a0
		move.l	a0,WinW(a5)
		lea	BiasWinH,a0
		move.l	a0,WinH(a5)

		bsr.l	openwindowF	;öffne Mainwindow

		move.l	viewWnd(a5),a0
		move.l	intbase(a5),a6
		jsr	_LVOActivateWindow(a6)

cb_maxcolor	=	APG_Free1

;bereite Colortabellen vor
cb_checkcolormap:

		move.l	vi_screen(a5),a0
		lea	sc_rastport(a0),a0
		move.l	rp_bitmap(a0),a0
		move.l	#BMA_DEPTH,d1
		move.l	gfxbase(a5),a6
		jsr	_LVOGetBitMapAttr(a6)
		moveq	#1,d7
		lsl.l	d0,d7
		move.l	d7,cb_maxcolor(a5)
		
		move.l	vi_screen(a5),a0
		lea	sc_viewport(a0),a0
		move.l	4(a0),a0	;Colormap

;		move.w	cm_Count(a0),d7	;Anzcolor ?
		move.l	cm_colorTable(a0),a1	;Colortable
		move.l	cm_LowColorBits(a0),a2	;Tab mit den unteren Bits

		subq.l	#1,d7
		lea	Colorpuffer1,a0
		lea	Colorpuffer2,a3

.nc:
		move.w	(a1)+,d0
		move.w	(a2)+,d1

		moveq	#0,d2
		moveq	#0,d3
		move.w	d0,d2
		and.w	#$f00,d2
		lsl.w	#4,d2
		move.w	d1,d3
		and.w	#$f00,d3
		or.w	d3,d2
		lsr.w	#8,d2
		move.w	d2,(a0)+	;Rot
		move.w	d2,(a3)+

		moveq	#0,d2
		moveq	#0,d3
		move.w	d0,d2
		and.w	#$f0,d2
		move.w	d1,d3
		and.w	#$f0,d3
		lsr.w	#4,d3
		or.w	d3,d2
		move.w	d2,(a0)+	;grün		
		move.w	d2,(a3)+

		moveq	#0,d2
		moveq	#0,d3
		move.w	d0,d2
		and.w	#$f,d2
		lsl.w	#4,d2
		move.w	d1,d3
		and.w	#$f,d3
		or.w	d3,d2
		move.w	d2,(a0)+	;blau
		move.w	d2,(a3)+
		dbra	d7,.nc			

		lea	colorlevel(a5),a0
		moveq	#7-1,d7
.cl:		clr.l	(a0)+
		dbra	d7,.cl

		move.l	vi_window(a5),a0
		move.l	intbase(a5),a6
		jsr	_LVOViewPortAddress(a6)
		move.l	d0,biasviewport(a5)

;---------------------------------------------------------------
cb_waitfor:
		move.l	BiaswinWnd(a5),a0
		move.l	WD_UserPort(a0),a0
		move.l	a0,WinMsgPort1(a5)
		moveq	#0,d6
		moveq	#0,d0
		move.b	15(a0),d0
		bset	d0,d6

		move.l	vi_window(a5),a0
		move.l	WD_UserPort(a0),a0
		move.l	a0,WinMsgPort2(a5)

	*--------------- SignalBits setzen ---------------*
		moveq	#0,d0
		move.b	15(a0),d0
		bset	d0,d6
		move.l	d6,SignalBits(a5)

	*--------------------- Wait ---------------------*
cb_Wait:	move.l	SignalBits(a5),d0
	;	or.w	#$1000,d0		;Break-Signal
		move.l	4.w,a6
		jsr	_LVOWait(a6)

	*------- War es ein ControlscreenMessage ------*
		move.l	WinMsgPort1(a5),d2
		beq.s	.NoPort
		move.l	d2,a0
		moveq	#0,d1
		move.b	15(a0),d1
		btst	d1,d0
		bne.b	cb_WartenWinPort1	;ControlScreen

	*----- war es eine Window-Message ----*
.NoPort:	move.l	WinMsgPort2(a5),d2
		beq.s	.NoMain
		move.l	d2,a0
		move.b	15(a0),d1
		btst	d1,d0
		bne.b	cb_WartenWinPort2
.NoMain:
		bra.b	cb_Wait

cb_Warten:	
cb_WartenWinPort1:
		move.l	WinMsgPort1(a5),d0
		beq.s	cb_WartenWinPort2
		move.l	d0,a0
		move.l	gadbase(a5),a6
		jsr	_LVOGT_getimsg(a6)
		tst.l	d0
		beq.b	cb_WartenWinPort2
		bra.b	cb_WindowMessage1

cb_WartenWinPort2:
		move.l	WinMsgPort2(a5),d0
		beq.b	cb_wait
			move.l	d0,a0
		move.l	gadbase(a5),a6
		jsr	_LVOGT_getimsg(a6)
		tst.l	d0
		beq.b	cb_wait
		bra.b	cb_WindowMessage2

;--- Abfrage im Controlscreen

cb_WindowMessage1:
		move.l	d0,a1			;muss nach a1
		move.l	im_Class(a1),d4		;Msg-Type
		move.w	im_Code(a1),d5		;Untergruppe
		move.l	im_IAddress(a1),a4	;Adr. für Gadgets
		move.l	gadbase(a5),a6
		jsr	_LVOGT_replyiMsg(a6)	;quittiere Msg in a1

		cmp.l	#IDCMP_NEWSIZE,d4
		beq	cb_newsize		;Zip Gadget
		cmp.l	#IDCMP_CLOSEWINDOW,d4
		beq	cb_ende
		cmp.l	#GADGETdown,d4
		beq.w	cb_slider	;Es wurde ein Slidergadet gedrückt
		cmp.l	#GADGETUP,d4
		beq.w	cb_gads
		cmp.l	#IDCMP_VANILLAKEY,d4
		beq.w	cb_tast		;es wurde eine Taste gedrückt

		bra.b	cb_warten


;abfrage im ViewWindow
cb_WindowMessage2:
		move.l	d0,a1			;muss nach a1
		move.l	im_Class(a1),d4		;Msg-Type
		move.w	im_Code(a1),d5		;Untergruppe
		move.l	im_Seconds(a1),d6	;Systemzeit
		move.l	im_IAddress(a1),a4	;Adr. für Gadgets
		move.l	gadbase(a5),a6
		jsr	_LVOGT_replyiMsg(a6)	;quittiere Msg in a1

		cmp.l	#VANILLAKEY,d4
		beq.w	cb_tast		;es wurde eine Taste gedrückt
		bra.w	cb_warten

cb_sliderwait:
		move.l	BiaswinWnd(a5),a0
		jsr	wait		;Warte auf eingabe im Prefswin

		cmp.l	#GADGETUP,d4
		beq.b	cb_wait1		;Slidergadet wurde losgelassen 

		cmp.l	#IDCMP_MOUSEMOVE,d4
		beq.b	cb_slider
		bra.b	cb_sliderwait

cb_wait1:
		move.l	viewWnd(a5),a0
		move.l	intbase(a5),a6
		jsr	_LVOActivateWindow(a6)
		bra.w	cb_wait

;Zip Gadget wurde geklickt
cb_newsize:
		move.l	BiaswinWnd(a5),a0
		move.l	gadbase(a5),a6
		jsr	_LVOGT_BeginRefresh(a6)
		move.l	BiaswinWnd(a5),a0
		moveq	#-1,d0
		jsr	_LVOGT_EndRefresh(a6)
		bra	cb_wait
		
cb_slider:
		moveq	#0,d0
		move.w	38(a4),d0
		cmp.w	#GD_color,d0
		beq.b	cb_col
		cmp.w	#GD_bright,d0
		beq.b	cb_bri
		cmp.w	#GD_contrast,d0
		beq.b	cb_cont
		cmp.w	#GD_red,d0
		beq.b	cb_red
		cmp.w	#GD_green,d0
		beq.b	cb_green
		cmp.w	#GD_blue,d0
		beq.b	cb_blue
		cmp.w	#GD_gamma,d0
		beq.b	cb_gamma
		bra.w	cb_wait

cb_col:
		ext.l	d5
		move.l	d5,colorlevel(a5)
		bra.w	cb_setit
cb_bri:
		ext.l	d5
		move.l	d5,brightlevel(a5)		
		bra.b	cb_setit
cb_cont:
		ext.l	d5
		move.l	d5,contrastlevel(a5)
		bra.b	cb_setit
cb_red:
		ext.l	d5
		move.l	d5,redlevel(a5)
		bra.b	cb_setit
cb_green:
		ext.l	d5
		move.l	d5,greenlevel(a5)
		bra.b	cb_setit
cb_blue:
		ext.l	d5
		move.l	d5,bluelevel(a5)
		bra.w	cb_setit
cb_gamma:

;gamma auf einen wert zwischen 0 und 5 bringen
;negative werte werden 1/g berechnet

		move.l	mathbase(a5),a6

		ext.l	d5
		moveq	#0,d0
		tst.l	d5
		beq	.s	;level ist null
		moveq	#0,d7
		tst.l	d5
		bpl	.gn	
		moveq	#-1,d7	;kleiner null
.gn:
		move.l	d5,d0
		jsr 	_LVOSPFlt(a6)
;		move.l	#$cccccd3c,d1	;5/100=0.05
;		move.l	#$a3d70a3c,d1	;4/100=0.04
		move.l	#$f5c28f3b,d1	;3/100=0.04
		jsr	_LVOSPMul(a6)
		tst.l	d7
		beq	.s
		move.l	d0,d1
		move.l	#$80000041,d0
		jsr	_LVOSPSub(a6)
		move.l	d0,gammalevel(a5)
		bra	cb_setit
.s
		move.l	#$80000041,d1
		jsr	_LVOSPAdd(a6)
		move.l	d0,d1
		move.l	#$80000041,d0
		jsr	_LVOSPDiv(a6)
		move.l	d0,gammalevel(a5)
		

cb_setit
		bsr.w	cb_setcolor
		bsr.w	cb_makecolortab
		bra.w	cb_sliderwait

cb_gads:
		moveq	#0,d0
		move.w	38(a4),d0

		add.l	d0,d0
		lea	cb_jumptab(pc),a0
		move.w	(a0,d0.w),d0
		ext.l	d0
		jmp	(a0,d0.l)

cb_jumptab:
		dc.w	cb_col-cb_jumptab,cb_bri-cb_jumptab,cb_cont-cb_jumptab
		dc.w	cb_red-cb_jumptab,cb_green-cb_jumptab,cb_blue-cb_jumptab
		dc.w	cb_use-cb_jumptab,cb_keep-cb_jumptab,cb_ende-cb_jumptab
		dc.w	cb_colornull-cb_jumptab,cb_brightnull-cb_jumptab
		dc.w	cb_contrastnull-cb_jumptab,cb_rednull-cb_jumptab
		dc.w	cb_greennull-cb_jumptab,cb_bluenull-cb_jumptab
		dc.w	cb_zeroall-cb_jumptab,cb_gamma-cb_jumptab
		dc.w	cb_gammanull-cb_jumptab
		
cb_tast:
		move.l	biaswinWnd(a5),aktwin(a5)
		lea	biaswinGadgets,a0
		move.l	d5,d3
		cmp.w	#'u',d3
		bne.b	.nouse
		lea	cb_use(pc),a3
		move.l	#GD_use,d0
		jmp	setandjump
.nouse:		cmp.w	#'k',d3
		bne.b	.nokeep
		lea	cb_keep(pc),a3
		move.l	#GD_keep,d0
		jmp	setandjump
.nokeep:	cmp.w	#'c',d3
		bne.b	.nocancel
		lea	cb_ende(pc),a3
		move.l	#GD_cancel,d0
		jmp	setandjump
.nocancel:
		cmp.w	#'z',d3
		bne.w	cb_wait	
		lea	cb_zeroall(pc),a3
		move.l	#GD_zeroall,d0
		jmp	setandjump


cb_use:
		move.l	#'CUSE',d7
		bra.w	cb_ende

cb_keep:
.go:
		lea	colorpuffer2,a0
		lea	colorpuffer1,a1
		move.l	#256-1,d7
.nc:		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		dbra	d7,.nc		

cb_zero
		moveq	#0,d0
		move.l	#GD_color,d1
		bsr.w	cb_setlevel
		moveq	#0,d0
		move.l	#GD_bright,d1
		bsr.w	cb_setlevel
		moveq	#0,d0
		move.l	#GD_contrast,d1
		bsr.w	cb_setlevel
		moveq	#0,d0
		move.l	#GD_red,d1
		bsr.w	cb_setlevel
		moveq	#0,d0
		move.l	#GD_green,d1
		bsr.w	cb_setlevel
		moveq	#0,d0
		move.l	#GD_blue,d1
		bsr.w	cb_setlevel
		moveq	#0,d0
		move.l	#GD_gamma,d1
		bsr.w	cb_setlevel

		lea	colorlevel(a5),a0
		moveq	#7-1,d7
.cl:		clr.l	(a0)+
		dbra	d7,.cl

;		tst.b	cbhammerk(a5)
;		bne.b	.w
		bsr.w	cb_setcolor
		bsr.w	cb_makecolortab

		move.l	viewWnd(a5),a0
		bsr.w	aktiwin
		bra.w	cb_wait


cb_zeroall:
		st	noslider(a5)
		bra.b	cb_zero		

cb_gammanull:
		move.l	#GD_gamma,d1
		clr.l	gammalevel(a5)
		bra.b	cb_set

cb_colornull:
		move.l	#GD_color,d1
		clr.l	colorlevel(a5)
		bra.b	cb_set
cb_brightnull:
		move.l	#GD_bright,d1
		clr.l	brightlevel(a5)
		bra.b	cb_set
cb_contrastnull:
		move.l	#GD_contrast,d1
		clr.l	contrastlevel(a5)
		bra.b	cb_set
cb_rednull:
		move.l	#GD_red,d1
		clr.l	redlevel(a5)
		bra.b	cb_set
cb_greennull:
		move.l	#GD_green,d1
		clr.l	greenlevel(a5)
		bra.b	cb_set
cb_bluenull:
		move.l	#GD_blue,d1
		clr.l	bluelevel(a5)


cb_set:
		moveq	#0,d0
		bsr.b	cb_setlevel
;		tst.b	cbhammerk(a5)
;		bne.w	cb_wait
		bsr.w	cb_setcolor
		bsr.w	cb_makecolortab

		move.l	viewWnd(a5),a0
		bsr.w	aktiwin

		bra.w	cb_wait

cb_setlevel:		
		lea	cb_farbwert(pc),a4
		move.l	d0,(a4)
		lsl.l	#2,d1
		lea	biaswinGadgets,a0
		move.l	(a0,d1),a0
		move.l	biaswinWnd(a5),a1
		sub.l	a2,a2
		lea	cb_colortag(pc),a3
		move.l	gadbase(a5),a6
		jmp	_LVOGT_SetGadgetAttrsA(a6)

cb_colortag:
		dc.l	GTSL_Level
cb_farbwert:	dc.l	0
		dc.l	TAG_DONE

;---------------------------------------------------------------------
;render ein HAM-Pic wieder ordentlich hin
;
cb_bias24:
		bsr.l	openprocess

		lea	cb_initmsg(pc),a1
		moveq	#6,d0	
		move.l	#'STOP',d1	;stop gadget ghosten
		bsr.l	initprocess

;haben wir rgb's ?

		jsr	APR_DoProcess(a5)
		
		tst.l	rndr_rgb(a5)
		bne	.memok
		bsr	makergbdatas
		tst.l	d0
		beq	.memok

		lea	notmemmsg(pc),a4
		bsr.w	status
		move.l	#'CBEN',d7
		lea	4(a7),a7
		bra.w	cb_ende		
.memok
		jsr	APR_DoProcess(a5)

		move.l	#256*2*6,d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,free1(a5)
		add.l	#256*2,d0
		move.l	d0,free2(a5)
		add.l	#256*2,d0
		move.l	d0,free3(a5)
		add.l	#256*2,d0
		move.l	d0,free4(a5)
		add.l	#256*2,d0
		move.l	d0,free5(a5)
		add.l	#256*2,d0
		move.l	d0,free6(a5)

		jsr	APR_DoProcess(a5)
		
		bsr.w	cb_setcolorHAM24

		bsr.l	clearprocess

		st	depthchange(a5)

		cmp.b	#24,planes(a5)
		beq.b	.w
		move.w	#'M8',anzcolor(a5)
		tst.b	ham(a5)
		beq.b	.w
		move.w	#'M6',anzcolor(a5)
.w
		move.l	4.w,a6
		move.l	free1(a5),a1
		jsr	_LVOFreeVec(a6)
		
		rts

cb_initmsg:	dc.b	'Init bias ...',0
cb_biasmsg:	dc.b	'Perform bias on 24 Bit data ...',0
;---------------------------------------------------------------------
cb_setcolor:
;Y=0.299R+0.587G+0.114B
;U=0.493(B-Y)
;V=0.877(R-Y)
;R=Y+V/0.877
;G=(0.587Y-0.341V-0.2312U)/0.587
;B=Y+U/0.493

		sf	merk1(a5)
		cmp.l	#'ENDE',d7
		bne	.w
		st	merk1(a5)
		move.l	d0,APG_Free1(a5)	;anzahl farben
.w
		move.l	mathbase(a5),a6

		tst.b	merk1(a5)
		beq	.ne
		lea	colorpuffer1,a0
		lea	colorpuffer2,a1
		move.l	APG_Free1(a5),d7			
		subq.l	#1,d7
		bra	.w1
.ne:
		lea	colorpuffer1+4*2*3,a0
		lea	colorpuffer2+4*2*3,a1
		move.l	cb_maxcolor(a5),d7
		subq.w	#1+4,d7
.w1
		move.l	colorlevel(a5),d0
		jsr	_LVOspflt(a6)
		move.l	d0,d5
.nextcolor
		moveq	#0,d0
		movem.w	(a0)+,d2-d4
		movem.l	a0/a1,-(a7)
		move.l	d2,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d2		;R
		move.l	d3,d0
		jsr	_LVOSPFlt(a6)
		move.l	d0,d3		;G
		move.l	d4,d0
		jsr	_LVOSPFlt(a6)	;d0 = B
		move.l	d0,d4

		move.l	d2,d0
		move.l	#$9916873f,d1	;.299
		jsr	_LVOspmul(a6)
		move.l	d0,d6
		move.l	d3,d0
		move.l	#$9645a240,d1	;0.587
		jsr	_LVOspmul(a6)
		move.l	d6,d1
		jsr	_LVOspadd(a6)
		move.l	d0,d6
		move.l	d4,d0
		move.l	#$e978d53d,d1	;0.114
		jsr	_LVOspmul(a6)
		move.l	d6,d1
		jsr	_LVOspadd(a6)
		move.l	d0,a2		;=Y

		move.l	d0,d1
		move.l	d4,d0
		jsr	_LVOspsub(a6)
		move.l	#$fc6a7f3f,d1	;0.493
		jsr	_LVOspmul(a6)
		move.l	d0,a3		;=U

		move.l	a2,d1
		move.l	d2,d0
		jsr	_LVOspsub(a6)
		move.l	#$e0831240,d1	;0.877
		jsr	_LVOspmul(a6)
		move.l	d0,a4		;V
		
		move.l	d5,d0
		move.l	a3,d1
		jsr	_LVOspmul(a6)	;U*slider
		move.l	#$c8000047,d1
		jsr	_LVOspdiv(a6)	;U*slider/100
		move.l	a3,d1
		jsr	_LVOspadd(a6)
		move.l	d0,a3

		move.l	d5,d0
		move.l	a4,d1
		jsr	_LVOspmul(a6)	;V*slider
		move.l	#$c8000047,d1
		jsr	_LVOspdiv(a6)	;V*slider/100
		move.l	a4,d1
		jsr	_LVOspadd(a6)
		move.l	d0,a4
				
		move.l	#$e0831240,d1	;0.877
		jsr	_LVOspdiv(a6)
		move.l	a2,d1
		jsr	_LVOspadd(a6)
		move.l	d0,d2		;R

		move.l	a2,d0
		move.l	#$9645a240,d1	;0.587
		jsr	_LVOspmul(a6)
		move.l	d0,d3
		move.l	a4,d0
		move.l	#$ae978d3f,d1	;0.341
		jsr	_LVOspmul(a6)
		move.l	d0,d1
		move.l	d3,d0
		jsr	_LVOspsub(a6)
		move.l	d0,d3
		move.l	a3,d0
		move.l	#$ec8b443e,d1	;0.231
		jsr	_LVOspmul(a6)
		move.l	d0,d1
		move.l	d3,d0
		jsr	_LVOspsub(a6)
		move.l	#$9645a240,d1	;0.587
		jsr	_LVOspdiv(a6)
		move.l	d0,d3		;G

;B=Y+U/0.493
		move.l	a3,d0
		move.l	#$fc6a7f3f,d1	;0.493
		jsr	_LVOspdiv(a6)
		move.l	a2,d1
		jsr	_LVOspadd(a6)
		move.l	d0,d4		;B

		move.l	d2,d0
		jsr	_LVOspfix(a6)
		move.l	d0,d2
		tst.l	d2
		bpl.b	.rpo
		moveq	#0,d2
		bra.b	.rok
.rpo		cmp.l	#255,d2
		bls.b	.rok
		move.w	#255,d2
.rok:		move.l	d3,d0
		jsr	_LVOspfix(a6)
		move.l	d0,d3
		tst.l	d3
		bpl.b	.gpo
		moveq	#0,d3
		bra.b	.gok
.gpo		cmp.l	#255,d3
		bls.b	.gok
		move.w	#255,d3
.gok:		move.l	d4,d0
		jsr	_LVOspfix(a6)
		move.l	d0,d4
		tst.l	d4
		bpl.b	.bpo
		moveq	#0,d4
		bra.b	.bok
.bpo		cmp.l	#255,d4
		bls.b	.bok
		move.w	#255,d4
.bok:		movem.l	(a7)+,a0/a1
		
		move.w	d2,(a1)+
		move.w	d3,(a1)+
		move.w	d4,(a1)+
		
		dbra	d7,.nextcolor		

cb_setgamma:

		tst.b	merk1(a5)
		beq	.ne
		lea	colorpuffer2,a4
		move.l	APG_Free1(a5),d7
		bra	.w
.ne		lea	colorpuffer2+4*2*3,a4
		move.l	cb_maxcolor(a5),d7
		subq.w	#4,d7
.w
		mulu	#3,d7
		subq.w	#1,d7

		move.l	gammalevel(a5),d5
		beq	cb_setbright
.nc:		moveq	#0,d0
		move.w	(a4),d0
		move.l	mathbase(a5),a6
		jsr	_LVOSPFlt(a6)
		move.l	#$ff000048,d1
		jsr	_LVOSPDiv(a6)
		move.l	d5,d1
		move.l	mathtransbase(a5),a6
		jsr	_LVOSPPow(a6)	;x^y
		move.l	#$ff000048,d1
		move.l	mathbase(a5),a6
		jsr	_LVOSPMul(a6)
		jsr	_LVOSPFix(a6)
		move.w	d0,(a4)+
		dbra	d7,.nc


cb_setbright:
		tst.b	merk1(a5)
		beq	.ne
		lea	colorpuffer2,a0
		move.l	APG_Free1(a5),d7
		bra	.w
.ne
		lea	colorpuffer2+4*2*3,a0
		move.l	cb_maxcolor(a5),d7
		subq.w	#4,d7
.w
		mulu	#3,d7
		subq.w	#1,d7
		move.l	brightlevel(a5),d5
		beq	cb_setcontrast
.nc:		moveq	#0,d0
		move.w	(a0),d0
		bsr.w	cb_makewert
		move.w	d0,(a0)+
		dbra	d7,.nc
			
cb_setcontrast:
		tst.b	merk1(a5)
		beq	.ne
		lea	colorpuffer2,a0
		move.l	APG_Free1(a5),d7
		bra	.w
.ne
		lea	colorpuffer2+4*2*3,a0
		move.l	cb_maxcolor(a5),d7
		subq.w	#4,d7
.w
		mulu	#3,d7
		subq.w	#1,d7
		move.l	contrastlevel(a5),d5
		beq	cb_setred
.nc:		moveq	#0,d0
		move.w	(a0),d0
		move.l	d0,d1
		sub.l	#128,d1
		bsr.w	cb_makewert1
		move.w	d0,(a0)+
		dbra	d7,.nc

cb_setred:
		tst.b	merk1(a5)
		beq	.ne
		lea	colorpuffer2,a0
		move.l	APG_Free1(a5),d7
		subq.l	#1,d7
		bra	.w
.ne
		lea	colorpuffer2+4*2*3,a0
		move.l	cb_maxcolor(a5),d7
		subq.w	#1+4,d7
.w
		move.l	redlevel(a5),d5
		beq	cb_setgreen
.nc:		move.w	(a0),d0
		bsr.w	cb_makewert
		move.w	d0,(a0)
		addq.l	#6,a0
		dbra	d7,.nc

cb_setgreen:
		tst.b	merk1(a5)
		beq	.ne
		lea	colorpuffer2,a0
		move.l	APG_Free1(a5),d7
		subq.l	#1,d7
		bra	.w
.ne
		lea	colorpuffer2+4*2*3,a0
		move.l	cb_maxcolor(a5),d7
		subq.w	#1+4,d7
.w
		move.l	greenlevel(a5),d5
		beq	cb_setblue
.nc:		move.w	2(a0),d0
		bsr.w	cb_makewert
		move.w	d0,2(a0)
		addq.l	#6,a0
		dbra	d7,.nc
cb_setblue:
		tst.b	merk1(a5)
		beq	.ne
		lea	colorpuffer2,a0
		move.l	APG_Free1(a5),d7
		subq.l	#1,d7
		bra	.w
.ne
		lea	colorpuffer2+4*2*3,a0
		move.l	cb_maxcolor(a5),d7
		subq.w	#1+4,d7
.w
		move.l	bluelevel(a5),d5
		beq	cb_wech
.nc:		move.w	4(a0),d0
		bsr.w	cb_makewert
		move.w	d0,4(a0)
		addq.l	#6,a0
		dbra	d7,.nc
		
cb_wech
		rts
;
;--- Berechne SetColor für HAM ----------------------------------------------
;
;	rsreset
cb_left		rs.l	1
cb_right	rs.l	1
cb_key		rs.l	1
cb_color	rs.l	1

cb_setcolorham24:

		move.l	colorlevel(a5),d0
		swap	D0			;*65536
		divu.l	#100,d0
		addq.l	#1,d0
		move.l	d0,colorlevelproz(a5)

;berechne lockup tabellen

;für gamma
		move.l	gammalevel(a5),d5
		beq	cb_prebright
		move.l	free1(a5),a3
		moveq	#0,d2
		move.w	#256-1,d7		
.ng
		move.l	d2,d0
		move.l	mathbase(a5),a6
		jsr	_LVOSPFlt(a6)
		move.l	#$ff000048,d1
		jsr	_LVOSPDiv(a6)
		move.l	d5,d1
		move.l	mathtransbase(a5),a6
		jsr	_LVOSPPow(a6)	;x^y
		move.l	#$ff000048,d1
		move.l	mathbase(a5),a6
		jsr	_LVOSPMul(a6)
		jsr	_LVOSPFix(a6)
		move.w	d0,(a3)+
		addq.w	#1,d2
		dbra	d7,.ng

cb_prebright:
		jsr	APR_DoProcess(a5)

		move.l	brightlevel(a5),d5
		beq.b	cb_precont
		move.l	free2(a5),a3
		moveq	#0,d2
		move.w	#256-1,d7		
.nb:		move.l	d2,d0
		bsr.w	cb_makewert
		move.w	d0,(a3)+
		addq.w	#1,d2
		dbra	d7,.nb
cb_precont:
		jsr	APR_DoProcess(a5)

		move.l	contrastlevel(a5),d5
		beq.b	cb_prered
		move.l	free3(a5),a3
		moveq	#0,d2
		move.w	#256-1,d7		
.nc:		move.l	d2,d0
		move.l	d0,d1
		sub.l	#128,d1
		bsr.w	cb_makewert1
		move.w	d0,(a3)+
		addq.w	#1,d2
		dbra	d7,.nc

cb_prered:
		jsr	APR_DoProcess(a5)

		lea	cb_biasmsg(pc),a1
		moveq	#0,d0	
		move.w	hoehe(a5),d0
		move.l	#'STOP',d1	;stop gadget ghosten
		bsr.l	initprocess

		move.l	rndr_rgb(a5),a0
		move.l	bytebreite(a5),d7
		lsl.l	#3,d7
		move.l	d7,APG_Free11(a5)
		move.w	hoehe(a5),d1
		mulu	d1,d7
		subq.l	#1,d7

		move.l	APG_Free11(a5),APG_Free12(a5)
cb_nextcolor24
		subq.l	#1,APG_Free12(a5)
		bne.b	.nixprocess

		bsr.w	doprocess
		move.l	APG_Free11(a5),APG_Free12(a5)

.nixprocess:

		move.l	(a0),d6

		move.l	d6,d2
		and.l	#$00ff0000,d2
		swap	d2
		move.l	d6,d3
		lsr.l	#8,d3
		and.l	#$000000ff,d3
		move.l	d6,d4
		and.l	#$000000ff,d4

		movem.l	d5/a0/a3/a4,-(a7)

		tst.l	colorlevel(a5)
		beq.w	cb_nocolor24

;Y=0.299R+0.587G+0.114B
;U=0.493(B-Y)
;V=0.877(R-Y)
;R=Y+V/0.877
;G=(0.587Y-0.341V-0.2312U)/0.587
;B=Y+U/0.493

		move.l	d2,d0
		mulu.l	#$4c8b,d0	;.299
		move.l	d0,d6
		move.l	d3,d0
		mulu.l	#$9645,d0	;0.587
		add.l	d0,d6
		move.l	d4,d0
		mulu.l	#$1d2f,d0
		add.l	d0,d6
		swap	d6
		ext.l	d6
		move.l	d6,a2		;=Y

		move.l	d4,d0
		sub.l	a2,d0		;B-Y
		muls.l	#$7e35,d0	;0.493
	divs.l	#65536,d0
		ext.l	d0
		move.l	d0,a3		;=U

		move.l	d2,d0
		sub.l	a2,d0
		muls.l	#$e083,d0	;0.877

	divs.l	#65536,d0

		ext.l	d0
		move.l	d0,a4		;V
		
		move.l	colorlevel(a5),d5
		move.l	a3,d0
		muls.l	d5,d0
		divs.l	#100,d0
		add.l	d0,a3

		move.l	a4,d0
		muls.l	d5,d0
		divs.l	#100,d0
		add.l	d0,a4		;V

		move.l	a4,d1		
		muls.l	#65536,d1
		divs.l	#$e083,d1	;0.877
		ext.l	d1
		add.l	a2,d1
		move.l	d1,d2		;R

		tst.l	d2
		bpl	.wr
		moveq	#0,d2
.wr
		cmp.l	#255,d2
		bls	.rok
		move.w	#255,d2
.rok:

;G=(0.587Y-0.341V-0.2312U)/0.587

		move.l	a2,d0
		muls.l	#$9645,d0	;0.587
		move.l	d0,d3
		move.l	a4,d0
		muls.l	#$574b,d0
		sub.l	d0,d3
		move.l	a3,d0
		muls.l	#$3b22,d0	;0.231
		sub.l	d0,d3
		divs.l	#$9645,d3	;G	;0.587

		tst.l	d3
		bpl	.w
		moveq	#0,d3
.w
		cmp.l	#255,d3
		bls	.gok
		move.w	#255,d3
.gok:
		
;B=Y+U/0.493
		move.l	a3,d4
		muls.l	#65536,d4
		divs.l	#$7e35,d4	;0.493
		add.l	a2,d4		;B

		tst.l	d4
		bpl	.w1
		moveq	#0,d4
.w1
		cmp.l	#255,d4
		bls	.bok
		move.w	#255,d4
.bok:

cb_nocolor24:
		move.l	gammalevel(a5),d5
		beq	cb_setbright24
		move.l	free1(a5),a0
		move.w	(a0,d2*2),d2
		move.w	(a0,d3*2),d3
		move.w	(a0,d4*2),d4

cb_setbright24:

		move.l	brightlevel(a5),d5
		beq.b	cb_nobright24
		move.l	free2(a5),a0
		move.w	(a0,d2*2),d2
		move.w	(a0,d3*2),d3
		move.w	(a0,d4*2),d4

;cb_setcontrast:
cb_nobright24:
		move.l	contrastlevel(a5),d5
		beq.b	cb_nocontrast24
		move.l	free3(a5),a0
		move.w	(a0,d2*2),d2
		move.w	(a0,d3*2),d3
		move.w	(a0,d4*2),d4
;red
cb_nocontrast24:
		moveq	#0,d6
		move.l	d2,d0
		move.l	redlevel(a5),d5
		beq.b	cb_nored24
		bsr.b	cb_makewert
cb_nored24:	move.l	d0,d6
		swap	d6
		move.l	d3,d0
		move.l	greenlevel(a5),d5
		beq.b	cb_nogreen24
		bsr.b	cb_makewert
cb_nogreen24:	lsl.l	#8,d0
		move.w	d0,d6
		move.l	d4,d0
		move.l	bluelevel(a5),d5
		beq.b	cb_noblue24
		bsr.b	cb_makewert
cb_noblue24:	move.b	d0,d6

;--- errechnete Farbe versuchen in Baum einzutragen ----

		movem.l	(a7)+,d5/a0/a3/a4

cb_savecolor24:	move.l	d6,(a0)+
		subq.l	#1,d7
		bne.w	cb_nextcolor24
		rts

;----------------------------------------------------------------------

cb_makewert:			;berechnet prozentualen Wert
		move.l	d0,d1
cb_makewert1:	muls	d5,d1
		divs	#100,d1
		ext.l	d1
		add.l	d1,d0
	;	tst.l	d0
		bpl.b	.bpo
		moveq	#0,d0
		bra.b	.bok
.bpo		cmp.l	#255,d0
		bls.b	.bok
		move.w	#255,d0
.bok:		rts

cb_ende:
		move.l	vi_screen(a5),a0
		move.l	intbase(a5),a6
		jsr	_LVOScreentoBack(a6)

		lea	biaswinWnd(a5),a0
		move.l	a0,window(a5)
		lea	biaswinGlist(a5),a0
		move.l	a0,Glist(a5)

		jsr	gt_CloseWindow

		jsr	APR_CloseVisualScreen(a5)		

		bsr.w	memcheck
		
		cmp.l	#'CBEN',d7
		bne.b	.w
		moveq	#-1,d3
		jmp	waitaction
.w
		cmp.l	#'CUSE',d7
		bne.w	.nh		;Cancel wurde angeklickt

;-----------------------------------------------------------------------------
		move.b	ham(a5),cbhammerk(a5)
		move.b	ham8(a5),d0
		add.b	d0,cbhammerk(a5)
		tst.b	cbhammerk(a5)
		bne	.make24
		cmp.b	#24,planes(a5)
		bne	.no24
.make24:	bsr	cb_bias24
		tst.b	cbhammerk(a5)
		beq	.end
		bsr.l	render
		bra.w	.end

;ein normales pic
.no24:
		lea	colorpuffer1,a0
		lea	colorpuffer2,a1
		lea	farbtab8(a5),a2
		move.l	(a2)+,d7
		swap	d7
		move.l	d7,d6
		subq.w	#1,d7
.n:		move.l	(a2)+,d0
		rol.l	#8,d0
		move.w	d0,(a0)+
		move.w	d0,(a1)+
		move.l	(a2)+,d0
		rol.l	#8,d0
		move.w	d0,(a0)+
		move.w	d0,(a1)+
		move.l	(a2)+,d0
		rol.l	#8,d0
		move.w	d0,(a0)+
		move.w	d0,(a1)+
		dbra	d7,.n

		move.l	#'ENDE',d7
		move.l	d6,d0		;anzahl farben
		bsr	cb_setcolor

		lea	colorpuffer2,a0
		lea	farbtab8(a5),a1
		move.l	(a1)+,d7
		swap	d7
		subq.w	#1,d7
;		move.l	cb_maxcolor(a5),d7
;		move.l	d7,d6
;		swap	d6
;		move.l	d6,(a1)+
;		subq.w	#1,d7
.nc:
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		movem.w	(a0)+,d0-d2
		lsl.l	#8,d0
		swap	d0
		move.l	d0,(a1)+
		lsl.l	#8,d1
		swap	d1
		move.l	d1,(a1)+
		lsl.l	#8,d2
		swap	d2
		move.l	d2,(a1)+
		dbra	d7,.nc
		clr.l	(a1)

;-------------------------------------------------------------------
.end
		lea	readymsg(pc),a4
		bsr.w	status
		
		tst.b	cbhammerk(a5)
		bne	.nh

		bsr.l	makepreview
.nh
		jsr	APR_Save2Tmp(a5)
		jmp	waitaction

cb_makecolor:
		move.l	gfxbase(a5),a6
		lea	cb_farbtab8,a1
		move.l	biasviewport(a5),a0
		jmp	_LVOLoadRGB32(a6)

cb_makecolortab:
		lea	colorpuffer2,a0
		lea	cb_farbtab8,a1
		move.l	cb_maxcolor(a5),d7
		move.l	d7,d6
		swap	d6
		move.l	d6,(a1)+
		subq.w	#1,d7
.nc:
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		movem.w	(a0)+,d0-d2
		lsl.l	#8,d0
		swap	d0
		move.l	d0,(a1)+
		lsl.l	#8,d1
		swap	d1
		move.l	d1,(a1)+
		lsl.l	#8,d2
		swap	d2
		move.l	d2,(a1)+
		dbra	d7,.nc
		clr.l	(a1)
		jmp	cb_makecolor
				

;---- Setzte MainScreenColors wenn wir einen CustomScreen haben ----
makescreencolors:
		tst.b	custfail(a5)
		bne.w	.wech1

		movem.l	d0-a6,-(a7)
		move.l 	mainwinWnd(a5),a0
		move.l  IntBase(a5),a6
		jsr     _LVOViewPortAddress(a6)
		move.l	d0,a0
		move.l	gfxbase(a5),a6
		
		lea	prefsfarbtab8(a5),a1
		lea	prefspurefarbtab(a5),a2
		move.w	prefsDisplayDepth(a5),d0
		cmp.w	#8,d0
		bls	.cok
		move.l	#256,d7
		bra	.w
.cok:
		move.w	anzmaincolors(a5),d7
.w		move.w	d7,(a1)+
		clr.w	(a1)+
		subq.l	#1,d7
		moveq	#0,d0
.nc:		move.b	(a2)+,d0
		lsl.l	#8,d0
		swap	d0
		move.l	d0,(a1)+
		move.b	(a2)+,d0
		lsl.l	#8,d0
		swap	d0
		move.l	d0,(a1)+
		move.b	(a2)+,d0
		lsl.l	#8,d0
		swap	d0
		move.l	d0,(a1)+
		dbra	d7,.nc
		clr.l	(a1)+
		lea	prefsfarbtab8(a5),a1
		jsr	_LVOLoadRGB32(a6)

.wech:		movem.l	(a7)+,d0-a6
.wech1:
		rts


;***************************************************************************
;*-------------------- Routinen von GadtoolsBox ---------------------------*
;***************************************************************************
SetupScreen:
		movem.l d1-d3/a0-a2/a6,-(sp)
		lea	decodier1+346,a1
		move.l	a1,decodier1rout(a5)
		lea	decodier2+420,a1
		move.l	a1,decodier2rout(a5)
		lea	endprog,a0
		move.l	a0,endbase(a5)

		move.l  intbase(a5),a6
		suba.l  a0,a0
		tst.b	customscr(a5)
		beq.b	.ncust

		moveq	#0,d7
.nextry:	lea.l   ScreenTags(pc),a1
		sub.l	a0,a0
		jsr	_LVOOpenScreenTagList(a6)
		tst.l	d0
		bne.b	.pok
		lea	pubnummer(pc),a0
		add.b	#1,(a0)
		add.b	#1,d7
		cmp.b	#9,d7
		beq.b	.ScError
		bra.b	.nextry
.ScError:
		st	custfail(a5)
		bra.b	_back
.pok:		st	custmerk(a5)
		sf	custfail(a5)
		bra.b	_w
.ncust:
		tst.b	publicscr(a5)
		beq.b	_nopub
		lea	aktpubscreen(a5),a0
		cmp.b	#0,(a0)
		bne.b	_nopub
_back:		sub.l	a0,a0
_nopub:
		jsr	_LVOLockPubScreen(a6)
_w
		move.l  d0,Scr(a5)
		tst.l   d0
		beq.b   SError
		move.l  Scr(a5),a0
		move.l  gadbase(a5),a6
		sub.l	a1,a1		;lea.l   TD,a1
		jsr	_LVOGetVisualInfoA(a6)
		move.l  d0,VisualInfo(a5)
		tst.l   d0
		beq.b	VError

		tst.b	custfail(a5)
		bne.b	.ok
		tst.b	custmerk(a5)
		beq.b	.ok
		move.l	scr(a5),a0
		moveq	#0,d0
		move.l	intbase(a5),a6
		jsr	_LVOPubScreenStatus(a6)

.ok
		moveq   #0,d0
SDone:
		movem.l (sp)+,d1-d3/a0-a2/a6
		rts
SError:
		cmp.l	#'PECH',d7
		beq.b	.nopub
		tst.b	publicscr(a5)
		beq.b	.nopub
		move.l	#'PECH',d7
		bra.b	_back
.nopub:
		moveq   #1,d0
		bra.s   SDone
VError:
		moveq   #2,d0
		bra.s   SDone
OError:
		moveq	#3,d0
		bsr.b	SDone

CloseDownScreen:
		movem.l d0-d1/a0-a1/a6,-(sp)

		move.l	guigfxbase(a5),a6
		move.l	dp_drawhandle(a5),d0
		beq	.nf
		move.l	d0,a0
		jsr	_LVOReleaseDrawHandle(a6)
		clr.l	dp_drawhandle(a5)
.nf
		move.l	dp_picture(a5),d0
		beq	.np
		move.l	d0,a0
		jsr	_LVODeletePicture(a6)
		clr.l	dp_picture(a5)
.np:
		move.l	dp_psm(a5),d0
		beq	.npsm
		move.l	d0,a0
		jsr	_LVODeletePenShareMap(a6)
		clr.l	dp_psm(a5)
.npsm


		move.l  gadbase(a5),a6
		move.l  VisualInfo(a5),a0
		cmpa.l  #0,a0
		beq.s   NoVis
		jsr	_LVOFreeVisualInfo(a6)
		move.l  #0,VisualInfo(a5)
NoVis:
		move.l  intbase(a5),a6
		sub.l	a0,a0
		move.l  Scr(a5),d0
		beq.s   NoScr

		move.l	d0,rt_pubscreen
		
		tst.b	custmerk(a5)
		beq.b	.nocust
		move.l	d0,a0
		jsr	_LVOCloseScreen(a6)
		tst.l	d0
		bne.b	.closeok

		lea	pubmsg(pc),a1
		lea	pubmsg1(pc),a2
		sub.l	a3,a3
		sub.l	a4,a4
		lea	pubListe(pc),a0
		move.l	reqtbase(a5),a6
		jsr	_LVOrtEZRequestA(a6)
		bra.b	NoVis
.closeok:
		sf	custmerk(a5)
		bra.b	.we
.nocust:
		move.l	d0,a1
		jsr	_LVOUnlockPubScreen(a6)
.we		move.l  #0,Scr(a5)
NoScr:
		movem.l (sp)+,d0-d1/a0-a1/a6
		rts

ScreenTags:
		dc.l	SA_Left,0
		dc.l	SA_Top,0
		dc.l	SA_Width
mainwidth:	dc.l	640
		dc.l	SA_Height
mainheight:	dc.l	256
		dc.l	SA_Depth
maindepth:	dc.l	2
		dc.l	SA_SysFont
mainfont:	dc.l	1
		dc.l	SA_Type,PUBLICSCREEN	;CUSTOMSCREEN
		dc.l	SA_PubName,myname
		dc.l	SA_DisplayID
mainID:		dc.l	HIRES_KEY  ;PAL_MONITOR_ID!
		dc.l	SA_Pens,DriPen
		dc.l    SA_AutoScroll
mainscroll:	dc.l	1
		dc.l    SA_Overscan
mainoscan:	dc.l	OSCAN_STANDARD
		dc.l	SA_Title,SCT
		dc.l	SA_PubSig,$55	;zeichen für letztes window
lasttag:	dc.l	SA_SharePens,1
		dc.l	SA_LikeWorkbench,1
		dc.l	TAG_DONE

myname:		dc.b	'ArtPRO.'
pubnummer:	dc.b	'1',0
	even

pubmsg:		dc.b	'Please close all visitors!',0
	even
pubmsg1:	dc.b	'Ok',0
	even

pubListe:	
		dc.l	_rt_screen
rt_pubscreen:	dc.l	0			;Pointer ????
		dc.l	RT_REQPOS
		dc.l	REQPOS_POINTER
		dc.l	RTEZ_ReqTitle
		dc.l	reqtitle
		dc.l	0

;-----------------------------------------------------------------------------
;>d0	x
; d1	y
; d2	xsize
; d3	ysize
CalcNewKoor:
		jsr	ComputeX
		add.w	OffX(a5),d0
		move.l	d0,d4
		move.l	d1,d0
		jsr	ComputeY
		add.w	OffY(a5),d0
		move.l	d0,d1
		move.l	d2,d0
		jsr	ComputeX
		move.l	d0,d2
		move.l	d3,d0
		jsr	ComputeY
		move.l	d0,d3
		move.l	d4,d0
		rts	

;---- Fontroutinen von Gadtools ----
ComputeX:
		move.l	d1,-(sp)
		move.w	FontX(a5),d1
		bra.s	ComputeItX
ComputeY:
		move.l	d1,-(sp)
		move.w	FontY(A5),d1
		mulu	d1,d0
		addq.w	#4,d0
		lsr.w	#3,d0
		move.l	(sp)+,d1
		rts
ComputeItX:
		mulu	d1,d0
		addq.w	#4,d0
		lsr.w	#3,d0
		move.l	(sp)+,d1
		rts
ComputeFont:
		lea.l	Attr(a5),a0
		move.l	a0,Font(A5)

		move.l	userfont(a5),a1

		tst.b	nofont(a5)
		beq.b	fontok

		move.l	scr(A5),a1
		lea.l	sc_RastPort(a1),a1
		move.l	rp_Font(a1),a1
fontok:
		move.l	LN_NAME(a1),ta_Name(a0)
		move.w	tf_YSize(a1),ta_YSize(a0)
		move.w	tf_XSize(a1),FontX(A5)
		move.w	tf_YSize(a1),FontY(A5)
		move.l	scr(A5),a0
		move.b	sc_WBorLeft(a0),d0
		ext.w	 d0
		move.w	d0,OffX(A5)
		move.l	sc_Font(a0),a1
		move.w	ta_YSize(a1),d0
		addq.w	#1,d0
		move.b	sc_WBorTop(a0),d1
		ext.w	d1
		add.w	d1,d0
		move.w	d0,OffY(A5)
		tst.w	d2
		beq.s	.CompDone
		tst.w	d3
		beq.s	.CompDone
		move.w	d2,d0
		bsr.w	ComputeX
		add.w	OffX(A5),d0
		move.b	sc_WBorRight(a0),d1
		ext.w	d1
		add.w	d1,d0
		cmp.w	sc_Width(a0),d0
		bhi.s	.UseTopaz
		move.w	d3,d0
		bsr.w	ComputeY
		add.w	OffY(A5),d0
		move.b	sc_WBorBottom(a0),d1
		ext.w	d1
		add.w	d1,d0
		cmp.w	sc_Height(a0),d0
		bhi.s	.UseTopaz
.CompDone:
		rts
.UseTopaz:
		move.l	Font(A5),a0
		move.l	#TopazName,ta_Name(a0)
		move.w	#8,FontY(A5)
		move.w	#8,FontX(a5)
		move.w	#8,ta_YSize(a0)
		rts

TopazName:
	DC.B	'topaz.font',0
	even

mainwinRender:
		movem.l d0-d5/a0-a2/a6,-(sp)
		move.l  mainwinWnd(a5),a0
		move.w	#mainwinWidth,d2
		move.l	#mainwinHeight,d3
	;	bsr.w	computeFont
		move.l  VisualInfo(a5),NR+4
		move.l  VisualInfo(a5),IR+4
		move.l  gadbase(a5),a6
		move.l  mainwinWnd(a5),a0
		move.l  wd_RPort(a0),a2
		move.l  a2,a0
		lea.l   IR,a1

		move.l  #175,d0
		bsr.w	ComputeY
		add.w   OffY(a5),d0
		move.l	d0,d1
		move.l  #293,d0
		bsr.w	ComputeX
		move.l	d0,d2
		move.l  #65,d0
		bsr.w	ComputeY
		move.l	d0,d3
		move.l  #324,d0
		bsr.w	ComputeX
		add.w	OffX(a5),d0
		jsr	_LVODrawBevelBoxA(a6)
		move.l  a2,a0
		lea	IR,a1
		move.l  #98,d0		;ImageControl
		bsr.w	ComputeY
		add.w	OffY(a5),d0
		move.l	d0,d1
		move.l  #293,d0
		bsr.w	ComputeX
		move.l	d0,d2
		move.l  #62,d0
		bsr.w	ComputeY
		move.l	d0,d3
		move.l  #324,d0
		bsr.w	ComputeX
		add.w	OffX(a5),d0
		jsr	_LVODrawBevelBoxA(a6)
		move.l  a2,a0
		lea	IR,a1
		move.l  #98,d0		;File Operationen
		bsr.w	ComputeY
		add.w	OffY(a5),d0
		move.l	d0,d1
		move.l  #311,d0
		bsr.w	ComputeX
		move.l	d0,d2
		move.l  #62,d0
		bsr.w	ComputeY
		move.l	d0,d3
		move.l  #5,d0
		bsr.w	ComputeX
		add.w	OffX(a5),d0
		jsr	_LVODrawBevelBoxA(a6)
		move.l  a2,a0
		lea.l   IR,a1
		move.l  #175,d0		;brush
		bsr.w	ComputeY
		add.w	OffY(a5),d0
		move.l	d0,d1
		move.l  #311,d0
		bsr.w	ComputeX
		move.l	d0,d2
		move.l  #65,d0
		bsr.w	ComputeY
		move.l	d0,d3
		move.l	#5,d0
		bsr.w	ComputeX
		add.w	OffX(a5),d0
		jsr	_LVODrawBevelBoxA(a6)
		move.l  a2,a0
		lea.l   IR,a1
		move.l  #18,d0		;Main 
		bsr.w	ComputeY
		add.w	OffY(a5),d0
		move.l	d0,d1
		move.l  #397,d0
		bsr.w	ComputeX
		move.l	d0,d2
		move.l  #63,d0
		bsr.w	ComputeY
		move.l	d0,d3
		move.l  #5,d0
		bsr.w	ComputeX
		add.w	OffX(a5),d0
		jsr	_LVODrawBevelBoxA(a6)
		moveq   #0,d3
		lea	mainwinText0,a2
Project0TLoop:
		move.l  4.w,a6
		lea	BufIText(a5),a1
		move.l  a2,a0
		move.l  d3,d0
		mulu    #it_SIZEOF,d0
		add.l   d0,a0
		moveq   #it_SIZEOF,d0
		jsr	_LVOCopyMem(a6)
		lea	BufIText(a5),a0
		move.l  IntBase(a5),a6
		move.l	Font(a5),it_ITextFont(a0)
		jsr	_LVOIntuiTextLength(a6)
		asr.l   #1,d0
		move.l  d0,-(sp)
		lea	BufIText(a5),a0
		move.w  it_LeftEdge(a0),d0
		bsr.w	ComputeX
		add.w   OffX(a5),d0
		ext.l   d0
		sub.l   (sp)+,d0
		move.w  d0,it_LeftEdge(a0)
		move.w  it_TopEdge(a0),d0

		bsr.w	ComputeY
		add.w   OffY(a5),d0
		move.l  Font(a5),a1
		move.w  ta_YSize(a1),d1
		asr.w   #1,d1
		sub.w   d1,d0
		move.w  d0,it_TopEdge(a0)
		move.l  a0,a1
		move.l  mainwinWnd(a5),a0
		move.l  wd_RPort(a0),a0
		moveq   #0,d0
		moveq   #0,d1
		jsr	_LVOPrintIText(a6)
		addq.l  #1,d3
		cmp.l   #Project0_TNUM,d3
		bmi.b	Project0TLoop
		movem.l (sp)+,d0-d5/a0-a2/a6

check:		tst.b	iconifyflag(a5)
		bne.b	.wech
		move.l	checkkey1rout(a5),a6
		move.l	#5,d0
		move.l	#$80001004,d2
		jsr	-312(a6)
		move.l	d0,dummymerk(a5)
		moveq	#0,d0
		move.b	check1(a5),d0
		add.w	d0,finalcheck(a5)
.wech		rts

openwindowF:
		movem.l d1-d4/a0-a4/a6,-(sp)
		move.l  Screenbase(a5),a0
		moveq   #0,d3
		moveq   #0,d2
		move.w	WinWidth(a5),d2
		move.w	WinHeight(a5),d3

		tst.b	fontallready(a5)
		bne.b	.nof
		bsr.w	ComputeFont
		st	fontallready(a5)
.nof:
		move.l	screenbase(A5),a0
		move.l	d2,d0
		bsr.w	ComputeX
		move.l	d0,d4
		move.w	WinLeft(a5),d2
		add.w	d2,d0
		add.w	OffX(a5),d0
		move.b	sc_WBorRight(a0),d1
		ext.w	d1
		add.w	d1,d0
		cmp.w	sc_Width(a0),d0
		bls.s	.Project0WOk
		move.w	sc_Width(a0),d0
		sub.w	d4,d0
		move.w	d0,d2
.Project0WOk:
		move.l	d3,d0
		bsr.w	ComputeY
		move.l	d0,d4
		move.w	WinTop(a5),d3
		add.w	d3,d0
		add.w	OffY(A5),d0
		move.b	sc_WBorBottom(a0),d1
		ext.w	d1
		add.w	d1,d0
		cmp.w	sc_Height(a0),d0
		bls.s	.Project0HOk
		move.w	sc_Height(a0),d0
		sub.w	d4,d0
		move.w	d0,d3
.Project0HOk:
		move.l  GadBase(a5),a6
		move.l	GList(a5),a0
		jsr	_LVOCreateContext(a6)
		move.l  d0,a3
		tst.l   d0
		beq.w	MainWinCError
		movem.w d2-d3,-(sp)
		moveq   #0,d3
		move.l	WindowTags(a5),a4
Project0GL:
		move.l	4.w,a6
		move.l	NGads(a5),a0
		move.l  d3,d0
		mulu    #gng_SIZEOF,d0
		add.l   d0,a0
		lea	BufNewGad,a1
		moveq   #gng_SIZEOF,d0
		jsr	_LVOCopyMem(a6)
		lea	BufNewGad,a0
		move.l  VisualInfo(a5),gng_VisualInfo(a0)
		move.l  Font(a5),gng_TextAttr(a0)
		move.w  gng_LeftEdge(a0),d0
		bsr.w	ComputeX
		add.w   OffX(a5),d0
		move.w  d0,gng_LeftEdge(a0)
		move.w  gng_TopEdge(a0),d0
		bsr.w	ComputeY
		add.w   OffY(a5),d0
		move.w  d0,gng_TopEdge(a0)
		move.w  gng_Width(a0),d0
		bsr.w	ComputeX
		move.w  d0,gng_Width(a0)
		move.w  gng_Height(a0),d0
		bsr.w	ComputeY
		move.w  d0,gng_Height(a0)
		move.l	GadBase(a5),a6
		move.l	GTypes(a5),a0
		moveq   #0,d0
		move.l  d3,d1
		asl.l	#1,d1
		add.l	d1,a0
		move.w	(a0),d0
		move.l	a3,a0
		lea	BufNewGad,a1
		move.l  a4,a2
		jsr	_LVOCreateGadgetA(a6)
		tst.l   d0
		bne.s	Project0COK
		movem.w (sp)+,d2-d3
		bra.w	MainWinGError
Project0COK:
		move.l  d0,a3
		move.l  d3,d0
		asl.l   #2,d0
		move.l	WinGadgets(a5),a0
		add.l   d0,a0
		move.l  a3,(a0)
Project0TL:
		tst.l   (a4)
		beq.s   Project0DN
		addq.w  #8,a4
		bra.s   Project0TL
Project0DN:
		addq.w  #4,a4
		addq.w  #1,d3
		cmp.w   Win_CNT(a5),d3
		bmi.w     Project0GL
		movem.w (sp)+,d2-d3
		move.l  GList(a5),a6
		move.l	Gadgets(a5),a1
		move.l	(a6),(a1)
		move.l	winscreen(a5),a1
		move.l  Screenbase(a5),(a1)
		move.l  intbase(a5),a6
		ext.l   d2
		ext.l   d3
		move.l	WinL(a5),a6
		move.l  d2,4(a6)		;MainWinL+4
		move.l	WinT(a5),a6
		move.l  d3,4(a6)		;MainWinT+4
		move.l  Scr(a5),a0
		move.w  WinWidth(a5),d0
		bsr.w	ComputeX
		add.w   OffX(a5),d0
		move.b  sc_WBorRight(a0),d1
		ext.w   d1
		add.w   d1,d0
		move.l	WinW(a5),a6
		move.l  d0,4(a6)		;MainWinW+4
		move.w  WinHeight(a5),d0
		bsr.w	ComputeY
		add.w   OffY(a5),d0
		move.b  sc_WBorBottom(a0),d1
		ext.w   d1
		add.w   d1,d0
		move.l	WinH(a5),a6
		move.l  d0,4(a6)		;MainWinH+4

;		tst.b	checkgetfile(a5)
;		bne	.nt
;		lea	gloadroutine,a0
;		move.w	4(a0),d0
;		bsr	ComputeX
;		add.w	OffX(a5),d0
;		move.w	d0,4(a0)
;		move.w	6(a0),d0
;		bsr	ComputeY
;		add.w	OffY(a5),d0
;		move.w	d0,6(a0)
;		
;		st	checkgetfile(a5)
;.nt:
		move.l  IntBase(a5),a6
		suba.l  a0,a0
		move.l	WindowTagList(a5),a1
		jsr	_LVOOpenWindowTagList(a6)
		move.l	window(a5),a1
		move.l  d0,(a1)
		tst.l   d0
		beq.b   mainwinWError
		move.l  gadbase(a5),a6
		move.l  Window(a5),a0
		move.l	(a0),a0
		suba.l  a1,a1
		jsr	_LVOGT_RefreshWindow(a6)
		moveq   #0,d0
mainwinDone:
		movem.l (sp)+,d1-d4/a0-a4/a6
		rts
mainwinCError:
		moveq   #1,d0
		bra.s   mainwinDone
mainwinGError:
		moveq   #2,d0
		bra.s   mainwinDone
mainwinWError:
		moveq   #4,d0
		bra.s   mainwinDone


;---------------------------------------------------------------------------
;----------- gebe Text aus 
;---------------------------------------------------------------------------

writetext:
		moveq   #0,d3
.Project0TLoop:
		move.l  4.w,a6
		lea	BufIText(a5),a1
		move.l  a2,a0
		move.l  d3,d0
		mulu    #it_SIZEOF,d0
		add.l   d0,a0
		moveq   #it_SIZEOF,d0
		jsr	_LVOCopyMem(a6)
		lea	BufIText(a5),a0
		move.l  IntBase(a5),a6
		move.l	Font(a5),it_ITextFont(a0)
		jsr	_LVOIntuiTextLength(a6)
		asr.l   #1,d0
		move.l  d0,-(sp)
		lea	BufIText(a5),a0
		move.w  it_LeftEdge(a0),d0
		bsr.w	ComputeX
		add.w   OffX(a5),d0
		ext.l   d0
		sub.l   (sp)+,d0
		move.w  d0,it_LeftEdge(a0)
		move.w  it_TopEdge(a0),d0

		bsr.w	ComputeY
		add.w   OffY(a5),d0
		move.l  Font(a5),a1
		move.w  ta_YSize(a1),d1
		asr.w   #1,d1
		sub.w   d1,d0
		move.w  d0,it_TopEdge(a0)
		move.l  a0,a1
		move.l  window(a5),a0
		move.l	(a0),a0
		move.l  wd_RPort(a0),a0
		moveq   #0,d0
		moveq   #0,d1
		jsr	_LVOPrintIText(a6)
		addq.l  #1,d3
		cmp.w   textnum(a5),d3
		bmi.b	.Project0TLoop
		rts


;**************************************
;*----- Routinen für ViewScreen ------*
;**************************************

SetupViewScreen:
		movem.l d1-d3/a0-a2/a6,-(sp)
		move.l  IntBase(a5),a6
		suba.l  a0,a0
		lea.l   ScreenTags1,a1
		jsr	_LVOOpenScreenTagList(a6)
		move.l  d0,Scr1(a5)
		tst.l   d0
		beq.b	SError1
		move.l  Scr1(a5),a0
		move.l  GadBase(a5),a6
		lea.l   TD1,a1
		jsr	_LVOGetVisualInfoA(a6)
		move.l  d0,VisualInfo1
		tst.l   d0
		beq.b	VError1
		moveq   #0,d0
SDone1:
		movem.l (sp)+,d1-d3/a0-a2/a6
		rts
SError1:
		moveq   #1,d0
		bra.s   SDone1
VError1:
		moveq   #2,d0
		bra.s   SDone1


OpenViewWindow:
		movem.l d1-d4/a0-a4/a6,-(sp)
		move.l  Scr1(a5),a0
		moveq   #0,d3
		moveq   #0,d2
		move.l  sc_Font(a0),a1
		move.w  ta_YSize(a1),d3
		addq.w  #1,d3
		add.b   sc_WBorTop(a0),d3
		move.l  Scr1(a5),ViewSC+4
		moveq   #0,d0
		move.w  ViewLeft,d0
		move.l  d0,ViewL+4
		move.w  ViewTop,d0
		move.l  d0,ViewT+4
		move.w  ViewWidth,d0
		move.l  d0,ViewW+4
		move.w  ViewHeight,d0
		add.w   d3,d0
		move.l  d0,ViewH+4
		move.l  IntBase(a5),a6
		suba.l  a0,a0
		lea.l   ViewWindowTags,a1
		jsr	_LVOOpenWindowTagList(a6)
		move.l  d0,ViewWnd(a5)
		tst.l   d0
		beq.b   ViewWError
		move.l  GadBase(a5),a6
		move.l  ViewWnd(a5),a0
		suba.l  a1,a1
		jsr	_LVOGT_RefreshWindow(a6)
		moveq   #0,d0
ViewDone:
		movem.l (sp)+,d1-d4/a0-a4/a6
		rts
ViewWError:
		moveq   #4,d0
		bra.s   ViewDone

;********************************************
;*----- Routinen für ColorBias Screen ------*
;********************************************

SetupBiasScreen:
		movem.l d1-d3/a0-a2/a6,-(sp)
		move.l  IntBase(a5),a6
		suba.l  a0,a0
		lea   	ScreenTags3,a1
		jsr	_LVOOpenScreenTagList(a6)
		move.l  d0,Scr3(a5)
		tst.l   d0
		beq.w   SError1
		move.l  d0,a0
		move.l  GadBase(a5),a6
		lea   	TD3,a1
		jsr	_LVOGetVisualInfoA(a6)
		move.l  d0,VisualInfo3
		tst.l   d0
		beq.w   VError1
		moveq   #0,d0
		movem.l (sp)+,d1-d3/a0-a2/a6
		rts

CloseDownBiasScreen:
		movem.l d0-d1/a0-a1/a6,-(sp)
		move.l  GadBase(a5),a6
		move.l  VisualInfo3,a0
		cmpa.l  #0,a0
		beq.b   NoVis3
		jsr	_LVOFreeVisualInfo(a6)
		move.l  #0,VisualInfo3
NoVis3:
		move.l  IntBase(a5),a6
		move.l  Scr3(a5),a0
		cmpa.l  #0,a0
		beq.s   NoScr3
		jsr	_LVOCloseScreen(a6)
		clr.l	Scr3(a5)
NoScr3:
		movem.l (sp)+,d0-d1/a0-a1/a6
		rts

;********************************************
;*----- Routinen für Palette Screen ------*
;********************************************
;d7 <>0 = zweiter Screen
SetuppalScreen:
		movem.l d1-d3/a0-a2/a6,-(sp)
		move.l  IntBase(a5),a6
		suba.l  a0,a0
		lea   	ScreenTags4,a1
		tst.l	d7		;<>0 = Scr5
		beq.b	.w
		lea   	ScreenTags5,a1
.w		jsr	_LVOOpenScreenTagList(a6)
		tst.l	d7
		beq.b	.w1
		move.l	d0,scr5(a5)
		bra.b	.w2
.w1		move.l  d0,Scr4(a5)
.w2		tst.l   d0
		beq.w   SError1
		move.l  d0,a0
		move.l  GadBase(a5),a6
		lea   	TD4,a1
		tst.l	d7
		beq.w	.w3
.w3		jsr	_LVOGetVisualInfoA(a6)
		tst.l	d7
		beq.b	.w4
		move.l	d0,VisualInfo5
		bra.b	.w5
.w4		move.l  d0,VisualInfo4
.w5		tst.l   d0
		beq.w   VError1
		moveq   #0,d0
		movem.l (sp)+,d1-d3/a0-a2/a6
		rts

CloseDownpalScreen:
		movem.l d0-d1/a0-a1/a6,-(sp)
		move.l  GadBase(a5),a6
		move.l  VisualInfo4,a0
		tst.l	d7
		beq.b	.w
		move.l  VisualInfo5,a0
.w		cmpa.l  #0,a0
		beq.b   NoVis4
		jsr	_LVOFreeVisualInfo(a6)
		tst.l	d7
		beq.b	.w1
		move.l  #0,VisualInfo5
		bra.b	NoVis4
.w1		move.l  #0,VisualInfo4
NoVis4:
		move.l  IntBase(a5),a6
		move.l  Scr4(a5),a0
		tst.l	d7
		beq.b	.w2
		move.l  Scr5(a5),a0
.w2		cmpa.l  #0,a0
		beq.s   NoScr4
		jsr	_LVOCloseScreen(a6)
		tst.l	d7
		beq.b	.w3
		clr.l	Scr5(a5)
		bra.b	NoScr4
.w3		clr.l	Scr4(a5)
NoScr4:
		movem.l (sp)+,d0-d1/a0-a1/a6
		rts

palwinRender:
		movem.l	d0-d5/a0-a2/a6,-(sp)
		move.l	PalwinWnd2(a5),a0
		move.b	wd_BorderLeft(a0),d4
		ext.w	d4
		move.b	wd_BorderTop(a0),d5
		ext.w	d5
		move.l  VisualInfo5,NR+4
		move.l	VisualInfo5,IR+4
		move.l	GadBase(a5),a6
		move.l	PalwinWnd2(a5),a0
		move.l	wd_RPort(a0),a2
		move.l	a2,a0
		lea	NR,a1
		move.w	#237,d0
		add.w	d4,d0
		move.w	#17,d1
		add.w	d5,d1
		move.w	#56,d2
		move.w	#24,d3
		jsr	_LVODrawBevelBoxA(a6)
		movem.l	(sp)+,d0-d5/a0-a2/a6
		rts

;-------------------------------------------------------------------------
;------------ Allgemeine Windowopenroutine -------------------------------
OpenWindow:
		movem.l d1-d4/a0-a4/a6,-(sp)
		move.l  gadbase(a5),a6
		cmp.l	#'NOGA',d7
		beq.w	openw
		move.l	GList(a5),a0
		jsr	_LVOCreateContext(a6)
		move.l  d0,a3
		tst.l   d0
		beq.w	openwinCError
		movem.w d2-d3,-(sp)
		moveq   #0,d3
		move.l  WindowTags(a5),a4
OpenwinGL:
		move.l  $4,a6
		move.l	NGads(a5),a0
		move.l  d3,d0
		mulu    #gng_SIZEOF,d0
		add.l   d0,a0
		lea.l   BufNewGad,a1
		moveq   #gng_SIZEOF,d0
		jsr	_LVOCopyMem(a6)
		lea.l   BufNewGad,a0
		move.l  VisualInfo(a5),gng_VisualInfo(a0)
		move.l  #topaz8,gng_TextAttr(a0)
		move.l  gadbase(a5),a6
		move.l	GTypes(a5),a0
		moveq   #0,d0
		move.l  d3,d1
		asl.l   #1,d1
		add.l   d1,a0
		move.w  (a0),d0
		move.l  a3,a0
		lea.l   BufNewGad,a1
		move.l  a4,a2
		jsr	_LVOCreateGadgetA(a6)
		tst.l   d0
		beq.b   OpenwinCError
		move.l  d0,a3
		move.l  d3,d0
		asl.l   #2,d0
		move.l	WinGadgets(a5),a0
		add.l   d0,a0
		move.l  a3,(a0)
OpenwinTL:
		tst.l   (a4)
		beq.s	OpenwinDN
		addq.w  #8,a4
		bra.s	OpenwinTL
OpenwinDN:
		addq.w  #4,a4
		addq.w  #1,d3
		cmp.w   win_CNT(a5),d3
		bmi.b	OpenwinGL
		movem.w (sp)+,d2-d3
		move.l  GList(a5),a6
		move.l	Gadgets(a5),a1
		move.l	(a6),(a1)
openw		move.l	winscreen(a5),a1
		move.l  Screenbase(a5),(a1)
		move.l  intbase(a5),a6
		suba.l  a0,a0
		move.l	WindowTaglist(a5),a1
		jsr	_LVOOpenWindowTagList(a6)
		move.l	window(a5),a1
		move.l  d0,(a1)
		tst.l   d0
		beq.b	OpenwinWError
		move.l  gadbase(a5),a6
		move.l  Window(a5),a0
		move.l	(a0),a0
		suba.l  a1,a1
		jsr	_LVOGT_RefreshWindow(a6)
		moveq   #0,d0
OpenwinDone:
		movem.l (sp)+,d1-d4/a0-a4/a6
		rts
OpenwinCError:
		moveq   #1,d0
		bra.s   OpenwinDone
OpenwinGError:
		moveq   #2,d0
		bra.s   OpenwinDone
OpenwinWError:
		moveq   #4,d0
		bra.s   OpenwinDone

gt_CloseWindow:
		movem.l d0-d1/a0-a2/a6,-(sp)
		move.l  intbase(a5),a6
		move.l  window(a5),a0
		move.l	(a0),a0
		cmpa.l  #0,a0
		beq.b	closewinNWnd
		jsr	_LVOCloseWindow(a6)
		move.l	window(a5),a0
		clr.l	(a0)
closewinNWnd:
		cmp.l	#'NOGA',d7
		beq.b	closewinNGad
		move.l  gadbase(a5),a6
		move.l  GList(a5),a0
		move.l	(a0),a0
		cmpa.l  #0,a0
		beq.b	closewinNGad
		jsr	_LVOFreeGadgets(a6)
		move.l	Glist(a5),a0
		clr.l	(a0)
closewinNGad:
		movem.l (sp)+,d0-d1/a0-a2/a6
		rts

	*-------- Erzeuge ein Arexxport --------*
makearexx:
		lea	arexxname(pc),a1
		move.l	4.w,a6
		jsr	_LVOFindPort(a6)
		tst.l	d0
		beq	.keinport
		lea	rx_num(pc),a0
		addq.b	#1,(a0)
		bra	makearexx

.keinport:
		jsr	_LVOCreateMsgPort(a6)
		tst.l	d0
		bne	.portok
		clr.l	rxPort(a5)	;kein arexxport
		bra	.check
		rts
.portok		
		move.l	d0,rxPort(a5)
		move.l	d0,a1
		lea	arexxname(pc),a0
		move.l	a0,LN_NAME(a1)
		jsr	_LVOAddPort(a6)

;teste falls Version nur mit key läuft	
.check
	ifne 	needkey

		moveq	#0,d0
		move.b	check2(a5),d0
		add.w	finalcheck(a5),d0
		cmp.w	#323,d0
		beq.b	.ok			;gecrackt !!!!!!!!
		move.l	#_LVOrtEZRequestA*2,d0
		asr.l	#1,d0
		lea	nokeymsg+2410,a1
		lea	key1msg-5210,a2
		sub.l	a3,a3
		sub.l	a4,a4
		lea	tagitemliste1,a0
		move.l	reqtbase(a5),a6
		lea	-2410(a1),a1
		lea	5210(a2),a2
		jsr	(a6,d0.l)
		lea	4(a7),a7
		bra.l	endall
	endc
.ok
		rts


arexxname:	dc.b	'rexx_AP'
rx_num:		dc.b	'0',0
	even

	*-------- Remove  Arexxport ------------*
removearexx:
		move.l	rxPort(a5),d2
		beq	.noport
		move.l	d2,a1
		move.l	4.w,a6
		jsr	_LVORemPort(a6)
		move.l	d2,a0
		jsr	_LVODeleteMsgPort(a6)
.noport:	clr.l	rxPort(a5)
		rts		

	*-------- Erzeuge ein AppWindow --------*
makeappwindow:

;erzeuge MsgPort für AppWindow
		clr.l	AppMsgPort(a5)
		move.l	4.w,a6
		jsr	_LVOCreateMsgPort(a6)
		tst.l	d0
		beq.b	.noport
		move.l	d0,AppMsgPort(a5)

		clr.l	appwinWnd(a5)
		moveq	#0,d0
		moveq	#0,d1
		move.l	MainwinWnd(a5),a0
		move.l	AppMsgPort(a5),a1
		move.l	wbbase(a5),a6
		jsr	_LVOAddAppWindowA(a6)
		tst.l	d0
		beq.b	.nowin
		move.l	d0,appwinWnd(a5)
.noport:
		rts

.nowin:
		move.l	AppMsgPort(a5),a0
		move.l	4.w,a6
		jsr	_LVODeleteMsgPort(a6)
		clr.l	AppMsgPort(a5)
		rts
				
deleteappwindow:
		move.l	appwinWnd(a5),d0
		beq.b	.wech
		move.l	d0,a0
		move.l	wbbase(a5),a6
		jsr	_LVORemoveAppWindow(a6)
		clr.l	appwinWnd(a5)

		move.l	AppMsgPort(a5),a0
		move.l	4.w,a6
		jsr	_LVODeleteMsgPort(a6)
		clr.l	AppMsgPort(a5)

.wech:		rts
		
;--------------------------------------------------------------------------
;---------------- Zeiche einen Frame -------------------------------------
;--------------------------------------------------------------------------
;d0=x d1=y d2=width d3=height d4= 0=Normal -1=Invert , a0=window
df_left	=	0
df_top	=	2
df_width=	4
df_height=	6

drawframe:
		movem.l	d5-a6,-(a7)
		lea	df_kordspuffer(pc),a1
		move.l	a1,a4
		move.w	d0,(a1)+
		move.w	d1,(a1)+
		move.w	d2,(a1)+
		move.w	d3,(a1)

		move.l	a4,a1

;Passe Koordinaten an
		move.w	(a1),d0
		bsr.w	computex
		add.w	OffX(a5),d0
		move.w	d0,(a1)+
		move.w	(a1),d0
		bsr.w	computey
		add.w	OffY(a5),d0
		move.w	d0,(a1)+
		move.w	(a1),d0
		bsr.w	computex
	;	add.w	OffX(a5),d0
		move.w	d0,(a1)+
		move.w	(a1),d0
		bsr.w	computey
	;	add.w	OffY(a5),d0
		move.w	d0,(a1)+

		move.l	wd_RPort(a0),a3

		move.l	a3,a1
		moveq	#2,d0
		tst.w	d4
		beq.b	.ok
		moveq	#1,d0
.ok
		move.l	gfxbase(a5),a6
		jsr	_LVOSetAPen(a6)

		move.l	gfxbase(a5),a6
		move.l	a3,a1
		move.w	df_left(a4),d0
		move.w	df_height(a4),d1
		add.w	df_top(a4),d1
		jsr	_LVOMove(a6)

		move.l	a3,a1
		move.w	df_left(a4),d0
		move.w	df_top(a4),d1
		jsr	_LVODraw(a6)

		move.l	a3,a1
		move.w	df_width(a4),d0
		add.w	df_left(a4),d0
		subq.w	#1,d0
		move.w	df_top(a4),d1
		jsr	_LVODraw(a6)

		move.l	a3,a1
		moveq	#1,d0
		tst.w	d4
		beq.b	.ok1
		moveq	#2,d0
.ok1
		move.l	gfxbase(a5),a6
		jsr	_LVOSetAPen(a6)
		
		move.l	a3,a1
		move.w	df_width(a4),d0
		add.w	df_left(a4),d0
		move.w	df_top(a4),d1
		jsr	_LVOMove(a6)

		move.l	a3,a1
		move.w	df_left(a4),d0
		add.w	df_width(a4),d0
		move.w	df_top(a4),d1
		add.w	df_height(a4),d1
		jsr	_LVODraw(a6)

		move.l	a3,a1
		move.w	df_left(a4),d0
		addq.w	#1,d0
		move.w	df_top(a4),d1
		add.w	df_height(a4),d1
		jsr	_LVODraw(a6)

		movem.l	(a7)+,d5-a6
		rts

df_kordspuffer:
		ds.w	4
		
;***************************************************************************
;*---------------------- gebe Statusline aus ------------------------------*
;***************************************************************************
;a4 = Text a3 = Argumentliste
status:
		movem.l d1-d3/a0-a2/a6,-(sp)

		bsr.b	parsesatusline

		move.l	#GD_gstatus,d0
		lsl.l	#2,d0
		lea	mainwinGadgets,a0
		move.l	(a0,d0),a0
		lea	statustext(pc),a1
		move.l	d7,(a1)			;geparste Line im Logopuffer
		move.l	mainwinWnd(a5),a1
		sub.l	a2,a2
		lea	statustag(pc),a3
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
		movem.l (sp)+,d1-d3/a0-a2/a6
		rts		

parsesatusline:
		lea	datapuffer,a0
		move.l	a0,d7
		
.nc		move.b	(a4)+,d0
		beq.b	.wech
		cmp.b	#'%',d0
		bne.b	.wc
		move.b	(a4)+,d1
		cmp.b	#'d',d1
		bne.b	.wcc

		move.l	(a3)+,d0
		bsr.w	Hexascii
		lea	zpuff,a1
		move.b	#'$',(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		bra.b	.nc
.wcc:
		move.b	d0,(a0)+
		move.b	d1,(a0)+	
		bra.b	.nc

.wc:		move.b	d0,(a0)+
		bra.b	.nc

.wech:		clr.b	(a0)+
		rts

statustag:
		dc.l	GTTX_Text
statustext:	dc.l	0
		dc.l	TAG_DONE

;***************************************************************************
;*---------------------- Set Text in Cylegadget ---------------------------*
;***************************************************************************
;d0 = GagetID d1 = TextNr. a0 = GList a1= Window
setcyle:
		movem.l d1-d7/a0-a6,-(a7)
		lea	cyletag(pc),a3
		move.l	d1,4(a3)		
		sub.l	a2,a2
		lsl	#2,d0
		move.l	(a0,d0),a0
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
		move.l	abouttest(a5),a0
		cmp.l	#$616e2075,(keymsg-aboutmsg)+8(a0)
		bne.w	keyfault1
		movem.l (a7)+,d1-d7/a0-a6
		rts
cyletag:
		dc.l	GTCY_Active
textnr:		dc.l	0
		dc.l	TAG_DONE

;***************************************************************************
;*---------------- Set Number in Numbergadget im Mainwindow----------------*
;***************************************************************************
;d0 = GagetID d1 = Number
setnumber:
		movem.l d1-d7/a0-a6,-(a7)
		lea	numTag(pc),a3
		move.l	d1,4(a3)		
		sub.l	a2,a2
		lsl	#2,d0
		lea	mainwinGadgets,a0
		move.l	(a0,d0),a0
		move.l	mainwinWnd(a5),a1
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
.codeok:	movem.l (a7)+,d1-d7/a0-a6
		rts
numtag:
		dc.l	GTNM_Number
num:		dc.l	0
		dc.l	GTNM_Justification,GTJ_Left
		dc.l	TAG_DONE

lastreqcode:	dc.l	$00028816	;checksumme für lastreq

;***************************************************************************
;*------------------------ Gebe Text aus ----------------------------------*
;***************************************************************************
;a1 = Textstruck
textout:
		move.l  IntBase(a5),a6
		move.l  mainwinWnd(a5),a0
		move.l  wd_RPort(a0),a0
		sub.l	a2,a2
		moveq	#0,d0
		moveq	#0,d1
		jmp	_LVOPrintIText(a6)

;***************************************************************************
;*--------------- Prüfe ob File überschrieben werden soll -----------------*
;***************************************************************************
checkoverwrite:				
		move.l	abouttest(a5),a0
		cmp.l	#$616e2075,(keymsg-aboutmsg)+8(a0)
		beq.b	.w
		move.l	execbasepuffer(a5),a0
		move.l	mainwinWnd(a5),(a0)

.w		tst.b	overwrite(a5)
		beq.b	writeok			;File kann überschrieben werden
		lea	Savename(a5),a1
		move.l	a1,d1
		moveq	#-1,d2
		move.l	dosbase(a5),a6
		jsr	_LVOlock(a6)		;hole lock
		tst.l	d0
		beq.b	writeok
		move.l	d0,d1
		jsr	_LVOUnlock(a6)	;gib lock frei
		bra.b	fragenach	;frage ob überschreiben
writeok:
		moveq	#1,d0
		rts
fragenach:
		lea	overmsg,a1
		lea	overmsg1,a2
		sub.l	a3,a3
		sub.l	a4,a4
		lea	tagitemliste1,a0
		move.l	reqtbase(a5),a6
		jmp	_LVOrtEZRequestA(a6)

;***************************************************************************
;*---------------------- Interrupt für Memshow ----------------------------*
;***************************************************************************
initmemshow:
		lea	irqstruck(pc),a1
		lea	memcheck(pc),a0
		move.l	a0,18(a1)
		moveq	#5,d0		;VBI
		move.l	4,a6
		jmp	_LVOAddIntServer(a6)				
		
irqstruck:
		ds.l	2
		dc.b	2
		dc.b	0	;Prioität
		ds.l	3

;***************************************************************************
;*------------------ Interrupt für Memshow entfernen ----------------------*
;***************************************************************************
endmemshow:
		move.l	4,a6
		lea	irqstruck(pc),a1		
		moveq	#5,d0
		jmp	_LVORemIntServer(a6)
		
;***************************************************************************
;*------------------------ Interrupt Memshow  -----------------------------*
;***************************************************************************
memcheck:
		movem.l	d0-d7/a0-a6,-(a7)

		move.l	4,a6
		move.l	#MEMF_CHIP,d1
		jsr	_LVOAvailMem(a6)
		move.l	d0,d4
		
		move.l	#MEMF_FAST,d1
		jsr	_LVOAvailMem(a6)
		move.l	d0,d5

;wandle Mem in Acsii um

		move.l	d4,d1
		move.l	#GD_gchip,d0
		bsr.w	setnumber

		move.l	d5,d1
		move.l	#GD_gfast,d0
		bsr.w	setnumber

		move.l	d4,d1
		add.l	d5,d1
		move.l	#GD_gmemory,d0
		bsr.w	setnumber

		movem.l	(a7)+,d0-d7/a0-a6
		moveq	#0,d0
		rts

;***************************************************************************
;*---------------------- Wandle Hex in DezAscii  --------------------------*
;***************************************************************************
;a0=Puffer d0=Wert
Hexdez:		
		movem.l	d0-d3,-(a7)
		lea	hexdeztab(pc),a1	;Tabellendisgs
		move.l	a0,a3
		moveq	#7,d3
.Hexdez2:	move.l	(a1)+,d1		;Tabellenzahl
		moveq	#0,d2			;Zahl
.Hexdez3:	addq.l	#1,d2
		sub.l	d1,d0
		bcc.s	.Hexdez3
		add.l	d1,d0
		add.b	#$2f,d2
		move.b	d2,(a0)+
		dbf	d3,.Hexdez2
		clr.b	(a0)+
		movem.l	(a7)+,d0-d3

;		move.l	a3,a0			;Pufferadresse nach a0
;		moveq	#0,d0
;.n:		addq.b	#1,d0
;		cmp.b	#'0',(a0)
;		bne.b	nozero
;		cmp.b	#8,d0
;		beq.b	nozero
;		move.b	#' ',(a0)+
;		bra.b	.n
nozero:		rts				;Rücksprung
		
Hexdeztab:	dc.l	10000000,1000000,100000,10000
		dc.l	1000,100,10,1
;		;1000000000,

usepuffer	dc.l	0,0
lastreqcode1:	dc.l	$00088b2c ;$0005b4d0	;checksumme für lastreq

;***************************************************************************
;*--------------- Wandle Hex in DezAscii für 4-Stellig --------------------*
;***************************************************************************
;Hexdez4:		
;		lea	hexdeztab4(pc),a1	;Tabellendisgs
;		move.l	a0,a3
;		moveq	#3,d3
;.Hexdez2:	move.l	(a1)+,d1		;Tabellenzahl
;		moveq	#0,d2			;Zahl
;.Hexdez3:	addq.l	#1,d2
;		sub.l	d1,d0
;		bcc.s	.Hexdez3
;		add.l	d1,d0
;		add.b	#$2f,d2
;		move.b	d2,(a0)+
;		dbf	d3,.Hexdez2
;		move.l	a3,a0			;Pufferadresse nach a0
;		moveq	#0,d0
;.n:		addq.b	#1,d0
;		cmp.b	#'0',(a0)
;		bne.b	nozero4
;		cmp.b	#4,d0
;		beq.b	nozero4
;		move.b	#' ',(a0)+
;		bra.b	.n
;nozero4:		rts				;Rücksprung
;		
;Hexdeztab4:	dc.l	1000,100,10,1

;***************************************************************************
;*---------- Wandle Hex in HexAscii für 4-Stellig für Copper --------------*
;***************************************************************************
Hexascii:		
		movem.l	d0-d7/a0-a6,-(a7)
		lea	zpuff(pc),a0
		moveq	#7,d1
next:		rol.l	#4,d0
		move.l	d0,d3
		and.b	#$f,d3
		add.b	#48,d3
		cmp.b	#58,d3
		bcs.b	out
		addq.b	#7,d3
out:		move.b	d3,(a0)+
		dbra	d1,next
		movem.l	(a7)+,d0-d7/a0-a6
		rts

zpuff:
		dc.b	'        '
		
;---------------------------------------------------------------------------
;------------ Ermittle Wert aus Integer Gadget -----------------------------
;---------------------------------------------------------------------------
;>a0 Gadget
; a1 Window
;<d0 Wert
getintegervalue:
		movem.l	d1-a6,-(a7)

		sub.l	a2,a2
		lea	get_integerget(pc),a3
		move.l	gadbase(a5),a6
		jsr	_LVOGT_GetGadgetAttrsA(a6)

		move.l	get_integerbuffer(pc),d0

		movem.l	(a7)+,d1-a6
		rts


get_integerget:	dc.l	GTIN_Number,get_integerbuffer,TAG_DONE

get_integerbuffer: dc.l	0

;---------------------------------------------------------------------------
;--------------- Setze  Wert in Integer Gadget -----------------------------
;---------------------------------------------------------------------------
;>a0 Gadget
; a1 Window
; d0 wert
setintegervalue:
		movem.l	d1-a6,-(a7)

		sub.l	a2,a2
		lea	set_integerget(pc),a3
		move.l	d0,4(a3)
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		movem.l	(a7)+,d1-a6
		rts

set_integerget:		dc.l	GTIN_Number,0,TAG_DONE

;***************************************************************************
;*---------------------- Ermittle länge eines Files -----------------------*
;***************************************************************************
filesize:
		lea	loadname(a5),a1
filesize1:
		move.l	a1,d1
		moveq	#-2,d2			;zugriffsmodus lesen
		move.l	dosbase(a5),a6
		jsr	_LVOLock(a6)	
		move.l	d0,filelockmerk(a5)
		beq.b	sizeerror
		move.l	d0,d1
		lea 	infoblock,a0
		move.l	a0,d2
		jsr	_LVOExamine(a6)		;Fileinfoblock holen
		tst.l	d0
		beq.b	sizeerror1
		lea	infoblock,a0
	;	add.l	#124,a0	
		move.l	fib_size(a0),d0
	;	beq	error
		move.l	d0,size(a5)
		move.l	filelockmerk(a5),d1
		jsr	_LVOUnlock(a6)
.codeok:	moveq	#0,d0
		rts		
sizeerror1:
		move.l	filelockmerk(a5),d1
		jsr	_LVOUnlock(a6)
sizeerror:
		moveq	#-1,d0
		rts	

;=====================================================================
; ------- Ghoste ein Gadget ----------------------
;d0=Gadget d1= 1 ghosten 0 löschen a0=Gadgets a1=Window
ghost:
		movem.l	d0-a6,-(a7)
		lea	.doghost(pc),a2
		move.l	d1,(a2)
		lsl.l	#2,d0
		move.l	(a0,d0),a0
		sub.l	a2,a2
		lea	.ghosttag(pc),a3
		move.l	gadbase(a5),a6
		jsr	_LVOGT_SetGadgetAttrsA(a6)
		movem.l	(a7)+,d0-a6
		rts
.ghosttag:
		dc.l	GA_Disabled
.doghost:	dc.l	0
		dc.l	TAG_DONE


;======================================================================
;---------------------- Setwaitpoint ----------------------------------
;======================================================================
;a0=Window
setwaitpointer:
		movem.l	d1-a6,-(a7)
		move.l	a0,a2

		lea	req_struck,a0
		move.l	intbase(a5),a6
		jsr	_LVOInitRequester(a6)
		lea	req_struck,a0
		move.l	A2,A1			; Window ptr
		jsr	_LVORequest(A6)		; Display invisible requester
		tst.l	D0
		bne.b	.dowaitpointer

		moveq	#0,D0
		bra.b	.wech

.dowaitpointer
		move.l	d0,reqmerk
		
		move.l	intbase(a5),a6
		tst.b	kick3(a5)
		bne.b	.k3

		move.l	a2,a0
		lea	WaitPointer,a1
		moveq	#16,d0
		moveq	#16,d1
		moveq	#-6,d2
		moveq	#0,d3
		jsr	_LVOSetpointer(a6)
		bra.b	.wech
.k3
		move.l	a2,a0
		lea	waittag(pc),a1
		jsr	_LVOSetWindowPointerA(a6)

		move.l	a2,d0
.wech		movem.l	(a7)+,d1-a6
		rts
waittag:
		dc.l	WA_BusyPointer,1,0

reqmerk:	ds.l	1

;======================================================================
;---------------------- Clearwaitpoint --------------------------------
;======================================================================
;a0=Window
clearwaitpointer:
		movem.l	d0-a6,-(a7)

		move.l	a0,D2			; Window ptr
		beq.b	.wech			; Previous error, exit

		lea	req_struck,a0
		move.l	D2,A1			; Window
		move.l	intbase(a5),a6
		jsr	_LVOEndRequest(A6)	; Clear requester

		move.l	d2,a0
		move.l	intbase(a5),a6
		tst.b	kick3(a5)
		bne.b	.k3
		jsr	_LVOClearPointer(a6)
		bra.b	.wech
.k3
		lea	clearwaittag(pc),a1
		jsr	_LVOSetWindowPointerA(a6)
.wech
		movem.l	(a7)+,d0-a6
		rts
clearwaittag:
		dc.l	WA_Pointer,0,0

;***************************************************************************
;*-------------------------- Ermittle WB-Daten ----------------------------*
;***************************************************************************
checkwbsize:
		movem.l	d1-d7/a0-a6,-(a7)
		move.l	intbase(a5),a6
		lea	pubscreen(pc),a0
		jsr	_LVOLockPubScreen(a6)
		move.l	d0,WBScreen(a5)
		bne.b	.pubok			;Screenwurde gefunden
		movem.l	(a7)+,d1-d7/a0-a6
		moveq	#-1,d0
		rts
.pubok:
		move.l	d0,a0
		move.w	12(a0),WBwidth(a5)
		move.w	14(a0),WBheight(a5)
		move.l	40(a0),WBFontStruck(a5)

		move.l	4(a0),a0
		move.l	intbase(a5),a6
		jsr	_LVOViewPortAddress(a6)
		move.l	d0,a0
		move.l	gfxbase(a5),a6
		jsr	_LVOGetVPModeID(a6)
		move.l	d0,WBModeID(a5)
		sub.l	a0,a0
		move.l	WBScreen(a5),a1
		move.l	intbase(a5),a6
		jsr	_LVOUnlockPubScreen(a6)
;		move.l	lastreq(a5),a0
;		lea	-112(a0),a0
;		addq.l	#4,a0
;		move.w	#$662a,(a0)+		;für Lastrequester Protect
		movem.l	(a7)+,d1-d7/a0-a6
		moveq	#0,d0
		rts

pubscreen:	dc.b	'Workbench',0
		
;***************************************************************************
;*-------------------- Ermittle Mainwindow Position -----------------------*
;***************************************************************************
checkmainwinpos:
		move.l	mainwinWnd(a5),a0
checkprefswinpos:
		moveq	#0,d0
		moveq	#0,d1
		move.w	wd_LeftEdge(a0),d0
		move.w	wd_TopEdge(a0),d1
		rts
;***************************************************************************
;*----------------------- Activiere Window --------------------------------*
;***************************************************************************
;a0 = Window
aktiwin:
		move.l	intbase(a5),a6
		jmp	_LVOActivateWindow(a6)

;=====================================================================
;------- Entferne altes Bild ,falls eins geladen wurde -------
oldpicwech:
		tst.w	loadflag(a5)
		beq.b	.memok
		move.l	picmem(a5),a1		;Speicher vom alten Pic
		cmp.l	#0,a1
		beq.b	.memok
	;	move.l	memsize(a5),d0		;freigeben
		move.l	4,a6
		jsr	_LVOFreeVec(a6)
		clr.w	loadflag(a5)
		clr.l	picmem(a5)
.memok:
		bra.w	memcheck

;---------------------------------------------------------------------
;
;	Hier folgen die Routinen von Captain Bifat
;
;---------------------------------------------------------------------
;---------------------------------------------------------------------
;
;		R24to12	dx,dy
;		   
;		"Round rgb24 to rgb12"
;
;		transformiert 24Bit-RGB in 12Bit-RGB.
;		die unteren 4 Bit jeder Farbkomponente
;		werden gerundet.
;
;	>	dx.l	24Bit-Source
;		dy.w	Trash-Register
;	<	dx.l	12Bit-Dest


R24to12		macro
		swap	\1
		moveq	#0,\2
		move.b	\1,\2
		addq.w	#8,\2
		lsr.w	#4,\2
		btst	#4,\2
		beq.b	*+4
		moveq	#15,\2
		move.w	\2,\1
		lsl.w	#8,\1
		swap	\1
		move.b	\1,\2
		addq.w	#8,\2
		lsr.w	#4,\2
		btst	#4,\2
		beq.b	*+4
		moveq	#15,\2
		swap	\1
		or.b	\2,\1
		swap	\1
		lsr.w	#8,\1
		move.b	\1,\2
		addq.w	#8,\2
		btst	#8,\2
		beq.b	*+6
		move.b	#$f0,\2
		and.w	#$f0,\2
		swap	\1
		or.w	\2,\1
		endm

;;========================================================================
;;
;;		RGBDIVERSITY12
;;		1994, (C)aptain Bifat /TEK
;;		v1.0 25.12.1994
;;		v1.1 12.1.1995	benutzt x² Tabelle
;;
;;		Ermittelt die Farbabweichung zwischen zwei
;;		RGB12-Farben. Zurückgeliefert wird das
;;		Quadrat des kartesischen Abstands im RGB-Raum.
;;		Je kleiner, desto besser die Übereinstimmung.
;;
;;	>	d0.w	erster RGB, Format $0RGB
;;		d1.w	zweiter RGB, Format $0RGB
;;	<	d0.l	Abweichung
;
;
RGBDiversity12:	movem.l	d1-d5,-(a7)

		moveq	#0,d5
		cmp.w	d0,d1
		beq.b	rd12_end		

		moveq	#15,d4

		move.w	d0,d2
		move.w	d1,d5
		and.w	d4,d2
		and.w	d4,d5
		sub.w	d2,d5
		add.w	d5,d5
		move.w	rd12_qtab(pc,d5.w),d5
		
		lsr.w	#4,d0
		lsr.w	#4,d1
		move.w	d0,d2
		move.w	d1,d3
		and.w	d4,d2
		and.w	d4,d3
		sub.w	d3,d2
		add.w	d2,d2
		add.w	rd12_qtab(pc,d2.w),d5

		lsr.w	#4,d0
		lsr.w	#4,d1
		sub.w	d1,d0
		add.w	d0,d0
		add.w	rd12_qtab(pc,d0.w),d5
	
rd12_end	move.l	d5,d0
		movem.l	(a7)+,d1-d5
		rts

		dc.w	15^2,14^2,13^2,12^2,11^2,10^2,9^2,8^2
		dc.w	7^2,6^2,5^2,4^2,3^2,2^2,1^2
rd12_qtab	dc.w	0,1^2,2^2,3^2,4^2,5^2,6^2,7^2
		dc.w	8^2,9^2,10^2,11^2,12^2,13^2,14^2,15^2

;========================================================================
;
;		RGBDIVERSITY24
;		1994, (C)aptain Bifat /TEK
;		v1.0 25.12.1994
;		v1.1 12.1.1995	benutzt x² Tabelle
;
;		Ermittelt die Farbabweichung zwischen zwei
;		RGB24-Farben. Zurückgeliefert wird das
;		Quadrat des kartesischen Abstands im RGB-Raum.
;		Je kleiner, desto besser die Übereinstimmung.
;
;	>	d0.l	erster RGB, Format $00RRGGBB
;		d1.l	zweiter RGB, Format $00RRGGBB
;	<	d0.l	Abweichung		


RGBDiversity24:	movem.l	d1-d5/a0,-(a7)

		moveq	#0,d5
		cmp.l	d0,d1
		beq.b	rd24_end		

		lea	rd24_qtab(pc),a0

		moveq	#0,d4
		not.b	d4

		move.w	d0,d2

;		move.l	d1,d5
		move.w	d1,d5

		and.w	d4,d2
		and.w	d4,d5
		sub.w	d2,d5
		add.w	d5,d5
		move.w	(a0,d5.w),d5
		
		lsr.l	#8,d0
		lsr.l	#8,d1
		move.l	d0,d2
		move.w	d1,d3
		and.w	d4,d2
		and.w	d4,d3
		sub.w	d3,d2
		add.w	d2,d2
		move.w	(a0,d2.w),d2
		add.l	d2,d5
		
		lsr.w	#8,d0
		lsr.w	#8,d1
		sub.w	d1,d0
		add.w	d0,d0
		move.w	(a0,d0.w),d0
		add.l	d0,d5

rd24_end	move.l	d5,d0
		movem.l	(a7)+,d1-d5/a0
		rts

	DC.W	$FE01,$FC04,$FA09,$F810,$F619,$F424,$F231,$F040
	DC.W	$EE51,$EC64,$EA79,$E890,$E6A9,$E4C4,$E2E1,$E100
	DC.W	$DF21,$DD44,$DB69,$D990,$D7B9,$D5E4,$D411,$D240
	DC.W	$D071,$CEA4,$CCD9,$CB10,$C949,$C784,$C5C1,$C400
	DC.W	$C241,$C084,$BEC9,$BD10,$BB59,$B9A4,$B7F1,$B640
	DC.W	$B491,$B2E4,$B139,$AF90,$ADE9,$AC44,$AAA1,$A900
	DC.W	$A761,$A5C4,$A429,$A290,$A0F9,$9F64,$9DD1,$9C40
	DC.W	$9AB1,$9924,$9799,$9610,$9489,$9304,$9181,$9000
	DC.W	$8E81,$8D04,$8B89,$8A10,$8899,$8724,$85B1,$8440
	DC.W	$82D1,$8164,$7FF9,$7E90,$7D29,$7BC4,$7A61,$7900
	DC.W	$77A1,$7644,$74E9,$7390,$7239,$70E4,$6F91,$6E40
	DC.W	$6CF1,$6BA4,$6A59,$6910,$67C9,$6684,$6541,$6400
	DC.W	$62C1,$6184,$6049,$5F10,$5DD9,$5CA4,$5B71,$5A40
	DC.W	$5911,$57E4,$56B9,$5590,$5469,$5344,$5221,$5100
	DC.W	$4FE1,$4EC4,$4DA9,$4C90,$4B79,$4A64,$4951,$4840
	DC.W	$4731,$4624,$4519,$4410,$4309,$4204,$4101,$4000
	DC.W	$3F01,$3E04,$3D09,$3C10,$3B19,$3A24,$3931,$3840
	DC.W	$3751,$3664,$3579,$3490,$33A9,$32C4,$31E1,$3100
	DC.W	$3021,$2F44,$2E69,$2D90,$2CB9,$2BE4,$2B11,$2A40
	DC.W	$2971,$28A4,$27D9,$2710,$2649,$2584,$24C1,$2400
	DC.W	$2341,$2284,$21C9,$2110,$2059,$1FA4,$1EF1,$1E40
	DC.W	$1D91,$1CE4,$1C39,$1B90,$1AE9,$1A44,$19A1,$1900
	DC.W	$1861,$17C4,$1729,$1690,$15F9,$1564,$14D1,$1440
	DC.W	$13B1,$1324,$1299,$1210,$1189,$1104,$1081,$1000
	DC.W	$0F81,$0F04,$0E89,$0E10,$0D99,$0D24,$0CB1,$0C40
	DC.W	$0BD1,$0B64,$0AF9,$0A90,$0A29,$09C4,$0961,$0900
	DC.W	$08A1,$0844,$07E9,$0790,$0739,$06E4,$0691,$0640
	DC.W	$05F1,$05A4,$0559,$0510,$04C9,$0484,$0441,$0400
	DC.W	$03C1,$0384,$0349,$0310,$02D9,$02A4,$0271,$0240
	DC.W	$0211,$01E4,$01B9,$0190,$0169,$0144,$0121,$0100
	DC.W	$00E1,$00C4,$00A9,$0090,$0079,$0064,$0051,$0040
	DC.W	$0031,$0024,$0019,$0010,$0009,$0004,$0001
rd24_qtab	dc.w	$0000
	DC.W	$0001,$0004,$0009,$0010,$0019,$0024,$0031,$0040
	DC.W	$0051,$0064,$0079,$0090,$00A9,$00C4,$00E1,$0100
	DC.W	$0121,$0144,$0169,$0190,$01B9,$01E4,$0211,$0240
	DC.W	$0271,$02A4,$02D9,$0310,$0349,$0384,$03C1,$0400
	DC.W	$0441,$0484,$04C9,$0510,$0559,$05A4,$05F1,$0640
	DC.W	$0691,$06E4,$0739,$0790,$07E9,$0844,$08A1,$0900
	DC.W	$0961,$09C4,$0A29,$0A90,$0AF9,$0B64,$0BD1,$0C40
	DC.W	$0CB1,$0D24,$0D99,$0E10,$0E89,$0F04,$0F81,$1000
	DC.W	$1081,$1104,$1189,$1210,$1299,$1324,$13B1,$1440
	DC.W	$14D1,$1564,$15F9,$1690,$1729,$17C4,$1861,$1900
	DC.W	$19A1,$1A44,$1AE9,$1B90,$1C39,$1CE4,$1D91,$1E40
	DC.W	$1EF1,$1FA4,$2059,$2110,$21C9,$2284,$2341,$2400
	DC.W	$24C1,$2584,$2649,$2710,$27D9,$28A4,$2971,$2A40
	DC.W	$2B11,$2BE4,$2CB9,$2D90,$2E69,$2F44,$3021,$3100
	DC.W	$31E1,$32C4,$33A9,$3490,$3579,$3664,$3751,$3840
	DC.W	$3931,$3A24,$3B19,$3C10,$3D09,$3E04,$3F01,$4000
	DC.W	$4101,$4204,$4309,$4410,$4519,$4624,$4731,$4840
	DC.W	$4951,$4A64,$4B79,$4C90,$4DA9,$4EC4,$4FE1,$5100
	DC.W	$5221,$5344,$5469,$5590,$56B9,$57E4,$5911,$5A40
	DC.W	$5B71,$5CA4,$5DD9,$5F10,$6049,$6184,$62C1,$6400
	DC.W	$6541,$6684,$67C9,$6910,$6A59,$6BA4,$6CF1,$6E40
	DC.W	$6F91,$70E4,$7239,$7390,$74E9,$7644,$77A1,$7900
	DC.W	$7A61,$7BC4,$7D29,$7E90,$7FF9,$8164,$82D1,$8440
	DC.W	$85B1,$8724,$8899,$8A10,$8B89,$8D04,$8E81,$9000
	DC.W	$9181,$9304,$9489,$9610,$9799,$9924,$9AB1,$9C40
	DC.W	$9DD1,$9F64,$A0F9,$A290,$A429,$A5C4,$A761,$A900
	DC.W	$AAA1,$AC44,$ADE9,$AF90,$B139,$B2E4,$B491,$B640
	DC.W	$B7F1,$B9A4,$BB59,$BD10,$BEC9,$C084,$C241,$C400
	DC.W	$C5C1,$C784,$C949,$CB10,$CCD9,$CEA4,$D071,$D240
	DC.W	$D411,$D5E4,$D7B9,$D990,$DB69,$DD44,$DF21,$E100
	DC.W	$E2E1,$E4C4,$E6A9,$E890,$EA79,$EC64,$EE51,$F040
	DC.W	$F231,$F424,$F619,$F810,$FA09,$FC04,$FE01

;=========================================================================
;
;		TurboCopyMem 3.1
;		1992-1995 © Timm S. Müller
;
;		- sehr schnelle Kopierroutine
;		- für gerade Adressen und Länge
;		- unterstützt überlappendes Kopieren
;		- alle Registerinhalte bleiben erhalten
;		- minimaler Overhead
;		- Länge 0 ist zulässig
;		- kopiert maximal 16MB
;
;		v3.0	- unterstützt überlappendes Kopieren
;		v3.1	- Overhead drastisch optimiert
;
;	>	a0	Startadresse (nur geradzahlig)
;		a1	Zieladresse (nur geradzahlig)
;		d0.l	Länge in Bytes (nur geradzahlig)



TurboCopyMem:	movem.l	a0/a1/d0/d2,-(a7)

		move.l	d0,d2

		cmp.l	a1,a0
		blt.s	tcm_rueck

		clr.b	d0
		tst.l	d0
		beq.s	tcm_vorw_small

		sub.l	d0,d2
		swap	d2
		lsr.l	#8,d0
		subq.w	#1,d0
		move.w	d0,d2

		movem.l	d1/d3-d7/a2-a6,-(a7)
		moveq	#44,d1
tcm_vorw256	movem.l	(a0)+,d0/d3-d7/a2-a6		; 44 Bytes
		movem.l	d0/d3-d7/a2-a6,(a1)
		add.l	d1,a1
		movem.l	(a0)+,d0/d3-d7/a2-a6		; 44 Bytes
		movem.l	d0/d3-d7/a2-a6,(a1)
		add.l	d1,a1
		movem.l	(a0)+,d0/d3-d7/a2-a6		; 44 Bytes
		movem.l	d0/d3-d7/a2-a6,(a1)
		add.l	d1,a1
		movem.l	(a0)+,d0/d3-d7/a2-a6		; 44 Bytes
		movem.l	d0/d3-d7/a2-a6,(a1)
		add.l	d1,a1
		movem.l	(a0)+,d3-d7/a2-a6		; 40 Bytes
		movem.l	d3-d7/a2-a6,(a1)
		moveq	#40,d0
		add.l	d0,a1
		movem.l	(a0)+,d3-d7/a2-a6		; 40 Bytes
		movem.l	d3-d7/a2-a6,(a1)
		add.l	d0,a1
		dbf	d2,tcm_vorw256
		movem.l	(a7)+,d1/d3-d7/a2-a6

		swap	d2

tcm_vorw_small	lsr.w	#1,d2
		subq.w	#1,d2
		bmi.s	tcm_nosmall

tcm_vorw_smlop	move.w	(a0)+,(a1)+
		dbf	d2,tcm_vorw_smlop

tcm_nosmall	movem.l	(a7)+,a0/a1/d0/d2
tcm_end		rts


tcm_rueck	add.l	d0,a0
		add.l	d0,a1

		clr.b	d0
		tst.l	d0
		beq.s	tcm_rueck_small

		sub.l	d0,d2
		swap	d2
		lsr.l	#8,d0
		subq.w	#1,d0
		move.w	d0,d2

		movem.l	d1/d3-d7/a2-a6,-(a7)
		moveq	#44,d1
tcm_rueck256	sub.l	d1,a0
		movem.l	(a0),d0/d3-d7/a2-a6		; 44 Bytes
		movem.l	d0/d3-d7/a2-a6,-(a1)
		sub.l	d1,a0
		movem.l	(a0),d0/d3-d7/a2-a6		; 44 Bytes
		movem.l	d0/d3-d7/a2-a6,-(a1)
		sub.l	d1,a0
		movem.l	(a0),d0/d3-d7/a2-a6		; 44 Bytes
		movem.l	d0/d3-d7/a2-a6,-(a1)
		sub.l	d1,a0
		movem.l	(a0),d0/d3-d7/a2-a6		; 44 Bytes
		movem.l	d0/d3-d7/a2-a6,-(a1)
		moveq	#40,d0
		sub.l	d0,a0
			movem.l	(a0),d3-d7/a2-a6		; 40 Bytes
		movem.l	d3-d7/a2-a6,-(a1)
		sub.l	d0,a0
		movem.l	(a0),d3-d7/a2-a6		; 40 Bytes
		movem.l	d3-d7/a2-a6,-(a1)
		dbf	d2,tcm_rueck256
		movem.l	(a7)+,d1/d3-d7/a2-a6

		swap	d2

tcm_rueck_small	lsr.w	#1,d2
		subq.w	#1,d2
		bmi.s	tcm_rueck_nosml
tcm_rueck_smlop	move.w	-(a0),-(a1)
		dbf	d2,tcm_rueck_smlop

tcm_rueck_nosml	movem.l	(a7)+,a0/a1/d0/d2
		rts

;=========================================================================
;		Bpl2chunkyLine
;	
;		Konvertiert eine Zeile Bitplane in Chunkys
;	
;		- keine Begrenzung im Anfangs- und Endpunkt
;	
;		> d0	Y-Line
;		  xbrush1,xbrush2 = Anfang und Ende
;		  a0	Chunkypuffer

bpl2chunkyLine:
		movem.l	d0-a6,-(a7)

		move.l	a0,a2

		move.l	bytebreite(a5),d3
		mulu	d3,d0
		move.l	d0,d5	;Y offset

		move.l	picmem(a5),bitmapmerk(a5)
		sub.l	a1,a1	;Planeoffset

		move.w	xbrush1(a5),d4
		move.w	Brushword(a5),d7
		subq.l	#1,d7
b2cl_nextword:
		move.b	planes(a5),planemerk(a5)
		moveq	#1,d2

b2cl_newplane
		move.l	firstword(a5),d0
		add.l	d0,d0		;in Byte
		move.l	bitmapmerk(a5),a0
		add.l	d0,a0
		add.l	d5,a0		;Y-Offset
		add.l	a1,a0		;Planeoffset
		
		move.l	bitshift(a5),d6
b2cl_newword:
		move.l	(a0),d0
		lsl.l	d6,d0
		swap	d0
		move.w	xbrush2(a5),d1
		cmp.w	d4,d1
		bhs.b	.pixok
		move.w	d4,d3
		sub.w	d1,d3
		lsr.w	d3,d0
		lsl.w	d3,d0	;zuviele Bits löschen
.pixok:
		lea	chunkypuffer(a5),a3

		moveq	#16-1,d3
.nextbit:		
		add.w	d0,d0
		bcc.b	.noset
		or.b	d2,(a3)
.noset:		addq.l	#1,a3
		dbra	d3,.nextbit
		lsl.b	#1,d2
		add.l	oneplanesize(a5),a1
		sub.b	#1,planemerk(a5)
		bne.b	b2cl_newplane

		add.l	#16,d4		;XBrush1
		lea	chunkypuffer(a5),a3
		move.l	d4,d1
		move.w	xbrush2(a5),d0
		sub.w	d0,d1
		bmi.b	.ok
		moveq	#16-1,d3
		sub.w	d1,d3
		bra.b	.nextbyte
.ok		moveq	#16-1,d3
.nextbyte	move.b	(a3)+,(a2)+
		dbra	d3,.nextbyte

.clear		lea	chunkypuffer(a5),a3
		clr.l	(a3)+
		clr.l	(a3)+
		clr.l	(a3)+
		clr.l	(a3)+

		addq.l	#2,bitmapmerk(a5)
		sub.l	a1,a1
		dbra	d7,b2cl_nextword

		movem.l	(a7)+,d0-a6
		rts

;=========================================================================

welcomemsg:	dc.b	'Welcome to ArtPRO!',0
loadfilemsg:	dc.b    'Load file...',0
savefilemsg:	dc.b	'Save file...',0
savecolormsg:	dc.b	'Save color...',0
loaderrormsg:	dc.b	'Error loading file!',0
saveerrormsg:	dc.b	'Error saving file!',0
notmemmsg:	dc.b	'Not enough memory!',0
notaiffmsg:	dc.b	'Not an IFF image.',0
invalidiffmsg:	dc.b	'IFF structure invalid!',0
readymsg:	dc.b	'Ready!',0
noimageload:	dc.b	'No image loaded.',0
noimagesavemsg:	dc.b	'No image saved.',0
noscreenmsg:	dc.b	'No screenmode selected.',0
notwidthmsg:	dc.b	'Insufficient screen width.',0
welcombackmsg:	dc.b	'Welcome back to ArtPRO!',0
breakmsg:	dc.b	'Mask color request cancelled.',0
screennotmsg:	dc.b	'Screen not available.',0
screenloadedmsg:dc.b	'Screen successfully loaded.',0
screenfailed:	dc.b	'Screen open failed!',0
tomanycolorsmsg:dc.b	'Too many colors for OCS/ECS!',0
dimemsionsmsg:	dc.b	'File dimensions do not match!',0
extnotdefined:	dc.b	'External definition not defined!',0
linksavemsg:	dc.b	'Linksave cancelled.',0
nocolormsg:	dc.b	'No Color-Bias with this Screen Mode',0
colorbiasfailedmsg:dc.b	'Color-Bias screen open failed!',0
spritecancellmsg:dc.b	'Spritesave cancelled.',0
cmapchunkmsg:	dc.b	'CMAP Chunk not found !',0


	even
;------------------------------------------------------------------------
;----------- Auto Loader ------------------------------------------------
;------------------------------------------------------------------------
autoload:
		move.l	utilbase(a5),a6

		lea	gloadreqList,a4
.w		move.l	(a4),a4
		tst.l	(a4)
		beq.w	al_loaddatatype

		cmp.l	#'AUTO',18(a4)
		beq.b	.w
		cmp.l	#'LDTC',18(a4)	;Datatype loader ersma überspringen
		beq.b	.w

		move.l	30(a4),a0	;Taglist
		move.l	#APT_Autoload,d0
		jsr	_LVOFindTagItem(a6)
		tst.l	d0
		beq.b	.w
		move.l	d0,a0
		tst.l	4(a0)
		beq.b	.w

		move.l	14(a4),a0
		move.l	a4,-(a7)
		jsr	(a0)		;Loader anspringen
		move.l	(a7)+,a4
		cmp.l	#APLE_UNKNOWN,d3	;Wurde file geladen
		beq.b	.w1
		rts

.w1		move.l	APG_Filehandle(a5),d1
		moveq	#0,d2
		move.l	#OFFSET_BEGINNING,d3
		move.l	APG_Dosbase(a5),a6
		jsr	_LVOSeek(a6)

		move.l	utilbase(a5),a6
		bra.b	.w

;Versuche überdatatype zu laden

al_loaddatatype:
		tst.b	availdatatype(a5)
		bne	loaddatatype
		lea	al_unknownmsg(pc),a4
		bsr	status
		moveq	#APLE_ERROR,d3
		rts

al_unknownmsg:	dc.b	'Unknown fileformat!',0

;***************************************************************************
;*-------------------------- Iff-Loader -----------------------------------*
;***************************************************************************
loadiff:
		lea	bytepuffer,a4
		bsr.w	readbyte
		cmp.l	#'FORM',(a4)		;Test IFF
		bne.w	notiff1	
		bsr.w	readbyte
		bsr.w	readbyte
		cmp.l	#'ILBM',(a4)		;Test ob IFF-Pic
		beq.s	.li
		cmp.l	#'ANIM',(a4)
		bne.w	notiff1
		bsr.w	readbyte
		cmp.l	#'FORM',(a4)
		bne.w	notiff1
		bsr.w	readbyte
		move.l	(a4),size(a5)
		add.l	#12,size(a5)

.li
	;---- Allociere Puffer für File ----
	
		move.l	size(a5),d0
		sub.l	#12,d0	       ;FORM und ILBM wurden ja schon gelesen
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4,a6
		jsr	_LVOAllocmem(a6)
		move.l	d0,puffermem(a5)
		bne.b	.memok

		lea	notmemmsg(pc),a4
		bsr.w	status
		moveq	#-1,d3
		rts
.memok
	;--- Lade IFF File ganz ein ---;
	
		move.l	filehandle(a5),d1
		move.l	puffermem(a5),d2
		move.l	size(a5),d3
		sub.l	#12,d3
		move.l	dosbase(a5),a6
		jsr	_LVORead(a6)
		tst.l	d0
		bne.b	.readok
		lea	loaderrormsg(pc),a4
		bsr.w	status
		moveq	#-1,d7
		bra.w	failiff

.readok:
	;--- Werte IFF-File aus -------
	
		bsr.l	openprocess

		move.l	puffermem(a5),a0
		move.l	#'BMHD',d0
		bsr.w	searchchunk
		tst.l	d0
		beq.w	failiff
		bsr.w	initpicdata
		
		cmp.b	#24,planes(a5)
		beq.b	.iff24

		moveq	#0,d0
		move.w	hoehe(a5),d0
		subq.w	#1,d0
		lea	iffmsg(pc),a1
		bsr.l	initprocess

		move.l	puffermem(a5),a0
		move.l	#'CAMG',d0
		bsr.w	searchchunk
		tst.l	d0
		bne.s	.camgok
		bsr.w	makeresolution	;bestimme auflösung ohne CAMG-Chunk
		bra.b	.nchk
.camgok:	bsr.w	hamehb

.nchk:		move.l	puffermem(a5),a0
		move.l	#'CMAP',d0
		bsr.w	searchchunk
		tst.l	d0
		beq.w	failiff
		bsr.w	colortab

.iff24:
		move.l	puffermem(a5),a0
		move.l	#'BODY',d0
		bsr.w	searchchunk
		tst.l	d0
		beq.w	failiff
		move.l	a0,loadbody(a5)
		bsr.w	loadpic
		
		move.l	puffermem(a5),a1
		move.l	size(a5),d0
		sub.l	#12,d0
		move.l	4,a6
		jsr	_LVOFreeMem(a6)
		
		cmp.l	#APLE_ABORT,d3
		beq.b	.w
		cmp.l	#-1,d3
		bne.b	initdatas
.w		rts
		
keyfault1:
		move.l	execbasepuffer(a5),a0
		move.l	mainwinWnd(a5),(a0)
		rts

;---------------------------------------------------------------------------
;--- Init Screenmode -------------------------------------------------------
;---------------------------------------------------------------------------
initdatas:
		cmp.b	#24,planes(a5)
		bne.b	.no24
		moveq	#0,d3
		rts

.no24:
;		move.b	planes(a5),d0
;		muls	#$1000,d0
		moveq	#0,d0
		move.l	viewmode(a5),d1
;		btst	#7,d1		;EHB ?
;		bne.b	.wei
;		and.w	#$fbff,d0	;Ja
;.wei:
		clr.b	ham(a5)
		clr.b	ham8(a5)
		move.l	d1,d2
		and.w	#$800,d2
		beq.b	noham1
		or.w	#$800,d0
		bra.b	setham
noham1:
		cmp.b	#6,planes(a5)	;Testen falls kein CAMG Chunk
		bne.b	checkham8
		cmp.w	#16,anzcolor(a5)
		bne.b	checkham8
		or.w	#$800,d0
		move.b	#1,ham(a5)
		bra.b	noham
checkham8:
		cmp.b	#8,planes(a5)
		bne.b	noham
		cmp.w	#64,anzcolor(a5)
		bne.b	noham
		or.w	#$800,d0
		move.b	#1,ham8(a5)
		bra.b	noham

setham:		moveq	#0,d3
		move.b	planes(a5),d3
		cmp.b	#8,d3
		beq.b	.ham8
		move.b	#1,ham(a5)
		bra.b	noham
.ham8:
		move.b	#1,ham8(a5)
noham:
;		or.w	#$200,d0	;Colorbit		
		clr.b	hires(a5)
		move.w	#320,displaywidth(a5)
		move.l	d1,d2
		and.l	#$8000,d2
		beq.b	nohires
		or.w	#$8000,d0
		move.b	#1,hires(a5)
		move.w	#640,displaywidth(a5)
		bra.b	noshires
nohires:					
		clr.b	superhires(a5)
		move.l	d1,d2
		and.l	#$8020,d2
		cmp.w	#$8020,d2
		bne.b	noshires
		or.w	#$8020,d0
		move.b	#1,superhires(a5)
		move.w	#1280,displaywidth(a5)
noshires:
		clr.b	lace(a5)
		move.w	#256,displayheight(a5)
		move.l	d1,d2
		and.l	#$4,d2
		beq.b	nolace
		or	#$4,d0
		move.b	#1,lace(a5)
		move.w	#512,displayheight(a5)
nolace:
		clr.b	ehb(a5)
		move.l	d1,d2
		and.l	#$80,d2
		cmp.w	#$80,d2
		bne.b	initmode
		or.w	#$80,d0
		move.b	#1,ehb(a5)
initmode:
		swap	d1
		tst.w	d1
		bne.b	.modeok
		or.l	#$21000,d0	;Stelle Pal ein
		move.l	d0,d1
		bra.b	.goon
.modeok:
		swap	d1
.goon:
		tst.b	lockcheck(a5)
		beq.b	.nolock
		tst.b	firstmode(a5)
		bne.b	.we
.nolock:
		and.l	#$fffff77f,d1
		move.l	d1,DisplayID(a5)
		bsr.w	setmodi

		st	firstmode(a5)

.we		moveq	#0,d3
		rts
notiff:
notiff1:
	;	lea	notaiffmsg(pc),a4
	;	bsr.w	status
	;	move.l	#-1,d3
		move.l	#APLE_UNKNOWN,d3
		rts
;------------------------------------------------------------------------
readbyte:
		move.l	filehandle(a5),d1
		lea	bytepuffer,a0
		exg	a0,d2
		moveq	#4,d3
		move.l	dosbase(a5),a6
		jmp	_LVOread(a6)
failiff:
		cmp.l	#-1,d7
		beq.b	noinvalid	;Fehler beim lesen
		lea	invalidiffmsg(pc),a4
		bsr.w	status
noinvalid:					
		move.l	puffermem(a5),a1
		move.l	size(a5),d0
		sub.l	#12,d0
		move.l	4,a6
		jsr	_LVOFreeMem(a6)
		moveq	#-1,d3
		rts

searchChunk:
		moveq	#0,d1
		move.l	size(a5),d3
.nb:		move.l	(a0),d2
		cmp.l	d0,d2
		beq.b	found
		addq.l	#2,a0
		addq.l	#2,d1
		cmp.l	d1,d3
		bhs.b	.nb
		moveq	#0,d0
found:
		addq.l	#8,a0	;Chunkkennung und Länge überlesen
		rts

	;-------- Lese Bilddaten aus Bitmapheader -----
initpicdata:
		move.w	(a0),breite(a5)
		move.w	2(a0),hoehe(a5)

		move.b	8(a0),planes(a5)
		move.b	9(a0),testbyte(a5)
		move.b	10(a0),crunchmode(a5)		

		move.w	12(a0),transcolor(a5)
		move.w	14(a0),verhaeltnis(a5)

		move.w	16(a0),xresolution(a5)	;Bildauflösung
		move.w	18(a0),yresolution(a5)

		rts
checkkey2:
;		move.l	lastreq(a5),a0
;		lea	-112(a0),a0
;		move.w	#$662a,4(a0)
;		move.w	#$6718,16(a0)
		tst.b	keyfound(a5)
		beq.b	.wech
		lea	name(a5),a1
		move.l	keypuffermerk(a5),a0
		move.l	decodier1rout(a5),a6
		jsr	-346(a6)
		add.b	#21,d3
		move.b	d3,check2(a5)
		lea	vorname(a5),a1
		jsr	-346(a6)
		add.b	#78,d3
		move.b	d3,check3(a5)

		move.l	#16-1,d7
		moveq	#0,d0
.pc1:		add.b	(a0)+,d0
		dbra	d7,.pc1

		lea	name(a5),a1
		move.l	decodier2rout(a5),a6
		jsr	-420(a6)
		move.b	d0,check4(a5)
		
		lea	strasse(a5),a1
		move.l	decodier1rout(a5),a6
		jsr	-346(a6)

		lea	vorname(a5),a1
		move.l	decodier2rout(a5),a6
		jsr	-420(a6)
		move.b	d0,check5(a5)

		lea	strasse(a5),a1
		jsr	-420(a6)
		move.b	d0,check6(a5)
		move.l	a0,keypuffermerk(a5)
.wech		rts

;---------------------------------------------------------------------------
;--- Read the colortab -----------------------------------------------------
;---------------------------------------------------------------------------
colortab:
		move.l	-4(a0),d3
		moveq	#0,d3
		move.b	planes(a5),d3
		moveq	#1,d7
		lsl.l	d3,d7
;		move.l	d3,d7
;		divs	#3,d7

		cmp.b	#6,planes(a5)
		bne.b	.nohamtest
		move.l	viewmode(a5),d0
		and.l	#$800,d0
		cmp.w	#$800,d0
		bne.b	.nohamtest
		moveq	#16,d7
		bra.b	.go
.nohamtest:	cmp.b	#8,planes(a5)
		bne.b	.go
		move.l	viewmode(a5),d0
		and.l	#$800,d0
		cmp.w	#$800,d0
		bne.b	.go
		moveq	#64,d7

.go:		move.w	d7,anzcolor(a5)
		subq.w	#1,d7

		move.l	viewmode(a5),d0		;EHB ?
		and.l	#$80,d0
		cmp.w	#$80,d0
		bne.b	.noehb
		move.w	#32,anzcolor(a5)
		moveq	#31,d7
.noehb:
		cmp.w	#31,d7
		bhi.b	agacol	;Mehr als 32 Farben
		tst.b	kick3(a5)
		bne.b	agacol

		lea	farbtab4(a5),a1
		lea	farbtab8(a5),a2

		moveq	#0,d0
		move.w	d7,d0
		addq.l	#1,d0
		move.w	d0,(a2)+
		move.w	#0,(a2)+
nextcol:
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.b	(a0)+,d1
		move.b	d1,d2
		lsr.w	#4,d2
		mulu	#255,d2
		divu	#15,d2
		lsl.l	#8,d2
		swap	d2
		move.l	d2,(a2)+
		lsl.w	#4,d1
		move.b	(a0)+,d1		
		moveq	#0,d2
		move.b	d1,d2
		lsr.w	#4,d2
		mulu	#255,d2
		divu	#15,d2
		lsl.l	#8,d2
		swap	d2
		move.l	d2,(a2)+
		move.b	(a0)+,d0
		moveq	#0,d2
		move.b	d0,d2
		lsr.w	#4,d2
		mulu	#255,d2
		divu	#15,d2
		lsl.l	#8,d2
		swap	d2
		move.l	d2,(a2)+
		lsr.w	#4,d0
		and.w	#$fff0,d1
		or.w	d0,d1
		move.w	d1,(a1)+
		dbra	d7,nextcol
		clr.b	colortype(a5)
		rts

agacol:
		lea	farbtab8(a5),a1
		lea	farbtab4(a5),a2
		moveq	#0,d0
		move.w	d7,d0
		addq.l	#1,d0
		move.w	d0,(a1)+
		move.w	#0,(a1)+
ncolor:		
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.b	(a0)+,d0
		move.b	d0,d1
		lsl.w	#4,d1
		lsl.l	#8,d0
		swap	d0
		move.l	d0,(a1)+
		moveq	#0,d0
		move.b	(a0)+,d0
		move.b	d0,d1
		lsl.l	#8,d0
		swap	d0
		move.l	d0,(a1)+
		moveq	#0,d0
		move.b	(a0)+,d0
		move.b	d0,d2
		lsr.w	#4,d2
		and.w	#$fff0,d1
		or.w	d2,d1
		lsl.l	#8,d0
		swap	d0
		move.l	d0,(a1)+
		move.w	d1,(a2)+
		dbra	d7,ncolor
		move.l	#0,(a1)
		move.b	#2,colortype(a5)
		rts
		
;---------------------------------------------------------------------------
;--- werte CAMG Chunk aus --------------------------------------------------
;---------------------------------------------------------------------------
hamehb:
		move.l	(a0),viewmode(a5)		
		rts
makeresolution:
		moveq	#0,d0
		cmp.w	#320,xresolution(a5)
		bls.b	xok
		or.w	#$8000,d0	;Hires einstellen
xok:
		cmp.w	#256,yresolution(a5)
		bls.b	yok
		or.w	#4,d0
yok:		move.l	d0,viewmode(a5)
		rts		

;---------------------------------------------------------------------------
;--- BODY-Chunk einlesen (das ganze bild einlesen) -------------------------
;---------------------------------------------------------------------------
loadpic:
		move.w	hoehe(a5),d1
		moveq	#0,d0

		move.w	breite(a5),d0
		move.l	d0,d5
		lsr.l	#3,d0		;Breite in Byte
		move.l	d0,d6
		lsl.l	#3,d6
		cmp.w	d6,d5
		beq.b	noadd
		addq.w	#1,d0
noadd:
		move.w	d0,d3		;Testen ob noch ein zweites
		lsr.w	#1,d3		;Byte addiert werden muß
		lsl.w	#1,d3		;Breite muß gerade sein
		cmp.w	d0,d3
		beq.b	noadd1
		addq.w	#1,d0

noadd1:
		move.l	d0,bytebreite(a5)
allmem:				
		mulu	d1,d0
;		lsr.l	#3,d0
		moveq	#0,d3
		move.l	d0,oneplanesize(a5)

		cmp.b	#24,planes(a5)
		beq.w	loadiff24

		move.b	planes(a5),d3
		cmp.b	#1,testbyte(a5)	;Teste ob maskierungsplane
		bne.b	.nomask		;vorhanden ist
		addq.b	#1,d3
.nomask:
;		sub.w	#1,d3
;		move.l	d0,d1
;		moveq	#0,d0
;.nplane:	add.l	d1,d0		;Simuliert Mulu.l Befehl
;		dbra	d3,.nplane

		mulu.l	d3,d0

		move.l	d0,memsize(a5)
	;	move.l	#$10002,d1
		move.l	#MEMF_CLEAR+MEMF_ANY,d1
		move.l	4,a6
		jsr	_LVOallocVec(a6)
		move.l	d0,picmem(a5)			
		bne.b	loadbodychunk		;Speicher für BODY allociert

		lea	notmemmsg(pc),a4	;nicht genug Speicher
		bsr.w	status
		clr.w	loadflag(a5)
		moveq	#-1,d3
		rts

;---------------------------------------------------------------------------
;--- Load Crunched Picdaten ------------------------------------------------
;---------------------------------------------------------------------------
loadbodychunk:
;-------------------------------------------------------------------------
	ifne	final
		lea	lastreqcode1(pc),a0
		move.l	(a0),a0
		cmp.l	lastreqcheck1(a5),a0
		beq.b	.codeok
		move.l	(a0),reqtbase(a5)
	endc
;--------------------------------------------------------------------------
.codeok:
		move.w	#1,loadflag(a5)
		
		move.l	bytebreite(a5),d7
		moveq	#0,d0
		move.l	picmem(a5),a1
		move.l	loadbody(a5),a0		
		moveq	#0,d5
		move.w	hoehe(a5),d5
		subq.l	#1,d5
		tst.b	crunchmode(a5)
		beq.b	loadnotcrunch
newline:
		move.l	a1,a2
		moveq	#0,d6
		move.b	planes(a5),d6
		cmp.b	#1,testbyte(a5)	;Teste ob maskierungsplane
		bne.b	.nomask		;vorhanden ist
		addq.b	#1,d6
.nomask:
		subq.l	#1,d6
nextplane:		
		move.l	a2,a4
		sub.l	a3,a3
loop:
		moveq	#0,d0
		move.b	(a0)+,d0
		bmi.b	packed
copy:
		addq.w	#1,a3
		move.b	(a0)+,(a2)+
		cmp.w	a3,d7		;Pic Breite erreicht ?
		beq.b	newplane
		dbra	d0,copy
		bra.b	loop	
packed:
		neg.b	d0
		move.b	(a0)+,d1
copy1:
		addq.w	#1,a3
		move.b	d1,(a2)+
		cmp.w	a3,d7
		beq.b	newplane
		dbra	d0,copy1
		bra.b	loop
newplane:
		move.l	a4,a2
		add.l	oneplanesize(a5),a2
		dbra	d6,nextplane		

		add.l	bytebreite(a5),a1
;		add.l	bmodulo(a5),a1

		bsr.l	doprocess

		tst.l	d0
		beq.b	if_stopload

		dbra	d5,newline		

endload:
		rts

loadnotcrunch:
		subq.l	#1,d7
		move.l	d7,a4
.newline:
		move.l	a1,a3
		moveq	#0,d6
		move.b	planes(a5),d6
		cmp.b	#1,testbyte(a5)	;Teste ob maskierungsplane
		bne.b	.nomask		;vorhanden ist
		addq.b	#1,d6
.nomask:
		subq.l	#1,d6
.nextplane:
		move.l	a1,a2
		move.l	a4,d7
.nextbyte:
		move.b	(a0)+,(a1)+
		dbra	d7,.nextbyte

		move.l	a2,a1
		add.l	oneplanesize(a5),a1
		dbra	d6,.nextplane		
		move.l	a3,a1
		add.l	bytebreite(a5),a1
;		add.l	bmodulo(a5),a1

		bsr.l	doprocess

		tst.l	d0
		beq.b	if_stopload

		dbra	d5,.newline		

		rts

if_stopload:
		move.l	APG_Picmem(a5),d0
		beq.b	.w
		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
		clr.l	APG_Picmem(a5)
.w		moveq	#APLE_ABORT,d3
		rts

;------------------------------------------------------------------------
;------ Lade ein IFF24 Image
;------------------------------------------------------------------------
loadiff24:

;Alloc Speicher für RGB Image

		moveq	#0,d0
		move.w	hoehe(a5),d0
		subq.w	#1,d0
		lea	iff24msg(pc),a1
		bsr.l	initprocess

		move.l	bytebreite(a5),d0
		lsl.l	#3,d0
		mulu.w	hoehe(a5),d0
		move.l	d0,d7		;Chunky8 größe
		move.l	d0,rndr_chunky8size(a5)
		mulu.l	#4,d0
		move.l	d0,rndr_rgbsize(a5)
		add.l	d0,d7
	;	add.l	#rndr_buffersize,d7
		move.l	d7,d0
	;	add.l	#rndr_workpuffer,d0
		
		move.l	4.w,a6
		move.l	#MEMF_ANY+MEMF_CLEAR,d1		
		jsr	_LVOAllocVec(a6)
		tst.l	d0
		bne.b	.memok
		
		bsr.l	clearprocess
		
		move.l	puffermem(a5),d0
		beq.b	.w
		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
.w	lea	notmemmsg(pc),a4
		bra.w	status

.memok
		move.l	d0,rndr_rendermem(a5)
		move.l	d0,d1

	;	add.l	#rndr_buffersize,d0
		move.l	d0,rndr_chunky(a5)
		add.l	rndr_chunky8size(a5),d0
		move.l	d0,rndr_rgb(a5)		;RGB Mem
		move.l	d0,APG_Free1(a5)

		move.l	d1,APG_Free2(a5)	;Bitmap Zeile
		move.l	bytebreite(a5),d0
		move.l	d0,d2
		mulu	#8,d0
		add.l	d0,d1
		move.l	d1,APG_Free3(a5)	;Chunky Zeile für Rot
		lsl.l	#3,d2
		add.l	d2,d1
		move.l	d1,APG_Free4(a5)	;Chunky Zeile für Grün
		add.l	d2,d1
		move.l	d1,APG_Free5(a5)	;Chunky Zeile für Blau
		
;Init PlaneTab für Bpl2Chunky

		lea	rndr_planetab,a0
		move.l	APG_Free2(a5),d0
		moveq	#8-1,d7
.npl:		move.l	d0,(a0)+
		add.l	bytebreite(a5),d0
		dbra	d7,.npl


		move.l	bytebreite(a5),a3
		move.l	loadbody(a5),a0		
		moveq	#0,d5
		move.w	hoehe(a5),d5
		subq.l	#1,d5
		tst.b	crunchmode(a5)
		beq.b	iff24_loadnotcrunch

iff24_newline:
		move.l	APG_Free3(a5),APG_Free6(a5)

		moveq	#3-1,d4
iff24_newcolor:
		move.l	APG_Free2(a5),a1
		moveq	#8-1,d6
iff24_nextplane:
		moveq	#0,d7
iff24_loop:	moveq	#0,d0
		move.b	(a0)+,d0
		bmi.b	iff24_packed
iff24_copy:
		addq.w	#1,d7
		move.b	(a0)+,(a1)+
		cmp.w	d7,a3	;Pic Breite erreicht ?
		beq.b	iff24_newplane
		dbra	d0,iff24_copy
		bra.b	iff24_loop	
iff24_packed:
		neg.b	d0
		move.b	(a0)+,d1
iff24_copy1:
		addq.w	#1,d7
		move.b	d1,(a1)+
		cmp.w	d7,a3
		beq.b	iff24_newplane
		dbra	d0,iff24_copy1
		bra.b	iff24_loop
iff24_newplane:
		dbra	d6,iff24_nextplane		

		bsr.b	iff24_maechchunkys

		dbra	d4,iff24_newcolor

		bsr.w	iff24_maechrgbs

		dbra	d5,iff24_newline		


IFF24_End:
		move.w	#1,loadflag(a5)

		move.b	#24,planes(a5)
		bsr.w	findmonitor
		
		move.b	#24,planes(a5)

		st	depthchange(a5)

	;	bsr.l	clearprocess

		rts


iff24_loadnotcrunch:

iff24_newline1:
		move.l	APG_Free3(a5),APG_Free6(a5)

		moveq	#3-1,d4
iff24_newcolor1:
		move.l	APG_Free2(a5),a1
		moveq	#8-1,d6
iff24_nextplane1:
		move.l	a3,d7
		subq.w	#1,d7
iff24_loop1:	moveq	#0,d0
		move.b	(a0)+,(a1)+
		dbra	d7,IFF24_loop1

iff24_newplane1:
		dbra	d6,iff24_nextplane1

		bsr.b	iff24_maechchunkys

		dbra	d4,iff24_newcolor1

		bsr.b	iff24_maechrgbs

		dbra	d5,iff24_newline1

		bra.b	IFF24_End


iff24_maechchunkys:
		movem.l	d0-a6,-(a7)
		lea	rndr_planetab,a0
		move.l	APG_Free6(a5),a1
		move.l	APG_ByteWidth(a5),d0
		move.l	d0,d5
		lsl.l	#3,d5
		add.l	d5,APG_Free6(a5)
		moveq	#1,d1			;Höhe
		moveq	#8,d2			;Depth
		move.l	d0,d3
		move.l	renderbase(a5),a6		
		sub.l	a2,a2
		jsr	_LVOPlanar2Chunky(a6)
		movem.l	(a7)+,d0-a6
		rts

iff24_maechrgbs:
		movem.l	d0-a6,-(a7)
		move.l	APG_Free3(a5),a0
		move.l	APG_Free4(a5),a1
		move.l	APG_Free5(a5),a2
		move.l	APG_Free1(a5),a3	;RGB Mem

		move.l	bytebreite(a5),d7
		lsl.l	#3,d7
		subq.w	#1,d7

.nc:		moveq	#0,d0
		move.b	(a0)+,d0	;R
		move.b	(a1)+,d1	;G
		move.b	(a2)+,d2	;B
		
		bfins	d1,d2{16:8}
		bfins	d0,d2{8:8}

		move.l	d2,(a3)+

		dbra	d7,.nc

		move.l	a3,APG_Free1(a5)

		movem.l	(a7)+,d0-a6

		bsr.l	doprocess
		tst.l	d0
		bne.b	.w

		move.l	rndr_rendermem(a5),a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
		clr.l	rndr_rendermem(a5)
		clr.l	rndr_rgb(a5)
		addq.l	#4,a7
		moveq	#APLE_ABORT,d3

.w		rts

iffmsg:		dc.b	'Loading a IFF Image',0
iff24msg:	dc.b	'Loading a IFF24 Image',0

;========================================================================
;	         *----------- Lade Screen --------------*		=
;========================================================================
loadscreen:
		clr.b	choosepub(a5)
		
		move.l	intbase(a5),a0
		move.l	ib_FirstScreen(a0),a4	;First Screen
		moveq	#1,d0
		
		move.l	a4,a1
.ns:
		move.l	(a1),a1
		cmp.l	#0,a1
		beq.b	.endscreen
		addq.l	#1,d0
		bra.b	.ns
.endscreen:
		mulu	#30,d0		;berechne puffer für ListviewStruck
		beq.b	ls_wech1	
		clr.l	listviewmem(a5)
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,Listviewmem(a5)
		beq.b	ls_wech1

;--- Fülle ListViewStruck ---

		move.l	d0,a0
	;	cmp.l	scr(a5),a4	;ist es unserer eigener Screen
	;	bne.b	.weiter
	;	move.l	(a4),a4
.weiter:
		lea	screenreqlist(pc),a1
		move.l	a1,4(a0)
		move.l	a0,(a1)		;erster node in Screenreqlist
		move.l	22(a4),d0
		bne.b	.tok
		lea	untitled(pc),a2
		move.l	a2,d0
.tok:
		move.l	d0,10(a0)	;Titeltext
		move.l	a4,14(a0)	;Screenstruck
.weiter1
		add.l	#18,a0
.w1
		move.l	(a4),a4
	;	cmp.l	scr(a5),a4
	;	beq.b	.w1
		cmp.l	#0,a4
		beq.b	.endscr1
		lea	-18(a0),a2
		move.l	a0,(a2)
		move.l	a2,4(a0)
		move.l	22(a4),d0
		bne.b	.tok1
		lea	untitled(pc),a2
		move.l	a2,d0
.tok1:
		move.l	d0,10(a0)
		move.l	a4,14(a0)
		bra.b	.weiter1
.endscr1
		lea	screenreqlist+4(pc),a1
		sub.l	#18,a0
		move.l	a1,(a0)
		move.l	a0,4(a1)	;letzter Node als letztes in reqlist
		
ls_wech1:
		tst.l	listviewmem(a5)
		beq.w	jumpwait

;--- Öffne Fenster mit der Screenliste ---
openscreenwin:
		
		clr.w	ls_screen(a5)

		lea	screenwinWindowTags(pc),a0
		move.l	a0,windowtaglist(a5)
		lea	screenwinWG+4(pc),a0
		move.l	a0,gadgets(a5)
		lea	screenwinSC+4(pc),a0
		move.l	a0,winscreen(a5)
		lea	screenwinWnd(a5),a0
		move.l	a0,window(a5)
		lea	screenwinGlist(a5),a0
		move.l	a0,Glist(a5)
		lea	screenwinNgads,a0
		move.l	a0,NGads(a5)
		lea	screenwinGTypes,a0
		move.l	a0,GTypes(a5)
		lea	screenwinGadgets,a0
		move.l	a0,WinGadgets(a5)
		move.w	#screen_CNT,win_CNT(a5)
		lea	screenwinGtags,a0
		move.l	a0,windowtags(a5)
		move.l	scr(a5),screenbase(a5)

		bsr.w	checkmainwinpos

		add.w	#screenwinLeft,d0
		add.w	#screenwinTop,d1

		move.w	d1,WinTop(a5)
		move.w	d0,WinLeft(a5)

		move.w	#screenwinWidth,WinWidth(a5)
		move.w	#screenwinHeight,WinHeight(a5)

		lea	screenWinL,a0
		move.l	a0,WinL(a5)
		lea	screenWinT,a0
		move.l	a0,WinT(a5)
		lea	screenWinW,a0
		move.l	a0,WinW(a5)
		lea	screenWinH,a0
		move.l	a0,WinH(a5)

		bsr.w	openwindowF

;		move.l	mainwinWnd(a5),a0
;		bsr.w	setwaitpointer

		clr.b	merk1(a5)
		move.l	screenwinwnd(a5),aktwin(a5)

ls_wait:	move.l	screenwinWnd(a5),a0
		jsr	wait
		
		cmp.l	#IDCMP_CLOSEWINDOW,d4
		beq.w	ls_nixgewaehlt
		cmp.l	#GADGETUP,d4
		beq.b	ls_gads
		cmp.l	#VANILLAKEY,d4
		beq.b	ls_keys
		bra.b	ls_wait		;nichts wichtiges

;Werte Gadgets im Screenwin aus

ls_gads:
		moveq	#0,d0
		move.w	38(a4),d0
		cmp.w	#GD_sCancel,d0
		beq.w	ls_nixgewaehlt
		cmp.w	#GD_screenlist,d0
		beq.b	ls_newscreen			;Listview angewählt
		cmp.w	#GD_sok,d0
		beq.w	ls_screenok

		bra.b	ls_wait

ls_keys:
		cmp.w	#'o',d5
		bne.b	.w
		lea	screenwingadgets,a0
		move.l	#GD_sok,d0
		lea	ls_screenok(pc),a3
		jmp	setandjump
.w
		cmp.w	#'c',d5
		bne.b	ls_wait
		lea	screenwingadgets,a0
		move.l	#GD_scancel,d0
		lea	ls_nixgewaehlt(pc),a3
		jmp	setandjump
		
jumpwait:
		jmp	waitaction

ls_newscreen:
		move.w	d5,ls_screen(a5)	;Sichere nummer des Screens
		move.l	d6,d7
.w
		move.l	screenwinWnd(a5),a0
		jsr	wait		;Warte auf eingabe im Choosewin
		cmp.l	#IDCMP_CLOSEWINDOW,d4
		beq.w	ls_nixgewaehlt
		cmp.l	#VANILLAKEY,d4
		beq.b	ls_keys
		cmp.l	#GADGETUP,d4
		bne.b	.w
		moveq	#0,d0
		move.w	38(a4),d0
		cmp.w	#GD_screenlist,d0
		bne.w	ls_gads
		move.w	ls_screen(a5),d0
		cmp.w	d5,d0
		bne.b	.news
		sub.l	d7,d6
		cmp.w	#1,d6
		bgt.b	.news
		bra.b	ls_screenok
.news:
		move.w	d5,ls_screen(a5)
		bra.w	ls_wait


;===========================================================================
;------------- Struckturen für Screenlist window ------

ScreenwinWindowTags:
screenwinL:	dc.l	WA_Left,200
screenwinT:	dc.l	WA_Top,70
screenwinW:	dc.l	WA_Width,320
screenwinH:	dc.l	WA_Height,110
		dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW!LISTVIEWIDCMP!IDCMP_VANILLAKEY!BUTTONIDCMP!IDCMP_CLOSEWINDOW!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_CLOSEGADGET!WFLG_DEPTHGADGET!WFLG_DRAGBAR!WFLG_ACTIVATE!WFLG_SMART_REFRESH
screenwinWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title,screentitle
		dc.l	WA_ScreenTitle,mainwinstitle  ;choosewinSTitle
screenwinSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

screentitle:
		dc.b	'Select a Screen !',0

	even
;-------------------------------------------------------------------------
cp_rts:
		move.l	#'CANC',d7
cp_rts1:	rts

ls_screenok:
		tst.b	choosepub(a5)
		bne.b	cp_rts1
		move.l	listviewmem(a5),a0

		moveq	#0,d7
		move.w	ls_screen(a5),d7

		subq.l	#1,d7
		bmi.b	ls_firstnode	;es war der erste Eintrag
.nn:		move.l	(a0),a0		;ermittle LoaderNode Adresse
		dbra	d7,.nn
ls_firstnode:
		move.l	14(a0),aktscreen(a5) 	;Aktueller Screen der geladen 
		bra.b	ls_loadit		;werden soll
		
ls_nixgewaehlt:
		bsr.w	ls_close
		tst.b	choosepub(a5)
		bne.b	cp_rts

		jmp	waitaction		

	;*--------- Versuche jetzt Screen zu Laden ----------*
ls_loadit:		
		bsr.w	ls_close

		move.l	aktscreen(a5),a0
		lea	sc_viewport(a0),a0
		move.l	a0,ScreenViewport(a5)

		moveq	#0,d0
		move.l	gfxbase(a5),a6
		jsr	_LVOGetVPModeID(a6)
		
		cmp.l	#-1,d0
		beq.w	ls_noscreen	;screen ist nicht mehr da !

		move.l	d0,screenID(a5)

		bsr.w	oldpicwech	;Altes Bild freigeben

		move.l	aktscreen(a5),a0
		move.w	sc_width(a0),breite(a5)	;Screenbreite
		move.w	sc_height(a0),hoehe(a5)

		lea	sc_rastport(a0),a0
		move.l	rp_bitmap(a0),a0
		move.l	a0,screenbitmap(a5)

		moveq	#0,d0
;		move.w	bm_bytesperrow(a0),d0
		move.w	breite(a5),d0
		add.l	#15,d0
		lsr.l	#4,d0
		add.l	d0,d0

		move.l	d0,bytebreite(a5)
		move.w	bm_rows(a0),d1
		mulu	d1,d0
		move.l	d0,oneplanesize(a5)
		moveq	#0,d1

		move.l	d0,d5
		
		move.l	#BMA_DEPTH,d1
		move.l	gfxbase(a5),a6
		jsr	_LVOGetBitmapAttr(a6)
		move.l	d0,d1
		move.b	d1,planes(a5)
	cmp.b	#8,d1
	bhi	ls_truecolor
		move.l	d5,d0
		moveq	#0,d2
		subq.b	#1,d1
.np:
		add.l	d0,d2
		dbeq	d1,.np
		move.l	d2,memsize(a5)	;MemSize für das gesammte Bild
		
		move.l	d2,d0
		move.l	#$10002,d1
		move.l	4,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,picmem(a5)
		bne.b	ls_initbitmap
		lea	notmemmsg(pc),a4	;Kein Speicher
		bsr.w	status
		jmp	waitaction

ls_initbitmap:
		move.w	#1,loadflag(a5)
		lea	picmap(a5),a0	
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.b	planes(a5),d0
		move.l	bytebreite(a5),d1
		lsl.l	#3,d1
		move.w	hoehe(a5),d2
		move.l	gfxbase(a5),a6
		jsr	_LVOinitbitmap(a6)
		
		lea	picmap+8(a5),a0
		move.l	picmem(a5),d0
		moveq	#0,d7		
		move.b	planes(a5),d7	
		subq	#1,d7
.newplane
		move.l	d0,(a0)		;Planes in Strucktur einbinden
		add.l	oneplanesize(a5),d0
		addq.l	#4,a0
 		dbra	d7,.newplane

;----------- Blitte Screen in neue Bitmap ----------------

		move.l	screenbitmap(a5),a0
		moveq	#0,d0
		moveq	#0,d1
		lea	picmap(a5),a1
		moveq	#0,d2
		moveq	#0,d3
		move.l	bytebreite(a5),d4
		lsl.l	#3,d4
		move.w	hoehe(a5),d5
		move.l	#$c0,d6
		move.l	#$ff,d7
		sub.l	a2,a2
		move.l	gfxbase(a5),a6
		jsr	_LVOBltBitMap(a6)
		
;------- Checke Colormap -----------------

		move.l	ScreenViewport(a5),a0
		move.l	4(a0),a0	;Colormap

		move.b	cm_Type(a0),d1	;ColormapTyp 0=old 0<>neu
		move.b	d1,colortype(a5)
;		move.w	cm_Count(a0),d0	;Anzcolor ?
		moveq	#0,d0
		move.b	planes(a5),d0
		moveq	#1,d1
		lsl.l	d0,d1
		move.w	d1,anzcolor(a5)
		move.l	cm_colorTable(a0),a1	;Colortable
		move.l	cm_LowColorBits(a0),a2	;Tab mit den unteren Bits

		move.w	anzcolor(a5),d7
		subq.l	#1,d7
		cmp.b	#2,colortype(a5)
		bhs.w	ls_newcolor
		lea	farbtab4(a5),a0
		lea	farbtab8(a5),a3
		move.w	anzcolor(a5),(a3)+
		move.w	#0,(a3)+
		moveq	#0,d0
.nc
		move.w	(a1)+,d0
		move.w	d0,(a0)+
		move.l	d0,d1
		and.w	#$f00,d1
		lsr.w	#8,d1
		mulu	#255,d1
		divu	#15,d1
		lsl.l	#8,d1
		swap	d1
		move.l	d1,(a3)+	
		move.l	d0,d1
		and.w	#$f0,d1
		lsr.w	#4,d1
		mulu	#255,d1
		divu	#15,d1
		lsl.l	#8,d1
		swap	d1
		move.l	d1,(a3)+
		move.l	d0,d1
		and.w	#$f,d1
		mulu	#255,d1
		divu	#15,d1
		lsl.l	#8,d1
		swap	d1
		move.l	d1,(a3)+
		dbra	d7,.nc
		clr.l	(a2)
		bra.b	testham
ls_newcolor:		
		lea	farbtab8(a5),a0
		lea	farbtab4(a5),a3
		move.w	anzcolor(a5),(a0)+	;schreibe mapheader
		move.w	#0,(a0)+
.nc:
		move.w	(a1)+,d0
		move.w	(a2)+,d1

		move.w	d0,(a3)+        ;oberen Bits einfach in 4 Bit Colortab
		
		moveq	#0,d2
		moveq	#0,d3
		move.w	d0,d2
		and.w	#$f00,d2
		lsl.w	#4,d2
		move.w	d1,d3
		and.w	#$f00,d3
		or.w	d3,d2
		swap	d2
		move.l	d2,(a0)+	;Rot

		moveq	#0,d2
		moveq	#0,d3
		move.w	d0,d2
		and.w	#$f0,d2
		move.w	d1,d3
		and.w	#$f0,d3
		lsr.w	#4,d3
		or.w	d3,d2
		lsl.w	#8,d2
		swap	d2
		move.l	d2,(a0)+	;grün		

		moveq	#0,d2
		moveq	#0,d3
		move.w	d0,d2
		and.w	#$f,d2
		lsl.w	#4,d2
		move.w	d1,d3
		and.w	#$f,d3
		or.w	d3,d2
		lsl.w	#8,d2
		swap	d2
		move.l	d2,(a0)+	;blau
		dbra	d7,.nc			
		clr.l	(a0)
testham:
		clr.b	ham(a5)
		clr.b	ham8(a5)
		move.l	screenID(a5),d0
		and.l	#$800,d0
		beq.b	ls_noham
		cmp.w	#16,anzcolor(a5)
		bne.b	.ham8
		move.b	#1,ham(a5)
		bra.b	ls_noham
.ham8
		move.b	#1,ham8(a5)
ls_noham:
		jsr	setpicsizegads

		tst.b	lockcheck(a5)
		beq.b	.nolock
		tst.b	firstmode(a5)
		bne.b	.we
.nolock:
		move.l	screenID(a5),DisplayID(a5)
		bsr.w	setmodi

		st	firstmode(a5)
.we
		lea	screenloadedmsg(pc),a4
		bsr.w	status

		bsr.l	makepreview
		jsr	APR_Save2TMP(a5)

		jmp	waitaction
ls_noscreen:
		lea	screennotmsg(pc),a4
		bsr.w	status
		jmp	waitaction

;lade trucolorscreen
ls_truecolor:
		tst.l	apg_rndr_rendermem(a5)
		beq	.mok
		move.l	apg_rndr_rendermem(a5),a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
		clr.l	apg_rndr_rendermem(a5)
.mok:
		move.l	apg_bytewidth(a5),d0
		move.w	apg_imageheight(a5),d1
		jsr	apr_initrendermem(a5)
		tst.l	d0
		beq	ls_noscreen
		
		move.l	guigfxbase(a5),a6
		move.l	aktscreen(a5),a1
		lea	sc_rastport(a1),a0
		move.l	ScreenViewport(a5),a1
		move.l	4(a1),a1		;Colormap
		moveq	#0,d0
		moveq	#0,d1
		move.w	breite(a5),d2
		move.w	hoehe(a5),d3
		sub.l	a2,a2
		move.l	guigfxbase(a5),a6
		jsr	_LVOReadPictureA(a6)
		tst.l	d0
		beq	ls_noscreen
		move.l	d0,d4			;picture merken

		move.l	d4,a0
		move.l	#TAG_DONE,-(a7)
		move.l	#ls_pointer,-(a7)
		move.l	#PICATTR_RawData,-(a7)
		move.l	a7,a1
		jsr	_LVOGetPictureAttrsA(a6)
		lea	3*4(a7),a7

		move.l	ls_pointer(pc),a0

		move.l	apg_rndr_rgb(a5),a1

		move.l	bytebreite(a5),d5
		lsl.l	#3,d5
		sub.w	breite(a5),d5
		lsl.w	#2,d5		;modulo

		move.w	hoehe(a5),d6
		subq.w	#1,d6
.nl
		move.w	breite(a5),d7
		subq.w	#1,d7
.nb:		move.l	(a0)+,(a1)+
		dbra	d7,.nb
		add.l	d5,a1
		dbra	d6,.nl	

		move.l	d4,a0
		jsr	_LVODeletePicture(a6)				

		move.b	#24,apg_planes(a5)
		move.w	#1,loadflag(a5)

		bra	ls_noham
		
ls_pointer:	ds.l	0

;-----------------------------------------------------------------------
checkkey3:
		tst.b	keyfound(a5)
		beq.w	.we
		move.l	keypuffermerk(a5),a0
		lea	plz(a5),a1
		move.l	decodier1rout(a5),a6
		jsr	-346(a6)
		add.b	#56,d3
		move.b	d3,check7(a5)
		lea	ort(a5),a1
		jsr	-346(a6)
		add.b	#54,d3
		add.b	d3,check7(a5)

		lea	ort(a5),a1
		move.l	decodier2rout(a5),a6
		jsr	-420(a6)
		move.b	d0,merk1(a5)

		lea	plz(a5),a1
		jsr	-420(a6)
		add.b	d0,merk1(a5)

		lea	staat(a5),a1
		move.l	decodier1rout(a5),a6
		jsr	-346(a6)
		add.b	#10,d3
		add.b	d3,merk(a5)

		moveq	#34-1,d7
		moveq	#0,d1
.nc		add.b	(a0)+,d0
		mulu	#10,d0
		add.l	d0,d1
		dbra	d7,.nc

		move.l	decodier2rout(a5),a6
		lea	staat(a5),a1
		jsr	-420(a6)
		add.b	d0,merk2(a5)

		lea	telefon(a5),a1
		move.l	decodier1rout(a5),a6
		jsr	-346(a6)

		lea	regdat(a5),a1
		jsr	-346(a6)

		lea	keypuffer+8,a1
		move.l	(a1),d2
		move.b	(a0)+,-(sp)
		move.b	(a0)+,-(sp)
		move.b	(a0)+,-(sp)
		move.b	(a0)+,-(sp)
		move.b	(sp)+,d0
		rol.l	#8,d0
		move.b	(sp)+,d0
		rol.l	#8,d0
		move.b	(sp)+,d0
		rol.l	#8,d0
		move.b	(sp)+,d0
		ror.l	#6,d0
		eor.l	d2,d0		
		sub.w	usernummer(a5),d0
		bne.w	keyfault1
		move.b	#79,check8(a5)
.we
		moveq	#0,d0
		move.b	check7(a5),d0
		add.w	d0,finalcheck(a5)
		move.b	check8(a5),d0
		add.w	d0,finalcheck(a5)
		rts

;-----------------------------------------------------------------------
ls_close:
		lea	screenwinWnd(a5),a0
		move.l	a0,window(a5)
		lea	screenwinGlist(a5),a0
		move.l	a0,Glist(a5)

		move.l	mainwinWnd(a5),a0
		bsr.w	clearwaitpointer

		bsr.w	gt_CloseWindow

		move.l	listviewmem(a5),a1
		move.l	4,a6
		jmp	_LVOFreeVec(a6)

checkkey1:
		tst.b	keyfound(a5)
		beq.b	.wech
		lea	keypuffer+4,a3
		move.l	(a3)+,d0
		move.l	a3,keypuffermerk(a5)
		eor.l	#$07fe01a0,d0
		ror.l	#6,d0
		swap	d0
		eor.w	#$afaf,d0
		move.w	d0,usernummer(a5)
		swap	d0

		move.l	keylen(a5),d7
		sub.l	#8+1,d7
		moveq	#0,d1
		moveq	#0,d2
.n		add.b	(a3)+,d2
		add.w	d2,d1
		dbra	d7,.n
		cmp.w	d0,d1
		beq.b	.w
		bra.w	keyfault
.w		move.b	#14,check1(a5)
.wech		rts

screenreqlist:
		dc.l	0,0,0

untitled:	dc.b	'Untitled Screen',0

TagItemListe	dc.l	$80000000+7		;MultiSelect
rt_screen:	dc.l	0			;Pointer ????
		dc.l	_rt_window
rt_window:	dc.l	0
	;	dc.l	RT_REQPOS
	;	dc.l	2			;Centriert
		dc.l	$80000000+40		;FileRequest-Flags
		dc.l	$1			;Select Dirs
	dc.l	RT_LOckWindow,1
		dc.l	0			;No Next Tag-Item
		dc.l	0


;-----------------------------------------------------------------------
;---- Versuche über ein DataType zu laden ----------------
;-----------------------------------------------------------------------
loaddatatype:
		lea	usingdatamsg(pc),a4
		bsr.w	status
		
		clr.b	usedatatype(a5)
		lea	loadname(a5),a0
		move.l	a0,d0
		lea	dt_tags(pc),a0
		move.l	dtbase(a5),a6
		jsr	_LVONewDTObjectA(a6)
		move.l	d0,DTObject(a5)
		beq.w	dt_checkerror

		move.l	DTObject(a5),a0
		lea	dt_attr(pc),a2
		move.l	dtbase(a5),a6
		jsr	_LVOGetDTAttrsA(a6)	;hole Attribute

		move.l	dt_bitmapheader(pc),a0
		move.b	bmh_depth(a0),d0
		cmp.b	#24,d0
		bhs	dt_load24bit		;24 Bit  Bitmap

		move.l	DTObject(a5),a0
		sub.l	a1,a1
		sub.l	a2,a2
		lea	dt_method(pc),a3
		jsr	_LVODoDTMethodA(a6)

		move.l	DTObject(a5),a0
		lea	dt_attr(pc),a2
		move.l	dtbase(a5),a6
		jsr	_LVOGetDTAttrsA(a6)	;hole Attribute
		

		st	usedatatype(a5)
		move.w	#1,loadflag(a5)

;check Daten vom Pic

		moveq	#2,d1
		move.l	dosbase(a5),a6
		jsr	_LVODelay(a6)

		move.l	dt_bitmap(pc),a0
		cmp.l	#0,a0

		move.l	dt_cregs(pc),d0

	;	move.l	dt_frame(pc),a0
		move.l	dt_bitmapheader(pc),a0

		move.w	bmh_Width(a0),d0
		move.w	d0,breite(a5)
		move.w	bmh_Height(a0),d0
		move.w	d0,hoehe(a5)
		move.b	bmh_depth(a0),d0

		move.b	d0,planes(a5)

		move.l	dt_mode(pc),d0
		move.l	d0,d1
		swap	d0
		tst.w	d0
		bne.b	.ok
		or.l	#$00021000,d1
.ok:
		move.l	d1,screenID(a5)

		moveq	#0,d0
		move.w	breite(a5),d0
		add.l	#15,d0
		lsr.l	#4,d0
		add.l	d0,d0
		move.l	d0,bytebreite(a5)

		move.l	dt_bitmap(pc),a0
		move.w	bm_rows(a0),d1
		mulu	d1,d0
		move.l	d0,oneplanesize(a5)
		moveq	#0,d1
		move.b	bm_depth(a0),d1
		moveq	#0,d2
		subq.b	#1,d1
.np:
		add.l	d0,d2
		dbeq	d1,.np
		move.l	d2,memsize(a5)	;MemSize für das gesammte Bild

		move.l	d2,d0
		move.l	#$10002,d1

		tst.l	cyberbase(a5)
		beq	.w
		move.l	d2,d5
		move.l	mainwinWnd(a5),a0
		move.l	intbase(a5),a6
		jsr	_LVOViewPortAddress(a6)
		move.l	d0,a0		;Viewport des ViewScreens
		move.l	gfxbase(a5),a6
		jsr	_LVOGetVPModeID(a6) ;hole DisplayID vom ViewScreen
		move.l	cyberbase(a5),a6
		jsr	_LVOIsCyberModeID(a6)
		tst.l	d0
		bne	.iscyber
		move.l	#$10002,d1
		bra	.we
.iscyber:	move.l	#MEMF_ANY!MEMF_CLEAR,d1
.we:		move.l	d5,d0
.w:
		move.l	4,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,picmem(a5)
		beq.w	dt_nomem

		lea	picmap(a5),a0
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.b	planes(a5),d0
		move.w	breite(a5),d1
		move.w	hoehe(a5),d2
		move.l	gfxbase(a5),a6
		jsr	_LVOInitBitmap(a6)
			
		moveq	#0,d7
		move.b	planes(a5),d7
		subq.w	#1,d7
		lea	picmap(a5),a0
		lea	bm_planes(a0),a0
		move.l	picmem(a5),d0
.np1:		move.l	d0,(a0)+
		add.l	oneplanesize(a5),d0
		dbra	d7,.np1

		move.l	dt_bitmap(pc),a0
		moveq	#0,d0
		moveq	#0,d1
		lea	picmap(a5),a1
		moveq	#0,d2
		moveq	#0,d3
		move.l	bytebreite(a5),d4
		lsl.l	#3,d4
		move.w	hoehe(a5),d5
		move.l	#$c0,d6
		move.l	#$ff,d7
		sub.l	a2,a2
		move.l	gfxbase(a5),a6
		jsr	_LVOBltBitMap(a6)

	;	move.l	bm_planes(a0),d0
	;	move.l	d0,picmem(a5)

;--- Checke ColorMap

;		move.b	planes(a5),d3
;		moveq	#1,d7
;		lsl.l	d3,d7

		move.l	dt_numcolor(pc),d7

		clr.b	ham(a5)
		clr.b	ham8(a5)
		clr.b	ehb(a5)
		
		cmp.b	#6,planes(a5)
		bne.b	.nohamtest
		move.l	screenID(a5),d0
		and.l	#$800,d0
		cmp.w	#$800,d0
		bne.b	.nohamtest
		moveq	#16,d7
		st	ham(a5)
		bra.b	.go
.nohamtest:	cmp.b	#8,planes(a5)
		bne.b	.go
		move.l	screenID(a5),d0
		and.l	#$800,d0
		cmp.w	#$800,d0
		bne.b	.go
		moveq	#64,d7
		st	HAM8(a5)
.go:		move.w	d7,anzcolor(a5)
		subq.w	#1,d7

		move.l	screenID(a5),d0		;EHB ?
		and.l	#$80,d0
		cmp.w	#$80,d0
		bne.b	.noehb
		move.w	#32,anzcolor(a5)
		moveq	#31,d7
		st	ehb(a5)
.noehb:
		move.l	dt_cregs(pc),a0

	;	move.l	dt_frame(pc),a0
	;	move.l	fri_ColorMap(a0),a0
		lea	farbtab4(a5),a1
		lea	farbtab8(a5),a2

		move.w	anzcolor(a5),(a2)+
		clr.w	(a2)+

.nc:		move.l	(a0)+,d0
		move.l	d0,d1
		and.l	#$ff000000,d0
		move.l	d0,(a2)+
		and.l	#$0000f000,d1
		lsr.l	#4,d1
		move.l	(a0)+,d0
		move.l	d0,d2
		and.l	#$ff000000,d2
		move.l	d2,(a2)+
		and.l	#$000000f0,d0
		move.b	d0,d1
		move.l	(a0)+,d0
		move.l	d0,d2
		and.l	#$ff000000,d2
		move.l	d2,(a2)+
		and.l	#$000000f0,d0
		lsr.l	#4,d0
		or.b	d0,d1
		move.w	d1,(a1)+
		dbra	d7,.nc

		clr.l	(a2)	;ende der Colorlist

		bsr.b	dt_clearobject
		
	;	move.l	screenID(a5),displayID(a5)		


dt_ende
		jsr	setpicsizegads

		tst.b	lockcheck(a5)
		beq.b	.nolock
		tst.b	firstmode(a5)
		bne.b	.we
.nolock:
		move.l	screenID(a5),DisplayID(a5)
		bsr.l	setmodi

		st	firstmode(a5)
.we
		lea	datatypeloadedmsg(pc),a4
		bsr.w	status

		moveq	#-2,d3
		rts

dt_clearobject:
		move.l	DTObject(a5),a1
		cmp.l	#0,a1
		beq.b	.nod
		move.l	mainwinWnD(a5),a0
		move.l	dtbase(a5),a6
;		jsr	_LVORemoveDTObject(a6)

		move.l	DTObject(a5),a0
		move.l	dtbase(a5),a6
		jsr	_LVODisposeDTObject(a6)
.nod		rts


dt_nomem:
		bsr.b	dt_clearobject
		bra.w	nomem

dt_checkerror:
		move.l	dosbase(a5),a6
		jsr	_LVOIoErr(a6)
		
		cmp.l	#error_object_wrong_type,d0
		bne.b	.now
		lea	wrongmsg(pc),a4
		bra.b	.errwech
.now		cmp.l	#dterror_unknown_datatype,d0
		bne.b	.nou
		lea	unknownmsg(pc),a4
		bra.b	.errwech
.nou		cmp.l	#dterror_couldnt_open,d0
		bne.b	.no
		lea	couldntmsg(pc),a4
		bra.b	.errwech
.no		cmp.l	#error_no_free_store,d0
		bne.b	.nn
		lea	dtnomemmsg(pc),a4
		bra.b	.errwech
.nn:		lea	notimplmsg(pc),a4

.errwech:	bsr.w	status
		moveq	#-1,d3
		rts


;--------- Lade 24 Bit datatype --------------------------------------------
PDTA_DestMode	=	$80001000+251
MODE_V43	=	1
DTM_Dummy	=	$600
DTM_READPIXELARRAY	= DTM_Dummy+$61

dt_load24bit:

;setze Bitmap in v43 mode

		move.l	DTObject(a5),a0
		sub.l	a1,a1
		sub.l	a2,a2
		lea	dt_method(pc),a3
		jsr	_LVODoDTMethodA(a6)

		move.l	DTObject(a5),a0
		lea	dt_attr(pc),a2
		move.l	dtbase(a5),a6
		jsr	_LVOGetDTAttrsA(a6)	;hole Attribute

		move.l	dt_mode(pc),d0
		move.l	d0,d1
		swap	d0
		tst.w	d0
		bne.b	.o
		or.l	#$00021000,d1
.o:
		move.l	d1,screenID(a5)

		move.l	dt_bitmapheader(pc),a0
		
		moveq	#0,d0
		move.w	bmh_width(a0),d0
		move.w	bmh_height(a0),d1
		move.w	d0,breite(a5)
		move.w	d1,hoehe(a5)
		
		add.w	#15,d0
		lsr.w	#4,d0
		add.l	d0,d0
		move.l	d0,d7
		move.l	d0,APG_ByteWidth(a5)
		lsl.w	#3,d7		;*2*4

		bsr.l	initrendermem
		tst.l	d0
		beq	dt_nomem

		lea	dt_rastport(pc),a1
		move.l	a1,a4
		move.l	gfxbase(a5),a6
		jsr	_LVOInitrastport(a6)
		
		move.l	dt_bitmap(pc),d0
		move.l	d0,rp_bitmap(a4)
		move.l	rndr_rgb(a5),a0
		moveq	#0,d0
		moveq	#0,d1
		move.l	APG_ByteWidth(a5),d2
		lsl.l	#3,d2
		lsl.l	#2,d2
		move.l	a4,a1
		moveq	#0,d3
		moveq	#0,d4
		move.l	dt_bitmapheader(pc),a2
		move.w	bmh_width(a2),d5
		move.w	bmh_height(a2),d6
		move.l	#RECTFMT_ARGB,d7
		move.l	cyberbase(a5),a6
		jsr	_LVOReadPixelArray(a6)

;		moveq	#0,d0
;
;		move.w	APG_Imageheight(a5),d0
;		move.l	d0,-(a7)
;		move.l	dt_bitmapheader(pc),a0
;		move.w	bmh_width(a0),d0	
;		move.l	d0,-(a7)		;breite
;
;		move.l	#0,-(a7)		;ystart
;		move.l	#0,-(a7)		;xstart
;
;	move.l	d0,d7
;	mulu.l	#4,d7
;
;		move.l	d7,-(a7)		;Modulo
;		move.l	#RECTFMT_ARGB,-(a7)
;		move.l	rndr_rgb(a5),-(a7)
;		move.l	#DTM_READPIXELARRAY,-(a7)
;		move.l	DTObject(a5),-(a7)
;		jsr	_DoMethod
;
;		lea	36(a7),a7

		move.b	#24,APG_Planes(a5)
		move.w	#1,loadflag(a5)

		st	depthchange(a5)

		bsr.w	dt_clearobject

		bra.w	dt_ende

dt_rastport:
		ds.b	rp_sizeof	

_DoMethod:
	MOVE.L	A2,-(SP)
	MOVEA.L	8(SP),A2
	MOVE.L	A2,D0
	BEQ.S	cmnullreturn
	LEA	12(SP),A1
	MOVEA.L	-4(A2),A0
	BRA.S	cminvoke

_DoSuperMethod:
	MOVE.L	A2,-(SP)
	MOVEM.L	8(SP),A0/A2
	MOVE.L	A2,D0
	BEQ.S	cmnullreturn
	MOVE.L	A0,D0
	BEQ.S	cmnullreturn
	LEA	$10(SP),A1
	MOVEA.L	$18(A0),A0
	BRA.S	cminvoke

_CoerceMethod:
	MOVE.L	A2,-(SP)
	MOVEM.L	8(SP),A0/A2
	MOVE.L	A2,D0
	BEQ.S	cmnullreturn
	MOVE.L	A0,D0
	BEQ.S	cmnullreturn
	LEA	$10(SP),A1
	BRA.S	cminvoke

_CoerceMethodA:
	MOVE.L	A2,-(SP)
	MOVEM.L	8(SP),A0/A2
	MOVE.L	A2,D0
	BEQ.S	cmnullreturn
	MOVE.L	A0,D0
	BEQ.S	cmnullreturn
	MOVEA.L	$10(SP),A1
cminvoke:
	PEA	cmreturn(PC)
	MOVE.L	8(A0),-(SP)
	RTS

cmnullreturn:
	MOVEQ	#0,D0
cmreturn:
	MOVEA.L	(SP)+,A2
	RTS

_DoMethodA:
	MOVE.L	A2,-(SP)
	MOVEA.L	8(SP),A2
	MOVE.L	A2,D0
	BEQ.S	cmnullreturn
	MOVEA.L	12(SP),A1
	MOVEA.L	-4(A2),A0
	BRA.S	cminvoke

dt_attr24:
		dc.l	PDTA_DestMode,MODE_V43
		dc.l	TAG_DONE

dt_method24:
		dc.l	DTM_READPIXELARRAY
		dc.l	0			;Pixelbuffer
		dc.l	RECTFMT_ARGB
		dc.l	0			;Modulo
		dc.l	0			;xstart
		dc.l	0			;ystart
		dc.l	0			;width
		dc.l	0			;heigt
		dc.l	~0
		
wrongmsg:	dc.b	'Datatype object wrong type!',0
unknownmsg:	dc.b	'Unknown datatype!',0
couldntmsg:	dc.b	'Unable to open the data object!',0
notimplmsg:	dc.b	'Error not implemented!',0
dtnomemmsg:	dc.b	'Datatype not enough memory!',0
usingdatamsg:	dc.b	'Loading using datatype!',0

datatypeloadedmsg:
		dc.b	'Image successfully loaded.',0

	even

dt_method:	dc.l	DTM_PROCLAYOUT,0

dt_method1:	dc.l	GM_Layout,~0


dt_tags:
		dc.l	PDTA_DestMode,MODE_V43
		dc.l	DTA_GroupID,GID_Picture
		dc.l	DTA_SourceType,DTST_File
		dc.l	PDTA_Remap,0
		
		dc.l	TAG_DONE
		
dt_attr:
		dc.l	DTA_FrameInfo,dt_frame
		dc.l	PDTA_ModeID,dt_mode
		dc.l	PDTA_BitMap,dt_bitmap
		dc.l	PDTA_BitMapHeader,dt_bitmapheader

	;	dc.l	PDTA_ColorTable,dt_color
	;	dc.l	PDTA_ColorTable2,dt_color1
	;	dc.l	PDTA_Allocated,dt_alloc
		dc.l	PDTA_NumColors,dt_numcolor
		dc.l	PDTA_NumAlloc,dt_numalloc
	;	dc.l	PDTA_ClassBitMap,dt_clBitmap
		dc.l	PDTA_CRegs,dt_cregs
		dc.l	TAG_DONE
		
dt_frame:	dc.l	0
dt_mode:	dc.l	0
dt_bitmap:	dc.l	0
dt_bitmapheader:dc.l	0

;dt_color:	dc.l	0
;dt_color1:	dc.l	0
;dt_alloc:	dc.l	0
dt_numcolor:	dc.l	0
dt_numalloc:	dc.l	0
;dt_clBitmap:	dc.l	0
dt_cregs:	dc.l	0

;========================================================================
;	    *---------------- Save IFF ---------------------*		=
;========================================================================
saveiff:

;--- Berechne Pufferspeicher ---
.nix24:
		tst.w	cutflag(a5)
		bne.b	iff_brushok
		move.w	#0,xbrush1(a5)		;Es soll das ganze 
		move.w	#0,ybrush1(a5)		;Pic abgesaved werden
		move.w	breite(a5),xbrush2(a5)
		move.w	hoehe(a5),ybrush2(a5)	

iff_brushok:
		moveq	#0,d1
		moveq	#0,d0
		move.w	xbrush1(a5),d1
		move.w	xbrush2(a5),d0
		sub.w	d1,d0		;x2-x1
		add.w	#15,d0
		lsr.w	#4,d0
		move.w	d0,brushword(a5)

;IFF24 speichern ?

		cmp.b	#24,planes(a5)
		beq	saveiff24

		tst.b	SIFF_render(a5)
		bne	saveiff24

;---
		moveq	#0,d1
		moveq	#0,d2
		move.w	ybrush1(a5),d1
		move.w	ybrush2(a5),d2
		sub.w	d1,d2
		add.w	d0,d0		;Brushword in Byte
		tst.w	d0
		bne.b	.ok
		moveq	#0,d2		;es wurde mit null multipliziert
		bra.b	.weiter
.ok:
		subq.w	#1,d0
		move.l	d2,d1
		moveq	#0,d2
.next:
		add.l	d1,d2		;Simuliert mulu.l Befehl
		dbra	d0,.next

.weiter:
		moveq	#0,d0
		move.b	planes(a5),d0

		move.l	d2,d1
		moveq	#0,d2
		sub.w	#1,d0
.npl:		add.l	d1,d2		;Simuliert mulu.l befehl
		dbra	d0,.npl
		move.l	d2,d0
		
		move.l	d0,brushmemsize(a5)

		add.l	#76+48,d0	;Grundgröße vom Header
		
		moveq	#0,d1
		move.w	anzcolor(a5),d1
		mulu	#3,d1
		add.l	d1,d0

		add.l	#1500,d0		;erstmal zur sicherheit
		add.l	#1500,d0		;erstmal zur sicherheit
		add.l	d0,d0

		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,brushpuffer(a5)
		beq.w	nomem


		bsr.l	openprocess

;---- Fülle IFF-Header ----

		move.l	brushpuffer(a5),a4
		move.l	#'FORM',(a4)+
		move.l	a4,formlenght(a5)
		move.l	#0,(a4)+	;gesammtlänge erstmal Null setzten
		move.l	#'ILBM',(a4)+
		move.l	#'BMHD',(a4)+
		move.l	#20,(a4)+	;BMHD länge 20 Bytes

		move.w	xbrush2(a5),d0
		sub.w	xbrush1(a5),d0
		move.w	d0,(a4)+	;brushbreite
		move.w	ybrush2(a5),d1
		sub.w	ybrush1(a5),d1
		move.w	d1,(a4)+	;brushhöhe

		move.w	d1,d0
		lea	saveiffmsg(pc),a1
		bsr.l	initprocess		

		move.l	#0,(a4)+	;x,y Position der Grafik
		move.b	planes(a5),(a4)+
		move.b	#0,(a4)+	;Typ des Masking => kein Masking

		move.b	#0,d0
		tst.b	SIFF_pack(a5)
		beq.b	.nopack
		move.b	#1,d0
		
.nopack		move.b	d0,(a4)+
;		move.b	#1,(a4)+	;ByteRun1 Kompression
;		move.b	#0,(a4)+	;Keine ByteRun1 Kompression

		tst.b	kick3(a5)
		bne.b	.k3
		move.b	#0,(a4)+	;auffüllbyte
		bra.b	.g
.k3
		move.b	#$80,(a4)+
.g:		
		move.l	#$00000101,(a4)+  ;transparente Farbe ; x,y-Aspect


		move.w	breite(a5),d0		;Screen- und Windowstruck
		move.w	hoehe(a5),d1		;Initialisieren

		move.w	displaywidth(a5),d3
		move.w	displayheight(a5),d4
						
;Passe Screengröße an

		cmp.w	d3,d0		;ist Pic Breiter
		bhi.b	.weidthok
		move.w	d3,d0
.weidthok:

		cmp.w	d4,d1
		bhi.b	.heightok
		move.w	d4,d1
.heightok:
		move.w	d0,(a4)+
		move.w	d1,(a4)+
		
		move.l	#'ANNO',(a4)+
		move.l	#50,(a4)+
		lea	annotext(pc),a0
		moveq	#49,d7
.nanno		move.b	(a0)+,(a4)+	;Kopiere Annotext
		dbra	d7,.nanno

		
		move.l	#'CMAP',(a4)+
		moveq	#0,d0
		move.w	anzcolor(a5),d0
		mulu	#3,d0
		move.l	d0,(a4)+	;länge der Colormap

		move.w	anzcolor(a5),d7
		subq.w	#1,d7
;		cmp.w	#32,anzcolor(a5)
;		bhi.b	.aga
;		cmp.b	#2,colortype(a5)
;		blo.b	.noaga
;.aga
		lea	farbtab8+4(a5),a0
.nextcolor:
		move.l	(a0)+,d0	;kopiere Farbtab jeweils für Normal
		lsr.l	#8,d0		;und AGA
		swap	d0
		move.b	d0,(a4)+
		move.l	(a0)+,d0
		lsr.l	#8,d0
		swap	d0
		move.b	d0,(a4)+
		move.l	(a0)+,d0
		lsr.l	#8,d0
		swap	d0
		move.b	d0,(a4)+
		dbra	d7,.nextcolor		
		bra.w	writebody

writebody:
		move.l	#'CAMG',(a4)+
		move.l	#4,(a4)+
		move.l	displayID(a5),d0
		move.b	ham(a5),d1
		or.b	ham8(a5),d1
		tst.b	d1
		beq.b	.g
		or.l	#$800,d0
.g		
		tst.b	ehb(a5)
		beq.b	.ne
		or.l	#$80,d0
.ne		
		move.l	d0,(a4)+

		moveq	#0,d0
		move.w	brushword(a5),d0
		add.l	d0,d0		;in Byte
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,linemem(a5)
		bne.b	.ok
		move.l	brushpuffer(a5),a1
		jsr	_LVOFreeVec(a6)
		bra.w	nomem
		
.ok:		
		move.l	#'BODY',(a4)+
		move.l	a4,bodymerk(a5)
		add.l	#4,a4
		bsr.w	checkY
		move.l	picmem(a5),a0
		move.l	linemem(a5),a2
		sub.l	a1,a1

		move.w	xbrush1(a5),d4
		moveq	#0,d1
		moveq	#0,d2
		move.w	d4,d1
		move.w	d1,d2	 
		lsr.l	#4,d1	;/16
		move.l	d1,firstword(a5);erstes word ab dem gelesenwird
		lsl.l	#4,d1
		sub.l	d1,d2
		move.l	d2,bitshift(a5)	;anzahl der Bits um die nach links
		move.w	ybrush1(a5),a6
		
;--- Hole eine Zeile ---
iff_makenewline:
		bsr.l	doprocess
		tst.l	d0
		beq.w	iff_stoped
				
		move.b	planes(a5),merk(a5)
iff_newline:

		move.w	xbrush1(a5),d4
		move.l	bitshift(a5),d6
		move.l	picmem(a5),a3
		move.l	firstword(a5),d0
		add.l	d0,d0
		add.l	d0,a3
		add.l	d5,a3
		add.l	a1,a3

		move.l	linemem(a5),a2

		move.w	brushword(a5),d7
		subq.w	#1,d7
iff_newword:
		move.l	(a3),d0
		lsl.l	d6,d0
		swap	d0
		add.l	#16,d4
		move.w	xbrush2(a5),d1
		cmp.w	d4,d1
		bhs.b	.pixok
		move.w	d4,d3
		sub.w	d1,d3
		lsr.w	d3,d0
		lsl.w	d3,d0	;zuviele Bits löschen
.pixok:
		move.w	d0,(a2)+
		addq.l	#2,a3
		dbra	d7,iff_newword
		bsr.w	copyline
		sub.b	#1,merk(a5)
		beq.b	.w
		add.l	oneplanesize(a5),a1
		bra.b	iff_newline
.w:
		sub.l	a1,a1
		add.l	bytebreite(a5),d5

		move.w	ybrush2(a5),d0
		addq.w	#1,a6
		cmp.w	d0,a6
		blo.b	iff_makenewline

		move.l	bodymerk(a5),a0
		move.l	a4,a1
		sub.l	a0,a1
		subq.l	#4,a1
		move.l	a1,(a0)
		
		move.l	a4,d3
		sub.l	brushpuffer(a5),d3
		move.l	d3,d2
		lsr.l	#1,d2
		bcc.b	.noadd
		move.b	#$80,(a4)+
		addq.l	#1,d3
.noadd:	

		move.l	formlenght(a5),a0
		move.l	d3,d5
		sub.l	#8,d5
		move.l	d5,(a0)		;gesamtlänge setzen
		
		move.l	filehandle(a5),d1
		move.l	brushpuffer(a5),d2
		move.l	dosbase(a5),a6
		jsr	_LVOWrite(a6)	;Save volles IFF-Pic ab

iff_end

;schreibe comment

		lea	gsavereqName0,a0
		moveq	#0,d0
		move.w	APG_xbrush2(a5),d0
		sub.w	APG_xbrush1(a5),d0
		moveq	#0,d1
		move.w	APG_ybrush2(a5),d1
		sub.w	APG_ybrush1(a5),d1
		moveq	#0,d2
		move.b	APG_Planes(a5),d2

		tst.b	SIFF_render(a5)
		beq	.n24
		move.b	#24,d2
.n24:
		jsr	APR_SetComment(a5)

		move.l	4,a6
		move.l	brushpuffer(a5),d0
		beq.b	.cl
		move.l	d0,a1
		jsr	_LVOFreeVec(a6)
		clr.l	brushpuffer(a5)
.cl		move.l	linemem(a5),d0
		beq.b	.we
		move.l	d0,a1
		jsr	_LVOFreeVec(a6)
		clr.l	linemem(a5)
.we
		rts

iff_stoped:
		moveq	#APSE_Abort,d3
		bra.b	iff_end
copyline:
		move.l	linemem(a5),a2
		moveq	#0,d7
		move.w	brushword(a5),d7
		tst.b	SIFF_pack(a5)
		beq.w	siff_nopack

		add.l	d7,d7

		moveq	#0,d6		;Bytezähler
		
		move.b	(a2)+,d1
		subq.l	#1,d7
		addq.l	#1,d6
		clr.b	merk1(a5)
.nb:
		move.b	(a2)+,d0
		cmp.b	d0,d1
		bne.b	.nichgleich

		cmp.b	#1,merk1(a5)
		bne.b	.nocopy

		cmp.w	#1,d6
		beq.b	.nocopy
		
		move.b	#2,merk1(a5)
		bsr.b	copynotequal
.nocopy
		move.b	#2,merk1(a5)
		addq.l	#1,d6
		subq.l	#1,d7
		bne.b	.nb
		bra.b	copyequal

.nichgleich:	
		cmp.b	#2,merk1(a5)
		bne.b	.nocopy1
		bsr.b	copyequal
.nocopy1:		
		move.b	#1,merk1(a5)
		move.b	d0,d1
		addq.l	#1,d6
		subq.l	#1,d7
		bne.b	.nb
		bra.w	copynotequal

copynotequal:	sub.l	d6,a2
		subq.l	#1,d6
		cmp.b	#2,merk1(a5)
		bne.b	.vergleichneu
		subq.l	#1,a2
		subq.l	#1,d6
	bpl.b	.vergleichneu
	moveq	#0,d6
.vergleichneu:	cmp.w	#127,d6
		bls.b	.ok
		sub.w	#127,d6
		move.b	#127,(a4)+
	move.l	d5,-(a7)
		moveq	#127,d5
.w:		move.b	(a2)+,(a4)+
		dbra	d5,.w
	move.l	(a7)+,d5
		bra.b	.vergleichneu
.ok:
		move.b	d6,(a4)+
.nb1:		move.b	(a2)+,(a4)+
		dbra	d6,.nb1
		cmp.b	#2,merk1(a5)
		bne.b	.noequ
		moveq	#1,d6
		addq.l	#2,a2
		rts
.noequ:
		moveq	#0,d6
		rts

copyequal:	subq.l	#1,d6
		cmp.w	#127,d6
		bls.b	.ok1
		sub.w	#127,d6
		move.b	#$81,(a4)+
		move.b	d1,(a4)+
		bra.b	copyequal

.ok1:		neg.b	d6
		move.b	d6,(a4)+
		move.b	d1,(a4)+
		move.l	d0,d1
		moveq	#0,d6
		rts

siff_nopack:
		subq.l	#1,d7
.w		move.w	(a2)+,(a4)+
		dbra	d7,.w
		rts

saveiffmsg:	dc.b	'Save a IFF image',0
saveiff24msg:	dc.b	'Save a IFF24 image',0

annotext:	dc.b	'Written by DEFECT',39,'S ArtPRO '
		version
		dc.b	' by Frank Pagels  ',0
	even

;--------------------------------------------------------------------------
;   			Speicher ein IFF24 Image
;
si24_counter	=	APG_Free1
si24_chunky	=	APG_Free2
si24_rgbchunky	=	APG_Free3
si24_planar	=	APG_Free4
si24_chunkyr	=	APG_Free5
si24_chunkyg	=	APG_Free6
si24_chunkyb	=	APG_Free7
si24_Linemerk	=	APG_Free8
si24_bodycounter=	APG_Free9

saveiff24:

;ersma speicher besorgen

		move.l	#10000,d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,brushpuffer(a5)
		beq	nomem

;speicher für die chunky daten besorgen

		moveq	#0,d0
		move.l	bytebreite(a5),d5
		lsl.l	#3,d5
		move.l	d5,d0
		lsl.l	#2,d0		;4 chunky zeilen
		move.l	d0,d6
		add.l	d0,d0		;noch für die rgb chunky's
		add.l	d5,d0		;für die Planardaten
		move.l	#MEMF_ANY!MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		tst.l	d0
		bne	.memok
		move.l	brushpuffer(a5),a1
		jsr	_LVOFreeVec(a6)
		bra	nomem
.memok:
		move.l	d0,si24_chunky(a5)
		add.l	d5,d0
		move.l	d0,si24_chunkyr(a5)
		add.l	d5,d0
		move.l	d0,si24_chunkyg(a5)
		add.l	d5,d0
		move.l	d0,si24_chunkyb(a5)
		add.l	d5,d0
		move.l	d0,si24_rgbchunky(a5)
		add.l	d5,d0
		move.l	d0,si24_planar(a5)		
;InitBitmap
		lea	si24_bitmap(pc),a0
		moveq	#8,d0
;		move.l	bytebreite(a5),d1
;		lsl.l	#3,d1
		moveq	#0,d1
		move.w	APG_xbrush2(a5),d1
		sub.w	APG_xbrush1(a5),d1

		moveq	#1,d2
		move.l	gfxbase(a5),a6
		jsr	_LVOInitBitmap(a6)

;Init Planes in Bitmap

		lea	si24_bitmap+8(pc),a0
		moveq	#8-1,d7
		move.l	bytebreite(a5),d1
	moveq	#0,d1
	move.w	apg_xbrush2(a5),d1
	sub.w	apg_xbrush1(a5),d1
	add.w	#15,d1
	lsr.w	#4,d1
	add.w	d1,d1
		move.l	si24_planar(a5),d0
.np		move.l	d0,(a0)+
		add.l	d1,d0
		dbra	d7,.np

		bsr.l	openprocess

;---- Fülle IFF-Header ----

		move.l	brushpuffer(a5),a4
		move.l	#'FORM',(a4)+
		move.l	#0,(a4)+	;gesammtlänge erstmal Null setzten
		move.l	#'ILBM',(a4)+
		move.l	#'BMHD',(a4)+
		move.l	#20,(a4)+	;BMHD länge 20 Bytes

		move.w	xbrush2(a5),d0
		sub.w	xbrush1(a5),d0
		move.w	d0,(a4)+	;brushbreite
		move.w	ybrush2(a5),d1
		sub.w	ybrush1(a5),d1
		move.w	d1,(a4)+	;brushhöhe

		move.w	d1,d0
		lea	saveiff24msg(pc),a1
		bsr.l	initprocess		

		move.l	#0,(a4)+	;x,y Position der Grafik
		move.b	#24,(a4)+	;24 Planes
		move.b	#0,(a4)+	;Typ des Masking => kein Masking

		move.b	#0,d0
;		tst.b	SIFF_pack(a5)
;		beq.b	.nopack
;		move.b	#1,d0
		
.nopack		move.b	d0,(a4)+

		tst.b	kick3(a5)
		bne.b	.k3
		move.b	#0,(a4)+	;auffüllbyte
		bra.b	.g
.k3
		move.b	#$80,(a4)+
.g:		
		move.l	#$00000101,(a4)+  ;transparente Farbe ; x,y-Aspect

		move.w	breite(a5),d0		;Screen- und Windowstruck
		move.w	hoehe(a5),d1		;Initialisieren

		move.w	displaywidth(a5),d3
		move.w	displayheight(a5),d4
						
;Passe Screengröße an

		cmp.w	d3,d0		;ist Pic Breiter
		bhi.b	.weidthok
		move.w	d3,d0
.weidthok:

		cmp.w	d4,d1
		bhi.b	.heightok
		move.w	d4,d1
.heightok:
		move.w	d0,(a4)+
		move.w	d1,(a4)+
		
		move.l	#'ANNO',(a4)+
		move.l	#50,(a4)+
		lea	annotext(pc),a0
		moveq	#49,d7
.nanno		move.b	(a0)+,(a4)+	;Kopiere Annotext
		dbra	d7,.nanno

		move.l	#'BODY',(a4)+
		move.l	a4,d0
		move.l	brushpuffer(a5),d1
		sub.l	d1,d0
		move.l	d0,bodymerk(a5)	;Offset für den Body merken

		clr.l	(a4)+		;Body länge ersma null
		
		bsr	si24_save	;Block ersma speichern

;Bereite palette vor

		tst.l	APG_rndr_rgb(a5)
		bne	.nixpal

		lea	Farbtab8pure,a0
		move.l	a0,a3
		lea	APG_Farbtab8(a5),a1
		move.w	(a1)+,d7
		moveq	#0,d5
		move.w	d7,d5		;für ImportPalette merken
		subq.w	#1,d7
		addq.l	#2,a1
.nc:		move.l	(a1)+,d0
		move.l	(a1)+,d1
		move.l	(a1)+,d2
		lsr.l	#8,d0
		swap	d1
		move.w	d1,d0
		rol.l	#8,d2
		move.b	d2,d0
		and.l	#$00ffffff,d0
		move.l	d0,(a0)+
		dbra	d7,.nc

		move.l	APG_rndr_palette(a5),a0
		move.l	a3,a1			;Farbtab
		move.l	d5,d0			;Anzahl Farben
		lea	rndr_palitag,a2
		move.l	APG_RenderBase(a5),a6
		jsr	_LVOImportPaletteA(a6)

		moveq	#COLORMODE_CLUT,d5
		tst.b	APG_HAM_Flag(a5)
		beq.w	.wc
		moveq	#COLORMODE_HAM6,d5
		bra.b	.ren
.wc		tst.b	APG_HAM8_Flag(a5)
		beq.b	.ren
		moveq	#COLORMODE_HAM8,d5
.ren
		lea	si24_c2rtag,a3
		move.l	d5,4(a3)		;Colormode eintragen
		moveq	#0,d0
		move.w	xbrush1(a5),d0
		move.l	d0,12(a3)		;Linke ecke
		move.l	bytebreite(a5),d0
		lsl.l	#3,d0
		move.l	d0,20(a3)		;Source Width
		
;brush daten sichern
.nixpal:
		clr.l	si24_bodycounter(a5)

		move.w	APG_ybrush1(a5),si24_Linemerk(a5)
		move.w	APG_ybrush2(a5),d7
		tst.w	d7
		beq.b	.wech
		sub.w	APG_ybrush1(a5),d7
		tst.w	d7
		beq.b	.wech
		subq.w	#1,d7
.wech		
;Begin save

;ersma eine Chunkyline erzeugen
si24_newline
		tst.l	APG_rndr_rgb(a5)
		bne	si24_getrgb		;wir haben schon rgb daten

		moveq	#0,d0
		move.w	si24_Linemerk(a5),d1
		move.l	bytebreite(a5),d0
		mulu	d0,d1
		lea	si24_planetab(pc),a0
		move.l	picmem(a5),a1
		move.l	a0,a2
		add.l	d1,a1
		moveq	#8-1,d7
.np:		move.l	a1,(a2)+
		add.l	oneplanesize(a5),a1
		dbra	d7,.np		
		moveq	#1,d1
		moveq	#0,d2
		move.b	apg_planes(a5),d2
		move.l	d0,d3
		move.l	si24_chunky(a5),a1
		sub.l	a2,a2
		move.l	renderbase(a5),a6
		jsr	_LVOPlanar2Chunky(a6)

;jetzt RGB's mächen
		move.l	si24_chunky(a5),a0
		move.w	APG_xbrush2(a5),d0
		sub.w	APG_xbrush1(a5),d0
		moveq	#1,d1			;eine Zeile
		move.l	si24_rgbchunky(a5),a1
		move.l	APG_rndr_palette(a5),a2
		lea	si24_c2rtag,a3
		jsr	_LVOChunky2RGBA(a6)

;rgb daten aufsplitten
si24_splitrgb:

		move.l	si24_rgbchunky(a5),a0
		move.w	APG_xbrush2(a5),d6
		sub.w	APG_xbrush1(a5),d6
		subq.w	#1,d6
		
		move.l	si24_chunkyr(a5),a1	;R
		move.l	si24_chunkyg(a5),a2	;G
		move.l	si24_chunkyb(a5),a3	;B
.ncr
		move.l	(a0)+,d0
		move.b	d0,(a3)+
		lsr.l	#8,d0
		move.b	d0,(a2)+
		lsr.l	#8,d0
		move.b	d0,(a1)+

		dbra	d6,.ncr

;wieder planes erzeugen

		move.l	si24_chunkyr(a5),a0
		moveq	#0,d0
		moveq	#0,d1
		move.w	APG_xbrush2(a5),d2
		sub.w	APG_xbrush1(a5),d2
		moveq	#1,d3
		lea	si24_bitmap(pc),a1
		moveq	#0,d4
		moveq	#0,d5
		sub.l	a2,a2	;No Tags
		move.l	APG_RenderBase(a5),a6
		jsr	_LVOChunky2BitmapA(a6)

		bsr	si24_copyline	       ;eine Zeile in den Puffer Kopieren

		move.l	si24_chunkyg(a5),a0
		moveq	#0,d0
		moveq	#0,d1
		move.w	APG_xbrush2(a5),d2
		sub.w	APG_xbrush1(a5),d2

		moveq	#1,d3
		lea	si24_bitmap(pc),a1
		moveq	#0,d4
		moveq	#0,d5
		sub.l	a2,a2	;No Tags
		move.l	APG_RenderBase(a5),a6
		jsr	_LVOChunky2BitmapA(a6)

		bsr	si24_copyline	       ;eine Zeile in den Puffer Kopieren

		move.l	si24_chunkyb(a5),a0
		moveq	#0,d0
		moveq	#0,d1
		move.w	APG_xbrush2(a5),d2
		sub.w	APG_xbrush1(a5),d2

		moveq	#1,d3
		lea	si24_bitmap(pc),a1
		moveq	#0,d4
		moveq	#0,d5
		sub.l	a2,a2	;No Tags
		move.l	APG_RenderBase(a5),a6
		jsr	_LVOChunky2BitmapA(a6)

		bsr	si24_copyline	       ;eine Zeile in den Puffer Kopieren
		
		bsr.l	doprocess

		move.w	si24_Linemerk(a5),d0
		addq.w	#1,d0
		cmp.w	APG_ybrush2(a5),d0
		beq	.endimage
		move.w	d0,si24_Linemerk(a5)
		bra	si24_newline
.endimage
		bsr	si24_save

;brush daten zurückholen

		move.l	4.w,a6
		move.l	brushpuffer(a5),d0
		beq	.nixbrush
		move.l	d0,a1
		jsr	_LVOFreeVec(a6)
.nixbrush:


;nun BODY länge eintragen
		move.l	APG_Filehandle(a5),d1
		move.l	bodymerk(a5),d2
		move.l	#OFFSET_BEGINNING,d3
		move.l	APG_Dosbase(a5),a6
		jsr	_LVOSeek(a6)

		lea	si24_planetab(pc),a0
		move.l	a0,d2
		move.l	si24_bodycounter(a5),(a0)
		moveq	#4,d3
		move.l	APG_Filehandle(a5),d1
		jsr	_LVOWrite(a6)

		move.l	APG_Filehandle(a5),d1
		moveq	#4,d2
		move.l	#OFFSET_BEGINNING,d3
		move.l	APG_Dosbase(a5),a6
		jsr	_LVOSeek(a6)

		lea	si24_planetab(pc),a0
		move.l	a0,d2
		move.l	si24_bodycounter(a5),d0
		add.l	#98,d0			;IFF Header länge
		move.l	d0,(a0)
		moveq	#4,d3
		move.l	APG_Filehandle(a5),d1
		jsr	_LVOWrite(a6)

;schreibe comment

		lea	gsavereqName0,a0
		moveq	#0,d0
		move.w	APG_xbrush2(a5),d0
		sub.w	APG_xbrush1(a5),d0
		moveq	#0,d1
		move.w	APG_ybrush2(a5),d1
		sub.w	APG_ybrush1(a5),d1
		moveq	#24,d2
		jsr	APR_SetComment(a5)

		rts

;Unterroutinen für Iff24 saver

si24_getrgb:
		move.l	APG_rndr_rgb(a5),a0
		move.w	si24_Linemerk(a5),d1
		move.l	bytebreite(a5),d0
		lsl.l	#3+2,d0
		mulu	d1,d0
		add.l	d0,a0
		moveq	#0,d0
		move.w	APG_xbrush1(a5),d0
		lsl.w	#2,d0
		add.l	d0,a0
;rgb chunkys copieren

		move.w	APG_xbrush2(a5),d7
		sub.w	APG_xbrush1(a5),d7
		subq.w	#1,d7
		move.l	si24_rgbchunky(a5),a1
.nc		move.l	(a0)+,(a1)+
		dbra	d7,.nc
		
		bra	si24_splitrgb

si24_copyline:
		moveq	#8-1,d7
		move.l	si24_planar(a5),a2

.nl		movem.l	d7/a6,-(a7)
		bsr	si24_copy
		movem.l	(a7)+,d7/a6
		dbra	d7,.nl
		rts

si24_copy:
		moveq	#0,d7
		move.w	brushword(a5),d7
;		tst.b	SIFF_pack(a5)
;		beq.w	si24_nopack
		bra	si24_nopack
		
		add.l	d7,d7
		lsl.l	#3,d7	;mal 8 da acht planes

		moveq	#0,d6		;Bytezähler
		
		move.b	(a2)+,d1
		subq.l	#1,d7
		addq.l	#1,d6
		clr.b	merk1(a5)
.nb:
		move.b	(a2)+,d0
		cmp.b	d0,d1
		bne.b	.nichgleich

		cmp.b	#1,merk1(a5)
		bne.b	.nocopy

		cmp.w	#1,d6
		beq.b	.nocopy
		
		move.b	#2,merk1(a5)
		bsr.b	si24_copynotequal
.nocopy
		move.b	#2,merk1(a5)
		addq.l	#1,d6
		subq.l	#1,d7
		bne.b	.nb
		bra.w	si24_copyequal

.nichgleich:	
		cmp.b	#2,merk1(a5)
		bne.b	.nocopy1
		bsr.w	si24_copyequal
.nocopy1:		
		move.b	#1,merk1(a5)
		move.b	d0,d1
		addq.l	#1,d6
		subq.l	#1,d7
		bne.b	.nb
		bra.w	si24_copynotequal

si24_copynotequal:
		sub.l	d6,a2
		subq.l	#1,d6
		cmp.b	#2,merk1(a5)
		bne.b	.vergleichneu
		subq.l	#1,a2
		subq.l	#1,d6
		bpl.b	.vergleichneu
		moveq	#0,d6
.vergleichneu:	cmp.w	#127,d6
		bls.b	.ok
		sub.w	#127,d6
		move.b	#127,(a4)+

	sub.l	#1,si24_counter(a5)
		bne	.ns
		bsr	si24_save
.ns

		moveq	#127,d5
.w:		move.b	(a2)+,(a4)+
	sub.l	#1,si24_counter(a5)
		bne	.ns1
		bsr	si24_save
.ns1
		dbra	d5,.w
		bra.b	.vergleichneu
.ok:
		move.b	d6,(a4)+
	sub.l	#1,si24_counter(a5)
	bne	.ns2
	bsr	si24_save
.ns2

.nb1:		move.b	(a2)+,(a4)+
	sub.l	#1,si24_counter(a5)
	bne	.ns3
	bsr	si24_save
.ns3
		dbra	d6,.nb1
		cmp.b	#2,merk1(a5)
		bne.b	.noequ
		moveq	#1,d6
		addq.l	#2,a2
		rts
.noequ:
		moveq	#0,d6
		rts

si24_copyequal:	subq.l	#1,d6
		cmp.w	#127,d6
		bls.b	.ok1
		sub.w	#127,d6
		move.b	#$81,(a4)+
	sub.l	#1,si24_counter(a5)
	bne	.ns4
	bsr	si24_save
.ns4
		move.b	d1,(a4)+
	sub.l	#1,si24_counter(a5)
	bne	.ns7
	bsr	si24_save
.ns7
		bra.b	si24_copyequal

.ok1:		neg.b	d6
		move.b	d6,(a4)+
	sub.l	#1,si24_counter(a5)
	bne	.ns5
	bsr	si24_save
.ns5
		move.b	d1,(a4)+
	sub.l	#1,si24_counter(a5)
	bne	.ns6
	bsr	si24_save
.ns6
		move.l	d0,d1
		moveq	#0,d6
		rts

si24_nopack:
		subq.l	#1,d7
.w		move.w	(a2)+,(a4)+
	sub.l	#2,si24_counter(a5)
;		move.l	si24_counter(a5),d0
;		sub.l	#2,d0
;		move.l	d0,si24_counter(a5)
		bne	.ns
		bsr	si24_save
.ns
		dbra	d7,.w
		rts

si24_savepuffer:
		rts


si24_c2rtag:	dc.l	RND_ColorMode,0
		dc.l	RND_LeftEdge,0
		dc.l	RND_SourceWidth,0
		dc.l	TAG_DONE
		
si24_bitmap:	dc.w	0
		dc.w	0
		dc.b	0
		dc.b	0
		dc.w	0
		ds.l	8

si24_planetab:	ds.l	8

;---------------------------------------------------------------------------
;Speicher block
si24_save:
		movem.l	d0-d7/a0-a3,-(a7)
		move.l	brushpuffer(a5),d5
		sub.l	d5,a4
		move.l	a4,d3
		tst.l	d3
		beq	.w
		add.l	d3,si24_bodycounter(a5)
		move.l	filehandle(a5),d1
		move.l	brushpuffer(a5),d2
		move.l	dosbase(a5),a6
		jsr	_LVOWrite(a6)
.w
		move.l	d5,a4
	movem.l	(a7)+,d0-d7/a0-a3

		move.l	#10000,si24_counter(a5)		;counter neu setzen
		
		rts

;----------------------------------------------------------------------------
;--------- Preferences für IFF saver 
SIFF_prefs:
;init Prefs
		moveq	#0,d0
		move.b	SIFF_pack(a5),d0
		lea	SIFF_MX(pc),a0
		move.l	d0,(a0)
		move.b	SIFF_render(a5),d0
		lea	SIFF_24(pc),a0
		move.l	d0,(a0)

;---------------------------------------------------------------------------

		move.l	#SIFF_WindowTags,APG_WindowTagList(a5) ;Tag list for the Window
		move.l	#SIFF_WinWG+4,APG_WGadgets(a5)	;addr. of WA_Gadgets Tag + 4
		move.l	#SIFF_winSC+4,APG_WScreen(a5)	;addr. of WA_CustomScreen Tag + 4
		move.l	#SIFF_window,APG_WinWnd(a5)	;a point for the Window
		move.l	#SIFF_Glist,APG_Glist(a5)		;a point for the Glist
		move.l	#SIFF_NTypes,APG_NGads(a5)		;the NGads list
		move.l	#SIFF_Gtypes,APG_GTypes(a5)		;the GTypes list
		move.l	#SIFF_Gtags,APG_Gtags(a5)		;the Gtags list
		move.w	#4,APG_CNT(a5)			;the number of Gadgets
		move.l	#SIFF_gadarray,APG_Gadgets(a5)	;a pointer for the Gadgetsarry, size=4*number of Gadgets
		move.l	APG_Scr(a5),APG_ScrBase(a5)	;the Screenpointer , stored in APG_Scr
	
		move.l	APG_CheckMainWinPos(a5),a6	;returns d0,d1 Pos
		jsr	(a6)

		add.w	#70,d0
		add.w	#100,d1
		
		move.w	d0,APG_WinLeft(a5)		;the left pos. of the Win
		move.w	d1,APG_WinTop(a5)		;the top pos. of the Win
		move.w	#160,APG_WinWidth(a5)		;the width of the Win
		move.w	#70,APG_WinHeight(a5)		;the height of the Win

		move.l	#SIFF_WinL,APG_WinL(a5)		;addr. of WA_Left Tag 
		move.l	#SIFF_WinT,APG_WinT(a5)		;addr. of WA_Top Tag
		move.l	#SIFF_WinW,APG_WinW(a5)		;addr. of WA_Width Tag
		move.l	#SIFF_WinH,APG_WinH(a5)		;addr. of WA_Height Tag

		move.l	APG_OpenWindow(a5),a6
		jsr	(a6)

		lea	SIFF_Text0(pc),a2
		move.w	#SIFF_Project0_TNUM,APG_TNUM(a5)
		move.l	APG_Writetext(a5),a6
		jsr	(a6)

		move.b	SIFF_pack(a5),APG_Mark1(a5)	;backup the prefs
		move.b	SIFF_render(a5),APG_Mark2(a5)

SIFF_wait:	move.l	SIFF_window(pc),a0
		move.l	APG_Wait(a5),a6
		jsr	(a6)				;Handle input

		cmp.l	#CLOSEWINDOW,d4
		beq	SIFF_Cancel
		cmp.l	#GADGETUP,d4
		beq.b	SIFF_gads
		cmp.l	#GADGETDOWN,d4
		beq.b	SIFF_gads
		bra.b	SIFF_wait

SIFF_gads:
		moveq	#0,d0
		move.w	38(a4),d0

		cmp.w	#SIFF_GD_format,d0
		beq.b	SIFF_handleformat
		cmp.b	#SIFF_GD_24Bit,d0
		beq	SIFF_handle24
		cmp.w	#SIFF_GD_Ok,d0
		beq.b	SIFF_Cancel\.wech
		cmp.w	#SIFF_GD_Cancel,d0
		bne.b	SIFF_wait
SIFF_Cancel:
		move.b	APG_Mark1(a5),d0
		ext.w	d0
		ext.l	d0
		move.b	d0,SIFF_pack(a5)
		move.l	d0,SIFF_MX
		move.b	APG_Mark2(a5),d0
		ext.w	d0
		ext.l	d0
		move.b	d0,SIFF_render(a5)
		move.l	d0,SIFF_24
.wech:
		move.l	SIFF_window(pc),a0
		move.l	APG_Intuitionbase(a5),a6
		jmp	_LVOCloseWindow(a6)

SIFF_handleformat:
		move.b	d5,SIFF_pack(a5)
		ext.w	d5
		ext.l	d5
		move.l	d5,SIFF_MX
		bra.w	SIFF_wait
SIFF_handle24:
		move.b	d5,SIFF_render(a5)
		ext.w	d5
		ext.l	d5
		move.l	d5,SIFF_24
		bra.w	SIFF_wait

		rts

SIFF_window	dc.l	0		;Enthält pointer vom eingenen Window
SIFF_GList	dc.l	0		
SIFF_gadarray	dcb.l	4,0

	even

;-----------------------------------------------------------------------------
SIFF_WindowTags:
SIFF_winL:	dc.l	WA_Left,212
SIFF_winT:	dc.l	WA_Top,78
SIFF_winW:	dc.l	WA_Width,220
SIFF_winH:	dc.l	WA_Height,85
		dc.l	WA_IDCMP,CLOSEWINDOW!MXIDCMP!GADGETUP!VANILLAKEY!BUTTONIDCMP!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_CLOSEGADGET!WFLG_DEPTHGADGET!WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_SMART_REFRESH!WFLG_RMBTRAP
SIFF_winWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title,SIFF_winWTitle
SIFF_winSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

SIFF_WinWTitle:	dc.b	'IFF Options',0
	even

SIFF_GD_format	=	0
SIFF_GD_24bit	=	1
SIFF_GD_Ok	=	2
SIFF_GD_Cancel	=	3

SIFF_Gtypes:
		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
SIFF_Gtags:
		dc.l	GTCY_Labels,SIFF_Gadget00Labels
		dc.l	GTCY_Active
SIFF_MX:	dc.l	0
		dc.l	TAG_DONE
SIFF_24tags:
	;	dc.l	GA_Disabled,1
		dc.l	GTCY_Labels,SIFF_Gadget01Labels
		dc.l	GTCY_Active
SIFF_24:	dc.l	0
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	TAG_DONE
SIFF_Gadget00Labels:
		dc.l	SIFF_Gadget00Lab0
		dc.l	SIFF_Gadget00Lab1
		dc.l	0

SIFF_Gadget00Lab0:	dc.b	'not packed',0
SIFF_Gadget00Lab1:	dc.b	'RLE packed',0

SIFF_Gadget01Labels:
		dc.l	SIFF_Gadget01Lab0
		dc.l	SIFF_Gadget01Lab1
		dc.l	0

SIFF_Gadget01Lab0:	dc.b	'Rendered',0
SIFF_Gadget01Lab1:	dc.b	'24 Bit',0


SIFF_NTypes:
		DC.W    20,20,120,13
		DC.L    0,0
		DC.W    SIFF_GD_format
		DC.L    PLACETEXT_RIGHT,0,0
		DC.W    20,35,120,13
		DC.L    0,0
		DC.W    SIFF_GD_24Bit
		DC.L    PLACETEXT_RIGHT,0,0
		DC.W    10,55,60,13
		DC.L    oktext,0
		DC.W    SIFF_GD_Ok
		DC.L    PLACETEXT_IN,0,0
		DC.W    85,55,60,13
		DC.L    canceltext,0
		DC.W    SIFF_GD_Cancel
		DC.L    PLACETEXT_IN,0,0

SIFF_Text0:
		DC.B    2,0
		DC.B    RP_JAM1
		DC.B    0
		DC.W    80,10
		DC.L    0
		DC.L    Project0IText0
		DC.L    0

SIFF_Project0_TNUM EQU 1

;--------------------------------------------------------------------------

Project0IText0:
		dc.b	'Save format',0

oktext:		dc.b	'Ok',0
canceltext:	dc.b	'Cancel',0

	even
;=================================================================
;--------------------------- Load Raw ----------------------------
;=================================================================
loadraw:
		clr.b	rawblitt(a5)
loadraw1:
		lea	imagewinWindowTags,a0
		move.l	a0,windowtaglist(a5)
		lea	imagewinWG+4,a0
		move.l	a0,gadgets(a5)
		lea	imagewinSC+4,a0
		move.l	a0,winscreen(a5)
		lea	imagewinWnd(a5),a0
		move.l	a0,window(a5)
		lea	imagewinGlist(a5),a0
		move.l	a0,Glist(a5)
		lea	imagewinNgads(pc),a0
		move.l	a0,NGads(a5)
		lea	imagewinGTypes(pc),a0
		move.l	a0,GTypes(a5)
		lea	imagewinGadgets(pc),a0
		move.l	a0,WinGadgets(a5)
		move.w	#imagewin_CNT,win_CNT(a5)
		lea	imagewinGtags(pc),a0
		move.l	a0,windowtags(a5)
		move.l	scr(a5),screenbase(a5)

		bsr.w	checkmainwinpos

		add.w	#imagewinLeft,d0
		add.w	#imagewinTop,d1

		move.w	d1,WinTop(a5)
		move.w	d0,WinLeft(a5)

		move.w	#imagewinWidth,WinWidth(a5)
		move.w	#imagewinHeight,WinHeight(a5)
		lea	imageWinL,a0
		move.l	a0,WinL(a5)
		lea	imageWinT,a0
		move.l	a0,WinT(a5)
		lea	imageWinW,a0
		move.l	a0,WinW(a5)
		lea	imageWinH,a0
		move.l	a0,WinH(a5)

		bsr.w	openwindowF

		move.l	#GD_imagewidth,d0
		bsr.w	lr_activate

lr_wait
		move.l	imagewinWnd(a5),a0
		jsr	wait

		cmp.l	#closewindow,d4
		beq.w	lr_cancel
		cmp.l	#GADGETUP,d4
		beq.b	lr_gads
		cmp.l	#IDCMP_VANILLAKEY,d4
		beq.b	lr_keys		;es wurde eine Taste gedrückt

		bra.b	lr_wait
lr_gads:
		moveq	#0,d0
		move.w	38(a4),d0
		cmp.w	#GD_imagewidth,d0
		beq.w	lr_width		;beende Programm
		cmp.w	#GD_imageheight,d0
		beq.w	lr_height
		cmp.w	#GD_imagedepth,d0
		beq.w	lr_depth
		cmp.w	#GD_imagedisplay,d0
		beq.w	lr_display
		cmp.w	#GD_imagedoit,d0
		beq.w	lr_load
		cmp.w	#GD_imagecancel,d0
		beq.w	lr_cancel
		bra.b	lr_wait			;kein Gadget dabei

lr_keys:
		move.l	imagewinWnd(a5),aktwin(a5)
		lea	imagewinGadgets(pc),a0
		move.l	d5,d3
		cmp.w	#'d',d3
		bne.b	.noload
		lea	lr_load(pc),a3
		move.l	#GD_imagedoit,d0
		jmp	setandjump
.noload:		
		cmp.w	#'c',d3
		bne.b	.nocancel
		lea	lr_cancel(pc),a3
		move.l	#GD_imagecancel,d0
		jmp	setandjump
.nocancel:
		cmp.w	#'i',d3
		bne.b	.nodisp
		move.l	rdispl(pc),d1
		addq.l	#1,d1
		cmp.l	#3,d1
		blo.b	.kl
		moveq	#0,d1
.kl:
		move.l	d1,rdispl
		move.l	d1,imagedisplay(a5)
		move.l	#GD_imagedisplay,d0
		lea	imagewinGadgets(pc),a0
		move.l	imagewinWnd(a5),a1
		bsr.w	setcyle	
		bra.w	lr_wait
.nodisp:

		cmp.w	#'w',d3
		bne.b	.nowidth
		move.l	#GD_imagewidth,d0
		bsr.b	lr_activate
		bra.w	lr_wait
.nowidth:
		cmp.w	#'h',d3
		bne.b	.noheight
		move.l	#GD_imageheight,d0
		bsr.b	lr_activate
		bra.w	lr_wait
.noheight:		
		cmp.w	#'p',d3
		bne.w	lr_wait
		move.l	#GD_imagedepth,d0	
		bsr.b	lr_activate		
		bra.w	lr_wait
		

;---------------------------------------------------------------
lr_activate:
		add.l	d0,d0
		add.l	d0,d0
		lea	imagewinGadgets(pc),a0
		move.l	(a0,d0.l),a0
		move.l	imagewinWnd(a5),a1
		sub.l	a2,a2
		move.l	intbase(a5),a6
		jmp	_LVOActivateGadget(a6)		

;---------------------------------------------------------------------

lr_width:
		move.l	#GD_imagewidth,d0	
		lea	imagewinGadgets(pc),a0
		bsr.w	lr_asciinteger
		move.l	d0,imagewidth(a5)
		move.l	d0,rwidth
		move.l	#GD_imageheight,d0
		bsr.b	lr_activate
		bra.w	lr_wait
lr_height:
		move.l	#GD_imageheight,d0	
		lea	imagewinGadgets(pc),a0
		bsr.w	lr_asciinteger
		move.l	d0,imageheight(a5)
		move.l	d0,rheight
		move.l	#GD_imagedepth,d0	
		bsr.b	lr_activate		
		bra.w	lr_wait
lr_depth:
		move.l	#GD_imagedepth,d0	
		lea	imagewinGadgets(pc),a0
		bsr.w	lr_asciinteger
		move.l	d0,imagedepth(a5)
		move.l	d0,rdepth
		bra.w	lr_wait
lr_display:
		ext.l	d5
		move.l	d5,imagedisplay(a5)
		move.l	d5,rdispl
		bra.w	lr_wait				
		
lr_load:
		bsr.w	closeimagewin

		move.l	imagedepth(a5),d0
		beq.w	lr_false
		moveq	#1,d1
		lsl.l	d0,d1
		move.w	d1,anzcolor(a5)
		
		move.l	imagedepth(a5),d0
		move.b	d0,planes(a5)

		clr.b	ehb(a5)
		clr.b	ham(a5)
		clr.b	ham8(a5)
		move.l	imagedisplay(a5),d1

		cmp.w	#1,d1
		bne.b	.noehb
		st	ehb(a5)
		move.w	#32,anzcolor(a5)
.noehb:		cmp.w	#2,d1
		bne.b	.noham
		cmp.b	#6,planes(a5)
		bhi.b	.ham8
		st	ham(a5)
		move.w	#16,anzcolor(a5)
		bra.b	.noham
.ham8:		st	ham8(a5)
		move.w	#64,anzcolor(a5)
.noham:		
		move.l	imagewidth(a5),d0
		beq.w	lr_false
		move.w	d0,breite(a5)
		add.l	#15,d0
		lsr.l	#4,d0		;byte per line
		add.l	d0,d0

		move.l	d0,bytebreite(a5)

		move.l	imageheight(a5),d1
		beq.w	lr_false
		move.w	d1,hoehe(a5)
		mulu	d0,d1		;oneplanesize
		move.l	d1,oneplanesize(a5)

		move.l	imagedepth(a5),d0
		move.b	d0,planes(a5)

		subq.l	#1,d0
		moveq	#0,d2
np:
		add.l	d1,d2
		dbra	d0,np

		move.l	d2,memsize(a5)
		move.l	d2,d0
		move.l	#$10002,d1
		move.l	4,a6
		jsr	_LVOallocVec(a6)
		move.l	d0,picmem(a5)			
		bne.b	.memok
		lea	notmemmsg(pc),a4
		bsr.w	status
		moveq	#-1,d3
		rts
.memok:
		move.l	memsize(a5),d0
		move.l	size(a5),d1
		cmp.l	d0,d1
		beq.b	.sizeok
		lea	dimemsionsmsg(pc),a4
		bsr.w	status
		moveq	#-1,d3
		rts		
.sizeok:
		tst.b	rawblitt(a5)
		bne.w	lr_loadblitt
		
		tst.b	ham8(a5)
		beq.b	.nixham

;Lade HAM8 extra weil ja die ersten zwei Bitplanes vertauscht sind

		move.l	picmem(a5),d2
		move.l	oneplanesize(a5),d0
		add.l	d0,d0
		move.l	d0,d3
		mulu.l	#3,d0	;= 6 mal oneplane
		move.l	d0,d7
		add.l	d0,d2
		move.l	filehandle(a5),d1
		move.l	dosbase(a5),a6
		jsr	_LVORead(a6)

		move.l	filehandle(a5),d1
		move.l	picmem(a5),d2
		move.l	d7,d3
		jsr	_LVORead(a6)		
		bra.b	loadago

.nixham:
		moveq	#0,d0
		move.l	filehandle(a5),d1
		move.l	picmem(a5),d2
		move.l	size(a5),d3
		move.l	dosbase(a5),a6
		jsr	_LVORead(a6)
loadago:		
		move.w	#1,loadflag(a5)
		
		move.b	#1,merk1(a5)
		jsr	changemoni1

;create default colorlist

		lea	farbtab8+4(a5),a0
		lea	farbtab4(a5),a1
		moveq	#0,d0
		move.l	#256,d2
		move.w	anzcolor(a5),d3
		divu	d3,d2
		ext.l	d2
		move.w	anzcolor(a5),d7
		ext.l	d7
		cmp.l	#1,imagedisplay(a5)
		bne.b	.we
		lsr.l	#1,d7
.we:
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
		
		lea	farbtab8(a5),a0
		move.w	anzcolor(a5),(a0)

		clr.b	colortype(a5)
		tst.b	kick3(a5)
		beq.b	.no3
		move.b	#2,colortype(a5)
.no3:
;		move.w	#320,displaywidth(a5)
;		move.w	#640,displaywidth(a5)

		moveq	#0,d3
		rts
lr_cancel:
		bra.b	closeimagewin

lr_false:
		lea	loaderrormsg(pc),a4
		bsr.w	status
		moveq	#-1,d3
		rts


closeimagewin:
		lea	imagewinWnd(a5),a0
		move.l	a0,window(a5)
		lea	imagewinGlist(a5),a0
		move.l	a0,Glist(a5)
		bra.w	gt_CloseWindow

lr_asciinteger:
		movem.l d1-d7/a0-a6,-(sp)
		lsl.l	#2,d0
		move.l	(a0,d0.w),a0
		move.l	gg_SpecialInfo(a0),a0
		move.w	si_NumChars(a0),d7	;Anzahl der Zeichen
		move.l	(a0),a0		;String
		lea	(a0,d7.w),a0	;ende des Strings
		subq.w	#1,d7
		moveq	#0,d0
		moveq	#1,d2
lr_nextchar:
		moveq	#0,d1
		move.b	-(a0),d1
		sub.b	#48,d1
		muls	d2,d1
		muls	#10,d2		
		add.l	d1,d0
		dbra	d7,lr_nextchar
		movem.l (sp)+,d1-d7/a0-a6
		rts		

lr_loadblitt:
		move.l	dosbase(a5),a6
		move.l	imageheight(a5),d7
		subq.l	#1,d7
		move.l	picmem(a5),a3
		tst.b	ham8(a5)
		bne.b	.loadham8

.nl:
		sub.l	a4,a4		;planeoffset
		move.l	imagedepth(a5),d6
		subq.l	#1,d6
.np:
		move.l	filehandle(a5),d1
		move.l	a3,d2
		add.l	a4,d2
		move.l	bytebreite(a5),d3
		jsr	_LVORead(a6)
		add.l	oneplanesize(a5),a4
		dbra	d6,.np
		add.l	bytebreite(a5),a3
		dbra	d7,.nl
		bra.w	loadago
		
;lade Ham8 Blit
.loadham8:
.nlham8:
		move.l	oneplanesize(a5),d0
		mulu.l	#6,d0
		move.l	d0,a4		

		move.l	a3,d2
		add.l	a4,d2
		move.l	bytebreite(a5),d3
		move.l	filehandle(a5),d1
		jsr	_LVORead(a6)
		add.l	oneplanesize(a5),a4
		move.l	a3,d2
		add.l	a4,d2
		move.l	bytebreite(a5),d3
		move.l	filehandle(a5),d1
		jsr	_LVORead(a6)

		moveq	#6-1,d6
		sub.l	a4,a4
.np8		move.l	a3,d2
		add.l	a4,d2
		move.l	bytebreite(a5),d3
		move.l	filehandle(a5),d1
		jsr	_LVORead(a6)
		add.l	oneplanesize(a5),a4
		dbra	d6,.np8
		add.l	bytebreite(a5),a3
		dbra	d7,.nlham8

		bra.w	loadago		

;=================================================================
;----------------------- Load Raw-Blitt --------------------------
;=================================================================
loadrawblitt:
		move.b	#1,rawblitt(a5)
		bra.w	loadraw1

;=================================================================
;----- Läd eine Farbpalette nach den Prefseinstellungen ein ------
loadcolor:
		tst.b	lpal_iff(a5)
		bne.w	loadcoloriff
		tst.b	lpal_loadrgb(a5)
		bne.w	lc_loadrgb
		tst.b	lpal_pure(a5)
		bne.b	lc_datas
		rts

lc_datas:
		bsr.w	lc_allocmem
		bsr.w	lc_read
		tst.b	lpal_depth4(a5)
		bne.b	_de4
;lade pure 8-Bit
		move.w	anzcolor(a5),d7
		tst.w	d7
		beq.w	lc_noimage
		cmp.w	#'M8',d7
		bne.b	.noh8
		moveq	#64,d7
.noh8		cmp.w	#'M6',d7
		bne.b	.noh6
		moveq	#16,d7
.noh6
		move.l	colormem(a5),a0
		lea	farbtab4(a5),a1
		lea	farbtab8+4(a5),a2
	;	move.w	d7,(a2)+
	;	clr.w	(a2)+
		subq.l	#1,d7
.nc		moveq	#0,d1
		move.w	(a0)+,d1
		move.l	d1,d2
		swap	d1
		lsl.l	#8,d1
		move.l	d1,(a2)+
		lsl.l	#4,d2
		moveq	#0,d1
		move.b	(a0)+,d1
		move.l	d1,d3
		lsl.l	#8,d1
		swap	d1
		move.l	d1,(a2)+
		move.b	d3,d2
		moveq	#0,d1
		move.b	(a0)+,d1		
		move.l	d1,d3
		lsl.l	#8,d1
		swap	d1
		move.l	d1,(a2)+
		and.b	#$f0,d2
		lsr.b	#4,d3
		or.w	d3,d2
		move.w	d2,(a1)+
		dbra	d7,.nc
		clr.l	(a2)
		bra.w	lc_freemem
_de4
		move.w	anzcolor(a5),d7
		tst.w	d7
		beq.w	lc_noimage
		cmp.w	#'M8',d7
		bne.b	.noh8
		moveq	#64,d7
.noh8		cmp.w	#'M6',d7
		bne.b	.noh6
		moveq	#16,d7
.noh6
	;	lsr.l	#1,d7
		move.l	colormem(a5),a0
		lea	farbtab4(a5),a1
		lea	farbtab8(a5),a2
		move.w	d7,(a2)+
		clr.w	(a2)+
		subq.l	#1,d7
.nc1		moveq	#0,d0
		move.w	(a0)+,d0
		move.w	d0,(a1)+
		move.l	d0,d1
		and.w	#$f00,d1
		lsl.l	#4,d1
		swap	d1
		move.l	d1,(a2)+
		move.l	d0,d1
		and.b	#$f0,d1
		lsl.l	#8,d1
		swap	d1
		move.l	d1,(a2)+
		lsl.l	#4,d0
		lsl.l	#8,d0
		swap	d0
		move.l	d0,(a2)+
		dbra	d7,.nc1
		bra.w	lc_freemem

lc_loadrgb:
		tst.b	lpal_depth4(a5)
		bne.b	_de4
		bsr.b	lc_allocmem
		bsr.b	lc_read
		move.w	anzcolor(a5),d7
		tst.w	d7
		beq.w	lc_noimage
		cmp.w	#'M8',d7
		bne.b	.noh8
		moveq	#64,d7
.noh8		cmp.w	#'M6',d7
		bne.b	.noh6
		moveq	#16,d7
.noh6
		move.l	colormem(a5),a0
		addq.l	#4,a0
		lea	farbtab4(a5),a1
		lea	farbtab8+4(a5),a2
		subq.l	#1,d7
.nc		move.l	(a0)+,d0
		move.l	d0,(a2)+
		swap	d0
		lsr.l	#4,d0
		move.l	(a0)+,d1
		move.l	d1,(a2)+
		swap	d1
		lsr.l	#8,d1
		move.b	d1,d0
		move.l	(a0)+,d2
		move.l	d2,(a2)+
		and.b	#$f0,d0
		lsr.b	#4,d2
		or.b	d2,d0
		move.w	d0,(a1)+
		dbra	d7,.nc
		bra.b	lc_freemem

lc_allocmem:
		move.l	size(a5),d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,colormem(a5)
		rts
lc_read:
		moveq	#0,d0
		move.l	filehandle(a5),d1
		move.l	colormem(a5),d2
		move.l	size(a5),d3
		move.l	dosbase(a5),a6
		jmp	_LVORead(a6)
		
lc_freemem:	move.l	colormem(a5),a1
		cmp.l	#0,a1
		beq.b	.w
		move.l	4,a6
		jsr	_LVOFreeVec(a6)
		clr.l	colormem(a5)
.w:		rts

lc_noimage:
		lea	noimageload(pc),a4
		bsr.w	status
		moveq	#-1,d3
		rts

;================================================================
;------- LoadColor aus einem IFF-File
;================================================================
loadcoloriff:
		bsr.w	lci_read
		lea	iffpuffer(pc),a4
		cmp.l	#'FORM',(a4)
		bne.w	lci_notiff
		bsr.w	lci_read
		bsr.w	lci_read
		cmp.l	#'ILBM',(a4)
		bne.w	lci_notiff
		bsr.w	lci_read
		moveq	#0,d6
.nochmal:	cmp.l	#'CMAP',(a4)
		beq.b	lci_loadit
		bsr.w	lci_read
		move.l	(a4),d7
		lsr.l	#1,d7
		subq.l	#1,d7
.nch		bsr.w	lci_readword
		addq.l	#2,d6
		cmp.l	#20000,d6
		bhi.w	lci_notfound
		dbra	d7,.nch
		bsr.w	lci_read
		cmp.l	#'BODY',(a4)
		beq.w	lci_notfound
		bra.b	.nochmal
		
lci_loadit:
		bsr.w	lci_read
		move.l	(a4),d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,colormem(a5)
		beq.w	nomem

		move.l	filehandle(a5),d1
		move.l	colormem(a5),d2
		move.l	(a4),d3
		move.l	dosbase(a5),a6
		jsr	_LVORead(a6)
		
		move.w	anzcolor(a5),d7
		tst.w	d7
		beq.w	lc_noimage
		cmp.w	#'M8',d7
		bne.b	.noh8
		moveq	#64,d7
.noh8		cmp.w	#'M6',d7
		bne.b	.noh6
		moveq	#16,d7
.noh6
		subq.w	#1,d7
		move.l	colormem(a5),a0
		lea	farbtab4(a5),a1
		lea	farbtab8+4(a5),a2
.nc:		moveq	#0,d0
		move.b	(a0)+,d0
		move.l	d0,d1
		lsl.l	#8,d0
		swap	d0
		move.l	d0,(a2)+
		lsl.l	#4,d1
		moveq	#0,d0
		move.b	(a0)+,d0
		move.b	d0,d1
		lsl.l	#8,d0
		swap	d0
		move.l	d0,(a2)+
		moveq	#0,d0
		move.b	(a0)+,d0
		move.l	d0,d2
		lsl.l	#8,d0
		swap	d0
		move.l	d0,(a2)+
		lsr.b	#4,d2
		and.b	#$f0,d1
		or.b	d2,d1
		move.w	d1,(a1)+
		dbra	d7,.nc
		bra.w	lc_freemem

lci_notfound:
		lea	cmapchunkmsg(pc),a4
		bsr.w	status
		moveq	#-1,d3
		rts
lci_read:
		lea	iffpuffer(pc),a0
		move.l	a0,d2
		moveq	#4,d3
		move.l	filehandle(a5),d1
		move.l	dosbase(a5),a6
		jmp	_LVORead(a6)
lci_readword:
		lea	iffpuffer(pc),a0
		move.l	a0,d2
		moveq	#2,d3
		move.l	filehandle(a5),d1
		move.l	dosbase(a5),a6
		jmp	_LVORead(a6)
		
lci_notiff:
		rts

iffpuffer:	dc.l	0


;--------------------------------------------------------------------------
;-------- Preference für Palette ------------------------------------------
;--------------------------------------------------------------------------
lpal_gadsanz	=	4

lpal_Prefs:
		moveq	#0,d0
		lea	lpal_form(pc),a0
		move.b	lpal_formtag(a5),d0
		move.l	d0,(a0)

		lea	lpal_depth(pc),a0
		move.b	lpal_depthtag(a5),d0
		move.l	d0,(a0)

		move.l	#lpal_WindowTags,APG_WindowTagList(a5) ;Tag list for the Window
		move.l	#lpal_WinWG+4,APG_WGadgets(a5)	;addr. of WA_Gadgets Tag + 4
		move.l	#lpal_winSC+4,APG_WScreen(a5)	;addr. of WA_CustomScreen Tag + 4
		move.l	#lpal_window1,APG_WinWnd(a5)	;a point for the Window
		move.l	#lpal_Glist,APG_Glist(a5)		;a point for the Glist
		move.l	#lpal_NTypes,APG_NGads(a5)		;the NGads list
		move.l	#lpal_Gtypes,APG_GTypes(a5)		;the GTypes list
		move.l	#lpal_Gtags,APG_Gtags(a5)		;the Gtags list
		move.w	#lpal_gadsanz,APG_CNT(a5)			;the number of Gadgets
		move.l	#lpal_gadarray,APG_Gadgets(a5)	;a pointer for the Gadgetsarry, size=4*number of Gadgets
		move.l	APG_Scr(a5),APG_ScrBase(a5)	;the Screenpointer , stored in APG_Scr
	
		move.l	APG_CheckMainWinPos(a5),a6	;returns d0,d1 Pos
		jsr	(a6)

		add.w	#70,d0
		add.w	#100,d1
		
		move.w	d0,APG_WinLeft(a5)		;the left pos. of the Win
		move.w	d1,APG_WinTop(a5)		;the top pos. of the Win
		move.w	#204,APG_WinWidth(a5)		;the width of the Win
		move.w	#80,APG_WinHeight(a5)		;the height of the Win

		move.l	#lpal_WinL,APG_WinL(a5)		;addr. of WA_Left Tag 
		move.l	#lpal_WinT,APG_WinT(a5)		;addr. of WA_Top Tag
		move.l	#lpal_WinW,APG_WinW(a5)		;addr. of WA_Width Tag
		move.l	#lpal_WinH,APG_WinH(a5)		;addr. of WA_Height Tag

		move.l	APG_OpenWindow(a5),a6
		jsr	(a6)

		bsr.w	lpal_checkghost

		lea	lpal_Text0(pc),a2
		move.w	#1,APG_TNUM(a5)
		move.l	APG_Writetext(a5),a6
		jsr	(a6)

		move.l	lpal_window1(pc),a0
		moveq	#3,d0
		moveq	#17,d1
		move.w	#197,d2
		move.w	#35,d3
		moveq	#0,d4	;Invert ?
		
		bsr.w	drawframe

		lea	lpal_iff(a5),a0
		lea	datapuffer,a1
		moveq	#lpallen,d7
.np		move.b	(a0)+,(a1)+
		dbra	d7,.np

lpal_wait_:	move.l	lpal_window1(pc),a0
		move.l	APG_Wait(a5),a6
		jsr	(a6)				;Handle input

		cmp.l	#GADGETUP,d4
		beq.b	lpal_gads_
		cmp.l	#CLOSEWINDOW,d4
		beq.b	lpal_cancel
		bra.b	lpal_wait_

lpal_gads_:
		moveq	#0,d0
		move.w	38(a4),d0
		add.w	d0,d0
		lea	lpal_Jumptab(pc),a0
		move.w	(a0,d0.l),d0
		jmp	(a0,d0.l)


lpal_Jumptab:	dc.w	lpal_ok-lpal_Jumptab
		dc.w	lpal_cancel-lpal_Jumptab
		dc.w	lpal_format-lpal_jumptab
		dc.w	lpal_handledepth-lpal_jumptab
		
lpal_ok:
		bra.b	lpal_wech
lpal_cancel:
		bra.b	lpal_cancelwech

lpal_format:
		move.b	d5,lpal_formtag(a5)
		lea	lpal_form(pc),a0
		moveq	#2,d7
		lea	lpal_iff(a5),a1
		bra.b	lpal_setflags

lpal_handledepth:
		move.b	d5,lpal_depthtag(a5)
		lea	lpal_depth(pc),a0
		moveq	#1,d7
		lea	lpal_depth4(a5),a1
		bra.b	lpal_setflags

lpal_cancelwech:
		lea	lpal_iff(a5),a0
		lea	datapuffer,a1
		moveq	#lpallen,d7
.np		move.b	(a1)+,(a0)+
		dbra	d7,.np

lpal_wech:
		move.l	lpal_window1(pc),a0
		move.l	APG_Intuitionbase(a5),a6
		jmp	_LVOCloseWindow(a6)

lpal_setflags
		move.l	a1,a2
.nc:		clr.b	(a1)+
		dbra	d7,.nc

		ext.l	d5
		move.b	#1,(a2,d5.l)
		move.l	d5,(a0)
		bsr.b	lpal_checkghost
		bra.w	lpal_wait_
		
lpal_checkghost:

		moveq	#0,d0
		tst.b	lpal_iff(a5)
		beq.b	.w1
		moveq	#1,d0
.w1
		lea	sraw_ghost(pc),a3
		move.l	d0,4(a3)

		moveq	#lpal_GD_depth,d0

lpal_doghost:
		lea	lpal_gadarray(pc),a0
		lsl.l	#2,d0
		move.l	(a0,d0.l),a0
		move.l	lpal_window1(pc),a1
		sub.l	a2,a2
		lea	sraw_ghost(pc),a3
		move.l	gadbase(a5),a6
		jmp	_LVOGT_SetGadgetAttrsA(a6)


lpal_window1:	dc.l	0		;Enthält pointer vom eingenen Window
lpal_GList:	dc.l	0		
lpal_gadarray:	dcb.l	5,0

	even

;-----------------------------------------------------------------------------
lpal_WindowTags:
lpal_winL:	dc.l	WA_Left,0
lpal_winT:	dc.l	WA_Top,0
lpal_winW:	dc.l	WA_Width,0
lpal_winH:	dc.l	WA_Height,0
		dc.l	WA_IDCMP,CLOSEWINDOW!GADGETUP!VANILLAKEY!BUTTONIDCMP!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_CLOSEGADGET!WFLG_DEPTHGADGET!WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_SMART_REFRESH!WFLG_RMBTRAP
lpal_winWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title,lpal_winWTitle
lpal_winSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

lpal_WinWTitle:	dc.b	'Palette options',0
	even

lpal_GD_Ok	=	0
lpal_GD_Cancel	=	1
lpal_GD_format	=	2
lpal_GD_depth	= 	3

lpal_Gtypes:
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND


lpal_GTags:
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,lpal_formLabel
		dc.l	GTCY_ACTIVE
lpal_form:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,lpal_depthLabel
		dc.l	GTCY_ACTIVE
lpal_depth:	dc.l	0
		dc.l	TAG_DONE


lpal_formLabel:
		dc.l	lpal_formLab0
		dc.l	lpal_formLab1
		dc.l	lpal_formLab2
		dc.l	0

lpal_depthLabel:
		dc.l	lpal_depthLab0
		dc.l	lpal_depthLab1
		dc.l	0


lpal_depthLab0:	dc.b	'4 Bit',0
lpal_depthLab1:	dc.b	'8 Bit',0

lpal_formLab0:	dc.b	'IFF',0
lpal_formLab1:	dc.b	'LoadRGB',0
lpal_formLab2:	dc.b	'Pure',0

	even

lpal_NTypes:
		dc.w    5,60,80,13
		dc.l    oktext,0
		dc.w    lpal_GD_Ok
		dc.l    PLACETEXT_IN,0,0
		dc.w	118,60,80,13
		dc.l    canceltext,0
		dc.w    lpal_GD_Cancel
		dc.l    PLACETEXT_IN,0,0
		dc.w	10,32,90,13
		dc.l	lpal_formtext,0
		dc.w	lpal_GD_format
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	105,32,90,13
		dc.l	lpal_depthtext,0
		dc.w	lpal_GD_depth
		dc.l	PLACETEXT_ABOVE,0,0


lpal_formtext:	dc.b	'Type',0
lpal_depthtext:	dc.b	'Depth',0

		even

LPal_Text0:
		DC.B    2,0
		DC.B    RP_JAM1
		DC.B    0
		DC.W    100,10
		DC.L    0
		DC.L    lpal_Text
		DC.L    0

lpal_Text:	dc.b	'Load Format',0

	even

;-----------------------------------------------------------------
;-------- Schreibe Header für Linkobject
;-----------------------------------------------------------------
writelinkheader:
		movem.l	d0-a6,-(a7)
		lea	linkwinWindowTags(pc),a0
		move.l	a0,windowtaglist(a5)
		lea	linkwinWG+4(pc),a0
		move.l	a0,gadgets(a5)
		lea	linkwinSC+4(pc),a0
		move.l	a0,winscreen(a5)
		lea	linkwinWnd(a5),a0
		move.l	a0,window(a5)
		lea	linkwinGlist(a5),a0
		move.l	a0,Glist(a5)
		lea	linkwinNgads(pc),a0
		move.l	a0,NGads(a5)
		lea	linkwinGTypes(pc),a0
		move.l	a0,GTypes(a5)
		lea	linkwinGadgets(pc),a0
		move.l	a0,WinGadgets(a5)
		move.w	#linkwin_CNT,win_CNT(a5)
		lea	linkwinGtags(pc),a0
		move.l	a0,windowtags(a5)
		move.l	scr(a5),screenbase(a5)

		bsr.w	checkmainwinpos

		add.w	#linkwinLeft,d0
		add.w	#linkwinTop,d1

		move.w	d1,WinTop(a5)
		move.w	d0,WinLeft(a5)

		move.w	#linkwinWidth,WinWidth(a5)
		move.w	#linkwinHeight,WinHeight(a5)
		lea	linkWinL,a0
		move.l	a0,WinL(a5)
		lea	linkWinT,a0
		move.l	a0,WinT(a5)
		lea	linkWinW,a0
		move.l	a0,WinW(a5)
		lea	linkWinH,a0
		move.l	a0,WinH(a5)

		bsr.w	openwindowF

;		move.l	mainwinwnd(a5),a0
;		bsr	setwaitpointer

li_wait
		move.l	linkwinWnd(a5),a0
		jsr	wait

		cmp.l	#GADGETUP,d4
		beq.b	li_gads
		cmp.l	#VANILLAKEY,d4
		beq.b	li_keys
		bra.b	li_wait		;nichts wichtiges

li_gads:
		moveq	#0,d0
		move.w	38(a4),d0
		cmp.w	#GD_linkok,d0
		beq.b	li_writeheader
		cmp.w	#GD_linkcancel,d0
		beq.w	li_wech
		cmp.w	#GD_linkmem,d0
		beq.b	li_checkmemtype
		bra.b	li_wait

li_keys:
		cmp.w	#'d',d5
		beq.b	li_writeheader
		cmp.w	#'c',d5
		beq.w	li_wech
		cmp.w	#'t',d5
		bne.b	li_wait
		move.l	limem(pc),d1
		addq.l	#1,d1
		cmp.l	#3,d1
		blo.b	.kl
		moveq	#0,d1
.kl:
		move.l	d1,limem
		move.l	d1,linkmemtype(a5)
		move.l	#GD_linkmem,d0
		lea	linkwinGadgets(pc),a0
		move.l	linkwinWnd(a5),a1
		bsr.w	setcyle	
		bra.b	li_wait		

li_checkmemtype:
		ext.l	d5
		move.l	d5,linkmemtype(a5)
		move.l	d5,limem
		bra.w	li_wait

li_writeheader:
		bsr.w	li_winwech

		move.l	#GD_linkextdef,d0
		lsl.l	#2,d0
		lea	linkwinGadgets(pc),a0
		move.l	(a0,d0.w),a0
		move.l	gg_SpecialInfo(a0),a0
		move.w	si_NumChars(a0),d7	;Anzahl der Zeichen
		bne.b	.sizeok
		lea	extnotdefined(pc),a4
		bsr.w	status		
		movem.l	(a7)+,d0-a6
		moveq	#-1,d7
		rts
.sizeok:
		move.l	(a0),a0		;String
		
		subq.w	#1,d7
		move.l	d7,linknumchars(a5)

		lea	extdefstring,a1
		move.l	a1,extstring
.ns:
		move.b	(a0)+,(a1)+
		dbra	d7,.ns
		clr.b	(a1)

		lea	linkheaderpuffer,a0
		move.l	#$000003e7,(a0)+
		clr.l	(a0)+
		move.l	#$000003e8,(a0)+
		move.l	#2,(a0)+
		move.l	#'DATA',(a0)+
		move.l	#$53454300,(a0)+
		move.l	linkmemtype(a5),d0
		lsl.l	#6,d0		
		lsl.l	#8,d0
		move.w	d0,(a0)+
		move.w	#$3ea,(a0)+
		move.l	linkobjektsize(a5),d0
		addq.l	#3,d0
		lsr.l	#2,d0		;brushlänge in Langwords
		move.l	d0,(a0)
		move.l	d0,linkmemsize(a5)
		
		move.l	filehandle(a5),d1
		move.l	#linkheaderpuffer,d2
		moveq	#32,d3
		move.l	dosbase(a5),a6
		jsr	_LVOWrite(a6)
		cmp.l	#-1,d0
		beq.b	li_winwech
		movem.l	(a7)+,d0-a6
		moveq	#0,d7
		rts
li_wech:
		bsr.b	li_winwech
		lea	linksavemsg,a4
		bsr.w	status
		movem.l	(a7)+,d0-a6
		moveq	#-1,d7
		rts
li_winwech:
;		move.l	mainwinwnd(a5),a0
;		bsr	clearwaitpointer

		lea	linkwinWnd(a5),a0
		move.l	a0,window(a5)
		lea	linkwinGlist(a5),a0
		move.l	a0,Glist(a5)
		bra.w	gt_CloseWindow

;-----------------------------------------------------------------
;-------- Schreibe Endhunks für Linkobject
;-----------------------------------------------------------------
writelinkbottom:
		lea	linkheaderpuffer,a0
		move.l	a0,-(a7)
		move.l	linkmemsize(a5),d0
		lsl.l	#2,d0
		sub.l	linkobjektsize(a5),d0
		beq.b	.sizeok
		subq.l	#1,d0
.nn:		move.b	#0,(a0)+
		dbra	d0,.nn
.sizeok:
		move.l	#$000003ef,(a0)+
		move.w	#$0100,(a0)+
		move.l	linknumchars(a5),d0
		addq.l	#4,d0
		lsr.l	#2,d0
		move.w	d0,(a0)+
		lea	extdefstring,a1
		move.l	linknumchars(a5),d1
;		subq.l	#1,d1
.ne		move.b	(a1)+,(a0)+
		dbra	d1,.ne
		lsl.l	#2,d0
		sub.l	linknumchars(a5),d0
		beq.b	.chok
		subq.l	#1,d0
		beq.b	.chok
		subq.l	#1,d0
.nc:		move.b	#0,(a0)+
		dbra	d0,.nc
.chok:
		move.l	#0,(a0)+
		move.l	#0,(a0)+
		move.l	#$000003f2,(a0)+
		move.l	(a7)+,d0
		sub.l	d0,a0
		move.l	a0,d3
		move.l	filehandle(a5),d1
		move.l	d0,d2
		move.l	dosbase(a5),a6
		jmp	_LVOWrite(a6)
		
;***************************************************************************
;*-------------------------- Save Raw-Format ------------------------------*
;***************************************************************************
saverawmsg:	dc.b	'Save raw bitplane data!',0
	even
saveraw:
		tst.l	picmem(a5)
		bne.b	.picok
		moveq	#APSE_NOBITMAP,d3
		rts

;Prefs Kopieren für Source Engine
.picok:
		lea	SRAW_asmsource(a5),a0
		lea	sasmsource(a5),a1
		move.l	(a0)+,(a1)+
		move.b	(a0),(a1)				

		lea	SRAW_byte(a5),a0
		lea	databyte(a5),a1
		move.w	(a0)+,(a1)+
		move.b	(a0),(a1)		

		moveq	#0,d0
		move.b	sraw_indents(a5),d0
		move.l	d0,data_indents(a5)

		moveq	#0,d0
		move.b	sraw_entri(a5),d0
		move.l	d0,data_datasPL(a5)
	
		move.b	SRAW_dtabs(a5),data_tab(a5)

;-------------------------------------------------------------------------
saveraw1:
		tst.w	cutflag(a5)
		bne.b	brushok
		move.w	#0,xbrush1(a5)		;Es soll das ganze 
		move.w	#0,ybrush1(a5)		;Pic abgesaved werden
		move.w	breite(a5),xbrush2(a5)
		move.w	hoehe(a5),ybrush2(a5)	

brushok:
		bsr.l	openprocess
;-------------------------------------------------------------------
		move.w	APG_ybrush2(a5),d0
		sub.w	APG_ybrush1(a5),d0

		lea	saverawmsg(pc),a1
		bsr.l	initprocess
;-------------------------------------------------------------------

		tst.b	SRAW_outsource(a5)
		beq.b	.nostruc

		tst.b	SRAW_pimage(a5)
		beq.b	.nostruc
		bsr.w	saveimagestruc	;save eine ImageStruc vor den Brush
.nostruc:
		moveq	#0,d1
		moveq	#0,d0
		move.w	xbrush1(a5),d1
		move.w	xbrush2(a5),d0
		sub.w	d1,d0		;x2-x1
		divu	#16,d0
		swap	d0
		tst.w	d0
		beq.b	norest
		add.l	#$10000,d0
norest:
		swap	d0
		ext.l	d0

	tst.b	SRAW_blitnone(a5)
	bne.b	.noadd
	addq.l	#1,d0		;ein Word mehr für blittword
.noadd:
		move.w	d0,brushword(a5)

		moveq	#0,d1
		moveq	#0,d2
		move.w	ybrush1(a5),d1
		move.w	ybrush2(a5),d2
		sub.w	d1,d2
		add.w	d0,d0		;Brushword in Byte
		tst.w	d0
		bne.b	.ok
		moveq	#0,d2		;es wurde mit null multipliziert
		bra.b	.weiter
.ok:

		mulu.l	d0,d2		;Oneplane Size

.weiter
		tst.b	SRAW_pmask(a5)
		beq.b	.moreplanes
		tst.b	SRAW_pinter(a5)	;Interleaved (Blitter)
		bne.b	.moreplanes
		move.l	d2,brushmemsize(a5)
		bra.b	.goon
.moreplanes:
		moveq	#0,d0
		move.b	planes(a5),d0

		mulu.l	d2,d0		;Gesamtspeicher für Brush

		move.l	d0,brushmemsize(a5)

		tst.b	SRAW_outsource(a5)
		beq.b	.goon
		st	full(a5)
		bra.b	savefull

;allociere PufferSpeicher

.goon:
		tst.b	SRAW_outlink(a5)   ;soll File als LinkObjekt gespeichert
		beq.b	.nolink		   ;werden

		move.l	brushmemsize(a5),linkobjektsize(a5)
		bsr.w	writelinkheader

		tst.l	d7
		beq.b	.nolink
		moveq	#-1,d3
		rts
.nolink:
		st	full(a5)
		move.l	4,a6
		move.l	brushmemsize(a5),d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		jsr	_LVOAllocVec(a6)
		move.l	d0,brushpuffer(a5)
		bne.b	savefull	;Puffere ganzes Pic

;Save Lineweise ab

		clr.b	full(a5)
		moveq	#MEMF_ANY,d1
		move.l	4,a6
		move.w	brushword(a5),d0
		add.w	d0,d0	;Bytes
		move.l	d0,brushmemsize(a5)
		jsr	_LVOAllocVec(a6)
		move.l	d0,brushpuffer(a5)
		beq.w	nomem

savefull:
		move.b	planes(a5),merk(a5)
		move.l	picmem(a5),a0
		move.l	brushpuffer(a5),a4
		tst.b	SRAW_outsource(a5)
		beq.b	.w
		lea	datapuffer,a4
		move.w	#250,datazaehler(a5)
		
		bsr.w	calclinemem	;berechne puffer für datasave
		tst.l	d0
		bne.w	nomem
		move.b	#1,newlinemerk(a5)
.w
		tst.b	SRAW_pmask(a5)
		bne.w	ma_savego		;save jetzt als Mask
		
		sub.l	a1,a1	;Planeoffset
		tst.b	ham8(a5)
		beq.b	nplane
				;bei Ham8 sind die ersten 2 Planes die
				;modifyplanes
		move.l	oneplanesize(a5),d0
		move.l	d0,a1
		lsl.l	#2,d0
		add.l	a1,a1
		add.l	d0,a1	;oneplanesize * &
nplane:
		bsr.w	checkfirstword
					;geschoben werden muß

		move.b	Planes(a5),APG_Free12(a5)
raw_newline:
		subq.b	#1,APG_Free12(a5)
		bne.b	.nixprocess
		bsr.l	doprocess
		tst.l	d0
		bne.b	.w

		move.l	brushpuffer(a5),d0
		beq.b	.nm
		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
.nm:
		moveq	#APSE_ABORT,d3
		rts
.w
		move.b	Planes(a5),APG_Free12(a5)

.nixprocess:
	tst.b	SRAW_blitnone(a5)
	bne.b	.noaddleft
	subq.w	#1,d7
	tst.b	SRAW_blitleft(a5)
	beq.b	.noaddleft
	move.w	#0,(a4)+		;Setzte linkes Blittword

	tst.b	SRAW_outsource(a5)
	beq.b	.noaddleft
	sub.w	#1,datazaehler(a5)
	bne.b	.noaddleft

	bsr.w	da_savedatas

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
.noaddleft:
		move.l	firstword(a5),d0
		add.l	d0,d0		;in Byte
		move.l	picmem(a5),a0
		add.l	d0,a0
		add.l	d5,a0		;Y-Offset
		add.l	a1,a0		;Planeoffset
		
		move.l	bitshift(a5),d6
newword:
		move.l	(a0),d0
		lsl.l	d6,d0
		swap	d0
		add.l	#16,d4
		move.w	xbrush2(a5),d1
		cmp.w	d4,d1
		bhs.b	.pixok
		move.w	d4,d3
		sub.w	d1,d3
		lsr.w	d3,d0
		lsl.w	d3,d0	;zuviele Bits löschen
.pixok:
		move.w	d0,(a4)+
	tst.b	SRAW_outsource(a5)
	beq.b	.w
		sub.w	#1,datazaehler(a5)
		bne.b	.w

		bsr.w	da_savedatas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


.w:		addq.l	#2,a0
		dbra	d7,newword

	tst.b	SRAW_blitright(a5)
	beq.b	.norightadd
	move.w	#0,(a4)+
	tst.b	SRAW_outsource(a5)
	beq.b	.norightadd
	sub.w	#1,datazaehler(a5)
	bne.b	.norightadd

	bsr.w	da_savedatas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.norightadd:
		tst.b	full(a5)	;Soll Pic ganz Gepuffert werden
		bne.b	noline

		bsr.w	saveline

		move.l	brushpuffer(a5),a4
noline:
		move.w	xbrush1(a5),d4
		move.w	brushword(a5),d7
		subq.w	#1,d7

		tst.b	SRAW_pinter(a5)
		beq.b	.noblitt

		subq.b	#1,merk(a5)
		bne.b	.noplaneend

		move.b	planes(a5),merk(a5)
		add.l	bytebreite(a5),d5
		sub.l	a1,a1

		tst.b	ham8(a5)
		beq.b	.noham8
		move.l	oneplanesize(a5),d0 ;bei Ham8 sind die ersten 2 Planes die
		move.l	d0,a1			;modifyplanes
		lsl.l	#2,d0
		add.l	a1,a1
		add.l	d0,a1	;oneplanesize * &

.noham8		move.w	ybrush2(a5),d0
		addq.w	#1,a2
		cmp.w	d0,a2
		blo.w	raw_newline
		bra.b	endraw
.noplaneend:
		add.l	oneplanesize(a5),a1

		tst.b	ham8(a5)
		beq.b	.noh
		cmp.b	#6,merk(a5)
		bne.b	.noh
		sub.l	a1,a1
.noh:
		bra.w	raw_newline
.noblitt:
		move.l	bytebreite(a5),d0
		add.l	d0,d5

		move.w	ybrush2(a5),d0
		addq.w	#1,a2
		cmp.w	d0,a2
		blo.w	raw_newline
	
		subq.b	#1,merk(a5)
		beq.b	endraw
		add.l	oneplanesize(a5),a1

		tst.b	ham8(a5)
		beq.b	.noham
		cmp.b	#6,merk(a5)
		bne.b	.noham
		sub.l	a1,a1

.noham:		bra.w	nplane

endraw:
		tst.b	full(a5)
		beq.b	.nosave
		tst.b	SRAW_outsource(a5)
		beq.b	.s
		bsr.w	da_savedatas
		tst.b	saveflag(a5)
		beq.b	.ns
		move.l	linememmerk(a5),a0
		move.b	#1,lastsave(a5)
		bsr.w	da_saveline
.ns
		bsr.w	da_makeend
		bsr.w	da_memwech
		bra.b	.nolink
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.s:		move.l	filehandle(a5),d1
		move.l	brushpuffer(a5),d2
		move.l	brushmemsize(a5),d3
		move.l	dosbase(a5),a6
		jsr	_LVOWrite(a6)	;Save volles Raw-Pic ab
		moveq	#0,d3
.nosave:
		move.l	brushpuffer(a5),a1
		cmp.l	#0,a1
		beq.b	.wl
		move.l	4,a6
		jsr	_LVOFreeVec(a6)
		clr.l	brushpuffer(a5)	

.wl:
		tst.b	SRAW_outlink(a5)
		beq.b	.nolink
		bsr.w	writelinkbottom
.nolink:
		bsr.w	da_memwech

;schreibe comment

		lea	srawname(pc),a0
		tst.b	SRAW_outsource(a5)
		bne	.ss
		lea	srawname1(pc),a0
		tst.b	SRAW_outlink(a5)
		bne	.ss
		lea	3(a0),a0
.ss
		moveq	#0,d0
		move.w	APG_xbrush2(a5),d0
		sub.w	APG_xbrush1(a5),d0
		moveq	#0,d1
		move.w	APG_ybrush2(a5),d1
		sub.w	APG_ybrush1(a5),d1
		moveq	#0,d2
		move.b	APG_Planes(a5),d2

		jsr	APR_SetComment(a5)

		move.b	#'c',d2		;autocolorsave erlauben
		rts

srawname:	dc.b	'SRC RAW',0
srawname1:	dc.b	'LI RAW',0

		even

checkfirstword:
		moveq	#0,d0
		moveq	#0,d7
		move.w	brushword(a5),d7
		subq.w	#1,d7
		
		move.w	xbrush1(a5),d4
		move.w	ybrush1(a5),d5
		move.w	d5,a2
		move.l	bytebreite(a5),d3
		mulu	d3,d5    

		moveq	#0,d1
		moveq	#0,d2
		move.w	d4,d1

		move.w	d1,d2	 
		lsr.l	#4,d1	;/16
		move.l	d1,firstword(a5);erstes word ab dem gelesenwird
		lsl.l	#4,d1
		sub.l	d1,d2
		move.l	d2,bitshift(a5)	;anzahl der Bits um die nach links
		rts

;-----------------------------------------------------------------------
; ----------------- Save eine Image Strucktur ------------------------
;-----------------------------------------------------------------------
saveimagestruc:
		lea	colorpuffer2,a4	;Savepuffer
		tst.b	sasmsource(a5)
		bne.b	sis_asm
		tst.b	sesource(a5)
		bne.w	sis_e
		tst.b	scsource(a5)
		bne.w	sis_c
		rts

;Save ASM Code
sis_asm:
		lea	sis_imagename(pc),a0
		move.b	#'I',(a0)
		lea	sis_image(pc),a0
		move.b	#'I',(a0)

		lea	sis_image(pc),a1
		moveq	#6,d7
.nc2:		move.b	(a1)+,(a4)+
		dbra	d7,.nc2

		lea	sis_lenght(pc),a3
		move.b	#'w',(a3)
		bsr.w	sis_newline
	;	move.b	#'$',(a4)+
	;	move.w	xbrush1(a5),d0
	;	bsr.w	hexascii
	;	bsr.w	sis_copy
		move.b	#'0',(a4)+

		move.b	#',',(a4)+
	;	move.b	#'$',(a4)+
	;	move.w	ybrush1(a5),d0
	;	bsr.w	hexascii
	;	bsr.w	sis_copy
		move.b	#'0',(a4)+

		move.b	#10,(a4)+
		bsr.w	sis_newline

		bsr.w	sis_copyxy

		move.b	#10,(a4)+

		move.b	#'l',(a3)
		bsr.w	sis_newline
		lea	sis_imagename(pc),a1
		moveq	#8,d7
.nc:		move.b	(a1)+,(a4)+
		dbra	d7,.nc
		move.b	#10,(a4)+

		move.b	#'b',(a3)
		bsr.w	sis_newline
		move.b	#'$',(a4)+
		moveq	#0,d1
		moveq	#1,d0
		moveq	#0,d1
		move.b	planes(a5),d1
		lsl.w	d1,d0
		subq.w	#1,d0
		bsr.w	Hexascii
		lea	zpuff+6,a1
		move.b	(a1)+,(a4)+
		move.b	(a1)+,(a4)+
		move.b	#',',(a4)+
		move.b	#'$',(a4)+		
		move.b	#'0',(a4)+
		move.b	#'0',(a4)+
		move.b	#10,(a4)+
		
		move.b	#'l',(a3)
		bsr.w	sis_newline
		move.b	#'0',(a4)+
		move.b	#10,(a4)+
		move.b	#10,(a4)+

sis_enda:
		lea	sis_imagename(pc),a1
		moveq	#9,d7
.nc1:		move.b	(a1)+,(a4)+
		dbra	d7,.nc1
		move.b	#10,(a4)+

		bra.w	sis_write

;------------------------------------------------
sis_e:
		lea	sis_imagename(pc),a0
		move.b	#'i',(a0)
		lea	sis_image(pc),a0
		move.b	#'i',(a0)

		move.b	#10,(a4)+

		move.b	#'D',(a4)+
		move.b	#'E',(a4)+
		move.b	#'F',(a4)+
		move.b	#' ',(a4)+

		lea	sis_image(pc),a1
		moveq	#5,d7
.nc:		move.b	(a1)+,(a4)+
		dbra	d7,.nc

		move.b	#'=',(a4)+
		move.b	#'[',(a4)+
		move.b	#'0',(a4)+				
		move.b	#',',(a4)+
		move.b	#'0',(a4)+				
		move.b	#',',(a4)+

		bsr.w	sis_copyxy

		move.b	#',',(a4)+
		move.b	#'{',(a4)+
		lea	sis_imagename(pc),a1
		moveq	#8,d7
.nc1:		move.b	(a1)+,(a4)+
		dbra	d7,.nc1
		
		move.b	#'}',(a4)+
		move.b	#',',(a4)+

		move.b	#'$',(a4)+
		moveq	#0,d1
		moveq	#1,d0
		moveq	#0,d1
		move.b	planes(a5),d1
		lsl.w	d1,d0
		subq.w	#1,d0
		bsr.w	Hexascii
		lea	zpuff+6,a1
		move.b	(a1)+,(a4)+
		move.b	(a1)+,(a4)+
		move.b	#',',(a4)+		
		move.b	#'0',(a4)+		
		move.b	#',',(a4)+		
		move.b	#'0',(a4)+		
		move.b	#']',(a4)+
		move.b	#':',(a4)+
				
		lea	sis_image(pc),a1
		moveq	#4,d7
.nc2:		move.b	(a1)+,(a4)+
		dbra	d7,.nc2

		move.b	#10,(a4)+
		move.b	#10,(a4)+

		bra.w	sis_enda

;---------------------------------------------------------------------
sis_c:
		move.b	#10,(a4)+
		lea	sis_struc(pc),a0
		moveq	#22,d7
.nc:		move.b	(a0)+,(a4)+
		dbra	d7,.nc
		move.b	#'{',(a4)+
		move.b	#10,(a4)+

		bsr.w	sis_newline
		
		lea	sis_null(pc),a0
		moveq	#8,d7
.nc1:		move.b	(a0)+,(a4)+
		dbra	d7,.nc1		

		bsr.w	sis_newline

		move.b	#'0',(a4)+
		move.b	#'x',(a4)+
		move.w	xbrush1(a5),d1
		move.w	xbrush2(a5),d0
		sub.w	d1,d0		;x2-x1
		bsr.w	Hexascii
		bsr.w	sis_copy
		move.b	#',',(a4)+
		move.b	#'0',(a4)+
		move.b	#'x',(a4)+
		move.w	ybrush1(a5),d1
		move.w	ybrush2(a5),d0
		sub.w	d1,d0		;x2-x1
		bsr.w	Hexascii
		bsr.w	sis_copy
		move.b	#',',(a4)+
		move.b	#'0',(a4)+
		move.b	#'x',(a4)+
		moveq	#0,d0
		move.b	planes(a5),d0
		bsr.w	hexascii
		bsr.w	sis_copy
		move.b	#',',(a4)+
		move.b	#10,(a4)+

		bsr.w	sis_newline
						
 		move.b	#'(',(a4)+
		tst.b	databyte(a5)
		beq.b	.nobyte
		lea	da_ubyte(pc),a0
.nobyte:	tst.b	dataword(a5)
		beq.b	.noword
		lea	da_ushort(pc),a0
.noword:	tst.b	datalongword(a5)
		beq.b	.nolong
		lea	da_ulong(pc),a0
.nolong:
		move	#4,d7
.nc2:		move.b	(a0)+,(a4)+
		dbra	d7,.nc2

		lea	sis_data(pc),a0
		moveq	#8,d7
.nc3:		move.b	(a0)+,(a4)+
		dbra	d7,.nc3

		bsr.w	sis_newline

		move.b	#'0',(a4)+
		move.b	#'x',(a4)+
		moveq	#0,d1
		moveq	#1,d0
		moveq	#0,d1
		move.b	planes(a5),d1
		lsl.w	d1,d0
		subq.w	#1,d0
		bsr.w	Hexascii
		lea	zpuff+6,a1
		move.b	(a1)+,(a4)+
		move.b	(a1)+,(a4)+

		lea	sis_null+3(pc),a0
		moveq	#5,d7
.nc4:		move.b	(a0)+,(a4)+
		dbra	d7,.nc4

		bsr.w	sis_newline

		lea	sis_nul(pc),a0
		moveq	#8,d7
.nc5:		move.b	(a0)+,(a4)+
		dbra	d7,.nc5

		bra.b	sis_write

sis_imagename:	dc.b	'Imagedata:',0
sis_image:	dc.b	'Image:',10
sis_struc:	dc.b	'struct Image myimage =',10
sis_null:	dc.b	'0x0,0x0,',10
sis_data:	dc.b	' *)data,',10
sis_nul:	dc.b	'NULL',10,'};',10,10

	even
;-----------------------------------------------------------------------
sis_write:
		move.l	a4,d3
		lea	colorpuffer2,a0	;Savepuffer
		sub.l	a0,d3
		move.l	filehandle(a5),d1
		move.l	a0,d2
		move.l	dosbase(a5),a6
		jmp	_LVOWrite(a6)
		
sis_copy:
		lea	zpuff+4,a1
		move.b	(a1)+,(a4)+
		move.b	(a1)+,(a4)+
		move.b	(a1)+,(a4)+
		move.b	(a1)+,(a4)+
		rts

sis_copyxy:
		move.b	#'$',(a4)+
		move.w	xbrush1(a5),d1
		move.w	xbrush2(a5),d0
		sub.w	d1,d0		;x2-x1
		bsr.w	Hexascii
		bsr.b	sis_copy
		move.b	#',',(a4)+
		move.b	#'$',(a4)+
		move.w	ybrush1(a5),d1
		move.w	ybrush2(a5),d0
		sub.w	d1,d0
		bsr.w	Hexascii
		bsr.b	sis_copy
		move.b	#',',(a4)+
		move.b	#'$',(a4)+
		moveq	#0,d0
		move.b	planes(a5),d0
		bsr.w	hexascii
		bra.b	sis_copy

sis_newline:
		move.l	data_indents(a5),d0
		beq.b	.notab
		subq.l	#1,d0
		moveq	#9,d1
		tst.b	data_tab(a5)
		bne.b	.ok
		moveq	#32,d1
.ok:
		move.b	d1,(a4)+
		dbra	d0,.ok
.notab:		tst.b	scsource(a5)
		bne.b	.w
		tst.b	spascal(a5)
		bne.b	.w
		tst.b	sesource(a5)
		bne.b	sis_makeEandBasic
		tst.b	sbasic(a5)
		bne.b	sis_makeEandBasic
		move.b	#'d',(a4)+
		move.b	#'c',(a4)+
		move.b	#'.',(a4)+
		move.b	sis_lenght(pc),(a4)+
		move.b	#9,(a4)+
.w
		rts

sis_makeEandBasic:
		tst.b	sbasic(a5)
		beq.b	.nba
		lea	da_data(pc),a2
		bra.b	.nb
.nba:		tst.b	datalongword(a5)
		beq.b	.nlw
		lea	da_long(pc),a2
.nlw:
		tst.b	dataword(a5)
		beq.b	.nw
		lea	da_int(pc),a2
.nw:
		tst.b	databyte(a5)
		beq.b	.nb
		lea	da_char(pc),a2
.nb:
		moveq	#3,d1
.nc:		move.b	(a2)+,(a4)+
		dbra	d1,.nc
		move.b	#9,(a4)+
		rts

sis_lenght:	dc.b	'w',0

;***************************************************************************
;*-------------------------- Save Mask ------------------------------------*
;***************************************************************************
maskcolorreqText: dc.b	'Enter Mask-Color !',0
	even
tags:
		dc.l	RTGL_min,0
		dc.l	RTGL_max
ma_max:		dc.l	0
		dc.l	$80000007
ma_screen:	dc.l	0
		dc.l	_rt_window
ma_window:	dc.l	0
		dc.l	RT_REQPOS
		dc.l	2			;Centriert
	;	dc.l	RTGL_min,0
	;	dc.l	RTGL_max,256
		dc.l	TAG_DONE

savemask:
ma_savego:
		tst.b	sraw_amask(a5)
		beq.b	.nomaskcolor

;--- Frage nach Mask-Color mit Reqtools ---

		move.l	scr(a5),ma_screen
		move.l	mainwinWnd(a5),ma_window
		lea	ma_max(pc),a0
		moveq	#0,d0
		move.w	anzcolor(a5),d0
		subq.w	#1,d0
		move.l	d0,(a0)
		
		lea	numpuffer(a5),a1
		lea	maskcolorreqText(pc),a2	
		sub.l	a3,a3
		lea	tags(pc),a0
		move.l	reqtbase(a5),a6
		jsr	_LVORTGetLongA(a6)

		tst.l	d0
		bne.b	.nomaskcolor
		lea	breakmsg(pc),a4
		bsr.w	status
		moveq	#-1,d3
		rts

.nomaskcolor:
		sub.l	a1,a1	;Planeoffset
ma_nplane:
		moveq	#0,d0
		moveq	#0,d7
		move.w	brushword(a5),d7
		subq.w	#1,d7
		
		move.w	xbrush1(a5),d4
		move.w	ybrush1(a5),d5
		move.w	d5,a2
		move.l	bytebreite(a5),d3
		mulu	d3,d5    

		moveq	#0,d1
		moveq	#0,d2
		move.w	d4,d1

		move.w	d1,d2	 
		lsr.l	#4,d1	;/16
		move.l	d1,firstword(a5);erstes word ab dem gelesenwird
		lsl.l	#4,d1
		sub.l	d1,d2
		move.l	d2,bitshift(a5)	;anzahl der Bits um die nach links
					;geschoben werden muß

		move.b	planes(a5),merk1(a5)
		move.b	Planes(a5),APG_Free12(a5)

ma_newline:
		tst.b	SRAW_pinter(a5)
		beq.b	.noblitt

		subq.b	#1,APG_Free12(a5)
		bne.b	.nixprocess
		move.b	Planes(a5),APG_Free12(a5)
.noblitt:
		bsr.l	doprocess
		tst.l	d0
		bne.b	.nixprocess

		move.l	brushpuffer(a5),d0
		beq.b	.nm
		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
.nm:
		moveq	#APSE_ABORT,d3
		rts
.nixprocess:

	tst.b	SRAW_blitnone(a5)
	bne.b	.noaddleft
	subq.w	#1,d7
	tst.b	SRAW_blitleft(a5)
	beq.b	.noaddleft
	move.w	#0,(a4)+		;Setzte linkes Blittword
	tst.b	SRAW_outsource(a5)
	beq.b	.noaddleft
	sub.w	#1,datazaehler(a5)
	bne.b	.noaddleft

	bsr.w	da_savedatas

.noaddleft:
		move.b	planes(a5),merk(a5)
		move.l	numpuffer(a5),numpuffer1(a5)
ma_save:
		move.l	bitshift(a5),d6

		move.l	picmem(a5),a3

ma_new:		add.l	#16,d4
		moveq	#0,d2
		tst.b	sraw_amask(a5)
		beq.b	ma_newword
		tst.l	numpuffer(a5)
		beq.b	ma_newword
		moveq	#-1,d2
		
ma_newword:
		move.l	firstword(a5),d0
		add.l	d0,d0		;in Byte
		move.l	a3,a0
		add.l	d0,a0
		add.l	d5,a0		;Y-Offset
		add.l	a1,a0		;Planeoffset

		move.l	(a0),d0
		lsl.l	d6,d0
		swap	d0
		move.w	xbrush2(a5),d1
		cmp.w	d4,d1
		bhs.b	.pixok
		move.w	d4,d3
		sub.w	d1,d3
		lsr.w	d3,d0
		lsl.w	d3,d0	;zuviele Bits löschen
.pixok:
		tst.b	sraw_amask(a5)
		beq.b	.noask
		move.l	numpuffer1(a5),d1	;check ob für Plane
		lsr.l	#1,d1			;gesetzt werden darf
		bcs.b	.set
		not.w	d0
.set:		and.w	d0,d2

		move.l	d1,numpuffer1(a5)
		bra.b	.weiter
.noask:
		or.w	d0,d2
.weiter:
		add.l	oneplanesize(a5),a1
		subq.b	#1,merk(a5)
		bne.b	ma_newword

		move.w	d2,(a4)+

	tst.b	SRAW_outsource(a5)
	beq.b	.ns
	sub.w	#1,datazaehler(a5)
	bne.b	.ns
	bsr.w	da_savedatas

.ns:
		move.b	planes(a5),merk(a5)
		move.l	numpuffer(a5),numpuffer1(a5)
		sub.l	a1,a1
		addq.l	#2,a3
		dbra	d7,ma_new

		tst.b	SRAW_blitright(a5)
		beq.b	.norightadd
	move.w	#0,(a4)+
	tst.b	SRAW_outsource(a5)
	beq.b	.norightadd
	sub.w	#1,datazaehler(a5)
	bne.b	.norightadd
	bsr.w	da_savedatas

.norightadd:
		tst.b	full(a5)	;Soll Pic ganz Gepuffert werden
		bne.b	ma_noline

		bsr.w	saveline

		move.l	brushpuffer(a5),a4
ma_noline:
		move.w	xbrush1(a5),d4
		move.w	brushword(a5),d7
		subq.w	#1,d7

		tst.b	SRAW_pinter(a5)
		beq.b	.noblitt
		subq.b	#1,merk1(a5)
		beq.b	.noblitt
		sub.l	a1,a1
		bra.w	ma_newline
.noblitt:
		move.b	planes(a5),merk1(a5)

		add.l	bytebreite(a5),d5
		sub.l	a1,a1
		move.w	ybrush2(a5),d0
		addq.w	#1,a2
		cmp.w	d0,a2
		blo.w	ma_newline
		bra.w	endraw
                                                     
;--------------------------------------------------------------------------
promptcheck:
		moveq	#0,d3			
		tst.b	spr_cwprompt(a5)		;gecrackt !!!!!!!!
		beq.b	.ok
		moveq	#0,d0
		move.b	check2(a5),d0
		add.w	finalcheck(a5),d0
		cmp.w	#323,d0
		beq.b	.ok			;gecrackt !!!!!!!!
		move.l	#_LVOrtEZRequestA*2,d0
		asr.l	#1,d0
		lea	nopromptmsg+2410(pc),a1
		lea	key1msg-5210(pc),a2
		sub.l	a3,a3
		sub.l	a4,a4
		lea	tagitemliste1(pc),a0
		move.l	reqtbase(a5),a6
		lea	-2410(a1),a1
		lea	5210(a2),a2
		jsr	(a6,d0.l)
		moveq	#-1,d3
.ok		rts


;-----------------------------------------------------------------------
;----------------- Prefs für Save RAW ---------------------------------
;---------------------------------------------------------------------
SRAW_gadsanz	=	13

SRAW_Prefs:

;----------------------------------------------------------------------------

		lea	sraw_outtag(pc),a0
		moveq	#0,d0
		move.b	sraw_outtag_(a5),d0
		move.l	d0,(a0)

		lea	sraw_blittag(pc),a0
		moveq	#0,d0
		move.b	sraw_blittag_(a5),d0
		move.l	d0,(a0)

		lea	SRAW_imagetag(pc),a0
		move.b	SRAW_pimage(a5),d0
		move.l	d0,(a0)

		lea	SRAW_masktag(pc),a0
		move.b	SRAW_pmask(a5),d0
		move.l	d0,(a0)

		lea	SRAW_intertag(pc),a0
		move.b	SRAW_pinter(a5),d0
		move.l	d0,(a0)
		
		lea	SRAW_lang(pc),a0
		move.b	sraw_sourcetag(a5),d0
		move.l	d0,(a0)
		
		lea	SRAW_width(pc),a0
		move.b	sraw_widthtag(a5),d0
		move.l	d0,(a0)
		
		lea	SRAW_Indent(pc),a0
		move.b	sraw_intag(a5),d0
		move.l	d0,(a0)
		
		lea	sr_tabs(pc),a0
		move.b	sraw_indents(a5),d0
		move.l	d0,(a0)

		lea	s_entries(pc),a0
		move.b	sraw_entri(a5),d0
		move.l	d0,(a0)
		
		lea	SRAW_askmask(pc),a0
		move.b	sraw_amask(a5),d0
		move.l	d0,(a0)

		move.l	#SRAW_WindowTags,APG_WindowTagList(a5) ;Tag list for the Window
		move.l	#SRAW_WinWG+4,APG_WGadgets(a5)	;addr. of WA_Gadgets Tag + 4
		move.l	#SRAW_winSC+4,APG_WScreen(a5)	;addr. of WA_CustomScreen Tag + 4
		move.l	#SRAW_window,APG_WinWnd(a5)	;a point for the Window
		move.l	#SRAW_Glist,APG_Glist(a5)		;a point for the Glist
		move.l	#SRAW_NTypes,APG_NGads(a5)		;the NGads list
		move.l	#SRAW_Gtypes,APG_GTypes(a5)		;the GTypes list
		move.l	#SRAW_Gtags,APG_Gtags(a5)		;the Gtags list
		move.w	#SRAW_gadsanz,APG_CNT(a5)			;the number of Gadgets
		move.l	#SRAW_gadarray,APG_Gadgets(a5)	;a pointer for the Gadgetsarry, size=4*number of Gadgets
		move.l	APG_Scr(a5),APG_ScrBase(a5)	;the Screenpointer , stored in APG_Scr
	
		move.l	APG_CheckMainWinPos(a5),a6	;returns d0,d1 Pos
		jsr	(a6)

	;	add.w	#50,d0
		add.w	#100,d1
		
		move.w	d0,APG_WinLeft(a5)		;the left pos. of the Win
		move.w	d1,APG_WinTop(a5)		;the top pos. of the Win
		move.w	#367,APG_WinWidth(a5)		;the width of the Win
		move.w	#110,APG_WinHeight(a5)		;the height of the Win

		move.l	#SRAW_WinL,APG_WinL(a5)		;addr. of WA_Left Tag 
		move.l	#SRAW_WinT,APG_WinT(a5)		;addr. of WA_Top Tag
		move.l	#SRAW_WinW,APG_WinW(a5)		;addr. of WA_Width Tag
		move.l	#SRAW_WinH,APG_WinH(a5)		;addr. of WA_Height Tag

		move.l	APG_OpenWindow(a5),a6
		jsr	(a6)

		bsr.w	sraw_checkghost

		lea	SRAW_Text0(pc),a2
		move.w	#SRAW_Project0_TNUM,APG_TNUM(a5)
		move.l	APG_Writetext(a5),a6
		jsr	(a6)

		move.l	SRAW_window(pc),a0
		moveq	#3,d0
		moveq	#17,d1
		move.w	#178,d2
		move.w	#72,d3
		moveq	#0,d4	;Invert ?
		
		bsr.w	drawframe

		move.l	SRAW_window(pc),a0
		move.w	#184,d0
		moveq	#17,d1
		move.w	#179,d2
		move.w	#72,d3
		moveq	#0,d4	;Invert ?
		
		bsr.w	drawframe

		lea	SRAW_outsource(a5),a0
		lea	datapuffer,a1
		moveq	#srawlen,d7
.np		move.b	(a0)+,(a1)+
		dbra	d7,.np

SRAW_wait:	move.l	SRAW_window(pc),a0
		move.l	APG_Wait(a5),a6
		jsr	(a6)				;Handle input

		cmp.l	#GADGETUP,d4
		beq.b	SRAW_gads
		cmp.l	#CLOSEWINDOW,d4
		beq.b	SRAW_cancel
		bra.b	SRAW_wait

SRAW_gads:
		moveq	#0,d0
		move.w	38(a4),d0
		add.w	d0,d0
		lea	SRAW_Jumptab(pc),a0
		move.w	(a0,d0.l),d0
		jmp	(a0,d0.l)


SRAW_Jumptab:	dc.w	SRAW_ok-SRAW_Jumptab,SRAW_cancel-SRAW_Jumptab
		dc.w	SRAW_output-SRAW_Jumptab,SRAW_blit-SRAW_Jumptab
		dc.w	SRAW_image-SRAW_Jumptab,SRAW_mask-SRAW_Jumptab
		dc.w	SRAW_inter-SRAW_Jumptab,SRAW_language-SRAW_Jumptab
		dc.w	SRAW_widhtcheck-SRAW_Jumptab,SRAW_Indentcheck-SRAW_Jumptab
		dc.w	SRAW_Indent1check-SRAW_Jumptab,SRAW_Lineentries-SRAW_Jumptab
		dc.w	SRAW_askfmask-SRAW_Jumptab
		
SRAW_ok:
		bra.w	SRAW_wech
SRAW_cancel:
		bra.w	SRAW_cancelwech
SRAW_output:
		move.b	d5,sraw_outtag_(a5)
		lea	SRAW_outtag(pc),a0
		moveq	#2,d7
		lea	SRAW_outsource(a5),a1
		bra.w	SRAW_setflags
SRAW_blit:
		move.b	d5,sraw_blittag_(a5)
		lea	SRAW_blittag(pc),a0
		moveq	#2,d7
		lea	SRAW_blitnone(a5),a1
		bra.w	SRAW_setflags
SRAW_image:
		lea	SRAW_pimage(a5),a2
		lea	SRAW_ImageTag(pc),a1
		clr.l	(a1)
		move.l	#SRAW_GD_imagestruc,d0
		bra.w	SRAW_setcheck
SRAW_mask:
		lea	SRAW_pmask(a5),a2
		lea	SRAW_maskTag(pc),a1
		clr.l	(a1)
		move.l	#SRAW_GD_mask,d0
		bra.w	SRAW_setcheck
SRAW_inter:
		lea	SRAW_pinter(a5),a2
		lea	SRAW_interTag(pc),a1
		clr.l	(a1)
		move.l	#SRAW_GD_interleaved,d0
		bra.w	SRAW_setcheck
SRAW_language:
		move.b	d5,sraw_sourcetag(a5)
		lea	SRAW_lang(pc),a0
		lea	SRAW_asmsource(a5),a1
		moveq	#4,d7
		bra.w	sraw_setflags
SRAW_widhtcheck:
		move.b	d5,sraw_widthtag(a5)
		lea	SRAW_width(pc),a0
		lea	SRAW_byte(a5),a1
		moveq	#2,d7
		bra.b	sraw_setflags		

SRAW_Indentcheck:
		move.b	d5,sraw_intag(a5)
		lea	SRAW_Indent(pc),a0
		lea	SRAW_dtabs(a5),a1
		moveq	#1,d7
		bra.b	sraw_setflags
SRAW_Indent1check:
		lea	SRAW_gadarray(pc),a0
		move.w	38(a4),d0
		lsl.w	#2,d0
		move.l	(a0,d0.l),a0
		move.l	sraw_window(pc),a1
		bsr.w	getintegervalue
		move.b	d0,sraw_indents(a5)
		bra.w	sraw_wait
SRAW_Lineentries:
		lea	SRAW_gadarray(pc),a0
		move.w	38(a4),d0
		lsl.w	#2,d0
		move.l	(a0,d0.l),a0
		move.l	sraw_window(pc),a1
		bsr.w	getintegervalue
		move.b	d0,sraw_entri(a5)
		bra.w	sraw_wait
SRAW_askfmask:
		lea	sraw_amask(a5),a2
		lea	SRAW_askmask(pc),a1
		clr.l	(a1)
		move.l	#SRAW_GD_Askformask,d0
		bra.b	SRAW_setcheck

SRAW_cancelwech:
		lea	SRAW_outsource(a5),a0
		lea	datapuffer,a1
		moveq	#srawlen,d7
.np		move.b	(a1)+,(a0)+
		dbra	d7,.np

SRAW_wech:
		move.l	SRAW_window(pc),a0
		move.l	APG_Intuitionbase(a5),a6
		jmp	_LVOCloseWindow(a6)

SRAW_setflags
		move.l	a1,a2
.nc:		clr.b	(a1)+
		dbra	d7,.nc

		ext.l	d5
		move.b	#1,(a2,d5.l)
		move.l	d5,(a0)
		bsr.b	sraw_checkghost
		bra.w	SRAW_wait
SRAW_setcheck:
		lea	SRAW_gadarray(pc),a0
		lsl.l	#2,d0			;Bestimme Adresse der
		move.l	(a0,d0.w),a0		;Gadgetadresse
		clr.b	(a2)
		move.w	gg_Flags(a0),d0
		and.w	#SELECTED,d0
		beq.b	.w	;nicht selected
		st	(a2)
		move.l	#1,(a1)
.w		bsr.b	sraw_checkghost
		bra.w	SRAW_wait
		
sraw_checkghost:
		moveq	#0,d0
		tst.b	sraw_outsource(a5)
		bne.b	.w
		moveq	#1,d0
.w
		lea	sraw_ghost(pc),a3
		move.l	d0,4(a3)

		moveq	#SRAW_GD_Language,d0
		bsr.b	sraw_doghost
		moveq	#SRAW_GD_width,d0
		bsr.b	sraw_doghost
		moveq	#SRAW_GD_Indent,d0
		bsr.b	sraw_doghost
		moveq	#SRAW_GD_Indent1,d0
		bsr.b	sraw_doghost
		moveq	#SRAW_GD_lineentries,d0
		bsr.b	sraw_doghost
		moveq	#SRAW_GD_imagestruc,d0
		bsr.b	sraw_doghost
		
		moveq	#0,d0
		tst.b	SRAW_pmask(a5)
		bne.b	.w1
		moveq	#1,d0
.w1
		lea	sraw_ghost(pc),a3
		move.l	d0,4(a3)

		moveq	#SRAW_GD_Askformask,d0

sraw_doghost:
		lea	SRAW_gadarray(pc),a0
		lsl.l	#2,d0
		move.l	(a0,d0.l),a0
		move.l	sraw_window(pc),a1
		sub.l	a2,a2
		lea	sraw_ghost(pc),a3
		move.l	gadbase(a5),a6
		jmp	_LVOGT_SetGadgetAttrsA(a6)


sraw_ghost:	dc.l	GA_Disabled,0,0



SRAW_window:	dc.l	0		;Enthält pointer vom eingenen Window
SRAW_GList:	dc.l	0		
SRAW_gadarray:	dcb.l	13,0

	even

;-----------------------------------------------------------------------------
SRAW_WindowTags:
SRAW_winL:	dc.l	WA_Left,0
SRAW_winT:	dc.l	WA_Top,0
SRAW_winW:	dc.l	WA_Width,0
SRAW_winH:	dc.l	WA_Height,0
		dc.l	WA_IDCMP,CLOSEWINDOW!GADGETUP!VANILLAKEY!BUTTONIDCMP!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_CLOSEGADGET!WFLG_DEPTHGADGET!WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_SMART_REFRESH!WFLG_RMBTRAP
SRAW_winWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title,SRAW_winWTitle
SRAW_winSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

SRAW_WinWTitle:	dc.b	'RAW bitplane options',0
	even

SRAW_GD_Ok	=	0
SRAW_GD_Cancel	=	1
SRAW_GD_output	=	2
SRAW_GD_blit	=	3
SRAW_GD_imagestruc = 	4
SRAW_GD_Mask	=	5
SRAW_GD_Interleaved =	6
SRAW_GD_Language=	7
SRAW_GD_width	=	8
SRAW_GD_Indent	=	9
SRAW_GD_Indent1	=	10
SRAW_GD_lineentries =	11
SRAW_GD_Askformask  =	12

SRAW_Gtypes:
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND
		dc.w	CHECKBOX_KIND
		dc.w	CHECKBOX_KIND
		dc.w	CHECKBOX_KIND

		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND
		dc.w	INTEGER_KIND
		dc.w	INTEGER_KIND
		dc.w	CHECKBOX_KIND

SRAW_GTags:
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,SRAW_OutputLabel
		dc.l	GTCY_ACTIVE
SRAW_outtag:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,SRAW_BlitLabel
		dc.l	GTCY_ACTIVE
SRAW_blittag:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCB_Checked
SRAW_imagetag:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCB_Checked
SRAW_masktag:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCB_Checked
SRAW_intertag:	dc.l	0
		dc.l	TAG_DONE

		dc.l	GTCY_Labels,SRAW_LangLabel
		dc.l	GTCY_ACTIVE
SRAW_lang:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,SRAW_WidthLabel
		dc.l	GTCY_ACTIVE
SRAW_width:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,SRAW_IndentLabel
		dc.l	GTCY_ACTIVE
SRAW_Indent:	dc.l	0
		dc.l	TAG_DONE
SRAW_tabs:	dc.l	GTIN_Number
sr_tabs:	dc.l	2
		dc.l	GTIN_MaxChars,2		;Tabs
		dc.l	STRINGA_Justification,GACT_STRINGRIGHT
		dc.l	TAG_DONE
SRAW_entries:	dc.l	GTIN_Number
s_entries:	dc.l	8
		dc.l	GTIN_MaxChars,2
		dc.l	STRINGA_Justification,GACT_STRINGRIGHT
		dc.l	TAG_DONE
		dc.l	GTCB_Checked
SRAW_askmask:	dc.l	0
		dc.l	TAG_DONE


SRAW_OutputLabel:
		dc.l	SRAW_OutputLab0
		dc.l	SRAW_OutputLab1
		dc.l	SRAW_OutputLab2
		dc.l	0

SRAW_BlitLabel:
		dc.l	SRAW_BlitLab0
		dc.l	SRAW_BlitLab1
		dc.l	SRAW_BlitLab2
		dc.l	0

SRAW_LangLabel:
		dc.l	LangLabel0
		dc.l	LangLabel1
		dc.l	LangLabel2
		dc.l	LangLabel3
		dc.l	LangLabel4
		dc.l	0
		
SRAW_WidthLabel:
		dc.l	Widthlabel0
		dc.l	Widthlabel1
		dc.l	Widthlabel2
		dc.l	0
		
SRAW_IndentLabel:
		dc.l	IndentLabel0
		dc.l	IndentLabel1
		dc.l	0

IndentLabel0:	dc.b	'Tabs',0
IndentLabel1:	dc.b	'Spaces',0

Widthlabel0:	dc.b	'Bytes',0
Widthlabel1:	dc.b	'Words',0
Widthlabel2:	dc.b	'Longs',0

LangLabel0:	dc.b	'Asm',0
LangLabel1:	dc.b	'C',0
LangLabel2:	dc.b	'Pascal',0			
LangLabel3:	dc.b	'E',0
LangLabel4:	dc.b	'Basic',0


SRAW_BlitLab0:	dc.b	'None',0
SRAW_BlitLab1:	dc.b	'Left',0
SRAW_BlitLab2:	dc.b	'Right',0

SRAW_OutputLab0:dc.b	'Source',0
SRAW_OutputLab1:dc.b	'Binary',0
SRAW_OutputLab2:dc.b	'Link',0

	even

SRAW_NTypes:
		dc.w    42,93,100,13
		dc.l    oktext,0
		dc.w    SRAW_GD_Ok
		dc.l    PLACETEXT_IN,0,0
		dc.w	224,93,100,13
		dc.l    canceltext,0
		dc.w    SRAW_GD_Cancel
		dc.l    PLACETEXT_IN,0,0
		dc.w	7,32,85,13
		dc.l	sraw_outtext,0
		dc.w	SRAW_GD_output
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	94,32,85,13
		dc.l	sraw_blittext,0
		dc.w	SRAW_GD_blit
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	15,76,26,11
		dc.l	SRAW_imagetext,0
		dc.w	SRAW_GD_imagestruc
		dc.l	PLACETEXT_RIGHT,0,0
		dc.w	15,63,26,11
		dc.l	SRAW_masktext,0
		dc.w	SRAW_GD_Mask
		dc.l	PLACETEXT_RIGHT,0,0
		dc.w	15,50,26,11
		dc.l	SRAW_intertext,0
		dc.w	SRAW_GD_Interleaved
		dc.l	PLACETEXT_RIGHT,0,0
		dc.w	181+7,32,85,13
		dc.l	SRAW_langtext,0
		dc.w	SRAW_GD_Language
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	268+7,32,85,13
		dc.l	SRAW_widthtext,0
		dc.w	SRAW_GD_width
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	248,50,78,13
		dc.l	SRAW_indenttext,0
		dc.w	SRAW_GD_Indent
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	330,50,30,13
		dc.l	0,0
		dc.w	SRAW_GD_Indent1
		dc.l	0,0,0
		dc.w	330,65,30,13
		dc.l	SRAW_linetext,0
		dc.w	SRAW_GD_lineentries
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	94,63,26,11
		dc.l	SRAW_masktext1,0
		dc.w	SRAW_GD_askformask
		dc.l	PLACETEXT_RIGHT,0,0



sraw_outtext:	dc.b	'Output',0
sraw_blittext:	dc.b	'BlitWord',0
SRAW_imagetext:	dc.b	'Image Structure',0
SRAW_masktext:	dc.b	'Mask',0
SRAW_masktext1:	dc.b	'Ask',0
SRAW_intertext  dc.b	'Interleaved',0
SRAW_langtext:	dc.b	'Language',0
SRAW_widthtext:	dc.b	'Width',0
SRAW_indenttext:dc.b	'Indent',0
SRAW_linetext:	dc.b	'Line entries',0

	even
SRAW_Text0:
		DC.B    2,0
		DC.B    RP_JAM1
		DC.B    0
		DC.W    91,10
		DC.L    0
		DC.L    SRAW_Text
		DC.L    0
SRAW_Text01:
		DC.B    2,0
		DC.B    RP_JAM1
		DC.B    0
		DC.W    276,10
		DC.L    0
		DC.L    SRAW_Text1
		DC.L    0

SRAW_Project0_TNUM EQU 2

SRAW_Text:
		dc.b	'Save Format',0
SRAW_Text1:
		dc.b	'Source Format',0
		
	even


;---------------------------------------------------------------------
;----------------- Save Chunkys --------------------------------------
;---------------------------------------------------------------------
savechunky:

;Prefs Kopieren für Source Engine

		lea	chk_asmsource(a5),a0
		lea	sasmsource(a5),a1
		move.l	(a0)+,(a1)+
		move.b	(a0),(a1)				

		lea	chk_byte(a5),a0
		lea	databyte(a5),a1
		move.w	(a0)+,(a1)+
		move.b	(a0),(a1)		

		moveq	#0,d0
		move.b	chk_indents(a5),d0
		move.l	d0,data_indents(a5)

		moveq	#0,d0
		move.b	chk_entri(a5),d0
		move.l	d0,data_datasPL(a5)
	
		move.b	chk_dtabs(a5),data_tab(a5)
;---------------------------------------------------------------------

		tst.b	chk_normaltype(a5)
		beq.w	savergbchunky24
		tst.l	APG_Picmem(a5)
		bne.b	.w
		moveq	#APSE_NOBITMAP,d3
		rts
.w		tst.b	chk_lefttype(a5)
		bne.b	saverawchunkyleft
		tst.b	chk_leftpack(a5)
		bne	saverawchunkyleft
		bra.w	saverawchunkyright


;=====================================================================
;------------------- Save Chunky left-justified ----------------------
;=====================================================================
saverawchunkyleft:
		clr.b	saveright(a5)
saverawchunkyleft1:
		bsr.l	openprocess

		tst.w	cutflag(a5)
		bne.b	.brushok
		move.w	#0,xbrush1(a5)		;Es soll das ganze 
		move.w	#0,ybrush1(a5)		;Pic abgesaved werden
		move.w	breite(a5),xbrush2(a5)
		move.w	hoehe(a5),ybrush2(a5)	

.brushok:
		moveq	#0,d0
		move.w	xbrush2(a5),d0
		sub.w	xbrush1(a5),d0
		move.l	d0,d2
		add.l	#15,d0
		lsr.l	#4,d0		;breite in worte
		move.w	d0,brushword(a5)

;berechne Puffer:
		moveq	#0,d1
		move.w	ybrush2(a5),d1
		sub.w	ybrush1(a5),d1
				
		move.l	d1,d0
		lea	chk_normalmsg(pc),a1
		bsr.l	initprocess

		mulu	d1,d2

		move.b	chk_leftpack(a5),d3
		add.b	chk_rightpack(a5),d3
		tst.b	d3
		beq	.np
	cmp.b	#4,APG_Planes(a5)
	bhi	.np
	lsr.l	#1,d2				;bei Pack chunky nur die Hälfte
.np		move.l	d2,brushmemsize(a5)
		move.l	d2,linkobjektsize(a5)

		tst.b	chk_link(a5)	;soll File als LinkObjekt gespeichert
		beq.b	chl_nolink		;werden

		bsr.w	writelinkheader

		tst.l	d7
		beq.b	chl_nolink
		moveq	#-1,d3
		rts
chl_nolink:
		move.b	#1,full(a5)

		tst.b	chk_source(a5)
		beq.b	.all
		bsr.w	calclinemem
		tst.l	d0
		bne.w	nomem
		bra.b	chl_savefull

.all:		move.l	4,a6
		move.l	brushmemsize(a5),d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		jsr	_LVOAllocVec(a6)
		move.l	d0,brushpuffer(a5)
		beq.w	nomem
		
chl_savefull:
		sub.l	a1,a1	;Planeoffset
		bsr.w	checkfirstword ;berechnen das erste Word und Bitshift

		move.l	brushpuffer(a5),a4
		tst.b	chk_source(a5)
		beq.b	.w
		lea	datapuffer,a4
		move.w	#250,datazaehler(a5)
.w		move.l	picmem(a5),bitmapmerk(a5)

chl_nextword:
		move.b	planes(a5),planemerk(a5)
		move.l	#$80,d2		; =%100000000
		tst.b	saveright(a5)	;Chunky Right saven ?
		beq.b	chl_newplane
		moveq	#1,d2

chl_newplane
		move.l	firstword(a5),d0
		add.l	d0,d0		;in Byte
		move.l	bitmapmerk(a5),a0
		add.l	d0,a0
		add.l	d5,a0		;Y-Offset
		add.l	a1,a0		;Planeoffset
		
		move.l	bitshift(a5),d6
chl_newword:
		move.l	(a0),d0
		lsl.l	d6,d0
		swap	d0
		move.w	xbrush2(a5),d1
		cmp.w	d4,d1
		bhs.b	.pixok
		move.w	d4,d3
		sub.w	d1,d3
		lsr.w	d3,d0
		lsl.w	d3,d0	;zuviele Bits löschen
.pixok:
		lea	chunkypuffer(a5),a3

		moveq	#16-1,d3
.nextbit:		
		add.w	d0,d0
		bcc.b	.noset
		or.b	d2,(a3)
.noset:		addq.l	#1,a3
		dbra	d3,.nextbit
		tst.b	saveright(a5)	;Chunky Right saven ?
		beq.b	.sl
		lsl.b	#1,d2
		bra.b	.sr
.sl		lsr.b	#1,d2
.sr		add.l	oneplanesize(a5),a1
		sub.b	#1,planemerk(a5)
		bne.b	chl_newplane

		add.l	#16,d4		;XBrush1
		lea	chunkypuffer(a5),a3
		move.l	d4,d1
		move.w	xbrush2(a5),d0
		sub.w	d0,d1
		bmi.b	.ok
		moveq	#16-1,d3
		sub.w	d1,d3
		bra.b	.nb
.ok		moveq	#16-1,d3
.nb:		tst.b	chk_source(a5)
		bne.b	.ss

		tst.b	chk_rightpack(a5)
		bne	.pack
		tst.b	chk_leftpack(a5)
		beq	.nextbyte
.packbyte:
		cmp.b	#4,planes(a5)
		bhi	.nextbyte
		addq.w	#1,d3
		lsr.w	#1,d3
		subq.w	#1,d3
	;	moveq	#8-1,d3
.packbyte1:
		move.b	(a3)+,d0

		tst.b	chk_leftpack(a5)
		bne	.bnp
		lsl.b	#4,d0
.bnp:
		move.b	(a3)+,d1
		tst.b	chk_leftpack(a5)
		beq	.bnp1
		lsr.b	#4,d1
.bnp1:		or.b	d1,d0
		move.b	d0,(a4)+
		dbra	d3,.packbyte1
		bra	.clear

.nextbyte	move.b	(a3)+,(a4)+
		dbra	d3,.nextbyte
		bra.b	.clear
.ss
		addq.l	#1,d3
		clr.b	APG_Mark1(a5)
.copy:
		tst.b	chk_rightpack(a5)
		bne	.pack
		tst.b	chk_leftpack(a5)
		beq	.zg
.pack
		cmp.b	#4,planes(a5)
		bhi	.zg
		move.b	(a3)+,d0

		tst.b	chk_leftpack(a5)
		bne	.np
		lsl.b	#4,d0
.np:
		subq.l	#1,d3
		beq.b	.zufruehschluss2
		move.b	(a3)+,d1
		tst.b	chk_leftpack(a5)
		beq	.np1
		lsr.b	#4,d1
.np1:		or.b	d1,d0
		bra	.zufruehschluss2
.zg
		move.b	(a3)+,(a4)+	;Hier für Chunky4 einfügen
		subq.l	#1,d3
		beq.b	.zufruehschluss
		move.b	(a3)+,(a4)+
.subzaehler:
		tst.b	APG_Mark1(a5)
		bne	.nw
		sub.w	#1,datazaehler(a5)
		bne.b	.nw
		bsr.w	da_savedatas
		bra.b	.nw

.zufruehschluss2:
		move.b	d0,(a4)+
		not.b	APG_Mark1(a5)
		bra.b	.subzaehler
.zufruehschluss:
		move.b	#0,(a4)+
		bra.b	.subzaehler
.nw		subq.l	#1,d3
		bmi.b	.clear
		bne.b	.copy
		
.clear		lea	chunkypuffer(a5),a3
		clr.l	(a3)+
		clr.l	(a3)+
		clr.l	(a3)+
		clr.l	(a3)+

		addq.l	#2,bitmapmerk(a5)
		sub.l	a1,a1
		dbra	d7,chl_nextword

		move.w	xbrush1(a5),d4
		move.w	brushword(a5),d7
		subq.w	#1,d7

		add.l	bytebreite(a5),d5
		move.l	picmem(a5),bitmapmerk(a5)

		move.w	ybrush2(a5),d0
		addq.w	#1,a2
		cmp.w	d0,a2
		beq.b	.end

		bsr.l	doprocess
		tst.l	d0
		beq.b	chk_abort

		bra.w	chl_nextword
.end	
		tst.b	chk_source(a5)
		beq.b	chk_end
		moveq	#0,d3

		tst.b	APG_Mark1(a5)
		beq	.nixrest
		clr.b	(a4)+
		sub.w	#1,datazaehler(a5)
.nixrest:	bsr.w	da_savedatas
		tst.b	saveflag(a5)
		beq.b	.we
		move.l	linememmerk(a5),a0
		move.b	#1,lastsave(a5)
		bsr.w	da_saveline
.we
		bsr.w	da_makeend
		bsr.w	da_memwech
		bsr	chk_writecomment
		rts

chk_abort:
		moveq	#APSE_ABORT,d3
		bra.b	chk_nosave

chk_end:
		move.l	filehandle(a5),d1
		move.l	brushpuffer(a5),d2
		move.l	brushmemsize(a5),d3
		move.l	dosbase(a5),a6
		jsr	_LVOWrite(a6)		;Save volles Raw-Pic ab
		moveq	#0,d3
chk_nosave:
		move.l	brushpuffer(a5),a1
		cmp.l	#0,a1
		beq.b	.wl
		move.l	4,a6
		jsr	_LVOFreeVec(a6)
		clr.l	brushpuffer(a5)	


		bsr	chk_writecomment
		
		cmp.l	#APSE_ABORT,d3
		beq.b	.nolink

.wl:		tst.b	chk_link(a5)
		beq.b	.nolink
		bsr.w	writelinkbottom
.nolink:
		bra.w	da_memwech

;------------------------------------------------------------------------------
;schreibe comment
chk_writecomment:
		tst.b	chk_lefttype(a5)
		bne	.sl
		lea	chk_name2(pc),a0
		tst.b	chk_source(a5)
		bne	.ssl
		lea	chk_name4(pc),a0
		tst.b	chk_link(a5)
		bne	.ssl
		lea	3(a0),a0
		bra	.ssl

;left:
.sl:		lea	chk_name3(pc),a0
		tst.b	chk_source(a5)
		bne	.ssl
		lea	chk_name5(pc),a0
		tst.b	chk_link(a5)
		bne	.ssl
		lea	3(a0),a0
.ssl:
		moveq	#0,d0
		move.w	APG_xbrush2(a5),d0
		sub.w	APG_xbrush1(a5),d0
		moveq	#0,d1
		move.w	APG_ybrush2(a5),d1
		sub.w	APG_ybrush1(a5),d1
		moveq	#0,d2
		move.b	APG_Planes(a5),d2

		jmp	APR_SetComment(a5)

chk_normalmsg:	dc.b	'Save Chunky!',0

chk_name:	dc.b	'SRC CHUNKY RGB',0
chk_name1:	dc.b	'LI CHUNKY RGB',0

chk_name2:	dc.b	'SRC CHUNKY Right Byte',0
chk_name3:	dc.b	'SRC CHUNKY Left Byte',0
chk_name4:	dc.b	'LI CHUNKY Right Byte',0
chk_name5:	dc.b	'LI CHUNKY Left Byte',0

	even
;---------------------------------------------------------------------
keyfault:
		move.l	execbasepuffer(a5),a0
		move.l	mainwinWnd(a5),(a0)
		rts

;=====================================================================
;------------------- Save Chunky right-justified ---------------------
;=====================================================================
saverawchunkyright:
		st	saveright(a5)
		bra.w	saverawchunkyleft1


;---------------------------------------------------------------------
convtab:
		lea	farbtab8+4(a5),a1
convtab1:
		lea	farbtab8pure,a0
		lea	farbtab4pure,a2
		move.w	anzcolor(a5),d7
		subq	#1,d7
.nc		moveq	#0,d1
		moveq	#0,d2
		move.l	(a1)+,d0
		swap	d0
		lsr.w	#8,d0
		move.b	d0,d1
		lsl.l	#8,d1
		move.l	d0,d2
		lsl.w	#4,d2
		and.w	#$0f00,d2
		move.l	(a1)+,d0
		swap	d0
		lsr.w	#8,d0
		move.b	d0,d2
		and.b	#$f0,d2
		move.b	d0,d1
		lsl.l	#8,d1
		move.l	(a1)+,d0
		swap	d0
		lsr.w	#8,d0
		move.b	d0,d1
	;	lsl.l	#8,d1
	tst.b	ham(a5)
	beq.b	.w
	and.l	#$00f0f0f0,d1
.w		move.l	d1,(a0)+
		and.b	#$f0,d0
		lsr.b	#4,d0
		or.b	d0,d2
		move.w	d2,(a2)+
		dbra	d7,.nc
		rts

;-------------------------------------------------------------------------
;------- Save RGB-Chunky 24-Bit ------------------------------------------
;-------------------------------------------------------------------------
savergbchunky24:
		tst.w	cutflag(a5)
		bne.b	.brushok
		clr.w	xbrush1(a5)		;Es soll das ganze 
		clr.w	ybrush1(a5)		;Pic abgesaved werden
		move.w	breite(a5),xbrush2(a5)
		move.w	hoehe(a5),ybrush2(a5)	
.brushok:
		moveq	#0,d0
		move.w	xbrush2(a5),d0
		sub.w	xbrush1(a5),d0
		move.l	d0,brushXwidth(a5)
		move.l	d0,brushbyte(a5)

		move.l	d0,d5
		add.l	#15,d5
		lsr.l	#4,d5		;breite in worte
		move.w	d5,APG_Brushword(a5)
		
		move.w	ybrush1(a5),ybrush1buffer(a5)
		
		moveq	#0,d1
		move.w	ybrush2(a5),d1
		sub.w	ybrush1(a5),d1

		move.l	d1,brushYheight(a5)

		add.l	d0,d0		;rgb ist ja ein Longword		
		tst.b	chk_12bit(a5)
		bne.b	.no24
		add.l	d0,d0		;weil longword
.no24:
		mulu	d0,d1

		move.l	d1,linkobjektsize(a5)

		move.l	d0,rgblinemem(a5)

		tst.b	chk_source(a5)
		beq.b	.li
		lea	datapuffer,a4
		move.w	#250,datazaehler(a5)
		bsr.w	calclinemem	;berechne puffer für datasave
		tst.l	d0
		bne.w	nomem
		st	newlinemerk(a5)
.li
		tst.b	chk_link(a5)	;soll File als LinkObjekt gespeichert
		beq.b	chk24_nolink		;werden

		bsr.w	writelinkheader

		tst.l	d7
		beq.b	chk24_nolink
		moveq	#-1,d3
		rts

chk24_nolink:
		tst.b	chk_source(a5)
		bne.b	.saveline

;full saver ersma rausgenommen damit 18 bit geht

		clr.l	APG_Free6(a5)

		st	full(a5)
		move.l	linkobjektsize(a5),d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,rgbmem(a5)
		beq.b	.saveline
		bra.b	.go
.saveline:
		clr.b	full(a5)
		move.l	rgblinemem(a5),d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,rgbmem(a5)
		beq.w	nomem
.go
		bsr.l	openprocess

		lea	savergbchunkymsg(pc),a1
		tst.b	chk_12bit(a5)
		beq.b	.nix12
 		lea	savergbchunky12msg(pc),a1
.nix12:
		tst.b	chk_18bit(a5)
		beq	.nix18
 		lea	savergbchunky18msg(pc),a1
.nix18:
		move.l	brushYheight(a5),d0
		bsr.l	initprocess
		
		sf	chk_firstmakechunk(a5)
		tst.l	rndr_rendermem(a5)
		bne.b	chk24_rendermemfound

chk24_nixrender:
		bsr.w	convtab		;convertiere Loadrgb32 in pure daten

;		tst.l	rndr_palette(a5)
;		bne	.wp
;		lea	rndr_paltag,a1
;		move.l	rndr_memhandler(a5),4(a1)
;		move.l	renderbase(a5),a6
;		jsr	_LVOCreatePaletteA(a6)
;		move.l	d0,rndr_palette(a5)
;.wp
		move.l	rndr_palette(a5),a0
		move.l	Farbtab8(a5),d0		;Farbanzahl
		swap	d0
		lea	farbtab8pure,a1
		lea	rndr_palitag,a2
		move.l	renderbase(a5),a6
		jsr	_LVOImportPaletteA(a6)		

		st	chk_firstmakechunk(a5)
		bsr.w	checkfirstword

		move.l	rgblinemem(a5),d0
		tst.b	chk_12bit(a5)
		beq.b	.w
		add.l	d0,d0
.w
		add.l	brushbyte(a5),d0
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4,a6
		jsr	_LVOAllocVec(a6)
		move.l	d0,APG_Free6(a5)	;Chunky Puffer
		add.l	brushbyte(a5),d0
		move.l	d0,APG_Free5(a5)	;RGB Chunky Puffer
		bra.b	chk24_makeit

chk24_rendermemfound:
		tst.l	APG_rndr_rgb(a5)
		beq.b	chk24_nixrender

chk24_makeit:
		move.l	rgbmem(a5),a0
		move.w	ybrush1(a5),d7		;Zeilen zähler
.nextline:
		move.l	apg_rndr_rgb(a5),a1
		
		tst.b	chk_firstmakechunk(a5)
		beq.b	.nixmake

;generiere Chunkys für eine Zeile

		move.l	a0,-(a7)
		moveq	#0,d0
		move.w	d7,d0
		move.l	APG_Free6(a5),a0
		move.l	APG_Bpl2ChunkyLine(a5),a6
		jsr	(a6)

		move.l	APG_Free6(a5),a0
		move.l	APG_Free5(a5),a1
;		lea	farbtab8pure,a2
		move.l	rndr_palette(a5),a2
		move.l	brushbyte(a5),d0
		moveq	#1,d1
		moveq	#COLORMODE_CLUT,d5

		tst.b	ham(a5)
		beq.b	.w
		moveq	#COLORMODE_HAM6,d5
		bra.b	.ren
.w		tst.b	ham8(a5)
		beq.b	.ren
		moveq	#COLORMODE_HAM8,d5
.ren
		lea	.chtag(pc),a3
		move.l	d5,4(a3)
		move.l	renderbase(a5),a6
		jsr	_LVOChunky2RGBA(a6)
		
		move.l	APG_Free5(a5),a1
		move.l	(a7)+,a0
		bra.b	.makeit
.chtag:
		dc.l	RND_ColorMode,0
		dc.l	TAG_DONE
.nixmake:
		move.w	d7,d0
		move.l	bytebreite(a5),d1
		lsl.w	#3,d1
		mulu	d1,d0
		lea	(a1,d0.l*4),a1
		moveq	#0,d0
		move.w	xbrush1(a5),d0
		lea	(a1,d0.l*4),a1
.makeit
		tst.b	chk_source(a5)
		beq.b	.nixsource
		move.l	brushbyte(a5),d6	;Pixel einer Zeile
		tst.b	chk_12bit(a5)
		bne.b	.saves12
		add.l	d6,d6
		subq.l	#1,d6
.snb:		move.w	(a1)+,d0

		tst.b	chk_18bit(a5)
		beq	.n18
		lsr.w	#2,d0		;wandle im 18 bit um
		and.b	#%00111111,d0
.n18:
		move.w	d0,(a4)+
		subq.w	#1,datazaehler(a5)
		bne.b	.ns
		bsr.w	da_savedatas
.ns:		
		dbra	d6,.snb
		bra.w	.sfull

.saves12:
		subq.w	#1,d6
.ns12:		move.l	(a1)+,d0	;Save für 12 Bit Source
		moveq	#0,d1
		bfextu	d0{8:4},d1
		move.w	d1,d2
		lsl.w	#4,d2
		bfextu	d0{16:4},d1
		or.w	d1,d2
		lsl.w	#4,d2
		bfextu	d0{24:4},d1
		or.w	d1,d2
		move.w	d2,(a4)+

		subq.w	#1,datazaehler(a5)
		bne.b	.ns1
		bsr.w	da_savedatas
.ns1:		
		dbra	d6,.ns12	
		bra.b	.sfull

;----------------------------------------------------------------------------
.nixsource:	move.l	brushbyte(a5),d6	;Pixel einer Zeile
		subq.l	#1,d6

		tst.b	chk_12bit(a5)
		beq.b	.no12

.nb12:		move.l	(a1)+,d0	;Saver für 12 Bit Binär
		moveq	#0,d1
		bfextu	d0{8:4},d1
		move.w	d1,d2
		lsl.w	#4,d2
		bfextu	d0{16:4},d1
		or.w	d1,d2
		lsl.w	#4,d2
		bfextu	d0{24:4},d1
		or.w	d1,d2
		move.w	d2,(a0)+

		dbra	d6,.nb12	
		bra.b	.weiter

.no12:
.nb:		move.l	(a1)+,d0
		tst.b	chk_18bit(a5)
		beq	.nn18
		lsr.l	#2,d0
		and.l	#%001111110011111100111111,d0
.nn18
		move.l	d0,(a0)+
		dbra	d6,.nb
.weiter
		tst.b	full(a5)
		bne.b	.sfull
		move.l	filehandle(a5),d1
		move.l	rgbmem(a5),d2
		move.l	brushxwidth(a5),d3
		add.w	d3,d3
		tst.b	chk_12bit(a5)
		bne.b	.no24
		add.w	d3,d3	;weil Longs für 24-Bit
.no24:		move.l	dosbase(a5),a6
		jsr	_LVOWrite(a6)
		tst.l	d0
		bmi	chk24_abort

.sfull:
		bsr.l	doprocess
		tst.l	d0
		beq.w	chk24_abort

		addq.w	#1,d7
		cmp.w	ybrush2(a5),d7
		blo.w	.nextline

		tst.b	full(a5)
		beq.b	.end
		move.l	filehandle(a5),d1
		move.l	rgbmem(a5),d2
		move.l	linkobjektsize(a5),d3
		move.l	dosbase(a5),a6
		jsr	_LVOWrite(a6)

.end:
		tst.b	chk_source(a5)
		beq.b	.s
		bsr.w	da_savedatas
		tst.b	saveflag(a5)
		beq.b	.ns2
		move.l	linememmerk(a5),a0
		move.b	#1,lastsave(a5)
		bsr.w	da_saveline
.ns2
		bsr.w	da_makeend
		bsr.w	da_memwech
.s:
		tst.b	chk_link(a5)
		beq.b	.nolink
		bsr.w	writelinkbottom
.nolink:
chk24_wech
		move.l	4,a6
		move.l	rgbmem(a5),d0
		beq.b	.nw
		move.l	d0,a1
		jsr	_LVOFreeVec(a6)
.nw
		move.l	APG_Free6(a5),d0
		beq.b	.nw1
		move.l	d0,a1
		jsr	_LVOFreeVec(a6)
.nw1

;schreibe comment
claber
		lea	chk_name(pc),a0
		tst.b	chk_source(a5)
		bne	.ss
		lea	chk_name1(pc),a0
		tst.b	chk_link(a5)
		bne	.ss
		lea	3(a0),a0
.ss	
		moveq	#0,d0
		move.w	APG_xbrush2(a5),d0
		sub.w	APG_xbrush1(a5),d0
		moveq	#0,d1
		move.w	APG_ybrush2(a5),d1
		sub.w	APG_ybrush1(a5),d1
		moveq	#12,d2
		tst.b	chk_12bit(a5)
		bne	.sc
		moveq	#18,d2
		tst.b	chk_18bit(a5)
		bne	.sc
		moveq	#24,d2
.sc		
		jsr	APR_SetComment(a5)


		cmp.w	#APSE_ABORT,d3
		bne.b	.w
		rts
.w		moveq	#0,d3
		rts

chk24_abort:
		moveq	#APSE_ABORT,d3
		bra.b	chk24_wech
savergbchunkymsg:
		dc.b	'Save 24-Bit RGB Chunkys',0
savergbchunky12msg:
		dc.b	'Save 12-Bit RGB Chunkys',0
savergbchunky18msg:
		dc.b	'Save 18-Bit RGB Chunkys',0

	even
;***************************************************************************
;*----------------------- Save GePufferte Line ----------------------------*
;***************************************************************************
saveline:
		move.l	a0,-(a7)
		move.l	filehandle(a5),d1
		move.l	brushpuffer(a5),d2
		moveq	#0,d3
		move.w	brushword(a5),d3
		add.w	d3,d3
		move.l	dosbase(a5),a6
		jsr	_LVOWrite(a6)	
		move.l	(a7)+,a0
		rts

;--------------------------------------------------------------------------
;-------- Preference für Chunky -------------------------------------------
;--------------------------------------------------------------------------
chk_prefs:

		lea	chk_outtag(pc),a0
		moveq	#0,d0
		move.b	chk_outtag_(a5),d0
		move.l	d0,(a0)

		lea	chk_lang(pc),a0
		move.b	chk_sourcetag(a5),d0
		move.l	d0,(a0)
		
		lea	chk_chktype(pc),a0
		move.b	chk_chktypetag(a5),d0
		move.l	d0,(a0)

		lea	chk_normal(pc),a0
		move.b	chk_normaltypetag(a5),d0
		move.l	d0,(a0)

		lea	chk_rgb(pc),a0
		move.b	chk_rgbtypetag(a5),d0
		move.l	d0,(a0)

		lea	chk_width(pc),a0
		move.b	chk_widthtag(a5),d0
		move.l	d0,(a0)
		
		lea	chk_Indent(pc),a0
		move.b	chk_intag(a5),d0
		move.l	d0,(a0)
		
		lea	chk_tabs(pc),a0
		move.b	chk_indents(a5),d0
		move.l	d0,(a0)

		lea	chk_entries(pc),a0
		move.b	chk_entri(a5),d0
		move.l	d0,(a0)
		
		move.l	#chk_WindowTags,APG_WindowTagList(a5) ;Tag list for the Window
		move.l	#chk_WinWG+4,APG_WGadgets(a5)	;addr. of WA_Gadgets Tag + 4
		move.l	#chk_winSC+4,APG_WScreen(a5)	;addr. of WA_CustomScreen Tag + 4
		move.l	#chk_window,APG_WinWnd(a5)	;a point for the Window
		move.l	#chk_Glist,APG_Glist(a5)		;a point for the Glist
		move.l	#chk_NTypes,APG_NGads(a5)		;the NGads list
		move.l	#chk_Gtypes,APG_GTypes(a5)		;the GTypes list
		move.l	#chk_Gtags,APG_Gtags(a5)		;the Gtags list
		move.w	#chk_gadsanz,APG_CNT(a5)			;the number of Gadgets
		move.l	#chk_gadarray,APG_Gadgets(a5)	;a pointer for the Gadgetsarry, size=4*number of Gadgets
		move.l	APG_Scr(a5),APG_ScrBase(a5)	;the Screenpointer , stored in APG_Scr
	
		move.l	APG_CheckMainWinPos(a5),a6	;returns d0,d1 Pos
		jsr	(a6)

	;	add.w	#50,d0
		add.w	#100,d1
		
		move.w	d0,APG_WinLeft(a5)		;the left pos. of the Win
		move.w	d1,APG_WinTop(a5)		;the top pos. of the Win
		move.w	#367,APG_WinWidth(a5)		;the width of the Win
		move.w	#100,APG_WinHeight(a5)		;the height of the Win

		move.l	#chk_WinL,APG_WinL(a5)		;addr. of WA_Left Tag 
		move.l	#chk_WinT,APG_WinT(a5)		;addr. of WA_Top Tag
		move.l	#chk_WinW,APG_WinW(a5)		;addr. of WA_Width Tag
		move.l	#chk_WinH,APG_WinH(a5)		;addr. of WA_Height Tag

		move.l	APG_OpenWindow(a5),a6
		jsr	(a6)

		bsr.w	chk_checkghost

		lea	SRAW_Text0(pc),a2
		move.w	#SRAW_Project0_TNUM,APG_TNUM(a5)
		move.l	APG_Writetext(a5),a6
		jsr	(a6)

		move.l	chk_window(pc),a0
		moveq	#3,d0
		moveq	#17,d1
		move.w	#178,d2
		move.w	#62,d3
		moveq	#0,d4	;Invert ?
		
		bsr.w	drawframe

		move.l	chk_window(pc),a0
		move.w	#184,d0
		moveq	#17,d1
		move.w	#179,d2
		move.w	#62,d3
		moveq	#0,d4	;Invert ?
		
		bsr.w	drawframe

		lea	chk_asmsource(a5),a0
		lea	datapuffer,a1
		moveq	#chklen,d7
.np		move.b	(a0)+,(a1)+
		dbra	d7,.np

chk_wait:	move.l	chk_window(pc),a0
		move.l	APG_Wait(a5),a6
		jsr	(a6)				;Handle input

		cmp.l	#GADGETUP,d4
		beq.b	chk_gads_
		cmp.l	#CLOSEWINDOW,d4
		beq.b	chk_cancel
		bra.b	chk_wait

chk_gads_:
		moveq	#0,d0
		move.w	38(a4),d0
		add.w	d0,d0
		lea	chk_Jumptab(pc),a0
		move.w	(a0,d0.l),d0
		jmp	(a0,d0.l)


chk_Jumptab:	dc.w	chk_ok-chk_Jumptab
		dc.w	chk_cancel-chk_Jumptab
		dc.w	chk_output-chk_Jumptab
		dc.w	chk_type-chk_Jumptab
		dc.w	chk_lrtype-chk_jumptab
		dc.w	chk_hrgbtype-chk_jumptab
		dc.w	chk_language-chk_Jumptab
		dc.w	chk_widhtcheck-chk_Jumptab
		dc.w	chk_Indentcheck-chk_Jumptab
		dc.w	chk_Indent1check-chk_Jumptab
		dc.w	chk_Lineentries-chk_Jumptab
chk_ok:
		bra.w	chk_wech
chk_cancel:
		bra.w	chk_cancelwech
chk_output:
		move.b	d5,chk_outtag_(a5)
		lea	chk_outtag(pc),a0
		moveq	#2,d7
		lea	chk_source(a5),a1
		bra.w	chk_setflags
chk_type:
		move.b	d5,chk_chktypetag(a5)
		lea	chk_chktype(pc),a0
		moveq	#1,d7
		lea	chk_normaltype(a5),a1
		bra.w	chk_setflags
chk_lrtype:
		move.b	d5,chk_normaltypetag(a5)
		lea	chk_normal(pc),a0
		ext.l	d5
		move.l	d5,(a0)

		lea	chk_lefttype(a5),a1
		clr.b	(a1)+
		clr.b	(a1)

		lea	chk_leftpack(a5),a1
		clr.b	(a1)+
		clr.b	(a1)

		cmp.w	#0,d5
		bne	.nl
		st	chk_lefttype(a5)
.nl		cmp.w	#1,d5
		bne	.nr
		st	chk_righttype(a5)
.nr		cmp.w	#2,d5
		bne	.nlp
		st	chk_leftpack(a5)
.nlp		cmp.w	#3,d5
		bne	.nrp
		st	chk_rightpack(a5)
.nrp:
		bra.w	chk_wait


chk_hrgbtype:
		move.b	d5,chk_rgbtypetag(a5)
		lea	chk_rgb(pc),a0
		moveq	#2,d7
		lea	chk_12bit(a5),a1
		bra.w	chk_setflags
chk_language:
		move.b	d5,chk_sourcetag(a5)
		lea	chk_lang(pc),a0
		lea	chk_asmsource(a5),a1
		moveq	#4,d7
		bra.b	chk_setflags
chk_widhtcheck:
		move.b	d5,chk_widthtag(a5)
		lea	chk_width(pc),a0
		lea	chk_byte(a5),a1
		moveq	#2,d7
		bra.b	chk_setflags		
chk_Indentcheck:
		move.b	d5,chk_intag(a5)
		lea	chk_Indent(pc),a0
		lea	chk_dtabs(a5),a1
		moveq	#1,d7
		bra.b	chk_setflags
chk_Indent1check:
		lea	chk_gadarray(pc),a0
		move.w	38(a4),d0
		lsl.w	#2,d0
		move.l	(a0,d0.l),a0
		move.l	chk_window(pc),a1
		bsr.w	getintegervalue
		move.b	d0,chk_indents(a5)
		bra.w	chk_wait
chk_Lineentries:
		lea	chk_gadarray(pc),a0
		move.w	38(a4),d0
		lsl.w	#2,d0
		move.l	(a0,d0.l),a0
		move.l	chk_window(pc),a1
		bsr.w	getintegervalue
		move.b	d0,chk_entri(a5)
		bra.w	chk_wait

chk_cancelwech:
		lea	chk_asmsource(a5),a0
		lea	datapuffer,a1
		moveq	#chklen,d7
.np		move.b	(a1)+,(a0)+
		dbra	d7,.np

chk_wech:
		move.l	chk_window(pc),a0
		move.l	APG_Intuitionbase(a5),a6
		jmp	_LVOCloseWindow(a6)

chk_setflags
		move.l	a1,a2
.nc:		clr.b	(a1)+
		dbra	d7,.nc

		ext.l	d5
		move.b	#1,(a2,d5.l)
		move.l	d5,(a0)
		bsr.b	chk_checkghost
		bra.w	chk_wait
		
chk_checkghost:
		moveq	#0,d0
		tst.b	chk_source(a5)
		bne.b	.w
		moveq	#1,d0
.w
		lea	sraw_ghost(pc),a3
		move.l	d0,4(a3)

		moveq	#chk_GD_Language,d0
		bsr.b	chk_doghost
		moveq	#chk_GD_width,d0
		bsr.b	chk_doghost
		moveq	#chk_GD_Indent,d0
		bsr.b	chk_doghost
		moveq	#chk_GD_Indent1,d0
		bsr.b	chk_doghost
		moveq	#chk_GD_lineentries,d0
		bsr.b	chk_doghost

		moveq	#0,d0
		tst.b	chk_normaltype(a5)
		bne.b	.w1
		moveq	#1,d0
.w1
		lea	sraw_ghost(pc),a3
		move.l	d0,4(a3)

		moveq	#chk_GD_normaltype,d0
		bsr.b	chk_doghost

		moveq	#0,d0
		tst.b	chk_rgbtype(a5)
		bne.b	.w2
		moveq	#1,d0
.w2
		lea	sraw_ghost(pc),a3
		move.l	d0,4(a3)
		
		moveq	#chk_GD_rgbtype,d0

chk_doghost:
		lea	chk_gadarray(pc),a0
		lsl.l	#2,d0
		move.l	(a0,d0.l),a0
		move.l	chk_window(pc),a1
		sub.l	a2,a2
		lea	sraw_ghost(pc),a3
		move.l	gadbase(a5),a6
		jmp	_LVOGT_SetGadgetAttrsA(a6)


chk_window:	dc.l	0		;Enthält pointer vom eingenen Window
chk_GList:	dc.l	0		
chk_gadarray:	dcb.l	11,0

	even

;-----------------------------------------------------------------------------
chk_WindowTags:
chk_winL:	dc.l	WA_Left,0
chk_winT:	dc.l	WA_Top,0
chk_winW:	dc.l	WA_Width,0
chk_winH:	dc.l	WA_Height,0
		dc.l	WA_IDCMP,CLOSEWINDOW!GADGETUP!VANILLAKEY!BUTTONIDCMP!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_CLOSEGADGET!WFLG_DEPTHGADGET!WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_SMART_REFRESH!WFLG_RMBTRAP
chk_winWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title,chk_winWTitle
chk_winSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

chk_WinWTitle:	dc.b	'Chunky options',0
	even

chk_gadsanz	=	11

chk_GD_Ok	=	0
chk_GD_Cancel	=	1
chk_GD_output	=	2
chk_GD_chktype	=	3
chk_GD_normaltype =	4
chk_GD_rgbtype	=	5
chk_GD_Language=	6
chk_GD_width	=	7
chk_GD_Indent	=	8
chk_GD_Indent1	=	9
chk_GD_lineentries =	10

chk_Gtypes:
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND

		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND
		dc.w	INTEGER_KIND
		dc.w	INTEGER_KIND
		dc.w	CYCLE_KIND

chk_GTags:
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,sraw_OutputLabel
		dc.l	GTCY_ACTIVE
chk_outtag:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,chk_chktypeLabel
		dc.l	GTCY_ACTIVE
chk_chktype:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,chk_normalLabel
		dc.l	GTCY_ACTIVE
chk_normal:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,chk_rgbLabel
		dc.l	GTCY_ACTIVE
chk_rgb:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,chk_LangLabel
		dc.l	GTCY_ACTIVE
chk_lang:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,chk_WidthLabel
		dc.l	GTCY_ACTIVE
chk_width:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,chk_IndentLabel
		dc.l	GTCY_ACTIVE
chk_Indent:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTIN_Number
chk_tabs:	dc.l	2
		dc.l	GTIN_MaxChars,2		;Tabs
		dc.l	STRINGA_Justification,GACT_STRINGRIGHT
		dc.l	TAG_DONE
		dc.l	GTIN_Number
chk_entries:	dc.l	8
		dc.l	GTIN_MaxChars,2
		dc.l	STRINGA_Justification,GACT_STRINGRIGHT
		dc.l	TAG_DONE


chk_chktypeLabel:
		dc.l	chk_chktypeLab0
		dc.l	chk_chktypeLab1
		dc.l	0

chk_normalLabel:
		dc.l	chk_normalLab0
		dc.l	chk_normalLab1

		dc.l	0

		dc.l	chk_normalLab2
		dc.l	chk_normalLab3
		dc.l	0

chk_rgbLabel:
		dc.l	chk_rgbLab0
		dc.l	chk_rgbLab1
		dc.l	chk_rgbLab2
		dc.l	0
		
chk_LangLabel:
		dc.l	LangLabel0
		dc.l	LangLabel1
		dc.l	LangLabel2
		dc.l	LangLabel3
		dc.l	LangLabel4
		dc.l	0
		
chk_WidthLabel:
		dc.l	Widthlabel0
		dc.l	Widthlabel1
		dc.l	Widthlabel2
		dc.l	0
		
chk_IndentLabel:
		dc.l	IndentLabel0
		dc.l	IndentLabel1
		dc.l	0


chk_chktypeLab0:dc.b	'Byte',0
chk_chktypeLab1:dc.b	'RGB',0

chk_normalLab0:	dc.b	'Left',0
chk_normalLab1:	dc.b	'Right',0
chk_normalLab2:	dc.b	'L Pack',0
chk_normalLab3:	dc.b	'R Pack',0

chk_rgbLab0:	dc.b	'12 Bit',0
chk_rgbLab1:	dc.b	'18 Bit',0
chk_rgbLab2:	dc.b	'24 Bit',0
		
	even

chk_NTypes:
		dc.w    42,83,100,13
		dc.l    oktext,0
		dc.w    chk_GD_Ok
		dc.l    PLACETEXT_IN,0,0
		dc.w	224,83,100,13
		dc.l    canceltext,0
		dc.w    chk_GD_Cancel
		dc.l    PLACETEXT_IN,0,0
		dc.w	7,32,85,13
		dc.l	sraw_outtext,0
		dc.w	chk_GD_output
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	94,32,85,13
		dc.l	chk_chktypetext,0
		dc.w	chk_GD_chktype
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	7,63,85,13
		dc.l	chk_normaltext,0
		dc.w	chk_GD_normaltype
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	94,63,85,13
		dc.l	chk_rgbtext,0
		dc.w	chk_GD_rgbtype
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	181+7,32,85,13
		dc.l	SRAW_langtext,0
		dc.w	chk_GD_Language
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	268+7,32,85,13
		dc.l	SRAW_widthtext,0
		dc.w	chk_GD_width
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	248,50-2,78,13
		dc.l	SRAW_indenttext,0
		dc.w	chk_GD_Indent
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	330,50-2,30,13
		dc.l	0,0
		dc.w	chk_GD_Indent1
		dc.l	0,0,0
		dc.w	330,65-2,30,13
		dc.l	SRAW_linetext,0
		dc.w	chk_GD_lineentries
		dc.l	PLACETEXT_LEFT,0,0


chk_chktypetext:dc.b	'Type',0
chk_normaltext:	dc.b	'Byte Type',0
chk_rgbtext:	dc.b	'RGB Type',0

		even

;--------------------------------------------------------------------------
;-------- Preference für Palette ------------------------------------------
;--------------------------------------------------------------------------
pal_gadsanz	=	10

pal_Prefs:
		lea	pal_outtag(pc),a0
		moveq	#0,d0
		move.b	pal_outtag_(a5),d0
		move.l	d0,(a0)

		lea	pal_form(pc),a0
		move.b	pal_formtag(a5),d0
		move.l	d0,(a0)

		lea	pal_depth(pc),a0
		move.b	pal_depthtag(a5),d0
		move.l	d0,(a0)
		
		lea	pal_lang(pc),a0
		move.b	pal_sourcetag(a5),d0
		move.l	d0,(a0)
		
		lea	pal_width(pc),a0
		move.b	pal_widthtag(a5),d0
		move.l	d0,(a0)
		
		lea	pal_Indent(pc),a0
		move.b	pal_intag(a5),d0
		move.l	d0,(a0)
		
		lea	lpl_tabs(pc),a0
		move.b	pal_indents(a5),d0
		move.l	d0,(a0)

		lea	lpl_entries(pc),a0
		move.b	pal_entri(a5),d0
		move.l	d0,(a0)
		

		move.l	#pal_WindowTags,APG_WindowTagList(a5) ;Tag list for the Window
		move.l	#pal_WinWG+4,APG_WGadgets(a5)	;addr. of WA_Gadgets Tag + 4
		move.l	#pal_winSC+4,APG_WScreen(a5)	;addr. of WA_CustomScreen Tag + 4
		move.l	#pal_window1,APG_WinWnd(a5)	;a point for the Window
		move.l	#pal_Glist,APG_Glist(a5)		;a point for the Glist
		move.l	#pal_NTypes,APG_NGads(a5)		;the NGads list
		move.l	#pal_Gtypes,APG_GTypes(a5)		;the GTypes list
		move.l	#pal_Gtags,APG_Gtags(a5)		;the Gtags list
		move.w	#pal_gadsanz,APG_CNT(a5)			;the number of Gadgets
		move.l	#pal_gadarray,APG_Gadgets(a5)	;a pointer for the Gadgetsarry, size=4*number of Gadgets
		move.l	APG_Scr(a5),APG_ScrBase(a5)	;the Screenpointer , stored in APG_Scr
	
		move.l	APG_CheckMainWinPos(a5),a6	;returns d0,d1 Pos
		jsr	(a6)

	;	add.w	#50,d0
		add.w	#100,d1
		
		move.w	d0,APG_WinLeft(a5)		;the left pos. of the Win
		move.w	d1,APG_WinTop(a5)		;the top pos. of the Win
		move.w	#367,APG_WinWidth(a5)		;the width of the Win
		move.w	#100,APG_WinHeight(a5)		;the height of the Win

		move.l	#pal_WinL,APG_WinL(a5)		;addr. of WA_Left Tag 
		move.l	#pal_WinT,APG_WinT(a5)		;addr. of WA_Top Tag
		move.l	#pal_WinW,APG_WinW(a5)		;addr. of WA_Width Tag
		move.l	#pal_WinH,APG_WinH(a5)		;addr. of WA_Height Tag

		move.l	APG_OpenWindow(a5),a6
		jsr	(a6)

		bsr.w	pal_checkghost

		lea	SRAW_Text0(pc),a2
		move.w	#SRAW_Project0_TNUM,APG_TNUM(a5)
		move.l	APG_Writetext(a5),a6
		jsr	(a6)

		move.l	pal_window1(pc),a0
		moveq	#3,d0
		moveq	#17,d1
		move.w	#178,d2
		move.w	#62,d3
		moveq	#0,d4	;Invert ?
		
		bsr.w	drawframe

		move.l	pal_window1(pc),a0
		move.w	#184,d0
		moveq	#17,d1
		move.w	#179,d2
		move.w	#62,d3
		moveq	#0,d4	;Invert ?
		
		bsr.w	drawframe

		lea	pal_asmsource(a5),a0
		lea	datapuffer,a1
		moveq	#pallen,d7
.np		move.b	(a0)+,(a1)+
		dbra	d7,.np

pal_wait_:	move.l	pal_window1(pc),a0
		move.l	APG_Wait(a5),a6
		jsr	(a6)				;Handle input

		cmp.l	#GADGETUP,d4
		beq.b	pal_gads_
		cmp.l	#CLOSEWINDOW,d4
		beq.b	pal_cancel
		bra.b	pal_wait_

pal_gads_:
		moveq	#0,d0
		move.w	38(a4),d0
		add.w	d0,d0
		lea	pal_Jumptab(pc),a0
		move.w	(a0,d0.l),d0
		jmp	(a0,d0.l)


pal_Jumptab:	dc.w	pal_ok-pal_Jumptab
		dc.w	pal_cancel-pal_Jumptab
		dc.w	pal_output-pal_Jumptab
		dc.w	pal_format-pal_jumptab
		dc.w	pal_handledepth-pal_jumptab
		dc.w	pal_language-pal_Jumptab
		dc.w	pal_widhtcheck-pal_Jumptab
		dc.w	pal_Indentcheck-pal_Jumptab
		dc.w	pal_Indent1check-pal_Jumptab
		dc.w	pal_Lineentries-pal_Jumptab
		
pal_ok:
		bra.w	pal_wech
pal_cancel:
		bra.w	pal_cancelwech
pal_output:
		move.b	d5,pal_outtag_(a5)
		lea	pal_outtag(pc),a0
		moveq	#3,d7
		lea	pal_source(a5),a1
		bra.w	pal_setflags

pal_format:
		move.b	d5,pal_formtag(a5)
		lea	pal_form(pc),a0
		moveq	#2,d7
		lea	pal_copper(a5),a1
		bra.w	pal_setflags

pal_handledepth:
		move.b	d5,pal_depthtag(a5)
		lea	pal_depth(pc),a0
		moveq	#1,d7
		lea	pal_depth4(a5),a1
		bra.w	pal_setflags
pal_language:
		move.b	d5,pal_sourcetag(a5)
		lea	pal_lang(pc),a0
		lea	pal_asmsource(a5),a1
		moveq	#4,d7
		bra.b	pal_setflags
pal_widhtcheck:
		move.b	d5,pal_widthtag(a5)
		lea	pal_width(pc),a0
		lea	pal_byte(a5),a1
		moveq	#2,d7
		bra.b	pal_setflags		
pal_Indentcheck:
		move.b	d5,pal_intag(a5)
		lea	pal_Indent(pc),a0
		lea	pal_dtabs(a5),a1
		moveq	#1,d7
		bra.b	pal_setflags
pal_Indent1check:
		lea	pal_gadarray(pc),a0
		move.w	38(a4),d0
		lsl.w	#2,d0
		move.l	(a0,d0.l),a0
		move.l	pal_window1(pc),a1
		bsr.w	getintegervalue
		move.b	d0,pal_indents(a5)
		bra.w	pal_wait_
pal_Lineentries:
		lea	pal_gadarray(pc),a0
		move.w	38(a4),d0
		lsl.w	#2,d0
		move.l	(a0,d0.l),a0
		move.l	pal_window1(pc),a1
		bsr.w	getintegervalue
		move.b	d0,pal_entri(a5)
		bra.w	pal_wait_

pal_cancelwech:
		lea	pal_asmsource(a5),a0
		lea	datapuffer,a1
		moveq	#pallen,d7
.np		move.b	(a1)+,(a0)+
		dbra	d7,.np

pal_wech:
		move.l	pal_window1(pc),a0
		move.l	APG_Intuitionbase(a5),a6
		jmp	_LVOCloseWindow(a6)

pal_setflags
		move.l	a1,a2
.nc:		clr.b	(a1)+
		dbra	d7,.nc

		ext.l	d5
		move.b	#1,(a2,d5.l)
		move.l	d5,(a0)
		bsr.b	pal_checkghost
		bra.w	pal_wait_
		
pal_checkghost:
		moveq	#0,d0
		tst.b	pal_source(a5)
		bne.b	.w
		moveq	#1,d0
.w
		lea	sraw_ghost(pc),a3
		move.l	d0,4(a3)

		moveq	#pal_GD_Language,d0
		bsr.b	pal_doghost
		moveq	#pal_GD_width,d0
		bsr.b	pal_doghost
		moveq	#pal_GD_Indent,d0
		bsr.b	pal_doghost
		moveq	#pal_GD_Indent1,d0
		bsr.b	pal_doghost
		moveq	#pal_GD_lineentries,d0
		bsr.b	pal_doghost

		moveq	#0,d0
		tst.b	pal_iff(a5)
		beq.b	.w1
		moveq	#1,d0
.w1
		lea	sraw_ghost(pc),a3
		move.l	d0,4(a3)

		moveq	#pal_GD_format,d0
		bsr.b	pal_doghost
		moveq	#pal_GD_depth,d0


pal_doghost:
		lea	pal_gadarray(pc),a0
		lsl.l	#2,d0
		move.l	(a0,d0.l),a0
		move.l	pal_window1(pc),a1
		sub.l	a2,a2
		lea	sraw_ghost(pc),a3
		move.l	gadbase(a5),a6
		jmp	_LVOGT_SetGadgetAttrsA(a6)


pal_window1:	dc.l	0		;Enthält pointer vom eingenen Window
pal_GList:	dc.l	0		
pal_gadarray:	dcb.l	10,0

	even

;-----------------------------------------------------------------------------
pal_WindowTags:
pal_winL:	dc.l	WA_Left,0
pal_winT:	dc.l	WA_Top,0
pal_winW:	dc.l	WA_Width,0
pal_winH:	dc.l	WA_Height,0
		dc.l	WA_IDCMP,CLOSEWINDOW!GADGETUP!VANILLAKEY!BUTTONIDCMP!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_CLOSEGADGET!WFLG_DEPTHGADGET!WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_SMART_REFRESH!WFLG_RMBTRAP
pal_winWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title,pal_winWTitle
pal_winSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

pal_WinWTitle:	dc.b	'Palette options',0
	even

pal_GD_Ok	=	0
pal_GD_Cancel	=	1
pal_GD_output	=	2
pal_GD_format	=	3
pal_GD_depth	= 	4
pal_GD_Language=	5
pal_GD_width	=	6
pal_GD_Indent	=	7
pal_GD_Indent1	=	8
pal_GD_lineentries =	9

pal_Gtypes:
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND

		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND
		dc.w	INTEGER_KIND
		dc.w	INTEGER_KIND

pal_GTags:
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,pal_OutputLabel
		dc.l	GTCY_ACTIVE
pal_outtag:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,pal_formLabel
		dc.l	GTCY_ACTIVE
pal_form:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,pal_depthLabel
		dc.l	GTCY_ACTIVE
pal_depth:	dc.l	0
		dc.l	TAG_DONE


		dc.l	GTCY_Labels,pal_LangLabel
		dc.l	GTCY_ACTIVE
pal_lang:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,pal_WidthLabel
		dc.l	GTCY_ACTIVE
pal_width:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,pal_IndentLabel
		dc.l	GTCY_ACTIVE
pal_Indent:	dc.l	0
		dc.l	TAG_DONE
pal_tabs:	dc.l	GTIN_Number
lpl_tabs:	dc.l	2
		dc.l	GTIN_MaxChars,2		;Tabs
		dc.l	STRINGA_Justification,GACT_STRINGRIGHT
		dc.l	TAG_DONE
pal_entries:	dc.l	GTIN_Number
lpl_entries:	dc.l	8
		dc.l	GTIN_MaxChars,2
		dc.l	STRINGA_Justification,GACT_STRINGRIGHT
		dc.l	TAG_DONE

pal_OutputLabel:
		dc.l	pal_OutputLab0
		dc.l	pal_OutputLab1
		dc.l	pal_OutputLab2
		dc.l	pal_OutputLab3
		dc.l	0

pal_formLabel:
		dc.l	pal_formLab0
		dc.l	pal_formLab1
		dc.l	pal_formLab2
		dc.l	0

pal_depthLabel:
		dc.l	pal_depthLab0
		dc.l	pal_depthLab1
		dc.l	0

pal_LangLabel:
		dc.l	LangLabel0
		dc.l	LangLabel1
		dc.l	LangLabel2
		dc.l	LangLabel3
		dc.l	LangLabel4
		dc.l	0
		
pal_WidthLabel:
		dc.l	Widthlabel0
		dc.l	Widthlabel1
		dc.l	Widthlabel2
		dc.l	0
		
pal_IndentLabel:
		dc.l	IndentLabel0
		dc.l	IndentLabel1
		dc.l	0


pal_depthLab0:	dc.b	'4 Bit',0
pal_depthLab1:	dc.b	'8 Bit',0

pal_formLab0:	dc.b	'Copper',0
pal_formLab1:	dc.b	'LoadRGB',0
pal_formLab2:	dc.b	'Pure',0

pal_OutputLab0:	dc.b	'Source',0
pal_OutputLab1:	dc.b	'Binary',0
pal_OutputLab2:	dc.b	'Link',0
pal_OutputLab3:	dc.b	'IFF',0

	even

pal_NTypes:
		dc.w    42,93-9,100,13
		dc.l    oktext,0
		dc.w    pal_GD_Ok
		dc.l    PLACETEXT_IN,0,0
		dc.w	224,93-9,100,13
		dc.l    canceltext,0
		dc.w    pal_GD_Cancel
		dc.l    PLACETEXT_IN,0,0
		dc.w	7,32,85,13
		dc.l	sraw_outtext,0
		dc.w	pal_GD_output
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	94,32,85,13
		dc.l	pal_formtext,0
		dc.w	pal_GD_format
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	50,65-2,85,13
		dc.l	pal_depthtext,0
		dc.w	pal_GD_depth
		dc.l	PLACETEXT_ABOVE,0,0


		dc.w	181+7,32,85,13
		dc.l	SRAW_langtext,0
		dc.w	pal_GD_Language
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	268+7,32,85,13
		dc.l	SRAW_widthtext,0
		dc.w	pal_GD_width
		dc.l	PLACETEXT_ABOVE,0,0

		dc.w	248,50-2,78,13
		dc.l	SRAW_indenttext,0
		dc.w	pal_GD_Indent
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	330,50-2,30,13
		dc.l	0,0
		dc.w	pal_GD_Indent1
		dc.l	0,0,0
		dc.w	330,65-2,30,13
		dc.l	SRAW_linetext,0
		dc.w	pal_GD_lineentries
		dc.l	PLACETEXT_LEFT,0,0

pal_formtext:	dc.b	'Type',0
pal_depthtext:	dc.b	'Depth',0

		even

;***************************************************************************
;*--------------------------- Save Colors ---------------------------------*
;***************************************************************************
savecolor:

;Prefs Kopieren für Source Engine

		lea	pal_asmsource(a5),a0
		lea	sasmsource(a5),a1
		move.l	(a0)+,(a1)+
		move.b	(a0),(a1)				

		lea	pal_byte(a5),a0
		lea	databyte(a5),a1
		move.w	(a0)+,(a1)+
		move.b	(a0),(a1)		

		moveq	#0,d0
		move.b	pal_indents(a5),d0
		move.l	d0,data_indents(a5)

		moveq	#0,d0
		move.b	pal_entri(a5),d0
		move.l	d0,data_datasPL(a5)
	
		move.b	pal_dtabs(a5),data_tab(a5)

;------------------------------------------------------------------------

		clr.b	agacolors(a5)
		cmp.w	#32,anzcolor(a5)
		bls.b	.noaga
		st	agacolors(a5)
.noaga:

		tst.b	pal_iff(a5)
		bne.w	savecoliff
		tst.b	pal_copper(a5)
		bne.b	savecopper
		tst.b	pal_loadrgb(a5)
		bne.b	savergb
		tst.b	pal_pure(a5)
		bne.w	savecoldatas
		bra.w	wech

savergb:
		tst.b	pal_depth4(a5)
		bne.w	savergb4
		bra.w	savergb32
		
;--- Save colors als Copper-list oder Asm-Source ---
savecopper:

;============================================================================
;   Save Copper binär non AGA
;============================================================================

co_binary:	;Copper als binär

		tst.b	pal_depth8(a5)
		bne.w	co_savebinaryaga

		tst.b	agacolors(a5)
		beq.b	.ok
		lea	tomanycolorsmsg(pc),a4
		bsr.w	status
		moveq	#-1,d3
		rts

;-- berechne pufferspeicher --
.ok:
		moveq	#0,d0
		move.w	anzcolor(a5),d0
		add.l	d0,d0
		add.l	d0,d0
		move.l	d0,linkobjektsize(a5)
		move.l	d0,brushmemsize(a5)

		tst.b	pal_link(a5)	;soll File als LinkObjekt gespeichert
		beq.b	.nolink		;werden
		bsr.w	writelinkheader
		tst.l	d7
		beq.b	.nolink
		moveq	#-1,d3
		rts
.nolink:
		tst.b	pal_source(a5)
		beq.b	.noall
		bsr.w	calclinemem
		tst.l	d0
		bne.w	nomem
		bra.b	.wei
.noall:
		move.l	linkobjektsize(a5),d0
		bsr.w	allocmem
		tst.l	d0
		beq.w	nomem

.wei
		tst.b	pal_source(a5)
		beq.b	.w
		lea	datapuffer,a4
		move.w	#250,datazaehler(a5)
		bra.b	.save
.w
		move.l	linemem(a5),a4

.save
		move.l	#$180,d0
		moveq	#0,d7
		move.w	anzcolor(a5),d7
		subq.l	#1,d7
		lea	farbtab4(a5),a1
.nextcolor
		move.w	d0,(a4)+
		tst.b	pal_source(a5)
		beq.b	.nd
		sub.w	#1,datazaehler(a5)
		bne.b	.nd
		move.l	d0,-(a7)
		bsr.w	da_savedatas
		move.l	(a7)+,d0
.nd:		
		move.w	(a1)+,(a4)+
		tst.b	pal_source(a5)
		beq.b	.nd1
		sub.w	#1,datazaehler(a5)
		bne.b	.nd1
		move.l	d0,-(a7)
		bsr.w	da_savedatas
		move.l	(a7)+,d0
.nd1:
		addq.w	#2,d0
		dbra	d7,.nextcolor
;		subq.l	#2,a1
		tst.b	pal_source(a5)
		beq.b	.s
		bsr.w	da_savedatas
		tst.b	saveflag(a5)
		beq.b	.we
		move.l	linememmerk(a5),a0
		move.b	#1,lastsave(a5)
		bsr.w	da_saveline
.we
		bsr.w	da_makeend
		bsr.w	da_memwech




		rts
.s		
		move.l	linemem(a5),d2
		sub.l	d2,a4
		move.l	a4,d3
		move.l	filehandle(a5),d1
		move.l	dosbase(a5),a6
		jsr	_LVOWrite(a6)

		tst.b	pal_link(a5)
		beq.b	.nol
		bsr.w	writelinkbottom
.nol:
		bra.w	endcolorsave
				
;======================================================================
;        Save Copper Binär AGA
;======================================================================
co_savebinaryaga:
		clr.b	merk2(a5)
		clr.b	merk1(a5)
		move.l	#32,bankcolor(a5)
		moveq	#0,d7
		move.w	anzcolor(a5),d7
		divu	#32,d7		;anzahl der verschiedenen Bänke
		tst.w	d7
		bne.b	.ok
		moveq	#0,d0
		move.w	anzcolor(a5),d0
		move.l	d0,bankcolor(a5)
		bra.b	.nos
.ok:
		subq.l	#1,d7
.nos:
		move.w	anzcolor(a5),d0
		move.l	d0,d1
		add.l	#31,d0
		lsr.l	#5,d0
		move.l	d0,d2
		mulu	#4,d0
		lsl.l	#2,d1
		add.l	d1,d0
		add.l	d0,d0
		move.l	d0,linkobjektsize(a5)
		move.l	d0,brushmemsize(a5)
;		move.l	#2112,d0	;einfach größter wert

		tst.b	pal_source(a5)
		beq.b	.testlink
	move.l	d7,-(a7)
		bsr.w	calclinemem
	move.l	(a7)+,d7
		tst.l	d0
		bne.w	nomem
		bra.b	.noli
.testlink:
		
		tst.b	pal_link(a5)
		beq.b	.nolink1
		move.l	d7,-(a7)
		bsr.w	writelinkheader
		tst.l	d7
		beq.b	.nolink
		move.l	(a7)+,d7
		moveq	#-1,d3
		rts
.nolink:
		move.l	(a7)+,d7
.nolink1:
		move.l	linkobjektsize(a5),d0
		bsr.w	allocmem
		tst.l	d0
		beq.w	nomem
;--- Fülle zeilen ---

.noli:
		sub.l	a1,a1		;offset für Farbtab
		move.l	#$c00,d5	;bankunschaltwert init
		move.l	linemem(a5),a4
		tst.b	pal_source(a5)
		beq.b	bnewbank
		lea	datapuffer,a4
		move.w	#250,datazaehler(a5)

Bnewbank:
		lea	farbtab8+4(a5),a2	;Controlword überspringen
		add.l	a1,a2
		move.l	#$180,d3
Bwritebank:
		move.l	bankcolor(a5),d4
		subq.l	#1,d4
;		move.l	#31,d4		;Anzahl Farben (einträge) pro Bank

		move.b	#1,merk1(a5)	;es wird völlig neu angefangen
Bco_aganextl:
;		move.l	#31,d6		;größe einer Bank

		tst.b	merk1(a5)	;muß $106 geschieben werden
		beq.b	bcol_goon
		move.w	#$0106,(a4)+

	tst.b	pal_source(a5)
	beq.b	.ns
	sub.w	#1,datazaehler(a5)
	bne.b	.ns
	bsr.w	da_savedatas
.ns:
		move.w	d5,(a4)+	;Bankumschaltwert
	tst.b	pal_source(a5)
	beq.b	.ns1
	sub.w	#1,datazaehler(a5)
	bne.b	.ns1
	bsr.w	da_savedatas
.ns1:
		clr.b	merk1(a5)

bcol_goon:
		move.w	d3,(a4)+	;schreibe register
		tst.b	pal_source(a5)
		beq.b	.ns2
		sub.w	#1,datazaehler(a5)
		bne.b	.ns2
		bsr.w	da_savedatas

.ns2:		tst.b	merk2(a5)
		bne.b	.setlow		;test ob höher oder niederwertige
					;bits geschieben werden sollen
;--- Setzte Farbwert für die höheren Bits zusammen ---

		bsr.w	sethigh

		bra.b	bcol_write

;--- Setzte Farbwert für die niederwertigen Bits zusammen ---
.setlow:
		bsr.w	setlow
		
bcol_write:
		move.w	d0,(a4)+
		tst.b	pal_source(a5)
		beq.b	.ns3
		subq.w	#1,datazaehler(a5)
		bne.b	.ns3
		bsr.w	da_savedatas
.ns3:		
		addq.l	#2,d3		;register erhöhen

		dbra	d4,Bcol_goon
bnextbank:
		tst.b	merk2(a5)
		beq.b	bwritesecondbank
		clr.b	merk2(a5)
		bclr	#9,d5
		add.l	#$2000,d5
		add.l	#32*4*3,a1		
		dbra	d7,bnewbank

		tst.b	pal_source(a5)
		beq.b	.savebin
		bsr.w	da_savedatas
		tst.b	saveflag(a5)
		beq.b	.we
		move.l	linememmerk(a5),a0
		move.b	#1,lastsave(a5)
		bsr.w	da_saveline
.we
		bsr.w	da_makeend
		bra.w	da_memwech

.savebin:
		move.l	a4,a0
		bsr.w	col_writeline1

		tst.b	pal_link(a5)
		beq.w	endcolorsave

		bsr.w	writelinkbottom

		bra.w	endcolorsave

bwritesecondbank:
		bset	#9,d5
		move.b	#1,merk2(a5)
		bra.w	bnewbank

	;*-------- Save Color als RGB4 Tab --------*
savergb4:
		
rgb4_binary:
		lea	farbtab4(a5),a1
		move.l	a1,d2
		move.l	filehandle(a5),d1
		moveq	#0,d3
		move.w	anzcolor(a5),d3
		add.l	d3,d3
		move.l	d3,linkobjektsize(a5)
		move.l	d3,brushmemsize(a5)

		tst.b	pal_source(a5)
		bne.b	savergb4source
		tst.b	pal_link(a5)
		beq.b	.w
		bsr.w	writelinkheader
		tst.l	d7
		beq.b	.nolink
		moveq	#-1,d3
		rts
.nolink:
	
.w:		move.l	dosbase(a5),a6
		jsr	_LVOwrite(a6)

		tst.b	pal_link(a5)
		beq.b	.wech
		bsr.w	writelinkbottom
.wech
		rts

savergb4source:
		bsr.w	calclinemem
		tst.l	d0
		bne.w	nomem
		lea	datapuffer,a4
		move.w	#250,datazaehler(a5)

		lea	farbtab4(a5),a1	;Farbtab
		move.w	anzcolor(a5),d3
		subq.w	#1,d3
.nc:
		move.w	(a1)+,(a4)+
		subq.w	#1,datazaehler(a5)
		bne.b	.ns
		bsr.w	da_savedatas
.ns:
		dbra	d3,.nc		
			
		bsr.w	da_savedatas
		tst.b	saveflag(a5)
		beq.b	.we
		move.l	linememmerk(a5),a0
		move.b	#1,lastsave(a5)
		bsr.w	da_saveline
.we
		bsr.w	da_makeend
		bsr.w	da_memwech
		rts

decodier2:
		moveq	#0,d3
		move.b	(a0)+,d1
		ror.b	#5,d1
		add.b	d1,d3
		move.b	(a0)+,d0
		move.b	d0,d2
		rol.b	#1,d0
		eor.b	d1,d0
		move.b	d0,d7
		ext.w	d7
		subq.w	#1,d7
		cmp.b	(a1)+,d0	;länge
		bne.w	keyfault
		move.b	d2,d1
.nc		move.b	(a0)+,d0
		move.b	d0,d2
		ror.b	#4,d0
		eor.b	d1,d0
		add.b	d0,d3
		cmp.b	(a1)+,d0
		bne.w	keyfault1
		move.b	d2,d1
		dbra	d7,.nc		
		move.b	(a0)+,d0
		rol.b	#4,d0
		eor.b	d1,d0
		cmp.b	d0,d3
		beq.b	.ok
		moveq	#0,d0
.ok:		rts

		
	;*-------- Save Color als RGB32 Tab --------*
savergb32:

rgb32_binary:
		moveq	#0,d3
		move.w	anzcolor(a5),d3
		mulu	#3*4,d3
		add.l	#8,d3
		move.l	d3,linkobjektsize(a5)
		move.l	d3,brushmemsize(a5)
		tst.b	pal_source(a5)
		bne.b	savergb32source
		tst.b	pal_link(a5)
		beq.b	.nl
		bsr.w	writelinkheader
		tst.l	d7
		beq.b	.nl
		moveq	#-1,d3
		rts
.nl:		lea	farbtab8(a5),a1
		move.l	a1,d2
		move.l	filehandle(a5),d1
		move.l	dosbase(a5),a6
		jsr	_LVOWrite(a6)
		tst.b	pal_link(a5)
		beq.b	.nl1
		bsr.w	writelinkbottom

.nl1:		rts

savergb32source:
		bsr.w	calclinemem
		tst.l	d0
		bne.w	nomem
		move.l	brushmemsize(a5),d7
		lsr.l	#1,d7		;in Worte umwandeln
		subq.l	#1,d7
		lea	datapuffer,a4
		move.w	#250,datazaehler(a5)

		lea	farbtab8(a5),a1	;Farbtab
.nc:
		move.w	(a1)+,(a4)+
		subq.w	#1,datazaehler(a5)
		bne.b	.ns
		bsr.w	da_savedatas
.ns:
		dbra	d7,.nc		
			
		bsr.w	da_savedatas
		tst.b	saveflag(a5)
		beq.b	.we
		move.l	linememmerk(a5),a0
		move.b	#1,lastsave(a5)
		bsr.w	da_saveline
.we
		bsr.w	da_makeend
		bsr.w	da_memwech
		rts


	;*-------- Save Color als Datas --------*
savecoldatas:
		tst.b	pal_depth4(a5)
		bne.w	savergb4

	;--Brechne Puffer --
col32bin:
		moveq	#0,d0
		move.w	anzcolor(a5),d0
		add.l	d0,d0
		add.l	d0,d0
		move.l	d0,linkobjektsize(a5)
		move.l	d0,brushmemsize(a5)

		tst.b	pal_source(a5)
		beq.b	.testlink
		bsr.w	calclinemem
		tst.l	d0
		bne.w	nomem
		lea	datapuffer,a4
		move.w	#250,datazaehler(a5)
		bra.b	.save

.testlink:	tst.b	pal_link(a5)
		beq.b	.w
		bsr.w	writelinkheader	
		tst.l	d7
		beq.b	.nolink
		moveq	#-1,d3
		rts
.nolink:
.w:
		bsr.w	allocmem
		tst.l	d0
		beq.w	nomem

		move.l	linemem(a5),a4
.save
		lea	farbtab8+4(a5),a1

		move.w	anzcolor(a5),d7
		subq.w	#1,d7
.next:
		bsr.w	contodata
		
		move.l	d0,(a4)+
		tst.b	pal_source(a5)
		beq.b	.nc
		subq.w	#2,datazaehler(a5)
		bne.b	.nc
		bsr.w	da_savedatas

.nc		dbra	d7,.next

		tst.b	pal_source(a5)
		beq.b	.savebin
		bsr.w	da_savedatas
		tst.b	saveflag(a5)
		beq.b	.we
		move.l	linememmerk(a5),a0
		move.b	#1,lastsave(a5)
		bsr.w	da_saveline
.we
		bsr.w	da_makeend
		bra.w	da_memwech


.savebin:
		move.l	a4,a0
		bsr.w	col_writeline1
		tst.b	pal_link(a5)
		beq.b	.w1
		bsr.w	writelinkbottom
.w1
		bra.w	endcolorsave
				
;------------------------------------------------------------------
	;*-------- Save Color als IFF --------*
savecoliff:
	;-- berechne puffer

		moveq	#0,d0
		move.w	anzcolor(a5),d0
		mulu	#3,d0
		add.l	#20,d0
		move.l	d0,d6
		bsr.b	allocmem
		tst.l	d0
		beq.w	nomem

		move.l	linemem(a5),a0
		lea	farbtab8+4(a5),a1

		move.l	#'FORM',(a0)+
		move.l	d6,d0
		sub.l	#8,d0
		move.l	d0,(a0)+	;länge aller Chunks
		move.l	#'ILBM',(a0)+
		move.l	#'CMAP',(a0)+
		sub.l	#20,d6
		move.l	d6,(a0)+
		
		move.w	anzcolor(a5),d7
		subq.w	#1,d7
				
.nextentry:
		moveq	#2,d6		;Save AGA-Colors
.nc:
		move.l	(a1)+,d0
		swap	d0
		lsr.l	#8,d0
		move.b	d0,(a0)+
		dbra	d6,.nc		

		dbra	d7,.nextentry

		bsr.b	col_writeline1
		bra.b	endcolorsave
		
;=========================================================================
allocmem:
		move.l	4,a6
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		jsr	_LVOAllocVec(a6)
		move.l	d0,linemem(a5)
		rts

col_writeline:

		move.b	#10,-(a0)
		addq.l	#1,a0
col_writeline1:
		move.l	linemem(a5),d2
		sub.l	d2,a0	;gesamtläge der Zeile
		move.l	a0,d3
		move.l	filehandle(a5),d1
		move.l	dosbase(a5),a6
		movem.l	a1-a2,-(a7)
		jsr	_LVOwrite(a6)
		movem.l	(a7)+,a1-a2
		rts

endcolorsave:
		move.l	linemem(a5),a1
		cmp.l	#0,a1
		beq.b	wech
		move.l	4,a6
		jsr	_LVOFreeVec(a6)
		clr.l	linemem(a5)
wech:
endsave:
		rts

sethigh:			;setzte die höherwertigen bits
		moveq	#0,d0
		move.l	(a2)+,d1
		swap	d1
		lsr.l	#4,d1
		and.l	#$f00,d1		
		or.l	d1,d0
		move.l	(a2)+,d1
		swap	d1
		lsr.l	#8,d1		
		and.l	#$f0,d1
		or.l	d1,d0
		move.l	(a2)+,d1
		rol.l	#4,d1
		and.l	#$f,d1
		or.l	d1,d0		
		rts
		
setlow:
		moveq	#0,d0
		move.l	(a2)+,d1
		swap	d1
		and.l	#$f00,d1
		or.l	d1,d0
		move.l	(a2)+,d1
		swap	d1
		lsr.l	#4,d1
		and.l	#$f0,d1
		or.l	d1,d0
		move.l	(a2)+,d1
		swap	d1
		lsr.l	#8,d1
		and.l	#$f,d1
		or.l	d1,d0
		rts

concolor:
		moveq	#0,d0
		move.l	(a1)+,d1
		swap	d1
		lsr.l	#8,d1
		mulu	#15,d1
		divu	#255,d1
		lsl.l	#8,d1
		or.w	d1,d0
		move.l	(a1)+,d1
		swap	d1
		lsr.l	#8,d1
		mulu	#15,d1
		divu	#255,d1
		lsl.l	#4,d1
		or.w	d1,d0
		move.l	(a1)+,d1
		swap	d1
		lsr.l	#8,d1
		mulu	#15,d1
		divu	#255,d1
		or.w	d1,d0
		rts
contodata:
		moveq	#0,d0
		move.l	(a1)+,d1
		lsr.l	#8,d1
		or.l	d1,d0
		move.l	(a1)+,d1
		swap	d1
		or.l	d1,d0
		move.l	(a1)+,d1
		swap	d1
		lsr.l	#8,d1
		or.l	d1,d0
		rts
nomem:
		lea	notmemmsg(pc),a4
		bsr.w	status
		moveq	#-1,d3
jumpback
		rts
				
;***************************************************************************
;*------------------------- Save Image als Hex-Datas ----------------------*
;***************************************************************************
savedatas:

da_savedatas:
		moveq	#0,d0
		move.w	datazaehler(a5),d0
		move.l	#250,d1
		sub.l	d0,d1
		beq.b	jumpback
		move.l	d1,datasmerk(a5) ;wieviel worte geschrieben werden müssen
		clr.b	saveflag(a5)

		tst.b	datalongword(a5)
		beq.b	da_saveit		;wenn longs nicht aufgehen
		moveq	#0,d0			;wird ein leerword dazu
		move.l	datasmerk(a5),d0	;addiert
		move.l	d0,d1
		lsr.l	#1,d0
		lsl.l	#1,d0
		cmp.l	d0,d1
		beq.b	da_saveit
		move.w	#0,(a4)+
		addq.l	#1,datasmerk(a5)


da_saveit:	tst.b	sasmsource(a5)
		bne.b	da_saveasm
		tst.b	sesource(a5)
		bne.w	da_saveasm

da_saveasm:
		movem.l	d0-a6,-(a7)
		move.l	datapuffermerk(a5),a4
		move.l	linememmerk(a5),a0
		clr.b	endmerk(a5)

		tst.b	datalongword(a5)
		bne.w	savelongs
		tst.b	dataword(a5)
		bne.w	savewords

;=========================================================================
savebytes:

da_Bnewline:
		tst.b	endmerk(a5)
		bne.w	da_end
		tst.b	newlinemerk(a5)
		beq.b	da_bnewword
		bsr.w	da_makenewline	;save datas als Bytes
		clr.b	newlinemerk(a5)

da_Bnewword:
		tst.b	kommaflag(a5)
		beq.b	.nokomma
		move.b	#",",(a0)+
		clr.b	kommaflag(a5)
.nokomma:
		tst.b	restmerk(a5)	;ist noch was von der letzten zeile
		beq.b	.da_nichts		;übrig
		lea	zpuff+6(pc),a1
		tst.b	scsource(a5)
		beq.b	.o
		move.b	#'0',(a0)+	;für C Sources
		move.b	#'x',(a0)+
		bra.b	.o1
.o		move.b	#"$",(a0)+
.o1		move.b	(a1)+,(a0)+
		move.b	(a1),(a0)+
		move.b	#",",(a0)+		
		clr.b	restmerk(a5)
		subq.l	#1,linedatasmerk(a5)
		beq.w	da_lineend
		tst.b	endmerk(a5)
		beq.b	.da_nichts
;		bsr.w	da_saveline		
		move.b	#1,saveflag(a5)
		move.l	a0,linememmerk(a5)	????
		move.b	#",",(a0)+
		movem.l	(a7)+,d0-a6
		move.w	#250,datazaehler(a5)
		lea	datapuffer,a4
		rts

.da_nichts:
		move.w	(a4)+,d0	;hole ein wort
		subq.l	#1,datasmerk(a5)
		bne.b	.w
		move.b	#1,endmerk(a5)
.w		
		bsr.w	hexascii

		lea	zpuff+4(pc),a1
		tst.b	scsource(a5)
		beq.b	.ok
		move.b	#'0',(a0)+	;für C Sources
		move.b	#'x',(a0)+
		bra.b	.ok1
.ok:		move.b	#"$",(a0)+
.ok1:
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		subq.l	#1,linedatasmerk(a5)
		bne.b	.da_noend1		;Zeile zuende ?

		move.b	#1,restmerk(a5)
		bra.b	da_lineend
.da_noend1:
		move.b	#",",(a0)+
		tst.b	scsource(a5)
		beq.b	.ok2
		move.b	#'0',(a0)+	;für C Sources
		move.b	#'x',(a0)+
		bra.b	.ok3
.ok2:
		move.b	#"$",(a0)+
.ok3:		move.b	(a1)+,(a0)+
		move.b	(a1),(a0)+
		subq.l	#1,linedatasmerk(a5)
		bne.b	.da_noend2		;Zeile zuende ?
		bra.b	da_lineend
.da_noend2:
		tst.b	endmerk(a5)
		beq.b	.w1
		move.b	#1,saveflag(a5)
		move.b	#1,kommaflag(a5)
	;	move.b	#",",(a0)+
		bra.b	da_end	
.w1		move.b	#",",(a0)+
		bra.w	da_bnewword
						
da_lineend:
		tst.b	scsource(a5)
		bne.b	.k
		tst.b	spascal(a5)
		beq.b	.nc
.k		move.b	#',',(a0)+
.nc		move.b	#10,(a0)+
		bsr.w	da_saveline		
		clr.b	saveflag(a5)
		move.b	#1,newlinemerk(a5)
		subq.l	#1,lines(a5)
		bne.w	da_Bnewline

da_end:
		move.l	a0,linememmerk(a5)	????
		movem.l	(a7)+,d0-a6
		move.w	#250,datazaehler(a5)
		lea	datapuffer,a4
		rts

;=========================================================================
savewords:

da_Wnewline:
		tst.b	endmerk(a5)
		bne.b	da_end
		tst.b	newlinemerk(a5)
		beq.b	da_Wnewword
		bsr.w	da_makenewline	
		clr.b	newlinemerk(a5)

da_Wnewword:
		tst.b	kommaflag(a5)
		beq.b	.nokomma
		move.b	#",",(a0)+
		clr.b	kommaflag(a5)
.nokomma:
		move.w	(a4)+,d0
		subq.l	#1,datasmerk(a5)
		bne.b	.w
		move.b	#1,endmerk(a5)
.w
		bsr.w	hexascii

		lea	zpuff+4(pc),a1
		tst.b	scsource(a5)
		beq.b	.ok
		move.b	#'0',(a0)+
		move.b	#'x',(a0)+
		bra.b	.ok1
.ok:		move.b	#"$",(a0)+
.ok1:		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1),(a0)+
		subq.l	#1,linedatasmerk(a5)
		beq.b	da_WLineend
		move.b	#1,kommaflag(a5)
;		move.b	#",",(a0)+
		tst.b	endmerk(a5)
		beq.b	da_Wnewword
		move.b	#1,saveflag(a5)
		bra.w	da_end
						
da_Wlineend:
		tst.b	scsource(a5)
		bne.b	.k
		tst.b	spascal(a5)
		beq.b	.nc
.k		move.b	#',',(a0)+
.nc:		move.b	#10,(a0)+
		bsr.w	da_saveline		
		clr.b	saveflag(a5)
		move.b	#1,newlinemerk(a5)
		subq.l	#1,lines(a5)
		bne.w	da_Wnewline
		bra.w	da_end

;=========================================================================
savelongs:
		
da_Lnewline:
		tst.b	endmerk(a5)
		bne.w	da_end
		tst.b	newlinemerk(a5)
		beq.b	da_Lnewword
		bsr.w	da_makenewline	
		clr.b	newlinemerk(a5)

da_Lnewword:
		tst.b	kommaflag(a5)
		beq.b	.nokomma
		move.b	#",",(a0)+
		clr.b	kommaflag(a5)
.nokomma:

		move.w	(a4)+,d0
		subq.l	#1,datasmerk(a5)
		bne.b	.w
		move.b	#1,endmerk(a5)
.w		
		bsr.w	hexascii

		lea	zpuff+4(pc),a1
		tst.b	scsource(a5)
		beq.b	.ok
		move.b	#'0',(a0)+
		move.b	#'x',(a0)+
		bra.b	.ok1
.ok		move.b	#"$",(a0)+
.ok1		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1),(a0)+

		tst.b	endmerk(a5)
		beq.b	.da_noend1
		move.b	#1,saveflag(a5)
		bra.w	da_end
		
;		move.b	#'0',(a0)+
;		move.b	#'0',(a0)+
;		move.b	#'0',(a0)+
;		move.b	#'0',(a0)+
;		bra.w	da_saveline
.da_noend1:
		move.w	(a4)+,d0
		subq.l	#1,datasmerk(a5)
		bne.b	.w1
		move.b	#1,endmerk(a5)
.w1		
		bsr.w	hexascii
		lea	zpuff+4(pc),a1
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1),(a0)+

		subq.l	#1,linedatasmerk(a5)
		beq.b	da_Llineend

		move.b	#1,kommaflag(a5)
		tst.b	endmerk(a5)
		beq.b	da_Lnewword
		move.b	#1,saveflag(a5)
		bra.w	da_end
		
da_Llineend:
		tst.b	scsource(a5)
		bne.b	.k
		tst.b	spascal(a5)
		beq.b	.nc
.k		move.b	#',',(a0)+
.nc		move.b	#10,(a0)+
		bsr.w	da_saveline		
		clr.b	saveflag(a5)
		move.b	#1,newlinemerk(a5)
		subq.l	#1,lines(a5)
		bne.w	da_Lnewline

		bra.w	da_end

;====== Unterroutinen für Datasave ==========

;Berechen Zeilengröße
calclinemem:
		clr.b	endmerk(a5)
		clr.b	restmerk(a5)
		clr.b	kommaflag(a5)
		clr.b	lastsave(a5)
		move.b	#1,newlinemerk(a5)
		move.l	#datapuffer,datapuffermerk(a5)
		
		move.l	data_indents(a5),d0
		addq.l	#5,d0		;für dc.? + tab
		tst.b	scsource(a5)
		beq.b	.nc
		addq.l	#2,d0
.nc:
		move.l	#10,d1		;für longword
		moveq	#4,d3
		move.b	#'l',da_lenght
		tst.b	datalongword(a5)
		bne.b	.ok
		moveq	#6,d1		;für Word
		moveq	#2,d3
		move.b	#'w',da_lenght
		tst.b	dataword(a5)
		bne.b	.ok
		moveq	#5,d1		;für Byte
		moveq	#1,d3
		move.b	#'b',da_lenght
.ok:		
		tst.b	scsource(a5)
		beq.b	.ncs
		addq.l	#2,d1		;für 0x in C
.ncs:
		move.l	data_datasPL(a5),d2
		tst.l	d2
		bne.b	da_nichtnull
		move.l	brushmemsize(a5),d2	;alles in eine Zeile

da_nichtnull:		
		moveq	#0,d7
		subq.l	#1,d1
.da_back:
		add.l	d2,d7
		dbra	d1,.da_back	;simuliert mulu.l

		add.l	d7,d0

		addq.l	#2,d0	;prophylaktisch für komma

		move.l	d0,linememsize(a5) ;Speicher für eine Zeile
		
		moveq	#0,d7
		subq.l	#1,d3
.da_back1:	add.l	d2,d7
		dbra	d3,.da_back1

;		mulu	d3,d2		;Bytes pro Zeile

		move.l	d7,d2

		move.l	brushmemsize(a5),d0
		cmp.l	d2,d0
		bne.b	da_divok
		moveq	#1,d0
		bra.b	da_weiter
da_divok:
		divu	d2,d0		;Wieviel Zeilen ?
		swap	d0
		tst.w	d0
		beq.b	da_gehtauf
		add.l	#$10000,d0
da_gehtauf:
		swap	d0
		ext.l	d0
da_weiter:
		move.l	d0,lines(a5)

;Allociere Speicher für eine Zeile
		
		move.l	linememsize(a5),d0
		move.l	4,a6
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		jsr	_LVOAllocVec(a6)
		move.l	d0,linemem(a5)
		move.l	d0,linememmerk(a5)
		bne.b	.w
		moveq	#-1,d0
		rts
.w
		tst.b	scsource(a5)
		beq.b	.wech
		tst.b	datalongword(a5)
		beq.b	.nl
		lea	da_ulong(pc),a0
.nl:		tst.b	dataword(a5)
		beq.b	.nw
		lea	da_ushort(pc),a0
.nw:		tst.b	databyte(a5)
		beq.b	.nb
		lea	da_ubyte(pc),a0
.nb:
		move.l	filehandle(a5),d1
		move.l	a0,d2
		moveq	#18,d3
		move.l	dosbase(a5),a6
		jsr	_LVOWrite(a6)

.wech:
		tst.b	spascal(a5)
		beq.b	.realwech

		move.l	brushmemsize(a5),d0
		tst.b	datalongword(a5)
		beq.b	.nlw
		addq.l	#3,d0
		lsr.l	#2,d0		;berechne wieviele Einträge im Array
		subq.l	#1,d0
		lea	da_paslong(pc),a3
		moveq	#12,d5
		bra.b	.doit
.nlw:
		tst.b	dataword(a5)
		beq.b	.ndw
		lsr.l	#1,d0
		subq.l	#1,d0
		lea	da_pasword(pc),a3
		moveq	#9,d5
		bra.b	.doit
.ndw:
		subq.l	#1,d0		;dann sind es nur noch bytes
		lea	da_pasbyte(pc),a3
		moveq	#9,d5
.doit
		bsr.w	hexascii
		lea	zpuff(pc),a0
		lea	da_paszaehler(pc),a1
		moveq	#7,d7
.nz		move.b	(a0)+,(a1)+
		dbra	d7,.nz
		
		move.l	filehandle(a5),d1
		lea	da_pascalheader(pc),a0
		move.l	a0,d2
		moveq	#39,d3
		move.l	dosbase(a5),a6
		jsr	_LVOWrite(a6)

		move.l	filehandle(a5),d1
		move.l	a3,d2
		move.l	d5,d3
		jsr	_LVOWrite(a6)

.realwech:	moveq	#0,d0
		rts

da_nomem:
		lea	notmemmsg(pc),a4
		bsr.w	status
		moveq	#-1,d3
		rts
da_makenewline:
		move.l	linemem(a5),a0
		move.l	data_datasPL(a5),d0
		tst.l	d0
		bne.b	.da_oneLine
		move.l	#-1,d0
.da_oneLine:	move.l	d0,linedatasmerk(a5)

		move.l	data_indents(a5),d0
		beq.b	.notab
		subq.l	#1,d0
		moveq	#9,d1
		tst.b	data_tab(a5)
		bne.b	.ok
		moveq	#32,d1
.ok:
		move.b	d1,(a0)+
		dbra	d0,.ok
.notab:		tst.b	scsource(a5)
		bne.b	.w
		tst.b	spascal(a5)
		bne.b	.w
		tst.b	sesource(a5)
		bne.b	da_makeEandBasic
		tst.b	sbasic(a5)
		bne.b	da_makeEandBasic
		move.b	#'d',(a0)+
		move.b	#'c',(a0)+
		move.b	#'.',(a0)+
		move.b	da_lenght(pc),(a0)+
		move.b	#9,(a0)+
.w
		rts

da_makeEandBasic:
		tst.b	sbasic(a5)
		beq.b	.nba
		lea	da_data(pc),a2
		bra.b	.nb
.nba:		tst.b	datalongword(a5)
		beq.b	.nlw
		lea	da_long(pc),a2
.nlw:
		tst.b	dataword(a5)
		beq.b	.nw
		lea	da_int(pc),a2
.nw:
		tst.b	databyte(a5)
		beq.b	.nb
		lea	da_char(pc),a2
.nb:
		moveq	#3,d1
.nc:		move.b	(a2)+,(a0)+
		dbra	d1,.nc
		move.b	#9,(a0)+
		rts

da_saveline:
		tst.b	lastsave(a5)
		beq.b	.nk
		tst.b	scsource(a5)
		beq.b	.nc
		move.b	#',',(a0)+
.nc:		tst.b	spascal(a5)
		beq.b	.np
		move.b	#',',(a0)+
.np:		move.b	#10,(a0)+
.nk		move.l	linemem(a5),d2
		sub.l	d2,a0
		move.l	a0,d3		
		move.l	filehandle(a5),d1
		move.l	dosbase(a5),a6
		jsr	_LVOWrite(a6)
		move.l	linemem(a5),a0
		rts


da_makeend:	lea	da_endsource(pc),a0
		tst.b	scsource(a5)
		beq.b	.nc
		move.b	#'}',(a0)
		bra.b	.w
.nc		tst.b	spascal(a5)
		beq.b	da_w
		move.b	#')',(a0)
.w:
		move.l	a0,d2
		move.l	filehandle(a5),d1
		moveq	#2,d3
		move.l	dosbase(a5),a6
		jsr	_LVOWrite(a6)
da_w
		rts
		
decodier1:
		moveq	#0,d3
		move.b	(a0)+,d1
		ror.b	#3,d1
		add.b	d1,d3
		move.b	(a0)+,d0
		move.b	d0,d2
		rol.b	#3,d0
		eor.b	d1,d0
		move.b	d0,(a1)+	;länge
		moveq	#0,d7
		move.b	d0,d7
		subq.w	#1,d7
		move.l	d7,d6
		move.b	d2,d1
.nc1:		move.b	(a0)+,-(sp)
		dbra	d6,.nc1

.nc		move.b	(sp)+,d0
		move.b	d0,d2
		ror.b	#2,d0
		eor.b	d1,d0
		add.b	d0,d3
		move.b	d0,(a1)+
		move.b	d2,d1
		dbra	d7,.nc

		move.b	(a0)+,d0
		rol.b	#3,d0
		eor.b	d1,d0
		sub.b	d0,d3
		bne.w	keyfault
		rts

da_memwech:
		move.l	linemem(a5),a1
		cmp.l	#0,a1
		beq.b	da_w
		move.l	4,a6
		jsr	_LVOFreeVec(a6)
		clr.l	linemem(a5)
		rts

da_lenght:	dc.b	'b'
	even
da_char:	dc.b	'CHAR'
da_int:		dc.b	'INT '
da_long:	dc.b	'LONG'

da_data:	dc.b	'DATA'

da_ubyte:	dc.b	'UBYTE  data[] =',10,'{',10
da_ushort:	dc.b	'UWORD  data[] =',10,'{',10
da_ulong:	dc.b	'ULONG  data[] =',10,'{',10

da_endsource:	dc.b	'};'

da_pascalheader:dc.b	'Const',10,'  Data : Array[$0..$'
da_paszaehler:	dc.b	'00000000] of '
da_paslong:	dc.b	'LongInt =',10,'(',10
da_pasword:	dc.b	'Word =',10,'(',10
da_pasbyte:	dc.b	'Byte =',10,'(',10
	even


;---------------------------------------------------------------------------
;---------- Prefs für Sprite Saver -----------------------------------------
;---------------------------------------------------------------------------
spr_prefs:

spr_gadsanz	=	12

		lea	spr_outtag(pc),a0
		moveq	#0,d0
		move.b	spr_outtag_(a5),d0
		move.l	d0,(a0)

		lea	spr_color(pc),a0
		move.b	spr_0416tag(a5),d0
		move.l	d0,(a0)

		lea	spr_spwidth(pc),a0
		move.b	spr_spritewidthtag(a5),d0
		move.l	d0,(a0)

		lea	spr_ctrlw(pc),a0
		move.b	spr_cwtag(a5),d0
		move.l	d0,(a0)

		lea	spr_lang(pc),a0
		move.b	spr_sourcetag(a5),d0
		move.l	d0,(a0)
		
		lea	spr_width(pc),a0
		move.b	spr_widthtag(a5),d0
		move.l	d0,(a0)
		
		lea	spr_Indent(pc),a0
		move.b	spr_intag(a5),d0
		move.l	d0,(a0)
		
		lea	spr_tabs(pc),a0
		move.b	spr_indents(a5),d0
		move.l	d0,(a0)

		lea	spr_entries(pc),a0
		move.b	spr_entri(a5),d0
		move.l	d0,(a0)
		
		lea	spr_label(pc),a0
		move.b	spr_uselabels(a5),d0
		move.l	d0,(a0)

		move.l	#spr_WindowTags,APG_WindowTagList(a5) ;Tag list for the Window
		move.l	#spr_WinWG+4,APG_WGadgets(a5)	;addr. of WA_Gadgets Tag + 4
		move.l	#spr_winSC+4,APG_WScreen(a5)	;addr. of WA_CustomScreen Tag + 4
		move.l	#spr_window,APG_WinWnd(a5)	;a point for the Window
		move.l	#spr_Glist,APG_Glist(a5)		;a point for the Glist
		move.l	#spr_NTypes,APG_NGads(a5)		;the NGads list
		move.l	#spr_Gtypes,APG_GTypes(a5)		;the GTypes list
		move.l	#spr_Gtags,APG_Gtags(a5)		;the Gtags list
		move.w	#spr_gadsanz,APG_CNT(a5)			;the number of Gadgets
		move.l	#spr_gadarray,APG_Gadgets(a5)	;a pointer for the Gadgetsarry, size=4*number of Gadgets
		move.l	APG_Scr(a5),APG_ScrBase(a5)	;the Screenpointer , stored in APG_Scr
	
		move.l	APG_CheckMainWinPos(a5),a6	;returns d0,d1 Pos
		jsr	(a6)

	;	add.w	#50,d0
		add.w	#100,d1
		
		move.w	d0,APG_WinLeft(a5)		;the left pos. of the Win
		move.w	d1,APG_WinTop(a5)		;the top pos. of the Win
		move.w	#367,APG_WinWidth(a5)		;the width of the Win
		move.w	#120+5,APG_WinHeight(a5)		;the height of the Win

		move.l	#spr_WinL,APG_WinL(a5)		;addr. of WA_Left Tag 
		move.l	#spr_WinT,APG_WinT(a5)		;addr. of WA_Top Tag
		move.l	#spr_WinW,APG_WinW(a5)		;addr. of WA_Width Tag
		move.l	#spr_WinH,APG_WinH(a5)		;addr. of WA_Height Tag

		move.l	APG_OpenWindow(a5),a6
		jsr	(a6)

		bsr.w	spr_checkghost

		lea	SRAW_Text0(pc),a2
		move.w	#SRAW_Project0_TNUM,APG_TNUM(a5)
		move.l	APG_Writetext(a5),a6
		jsr	(a6)

		move.l	spr_window(pc),a0
		moveq	#3,d0
		moveq	#17,d1
		move.w	#178,d2
		move.w	#63+23,d3
		moveq	#0,d4	;Invert ?
		
		bsr.w	drawframe

		move.l	spr_window(pc),a0
		move.w	#184,d0
		moveq	#17,d1
		move.w	#179,d2
		move.w	#63+23,d3
		moveq	#0,d4	;Invert ?
		
		bsr.w	drawframe

		lea	spr_asmsource(a5),a0
		lea	datapuffer,a1
		moveq	#pallen,d7
.np		move.b	(a0)+,(a1)+
		dbra	d7,.np

spr_wait:	move.l	spr_window(pc),a0
		move.l	APG_Wait(a5),a6
		jsr	(a6)				;Handle input

		cmp.l	#GADGETUP,d4
		beq.b	spr_gads_
		cmp.l	#CLOSEWINDOW,d4
		beq.b	spr_cancel
		bra.b	spr_wait

spr_gads_:
		moveq	#0,d0
		move.w	38(a4),d0
		add.w	d0,d0
		lea	spr_Jumptab(pc),a0
		move.w	(a0,d0.l),d0
		jmp	(a0,d0.l)


spr_Jumptab:	dc.w	spr_ok-spr_Jumptab
		dc.w	spr_cancel-spr_Jumptab
		dc.w	spr_output-spr_Jumptab
		dc.w	spr_handlecolor-spr_jumptab
		dc.w	spr_handlewidth-spr_jumptab
		dc.w	spr_handlectrlw-spr_jumptab
		dc.w	spr_language-spr_Jumptab
		dc.w	spr_widhtcheck-spr_Jumptab
		dc.w	spr_Indentcheck-spr_Jumptab
		dc.w	spr_Indent1check-spr_Jumptab
		dc.w	spr_Lineentries-spr_Jumptab
		dc.w	spr_handlelabel-spr_jumptab		
spr_ok:
		bra.w	spr_wech
spr_cancel:
		bra.w	spr_cancelwech
spr_output:
		move.b	d5,spr_outtag_(a5)
		lea	spr_outtag(pc),a0
		moveq	#2,d7
		lea	spr_source(a5),a1
		bra.w	spr_setflags

spr_handlecolor:
		move.b	d5,spr_0416tag(a5)
		lea	spr_color(pc),a0
		moveq	#1,d7
		lea	spr_sprite04(a5),a1
		bra.w	spr_setflags

spr_handlewidth:
		move.b	d5,spr_spritewidthtag(a5)
		lea	spr_spwidth(pc),a0
		moveq	#2,d7
		lea	spr_spritewidth16(a5),a1
		bra.w	spr_setflags

spr_handlectrlw:
		move.b	d5,spr_cwtag(a5)
		lea	spr_ctrlw(pc),a0
		moveq	#3,d7
		lea	spr_cwnone(a5),a1
		bra.w	spr_setflags

spr_handlelabel:
		move.b	d5,spr_uselabels(a5)
		ext.l	d5
		move.l	d5,spr_label

spr_language:
		move.b	d5,spr_sourcetag(a5)
		lea	spr_lang(pc),a0
		lea	spr_asmsource(a5),a1
		moveq	#4,d7
		bra.b	spr_setflags
spr_widhtcheck:
		move.b	d5,spr_widthtag(a5)
		lea	spr_width(pc),a0
		lea	spr_byte(a5),a1
		moveq	#2,d7
		bra.b	spr_setflags		
spr_Indentcheck:
		move.b	d5,spr_intag(a5)
		lea	spr_Indent(pc),a0
		lea	spr_dtabs(a5),a1
		moveq	#1,d7
		bra.b	spr_setflags
spr_Indent1check:
		lea	spr_gadarray(pc),a0
		move.w	38(a4),d0
		lsl.w	#2,d0
		move.l	(a0,d0.l),a0
		move.l	spr_window(pc),a1
		bsr.w	getintegervalue
		move.b	d0,spr_indents(a5)
		bra.w	spr_wait
spr_Lineentries:
		lea	spr_gadarray(pc),a0
		move.w	38(a4),d0
		lsl.w	#2,d0
		move.l	(a0,d0.l),a0
		move.l	spr_window(pc),a1
		bsr.w	getintegervalue
		move.b	d0,spr_entri(a5)
		bra.w	spr_wait

spr_cancelwech:
		lea	spr_asmsource(a5),a0
		lea	datapuffer,a1
		moveq	#pallen,d7
.np		move.b	(a1)+,(a0)+
		dbra	d7,.np

spr_wech:
		move.l	spr_window(pc),a0
		move.l	APG_Intuitionbase(a5),a6
		jmp	_LVOCloseWindow(a6)

spr_setflags
		move.l	a1,a2
.nc:		clr.b	(a1)+
		dbra	d7,.nc

		ext.l	d5
		move.b	#1,(a2,d5.l)
		move.l	d5,(a0)
		bsr.b	spr_checkghost
		bra.w	spr_wait
		
spr_checkghost:
		moveq	#0,d0
		tst.b	spr_source(a5)
		bne.b	.w
		moveq	#1,d0
.w
		lea	sraw_ghost(pc),a3
		move.l	d0,4(a3)

		moveq	#spr_GD_Language,d0
		bsr.b	spr_doghost
		moveq	#spr_GD_width,d0
		bsr.b	spr_doghost
		moveq	#spr_GD_Indent,d0
		bsr.b	spr_doghost
		moveq	#spr_GD_Indent1,d0
		bsr.b	spr_doghost
		moveq	#spr_GD_lineentries,d0
		bsr.b	spr_doghost

		moveq	#0,d0
		tst.b	spr_asmsource(a5)
		bne.b	.ok
		moveq	#1,d0
.ok
		lea	sraw_ghost(pc),a3
		move.l	d0,4(a3)
		moveq	#spr_GD_labels,d0

spr_doghost:
		lea	spr_gadarray(pc),a0
		lsl.l	#2,d0
		move.l	(a0,d0.l),a0
		move.l	spr_window(pc),a1
		sub.l	a2,a2
		lea	sraw_ghost(pc),a3
		move.l	gadbase(a5),a6
		jmp	_LVOGT_SetGadgetAttrsA(a6)


spr_window:	dc.l	0		;Enthält pointer vom eingenen Window
spr_GList:	dc.l	0		
spr_gadarray:	dcb.l	12,0

	even

;-----------------------------------------------------------------------------
spr_WindowTags:
spr_winL:	dc.l	WA_Left,0
spr_winT:	dc.l	WA_Top,0
spr_winW:	dc.l	WA_Width,0
spr_winH:	dc.l	WA_Height,0
		dc.l	WA_IDCMP,CLOSEWINDOW!GADGETUP!VANILLAKEY!BUTTONIDCMP!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_CLOSEGADGET!WFLG_DEPTHGADGET!WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_SMART_REFRESH!WFLG_RMBTRAP
spr_winWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title,spr_winWTitle
spr_winSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

spr_WinWTitle:	dc.b	'Sprite options',0
	even

spr_GD_Ok	=	0
spr_GD_Cancel	=	1
spr_GD_output	=	2
spr_GD_colors	=	3
spr_GD_spwidth	= 	4
spr_GD_ctrlwords=	5
spr_GD_Language=	6
spr_GD_width	=	7
spr_GD_Indent	=	8
spr_GD_Indent1	=	9
spr_GD_lineentries =	10
spr_GD_labels	=	11

spr_Gtypes:
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND

		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND
		dc.w	CYCLE_KIND
		dc.w	INTEGER_KIND
		dc.w	INTEGER_KIND
		dc.w	CYCLE_KIND

spr_GTags:
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,sraw_OutputLabel
		dc.l	GTCY_ACTIVE
spr_outtag:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,spr_colorLabel
		dc.l	GTCY_ACTIVE
spr_color:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,spr_spwidthLabel
		dc.l	GTCY_ACTIVE
spr_spwidth:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,spr_ctlrwLabel
		dc.l	GTCY_ACTIVE
spr_ctrlw:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,spr_LangLabel
		dc.l	GTCY_ACTIVE
spr_lang:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,spr_WidthLabel
		dc.l	GTCY_ACTIVE
spr_width:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,spr_IndentLabel
		dc.l	GTCY_ACTIVE
spr_Indent:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTIN_Number
spr_tabs:	dc.l	2
		dc.l	GTIN_MaxChars,2		;Tabs
		dc.l	STRINGA_Justification,GACT_STRINGRIGHT
		dc.l	TAG_DONE
		dc.l	GTIN_Number
spr_entries:	dc.l	8
		dc.l	GTIN_MaxChars,2
		dc.l	STRINGA_Justification,GACT_STRINGRIGHT
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,spr_labelLabel
		dc.l	GTCY_ACTIVE
spr_label:	dc.l	0
		dc.l	TAG_DONE

spr_colorLabel:
		dc.l	spr_colorlab0
		dc.l	spr_colorlab1
		dc.l	0


spr_spwidthLabel:
		dc.l	spr_spwidthLab0
		dc.l	spr_spwidthLab1
		dc.l	spr_spwidthLab2
		dc.l	0

spr_ctlrwLabel:
		dc.l	spr_ctlrwLab0
		dc.l	spr_ctlrwLab1
		dc.l	spr_ctlrwLab2
		dc.l	spr_ctlrwLab3
		dc.l	0

spr_labelLabel:
		dc.l	spr_labelLab0
		dc.l	spr_labelLab1
		dc.l	spr_labelLab2
		dc.l	0

spr_LangLabel:
		dc.l	LangLabel0
		dc.l	LangLabel1
		dc.l	LangLabel2
		dc.l	LangLabel3
		dc.l	LangLabel4
		dc.l	0
		
spr_WidthLabel:
		dc.l	Widthlabel0
		dc.l	Widthlabel1
		dc.l	Widthlabel2
		dc.l	0
		
spr_IndentLabel:
		dc.l	IndentLabel0
		dc.l	IndentLabel1
		dc.l	0


spr_labelLab0:	dc.b	'None',0
spr_labelLab1:	dc.b	'Auto',0
spr_labelLab2:	dc.b	'Prompt',0

spr_ctlrwLab0:	dc.b	'None',0
spr_ctlrwLab1:	dc.b	'Empty',0
spr_ctlrwLab2:	dc.b	'Auto',0
spr_ctlrwLab3:	dc.b	'Prompt',0

spr_spwidthLab0:dc.b	'16',0
spr_spwidthLab1:dc.b	'32',0
spr_spwidthLab2:dc.b	'64',0

spr_colorlab0:	dc.b	'4',0
spr_colorlab1:	dc.b	'16',0

	even

spr_NTypes:
		dc.w    42,93+15,100,13
		dc.l    oktext,0
		dc.w    spr_GD_Ok
		dc.l    PLACETEXT_IN,0,0
		dc.w	224,93+15,100,13
		dc.l    canceltext,0
		dc.w    spr_GD_Cancel
		dc.l    PLACETEXT_IN,0,0
		dc.w	7,32,85,13
		dc.l	sraw_outtext,0
		dc.w	spr_GD_output
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	7,60,85,13
		dc.l	spr_colortext,0
		dc.w	spr_GD_colors
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	94,60,85,13
		dc.l	spr_widthtext,0
		dc.w	spr_GD_spwidth
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	94,32,85,13
		dc.l	spr_ctrlwtext,0
		dc.w	spr_GD_ctrlwords
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	181+7,32,85,13
		dc.l	SRAW_langtext,0
		dc.w	spr_GD_Language
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	268+7,32,85,13
		dc.l	SRAW_widthtext,0
		dc.w	spr_GD_width
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	188+42,60,85,13
		dc.l	SRAW_indenttext,0
		dc.w	spr_GD_Indent
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	268+7+43,60,42,13
		dc.l	0,0
		dc.w	spr_GD_Indent1
		dc.l	0,0,0
		dc.w	268+7+43,75+3,42,13
		dc.l	SRAW_linetext,0
		dc.w	spr_GD_lineentries
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	50,88,85,13
		dc.l	spr_labeltext,0
		dc.w	spr_GD_labels
		dc.l	PLACETEXT_ABOVE,0,0



spr_colortext:	dc.b	'Colors',0
spr_widthtext:	dc.b	'Width',0
spr_ctrlwtext:	dc.b	'Ctrl. Words',0
spr_labeltext:	dc.b	'Labels',0

		even

;***************************************************************************
;*--------------------------- Save Sprite ---------------------------------*
;***************************************************************************
saveSprite:
;Prefs Kopieren für Source Engine

		tst.l	picmem(a5)
		bne.b	.memok
		moveq	#APSE_NOBITMAP,d3
		rts
.memok
		lea	spr_asmsource(a5),a0
		lea	sasmsource(a5),a1
		move.l	(a0)+,(a1)+
		move.b	(a0),(a1)				

		lea	spr_byte(a5),a0
		lea	databyte(a5),a1
		move.w	(a0)+,(a1)+
		move.b	(a0),(a1)		

		moveq	#0,d0
		move.b	spr_indents(a5),d0
		move.l	d0,data_indents(a5)

		moveq	#0,d0
		move.b	spr_entri(a5),d0
		move.l	d0,data_datasPL(a5)
	
		move.b	spr_dtabs(a5),data_tab(a5)

;-------------------------------------------------------------------------
		tst.w	cutflag(a5)
		bne.b	.cutok
		move.w	#0,xbrush1(a5)		;Es soll das ganze 
		move.w	#0,ybrush1(a5)		;Pic abgesaved werden
		move.w	breite(a5),xbrush2(a5)
		move.w	hoehe(a5),ybrush2(a5)	
.cutok:
		move.w	xbrush1(a5),xbrushpuff1(a5)
		move.w	xbrush2(a5),xbrushpuff2(a5)

		lea	picx(pc),a0
		moveq	#0,d0
		move.w	xbrush1(a5),d0
		move.l	d0,(a0)
		lea	picy(pc),a0
		move.w	ybrush1(a5),d0
		move.l	d0,(a0)
		
		bsr.w	ckecksize	;check wieviel Sprites
		tst.l	anzsprite(a5)
		bne.b	.saveok
		lea	notwidthmsg(pc),a4
		bsr.w	status
		moveq	#-1,d3		;Ein fehler
		rts
.saveok:
		move.l	checkprompt(a5),a6
		move.l	rgbmem(a5),d0
		move.l	#$10001,d1
		jsr	-684(a6)
		move.l	d0,dummymerk(a5)

;Berechne Puffergröße

		moveq	#0,d0
		move.b	spr_binary(a5),d0
		add.b	spr_link(a5),d0
		move.b	d0,bindata(a5)
		
		moveq	#0,d0		
		move.w	ybrush2(a5),d0
		sub.w	ybrush1(a5),d0
		move.w	words(a5),d1
		addq.w	#1,d1
		mulu	d1,d0
		add.w	d1,d1	;weil Zwei Controlworte
		add.l	d0,d0	;für zwei Planes
		add.l	d1,d0	;Die Controlworte adden
		add.l	d1,d0	;für anfang und ende
		move.l	anzsprite(a5),d1
		mulu	d1,d0
		add.l	d0,d0	:Worte in Bytes
		
		cmp.w	#-1,d3
		beq.w	noprompt
		tst.b	spr_sprite16(a5)
		beq.b	.no16
		add.l	d0,d0	;anzahl der Sprites verdoppelt sich
.no16:
		move.l	d0,linkobjektsize(a5)
		move.l	d0,brushmemsize(a5)
		tst.b	spr_link(a5)
		beq.b	.nl

		bsr.w	writelinkheader
		tst.l	d7
		beq.b	.nolink
		moveq	#-1,d3
		rts
.nolink:
.nl:		move.l	linkobjektsize(a5),d0
		tst.b	spr_source(a5)
		beq.b	.noall

		bsr.w	calclinemem
		tst.l	d0
		bne.w	nomem
		bra.b	.wei
.noall:
		bsr.w	allocmem
		tst.l	d0
		beq.w	nomem	

;===========================================================================
.wei
		move.l	#0,oneplanesizeoffset(a5)
		clr.b	second(a5)

		move.w	#1,labelcount(a5)
		sf	merk2(a5)	;merker für make all
newsprite4:
		tst.b	spr_source(a5)
		beq.b	.w
		lea	datapuffer,a4
		move.w	#250,datazaehler(a5)
		bra.w	laber
.w
		move.l	linemem(a5),a4
laber		clr.b	allflag(a5)
newsprite4.2:
		tst.b	spr_cwprompt(a5)
		beq.b	nop
		tst.b	allflag(a5)
		bne.b	nop
		bsr.w	makepromt
		cmp.l	#-1,d0
		bne.b	nop
noprompt:	lea	spritecancellmsg(pc),a4
		bsr.w	status
		moveq	#-1,d3
		rts
nop
newsprite4.1:
		tst.b	spr_source(a5)
		beq.b	.w
		bsr.w	sp_makelabels
		tst.l	d0
		bne.b	noprompt
.w
		moveq	#0,d1
		moveq	#0,d2
		move.w	xbrushpuff1(a5),d1
		move.w	d1,d2	 
		lsr.l	#4,d1	;/16
		move.l	d1,firstword(a5);erstes word ab dem gelesenwird
		lsl.l	#4,d1
		sub.l	d1,d2
		move.l	d2,bitshift(a5)	;anzahl der Bits um die nach links
		move.l	firstword(a5),d0
		add.l	d0,d0
		move.l	d0,firstword(a5)

		bsr.w	checkY		;ermittle Zeilen und rechne y-koor.
					;um
		move.b	#1,first(a5)
		bsr.w	makecontrolwords ;Teste und schreibe Controlwords
		clr.b	first(a5)
		tst.b	spr_source(a5)
		beq.b	newline4
aha
		bsr.w	da_savedatas
		tst.b	newlinemerk(a5) ;Line wurde schon gespeichert
		bne.b	newline4
		move.l	linememmerk(a5),a0
		tst.b	spr_source(a5)
		bne.b	.k
		tst.b	spr_pascal(a5)
		beq.b	.ok
.k		move.b	#',',(a0)+
.ok		bsr.w	da_saveline
		bsr.w	da_makeenter
		move.l	linemem(a5),a0
		move.l	a0,linememmerk(a5)
		move.b	#1,newlinemerk(a5)
		clr.b	kommaflag(a5)
		lea	datapuffer,a4
		move.w	#250,datazaehler(a5)
		
newline4:
newentry
		move.w	xbrushpuff1(a5),d4
		move.l	picmem(a5),a0
		add.l	oneplanesizeoffset(a5),a0
		move.l	a0,a3
		add.l	firstword(a5),a3

		move.w	words(a5),d3 ;hole und schreibe so viele worte 
.nw:				    ;wie für eine Spritebreite gebraucht werden
		tst.b	second(a5)
		beq.b	.plok
		move.b	planes(a5),d0
		cmp.b	#3,d0		;weniger als 3 Planes ?
		bhs.b	.plok
		moveq	#0,d0
		bra.b	.go
.plok:
		bsr.w	holeword
.go
		move.w	d0,(a4)+
		tst.b	spr_source(a5)
		beq.b	.nd
		sub.w	#1,datazaehler(a5)
		bne.b	.nd
		bsr.w	da_savedatas
.nd:
		dbra	d3,.nw

		clr.b	merk1(a5)
		move.b	planes(a5),d0
		tst.b	second(a5)
		bne.b	.test4
		cmp.b	#2,d0
		bhs.b	.planeok
		bra.b	.null
.test4
		cmp.b	#4,d0
		bhs.b	.planeok
.null:
		moveq	#0,d0
		move.b	#1,merk1(a5)
		bra.b	goOn
.planeok:
		add.l	oneplanesize(a5),a0
		move.l	a0,a3
		add.l	firstword(a5),a3
goOn:
		move.w	xbrushpuff1(a5),d4
		move.w	words(a5),d3

.nw1
		tst.b	merk1(a5)
		beq.b	.planeok
		moveq	#0,d0
		bra.b	.con
.planeok:
		bsr.w	holeword
.con
		move.w	d0,(a4)+
		tst.b	spr_source(a5)
		beq.b	.weiter1
		sub.w	#1,datazaehler(a5)
		bne.b	.weiter1
		bsr.w	da_savedatas
.weiter1:
		dbra	d3,.nw1

		add.l	bytebreite(a5),d5
		dbra	d7,newentry

		tst.b	spr_source(a5)
		beq.b	.ns
		bsr.w	da_savedatas
		tst.b	newlinemerk(a5)
		bne.b	.sf
		move.l	linememmerk(a5),a0
		tst.b	spr_csource(a5)
		bne.b	.k
		tst.b	spr_pascal(a5)
		beq.b	.ok
.k		move.b	#',',(a0)+
.ok		bsr.w	da_saveline
.sf
		tst.b	newlinemerk(a5)
		bne.b	.nli
		bsr.w	da_makeenter
.nli		move.b	#1,newlinemerk(a5)
		clr.b	kommaflag(a5)
		lea	datapuffer,a4
		move.w	#250,datazaehler(a5)
 
.ns		bsr.w	makecontrolwords

		tst.b	spr_source(a5)
		beq.b	.ns1

		bsr.w	da_savedatas
		tst.b	newlinemerk(a5) ;Line wurde schon gespeichert
		bne.b	.ns1
		move.l	linememmerk(a5),a0
		tst.b	spr_csource(a5)
		bne.b	.k1
		tst.b	spr_pascal(a5)
		beq.b	.ok1
.k1		move.b	#',',(a0)+
.ok1
		bsr.w	da_saveline
		bsr.w	da_makeenter
		bsr.w	da_makeenter
		move.b	#1,newlinemerk(a5)
		clr.b	kommaflag(a5)
.ns1:
		tst.b	second(a5)
		bne.b	.nosecond
		tst.b	spr_sprite16(a5)
		beq.b	.nosecond
		move.l	oneplanesize(a5),d0
		add.l	d0,d0
		move.l	d0,oneplanesizeoffset(a5)
		st	second(a5)

		bra.w	newsprite4.1
.nosecond:
		clr.b	second(a5)
		move.l	#0,oneplanesizeoffset(a5)

		subq.l	#1,anzsprite(a5)
		beq.b	.wech
		move.l	xadd(a5),d0
		add.w	d0,xbrushpuff1(a5)
		lea	picx(pc),a0
		add.l	d0,(a0)
;		add.l	d0,xbrush2(a5)

		bra.w	newsprite4.2
.wech:
		tst.b	bindata(a5)
		beq.b	.nowrite

		move.l	a4,a0
		bsr.w	col_writeline1
.nowrite:
		tst.b	spr_link(a5)
		beq.b	.nl
		bsr.w	writelinkbottom
.nl:
		tst.b	spr_source(a5)
		beq.b	.s

		bsr.w	da_makeend	;setzte endklammer für C und Pascale
		
		bsr.w	da_memwech
.s

		lea	spr_name(pc),a0
		tst.b	spr_source(a5)
		bne	.ss
		lea	spr_name1(pc),a0
		tst.b	spr_link(a5)
		bne	.ss
		lea	3(a0),a0
.ss
		moveq	#16,d0
		tst.b	spr_spritewidth16(a5)
		bne	.yes
		tst.b	spr_spritewidth32(a5)
		beq	.n32
		moveq	#32,d0
		bra	.yes
.n32:		moveq	#64,d0
.yes
		moveq	#0,d1
		move.w	APG_ybrush2(a5),d1
		sub.w	APG_ybrush1(a5),d1
		moveq	#2,d2
		tst.b	spr_sprite16(a5)
		beq	.nur4
		moveq	#4,d2		;16 farben sprite
.nur4:		
		jsr	APR_SetComment(a5)


		bra.w	endcolorsave


spr_name:	dc.b	"SRC SPRITE",0
spr_name1:	dc.b	"LI SPRITE",0

		even
		
		
;--------------- Hilfroutinen für Spritesave -----------------;

makecontrolwords:
		move.l	d5,-(a7)
		tst.b	spr_cwnone(a5)
		bne.w	.nocontrol

		moveq	#0,d4
		moveq	#0,d5
		tst.b	spr_cwempty(a5)
		bne.b	.noposition
		tst.b	first(a5)
		beq.b	.noposition

		move.w	xbrushpuff1(a5),d4
		tst.b	spr_cwprompt(a5)
		beq.b	.ok1
		move.l	picx(pc),d4
.ok1		move.w	ybrush1(a5),d5
		move.w	ybrush2(a5),d3
.noposition:
		move.l	d4,d0
		move.l	d5,d1
		tst.b	first(a5)
		beq.b	.nopos
		tst.b	spr_cwpos(a5)
		bne.b	.wq
		tst.b	spr_cwprompt(a5)
		beq.b	.nopos
.wq
		bsr.w	makepos
		
.nopos:
		tst.b	second(a5)
		beq.b	.nosec
		bset	#7,d1
.nosec:
	tst.b	first(a5)
	bne.b	.ok
	moveq	#0,d0
.ok		move.w	d0,(a4)+
		tst.b	spr_source(a5)
		beq.b	.ns
		sub.w	#1,datazaehler(a5)
		bne.b	.ns
		bsr.w	da_savedatas
.ns:
		move.w	d1,(a4)+
		tst.b	spr_source(a5)
		beq.b	.ns1
		sub.w	#1,datazaehler(a5)
		bne.b	.ns1
		bsr.w	da_savedatas

.ns1:		tst.b	spr_spritewidth16(a5)
		bne.b	.nocontrol

		move.w	d1,(a4)+	;controlwords für 32'er Sprites
		tst.b	spr_source(a5)
		beq.b	.ns2
		sub.w	#1,datazaehler(a5)
		bne.b	.ns2
		bsr.w	da_savedatas
.ns2:
		clr.w	(a4)+
		tst.b	spr_source(a5)
		beq.b	.ns3
		sub.w	#1,datazaehler(a5)
		bne.b	.ns3
		bsr.w	da_savedatas
.ns3:
		tst.b	spr_spritewidth64(a5)
		beq.b	.nocontrol

		move.w	d1,(a4)+	;und Words für 64'er
		tst.b	spr_source(a5)
		beq.b	.ns4
		sub.w	#1,datazaehler(a5)
		bne.b	.ns4
		bsr.w	da_savedatas
.ns4:
		moveq	#2,d6
.ns4w		clr.w	(a4)+
		tst.b	spr_source(a5)
		beq.b	.ns5
		sub.w	#1,datazaehler(a5)
		bne.b	.ns5
		bsr.w	da_savedatas
.ns5:		dbra	d6,.ns4w

.nocontrol:
		move.l	(a7)+,d5
		rts

;--- Brechne Spriteposition für Kontrollwords ----
makepos:			
		move.w	d4,d0
		move.w	d5,d1

		movem.l	d2-a6,-(a7)

		sub.w	d1,d3
		move.w	d3,d2

		tst.b	spr_cwprompt(a5)
		beq.b	.promt

	;	move.l	picx(pc),d0
		move.l	picy(pc),d1
		
		add.l	scrx,d0
		add.l	scry,d1

		bra.b	.go

.promt:
		add.w	#128,d0
		add.w	#$2c,d1

.go		moveq	#0,d4
		moveq	#0,d5

		add.w	d1,d2
		move.b	d1,d4
		ror.w	#1,d0
		asl.w	#8,d4
		move.b	d0,d4
		move.b	d2,d5
		asl.w	#8,d5
		clr.b	d1
		clr.b	d2
		lsr.w	#6,d1
		lsr.w	#7,d2
		clr.b	d0
		rol.w	#1,d0
		or.b	d2,d0
		or.b	d1,d0
		;	bset	#7,d0			; ATTACH-Bit
		move.b	d0,d5

		move.w	d4,d0
		move.w	d5,d1

		movem.l	(a7)+,d2-a6		

		rts

makepromt:
		movem.l	d0-a6,-(a7)
 		lea	spritewinWindowTags(pc),a0
		move.l	a0,windowtaglist(a5)
		lea	spritewinWG+4(pc),a0
		move.l	a0,gadgets(a5)
		lea	spritewinSC+4(pc),a0
		move.l	a0,winscreen(a5)
		lea	spritewinWnd(a5),a0
		move.l	a0,window(a5)
		lea	spritewinGlist(a5),a0
		move.l	a0,Glist(a5)
		lea	spritewinNgads(pc),a0
		move.l	a0,NGads(a5)
		lea	spritewinGTypes(pc),a0
		move.l	a0,GTypes(a5)
		lea	spritewinGadgets(pc),a0
		move.l	a0,WinGadgets(a5)
		move.w	#spritewin_CNT,win_CNT(a5)
		lea	spritewinGtags(pc),a0
		move.l	a0,windowtags(a5)
		move.l	scr(a5),screenbase(a5)

		bsr.w	checkmainwinpos

		add.w	#spritewinLeft,d0
		add.w	#spritewinTop,d1

		move.w	d1,WinTop(a5)
		move.w	d0,WinLeft(a5)

		move.w	#spritewinWidth,WinWidth(a5)
		move.w	#spritewinHeight,WinHeight(a5)
		lea	spriteWinL,a0
		move.l	a0,WinL(a5)
		lea	spriteWinT,a0
		move.l	a0,WinT(a5)
		lea	spriteWinW,a0
		move.l	a0,WinW(a5)
		lea	spriteWinH,a0
		move.l	a0,WinH(a5)

		bsr.l	openwindowF

mp_wait:	move.l	spritewinWnd(a5),a0
		jsr	wait

		cmp.l	#closewindow,d4
		beq.w	mp_cancel
		cmp.l	#GADGETUP,d4
		beq.b	mp_gads
		cmp.l	#IDCMP_VANILLAKEY,d4
		beq.b	mp_keys		;es wurde eine Taste gedrückt

		bra.b	mp_wait
mp_gads:
		moveq	#0,d0
		move.w	38(a4),d0
		cmp.w	#GD_screenx,d0
		beq.w	mp_scrx		;beende Programm
		cmp.w	#GD_screeny,d0
		beq.w	mp_scry
		cmp.w	#GD_picx,d0
		beq.w	mp_picx
		cmp.w	#GD_picy,d0
		beq.w	mp_picy
		cmp.w	#GD_spok,d0
		beq.b	mp_ok
		cmp.w	#GD_spcancel,d0
		beq.b	mp_cancel
		cmp.w	#GD_spall,d0
		beq.b	mp_all
		bra.b	mp_wait			;kein Gadget dabei

mp_keys:
		move.l	spritewinWnd(a5),aktwin(a5)
		lea	spritewinGadgets(pc),a0
		move.l	d5,d3
		cmp.w	#'o',d3
		bne.b	.nook
		lea	mp_ok(pc),a3
		move.l	#GD_spok,d0
		jmp	setandjump
.nook:		
		cmp.w	#'a',d3
		bne.b	.noall
		lea	mp_all(pc),a3
		move.l	#GD_spall,d0
		jmp	setandjump
.noall:
		cmp.w	#'c',d3
		bne.w	mp_wait
		lea	mp_cancel(pc),a3
		move.l	#GD_spcancel,d0
		jmp	setandjump

mp_cancel:
		bsr.l	gt_CloseWindow
		movem.l	(a7)+,d0-a6
		moveq	#-1,d0
		rts
mp_all:
		st	allflag(a5)
mp_ok:
		bsr.l	gt_CloseWindow
		movem.l	(a7)+,d0-a6
		moveq	#0,d0
		rts

mp_scrx:
		lea	spritewinGadgets(pc),a0
		move.l	#GD_screenx,d0
		bsr.w	lr_asciinteger
		lea	scrx(pc),a0
		move.l	d0,(a0)
		bra.w	mp_wait
mp_scry:
		lea	spritewinGadgets(pc),a0
		move.l	#GD_screeny,d0
		bsr.w	lr_asciinteger
		lea	scry(pc),a0
		move.l	d0,(a0)
		bra.w	mp_wait
mp_picx:
		lea	spritewinGadgets(pc),a0
		move.l	#GD_picx,d0
		bsr.w	lr_asciinteger
		lea	picx(pc),a0
		move.l	d0,(a0)
		bra.w	mp_wait
mp_picy:
		lea	spritewinGadgets(pc),a0
		move.l	#GD_picy,d0
		bsr.w	lr_asciinteger
		lea	picy(pc),a0
		move.l	d0,(a0)
		bra.w	mp_wait

checkY:
		moveq	#0,d3
		move.w	ybrush2(a5),d7
		move.w	ybrush1(a5),d5
		sub.w	d5,d7		;Zeilen
		sub.w	#1,d7
		move.l	bytebreite(a5),d3
;		subq.l	#1,d5
		mulu	d3,d5    	;ykoordinate umrechnen
		rts
ckecksize:
		moveq	#0,d0
		move.w	xbrush2(a5),d0
		sub.w	xbrush1(a5),d0

		tst.b	spr_spritewidth16(a5)
		beq.b	.no16
		moveq	#16,d1
		move.w	#0,words(a5)
		bra.b	.check
.no16:
		tst.b	spr_spritewidth32(a5)
		beq.b	.no32
		moveq	#32,d1
		move.w	#1,words(a5)
		bra.b	.check
.no32:
		moveq	#64,d1
		move.w	#3,words(a5)
.check:
		move.l	d1,xadd(a5)
		divu	d1,d0
		swap	d0
		tst.w	d0
		beq.b	.norest
		add.l	#$10000,d0
.norest:
		swap	d0
		ext.l	d0

		move.l	d0,anzsprite(a5)	;so viele Sprites müssen
						;gesaved werden
		rts

writesprite:
		move.l	filehandle(a5),d1
		move.l	puffermem(a5),d2
		move.l	dosbase(a5),a6
		jmp	_LVOWrite(a6)

holeword:
		movem.l	d1-d3/d5/d6,-(a7)

		move.l	bitshift(a5),d6

		move.l	(a3,d5.l),d0
		lsl.l	d6,d0
		swap	d0
		add.l	#16,d4
		move.w	xbrush2(a5),d1
		cmp.w	d4,d1
		bhs.b	.pixok
		move.w	d4,d3
		sub.w	d1,d3
		lsr.w	d3,d0
		lsl.w	d3,d0	;zuviele Bits löschen
.pixok:
		addq.l	#2,a3
		movem.l	(a7)+,d1-d3/d5/d6
		rts

da_makeenter:
		movem.l	d0-a6,-(a7)
		move.l	filehandle(a5),d1
		lea	enter(pc),a0
		move.l	a0,d2
		moveq	#1,d3
		move.l	dosbase(a5),a6
		jsr	_LVOWrite(a6)
		movem.l	(a7)+,d0-a6
		rts
enter:
		dc.b	10
	even

sp_makelabels:
		movem.l	d0-a6,-(a7)
		tst.b	spr_uselabels(a5)
		beq.w	la_wech
		tst.b	spr_asmsource(a5)
		beq.w	la_wech		;nur bei assm Labels
		cmp.b	#2,spr_uselabels(a5)
		beq.w	la_makeprompt
		
la_cont:	lea	keymsgpuffer(a5),a0
		move.l	a0,a2
		lea	spritename(pc),a1
		cmp.b	#1,spr_uselabels(a5)
		beq.b	.nn
		lea	labelpuffer,a1
.nn:		move.b	(a1)+,d0
		beq.b	.endname
		move.b	d0,(a0)+
		bra.b	.nn
.endname:
		move.w	labelcount(a5),d0
		move.w	d0,d1
		moveq	#0,d2
.w		sub.w	#10,d1
		bmi.b	.endzehn
		addq.w	#1,d2
		bra.b	.w
.endzehn:	tst.w	d2
		beq.b	.nozehn		;keine Zehnerstelle (null)
		add.b	#$30,d2
		move.b	d2,(a0)+
.nozehn:
		moveq	#0,d2
		add.w	#10+$30,d1
		move.b	d1,(a0)+

		tst.b	spr_sprite16(a5)
		beq.b	.no16
		move.b	#'a',d0
		tst.b	second(a5)
		beq.b	.nosec
		move.b	#'b',d0
.nosec:		move.b	d0,(a0)+
.no16:		move.b	#':',(a0)+
		move.b	#10,(a0)+
		sub.l	a2,a0
		move.l	a0,d3

		move.l	filehandle(a5),d1
		move.l	a2,d2
		move.l	dosbase(a5),a6
		jsr	_LVOWrite(a6)	;write Label

		tst.b	spr_sprite16(a5)
		beq.b	.add
		tst.b	second(a5)
		beq.b	la_wech

.add:		addq.w	#1,labelcount(a5)

la_wech:	movem.l	(a7)+,d0-a6
		moveq	#0,d0
		rts

;--------------------------------------------------------------------------
la_makeprompt:
		tst.b	second(a5)
		bne.w	la_cont
		tst.b	merk2(a5)	;es sollen alle Sprites mit der
		bne.w	la_cont		;einstellung gespeichert werden
 		lea	labelwinWindowTags(pc),a0
		move.l	a0,windowtaglist(a5)
		lea	labelwinWG+4(pc),a0
		move.l	a0,gadgets(a5)
		lea	labelwinSC+4(pc),a0
		move.l	a0,winscreen(a5)
		lea	labelwinWnd(a5),a0
		move.l	a0,window(a5)
		lea	labelwinGlist(a5),a0
		move.l	a0,Glist(a5)
		lea	labelwinNgads(pc),a0
		move.l	a0,NGads(a5)
		lea	labelwinGTypes(pc),a0
		move.l	a0,GTypes(a5)
		lea	labelwinGadgets(pc),a0
		move.l	a0,WinGadgets(a5)
		move.w	#labelwin_CNT,win_CNT(a5)
		lea	labelwinGtags(pc),a0
		move.l	a0,windowtags(a5)
		move.l	scr(a5),screenbase(a5)

		bsr.l	checkmainwinpos

		add.w	#labelwinLeft,d0
		add.w	#labelwinTop,d1

		move.w	d1,WinTop(a5)
		move.w	d0,WinLeft(a5)

		move.w	#labelwinWidth,WinWidth(a5)
		move.w	#labelwinHeight,WinHeight(a5)
		lea	LabelWinL,a0
		move.l	a0,WinL(a5)
		lea	LabelWinT,a0
		move.l	a0,WinT(a5)
		lea	LabelWinW,a0
		move.l	a0,WinW(a5)
		lea	labelWinH,a0
		move.l	a0,WinH(a5)

		bsr.l	openwindowF

la_wait:	move.l	labelwinWnd(a5),a0
		jsr	wait

		cmp.l	#closewindow,d4
		beq.b	la_cancel
		cmp.l	#GADGETUP,d4
		beq.b	la_gads
		cmp.l	#IDCMP_VANILLAKEY,d4
		beq.b	la_keys		;es wurde eine Taste gedrückt

		bra.b	la_wait
la_gads:
		moveq	#0,d0
		move.w	38(a4),d0
		cmp.w	#GD_create,d0
		beq.b	la_create
		cmp.w	#GD_createall,d0
		beq.w	la_createall
		cmp.w	#GD_lcancel,d0
		beq.b	la_cancel
		bra.b	la_wait			;kein Gadget dabei

la_keys:
		move.l	labelwinWnd(a5),aktwin(a5)
		lea	labelwinGadgets(pc),a0
		move.l	d5,d3
		cmp.w	#'c',d3
		bne.b	.nocreate
		lea	la_create(pc),a3
		move.l	#GD_create,d0
		jmp	setandjump
.nocreate:
		cmp.w	#'a',d3
		bne.b	.nocreateall
		lea	la_createall(pc),a3
		move.l	#GD_createall,d0
		jmp	setandjump
.nocreateall:
		cmp.w	#'n',d3
		bne.b	la_wait
		lea	la_cancel(pc),a3
		move.l	#GD_lcancel,d0
		jmp	setandjump

la_cancel:
		bsr.l	gt_CloseWindow
		movem.l	(a7)+,d0-a6
		moveq	#-1,d0
		rts

la_create:
		move.l	#GD_countstart,d0
		lsl.l	#2,d0
		lea	labelwinGadgets(pc),a0
		move.l	(a0,d0.w),a0
		move.l	gg_SpecialInfo(a0),a0
		move.w	si_NumChars(a0),d7	;Anzahl der Zeichen
		move.l	(a0),a0		;String
		lea	(a0,d7.w),a0	;ende des Strings
		subq.w	#1,d7

		moveq	#0,d0
		moveq	#1,d2
la_nextchar:
		moveq	#0,d1
		move.b	-(a0),d1
		sub.b	#48,d1
		muls	d2,d1
		muls	#10,d2		
		add.l	d1,d0
		dbra	d7,la_nextchar			

		move.w	d0,labelcount(a5)
		lea	countst(pc),a0
		addq.w	#1,d0
		move.l	d0,(a0)
				
		move.l	#GD_labelname,d0
		lsl.l	#2,d0
		lea	labelwinGadgets(pc),a0
		move.l	(a0,d0.w),a0
		move.l	gg_SpecialInfo(a0),a0
		move.w	si_NumChars(a0),d7	;Anzahl der Zeichen
		tst.w	d7
		beq.b	nolabelname
		move.l	(a0),a0		;String
		subq.w	#1,d7
		lea	labelpuffer,a1
.nc:		move.b	(a0)+,(a1)+
		dbra	d7,.nc
		clr.b	(a1)+
		
la_promptend:	bsr.l	gt_closewindow
		bra.w	la_cont

la_createall:
		st	merk2(a5)
		bra.w	la_create

nolabelname:
		lea	nolabelmsg(pc),a4
		bsr.l	status
		bsr.l	gt_CloseWindow
		movem.l	(a7)+,d0-a6
		addq.l	#4,sp
		moveq	#-1,d3
		rts		

nolabelmsg:	dc.b	'Label is not defined!',0

spritename:	dc.b	'Sprite',0
	even

spritewinWindowTags:
spritewinL:	dc.l	WA_Left,212
spritewinT:	dc.l	WA_Top,78
spritewinW:	dc.l	WA_Width,210
spriteWinH:	dc.l	WA_Height,97
		dc.l	WA_IDCMP,CLOSEWINDOW!VANILLAKEY!INTEGERIDCMP!CYCLEIDCMP!BUTTONIDCMP!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_CLOSEGADGET!WFLG_DEPTHGADGET!WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_SMART_REFRESH!WFLG_RMBTRAP
spritewinWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title,controlwinWTitle
		dc.l	WA_ScreenTitle,MainwinStitle
spritewinSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

controlwinWTitle:
		dc.b	'Sprite Position',0
	even

LabelwinWindowTags:
labelwinL:	dc.l	WA_Left,212
labelwinT:	dc.l	WA_Top,78
labelwinW:	dc.l	WA_Width,240
labelWinH:	dc.l	WA_Height,97
		dc.l	WA_IDCMP,CLOSEWINDOW!VANILLAKEY!INTEGERIDCMP!CYCLEIDCMP!BUTTONIDCMP!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_CLOSEGADGET!WFLG_DEPTHGADGET!WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_SMART_REFRESH!WFLG_RMBTRAP
labelwinWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title,labelwinWTitle
		dc.l	WA_ScreenTitle,MainwinStitle
labelwinSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

labelwinWTitle:
		dc.b	'Define the label !',0
	even

;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
;			Open a screen for visual stuff
;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
nomodemsg:	dc.b	'Select first a screenmode',10
		dc.b	'in the settingswindow!',0
nomodemsg1:	dc.b	'Ok',0
	even
	
OpenVisualScreen:

;d0 = Visual Mode
;< d0 = error

;init screen und window datas

		move.l	d0,APG_Free1(a5)

		tst.l	OpScreenMode(a5)
		bne	.nm
		lea	nomodemsg(pc),a1
		lea	nomodemsg1(pc),a2
		sub.l	a3,a3
		sub.l	a4,a4
		lea	tagitemliste1,a0
		move.l	reqtbase(a5),a6
		jsr	_LVOrtEZRequestA(a6)
		moveq	#-1,d0
		rts
.nm
		sf	APG_Mark1(a5)
		
		cmp.l	#OPV_COLOR_NOTTRUE,APG_Free1(a5)
		bne	.depthok

		tst.l	cyberbase(a5)
		beq	.depthok

;check ob 16 oder 24 Bit screen eingestellt

		move.l	cyberbase(a5),a6
		move.l	OpScreenmode(a5),d0
		jsr	_LVOIsCyberModeID(a6)
		tst.l	d0
		beq	.depthok

		move.l	OpScreenmode(a5),d1
		move.l	#CYBRIDATTR_DEPTH,d0
		jsr	_LVOGetCyberIDAttr(a6)

		cmp.w	#8,d0			; größer 8 bit ?
		bls	.depthok

		move.l	OpScreenmode(a5),d1	;wir suchen einen screen mit 8 bit
		move.l	#CYBRIDATTR_WIDTH,d0
		jsr	_LVOGetCyberIDAttr(a6)
		move.l	d0,d5
		move.l	OpScreenmode(a5),d1	;wir suchen einen screen mit 8 bit
		move.l	#CYBRIDATTR_HEIGHT,d0
		jsr	_LVOGetCyberIDAttr(a6)
		move.l	d0,d6

		move.l	#TAG_DONE,-(a7)
		move.l	#8,-(a7)
		move.l	#CYBRBIDTG_Depth,-(a7)
		move.l	d5,-(a7)
		move.l	#CYBRBIDTG_NominalWIDTH,-(a7)
		move.l	d6,-(a7)
		move.l	#CYBRBIDTG_NominalHEIGHT,-(a7)
		move.l	a7,a0
		jsr	_LVOBestCModeIDTagList(a6)
		lea	28(a7),a7
		cmp.l	#INVALID_ID,d0
		bne	.modeok
.modeok
		move.l	d0,d6
		st	APG_Mark1(a5)	;force 8 bit

.depthok
		moveq	#0,d0
		lea	vi_width(pc),a0
		lea	vi_W+4(pc),a1
		move.w	OpdisplayWidth(a5),d0

	tst.b	dscale(a5)
	beq	.noscale	;image nicht scalen, kucken ob screensize ausreicht
	move.w	APG_ImageWidth(a5),d1
	cmp.w	d1,d0
	bhs	.noscale
	move.l	d1,d0
.noscale
		move.l	d0,(a0)
		move.l	d0,(a1)
		move.w	OpDisplayHeight(a5),d0

	tst.b	dscale(a5)
	beq	.noscale1	;image nicht scalen, kucken ob screensize ausreicht
	move.w	APG_ImageHeight(a5),d1
	cmp.w	d1,d0
	bhs	.noscale1
	move.l	d1,d0
.noscale1
		move.l	d0,8(a0)
		move.l	d0,8(a1)
		move.w	OpDisplayDepth(a5),d0

	tst.b	APG_Mark1(a5)
	beq	.n24				;force kein 24 bit
	moveq	#8,d0
	move.l	d0,16(a0)
	move.l	d6,24(a0)
	bra	.doit
.n24
		move.l	d0,16(a0)
		move.l	OpScreenmode(a5),24(a0)
.doit
		move.l	intbase(a5),a6
		lea	vi_Screentags(pc),a1
		sub.l	a0,a0
		jsr	_LVOOpenScreenTagList(a6)
		move.l	d0,vi_screen(a5)
		bne	.w
		moveq	#-1,d0		;Screenopen fail
		rts
.w
		move.l	vi_screen(a5),vi_SC
		sub.l	a0,a0
		lea	vi_WindowTags(pc),a1
		move.l	intbase(a5),a6
		jsr	_LVOOpenWindowTagList(a6)
		move.l	d0,vi_window(a5)
		beq	CloseVisualScreen1

;scale und render  Image

		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5

		move.w	breite(a5),d0
		move.w	hoehe(a5),d1
		move.l	vi_screen(a5),a0
		move.w	sc_width(a0),d2		;Screen breite,höhe
		move.w	sc_height(a0),d3
		
		move.l	d2,d4
		swap	d4
		divu.l	d0,d4
		move.l	d3,d5
		swap	d5
		divu.l	d1,d5

		move.l	d5,d6
		cmp.l	d4,d5
		blo	.wh
		move.l	d4,d6
.wh:
		mulu.l	d6,d0
		mulu.l	d6,d1
		swap	d0
		swap	d1
		ext.l	d0
		ext.l	d1

		move.l	d0,d4
		move.l	d1,d5

		tst.b	dscale(a5)
		beq	.ready
		moveq	#0,d4
		moveq	#0,d5
		move.w	APG_Imagewidth(a5),d4
		move.w	APG_ImageHeight(a5),d5
.ready:
		move.l	d4,OpDestWidth(a5)	;Breite
		move.l	d5,OpDestHeight(a5)	;Höhe

;----------------------------------------------------------------------------------
;init palette
		lea	cb_farbtab8,a0
		move.w	OpDisplayDepth(a5),d0

		tst.b	APG_Mark1(a5)
		beq	.wp
		moveq	#8,d0		;force 8 Bit
		bra	vi_setpal
.wp
		cmp.w	#8,d0			;trucolorscreen ?
		bhi	vi_setpal
		moveq	#1,d1
		lsl.w	d0,d1
		subq.w	#4,d1

		cmp.l	#OPV_COLOR_NOTTRUE,APG_Free1(a5)
		beq	vi_setpal
		tst.b	OpColMode(a5)
		bne	vi_setpal

;erzeuge eine grau palette
		
		move.l	d1,d6
		move.l	d1,d7

		move.l	#256,d2
		divu	d1,d2
		ext.l	d2
		subq.l	#1,d7

		moveq	#0,d0
.nc
		move.b	d0,d1
		swap	d1
		move.b	d0,d1
		lsl.w	#8,d1
		move.b	d0,d1
		move.l	d1,(a0)+
		add.l	d2,d0
		dbra	d7,.nc

		clr.l	(a0)
vi_setpal:
		move.l  vi_window(a5),a0
		move.l  IntBase(a5),a6
		jsr     _LVOViewPortAddress(a6)
		move.l	d0,a0

		move.l	gfxbase(a5),a6
		lea	vi_defaultpal(pc),a1
		jsr	_LVOLoadRGB32(a6)

;---------------------------------------------------------------------------------
		move.l	guigfxbase(a5),a6
		move.l	#TAG_DONE,-(a7)
		move.l	#HSTYPE_15Bit_Turbo,-(a7)
		move.l	#GGFX_HSType,-(a7)
		move.l	a7,a0
		jsr	_LVOCreatePenShareMapA(a6)
		lea	12(a7),a7
		move.l	d0,vi_psm(a5)		;psm

		cmp.l	#OPV_COLOR_NOTTRUE,APG_Free1(a5)
		beq	.noadd

		tst.b	APG_Mark1(a5)
		bne	.add	

		tst.b	OpColMode(a5)
		bne	.noadd
.add:
		move.l	vi_psm(a5),a0
		lea	cb_farbtab8,a1
		move.w	OpDisplayDepth(a5),d1

		tst.b	APG_Mark1(a5)
		bne	.noadd	
	cmp.w	#8,d1
	bls	.w
	moveq	#0,d0
	bra	.do
.w
		moveq	#1,d0
		lsl.w	d1,d0
		subq.w	#4,d0
.do
		move.l	#TAG_DONE,-(a7)
		move.l	d0,-(a7)
		move.l	#GGFX_NumColors,-(a7)
	;	move.l	#GGFX_PaletteFormat,-(a7)
	;	move.l	#PALFMT_RGB32,-(a7)
	;	move.l	#PALFMT_RGB8,-(a7)
		move.l	a7,a2
		jsr	_LVOAddPaletteA(a6)
		lea	12(a7),a7
				
.noadd:		
		tst.l	rndr_rgb(a5)	;24 Bit daten ?
		bne	vi_drawrgb

		lea	PicMap(a5),a0
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.b	planes(a5),d0
		move.w	breite(a5),d1
		move.w	hoehe(a5),d2
		move.l	gfxbase(a5),a6
		jsr	_LVOinitbitmap(a6)

		lea	picmap+8(a5),a0
		move.l	picmem(a5),d0
		moveq	#0,d7		
		moveq	#8-1,d7	
.newplane8
		move.l	d0,(a0)+	;Planes in Strucktur einbinden
		add.l	oneplanesize(a5),d0
		dbra	d7,.newplane8
		bra	.initstruck

		moveq	#0,d7		
		move.b	planes(a5),d7	
		subq	#1,d7
.newplane
		move.l	d0,(a0)+	;Planes in Strucktur einbinden
		add.l	oneplanesize(a5),d0
		dbra	d7,.newplane
		
.initstruck
		moveq	#0,d0
		move.w	anzcolor(a5),d0
		move.l	d0,vi_colors(a5)
		lea	farbtab8+4(a5),a0
		move.l	a0,vi_palette(a5)
		move.l	#PALFMT_RGB32,vi_palfmt(a5)
		lea	picmap(a5),a0
		move.l	#PIXFMT_BITMAP_CLUT,d7
		tst.b	ham8(a5)
		beq	.n8
		move.l	#PIXFMT_BITMAP_HAM8,d7
.n8		tst.b	ham(a5)
		beq	.n6
		move.l	#PIXFMT_BITMAP_HAM6,d7
.n6
		bra	vi_draw

vi_drawrgb:
		clr.l	vi_colors(a5)
		clr.l	vi_palette(a5)
		clr.l	vi_palfmt(a5)
		move.l	rndr_rgb(a5),a0
		move.l	#PIXFMT_0RGB_32,d7

vi_draw:
		move.l	guigfxbase(a5),a6

		move.w	APG_ImageWidth(a5),d0
		move.w	APG_ImageHeight(a5),d1
		cmp.w	#PIXFMT_0RGB_32,d7
		bne	.w
		move.l	APG_Bytewidth(a5),d0
		lsl.l	#3,d0
.w		
		move.l	#TAG_DONE,-(a7)
		move.l	vi_colors(a5),-(a7)		
		move.l	#GGFX_NumColors,-(a7)
		move.l	vi_palfmt(a5),-(a7)
		move.l	#GGFX_PaletteFormat,-(a7)
		move.l	vi_palette(a5),-(a7)
		move.l	#GGFX_Palette,-(a7)
		move.l	d7,-(a7)
		move.l	#GGFX_PixelFormat,-(a7)
;	move.l	#GGFX_HSType,-(a7)
;	move.l	#HSTYPE_15Bit_TURBO,-(a7)

		move.l	a7,a1
		jsr	_LVOMakePictureA(a6)
		lea	36(a7),a7
		move.l	d0,vi_picture(a5)		;logopic

		cmp.l	#OPV_COLOR_NOTTRUE,APG_Free1(a5)
		beq	.ad

		tst.b	APG_Mark1(a5)
		bne	.ad

		tst.b	OpColMode(a5)
		beq	.noadd
.ad
		move.l	vi_psm(a5),a0
		move.l	vi_picture(a5),a1
		sub.l	a2,a2
		jsr	_LVOAddPictureA(a6)

.noadd
		move.l 	vi_window(a5),a0
		move.l  IntBase(a5),a6
		jsr     _LVOViewPortAddress(a6)
		move.l	d0,a2

		move.l	vi_psm(a5),a0
		move.l 	vi_window(a5),a1
		move.l	wd_RPort(a1),a1
		move.l	vp_colormap(a2),a2
		move.l	#TAG_DONE,-(a7)
		move.l	#PRECISION_EXACT,-(a7)
		move.l	#OBP_Precision,-(a7)
		move.l	a7,a3

	;	sub.l	a3,a3
		move.l	guigfxbase(a5),a6
		jsr	_LVOObtainDrawHandleA(a6)
		lea	12(a7),a7

		move.l	d0,vi_drawhandle(a5)		;drawhandle
		move.l	d0,a0

		move.l	vi_picture(a5),a1
		moveq	#0,d0
		moveq	#0,d1
		move.l	#TAG_DONE,-(a7)
		moveq	#0,d3

	tst.b	dscale(a5)
	bne	.nixscale
		move.l	OpDestHeight(a5),d3
		move.l	d3,-(a7)
		move.l	#GGFX_destHeight,-(a7)
		move.l	OpDestWidth(a5),d3
		move.l	d3,-(a7)
		move.l	#GGFX_destWidth,-(a7)
.nixscale:
		move.w	breite(a5),d3
		move.l	d3,-(a7)
		move.l	#GGFX_SourceWidth,-(a7)
		move.w	hoehe(a5),d3
		move.l	d3,-(a7)
		move.l	#GGFX_SourceHeight,-(a7)
		move.l	#DITHERMODE_NONE,d5
	tst.b	vidither(a5)
	beq	.nixdither
		move.l	#DITHERMODE_EDD,d5
.nixdither:
		move.l	d5,-(a7)
		move.l	#GGfx_Dithermode,-(a7)
		move.l	a7,a2
		jsr	_LVODrawpictureA(a6)
		lea	36+8(a7),a7
	tst.b	dscale(a5)
	beq	.s
		sub.l	#16,a7		;es gab keine tags für scale
.s

		move.l	VisualInfo(a5),tmpvisual(a5)

		move.l	vi_screen(a5),a0
		sub.l	a1,a1
		move.l	gadbase(a5),a6
		jsr	_LVOGetVisualInfoA(a6)
		move.l	d0,VisualInfo(a5)
		
		moveq	#0,d0

		rts

CloseVisualScreen:
		move.l	VisualInfo(a5),a0
		move.l	gadbase(a5),a6
		jsr	_LVOFreeVisualInfo(a6)

		move.l	tmpvisual(a5),VisualInfo(a5)

		move.l	vi_screen(a5),a0
		move.l	intbase(a5),a6
		jsr	_LVOScreenToBack(a6)

		move.l	guigfxbase(a5),a6

		move.l	vi_drawhandle(a5),d0
		beq	.nf
		move.l	d0,a0
		jsr	_LVOReleaseDrawHandle(a6)
		clr.l	vi_drawhandle(a5)
.nf
		move.l	vi_picture(a5),d0
		beq	.np
		move.l	d0,a0
		jsr	_LVODeletePicture(a6)
		clr.l	vi_picture(a5)
.np:
		move.l	vi_psm(a5),d0
		beq	.npsm
		move.l	d0,a0
		jsr	_LVODeletePenShareMap(a6)
		clr.l	vi_psm(a5)
.npsm

		move.l	vi_window(a5),d0
		beq	CloseVisualScreen1\.nixscreen
		move.l	d0,a0
		move.l	intbase(a5),a6
		jsr	_LVOCloseWindow(a6)
CloseVisualScreen1:
		move.l	vi_screen(a5),d0
		beq	.nixscreen
		move.l	d0,a0
		move.l	intbase(a5),a6
		jsr	_LVOCloseScreen(a6)
.nixscreen
		rts

;-------------------------------------------------------------------------

vi_defaultpal:
		dc.l	$00040000,$95000000,$89000000,$98000000
		dc.l	$00000000,$00000000,$00000000,$fd000000
		dc.l	$f3000000,$ff000000,$80000000,$59000000
		dc.l	$92000000,0
		
vi_ScreenTags:
		dc.l	SA_Left,0
		dc.l	SA_Top,0
		dc.l	SA_Width
vi_width:	dc.l	800
		dc.l	SA_Height
vi_height:	dc.l	600
		dc.l	SA_Depth
vi_depth:	dc.l	8
		dc.l	SA_DisplayID
vi_mainID:	dc.l	$21000
		dc.l	SA_Pens,DriPen
		dc.l    SA_AutoScroll,1
		dc.l	SA_Draggable,1
		dc.l	SA_Showtitle,0
		dc.l	SA_FullPalette,1
		dc.l	SA_Sharepens,1
		dc.l	SA_LikeWorkbench,1
		dc.l	TAG_DONE

vi_WindowTags:
vi_L:		dc.l    WA_Left,0
vi_T:		dc.l    WA_Top,0
vi_W:		dc.l    WA_Width,800
vi_H:		dc.l    WA_Height,600
		dc.l	WA_IDCMP,IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_REFRESHWINDOW!IDCMP_MOUSEMOVE!IDCMP_Mousebuttons
	 	dc.l	WA_Flags,WFLG_REPORTMOUSE!WFLG_BORDERLESS!WFLG_RMBTRAP!WFLG_ACTIVATE!WFLG_BACKDROP
		dc.l    WA_CustomScreen
vi_SC:		dc.l	0
		dc.l    TAG_DONE


;------------- Ermittle die Viewsize von einem View -----------------------*
;>A0 Viewport
;<d0,d1,d2,d3 x1,y1,x2,y2
GetViewSize:
		move.l	gfxbase(a5),a6
		jsr	_LVOGetVPModeID(a6)
		move.l	d0,d2

		sub.l	a0,a0
		lea	infopuffer,a1
		moveq	#88,d0
		move.l	#DTAG_DIMS,d1
		jsr	_LVOGetDisplayinfodata(a6)
		lea	infopuffer+dim_StdOScan,a1
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		move.w	(a1)+,d0
		move.w	(a1)+,d1
		move.w	(a1)+,d2
		move.w	(a1)+,d3
		rts

;--------------------------------------------------------------------------
initpicmap:
		lea	PicMap(a5),a0
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.b	planes(a5),d0
		move.w	breite(a5),d1
		move.w	hoehe(a5),d2
		move.l	gfxbase(a5),a6
		jsr	_LVOinitbitmap(a6)

		lea	picmap+8(a5),a0
		move.l	picmem(a5),d0
		moveq	#0,d7		
		moveq	#8-1,d7	
.newplane8
		move.l	d0,(a0)+	;Planes in Strucktur einbinden
		add.l	oneplanesize(a5),d0
		dbra	d7,.newplane8
		rts

;-------------------------------------------------------------------------
; Speicher aktuellen Buffer ins tmp für undo
;-------------------------------------------------------------------------
Save2TMP:
		tst.l	undolevel(a5)
		beq	.back
		bmi	.back
		tst.b	pundo(a5)
		beq.b	.back
		tst.w	loadflag(a5)
		bne	.doit
		sf	st_overflow(a5)
	move.l	#-1,st_lasttmp(a5)
.back		rts
.doit	
		move.l	st_lasttmp(a5),d0
		addq.l	#1,d0
		cmp.l	undolevel(a5),d0
		bls	.levelok	;wir haben noch freie level
		beq	.clearover
		moveq	#0,d0
		st	st_overflow(a5)
		bra	.levelok
.clearover:	sf	st_overflow(a5)
.levelok:
		move.l	d0,st_lasttmp(a5)
		tst.b	st_overflow(a5)
		beq	.no
		move.l	d0,d1
		addq.w	#1,d1
		move.l	d1,st_first(a5)
.no:
		move.l	st_lastmax(a5),d1
		tst.b	st_overflow(a5)
		beq	.noflow
		move.l	st_first(a5),d1
		subq.w	#1,d1
		move.l	d1,st_lastmax(a5)
		bra	.egal
.noflow
		cmp.l	d0,d1
		bhi	.egal
		move.l	d0,st_lastmax(a5)
.egal:	
		move.l	tmpname(a5),a1
		
		moveq	#0,d7		;flag für die nullen
		lea	sc_hexdeztab,a0	;Tabellendisgs
		moveq	#4,d3
.Hexdez2:	move.l	(a0)+,d1		;Tabellenzahl
		moveq	#0,d2			;Zahl
.Hexdez3:	addq.l	#1,d2
		sub.l	d1,d0
		bcc.s	.Hexdez3
		add.l	d1,d0
		add.b	#$2f,d2
		cmp.b	#$30,d2
		bne	.cp
		cmp.b	#1,d1
		beq	.cp
		tst.l	d7	;waren schon andere zahlen  ?
		beq	.np	
.cp:		move.b	d2,(a1)+
		moveq	#1,d7
.np:		dbf	d3,.Hexdez2

		lea	ct_tmpname,a1
		move.l	a1,d1
		move.l	#MODE_NEWFILE,d2	;newfile
		move.l	dosbase(a5),a6
		jsr	_LVOOpen(a6)
		tst.l	d0
		beq	st_ende		;file error
		move.l	d0,st_filehandle(a5)

		lea	tmpbuffer,a0
		move.w	#tmpsavesizeof-1,d7
.nc:		clr.b	(a0)+
		dbra	d7,.nc

		lea	tmpbuffer,a0
		move.w	APG_ImageWidth(a5),tp_width(a0)
		move.w	APG_ImageHeight(a5),tp_height(a0)
		move.b	APG_Planes(a5),tp_depth(a0)
		move.l	APG_ByteWidth(a5),tp_bytewidth(a0)
		moveq	#tp_nomode,d0		
		tst.b	ham(a5)
		beq	.noham
		moveq	#tp_ham,d0
.noham:		tst.b	ham8(a5)
		beq	.noham8
		moveq	#tp_ham8,d0
.noham8:	tst.b	ehb(a5)
		beq	.noehb
		moveq	#tp_ehb,d0
.noehb:		move.b	d0,tp_modeflags(a0)

		move.l	DisplayID(a5),tp_modeID(a0)
		move.l	oneplanesize(a5),tp_oneplanesize(a0)
		move.w	APG_Colorcount(a5),tp_colorcount(a0)
		lea	FileName(a5),a1
		lea	tp_name(a0),a2
.w1		move.b	(a1)+,(a2)+
		bne	.w1
		clr.b	(a2)+

		sf	tp_paletteflag(a0)
		cmp.b	#8,APG_Planes(a5)
		bhi	.nixpal
		st	tp_paletteflag(a0)
		lea	tp_palette(a0),a2
		lea	farbtab8+4(a5),a1
		move.l	#256-1,d7
.npa:		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		dbra	d7,.npa
.nixpal:
		sf	tp_bitmapflag(a0)
		sf	tp_rgbflag(a0)
		tst.l	picmem(a5)
		beq	.nobit
		st	tp_bitmapflag(a0)
.nobit:		tst.l	APG_rndr_rendermem(a5)
		beq	.norgb
		st	tp_rgbflag(a0)
.norgb:
		move.l	st_filehandle(a5),d1
		move.l	a0,d2
		move.l	#tmpsavesizeof,d3
		jsr	_LVOWrite(a6)
		
		tst.l	picmem(a5)
		beq	.nixbitmap
		move.l	APG_ByteWidth(a5),d3
		mulu	APG_ImageHeight(a5),d3
		moveq	#0,d1
		move.b	APG_Planes(a5),d1
		mulu.l	d1,d3
		move.l	st_filehandle(a5),d1
		move.l	picmem(a5),d2
		jsr	_LVOWrite(a6)
		tst.l	APG_rndr_rendermem(a5)
		beq	.close
.nixbitmap:
		move.l	APG_ByteWidth(a5),d3
		lsl.l	#3,d3
		mulu	APG_ImageHeight(a5),d3
		lsl.l	#2,d3

		move.l	st_filehandle(a5),d1
		move.l	APG_rndr_rgb(a5),d2
		jsr	_LVOWrite(a6)
.close
		
		move.l	st_filehandle(a5),d1
		move.l	dosbase(a5),a6
		jsr	_LVOClose(a6)

		clr.l	tag_undodis
		clr.l	tag_redodis

		move.l	gadbase(a5),a6
		lea	mainwinGadgets,a0
		move.l	GD_gundo*4(a0),a0
		move.l	mainwinWnd(a5),a1
		sub.l	a2,a2
		lea	nc_ghost,a3
		clr.l	4(a3)
		jsr	_LVOGT_SetGadgetAttrsA(a6)

		move.l	gadbase(a5),a6
		lea	mainwinGadgets,a0
		move.l	GD_gredo*4(a0),a0
		move.l	mainwinWnd(a5),a1
		sub.l	a2,a2
		lea	nc_ghost,a3
		jsr	_LVOGT_SetGadgetAttrsA(a6)

st_ende:
		rts

;------------------------------------------------------------------------
; Lösche undo files
;------------------------------------------------------------------------

deletetmp:

		move.l	dosbase(a5),a6
		moveq	#0,d6
		
.nextfile:
		move.l	d6,d0
		move.l	tmpname(a5),a1
		moveq	#0,d7		;flag für die nullen
		lea	sc_hexdeztab,a0	;Tabellendisgs
		moveq	#4,d3
.Hexdez2:	move.l	(a0)+,d1		;Tabellenzahl
		moveq	#0,d2			;Zahl
.Hexdez3:	addq.l	#1,d2
		sub.l	d1,d0
		bcc.s	.Hexdez3
		add.l	d1,d0
		add.b	#$2f,d2
		cmp.b	#$30,d2
		bne	.cp
		cmp.b	#1,d1
		beq	.cp
		tst.l	d7	;waren schon andere zahlen  ?
		beq	.np	
.cp:		move.b	d2,(a1)+
		moveq	#1,d7
.np:		dbf	d3,.Hexdez2

		addq.w	#1,d6

		lea	ct_tmpname,a1
		move.l	a1,d1
		jsr	_LVODeleteFile(a6)
		tst.l	d0
		bne	.nextfile

		rts

;-------------------------------------------------------------------------
undo:
		move.l	st_lasttmp(a5),d0
		cmp.l	st_first(a5),d0
		bne	.w
		bra.l	waitaction
.w
		subq.w	#1,d0
		bpl	.weiter
		tst.b	st_overflow(a5)
		move.l	undolevel(a5),d0
.weiter
		move.l	d0,st_lasttmp(a5)	

		move.l	tmpname(a5),a1
		moveq	#0,d7		;flag für die nullen
		lea	sc_hexdeztab,a0	;Tabellendisgs
		moveq	#4,d3
.Hexdez2:	move.l	(a0)+,d1		;Tabellenzahl
		moveq	#0,d2			;Zahl
.Hexdez3:	addq.l	#1,d2
		sub.l	d1,d0
		bcc.s	.Hexdez3
		add.l	d1,d0
		add.b	#$2f,d2
		cmp.b	#$30,d2
		bne	.cp
		cmp.b	#1,d1
		beq	.cp
		tst.l	d7	;waren schon andere zahlen  ?
		beq	.np	
.cp:		move.b	d2,(a1)+
		moveq	#1,d7
.np:		dbf	d3,.Hexdez2

		lea	ct_tmpname,a1
		move.l	a1,d1
		move.l	#MODE_OLDFILE,d2	;newfile
		move.l	dosbase(a5),a6
		jsr	_LVOOpen(a6)
		tst.l	d0
		bne	.undook
		lea	undoerrormsg(pc),a4
		jsr	status
		bra.l	waitaction
						
.undook:	move.l	d0,st_filehandle(a5)

		move.l	d0,d1
		lea	tmpbuffer,a0
		move.l	a0,d2
		move.l	#tmpsavesizeof,d3
		jsr	_LVORead(a6)
		
		lea	tmpbuffer,a0
		move.w	tp_width(a0),APG_ImageWidth(a5)
		move.w	tp_height(a0),APG_ImageHeight(a5)
		move.b	tp_depth(a0),APG_Planes(a5)
		move.l	tp_bytewidth(a0),APG_ByteWidth(a5)
		move.b	tp_modeflags(a0),d0
		sf	ham(a5)
		sf	ham8(a5)
		sf	ehb(a5)
		cmp.b	#tp_nomode,d0
		beq	.modeok
		cmp.b	#tp_ham,d0
		bne	.noham
		st	ham(a5)
.noham		cmp.b	#tp_ham8,d0
		bne	.noham8
		st	ham8(a5)
.noham8		cmp.b	#tp_ehb,d0
		bne	.modeok
		st	ehb(a5)
.modeok:
		move.l	tp_modeID(a0),DisplayID(a5)
		move.l	tp_oneplanesize(a0),oneplanesize(a5)
		move.w	tp_colorcount(a0),APG_Colorcount(a5)

		tst.b	tp_paletteflag(a0)
		beq	.nixpal
		lea	tp_palette(a0),a2
		lea	farbtab8(a5),a1
		moveq	#0,d0
		moveq	#1,d1
		move.b	APG_Planes(a5),d0
		lsl.w	d0,d1
		tst.b	ham8(a5)
		beq	.wnh
		moveq	#64,d1
.wnh:		tst.b	ham(a5)
		beq	.wnhh
		moveq	#32,d1
.wnhh:		tst.b	ehb(a5)
		beq	.weh
		moveq	#64,d1
.weh	
		move.l	d1,d7
		swap	d1
		move.l	d1,(a1)+
		subq.w	#1,d7
.npa:		move.l	(a2)+,(a1)+
		move.l	(a2)+,(a1)+
		move.l	(a2)+,(a1)+
		dbra	d7,.npa
		clr.l	(a1)+
		
.nixpal:
		move.l	picmem(a5),d0
		beq	.npm
		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
		clr.l	picmem(a5)
.npm
		lea	tmpbuffer,a0
		tst.b	tp_bitmapflag(a0)
		beq	.nixbitmap
		move.l	APG_Bytewidth(a5),d0
		mulu	APG_ImageHeight(a5),d0
		moveq	#0,d1
		move.b	APG_Planes(a5),d1
		mulu.l	d1,d0
		move.l	d0,d5
		move.l	#MEMF_ANY+MEMF_CLEAR,d1
		move.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		tst.l	d0
		bne	.mok
		lea	undoerrormsg1(pc),a4
		jsr	status
		bra.l	waitaction
		
.mok:		move.l	d0,picmem(a5)
		move.l	st_filehandle(a5),d1
		move.l	d0,d2
		move.l	d5,d3
		move.l	dosbase(a5),a6
		jsr	_LVORead(a6)		
.nixbitmap:
		lea	tmpbuffer,a0
		move.l	APG_rndr_rendermem(a5),d0
		beq	.nr
		move.l	d0,a1
		move.l	4.w,a6
		jsr	_LVOFreeVec(a6)
		clr.l	APG_rndr_rendermem(a5)
.nr
		lea	tmpbuffer,a0
		tst.b	tp_rgbflag(a0)
		beq	.nixrgb

		move.l	APG_ByteWidth(a5),d0
		moveq	#0,d1
		move.w	APG_ImageHeight(a5),d1
		jsr	APR_InitRenderMem(a5)
		tst.l	d0
		bne	.rok
.rok:		
		move.l	APG_ByteWidth(a5),d3
		lsl.l	#3,d3
		mulu	APG_ImageHeight(a5),d3
		lsl.l	#2,d3

		move.l	st_filehandle(a5),d1
		move.l	APG_rndr_rgb(a5),d2
		move.l	dosbase(a5),a6
		jsr	_LVORead(a6)
.nixrgb
		move.l	st_filehandle(a5),d1
		move.l	dosbase(a5),a6
		jsr	_LVOClose(a6)

		bsr.l	setpicsizegads

		lea	tmpbuffer,a0	
		lea	tp_name(a0),a0
		lea	TAG_project,a1
		move.l	a0,(a1)
		move.l	a0,d5
		move.l	#GD_gproject,d6
		bsr.l	setnewname

		bsr.l	setmodi
		
		jsr	APR_MakePreview(a5)

		bra.l	waitaction

;-------------------------------------------------------------------------
redo:
		move.l	st_lasttmp(a5),d0
		move.l	st_lastmax(a5),d1
		cmp.l	d0,d1
		beq.l	waitaction
		addq.w	#1,d0
		tst.b	st_overflow(a5)
		beq	.nixflow
		cmp.l	undolevel(a5),d0
		bls	undo\.weiter	;.nixflow
		moveq	#0,d0
		bra	undo\.weiter
.nixflow:	cmp.l	d0,d1
		bcc	undo\.weiter
		bra.l	waitaction


undoerrormsg:	dc.b	'error while reading undo file!',0
undoerrormsg1:	dc.b	'error while allocate picture buffer!',0

;*----------------- Tabellen und Daten ------------------------------------*
datas:

aboutmsg:
		dc.b	'ArtPRO V'
		version
		dc.b	10,'---===============---',10
		dc.b	'assembled at '
		%getdate
		dc.b	10,'© 1994/98 by Frank Pagels / Defect Softworks',10,10

	dc.b	'This piece of software is shareware.',10
	dc.b	'Please consider registration if you',10
	dc.b	'use ArtPRO frequently. Fee is DM 20,- ,US $15 or UK £10.',10
	dc.b	'Please submit your suggestions, bug reports etc. to',10,10
	dc.b	'Frank Pagels',10
	dc.b	'Kolumbusring 39',10
	dc.b	'18106 Rostock / FRG',10
	dc.b	'Tel: +49 (0)381/1207938',10,10
	dc.b	'E-Mail:    copper@informatik.uni-rostock.de',10
	dc.b	'    copper@hysteria.dssd.sub.org',10 
	dc.b	'WWW: http://copper.home.pages.de/  ArtPRO support page',10,10
	dc.b	'Special thanks to Timm S. Müller, for his wonderful render library,',10
	dc.b	'designing the GUI and many other help.Greets and thanks to Buggs,',10
	dc.b	' M.U.D.U. /Defect for some additional help.',0
okmsg:
		dc.b	'Wow|Key',0
reqtitle:
		dc.b	'Information!',0
	even
	
overmsg:
		dc.b	'File already exists! Overwrite?',0
overmsg1:
		dc.b	'Okay|Oh no',0
		
	even
keymsg:
		dc.b	'This is an unregistered version of ArtPRO',0
key1msg:
		dc.b	'I understand!',0

thanxmsg:	dc.b	'Thanks!',0

	even
reqmsg:
		dc.b	'This is the registered version of ArtPRO!',10
		dc.b	'If you dare to spread your private key-file',10
		dc.b	"you will lose your human rights and dignity!",10
		dc.b	'ArtPRO ist registered to:',10,10
reqmsgend:

reqmsglen	= reqmsgend-reqmsg		
	even
lockmsg:
		dc.b	'Lock Monitor',10
		dc.b	'------------',10
		dc.b	'This will lock the actual screenmode!',10
		dc.b	'This is only available with the',10
		dc.b	'registered version of ArtPRO!',0
		
	even
nopromptmsg:
		dc.b	'Prompt for sprite ctrl.words',10
		dc.b	'----------------------------',10
		dc.b	'This will allow customized control',10
		dc.b	'word calculation. Sorry, this is',10
		dc.b	'only available with the registered',10
		dc.b	'version of ArtPRO!',0

	even
nokeymsg:	dc.b	'This Betaversion works only with',10
		dc.b	'a valid keyfile. Go and get one!',0

TagItemListe1:	dc.l	$80000000+7		;MultiSelect
rt_screen1:	dc.l	0			;Pointer ????
		dc.l	_rt_window
rt_window1:	dc.l	0
	;	dc.l	RT_REQPOS
	;	dc.l	2			;Centriert
		dc.l	RTEZ_ReqTitle
		dc.l	reqtitle
		dc.l	RT_LOckWindow,1
		dc.l	RTEZ_Flags,EZREQF_CENTERTEXT
		dc.l	0

dirtag:		dc.l	$80000032	;RTFI_Dir
		dc.l	PrefsDir
		dc.l	$80000034
		dc.l	0

	even

;*----------- Gadtools-Struckturen ----------*

;--Mainwin--

GD_gload		=	0
GD_gsave		=	1
GD_gexit		=	2
GD_gabout		=	3
GD_giconify		=	4
GD_gcutbrush		=	5
GD_gviewpic		=	6
GD_geffect		=	7
GD_gexecuteoperator	=	8
GD_gexecutepalette	=	9
GD_gpaletteoption	=	10
GD_gpreferences		=	11
GD_gstatus		=	12
GD_gmemory		=	13
GD_gchip		=	14
GD_gfast		=	15
GD_gloader		=	16
GD_gsaver		=	17
GD_gproject		=	18
GD_gmonitor		=	19
GD_gxsize		=	20
GD_gysize		=	21
GD_gdepth		=	22
GD_gxbrush		=	23
GD_gybrush		=	24
GD_glockmon		=	25
GD_gloadrout		=	26
GD_gsaverout		=	27
GD_gmon			=	28
GD_goperator		=	29
GD_grenderset		=	30
GD_gclear		=	31
GD_gundo		=	32
GD_gredo		=	33


;-- New Choose Loader Saver Win --

GD_nloadreq		=	0
GD_nconfig		=	1
GD_nclone		=	2
GD_nadd			=	3
GD_nerase		=	4
GD_nup			=	5
GD_ndown		=	6
GD_nload		=	7
GD_nsave		=	8
GD_nAcceptandLoad	=	9
GD_nAccept		=	10
GD_nCancel		=	11
GD_nname		=	12

;-- Window zur loader saver auswahl --

GD_nclistview		=	0
GD_ncinfo		=	1
GD_ncadd		=	2
GD_ncok			=	3

;-- Kontrollwindow --

GD_aktx			=	0	;aktueller X-wert
GD_akty			=	1	;aktueller Y-wert
GD_brushx		=	2
GD_brushy		=	3
GD_autocut		=	4
GD_kok			=	5
GD_kcancel		=	6
GD_kwords		=	7
GD_kscale		=	8

;-- Screenauswahlwindow --

GD_screenlist		=	0
GD_sok			=	1
GD_scancel		=	2

;--- Imageload ------

GD_imagewidth		=	0
GD_imageheight		=	1
GD_imagedepth		=	2
GD_imagedisplay		=	3
GD_imagedoit		=	4
GD_imagecancel		=	5

;--- Specify linkdata ---

GD_linkextdef		=	0
GD_linkmem		=	1
GD_linkok		=	2
GD_linkcancel		=	3

;--- Color Bias ---
GD_color		=	0
GD_bright		=	1
GD_contrast		=	2
GD_red			=	3
GD_green		=	4
GD_blue			=	5
GD_use			=	6
GD_keep			=	7
GD_cancel		=	8
GD_colornull		=	9
GD_brightnull		=	10
GD_contrastnull		=	11
GD_rednull		=	12
GD_greennull		=	13
GD_bluenull		=	14
GD_zeroall		=	15
GD_gamma		=	16
GD_gammanull		=	17

;--- Sprite Position ---
GD_screenx		=	0
GD_screeny		=	1
GD_picx			=	2
GD_picy			=	3
GD_spok			=	4
GD_spcancel		=	5
GD_spall		=	6

;--- Labels ---
GD_labelname		=	0
GD_countstart		=	1
GD_create		=	2
GD_createall		=	3
GD_lcancel		=	4

;--- Palette ---
GD_pal_red		=	0
GD_pal_green		=	1
GD_pal_blue		=	2
GD_pal_colorsystem	=	3
GD_pal_copy		=	4
GD_pal_spread		=	5
GD_pal_swap		=	6
GD_pal_rangeslider	=	7
GD_pal_number		=	8
GD_pal_ok		=	9
GD_pal_undo		=	10
GD_pal_reset		=	11
GD_pal_remap		=	12
GD_pal_rangeinfo	=	13
GD_pal_sort		=	14
GD_pal_pick		=	15

;--- Palette Sortwindow ---
GD_pal_sortdark		=	0
GD_pal_sortlight	=	1
GD_pal_sortcancel	=	2

;---------------------------------------------------------------
mainwin_CNT		=	34
newchoosewin_CNT	=	13
newmodulewin_CNT	=	4
konwin_CNT		=	9-1
screen_CNT		=	3
imagewin_CNT		=	6
linkwin_CNT		=	4
biaswin_CNT		=	18
spritewin_CNT		=	7
labelwin_CNT		=	5
palwin1_CNT		=	0
palwin2_CNT		=	16
palwin3_CNT		=	3

mainwinGadgets:		dcb.l	mainwin_CNT,0
newchoosewinGadgets: 	dcb.l	newchoosewin_CNT,0
newmodulewinGadgets:	dcb.l	newmodulewin_CNT,0
konwinGadgets:		dcb.l	konwin_CNT,0
screenwinGadgets:	dcb.l	screen_CNT,0
imagewinGadgets:	dcb.l	imagewin_CNT,0
linkwinGadgets:		dcb.l	linkwin_CNT,0
biaswinGadgets:		dcb.l	biaswin_CNT,0
spritewinGadgets:	dcb.l	spritewin_CNT,0
labelwinGadgets:	dcb.l	labelwin_CNT,0
palwingadgets1:		dcb.l	1,0
palwingadgets2:		dcb.l	palwin2_CNT,0
palwingadgets3:		dcb.l	palwin3_CNT,0

BufNewGad:
		dc.w	0,0,0,0
		dc.l	0,0
		dc.w	0
		dc.l	0,0,0
TD:		dc.l	TAG_DONE
NR:		dc.l	GT_VisualInfo,$00000000,TAG_DONE
IR:		dc.l	GT_VisualInfo,$00000000,GTBB_Recessed,1,TAG_DONE

lockcode:	dc.w	$673e

proglenzaehler:	dc.l	proglen	;sicherheitszaehler falls Prog verändert wurde

mainwinGTypes:
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	TEXT_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	TEXT_KIND
		dc.w	NUMBER_KIND
		dc.w	NUMBER_KIND
		dc.w	NUMBER_KIND
		dc.w	TEXT_KIND
		dc.w	TEXT_KIND
		dc.w	TEXT_KIND
		dc.w	TEXT_KIND
		dc.w	NUMBER_KIND
		dc.w	NUMBER_KIND
		dc.w	TEXT_KIND
		dc.w	NUMBER_KIND
		dc.w	NUMBER_KIND
		dc.w	CHECKBOX_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND

newchoosewinGTypes:
		dc.w	LISTVIEW_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	STRING_KIND		

newmodulewinGtypes:
		dc.w	LISTVIEW_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND

KonwinGTypes:
		dc.w	INTEGER_KIND
		dc.w	INTEGER_KIND
		dc.w	INTEGER_KIND
		dc.w	INTEGER_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	INTEGER_KIND
		dc.w	CHECKBOX_KIND

screenwinGTypes:
		dc.w	LISTVIEW_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND

imagewinGtypes:
		dc.w	INTEGER_KIND
		dc.w	INTEGER_KIND
		dc.w	INTEGER_KIND
		dc.w	CYCLE_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND

linkwinGtypes:
		dc.w	STRING_KIND		
		dc.w	CYCLE_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND

biaswinGTypes:
		dc.w	SLIDER_KIND
		dc.w	SLIDER_KIND
		dc.w	SLIDER_KIND
		dc.w	SLIDER_KIND
		dc.w	SLIDER_KIND
		dc.w	SLIDER_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	SLIDER_KIND
		dc.w	BUTTON_KIND

spritewinGtypes:
		dc.w	INTEGER_KIND
		dc.w	INTEGER_KIND
		dc.w	INTEGER_KIND
		dc.w	INTEGER_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND

labelwinGtypes:
		dc.w	STRING_KIND
		dc.w	INTEGER_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND

palwinGTypes1:
		dc.l	0
		
palwinGTypes2:
		dc.w	SLIDER_KIND
		dc.w	SLIDER_KIND
		dc.w	SLIDER_KIND
		dc.w	CYCLE_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	SCROLLER_KIND
		dc.w	NUMBER_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	TEXT_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND

palwingtypes3:
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND
		dc.w	BUTTON_KIND

mainwinNGads:
		dc.w	23-4,103,74,14
		dc.l	gloadText,0
		dc.w	GD_gload
		dc.l	PLACETEXT_IN,0,0
		dc.w	23-4,122,74,14
		dc.l	gsaveText,0
		dc.w	GD_gsave
		dc.l	PLACETEXT_IN,0,0
		dc.w	311-4,23,85,14
		dc.l	gexitText,0
		dc.w	GD_gexit
		dc.l	PLACETEXT_IN,0,0
		dc.w	21-4,23,85,14
		dc.l	gaboutText,0
		dc.w	GD_gabout
		dc.l	PLACETEXT_IN,0,0
		dc.w	213-4,23,85,14
		dc.l	giconifyText,0
		dc.w	GD_giconify
		dc.l	PLACETEXT_IN,0,0

		dc.w	60,183,200,14
		dc.l	gcutbrushText,0
		dc.w	GD_gcutbrush
		dc.l	PLACETEXT_IN,0,0

		dc.w	340,141,120,14
		dc.l	gviewpicText,0
		dc.w	GD_gviewpic
		dc.l	PLACETEXT_IN,0,0

		dc.w	425-8,172+11+10,169,14
		dc.l	0,0
		dc.w	GD_geffect
		dc.l	PLACETEXT_IN,0,0

		dc.w	345-8,172+11+10,76,14
		dc.l	gexecuteoperatorText,0
		dc.w	GD_gexecuteoperator
		dc.l	PLACETEXT_IN,0,0

		dc.w	345-8,221,120,14
		dc.l	gexecutepaletteText,0
		dc.w	GD_gexecutepalette
		dc.l	PLACETEXT_IN,0,0

		dc.w	490,221,120,14	;Palette Cycle
		dc.l	gcolorbiastext,0
		dc.w	GD_gpaletteoption
		dc.l	PLACETEXT_IN,0,0

		dc.w	117-4,23,85,14
		dc.l	gpreferencesText,0
		dc.w	GD_gpreferences
		dc.l	PLACETEXT_IN,0,0
		dc.w	75-4,42,322,14
		dc.l	gstatustext,0
		dc.w	GD_gstatus
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	75-4,61,72,14
		dc.l	gmemoryText,0
		dc.w	GD_gmemory
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	200-4,61,72,14
		dc.l	gchipText,0
		dc.w	GD_gchip
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	325-4,61,72,14
		dc.l	gfastText,0
		dc.w	GD_Gfast
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	102-4,103,186,14
		dc.l	0,0
		dc.w	GD_Gloader
		dc.l	0,0,0
		dc.w	102-4,122,186,14
		dc.l	0,0
		dc.w	GD_Gsaver
		dc.l	0,0,0
		dc.w	102-4,141,209,14
		dc.l	gprojecttext,0
		dc.w	GD_Gproject
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	386-8,103,207,14
		dc.l	gmonitorText,0
		dc.w	GD_Gmonitor
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	386-8,122,60,14
		dc.l	gxsizeText,0
		dc.w	GD_Gxsize
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	469-8,122,60,14
		dc.l	gysizeText,0
		dc.w	GD_Gysize
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	554-8,122,63,14
		dc.l	gdepthText,0
		dc.w	GD_Gdepth
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	176-4-48,202+18,55,14
		dc.l	0,0
		dc.w	GD_Gxbrush
		dc.l	0,0,0
		dc.w	256-4-48,202+18,55,14
		dc.l	gybrushText,0
		dc.w	GD_Gybrush
		dc.l	PLACETEXT_LEFT,0,0

		dc.w	568,143,26,11
		dc.l	glockmontext,0
		dc.w	GD_glockmon
		dc.l	PLACETEXT_RIGHT,0,0
		dc.w	290-2,103,20,14
		dc.l	selecttext1,0
		dc.w	GD_gloadrout
		dc.l	0,0,0
		dc.w	290-2,122,20,14
		dc.l	selecttext2,0
		dc.w	GD_gsaverout
		dc.l	0,0,0
		dc.w	590,103,20,14
		dc.l	selecttext3,0
		dc.w	GD_gmon
		dc.l	0,0,0

		dc.w	592-2,186-3+10,20,14
		dc.l	selecttext,0
		dc.w	GD_goperator
		dc.l	0,0,0
		dc.w	465,141,95,14
		dc.l	grenderText,0
		dc.w	GD_grenderset
		dc.l	PLACETEXT_IN,0,0

		dc.w	60,202+18,55,14
		dc.l	gleartext,0
		dc.w	GD_gclear
		dc.l	PLACETEXT_IN,0,0

		dc.w	395,178,76,12
		dc.l	gundoText,0
		dc.w	GD_gundo
		dc.l	PLACETEXT_IN,0,0
		dc.w	475,178,76,12
		dc.l	gredoText,0
		dc.w	GD_gredo
		dc.l	PLACETEXT_IN,0,0


newchoosewinNGads:
		dc.w	3,3,190,73+16
		dc.l	0,0
		dc.w	GD_nloadreq
		dc.l	0,0,0
		dc.w	197,3,58,15
		dc.l	nconfigtext,0
		dc.w	GD_nconfig
		dc.l	PLACETEXT_IN,0,0
		dc.w	197,25,58,15
		dc.l	nclonetext,0
		dc.w	GD_nclone
		dc.l	PLACETEXT_IN,0,0
		dc.w	197,41,58,15
		dc.l	naddtext,0
		dc.w	GD_nadd
		dc.l	PLACETEXT_IN,0,0
		dc.w	197,57,58,15
		dc.l	nerasetext,0
		dc.w	GD_nerase
		dc.l	PLACETEXT_IN,0,0
		dc.w	197,67+4+8,58,15
		dc.l	nuptext,0
		dc.w	GD_nup
		dc.l	PLACETEXT_IN,0,0
		dc.w	197,82+4+9,58,15
		dc.l	ndowntext,0
		dc.w	GD_ndown
		dc.l	PLACETEXT_IN,0,0
		dc.w	75,137-4,53,12
		dc.l	nloadtext,0
		dc.w	GD_nload
		dc.l	PLACETEXT_IN,0,0
		dc.w	130,137-4,53,12
		dc.l	nsavetext,0
		dc.w	GD_nsave
		dc.l	PLACETEXT_IN,0,0
		dc.w	3,115-2,252,16
		dc.l	glAcceptandLoadText,0
		dc.w	GD_nAcceptandLoad
		dc.l	PLACETEXT_IN,0,0

		dc.w	3,135-4,65,16
		dc.l	glAcceptText,0
		dc.w	GD_nAccept
		dc.l	PLACETEXT_IN,0,0
		dc.w	190,135-4,65,16
		dc.l	glCancelText,0
		dc.w	GD_nCancel
		dc.l	PLACETEXT_IN,0,0
		dc.w	3,79+16,190,15
		dc.l	0,0
		dc.w	GD_nname
		dc.l	0,0,0

newmodulewinNGads:
		dc.w	3,3,213,73+16
		dc.l	0,0
		dc.w	GD_nclistview
		dc.l	0,0,0
		dc.w	79,97,60,15
		dc.l	ninfotext,0
		dc.w	GD_ncinfo
		dc.l	PLACETEXT_IN,0,0
		dc.w	3,97,60,15
		dc.l	naddtext,0
		dc.w	GD_ncadd
		dc.l	PLACETEXT_IN,0,0
		dc.w	156,97,60,15
		dc.l	nexittext,0
		dc.w	GD_ncok
		dc.l	PLACETEXT_IN,0,0

konwinNGads:
		dc.w	72,16-11,60,12
		dc.l	gaktxText,0
		dc.w	GD_aktx
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	72,30-11,60,12
		dc.l	gaktyText,0
		dc.w	GD_akty
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	72,44-11,60,12
		dc.l	gbrushxText,0
		dc.w	GD_brushx
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	72,58-11,60,12
		dc.l	gbrushyText,0
		dc.w	GD_brushy
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	40,90+2-11,65,12
		dc.l	gautocutText,0
		dc.w	GD_autocut
		dc.l	PLACETEXT_IN,0,0
		dc.w	10,108-11,60,12
		dc.l	gokText,0
		dc.w	GD_kok
		dc.l	PLACETEXT_IN,0,0
		dc.w	72,108-11,60,12
		dc.l	gcancelText,0
		dc.w	GD_kcancel
		dc.l	PLACETEXT_IN,0,0
		dc.w	72,72-11,40,12
		dc.l	kwordstext,0
		dc.w	GD_kwords
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	72,72+4,26,11
		dc.l	kscaletext,0
		dc.w	GD_kscale
		dc.l	PLACETEXT_LEFT,0,0
		
screenwinNGads:
		dc.w	7,13-11,306,70
		dc.l	0,0
		dc.w	GD_screenlist
		dc.l	0,0,0
		dc.w	50,90-11,70,13
		dc.l	glAcceptText,0
		dc.w	GD_sok
		dc.l	PLACETEXT_IN,0,0
		dc.w	205,90-11,70,13
		dc.l	glcancelText,0
		dc.w	GD_scancel
		dc.l	PLACETEXT_IN,0,0

ImagewinNGads:
		dc.w	78-3,15-11,61,14
		dc.l	rawwithText,0
		dc.w	GD_imagewidth
		dc.l	PLACETEXT_RIGHT,0,0
		dc.w	78-3,30-11,61,14
		dc.l	rawheightText,0
		dc.w	GD_imageheight
		dc.l	PLACETEXT_RIGHT,0,0
		dc.w	113-6-3,45-11,32,14
		dc.l	imageplanesText,0
		dc.w	GD_imagedepth
		dc.l	PLACETEXT_RIGHT,0,0
		dc.w	34-3,60-11,105,14
		dc.l	imagedisplayText,0
		dc.w	GD_imagedisplay
		dc.l	PLACETEXT_RIGHT,0,0
		dc.w	18-3,80-11,66,14
		dc.l	imagedoitText,0
		dc.w	GD_imagedoit
		dc.l	PLACETEXT_IN,0,0
		dc.w	128+3,80-11,66,14
		dc.l	imagecancelText,0
		dc.w	GD_imagecancel
		dc.l	PLACETEXT_IN,0,0

linkwinNGads:
		dc.w	15,28-11,190,14
		dc.l	extdeftext,0
		dc.w	GD_linkextdef
		dc.l	PLACETEXT_ABOVE,0,0
		dc.w	125,45-11,80,14
		dc.l	linkmemtext,0
		dc.w	GD_linkmem
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	15,65-11,66,14
		dc.l	linkoktext,0
		dc.w	GD_linkok
		dc.l	PLACETEXT_IN,0,0
		dc.w	139,65-11,66,14
		dc.l	linkcanceltext,0
		dc.w	GD_linkcancel
		dc.l	PLACETEXT_IN,0,0
				
biaswinNGads:
		dc.w	71,2,175,12
		dc.l	0,0
		dc.w	GD_color
		dc.l	0,0,0
		dc.w	71,26,175,12
		dc.l	0,0
		dc.w	GD_bright
		dc.l	0,0,0
		dc.w	71,38,175,12
		dc.l	0,0
		dc.w	GD_contrast
		dc.l	0,0,0
		dc.w	71,50,175,12
		dc.l	0,0
		dc.w	GD_red
		dc.l	0,0,0
		dc.w	71,62,175,12
		dc.l	0,0
		dc.w	GD_green
		dc.l	0,0,0
		dc.w	71,74,175,12
		dc.l	0,0
		dc.w	GD_blue
		dc.l	0,0,0
		dc.w	2,94+12,80,12
		dc.l	useText,0
		dc.w	GD_use
		dc.l	PLACETEXT_IN,0,0
		dc.w	84,94+12,80,12
		dc.l	keepText,0
		dc.w	GD_keep
		dc.l	PLACETEXT_IN,0,0
		dc.w	166,94+12,80,12
		dc.l	glCancelText,0
		dc.w	GD_cancel
		dc.l	PLACETEXT_IN,0,0
		dc.w	2,2,69,12
		dc.l	colorText,0
		dc.w	GD_colornull
		dc.l	PLACETEXT_IN,0,0
		dc.w	2,26,69,12
		dc.l	brightText,0
		dc.w	GD_brightnull
		dc.l	PLACETEXT_IN,0,0
		dc.w	2,38,69,12
		dc.l	contrasttext,0
		dc.w	GD_contrastnull
		dc.l	PLACETEXT_IN,0,0
		dc.w	2,50,69,12
		dc.l	gpcolorredText,0
		dc.w	GD_rednull
		dc.l	PLACETEXT_IN,0,0
		dc.w	2,62,69,12
		dc.l	gpcolorgreenText,0
		dc.w	GD_greennull
		dc.l	PLACETEXT_IN,0,0
		dc.w	2,74,69,12
		dc.l	gpcolorblueText,0
		dc.w	GD_bluenull
		dc.l	PLACETEXT_IN,0,0
		dc.w	90,78+12,69,12
		dc.l	zerotext,0
		dc.w	GD_zeroall
		dc.l	PLACETEXT_IN,0,0
		dc.w	71,14,175,12
		dc.l	0,0
		dc.w	GD_gamma
		dc.l	0,0,0
		dc.w	2,14,69,12
		dc.l	gpgammaText,0
		dc.w	GD_gammanull
		dc.l	PLACETEXT_IN,0,0

spritewinNgads
		dc.w	140,15-11,61,14
		dc.l	scrxtext,0
		dc.w	GD_screenx
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	140,30-11,61,14
		dc.l	scryText,0
		dc.w	GD_screeny
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	140,45-11,61,14
		dc.l	picxText,0
		dc.w	GD_picx
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	140,60-11,61,14
		dc.l	picyText,0
		dc.w	GD_picy
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	10,78-11,61,14
		dc.l	glAcceptText,0
		dc.w	GD_spok
		dc.l	PLACETEXT_IN,0,0
		dc.w	140,78-11,61,14
		dc.l	glcancelText,0
		dc.w	GD_spcancel
		dc.l	PLACETEXT_IN,0,0
		dc.w	75,78-11,61,14
		dc.l	allText,0
		dc.w	GD_spall
		dc.l	PLACETEXT_IN,0,0

labelwinNgads:
		dc.w	59-2,5,162,14
		dc.l	labelnametext,0
		dc.w	GD_labelname
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	98-2,21,30,14
		dc.l	counttext,0
		dc.w	GD_countstart
		dc.l	PLACETEXT_LEFT,0,0
		dc.w	10-2,38,61,14
		dc.l	createText,0
		dc.w	GD_create
		dc.l	PLACETEXT_IN,0,0
		dc.w	73-2,38,85,14
		dc.l	createallText,0
		dc.w	GD_createall
		dc.l	PLACETEXT_IN,0,0
		dc.w	160-2,38,61,14
		dc.l	lcancelText,0
		dc.w	GD_lcancel
		dc.l	PLACETEXT_IN,0,0

palwinNGads1:
		dc.l	0

palwinNGads2:
		dc.w	4,16,163,9
		dc.l	0,0
		dc.w	GD_pal_red
		dc.l	0,0,0
		dc.w	4,25,163,9
		dc.l	0,0
		dc.w	GD_pal_green
		dc.l	0,0,0
		dc.w	4,34,163,9
		dc.l	0,0
		dc.w	GD_pal_blue
		dc.l	0,0,0
		dc.w	4,2,57,12
		dc.l	0,0
		dc.w	GD_pal_colorsystem
		dc.l	0,0,0
		dc.w	64,2,45,12
		dc.l	pal_copyText,0
		dc.w	GD_pal_copy
		dc.l	PLACETEXT_IN,0,0
		dc.w	109,2,58,12
		dc.l	pal_spreadText,0
		dc.w	GD_pal_spread
		dc.l	PLACETEXT_IN,0,0
		dc.w	167,2,58,12
		dc.l	pal_swapText,0
		dc.w	GD_pal_swap
		dc.l	PLACETEXT_IN,0,0
		dc.w	236,2,245,12
		dc.l	0,0
		dc.w	GD_pal_rangeslider
		dc.l	0,0,0
		dc.w	299,30,39,11
		dc.l	0,0
		dc.w	GD_pal_number
		dc.l	0,0,0
		dc.w	344,29,75,13
		dc.l	pal_okText,0
		dc.w	GD_pal_ok
		dc.l	PLACETEXT_IN,0,0
		dc.w	431,29,75,13
		dc.l	pal_undoText,0
		dc.w	GD_pal_undo
		dc.l	PLACETEXT_IN,0,0
		dc.w	518,29,75,13
		dc.l	pal_resetText,0
		dc.w	GD_pal_reset
		dc.l	PLACETEXT_IN,0,0
		dc.w	344,15,75,13
		dc.l	pal_remapText,0
		dc.w	GD_pal_remap
		dc.l	PLACETEXT_IN,0,0
		dc.w	489,2,142,12
		dc.l	0,0
		dc.w	GD_Pal_rangeinfo
		dc.l	0,0,0
		dc.w	431,15,75,13
		dc.l	pal_sortText,0
		dc.w	GD_pal_sort
		dc.l	PLACETEXT_IN,0,0
		dc.w	518,15,75,13
		dc.l	pal_pickText,0
		dc.w	GD_pal_pick
		dc.l	PLACETEXT_IN,0,0

palwinNGads3:
		dc.w	6,3,120,13
		dc.l	pal_sortdarktext,0
		dc.w	GD_pal_sortdark
		dc.l	PLACETEXT_IN,0,0
		dc.w	130,3,120,13
		dc.l	pal_sortlighttext,0
		dc.w	GD_pal_sortlight
		dc.l	PLACETEXT_IN,0,0
		dc.w	254,3,120,13
		dc.l	linkcanceltext,0
		dc.w	GD_pal_sortcancel
		dc.l	PLACETEXT_IN,0,0

mainwinGTags:
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GTTX_Text
TAG_effect:	dc.l	0		;GeffectString
		dc.l	GTTX_CopyText,1
		dc.l	GTTX_Border,1
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
	;	dc.l	GA_Disabled,1
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
	;	dc.l	GA_Disabled,1
		dc.l	TAG_DONE

		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE

		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GTTX_Text,gstatusstring
		dc.l	GTTX_Border,1
		dc.l	TAG_DONE
		dc.l	GTNM_Justification,GTJ_Right
		dc.l	GTNM_Border,1
		dc.l	TAG_DONE
		dc.l	GTNM_Justification,GTJ_Right
		dc.l	GTNM_Border,1
		dc.l	TAG_DONE
		dc.l	GTNM_Justification,GTJ_Right
		dc.l	GTNM_Border,1
		dc.l	TAG_DONE
		dc.l	GTTX_Text
TAG_loadstring:	dc.l	0	;gloaderString
		dc.l	GTTX_CopyText,1
		dc.l	GTTX_Border,1
		dc.l	TAG_DONE
		dc.l	GTTX_Text
TAG_savestring:	dc.l	0	;gsaverString
		dc.l	GTTX_CopyText,1
		dc.l	GTTX_Border,1
		dc.l	TAG_DONE
		dc.l	GTTX_Text
TAG_project:	dc.l	0
		dc.l	GTTX_Border,1
		dc.l	TAG_DONE
		dc.l	GTTX_CopyText,1
		dc.l	GTTX_Border,1
		dc.l	GTTX_Text
TAG_monitor:	dc.l	0
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GTNM_Number
TAG_xsize:	dc.l	0
		dc.l	GTNM_Justification,GTJ_Right
		dc.l	GTNM_Border,1
		dc.l	TAG_DONE
		dc.l	GTNM_Number
TAG_ysize:	dc.l	0
		dc.l	GTNM_Justification,GTJ_Right
		dc.l	GTNM_Border,1
		dc.l	TAG_DONE
		dc.l	GTTX_Text
TAG_depthcolor:	dc.l	de0
		dc.l	GTTX_Border,1
		dc.l	TAG_DONE
;		dc.l	GTNM_Number
;TAG_brushsize:	dc.l	0
;		dc.l	GTNM_Justification,GTJ_Right
;		dc.l	GTNM_Border,1
;		dc.l	TAG_DONE
		dc.l	GTNM_Number
TAG_xbrush:	dc.l	0
		dc.l	GTNM_Justification,GTJ_Right
		dc.l	GTNM_Border,1
		dc.l	TAG_DONE
		dc.l	GTNM_Number
TAG_ybrush:	dc.l	0
		dc.l	GTNM_Justification,GTJ_Right
		dc.l	GTNM_Border,1
		dc.l	TAG_DONE
;		dc.l	GTTX_Text
;TAG_cutmode:	dc.l	gcutmodestring
;		dc.l	GTTX_CopyText,1
;		dc.l	GTTX_Border,1
;		dc.l	TAG_DONE
;		dc.l	GTNM_Number
;TAG_gwords:	dc.l	0
;		dc.l	GTNM_Justification,GTJ_Right
;		dc.l	GTNM_Border,1
;		dc.l	TAG_DONE
		dc.l	GTCB_Checked
TAG_check:	dc.l	0
		dc.l	GTCB_Scaled,1
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
;		dc.l	GA_Disabled,1
		dc.l	TAG_DONE
;		dc.l	GA_Disabled,1
;		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	GA_Disabled
tag_undodis:	dc.l	1
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	GA_Disabled
tag_redodis:	dc.l	1
		dc.l	TAG_DONE

newchoosewinGTags:
		dc.l	GTLV_Labels
newnodelist:	dc.l	0
		dc.l	GTLV_ShowSelected,0
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	GA_Disabled
nc_confdis:	dc.l	1		;conf gadget
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	GA_Disabled
nc_clonedis:	dc.l	1		;clone gadget
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	GA_Disabled
nc_erasedis:	dc.l	1		;erase gadget
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	GA_Disabled
nc_updis:	dc.l	1		;up gadget
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	GA_Disabled
nc_downdis:	dc.l	1		;down gadget
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GTST_MaxChars,24
		dc.l	GTST_String
newstring:	dc.l	0
		dc.l	GA_Disabled
nc_stringdis:	dc.l	1		;erase gadget
		dc.l	TAG_DONE


newmodulewinGTags:
		dc.l	GTLV_Labels
newmodulenodelist:
		dc.l	0
		dc.l	GTLV_ShowSelected,0
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE


konwinGTags:
		dc.l	GTIN_Number
TAG_aktx:	dc.l	0
	;	dc.l	GTIN_Justification,GTJ_Right
	;	dc.l	GTIN_Border,1
		dc.l	GTIN_MaxChars,5
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GTIN_Number
TAG_akty:	dc.l	0
		dc.l	GTIN_MaxChars,5
	;	dc.l	GTIN_Justification,GTJ_Right
	;	dc.l	GTIN_Border,1
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GTIN_Number
TAG_brushx:	dc.l	0
		dc.l	GTIN_MaxChars,5
	;	dc.l	GTIN_Justification,GTJ_Right
	;	dc.l	GTIN_Border,1
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GTIN_Number
TAG_brushy:	dc.l	0
		dc.l	GTIN_MaxChars,5
	;	dc.l	GTIN_Justification,GTJ_Right
	;	dc.l	GTIN_Border,1
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GTIN_Number
TAG_kwords:	dc.l	0
		dc.l	GTIN_MaxChars,5
	;	dc.l	GTNM_Justification,GTJ_Right
	;	dc.l	GTNM_Border,1
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GTCB_Scaled,1
		dc.l	GT_Underscore,'_'
		dc.l	GTCB_Checked
TAG_kscale:	dc.l	0
		dc.l	TAG_DONE

screenwinGtags:
		dc.l	GTLV_Labels,screenreqlist
		dc.l	GTLV_ShowSelected,0
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE

imagewinGTags:
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
		dc.l	GTIN_Number
rdepth:		dc.l	0
		dc.l	GTIN_MaxChars,1
		dc.l	STRINGA_Justification,GACT_STRINGRIGHT
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,imagedisplayLabels
		dc.l	GTCY_ACTIVE
rdispl:		dc.l	0
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE

linkwinGTags:
		dc.l	GTST_MaxChars,24
		dc.l	GTST_String
extstring:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,linkwinLabels
		dc.l	GTCY_ACTIVE
limem:		dc.l	0
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE

biaswinGtags:
		dc.l	PGA_Freedom,LORIENT_HORIZ
		dc.l	GA_RelVerify,1
		dc.l	GA_Immediate,1
		dc.l	GTSL_LevelPlace,PlaceText_Right
		dc.l	GTSL_LevelFormat,Lformatbias
		dc.l	GTSL_MaxLevelLen,5
		dc.l	GTSL_Min,-100
		dc.l	GTSL_Max,100
		dc.l	TAG_DONE
		dc.l	PGA_Freedom,LORIENT_HORIZ
		dc.l	GA_RelVerify,1
		dc.l	GA_Immediate,1
		dc.l	GTSL_LevelPlace,PlaceText_Right
		dc.l	GTSL_LevelFormat,Lformatbias
		dc.l	GTSL_MaxLevelLen,5
		dc.l	GTSL_Min,-100
		dc.l	GTSL_Max,100
		dc.l	TAG_DONE
		dc.l	PGA_Freedom,LORIENT_HORIZ
		dc.l	GA_RelVerify,1
		dc.l	GA_Immediate,1
		dc.l	GTSL_LevelPlace,PlaceText_Right
		dc.l	GTSL_LevelFormat,Lformatbias
		dc.l	GTSL_MaxLevelLen,5
		dc.l	GTSL_Min,-100
		dc.l	GTSL_Max,100
		dc.l	TAG_DONE
		dc.l	PGA_Freedom,LORIENT_HORIZ
		dc.l	GA_RelVerify,1
		dc.l	GA_Immediate,1
		dc.l	GTSL_LevelPlace,PlaceText_Right
		dc.l	GTSL_LevelFormat,Lformatbias
		dc.l	GTSL_MaxLevelLen,5
		dc.l	GTSL_Min,-100
		dc.l	GTSL_Max,100
		dc.l	TAG_DONE
		dc.l	PGA_Freedom,LORIENT_HORIZ
		dc.l	GA_RelVerify,1
		dc.l	GA_Immediate,1
		dc.l	GTSL_LevelPlace,PlaceText_Right
		dc.l	GTSL_LevelFormat,Lformatbias
		dc.l	GTSL_MaxLevelLen,5
		dc.l	GTSL_Min,-100
		dc.l	GTSL_Max,100
		dc.l	TAG_DONE
		dc.l	PGA_Freedom,LORIENT_HORIZ
		dc.l	GA_RelVerify,1
		dc.l	GA_Immediate,1
		dc.l	GTSL_LevelPlace,PlaceText_Right
		dc.l	GTSL_LevelFormat,Lformatbias
		dc.l	GTSL_MaxLevelLen,5
		dc.l	GTSL_Min,-100
		dc.l	GTSL_Max,100
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	PGA_Freedom,LORIENT_HORIZ
		dc.l	GA_RelVerify,1
		dc.l	GA_Immediate,1
		dc.l	GTSL_LevelPlace,PlaceText_Right
		dc.l	GTSL_LevelFormat,Lformatbias
		dc.l	GTSL_MaxLevelLen,5
		dc.l	GTSL_Min,-100
		dc.l	GTSL_Max,100
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE


spritewinGtags:
		dc.l	GTIN_Number
scrx:		dc.l	0
		dc.l	GTIN_MaxChars,10
		dc.l	STRINGA_Justification,GACT_STRINGRIGHT
	;	dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GTIN_Number
scry:		dc.l	0
		dc.l	GTIN_MaxChars,10
		dc.l	STRINGA_Justification,GACT_STRINGRIGHT
	;	dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GTIN_Number
picx:		dc.l	0
		dc.l	GTIN_MaxChars,10
		dc.l	STRINGA_Justification,GACT_STRINGRIGHT
	;	dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GTIN_Number
picy:		dc.l	0
		dc.l	GTIN_MaxChars,10
		dc.l	STRINGA_Justification,GACT_STRINGRIGHT
	;	dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE

labelwinGtags:
		dc.l	GTST_MaxChars,50
		dc.l	GTST_String
labelstr:	dc.l	labelpuffer
		dc.l	TAG_DONE
		dc.l	GTIN_Number
countst:	dc.l	1
		dc.l	GTIN_MaxChars,2
		dc.l	STRINGA_Justification,GACT_STRINGRIGHT
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE

palwinGtags1:	
		dc.l	TAG_DONE

palwinGtags2:	
		dc.l	PGA_Freedom,LORIENT_HORIZ
		dc.l	GA_RelVerify,1
		dc.l	GA_Immediate,1
		dc.l	GTSL_LevelFormat,pal_formatR
		dc.l	GTSL_LevelPlace,PlaceText_Right
		dc.l	GTSL_MaxLevelLen,5
		dc.l	GTSL_Min,0
		dc.l	GTSL_Max,255
		dc.l	TAG_DONE
		dc.l	PGA_Freedom,LORIENT_HORIZ
		dc.l	GA_RelVerify,1
		dc.l	GA_Immediate,1
		dc.l	GTSL_LevelFormat,pal_formatG
		dc.l	GTSL_LevelPlace,PlaceText_Right
		dc.l	GTSL_MaxLevelLen,5
		dc.l	GTSL_Min,0
		dc.l	GTSL_Max,255
		dc.l	TAG_DONE
		dc.l	PGA_Freedom,LORIENT_HORIZ
		dc.l	GA_RelVerify,1
		dc.l	GA_Immediate,1
		dc.l	GTSL_LevelFormat,pal_formatB
		dc.l	GTSL_LevelPlace,PlaceText_Right
		dc.l	GTSL_MaxLevelLen,5
		dc.l	GTSL_Min,0
		dc.l	GTSL_Max,255
		dc.l	TAG_DONE
		dc.l	GTCY_Labels,pal_colorsystemLabels
GA_colorsys:	dc.l	GTCY_ACTIVE
TAG_colorsys:	dc.l	0
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	PGA_Freedom,LORIENT_HORIZ
		dc.l	GA_RelVerify,1
		dc.l	GA_Immediate,1
		dc.l	GTSC_Arrows,15
;		dc.l	GTSL_Min,0
;		dc.l	GTSL_Max,0
		dc.l	GTSC_Total,0
		dc.l	GTSC_Visible,0
		dc.l	TAG_DONE
		dc.l	GTNM_Number,0
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GTTX_Border,1
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		
palwinGtags3:	
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE
		dc.l	GT_Underscore,'_'
		dc.l	TAG_DONE

Lformat:		dc.b	'%ld% ',0
Lformatbias:		dc.b	'%ld%%% ',0
gloadText:		dc.b	'_Load',0
gsaveText:		dc.b	'_Save',0
gexitText:		dc.b	'E_xit',0
gaboutText:		dc.b	'_About',0
giconifyText:		dc.b	'_Iconify',0
gcutbrushText:		dc.b	'Sele_ct Brush',0
gviewpicText:		dc.b	'_Render/Display',0
grenderText:		dc.b	'Ren_der Ctrl',0
glockmontext:		dc.b	'L',0
gexecuteoperatorText:	dc.b	'_Execute',0
gexecutepaletteText:	dc.b	'Pale_tte',0
gcolorbiastext:		dc.b	'Color_Bias',0
gcolorsText:		dc.b	'2',0
gpreferencesText:	dc.b	'Settin_gs',0
gstatustext:		dc.b	'Status',0
gmemoryText:		dc.b	'Memory',0
gchiptext:		dc.b	'Chip',0
gfasttext:		dc.b	'Fast',0
gprojectText:		dc.b	'Project',0
gmonitorText:		dc.b	'_Mode',0
gxsizeText:		dc.b	'Size',0
gysizeText:		dc.b	'x',0
gdepthText:		dc.b	'x',0
gybrushText:		dc.b	'x',0
gwordstext:		dc.b	'Words',0
gbsizeText:		dc.b	'Bytes',0
gleartext:		dc.b	'Clear',0
selecttext1:		dc.b	'_1',0
selecttext2:		dc.b	'_2',0
selecttext3:		dc.b	'_3',0
selecttext:		dc.b	'_4',0
gundoText:		dc.b	'Undo',0
gredoText:		dc.b	'Redo',0

gstatusstring:		dc.b	'Welcome to ArtPRO !',0
geffectstring:		dc.b	'Pack Colors',0

gloaderstring:		dc.b	'IFF-ILBM',0
gsaverstring:		dc.b	'RAW',0
gcutmodestring:		dc.b	'Normal Cut',0

glAcceptandLoadText:	dc.b	'Accept and Opera_te',0
glAcceptText:		dc.b	'_Ok',0
glCancelText:		dc.b	'_Cancel',0

nconfigtext:		dc.b	'Confi_g',0
naddtext:		dc.b	'_Add',0
nclonetext:		dc.b	'Clo_ne',0
nerasetext:		dc.b	'_Erase',0
nuptext:		dc.b	'_Up',0
ndowntext:		dc.b	'_Down',0
nloadtext:		dc.b	'_Load',0
nsavetext:		dc.b	'_Save',0
ninfotext:		dc.b	'_Info',0

nexittext:		dc.b	'E_xit',0

gacceotandviewText:	dc.b	'Accept and _View',0
gcccancelText:		dc.b	'_Cancel',0
gccacceptText:		dc.b	'_Ok',0

gpcolorredText:		dc.b	'Red',0
gpcolorgreenText:	dc.b	'Green',0
gpcolorblueText:	dc.b	'Blue',0

gaktxText:		dc.b	'_XOffset',0
gaktyText:		dc.b	'_YOffset',0
gbrushxText:		dc.b	'_Width',0
gbrushytext:		dc.b	'_Height',0
gautocutText:		dc.b	'A_utoCut',0
gokText:		dc.b	'_Accept',0
gcancelText:		dc.b	'_Cancel',0
kwordstext:		dc.b	'Wo_rds',0
kscaletext:		dc.b	'Scale_d',0

rawwithText:		dc.b	'_Width',0
rawheightText:		dc.b	'_Height',0
imageplanesText:	dc.b	'_Planes',0
imagedisplayText:	dc.b	'D_isplay',0
imagedoitText:		dc.b	'_Do it',0
imagecancelText:	dc.b	'_Cancel',0

extdeftext:		dc.b	'External definition',0
linkmemtext:		dc.b	'Memory _type',0
linkoktext:		dc.b	'_Do it',0
linkcanceltext:		dc.b	'_Cancel',0

colorText:		dc.b	'Color',0
brightText:		dc.b	'Bright',0
contrasttext:		dc.b	'Contrast',0
keepText:		dc.b	'_Keep',0
usetext:		dc.b	'_Use',0
zerotext:		dc.b	'_Zero',0
gpgammaText:		dc.b	'Gamma',0

	even
scrxtext:		dc.b	'DMA X-Offset',0
scrytext:		dc.b	'DMA Y-Offset',0
picxtext:		dc.b	'Image X-Offset',0
picytext:		dc.b	'Image Y-Offset',0
alltext:		dc.b	'_All',0

labelnametext:		dc.b	'Label',0
counttext:		dc.b	'CountStart',0
createText:		dc.b	'_Create',0
createalltext:		dc.b	'Create _all',0
lcanceltext:		dc.b	'Ca_ncel',0

pal_copyText:		dc.b	'_Copy',0
pal_spreadText:		dc.b	'_Spread',0
pal_swapText:		dc.b	'S_wap',0
pal_okText:		dc.b	'_Ok',0
pal_undoText:		dc.b	'_Undo',0
pal_resetText:		dc.b	'_Reset',0
pal_remapText:		dc.b	'Rema_p',0
pal_formatR:		dc.b	'R:%ld%',0
pal_formatG:		dc.b	'G:%ld%',0
pal_formatB:		dc.b	'B:%ld%',0
pal_sortText:		dc.b	'Sor_t',0
pal_pickText:		dc.b	'P_ick',0
pal_sortdarktext:	dc.b	'_Dark to Light',0
pal_sortlighttext:	dc.b	'_Light to Dark',0

		even
imagedisplayLabels:
			dc.l	imagedisplayLab0
			dc.l	imagedisplayLab1
			dc.l	imagedisplayLab2
			dc.l	0

imagedisplayLab0:	dc.b	'Normal',0
imagedisplayLab1:	dc.b	'Halfbrite',0
imagedisplayLab2:	dc.b	'HAM',0

    		even

gpiconifymodeLabels:
		dc.l	gpiconifymodeLab0
		dc.l	gpiconifymodeLab1
		dc.l	gpiconifymodeLab2
		dc.l	0

gpspurceformatLabels:
		dc.l	gpspurceformatLab0
		dc.l	gpspurceformatLab1
		dc.l	0

;gpspriteformLabels:
;		dc.l	gpspriteformLab0
;		dc.l	gpspriteformLab1
;		dc.l	0

gpcolorformatLabels:
		dc.l	gpcolorformatLab0
		dc.l	gpcolorformatLab1
		dc.l	gpcolorformatLab2
		dc.l	0

gpaddwordLabels:
		dc.l	gpaddwordLab0
		dc.l	gpaddwordLab1
		dc.l	gpaddwordLab2
		dc.l	0

gpsriteLabels:
		dc.l	gpsriteLab0
		dc.l	gpsriteLab1
		dc.l	0

gpspritewidthLabels:
		dc.l	gpspritewidthLab0
		dc.l	gpspritewidthLab1
		dc.l	gpspritewidthLab2
		dc.l	0

gpdataslenghtLabels:
		dc.l	gpdataslenghtLab0
		dc.l	gpdataslenghtLab1
		dc.l	gpdataslenghtLab2
		dc.l	0
				
gpcolordataformatLabels:
		dc.l	gpcolordataformatLab0
		dc.l	gpcolordataformatLab1
		dc.l	gpcolordataformatLab2
		dc.l	gpcolordataformatLab3
		dc.l	gpcolordataformatLab4
		dc.l	0

goutputlabels:
		dc.l	goutputLab0
		dc.l	goutputLab1
		dc.l	goutputLab2
		dc.l	0
		
gpcoloroutLabels:
		dc.l	gcoloroutLab0
		dc.l	gcoloroutLab1
		dc.l	gcoloroutLab2
		dc.l	gcoloroutLab3
		dc.l	0		

gpcolordepthLabels:
		dc.l	gcolordepthLab0
		dc.l	gcolordepthLab1
		dc.l	0
		
gspriteoutLabels:
		dc.l	goutputLab0
		dc.l	goutputLab1
		dc.l	goutputLab2
		dc.l	0

gcontrolLabels:
		dc.l	controlLab0
		dc.l	controlLab1
		dc.l	controlLab2
		dc.l	controlLab3
		dc.l	0
		
linkwinLabels:
		dc.l	linkmemlab0
		dc.l	linkmemlab1
		dc.l	linkmemlab2
		dc.l	0

gplabelLabels:
		dc.l	labelLab0
		dc.l	labelLab1
		dc.l	labelLab2
		dc.l	0

gpscreenLabels:
		dc.l	screenLab0
		dc.l	screenLab1
		dc.l	screenLab2
		dc.l	0

pal_colorsystemLabels:
		dc.l	pal_colorsystemLab0
		dc.l	pal_colorsystemLab1
		dc.l	pal_colorsystemLab2
		dc.l	pal_colorsystemLab3
		dc.l	pal_colorsystemLab4
		dc.l	0

gpiconifymodeLab0:	dc.b	'Window',0
gpiconifymodeLab1:	dc.b	'App Icon',0
gpiconifymodeLab2:	dc.b	'App Item',0

gpspurceformatLab0:	dc.b	'Tab',0
gpspurceformatLab1:	dc.b	'Spc',0

;gpspriteformLab0:	dc.b	'Asm-Source',0
;gpspriteformLab1:	dc.b	'Pure data',0

gpcolorformatLab0:	dc.b	'Copper',0
gpcolorformatLab1:	dc.b	'LoadRGB',0
gpcolorformatLab2:	dc.b	'Pure',0

gpaddwordLab0:		dc.b	'None',0
gpaddwordLab1:		dc.b	'Left',0
gpaddwordLab2:		dc.b	'Right',0


gpsriteLab0:		dc.b	'4',0
gpsriteLab1:		dc.b	'16',0

gpspritewidthLab0:	dc.b	'16',0
gpspritewidthLab1:	dc.b	'32',0
gpspritewidthLab2:	dc.b	'64',0

goutputLab0:		dc.b	'Source',0
goutputLab1:		dc.b	'Binary',0
goutputLab2:		dc.b	'Link',0

gpdataslenghtLab0:	dc.b	'Bytes',0
gpdataslenghtLab1:	dc.b	'Words',0
gpdataslenghtLab2:	dc.b	'Longs',0

gpcolordataformatLab0:	dc.b	'Assembler',0
gpcolordataformatLab1:	dc.b	'C',0
gpcolordataformatLab2:	dc.b	'Pascal',0			
gpcolordataformatLab3:	dc.b	'E',0
gpcolordataformatLab4:	dc.b	'Basic',0

gcoloroutLab0:		dc.b	'Source',0
gcoloroutLab1:		dc.b	'Binary',0
gcoloroutLab2:		dc.b	'Link',0
gcoloroutLab3:		dc.b	'IFF',0

gcolordepthLab0:	dc.b	'4 Bit',0
gcolordepthLab1:	dc.b	'8 Bit',0

controlLab0:		dc.b	'None',0
controlLab1:		dc.b	'Empty',0
controlLab2:		dc.b	'Auto',0
controlLab3:		dc.b	'Prompt',0

linkmemlab0:		dc.b	'Any',0
linkmemlab1:		dc.b	'Chip',0
linkmemlab2:		dc.b	'Fast',0

labelLab0:		dc.b	'None',0
labelLab1:		dc.b	'Auto',0
labelLab2:		dc.b	'Prompt',0

screenLab0:		dc.b	'Workbench',0
screenLab1:		dc.b	'PublicScreen',0
screenLab2:		dc.b	'CustomScreen',0

pal_colorsystemLab0:	dc.b	'RGB',0
pal_colorsystemLab1:	dc.b	'CMY',0
pal_colorsystemLab2:	dc.b	'HSV',0
pal_colorsystemLab3:	dc.b	'YUV',0
pal_colorsystemLab4:	dc.b	'YIQ',0
	
    		even

topaz8:
		dc.l	topazFName8
		dc.w	8
		dc.b	$00,$01

topazFName8:
		dc.b	'topaz.font',0

		even

mainwinWindowTags:
mainwinL:	dc.l	WA_Left,0
mainwinT:	dc.l	WA_Top,0
mainwinW:	dc.l	WA_Width,0
mainwinH:	dc.l	WA_Height,0
		dc.l	WA_IDCMP,IDCMP_NewSize!closewindow!RAWKEY!IDCMP_VANILLAKEY!BUTTONIDCMP!INTEGERIDCMP!CYCLEIDCMP!IDCMP_CLOSEWINDOW!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_DEPTHGADGET!WFLG_ACTIVATE!WFLG_CLOSEGADGET!WFLG_DRAGBAR!WFLG_SMART_REFRESH!WFLG_ACTIVATE!WFLG_RMBTRAP
mainwinWG:	dc.l	WA_Gadgets,0
		dc.l	WA_ScreenTitle,mainwinSTitle
		dc.l	WA_Title,mainwinSTitle
mainwinSC:	dc.l	WA_CustomScreen,0
		dc.l	WA_Zoom,mainzoomlist
		dc.l	TAG_DONE

mainzoomlist:	dc.w	0,0,200
zoomheight:	dc.w	0

mainwinWTitle:
		dc.b	0
  	even

mainwinSTitle:
sct:
		dc.b	'ArtPRO '
		version
		dc.b	' © 1994/98, Frank Pagels / Defect Softworks',0
    	even

choosewinWindowTags:
choosewinL:	dc.l	WA_Left,0
choosewinT:	dc.l	WA_Top,80
choosewinW:	dc.l	WA_Width,274
choosewinH:	dc.l	WA_Height,148
		dc.l	WA_IDCMP,RAWKEY!LISTVIEWIDCMP!IDCMP_VANILLAKEY!BUTTONIDCMP!IDCMP_CLOSEWINDOW!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_DEPTHGADGET!WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_CLOSEGADGET!WFLG_SMART_REFRESH
choosewinWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title
wintitle:	dc.l	chooseloader
		dc.l	WA_ScreenTitle,mainwinstitle  ;choosewinSTitle
choosewinSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

chooseloader:	dc.b    'Choose Loader',0
choosesaver:	dc.b    'Choose Saver',0
	even

imagewinWindowTags:
imagewinL:	dc.l	WA_Left,212
imagewinT:	dc.l	WA_Top,78
imagewinW:	dc.l	WA_Width,216
imagewinH:	dc.l	WA_Height,100
		dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW!VANILLAKEY!INTEGERIDCMP!CYCLEIDCMP!BUTTONIDCMP!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_CLOSEGADGET!WFLG_DEPTHGADGET!WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_SMART_REFRESH!WFLG_RMBTRAP
imagewinWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title,imagewinWTitle
		dc.l	WA_ScreenTitle,MainwinStitle
ImagewinSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

imagewinWTitle:	dc.b	'Image Dimensions',0

    	even

linkwinWindowTags:
linkwinL:	dc.l	WA_Left,212
linkwinT:	dc.l	WA_Top,78
linkwinW:	dc.l	WA_Width,220
linkwinH:	dc.l	WA_Height,85
		dc.l	WA_IDCMP,VANILLAKEY!INTEGERIDCMP!CYCLEIDCMP!BUTTONIDCMP!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_DEPTHGADGET!WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_SMART_REFRESH!WFLG_RMBTRAP
linkwinWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title,linkwinWTitle
		dc.l	WA_ScreenTitle,MainwinStitle
linkwinSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

linkwinWTitle:	dc.b	'Specify linkdata',0

    		even

mainwinText0:
		dc.b	2,0
		dc.b	RP_JAM1
		dc.b	0
		dc.w	200,10
		dc.l	topaz8
		dc.l	mainwinIText0
		dc.l	0

mainwinText1:
		dc.b	2,0
		dc.b	RP_JAM1
		dc.b	0
		dc.w	160,90
		dc.l	topaz8
		dc.l	mainwinIText1
		dc.l	0

mainwinText2:
		dc.b	2,0
		dc.b	RP_JAM1
		dc.b	0
		dc.w	475,90
		dc.l	topaz8
		dc.l	mainwinIText2
		dc.l	0

mainwinText3:
		dc.b	2,0
		dc.b	RP_JAM1
		dc.b	0
		dc.w	160,168
		dc.l	topaz8
		dc.l	mainwinIText3
		dc.l	0

mainwinText4:
		dc.b	2,0
		dc.b	RP_JAM1
		dc.b	0
		dc.w	475,168
		dc.l	topaz8
		dc.l	mainwinIText4
		dc.l	0

mainwinText5:
		dc.b	2,0
		dc.b	RP_JAM1
		dc.b	0
		dc.w	475,208+6
		dc.l	topaz8
		dc.l	mainwinIText5
		dc.l	0

mainwinText6:
		dc.b	1,0
		dc.b	RP_JAM1
		dc.b	0
		dc.w	240-48,209
		dc.l	topaz8
		dc.l	mainwinIText6
		dc.l	0


Project0_TNUM EQU 7

mainwinIText0:	dc.b	'Main Control Panel',0
mainwinIText1:	dc.b	'File Operation',0
mainwinIText2:	dc.b	'Image Control',0
mainwinIText3:	dc.b	'Brush Operation',0
mainwinIText4:	dc.b	'Image Operation',0
mainwinIText5:	dc.b	'Palette Operation',0
mainwinIText6:	dc.b	'Dimension',0

    		even

DriPen:
    DC.W    0,1,1,2,1,3,1,0,2,1,2,1,$FFFF
		dc.w	$FFFF

;SCT:
;    dc.b    'ARTScreen',0
    		even

;***************************************************************************
;*--------------------- Struckturen für Viewwindow ------------------------*
;***************************************************************************

VisualInfo1:	dc.l    0
TD1:		dc.l    TAG_DONE
ViewLeft:	dc.w    0
ViewTop:	dc.w    0
ViewWidth:	dc.w    0
ViewHeight:	dc.w    0

ViewWindowTags:
ViewL:		dc.l    WA_Left,0
ViewT:		dc.l    WA_Top,0
ViewW:		dc.l    WA_Width,0
ViewH:		dc.l    WA_Height,0
		dc.l	WA_IDCMP,IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_REFRESHWINDOW!IDCMP_MOUSEMOVE!IDCMP_Mousebuttons
	 	dc.l	WA_Flags,WFLG_REPORTMOUSE!WFLG_SIMPLE_REFRESH!WFLG_BORDERLESS!WFLG_RMBTRAP!WFLG_ACTIVATE
ViewSC:				
		dc.l    WA_CustomScreen,0
		dc.l    TAG_DONE


ScreenTags1:
		dc.l    SA_Left
sleft:		dc.l	0
		dc.l    SA_Top
stop:		dc.l	0
		dc.l    SA_Width
swidth:		dc.l	0
		dc.l    SA_Height
sheight:	dc.l	0
		dc.l    SA_Depth
sdepth:		dc.l	0
		dc.l    SA_Font,topaz8
		dc.l    SA_Type,CUSTOMSCREEN
		dc.l	SA_Behind,SCREENBEHIND
		dc.l    SA_DisplayID
stype		dc.l	0
		dc.l    SA_Overscan,OSCAN_STANDARD
		dc.l    SA_Pens,DriPen
		dc.l    SA_AutoScroll,1
		dc.l    TAG_DONE,0

;***************************************************************************
;*--------------------- Struckturen für Kontrollscreen --------------------*
;***************************************************************************

konwinWindowTags:
konwinL:	dc.l	WA_Left,0
konwinT:	dc.l	WA_Top,0
konwinW:	dc.l	WA_Width,140
konwinH:	dc.l	WA_Height,125+16
	dc.l	WA_IDCMP,IDCMP_NewSize!IDCMP_CLOSEWINDOW!IDCMP_MOUSEMOVE!IDCMP_Mousebuttons!INTEGERIDCMP!IDCMP_VANILLAKEY!BUTTONIDCMP!IDCMP_REFRESHWINDOW!IDCMP_RAWKEY
	dc.l	WA_Flags,WFLG_SMART_REFRESH!WFLG_DRAGBAR!WFLG_CLOSEGADGET!WFLG_DEPTHGADGET
konwinWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title,cutwinWTitle
;		dc.l	WA_ScreenTitle,MainwinStitle
konwinSC:	dc.l	WA_CustomScreen,0
		dc.l	WA_Zoom,biaszoomlist
		dc.l	TAG_DONE

cutzoomlist:	dc.w	0,0,200
cutzoomheight:	dc.w	0

cutwinWTitle:	dc.b	'Cut',0
		even

;***************************************************************************
;*------------------- Struckturen für Color-BiasScreen --------------------*
;***************************************************************************

VisualInfo3:	dc.l    0
TD3:		dc.l    TAG_DONE

biaswinWindowTags:
biaswinL:	dc.l	WA_Left,0
biaswinT:	dc.l	WA_Top,0
biaswinW:	dc.l	WA_Width,0
biaswinH:	dc.l	WA_Height,0
		dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW!IDCMP_NewSize!SLIDERIDCMP!IDCMP_MOUSEMOVE!IDCMP_VANILLAKEY!IDCMP_REFRESHWINDOW!IDCMP_MouseButtons
		dc.l	WA_Flags,WFLG_SMART_REFRESH!WFLG_RMBTRAP!WFLG_DRAGBAR!WFLG_DEPTHGADGET!WFLG_CLOSEGADGET
biaswinWG:	dc.l	WA_Gadgets,0
		dc.l	WA_Title,BiasWTitle
;		dc.l	WA_ScreenTitle,MainwinStitle
biaswinSC:	dc.l	WA_CustomScreen,0
		dc.l	WA_Zoom,biaszoomlist
		dc.l	TAG_DONE

biaszoomlist:	dc.w	0,0,200
biaszoomheight:	dc.w	0

BiasWTitle:	dc.b	'Colorbias',0

	even
ScreenTags3:
		dc.l    SA_Left,0
		dc.l    SA_Top
btop:		dc.l	0
		dc.l    SA_Width,640
		dc.l    SA_Height,33
		dc.l    SA_Depth
bdepth:		dc.l	2
		dc.l    SA_Font,topaz8
		dc.l    SA_Type,CUSTOMSCREEN
		dc.l	SA_Behind,SCREENBEHIND
		dc.l    SA_DisplayID
btype:		dc.l	HIRES_KEY
		dc.l    SA_Overscan,OSCAN_STANDARD
		dc.l    SA_AutoScroll,1
		dc.l    SA_Pens
bdripens:	dc.l	DriPen
		dc.l    TAG_DONE

;***************************************************************************
;*------------------- Struckturen für Palette-Screen ----------------------*
;***************************************************************************
VisualInfo4:	dc.l    0
TD4:		dc.l    TAG_DONE

palwinWindowTags:
palwinL:	dc.l	WA_Left,0
palwinT:	dc.l	WA_Top,0
palwinW:	dc.l	WA_Width,320-1
palwinH:	dc.l	WA_Height,15
		dc.l	WA_IDCMP,IDCMP_Mousebuttons!IDCMP_MOUSEMOVE!IDCMP_VANILLAKEY!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_SMART_REFRESH!WFLG_RMBTRAP!WFLG_BORDERLESS
palwinWG:	dc.l	WA_Gadgets,0
palwinSC:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE


ScreenTags4:
		dc.l    SA_Left,0
		dc.l    SA_Top
ptop:		dc.l	0
		dc.l    SA_Width,320-1
		dc.l    SA_Height,15
		dc.l    SA_Depth
pdepth:		dc.l	5
		dc.l    SA_Font,topaz8
		dc.l    SA_Type,CUSTOMSCREEN
;		dc.l	SA_Behind,SCREENBEHIND
		dc.l    SA_DisplayID
ptype:		dc.l	0
		dc.l    SA_Overscan,OSCAN_STANDARD
		dc.l    SA_Pens,DriPen
		dc.l    SA_AutoScroll,1
		dc.l    TAG_DONE

VisualInfo5:	dc.l    0
TD5:		dc.l    TAG_DONE

palwinWindowTags1:
palwinL1:	dc.l	WA_Left,0
palwinT1:	dc.l	WA_Top,0
palwinW1:	dc.l	WA_Width,640
palwinH1:	dc.l	WA_Height,44
		dc.l	WA_IDCMP,IDCMP_MouseButtons!SCROLLERIDCMP!ARROWIDCMP!CYCLEIDCMP!IDCMP_MOUSEMOVE!IDCMP_VANILLAKEY!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_BACKDROP!WFLG_SMART_REFRESH!WFLG_RMBTRAP!WFLG_BORDERLESS
palwinWG1:	dc.l	WA_Gadgets,0
palwinSC1:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE

ScreenTags5:
		dc.l    SA_Left,0
		dc.l    SA_Top
ptop1:		dc.l	0
		dc.l    SA_Width,640
		dc.l    SA_Height,44
		dc.l    SA_Depth,3
		dc.l    SA_Font,topaz8
		dc.l    SA_Type,CUSTOMSCREEN
;		dc.l	SA_Behind,SCREENBEHIND
		dc.l    SA_DisplayID
ptype1:		dc.l	0
		dc.l    SA_Overscan,OSCAN_STANDARD
		dc.l    SA_Pens,DriPen
		dc.l    SA_AutoScroll,1
		dc.l	SA_Sharepens,1
		dc.l	SA_LikeWorkbench,1
		dc.l	SA_ShowTitle,0
		dc.l    TAG_DONE

palsortwintags:
palwinL2:	dc.l	WA_Left,130
palwinT2:	dc.l	WA_Top,5
palwinW2:	dc.l	WA_Width,380
palwinH2:	dc.l	WA_Height,19
		dc.l	WA_IDCMP,GADGETUP!IDCMP_VANILLAKEY!IDCMP_REFRESHWINDOW
		dc.l	WA_Flags,WFLG_Activate!WFLG_SMART_REFRESH!WFLG_RMBTRAP   ;!WFLG_BORDERLESS
palwinWG2:	dc.l	WA_Gadgets,0
palwinSC2:	dc.l	WA_CustomScreen,0
		dc.l	TAG_DONE


endprog:

proglen = endprog-start


dummy:		rts

;---------------------------------------------------------------------------
;--- ArtPRO public routines ------------------------------------------------
;---------------------------------------------------------------------------
jmp_begin:
		jmp	Save2TMP
		jmp	gettag
		jmp	setpicsizegads
		jmp	selectbrush
		jmp	SetComment
		jmp	RGBDiversity24
		jmp	initpicmap
		jmp	CalcNewKoor
		jmp	makepreview
		jmp	dummy
		jmp	GetViewSize
		jmp	GetAktNode
		jmp	makergbdatas
		jmp	CloseVisualScreen
		jmp	OpenVisualScreen
		jmp	render
		jmp	autoload
		jmp	drawframe
		jmp	initrendermem
		jmp	clearprocess
		jmp	doprocess
		jmp	initprocess
		jmp	openprocess

jmp_sizeof	= *-jmp_begin

;***************************************************************************
;*** Daten in BSS-Section **************************************************
;***************************************************************************



		section	daten,BSS
jmp_tab:
		ds.b	jmp_sizeof

	rsreset
daten:

;--- System ---

gfxbase:	rs.l	1
dosbase:	rs.l	1
reqtbase:	rs.l	1
intbase:	rs.l	1
gadbase:	rs.l	1
mathbase:	rs.l	1
DTBase:		rs.l	1
diskbase:	rs.l	1

filehandle:	rs.l	1
picmem:		rs.l	1

breite:		rs.w	1
hoehe:		rs.w	1
planes:		rs.b	1
testbyte:	rs.b	1
crunchmode:	rs.b	1
leer:		rs.b	1
loadflag:	rs.w	1	;wurde was geladen ?

viewmode:	rs.l	1
bytebreite:	rs.l	1
oneplanesize:	rs.l	1
anzcolor:	rs.w	1		;anzahl der Farben
picmap:		rs.b	8+4*10

ReqTPuffer:

colorreq:	rs.l	1
fontreq:	rs.l	1
scrmodereq:	rs.l	1
scrmodereqprefs:rs.l	1
struckAdr	rs.l	1
struckAdr1	rs.l	1
struckAdr2	rs.l	1
dirname:	rs.l	1
filelenght:	rs.l	1
FileName:	rs.b	108
loadname:	rs.b	200
Sdirname:	rs.l	1
Sfilelenght:	rs.l	1
SFileName:	rs.b	108
savename:	rs.b	200

farbtab4:	rs.w	260
farbtab8:	rs.l	257*3

size:		rs.l	1	;Länge eines File

;--- Flags ---

ecs:		rs.b	1
aga:		rs.b	1
merk1:		rs.b	1	;merkzellen
merk2:		rs.b	1
_PAL:		rs.b	1
_NTSC:		rs.b	1
VGA:		rs.b	1
EURO72:		rs.b	1
EURO36:		rs.b	1
SUPER72:	rs.b	1
DBLPAL:		rs.b	1
DBLNTSC:	rs.b	1
UNKNOW:		rs.b	1
endmerk		rs.b	1
planemerk:	rs.b	1	;merke aktuelle Plane Nummer
saveasblitt:	rs.b	1
saveasmask:	rs.b	1
maskblitt	rs.b	1	;Save Maske interleaved
kick3:		rs.b	1
konok:		rs.b	1
agacolors:	rs.b	1	;Palette muß für AGA geschrieben werden
colortype	rs.b	1	;Format der Color 0=old <>0 new
ham:		rs.b	1
ham8:		rs.b	1
ehb:		rs.b	1
availdatatype:	rs.b	1
checkgetfile:	rs.b	1
		rs.b	1

DisplayID:	rs.l	1	;Screenmode
PicModeID:	rs.l	1	;Screenmode

free1:		rs.l	1
free2:		rs.l	1
free3:		rs.l	1
free4:		rs.l	1

rtrequestsTags:	rs.l	1
statusrout:	rs.l	1
filesizerout:	rs.l	1
TurboCopyMemrout:	rs.l	1
checkmonirout:	rs.l	1
findmonitorrout:rs.l	1

cutflag:	rs.w	1
xbrush1:	rs.w	1
ybrush1:	rs.w	1
xbrush2:	rs.w	1
ybrush2:	rs.w	1
brushword:	rs.w	1

checkfirstwordrout:	rs.l	1
bpl2chunkyLinerout:	rs.l	1

firstword:	rs.l	1
bitshift:	rs.l	1

free5:		rs.l	1
free6:		rs.l	1
free7:		rs.l	1
free8:		rs.l	1

windowtaglist	rs.l	1
gadgets:	rs.l	1
winscreen:	rs.l	1
window:		rs.l	1
Glist:		rs.l	1
NGads:		rs.l	1
GTypes:		rs.l	1
win_CNT:	rs.w	1
WinGadgets:	rs.l	1
windowtags:	rs.l	1
screenbase:	rs.l	1

WinLeft:	rs.w	1
WinWidth:	rs.w	1
WinHeight:	rs.w	1
WinTop:		rs.w	1
WinL:		rs.l	1
WinT:		rs.l	1
WinW:		rs.l	1
WinH:		rs.l	1

mainx:		rs.w	1	;für positionssave
mainy:		rs.w	1

Scr:		rs.l	1

openwinrout:	rs.l	1

waitrout:	rs.l	1
writetextrout:	rs.l	1
textnum:	rs.w	1

checkmainwinposrout: rs.l	1

renderbase:	rs.l	1

rndr_rendermem: rs.l	1	;pointer für den gesamten Speicher für rendern
rndr_chunky8size: rs.l	1	;größe des Chunky8 Puffers
rndr_rgbsize:   rs.l	1	;größe des RGB Puffers
rndr_chunky:	rs.l	1
rndr_rgb:	rs.l	1
rndr_histogram:	rs.l	1
rndr_memhandler:rs.l	1
rndr_palette:	rs.l	1

depthchange:	rs.b	1	;die Farbtiefe wurde verändert
		rs.b	1

cyberbase:	rs.l	1

free9:		rs.l	1
free10:		rs.l	1
free11:		rs.l	1
free12:		rs.l	1

usedatatype:	rs.b	1
newloaded:	rs.b	1	;merker ob von einem Pic die Position gemerkt werden soll

rndr_lock:	rs.b	1
intern3:	rs.b	1
		
ren_colormode:	rs.l	1
ren_colorlevel:	rs.l	1
ren_cust:	rs.l	1
ren_usedcolors:	rs.l	1
ren_firstcolors:rs.l	1
ren_palsortmode:rs.l	1
ren_palordermode:rs.l	1
ren_dithermode:	rs.l	1
ren_damount:	rs.l	1

doprocesshook:	rs.l	1

loadernode:	rs.l	1
savernode:	rs.l	1
operatornode:	rs.l	1

loader:		rs.l	1
saver:		rs.l	1
operator:	rs.l	1
loadername:	rs.l	1
savername:	rs.l	1
operatorname:	rs.l	1

utilbase:	rs.l	1
guigfxbase:	rs.l	1
mp_width:	rs.l	1
mp_height:	rs.l	1
mp_colors:	rs.l	1
mp_palette:	rs.l	1
mp_palfmt:	rs.l	1
mp_woffset:	rs.l	1
mp_hoffset:	rs.l	1
dp_drawhandle:	rs.l	1
dp_picture:	rs.l	1
dp_psm:		rs.l	1	;PenShareMap

rxPort:		rs.l	1

mathtransbase:	rs.l	1


;======================================================================

wbbase:		rs.l	1
lastreq:	rs.l	1
checkkey1rout:	rs.l	1
checkprompt:	rs.l	1
reqtbase1:	rs.l	1	;zweiter Reqbase puffer
WBMessage:	rs.l	1	;

firstloader:	rs.l	1	;segment des ersten loaders für UnloadSeg
lastloader:	rs.l	1    	;segment des letzten loaders der eingeladen wurde
firstsaver:	rs.l	1	;segment des ersten savers für UnloadSeg
lastsaver:	rs.l	1    	;segment des letzten savers der eingeladen wurde
firstoperator:	rs.l	1
lastoperator:	rs.l	1
rgbmem:		rs.l	1
rgbtemp:	rs.l	1
rgbtemp1:	rs.l	1
rgbpuff:	rs.l	1
tmp_line:	rs.l	1
tmpname:	rs.l	1	;point ab dem der tmpfilename eingetragen wird
undolevel:	rs.l	1
aktundolevel:	rs.l	1	;aktueller undolevel
st_lasttmp:	rs.l	1
st_akttmp:	rs.l	1
st_filehandle:	rs.l	1
st_first:	rs.l	1	;nummer des ersten undo level
st_overflow:	rs.w	1
st_lastmax:	rs.l	1

newanzcolor:	rs.l	1	;anzahl farben nach dem Packen
anzcolorbak:	rs.w	1	;anzahl der Farben backup für render
memsize:	rs.l	1
loadbody:	rs.l	1	;Mem für BodyChunck
bodylaenge:	rs.l	1	;Länge des BodyChunck
Uviewport:	rs.l	1
Uviewport1:	rs.l	1
mainRastport:	rs.l	1
viewRastport:	rs.l	1
processrastport: rs.l	1
checkkey2rout:	rs.l	1

nc_lroutine:	rs.w	1
nc_sroutine:	rs.w	1
nc_oroutine:	rs.w	1
nc_routine:	rs.w	1	;Nummer der angewählten Load/Save Routine
nc_addroutine:	rs.w	1
nc_addtime:	rs.w	1

ls_screen:	rs.w	1	;Nummer des Angewaehlten Screens
linemem:	rs.l	1	;Puffer für Color
linememsize:	rs.l	1	;größe des Puffers
lines:		rs.l	1	;anzahl der Zeilen für Copper
filelockmerk:	rs.l	1
dirlock:	rs.l	1
ProgramDirlock:	rs.l	1
lastcurrentdirlock:rs.l	1
lastcurrentdirlock1:rs.l	1
puffermem:	rs.l	1
puffersize:	rs.l	1
spriteplanes:	rs.l	1
WBScreen:	rs.l	1	;Workbench Screen
WBwidth:	rs.w	1	;breite der Workbench
WBheight:	rs.w	1	;höhe der selben
WBFontStruck:	rs.l	1	;Fontstrucktur der WB
WBModeID:	rs.l	1
namepuffer:	rs.l	1

DisplayWidth:	rs.w	1
DisplayHeight:	rs.w	1
bitmapmerk:	rs.l	1	;merke aktuelle Addr. von Bitplane
brushheight:	rs.w	1
scale:		rs.l	1	;um vieviel die Screenhöhe halbiert werden muß
keylen:		rs.l	1
gadmerk:	rs.l	1
aktwin:		rs.l	1
port:		rs.l	1
mspc:		rs.l	1
msgport:	rs.l	1
itemstruck:	rs.l	1
puffermerk:	rs.l	1
bodymerk:	rs.l	1
formlenght:	rs.l	1
numpuffer:	rs.l	1	;Nummer der Farbe die für Mask benutzt wird
numpuffer1:	rs.l	1
checkkey3rout:	rs.l	1
WinMsgPort1:	rs.l	1
WinMsgPort2:	rs.l	1
WinMsgPort3:	rs.l	1
appmsgport:	rs.l	1
appwinWnd:	rs.l	1
SignalBits:	rs.l	1
Ibase:		rs.l	1	;IntuitionBase für Screenload
listviewmem:	rs.l	1
aktscreen:	rs.l	1	;Screen der geladen werden soll
ScreenViewport:	rs.l	1	;ViewPort vom Screen der geladen werden soll
ScreenID:	rs.l	1
screenbitmap:	rs.l	1
bankcolor:	rs.l	1	;Anzahl der Farben für eine Colorbank
imagewidth:	rs.l	1	;breite des Raw-Image das geladen werden soll
imageheight:	rs.l	1
imagedepth:	rs.l	1
imagedisplay:	rs.l	1
linkmemtype:	rs.l	1   ;memtype mit dem Linkobjekt gespeichert werden soll
linknumchars:	rs.l	1
linkmemsize:	rs.l	1
kwords:		rs.l	1	;anzahl der Worte in einem Brush
loadnumber:	rs.w	1
savenumber:	rs.w	1
datapuffermerk: rs.l	1
datazaehler:	rs.w	1	;zaehlt die worte die in den datapuffer kommen
linememmerk:	rs.l	1
linedatasmerk:	rs.l	1	;
datasmerk:	rs.l	1
startbase:	rs.l	1
usernummer:	rs.w	1
biasviewport:	rs.l	1
colormem:	rs.l	1
decodier1rout:	rs.l	1
windowlock:	rs.l	1	;merkzelle für rtLockWindow()
scaleargs:	rs.b	bsa_sizeof	;puffer für ScaleArgs um Logo zu Scalen

colorlevelproz: rs.l	1
colorlevel:	rs.l	1	;für Color-Bias
brightlevel:	rs.l	1
contrastlevel:	rs.l	1
redlevel:	rs.l	1
greenlevel:	rs.l	1
bluelevel:	rs.l	1
gammalevel:	rs.l	1
rgblinemem:	rs.l	1	;speicher für eine Zeile bei RGB-Chunky save
anzchunky:	rs.l	1
histobuffer:	rs.l	1	;speicher für Histogram bei ChooseColors
histosize:	rs.l	1	;größe des Histogramm puffers
picbuffer:	rs.l	1	;speicher für buffer Pic
picmap1:	rs.b	8+4*10
rgbmap:		rs.b	8+4*10
cb_actbin:	rs.l	1
cb_lastnode:	rs.l	1	;kopf des Suchbaums

DTObject:	rs.l	1	;Pointer von NewDTObjectA()
newfontstruck:	rs.l	1
newfontname1:	rs.l	1
newfontname:	rs.b	30
newfontheight:	rs.w	1	
pnewfontname:	rs.b	30
pnewfontheight:	rs.w	1	
finalfontname:	rs.b	40
userfont:	rs.l	1
newlogoleft:	rs.w	1
newlogotop:	rs.w	1
newlogowidth:	rs.w	1
newlogoheight:	rs.w	1
aktcolor:	rs.l	1	;aktuelle Farbe in Palette
realaktcolor:	rs.l	1
pal_aktred:	rs.l	1
pal_aktgreen:	rs.l	1
pal_aktblue:	rs.l	1
pal_undored:	rs.l	1
pal_undogreen:	rs.l	1
pal_undoblue:	rs.l	1
coloroffset:	rs.l	1	;offset zur aktuellen Farbe
reqwinmerk:	rs.l	1	;window merken

fonlen		=	pnewfontname-newfontname

labelcount:	rs.w	1	;zähler für LabelsNamen
lastreqcheck:	rs.l	1	;checksumme für Lastreq aufruf
lastreqcheck1:	rs.l	1	;checksumme für Lastreq aufruf

pc_top:		rs.l	1
pc_left:	rs.l	1
pc_width:	rs.l	1
pc_height:	rs.l	1
pc_step:	rs.l	1
pc_stepcounter: rs.l	1

loadsavemark:	rs.l	1


;--- InternFlags ---

noslider:	rs.b	1
savedata:	rs.b	1
second:		rs.b	1
first:		rs.b	1	;erste kontrollword bei sprite
rawblitt:	rs.b	1					
nomove:		rs.b	1
nogadremove:	rs.b	1
bindata:	rs.b	1
nocut:		rs.b	1
lockcheck:	rs.b	1	;ist lockmon erlaubt
newlinemerk:	rs.b	1
restmerk:	rs.b	1
saveflag:	rs.b	1
kommaflag:	rs.b	1
lastsave:	rs.b	1	;Saveline wird zum letzten mal aufgerufen
saveright:	rs.b	1
biasmerk:	rs.b	1
keyfound:	rs.b	1
firstmode:	rs.b	1	;wurde schon ein Mode ausgewählt
allflag:	rs.b	1
rgb24:		rs.b	1
iconifyflag:	rs.b	1
cbhammerk:	rs.b	1
cbrenderflag:	rs.b	1
fontallready:	rs.b	1
choosepub:	rs.b	1
logomerk:	rs.b	1
nofont:		rs.b	1
newwin:		rs.b	1	;es muß ein neues Fenter aufgemacht werden
newscr:		rs.b	1
newfont:	rs.b	1	;der Font wurde in der Prefs verändert
usepref:	rs.b	1	;
custmerk:	rs.b	1
custfail:	rs.b	1
nc_addarrowmerk:rs.b	1
nc_arrowmerk:	rs.b	1
useRGB:		rs.b	1
useCMY:		rs.b	1
useHSV:		rs.b	1
useYUV:		rs.b	1
useYIQ:		rs.b	1
Toflag:		rs.b	1	;es wurde Spread, Copy oder Swap angeklickt
firstload:	rs.b	1	;flag für laden von einem argument
cybertest:	rs.b	1

;--- Intern ---
decodier2rout:	rs.l	1
cu_x:		rs.w	1
cu_y:		rs.w	1
cu_width:	rs.w	1
cu_height:	rs.w	1
cu_word:	rs.w	1
xmouse:		rs.w	1
ymouse:		rs.w	1
xmousereal:	rs.w	1
ymousereal:	rs.w	1
oldx:		rs.w	1
oldy:		rs.w	1
oldxbox:	rs.w	1
oldybox:	rs.w	1
check7:		rs.w	1
xbox:		rs.w	1
ybox:		rs.w	1
xboxreal:	rs.w	1
yboxreal:	rs.w	1
xdiff:		rs.w	1
ydiff:		rs.w	1
xtest:		rs.w	1
ytest:		rs.w	1
xwert:		rs.w	1
ywert:		rs.w	1
xmerk:		rs.w	1
ymerk:		rs.w	1
xzaehler:	rs.w	1
anzgitter:	rs.w	1
boxsize:	rs.w	1
locktest:	rs.w	1
oldrast:	rs.w	1
newrast:	rs.w	1
clrflag:	rs.w	1
anzsprite:	rs.l	1
xadd:		rs.l	1
dummymerk:	rs.l	1
				check3:		rs.w	1

	ifne 	decodier2rout/2*2<>decodier2rout
	error
	endc

;--- Picdaten ---
keypuffermerk:	rs.l	1
check5:		rs.w	1
transcolor:	rs.w	1
verhaeltnis:	rs.w	1
xresolution:	rs.w	1
yresolution:	rs.w	1
oneplanesizeoffset: rs.l	1
brush:		rs.b	1	;Es wird ein brush angezeigt
hires:		rs.b	1
superhires:	rs.b	1
lace:		rs.b	1
screenbreite:	rs.w	1
screenhight:	rs.w	1
;screenbyte:	rs.w	1
bmodulo:	rs.l	1
modulo:		rs.w	1
lmodulo:	rs.w	1
screenmode:	rs.w	1
ybrush1buffer:	rs.w	1
check8:		rs.w	1
xbrushpuff1:	rs.w	1
xbrushpuff2:	rs.w	1
brushbyte:	rs.l	1
finalcheck:	rs.w	1
brushpuffer:	rs.l	1
brushmemsize:	rs.l	1
linkobjektsize:	rs.l	1
merk:		rs.b	1
full:		rs.b	1	; Pic voll gepuffert absaven
endbase:	rs.l	1
bxsize:		rs.l	1
bysize:		rs.l	1
brushXwidth:	rs.l	1
brushYheight:	rs.l	1
sleftmerk:	rs.l	1	;merker für Screenpositionen
stopmerk:	rs.l	1
aktcolordepth:	rs.l	1	;aktuell eingestellte Farbtiefe

;--- GadTools ---

abouttest:	rs.l	1
fontx:		rs.w	1
fonty:		rs.w	1
attr:		rs.l	2
font:		rs.l	1
offx:		rs.w	1
offy:		rs.w	1
BufIText:	rs.b	20
ic_Wnd:		rs.l	1
scr1:		rs.l	1
scr2:		rs.l	1
Scr3:		rs.l	1
Scr4:		rs.l	1	;Palette
Scr5:		rs.l	1	;Palette2
VisualInfo:	rs.l	1
tmpVisual:	rs.l	1
mainwinWnd:	rs.l	1
choosewinWnd:	rs.l	1
newchoosewinWnd:rs.l	1
nc_choosewinWnd:rs.l	1
prefswinWnd:	rs.l	1
screenwinWnd:	rs.l	1
ViewWnd:	rs.l	1
konwinWnd:	rs.l	1
imagewinWnd:	rs.l	1
linkwinWnd:	rs.l	1
biaswinWnd:	rs.l	1
spritewinWnd:	rs.l	1
labelwinWnd:	rs.l	1
palwinWnd1:	rs.l	1
palwinWnd2:	rs.l	1
palwinWnd3:	rs.l	1
processWnd:	rs.l	1
mainwinGList:	rs.l	1
choosewinGList:	rs.l	1
newchoosewinGList:rs.l	1
newmodulewinGList:rs.l	1
prefswinGList:	rs.l	1
konwinGList:	rs.l	1
screenwinGlist:	rs.l	1
imagewinGlist:	rs.l	1
linkwinGlist:	rs.l	1
biaswinGlist:	rs.l	1
spritewinGlist:	rs.l	1
labelwinGlist:	rs.l	1
palwinGlist1:	rs.l	1
palwinGlist2:	rs.l	1
palwinGlist3:	rs.l	1
processGlist:	rs.l	1

check1:		rs.b	1
		rs.b	1

lockmerk:	rs.w	1
dispmerk:	rs.l	1
		rs.l	1

prefsx:		rs.w	1
prefsy:		rs.w	1
		rs.w	1

StruckAdr3:	rs.l	1	;reqtoolsstruck für add loader
StruckAdr4:	rs.l	1	;reqtoolsstruck für add saver
ch_dirname:	rs.l	1
ch_filelenght:	rs.l	1
ch_FileName:	rs.b	108
ch_loadname:	rs.b	200

prefsDisplayID:	rs.l	1
prefsdisplayWidth:rs.w	1
prefsDisplayHeight:rs.w	1
prefsDisplayDepth:rs.w	1
prefsoverscantype:rs.w	1
prefsautoroll:	rs.l	1

aktpubscreen:	rs.b	30

pprefsDisplayID: rs.l	1
pprefsdisplayWidth:rs.w	1
pprefsDisplayHeight:rs.w 1
pprefsDisplayDepth:rs.w	1
pprefsoverscantype:rs.w	1
pprefsautoroll:	rs.l	1

paktpubscreen:	rs.b	30

displen		=	pprefsDisplayID-prefsDisplayID

OpScreenmode:	rs.l	1	;screen mode für operatorscreen

OpdisplayWidth:	rs.w	1
OpDisplayHeight:rs.w	1
OpDisplayDepth: rs.w	1

OpDestWidth:	rs.l	1
OpDestHeight:	rs.l	1

vi_screen:	rs.l	1	;Visual Screen
vi_window:	rs.l	1

OpColMode:	rs.b	1
pOpColMode:	rs.b	1

POpScreenmode:		rs.l	1
POpdisplayWidth:	rs.w	1
POpDisplayHeight:	rs.w	1
POpDisplayDepth:	rs.w	1




anzmaincolors:	rs.w	1	;anzahl farben im MainScreen


;Merker für Sourceengine

sasmsource:	rs.b	1	;Copper als asm-source
scsource:	rs.b	1
spascal:	rs.b	1
sesource:	rs.b	1
sbasic:		rs.b	1
databyte:	rs.b	1	;Datas als Byte dc.b
dataword:	rs.b	1	;Datas als Word dc.w
datalongword:	rs.b	1	;Datas als Longword dc.l


;--- Preferences ---
overwrite:	rs.b	1	;Überschreiben ?
showpic:	rs.b	1	;Zeige Pic nach laden
autosavecolor:	rs.b	1	;save Colors automatisch
drawgrid:	rs.b	1	;Zeichne beim Ausschneiden ein Raster
littlewin:	rs.b	1	;Iconify als kleines Fenster
_appicon:	rs.b	1	;als AppIcon
appitem:	rs.b	1	;als AppItem
workbench:	rs.b	1	;\
publicscr:	rs.b	1	; - auf welchem Screen soll ArtPRO sich öffnen
customscr:	rs.b	1	;/
askforexit:	rs.b	1
opdepth		rs.b	1	;tiefe des Operatorscreens
vidither:	rs.b	1
mpreview:	rs.b	1	
dscale:		rs.b	1
hsize:		rs.b	1	;histogramm größe
pundo:		rs.b	1
		rs.b	13	;reserve

words:		rs.w	1    ;wieviel worte für ein Sprite geholt werden müssen

	ifne words/2*2<>words
	error
	endc

;--- Preferences Puffer ---

poverwrite:	rs.b	1	;Überschreiben ?
pshowpic:	rs.b	1	;Zeige Pic nach laden
pautosavecolor:	rs.b	1	;save Colors automatisch
pdrawgrid:	rs.b	1	;Zeichne beim Ausschneiden ein Raster
plittlewin:	rs.b	1	;Iconify als kleines Fenster
pappicon:	rs.b	1	;als AppIcon
pappitem:	rs.b	1	;als AppItem
pworkbench:	rs.b	1
ppublicscr:	rs.b	1
pcustomscr:	rs.b	1
paskforexit:	rs.b	1
popdepth:	rs.b	1
pvidither:	rs.b	1
pmpreview:	rs.b	1	
pdscale:	rs.b	1
phsize:		rs.b	1
ppundo:		rs.b	1
		rs.b	13	;reserve

ptag_show:	rs.l	1
ptad_drawgrid:	rs.l	1
ptag_autosave:	rs.l	1
ptag_overwrite:	rs.l	1
pTAG_iconify:	rs.l	1
PTAg_screens	rs.l	1
pTAG_askforexit:rs.l	1
pTAG_videpth:	rs.l	1
pTAG_vidither:	rs.l	1
pTAG_preview:	rs.l	1
pTAG_scale:	rs.l	1
pTAG_hsize:	rs.l	1


	ifne PTAg_screens/2*2<>PTAg_screens
	error
	endc
check6:		rs.w	1
name:		rs.b	30
vorname:	rs.b	30
strasse:	rs.b	100
plz:		rs.b	10
ort:		rs.b	50
staat:		rs.b	50
telefon:	rs.b	50
regdat:		rs.b	50

keymsgpuffer:	rs.b	500

check2:		rs.w	1
		
chunkypuffer:	rs.b	16
chunkyleerpuffer:	rs.b	16

loadsavestring: rs.l	3
check4:		rs.w	1

execbasepuffer:	rs.l	1

PFilename:	rs.b	108
Psavename:	rs.b	200
pdirname:	rs.l	1

loaddirname:	rs.b	200
savedirname:	rs.b	200

prefsfarbtab4:	rs.w	260
prefsfarbtab8:	rs.l	257*3

prefspurefarbtab: rs.b	256*3
prefspurefarbtabback: rs.b	256*3


;Puffer für Saverprefs

SIFF_pack:	rs.b	1
SIFF_render:	rs.b	1	;24 Bit oder gerendert

;----------------------------------------------------------------------------
SRAW_outsource:	rs.b	1
SRAW_outbinary:	rs.b	1
SRAW_outlink:	rs.b	1
sraw_outtag_:	rs.b	1
SRAW_blitnone:	rs.b	1
SRAW_blitleft:	rs.b	1
SRAW_blitright:	rs.b	1
sraw_blittag_:	rs.b	1
SRAW_pimage:	rs.b	1
SRAW_pmask:	rs.b	1
SRAW_pinter:	rs.b	1
SRAW_asmsource:	rs.b	1
SRAW_scsource:	rs.b	1
SRAW_pascal:	rs.b	1
SRAW_esource:	rs.b	1
SRAW_basic:	rs.b	1
sraw_sourcetag:	rs.b	1
SRAW_byte:	rs.b	1	;Datas als Byte dc.b
SRAW_word:	rs.b	1	;Datas als Word dc.w
SRAW_longword:	rs.b	1	;Datas als Longword dc.l
sraw_widthtag:	rs.b	1
SRAW_dtabs:	rs.b	1
sraw_dspaces:	rs.b	1
sraw_intag:	rs.b	1
sraw_indents:	rs.b	1
sraw_entri:	rs.b	1
sraw_amask:	rs.b	1
srawlen		= sraw_amask-sraw_outsource
;---------------------------------------------------------------------------
pal_asmsource:	rs.b	1
pal_scsource:	rs.b	1
pal_pascal:	rs.b	1
pal_esource:	rs.b	1
pal_basic:	rs.b	1
pal_sourcetag:	rs.b	1
pal_byte:	rs.b	1	;Datas als Byte dc.b
pal_word:	rs.b	1	;Datas als Word dc.w
pal_longword:	rs.b	1	;Datas als Longword dc.l
pal_widthtag:	rs.b	1
pal_dtabs:	rs.b	1
pal_dspaces:	rs.b	1
pal_intag:	rs.b	1
pal_indents:	rs.b	1
pal_entri:	rs.b	1
pal_source:	rs.b	1
pal_binary:	rs.b	1
pal_link:	rs.b	1
pal_iff:	rs.b	1	;Save Color als IFF
pal_outtag_	rs.b	1
pal_copper:	rs.b	1	;Save als Copperliste
pal_loadrgb:	rs.b	1
pal_pure:	rs.b	1
pal_formtag:	rs.b	1
pal_depth4:	rs.b	1	;tiefe der Palette 4 Bit
pal_depth8:	rs.b	1
pal_depthtag:	rs.b	1
		rs.b	1
pallen		= pal_depthtag-pal_asmsource

lpal_iff:	rs.b	1	;Save Color als IFF
lpal_loadrgb:	rs.b	1
lpal_pure:	rs.b	1
lpal_formtag:	rs.b	1
lpal_depth4:	rs.b	1	;tiefe der Palette 4 Bit
lpal_depth8:	rs.b	1
lpal_depthtag:	rs.b	1
		rs.b	1

lpallen		= lpal_depthtag-lpal_iff

;---------------------------------------------------------------------------
spr_asmsource:	rs.b	1
spr_csource:	rs.b	1
spr_pascal:	rs.b	1
spr_esource:	rs.b	1
spr_basic:	rs.b	1
spr_sourcetag:	rs.b	1
spr_byte:	rs.b	1	;Datas als Byte dc.b
spr_word:	rs.b	1	;Datas als Word dc.w
spr_longword:	rs.b	1	;Datas als Longword dc.l
spr_widthtag:	rs.b	1
spr_dtabs:	rs.b	1
spr_dspaces:	rs.b	1
spr_intag:	rs.b	1
spr_indents:	rs.b	1
spr_entri:	rs.b	1
spr_source:	rs.b	1
spr_binary:	rs.b	1
spr_link:	rs.b	1
spr_outtag_:	rs.b	1
spr_sprite04:	rs.b	1	;Save Sprite als 4 Farbensprite
spr_sprite16:	rs.b	1	;als 16 Farben
spr_0416tag:	rs.b	1
spr_spritewidth16:	rs.b	1	;16 
spr_spritewidth32:	rs.b	1	;32 AGA
spr_spritewidth64:	rs.b	1	;64 AGA
spr_spritewidthtag:	rs.b	1
spr_cwnone:		rs.b	1	;keine Kontrollwords
spr_cwempty:		rs.b	1
spr_cwpos:		rs.b	1
spr_cwprompt:		rs.b	1
spr_cwtag:		rs.b	1
spr_uselabels:		rs.b	1

sprlen		=	spr_uselabels-spr_asmsource
;---------------------------------------------------------------------------
chk_asmsource:	rs.b	1
chk_csource:	rs.b	1
chk_pascal:	rs.b	1
chk_esource:	rs.b	1
chk_basic:	rs.b	1
chk_sourcetag:	rs.b	1
chk_byte:	rs.b	1	;Datas als Byte dc.b
chk_word:	rs.b	1	;Datas als Word dc.w
chk_longword:	rs.b	1	;Datas als Longword dc.l
chk_widthtag:	rs.b	1
chk_dtabs:	rs.b	1
chk_dspaces:	rs.b	1
chk_intag:	rs.b	1
chk_indents:	rs.b	1
chk_entri:	rs.b	1
chk_source:	rs.b	1
chk_binary:	rs.b	1
chk_link:	rs.b	1
chk_outtag_:	rs.b	1
chk_normaltype:	rs.b	1
chk_rgbtype:	rs.b	1
chk_chktypetag:	rs.b	1
chk_lefttype:	rs.b	1
chk_righttype:	rs.b	1
chk_normaltypetag:rs.b	1
chk_12bit:	rs.b	1
chk_18bit:	rs.b	1
chk_24bit:	rs.b	1
chk_rgbtypetag:	rs.b	1
chk_leftpack:	rs.b	1
chk_rightpack:	rs.b	1

chklen		=	chk_rightpack-chk_asmsource

chk_firstmakechunk:	rs.b	1
			rs.b	1

;---------------------------------------------------------------------------

ren_colorlevelbak:	rs.l	1
ren_colormodebak:	rs.l	1
ren_palmodetabbak:	rs.l	1
ren_colvisbak:		rs.l	1
ren_paltextbak:		rs.l	1
ren_dithermodebak:	rs.l	1
ren_dithertagbak:	rs.l	1
ren_palsortmodebak:	rs.l	1
ren_palsorttagbak:	rs.l	1
ren_palodertagbak:	rs.l	1
ren_palordermodebak:	rs.l	1
ren_custbak:		rs.l	1
ren_custtagbak:		rs.l	1
ren_ucolvisbak:		rs.l	1
ren_usedcolorsbak:	rs.l	1
ren_firstvisbak:	rs.l	1
ren_firstcolorsbak:	rs.l	1
ren_ucolmaxbak:		rs.l	1
ren_ucolnumbak:		rs.l	1
ren_fnumbak:		rs.l	1
ren_damountbak:		rs.l	1

;---------------------------------------------------------------------------

;vi_width:	rs.l	1
;vi_height:	rs.l	1
vi_colors:	rs.l	1
vi_palette:	rs.l	1
vi_palfmt:	rs.l	1
vi_drawhandle:	rs.l	1
vi_picture:	rs.l	1
vi_psm:		rs.l	1	;PenShareMap

;---------------------------------------------------------------------------

data_indents:	rs.l	1
data_datasPL:	rs.l	1
data_tab:	rs.b	1
		rs.b	1

datalen:	rs.w	0

		ds.b	datalen

	section	datas1,bss
	
bytepuffer:	ds.b	4
;chunkpuffer:	ds.b	200

	even

farbtab8pure:	ds.l	256
farbtab4pure:	ds.w	256

farbtab8bak:	ds.l	3*256+2

prefpuffer:	ds.b	500		;Puffer um die Prefs aufzunehmen

	even
prefssavepuffer:
		ds.b	500+(256*3)

		cnop 0,4
infoblock:	ds.b	512		;Puffer für Fileinfoblock

		cnop 0,4
infoblock1:	ds.b	512		;Puffer für Fileinfoblock

mo_IText:
		ds.b	32+16		;Platz für ScreenMode Text

infopuffer:	ds.b	88		;puffer für DimensionInfo

linkheaderpuffer: ds.b	50
extdefstring:	ds.b	26

reqstruck:	ds.b	100

datapuffer:	ds.b	500	;nimmt daten für datasave erstmal auf

colorpuffer1:	ds.w	3*257
colorpuffer2:	ds.w	3*257

cb_farbtab4:	ds.w	260	;Puffertabellen für Color-Bias
cb_farbtab8:	ds.l	257*3	;	     -""-
cb_pufferfarbtab: ds.l	256
keypuffer:	ds.b	400

dirnamebuffer	ds.b	200
labelpuffer	ds.b	50

logopuffer:	ds.b	20500

tmpbuffer:	ds.b	4000

req_struck:	ds.b	rq_sizeof

dataend

datalen1	= dataend-bytepuffer

;=========================================================================

		section	images,data_c

appiconimage1:
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000,$00000C00,$00000000,$00000000,$00000C00,$08888888,$88000888,$88888C00,$00000000,$00000000,$00000C00,$22200002,$00000302,$22222C00,$00001004,$00FC0E00,$00000C00,$08807E03,$807E0F00,$00088C00,$00007F01,$C07C0FF8,$00000C00,$2AA03E00,$E00007F8,$000AAC00,$00000000,$700007F0,$1F3E0C00,$2AA80060,$380601E0,$1FFFAC00,$000007F0,$181F80E0,$3F1F0C00,$2AAA03F8,$1C0FC0C0,$7EAAAC00,$111101F0,$3C07E380,$FF111C00,$2AAA80EB,$BE07FB00,$FEAAAC00,$545441F4,$5F3FD701,$FC545C00,$2AA07FFA,$ABEFEE03,$FAAAAC00,$514003F9,$0017D187,$F1515C00,$2AA00070,$0002ABE7,$EAAAAC00,$55408038,$0F01FC01,$D5555C00,$2A80F818,$0FC0E000,$2AAAAC00,$5D81FC1C,$0FC1C000,$1DDDDC00,$2A81F81C,$0C01C038,$1EAAAC00,$7700001E,$0003C0FC,$0F777C00,$2A00005E,$0000C0FE,$07AAAC00,$5C0600FE,$0F00E073,$03DDDC00,$2A07FFFE,$07E0703F,$81EAAC00,$7C0FFFFF,$07E0781F,$81FFFC00,$2A0FEBEA,$07E07C00,$03FAAC00,$7FFFFFFF,$07FFFF00,$01FFFC00,$3BBFBBBB,$BFFBFFA0,$07FBBC00,$7FFFFFFF,$FFFFFFFF,$FFFFFC00,$6EEEEEEE,$EEEEEEEF,$FFEEEC00,$7FFFFFFF,$FFFFFFFF,$FFFFFC00,$7FFFFFFF,$FFFFFFFF,$FFFFFC00,$7FFFFFFF,$FFFFFFFF,$FFFFFC00,$3FFFFFFF,$FFFFFFFF,$FFFFFC00,$FFFFFFFF,$FFFFFFFF,$FFFFF000,$80000000,$00000000,$00000400,$80000000,$00000000,$00000400,$88888888,$8AFF8888,$88888400,$8000FF80,$3FFFE000,$00000400,$A227FFE2,$3FD7F3F6,$22222400,$800FD3F0,$1FC1FBFF,$A0000400,$889F71F8,$9FC1FC5F,$FE888400,$801FF8FC,$4FC5F80F,$FFF00400,$AAAFFEFE,$2FFFE087,$F7EAA400,$8007EBFF,$17FFF837,$E0C20400,$AAABFEDF,$8FF6FC6F,$C0802400,$8001FFFF,$C3FE3EFF,$80100400,$AAAAFF8F,$F7F17FFF,$80AAA400,$91117F92,$B1F0FABF,$83111400,$AAAABFCB,$A3D04B7E,$02AAA400,$D4545904,$410057FC,$04545400,$AAAEFE02,$AB882FF8,$0AAAA400,$D15FF781,$ABF3D194,$11515400,$AABFFF77,$FFFEABE0,$0AAAA400,$D57F9FFB,$E97E7FF5,$15555400,$AABE07FB,$E07E6FFF,$AAAAA400,$DDFF23FB,$F1FFFF8F,$DDDDD400,$AAFDFBF1,$FC7EFE33,$F6AAA400,$F7FF9FC3,$FFFA7E89,$F9777400,$AAFFFFC1,$FFFE7F04,$FCAAA400,$DDFEBAC1,$F93FBF83,$7A5DD400,$ABF70002,$F41F1FFF,$BC2AA400,$FFFE0007,$FC7F8FFF,$BC1FF400,$AB6C2BEA,$FC6D03FD,$7E0AA400,$FFF07FFF,$D03F03FF,$F80FF400,$BBA03BBB,$B83B03B7,$A40BB400,$FFFE7FFF,$FDFFFFF0,$001FF400,$EEEEEEEE,$EEEEEEEC,$006EE400,$FFFFFFFF,$FFFFFFFF,$E7FFF400,$FFFFFFFF,$FFFFFFFF,$FFFFF400,$00000000,$00000000,$00000400,$3FFFFFFF,$FFFFFFFF,$FFFFFC00
appiconimage2:
		dc.l	$FFFFFFFF,$FFFFFFFF,$FFFFF800,$80000000,$00000000,$00000400,$80000000,$00000000,$00000400,$80000000,$00000000,$00000400,$80000000,$00000000,$00000400,$80000000,$00000000,$00000400,$80000000,$00000000,$0FF00400,$80000000,$03C00000,$FFF80400,$80000007,$83300001,$85F80400,$80000786,$63300003,$1FF80400,$80000666,$61E00002,$38FC0400,$80000663,$C1B80002,$38FC0400,$800003C3,$7188001F,$B8FC0400,$80000373,$100007F5,$B87C0400,$80000310,$0001FA82,$F87E0400,$80000000,$00FF4015,$FC7E0400,$8007FD00,$3FA80AAA,$FC360400,$801EFFFF,$D4015555,$7C2E0400,$803FEFEA,$80AAAAAA,$FC660400,$807FFD40,$17FD5555,$7CE60400,$807EA80A,$AFFFFEAB,$FF9E0400,$807D0155,$5DDFFFFE,$FD7C0400,$807E2AAA,$BB6EFD5C,$7FF40400,$807D1555,$7FDB7BEE,$FFA80400,$803EAAAB,$FFFEF757,$55000400,$801555FF,$FFFFE6BB,$00000400,$8006FFFF,$FFFFD5D9,$00000400,$8003D5FF,$FFFFE6DB,$00000400,$8002AFAF,$FFFFF62B,$00000400,$8015F555,$7FFFFBF6,$00000400,$800AAA82,$AAFFFD5C,$00000400,$80014010,$0557FFF0,$00000400,$80000000,$202AAA00,$00000400,$80000000,$00814000,$00000400,$80000000,$00000000,$00000400,$80000000,$00000000,$00000400,$80000000,$00000000,$00000400,$3FFFFFFF,$FFFFFFFF,$FFFFFC00,$FFFFFFFF,$FFFFFFFF,$FFFFF800,$FFFFFFFF,$FFFFFFFF,$FFFFFC00,$C0000000,$00000000,$00000000,$C0000000,$00000000,$00000000,$C0000000,$00000000,$00000000,$C0000000,$00000000,$00000000,$C0000000,$00000000,$04000000,$C0000000,$00000000,$0FF00000,$C0000000,$00000000,$A5F00000,$C0000000,$00000001,$98700000,$C0000000,$00000000,$B0780000,$C0000000,$00000000,$30780000,$C0000000,$00000000,$B0B80000,$C0000000,$00000015,$30380000,$C0000000,$00000282,$703A0000,$C0000000,$00014015,$785C0000,$C0000100,$00A80AAA,$B8140000,$C006FEA0,$14015555,$380C0000,$C01FE80A,$80AAAAAA,$B8440000,$C03E0540,$14015555,$38340000,$C020A80A,$A3FC02A8,$7CDC0000,$C0150155,$4DDFF802,$7D600000,$C04A2AAA,$9B6EE550,$3E140000,$C0611555,$5FDB5BEC,$C1A80000,$C03AAAAA,$1BFEB756,$55000000,$C0115405,$5777A6BA,$00000000,$C00481A0,$AAAE95D8,$00000000,$C00055D5,$015526DA,$00000000,$C002AFAE,$A80AB62A,$00000000,$C015F555,$75505BF4,$00000000,$C00AAA82,$AAEA8150,$00000000,$C0014010,$05575000,$00000000,$C0000000,$202AAA00,$00000000,$C0000000,$00814000,$00000000,$C0000000,$00000000,$00000000,$C0000000,$00000000,$00000000,$C0000000,$00000000,$00000000,$20000000,$00000000,$00000000

WaitPointer:	dc.w	$0000,$0000
		dc.w	$0400,$07C0,$0000,$07C0,$0100,$0380,$0000,$07E0
		dc.w	$07C0,$1FF8,$1FF0,$3FEC,$3FF8,$7FDE,$3FF8,$7FBE
		dc.w	$7FFC,$FF7F,$7EFC,$FFFF,$7FFC,$FFFF,$3FF8,$7FFE
		dc.w	$3FF8,$7FFE,$1FF0,$3FFC,$07C0,$1FF8,$0000,$07E0
		dc.w	$0000,$0000
		
pal_ToPointer:	dc.w	$0000,$0000
		dc.w	$8000,$0000,$7000,$B000,$3C00,$4C00,$3F00,$4300
		dc.w	$1FC0,$20C0,$1FC0,$2000,$0F00,$1100,$0D80,$1280
		dc.w	$04C0,$0940,$0440,$0880,$0000,$0000,$7000,$0000
		dc.w	$2300,$0000,$2480,$0000,$2480,$0000,$2300,$0000
		dc.w	$0000,$0000

pal_PickPointer:
		dc.w	$0000,$0000
		dc.w	$8000,$0000,$4000,$0000,$2000,$0000,$1600,$0000
		dc.w	$0900,$0600,$1280,$0D00,$1440,$0F80,$0EA0,$0740
		dc.w	$0710,$03E0,$03A8,$01D0,$01C8,$00F0,$00F0,$0060
		dc.w	$0068,$0000,$0005,$0000,$0002,$0000,$0004,$0000
		dc.w	$0000,$0000

		section	logo,data_p
		incdir	sources:converter/
chunkylogo:
		incbin	logo.packed
		
