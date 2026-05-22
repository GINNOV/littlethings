********************************************
* ----- Protracker V1.1a Playroutine ----- *
********************************************

* Optimised and re-worked by abn

* vblank version a:
* call init to initialize the routine, then call music on
* each vertical blank (50 Htz). to end the song and turn off all
* voices, call end.

* changes from v1.0c playroutine:
* vibrato depth changed to be compatible with noisetracker 2.0.
* you'll have to double all vib. depths on old pt modules.
* funk repeat changed to invert loop.

dmawait	equ	280 * set this as low as possible without losing low notes.

n_cmd		equ	2  * w
n_cmdlo		equ	3  * low b of n_cmd
n_start		equ	4  * l
n_length	equ	8  * w
n_loopstart	equ	10 * l
n_replen	equ	14 * w
n_period	equ	16 * w
n_finetune	equ	18 * b
n_volume	equ	19 * b
n_dmabit	equ	20 * w
n_toneportdirec	equ	22 * b
n_toneportspeed	equ	23 * b
n_wantedperiod	equ	24 * w
n_vibratocmd	equ	26 * b
n_vibratopos	equ	27 * b
n_tremolocmd	equ	28 * b
n_tremolopos	equ	29 * b
n_wavecontrol	equ	30 * b
n_glissfunk	equ	31 * b
n_sampleoffset	equ	32 * b
n_pattpos	equ	33 * b
n_loopcount	equ	34 * b
n_funkoffset	equ	35 * b
n_wavestart	equ	36 * l
n_reallength	equ	40 * w

*******************************************************
init	lea	module,a0
	move.l	a0,songdataptr
	lea	mulu(pc),a1
	move.l	a0,d0
	addq.l	#8,d0
	addq.l	#4,d0
	moveq	#$1f,d1
	moveq	#$1e,d3
lop4	move.l	d0,(a1)+
	add.l	d3,d0
	dbra	d1,lop4
	lea	$3b8(a0),a1
	moveq	#127,d0
	moveq	#0,d1
	moveq	#0,d2
lop2 move.b	(a1)+,d1
	cmp.b	d2,d1
	ble.s	lop
	move.l	d1,d2
lop	dbra	d0,lop2
	addq.w	#1,d2
	asl.l	#8,d2
	asl.l	#2,d2
	lea	4(a1,d2.l),a2
	lea	samplestarts(pc),a1
	add.w	#$2a,a0
	moveq	#$1e,d0
lop3	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.b	d1,2(a0)
	move.w	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	d3,a0
	dbra	d0,lop3
	lea	speed(pc),a1
	move.b	#6,(a1)
	or.b	#2,$bfe001
	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.b	d0,songpos-speed(a1)
	move.b	d0,counter-speed(a1)
	move.w	d0,pattpos-speed(a1)
	rts
*******************************************************

end	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.w	#$f,$dff096
	rts

*******************************************************
music	move.b	counter(pc),d0
	addq.b	#1,d0		* increment counter
	cmp.b	speed(pc),d0
	blo.s	nonewnote		* if not done, don't get new
	clr.b	counter		* clear counter
	tst.b	pattdeltime2	* 
	beq.s	getnewnote
	bsr.s	nonewallchannels
	bra	dskip

nonewnote	move.b	d0,counter
**************************************************
* don't need to step pattern yet, so check commands
* and deal with the effects
	bsr.s	nonewallchannels
	bra	nonewposyet

nonewallchannels
	lea	$dff0a0,a5
	lea	chan1temp(pc),a6
	bsr	check_fx
	lea	$dff0b0,a5
	lea	chan2temp(pc),a6
	bsr	check_fx
	lea	$dff0c0,a5
	lea	chan3temp(pc),a6
	bsr	check_fx
	lea	$dff0d0,a5
	lea	chan4temp(pc),a6
	bra	check_fx
****************************************************

