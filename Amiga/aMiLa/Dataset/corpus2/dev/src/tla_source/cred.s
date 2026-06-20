; +-------------------------+
; | 'lace.s' Display Piccy. |
; +-------------------------+-----------------------------------------+




ECD_INT	;-- Init CoperList --

	Lea	$DFF000,a5
	Move.w	$0180,DMACON(a5)				; Kill DMA: BPLEN | COPEN

	_LoadPlanes	#ECD_Top, ECD_CL1, 5, 40*80		; Top Picture (LoRes)
	_LoadPlanes	#ECD_Top, ECD_CL2, 5, 40*80

	_LoadPlanes	#ECD_pln+00, ECD_p1, 1, 0
	_LoadPlanes	#ECD_pln+80, ECD_p2, 1, 0

	_LoadPalette24	ECD_pal, ECD_tp1, 1			; 32 cols
	_LoadPalette24	ECD_pal, ECD_tp2, 1			; 32 cols

	;-- Setup Long/Short frame swap --
	Lea	ECD_C1,a0	; Pointer.1
	Move.l	#ECD_CL2,d0	; Addr. of Short Frame
	Move.w	d0,6(a0)
	Swap	d0
	Move.w	d0,2(a0)

	Lea	ECD_C2,a0	; Pointer.2
	Move.l	#ECD_CL1,d0	; Addr. of Long Frame
	Move.w	d0,6(a0)
	Swap	d0
	Move.w	d0,2(a0)

	;-- Done --

	_ClearView
	_WaitTOP
	_WaitTOP			; (don't screw with hardware mid-frame!!) (sync.)
	Bset.b	#7,VPOSW(a5)		; Set Short Frame (2nd) so that 1st C-L sets short frame

	_LoadCList	ECD_CL1		; Show CopperList
	Move.w	#$8380,DMACON(a5)	; DMAEN | BPLEN | COPEN


	; +-| START |---------------------------------+




.lp1	_STC_Decrunch	ECD_pg1, ECD_pln

	Move.w	#375,d0				; 7.5 Sec
.e1	_WaitVBL	
	Tst.w	EXIT
	Bne.s	.end
	Dbra	d0,.e1


.lp2	_STC_Decrunch	ECD_pg2, ECD_pln

	Move.w	#375,d0
.e2	_WaitVBL	
	Tst.w	EXIT
	Bne.s	.end
	Dbra	d0,.e2


.lp3	_STC_Decrunch	ECD_pg3, ECD_pln

	Move.w	#375,d0
.e3	_WaitVBL	
	Tst.w	EXIT
	Bne.s	.end
	Dbra	d0,.e3


.lp4	_STC_Decrunch	ECD_pg4, ECD_pln

	Move.w	#375,d0
.e4	_WaitVBL	
	Tst.w	EXIT
	Bne.s	.end
	Dbra	d0,.e4

	Bra.s	.lp1
.end

	; +-| END |-----------------------------------+

	Rts							; Finished


; +-------+
; | DATAS |	
; +-------+-------------------------------------------+


ECD_pal	dc.l	$00000000,$00000000,$00090809,$00111011,$001a191a,$00222122,$002b292b,$00333133
	dc.l	$003c393c,$00444144,$004d4a4d,$00555255,$005e5a5e,$00666266,$006f6a6f,$00777277
	dc.l	$00807a80,$00888388,$00918b91,$00999399,$00a29ba2,$00aaa3aa,$00b3acb3,$00bbb4bb
	dc.l	$00c4bcc4,$00ccc4cc,$00d5ccd5,$00ddd4dd,$00e6dde6,$00eee5ee,$00f7edf7,$00fff5ff

ECD_pptr	Dc.l	ECD_pg1, ECD_pg2, ECD_pg3, ECD_pg4

ECD_pg1	incbin	'TLA/EndCreds/credpage1.stc'
ECD_pg2	incbin	'TLA/EndCreds/credpage2.stc'
ECD_pg3	incbin	'TLA/EndCreds/credpage3.stc'
ECD_pg4	incbin	'TLA/EndCreds/credpage4.stc'

	; +-------------------------------------------+

	section	'Planar',BSS_C
ECD_pln	Ds.b	80*352


	; +-------------------------------------------+

	section	'Laced Copper',DATA_C

	; Long Frame

ECD_CL1	Dc.w	BPL0PTH,0,BPL0PTL,0,BPL1PTH,0,BPL1PTL,0
	Dc.w	BPL2PTH,0,BPL2PTL,0,BPL3PTH,0,BPL3PTL,0
	Dc.w	BPL4PTH,0,BPL4PTL,0
	Dc.w	DDFSTRT,$38,DDFSTOP,$D0,DIWSTRT,$2C81,DIWSTOP,$2CC1
	Dc.w	BPL1MOD,0,BPL2MOD,0,BPLCON0,$5204		; 32 col HiRes Laced
	Dc.w	BPLCON1,0,BPLCON2,0
ECD_tp1	ColBank	1

	Dc.w	$7C07,$FFFE,BPLCON0,$0204

	Dc.w	DDFSTRT,$3C,DDFSTOP,$D4,DIWSTRT,$2C81,DIWSTOP,$2CC1
	Dc.w	BPL1MOD,80,BPL2MOD,80,BPLCON1,0,BPLCON2,0	; HiRes, Laced
ECD_p1	Dc.w	BPL0PTH,0,BPL0PTL,0,BPLCON3,0,COL00,$000,COL01,$FFF
	Dc.w	$7D07,$FFFE,BPLCON0,$9204


ECD_C1	Dc.w	COP1LCH,0,COP1LCL,0			; Load Short Frame
	Dc.w	$FFFF,$FFFE

	; +---------------------------------------------------+

	; Short Frame


ECD_CL2	Dc.w	BPL0PTH,0,BPL0PTL,0,BPL1PTH,0,BPL1PTL,0
	Dc.w	BPL2PTH,0,BPL2PTL,0,BPL3PTH,0,BPL3PTL,0
	Dc.w	BPL4PTH,0,BPL4PTL,0
	Dc.w	DDFSTRT,$38,DDFSTOP,$D0,DIWSTRT,$2C81,DIWSTOP,$2CC1
	Dc.w	BPL1MOD,0,BPL2MOD,0,BPLCON0,$5204		; 32 col HiRes Laced
	Dc.w	BPLCON1,0,BPLCON2,0,FMODE,0
ECD_tp2	ColBank	1

	Dc.w	$7C07,$FFFE,BPLCON0,$0204

	Dc.w	DDFSTRT,$3C,DDFSTOP,$D4,DIWSTRT,$2C81,DIWSTOP,$2CC1
	Dc.w	BPL1MOD,80,BPL2MOD,80,BPLCON1,0,BPLCON2,0	; HiRes, Laced
ECD_p2	Dc.w	BPL0PTH,0,BPL0PTL,0,BPLCON3,0,COL00,$000,COL01,$FFF
	Dc.w	$7D07,$FFFE,BPLCON0,$9204


ECD_C2	Dc.w	COP1LCH,0,COP1LCL,0			; Load Short Frame
	Dc.w	$FFFF,$FFFE



ECD_Top	incbin	'TLA/EndCreds/TopPic.RAW'		; Planar Picture



; +-----+
; | END |
; +-----+---------------------------------------------+

