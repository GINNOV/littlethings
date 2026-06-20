
; Spot effect sound routines, by M.Meany.

; PlaySample	Initialise a sample for playing. Will start during next
;		call to SmpPlayer.

;	Entry	a0->sample structure ( see below )
;		d0=channel number ( 0->3 )

; SmpPlayer	Should be called during vertical blank interrupt. Launches
;		any samples requested during previous interrupt.

;	Entry	None.

; DoSample	Launches a sample straight away. No need for interrupt
;		player to use this routine.

;	Entry	a0->sample structure ( see below )
;		d0=channel number ( 0->3 )

; The raw samples should be defined using the macro below. This ensures that
;the word length of the sample is stored before the sample data as required
;by the replay routines. The label at which the sample is to appear is also
;set up using the macro. For example, to define a sample at the label 'Bang'
;with raw data found in the file 'df0:sounds/bang.snd' use the sample as
;follows:

;		SETSAMPLE	Bang,'df0:sounds/bang.snd'		

SETSAMPLE	macro		label,file
\1		dc.w		\1_size
		incbin		\2
\1_size		=		(*-\1)>>1-1
		endm

		LIST
*** Sound.i v1.00, by M.Meany ***
		NOLIST

*****
*****	Simple raw sample player
*****

; Entry		a0->Sample structure
;		d0=channel ( 0,1,2,3 ) if d0>3 then d0=3.

PlaySample	cmp.w		#0,d0
		bne.s		.try1

		move.w		#$0001,$dff096		stop channel 0 dma
		move.l		a0,ch0_smp		set addr of sample
		bra.s		.done			and exit

.try1		cmp.w		#1,d0
		bne.s		.try2

		move.w		#$0002,$dff096		stop channel 1 dma
		move.l		a0,ch1_smp		set addr of sample
		bra.s		.done			and exit

.try2		cmp.w		#2,d0
		bne.s		.do3

		move.w		#$0004,$dff096		stop channel 2 dma
		move.l		a0,ch2_smp		set addr of sample
		bra.s		.done			and exit

.do3		move.w		#$0008,$dff096		stop channel 3 dma
		move.l		a0,ch3_smp		set addr of sample

.done		rts

*****
*****	Sample player, should be called every vertical blank or similar
*****

SmpPlayer	PUSH		d0-d4/a0-a2

		lea		$dff0a0,a1		a1->channel 0
		lea		ch0_smp,a2		a2->channel list
		moveq.l		#3,d3			num channels - 1
		moveq.l		#$0001,d4
		move.l		#$0080,d1		Interrupt bit mask
		
; Initialise sample and start it playing

.play		tst.l		(a2)			start sample ?
		beq		.next			no, so skip!

		move.l		(a2),a0			a0->sample
		clr.l		(a2)
		move.w		(a0)+,4(a1)		sample length
		move.l		a0,(a1)			sample address
		move.w		#64,8(a1)		volume
		move.w		#$12c,6(a1)		period
		move.w		d4,d0
		or.w		#$8200,d0
		move.w		d0,$dff096		start sample

; Wait for DMA channel to read registers and init a quiet sample. The quiet
;sample will be left playing!

		move.w		d1,$dff09c		clear bit
.WaitL4		move.w		$dff01e,d2		get bits
		and.w		d1,d2
		beq.s		.WaitL4
		
		move.l		#_NullSample,(a1)	quiet sound
		move.w		#2,4(a1)		length

.next		addq.l		#4,a2			next channel
		lea		$10(a1),a1		next register set
		asl.w		#1,d4
		asl.w		#1,d1
		dbra		d3,.play

		PULL		d0-d4/a0-a2
		rts

*****
*****	Launch a sample straight away. Does not rely on level 3 player.
*****

; Entry		a0->Sample structure
;		d0=channel ( 0,1,2,3 ) if d0>3 then d0=3.

DoSample	PUSH		d0-d3/a0-a1

; Decide which channel was chosen and initialise accordingly.
;NOTE -- takes a little longer to play a channel 3 sample than a channel 0
;        sample. Use channels 0 and 2 as much as possible!		

		cmp.w		#0,d0
		bne.s		.try1

		lea		$dff0a0,a1
		move.w		#SETIT!DMAEN!AUD0EN,d0	DMA enable
		move.w		#AUD0EN,d1		DMA disable
		move.w		#AUD0,d2		interrupt disable
		bra		.GetOnWithIt

.try1		cmp.w		#1,d0
		bne.s		.try2

		lea		$dff0b0,a1
		move.w		#SETIT!DMAEN!AUD1EN,d0	DMA enable
		move.w		#AUD1EN,d1		DMA disable
		move.w		#AUD1,d2		interrupt disable

		bra		.GetOnWithIt


.try2		cmp.w		#2,d0
		bne.s		.do3

		lea		$dff0c0,a1
		move.w		#SETIT!DMAEN!AUD2EN,d0	DMA enable
		move.w		#AUD2EN,d1		DMA disable
		move.w		#AUD2,d2		interrupt disable

		bra.s		.GetOnWithIt

.do3		lea		$dff0d0,a1
		move.w		#SETIT!DMAEN!AUD3EN,d0	DMA enable
		move.w		#AUD3EN,d1		DMA disable
		move.w		#AUD3,d2		interrupt disable

.GetOnWithIt	move.w		d1,DMACON+$dff000	stop sample

; Initialise sample and start it playing

		move.w		(a0)+,4(a1)		sample length
		move.l		a0,(a1)			sample address
		move.w		#64,8(a1)		volume
		move.w		#$12c,6(a1)		period
		move.w		d0,DMACON+$dff000	start sample

; Wait for DMA channel to read registers and init a quiet sample. The quiet
;sample will be left playing!

		move.w		d2,INTREQ+$dff000	clear bit
.WaitL4		move.w		INTREQR+$dff000,d3	get bits
		and.w		d2,d3
		beq.s		.WaitL4
		
		move.l		#_NullSample,(a1)	quiet sound
		move.w		#2,4(a1)		length
		
		PULL		d0-d3/a0-a1
		rts

ch0_smp		dc.l		0
ch1_smp		dc.l		0
ch2_smp		dc.l		0
ch3_smp		dc.l		0
		