getnewnote
	move.l	songdataptr(pc),a0
	lea	12(a0),a3
	lea	952(a0),a2	*pattpo
	lea	1084(a0),a0	*patterndata
	moveq	#0,d0
	moveq	#0,d1
	move.b	songpos(pc),d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1
	clr.w	dmacontemp

	lea	$dff0a0,a5
	lea	chan1temp(pc),a6
	bsr.s	playvoice
	lea	$dff0b0,a5
	lea	chan2temp(pc),a6
	bsr.s	playvoice
	lea	$dff0c0,a5
	lea	chan3temp(pc),a6
	bsr.s	playvoice
	lea	$dff0d0,a5
	lea	chan4temp(pc),a6
	bsr.s	playvoice
	bra	setdma

*********************************************

playvoice
	tst.l	(a6)
	bne.s	plvskip
	move.w	n_period(a6),6(a5)
plvskip
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	n_cmd(a6),d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	beq	setregs
	moveq	#0,d3
	lea	samplestarts(pc),a1
	move	d2,d4
	subq.l	#1,d2
	asl.l	#2,d2
	mulu	#30,d4
	move.l	(a1,d2.l),n_start(a6)
	move.w	(a3,d4.l),n_length(a6)
	move.w	(a3,d4.l),n_reallength(a6)
	move.b	2(a3,d4.l),n_finetune(a6)
	move.b	3(a3,d4.l),n_volume(a6)
	move.w	4(a3,d4.l),d3 		* get repeat
	tst.w	d3
	beq.s	noloop
	move.l	n_start(a6),d2		* get start
	lsl.w	#1,d3
	add.l	d3,d2			* add repeat
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	4(a3,d4.l),d0		* get repeat
	add.w	6(a3,d4.l),d0		* add replen
	move.w	d0,n_length(a6)
	move.w	6(a3,d4.l),n_replen(a6)	* save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,8(a5)	* set volume
	bra.s	setregs

noloop	move.l	n_start(a6),d2
	add.l	d3,d2
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	6(a3,d4.l),n_replen(a6)	* save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,8(a5)			* set volume

setregs	move.w	(a6),d0
	and.w	#$0fff,d0
	beq	checkmoreefx	* if no note
	move.w	2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0e50,d0
	beq.s	dosetfinetune
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#3,d0		* toneportamento
	beq.s	chktoneporta
	cmp.b	#5,d0
	beq.s	chktoneporta
	cmp.b	#9,d0		* sample offset
	bne.s	setperiod
	bsr	checkmoreefx
	bra.s	setperiod

dosetfinetune
	bsr	setfinetune
	bra.s	setperiod

chktoneporta
	bsr	settoneporta
	bra	checkmoreefx

setperiod	movem.l	d0-d1/a0-a1,-(sp)
	move.w	(a6),d1
	and.w	#$0fff,d1
	lea	periodtable(pc),a1
	moveq	#0,d0
	moveq	#36,d7
ftuloop
	cmp.w	(a1,d0.w),d1
	bhs.s	ftufound
	addq.l	#2,d0
	dbra	d7,ftuloop
ftufound
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#36*2,d1
	add.l	d1,a1
	move.w	(a1,d0.w),n_period(a6)
	movem.l	(sp)+,d0-d1/a0-a1

	move.w	2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0ed0,d0 	* notedelay
	beq	checkmoreefx

	move.w	n_dmabit(a6),$dff096
	btst	#2,n_wavecontrol(a6)
	bne.s	vibnoc
	clr.b	n_vibratopos(a6)
vibnoc
	btst	#6,n_wavecontrol(a6)
	bne.s	trenoc
	clr.b	n_tremolopos(a6)
trenoc
	move.l	n_start(a6),(a5)	* set start
	move.w	n_length(a6),4(a5)	* set length
	move.w	n_period(a6),d0
	move.w	d0,6(a5)		* set period
	move.w	n_dmabit(a6),d0
	or.w	d0,dmacontemp
	bra	checkmoreefx
	 
