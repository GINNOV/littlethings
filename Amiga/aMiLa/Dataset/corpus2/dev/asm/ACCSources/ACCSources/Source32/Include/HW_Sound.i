
		LIST
*** Sound.i v1.00, by M.Meany ***
		NOLIST

;*****	Sample player, first part of spot effect system

; This routine should be called once every VBL befors any SFX are requested.
;This will result in a maximum of 1/50 second delay between requesting and
;hearing a sample.

; Entry		SEChan0,1,2,3 hold pointers to samples if any to be played

; Exit		SEChan0,1,2,3 all cleared

; Corrupt	none

SEPlayer	movem.l		d0-d4/a0-a2,-(sp)

		lea		SEChan0,a0		a0->1st channel
		lea		AUD0LCH(a5),a1		a1->HW Registers
		moveq.l		#AUD0EN,d0		DMA enable bits
		moveq.l		#3,d2			counter: 4-1 channels

SELoop		move.l		(a0)+,d1		get next channel data
		beq.s		SENext			skip if 0

		move.l		d1,a2			a2->sample structure

; See if user wants a specific frequency, if not use default

		move.w		(a2)+,d4
		bne.s		SEFreq			skip if they do
		move.w		#$12c,d4		else set default

; Initialise audio channel

SEFreq		move.w		(a2)+,4(a1)		sample length
		move.l		(a2),(a1)		samples address
		move.w		d4,6(a1)		sample period
		move.w		#$64,8(a1)		sample volume

; Now start channel 0 DMA

		move.w		d0,d3			DMA bit
		or.w		#SETIT+DMAEN,d3		+ SETIT + DMAEN
		move.w		d3,DMACON(a5)		start DMA for channel

; And initialise a quiet sample to follow it

		move.w		#1,4(a1)

; Clear this sample request

		move.l		#0,-4(a0)		clear request

SENext		lea		16(a1),a1		a1->Next channel
		lsl.w		#1,d0			next DMA bit
		dbra		d2,SELoop		for all 4 channels

		movem.l		(sp)+,d0-d4/a0-a2

		rts					and exit

;*****	Sample Request, second part of spot effects system

; Entry		a0->sample structure to play
;		d0=channel number ( 0,1,2 or 3 ) no checking!

; Corrupt	d0,d1,a1

SEFX		moveq.l		#AUD0EN,d1
		asl.w		d0,d1			d1=DMA Enable bit

		lea		SEChan0,a1		a1->storage point
		asl.w		#2,d0			offset=ch No * 4
		adda.l		d0,a1			a1
		move.l		a0,(a1)			set sample to play
		move.w		d1,DMACON(a5)		stop current sample
		rts					and exit

SEChan0		dc.l		0
SEChan1		dc.l		0
SEChan2		dc.l		0
SEChan3		dc.l		0

		