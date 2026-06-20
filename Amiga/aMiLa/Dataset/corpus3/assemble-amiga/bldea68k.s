;	include	"comequ.s"
;	XDEF	BuildEa

;errors:
;memory
;ea forb
;An->OpSize==B?	->error
;#i->OpSize/Value	->error

;  #[ Build instruction:
;	 #[ BuildEa:
BuildEa:	;bsr	GetBinBuffer
	move.l	BinBuffer,a0
	move.l	a0,a1
	lea	22(a1),a1
	cmp.l	EndBinBuffer,a1
	bge.s	.realloc
.again:	moveq	#0,d0
	move.b	EA_mode(EAPTR),d0
	IFNE	EABLINDOS
	bmi.s	.rea
	cmp.w	#7,d0
	bhi.s	.rea
	ENDC	;EABLINDOS
	IFNE	_68000
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a1
	jmp	(a1)
	ELSEIF
	jmp	([.tab.w,pc,d0.w*4])
	ENDC	;_68000
	IFNE	EABLINDOS
.rea:	_Debugger
	rts
	ENDC	;EABLINDOS
.realloc:	jsr	UpdateBinBuffer
	jsr	BinAlloc
	move.l	d0,a0
	bra.s	.again
	dc.l	Errnot_imp	;mode -1
.tab:	dc.l	BuildDn		;mode 0 = Dn
	dc.l	BuildAn		;mode 1 = An
	dc.l	BuildAnIndir	;mode 2 = (An)
	dc.l	BuildAnPost	;mode 3 = (An)+
	dc.l	BuildAnPre	;mode 4 = -(An)
	dc.l	Buildd16An	;mode 5 = d16(An)
	dc.l	Build6		;mode 6 = MEM
	dc.l	Build7		;mode 7 = PC,@.w,@.l,#i
;	 #] BuildEa:
;	 #[ BuildDn:
BuildDn:	btst	#0,d7
	beq.s	.err
	rts
.err:	bra	Errdn_forb
;	 #] BuildDn:
;	 #[ BuildAn:
BuildAn:	tst.w	OpSize
	beq.s	.errsize
	btst	#1,d7
	beq.s	.err
	rts
.errsize:	bra	Erropsz_forb
.err:	bra	Erran_forb
;	 #] BuildAn:
;	 #[ BuildAnIndir:
BuildAnIndir:
	btst	#2,d7
	beq.s	.err
	rts
.err:	bra	Erranindir_forb
;	 #] BuildAnIndir:
;	 #[ BuildAnPost:
BuildAnPost:
	btst	#3,d7
	beq.s	.err
	rts
.err:	bra	Erranpost_forb
;	 #] BuildAnPost:
;	 #[ BuildAnPre:
BuildAnPre:
	btst	#4,d7
	beq.s	.err
	rts
.err:	bra	Erranpre_forb
;	 #] BuildAnPre:
;	 #[ BuildPcBrief:
BuildPCBrief:
	btst	#14,d7
	beq.s	.err
	moveq	#P_D8PC,d3
	bra.s	_BuildBrief
.err:	bra	Errd8PC_forb
;	 #] BuildPcBrief:
;	 #[ Build6:	;D8ANXN, BDANXN, BDAN_XNOD, BDANXN_OD
errbrief:	bra	Errd8An_forb
Build6:	tst.b	EA_mode2(EAPTR)
	bgt	BuildFull
;	 #] Build6:
;keep tight
;	 #[ BuildBrief:		;BRIEF_MODE+PCMEM
BuildBrief:
	btst	#6,d7
	beq.s	errbrief
	moveq	#P_ABSB,d3
_BuildBrief:
	moveq	#0,d4		;bit 8 a zero
	move.b	EA_xn(EAPTR),d4
	moveq	#TOKENA0,d2
	cmp.b	d2,d4
	blt.s	.noan
	sub.b	d2,d4
	bset	#7-4,d4		;D/A
.noan:	lsl.b	#4,d4		;Xn->12
	tst.b	EA_xnsz(EAPTR)
	beq.s	.word
	bset	#3,d4		;W/L
.word:	move.b	EA_xnsc(EAPTR),d1	;SCALE
	bne.s	.chkmpu
.achkmpu:	add.b	d1,d1		;<<1
	or.b	d1,d4
	lsl.w	#8,d4

	move.l	EA_vtype(EAPTR),d1
	bgt.s	.patch
.nopat:	move.b	EA_value+3(EAPTR),d4
	bra	WPokeBin
.chkmpu:	cmp.w	#MPU_10,MPUType
	bhi.s	.achkmpu
	bra	Errea20_forb
.patch:	;clr.b	d4
	bsr	WPokeBin
	move.l	EA_value(EAPTR),d0
	move.l	LINE_srcstart(FIELDPTR),a1
	move.l	FIELDPTR,a0
	cmp.b	#'(',(a0)
	bne.s	.nopar
	addq.w	#1,a0
	addq.w	#1,a1
.nopar:	move.w	d3,d2
	jmp	StoreEXP