setdma	move.w	#dmawait,d0
waitdma	dbra	d0,waitdma
	
	move.w	dmacontemp(pc),d0
	or.w	#$8000,d0
	move.w	d0,$dff096
	
	move.w	#dmawait,d0
waitdma2	dbra	d0,waitdma2

	lea	$dff000,a5
	lea	chan4temp(pc),a6
	move.l	n_loopstart(a6),$d0(a5)
	move.w	n_replen(a6),$d4(a5)
	lea	chan3temp(pc),a6
	move.l	n_loopstart(a6),$c0(a5)
	move.w	n_replen(a6),$c4(a5)
	lea	chan2temp(pc),a6
	move.l	n_loopstart(a6),$b0(a5)
	move.w	n_replen(a6),$b4(a5)
	lea	chan1temp(pc),a6
	move.l	n_loopstart(a6),$a0(a5)
	move.w	n_replen(a6),$a4(a5)

dskip
	add.w	#16,pattpos
	move.b	pattdeltime,d0
	beq.s	dskc
	move.b	d0,pattdeltime2
	clr.b	pattdeltime
dskc	tst.b	pattdeltime2
	beq.s	dska
	subq.b	#1,pattdeltime2
	beq.s	dska
	sub.w	#16,pattpos
dska	tst.b	pbreakflag
	beq.s	nnpysk
	sf	pbreakflag
	moveq	#0,d0
	move.b	pbreakpos(pc),d0
	clr.b	pbreakpos
	lsl.w	#4,d0
	move.w	d0,pattpos
nnpysk
	cmp.w	#1024,pattpos
	blo.s	nonewposyet
nextposition	
	moveq	#0,d0
	move.b	pbreakpos(pc),d0
	lsl.w	#4,d0
	move.w	d0,pattpos
	clr.b	pbreakpos
	clr.b	posjumpflag
	addq.b	#1,songpos
	and.b	#$7f,songpos
	move.b	songpos(pc),d1
	move.l	songdataptr(pc),a0
	cmp.b	950(a0),d1
	blo.s	nonewposyet
	clr.b	songpos
nonewposyet	
	tst.b	posjumpflag
	bne.s	nextposition
	rts

***********************************************************************
* do the effects, only called when not new step

check_fx	bsr	updatefunk
	
	move.w	n_cmd(a6),d0
	and.w	#$0fff,d0
	beq.s	pernop		* if 0, no fx to do!
	
	move.b	n_cmd(a6),d0
	and.w	#$0f,d0
	lsl.w	d0	* mult by 2
	
	lea	pernop(pc),a4
	add.w	fx_list(pc,d0.w),a4
	jmp	(a4)

fx_list	dc.w	arpeggio-pernop
	dc.w	portaup-pernop
	dc.w	portadown-pernop
	dc.w	toneportamento-pernop
	dc.w	vibrato-pernop
	dc.w	toneplusvolslide-pernop
	dc.w	vibratoplusvolslide-pernop
	dc.w	tremolo-pernop
	dc.w	rts0-pernop
	dc.w	rts0-pernop
	dc.w	volumeslide-pernop
	dc.w	rts0-pernop
	dc.w	rts0-pernop
	dc.w	rts0-pernop
	dc.w	e_commands-pernop
	dc.w	rts0-pernop
	
pernop	move.w	n_period(a6),6(a5)
rts0	rts

****************************************
arpeggio	moveq	#0,d0
	move.b	counter(pc),d0
	divs	#3,d0
	swap	d0
	cmp.w	#0,d0
	beq.s	arpeggio2
	cmp.w	#2,d0
	beq.s	arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	bra.s	arpeggio3

arpeggio1	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#15,d0
	bra.s	arpeggio3

arpeggio2
	move.w	n_period(a6),d2
	bra.s	arpeggio4

