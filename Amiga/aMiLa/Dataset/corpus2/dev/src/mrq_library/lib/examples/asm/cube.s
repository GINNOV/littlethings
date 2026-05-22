;APS0000069E000000000000000000000000000000000000000000000000000000000000000000000000
	incdir	includes:

	include	lvos.i
	include	lvo/mrq_lib.i
	include	exec/exec.i
	include	intuition/intuition.i


;proszem nie pszejmowaê siem jenzykiem ;D
;nie ma to jak Wap :D


;--------------------------------------
szer	equ	320
wys	equ	256

		rsreset
x		rs.w	1
y		rs.w	1
u		rs.w	1
v		rs.w	1

;--------------------------------------
	section	code,code_p



;-------				;alokacja pamiëci na tablice,
	move.l	4,a6			;bufory
	moveq	#$00,d0
	lea	mrqlib,a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,mrqbase
	tst.l	d0
	beq.w	_stupid_error

	move.l	#MEMF_FAST+MEMF_CLEAR,d1
	move.l	#(szer*wys)*2,d0
	jsr	_LVOAllocVec(a6)
	tst.l	d0
	beq.w	_stupid_error
	move.l	d0,chunky_buffer

	move.l	d0,s_adr1
	add.l	#szer*wys,d0
	move.l	d0,s_adr1e

	move.l	#MEMF_FAST+MEMF_CLEAR,d1
	move.l	#(512*10)*4,d0
	jsr	_LVOAllocVec(a6)
	tst.l	d0
	beq.w	_stupid_error
	move.l	d0,lookup

	move.l	#MEMF_FAST+MEMF_CLEAR,d1
	move.l	#(65536*4)*2,d0
	jsr	_LVOAllocVec(a6)
	tst.l	d0
	beq.w	_stupid_error
	move.l	d0,multab1

	add.l	#65536*4,d0
	move.l	d0,multab

	move.l	#MEMF_FAST+MEMF_CLEAR,d1
	move.l	#(16384*4)*2,d0
	jsr	_LVOAllocVec(a6)
	tst.l	d0
	beq.w	_stupid_error
	move.l	d0,right_clip_tab1
	add.l	#16384*4,d0
	move.l	d0,right_clip_tab
;-------
	move.l	mrqbase,a6
	jsr	_LVOMisterQInit(a6)	;inicjalizacja biblioteki, struktur
	tst.l	d0
	beq.w	_eext


	move.l	d0,lib_base
	move.l	lib_base,a5
;-------				;zaîadowanie tekstur
	lea	teksturka,a0
	move.l	#MEMF_FAST+MEMF_CLEAR,d0
	jsr	_LVOMLoadFile(a6)
	move.l	d0,texture1

	lea	paletka,a0
	move.l	#MEMF_FAST+MEMF_CLEAR,d0
	jsr	_LVOMLoadFile(a6)
	move.l	d0,paleta
;-------
	move.l	#szer,d0
	move.l	#wys,d1
	moveq	#$00,d2
	move.l	paleta,a0

	jsr	_LVOMOpenScreen(a6)	;otwarcie ekranu


	tst.l	d0
	beq.w	_ext
	move.l	d0,screenbase
	move.l	d0,a0
	move.l	s_Win_Base(a0),a0
	move.l	wd_UserPort(a0),a0
	move.l	a0,userport

	bsr.w	conv_multab

loop

	bsr.w	ramka
	move.l	d0,-(sp)

	jsr	_LVOGetFPS(a6)
	jsr	_LVODecConvert(a6)
	move.l	#0,d0
	move.l	#10,d1

	move.l	tabdec2(a5),a0
	jsr	_LVOWyswTXT(a6)


	move.l	(sp)+,d0
	tst.l	d0
	beq.b	loop	



	move.l	lib_base,a5
	move.l	mrqbase,a6

	move.l	screenbase,a0
	jsr	_LVOMCloseScreen(a6)

	move.l	paleta,a0
	jsr	_LVOMFreeFile(a6)
	move.l	texture1,a0
	jsr	_LVOMFreeFile(a6)

_ext	move.l	lib_base,a0
	jsr	_LVOMisterQCleanUp(a6)	;zwolnienie struktur,tablic, itp

_eext	move.l	4,a6
	move.l	chunky_buffer,a1
	jsr	_LVOFreeVec(a6)
	move.l	lookup,a1
	jsr	_LVOFreeVec(a6)
	move.l	multab1,a1
	jsr	_LVOFreeVec(a6)
	move.l	right_clip_tab1,a1
	jsr	_LVOFreeVec(a6)
	move.l	mrqbase,a1
	jsr	_LVOCloseLibrary(a6)
;-------
_stupid_error
	moveq	#$00,d0
	rts
