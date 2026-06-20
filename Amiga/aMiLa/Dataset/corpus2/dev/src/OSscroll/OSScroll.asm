SYSI	equ	1
	include	"ssmac.i"	; include the macros
	start			; or clistart if you want only CLI

Wid	equ	320
Hei	equ	200
Obw	equ	640		; Picture - width
Obh	equ	487		; Picture - height
Dep	equ	8		; O neco niz je movem.l d0-d7 !!!
Obl	equ	Obw*Obh
	dv.w	x
	dv.w	y
	dv.w	dx
	dv.w	dy
	dv.l	req
	dv.l	s1
	dv.l	obr
	dv.l	fh
	dv.l	proc
	dv.l	cop
	dv.l	screenmagic
	dv.l	task
	dv.l	gonext
	dv.l	oldpri
	dbuf.l	tag,22
	dbuf.l	dtag,10

;	WORD    bm_BytesPerRow
;	WORD    bm_Rows
;	BYTE    bm_Flags
;	BYTE    bm_Depth
;	WORD    bm_Pad
;	STRUCT  bm_Planes,8*4
;	LABEL   bm_SIZEOF

	dv.w	BytesPerRow
	dv.w	Rows
	dv.b	Flags
	dv.b	Depth
	dv.w	Pad
	dbuf.l	bpl,8				; Planes

	dbuf.b	bar,256*12+8			; Barvicky
	dbuf.b	inter,IS_SIZE
	dbuf.b	rezerva,100

	move.l	4.w,a6			; exec
	move.l	ThisTask(a6),a1
	move.l	a1,task(a5)

	moveq	#39,d0
	call	SetTaskPri
	move.b	d0,oldpri(a5)

	lea	inter(a5),a1
	move.b	#NT_INTERRUPT,LN_TYPE(a1)
	move.b	#120,LN_PRI(a1)
	lea	inrname(PC),a0
	move.l	a0,LN_NAME(a1)
	move.l	a5,IS_DATA(a1)
	lea	IntRout(PC),a0
	move.l	a0,IS_CODE(a1)

	moveq	#INTB_COPER,d0
	call	AddIntServer		; A1=Interrupt Structure

	moveq	#ucl_SIZEOF,d0
	move.l	#MEMF_PUBLIC|MEMF_CLEAR,d1	
	call	AllocMem
	move.l	d0,cop(a5)
	beq	VeryBad

	move.l	#Obl+8,d0
	moveq	#MEMF_CHIP,d1
	call	AllocMem
	move.l	d0,obr(a5)
	beq	Bad

	lea	obName(pc),a0
	moveq	#OPEN_OLD,d0
	call	ss,TrackOpen
	move.l	d0,fh(a5)

	move.l	d0,d1
	move.l	obr(a5),d2
	move.l	#Obl,d3
	call	dos,Read


	lea	BytesPerRow(a5),a0		; Creating BitMap
	move.w	#Obw/8,(a0)+
	move.w	#Hei,(a0)+
	clr.b	(a0)+			; Flags
	move.b	#Dep,(a0)+		; Depth
	clr.w	(a0)+			; Pad
;	lea	bpl(a5),a0
	move.l	obr(a5),d0
	moveq	#Dep-1,d7
L2	move.l	d0,(a0)+
	add.l	#Obl/Dep,d0
	dbra	d7,L2


	lea	bar(a5),a0			; Creating palette
	move.l	#$01000000,(a0)+
	moveq	#0,d0
	move.w	#255,d1
L1	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	add.l	#$01000000,d0
	dbra	d1,L1

	; Potom nasleduje 0, ktera zakonci loudeni barev

	moveq	#ASL_ScreenModeRequest,d0	; ASL-ing
	sub.l	a0,a0
	call	asl,AllocAslRequest
	move.l	d0,req(a5)
	beq	Noasl
	move.l	d0,a0
	lea	asltag(PC),a1
	call	asl,AslRequest
	tst.l	d0
	beq	Fatal

	move.l	req(a5),a0			; Creating TagList for screen
	lea	tag(a5),a1
	move.l	#SA_DisplayID,(a1)+
	move.l	(a0)+,(a1)+
	move.l	#SA_Width,(a1)+
	move.l	(a0)+,(a1)+
	move.l	#SA_Height,(a1)+
	move.l	(a0)+,(a1)+
	move.l	#SA_Depth,(a1)+
	move.l	#Dep,(a1)+
	move.l	#SA_Quiet,(a1)+
	move.l	#TRUE,(a1)+
	move.l	#SA_BitMap,(a1)+
	lea	BytesPerRow(a5),a0
	move.l	a0,(a1)+
	move.l	#SA_Colors32,(a1)+
	lea	bar(a5),a0
	move.l	a0,(a1)+

	move.l	cop(a5),a0
	moveq	#10,d0				; Kolik instrukci udrzi coplist
	call	graphics,UCopperListInit
	tst.l	d0
	beq	Fatal

	move.l	cop(a5),a1			; Vyrabim CopperList
	moveq	#0,d0				; Kam az pockam ?
	moveq	#0,d1
	call	CWait
	move.l	cop(a5),a1
	call	CBump
	move.l	cop(a5),a1
	move.l	#intreq,d0			; Kam zapisuji
	move.w	#INTF_SETCLR+INTF_COPER,d1
	call	CMove
	move.l	cop(a5),a1
	call	CBump
	move.l	cop(a5),a1
	move.w	#10000,d0			; = CEND
	move.w	#255,d1
	call	CWait

	sub.l	a0,a0				; Opening SCREEN
	lea	tag(a5),a1
	call	intuition,OpenScreenTagList
	move.l	d0,s1(a5)
	beq	Fatal

	addq.l	#1,screenmagic(a5)		; Info for IntRout

	move.l	d0,a0				; Enabling CopperLists
	move.l	cop(a5),a1
	move.l	a1,sc_ViewPort+vp_UCopIns(a0)

	move.l	sc_ViewPort+vp_ColorMap(a0),a0
	lea	CopTag(pc),a1
	call	graphics,VideoControl
	tst.l	d0
	bne	ending
	call	intuition,RethinkDisplay

	move.l	s1(a5),a0			; Filling a2,a3,a4
	lea	sc_BitMap+bm_Planes(a0),a2
	move.l	sc_RastPort+rp_BitMap(a0),a3
	addq.l	#bm_Planes,a3
	move.l	sc_ViewPort+vp_RasInfo(a0),a4
	move.l	ri_BitMap(a4),a4
	addq.l	#bm_Planes,a4


;	addq.w	#3,dx(a5)
;	addq.w	#2,dy(a5)

	; Tady uz musi byt aktivovany Copper-Interrupt, jinak ztuhnu
	;	!!	!!	!!	!!	!!	!!

	moveq	#0,d0
	moveq	#-1,d1
	call	exec,SetSignal			; Vynulovat breaky


Loop	moveq	#1,d0
	call	lowlevel,ReadJoyPort
	move.l	d0,d1
	and.l	#JP_TYPE_MASK,d1
	cmp.l	#JP_TYPE_MOUSE,d1
	beq.s	.nojoy

	btst.l	#JPB_JOY_DOWN,d0
	beq.s	.nodown
	addq.w	#4,y(a5)

.nodown	btst.l	#JPB_JOY_UP,d0
	beq.s	.noup
	subq.w	#4,y(a5)

.noup	btst.l	#JPB_JOY_RIGHT,d0
	beq.s	.noright
	addq.w	#4,x(a5)

.noright btst.l	#JPB_JOY_LEFT,d0
	beq.s	.noleft
	subq.w	#4,x(a5)

.noleft
.nojoy
	move.w	x(a5),d6
	add.w	dx(a5),d6
	bpl.s	prx1
	moveq	#0,d6
	neg.w	dx(a5)