arpeggio3	asl.w	#1,d0
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#36*2,d1
	lea	periodtable(pc),a0
	add.l	d1,a0
	moveq	#0,d1
	move.w	n_period(a6),d1
	moveq	#36,d7
arploop
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bhs.s	arpeggio4
	addq.l	#2,a0
	dbra	d7,arploop
	rts

arpeggio4
	move.w	d2,6(a5)
rts1	rts
****************************************

fineportaup
	tst.b	counter
	bne.s	rts1
	move.b	#$0f,lowmask
portaup
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	lowmask(pc),d0
	move.b	#$ff,lowmask
	sub.w	d0,n_period(a6)
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#113,d0
	bpl.s	portauskip
	and.w	#$f000,n_period(a6)
	or.w	#113,n_period(a6)
portauskip
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	move.w	d0,6(a5)
	rts	
 
****************************************
fineportadown
	tst.b	counter
	bne.s	rts1
	move.b	#$0f,lowmask
portadown
	clr.w	d0
	move.b	n_cmdlo(a6),d0
	and.b	lowmask(pc),d0
	move.b	#$ff,lowmask
	add.w	d0,n_period(a6)
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#856,d0
	bmi.s	portadskip
	and.w	#$f000,n_period(a6)
	or.w	#856,n_period(a6)
portadskip
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	move.w	d0,6(a5)
	rts

****************************************
settoneporta
	move.l	a0,-(sp)
	move.w	(a6),d2
	and.w	#$0fff,d2
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#37*2,d0
	lea	periodtable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
stploop
	cmp.w	(a0,d0.w),d2
	bhs.s	stpfound
	addq.w	#2,d0
	cmp.w	#37*2,d0
	blo.s	stploop
	moveq	#35*2,d0
stpfound
	move.b	n_finetune(a6),d2
	and.b	#8,d2
	beq.s	stpgoss
	tst.w	d0
	beq.s	stpgoss
	subq.w	#2,d0
stpgoss
	move.w	(a0,d0.w),d2
	move.l	(sp)+,a0
	move.w	d2,n_wantedperiod(a6)
	move.w	n_period(a6),d0
	clr.b	n_toneportdirec(a6)
	cmp.w	d0,d2
	beq.s	cleartoneporta
	bge.s	rts2
	move.b	#1,n_toneportdirec(a6)
	rts

cleartoneporta
	clr.w	n_wantedperiod(a6)
rts2	rts

toneportamento
	move.b	n_cmdlo(a6),d0
	beq.s	toneportnochange
	move.b	d0,n_toneportspeed(a6)
	clr.b	n_cmdlo(a6)
toneportnochange
	tst.w	n_wantedperiod(a6)
	beq.s	rts2
	moveq	#0,d0
	move.b	n_toneportspeed(a6),d0
	tst.b	n_toneportdirec(a6)
	bne.s	toneportaup
toneportadown
	add.w	d0,n_period(a6)
	move.w	n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	bgt.s	toneportasetper
	move.w	n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)
	bra.s	toneportasetper

toneportaup
	sub.w	d0,n_period(a6)
	move.w	n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	blt.s	toneportasetper
	move.w	n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)

toneportasetper
	move.w	n_period(a6),d2
	move.b	n_glissfunk(a6),d0
	and.b	#$0f,d0
	beq.s	glissskip
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#36*2,d0
	lea	periodtable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
glissloop
	cmp.w	(a0,d0.w),d2
	bhs.s	glissfound
	addq.w	#2,d0
	cmp.w	#36*2,d0
	blo.s	glissloop
	moveq	#35*2,d0
glissfound
	move.w	(a0,d0.w),d2
glissskip
	move.w	d2,6(a5) 	* set period
	rts

****************************************
vibrato
	move.b	n_cmdlo(a6),d0
	beq.s	vibrato2
	move.b	n_vibratocmd(a6),d2
	and.b	#$0f,d0
	beq.s	vibskip
	and.b	#$f0,d2
	or.b	d0,d2
vibskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	vibskip2
	and.b	#$0f,d2
	or.b	d0,d2
vibskip2
	move.b	d2,n_vibratocmd(a6)
vibrato2
	move.b	n_vibratopos(a6),d0
	lea	vibratotable(pc),a4
	lsr.w	#2,d0
	and.w	#$001f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	and.b	#$03,d2
	beq.s	vib_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	vib_rampdown
	move.b	#255,d2
	bra.s	vib_set
vib_rampdown
	tst.b	n_vibratopos(a6)
	bpl.s	vib_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	vib_set
vib_rampdown2
	move.b	d0,d2
	bra.s	vib_set
vib_sine
	move.b	0(a4,d0.w),d2
vib_set
	move.b	n_vibratocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w	n_period(a6),d0
	tst.b	n_vibratopos(a6)
	bmi.s	vibratoneg
	add.w	d2,d0
	bra.s	vibrato3
vibratoneg
	sub.w	d2,d0
vibrato3
	move.w	d0,6(a5)
	move.b	n_vibratocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$003c,d0
	add.b	d0,n_vibratopos(a6)
	rts

toneplusvolslide
	bsr	toneportnochange
	bra	volumeslide

vibratoplusvolslide
	bsr.s	vibrato2
	bra	volumeslide

****************************************
tremolo
	move.b	n_cmdlo(a6),d0
	beq.s	tremolo2
	move.b	n_tremolocmd(a6),d2
	and.b	#$0f,d0
	beq.s	treskip
	and.b	#$f0,d2
	or.b	d0,d2
treskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	treskip2
	and.b	#$0f,d2
	or.b	d0,d2
treskip2
	move.b	d2,n_tremolocmd(a6)
tremolo2
	move.b	n_tremolopos(a6),d0
	lea	vibratotable(pc),a4
	lsr.w	#2,d0
	and.w	#$001f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	lsr.b	#4,d2
	and.b	#$03,d2
	beq.s	tre_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	tre_rampdown
	move.b	#255,d2
	bra.s	tre_set
tre_rampdown
	tst.b	n_vibratopos(a6)
	bpl.s	tre_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	tre_set
tre_rampdown2
	move.b	d0,d2
	bra.s	tre_set
tre_sine
	move.b	0(a4,d0.w),d2
tre_set
	move.b	n_tremolocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#6,d2
	moveq	#0,d0
	move.b	n_volume(a6),d0
	tst.b	n_tremolopos(a6)
	bmi.s	tremoloneg
	add.w	d2,d0
	bra.s	tremolo3
tremoloneg
	sub.w	d2,d0
tremolo3
	bpl.s	tremoloskip
	clr.w	d0
tremoloskip
	cmp.w	#$40,d0
	bls.s	tremolook
	move.w	#$40,d0
tremolook
	move.w	d0,8(a5)
	move.b	n_tremolocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$003c,d0
	add.b	d0,n_tremolopos(a6)
	rts

****************************************
sampleoffset
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	beq.s	sononew
	move.b	d0,n_sampleoffset(a6)
sononew
	move.b	n_sampleoffset(a6),d0
	lsl.w	#7,d0
	cmp.w	n_length(a6),d0
	bge.s	sofskip
	sub.w	d0,n_length(a6)
	lsl.w	#1,d0
	add.l	d0,n_start(a6)
	rts
sofskip
	move.w	#1,n_length(a6)
	rts

****************************************
volumeslide
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	volslidedown
volslideup
	add.b	d0,n_volume(a6)
	cmp.b	#$40,n_volume(a6)
	bmi.s	vsuskip
	move.b	#$40,n_volume(a6)
vsuskip
	move.b	n_volume(a6),d0
	move.w	d0,8(a5)
	rts