;-------
ramka	bsr.w   cube

	move.l	lib_base,a5
	move.l	mrqbase,a6
	move.l	screenbase,a0
	move.l	#szer,d0
	move.l	#wys,d1
	move.l	#0,d2
	move.l	#0,d3

	jsr	_LVODoubleBuffer(a6)

	move.l	chunky_buffer,a0
	jsr	_LVOC2P(a6)

	tst.w	cs
	bne.b	_no_cs

	move.l	#(szer*wys)/32,d0	;czyszczenie bufora chunky
	move.l	chunky_buffer,a0
kk	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbf	d0,kk

_no_cs

	move.l	userport,a0
	jsr	_LVOGetDynamicMessage(a6)
	move.l	d0,a0
	move.l	im_Class(a0),d0
	cmp.l	#IDCMP_RAWKEY,d0
	beq.b	_key1
	moveq	#$00,d0
	rts
_key1	
	move.w	im_Code(a0),d0
	and.l	#$000000ff,d0
	cmp.b	#95,d0		;wyjôcie przez HELP
	beq.b	_cs_sc
	cmp.b	#80,d0		;f1 - wîâczenie/wyîâczenie czyszczenia
	bne.b	_clear
	eor.w	#$ff,cs
_clear
	moveq	#$00,d0
	rts
_cs_sc	moveq	#$01,d0
	rts
;-------
conv_multab
	move.l	multab,a0
	move.l	multab,a1
	move.l	#65536-2,d7
	move.l	#65535/1,d0
	moveq.l	#1,d2

	move.l	#0,(a0)+
	move.l	#0,-(a1)

.lp	move.l	d0,d1
	divs.l	d2,d1
	move.l	d1,(a0)+
	move.l	d1,-(a1)
	addq.l	#1,d2
	dbf	d7,.lp

							;tutaj generuje tablelke
							;do obcinania do bocznych
							;ramek
		move.l	right_clip_tab,a0
		sub.l	#(8000*2),a0
		moveq	#-1,d0				;tutaj konkretnie do prawej
		move.w	#8000-1,d7
fill_clip_tab_1	move.w	d0,(a0)+			;tutaj "trafimy" z x'em ujemnym
		dbf	d7,fill_clip_tab_1

		move.l	right_clip_tab,a0		;a tutaj nie obcinamy...
		moveq	#0,d0
		move.w	#szer-1,d7
fill_clip_tab_2	move.w	d0,(a0)+
		addq.w	#1,d0
		dbf	d7,fill_clip_tab_2

		move.w	#szer,d0			;a tutaj to juz wyszlismy
		move.w	#8000*2-1,d7			;poza prawom ramke i
fill_clip_tab_3	move.w	d0,(a0)+			;juz nie musimy rysowac
		dbf	d7,fill_clip_tab_3		;linii...

	rts
;-------
cube

	bsr.w	obroty

lo1	=	-$400
hi1	=	$400

	move.l	#lo1,d0
	move.l	#lo1,d1
	move.l	#lo1,d2
	bsr.w	obrot
	move.w	d0,x1
	move.w	d1,y1

	move.l	#lo1,d0
	move.l	#hi1,d1
	move.l	#lo1,d2
	bsr.w	obrot
	move.w	d0,x2
	move.w	d1,y2

	move.l	#hi1,d0
	move.l	#hi1,d1
	move.l	#lo1,d2
	bsr.w	obrot
	move.w	d0,x3
	move.w	d1,y3


	move.w	#1,u1
	move.w	#1,v1
	move.w	#1,u2
	move.w	#256/2-1,v2
	move.w	#256/2-1,u3
	move.w	#256/2-1,v3
	move.l	texture1,a4
	bsr.w	triage

	move.l	#hi1,d0
	move.l	#hi1,d1
	move.l	#lo1,d2
	bsr.w	obrot
	move.w	d0,x1
	move.w	d1,y1

	move.l	#hi1,d0
	move.l	#lo1,d1
	move.l	#lo1,d2
	bsr.w	obrot
	move.w	d0,x2
	move.w	d1,y2

	move.l	#lo1,d0
	move.l	#lo1,d1
	move.l	#lo1,d2
	bsr.w	obrot
	move.w	d0,x3
	move.w	d1,y3


	move.w	#256/2-1,u1
	move.w	#256/2-1,v1
	move.w	#256/2-1,u2
	move.w	#1,v2
	move.w	#1,u3
	move.w	#1,v3
	move.l	texture1,a4
;------
triage

	lea	x1,a0
	lea	x2,a1
	lea	x3,a2

		move.l	a4,_2_map	;zapisz wskaznik textury

		move.w	y(a2),d0	;sortujemy punkty wzgledem y
		cmp.w	y(a0),d0
		bge.b	.swap_1
		exg.l	a2,a0
