*** Bootblock spécial: Intro avec Menu et Scrolling de texte

Start:
	MOVEM.L	D1-A6,-(A7)
	MOVE	#$81c0,$DFF096
	MOVE.L	#$5FC00,$0300.W	;rastport à $5fc00
	MOVE.L	#$5FD00,$0304.W	;bitmap à $5fd00
	LEA	$60000,A0	;bitplanes à $60000
	MOVE	#$1000,D0
LB_0032	CLR.L	(A0)+
	DBF	D0,LB_0032
	MOVE.L	4.W,A6
	move.l	$9c(a6),a6	;execbase->gfxbase
	LEA	CopList(PC),A0
	move.l	50(a6),OldCop
	MOVE.L	A0,50(A6)	;2è coplist système
	MOVE.L	$0304.W,A0	;adresse du bitmap
	MOVEQ	#1,D0		;1 bitplane
	MOVE	#704,D1		;Largeur
	MOVE	#256,D2		;Hauteur
	JSR	-$0186(A6)	;InitBitmap()
	MOVE.L	$0300.W,A1	;adresse du rastport
	JSR	-$00C6(A6)	;InitRastport()
	MOVE.L	$0300.W,A1
	MOVE.L	$0304.W,A0
	MOVE.L	A0,4(A1)
	MOVE.L	#$60000,8(A0)	;adr bitplanes ds struct Bitmap
*** Ecrire le texte du Menu
	MOVEQ	#$14,D6
	LEA	MenuText(PC),A3
LB_0084	MOVE.L	A3,-(A7)
	MOVEQ	#-1,D1
LB_0088	TST.B	(A3)+
	DBEQ	D1,LB_0088
	NOT.L	D1
	MOVE.L	D1,-(A7)
	MULU	#9,D1
	LSR.L	#1,D1
	MOVE.L	#$B4,D0
	SUB.L	D1,D0
	MOVE.L	D6,D1
	MOVE.L	$0300.W,A1
	JSR	-$00F0(A6)	;Move()
	MOVE.L	$0300.W,A1
	MOVE.L	(A7)+,D0
	MOVE.L	(A7)+,A0
	JSR	-$003C(A6)	;Text()
	ADD	#9,D6
	TST.B	(A3)
	BNE.B	LB_0084
	BSR.W	InitStars
	LEA	ScrollText(PC),A4
	moveq	#0,d7
LB_00C8
	JSR	-270(A6)	;WaitTOF()	attendre prochaine VBL
	MOVE.L	D7,$0320.W
	BSR.W	Stars
	MOVE.L	$0320.W,D7
	BSR.B	LB_0110
*** touche de fonction appuyée? si non boucle
	CLR.L	D0
	MOVE.B	$BFEC01,D0
	NOT.B	D0
	LSR.B	#1,D0
	SUBI.B	#$50,D0
	BCS.B	LB_00C8
	CMP.B	#$09,D0
	BHI.B	LB_00C8
	MOVE.L	D0,$80.W	;code touche ds vecteur trap 0
*** restore coplist
	move.l	OldCop(pc),50(a6)
*** boote le système
	LEA	dosname(PC),A1
	MOVE.L	4.W,A6
	JSR	-96(A6)		;FindResident()
	MOVE.L	D0,A0
	MOVE.L	22(A0),A0
	CLR.L	D0
	MOVEM.L	(A7)+,D1-a6
LB_010E	RTS	
LB_0110	LEA	$DFF000,A0
	BTST	#2,2(A0)	;le blitter a fini son travail?
	BNE.B	LB_0110		;si non alors boucle
	MOVE.L	#$62890,$50(A0)	;blitter source A
	MOVE.L	#$6288E,$54(A0)	;blitter destination D
	MOVE.L	#$002a002a,$64(A0)	;modulo src/dest
	MOVE	#$D9F0,$40(A0)		;bltcon0 (controle blitter)
	MOVE	#$0217,$58(A0)	;bltsize (démarrage blitter & controle fenètre)
	ADDQ	#1,D7
	CMP	#3,D7
	BNE.B	LB_010E
	MOVE.L	$0300.W,A1
	MOVE	#342,D0
	MOVEQ	#124,D1
	JSR	-$00F0(A6)	;Move()
	MOVE.L	$0300.W,A1
	MOVE.L	A4,A0
	addq.l	#1,a4
	MOVEQ	#1,D0
	CLR.L	D7
	TST.B	(A4)
	BNE.B	LB_0172
	LEA	ScrollText(PC),A4
LB_0172	JMP	-$003C(A6)	;Text()


InitStars:
	LEA	$68000,A0
	MOVE	#$E7FF,D0
.clr	clr.b	(a0)+
	DBF	D0,.clr
	LEA	$7E800,A0
	MOVEQ	#84,D0
.lop1	MOVE.B	$DFF007,D5
	MOVEQ	#0,D4
	MOVE.B	$BFD800,D4
	MOVE	D4,4(A0)
	EOR.B	D5,D4
	ASL	#6,D4
	MOVE	D4,(A0)+
	AND	#$00FF,D4
.lop	DBF	D4,.lop
	MOVE.B	$BFE801,D4
	EOR.B	D4,D5
	ASL	#6,D5
	BSET	#$0F,D5
	MOVE	D5,(A0)+
	TST	(A0)+
	CLR.L	(A0)+
	DBF	D0,.lop1
	RTS	
Stars:
	LEA	$7E800,A0
	LEA	$68000,A1
	LEA	$6C000,A2
	MOVEQ	#84,D0
LB_0242	MOVE.L	A0,-(A7)
	MOVE.B	7(A0),D5
	MOVE	8(A0),D6
	BCLR	D5,(A1,D6.W)
	BCLR	D5,(A2,D6.W)
	SUBQ	#3,4(A0)
	MOVE	4(A0),D4
	BMI.B	LB_02BA
	BEQ.B	LB_02BA
	MOVE	(A0)+,D2
	EXT.L	D2
	DIVS	D4,D2
	MOVE	(A0)+,D3
	TST	(A0)+
	EXT.L	D3
	DIVS	D4,D3
	ADD	#176,D2
	BMI.B	LB_02BA
	CMP	#352,D2
	BGE.B	LB_02BA
	ADDI	#128,D3
	BMI.B	LB_02BA
	LSL	#6,D3
	MOVE	D2,D1
	LSR	#3,D1
	ADD	D1,D3
	NOT.B	D2
	ANDI.B	#$07,D2
	MOVE	D2,(A0)+
	MOVE	D3,(A0)+
	MOVEQ	#1,D7
	ROL.B	D2,D7
	CMP	#225,D4
	BLT.B	LB_02A2
	OR.B	D7,(A2,D3.W)
	BRA.B	LB_02AE
LB_02A2	CMP	#150,D4
	BLT.B	LB_02AE
	OR.B	D7,(A2,D3.W)
	BRA.B	LB_02B2
LB_02AE	OR.B	D7,(A1,D3.W)
LB_02B2	TST.L	(A7)+
LB_02B4	DBF	D0,LB_0242
	RTS	
LB_02BA	MOVE	#1000,D7
	MOVE.L	(A7)+,A0
	MOVE	#300,4(A0)
	MOVE.B	$DFF007,D5
	MOVE.B	$BFD800,D4
	EOR.B	D5,D4
	EXT	D4
	ASL	#6,D4
	BMI.B	LB_02DE
	ADD	D7,D4
	BRA.B	LB_02E0
LB_02DE	SUB	D7,D4
LB_02E0	MOVE	D4,(A0)+
	MOVE.B	$BFE801,D4
	EOR.B	D4,D5
	EXT	D5
	ASL	#6,D5
	BMI.B	LB_02F2
	NEG	D5
LB_02F2	SUB	D7,D5
	MOVE	D5,(A0)+
	TST	(A0)+
	CLR.L	(A0)+
	BRA.B	LB_02B4
OldCop	dc.l	0
CopList:
 DC.w $008E,$2C81,$0100,$4600
 DC.w $0108,$0014,$010A,$0000
 DC.w $0090,$2CF4,$0092,$0030
 DC.w $0094,$00D8,$0184,$0FFF
 DC.w $0186,$0DDD,$0182,$0BBB
 DC.w $0180,$0000,$0192,$0FFF
 DC.w $0194,$0BBB,$00E0,$0006
 DC.w $00E2,$8000,$00E8,$0006
 DC.w $00EA,$C000,$00E4,$0006
 DC.w $00E6,$0000,$00EC,$0006
 DC.w $00EE,$002C,$AC01,$FFFE
 DC.w $0108,$FF94
 dc.w $FFFF,$FFFE		;fin
dosname	dc.b	"dos.library",0

MenuText:
 dc.b "F R E D O",0
 dc.b "PRESENTE",0
 dc.b "UNE BOOTBLOCK-INTRO AVEC MENU!!!",0
 dc.b " ",0
 dc.b "Appuyez sur une",0
 dc.b "touche de fonction",0
 dc.b "Pour sortir....",0 
 DC.B 0
ScrollText:
 dc.b "Salut tout le monde!  Frédo présente une nouvelle"
 dc.b " Bootblock-Intro, avec un menu..."
 dc.b "                    ",0

End:
	dcb.b	512*2
