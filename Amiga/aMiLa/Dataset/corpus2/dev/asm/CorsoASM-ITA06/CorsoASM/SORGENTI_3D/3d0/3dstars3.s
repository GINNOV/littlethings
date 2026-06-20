
	section	bau,code_C
;---------------------------------------
j:
	move.l	SP,saveSP

	move.w	#$4000,$dff09a
	move.l	#Copperlist,$dff080		;var e copperlistan?
	move.w	d0,$dff088
	move.w	#0,$dff1fc
* starta DMA'n
	move.w	#$8380,$dff096			;Force copper to start
;---------------------------------------
	bsr.w	FixCopper
	bsr.w	star_init

Raster:
	cmp.b	#$ff,$dff006
	bne.s	Raster
	move.w	#$000f,$dff180
	bsr.w	star
	move.w	#0,$dff180

	btst	#6,$bfe001 ;Vanster
	bne	Raster

;---------------------------------------
Exit:
	bclr	#1,$bfe001
	move.w	#%0000010000000000,$dff096 ;Halv prioritet till Blitter
	lea	graph(pc),a1
	move.l	$4,a6
	jsr	-408(a6)
	move.l	d0,a6
	move.l	38(a6),$dff080
	move.w	#$c000,$dff09a
	moveq	#0,d0
	move.l	SaveSp,SP
	rts
SaveSp: dc.l 0
;---------------------------------------
copperlist:
	dc.l $0100a000,$01020000,$00920038,$009400d0,$008e3881,$0090ffc1
	dc.l $01080000,$010a0000
BPL:
	dc.l $00e00006,$00e20000,$00e40006,$00e62000

;dummy sprites
	dc.l $01200005,$0122fff0,$01240005,$0126fff0,$01280005,$012afff0
	dc.l $012c0005,$012efff0,$01300005,$0132fff0,$01340005,$0136fff0
	dc.l $01380005,$013afff0,$013c0005,$013efff0
	dc.l $01820888,$01840fff,$01860ccc

	dc.l $fffffffe
;---------------------------------------
graph: dc.b 'graphics.library',0
	even
;---------------------------------------
 
	jsr vblt
	move.l	#$60032,$dff054   ;SATT BLIT_D DESTNATION
	move.l	#$60000,$dff050   ;SATT BLIT_A SOURCE
	move.w	#0050,$dff066     ;SATT MODULO TILL 17 _D
	move.w	#0000,$dff064     ;SATT MODULO TILL 17 _A
	move.w	#%0000100000000010,$dff058   ;SATT STORLEK,STARTA BLT
	;	  hhhhhhhhhhwwwwww
	rts

vblt:
	move.w	#$09f0,$dff040   ;USE D,A SATT MINTERM D=A
	move.w	#0,$dff042	  ;O=BLTCON1
	move.w	#$ffff,$dff044
	move.w	#$ffff,$dff046
	move.w	#$8040,$dff096  ;SATT PA BLITTER DMA
	rts
;-------------------------------
FixCopper:
	move.l	#star_bild1,d0
	move.w	d0,BPL+6
	swap	d0
	move.w	d0,BPL+2
	move.l	#star_bild2,d0
	move.w	d0,BPL+14
	swap	d0
	move.w	d0,BPL+10
	rts

Clear_screen:
	btst.b	#14,$DFF002.L
	bne.s	Clear_screen
	move.l	#star_bild1,$DFF054.L
	move.l	#$01F00000,$DFF040.L
	move.l	#$FFFFFFFF,$DFF044.L
	move.l	#$00000000,$DFF064.L
	move.w	#$0000,$DFF074.L
	move.w	#$0f00,$DFF058.L
	rts

star:
	bsr.w	star_clear_screen

	moveq	#0,d6
	lea	star_tabell(pc),a0
	lea	star_clear_tabell(pc),a5

star_loop:			;setter alla stars
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	(a0),d0			;z
	move.w	2(a0),d1		;x
	move.w	4(a0),d2		;y
