; +-----------------+
; | Sierprinski tri |
; +-----------------+-------------------------------------------------+

TRI_WAITDELAY	= 50*10


	CNOP	0,4

TRI_INT

	;-- GET MEMORY --

	Move.l	#250000,d0			; Stack Mem
	Move.l	#MEMF_PUBLIC|MEMF_CLEAR,d1
	Call	_LVOAllocMem,exec
	Move.l	d0,TRI_stkp
	Beq.s	TRI_die0

	Move.l	#40*256*2,d0			; ChipMem (display)
	Move.l	#MEMF_CHIP|MEMF_CLEAR,d1
	Call	_LVOAllocMem,exec
	Move.l	d0,TRI_plnp
	Beq.s	TRI_die1

	;-- Init CoperList --
	Move.l	d0,TRI_log
	Add.l	#40*256,d0
	Move.l	d0,TRI_phy
	Bsr	TRI_ScrSwap

	_WaitVBL
	_LoadPlanes	#TRI_bgimg, TRI_CL, 4, 40*256
	_LoadPalette24	PAL_black, TRI_cp, 1
	_LoadCList	TRI_CL				; Show CopperList
	Move.w	#$8380,$DFF000+DMACON	; DMAEN | BPLEN | COPEN

	Clr.w	INT_Timer1



	;----------
	;-- LOOP --
	;----------

.tri_lp

	;-- FADE IN (IF NEEDED) --
	Move.w	INT_Timer1,d1
	Lsl.w	#1,d1		; Fade Speed
	Cmp.w	#255,d1		; <fade_lev>
	Bgt.s	.nofin

	Move.w	#31, d0		; <cols-1>
	Lea	PAL_black,a0	; <pal1>
	Lea	TRI_pal,a1	; <pal2>
	Lea	PAL_temp,a2	; <temp_pal>
	Jsr	__FadePalette24

	Move.w	#0,d0
	Lea	PAL_temp,a0	; <palette>
	Lea	TRI_cp,a1	; <copper palette>
	Jsr	__LoadPalette24
.nofin

	;--( Fade-Out if needed )--
	Move.w	INT_Timer1,d1
	Neg.w	d1
	Add.w	#TRI_WAITDELAY,d1
	Lsl.w	#1,d1		; Fade Speed
	Cmp.w	#255,d1
	Bgt.s	.nofout

	Move.w	#31, d0		; <cols-1>
	Lea	PAL_black,a0	; <pal1>
	Lea	TRI_pal,a1	; <pal2>
	Lea	PAL_temp,a2	; <temp_pal>
	Jsr	__FadePalette24

	Move.w	#0,d0
	Lea	PAL_temp,a0	; <palette>
	Lea	TRI_cp,a1	; <copper palette>
	Jsr	__LoadPalette24
.nofout

	; +--------------------------+

	Lea	SINE,a0
	Lea	512(a0),a1		; Cosine Table

	;-- CALCULATE MOVEMENT OF TRIANGLE --
	Move.w	TRI_trioff,d0
	Add.w	#7,d0
	And.w	#$03FF,d0
	Move.w	d0,TRI_trioff
	Move.w	0(a0,d0.w*2),d0
	Asr.w	#1,d0
	Add.w	#512,d0

	;-- CALCULATE ROTATED POINTS --
;	Move.w	TRI_trirot,d0
;	Add.w	#12,d0
;	And.w	#$03FF,d0
;	Move.w	d0,TRI_trirot			; Angle of rotation

	Move.w	TRI_ptang + $00,d1
	Add.w	d0,d1
	And.w	#$03FF,d1
	Move.w	0(a1,d1.w*2),d2
	Asr.w	#3,d2
	Move.w	0(a0,d1.w*2),d1
	Asr.w	#3,d1
	Add.w	#160,d1
	Move.w	d1,TRI_pts + $00
	Add.w	#128,d2
	Move.w	d2,TRI_pts + $02

	Move.w	TRI_ptang + $02,d1
	Add.w	d0,d1
	And.w	#$03FF,d1
	Move.w	0(a1,d1.w*2),d2
	Asr.w	#3,d2
	Move.w	0(a0,d1.w*2),d1
	Asr.w	#3,d1
	Add.w	#160,d1
	Move.w	d1,TRI_pts + $04
	Add.w	#128,d2
	Move.w	d2,TRI_pts + $06

	Move.w	TRI_ptang + $04,d1
	Add.w	d0,d1
	And.w	#$03FF,d1
	Move.w	0(a1,d1.w*2),d2
	Asr.w	#3,d2
	Move.w	0(a0,d1.w*2),d1
	Asr.w	#3,d1
	Add.w	#160,d1
	Move.w	d1,TRI_pts + $08
	Add.w	#128,d2
	Move.w	d2,TRI_pts + $0A

	;-- DRAW THE BASTARD --
	Bsr	TRI_cls
	Bsr	TRI_init
	Bsr	TRI_ScrSwap
	_WaitVBL

	Tst.w	EXIT
	Bne.s	.out

	Cmp.w	#TRI_WAITDELAY,INT_Timer1
	Ble.s	.tri_lp

	;----------
	;-- QUIT --
	;----------