.swap_1:	move.w	y(a2),d0
		cmp.w	y(a1),d0
		bge.b	.swap_2
		exg.l	a2,a1
.swap_2:	move.w	y(a1),d0
		cmp.w	y(a0),d0
		bge.b	.swap_3
		exg.l	a1,a0
.swap_3:
		move.w	y(a0),d0	;jesli y1=y1 to skoryguj
		cmp.w	y(a1),d0	;y2 i y3 (to przez to ze
		bne.b 	_dd		;mam jakis blad niedokladnosci
		addq.w	#1,y(a1)	;w procedurze. ogolnie to bardzo
		addq.w	#1,y(a2)	;brzydko to zalatwilem
_dd
		move.w	x(a0),d0	;y1=y1 ?
		cmp.w	x(a1),d0
		bne.b	_eed		;jesli tak to sprobuj kontynuowac
		cmp.w	x(a2),d0	;y1=y2=y3?
		beq.b	_ee		;to olej ten trojkont!
_eed

	;teraz licze najdluzszom linie w trujkoncie
	;po jej znaku bede wiedzial z ktorej strony
	;jest najdluzsza linie i co z tego wynika
	;bede mogl wywalic sprawdzanie w innerlopie
	;czy x1>x2 bo zrobie to przed pentlom
	;patrz:)

;-----------------------------------------------------
;              (y2-y1) << 16
;       temp = --------------
;                  y3-y1
;
;       width = temp * (x3-x1) + ((x1-x2) << 16)
;-----------------------------------------------------
		move.w	y(a2),d1		;y3-y1=0
		sub.w	y(a0),d1
		bne.b	mgo_one

_ee						;jesli tak to do widzienia...
		rts
mgo_one
		moveq	#16,d2			;ustaw "wirtualny przecinek"
		move.w	y(a1),d0		;(y2-y1)
		sub.w	y(a0),d0
		ext.l	d0
		asl.l	d2,d0			;(y2-y1)*65536
		ext.l	d1
		divs.l	d1,d0			;[(y2-y1)*65536]/(y3-y1)

		move.w	x(a2),d4		;(x2-x1)
		sub.w	x(a0),d4
		ext.l	d4
		muls.l	d0,d4			;{[(y2-y1)*65536]/(y3-y1)}*(x2-x1)

		move.w	x(a0),d3		;(x1-x2)
		sub.w	x(a1),d3
		ext.l	d3
		asl.l	d2,d3			;(x1-x2)*65536
		add.l	d4,d3			;{[(y2-y1)*65536]/(y3-y1)}*(x2-x1)+(x1-x2)*65536  - uffff...

		move.l	d3,longest		;ok tutaj mamy najdluzszom linie * 65536!

		move.l	multab,a6		;przygotuj tablice dzielenia

		swap.w	d3			;czesc calkowita najdluzszej linii
		tst.w	d3			;zbadaj...
		beq.w	map_exit		;zero? to wypierdalaj

		bpl.w	_right			;dodatnia? to z prawej strony


	;ok tutaj lecom procedurki ktore obliczajom
	;przyrosty dla textur i krawendzi trujkonta
	;som dwie dlatego, ze w zaleznosci od znaku
	;najdluzszej linii wiemy z ktorej strony zn-
	;ajduje sie najdluzsza krawedz wiec wiemy
	;gdzie mozemy sobie odpuscic interpolowanie
	;przyrostu textury, bo przy stalych przyrostach
	;musimy interpolowac tylko z jednej krawendzi
	;- tej po prawej!!! Przy okazji mam za darmo
	;test czy x2<x1...

;-----------------------------------------------------
;	longest edge (a2,a0) on the left 

		move.w	x(a1),d0		;przyrost 1
		sub.w	x(a0),d0
		move.w	y(a1),d1
		sub.w	y(a0),d1
		ext.l	d0
		muls.l	(a6,d1.w*4),d0		;podziel!! (to tak jak -> divs d1.w,d0.l)
		;asl.l	#2,d0
		move.l	d0,right_dx1	;kod samomodyfikujacy sie!!!!!

		move.w	x(a2),d0		;przyrost 2
		sub.w	x(a1),d0
		move.w	y(a2),d1
		sub.w	y(a1),d1
		ext.l	d0
		muls.l	(a6,d1.w*4),d0
		;asl.l	#2,d0
		move.l	d0,right_dx2
		
		move.w	x(a2),d0		;przyrost 3
		sub.w	x(a0),d0
		move.w	y(a2),d1
		sub.w	y(a0),d1
		ext.l	d0
		muls.l	(a6,d1.w*4),d0
		;asl.l	#2,d0
		move.l	d0,left_dx1
		move.l	d0,left_dx2

		*******************
		move.w	u(a2),d0		;przyrosty textury [u]
		sub.w	u(a0),d0
		ext.l	d0
		muls.l	(a6,d1.w*4),d0
		;asl.l	#2,d0
		move.l	d0,left_du1
		move.l	d0,left_du2

		move.w	v(a2),d0		;[v]
		sub.w	v(a0),d0
		ext.l	d0
		muls.l	(a6,d1.w*4),d0
		;asl.l	#2,d0
		move.l	d0,left_dv1
		move.l	d0,left_dv2

		bra	cdeltas