volslidedown
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
volslidedown2
	sub.b	d0,n_volume(a6)
	bpl.s	vsdskip
	clr.b	n_volume(a6)
vsdskip
	move.b	n_volume(a6),d0
	move.w	d0,8(a5)
	rts

****************************************
positionjump
	move.b	n_cmdlo(a6),d0
	subq.b	#1,d0
	move.b	d0,songpos
pj2	clr.b	pbreakpos
	st	posjumpflag
	rts

****************************************
volumechange
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	cmp.b	#$40,d0
	bls.s	volumeok
	moveq	#$40,d0
volumeok
	move.b	d0,n_volume(a6)
	move.w	d0,8(a5)
	rts

****************************************
patternbreak
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	move.l	d0,d2
	lsr.b	#4,d0
	mulu	#10,d0
	and.b	#$0f,d2
	add.b	d2,d0
	cmp.b	#63,d0
	bhi.s	pj2
	move.b	d0,pbreakpos
	st	posjumpflag
	rts

****************************************
setspeed
	move.b	3(a6),d0
	beq.s	rts3
	clr.b	counter
	move.b	d0,speed
	rts

****************************************
checkmoreefx
	bsr	updatefunk
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$9,d0
	beq	sampleoffset
	cmp.b	#$b,d0
	beq	positionjump
	cmp.b	#$d,d0
	beq.s	patternbreak
	cmp.b	#$e,d0
	beq.s	e_commands
	cmp.b	#$f,d0
	beq.s	setspeed
	cmp.b	#$c,d0
	beq	volumechange
rts3	rts	
****************************************
e_commands
	move.b	n_cmdlo(a6),d0
	and.w	#$f0,d0
	lsr.w	#3,d0		* make lhs, mult by 2
	lea	filteronoff(pc),a4
	add.w	efx_list(pc,d0.w),a4
	jmp	(a4)

efx_list	dc.w	filteronoff-filteronoff
	dc.w	fineportaup-filteronoff
	dc.w	fineportadown-filteronoff
	dc.w	setglisscontrol-filteronoff
	dc.w	setvibratocontrol-filteronoff
	dc.w	setfinetune-filteronoff
	dc.w	jumploop-filteronoff
	dc.w	settremolocontrol-filteronoff
	dc.w	rts6-filteronoff
	dc.w	retrignote-filteronoff
	dc.w	volumefineup-filteronoff
	dc.w	volumefinedown-filteronoff
	dc.w	notecut-filteronoff
	dc.w	notedelay-filteronoff
	dc.w	patterndelay-filteronoff
	dc.w	funkit-filteronoff
	
****************************************
filteronoff
	move.b	n_cmdlo(a6),d0
	and.b	#1,d0
	asl.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
rts6	rts	

setglisscontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	and.b	#$f0,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	rts

setvibratocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	and.b	#$f0,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

setfinetune
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	move.b	d0,n_finetune(a6)
	rts

jumploop
	tst.b	counter
	bne.s	rts4
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.s	setloop
	tst.b	n_loopcount(a6)
	beq.s	jumpcnt
	subq.b	#1,n_loopcount(a6)
	beq.s	rts4
jmploop
	move.b	n_pattpos(a6),pbreakpos
	st	pbreakflag
rts4	rts

jumpcnt
	move.b	d0,n_loopcount(a6)
	bra.s	jmploop

setloop
	move.w	pattpos(pc),d0
	lsr.w	#4,d0
	move.b	d0,n_pattpos(a6)
	rts

settremolocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	and.b	#$0f,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

retrignote
	move.l	d1,-(sp)
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.s	rtnend
	moveq	#0,d1
	move.b	counter(pc),d1
	bne.s	rtnskp
	move.w	(a6),d1
	and.w	#$0fff,d1
	bne.s	rtnend
	moveq	#0,d1
	move.b	counter(pc),d1
