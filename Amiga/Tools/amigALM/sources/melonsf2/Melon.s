;	Code and design by Melon Dezign
;	Disassembled by Frantic
;	This is not the original source,
;	this has only been disassembled so you may learn...

;--------------------------------------;

;	AUTO	wb\Address\DatArea\		;ASM-One auto save intro

Address	= $1a0000				;Original was $40000
S	= Address+$8000

;--------------------------------------;

WaitBm	MACRO
.1\@	cmp.b	#\1-1,6(a6)
	bne.s	.1\@
.2\@	cmp.b	#\1,6(a6)
	bne.s	.2\@
	ENDM

;-------------------;

WaitBlt	MACRO
.1\@	btst	#14,2(a6)
	bne.s	.1\@
	ENDM

;--------------------------------------;

	JMP	Address
	ORG	Address
	LOAD	Address

;--------------------------------------;

Start	movem.l	d0-a6,-(a7)
	lea	$bfd100,a6
	or.b	#$f8,(a6)
	and.b	#$87,(a6)
	or.b	#$78,(a6)
	lea	S(pc),a5
	lea	$dff000,a6

	lea	DatArea-S(a5),a0
	move.w	#(PntSets-DatArea)-1,d0
.1	clr.b	(a0)+
	dbf	d0,.1

	move.w	2(a6),DMACon-S(a5)
	or.b	#$c0,DMACon-S(a5)
	move.w	$1c(a6),IntEna-S(a5)
	or.b	#$c0,IntEna-S(a5)

	move.w	#$7fff,$9a(a6)
	move.w	#$80c0,$96(a6)

	move.l	4,a0
	move.l	156(a0),a0
	move.l	38(a0),OldCop-S(a5)
	move.l	#CList,$80(a6)

	bsr.l	mt_init

	moveq	#0,d0
	moveq	#$28,d3
	move.w	#$6704,d4
	moveq	#-$17,d5			;$e9
	lea	PntSets,a0
	lea	CdeArea-S(a5),a1
.2	move.w	d0,d1
	move.w	d1,d2
	lsr.w	#3,d2
	not.b	d1
	and.b	#%111,d1
	add.b	d1,d1
	addq.b	#1,d1
	move.b	d1,(a0)+
	move.b	d3,(a0)+
	move.w	d2,(a0)+			;btst	Dx,x(a0)
	move.b	d1,(a1)+
	move.b	d5,(a1)+
	move.w	d2,(a1)+			;bset	Dx,X(a1)
	move.w	d4,(a0)+			;beq.b n+6
	addq.w	#4,a0
	addq.w	#1,d0
	cmp.w	#320,d0
	blt.s	.2
	move.w	#$4e75,(a0)+

	lea	PntSets,a0
	lea	PntSets+(8*400)+2,a1
	moveq	#27-1,d0
.3	WaitBlt
	move.l	#$09f00000,$40(a6)
	move.l	#$ffffffff,$44(a6)
	move.l	#$00000000,$64(a6)
	move.l	a0,$50(a6)
	move.l	a1,$54(a6)
	move.w	#400<<6+(8/2),$58(a6)
	add.l	#8*400,a1
	move.w	#$4e75,(a1)+			;rts
	dbf	d0,.3
	WaitBlt

	move.w	#140,d0
	moveq	#5,d1
	moveq	#28-1,d2
	lea	PntSets+6,a0
	lea	CdeArea-S(a5),a1
.5	move.w	#-4*1*(320/8),d3
.6	move.w	d3,d4
	muls	d0,d4
	divs	#280,d4
	add.w	#4*(320/8),d4
	lsl.w	#2,d4
	move.l	(a1,d4),(a0)+
	addq.l	#6,a0
	add.w	#1,d3
	cmp.w	#4*(320/8),d3
	blt.s	.6
	addq.l	#2,a0
	add.w	d1,d0
	dbf	d2,.5

;-------------------;

MveSprI	WaitBm	-1
	cmp.b	#$41,(MelSprt+1)-S(a5)
	beq.s	MainLp
	add.b	#1,(MelSprt+(0*44)+1)-S(a5)
	add.b	#1,(MelSprt+(1*44)+1)-S(a5)
	add.b	#1,(MelSprt+(2*44)+1)-S(a5)
	add.b	#1,(MelSprt+(3*44)+1)-S(a5)
	bra.s	MveSprI

;--------------------------------------;

MainLp	WaitBm	-3
	cmp.w	#0,LoopStp-S(a5)
	beq.l	PrntTxt
	cmp.w	#1,LoopStp-S(a5)
	beq.l	PutLine
	cmp.w	#2,LoopStp-S(a5)
	beq.l	WaitCnt
	cmp.w	#3,LoopStp-S(a5)
	beq.s	InsCols
	subq.w	#1,Count-S(a5)
	bpl.s	FadeTxt
	bra.l	End

;--------------------------------------;

InsCols	subq.w	#1,Count-S(a5)
	bpl.s	FadeTxt
	move.w	#501,Count-S(a5)
	move.w	#$2c09,LineOff-S(a5)
	clr.w	LoopStp-S(a5)
	move.w	#$f97,(Cols+02)-S(a5)
	move.w	#$f97,(Cols+06)-S(a5)
	move.w	#$f97,(Cols+10)-S(a5)
	move.w	#$f97,(Cols+14)-S(a5)
	move.w	#$f97,(Cols+18)-S(a5)
	move.w	#$f97,(Cols+22)-S(a5)
	move.w	#$f97,(Cols+26)-S(a5)
	move.w	#$f97,(Cols+30)-S(a5)
	bra.l	EndLoop

;-------------------;

FadeTxt	move.w	Count-S(a5),d2
	move.w	#$337,d0
	move.w	#$f97,d1
	bsr.l	Fade
	move.w	d3,(Cols+02)-S(a5)
	move.w	d3,(Cols+06)-S(a5)
	move.w	d3,(Cols+10)-S(a5)
	move.w	d3,(Cols+14)-S(a5)
	move.w	d3,(Cols+18)-S(a5)
	move.w	d3,(Cols+22)-S(a5)
	move.w	d3,(Cols+26)-S(a5)
	move.w	d3,(Cols+30)-S(a5)
	bra.l	EndLoop

;--------------------------------------;

WaitCnt	tst.w	Count-S(a5)
	bne.s	.1
	addq.w	#1,LoopStp-S(a5)
	move.w	#17,Count-S(a5)
.1	subq.w	#1,Count-S(a5)
	btst	#10,$16(a6)
	bne.l	EndLoop
	move.w	#4,LoopStp-S(a5)
	move.w	#16,Count-S(a5)
	bra.l	EndLoop

;--------------------------------------;

PrntTxt	move.l	TxtPntr-S(a5),a0
	lea	MelFont-S(a5),a1
	lea	Screen1+(3*(320/8))-S(a5),a2
	move.w	#$0100,$40(a6)
	move.w	#$0078,$66(a6)
	move.l	a2,$54(a6)
	move.w	#200<<6+(320/16),$58(a6)

	moveq	#0,d1
	WaitBlt
.1	move.b	(a0)+,d0
	bne.s	.3
	cmp.l	#TextEnd,a0
	bne.s	.2
	lea	MelText-S(a5),a0
.2	move.l	a0,TxtPntr-S(a5)
	addq.w	#1,LoopStp-S(a5)
	bra.l	EndLoop

.3	sub.b	#" ",d0
	bpl.s	.4
	sub.l	d1,a2
	add.l	#4*10*(320/8),a2
	moveq	#0,d1
	bra.s	.1

.4	ext.w	d0
	lsl.w	#3,d0
	move.b	0(a1,d0),(a2)+
	move.b	1(a1,d0),4*1*(320/8)-1(a2)
	move.b	2(a1,d0),4*2*(320/8)-1(a2)
	move.b	3(a1,d0),4*3*(320/8)-1(a2)
	move.b	4(a1,d0),4*4*(320/8)-1(a2)
	move.b	5(a1,d0),4*5*(320/8)-1(a2)
	move.b	6(a1,d0),4*6*(320/8)-1(a2)
	move.b	7(a1,d0),4*7*(320/8)-1(a2)
	addq.l	#1,d1
	bra.s	.1

;--------------------------------------;

PutLine	cmpa.l	#Screen1,a4
	beq.s	.1
	lea	Screen1-S(a5),a4
	bra.s	.2
.1	lea	Screen2-S(a5),a4

.2	moveq	#7-1,d0
	lea	4*200*(320/8)(a4),a0
	move.w	#$0000,$66(a6)
.3	move.w	#$0100,$40(a6)
	move.l	(a0)+,$54(a6)
	beq.s	.4
	move.w	#3<<6+(320/16),$58(a6)
	WaitBlt
.4	dbf	d0,.3

	move.w	TextScl-S(a5),d0
	move.w	TextY-S(a5),d1
	lea	4*200*(320/8)(a4),a3
CalcOff	move.w	d0,d2
	mulu	#(8*400)+2,d2
	lea	PntSets,a2
	add.l	d2,a2
	move.w	d1,d2
	mulu	#4*(320/8),d2
	lea	Screen1+(3*(320/8))-S(a5),a0
	add.l	d2,a0
	move.w	d1,d2
	add.w	d2,d2
	sub.w	#600,d2
	muls	d2,d2
	move.w	d1,d3
	mulu	d3,d3
	move.w	d1,d4
	mulu	#200,d4
	sub.l	d4,d3
	add.l	#10000,d3
	lsl.l	#2,d3
	sub.l	d3,d2
	bsr.l	CalcCrv
	add.w	#600,d3
	move.w	d1,d2
	add.w	d2,d2
	sub.w	d2,d3
	ext.l	d3
	lsl.l	#8,d3
	divs	#-1568,d3
	move.w	d0,d6
	muls	d6,d6
	muls	d3,d6
	add.l	#25600,d6
	muls	#-400,d3
	asl.l	#8,d3
	move.l	d3,d2
	bsr.l	CalcCrv
	muls	d0,d3
	add.l	d3,d6
	lsr.l	#8,d6
	cmp.w	#200,d6
	blt.s	.1
	move.w	#200-1,d6
.1	mulu	#4*(320/8),d6
	move.l	a4,a1
	add.l	d6,a1
	move.l	a1,(a3)+

Plot	movem.l	d0-d1,-(a7)
	moveq	#1,d1
	moveq	#2,d2
	moveq	#3,d3
	moveq	#4,d4
	moveq	#5,d5
	moveq	#6,d6
	moveq	#7,d7

	lsr.w	#2,d0

	btst	#0,d0
	beq.s	.1
	move.w	d0,-(a7)
	moveq	#0,d0
	jsr	(a2)
	move.w	(a7)+,d0
.1	lea	(320/8)(a1),a1
	btst	#1,d0
	beq.s	.2
	move.w	d0,-(a7)
	moveq	#0,d0
	jsr	(a2)
	move.w	(a7)+,d0
.2	lea	(320/8)(a1),a1
	btst	#2,d0
	beq.s	.3
	moveq	#0,d0
	jsr	(a2)
.3	movem.l	(a7)+,d0-d1

	addq.w	#4,d0
	cmp.w	#28,d0
	bge.s	AdjCopr
	subq.w	#1,d1
	bpl.l	CalcOff

AdjCopr	move.w	TextScl-S(a5),d0
	move.w	TextY-S(a5),d1
	addq.w	#1,d0
	cmp.w	#4,d0
	blt.s	.3
	cmp.w	#200-1,d1
	bne.s	.1
	move.w	d0,d2
	and.b	#%11,d2
	bne.s	.3
	addq.b	#1,LineOff-S(a5)
	bra.s	.3

.1	cmp.w	#7,d1
	blt.s	.2
	addq.b	#1,LineOff-S(a5)
.2	addq.w	#1,d1
	moveq	#0,d0
.3	cmp.w	#28,d0
	blt.s	.4
	move.b	#$f4,LineOff-S(a5)
	move.w	#2,LoopStp-S(a5)
	moveq	#0,d0
	moveq	#0,d1
.4	move.w	d0,TextScl-S(a5)
	move.w	d1,TextY-S(a5)
	clr.l	(a3)+

	move.l	a4,d0
	move.w	d0,(BPL+6)-S(a5)
	swap	d0
	move.w	d0,(BPL+2)-S(a5)
	swap	d0
	add.l	#(320/8),d0
	move.w	d0,(BPL+14)-S(a5)
	swap	d0
	move.w	d0,(BPL+10)-S(a5)
	swap	d0
	add.l	#(320/8),d0
	move.w	d0,(BPL+22)-S(a5)
	swap	d0
	move.w	d0,(BPL+18)-S(a5)

;--------------------------------------;

EndLoop	WaitBlt
	bsr.l	mt_music
	bra.l	MainLp

;--------------------------------------;

End	moveq	#64,d0
.1	WaitBm	-1
	bsr.l	mt_music
	move.b	d0,L128+07-S(a5)
	move.b	d0,L128+15-S(a5)
	move.b	d0,L135+09-S(a5)
	move.b	d0,L135+13-S(a5)
	move.b	d0,R1+3-S(a5)
	move.b	d0,R2+1-S(a5)
	move.b	d0,R3+3-S(a5)
	move.b	d0,R4+1-S(a5)

	cmp.b	#$31,(MelSprt+1)-S(a5)
	beq.s	.2
	sub.b	#1,(MelSprt+(0*44)+1)-S(a5)
	sub.b	#1,(MelSprt+(1*44)+1)-S(a5)
	sub.b	#1,(MelSprt+(2*44)+1)-S(a5)
	sub.b	#1,(MelSprt+(3*44)+1)-S(a5)
.2	dbf	d0,.1

	move.l	OldCop-S(a5),$80(a6)
	move.w	DMACon-S(a5),$96(a6)
	move.w	IntEna-S(a5),$9a(a6)
	bsr.l	mt_end
	movem.l	(a7)+,d0-a6
	rts

;--------------------------------------;

MelSprt	dc.w	$2e31,$3700
	dc.w	%1111111111111100,%1111111111111111
	dc.w	%1111111111111100,%1111111111111111
	dc.w	%1101011100110100,%1010101011011111
	dc.w	%1010101011010101,%1101011111111111
	dc.w	%1010101000010101,%1111111111111111
	dc.w	%1010101011110101,%1111111111111011
	dc.w	%1010101100011000,%1111111011110101
	dc.w	%1111111111111100,%1111111111111111
	dc.w	%1111111111111100,%1111111111111111
NullSpr	dc.w	0,0

	dc.w	$2e39,$3700
	dc.w	%0000000000000000,%1111111110000000
	dc.w	%0000000000000000,%1111111110000000
	dc.w	%1100111000000000,%1111111110000000
	dc.w	%0010100100000000,%1111111110000000
	dc.w	%0010100100000000,%1111111110000000
	dc.w	%0010100100000000,%1111111110000000
	dc.w	%1100100100000000,%1111111110000000
	dc.w	%0000000000000000,%1111111110110000
	dc.w	%0000000000000000,%1111111110110000
	dc.w	0,0

	dc.w	$3032,$3900
	dc.w	%1111111111111100,%1111111111111111
	dc.w	%1111111111111100,%1111111111111111
	dc.w	%1101011100110100,%1010101011011111
	dc.w	%1010101011010101,%1101011111111111
	dc.w	%1010101000010101,%1111111111111111
	dc.w	%1010101011110101,%1111111111111011
	dc.w	%1010101100011000,%1111111011110111
	dc.w	%1111111111111100,%1111111111111111
	dc.w	%1111111111111100,%1111111111111111
	dc.w	0,0

	dc.w	$303a,$3900
	dc.w	%0000000000000000,%1111111110000000
	dc.w	%0000000000000000,%1111111110000000
	dc.w	%1100111000000000,%1111111110000000
	dc.w	%0010100100000000,%1111111110000000
	dc.w	%0010100100000000,%1111111110000000
	dc.w	%0010100100000000,%1111111110000000
	dc.w	%1100100100000000,%1111111110000000
	dc.w	%0000000000000000,%1111111110110000
	dc.w	%0000000000000000,%1111111110110000
	dc.w	0,0

;--------------------------------------;

Music	include	"DH2:MelonSF2/Replay.i"

;--------------------------------------;

Fade	move.w	d1,d3
	move.w	d1,d4
	move.w	d1,d5
	and.w	#$f00,d3
	and.w	#$0f0,d4
	and.w	#$00f,d5
	move.w	d0,d6
	and.w	#$f00,d6
	sub.w	d6,d3
	move.w	d0,d6
	and.w	#$0f0,d6
	sub.w	d6,d4
	move.w	d0,d6
	and.w	#$00f,d6
	sub.w	d6,d5
	mulu	d2,d3
	mulu	d2,d4
	mulu	d2,d5
	asr.w	#4,d3
	asr.w	#4,d4
	asr.w	#4,d5
	and.w	#$ff00,d3
	and.w	#$fff0,d4
	move.w	d0,d6
	and.w	#$f00,d6
	add.w	d6,d3
	move.w	d0,d6
	and.w	#$0f0,d6
	add.w	d6,d4
	move.w	d0,d6
	and.w	#$00f,d6
	add.w	d6,d5
	or.w	d4,d3
	or.w	d5,d3
	rts