;-----------------------------------------------------
;	longest edge (a2,a0) on the right

_right:						;to samo tylko dla drugiego przypadku!
		move.w	x(a1),d0
		sub.w	x(a0),d0
		move.w	y(a1),d1
		sub.w	y(a0),d1
		ext.l	d0
		muls.l	(a6,d1.w*4),d0
		;asl.l	#2,d0
		move.l	d0,left_dx1 		
		move.l	d1,d6

		move.w	x(a2),d0
		sub.w	x(a1),d0
		move.w	y(a2),d1
		sub.w	y(a1),d1
		ext.l	d0
		muls.l	(a6,d1.w*4),d0
		;asl.l	#2,d0
		move.l	d0,left_dx2
		move.l	d1,d7

		move.w	x(a2),d0
		sub.w	x(a0),d0
		move.w	y(a2),d1
		sub.w	y(a0),d1
		ext.l	d0
		muls.l	(a6,d1.w*4),d0
		;asl.l	#2,d0
		move.l	d0,right_dx1
		move.l	d0,right_dx2

		*******************
		move.w	u(a1),d0
		sub.w	u(a0),d0
		ext.l	d0
		muls.l	(a6,d6.w*4),d0
		;asl.l	#2,d0
		move.l	d0,left_du1

		move.w	u(a2),d0
		sub.w	u(a1),d0
		ext.l	d0
		muls.l	(a6,d7.w*4),d0
		;asl.l	#2,d0
		move.l	d0,left_du2

		move.w	v(a1),d0
		sub.w	v(a0),d0
		ext.l	d0
		muls.l	(a6,d6.w*4),d0
		;asl.l	#2,d0
		move.l	d0,left_dv1

		move.w	v(a2),d0
		sub.w	v(a1),d0
		ext.l	d0
		muls.l	(a6,d7.w*4),d0
		;asl.l	#2,d0
		move.l	d0,left_dv2		


	;tutaj to co czyni te procedurke w miare
	;szybkom - stale delty dla interpolacji
	;textury wewnatrz trujkonta [ponizej wzor]
	;musimy go policzyc dwa razy bo mamy [U,V]

;-----------------------------------------------------
;		Calculate constant deltas
;        
;          (At-Ct)*(By-Cy) - (Bt-Ct)*(Ay-Cy)
;  dt/dx = ---------------------------------
;          (Ax-Cx)*(By-Cy) - (Bx-Cx)*(Ay-Cy)	;<-mianownik jest taki sam dla obu delt [dzieki bogu:)]
;
;-----------------------------------------------------
cdeltas:	;calc dcu

		move.w	u(a0),d0
		sub.w	u(a2),d0
		move.w	y(a1),d1
		sub.w	y(a2),d1
		muls	d1,d0		;(At-Ct)*(By-Cy)
				
		move.w	u(a1),d1
		sub.w	u(a2),d1
		move.w	y(a0),d2
		sub.w	y(a2),d2		
		muls	d2,d1		;(Bt-Ct)*(Ay-Cy)
		sub.l	d1,d0

		move.w	x(a0),d3
		sub.w	x(a2),d3
		move.w	y(a1),d1
		sub.w	y(a2),d1
		muls	d1,d3		;(Ax-Cx)*(By-Cy)

		move.w	x(a1),d1
		sub.w	x(a2),d1
		move.w	y(a0),d2
		sub.w	y(a2),d2		
		muls	d2,d1		;(Bx-Cx)*(Ay-Cy)
		sub.l	d1,d3

		asl.l	#8,d0
		;asl.l	#2,d0
		divs.l	d3,d0
		asl.l	#8,d0
		;asl.l	#8-2,d0
		move.l	d0,dcu		;stale U
	
		move.w	v(a0),d0
		sub.w	v(a2),d0
		move.w	y(a1),d1
		sub.w	y(a2),d1
		muls	d1,d0		;(At-Ct)*(By-Cy)
				
		move.w	v(a1),d1
		sub.w	v(a2),d1
		move.w	y(a0),d2
		sub.w	y(a2),d2		
		muls	d2,d1		;(Bt-Ct)*(Ay-Cy)
		sub.l	d1,d0

		asl.l	#8,d0
		;asl.l	#2,d0
		divs.l	d3,d0
		asl.l	#8,d0	
		;asl.l	#8-2,d0	
		move.l	d0,dcv		;stale V
