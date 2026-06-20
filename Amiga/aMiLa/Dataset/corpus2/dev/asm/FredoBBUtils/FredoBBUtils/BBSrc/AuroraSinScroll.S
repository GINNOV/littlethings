* AURORA Sinus scroll bootintro
* Resourced by Frédo
* Works under 2.0 but
* Always the same problem... memory trashing!

LB_0000
	dc.b	'DOS',0
	dc.l	0,$370
Start:
	MOVE.L	$0004.W,A6	;remove this if you want to install
				;this bootblock, as this is not needed
				;When a bootcode is executed, Execbase
				;is always in A6

	MOVEM.L	D0-A6,-(A7)
	LEA	gfxname(PC),A1
	MOVEQ	#$00,D0
	JSR	-$0198(A6)	;open gfxlib
	MOVE.L	D0,A6
	LEA	LB_02A2(PC),A0
	LEA	fontname(PC),A1
	MOVE.L	A1,(A0)
	JSR	-$0048(A6)	;OpenFont()
	MOVE.L	D0,A0
	MOVE.L	$0022(A0),$0005ED0A	;let's trash some memory zone!
	MOVE.W	$0026(A0),$0005ED0E	;and another...
	MOVE.L	A6,A1
	MOVE.L	$0004.W,A6
	JSR	-$019E(A6)	;close gfxlib
;initialization
	MOVEQ	#$00,D4
	MOVEQ	#$00,D5
	LEA	$00060000,A0
	MOVE.W	#$0D44,D7
LB_0058	CLR.L	(A0)+			;hell...
	DBF	D7,LB_0058
	LEA	$00060000,A5
	LEA	LB_02EA(PC),A0
	LEA	$3560(A5),A1
	MOVEQ	#$1A,D6
LB_006E	MOVE.L	(A0)+,(A1)+
	DBF	D6,LB_006E
	LEA	$30D0(A5),A1
	MOVEQ	#$03,D0
LB_007A	LEA	LB_02C8(PC),A0
	MOVEQ	#$20,D6
LB_0080	MOVE.B	(A0)+,(A1)
	ADDI.B	#$20,(A1)
	MOVE.B	(A1)+,(A1)+
	DBF	D6,LB_0080
	SUBQ.W	#1,A0
	MOVEQ	#$1E,D6
LB_0090	MOVE.B	-(A0),(A1)
	ADDI.B	#$20,(A1)
	MOVE.B	(A1)+,(A1)+
	DBF	D6,LB_0090
	LEA	LB_02C8(PC),A0
	MOVEQ	#$20,D6
LB_00A2	MOVE.B	(A0)+,(A1)
	NEG.W	(A1)
	ADDI.B	#$20,(A1)
	MOVE.B	(A1)+,(A1)+
	DBF	D6,LB_00A2
	SUBQ.W	#1,A0
	MOVEQ	#$1E,D6
LB_00B4	MOVE.B	-(A0),(A1)
	NEG.W	(A1)
	ADDI.B	#$20,(A1)
	MOVE.B	(A1)+,(A1)+
	DBF	D6,LB_00B4
	DBF	D0,LB_007A
	LEA	$34D0(A5),A0
	MOVEQ	#$00,D0
	MOVEQ	#$47,D6
LB_00D0	MOVE.W	D0,(A0)+
	ADDI.W	#$0050,D0
	DBF	D6,LB_00D0

	LEA	$00DFF000,A6
	LEA	LB_028C(PC),A0
	MOVE.W	#$8000,D7
	MOVE.W	$0002(A6),(A0)		;save old DMA
	OR.W	D7,(A0)+
	MOVE.W	$001C(A6),(A0)		;save old interrupts
	OR.W	D7,(A0)
	NOT.W	D7
	MOVE.W	D7,$0096(A6)
	MOVE.W	D7,$009A(A6)
	MOVE.W	#$87C0,$0096(A6)	;start DMA
	MOVE.W	#$C000,$009A(A6)	;and interrupts
	MOVE.L	#$00063560,$0084(A6)
	LEA	LB_0356(PC),A2
LB_0116	MOVE.L	$0004(A6),D0
	ANDI.L	#$0001FF00,D0
	CMPI.L	#$00012C00,D0
	BNE.B	LB_0116
	LEA	LB_0290(PC),A3
	MOVEM.L	(A3),D0/D1
	EXG	D0,D1
	MOVEM.L	D0/D1,(A3)
	LEA	$3576(A5),A3
	LEA	$359E(A5),A4
	MOVE.W	D0,$0004(A3)
	SWAP	D0
	MOVE.W	D0,(A3)
	SWAP	D0
	ADDI.L	#$00001680,D0
	MOVE.W	D0,$0004(A4)
	SWAP	D0
	MOVE.W	D0,(A4)
	CMPI.W	#$0100,D4
	BLS.B	LB_0160
	SUBI.W	#$0100,D4
LB_0160	ADDQ.W	#6,D4
	SWAP	D4
	CMPI.B	#$04,D4
	BNE.B	LB_019C
	MOVEQ	#$00,D0
	MOVE.B	(A2)+,D0
	BNE.W	LB_0178
	LEA	LB_0356(PC),A2
	MOVE.B	(A2)+,D0
