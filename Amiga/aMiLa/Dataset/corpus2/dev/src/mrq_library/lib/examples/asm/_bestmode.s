;APS000005AD000000000000000000000000000000000000000000000000000000000000000000000000
	incdir	includes:

	include	lvos.i
	include	lvo/mrq_lib.i
	include	exec/exec.i
	include	graphics/gfx.i
	include	intuition/intuition.i


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
	lea	nazwa,a0
	move.l	a6,-(sp)
	move.l	intbase(a5),a6
	jsr	_LVOLockPubScreen(a6)
	add.l	#$2c,d0
	move.l	d0,WB_ViewPort(a5)
	move.l	WB_ViewPort(a5),a0
	move.l	gfxbase(a5),a6
	jsr	_LVOGetVPModeID(a6)	;co mamy w do?
	move.l	(sp)+,a6

	move.l	mrqbase,a6

	move.l	d0,-(sp)
	jsr	_LVOHexConvert(a6)

	move.w	#$00,_kolor1(a5)
	move.w	#$01,_kolor0(a5)

	lea	tryb,a0
	move.l	#$03,d0
	move.l	#30,d1
	jsr	_LVOWyswTXT(a6)
	
	move.w	#$03,_kolor1(a5)
	move.w	#$01,_kolor0(a5)

	move.l	tabhex1(a5),a0

	move.l	#100,d0
	move.l	#30,d1
	jsr	_LVOWyswTXT(a6)

	move.w	#$00,_kolor1(a5)
	move.w	#$01,_kolor0(a5)

	lea	bestmode1,a0
	move.l	#$03,d0
	move.l	#45,d1
	jsr	_LVOWyswTXT(a6)

	move.l	(sp)+,d0
	and.l	#MONITOR_ID_MASK,d0
	move.l	d0,mon_id+4

	move.l	#320,szer1+4
	move.l	#240,wys1+4
	bsr.w	best		;co mamy w d0?
	
	move.w	#$03,_kolor1(a5)
	move.w	#$01,_kolor0(a5)

	move.l	tabhex1(a5),a0
	move.l	#210,d0
	move.l	#45,d1
	jsr	_LVOWyswTXT(a6)

	move.w	#$00,_kolor1(a5)
	move.w	#$01,_kolor0(a5)

	lea	bestmode2,a0
	move.l	#$03,d0
	move.l	#60,d1
	jsr	_LVOWyswTXT(a6)

	move.l	#640,szer1+4
	move.l	#480,wys1+4
	bsr.w	best		;co mamy w d0?

	move.w	#$03,_kolor1(a5)
	move.w	#$01,_kolor0(a5)

	move.l	tabhex1(a5),a0
	move.l	#210,d0
	move.l	#60,d1
	jsr	_LVOWyswTXT(a6)


_czekaj	move.l	userport,a0
	jsr	_LVOGetMessage(a6)
	move.l	d0,a0
	move.l	im_Class(a0),d0
	cmp.l	#IDCMP_CLOSEWINDOW,d0
	beq.w	_exit
	bra.b	_czekaj


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
best	lea	bestmode,a0
	move.l	a6,-(sp)
	move.l	gfxbase(a5),a6
	jsr	_LVOBestModeIDA(A6)
	move.l	(sp)+,a6
	jsr	_LVOHexConvert(a6)
	rts
;-------
mrqbase		dc.l	$00
lib_base	dc.l	$00
winbase		dc.l	$00
liczba		dc.l	$00
userport	dc.l	$00
;-------
window	dc.l	WA_Width,300
	dc.l	WA_Height,100
	dc.l	WA_Left,250
	dc.l	WA_Top,200
	dc.l	WA_CloseGadget,1
	dc.l	WA_DragBar,1
	dc.l	WA_DepthGadget,1
	dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW+IDCMP_RAWKEY
	dc.l	WA_Activate,1
	dc.l	$00,$00	
;-------
bestmode
szer1	dc.l	BIDTAG_NominalWidth,$00
wys1	dc.l	BIDTAG_NominalHeight,$00
	dc.l	BIDTAG_Depth,8
mon_id	dc.l	BIDTAG_MonitorID,$00
	dc.l	$00,$00
;-------
tryb		dc.b	'tryb wb to: ',$00
bestmode1	dc.b	'bestmode (320x200) daje: ',$00
bestmode2	dc.b	'bestmode (640x480) daje: ',$00
;-------
mrqlib		dc.b	'mrq.library',0
;-------
nazwa		dc.b	'Workbench',0
;-------

