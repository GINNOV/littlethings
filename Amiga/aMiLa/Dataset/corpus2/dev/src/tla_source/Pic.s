; +------------------------+
; | 'pic.s' Display Piccy. |
; +------------------------+----------------------------------------+


;------------------------------


	CNOP	0,4

PIC_INT

	_LoadPalette24	PIC_black, PIC_Cp1, 7
	_LoadPlanes	#PIC_exp, PIC_CL1, 7, 40*160
	_LoadCList	PIC_CL1		; Show CopperList


	_WaitVBL
	Move.w	#$8380,$DFF000+DMACON	; DMAEN | BPLEN | COPEN


	; +-| START |---------------------------------+

	_WaitVBL 20

.lp	Move.w	PIC_cnt,d0
	Move.w	d0,d1
	Neg.w	d0
	Add.w	#44+128,d0
	Add.w	#44+128,d1
	Lsl.w	#8,d0
	Lsl.w	#8,d1
	Or.b	#07,d0
	Or.b	#07,d1

	Move.w	d0,PIC_d1a
	Move.w	d1,PIC_d1b

	;-- PALETTE FADE --
	Move.w	PIC_cnt,d7
	Ext.l	d7
	Lsl.l	#8,d7		; * 256
	Divu	#81,d7		; /  80 ~ 98%
	And.l	#$FF,d7
	_FadePalette24	PIC_black, PIC_pal, PIC_tmp, 128, d7
	_LoadPalette24	PIC_tmp, PIC_Cp1, 7
	_WaitVBL

	Add.w	#1,PIC_cnt
	Cmp.w	#80,PIC_cnt
	Ble.s	.lp


	;-- WAIT FOR A BIT --
	_WaitVBL	50*5


	;-- AND DISAPPEAR --
	Sub.w	#1,PIC_cnt
.lp2	Move.w	PIC_cnt,d0
	Move.w	d0,d1
	Neg.w	d0
	Add.w	#44+128,d0
	Add.w	#44+128,d1
	Lsl.w	#8,d0
	Lsl.w	#8,d1
	Or.b	#07,d0
	Or.b	#07,d1

	Move.w	d0,PIC_d1a
	Move.w	d1,PIC_d1b

	;-- PALETTE FADE --
	Move.w	PIC_cnt,d7
	Ext.l	d7
	Lsl.l	#8,d7		; * 256
	Divu	#81,d7		; /  80 ~ 98%
	And.l	#$FF,d7
	_FadePalette24	PIC_black, PIC_pal, PIC_tmp, 128, d7
	_LoadPalette24	PIC_tmp, PIC_Cp1, 7
	_WaitVBL

	Sub.w	#1,PIC_cnt
	Tst.w	PIC_cnt
	Bgt.s	.lp2


	; +-| END |-----------------------------------+

PIC_bailout	Rts			; Finished





; +-------+
; | DATAS |	
; +-------+-------------------------------------------+

PIC_cnt	Dc.w	1

	CNOP	0,4

PIC_pal	dc.l	$00080808,$000c0c0c,$00101010,$00161616,$001a1a1a,$0014181e,$00161b25,$000e1628
	dc.l	$001f1f1f,$00121c36,$00222222,$00272727,$000b1937,$0024282e,$0016223d,$00242836
	dc.l	$00152649,$002f2f2f,$00192a4e,$00282c3a,$00222e48,$00343434,$00202d4f,$00273145
	dc.l	$00383838,$00333741,$00253251,$00213559,$003c3c3c,$0029395a,$00343a48,$00263860
	dc.l	$00323c50,$00404040,$00333d57,$002b3b5f,$00444444,$00283c66,$003a445c,$00484848
	dc.l	$00324263,$00273f71,$0031456d,$00414753,$00424a60,$003a4866,$00364872,$002d4577
	dc.l	$004f4f4f,$00545454,$003e4c6d,$00384c78,$00465066,$00415171,$00585858,$00374d7f
	dc.l	$004a546a,$00465674,$004e586c,$0041557d,$00545864,$00525a6e,$003f5585,$005c5c5c
	dc.l	$00445782,$00606060,$00646464,$004d5b7a,$00495d83,$00586072,$00546382,$00616771
	dc.l	$00506490,$00686868,$005a6680,$00656975,$006e6e6e,$00576787,$00566890,$00656b7c
	dc.l	$005f6c8b,$00697389,$00767676,$007c7c7c,$00637193,$00677595,$00787b85,$0061759d
	dc.l	$00808080,$006b7999,$006a7aa0,$00848484,$00707e9e,$00748098,$007682a0,$00888888
	dc.l	$007b88a6,$008c8c8c,$00818ba3,$008290aa,$00909090,$00949494,$008993ab,$008997b3
	dc.l	$00989898,$008e9bb3,$009c9c9c,$00a0a0a0,$0095a0b8,$00a4a4a4,$00a8a8a8,$009ca7bf
	dc.l	$00acacac,$009eaac4,$00a3adc1,$00b0b0b0,$00abb4c9,$00b1b9cb,$00b9c0d1,$00c2c8d6
	dc.l	$00c6ccd8,$00cdd3de,$00d2d8e2,$00dadee7,$00e0e4ec,$00e7e9f0,$00eff1f5,$00ffffff
PIC_black	Ds.l	128
PIC_tmp		Ds.l	128
	; +-------------------------------------------+

	section	'Pic Copper',DATA_C


PIC_CL1	Dc.w	BPL0PTH,0,BPL0PTL,0,BPL1PTH,0,BPL1PTL,0
	Dc.w	BPL2PTH,0,BPL2PTL,0,BPL3PTH,0,BPL3PTL,0
	Dc.w	BPL4PTH,0,BPL4PTL,0,BPL5PTH,0,BPL5PTL,0
	Dc.w	BPL6PTH,0,BPL6PTL,0

	Dc.w	DDFSTRT,$38,DDFSTOP,$D0,DIWSTRT,$2C81,DIWSTOP,$2CC1
	Dc.w	BPL1MOD,-8,BPL2MOD,-8,BPLCON1,0,BPLCON2,0
	Dc.w	FMODE,$0003

PIC_Cp1	ColBank	7

	Dc.w	BPLCON3,0000

PIC_d1a	Dc.w	$AC07,$FFFE,BPLCON0,$7200		; Display On
PIC_d1b	Dc.w	$AC07,$FFFE,BPLCON0,$0200		; Display Off

	Dc.w	$FFFF,$FFFE				; END



	CNOP	0,8

PIC_exp	incbin	'tla/ExpPic/EXP.RAW'