;-----------------------------------------------------
;	teraz licze tablice interpolacji wewnatrz
;	trujkonta, skoro U,V jest stale to moge
;	calom interpolacje przeliczyc i wjebac do
;	tabelki!!!!

		moveq	#0,d0
		moveq	#0,d1
		move.l	longest(pc),d2		;tabelka musi miec dlugosc
		swap.w	d2			;najdluzszej linii!!!
		tst.w	d2
		bpl.b	len_ok
		neg.w	d2
len_ok		move.l	lookup,a4		
		addq.w	#8,d2
look_up:	
		move.l	d1,d5		;tutaj to co bym robil w innerlopie
		asr.l	#8,d5
		move.l	d0,d3
		swap.w	d3
		move.b	d3,d5

		move.w	d5,(a4)+	;zapisz do tablicy!!

		add.l	dcu(pc),d0	;dodaj przyrosty [U]
		add.l	dcv(pc),d1	;		 [V]
		dbf	d2,look_up
;-----------------------------------------------------
		moveq	#16,d6			;"wirtualny" przecinek

		;ustaw poczontkowe wartosci x,u,v
		;(do nich bedziemy dodawac przyrosty!)

		move.w	x(a0),d0		;setup start x,u,v
		lsl.l	d6,d0
		move.l	d0,left_x
		move.l	d0,right_x		;x ustawione
		
		move.w	u(a0),d0
		lsl.l	d6,d0
		move.l	d0,left_u		;teraz u

		move.w	v(a0),d0
		lsl.l	d6,d0
		move.l	d0,left_v		;i v


		;oblicz pierwsza linie trujkonta

		move.l	chunky_buffer,a6	;pobierz ze stosu adres ekranu
		move.w	y(a0),d0		;y1->d0
		ext.l	d0
		muls.w	#szer,d0		;y1*368+screen (start y)
		add.l	d0,a6
;------------------------------------------------------------------		
		moveq	#16,d6		;"wirtualny" przecinek:)

		;oblicz wysokosci poszczegolnych sekcji trojkonta

		move.w	y(a2),d0		;h2
		sub.w	y(a1),d0
		swap.w	d0

		move.w	y(a1),d0		;h1
		sub.w	y(a0),d0

		lea	left_x(pc),a0
		move.l	right_clip_tab,a1
	
		subq.w	#1,d0		;jesli sekcja 1 ma h=0 to rysuj od drugiej!!
		bmi.w	_h2
;------------------------------------------------------------------
;		a1,a2

	;no to jazda mozemy rysowac!!!!!!!!!!!!!!

h1		cmp.l	s_adr1(pc),a6		;obetnij do gornej ramki!
		blt.b	h1_next_line	
		cmp.l	s_adr1e(pc),a6		;obetnij do dolnej ramki!!
		bge.w	map_exit
	
		movem.l	(a0),d1-d2	;left_x i right_x do rejestrow

		asr.l	d6,d1		;czesc calkowita!!
		asr.l	d6,d2

		cmp.w	#szer,d1	;czy x1>szer? jesli tak to nie rysuj linii
		bgt.b	h1_next_line

		move.l	lookup,a3	;tabela interpolacji do a3

		tst.w	d1		;czy x1 ukemny?
		bpl.b	ok_cmp_1	;nie.
		neg.w	d1		;tak. no to zmien znak!
		move.w	d1,d3
		;asr.w	d3
		lea	(a3,d3.w*2),a3	;adres poczontkowy w tablicy
		moveq	#0,d1		;x1 = 0

ok_cmp_1		
		move.w	(a1,d2.w*2),d2	;obetnij x2 (korzystajac z tabelki)
		bmi.b	h1_next_line	;nastempna linia

		sub.w	d1,d2		;dlugosc linii (x2-x1)
		;asr.w	d2
		bmi.b	h1_next_line
	
		moveq	#0,d4		;teraz pobierz wartosci [U,V]
		move.b	left_v+1(pc),d4	;na krawedziach textury
		lsl.w	#8,d4		;zformuj jednom wartosc w d4
		move.b	left_u+1(pc),d4	; d4=$0000vvuu
		
		lea	(a6,d1.w*1),a5	;adres pierwszego pixela linii na ekranie

		move.l	_2_map(pc),a4	;adres textury -> a4

		lea	(a4,d4.l*2),a4	;dodaj ofset do adresu textury

		moveq	#0,d5		;d5=0

h1_inner	move.w	(a3)+,d5	;pobierz przeliczonom interpolacje
		move.b	(a4,d5.w*2),(a5)+ ;pobierz i postaw pixel!
		;move.b	#-1,(a5)+ ;pobierz i postaw pixel!
		dbf	d2,h1_inner
