
; ===================================================================
;
;  NoiseRunner Replay V1.0
;  By Chaos of Sanity
; 
; ===================================================================

; Module:
; $000  Name
; $00c  Samples
; $3b6  End
; $3b7  Repeat
; $3b8  Patternlist
; $43c  Patterns

; Limits:
; SETFILT must be 0 or 1
; no check at SETSPD
; MYPORT not supported
; ARP not supported

			rsreset
mtS_Volume		rs.w	1
mtS_Adress		rs.l	1
mtS_Lenght		rs.w	1
mtS_RepAdress		rs.l	1
mtS_RepLen		rs.w	1
mtS_Finetune		rs.w	1

			rsreset
mtV_LoopAdr		rs.l	1	; Adresse für Loop \
mtV_LoopLen		rs.w	1	; Länge für Loop   / 
mtV_EffJ		rs.w	1	; EffektNummer*4
mtV_EffA		rs.w	1	; EffektAttribute
mtV_Per			rs.w	1	; Period \
mtV_Vol			rs.w	1	; Volume /
mtV_MyPortPer		rs.w	1	; Period für Portamentio
mtV_VibratMem		rs.b	1	; Sicherheitsspeicher für Port
mtV_VibratCnt		rs.b	1	; Vibrato-Counter
mtV_MyPortSpd		rs.b	1	; Speed für Port
mtV_SampleOffset	rs.b	1
mtV_DMAMask		rs.w	1	; $0001-$0008 für DMACON (Retrig)
mtV_Sample		rs.w	1	; Altes Sample
mtV_SIZEOF		rs.w	0

			rsset	-128
