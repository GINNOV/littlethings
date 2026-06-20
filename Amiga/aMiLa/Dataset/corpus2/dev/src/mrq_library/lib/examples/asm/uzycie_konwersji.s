;APS0000084B000001D1000001D1000001D1000001D1000001D1000001D1000001D1000001D1000001D1
	incdir	includes:

	include	lvos.i
	include	lvo/mrq_lib.i
	include	exec/exec.i
	include	graphics/gfx.i
	include	intuition/intuition.i
	include	libraries/cybergraphics.i
	include	lvo/cybergraphics_lib.i


	section	code,code_p

	move.l	4,a6
	moveq	#$00,d0
	lea	mrqlib,a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,mrqbase
	tst.l	d0
	beq.w	_stupid_error

	move.l	mrqbase,a6
	jsr	_LVOMisterQInit(a6)	;inicjalizacja biblioteki, struktur
	move.l	d0,lib_base
	move.l	lib_base,a5

	move.l	intbase(a5),a6
	lea	0,a0
	lea	window,a1
	jsr	_LVOOpenWindowTagList(a6)
	tst.l	d0
	beq.w	_no_win
	move.l	d0,winbase

	move.l	d0,a0
	move.l	wd_UserPort(a0),userport
	move.l	wd_RastPort(a0),s_RastPort(a5)

_set_t	

	move.l	mrqbase,a6

	move.w	#2,_kolor0(a5)
	move.w	#70,_kolor1(a5)

	move.l	#10,d0
	move.l	#25,d1
	lea	text1,a0
	jsr	_LVOWyswTXT(a6)

	move.l	liczba,d0
	jsr	_LVODecConvert(a6)
	
	move.w	#3,_kolor0(a5)
	move.w	#71,_kolor1(a5)

	move.l	#10,d0
	move.l	#35,d1
	move.l	tabdec1(a5),a0
	jsr	_LVOWyswTXT(a6)

	move.w	#4,_kolor0(a5)
	move.w	#72,_kolor1(a5)

	move.l	#10,d0
	move.l	#45,d1
	move.l	tabdec2(a5),a0
	jsr	_LVOWyswTXT(a6)

	move.l	liczba,d0
	jsr	_LVOHexConvert(a6)
	
	move.w	#5,_kolor0(a5)
	move.w	#73,_kolor1(a5)

	move.l	#10,d0
	move.l	#55,d1
	move.l	tabhex1(a5),a0
	jsr	_LVOWyswTXT(a6)

	move.l	liczba,d0
	jsr	_LVORomanConvert(a6)
	
	move.w	#6,_kolor0(a5)
	move.w	#12,_kolor1(a5)

	move.l	#10,d0
	move.l	#65,d1
	move.l	tabroman1(a5),a0
	jsr	_LVOWyswTXT(a6)

	move.w	#7,_kolor0(a5)
	move.w	#13,_kolor1(a5)

	move.l	#10,d0
	move.l	#75,d1
	lea	text2,a0
	jsr	_LVOWyswTXT(a6)

	move.w	#8,_kolor0(a5)
	move.w	#14,_kolor1(a5)

	move.l	#10,d0
	move.l	#85,d1
	lea	text3,a0
	jsr	_LVOWyswTXT(a6)

_czekaj	move.l	userport,a0
	jsr	_LVOGetMessage(a6)
	move.l	d0,a0
	move.l	im_Class(a0),d0
	cmp.l	#IDCMP_CLOSEWINDOW,d0
	beq.w	_exit
	cmp.l	#IDCMP_RAWKEY,d0
	beq.b	_key
	bra.b	_czekaj
_key	move.w	im_Code(a0),d0
	and.l	#$000000ff,d0
	cmp.b	#64,d0
	beq.w	_exit

	jsr	_LVODecConvert(a6)

	cmp.b	#76,d0
	bne.b	_no_dol

	sub.l	#$01,liczba
	
_no_dol	cmp.b	#77,d0
	bne.b	_no_gor

	add.l	#$01,liczba

_no_gor
	move.l	s_RastPort(a5),a1
	move.l	gfxbase(a5),a6

	move.l	#$00,d0
	jsr	_LVOSetAPen(a6)

	move.l	#10,d0
	move.l	#25,d1
	move.l	#350,d2
	move.l	#110,d3
	jsr	_LVORectFill(a6)

	move.w	#8,_kolor0(a5)
	move.w	#7,_kolor1(a5)

	move.l	#150,d0
	move.l	#85,d1
	move.l	tabdec2(a5),a0

	move.l	mrqbase,a6
	
	jsr	_LVOWyswTXT(a6)

	move.l	#1000,d0
	jsr	_LVORnd(a6)
	jsr	_LVODecConvert(a6)

	move.w	#7,_kolor0(a5)
	move.w	#0,_kolor1(a5)

	move.l	#210,d0
	move.l	#75,d1
	move.l	tabdec2(a5),a0

	jsr	_LVOWyswTXT(a6)
	
	bra.w	_set_t


_exit	move.l	winbase,a0
	move.l	intbase(a5),a6
	jsr	_LVOCloseWindow(a6)
	
_no_win	move.l	lib_base,a0
	jsr	_LVOMisterQCleanUp(a6)	;zwolnienie struktur,tablic, itp
	move.l	4,a6
	move.l	mrqbase,a1
	jsr	_LVOCloseLibrary(a6)
;-------
_stupid_error
	moveq	#$00,d0
_upss1	rts
;-------
mrqbase		dc.l	$00
lib_base	dc.l	$00
winbase		dc.l	$00
liczba		dc.l	$00
userport	dc.l	$00
;-------
window	dc.l	WA_Width,400
	dc.l	WA_Height,150
	dc.l	WA_CloseGadget,1
	dc.l	WA_DragBar,1
	dc.l	WA_DepthGadget,1
	dc.l	WA_IDCMP,IDCMP_MOUSEBUTTONS+IDCMP_MENUPICK+IDCMP_MOUSEMOVE+IDCMP_RAWKEY+IDCMP_CLOSEWINDOW
	dc.l	WA_Activate,1
	dc.l	$00,$00	
;-------
text1	dc.b	'Przyklad uzycia funkcji WyswTXT()',0
text2	dc.b	'Liczba losowa z zakresu 1000',0
text3	dc.b	'Naciôniëty klawisz:',0
;-------
mrqlib		dc.b	'mrq.library',0
;-------

