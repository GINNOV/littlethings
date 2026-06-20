;APS0000026F00000BB30000000000000000000000000000000000000000000000000000000000000000
	incdir	includes:

	include	lvos.i
	include	lvo/mrq_lib.i
	include	exec/exec.i
	include	graphics/gfx.i
	include	intuition/intuition.i


	section	code,code_p

szer=640
wys=512
x_offs=0
y_offs=0


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
;-------
	move.l	4,a6
	move.l	#2*(szer*wys),d0
	move.l	#MEMF_FAST+MEMF_CLEAR,d1
	jsr	_LVOAllocVec(a6)
	tst.l	d0
	beq.w	_stupid_error
	move.l	d0,chunky
	add.l	#(szer*wys),d0
	move.l	d0,bitpl

	move.l	mrqbase,a6
	bsr.w	opensc



	lea	cun,a0		;úródîo
	move.l	bitpl,a1	;cel
	move.l	#szer,d0	;szerokoôê w pikselach
	move.l	#wys,d1		;wysokoôê w pikselach

	move.w	#$01,Precc(a5)  ;wîâczenie superwolnego c2p
	jsr	_LVOC2P(a6)
	clr.w	Precc(a5)	;wyîâczenie superwolnego c2p

	move.l	bitpl,a0	;úródîo
	move.l	chunky,a1	;cel
	move.l	#szer,d0	;szerokoôê w pikselach
	move.l	#wys,d1		;wysokoôê w pikselach
	jsr	_LVOP2C(a6)

	move.l	#szer,d0
	move.l	#wys,d1
	move.l	#0,d2
	move.l	#0,d3

	move.l	chunky,a0
	jsr	_LVOC2P(a6)

	bsr.w	put_txt			;wyôwietlenie tekstów informacyjnych

	move.l	screenbase,a0
	move.l	s_UserPort(a0),a0
wait	
	jsr	_LVOGetMessage(a6)	;pobranie wiadomoôci z okna

	move.l	d0,a1
	move.l	im_Class(a1),d0
	cmp.l	#IDCMP_RAWKEY,d0
	bne.b	wait

_cs_sc	move.l	screenbase,a0
	jsr	_LVOMCloseScreen(a6)

_ext	move.l	lib_base,a0
	jsr	_LVOMisterQCleanUp(a6)	;zwolnienie struktur,tablic, itp
	move.l	4,a6
	move.l	chunky,a1
	jsr	_LVOFreeVec(a6)
	move.l	mrqbase,a1
	jsr	_LVOCloseLibrary(a6)
;-------
_stupid_error
	moveq	#$00,d0
	rts
;-------
opensc	lea	cun,a0
	move.l	a0,chunky_buffer
	lea	pal,a0
	move.l	a0,paleta

	move.l	#szer,d0
	move.l	#wys,d1
	moveq	#$00,d2
	move.l	paleta,a0
	jsr	_LVOMOpenScreen(a6)	;otwarcie ekranu

	tst.l	d0
	beq.w	_ext
	move.l	d0,screenbase
	rts
;-------
put_txt	move.w	#$ff,_kolor0(a5)
	move.w	#$00,_kolor1(a5)

	lea	szerok,a0
	move.l	#$00,d0
	move.l	#10,d1
	jsr	_LVOWyswTXT(a6)

	move.l	#szer,d0
	jsr	_LVODecConvert(a6)
	
	move.l	tabdec2(a5),a0
	move.l	#140,d0
	move.l	#10,d1

	jsr	_LVOWyswTXT(a6)

	move.l	#szer,d0
	jsr	_LVOHexConvert(a6)

	move.l	tabhex1(a5),a0
	
	move.l	#250,d0
	move.l	#10,d1

	jsr	_LVOWyswTXT(a6)

	move.l	#szer,d0
	jsr	_LVORomanConvert(a6)

	move.l	tabroman1(a5),a0
	
	move.l	#320,d0
	move.l	#10,d1

	jsr	_LVOWyswTXT(a6)

;-------

	lea	wysok,a0
	move.l	#$00,d0
	move.l	#20,d1
	jsr	_LVOWyswTXT(a6)	

	move.l	#wys,d0
	jsr	_LVODecConvert(a6)

	move.l	tabdec2(a5),a0
	move.l	#140,d0
	move.l	#20,d1

	jsr	_LVOWyswTXT(a6)

	move.l	#wys,d0
	jsr	_LVOHexConvert(a6)

	move.l	tabhex1(a5),a0
	
	move.l	#250,d0
	move.l	#20,d1

	jsr	_LVOWyswTXT(a6)

	move.l	#wys,d0
	jsr	_LVORomanConvert(a6)

	move.l	tabroman1(a5),a0
	
	move.l	#320,d0
	move.l	#20,d1

	jmp	_LVOWyswTXT(a6)
;-------
mrqbase		dc.l	$00
lib_base	dc.l	$00
screenbase	dc.l	$00
paleta		dc.l	$00
chunky_buffer	dc.l	$00
chunky		dc.l	$00
bitpl		dc.l	$00
;-------
szerok		dc.b	'Szerokoôê ekranu: ',0
wysok		dc.b	'Wysokoôê ekranu: ',0
;-------
mrqlib		dc.b	'mrq.library',0
;-------
pal	incbin	gfx:widok_640\512.rgb32
cun	incbin	gfx:widok_640\512.chunky
;-------






