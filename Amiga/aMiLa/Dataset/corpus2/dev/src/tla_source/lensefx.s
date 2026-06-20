; +----------------------------------------+
; | 'lensefx.s' > Moving Bitmap Under Lens |
; +----------------------------------------+--------------------------+


	; Logo now 160x60

; --+-----------------------+--

LNS_Y		= 76		; # of y lines to do (max 127)
LNS_Time	= 15*50		; Time (in VBL's) for efect

; --+-----------------------+--

	CNOP	0,4

LNS2_INT
	Move.w	#0,LNS_ptn			; Do 'exp' effect Now
	Move.w	#$4201,LNS_bpl+2
	Bra.s	LNS_st

LNS_INT	Move.w	#1,LNS_ptn			; 'Ripple'

LNS_st	;-- Init CoperList --
	Lea	$DFF000,a5

	_LoadPlanes	#LNS_pln, LNS_CL, 5, 40*128	; Init Plane Ptrs
	_LoadPalette24	PAL_black, LNS_CLp, 1		; Init Palette (black)
	_LoadCList	LNS_CL				; Show CopperList
	_WaitTOP
	Move.w	#$8380,DMACON(a5)	; DMAEN | BPLEN | COPEN

	;-- Prepare for effect --
	Lea	LNS_int3,a0		; New interrupt
	Jsr	AddInt3
	Clr.w	INT_Timer1		; Clear a timer
	

	;--+------------------------------------------------+--

.lns_lp


	;--( Fade-In if needed )--
	Move.w	INT_Timer1,d1
	Lsl.w	#1,d1		; Fade Speed
	Cmp.w	#255,d1		; <fade_lev>
	Bgt.s	.nofin

	Move.w	#31, d0		; <cols-1>
	Lea	PAL_black,a0	; <pal1>



	Tst.w	LNS_ptn
	Beq.s	.pal1

	Lea	LNS_pal2,a1
	Bra.s	.paldone

.pal1	Lea	LNS_pal,a1	; <pal2>
.paldone

	Lea	PAL_temp,a2	; <temp_pal>
	Jsr	__FadePalette24

	Move.w	#0,d0
	Lea	PAL_temp,a0	; <palette>
	Lea	LNS_CLp,a1	; <copper palette>
	Jsr	__LoadPalette24
.nofin





	;--( Fade-Out if needed )--
	Move.w	INT_Timer1,d1
	Neg.w	d1
	Add.w	#LNS_Time,d1
	Lsl.w	#1,d1		; Fade Speed
	Cmp.w	#255,d1
	Bgt.s	.nofout

	Move.w	#31, d0		; <cols-1>
	Lea	PAL_black,a0	; <pal1>

	Tst.w	LNS_ptn
	Beq.s	.pal2

	Lea	LNS_pal2,a1
	Bra.s	.pdone

.pal2	Lea	LNS_pal,a1
.pdone
	Lea	PAL_temp,a2	; <temp_pal>
	Jsr	__FadePalette24

	Move.w	#0,d0
	Lea	PAL_temp,a0	; <palette>
	Lea	LNS_CLp,a1	; <copper palette>
	Jsr	__LoadPalette24
.nofout




	;--( Fetch Sine Values )--
	Lea	SINE,a0
	Move.w	LNS_AngX,d0
	Move.w	0(a0,d0.w*2),d0		; X Coord
	Move.w	LNS_AngY,d1
	Move.w	0(a0,d1.w*2),d1		; Y Coord

	;--( X,Y Scaling )--
	Muls	#160,d0
	Asr.l	#8,d0
	Asr.l	#2,d0

	Muls	#16,d1
	Asr.l	#8,d1
	Asr.l	#2,d1

	;--( Rounding, Adding )--
	Add.l	#80,d0			; Final X add
	Divs	#320,d0
	Clr.w	d0
	Swap	d0
	Bpl.s	.xoki
	Neg.w	d0
.xoki
	Sub.l	#6,d1			; Y Centering
	And.l	#$003F,d1

	;--( Do Effect )--

	Tst.w	LNS_ptn
	Beq.s	.normal			; First 'bubble'

	Lea	LNS_bmp2,a0		; Source Bitmap
	Lea	LNS_cbf,a1		; ChunkyBuffer
	Lea	LNS_lns2,a2		; Lens Lookup Table
	Bra.s	.done

.normal	Lea	LNS_bmp,a0		; Source Bitmap
	Lea	LNS_cbf,a1		; ChunkyBuffer
	Lea	LNS_lns,a2		; Lens Lookup Table
.done
;	Lsl.w	#7,d1			; *128
	Mulu	#320,d1			; *160 ;^)
	Add.w	d0,d1
	Add.w	d1,a0			; Start Of Bitmap

	Moveq	#0,d2
	Move.l	d2,d3
	Move.l	d3,d4
	Move.l	d4,d5

	Move.w	#LNS_Y-1,d1		; FOR y IN 0 .. 128 LOOP
.ylp	Move.w	#160/4-1,d0		;   FOR x IN 0 .. 160 LOOP
.xlp	Movem.w	(a2)+,d2-5		;     (Get 4 Pixels)
	Move.b	0(a0,d2.l),(a1)+	;     Copy Pixel
	Move.b	0(a0,d3.l),(a1)+
	Move.b	0(a0,d4.l),(a1)+
	Move.b	0(a0,d5.l),(a1)+
	Dbra	d0,.xlp			;   END x
	Dbra	d1,.ylp			; END y


	;-- C2P --
	_WaitVBL
	Lea	LNS_cbf,a0
	Lea	LNS_pln,a1
	Lea	CHUNKY,a2
	Move.l	#160*LNS_Y/8-1,d0



	Tst.w	LNS_ptn
	Beq.s	.c2p16
	Jsr	c2p32
	Bra.s	.c2pd
.c2p16	Jsr	c2p16
.c2pd
	Tst.w	EXIT
	Bne.s	.bye

	Cmp.w	#LNS_Time,INT_Timer1	; Wait 5 seconds
	Blt.s	.lns_lp


	;-- QUIT --

	Move.w	#$0180,DMACON(a5)
	_WaitVBL

.bye	Rts



;	--+---------------+--
;	--| VBL INTERRUPT |--
;	--+---------------+----------------------------------+--

	CNOP	0,4

LNS_int3
	Movem.l	d0-7/a0-6,-(sp)

	;--( Update Coords )--
	Move.w	LNS_AngX,d0
	Addq.w	#2,d0
	And.w	#$03FF,d0
	Move.w	d0,LNS_AngX

	Move.w	LNS_AngY,d1
	Add.w	#12,d1
	And.w	#$03FF,d1
	Move.w	d1,LNS_AngY

	;--( General VBlank Stuff)--
	Jsr	PT_Music
	Add.w	#1,INT_Timer1
	Add.w	#1,INT_Timer2

	Btst	#6,$BFE001
	Bne.s	.nolmb
	Move.w	#-1,EXIT

.nolmb	Movem.l	(sp)+,d0-7/a0-6
	Move.w	#$0020,$DFF000+INTREQ
	Nop
	Rte



; +-------+
; | DATAS |	
; +-------+-------------------------------------------+

	CNOP	0,4

LNS_AngX	Dc.w	800
LNS_AngY	Dc.w	0

LNS_ptn	Dc.w	0					; Which of the two to use

LNS_pal		dc.l	$00000000,$00000000,$00121212,$00242424
		dc.l	$00494949,$006d6d6d,$00808080,$00b6b6b6
		dc.l	$00ffffff,$004f6b81,$00607e91,$007491a3
		dc.l	$0086a3b3,$009bb6c2,$00b4cad4,$00ccdde3

LNS_pal2	dc.l	$00000033,$000d0e51,$0012135d,$00141663,$00171869,$00191b6f,$001c1e75,$001e217b
		dc.l	$00212381,$00232687,$00272a90,$002b2e99,$002d319f,$003033a5,$003236ab,$003539b1
		dc.l	$00373cb7,$003a3ebd,$003c41c3,$003f44c9,$004449d5,$004e53d8,$00565bdb,$005c61dd
		dc.l	$00666be1,$006f75e5,$00767ce7,$007d83ea,$00848aeb,$008c91ef,$00949af1,$00999ef3


LNS_bmp		incbin	'TLA/lens/ExpPic2.CNK'			; The Bitmap
		incbin	'TLA/lens/ExpPic2.CNK'
LNS_bmp2	incbin	'TLA/lens/WaterPic.CNK'
		incbin	'TLA/lens/WaterPic.CNK'
LNS_lns		incbin	'TLA/lens/Lens2a.RAW'			; The Lens Lookup Table
LNS_lns2	incbin	'TLA/lens/Lens2b.RAW'

; +-------------------------------------------+

	section	'LNS_pln',BSS_C
LNS_pln	Ds.b	40*128*5				; Planar Display (320x128x4)

; +-------------------------------------------+

	section	'LNS_cbf',BSS
LNS_cbf	Ds.b	160*128					; ChunkyBuffer

; +-------------------------------------------+

	section	'LNS_CL',DATA_C
LNS_CL	Dc.w	BPL0PTH,0,BPL0PTL,0,BPL1PTH,0,BPL1PTL,0
	Dc.w	BPL2PTH,0,BPL2PTL,0,BPL3PTH,0,BPL3PTL,0
	Dc.w	BPL4PTH,0,BPL4PTL,0

	Dc.w	DDFSTRT,$38,DDFSTOP,$D0,DIWSTRT,$2C81,DIWSTOP,$2CC1
	Dc.w	BPL1MOD,-48,BPL2MOD,-8

	Dc.w	BPLCON1,0,BPLCON2,0
	Dc.w	FMODE,$4003			; ScanDouble + FastLargeGrab

LNS_CLp	ColBank	1				; 32 Colours

	Dc.w	$6007,$FFFE
LNS_bpl	Dc.w	BPLCON0,$5201
	Dc.w	$F807,$FFFE,BPLCON0,$0201

	Dc.w	$FFFF,$FFFE
