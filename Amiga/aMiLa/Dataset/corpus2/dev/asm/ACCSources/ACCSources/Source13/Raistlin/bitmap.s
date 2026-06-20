

       opt c-				   

       include source:include/hardware.i


;Display the picture
piccy
	lea	$dff000,a5		;a5 is hardware base
	move.l	4,a6			;EXEC base
	jsr	-132(a6)		;Forbid!!
	lea	gfxname,a1		;we're use gfx.lib
	moveq.l	#0,d0			;any version
	jsr	-552(a6)		;And OPEN!!
	tst.l	d0			;dit it open?
	beq	quit			;no
	move.l	d0,gfxbase		;save gfx base address

*************************************************************************
;			DO THE INTRO 
*************************************************************************
;set-up picture
	move.l	#dragon,d0		;Address of intro grafix
;bitplane1
	move.w	d0,bp1l+2		;Load bitplane pointers
	swap	d0
	move.w	d0,bp1h+2
	swap	d0
	add.l	#40*256,d0		;Size of bitplanes
;bitplane2
	move.w	d0,bp2l+2
	swap	d0
	move.w	d0,bp2h+2
	swap	d0
	add.l	#40*256,d0
;bitplane3
	move.w	d0,bp3l+2
	swap	d0
	move.w	d0,bp3h+2
	swap	d0
	add.l	#40*256,d0
;bitplane4
	move.w	d0,bp4l+2
	swap	d0
	move.w	d0,bp4h+2
	swap	d0
	add.l	#40*256,d0
;bitplane5
	move.w	d0,bp5l+2
	swap	d0
	move.w	d0,bp5h+2
	
;sprite 1
	move.l	#a1a,d0
	move.w	d0,spl1+2
	swap	d0
	move.w	d0,sph1+2
;sprite 2
	move.l	#a1aa,d0
	move.w	d0,spl2+2
	swap	d0
	move.w	d0,sph2+2

	move.l	#copper,cop1lch(a5)	;Load copper
	clr.w	copjmp1(a5)		;Run copper list


wait	btst	#6,$bfe001		;Test for LMP
	bne	wait

****************************************************************************
;		CLEAN-UP & BYE,BYE!!
****************************************************************************
clean_up
	move.w	#$83e0,dmacon(a5)
	move.l	gfxbase,a1	
	move.l	38(a1),cop1lch(a5)	;Restore system copper
	move.w	#$0,copjmp1(a5)		;& run sys copper
	move.l	4,a6			;EXEC base
	jsr	-138(a6)		;Permit!!
	move.l	gfxbase,a1		;gfx to close
	jmp	-414(a6)		;and close!!
	move.l	#dragonend,d0	        ;End address Of module in d0
	move.l	#dragon,a0	        ;Start address of module in a0
LOOPY1	move.l	#0,(a0)+	        ;Wipe long word & increment a0
	cmp.l	d0,a0		        ;Are we at end of module?
	blt	loopy1		        ;No
quit	rts				;BYE!BYE!

************************************************************************
;			 COPPER LIST
************************************************************************
	section	copperlist,code_c
copper	
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon0,%0101001000000000
	dc.w	bplcon1,$0

;colours
	dc.w	color00,$000,color01,$200,color02,$400,color03,$040
	dc.w	color04,$221,color05,$421,color06,$233,color07,$711
	dc.w	color08,$642,color09,$940,color10,$644,color11,$03b
	dc.w	color12,$654,color13,$15b,color14,$a34,color15,$42b
	dc.w	color16,$864,color17,$26c,color18,$a64,color19,$876
	dc.w	color20,$988,color21,$49d,color22,$d95,color23,$bc4
	dc.w	color24,$ba7,color25,$ba9,color26,$ed7,color27,$cbb
	dc.w	color28,$adc,color29,$dca,color30,$dec,color31,$ffe

