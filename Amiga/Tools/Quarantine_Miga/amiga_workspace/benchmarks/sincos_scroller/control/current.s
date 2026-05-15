	; Phase-1 sin/cos text scroller control.
	; Keeps the same text band fixed in place so the temporal suite can reject it.
	include "../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"

SCREEN_WIDTH		equ 320
SCREEN_HEIGHT		equ 256
SCREEN_WIDTH_BYTES	equ (SCREEN_WIDTH/8)
BITPLANE_SIZE		equ SCREEN_WIDTH_BYTES*SCREEN_HEIGHT
SCREEN_BIT_DEPTH		equ 1
SCREEN_RES		equ 8
RASTER_X_START		equ $81
RASTER_Y_START		equ $2c
RASTER_X_STOP		equ RASTER_X_START+SCREEN_WIDTH
RASTER_Y_STOP		equ RASTER_Y_START+SCREEN_HEIGHT
CHAR_H			equ 8
BAND_BASE_Y		equ 70
START_X_BYTE		equ 6
VISIBLE_CHARS		equ 14

start:
	lea 	CUSTOM,a6

	move	#$7ff,DMACON(a6)
	move	#$7fff,INTENA(a6)

	bsr	poke_bitplane_pointer
	bsr	setup_playfield

	lea	copper(pc),a0
	move.l	a0,COP1LC(a6)
	move.w	COPJMP1(a6),d0
	move.w	#(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)
	move.w	#(INTF_SETCLR|INTF_INTEN|INTF_EXTER),INTENA(a6)

.mainLoop:
	bsr	wait_frame
	bsr	clear_bitplane

	moveq	#0,d4
.renderLoop:
	lea	message(pc),a0
	moveq	#0,d1
	move.b	0(a0,d4.w),d1

	move.w	#BAND_BASE_Y,d2
	move.w	d4,d3
	addi.w	#START_X_BYTE,d3

	move.w	d1,d0
	move.w	d2,d1
	move.w	d3,d2
	bsr	draw_glyph

	addq.w	#1,d4
	cmpi.w	#VISIBLE_CHARS,d4
	blt	.renderLoop

	bra	.mainLoop

wait_frame:
	move.w	VPOSR(a6),d0
.waitsame:
	cmp.w	VPOSR(a6),d0
	beq.s	.waitsame
	rts

setup_playfield:
	move.w  #(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a6)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a6)
	move.w	#(RASTER_X_START/2-SCREEN_RES),DDFSTRT(a6)
	move.w	#(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a6)
	move.w	#(SCREEN_BIT_DEPTH<<12)|$200,BPLCON0(a6)
	clr.w	BPL1MOD(a6)
	rts

poke_bitplane_pointer:
	lea	bitplane(pc),a0
	lea	_BPL1PTL(pc),a1
	move.l	a0,d0
	move.w	d0,(a1)
	swap	d0
	lea	_BPL1PTH(pc),a1
	move.w	d0,(a1)
	rts

clear_bitplane:
	lea	bitplane(pc),a0
	moveq	#0,d0
	move.w	#((BITPLANE_SIZE/4)-1),d1
.clearLoop:
	move.l	d0,(a0)+
	dbra	d1,.clearLoop
	rts

draw_glyph:
	lea	glyphs(pc),a1
	lsl.w	#3,d0
	adda.w	d0,a1
	lea	bitplane(pc),a0
	mulu	#SCREEN_WIDTH_BYTES,d1
	adda.l	d1,a0
	adda.w	d2,a0
	moveq	#CHAR_H-1,d6
.rowLoop:
	move.b	(a1)+,(a0)
	lea	SCREEN_WIDTH_BYTES(a0),a0
	dbra	d6,.rowLoop
	rts

copper:
	dc.w	BPL1PTH
_BPL1PTH:
	dc.w	0
	dc.w	BPL1PTL
_BPL1PTL:
	dc.w	0
	dc.w	COLOR00,$0000
	dc.w	COLOR01,$0fff
	dc.l	$fffffffe

message:
	dc.b 0,1,2,3,4,5,2,6,7,4,8,0,9,7

glyphs:
	; A
	dc.b %00111100
	dc.b %01100110
	dc.b %01100110
	dc.b %01111110
	dc.b %01100110
	dc.b %01100110
	dc.b %01100110
	dc.b %00000000
	; M
	dc.b %01100011
	dc.b %01110111
	dc.b %01111111
	dc.b %01101011
	dc.b %01100011
	dc.b %01100011
	dc.b %01100011
	dc.b %00000000
	; I
	dc.b %00111100
	dc.b %00011000
	dc.b %00011000
	dc.b %00011000
	dc.b %00011000
	dc.b %00011000
	dc.b %00111100
	dc.b %00000000
	; G
	dc.b %00111100
	dc.b %01100110
	dc.b %01100000
	dc.b %01101110
	dc.b %01100110
	dc.b %01100110
	dc.b %00111110
	dc.b %00000000
	; space
	dc.b %00000000
	dc.b %00000000
	dc.b %00000000
	dc.b %00000000
	dc.b %00000000
	dc.b %00000000
	dc.b %00000000
	dc.b %00000000
	; S
	dc.b %00111110
	dc.b %01100000
	dc.b %01100000
	dc.b %00111100
	dc.b %00000110
	dc.b %00000110
	dc.b %01111100
	dc.b %00000000
	; N
	dc.b %01100011
	dc.b %01110011
	dc.b %01111011
	dc.b %01101111
	dc.b %01100111
	dc.b %01100011
	dc.b %01100011
	dc.b %00000000
	; E
	dc.b %01111110
	dc.b %01100000
	dc.b %01100000
	dc.b %01111100
	dc.b %01100000
	dc.b %01100000
	dc.b %01111110
	dc.b %00000000
	; W
	dc.b %01100011
	dc.b %01100011
	dc.b %01100011
	dc.b %01101011
	dc.b %01111111
	dc.b %01110111
	dc.b %01100011
	dc.b %00000000
	; V
	dc.b %01100011
	dc.b %01100011
	dc.b %01100011
	dc.b %01100011
	dc.b %00110110
	dc.b %00110110
	dc.b %00011100
	dc.b %00000000

bitplane:
	dcb.b	BITPLANE_SIZE,$00
