	; MOD playback control: the display updates, but the player is never advanced.
	include "../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"

LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH		equ 320
SCREEN_HEIGHT		equ 256
SCREEN_WIDTH_BYTES	equ (SCREEN_WIDTH/8)
BITPLANE_SIZE		equ SCREEN_WIDTH_BYTES*SCREEN_HEIGHT
SCREEN_BIT_DEPTH	equ 1
SCREEN_RES		equ 8
RASTER_X_START		equ $81
RASTER_Y_START		equ $2c
RASTER_X_STOP		equ RASTER_X_START+SCREEN_WIDTH
RASTER_Y_STOP		equ RASTER_Y_START+SCREEN_HEIGHT
BAR_HEIGHT		equ 18
BAR1_Y			equ 28
BAR2_Y			equ 70
BAR3_Y			equ 112

start:
	lea	CUSTOM,a6

	move.w	#$7ff,DMACON(a6)
	move.w	#$7fff,INTENA(a6)
	move.w	#$7fff,INTREQ(a6)

	bsr	poke_bitplane_pointer
	bsr	setup_playfield
	bsr	clear_bitplane

	lea	mt_data(pc),a0
	sub.l	a1,a1
	sub.l	a2,a2
	moveq	#0,d0
	jsr	mt_init(pc)

	lea	copper(pc),a0
	move.l	a0,COP1LC(a6)
	move.w	COPJMP1(a6),d0
	move.w	#(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)

.loop:
	bsr	wait_frame
	bsr	paint_state_bars
	bra.s	.loop

wait_frame:
	move.w	VPOSR(a6),d0
.waitsame:
	cmp.w	VPOSR(a6),d0
	beq.s	.waitsame
	rts

setup_playfield:
	move.w	#(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a6)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a6)
	move.w	#(RASTER_X_START/2-SCREEN_RES),DDFSTRT(a6)
	move.w	#(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a6)
	move.w	#(SCREEN_BIT_DEPTH<<12)|$200,BPLCON0(a6)
	clr.w	BPL1MOD(a6)
	rts

poke_bitplane_pointer:
	lea	bitplane,a0
	lea	_BPL1PTL(pc),a1
	move.l	a0,d0
	move.w	d0,(a1)
	swap	d0
	lea	_BPL1PTH(pc),a1
	move.w	d0,(a1)
	rts

clear_bitplane:
	lea	bitplane,a0
	moveq	#0,d0
	move.w	#((BITPLANE_SIZE/4)-1),d1
.clearLoop:
	move.l	d0,(a0)+
	dbra	d1,.clearLoop
	rts

paint_state_bars:
	bsr	clear_bitplane

	moveq	#0,d0
	move.w	mt_PatternPos(pc),d0
	lsr.w	#5,d0
	addi.w	#4,d0
	cmpi.w	#SCREEN_WIDTH_BYTES,d0
	ble.s	.bar1Ready
	move.w	#SCREEN_WIDTH_BYTES,d0
.bar1Ready:
	move.w	#BAR1_Y,d1
	move.w	#BAR_HEIGHT,d2
	bsr	fill_bar

	moveq	#0,d0
	move.b	mt_counter(pc),d0
	lsl.w	#2,d0
	addi.w	#4,d0
	cmpi.w	#SCREEN_WIDTH_BYTES,d0
	ble.s	.bar2Ready
	move.w	#SCREEN_WIDTH_BYTES,d0
.bar2Ready:
	move.w	#BAR2_Y,d1
	move.w	#BAR_HEIGHT,d2
	bsr	fill_bar

	moveq	#0,d0
	move.b	mt_SongPos(pc),d0
	lsl.w	#1,d0
	addi.w	#4,d0
	cmpi.w	#SCREEN_WIDTH_BYTES,d0
	ble.s	.bar3Ready
	move.w	#SCREEN_WIDTH_BYTES,d0
.bar3Ready:
	move.w	#BAR3_Y,d1
	move.w	#BAR_HEIGHT,d2
	bsr	fill_bar
	rts

fill_bar:
	lea	bitplane,a0
	mulu	#SCREEN_WIDTH_BYTES,d1
	adda.l	d1,a0
	move.w	d2,d7
	subq.w	#1,d7
.rowLoop:
	move.w	d0,d6
	movea.l	a0,a1
	subq.w	#1,d6
	blt.s	.nextRow
.fillLoop:
	move.b	#$ff,(a1)+
	dbra	d6,.fillLoop
.nextRow:
	lea	SCREEN_WIDTH_BYTES(a0),a0
	dbra	d7,.rowLoop
	rts

copper:
	dc.w	BPL1PTH
_BPL1PTH:
	dc.w	0
	dc.w	BPL1PTL
_BPL1PTL:
	dc.w	0
	dc.w	COLOR00,$0112
	dc.w	COLOR01,$0fff
	dc.l	$fffffffe
	include "../include/ProTracker2.3A.i"

mt_data:
	incbin "music.mod"

	cnop 0,4
bitplane:
	dcb.b	BITPLANE_SIZE,0
