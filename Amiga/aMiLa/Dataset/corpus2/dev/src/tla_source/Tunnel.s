; +-----------------------+
; | Generic Tunnel Effect |
; +-----------------------+-------------------------------------------+



TNL_Y		= 128		; # of y lines to do
TNL_TIME	= 15*50		; Time in VBL's

TNL_INT	;-- Init CoperList --
	_LoadPlanes	#TNL_pln, TNL_CL, 8, 40*128	; Init Plane Ptrs
	_LoadPalette24	TNL_white, TNL_CLp, 8		; Init Palette
	_LoadCList	TNL_CL				; Show CopperList
	_WaitVBL

	Move.w	#$8380,$DFF000+DMACON	; DMAEN | BPLEN | COPEN

	;-- UNPACK SHADED BG --
	_STC_Decrunch	TNL_bkg, TNL_pln+(40*128*4)
	;-- RESET TIMER --
	Clr.w	INT_Timer1

	; +------+
	; | LOOP |
	; +------+--------------------+



.tnl_lp

	;-- TIMING --
	_WaitVBL

	;-- FADE IN/OUT --
	Move.w	INT_Timer1,d0
	Cmp.w	#32,d0
	Bgt.s	.noin

	Asl.w	#3,d0
	Move.w	d0,TNL_fvl
	_FadePalette24	TNL_white, TNL_pal, PAL_temp, 256, TNL_fvl
	_LoadPalette24	PAL_temp, TNL_CLp, 8
	Bra.s	.nofd

.noin	Neg.w	d0
	Add.w	#TNL_TIME,d0
	Cmp.w	#64,d0
	Bgt.s	.nofd

	Asl.w	#2,d0
	Bge.s	.colok
	Moveq	#0,d0
.colok	Move.w	d0,TNL_fvl
	_FadePalette24	TNL_black, TNL_pal, PAL_temp, 256, TNL_fvl
	_LoadPalette24	PAL_temp, TNL_CLp, 8
.nofd

	;-- DO THE EFFECT --
	Lea	TNL_txr,a0		; The Texture
	Lea	TNL_tab,a1		; Lookup Table
	Lea	TNL_cbf,a2		; ChunkyBuffer
	Lea	SINE,a3			; Sine Table (1024 entries) = 1024*Sin(Ang)
	Lea	SINE+256,a4		; Cosine Table

	;-- TUNNEL MOVEMENT --
	Move.w	TNL_xps,d0		; Move thru tunnel
	Subq	#3,d0
	And.w	#$007F,d0
	Move.w	d0,TNL_xps
	Lsl.w	#7,d0			; *128 (texture width)
	Lea	0(a0,d0.w),a0

	Move.w	TNL_yan,d1		; Tunnel Rotation
	Addq	#8,d1
	And.w	#$03FF,d1
	Move.w	d1,TNL_yan

	Move.w	0(a3,d1.w*2),d1
	Lsr.w	#3,d1
	And.w	#$007F,d1
	Lea	0(a0,d1.w),a0

	;-- PERFORM TRANSFORMATION --
	Move.w	#160*128-1,d0
.ll	Move.w	(a1)+,d1		; Offset
	Move.b	0(a0,d1.w),(a2)+	; Read -> Write
	Dbra	d0,	.ll


	;-- DO C2P --
	Lea	TNL_cbf,a0
	Lea	TNL_pln,a1
	Lea	CHUNKY,a2
	Move.l	#160*TNL_Y/8-1,d0
	Jsr	c2p16

	;-- DONE! --
	
	Tst.w	EXIT
	Bne.s	.tnl_xit		; User Abort
	Cmp.w	#TNL_TIME,INT_Timer1	; Time to finish??
	Blt.s	.tnl_lp			; Just loop it


.tnl_xit

	;-- QUIT --

	Move.w	#$0180,DMACON(a5)
	_WaitVBL

	Rts



; +-------+
; | DATAS |	
; +-------+-------------------------------------------+

TNL_xps	Dc.w	0
TNL_yan	Dc.w	0
TNL_fvl	Dc.w	0

TNL_pal		incbin	'TLA/Tunnel/Main3.PAL'
TNL_white	Dcb.l	256,$FFFFFF
TNL_black	Dcb.l	256,$000000
TNL_tmp	Dcb.l	256,$000000

TNL_txr	incbin	'tla/tunnel/Texture6.CNK'
	incbin	'tla/tunnel/Texture6.CNK'
TNL_bkg	incbin	'TLA/Tunnel/SHADE_BG.STC'

TNL_tab	incbin	'tla/tunnel/TunnelMap.RAW'

	section	'PlanarDisplay',BSS_C
TNL_pln	Ds.b	40*128*8			; Planar Display (320x128x8)

	section	'MoreData',BSS
TNL_cbf	Ds.b	160*128				; ChunkyBuffer



	; +-------------------------------------------+

	section	'C2P_Test Clist',DATA_C
TNL_CL	Dc.w	BPL0PTH,0,BPL0PTL,0,BPL1PTH,0,BPL1PTL,0
	Dc.w	BPL2PTH,0,BPL2PTL,0,BPL3PTH,0,BPL3PTL,0
	Dc.w	BPL4PTH,0,BPL4PTL,0,BPL5PTH,0,BPL5PTL,0
	Dc.w	BPL6PTH,0,BPL6PTL,0,BPL7PTH,0,BPL7PTL,0

	Dc.w	DDFSTRT,$38,DDFSTOP,$D0,DIWSTRT,$2C81,DIWSTOP,$2CC1
	Dc.w	BPL1MOD,-48,BPL2MOD,-8

	Dc.w	BPLCON0,$0210,BPLCON1,0,BPLCON2,0
	Dc.w	FMODE,$4003			; ScanDouble + FastLargeGrab

TNL_CLp	ColBank	8				; 256 Colours

	Dc.w	$FFFF,$FFFE

