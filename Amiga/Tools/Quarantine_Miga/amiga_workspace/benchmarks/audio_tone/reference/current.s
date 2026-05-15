	; Paula audio benchmark reference.
	include "../include/registers.i"
	include "hardware/dmabits.i"

AUDIO_PERIOD	equ 428
AUDIO_VOLUME	equ 64
STATUS_ADDR	equ $7f000

start:
	lea	CUSTOM,a6

	move.w	#$00f,COLOR00(a6)
	move.w	#$7fff,ADKCON(a6)
	move.w	#$7ff,DMACON(a6)
	move.w	#$7fff,INTENA(a6)

	lea	sample_data(pc),a0
	move.l	a0,d0
	move.w	d0,AUD0LCL(a6)
	swap	d0
	move.w	d0,AUD0LCH(a6)
	move.w	#((sample_end-sample_data)/2),AUD0LEN(a6)
	move.w	#AUDIO_PERIOD,AUD0PER(a6)
	move.w	#AUDIO_VOLUME,AUD0VOL(a6)
	move.w	#(DMAF_SETCLR!DMAF_MASTER!DMAF_AUD0),DMACON(a6)
	move.w	#0,AUD0DAT(a6)
	move.l	#'AUD0',STATUS_ADDR
	move.w	#AUDIO_PERIOD,STATUS_ADDR+4
	move.w	#AUDIO_VOLUME,STATUS_ADDR+6
	move.w	#((sample_end-sample_data)/2),STATUS_ADDR+8
	move.w	#(DMAF_MASTER!DMAF_AUD0),STATUS_ADDR+10

.loop:
	bra.s	.loop

	cnop	0,2
sample_data:
	incbin "../tone_sample.bin"
sample_end:
