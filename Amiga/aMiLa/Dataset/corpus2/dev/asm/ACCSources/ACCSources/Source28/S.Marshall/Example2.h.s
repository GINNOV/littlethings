***************************************************************************
*
*		Audio Example Playing A Sample Once
*		 
*		by Steve Marshall
*
***************************************************************************

		incdir		sys:include/
		include		hardware/intbits.i
		include		hardware/dmabits.i
		include		hardware/custom.i

Start
	lea		$dff000,a5		;hardware base

;-------
	move.w		#DMAF_AUD0,dmacon(a5)	;stop audio 0 dma
	move.w		#INTF_AUD0,intreq(a5)	;clear interrupt
	
	move.l		$70.w,OldVector		;save old vector
	move.l		#Aud_interrupt,$70.w	;set new vector		
	
	move.w		#INTF_SETCLR!INTF_AUD0,intena(a5) ;enable audio 0 interrupts

; Write sample parameters into hardware registers

	lea		aud0(a5),a4
	move.w		#64,ac_vol(a4)		set volume
	move.w		#$12c,ac_per(a4)	set period
	move.l		#SMP1,(a4)		set new address
	move.w		#SMP1LEN,ac_len(a4)	set new length

	move.w		#1,Cycles		;set num times to play

; Enable channel 0 DMA to start the sound playing.

	move.w		#DMAF_SETCLR!DMAF_AUD0,dmacon(a5) ;start playing

;------	We can tell if the sample has completed by checking Cycles
;	If Cycles = -1 then the sample has  been completed.
;	We wouldn't normally wait around for it to finish
;	The audio dma switches off automatically, volume is set to 0

Wait
	tst.w		Cycles
	bpl.s		Wait

	move.w		#$12c,ac_per(a4)	set period
	move.w		#64,ac_vol(a4)		set volume
	move.w		#4,Cycles		;set num times to play

; Enable channel 0 DMA to start the sound playing.

	move.w		#DMAF_SETCLR!DMAF_AUD0,dmacon(a5) ;start playing

Wait2
	tst.w		Cycles
	bpl.s		Wait2


;------	All done - disable audio 0 interrupts

	move.w		#INTF_AUD0,intena(a5)	;disable audio 0 interrupts
	move.l		OldVector,$70.w		;restore old vector
	rts					;end of main prog

*****************************************************************************
Aud_interrupt
	movem.l		d0-d1/a0,-(sp)		;save a0 and d0
	lea		$dff000,a0		;a0 = CUSTOM
	move.w		intenar(a0),d0		;get enabled interrupts
	btst		#INTB_INTEN,d0		;test master int enable
	beq.s		.ignore			;ignore if not enabled
	
	and.w		intreqr(a0),d0		;and requested with enabled
	btst		#INTB_AUD0,d0		;is it ours
	beq.s		.skip			;ignore if not
	
	subq.w		#1,Cycles		;decrement counter
	bpl.s		.skip			;skip if not done

;------	Set volume to 0 to avoid click when dma stopped	
	move.w		#1,aud0+ac_per(a0)	;set period
	move.w		#0,aud0+ac_vol(a0)	;set volume
	move.w		#DMAF_AUD0,dmacon(a0) 	;stop audio 0 dma
	move.w		#$20,d1

;------	This is a small loop which is needed with the hardware version
;	of this code. Without it the interrupt hardware seems to become
;	confused and the samples may play one extra time due to inteerupts
;	not being generated. Setting the period to 1 considerably reduces
;	the time required for the audio hardware to reset itself. The 
;	system version of this code can get away with just setting the
;	period to 1 as there is quite a lot of extra code executed after
;	your handler terminates. Note that the value of $20 is about as
;	small as you can reliably go. Faster processors would require
;	loops. Busy loops in interrupts are not a good thing but it
;	would seem to be the only solution. Check out SoundTracker/
;	ProTracker playroutines for some examples of horrendously
;	large busy loops in interrupt code! 
.lp
	dbra		d1,.lp


.skip
	move.w		d0,intreq(a0)		;clear interrupt
.ignore	
	movem.l		(sp)+,a0/d0-d1		;restore a0 and d0
	rte
	
*****************************************************************************

		section		sounds,DATA_C

Cycles
	dc.w	0
	
OldVector
	dc.l	0
		
SMP1		incbin		monobass	sample itself
SMP1LEN		equ		(*-SMP1)>>1	word length