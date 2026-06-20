
; Audio Example 3: Interrupt Driven Sample Player
;		   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; by M.Meany

; No sample priority and only one channel used for simplicity!

; This is also in answer to Dac who wanted to know how to interrupt a sample
;that is playing :-)


		include		source:include/hardware.i

Start		lea		$dff000,a5		hardware base

; Get copy of system's Level 3 interrupt vector and enable bits

		move.l		$6c,sysL3Vect		save vector
		move.w		INTENAR(a5),sysINTS	and requirements

; Stop level 3 interrupts

		move.w		#BLIT!VERTB!COPER,INTENA(a5)

; Write new level 3 vector

		move.l		#Level3Code,$6c

; Enable vert blank interrupts only

		move.w		#SETIT!VERTB,INTENA(a5)	enable level 3

; Wait for mouse to be pressed

Mouse		btst		#6,CIAAPRA
		bne.s		Mouse

; Stop level 3 interrupts

		move.w		#VERTB,INTENA(a5)

; Restore systems level 3 vector

		move.l		sysL3Vect,$6c

; Enable interrupts as required by system

		move.w		sysINTS,d0		system bits
		or.w		#SETIT!INTEN,d0		were setting them
		move.w		d0,INTENA(a5)		enable

; All done. Kill sound on channel 0 incase it's still playing!

		move.w		#0,AUD0VOL(a5)		quiet!

		rts					go home

*****************************************************************************

;---
;---	level 3 interrupt handler
;---


Level3Code	movem.l		a0-a6/d0-d7,-(a7)	Save all registers

		lea		$dff000,a5		hardware registers

; Start any new samples playing

		bsr		PlaySFX

; See if new sample is required

		bsr		TestFire

; Clear interrupt request bits now

		move.w		#BLIT!VERTB!COPER,INTREQ(a5) clear L3 bits

.Done		movem.l		(a7)+,a0-a6/d0-d7	restore registers
		rte					what, no handler!

*****************************************************************************

; Vertical blank interrupt driven sample player.

; At present only one channel is used, but a seperate structure could be
;maintained on all four channels if required.

PlaySFX		lea		Channel0,a0		a0->struct

; See if a new sample has been requested

		tst.w		ch_New(a0)		new sample?
		beq.s		.Done			skip if not
		
; New sample, start playing it!

		move.l		ch_Addr(a0),AUD0LCH(a5) set new address
		move.w		ch_Len(a0),AUD0LEN(a5)	set new length
		move.w		#64,AUD0VOL(a5)		set volume
		move.w		#$12c,AUD0PER(a5)	set period
		move.w		#SETIT!AUD0EN,DMACON(a5) start playing

; When audio DMA channel is ready for next sample it will generate a level 4
;interrupt. Wait for this interrupt and then write address of ' quiet '
;sample. This will ensure sample only plays once that we can hear. I am
;assuming there is not a Level 4 interrupt enabled!

		move.w		#AUD0,INTREQ(a5)	clear bit

.WaitL4		btst		#7,INTREQR+1(a5)	wait for acceptance
		beq.w		.WaitL4

		move.l		#NullSample,AUD0LCH(a5)	quiet sound
		move.w		#50,AUD0LEN(a5)		it's length

		move.w		#0,ch_New(a0)		clear flag

.Done		rts

*****************************************************************************

; Present a new sample to sample player. This stops current sample so channel
;is free at start of next vert blank.

; Entry		a0->raw sample structure

NewSFX		move.w		#AUD0EN,DMACON(a5)	Kill current sound
		lea		Channel0,a1		a1->channel struct
		move.w		(a0)+,ch_Len(a1)	set sample length
		move.l		a0,ch_Addr(a1)		set address
		move.w		#1,ch_New(a1)		signal new sample
		rts					and exit

*****************************************************************************

; When fire button is pressed, a counter is activated. Further presses are
;ignored until counter reaches zero. This gives a sample a chance to start
;playing before repeating due to user holding down fire button.

TestFire	tst.w		vbl_count		counter clear?
		beq.s		.DoFire			yep! ok to start snd
		
		subq.w		#1,vbl_count		dec counter
		bra.s		.done			and exit

.DoFire		tst.b		CIAAPRA			fire button pressed?
		bmi.s		.done			skip if not

		lea		Sample1,a0		sample structure
		bsr.s		NewSFX			signal request
		move.w		#3,vbl_count		activate counter

.done		rts					and exit

*****************************************************************************


; The following structure contains details on a sample for the player.


; The structure offsets

		rsreset
ch_New		rs.w		1		set to play new sound
ch_Addr		rs.l		1		addr of raw data
ch_Len		rs.w		1		length of sample
ch_SIZEOF	rs.b		0

; The structure is allocated here

Channel0	ds.b		ch_SIZEOF	channel 0 audio struct

; Counter used to disable fire checking

vbl_count	dc.w		0		disable fire checks temp

sysINTS		dc.w		0
sysL3Vect	dc.l		0

*****************************************************************************

		section		sounds,DATA_C

Sample1		dc.w		SMP1LEN>>1	word length of sample
SMP1		incbin		shot.snd	sample itself
SMP1LEN		equ		*-SMP1

NullSample	ds.w		50
		
	
