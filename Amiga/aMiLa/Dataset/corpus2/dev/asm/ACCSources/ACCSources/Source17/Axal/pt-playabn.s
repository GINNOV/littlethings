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
mt_init	lea	module,a0
	move.l	a0,mt_songdataptr
	lea	mt_mulu(pc),a1
	move.l	a0,d0
	addq.l	#8,d0
	addq.l	#4,d0
	moveq	#$1f,d1
	moveq	#$1e,d3
mt_lop4	move.l	d0,(a1)+
	add.l	d3,d0
	dbra	d1,mt_lop4
	lea	$3b8(a0),a1
	moveq	#127,d0
	moveq	#0,d1
	moveq	#0,d2
mt_lop2 move.b	(a1)+,d1
	cmp.b	d2,d1
	ble.s	mt_lop
	move.l	d1,d2
mt_lop	dbra	d0,mt_lop2
	addq.w	#1,d2
	asl.l	#8,d2
	asl.l	#2,d2
	lea	4(a1,d2.l),a2
	lea	mt_samplestarts(pc),a1
	add.w	#$2a,a0
	moveq	#$1e,d0
mt_lop3	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.b	d1,2(a0)
	move.w	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	d3,a0
	dbra	d0,mt_lop3
	lea	mt_speed(pc),a1
	move.b	#6,(a1)
	or.b	#2,$bfe001
	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.b	d0,mt_songpos-mt_speed(a1)
	move.b	d0,mt_counter-mt_speed(a1)
	move.w	d0,mt_pattpos-mt_speed(a1)
	rts
*******************************************************

mt_end	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.w	#$f,$dff096
	rts

*******************************************************
mt_music	move.b	mt_counter(pc),d0
	addq.b	#1,d0		* increment counter
	cmp.b	mt_speed(pc),d0
	blo.s	mt_nonewnote		* if not done, don't get new
	clr.b	mt_counter		* clear counter
	tst.b	mt_pattdeltime2	* 
	beq.s	mt_getnewnote
	bsr.s	mt_nonewallchannels
	bra	mt_dskip

mt_nonewnote	move.b	d0,mt_counter
**************************************************
* don't need to step pattern yet, so check commands
* and deal with the effects
	bsr.s	mt_nonewallchannels
	bra	mt_nonewposyet

mt_nonewallchannels
	lea	$dff0a0,a5
	lea	mt_chan1temp(pc),a6
	bsr	mt_check_fx
	lea	$dff0b0,a5
	lea	mt_chan2temp(pc),a6
	bsr	mt_check_fx
	lea	$dff0c0,a5
	lea	mt_chan3temp(pc),a6
	bsr	mt_check_fx
	lea	$dff0d0,a5
	lea	mt_chan4temp(pc),a6
	bra	mt_check_fx
****************************************************