.out	Move.l	TRI_plnp,a1		; Free Screen Data
	Move.l	#40*256*2,d0
	Call	_LVOFreeMem,exec
TRI_die1
	Move.l	TRI_stkp,a1		; Free Stack Space
	Move.l	#250000,d0
	Call	_LVOFreeMem,exec
TRI_die0

	Rts


; +-------------------------------------------+



TRI_ScrSwap
	Move.l	TRI_log,d0
	Move.l	TRI_phy,TRI_log
	Move.l	d0,TRI_phy

	Lea	TRI_pp,a0
	Move.w	d0,$06(a0)
	Swap	d0
	Move.w	d0,$02(a0)

	Rts




TRI_cls	Move.l	TRI_log,a0
	Move.w	#(40*256/4)-1,d0
.clp	Clr.l	(a0)+
	Dbra	d0,.clp
	Rts

	; Stack:	(uses $0E bytes stack)
	; ------	----------------------
	; $00(a6).w -	# of iterations left (0 terminates)
	; $02(a6).w -	x1, y1
	; $06(a6).w -	x2, y2
	; $0A(a6).w -	x3, y3


TRI_init
	Move.l	TRI_log,a0	; !! ALWAYS KEEP SCREEN PTR. IN A0 !!
	Lea	TRI_pts,a1
	Move.l	TRI_stkp,a6
	Lea	250000(a6),a6	; ** END of stack!! **

	Lea	-$0E(a6),a6	; Allocate stack space for params
	Move.w	#6,$00(a6)	; # of levels
	Move.l	(a1)+,$02(a6)	; x1, y1
	Move.l	(a1)+,$06(a6)	; x2, y2
	Move.l	(a1)+,$0A(a6)	; x3, y3
	Bsr	TRI_draw	; DRAW IT
	Lea	$0E(a6),a6	; Deallocate stack
	Rts



;            [x1,y1]
;            /     \
;           /       \
;          /         \
;         /           \
;        /             \
;       /               \
;      /                 \
;  [x2,y2] ------------- [x3,y3]



TRI_draw
	Move.w	$00(a6),d7
	Beq.s	.bailout


	;-- CREATE NEW COORDS --
	Move.l	$02(a6),d4	; [ x1 | y1 ]
	Move.l	$06(a6),d5	; [ x2 | y2 ]
	Move.l	$0A(a6),d6	; [ x3 | y3 ]

	Subq.w	#1,d7

	;-- FIND MEDIAN POINTS --
	Lea	-$1A(a6),a6	; TEMP STACK ALLOCATION	(26 bytes)


	Move.w	d4,d1
	Add.w	d5,d1
	Asr.w	#1,d1		; Y: 1-2 Average
	Move.w	d1,$02(a6)	; as [y1]
	Swap	d4
	Swap	d5
	Move.w	d4,d0
	Add.w	d5,d0
	Asr.w	#1,d0		; X: 1-2 Average
	Move.w	d0,$00(a6)	; as [x1]
	Swap	d4
	Swap	d5
	Bsr	TRI_plot	;		** DRAW [x1,y1] **

	Move.w	d5,d1
	Add.w	d6,d1
	Asr.w	#1,d1
	Move.w	d1,$06(a6)	; as [y2]
	Swap	d5
	Swap	d6
	Move.w	d5,d0
	Add.w	d6,d0
	Asr.w	#1,d0
	Move.w	d0,$04(a6)	; as [x2]
	Swap	d5
	Swap	d6
	Bsr	TRI_plot	;		** DRAW [x2,y2] **

	Move.w	d4,d1
	Add.w	d6,d1
	Asr.w	#1,d1
	Move.w	d1,$0A(a6)	; as [y3]
	Swap	d4
	Swap	d6
	Move.w	d4,d0
	Add.w	d6,d0
	Asr.w	#1,d0
	Move.w	d0,$08(a6)	; as [x3]
	Swap	d4
	Swap	d6
	Bsr	TRI_plot	;		** DRAW [x3,y3] **

	;-- NOW DRAW THEM --

	Move.w	d7,$0C(a6)	; # Recursions left
	Move.l	d4,$0E(a6)	; [x1,y1]
	Move.l	d5,$12(a6)	; [x2,y2]
	Move.l	d6,$16(a6)	; [x3,y3]


	Move.l	$00(a6),d0	; [nx1,ny1]
	Move.l	$08(a6),d1	; [nx2,ny2]
	Move.l	$0E(a6),d2	; [nx3,ny3]
	Move.w	$0C(a6),d7

	Lea	-$0E(a6),a6	; TOP SEGMENT
	Move.w	d7,$00(a6)
	Move.l	d2,$02(a6)
	Move.l	d0,$06(a6)
	Move.l	d1,$0A(a6)
	Bsr	TRI_draw
	Lea	$0E(a6),a6	; DONE



	Move.l	$00(a6),d0
	Move.l	$04(a6),d1
	Move.l	$12(a6),d2
	Move.w	$0C(a6),d7

	Lea	-$0E(a6),a6	; LEFT SEGMENT
	Move.w	d7,$00(a6)
	Move.l	d0,$02(a6)
	Move.l	d2,$06(a6)
	Move.l	d1,$0A(a6)
	Bsr	TRI_draw
	Lea	$0E(a6),a6	; DONE



	Move.l	$04(a6),d0
	Move.l	$08(a6),d1
	Move.l	$16(a6),d2
	Move.w	$0C(a6),d7

	Lea	-$0E(a6),a6	; RIGHT SEGMENT
	Move.w	d7,$00(a6)
	Move.l	d1,$02(a6)
	Move.l	d0,$06(a6)
	Move.l	d2,$0A(a6)
	Bsr	TRI_draw
	Lea	$0E(a6),a6	; DONE

	;-- FREE UP TEMP STACK --
	Lea	$1A(a6),a6