LB_0178	SUBI.B	#$20,D0
	MOVE.L	$0005ED0A,A3
	ADDA.L	D0,A3
	LEA	$2E90(A5),A4
	MOVEQ	#$07,D6
LB_018A	MOVE.B	(A3),(A4)
	ADDA.W	$0005ED0E,A3
	ADDA.W	#$0052,A4
	DBF	D6,LB_018A
	CLR.B	D4
LB_019C	MOVE.L	#$000630CE,$0050(A6)
	MOVE.L	#$000630CE,$0054(A6)
	MOVE.L	D5,$0064(A6)
	MOVE.L	#$29F00002,$0040(A6)
	MOVE.L	#$FFFFFFFF,$0044(A6)
	MOVE.W	#$0229,$0058(A6)
	ADDQ.B	#1,D4
	MOVE.L	D1,$0054(A6)
	MOVE.W	D5,$0066(A6)
	MOVE.W	#$0100,$0050(A6)
	MOVE.L	#$01000000,$0040(A6)
	MOVE.W	#$1228,$0058(A6)
	MOVE.W	#$0900,$0040(A6)
	MOVE.W	#$004E,$0062(A6)
	MOVE.W	#$0050,$0064(A6)
	MOVE.W	#$004E,$0066(A6)
	MOVE.W	#$0DFC,$0040(A6)
	LEA	$30D0(A5),A4
	SWAP	D4
	ADDA.W	D4,A4
	LEA	$34D0(A5),A3
	MOVE.L	#$00062E40,D2
LB_0214	MOVE.W	#$8000,D0
	MOVEQ	#$0F,D6
LB_021A	MOVEQ	#$00,D3
	MOVE.B	(A4)+,D3
	ADD.W	D3,D3
	MOVE.W	$00(A3,D3.W),D3
	ADD.L	D1,D3
	MOVE.L	D2,$0050(A6)
	MOVE.L	D3,$004C(A6)
	MOVE.L	D3,$0054(A6)
	MOVE.W	D0,$0044(A6)
	MOVE.W	#$0201,$0058(A6)
	LSR.W	#1,D0
	DBF	D6,LB_021A
	ADDQ.L	#2,D1
	ADDQ.L	#2,D2
	CMPI.L	#$00062E90,D2
	BNE.B	LB_0214
	BTST	#$06,$00BFE001	;test leftmouse
	BNE.W	LB_0116
	MOVE.W	D7,$0096(A6)	;restore DMA and interrupts
	MOVE.W	D7,$009A(A6)
	MOVE.W	LB_028C(PC),$0096(A6)
	MOVE.W	LB_028E(PC),$009A(A6)
	MOVEM.L	(A7)+,D0-A6
;boot system
;	MOVE.L	$0004.W,A6
	LEA	dosname(PC),A1
	MOVE.W	#'do',(A1)	;a little trick to save some bytes
	JSR	-$0060(A6)	;FindResident()
	MOVE.L	D0,A0
	MOVE.L	$0016(A0),A0
	MOVEQ	#$00,D0
	RTS	

LB_028C	DC.B	$00,$00
LB_028E	dc.b	$00,$00
LB_0290
	DC.B	$00,$06,$00,$00,$00,$06,$17,$20
	DC.B	$00,$00,$00,$00,$00,$00,$00,$05
	DC.B	$ED,$C8
LB_02A2
	DC.B	$00,$00,$00,$00,$00,$08,$00,$00
	DC.B	$00,$08
fontname
	dc.b	'topaz.font',0
gfxname	dc.b	'graph'
dosname	dc.b	'ics.library',0
LB_02C8
	DC.B	$00,$01,$03,$04,$06,$07,$09,$0A
	DC.B	$0C,$0D,$0F,$10,$11,$13,$14,$15
	DC.B	$16,$17,$18,$19,$1A,$1B,$1C,$1C
	DC.B	$1D,$1E,$1E,$1F,$1F,$1F,$1F,$1F
	DC.B	$20,$00

;copper list data
LB_02EA
	DC.B	$01,$00,$90,$00,$00,$8E,$75,$81
	DC.B	$00,$90,$E3,$C1,$00,$92,$00,$3C
	DC.B	$00,$94,$00,$D4,$00,$E0,$00,$07
	DC.B	$00,$E2,$00,$00,$01,$80,$00,$00
	DC.B	$01,$82,$00,$79,$01,$08,$00,$00
	DC.B	$74,$07,$FF,$FE,$01,$80,$03,$45
	DC.B	$75,$07,$FF,$FE,$01,$80,$00,$00
	DC.B	$BE,$07,$FF,$FE,$00,$E0,$00,$07
	DC.B	$00,$E2,$00,$00,$01,$08,$FF,$10
	DC.B	$01,$80,$00,$02,$01,$82
LB_0338
	DC.B	$00,$57,$BF,$07,$FF,$FE,$01,$80
	DC.B	$00,$04,$E3,$07,$FF,$FE,$01,$80
	DC.B	$03,$45,$E4,$07,$FF,$FE,$01,$80
	DC.B	$00,$00,$FF,$FF,$FF,$FE
LB_0356
	DC.B	'Spirou And Cuddley of Aurora proudly presents a '
	DC.B	'1024 bytes long Sinus Scroll Boot...  Coded just'
	DC.B	' for fun...  Greetings to all our friends.'
	dc.b	'  Have a nice life... '
	DC.B	'         ',$00