mt_getnewnote
	move.l	mt_songdataptr(pc),a0
	lea	12(a0),a3
	lea	952(a0),a2	*pattpo
	lea	1084(a0),a0	*patterndata
	moveq	#0,d0
	moveq	#0,d1
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_pattpos(pc),d1
	clr.w	mt_dmacontemp

	lea	$dff0a0,a5
	lea	mt_chan1temp(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0b0,a5
	lea	mt_chan2temp(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0c0,a5
	lea	mt_chan3temp(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0d0,a5
	lea	mt_chan4temp(pc),a6
	bsr.s	mt_playvoice
	bra	mt_setdma

*********************************************

mt_playvoice
	tst.l	(a6)
	bne.s	mt_plvskip
	move.w	n_period(a6),6(a5)
mt_plvskip
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	n_cmd(a6),d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	beq	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
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
	beq.s	mt_noloop
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
	bra.s	mt_setregs

mt_noloop	move.l	n_start(a6),d2
	add.l	d3,d2
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	6(a3,d4.l),n_replen(a6)	* save replen
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,8(a5)			* set volume

mt_setregs	move.w	(a6),d0
	and.w	#$0fff,d0
	beq	mt_checkmoreefx	* if no note
	move.w	2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0e50,d0
	beq.s	mt_dosetfinetune
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#3,d0		* toneportamento
	beq.s	mt_chktoneporta
	cmp.b	#5,d0
	beq.s	mt_chktoneporta
	cmp.b	#9,d0		* sample offset
	bne.s	mt_setperiod
	bsr	mt_checkmoreefx
	bra.s	mt_setperiod

mt_dosetfinetune
	bsr	mt_setfinetune
	bra.s	mt_setperiod

mt_chktoneporta
	bsr	mt_settoneporta
	bra	mt_checkmoreefx

mt_setperiod	movem.l	d0-d1/a0-a1,-(sp)
	move.w	(a6),d1
	and.w	#$0fff,d1
	lea	mt_periodtable(pc),a1
	moveq	#0,d0
	moveq	#36,d7
mt_ftuloop
	cmp.w	(a1,d0.w),d1
	bhs.s	mt_ftufound
	addq.l	#2,d0
	dbra	d7,mt_ftuloop
mt_ftufound
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#36*2,d1
	add.l	d1,a1
	move.w	(a1,d0.w),n_period(a6)
	movem.l	(sp)+,d0-d1/a0-a1

	move.w	2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0ed0,d0 	* notedelay
	beq	mt_checkmoreefx

	move.w	n_dmabit(a6),$dff096
	btst	#2,n_wavecontrol(a6)
	bne.s	mt_vibnoc
	clr.b	n_vibratopos(a6)
mt_vibnoc
	btst	#6,n_wavecontrol(a6)
	bne.s	mt_trenoc
	clr.b	n_tremolopos(a6)
mt_trenoc
	move.l	n_start(a6),(a5)	* set start
	move.w	n_length(a6),4(a5)	* set length
	move.w	n_period(a6),d0
	move.w	d0,6(a5)		* set period
	move.w	n_dmabit(a6),d0
	or.w	d0,mt_dmacontemp
	bra	mt_checkmoreefx
	 
mt_setdma	move.w	#dmawait,d0
mt_waitdma	dbra	d0,mt_waitdma
	
	move.w	mt_dmacontemp(pc),d0
	or.w	#$8000,d0
	move.w	d0,$dff096
	
	move.w	#dmawait,d0
mt_waitdma2	dbra	d0,mt_waitdma2

	lea	$dff000,a5
	lea	mt_chan4temp(pc),a6
	move.l	n_loopstart(a6),$d0(a5)
	move.w	n_replen(a6),$d4(a5)
	lea	mt_chan3temp(pc),a6
	move.l	n_loopstart(a6),$c0(a5)
	move.w	n_replen(a6),$c4(a5)
	lea	mt_chan2temp(pc),a6
	move.l	n_loopstart(a6),$b0(a5)
	move.w	n_replen(a6),$b4(a5)
	lea	mt_chan1temp(pc),a6
	move.l	n_loopstart(a6),$a0(a5)
	move.w	n_replen(a6),$a4(a5)

mt_dskip
	add.w	#16,mt_pattpos
	move.b	mt_pattdeltime,d0
	beq.s	mt_dskc
	move.b	d0,mt_pattdeltime2
	clr.b	mt_pattdeltime
mt_dskc	tst.b	mt_pattdeltime2
	beq.s	mt_dska
	subq.b	#1,mt_pattdeltime2
	beq.s	mt_dska
	sub.w	#16,mt_pattpos
mt_dska	tst.b	mt_pbreakflag
	beq.s	mt_nnpysk
	sf	mt_pbreakflag
	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0
	clr.b	mt_pbreakpos
	lsl.w	#4,d0
	move.w	d0,mt_pattpos
mt_nnpysk
	cmp.w	#1024,mt_pattpos
	blo.s	mt_nonewposyet
mt_nextposition	
	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0
	lsl.w	#4,d0
	move.w	d0,mt_pattpos
	clr.b	mt_pbreakpos
	clr.b	mt_posjumpflag
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos(pc),d1
	move.l	mt_songdataptr(pc),a0
	cmp.b	950(a0),d1
	blo.s	mt_nonewposyet
	clr.b	mt_songpos
mt_nonewposyet	
	tst.b	mt_posjumpflag
	bne.s	mt_nextposition
	rts

***********************************************************************
* do the effects, only called when not new step

mt_check_fx	bsr	mt_updatefunk
	
	move.w	n_cmd(a6),d0
	and.w	#$0fff,d0
	beq.s	mt_pernop		* if 0, no fx to do!
	
	move.b	n_cmd(a6),d0
	and.w	#$0f,d0
	lsl.w	d0	* mult by 2
	
	lea	mt_pernop(pc),a4
	add.w	mt_fx_list(pc,d0.w),a4
	jmp	(a4)

mt_fx_list	dc.w	mt_arpeggio-mt_pernop
	dc.w	mt_portaup-mt_pernop
	dc.w	mt_portadown-mt_pernop
	dc.w	mt_toneportamento-mt_pernop
	dc.w	mt_vibrato-mt_pernop
	dc.w	mt_toneplusvolslide-mt_pernop
	dc.w	mt_vibratoplusvolslide-mt_pernop
	dc.w	mt_tremolo-mt_pernop
	dc.w	mt_rts0-mt_pernop
	dc.w	mt_rts0-mt_pernop
	dc.w	mt_volumeslide-mt_pernop
	dc.w	mt_rts0-mt_pernop
	dc.w	mt_rts0-mt_pernop
	dc.w	mt_rts0-mt_pernop
	dc.w	mt_e_commands-mt_pernop
	dc.w	mt_rts0-mt_pernop
	
mt_pernop	move.w	n_period(a6),6(a5)
mt_rts0	rts

****************************************
mt_arpeggio	moveq	#0,d0
	move.b	mt_counter(pc),d0
	divs	#3,d0
	swap	d0
	cmp.w	#0,d0
	beq.s	mt_arpeggio2
	cmp.w	#2,d0
	beq.s	mt_arpeggio1
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arpeggio3

mt_arpeggio1	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#15,d0
	bra.s	mt_arpeggio3

mt_arpeggio2
	move.w	n_period(a6),d2
	bra.s	mt_arpeggio4

mt_arpeggio3	asl.w	#1,d0
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu	#36*2,d1
	lea	mt_periodtable(pc),a0
	add.l	d1,a0
	moveq	#0,d1
	move.w	n_period(a6),d1
	moveq	#36,d7
mt_arploop
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bhs.s	mt_arpeggio4
	addq.l	#2,a0
	dbra	d7,mt_arploop
	rts

mt_arpeggio4
	move.w	d2,6(a5)
mt_rts1	rts
****************************************

mt_fineportaup
	tst.b	mt_counter
	bne.s	mt_rts1
	move.b	#$0f,mt_lowmask
mt_portaup
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask(pc),d0
	move.b	#$ff,mt_lowmask
	sub.w	d0,n_period(a6)
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#113,d0
	bpl.s	mt_portauskip
	and.w	#$f000,n_period(a6)
	or.w	#113,n_period(a6)
mt_portauskip
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	move.w	d0,6(a5)
	rts	
 
****************************************
mt_fineportadown
	tst.b	mt_counter
	bne.s	mt_rts1
	move.b	#$0f,mt_lowmask
mt_portadown
	clr.w	d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask(pc),d0
	move.b	#$ff,mt_lowmask
	add.w	d0,n_period(a6)
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#856,d0
	bmi.s	mt_portadskip
	and.w	#$f000,n_period(a6)
	or.w	#856,n_period(a6)
mt_portadskip
	move.w	n_period(a6),d0
	and.w	#$0fff,d0
	move.w	d0,6(a5)
	rts

****************************************
mt_settoneporta
	move.l	a0,-(sp)
	move.w	(a6),d2
	and.w	#$0fff,d2
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#37*2,d0
	lea	mt_periodtable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_stploop
	cmp.w	(a0,d0.w),d2
	bhs.s	mt_stpfound
	addq.w	#2,d0
	cmp.w	#37*2,d0
	blo.s	mt_stploop
	moveq	#35*2,d0
mt_stpfound
	move.b	n_finetune(a6),d2
	and.b	#8,d2
	beq.s	mt_stpgoss
	tst.w	d0
	beq.s	mt_stpgoss
	subq.w	#2,d0
mt_stpgoss
	move.w	(a0,d0.w),d2
	move.l	(sp)+,a0
	move.w	d2,n_wantedperiod(a6)
	move.w	n_period(a6),d0
	clr.b	n_toneportdirec(a6)
	cmp.w	d0,d2
	beq.s	mt_cleartoneporta
	bge.s	mt_rts2
	move.b	#1,n_toneportdirec(a6)
	rts

mt_cleartoneporta
	clr.w	n_wantedperiod(a6)
mt_rts2	rts

mt_toneportamento
	move.b	n_cmdlo(a6),d0
	beq.s	mt_toneportnochange
	move.b	d0,n_toneportspeed(a6)
	clr.b	n_cmdlo(a6)
mt_toneportnochange
	tst.w	n_wantedperiod(a6)
	beq.s	mt_rts2
	moveq	#0,d0
	move.b	n_toneportspeed(a6),d0
	tst.b	n_toneportdirec(a6)
	bne.s	mt_toneportaup
mt_toneportadown
	add.w	d0,n_period(a6)
	move.w	n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	bgt.s	mt_toneportasetper
	move.w	n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)
	bra.s	mt_toneportasetper

mt_toneportaup
	sub.w	d0,n_period(a6)
	move.w	n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	blt.s	mt_toneportasetper
	move.w	n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)

mt_toneportasetper
	move.w	n_period(a6),d2
	move.b	n_glissfunk(a6),d0
	and.b	#$0f,d0
	beq.s	mt_glissskip
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	mulu	#36*2,d0
	lea	mt_periodtable(pc),a0
	add.l	d0,a0
	moveq	#0,d0
mt_glissloop
	cmp.w	(a0,d0.w),d2
	bhs.s	mt_glissfound
	addq.w	#2,d0
	cmp.w	#36*2,d0
	blo.s	mt_glissloop
	moveq	#35*2,d0
mt_glissfound
	move.w	(a0,d0.w),d2
mt_glissskip
	move.w	d2,6(a5) 	* set period
	rts

****************************************
mt_vibrato
	move.b	n_cmdlo(a6),d0
	beq.s	mt_vibrato2
	move.b	n_vibratocmd(a6),d2
	and.b	#$0f,d0
	beq.s	mt_vibskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_vibskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	mt_vibskip2
	and.b	#$0f,d2
	or.b	d0,d2
mt_vibskip2
	move.b	d2,n_vibratocmd(a6)
mt_vibrato2
	move.b	n_vibratopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr.w	#2,d0
	and.w	#$001f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	and.b	#$03,d2
	beq.s	mt_vib_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	mt_vib_rampdown
	move.b	#255,d2
	bra.s	mt_vib_set
mt_vib_rampdown
	tst.b	n_vibratopos(a6)
	bpl.s	mt_vib_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	mt_vib_set
mt_vib_rampdown2
	move.b	d0,d2
	bra.s	mt_vib_set
mt_vib_sine
	move.b	0(a4,d0.w),d2
mt_vib_set
	move.b	n_vibratocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w	n_period(a6),d0
	tst.b	n_vibratopos(a6)
	bmi.s	mt_vibratoneg
	add.w	d2,d0
	bra.s	mt_vibrato3
mt_vibratoneg
	sub.w	d2,d0
mt_vibrato3
	move.w	d0,6(a5)
	move.b	n_vibratocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$003c,d0
	add.b	d0,n_vibratopos(a6)
	rts

mt_toneplusvolslide
	bsr	mt_toneportnochange
	bra	mt_volumeslide

mt_vibratoplusvolslide
	bsr.s	mt_vibrato2
	bra	mt_volumeslide

****************************************
mt_tremolo
	move.b	n_cmdlo(a6),d0
	beq.s	mt_tremolo2
	move.b	n_tremolocmd(a6),d2
	and.b	#$0f,d0
	beq.s	mt_treskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_treskip
	move.b	n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	mt_treskip2
	and.b	#$0f,d2
	or.b	d0,d2
mt_treskip2
	move.b	d2,n_tremolocmd(a6)
mt_tremolo2
	move.b	n_tremolopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr.w	#2,d0
	and.w	#$001f,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	lsr.b	#4,d2
	and.b	#$03,d2
	beq.s	mt_tre_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	mt_tre_rampdown
	move.b	#255,d2
	bra.s	mt_tre_set
mt_tre_rampdown
	tst.b	n_vibratopos(a6)
	bpl.s	mt_tre_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	mt_tre_set
mt_tre_rampdown2
	move.b	d0,d2
	bra.s	mt_tre_set
mt_tre_sine
	move.b	0(a4,d0.w),d2
mt_tre_set
	move.b	n_tremolocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#6,d2
	moveq	#0,d0
	move.b	n_volume(a6),d0
	tst.b	n_tremolopos(a6)
	bmi.s	mt_tremoloneg
	add.w	d2,d0
	bra.s	mt_tremolo3
mt_tremoloneg
	sub.w	d2,d0
mt_tremolo3
	bpl.s	mt_tremoloskip
	clr.w	d0
mt_tremoloskip
	cmp.w	#$40,d0
	bls.s	mt_tremolook
	move.w	#$40,d0
mt_tremolook
	move.w	d0,8(a5)
	move.b	n_tremolocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$003c,d0
	add.b	d0,n_tremolopos(a6)
	rts

****************************************
mt_sampleoffset
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	beq.s	mt_sononew
	move.b	d0,n_sampleoffset(a6)
mt_sononew
	move.b	n_sampleoffset(a6),d0
	lsl.w	#7,d0
	cmp.w	n_length(a6),d0
	bge.s	mt_sofskip
	sub.w	d0,n_length(a6)
	lsl.w	#1,d0
	add.l	d0,n_start(a6)
	rts
mt_sofskip
	move.w	#1,n_length(a6)
	rts

****************************************
mt_volumeslide
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_volslidedown
mt_volslideup
	add.b	d0,n_volume(a6)
	cmp.b	#$40,n_volume(a6)
	bmi.s	mt_vsuskip
	move.b	#$40,n_volume(a6)
mt_vsuskip
	move.b	n_volume(a6),d0
	move.w	d0,8(a5)
	rts

mt_volslidedown
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
mt_volslidedown2
	sub.b	d0,n_volume(a6)
	bpl.s	mt_vsdskip
	clr.b	n_volume(a6)
mt_vsdskip
	move.b	n_volume(a6),d0
	move.w	d0,8(a5)
	rts

****************************************
mt_positionjump
	move.b	n_cmdlo(a6),d0
	subq.b	#1,d0
	move.b	d0,mt_songpos
mt_pj2	clr.b	mt_pbreakpos
	st	mt_posjumpflag
	rts

****************************************
mt_volumechange
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	cmp.b	#$40,d0
	bls.s	mt_volumeok
	moveq	#$40,d0
mt_volumeok
	move.b	d0,n_volume(a6)
	move.w	d0,8(a5)
	rts

****************************************
mt_patternbreak
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	move.l	d0,d2
	lsr.b	#4,d0
	mulu	#10,d0
	and.b	#$0f,d2
	add.b	d2,d0
	cmp.b	#63,d0
	bhi.s	mt_pj2
	move.b	d0,mt_pbreakpos
	st	mt_posjumpflag
	rts

****************************************
mt_setspeed
	move.b	3(a6),d0
	beq.s	mt_rts3
	clr.b	mt_counter
	move.b	d0,mt_speed
	rts

****************************************
mt_checkmoreefx
	bsr	mt_updatefunk
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$9,d0
	beq	mt_sampleoffset
	cmp.b	#$b,d0
	beq	mt_positionjump
	cmp.b	#$d,d0
	beq.s	mt_patternbreak
	cmp.b	#$e,d0
	beq.s	mt_e_commands
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	cmp.b	#$c,d0
	beq	mt_volumechange
mt_rts3	rts	
****************************************
mt_e_commands
	move.b	n_cmdlo(a6),d0
	and.w	#$f0,d0
	lsr.w	#3,d0		* make lhs, mult by 2
	lea	mt_filteronoff(pc),a4
	add.w	mt_efx_list(pc,d0.w),a4
	jmp	(a4)

mt_efx_list	dc.w	mt_filteronoff-mt_filteronoff
	dc.w	mt_fineportaup-mt_filteronoff
	dc.w	mt_fineportadown-mt_filteronoff
	dc.w	mt_setglisscontrol-mt_filteronoff
	dc.w	mt_setvibratocontrol-mt_filteronoff
	dc.w	mt_setfinetune-mt_filteronoff
	dc.w	mt_jumploop-mt_filteronoff
	dc.w	mt_settremolocontrol-mt_filteronoff
	dc.w	mt_rts6-mt_filteronoff
	dc.w	mt_retrignote-mt_filteronoff
	dc.w	mt_volumefineup-mt_filteronoff
	dc.w	mt_volumefinedown-mt_filteronoff
	dc.w	mt_notecut-mt_filteronoff
	dc.w	mt_notedelay-mt_filteronoff
	dc.w	mt_patterndelay-mt_filteronoff
	dc.w	mt_funkit-mt_filteronoff
	
****************************************
mt_filteronoff
	move.b	n_cmdlo(a6),d0
	and.b	#1,d0
	asl.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
mt_rts6	rts	

mt_setglisscontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	and.b	#$f0,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	rts

mt_setvibratocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	and.b	#$f0,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_setfinetune
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	move.b	d0,n_finetune(a6)
	rts

mt_jumploop
	tst.b	mt_counter
	bne.s	mt_rts4
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.s	mt_setloop
	tst.b	n_loopcount(a6)
	beq.s	mt_jumpcnt
	subq.b	#1,n_loopcount(a6)
	beq.s	mt_rts4
mt_jmploop
	move.b	n_pattpos(a6),mt_pbreakpos
	st	mt_pbreakflag
mt_rts4	rts

mt_jumpcnt
	move.b	d0,n_loopcount(a6)
	bra.s	mt_jmploop

mt_setloop
	move.w	mt_pattpos(pc),d0
	lsr.w	#4,d0
	move.b	d0,n_pattpos(a6)
	rts

mt_settremolocontrol
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	and.b	#$0f,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_retrignote
	move.l	d1,-(sp)
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.s	mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
	bne.s	mt_rtnskp
	move.w	(a6),d1
	and.w	#$0fff,d1
	bne.s	mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
mt_rtnskp
	divu	d0,d1
	swap	d1
	tst.w	d1
	bne.s	mt_rtnend
mt_doretrig
	move.w	n_dmabit(a6),$dff096	* channel dma off
	move.l	n_start(a6),(a5)		* set sampledata pointer
	move.w	n_length(a6),4(a5)		* set length
	move.w	#dmawait,d0
mt_rtnloop1
	dbra	d0,mt_rtnloop1
	move.w	n_dmabit(a6),d0
	bset	#15,d0
	move.w	d0,$dff096
	move.w	#dmawait,d0
mt_rtnloop2
	dbra	d0,mt_rtnloop2
	move.l	n_loopstart(a6),(a5)
	move.l	n_replen(a6),4(a5)
mt_rtnend
	move.l	(sp)+,d1
	rts

mt_volumefineup
	tst.b	mt_counter
	bne.s	mt_rts5
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$f,d0
	bra	mt_volslideup

mt_volumefinedown
	tst.b	mt_counter
	bne.s	mt_rts5
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	bra	mt_volslidedown2

mt_notecut
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	mt_counter(pc),d0
	bne.s	mt_rts5
	clr.b	n_volume(a6)
	move.w	#0,8(a5)
mt_rts5	rts

mt_notedelay
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	mt_counter,d0
	bne.s	mt_rts5
	move.w	(a6),d0
	beq.s	mt_rts5
	move.l	d1,-(sp)
	bra	mt_doretrig

mt_patterndelay
	tst.b	mt_counter
	bne.s	mt_rts5
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	tst.b	mt_pattdeltime2
	bne.s	mt_rts5
	addq.b	#1,d0
	move.b	d0,mt_pattdeltime
	rts

mt_funkit
	tst.b	mt_counter
	bne.s	mt_rts5
	move.b	n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	and.b	#$0f,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	tst.b	d0
	beq.s	mt_rts5
mt_updatefunk
	movem.l	a0/d1,-(sp)
	moveq	#0,d0
	move.b	n_glissfunk(a6),d0
	lsr.b	#4,d0
	beq.s	mt_funkend
	lea	mt_funktable(pc),a0
	move.b	(a0,d0.w),d0
	add.b	d0,n_funkoffset(a6)
	btst	#7,n_funkoffset(a6)
	beq.s	mt_funkend
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
	blo.s	mt_funkok
	move.l	n_loopstart(a6),a0
mt_funkok
	move.l	a0,n_wavestart(a6)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
mt_funkend
	movem.l	(sp)+,a0/d1
	rts

*******************************************************************
* start of data
*

mt_funktable
	dc.b	0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
	even
	
mt_vibratotable	
	dc.b	0,24,49,74,97,120,141,161
	dc.b	180,197,212,224,235,244,250,253
	dc.b	255,253,250,244,235,224,212,197
	dc.b	180,161,141,120,97,74,49,24
	even
	
mt_periodtable
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

mt_chan1temp		dc.l	0,0,0,0,0,$00010000,0,0,0,0,0
mt_chan2temp		dc.l	0,0,0,0,0,$00020000,0,0,0,0,0
mt_chan3temp		dc.l	0,0,0,0,0,$00040000,0,0,0,0,0
mt_chan4temp		dc.l	0,0,0,0,0,$00080000,0,0,0,0,0

mt_samplestarts	ds.l	31

mt_songdataptr	dc.l	0

mt_speed		dc.b	6
mt_counter		dc.b	0
mt_songpos		dc.b	0
mt_pbreakpos		dc.b	0
mt_posjumpflag	dc.b	0
mt_pbreakflag	dc.b	0
mt_lowmask		dc.b	0
mt_pattdeltime	dc.b	0
mt_pattdeltime2	dc.b	0
		dc.b	0
		even

mt_pattpos		dc.w	0
mt_dmacontemp	dc.w	0

mt_mulu		dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