.bailout
	Rts




TRI_plot	; INPUT: d0.w, d1.w = x, y
		; KILLS: d0,d1,d2

	;-- BOUNDARY CHECKS --
	Tst.w	d0
	Blt.s	.waa
	Tst.w	d1
	Blt.s	.waa
	Cmp.w	#320,d0
	Bge.s	.waa
	Cmp.w	#256,d1
	Bge.s	.waa

	;-- PLOT THE BASTARD --
	Move.b	d0,d2
	Mulu	#40,d1
	Lsr.w	#3,d0
	Not.w	d2
	Ext.l	d0
	And.w	#$07,d2
	Add.l	d0,d1
	Bset	d2,00(a0,d1.l)

;	_WaitVBL

.waa	Rts
		
; +-------+
; | DATAS |	
; +-------+-------------------------------------------+


TRI_pts	Dc.w	0,0, 0,0, 0,0
	Dc.w	159,5, 5,250, 315,250

TRI_ptang	Dc.w	000,341,683
TRI_trirot	Dc.w	0
TRI_trioff	Dc.w	0

TRI_phy	Dc.l	0
TRI_log	Dc.l	0

TRI_stkp	Dc.l	0
TRI_plnp	Dc.l	0

TRI_pal	dc.l	$006677cc,$005564bd,$004553ad,$0037439e
	dc.l	$002b358f,$00202880,$00161c70,$000f1361
	dc.l	$00080b52,$00030442,$00000033,$00ffffff
	dc.l	$00ffffff,$00ffffff,$00ffffff,$00ffffff
	Dc.l	$ffffff,$ffffff,$ffffff,$ffffff,$ffffff,$ffffff,$ffffff,$ffffff
	Dc.l	$ffffff,$ffffff,$ffffff,$ffffff,$ffffff,$ffffff,$ffffff,$ffffff
	; +-------------------------------------------+

	section	'Copperlist',DATA_C

TRI_CL	Dc.w	BPL0PTH,0,BPL0PTL,0,BPL1PTH,0,BPL1PTL,0
	Dc.w	BPL2PTH,0,BPL2PTL,0,BPL3PTH,0,BPL3PTL,0
TRI_pp	Dc.w	BPL4PTH,0,BPL4PTL,0
	Dc.w	DDFSTRT,$38,DDFSTOP,$D0,DIWSTRT,$2C81,DIWSTOP,$2CC1
	Dc.w	BPL1MOD,0,BPL2MOD,0,FMODE,$0000
	Dc.w	BPLCON0,$5201,BPLCON1,0,BPLCON2,0

TRI_cp	ColBank	1						; 32 colours

	Dc.w	$FFFF,$FFFE



	CNOP 0,4
TRI_bgimg	incbin	'TLA/S-Tri/TRI_BG.RAW'


; +-----+
; | END |
; +-----+---------------------------------------------+