BuildPCMem:
	tst.b	EA_mode2(EAPTR)
	beq	BuildPCBrief	;(d8,PC,Xn)
	btst	#15,d7		;(bd,PC,Xn),(bd,ZPC,Xn)
	beq.s	.err
	moveq	#%1000000,d2	;IS set (6)
	tst.b	EA_mode2(EAPTR)
	bgt.s	_BuildFull	;PC
	bset	#7,d2		;ZPC->BS set (7)
	bra.s	_BuildFull
.err:	bra	Errfull_forb
;	 #] BuildBrief:
;	 #[ BuildFull:		;FULL_MODE
errfull:	bra	Errfull_forb
BuildFull:
	btst	#7,d7
	beq.s	errfull
	moveq	#%1000000,d2	;IS set (6)
	tst.b	EA_an(EAPTR)
	bpl.s	.set
	tas	d2		;ZAn->BS set (7)
.set:
_BuildFull:
	cmp.w	#MPU_32,MPUType
	blt.s	.rmpu
	moveq	#1,d4		;full bit set (8)
	moveq	#0,d1		;registre tmp.b
	move.b	EA_xn(EAPTR),d1	;Xn
	bmi.s	.build		;ZXn->build
	bclr	#6,d2		;Xn->IS clr (6)
.xnadded:	cmp.b	#TOKEND7,d1
	ble.s	.dn
	bset	#7,d4		;D/A set (15)
	subq.b	#TOKENA0,d1
.dn:	lsl.b	#4,d1		;Xn<<4 (14-12)
	or.b	d1,d4
	tst.b	EA_xnsz(EAPTR)	;.S
	beq.s	.xsizew
	bset	#3,d4		;W/L (11)
.xsizew:	move.b	EA_xnsc(EAPTR),d1	;*S (10-9)
	add.b	d1,d1		;*S<<1
	or.b	d1,d4

.build:	lsl.w	#8,d4		;<<8
	move.b	d2,d4		;low byte with IS

	move.b	EA_bdsz(EAPTR),d1	;BD SIZE (5-4)
	move.b	d1,d2
	lsl.b	#4,d1
	or.b	d1,d4

	or.b	EA_odsz(EAPTR),d4	;OD SIZE + I/IS (POST) (2-0)
	bsr	WPokeBin

	subq.b	#1,d2		;bd
	ble.s	.nobd		;null
	bsr.s	buildbd
.nobd:	move.b	EA_odsz(EAPTR),d1	;OD	
	btst	#1,d1		;%10 11 110 111
	bne.s	buildod
	rts
.rmpu:	bra	Errea20_forb

buildod:	tst.l	EA_odvtype(EAPTR)
	bgt.s	.patch
	move.l	EA_odvalue(EAPTR),d4
	btst	#0,d1		;%10 110
	beq	WPokeBin
	bra	LPokeBin
.patch:	moveq	#0,d4
	btst	#0,d1		;%10 110
	beq.s	.ww
	bsr	LPokeBin
	moveq	#P_ABSL,d2
	bra.s	.dopatch
.ww:	bsr	WPokeBin
	moveq	#P_ABSW,d2
.dopatch:	moveq	#0,d0
	move.l	EA_odvtype(EAPTR),d1
	move.l	EA_odsrc(EAPTR),a0	;recuperation @ token
	move.l	LINE_srccomma(FIELDPTR),a1
	jmp	StoreEXP

buildbd:	move.l	EA_vtype(EAPTR),d1
	bgt.s	.patch
	move.l	EA_value(EAPTR),d4
	subq.b	#1,d2		;word
	beq	WPokeBin
	bra	LPokeBin
.patch:	moveq	#0,d4
	subq.b	#1,d2
	beq.s	.paw
	bsr	LPokeBin
	moveq	#P_ABSL,d2
	cmp.b	#PC_MODE,EA_mode(EAPTR)
	bne.s	.dopatch
	moveq	#P_BDPCL,d2
	bra.s	.dopatch
.paw:	bsr	WPokeBin
	moveq	#P_ABSW,d2
	cmp.b	#PC_MODE,EA_mode(EAPTR)
	bne.s	.dopatch
	moveq	#P_BDPCW,d2
.dopatch:	move.l	FIELDPTR,a0
	move.l	LINE_srcstart(FIELDPTR),a1
	move.l	EA_value(EAPTR),d0
	cmp.b	#'(',(a0)
	bne.s	.nopar
	cmp.b	#'[',1(a0)
	bne.s	.nobra
	addq.w	#2,a0
	addq.w	#2,a1
	jmp	StoreEXP
.nobra:	addq.w	#1,a0
	addq.w	#1,a1
.nopar:	jmp	StoreEXP

;	 #] BuildFull:
;	 #[ Build7:
Build7:	moveq	#0,d0
	move.b	EA_an(EAPTR),d0
	IFNE	EABLINDOS
	bmi.s	.err7
	cmp.w	#4,d0
	bhi.s	.err7
	ENDC	;EABLINDOS
	IFNE	_68000
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a0
	jmp	(a0)
	ELSEIF
	jmp	([.tab.w,pc,d0.w*4])
	ENDC	;_68000
	IFNE	EABLINDOS
