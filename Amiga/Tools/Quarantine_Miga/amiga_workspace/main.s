	include "registers.i"
	include "hardware/custom.i"

	section MyCode,code_c

START:
	lea	CUSTOM,a6
	
	; Kill OS and clear screen garbage
	move.w	#$7fff,INTENA(a6)
	move.w	#$7fff,DMACON(a6)
	move.w	#$0000,BPLCON0(a6)
	move.w	#$000,COLOR00(a6)

	; Install Copper
	lea	COPPER_LIST(pc),a0
	move.l	a0,COP1LC(a6)
	move.w	COPJMP1(a6),d0
	
	; Enable Copper DMA
	move.w	#$8080,DMACON(a6)

.loop:
.v1:	move.l	VPOSR(a6),d0
	and.l	#$1ff00,d0
	bne.s	.v1
.v2:	move.l	VPOSR(a6),d0
	and.l	#$1ff00,d0
	beq.s	.v2

	move.w	BAR_Y(pc),d0
	add.w	DIR(pc),d0
	cmp.w	#$2c,d0
	bgt.s	.n1
	move.w	#1,DIR
.n1:	cmp.w	#$f0,d0
	blt.s	.n2
	move.w	#-1,DIR
.n2:	move.w	d0,BAR_Y

	lea	BW(pc),a0
	lsl.w	#8,d0
	or.w	#$07,d0
	move.w	d0,(a0)
	bra.s	.loop

BAR_Y:	dc.w	$80
DIR:	dc.w	1
	even
COPPER_LIST:
	dc.w	COLOR00,$000
BW:	dc.w	$8007,$fffe
	dc.w	COLOR00,$00f
	dc.w	$0107,$fffe
	dc.w	COLOR00,$000
	dc.l	$fffffffe
