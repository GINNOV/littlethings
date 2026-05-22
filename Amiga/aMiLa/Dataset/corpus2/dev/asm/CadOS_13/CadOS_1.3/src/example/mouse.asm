	include	cados.asm

width	set	320
height	set	256

Maus	move	#width,d0
	move	#height,d1
	move	#1,d2
	move	#128,d3
	move	#44,d4
	move	#0,d5
	move	#MSF_NOBORDER,d6
	jsr	_MakeScreen
	tst.l	a0
	beq	.exit
	setcop	a0
	lea	.copper(pc),a2
	move.l	a0,(a2)
	lea	.screen(pc),a2
	move.l	a1,(a2)

	move.w	#$000,$dff180
	move.w	#$fff,$dff182

	dmaon	RASTER,COPPER

	move	#0,d0
	move	#0,d1
	move	#width-1,d2
	move	#height-1,d3
	jsr	_SetMouseLimits

.wlmb	vsync
	jsr	_GetMouse
	get.l	.screen,a0
	bsr	.FastPlot
	btst.b	#6,$bfe001
	bne.s	.wlmb

	lea	.copper(pc),a0
	move.l	(a0),d0
	jsr	_FreeMem
	lea	.screen(pc),a0
	move.l	(a0),d0
	jsr	_FreeMem

.exit	rts

.copper	dc.l	0
.screen	dc.l	0


.FastPlot
	tst.w	d0
	bmi.s	.fp_quit
	tst.w	d1
	bmi.s	.fp_quit
	cmp.w	#width,d0
	bhi.s	.fp_quit
	cmp.w	#height,d1
	bhi.s	.fp_quit
	add.l	.fp_ymuls(pc,d1.w*4),a0
	move.w	d0,d1
	asr.w	#3,d1
	move.b	.fp_xbits(pc,d0.w),d0
	bset.b	d0,(a0,d1.w)
.fp_quit	rts
.fp_xbits
_fp_cnt	set	7
	rept	width
	dc.b	_fp_cnt
_fp_cnt	set	_fp_cnt-1
	ifeq	_fp_cnt+1
_fp_cnt	set	7
	endc
	endr
	even
.fp_ymuls
_fp_cnt	set	0
	rept	height+1
	dc.l	_fp_cnt
_fp_cnt	set	_fp_cnt+(width/8)
	endr