h1_next_line	


	move.l	(a0),d7
	add.l	left_dx1,d7
	move.l	d7,(a0)

	move.l	4(a0),d7
	add.l	right_dx1,d7
	move.l	d7,4(a0)	;dodaj przyrost do x2

	move.l	8(a0),d7
	add.l	left_du1,d7	;dodaj przyrost do U
	move.l	d7,8(a0)

	move.l	12(a0),d7
	add.l	left_dv1,d7	;dodaj przyrost do V
	move.l	d7,12(a0)


		add.w	#szer,a6		;nastempna linia
		dbf	d0,h1		;puki h!=0



;-------		
;	wszystko ponizej jest identyczne jak przed chwilom
;-------		


_h2		
		swap.w	d0
		tst.w	d0
		bmi.w	map_exit

h2		cmp.l	s_adr1(pc),a6
		blt.b	h2_next_line	
		cmp.l	s_adr1e(pc),a6
		bge.w	map_exit

		movem.l	(a0),d1-d2
	
		asr.l	d6,d1
		asr.l	d6,d2
		
		cmp.w	#szer,d1
		bgt.b	h2_next_line

		move.l	lookup,a3

		tst.w	d1		;left clip
		bpl.b	ok_cmp_2
		neg.w	d1
		move.w	d1,d3
		;asr.w	d3
		lea	(a3,d3.w*2),a3
		moveq	#0,d1
ok_cmp_2	
		move.w	(a1,d2.w*2),d2	;right clip
		bmi.b	h2_next_line

		sub.w	d1,d2
		;asr.w	d2
		bmi.b	h2_next_line

		moveq	#0,d4
		move.b	left_v+1(pc),d4
		lsl.w	#8,d4
		move.b	left_u+1(pc),d4

		lea	(a6,d1.w*1),a5
		
		move.l	_2_map(pc),a4

		lea	(a4,d4.l*2),a4

		moveq	#0,d5
	
h2_inner	move.w	(a3)+,d5	  ;5  cykli na 020
		move.b	(a4,d5.w*2),(a5)+ ;10
		;move.b	#-1,(a5)+ ;10
		dbf	d2,h2_inner	  ;6
					;21 clock ticks.
h2_next_line	


	move.l	(a0),d7
	add.l	left_dx2,d7
	move.l	d7,(a0)

	move.l	4(a0),d7
	add.l	right_dx2,d7
	move.l	d7,4(a0)	;dodaj przyrost do x2

	move.l	8(a0),d7
	add.l	left_du2,d7	;dodaj przyrost do U
	move.l	d7,8(a0)

	move.l	12(a0),d7
	add.l	left_dv2,d7	;dodaj przyrost do V
	move.l	d7,12(a0)



		add.w	#szer,a6		;nastempna linia
		dbf	d0,h2

map_exit	rts

;------
obroty


	lea	sin,a1
	lea	cos,a2

	add.l	#2,alfa
	add.l	#-2,beta
	add.l	#2,gamma

	and.l	#$ff,alfa
	and.l	#$ff,beta
	and.l	#$ff,gamma
	move.l	alfa,d0
	move.l	beta,d1		
	move.l	gamma,d2		
	move.w	(a1,d0.w*2),sinalf	
	move.w	(a2,d0.w*2),cosalf	
	move.w	(a1,d1.w*2),sinbet	
	move.w	(a2,d1.w*2),cosbet	
	move.w	(a1,d2.w*2),singam
	move.w	(a2,d2.w*2),cosgam	

	rts
;--------------------------------------

obrot

	move.w	d1,d3
	move.w	d2,d4
	muls.w	cosalf,d1
	muls.w	sinalf,d4
	muls.w	sinalf,d3
	muls.w	cosalf,d2
	sub.l	d4,d1
	add.l	d3,d2
	asr.l	#8,d1
	asr.l	#8,d2

	move.w	d0,d3
	move.w	d2,d4
	muls.w	cosbet,d0
	muls.w	sinbet,d4
	muls.w	sinbet,d3
	muls.w	cosbet,d2
	sub.l	d4,d0
	add.l	d3,d2
	asr.l	#8,d0
	asr.l	#8,d2

	move.w	d0,d3
	move.w	d1,d4
	muls.w	cosgam,d0
	muls.w	singam,d4
	muls.w	singam,d3
	muls.w	cosgam,d1
	sub.l	d4,d0
	add.l	d3,d1
	asr.l	#8,d0
	asr.l	#8,d1

	move.l	d2,d3
	add.l	#$1000,d2
	asl.l	#8,d0	
	asl.l	#8,d1	
	tst	d2
	bne.b	.zr1
	addq	#1,d2
.zr1	
	divs.w	d2,d0
	divs.w	d2,d1
	add.w	#160,d0
	add.w	#100,d1

	move.b	d3,d2
	lsr.l	#3,d2
	add.b	#$80,d2
	not.b	d2
	rts
