; +------------------------+
; | 'yin.s' Bumpmap Effect |
; +------------------------+------------------------------------------+


YIN_WAITDELAY	= 50*20



YIN_INT	;-- Init CoperList --
	Lea	$DFF000,a5
	Move.w	#$0180,DMACON(a5)		; Kill DMA: BPLEN | COPEN

	_LoadPlanes	#YIN_pln, YIN_CL,  4, 40*128	; Init Plane Ptrs
	_LoadPlanes	#YIN_bg,  YIN_c2,  4, 40*128	; (Background Image Data)
	_LoadPalette24	PAL_black,  YIN_CLp, 8		; Init Palette
	_WaitTOP
	_LoadCList	YIN_CL				; Show CopperList
	Move.w	#$8380,DMACON(a5)		; DMAEN | BPLEN | COPEN


	Clr.w	INT_Timer1


	; -- THE LOOP --


.YIN_lp	;-- FADE IN (IF NEEDED) --
	Move.w	INT_Timer1,d1
	Lsl.w	#1,d1		; Fade Speed
	Cmp.w	#255,d1		; <fade_lev>
	Bgt.s	.nofin

	Move.w	#255, d0	; <cols-1>
	Lea	PAL_black,a0	; <pal1>
	Lea	YIN_pal,a1	; <pal2>
	Lea	PAL_temp,a2	; <temp_pal>
	Jsr	__FadePalette24

	_LoadPalette24	PAL_temp, YIN_CLp, 8

.nofin

	;--( Fade-Out if needed )--
	Move.w	INT_Timer1,d1
	Neg.w	d1
	Add.w	#YIN_WAITDELAY,d1
	Lsl.w	#1,d1		; Fade Speed
	Cmp.w	#255,d1
	Bgt.s	.nofout

	Move.w	#255, d0	; <cols-1>
	Lea	PAL_black,a0	; <pal1>
	Lea	YIN_pal,a1	; <pal2>
	Lea	PAL_temp,a2	; <temp_pal>
	Jsr	__FadePalette24

	_LoadPalette24	PAL_temp, YIN_CLp, 8
.nofout

	; -- DO EFFECT (texture move) --
	Lea	YIN_map,a0		; Distortion Map
	Lea	YIN_img,a1		; Image Data
	Lea	YIN_cbf,a2		; Chunky Buffer

	Lea	SINE,a3
	Move.w	YIN_xa,d0
	Move.w	YIN_ya,d1
	Add.w	#7,d0
	Add.w	#5,d1
	And.w	#$03FF,d0
	And.w	#$03FF,d1
	Move.w	d0,YIN_xa
	Move.w	d1,YIN_ya

	Move.w	0(a3,d0.w*2),d0
	Asr.w	#4,d0			; +/- 1024 -> +/- 64
	Add.w	#64,d0
	Mulu	#320,d0

	Move.w	0(a3,d1.w*2),d1
	Muls	#80,d1
	Asr.l	#8,d1
	Asr.l	#2,d1			; +/- 1024  -> +/- 80
	Add.l	#80,d1
	Add.l	d1,d0
	Lea	0(a1,d0.l),a1



	;-- MOVE IMAGE/Map --
	Move.w	YIN_aa,d0
	Add.w	#9,d0
	And.w	#$03FF,d0
	Move.w	d0,YIN_aa

	Move.w	0(a3,d0.w*2),d0
	Muls	#26,d0
	Asr.l	#8,d0
	Asr.w	#2,d0			; +/1 1024 -> +/- 26
	Add.w	#26,d0
	Move.w	d0,d1
	Mulu	#40,d0

	Mulu	#640,d1			; Move Distort Map
	Lea	0(a0,d1.l),a0

	Move.l	a0,-(sp)
	Lea	YIN_c2,a0
	Add.l	#YIN_bg,d0
	Moveq.w	#4,d1
	Move.w	#40*128,d2
	Jsr	__LoadPlanes
	Move.l	(sp)+,a0

	Move.w	#(160*76)-1,d0
.lp	Move.l	(a0)+,d2
	Move.b	0(a1,d2.l),(a2)+
	Dbra	d0,.lp


	_WaitVBL

	; -- DO C2P --
	Lea	YIN_cbf,a0
	Lea	YIN_pln,a1
	Lea	CHUNKY,a2
	Move.l	#(160*76/8)-1,d0
	Jsr	c2p16

	; -- LOOP IT --

	Cmp.w	#YIN_WAITDELAY,INT_Timer1	; Time up yet?
	Bgt.s	.endyin

	Tst.w	EXIT
	Beq.s	.YIN_lp

	; -- QUIT --

.endyin
	Move.w	#$0180,DMACON(a5)
	_WaitVBL

	Rts

	; +-------------------------------------------+


; +-------+
; | DATAS |	
; +-------+-------------------------------------------+

YIN_xa	Dc.w	0				; Texture Coords
YIN_ya	Dc.w	0

YIN_aa	Dc.w	0				; Lens Y Coord


YIN_pal	incbin	'TLA/YinYang/Main2.PAL'
YIN_map	incbin	'TLA/YinYang/YMap2.RAW'
YIN_img	incbin	'TLA/YinYang/Yin-Yang.CNK'




	section	'PlanarDisplay',BSS_C
YIN_pln	Ds.b	40*128*4			; Planar Display (320x128x4)

	section	'MoreData',BSS
YIN_cbf	Ds.b	160*76				; ChunkyBuffer



	; +-------------------------------------------+

	section	'YinYang CList',DATA_C
YIN_CL	Dc.w	BPL0PTH,0,BPL0PTL,0,BPL1PTH,0,BPL1PTL,0
	Dc.w	BPL2PTH,0,BPL2PTL,0,BPL3PTH,0,BPL3PTL,0
YIN_c2	Dc.w	BPL4PTH,0,BPL4PTL,0,BPL5PTH,0,BPL5PTL,0
	Dc.w	BPL6PTH,0,BPL6PTL,0,BPL7PTH,0,BPL7PTL,0

	Dc.w	DDFSTRT,$38,DDFSTOP,$D0,DIWSTRT,$2C81,DIWSTOP,$2CC1
	Dc.w	BPL1MOD,-48,BPL2MOD,-8

	Dc.w	BPLCON0,$0201,BPLCON1,0,BPLCON2,0,BPLCON4,0
	Dc.w	FMODE,$4003			; ScanDouble + FastLargeGrab

YIN_CLp	ColBank	8				; 256 Colours

	Dc.w	$6007,$FFFE,BPLCON0,$0211
	Dc.w	$F807,$FFFE,BPLCON0,$0201

	Dc.w	$FFFF,$FFFE

YIN_bg	incbin	'TLA/YinYang/Yin_BG3.RAW'