;-------------------------------
	moveq	#0,d3			;setter dit en stjerna
	moveq	#0,d4
	add.w	oga_till_tv_size_z(PC),d0	;riktig star z
	move.w	oga_till_tv_size_z(PC),d3	;skerm y till d3
	muls.w	d1,d3
	divs.w	d0,d3
	and.l	#$ffff,d3
	move.w	oga_till_tv_size_z(PC),d4	;skerm x till d4
	muls.w	d2,d4
	divs.w	d0,d4
	and.l	#$ffff,d4
	add.w	star_bild_centrum_y(PC),d3	;star till mitten
	add.w	star_bild_centrum_x(PC),d4
	cmp.w	star_bild_size_y(PC),d3	;kollar utanfor skerm
	bhi.w	star_ej_on
	cmp.w	star_bild_size_x(PC),d4
	bhi.w	star_ej_on

	lea	star_bild1(pc),a1
	move.l	d3,d2		;y/80
	asl.w	#6,d3
	asl.w	#4,d2
	add.l	d2,d3
	add.l	d3,a1		;y/80+addr
	move.l	d4,d3
	lsr.l	#3,d3		;dividera med 8
	add.l	d3,a1		;ratt byte
	and.l	#$7,d4		;bort med allt utom de sista
	eor.b	#$0f,d4
	move.l	a1,(a5)+

	cmp.w	star_intenc_1(PC),d0
	blt.s	star_ej_bit_1
	bset.b	d4,(a1)			;setter star bit 1

star_ej_bit_1:
	cmp.w	star_intenc_2(PC),d0
	bgt.s	star_ej_bit_2
	add.l	#star_bild2-star_bild1,a1
	bset.b	d4,(a1)			;setter star bit 2
star_ej_bit_2:
;-------------------------------
star_closer:
	subq.w	#1,(a0)			;flyttar star nermare
	tst.w	(a0)
	bne.s	star_flytt_loop1
	bsr.s	ny_star
star_flytt_loop1:
	addq.w	#6,a0
	addq.w	#1,d6
	cmp.w	antal_star(PC),d6
	bne.w	star_loop
	rts

ny_star:			;ny stjerna
	move.w	star_start_z(PC),(a0)
	move.w	rnd(PC),d0		;{random
	mulu.w	#$3723,d0
	add.w	#$7646,d0
	move.w	d0,rnd			;}
	asr.w	#5,d0			;space size y
	move.w	d0,2(a0)
	move.w	rnd(PC),d0		;{random
	mulu.w	#$3723,d0
	add.w	#$7646,d0
	move.w	d0,rnd			;}
	asr.w	#4,d0			;space size x
	move.w	d0,4(a0)
	rts

random:
	move.w	rnd(PC),d0		;{random
	mulu.w	#$3723,d0
	add.w	#$7646,d0
	move.w	d0,rnd			;}
	rts
RND:
	dc.w $0876

star_ej_on:
	bsr.s	ny_star
	bra.s	star_closer

star_CLEAR_SCREEN:
	lea	star_clear_tabell(pc),a0
	moveq	#0,d0
	move.w	#star_bild2-star_bild1,d1
star_clear_screen_loop:
	move.l	(a0)+,a1
	clr.b	(a1)
	add.l	d1,a1
	clr.b	(a1)
	addq.w	#1,d0
	cmp.w	antal_star(PC),d0
	bne.s	star_clear_screen_loop
	rts

star_init:			;star init
	moveq	#0,d6
	lea	star_tabell(pc),a0
star_init_loop:
	move.w	d6,d0
	mulu.w	#6,d0			;SLUMP START Z  <===--
	move.w	d0,(a0)+
	bsr.s	random			;slump av star y
	asr.w	#5,d0
	move.w	d0,(a0)+
	bsr.s	random			;slump av star x
	asr.w	#5,d0
	move.w	d0,(a0)+
	addq.w	#1,d6
	cmp.w	antal_star(PC),d6
	bne.s	star_init_loop
	moveq	#0,d0
	move.w	star_start_z(PC),d0
	divu.w	#3,d0
	move.w	d0,star_intenc_1
	add.w	d0,d0			; mulu.w #2,d0
	move.w	d0,star_intenc_2
	rts

star_intenc_1:		dc.w 0	;skrivs av init
star_intenc_2:		dc.w 0

oga_till_tv_size_z:	dc.w 3
star_bild_size_x:	dc.w 640
star_bild_size_y:	dc.w 176
star_bild_centrum_x:	dc.w 320
star_bild_centrum_y:	dc.w 88
antal_star:		dc.w 40
star_start_z:		dc.w 100

star_tabell:		dcb.b 40*6,1	;20 stars
star_clear_tabell:	dcb.b 40*8	;20 stars

star_bild1:	dcb.b	176*80,0
star_bild2:	dcb.b	176*80,0

	ds.b	30000

	end