;-------
paleta		dc.l	$00
texture1	dc.l	$00
chunky_buffer	dc.l	$00
userport	dc.l	$00
left_dx1	dc.l	$00	;dodaj przyrost do x1
right_dx1	dc.l	$00	;dodaj przyrost do x2
left_du1	dc.l	$00	;dodaj przyrost do U
left_dv1	dc.l	$00	;dodaj przyrost do V
left_dx2	dc.l	$00	;dodaj przyrost do x1
right_dx2	dc.l	$00	;dodaj przyrost do x2
left_du2	dc.l	$00	;dodaj przyrost do U
left_dv2	dc.l	$00	;dodaj przyrost do V
s_adr1		dc.l	$00
s_adr1e		dc.l	$00
lookup		dc.l	$00
multab1		dc.l	$00
multab		dc.l	$00
alfa		dc.l	$00
beta		dc.l	$00
gamma		dc.l	$00
sinalf		dc.w	$00
cosalf		dc.w	$00
sinbet		dc.w	$00
cosbet		dc.w	$00
singam		dc.w	$00
cosgam		dc.w	$00
mrqbase		dc.l	$00
lib_base	dc.l	$00
screenbase	dc.l	$00
right_clip_tab1	dc.l	$00
right_clip_tab	dc.l	$00
;-------
x1		ds.w	$01
y1		ds.w	$01
u1		ds.w	$01
v1		ds.w	$01
x2		ds.w	$01
y2		ds.w	$01
u2		ds.w	$01
v2		ds.w	$01
x3		ds.w	$01
y3		ds.w	$01
u3		ds.w	$01
v3		ds.w	$01
sav_sp		dc.l	$00
longest		dc.l	$00
left_x		dc.l	$00
right_x		dc.l	$00
left_u		dc.l	$00
left_v		dc.l	$00
dcu		dc.l	$00
dcv		dc.l	$00
zn		dc.b	$00
cs		dc.w	$00
_2_map		ds.l	1
;-------
teksturka	dc.b	'gfx:edify_256x256.chunky',0
paletka		dc.b	'gfx:edify_256x256.palete',0
;-------
mrqlib		dc.b	'mrq.library',0
;-------
sin	DC.W	$0000,$0006,$000C,$0012,$0019,$001F,$0025,$002B,$0031,$0038
	DC.W	$003E,$0044,$004A,$0050,$0056,$005C,$0061,$0067,$006D,$0073
	DC.W	$0078,$007E,$0083,$0088,$008E,$0093,$0098,$009D,$00A2,$00A7
	DC.W	$00AB,$00B0,$00B5,$00B9,$00BD,$00C1,$00C5,$00C9,$00CD,$00D1
	DC.W	$00D4,$00D8,$00DB,$00DE,$00E1,$00E4,$00E7,$00EA,$00EC,$00EE
	DC.W	$00F1,$00F3,$00F4,$00F6,$00F8,$00F9,$00FB,$00FC,$00FD,$00FE
	DC.W	$00FE,$00FF,$00FF,$00FF,$0100,$00FF,$00FF,$00FF,$00FE,$00FE
	DC.W	$00FD,$00FC,$00FB,$00F9,$00F8,$00F6,$00F4,$00F3,$00F1,$00EE
	DC.W	$00EC,$00EA,$00E7,$00E4,$00E1,$00DE,$00DB,$00D8,$00D4,$00D1
	DC.W	$00CD,$00C9,$00C5,$00C1,$00BD,$00B9,$00B5,$00B0,$00AB,$00A7
	DC.W	$00A2,$009D,$0098,$0093,$008E,$0088,$0083,$007E,$0078,$0073
	DC.W	$006D,$0067,$0061,$005C,$0056,$0050,$004A,$0044,$003E,$0038
	DC.W	$0031,$002B,$0025,$001F,$0019,$0012,$000C,$0006,$0000,$FFFA
	DC.W	$FFF4,$FFEE,$FFE7,$FFE1,$FFDB,$FFD5,$FFCF,$FFC8,$FFC2,$FFBC
	DC.W	$FFB6,$FFB0,$FFAA,$FFA4,$FF9F,$FF99,$FF93,$FF8D,$FF88,$FF82
	DC.W	$FF7D,$FF78,$FF72,$FF6D,$FF68,$FF63,$FF5E,$FF59,$FF55,$FF50
	DC.W	$FF4B,$FF47,$FF43,$FF3F,$FF3B,$FF37,$FF33,$FF2F,$FF2C,$FF28
	DC.W	$FF25,$FF22,$FF1F,$FF1C,$FF19,$FF16,$FF14,$FF12,$FF0F,$FF0D
	DC.W	$FF0C,$FF0A,$FF08,$FF07,$FF05,$FF04,$FF03,$FF02,$FF02,$FF01
	DC.W	$FF01,$FF01,$FF00,$FF01,$FF01,$FF01,$FF02,$FF02,$FF03,$FF04
	DC.W	$FF05,$FF07,$FF08,$FF0A,$FF0C,$FF0D,$FF0F,$FF12,$FF14,$FF16
	DC.W	$FF19,$FF1C,$FF1F,$FF22,$FF25,$FF28,$FF2C,$FF2F,$FF33,$FF37
	DC.W	$FF3B,$FF3F,$FF43,$FF47,$FF4B,$FF50,$FF55,$FF59,$FF5E,$FF63
	DC.W	$FF68,$FF6D,$FF72,$FF78,$FF7D,$FF82,$FF88,$FF8D,$FF93,$FF99
	DC.W	$FF9F,$FFA4,$FFAA,$FFB0,$FFB6,$FFBC,$FFC2,$FFC8,$FFCF,$FFD5
	DC.W	$FFDB,$FFE1,$FFE7,$FFEE,$FFF4,$FFFA