rtnskp
	divu	d0,d1
	swap	d1
	tst.w	d1
	bne.s	rtnend
doretrig
	move.w	n_dmabit(a6),$dff096	* channel dma off
	move.l	n_start(a6),(a5)		* set sampledata pointer
	move.w	n_length(a6),4(a5)		* set length
	move.w	#dmawait,d0
rtnloop1
	dbra	d0,rtnloop1
	move.w	n_dmabit(a6),d0
	bset	#15,d0
	move.w	d0,$dff096
	move.w	#dmawait,d0
rtnloop2
	dbra	d0,rtnloop2
	move.l	n_loopstart(a6),(a5)
	move.l	n_replen(a6),4(a5)
rtnend
	move.l	(sp)+,d1
	rts

volumefineup
	tst.b	counter
	bne.s	rts5
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	bra	volslideup

volumefinedown
	tst.b	counter
	bne.s	rts5
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	bra	volslidedown2

notecut
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	counter(pc),d0
	bne.s	rts5
	clr.b	n_volume(a6)
	move.w	#0,8(a5)
rts5	rts

notedelay
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	counter,d0
	bne.s	rts5
	move.w	(a6),d0
	beq.s	rts5
	move.l	d1,-(sp)
	bra	doretrig

patterndelay
	tst.b	counter
	bne.s	rts5
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	tst.b	pattdeltime2
	bne.s	rts5
	addq.b	#1,d0
	move.b	d0,pattdeltime
	rts

funkit
	tst.b	counter
	bne.s	rts5
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	and.b	#$0f,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	tst.b	d0
	beq.s	rts5
updatefunk
	movem.l	a0/d1,-(sp)
	moveq	#0,d0
	move.b	n_glissfunk(a6),d0
	lsr.b	#4,d0
	beq.s	funkend
	lea	funktable(pc),a0
	move.b	(a0,d0.w),d0
	add.b	d0,n_funkoffset(a6)
	btst	#7,n_funkoffset(a6)
	beq.s	funkend
	clr.b	n_funkoffset(a6)

	clr.b	n_funkoffset(a6)
	move.l	n_loopstart(a6),d0
	moveq	#0,d1
	move.w	n_replen(a6),d1
	add.l	d1,d0
	add.l	d1,d0
	move.l	n_wavestart(a6),a0
	addq.l	#1,a0
	cmp.l	d0,a0
	blo.s	funkok
	move.l	n_loopstart(a6),a0
funkok
	move.l	a0,n_wavestart(a6)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
funkend
	movem.l	(sp)+,a0/d1
	rts

*******************************************************************
* start of data
*

funktable
	dc.b	0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
	even
	
vibratotable	
	dc.b	0,24,49,74,97,120,141,161
	dc.b	180,197,212,224,235,244,250,253
	dc.b	255,253,250,244,235,224,212,197
	dc.b	180,161,141,120,97,74,49,24
	even
	
periodtable
* tuning 0, normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
* tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
* tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
* tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
* tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
* tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
* tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
* tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
* tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
* tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
* tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
* tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
* tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
* tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
* tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
* tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

chan1temp		dc.l	0,0,0,0,0,$00010000,0,0,0,0,0
chan2temp		dc.l	0,0,0,0,0,$00020000,0,0,0,0,0
chan3temp		dc.l	0,0,0,0,0,$00040000,0,0,0,0,0
chan4temp		dc.l	0,0,0,0,0,$00080000,0,0,0,0,0

samplestarts	ds.l	31

songdataptr	dc.l	0

speed		dc.b	6
counter		dc.b	0
songpos		dc.b	0
pbreakpos		dc.b	0
posjumpflag	dc.b	0
pbreakflag	dc.b	0
lowmask		dc.b	0
pattdeltime	dc.b	0
pattdeltime2	dc.b	0
		dc.b	0
		even

pattpos		dc.w	0
dmacontemp	dc.w	0

mulu		dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