bp1h	dc.w	bpl1pth,$0
bp1l	dc.w	bpl1ptl,$0
bp2h	dc.w	bpl2pth,$0
bp2l	dc.w	bpl2ptl,$0
bp3h	dc.w	bpl3pth,$0
bp3l	dc.w	bpl3ptl,$0
bp4h	dc.w	bpl4pth,$0
bp4l	dc.w	bpl4ptl,$0
bp5h	dc.w	bpl5pth,$0
bp5l	dc.w	bpl5ptl,$0


sph1	dc.w	spr0pth,$0
spl1	dc.w	spr0pth,$0
sph2	dc.w	spr1pth,$0
spl2	dc.w	spr1pth,$0

	dc.w	$ffff,$fffe






a1a	dc.w	$4040,$6000	SPRxPOS,SPRxCTL
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0001,$0001
	dc.w	$0003,$0003
	dc.w	$0001,$0001
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0001,$0001
	dc.w	$0001,$0001
	dc.w	$0003,$0002
	dc.w	$0007,$0005
	dc.w	$0007,$0005
	dc.w	$000f,$000a
	dc.w	$001f,$0011
	dc.w	$001e,$0016
	dc.w	$0038,$0028
	dc.w	$0070,$0070
	dc.w	$01c0,$01c0
	dc.w	$0700,$0700
	dc.w	$fc00,$fc00
	dc.w	$0000,$0000	Sprite End

a1aa	dc.w	$4040,$6080	SPRxPOS,SPRxCTL
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0001,$0001
	dc.w	$0002,$0003
	dc.w	$0001,$0001
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0001,$0001
	dc.w	$0001,$0001
	dc.w	$0003,$0003
	dc.w	$0006,$0007
	dc.w	$0006,$0007
	dc.w	$000d,$000f
	dc.w	$001f,$001f
	dc.w	$001e,$001e
	dc.w	$0038,$0038
	dc.w	$0070,$0070
	dc.w	$01c0,$01c0
	dc.w	$0700,$0700
	dc.w	$fc00,$fc00
	dc.w	$0000,$0000	Sprite End

a1b	dc.w	$4050,$6000	SPRxPOS,SPRxCTL
	dc.w	$0000,$0000
	dc.w	$0078,$0078
	dc.w	$00fe,$0086
	dc.w	$01ff,$0179
	dc.w	$03ff,$0286
	dc.w	$03c7,$0281
	dc.w	$03c3,$0283
	dc.w	$63f3,$62c3
	dc.w	$e3ff,$a231
	dc.w	$f1ff,$d1cc
	dc.w	$7a7f,$6a72
	dc.w	$3eff,$36dd
	dc.w	$9cff,$9ce6
	dc.w	$cdff,$4d9b
	dc.w	$fb9f,$bb05
	dc.w	$f78f,$f705
	dc.w	$6f87,$6c02
	dc.w	$5f8f,$5c05
	dc.w	$bf9e,$bf0a
	dc.w	$9d9e,$9f0a
	dc.w	$59fc,$5fd4
	dc.w	$663c,$7ff4
	dc.w	$083c,$3ff4
	dc.w	$177c,$78d4
	dc.w	$00bf,$1f6b
	dc.w	$002f,$1fe4
	dc.w	$0027,$1fe3
	dc.w	$107b,$1fc0
	dc.w	$38ff,$2ff8
	dc.w	$3fff,$2f07
	dc.w	$7fff,$52f8
	dc.w	$7fe7,$52a7
	dc.w	$7fe0,$5520
	dc.w	$ffc0,$a541
	dc.w	$ffc1,$aa42
	dc.w	$ff81,$5482
	dc.w	$ff00,$6901
	dc.w	$f600,$d200
	dc.w	$fc00,$a201
	dc.w	$c200,$7d01
	dc.w	$fa01,$8502
	dc.w	$f400,$0a03
	dc.w	$0c00,$f200
	dc.w	$7e00,$8100
	dc.w	$2d00,$52c0
	dc.w	$30c0,$4f20
	dc.w	$7fe0,$8010
	dc.w	$0000,$fff0
	dc.w	$0000,$0000	Sprite End