prx1	cmp.w	#Obw-Wid,d6
	blt.s	prx2
	neg.w	dx(a5)
	move.w	x(a5),d6
prx2	move.w	d6,x(a5)

	move.w	y(a5),d7
	add.w	dy(a5),d7
	bpl.s	pry1
	moveq	#0,d7
	neg.w	dy(a5)
pry1	cmp.w	#Obh-Hei,d7
	blt.s	pry2
	neg.w	dy(a5)
	move.w	y(a5),d7
pry2	move.w	d7,y(a5)
	muls	#Obw,d7

	ext.l	d6
	add.l	d7,d6
	move.w	d6,d7
	and.w	#$3F,d7
	eor.w	d7,d6
	asr.l	#3,d6


	movem.l	bpl(a5),a0/a1/d0-d5

	add.l	d6,a0
	add.l	d6,a1
	add.l	d6,d0
	add.l	d6,d1
	add.l	d6,d2
	add.l	d6,d3
	add.l	d6,d4
	add.l	d6,d5

;	call	exec,Forbid
	movem.l	a0/a1/d0-d5,(a2)
	movem.l	a0/a1/d0-d5,(a3)
	movem.l	a0/a1/d0-d5,(a4)

	move.l	s1(a5),a1
	lea	sc_ViewPort(a1),a0
	move.l	a0,d6
	move.l	vp_RasInfo(a0),a1
	move.w	d7,ri_RxOffset(a1)
;	call	Permit

	move.l	#(1<<$F)+(1<<$C),d0
	call	exec,Wait
	btst	#SIGBREAKB_CTRL_C,d0
	bne.s	ending

	addq.l	#1,gonext(a5)			; Aby se to tu moc nehromadilo

	move.l	d6,a0
	call	graphics,ScrollVPort

	clr.l	gonext(a5)

	moveq	#0,d0
	moveq	#-1,d1
	call	exec,SetSignal
	beq	Loop				; *****   End of Main LOOP



ending	move.l	s1(a5),a0
	lea	sc_ViewPort(a0),a0
	call	graphics,FreeVPortCopLists
	clr.l	cop(a5)

	clr.l	screenmagic(a5)

	move.l	s1(a5),a0
	call	intuition,CloseScreen

Fatal	move.l	req(a5),a0
	call	asl,FreeAslRequest

Noasl	move.l	obr(a5),a1
	move.l	#Obl+8,d0
	call	exec,FreeMem

Bad	move.l	cop(a5),d0
	beq.s	VeryBad
	move.l	d0,a1
	moveq	#ucl_SIZEOF,d0
	call	FreeMem

VeryBad	lea	inter(a5),a1			; Remove copper interrupt
	moveq	#INTB_COPER,d0
	call	exec,RemIntServer

	move.b	oldpri(a5),d0
	move.l	task(a5),a1
	call	SetTaskPri

Death	rts


IntRout	tst.l	screenmagic(a1)		; A1=is_Data   D1,A0,A6=scratch
	beq.s	NoMagic
;	bchg.b #1,$bfe001		;Toggle the power LED

	tst.l	gonext(a1)
	bne.s	NoMagic
	move.l	A1,-(SP)
	move.l	task(a1),a1
	move.l	4.w,a6
	moveq	#0,d0
	bset	#$F,d0
	jsr	_LVOSignal(a6)		; **** !! Zrusi mi to A1 !! ****
	move.l	(SP)+,A1

NoMagic	moveq	#0,d0			; Aby se provedly dalsi interupty
	rts



asltag	dc.l	ASLSM_DoHeight,TRUE,ASLSM_MaxHeight,700
	dc.l	ASLSM_InitialDisplayID,$29000,TAG_DONE

CopTag	dc.l	VTAG_USERCLIP_SET,TRUE,TAG_DONE

obName	dc.b	'pic.raw',0
inrname	dc.b	'Harry-Copper',0

	tags			; start of tag list
	library	graphics,39
	library asl,38
	library	lowlevel,40
	finish			; end of tag list
	end