;--------------------------------------;

CalcCrv	move.l	d2,d3
	beq.s	.4
	moveq	#15,d4
	lsl.l	#1,d3
.1	bmi.s	.2
	bcs.s	.2
	subq.w	#1,d4
	lsl.l	#2,d3
	bra.s	.1

.2	moveq	#0,d3
	bset	d4,d3
.3	move.l	d2,d5
	divu	d3,d5
	add.w	d5,d3
	lsr.w	#1,d3
	cmp.w	d3,d4
	beq.s	.4
	move.w	d3,d4
	move.l	d2,d5
	divu	d4,d5
	add.w	d5,d4
	lsr.w	#1,d4
	cmp.w	d3,d4
	bne.s	.3
.4	rts

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$f4c1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$01fc,$0000,$0100,$4200		;$1fc,$0000, orig = $0096,$85f0
	dc.w	$0102,$0000,$0104,$0024
	dc.w	$0108,$0078,$010a,$0078

	dc.w	$0180,$0337,$0182,$0759
	dc.w	$0184,$094a,$0186,$0a5a
	dc.w	$0188,$0b59,$018a,$0c68
	dc.w	$018c,$0d68,$018e,$0e77
Cols	dc.w	$0190,$0f97,$0192,$0f97
	dc.w	$0194,$0f97,$0196,$0f97
	dc.w	$0198,$0f97,$019a,$0f97
	dc.w	$019c,$0f97,$019e,$0f97

	dc.w	$01a2,$0000,$01a4,$0fff
	dc.w	$01a6,$0000,$01aa,$0225
	dc.w	$01ac,$0225,$01ae,$0225

	dc.w	$0120,(MelSprt+(0*44))>>16,$0122,(MelSprt+(0*44))&$ffff
	dc.w	$0124,(MelSprt+(1*44))>>16,$0126,(MelSprt+(1*44))&$ffff
	dc.w	$0128,(MelSprt+(2*44))>>16,$012a,(MelSprt+(2*44))&$ffff
	dc.w	$012c,(MelSprt+(3*44))>>16,$012e,(MelSprt+(3*44))&$ffff
	dc.w	$0130,(NullSpr)>>16,$0132,(NullSpr)&$ffff
	dc.w	$0134,(NullSpr)>>16,$0136,(NullSpr)&$ffff
	dc.w	$0138,(NullSpr)>>16,$013a,(NullSpr)&$ffff
	dc.w	$013c,(NullSpr)>>16,$013e,(NullSpr)&$ffff

BPL	dc.w	$00e0,(Screen1+(0*320/8))>>16,$00e2,(Screen1+(0*320/8))&$ffff
	dc.w	$00e4,(Screen1+(1*320/8))>>16,$00e6,(Screen1+(1*320/8))&$ffff
	dc.w	$00e8,(Screen1+(2*320/8))>>16,$00ea,(Screen1+(2*320/8))&$ffff
	dc.w	$00ec,(Screen1+(3*320/8))>>16,$00ee,(Screen1+(3*320/8))&$ffff

LineOff	dc.w	$2c09,$fffe,$0100,$3200

	dc.w	$ffff,$fffe

;--------------------------------------;

MelFont	incbin	"DH2:MelonSF2/Melon.fnt"

;--------------------------------------;

Count	dc.w	500
TxtPntr	dc.l	MelText
LoopStp	dc.w	0
TextScl	dc.w	0
TextY	dc.w	0

;--------------------------------------;

MelText	incbin	"DH2:MelonSF2/Melon.txt"
TextEnd	even

;--------------------------------------;

mt_data	incbin	"DH2:MelonSF2/mod.micro"

;--------------------------------------;

;	Melon doesnt save area after this point, I only added it for
;	restructure compatibility.

;--------------------------------------;

DatArea	dcb.b	80,0
DMACon	dc.w	0
	dc.w	0
OldCop	dc.l	0
IntEna	dc.w	0
	dc.w	0

CdeArea	dcb.l	320,0

Screen1	dcb.b	4*200*(320/8),0
	dcb.b	32,0
Screen2	dcb.b	4*200*(320/8),0
	dcb.b	32,0

PntSets	dcb.b	28*((8*400)+2),0

	END