a1bb	dc.w	$4050,$6080	SPRxPOS,SPRxCTL
	dc.w	$0000,$0000
	dc.w	$0078,$0078
	dc.w	$00fe,$00fe
	dc.w	$0187,$01ff
	dc.w	$0301,$03ff
	dc.w	$0300,$03ff
	dc.w	$0300,$03ff
	dc.w	$6301,$63ff
	dc.w	$a3c1,$e3ff
	dc.w	$91f0,$f1ff
	dc.w	$4a7c,$7bff
	dc.w	$247e,$3fff
	dc.w	$9c5f,$9fff
	dc.w	$4887,$cfff
	dc.w	$3903,$ffff
	dc.w	$b203,$ffff
	dc.w	$6401,$7fff
	dc.w	$4803,$7fff
	dc.w	$9e06,$fffe
	dc.w	$8f06,$fffe
	dc.w	$47cc,$7ffc
	dc.w	$5fec,$7ffc
	dc.w	$3fec,$3ffc
	dc.w	$78cc,$78fc
	dc.w	$1f67,$1f7f
	dc.w	$1fe3,$1fff
	dc.w	$1fe0,$1fff
	dc.w	$1fc0,$1fff
	dc.w	$3f80,$3fff
	dc.w	$37f8,$3fff
	dc.w	$61ff,$7fff
	dc.w	$61e7,$7fe7
	dc.w	$63e0,$7fe0
	dc.w	$c3c0,$ffc0
	dc.w	$c7c0,$ffc0
	dc.w	$8f80,$ff80
	dc.w	$9f00,$ff00
	dc.w	$3e00,$fe00
	dc.w	$7c00,$fc00
	dc.w	$c000,$c000
	dc.w	$8000,$8000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$1200,$1200
	dc.w	$0f00,$0f00
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000	Sprite End

	dc.w	$0000,$0000	SPRxPOS,SPRxCTL
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$8000,$8000
	dc.w	$c000,$4000
	dc.w	$e000,$a000
	dc.w	$f000,$d000
	dc.w	$f800,$6800
	dc.w	$f800,$a800
	dc.w	$fc00,$f400
	dc.w	$fc00,$7400
	dc.w	$fc00,$f400
	dc.w	$fc00,$3c00
	dc.w	$fc00,$c400
	dc.w	$fc00,$ac00
	dc.w	$fc00,$c400
	dc.w	$fc00,$fc00
	dc.w	$7c00,$7c00
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$8000,$8000
	dc.w	$c000,$4000
	dc.w	$e000,$a000
	dc.w	$f000,$d000
	dc.w	$f800,$e800
	dc.w	$f800,$6800
	dc.w	$f800,$a800
	dc.w	$7c00,$4600
	dc.w	$0200,$fd00
	dc.w	$fa00,$0500
	dc.w	$f400,$0a00
	dc.w	$0800,$f400
	dc.w	$7800,$8400
	dc.w	$b400,$4b00
	dc.w	$c300,$3c80
	dc.w	$ff80,$0040
	dc.w	$0000,$ffc0
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000	Sprite End

	dc.w	$0000,$0000	SPRxPOS,SPRxCTL
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$8000,$8000
	dc.w	$c000,$c000
	dc.w	$6000,$e000
	dc.w	$3000,$f000
	dc.w	$9800,$f800
	dc.w	$d800,$f800
	dc.w	$ec00,$fc00
	dc.w	$0c00,$fc00
	dc.w	$0c00,$fc00
	dc.w	$fc00,$fc00
	dc.w	$c400,$c400
	dc.w	$ac00,$ac00
	dc.w	$c400,$c400
	dc.w	$bc00,$fc00
	dc.w	$7c00,$7c00
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$8000,$8000
	dc.w	$c000,$c000
	dc.w	$6000,$e000
	dc.w	$3000,$f000
	dc.w	$1800,$f800
	dc.w	$9800,$f800
	dc.w	$d800,$f800
	dc.w	$7c00,$7c00
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$4800,$4800
	dc.w	$3c00,$3c00
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000	Sprite End






gfxname	dc.b	'graphics.library',0		;Load gfx lib
	even
gfxbase	dc.l	0				;Gfx base address goes here
dragon	incbin	source:bitmaps/dragonlogo.r
dragonend