cos	DC.W	$0100,$00FF,$00FF,$00FF,$00FE,$00FE,$00FD,$00FC,$00FB,$00F9
	DC.W	$00F8,$00F6,$00F4,$00F3,$00F1,$00EE,$00EC,$00EA,$00E7,$00E4
	DC.W	$00E1,$00DE,$00DB,$00D8,$00D4,$00D1,$00CD,$00C9,$00C5,$00C1
	DC.W	$00BD,$00B9,$00B5,$00B0,$00AB,$00A7,$00A2,$009D,$0098,$0093
	DC.W	$008E,$0088,$0083,$007E,$0078,$0073,$006D,$0067,$0061,$005C
	DC.W	$0056,$0050,$004A,$0044,$003E,$0038,$0031,$002B,$0025,$001F
	DC.W	$0019,$0012,$000C,$0006,$0000,$FFFA,$FFF4,$FFEE,$FFE7,$FFE1
	DC.W	$FFDB,$FFD5,$FFCF,$FFC8,$FFC2,$FFBC,$FFB6,$FFB0,$FFAA,$FFA4
	DC.W	$FF9F,$FF99,$FF93,$FF8D,$FF88,$FF82,$FF7D,$FF78,$FF72,$FF6D
	DC.W	$FF68,$FF63,$FF5E,$FF59,$FF55,$FF50,$FF4B,$FF47,$FF43,$FF3F
	DC.W	$FF3B,$FF37,$FF33,$FF2F,$FF2C,$FF28,$FF25,$FF22,$FF1F,$FF1C
	DC.W	$FF19,$FF16,$FF14,$FF12,$FF0F,$FF0D,$FF0C,$FF0A,$FF08,$FF07
	DC.W	$FF05,$FF04,$FF03,$FF02,$FF02,$FF01,$FF01,$FF01,$FF00,$FF01
	DC.W	$FF01,$FF01,$FF02,$FF02,$FF03,$FF04,$FF05,$FF07,$FF08,$FF0A
	DC.W	$FF0C,$FF0D,$FF0F,$FF12,$FF14,$FF16,$FF19,$FF1C,$FF1F,$FF22
	DC.W	$FF25,$FF28,$FF2C,$FF2F,$FF33,$FF37,$FF3B,$FF3F,$FF43,$FF47
	DC.W	$FF4B,$FF50,$FF55,$FF59,$FF5E,$FF63,$FF68,$FF6D,$FF72,$FF78
	DC.W	$FF7D,$FF82,$FF88,$FF8D,$FF93,$FF99,$FF9F,$FFA4,$FFAA,$FFB0
	DC.W	$FFB6,$FFBC,$FFC2,$FFC8,$FFCF,$FFD5,$FFDB,$FFE1,$FFE7,$FFEE
	DC.W	$FFF4,$FFFA,$0000,$0006,$000C,$0012,$0019,$001F,$0025,$002B
	DC.W	$0031,$0038,$003E,$0044,$004A,$0050,$0056,$005C,$0061,$0067
	DC.W	$006D,$0073,$0078,$007E,$0083,$0088,$008E,$0093,$0098,$009D
	DC.W	$00A2,$00A7,$00AB,$00B0,$00B5,$00B9,$00BD,$00C1,$00C5,$00C9
	DC.W	$00CD,$00D1,$00D4,$00D8,$00DB,$00DE,$00E1,$00E4,$00E7,$00EA
	DC.W	$00EC,$00EE,$00F1,$00F3,$00F4,$00F6,$00F8,$00F9,$00FB,$00FC
	DC.W	$00FD,$00FE,$00FE,$00FF,$00FF,$00FF
;--------------------------------------

nazwa	dc.b	'Workbench',0
screenname	dc.b	'kupa',0
