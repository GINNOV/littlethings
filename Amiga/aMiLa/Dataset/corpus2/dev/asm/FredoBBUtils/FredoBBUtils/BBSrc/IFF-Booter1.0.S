*** IFF-Booter 1.00 Bootblock
* Bootblock qui charge & affiche une image IFF-ILBM
* l'image ne doit pas dépasser 5 bitplanes (32 couleurs)

IFFDATA=$50000		;adr des données IFF-ILBM

Start:
	MOVEM.L	D0-A6,-(A7)
	MOVE.L	4.W,A6
	bra.s	.go

	move	#2,$001C(A1)		;TD_READ
	MOVE.L	#$A400,$0024(A1)	;io_length
	MOVE.L	#IFFDATA,$0028(A1)	;io_data
	MOVE.L	#$400,$002C(A1)		;io_offset
	JSR	-$01C8(A6)		;DoIO()
	move	#9,$001C(A1)		;TD_MOTOR
	CLR.L	$0024(A1)
	JSR	-$01C8(A6)
.go
	LEA	intname(PC),A1
	JSR	-408(A6)
	MOVE.L	D0,$7D000
	MOVE.L	$9c(a6),$7D004	;execbase->gfxbase
	lea	IFFDATA+12,A0
	MOVE.L	A0,$7D008
	MOVE.L	4(A0),D0
	ADDA.L	D0,A0
	ADDQ.L	#8,A0
	MOVE.L	A0,$7D00C
.search_BODY
	MOVE.L	4(A0),D0
	ADDA.L	D0,A0
	ADDQ.L	#8,A0
	MOVE.L	#'BODY',D1
	CMP.L	(A0),D1
	BNE.B	.search_BODY
	MOVE.L	A0,$7D010
	MOVE.L	$7D008,A2
	MOVE.L	A2,A1
	lea	$10(a1),A1
	MOVEQ	#0,D0
	MOVE.B	(A1),D0
	CMP	#6,D0
	BLT.B	.no6bpl
	MOVEQ	#6,D0
.no6bpl	LEA	NewScreen(PC),A0
	MOVE.L	A0,A3
	move	D0,8(A3)	;ns_depth
	subq	#1,D0
	move	D0,$7D014
	MOVE.L	A2,A1
	MOVE.B	$0048(A1),$7D016
	ADDQ.L	#8,A1
	MOVEQ	#0,D0
	move	(A1)+,D0
	move	D0,4(A3)
	MOVEQ	#0,D3
	cmp	#640,D0
	BLT.B	.lores
	OR	#$8000,D3	;ns_viewmodes
.lores	move	D0,D1
	AND	#7,D1
	BEQ.B	.zero
	OR	#8,D0
.zero	lsr	#3,d0		;d0=d0/8
	move	D0,$7D018
	MOVEQ	#0,D0
	move	(A1),D0
	move	D0,6(A3)
	cmp	#400,D0
	BLT.B	.nolace
	OR	#4,D3
.nolace	move	D3,$C(A3)
	LEA	NewScreen(PC),A0
	MOVE.L	$7D000,A6	;intbase
	JSR	-$00C6(A6)	;OpenScreen()
	MOVE.L	D0,$7D01A
	MOVE.L	D0,A0
	lea	$C0(a0),A0	;bm_planes
	lea	$7D01E,A1
	move	$7D014,D0
.getplanes
	move	D0,D1
	LSL.L	#2,D1
	MOVE.L	(A0,D1.W),(A1,D1.W)
	DBF	D0,.getplanes
	MOVE.L	$7D00C,A0
	ADDQ.L	#8,A0

	lea	$7D0C6,A1
	MOVEQ	#32-1,D7	;compteur nbre de couleurs
.col
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	ANDI.B	#$F0,D0
	LSL	#4,D0
	MOVE.B	(A0)+,D0
	AND	#$0FF0,D0
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1
	LSR.B	#4,D1
	AND.B	#$0F,D1
	OR.B	D1,D0
	move	D0,(A1)+
	DBF	D7,.col

	MOVE.L	$7D01A,A0
	lea	$2C(a0),A0	;sc_viewport
	move.l	a0,-(sp)
	lea	$7D146,A1	;palette noire
	MOVEQ	#32,D0		;32 couleurs
	MOVE.L	$7D004,A6	;gfxbase
	JSR	-$00C0(A6)	;LoadRGB4()

	BSR.s	DisplayPic	;affiche image

	move.l	(sp)+,a0
	lea	$7D0C6,A1	;palette de l'image
	MOVEQ	#32,D0
	MOVE.L	$7D004,A6
	JSR	-$00C0(A6)	;LoadRGB4()
wait	BTST	#10,$dff016
	BNE.B	wait
	MOVE.L	$7D000,A6
	MOVE.L	$7D01A,A0
	JSR	-$0042(A6)
;	move	#$83F0,$00DFF096
	MOVEM.L	(A7)+,D0-A6
	RTS
DisplayPic:
	lea	$7D01E,A2
	MOVE.L	$7D010,A0
	ADDQ.L	#4,A0
	MOVE.L	(A0)+,D7
	MOVE.L	A0,A3
	ADDA.L	D7,A3
	move	$7D014,D2
	addq	#1,D2
LB_0214	CMPA.L	A3,D0
	BGE.B	LB_028E
	MOVEQ	#0,D3
LB_021C	move	D3,D4
	lsl	#2,d4		;d4=d4*4
	MOVE.L	(A2,D4.W),A5
	BSR.B	LB_024A
	MOVE.L	A5,(A2,D4.W)
	addq	#1,D3
	cmp	D2,D3
	BLT.B	LB_021C
	MOVE.L	$7D008,A5
	AND.B	#1,$0011(A5)
	BEQ.B	LB_0214
	lea	$7D1CA,A5
	BSR.B	LB_024A
	BRA.B	LB_0214
LB_024A	MOVE.L	D2,$80.W
	move	$7D018,D2
LB_0254	TST	D2
	BEQ.B	LB_0288
	MOVEQ	#0,D0
	TST.W	$7D016
	BNE.B	LB_026C
	move	$7D018,D0
	subq	#1,D0
	BRA.B	LB_0270
LB_026C	MOVE.B	(A0)+,D0
	BMI.B	LB_027A
LB_0270	MOVE.B	(A0)+,(A5)+
	subq	#1,D2
	DBF	D0,LB_0270
	BRA.B	LB_0254
LB_027A	NEG.B	D0
	MOVE.B	(A0)+,D1
LB_027E	MOVE.B	D1,(A5)+
	subq	#1,D2
	DBF	D0,LB_027E
	BRA.B	LB_0254
LB_0288	MOVE.L	$80.W,D2
LB_028E	RTS

NewScreen:
	dc.w	0,0,320,200
	dc.w	5
	dc.b	0,1
	dc.w	0,$f
	dc.l	0,0,0,0

intname:dc.b "intuition.library",0