.err7:	_Debugger
	rts
	ENDC	;EABLINDOS
	dc.l	Errnot_imp	;mode -1
.tab:	dc.l	BuildAbsShort	;abs.w
	dc.l	BuildAbsLong	;abs.l
	dc.l	BuildD16PC	;d16(PC)
	dc.l	BuildPCMem	;(bdPCXn)
	dc.l	BuildImm		;#i
;	 #] Build7:
;	 #[ BuildD16PC:		;d16PC
BuildD16PC:
	btst	#13,d7
	beq.s	.rforb
	move.l	EA_vtype(EAPTR),d1
	bgt.s	.patch
	move.w	EA_value+2(EAPTR),d4
	bra	WPokeBin
.patch:	moveq	#0,d4
	bsr	WPokeBin
	move.l	EA_value(EAPTR),d0
	move.l	LINE_srcstart(FIELDPTR),a1
	move.l	FIELDPTR,a0
	moveq	#P_D16PC,d2
	jmp	StoreEXP
.rforb:	bra	Errd16PC_forb
;	 #] BuildD16PC:
;	 #[ Buildd16An:		;d16An
Buildd16An:
	btst	#5,d7
	beq.s	.rforb
	move.l	EA_vtype(EAPTR),d1
	bgt.s	.patch
	move.w	EA_value+2(EAPTR),d4
	bra	WPokeBin
.patch:	moveq	#0,d4
	bsr	WPokeBin
	move.l	EA_value(EAPTR),d0
	move.l	LINE_srcstart(FIELDPTR),a1
	move.l	FIELDPTR,a0
	moveq	#P_D16,d2
	jmp	StoreEXP
.rforb:	bra	Errd16An_forb
;	 #] Buildd16An:
;	 #[ BuildImm:			;IMMEDIATE
BuildImm:	btst	#12,d7
	beq.s	.rforb
	move.l	EA_vtype(EAPTR),d1
	bgt.s	.patch
	move.l	EA_value(EAPTR),d4
	move.w	OpSize,d0
	beq.s	.imb
	subq.w	#1,d0
	beq.s	.imw
.iml:	bra	LPokeBin
.rforb:	bra	Errimm_forb

.imw:	cmp.l	#$ffff,d4		;-65535<=x<=65535
	bhi.s	.wmi
	bra	WPokeBin

.imb:	moveq	#127,d0		;-128<=x<=127
	cmp.l	d0,d4
	bhi.s	.bmi
	bra	WPokeBin		;127<=(unsigned x)<=0

.patch:	moveq	#0,d4
	move.l	EA_value(EAPTR),d0
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1			;'#'
	move.w	OpSize,d2
	subq.w	#1,d2			;B&W
	ble.s	.paw
.pal:	bsr	LPokeBin			;L
	moveq	#P_DCL,d2
	jmp	StoreEXP
.paw:	bsr	WPokeBin
	moveq	#P_DCW,d2
	jmp	StoreEXP

.wmi:	move.l	d4,d0
	swap	d0
	tst.w	d0
	beq.s	.wpoke
	addq.w	#1,d0
	beq.s	.wpoke
.rwgt:	bsr	Errw_gt
.wpoke:	bra	WPokeBin

.bmi:	move.l	d4,d0
	asr.l	#8,d0
	beq.s	.wpoke
	addq.l	#1,d0
	beq.s	.wpoke
.rbgt:	bsr	Errb_gt
	bra.s	.wpoke
;	 #] BuildImm:
;	 #[ BuildAbsShort:			;ABS SHORT
BuildAbsShort:
	btst	#10,d7
	beq.s	.rforb
	move.l	EA_vtype(EAPTR),d1
	bgt.s	.patch
	move.l	EA_value(EAPTR),d4
	cmp.l	#$7fff,d4
	bgt.s	.rwgt
	cmp.l	#-32768,d4
	blt.s	.rwgt
	bra	WPokeBin
.rwgt:	bsr	Errw_gt
	bra	WPokeBin
.patch:	moveq	#0,d4
	bsr	WPokeBin
	move.l	FIELDPTR,a0
	move.l	LINE_srcstart(FIELDPTR),a1
	move.l	EA_value(EAPTR),d0
	moveq	#P_ABSW,d2
	jmp	StoreEXP
.rforb:	bra	Errabsw_forb
;	 #] BuildAbsShort:
;	 #[ BuildAbsLong:
BuildAbsLong:				;ABS LONG
	btst	#11,d7
	beq.s	.rforb
	move.l	EA_vtype(EAPTR),d1
	bgt.s	.patch
	move.l	EA_value(EAPTR),d4
	bra	LPokeBin
.patch:	moveq	#0,d4
	bsr	LPokeBin
	move.l	FIELDPTR,a0
	move.l	LINE_srcstart(FIELDPTR),a1
	move.l	EA_value(EAPTR),d0
	moveq	#P_ABSL,d2
	jmp	StoreEXP
.rforb:	bra	Errabsl_forb
;	 #] BuildAbsLong:
;  #] Build instruction:

