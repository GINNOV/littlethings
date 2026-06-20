;APS0000040900000F310000000000000000000000000000000000000000000000000000000000000000
	incdir	includes:

	include	lvos.i
	include	lvo/mrq_lib.i
	include	exec/exec.i
	include	graphics/gfx.i
	include	intuition/intuition.i
	include	libraries/cybergraphics.i
	include	lvo/cybergraphics_lib.i


	section	code,code_p

szer=640
wys=480
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
	bsr.w	load_gfx		;zaîadowanie grafiki
	tst.l	d0
	beq.b	_yep

	lea	kupka,a1
	jsr	_LVOMRequest(a6)
	bra.w	_no_sc
;-------
_yep		
	lea	plik,a0			;ôcieûka gdzie
	move.l	#1024,d0		;iloôê
	move.l	#$12345678,a1		;adres skâd
	jsr	_LVOMSaveFile(a6)	;zapisanie 1024 bajtów pliku 

opensc	move.l	#szer,d0
	move.l	#wys,d1
	moveq	#$00,d2
	move.l	paleta,a0
	jsr	_LVOMOpenScreen(a6)	;otwarcie ekranu

	tst.l	d0
	beq.w	_no_sc
	move.l	d0,screenbase

	move.l	#szer,d0
	move.l	#wys,d1
	move.l	#0,d2
	move.l	#0,d3

	move.l 	chunky_buffer,a0

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

_no_sc	move.l	paleta,a0
	jsr	_LVOMFreeFile(a6)
	move.l	chunky_buffer,a0	;zwolnienie pamiëci
	jsr	_LVOMFreeFile(a6)

_ext	move.l	lib_base,a0
	jsr	_LVOMisterQCleanUp(a6)	;zwolnienie struktur,tablic, itp
	move.l	4,a6
	move.l	mrqbase,a1
	jsr	_LVOCloseLibrary(a6)
;-------
_stupid_error
	moveq	#$00,d0
	rts
;-------
load_gfx
	lea	tekst1,a0
	jsr	_LVOAslFILERequest(a6)
	tst.l	d0
	beq.w	_stupid_error1
	move.l	d0,_paleta

	move.l	_paleta,a0
	move.l	#MEMF_FAST+MEMF_CLEAR,d0
	jsr	_LVOMLoadFile(a6)
	tst.l	d0
	beq.w	_stupid_error1
	move.l	d0,paleta

	move.l	_paleta,a0
	jsr	_LVOAslFreeFILERequest(a6)

	lea	tekst2,a0
	jsr	_LVOAslFILERequest(a6)
	tst.l	d0
	beq.w	_stupid_error1
	move.l	d0,_chunky_buffer

	move.l	_chunky_buffer,a0
	move.l	#MEMF_FAST+MEMF_CLEAR,d0
	jsr	_LVOMLoadFile(a6)
	tst.l	d0
	beq.w	_stupid_error1
	move.l	d0,chunky_buffer

	move.l	_chunky_buffer,a0
	jsr	_LVOAslFreeFILERequest(a6)
	moveq	#$00,d0
	rts
_stupid_error1
	moveq	#$01,d0
_upss1	rts
;-------
put_txt	move.w	#$ff,_kolor0(a5)
	move.w	#$00,_kolor1(a5)

	lea	szerok,a0
	move.l	#$00,d0
	move.l	#30,d1
	jsr	_LVOWyswTXT(a6)

	move.l	#szer,d0
	jsr	_LVODecConvert(a6)
	
	move.l	tabdec2(a5),a0
	move.l	#140,d0
	move.l	#30,d1

	jsr	_LVOWyswTXT(a6)

	move.l	#szer,d0
	jsr	_LVOHexConvert(a6)

	move.l	tabhex1(a5),a0
	
	move.l	#250,d0
	move.l	#30,d1

	jsr	_LVOWyswTXT(a6)

	move.l	#szer,d0
	jsr	_LVORomanConvert(a6)

	move.l	tabroman1(a5),a0
	
	move.l	#320,d0
	move.l	#30,d1

	jsr	_LVOWyswTXT(a6)

;-------

	lea	wysok,a0
	move.l	#$00,d0
	move.l	#50,d1
	jsr	_LVOWyswTXT(a6)	

	move.l	#wys,d0
	jsr	_LVODecConvert(a6)

	move.l	tabdec2(a5),a0
	move.l	#140,d0
	move.l	#50,d1

	jsr	_LVOWyswTXT(a6)

	move.l	#wys,d0
	jsr	_LVOHexConvert(a6)

	move.l	tabhex1(a5),a0
	
	move.l	#250,d0
	move.l	#50,d1

	jsr	_LVOWyswTXT(a6)

	move.l	#wys,d0
	jsr	_LVORomanConvert(a6)

	move.l	tabroman1(a5),a0
	
	move.l	#320,d0
	move.l	#50,d1

	jmp	_LVOWyswTXT(a6)
;-------
mrqbase		dc.l	$00
lib_base	dc.l	$00
screenbase	dc.l	$00
paleta		dc.l	$00
chunky_buffer	dc.l	$00
_paleta		dc.l	$00   	
_chunky_buffer	dc.l	$00   	
;-------
tekst1		dc.b	'Wybierz paletë w formacie RGB32()',0
tekst2		dc.b	'Wybierz grafikë w formacie Chunky 640/480',0
kupka		dc.b	'Niestety îadowanie danych nie powiodîo sië :(',0
szerok		dc.b	'Szerokoôê ekranu: ',0
wysok		dc.b	'Wysokoôê ekranu: ',0
;-------
mrqlib		dc.b	'mrq.library',0
;-------
plik		dc.b	'ram:plik',0
;-------




