	include "registers.i"
	include "hardware/custom.i"

START:
	lea	CUSTOM,a6
	move.w	#$7fff,INTENA(a6) ; Disable all interrupts
	move.w	#$7fff,DMACON(a6) ; Disable all DMA
	move.w	#$87e0,DMACON(a6) ; Enable Master, Raster, Copper, and Blitter DMA

	; Install our Copper list
	lea	COPPER_LIST(pc),a0
	move.l	a0,COP1LC(a6)
	move.w	COPJMP1(a6),d0  ; Force Copper to start

.main_loop:
.wait_vblank:
	move.l	VPOSR(a6),d0
	and.l	#$1ff00,d0
	cmp.l	#$300,d0
	bne.s	.wait_vblank

	; [Frame update logic goes here]

	bra.s	.main_loop

	even
COPPER_LIST:
	dc.w	COLOR00,$000
	; [Copper instructions go here]
	dc.l	$fffffffe