mt_JmpNew		rs.l	16	; Effektsprungtabellen
mt_JmpOld		rs.l	16
mt_PatAds		rs.l	129	; Pattern-Adresstabelle (Ende -1)
mt_Module		rs.l	1	; Modul-Adresse
mt_JumpFirst		rs.w	1	; Einsprung in Loop
mt_RestList		rs.l	1	; Restart-Pattern (list-Position
mt_Pattern		rs.l	1	; akt. Pattern
mt_List			rs.l	1	; akt. PatListPos
mt_Counter		rs.w	1	; Notenzähler (abwärts)
mt_PatCnt		rs.w	1	; Rückwärtszähler für Patternende
mt_Speed		rs.w	1	; akt. Speed
mt_Zero			rs.w	1	; DMA-Zero-Word
mt_Break		rs.w	1	; PatternBreak
mt_Voice1		rs.b	mtV_SIZEOF
mt_Voice2		rs.b	mtV_SIZEOF
mt_Voice3		rs.b	mtV_SIZEOF
mt_Voice4		rs.b	mtV_SIZEOF
mt_SIZEOF		rs.w	0

mt_init	lea	mt_Vars(pc),a6		; a0 = Module
	move.l	a0,mt_Module(a6)

	lea	$43c(a0),a1		; a1 = Patterns
	lea	$3b8(a0),a2		; a2 = PatternList
	lea	mt_PatAds(a6),a3	; a3 = PatterAdresses
	move.l	a1,a4			; a4 = MaxAdr
	moveq	#127,d0
.a	moveq	#0,d1			; Ermittle Adresse und merke
	move.b	(a2)+,d1
	lsl.w	#8,d1
	lsl.l	#2,d1
	add.l	a1,d1
	move.l	d1,(a3)+
	cmp.l	a4,d1			; Ermittle höchstes Pattern
	blo.s	.ok
	move.l	d1,a4
.ok	dbf	d0,.a
	adda.w	#1024,a4		; a4 = SampleStart

	lea	$43c(a0),a3		; a3 = PatternStart
	lea	mt_Perio,a1		; a1 = FreqTab
.pats	move.w	#64*4-1,d7		; d0 = Notenzähler
.patl	move.w	(a3),d0
	move.w	2(a3),d1
	move.w	#$fff,d2		; d6 = Note
	moveq	#0,d3
	and.w	d0,d2
	beq.s	.patnn
	move.l	a1,a2
.patn	addq.w	#2,d3
	cmp.w	(a2)+,d2
	blo.s	.patn
.patnn	move.b	d3,d6
	move.w	d0,d2			; d3 = Stimme
	move.w	d1,d3
	rol.w	#8,d2
	rol.w	#4,d3
	and.w	#$00f0,d2
	and.w	#$000f,d3
	or.w	d2,d3
	lsl.w	#3,d3
	move.b	2(a3),d0		; d0/d1 = Effect
	move.b	3(a3),d1
	and.w	#$000f,d0
	beq.s	.e0			; Vertausche $00xx <-> $03xx
	cmp.w	#3,d0
	bne.s	.eo
	moveq	#0,d0
	bra.s	.eo
.e0	moveq	#3,d0
.eo	cmp.w	#$e,d0			; Special treatment $0edx
	bne.s	.ned
	moveq	#$fffffff0,d4
	and.b	d1,d4
	cmp.b	#$d0,d4
	bne.s	.ned
	moveq	#$08,d0			; $0edx -> $080x
	and.w	#$f,d1
.ned	add.w	d0,d0
	add.w	d0,d0

	move.b	d0,(a3)+		; EffT
	move.b	d1,(a3)+		; EffA
	move.b	d6,(a3)+		; Note
	move.b	d3,(a3)+		; Stimme

	dbf	d7,.patl
	cmpa.l	a3,a4
	bne.s	.pats

	lea	12+30(a0),a1		; a1 = SampleDaten
	lea	np_offsets(pc),a5
	move.l	a0,a2			; a2 = SampleNeu
	moveq	#31-1,d0
.bb	movem.w	(a1),d1-d4		; Lenght/Vol/rep/repl
	move.w	d1,d5
	move.l	a4,a3
	tst.w	d3
	beq.s	.norep
	add.w	d3,a3
	add.w	d3,a3
	move.w	d3,d5
	add.w	d4,d5
.norep	move.w	d2,d6			; d6 = Finetune
	ext.w	d2			; d2 = Volume
	move.w	d2,(a2)+		; Volume
	move.l	a4,(a2)+		; Adress
	move.w	d5,(a2)+		; Lenght
	move.l	a3,(a2)+		; RepAdr
	move.w	d4,(a2)+		; RepLen
	lsr.w	#8,d6
	add.w	d6,d6
	move.w	0(a5,d6.w),(a2)+

	adda.w	d1,a4
	adda.w	d1,a4
	adda.w	#30,a1
	dbf	d0,.bb

	or.b	#2,$bfe001
	move.w	#6,mt_Speed(a6)
	move.w	#6,mt_Counter(a6)
	move.w	#64,mt_PatCnt(a6)

	lea	mt_PatAds(a6),a2	; ListenPosition
	lea	$43c(a0),a1		; Errechne Restart-ListPos
	moveq	#0,d0
	move.b	$3b7(a0),d0
	addq.w	#1,d0
	and.w	#$7f,d0
	add.w	d0,d0
	add.w	d0,d0
	add.l	a2,d0
	move.l	d0,mt_RestList(a6)
	moveq	#0,d0			; Setze Endmarkierung
	move.b	$3b6(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	moveq	#-1,d1
	move.l	d1,0(a2,d0.w)
;	lea	15*4(a2),a2		;!!!!!!!!!!!!!!!!!!!!!!!
	move.l	(a2)+,mt_Pattern(a6)	; Erstes Pattern
	move.l	a2,mt_List(a6)

	lea	mt_Zero(a6),a0		; Totmachen
	move.l	a0,mt_Voice1+mtV_LoopAdr(a6)
	move.l	a0,mt_Voice2+mtV_LoopAdr(a6)
	move.l	a0,mt_Voice3+mtV_LoopAdr(a6)
	move.l	a0,mt_Voice4+mtV_LoopAdr(a6)
	moveq	#1,d0
	move.w	d0,mt_Voice1+mtV_LoopLen(a6)
	move.w	d0,mt_Voice2+mtV_LoopLen(a6)
	move.w	d0,mt_Voice3+mtV_LoopLen(a6)
	move.w	d0,mt_Voice4+mtV_LoopLen(a6)

	move.w	#$0001,mt_Voice1+mtV_DMAMask(a6)	; Init DmAMasks
	move.w	#$0002,mt_Voice2+mtV_DMAMask(a6)
	move.w	#$0004,mt_Voice3+mtV_DMAMask(a6)
	move.w	#$0008,mt_Voice4+mtV_DMAMask(a6)

	lea	mt_Jmps(pc),a1		; Init JmpTable
	lea	mt_JmpNew(a6),a2
	lea	mt_init(pc),a3
	moveq	#31,d0
.llx	move.w	(a1)+,a4
	add.l	a3,a4
	move.l	a4,(a2)+
	dbf	d0,.llx

	rts

mt_end	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
mt_endL	rts

mt_music	lea	mt_Vars(pc),a6		; a6 = Vars
		subq.w	#1,mt_Counter(a6)	; Neue Note ?
		beq.s	mt_New			; Ja

		tst.w	mt_JumpFirst(a6)	; Schlage Note neu an?
		beq.s	mt_Loop1
mt_Loop2	sf	mt_JumpFirst(a6)	; JA!
		lea	$dff0a0,a5
		lea	mt_Voice1+mtV_LoopAdr(a6),a0
		move.l	(a0)+,(a5)+
		move.w	(a0)+,(a5)+
		lea	10(a5),a5
		lea	mtV_SIZEOF-6(a0),a0
		move.l	(a0)+,(a5)+
		move.w	(a0)+,(a5)+
		lea	10(a5),a5
		lea	mtV_SIZEOF-6(a0),a0
		move.l	(a0)+,(a5)+
		move.w	(a0)+,(a5)+
		lea	10(a5),a5
		lea	mtV_SIZEOF-6(a0),a0
		move.l	(a0)+,(a5)+
		move.w	(a0)+,(a5)+

mt_Loop1	lea	$dff0a0-8,a5		; Alte note weiterspielen
		lea	mt_Voice1+mtV_LoopAdr-mtV_SIZEOF+10(a6),a0
		moveq	#4,d0
mt_Loop		subq.w	#1,d0
		bmi.s	mt_endL
		lea	mtV_SIZEOF-10+6(a0),a0
		lea	8+6(a5),a5
		move.w	(a0)+,d1
		move.w	(a0)+,d2
		move.l	mt_JmpOld(a6,d1.w),a1
		jmp	(a1)


; Spiele neue Noten

mt_New		move.l	mt_Pattern(a6),a5	; a5 = Pattern

		lea	$dff0a0,a4		; a4 = Hardware
		lea	mt_Voice1(a6),a3	; a3 = Voice
		move.l	mt_Module(a6),a1	; a1 = Module
		moveq	#0,d2			; d2 = EffectJmp
		moveq	#0,d3			; d3 = EffectAttr
		moveq	#1,d7			; d7 = DMABit
		moveq	#3,d6
		bra.w	mt_Play


; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,233
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 0, Normal
mt_Perio:
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113



; Eine neue Note

mt_Play		move.b	(a5)+,d2		; Effect Jump
		move.b	(a5)+,d3		; Effect Attribut
		move.w	d3,mtV_EffA(a3)
		move.w	d2,mtV_EffJ(a3)
		beq	.MyPort			; 0 = Portamento
		cmp.b	#5*4,d2			; 5 = Port+Vol
		beq	.MyPort

		moveq	#0,d1			; Hole Note
		move.b	(a5)+,d1
		beq	.notone
		move.w	d1,d4

		move.b	(a5)+,d1		; Hole Sample
		beq.s	.nonot1a		; -> kein neues Sample
		add.w	d1,d1
		move.w	d1,mtV_Sample(a3)
		lea	-16(a1,d1.w),a2
		move.w	(a2)+,d0		; d0 = Per:Volume
.nonot1b	cmp.b	#8*4,d2
		beq.s	.edx_skip
		move.w	d7,$dff096		; Note anschlagen
		move.l	(a2)+,(a4)+		; Adress
		move.w	(a2)+,(a4)+		; Lenght
		move.l	(a2)+,mtV_LoopAdr(a3)	; RepAdress
		move.w	(a2)+,mtV_LoopLen(a3)	; RepLen
		add.w	(a2),d4

		swap	d0
		lea	mt_Perio(pc),a0
		move.w	-2(a0,d4.w),d0
		move.w	d0,mtV_MyPortPer(a3)
		swap	d0

		move.b	#0,mtV_VibratCnt(a3)

		move.l	mt_JmpNew(a6,d2.w),a0	; Spiele Effekt
		jmp	(a0)

.edx_skip	adda.w	#12,a2
		add.w	(a2),d4

		swap	d0
		lea	mt_Perio(pc),a0
		move.w	-2(a0,d4.w),d0
		move.w	d0,mtV_MyPortPer(a3)
		swap	d0

		move.b	#0,mtV_VibratCnt(a3)
		addq.l	#6,a4
		bra	mtX_ED1

.nonot1a	move.w	mtV_Sample(a3),d1	; Altes Sample
		lea	-16+2(a1,d1.w),a2
		move.w	mtV_Vol(a3),d0		; Alte Lautstärke
		bra.s	.nonot1b		; Weitermachen


; Routine für Portamento

.MyPort		moveq	#0,d1			; Hole Note
		move.b	(a5)+,d1
		beq.s	.notone2
		move.w	d1,d4

		move.b	(a5)+,d1		; Hole Sample
		beq.s	.nonot2a
		add.w	d1,d1
		move.w	d1,mtV_Sample(a3)
		lea	-16(a1,d1.w),a2
		move.w	mtV_Per(a3),d0
		swap	d0
		move.w	(a2)+,d0		; d0 = Per:Volume
		addq.w	#6,a2
.nonot2b	move.l	(a2)+,mtV_LoopAdr(a3)	; RepAdress
		move.w	(a2)+,mtV_LoopLen(a3)	; RepLen

		add.w	(a2),d4
		lea	mt_Perio(pc),a2
		move.w	-2(a2,d4.w),mtV_MyPortPer(a3)

		addq.l	#6,a4
		bra	mtX_No1

.nonot2a	move.w	mtV_Sample(a3),d1	; Altes Sample
		lea	-16+8(a1,d1.w),a2
		move.l	mtV_Per(a3),d0		; Lautstärke und Period
		bra.s	.nonot2b


; Keine Note (kein Portamento)

.notone		move.b	(a5)+,d1		; Instrument
		beq.s	.nonot3a
		add.w	d1,d1
		move.w	d1,mtV_Sample(a3)
		lea	-16(a1,d1.w),a2
		move.w	mtV_Per(a3),d0
		swap	d0
		move.w	(a2)+,d0		; d0 = Per:Volume
		move.b	#0,mtV_VibratCnt(a3)
.nonot3b	addq.w	#6,a4
		move.l	mt_JmpNew(a6,d2.w),a0
		jmp	(a0)

.nonot3a	move.l	mtV_Per(a3),d0		; Lautstärke und Period
		bra.s	.nonot3b


; Keine Note, Portamento

.notone2	move.w	mtV_Per(a3),d0
		swap	d0
		move.b	(a5)+,d1		; Instrument
		beq.s	.nonot4a
		add.w	d1,d1
		move.w	d1,mtV_Sample(a3)
		lea	-16(a1,d1.w),a2
		move.w	(a2)+,d0		; d0 = Per:Volume
.nonot4b	addq.l	#6,a4
		bra	mtX_No1

.nonot4a	move.w	mtV_Vol(a3),d0		; Lautstärke
		bra.s	.nonot4b


mtX_PosJmp:
	move.l	d0,(a4)+
	move.l	d0,mtV_Per(a3)
	add.w	d3,d3
	add.w	d3,d3
	lea	mt_PatAds(a6,d3.w),a0
	moveq	#0,d3
	move.l	a0,mt_List(a6)
mtX_PatBrk:
	moveq	#$f,d2
	and.b	d3,d2
	lsr.b	#4,d3
	mulu.w	#10,d3
	add.w	d2,d3
	not.b	d3
	move.b	d3,mt_Break(a6)
	bra.s	mtX_No1
mtX_SetSpd:
	move.b	d3,mt_Speed+1(a6)
	subq.b	#1,d3
	move.b	d3,mt_Counter+1(a6)
	bra.s	mtX_No1

mtX_SplOff:
	moveq	#0,d2
	move.b	d3,d2
	BEQ.S	.sononew
	MOVE.B	D2,mtV_SampleOffset(A3)
.sononew	MOVE.B	mtV_SampleOffset(A3),D2
	LSL.W	#7,D2
	move.W	mtS_Lenght-mtS_Finetune(A2),D3
	SUB.W	D2,d3
	move.w	d3,-2(a4)
	add.w	d2,D2
	move.l	mtS_Adress-mtS_Finetune(A2),D3
	ADD.L	D2,d3
	move.l	d3,-6(a4)
	moveq	#0,d2
	moveq	#0,d3
	bra.s	mtX_No1

mtX_Error1:
	bra.s	mtX_No1

mtX_SetVol:
	move.b	d3,d0
mtX_No1	move.l	d0,(a4)+			; Per:Volume
mtX_No1b	move.l	d0,mtV_Per(a3)

	addq.w	#6,a4
	lea	mtV_SIZEOF(a3),a3
	add.w	d7,d7
	dbf	d6,mt_Play

	tst.w	mt_Break(a6)
	bne.s	.patbr

	subq.w	#1,mt_PatCnt(a6)		; Pattern zuende ?
	beq.s	.next
	bra.s	.endr

.patbr	moveq	#64,d1
	moveq	#0,d0
	move.b	mt_Break(a6),d0
	not.b	d0
	sub.b	d0,d1
	move.w	#0,mt_Break(a6)
	move.w	d1,mt_PatCnt(a6)
	move.l	mt_List(a6),a0		; Next Pattern
	move.l	(a0)+,d1
	move.l	d1,a5
	bpl.s	.ok2
	move.l	mt_RestList(a6),a0
	move.l	(a0)+,a5
.ok2	lsl.w	#4,d0
	adda.w	d0,a5
	bra.s	.ok

.next	move.w	#64,mt_PatCnt(a6)
	move.l	mt_List(a6),a0		; Next Pattern
	move.l	(a0)+,d0
	move.l	d0,a5
	bpl.s	.ok
	move.l	mt_RestList(a6),a0
	move.l	(a0)+,a5
.ok	move.l	a0,mt_List(a6)
.endr	move.l	a5,mt_Pattern(a6)		; Note weiterschalten
	move.w	mt_Speed(a6),mt_Counter(a6)
	st	mt_JumpFirst(a6)
	rts

MyPort2a	move.w	mtV_MyPortSpd-mtV_Per(a0),d2
		bra.s	MyPort2

mtX_MyPort	tst.w	d2
		beq.s	MyPort2a
		move.w	d2,mtV_MyPortSpd-mtV_Per(a0)
MyPort2		move.w	(a0),d3
		move.w	mtV_MyPortPer-mtV_Per(a0),d1
		cmp.w	d3,d1
		bpl.s	.down
		beq.s	mtX_No2
.up		sub.w	d2,d3
		cmp.w	d1,d3
		bhi.s	.put
		move.w	d1,(a5)+
		move.w	d1,(a0)
		bra	mt_Loop
.put		move.w	d3,(a5)+
		move.w	d3,(a0)
		bra	mt_Loop
.down		add.w	d2,d3
		cmp.w	d1,d3
		blo.s	.put
		move.w	d1,(a5)+
		move.w	d1,(a0)
		bra	mt_Loop

mtX_Error2:
mtX_No2
	addq.w	#2,a5
	bra	mt_Loop

mtX_PortUp:
	sub.w	d2,(a0)
	move.w	(a0),(a5)+
	bra	mt_Loop

mtX_PortDw:
	add.w	d2,(a0)
	move.w	(a0),(a5)+
	bra	mt_Loop

mtX_Vibrat:
	tst.b	d2
	bne.s	mtX_VIB1
mtX_Vib	move.b	mtV_VibratMem-mtV_Per(a0),d2
	bra.s	mtX_VIB2
mtX_VIB1	move.b	d2,mtV_VibratMem-mtV_Per(a0)
mtX_VIB2	moveq	#$7f,d3
	and.b	mtV_VibratCnt-mtV_Per(a0),d3
	lsr.w	#2,d3
	move.b	mt_sin(pc,d3.w),d3
	move.w	d2,d1
	and.w	#$f,d1
	mulu	d1,d3
	lsr.w	#7,d3
	move.w	(a0),d1
	tst.b	mtV_VibratCnt-mtV_Per(a0)
	bmi.s	.x
	add.w	d3,d1
	bra.s	.y
.x	sub.w	d3,d1
.y	move.w	d1,(a5)+
	lsr.w	#2,d2
	and.w	#$3c,d2
	add.b	d2,mtV_VibratCnt-mtV_Per(a0)
	bra	mt_Loop

mt_sin	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mtX_VolSld:
	bsr.s	VolSld
	bra	mt_Loop

mtX_VibVol:
	bsr.s	VolSld
	subq.w	#2,a5
	bsr	mtX_Vib
	bra	mt_Loop

mtX_SldVol:
	bsr.s	VolSld
	subq.w	#2,a5
	bra	MyPort2a

VolSld	move.w	d2,d3
	addq.w	#2,a5
	asr.b	#4,d2
	beq.s	.a
	add.w	2(a0),d2
	cmp.w	#$40,d2
	bmi.s	.b2
	move.w	#$40,d2
.b2	move.w	d2,(a5)
	move.w	d2,2(a0)
	bra	mt_Loop

.a	and.w	#$f,d3
	neg.b	d3
	add.b	3(a0),d3
	bpl.s	.a2
	moveq	#0,d3
.a2	move.b	d3,3(a0)
	move.w	d3,(a5)
	rts

mtX_ECmds1:				; Start-Effekte
	moveq	#$fffffff0,d3
	and.b	d2,d3
	cmp.b	#$D0,d3			; NoteDelay
	beq.s	mtX_ED1

	IFD	DEBUG			; Wird der Befehl gehandelt?
	move.w	#$2200,d3
	lsr.b	#4,d2
	btst	d2,d3
	ENDC

	bra	mtX_No1

mtX_ED1	move.w	#$40,d0
;	move.w	#$fff,$dff180
	bra	mtX_No1

mtX_ECmds2:				; Drin-Effekte
	moveq	#$fffffff0,d3
	and.b	d2,d3
	cmp.b	#$90,d3			; Retrig
	beq.b	_2E9
	cmp.b	#$c0,d3			; Stop Note
	beq.b	_2EC
	cmp.b	#$d0,d3			; NoteDelay
	beq.b	mtX_ED2

	bra	mtX_No2

_2E9		move.b	mt_Speed+1(a6),d3
		sub.b	mt_Counter+1(a6),d3
		and.b	#$f,d2
		cmp.b	d2,d3
		bne	mtX_No2

		move.w	mtV_Sample-mtV_Per(a0),d3	; Altes Sample
		move.l	mt_Module(a6),a1		; a1 = Module
		lea	-16+2(a1,d3.w),a1
		move.l	(a1)+,-6(a5)			; Adress
		move.w	(a1)+,-2(a5)			; Lenght
		move.w	mtV_DMAMask-mtV_Per(a0),$dff096	; DMA

		st	mt_JumpFirst(a6)
		bra	mtX_No2


_2EC		move.b	mt_Speed+1(a6),d3
		sub.b	mt_Counter+1(a6),d3
		and.b	#$f,d2
		cmp.b	d2,d3
		bne	mtX_No2
		addq.l	#2,a5				; Ton Aus
		clr.w	(a5)
		bra	mt_Loop

mtX_ED2		move.b	mt_Speed+1(a6),d3
		sub.b	mt_Counter+1(a6),d3
		and.b	#$f,d2
		cmp.b	d2,d3
		bne	mtX_No2

		move.w	mtV_Sample-mtV_Per(a0),d3	; Altes Sample
		move.l	mt_Module(a6),a1		; a1 = Module
		lea	-16(a1,d3.w),a1
		move.w	(a1)+,mtV_Vol-mtV_Per(a0)	; Volume
		move.l	(a1)+,-6(a5)			; Adress
		move.w	(a1)+,-2(a5)			; Lenght
		move.l	(a1)+,mtV_LoopAdr-mtV_Per(a0)	; RepAdress
		move.w	(a1)+,mtV_LoopLen-mtV_Per(a0)	; RepLen
		move.w	mtV_DMAMask-mtV_Per(a0),$dff096	; DMA

		addq.l	#2,a5				; Ton An
		move.w	mtV_Vol-mtV_Per(a0),(a5)
		st	mt_JumpFirst(a6)

		bra	mt_Loop


np_offsets:
	dc.w	-00*72
	dc.w	-01*72
	dc.w	-02*72
	dc.w	-03*72
	dc.w	-04*72
	dc.w	-05*72
	dc.w	-06*72
	dc.w	-07*72
	dc.w	-08*72
	dc.w	-09*72
	dc.w	-10*72
	dc.w	-11*72
	dc.w	-12*72
	dc.w	-13*72
	dc.w	-14*72
	dc.w	-15*72

np_periods:


mt_Jmps	dc.w	mtX_No1-mt_init		; 3	; Init
	dc.w	mtX_No1-mt_init		; 1
	dc.w	mtX_No1-mt_init		; 2
	dc.w	mtX_No1-mt_init		; 0
	dc.w	mtX_No1-mt_init		; 4
	dc.w	mtX_No1-mt_init		; 5
	dc.w	mtX_No1-mt_init		; 6
	dc.w	mtX_Error1-mt_init	; 7
	dc.w	mtX_ED1-mt_init		; 8
	dc.w	mtX_SplOff-mt_init	; 9
	dc.w	mtX_No1-mt_init		; a
	dc.w	mtX_PosJmp-mt_init	; b
	dc.w	mtX_SetVol-mt_init	; c
	dc.w	mtX_PatBrk-mt_init	; d
	dc.w	mtX_ECmds1-mt_init	; e
	dc.w	mtX_SetSpd-mt_init	; f

	dc.w	mtX_MyPort-mt_init	; 3	; Hold
	dc.w	mtX_PortUp-mt_init	; 1
	dc.w	mtX_PortDw-mt_init	; 2
	dc.w	mtX_No2-mt_init		; 0
	dc.w	mtX_Vibrat-mt_init	; 4
	dc.w	mtX_SldVol-mt_init	; 5
	dc.w	mtX_VibVol-mt_init	; 6
	dc.w	mtX_Error2-mt_init	; 7
	dc.w	mtX_ED2-mt_init		; 8
	dc.w	mtX_No2-mt_init		; 9
	dc.w	mtX_VolSld-mt_init	; a
	dc.w	mtX_No2-mt_init		; b
	dc.w	mtX_No2-mt_init		; c
	dc.w	mtX_No2-mt_init		; d
	dc.w	mtX_ECmds2-mt_init	; e
	dc.w	mtX_No2-mt_init		; f

	dcb.b	128,0
mt_Vars	dcb.b	mt_SIZEOF
